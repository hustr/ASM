.386
STACK	SEGMENT USE16 STACK
        DB 400 DUP(0)
STACK 	ENDS
DATA	SEGMENT USE16
NOTICE_NAME	DB 'Please enter user name: $'
NOTICE_PWD DB 'Please enter user password: $'
NOTICE_GOODS DB 'Please enter goods name: $'
IN_GOODS DB 20, ?, 20 DUP(0)
BNAME  	DD 3964361990; 用户名哈希值
BPASS	DD 3970332365; 密码的哈希值
IN_NAME DB 20, ?, 20 DUP(0)
IN_PWD	DB 20, ?, 20 DUP(0)
G_CNT	= 4
mix     = 'p'
S1		DB 'SHOP1', 5 DUP(0)
BAG1	DB 'BAG', 7 DUP(0)
        DW 12, 30, 1000, 5, ? ; 利润率未计算
G_SIZE  = $ - BAG1
GA1		DB 'PEN', 7 DUP(0)
        DW 35 XOR mix, 56 XOR mix, 70 XOR mix, 25 XOR mix, ? ; 利润率未计算
GA2		DB 'BOOK', 6 DUP(0)
        DW 12 XOR mix, 30 XOR mix, 25 XOR mix, 5 XOR mix, ? ; 利润率未计算
GAN		DB 'TempValue',0
        DW 15 XOR mix, 20 XOR mix, 30 XOR mix, 2 XOR mix, ?; 其他商品暂时未知
S_SIZE	= $ - S1
S2 		DB 'SHOP2', 5 DUP(0) ;网店名称，用0结束
BAG2	DB 'BAG', 7 DUP(0)
        DW 12 XOR mix, 30 XOR mix, 2000 XOR mix, 2 XOR mix, ? ; 利润率未计算
GB1   	DB 'PEN', 7 DUP(0) ;商品名称
        DW 35 XOR mix, 50 XOR mix, 30 XOR mix, 24 XOR mix, ?  ;利润率还未计算
GB2   	DB 'BOOK', 6 DUP(0) ; 商品名称
        DW 12 XOR mix, 28 XOR mix, 20 XOR mix, 15 XOR mix, ? ;利润率还未计算
GBN		DB 'TempValue',0
        DW 15 XOR mix, 20 XOR mix, 30 XOR mix, 2 XOR mix, ?
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
query	DB "1. Query goods.$", 24 DUP(0); len 13
modify	DB "2. Modify goods.$", 23 DUP(0); len 14
calcu_pro	DB "3. Calcu average profile rate.$", 9 DUP(0);len 28
sort_pro	DB "4. Sort the profile rate.$", 14 DUP(0); len 23
print_all	DB "5. Print all goods's information.$", 6 DUP(0); len  31
exit	DB "6. Exit the program.$", 19 DUP(0); len 18
_ADD	DW 0
NUM 	DD 0

; 菜单函数中输入选项使用
STRLEN	DW 0
; 输入商店名
NOTICE_SHOP	DB 'Please enter shop name: $'
IN_SHOP	DB 10, ?, 10 DUP(0)
; 地址存放，字符串比较使用
ADD1	DW 0
ADD2	DW 0
; 选项一的shop1、shop2
SHOP1_STR DB 'SHOP1$'
SHOP2_STR DB 'SHOP2$'
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
IDXES	DW G_CNT DUP(0)
MAX		DW 0
RANK	DW 0
; 输出全部信息函数使用的数据段
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
NAME_BP DW 0
NAME_ADD DW 0
; 记录输入密码次数
ERR_TIME DB 0
DATA	ENDS

; 输出字符串的宏
; 参数：字符串偏移地址
; 返回值：无
WRITE 	MACRO A
        PUSH AX
        PUSH DX
        MOV DX, A
        MOV AH, 9
        INT 21H
        POP DX
        POP AX
        ENDM
; 读入字符串宏
; 参数：缓冲区偏移地址
; 返回值：无
READ	MACRO A
        PUSH DX
        PUSH AX
        MOV DX, A
        MOV AH, 10
        INT 21H
        POP AX
        POP DX
        ENDM
; 换行宏
; 参数：无
; 返回值：无
CRLF 	MACRO
        WRITE <OFFSET SHIFTLINE>
        ENDM
