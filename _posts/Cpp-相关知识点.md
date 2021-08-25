---
title: Cpp-相关知识点
date: 2021-08-19 09:38:42
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 语法

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
1. 线程局部存储，`thread_local`关键词
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

## 1.5 throw与异常

throw关键字可以抛出任何对象，例如可以抛出一个整数

```c++
    try {
        throw 1;
    } catch (int &i) {
        std::cout << i << std::endl;
    }
```

## 1.6 类型转换

### 1.6.1 static_cast

### 1.6.2 dynamic_cast

### 1.6.3 const_cast

### 1.6.4 reinterpret_cast

## 1.7 如何在类中定义常量

## 1.8 初始化

### 1.8.1 初始化列表

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

### 1.8.2 各种初始化类型

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

## 1.9 参考

* [C++11\14\17\20 特性介绍](https://www.jianshu.com/p/8c4952e9edec)
* [关于C++：静态常量字符串(类成员)](https://www.codenong.com/1563897/)

# 2 标准库

## 2.1 std::promise/std::future

## 2.2 std::string

字符串比较函数：`strcmp`

## 2.3 std::thread

## 2.4 std::chrono

## 2.5 std::shared_ptr

**只在函数使用指针，但并不保存对象内容**

假如我们只需要在函数中，用这个对象处理一些事情，但不打算涉及其生命周期的管理，也不打算通过函数传参延长`shared_ptr `的生命周期。对于这种情况，可以使用`raw pointer`或者`const shared_ptr&`

```c++
void func(Widget*);
// 不发生拷贝，引用计数未增加
void func(const shared_ptr<Widget>&)
```

**在函数中保存智能指针**

假如我们需要在函数中把这个智能指针保存起来，这个时候建议直接传值

```c++
// 传参时发生拷贝，引用计数增加
void func(std::shared_ptr<Widget> ptr);
```

这样的话，外部传过来值的时候，可以选择`move`或者赋值。函数内部直接把这个对象通过`move`的方式保存起来

## 2.6 std::function

其功能类似于函数指针，在需要函数指针的地方，可以传入`std::function`类型的对象（不是指针）

## 2.7 std::bind

## 2.8 std::lock_guard

一般的使用方法，如果getVar方法抛出异常了，那么就会导致`m.unlock()`方法无法执行，可能会造成死锁

```c++
mutex m;
m.lock();
sharedVariable= getVar();
m.unlock();
```

一种优雅的方式是使用`std::lock_guard`，该对象的析构方法中会进行锁的释放，需要将串行部分放到一个`{}`中，当退出该作用域时，`std::lock_guard`对象会析构，并释放锁，在任何正常或异常情况下都能够释放锁

```c++
{
  std::mutex m,
  std::lock_guard<std::mutex> lockGuard(m);
  sharedVariable= getVar();
}
```

## 2.9 std::condition_variable

调用`wait`方法时，必须获取监视器。而调用`notify`方法时，无需获取监视器

## 2.10 std::atomic

`compare_exchange_strong(T& expected_value, T new_value)`方法的第一个参数是个左值

* 当前值与期望值`expected_value`相等时，修改当前值为设定值`new_value`，返回true
* 当前值与期望值`expected_value`不等时，将期望值修改为当前值，返回false（搞不懂为什么要这样设计，啥脑回路）

```c++
std::atomic_bool flag = false;
bool expected = false;

std::cout << "result: " << flag.compare_exchange_strong(expected, true)
              << ", flag: " << flag << ", expected: " << expected << std::endl;
std::cout << "result: " << flag.compare_exchange_strong(expected, true)
              << ", flag: " << flag << ", expected: " << expected << std::endl;
```

```
result: 1, flag: 1, expected: 0
result: 0, flag: 1, expected: 1
```

## 2.11 std::mem_fn

## 2.12 参考

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)
* [Do I have to acquire lock before calling condition_variable.notify_one()?](https://stackoverflow.com/questions/17101922/do-i-have-to-acquire-lock-before-calling-condition-variable-notify-one)
* [C++ 智能指针的正确使用方式](https://www.cyhone.com/articles/right-way-to-use-cpp-smart-pointer/)

# 3 编程范式

## 3.1 形参类型是否需要左右值引用

## 3.2 返回类型是否需要左右值引用

# 4 宏

## 4.1 do while(0) in macros

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

## 4.2 参考

* [do {…} while (0) in macros](https://hownot2code.com/2016/12/05/do-while-0-in-macros/)
* [PRE10-C. Wrap multistatement macros in a do-while loop](https://wiki.sei.cmu.edu/confluence/display/c/PRE10-C.+Wrap+multistatement+macros+in+a+do-while+loop)

# 5 三方库

## 5.1 头文件如何查找

## 5.2 参考

* [Linux下c/c++头文件和库文件的查找路径](https://blog.csdn.net/guotianqing/article/details/104224439)

# 6 Make

**代码变成可执行文件，叫做编译`compile`；先编译这个，还是先编译那个（即编译的安排），叫做构建`build`**

## 6.1 Makefile文件的格式

**`Makefile`文件由一系列规则`rules`构成。每条规则的形式如下：**

```makefile
<target> : <prerequisites> 
[tab]  <commands>
```

* `target`：目标，是必须的
* `prerequisites`：前置条件，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的
* `commands`：即完成目标需要执行的命令，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的

### 6.1.1 target

一个目标`target`就构成一条规则。**目标通常是文件名**，指明`make`命令所要构建的对象。目标可以是一个文件名，也可以是多个文件名，之间用空格分隔

**除了文件名，目标还可以是某个操作的名字，这称为「伪目标」`phony target`，例如**

```makefile
clean:
    rm *.o
```

但是，项目中可能有名为`clean`的文件名，`make`发现`clean`文件已经存在，就认为没有必要重新构建了，因此可以明确声明「伪目标」

```makefile
.PHONY: clean
clean:
    rm *.o temp
```

**如果`make`命令运行时没有指定目标，默认会执行`Makefile`文件的第一个目标**

### 6.1.2 prerequisites

前置条件通常是一组文件名，之间用空格分隔。它指定了目标是否重新构建的判断标准：只要有一个前置文件不存在，或者有过更新（前置文件的`last-modification`时间戳比目标的时间戳新），目标就需要重新构建

```makefile
result.txt: source.txt
    cp source.txt result.txt
```

上面代码中，构建`result.txt`的前置条件是`source.txt`。如果当前目录中，`source.txt`已经存在，那么`make result.txt`可以正常运行，否则必须再写一条规则，来生成`source.txt`

```makefile
source.txt:
    echo "this is the source" > source.txt
```

连续执行两次`make result.txt`。第一次执行会先新建`source.txt`，然后再新建`result.txt`。第二次执行，`make`发现`source.txt`没有变动（时间戳晚于`result.txt`），就不会执行任何操作，`result.txt`也不会重新生成

如果需要生成多个文件，往往采用下面的写法

```makefile
source: file1 file2 file3
```

这样仅需要执行`make source`便可生成3个文件，而无需执行`make file1`、`make file2`、`make file3`

### 6.1.3 commands

命令`commands`表示如何更新目标文件，由一行或多行的`shell`命令组成。它是构建目标的具体指令，它的运行结果通常就是生成目标文件

每行命令之前必须有一个`tab`键。如果想用其他键，可以用内置变量`.RECIPEPREFIX`声明

```makefile
.RECIPEPREFIX = >
all:
> echo Hello, world
```

**需要注意的是，每行命令在一个单独的`shell`中执行。这些`shell`之间没有继承关系**

```makefile
var-lost:
    export foo=bar
    echo "foo=[$$foo]"
```

一个解决办法是将两行命令写在一行，中间用分号分隔

```makefile
var-kept:
    export foo=bar; echo "foo=[$$foo]"
```

另一个解决办法是在换行符前加反斜杠转义

```makefile
var-kept:
    export foo=bar; \
    echo "foo=[$$foo]"
```

更好的方法是加上`.ONESHELL:`命令

```makefile
.ONESHELL:
var-kept:
    export foo=bar; 
    echo "foo=[$$foo]"
```

## 6.2 Makefile文件的语法

### 6.2.1 注释

井号`#`在`Makefile`中表示注释

```makefile
# 这是注释
result.txt: source.txt
    # 这是注释
    cp source.txt result.txt # 这也是注释
```

### 6.2.2 回声（echoing）

正常情况下，`make`会打印每条命令，然后再执行，这就叫做回声`echoing`

```makefile
test:
    # 这是测试
```

执行上面的规则，会得到下面的结果

```sh
$ make test
# 这是测试
```

在命令的前面加上`@`，就可以关闭回声

```makefile
test:
    @# 这是测试
```

### 6.2.3 通配符

通配符`wildcard`用来指定一组符合条件的文件名。`Makefile`的通配符与 `Bash`一致，主要有星号`*`、问号`？`和`...`。比如，`*.o`表示所有后缀名为`o`的文件

```makefile
clean:
        rm -f *.o
```

### 6.2.4 模式匹配

`make`命令允许对文件名，进行类似正则运算的匹配，主要用到的匹配符是`%`。比如，假定当前目录下有`f1.c`和`f2.c`两个源码文件，需要将它们编译为对应的对象文件

```makefile
%.o: %.c
```

等同于下面的写法

```makefile
f1.o: f1.c
f2.o: f2.c
```

**使用匹配符`%`，可以将大量同类型的文件，只用一条规则就完成构建**

### 6.2.5 变量和赋值符

`Makefile`允许使用等号自定义变量

```makefile
txt = Hello World
test:
    @echo $(txt)
```

上面代码中，变量`txt`等于`Hello World`。**调用时，变量需要放在`$()`之中**

**调用`shell`变量，需要在`$`前，再加一个`$`，这是因为`make`命令会对`$`转义**

```makefile
test:
    @echo $$HOME
```

### 6.2.6 内置变量（Implicit Variables）

`make`命令提供一系列内置变量，比如，`$(CC)`指向当前使用的编译器，`$(MAKE)`指向当前使用的`make`工具。这主要是为了跨平台的兼容性，详细的内置变量清单见[手册](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html)

```makefile
output:
    $(CC) -o output input.c
```

### 6.2.7 自动变量（Automatic Variables）

`make`命令还提供一些自动变量，它们的值与当前规则有关。主要有以下几个，可以参考[手册](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

#### 6.2.7.1 `$@`

`$@`指代当前目标，就是`make`命令当前构建的那个目标。比如，`make foo`的`$@`就指代`foo`

```makefile
a.txt b.txt: 
    touch $@
```

等同于下面的写法

```makefile
a.txt:
    touch a.txt
b.txt:
    touch b.txt
```

#### 6.2.7.2 `$<`

`$<`指代第一个前置条件。比如，规则为`t: p1 p2`，那么`$<`就指代`p1`

```makefile
a.txt: b.txt c.txt
    cp $< $@ 
```

等同于下面的写法

```makefile
a.txt: b.txt c.txt
    cp b.txt a.txt 
```

#### 6.2.7.3 `$?`

`$?`指代比目标更新的所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，其中`p2`的时间戳比`t`新，`$?`就指代`p2`

#### 6.2.7.4 `$^`

`$^`指代所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，那么`$^`就指代`p1 p2`

#### 6.2.7.5 `$*`

`$*`指代匹配符`%`匹配的部分，比如`%.txt`匹配`f1.txt`中的`f1`，`$*`就表示`f1`

#### 6.2.7.6 `$(@D)/$(@F)`

`$(@D)`和`$(@F)`分别指向`$@`的目录名和文件名。比如，`$@`是`src/input.c`，那么`$(@D)`的值为`src`，`$(@F)`的值为`input.c`

#### 6.2.7.7 `$(<D)/$(<F)`

`$(<D)`和`$(<F)`分别指向`$<`的目录名和文件名

#### 6.2.7.8 例子

```makefile
dest/%.txt: src/%.txt
    @[ -d dest ] || mkdir dest
    cp $< $@
```

上面代码将`src`目录下的`txt`文件，拷贝到`dest`目录下。首先判断`dest`目录是否存在，如果不存在就新建，然后，`$<`指代前置文件`src/%.txt`，`$@`指代目标文件`dest/%.txt`

### 6.2.8 判断和循环

`Makefile`使用`Bash`语法，完成判断和循环

```makefile
ifeq ($(CC),gcc)
  libs=$(libs_for_gcc)
else
  libs=$(normal_libs)
endif
```

```makefile
LIST = one two three
all:
    for i in $(LIST); do \
        echo $$i; \
    done

# 等同于

all:
    for i in one two three; do \
        echo $$i; \
    done
```

### 6.2.9 函数

`Makefile`还可以使用函数，格式如下

```makefile
$(function arguments)
# 或者
${function arguments}
```

`Makefile`提供了许多[内置函数](https://www.gnu.org/software/make/manual/html_node/Functions.html)，可供调用

## 6.3 参考

* [Make 命令教程](https://www.ruanyifeng.com/blog/2015/02/make.html)

# 7 CMake

## 7.1 tutorial

### 7.1.1 step1: A Basic Starting Point

`tutorial.cxx`内容如下：

```c++
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " number" << std::endl;
    return 1;
  }

  // convert input to double
  const double inputValue = atof(argv[1]);

  // calculate square root
  const double outputValue = sqrt(inputValue);
  std::cout << "The square root of " << inputValue << " is " << outputValue
            << std::endl;
  return 0;
}
```

`CMakeLists.txt`内容如下：

* `cmake_minimum_required`：用于指定`cmake`的最小版本，避免出现兼容性问题（包含了高级版本的特性，但是实际的`cmake`版本较小）
* `project`：用于设置项目名称，并存储到`CMAKE_PROJECT_NAME`变量中，`cmake`中的一些环境变量会以这里指定的项目名称作为前缀，例如
    * `PROJECT_SOURCE_DIR`、`<PROJECT-NAME>_SOURCE_DIR`
    * `PROJECT_BINARY_DIR`、`<PROJECT-NAME>_BINARY_DIR`
* `set`：用于设置一些变量
* `add_executable`：添加目标可执行文件

```cmake
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# add the executable
add_executable(Tutorial tutorial.cxx)
```

此时文件结构如下：

```
.
├── CMakeLists.txt
└── tutorial.cxx
```

测试：

```sh
mkdir build
cd build
cmake ..
make
./Tutorial 256
```

### 7.1.2 step2: Adding a Library and Adding Usage Requirements for a Library

接下来，我们用自己实现的求开方的函数替换标准库中的实现。创建`MathFunctions`子目录，并在该子目录添加`MathFunctions.h`以及`mysqrt.cxx`、`CMakeLists.txt`三个文件

`MathFunctions/MathFunctions.h`内容如下：

```c++
double mysqrt(double x);
```

`MathFunctions/mysqrt.cxx`内容如下：

```c++
#include <iostream>

// a hack square root calculation using simple operations
double mysqrt(double x)
{
  if (x <= 0) {
    return 0;
  }

  double result = x;

  // do ten iterations
  for (int i = 0; i < 10; ++i) {
    if (result <= 0) {
      result = 0.1;
    }
    double delta = x - (result * result);
    result = result + 0.5 * delta / result;
    std::cout << "Computing sqrt of " << x << " to be " << result << std::endl;
  }
  return result;
}
```

`MathFunctions/CMakeLists.txt`内容如下：

```cmake
add_library(MathFunctions mysqrt.cxx)
```

添加`TutorialConfig.h.in`文件，内容如下：

```c++
#cmakedefine USE_MYMATH
```

修改`tutorial.cxx`文件，内容如下：

```c++
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>
#include "TutorialConfig.h"
#ifdef USE_MYMATH
#  include "MathFunctions.h"
#endif

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " number" << std::endl;
    return 1;
  }

  // convert input to double
  const double inputValue = atof(argv[1]);

  // calculate square root
#ifdef USE_MYMATH
  const double outputValue = mysqrt(inputValue);
#else
  const double outputValue = sqrt(inputValue);
#endif
  std::cout << "The square root of " << inputValue << " is " << outputValue
            << std::endl;
  return 0;
}
```

修改`CMakeLists.txt`文件，内容如下：

* `option`：用于添加`cmake`选项，可以通过`-D<OPTION-NAME>=ON/OFF`参数来选择打开或者关闭该选项
    * 例如`cmake .. -DUSE_MYMATH=OFF`
* `configure_file`：一般用于根据cmake选项动态生成头文件
* `if statement`：控制流
* `add_subdirectory`：用于将子目录添加到构建任务中
* `list`：容器相关的操作
* `target_link_libraries`：指定库文件
* `target_include_directories`：指定头文件搜索路径

```cmake
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

option(USE_MYMATH "Use tutorial provided math implementation" ON)

# configure a header file to pass some of the CMake settings
# to the source code
configure_file(TutorialConfig.h.in TutorialConfig.h)

if(USE_MYMATH)
  add_subdirectory(MathFunctions)
  list(APPEND EXTRA_LIBS MathFunctions)
  list(APPEND EXTRA_INCLUDES "${PROJECT_SOURCE_DIR}/MathFunctions")
endif()

# add the executable
add_executable(Tutorial tutorial.cxx)

target_link_libraries(Tutorial PUBLIC ${EXTRA_LIBS})

# add the binary tree to the search path for include files
# so that we will find TutorialConfig.h
target_include_directories(Tutorial PUBLIC
                           "${PROJECT_BINARY_DIR}"
                           ${EXTRA_INCLUDES}
                           )
```

此时目录结构如下：

```
.
├── CMakeLists.txt
├── MathFunctions
│   ├── CMakeLists.txt
│   ├── MathFunctions.h
│   └── mysqrt.cxx
├── TutorialConfig.h.in
└── tutorial.cxx
```

测试：

```sh
# 使用的是自定义的sqrt函数
mkdir build
cd build
cmake ..
make
./Tutorial 256

# 使用的是标准库的sqrt函数
mkdir build
cd build
cmake .. -DUSE_MYMATH=OFF
make
./Tutorial 256
```

### 7.1.3 step3: Installing

现在，我们要安装`make`后产生的二进制、库文件、头文件

在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* 其中这里指定了两个相对路径`lib`、`include`。前缀由`cmake`变量`CMAKE_INSTALL_PREFIX`确定，默认值为`/usr/local`

```cmake
# add the install targets
install (TARGETS MathFunctions DESTINATION bin)
install(FILES MathFunctions.h DESTINATION include)
```

在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

```cmake
# add the install targets
install (TARGETS Tutorial DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/TutorialConfig.h" DESTINATION include)
```

测试：

```sh
# 使用默认的安装路径
mkdir build
cd build
cmake ..
make
make install

# 指定安装路径
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/mydir
make
make install
```

### 7.1.4 step4: Testing

接下来，增加测试功能。在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

* `add_test`：用于增加测试，其中`NAME`指定的是测试用例的名称，`RUN`指定的是测试的命令
* `function`：用于定义一个方法
* `set_tests_properties`：用于设置测试项的属性，这里指定了测试结果的通配符

```cmake
enable_testing()

# does the application run
add_test(NAME Runs COMMAND Tutorial 25)

# does the usage message work?
add_test(NAME Usage COMMAND Tutorial)
set_tests_properties(Usage
  PROPERTIES PASS_REGULAR_EXPRESSION "Usage:.*number"
  )

# define a function to simplify adding tests
function(do_test target arg result)
  add_test(NAME Comp_${arg} COMMAND ${target} ${arg})
  set_tests_properties(Comp_${arg}
    PROPERTIES PASS_REGULAR_EXPRESSION ${result}
    )
endfunction(do_test)

# do a bunch of result based tests
do_test(Tutorial 4 "4 is 2")
do_test(Tutorial 9 "9 is 3")
do_test(Tutorial 5 "5 is 2.236")
do_test(Tutorial 7 "7 is 2.645")
do_test(Tutorial 25 "25 is 5")
do_test(Tutorial -25 "-25 is [-nan|nan|0]")
do_test(Tutorial 0.0001 "0.0001 is 0.01")
```

测试：

```
mkdir build
cd build
cmake ..
make
make test
```

### 7.1.5 step5: Adding System Introspection

同一个库，在不同平台上的实现可能不同，例如A平台有方法`funcA`，而B平台没有`funcA`，因此我们需要有一种机制来检测这种差异

接下来，增加测试功能。在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* `include`：加载`cmake`模块，这里加载了`CheckSymbolExists`模块，该模块用于检测指定文件中的指定符号是否存在

```cmake
include(CheckSymbolExists)
check_symbol_exists(log "math.h" HAVE_LOG)
check_symbol_exists(exp "math.h" HAVE_EXP)
if(NOT (HAVE_LOG AND HAVE_EXP))
  unset(HAVE_LOG CACHE)
  unset(HAVE_EXP CACHE)
  set(CMAKE_REQUIRED_LIBRARIES "m")
  check_symbol_exists(log "math.h" HAVE_LOG)
  check_symbol_exists(exp "math.h" HAVE_EXP)
  if(HAVE_LOG AND HAVE_EXP)
    target_link_libraries(MathFunctions PRIVATE m)
  endif()
endif()

if(HAVE_LOG AND HAVE_EXP)
  target_compile_definitions(MathFunctions
                             PRIVATE "HAVE_LOG" "HAVE_EXP")
endif()
```

修改`MathFunctions/mysqrt.cxx`文件，内容如下：

```c++
#include <iostream>
#include <cmath>

// a hack square root calculation using simple operations
double mysqrt(double x)
{
  if (x <= 0) {
    return 0;
  }

#if defined(HAVE_LOG) && defined(HAVE_EXP)
  double result = exp(log(x) * 0.5);
  std::cout << "Computing sqrt of " << x << " to be " << result
            << " using log and exp" << std::endl;
#else
  double result = x;

  // do ten iterations
  for (int i = 0; i < 10; ++i) {
    if (result <= 0) {
      result = 0.1;
    }
    double delta = x - (result * result);
    result = result + 0.5 * delta / result;
    std::cout << "Computing sqrt of " << x << " to be " << result << std::endl;
  }
#endif
  return result;
}
```

测试：

```
mkdir build
cd build
cmake ..
make
./Tutorial 25
```

## 7.2 target

`cmake`可以使用`add_executable`、`add_library`或`add_custom_target`等命令来定义目标`target`。与变量不同，目标在每个作用域都可见，且可以使用`get_property`和`set_property`获取或设置其属性

## 7.3 property

### 7.3.1 INCLUDE_DIRECTORIES

1. `include_directories`：该方法会在全局维度添加`include`的搜索路径。这些搜索路径会被添加到所有`target`中去（包括所有`sub target`），会追加到所有`target`的`INCLUDE_DIRECTORIES`属性中去
1. `target_include_directories`：该方法为指定`target`添加`include`的搜索路径，会追加到该`target`的`INCLUDE_DIRECTORIES`属性中去

如何查看全局维度以及target维度的`INCLUDE_DIRECTORIES`属性值

```cmake
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
  message(STATUS "dir of include_directories='${dir}'")
endforeach()

get_target_property(target_dirs <TARGET-NAME> INCLUDE_DIRECTORIES)
foreach(target_dir ${target_dirs})
  message(STATUS "dir of target_include_directories='${target_dir}'")
endforeach()
```

## 7.4 command

### 7.4.1 message

用于打印信息

格式：`message([<mode>] "message text" ...)`

合法的`mode`包括

* `FATAL_ERROR`：致命错误，终止构建
* `SEND_ERROR`：继续构建，终止`generation`
* `WARNING`：告警信息，继续构建
* `AUTHOR_WARNING`：告警信息，继续构建
* `DEPRECATION`：当`CMAKE_ERROR_DEPRECATED`或`CMAKE_WARN_DEPRECATED`参数启用时，若使用了`deprecated`的特性，会打印`error`或者`warn`信息
* `NOTICE`：通过`stderr`打印的信息
* **`STATUS`：用户最应该关注的信息**
* `VERBOSE`：项目构建者需要关注的信息
* `DEBUG`：项目调试需要关注的信息
* `TRACE`：最低级别的信息

### 7.4.2 set

`set`用于设置：`cmake`变量或环境变量

格式：

* `cmake`变量：`set(<variable> <value>... [PARENT_SCOPE])`
* 环境变量：`set(ENV{<variable>} [<value>]`

变量如何引用：

* `cmake`变量：`${<variable>}`
* 环境变量：`$ENV{<variable>}`

### 7.4.3 option

`option`用于设置构建选项

格式：`option(<variable> "<help_text>" [value])`

* 其中`value`的可选值就是`ON`和`OFF`，其中`OFF`是默认值

### 7.4.4 file

`file`用于文件操作

格式：

* `file(READ <filename> <out-var> [...])`
* `file({WRITE | APPEND} <filename> <content>...)`

操作类型说明：

* `READ`：读取文件到变量中
* `WRITE`：覆盖写，文件不存在就创建
* `APPEND`：追加写，文件不存在就创建

### 7.4.5 add_executable

`add_executable`用于添加可执行文件

### 7.4.6 add_library

`add_library`用于添加链接文件

### 7.4.7 target_link_libraries

`target_link_libraries`指定链接给定目标时要使用的库或标志

### 7.4.8 include_directories

`include_directories`：该方法会在全局维度添加`include`的搜索路径。这些搜索路径会被添加到所有`target`中去（包括所有`sub target`），会追加到所有`target`的`INCLUDE_DIRECTORIES`属性中去

### 7.4.9 target_include_directories

`target_include_directories`：该方法为指定`target`添加`include`的搜索路径，会追加到该`target`的`INCLUDE_DIRECTORIES`属性中去

### 7.4.10 include

`include`用于加载模块

### 7.4.11 find_package

**本小节转载摘录自[Cmake之深入理解find_package()的用法](https://zhuanlan.zhihu.com/p/97369704)**

为了方便我们在项目中引入外部依赖包，`cmake`官方为我们预定义了许多寻找依赖包的`Module`，他们存储在`path_to_your_cmake/share/cmake-<version>/Modules`目录下。每个以`Find<LibaryName>.cmake`命名的文件都可以帮我们找到一个包。**注意，`find_package(<LibaryName>)`与`Find<LibaryName>.cmake`中的`<LibaryName>`部分，大小写必须完全一致**

我们以`curl`库为例，假设我们项目需要引入这个库，从网站中请求网页到本地，我们看到官方已经定义好了`FindCURL.cmake`。所以我们在`CMakeLists.txt`中可以直接用`find_pakcage`进行引用

对于系统预定义的`Find<LibaryName>.cmake`模块，使用方法如下，每一个模块都会定义以下几个变量（这些信息会在`Find<LibaryName>.cmake`文件的最上方注释中说明）。**注意，这些变量命名只是规范，命名中`<LibaryName>`部分是全部大写还是包含大小写完全由`Find<LibaryName>.cmake`文件决定。一般来说是大写的，例如`FindDemo.cmake`中定义的变量名为`DEMO_FOUND`**

* `<LibaryName>_FOUND`
* `<LibaryName>_INCLUDE_DIR`
* `<LibaryName>_LIBRARY`：该模块通过`add_library`定义的名称
* `<LibaryName>_STATIC_LIB`

```cmake
find_package(CURL)
add_executable(curltest curltest.cc)
if(CURL_FOUND)
    target_include_directories(clib PRIVATE ${CURL_INCLUDE_DIR})
    target_link_libraries(curltest ${CURL_LIBRARY})
else(CURL_FOUND)
    message(FATAL_ERROR ”CURL library not found”)
endif(CURL_FOUND)
```

你可以通过`<LibaryName>_FOUND`来判断模块是否被找到，如果没有找到，按照工程的需要关闭某些特性、给出提醒或者中止编译，上面的例子就是报出致命错误并终止构建。如果`<LibaryName>_FOUND`为真，则将`<LibaryName>_INCLUDE_DIR`加入`INCLUDE_DIRECTORIES`

#### 7.4.11.1 引入非官方的库

**通过`find_package`引入非官方的库，该方式只对支持cmake编译安装的库有效**

假设此时我们需要引入`glog`库来进行日志的记录，我们在`Module`目录下并没有找到`FindGlog.cmake`。所以我们需要自行安装`glog`库，再进行引用

```sh
# clone该项目
git clone https://github.com/google/glog.git 
# 切换到需要的版本 
cd glog
git checkout v0.40  

# 根据官网的指南进行安装
cmake -H. -Bbuild -G "Unix Makefiles"
cmake --build build
cmake --build build --target install
```

此时我们便可以通过与引入`curl`库一样的方式引入`glog`库了

```cmake
find_package(GLOG)
add_executable(glogtest glogtest.cc)
if(GLOG_FOUND)
    # 由于glog在连接时将头文件直接链接到了库里面，所以这里不用显示调用target_include_directories
    target_link_libraries(glogtest glog::glog)
else(GLOG_FOUND)
    message(FATAL_ERROR ”GLOG library not found”)
endif(GLOG_FOUND)
```

#### 7.4.11.2 Module模式与Config模式

通过上文我们了解了通过`cmake`引入依赖库的基本用法。知其然也要知其所以然，`find_package`对我们来说是一个黑盒子，那么它是具体通过什么方式来查找到我们依赖的库文件的路径的呢。到这里我们就不得不聊到`find_package`的两种模式，一种是`Module`模式，也就是我们引入`curl`库的方式。另一种叫做`Config`模式，也就是引入`glog`库的模式。下面我们来详细介绍着两种方式的运行机制

在`Module`模式中，`cmake`需要找到一个叫做`Find<LibraryName>.cmake`的文件。这个文件负责找到库所在的路径，为我们的项目引入头文件路径和库文件路径。`cmake`搜索这个文件的路径有两个，一个是上文提到的`cmake`安装目录下的`share/cmake-<version>/Modules`目录，另一个使我们指定的`CMAKE_MODULE_PATH`的所在目录

如果`Module`模式搜索失败，没有找到对应的`Find<LibraryName>.cmake`文件，则转入`Config`模式进行搜索。它主要通过`<LibraryName>Config.cmake`或`<lower-case-package-name>-config.cmake`这两个文件来引入我们需要的库。以我们刚刚安装的`glog`库为例，在我们安装之后，它在`/usr/local/lib/cmake/glog/`目录下生成了`glog-config.cmake`文件，而`/usr/local/lib/cmake/<LibraryName>/`正是`find_package`函数的搜索路径之一

#### 7.4.11.3 编写自己的`Find<LibraryName>.cmake`模块

假设我们编写了一个新的函数库，我们希望别的项目可以通过`find_package`对它进行引用我们应该怎么办呢。

我们在当前目录下新建一个`ModuleMode`的文件夹，在里面我们编写一个计算两个整数之和的一个简单的函数库。库函数以手工编写`Makefile`的方式进行安装，库文件安装在`/usr/lib`目录下，头文件放在`/usr/include`目录下。其中的Makefile文件如下：

```makefile
# 1、准备工作，编译方式、目标文件名、依赖库路径的定义。
CC = g++
CFLAGS  := -Wall -O3 -std=c++11 

OBJS = libadd.o #.o文件与.cpp文件同名
LIB = libadd.so # 目标文件名
INCLUDE = ./ # 头文件目录
HEADER = libadd.h # 头文件

all : $(LIB)

# 2. 生成.o文件 
$(OBJS) : libadd.cc
    $(CC) $(CFLAGS) -I ./ -fpic -c $< -o $@

# 3. 生成动态库文件
$(LIB) : $(OBJS)
    rm -f $@
    g++ $(OBJS) -shared -o $@ 
    rm -f $(OBJS)

# 4. 删除中间过程生成的文件 
clean:
    rm -f $(OBJS) $(TARGET) $(LIB)

# 5.安装文件
install:
    cp $(LIB) /usr/lib
    cp $(HEADER) /usr/include
```

编译安装：

```sh
make
make install
```

接下来我们回到我们的`cmake`项目中来，在`cmake`文件夹下新建一个`FindAdd.cmake`的文件。我们的目标是找到库的头文件所在目录和共享库文件的所在位置

```cmake
# 在指定目录下寻找头文件和动态库文件的位置，可以指定多个目标路径
find_path(ADD_INCLUDE_DIR libadd.h /usr/include/ /usr/local/include ${CMAKE_SOURCE_DIR}/ModuleMode)
find_library(ADD_LIBRARY NAMES add PATHS /usr/lib/add /usr/local/lib/add ${CMAKE_SOURCE_DIR}/ModuleMode)

if (ADD_INCLUDE_DIR AND ADD_LIBRARY)
    set(ADD_FOUND TRUE)
endif (ADD_INCLUDE_DIR AND ADD_LIBRARY)
```

这时我们便可以像引用`curl`一样引入我们自定义的库了，在`CMakeLists.txt`添加

```cmake
# 将项目目录下的cmake文件夹加入到CMAKE_MODULE_PATH中，让find_pakcage能够找到我们自定义的函数库
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;${CMAKE_MODULE_PATH}")
add_executable(addtest addtest.cc)
find_package(ADD)
if(ADD_FOUND)
    target_include_directories(addtest PRIVATE ${ADD_INCLUDE_DIR})
    target_link_libraries(addtest ${ADD_LIBRARY})
else(ADD_FOUND)
    message(FATAL_ERROR "ADD library not found")
endif(ADD_FOUND)
```

### 7.4.12 aux_source_directory

Find all source files in a directory

## 7.5 Tips

### 7.5.1 打印cmake中所有的变量

```cmake
get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
```

### 7.5.2 打印cmake中所有环境变量

```cmake
execute_process(COMMAND "${CMAKE_COMMAND}" "-E" "environment")
```

### 7.5.3 同一目录，多个源文件

如果同一个目录下有多个源文件，那么在使用`add_executable`命令的时候，如果要一个个填写，那么将会非常麻烦，并且后续维护的代价也很大

```
add_executable(Demo main.cxx opt1.cxx opt2.cxx)
```

我们可以使用`aux_source_directory(<dir> <variable>)`）命令，该命令可以扫描一个目录下得所有源文件，并将文件列表赋值给一个变量

```sh
# 查找当前目录下的所有源文件
# 并将名称保存到 DIR_SRCS 变量
aux_source_directory(. DIR_SRCS)

# 指定生成目标
add_executable(Demo ${DIR_SRCS})
```

## 7.6 参考

* [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
    * [CMake Tutorial对应的source code](https://github.com/Kitware/CMake/tree/master/Help/guide/tutorial)
    * [CMake Tutorial 翻译](https://www.jianshu.com/p/6df3857462cd)
* [CMake 入门实战](https://www.hahack.com/codes/cmake/)
* [CMake 语言 15 分钟入门教程](https://leehao.me/cmake-%E8%AF%AD%E8%A8%80-15-%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
* [CMake Table of Contents](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#manual:cmake-buildsystem(7))
* [What is the difference between include_directories and target_include_directories in CMake?](https://stackoverflow.com/questions/31969547/what-is-the-difference-between-include-directories-and-target-include-directorie/40244458)
* [Cmake之深入理解find_package()的用法](https://zhuanlan.zhihu.com/p/97369704)
