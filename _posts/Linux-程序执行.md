---
title: Linux-程序执行
date: 2021-02-09 10:07:03
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 ELF

`ELF`是`Executable and Linkable Format`的缩写，它定义二进制文件，库文件的结构。`ELF`文件通常是编译器或链接器的输出，并且是二进制格式

## 1.1 ELF格式详解

__`ELF`大致包含`ELF headers`、`program header table`、`section header table`__

__可以通过`man 5 ELF`查看详细介绍__

### 1.1.1 Section

__目标代码文件中的`section`和`section header table`中的条目是一一对应的。`section`的信息用于链接器对代码重定位。下面列了系统预定义的`section`__

* `.bss`：程序运行时未初始化的数据。当程序运行时，这些数据初始化为0
* `.comment`：版本控制信息
* `.ctors`：c++构造方法的指针
* `.data`/`.data1`：包含初始化的全局变量和静态变量
* `.debug`：符号调试用的信息（与gdb这类调试工具有关）
* `.dtors`：c++析构函数的指针
* `.dynamic`：动态链接的信息
* `.dynstr`：动态链接相关字符串，通常是和符号表中的符号关联的字符串
* `.dynsym`：动态链接符号表
* `.fini`：程序正常结束时需要执行的指令
* `.got`：全局偏移表（`global offset table`）
* `.hash`：符号hash表
* `.init`：程序运行时需要执行的指令
* `.interp`：程序解释器的路径名
* `.line`：包含符号调试的行号信息，描述了源程序和机器代码的对应关系（与gdb这类调试工具有关）
* `.plt`：过程链接表（`Procedure Linkage Table`）
* `.rodata`/`.rodata1`：只读数据，组成不可写的段
* `.shstrtab`：包含section的名字。`section header`中不是已经包含名字了吗，为什么把名字集中存放在这里？`sh_name`包含的是`.shstrtab`中的索引，真正的字符串存储在`.shstrtab`中
* `.strtab`：包含字符串，通常是符号表中符号对应的变量名字
* `.symtab`：符号表（`Symbol Table`）
* `.text`：包含文本或程序的可执行的指令

可以通过`readelf -S <name>`查看`section header table`以及`section`信息

### 1.1.2 Segment

可执行文件载入内存执行时，是以`segment`组织的，每个`segment`对应`ELF`文件中`program header table`中的一个条目，用来建立可执行文件的进程映像。比如我们通常说的，`代码段`、`数据段`，目标代码中的`section`会被链接器组织到可执行文件的各个`segment`中（一个`segment`可以包含0个或多个`section`），例如`.text`的内容会组装到代码段中；`.data`、`.bss`等节的内容会包含在数据段中

可以通过`readelf -l <name>`查看`program header table`以及`segment`信息

## 1.2 参考