; 输出逗号
; 参数：无
; 返回值：无
COMMA 	MACRO
        PUSH DX
        PUSH AX
        MOV DL, ','
        MOV AH, 2
        INT 21H
        POP AX
        POP DX
        ENDM
CODE	SEGMENT USE16
        ASSUME  CS:CODE, SS:STACK, DS:DATA, ES:DATA
START:
        MOV AX, DATA
        MOV DS, AX
        ; code after this
FUNC1:  ; 功能1开始
        WRITE <OFFSET NOTICE_NAME>
        READ <OFFSET IN_NAME>
        CRLF
        WRITE <OFFSET NOTICE_PWD>
        READ <OFFSET IN_PWD>
        CRLF
FUNC2:  ;功能2开始
        ; 用户名输入长度为0？
        MOV AUTH, 0
        ; 长度为1，检测是否是q
        CMP IN_NAME[1], 1
        ; 不是1跳check_name
        JG CHECK_NAME
        CMP IN_NAME[2], 'q'
        ; 输入为q，退出
        JZ QUIT
CHECK_NAME:
        PUSH OFFSET IN_NAME[2]
        CALL GetHash
        CMP EAX, BNAME
        JE CK_PASSWD
        INC ERR_TIME
        CMP ERR_TIME, 3
        JE FUNC3
        JMP FUNC1
CK_PASSWD:
        PUSH OFFSET IN_PWD[2]
        CALL GetHash
        MOV AUTH, 1
        CMP EAX, BPASS
        JZ FUNC3
        MOV AUTH, 0
        INC ERR_TIME
        CMP ERR_TIME, 3
        JE FUNC3
        JMP FUNC1
        ; 进入功能3
FUNC3:
        ; 显示菜单
        CALL SHOW_MENU
        ; 返回值是AL中的选项
        ; 合法就向下找对应的选项
        CMP AL, 1
        JE OPT_1
        CMP AL, 2
        JE OPT_2
        CMP AL, 3
        JE OPT_3
        CMP AL, 4
        JE OPT_4
        CMP AL, 5
        JE OPT_5
        CMP AL, 6
        JE OPT_6
        JMP FUNC3
OPT_1:
        CALL QUERYP
        JMP FUNC3
OPT_2:
        WRITE <OFFSET NOTICE_SHOP>
        READ <OFFSET IN_SHOP>
        CRLF
        PUSH OFFSET IN_SHOP[2]
        WRITE <OFFSET NOTICE_GOODS>
        READ <OFFSET IN_GOODS>
        CRLF
        PUSH OFFSET IN_GOODS[2]
        CALL MODIFYP
        JMP FUNC3
OPT_3:
        CALL CALCU_ALL
        JMP FUNC3
OPT_4:
        CALL SORT_PROP
        JMP FUNC3
OPT_5:
        CALL PRINT_ALLP
        JMP FUNC3
OPT_6:
        JMP QUIT
QUIT:
        ;stop here
        MOV  AH, 4CH
        INT  21H
; GetHash获取传入参数的哈希值
; 参数：字符串偏移地址
; 返回值：EAX字符串哈希值
GetHash PROC
        PUSH BP
        MOV BP, SP
        PUSH EBX
        PUSH ECX
        PUSH EDX
        MOV BX, [BP + 4]
        ADD BX, 5
        MOV ECX, 6
        MOV EAX, 0
LOOP_HASH:
        PUSH EAX
        XOR EDX, EDX
        MOV DL, [BX]
        ADD EDX, 9421
        MOV EAX, EDX
        MUL EDX
        MUL ECX
        MUL ECX
        MOV EDX, EAX
        POP EAX
        ADD EAX, EDX
        DEC BX
        LOOP LOOP_HASH
        POP EDX
        POP ECX
        POP EBX
        POP BP
        RET 2; 地址占2个字节
GetHash ENDP
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


; 输出函数：输出参数的十进制表示
; 参数：一个字的数值
; 返回值：无
; 注意：
PRINT_NUM PROC
        PUSH BP
        MOV BP, SP
        PUSH EAX
        PUSH EDX
        PUSH ECX
        PUSH EBX
        MOV AX, [BP + 4]
        XOR AL, IN_PWD[2]
        MOVSX EAX, AX
        MOV EBX, 10
        XOR CX, CX
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
        CDQ
        IDIV EBX
        ADD DL, '0'
        PUSH DX
        ; 还原EDX的实际情况
        INC CX
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
        POP BP
        RET 2
