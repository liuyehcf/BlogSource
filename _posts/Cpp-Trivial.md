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

## 2.1 静态链接库

**后缀：`*.a`**

**编译时如何链接静态链接库：**

* `-L`：指定静态链接库的搜索路径
* `-l <static_lib_name>`：
    * 假设静态链接库的名称是`libgflags.a`，那么`<static_lib_name>`既不需要`lib`前缀，也不需要`.a`后缀，即`gflags`

**如何查看二进制的静态链接库：由于链接器在链接时，就会丢弃静态库的名字信息，因此，一般是看不到的**

* `-Xlinker -Map=a.map`：将链接时的信息记录到`a.map`中
* `nm/objdump/readelf/strings`或许可以找到一些静态库相关的`hint`

**静态库的路径：**

* `/usr/local/lib`
* `/usr/local/lib64`

## 2.2 动态链接库

**后缀：`*.so`**

**如何查看二进制的动态链接库：`ldd`**

**查看动态链接库绑定信息：`ldconfig -v`、`ldconfig -p`**

### 2.2.1 动态库搜索顺序

**搜索如下：详见`man ld.so`**

1. 在环境变量`LD_LIBRARY_PATH`指定的目录下搜索，以`:`分隔
1. 在`/etc/ld.so.cache`指定的目录中搜索
1. 在`/lib`、`/lib64`中搜索（系统发行版安装的）
1. 在`/usr/lib`、`/usr/lib64`中搜索（其他软件安装的）

### 2.2.2 Linux下so的版本机制介绍

