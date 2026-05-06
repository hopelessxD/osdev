org 0x7C00 ;tells nasm where to start the code usually 0x7C00 is the start of an operating system
bits 16    ;declaring a 16 bit os

%define ENDL 0x0D,0x0A ;hex code to go the the first of the line then jump down one line

;
;fat12 header
;

jmp short start                                     ;2 bytes
nop                                                 ;1 byte

bdb_oem:                     db 'MSWIN4.1'          ;8 bytes
bdb_bytes_per_sector:        dw 512
bdb_sectors_per_cluster:     db 1
bdb_reserved_sectors:        dw 1
bdb_number_of_fats:          db 2
bdb_dir_entries:             dw 0xe0
bdb_total_sectors:           dw 2880                ;2880 * 512 = 1.44MB
bdb_media_type:              db 0xf0
bdb_sectors_per_fat          dw 9
bdb_sectors_per_track        dw 18
bdb_heads:                   dw 2
bdb_hidden_sectors:          dd 0
bdb_large_sector_count:      dd 0

;extended boot record

ebr_drive_num:              db 0x00                 ;0x00 for floppy, 0x80 for hdd
                            db 0                    ;reserved
ebr_signature:              db 29h          
ebr_volume_id:              db 69h, 69h, 69h, 69h   ;serial number, value doesnt matter
ebr_volume_label:           db 'PRASANNA P.'        ;11 bytes,padded with string
ebr_system_id:              db 'FAT12   '           ;8 bytes



start:
    jmp main

;prints string to screen
;params:
;   -ds:si points to string

puts:
    ;push registers that we are modifying to save them before entering the main loop
    push si
    push ax

.loop:
    lodsb           ;loads a byte from ds:si then increments si very nice function 
    or al,al        ;verify if next character is null or not since or changes nothing except the zero flag
    jz .done
    
    mov ah,0x0e     ;calling bios interrupt INT 10h -- video, having ah = 0eh sets it to write mode
    int 0x10        ;combingin the two we can print a character using only BIOS functions

    jmp .loop

.done:
    pop ax
    pop si
    ret

main:

    ;setup data segment
    mov ax,0
    mov ds,ax
    mov es,ax ;ensures ds/es can only be accessed using ax

    ;setup stack segments
    mov ss,ax
    mov sp, 0x7C00 ;stack grows downward, if we put at last of os it will override the operating system so we put at the first

    ;read something from the disk
    mov [ebr_drive_num], dl ; BIOS sets drive number in dl register, we save it in our ebr_volume_label

    mov ax,1    ; LBA = 1, second sector from the disk
    mov cl,1    ; 1 sector to read
    mov bx,0x7e00
    call disk_read


    ;print message
    mov si, msg_hello
    call puts
    
    hlt

.halt:
    jmp .halt   ;infinite loop to ensure nothing breaks down



;
;Convert LBA to CHS 
;Params:
;   - ax: LBA address
;Returns:
;   -cx [bits 0-5]  : sector number
;   -cx [bits 6-15] : cylinder
;   -dh: head

lba_to_chs:

    push ax
    push dx

    mov dx,0                            ;dx=0
    div word [bdb_sectors_per_track]    ;ax = LBA / sectors per track
                                        ;dx = LBA % sectors per track
    inc dx                              ;dx = {LBA % sectors per track} + 1 = sector
    mov cx,dx

    mov dx,0
    div word [bdb_heads]                ;ax = (LBA / sectors per track) / head = cylinder
                                        ;dx = (LBA / sectors per track) % head = head 
    mov dh,dl                           ;dl = head
    mov ch,al                           ;al=cylinder 
    shl ah,6
    or cl,ah

    pop dx
    pop ax
    ret

;
;read sectors from disk
;params:
;   - ax : lba 
;   - cl : number of sectors to read
;   - dl : drive number
;   - es:bx : memory location where data is stored

disk_read:
    push cx                     ; temporarily save CL i.e. number of sectors to read
    call lba_to_chs             ; compute CHS
    pop ax                      ; AL = number of sectors to read

    mov ah,02h
    int 13h






msg_hello: db 'hello world',ENDL,0


times 510-($-$$) db 0  ;fills out empty space with 0's, $-current address, $$-start address, $-$$ = remaining address to be filled with 0
dw 0AA55h    ;signature, bios goes to the end of file and if its sees AA and 55 it determines it to be a bootloader