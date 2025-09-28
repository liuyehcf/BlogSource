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

The preprocessor supports conditional compilation of certain parts of the source file.
This behavior is controlled by the `#if`, `#else`, `#elif`, `#ifdef`, `#ifndef`, and `#endif` directives.

## 2.2 `#define`

**In the `ANSI C` standard, there are several predefined macros (also commonly used):**

* `__LINE__`: Inserts the current source code line number in the source code
* `__FILE__`: Inserts the current source file name in the source file
* `__FUNCTION__`: Function name
* `__PRETTY_FUNCTION__`: Function signature
* `__DATE__`: Inserts the current compilation date in the source file
* `__TIME__`: Inserts the current compilation time in the source file
* `__STDC__`: This identifier is assigned the value 1 when the program is required to strictly follow the `ANSI C` standard
* `__cplusplus`: This identifier is defined when writing `C++` programs

**Syntax:**

* `#`: Stringizing operator
* `##`: Concatenation operator
* `\`: Line continuation operator

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

Consider the following macro definition:

```c++
#define foo(x) bar(x); baz(x)
```

Then we call:

```c++
foo(wolf);
```

It will be expanded into:

```c++
bar(wolf); baz(wolf);
```

It seems fine, let's now consider another situation:

```c++
if (condition)
    foo(wolf);
```

It will be expanded into:

```c++
if (condition)
    bar(wolf);
baz(wolf);
```

This does not meet our expectations. To avoid such issues, we need to wrap the macro in a scope to prevent statement scope shifting. Thus, we further represent the macro in the following form

```c++
#define foo(x) { bar(x); baz(x); }
```

Then we call:

```c++
if (condition)
    foo(wolf);
else
    bin(wolf);
```

It will be expanded into:

```c++
if (condition) {
    bar(wolf);
    baz(wolf);
}; // syntax error
else
    bin(wolf);
```

Finally, we optimize the macro into the following form

```c++
#define foo(x) do { bar(x); baz(x); } while (0)
```

#### 2.2.2.2 Variant

With the help of nested macros and agreed naming conventions, we can automatically generate `else if` branches. The sample code is as follows:

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

The above functionality can be fully implemented using `std::variant`, as follows:

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

For example, we define a macro with one parameter `MY_MACRO`:

* `MY_MACRO(func<flag1, flag2>())`: This call will result in an error because the comma is interpreted as separating two macro parameters
* `MY_MACRO((func<flag1, flag2>()))`: This call works correctly because enclosing the expression in `()` makes it be treated as a single macro parameter

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

Macros also support variable arguments, which can be referenced using `__VA_ARGS__`.

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

In `C++`, `#pragma` is a preprocessor directive that is used to send specific commands or hints to the compiler, thereby controlling the compiler's behavior. `#pragma` is often used to enable or disable certain compiler features, set compiler options, or specify link libraries.

The `#pragma` directive is not a standard feature of `C++`, but rather an extension provided by the compiler. Different compilers may support different `#pragma` directives, and their behavior may also vary. Therefore, when writing portable `C++` code, it is best to avoid using them.

Different compilers may support different `#pragma` directives. Below are some commonly used `#pragma` directives and their purposes:

* `#pragma once`: This directive prevents a header file from being included multiple times, solving the problem of duplicate header inclusion. It tells the compiler to include the header file only once.
* `#pragma pack`: This family of pragmas controls the maximum alignment of structures, unions, and classes defined thereafter.
    * `#pragma pack(<arg>)`: Sets the current alignment to `<arg>`.
    * `#pragma pack()`: Resets the current alignment to the default (as specified by command-line options).
    * `#pragma pack(push)`: Pushes the current alignment value onto an internal stack.
    * `#pragma pack(push, <arg>)`: Pushes the current alignment value onto an internal stack, then sets the current alignment to `<arg>`.
    * `#pragma pack(pop)`: Pops the top entry from the internal stack and restores the current alignment to that value.
    * Here, the `<arg>` argument must be a small power of `2`, specifying the new alignment in bytes.
* `#pragma message`: This directive is used to output a message during compilation.
    ```cpp
    #pragma message("Compiling " __FILE__)

    int main() {
        return 0;
    }
    ```

* `#pragma GCC diagnostic`: This directive is used to control the compiler's warnings and error messages. It can be used to specify whether certain warnings or error messages should be ignored or displayed.
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

* `#pragma omp`: This directive is used in `OpenMP` parallel programming to specify the manner of parallel execution.

## 2.5 `#error`

Displays the given error message and terminates the compilation process.

## 2.6 Reference

