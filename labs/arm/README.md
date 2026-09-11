# Conversão de imagem para tons de cinza em _assembly_ do processador ARM

Esta atividade combina um programa C com uma função escrita em _assembly_ ARM usando GCC e QEMU para testar. A funcao `convert_grayscale` recebe:

```c
void convert_grayscale(int width, int height, uint8_t *pixels);
```

`pixels` é um vetor RGB intercalado, com `width * height * 3` bytes. A
conversao é feita no proprio vetor: para cada pixel, os três componentes sao
substituidos por:

```text
cinza = (vermelho + verde << 1 + azul) >> 2
```

## Dependências

Em um ambiente Debian/Ubuntu, instale:

```sh
sudo apt install gcc-arm-linux-gnueabihf qemu-user
```

## Compilar e executar

O programa recebe a largura e a altura na linha de comando e lê os bytes RGB,
em decimal, pela entrada padrão. Ele imprime um byte de cinza por pixel.

```sh
make
printf '255 0 0 0 255 0 0 0 255 255 255 255\n' | \
    qemu-arm ./convert_grayscale 2 2
```

Saida:

```text
63 127 63 255
```

O teste automatizado compila o programa e executa o mesmo caso:

```sh
make test
```

Para remover os arquivos gerados:

```sh
make clean
```

# Referências

- https://github.com/menotti/convert_grayscale 