**本小节转载摘录自[一文读懂Linux下动态链接库版本管理及查找加载方式](https://blog.ideawand.com/2020/02/15/how-does-linux-shared-library-versioning-works/)**

在`/lib64`、`/usr/lib64`、`/usr/local/lib64`目录下，会看到很多具有下列特征的软连接，其中`x`、`y`、`z`为数字, 那么这些软连接和他们后面的数字有什么用途呢？

```
libfoo.so    ->  libfoo.so.x
libfoo.so.x  ->  libfoo.so.x.y.z
libbar.so.x  ->  libbar.so.x.y
```

这里的`x`、`y`、`z`分别代表的是这个`so`的主版本号（`MAJOR`），次版本号（`MINOR`），以及发行版本号（`RELEASE`），对于这三个数字各自的含义，以及什么时候会进行增长，不同的文献上有不同的解释，不同的组织遵循的规定可能也有细微的差别，但有一个可以肯定的事情是：主版本号（`MAJOR`）不同的两个`so`库，所暴露出的`API`接口是不兼容的。而对于次版本号，和发行版本号，则有着不同定义，其中一种定义是：次要版本号表示`API`接口的定义发生了改变（比如参数的含义发生了变化），但是保持向前兼容；而发行版本号则是函数内部的一些功能调整、优化、BUG修复，不涉及`API`接口定义的修改

#### 2.2.2.1 几个so库有关名字的介绍

**介绍一下在`so`查找过程中的几个名字**

* **`SONAME`：一组具有兼容`API`的`so`库所共有的名字，其命名特征是`lib<库名>.so.<数字>`这种形式的**
* **`real name`：是真实具有`so`库可执行代码的那个文件，之所以叫`real`是相对于`SONAME`和`linker name`而言的，因为另外两种名字一般都是一个软连接，这些软连接最终指向的文件都是具有`real name`命名形式的文件。`real name`的命名格式中，可能有`2`个数字尾缀，也可能有`3`个数字尾缀，但这不重要。你只要记住，真实的那个，不是以软连接形式存在的，就是一个`real name`**
* **`linker name`：这个名字只是给编译工具链中的连接器使用的名字，和程序运行并没有什么关系，仅仅在链接得到可执行文件的过程中才会用到。它的命名特征是以`lib`开头，以`.so`结尾，不带任何数字后缀的格式**

#### 2.2.2.2 SONAME的作用

假设在你的Linux系统中有3个不同版本的`bar`共享库，他们在磁盘上保存的文件名如下：

* `/usr/lib64/libbar.so.1.3`
* `/usr/lib64/libbar.so.1.5`
* `/usr/lib64/libbar.so.2.1`

假设以上三个文件，都是真实的`so`库文件，而不是软连接，也就是说，上面列出的名字都是`real name`

根据我们之前对版本号的定义，我们可以知道：

* `libbar.so.1.3`和`libbar.so.1.5`之间是互相兼容的
* `libbar.so.2.1`和上述两个库之间互相不兼容

**引入软连接的好处是什么呢？假设有一天，`libbar.so.2.1`库进行了升级，但`API`接口仍然保持兼容，升级后的库文件为`libbar.so.2.2`，这时候，我们只要将之前的软连接重新指向升级后的文件，然后重新启动B程序，B程序就可以使用全新版本的`so`库了，我们并不需要去重新编译链接来更新B程序**

**总结一下上面的逻辑：**

* 通常`SONAME`是一个指向`real name`的软连接
* 应用程序中存储自己所依赖的`so`库的`SONAME`，也就是仅保证主版本号能匹配就行
* 通过修改软连接的指向，可以让应用程序在互相兼容的`so`库中方便切换使用哪一个
* 通常情况下，大家使用最新版本即可，除非是为了在特定版本下做一些调试、开发工作

#### 2.2.2.3 linker name的作用

上一节中我们提到，可执行文件里会存储精确到主版本号的`SONAME`，但是在编译生成可执行文件的过程中，编译器怎么知道应该用哪个主版本号呢？为了回答这个问题，我们从编译链接的过程来梳理一下

假设我们使用`gcc`编译生成一个依赖`foo`库的可执行文件`A`：`gcc A.c -lfoo -o A`

熟悉`gcc`编译的读者们肯定知道，上述的`-l`标记后跟随了`foo`参数，表示我们告诉`gcc`在编译的过程中需要用到一个外部的名为`foo`的库，但这里有一个问题，我们并没有说使用哪一个主版本，我们只给出了一个名字。为了解决这个问题，软链接再次发挥作用，具体流程如下：

**根据linux下动态链接库的命名规范，`gcc`会根据`-lfoo`这个标识拼接出`libfoo.so`这个文件名，这个文件名就是`linker name`，然后去尝试读取这个文件，并将这个库链接到生成的可执行文件`A`中。在执行编译前，我们可以通过软链接的形式，将`libfoo.so`指向一个具体`so`库，也就是指向一个`real name`，在编译过程中，`gcc`会从这个真实的库中读取出`SONAME`并将它写入到生成的可执行文件`A`中。例如，若`libfoo.so`指向`libfoo.so.1.5`,则生成的可执行文件A使用主版本号为`1`的`SONAME`，即`libfoo.so.1`**

在上述编译过程完成之后，`SONAME`已经被写入可执行文件`A`中了，因此可以看到`linker name`仅仅在编译的过程中，可以起到指定连接那个库版本的作用，除此之外，再无其他作用

**总结一下上面的逻辑：**

* 通常`linker name`是一个指向`real name`的软连接
* 通过修改软连接的指向，可以指定编译生成的可执行文件使用那个主版本号`so`库
* 编译器从软链接指向的文件里找到其`SONAME`，并将`SONAME`写入到生成的可执行文件中
* 通过改变`linker name`软连接的指向，可以将不同主版本号的`SONAME`写入到生成的可执行文件中

## 2.3 链接顺序

[Why does the order in which libraries are linked sometimes cause errors in GCC?](https://stackoverflow.com/questions/45135/why-does-the-order-in-which-libraries-are-linked-sometimes-cause-errors-in-gcc)

**示例：**

```sh
cat > a.cpp << 'EOF'
extern int a;
int main() {
    return a;
}
EOF

cat > b.cpp << 'EOF'
extern int b;
int a = b;
EOF

cat > d.cpp << 'EOF'
int b;
EOF

g++ -c b.cpp -o b.o
ar cr libb.a b.o
g++ -c d.cpp -o d.o
ar cr libd.a d.o

g++ -L. -ld -lb a.cpp # wrong order
g++ -L. -lb -ld a.cpp # wrong order
g++ a.cpp -L. -ld -lb # wrong order
g++ a.cpp -L. -lb -ld # right order
```

**链接器解析过程如下：从左到右扫描目标文件、库文件**

* 记录未解析的符号
* 若发现某个库文件可以解决「未解析符号表」中的某个符号，则将该符号从「未解析符号表」中删除

**因此，假设`libA`依赖`libB`，那么需要将`libA`写前面，`libB`写后面**

## 2.4 LD_PRELOAD

**环境变量`LD_PRELOAD`指定的目录拥有最高优先级**

### 2.4.1 demo

```sh
cat > sample.c << 'EOF'
#include <stdio.h>
int main(void) {
    printf("Calling the fopen() function...\n");
    FILE *fd = fopen("test.txt","r");
    if (!fd) {
        printf("fopen() returned NULL\n");
        return 1;
    }
    printf("fopen() succeeded\n");
    return 0;
}
EOF
gcc -o sample sample.c

./sample 
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
fopen() returned NULL
#-------------------------↑↑↑↑↑↑-------------------------

touch test.txt
./sample
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
fopen() succeeded
#-------------------------↑↑↑↑↑↑-------------------------

cat > myfopen.c << 'EOF'
#include <stdio.h>
FILE *fopen(const char *path, const char *mode) {
    printf("This is my fopen!\n");
    return NULL;
}
EOF

gcc -o myfopen.so myfopen.c -Wall -fPIC -shared

LD_PRELOAD=./myfopen.so ./sample
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
This is my fopen!
fopen() returned NULL
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.5 如何制作动态库

```sh
cat > foo.cpp << 'EOF'
#include <iostream>

void foo() {
    std::cout << "hello, this is foo" << std::endl;
}
EOF

cat > main.cpp << 'EOF'
void foo();

int main() {
    foo();
    return 0;
}
EOF

gcc -o foo.o -c foo.cpp -O3 -Wall -fPIC
gcc -shared -o libfoo.so foo.o

gcc -o main main.cpp -O3 -L . -lfoo -lstdc++
./main # ./main: error while loading shared libraries: libfoo.so: cannot open shared object file: No such file or directory
gcc -o main main.cpp -O3 -L . -Wl,-rpath=`pwd` -lfoo -lstdc++
./main
```

## 2.6 ABI

`ABI`全称是`Application Binary Interface`，它是两个二进制模块间的接口，二进制模块可以是`lib`，可以是操作系统的基础设施，或者一个正在运行的用户程序

> An ABI defines how data structures or computational routines are accessed in machine code, which is a low-level, hardware-dependent format

![abi](/images/Cpp-Trivial/abi.png)

具体来说，`ABI`定义了如下内容：

1. 指令集、寄存器、栈组织结构，内存访问类型等等
1. 基本数据类型的`size`、`layout`、`alignment`
1. 调用约定，比如参数如何传递、结果如何传递
    * 参数传递到栈中，还是传递到寄存器中
    * 如果传递到寄存器中的话，哪个入参对应哪个寄存器
    * 如果传递到栈中的话，第一个入参是先压栈还是后压栈
    * 返回值使用哪个寄存器
1. 如何发起系统调用
1. `lib`、`object file`等的文件格式

### 2.6.1 Language-Specific ABI

摘自[What is C++ ABI?](https://www.quora.com/What-is-C-ABI)

> Often, a platform will specify a “base ABI” that specifies how to use that platform’s basic services and that is often done in terms of C language capabilities. However, other programming languages like C++ may require support for additional mechanisms. That’s how you get to language-specific ABIs, including a variety of C++ ABIs. Among the concerns of a C++ ABI are the following:
> * How are classes with virtual functions represented? A C++ ABI will just about always extend the C layout rules for this, and specify implicit pointers in the objects that point to static tables (“vtables”) that themselves point to virtual functions.
> * How are base classes (including virtual base classes) laid out in class objects? Again, this usually starts with the C struct layout rules.
> * How are closure classes (for lambdas) organized?
> * How is RTTI information stored?
> * How are exceptions implemented?
> * How are overloaded functions and operators “named” in object files? This is where “name mangling” usually comes in: The type of the various functions is encoded in their object file names. That also handles the “overloading” that results from template instantiations.
> * How are spilled inline functions and template instantiations handled? After all, different object files might use/spill the same instances, which could lead to collisions.

### 2.6.2 Dual ABI

[Dual ABI](https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dual_abi.html)

> In the GCC 5.1 release libstdc++ introduced a new library ABI that includes new implementations of std::string and std::list. These changes were necessary to conform to the 2011 C++ standard which forbids Copy-On-Write strings and requires lists to keep track of their size.

宏`_GLIBCXX_USE_CXX11_ABI`用于控制使用新版本还是老版本

* `_GLIBCXX_USE_CXX11_ABI = 0`：老版本
* `_GLIBCXX_USE_CXX11_ABI = 1`：新版本

其他参考：

* [ABI Policy and Guidelines](https://gcc.gnu.org/onlinedocs/libstdc++/manual/abi.html)
* [C/C++ ABI兼容那些事儿](https://zhuanlan.zhihu.com/p/556726543)

## 2.7 常用动态库

**`libc/glibc/glib`（`man libc/glibc`）**

* `libc`实现了C的标准库函数，例如`strcpy()`，以及`POSIX`函数，例如系统调用`getpid()`。此外，不是所有的C标准库函数都包含在`libc`中，比如大多数`math`相关的库函数都封装在`libm`中，大多数压缩相关的库函数都封装在`libz`中
    * 系统调用有别于普通函数，它无法被链接器解析。实现系统调用必须引入平台相关的汇编指令。我们可以通过手动实现这些汇编指令来完成系统调用，或者直接使用`libc`（它已经为我们封装好了）
* **`glibc, GNU C Library`可以看做是`libc`的另一种实现，它不仅包含`libc`的所有功能还包含`libm`以及其他核心库，比如`libpthread`**
    * **`glibc`对应的动态库的名字是`libc.so`**
    * **Linux主流的发行版用的都是这个**
* `glib`是Linux下C的一些工具库，和`glibc`没有关系

**查看`glibc`的版本**

* `ldd --version`：`ldd`隶属于`glibc`，因此`ldd`的版本就是`glibc`的版本
* `getconf GNU_LIBC_VERSION`
* `gcc -print-file-name=libc.so`
* `strings /lib64/libc.so.6 | grep GLIBC`：查看`glibc`的API的版本

**其他常用动态库可以参考[Library Interfaces and Headers](https://docs.oracle.com/cd/E86824_01/html/E54772/makehtml-id-7.html#scrolltoc)中的介绍**

1. `libdl`：dynamic linking library
    * **`libdl`主要作用是将那些早已存在于`libc`中的`private dl functions`对外露出，便于用户实现一些特殊的需求。[dlopen in libc and libdl](https://stackoverflow.com/questions/31155824/dlopen-in-libc-and-libdl)**
    * 可以通过`readelf -s /lib64/ld-linux-x86-64.so.2 | grep PRIVATE`查看露出的这些方法
1. `libm`：c math library
1. `libz`：compression/decompression library
1. `libpthread`：POSIX threads library

## 2.8 参考

* [Program Library HOWTO](https://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html)
* [Shared Libraries: Understanding Dynamic Loading](https://amir.rachum.com/blog/2016/09/17/shared-libraries/)
* [wiki-Rpath](https://en.wikipedia.org/wiki/Rpath)
* [RPATH handling](https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling)
* [Linux hook：Ring3下动态链接库.so函数劫持](https://www.cnblogs.com/reuodut/articles/13723437.html)
* [What is the difference between LD_PRELOAD_PATH and LD_LIBRARY_PATH?](https://stackoverflow.com/questions/14715175/what-is-the-difference-between-ld-preload-path-and-ld-library-path)
* [What is libstdc++.so.6 and GLIBCXX_3.4.20?](https://unix.stackexchange.com/questions/557919/what-is-libstdc-so-6-and-glibcxx-3-4-20)
* [多个gcc/glibc版本的共存及指定gcc版本的编译](https://blog.csdn.net/mo4776/article/details/119837501)

# 3 内存管理

[brk和sbrk所指的program break到底是什么？](https://www.zhihu.com/question/21098367/answer/1698482825)

![memory_allocate](/images/Cpp-Trivial/memory_allocate.jpeg)

> 进程可以通过增加堆的大小来分配内存，堆是一段长度可变的连续**虚拟内存**，始于进程的未初始化数据段末尾，随着内存的分配和释放而增减。通常将堆的当前内存边界称为`program break`

> 改变堆的大小（即分配或释放内存），其实就是命令内核改变进程的`program break`位置。最初，`program break`正好位于未初始化数据段末尾之后（如图所示，与`&end`位置相同）

> 在`program break`的位置抬升后，程序可以访问新分配区域内的任何内存地址，而此时物理内存页尚未分配。内核会在进程首次试图访问这些虚拟内存地址时自动分配新的物理内存页

**涉及的系统调用（只涉及虚拟内存，物理内存只能通过缺页异常来分配）**

* `brk/sbrk`：详见`man brk/sbrk`，用于调整堆顶位置，内存释放存在先后顺序。通常用于分配小于`128k`的内存
* `mmap/munmap`：详见`man mmap/munmap`，在栈和堆之间的空间找一块独立内存空间，可以独立释放。通常用于分配大于`128k`的内存

而内存管理的`lib`工作在用户态，底层还是通过上述系统调用来分配虚拟内存，不同的`lib`管理内存的算法可能有差异

## 3.1 [tcmalloc](https://github.com/google/tcmalloc)

![tcmalloc](/images/Cpp-Trivial/tcmalloc.png)

**特点：**

* `Small object allocation`
    * 每个线程都会有个`ThreadCache`，用于为当前线程分配小对象
    * 当其容量不足时，会从`CentralCache`获取额外的存储空间
* `CentralCache allocation management`
    * 用于分配大对象，大对象通常指`>32K`
    * 当内存空间用完后，用`sbrk/mmap`从操作系统中分配内存
    * 在多线程高并发的场景中，`CentralCache`中的锁竞争很容易成为瓶颈
* `Recycle`

**如何安装：**

```sh
yum -y install gperftools gperftools-devel
```

### 3.1.1 Heap-profile

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

## 3.2 [jemalloc](https://github.com/jemalloc/jemalloc)

![jemalloc](/images/Cpp-Trivial/jemalloc.png)

**特点：**

* 在多核、多线程场景下，跨线程分配/释放的性能比较好
* 大量分配小对象时，所占空间会比`tcmalloc`稍多一些
* 对于大对象分配，所造成的的内存碎片会比`tcmalloc`少一些
* 内存分类粒度更细，锁比`tcmalloc`更少

### 3.2.1 Install

[jemalloc/INSTALL.md](https://github.com/jemalloc/jemalloc/blob/dev/INSTALL.md)

```sh
git clone git@github.com:jemalloc/jemalloc.git
cd jemalloc
git checkout 5.3.0

./autogen.sh
./configure --prefix=/usr/local --enable-prof
make -j 16
sudo make install
```

### 3.2.2 Heap-profile

[Getting Started](https://github.com/jemalloc/jemalloc/wiki/Getting-Started)

```cpp
#include <cstdint>

void alloc_1M() {
    new uint8_t[1024 * 1024];
}

int main() {
    for (int i = 0; i < 100; i++) {
        alloc_1M();
    }
    return 0;
}
```

**编译执行：**

* 方式1：隐式链接，用`LD_PRELOAD`
    ```sh
    gcc -o main main.cpp -O0 -lstdc++ -std=gnu++17
    MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true LD_PRELOAD=/usr/local/lib/libjemalloc.so.2 ./main
    ```

* 方式2：显示链接
    ```
    gcc -o main main.cpp -O0 -lstdc++ -std=gnu++17 -L`jemalloc-config --libdir` -Wl,-rpath,`jemalloc-config --libdir` -ljemalloc `jemalloc-config --libs`
    MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true ./main
    ```

**查看：`jeprof --text main jeprof.145931.0.f.heap`**

* 第一列：函数直接申请的内存大小，单位MB
* 第二列：第一列占总内存的百分比
* 第三列：第二列的累积值
* 第四列：函数以及函数所有调用的函数申请的内存大小，单位MB
* 第五列：第四列占总内存的百分比
```
Using local file main.
Using local file jeprof.145931.0.f.heap.
Total: 100.1 MB
100.1 100.0% 100.0%    100.1 100.0% prof_backtrace_impl
    0.0   0.0% 100.0%      0.1   0.1% _GLOBAL__sub_I_eh_alloc.cc
    0.0   0.0% 100.0%    100.0  99.9% __libc_start_main
    0.0   0.0% 100.0%      0.1   0.1% __static_initialization_and_destruction_0 (inline)
    0.0   0.0% 100.0%      0.1   0.1% _dl_init_internal
    0.0   0.0% 100.0%      0.1   0.1% _dl_start_user
    0.0   0.0% 100.0%    100.0  99.9% _start
    0.0   0.0% 100.0%    100.0  99.9% alloc_1M
    0.0   0.0% 100.0%    100.1 100.0% imalloc (inline)
    0.0   0.0% 100.0%    100.1 100.0% imalloc_body (inline)
    0.0   0.0% 100.0%    100.1 100.0% je_malloc_default
    0.0   0.0% 100.0%    100.1 100.0% je_prof_backtrace
    0.0   0.0% 100.0%    100.1 100.0% je_prof_tctx_create
    0.0   0.0% 100.0%    100.0  99.9% main
    0.0   0.0% 100.0%      0.1   0.1% pool (inline)
    0.0   0.0% 100.0%    100.1 100.0% prof_alloc_prep (inline)
    0.0   0.0% 100.0%    100.0  99.9% void* fallback_impl
```

### 3.2.3 Work with http

源码如下：

* [yhirose/cpp-httplib](https://github.com/yhirose/cpp-httplib)
* `path`是固定，即`/pprof/heap`以及`/pprof/profile`
    * `/pprof/profile`的实现估计有问题，拿不到预期的结果

```cpp
#include <gperftools/profiler.h>
#include <jemalloc/jemalloc.h>
#include <stdlib.h>

#include <iterator>
#include <sstream>
#include <thread>

#include "httplib.h"

uint8_t* alloc_1M() {
    return new uint8_t[1024 * 1024];
}

int main(int argc, char** argv) {
    httplib::Server svr;

    svr.Get("/pprof/heap", [](const httplib::Request&, httplib::Response& res) {
        std::stringstream fname;
        fname << "./heap." << getpid() << "." << rand();
        auto fname_str = fname.str();
        const char* fname_cstr = fname_str.c_str();

        std::string content;
        if (mallctl("prof.dump", nullptr, nullptr, &fname_cstr, sizeof(const char*)) == 0) {
            std::ifstream f(fname_cstr);
            content = std::string(std::istreambuf_iterator<char>(f), std::istreambuf_iterator<char>());
        } else {
            content = "dump jemalloc prof file failed";
        }

        res.set_content(content, "text/plain");
    });

    svr.Get("/pprof/profile", [](const httplib::Request& req, httplib::Response& res) {
        int seconds = 30;
        const std::string& seconds_str = req.get_param_value("seconds");
        if (!seconds_str.empty()) {
            seconds = std::atoi(seconds_str.c_str());
        }

        std::ostringstream fname;
        fname << "./profile." << getpid() << "." << rand();
        auto fname_str = fname.str();
        const char* fname_cstr = fname_str.c_str();

        ProfilerStart(fname_cstr);
        sleep(seconds);
        ProfilerStop();

        std::ifstream f(fname_cstr, std::ios::in);
        std::string content;
        if (f.is_open()) {
            content = std::string(std::istreambuf_iterator<char>(f), std::istreambuf_iterator<char>());
        } else {
            content = "dump jemalloc prof file failed";
        }

        res.set_content(content, "text/plain");
    });

    std::thread t_alloc([]() {
        while (true) {
            alloc_1M();
            sleep(1);
        }
    });

    svr.listen("0.0.0.0", 16691);

    return 0;
}
```

编译运行：

```sh
gcc -o main main.cpp -O0 -lstdc++ -std=gnu++17 -L`jemalloc-config --libdir` -Wl,-rpath,`jemalloc-config --libdir` -ljemalloc `jemalloc-config --libs` -lprofiler
MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true ./main

# 另一个终端中执行下面命令
jeprof main localhost:16691/pprof/heap # 交互式
jeprof main localhost:16691/pprof/heap --text #文本
jeprof main localhost:16691/pprof/heap --svg > main.svg #图形

jeprof main localhost:16691/pprof/profile --text --seconds=15
```

## 3.3 [mimalloc](https://github.com/microsoft/mimalloc)

## 3.4 对比

[What are the differences between (and reasons to choose) tcmalloc/jemalloc and memory pools?](https://stackoverflow.com/questions/9866145/what-are-the-differences-between-and-reasons-to-choose-tcmalloc-jemalloc-and-m)

## 3.5 参考

* [heapprofile.html](https://gperftools.github.io/gperftools/heapprofile.html)
* [Apache Doris-调试工具](https://doris.apache.org/developer-guide/debug-tool.html)
* [调试工具](https://github.com/stdpain/doris-vectorized/blob/master/docs/zh-CN/developer-guide/debug-tool.md)
* [jemalloc的heap profiling](https://www.yuanguohuo.com/2019/01/02/jemalloc-heap-profiling/)

# 4 Address Sanitizer

## 4.1 memory leak

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

## 4.2 stack buffer underflow

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

## 4.3 参考

* [c++ Asan(address-sanitize)的配置和使用](https://blog.csdn.net/weixin_41644391/article/details/103450401)
* [HOWTO: Use Address Sanitizer](https://www.osc.edu/resources/getting_started/howto/howto_use_address_sanitizer)
* [google/sanitizers](https://github.com/google/sanitizers)

# 5 gun工具链

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

## 5.1 gcc

**常用参数说明：**

1. **文件类型**
    *  `-E`：生成预处理文件（`.i`）
    *  `-S`：生成汇编文件（`.s`）
        * `-fverbose-asm`：带上一些注释信息
    *  `-c`：生成目标文件（`.o`）
    *  默认生成可执行文件
1. **优化级别**
    1. `-O0`（默认）：不做任何优化
    1. `-O/-O1`：在不影响编译速度的前提下，尽量采用一些优化算法降低代码大小和可执行代码的运行速度
    1. `-O2`：该优化选项会牺牲部分编译速度，除了执行`-O1`所执行的所有优化之外，还会采用几乎所有的目标配置支持的优化算法，用以提高目标代码的运行速度
    1. `-O3`：该选项除了执行`-O2`所有的优化选项之外，一般都是采取很多向量化算法，提高代码的并行执行程度，利用现代CPU中的流水线，`Cache`等
    * 不同优化等级对应开启的优化参数参考`man page`
1. **调试**
    * `-gz[=type]`：对于`DWARF`格式的文件中的调试部分按照指定的压缩方式进行压缩
    * `-g`：生成调试信息
    * `-ggdb`：生成`gdb`专用的调试信息
    * `-gdwarf`/`-gdwarf-version`：生成`DWARF`格式的调试信息，`version`的可选值有`2/3/4/5`，默认是4
1. **`-I <path>`：增加头文件搜索路径**
    * 可以并列使用多个`-I`参数，例如`-I path1 -I path2`
1. **`-L <path>`：增加库文件搜索路径**
1. **`-l<lib_name>`：增加库文件**
    * 搜索指定名称的静态或者动态库，如果同时存在，默认选择动态库
    * 例如`-lstdc++`、`-lpthread`
1. **`-std=<std_version>`：指定标注库类型以及版本信息**
    * 例如`-std=gnu++17`
1. **`-W<xxx>`：warning提示**
    * `-Wall`：启用大部分warning提示（部分warning无法通过该参数默认启用）
    * `-Wno<xxx>`：关闭指定种类的warning提示
    * `-Werror`：所有warning变为error（会导致编译失败）
    * `-Werror=<xxx>`：指定某个warning变为error（会导致编译失败）
1. **`-D <macro_name>[=<macro_definition>]`：定义宏**
    * 例如`-D MY_DEMO_MACRO`、`-D MY_DEMO_MACRO=2`、`-D 'MY_DEMO_MACRO="hello"'`、`-D 'ECHO(a)=(a)'`
1. **`-U <macro_name>`：取消宏定义**
1. **`-fno-access-control`：关闭访问控制，例如在类外可以直接访问某类的私有字段和方法，一般用于单元测试**
1. **向量化相关参数**
    * `-fopt-info-vec`/`-fopt-info-vec-optimized`：当循环进行向量化优化时，输出详细信息
    * `-fopt-info-vec-missed`：当循环无法向量化时，输出详细信息
    * `-fopt-info-vec-note`：输出循环向量化优化的所有详细信息
    * `-fopt-info-vec-all`：开启所有输出向量化详细信息的参数
    * `-fno-tree-vectorize`：关闭向量化
    * **一般来说，需要指定参数后才能使用更大宽度的向量化寄存器**
        * `-mmmx`
        * `-msse`、`-msse2`、`-msse3`、`-mssse3`、`-msse4`、`-msse4a`、`-msse4.1`、`-msse4.2`
        * `-mavx`、`-mavx2`、`-mavx512f`、`-mavx512pf`、`-mavx512er`、`-mavx512cd`、`-mavx512vl`、`-mavx512bw`、`-mavx512dq`、`-mavx512ifma`、`-mavx512vbmi`
        * ...
1. **`-fPIC`：如果目标机器支持，则生成与位置无关的代码，适用于动态链接并避免对全局偏移表大小的任何限制**
1. **`-fomit-frame-pointer`：必要的话，允许部分函数没有栈指针**
    * `-fno-omit-frame-pointer`：所有函数必须包含栈指针
1. `-faligned-new`
1. `-fsized-deallocation`：启用接收`size`参数的`delete`运算符。[C++ Sized Deallocation](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3778.html)。现代内存分配器在给对象分配内存时，需要指定大小，出于空间利用率的考虑，不会在对象内存周围存储对象的大小信息。因此在释放对象时，需要查找对象占用的内存大小，查找的开销很大，因为通常不在缓存中。因此，编译器允许提供接受一个`size`参数的`global delete operator`，并用这个版本来对对象进行析构

## 5.2 ld

**种类**

* `GNU gold`
* `LLVM lld`
* [mold](https://github.com/rui314/mold)

**`gcc`如何指定`linker`**

* -fuse-ld=gold
* -B/usr/local/bin/gcc-mold

**常用参数说明：**

* `-l <name>`：增加库文件，查找`lib<name>.a`或者`lib<name>.so`，如果都存在，默认使用`so`版本
* `-L <dir>`：增加库文件搜索路径，其优先级会高于默认的搜索路径。允许指定多个，搜索顺序与其指定的顺序相同
* `-rpath=<dir>`：增加运行时库文件搜索路径（务必用绝路径，否则二进制一旦换目录就无法运行了）。`-L`参数只在编译、链接期间生效，运行时仍然会找不到动态库文件，需要通过该参数指定。因此，对于位于非默认搜索路径下的动态库文件，`-L`与`-Wl,-rpath=`这两个参数通常是一起使用的
    * [What's the difference between `-rpath-link` and `-L`?](https://stackoverflow.com/questions/49138195/whats-the-difference-between-rpath-link-and-l)
* `-Bstatic`：修改默认行为，强制使用静态链接库，只对该参数之后出现的库有效。如果找不到对应的静态库会报错（即便有动态库）
* `-Bdynamic`：修改默认行为，强制使用动态链接库，只对该参数之后出现的库有效。如果找不到对应的动态库会报错（即便有静态库）
* `--wrap=<symbol>`
    * 任何指向`<symbol>`的未定义的符号都会被解析为`__wrap_<symbol>`
    * 任何指向`__real_<symbol>`的未定义的符号都会被解析为`<symbol>`
    * 于是，我们就可以在`__wrap_<symbol>`增加额外的逻辑，并最终调用`__real_<symbol>`来实现代理
    ```sh
    cat > proxy_malloc.c << 'EOF'
    #include <stddef.h>
    #include <stdio.h>
    #include <stdlib.h>

    void* __real_malloc(size_t c);

    void* __wrap_malloc(size_t c) {
        printf("malloc called with %zu\n", c);
        return __real_malloc(c);
    }

    int main() {
        int* num = (int*)malloc(sizeof(int));
        return *num;
    }
    EOF

    gcc -o proxy_malloc proxy_malloc.c -Wl,-wrap=malloc

    ./proxy_malloc
    ```

## 5.3 参考

# 6 llvm工具链

## 6.1 clang-format

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

**注意：**

* 即便`.clang-format`相同，不同版本的`clang-format`格式化的结果也有差异

# 7 其他

## 7.1 动态分析

![analysis-tools](/images/Cpp-Trivial/analysis-tools.png)

## 7.2 头文件搜索路径

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

## 7.3 doc

1. [cpp reference](https://en.cppreference.com/w/)
1. [cppman](https://github.com/aitjcize/cppman/)
    * 安装：`pip install cppman`
    * 示例：`cppman vector::begin`
    * 重建索引：`cppman -r`

## 7.4 参考

* [C/C++ 头文件以及库的搜索路径](https://blog.csdn.net/crylearner/article/details/17013187)
