.386
STACK	SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK 	ENDS
DATA	SEGMENT USE16
NOTICE_NAME	DB 'Please enter user name: $', 5 DUP(0)
NOTICE_PWD DB 'Please enter user password: $', 2 DUP(0)
NOTICE_GOODS DB 'Please enter goods name: $', 3 DUP(0)
BNAME  	DB 'yaning', 4 DUP(0); 用户名
BPASS	DB 'passwd', 4 DUP(0); 密码
IN_NAME DB 20, ?, 20 DUP(0)
IN_PWD	DB 20, ?, 20 DUP(0)
IN_GOODS DB 20, ?, 20 DUP(0)
G_CNT	= 30
S1		DB 'SHOP1', 5 DUP(0)
GA1		DB 'PEN', 7 DUP(0)
		DW 35, 56, 70, 25, ? ; 利润率未计算
GA2		DB 'BOOK', 6 DUP(0)
		DW 12, 30, 25, 5, ? ; 利润率未计算
GAN		DB G_CNT - 2 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, 2, 0, ?, ?); 其他商品暂时未知
S_SIZE	= $ - S1
S2 		DB 'SHOP2', 5 DUP(0) ;网店名称，用0结束
GB1   	DB 'BOOK', 6 DUP(0) ; 商品名称
		DW 12, 28, 20,15, ? ;利润率还未计算
G_SIZE  = $ - GB1
GB2   	DB 'PEN', 7 DUP(0) ;商品名称
		DW 35, 50, 30, 24, ?  ;利润率还未计算
GBN		DB G_CNT - 2 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, 2, 0, ?, ?)
AUTH	DB 0; 标志是否通过验证
GG_INDEX DD 2 DUP(0); 一共两家店,存放查询的物品的地址在内存中
G_INDEX	DD 0
SHIFTLINE DB 13, 10, '$'
S_CNT	= 2
S_TEMP_CNT DB 2
G_TEMP_CNT DB 0
SG_INDEX DD 0
S_INDEX DD 0
G_COST  DD 0
G_PRO   DD 0
AVE_PRO DD 0
DATA	ENDS

CODE	SEGMENT USE16
		ASSUME  CS:CODE, SS:STACK, DS:DATA, ES:DATA
START:
		MOV AX, DATA
		MOV DS, AX
		; code after this
FUNC1:  ; 功能1开始
		LEA DX, OFFSET NOTICE_NAME; 提示输入用户名
		MOV AH, 9
		INT 21H	
		
		LEA DX, OFFSET IN_NAME ; 输入用户名
		MOV AH, 10
		INT 21H
		; 换行
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 9
		INT 21H
		
		LEA DX, OFFSET NOTICE_PWD;提示输入密码
		MOV AH, 9
		INT 21H
		LEA DX, OFFSET IN_PWD;输入密码
		MOV AH, 10
		INT 21H
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 9
		INT 21H
		;LEA DX, OFFSET NEWLINE
		;MOV AH, 9
		;INT 21H
FUNC2:  ;功能2开始
		; 用户名输入长度为0？
		CMP IN_NAME[1], 0
		; 调到功能3
		JZ FUNC3
		; 长度为1，检测是否是q
		CMP IN_NAME[1], 1
		; 不是1跳check_name
		JNZ CHECK_NAME
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
		DEC CX
		JNZ LOOP_NAME
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
		DEC CX
		JNZ LOOP_PWD
		; 通过用户名和密码检测
		MOV AUTH, 1
		; 进入功能3
FUNC3:	
INPUT_GOODS:
		LEA DX, OFFSET NOTICE_GOODS; 提示输入商品名
		MOV AH, 9
		INT 21H
		LEA DX, OFFSET IN_GOODS; 输入商品名
		MOV AH, 10
		INT 21H
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 09
		INT 21H
		; 只有回车跳转功能1
		CMP IN_GOODS[1], 0
		JZ FUNC1
		; MOV AH, 0
		; 检测网店1是否有此商品
		LEA EBX, OFFSET S1
		ADD EBX, 10; 跳到商品名处
		LEA EDX, OFFSET IN_GOODS + 2
		MOV G_INDEX, EBX
		MOV CL, 0