PRINT_NUM ENDP

; 输出菜单函数
; 参数：无
; 返回值：输入的菜单选项，存放在AL中
SHOW_MENU PROC
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        WRITE <OFFSET query>
        CRLF
        CMP AUTH, 1
        JNZ STR6
        MOV DI, OFFSET modify
        MOV CX, 4
SHOW_MENU_LOOP1:
        WRITE <DI>
        CRLF
        ADD DI, 40
        LOOP SHOW_MENU_LOOP1
STR6:
        WRITE <OFFSET exit>
        CRLF
        ; 输入选项部分
        CALL GET_NUM
        CRLF
        ;恢复环境
        POP DI
        POP DX
        POP CX
        POP BX
        RET
SHOW_MENU ENDP
; 字符串转数字函数
; 参数：字符串地址一个字，字符串长度一个字
; 返回值：转换为的数字，EAX中存放，溢出不管,错误返回-1
FSTRT2 PROC
        POP BP
        ; 弹出参数
        POP WORD PTR STRLEN
        POP WORD PTR _ADD
        ; 保存寄存器
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH DI
        ; 置零
        XOR EAX, EAX
        XOR EBX, EBX
        XOR ECX, ECX
        XOR EDX, EDX
        ; 开始计算
        ; 首先判断正负号
        MOV DI, _ADD
        MOV CX, WORD PTR STRLEN
        CMP BYTE PTR [DI], '-'
        JNZ FSTRT2_LOOP1
        ; 正负号是否占据字符位置
        INC DI
        DEC CX
FSTRT2_LOOP1:
        MOV BL, [DI]
        SUB BL, '0'
        CMP BL, 0
        JL 	FSTRT2_ERR
        CMP BL, 9
        JG 	FSTRT2_ERR
        ; 拓展BX
        MOVZX EBX, BL
        IMUL EAX, 10
        CDQ
        ADD EAX, EBX
        INC DI
        LOOP FSTRT2_LOOP1
        SUB DI, STRLEN
        ; 判断正负，负责变号
        CMP BYTE PTR [DI], '-'
        JNZ FSTRT2_EXIT
        NEG EAX
        JMP FSTRT2_EXIT
FSTRT2_ERR:
        MOV EAX, -1
FSTRT2_EXIT:
        POP DI
        POP EDX
        POP ECX
        POP EBX
        PUSH BP
        RET
FSTRT2 ENDP

; 查询商品函数
; 参数：无（参数在此函数中输入）
; 返回值：无（直接在此函数中输出）
QUERYP	PROC
        ; 需要使用的寄存器先压栈保存环境
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH DI
        ; 输出提示
        WRITE <OFFSET NOTICE_GOODS>
        ; 输入商品名
        READ <OFFSET IN_GOODS>
        CRLF
        ; 开始在商店一寻找商品
        MOV CX, G_CNT
        MOV DI, OFFSET S1[10]
        XOR EBX, EBX
        MOV BL, IN_GOODS[1]
        ; EBX移动到输入名下一个位置
        ADD EBX, OFFSET IN_GOODS[2]
        ; 给它加个尾巴
        MOV BYTE PTR [EBX], '$'
QUERY_LOOP1:
        PUSH DI
        PUSH OFFSET IN_GOODS[2]
        CALL CMP_STR
        ; 查看输入是否与已有商品名相同
        CMP AL, 0
        JZ END_QUERY_LOOP1
        ; 转移到下一个物品
        ADD DI, G_SIZE
        LOOP QUERY_LOOP1
        JMP NO_GOODS
