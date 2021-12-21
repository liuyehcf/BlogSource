---
title: Cpp-Trivial
date: 2021-08-19 09:38:42
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 编译过程

```mermaid
graph TD
other_target(["其他目标代码"])
linker[["链接器"]]
source(["源代码"])
compiler[["编译器"]]
assembly(["汇编代码"])
assembler[["汇编器"]]
target(["目标代码"])
lib(["库文件"])
result_target(["目标代码"])
exec(["可执行程序"])
result_lib(["库文件"])

other_target --> linker

subgraph 编译过程
source --> compiler
compiler --> assembly
assembly --> assembler
assembler --> target
end
target --> linker
lib --> linker

linker --> result_target
linker --> exec
linker --> result_lib
```

# 2 lib

## 2.1 什么是`libc`、`glic`

`libc`实现了C的标准库函数（例如`strcpy()`），以及`POSIX`函数（例如系统调用`getpid()`）。此外，不是所有的C标准库函数都包含在`libc`中，比如大多数`math`相关的库函数都封装在`libm`中

系统调用有别于普通函数，它无法被链接器解析。实现系统调用必须引入平台相关的汇编指令。我们可以通过手动实现这些汇编指令来完成系统调用，或者直接使用`libc`（它已经为我们封装好了）

`glibc, GNU C Library`可以看做是`libc`的另一种实现，它不仅包含`libc`的所有功能还包含`libm`以及其他核心库，比如`libpthread`

## 2.2 静态/动态链接库

**后缀**

* 静态链接库：`*.a`
* 动态链接库：`*.so`

# 3 gcc

## 3.1 编译流程

1. `-E`：生成预处理文件（`.i`）
1. `-S`：生成汇编文件（`.s`）
    * `-fverbose-asm`：带上一些注释信息
1. `-c`：生成目标文件（`.o`）
1. 默认生成可执行文件

## 3.2 编译优化

**`-O0`（默认）：不做任何优化**

**`-O/-O1`：在不影响编译速度的前提下，尽量采用一些优化算法降低代码大小和可执行代码的运行速度**

**`-O2`：该优化选项会牺牲部分编译速度，除了执行`-O1`所执行的所有优化之外，还会采用几乎所有的目标配置支持的优化算法，用以提高目标代码的运行速度**

**`-O3`：该选项除了执行-O2所有的优化选项之外，一般都是采取很多向量化算法，提高代码的并行执行程度，利用现代CPU中的流水线，Cache等**

**不同优化等级对应开启的优化参数参考`man page`**

## 3.3 参考

# 4 clang-format

**如何安装`clang-format`**

```sh
npm install -g clang-format
```

**如何使用：在`用户目录`或者`项目根目录`中创建`.clang-format`文件用于指定格式化的方式，下面给一个示例**

* **优先使用项目根目录中的`.clang-format`；如果不存在，则使用用户目录中的`~/.clang-format`**

```
---
Language: Cpp
BasedOnStyle: Google
AccessModifierOffset: -4
AllowShortFunctionsOnASingleLine: Inline
ColumnLimit: 120
ConstructorInitializerIndentWidth: 8 # double of IndentWidth
ContinuationIndentWidth: 8 # double of IndentWidth
DerivePointerAlignment: false # always use PointerAlignment
IndentCaseLabels: false
IndentWidth: 4
PointerAlignment: Left
ReflowComments: false
SortUsingDeclarations: false
SpacesBeforeTrailingComments: 1
```

# 5 头文件搜索路径

**头文件`#include "xxx.h"`的搜索顺序**

1. 先搜索当前目录
1. 然后搜索`-I`参数指定的目录
1. 再搜索gcc的环境变量`CPLUS_INCLUDE_PATH`（C程序使用的是`C_INCLUDE_PATH`）
1. 最后搜索gcc的内定目录，包括：
    * `/usr/include`
    * `/usr/local/include`
    * `/usr/lib/gcc/x86_64-redhat-linux/<gcc version>/include`（C头文件）或者`/usr/include/c++/<gcc version>`（C++头文件）

**头文件`#include <xxx.h>`的搜索顺序**

1. 先搜索`-I`参数指定的目录
1. 再搜索gcc的环境变量`CPLUS_INCLUDE_PATH`（C程序使用的是`C_INCLUDE_PATH`）
1. 最后搜索gcc的内定目录，包括：
    * `/usr/include`
    * `/usr/local/include`
    * `/usr/lib/gcc/x86_64-redhat-linux/<gcc version>/include`（C头文件）或者`/usr/include/c++/<gcc version>`（C++头文件）

## 5.1 参考

* [C/C++ 头文件以及库的搜索路径](https://blog.csdn.net/crylearner/article/details/17013187)

# 6 Address Sanitizer

## 6.1 memory leak

```sh
cat > test_memory_leak.cpp << 'EOF'
#include <iostream>

int main() {
    int *p = new int(5);
    std::cout << *p << std::endl;
    return 0;
}
EOF

gcc test_memory_leak.cpp -o test_memory_leak -g -lstdc++ -fsanitize=address -static-libasan
./test_memory_leak
```

## 6.2 stack buffer underflow

```sh
cat > test_stack_buffer_underflow.cpp << 'EOF'
#include <iostream>

int main() {
    char buffer[5] = "";
    uint8_t num = 5;

    buffer[-1] = 7;

    std::cout << (void*)buffer << std::endl;
    std::cout << (void*)&buffer[-1] << std::endl;
    std::cout << (void*)&num << std::endl;
    std::cout << (uint32_t)num << std::endl;

    return 0;
}
EOF

# 非asan模式
gcc test_stack_buffer_underflow.cpp -o test_stack_buffer_underflow -g -lstdc++ 
./test_stack_buffer_underflow

# asan模式
gcc test_stack_buffer_underflow.cpp -o test_stack_buffer_underflow -g -lstdc++ -fsanitize=address -static-libasan
./test_stack_buffer_underflow
```

## 6.3 参考

* [c++ Asan(address-sanitize)的配置和使用](https://blog.csdn.net/weixin_41644391/article/details/103450401)
* [HOWTO: Use Address Sanitizer](https://www.osc.edu/resources/getting_started/howto/howto_use_address_sanitizer)
* [google/sanitizers](https://github.com/google/sanitizers)

# 7 doc

## 7.1 [cpp reference](https://en.cppreference.com/w/)

## 7.2 [cppman](https://github.com/aitjcize/cppman/)

**如何安装：**

```sh
pip install cppman
```

**示例：**

* `cppman vector::begin`
