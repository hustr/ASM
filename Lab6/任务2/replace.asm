.386
CODE	SEGMENT USE16
		ASSUME  CS:CODE, SS:STACK
		OLD_INT DW 0, 0
NEW16H  PROC
		CMP AH, 00H
		JE GETKEY
		CMP AH, 10H
		JE GETKEY
		; 调用旧中断
		CALL DWORD PTR CS:OLD_INT
		JMP ENDINT
GETKEY:
		PUSHF
		CALL DWORD PTR OLD_INT
		; 获取了扫描码和ASCII码
		; 判断大小写并转换
		CMP AL, 'a'
		JL 	ENDINT
		CMP AL, 'z'
		JG 	ENDINT
		; 是小写字母
		SUB AL, 32;变为大写
ENDINT:
	    IRET
NEW16H  ENDP
START:
		PUSH CS
		POP DS
		; code after this
		MOV AX, 3516H
		INT 21H
		MOV OLD_INT, BX
		MOV OLD_INT + 2, ES
		; 替换中断
		CLI;关闭中断响应
		MOV DX, OFFSET NEW16H
		MOV AX, 2516H
		INT 21H
		STI;开启中断
		; 替换完毕，准备驻留内存
		MOV DX, OFFSET START + 15
		SHR DX, 4
		ADD DX, 10H
		MOV AL, 0
		MOV AH, 31H
		INT 21H
CODE 	ENDS
STACK	SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK 	ENDS
		END  START