END_QUERY_LOOP1:
        ; 存在商品就好办了
        ; DI此时存放的是商品在第一个商店中的位置
        ; 输出商品的信息“SHOP1，商品名称，销售价，进货总数，
        ;已售数量”顺序显示该商品的信息，同时还要将“SHOP2”中该商品的信息也显示出来。
        WRITE <OFFSET SHOP1_STR>
        COMMA
        WRITE <OFFSET IN_GOODS[2]>
        COMMA
        ; 得出销售价
        PUSH WORD PTR [DI + 12]
        CALL PRINT_NUM
        COMMA
        ; 进货总数
        PUSH WORD PTR [DI + 14]
        CALL PRINT_NUM
        COMMA
        ; 已售总量
        PUSH WORD PTR [DI + 16]
        CALL PRINT_NUM
        CRLF
        ; 显示商店2中方物品信息
        ADD DI, S_SIZE
        WRITE <OFFSET SHOP2_STR>
        COMMA
        WRITE <OFFSET IN_GOODS[2]>
        COMMA
        ; 得出销售价
        PUSH WORD PTR [DI + 12]
        CALL PRINT_NUM
        COMMA
        ; 进货总数
        PUSH WORD PTR [DI + 14]
        CALL PRINT_NUM
        COMMA
        ; 已售总量
        PUSH WORD PTR [DI + 16]
        CALL PRINT_NUM
        CRLF
; 没有此商品
NO_GOODS:
; 函数结束
        POP EAX
        POP EBX
        POP ECX
        POP EDX
        POP DI
        RET
QUERYP 	ENDP

; 修改商店物品的信息
; 参数：商店名和物品名字符串所在地址
; 返回值，无
MODIFYP 	PROC
        ; 首先获取参数
        POP MYBP
        ; ADD3是第一个参数，是商品名吧
        POP WORD PTR ADD3
        POP WORD PTR ADD4
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH DI
        ; 首先比较商店
        MOV DI, OFFSET S1
        PUSH DI
        PUSH ADD4
        CALL CMP_STR
        ; 是这个shop进入下环节
        CMP AL, 0
        JZ FIND_GOODS
        MOV DI, OFFSET S2
        PUSH DI
        PUSH ADD4
        CALL CMP_STR
        CMP AL, 0
        ; 进入下环节
        JZ FIND_GOODS
        ; 没进入下环节说明没有此商店
        JMP NO_SHOP
; 寻找商品
FIND_GOODS:
        ; 哪个商店？在DI中，不需要关心
        ; 移动到第一个物品处
        ADD DI, 10
        ; 开始寻找物品名
        ; 将商品数量输入到CX中
        MOV CX, G_CNT
LOOP_GOODS:
        PUSH DI
        PUSH WORD PTR ADD3
        ; 比较字符串是否相同
        CALL CMP_STR
        CMP AL, 0
        JZ FOUND_GOOD
        ; 移动到下一个物品处
        ADD DI, G_SIZE
        LOOP LOOP_GOODS
        JMP NO_GOODS_1
FOUND_GOOD:
; 改变进货价
CHG_COST:
        WRITE <OFFSET COST>
        PUSH WORD PTR [DI + 10]
        CALL PRINT_NUM
        ; 逗号分隔开 
        COMMA
        ; 尝试获取数字
        READ <OFFSET IN_NUM>
        CRLF
        CMP BYTE PTR IN_NUM[1], 0
        JE  CHG_PRICE
        PUSH OFFSET IN_NUM[2]
        MOV AL, IN_NUM[1]
        MOV AH, 0
        PUSH AX
        CALL FSTRT2
        CMP AX, -1
        JE CHG_COST
        ; 将得到的数字的低两字节放入位置
        XOR AL, IN_PWD[2]
        MOV [DI + 10], AX
CHG_PRICE:
;同等逻辑
        WRITE <OFFSET PRICE>
        PUSH WORD PTR [DI + 12]
        CALL PRINT_NUM
        COMMA
        ; 尝试获取数字
        READ <OFFSET IN_NUM>
        CRLF
        CMP IN_NUM[1], 0
        JE  CHG_CNT
        PUSH OFFSET IN_NUM[2]
        MOV AL, IN_NUM[1]
        MOV AH, 0
        PUSH AX
        CALL FSTRT2
        CMP AX, -1
        JE CHG_PRICE
        XOR AL, IN_PWD[2]
        MOV [DI + 12], AX
;; 修改进货数量
CHG_CNT:
        WRITE <OFFSET BUY_CNT>
        PUSH WORD PTR [DI + 14]
        CALL PRINT_NUM
        COMMA
        ; 尝试获取数字
        READ <OFFSET IN_NUM>
        CRLF
        CMP BYTE PTR IN_NUM[1], 0
        JE  NO_GOODS_1
        PUSH OFFSET IN_NUM[2]
        MOV AL, IN_NUM[1]
        MOV AH, 0
        PUSH AX
        CALL FSTRT2
        CMP AX, -1
        JE CHG_CNT
        XOR AL, IN_PWD[2]
        MOV [DI + 14], AX
