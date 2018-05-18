.386
.model   flat,stdcall
option   casemap:none

WinMain  proto :DWORD,:DWORD,:DWORD,:DWORD
WndProc  proto :DWORD,:DWORD,:DWORD,:DWORD
Display  proto :DWORD
;Average  proto
;ToStr	 proto :DWORD

include	menuID.inc; 自己的ID文件

; 系统inc文件
include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
; 系统库文件
includelib 	user32.lib
includelib  kernel32.lib
includelib  gdi32.lib
includelib  shell32.lib
;结构体定义
; 大小为24个字节
goods	struct
		g_name	db 	10 dup(0)
		inpre 	dw 	0
		outpre 	dw 0
		incnt	dw 0
		outcnt	dw 0
		pro		dw 0
		len		dd 0
goods 	ends

; 数据段定义
.data
ClassName	db 	'TryWinClass',0
AppName     db  'Shop Manage System',0
MenuName    db  'MyMenu',0
DlgName	    db  'MyDialog',0
AboutMsg    db  'I am Yaning Wang from CS1607.',0
hInstance   dd  0
CommandLine dd  0
;buf	    student  <>
;	    student  <'Jin',96,98,100,98,'A'>
;	    student  3 dup(<>)
all_goods	goods	<'Bag', 12, 30, 100, 5, ?, 3>
			goods	<'Pen', 35, 56, 70, 25, ?, 3>
			goods	<'Book', 12, 30, 25, 5, ?, 4>
			goods	<'Cup', 35, 50, 30, 24, ?, 3>
			goods	<'Eraser', 12, 28, 20, 15, ?, 6>
msg_name    db	'Name',0
msg_inpre   db  'In Price',0
msg_outpre  db  'Out Price',0
msg_incnt   db  'In Count',0
msg_outcnt  db  'Out Count',0
msg_pro db  'Profile',0
sum		db 0
;tostr
num_str	db 10 dup(0)
len		dd 0
ten		dw 10
; display
xgap	dd 0
ygap 	dd 0
g_idx	dd 0
; 代码段
.code
Start:	invoke 	GetModuleHandle,NULL
	    mov    	hInstance,eax
	    invoke 	GetCommandLine
	    mov    	CommandLine,eax
	    invoke 	WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	    invoke 	ExitProcess, eax
	     ;;
WinMain proc   	hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD
	    LOCAL  	wc:WNDCLASSEX
	    LOCAL  	msg:MSG
	    LOCAL  	hWnd:HWND
        invoke 	RtlZeroMemory, addr wc, sizeof wc
	    mov		wc.cbSize, SIZEOF WNDCLASSEX
	    mov     wc.style, CS_HREDRAW or CS_VREDRAW
	    mov    	wc.lpfnWndProc, offset WndProc
	    mov    	wc.cbClsExtra,NULL
	    mov    	wc.cbWndExtra,NULL
	    push   	hInst
	    pop    	wc.hInstance
	    mov    	wc.hbrBackground, COLOR_WINDOW+1
	    mov    	wc.lpszMenuName, offset MenuName
	    mov    	wc.lpszClassName, offset ClassName
	    invoke 	LoadIcon, NULL,IDI_APPLICATION
	    mov    	wc.hIcon, eax
	    mov    	wc.hIconSm, 0
	    invoke 	LoadCursor, NULL, IDC_ARROW
	    mov    	wc.hCursor, eax
	    invoke 	RegisterClassEx, addr wc
	    invoke 	CreateWindowEx, NULL,addr ClassName,addr AppName,\
                    WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
                    CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
                    hInst,NULL
	    mov		hWnd, eax
	    invoke 	ShowWindow, hWnd, SW_SHOWNORMAL
	    invoke 	UpdateWindow, hWnd
MsgLoop:
		invoke 	GetMessage, addr msg, NULL, 0, 0
        cmp    	eax, 0
        je     	ExitLoop
        invoke 	TranslateMessage, addr msg
        invoke 	DispatchMessage, addr msg
	    jmp    	MsgLoop
ExitLoop:
		mov    	eax,msg.wParam
	    ret
WinMain	endp

Average proc hWnd:dword
		mov sum, 5
		push eax
		push ebx
		push ecx
		push edx
		push edi
		mov ebx, 0
LOOP_AVE:
		movsx eax, all_goods[ebx].inpre
		movsx ecx, all_goods[ebx].incnt
		imul ecx
		mov edi, eax
		movsx eax, all_goods[ebx].outpre
		movsx ecx, all_goods[ebx].outcnt
		imul ecx
		sub eax, edi
		imul eax, 100
		cdq
		idiv edi
		mov all_goods[ebx].pro, ax
		add ebx, 24
		dec sum
		cmp sum, 0
		jg  LOOP_AVE
		pop edi
		pop edx
		pop ecx
		pop ebx
		pop eax
		invoke Display, hWnd
		ret
