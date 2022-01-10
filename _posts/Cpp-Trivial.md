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

# 3 gun工具链

1. `ld`：the GNU linker
1. `as`：the GNU assembler
1. `gold`：a new, faster, ELF only linker
1. `addr2line`：Converts addresses into filenames and line numbers
1. `ar`：A utility for creating, modifying and extracting from archives
1. `c++filt` - Filter to demangle encoded C++ symbols.
1. `dlltool` - Creates files for building and using DLLs.
1. `elfedit` - Allows alteration of ELF format files.
1. `gprof` - Displays profiling information.
1. `nlmconv` - Converts object code into an NLM.
1. `nm` - Lists symbols from object files.
1. `objcopy` - Copies and translates object files.
1. `objdump` - Displays information from object files.
1. `ranlib` - Generates an index to the contents of an archive.
1. `readelf` - Displays information from any ELF format object file.
1. `size` - Lists the section sizes of an object or archive file.
1. `strings` - Lists printable strings from files.
1. `strip` - Discards symbols.
1. `windmc` - A Windows compatible message compiler.
1. `windres` - A compiler for Windows resource files.

## 3.1 gcc

### 3.1.1 编译选项

1. `-E`：生成预处理文件（`.i`）
1. `-S`：生成汇编文件（`.s`）
    * `-fverbose-asm`：带上一些注释信息
1. `-c`：生成目标文件（`.o`）
1. 默认生成可执行文件

### 3.1.2 编译优化

1. **`-O0`（默认）：不做任何优化**
1. **`-O/-O1`：在不影响编译速度的前提下，尽量采用一些优化算法降低代码大小和可执行代码的运行速度**
1. **`-O2`：该优化选项会牺牲部分编译速度，除了执行`-O1`所执行的所有优化之外，还会采用几乎所有的目标配置支持的优化算法，用以提高目标代码的运行速度**
1. **`-O3`：该选项除了执行-O2所有的优化选项之外，一般都是采取很多向量化算法，提高代码的并行执行程度，利用现代CPU中的流水线，Cache等**
* **不同优化等级对应开启的优化参数参考`man page`**

### 3.1.3 其他参数

1. `-fsized-deallocation`：启用接收`size`参数的`delete`运算符。[C++ Sized Deallocation](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3778.html)。现代内存分配器在给对象分配内存时，需要指定大小，出于空间利用率的考虑，不会在对象内存周围存储对象的大小信息。因此在释放对象时，需要查找对象占用的内存大小，查找的开销很大，因为通常不在缓存中。因此，编译器允许提供接受一个`size`参数的`global delete operator`，并用这个版本来对对象进行析构

## 3.2 参考

# 4 内存管理

## 4.1 [tcmalloc](https://github.com/google/tcmalloc)

**如何安装：**

```sh
yum -y install gperftools gperftools-devel
```

### 4.1.1 heapprofile

**`main.cpp`：**

```cpp
#include <stdlib.h>

void* create(unsigned int size) {
    return malloc(size);
}

void create_destory(unsigned int size) {
    void* p = create(size);
    free(p);
}

int main(void) {
    const int loop = 4;
    char* a[loop];
    unsigned int mega = 1024 * 1024;

    for (int i = 0; i < loop; i++) {
        const unsigned int create_size = 1024 * mega;
        create(create_size);

        const unsigned int malloc_size = 1024 * mega;
        a[i] = (char*)malloc(malloc_size);

        const unsigned int create_destory_size = mega;
        create_destory(create_destory_size);
    }

    for (int i = 0; i < loop; i++) {
        free(a[i]);
    }

    return 0;
}
```

**编译：**

```sh
gcc -o main main.cpp -Wall -O3 -lstdc++ -ltcmalloc -std=gnu++17
```

**运行：**

```sh
# 开启 heap profile 功能
export HEAPPROFILE=/tmp/test-profile

./main
```

**输出如下：**

```
Starting tracking the heap
tcmalloc: large alloc 1073741824 bytes == 0x2c46000 @  0x7f6a8fd244ef 0x7f6a8fd43e76 0x400571 0x7f6a8f962555 0x4005bf
Dumping heap profile to /tmp/test-profile.0001.heap (1024 MB allocated cumulatively, 1024 MB currently in use)
Dumping heap profile to /tmp/test-profile.0002.heap (2048 MB allocated cumulatively, 2048 MB currently in use)
Dumping heap profile to /tmp/test-profile.0003.heap (3072 MB allocated cumulatively, 3072 MB currently in use)
Dumping heap profile to /tmp/test-profile.0004.heap (4096 MB allocated cumulatively, 4096 MB currently in use)
Dumping heap profile to /tmp/test-profile.0005.heap (Exiting, 0 bytes in use)
```

**使用`pprof`分析内存：**

```sh
# 文本格式
pprof --text ./main /tmp/test-profile.0001.heap | head -30

# 图片格式
pprof --svg ./main /tmp/test-profile.0001.heap > heap.svg 
```

## 4.2 [jemalloc](https://github.com/jemalloc/jemalloc)

## 4.3 参考

* [heapprofile.html](https://gperftools.github.io/gperftools/heapprofile.html)
* [Apache Doris-调试工具](https://doris.apache.org/master/zh-CN/developer-guide/debug-tool.html)

# 5 clang-format

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

# 6 头文件搜索路径

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

## 6.1 参考

* [C/C++ 头文件以及库的搜索路径](https://blog.csdn.net/crylearner/article/details/17013187)

# 7 Address Sanitizer

## 7.1 memory leak

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

## 7.2 stack buffer underflow

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

## 7.3 参考

* [c++ Asan(address-sanitize)的配置和使用](https://blog.csdn.net/weixin_41644391/article/details/103450401)
* [HOWTO: Use Address Sanitizer](https://www.osc.edu/resources/getting_started/howto/howto_use_address_sanitizer)
* [google/sanitizers](https://github.com/google/sanitizers)

# 8 doc

## 8.1 [cpp reference](https://en.cppreference.com/w/)

## 8.2 [cppman](https://github.com/aitjcize/cppman/)

**如何安装：**

```sh
pip install cppman
```

**示例：**

* `cppman vector::begin`
