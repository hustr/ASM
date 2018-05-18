# 1. 环境设置(win)

先去下载网站上的`win32窗口程序框架_操作说明_源码级调试.rar`文件，[下载地址](http://222.20.79.217/huibian1/site/assembly/courseMaterial.files/materialInfo.jsp?id=187)。

下载后解压到你自己的常用文件夹，建议将`Masm32`文件夹移动到C盘根目录下，打开资源管理器，右键此电脑->属性->高级系统设置->环境变量，编辑用户变量，双击`Path`->新建，值设置为你的`Masm32`文件的的`BIN`文件夹目录，如图：

![bin](https://raw.githubusercontent.com/hustr/Pictures/master/win32asm/bin.PNG)

点击确定。

再设置`include`变量，如果已经存在请直接编辑，不存在就新建：

![include](https://raw.githubusercontent.com/hustr/Pictures/master/win32asm/include.PNG)

点击确定。

设置`lib`变量，同`include`：

![lib](https://raw.githubusercontent.com/hustr/Pictures/master/win32asm/lib.PNG)

点击确定。

一直确定直到关闭系统属性。设置变量完毕。

# 2. 编译资源文件

进入源文件所在目录，`Shift`+右键->打开`CMD`或者`PowerShell`。

执行命令：

```powershell
rc ./src_name.rc # src_name就是你的资源文件名字
```

生成一个`.res`文件。

# 3. 编译源码 

```powershell
ml -c -coff -Zi ./code_name.asm #code_name就是你的代码文件名字 
```

生成的一堆文件，下面主要需要其中的`.obj`文件。

# 4. 连接文件

```powershell
link -subsystem:windows -debug -debugtype:cv code_name.obj src_name.res
```

这部就生成了`.exe`文件。

# 5. 运行

直接在命令行中打开：

```powershell
./code_name
```

或者直接双击`.exe`文件。

运行如图：

![win_wnd](https://raw.githubusercontent.com/hustr/Pictures/master/win32asm/win_wnd.gif)