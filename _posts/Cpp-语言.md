---
title: Cpp-语言
date: 2021-09-06 10:53:48
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 版本新特性

## 1.1 c++11新特性

1. `auto`与`decltype`类型推导
1. `default`与`delete`函数
1. `final`与`override`
1. 尾置返回类型
1. 右值引用
1. 移动构造函数与移动赋值运算符
1. 有作⽤域的枚举
1. `constexpr`与字⾯类型
1. 扩展「初始化列表」的适⽤范围
1. 委托与继承的构造函数
1. 花括号或等号初始化器
1. 空指针`nullptr`
1. `long long`
1. `char16_t`与`char32_t`
1. `using`定义类型别名
1. 变长参数模板
1. 推⼴的（⾮平凡）联合体
1. 推⼴的`POD`（平凡类型与标准布局类型）
1. `Unicode`字符串字⾯量
1. ⽤户定义字⾯量
1. 属性，用于提供额外信息
1. `Lambda`表达式
1. `noexcept`说明符与`noexcept`运算符
1. `alignof`与`alignas`
1. 多线程内存模型
1. 线程局部存储，`thread_local`关键字
1. `GC`接口，`declare_reachable`与`undeclare_reachable`（并未实现）
1. 基于范围的for循环
1. `static_assert`
1. 智能指针

## 1.2 c++14新特性

1. 变量模板
1. 泛型`Lambda`
1. `Lambda`初始化捕获右值对象
1. `new/delete`消除
1. `constexpr`函数上放松的限制
1. ⼆进制字⾯量，`0b101010`
1. 数字分隔符，`100'0000`
1. 函数的返回类型推导
1. 带默认成员初始化器的聚合类
1. `decltype(auto)`

## 1.3 c++17新特性

1. 折叠表达式
1. 类模板实参推导
1. `auto`占位的⾮类型模板形参
1. 编译期的`constexpr if`语句
1. 内联变量，`inline`变量
1. 结构化绑定
1. `if/switch`语句的变量初始化
1. `u8-char`
1. 简化的嵌套命名空间
1. `using`声明语句可以声明多个名称
1. 将`noexcept`作为类型系统的一部分
1. 新的求值顺序规则
1. 强制的复制消除
1. `Lambda`表达式捕获`*this`
1. `constexpr`的`Lambda`表达式
1. 属性命名空间不必重复
1. 新属性`[[fallthrough]]`、`[[nodiscard]]`和`[[maybe_unused]]`
1. `__has_include`

## 1.4 C++20新特性

1. 特性测试宏
1. 三路比较运算符`<=>`
1. 范围`for`中的初始化语句和初始化器
1. `char8_t`
1. `[[no_unique_address]]`
1. `[[likely]]`与`[[unlikely]]`
1. `Lambda`初始化捕获中的包展开
1. 移除了在多种上下文语境中，使用`typename`关键字以消除类型歧义的要求
1. `consteval`、`constinit`
1. 更为宽松的`constexpr`要求
1. 规定有符号整数以补码实现
1. 使用圆括号的聚合初始化
1. 协程
1. 模块
1. 限定与概念(concepts)
1. 缩略函数模板
1. 数组长度推导

# 2 宏

## 2.1 预定义宏

**`ANSI C`标准中有几个标准预定义宏（也是常用的）：**

* `__LINE__`：在源代码中插入当前源代码行号
* `__FILE__`：在源文件中插入当前源文件名
* `__DATE__`：在源文件中插入当前的编译日期
* `__TIME__`：在源文件中插入当前编译时间
* `__STDC__`：当要求程序严格遵循`ANSI C`标准时该标识被赋值为1
* `__cplusplus`：当编写C++程序时该标识符被定义

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

# 3 关键字

## 3.1 const

默认状态下，`const`对象仅在文件内有效。编译器将在编译过程中把用到该变量的地方都替代成对应的值，也就是说，编译器会找到代码中所有用到该`const`变量的地方，然后将其替换成定义的值