* [The 101 of ELF files on Linux: Understanding and Analysis](https://linux-audit.com/elf-binaries-on-linux-understanding-and-analysis/)
* [ELF完整说明文档](https://refspecs.linuxfoundation.org/elf/elf.pdf)
* [ELF格式探析之三：sections](https://segmentfault.com/a/1190000016834180)
* [What's the difference of section and segment in ELF file format](https://stackoverflow.com/questions/14361248/whats-the-difference-of-section-and-segment-in-elf-file-format)
* [https://segmentfault.com/a/1190000016664025](https://segmentfault.com/a/1190000016664025)

# 2 程序如何加载执行

__系统调用`sys_execve`的调用栈如下（内核版本3.10.10）__

```sh
# syscall
sys_execve | fs/exec.c SYSCALL_DEFINE3(execve
    do_execve | fs/exec.c
        do_execve_common | fs/exec.c
            search_binary_handler | fs/exec.c
                load_binary | fs/exec.c
        ⬇️  linux_binfmt --> elf_format
# elf
load_elf_binary | fs/binfmt_elf.c
```

__`load_elf_binary`的主要步骤如下__

1. 读取并检查`ELF headers | elfhdr`
1. 读取并检查`program header table | elf_phdr`
1. 处理动态链接`PT_INTERP | elf_interpreter`
1. 检查是否可执行栈`PT_GNU_STACK | executable_stack`
1. 载入目标程序必要的segment`PT_LOAD`
1. 填写程序的入口地址
    * 如果需要解释器，就通过`load_elf_interp`函数进行加载
    * 如果不需要解释器，那么入口就是本身的入口地址
1. 执行前的准备，例如环境变量等
1. 调用`start_thread`函数准备执行此程序

## 2.1 binfmt_misc

在Windows平台上，可以绑定拥有特定扩展名的文件，使用特定的程序打开。比如，PDF文件就使用Acrobat Reader打开。这样做确实极大的方便了用户的使用体验

其实，在Linux平台上，也提供了类似的功能，甚至从某种意义上来说更加的强大。Linux的内核从很早开始就引入了一个叫做`Miscellaneous Binary Format（binfmt_misc）`的机制，可以通过要打开文件的特性来选择到底使用哪个程序来打开。比Windows更加强大的地方是，它不光光可以通过文件的扩展名来判断的，还可以通过文件开始位置的特殊的字节（Magic Byte）来判断

如果要使用这个功能的话，首先要绑定`binfmt_misc`，可以通过以下命令来绑定：

```sh
mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc
```

这样绑定的话，系统重新启动之后就失效了。如果想让系统每次启动的时候都自动绑定的话，可以往`/etc/fstab`文件中加入下面这行：

```
none  /proc/sys/fs/binfmt_misc binfmt_misc defaults 0 0
```

绑定完之后，就可以通过向`/proc/sys/fs/binfmt_misc/register`（这个文件只能写不能读）文件中写入一行匹配规则字符串来告诉内核什么样的程序要用什么样的程序打开（一般使用echo命令）。这行字符串的格式如下：

```
:name:type:offset:magic:mask:interpreter:flags
```

每个字段都用冒号`:`分割。某些字段拥有默认值，或者只在前面字段被设置成了某个特定值后才有效，因此可以跳过某些字段的设置，但是必须保留相应的冒号分割符。各个字段的意义如下

* `name`：这个规则的名字，理论上可以取任何名字，只要不重名就可以了。但是为了方便以后维护一般都取一个有意义的名字，比如表示被打开文件特性的名字，或者要打开这个文件的程序的名字等
* `type`：表示如何匹配被打开的文件，只可以使用`E`或者`M`，只能选其一，两者不可共用。`E`代表只根据待打开文件的扩展名来识别，而`M`表示只根据待打开文件特定位置的几位魔数（Magic Byte）来识别
* `offset`：这个字段只对前面type字段设置成`M`之后才有效，它表示从文件的多少偏移开始查找要匹配的魔数。如果跳过这个字断不设置的话，默认就是`0`
* `magic`：如果type字段设置成`M`的话，它表示真正要匹配的魔数；如果type字段设置成`E`的话，它表示文件的扩展名。对于匹配魔数来说，如果要匹配的魔数是ASCII码可见字符，可以直接输入，而如果是不可见的话，可以输入其16进制数值，前面加上`\x`或者`\\x`（如果在Shell环境中的话。对于匹配文件扩展名来说，就在这里写上文件的扩展名，但不要包括扩展名前面的点号（`.`），且这个扩展名是大小写敏感的，有些特殊的字符，例如目录分隔符正斜杠（`/`）是不允许输入的
* `mask`：同样，这个字段只对前面type字段设置成`M`之后才有效。它表示要匹配哪些位，它的长度要和magic字段魔数的长度一致。如果某一位为1，表示这一位必须要与magic对应的位匹配；如果对应的位为0，表示忽略对这一位的匹配，取什么值都可以。如果是`0xff`的话，即表示全部位都要匹配，默认情况下，如果不设置这个字段的话，表示要与magic全部匹配（即等效于所有都设置成0xff）。还有同样对于NUL来说，要使用转义（`\x00`），否则对这行字符串的解释将到NUL停止，后面的不再起作用；
* `interpreter`：表示要用哪个程序来启动这个类型的文件，一定要使用全路径名，不要使用相对路径名
* `flags`：这个字段可选，主要用来控制`interpreter`打开文件的行为。比较常用的是`P`（请注意，一定要大写），表示保留原始的`argv[0]`参数。这是什么意思呢？默认情况下，如果不设置这个标志的话，`binfmt_misc`会将传给`interpreter`的第一个参数，即`argv[0]`，修改成要被打开文件的全路径名。当设置了`P`之后，`binfmt_misc`会保留原来的argv[0]，在原来的`argv[0]`和`argv[1]`之间插入一个参数，用来存放要被打开文件的全路径名。比如，如果想用程序`/bin/foo`来打开`/usr/local/bin/blah`这个文件，如果不设置`P`的话，传给程序`/bin/foo`的参数列表`argv[]`是`["/usr/local/bin/blah", "blah"]`，而如果设置了`P`之后，程序`/bin/foo`得到的参数列表是`["/bin/foo", "/usr/local/bin/blah", "blah"]`

__每次成功写入一行规则，都会在`/proc/sys/fs/binfmt_misc/`目录下，创建一个名字为输入的匹配规则字符串中`name`字段的文件__

在`/proc/sys/fs/binfmt_misc/`目录下，还缺省存在一个叫做`status`的文件，通过它可以查看和控制整个`binfmt_misc`的状态，而不光是单个匹配规则

可以查看当前binfmt_misc是否处于打开状态：

```sh
cat /proc/sys/fs/binfmt_misc/status
```

也可以通过向它写入1或0来打开或关闭`binfmt_misc`：

```sh
echo 0 > /proc/sys/fs/binfmt_misc/status    # Disable binfmt_misc
echo 1 > /proc/sys/fs/binfmt_misc/status    # Enable binfmt_misc
```

如果想删除当前binfmt_misc中的所有匹配规则，可以向其传入-1：

```sh
echo -1 > /proc/sys/fs/binfmt_misc/status
```

## 2.2 Relro

通过覆盖`.got`可以达到漏洞攻击的目的，`.got`覆盖之所以能成功是因为默认编译的应用程序的重定位表段对应数据区域是可写的（如`.got.plt`），这与链接器和加载器的运行机制有关，默认情况下应用程序的导入函数只有在调用时才去执行加载（所谓的`lazy loading`，非内联或显示通过dlxxx指定直接加载），如果让这样的数据区域属性变成只读将大大增加安全性。`RELRO（read only relocation）`是一种用于加强对数据段的保护的技术，大概实现由linker指定binary的一块经过`dynamic linker`处理过`relocation`之后的区域为只读，设置符号重定向表格为只读或在程序启动时就解析并绑定所有动态符号，从而减少对`.got`攻击。`RELRO`分为`partial`和`full`

## 2.3 参考

* [linux下使用binfmt_misc设定不同二进制的打开程序](https://blog.csdn.net/whatday/article/details/88299482)
* [ELF文件的加载过程(load_elf_binary函数详解)--Linux进程的管理与调度（十三）](https://cloud.tencent.com/developer/article/1351964)
* [ELF文件加载过程](https://zhuanlan.zhihu.com/p/287863861)
