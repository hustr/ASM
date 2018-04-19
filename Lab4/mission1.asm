.386
STACK	SEGMENT USE16 STACK
        DB 400 DUP(0)
STACK 	ENDS
DATA	SEGMENT USE16
NOTICE_NAME	DB 'Please enter user name: $', 5 DUP(0)
NOTICE_PWD DB 'Please enter user password: $', 2 DUP(0)
BNAME  	DB 'yaning', 4 DUP(0); 用户名
BPASS	DB 'passwd', 4 DUP(0); 密码
IN_NAME DB 20, ?, 20 DUP(0)
IN_PWD	DB 20, ?, 20 DUP(0)
G_CNT	= 60
S1		DB 'SHOP1', 5 DUP(0)
BAG1	DB 'BAG', 7 DUP(0)
		DW 12, 30, 1000, 5, ? ; 利润率未计算
G_SIZE  = $ - BAG1
GA1		DB 'PEN', 7 DUP(0)
		DW 35, 56, 70, 25, ? ; 利润率未计算
GA2		DB 'BOOK', 6 DUP(0)
		DW 12, 30, 25, 5, ? ; 利润率未计算
GAN		DB G_CNT - 3 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, 2, 0, ?, ?); 其他商品暂时未知

S_SIZE	= $ - S1

S2 		DB 'SHOP2', 5 DUP(0) ;网店名称，用0结束
BAG2	DB 'BAG', 7 DUP(0)
		DW 12, 30, 2000, 2, ? ; 利润率未计算
GB1   	DB 'PEN', 7 DUP(0) ;商品名称
		DW 35, 50, 30, 24, ?  ;利润率还未计算
GB2   	DB 'BOOK', 6 DUP(0) ; 商品名称
		DW 12, 28, 20,15, ? ;利润率还未计算
GBN		DB G_CNT - 3 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, 2, 0, ?, ?)
AUTH	DB 0; 标志是否通过验证
GG_INDEX DD 2 DUP(0); 一共两家店,存放查询的物品的地址在内存中
G_INDEX	DD 0
SHIFTLINE DB 13, 10, '$'
S_CNT	= 2
S_TEMP_CNT DB 0
G_TEMP_CNT DB 0

SG_INDEX DD 0
S_INDEX DD 0
G_COST  DD 0
G_PRO   DD 0

TIME 	DD 0
; 菜单字符串
query	DB "Query goods.$"
modify	DB "Modify goods.$"
calcu_pro	DB "Calcu average profile rate.$"
sort_pro	DB "Sort the profile rate.$", 
print_all	DB "Print all goods's information.$", 9 DUP(0)
exit	DB "Exit the program.$"
; proc
;output
_ADD	DW 0
NUM 	DD 0
DATA	ENDS

CODE	SEGMENT USE16
		ASSUME  CS:CODE, SS:STACK, DS:DATA, ES:DATA
START:
		MOV AX, DATA
		MOV DS, AX
		; code after this
FUNC1:  ; 功能1开始
		PUSH OFFSET NOTICE_NAME
		CALL OUTPUT
		PUSH OFFSET IN_NAME
		CALL INPUT
		CALL CRLF
		PUSH OFFSET NOTICE_PWD
		CALL OUTPUT
		PUSH OFFSET IN_PWD
		CALL INPUT
		CALL CRLF
FUNC2:  ;功能2开始
		; 用户名输入长度为0？
		MOV AUTH, 0
		CMP IN_NAME[1], 0
		; 调到功能3
		JZ FUNC3
		; 长度为1，检测是否是q
		CMP IN_NAME[1], 1
		; 不是1跳check_name
		JG CHECK_NAME
		CMP IN_NAME[2], 'q'
		; 输入为q，退出
		JZ QUIT
CHECK_NAME:
		; 检查用户名
		; 已知用户名长度为6，作为已知量使用
		CMP IN_NAME[1], 6
		; 不为6错误
		JNZ FUNC1
		MOV CX, 6
		LEA EBX, OFFSET IN_NAME + 2
		LEA EDX, OFFSET BNAME
