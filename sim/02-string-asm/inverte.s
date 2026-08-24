    .section .data
buffer: .space 128        # buffer para leitura (128 bytes máx)

    .section .text
    .globl _start
_start:
    # read(0, buffer, 128)
    li a7, 63             # syscall read
    li a0, 0              # fd = 0 (stdin)
    la a1, buffer         # buffer destino
    li a2, 128            # tamanho máx
    ecall
    mv s0, a0             # s0 = número de bytes lidos (preservar)









    # write(1, buffer, nbytes)
    li a7, 64             # syscall write
    li a0, 1              # fd = 1 (stdout)
    la a1, buffer         # endereço do buffer
    mv a2, s0             # número de bytes lidos
    ecall
    # exit(0)
    li a7, 93             # syscall exit
    li a0, 0
    ecall
