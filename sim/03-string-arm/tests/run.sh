#!/bin/bash

cd tests

arm-linux-gnueabihf-as ../$1.s -o $1.o && \
arm-linux-gnueabihf-ld $1.o -o $1.elf && \
qemu-arm ./$1.elf < string.in > $1.out

if diff $1.out $1.ok >/dev/null; then
    echo "OK"
    exit 0
else
    echo "ERRO"
    exit 1
fi
