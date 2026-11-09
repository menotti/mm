#!/bin/bash

cd tests

as --64 ../$1.s -o $1.o && \
ld -m elf_x86_64 $1.o -o $1.elf && \
./$1.elf < string.in > $1.out

if diff $1.out $1.ok >/dev/null; then
    echo "OK"
    exit 0
else
    echo "ERRO"
    exit 1
fi