S1_CK:	; 检测物品是否存在第一个商店
		MOV AL, [EBX]
		MOV AH, [EDX]
		CMP AL, AH
		JNZ NEXT_SG
		INC EBX
		INC EDX
		MOV AL, [EBX]
		CMP AL, 0; 检测商品名是否走到结尾
		JNZ S1_CK
		; 走到这里说明网店1有该商品
		; 判断授权
		CMP AUTH, 1
		JZ CALCU_PR
		; 未授权, 输出商品名跳FUNC1
		LEA EBX, OFFSET IN_GOODS
		XOR EAX, EAX
		MOV AL, [EBX + 1]
		ADD EBX, EAX
		ADD EBX, 2
		MOV BYTE PTR [EBX], '$'
		LEA DX, OFFSET IN_GOODS + 2
		MOV AH, 9
		INT 21H
		; 换行
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 09
		INT 21H
		JMP FUNC1
NEXT_SG:
		MOV EBX, G_INDEX
		ADD EBX, G_SIZE
		INC CL
		CMP CL, G_CNT
		JZ INPUT_GOODS
		MOV G_INDEX, EBX
		JMP S1_CK
CALCU_PR:
		; 计算利润率,结果乘以100保证整数显示
		LEA EBX, OFFSET S1
		MOV S_INDEX, EBX
		; 已检测商店个数
		MOV S_TEMP_CNT, 0
LOOP_S:
		LEA EBX, OFFSET S_INDEX
		ADD EBX, 10
		MOV G_INDEX, EBX
LOOP_G:	
		; 首先找到商品位置
		; EBX记录商品位置
		MOV EBX, G_INDEX
		; 判断商品名是否为所求
CHG_S:	; 检测循环
		LEA EDX, OFFSET IN_GOODS + 2
		MOV AL, [EBX]
		MOV AH, [EDX]
		CMP AL, AH; 不是这件商品
		JNZ NEXT_G
		; 检测是否到头
		CMP AL, 0; 
		JNZ CHG_S;没到头继续
		; 到头了, 计算利润率
		MOV ECX, G_INDEX
		MOV AX, [ECX + 10]
		MOV BX, [ECX + 14]
		IMUL AX, BX
		; 80x86低位在前
		LEA ECX, OFFSET G_COST
		MOV [ECX], AX
		MOV [ECX + 2], DX
		MOV ECX, G_INDEX
		MOV AX, [ECX + 12]
		MOV BX, [ECX + 16]
		IMUL AX, BX
		LEA ECX, OFFSET G_PRO
		MOV [ECX], AX
		MOV [ECX + 2], DX
		MOV EAX, G_PRO
		MOV EBX, G_COST
		; 我怎么知道结果和0的大小？
		SUB EAX, EBX
		IMUL EAX, 100
		; 由于结果8个字节，一个寄存器放不下,抛弃高位EDX
		MOV EBX, G_INDEX
		MOV [EBX + 18], AX
		LEA EAX, OFFSET GG_INDEX
		XOR ECX, ECX
		MOV CL, S_TEMP_CNT
		ADD EAX, ECX
		MOV [EAX], EBX
		; 利润率计算完成
NEXT_G:
		ADD G_INDEX, G_SIZE
		INC G_TEMP_CNT
		MOV CL, G_TEMP_CNT
		CMP CL, G_CNT
		; 未完成商品继续LOOP_G
		JNZ LOOP_G
NEXT_S:
		INC S_TEMP_CNT
		ADD S_INDEX, S_SIZE
		MOV CL, S_TEMP_CNT
		CMP CL, S_CNT
		; 计算完毕去计算平均数目
		JNZ LOOP_S
AVE:	; 计算平均利润
		MOV CL, 0
		LEA EDX, OFFSET GG_INDEX
		MOV EBX, [EDX]
		XOR AX, AX
NEXT_IDX:
		ADD AX, [EBX + 18]
		ADD EDX, 4
		MOV EBX, [EDX]
		INC CL
		CMP CL, S_CNT
		JNZ NEXT_IDX
		IDIV CL
		; 计算后AL内存放结果的商，AH存放余数
FUNC4:	
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
		LEA DX, OFFSET SHIFTLINE
		MOV AH, 09
		INT 21H
		JMP FUNC1
QUIT:
		;stop here
		MOV  AH, 4CH
		INT  21H	
CODE 	ENDS
		END  START
