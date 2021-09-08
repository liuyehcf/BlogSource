---
title: Cpp-标准库
date: 2021-09-06 10:54:02
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 `<utility>`

## 1.1 std::move

标准库的实现如下：

```cpp
  template<typename _Tp>
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```

本质上，就是做了一次类型转换，返回的一定是个右值。其中，`remove_reference`是个`traits`，用于萃取出原始类型（不带任何引用）

## 1.2 std::forward

`std::forward`主要用于实现模板的完美转发：因为对于一个变量而言，无论该变量的类型是左值引用还是右值引用，变量本身都是左值，如果直接将变量传递到下一个方法中，那么一定是按照左值来匹配重载函数的，而`std::forward`就是为了解决这个问题。请看下面这个例子：

```cpp
#include <iostream>

void func(int &value) {
    std::cout << "left reference version, value=" << value << std::endl;
}

void func(int &&value) {
    std::cout << "right reference version, value=" << value << std::endl;
}

template<typename T>
void dispatch_without_forward(T &&t) {
    func(t);
}

template<typename T>
void dispatch_with_forward(T &&t) {
    func(std::forward<T>(t));
}

int main() {
    int value = 0;
    dispatch_without_forward(value); // left reference version, value=0
    dispatch_without_forward(1); // left reference version, value=1

    value = 2;
    dispatch_with_forward(value); // left reference version, value=2
    dispatch_with_forward(3); // right reference version, value=3

    value = 4;
    func(std::forward<int>(value)); // right reference version, value=4 (!!! very strange !!!)
    value = 5;
    func(std::forward<int &>(value)); // left reference version, value=5
    func(std::forward<int &&>(6)); // right reference version, value=6
}
```

标准库的实现如下：

```cpp
  template<typename _Tp>
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type& __t) noexcept
    { return static_cast<_Tp&&>(__t); }

  template<typename _Tp>
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type&& __t) noexcept
    {
      static_assert(!std::is_lvalue_reference<_Tp>::value, "template argument"
                    " substituting _Tp is an lvalue reference type");
      return static_cast<_Tp&&>(__t);
    }
```

**在使用`std::forward`时，模板实参都是需要显式指定的，而不是推断出来的**

* 如果模板实参是左值、左值引用或右值引用，那么匹配第一个方法
    * 左值：`_Tp&&`得到的是个右值（很奇怪吧，因为一般都不是这么用的）
    * **左值引用：`_Tp&&`得到的是个左值引用（完美转发会用到）**
    * **右值应用：`_Tp&&`得到的是个右值引用（完美转发会用到）**
* 如果模板实参是左值或右值，那么匹配的是第二个方法
    * 右值：`_Tp&&`得到的是个右值

# 2 `<future>`

## 2.1 std::promise

## 2.2 std::future

# 3 `<string>`

## 3.1 std::string

字符串比较函数：`strcmp`

# 4 `<thread>`

## 4.1 std::thread

# 5 `<chrono>`

## 5.1 std::chrono

# 6 `<memory>`

## 6.1 std::shared_ptr

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

## 6.2 std::unique_ptr

## 6.3 参考

* [C++ 智能指针的正确使用方式](https://www.cyhone.com/articles/right-way-to-use-cpp-smart-pointer/)

# 7 `<functional>`

## 7.1 std::function

其功能类似于函数指针，在需要函数指针的地方，可以传入`std::function`类型的对象（不是指针）

## 7.2 std::bind

## 7.3 std::mem_fn

## 7.4 参考

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)

# 8 `<mutex>`

## 8.1 std::mutex

## 8.2 std::lock_guard

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

## 8.3 std::unique_lock

## 8.4 std::condition_variable

调用`wait`方法时，必须获取监视器。而调用`notify`方法时，无需获取监视器

## 8.5 参考

* [Do I have to acquire lock before calling condition_variable.notify_one()?](https://stackoverflow.com/questions/17101922/do-i-have-to-acquire-lock-before-calling-condition-variable-notify-one)

# 9 `<atomic>`

## 9.1 内存模型

### 9.1.1 顺序一致性

> the result of any execution is the same as if the operations of all the processors were executed in some sequential order, and the operations of each individual processor appear in this sequence in the order specified by its program

**SC其实就是规定了两件事情：**

1. **每个线程内部的指令都是按照程序规定的顺序（program order）执行的（单个线程的视角）**
1. **线程执行的交错顺序可以是任意的，但是所有线程所看见的整个程序的总体执行顺序都是一样的（整个程序的视角）**

## 9.2 std::atomic

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

## 9.3 std::memory_order

这是个枚举类型，包含6个枚举值

* `memory_order_relaxed`
* `memory_order_consume`
* `memory_order_acquire`
* `memory_order_release`
* `memory_order_acq_rel`
* `memory_order_seq_cst`

### 9.3.1 顺序一致次序（sequential consisten ordering）

`memory_order_seq_cst`属于这种内存模型

`SC`作为默认的内存序，是因为它意味着将程序看做是一个简单的序列。如果对于一个原子变量的操作都是顺序一致的，那么多线程程序的行为就像是这些操作都以一种特定顺序被单线程程序执行

### 9.3.2 松弛次序（relaxed ordering）

`memory_order_relaxed`属于这种内存模型

在原子变量上采用`relaxed ordering`的操作不参与`synchronized-with`关系。在同一线程内对同一变量的操作仍保持`happens-before`关系，但这与别的线程无关

在`relaxed ordering`中唯一的要求是在同一线程中，对同一原子变量的访问不可以被重排

### 9.3.3 获取-释放次序（acquire-release ordering）

`memory_order_release`、`memory_order_acquire`、`memory_order_acq_rel`属于这种内存模型

## 9.4 参考

* [C++11 - atomic类型和内存模型](https://zhuanlan.zhihu.com/p/107092432)
* [doc-std::memory_order](https://www.apiref.com/cpp-zh/cpp/atomic/memory_order.html)
* [如何理解 C++11 的六种 memory order？](https://www.zhihu.com/question/24301047)
* [并行编程——内存模型之顺序一致性](https://www.cnblogs.com/jiayy/p/3246157.html)

# 10 `<any>`

## 10.1 std::any_cast

# 11 `<type_traits>`

## 11.1 std::conditional_t

## 11.2 std::remove_reference

