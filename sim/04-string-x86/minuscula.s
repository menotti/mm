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

    # Converter somente letras A-Z em minúsculas
    lea buffer(%rip), %r13  # ponteiro para buffer
    mov %r12, %r14          # contador de bytes
loop:
    test %r14, %r14
    jz done                 # se não há mais bytes, termina
    movzbl (%r13), %eax     # lê o próximo byte
    cmp $'A', %al
    jb skip                 # se < 'A', ignora
    cmp $'Z', %al
    ja skip                 # se > 'Z', ignora
    or $0x20, %al           # ativa o bit 5: maiúscula -> minúscula
    mov %al, (%r13)         # grava de volta no buffer
skip:
    inc %r13
    dec %r14
    jmp loop
done:
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
