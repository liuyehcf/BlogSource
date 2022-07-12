---
title: Cpp-元编程
date: 2021-09-06 09:20:53
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

**本文转载摘录自[浅谈 C++ 元编程](https://bot-man-jl.github.io/articles/?post=2017/Cpp-Metaprogramming#%E4%BB%80%E4%B9%88%E6%98%AF%E5%85%83%E7%BC%96%E7%A8%8B)**

# 1 引言

## 1.1 什么是元编程

**元编程（`metaprogramming`）通过操作程序实体（`program entity`），在编译时（`compile time`）计算出运行时（`runtime`）需要的常数、类型、代码的方法**

一般的编程是通过直接编写程序（`program`），通过编译器编译（`compile`），产生目标代码，并用于运行时执行。与普通的编程不同，元编程则是借助语言提供的模板（`template`）机制，通过编译器推导（`deduce`），在编译时生成程序。元编程经过编译器推导得到的程序，再进一步通过编译器编译，产生最终的目标代码

因此，元编程又被成为两级编程（`two-level programming`），生成式编程（`generative programming`）或模板元编程（`template metaprogramming`）

## 1.2 元编程在C++中的位置

**`C++`语言 = C语言的超集 + 抽象机制 + 标准库**

**`C++`的抽象机制（`abstraction mechanisms`）主要有两种：**

1. 面向对象编程（`object-oriented programming`）
1. 模板编程（`template programming`）

为了实现面向对象编程，`C++`提供了类（`class`），用`C++`的已有类型（`type`）构造出新的类型。而在模板编程方面，`C++`提供了模板（`template`），以一种直观的方式表示通用概念（`general concept`）

**模板编程的应用主要有两种：**

1. 泛型编程（`generic programming`）
1. 元编程（`meta-programming`）

前者注重于通用概念的抽象，设计通用的类型或算法（`algorithm`），不需要过于关心编译器如何生成具体的代码

而后者注重于设计模板推导时的选择（`selection`）和迭代（`iteration`），通过模板技巧设计程序

## 1.3 C++元编程的历史

## 1.4 元编程的语言支持

`C++`的元编程主要依赖于语言提供的模板机制。除了模板，现代`C++`还允许使用`constexpr`函数进行常量计算。由于`constexpr`函数的功能有限，递归调用层数和计算次数还受编译器限制，而且编译性能较差，所以目前的元编程程序主要基于模板。**这一部分主要总结`C++`模板机制相关的语言基础，包括狭义的模板和泛型`lambda`表达式**

### 1.4.1 狭义的模板

**目前最新的`C++`将模板分成了4类：**

1. 类模板（`class template`）
1. 函数模板（`function template`）
1. 别名模板（`alias template`）
1. 变量模板（`variable template`）

前两者能产生新的类型，属于类型构造器（`type constructor`）；而后两者是`C++`为前两者补充的简化记法，属于语法糖（`syntactic sugar`）

类模板和函数模板分别用于定义具有相似功能的类和函数（`function`），是泛型中对类型和算法的抽象。在标准库中，容器（`container`）和函数都是类模板和函数模板的应用

别名模板和变量模板分别在`C++ 11`和`C++ 14`引入，分别提供了具有模板特性的类型别名（`type alias`）和常量（`constant`）的简记方法。前者类模板的嵌套类等方法实现，后者则可以通过constexpr函数、类模板的静态成员、函数模板的返回值等方法实现。例如，`C++ 14`中的别名模板`std::enable_if_t<T>`等价于`typename std::enable_if<T>::type`，`C++ 17`中的变量模板`std::is_same<T, U>`等价于`std::is_same<T, U>::value`。尽管这两类模板不是必须的，但一方面可以增加程序的可读性，另一方面可以提高模板的编译性能

**`C++`中的模板参数（`template parameter/argument`）可以分为三种：**

1. 值参数
1. 类型参数
1. 模板参数

从`C++ 11`开始，`C++`支持了变长模板（`variadic template`）：模板参数的个数可以不确定，变长参数折叠为一个参数包（`parameter pack`），使用时通过编译时迭代，遍历各个参数。标准库中的元组（`tuple`），`std::tuple`就是变长模板的一个应用（元组的类型参数是不定长的，可以用`template<typename... Ts>`匹配）

尽管模板参数也可以当作一般的类型参数进行传递（模板也是一个类型），但之所以单独提出来，是因为它可以实现对传入模板的参数匹配。代码8使用`std::tuple`作为参数，然后通过匹配的方法，提取`std::tuple`内部的变长参数

特化（`specialization`）类似于函数的重载（`overload`），即给出全部模板参数取值（完全特化）或部分模板参数取值（部分特化）的模板实现。实例化（`instantiation`）类似于函数的绑定（`binding`），是编译器根据参数的个数和类型，判断使用哪个重载的过程。由于函数和模板的重载具有相似性，所以他们的参数重载规则（`overloading rule`）也是相似的

### 1.4.2 泛型 lambda 表达式

由于`C++`不允许在函数内定义模板，有时候为了实现函数内的局部特殊功能，需要在函数外专门定义一个模板。一方面，这导致了代码结构松散，不易于维护；另一方面，使用模板时，需要传递特定的上下文（`context`），不易于复用。（类似于C语言里的回调机制，不能在函数内定义回调函数，需要通过参数传递上下文。）

为此，`C++ 14`引入了泛型`lambda`表达式（`generic lambda expression`）：一方面，能像`C++ 11`引入的`lambda`表达式一样，在函数内构造闭包（`closure`），避免在函数外定义函数内使用的局部功能；另一方面，能实现函数模板的功能，允许传递任意类型的参数

# 2 元编程的基本演算

`C++`的模板机制仅仅提供了纯函数（`pure functional`）的方法，即不支持变量，且所有的推导必须在编译时完成。但是`C++`中提供的模板是图灵完备（`turing complete`）的，所以可以使用模板实现完整的元编程

元编程的基本演算规则（`calculus rule`）有两种：

1. 编译时测试（`compile-time test`）
1. 编译时迭代（`compile-time iteration`）

分别实现了控制结构（`control structure`）中的选择（`selection`）和迭代（`iteration`）。基于这两种基本的演算方法，可以完成更复杂的演算

另外，元编程中还常用模板参数传递不同的策略（`policy`），从而实现依赖注入（`dependency injection`）和控制反转（`Inversion of Control`）。例如，`std::vector<typename T, typename Allocator = std::allocator<T>>`允许传递`Allocator`实现自定义内存分配

## 2.1 编译时测试

编译时测试相当于面向过程编程中的选择语句（`selection statement`），可以实现`if-else/switch`的选择逻辑

在`C++ 17`之前，编译时测试是通过模板的实例化和特化实现的，每次找到最特殊的模板进行匹配。而`C++ 17`提出了使用`constexpr-if`的编译时测试方法

### 2.1.1 测试表达式

类似于静态断言（`static assert`），编译时测试的对象是常量表达式（`constexpr`），即编译时能得出结果的表达式。以不同的常量表达式作为参数，可以构造各种需要的模板重载。例如，代码1演示了如何构造谓词（`predicate`）`isZero<Val>`，编译时判断`Val`是不是`0`

**代码1：**

```cpp
template <unsigned Val>
struct _isZero {
    constexpr static bool value = false;
};

template <>
struct _isZero<0> {
    constexpr static bool value = true;
};

template <unsigned Val>
constexpr bool isZero = _isZero<Val>::value;

static_assert(!isZero<1>, "compile error");
static_assert(isZero<0>, "compile error");
```

### 2.1.2 测试类型

**在元编程的很多应用场景中，需要对类型进行测试，即对不同的类型实现不同的功能。而常见的测试类型又分为两种：**

* **判断一个类型是否为特定的类型：**
    * 可以通过对模板的特化直接实现
* **判断一个类型是否满足某些条件：**
    * 可以通过替换失败不是错误（`SFINAE, Substitution Failure Is Not An Error`）规则进行最优匹配
    * 还能通过标签派发（`tag dispatch`）匹配可枚举的有限情况（例如，`std::advance<Iter>`根据`std::iterator_traits<Iter>::iterator_category`选择迭代器类型`Iter`支持的实现方式）

**为了更好的支持`SFINAE`，`C++ 11`的`<type_traits>`除了提供类型检查的谓词模板`is_*/has_*`，还提供了两个重要的辅助模板：**

1. `std::enable_if`将对条件的判断转化为常量表达式，类似「测试表达式」小节实现重载的选择（但需要添加一个冗余的函数参数/函数返回值/模板参数）
1. `std::void_t`直接检查依赖的成员/函数是否存在，不存在则无法重载（可以用于构造谓词，再通过`std::enable_if`判断条件）

是否为特定的类型的判断，类似于代码1，将`unsigned Val`改为`typename Type`，并把传入的模板参数由值参数改为类型参数，根据最优原则匹配重载

是否满足某些条件的判断，在代码2中，展示了如何将C语言的基本类型数据，转换为`std::string`的函数`ToString`。代码具体分为三个部分：

1. 首先定义三个变量模板`isNum/isStr/isBad`，分别对应了三个类型条件的谓词（使用了`<type_traits>`中的`std::is_arithmetic`和`std::is_same`）
1. 然后根据`SFINAE`规则，使用`std::enable_if`重载函数`ToString`，分别对应了数值、C风格字符串和非法类型
1. 在前两个重载中，分别调用`std::to_string`和`std::string`构造函数；在最后一个重载中，静态断言直接报错

**代码2：**

```cpp
template <typename T>
constexpr bool isNum = std::is_arithmetic<T>::value;

template <typename T>
constexpr bool isStr = std::is_same<T, const char *>::value;

template <typename T>
constexpr bool isBad = !isNum<T> && !isStr<T>;

template <typename T>
std::enable_if_t<isNum<T>, std::string> ToString(T num) {
    return std::to_string(num);
}

template <typename T>
std::enable_if_t<isStr<T>, std::string> ToString(T str) {
    return std::string(str);
}

template <typename T>
std::enable_if_t<isBad<T>, std::string> ToString(T bad) {
    static_assert(sizeof(T) == 0, "neither Num nor Str");
}

auto a = ToString(1);  // std::to_string (num);
auto b = ToString(1.0);  // std::to_string (num);
auto c = ToString("0x0");  // std::string (str);
auto d = ToString(std::string {});  // not compile :-(
```

根据两阶段名称查找（`two-phase name lookup`）的规定：如果直接使用`static_assert (false)`断言，会在模板还没实例化的第一阶段编译失败；所以需要借助类型依赖（`type-dependent`）的`false`表达式（一般依赖于参数`T`）进行失败的静态断言

类似的，可以通过定义一个变量模板`template <typename...> constexpr bool false_v = false`，并使用`false_v<T>`替换`sizeof (T) == 0`

### 2.1.3 使用 if 进行编译时测试

对于初次接触元编程的人，往往会使用`if`语句进行编译时测试。代码3是代码2一个错误的写法，很代表性的体现了元编程和普通编程的不同之处

**代码3：**

```cpp
template <typename T>
std::string ToString(T val) {
    if (isNum<T>)
        return std::to_string(val);
    else if (isStr<T>)
        return std::string(val);
    else
        static_assert(!isBad<T>, "neither Num nor Str");
}
```

代码3中的错误在于：编译代码的函数`ToString`时，对于给定的类型`T`，需要进行两次函数绑定，`val`作为参数分别调用`std::to_string(val)`和`std::string (val)`，再进行一次静态断言，判断`!isBad<T>`是否为`true`。这会导致：两次绑定中，有一次会失败。假设调用`ToString("str")`，在编译这段代码时，`std::string(const char *)`可以正确的重载，但是`std::to_string (const char *)`并不能找到正确的重载，导致编译失败

假设是脚本语言，这段代码是没有问题的：因为脚本语言没有编译的概念，所有函数的绑定都在运行时完成。而静态语言的函数绑定是在编译时完成的。为了使得代码`3`的风格用于元编程，`C++ 17`引入了 `constexpr-if`，只需要把以上代码3中的`if`改为`if constexpr`就可以编译了

`constexpr-if`的引入让模板测试更加直观，提高了模板代码的可读性。代码4展示了如何使用`constexpr-if`解决编译时选择的问题；而且最后的兜底（`catch-all`）语句，不再需要`isBad<T>`谓词模板，可以使用类型依赖的`false`表达式进行静态断言（但也不能直接使用`static_assert(false)`断言）

**代码4：**

```cpp
template <typename T>
std::string ToString(T val) {
    if constexpr (isNum<T>)
        return std::to_string(val);
    else if constexpr (isStr<T>)
        return std::string(val);
    else
        static_assert(false_v<T>, "neither Num nor Str");
}
```

然而，`constexpr-if`背后的思路早在`Visual Studio 2012`已出现了。其引入了`__if_exists`语句，用于编译时测试标识符是否存在

## 2.2 编译时迭代

编译时迭代和面向过程编程中的循环语句（`loop statement`）类似，用于实现与`for/while/do`类似的循环逻辑

在`C++ 17`之前，和普通的编程不同，元编程的演算规则是纯函数的，不能通过变量迭代实现编译时迭代，只能用递归（`recursion`）和特化的组合实现。**一般思路是：提供两类重载，一类接受任意参数，内部递归 调用自己；另一类是前者的模板特化或函数重载，直接返回结果，相当于递归终止条件。它们的重载条件可以是表达式或类型**

而`C++ 17`提出了折叠表达式（`fold expression`）的语法，化简了迭代的写法

### 2.2.1 定长模板的迭代

代码5展示了如何使用编译时迭代实现编译时计算阶乘（`N!`）。函数`_Factor`有两个重载：一个是对任意非负整数的，一个是对`0`为参数的。前者利用递归产生结果，后者直接返回结果。当调用`_Factor<2>`时，编译器会展开为`2 * _Factor<1>`，然后`_Factor<1>`再展开为`1 * _Factor<0>`，最后`_Factor<0>`直接匹配到参数为`0`的重载

**代码5：**

```cpp
template <unsigned N>
constexpr unsigned _Factor() {
    return N * _Factor<N - 1>();
}

template <>
constexpr unsigned _Factor<0>() {
    return 1;
}

template <unsigned N>
constexpr unsigned Factor = _Factor<N>();

static_assert(Factor<0> == 1, "compile error");
static_assert(Factor<1> == 1, "compile error");
static_assert(Factor<4> == 24, "compile error");
```

### 2.2.2 变长模板的迭代

为了遍历变长模板的每个参数，可以使用编译时迭代实现循环遍历。代码6实现了对所有参数求和的功能。函数`Sum`有两个重载：一个是对没有函数参数的情况，一个是对函数参数个数至少为`1`的情况。和定长模板的迭代类似，这里也是通过递归调用实现参数遍历

**代码6：**

```cpp
template <typename T>
constexpr auto Sum() {
    return T(0);
}

template <typename T, typename... Ts>
constexpr auto Sum(T arg, Ts... args) {
    return arg + Sum<T>(args...);
}

static_assert(Sum<int>() == 0, "compile error");
static_assert(Sum(1, 2.0, 3) == 6, "compile error");
```

### 2.2.3 使用折叠表达式化简编译时迭代

在`C++ 11`引入变长模板时，就支持了在模板内直接展开参数包的语法；但该语法仅支持对参数包里的每个参数进行一元操作（`unary operation`）；为了实现参数间的二元操作（`binary operation`），必须借助额外的模板实现（例如，代码6定义了两个`Sum`函数模板，其中一个展开参数包进行递归调用）。

而`C++ 17`引入了折叠表达式，允许直接遍历参数包里的各个参数，对其应用二元运算符（`binary operator`）进行左折叠（`left fold`）或右折叠（`right fold`）。代码7使用初始值为`0`的左折叠表达式，对代码6进行改进

**代码7：**

```cpp
template <typename... Ts>
constexpr auto Sum(Ts... args) {
    return (0 + ... + args);
}

static_assert(Sum() == 0, "compile error");
static_assert(Sum(1, 2.0, 3) == 6, "compile error");
```

# 3 元编程的基本应用

利用元编程，可以很方便的设计出类型安全（`type safe`）、运行时高效（`runtime effective`）的程序。到现在，元编程已被广泛的应用于`C++`的编程实践中。例如，`Todd Veldhuizen`提出了使用元编程的方法构造表达式模板（`expression template`），使用表达式优化的方法，提升向量计算的运行速度；`K. Czarnecki`和`U. Eisenecker`利用模板实现`Lisp`解释器

尽管元编程的应用场景各不相同，但都是三类基本应用的组合：数值计算（`numeric computation`）、类型推导（`type deduction`）和代码生成（`code generation`）。例如，在`BOT Man`设计的对象关系映射`ORM, object-relation mapping`中，主要使用了类型推导和代码生成的功能。根据对象（`object`）在`C++`中的类型，推导出对应数据库关系（`relation`）中元组各个字段的类型。将对`C++`对象的操作，映射到对应的数据库语句上，并生成相应的代码

## 3.1 数值计算

作为元编程的最早的应用，数值计算可以用于编译时常数计算和优化运行时表达式计算

编译时常数计算能让程序员使用程序设计语言，写编译时确定的常量；而不是直接写常数（迷之数字（`magic number`））或在运行时计算这些常数。例如，代码5、6、7都是编译时对常数的计算

最早的有关元编程优化表达式计算的思路是`Todd Veldhuizen`提出的。利用表达式模板，可以实现部分求值、惰性求值、表达式化简等特性

## 3.2 类型推导

除了基本的数值计算之外，还可以利用元编程进行任意类型之间的相互推导。例如，在领域特定语言（`domain-specific language`）和`C++`语言原生结合时，类型推导可以实现将这些语言中的类型，转化为`C++`的类型，并保证类型安全

`BOT Man`提出了一种能编译时进行`SQL`语言元组类型推导的方法。`C++`所有的数据类型都不能为`NULL`，而`SQL`的字段是允许为`NULL`的，所以在`C++`中使用`std::optional`容器存储可以为空的字段。通过`SQL`的`outer-join`拼接得到的元组的所有字段都可以为`NULL`，所以`ORM`需要一种方法：把字段可能是`std::optional<T>`或`T`的元组，转化为全部字段都是`std::optional<T>`的新元组。

**代码8：**

1. 定义`TypeToNullable`，并对`std::optional<T>`进行特化，作用是将`std::optional<T>`和`T`自动转换为`std::optional<T>`
1. 定义`TupleToNullable`，拆解元组中的所有类型，转化为参数包，再把参数包中所有类型分别传入`TypeToNullable`，最后得到的结果重新组装为新的元组

```cpp
template <typename T>
struct TypeToNullable {
    using type = std::optional<T>;
};
template <typename T>
struct TypeToNullable<std::optional<T>> {
    using type = std::optional<T>;
};

template <typename... Args>
auto TupleToNullable(const std::tuple<Args...>&) {
    return std::tuple<typename TypeToNullable<Args>::type...>{};
}

auto t1 = std::make_tuple(std::optional<int>{}, int{});
auto t2 = TupleToNullable(t1);
static_assert(!std::is_same<std::tuple_element_t<0, decltype(t1)>, std::tuple_element_t<1, decltype(t1)>>::value,
              "compile error");
static_assert(std::is_same<std::tuple_element_t<0, decltype(t2)>, std::tuple_element_t<1, decltype(t2)>>::value,
              "compile error");
```

## 3.3 代码生成

和泛型编程一样，元编程也常常被用于代码的生成。但是和简单的泛型编程不同，元编程生成的代码往往是通过编译时测试和编译时迭代的演算推导出来的。例如，代码2就是一个将C语言基本类型转化为`std::string`的代码的生成代码

在实际项目中，我们往往需要将`C++`数据结构，和实际业务逻辑相关的领域模型（`domain model`）相互转化。例如，将承载着领域模型的`JSON`字符串反序列化（`deserialize`）为`C++`对象，再做进一步的业务逻辑处理，然后将处理后的`C++`对象序列化（`serialize`）变为`JSON`字符串。而这些序列化/反序列化的代码，一般不需要手动编写，可以自动生成

`BOT Man`提出了一种基于编译时多态（`compile-time polymorphism`）的方法，定义领域模型的模式（`schema`），自动生成领域模型和`C++`对象的序列化/反序列化的代码。这样，业务逻辑的处理者可以更专注于如何处理业务逻辑，而不需要关注如何做底层的数据结构转换

# 4 元编程的主要难点

尽管元编程的能力丰富，但学习、使用的难度都很大。一方面，复杂的语法和运算规则，往往让初学者望而却步；另一方面，即使是有经验的`C++`开发者，也可能掉进元编程看不见的坑里

## 4.1 复杂性

由于元编程的语言层面上的限制较大，所以许多的元编程代码使用了很多的编译时测试和编译时迭代技巧，可读性（`readability`）都比较差。另外，由于巧妙的设计出编译时能完成的演算也是很困难的，相较于一般的`C++`程序，元编程的可写性（`writability`）也不是很好

现代`C++`也不断地增加语言的特性，致力于降低元编程的复杂性：

* `C++ 11`的别名模板提供了对模板中的类型的简记方法
* `C++ 14`的变量模板提供了对模板中常量的简记方法
* `C++ 17`的`constexpr-if`提供了编译时测试的新写法
* `C++ 17`的折叠表达式降低了编译时迭代的编写难度

基于`C++ 14`的泛型`lambda`表达式，`Louis Dionne`设计的元编程库`Boost.Hana`提出了不用模板就能元编程的理念，宣告从模板元编程（`template metaprogramming`）时代进入现代元编程（`modern metaprogramming`）时代。其核心思想是：只需要使用`C++ 14`的泛型`lambda`表达式和`C++ 11`的`constexpr/decltype`，就可以快速实现元编程的基本演算了

## 4.2 实例化错误

模板的实例化和函数的绑定不同：在编译前，前者对传入的参数是什么，没有太多的限制；而后者则根据函数的声明，确定了应该传入参数的类型。而对于模板实参内容的检查，则是在实例化的过程中完成的。所以，程序的设计者在编译前，很难发现实例化时可能产生的错误

为了减少可能产生的错误，`Bjarne Stroustrup`等人提出了在语言层面上，给模板上引入概念（`concept`）。利用概念，可以对传入的参数加上限制（`constraint`），即只有满足特定限制的类型才能作为参数传入模板。例如，模板`std::max`限制接受支持运算符`<`的类型传入。但是由于各种原因，这个语言特性一直没有能正式加入`C++`标准（可能在`C++ 20`中加入）。尽管如此，编译时仍可以通过编译时测试和静态断言等方法实现检查

另外，编译时模板的实例化出错位置，在调用层数较深处时，编译器会提示每一层实例化的状态，这使得报错信息包含了很多的无用信息，很难让人较快的发现问题所在。`BOT Man`提出了一种短路编译（`short-circuit compiling`）的方法，能让基于元编程的库（`library`），给用户提供更人性化的编译时报错。具体方法是，在实现（`implementation`）调用需要的操作之前，接口（`interface`）先检查是传入的参数否有对应的操作；如果没有，就通过短路的方法，转到一个用于报错的接口，然后停止编译并使用静态断言提供报错信息。`Paul Fultz II`提出了一种类似于`C++ 20`的概念/限制的接口检查方法，通过定义概念对应的特征（`traits`）模板，然后在使用前检查特征是否满足

## 4.3 代码膨胀

由于模板会对所有不同模板实参都进行一次实例化，所以当参数的组合很多的时候，很可能会发生代码膨胀（`code bloat`），即产生体积巨大的代码。这些代码可以分为两种：死代码（`dead code`）和有效代码（`effective code`）

在元编程中，很多时候只关心推导的结果，而不是过程。例如，代码5中，只关心最后的`Factor<4> == 24`，而不需要中间过程中产生的临时模板。但是在`N`很大的时候，编译会产生很多临时模板。这些临时模板是死代码，即不被执行的代码。所以，编译器会自动优化最终的代码生成，在链接时（`link-time`）移除这些无用代码，使得最终的目标代码不会包含它们。尽管如此，如果产生过多的死代码，会浪费宝贵的编译时间

另一种情况下，展开的代码都是有效代码，即都是被执行的，但是又由于需要的参数的类型繁多，最后的代码体积仍然很大。编译器很难优化这些代码，所以程序员应该在设计时避免代码膨胀。一般用薄模板（`thin template`）减小模板实例体积；具体思路是：将不同参数实例化得到的模板的相同部分抽象为共同的基类或函数，然后将不同参数对应的不同部分继承基类或调用函数，从而实现代码共享

例如，在`std::vector`的实现中，对`T*`和`void*`进行了特化；然后将所有的`T*`的实现继承到`void*`的实现上，并在公开的函数里通过强制类型转换，进行`void*`和`T*`的相互转换；最后这使得所有的指针的`std::vector`就可以共享同一份实现，从而避免了代码膨胀（代码9）

**代码9：**

```cpp
template <typename T>
class vector; // general
template <typename T>
class vector<T*>; // partial spec
template <>
class vector<void*>; // complete spec

template <typename T>
class vector<T*> : private vector<void*> {
    using Base = Vector<void∗>;

public:
    T∗& operator[](int i) {
        return reinterpret_cast<T∗&>(Base::operator[](i));
    }
    ...
}
```

## 4.4 编译性能

元编程尽管不会带来额外的运行时开销（`runtime overhead`），但如果过度使用，可能会大大增加编译时间（尤其是在大型项目中）。为了提高元编程的编译性能，需要使用特殊的技巧进行优化

根据单定义规则（`One Definition Rule, ODR`），允许一个模板在多个翻译单元（`translation unit`）中使用相同的模板参数实例化，并在链接时合并为同一个实例。然而，每个翻译单元上的模板操作是独立的，一方面增加了编译时间，另一方面还会产生过多中间代码。因此，常用显式实例化（`explicit instantiation`）避免进行多次模板实例化操作；具体思路是：在一个翻译单元中显式定义模板实例，在其他翻译单元中只需要通过`extern`声明相同的实例。由于接口与实现分离，该方法还常用于静态库的模板接口

`Chiel Douwes`对元编程中的常用模板操作进行了深入分析，对比了几种模板操作的代价（`Cost of operations: The Rule of Chiel`）（没有提到`C++ 14`的变量模板；从高到低）：

1. 替换失败不是错误`SFINAE`
1. 实例化函数模板
1. 实例化类模板
1. 使用别名模板
1. 添加参数到类模板
1. 添加参数到别名模板
1. 使用缓存的类型

基于以上原则，`Odin Holmes`设计了类型运算库`Kvasir`，相比基于`C++ 98/11`的类型运算库，拥有极高的编译性能。为了衡量编译性能的优化效果，`Louis Dionne`设计了一个基于`CMake`的编译时间基准测试框架

另外，`Mateusz Pusz`总结了一些元编程性能的实践经验。例如，基于`C++ 11`别名模板的`std::conditional_t`和基于`C++ 14`变量模板的`std::is_same_v`都比基于`std::conditional/std::is_same`的传统方案更快。代码10展示了基于`std::is_same`和直接基于变量模板的`std::is_same_v`的实现

**代码10：**

```cpp
// traditional, slow
template <typename T, typename U>
struct is_same : std::false_type {};
template <typename T>
struct is_same<T, T> : std::true_type {};
template <typename T, typename U>
constexpr bool is_same_v = is_same<T, U>::value;

// using variable template, fast
template <typename T, typename U>
constexpr bool is_same_v = false;
template <typename T>
constexpr bool is_same_v<T, T> = true;
```

## 4.5 调试模板

元编程在运行时主要的难点在于：对模板代码的调试（`debugging`）。如果需要调试的是一段通过很多次的编译时测试和编译时迭代展开的代码，即这段代码是各个模板的拼接生成的（而且展开的层数很多）；那么，调试时需要不断地在各个模板的实例（`instance`）间来回切换。这种情景下，调试人员很难把具体的问题定位到展开后的代码上

所以，一些大型项目很少使用复杂的代码生成技巧，而是通过传统的代码生成器生成重复的代码，易于调试。例如`Chromium`的通用扩展接口（`common extension api`）通过定义`JSON/IDL`文件，通过代码生成器生成相关的`C++`代码，同时还可以生成接口文档

# 5 总结

`C++`元编程的出现，是一个无心插柳的偶然：人们发现`C++`语言提供的模板抽象机制，能很好的被应用于元编程上。借助元编程，可以写出类型安全、运行时高效的代码。但是，过度的使用元编程，一方面会增加编译时间，另一方面会降低程序的可读性。不过，在`C++`不断地演化中，新的语言特性被不断提出，为元编程提供更多的可能

# 6 元编程的应用

## 6.1 rank

```cpp
#include <iostream>

template <class T>
struct rank {
    static size_t const value = 0u;
};

template <class U, size_t N>
struct rank<U[N]> {
    static size_t const value = 1u + rank<U>::value;
};

int main() {
    using array_t = int[10][20][30];
    std::cout << "rank=" << rank<array_t>::value << std::endl;
    return 0;
}
```

我们也可以利用`std::integral_constant`来实现上述功能

```cpp
#include <iostream>
#include <type_traits>

// Default version
template <typename T>
struct rank : std::integral_constant<size_t, 0> {};

template <typename U, size_t N>
struct rank<U[N]> : std::integral_constant<size_t, 1 + rank<U>::value> {};

int main() {
    using array_t = int[10][20][30];
    std::cout << "rank=" << rank<array_t>::value << std::endl;
    return 0;
}
```

## 6.2 one_of/type_in/value_in

下面是`is_one_of`的实现方式

* 首先，定义模板
* base1，定义单个参数的实例化版本，即递归的终止状态
* base2，定义首个元素相同的实例化版本，即递归的终止状态
* 定义首个元素不同的实例化版本，并通过继承实现递归实例化（递归时，要注意，每次减少一个参数）

```cpp
#include <iostream>
#include <type_traits>

// declare the interface only
template <typename T, typename... P0toN>
struct is_one_of;

// base #1: specialization recognizes empty list of types:
template <typename T>
struct is_one_of<T> : std::false_type {};

// base #2: specialization recognizes match at head of list of types:
template <typename T, typename... P1toN>
struct is_one_of<T, T, P1toN...> : std::true_type {};

// specialization recognizes mismatch at head of list of types:
template <typename T, typename P0, typename... P1toN>
struct is_one_of<T, P0, P1toN...> : is_one_of<T, P1toN...> {};

int main() {
    std::cout << is_one_of<double, double, float, long>::value << std::endl;
    std::cout << is_one_of<bool, double, float, long>::value << std::endl;
    return 0;
}
```

我们也可以利用[折叠表达式](https://www.bookstack.cn/read/cppreference-language/62e23cda3198622e.md)来实现递归展开

```cpp
#include <iostream>
#include <type_traits>

template <typename T, typename... Args>
constexpr bool type_in = (std::is_same_v<T, Args> || ...);

template <typename T, T v, T... args>
constexpr bool value_in = ((v == args) || ...);

int main() {
    std::cout << type_in<double, double, float, long> << std::endl;
    std::cout << type_in<bool, double, float, long> << std::endl;
    std::cout << value_in<int, 1, 1, 2, 3, 4, 5> << std::endl;
    std::cout << value_in<int, 10, 1, 2, 3, 4, 5> << std::endl;
    return 0;
}
```

## 6.3 is_copy_assignable

我们手动来实现一下`<type_traits>`头文件中的`std::is_copy_assignable`，该模板用于判断一个类是否支持了拷贝赋值运算符

示例如下，这个实现比较复杂，我们一一解释

* 其中`std::declval`用于返回指定类型的右值版本
* 函数模板`try_assignment(U&&)`包含两个类型参数，其中第二个类型参数并未用到（省略了参数名），且存在一个默认值`typename = decltype(std::declval<U&>() = std::declval<U const&>())`，这一段其实就是用于测试指定类型是否支持拷贝赋值操作。如果不支持，那么`try_assignment(U&&)`模板的实例化将会失败，转而匹配默认版本`try_assignment(...)`。**这就是著名的`SFINAE, Substitution failure is not an error`**
    * 如果要实现`is_copy_constructible`、`is_move_constructible`以及`is_move_assignable`，其实是类似的，替换这一串表达式即可
* `try_assignment(...)`该重载版本可以匹配任意数量任意类型的参数

```cpp
#include <iostream>

template <typename T>
struct is_copy_assignable {
private:
    template <typename U, typename = decltype(std::declval<U&>() = std::declval<U const&>())>
    static std::true_type try_assignment(U&&);

    static std::false_type try_assignment(...);

public:
    using type = decltype(try_assignment(std::declval<T>()));
};

struct SupportCopyAssignment {
    SupportCopyAssignment() = delete;
    SupportCopyAssignment(const SupportCopyAssignment&) = delete;
    SupportCopyAssignment(SupportCopyAssignment&&) = delete;
    SupportCopyAssignment& operator=(const SupportCopyAssignment&) = default;
    SupportCopyAssignment& operator=(SupportCopyAssignment&&) = delete;
};

struct NoSupportCopyAssignment {
    NoSupportCopyAssignment() = delete;
    NoSupportCopyAssignment(const NoSupportCopyAssignment&) = delete;
    NoSupportCopyAssignment(NoSupportCopyAssignment&&) = delete;
    NoSupportCopyAssignment& operator=(const NoSupportCopyAssignment&) = delete;
    NoSupportCopyAssignment& operator=(NoSupportCopyAssignment&&) = delete;
};

int main() {
    std::cout << is_copy_assignable<SupportCopyAssignment>::type::value << std::endl;
    std::cout << is_copy_assignable<NoSupportCopyAssignment>::type::value << std::endl;
    return 0;
}
```

## 6.4 has_type_member

我们实现一个`has_type_member`，用于判断某个类型是否有类型成员，且其名字为`type`，即对于类型`T`是否存在`typename T::type`

* `has_type_member`的`primitive`版本包含两个类型参数，其中第二个参数存在默认值，其值为`void`
* `std::void_t<T>`对任意`T`都会返回`void`。任何存在类型成员`type`的类型，对于该特化版本而言都是`well-formed`，因此会匹配该版本；而对于没有类型成员`type`的类型，第二个模板参数的推导会失败，转而匹配其他版本。这里也用到了`SFINAE`
    * 该示例也是`std::void_t`的应用之一

```cpp
#include <iostream>
#include <type_traits>

template <typename, typename = void>
struct has_type_member : std::false_type {};

template <typename T>
struct has_type_member<T, std::void_t<typename T::type>> : std::true_type {};

struct WithNonVoidMemberType {
    using type = int;
};

struct WithVoidMemberType {
    using type = void;
};

struct WithNonTypeMemberType {
    static constexpr int type = 1;
};

struct WithoutMemberType {};

int main() {
    std::cout << has_type_member<WithNonVoidMemberType>::value << std::endl;
    std::cout << has_type_member<WithVoidMemberType>::value << std::endl;
    std::cout << has_type_member<WithNonTypeMemberType>::value << std::endl;
    std::cout << has_type_member<WithoutMemberType>::value << std::endl;
    return 0;
}
```

## 6.5 类型推导

**`using template`：当我们使用`Traits`萃取类型时，通常需要加上`typename`来消除歧义。因此，`using`模板可以进一步消除多余的`typename`**
**`static member template`：静态成员模板**

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>
#include <string>

enum Type {
    INT = 0,
    LONG,  /* 1 */
    FLOAT, /* 2 */
    DOUBLE /* 3 */
};

template <Type type>
struct TypeTraits {};

template <>
struct TypeTraits<Type::INT> {
    using type = int32_t;
    static constexpr int32_t default_value = 1;
};

template <>
struct TypeTraits<Type::LONG> {
    using type = int64_t;
    static constexpr int64_t default_value = 2;
};

template <>
struct TypeTraits<Type::FLOAT> {
    using type = float;
    static constexpr float default_value = 2.2;
};

template <>
struct TypeTraits<Type::DOUBLE> {
    using type = double;
    static constexpr double default_value = 3.3;
};

template <Type type>
using CppType = typename TypeTraits<type>::type;

int main() {
    typename TypeTraits<Type::INT>::type value1 = TypeTraits<Type::INT>::default_value;
    CppType<Type::LONG> value2 = TypeTraits<Type::LONG>::default_value;
    CppType<Type::FLOAT> value3 = TypeTraits<Type::FLOAT>::default_value;
    CppType<Type::DOUBLE> value4 = TypeTraits<Type::DOUBLE>::default_value;
    std::cout << "value1=" << value1 << std::endl;
    std::cout << "value2=" << value2 << std::endl;
    std::cout << "value3=" << value3 << std::endl;
    std::cout << "value4=" << value4 << std::endl;
}
```

## 6.6 遍历tuple

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>
#include <tuple>

template <typename Tuple, typename Func, size_t... N>
void func_call_tuple(const Tuple& t, Func&& func, std::index_sequence<N...>) {
    static_cast<void>(std::initializer_list<int>{(func(std::get<N>(t)), 0)...});
}

template <typename... Args, typename Func>
void travel_tuple(const std::tuple<Args...>& t, Func&& func) {
    func_call_tuple(t, std::forward<Func>(func), std::make_index_sequence<sizeof...(Args)>{});
}

int main() {
    auto t = std::make_tuple(1, 4.56, "hello");
    travel_tuple(t, [](auto&& item) { std::cout << item << ","; });
}
```

## 6.7 快速排序

**源码出处：[quicksort in C++ template metaprogramming](https://gist.github.com/cleoold/c26d4e2b4ff56985c42f212a1c76deb9)**

```cpp
#include <iostream>

namespace quicksort {
/**
 * 1. 通过 ::type 获取自身类型
 * 2. 通过 ::value 获取模板实参
 */
template <int VALUE>
struct Value {
    using type = Value;
    static constexpr int value = VALUE;
};

/*==============================================================*/

/**
 * 1. 通过 ::type 获取自身类型
 */
template <int... VALUES>
struct Array {
    using type = Array;
};
using EmptyArray = Array<>;

/*==============================================================*/

/**
 * 从 TARGET_ARRAY 的模板参数中，提取第一个模板参数
 */
template <typename TARGET_ARRAY>
struct FirstOf;
/**
 * 定义了如何实现 FirstOf
 */
template <int FIRST_VALUE, int... VALUES>
struct FirstOf<Array<FIRST_VALUE, VALUES...>> : Value<FIRST_VALUE> {};

/*==============================================================*/

/**
 * 将 VALUE 添加到 TARGET_ARRAY 的模板参数列表中，并作为第一个模板参数
 */
template <typename TARGET_ARRAY, int VALUE>
struct PrependTo;
/**
 * 定义了如何实现 PrependTo
 */
template <int FIRST_VALUE, int... VALUES>
struct PrependTo<Array<VALUES...>, FIRST_VALUE>
    : Array<FIRST_VALUE, VALUES...> {};

/*==============================================================*/

/**
 * 将 VALUE 添加到 TARGET_ARRAY 的模板参数列表中，并作为最后一个模板参数
 */
template <typename TARGET_ARRAY, int VALUE>
struct AppendValueTo;
/**
 * 定义了如何实现 AppendValueTo
 */
template <int LAST_VALUE, int... VALUES>
struct AppendValueTo<Array<VALUES...>, LAST_VALUE>
    : Array<VALUES..., LAST_VALUE> {};

/*==============================================================*/

/**
 * 将 SOURCE_ARRAY 的模板参数列表依次添加到 TARGET_ARRAY 的模板参数列表中
 */
template <typename TARGET_ARRAY, typename SOURCE_ARRAY>
struct AppendArrayTo;
/**
 * 定义了如何实现 AppendArrayTo
 * 实现方式：模板递归
 */
template <typename TARGET_ARRAY, int FIRST_VALUE, int... VALUES>
struct AppendArrayTo<TARGET_ARRAY, Array<FIRST_VALUE, VALUES...>>
    : AppendArrayTo<typename AppendValueTo<TARGET_ARRAY, FIRST_VALUE>::type,
                    typename Array<VALUES...>::type> {};
/**
 * 递归终止状态
 */
template <typename TARGET_ARRAY>
struct AppendArrayTo<TARGET_ARRAY, EmptyArray> : TARGET_ARRAY {};

/*==============================================================*/

/**
 * 提取 TARGET_ARRAY 的模板参数中，与 TARGET_VALUE 相比，所有符合 CONDITION
 * 条件的模板参数列表
 */
template <typename TARGET_ARRAY, int TARGET_VALUE, bool CONDITION>
struct LessEqualFilterAdviser;
/**
 * 定义了当 CONDITION = true 时，如何实现 LessEqualFilterAdviser
 * 实现方式：模板递归
 */
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct LessEqualFilterAdviser<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, true>
    : PrependTo<typename LessEqualFilterAdviser<
                    typename Array<VALUES...>::type, TARGET_VALUE,
                    (FirstOf<typename Array<VALUES...>::type>::value <=
                     TARGET_VALUE)>::type,
                FIRST_VALUE> {};
/**
 * 定义了当 CONDITION = false 时，如何实现 LessEqualFilterAdviser
 * 实现方式：模板递归
 */
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct LessEqualFilterAdviser<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE,
                              false>
    : LessEqualFilterAdviser<typename Array<VALUES...>::type, TARGET_VALUE,
                             (FirstOf<typename Array<VALUES...>::type>::value <=
                              TARGET_VALUE)> {};
/**
 * 当 CONDITION = true 时的递归终止状态
 */
template <int TARGET_VALUE, int FIRST_VALUE>
struct LessEqualFilterAdviser<Array<FIRST_VALUE>, TARGET_VALUE, true>
    : Array<FIRST_VALUE> {};
/**
 * 当 CONDITION = false 时的递归终止状态
 */
template <int TARGET_VALUE, int FIRST_VALUE>
struct LessEqualFilterAdviser<Array<FIRST_VALUE>, TARGET_VALUE, false>
    : EmptyArray {};
/**
 * 接口模板，外部不直接使用 LessEqualFilterAdviser，而是使用 LessEqualFilter
 */
template <typename TARGET_ARRAY, int TARGET_VALUE>
struct LessEqualFilter
    : LessEqualFilterAdviser<TARGET_ARRAY, TARGET_VALUE,
                             (FirstOf<TARGET_ARRAY>::value <= TARGET_VALUE)> {};
/**
 * 递归终止状态
 */
template <int TARGET_VALUE>
struct LessEqualFilter<EmptyArray, TARGET_VALUE> : EmptyArray {};

/*==============================================================*/

/**
 * 提取 TARGET_ARRAY 的模板参数中，与 TARGET_VALUE 相比，所有符合 CONDITION
 * 条件的模板参数列表
 */
template <typename TARGET_ARRAY, int TARGET_VALUE, bool CONDITION>
struct GreaterThanAdvisor;
/**
 * 定义了当 CONDITION = true 时，如何实现 GreaterThanAdvisor
 * 实现方式：模板递归
 */
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct GreaterThanAdvisor<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, true>
    : PrependTo<typename GreaterThanAdvisor<
                    typename Array<VALUES...>::type, TARGET_VALUE,
                    (FirstOf<typename Array<VALUES...>::type>::value >
                     TARGET_VALUE)>::type,
                FIRST_VALUE> {};
/**
 * 定义了当 CONDITION = false 时，如何实现 GreaterThanAdvisor
 * 实现方式：模板递归
 */
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct GreaterThanAdvisor<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, false>
    : GreaterThanAdvisor<typename Array<VALUES...>::type, TARGET_VALUE,
                         (FirstOf<typename Array<VALUES...>::type>::value >
                          TARGET_VALUE)> {};
/**
 * 当 CONDITION = true 时的递归终止状态
 */
template <int TARGET_VALUE, int FIRST_VALUE>
struct GreaterThanAdvisor<Array<FIRST_VALUE>, TARGET_VALUE, true>
    : Array<FIRST_VALUE> {};
/**
 * 当 CONDITION = false 时的递归终止状态
 */
template <int TARGET_VALUE, int FIRST_VALUE>
struct GreaterThanAdvisor<Array<FIRST_VALUE>, TARGET_VALUE, false>
    : EmptyArray {};
/**
 * 接口模板，外部不直接使用 GreaterThanAdvisor，而是使用 GreaterThan
 */
template <typename TARGET_ARRAY, int TARGET_VALUE>
struct GreaterThan
    : GreaterThanAdvisor<TARGET_ARRAY, TARGET_VALUE,
                         (FirstOf<TARGET_ARRAY>::value > TARGET_VALUE)> {};
/**
 * 递归终止状态
 */
template <int TARGET_VALUE>
struct GreaterThan<EmptyArray, TARGET_VALUE> : EmptyArray {};

/*==============================================================*/

/**
 * 对 TARGET_ARRAY 进行快速排序
 */
template <typename TARGET_ARRAY>
struct QuickSort;
/**
 * 定义了如何实现 QuickSort
 */
template <int FIRST_VALUE, int... VALUES>
struct QuickSort<Array<FIRST_VALUE, VALUES...>>
    : AppendArrayTo<
          typename QuickSort<typename LessEqualFilter<
              typename Array<VALUES...>::type, FIRST_VALUE>::type>::type,
          typename PrependTo<
              typename QuickSort<typename GreaterThan<
                  typename Array<VALUES...>::type, FIRST_VALUE>::type>::type,
              FIRST_VALUE>::type> {};
/**
 * 递归终止状态
 */
template <>
struct QuickSort<EmptyArray> : EmptyArray {};

}  // namespace quicksort

template <int FIRST_VALUE, int... VALUES>
static void print(quicksort::Array<FIRST_VALUE, VALUES...>) {
    std::cout << '(' << FIRST_VALUE;
    int _[] = {0, ((void)(std::cout << ", " << VALUES), 0)...};
    std::cout << ")\n";
}

static void print(quicksort::EmptyArray) { std::cout << "()\n"; }

template <int... VALUES>
static void test_quick_sort() {
    using original = quicksort::Array<VALUES...>;
    using sorted = quicksort::QuickSort<original>;
    std::cout << "before: ";
    print(original());
    std::cout << "after : ";
    print(sorted());
    std::cout << '\n';
}

int main() {
    test_quick_sort<>();
    test_quick_sort<1>();
    test_quick_sort<8, 1>();
    test_quick_sort<1, 2, 5, 8, -3, 2, 100, 4, 9, 3, -8, 33, 21, 3, -4, -4, -4,
                    -7, 2, 5, 1, 8, 2, 88, 42, 956, 21, 27, 39, 55, 1, 4, -5,
                    -31, 9>();
}
```

## 6.8 静态代理

不确定这个是否属于元编程的范畴。更多示例可以参考[binary_function.h](https://github.com/liuyehcf/starrocks/blob/main/be/src/exprs/vectorized/binary_function.h)

```cpp
#include <iostream>

struct OP1 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP1(l, r)" << std::endl;
        return l + r;
    }
};

struct OP2 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP2(l, r)" << std::endl;
        return l - r;
    }
};

struct OP3 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP3(l, r)" << std::endl;
        return l * r;
    }
};

struct OP4 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP4(l, r)" << std::endl;
        return r == 0 ? 0 : l / r;
    }
};

template <typename OP>
struct Wrapper1 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper1 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper1 end" << std::endl;
        return res;
    }
};

template <typename OP>
struct Wrapper2 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper2 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper2 end" << std::endl;
        return res;
    }
};

template <typename OP>
struct Wrapper3 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper3 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper3 end" << std::endl;
        return res;
    }
};

int main() {
    Wrapper3<Wrapper2<Wrapper1<OP1>>>::apply(1, 2);
    std::cout << std::endl;
    Wrapper1<Wrapper2<Wrapper3<OP2>>>::apply(1, 2);
    return 0;
}
```

## 6.9 编译期分支

有时候，我们想为不同的类型编写不同的分支代码，而这些分支代码在不同类型中是不兼容的，例如，我要实现加法，对于`int`来说，用操作符`+`即可完成加法运算；对于`Foo`类型来说，要调用`add`方法才能实现加法运算。这个时候，普通的分支是无法实现的，实例化的时候会报错。这时候，我们可以使用`if constexpr`来实现编译期的分支

```cpp
#include <type_traits>

struct Foo {
    int val;
};

Foo add_foo(const Foo& left, const Foo& right) {
    return Foo{left.val + right.val};
}

template <typename T>
T add(const T& left, const T& right) {
    if constexpr (std::is_same<T, int>::value) {
        return left + right;
    } else if constexpr (std::is_same<T, Foo>::value) {
        return add_foo(left, right);
    }
}

int main() {
    Foo left, right;
    add(left, right);
    add(1, 2);
    return 0;
}
```

**类型相关的代码必须包含在`if constexpr/else if constexpr`的代码块中，错误示例如下，其本意是，当不为算数类型时，直接返回，但由于`left + right`不在上述静态分支内，因此实例化`Foo`的时候就会报错**

```cpp
#include <type_traits>

template <typename T>
T add(const T& left, const T& right) {
    if constexpr (!std::is_arithmetic<T>::value) {
        return {};
    }
    return left + right;
}

struct Foo {};

int main() {
    Foo left, right;
    add(left, right);
    return 0;
}
```

# 7 参考

* [ClickHouse](https://github.com/ClickHouse/ClickHouse/blob/master/base/base/constexpr_helpers.h)
* [C++雾中风景16:std::make_index_sequence, 来试一试新的黑魔法吧](https://www.cnblogs.com/happenlee/p/14219925.html)
* [CppCon 2014: Walter E. Brown "Modern Template Metaprogramming: A Compendium, Part I"](https://www.youtube.com/watch?v=Am2is2QCvxY)
* [CppCon 2014: Walter E. Brown "Modern Template Metaprogramming: A Compendium, Part II"](https://www.youtube.com/watch?v=a0FliKwcwXE)
    * Unevaluated operands(sizeof, typeid, decltype, noexcept), 12:30
