.386
STACK	SEGMENT USE16 STACK
        DB 200 DUP(0)
STACK 	ENDS
DATA	SEGMENT USE16
BNAME  	DB 'YANING$', 3 DUP(0); 用户名
BPASS	DB 'passwd', 4 DUP(0); 密码
N		= 30
S1		DB 'SHOP1$', 4 DUP(0)
GA1		DB 'PEN$', 6 DUP(0)
		DW 35, 56, 70, 25, ? ; 利润率未计算
GA2		DB 'BOOK$', 5 DUP(0)
		DW 12, 30, 25, 5, ? ; 利润率未计算
GAN		DB N - 2 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, ?, ?); 其他商品暂时未知
S2 		DB  'SHOP2', 0 ;网店名称，用0结束
GB1   	DB    'BOOK', 6 DUP(0) ; 商品名称
		DW   12，28，20，15，? ；利润率还未计算
GB2   	DB    'PEN', 7 DUP(0) ;商品名称
		DW   35，50，30，24, ?  ；利润率还未计算
GBN		DB N - 2 DUP('Temp-Value', 15, 0, 20, 0, 30, 0, ?, ?)
DATA	ENDS

CODE	SEGMENT USE16
		ASSUME  CS:CODE, SS:STACK, DS:DATA, ES:DATA
START:
		MOV AX, DATA
		MOV DS, AX
		; code after this

		;stop here
		MOV  AH, 4CH
		INT  21H	
CODE 	ENDS
		END  START
