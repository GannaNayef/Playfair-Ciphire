INCLUDE Irvine32.inc
INCLUDE macros.inc
BUFFER_SIZE = 5000

.data
buffer BYTE BUFFER_SIZE DUP(?)
filename BYTE "key.txt", 0 
filenameOut BYTE "output.txt", 0
fileHandle HANDLE ?
stringLength DWORD ?
bytesWritten DWORD ?
str1 BYTE "Cannot create file", 0
str2 BYTE "Bytes written to file [output.txt]:", 0
TABLE DWORD 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K' , 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
INSERT DWORD 25 DUP(?)
KEY DWORD 1000 DUP(?)
sz DWORD ?
F_ROW DWORD ?
F_COL DWORD ?
S_ROW DWORD ?
S_COL DWORD ?
USER_MESSAGE DWORD 'F', 'A', 'J', 'I', 'T', 'A'
message DWORD 2000 DUP(?)
tmp BYTE 2000 DUP(?)
encrpt_message DWORD 'N','P','Z','P','Z','P','J','M','F','J','V','J'
decrypt_message DWORD 1000 dup(?)
need_filter DWORD 2000 dup(?)
final DWORD 1000 dup(?)
final_cont DWORD 0
FIRST DWORD ?
SEC DWORD ?
cont DWORD 0
CONTER DWORD 0
ROW DWORD 0
COL DWORD 0
insert_x DWORD 'X'
len DWORD 0
divbytwo DWORD 2
.code

main PROC

	CALL READ_FILE
	CALL COMPLETE_MATRIX
	
	CALL REBUILD
 
	;CALL Encrypt
 
	CALL Decryption
	;call printdec
	CALL WRITE_FILE
exit
main ENDP
;takes every two char in the message to decrypt it and put it int the encrpt_message
Encrypt PROC
 
MOV EDI , OFFSET MESSAGE
MOV ESI , OFFSET encrpt_message
mov edx ,0
mov eax ,len
div divbytwo
mov ecx , eax
FILL:
PUSH ECX
MOV ROW ,0 
MOV COL ,0
mov F_ROW,0
MOV F_COL ,0
mov S_ROW,0
MOV S_COL,0
CALL find_char
CALL encrpyt_chars
ADD ESI, 8
ADD EDI, 8
POP ECX
LOOP FILL
 
RET
Encrypt ENDP
;-----------------DECRPTION FUNCTION--------------------
Decryption PROC
MOV EDI , OFFSET encrpt_message
MOV ESI , OFFSET decrypt_message
 
mov edx ,0
mov eax ,lengthof encrpt_message
div divbytwo
 
mov ecx , eax
FILL:
PUSH ECX
MOV ROW ,0 
MOV COL ,0
mov F_ROW,0
MOV F_COL ,0
mov S_ROW,0
MOV S_COL,0
CALL find_char
CALL decrpt_char
ADD ESI, 8
ADD EDI, 8
POP ECX
LOOP FILL

mov ecx ,lengthof encrpt_message 
;sub ecx ,2
mov esi , offset decrypt_message
show:
mov eax , [esi]
call writechar
mov al , ' '
call writechar
add esi ,4
loop show
 call crlf
 

RET
Decryption ENDP
;------------------ filter any X after decryption ------------------
printdec PROC
mov cont , 0
mov esi , offset decrypt_message
mov edi , offset final
mov ecx , lengthof encrpt_message
 
check:
mov eax , insert_x
cmp eax , [esi]
je found
inserttt:
mov eax , [esi]
mov [edi], eax
add edi , 4
inc final_cont
jmp finish
found:
cmp cont , 0
je inserttt
mov eax , len
cmp cont, eax
je inserttt
mov eax , [esi - 4]
mov ebx , [esi + 4]
cmp eax , ebx
jne inserttt
;mov esi ,4
 
finish:
add esi ,4
inc cont
loop check

mov ecx ,final_cont 
;sub ecx ,2
mov esi , offset final
show:
mov eax , [esi]
call writechar
mov al , ' '
call writechar
add esi ,4
loop show
 call crlf
 
 
 
RET
printdec ENDP
;---------------------get two chars in decrption  ------------------------
decrpt_char PROC
 
