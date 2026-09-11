CROSS ?= arm-linux-gnueabihf
CC = $(CROSS)-gcc
QEMU ?= qemu-arm
CFLAGS = -marm -O2 -Wall -Wextra -std=c11
LDFLAGS = -static
TARGET = convert_grayscale

.PHONY: all run test clean

all: $(TARGET)

$(TARGET): main.o convert_grayscale.arm.o
	$(CC) $(LDFLAGS) -o $@ $^

main.o: main.c
	$(CC) $(CFLAGS) -c -o $@ $<

convert_grayscale.arm.o: convert_grayscale.arm.s
	$(CC) $(CFLAGS) -c -o $@ $<

run: $(TARGET)
	printf '255 0 0 0 255 0 0 0 255 255 255 255\n' | $(QEMU) ./$(TARGET) 2 2

test: $(TARGET)
	@actual=$$(printf '255 0 0 0 255 0 0 0 255 255 255 255\n' | $(QEMU) ./$(TARGET) 2 2); \
	expected='63 127 63 255'; \
	if test "$$actual" != "$$expected"; then \
		echo "falha: esperado '$$expected', obtido '$$actual'"; \
		exit 1; \
	fi; \
	echo "teste aprovado: $$actual"

clean:
	rm -f $(TARGET) *.o