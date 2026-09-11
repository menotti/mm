.syntax unified
.arm
.text

.global convert_grayscale
.type convert_grayscale, %function

@ void convert_grayscale(int width, int height, uint8_t *pixels)
@ pixels contains width * height RGB pixels and is modified in place.
convert_grayscale:
        push    {r4, r5, r6, r7, r11, lr}

        cmp     r0, #1
        blt     .done
        cmp     r1, #1
        blt     .done

        add     r12, r0, r0, lsl #1       @ bytes per row: width * 3
        add     lr, r2, #2                @ point at blue in the first pixel
        mov     r3, #0                    @ row index

.row:
        mov     r2, lr
        mov     r4, r0                    @ pixels remaining in this row

.pixel:
        ldrb    r5, [r2, #-2]             @ red
        ldrb    r6, [r2, #-1]             @ green
        ldrb    r7, [r2]                   @ blue
        add     r5, r5, r6, lsl #1
        add     r5, r5, r7
        lsr     r5, r5, #2                @ (red + 2 * green + blue) / 4
        strb    r5, [r2, #-2]
        strb    r5, [r2, #-1]
        strb    r5, [r2]
        add     r2, r2, #3
        subs    r4, r4, #1
        bne     .pixel

        add     r3, r3, #1
        add     lr, lr, r12
        cmp     r3, r1
        bne     .row

.done:
        pop     {r4, r5, r6, r7, r11, lr}
        bx      lr

.size convert_grayscale, .-convert_grayscale