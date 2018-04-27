.386
.model flat, c
.stack 400
.data
; 声明为共享数据
public AUTH, S1

G_CNT   = 4
S1      DB 'SHOP1', 5 DUP(0)
BAG1    DB 'BAG', 7 DUP(0)
        DW 12, 30, 1000, 5, ? ; 利润率未计算
G_SIZE  = $ - BAG1
GA1     DB 'PEN', 7 DUP(0)
        DW 35, 56, 70, 25, ? ; 利润率未计算
GA2     DB 'BOOK', 6 DUP(0)
        DW 12, 30, 25, 5, ? ; 利润率未计算
GAN     DB G_CNT - 3 DUP('TempValue', 0, 15, 0, 20, 0, 30, 0, 2, 0, ?, ?); 其他商品暂时未知
S_SIZE  = $ - S1
S2      DB 'SHOP2', 5 DUP(0) ;网店名称，用0结束
BAG2    DB 'BAG', 7 DUP(0)
        DW 12, 30, 2000, 2, ? ; 利润率未计算
GB1     DB 'PEN', 7 DUP(0) ;商品名称
        DW 35, 50, 30, 24, ?  ;利润率还未计算
GB2     DB 'BOOK', 6 DUP(0) ; 商品名称
        DW 12, 28, 20,15, ? ;利润率还未计算
GBN     DB G_CNT - 3 DUP('TempValue', 0, 15, 0, 20, 0, 30, 0, 2, 0, ?, ?)
AUTH    DB 0; 标志是否通过验证
GG_INDEX DD 2 DUP(0); 一共两家店,存放查询的物品的地址在内存中
G_INDEX DD 0
SHIFTLINE DB 13, 10, 0
S_CNT   = 2
S_TEMP_CNT DB 0
G_TEMP_CNT DB 0

SG_INDEX DD 0
S_INDEX DD 0
G_COST  DD 0
G_PRO   DD 0

TIME    DD 0
; 菜单字符串
query   DB "1. Query goods.", 0, 24 DUP(0); len 13
modify  DB "2. Modify goods.", 0, 23 DUP(0); len 14
calcu_pro   DB "3. Calcu average profile rate.", 0, 9 DUP(0);len 28
sort_pro    DB "4. Sort the profile rate.", 0, 14 DUP(0); len 23
print_all   DB "5. Print all goods's information.", 0, 6 DUP(0); len  31
exit    DB "6. Exit the program.", 0, 19 DUP(0); len 18
; 选项一的shop1、shop2
SHOP1_STR DB 'SHOP1', 0
SHOP2_STR DB 'SHOP2', 0
; 获取数字的字符串缓冲区
IN_NUM DB 20, ?, 20 DUP(0)
MYBP    DD 0
; 输出提示
COST    DB 'Buy cost: ', 0
PRICE   DB 'Sale price: ', 0
BUY_CNT DB 'Buy count: ', 0
; 排序函数中使用的地址数组
IDXES   DW G_CNT DUP(0)
MAX     DW 0
RANK    DW 0

_comma DB ",", 0
.code
; 函数共享
public SHOW_MENU, QUERYP, MODIFYP, SORT_PROP, CALCU_ALL

; C中的函数
; 80x86里的中断全部GG了，只能使用c里的printf和scanf了
PRINT_NUM proto c, num : DWORD
prints proto c, s : dword
scans proto c, s : dword

; 输出字符串
; 参数：字符串地址
; 返回值：无
WRITE   proc A:dword
		push eax
        invoke prints, A
        pop eax
		ret
WRITE   endp

; 读入字符串
; 参数：缓冲区地址
; 返回值：无
READ    proc A:dword
		push eax
		push ebx
		mov ebx, A
		add ebx, 2
        invoke scans, ebx
		mov [ebx - 1], al
		pop ebx
		pop eax
        ret
READ    endp

; 换行函数
; 参数：无
; 返回值：无
CRLF    proc
        invoke WRITE, offset SHIFTLINE
        ret