MOV EAX , F_ROW
CMP EAX, S_ROW
JE ROWEQL
MOV EAX , F_COL
CMP EAX, S_COL
JE COLEQL
 
MOV EAX, S_COL
XCHG F_COL, EAX
MOV S_COL, EAX
JMP F
ROWEQL:
cmp S_COL , 0
je swapcol
dec F_COL
dec S_COL
jmp F
swapcol:
mov S_COL ,4
dec F_COL
JMP F
COLEQL:
cmp S_ROW,0
je swaprow
dec F_ROW
dec S_ROW
Jmp F
swaprow:
mov S_ROW ,4
dec F_ROW
F:
MOV EAX,  5* TYPE INSERT
MUL F_ROW
MOV EBX ,EAX
MOV EAX , 1* TYPE INSERT
MUL F_COL
MOV EDX , INSERT[EAX + EBX]
MOV [ESI] , EDX
S:
MOV EAX,  5* TYPE INSERT
MUL S_ROW
MOV EBX ,EAX
MOV EAX , 1* TYPE INSERT
MUL S_COL
MOV EDX , INSERT[EAX + EBX]
MOV [ESI+4], EDX
 
RET
decrpt_char ENDP
;--------------------- REBUILD ---------------------------------------
;check if there any 2 duplicated items and put X between them
REBUILD PROC    
    mov esi , offset message
    mov edi , offset USER_message
    mov ecx , lengthof USER_message 
    L1:
         mov ebx , [edi]
         mov edx , [edi+4]
         mov [esi] ,ebx
         cmp ebx , edx
         jne continue
         mov eax , insert_x
         mov[esi+4], eax
         add esi , 4
         inc len
         continue:
          add esi,4
          add edi,4
          inc len     
    loop L1   
    mov edx, 0
    mov eax ,len
    div divbytwo
    cmp edx ,0
    je nth
    mov eax , insert_x
    mov [esi],eax
    inc len
    nth: 
RET 
REBUILD ENDP

;--------------------find 2 chars in the matrix---------------------------
; find the row and column of the two chars in the matrix
find_char PROC 
 
MOV ECX , 5
OUTER:
PUSH ECX
MOV ECX, 5
MOV COL, 0
INNER:
MOV EAX, 5 * TYPE INSERT
MUL ROW
MOV EBX, EAX
MOV EAX, 1* TYPE INSERT
MUL COL
MOV EDX, INSERT [ EAX + EBX ]
CMP  EDX, [EDI]
JE FOUNDF
CMP EDX , [EDI+4]
JE FOUNDSEC
JMP ENDD
FOUNDF:
MOV EAX, ROW
MOV F_ROW, EAX
MOV EAX ,COL
MOV F_COL, EAX
 
JMP ENDD
FOUNDSEC:
MOV EAX , ROW
MOV S_ROW,EAX 
MOV EAX , COL
MOV S_COL , EAX
ENDD:
INC COL
LOOP INNER
INC ROW
POP ECX
LOOP OUTER
 
 
 RET 
find_char ENDP

;-------------------Get the chars in encription 'function------------------------
;takes the original two chars and return in the encrpt message the encrypted chars
encrpyt_chars PROC
 
MOV EAX , F_ROW
CMP EAX, S_ROW
JE ROWEQL
MOV EAX , F_COL
CMP EAX, S_COL
JE COLEQL
 
MOV EAX, S_COL
XCHG F_COL, EAX
MOV S_COL, EAX
JMP F
ROWEQL:
cmp S_COL , 4
je swapcol
inc F_COL
inc S_COL
jmp F
swapcol:
mov S_COL ,0
inc F_COL
JMP F
COLEQL:
cmp S_ROW,4 
je swaprow
INC F_ROW
INC S_ROW
Jmp F
swaprow:
mov S_ROW ,0
inc F_ROW
F:
MOV EAX,  5* TYPE INSERT
MUL F_ROW
MOV EBX ,EAX
MOV EAX , 1* TYPE INSERT
MUL F_COL
MOV EDX , INSERT[EAX + EBX]
MOV [ESI] , EDX
S:
MOV EAX,  5* TYPE INSERT
MUL S_ROW
MOV EBX ,EAX
MOV EAX , 1* TYPE INSERT
MUL S_COL
MOV EDX , INSERT[EAX + EBX]
MOV [ESI+4], EDX
 
