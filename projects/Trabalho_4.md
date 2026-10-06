# Trabalho Nº 4

## x86: processamento vetorial

## 1. Instruções Gerais

- Grupos definidos no AVA;
- Ler o documento sobre Normas para entrega dos Relatórios;
- Ler atentamente todo o enunciado deste trabalho antes de realizá-lo;
- Consultar as referências adicionais e manuais sempre que necessário;
- Tornar todo o código disponível em um repositório ou pasta compartilhada com instruções de compilação.

## 2. Objetivos da Prática

- Conhecer o processador x86 e seu conjunto de instruções;
- Conhecer o mecanismo de processamento vetorial;
- Familiarizar-se com a programação assembly para resolver problemas simples;
- Descrever as atividades gerais desenvolvidas no trabalho em um relatório;

## 3. Materiais e Equipamentos

- Tutoriais sobre programação assembly x86 com NASM;
- NASM - The Netwide Assembler (Windows, Linux e Mac); e/ou
- Microsoft compiler (Windows)[^1];


## 4. Fundamentos teóricos

Agora que já conhecemos as arquiteturas ARM e RISC-V – conjunto de instruções, sintaxe da linguagem assembly, particularidades, etc. – podemos avançar para o estudo de uma arquitetura CISC[^2]: a x86. Como o próprio nome diz, processadores desta categoria possuem um número muito maior de instruções e essas, por sua vez, podem executar operações mais complexas. Elas podem ter, por exemplo, operandos em memória com modos de endereçamento diversos. A instrução `add [memoria], eax`, por exemplo, busca um valor na memória, soma com o valor de um registrador e grava o resultado de volta na memória. Seriam necessárias três instruções RISC para fazer a mesma coisa (`LOAD`/`ADD`/`STORE`).

Vamos aproveitar a oportunidade para compilar e executar programas reais, uma vez que esta é a arquitetura disponível em praticamente todos os computadores pessoais atuais. Para isso teremos que conhecer minimamente os formatos de arquivos executáveis usados nos sistemas operacionais, bibliotecas e ferramentas de compilação. Também vamos abordar o tema das instruções vetoriais, bastante usadas atualmente para se extrair melhor desempenho dos programas.

### 4.1. Sintaxe para assembly e inline

Sabemos que um processador possui um determinado conjunto de instruções (ISA) e que um montador traduz os mnemônicos das instruções para o código de máquina da arquitetura alvo. Além disso, o montador também aceita diretivas de compilação que servem para delimitar seções da memória, declarar variáveis inicializadas, entre outras possibilidades. Para o assembly x86 temos duas sintaxes mais conhecidas, como se pode ver na Tabela 1.

|   | AT&T | Intel |
|:---:|:---|:---|
|Ordem| `movl $5, %eax` | `mov eax, 5` |
|Tamanho| `addl $4, %esp` | `add esp, 4` |
|Endereços| `movl label(%ebx,%ecx,4), %eax` | `mov eax, [ebx + ecx*4 + label]` |

Tabela 1: Diferenças na sintaxe AT&T e Intel.

A sintaxe da Intel é mais parecida com as que utilizamos até agora, nela os operandos de destino das instruções ficam do lado esquerdo e o tamanho das operações é inferido automaticamente a partir dos operandos. Na sintaxe da AT&T eles ficam do lado direito, os nomes de registradores devem ser precedidos por `%`, os imediatos por `$` e as instruções têm um sufixo para indicar o tamanho da operação (`q` para quadword, `l` para long/dword, `w` para word e `b` para byte).

Os compiladores C/C++ e de outras linguagens possuem também uma sintaxe para se incluir código assembly no meio da linguagem original, isso se chama inline assembly. Embora a técnica possa ser útil em algumas situações, ela torna o código menos portátil e mais sujeito a erros. Aqui há um exemplo de como isso pode ser feito no GCC e no MSVC.

### 4.2. Formatos de arquivos executáveis

Os programas que geramos a partir de compiladores, montadores e ligadores possuem um formato próprio de acordo com o sistema operacional e, em alguns casos, da arquitetura alvo. Entre as razões para se compreender estes formatos, poderiam estar:

- Desenvolvimento de software;
- Estudo de sistemas operacionais;
- Perícia digital e resposta a incidentes (DFIR[^3]);
- Pesquisa de malware (análise binária); entre outras.

Infelizmente não teremos tempo suficiente para nos tornarmos hackers neste curso, mas a realização deste trabalho supõe a geração correta de binários executáveis para ao menos um sistema operacional. A seguir estão algumas referências úteis para entender um pouco mais sobre isso nos sistemas mais conhecidos:

- Windows;
- Linux;
- Mac.

Informações deste tipo podem ser necessárias na geração do binário, por exemplo, indicando o formato de saída. O código a seguir, usado como entrada no NASM, gera um executável para o Mac usando a função `puts` da biblioteca padrão para imprimir uma mensagem na tela:

```asm
;----------------------------------------------------------------------------;
; This is an macOS console program that writes "Ola, mundo".
;
; It uses puts from the C library. To assemble and run type:
;
; nasm -fmacho64 ola.asm && cc ola.o && ./a.out
;
;----------------------------------------------------------------------------;

global _main
extern _puts

section .text
_main:
    push rbx
    lea rdi, [rel msg]
    call _puts
    pop rbx
    ret

section .data
msg:
    db "Ola, mundo", 0
```

O arquivo resultante tem muito mais coisas do que o código de entrada, como podemos observar no comando a seguir:

```console
$ objdump -D a.out
a.out: file format Mach-O 64-bit x86-64
Disassembly of section __TEXT,__text:
0000000100003f87 _main:
100003f87: 53 pushq %rbx
100003f88: 48 8d 3d 81 40 00 00 leaq 16513(%rip), %rdi
100003f8f: e8 02 00 00 00 callq 2
100003f94: 5b popq %rbx
100003f95: c3 retq
```

Podemos notar que a ferramenta `objdump` não é capaz de interpretar corretamente o conteúdo que está em `msg` no final do comando, por ignorar qual o tipo de dado usado na declaração original. Se usarmos os comandos a seguir podemos conferir o conteúdo como do arquivo original:

```console
$ echo "Ola, mundo" | hexdump
0000000 4f 6c 61 2c 20 6d 75 6e 64 6f...
```

### 4.3. Instruções vetoriais

A maioria dos processadores modernos usam instruções vetoriais para computar vários valores a cada instrução. Algumas formas de se gerar código com estas instruções são:

- Autovetorização: os compiladores modernos são capazes de vetorizar automaticamente um programa, mas eles podem ter dificuldades com dependências entre iterações de um laço, tipos de dados misturados, condições complexas no código e índices, entre outras;
- Bibliotecas: ao invés de implementar operações comuns em vários programas (e.g., matriciais) podemos para isso invocar funções de uma biblioteca que já foi otimizada pelo fabricante do processador (MKL, TBB, IPP, DAAL, etc.);
- Intrinsics: são funções e tipos de dados interpretados de forma especial pelo compilador, mapeando diretamente para registradores e instruções específicas (e.g., vetoriais);
- Assembly: escrever o código assembly manualmente usando instruções vetoriais.

Embora as últimas formas sejam as mais complexas, elas permitem um controle maior sobre o código gerado e podem ser necessárias quando o compilador não consegue vetorizar determinado código automaticamente e a operação desejada é específica demais para estar disponível em uma biblioteca.

## 5. Procedimentos

Para realização deste trabalho, o grupo deverá implementar obrigatoriamente no mínimo 5 programas em assembly do x86 para Windows, Linux ou Mac (estamos falando de programas reais e não mais de simulações). As duas primeiras implementações serão efetuadas por todos os grupos; as outras podem ser escolhidas livremente a partir do número 3 da lista a seguir:

1. (obrigatório) Implementar um programa para converter a imagem contida em um arquivo `.bmp` em outra imagem preto e branco;
2. (obrigatório) Implementar um programa para aumentar o brilho de uma imagem colorida contida em um arquivo `.bmp` (basta somar uma constante em todos os canais de cor);
3. Implementar um programa para gerar o histograma de uma imagem;
4. Implementar o primeiro programa obrigatório com operações de ponto flutuante usando a equação $gray = (0,299 \times R + 0,587 \times G + 0,114 \times B)$;
5. Implementar um programa para borrar uma imagem (`blur`);
6. Pesquisar as calling conventions do x86 e implementar um programa que faça uso de `stack frame`;
7. Implementar um dos programas anteriores usando instruções vetoriais e comparar o desempenho com o programa original;
8. Implementar um programa para espelhar horizontalmente e/ou verticalmente uma imagem, tratando corretamente a ordem dos pixels e o cabeçalho BMP;
9. Implementar um detector de bordas simples, como Sobel ou diferença entre pixels vizinhos, usando apenas operações inteiras e comparar o resultado com uma imagem de referência;
10. Implementar um ajuste de brilho ou contraste em assembly, saturando os valores no intervalo `[0, 255]` e avaliando o efeito em imagens claras e escuras.
11. Implementar o tutorial SSE/AVX de vetorização no Google Colab, reproduzindo o conteúdo do link fornecido nas referências bibliográficas.

## Referências Bibliográficas

- https://www.tutorialspoint.com/assembly_programming/
- https://cs.lmu.edu/~ray/notes/nasmtutorial/
- https://www.intel.com/content/dam/develop/external/us/en/documents/319433-024-697869.pdf
- Tutorial de vetorização SSE/AVX: foi descontinuado, mas é possível reproduzir o conteúdo a partir dos links a seguir: 
    * https://www.codingame.com/playgrounds/283/sse-avx-vectorization/what-is-sse-and-avx
    * https://github.com/menotti/playground-41d1904q
    * https://colab.research.google.com/github/hussain0048/C-Plus-Plus/blob/master/Basic_of_C%2B%2B.ipynb

[^1]: Usa praticamente a mesma sintaxe do NASM e pode ser útil para quem usa o Visual Studio.

[^2]: Do inglês: Complex Instruction Set Computer.

[^3]: Do inglês: Digital Forensics and Incident Response.
