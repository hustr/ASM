
INCLUDE MACRO.LIB
EXTRN S1: BYTE, S2: BYTE, IDXES: WORD, SHIFTLINE: BYTE, PRINT_NUM:NEAR
EXTRN _ADD: WORD, G_PRO: DWORD, G_COST: DWORD, ADD1: WORD, ADD2: WORD
EXTRN G_SIZE:ABS, G_CNT:ABS, S_CNT:ABS, S_SIZE:ABS
PUBLIC CALCU_ALL, SORT_PROP, PRINT_ALLP, PRINT_ONE

.386
DATA1 SEGMENT USE16 PARA PUBLIC 'D1'
; 获取数字的字符串缓冲区
IN_NUM DB 20, ?, 20 DUP(0)
; 选项二的地址参数
ADD3	DW 0
ADD4	DW 0
MYBP	DW 0
; 输出提示
COST 	DB 'Buy cost: $'
PRICE	DB 'Sale price: $'
BUY_CNT DB 'Buy count: $'
; 排序函数中使用的地址数组
MAX		DW 0
RANK	DW 0
; 输出全部信息函数使用的提示信息
PRINT_SHOP1	DB 'In shop1: $'
PRINT_SHOP2 DB 'IN shop2: $'
PRINT_BUY	DB 'in price: $'
PRINT_SELL	DB 'sell price: $'
PRINT_BUY_CNT	DB 'buy count: $'
PRINT_SELL_CNT	DB 'sell count: $'
PRINT_PRO	DB 'profile: $'
PRINT_RANK	DB 'rank: $'
; print_one数据区
PRINT_ONE_BP DW 0
; print_num
NUM DD 0
; pint_name
NAME_ADD 	DW 0
NAME_BP	DW 0
DATA1 ENDS

STACK SEGMENT USE16 PARA STACK 'STACK'
	DB 200 DUP(0)
STACK ENDS
CODE	SEGMENT USE16 PARA  PUBLIC 'CODE'
		ASSUME  CS:CODE, SS:STACK, DS:DATA1
		
; 函数：计算一个商品的平均利润率
; 参数：第一个商店里的物品的偏移地址
; 返回值：利润率AX
CALCUG_PRO PROC
		POP BP
		POP WORD PTR _ADD
		PUSH EBX
		PUSH ECX
		PUSH EDX
		PUSH SI
		MOV DWORD PTR G_PRO, 0
		MOV SI, WORD PTR _ADD
		MOV CX, S_CNT
L1:
		PUSH DWORD PTR G_PRO
		;PUSH DWORD PTR G_COST
		XOR EAX, EAX
		XOR EBX, EBX
		XOR EDX, EDX
		MOV AX, [SI + 10]
		MOV BX, [SI + 14]
		IMUL BX
		; 80x86低位在前
		; MOVSX EAX, AX; 拓展AX符号位
		MOV WORD PTR G_COST, AX
		MOV WORD PTR G_COST[2], DX
		MOV AX, [SI + 12]
		MOV BX, [SI + 16]
		IMUL BX
		;MOVSX EAX, AX
		MOV WORD PTR G_PRO, AX
		MOV WORD PTR G_PRO[2], DX
		MOV EAX, G_PRO
		MOV EBX, G_COST
		SUB EAX, EBX
		IMUL EAX, 100
		CDQ
		IDIV EBX; 得出结果
		POP DWORD PTR G_PRO
		ADD G_PRO, EAX
		ADD SI, S_SIZE
		LOOP L1
		; 恢复现场并返回
		MOV EAX, G_PRO; AX为低位
		CDQ
		MOV EBX, S_CNT
		IDIV EBX
		POP SI
		POP EDX
		POP ECX
		POP EBX
		PUSH BP
		RET
CALCUG_PRO ENDP
; 获取所有商品平均利润率函数
; 参数：无
; 返回值：无
CALCU_ALL PROC
		PUSH AX
		PUSH DI
		MOV CX, G_CNT
		MOV DI, OFFSET S1[10]
CALCU_ALL_LOOP1:
		PUSH DI
		CALL CALCUG_PRO
		MOV [DI + 18], AX
		ADD DI, G_SIZE
		LOOP CALCU_ALL_LOOP1
		POP DI
		POP AX
		RET
CALCU_ALL ENDP

; 平均利润率排名函数
; 我选择使用选择排序
; 参数：第一个商品的位置
; 返回值：无
SORT_PROP	PROC
		PUSH EAX
		PUSH EBX
		PUSH ECX
		PUSH EDX
		PUSH DI
		PUSH SI
		MOV CX, G_CNT
		MOV BX, OFFSET IDXES
		MOV DI, OFFSET S1[10]
		; 获取所有的商品偏移地址
GET_IDX_LOOP:
		MOV [BX], DI
		ADD DI, G_SIZE
		; 每次后移两字节
		ADD BX, 2
		LOOP GET_IDX_LOOP
		; 获取地址完毕，对地址对应商品排序
		; 通过对利润率排名，将排名结果放到shop2对应的利润字段
		; RANK存储排名, 排名从1开始吧
		MOV RANK, 1
		; CX控制外层循环
		MOV CX, G_CNT
		; BX指向第一个物品偏移地址的地址
		MOV BX, OFFSET IDXES
