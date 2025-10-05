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

**Assembly language has 2 different syntaxes, namely `Intel Syntax` and `AT&T Syntax`. They are roughly similar in form, but there are significant differences in detail. Very easy to confuse.**

|  | Intel | AT&T |
|:--|:--|:--|
| Comment | `;` | `#` |
| Instruction | No suffix, e.g., `add` | With suffix, indicating operand size, e.g., `addq` |
| Register | `eax`, `ebx`, etc. | `%eax`, `%ebx`, etc. |
| Immediate Value | `0x100` | `$0x100` |
| Direct Addressing | `[eax]` | `(%eax)` |
| Indirect Addressing | `[base + reg + reg * scale + displacement]` | `displacement(base, reg, scale)` |

## 1.1 Memory Reference

**The format for indirect memory reference in `Intel Syntax` is: `section:[base + index*scale + displacement]`**
**The format for indirect memory reference in `AT&T Syntax` is: section:displacement(base, index, scale)**

* Here, `base` and `index` are any `32-bit` `base` and `index` registers.
* `scale` can be `1`, `2`, `4`, or `8`. If the `scale` is not specified, the default value is `1`.
* `section` can specify any segment register as the segment prefix. The default segment register varies depending on the situation.

**Some examples:**

1. `-4(%ebp)`
    * `base`: `%ebp`
    * `displacement`: `-4`
    * `section`: not specified
    * `index`: not specified, defaults to 0
    * `scale`: not specified, defaults to 1

# 2 Instructions

**The characteristics of the `Intel Syntax` are as follows:**

```
mnemonic DestinationOperand sourceOperand
```

**The characteristics of the `AT&T Syntax` are as follows:**

```
mnemonic SourceOperand DestinationOperand
```

**Below are common instructions in the form of `AT&T Syntax`:**

**Data Transfer Instructions:**

| Instruction Format | Description |
|:--|:--|
| `movl src, dst` | Transfer doubleword |
| `movw src, dst` | Transfer word |
| `movb src, dst` | Transfer byte |
| `movsbl src, dst` | Sign-extend `src` (byte) to `dst` (doubleword) |
| `movzbl src, dst` | Zero-extend `src` (byte) to `dst` (doubleword) |
| `pushl src` | Push</br>`R[%esp] -= 4`</br>`M[R[%esp]] = src` |
| `popl dst` | Pop</br>`dst = M[R[%esp]]`</br>`R[%esp] += 4` |
| `xchg mem/reg mem/reg` | Exchange the contents between two registers or between a register and memory (at least one must be a register)</br>Both operands must be of the same data type, e.g., if one is byte, the other must be byte |
| `lea src, dst` | Load Effective Address DoubleWords, the instruction computes the effective address of a memory location and then places this address into a specified general-purpose register.|
| `leaq src, dst` | Load Effective Address Quadwords, similar to lea. |

**Arithmetic and Logical Operations Instructions:**

| Instruction Format | Description |
|:--|:--|
| `leal src, dst` | `dst = &src`, `dst` can only be a register |
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
| `shll k dst` | `dst << k` (same as `sall`) |
| `sarl k dst` | `dst >> k` |
| `shrl k dst` | `dst >> k` (same as `sarl`) |

**Comparison Instructions:**

| Instruction Format | Description |
|:--|:--|
| `cmpb s1, s2` | `s2 - s1`, compare byte, difference relationship |
| `testb s1, s2` | `s2 & s1`, compare byte, and relationship |
| `cmpw s1, s2` | `s2 - s1`, compare word, difference relationship |
| `testw s1, s2` | `s2 & s1`, compare word, and relationship |
| `cmpl s1, s2` | `s2 - s1`, compare doubleword, difference relationship |
| `testl s1, s2` | `s2 & s1`, compare doubleword, and relationship |

**Jump Instructions:**

| Instruction Format | Description |
|:--|:--|
| `jmp label` | Direct jump |
| `jmp *operand` | Indirect jump |
| `je label` | Jump if equal |
| `jne label` | Jump if not equal |
| `jz label` | Jump if zero |
| `jnz label` | Jump if not zero |
| `js label` | Jump if negative |
| `jns label` | Jump if not negative |
| `jg label` | Jump if greater |
| `jnle label` | Jump if greater |
| `jge label` | Jump if greater or equal |
| `jnl label` | Jump if greater or equal |
| `jl label` | Jump if less |
| `jnge label` | Jump if less |
| `jle label` | Jump if less or equal |
| `jng label` | Jump if less or equal |

