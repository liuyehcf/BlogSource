---
title: Cpp-Tools-GDB
date: 2021-09-06 10:55:03
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 GDB能够做什么？

1. 一个支持包括`c`以及`c++`等众多语言的`debugger`工具
1. 它允许您检查程序在执行期间的某个时刻正在做什么
1. 能够定位诸如`segmentation faults`等错误的具体原因
1. 

对`c/c++`程序的调试，需要在编译前就加上`-g`选项：

```sh
gcc -g hello.c -o hello
g++ -g hello.cpp -o hello
```

# 2 如何进入GDB shell

`gdb`提供了一个交互式的`shell`，能够通过`↑`查询历史命令，可以通过`tab`进行命令行补全，可以通过`help [command]`查询帮助文档

**进入gdb交互界面的几种方式：**

* `gdb <binary_with_-g>`：调试可执行文件
* `gdb <binary_with_-g> core.xxx`：分析coredump
* `gdb <binary_with_-g> <pid_without_-g>`：以可执行文件为元数据，调试指定进程
    * `<binary>`需要用`-g`参数编译出来，否则指定该文件没有意义
    * `<pid>`对应的进程可以是不带`-g`参数编译出来的版本，只要保证源码一样即可
* `gdb -p <pid_with_-g>`：调试指定进程
    * 若`<pid>`对应的进程如果是用`-g`参数编译出来，那么等效于`gdb <binary_with_-g>` + `run`

**下面演示一下使用`gdb <binary_with_-g> <pid_without_-g>`这种方式进入gdb shell**

```sh
# 源码
cat > main.cpp << 'EOF'
#include<iostream>
#include<thread>
#include<chrono>

int main() {
    std::cout << "hello, world!" <<std::endl;

    int cnt = 0;
    while(true) {
        ++cnt;
        std::this_thread::sleep_for(std::chrono::seconds(1));
	std::cout << "cnt=" << cnt << std::endl;
    }
}
EOF

# 编译两个版本，一个带-g参数，一个不带
g++ -o main_without_debug main.cpp -std=gnu++11
g++ -o main_with_debug main.cpp -std=gnu++11 -g
```

```sh
# 运行非debug版本
./main_without_debug
```

```sh
# 查询进程id
pid=$(ps -ef | grep main_without_debug | grep -v grep | awk '{print $2}')

# 进入gdb shell
gdb main_with_debug ${pid}
```

# 3 command

## 3.1 运行程序

当我们通过`gdb <binary>`这种方式进入`gdb shell`后，程序不会立即执行，需要通过`run`或者`start`命令触发程序的执行

* `run`：开始执行程序，直到碰到第一个断点或者程序结束
* `start`：开始执行程序，在main函数第一行停下来

如果程序有异常（比如包含段错误），那么我们将会得到一些有用的信息，包括：程序出错的行号，函数的参数等等信息

```sh
# c++源文件
$ cat > segment_fault.cpp << 'EOF'
int main() {
    int *num = nullptr;
    *num = 100;
    return 0;
}
EOF

# 编译（可以试下不加-g参数）
$ g++ -o segment_fault segment_fault.cpp -std=gnu++11 -g

# 进入gdb shell
$ gdb segment_fault

# 执行程序，程序会出现段错误而退出，并输出相关的错误信息
# 如果编译时没有加-g参数，输出的信息就会少很多（比如行号和具体的代码就没有了）
(gdb) run

Starting program: xxx/segment_fault

Program received signal SIGSEGV, Segmentation fault.
0x000000000040051d in main () at segment_fault.cpp:3
3	    *num = 100;

```

## 3.2 GDB与程序关联

## 3.3 断点设置

* `break`：用于设置断点
    * `break <line_num>`
    * `break <func_name>`
    * `break <file_name>:<line_num>`
    * `break <file_name>:<func_name>`
* `info break`：用于查看断点
* `delete`：用于删除断点
    * `delete <break_id>`：删除指定断点
    * `delete`：删除所有断点
* `enable`：用于启用断点
    * `enable <break_id>`
* `disable`：用于停用断点
    * `disable <break_id>`

### 3.3.1 demo 

```sh
# c++源文件
$ cat > set_break.cpp << 'EOF'
#include <iostream>

void funcA() {
    std::cout << "invoke funcA()" << std::endl;
}

int main() {
    std::cout << "hello world" << std::endl;

    int num = 0;

    int *num_ptr = &num;

    funcA();

    for(int i=0; i < 10; i++) {
        ++(*num_ptr);
    }

    std::cout << "num: " << *num_ptr << std::endl;

    return 0;
}
EOF

# 编译（可以试下不加-g参数）
$ g++ -o set_break set_break.cpp -std=gnu++11 -g

# 进入gdb shell
$ gdb set_break

# 通过list查看源码
$ (gdb) list 0
1	#include <iostream>
2
3	void funcA() {
4	    std::cout << "invoke funcA()" << std::endl;
5	}
6
7	int main() {
8	    std::cout << "hello world" << std::endl;
9
10	    int num = 0;
# 回车，继续输出下10行
$ (gdb)
11
12	    int *num_ptr = &num;
13
14	    funcA();
15
16	    for(int i=0; i < 10; i++) {
17	        ++(*num_ptr);
18	    }
19
20	    std::cout << "num: " << *num_ptr << std::endl;
# 回车，继续输出下10行
$ (gdb)
21
22	    return 0;
23	}
```