SORT_OUT_LOOP:
		PUSH CX
		PUSH BX
		; AX存放已知最大利润率
		MOV AX, -1
		; DI获取商品地址
		MOV DI, [BX]
		; 获取此商品利润率
		MOV AX, [DI + 18]
		MOV MAX, BX
		; 需要从BX下一个物品处开始循环
		; CX现在的数值就是剩余的商品数量加1
SORT_IN_LOOP:
		DEC CX
		CMP CX, 0
		JE NOT_BIG
		ADD BX, 2
		MOV DI, [BX]
		MOV DX, [DI + 18]
		CMP DX, AX
		; 此商品比最大的利润值小到NOT_BIG
		JLE NOT_BIG
		; 否则此商品就是最大的，
		MOV AX, DX
		; 获取地址在数组中的地址
		MOV MAX, BX
NOT_BIG:
		CMP CX, 0
		JG SORT_IN_LOOP
		; 结束，交换
		POP BX
		; 将最大的与现在的下标所属元素交换
		MOV AX, [BX]
		MOV DI, MAX
		MOV DI, [DI]
		MOV [BX], DI
		MOV DI, MAX
		MOV [DI], AX
		MOV DI, [BX]
		MOV AX, RANK
		INC WORD PTR RANK
		ADD DI, S_SIZE
		MOV [DI + 18], AX
		ADD BX, 2
		POP CX
		LOOP SORT_OUT_LOOP
		POP SI
		POP DI
		POP EDX
		POP ECX
		POP EBX
		POP EAX
		RET
SORT_PROP ENDP
; 输出全部信息函数
; 参数：无
; 返回值：无
; 将SHOP1和SHOP2中的所有商品信息显示到屏幕上，包括平均利润率和排名（替代了商品原有的利润率字段）。
;具体的显示格式自行定义（可以分网店显示，也可以按照商品排名显示，等等，显示方式可以作为子程序的入口参数）。
PRINT_ALLP PROC
		PUSH EBX
		PUSH ECX
		PUSH DI
		; 商品数量
		MOV CX, G_CNT
		; BX指向shop1中商品
		; DI指向shop2中商品
		MOV BX, OFFSET S1[10]
		MOV DI, OFFSET S2[10]
		; 开始循环吧
PRINT_ALL_LOOP1:
		PUSH BX
		PUSH DI
		CALL PRINT_ONE
		ADD BX, G_SIZE
		ADD DI, G_SIZE
		LOOP PRINT_ALL_LOOP1
		POP DI
		POP ECX
		POP EBX
		RET
PRINT_ALLP ENDP

; 输出一个商品
; 参数：商品在两个商店中的偏移
; 返回值：无
PRINT_ONE PROC
		POP PRINT_ONE_BP
		POP ADD1
		POP ADD2
		PUSH EAX
		PUSH EBX
		PUSH DI
		MOV BX, ADD2
		MOV DI, ADD1
		PUSH BX
		CALL PRINT_NAME
		WRITE <OFFSET PRINT_SHOP1>
		WRITE <OFFSET PRINT_BUY>
		MOV AX, [BX + 10]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_SELL>
		MOV AX, [BX + 12]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_BUY_CNT>
		MOV AX, [BX + 14]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_SELL_CNT>
		MOV AX, [BX + 16]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		CRLF
		WRITE <OFFSET PRINT_SHOP2>
		WRITE <OFFSET PRINT_BUY>
		MOV AX, [DI + 10]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_SELL>
		MOV AX, [DI + 12]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_BUY_CNT>
		MOV AX, [DI + 14]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		WRITE <OFFSET PRINT_SELL_CNT>
		MOV AX, [DI + 16]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		CRLF
		; 输出利润率
		WRITE <OFFSET PRINT_PRO>
		MOV AX, [BX + 18]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		COMMA
		; 输出排名
		WRITE <OFFSET PRINT_RANK>
		MOV AX, [DI + 18]
		MOVSX EAX, AX
		PUSH EAX
		CALL PRINT_NUM
		CRLF
		POP DI
		POP EBX
		POP EAX
		PUSH PRINT_ONE_BP
		RET
PRINT_ONE ENDP

; 用来显示程序中以0结尾的字符串，可以用来显示商品名和商店名
; 参数：字单位的地址
; 返回值：无
PRINT_NAME PROC
		POP NAME_BP
		POP NAME_ADD
		PUSH AX
		PUSH BX
		PUSH DX
		MOV BX, NAME_ADD
NAME_LOOP:
		MOV DL, [BX]
		MOV AH, 2
		INT 21H
		INC BX
		CMP BYTE PTR [BX], 0
		JNZ NAME_LOOP
		POP DX
		POP BX
		POP AX
		PUSH NAME_BP
		RET
PRINT_NAME ENDP

CODE ENDS
	END