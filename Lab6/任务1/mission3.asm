.386
STACK	SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK 	ENDS
CODE	SEGMENT USE16
		ASSUME  CS:CODE, SS:STACK
; 获取中断物理地址的函数，参数AL
; 返回值AX, BX：中断的物理地址
GET_INT PROC
		XOR EBX, EBX
		MOV BL, AL
		XOR EAX, EAX
		SHL BX, 2
		PUSH DS
		MOV AX, 0
		MOV DS, AX
		MOV AX, DS:[BX]
		MOV BX, DS:[BX + 2]
		POP DS
		RET
GET_INT ENDP
START:
		; code after this
		; 这个还行，直接读取
		MOV AL, 1H
		CALL GET_INT
		MOV AL, 10H
		CALL GET_INT
		;stop here
		MOV  AH, 4CH
		INT  21H	
CODE 	ENDS
		END  START
