    .section .data
buffer: .space 128          @ buffer para leitura (128 bytes máx)

    .section .text
    .globl _start
_start:
    @ read(0, buffer, 128)
    mov r7, #3              @ syscall read (Linux ARM)
    mov r0, #0              @ fd = 0 (stdin)
    ldr r1, =buffer         @ buffer destino
    mov r2, #128            @ tamanho máx
    svc #0
    mov r4, r0              @ r4 = número de bytes lidos (preservar)

    @ Converter somente letras A-Z em minúsculas
    ldr r1, =buffer         @ ponteiro para buffer
    mov r5, r4              @ contador de bytes
loop:
    cmp r5, #0
    beq done                @ se não há mais bytes -> fim
    ldrb r2, [r1], #1       @ lê próximo byte e incrementa ponteiro
    cmp r2, #'A'            @ 0x41
    blt skip                @ se < 'A' -> ignora
    cmp r2, #'Z'            @ 0x5A
    bgt skip                @ se > 'Z' -> ignora
    orr r2, r2, #0x20       @ força bit 5 -> minúsculo
    strb r2, [r1, #-1]      @ grava de volta, no endereço anterior
skip:
    subs r5, r5, #1         @ decrementa contador
    b loop
done:
    @ write(1, buffer, nbytes)
    mov r7, #4              @ syscall write (Linux ARM)
    mov r0, #1              @ fd = 1 (stdout)
    ldr r1, =buffer         @ endereço do buffer
    mov r2, r4              @ número de bytes lidos
    svc #0

    @ exit(0)
    mov r7, #1              @ syscall exit (Linux ARM)
    mov r0, #0
    svc #0
