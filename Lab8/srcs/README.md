# 1. 编译资源文件

```powershell
rc menu.rc
```

生成一个`.res`文件。

# 2. 编译源码 

```powershell
ml -c -coff -Zi code.asm
```

生成的一堆文件，下面主要需要其中的`.obj`文件。

# 3. 连接文件

```powershell
link -subsystem:windows -debug -debugtype:cv code.obj menu.res
```

这就生成了`.exe`文件。

***完成***