RET 
encrpyt_chars ENDP
 
COMPLETE_MATRIX PROC

	MOV ESI, OFFSET KEY
	MOV EDX, OFFSET INSERT
	MOV ECX, SZ
	MOV EAX, [ESI]
	CMP EAX, 'J'
	JNZ CREATE
	MOV EAX, 'I'
	MOV [ESI], EAX
	
	CREATE:
		MOV EDI, OFFSET INSERT
		PUSH ECX
		MOV ECX, LENGTHOF INSERT
		MOV EAX, [ESI]
		REPNE SCASD
		JZ FOUND
		MOV [EDX], EAX
		ADD EDX, TYPE INSERT
	    
		FOUND:
			POP ECX
			ADD ESI, TYPE KEY
			MOV EAX, [ESI]
			CMP EAX, 'J'
			JNZ DONE
		
		N:
			MOV EAX, 'I'
			MOV [ESI], EAX
 
		DONE:
	LOOP CREATE
 
	MOV EBX, OFFSET TABLE
	MOV ECX, LENGTHOF TABLE
 
	CONCREATE:
		MOV EDI,  OFFSET INSERT
		PUSH ECX
		MOV ECX, LENGTHOF INSERT
		MOV EAX, [EBX]

		REPNE SCASD
 
		JZ F
		MOV [EDX], EAX
		ADD EDX, TYPE INSERT
 
		F:
			POP ECX
			ADD EBX, TYPE TABLE
	LOOP CONCREATE
	RET

COMPLETE_MATRIX ENDP

READ_FILE PROC
	
	MOV EDX, OFFSET filename
	MOV ECX, SIZEOF filename
	CALL READSTRING
	MOV EDX, OFFSET filename
	CALL OPENINPUTFILE
	MOV fileHandle, EAX
	CMP EAX, INVALID_HANDLE_VALUE 
	JNE file_ok 
	JMP quit ; and quit
	
	file_ok:
		MOV EDX, OFFSET buffer
		MOV ECX, BUFFER_SIZE
		CALL READFROMFILE
		JNC check_buffer_size 
		CALL WRITEWINDOWSMSG
		JMP close_file
	
	check_buffer_size:
		CMP EAX, BUFFER_SIZE 
		JB buf_size_ok 
		JMP quit ;and quit
	
	buf_size_ok:
		MOV buffer[EAX], 0 
		MOV sz, EAX 
		MOV EDX, OFFSET buffer
		MOV ESI, OFFSET KEY
		MOV ECX, sz
		
	L1:
		MOV BL, BYTE PTR [EDX]
		MOV BYTE PTR [ESI], BL
		INC EDX
		ADD ESI, TYPE KEY
	LOOP L1
	
	close_file:
		MOV EAX, fileHandle
		CALL CLOSEFILE
	
	quit:
	
	RET
READ_FILE ENDP

WRITE_FILE PROC
                                    ; Create a new text file.
	mov edx,OFFSET filenameOut
	call CreateOutputFile
	mov fileHandle,eax
                                   ; Check for errors.
	cmp eax, INVALID_HANDLE_VALUE       ; error found?
	jne file_ok                         ; no: skip
	mov edx,OFFSET str1                 ; display error
	call WriteString
	jmp quit
	
	file_ok:
                                  
		MOV ECX, len
		MOV EDX, OFFSET encrpt_message
		MOV ESI, OFFSET tmp
		
	
					             ;counts chars entered
                                 ;Write the buffer to the output file.

		MOV EAX, LEN
		MOV EBX, 4
		MUL ebx
		MOV ECX, EAX
		SUB ECX, 8
		mov eax, fileHandle
		mov edx, OFFSET encrpt_message
		call WriteToFile
		mov bytesWritten, eax             ;save return value
		call CloseFile
                                 ;Display the return value.
		mov edx, OFFSET str2              ;"Bytes written"
		call WriteString
		mov eax, bytesWritten
		call WriteDec
		call Crlf
	quit:
	exit
	RET
WRITE_FILE ENDP
END main