LOOP_NAME:  ; 偷懒从高到低检查
		MOV AH, [EBX]
		MOV AL, [EDX]
		CMP AH, AL
		JNZ FUNC1
		INC EBX
		INC EDX
		LOOP LOOP_NAME
		; 密码也是6位
		CMP IN_PWD[1], 6
		JNZ FUNC1
		MOV CX, 6
		LEA EBX, OFFSET IN_PWD
		ADD EBX, 2
		LEA EDX, OFFSET BPASS
LOOP_PWD:
		MOV AH, [EBX]
		MOV AL, [EDX]
		CMP AH, AL
		; 密码不同跳功能1
		JNZ FUNC1
		INC EBX
		INC EDX
		LOOP LOOP_PWD
		; 通过用户名和密码检测
		MOV AUTH, 1
		; 进入功能3
		CALL GET_MS
		MOV TIME, EAX
FUNC3:
		CMP AUTH, 1
		JNZ FUNC1
		LEA SI, OFFSET S1
		ADD SI, 10; 指向物品地址
		; BAG我放在了第一个物品处
		MOV DX, [SI + 14];进货数
		MOV BX, [SI + 16];卖的数量
		CMP DX, BX
		JLE FUNC1
		ADD WORD PTR [SI+ 16], 1
		MOV CX, G_CNT
NEXT_G:
		PUSH SI; SI里面放的就是当前物品地址
		CALL CALCUG_PRO
		MOV [SI + 18], AX
		ADD SI, G_SIZE
		LOOP NEXT_G
		; 检测M是否为0
		LEA SI, OFFSET S1
		ADD SI, 10; 指向物品地址
		; BAG我放在了第一个物品处
		DEC DX;进货数
		;MOV BX, [SI + 16];卖的数量
		CMP DX, BX
		JE FUNC4
		JMP FUNC3
		
FUNC4:
		; 时间计算一下
		CALL GET_MS
		SUB EAX, TIME
		; print参数压栈
		PUSH EAX
		; 显示运行时间
		CALL PRINT_NUM
		CALL CRLF
		; 原来的出栈
		MOV AX, [SI + 18]
		; 检测利润率范围
		CMP AL, 90
		JGE SHOWA
		CMP AL, 50
		JGE SHOWB
		CMP AL, 20
		JGE SHOWC
		CMP AL, 0
		JGE SHOWD
		JMP SHOWF
SHOWA:	
		MOV DL, 'A'
		JMP SHOW
SHOWB:
		MOV DL, 'B'
		JMP SHOW
SHOWC:
		MOV DL, 'C'
		JMP SHOW
SHOWD:
		MOV DL, 'D'
		JMP SHOW
SHOWF:	
		MOV DL, 'F'
SHOW:	
		MOV AH, 2
		INT 21H
		; 换行
		CALL CRLF
		JMP FUNC1
QUIT:
		;stop here
		MOV  AH, 4CH
		INT  21H

; 函数：获取时间戳，以ms为单位，
; 参数: 无
; 返回值：EAX:
GET_MS PROC
		PUSH EBX
		PUSH ECX
		PUSH EDX
		MOV AH, 2CH
		INT 21H
		XOR EAX, EAX
		XOR EBX, EBX
		; 获取小时
		MOV BL, CH
		ADD EAX, EBX
		;; 转为分钟
		IMUL EAX, 60
		; 获取分钟
		MOV BL, CL
		ADD EAX, EBX
		; 转为s
		IMUL EAX, 60
		; 获取10ms
		MOV BL, DH
		ADD EAX, EBX
		IMUL EAX, 100
		MOV BL, DL
		ADD EAX, EBX
		; 转为ms
		IMUL EAX, 10
		POP EDX
		POP ECX
		POP EBX
		RET
