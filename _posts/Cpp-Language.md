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

# 1 版本新特性

[modern-cpp-features](https://github.com/AnthonyCalandra/modern-cpp-features)

# 2 宏

## 2.1 预定义宏

**`ANSI C`标准中有几个标准预定义宏（也是常用的）：**

* `__LINE__`：在源代码中插入当前源代码行号
* `__FILE__`：在源文件中插入当前源文件名
* `__DATE__`：在源文件中插入当前的编译日期
* `__TIME__`：在源文件中插入当前编译时间
* `__STDC__`：当要求程序严格遵循`ANSI C`标准时该标识被赋值为1
* `__cplusplus`：当编写`C++`程序时该标识符被定义

## 2.2 语法

* `#`：字符串化操作符
* `##`：连接操作符
* `\`：续行操作符

## 2.3 do while(0) in macros

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

## 2.4 参考

* [C/C++ 宏编程的艺术](https://bot-man-jl.github.io/articles/?post=2020/Macro-Programming-Art)

# 3 关键字

## 3.1 const

默认状态下，`const`对象仅在文件内有效。编译器将在编译过程中把用到该变量的地方都替代成对应的值，也就是说，编译器会找到代码中所有用到该`const`变量的地方，然后将其替换成定义的值

为了执行上述替换，编译器必须知道变量的初始值，如果程序包含多个文件，则每个用了`const`对象的文件都必须能访问到它的初始值才行。要做到这一点，就必须在每一个用到该变量的文件中都对它有定义（将定义该`const`变量的语句放在头文件中，然后用到该变量的源文件包含头文件即可），为了支持这一用法，同时避免对同一变量的重复定义，默认情况下`const`被设定为尽在文件内有效（`const`的全局变量，其实只是在每个文件中都定义了一边而已）

有时候出现这样的情况：`const`变量的初始值不是一个常量表达式，但又确实有必要在文件间共享。这种情况下，我们不希望编译器为每个文件生成独立的变量，相反，我们想让这类`const`对象像其他对象一样工作。**即：在一个文件中定义`const`，在多个文件中声明并使用它，无论声明还是定 义都添加`extern`关键字**

* `.h`文件中：`extern const int a;`
* `.cpp`文件中：`extern const int a=f();`

### 3.1.1 顶层/底层const

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

### 3.1.2 const实参和形参

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

### 3.1.3 const成员

构造函数中显式初始化：在初始化部分进行初始化，而不能在函数体内初始化；如果没有显式初始化，就调用定义时的初始值进行初始化

### 3.1.4 const成员函数

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

## 3.2 类型长度

### 3.2.1 内存对齐

**内存对齐最最底层的原因是内存的IO是以`8`个字节`64bit`为单位进行的**

假如你指定要获取的是`0x0001-0x0008`，也是8字节，但是不是0开头的，内存需要怎么工作呢？没有好办法，内存只好先工作一次把`0x0000-0x0007`取出来，然后再把`0x0008-0x0015`取出来，把两次的结果都返回给你。CPU和内存IO的硬件限制导致没办法一次跨在两个数据宽度中间进行IO。这样你的应用程序就会变慢，算是计算机因为你不懂内存对齐而给你的一点点惩罚

**内存对齐规则**

1. **结构体第一个成员的偏移量`offset`为`0`，以后每个成员相对于结构体首地址的`offset`都是该成员大小与`有效对齐值`中较小那个的整数倍，如有需要编译器会在成员之间加上填充字节**
1. **结构体的总大小为`有效对齐值`的整数倍，如有需要编译器会在最末一个成员之后加上填充字节**
* **有效对齐值：是给定值`#pragma pack(n)`和结构体中最长数据类型长度中较小的那个。有效对齐值也叫对齐单位。gcc中默认`#pragma pack(4)`，可以通过预编译命令`#pragma pack(n)，n = 1,2,4,8,16`来改变这一系数**

**下面以一个例子来说明**

```sh
# 创建源文件
cat > main.cpp << 'EOF'
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
EOF

# 编译
gcc -o main main.cpp -lstdc++

# 执行
./main
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

### 3.2.2 sizeof

**`sizeof`用于获取对象的内存大小**

### 3.2.3 alignof

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

## 3.3 alignas

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

## 3.4 类型推断

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

## 3.5 类型转换

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

## 3.6 extern/static

**`extern`：告诉编译器，这个符号在别的编译单元里定义，也就是要把这个符号放到未解决符号表里去（外部链接）**

**`static`：如果该关键字位于全局函数或者变量声明的前面，表示该编译单元不 导出这个函数/变量的符号，因此无法再别的编译单元里使用。(内部链接)。如果 `static`是局部变量，则该变量的存储方式和全局变量一样，但仍然不导出符号**

### 3.6.1 共享全局变量

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

## 3.7 继承与多态

### 3.7.1 virtual

`virtual`关键词修饰的就是虚函数，虚函数的分派发生在运行时

1. 有虚函数的每个类，维护一个虚函数表
1. 有虚函数的类的对象，会包含一个指向该类的虚函数表的指针

![virtual-method-table](/images/Cpp-Language/virtual-method-table.jpeg)

* 图片出处：[c++虚指针和虚函数表](https://zhuanlan.zhihu.com/p/110144589)

### 3.7.2 final

`final`可以修饰类或者虚函数

* `final`修饰的类不能有子类，该类的所有虚函数不能被覆盖
* `final`修饰的虚函数，不能被覆盖
    * 只能在虚函数的声明处进行修饰

当用具体类型的指针或者引用调用`final`修饰的虚函数时，虚函数的调用可以被编译器直接优化掉

### 3.7.3 override

`override`可以修饰虚函数，表示对虚函数进行覆盖

* 只能在虚函数的声明处进行修饰
* 加不加`override`其实没有影响

## 3.8 volatile

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
#include <stdint.h>

void with_volatile(volatile int32_t* src, int32_t* target) {
    *target = *(src);
    *target = *(src);
    *target = *(src);
}

void without_volatile(int32_t* src, int32_t* target) {
    *target = *(src);
    *target = *(src);
    *target = *(src);
}
EOF

gcc -o volatile.o -c volatile.cpp -O3 -lstdc++ -std=gnu++17
objdump -drwCS volatile.o
```

**输出如下：**

```
volatile.o：     文件格式 elf64-x86-64

Disassembly of section .text:

0000000000000000 <with_volatile(int volatile*, int*)>:
   0:   8b 07                   mov    (%rdi),%eax
   2:   89 06                   mov    %eax,(%rsi)
   4:   8b 07                   mov    (%rdi),%eax
   6:   89 06                   mov    %eax,(%rsi)
   8:   8b 07                   mov    (%rdi),%eax
   a:   89 06                   mov    %eax,(%rsi)
   c:   c3                      retq
   d:   0f 1f 00                nopl   (%rax)

0000000000000010 <without_volatile(int*, int*)>:
  10:   8b 07                   mov    (%rdi),%eax
  12:   89 06                   mov    %eax,(%rsi)
  14:   c3                      retq
```

### 3.8.1 如何验证volatile不具备可见性

这个问题比较难直接验证，我们打算用一种间接的方式来验证。假设写操作和读操作的性能开销之比为`w/r = α`。开两个线程，分别循环执行读操作和写操作，读写分别执行`n`次。统计读线程，相邻两次读操作，读取数值不同的次数为`m`，`m/r=β`。

* 若满足可见性，那么`β`应该大致接近`1/α`

首先，测试`atomic`与`volatile`的读写性能

* 测试时，会有一个额外的线程对`atomic`或`volatile`变量进行持续的读写操作

```cpp
#include <benchmark/benchmark.h>

#include <atomic>
#include <thread>

std::atomic<uint64_t> atomic_value{0};
uint64_t volatile volatile_value = 0;

template <typename T>
static void random_write(T& value, std::atomic<bool>& stop) {
    uint32_t tmp = 1;
    while (!stop) {
        value = tmp;
        tmp++;
    }
}

template <typename T>
static void random_read(T& value, std::atomic<bool>& stop) {
    uint64_t tmp;
    while (!stop) {
        benchmark::DoNotOptimize(tmp = value);
    }
}

static void atomic_read(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { random_write(atomic_value, stop); });
    for (auto _ : state) {
        benchmark::DoNotOptimize(tmp = atomic_value);
    }
    stop = true;
    t.join();
}

static void atomic_write(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { random_read(atomic_value, stop); });
    for (auto _ : state) {
        benchmark::DoNotOptimize(atomic_value = tmp);
        tmp++;
    }
    stop = true;
    t.join();
}

static void volatile_read(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { random_write(volatile_value, stop); });
    for (auto _ : state) {
        benchmark::DoNotOptimize(tmp = volatile_value);
    }
    stop = true;
    t.join();
}

static void volatile_write(benchmark::State& state) {
    uint64_t tmp = 0;
    std::atomic<bool> stop{false};
    std::thread t([&]() { random_read(volatile_value, stop); });
    for (auto _ : state) {
        benchmark::DoNotOptimize(volatile_value = tmp);
        tmp++;
    }
    stop = true;
    t.join();
}

BENCHMARK(atomic_read);
BENCHMARK(atomic_write);
BENCHMARK(volatile_read);
BENCHMARK(volatile_write);

BENCHMARK_MAIN();
```

结果如下：

* 对于`atomic<uint64_t>`，`α = 31.8/1.01 = 31.49`
* 对于`volatile`，`α = 0.794/0.622 = 1.28`

```
---------------------------------------------------------
Benchmark               Time             CPU   Iterations
---------------------------------------------------------
atomic_read          1.01 ns         1.01 ns    617176522
atomic_write         31.8 ns         31.8 ns     22684714
volatile_read       0.622 ns        0.622 ns   1000000000
volatile_write      0.794 ns        0.793 ns    990971682
```

测试程序如下：

```cpp
#include <atomic>
#include <iostream>
#include <thread>

constexpr uint64_t size = 1000000000;

template <class Tp>
inline void DoNotOptimize(Tp const& value) {
    asm volatile("" : : "r,m"(value) : "memory");
}

template <typename T>
void test(T& value, const std::string& description) {
    std::thread write_thread([&]() {
        for (uint64_t i = 0; i < size; i++) {
            DoNotOptimize(value = i);
        }
    });

    std::thread read_thread([&]() {
        uint64_t prev_value = 0;
        uint64_t non_diff_cnt = 0;
        uint64_t diff_cnt = 0;
        uint64_t cur_value;
        for (uint64_t i = 0; i < size; i++) {
            DoNotOptimize(cur_value = value);

            // These two statements have little overhead which can be ignored if enable -03
            cur_value == prev_value ? non_diff_cnt++ : diff_cnt++;
            prev_value = cur_value;
        }
        std::cout << description << ", β=" << static_cast<double>(diff_cnt) / size << std::endl;
    });
    write_thread.join();
    read_thread.join();
}

int main() {
    {
        std::atomic<uint64_t> value = 0;
        test(value, "atomic");
    }
    {
        uint64_t volatile value = 0;
        test(value, "volatile");
    }
    return 0;
}
```

结果如下：

* 对于`atomic`而言，预测结果是`1/α = 1/31.49 ≈ 0.032`，实际为`0.025`，符合预测
* 对于`volatile`而言，预测结果是`1/α = 1/1.28 ≈ 0.781`，实际为`0.006`，相距甚远。也就是说，写操作写的值，读操作大概率读不到，即不满足可见性

```
atomic, β=0.0246502
volatile, β=0.00602403
```

**如果用Java进行上述等价验证，会发现实际结果与预期吻合，这里不再赘述**

## 3.9 constexpr

### 3.9.1 if constexpr

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

## 3.10 static_assert

编译期断言

```cpp
int main() {
    static_assert(sizeof(int) == 4, "test1");
    static_assert(sizeof(long) > 8, "test2");
    return 0;
}
```

## 3.11 noexcept

用于声明函数不会抛异常，声明和实现都必须同时包含

```cpp
class A {
public:
    void func() noexcept;
};

void A::func() noexcept {}
```

## 3.12 throw与异常

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

## 3.13 placement new

`placement new`的功能就是在一个已经分配好的空间上，调用构造函数，创建一个对象

```c++
void *buf = // 在这里为buf分配内存
Class *pc = new (buf) Class();  
```

# 4 模板

## 4.1 模板类型

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

## 4.2 形参包

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

## 4.3 折叠表达式

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

形参包折叠的示例：

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

## 4.4 如何遍历形参包

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

## 4.5 非类型模板参数

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

## 4.6 模板形参无法推断

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

## 4.7 typename消除歧义

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

## 4.8 template消除歧义

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

## 4.9 template参数列表中定义类型别名

语法上，我们是无法在template的参数列表中定义别名的（无法使用`using`）。但是我们可以通过定义有默认值的类型形参来实现类似类型别名的功能，如下：

```cpp
template <typename HashMap, typename KeyType = typename HashMap::key_type,
          typename ValueType = typename HashMap::mapped_type>
ValueType& get(HashMap& map, const KeyType& key) {
    return map[key];
}
```

## 4.10 非模板子类访问模板父类中的成员

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

## 4.11 模板子类访问模板父类中的成员

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

## 4.12 模板作为模板形参

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

## 4.13 模板的定义与实现分离

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

## 4.14 [CRTP](https://en.wikipedia.org/wiki/Curiously_recurring_template_pattern)

`CRTP`的全称是`Curious Recurring Template Pattern`

### 4.14.1 Static Polymorphism

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

### 4.14.2 Object Counter

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

### 4.14.3 Polymorphic Chaining

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

### 4.14.4 Polymorphic Copy Construction

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

# 5 `__attribute__`

[Compiler-specific Features](https://www.keil.com/support/man/docs/armcc/armcc_chr1359124965789.htm)

## 5.1 aligned

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

# 6 ASM

[gcc-online-docs](https://gcc.gnu.org/onlinedocs/gcc/)

## 6.1 Basic Asm

## 6.2 [Extended Asm](https://gcc.gnu.org/onlinedocs/gcc/Extended-Asm.html)

GCC设计了一种特有的嵌入方式，它规定了汇编代码嵌入的形式和嵌入汇编代码需要由哪几个部分组成，格式如下：

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

# 7 Policy

## 7.1 Pointer Stability

**`pointer stability`通常用于描述容器。当我们说一个容器是`pointer stability`时，是指，当某个元素添加到容器之后、从容器删除之前，该元素的内存地址不变，也就是说，该元素的内存地址，不会受到容器的添加删除元素、扩缩容、或者其他操作影响**

**[absl](https://abseil.io/docs/cpp/guides/container)**

| 容器 | 是否`pointer stability` |
|:--|:--|
| `std::vector` | ❎ |
| `std::list` | ✅ |
| `std::map` | ✅ |
| `std::unordered_map` | ✅ |
| `std::set` | ✅ |
| `std::unordered_set` | ✅ |
| `absl::flat_hash_map` | ❎ |
| `absl::flat_hash_set` | ❎ |
| `absl::node_hash_map` | ✅ |
| `absl::node_hash_set` | ✅ |
| `phmap::flat_hash_map` | ❎ |
| `phmap::flat_hash_set` | ❎ |
| `phmap::node_hash_map` | ✅ |
| `phmap::node_hash_set` | ✅ |

## 7.2 Exception Safe

[Wiki-Exception safety](https://en.wikipedia.org/wiki/Exception_safety)

**`exception safety`的几个级别：**

1. `No-throw guarantee`：承诺不会对外抛出任何异常。方法内部可能会抛异常，但都会被正确处理
1. `Strong exception safety`：可能会抛出异常，但是承诺不会有副作用，所有对象都会恢复到调用方法时的初始状态
1. `Basic exception safety`：可能会抛出异常，操作失败的部分可能会导致副作用，但所有不变量都会被保留。任何存储的数据都将包含可能与原始值不同的有效值。资源泄漏（包括内存泄漏）通常通过一个声明所有资源都被考虑和管理的不变量来排除
1. `No exception safety`：不承诺异常安全

## 7.3 RAII

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

# 8 Tips

## 8.1 如何在类中定义静态成员

**在类中声明静态成员，在类外定义（赋值）静态成员，示例如下：**

```sh
# 创建源文件
cat > main.cpp << 'EOF'
#include <iostream>

class Demo {
public:
    static size_t BUFFER_LEN;
};

size_t Demo::BUFFER_LEN = 5;

int main() {
    std::cout << Demo::BUFFER_LEN << std::endl;
}
EOF

# 编译
gcc -o main main.cpp -lstdc++ -Wall

# 执行
./main
```

## 8.2 初始化

### 8.2.1 初始化列表

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

### 8.2.2 各种初始化类型

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

## 8.3 指针

### 8.3.1 成员函数指针

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

## 8.4 引用

### 8.4.1 引用赋值

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

## 8.5 mock class

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

# 9 FAQ

## 9.1 为什么free和delete释放内存时不用指定大小

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

## 9.2 形参类型是否需要左右值引用

## 9.3 返回类型是否需要左右值引用

# 10 参考

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
