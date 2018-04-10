主流程图

```flow
st=>start: 开始
e=>end: 结束

notice_name=>operation: 提示输入用户名
in_name=>inputoutput: 输入用户名
notice_pwd=>operation: 提示输入密码
in_pwd=>inputoutput: 输入密码
no_name=>condition: 未输入名字？
name_q=>condition: 输入为'q'？
auth_0=>operation: auth置为0，进入功能3

name_check=>condition: 用户名正确？
pwd_check=>condition: 密码正确？
auth_1=>operation: auth设置为1，进入功能3

notice_goods=>operation: 提示输入商品名
in_goods=>inputoutput: 输入商品名
goods_enter=>condition: 只有回车？
goods_is_in=>condition: 网店1有该商品？
check_auth=>condition: 已经登陆？
calcu_rate=>operation: 计算网店1中利润率PR1
计算网店2中利润率PR2
计算平均利润率APR
show_name=>operation: 显示商品名字

class=>inputoutput: 输出等级：
APR >= 90%? A
APR >= 50%? B
APR >= 20%? C
APR >= 0%? D
APR < 0% F


st->notice_name->in_name->notice_pwd->in_pwd->no_name->
pwd_check(yes, left)->auth_1->notice_goods->in_goods->goods_enter
pwd_check(no, right)->notice_name
no_name(no, down)->name_q
no_name(yes, right)->auth_0->notice_goods
name_q(yes, down)->e
name_q(no, down)->name_check
name_check(yes)->pwd_check
name_check(no)->notice_name
goods_enter(yes, left)->notice_name
goods_enter(no, down)->goods_is_in
goods_is_in(no)->notice_goods
goods_is_in(yes)->check_auth
check_auth(no)->show_name->notice_name
check_auth(yes)->calcu_rate->class->notice_name

```

判断输入用户名是否正确，密码同等逻辑

```flow
st=>start: 开始
in=>inputoutput: 输入用户名到缓冲区IN_NAME
name_0=>condition: IN_NAME[1] == 0?
输入用户名长度是否为0?
func3=>operation: 跳到功能3
cmp_len=>condition: IN_NAME[1] == NAME_LEN?
输入用户名长度正确？
name_1=>condition: IN_NAME[1] == 1?
输入用户名长度为1？
name_q=>condition: 输入为q
lea=>operation: LEA EBX, OFFSET IN_NAME + 2
LEA EDX, OFFSET BNAME
load_str=>operation: MOV AL, [EBX]
MOV AH, [EDX]
INC EDX
INC EBX
equal=>condition: AH == AL?
cmp_end=>condition: MOV AL, [EBX]
AL == 0?
auth_1=>operation: MOV AUTH, 1
auth_0=>operation: MOV AUTH, 0
e=>end: 结束

st->in->cmp_len
cmp_len(yes)->lea->load_str->equal
equal(yes)->cmp_end
equal(no, left)->in
cmp_end(yes)->auth_1->func3
cmp_end(no)->load_str
cmp_len(no)->name_1
name_1(yes)->name_q
name_1(no)->name_0
name_0(yes)->auth_0->func3->e
name_0(no)->in
name_q(yes)->e
name_q(no)->in

```



计算利润率的函数

```flow
s=>start: 开始
lea=>operation: MOV ECX, G_INDEX
; G_INDEX中为地址不能直接使用
cal_cost=>operation: MOV AX, [ECX + 10]
MOV BX, [ECX + 14]
IMUL AX, BX
MOVSX EAX, AX
MOV G_COST, EAX
cal_pro=>operation: MOV AX, [ECX + 12]
MOV BX, [ECX + 16]
IMUL AX, BX
MOVSX EAX, AX
MOV G_PRO, EAX
cal_rate=>operation: MOV EAX, G_PRO
MOV EBX, G_COST
SUB EAX, EBX
CWD
IDIV BX
MOV [ECX + 18], AX
e=>end: 结束

s->lea->cal_cost->cal_pro->cal_rate->e
```