* [C/C++ 宏编程的艺术](https://bot-man-jl.github.io/articles/?post=2020/Macro-Programming-Art)

# 3 Key Word

## 3.1 Type Qualifier

### 3.1.1 const

By default, a `const` object is only valid within a single file. During compilation, the compiler replaces every occurrence of the variable with its corresponding value. In other words, the compiler locates all usages of the `const` variable in the code and substitutes them with the defined value.

To perform this substitution, the compiler must know the initial value of the variable. If a program consists of multiple files, each file that uses the `const` object must have access to its initial value. To achieve this, the variable must be defined in every file that uses it (by placing the definition of the `const` variable in a header file and including that header file in the source files). To support this usage while avoiding duplicate definitions of the same variable, `const` is by default restricted to file scope (a global `const` variable is essentially defined separately in each file).

Sometimes, however, the initial value of a `const` variable is not a constant expression, yet it still needs to be shared across files. In such cases, we do not want the compiler to generate independent variables for each file. Instead, we want such `const` objects to behave like other objects.
**That is: define the `const` in one file, declare and use it in multiple files, and add the `extern` keyword both in the declaration and the definition.**

* In the `.h` file: `extern const int a;`
* In the `.cpp` file: `extern const int a = f();`

#### 3.1.1.1 Top/Bottom Level const

**Only pointers and references have the distinction between top-level and low-level `const`**

* Top-level `const` means the object itself is immutable.
* Low-level `const` means the object being pointed to is immutable.
* For references, `const` can only be low-level, because a reference itself is not an object and thus cannot have a top-level `const`.
* For pointers, `const` can be either top-level or low-level.
    * Note: only when `const` is adjacent to the variable name (with no `*` in between) is it considered top-level `const`. For example, in the cases below, both `p1` and `p2` are top-level `const`
* A pointer with low-level `const` can be rebound, as in the examples with `p1` and `p2`.
* A reference with low-level `const` cannot be rebound, but this is due to the fact that references themselves do not support rebinding, rather than being a restriction of `const`.

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

**`const` follows the rules below:**

* Top-level `const` can access both `const` and non-`const` members.
* Low-level `const` can only access `const` members.

For example, we can observe:

* `const Container* container` and `const Container& container` can only access `const` members and cannot access non-`const` members.
* `Container* const container` can access both `const` and non-`const` members.
* Specifically, `const ContainerPtr& container` can access non-`const` members. This is because `container->push_back(num)` involves a two-level call:
    * First level: It calls `std::shared_ptr::operator->`, which is itself `const`, and its return type is `element_type*`.
    * Second level: Through the returned `element_type*`, it accesses `std::vector::push_back`. Therefore, this does not contradict the above conclusion.

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

When an argument initializes a parameter, the top-level `const` attribute is automatically ignored.

Top-level `const` does not affect the type of a parameter. For example, in the following code, compilation will fail with an error indicating function redefinition.

```cpp
void func(int value) {}

void func(const int value) {}

int main() {
    int value = 5;
    func(value);
}
```

#### 3.1.1.3 const Member

Explicit initialization in a constructor: initialization must be done in the initializer list, not inside the function body.
If no explicit initialization is provided, the member will be initialized using its default value defined at the point of declaration.

#### 3.1.1.4 const Member Function

**A member function modified with the `const` keyword cannot modify the value of any field in the current class. If a field is an object type, it also cannot call member methods that are not marked `const`. (One exception: if the class holds a pointer to a type, it can use that pointer to call non-`const` methods.)**

* Constant objects, as well as references or pointers to constant objects, can only call constant member functions.
* Constant objects, as well as references or pointers to constant objects, can call both constant and non-constant member functions.

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

The `volatile` keyword is a type qualifier. A variable declared with it indicates that its value may be changed by factors unknown to the compiler (outside the program), such as the operating system, hardware, etc. When encountering a variable declared as `volatile`, the compiler will not optimize the code accessing that variable, ensuring stable access to special addresses.

* **From the perspective of the `C/C++` standard alone (without considering platform or compiler extensions), `volatile` does not guarantee visibility between threads.** In real-world scenarios, for example on the `x86` platform, with the support of the `MESI` protocol, `volatile` can ensure visibility. However, this is merely incidental and relies on platform specifics, thus lacking portability across platforms.

`Java` also has the `volatile` keyword, but its role is entirely different: in `Java`, `volatile` ensures thread visibility at the language level.

* `x86`
    * Relying only on the `MESI` protocol may still fail to achieve visibility. For example, when `CPU1` performs a write, it must wait until other CPUs set the corresponding cache line to the `I` state before the write can complete. This is inefficient, so CPUs introduced the `Store Buffer` (which the `MESI` protocol does not account for). `CPU1` can write to the `Store Buffer` and proceed without waiting for other CPUs to invalidate the cache line.
    * To solve this issue, the `JVM` uses assembly instructions with the `lock` prefix, which flushes all data in the `Store Buffer` (not just variables declared as `volatile`) into memory through the `MESI` protocol.
* Other architectures use different mechanisms to fulfill the promise of thread visibility.

**Reference:**

* [Is volatile useful with threads?](https://isocpp.org/blog/2018/06/is-volatile-useful-with-threads-isvolatileusefulwiththreads.com)
    * [isvolatileusefulwiththreads](http://isvolatileusefulwiththreads.com/)
* [Volatile and cache behaviour](https://stackoverflow.com/questions/18695120/volatile-and-cache-behaviour)
* [你不认识的cc++ volatile](https://www.hitzhangjie.pro/blog/2019-01-07-%E4%BD%A0%E4%B8%8D%E8%AE%A4%E8%AF%86%E7%9A%84cc++-volatile/)

**Example:**

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

**The output is as follows:**

* The three operations of `read_from_normal` are optimized into one.
* The three operations of `write_to_normal` are optimized into one.
* In `write_to_atomic`, `std::memory_order_seq_cst` uses [xchg](https://www.felixcloutier.com/x86/xchg), when one of the operands is a memory address, the `locking protocol` is automatically enabled to ensure serialization of write operations.

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

First, let's clarify the concept of `visibility`. Here, I define it as follows: when there are two threads `A` and `B`, if `A` performs a write operation on variable `x` and `B` performs a read operation on variable `x`, then if the write operation happens before the read operation, the read should be able to see the value written by the write operation.

This problem is difficult to verify directly, so we intend to use an indirect method to test it:

* Assume the performance overhead ratio of read to write operations is `α`.
* Start two threads: one continuously performing read operations, the other continuously performing write operations. The read thread executes `n` reads (with write operations ongoing in parallel). Count the number of times `m` that two consecutive read operations return different values. Define `β = m / n`.
    * If `α > 1`, i.e., reads are more efficient than writes. If visibility is ensured, then `β` should roughly approach `1/α`.
    * If `α <= 1`, i.e., reads are less efficient than writes. If visibility is ensured, then `β` should roughly approach 1 (since the written value is very likely to be observed).

First, test the read/write performance of `atomic` and `volatile`.

* During testing, an additional thread will continuously read and write to the `atomic` or `volatile` variable

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

Output:

* `atomic<uint64_t>, std::memory_order_seq_cst`
    * `α = 28.9/1.24 = 23.30 > 1`
    * `β` expected to be `1/α = 0.043`
* `atomic<uint64_t>, std::memory_order_relaxed`
    * `α = 0.391/1.38 = 0.28 < 1`
    * `β` expected to be `1`
* `volatile`
    * `α = 0.331/1.33 = 0.25 < 1`
    * `β` expected to be `1`

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

In the same environment, the test program is as follows:

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

The results are as follows (`volatile` and `std::memory_order_relaxed` behavior is platform-dependent; the test environment is x86, so the experimental results are not portable across platforms):

* `std::memory_order_seq_cst` behaves as expected.
* `std::memory_order_relaxed` and `volatile` do not behave as expected — neither provides `visibility`.
* My hypothesis for this phenomenon is as follows:
    * x86 employs a hardware optimization: the `Store Buffer` is used to accelerate write operations.
    * Writes with `std::memory_order_seq_cst` immediately flush the `Store Buffer` into memory.
    * Writes with `std::memory_order_relaxed` and `volatile` go into the `Store Buffer` and are only flushed to memory when the buffer fills.
    * The time required to fill the `Store Buffer` is very short. Thus, the above code is effectively equivalent to:
        * `std::memory_order_seq_cst`: each write flushes once to memory.
        * `std::memory_order_relaxed` / `volatile`: a batch of writes flushes once to memory.
    * The frequency of memory flushes ends up being similar, so in all three cases, the observed `β` values are close.

```
atomic<uint64_t>, std::memory_order_seq_cst, β=0.0283726
atomic<uint64_t>, std::memory_order_relaxed, β=0.0276697
volatile, β=0.0271394
```

**If the above equivalent verification is performed using Java, the actual results align with the expectations, so it will not be elaborated here.**

#### 3.1.2.2 Atomicity Verification

`std::atomic` can provide a `happens-before` relationship for other non-atomic variables

* `normal-write happens-before atomic-write`.
* `atomic-write happens-before atomic-read`.
* `atomic-read happens-before normal-read`.
* We deduce that `normal-write` happens-before `normal-read`.

In addition, since the test machine is x86 and x86 uses the `TSO` model, `std::memory_order_relaxed` likewise satisfies the `atomic-write happens-before atomic-read` rule. However, the generated instructions are closer to those of `volatile`. Therefore, we use `std::memory_order_relaxed` here to make it easier to compare the differences between the two sets of instructions.

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

When compiling with the `-O3` optimization level and examining the assembly instructions, we can observe:

* In `volatile_writer`, the assignment to `data` is hoisted outside the loop, while `volatile_data_ready` is assigned once per iteration (this optimization breaks the program's intended semantics).
* In `atomic_writer`, due to the presence of a memory barrier (the write to `std::atomic`), the assignment to `data` is not hoisted outside the loop. Both `data` and `atomic_data_ready` are assigned on each iteration (which matches the program's intent).

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

If the program is compiled with the `-O0` optimization level, the assertions in the above code will not fail.

### 3.1.3 mutable

Allow constant class-type objects to modify the corresponding class members.

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

[C++ keyword: inline](https://en.cppreference.com/w/cpp/keyword/inline)

* When used in the declaration specifier sequence for functions, it declares the function as an inline function
    * A complete definition within a `class/struct/union` that is attached to the global module (since C++20) is implicitly an inline function, whether it is a member function or a non-member `friend` function
    * The original intent of the `inline` keyword was to serve as a hint to the optimizer to prefer inlining the function rather than invoking it through a function call—that is, instead of executing a CPU instruction that transfers control to the function body, the function body is copied in place without creating a call. This avoids function call overhead (passing arguments and returning results), but may lead to a larger executable since the function body must be duplicated multiple times
    * Because the `inline` keyword is non-mandatory, the compiler has the freedom to inline any function not marked as `inline`, and to generate a function call for any function marked as `inline`. These optimization decisions do not affect the rules regarding multiple definitions and shared static variables mentioned above
    * Functions declared with `constexpr` are implicitly inline functions
* When used in the declaration specifier sequence for variables with static storage duration (static class members or namespace-scope variables), it declares the variable as an inline variable
    * Static member variables declared as `constexpr` (but not namespace-scope variables) are implicitly inline variables

## 3.3 Type Length

### 3.3.1 Memory Alignment

**The most fundamental reason for memory alignment is that memory I/O is performed in units of `8` bytes, or `64 bits`.**

Suppose you request to access memory from `0x0001-0x0008`, which is also 8 bytes but does not start at address 0. How does memory handle this? There's no easy solution. The memory must first fetch `0x0000-0x0007`, then fetch `0x0008-0x0015`, and return the results of both operations to you. Due to hardware limitations of the CPU and memory I/O, it's not possible to perform an I/O operation that spans across two data width boundaries. As a result, your application slows down — a small penalty imposed by the computer because you didn't understand memory alignment.

**Memory Alignment Rules**

1. **The offset of the first member of a structure is `0`. For all subsequent members, the offset relative to the start address of the structure must be an integer multiple of the smaller of the member's size and the `effective alignment value`. If necessary, the compiler will insert padding bytes between members.**
2. **The total size of the structure must be an integer multiple of the `effective alignment value`. If necessary, the compiler will add padding bytes after the last member.**
* **Effective alignment value: the smaller of the value specified by `#pragma pack(n)` and the size of the largest data type in the structure. This value is also called the alignment unit. In GCC, the default is `#pragma pack(4)`, and this value can be changed using the preprocessor directive `#pragma pack(n)`, where n can be `1`, `2`, `4`, `8`, or `16`.**

**Let's illustrate this with an example**

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

**Execution results are as follows:**

* Since the offset of each member must be an integer multiple of the smaller of that member's size and the `effective alignment value`, we'll refer to this smaller value as the `member effective alignment value` below.
* `Align1`: The longest data type has a length of `1`, and pack = `4`, so the `effective alignment value` is `min(1, 4) = 1`
    * Rule 1:
        * `f1`, the first member, has `offset = 0`
    * Rule 2:
        * The total type length is `1`, which is a multiple of the `effective alignment value (1)`
* `Align2`: The longest data type has a length of `2`, and pack = `4`, so the `effective alignment value` is `min(2, 4) = 2`
    * Rule 1:
        * `f1`, the first member, has `offset = 0`
        * `f2` has a type length of `2`, so its `member effective alignment value` is `min(2, 2) = 2`. `offset = 2` is a multiple of the `member effective alignment value (2)`
    * Rule 2:
        * The total type length is `4`, which is a multiple of the `effective alignment value (2)`
* `Align3`: The longest data type has a length of `4`, and pack = `4`, so the `effective alignment value` is `min(4, 4) = 4`
    * Rule 1:
        * `f1`, the first member, has `offset = 0`
        * `f2` has a type length of `2`, so its `member effective alignment value` is `min(2, 4) = 2`. `offset = 2` is a multiple of the `member effective alignment value (2)`
        * `f3` has a type length of `4`, so its `member effective alignment value` is `min(4, 4) = 4`. `offset = 4` is a multiple of the `member effective alignment value (4)`
    * Rule 2:
        * The total type length is `8`, which is a multiple of the `effective alignment value (4)`
* `Align4`: The longest data type has a length of `8`, and pack = `4`, so the `effective alignment value` is `min(8, 4) = 4`
    * Rule 1:
        * `f1`, the first member, has `offset = 0`
        * `f2` has a type length of `2`, so its `member effective alignment value` is `min(2, 4) = 2`. `offset = 2` is a multiple of the `member effective alignment value (2)`
        * `f3` has a type length of `4`, so its `member effective alignment value` is `min(4, 4) = 4`. `offset = 4` is a multiple of the `member effective alignment value (4)`
        * `f4` has a type length of `8`, so its `member effective alignment value` is `min(8, 4) = 4`. `offset = 8` is a multiple of the `member effective alignment value (4)`
    * Rule 2:
        * The total type length is `16`, which is a multiple of the `effective alignment value (4)`

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

`sizeof` is used to query size of the object or type.

* `sizeof(int32_t)`：4
* `sizeof(char[2][2][2])`：8

### 3.3.3 alignof

**`alignof` is used to obtain the effective alignment value of an object. `alignas` is used to set the effective alignment value (it cannot be less than the default effective alignment value).**

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

Output:

```
sizeof(Foo1)=8, alignof(Foo1)=4
sizeof(Foo4)=8, alignof(Foo4)=4
sizeof(Foo5)=8, alignof(Foo5)=8
sizeof(Foo6)=16, alignof(Foo6)=16
```

### 3.3.4 alignas

The `alignas` type specifier is a portable C++ standard method used to specify the alignment of variables and user-defined types. It can be used when defining a `class`, `struct`, `union`, or when declaring a variable. If multiple `alignas` specifiers are encountered, the compiler will choose the strictest one (i.e., the largest alignment value).

Memory alignment allows the processor to better utilize the cache, including reducing `cache line` accesses and avoiding `cache miss` penalties caused by multi-core consistency issues. Specifically, in multithreaded programs, a common optimization technique is to align frequently accessed concurrent data according to the `cache line` size (usually `64` bytes). On one hand, for data smaller than `64` bytes, this ensures that only one `cache line` is touched, reducing memory access. On the other hand, it effectively dedicates an entire `cache line` to that data, preventing other data from sharing the same `cache line` and causing `cache miss` in other cores due to potential modifications.

**Arrays: When `alignas` is applied to an array, it aligns the starting address of the array, not each individual array element. That means the following array does not allocate `64` bytes for each `int`. To align each element, you can define a `struct`, such as `int_align_64`.**

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

**`auto` ignores top-level `const` but retains low-level `const`. However, when setting a reference of type `auto`, the top-level `const` property from the initializer is still preserved.**

### 3.4.2 decltype

* **`decltype` preserves all type information of a variable (including top-level `const` and references).**
* If the expression involves a dereference operation, the result will be a reference type.
    * `int i = 42;`
    * `int *p = &i;`
    * `decltype(*p)` results in `int&`
* **`decltype((c))` yields the reference type of `c` (regardless of whether `c` itself is a reference).**

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

**Output:**

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

In addition, `decltype` is evaluated at compile time, meaning it does not generate any runtime code.
For example, after compiling and running the following code, you will find that `say_hello` is never executed.

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

**Non-`C++` Standard**

### 3.4.4 typeid

**The `typeid` operator allows determining the type of an object at runtime. To distinguish between a parent class and a child class, the parent class must contain a virtual function.**

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

Output:

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

**In addition, `dynamic_cast` can be used to determine whether a pointer points to a subclass or a parent class.**

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

Output:

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

**Usage: `static_cast<type> (expr)`**

The `static_cast` operator performs non-dynamic conversions, without runtime class checks to ensure conversion safety. For example, it can be used to convert a base class pointer to a derived class pointer. Any type conversion with a clear meaning, as long as it does not involve low-level `const`, can be done using `static_cast`.

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

**Note: If the target type is neither a reference type nor a pointer type, the copy constructor of that type will be called.**

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

**Usage: `dynamic_cast<type> (expr)`**

`dynamic_cast` is typically used for conversions within an inheritance hierarchy. It performs the conversion at runtime and verifies its validity. The `type` must be a class pointer, a class reference, or `void*`.
If a pointer conversion fails, the result is `nullptr`; if a reference conversion fails, a `std::bad_cast` exception is thrown.

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

**Usage: `const_cast<type> (expr)`**

This type of cast is mainly used to manipulate the `const` property of the given object. It can either add or remove the `const` qualifier (both top-level and low-level).
Here, `type` can only be one of the following categories (it must be either a reference or a pointer type).

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

**Usage: `reinterpret_cast<type> (expr)`**

`reinterpret_cast` is the most dangerous type of cast. It can directly convert a pointer of one type to a pointer of another type, and should be used with great caution. In most cases, the only guarantee when using `reinterpret_cast` is that if you convert the result back to the original type, you will usually get the exact same value (but not if the intermediate type is smaller than the original type).

There are also many conversions that `reinterpret_cast` cannot perform. It is mainly used for unusual conversions and bit manipulations, such as converting a raw data stream into actual data, or storing data in the low bits of a pointer that points to aligned data.

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

## 3.6 Storage duration and linkage

### 3.6.1 Storage Class Specifiers

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

#### 3.6.1.1 static

[C++ keyword: static](https://zh.cppreference.com/w/cpp/keyword/static)

* Declarations of namespace members with static storage duration and internal linkage.
    * A global static variable/function that is not visible to other translation units.
    * **internal linkage**
* Definitions of block scope variables with static storage duration and initialized once.
    * A static variable inside a function has the same storage as a global variable, but it still does not export a symbol.
    * **no linkage**
* Declarations of class members not bound to specific instances
    * Static member of a class
    * **external linkage**

#### 3.6.1.2 extern

[C++ keyword: extern](https://zh.cppreference.com/w/cpp/keyword/extern)

* Static storage duration specifier with external linkage
    * This symbol is defined in another compilation unit, which means it needs to be placed in the unresolved symbol table (external linkage)
* Language linkage specification, to avoid name mangling
    * `extern "C" {}`
* Explicit template instantiation declaration
    * For class templates
    * For function templates

##### 3.6.1.2.1 Shared Global Variable

**Each source file must have a declaration of the variable, but only one source file can contain the definition of the variable. A common approach is as follows:**

* Define a header file `xxx.h` that declares the variable (using the `extern` keyword)
* All source files include the header file `xxx.h`
* Define the variable in one specific source file

**Example:**

```sh
cat > extern.h << 'EOF'
#pragma once

extern int extern_value;
EOF

cat > extern.cpp << 'EOF'
#include "extern.h"

int extern_value = 5;
EOF

cat > main.cpp << 'EOF'
#include <iostream>

#include "extern.h"

int main() {
    std::cout << extern_value << std::endl;
}
EOF

gcc -o main main.cpp extern.cpp -lstdc++ -Wall

./main
```

#### 3.6.1.3 thread_local

[C++ keyword: thread_local](https://en.cppreference.com/w/cpp/keyword/thread_local.html)

* Thread local storage duration specifier

Implementation principle (speculated): Variables modified with `thread_local` are stored at the beginning of each thread's stack space (high address, since the stack allocates memory from top to bottom). The following program will be used to verify this hypothesis:

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

In my environment, the output is as follows:

```
main_thread_local: 0x7f190e1a573c
main_local: 0x7fff425e1dd4
t1_thread_local: 0x7f190e1a463c
t1_local: 0x7f190e1a3ddc
t2_thread_local: 0x7f190d9a363c
t2_local: 0x7f190d9a2ddc
addr distance between t1 and t2 is: 8392704
```

It can be observed that in different threads, the memory address of `value` is different and located at a high address. For two adjacent threads, the difference in the address of `value` is approximately equal to the size of the stack space (`ulimit -s`).

##### 3.6.1.3.1 Initialization

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

Output is as follows:

* The constructor is called twice because both threads go through the declaration of the `foo` variable, so each will allocate storage space and perform initialization.

```
default ctor
main: foo'address=0x7f5fd6b0c77c, value=1
default ctor
t1: foo'address=0x7f5fd5a3c6fc, value=0
dtor
dtor
```

Let's make a modification by moving `thread_local` inside the `main` function.

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

Output is as follows:

* The constructor is called once because only the `main` thread goes through the declaration of the `foo` variable, so it allocates storage space and performs initialization. The `t1` thread does not go through the declaration of the `foo` variable, so it only allocates storage space without initialization.

```
default ctor
main: foo'address=0x7f2d690e6778, value=1
t1: foo'address=0x7f2d680166f8, value=0
dtor
```

### 3.6.2 Linkage

A name can have **external linkage**, **module linkage(since C++20)**, **internal linkage**, or **no linkage**:

* An entity whose name has **external linkage** can be redeclared in another translation unit, and the redeclaration can be attached to a different modul(since C++20).
* An entity whose name has **module linkage** can be redeclared in another translation unit, as long as the redeclaration is attached to the same module(since C++20).
* An entity whose name has **internal linkage** can be redeclared in another scope in the same translation unit.
* An entity whose name has **no linkage** can only be redeclared in the same scope.

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

The `virtual` keyword marks a virtual function, and the dispatch of a virtual function occurs at runtime.

1. Every class that has virtual functions maintains a virtual function table (vtable).
1. Objects of classes with virtual functions contain a pointer to that class's vtable.

![virtual-method-table](/images/Cpp-Language/virtual-method-table.jpeg)

* Image comes from [c++虚指针和虚函数表](https://zhuanlan.zhihu.com/p/110144589)

#### 3.7.2.1 virtual destructor

Typically, we need to declare the destructor of a class with virtual functions as `virtual`; otherwise, it can easily cause memory leaks, as shown below:

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

`final` can be used to modify either a class or a virtual function:

* A class marked with `final` cannot have subclasses, and none of its virtual functions can be overridden.
* A virtual function marked with `final` cannot be overridden.
    * It can only be marked at the point of the virtual function's declaration.

When a `final` virtual function is called through a pointer or reference of the concrete type, the compiler can directly optimize away the virtual function call.

### 3.7.4 override

`override` can be used to modify a virtual function, indicating that it overrides a virtual function.

* It can only be applied at the point of the virtual function's declaration.
* Adding or omitting `override` does not affect functionality.

## 3.8 constexpr

### 3.8.1 How to define constexpr variables

* Outside class scope: `inline constexpr`
* Inside class scope: `static inline constexpr`

```sh
cat > const.h << 'EOF'
#pragma once

#include <cstdint>
#include <iostream>

#define PRINT_ADDRESS(x)                                                                 \
    do {                                                                                 \
        std::cout << #x << " address: " << reinterpret_cast<uintptr_t>(&x) << std::endl; \
    } while (0)

class Foo {
public:
    static constexpr int s_value1 = 1;
    static inline constexpr int s_value2 = 2;
};

static constexpr int g_value1 = 1;
inline constexpr int g_value2 = 2;
EOF

cat > lib.cpp << 'EOF'
#include "const.h"

void print_addresses() {
    std::cout << "Print address from lib.cpp:" << std::endl;
    PRINT_ADDRESS(g_value1);
    PRINT_ADDRESS(g_value2);
    PRINT_ADDRESS(Foo::s_value1);
    PRINT_ADDRESS(Foo::s_value2);
}
EOF

cat > main.cpp << 'EOF'
#include "const.h"

extern void print_addresses();

int main() {
    std::cout << "Print address from main.cpp:" << std::endl;
    PRINT_ADDRESS(g_value1);
    PRINT_ADDRESS(g_value2);
    PRINT_ADDRESS(Foo::s_value1);
    PRINT_ADDRESS(Foo::s_value2);

    print_addresses();
    return 0;
}
EOF

gcc -o main main.cpp lib.cpp -lstdc++ -std=gnu++17

nm -C main | grep 'g_value1'
# 000000000000200c r g_value1
# 000000000000206c r g_value1

nm -C main | grep 'g_value2'
# 0000000000002068 u g_value2

nm -C main | grep 'Foo::s_value1'
# 0000000000002004 u Foo::s_value1

nm -C main | grep 'Foo::s_value2'
# 0000000000002008 u Foo::s_value2

./main
```

```
Print address from main.cpp:
value1 address: 94496100839436
value2 address: 94496100839520
Foo::value1 address: 94496100839428
Foo::value2 address: 94496100839432
Print address from lib.cpp:
value1 address: 94496100839524
value2 address: 94496100839520
Foo::value1 address: 94496100839428
Foo::value2 address: 94496100839432
```

### 3.8.2 if constexpr

Compile-time branch selection is generally used in generics. If different branches use features of different types, a normal `if` statement will fail to compile, as shown below:

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

Compile time assertion.

```cpp
int main() {
    static_assert(sizeof(int) == 4, "test1");
    static_assert(sizeof(long) > 8, "test2");
    return 0;
}
```

## 3.10 noexcept

Specifies whether a function could throw exceptions.

* `noexcept(true)`
* `noexcept(false)`
* `noexcept` same as `noexcept(true)`

**Non-throwing functions are permitted to call potentially-throwing functions. Whenever an exception is thrown and the search for a handler encounters the outermost block of a non-throwing function, the function std::terminate is called:**

* An exception throw by a `noexcept` function cannot be normally catched.

```cpp
#include <functional>
#include <iostream>
#include <memory>
#include <utility>

void funcA() {
    std::cout << "funcA" << std::endl;
    throw std::runtime_error("funA");
}

void funcB() noexcept {
    std::cout << "funcB" << std::endl;
    throw std::runtime_error("funcB");
}

int main() {
    try {
        funcA();
    } catch (...) {
        std::cerr << "catch funcA's exception" << std::endl;
    }
    try {
        funcB();
    } catch (...) {
        std::cerr << "catch funcB's exception" << std::endl;
    }
    return 0;
}
```

### 3.10.1 destructor

In practice, implicit destructors are `noexcept` unless the class is "poisoned" by a base or member whose destructor is `noexcept(false)`.

```cpp
#include <iostream>

class Poison {
public:
    explicit Poison() {}
    ~Poison() noexcept(false){};
};

class Foo {
public:
    explicit Foo() = default;
};

class PoisionedFoo {
public:
    explicit PoisionedFoo() = default;
    Poison p;
};

int main() {
    std::cout << noexcept(Foo()) << std::endl;
    std::cout << noexcept(PoisionedFoo()) << std::endl;
    return 0;
}
```

## 3.11 throw and error

The `throw` keyword can throw any object; for example, it can throw an integer.

```c++
    try {
        throw 1;
    } catch (int &i) {
        std::cout << i << std::endl;
    }

    try {
        // Protected code
    } catch (...) {
        // Handle any exceptions.
    }
```

## 3.12 placement new

The purpose of `placement new` is to create an object by invoking its constructor on an already allocated memory space.

```c++
void *buf = // alloc memory here
Class *pc = new (buf) Class();
```

## 3.13 enum

In C++, both `enum` and `enum class` are used to define enumerations, but they differ in scope, type safety, and implicit conversions.

Key characteristics of `enum`:

* **Unscoped**: The enumerator names (Red, Green, Blue) are injected into the surrounding scope.
* **Implicit conversions**: Enumerator values can implicitly convert to int (or their underlying type).
* **Possible name clashes**: Because they go into the outer scope, different enums can't reuse the same names safely.

Example of `enum`:

```cpp
enum Color {
    Red = 0, // 0
    Green,   // 1
    Blue     // 2
};

Color c = Red; // OK
int x = Green; // OK (implicitly converts to int)
```

**Key characteristics of `enum class`**:

* **Scoped**: Enumerator names are placed inside the enum's scope (Color::Red), so no name clashes.
* **Strongly typed**: They do not implicitly convert to int.
* **Type-safe**: Can't be mixed with other enums or integers without an explicit cast.

Example of `enum class`:

```cpp
enum class Color {
    Red = 0, // 0
    Green,   // 1
    Blue     // 2
};

Color c = Color::Red;                   // Must qualify the name
int x = c;                              // ❌ Error — no implicit conversion to int
int y = static_cast<int>(Color::Green); // ✅ explicit cast
```

# 4 Syntax

## 4.1 Initialization

### 4.1.1 Initialization Types

1. Default initialization: `type variableName;`
1. Direct initialization / Constructor initialization (with at least one argument): `type variableName(args);`
1. List initialization: `type variableName{args};`
    * Essentially, list initialization calls the corresponding constructor (matching the argument types and number) for initialization.
    * One of its advantages is that it can simplify the `return` statement, allowing `return {args};` directly.
1. Copy initialization:
    * `type variableName = otherVariableName`, essentially calls the copy constructor.
    * `type variableName = <type (args)>`, where `<type (args)>` refers to a function that returns a `type`. It seems like the copy constructor would be called, but the compiler optimizes this form of initialization, meaning only the constructor is called within the function (if applicable), and the `=` does not call any constructor.
1. Value initialization: `type variableName()`
    * For built-in types, initialized to `0` or `nullptr`.
    * For class types, equivalent to default initialization. Testing shows that no constructor is actually called.

```c++
#include <iostream>

class A {
public:
    A() { std::cout << "A's default constructor" << std::endl; }

    A(int a) : _a(a), _b(0) { std::cout << "A's (int) constructor" << std::endl; }

    A(int a, int b) : _a(a), _b(b) { std::cout << "A's (int, int) constructor" << std::endl; }

    A(const A& a) : _a(a._a), _b(a._b) { std::cout << "A's copy constructor" << std::endl; }

    A(A&& a) : _a(a._a), _b(a._b) { std::cout << "A's move constructor" << std::endl; }

    A& operator=(const A& a) {
        std::cout << "A's copy assign operator" << std::endl;
        this->_a = a._a;
        this->_b = a._b;
        return *this;
    }

    A& operator=(A&& a) noexcept {
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
    std::cout << "============(a1)============" << std::endl;
    A a1;
    std::cout << "\n============(a2)============" << std::endl;
    A a2(1);
    std::cout << "\n============(a3)============" << std::endl;
    A a3(1, 2);
    std::cout << "\n============(a4)============" << std::endl;
    A a4 = {};
    std::cout << "\n============(a5)============" << std::endl;
    A a5 = {1};
    std::cout << "\n============(a6)============" << std::endl;
    A a6 = {1, 2};
    std::cout << "\n============(a7)============" << std::endl;
    A a7 = a6;
    std::cout << "\n============(a8)============" << std::endl;
    A a8 = createA(0);
    std::cout << "\n============(a9)============" << std::endl;
    A a9 = createA(1);
    std::cout << "\n============(a10)============" << std::endl;
    A a10 = createA(2);
    std::cout << "\n============(a11)============" << std::endl;
    A a11();
}
```

Output:

```
============(a1)============
A's default constructor

============(a2)============
A's (int) constructor

============(a3)============
A's (int, int) constructor

============(a4)============
A's default constructor

============(a5)============
A's (int) constructor

============(a6)============
A's (int, int) constructor

============(a7)============
A's copy constructor

============(a8)============
A's default constructor

============(a9)============
A's (int) constructor

============(a10)============
A's (int, int) constructor

============(a11)============
```

### 4.1.2 Initialization of static Local Variables

```cpp
void foo() {
    static Bar bar;
    // ...
}
```

The initialization process is equivalent to the following program, where:

* `guard_for_bar` is an integer variable used to ensure thread safety and one-time initialization. It is generated by the compiler and stored in the `bss` segment. The lowest byte of this variable serves as a flag indicating whether the corresponding static variable has been initialized. If it is `0`, it means the variable has not been initialized yet; otherwise, it means it has been initialized.
* `__cxa_guard_acquire` is essentially a locking process, while `__cxa_guard_abort` and `__cxa_guard_release` release the lock.
* `__cxa_atexit` registers a function to be executed when `exit` is called or when a dynamic library (or shared library) is unloaded. In this case, the destructor of `Bar` is registered.

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

### 4.1.3 List-initialization

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

#### 4.1.3.1 Aggregate initialization

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

## 4.2 Pointer

### 4.2.1 Multi-dimensional Pointer

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

## 4.3 Reference

### 4.3.1 Reference Initialization

References can only be initialized at the point of definition.

```cpp
int main() {
    int a = 1;
    int b = 2;

    int &ref = a;
    ref = b;

    std::cout << "a=" << a << std::endl;
    std::cout << "b=" << b << std::endl;
    std::cout << "ref=" << ref << std::endl;
}
```

Output:

```
a=2
b=2
ref=2
```

## 4.4 Class

### 4.4.1 Member Initializer List

1. For built-in types, a direct value copy is made. There's no difference between using an initializer list or initializing within the constructor body.
1. For class types:
    * Initializing in the initializer list: Calls either the copy constructor or the move constructor.
    * Initializing in the constructor body: Even though it's not explicitly specified in the initializer list, the default constructor is still called to initialize it, followed by the use of the copy or move assignment operator within the constructor body.
1. What must be placed in the initializer list:
    * Constant members
    * Reference types
    * Class types without a default constructor, because using the initializer list avoids the need to call the default constructor and instead directly calls the copy or move constructor for initialization.

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

Output:

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

### 4.4.2 Initialization Order of Class Members

1. Initializer list
1. List initialization at the member definition, which takes effect only if the member is not included in the initializer list
1. Initialization behavior within the constructor body

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

Output:

```
initialized_where_defined
initialized_at_construct_block

---------------------------------------

initialized_at_initialization_list
initialized_at_construct_block
```

### 4.4.3 Initialization of non-static Class Members

Non-static members are not allowed to use constructor initialization, but they are allowed to use list initialization (which essentially still calls the corresponding constructor).

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

### 4.4.4 How to define static members in a class

**Declare static members in the class and define (assign) static members outside the class, as shown in the example below:**

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

### 4.4.5 Non-static members of a Class cannot undergo type deduction

Non-static members of a class cannot undergo type deduction; the type must be explicitly specified (as the type information must be immutable). Static members, however, can. For example, the following code contains a syntax error:

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

### 4.4.6 Member Function Pointer

Member function pointers need to be invoked using the `.*` or `->*` operators.

* Inside the class: `(this->*<name>)(args...)`
* Outside the class: `(obj.*obj.<name>)(args...)` or `(pointer->*pointer-><name>)(args...)`

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

### 4.4.7 Mock class

Sometimes during testing, we need to mock the implementation of a class. We can implement all the methods of this class (**note, it must be all methods**) in the test `.cpp` file, which will override the implementation in the original library. Below is an example:

**Directory structure is as follows**

```
.
├── lib
│   ├── libperson.a
│   ├── person.cpp
│   ├── person.h
│   └── person.o
└── main.cpp
```

**`lib/person.h`:**

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

**`lib/person.cpp`:**

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

**Build `person.cpp` to `.a`**

```sh
g++ person.cpp -c -std=gnu++11
ar crv libperson.a person.o
```

**`main.cpp`:**

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

**Compile `main.cpp` and execute:**

```sh
g++ -o main main.cpp -std=gnu++11 -L lib -lperson

./main

work
sleep
eat
```

**Next, we modify `main.cpp` to override the original `work`, `sleep`, and `eat` methods:**

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

**Compile `main.cpp` and execute:**

```sh
g++ -o main main.cpp -std=gnu++11 -L lib -lperson

./main

mock work
mock sleep
mock eat
```

**Then, we proceed to modify `main.cpp` by removing one of the methods:**

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

**Compile `main.cpp`(Failed)**

```sh
g++ -o main main.cpp -std=gnu++11 -L lib -lperson
```

## 4.5 Operator Overloading

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

### 4.5.1 std::forward cannot convert brace-enclosed initializer list

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

## 4.6 Variadic Arguments

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

### 4.6.1 How to forward variadic arguments

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

### 4.6.2 Implicit Type Conversion

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

## 4.7 Attributes

`__attribute__` is a feature specific to the `GCC` compiler that allows programmers to provide the compiler with certain instructions to optimize during compilation or apply additional constraints during runtime. These instructions are called attributes (`attributes`) and can be applied to various program elements such as functions, variables, and types.

`C++11` introduced a new language feature called attributes (`attributes`), which are similar to `__attribute__` but are part of the standard `C++`, making them usable in `C++` code after the compiler supports `C++11`. Unlike `__attribute__`, `C++11` attributes can be used at the class and namespace levels, not just at the function and variable levels.

`C++11` attributes also provide more flexibility and readability. They can be embedded in the code in a more natural way, unlike `__attribute__`, which requires some verbose syntax. Additionally, `C++11` attributes offer some useful new features such as `[[noreturn]]`, `[[carries_dependency]]`, `[[deprecated]]`, `[[fallthrough]]`.

Common `__attribute__` list:

* `__attribute__((packed))`: Instructs the compiler to pack structure members as tightly as possible to reduce the memory footprint of the structure.
* `__attribute__((aligned(n)))`: Instructs the compiler to align a variable to an `n`-byte boundary.
* `__attribute__((noreturn))`: Instructs the compiler that the function will not return, which is used to inform the compiler that no cleanup is needed after the function call.
* `__attribute__((unused))`: Instructs the compiler not to issue a warning for unused variables.
* `__attribute__((deprecated))`: Instructs the compiler that the function or variable is deprecated, and the compiler will issue a warning when they are used.
* `__attribute__((visibility("hidden")))`: Instructs the compiler to hide the symbol, meaning it will not appear in the exported symbol table of the current compilation unit.
* `__attribute__((guarded_by(mutex)))`: is used to annotate a data member (usually a class member variable) to indicate that it is protected by a specific `mutex`. This attribute acts as a directive to the compiler or static analysis tools to help ensure thread safety.
* `__attribute__(alias)`: Allows you to specify the name of a function or variable as an alias for an existing function or variable. It can serve a similar purpose as the linker parameter `--wrap=<symbol>`.

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

Common `attributes` list:

* `[[noreturn]]` (C++11): Indicates that a function will not return. If a function is marked with `[[noreturn]]`, the compiler will issue a warning or error for any attempt to return a value from that function.
* `[[deprecated]]` (C++14): Indicates that a function or variable is deprecated. The compiler will issue a warning when a function or variable marked with `[[deprecated]]` is called or used.
* `[[fallthrough]]` (C++17): Used to indicate a `case` label in a `switch` statement, signaling that the code intentionally falls through to the next `case` label.
* `[[nodiscard]]` (C++17): Indicates that the return value of a function should be checked. When a function is marked with `[[nodiscard]]`, the compiler will issue a warning if the return value is not checked.
* `[[maybe_unused]]` (C++17): Indicates that a variable or function may be unused. The compiler will not issue a warning for unused variables or functions.
* `[[likely]]` (C++20): Hints to the compiler that this branch is likely to be `true`.
* `[[unlikely]]` (C++20): Hints to the compiler that this branch is likely to be `false`.

### 4.7.1 aligned

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

### 4.7.2 Reference

* [Compiler-specific Features](https://www.keil.com/support/man/docs/armcc/armcc_chr1359124965789.htm)

## 4.8 ASM

[gcc-online-docs](https://gcc.gnu.org/onlinedocs/gcc/)

### 4.8.1 Basic Asm

### 4.8.2 Extended Asm

[Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html): GCC has designed a unique embedding method that defines the form of embedded assembly code and specifies the components required for embedding assembly. The format is as follows:

* The assembly instruction template is mandatory, while the other three parts are optional.

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

**`Qualifiers`: Modifiers**

* `volatile`: Prevents the compiler from optimizing.
* `inline`
* `goto`

**`AssemblerTemplate`, assembly instruction template:**

* The assembly instruction template consists of a sequence of assembly instructions, separated by `;`, `\n`, or `\n\t`.
* Operands in instructions can use placeholders, which may refer to `OutputOperands`, `InputOperands`, or `GotoLabels`.
* Operands represented by placeholders in the instruction are always treated as `long` (4 bytes). However, depending on the instruction, they may be operated on as words or bytes. When treated as a word or byte, the default is the low word or low byte.
* For byte operations, you can explicitly indicate whether it's the low byte or high byte. This is done by inserting a letter between `%` and the index:
    * `b` represents the low byte.
    * `h` represents the high byte.
    * Example: `%h1`.

**`OutputOperands`, output operands:**

* Operands are separated by commas.
* Each operand descriptor consists of a constraint string (`Constraints`) and a C variable or expression.

**`InputOperands`, input operands:**

* Operands are separated by commas.
* Each operand descriptor consists of a constraint string (`Constraints`) and a C variable or expression.

**`Clobbers`, clobber list:**

* Used to inform the compiler which registers or memory are used; consists of comma-separated strings.
* Each string describes a case, usually a register name; besides registers, there is also `memory`. For example: `%eax`, `%ebx`, `memory`, etc.

**`Constraints`, constraint strings (commonly used ones):**

* `m`: Memory
* `o`: Memory, but addressable via offset
* `v`: Memory, but not addressable via offset
* `r`: General-purpose register
* `i`: Integer immediate value
* `g`: Any general-purpose register, memory, or immediate value
* `p`: Valid pointer
* `=`: Write-only
* `+`: Read-write
* `&`: The output operand cannot use the same register as an input operand

**Example 1:**

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

**Example 2:**

* This program cannot run because the `cli` instruction must be executed in kernel mode.
* `hal_save_flags_cli`: Saves the value of the `eflags` register into memory, then disables interrupts.
* `hal_restore_flags_sti`: Restores the value saved by `hal_save_flags_cli` from memory back into the `eflags` register.

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>

typedef uint32_t cpuflg_t;

static inline void hal_save_flags_cli(cpuflg_t* flags) {
    __asm__ __volatile__(
            "pushf;" // Push the value of the `eflags` register onto the current stack top.
            "cli;"   // Disable interrupts, which changes the value of the `eflags` register.
            "pop %0" // Pop the current stack top into the memory location addressed by `eflags`.
            : "=m"(*flags)
            :
            : "memory");
}

static inline void hal_restore_flags_sti(cpuflg_t* flags) {
    __asm__ __volatile__(
            "push %0;" // Push the value at the address `flags` onto the current stack top.
            "popf"     // Pop the current stack top into the `eflags` register.
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

**Example 3: The Linux kernel makes extensive use of `asm`. For details, see[linux-asm](https://github.com/torvalds/linux/blob/master/arch/x86/include/asm)**

## 4.9 Lambda

[Lambda expressions (since C++11)](https://en.cppreference.com/w/cpp/language/lambda)

> The lambda expression is a prvalue expression of unique unnamed non-union non-aggregate class type, known as closure type, which is declared (for the purposes of ADL) in the smallest block scope, class scope, or namespace scope that contains the lambda expression. The closure type has the following members, they cannot be explicitly instantiated, explicitly specialized, or (since C++14) named in a friend declaration

* Each `Lambda` expression has a unique type, which cannot be explicitly declared.

### 4.9.1 `std::function` and Lambda

In most cases, `Lambda` and `std::function` can be used interchangeably, but there are some differences between them.（[What's the difference between a lambda expression and a function pointer (callback) in C++?](https://www.quora.com/Whats-the-difference-between-a-lambda-expression-and-a-function-pointer-callback-in-C++)）：

* A `Lambda` cannot have its type explicitly declared, whereas `std::function` can.
* `Lambda` is more efficient, see {% post_link Cpp-Performance-Optimization %}.
    * `std::function` is essentially a wrapper around a function pointer, making it difficult for the compiler to inline during passing.
    * A `Lambda` is essentially an instance of an anonymous class with concrete type information, which allows the compiler to inline more easily.

### 4.9.2 How lambda capture itself

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

### 4.9.3 C-Stype function pointer

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

## 4.10 Coroutine

[C++20's Coroutines for Beginners - Andreas Fertig - CppCon 2022](https://www.youtube.com/watch?v=8sEe-4tig_A)

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

### 4.10.1 Overview of `promise_type`

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

#### 4.10.1.1 Awaiter

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

### 4.10.2 Example

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

## 5.1 Template category

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

### 5.1.1 Examples

**Case 1:**

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

**Case 2:**

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

## 5.2 Template parameter

[Template parameters and template arguments](https://en.cppreference.com/w/cpp/language/template_parameters)

Every template is parameterized by one or more template parameters, indicated in the parameter-list of the template declaration syntax:

```cpp
template < parameter-list > declaration
```

Each parameter in parameter-list may be:

* **a non-type template parameter;**
* **a type template parameter;**
* **a template template parameter.**

## 5.3 Template argument

[Template parameters and template arguments](https://en.cppreference.com/w/cpp/language/template_parameters)

In order for a template to be instantiated, every template parameter (type, non-type, or template) must be replaced by a corresponding template argument. For class templates, the arguments are either explicitly provided, deduced from the initializer, (since C++17) or defaulted. For function templates, the arguments are explicitly provided, deduced from the context, or defaulted.

Each argument may be:

* **a template non-type argument;**
* **a template type argument;**
* **a template template argument.**

## 5.4 Parameter pack

[Parameter pack](https://en.cppreference.com/w/cpp/language/parameter_pack)

A template parameter pack is a template parameter that accepts zero or more template arguments (non-types, types, or templates). A function parameter pack is a function parameter that accepts zero or more function arguments.

A template with at least one parameter pack is called a variadic template.

### 5.4.1 Fold Expressions

[Fold expressions](https://en.cppreference.com/w/cpp/language/fold)

Reduces (folds) a parameter pack over a binary operator.

**Syntax:**

* Unary right fold: `( pack op ... )`
* Unary left fold: `( ... op pack )`
* Binary right fold: `( pack op ... op init )`
* Binary left fold: `( init op ... op pack )`
* `op`: any of the following 32 binary operators: `+` `-` `*` `/` `%` `^` `&` `|` `=` `<` `>` `<<` `>>` `+=` `-=` `*=` `/=` `%=` `^=` `&=` `|=` `<<=` `>>=` `==` `!=` `<=` `>=` `&&` `||` `,` `.*` `->*`. In a binary fold, both ops must be the same.
* `pack`: an expression that contains an unexpanded parameter pack and does not contain an operator with precedence lower than cast at the top level (formally, a cast-expression)
* `init`: an expression that does not contain an unexpanded parameter pack and does not contain an operator with precedence lower than cast at the top level (formally, a cast-expression)
Note that the opening and closing parentheses are a required part of the fold expression.

**Case 1:**

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

**Case 2:**

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

### 5.4.2 Traverse Parameter Pack

#### 5.4.2.1 Parenthesis Initializer

[Built-in comma operator](https://en.cppreference.com/w/cpp/language/operator_other#Built-in_comma_operator): In a comma expression `E1, E2`, the expression `E1` is evaluated, its result is discarded (although if it has class type, it won't be destroyed until the end of the containing full expression), and its side effects are completed before evaluation of the expression `E2` begins (note that a user-defined operator, cannot guarantee sequencing)

```cpp
#include <iostream>

int main() {
    int n = 1;
    int m = (++n, std::cout << "n = " << n << '\n', ++n, 2 * n); // print 2, n=3, m=6
    std::cout << "m = " << (++m, m) << '\n';                     // print 7
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

#### 5.4.2.2 constexpr for

Sometimes, fold expressions cannot handle certain complex scenarios. In such cases, we may want to process the parameters one by one using a loop, as shown below (see [Approximating 'constexpr for'](https://artificial-mind.net/blog/2020/10/31/constexpr-for)):

* Since an iteration variable is needed inside the function to extract elements from the parameter pack, this variable must be a compile-time constant. Here, `std::integral_constant` is used for the conversion. This way, inside the function, we can use `std::get<i>` to extract the `i`-th parameter.

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

## 5.5 template specialization

### 5.5.1 Explicit (full) template specialization

[Explicit (full) template specialization](https://en.cppreference.com/w/cpp/language/template_specialization) Allows customizing the template code for a given set of template arguments.

### 5.5.2 Partial template specialization

[Partial template specialization](https://en.cppreference.com/w/cpp/language/partial_specialization) Allows customizing class and variable(since C++14) templates for a given category of template arguments.

* template function don't support partial template specialization.

**The requirements of argument list:**

* The argument list cannot be identical to the non-specialized argument list (it must specialize something).
    ```cpp
    template<class T1, class T2, int I> class B {};        // primary template
    template<class X, class Y, int N> class B<X, Y, N> {}; // error
    ```

* Default arguments cannot appear in the argument list.
* If any argument is a pack expansion, it must be the last argument in the list.
* ...

#### 5.5.2.1 Members of partial specializations

The template parameter list and the template argument list of a member of a partial specialization must match the parameter list and the argument list of the partial specialization.

Just like with members of primary templates, they only need to be defined if used in the program.

Members of partial specializations are not related to the members of the primary template.

Explicit (full) specialization of a member of a partial specialization is declared the same way as an explicit specialization of the primary template.

```cpp
template <class T, int I> // primary template
struct A {
    void f(); // member declaration
};

template <class T, int I>
void A<T, I>::f() {} // primary template member definition

// partial specialization
template <class T>
struct A<T, 2> {
    void f();
    void g();
    void h();
};

// member of partial specialization
template <class T>
void A<T, 2>::g() {}

// explicit (full) specialization
// of a member of partial specialization
template <>
void A<char, 2>::h() {}

int main() {
    A<char, 0> a0;
    A<char, 2> a2;
    a0.f(); // OK, uses primary template's member definition
    a2.g(); // OK, uses partial specialization's member definition
    a2.h(); // OK, uses fully-specialized definition of
            // the member of a partial specialization
    a2.f(); // error: no definition of f() in the partial
            // specialization A<T,2> (the primary template is not used)
}
```

#### 5.5.2.2 How to use std::enable_if in partial specialization

**Wrong way:**

* Default arguments cannot appear in the argument list.
* Didn't specialize anything.

```cpp
#include <type_traits>

template <typename T>
struct Foo {};

template <typename T, typename = std::enable_if_t<std::is_integral_v<T>>>
struct Foo<T> {};
```

**Right way:**

```cpp
#include <type_traits>

template <typename T, typename E = void>
struct Bar {};

template <typename T>
struct Bar<T, std::enable_if_t<std::is_integral_v<T>>> {};
```

## 5.6 Template Instantiation

Template instantiation is the process by which the C++ compiler generates concrete code from a template when you use it with specific types.

### 5.6.1 Implicit Instantiation

Implicit instantiation happens automatically when a template is used. It is useful when you want to pre-compile template code in a `.cpp` file to reduce compile times or binary size.

### 5.6.2 Explicit Instantiation

Explicit Instantiation ask the compiler to generate a specific instantiation.

```sh
cat > lib.h << 'EOF'
#pragma once

class Foo {
public:
    template <typename T>
    void m_print(const T& t);
};

template <typename T>
class Bar {
public:
    void m_print(const T& t);
};

template <typename T>
void g_print(const T& t);
EOF

cat > lib.cpp << 'EOF'
#include "lib.h"

#include <iostream>

template <typename T>
void Foo::m_print(const T& t) {
    std::cout << "Foo::m_print: " << t << std::endl;
}

template <typename T>
void Bar<T>::m_print(const T& t) {
    std::cout << "Bar::m_print: " << t << std::endl;
}

template <typename T>
void g_print(const T& t) {
    std::cout << "g_print: " << t << std::endl;
}

template void Foo::m_print(const int32_t&);
template void Foo::m_print(const std::string&);

template class Bar<int32_t>;
template class Bar<std::string>;

template void g_print(const int32_t&);
template void g_print(const std::string&);
EOF

cat > main.cpp << 'EOF'
#include <stdint.h>

#include <string>

#include "lib.h"

int main() {
    Foo foo;
    Bar<int32_t> bar1;
    Bar<std::string> bar2;

    int32_t val1 = 1;
    std::string val2 = "this is a string";

    foo.m_print(val1);
    foo.m_print(val2);

    bar1.m_print(val1);
    bar2.m_print(val2);

    g_print(val1);
    g_print(val2);
    return 0;
}
EOF

gcc -o main main.cpp lib.cpp -lstdc++ -std=gnu++17 -O3
./main
```

cmake example:

```sh
mkdir -p explicit_instantiation_demo
cd explicit_instantiation_demo

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(explicit_instantiation_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_compile_options(-O3 -Wall)

file(GLOB MAIN_SOURCES "main.cpp")
add_executable(${PROJECT_NAME} ${MAIN_SOURCES})
target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_SOURCE_DIR})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

file(GLOB LIB_A_SOURCES "liba/liba.cpp")
add_library(my_liba STATIC ${LIB_A_SOURCES})
target_include_directories(my_liba PUBLIC ${CMAKE_SOURCE_DIR}/liba)

file(GLOB LIB_B_SOURCES "libb/libb.cpp")
add_library(my_libb STATIC ${LIB_B_SOURCES})
target_include_directories(my_libb PUBLIC ${CMAKE_SOURCE_DIR}/libb)
target_link_libraries(my_libb PRIVATE my_liba)

target_link_libraries(${PROJECT_NAME} PRIVATE my_libb)
EOF

mkdir -p liba
cat > liba/liba.h << 'EOF'
#pragma once

class Foo {
public:
    template <typename T>
    void m_print(const T& t);
};

template <typename T>
class Bar {
public:
    void m_print(const T& t);
};

template <typename T>
void g_print(const T& t);
EOF
cat > liba/liba.cpp << 'EOF'
#include "liba.h"

#include <iostream>

template <typename T>
void Foo::m_print(const T& t) {
    std::cout << "Foo::m_print: " << t << std::endl;
}

template <typename T>
void Bar<T>::m_print(const T& t) {
    std::cout << "Bar::m_print: " << t << std::endl;
}

template <typename T>
void g_print(const T& t) {
    std::cout << "g_print: " << t << std::endl;
}

template void Foo::m_print(const int32_t&);
template void Foo::m_print(const std::string&);

template class Bar<int32_t>;
template class Bar<std::string>;

template void g_print(const int32_t&);
template void g_print(const std::string&);
EOF

mkdir -p libb
cat > libb/libb.h << 'EOF'
#pragma once

void greet_via_liba_Foo_m_print();
void greet_via_liba_Bar_m_print();
void greet_via_liba_g_print();
EOF
cat > libb/libb.cpp << 'EOF'
#include "libb.h"

#include <liba.h>

#include <string>

static std::string content = "Hello, this is libb";

void greet_via_liba_Foo_m_print() {
    Foo foo;
    foo.m_print(content);
}
void greet_via_liba_Bar_m_print() {
    Bar<std::string> bar;
    bar.m_print(content);
}
void greet_via_liba_g_print() {
    g_print(content);
}
EOF

cat > main.cpp << 'EOF'
#include <libb.h>

int main() {
    greet_via_liba_Foo_m_print();
    greet_via_liba_Bar_m_print();
    greet_via_liba_g_print();
    return 0;
}
EOF

cmake -B build
cmake --build build
build/explicit_instantiation_demo
```

## 5.7 When template parameters cannot be deduced

In C++ template programming, when a template parameter appears on the left side of `::`, it typically cannot be deduced. This is because the left side of `::` often represents a `dependent type`, which the compiler cannot resolve during template argument deduction.

**Case 1:**

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

**Case 2:**

```cpp
#include <type_traits>
#include <vector>

template <typename T>
class Foo {};

template <typename T>
class Foo<std::vector<T>> {};

// This one cannot be deduced
template <typename T>
class Foo<std::vector<T>::value_type> {};

// This one cannot be deduced
template <typename T>
class Foo<std::conditional_t<std::is_integral_v<T>, int, double>> {};

template <typename T, typename U>
class Bar {};

// T can be directly deduced from template parameter `std::vector<T>`
// so the dependent type `std::vector<T>::value_type` can be also deduced
template <typename T>
class Bar<std::vector<T>, typename std::vector<T>::value_type> {};

// T can be directly deduced from template parameter `std::vector<T>`
// so the dependent type `std::conditional_t` and `std::is_integral_v` can be also deduced
template <typename T>
class Bar<std::vector<T>, std::conditional_t<std::is_integral_v<T>, int, double>> {};
```

## 5.8 Using typename to Disambiguate

**Under what circumstances would ambiguity arise? For example, `foo* ptr;`**

* If `foo` is a type, then this statement is a declaration, i.e., it defines a variable of type `foo*`.
* If `foo` is a variable, then this statement is an expression, i.e., it performs the `*` operation on `foo` and `ptr`.
* The compiler cannot distinguish which of the above two cases it is. Therefore, you can explicitly use `typename` to inform the compiler that `foo` is a type.

**For templates, such as `T::value_type`, the compiler similarly cannot determine whether `T::value_type` is a type or not. This is because the class scope resolution operator `::` can access both type members and static members. By default, the compiler assumes that something in the form of `T::value_type` is not a type.**

**Case 1:**

```cpp
// The following will fail to compile:
template<typename T>
T::value_type sum(const T &container) {
    T::value_type res = {};
    for (const auto &item: container) {
        res += item;
    }
    return res;
}
```

**After refined:**

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

**Under what circumstances would ambiguity arise? For example, `container.emplace<int>(1);`**

* If `container.emplace` is a member variable, then `<` can be interpreted as a less-than symbol.
* If `container.emplace` is a template, then `<` can be interpreted as the brackets for template parameters.

**Case 1:**

```cpp
class Container {
public:
    template<typename T>
    void emplace(T value) {
        std::cout << "emplace value: " << value << std::endl;
    }
};

// The following will fail to compile:
template<typename T>
void add(T &container) {
    container.emplace<int>(1);
}
```

**After refined:**

```cpp
template<typename T>
void add(T &container) {
    container.template emplace<int>(1);
}
```

**Case 2:**

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

**After refined:**

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

Syntactically, we cannot define aliases (using `using`) in the parameter list of a template.
However, we can achieve a similar effect to type aliases by defining type parameters with default values, as shown below:

```cpp
template <typename HashMap, typename KeyType = typename HashMap::key_type,
          typename ValueType = typename HashMap::mapped_type>
ValueType& get(HashMap& map, const KeyType& key) {
    return map[key];
}
```

## 5.11 Accessing members of a template parent class from a non-template derived class

* Approach 1: `MemberName`
* Approach 2: `this->MemberName`

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

* Approach 1: `ParentClass<Template Args...>::MemberName`
* Approach 2: `this->MemberName`

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

## 5.13 Separating the definition and implementation of a template

We can place the declaration and definition of a template in two separate files, which makes the code structure clearer. For example, suppose there are two files `test.h` and `test.tpp`, with the following contents:

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

As we can see, `test.h` references `test.tpp` at the end, so other modules only need to include `test.h`. The entire template definition can also be clearly viewed through a single file, `test.h`. However, there is an issue here: if we use `vscode` or the `lsp` plugin in `vim` to read or edit the `test.tpp` file, we may encounter syntax problems because `test.tpp` itself is incomplete and cannot be compiled.

Referring to [[BugFix] Fix the problem of null aware anti join](https://github.com/StarRocks/starrocks/pull/15330), we can resolve this issue with a small trick by modifying `test.h` and `test.tpp` as follows:

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

In this way, when editing these two files independently, `lsp` can work normally without causing circular reference issues.

When there is no `compile_commands.json` file, `clangd` will report an error when processing a standalone `tpp` file. The error message is: `Unable to handle compilation, expected exactly one compiler job in ''`.

### 5.13.1 Hide template implementation

We can even hide the specific implementation of the template, but in this case, all required types must be explicitly instantiated in the defining `.cpp` file. This is because the implementation of the template is not visible to other `.cpp` files and can only resolve the corresponding symbols during linking.

```sh
cat > template.h << 'EOF'
#pragma once

template <typename T>
class Foo {
public:
    void func();
};
EOF

cat > template.cpp << 'EOF'
#include "template.h"

#include <iostream>

template <typename T>
void Foo<T>::func() {
    std::cout << "Foo::func's default implementation" << std::endl;
}

template <>
void Foo<double>::func() {
    std::cout << "Foo::func's special implementation for double" << std::endl;
}

template class Foo<int>;
template class Foo<double>;
EOF

cat > main.cpp << 'EOF'
#include "template.h"

int main() {
    Foo<int>().func();
    Foo<double>().func();
    return 0;
}
EOF

gcc -o main main.cpp template.cpp -lstdc++ -std=gnu++17 -O3
```

## 5.14 [CRTP](https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern)

The full name of `CRTP` is `Curious Recurring Template Pattern`.

### 5.14.1 Static Polymorphism

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

### 5.14.2 Object Counter

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

### 5.14.3 Polymorphic Chaining

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

* The return type of `PlainCoutPrinter().print("Hello ")` is `PlainPrinter`, which loses the specific `PlainCoutPrinter` type information. As a result, calling `SetConsoleColor` afterward causes an error.
* Using `CRTP` avoids this problem, because the return type of methods in the base class is always the concrete derived class.

### 5.14.4 Polymorphic Copy Construction

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

## 5.15 PIMPL

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

The rules of happens-before under different `std::memory_order` values:

* `std::memory_order_seq_cst`
    * `normal-write` happens-before `atomic-write`
    * `atomic-read` happens-before `normal-read`
    * `atomic-write` happens-before `atomic-read`
    * We deduce that `normal-write` happens-before `normal-read`
* `std::memory_order_relaxed`
    * `normal-write` happens-before `atomic-write`
    * `atomic-read` happens-before `normal-read`
    * We cannot deduce that `normal-write` happens-before `normal-read`

In the following program:

* `test_atomic_visibility<std::memory_order_seq_cst>();` executes correctly.
* `test_atomic_visibility<std::memory_order_relaxed>();` also executes correctly, because x86 uses the `TSO` model, where `std::memory_order_relaxed` still satisfies the `atomic-write happens-before atomic-read` rule.
* `test_volatile_visibility` throws an error, because `volatile` does not provide synchronization semantics and imposes no restrictions on reordering.

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

The demo comes from [Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf), `Figure-5(a)`

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

On the `x86` platform (`TSO`), the results are as follows: only `memory_order_seq_cst` can guarantee consistency, while `memory_order_acquire`/`memory_order_release` apply only to the same variable — `Write-Read` operations on different variables may still be reordered.

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=false
test std::memory_order_relaxed, std::memory_order_relaxed, res=false
```

### 6.4.3 Case-3-write-write-read-read-reorder

The demo comes from [Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf), `Figure-5(b)`

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

On the `x86` platform (`TSO`), the `Relaxed Consistency Model` does not allow `Write-Write` or `Read-Read` reordering. The results are as follows (for other hardware platforms with different memory models, the results may vary depending on their level of support for `Relaxed`):

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=true
test std::memory_order_relaxed, std::memory_order_relaxed, res=true
```

### 6.4.4 Case-4-write-order-consistency

The demo comes from [Shared Memory Consistency Models: A Tutorial](/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf), `Figure-10(b)`

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

On the `x86` platform (`TSO`), the `Relaxed Consistency Model` requires that the order of `Write` operations observed by all cores is consistent. The results are as follows (for other hardware platforms with different memory models, the results may vary depending on their level of support for `Relaxed`):

```
test std::memory_order_seq_cst, std::memory_order_seq_cst, res=true
test std::memory_order_acquire, std::memory_order_release, res=true
test std::memory_order_relaxed, std::memory_order_relaxed, res=true
```

### 6.4.5 Case-5-visibility

Process scheduling can also ensure visibility. We can bind the read and write threads to a specific core, so that under the effect of scheduling, the read and write threads will execute alternately.

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

Output:

```
type=int32_t, count=2000000
type=volatile int32_t, count=2000000
type=std::atomic<int32_t>, count=2000000
```

### 6.4.6 Case-6-eventual-consistency

Different atomic operations, although they cannot guarantee synchronization semantics, can ensure eventual consistency of variables.

* Without atomic operations, the `write` thread's writes cannot be observed by the `read` thread's reads (at the `-O3` optimization level).
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

* Using different `std::mutex` instances can ensure eventual consistency of variables.
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

* Using different `std::atomic` instances can ensure eventual consistency of variables.
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

For `std::memory_order_relaxed`, its effect varies across different hardware platforms. The x86 architecture follows the `TSO` model.

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
* `std::tie`: Can work with structured bindings.

```cpp
#include <iostream>
#include <tuple>

struct Person {
    std::string name;
    int age;
    double height;

    Person(const std::string& n, int a, double h) : name(n), age(a), height(h) {}
};

int main() {
    const std::tuple<int, double, std::string> t1(42, 3.14, "Hello");

    auto [x, y, z] = t1;
    std::cout << "x: " << x << std::endl;
    std::cout << "y: " << y << std::endl;
    std::cout << "z: " << z << std::endl;

    const std::tuple<int, double, std::string> t2(100, 2.71, "World");

    std::tie(x, y, z) = t2;
    std::cout << "x: " << x << std::endl;
    std::cout << "y: " << y << std::endl;
    std::cout << "z: " << z << std::endl;

    const Person person1("Alice", 30, 1.75);

    auto [name, age, height] = person1;
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
* `Named Return Value Optimization (NRVO)`: Similar to RVO, NRVO allows the compiler to eliminate the temporary object even when the object returned has a name. NRVO is a bit more challenging for the compiler because it involves predicting which named variable will be returned at compile time.
* Moving a local object in a return statement prevents copy elision.

```cpp
#include <iostream>

class Widget {
public:
    Widget() { std::cout << "Widget()" << std::endl; }
    Widget(const Widget&) { std::cout << "Widget(const Widget&)" << std::endl; }
    Widget(Widget&&) { std::cout << "Widget(Widget&&)" << std::endl; }
    Widget& operator=(const Widget&) {
        std::cout << "operator=(const Widget&)" << std::endl;
        return *this;
    }
    Widget& operator=(Widget&&) {
        std::cout << "operator=(Widget&&)" << std::endl;
        return *this;
    }
};

Widget createWidgetRVO() {
    return Widget();
}

Widget createWidgetNRVO() {
    return Widget();
}

Widget createWidgetNonRVO() {
    auto w = Widget();
    return std::move(w);
}

int main() {
    {
        std::cout << "Testing RVO:" << std::endl;
        Widget w = createWidgetRVO(); // With RVO, the copy constructor is not called
    }
    {
        std::cout << "Testing NRVO:" << std::endl;
        Widget w2 = createWidgetNRVO(); // With NRVO, the copy constructor is not called
    }
    {
        std::cout << "Testing non-RVO:" << std::endl;
        Widget w3 = createWidgetNonRVO(); // Without RVO, the copy constructor is called
    }
    return 0;
}
```

Output:

```
Testing RVO:
Widget()
Testing NRVO:
Widget()
Testing non-RVO:
Widget()
Widget(Widget&&)
```

## 7.5 Type Erasure

Type erasure is a programming technique that lets you hide ("erase") concrete types behind a single abstract interface while preserving value semantics and often runtime polymorphism. It combines templates (compile-time flexibility) with a small amount of runtime indirection (virtual dispatch or function pointers) to provide a uniform API for many different types.

**Usages in std libraries:**

* `std::function`: Type erases callable objects.
* `std::any`: Type erases any type.
* `std::shared_ptr<void>`/`std::unique_ptr<void, Deleter>`: Smart pointers can erase the exact type being managed, but still know how to delete it.
* `std::thread`: The constructor takes any callable, then type erases it for execution.

**Common Ways to Achieve Type Erasure:**

* Using Templates + Virtual Functions (Classic OOP Polymorphism)
    ```cpp
    #include <iostream>
    #include <memory>
    #include <vector>

    class Drawable {
    public:
        // public interface
        void draw() const { ptr_->draw(); }

        // constructors from any type that has draw() const
        template <typename T>
        Drawable(T x) : ptr_(std::make_unique<Wrapper<T>>(std::move(x))) {}

    private:
        struct Interface {
            virtual ~Interface() = default;
            virtual void draw() const = 0;
        };

        template <typename T>
        struct Wrapper : Interface {
            T data;
            Wrapper(T x) : data(std::move(x)) {}
            void draw() const override { data.draw(); }
        };

        std::unique_ptr<Interface> ptr_;
    };

    struct Circle {
        void draw() const { std::cout << "Circle\n"; }
    };
    struct Sprite {
        void draw() const { std::cout << "Sprite\n"; }
    };

    int main() {
        std::vector<Drawable> items;
        items.emplace_back(Circle{});
        items.emplace_back(Sprite{});

        for (const auto& d : items) d.draw();
    }
    ```

* Using Function Pointers (like `std::function`)
    ```cpp
    #include <iostream>
    #include <memory>
    #include <utility>

    class AnyCallable {
        struct Concept {
            void* object;
            void (*invoke)(void*);
            void (*destroy)(void*);
        };

        Concept c;

    public:
        template <typename F>
        AnyCallable(F f) {
            using Fn = std::decay_t<F>;
            Fn* fn = new Fn(std::move(f));
            c.object = fn;
            c.invoke = [](void* obj) { (*static_cast<Fn*>(obj))(); };
            c.destroy = [](void* obj) { delete static_cast<Fn*>(obj); };
        }

        void operator()() { c.invoke(c.object); }

        ~AnyCallable() { c.destroy(c.object); }
    };

    int main() {
        AnyCallable f1 = [] { std::cout << "Hello\n"; };
        AnyCallable f2 = [] { std::cout << "World\n"; };
        f1(); // Hello
        f2(); // World
    }
    ```

## 7.6 Implicit Type Conversions

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

**`pointer stability` is usually used to describe containers. When we say a container has `pointer stability`, it means that once an element is added to the container and before it is removed, its memory address does not change. In other words, the memory address of the element will not be affected by operations such as insertion, deletion, resizing, or other modifications to the container.**

* References are also affected by this property, since a reference is essentially syntactic sugar for a pointer.

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

**Levels of `exception safety`:**

1. `No-throw guarantee`: Guarantees that no exceptions will be thrown outward. Exceptions may occur inside the method but will be properly handled.
2. `Strong exception safety`: Exceptions may be thrown, but the operation guarantees no side effects — all objects will be restored to their state prior to the call.
3. `Basic exception safety`: Exceptions may be thrown, and failed operations may cause side effects, but all invariants will be preserved. Any stored data will remain valid, though possibly different from the original. Resource leaks (including memory leaks) are usually excluded through an invariant that all resources are considered and managed.
4. `No exception safety`: No guarantees of exception safety are provided.

## 8.3 RAII

`RAII, Resource Acquisition Is Initialization` means "resource acquisition is initialization." Typical examples include `std::lock_guard` and `defer`.
Simply put, resources are initialized in the constructor of an object and released in its destructor. Since constructor and destructor calls are automatically inserted by the compiler, this reduces the mental burden on developers.

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

### 8.3.1 Destructor Behavior

**Key Concepts**

* RAII (Resource Acquisition Is Initialization): The DeferOp class is an RAII wrapper that executes a provided function (or lambda) when its destructor is called. This is typically used for cleanup or deferred execution.
* Destructor Behavior: In C++, destructors are implicitly called when an object goes out of scope. If an exception is thrown elsewhere in the scope, the stack unwinds, and destructors of automatic objects are invoked.
* Exception Handling: A try-catch block catches exceptions thrown within its scope, but how exceptions interact with destructors is critical here.

```cpp
#include <functional>
#include <iostream>
#include <memory>
#include <utility>

template <class DeferFunction>
class DeferOp {
public:
    explicit DeferOp(DeferFunction func) : _func(std::move(func)) {}

    ~DeferOp() noexcept(false) { _func(); };

private:
    DeferFunction _func;
};

void normal_func() {
    std::cout << "hello world" << std::endl;
    throw std::runtime_error("normal_func");
}

void raii_func() {
    DeferOp([]() {
        std::cout << "hello world" << std::endl;
        throw std::runtime_error("raii_func");
    });
}

int main() {
    try {
        normal_func();
    } catch (...) {
        std::cerr << "normal_func exception caught" << std::endl;
    }
    try {
        raii_func();
    } catch (...) {
        std::cerr << "raii_func exception caught" << std::endl;
    }
    return 0;
}
```

**Code Breakdown**

* `normal_func`
    * Executes `std::cout << "hello world" << std::endl;`.
    * Throws a `std::runtime_error`.
    * This exception is thrown directly in the `try` block in `main`, so it's caught by the corresponding `catch (...)` block, printing `"normal_func exception caught"`.
* `raii_func`
    * Creates a `DeferOp` object with a lambda: `[]() { std::cout << "hello world" << std::endl; throw std::runtime_error("raii_func"); }`.
    * The lambda isn't executed immediately—it's stored in the `DeferOp` object's `_func` member.
    * When `raii_func` returns, the `DeferOp` object goes out of scope, and its destructor `~DeferOp()` is called.
    * The destructor invokes `_func()`, which executes the lambda, printing `"hello world"` and throwing `the std::runtime_error`.

**Why the Exception Isn't Caught**: The key issue lies in when and where the exception is thrown in raii_func:

* The `try` block in `main` surrounds the call to `raii_func()`.
* However, no exception is thrown during the execution of `raii_func()` itself—`raii_func` simply constructs the `DeferOp` object and returns.
* The exception is thrown later, in the destructor of `DeferOp`, after the `try` block has already completed and the stack is unwinding (or after the function has exited normally).
* At this point, the `try-catch` block in `main` is no longer active because the scope of the `try` block has ended. Exceptions thrown during stack unwinding or outside the `try` block aren't caught by that block.

**In C++, if an exception is thrown while the stack is already unwinding due to another exception—or outside of an active `try` block—it results in undefined behavior or program termination unless caught by a higher-level `try-catch`. In this case, there's no prior exception causing unwinding, but the exception still occurs outside the `try` block's scope.**

**And there's a solution: add `noexcept(false)` to destructor of `DeferOp`, the exception can be catched as expected.**

```cpp
#include <functional>
#include <iostream>
#include <memory>
#include <utility>

template <class DeferFunction>
class DeferOp {
public:
    explicit DeferOp(DeferFunction func) : _func(std::move(func)) {}

    ~DeferOp() noexcept(false) { _func(); };

private:
    DeferFunction _func;
};

void normal_func() {
    std::cout << "hello world" << std::endl;
    throw std::runtime_error("normal_func");
}

void raii_func() {
    DeferOp([]() {
        std::cout << "hello world" << std::endl;
        throw std::runtime_error("raii_func");
    });
}

int main() {
    try {
        normal_func();
    } catch (...) {
        std::cerr << "normal_func exception caught" << std::endl;
    }
    try {
        raii_func();
    } catch (...) {
        std::cerr << "raii_func exception caught" << std::endl;
    }
    return 0;
}
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
    ASTBinaryExpression(std::string op_, ASTNode* lhs_, ASTNode* rhs_) : ASTNode({lhs_, rhs_}), op(std::move(op_)) {}
    ASTType getType() override { return ASTType::BinaryExpression; }
    const std::string op;
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

#define VISITOR_DEF(TYPE)                              \
    virtual R visit##TYPE(ASTNode* node, C& context) { \
        return visit(node, context);                   \
    }
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
        context.append(" " + binary->op + " ");
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

# 10 Assorted

1. [Definitions and ODR (One Definition Rule)](https://en.cppreference.com/w/cpp/language/definition.html)

# 11 Tips

## 11.1 How to Choose Function Parameter Type

For given type T, you can use:

1. `const T&`: Avoid copy.
1. `T&&`: The function should take ownership of this parameter.
1. `T&`: The function may modify this parameter.
1. `T`: A copy of the parameter. (Not recommend)
1. `T*`: Used when this parameter is treated as output of the function.
1. `std::shared_ptr<T>`/`std::unique_ptr<T>`: Used when the lifetime of object should be extended or transfered.

### 11.1.1 How to Choose Constructor Parameter Type

Things change when it come to constructor:

1. `const T&`: Often used when the type cannot be moved.
1. `T&&`: Often used when the type can be moved.
1. `T&`: Rarely use.
1. **`T`: Recommended, used for both copy or moved.**
1. `T*`: Rarely use.

```cpp
#include <iostream>

class Foo1 {
public:
    Foo1() = default;
    Foo1(Foo1&) { std::cout << "Foo1(Foo1&)" << std::endl; }
    Foo1(Foo1&&) { std::cout << "Foo1(Foo1&&)" << std::endl; }
};
class Foo2 {
public:
    Foo2() = default;
    Foo2(Foo2&) { std::cout << "Foo2(Foo2&)" << std::endl; }
    Foo2(Foo2&&) { std::cout << "Foo2(Foo2&&)" << std::endl; }
};

class Bar {
public:
    Bar(Foo1 f1, Foo2 f2) : foo1(f1), foo2(std::move(f2)) {}

private:
    Foo1 foo1;
    Foo2 foo2;
};

int main() {
    Foo1 foo1;
    Foo2 foo2;
    std::cout << "Bar1" << std::endl;
    Bar bar1(foo1, std::move(foo2));
    std::cout << "Bar2" << std::endl;
    Bar bar2(std::move(foo1), std::move(foo2));
    return 0;
}
```

Output:

```
Bar1
Foo2(Foo2&&)
Foo1(Foo1&)
Foo1(Foo1&)
Foo2(Foo2&&)
Bar2
Foo2(Foo2&&)
Foo1(Foo1&&)
Foo1(Foo1&)
Foo2(Foo2&&)
```

## 11.2 Variable-length Array

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

# 12 FAQ

## 12.1 Why is it unnecessary to specify the size when releasing memory with free and delete

[How does free know how much to free?](https://stackoverflow.com/questions/1518711/how-does-free-know-how-much-to-free)

When allocating memory, in addition to the requested memory, a `header` is also allocated to store certain information, such as:

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

## 12.2 Do parameter types require lvalue or rvalue references

## 12.3 Does the return type require lvalue or rvalue references

# 13 Reference

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
