---
title: Assembly-Language
date: 2021-10-15 16:17:52
tags: 
- 原创
categories: 
- Assembly
---

**阅读更多**

<!--more-->

# 1 Intel and AT&T Syntax

**汇编语言有2种不同的语法，分别是`Intel Syntax`以及`AT&T Syntax`。它们在形式上大致相同，但是在细节上存在很大差异。极易混淆**

|  | Intel | AT&T |
|:--|:--|:--|
| 注释 | `;` | `#` |
| 指令 | 无后缀，例如`add` | 有后缀，会带上操作数的类型大小，例如`addq` |
| 寄存器 | `eax`、`ebx`等等 | `%eax`、`%ebx`等等 |
| 立即数 | `0x100` | `$0x100` |
| 直接寻址 | `[eax]` | `(%eax)` |
| 间接寻址 | `[base + reg + reg * scale + displacement]` | `displacement(reg, reg, scale)` |

## 1.1 内存引用

**`Intel Syntax`的间接内存引用的格式为：`section:[base + index*scale + displacement]`**
**`AT&T Syntax`的间接内存引用的格式为：section:displacement(base, index, scale)**

* 其中，`base`和`index`是任意的`32-bit`的`base`和`index`寄存器
* `scale`可以取值`1`，`2`，`4`，`8`。如果不指定`scale`值，则默认值为`1`
* `section`可以指定任意的段寄存器作为段前缀，默认的段寄存器在不同的情况下不一样

**一些例子：**

1. `-4(%ebp)`
    * `base`：`%ebp`
    * `displacement`：`-4`
    * `section`：未指定
    * `index`：未指定，默认为0
    * `scale`：未指定，默认为1

# 2 指令

**`Intel Syntax`语法的特点如下：**

```
助记符 目的操作数 源操作数
```

**`AT&T Syntax`语法的特点如下：**

```
助记符 源操作数 目的操作数
```

**下面以`AT&T Syntax`的形式列出常用的指令**

**数据传送指令：**

| 指令格式 | 描述 |
|:--|:--|
| `movl src, dst` | 传双字 |
| `movw src, dst` | 传单字 |
| `movb src, dst` | 传字节 |
| `movsbl src, dst` | 对`src`（字节）进行符号位填充，变为`dst`（双字） |
| `movzbl src, dst` | 对`src`（字节）进行零填充，变为`dst`（双字） |
| `pushl src` | 压栈</br>`R[%esp] -= 4`</br>`M[R[%esp]] = src` |
| `popl dst` | 出栈</br>`dst = M[R[%esp]]`</br>`R[%esp] += 4` |
| `xchg mem/reg mem/reg` | 交换两个寄存器或者交换寄存器和内存之间的内容（至少有一个是寄存器）</br>两个操作数的数据类型要相同，比如一个是字节另一个也得是字节 |

**算数和逻辑操作指令：**

| 指令格式 | 描述 |
|:--|:--|
| `leal src, dst` | `dst = &src`，`dst`只能是寄存器 |
| `incl dst` | `dst += 1` |
| `decl dst` | `dst -= 1` |
| `negl dst` | `dst = -dst` |
| `notl dst` | `dst = ~dst` |
| `addl src, dst` | `dst += src` |
| `subl src, dst` | `dst -= src` |
| `imull src, dst` | `dst *= src` |
| `xorl src, dst` | `dst ^= src` |
| `orl src, dst` | `dst |= src` |
| `andl src, dst` | `dst &= src` |
| `sall k dst` | `dst << k` |
| `shll k dst` | `dst << k`（同`sall`） |
| `sarl k dst` | `dst >> k` |
| `shrl k dst` | `dst >> k`（同`sarl`） |

**比较指令：**

| 指令格式 | 描述 |
|:--|:--|
| `cmpb s1, s2` | `s2 - s1`，比较字节，差关系 |
| `testb s1, s2` | `s2 & s1`，比较字节，与关系 |
| `cmpw s1, s2` | `s2 - s1`，比较字，差关系 |
| `testw s1, s2` | `s2 & s1`，比较字，与关系 |
| `cmpl s1, s2` | `s2 - s1`，比较双字，差关系 |
| `testl s1, s2` | `s2 & s1`，比较双字，与关系 |

