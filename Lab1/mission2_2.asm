.386
STACK	SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK 	ENDS

DATA	SEGMENT USE16
BUF1 	DB 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
BUF2 	DB 10 DUP(0)
BUF3	DB 10 DUP(0)
BUF4	DB 10 DUP(0)
WAIT_STR DB "Press any key to begin!$"; dolar in the end
DATA	ENDS

CODE	SEGMENT USE16
		ASSUME  CS:CODE, DS:DATA, SS:DATA
START:
		MOV AX, DATA
		MOV DS, AX
		; code after here
		MOV SI, OFFSET BUF1
		MOV DI, OFFSET BUF2
		MOV BX, OFFSET BUF3
		MOV BP, OFFSET BUF4
		MOV CX, 10; count number
		LEA DX, OFFSET WAIT_STR;load offset
		MOV AH, 9;set function
		INT 21H ; call function
		; wait for key
		MOV AH, 1
		INT 21H
		; begin loop
LOPA:	MOV AL, [SI]; let ax = BUF1[0]
		MOV [DI], AL
		INC AL; add 1
		MOV [BX], AL
		ADD AL, 3; add 3
		MOV DS:[BP], AL
		INC SI
		INC DI
		INC BP
		INC BX
		DEC CX
		JNZ LOPA; check jmp or not
		;stop here
		MOV  AH, 4CH
		INT  21H	
CODE 	ENDS
		END  START