NO_GOODS_1:
NO_SHOP:
    ;  结束
        POP DI
        POP ECX
        POP EBX
        POP EAX
        PUSH MYBP
        RET
MODIFYP ENDP
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
        XOR EAX, EAX
        XOR EBX, EBX
        XOR EDX, EDX
        MOV AX, [SI + 10]
        MOV BX, [SI + 14]
        XOR AL, IN_PWD[2]
        XOR BL, IN_PWD[2]
        IMUL AX, BX
        ; 80x86低位在前
        MOVSX EAX, AX; 拓展AX符号位
        MOV G_COST, EAX
        MOV AX, [SI + 12]
        MOV BX, [SI + 16]
        XOR AL, IN_PWD[2]
        XOR BL, IN_PWD[2]
        IMUL AX, BX
        MOVSX EAX, AX
        MOV G_PRO, EAX
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
; 参数：无
; 返回值：无
SORT_PROP	PROC
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH DI
        PUSH SI
        CALL CALCU_ALL
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
        ; 输出好办啊
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
        CRLF
        WRITE <OFFSET PRINT_SHOP1>
        WRITE <OFFSET PRINT_BUY>
        PUSH WORD PTR [BX + 10]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_SELL>
        PUSH WORD PTR [BX + 12]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_BUY_CNT>
        PUSH WORD PTR [BX + 14]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_SELL_CNT>
        PUSH WORD PTR [BX + 16]
        CALL PRINT_NUM
        CRLF
        WRITE <OFFSET PRINT_SHOP2>
        WRITE <OFFSET PRINT_BUY>
        PUSH WORD PTR [DI + 10]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_SELL>
        PUSH WORD PTR [DI + 12]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_BUY_CNT>
        PUSH WORD PTR [DI + 14]
        CALL PRINT_NUM
        COMMA
        WRITE <OFFSET PRINT_SELL_CNT>
        PUSH WORD PTR [DI + 16]
        CALL PRINT_NUM
        CRLF
        ; 输出利润率
        WRITE <OFFSET PRINT_PRO>
        MOV AX, WORD PTR [BX + 18]
        XOR AL, IN_PWD[2]
        PUSH AX
        CALL PRINT_NUM
        COMMA
        ; 输出排名
        WRITE <OFFSET PRINT_RANK>
        MOV AX, WORD PTR [DI + 18]
        XOR AL, IN_PWD[2]
        PUSH AX
        CALL PRINT_NUM
        CRLF
        POP DI
        POP EBX
        POP EAX
        PUSH PRINT_ONE_BP
        RET
PRINT_ONE ENDP

; 比较两个字符串
; 参数：两个字符串的偏移地址
; 返回值AL: 1:不想等，0：相等
; 以第一个字符串结尾为准，调用时注意
CMP_STR PROC
        POP BP
        POP WORD PTR ADD1
        POP WORD PTR ADD2
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH DI
        XOR EBX, EBX
        XOR EDX, EDX
        MOV BX, ADD2
        MOV DX, ADD1
        MOV AL, 1
CMP_STR_LOOP1:
        MOV CH, [EBX]
        MOV CL, [EDX]
        CMP CH, CL
        JNZ END_CMP_STR
        INC EBX
        INC EDX
        CMP BYTE PTR [EBX], 0
        JNZ CMP_STR_LOOP1
        MOV AL, 0
END_CMP_STR:
        POP DI
        POP EDX
        POP ECX
        POP EBX
        PUSH BP
        RET
CMP_STR ENDP

; 获取一个数字
; 参数无
; 返回值：输入的数字EAX，数字过大将会被截断
; 注意：请求失败返回-1，所以返回-1有可能是输入的-1也肯能是请求失败
GET_NUM PROC
        READ <OFFSET IN_NUM>
        PUSH OFFSET IN_NUM[2]
        MOV AH, 0
        MOV AL, IN_NUM[1]
        PUSH AX
        ; 解析交给函数去做
        CALL FSTRT2
        RET
GET_NUM ENDP

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
    END  START

