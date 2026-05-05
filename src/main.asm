org 0x7C00 ;tells nasm where to start the code usually 0x7C00 is the start of an operating system
bits 16    ;declaring a 16 bit os


main:

    ;setup data segment
    mov ax,0
    mov ds,ax
    mov es,ax ;ensures ds/es can only be accessed using ax

    ;setup stack segments
    mov ss,ax
    mov sp, 0x7C00 ;stack grows downward, if we put at last of os it will override the operating system so we put at the first


    hlt

.halt:
    jmp .halt   ;infinite loop to ensure nothing breaks down
 
times 510-($-$$) db 0  ;fills out empty space with 0's, $-current address, $$-start address, $-$$ = remaining address to be filled with 0
dw 0AA55h    ;signature, bios goes to the end of file and if its sees AA and 55 it determines it to be a bootloader