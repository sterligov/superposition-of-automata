; суперпозиция автоматов

%include "my_macros.inc"
global _start
section .bss
tmp	   resd    1                 ; дескриптор, возращаемый при открытии файла
start_1    resb	   1024          ; массив начального состояния первого автомата
start_2    resb    1024
start_s    resb    1024
numVar_1   resd	   1		         ; количество переменных кодирующих состояние первого автомата
numVar_2   resd    1
numVal_1   resd    1             ; количество значений функций переходов и выхода первого автомата
numVal_2   resd    1
numVar_s   resd    1
numVal_s   resd    1
exit_1	   resb    1024          ; массив функции выхода первого автомата
exit_2     resb	   1024
exit_s     resb    1024
trans_1	   resb    100*100       ; массив функций переходов первого автомата
trans_2    resb    100*100
trans_s    resb    200*200
in_        resb    50            ; входной файл
section .data
ind   db  0
out_  db  "out.txt", 0
section .text
_start:

	      mov ebp, in_
	      call SCAN

	      OPEN in_
	      push dword start_1
	      push dword exit_1
	      push dword trans_1
	      push dword numVal_1
	      push dword numVar_1
	      call READ_FILE
	      add esp, 20

	      push dword start_2
	      push dword exit_2
	      push dword trans_2
	      push dword numVal_2
	      push dword numVar_2
	      call READ_FILE
	      add esp, 20
	      CLOSE

	      mov cl, [numVar_1]
	      mov bl, [numVar_2]
	      add cl, bl
	      mov [numVar_s], ecx

	      add cl, 1
	      mov eax, 1
	      shl eax, cl
	      mov [numVal_s], eax
	      mov eax, [numVar_s]

	      call SUPER                    ; строим суперпозицию
	      CALL PRINT_FILE
	      OPEN
FINISH



GET_num:
	      push eax
	      push ebx
	      push ecx
	      push edx
	      push esi
	      pushfd
	      mov ebx, 1
	      xor edi, edi
	      xor ecx, ecx
	      xor eax, eax
	      mov esi, 10
.lp:
	      READf
	      cmp al, 32
	      je .lp_1
	      cmp al, 10
	      je .lp_1
	      sub al, '0'
	      push eax
	      inc ecx
	      jmp .lp
.lp_1:
	      pop eax
	      mul ebx
	      add edi, eax
	      mov eax, ebx
	      mul esi
	      mov ebx, eax
	      xor eax, eax
	      dec ecx
	      cmp ecx, 0
	      jne .lp_1
	      popfd
	      pop esi
	      pop edx
	      pop ecx
	      pop ebx
	      pop eax
	      ret



PRINT_FILE:	; читаем с файла автоматы, параметры - массивы: начального состояния, функция выхода, функция переходов(двумерный)
		; переменные: количество значений функций переходов и выходов, количество переменных кодирующих состояние автомата
	      mov eax, [numVar_s]
	      call PRINT_num
	      WRITCH 32
	      xor ecx, ecx
.lp:	      WRITCH [start_s+ecx]
	      inc ecx
	      cmp ecx, [numVar_s]
	      jne .lp

	      WRITCH 10

	      xor ecx, ecx
	      xor edx, edx
	      xor ebx, ebx
.lp_i:
	      WRITCH '2'
	      WRITCH 32
	      mov eax, [numVar_s]
	      add eax, 1
	      call PRINT_num
	      WRITCH 32		; пробел

.lp_j:
	      WRITCH [trans_s+ecx+ebx]
	      add ebx, [numVar_s]
	      inc edx
	      cmp edx, [numVal_s]
	      jne .lp_j
	      xor edx, edx
	      WRITCH 10
	      xor ebx, ebx
	      inc ecx
	      cmp ecx, [numVar_s]
	      jne .lp_i

	      WRITCH '2'
	      WRITCH 32
	      mov eax, [numVar_s]
	      add eax, 1
	      call PRINT_num
	      WRITCH 32		; пробел

	      xor ecx, ecx
.lp_e         WRITCH [exit_s+ecx]
	      inc ecx
	      cmp ecx, [numVal_s]
	      jne .lp_e
	      WRITCH 10
	      ret




SCAN:
	      xor ecx, ecx
.lp:          READ
	      cmp al, 10
	      je .fin
	      mov [ebp+ecx], al
              inc ecx
	      jmp .lp
.fin	      mov [ebp+ecx], byte 0
	      ret



SUPER:

	      mov esi, start_1      ; адрес start_1
	      mov edi, start_s      ; адрес start_s
	      mov ecx, [numVar_1]   ; кладём в ecx numVar_1
	      cld
	      rep movsb

	      mov ecx, [numVar_1]
	      mov edi, start_s
	      add edi, ecx
	      mov ecx, [numVar_2]
	      mov esi, start_2
	      cld
	      rep movsb
	      xor ebx, ebx
	      xor ecx, ecx
	      xor edx, edx
.lp_i:

.lp_j:
	      push ecx
	      mov eax, ecx
	      mul byte [numVar_1]
	      mov ecx, [numVar_1]
	      mov esi, trans_1
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_1]
	      add ebx, ecx
	      pop ecx

	      cmp byte [exit_1+ecx], '0'
	      je .if_1
	      jmp .go
.if_1:	      push ecx
	      mov eax, edx
	      mul byte [numVar_2]
	      mov ecx, [numVar_2]
	      mov esi, trans_2
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_2]
	      add ebx, ecx
	      mov eax, ebx
	      pop ecx

	      mov ebp, [ind]
	      mov eax, [exit_2+edx]
	      mov [exit_s+ebp], eax
	      inc ebp
	      mov [ind], ebp


.go:          cmp byte [exit_1+ecx], '1'
	      je .if_2
	      jmp .stage_2
.if_2:        push ecx
	      mov eax, edx
	      add eax, 1
	      mul byte [numVar_2]
	      mov ecx, [numVar_2]
	      mov esi, trans_2
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_2]
	      add ebx, ecx
	      pop ecx

	      mov ebp, [ind]
	      mov eax, [exit_2+edx+1]
	      mov [exit_s+ebp], eax
	      inc ebp
	      mov [ind], ebp

.stage_2:     push ecx
	      mov eax, ecx
	      add eax, 1
	      mul byte [numVar_1]
	      mov ecx, [numVar_1]
	      mov esi, trans_1
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_1]
	      add ebx, ecx
	      pop ecx

	      cmp byte [exit_1+ecx+1], '0'
	      je .if_3
	      jmp .go_2
.if_3:	      push ecx
	      mov eax, edx
	      mul byte [numVar_2]
	      mov ecx, [numVar_2]
	      mov esi, trans_2
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_2]
	      add ebx, ecx
	      pop ecx

	      mov ebp, [ind]
	      mov eax, [exit_2+edx]
	      mov [exit_s+ebp], eax
	      inc ebp
	      mov [ind], ebp

.go_2:	      cmp byte [exit_1+ecx+1], '1'
	      je .if_4
	      jmp .go_3
.if_4:        push ecx
	      mov eax, edx
	      add eax, 1
	      mul byte [numVar_2]
	      mov ecx, [numVar_2]
	      mov esi, trans_2
	      add esi, eax
	      mov edi, trans_s
	      add edi, ebx
	      cld
	      rep movsb
	      mov ecx, [numVar_2]
	      add ebx, ecx
	      pop ecx

	      mov ebp, [ind]
	      mov eax, [exit_2+edx+1]
	      mov [exit_s+ebp], eax
	      inc ebp
	      mov [ind], ebp


.go_3:	      add edx, 2
	      cmp edx, [numVal_2]
	      jne .lp_j
	      xor edx, edx
	      add ecx, 2
	      cmp ecx, [numVal_1]
	      jne .lp_i

	      ret


READ_FILE:
	      mov ebp, esp
	      call GET_num
	      mov ecx, edi
	      mov ebx, [ebp+4]
	      mov [ebx], edi
;	      READf
	      cmp [ebx], byte 0
	      je  .lp3
	      mov ebx, [ebp+20]
	      xor edx, edx
.lp:	      READf
	      mov [ebx+edx], eax
	      inc edx
	      loop .lp

.lp3:	      mov ebx,   [ebp+4]
	      mov cl, 	 [ebx]
	      add cl,	 1
	      mov eax, 1
	      shl eax, cl
	      mov ebx, [ebp+8]
	      mov [ebx], eax
	      mov ebx, [ebp+4]
	      cmp [ebx], byte 0
	      je .zer

 	      READf

	      mov ebx,   [ebp+4]
	      mov edi,   [ebx]
	      mov ebx,   [ebp+8]
	      mov edx,   [ebx]
	      mov ebx,   [ebp+12]
	      xor ecx, ecx
	      xor esi, esi
.lp_j:
	      READf
	      READf
	      push edi
	      call GET_num
	      pop edi

.lp_i:
	      READf
	      push edx
	      push eax
	      mov eax, edi
	      mul ecx
	      add eax, esi
	      mov edx, eax
	      pop eax
	      mov [ebx+edx], al
	      pop edx
	      inc ecx
	      cmp ecx, edx
	      jne .lp_i
	      xor ecx, ecx
	      READf
	      inc esi
	      cmp esi, edi
	      jne .lp_j

.zer	      READf
	      READf
	      push edi
	      call GET_num
	      pop edi
	      mov ecx, edx
	      mov ebx, [ebp+16]
	      xor edx, edx
.lp2	      READf
	      mov [ebx+edx], al
	      inc edx
	      loop .lp2
	      READf
	      ret


PRINT_num: 				; печатаем число из регистра eax
	      pushad
	      xor ecx, ecx
	      xor edx, edx
	      mov ebx, 10
.lp1:
	      div ebx
	      add dl, '0'
	      push edx
	      xor edx, edx
	      inc ecx
	      cmp eax, 0
	      jg .lp1
              xor eax, eax
.lp2:
	      pop eax
	      WRITCH al
	      xor eax, eax
	      loop .lp2
	      popad
	      ret
