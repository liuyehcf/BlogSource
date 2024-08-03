---
title: Cpp-Language
date: 2021-09-06 10:53:48
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 Features

[modern-cpp-features](https://github.com/AnthonyCalandra/modern-cpp-features)

# 2 Preprocessor Directives

## 2.1 Conditions

预处理器支持有条件地编译源文件的某些部分。这一行为由`#if`、`#else`、`#elif`、`#ifdef`、`#ifndef`与`#endif`指令所控制

## 2.2 `#define`

**`ANSI C`标准中有几个标准预定义宏（也是常用的）：**

* `__LINE__`：在源代码中插入当前源代码行号
* `__FILE__`：在源文件中插入当前源文件名
* `__FUNCTION__`：函数名
* `__PRETTY_FUNCTION__`：函数签名
* `__DATE__`：在源文件中插入当前的编译日期
* `__TIME__`：在源文件中插入当前编译时间
* `__STDC__`：当要求程序严格遵循`ANSI C`标准时该标识被赋值为1
* `__cplusplus`：当编写`C++`程序时该标识符被定义

**语法：**

* `#`：字符串化操作符
* `##`：连接操作符
* `\`：续行操作符

### 2.2.1 Work with compiler

macros are preprocessor directives, and they get processed before the actual compilation phase. One of the most common preprocessor directives is `#define` which is used to define macros.

If you want to change a macro definition at compile time, there are several ways to do it:

**Using Compiler Flags**: You can use the `-D` flag (for most compilers like GCC and Clang) to define macros.

* For example, suppose you have the following code:
    ```cpp
    #include<iostream>

    #ifndef MY_MACRO
    #define MY_MACRO "Default Value"
    #endif

    int main() {
        std::cout << MY_MACRO << std::endl;
        return 0;
    }
    ```

* You can change `MY_MACRO` at compile time as:
    ```sh
    g++ your_file.cpp -o output -DMY_MACRO='"Compile Time Value"'
    ```

* When you run the output, it will print "Compile Time Value".

**Using Conditional Compilation:** This is where you use `#ifdef`, `#ifndef`, `#else`, and `#endif` directives to conditionally compile parts of your code based on whether a certain macro is defined or not.

* Here's an example:
    ```cpp
    #ifdef DEBUG
    // code for debugging
    #else
    // regular code
    #endif
    ```

* You can then define or not define DEBUG using the -D flag at compile time:
    ```sh
    g++ your_file.cpp -o output -DDEBUG
    ```

### 2.2.2 Tips

#### 2.2.2.1 do while(0) in macros

考虑下面的宏定义

```c++
#define foo(x) bar(x); baz(x)
```

然后我们调用

```c++
foo(wolf);
```

会被展开为

```c++
bar(wolf); baz(wolf);
```

看起来没有问题，我们接着考虑另一个情况

```c++
if (condition) 
    foo(wolf);
```

会被展开为

```c++
if (condition) 
    bar(wolf);
baz(wolf);
```

这并不符合我们的预期，为了避免出现这种问题，需要用一个作用域将宏包围起来，避免语句的作用域发生偏移，于是我们进一步将宏表示为如下形式

```c++
#define foo(x) { bar(x); baz(x); }
```

然后我们调用

```c++
if (condition)
    foo(wolf);
else
    bin(wolf);
```

会被展开为

```c++
if (condition) {
    bar(wolf);
    baz(wolf);
}; // syntax error
else
    bin(wolf);
```

最终，我们将宏优化成如下形式

```c++
#define foo(x) do { bar(x); baz(x); } while (0)
```

#### 2.2.2.2 Variant

借助宏的嵌套，以及约定命名规则，我们可以实现自动生成`else if`分支，示例代码如下：

```cpp
#include <iostream>
#include <map>

#define APPLY_FOR_PARTITION_VARIANT_ALL(M) \
    M(_int)                                \
    M(_long)                               \
    M(_double)

enum HashMapVariantType { _int, _long, _double };

struct HashMapVariant {
    std::map<int, int> _int;
    std::map<long, long> _long;
    std::map<double, double> _double;
};

HashMapVariant hash_map_variant;
HashMapVariantType type;

void handle_int_map(std::map<int, int>& map) {
    std::cout << "handle int map" << std::endl;
}
void handle_long_map(std::map<long, long>& map) {
    std::cout << "handle long map" << std::endl;
}
void handle_double_map(std::map<double, double>& map) {
    std::cout << "handle double map" << std::endl;
}

void dispatch() {
    if (false) {
    }
#define HASH_MAP_METHOD(NAME)                      \
    else if (type == HashMapVariantType::NAME) {   \
        handle##NAME##_map(hash_map_variant.NAME); \
    }
    APPLY_FOR_PARTITION_VARIANT_ALL(HASH_MAP_METHOD)
#undef HASH_MAP_METHOD
}

int main() {
    type = HashMapVariantType::_int;
    dispatch();
    type = HashMapVariantType::_long;
    dispatch();
    type = HashMapVariantType::_double;
    dispatch();
    return 0;
}
```

上述功能完全可以由`std::variant`实现，如下：

```cpp
#include <iostream>
#include <map>
#include <variant>

std::variant<std::map<int, int>, std::map<long, long>, std::map<double, double>> hash_map_variant;

class Visitor {
public:
    void operator()(std::map<int, int>& map) { std::cout << "handle int map" << std::endl; }
    void operator()(std::map<long, long>& map) { std::cout << "handle long map" << std::endl; }
    void operator()(std::map<double, double>& map) { std::cout << "handle double map" << std::endl; }
};

int main() {
    auto lambda_visitor = [](auto& map) {
        if constexpr (std::is_same_v<std::decay_t<decltype(map)>, std::map<int, int>>) {
            std::cout << "handle int map by lambda" << std::endl;
        } else if constexpr (std::is_same_v<std::decay_t<decltype(map)>, std::map<long, long>>) {
            std::cout << "handle long map by lambda" << std::endl;
        } else if constexpr (std::is_same_v<std::decay_t<decltype(map)>, std::map<double, double>>) {
            std::cout << "handle double map by lambda" << std::endl;
        }
    };
    Visitor visitor;

    hash_map_variant = std::map<int, int>{};
    std::visit(visitor, hash_map_variant);
    std::visit(lambda_visitor, hash_map_variant);

    hash_map_variant = std::map<long, long>{};
    std::visit(visitor, hash_map_variant);
    std::visit(lambda_visitor, hash_map_variant);

    hash_map_variant = std::map<double, double>{};
    std::visit(visitor, hash_map_variant);
    std::visit(lambda_visitor, hash_map_variant);
    return 0;
}
```

#### 2.2.2.3 Comma Problem

[pass method with template arguments to a macro](https://stackoverflow.com/questions/4496842/pass-method-with-template-arguments-to-a-macro)

示例如下，我们定义了一个参数的宏`MY_MACRO`：

* `MY_MACRO(func<flag1, flag2>())`：这个调用会报错，因为逗号会被认为用于分隔两个宏参数
* `MY_MACRO((func<flag1, flag2>()))`：这个调用正常，因为用`()`将表达式包围后，会被认为是一个宏参数

```cpp
#define MY_MACRO(stmt) \
    do {               \
        { stmt; }      \
    } while (0)

template <bool flag1, bool flag2>
void func() {}

template <bool flag1, bool flag2>
void call_func() {
    // MY_MACRO(func<flag1, flag2>());
    MY_MACRO((func<flag1, flag2>()));
}

int main() {
    call_func<true, true>();
    return 0;
}
```

### 2.2.3 Macro Expansion

**Macro replacement proceeds left-to-right ([The Macro Expansion Process](https://www.boost.org/doc/libs/1_85_0/libs/wave/doc/macro_expansion_process.html)):**

1. If, during scanning (or rescanning) an identifier is found, it is looked up in the symbol table. If the identifier is not found in the symbol table, it is not a macro and scanning continues.
1. If the identifier is found, the value of a flag associated with the identifier is used to determine if the identifier is available for expansion. If it is not, the specific token (i.e. the specific instance of the identifier) is marked as disabled and is not expanded. If the identifier is available for expansion, the value of a different flag associated with the identifier in the symbol table is used to determine if the identifier is an object-like or function-like macro. If it is an object-like macro, it is expanded. If it is a function-like macro, it is only expanded if the next token is an left parenthesis.
1. An identifier is available for expansion if it is not marked as disabled and if the the value of the flag associated with the identifier is not set, which is used to determine if the identifier is available for expansion.
1. If a macro is an object-like macro, skip past the next two paragraphs.
1. If a macro to be expanded is a function-like macro, it must have the exact number of actual arguments as the number of formal parameters required by the definition of the macro. Each argument is recursively scanned and expanded. Each parameter name found in the replacement list is replaced by the expanded actual argument after leading and trailing whitespace and all placeholder tokens are removed **unless the parameter name immediately follows the stringizing operator (`#`) or is adjacent to the token-pasting operator (`##`)**.
1. **If the parameter name immediately follows the stringizing operator (`#`), a stringized version of the unexpanded actual argument is inserted**. If the parameter name is adjacent to the token-pasting operator (`##`), the unexpanded actual argument is inserted after all placeholder tokens are removed.

```cpp
// Concat x and y, both parameters won't be expanded before concatenation, and the result of concatenation can be expanded if possible
#define TOKEN_CONCAT(x, y) x##y
// Make sure x and y are fully expanded
#define TOKEN_CONCAT_FORWARD(x, y) TOKEN_CONCAT(x, y)

#define DEFINE_INT_1 int prefix_1_##__LINE__
#define DEFINE_INT_2 int TOKEN_CONCAT(prefix_2_, __LINE__)
#define DEFINE_INT_3 int TOKEN_CONCAT_FORWARD(prefix_3_, __LINE__)
#define LINE_NUMBER_AS_VALUE TOKEN_CONCAT(__LINE, __)

int main() {
    DEFINE_INT_1 = 1;
    DEFINE_INT_2 = 2;
    DEFINE_INT_3 = 3;
    int i4 = LINE_NUMBER_AS_VALUE;
    return 0;
}
```

* For `DEFINE_INT_1`, `DEFINE_INT_2` and `DEFINE_INT_3`, only `DEFINE_INT_3` works as we expected.
    * when you use `TOKEN_CONCAT` or `#` directly with macro arguments, it won't expand those arguments before concatenation. This means if `x` or `y` are themselves macros, they will not be expanded before concatenation.
    * The `TOKEN_CONCAT_FORWARD` macro is a forward macro that ensures its arguments are fully expanded before passing them to `TOKEN_CONCAT`
* For `LINE_NUMBER_AS_VALUE`, the expansion happens after the concatenation.

```sh
gcc -E main.cpp
# 0 "main.cpp"
# 0 "<built-in>"
# 0 "<command-line>"
# 1 "/usr/include/stdc-predef.h" 1 3 4
# 0 "<command-line>" 2
# 1 "main.cpp"
# 11 "main.cpp"
int main() {
    int prefix_1___LINE__ = 1;
    int prefix_2___LINE__ = 2;
    int prefix_3_14 = 3;
    int i4 = 15;
    return 0;
}
```

## 2.3 Variadic Macros

宏也支持可变参数，通过`__VA_ARGS__`引用这些参数

```cpp
#include <iostream>

#define SHOW_SUM_UP(...) std::cout << sum(__VA_ARGS__) << std::endl;

template <typename... Args>
int sum(Args&&... args) {
    int sum = 0;
    int nums[] = {args...};
    int size = sizeof...(args);

    for (int i = 0; i < size; i++) {
        sum += nums[i];
    }

    return sum;
}

int main() {
    SHOW_SUM_UP(1, 2, 3);
    return 0;
}
```

## 2.4 `#pragma`

在`C++`中，`#pragma`是一个预处理器指令（`preprocessor directive`），它用于向编译器发出一些特定的命令或提示，从而控制编译器的行为。`#pragma`通常用于开启或关闭某些编译器的特性、设置编译器选项、指定链接库等

`#pragma`指令不是`C++`的标准特性，而是编译器提供的扩展。不同的编译器可能支持不同的`#pragma`指令，而且它们的行为也可能不同。因此在编写可移植的`C++`代码时应尽量避免使用它们

不同的编译器可能支持不同的`#pragma`指令，以下是一些常用的`#pragma`指令及其作用

* `#pragma once`：该指令用于避免头文件被多次包含，以解决头文件重复包含的问题。它告诉编译器只包含一次该头文件
* `#pragma pack`：该`pragma`族控制后继定义的结构体、联合体、类的最大对齐
    * `#pragma pack(<arg>)`：设置当前对齐为值`<arg>`
    * `#pragma pack()`：设置当前对齐为默认值（由命令行选项指定）
    * `#pragma pack(push)`：推入当前对齐的值到内部栈
    * `#pragma pack(push, <arg>)`：推入当前对齐的值到内部栈然后设置当前对齐为值`<arg>`
    * `#pragma pack(pop)`：从内部栈弹出顶条目然后设置（恢复）当前对齐为该值
    * 其中`<arg>`实参是小的`2`的幂，指定以字节计的新对齐
* `#pragma message`：该指令用于在编译时输出一条消息
    ```cpp
    #pragma message("Compiling " __FILE__)

    int main() {
        return 0;
    }
    ```

* `#pragma GCC diagnostic`：该指令用于控制编译器的警告和错误信息。可以用它来控制特定的警告或错误信息是否应该被忽略或显示
    ```cpp
    [[nodiscard]] int something() {
        return 0;
    }

    int main() {
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wunused-result"
        something();
    #pragma GCC diagnostic pop
    }
    ```

* `#pragma omp`：该指令用于`OpenMP`并行编程，用于指定并行执行的方式

## 2.5 `#error`

显示给定的错误消息，并终止编译过程

## 2.6 Reference

* [C/C++ 宏编程的艺术](https://bot-man-jl.github.io/articles/?post=2020/Macro-Programming-Art)

# 3 Key Word

## 3.1 Type Qualifier

### 3.1.1 const

默认状态下，`const`对象仅在文件内有效。编译器将在编译过程中把用到该变量的地方都替代成对应的值，也就是说，编译器会找到代码中所有用到该`const`变量的地方，然后将其替换成定义的值

为了执行上述替换，编译器必须知道变量的初始值，如果程序包含多个文件，则每个用了`const`对象的文件都必须能访问到它的初始值才行。要做到这一点，就必须在每一个用到该变量的文件中都对它有定义（将定义该`const`变量的语句放在头文件中，然后用到该变量的源文件包含头文件即可），为了支持这一用法，同时避免对同一变量的重复定义，默认情况下`const`被设定为尽在文件内有效（`const`的全局变量，其实只是在每个文件中都定义了一边而已）

有时候出现这样的情况：`const`变量的初始值不是一个常量表达式，但又确实有必要在文件间共享。这种情况下，我们不希望编译器为每个文件生成独立的变量，相反，我们想让这类`const`对象像其他对象一样工作。**即：在一个文件中定义`const`，在多个文件中声明并使用它，无论声明还是定 义都添加`extern`关键字**

* `.h`文件中：`extern const int a;`
* `.cpp`文件中：`extern const int a=f();`

#### 3.1.1.1 Top/Bottom Level const

**只有指针和引用才有顶层底层之分**

* 顶层`const`属性表示对象本身不可变
* 底层`const`属性表示指向的对象不可变
* 引用的`const`属性只能是底层。因为引用本身不是对象，没法指定顶层的`const`属性
* 指针的`const`属性既可以是顶层又可以是底层
    * 注意，只有`const`与`变量名`相邻时（中间不能有`*`），才算顶层`const`。例如下面例子中的`p1`和`p2`都是顶层`const`
* 指针的底层`const`是可以重新绑定的，例如下面例子中的`p1`和`p2`
* 引用的底层`const`是无法重新绑定的，这是因为引用本身就不支持重新绑定，而非`const`的限制

```cpp
int main() {
    int a = 0, b = 1, c = 2;

    // bottom level const
    const int* p1 = &a;
    p1 = &c;
    // *p1 += 1; // compile error

    // bottom level const
    int const* p2 = &b;
    p2 = &c;
    // *p2 += 1; // compile error

    // top level const
    int* const p3 = &c;
    // p3 = &a; // compile error
    *p3 += 1;

    const int& r1 = a;
    // r1 = b; // compile error
    // r1 += 1; // compile error

    return 0;
}
```

**`const`遵循如下规则：**

* 顶层`const`可以访问`const`和非`const`的成员
* 底层`const`只能访问`const`的成员

示例如下，可以发现：

* `const Container* container`以及`const Container& container`都只能访问`const`成员，而无法访问非`const`成员
* `Container* const container`可以访问`const`成员以及非`const`成员
* 特别地，`const ContainerPtr& container`可以访问非`const`成员，这是因为`container->push_back(num)`是一个两级调用
    * 第一级：访问的是`std::shared_ptr::operator->`运算符，该运算符是`const`的，且返回类型为`element_type*`
    * 第二级：通过返回的`element_type*`访问`std::vector::push_back`，因此与上述结论并不矛盾

```cpp
#include <stddef.h>

#include <memory>
#include <vector>

using Container = std::vector<int32_t>;
using ContainerPtr = std::shared_ptr<Container>;

void append_by_const_reference_shared_ptr(const ContainerPtr& container, const int num) {
    // can calling non-const member function
    container->push_back(num);
}

void append_by_const_reference(const Container& container, const int num) {
    // cannot calling non-const member function
    // container.push_back(num);
}

void append_by_bottom_const_pointer(const Container* container, const int num) {
    // cannot calling non-const member function
    // container->push_back(num);
}

void append_by_top_const_pointer(Container* const container, const int num) {
    // can calling non-const member function
    container->push_back(num);
}

int main() {
    return 0;
}
```

#### 3.1.1.2 const Actual and Formal Parameters

实参初始化形参时会自动忽略掉顶层`const`属性

顶层`const`不影响形参的类型，例如下面的代码，编译会失败，错误信息是函数重定义

```cpp
void func(int value) {}

void func(const int value) {}

int main() {
    int value = 5;
    func(value);
}
```

#### 3.1.1.3 const Member

构造函数中显式初始化：在初始化部分进行初始化，而不能在函数体内初始化；如果没有显式初始化，就调用定义时的初始值进行初始化

#### 3.1.1.4 const Member Function

**`const`关键字修饰的成员函数，不能修改当前类的任何字段的值，如果字段是对象类型，也不能调用非`const`修饰的成员方法。（有一个特例，就是当持有的是某个类型的指针时，可以通过该指针调用非`const`方法）**

常量对象以及常量对象的引用或指针都只能调用常量成员函数

常量对象以及常量对象的引用或指针都可以调用常量成员函数以及非常量成员函数

```cpp
#include <iostream>

class Demo {
public:
    void sayHello1() const {
        std::cout << "hello world, const version" << std::endl;
    }

    void sayHello2() {
        std::cout << "hello world, non const version" << std::endl;
    }
};

int main() {
    Demo d;
    d.sayHello1();
    d.sayHello2();

    const Demo cd;
    cd.sayHello1();
    // the following statement will lead to compile error
    // cd.sayHello2();
};
```

### 3.1.2 volatile

`volatile`关键字是一种类型修饰符，用它声明的类型变量表示可以被某些编译器未知的因素更改（程序之外的因素），比如：操作系统、硬件等。遇到这个关键字声明的变量，编译器对访问该变量的代码就不再进行优化，从而可以提供对特殊地址的稳定访问

* **仅从`C/C++`标准的角度来说（不考虑平台以及编译器扩展），`volatile`并不保证线程间的可见性**。在实际场景中，例如`x86`平台，在`MESI`协议的支持下，`volatile`是可以保证可见性的，这可以理解为一个巧合，利用了平台相关性，因此不具备平台可移植性

`Java`中也有`volatile`关键字，但作用完全不同，`Java`在语言层面就保证了`volatile`具有线程可见性

* `x86`
    * 仅依赖`MESI`协议，可能也无法实现可见性。举个例子，当`CPU1`执行写操作时，要等到其他`CPU`将对应的缓存行设置成`I`状态后，写入才能完成，性能较差，于是`CPU`又引入了`Store Buffer`（`MESI`协议不感知`Store Buffer`），`CPU1`只需要将数据写入`Store Buffer`而不用等待其他`CPU`将缓存行设置成`I`状态就可以干其他事了
    * 为了解决上述问题，`JVM`使用了`lock`前缀的汇编指令，将当前`Store Buffer`中的所有数据（不仅仅是`volatile`修饰的变量）都通过`MESI`写入
* 其他架构，采用其他方式来保证线程可见性这一承诺

**参考：**

* [Is volatile useful with threads?](https://isocpp.org/blog/2018/06/is-volatile-useful-with-threads-isvolatileusefulwiththreads.com)
    * [isvolatileusefulwiththreads](http://isvolatileusefulwiththreads.com/)
* [Volatile and cache behaviour](https://stackoverflow.com/questions/18695120/volatile-and-cache-behaviour)
* [你不认识的cc++ volatile](https://www.hitzhangjie.pro/blog/2019-01-07-%E4%BD%A0%E4%B8%8D%E8%AE%A4%E8%AF%86%E7%9A%84cc++-volatile/)

**示例如下：**

```sh
cat > volatile.cpp << 'EOF'
#include <atomic>

void read_from_normal(int32_t& src, int32_t& target) {
    target = src;
    target = src;
    target = src;
}

void read_from_volatile(volatile int32_t& src, int32_t& target) {
    target = src;
    target = src;
    target = src;
}

void read_from_atomic(std::atomic<int32_t>& src, int32_t& target) {
    target = src.load(std::memory_order_seq_cst);
    target = src.load(std::memory_order_relaxed);
    target = src.load(std::memory_order_release);
}

void write_to_normal(int32_t& src, int32_t& target) {
    target = src;
    target = src;
    target = src;
}

void write_to_volatile(int32_t& src, volatile int32_t& target) {
    target = src;
    target = src;
    target = src;
}

void write_to_atomic(int32_t& src, std::atomic<int32_t>& target) {
    target.store(src, std::memory_order_seq_cst);
    target.store(src, std::memory_order_relaxed);
    target.store(src, std::memory_order_release);
}
EOF

gcc -o volatile.o -c volatile.cpp -O3 -lstdc++ -std=gnu++17
objdump -drwCS volatile.o
```

**输出如下：**

* `read_from_normal`的三次操作被优化成了一次
* `write_to_normal`的三次操作被优化成了一次
* `write_to_atomic`中，`std::memory_order_seq_cst`使用的是[`xchg`指令](https://www.felixcloutier.com/x86/xchg)，当有一个操作数是内存地址时，会自动启用`locking protocol`，确保写操作的串行化

```
volatile.o:     file format elf64-x86-64

Disassembly of section .text:

0000000000000000 <read_from_normal(int&, int&)>:
   0:	f3 0f 1e fa          	endbr64
   4:	8b 07                	mov    (%rdi),%eax
   6:	89 06                	mov    %eax,(%rsi)
   8:	c3                   	ret
   9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000000010 <read_from_volatile(int volatile&, int&)>:
  10:	f3 0f 1e fa          	endbr64
  14:	8b 07                	mov    (%rdi),%eax
  16:	89 06                	mov    %eax,(%rsi)
  18:	8b 07                	mov    (%rdi),%eax
  1a:	89 06                	mov    %eax,(%rsi)
  1c:	8b 07                	mov    (%rdi),%eax
  1e:	89 06                	mov    %eax,(%rsi)
  20:	c3                   	ret
  21:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 cs nopw 0x0(%rax,%rax,1)
  2c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000000030 <read_from_atomic(std::atomic<int>&, int&)>:
  30:	f3 0f 1e fa          	endbr64
  34:	8b 07                	mov    (%rdi),%eax
  36:	89 06                	mov    %eax,(%rsi)
  38:	8b 07                	mov    (%rdi),%eax
  3a:	89 06                	mov    %eax,(%rsi)
  3c:	8b 07                	mov    (%rdi),%eax
  3e:	89 06                	mov    %eax,(%rsi)
  40:	c3                   	ret
  41:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 cs nopw 0x0(%rax,%rax,1)
  4c:	0f 1f 40 00          	nopl   0x0(%rax)

0000000000000050 <write_to_normal(int&, int&)>:
  50:	f3 0f 1e fa          	endbr64
  54:	8b 07                	mov    (%rdi),%eax
  56:	89 06                	mov    %eax,(%rsi)
  58:	c3                   	ret
  59:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000000060 <write_to_volatile(int&, int volatile&)>:
  60:	f3 0f 1e fa          	endbr64
  64:	8b 07                	mov    (%rdi),%eax
  66:	89 06                	mov    %eax,(%rsi)
  68:	89 06                	mov    %eax,(%rsi)
  6a:	8b 07                	mov    (%rdi),%eax
  6c:	89 06                	mov    %eax,(%rsi)
  6e:	c3                   	ret
  6f:	90                   	nop

0000000000000070 <write_to_atomic(int&, std::atomic<int>&)>:
  70:	f3 0f 1e fa          	endbr64
  74:	8b 07                	mov    (%rdi),%eax
  76:	87 06                	xchg   %eax,(%rsi)
  78:	8b 07                	mov    (%rdi),%eax
  7a:	89 06                	mov    %eax,(%rsi)
  7c:	8b 07                	mov    (%rdi),%eax
  7e:	89 06                	mov    %eax,(%rsi)
  80:	c3                   	ret
```

#### 3.1.2.1 Visibility Verification

首先明确一下`visibility`的概念，这里我对它的定义是：当`A`和`B`两个线程，`A`对变量`x`进行写操作，`B`对变量`x`进行读操作，若时间上写操作先发生于读操作时，读操作能够读取到写操作写入的值

这个问题比较难直接验证，我们打算用一种间接的方式来验证：

* 假设读操作和写操作的性能开销之比为`α`
* 开两个线程，分别循环执行读操作和写操作，读执行`n`次（期间持续进行写操作）。统计读线程，相邻两次读操作，读取数值不同的次数为`m`，`β=m/n`。
    * 若`α > 1`，即读比写更高效。如果满足可见性，那么`β`应该大致接近`1/α`
    * 若`α <= 1`，即读比写更低效。如果满足可见性，那么`β`应该接近1（写的值大概率被看见）

首先，测试`atomic`与`volatile`的读写性能

* 测试时，会有一个额外的线程对`atomic`或`volatile`变量进行持续的读写操作

```cpp
#include <benchmark/benchmark.h>

#include <atomic>
#include <thread>

std::atomic<uint64_t> atomic_value{0};
uint64_t volatile volatile_value = 0;

constexpr size_t RAND_ROUND_SIZE = 1000000;

static void volatile_random_write(volatile uint64_t& value, std::atomic<bool>& stop) {
    uint32_t tmp = 1;
    while (!stop.load(std::memory_order_relaxed)) {
        for (size_t i = 0; i < RAND_ROUND_SIZE; i++) {
            value = tmp;
            tmp++;
        }
    }
}

static void volatile_random_read(volatile uint64_t& value, std::atomic<bool>& stop) {
    uint64_t tmp;
    while (!stop.load(std::memory_order_relaxed)) {
        for (size_t i = 0; i < RAND_ROUND_SIZE; i++) {
            tmp = value;
        }
    }
    benchmark::DoNotOptimize(tmp);
}

template <std::memory_order order>
static void atomic_random_write(std::atomic<uint64_t>& value, std::atomic<bool>& stop) {
    uint32_t tmp = 1;
    while (!stop.load(std::memory_order_relaxed)) {
        for (size_t i = 0; i < RAND_ROUND_SIZE; i++) {
            value.store(tmp, order);
            tmp++;
        }
    }
}

template <std::memory_order order>
static void atomic_random_read(std::atomic<uint64_t>& value, std::atomic<bool>& stop) {
    uint64_t tmp;
    while (!stop.load(std::memory_order_relaxed)) {
        for (size_t i = 0; i < RAND_ROUND_SIZE; i++) {
            tmp = value.load(order);
        }
    }
    benchmark::DoNotOptimize(tmp);
}

template <std::memory_order order>
static void atomic_read(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { atomic_random_write<order>(atomic_value, stop); });
    for (auto _ : state) {
        tmp = atomic_value.load(order);
    }
    benchmark::DoNotOptimize(tmp);
    stop = true;
    t.join();
}

template <std::memory_order order>
static void atomic_write(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { atomic_random_read<order>(atomic_value, stop); });
    for (auto _ : state) {
        atomic_value.store(tmp, order);
        tmp++;
    }
    stop = true;
    t.join();
}

static void volatile_read(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { volatile_random_write(volatile_value, stop); });
    for (auto _ : state) {
        tmp = volatile_value;
    }
    benchmark::DoNotOptimize(tmp);
    stop = true;
    t.join();
}

static void volatile_write(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { volatile_random_read(volatile_value, stop); });
    for (auto _ : state) {
        volatile_value = tmp;
        tmp++;
    }
    stop = true;
    t.join();
}

BENCHMARK(atomic_read<std::memory_order_seq_cst>);
BENCHMARK(atomic_write<std::memory_order_seq_cst>);
BENCHMARK(atomic_read<std::memory_order_relaxed>);
BENCHMARK(atomic_write<std::memory_order_relaxed>);
BENCHMARK(volatile_read);
BENCHMARK(volatile_write);

BENCHMARK_MAIN();
```

结果如下：

* 对于`atomic<uint64_t>, std::memory_order_seq_cst`
    * `α = 28.9/1.24 = 23.30 > 1`
    * `β`的预期值为`1/α = 0.043`
* 对于`atomic<uint64_t>, std::memory_order_relaxed`
    * `α = 0.391/1.38 = 0.28 < 1`
    * `β`的预期值为`1`
* 对于`volatile`
    * `α = 0.331/1.33 = 0.25 < 1`
    * `β`的预期值为`1`

```
----------------------------------------------------------------------------------
Benchmark                                        Time             CPU   Iterations
----------------------------------------------------------------------------------
atomic_read<std::memory_order_seq_cst>        1.24 ns         1.24 ns    577159059
atomic_write<std::memory_order_seq_cst>       28.9 ns         28.9 ns     23973114
atomic_read<std::memory_order_relaxed>        1.38 ns         1.38 ns    595494132
atomic_write<std::memory_order_relaxed>      0.391 ns        0.391 ns   1000000000
volatile_read                                 1.33 ns         1.33 ns    551154517
volatile_write                               0.331 ns        0.331 ns   1000000000
```

同一个环境，测试程序如下：

```cpp
#include <atomic>
#include <iostream>
#include <thread>

constexpr uint64_t SIZE = 1000000000;

void test_volatile(volatile uint64_t& value, const std::string& description) {
    std::atomic<bool> stop{false};
    std::thread write_thread([&]() {
        while (!stop.load(std::memory_order_relaxed)) {
            for (uint64_t i = 0; i < SIZE; i++) {
                value = i;
            }
        }
    });

    std::thread read_thread([&]() {
        uint64_t prev_value = 0;
        uint64_t non_diff_cnt = 0;
        uint64_t diff_cnt = 0;
        uint64_t cur_value;
        for (uint64_t i = 0; i < SIZE; i++) {
            cur_value = value;

            // These two statements have little overhead which can be ignored if enable -03
            cur_value == prev_value ? non_diff_cnt++ : diff_cnt++;
            prev_value = cur_value;
        }
        std::cout << description << ", β=" << static_cast<double>(diff_cnt) / SIZE << std::endl;
    });
    read_thread.join();
    stop = true;
    write_thread.join();
}

template <std::memory_order order>
void test_atomic(std::atomic<uint64_t>& value, const std::string& description) {
    std::atomic<bool> stop{false};
    std::thread write_thread([&]() {
        while (!stop.load(std::memory_order_relaxed)) {
            for (uint64_t i = 0; i < SIZE; i++) {
                value.store(i, order);
            }
        }
    });

    std::thread read_thread([&]() {
        uint64_t prev_value = 0;
        uint64_t non_diff_cnt = 0;
        uint64_t diff_cnt = 0;
        uint64_t cur_value;
        for (uint64_t i = 0; i < SIZE; i++) {
            cur_value = value.load(order);

            // These two statements have little overhead which can be ignored if enable -03
            cur_value == prev_value ? non_diff_cnt++ : diff_cnt++;
            prev_value = cur_value;
        }
        std::cout << description << ", β=" << static_cast<double>(diff_cnt) / SIZE << std::endl;
    });
    read_thread.join();
    stop = true;
    write_thread.join();
}

int main() {
    {
        std::atomic<uint64_t> value = 0;
        test_atomic<std::memory_order_seq_cst>(value, "atomic<uint64_t>, std::memory_order_seq_cst");
        test_atomic<std::memory_order_relaxed>(value, "atomic<uint64_t>, std::memory_order_relaxed");
    }
    {
        uint64_t volatile value = 0;
        test_volatile(value, "volatile");
    }
    return 0;
}
```

结果如下（`volatile`以及`std::memory_order_relaxed`的行为是平台相关的，测试环境是x86，实验结果不具备平台扩展性）：

* `std::memory_order_seq_cst`符合预期
* `std::memory_order_relaxed`、`volatile`都不符合预期。这两者都不具备`visibility`
* 导致这一现象的原因，我的猜想如下：
    * x86会用到一种硬件优化，`Store Buffer`用于加速写操作
    * `std::memory_order_seq_cst`的写操作，会立即将`Store Buffer`刷入内存
    * `std::memory_order_relaxed`、`volatile`的写操作，会写入`Store Buffer`，当容量满了之后，刷入内存
    * 将`Store Buffer`填充满所需的时间很短。于是上述代码等价于`std::memory_order_seq_cst`每次写操作写一次内存，`std::memory_order_relaxed`、`volatile`的一批写操作写一次内存。写内存的频率接近。于是这三种情况下，`β`相近

```
atomic<uint64_t>, std::memory_order_seq_cst, β=0.0283726
atomic<uint64_t>, std::memory_order_relaxed, β=0.0276697
volatile, β=0.0271394
```

**如果用Java进行上述等价验证，会发现实际结果与预期吻合，这里不再赘述**

#### 3.1.2.2 Atomicity Verification

`std::atomic`可以为其他非原子变量提供`happens-before`关系

* `normal-write happens-before atomic-write`
* `atomic-write happens-before atomic-read`
* `atomic-read happens-before normal-read`
* 推导出`normal-write happens-before normal-read`

此外，由于测试机器是x86的，x86是`TSO`模型，`std::memory_order_relaxed`同样满足`atomic-write happens-before atomic-read`规则，只不过生成的指令更接近`volatile`，因此这里使用`std::memory_order_relaxed`，便于对比两者指令的差异

```cpp
#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>

constexpr int32_t INVALID_VALUE = -1;
constexpr int32_t EXPECTED_VALUE = 99;
constexpr int32_t TIMES = 1000000;

int32_t data;
std::atomic<bool> atomic_data_ready(false);
volatile bool volatile_data_ready(false);

void atomic_reader() {
    for (auto i = 0; i < TIMES; i++) {
        while (!atomic_data_ready.load(std::memory_order_relaxed))
            ;

        assert(data == EXPECTED_VALUE);

        data = INVALID_VALUE;
        atomic_data_ready.store(false, std::memory_order_relaxed);
    }
}

void atomic_writer() {
    for (auto i = 0; i < TIMES; i++) {
        while (atomic_data_ready.load(std::memory_order_relaxed))
            ;

        data = EXPECTED_VALUE;

        atomic_data_ready.store(true, std::memory_order_relaxed);
    }
}

void test_atomic_visibility() {
    data = INVALID_VALUE;
    atomic_data_ready = false;

    std::thread t1(atomic_reader);
    std::thread t2(atomic_writer);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    t1.join();
    t2.join();
}

void volatile_reader() {
    for (auto i = 0; i < TIMES; i++) {
        while (!volatile_data_ready)
            ;

        assert(data == EXPECTED_VALUE);

        data = INVALID_VALUE;
        volatile_data_ready = false;
    }
}

void volatile_writer() {
    for (auto i = 0; i < TIMES; i++) {
        while (volatile_data_ready)
            ;

        data = EXPECTED_VALUE;

        volatile_data_ready = true;
    }
}

void test_volatile_visibility() {
    data = INVALID_VALUE;
    volatile_data_ready = false;

    std::thread t1(volatile_reader);
    std::thread t2(volatile_writer);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    t1.join();
    t2.join();
}

int main() {
    test_atomic_visibility();
    test_volatile_visibility();
    return 0;
}
```

以`-O3`优化级别进行编译，查看其汇编指令，可以发现：

* `volatile_writer`中，`data`的赋值被优化到了循环外，`volatile_data_ready`每次循环都会进行一次赋值（这种优化破坏了程序的本意）
* `atomic_writer`中，由于内存屏障的存在（`std::atomic`的写操作），`data`的赋值并未被优化到循环外。`data`和`atomic_data_ready`每次循环都会被赋值（符合程序本意）

```
00000000000013c0 <volatile_writer()>:
    13c0:	f3 0f 1e fa          	endbr64
    13c4:	ba 40 42 0f 00       	mov    $0xf4240,%edx
    13c9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    13d0:	0f b6 05 45 2c 00 00 	movzbl 0x2c45(%rip),%eax        # 401c <volatile_data_ready>
    13d7:	84 c0                	test   %al,%al
    13d9:	75 f5                	jne    13d0 <volatile_writer()+0x10>
    13db:	c6 05 3a 2c 00 00 01 	movb   $0x1,0x2c3a(%rip)        # 401c <volatile_data_ready>
    13e2:	83 ea 01             	sub    $0x1,%edx
    13e5:	75 e9                	jne    13d0 <volatile_writer()+0x10>
    13e7:	c7 05 2f 2c 00 00 63 00 00 00 	movl   $0x63,0x2c2f(%rip)        # 4020 <data>
    13f1:	c6 05 24 2c 00 00 01 	movb   $0x1,0x2c24(%rip)        # 401c <volatile_data_ready>
    13f8:	c3                   	ret
    13f9:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)

0000000000001400 <atomic_writer()>:
    1400:	f3 0f 1e fa          	endbr64
    1404:	ba 40 42 0f 00       	mov    $0xf4240,%edx
    1409:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
    1410:	0f b6 05 06 2c 00 00 	movzbl 0x2c06(%rip),%eax        # 401d <atomic_data_ready>
    1417:	84 c0                	test   %al,%al
    1419:	75 f5                	jne    1410 <atomic_writer()+0x10>
    141b:	c7 05 fb 2b 00 00 63 00 00 00 	movl   $0x63,0x2bfb(%rip)        # 4020 <data>
    1425:	c6 05 f1 2b 00 00 01 	movb   $0x1,0x2bf1(%rip)        # 401d <atomic_data_ready>
    142c:	83 ea 01             	sub    $0x1,%edx
    142f:	75 df                	jne    1410 <atomic_writer()+0x10>
    1431:	c3                   	ret
    1432:	66 66 2e 0f 1f 84 00 00 00 00 00 	data16 cs nopw 0x0(%rax,%rax,1)
    143d:	0f 1f 00             	nopl   (%rax)
```

如果以`-O0`优化级别进行编译，则上述程序中的断言不会报错

### 3.1.3 mutable

容许常量类类型对象修改相应类成员

```cpp
#include <cstdint>

class Foo {
public:
    void set(int32_t data) const { this->data = data; }

private:
    mutable int32_t data;
};
```

## 3.2 Other Specifiers

### 3.2.1 inline

[C++ 关键词：inline](https://zh.cppreference.com/w/cpp/keyword/inline)

* 在用于函数的声明说明符序列时，将函数声明为一个内联函数
    * 整个定义都在`class/struct/union`的定义内且被附着到全局模块（C++20 起）的函数是隐式的内联函数，无论它是成员函数还是非成员`friend`函数
    * `inline`关键词的本意是作为给优化器的指示器，以指示优先采用函数的内联替换而非进行函数调用，即并不执行将控制转移到函数体内的函数调用CPU指令，而是代之以执行函数体的一份副本而无需生成调用。这会避免函数调用的开销（传递实参及返回结果），但它可能导致更大的可执行文件，因为函数体必须被复制多次
    * 因为关键词`inline`的含义是非强制的，编译器拥有对任何未标记为`inline`的函数使用内联替换的自由，和对任何标记为`inline`的函数生成函数调用的自由。这些优化选择不改变上述关于多个定义和共享静态变量的规则
    * 声明有`constexpr`的函数是隐式的内联函数
* 在用于具有静态存储期的变量（静态类成员或命名空间作用域变量）的声明说明符序列时，将变量声明为内联变量
    * 声明为`constexpr`的静态成员变量（但不是命名空间作用域变量）是隐式的内联变量

## 3.3 Type Length

### 3.3.1 Memory Alignment

**内存对齐最最底层的原因是内存的IO是以`8`个字节`64bit`为单位进行的**

假如你指定要获取的是`0x0001-0x0008`，也是8字节，但是不是0开头的，内存需要怎么工作呢？没有好办法，内存只好先工作一次把`0x0000-0x0007`取出来，然后再把`0x0008-0x0015`取出来，把两次的结果都返回给你。CPU和内存IO的硬件限制导致没办法一次跨在两个数据宽度中间进行IO。这样你的应用程序就会变慢，算是计算机因为你不懂内存对齐而给你的一点点惩罚

**内存对齐规则**

1. **结构体第一个成员的偏移量`offset`为`0`，以后每个成员相对于结构体首地址的`offset`都是该成员大小与`有效对齐值`中较小那个的整数倍，如有需要编译器会在成员之间加上填充字节**
1. **结构体的总大小为`有效对齐值`的整数倍，如有需要编译器会在最末一个成员之后加上填充字节**
* **有效对齐值：是给定值`#pragma pack(n)`和结构体中最长数据类型长度中较小的那个。有效对齐值也叫对齐单位。gcc中默认`#pragma pack(4)`，可以通过预编译命令`#pragma pack(n)，n = 1,2,4,8,16`来改变这一系数**

**下面以一个例子来说明**

```cpp
#include <iostream>

struct Align1 {
    int8_t f1;
};

struct Align2 {
    int8_t f1;
    int16_t f2;
};

struct Align3 {
    int8_t f1;
    int16_t f2;
    int32_t f3;
};

struct Align4 {
    int8_t f1;
    int16_t f2;
    int32_t f3;
    int64_t f4;
};

int main() {
    std::cout << "Align1's size = " << sizeof(Align1) << std::endl;
    std::cout << "\tf1's offset = " << offsetof(Align1, f1) << ", f1's size = " << sizeof(Align1::f1) << std::endl;
    std::cout << std::endl;

    std::cout << "Align2's size = " << sizeof(Align2) << std::endl;
    std::cout << "\tf1's offset = " << offsetof(Align2, f1) << ", f1's size = " << sizeof(Align2::f1) << std::endl;
    std::cout << "\tf2's offset = " << offsetof(Align2, f2) << ", f2's size = " << sizeof(Align2::f2) << std::endl;
    std::cout << std::endl;

    std::cout << "Align3's size = " << sizeof(Align3) << std::endl;
    std::cout << "\tf1's offset = " << offsetof(Align3, f1) << ", f1's size = " << sizeof(Align3::f1) << std::endl;
    std::cout << "\tf2's offset = " << offsetof(Align3, f2) << ", f2's size = " << sizeof(Align3::f2) << std::endl;
    std::cout << "\tf3's offset = " << offsetof(Align3, f3) << ", f3's size = " << sizeof(Align3::f3) << std::endl;
    std::cout << std::endl;

    std::cout << "Align4's size = " << sizeof(Align4) << std::endl;
    std::cout << "\tf1's offset = " << offsetof(Align4, f1) << ", f1's size = " << sizeof(Align4::f1) << std::endl;
    std::cout << "\tf2's offset = " << offsetof(Align4, f2) << ", f2's size = " << sizeof(Align4::f2) << std::endl;
    std::cout << "\tf3's offset = " << offsetof(Align4, f3) << ", f3's size = " << sizeof(Align4::f3) << std::endl;
    std::cout << "\tf4's offset = " << offsetof(Align4, f4) << ", f4's size = " << sizeof(Align4::f4) << std::endl;
    std::cout << std::endl;
    return 0;
}
```

**执行结果如下**

* 由于每个成员的offset必须是该成员与`有效对齐值`中较小的那个值的整数倍，下面称较小的这个值为`成员有效对齐值`
* `Align1`：最长数据类型的长度是`1`，pack=`4`，因此，`有效对齐值`是`min(1, 4) = 1`
    * 规则1：
        * `f1`，第一个成员的`offset = 0`
    * 规则2：
        * 类型总长度为`1`，是`有效对齐值（1）`的整数倍
* `Align2`：最长数据类型的长度是`2`，pack=`4`，因此，`有效对齐值`是`min(2, 4) = 2`
    * 规则1：
        * `f1`，第一个成员的`offset = 0`
        * `f2`，类型长度为`2`，因此，`成员有效对齐值`是`min(2, 2) = 2`。`offset = 2`是`成员有效对齐值（2)`的整数倍
    * 规则2：
        * 类型总长度为`4`，是`有效对齐值（2）`的整数倍
* `Align3`：最长数据类型的长度是`4`，pack=`4`，因此，`有效对齐值`是`min(4, 4) = 4`
    * 规则1：
        * `f1`，第一个成员的`offset = 0`
        * `f2`，类型长度为`2`，因此，`成员有效对齐值`是`min(2, 4) = 2`。`offset = 2`是`成员有效对齐值（2)`的整数倍
        * `f3`，类型长度为`4`，因此，`成员有效对齐值`是`min(4, 4) = 4`。`offset = 4`是`成员有效对齐值（4)`的整数倍
    * 规则2：
        * 类型总长度为`8`，是`有效对齐值（4）`的整数倍
* `Align4`：最长数据类型的长度是`8`，pack=`4`，因此，`有效对齐值`是`min(8, 4) = 4`
    * 规则1：
        * `f1`，第一个成员的`offset = 0`
        * `f2`，类型长度为`2`，因此，`成员有效对齐值`是`min(2, 4) = 2`。`offset = 2`是`成员有效对齐值（2)`的整数倍
        * `f3`，类型长度为`4`，因此，`成员有效对齐值`是`min(4, 4) = 4`。`offset = 4`是`成员有效对齐值（4)`的整数倍
        * `f4`，类型长度为`8`，因此，`成员有效对齐值`是`min(8, 4) = 4`。`offset = 8`是`成员有效对齐值（4)`的整数倍
    * 规则2：
        * 类型总长度为`16`，是`有效对齐值（4）`的整数倍

```
Align1's size = 1
    f1's offset = 0, f1's size = 1

Align2's size = 4
    f1's offset = 0, f1's size = 1
    f2's offset = 2, f2's size = 2

Align3's size = 8
    f1's offset = 0, f1's size = 1
    f2's offset = 2, f2's size = 2
    f3's offset = 4, f3's size = 4

Align4's size = 16
    f1's offset = 0, f1's size = 1
    f2's offset = 2, f2's size = 2
    f3's offset = 4, f3's size = 4
    f4's offset = 8, f4's size = 8
```

### 3.3.2 sizeof

**`sizeof`用于获取对象的内存大小**

* `sizeof(int32_t)`：4
* `sizeof(char[2][2][2])`：8

### 3.3.3 alignof

**`alignof`用于获取对象的有效对齐值。`alignas`用于设置有效对其值（不允许小于默认的有效对齐值）**

```cpp
#include <iostream>

struct Foo1 {
    char c;
    int32_t i32;
};

// Compile error
// Requested alignment is less than minimum int alignment of 4 for type 'Foo2'
// struct alignas(1) Foo2 {
//     char c;
//     int32_t i32;
// };

// Compile error
// Requested alignment is less than minimum int alignment of 4 for type 'Foo3'
// struct alignas(2) Foo3 {
//     char c;
//     int32_t i32;
// };

struct alignas(4) Foo4 {
    char c;
    int32_t i32;
};

struct alignas(8) Foo5 {
    char c;
    int32_t i32;
};

struct alignas(16) Foo6 {
    char c;
    int32_t i32;
};

#define PRINT_SIZE(name)                                                                                      \
    std::cout << "sizeof(" << #name << ")=" << sizeof(name) << ", alignof(" << #name << ")=" << alignof(name) \
              << std::endl;

int main() {
    PRINT_SIZE(Foo1);
    PRINT_SIZE(Foo4);
    PRINT_SIZE(Foo5);
    PRINT_SIZE(Foo6);
    return 0;
}
```

输出如下：

```
sizeof(Foo1)=8, alignof(Foo1)=4
sizeof(Foo4)=8, alignof(Foo4)=4
sizeof(Foo5)=8, alignof(Foo5)=8
sizeof(Foo6)=16, alignof(Foo6)=16
```

### 3.3.4 alignas

`alignas`类型说明符是一种可移植的`C++`标准方法，用于指定变量和自定义类型的对齐方式，可以在定义 `class`、`struct`、`union`或声明变量时使用。如果遇到多个`alignas`说明符，编译器会选择最严格的那个（最大对齐值）

内存对齐可以使处理器更好地利用`cache`，包括减少`cache line`访问，以及避免多核一致性问题引发的 `cache miss`。具体来说，在多线程程序中，一种常用的优化手段是将需要高频并发访问的数据按`cache line`大小（通常为`64`字节）对齐。一方面，对于小于`64`字节的数据可以做到只触及一个`cache line`，减少访存次数；另一方面，相当于独占了整个`cache line`，避免其他数据可能修改同一`cache line`导致其他核`cache miss`的开销

**数组：对数组使用`alignas`，对齐的是数组的首地址，而不是每个数组元素。也就是说，下面这个数组并不是每个`int`都占`64`字节。如果一定要让每个元素都对齐，可以定义一个`struct`，如`int_align_64`**

```cpp
#include <iostream>

int array1[10];

struct alignas(64) int_align_64 {
    int a;
};
int_align_64 array2[10];

#define PRINT_SIZEOF(element) std::cout << "sizeof(" << #element << ")=" << sizeof(element) << std::endl
#define PRINT_ALIGNOF(element) std::cout << "alignof(" << #element << ")=" << alignof(element) << std::endl

int main(int argc, char* argv[]) {
    PRINT_SIZEOF(array1[1]);
    PRINT_SIZEOF(array2[1]);

    PRINT_ALIGNOF(decltype(array1));
    PRINT_ALIGNOF(decltype(array2));

    PRINT_ALIGNOF(decltype(array1[1]));
    PRINT_ALIGNOF(decltype(array2[1]));
    return 0;
}
```

```
sizeof(array1[1])=4
sizeof(array2[1])=64
alignof(decltype(array1))=4
alignof(decltype(array2))=64
alignof(decltype(array1[1]))=4
alignof(decltype(array2[1]))=64
```

## 3.4 Type Inference

### 3.4.1 auto

**`auto`会忽略顶层`const`，保留底层的`const`，但是当设置一个类型为`auto`的引用时，初始值中的顶层常量属性仍然保留**

### 3.4.2 decltype

* **`decltype`会保留变量的所有类型信息（包括顶层`const`和引用在内）**
* 如果表达式的内容是解引用操作，得到的将是引用类型
    * `int i = 42;`
    * `int *p = &i;`
    * `decltype(*p)`得到的是`int&`
* **`decltype((c))`会得到`c`的引用类型（无论`c`本身是不是引用）**

```cpp
#include <iostream>
#include <type_traits>

#define print_type_info(exp)                                                                     \
    do {                                                                                         \
        std::cout << #exp << ": " << std::endl;                                                  \
        std::cout << "\tis_reference_v=" << std::is_reference_v<exp> << std::endl;               \
        std::cout << "\tis_lvalue_reference_v=" << std::is_lvalue_reference_v<exp> << std::endl; \
        std::cout << "\tis_rvalue_reference_v=" << std::is_rvalue_reference_v<exp> << std::endl; \
        std::cout << "\tis_const_v=" << std::is_const_v<exp> << std::endl;                       \
        std::cout << "\tis_pointer_v=" << std::is_pointer_v<exp> << std::endl;                   \
        std::cout << std::endl;                                                                  \
    } while (0)

int main() {
    int num1 = 0;
    int& num2 = num1;
    const int& num3 = num1;
    int&& num4 = 0;
    int* ptr1 = &num1;
    int* const ptr2 = &num1;
    const int* ptr3 = &num1;

    print_type_info(decltype(0));
    print_type_info(decltype((0)));

    print_type_info(decltype(num1));
    print_type_info(decltype((num1)));

    print_type_info(decltype(num2));
    print_type_info(decltype(num3));
    print_type_info(decltype(num4));

    print_type_info(decltype(ptr1));
    print_type_info(decltype(*ptr1));

    print_type_info(decltype(ptr2));
    print_type_info(decltype(*ptr2));

    print_type_info(decltype(ptr3));
    print_type_info(decltype(*ptr3));
}
```

**输出如下：**

```
decltype(0):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype((0)):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(num1):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype((num1)):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(num2):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(num3):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(num4):
    is_reference_v=1
    is_lvalue_reference_v=0
    is_rvalue_reference_v=1
    is_const_v=0
    is_pointer_v=0

decltype(ptr1):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=1

decltype(*ptr1):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(ptr2):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=1
    is_pointer_v=1

decltype(*ptr2):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0

decltype(ptr3):
    is_reference_v=0
    is_lvalue_reference_v=0
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=1

decltype(*ptr3):
    is_reference_v=1
    is_lvalue_reference_v=1
    is_rvalue_reference_v=0
    is_const_v=0
    is_pointer_v=0
```

此外，`decltype`发生在编译期，即它不会产生任何运行时的代码。示例如下，编译执行后，可以发现`say_hello`并未执行

```cpp
#include <iostream>

int say_hello() {
    std::cout << "hello" << std::endl;
    return 0;
}

int main() {
    decltype(say_hello()) a;
    return 0;
}
```

### 3.4.3 typeof

**非`C++`标准**

### 3.4.4 typeid

**`typeid`运算符允许在运行时确定对象的类型。若要判断是父类还是子类的话，那么父类必须包含虚函数**

```cpp
#define CHECK_TYPE(left, right)                                                            \
    std::cout << "typeid(" << #left << ") == typeid(" << #right << "): " << std::boolalpha \
              << (typeid(left) == typeid(right)) << std::noboolalpha << std::endl;

class BaseWithoutVirtualFunc {};

class DeriveWithoutVirtualFunc : public BaseWithoutVirtualFunc {};

class BaseWithVirtualFunc {
public:
    virtual void func() {}
};

class DeriveWithVirtualFunc : public BaseWithVirtualFunc {};

int main() {
    std::string str;
    CHECK_TYPE(str, std::string);

    BaseWithoutVirtualFunc* ptr1 = nullptr;
    CHECK_TYPE(*ptr1, BaseWithoutVirtualFunc);
    CHECK_TYPE(*ptr1, DeriveWithoutVirtualFunc);

    BaseWithoutVirtualFunc* ptr2 = new BaseWithoutVirtualFunc();
    CHECK_TYPE(*ptr2, BaseWithoutVirtualFunc);
    CHECK_TYPE(*ptr2, DeriveWithoutVirtualFunc);

    BaseWithoutVirtualFunc* ptr3 = new DeriveWithoutVirtualFunc();
    CHECK_TYPE(*ptr3, BaseWithoutVirtualFunc);
    CHECK_TYPE(*ptr3, DeriveWithoutVirtualFunc);

    BaseWithVirtualFunc* ptr4 = new BaseWithVirtualFunc();
    CHECK_TYPE(*ptr4, BaseWithVirtualFunc);
    CHECK_TYPE(*ptr4, DeriveWithVirtualFunc);

    BaseWithVirtualFunc* ptr5 = new DeriveWithVirtualFunc();
    CHECK_TYPE(*ptr5, BaseWithVirtualFunc);
    CHECK_TYPE(*ptr5, DeriveWithVirtualFunc);
}
```

输出如下：

```
typeid(str) == typeid(std::string): true
typeid(*ptr1) == typeid(BaseWithoutVirtualFunc): true
typeid(*ptr1) == typeid(DeriveWithoutVirtualFunc): false
typeid(*ptr2) == typeid(BaseWithoutVirtualFunc): true
typeid(*ptr2) == typeid(DeriveWithoutVirtualFunc): false
typeid(*ptr3) == typeid(BaseWithoutVirtualFunc): true
typeid(*ptr3) == typeid(DeriveWithoutVirtualFunc): false
typeid(*ptr4) == typeid(BaseWithVirtualFunc): true
typeid(*ptr4) == typeid(DeriveWithVirtualFunc): false
typeid(*ptr5) == typeid(BaseWithVirtualFunc): false
typeid(*ptr5) == typeid(DeriveWithVirtualFunc): true
```

**此外，还可以使用`dynamic_cast`来判断指针指向子类还是父类**

```cpp
#define CHECK_TYPE(left, right)                                                                   \
    std::cout << "dynamic_cast<" << #right << ">(" << #left << ") != nullptr: " << std::boolalpha \
              << (dynamic_cast<right>(left) != nullptr) << std::noboolalpha << std::endl;

class Base {
public:
    virtual ~Base() {}
};

class Derive : public Base {
    virtual ~Derive() {}
};

int main() {
    Base* ptr1 = nullptr;
    CHECK_TYPE(ptr1, Base*);
    CHECK_TYPE(ptr1, Derive*);

    Base* ptr2 = new Base();
    CHECK_TYPE(ptr2, Base*);
    CHECK_TYPE(ptr2, Derive*);

    Base* ptr3 = new Derive();
    CHECK_TYPE(ptr3, Base*);
    CHECK_TYPE(ptr3, Derive*);
}
```

输出如下：

```
dynamic_cast<Base*>(ptr1) != nullptr: false
dynamic_cast<Derive*>(ptr1) != nullptr: false
dynamic_cast<Base*>(ptr2) != nullptr: true
dynamic_cast<Derive*>(ptr2) != nullptr: false
dynamic_cast<Base*>(ptr3) != nullptr: true
dynamic_cast<Derive*>(ptr3) != nullptr: true
```

## 3.5 Type Conversion

### 3.5.1 static_cast

**用法：`static_cast<type> (expr)`**

`static_cast`运算符执行非动态转换，没有运行时类检查来保证转换的安全性。例如，它可以用来把一个基类指针转换为派生类指针。任何具有明确意义的类型转换，只要不包含底层`const`，都可以使用`static_cast`

```cpp
#include <iostream>
#include <string>

int main() {
    const char *cc = "hello, world";
    auto s = static_cast<std::string>(cc);
    std::cout << s << std::endl;

    // compile error
    // auto i = static_cast<int>(cc);
}
```

**注意，若待转换类型既不是引用类型，也不是指针类型时，会调用该类型的拷贝构造函数**

```cpp
#include <iostream>
class Foo {
public:
    Foo() { std::cout << "Foo's default ctor" << std::endl; }
    Foo(const Foo& foo) { std::cout << "Foo's copy ctor" << std::endl; }

    void something() {}
};

int main() {
    Foo* f = new Foo();
    static_cast<Foo>(*f).something();
}
```

### 3.5.2 dynamic_cast

**用法：`dynamic_cast<type> (expr)`**

`dynamic_cast`通常用于在继承结构之间进行转换，在运行时执行转换，验证转换的有效性。`type`必须是类的指针、类的引用或者`void*`。若指针转换失败，则得到的是`nullptr`；若引用转换失败，那么会抛出`std::bad_cast`类型的异常

```cpp
#include <iostream>
#include <string>

class Base {
public:
    virtual void func() const {
        std::cout << "Base's func" << std::endl;
    }
};

class Derive : public Base {
public:
    void func() const override {
        std::cout << "Derive's func" << std::endl;
    }
};

int main() {
    const Base &b = Derive{};
    try {
        auto &d = dynamic_cast<const Derive &>(b);
        d.func();
        auto &s = dynamic_cast<const std::string &>(b); // error case
    } catch (std::bad_cast &err) {
        std::cout << "err=" << err.what() << std::endl;
    }

    const Base *pb = &b;
    auto *pd = dynamic_cast<const Derive *>(pb);
    pd->func();
    auto *ps = dynamic_cast<const std::string *>(pb); // error case
    std::cout << "ps=" << ps << std::endl; // print nullptr
}
```

### 3.5.3 const_cast

**用法：`const_cast<type> (expr)`**

这种类型的转换主要是用来操作所传对象的`const`属性，可以加上`const`属性，也可以去掉`const`属性（顶层底层均可）。其中，`type`只能是如下几类（必须是引用或者指针类型）

* `T &`
* `const T &`
* `T &&`
* `T *`
* `const T *`
* `T *const`
* `const T *const`

```cpp
#include <iostream>

int main() {
    std::cout << "const T & -> T &" << std::endl;
    const int &v1 = 100;
    std::cout << "v1's address=" << &v1 << std::endl;
    int &v2 = const_cast<int &>(v1);
    v2 = 200;
    std::cout << "v2's address=" << &v2 << std::endl;

    std::cout << "\nT & -> T &&" << std::endl;
    int &&v3 = const_cast< int &&>(v2);
    std::cout << "v3's address=" << &v3 << std::endl;

    std::cout << "\nT * -> const T *const" << std::endl;
    int *p1 = &v2;
    std::cout << "p1=" << p1 << std::endl;
    const int *const p2 = const_cast<const int *const >(p1);
    std::cout << "p2=" << p2 << std::endl;
}
```

### 3.5.4 reinterpret_cast

**用法：`reinterpret_cast<type> (expr)`**

`reinterpret_cast`是最危险的类型转换，它能够直接将一种类型的指针转换为另一种类型的指针，应该非常谨慎地使用。在很大程度上，使用`reinterpret_cast`获得的唯一保证是，通常如果你将结果转换回原始类型，您将获得完全相同的值（但如果中间类型小于原始类型，则不会）。也有许多`reinterpret_cast`不能做的转换。它主要用于特别奇怪的转换和位操作，例如将原始数据流转换为实际数据，或将数据存储在指向对齐数据的指针的低位中

```cpp
#include <iostream>
#include <vector>

int main() {
    int32_t i = 0x7FFFFFFF;
    int32_t *pi = &i;

    {
        auto *pl = reinterpret_cast<int64_t *> (pi);
        std::cout << *pl << std::endl;
        auto *rebuild_pi = reinterpret_cast<int32_t *> (pl);
        std::cout << *rebuild_pi << std::endl;
    }
}
```

## 3.6 Storage Class Specifiers

[Storage class specifiers](https://en.cppreference.com/w/cpp/language/storage_duration)

In C++, storage classes determine the scope, visibility, and lifetime of variables. There are four storage classes in C++:

1. **Automatic Storage Class (default)**: Variables declared within a block or function without specifying a storage class are considered to have automatic storage class. These variables are created when the block or function is entered and destroyed when the block or function is exited. The keyword "auto" can also be used explicitly, although it is optional.
1. **Static Storage Class**: Variables with static storage class are created and initialized only once, and their values persist across function calls. They are initialized to zero by default. Static variables can be declared within a block or function, but their scope is limited to that block or function. The keyword "static" is used to specify static storage class.
1. **Register Storage Class (deprecated)**: The register storage class is used to suggest that a variable be stored in a register instead of memory. The keyword "register" is used to specify register storage class. However, the compiler is free to ignore this suggestion.
1. **Extern Storage Class**: The extern storage class is used to declare a variable that is defined in another translation unit (source file). It is often used to provide a global variable declaration that can be accessed from multiple files. When using extern, the variable is not allocated any storage, as it is assumed to be defined elsewhere. The keyword "extern" is used to specify extern storage class.

Here's an example illustrating the usage of different storage classes:

```cpp
#include <iostream>

int globalVariable; // extern storage class by default

void function() {
    static int staticVariable; // static storage class

    for (auto i = 0; i < 5; ++i) {
        int autoVariable;              // automatic storage class
        register int registerVariable; // register storage class

        std::cout << "Auto: " << autoVariable << ", Static: " << staticVariable << ", Register: " << registerVariable
                  << std::endl;

        ++autoVariable;
        ++staticVariable;
        ++registerVariable;
    }
}

int main() {
    globalVariable = 10;
    function();
    return 0;
}
```

### 3.6.1 static

[C++ 关键词：static](https://zh.cppreference.com/w/cpp/keyword/static)

1. 声明具有静态存储期和内部链接的命名空间成员（全局静态变量/函数，其他编译单元不可见）
    * 表示该编译单元不导出这个函数/变量的符号，因此无法再别的编译单元里使用
1. 定义具有静态存储期且仅初始化一次的块作用域变量（函数的静态变量）
    * 变量的存储方式和全局变量一样，但仍然不导出符号
1. 声明不绑定到特定实例的类成员（类的静态成员）

### 3.6.2 extern

[C++ 关键词：extern](https://zh.cppreference.com/w/cpp/keyword/extern)

* Static storage duration specifier with external linkage
    * This symbol is defined in another compilation unit, which means it needs to be placed in the unresolved symbol table (external linkage)
* Language linkage specification, to avoid name mangling
    * `extern "C" {}`
* Explicit template instantiation declaration
    * For class templates
    * For function templates

#### 3.6.2.1 Shared Global Variable

**每个源文件中都得有该变量的声明，但是只有一个源文件中可以包含该变量的定义，通常可以采用如下做法**

* 定义一个头文件`xxx.h`，声明该变量（需要用extern关键字）
* 所有源文件包含该头文件`xxx.h`
* 在某个源文件中定义该变量

**示例如下：**

```sh
# 创建头文件
cat > extern.h << 'EOF'
#pragma once

extern int extern_value;
EOF

# 创建源文件
cat > extern.cpp << 'EOF'
#include "extern.h"

int extern_value = 5;
EOF

# 创建源文件
cat > main.cpp << 'EOF'
#include <iostream>

#include "extern.h"

int main() {
    std::cout << extern_value << std::endl;
}
EOF

# 编译
gcc -o main main.cpp extern.cpp -lstdc++ -Wall

# 执行
./main
```

### 3.6.3 thread_local

[C++ 关键词：thread_local (C++11 起)](https://zh.cppreference.com/w/cpp/keyword/thread_local)

* 线程局域存储期指定符 

实现原理（猜测）：在每个线程的栈空间起始位置（高位，栈是从上往下分配内存的）存储由`thread_local`修饰的变量。下面由一个程序来验证一下这个猜想：

```cpp
#include <cassert>
#include <iostream>
#include <string>
#include <thread>

thread_local int32_t value;

void print_address(const std::string name, int32_t& value) {
    static std::mutex m;
    std::lock_guard<std::mutex> l(m);
    std::cout << name << ": " << &value << std::endl;
}

int main() {
    uint64_t addr_t1;
    uint64_t addr_t2;

    print_address("main_thread_local", value);
    int i;
    print_address("main_local", i);
    std::thread t1([&addr_t1]() {
        addr_t1 = reinterpret_cast<uint64_t>(&value);
        print_address("t1_thread_local", value);
        int i;
        print_address("t1_local", i);
        assert(&i < &value);
    });
    std::thread t2([&addr_t2]() {
        addr_t2 = reinterpret_cast<uint64_t>(&value);
        print_address("t2_thread_local", value);
        int i;
        print_address("t2_local", i);
        assert(&i < &value);
    });
    t1.join();
    t2.join();

    auto distance = addr_t1 - addr_t2;
    std::cout << "addr distance between t1 and t2 is: " << distance << std::endl;
    return 0;
}
```

在我的环境中，输出如下：

```
main_thread_local: 0x7f190e1a573c
main_local: 0x7fff425e1dd4
t1_thread_local: 0x7f190e1a463c
t1_local: 0x7f190e1a3ddc
t2_thread_local: 0x7f190d9a363c
t2_local: 0x7f190d9a2ddc
addr distance between t1 and t2 is: 8392704
```

可以发现，在不同的线程中，`value`的内存地址是不同的，且处于高位。相邻两个线程，`value`地址的差值差不多就是栈空间的大小（`ulimit -s`）

#### 3.6.3.1 Initialization

```cpp
#include <iostream>
#include <mutex>
#include <thread>

template <typename... Args>
void print(Args&&... args) {
    static std::mutex m;
    std::lock_guard<std::mutex> l(m);
    int _[] = {(std::cout << args, 0)...};
    std::cout << std::endl;
}

class Foo {
public:
    Foo() { print("default ctor"); }
    Foo(const Foo& foo) { print("copy ctor"); }
    Foo(Foo&& foo) { print("move ctor"); }
    ~Foo() { print("dtor"); }

    int value = 0;
};

thread_local Foo foo;

int main() {
    foo.value = 1;
    print("main: foo'address=", &foo, ", value=", foo.value);
    std::thread t([&]() { print("t1: foo'address=", &foo, ", value=", foo.value); });
    t.join();

    return 0;
}
```

输出如下：

* 构造方法调用了2次，因为这两个线程都经过了`foo`这个变量的声明，因此都会分配存储空间并进行初始化

```
default ctor
main: foo'address=0x7f5fd6b0c77c, value=1
default ctor
t1: foo'address=0x7f5fd5a3c6fc, value=0
dtor
dtor
```

修改一下，我们将`thread_local`移动到`main`函数内部

```cpp
#include <iostream>
#include <mutex>
#include <thread>

template <typename... Args>
void print(Args&&... args) {
    static std::mutex m;
    std::lock_guard<std::mutex> l(m);
    int _[] = {(std::cout << args, 0)...};
    std::cout << std::endl;
}

class Foo {
public:
    Foo() { print("default ctor"); }
    Foo(const Foo& foo) { print("copy ctor"); }
    Foo(Foo&& foo) { print("move ctor"); }
    ~Foo() { print("dtor"); }

    int value = 0;
};

int main() {
    thread_local Foo foo;
    foo.value = 1;
    print("main: foo'address=", &foo, ", value=", foo.value);
    std::thread t([&]() { print("t1: foo'address=", &foo, ", value=", foo.value); });
    t.join();

    return 0;
}
```

输出如下：

* 构造方法调用了1次，只有`main`线程经过了`foo`这个变量的声明，因此会分配存储空间并进行初始化。而`t1`线程并未经过`foo`这个变量的声明，因此只分配了存储空间，并未进行初始化

```
default ctor
main: foo'address=0x7f2d690e6778, value=1
t1: foo'address=0x7f2d680166f8, value=0
dtor
```

## 3.7 Inheritance and Polymorphism

### 3.7.1 Inheritance Modes

| Inheritance mode\member permissions | public | protected | private |
|:--|:--|:--|:--|
| **public inherit** | public | protected | invisible |
| **protected inherit** | protected | protected | invisible |
| **private inherit** | private | private | invisible |

Regardless of the inheritance method, you can access the `public` and `protected` members of the parent class, but their access rights will be modified according to the inheritance method, thus affecting the access rights of the derived class.

**Most importantly, only public inheritance can achieve polymorphism**

```cpp
#include <iostream>

class Base {
public:
    void public_op() { std::cout << "public_op" << std::endl; }

protected:
    void protected_op() { std::cout << "protected_op" << std::endl; }

private:
    void private_op() { std::cout << "private_op" << std::endl; }
};

class PublicDerive : public Base {
    void test() {
        public_op();
        protected_op();
        // private_op();
    }
};

class SecondaryPublicDerive : public PublicDerive {
    void test() {
        public_op();
        protected_op();
        // private_op();
    }
};

class ProtectedDerive : protected Base {
    void test() {
        public_op();
        protected_op();
        // private_op();
    }
};

class SecondaryProtectedDerive : public ProtectedDerive {
    void test() {
        public_op();
        protected_op();
        // private_op();
    }
};

class PrivateDerive : private Base {
    void test() {
        public_op();
        protected_op();
        // private_op();
    }
};

class SecondaryPrivateDerive : public PrivateDerive {
    void test() {
        // public_op();
        // protected_op();
        // private_op();
    }
};

int main() {
    SecondaryPublicDerive obj_public;
    obj_public.public_op();

    SecondaryProtectedDerive obj_protected;
    // obj_protected.public_op();
}
```

### 3.7.2 virtual

`virtual`关键词修饰的就是虚函数，虚函数的分派发生在运行时

1. 有虚函数的每个类，维护一个虚函数表
1. 有虚函数的类的对象，会包含一个指向该类的虚函数表的指针

![virtual-method-table](/images/Cpp-Language/virtual-method-table.jpeg)

* 图片出处：[c++虚指针和虚函数表](https://zhuanlan.zhihu.com/p/110144589)

#### 3.7.2.1 virtual destructor

通常，我们需要将有虚函数的类的析构函数定义为`virtual`，否则很容易造成内存泄露，如下：

```cpp
#include <iostream>

class Base {
public:
    virtual void func() = 0;
    ~Base() { std::cout << "~Base" << std::endl; }
};

class Derive : public Base {
public:
    ~Derive() { std::cout << "~Derive" << std::endl; }
    virtual void func() override { std::cout << "Derive::func" << std::endl; }
};

int main() {
    Base* ptr = new Derive();
    delete ptr;
    return 0;
}
```

### 3.7.3 final

`final`可以修饰类或者虚函数

* `final`修饰的类不能有子类，该类的所有虚函数不能被覆盖
* `final`修饰的虚函数，不能被覆盖
    * 只能在虚函数的声明处进行修饰

当用具体类型的指针或者引用调用`final`修饰的虚函数时，虚函数的调用可以被编译器直接优化掉

### 3.7.4 override

`override`可以修饰虚函数，表示对虚函数进行覆盖

* 只能在虚函数的声明处进行修饰
* 加不加`override`其实没有影响

## 3.8 constexpr

### 3.8.1 if constexpr

编译期分支判断，一般用于泛型。如果在分支中使用的是不同类型的不同特性，那么普通的`if`是没法通过编译的，如下：

```cpp
#include <iostream>
#include <type_traits>

template <typename T>
struct Condition1 {
    static T append(T left, T right) {
        if (std::is_integral<T>::value) {
            return left + right;
        } else if (std::is_pointer<T>::value) {
            return (*left) + (*right);
        }
        return T();
    }
};

template <typename T>
struct Condition2 {
    static T append(T left, T right) {
        if constexpr (std::is_integral<T>::value) {
            return left + right;
        } else if constexpr (std::is_pointer<T>::value) {
            return (*left) + (*right);
        }
        return T();
    }
};
int main() {
    // Condition1<int32_t>::append(1, 2);
    Condition2<int32_t>::append(1, 2);
}
```

## 3.9 static_assert

编译期断言

```cpp
int main() {
    static_assert(sizeof(int) == 4, "test1");
    static_assert(sizeof(long) > 8, "test2");
    return 0;
}
```

## 3.10 noexcept

用于声明函数不会抛异常，声明和实现都必须同时包含

```cpp
class A {
public:
    void func() noexcept;
};

void A::func() noexcept {}
```

## 3.11 throw and error

`throw`关键字可以抛出任何对象，例如可以抛出一个整数

```c++
    try {
        throw 1;
    } catch (int &i) {
        std::cout << i << std::endl;
    }

    try {
        // 保护代码
    } catch (...) {
        // 能处理任何异常的代码
    }
```

## 3.12 placement new

`placement new`的功能就是在一个已经分配好的空间上，调用构造函数，创建一个对象

```c++
void *buf = // 在这里为buf分配内存
Class *pc = new (buf) Class();  
```

# 4 Syntax

## 4.1 List-initialization

Initializes an object from braced-init-list.

* [List-initialization (since C++11)](https://en.cppreference.com/w/cpp/language/list_initialization)
* [Why is a braced-init-list not an expression？](https://stackoverflow.com/questions/18009628/why-is-a-braced-init-list-not-an-expression)

**Direct-list-initialization:**

```cpp
T object { arg1, arg2, ... };
T object { .des1 = arg1, .des2 { arg2 } ... }; (since C++20)

T { arg1, arg2, ... }
T { .des1 = arg1, .des2 { arg2 } ... } (since C++20)

new T { arg1, arg2, ... }
new T { .des1 = arg1, .des2 { arg2 } ... } (since C++20)

Class { T member { arg1, arg2, ... }; };
Class { T member { .des1 = arg1, .des2 { arg2 } ... }; }; (since C++20)

Class::Class() : member { arg1, arg2, ... } {...
Class::Class() : member { .des1 = arg1, .des2 { arg2 } ... } {... (since C++20)
```

**Copy-list-initialization:**

```cpp
T object = { arg1, arg2, ... };
T object = { .des1 = arg1, .des2 { arg2 } ... }; (since C++20)

function ({ arg1, arg2, ... })
function ({ .des1 = arg1, .des2 { arg2 } ... }) (since C++20)

return { arg1, arg2, ... };
return { .des1 = arg1, .des2 { arg2 } ... }; (since C++20)

object [{ arg1, arg2, ... }]
object [{ .des1 = arg1, .des2 { arg2 } ... }] (since C++20)

object = { arg1, arg2, ... }
object = { .des1 = arg1, .des2 { arg2 } ... } (since C++20)

U ({ arg1, arg2, ... })
U ({ .des1 = arg1, .des2 { arg2 } ... }) (since C++20)

Class { T member = { arg1, arg2, ... }; };
Class { T member = { .des1 = arg1, .des2 { arg2 } ... }; }; (since C++20)
```

### 4.1.1 Aggregate initialization

[Aggregate initialization](https://en.cppreference.com/w/cpp/language/aggregate_initialization)

Initializes an aggregate from an initializer list. It is a form of list-initialization

An aggregate is one of the following types:

1. array types
1. class types that has
    * no user-declared constructors
    * no private or protected direct non-static data members
    * no base classes
    * ...

Each member can choose to use copy constructor or move constructor independently:

```cpp
#include <iostream>

class Foo {
public:
    Foo() = default;
    Foo(const Foo& foo) { std::cout << "Foo::Foo(const Foo&)" << std::endl; }
    Foo(Foo&& foo) { std::cout << "Foo::Foo(Foo&&)" << std::endl; }
};

class Bar {
public:
    Bar() = default;
    Bar(const Bar&) { std::cout << "Bar::Bar(const Bar&)" << std::endl; }
    Bar(Bar&&) { std::cout << "Bar::Bar(Bar&&)" << std::endl; }
};

struct Container {
    Foo foo;
    Bar bar;
    int num;
};

int main() {
    Foo foo;
    Bar bar;
    Container c{.foo = foo, .bar = std::move(bar)};
    return 0;
}
```

## 4.2 operator overloading

* [operator overloading](https://en.cppreference.com/w/cpp/language/operators)

Overloaded operators are functions with special function names:

* `operator op`
* `operator type`
    ```cpp
    struct Foo {
        int val;
        operator bool() const { return val == 0; }
    };

    Foo getFoo() {
        return Foo();
    }
    int main() {
        if (getFoo()) {
        }
        return 0;
    }
    ```

* `operator new`
* `operator new []`
* `operator delete`
* `operator delete []`
* `operator "" suffix-identifier`
* `operator co_await`

### 4.2.1 std::forward cannot convert brace-enclosed initializer list

```cpp
#include <memory>
#include <vector>

struct Foo {
    Foo(std::vector<int> data_) : data(data_) {}
    std::vector<int> data;
};

Foo create() {
    return {{}};
}

std::shared_ptr<Foo> create_ptr_1() {
    return std::shared_ptr<Foo>({});
}
std::shared_ptr<Foo> create_ptr_2() {
    // Compile error
    return std::make_shared<Foo>({});
}

int main() {
    create();
    create_ptr_1();
    create_ptr_2();
    return 0;
}
```

## 4.3 Variadic Arguments

[Variadic arguments](https://en.cppreference.com/w/cpp/language/variadic_arguments)

Allows a function to accept any number of extra arguments. 

Within the body of a function that uses variadic arguments, the values of these arguments may be accessed using the `<cstdarg>` library facilities:

* `va_start`: enables access to variadic function arguments
* `va_arg`: accesses the next variadic function argument
* `va_copy`: makes a copy of the variadic function arguments
* `va_end`: ends traversal of the variadic function arguments
* `va_list`: holds the information needed by va_start, va_arg, va_end, and va_copy

**Example:**

```cpp
#include <cstdarg>
#include <iostream>

int sum(int count, ...) {
    int result = 0;
    va_list args;
    va_start(args, count);
    for (int i = 0; i < count; i++) {
        result += va_arg(args, int);
    }
    va_end(args);
    return result;
}

int main() {
    std::cout << sum(3, 1, 2, 3) << std::endl;            // Output: 6
    std::cout << sum(5, 10, 20, 30, 40, 50) << std::endl; // Output: 150
    return 0;
}
```

**How it works?**

* [How are variable arguments implemented in gcc?](https://stackoverflow.com/questions/12371450/how-are-variable-arguments-implemented-in-gcc)

If you look at the way the C language stores the parameters on the stack, the way the macros work should become clear:

```
Higher memory address    Last parameter
                         Penultimate parameter
                         ....
                         Second parameter
Lower memory address     First parameter
       StackPointer  ->  Return address
```

The arguments are always stored like this, even without the `...` parameter type.

The `va_start` macro just sets up a pointer to the last named parameter:

```cpp
void func(int a, ...) {
    // va_start
    char* p = (char*)&a + sizeof a;
}
```

which makes `p` point to the second parameter. The `va_arg` macro does this:

```cpp
void func(int a, ...) {
    // va_start
    char* p = (char*)&a + sizeof a;

    // va_arg
    int i1 = *((int*)p);
    p += sizeof(int);

    // va_arg
    int i2 = *((int*)p);
    p += sizeof(int);

    // va_arg
    long i2 = *((long*)p);
    p += sizeof(long);
}
```

The `va_end` macro just sets the `p` value to `NULL`

### 4.3.1 How to forward variadic arguments

**Conclusion: Variadic arguments cannot be directly forwarded via function call.**

```cpp
#include <cstdarg>
#include <cstdio>

void forward_printf(const char* __restrict __format, ...) {
    va_list args;
    va_start(args, __format);
    std::printf(__format, args);
    va_end(args);
}

void forward_vprintf(const char* __restrict __format, ...) {
    va_list args;
    va_start(args, __format);
    std::vprintf(__format, args);
    va_end(args);
}

#define FORWARD_PRINTF(format, ...) std::printf(format, __VA_ARGS__)

int main() {
    std::printf("std::printf: %d + %d = %d\n", 1, 2, 1 + 2);
    forward_printf("forward_printf: %d + %d = %d\n", 1, 2, 1 + 2);
    forward_vprintf("forward_vprintf: %d + %d = %d\n", 1, 2, 1 + 2);
    FORWARD_PRINTF("FORWARD_PRINTF: %d + %d = %d\n", 1, 2, 1 + 2);
    return 0;
}
```

### 4.3.2 Implicit Type Conversion

**Conclusion: Variadic arguments do not support implicit type conversion**

```cpp
#include <cstdarg>
#include <iostream>

struct IntWrap {
    operator int() { return *val; }
    int* val;
};

int sum(int count, ...) {
    int result = 0;
    va_list args;
    va_start(args, count);
    for (int i = 0; i < count; i++) {
        result += va_arg(args, int);
    }
    va_end(args);
    return result;
}

template <typename... Args>
int sum_template(Args... args) {
    return (args + ...);
}

int main() {
    int val1 = 1, val2 = 2, val3 = 3;
    IntWrap wrap1{&val1}, wrap2{&val2}, wrap3{&val3};
    {
        // Implicit type conversion not happen
        int res = sum(3, wrap1, wrap2, wrap3);
        std::cout << res << std::endl;
    }
    {
        // Explicit type conversion works
        int res = sum(3, static_cast<int>(wrap1), static_cast<int>(wrap2), static_cast<int>(wrap3));
        std::cout << res << std::endl;
    }
    {
        // Implicit type conversion works
        int res = sum_template(wrap1, wrap2, wrap3);
        std::cout << res << std::endl;
    }
    return 0;
}
```

## 4.4 Attributes

`__attribute__`是一个`GCC`编译器特有的特性，它允许程序员向编译器提供一些指示信息，以便在编译期间进行优化或者在运行期间提供一些额外的约束条件。这些指示信息被称为属性（`attributes`），可以应用于函数、变量、类型等各种程序元素

`C++11`引入了一种新的语言特性，称为属性（`attributes`），它们与`__attribute__`类似，但是是标准`C++`的一部分，因此在编译器支持`C++11`之后，可以在`C++`代码中使用它们。与`__attribute__`不同，`C++11`的`attributes`支持在类和命名空间级别使用，而不仅仅是在函数和变量级别

`C++11`的`attributes`也提供了更多的灵活性和可读性。它们可以用更自然的方式嵌入到代码中，而不像`__attribute__`那样需要使用一些冗长的语法。此外，`C++11`的`attributes`还提供了一些有用的新特性，例如`[[noreturn]]`、`[[carries_dependency]]`、`[[deprecated]]`、`[[fallthrough]]`

常用`__attribute__`清单：

* `__attribute__((packed))`：指示编译器在分配结构体内存时尽量紧凑地排列各个字段，以减小结构体的内存占用
* `__attribute__((aligned(n)))`: 指示编译器将变量对齐到`n`字节边界
* `__attribute__((noreturn))`：指示函数不会返回，用于告诉编译器在函数调用之后不需要进行任何清理操作
* `__attribute__((unused))`：指示编译器不应发出未使用变量的警告。
* `__attribute__((deprecated))`：指示函数或变量已经过时，编译器会在使用它们时发出警告
* `__attribute__((visibility("hidden")))`：指示编译器隐藏该符号，即不会出现在当前编译单元的导出的符号表中
* `__attribute__(alias)`：它允许你将一个函数或变量的名称指定为另一个已存在的函数或变量的别名。可以起到与链接器参数`--wrap=<symbol>`类似的作用
    ```cpp
    #include <stdio.h>

    FILE* my_fopen(const char* path, const char* mode) {
        printf("This is my fopen!\n");
        return NULL;
    }

    FILE* fopen(const char* path, const char* mode) __attribute__((alias("my_fopen")));

    int main() {
        printf("Calling the fopen() function...\n");
        FILE* fd = fopen("test.txt", "r");
        if (!fd) {
            printf("fopen() returned NULL\n");
            return 1;
        }
        printf("fopen() succeeded\n");
        return 0;
    }
    ```

常用`attributes`清单：

* `[[noreturn]]`（C++11）：用于标识函数不会返回。如果一个函数被标记为`[[noreturn]]`，那么编译器会警告或者错误地处理一个函数的任何尝试返回值
* `[[deprecated]]`（C++14）：用于标识函数或变量已被弃用。编译器会在调用或使用被标记为`[[deprecated]]`的函数或变量时给出警告
* `[[fallthrough]]`（C++17）：用于标识`switch`语句中的`case`标签，以指示代码故意继续执行下一个`case`标签
* `[[nodiscard]]`（C++17）：用于标识函数的返回值需要被检查。当一个函数被标记为`[[nodiscard]]`时，如果函数返回值没有被检查，编译器会给出警告
* `[[maybe_unused]]`（C++17）：用于标识变量或函数可能未被使用。编译器不会给出未使用的变量或函数的警告
* `[[likely]]`（C++20）：提示编译器该分支大概率为`true`
* `[[unlikely]]`（C++20）：提示编译器该分支大概率为`false`

### 4.4.1 aligned

```cpp
#include <iostream>

#define FOO_WITH_ALIGN(SIZE) \
    struct Foo_##SIZE {      \
        int v;               \
    } __attribute__((aligned(SIZE)))

#define PRINT_SIZEOF_FOO(SIZE) std::cout << "Foo_##SIZE's size=" << sizeof(Foo_##SIZE) << std::endl;

FOO_WITH_ALIGN(1);
FOO_WITH_ALIGN(2);
FOO_WITH_ALIGN(4);
FOO_WITH_ALIGN(8);
FOO_WITH_ALIGN(16);
FOO_WITH_ALIGN(32);
FOO_WITH_ALIGN(64);
FOO_WITH_ALIGN(128);
FOO_WITH_ALIGN(256);

int main() {
    PRINT_SIZEOF_FOO(1);
    PRINT_SIZEOF_FOO(2);
    PRINT_SIZEOF_FOO(4);
    PRINT_SIZEOF_FOO(8);
    PRINT_SIZEOF_FOO(16);
    PRINT_SIZEOF_FOO(32);
    PRINT_SIZEOF_FOO(64);
    PRINT_SIZEOF_FOO(128);
    PRINT_SIZEOF_FOO(256);
    return 1;
}
```

### 4.4.2 Reference

* [Compiler-specific Features](https://www.keil.com/support/man/docs/armcc/armcc_chr1359124965789.htm)

## 4.5 ASM

[gcc-online-docs](https://gcc.gnu.org/onlinedocs/gcc/)

### 4.5.1 Basic Asm

### 4.5.2 Extended Asm

[Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html): GCC设计了一种特有的嵌入方式，它规定了汇编代码嵌入的形式和嵌入汇编代码需要由哪几个部分组成，格式如下：

* 汇编语句模板是必须的，其余三部分是可选的

```cpp
asm asm-qualifiers ( AssemblerTemplate 
                 : OutputOperands 
                 [ : InputOperands
                 [ : Clobbers ] ])

asm asm-qualifiers ( AssemblerTemplate 
                      : OutputOperands
                      : InputOperands
                      : Clobbers
                      : GotoLabels)
```

**`Qualifiers`，修饰符：**

* `volatile`：禁止编译器优化
* `inline`
* `goto`

**`AssemblerTemplate`，汇编语句模板：**

* 汇编语句模板由汇编语句序列组成，语句之间使用`;`、`\n`、`\n\t`分开
* 指令中的操作数可以使用占位符，占位符可以指向`OutputOperands`、`InputOperands`、`GotoLabels`
* 指令中使用占位符表示的操作数，总被视为`long`型（4个字节），但对其施加的操作根据指令可以是字或者字节，当把操作数当作字或者字节使用时，默认为低字或者低字节
* 对字节操作可以显式的指明是低字节还是次字节。方法是在`%`和序号之间插入一个字母
    * `b`代表低字节
    * `h`代表高字节
    * 例如：`%h1`

**`OutputOperands`，输出操作数：**

* 操作数之间用逗号分隔
* 每个操作数描述符由限定字符串（`Constraints`）和C语言变量或表达式组成

**`InputOperands`，输入操作数：**

* 操作数之间用逗号分隔
* 每个操作数描述符由限定字符串（`Constraints`）和C语言变量或表达式组成

**`Clobbers`，描述部分：**

* 用于通知编译器我们使用了哪些寄存器或内存，由逗号格开的字符串组成
* 每个字符串描述一种情况，一般是寄存器名；除寄存器外还有`memory`。例如：`%eax`，`%ebx`，`memory`等

**`Constraints`，限定字符串（下面仅列出常用的）：**

* `m`：内存
* `o`：内存，但是其寻址方式是偏移量类型
* `v`：内存，但寻址方式不是偏移量类型
* `r`：通用寄存器
* `i`：整型立即数
* `g`：任意通用寄存器、内存、立即数
* `p`：合法指针
* `=`：write-only
* `+`：read-write
* `&`：该输出操作数不能使用过和输入操作数相同的寄存器

**示例1：**

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>

struct atomic_t {
    volatile int32_t a_count;
};

static inline int32_t atomic_read(const atomic_t* v) {
    return (*(volatile int32_t*)&(v)->a_count);
}

static inline void atomic_write(atomic_t* v, int32_t i) {
    v->a_count = i;
}

static inline void atomic_add(atomic_t* v, int32_t i) {
    __asm__ __volatile__(
            "lock;"
            "addl %1,%0"
            : "+m"(v->a_count)
            : "ir"(i));
}

static inline void atomic_sub(atomic_t* v, int32_t i) {
    __asm__ __volatile__(
            "lock;"
            "subl %1,%0"
            : "+m"(v->a_count)
            : "ir"(i));
}

static inline void atomic_inc(atomic_t* v) {
    __asm__ __volatile__(
            "lock;"
            "incl %0"
            : "+m"(v->a_count));
}

static inline void atomic_dec(atomic_t* v) {
    __asm__ __volatile__(
            "lock;"
            "decl %0"
            : "+m"(v->a_count));
}

int main() {
    atomic_t v;
    atomic_write(&v, 0);
    atomic_add(&v, 10);
    atomic_sub(&v, 5);
    atomic_inc(&v);
    atomic_dec(&v);
    std::cout << atomic_read(&v) << std::endl;
    return 0;
}
```

**示例2：**

* 这个程序是没法跑的，因为`cli`指令必须在内核态执行
* `hal_save_flags_cli`：将`eflags`寄存器的值保存到内存中，然后关闭中断
* `hal_restore_flags_sti`：将`hal_save_flags_cli`保存在内存中的值恢复到`eflags`寄存器中

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>

typedef uint32_t cpuflg_t;

static inline void hal_save_flags_cli(cpuflg_t* flags) {
    __asm__ __volatile__(
            "pushf;" // 把eflags寄存器的值压入当前栈顶
            "cli;"   // 关闭中断，会改变eflags寄存器的值
            "pop %0" // 把当前栈顶弹出到eflags为地址的内存中
            : "=m"(*flags)
            :
            : "memory");
}

static inline void hal_restore_flags_sti(cpuflg_t* flags) {
    __asm__ __volatile__(
            "push %0;" // 把flags为地址处的值寄存器压入当前栈顶
            "popf"     // 把当前栈顶弹出到eflags寄存器中
            :
            : "m"(*flags)
            : "memory");
}

void foo(cpuflg_t* flags) {
    hal_save_flags_cli(flags);
    std::cout << "step1: foo()" << std::endl;
    hal_restore_flags_sti(flags);
}

void bar() {
    cpuflg_t flags;
    hal_save_flags_cli(&flags);
    foo(&flags);
    std::cout << "step2: bar()" << std::endl;
    hal_restore_flags_sti(&flags);
}

int main() {
    bar();
    return 0;
}
```

**示例3：linux内核大量用到了`asm`，具体可以参考[linux-asm](https://github.com/torvalds/linux/blob/master/arch/x86/include/asm)**

## 4.6 Lambda

[Lambda expressions (since C++11)](https://en.cppreference.com/w/cpp/language/lambda)

> The lambda expression is a prvalue expression of unique unnamed non-union non-aggregate class type, known as closure type, which is declared (for the purposes of ADL) in the smallest block scope, class scope, or namespace scope that contains the lambda expression. The closure type has the following members, they cannot be explicitly instantiated, explicitly specialized, or (since C++14) named in a friend declaration

* 每个`Lambda`表达式都是独一无二的类型，且无法显式声明

### 4.6.1 `std::function` and Lambda

在大多数场景下，`Lambda`和`std::function`可以相互替换使用，但它们之间存在一些差异（[What's the difference between a lambda expression and a function pointer (callback) in C++?](https://www.quora.com/Whats-the-difference-between-a-lambda-expression-and-a-function-pointer-callback-in-C++)）：

* `Lambda`无法显式声明类型，而`std::function`可以
* `Lambda`效率更高，参考{% post_link Cpp-Performance-Optimization %}
    * `std::function`本质上是个函数指针的封装，当传递它时，编译器很难进行内联优化
    * `Lambda`本质上是传递某个匿名类的实例，有确定的类型信息，编译器可以很容易地进行内联优化

### 4.6.2 How lambda capture itself

```cpp
#include <functional>
#include <iostream>

int main() {
    std::function<void(int)> recursiveLambda;

    // Must use reference to capture itself
    recursiveLambda = [&recursiveLambda](int x) {
        std::cout << x << std::endl;
        if (x > 0) recursiveLambda(x - 1);
    };

    recursiveLambda(5);
    return 0;
}
```

### 4.6.3 C-Stype function pointer

According to [expr.unary.op](https://eel.is/c++draft/expr.unary.op)/7

> The operand of the unary + operator shall be a prvalue of arithmetic, unscoped enumeration, or pointer type and the result is the value of the argument. Integral promotion is performed on integral or enumeration operands. The type of the result is the type of the promoted operand.

According to [expr.prim.lambda.closure](https://eel.is/c++draft/expr.prim.lambda.closure)/1

> The type of a lambda-expression (which is also the type of the closure object) is a unique, unnamed non-union class type, called the closure type, whose properties are described below.

According to [expr.prim.lambda](https://timsong-cpp.github.io/cppwp/n3337/expr.prim.lambda)/6

> The closure type for a lambda-expression with no lambda-capture has a public non-virtual non-explicit const conversion function to pointer to function having the same parameter and return types as the closure type's function call operator. The value returned by this conversion function shall be the address of a function that, when invoked, has the same effect as invoking the closure type's function call operator.

**Explicit cast to C-style function pointer by using unary operator `+`:**

* This is necessary in some cases like `libcurl` when you setting up the callback.
* And in most cases, the labmda will automatically cast to C-style function pointer where there needs a C-style function pointer.

```cpp
#include <cstdarg>
#include <iostream>

using AddFunType = int (*)(int, int);
using NegativeFunType = int (*)(int);

enum OperatorType {
    ADD = 0,
    NEGATIVE = 1,
};

int invoke_operator(OperatorType op, ...) {
    va_list args;
    va_start(args, op);
    switch (op) {
    case ADD: {
        AddFunType add_func = va_arg(args, AddFunType);
        int num1 = va_arg(args, int);
        int num2 = va_arg(args, int);
        va_end(args);
        return add_func(num1, num2);
    }
    case NEGATIVE: {
        NegativeFunType negative_func = va_arg(args, NegativeFunType);
        int num = va_arg(args, int);
        va_end(args);
        return negative_func(num);
    }
    default:
        throw std::logic_error("Invalid operator type");
    }
}

int main() {
    {
        // Must use + to explicitly convert lambda to function pointer, otherwise it may crash
        auto lambda_add = +[](int num1, int num2) { return num1 + num2; };
        int num1 = 1;
        int num2 = 2;
        auto ret = invoke_operator(OperatorType::ADD, lambda_add, num1, num2);
        std::cout << num1 << " + " << num2 << " = " << ret << std::endl;
    }
    {
        // Must use + to explicitly convert lambda to function pointer, otherwise it may crash
        auto lambda_negative = +[](int num) { return -num; };
        int num = 1;
        auto ret = invoke_operator(OperatorType::NEGATIVE, lambda_negative, num);
        std::cout << "-(" << num << ") = " << ret << std::endl;
    }
    return 0;
}
```

**References:**

* [Resolving ambiguous overload on function pointer and std::function for a lambda using + (unary plus)](https://stackoverflow.com/questions/17822131/resolving-ambiguous-overload-on-function-pointer-and-stdfunction-for-a-lambda)
* [A positive lambda: '+[]{}' - What sorcery is this? [duplicate]](https://stackoverflow.com/questions/18889028/a-positive-lambda-what-sorcery-is-this)

## 4.7 Coroutine

[C++20’s Coroutines for Beginners - Andreas Fertig - CppCon 2022](https://www.youtube.com/watch?v=8sEe-4tig_A)

A coroutine is a generalization of a function that can be exited and later resumed at specific points. The key difference from functions is that coroutines can maintain state between suspensions.

* `co_yield`: Produces a value and suspends the coroutine. The coroutine can be later resumed from this point.
* `co_return`: Ends the coroutine, potentially returning a final value.
* `co_await`: Suspends the coroutine until the awaited expression is ready, at which point the coroutine is resumed.

**A coroutine consists of:**

* A wrapper type
* A type with the exact name `promise_type` inside the return type of coroutine(the wrapper type), this type can be:
    * Type alias
    * A `typedef`
    * Directly declare an inner class
* An awaitable type that comes into play once we use `co_await`
* An interator

**Key Observation: A coroutine in C++ is an finite state machine(FSM) that can be controlled and customized by the promise_type**

**Coroutine Classifications:**

* `Task`: A coroutine that does a job without returning a value.
* `Generator`: A coroutine that does a job and returns a value(either by `co_return` or `co_yield`)

### 4.7.1 Overview of `promise_type`

The `promise_type` for coroutines in C++20 can have several member functions which the coroutine machinery recognizes and calls at specific times or events. Here's a general overview of the structure and potential member functions:

* **Stored Values or State:** These are member variables to hold state, intermediate results, or final values. The nature of these depends on the intended use of your coroutine.
* **Coroutine Creation:** 
    * `auto get_return_object() -> CoroutineReturnObject`: Defines how to obtain the return object of the coroutine (what the caller of the coroutine gets when invoking the coroutine).
* **Coroutine Lifecycle:**
    * `std::suspend_always/std::suspend_never initial_suspend() noexcept`: Dictates if the coroutine should start executing immediately or be suspended right after its creation.
    * `std::suspend_always/std::suspend_never final_suspend() noexcept`: Dictates if the coroutine should be suspended after running to completion. If `std::suspend_never` is used, the coroutine ends immediately after execution.
    * `void return_void()` noexcept: Used for coroutines with a `void` return type. Indicates the end of the coroutine.
    * `void return_value(ReturnType value)`: For coroutines that produce a result, this function specifies how to handle the value provided with `co_return`.
    * `void unhandled_exception()`: Invoked if there's an unhandled exception inside the coroutine. Typically, you'd capture or rethrow the exception here.
* **Yielding Values:**
    * `std::suspend_always/std::suspend_never yield_value(YieldType value)`: Specifies what to do when the coroutine uses `co_yield`. You dictate here how the value should be handled or stored.
* **Awaiting Values:**
    * `auto await_transform(AwaitableType value) -> Awaiter`: Transforms the expression after co_await. This is useful for custom awaitable types. For instance, it's used to make this a valid awaitable in member functions.

#### 4.7.1.1 Awaiter

The awaiter in the C++ coroutine framework is a mechanism that allows fine-tuned control over how asynchronous operations are managed and how results are produced once those operations are complete.

Here's an overview of the awaiter:

**Role of the Awaiter:**

* The awaiter is responsible for defining the behavior of a `co_await` expression. It determines if the coroutine should suspend, what should be done upon suspension, and what value (if any) should be produced when the coroutine resumes.

**Required Methods:** The awaiter must provide the following three methods:

* `await_ready`
    * Purpose: Determines if the coroutine needs to suspend at all.
    * Signature: `bool await_ready() const noexcept`
    * Return:
        * `true`: The awaited operation is already complete, and the coroutine shouldn't suspend.
        * `false`: The coroutine should suspend.
* `await_suspend`
    * Purpose: Dictates the actions that should be taken when the coroutine suspends.
    * Signature: `void await_suspend(std::coroutine_handle<> handle) noexcept`
    * Parameters:
        * `handle`: A handle to the currently executing coroutine. It can be used to later resume the coroutine.
* `await_resume`
    * Purpose: Produces a value once the awaited operation completes and the coroutine resumes.
    * Signature: `ReturnType await_resume() noexcept`
    * Return: The result of the `co_await` expression. The type can be `void` if no value needs to be produced.

**Workflow of the Awaiter:**

1. **Obtain the Awaiter**: When a coroutine encounters `co_await someExpression`, it first needs to get an awaiter. The awaiter can be:
    * Directly from `someExpression` if it has an `operator co_await`.
    * Through an ADL (Argument Dependent Lookup) free function named `operator co_await` that takes `someExpression` as a parameter.
    * From the coroutine's `promise_type` via `await_transform` if neither of the above methods produce an awaiter.
1. **Call `await_ready`**: The coroutine calls the awaiter's `await_ready()` method.
    * If it returns `true`, the coroutine continues without suspending.
    * If it returns `false`, the coroutine prepares to suspend.
1. **Call `await_suspend (if needed)`**: If `await_ready` indicated the coroutine should suspend (by returning `false`), the `await_suspend` method is called with a handle to the current coroutine. This method typically arranges for the coroutine to be resumed later, often by setting up callbacks or handlers associated with the asynchronous operation.
1. **Operation Completion and Coroutine Resumption**: Once the awaited operation is complete and the coroutine is resumed, the awaiter's await_resume method is called. The value it produces becomes the result of the co_await expression.

**Built-in Awaiters:**

* `std::suspend_always`: The method `await_ready` always returns `false`, indicating that an await expression always suspends as it waits for its value
* `std::suspend_never`: The method `await_ready` always returns `true`, indicating that an await expression never suspends

### 4.7.2 Example

The `Chat` struct acts as a wrapper around the coroutine handle. It allows the main code to interact with the coroutine - by resuming it, or by sending/receiving data to/from it.

The `promise_type` nested within `Chat` is what gives behavior to our coroutine. It defines:

* What happens when you start the coroutine (`initial_suspend`).
* What happens when you `co_yield` a value (`yield_value`).
* What happens when you `co_await` a value (`await_transform`).
* What happens when you `co_return` a value (`return_value`).
* What happens at the end of the coroutine (`final_suspend`).

Functionality:

1. **Creating the Coroutine:**
    * When `Fun()` is called, a new coroutine is started. Due to `initial_suspend`, it is suspended immediately before executing any code.
    * The coroutine handle (with the promise) is wrapped inside the Chat object, which is then returned to the caller (main function in this case).
1. **Interacting with the Coroutine:**
    * `chat.listen()`: Resumes the coroutine until the next suspension point. If `co_yield` is used inside the coroutine, the yielded value will be returned.
    * `chat.answer(msg)`: Sends a message to the coroutine. If the coroutine is waiting for input using `co_await`, this will provide the awaited value and resume the coroutine.
1. **Coroutine Flow:**
    * The coroutine starts and immediately hits `co_yield "Hello!\n";`. This suspends the coroutine and the string `"Hello!\n"` is made available to the caller.
    * In `main`, after `chat.listen()`, it prints this message.
    * Then, `chat.answer("Where are you?\n");` is called. Inside the coroutine, the message `"Where are you?\n"` is captured and printed because of the line `std::cout << co_await std::string{};`.
    * Finally, `co_return "Here!\n";` ends the coroutine, and the string `"Here!\n"` is made available to the caller. This message is printed after the second chat.`listen()` in `main`.

```cpp
#include <coroutine>
#include <iostream>
#include <utility>
#include <vector>

struct Chat {
    struct promise_type {
        // A: Storing a value from or for the coroutine
        std::string _msg_out{};
        std::string _msg_in{};

        // B: What to do in case of an exception
        void unhandled_exception() noexcept { std::cout << "Chat::unhandled_exception" << std::endl; }

        // C: Coroutine creation
        Chat get_return_object() {
            std::cout << " -- Chat::promise_type::get_return_object" << std::endl;
            return Chat(this);
        };

        // D: Startup
        std::suspend_always initial_suspend() noexcept {
            std::cout << " -- Chat::promise_type::initial_suspend" << std::endl;
            return {};
        }

        // F: Value from co_yield
        std::suspend_always yield_value(std::string msg) noexcept {
            std::cout << " -- Chat::promise_type::yield_value" << std::endl;
            _msg_out = std::move(msg);
            return {};
        }

        // G: Value from co_await
        auto await_transform(std::string) noexcept {
            std::cout << " -- Chat::promise_type::await_transform" << std::endl;
            // H: Customized version instead of using suspend_always or suspend_never
            struct awaiter {
                promise_type& pt;
                bool await_ready() const noexcept {
                    std::cout << " -- Chat::promise_type::await_transform::await_ready" << std::endl;
                    return true;
                }
                std::string await_resume() const noexcept {
                    std::cout << " -- Chat::promise_type::await_transform::await_resume" << std::endl;
                    return std::move(pt._msg_in);
                }
                void await_suspend(std::coroutine_handle<>) const noexcept {
                    std::cout << " -- Chat::promise_type::await_transform::await_suspend" << std::endl;
                }
            };
            return awaiter{*this};
        }

        // I: Value from co_return
        void return_value(std::string msg) noexcept {
            std::cout << " -- Chat::promise_type::return_value" << std::endl;
            _msg_out = std::move(msg);
        }

        // E: Ending
        std::suspend_always final_suspend() noexcept {
            std::cout << " -- Chat::promise_type::final_suspend" << std::endl;
            return {};
        }
    };

    // A: Shortcut for the handle type
    using Handle = std::coroutine_handle<promise_type>;
    // B
    Handle _handle;

    // C: Get the handle from promise
    explicit Chat(promise_type* p) : _handle(Handle::from_promise(*p)) {}

    // D: Move only
    Chat(Chat&& rhs) : _handle(std::exchange(rhs._handle, nullptr)) {}

    // E: Care taking, destroying the handle if needed
    ~Chat() {
        if (_handle) {
            _handle.destroy();
        }
    }

    // F: Active the coroutine and wait for data
    std::string listen() {
        std::cout << " -- Chat::listen" << std::endl;
        if (!_handle.done()) {
            _handle.resume();
        }
        return std::move(_handle.promise()._msg_out);
    }

    // G Send data to the coroutine and activate it
    void answer(std::string msg) {
        std::cout << " -- Chat::answer" << std::endl;
        _handle.promise()._msg_in = msg;
        if (!_handle.done()) {
            _handle.resume();
        }
    }
};

Chat Fun() {
    co_yield "Hello!\n";
    std::cout << co_await std::string{};
    co_return "Here!\n";
}

int main() {
    Chat chat = Fun();
    std::cout << chat.listen();
    chat.answer("Where are you?\n");
    std::cout << chat.listen();
}
```

**Output:**

```
 -- Chat::promise_type::get_return_object
 -- Chat::promise_type::initial_suspend
 -- Chat::listen
 -- Chat::promise_type::yield_value
Hello!
 -- Chat::answer
 -- Chat::promise_type::await_transform
 -- Chat::promise_type::await_transform::await_ready
 -- Chat::promise_type::await_transform::await_resume
Where are you?
 -- Chat::promise_type::return_value
 -- Chat::promise_type::final_suspend
 -- Chat::listen
Here!
```

# 5 template

## 5.1 template Type

1. `Function Templates`: These are templates that produce templated functions that can operate on a variety of data types.
    ```cpp
    template<typename T>
    T max(T a, T b) {
        return (a > b) ? a : b;
    }
    ```

1. `Class Templates`: These produce templated classes. The Standard Template Library (STL) makes heavy use of this type of template for classes like `std::vector`, `std::map`, etc.
    ```cpp
    template<typename T>
    class Stack {
        // ... class definition ...
    };
    ```

1. `Variable Templates`: Introduced in C++14, these are templates that produce templated variables.
    ```cpp
    template<typename T>
    constexpr T pi = T(3.1415926535897932385);
    ```

1. `Alias Templates`: These are a way to define templated `typedef`, providing a way to simplify complex type names.
    ```cpp
    template<typename T>
    using Vec = std::vector<T, std::allocator<T>>;
    ```

1. `Member Function Templates`: These are member functions within classes that are templated. The containing class itself may or may not be templated.
    ```cpp
    class MyClass {
        template<typename T>
        void myFunction(T t) {
            // ... function implementation ...
        }
    };
    ```

1. `Template Template Parameters`: This advanced feature allows a template to have another template as a parameter.
    ```cpp
    template<template<typename> class ContainerType>
    class MyClass {
        // ... class definition ...
    };
    ```

1. `Non-type Template Parameters`: These are templates that take values (like integers, pointers, etc.) as parameters rather than types.
    ```cpp
    template<int size>
    class Array {
        int elems[size];
        // ... class definition ...
    };
    ```

1. `Nested Templates`: This refers to templates defined within another template. It's not a different kind of template per se, but rather a feature where one template can be nested inside another.

**Function and Class Templates**: When you define a function template or a class template in a header, you're not defining an actual function or class. Instead, you're defining a blueprint from which actual functions or classes can be instantiated. Actual instantiations of these templates (the generated functions or classes) may end up in multiple translation units, but they're identical and thus don't violate the ODR. Only when these templates are instantiated do they become tangible entities in the object file. If multiple translation units include the same function or class template and instantiate it in the same way, they all will have the same instantiation, so it doesn't break One Definition Rule (ODR).

**Variable Templates**: A variable template is still a blueprint, like function and class templates. But the key difference lies in how the compiler treats template instantiations for variables versus functions/classes. For variables, the instantiation actually defines a variable. If this template is instantiated in multiple translation units, it results in multiple definitions of the same variable across those translation units, violating the ODR. Thus, for variable templates, the `inline` keyword is used to ensure that all instances of a variable template across multiple translation units are treated as a single entity, avoiding ODR violations.

## 5.2 template Argument Type

1. `template`模板
1. `typename`模板
1. `enum`模板
1. 非类型模板，通常是整型、布尔等可以枚举的类型

```cpp
#include <iostream>
#include <vector>

template <template <typename> typename V, typename E>
const E& get_back_1(const V<E>& c) {
    return c.back();
}

template <typename T>
const typename T::value_type& get_back_2(const T& c) {
    return c.back();
}

template <size_t I>
const int& get(const std::vector<int>& c) {
    return c[I];
}

int main() {
    std::vector<int> v{1, 2, 3};
    std::cout << get_back_1(v) << std::endl;
    std::cout << get_back_2(v) << std::endl;
    std::cout << get<2>(v) << std::endl;
    return 0;
}
```

## 5.3 template Parameter Pack

[C++ 语言构造参考手册-形参包](https://www.bookstack.cn/read/cppreference-language/5c04935094badaf1.md)

**模板形参包是接受零或更多模板实参（非类型、类型或模板）的模板形参。函数模板形参包是接受零或更多函数实参的函数形参**

**至少有一个形参包的模板被称作变参模板**

**模板形参包（出现于别名模版、类模板、变量模板及函数模板形参列表中）**

* `类型 ... Args(可选)`
* `typename|class ... Args(可选)`
* `template <形参列表> typename(C++17)|class ... Args(可选)`

**函数参数包（声明符的一种形式，出现于变参函数模板的函数形参列表中）**

* `Args ... args(可选)`

**形参包展开（出现于变参模板体中），展开成零或更多模式的逗号分隔列表。模式必须包含至少一个形参包**

* `模式 ...`

## 5.4 Fold Expressions

[C++ 语言构造参考手册-折叠表达式](https://www.bookstack.cn/read/cppreference-language/62e23cda3198622e.md)

**格式如下：**

* 一元右折叠：`( 形参包 op ... )`
* 一元左折叠：`( ... op 形参包 )`
* 二元右折叠：`( 形参包 op ... op 初值 )`
* 二元左折叠：`( 初值 op ... op 形参包 )`

**形参包：含未展开的形参包且其顶层不含有优先级低于转型（正式而言，是 转型表达式）的运算符的表达式。说人话，就是表达式**

**31个合法`op`如下（二元折叠的两个`op`必须一样）：**

1. `+`
1. `-`
1. `/`
1. `%`
1. `^`
1. `&`
1. `|`
1. `=`
1. `<`
1. `>`
1. `<<`
1. `>>`
1. `+=`
1. `-=`
1. `=`
1. `/=`
1. `%=`
1. `^=`
1. `&=`
1. `|=`
1. `<<=`
1. `>>=`
1. `==`
1. `!=`
1. `<=`
1. `>=`
1. `&&`
1. `||`
1. `,`
1. `.`
1. `->`

**形参包折叠的示例1：**

```cpp
#include <cstdint>
#include <type_traits>

template <typename T, typename... Args>
void check_type() {
    static_assert((std::is_same_v<T, Args> || ...), "check failed");
}

int main() {
    check_type<int32_t, int32_t, int64_t>();
    // check_type<int32_t, int8_t, int16_t>();
    return 0;
}
```

**形参包折叠的示例2：**

```cpp
#include <fstream>
#include <iostream>
#include <string>

template <typename... Args>
void read_contents(const std::string& path, Args&... args) {
    std::ifstream ifs;
    ifs.open(path);
    (ifs >> ... >> args);
    ifs.close();
}

int main() {
    std::ofstream ofs;
    ofs.open("/tmp/test.txt");
    ofs << "1 2.3 5";
    ofs.close();

    int first;
    double second;
    int third;

    read_contents("/tmp/test.txt", first, second, third);

    std::cout << first << std::endl;
    std::cout << second << std::endl;
    std::cout << third << std::endl;
    return 0;
}
```

## 5.5 Traverse Parameter Pack

### 5.5.1 Parenthesis Initializer

这里用到了一个技巧，[逗号运算符](https://www.bookstack.cn/read/cppreference-language/ae53223225119599.md#9bocdk)：对于逗号表达式`E1, E2`中，对`E1`求值并舍弃其结果（尽管当它具有类类型时，直到包含它的全表达式的结尾之前都不会销毁它），其副作用在表达式`E2`的求值开始前完成

示例代码如下：

```cpp
#include <iostream>

int main() {
    int n = 1;
    int m = (++n, std::cout << "n = " << n << '\n', ++n, 2 * n); // 2
    std::cout << "m = " << (++m, m) << '\n';                     // 7
}
```

```cpp
#include <fstream>
#include <iostream>
#include <tuple>
#include <type_traits>

template <typename... Values>
bool read_contents(const std::string& path, Values&... values) {
    std::ifstream ifs;
    ifs.open(path);

    bool ok = ifs.good();
    auto read_content = [&ifs, &ok](auto& value) {
        ok &= ifs.good();
        if (!ok) {
            return;
        }
        ifs >> value;
    };

    // Either of the following two methods will work
    // ((read_content(values), ...));
    [[maybe_unused]] int32_t _[] = {(read_content(values), 0)...};

    if (ifs.is_open()) {
        ifs.close();
    }
    return ok;
}

int main() {
    std::ofstream ofs;
    ofs.open("/tmp/test.txt");
    ofs << "1 2.3 5";
    ofs.close();

    int first = -1;
    double second = -1;
    int third = -1;
    double forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test.txt", first, second, third)
              << ", first: " << first << ", second: " << second << ", third: " << third << std::endl;

    first = second = third = forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test.txt", first, second, third, forth)
              << ", first: " << first << ", second: " << second << ", third: " << third << ", forth=" << forth
              << std::endl;

    first = second = third = forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test_wrong.txt", first, second, third, forth)
              << ", first: " << first << ", second: " << second << ", third: " << third << ", forth=" << forth
              << std::endl;
    return 0;
}
```

### 5.5.2 constexpr for

有时候，无法通过折叠表达式处理一些复杂的场景，我们希望能通过循环来挨个处理形参，示例如下（参考[Approximating 'constexpr for'](https://artificial-mind.net/blog/2020/10/31/constexpr-for)）：

* 由于需要在函数内用迭代变量进行形参包的提取，因此这个变量必须是编译期的常量，这里用`std::integral_constant`进行转换，这样在函数内，就可以用`std::get<i>`来提取第`i`个参数了

```cpp
#include <fstream>
#include <iostream>
#include <tuple>
#include <type_traits>

template <auto Start, auto End, auto Inc, typename F>
constexpr void constexpr_for(F&& f) {
    if constexpr (Start < End) {
        f(std::integral_constant<decltype(Start), Start>());
        constexpr_for<Start + Inc, End, Inc>(f);
    }
}

template <typename... Values>
bool read_contents(const std::string& path, Values&... values) {
    std::ifstream ifs;
    ifs.open(path);

    auto tvalues = std::forward_as_tuple(values...);
    bool ok = ifs.good();
    constexpr_for<0, sizeof...(values), 1>([&ifs, &tvalues, &ok](auto i) {
        ok &= ifs.good();
        if (!ok) {
            return;
        }
        ifs >> std::get<i>(tvalues);
    });

    if (ifs.is_open()) {
        ifs.close();
    }
    return ok;
}

int main() {
    std::ofstream ofs;
    ofs.open("/tmp/test.txt");
    ofs << "1 2.3 5";
    ofs.close();

    int first = -1;
    double second = -1;
    int third = -1;
    double forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test.txt", first, second, third)
              << ", first: " << first << ", second: " << second << ", third: " << third << std::endl;

    first = second = third = forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test.txt", first, second, third, forth)
              << ", first: " << first << ", second: " << second << ", third: " << third << ", forth=" << forth
              << std::endl;

    first = second = third = forth = -1;

    std::cout << "is_good: " << std::boolalpha << read_contents("/tmp/test_wrong.txt", first, second, third, forth)
              << ", first: " << first << ", second: " << second << ", third: " << third << ", forth=" << forth
              << std::endl;
    return 0;
}
```

## 5.6 Non-Type template Parameter

我们还可以在模板中定义非类型参数，一个非类型参数表示一个值而非一个类型。当一个模板被实例化时，非类型参数被编译器推断出的值所代替，这些值必须是常量表达式，从而允许编译器在编译时实例化模板。一个非类型参数可以是一个整型（枚举可以理解为整型），或是一个指向对象或函数类型的指针或引用

* 绑定到非类型整型参数的实参必须是一个常量表达式
* 绑定到指针或引用非类型参数必须具有静态的生命周期
* 在模板定义内，模板非类型参数是一个常量值，在需要常量表达式的地方，可以使用非类型参数，例如指定数组大小

```c++
enum BasicType {
    INT,
    DOUBLE
};

template<BasicType BT>
struct RuntimeTypeTraits {
};

// 特化
template<>
struct RuntimeTypeTraits<INT> {
    using Type = int;
};

// 特化
template<>
struct RuntimeTypeTraits<DOUBLE> {
    using Type = double;
};

int main() {
    // 编译期类型推断，value的类型是int
    RuntimeTypeTraits<INT>::Type value = 100;
}
```

## 5.7 When template parameters cannot be inferred

**通常，在`::`左边的模板形参是无法进行推断的（这里的`::`特指用于连接两个类型），例如下面这个例子**

```cpp
template<typename T>
void func(const typename T::type &obj) {
    // ...
}

struct Int {
    using type = int;
};

struct Long {
    using type = long;
};

int main() {
    func(1); // compile error
    func<Int>(1);
    func<Long>(2);
}
```

## 5.8 Using typename to Disambiguate

**什么情况下会有歧义？。例如`foo* ptr;`**

* 若`foo`是个类型，那么该语句就是个声明语句，即定义了一个类型为`foo*`变量
* 若`foo`是个变量，那么该语句就是个表达式语句，即对`foo`以及`ptr`进行`*`运算
* 编译器无法分辨出是上述两种情况的哪一种，因此可以显式使用`typename`来告诉编译器`foo`是个类型

**对于模板而言，例如`T::value_type`，编译器同样无法确定`T::value_type`是个类型还是不是类型。因为类作用域运算符`::`可以访问类型成员也可以访问静态成员。而编译器默认会认为`T::value_type`这种形式默认不是类型**

**示例1：**

```cpp
// 下面这个会编译失败
template<typename T>
T::value_type sum(const T &container) {
    T::value_type res = {};
    for (const auto &item: container) {
        res += item;
    }
    return res;
}
```

**上面的代码有2处错误：**

1. 需要用`typename`显式指定返回类型`T::value_type`
1. 需要用`typename`显式指定`res`的声明类型

**修正后：**

```cpp
template<typename T>
typename T::value_type sum(const T &container) {
    typename T::value_type res = {};
    for (const auto &item: container) {
        res += item;
    }
    return res;
}
```

## 5.9 Using template to Disambiguate

**什么情况下会有歧义？。例如`container.emplace<int>(1);`**

* 若`container.emplace`是个成员变量，那么`<`可以理解成小于号
* 若`container.emplace`是个模板，那么`<`可以理解成模板形参的括号

**示例1：**

```cpp
class Container {
public:
    template<typename T>
    void emplace(T value) {
        std::cout << "emplace value: " << value << std::endl;
    }
};

// 下面这个会编译失败
template<typename T>
void add(T &container) {
    container.emplace<int>(1);
}
```

**上面的代码有1处错误：**

1. 编译器无法确定`container.emplace`是什么含义

**修正后：**

```cpp
template<typename T>
void add(T &container) {
    container.template emplace<int>(1);
}
```

**示例2：**

```cpp
template<typename T>
class Foo {
    template<typename C>
    using container = std::vector<C>;
};

template<typename T>
void bar() {
    T::container<int> res;
}
```

**上面的代码有1处错误：**

1. 编译器无法确定`T::container`是什么含义
1. 需要用`typename`显式指定`T::container<int>`是个类型

**修正后：**

```cpp
template<typename T>
class Foo {
    template<typename C>
    using container = std::vector<C>;
};

template<typename T>
void bar() {
    typename T::template container<int> res;
}
```

## 5.10 Defining a type alias in a template parameter list

语法上，我们是无法在template的参数列表中定义别名的（无法使用`using`）。但是我们可以通过定义有默认值的类型形参来实现类似类型别名的功能，如下：

```cpp
template <typename HashMap, typename KeyType = typename HashMap::key_type,
          typename ValueType = typename HashMap::mapped_type>
ValueType& get(HashMap& map, const KeyType& key) {
    return map[key];
}
```

## 5.11 Accessing members of a template parent class from a non-template derived class

* 方式1：`MemberName`
* 方式2：`this->MemberName`

```cpp
template <typename T>
struct Base {
    T data;
};

struct Derive : Base<int> {
    void set_data_1(const int& other) { data = other; }
    void set_data_2(const int& other) { this->data = other; }
};

int main() {
    Derive t;
    t.set_data_1(1);
    t.set_data_2(2);
    return 0;
}
```

## 5.12 Accessing members of a template parent class from a template derived class

* 访问方式1：`ParentClass<Template Args...>::MemberName`
* 访问方式2：`this->MemberName`

```cpp
template <typename T>
struct Base {
    T data;
};

template <typename T>
struct Derive : Base<T> {
    void set_data_1(const T& data) { Base<T>::data = data; }
    void set_data_2(const T& data) { this->data = data; }
};

int main() {
    Derive<int> t;
    t.set_data_1(5);
    t.set_data_2(6);
    return 0;
}
```

## 5.13 template as a template Parameter

[What are some uses of template template parameters?](https://stackoverflow.com/questions/213761/what-are-some-uses-of-template-template-parameters)

```cpp
#include <iostream>
#include <random>
#include <typeinfo>
#include <vector>

template <template <typename, typename> typename V, typename T, typename A>
void print_last_value(V<T, A>& v) {
    const T& value = v.back();
    std::cout << value << std::endl;
}

template <template <typename> typename V, typename T>
void print_type(const V<T>& value) {
    std::cout << "V<T>'s type=" << typeid(V<T>).name() << std::endl;
    std::cout << "T's type=" << typeid(T).name() << std::endl;
}

int main() {
    std::vector<int> v{1, 2, 3};
    print_last_value(v);
    print_type(v);
    return 0;
}
```

## 5.14 Separating the definition and implementation of a template

我们可以将模板的声明和定义分别放在两个文件中，这样可以使得代码结构更加清晰。例如，假设有两个文件`test.h`和`test.tpp`，其内容分别如下：

* `test.h`
    ```cpp
    #pragma once

    template <typename T>
    class Demo {
    public:
        void func();
    };

    #include "test.tpp"
    ```

* `test.tpp`
    ```cpp
    template <typename T>
    void Demo<T>::func() {
        // do something
    }
    ```

可以看到，`test.h`在追后引用了`test.tpp`，这样其他模块只需要引用`test.h`即可，整个模板的定义也可以通过`test.h`一个文件清晰地看到。但是，这里存在一个问题，如果我们用`vscode`或者`vim`的`lsp`插件来阅读编辑`test.tpp`文件时，会发现存在语法问题，因为`test.tpp`本身并不完整，无法进行编译

参考[[BugFix] Fix the problem of null aware anti join](https://github.com/StarRocks/starrocks/pull/15330)我们可以通过一个小技巧来解决这个问题，我们将`test.h`和`test.tpp`进行如下修改：

* `test.h`
    ```cpp
    #pragma once

    #define TEST_H

    template <typename T>
    class Demo {
    public:
        void func();
    };

    #ifndef TEST_TPP
    #include "test.tpp"
    #endif

    #undef TEST_H
    ```

* `test.tpp`
    ```cpp
    #define TEST_TPP

    #ifndef TEST_H
    #include "test.h"
    #endif

    template <typename T>
    void Demo<T>::func() {
        // do something
    }

    #undef TEST_TPP
    ```

这样，在独立编辑这两个文件时，`lsp`都可以正常工作，也不会造成循环引用的问题

`clangd`在没有`compile_commands.json`文件时，处理单独的`tpp`文件会报错，错误信息是：`Unable to handle compilation, expected exactly one compiler job in ''`

## 5.15 [CRTP](https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern)

`CRTP`的全称是`Curious Recurring Template Pattern`

### 5.15.1 Static Polymorphism

```cpp
#include <iostream>

template <class T>
struct Base {
    void interface() { static_cast<T*>(this)->implementation(); }
    static void static_func() { T::static_sub_func(); }
};

struct Derived : Base<Derived> {
    void implementation() { std::cout << "Derived::implementation" << std::endl; }
    static void static_sub_func() { std::cout << "Dericed::static_sub_func" << std::endl; }
};

int main() {
    Derived d;
    d.interface();
    Derived::static_func();
    return 0;
}
```

### 5.15.2 Object Counter

```cpp
#include <iostream>

template <typename T>
struct counter {
    static inline int objects_created = 0;
    static inline int objects_alive = 0;

    counter() {
        ++objects_created;
        ++objects_alive;
    }

    counter(const counter&) {
        ++objects_created;
        ++objects_alive;
    }

protected:
    ~counter() // objects should never be removed through pointers of this type
    {
        --objects_alive;
    }
};

class X : public counter<X> {
    // ...
};

#define PRINT(expr) std::cout << #expr << ": " << expr << std::endl;

int main() {
    {
        X x;
        PRINT(X::objects_created);
        PRINT(X::objects_alive);
    }
    PRINT(X::objects_created);
    PRINT(X::objects_alive);
    return 0;
}
```

### 5.15.3 Polymorphic Chaining

```cpp
#include <iostream>

enum Color { red, green, yello, blue, white, black };

class PlainPrinter {
public:
    PlainPrinter(std::ostream& pstream) : m_stream(pstream) {}

    template <typename T>
    PlainPrinter& print(T&& t) {
        m_stream << t;
        return *this;
    }

    template <typename T>
    PlainPrinter& println(T&& t) {
        m_stream << t << std::endl;
        return *this;
    }

private:
    std::ostream& m_stream;
};
class PlainCoutPrinter : public PlainPrinter {
public:
    PlainCoutPrinter() : PlainPrinter(std::cout) {}

    PlainCoutPrinter& SetConsoleColor(Color c) {
        // do something to change color
        return *this;
    }
};

template <typename ConcretePrinter>
class Printer {
public:
    Printer(std::ostream& pstream) : m_stream(pstream) {}

    template <typename T>
    ConcretePrinter& print(T&& t) {
        m_stream << t;
        return static_cast<ConcretePrinter&>(*this);
    }

    template <typename T>
    ConcretePrinter& println(T&& t) {
        m_stream << t << std::endl;
        return static_cast<ConcretePrinter&>(*this);
    }

private:
    std::ostream& m_stream;
};

class CoutPrinter : public Printer<CoutPrinter> {
public:
    CoutPrinter() : Printer(std::cout) {}

    CoutPrinter& SetConsoleColor(Color c) {
        // ...
        return *this;
    }
};

int main() {
    // PlainCoutPrinter().print("Hello ").SetConsoleColor(Color::red).println("Printer!"); // compile error
    CoutPrinter().print("Hello ").SetConsoleColor(Color::red).println("Printer!");
    return 0;
}
```

* `PlainCoutPrinter().print("Hello ")`的返回类型是`PlainPrinter`，丢失了具体的`PlainCoutPrinter`类型信息，于是再调用`SetConsoleColor`就报错了
* 而使用`CRTP`就可以避免这个问题，基类的方法返回类型永远是具体的子类

### 5.15.4 Polymorphic Copy Construction

```cpp
#include <memory>

// Base class has a pure virtual function for cloning
class AbstractShape {
public:
    virtual ~AbstractShape() = default;
    virtual std::unique_ptr<AbstractShape> clone() const = 0;
};

// This CRTP class implements clone() for Derived
template <typename Derived>
class Shape : public AbstractShape {
public:
    std::unique_ptr<AbstractShape> clone() const override {
        return std::make_unique<Derived>(static_cast<Derived const&>(*this));
    }

protected:
    // We make clear Shape class needs to be inherited
    Shape() = default;
    Shape(const Shape&) = default;
    Shape(Shape&&) = default;
};

// Every derived class inherits from CRTP class instead of abstract class
class Square : public Shape<Square> {};

class Circle : public Shape<Circle> {};

int main() {
    Square s;
    auto clone = s.clone();
    return 0;
}
```

## 5.16 PIMPL

In C++, the term `pimpl` is short for `pointer to implementation` or `private implementation`. It's an idiom used to separate the public interface of a class from its implementation details. This helps improve code modularity, encapsulation, and reduces compile-time dependencies.

Here's how the pimpl idiom works:

1. **Public Interface**: You define a class in your header file (`.h` or `.hpp`) that contains only the public interface members (public functions, typedefs, etc.). This header file should include minimal implementation details to keep the interface clean and focused.
1. **Private Implementation**: In the implementation file (`.cpp`), you declare a private class that holds the actual implementation details of your class. This private class is typically defined within an anonymous namespace or as a private nested class of the original class. The private class contains private data members, private functions, and any other implementation-specific details.
1. **Pointer to Implementation**: Within the main class, you include a pointer to the private implementation class. The public functions in the main class forward calls to the corresponding functions in the private implementation class.

By using the pimpl idiom, you achieve several benefits:

* Reduces compile-time dependencies: Changes to the private implementation do not require recompilation of the public interface, reducing compilation times.
* Enhances encapsulation: Clients of the class only need to know about the public interface, shielding them from implementation details.
* Minimizes header dependencies: Since the private implementation is not exposed in the header, you avoid leaking implementation details to client code.
* Eases binary compatibility: Changing the private implementation does not require recompiling or re-linking client code, as long as the public interface remains unchanged.

Here's a simplified example of the pimpl idiom:

```cpp
// Widget.h
class Widget {
public:
    Widget();
    ~Widget();

    void DoSomething();

private:
    class Impl; // Forward declaration of the private implementation class
    Impl* pImpl; // Pointer to the private implementation
};
```

```cpp
// Widget.cpp
#include "Widget.h"

class Widget::Impl {
public:
    void PerformAction() {
        // Implementation details
    }
};

Widget::Widget() : pImpl(new Impl()) {}

Widget::~Widget() {
    delete pImpl;
}

void Widget::DoSomething() {
    pImpl->PerformAction();
}
```

# 6 Memory Model

## 6.1 Concepts

### 6.1.1 Cache coherence & Memory consistency

Cache coherence and memory consistency are two fundamental concepts in parallel computing systems, but they address different issues:

**Cache Coherence**:

* **This concept is primarily concerned with the values of copies of a single memory location that are cached at several caches (typically, in a multiprocessor system)**. When multiple processors with separate caches are in a system, it's possible for those caches to hold copies of the same memory location. **Cache coherence ensures that all processors in the system observe a single, consistent value for the memory location**. It focuses on maintaining a global order in which writes to each individual memory location occur.
* For example, suppose we have two processors P1 and P2, each with its own cache. If P1 changes the value of a memory location X that's also stored in P2's cache, the cache coherence protocols will ensure that P2 sees the updated value if it tries to read X.

**Memory Consistency**: 

* While cache coherence is concerned with the view of a single memory location, **memory consistency is concerned about the ordering of multiply updates to different memory locations(or single memory location) from different processors. It determines when a write by one processor to a shared memory location becomes visible to all other processors.**
* A memory consistency model defines the architecturally visible behavior of a memory system. Different consistency models make different guarantees about the order and visibility of memory operations across different threads or processors. For example, sequential consistency, a strict type of memory consistency model, says that all memory operations must appear to execute in some sequential order that's consistent with the program order of each individual processor.

In summary, while both are essential for correctness in multiprocessor systems, cache coherence deals with maintaining a consistent view of a single memory location, while memory consistency is concerned with the order and visibility of updates to different memory locations.

### 6.1.2 Happens-before

If an operation A "happens-before" another operation B, it means that A is guaranteed to be observed by B. In other words, any data or side effects produced by A will be visible to B when it executes.

![happens-before](/images/Cpp-Language/happens-before.png)

## 6.2 Memory consistency model

### 6.2.1 Sequential consistency model

> the result of any execution is the same as if the operations of all the processors were executed in some sequential order, and the operations of each individual processor appear in this sequence in the order specified by its program

**`Sequential consistency model (SC)`**, also known as the sequential consistency model, essentially stipulates two things:

1. **Each thread's instructions are executed in the order specified by the program (from the perspective of a single thread)**
2. **The interleaving order of thread execution can be arbitrary, but the overall execution order of the entire program, as observed by all threads, must be the same (from the perspective of the entire program)**
    * That is, there should not be a situation where for write operations `W1` and `W2`, processor 1 sees the order as: `W1 -> W2`; while processor 2 sees the order as: `W2 -> W1`

### 6.2.2 Relaxed consistency model

**`Relaxed consistency model` also known as the loose memory consistency model, is characterized by:**

1. **Within the same thread, access to the same atomic variable cannot be reordered (from the perspective of a single thread)**
2. **Apart from ensuring the atomicity of operations, there is no stipulation on the order of preceding and subsequent instructions, and the order in which other threads observe data changes may also be different (from the perspective of the entire program)**
    * That is, different threads may observe the relaxed operations on a single atomic value in different orders.

**Looseness can be measured along the following two dimensions:**

* How to relax the requirements of program order. Typically, this refers to the read and write operations of different variables; for the same variable, read and write operations cannot be reordered. Program order requirements include:
    * `read-read`
    * `read-write`
    * `write-read`
    * `write-write`
* How they relax the requirements for write atomicity. Models are differentiated based on whether they allow a read operation to return the written value of another processor before all cache copies have received the invalidation or update message produced by the write; in other words, allowing a processor to read the written value before the write is visible to all other processors.

**Through these two dimensions, the following relaxed strategies have been introduced:**

* Relaxing the `write-read` program order. Supported by `TSO` (Total Store Order)
* Relaxing the `write-write` program order
* Relaxing the `read-read` and `read-write` program order
* Allowing early reads of values written by other processors
* Allowing early reads of values written by the current processor

### 6.2.3 Total Store Order

otal Store Order (TSO) is a type of memory consistency model used in computer architecture to manage how memory operations (reads and writes) are ordered and observed by different parts of the system.

In a Total Store Order model:

* **Writes are not immediately visible to all processors**: When a processor writes to memory, that write is not instantly visible to all other processors. There's a delay because writes are first written to a store buffer unique to each processor.
* **Writes are seen in order**: Even though there's a delay in visibility, writes to the memory are seen by all processors in the same order. This is the "total order" part of TSO, which means that if Processor A sees Write X followed by Write Y, Processor B will also see Write X before Write Y.
* **Reads may bypass writes**: If a processor reads a location that it has just written to, it may get the value from its store buffer (the most recent write) rather than the value that is currently in memory. This means a processor can see its writes immediately but may not see writes from other processors that happened after its own write.
* **Writes from a single processor are seen in the order issued**: Writes by a single processor are observed in the order they were issued by that processor. If Processor A writes to memory location X and then to memory location Y, all processors will see the write to X happen before the write to Y.

This model is a compromise between strict ordering and performance. In a system that enforces strict ordering (like Sequential Consistency), every operation appears to happen in a strict sequence, which can be quite slow. TSO allows some operations to be reordered (like reads happening before a write is visible to all) for better performance while still maintaining a predictable order for writes, which is critical for correctness in many concurrent algorithms.

TSO is commonly used in x86 processors, which strikes a balance between the predictable behavior needed for programming ease and the relaxed rules that allow for high performance in practice.

## 6.3 std::memory_order

1. `std::memory_order_seq_cst`: **Provide happens-before relationship.**
1. `std::memory_order_relaxed`: **CAN NOT Provide happens-before relationship.** Which specific relaxation strategies are adopted must be determined based on the hardware platform.
    * When you use `std::memory_order_relaxed`, it guarantees the following:
        1. Sequential consistency for atomic operations on a single variable: If you perform multiple atomic operations on the same atomic variable using `std::memory_order_relaxed`, the result will be as if those operations were executed in some sequential order. This means that the final value observed by any thread will be a valid result based on the ordering of the operations.
        1. Coherence: All threads will eventually observe the most recent value written to an atomic variable. However, the timing of when each thread observes the value may differ due to the relaxed ordering.
        1. Atomicity: Atomic operations performed with `std::memory_order_relaxed` are indivisible. They are guaranteed to be performed without interruption or interference from other threads.
1. `std::memory_order_acquire` and `std::memory_order_release`: **Provide happens-before relationship.**
    * When used together, `std::memory_order_acquire` and `std::memory_order_release` can establish a happens-before relationship between threads, allowing for proper synchronization and communication between them
        1. `std::memory_order_acquire` is a memory ordering constraint that provides acquire semantics. It ensures that any memory operations that occur before the acquire operation in the program order will be visible to the thread performing the acquire operation.
        1. `std::memory_order_release` is a memory ordering constraint that provides release semantics. It ensures that any memory operations that occur after the release operation in the program order will be visible to other threads that perform subsequent acquire operations.

## 6.4 Cases

### 6.4.1 Case-1-happens-before

happens-before在不同`std::memory_order`下的规则

* `std::memory_order_seq_cst`
    * normal-write happens-before atomic-write
    * atomic-read happens-before normal-read
    * atomic-write happens-before atomic-read
    * 可以推导出：normal-write happens-before normal-read
* `std::memory_order_relaxed`
    * normal-write happens-before atomic-write
    * atomic-read happens-before normal-read
    * 无法推导出：normal-write happens-before normal-read

下面的程序：

* `test_atomic_visibility<std::memory_order_seq_cst>();`可以正确执行
* `test_atomic_visibility<std::memory_order_relaxed>();`也可以正确执行。因为x86是`TSO`模型，`std::memory_order_relaxed`同样满足`atomic-write happens-before atomic-read`规则
* `test_volatile_visibility`会报错，因为`volatile`不提供同步语义，对重排没有限制

```cpp
#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>

constexpr int32_t INVALID_VALUE = -1;
constexpr int32_t EXPECTED_VALUE = 99;
constexpr int32_t TIMES = 1000000;

int32_t data;
std::atomic<bool> atomic_data_ready(false);
volatile bool volatile_data_ready(false);

template <std::memory_order read_order, std::memory_order write_order>
void test_atomic_happens_before() {
    auto reader_thread = []() {
        for (auto i = 0; i < TIMES; i++) {
            // atomic read
            while (!atomic_data_ready.load(read_order))
                ;

            // normal read: atomic read happens-before normal read
            assert(data == EXPECTED_VALUE);

            data = INVALID_VALUE;
            atomic_data_ready.store(false, write_order);
        }
    };
    auto writer_thread = []() {
        for (auto i = 0; i < TIMES; i++) {
            while (atomic_data_ready.load(read_order))
                ;

            // normal write
            data = EXPECTED_VALUE;

            // atomic write: normal write happens-before atomic write
            atomic_data_ready.store(true, write_order);
        }
    };

    data = INVALID_VALUE;
    atomic_data_ready = false;

    std::thread t1(reader_thread);
    std::thread t2(writer_thread);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    t1.join();
    t2.join();
}

void test_volatile_happens_before() {
    auto reader_thread = []() {
        for (auto i = 0; i < TIMES; i++) {
            while (!volatile_data_ready)
                ;

            assert(data == EXPECTED_VALUE);

            data = INVALID_VALUE;
            volatile_data_ready = false;
        }
    };
    auto writer_thread = []() {
        for (auto i = 0; i < TIMES; i++) {
            while (volatile_data_ready)
                ;

            data = EXPECTED_VALUE;

            volatile_data_ready = true;
        }
    };

    data = INVALID_VALUE;
    volatile_data_ready = false;

    std::thread t1(reader_thread);
    std::thread t2(writer_thread);
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    t1.join();
    t2.join();
}

int main() {
    test_atomic_happens_before<std::memory_order_seq_cst, std::memory_order_seq_cst>();
    test_atomic_happens_before<std::memory_order_acquire, std::memory_order_release>();
    test_atomic_happens_before<std::memory_order_relaxed, std::memory_order_relaxed>();
    test_volatile_happens_before(); // Failed assertion
    return 0;
}
```

### 6.4.2 Case-2-write-read-reorder

来自[Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf)中的`Figure-5(a)`

```cpp
#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>

constexpr size_t TIMES = 1000000;

template <std::memory_order read_order, std::memory_order write_order>
bool test_reorder() {
    // control vars
    std::atomic<bool> control(false);
    std::atomic<bool> stop(false);
    std::atomic<bool> success(true);
    std::atomic<int32_t> finished_num = 0;

    auto round_process = [&control, &stop, &finished_num](auto&& process) {
        while (!stop) {
            // make t1 and t2 go through synchronously
            finished_num++;
            while (!stop && !control)
                ;

            process();

            // wait for next round
            finished_num++;
            while (!stop && control)
                ;
        }
    };

    auto control_process = [&control, &success, &finished_num](auto&& clean_process, auto&& check_process) {
        for (size_t i = 0; i < TIMES; i++) {
            // wait t1 and t2 at the top of the loop
            while (finished_num != 2)
                ;

            // clean up data
            finished_num = 0;
            clean_process();

            // let t1 and t2 go start
            control = true;

            // wait t1 and t2 finishing write operation
            while (finished_num != 2)
                ;

            // check assumption
            if (!check_process()) {
                success = false;
            }

            finished_num = 0;
            control = false;
        }
    };

    // main vars
    std::atomic<int32_t> flag1, flag2;
    std::atomic<int32_t> critical_num;

    auto process_1 = [&flag1, &flag2, &critical_num]() {
        flag1.store(1, write_order);
        if (flag2.load(read_order) == 0) {
            critical_num++;
        }
    };
    auto process_2 = [&flag1, &flag2, &critical_num]() {
        flag2.store(1, write_order);
        if (flag1.load(read_order) == 0) {
            critical_num++;
        }
    };
    auto clean_process = [&flag1, &flag2, &critical_num]() {
        flag1 = 0;
        flag2 = 0;
        critical_num = 0;
    };
    auto check_process = [&critical_num]() { return critical_num <= 1; };

    std::thread t_1(round_process, process_1);
    std::thread t_2(round_process, process_2);
    std::thread t_control(control_process, clean_process, check_process);

    t_control.join();
    stop = true;
    t_1.join();
    t_2.join();

    return success;
}

int main() {
    bool res;
    res = test_reorder<std::memory_order_seq_cst, std::memory_order_seq_cst>();
    std::cout << "test std::memory_order_seq_cst, std::memory_order_seq_cst"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_acquire, std::memory_order_release>();
    std::cout << "test std::memory_order_acquire, std::memory_order_release"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_relaxed, std::memory_order_relaxed>();
    std::cout << "test std::memory_order_relaxed, std::memory_order_relaxed"
              << ", res=" << std::boolalpha << res << std::endl;
    return 0;
}
```

在`x86`平台（`TSO`），结果如下，只有`memory_order_seq_cst`能保证一致性，而`memory_order_acquire/memory_order_release`仅针对同一变量，不同变量的`Write-Read`仍然可能重排

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=false
test std::memory_order_relaxed, std::memory_order_relaxed, res=false
```

### 6.4.3 Case-3-write-write-read-read-reorder

来自[Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf)中的`Figure-5(b)`

```cpp
#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>

constexpr size_t TIMES = 1000000;

template <std::memory_order read_order, std::memory_order write_order>
bool test_reorder() {
    // control vars
    std::atomic<bool> control(false);
    std::atomic<bool> stop(false);
    std::atomic<bool> success(true);
    std::atomic<int32_t> finished_num = 0;

    auto round_process = [&control, &stop, &finished_num](auto&& process) {
        while (!stop) {
            // make t1 and t2 go through synchronously
            finished_num++;
            while (!stop && !control)
                ;

            process();

            // wait for next round
            finished_num++;
            while (!stop && control)
                ;
        }
    };

    auto control_process = [&control, &success, &finished_num](auto&& clean_process, auto&& check_process) {
        for (size_t i = 0; i < TIMES; i++) {
            // wait t1 and t2 at the top of the loop
            while (finished_num != 2)
                ;

            // clean up data
            finished_num = 0;
            clean_process();

            // let t1 and t2 go start
            control = true;

            // wait t1 and t2 finishing write operation
            while (finished_num != 2)
                ;

            // check assumption
            if (!check_process()) {
                success = false;
            }

            finished_num = 0;
            control = false;
        }
    };

    // main vars
    std::atomic<int32_t> data;
    std::atomic<int32_t> head;
    std::atomic<int32_t> read_val;

    auto process_1 = [&data, &head]() {
        data.store(2000, write_order);
        head.store(1, write_order);
    };
    auto process_2 = [&data, &head, &read_val]() {
        while (head.load(read_order) == 0)
            ;
        read_val = data.load(read_order);
    };
    auto clean_process = [&data, &head, &read_val]() {
        data = 0;
        head = 0;
        read_val = 0;
    };
    auto check_process = [&read_val]() { return read_val == 2000; };

    std::thread t_1(round_process, process_1);
    std::thread t_2(round_process, process_2);
    std::thread t_control(control_process, clean_process, check_process);

    t_control.join();
    stop = true;
    t_1.join();
    t_2.join();

    return success;
}

int main() {
    bool res;
    res = test_reorder<std::memory_order_seq_cst, std::memory_order_seq_cst>();
    std::cout << "test std::memory_order_seq_cst, std::memory_order_seq_cst"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_acquire, std::memory_order_release>();
    std::cout << "test std::memory_order_acquire, std::memory_order_release"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_relaxed, std::memory_order_relaxed>();
    std::cout << "test std::memory_order_relaxed, std::memory_order_relaxed"
              << ", res=" << std::boolalpha << res << std::endl;
    return 0;
}
```

在`x86`平台（`TSO`），`Relaxed Consistency Model`不允许`Write-Write`以及`Read-Read`重排，结果如下（对于其他具有不同内存模型的硬件平台，由于对`Relaxed`的支持程度不同，可能会有不同的结果）：

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=true
test std::memory_order_relaxed, std::memory_order_relaxed, res=true
```

### 6.4.4 Case-4-write-order-consistency

来自[Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf)中的`Figure-10(b)`

```cpp
#include <atomic>
#include <cassert>
#include <iostream>
#include <thread>

constexpr size_t TIMES = 1000000;

template <std::memory_order read_order, std::memory_order write_order>
bool test_reorder() {
    // control vars
    std::atomic<bool> control(false);
    std::atomic<bool> stop(false);
    std::atomic<bool> success(true);
    std::atomic<int32_t> finished_num = 0;

    auto round_process = [&control, &stop, &finished_num](auto&& process) {
        while (!stop) {
            // make t1 and t2 go through synchronously
            finished_num++;
            while (!stop && !control)
                ;

            process();

            // wait for next round
            finished_num++;
            while (!stop && control)
                ;
        }
    };

    auto control_process = [&control, &success, &finished_num](auto&& clean_process, auto&& check_process) {
        for (size_t i = 0; i < TIMES; i++) {
            // wait t1, t2 and t3 at the top of the loop
            while (finished_num != 3)
                ;

            // clean up data
            finished_num = 0;
            clean_process();

            // let t1, t2 and t3 go start
            control = true;

            // wait t1, t2 and t3 finishing write operation
            while (finished_num != 3)
                ;

            // check assumption
            if (!check_process()) {
                success = false;
            }

            finished_num = 0;
            control = false;
        }
    };

    // main vars
    std::atomic<int32_t> a;
    std::atomic<int32_t> b;
    std::atomic<int32_t> reg;

    auto process_1 = [&a]() { a.store(1, write_order); };
    auto process_2 = [&a, &b]() {
        if (a.load(read_order) == 1) {
            b.store(1, write_order);
        }
    };
    auto process_3 = [&a, &b, &reg]() {
        if (b.load(read_order) == 1) {
            reg.store(a.load(read_order), write_order);
        }
    };
    auto clean_process = [&a, &b, &reg]() {
        a = 0;
        b = 0;
        reg = -1;
    };
    auto check_process = [&reg]() { return reg != 0; };

    std::thread t_1(round_process, process_1);
    std::thread t_2(round_process, process_2);
    std::thread t_3(round_process, process_3);
    std::thread t_control(control_process, clean_process, check_process);

    t_control.join();
    stop = true;
    t_1.join();
    t_2.join();
    t_3.join();

    return success;
}

int main() {
    bool res;
    res = test_reorder<std::memory_order_seq_cst, std::memory_order_seq_cst>();
    std::cout << "test std::memory_order_seq_cst, std::memory_order_seq_cst"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_acquire, std::memory_order_release>();
    std::cout << "test std::memory_order_acquire, std::memory_order_release"
              << ", res=" << std::boolalpha << res << std::endl;
    res = test_reorder<std::memory_order_relaxed, std::memory_order_relaxed>();
    std::cout << "test std::memory_order_relaxed, std::memory_order_relaxed"
              << ", res=" << std::boolalpha << res << std::endl;
    return 0;
}
```

在`x86`平台（`TSO`），`Relaxed Consistency Model`要求所有核看到的`Write`顺序是一致的，结果如下（对于其他具有不同内存模型的硬件平台，由于对`Relaxed`的支持程度不同，可能会有不同的结果）：

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=true
test std::memory_order_relaxed, std::memory_order_relaxed, res=true
```

### 6.4.5 Case-5-visibility

进程调度也能保证可见性，我们可以让读写线程绑定到某个核上，那么读写线程会在调度的作用下交替执行

```cpp
#include <pthread.h>

#include <atomic>
#include <iostream>
#include <thread>
#include <type_traits>

template <typename T, bool use_inc>
void test_concurrent_visibility() {
    constexpr size_t TIMES = 1000000;
    T count = 0;
    auto func = [&count]() {
        pthread_t thread = pthread_self();

        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(0, &cpuset);
        if (pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
            return;
        }

        if (pthread_getaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
            return;
        }

        for (size_t i = 0; i < TIMES; i++) {
            if constexpr (use_inc) {
                count++;
            } else {
                count = count + 1;
            }
        }
    };

    std::thread t1(func);
    std::thread t2(func);

    t1.join();
    t2.join();
    if constexpr (std::is_same_v<T, int32_t>) {
        std::cout << "type=int32_t, count=" << count << std::endl;
    } else if constexpr (std::is_same_v<T, volatile int32_t>) {
        std::cout << "type=volatile int32_t, count=" << count << std::endl;
    } else if constexpr (std::is_same_v<T, std::atomic<int32_t>>) {
        std::cout << "type=std::atomic<int32_t>, count=" << count << std::endl;
    }
}

int main() {
    test_concurrent_visibility<int32_t, true>();
    test_concurrent_visibility<volatile int32_t, false>();
    test_concurrent_visibility<std::atomic<int32_t>, true>();
    return 0;
}
```

输出如下：

```
type=int32_t, count=2000000
type=volatile int32_t, count=2000000
type=std::atomic<int32_t>, count=2000000
```

### 6.4.6 Case-6-eventual-consistency

不同的原子操作，虽然无法保证同步语义，但是可以保证变量的最终一致性

* 无原子操作时，`write`线程的写操作无法被`read`线程的读操作看到（`-O3`优化级别）
    ```cpp
    #include <iostream>
    #include <thread>

    int main() {
        size_t data = 0;
        std::thread read([&data]() {
            int64_t prev = -1;
            while (true) {
                if (prev != -1 && prev != data) {
                    std::cout << "see changes, prev=" << prev << ", data=" << data << std::endl;
                }
                prev = data;
            }
        });
        std::thread write([&data]() {
            while (true) {
                data++;
            }
        });

        read.join();
        write.join();
        return 0;
    }
    ```

* 用不同的`std::mutex`可以保证变量的最终一致性
    ```cpp
    #include <iostream>
    #include <mutex>
    #include <thread>

    int main() {
        size_t data = 0;
        std::thread read([&data]() {
            std::mutex m_read;
            int64_t prev = -1;
            while (true) {
                std::lock_guard<std::mutex> l(m_read);
                if (prev != -1 && prev != data) {
                    std::cout << "see changes, prev=" << prev << ", data=" << data << std::endl;
                }
                prev = data;
            }
        });
        std::thread write([&data]() {
            std::mutex m_write;
            while (true) {
                std::lock_guard<std::mutex> l(m_write);
                data++;
            }
        });

        read.join();
        write.join();
        return 0;
    }
    ```

* 用不同的`std::atomic`可以保证变量的最终一致性
    ```cpp
    #include <atomic>
    #include <iostream>
    #include <thread>

    int main() {
        size_t data = 0;
        std::thread read([&data]() {
            std::atomic<int32_t> atom_read;
            int64_t prev = -1;
            while (true) {
                atom_read.load();
                if (prev != -1 && prev != data) {
                    std::cout << "see changes, prev=" << prev << ", data=" << data << std::endl;
                }
                prev = data;
            }
        });
        std::thread write([&data]() {
            std::atomic<int32_t> atom_write;
            while (true) {
                data++;
                atom_write.store(1);
            }
        });

        read.join();
        write.join();
        return 0;
    }
    ```

## 6.5 x86 Memory Model

对于`std::memory_order_relaxed`，在不同的硬件平台上，其效果是不同的。x86属于`TSO`

[x86-TSO : 适用于x86体系架构并发编程的内存模型](https://www.cnblogs.com/lqlqlq/p/13693876.html)

## 6.6 Reference

* [C++11 - atomic类型和内存模型](https://zhuanlan.zhihu.com/p/107092432)
* [cppreference.com-std::memory_order](https://en.cppreference.com/w/cpp/atomic/memory_order)
* [如何理解 C++11 的六种 memory order？](https://www.zhihu.com/question/24301047)
* [并行编程——内存模型之顺序一致性](https://www.cnblogs.com/jiayy/p/3246157.html)
* [漫谈内存一致性模型](https://zhuanlan.zhihu.com/p/91406250)

# 7 Mechanism

## 7.1 lvalue & rvalue

[Value categories](https://en.cppreference.com/w/cpp/language/value_category)

```cpp
#include <iostream>

class Foo {
public:
    Foo() = default;
    Foo(const Foo&) { std::cout << "Foo(const Foo&)" << std::endl; }
    Foo(Foo&&) { std::cout << "Foo(Foo&&)" << std::endl; }
};

class HolderWithoutMove {
public:
    explicit HolderWithoutMove(Foo&& foo) : _foo(foo) {}

private:
    const Foo _foo;
};

class HolderWithMove {
public:
    explicit HolderWithMove(Foo&& foo) : _foo(std::move(foo)) {}

private:
    const Foo _foo;
};

void receiveFoo(Foo&) {
    std::cout << "receiveFoo(Foo&)" << std::endl;
}
void receiveFoo(Foo&&) {
    std::cout << "receiveFoo(Foo&&)" << std::endl;
}

void forwardWithoutMove(Foo&& foo) {
    receiveFoo(foo);
}
void forwardWithMove(Foo&& foo) {
    receiveFoo(std::move(foo));
}

int main() {
    HolderWithoutMove holder1({});
    HolderWithMove holder2({});
    forwardWithoutMove({});
    forwardWithMove({});
    return 0;
}
```

Output:

```
Foo(const Foo&)
Foo(Foo&&)
receiveFoo(Foo&)
receiveFoo(Foo&&)
```

## 7.2 Move Semantics

**For argument passing:**

* If a function receives an object of type `T`(not reference type), you pass lvalue, then copy constructor is called to create the object; you pass rvalue, then move constructor is called to create the object

```cpp
#include <iostream>
#include <vector>

class Foo {
public:
    Foo() { std::cout << "Foo::Foo()" << std::endl; }
    Foo(const Foo&) { std::cout << "Foo::Foo(const Foo&)" << std::endl; }
    Foo(Foo&&) { std::cout << "Foo::Foo(Foo&&)" << std::endl; }
    Foo& operator=(const Foo&) {
        std::cout << "Foo::operator=(const Foo&)" << std::endl;
        return *this;
    }
    Foo& operator=(Foo&&) {
        std::cout << "Foo::operator=(Foo&&)" << std::endl;
        return *this;
    }
};

Foo getFoo() {
    return {};
}

class Bar {
public:
    Bar() = default;
    Bar(const Bar&) { std::cout << "Bar::Bar(const Bar&)" << std::endl; }
    Bar(Bar&&) { std::cout << "Bar::Bar(Bar&&)" << std::endl; }
};

void receiveBar(Bar bar) {
    std::cout << "receiveBar(Bar)" << std::endl;
}

int main() {
    std::vector<Foo> v;
    // Avoid scale up
    v.reserve(3);

    std::cout << "\npush_back without std::move" << std::endl;
    // This move operation is possible because the object returned by getFoo() is an rvalue, which is eligible for move semantics.
    v.push_back(getFoo());

    std::cout << "\npush_back with std::move (1)" << std::endl;
    v.push_back(std::move(getFoo()));

    std::cout << "\npush_back with std::move (2)" << std::endl;
    Foo foo = getFoo();
    v.push_back(std::move(foo));

    std::cout << "\nassign without std::move" << std::endl;
    Foo foo_assign;
    foo_assign = getFoo();

    std::cout << "\nassign with std::move" << std::endl;
    foo_assign = std::move(getFoo());

    Bar bar1, bar2;
    std::cout << "\npass without std::move" << std::endl;
    receiveBar(bar1);
    std::cout << "\npass with std::move" << std::endl;
    receiveBar(std::move(bar2));
    return 0;
}
```

**Output:**

```
push_back without std::move
Foo::Foo()
Foo::Foo(Foo&&)

push_back with std::move (1)
Foo::Foo()
Foo::Foo(Foo&&)

push_back with std::move (2)
Foo::Foo()
Foo::Foo(Foo&&)

assign without std::move
Foo::Foo()
Foo::Foo()
Foo::operator=(Foo&&)

assign with std::move
Foo::Foo()
Foo::operator=(Foo&&)

pass without std::move
Bar::Bar(const Bar&)
receiveBar(Bar)

pass with std::move
Bar::Bar(Bar&&)
receiveBar(Bar)
```

## 7.3 Structured Bindings

Structured bindings were introduced in C++17 and provide a convenient way to destructure the elements of a tuple-like object or aggregate into individual variables.

Tuple-like objects in C++ include:

* `std::tuple`: The standard tuple class provided by the C++ Standard Library.
* `std::pair`: A specialized tuple with exactly two elements, also provided by the C++ Standard Library.
* Custom user-defined types that mimic the behavior of tuples, such as structs with a fixed number of members.

```cpp
#include <iostream>
#include <tuple>

struct Person {
    std::string name;
    int age;
    double height;

    // Constructor
    Person(const std::string& n, int a, double h) : name(n), age(a), height(h) {}
};

int main() {
    std::tuple<int, double, std::string> myTuple(42, 3.14, "Hello");

    auto [x, y, z] = myTuple;

    std::cout << "x: " << x << std::endl;
    std::cout << "y: " << y << std::endl;
    std::cout << "z: " << z << std::endl;

    // Create an instance of the custom struct
    Person person("Alice", 30, 1.75);

    // Structured binding to extract elements
    auto [name, age, height] = person;

    // Print the extracted elements
    std::cout << "Name: " << name << std::endl;
    std::cout << "Age: " << age << std::endl;
    std::cout << "Height: " << height << std::endl;

    return 0;
}
```

## 7.4 Copy Elision

* [Copy elision](https://en.cppreference.com/w/cpp/language/copy_elision)
* [What are copy elision and return value optimization?](https://stackoverflow.com/questions/12953127/what-are-copy-elision-and-return-value-optimization)

Copy elision is an optimization technique used by compilers in C++ to reduce the overhead of copying and moving objects. This optimization can significantly improve performance by eliminating unnecessary copying of objects, especially in return statements or during function calls. Two specific cases of copy elision are Return Value Optimization (RVO) and Named Return Value Optimization (NRVO). Let's explore each of these:

* `Return Value Optimization (RVO)`: RVO is a compiler optimization that eliminates the need for a temporary object when a function returns an object by value. Normally, when a function returns an object, a temporary copy of the object is created (which invokes the copy constructor), and then the temporary object is copied to the destination variable. With RVO, the compiler can directly construct the return value in the memory location of the caller's receiving variable, thereby skipping the creation and copy of the temporary object.
    ```
    #include <iostream>

    class Widget {
    public:
        Widget() {}
        Widget(const Widget&) { std::cout << "Copy constructor called!\n"; }
    };

    Widget createWidget() {
        return Widget();
    }

    int main() {
        Widget w = createWidget(); // With RVO, the copy constructor is not called
        return 0;
    }
    ```

* `Named Return Value Optimization (NRVO)`: Similar to RVO, NRVO allows the compiler to eliminate the temporary object even when the object returned has a name. NRVO is a bit more challenging for the compiler because it involves predicting which named variable will be returned at compile time.

    ```cpp
    #include <iostream>

    class Widget {
    public:
        Widget() {}
        Widget(const Widget&) { std::cout << "Copy constructor called!\n"; }
    };

    Widget createWidget() {
        Widget w;
        return w; // Normally, this would call the copy constructor
    }

    int main() {
        Widget w = createWidget(); // With RVO, the copy constructor is not called
        return 0;
    }
    ```

## 7.5 Implicit Type Conversions

**Implicit conversion sequence consists of the following, in this order:**

1. zero or one standard conversion sequence;
1. zero or one user-defined conversion;
1. zero or one standard conversion sequence (only if a user-defined conversion is used).

**A standard conversion sequence consists of the following, in this order:**

1. zero or one conversion from the following set:
    * lvalue-to-rvalue conversion,
    * array-to-pointer conversion, and
    * function-to-pointer conversion;
1. zero or one numeric promotion or numeric conversion;
1. zero or one function pointer conversion;
1. zero or one qualification conversion.

**Assored conversion types:**

1. derived-to-base pointer conversions;

# 8 Policy

## 8.1 Pointer Stability

**`pointer stability`通常用于描述容器。当我们说一个容器是`pointer stability`时，是指，当某个元素添加到容器之后、从容器删除之前，该元素的内存地址不变，也就是说，该元素的内存地址，不会受到容器的添加删除元素、扩缩容、或者其他操作影响**

* 引用也会受到这个性质的影响，因为引用就是指针的语法糖

**[absl](https://abseil.io/docs/cpp/guides/container)**

| Container | Is pointer stability or not | Description |
|:--|:--|:--|
| `std::vector` | ❌ |  |
| `std::list` | ✅ |  |
| `std::deque` | ❌ | Expand may keep pointer stablity, but contract may not |
| `std::map` | ✅ |  |
| `std::unordered_map` | ✅ |  |
| `std::set` | ✅ |  |
| `std::unordered_set` | ✅ |  |
| `absl::flat_hash_map` | ❌ |  |
| `absl::flat_hash_set` | ❌ |  |
| `absl::node_hash_map` | ✅ |  |
| `absl::node_hash_set` | ✅ |  |
| `phmap::flat_hash_map` | ❌ |  |
| `phmap::flat_hash_set` | ❌ |  |
| `phmap::node_hash_map` | ✅ |  |
| `phmap::node_hash_set` | ✅ |  |

## 8.2 Exception Safe

[Wiki-Exception safety](https://en.wikipedia.org/wiki/Exception_safety)

**`exception safety`的几个级别：**

1. `No-throw guarantee`：承诺不会对外抛出任何异常。方法内部可能会抛异常，但都会被正确处理
1. `Strong exception safety`：可能会抛出异常，但是承诺不会有副作用，所有对象都会恢复到调用方法时的初始状态
1. `Basic exception safety`：可能会抛出异常，操作失败的部分可能会导致副作用，但所有不变量都会被保留。任何存储的数据都将包含可能与原始值不同的有效值。资源泄漏（包括内存泄漏）通常通过一个声明所有资源都被考虑和管理的不变量来排除
1. `No exception safety`：不承诺异常安全

## 8.3 RAII

`RAII, Resource Acquisition is initialization`，即资源获取即初始化。典型示例包括：`std::lock_guard`、`defer`。简单来说，就是在对象的构造方法中初始化资源，在析构函数中销毁资源。而构造函数与析构函数的调用是由编译器自动插入的，减轻了开发者的心智负担

```cpp
template <class DeferFunction>
class DeferOp {
public:
    explicit DeferOp(DeferFunction func) : _func(std::move(func)) {}

    ~DeferOp() { _func(); };

private:
    DeferFunction _func;
};
```

# 9 Best Practice

## 9.1 Visitor

```cpp
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

#define APPLY_AST_TYPES(M) \
    M(Function)            \
    M(UnaryExpression)     \
    M(BinaryExpression)    \
    M(Literal)
// More types here

enum ASTType {
#define ENUM_TYPE(ITEM) ITEM,
    APPLY_AST_TYPES(ENUM_TYPE) UNDEFINED,
#undef ENUM_TYPE
};

inline std::string toString(ASTType type) {
    switch (type) {
#define CASE_TYPE(ITEM) \
    case ASTType::ITEM: \
        return #ITEM;
        APPLY_AST_TYPES(CASE_TYPE)
#undef CASE_TYPE
    default:
        __builtin_unreachable();
    }
}

struct ASTNode {
    ASTNode(std::vector<ASTNode*> children_) : children(children_) {}
    virtual ASTType getType() = 0;
    std::vector<ASTNode*> children;
};
struct ASTFunction : public ASTNode {
    ASTFunction(std::string name_, std::vector<ASTNode*> args_) : ASTNode(args_), name(std::move(name_)) {}
    ASTType getType() override { return ASTType::Function; }
    const std::string name;
};
struct ASTUnaryExpression : public ASTNode {
    ASTUnaryExpression(std::string op_, ASTNode* operand_) : ASTNode({operand_}), op(std::move(op_)) {}
    ASTType getType() override { return ASTType::UnaryExpression; }
    const std::string op;
};
struct ASTBinaryExpression : public ASTNode {
    ASTBinaryExpression(std::string op_, ASTNode* lhs_, ASTNode* rhs_) : ASTNode({lhs_, rhs_}), _op(std::move(op_)) {}
    ASTType getType() override { return ASTType::BinaryExpression; }
    const std::string _op;
};
struct ASTLiteral : public ASTNode {
    ASTLiteral(std::string value_) : ASTNode({}), value(std::move(value_)) {}
    ASTType getType() override { return ASTType::Literal; }
    const std::string value;
};

template <typename R, typename C>
class ASTVisitor {
public:
    virtual R visit(ASTNode* node, C& ctx) { throw std::runtime_error("unimplemented"); }

#define VISITOR_DEF(TYPE) \
    virtual R visit##TYPE(ASTNode* node, C& context) { return visit(node, context); }
    APPLY_AST_TYPES(VISITOR_DEF)
#undef VISITOR_DEF
};

class ASTVisitorUtil {
public:
    template <typename R, typename C>
    static R visit(ASTNode* node, ASTVisitor<R, C>& visitor, C& ctx) {
        switch (node->getType()) {
#define CASE_TYPE(ITEM) \
    case ASTType::ITEM: \
        return visitor.visit##ITEM(node, ctx);
            APPLY_AST_TYPES(CASE_TYPE)
#undef CASE_TYPE
        default:
            __builtin_unreachable();
        }
    }
};

struct EmptyContext {};

class PrintVisitor : public ASTVisitor<void, EmptyContext> {
    void visit(ASTNode* node, EmptyContext& context) override {
        std::cout << "Visiting node: " << toString(node->getType()) << std::endl;
        for (auto* child : node->children) {
            ASTVisitorUtil::visit(child, *this, context);
        }
    }
};

class RebuildVisitor : public ASTVisitor<void, std::string> {
public:
    void visit(ASTNode* node, std::string& context) override { throw std::runtime_error("unimplemented"); }

    void visitUnaryExpression(ASTNode* node, std::string& context) override {
        auto* unary = dynamic_cast<ASTUnaryExpression*>(node);
        context.append(unary->op);
        ASTVisitorUtil::visit(unary->children[0], *this, context);
    }

    void visitBinaryExpression(ASTNode* node, std::string& context) override {
        auto* binary = dynamic_cast<ASTBinaryExpression*>(node);
        ASTVisitorUtil::visit(binary->children[0], *this, context);
        context.append(" " + binary->_op + " ");
        ASTVisitorUtil::visit(binary->children[1], *this, context);
    }

    void visitFunction(ASTNode* node, std::string& context) override {
        auto* function = dynamic_cast<ASTFunction*>(node);
        context.append(function->name);
        context.append("(");
        size_t i = 0;
        for (auto* child : node->children) {
            ASTVisitorUtil::visit(child, *this, context);
            if (++i != node->children.size()) {
                context.append(", ");
            }
        }
        context.append(")");
    }

    void visitLiteral(ASTNode* node, std::string& context) override {
        auto* literal = dynamic_cast<ASTLiteral*>(node);
        context.append(literal->value);
    }
};

int main() {
    // Create an AST: max(1, 2) + min(3, 5) / -3
    ASTNode* ast = new ASTBinaryExpression(
            "+", new ASTFunction("max", {new ASTLiteral("1"), new ASTLiteral("2")}),
            new ASTBinaryExpression("/", new ASTFunction("min", {new ASTLiteral("3"), new ASTLiteral("5")}),
                                    new ASTUnaryExpression("-", new ASTLiteral("3"))));

    {
        EmptyContext context;
        PrintVisitor visitor;
        ASTVisitorUtil::visit(ast, visitor, context);
    }
    {
        std::string buffer;
        RebuildVisitor visitor;
        ASTVisitorUtil::visit(ast, visitor, buffer);
        std::cout << buffer << std::endl;
    }
    return 0;
}
```

# 10 Tips

## 10.1 Class Related

### 10.1.1 How to define static members in a class

**在类中声明静态成员，在类外定义（赋值）静态成员，示例如下：**

```cpp
#include <iostream>

class Demo {
public:
    static size_t BUFFER_LEN;
};

size_t Demo::BUFFER_LEN = 5;

int main() {
    std::cout << Demo::BUFFER_LEN << std::endl;
}
```

### 10.1.2 Non-static members of a class cannot undergo type deduction

类的非静态成员，无法进行类型推导，必须显式指定类型（因为类型信息必须是不可变的）；静态成员可以。例如下面示例就存在语法错误：

```cpp
#include <utility>

template <typename Func>
class Delegate {
public:
    Delegate(Func func) : _func(std::move(func)) { _func(); }

private:
    Func _func;
};

class Foo {
public:
    Foo() : _delegate(Foo::do_something) {}
    inline static void do_something() {}

private:
    inline static Delegate _s_delegate{Foo::do_something};
    // Use of class template 'Delegate' requires template arguments
    // Argument deduction not allowed in non-static class member (clang auto_not_allowed
    Delegate _delegate;
};
```

## 10.2 Initialization

### 10.2.1 Initializer List

1. 对于内置类型，直接进行值拷贝。使用初始化列表还是在构造函数体中进行初始化没有差别
1. 对于类类型
    * 在初始化列表中初始化：调用的是拷贝构造函数或者移动构造函数
    * 在构造函数体中初始化：虽然在初始化列表中没有显式指定，但是仍然会用默认的构造函数来进行初始化，然后在构造函数体中使用拷贝或者移动赋值运算符
1. 哪些东西必须放在初始化列表中
    * 常量成员
    * 引用类型
    * 没有默认构造函数的类类型，因为使用初始化列表可以不必调用默认构造函数来初始化，而是直接调用拷贝或者移动构造函数初始化

```c++
#include <iostream>

class A {
public:
    A() {
        std::cout << "A's default constructor" << std::endl;
    }

    A(int a) : _a(a), _b(0) {
        std::cout << "A's (int) constructor" << std::endl;
    }

    A(int a, int b) : _a(a), _b(b) {
        std::cout << "A's (int, int) constructor" << std::endl;
    }

    A(const A &a) : _a(a._a), _b(a._b) {
        std::cout << "A's copy constructor" << std::endl;
    }

    A(A &&a) : _a(a._a), _b(a._b) {
        std::cout << "A's move constructor" << std::endl;
    }

    A &operator=(const A &a) {
        std::cout << "A's copy assign operator" << std::endl;
        this->_a = a._a;
        this->_b = a._b;
        return *this;
    }

    A &operator=(A &&a) noexcept {
        if (this == &a) {
            return *this;
        }
        std::cout << "A's move assign operator" << std::endl;
        this->_a = a._a;
        this->_b = a._b;
        return *this;
    }

private:
    int _a;
    int _b;
};

class B {
public:
    B(A &a) : _a(a) {}

    B(A &a, std::nullptr_t) {
        this->_a = a;
    }

    B(A &&a) : _a(std::move(a)) {}

    B(A &&a, std::nullptr_t) {
        this->_a = std::move(a);
    }

private:
    A _a;
};

int main() {
    std::cout << "============(create a)============" << std::endl;
    A a(1, 2);
    std::cout << "\n============(create b1)============" << std::endl;
    B b1(a);
    std::cout << "\n============(create b2)============" << std::endl;
    B b2(a, nullptr);
    std::cout << "\n============(create b3)============" << std::endl;
    B b3(static_cast<A &&>(a));
    std::cout << "\n============(create b4)============" << std::endl;
    B b4(static_cast<A &&>(a), nullptr);
}
```

输出：

```
============(create a)============
A's (int, int) constructor

============(create b1)============
A's copy constructor

============(create b2)============
A's default constructor
A's copy assign operator

============(create b3)============
A's move constructor

============(create b4)============
A's default constructor
A's move assign operator
```

### 10.2.2 Various Initialization Types

1. 默认初始化：`type variableName;`
1. 直接初始化/构造初始化（至少有1个参数）：`type variableName(args);`
1. 列表初始化：`type variableName{args};`
    * 本质上列表初始化会调用相应的构造函数（匹配参数类型以及参数数量）来进行初始化
    * 它的好处之一是可以简化`return`语句，可以直接`return {args};`
1. 拷贝初始化：
    * `type variableName = otherVariableName`，本质上调用了拷贝构造函数
    * `type variableName = <type (args)>`，其中`<type (args)>`指的是返回类型为`type`的函数。看起来会调用拷贝构造函数，但是编译器会对这种形式的初始化进行优化，也就是只有函数内部调用了构造函数（如果有的话），而`=`并未调用任何构造函数
1. 值初始化：`type variableName()`
    * 对于内置类型，初始化为`0`或者`nullptr`
    * 对于类类型，等同于默认初始化。测试发现并未调用任何构造函数

```c++
#include <iostream>

class A {
public:
    A() {
        std::cout << "A's default constructor" << std::endl;
    }

    A(int a) : _a(a), _b(0) {
        std::cout << "A's (int) constructor" << std::endl;
    }

    A(int a, int b) : _a(a), _b(b) {
        std::cout << "A's (int, int) constructor" << std::endl;
    }

    A(const A &a) : _a(a._a), _b(a._b) {
        std::cout << "A's copy constructor" << std::endl;
    }

    A(A &&a) : _a(a._a), _b(a._b) {
        std::cout << "A's move constructor" << std::endl;
    }

    A &operator=(const A &a) {
        std::cout << "A's copy assign operator" << std::endl;
        this->_a = a._a;
        this->_b = a._b;
        return *this;
    }

    A &operator=(A &&a) noexcept {
        if (this == &a) {
            return *this;
        }
        std::cout << "A's move assign operator" << std::endl;
        this->_a = a._a;
        this->_b = a._b;
        return *this;
    }

private:
    int _a;
    int _b;
};

A createA(int argNum) {
    if (argNum == 0) {
        return {};
    } else if (argNum == 1) {
        return {1};
    } else {
        return {1, 2};
    }
}

int main() {
    std::cout << "============(默认初始化 a1)============" << std::endl;
    A a1;
    std::cout << "\n============(直接初始化 a2)============" << std::endl;
    A a2(1);
    std::cout << "\n============(直接初始化 a3)============" << std::endl;
    A a3(1, 2);
    std::cout << "\n============(列表初始化 a4)============" << std::endl;
    A a4 = {};
    std::cout << "\n============(列表初始化 a5)============" << std::endl;
    A a5 = {1};
    std::cout << "\n============(列表初始化 a6)============" << std::endl;
    A a6 = {1, 2};
    std::cout << "\n============(拷贝初始化 a7)============" << std::endl;
    A a7 = a6;
    std::cout << "\n============(拷贝初始化 a8)============" << std::endl;
    A a8 = createA(0);
    std::cout << "\n============(拷贝初始化 a9)============" << std::endl;
    A a9 = createA(1);
    std::cout << "\n============(拷贝初始化 a10)============" << std::endl;
    A a10 = createA(2);
    std::cout << "\n============(值初始化 a11)============" << std::endl;
    A a11();
}
```

输出：

```
============(默认初始化 a1)============
A's default constructor

============(直接初始化 a2)============
A's (int) constructor

============(直接初始化 a3)============
A's (int, int) constructor

============(列表初始化 a4)============
A's default constructor

============(列表初始化 a5)============
A's (int) constructor

============(列表初始化 a6)============
A's (int, int) constructor

============(拷贝初始化 a7)============
A's copy constructor

============(拷贝初始化 a8)============
A's default constructor

============(拷贝初始化 a9)============
A's (int) constructor

============(拷贝初始化 a10)============
A's (int, int) constructor

============(值初始化 a11)============
```

### 10.2.3 Initialization Order of class Members

1. 初始化列表
1. 成员定义处的列表初始化，当且仅当该成员未出现在初始化列表中时才会生效
1. 构造函数的函数体中的初始化行为

```cpp
#include <iostream>

int initialized_where_defined() {
    std::cout << "initialized_where_defined" << std::endl;
    return 0;
}

int initialized_at_initialization_list() {
    std::cout << "initialized_at_initialization_list" << std::endl;
    return 0;
}

int initialized_at_construct_block() {
    std::cout << "initialized_at_construct_block" << std::endl;
    return 0;
}

class Foo {
public:
    Foo() { _data = initialized_at_construct_block(); }
    Foo(int) : _data(initialized_at_initialization_list()) { _data = initialized_at_construct_block(); }

private:
    int _data = initialized_where_defined();
};

int main(int argc, const char* argv[]) {
    Foo f1;
    std::cout << "\n---------------------------------------\n" << std::endl;
    Foo f2(0);
    return 0;
}
```

输出：

```
initialized_where_defined
initialized_at_construct_block

---------------------------------------

initialized_at_initialization_list
initialized_at_construct_block
```

### 10.2.4 Initialization of static Local Variables

```cpp
void foo() {
    static Bar bar;
    // ...
}
```

初始化过程等效于如下程序，其中：

* `guard_for_bar`是一个用来保证线程安全和一次性初始化的整型变量，是编译器生成的，存储在`bss`段。它的最低的一个字节被用作相应静态变量是否已被初始化的标志，若为`0`表示还未被初始化，否则表示已被初始化
* `__cxa_guard_acquire`实际上是一个加锁的过程， 相应的`__cxa_guard_abort`和 `__cxa_guard_release`释放锁
* `__cxa_atexit`注册在调用`exit`时或动态链接库(或共享库) 被卸载时执行的函数，这里注册的是Bar的析构函数

```cpp
void foo() {
    if ((guard_for_bar & 0xff) == 0) {
        if (__cxa_guard_acquire(&guard_for_bar)) {
            try {
                Bar::Bar(&bar);
            } catch (...) {
                __cxa_guard_abort(&guard_for_bar);
                throw;
            }
            __cxa_guard_release(&guard_for_bar);
            __cxa_atexit(Bar::~Bar, &bar, &__dso_handle);
        }
    }
    // ...
}
```

### 10.2.5 Initialization of non-static class Members

非静态成员不允许使用构造初始化，但是允许使用列表初始化（本质上还是调用了对应的构造函数）

```cpp
#include <iostream>

class Foo {
public:
    Foo() { std::cout << "Foo()" << std::endl; }
    Foo(int val) : val(val) { std::cout << "Foo(int)" << std::endl; }

private:
    int val;
};

class Bar {
private:
    Foo foo{5};
};

int main() {
    Bar bar;
    return 0;
}
```

## 10.3 Pointer

### 10.3.1 Member Function Pointer

成员函数指针需要通过`.*`或者`->*`运算符进行调用

* 类内调用：`(this->*<name>)(args...)`
* 类外调用：`(obj.*obj.<name>)(args...)`或者`(pointer->*pointer-><name>)(args...)`

```cpp
#include <iostream>
#include <memory>

class Demo {
public:
    explicit Demo(bool flag) {
        if (flag) {
            say_hi = &Demo::say_hi_1;
        } else {
            say_hi = &Demo::say_hi_2;
        }
    }

    void invoke_say_hi() {
        (this->*say_hi)();
    }

    void (Demo::*say_hi)() = nullptr;

    void say_hi_1();

    void say_hi_2();
};

void Demo::say_hi_1() {
    std::cout << "say_hi_1" << std::endl;
}

void Demo::say_hi_2() {
    std::cout << "say_hi_2" << std::endl;
}

int main() {
    Demo demo1(true);

    // invoke inside class
    demo1.invoke_say_hi();

    // invoke outside class with obj
    (demo1.*demo1.say_hi)();

    // invoke outside class with pointer
    Demo *p1 = &demo1;
    (p1->*p1->say_hi)();

    // invoke outside class with pointer
    std::shared_ptr<Demo> sp1 = std::make_shared<Demo>(false);
    (sp1.get()->*sp1->say_hi)();
}
```

### 10.3.2 How to pass multi-dimensional pointer parameters

```cpp
#include <iostream>

// Using a pointer to a 2D array
void yourFunction1(bool (*rows)[9]) {
    // Access elements of the 2D array
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            std::cout << rows[i][j] << " ";
        }
        std::cout << std::endl;
    }
}

// Using a reference to a 2D array
void yourFunction2(bool (&rows)[9][9]) {
    // Access elements of the 2D array
    for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
            std::cout << rows[i][j] << " ";
        }
        std::cout << std::endl;
    }
}

int main() {
    bool rows[9][9] = {
            // Initialize the array as needed
    };

    // Pass the local variable to the functions
    yourFunction1(rows);
    yourFunction2(rows);

    return 0;
}
```

## 10.4 Reference

### 10.4.1 Reference Initialization

**引用只能在定义处初始化**

```cpp
int main() {
    int a = 1;
    int b = 2;

    int &ref = a;
    ref = b; // a的值变为2

    std::cout << "a=" << a << std::endl;
    std::cout << "b=" << b << std::endl;
    std::cout << "ref=" << ref << std::endl;
}
```

结果：

```
a=2
b=2
ref=2
```

## 10.5 Mock class

有时在测试的时候，我们需要mock一个类的实现，我们可以在测试的cpp文件中实现这个类的所有方法（**注意，必须是所有方法**），就能够覆盖原有库文件中的实现。下面以一个例子来说明

**目录结构如下**

```
.
├── lib
│   ├── libperson.a
│   ├── person.cpp
│   ├── person.h
│   └── person.o
└── main.cpp
```

**`lib/person.h`内容如下：**

```c++
#pragma once

#include <string>

class Person {
public:
    void work();

    void sleep();

    void eat();
};
```

**`lib/person.cpp`内容如下：**

```c++
#include "person.h"
#include <iostream>

void Person::work() {
    std::cout << "work" << std::endl;
}

void Person::sleep() {
    std::cout << "sleep" << std::endl;
}

void Person::eat() {
    std::cout << "eat" << std::endl;
}
```

**编译`person.cpp`生成链接文件，并生成`.a`归档文件**

```sh
# 指定-c参数，只生成目标文件（person.o），不进行链接
g++ person.cpp -c -std=gnu++11

# 生成归档文件
ar crv libperson.a person.o
```

**`main.cpp`内容如下：**

```c++
#include <iostream>
#include "lib/person.h"

int main() {
    Person person;
    person.work();
    person.sleep();
    person.eat();
};
```

**编译`main.cpp`并执行**

```sh
# 编译
# -L参数将lib目录加入到库文件的扫描路径
# -l参数指定需要链接的库文件
g++ -o main main.cpp -std=gnu++11 -L lib -lperson

# 执行，输出如下
./main

work
sleep
eat
```

**接下来，我们修改`main.cpp`，覆盖原有的`work`、`sleep`、`eat`方法**

```c++
#include <iostream>
#include "lib/person.h"

void Person::work() {
    std::cout << "mock work" << std::endl;
}

void Person::sleep() {
    std::cout << "mock sleep" << std::endl;
}

void Person::eat() {
    std::cout << "mock eat" << std::endl;
}

int main() {
    Person person;
    person.work();
    person.sleep();
    person.eat();
};
```

**编译`main.cpp`并执行**

```sh
# 编译
# -L参数将lib目录加入到库文件的扫描路径
# -l参数指定需要链接的库文件
g++ -o main main.cpp -std=gnu++11 -L lib -lperson

# 执行，输出如下，可以发现，都变成了mock版本
./main

mock work
mock sleep
mock eat
```

**然后，我们继续修改`main.cpp`，删去其中一个方法**

```c++
#include <iostream>
#include "lib/person.h"

void Person::work() {
    std::cout << "mock work" << std::endl;
}

void Person::sleep() {
    std::cout << "mock sleep" << std::endl;
}

// void Person::eat() {
//     std::cout << "mock eat" << std::endl;
// }

int main() {
    Person person;
    person.work();
    person.sleep();
    person.eat();
};
```

**编译`main.cpp`（编译会失败）**

```sh
# 编译
# -L参数将lib目录加入到库文件的扫描路径
# -l参数指定需要链接的库文件
g++ -o main main.cpp -std=gnu++11 -L lib -lperson

lib/libperson.a(person.o)：在函数‘Person::work()’中：
person.cpp:(.text+0x0): Person::work() 的多重定义
/tmp/ccfhnlz4.o:main.cpp:(.text+0x0)：第一次在此定义
lib/libperson.a(person.o)：在函数‘Person::sleep()’中：
person.cpp:(.text+0x2a): Person::sleep() 的多重定义
/tmp/ccfhnlz4.o:main.cpp:(.text+0x2a)：第一次在此定义
collect2: 错误：ld 返回 1
```

## 10.6 Variable-length Array

Variable-length array (VLA), which is a feature not supported by standard C++. However, some compilers, particularly in C and as extensions in C++, do provide support for VLAs.

```cpp
void func(size_t size) {
    int array[size];
}
```

```cpp
#include <iostream>
#include <iterator>
#include <limits>
#include <random>
#include <vector>

int main(int32_t argc, char* argv[]) {
    int32_t num1;
    int32_t num2;
    int32_t array1[1];
    int32_t num3;
    int32_t array2[std::atoi(argv[1])];
    int32_t num4;

    auto offset = [&num1](void* p) { return reinterpret_cast<int8_t*>(p) - reinterpret_cast<int8_t*>(&num1); };

    std::cout << "num1: " << offset(&num1) << std::endl;
    std::cout << "num2: " << offset(&num2) << std::endl;
    std::cout << "array1: " << offset(&array1) << std::endl;
    std::cout << "num3: " << offset(&num3) << std::endl;
    std::cout << "array2: " << offset(&array2) << std::endl;
    std::cout << "num4: " << offset(&num4) << std::endl;

    return 0;
}
```

```
./main 1
num1: 0
num2: -4
array1: -8
num3: -12
array2: -148
num4: -32

./main 100
num1: 0
num2: -4
array1: -8
num3: -12
array2: -532
num4: -32
```

# 11 FAQ

## 11.1 Why is it unnecessary to specify the size when releasing memory with free and delete

[How does free know how much to free?](https://stackoverflow.com/questions/1518711/how-does-free-know-how-much-to-free)

分配内存时，除了分配指定的内存之外，还会分配一个`header`，用于存储一些信息，例如

* **`size`**
* `special marker`
* `checksum`
* `pointers to next/previous block`

```
____ The allocated block ____
/                             \
+--------+--------------------+
| Header | Your data area ... |
+--------+--------------------+
          ^
          |
          +-- The address you are given
```

## 11.2 Do parameter types require lvalue or rvalue references

## 11.3 Does the return type require lvalue or rvalue references

# 12 Reference

* [C++11\14\17\20 特性介绍](https://www.jianshu.com/p/8c4952e9edec)
* [关于C++：静态常量字符串(类成员)](https://www.codenong.com/1563897/)
* [do {…} while (0) in macros](https://hownot2code.com/2016/12/05/do-while-0-in-macros/)
* [PRE10-C. Wrap multistatement macros in a do-while loop](https://wiki.sei.cmu.edu/confluence/display/c/PRE10-C.+Wrap+multistatement+macros+in+a+do-while+loop)
* [C++ const 关键字小结](https://www.runoob.com/w3cnote/cpp-const-keyword.html)
* [C++ 强制转换运算符](https://www.runoob.com/cplusplus/cpp-casting-operators.html)
* [When should static_cast, dynamic_cast, const_cast and reinterpret_cast be used?](https://stackoverflow.com/questions/332030/when-should-static-cast-dynamic-cast-const-cast-and-reinterpret-cast-be-used)
* [Candidate template ignored because template argument could not be inferred](https://stackoverflow.com/questions/12566228/candidate-template-ignored-because-template-argument-could-not-be-inferred)
* [calling a member function pointer from outside the class - is it possible?](https://stackoverflow.com/questions/60438079/calling-a-member-function-pointer-from-outside-the-class-is-it-possible)
* [带你深入理解内存对齐最底层原理](https://zhuanlan.zhihu.com/p/83449008)
* [C++那些事](https://light-city.club/sc/)
* [ARM GCC Inline Assembler Cookbook](http://www.ethernut.de/en/documents/arm-inline-asm.html)
* [GCC's assembler syntax](https://www.felixcloutier.com/documents/gcc-asm.html#constraints)
