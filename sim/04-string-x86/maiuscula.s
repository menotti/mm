    .section .bss
    .lcomm buffer, 128

    .section .text
    .globl _start
_start:
    # read(0, buffer, 128)
    mov $0, %eax            # syscall read (Linux x86-64)
    mov $0, %edi            # fd = 0 (stdin)
    lea buffer(%rip), %rsi  # buffer destino
    mov $128, %edx          # tamanho máximo
    syscall
    mov %rax, %r12          # quantidade de bytes lidos

    # Complete aqui a conversão de minúsculas para maiúsculas.

    # write(1, buffer, nbytes)
    mov $1, %eax            # syscall write (Linux x86-64)
    mov $1, %edi            # fd = 1 (stdout)
    lea buffer(%rip), %rsi  # endereço do buffer
    mov %r12, %rdx          # quantidade de bytes lidos
    syscall

    # exit(0)
    mov $60, %eax           # syscall exit (Linux x86-64)
    xor %edi, %edi
    syscall
