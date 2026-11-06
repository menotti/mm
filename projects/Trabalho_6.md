# Trabalho Nº 6

## Microarquitetura: integração de processadores e vídeo VGA

## 1. Instruções Gerais

- Grupos definidos no AVA da disciplina;
- Ler o documento sobre Normas para entrega dos Relatórios;
	- Opcionalmente, o relatório pode ser escrito no `README.md`;
- Ler atentamente todo o enunciado deste trabalho antes de realizá-lo;
- Consultar as referências adicionais e os manuais sempre que necessário;
- A entrega será no repositório gerado para o grupo no Classroom 50;
- Tornar todo o código disponível no repositório ou na pasta compartilhada indicada pela disciplina, com instruções para reproduzir os experimentos realizados.

## 2. Objetivos da Prática

- Familiarizar-se com linguagens de descrição de hardware, como Verilog;
- Compreender a microarquitetura de processadores simples;
- Integrar um processador a um adaptador de vídeo VGA;
- Projetar ou modificar um processador simples em Verilog;
- Descrever as atividades desenvolvidas e os resultados obtidos em um relatório.

## 3. Materiais e Equipamentos

- Processador ARM monociclo no simulador [EDA Playground](https://www.edaplayground.com/); e/ou
- Processador RISC-V multiciclo no simulador [EDA Playground](https://www.edaplayground.com/);
- [Laboratório Remoto de Lógica Digital](https://legacy.vlab.dc.ufscar.br/camera.php), do DC/UFSCar.

## 4. Fundamentos teóricos

Este trabalho retoma os conteúdos estudados anteriormente na disciplina, sem introduzir novos fundamentos teóricos. Recomenda-se revisar a organização e o funcionamento dos processadores, o conjunto de instruções, a descrição de hardware em Verilog e a geração de vídeo VGA. O [Trabalho 5](Trabalho_5.md) apresenta uma introdução ao sinal VGA e a exemplos de geração de vídeo por hardware e por *framebuffer*.

## 5. Procedimentos

O grupo deverá implementar e testar no mínimo **duas configurações diferentes de hardware e/ou software**, preferencialmente no laboratório virtual. A primeira implementação é obrigatória para todos os grupos. A segunda deve ser escolhida entre as opções 2 a 7 da lista abaixo e informada com antecedência no fórum de dúvidas da disciplina. Cada grupo deverá escolher uma opção diferente.

1. **(obrigatório)** Integrar um dos processadores fornecidos — ARM ou RISC-V — ao módulo VGA de resolução 20 × 15. Implementar um programa que demonstre o funcionamento correto da integração e incluir pelo menos três instruções novas no processador.
2. Adaptar uma implementação do algoritmo de Mandelbrot, ou de outro algoritmo gráfico, para execução no hardware.
3. Modificar o adaptador de vídeo do uP1 para funcionar em modo texto com um mapa de caracteres. Nesse arranjo, uma ROM armazena o mapa e a memória de vídeo armazena o caractere correspondente a cada posição da tela.
4. Implementar ou adaptar o processador IAS, SAP-1 ou outro processador para funcionar com o adaptador de vídeo fornecido ou com uma versão modificada.
5. Implementar uma animação com funções trigonométricas usando software e/ou hardware.
6. Implementar um jogo simples usando software e/ou hardware.
7. Desenvolver um projeto relacionado a uma área de interesse do grupo, descrevendo previamente a proposta no fórum da disciplina.
8. Qualquer item do [Trabalho 5](Trabalho_5.md) que seja aplicável aqui. 

O relatório deve descrever as configurações implementadas, as alterações realizadas, os testes executados e seus resultados. Devem ser discutidas as decisões de projeto, as limitações encontradas e as instruções necessárias para reproduzir cada experimento.

## Referências Bibliográficas

- [Playlist sobre Verilog](https://www.youtube.com/playlist?list=PLhaFCmjMNuYZjAdJtC2WfDeHgR3daM9Tm)
- [Verilog Tutorial](http://asic-world.com/verilog/)
- [VGA Display Controller](https://reference.digilentinc.com/learn/programmable-logic/tutorials/vga-display-congroller/start)
- [LightRISCV](https://github.com/menotti/lightriscv)