GET_MS ENDP
; 输出函数：输出参数中的字符串
; 参数：要输出的字符串的地址：字
; 返回值：无
OUTPUT PROC
		;local _ADD DW
		POP BP
		POP _ADD
		PUSH EAX
		PUSH EDX
		MOV DX, _ADD
		MOV AH, 9
		INT 21H
		POP EDX
		POP EAX
		PUSH BP
		RET
OUTPUT ENDP

; 输入函数：输入一个字符串到缓冲区
; 参数：要输入的缓冲区的地址：字
; 返回值：无
INPUT PROC
		POP BP
		POP _ADD
		PUSH EAX
		PUSH EBX
		MOV DX, _ADD
		MOV AH, 10
		INT 21H
		POP EBX
		POP EAX
		PUSH BP
		RET
INPUT ENDP

; 换行函数
; 参数：无
; 返回值：无
CRLF PROC
		PUSH EAX
		PUSH EDX
		; 获取换行字符串
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 9
		INT 21H
		POP EDX
		POP EAX
		RET
CRLF ENDP
; 函数：计算一个商品的所有利润率
; 参数：第一个商店里的物品的偏移地址
; 返回值：利润率AX
CALCUG_PRO PROC
		POP BP
		POP WORD PTR _ADD
		PUSH EBX
		PUSH ECX
		PUSH EDX
		PUSH SI
		MOV G_PRO, 0
		MOV SI, WORD PTR _ADD
		MOV CX, S_CNT
L1:
		PUSH WORD PTR G_PRO
		XOR EAX, EAX
		XOR EBX, EBX
		XOR EDX, EDX
		MOV AX, [SI + 10]
		MOV BX, [SI + 14]
		IMUL AX, BX
		; 80x86低位在前
		MOVSX EAX, AX; 拓展AX符号位
		MOV G_COST, EAX
		MOV AX, [SI + 12]
		MOV BX, [SI + 16]
		IMUL AX, BX
		MOVSX EAX, AX
		MOV G_PRO, EAX
		MOV EAX, G_PRO
		MOV EBX, G_COST
		SUB EAX, EBX
		IMUL EAX, 100
		CDQ
		IDIV EBX; 得出结果
		POP WORD PTR G_PRO
		ADD G_PRO, EAX
		ADD SI, S_SIZE
		LOOP L1
		; 恢复现场并返回
		MOV EAX, G_PRO; AX为低位
		POP SI
		POP EDX
		POP ECX
		POP EBX
		PUSH BP
		RET
CALCUG_PRO ENDP

; 输出函数：输出参数的十进制表示
; 参数：一个双字的数值
; 返回值：无
; 注意：
PRINT_NUM PROC
		POP BP
		POP DWORD PTR NUM
		PUSH EAX
		PUSH EDX
		PUSH ECX
		PUSH EBX
		MOV EBX, 10
		MOV EAX, NUM
		XOR ECX, ECX
		CDQ
		CMP EAX, 0
		JGE L2
		PUSH EAX
		PUSH EDX
		; 输出负号，正数不输出
		MOV DL, '-'
		MOV AH, 2
		INT 21H
		POP EDX
		POP EAX
		NEG EAX
		
L2:
		IDIV EBX
		ADD DL, '0'
		PUSH DX
		; 还原EDX的实际情况
		CDQ
		INC ECX
		CMP EAX, 0
		JG L2
		; 栈里一共ECX个数字可用
L3:
		POP DX
		MOV AH, 2
		INT 21H
		LOOP L3
		; 恢复环境
		POP EBX
		POP ECX
		POP EDX
		POP EAX
		PUSH BP
		RET
PRINT_NUM ENDP

; 输出菜单函数
; 参数：无
; 返回值：输入的菜单选项，存放在AL中
SHOW_MENU PROC
		PUSH BX
		PUSH CX
		PUSH DX
		PUSH DI
		MOV DI, 0
		
		

		RET
SHOW_MENU END

CODE ENDS
	END  START