```sh
# 在行号为8的位置打断点
$ (gdb) break 8
Breakpoint 1 at 0x400848: file set_break.cpp, line 8.

# 在行号为10的位置打断点
$ (gdb) break set_break.cpp:10
Breakpoint 2 at 0x400864: file set_break.cpp, line 10.

# 在行号为12的位置打断点
$ (gdb) break 12
Breakpoint 3 at 0x40086b: file set_break.cpp, line 12.

# 在行号为4的位置打断点
$ (gdb) break 4
Breakpoint 4 at 0x400821: file set_break.cpp, line 4.

# 在行号为17的位置打断点
$ (gdb) break 17
Breakpoint 5 at 0x400881: file set_break.cpp, line 17.

# 在行号为20的位置打断点
$ (gdb) break 20
Breakpoint 6 at 0x40089a: file set_break.cpp, line 20.

# 在函数funcA处打断点，发现该断点已经重复了
$ (gdb) break funcA
Note: breakpoint 4 also set at pc 0x400821.
Breakpoint 7 at 0x400821: file set_break.cpp, line 4.

# 查看所有断点
(gdb) info break
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400848 in main() at set_break.cpp:8
2       breakpoint     keep y   0x0000000000400864 in main() at set_break.cpp:10
3       breakpoint     keep y   0x000000000040086b in main() at set_break.cpp:12
4       breakpoint     keep y   0x0000000000400821 in funcA() at set_break.cpp:4
5       breakpoint     keep y   0x0000000000400881 in main() at set_break.cpp:17
6       breakpoint     keep y   0x000000000040089a in main() at set_break.cpp:20
7       breakpoint     keep y   0x0000000000400821 in funcA() at set_break.cpp:4

# 执行命令run开始运行程序，发现现在程序卡在了行号为8的位置
$ (gdb) run
Starting program: xxx/set_break

Breakpoint 1, main () at set_break.cpp:8
8	    std::cout << "hello world" << std::endl;
```

## 3.4 调试

* `continue`：继续运行直至程序结束或者遇到下一个断点
* `step`：源码级别的单步调试，会进入方法，另一种说法是`step into`
* `next`：源码级别的单步调试，不会进入方法，将方法调用视为一步，另一种说法是`step over`
* `stepi`：指令级别的单步调试，会进入方法，另一种说法是`step into`
* `nexti`：指令级别的单步调试，不会进入方法，将方法调用视为一步，另一种说法是`step over`
* `until`：退出循环
* `finish`：结束当前函数的执行
* `display <variable>`：跟踪查看某个变量，每次停下来都显示它的值
* `undisplay <display_id>`：取消跟踪
* `watch`：设置观察点。当被设置观察点的变量发生修改时，打印显示
* `thread <id>`：切换调试的线程为指定线程

## 3.5 查看调试相关信息

* `bt`、`backtrace`、`where`：查看当前调用堆栈
    * `bt 3`：最上面3层
    * `bt -3`：最下面3层
* `disassemble`：查看当前的汇编指令
    * `disassemble`：当前函数的汇编指令
    * `disassemble <function>`：指定函数的汇编指令
* `list`：查看源码
    * `list`：紧接着上一次的输出，继续输出10行源码
    * `list <linenumber>`：输出当前文件指定行号开始的10行源码
    * `list <function>`：输出指定函数的10行源码
    * `list <filename:linenum>`：输出指定文件指定行号开始的10行源码
    * `list <filename:function>`：输出指定文件指定函数的10行源码
* `info`用于查看各种调试相关的信息
    * `info break`：查看断点
    * `info reg`：查看寄存器
    * `info stack`：查看堆栈
    * `info thread`：查看线程
    * `info locals`：查看本地变量
    * `info args`：查看参数
    * `info symbol <address>`：查看指定内存地址所对应的符号信息（如果有的话）
* `print`：用于查看变量
    * `print <variable>`
    * `print <variable>.<field>`
    * `p *((std::vector<uint32_t>*) <address>)`：查看智能指针
* `x/<n/f/u>  <addr>`：以指定格式打印内存信息
    * `n`：正整数，表示需要显示的内存单元的个数，即从当前地址向后显示n个内存单元的内容，一个内存单元的大小由第三个参数`u`定义
    * `f`：表示`addr`指向的内存内容的输出格式
        * `s`：对应输出字符串
        * `x`：按十六进制格式显示变量
        * `d`：按十进制格式显示变量
        * `u`：按十进制格式显示无符号整型
        * `o`：按八进制格式显示变量
        * `t`：按二进制格式显示变量
        * `a`：按十六进制格式显示变量
        * `c`：按字符格式显示变量
        * `f`：按浮点数格式显示变量
    * `u`：就是指以多少个字节作为一个内存单元-unit，默认为4。`u`还可以用被一些字符表示:
        * `b`：1 byte
        * `h`：2 bytes
        * `w`：4 bytes
        * `g`：8 bytes
    * 示例：
        * `x /1ug $rbp-0x4`：查看寄存器`rbp`存储的内容减去`0x4`得到的地址中所存储的内容
        * `x /1xg $rsp`：查看寄存器`rsp`存储的地址中所存储的内容

