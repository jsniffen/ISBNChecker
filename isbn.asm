; File: Project1.asm 
;
; Find out if a number is a valid ISBN number
;

%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256


        SECTION .data                   ; initialized data section

msg1:   db "Enter 10 digit ISBN: "      ; user prompt
len1:   equ $-msg1                      ; length of first message

msg2:   db "This is a valid ISBN number.", 0Dh, 0Ah, 0 ; original string label
len2:   equ $-msg2                        ; length of second message

msg3:   db "This is NOT a valid ISBN number.", 0Dh, 0Ah, 0 ; converted string label
len3:   equ $-msg3

        SECTION .bss                    ; uninitialized data section
buf:    resb BUFLEN                     ; buffer for read
newstr: resb BUFLEN                     ; converted string
sum4:	resb 4				; sum
t4:	resb 4				; t4

        SECTION .text                   ; Code section.
        global  _start                  ; let loader see entry point

_start: nop                             ; Entry point.
start:                                  ; address for gdb

        ; prompt user for input
        ;
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg1               ; Arg2: addr of message
        mov     edx, len1               ; Arg3: length of message
        int     080h                    ; ask kernel to write

        ; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, buf                ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

L1_init:
        mov     ecx, 11                 ; initialize count
        mov     esi, buf                ; point to start of buffer
        mov     edi, newstr             ; point to start of new string
	mov	dword[sum4], 0			; set sum4 to zero
	mov	dword[t4], 0			; set t4 to zero
	
L1_one:
	dec	ecx
	jz	L1_end			; if runs ten times then exit
	
        mov     al, [esi]               ; get a character
        inc     esi                     ; update source pointer

	cmp	ecx, 1
	je	L1_check

	sub	al, '0'			; convert to a digit

	add	[t4], al		; add al to t4

        cmp     dword[t4], 10           ; more than 11?
	ja      L1_two			
	jmp	L1_three
	
L1_two:
	sub	dword[t4], 11		; subtract 11 from t4
	jmp	L1_three		; jump to 3
	
L1_three:
	mov	eax, dword[sum4]
	add	eax, dword[t4]  	; add t4 to sum4
	mov	dword[sum4], eax
	inc	edi			; update pointer
	cmp     dword[sum4], 10         ; more than 11?
        ja      L1_four
	jmp	L1_one

L1_four:
	sub 	dword[sum4], 11		; subtract 11 from sum4
	jmp	L1_one

L1_check:
	cmp	al, 'X'
	jne	L1_special

	add	dword[t4], 10

        cmp     dword[t4], 10           ; more than 11?
	ja      L1_two			
	jmp	L1_three

L1_special:
	sub	al, '0'			; convert to a digit

	add	[t4], al		; add al to t4

        cmp     dword[t4], 10           ; more than 11?
	ja      L1_two			
	jmp	L1_three
	
L1_end:

	; determine if isbn number
	;
	cmp	dword[sum4], 0		; subtract 0 from sum4
	je	If_1			; if zero -> valid
	jmp	If_2			; else -> not valid
	
If_1:				   	; if is valid isbn number
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg2               ; Arg2: addr of message
        mov     edx, len2               ; Arg3: length of message
        int     080h                    ; ask kernel to write
	jmp 	exit			; exit
	
If_2:	
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg3               ; Arg2: addr of message
        mov     edx, len3               ; Arg3: length of message
        int     080h                    ; ask kernel to write
	jmp	exit			; exit
	
	; final exit
        ;
exit:   mov     eax, SYSCALL_EXIT       ; exit function
        mov     ebx, 0                  ; exit code, 0=normal
        int     080h                    ; ask kernel to take over