CRLF endp

; 输出逗号
; 参数：无
; 返回值：无
COMMA   proc
        invoke write, offset _comma
        ret
COMMA   endp

; 比较两个字符串
; 参数：两个字符串的偏移地址
; 返回值AL: 1:不想等，0：相等
; 以第一个字符串结尾为准，调用时注意
CMP_STR PROC ADD1:DWORD, ADD2:DWORD
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH EDI
        XOR EBX, EBX
        XOR EDX, EDX
        MOV EBX, ADD1
        MOV EDX, ADD2
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
        POP EDI
        POP EDX
        POP ECX
        POP EBX
        RET
CMP_STR ENDP

; 字符串转数字函数
; 参数：字符串地址两个字，字符串长度一个字
; 返回值：转换为的数字，EAX中存放，溢出不管,错误返回-1
FSTRT2 PROC _ADD:DWORD, STRLEN:WORD
        ; 弹出参数
        ; 保存寄存器
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH EDI
        ; 置零
        XOR EAX, EAX
        XOR EBX, EBX
        XOR ECX, ECX
        XOR EDX, EDX
        ; 开始计算
        ; 首先判断正负号
        MOV EDI, _ADD
        MOV CX, WORD PTR STRLEN
        CMP BYTE PTR [EDI], '-'
        JNZ FSTRT2_LOOP1
        ; 正负号是否占据字符位置
        INC EDI
        DEC CX
FSTRT2_LOOP1:
        MOV BL, [EDI]
        SUB BL, '0'
        CMP BL, 0
        JL  FSTRT2_ERR
        CMP BL, 9
        JG  FSTRT2_ERR
        ; 拓展BX
        MOVZX EBX, BL
        IMUL EAX, 10
        CDQ
        ADD EAX, EBX
        INC EDI
        LOOP FSTRT2_LOOP1
        SUB DI, STRLEN
        ; 判断正负，负责变号
        CMP BYTE PTR [EDI], '-'
        JNZ FSTRT2_EXIT
        NEG EAX
        JMP FSTRT2_EXIT
FSTRT2_ERR:
        MOV EAX, -1
FSTRT2_EXIT:
		POP EDI
		POP EDX
		POP ECX
		POP EBX
        RET
FSTRT2 ENDP

; 获取一个数字
; 参数无
; 返回值：输入的数字EAX，数字过大将会被截断
; 注意：请求失败返回-1，所以返回-1有可能是输入的-1也肯能是请求失败
GET_NUM PROC
        invoke READ, OFFSET IN_NUM
        MOV AH, 0
        MOV AL, IN_NUM[1]
        ; 解析交给函数去做
        invoke FSTRT2, OFFSET IN_NUM[2], AX
        RET
GET_NUM ENDP

; 输出菜单函数
; 参数：无
; 返回值：输入的菜单选项，存放在AL中
SHOW_MENU PROC
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH EDI
        invoke WRITE, OFFSET query
        invoke CRLF
        CMP AUTH, 1
        JNZ STR6
        MOV EDI, OFFSET modify
        MOV ECX, 4
SHOW_MENU_LOOP1:
		push ecx
        invoke WRITE, EDI
        invoke CRLF
        ADD EDI, 40
		pop ECX
        LOOP SHOW_MENU_LOOP1
STR6:
        invoke WRITE, OFFSET exit
        invoke CRLF
        ; 输入选项部分
        invoke GET_NUM
        invoke CRLF
        ;恢复环境
        POP EDI
        POP EDX
        POP ECX
        POP EBX
        RET
SHOW_MENU ENDP

; 查询商品函数
; 参数：无（参数在此函数中输入）
; 返回值：无（直接在此函数中输出）
QUERYP  PROC IN_GOODS : DWORD
        ; 需要使用的寄存器先压栈保存环境
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH EDI
        ; 开始在商店一寻找商品
        MOV ECX, G_CNT
        MOV EDI, OFFSET S1[10]
		MOV EBX, IN_GOODS
