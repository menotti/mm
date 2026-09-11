#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern void convert_grayscale(int width, int height, uint8_t *pixels);

static int read_byte(uint8_t *value)
{
    unsigned int number;

    if (scanf("%u", &number) != 1 || number > UINT8_MAX) {
        return 0;
    }
    *value = (uint8_t)number;
    return 1;
}

int main(int argc, char **argv)
{
    char *end;
    long width;
    long height;
    size_t pixel_count;
    size_t byte_count;
    uint8_t *pixels;

    if (argc != 3) {
        fprintf(stderr, "uso: %s LARGURA ALTURA < entrada_rgb.txt\n", argv[0]);
        return EXIT_FAILURE;
    }

    errno = 0;
    width = strtol(argv[1], &end, 10);
    if (errno != 0 || *end != '\0' || width < 1) {
        fprintf(stderr, "largura invalida: %s\n", argv[1]);
        return EXIT_FAILURE;
    }

    errno = 0;
    height = strtol(argv[2], &end, 10);
    if (errno != 0 || *end != '\0' || height < 1) {
        fprintf(stderr, "altura invalida: %s\n", argv[2]);
        return EXIT_FAILURE;
    }

    pixel_count = (size_t)width * (size_t)height;
    if (pixel_count > SIZE_MAX / 3) {
        fprintf(stderr, "imagem grande demais\n");
        return EXIT_FAILURE;
    }
    byte_count = pixel_count * 3;
    pixels = malloc(byte_count);
    if (pixels == NULL) {
        perror("malloc");
        return EXIT_FAILURE;
    }

    for (size_t index = 0; index < byte_count; ++index) {
        if (!read_byte(&pixels[index])) {
            fprintf(stderr, "entrada invalida: esperado um byte RGB por vez\n");
            free(pixels);
            return EXIT_FAILURE;
        }
    }

    convert_grayscale((int)width, (int)height, pixels);

    for (size_t index = 0; index < byte_count; index += 3) {
        if (index != 0) {
            putchar(' ');
        }
        printf("%u", pixels[index]);
    }
    putchar('\n');

    free(pixels);
    return EXIT_SUCCESS;
}