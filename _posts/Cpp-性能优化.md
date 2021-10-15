---
title: Cpp-性能优化
date: 2021-10-15 18:45:48
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 Pointer Aliasing

**`Pointer Aliasing`指的是两个指针（在作用域内）指向了同一个物理地址，或者说指向的物理地址有重叠。`__restrict`关键词用于给编译器一个提示：确保被标记的指针是独占物理地址的**

## 1.1 case1

**下面以一个简单的例子说明`__restrict`关键词的作用，以及它是如何引导编译器进行指令优化的**

```sh
# 创建源文件
cat > main.cpp << 'EOF'
#include <stdint.h>

uint32_t add1(uint32_t* a, uint32_t* b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

uint32_t add2(uint32_t* __restrict a, uint32_t* __restrict b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

uint32_t add3(uint32_t* __restrict a, uint32_t* b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

int main() {
    return 0;
}
EOF

# 编译
gcc -o main main.cpp -Wall -O3 -lstdc++

# 反汇编
gdb main

# 在gdb会话中执行
disassemble add1
disassemble add2
disassemble add3
```

**输出如下**

```
(gdb) disassemble add1
Dump of assembler code for function _Z4add1PjS_:
   0x00000000004004c0 <+0>:	movl   $0x1,(%rdi)      # 将1写入rdi对应的地址
   0x00000000004004c6 <+6>:	movl   $0x2,(%rsi)      # 将2写入rsi对应的地址
   0x00000000004004cc <+12>:	mov    (%rdi),%eax  # 将rdi对应的地址中的值写入eax对应的地址
   0x00000000004004ce <+14>:	add    $0x2,%eax    # eax对应的地址中的值加2
   0x00000000004004d1 <+17>:	ret
End of assembler dump.
(gdb) disassemble add2
Dump of assembler code for function _Z4add2PjS_:
   0x00000000004004e0 <+0>:	movl   $0x1,(%rdi)      # 将1写入rdi对应的地址
   0x00000000004004e6 <+6>:	mov    $0x3,%eax        # 将3写入eax对应的地址（直接算出了1 + 2 = 3）
   0x00000000004004eb <+11>:	movl   $0x2,(%rsi)  # 将2写入rsi对应的地址
   0x00000000004004f1 <+17>:	ret
End of assembler dump.
(gdb) disassemble add3
Dump of assembler code for function _Z4add3PjS_:
   0x0000000000400500 <+0>:	movl   $0x1,(%rdi)      # 将1写入rdi对应的地址
   0x0000000000400506 <+6>:	mov    $0x3,%eax        # 将3写入eax对应的地址（直接算出了1 + 2 = 3）
   0x000000000040050b <+11>:	movl   $0x2,(%rsi)  # 将2写入rsi对应的地址
   0x0000000000400511 <+17>:	ret
End of assembler dump.
```

**结论如下**

* 对于函数`add1`，其结果可能是3（`a`和`b`指向不同地址）或者4（`a`和`b`指向相同地址）
* 函数`add2`和`add3`得到的汇编指令是一样的，因为只有`*a = 1;`可能会被`*b = 2;`覆盖

## 1.2 case2

**下面再以一个简单的例子说明`__restrict`关键词的作用，以及它是如何引导编译器进行指令优化的**

```sh
# 创建源文件
cat > main.cpp << 'EOF'
#include <libio.h>
#include <stdint.h>

uint32_t loop1(uint32_t* num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t loop2(uint32_t* __restrict num1, uint32_t* __restrict num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t loop3(uint32_t* __restrict num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

int main() {
    return 0;
}
EOF

# 编译
gcc -o main main.cpp -Wall -O3 -lstdc++

# 反汇编
gdb main

# 在gdb会话中执行
disassemble loop1
disassemble loop2
disassemble loop3
```

**输出如下**

```
(gdb) disassemble loop1
Dump of assembler code for function _Z5loop1PjS_:
   0x00000000004004c0 <+0>:	xor    %eax,%eax
   0x00000000004004c2 <+2>:	xor    %r8d,%r8d
   0x00000000004004c5 <+5>:	nopl   (%rax)
   0x00000000004004c8 <+8>:	mov    %eax,(%rsi)
   0x00000000004004ca <+10>:	add    $0x1,%rax
   0x00000000004004ce <+14>:	add    (%rdi),%r8d
   0x00000000004004d1 <+17>:	cmp    $0x64,%rax
   0x00000000004004d5 <+21>:	jne    0x4004c8 <_Z5loop1PjS_+8>
   0x00000000004004d7 <+23>:	mov    %r8d,%eax
   0x00000000004004da <+26>:	ret
End of assembler dump.
(gdb) disassemble loop2
Dump of assembler code for function _Z5loop2PjS_:
   0x00000000004004e0 <+0>:	imul   $0x64,(%rdi),%eax    # 直接将rdi对应地址中的值乘以100（0x64），写入eax对应的地址
   0x00000000004004e3 <+3>:	movl   $0x63,(%rsi)         # 直接将99写入rsi对应的地址
   0x00000000004004e9 <+9>:	ret
End of assembler dump.
(gdb) disassemble loop3
Dump of assembler code for function _Z5loop3PjS_:
   0x00000000004004f0 <+0>:	imul   $0x64,(%rdi),%eax    # 直接将rdi对应地址中的值乘以100（0x64），写入eax对应的地址
   0x00000000004004f3 <+3>:	movl   $0x63,(%rsi)         # 直接将99写入rsi对应的地址
   0x00000000004004f9 <+9>:	ret
End of assembler dump.
```

**结论**

1. 对于函数`loop1`，由于赋值语句`*num2 = i;`的存在，导致编译器无法直接计算结果，因为该语句可能会修改`num1`的值（`num1`和`num2`指向同一地址）
1. 函数`loop2`和`loop3`生成的指令一样，都可以在编译期直接计算结果