**`info reg`会显示所有寄存器的内容，其中内容会打印两列，第一列是以16进制的形式输出（`raw format`），另一列是以原始形式输出（`natural format`），下面显式了所有寄存器的大小以及类型**

* 类型为`int64`的寄存器，`natural format`用十进制表示
* 类型为`data_ptr`以及`code_ptr`的寄存器，`natural format`仍然以十六进制表示，所以你会看到两列完全一样的值

```xml
<reg name="rax" bitsize="64" type="int64"/>
<reg name="rbx" bitsize="64" type="int64"/>
<reg name="rcx" bitsize="64" type="int64"/>
<reg name="rdx" bitsize="64" type="int64"/>
<reg name="rsi" bitsize="64" type="int64"/>
<reg name="rdi" bitsize="64" type="int64"/>
<reg name="rbp" bitsize="64" type="data_ptr"/>
<reg name="rsp" bitsize="64" type="data_ptr"/>
<reg name="r8" bitsize="64" type="int64"/>
<reg name="r9" bitsize="64" type="int64"/>
<reg name="r10" bitsize="64" type="int64"/>
<reg name="r11" bitsize="64" type="int64"/>
<reg name="r12" bitsize="64" type="int64"/>
<reg name="r13" bitsize="64" type="int64"/>
<reg name="r14" bitsize="64" type="int64"/>
<reg name="r15" bitsize="64" type="int64"/>

<reg name="rip" bitsize="64" type="code_ptr"/>
<reg name="eflags" bitsize="32" type="i386_eflags"/>
<reg name="cs" bitsize="32" type="int32"/>
<reg name="ss" bitsize="32" type="int32"/>
<reg name="ds" bitsize="32" type="int32"/>
<reg name="es" bitsize="32" type="int32"/>
<reg name="fs" bitsize="32" type="int32"/>
<reg name="gs" bitsize="32" type="int32"/>
```

### 3.5.1 demo of print

```sh
# c++源文件
$ cat > print.cpp << 'EOF'
struct Person {
    const char* name;
    const char* phone_num;
    const int age;
};

int main() {
    Person p {"张三", "123456789", 18};
    return 0;
}
EOF

# 编译（可以试下不加-g参数）
$ g++ -o print print.cpp -std=gnu++11 -g

# 进入gdb shell
$ gdb print

# 查看源码
$ list
(gdb) list
1	struct Person {
2	    const char* name;
3	    const char* phone_num;
4	    const int age;
5	};
6
7	int main() {
8	    Person p {"张三", "123456789", 18};
9	    return 0;
10	}

# 设置断点
$ (gdb) break 9
Breakpoint 1 at 0x400528: file print.cpp, line 9.

# 运行程序，会停在断点处
$ (gdb) run
Starting program: xxx/print

Breakpoint 1, main () at print.cpp:9
9	    return 0;

# 查看相关信息
$ (gdb) print p
$1 = {name = 0x4005c0 "张三", phone_num = 0x4005c7 "123456789", age = 18}
$ (gdb) print p.name
$2 = 0x4005c0 "张三"
$ (gdb) print p.phone_num
$3 = 0x4005c7 "123456789"
$ (gdb) print p.age
$4 = 18
$ (gdb) print &p
$5 = (Person *) 0x7fffffffe0c0
```

## 3.6 `!`执行外部命令

格式：`!<command> [params]`

```sh
(gdb) !pwd
xxx/gdb_tutorial
```

# 4 ASAN

[google/sanitizers](https://github.com/google/sanitizers)

# 5 参考

* [GDB Tutorial - A Walkthrough with Examples](https://www.cs.umd.edu/~srhuang/teaching/cmsc212/gdb-tutorial-handout.pdf)
* [GDB Command Reference](https://visualgdb.com/gdbreference/commands/)
* [《100个gdb小技巧》](https://wizardforcel.gitbooks.io/100-gdb-tips/content/break-on-linenum.html)
* [gdb 调试coredump文件中烂掉的栈帧的方法](https://blog.csdn.net/muclenerd/article/details/48005171)
* [GDB corrupted stack frame - How to debug?](https://stackoverflow.com/questions/9809810/gdb-corrupted-stack-frame-how-to-debug)
* [追core笔记之五：如何查看一个corrupt stack的core](https://izualzhy.cn/why-the-code-stack-is-overflow)
* [gdb 调试coredump文件中烂掉的栈帧的方法](https://blog.csdn.net/muclenerd/article/details/48005171)
* [How do you set GDB debug flag with cmake?](https://stackoverflow.com/questions/10005982/how-do-you-set-gdb-debug-flag-with-cmake)
* [GDB info registers command - Second column of output](https://stackoverflow.com/questions/31026000/gdb-info-registers-command-second-column-of-output)