QUERY_LOOP1:
        invoke CMP_STR, EDI, EBX
        ; 查看输入是否与已有商品名相同
        CMP AL, 0
        JZ END_QUERY_LOOP1
        ; 转移到下一个物品
        ADD EDI, G_SIZE
        LOOP QUERY_LOOP1
        JMP NO_GOODS
END_QUERY_LOOP1:
        ; 存在商品就好办了
        ; EDI此时存放的是商品在第一个商店中的位置
        ; 输出商品的信息“SHOP1，商品名称，销售价，进货总数，
        ;已售数量”顺序显示该商品的信息，同时还要将“SHOP2”中该商品的信息也显示出来。
		invoke WRITE, EDI
		invoke CRLF
        invoke WRITE, OFFSET SHOP1_STR
        invoke COMMA
        ; 得出销售价
        MOV AX, [EDI + 12]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 进货总数
        MOV AX, [EDI + 14]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 已售总量
        MOV AX, [EDI + 16]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke CRLF
        ; 显示商店2中方物品信息
        ADD EDI, S_SIZE
		invoke WRITE, OFFSET SHOP2_STR
        invoke COMMA
        ; 得出销售价
        MOV AX, [EDI + 12]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 进货总数
        MOV AX, [EDI + 14]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 已售总量
        MOV AX, [EDI + 16]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke CRLF
; 没有此商品     
NO_GOODS:
; 函数结束
        POP EAX
        POP EBX
        POP ECX
        POP EDX
        POP EDI
        RET
QUERYP  ENDP

; 修改商店物品的信息
; 参数：商店名和物品名字符串所在地址
; 返回值，无
MODIFYP PROC ADD3:DWORD, ADD4:DWORD
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDI
        ; 首先比较商店
        MOV EBX, OFFSET S1
        invoke CMP_STR, EBX, ADD3
        ; 是这个shop进入下环节
        CMP AL, 0
        JZ FIND_GOODS
        MOV EBX, OFFSET S2
        invoke CMP_STR, EBX, ADD3
        CMP AL, 0
        ; 进入下环节
        JZ FIND_GOODS
        ; 没进入下环节说明没有此商店
        JMP NO_SHOP
; 寻找商品
FIND_GOODS:
        ; 哪个商店？在EDI中，不需要关心
        ; 移动到第一个物品处
        ADD EBX, 10
        ; 开始寻找物品名
        ; 将商品数量输入到CX中
        MOV ECX, G_CNT
LOOP_GOODS:
        invoke CMP_STR, EBX, ADD4
        CMP AL, 0
        JZ FOUND_GOOD
        ; 移动到下一个物品处
        ADD EBX, G_SIZE
        LOOP LOOP_GOODS
        JMP NO_GOODS_1
FOUND_GOOD:
; 改变进货价
CHG_COST:
        invoke WRITE, OFFSET COST
        MOV AX, [EBX + 10]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        ; 逗号分隔开 
        invoke COMMA
        ; 尝试获取数字
		invoke READ, OFFSET IN_NUM
        CMP BYTE PTR IN_NUM[1], 0
        JE  CHG_PRICE
        MOV AL, IN_NUM[1]
        MOV AH, 0
        invoke FSTRT2, OFFSET IN_NUM[2], AX
        CMP AX, -1
        JE CHG_COST
        ; 将得到的数字的低两字节放入位置
        MOV [EBX + 10], AX
CHG_PRICE:
;同等逻辑
        invoke WRITE, OFFSET PRICE
        MOV AX, [EBX + 12]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 尝试获取数字
        invoke READ, OFFSET IN_NUM
        CMP IN_NUM[1], 0
        JE  CHG_CNT
        MOV AL, IN_NUM[1]
        MOV AH, 0
        invoke FSTRT2, OFFSET IN_NUM[2], AX
        CMP AX, -1
        JE CHG_PRICE
        MOV [EBX + 12], AX