为了执行上述替换，编译器必须知道变量的初始值，如果程序包含多个文件，则每个用了`const`对象的文件都必须能访问到它的初始值才行。要做到这一点，就必须在每一个用到该变量的文件中都对它有定义（将定义该`const`变量的语句放在头文件中，然后用到该变量的源文件包含头文件即可），为了支持这一用法，同时避免对同一变量的重复定义，默认情况下`const`被设定为尽在文件内有效（`const`的全局变量，其实只是在每个文件中都定义了一边而已）

有时候出现这样的情况：`const`变量的初始值不是一个常量表达式，但又确实有必要在文件间共享。这种情况下，我们不希望编译器为每个文件生成独立的变量，相反，我们想让这类`const`对象像其他对象一样工作。**即：在一个文件中定义`const`，在多个文件中声明并使用它，无论声明还是定 义都添加`extern`关键字**

* `.h`文件中：`extern const int a;`
* `.cpp`文件中：`extern const int a=f();`

### 3.1.1 顶层/底层const

顶层的`const`可以表示任意的对象是常量（包括指针，不包括引用，因为引用本身不是对象，没法指定顶层的`const`属性）

只有指针的`const`属性既可以是顶层又可以是底层，例如：

```cpp
const int i = 1;
const int *const pi = &i;
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

`const`关键字修饰的成员函数，不能修改当前类的任何字段的值，如果字段是对象类型，也不能调用非const修饰的成员方法

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

## 3.2 类型推断

### 3.2.1 auto

**`auto`会忽略顶层`const`，保留底层的`const`，但是当设置一个类型为`auto`的引用时，初始值中的顶层常量属性仍然保留**

### 3.2.2 decltype

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

### 3.2.3 typeof

**非c++标准**

### 3.2.4 typeid

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

## 3.3 类型转换

### 3.3.1 static_cast

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

### 3.3.2 dynamic_cast

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

### 3.3.3 const_cast

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

### 3.3.4 reinterpret_cast

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

## 3.4 extern/static

**`extern`：告诉编译器，这个符号在别的编译单元里定义，也就是要把这个符号放到未解决符号表里去（外部链接）**

**`static`：如果该关键字位于全局函数或者变量声明的前面，表示该编译单元不 导出这个函数/变量的符号，因此无法再别的编译单元里使用。(内部链接)。如果 `static`是局部变量，则该变量的存储方式和全局变量一样，但仍然不导出符号**

### 3.4.1 共享全局变量

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

## 3.5 throw与异常

throw关键字可以抛出任何对象，例如可以抛出一个整数

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

# 4 模板

1. 模板形参可以是一个类型或者枚举
1. 模板成员默认不认为是类型，用`typename`消除歧义。例如`T::type* ptr`：如果`type`是个类型，那么这个是声明；如果`type`不是类型，那么这个是乘法表达式。因此这里存在一个歧义，而且编译器默认认为不是类型

## 4.1 非类型模板参数

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

## 4.2 模板形参无法推断

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

## 4.3 typename消除歧义

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

## 4.4 template消除歧义

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

# 5 `__attribute__`

[Compiler-specific Features](https://www.keil.com/support/man/docs/armcc/armcc_chr1359124965789.htm)

# 6 ASM

[gcc-online-docs](https://gcc.gnu.org/onlinedocs/gcc/)

## 6.1 Basic Asm

## 6.2 Extended Asm

GCC设计了一种特有的嵌入方式，它规定了汇编代码嵌入的形式和嵌入汇编代码需要由哪几个部分组成，格式如下：

* 汇编语句模板是必须的，其余三部分是可选的

```cpp
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

# 7 Tips

## 7.1 如何在类中定义静态成员

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

## 7.2 初始化

### 7.2.1 初始化列表

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

### 7.2.2 各种初始化类型

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

## 7.3 指针

### 7.3.1 成员函数指针

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

## 7.4 placement new

`placement new`的功能就是在一个已经分配好的空间上，调用构造函数，创建一个对象

```c++
void *buf = // 在这里为buf分配内存
Class *pc = new (buf) Class();  
```

## 7.5 内存对齐

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

## 7.6 mock class

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

### 7.6.1 demo using cmake

# 8 参考

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