**跳转指令：**

| 指令格式 | 描述 |
|:--|:--|
| `jmp label` | 直接跳转 |
| `jmp *operand` | 间接跳转 |
| `je label` | 相等跳转 |
| `jne label` | 不相等跳转 |
| `jz label` | 零跳转 |
| `jnz label` | 非零跳转 |
| `js label` | 负数跳转 |
| `jns label` | 非负跳转 |
| `jg label` | 大于跳转 |
| `jnle label` | 大于跳转 |
| `jge label` | 大于等于跳转 |
| `jnl label` | 大于等于跳转 |
| `jl label` | 小于跳转 |
| `jnge label` | 小于跳转 |
| `jle label` | 小于等于跳转 |
| `jng label` | 小于等于跳转 |

**`SIMD`相关指令集**

* [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions)
* [一文读懂SIMD指令集 目前最全SSE/AVX介绍](https://blog.csdn.net/qq_32916805/article/details/117637192)
* ![simd](/images/Assembly-Language/simd.png)
* 指令级

| 指令集 | 描述 |
|:--|:--|
| `MMX` | 新增8个64位的向量寄存器`MM0`到`MM7` |
| `SSE` | 在`MMX`基础上，新增8个128位的向量寄存器`XMM0`到`XMM7`。仅支持128位的浮点 |
| `SSE2` | 支持128位的整型 |
| `SSE3` |  |
| `SSSE3` |  |
| `SSE4.1` |  |
| `SSE4.2` |  |
| `AVX` | 新增了16个256位的向量寄存器`YMM0`到`YMM15`。浮点支持256位，整型只支持128位 |
| `AVX2` | 整型也支持256位 |
| `AVX512` | 新增32个512位的向量寄存器`ZMM0`到`ZMM31` |

* 数据类型

| 数据类型 | 描述 |
|:--|:--|
| `__m128` | 包含4个float类型数字的向量 |
| `__m128d` | 包含2个double类型数字的向量 |
| `__m128i` | 包含若干个整型数字的向量 |
| `__m256` | 包含8个float类型数字的向量 |
| `__m256d` | 包含4个double类型数字的向量 |
| `__m256i` | 包含若干个整型数字的向量 |

**其他：**

| 指令 | 描述 |
|:--|:--|
| `enter size, nesting level` | 准备当前栈帧，其中`nesting level`范围是`0-31`，表示了从前一帧复制到新栈帧中的栈帧指针的数量，通常是`0`。`enter $size, $0`等效于`push %rbp` + `mov %rsp, %rbp` + `sub $size, %rsp` |
| `leave` | 恢复上级栈帧，等效于`mov %rbp, %rsp`、`pop %rbp` |
| `ret` | 函数调用后返回 |
| `cli` | 关中断，ring0 |
| `sti` | 开中断，ring0 |
| `lgdt src` | 加载全局描述符 |
| `lidt src` | 加载中断描述符 |
| `cmov` | Conditional move instructions，用于消除分支 |

## 2.1 如何查指令

* [x86 and amd64 instruction reference](https://www.felixcloutier.com/x86/)
* [汇编语言在线帮助](https://sites.google.com/site/huibianyuyanzaixianbangzhu/)
* [X86 Opcode and Instruction Reference](http://ref.x86asm.net/)
    * [geek.html](http://ref.x86asm.net/geek.html)
* [Intel x86/x64 开发者手册 卷1](https://www.intel.cn/content/www/cn/zh/architecture-and-technology/64-ia-32-architectures-software-developer-vol-1-manual.html)
* [Intel x86/x64 开发者手册 卷2](https://www.intel.cn/content/www/cn/zh/architecture-and-technology/64-ia-32-architectures-software-developer-vol-2a-manual.html)
* [Intel® 64 and IA-32 Architectures Software Developer Manuals](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)
* [Good reference for x86 assembly instructions](https://stackoverflow.com/questions/4568848/good-reference-for-x86-assembly-instructions)
* [汇编指令速查](https://www.cnblogs.com/lsgxeva/p/8948153.html)
* [cgasm](https://github.com/bnagy/cgasm)
    ```sh
    go get github.com/bnagy/cgasm

    # 查看 GOPATH
    go env | grep GOPATH

    # 将 GOPATH 添加到环境变量 PATH 中
    export PATH=${PATH}:$(go env | grep GOPATH | awk -F '=' '{print $2}' | sed -e 's/"//g')/bin

    cgasm -f push
    ```

# 3 寄存器

**更多内容请参考{% post_link SystemArchitecture-Register %}**

| 64-bit register | Lower 32 bits | Lower 16 bits | Lower 8 bits |
|:--|:--|:--|:--|
| rax | eax | ax | al |
| rbx | ebx | bx | bl |
| rcx | ecx | cx | cl |
| rdx | edx | dx | dl |
| rsi | esi | si | sil |
| rdi | edi | di | dil |
| rbp | ebp | bp | bpl |
| rsp | esp | sp | spl |
| rip | eip | ? | ? |
| r8 | r8d | r8w | r8b |
| r9 | r9d | r9w | r9b |
| r10 | r10d | r10w | r10b |
| r11 | r11d | r11w | r11b |
| r12 | r12d | r12w | r12b |
| r13 | r13d | r13w | r13b |
| r14 | r14d | r14w | r14b |
| r15 | r15d | r15w | r15b |

**其中，`rbp`是基址指针寄存器，指向栈底；`rsp`是栈指针寄存器，指向栈顶；`rip`是指令指针寄存器，指向下一个待执行的指令**

**向量化相关寄存器（参考[Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions)）**

| 寄存器名 | 位数 |
|:--|:--|
| xmm | 128 |
| ymm | 256 |
| zmm | 512 |

# 4 汇编语法

**参考：**

* [x86 Assembly](https://en.wikibooks.org/wiki/X86_Assembly)
    * [x86 Assembly/GNU assembly syntax](https://en.wikibooks.org/wiki/X86_Assembly/GNU_assembly_syntax)
    * [x86 Assembly/NASM Syntax](https://en.wikibooks.org/wiki/X86_Assembly/NASM_Syntax)
* [AT&T汇编教程](http://ted.is-programmer.com/posts/5250.html)
    * [AT&T汇编语法](http://ted.is-programmer.com/posts/5251.html)
    * [Linux 汇编语言开发指南](http://ted.is-programmer.com/posts/5254.html)
    * [AT&T汇编指令](http://ted.is-programmer.com/posts/5262.html)
    * [AT＆T汇编伪指令](http://ted.is-programmer.com/posts/5263.html)

## 4.1 Intel Syntax

### 4.1.1 注释

```nasm
; this is comment
```

## 4.2 AT&T Syntax

### 4.2.1 汇编器命令

**汇编器命令（`Assembler Directives`）由英文句号（'.'）开头，命令名的其余是字母，通常使用小写，下面仅列出一些常见的命令**

| 命令 | 描述 |
|:--|:--|
| `.abort` | 本命令立即终止汇编过程。这是为了兼容其它的汇编器。早期的想法是汇编语言的源码会被输送进汇编器。如果发送源码的程序要退出，它可以使用本命令通知as退出。将来可能不再支持使用`.abort` |
| `.align abs-expr, abs-expr, abs-expr` | 增加位置计数器（在当前的子段）使它指向规定的存储边界。第一个表达式参数（必须）表示边界基准；第二个表达式参数表示填充字节的值，用这个值填充位置计数器越过的地方；第三个表达式参数（可选）表示本对齐命令允许越过字节数的最大值 |
| `.ascii "str"...` | `.ascii`可不带参数或者带多个由逗点分开的字符串。它把汇编好的每个字符串（在字符串末不自动追加零字节）存入连续的地址 |
| `.asciz "str"...` | `.asciz`类似与`.ascii`，但在每个字符串末自动追加一个零字节 |
| `.byte` | `.byte`可不带参数或者带多个表达式参数，表达式之间由逗点分隔。每个表达式参数都被汇编成下一个字节 |
| `.data subsection` | `.data`通知as汇编后续语句，将它们追加在编号为`subsection`（`subsection`必须是纯粹的表达式）数据段末。如果参数`subsection`省略，则默认是0 |
| `.def name` | 开始定义符号`name`的调试信息，定义区延伸至遇到`.endef`命令 |
| `.end` | `.end`标记着汇编文件的结束。as不处理`.end`命令后的任何语句 |
| `.err` | 如果as汇编一条`.err`命令，将打印一条错误信息 |
| `.float flonums` | 汇编0个或多个浮点数，浮点数之间由逗号分隔 |
| `.global symbol` | `.global`使符号symbol对连接器ld可见 |
| `.int intnums` | 汇编0个或多个整数，整数数之间由逗号分隔 |
| `.long` | 同`.int` |
| `.macro` | `.macro`和`.endm`用于定义宏，宏可以用来生成汇编输出 |
| `.quad bignums` | 汇编0个或多个长整数，长整数之间由逗号分隔 |
| `.section name` | 使用`.section`命令将后续的代码汇编进一个定名为name的段 |
| `.short shortnums` |  汇编0个或多个短整数，短整数之间由逗号分隔 |
| `.single flonums` | 同`.float` |
| `.size` | 本命令一般由编译器生成，以在符号表中加入辅助调试信息 |
| `.string "str"` | 将参数str中的字符复制到目标文件中去。您可以指定多个字符串进行复制，之间使用逗号分隔 |
| `.text subsection` | 通知as把后续语句汇编到编号为`subsection`的正文子段的末尾，`subsection`是一个纯粹的表达式。如果省略了参数`subsection`，则使用编号为0的子段 |
| `.title "heading"` | 当生成汇编清单时，把`heading`作为标题使用 |
| `.word` | 同`.short` |

### 4.2.2 Symbol

`Symbol`由字母下划线构成，最后跟一个冒号`:`

```
<symbol_name>:
```

### 4.2.3 注释

```nasm
/* this is comment */
```

# 5 实战

**本小节转载摘录自[不吃油条](https://www.zhihu.com/people/hackeris)针对汇编语言的系列文章**

## 5.1 准备环境

**汇编工具：**

1. **`nasm`：全称为`Netwide Assembler`，是通用的汇编器，采用`Intel Syntax`**
    * 无`PTR`关键词，因此`mov DWORD PTR [rbp-0xc], edi`要写成`mov DWORD [rbp-0xc], edi`
1. `masm`：全称为`Microsoft Macro Assembler`，是微软专门为`windows`下汇编而写的
1. **`gas`：全称为`GNU Assembler`，采用`AT&T Syntax`**

```sh
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/nasm-2.10.07-7.el7.x86_64.rpm
yum localinstall -y nasm-2.10.07-7.el7.x86_64.rpm
```

## 5.2 第一个程序

**本小节的任务：编写等效于下面cpp程序的汇编代码**

```cpp
int main() {
    return 0;
}
```

### 5.2.1 Intel版本

`first.asm`如下：

```nasm
global main

main:
    mov eax, 0
    ret
```

编译执行：

```sh
nasm -o first.o -f elf64 first.asm
gcc -o first -m64 first.o

./first; echo $?
```

### 5.2.2 AT&T版本

`first.asm`如下：

```nasm
    .text
    .globl main
main:
    mov $0, %eax
    ret
```

编译执行：

```sh
as -o first.o first.asm
gcc -o first -m64 first.o

./first; echo $?
```

## 5.3 使用内存

**本小节的任务：利用内存计算1+2的值**

### 5.3.1 Intel版本

`use_memory.asm`如下：

```nasm
global main

main:
    mov ebx, 1
    mov ecx, 2
    add ebx, ecx
    
    mov [0x233], ebx
    mov eax, [0x233]
    
    ret
```

尝试编译执行：

```sh
nasm -o use_memory.o -f elf64 use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

**结果发现`core dump`了，这是因为在Linux操作系统上，内存是受操作系统管控的，不能随便读写，可以改成如下形式：**

```nasm
global main

main:
    mov ebx, 1                  ;将ebx赋值为1
    mov ecx, 2                  ;将ecx赋值为2
    add ebx, ecx                ;ebx = ebx + ecx
    
    mov [sui_bian_xie], ebx     ; 将ebx的值保存起来
    mov eax, [sui_bian_xie]     ; 将刚才保存的值重新读取出来，放到eax中
    
    ret                         ; 返回，整个程序最后的返回值，就是eax中的值

section .data
sui_bian_xie   dw    0
```

再次尝试编译执行：

```sh
nasm -o use_memory.o -f elf64 use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

**这次的代码除了用`[sui_bian_xie]`代替内存地址外，还多出了如下两行**

* 第一行先不管是表示接下来的内容经过编译后，会放到可执行文件的数据区域，同时也会随着程序启动的时候，分配对应的内存
* 第二行就是描述真实的数据的关键所在里，这一行的意思是开辟一块4字节的空间，并且里面用0填充。这里的`dw（double word）`就表示4个字节，前面那个`sui_bian_xie`的意思就是这里可以随便写，也就是起个名字而已，方便自己写代码的时候区分，这个`sui_bian_xie`会在编译时被编译器处理成一个具体的地址，我们无需理会地址具体时多少，反正知道前后的`sui_bian_xie`指代的是同一个东西就行了

```asm
section .data
sui_bian_xie   dw    0
```

再来个例子，`use_memory2.asm`如下：

```nasm
global main

main:
    mov eax, [number_1]
    mov ebx, [number_2]
    add eax, ebx
    
    ret

section .data
number_1      dw        10
number_2      dw        20
```

编译执行：

```sh
nasm -o use_memory2.o -f elf64 use_memory2.asm
gcc -o use_memory2 -m64 use_memory2.o

./use_memory2; echo $?
```

### 5.3.2 AT&T版本

`use_memory.asm`如下：

```nasm
    .text
    .data
sui_bian_xie:
    .int 0
    .text
    .globl main
main:
    mov $1, %ebx
    mov $2, %ecx
    add %ecx, %ebx
    mov %ebx, (sui_bian_xie)
    mov (sui_bian_xie), %eax
    ret
```

编译执行：

```sh
as -o use_memory.o use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

`use_memory2.asm`如下：

```nasm
    .text
    .data
number_1:
    .int 10
number_2:
    .int 20
    .text
    .globl main
main:
    mov (number_1), %eax
    mov (number_2), %ebx
    add %ebx, %eax
    ret
```

编译执行：

```sh
as -o use_memory2.o use_memory2.asm
gcc -o use_memory2 -m64 use_memory2.o

./use_memory2; echo $?
```

## 5.4 翻译第一个C语言程序

对于如下`C`程序

```cpp
int x = 0;
int y = 0;
int z = 0;

int main() {
    x = 2;
    y = 3;
    z = x + y;
    return z;
}
```

### 5.4.1 Intel版本

`first_c.asm`如下：

```nasm
global main

main:
    mov eax, 2
    mov [x], eax
    mov eax, 3
    mov [y], eax
    mov eax, [x]
    mov ebx, [y]
    add eax, ebx
    mov [z], eax
    mov eax, [z]
    ret

section .data
x       dw      0
y       dw      0
z       dw      0
```

编译执行：

```sh
nasm -o first_c.o -f elf64 first_c.asm
gcc -o first_c -m64 first_c.o

./first_c; echo $?
```

### 5.4.2 AT&T版本

`first_c.asm`如下：

```nasm
    .text
    .data
x:
    .int 0
y:
    .int 0
z:
    .int 0
    .text
    .globl main
main:
    mov $2, %eax
    mov %eax, (x)
    mov $3, %eax
    mov %eax, (y)
    mov (x), %eax
    mov (y), %ebx
    add %ebx, %eax
    mov %eax, (z)
    mov (z), %eax
    ret
```

编译执行：

```sh
as -o first_c.o first_c.asm
gcc -o first_c -m64 first_c.o

./first_c; echo $?
```

## 5.5 翻译C语言if语句

对于如下`C`程序

```cpp
int main() {
    int a = 50;
    if (a > 10) {
        a = a - 10;
    }
    return a;
}
```

### 5.5.1 Intel版本

`if_c.asm`如下：

```nasm
global main

main:
    mov eax, 50
    cmp eax, 10             ; 对eax和10进行比较
    jle xiaoyu_dengyu_shi   ; 小于或等于的时候跳转
    sub eax, 10
xiaoyu_dengyu_shi:
    ret
```

编译执行：

```sh
nasm -o if_c.o -f elf64 if_c.asm
gcc -o if_c -m64 if_c.o

./if_c; echo $?
```

### 5.5.2 AT&T版本

`if_c.asm`如下：

```nasm
    .text
    .globl main
main:
    mov $50, %eax
    cmp $10, %eax
    jle xiaoyu_dengyu_shi
    sub $10, %eax
xiaoyu_dengyu_shi:
    ret
```

编译执行：

```sh
as -o if_c.o if_c.asm
gcc -o if_c -m64 if_c.o

./if_c; echo $?
```

## 5.6 翻译C语言循环语句

对于如下`C`程序

```cpp
int main() {
    int sum = 0;
    int i = 1;
    while (i <= 10) {
        sum = sum + i;
        i = i + 1;
    }
    return sum;
}
```

或者`for`版本，如下

```cpp
int main() {
    int sum = 0;
    for (int i = 1; i <= 10; i++) {
        sum = sum + i;
    }
    return sum;
}
```

上述两种循环的写法，经过简单调整，便可以得到如下等价的程序：

```cpp
int main() {
    int sum = 0;
    int i = 1;
loop:
    if (i <= 10) {
        sum = sum + i;
        i = i + 1;
        goto loop;
    }
    return sum;
}
```

### 5.6.1 Intel版本

`loop_c.asm`如下：

```nasm
global main:

main:
    mov eax, 0
    mov ebx, 1
loop:
    cmp ebx, 10
    jg end
    add eax, ebx
    add ebx, 1
    jmp loop
end:
    ret
```

编译执行：

```sh
nasm -o loop_c.o -f elf64 loop_c.asm
gcc -o loop_c -m64 loop_c.o

./loop_c; echo $?
```

### 5.6.2 AT&T版本

`loop_c.asm`如下：

```nasm
    .text
    .globl main
main:
    mov $0, %eax
    mov $1, %ebx
loop:
    cmp $10, %ebx
    jg end
    add %ebx, %eax
    add $1, %ebx
    jmp loop
end:
    ret
```

编译执行：

```sh
as -o loop_c.o loop_c.asm
gcc -o loop_c -m64 loop_c.o

./loop_c; echo $?
```

## 5.7 翻译C语言函数调用

```cpp
int fibonacci(int num) {
    if (num == 0 || num == 1) {
        return 1;
    }
    return fibonacci(num - 1) + fibonacci(num - 2);
}

int main() {
    return fibonacci(10);
}
```

为了方便转成汇编，将上述程序改写成如下的等价程序：

```cpp
int fibonacci(int num) {
    if (num == 0) {
        return 1;
    }

    if (num == 1) {
        return 1;
    }

    int left = fibonacci(num - 1);
    int right = fibonacci(num - 2);
    return left + right;
}

int main() {
    return fibonacci(10);
}
```

**由于寄存器是个全局资源，为了实现递归调用，在调用前，必须将当前函数使用到的寄存器挨个存入栈中，调用返回后，再将寄存器恢复回来。涉及到的指令包括：**

* `call`：触发函数调用
* `ret`：返回
* `push`：压栈
* `pop`：弹栈
* `rsp`：栈顶指针
* `rbp`：栈底指针

### 5.7.1 Intel版本

`fibonacci_c.asm`如下：

```nasm
global main:

main:
    mov edi, 0xa
    call fibonacci
    ret

fibonacci:
    push rbp                        ; 保存上一级的栈底指针
    mov rbp, rsp                    ; 上个函数的栈顶指针作为当前函数的栈底指针
    sub rsp, 0xc                    ; 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节
    mov DWORD [rbp-0xc], edi        ; 将入参存到 [rbp-0xc] 位置，(rbp-0x8, rbp-0xc]
    cmp DWORD [rbp-0xc], 0x0        ; if (num == 0)
    je plain_case
    cmp DWORD [rbp-0xc], 0x1        ; if (num ==1 )
    je plain_case
    mov eax, DWORD [rbp-0xc]
    sub eax, 0x1                    ; num - 1
    mov edi, eax                    ; 将入参 num - 1 保存到 edi 中
    call fibonacci
    mov DWORD [rbp-0x4], eax        ; 将 fibonacci(num - 1) 的结果保存到 [rbp-0x4] 位置，(rbp-0x0, rbp-0x4]
    mov eax, DWORD [rbp-0xc]
    sub eax, 0x2                    ; num - 2
    mov edi, eax                    ; 将入参 num - 1 保存到 edi 中
    call fibonacci
    mov DWORD [rbp-0x8], eax        ; 将 fibonacci(num - 2) 的结果保存到 [rbp-0x8] 位置，(rbp-0x4, rbp-0x8]
    mov edx, DWORD [rbp-0x4]
    mov eax, DWORD [rbp-0x8]
    add eax, edx
    mov rsp, rbp                    ; 恢复 rsp
    pop rbp                         ; 恢复 rbp
    ret

plain_case:
    mov eax, 0x1
    mov rsp, rbp                    ; 恢复 rsp
    pop rbp                         ; 恢复 rbp
    ret
```

编译执行：

```sh
nasm -o fibonacci_c.o -f elf64 fibonacci_c.asm
gcc -o fibonacci_c -m64 fibonacci_c.o

./fibonacci_c; echo $?
```

其中，准备当前栈帧和恢复上级栈帧可以替换为`enter`以及`leave`

```nasm
    push rbp                        ; 保存上一级的栈底指针
    mov rbp, rsp                    ; 上个函数的栈顶指针作为当前函数的栈底指针
    sub rsp, 0xc                    ; 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节

    mov rsp, rbp                    ; 恢复 rsp
    pop rbp                         ; 恢复 rbp
```

可以替换为

```nasm
    enter 0xc, 0x0

    leave
```

### 5.7.2 AT&T版本

`fibonacci_c.asm`如下：

```nasm
    .text
    .globl main
main:
    mov $0xa, %edi 
    call fibonacci
    ret

fibonacci:
    push %rbp                       # 保存上一级的栈底指针
    mov %rsp, %rbp                  # 上个函数的栈顶指针作为当前函数的栈底指针
    sub $0xc, %rsp                  # 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节
    mov %edi, -0xc(%rbp)            # 将入参存到 -0xc(%rbp) 位置，(-0x8(%rbp), -0xc(%rbp)]
    cmp $0x0, -0xc(%rbp)            # if (num == 0)
    je plain_case
    cmp $0x1, -0xc(%rbp)            # if (num ==1 )
    je plain_case
    mov -0xc(%rbp), %eax 
    sub $0x1, %eax                  # num - 1
    mov %eax, %edi                  # 将入参 num - 1 保存到 edi 中
    call fibonacci
    mov %eax, -0x4(%rbp)            # 将 fibonacci(num - 1) 的结果保存到 -0x4(%rbp) 位置，(-0x0(%rbp), -0x4(%rbp)]
    mov -0xc(%rbp), %eax 
    sub $0x2, %eax                  # num - 2
    mov %eax, %edi                  # 将入参 num - 1 保存到 edi 中
    call fibonacci
    mov %eax, -0x8(%rbp)            # 将 fibonacci(num - 2) 的结果保存到 -0x8(%rbp) 位置，(-0x4(%rbp), -0x8(%rbp)]
    mov -0x4(%rbp), %edx
    mov -0x8(%rbp), %eax 
    add %edx, %eax 
    mov %rbp, %rsp                  # 恢复 rsp
    pop %rbp                        # 恢复 rbp
    ret

plain_case:
    mov $0x1, %eax 
    mov %rbp, %rsp                  # 恢复 rsp
    pop %rbp                        # 恢复 rbp
    ret
```

编译执行：

```sh
as -o fibonacci_c.o fibonacci_c.asm
gcc -o fibonacci_c -m64 fibonacci_c.o

./fibonacci_c; echo $?
```

其中，准备当前栈帧和恢复上级栈帧可以替换为`enter`以及`leave`

```nasm
    push %rbp                       # 保存上一级的栈底指针
    mov %rsp, %rbp                  # 上个函数的栈顶指针作为当前函数的栈底指针
    sub $0xc, %rsp                  # 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节

    mov %rbp, %rsp                  # 恢复 rsp
    pop %rbp                        # 恢复 rbp
```

可以替换为

```nasm
    enter $0xc, $0x0

    leave
```

# 6 Tips

## 6.1 如何生成易读的汇编

**方式1：（并不容易看懂）**

```sh
# 生成汇编
gcc main.cpp -S -g -fverbose-asm

# 查看汇编
cat main.s
```

**方式2：**

```sh
# 生成目标文件
gcc main.cpp -c -g

# 反汇编（AT&T Syntax)
# -d: 仅显式可执行部分的汇编
# -r: 在重定位时显示符号名称
# -w: 以多于 80 列的宽度对输出进行格式化
# -C: 对修饰过的 (mangled) 符号名进行解码
# -S: 将源代码与反汇编混合在一起，便于阅读
objdump -drwCS main.o

# 反汇编（Intel Syntax）
objdump -drwCS -M intel main.o
```

# 7 参考

* [Assembly Programming Tutorial](https://www.tutorialspoint.com/assembly_programming/index.htm)
* [x86 instruction listings](https://en.wikipedia.org/wiki/X86_instruction_listings)
* [汇编语言入门一：环境准备](https://zhuanlan.zhihu.com/p/23618489)
* [汇编语言入门二：环境有了先过把瘾](https://zhuanlan.zhihu.com/p/23639191)
* [汇编语言入门三：是时候上内存了](https://zhuanlan.zhihu.com/p/23722940)
* [汇编语言入门四：打通C和汇编语言](https://zhuanlan.zhihu.com/p/23779935)
* [汇编语言入门五：流程控制（一）](https://zhuanlan.zhihu.com/p/23845369)
* [汇编语言入门六：流程控制（二）](https://zhuanlan.zhihu.com/p/23902265)
* [汇编语言入门七：函数调用（一）](https://zhuanlan.zhihu.com/p/24129384)
* [汇编语言入门八：函数调用（二）](https://zhuanlan.zhihu.com/p/24265088)
* [汇编语言入门九：总结与后续（闲扯）](https://zhuanlan.zhihu.com/p/24424432)
* [What is the difference between "mov (%rax),%eax" and "mov %rax,%eax"?](https://stackoverflow.com/questions/41232333/what-is-the-difference-between-mov-rax-eax-and-mov-rax-eax)
* [Using GCC to produce readable assembly?](https://stackoverflow.com/questions/1289881/using-gcc-to-produce-readable-assembly)
* [汇编语言入门教程：汇编语言程序设计指南（精讲版）](http://c.biancheng.net/asm/)
* [AT&T ASM Syntax详解](https://blog.csdn.net/opendba/article/details/6104485)
* [汇编语言--x86汇编指令集大全](https://zhuanlan.zhihu.com/p/53394807)
* [x86 Assembly Guide](https://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html)