**`SIMD`-related Instruction Set**

* [Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions)
* [一文读懂SIMD指令集 目前最全SSE/AVX介绍](https://blog.csdn.net/qq_32916805/article/details/117637192)
* ![simd](/images/Assembly-Language/simd.png)
* Instruction Sets

| Instruction Set | Description |
|:--|:--|
| `MMX` | Introduced 8 new 64-bit vector registers `MM0` to `MM7` |
| `SSE` | Building on `MMX`, introduced 8 new 128-bit vector registers `XMM0` to `XMM7`. Only supports 128-bit floating point |
| `SSE2` | Supports 128-bit integer |
| `SSE3` |  |
| `SSSE3` |  |
| `SSE4.1` |  |
| `SSE4.2` |  |
| `AVX` | Introduced 16 new 256-bit vector registers `YMM0` to `YMM15`. Floating point supports 256-bit, while integer only supports 128-bit |
| `AVX2` | Integer now also supports 256-bit |
| `AVX512` | Introduced 32 new 512-bit vector registers `ZMM0` to `ZMM31` |

* Data Types

| Data Type | Description |
|:--|:--|
| `__m128` | Vector containing 4 float numbers |
| `__m128d` | Vector containing 2 double numbers |
| `__m128i` | Vector containing several integer numbers |
| `__m256` | Vector containing 8 float numbers |
| `__m256d` | Vector containing 4 double numbers |
| `__m256i` | Vector containing several integer numbers |

**Others:**

| Instruction | Description |
|:--|:--|
| `enter size, nesting level` | Prepares the current stack frame. Where `nesting level` ranges from `0-31` which indicates the number of stack frame pointers copied from the previous frame to the new frame, typically `0`. `enter $size, $0` is equivalent to `push %rbp` + `mov %rsp, %rbp` + `sub $size, %rsp` |
| `leave` | Restores the previous stack frame, equivalent to `mov %rbp, %rsp`, `pop %rbp` |
| `ret` | Returns after a function call |
| `cli` | Disables interrupts, ring0 |
| `sti` | Enables interrupts, ring0 |
| `lgdt src` | Loads the global descriptor |
| `lidt src` | Loads the interrupt descriptor |
| `cmov` | Conditional move instructions, used to eliminate branching |

## 2.1 How to Check Instructions

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

## 2.2 Memory Barriers

In the `x86` architecture, there are several assembly instructions that can serve as memory barriers. Their role is to ensure that the order of memory accesses is not reordered, thereby ensuring the correctness and reliability of the program. These instructions include:

* `MFENCE`: All memory accesses before the execution of the `MFENCE` instruction must complete before the `MFENCE` instruction, and all memory accesses after the `MFENCE` instruction must start after the execution of the `MFENCE` instruction. This instruction acts as a full barrier, meaning it prevents all memory accesses on all processors.
* `SFENCE`: `SFENCE` ensures that all write operations before its execution have been committed to memory. Any write operations after the `SFENCE` instruction cannot be reordered to occur before the `SFENCE` instruction.
* `LFENCE`: `LFENCE` ensures that all read operations prior to its execution are complete. Any read operations after the `LFENCE` instruction cannot be reordered to happen before the `LFENCE` instruction.
* `LOCK` instruction prefix: The `LOCK` prefix can be applied to specific instructions, such as `LOCK ADD`, `LOCK DEC`, `LOCK XCHG`, etc. They guarantee that when executing an instruction with the `LOCK` prefix, access to shared memory is serialized.

# 3 Register

**For more information, please refer to{% post_link System-Architecture-Register %}**

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

**In this context, `rbp` is the base pointer register pointing to the bottom of the stack; `rsp` is the stack pointer register pointing to the top of the stack; `rip` is the instruction pointer register pointing to the next instruction to be executed.**

**Vector-related Registers (Refert to[Advanced Vector Extensions](https://en.wikipedia.org/wiki/Advanced_Vector_Extensions))**

| Register Name | Bit Size |
|:--|:--|
| xmm | 128 |
| ymm | 256 |
| zmm | 512 |

## 3.1 The registers used for parameters

The specific register used to store function parameters depends on the architecture and the calling convention being used. I'll provide details for the x86-64 architecture using the System V AMD64 ABI calling convention, which is common for Unix-like systems (including Linux).

For the x86-64 System V AMD64 ABI:

1. First parameter: `%rdi`
1. Second parameter: `%rsi`
1. Third parameter: `%rdx`
1. Fourth parameter: `%rcx`
1. Fifth parameter: `%r8`
1. Sixth parameter: `%r9`
1. Seventh parameter: Placed on the stack.
1. Eighth parameter: Placed on the stack after the seventh parameter.
1. ... and so on.

# 4 Assembly Syntax

**Reference:**

* [x86 Assembly](https://en.wikibooks.org/wiki/X86_Assembly)
    * [x86 Assembly/GNU assembly syntax](https://en.wikibooks.org/wiki/X86_Assembly/GNU_assembly_syntax)
    * [x86 Assembly/NASM Syntax](https://en.wikibooks.org/wiki/X86_Assembly/NASM_Syntax)
* [AT&T汇编教程](http://ted.is-programmer.com/posts/5250.html)
    * [AT&T汇编语法](http://ted.is-programmer.com/posts/5251.html)
    * [Linux 汇编语言开发指南](http://ted.is-programmer.com/posts/5254.html)
    * [AT&T汇编指令](http://ted.is-programmer.com/posts/5262.html)
    * [AT＆T汇编伪指令](http://ted.is-programmer.com/posts/5263.html)

## 4.1 Intel Syntax

### 4.1.1 Comment

```nasm
; this is comment
```

## 4.2 AT&T Syntax

### 4.2.1 Assembler Commands

**Assembler directives (`Assembler Directives`) start with an English period ('.') followed by letters for the rest of the command name. Typically, these are in lowercase. Below are some common commands:**

| Command | Description |
|:--|:--|
| `.abort` | This command immediately terminates the assembly process. This is for compatibility with other assemblers. The initial idea was that the assembly language source would be fed into the assembler. If the program sending the source wanted to exit, it could use this command to notify `as` to exit. Use of `.abort` might not be supported in the future. |
| `.align abs-expr, abs-expr, abs-expr` | Increase the position counter (in the current subsection) to point to the specified storage boundary. The first expression argument (mandatory) represents the boundary base; the second expression argument represents the value of the filler byte, which is used to fill places passed by the position counter; the third expression argument (optional) indicates the maximum number of bytes this alignment command is allowed to cross. |
| `.ascii "str"...` | `.ascii` can have no arguments or several strings separated by commas. It saves each assembled string (without automatically appending a null byte at the end) in consecutive addresses. |
| `.asciz "str"...` | `.asciz` is similar to `.ascii`, but it automatically appends a null byte at the end of each string. |
| `.byte` | `.byte` can have no arguments or multiple expression arguments separated by commas. Each expression argument is assembled into the next byte. |
| `.data subsection` | `.data` informs `as` to append subsequent statements to the data section ending in `subsection` (which must be a pure expression). If the `subsection` argument is omitted, the default is 0. |
| `.def name` | Starts defining debug information for the symbol `name`. The definition area extends to the `.endef` command encountered. |
| `.end` | `.end` marks the end of the assembly file. `as` doesn't process any statements after the `.end` command. |
| `.err` | If `as` assembles a `.err` command, it will print an error message. |
| `.float flonums` | Assemble 0 or more floating point numbers, separated by commas. |
| `.global symbol` | `.global` makes the symbol `symbol` visible to the linker `ld`. |
| `.int intnums` | Assemble 0 or more integers, separated by commas. |
| `.long` | Same as `.int`. |
| `.macro` | `.macro` and `.endm` are used to define macros. Macros can be used to generate assembly output. |
| `.quad bignums` | Assemble 0 or more long integers, separated by commas. |
| `.section name` | The `.section` command assembles subsequent code into a segment named `name`. |
| `.short shortnums` | Assemble 0 or more short integers, separated by commas. |
| `.single flonums` | Same as `.float`. |
| `.size` | This command is usually generated by compilers to add auxiliary debugging information in the symbol table. |
| `.string "str"` | Copies characters from the argument `str` into the target file. Multiple strings can be specified for copying, separated by commas. |
| `.text subsection` | Instructs `as` to assemble subsequent statements to the end of the text subsection identified by `subsection`, which is a pure expression. If the `subsection` argument is omitted, the default subsection is 0. |
| `.title "heading"` | When generating an assembly listing, use `heading` as the title. |
| `.word` | Same as `.short`. |

### 4.2.2 Symbol

A `Symbol` is composed of letters and underscores, ending with a colon `:`.

```
<symbol_name>:
```

### 4.2.3 Comment

```nasm
/* this is comment */
```

# 5 Practical Application

**本小节转载摘录自[不吃油条](https://www.zhihu.com/people/hackeris)针对汇编语言的系列文章**

## 5.1 Setting Up the Environment

**Assembly Tools:**

1. **`nasm`: Stands for `Netwide Assembler`. It's a generic assembler that uses `Intel Syntax`.**
    * Lacks the `PTR` keyword, so `mov DWORD PTR [rbp-0xc], edi` should be written as `mov DWORD [rbp-0xc], edi`.
1. `masm`: Stands for `Microsoft Macro Assembler`. It's specifically written by Microsoft for assembly under `windows`.
1. **`gas`: Stands for `GNU Assembler` and uses `AT&T Syntax`.**

```sh
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/nasm-2.10.07-7.el7.x86_64.rpm
yum localinstall -y nasm-2.10.07-7.el7.x86_64.rpm
```

## 5.2 First Program

**Objective of this section: Write assembly code equivalent to the following C++ program**

```cpp
int main() {
    return 0;
}
```

### 5.2.1 Intel Version

`first.asm` is as follows:

```nasm
global main

main:
    mov eax, 0
    ret
```

Compile and execute:

```sh
nasm -o first.o -f elf64 first.asm
gcc -o first -m64 first.o

./first; echo $?
```

### 5.2.2 AT&T Version

`first.asm` is as follows:

```nasm
    .text
    .globl main
main:
    mov $0, %eax
    ret
```

Compile and execute:

```sh
as -o first.o first.asm
gcc -o first -m64 first.o

./first; echo $?
```

## 5.3 Use Memory

**Objective of this section: Calculate the value of 1+2 using memory.**

### 5.3.1 Intel Version

`use_memory.asm` is as follows:

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

Compile and execute:

```sh
nasm -o use_memory.o -f elf64 use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

**The result shows a `core dump`. This is because in the Linux operating system, memory is controlled by the operating system and cannot be read or written arbitrarily. You can change it to the following form:**

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

Compile and execute:

```sh
nasm -o use_memory.o -f elf64 use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

**In this version of the code, in addition to using `[sui_bian_xie]` instead of a memory address, there are also two additional lines:**

* The first line indicates that the following content, after compilation, will be placed in the data section of the executable file and will be allocated corresponding memory when the program starts.
* The second line is crucial as it describes the actual data. This line means that a 4-byte space is allocated and filled with zeros. The `dw` (double word) here represents 4 bytes. The `sui_bian_xie` in front is just a name, which means you can write anything here for ease of distinction when writing code. This `sui_bian_xie` will be processed by the compiler into a specific address during compilation. We don't need to worry about the exact address; we just need to know that the `sui_bian_xie` before and after represents the same thing.

```asm
section .data
sui_bian_xie   dw    0
```

Here's another example, `use_memory2.asm`, as follows:

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

Compile and execute:

```sh
nasm -o use_memory2.o -f elf64 use_memory2.asm
gcc -o use_memory2 -m64 use_memory2.o

./use_memory2; echo $?
```

### 5.3.2 AT&T Version

`use_memory.asm` is as follows:

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

Compile and execute:

```sh
as -o use_memory.o use_memory.asm
gcc -o use_memory -m64 use_memory.o

./use_memory; echo $?
```

`use_memory2.asm` is as follows:

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

Compile and execute:

```sh
as -o use_memory2.o use_memory2.asm
gcc -o use_memory2 -m64 use_memory2.o

./use_memory2; echo $?
```

## 5.4 Translate the first C program:

For the following C program:

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

### 5.4.1 Intel Version

`first_c.asm` is as follows:

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

Compile and execute:

```sh
nasm -o first_c.o -f elf64 first_c.asm
gcc -o first_c -m64 first_c.o

./first_c; echo $?
```

### 5.4.2 AT&T Version

`first_c.asm` is as follows:

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

Compile and execute:

```sh
as -o first_c.o first_c.asm
gcc -o first_c -m64 first_c.o

./first_c; echo $?
```

## 5.5 Translating C Language if Statements

For the following C program:

```cpp
int main() {
    int a = 50;
    if (a > 10) {
        a = a - 10;
    }
    return a;
}
```

### 5.5.1 Intel Version

`if_c.asm` is as follows:

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

Compile and execute:

```sh
nasm -o if_c.o -f elf64 if_c.asm
gcc -o if_c -m64 if_c.o

./if_c; echo $?
```

### 5.5.2 AT&T Version

`if_c.asm` is as follows:

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

Compile and execute:

```sh
as -o if_c.o if_c.asm
gcc -o if_c -m64 if_c.o

./if_c; echo $?
```

## 5.6 Translating C Language Loop Statements

For the following C program:

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

Or the `for` version as follows:

```cpp
int main() {
    int sum = 0;
    for (int i = 1; i <= 10; i++) {
        sum = sum + i;
    }
    return sum;
}
```

The above two forms of loops, with slight adjustments, can be simplified to the following equivalent program:

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

### 5.6.1 Intel Version

`loop_c.asm` is as follows:

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

Compile and execute:

```sh
nasm -o loop_c.o -f elf64 loop_c.asm
gcc -o loop_c -m64 loop_c.o

./loop_c; echo $?
```

### 5.6.2 AT&T Version

`loop_c.asm` is as follows:

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

Compile and execute:

```sh
as -o loop_c.o loop_c.asm
gcc -o loop_c -m64 loop_c.o

./loop_c; echo $?
```

## 5.7 Translating C Language Function Calls

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

To facilitate conversion to assembly, the program above has been rewritten into the following equivalent program:

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

**Since registers are global resources, for recursive calls to work, before making a call, it's necessary to push each register used by the current function onto the stack, and after the call returns, restore the registers. The instructions involved include:**

* `call`: Initiates a function call.
* `ret`: Returns from a function.
* `push`: Pushes onto the stack.
* `pop`: Pops from the stack.
* `rsp`: Stack pointer.
* `rbp`: Base pointer.

### 5.7.1 Intel Version

`fibonacci_c.asm` is as follows:

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

Compile and execute:

```sh
nasm -o fibonacci_c.o -f elf64 fibonacci_c.asm
gcc -o fibonacci_c -m64 fibonacci_c.o

./fibonacci_c; echo $?
```

Among these, preparing the current stack frame and restoring the parent stack frame can be replaced with `enter` and `leave`.

```nasm
    push rbp                        ; 保存上一级的栈底指针
    mov rbp, rsp                    ; 上个函数的栈顶指针作为当前函数的栈底指针
    sub rsp, 0xc                    ; 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节

    mov rsp, rbp                    ; 恢复 rsp
    pop rbp                         ; 恢复 rbp
```

Can be replaced with

```nasm
    enter 0xc, 0x0

    leave
```

### 5.7.2 AT&T Version

`fibonacci_c.asm` is as follows:

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

Compile and execute:

```sh
as -o fibonacci_c.o fibonacci_c.asm
gcc -o fibonacci_c -m64 fibonacci_c.o

./fibonacci_c; echo $?
```

Among these, preparing the current stack frame and restoring the parent stack frame can be replaced with `enter` and `leave`.

```nasm
    push %rbp                       # 保存上一级的栈底指针
    mov %rsp, %rbp                  # 上个函数的栈顶指针作为当前函数的栈底指针
    sub $0xc, %rsp                  # 栈顶向下移动 12 个字节，当前栈空间就是 12 个字节

    mov %rbp, %rsp                  # 恢复 rsp
    pop %rbp                        # 恢复 rbp
```

Can be replaced with

```nasm
    enter $0xc, $0x0

    leave
```

# 6 Tips

## 6.1 How to generate readable assembly code

**Approach 1: (Not easy to understand)**

```sh
# Generate
gcc main.cpp -S -g -fverbose-asm

# View
cat main.s
```

**Approach 2：**

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