Average endp

; 返回eax作为字符串长
ToStr 	proc num:dword
		push eax
		push ebx
		push ecx
		push edx
		mov ecx, 0
		mov len, 0
		mov ax, word ptr num
		cmp ax, 0
		mov ebx, offset num_str
		jge POSITIVE
		neg ax
		mov byte ptr [ebx], '-'
		inc ebx
		inc len
POSITIVE:
		inc len
		cwd
		idiv ten
		push dx
		inc ecx
		cmp ax, 0
		jne POSITIVE
POP_LOOP:
		pop dx
		add dl, '0'
		mov [ebx], dl
		inc ebx
		loop POP_LOOP
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
ToStr 	endp

; 专门处理的程序
WndProc proc   	hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	    LOCAL  	hdc:HDC
		.IF uMsg == WM_DESTROY
			invoke PostQuitMessage,NULL
		; 按键不进行操作
		;.ELSEIF uMsg == WM_KEYDOWN
		;	.IF wParam == VK_F1
		;	.ENDIF
		.ELSEIF uMsg == WM_COMMAND
			; 按了退出
			.IF wParam == File_Exit
				invoke SendMessage,hWnd,WM_CLOSE,0,0
			.ELSEIF wParam == Action_Average
				;invoke Display,hWnd
				; TODO average
				invoke Average, hWnd
			.ELSEIF wParam == Action_List
				; 显示商品信息
				invoke Display, hWnd
			.ELSEIF wParam == Help_About
				; 显示作者信息
				invoke MessageBox, hWnd, addr AboutMsg, addr AppName, MB_OK
			.ENDIF
		;.ELSEIF uMsg == WM_PAINT
	     ;;redraw window again
		.ELSE
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam
            ret
		.ENDIF
  	    xor eax, eax
	    ret
WndProc endp



Display proc    hWnd:DWORD
        XX	equ 10
        YY  equ 10
	    XX_GAP  equ	100
	    YY_GAP  equ  30
		LOCAL   hdc:HDC
		push eax
		push ebx
		push ecx
		push edx
		push edi
		xor eax, eax
		xor ebx, ebx
		xor ecx, ecx
		xor edx, edi
		invoke  GetDC, hWnd
		mov     hdc, eax
		; 输出最上面的信息栏
		invoke  TextOut,hdc,XX+0*XX_GAP,edx,offset msg_name, 4
		invoke  TextOut,hdc,XX+1*XX_GAP,edx,offset msg_inpre, 8
		invoke  TextOut,hdc,XX+2*XX_GAP,edx,offset msg_outpre, 9
		invoke  TextOut,hdc,XX+3*XX_GAP,edx,offset msg_incnt, 8
		invoke  TextOut,hdc,XX+4*XX_GAP,edx,offset msg_outcnt, 9
		invoke  TextOut,hdc,XX+5*XX_GAP,edx,offset msg_pro, 7
		; 一共5件商品
		mov sum, 5
		mov ygap, YY
		; ebx放置all_goods的里商品首地址
		mov ebx, 0
PRINT_LOOP:
		;push ecx
		mov xgap, XX
		add ygap, YY_GAP
		invoke TextOut,hdc,xgap,ygap,addr all_goods[ebx].g_name, all_goods[ebx].len;all_goods[ebx].len
		; 下面的需要先转换为str，还要有长度
		; 调用ToStr函数
		add xgap, XX_GAP
		invoke ToStr, all_goods[ebx].inpre
		invoke TextOut,hdc,xgap,ygap,offset num_str, len
		add xgap, XX_GAP
		invoke ToStr, all_goods[ebx].outpre
		invoke TextOut,hdc,xgap,ygap,offset num_str, len
		add xgap, XX_GAP
		invoke ToStr, all_goods[ebx].incnt
		invoke TextOut,hdc,xgap,ygap,offset num_str, len
		add xgap, XX_GAP
		invoke ToStr, all_goods[ebx].outcnt
		invoke TextOut,hdc,xgap,ygap,offset num_str, len
		add xgap, XX_GAP
		invoke ToStr, all_goods[ebx].pro
		invoke TextOut,hdc,xgap,ygap,offset num_str, len
		;pop ebx
		add ebx, 24
		;pop ecx
		;dec ecx
		dec sum
		cmp sum, 0
		jg  PRINT_LOOP
		;loop PRINT_LOOP
		; 结束，恢复环境
		pop edi
		pop edx
		pop ecx
		pop ebx
		pop eax
		ret
Display endp
end  Start

;goods	struct
;		g_name	db 	10 dup(0)
;		inpre 	dw 	0
;		outpre 	dw 0
;		incnt	dw 0
;		outcnt	dw 0
;		pro		dw 0
;goods 	ends