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

