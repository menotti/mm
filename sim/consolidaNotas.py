#!/usr/bin/env python3
import pandas as pd
import glob
import os

# A) Acessar os arquivos diretamente no Drive
# from google.colab import drive
# drive.mount('/content/drive/', force_remount=True)
# path = '/content/drive/MyDrive/1_Ensino/_Disciplinas/Mic_e_Mic_(27146)/2026S2/'

# B) Subir os arquivos manualmente no Colab
# path = '/content/'

# C) Python local
path = './'

# --- 1. Definir nomes dos arquivos ---
main_grades_file = path + 'GRAD_turma-comma_separated.csv'
roster_file = path + 'mm_roster.csv'
scores_pattern = path + 'mm2026s2-*-scores.csv' # Corrigido de 's_pattern' para 'scores_pattern'

# --- 2. Carregar o arquivo principal de notas ---
try:
    df_grades = pd.read_csv(main_grades_file)
    print(f"Arquivo principal de notas '{main_grades_file}' carregado com sucesso.")
except FileNotFoundError:
    print(f"Erro: O arquivo '{main_grades_file}' não foi encontrado. Por favor, verifique o caminho e o nome do arquivo.")
    exit()

# --- 3. Carregar o arquivo de lista de alunos (roster) ---
try:
    df_roster = pd.read_csv(roster_file)
    print(f"Arquivo de lista de alunos '{roster_file}' carregado com sucesso.")
except FileNotFoundError:
    print(f"Erro: O arquivo '{roster_file}' não foi encontrado. Por favor, verifique o caminho e o nome do arquivo.")
    exit()

# --- 4. Encontrar e processar arquivos de notas das atividades ---
score_files = glob.glob(scores_pattern)

if not score_files:
    print(f"Aviso: Nenhum arquivo de notas de atividade encontrado com o padrão '{scores_pattern}'.")
else:
    email_col_grades = 'Email address'
    if email_col_grades not in df_grades.columns:
        print(f"Erro: A coluna '{email_col_grades}' não foi encontrada no arquivo principal de notas.")
        exit()
    else:
        print(f"Coluna de email identificada no arquivo principal de notas: '{email_col_grades}'")

    username_col_roster = 'username'
    email_col_roster = 'email'

    if username_col_roster not in df_roster.columns or email_col_roster not in df_roster.columns:
        print(f"Erro: As colunas '{username_col_roster}' e/ou '{email_col_roster}' não foram encontradas na lista de alunos.")
        exit()
    else:
        print(f"Colunas de link identificadas na lista de alunos: username='{username_col_roster}', email='{email_col_roster}'")

    for score_file in score_files:
        try:
            df_activity_scores = pd.read_csv(score_file)

            if df_activity_scores.empty:
                print(f"Aviso: O arquivo de notas da atividade '{score_file}' está vazio. Pulando.")
                continue

            print(f"\nProcessando arquivo de notas de atividade: '{score_file}'")

            activity_name = os.path.basename(score_file).replace('mm2026s2-', '').replace('-scores.csv', '')
            print(f"Nome da atividade detectado: {activity_name}")

            username_col_activity = 'usernames'
            score_col_activity = 'score'

            if username_col_activity in df_activity_scores.columns and score_col_activity in df_activity_scores.columns:
                new_score_col_name = f'{activity_name}'

                # Remove colunas existentes para esta atividade para evitar duplicações
                cols_to_drop = [col for col in df_grades.columns if new_score_col_name in col]
                if cols_to_drop:
                    df_grades.drop(columns=cols_to_drop, inplace=True)
                    print(f"Colunas existentes para '{activity_name}' ({cols_to_drop}) removidas antes da mesclagem.")

                # --- TRATAMENTO PARA MÚLTIPLOS USERNAMES POR LINHA ---
                # Converte para string, divide por vírgula (e limpa espaços extras) e depois explode as linhas
                df_activity_scores[username_col_activity] = df_activity_scores[username_col_activity].astype(str).str.split(',')
                df_exploded = df_activity_scores.explode(username_col_activity)
                df_exploded[username_col_activity] = df_exploded[username_col_activity].str.strip()

                # Mesclar com df_roster para obter o email a partir do username individual
                df_merged_activity = pd.merge(
                    df_exploded,
                    df_roster[[username_col_roster, email_col_roster]],
                    left_on=username_col_activity,
                    right_on=username_col_roster,
                    how='left'
                )

                # Adicionar a nota bruta da atividade e escalar de 0-10 para 0-100
                df_merged_activity[new_score_col_name] = df_merged_activity[score_col_activity].fillna(0) * 10

                # Mesclar as notas brutas com o dataframe principal de notas usando o email
                df_grades = pd.merge(
                    df_grades,
                    df_merged_activity[[email_col_roster, new_score_col_name]].dropna(subset=[email_col_roster]).drop_duplicates(subset=[email_col_roster]),
                    left_on=email_col_grades,
                    right_on=email_col_roster,
                    how='left'
                )
                df_grades.drop(columns=[email_col_roster], inplace=True, errors='ignore')
                print(f"Notas da atividade '{activity_name}' adicionadas ao arquivo principal (notas brutas, escaladas para 0-100).")

            else:
                print(f"Aviso: As colunas 'usernames' ou 'score' esperadas não foram encontradas no arquivo '{score_file}'. Pulando.")

        except Exception as e:
            print(f"Erro ao processar o arquivo '{score_file}': {e}. Pulando.")

# --- 5. Salvar o arquivo de notas atualizado ---
output_file = path + 'GRAD_turma-notas_consolidadas.csv'

if 'df_grades' in locals() and not df_grades.empty:
    df_grades.to_csv(output_file, index=False)
    print(f"\nArquivo de notas atualizado salvo como '{output_file}'.")
else:
    print("Não foi possível gerar o arquivo de notas atualizado devido a erros anteriores.")