;; 修改进货数量
CHG_CNT:
        invoke WRITE, OFFSET BUY_CNT
        MOV AX, [EBX + 14]
        MOVSX EAX, AX
        invoke PRINT_NUM, EAX
        invoke COMMA
        ; 尝试获取数字
        invoke READ, OFFSET IN_NUM
        CMP BYTE PTR IN_NUM[1], 0
        JE  NO_GOODS_1
        MOV AL, IN_NUM[1]
        MOV AH, 0
        invoke FSTRT2, OFFSET IN_NUM[2], AX
        CMP AX, -1
        JE CHG_CNT
        MOV [EBX + 14], AX
NO_GOODS_1:
NO_SHOP:
    ;  结束
        POP EDI
        POP ECX
        POP EBX
        POP EAX
        RET
MODIFYP ENDP

; 函数：计算一个商品的平均利润率
; 参数：第一个商店里的物品的偏移地址
; 返回值：利润率AX
CALCUG_PRO PROC _ADD:DWORD
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH ESI
        MOV G_PRO, 0
        MOV ESI, _ADD
        MOV ECX, S_CNT
L1:
        PUSH G_PRO
        XOR EAX, EAX
        XOR EBX, EBX
        XOR EDX, EDX
        MOV AX, [ESI + 10]
        MOV BX, [ESI + 14]
        IMUL AX, BX
        ; 80x86低位在前
        MOVSX EAX, AX; 拓展AX符号位
        MOV G_COST, EAX
        MOV AX, [ESI + 12]
        MOV BX, [ESI + 16]
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
        ADD ESI, S_SIZE
        LOOP L1
        ; 恢复现场并返回
        MOV EAX, G_PRO
        CDQ
        MOV EBX, S_CNT
        IDIV EBX
        POP ESI
        POP EDX
        POP ECX
        POP EBX
        RET
CALCUG_PRO ENDP
; 获取所有商品平均利润率函数
; 参数：无
; 返回值：无
CALCU_ALL PROC
        PUSH EAX
        PUSH EDI
        MOV ECX, G_CNT
        MOV EDI, OFFSET S1[10]
CALCU_ALL_LOOP1:
        invoke CALCUG_PRO, EDI
        MOV [EDI + 18], AX
        ADD EDI, G_SIZE
        LOOP CALCU_ALL_LOOP1
        POP EDI
        POP EAX
        RET
CALCU_ALL ENDP

; 平均利润率排名函数
; 我选择使用选择排序
; 参数：无
; 返回值：无
SORT_PROP   PROC
        PUSH EAX
        PUSH EBX
        PUSH ECX
        PUSH EDX
        PUSH DI
        PUSH SI
        MOV CX, G_CNT
        MOV EBX, OFFSET IDXES
        MOV EDI, OFFSET S1[10]
        ; 获取所有的商品偏移地址
GET_IDX_LOOP:
        MOV [EBX], DI
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
        MOV EBX, OFFSET IDXES
SORT_OUT_LOOP:
        PUSH CX
        PUSH BX
        ; AX存放已知最大利润率
        MOV AX, -1
        ; DI获取商品地址
        MOV DI, [EBX]
        ; 获取此商品利润率
        MOV AX, [EDI + 18]
        MOV MAX, BX
        ; 需要从BX下一个物品处开始循环
        ; CX现在的数值就是剩余的商品数量加1
SORT_IN_LOOP:
        DEC CX
        CMP CX, 0
        JE NOT_BIG
        ADD BX, 2
        MOV DI, [EBX]
        MOV DX, [EDI + 18]
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
        MOV AX, [EBX]
        MOV DI, MAX
        MOV DI, [EDI]
        MOV [EBX], DI
        MOV DI, MAX
        MOV [EDI], AX
        MOV DI, [EBX]
        MOV AX, RANK
        INC WORD PTR RANK
        ADD DI, S_SIZE
        MOV [EDI + 18], AX
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
end
