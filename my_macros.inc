%macro 	FINISH 0
	mov eax, 1
	mov ebx, 0
	int 80h
%endmacro

%macro 	READ 0          	; считываем символ со стандартного потока
	push ebx
	push ecx
	push edx
	pushfd
	push 0			; кладём на стек 0
	mov eax, 3		; номер вызова
	mov ebx, 1
	mov ecx, esp
	mov edx, 1
	int 80h			; системный вызов
	pop eax
	popfd
	pop edx
	pop ecx
	pop ebx
%endmacro

%macro 	WRITCH 1
	pushad 			; кладём на стек все регистры
	pushfd			; кладём на стек регистры флагов
	mov al, %1
	push ax
	mov eax, 4		; номер системного вызова
	mov ebx, 1		; дескриптор(в данном случае - стандартный поток)
	mov ecx, esp
	mov edx, 1
	int 80h
	add esp, 2
  	popfd
	popad
%endmacro


%macro 	WRITF 1 		; печать в файл
	pushad
	pushfd
	xor eax, eax
	mov al, %1
	push ax
	mov ebx, [tmp]
	mov eax, 4
	mov ecx, esp
	mov edx, 1
	int 80h
	add esp, 2
  	popfd
	popad
%endmacro

%macro  OPEN  1			; открываем файл
	pushad
	pushfd
	mov eax, 5
	mov ebx, %1
	mov ecx, 002h		; открываем на запись и на чтение
	mov edx, 066q
	int 80h
	mov [tmp], eax
	popfd
	popad
%endmacro

%macro  OPEN_out 1
	pushad
	pushfd
	mov eax, 5
	mov ebx, %1
	mov ecx, 241h
	mov edx, 066q
	int 80h
	mov [tmp], eax
	popfd
	popad
%endmacro

%macro  CLOSE 0         	; закрываем файл
	pushad
	pushfd
	mov eax, 6
	mov ebx, [tmp]
	int 80h
	popfd
	popad
%endmacro

%macro 	READf 0			; читаем с файла
	push ebx
	push ecx
	push edx
	pushfd

	push 0
	mov eax, 3
	mov ebx, [tmp]
	mov ecx, esp
	mov edx, 1
	int 80h			; системный вызов

	pop eax
	popfd
	pop edx
	pop ecx
	pop ebx
%endmacro
