org 0x7C00 ;tells nasm where to start the code usually 0x7C00 is the start of an operating system
bits 16    ;declaring a 16 bit os


main:
    hlt

.halt:
    jmp .halt   ;infinite loop to ensure nothing breaks down
 
times 510-($-$$) db 0  ;fills out empty space with 0's, $-current address, $$-start address, $-$$ = remaining address to be filled with 0
dw 0AA55h    ;signature, bios goes to the end of file and if its sees AA and 55 it determines it to be a bootloader