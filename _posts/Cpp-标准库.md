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

# 1 any

## 1.1 std::any_cast

# 2 atomic

## 2.1 内存一致性模型

### 2.1.1 Sequential consistency model

> the result of any execution is the same as if the operations of all the processors were executed in some sequential order, and the operations of each individual processor appear in this sequence in the order specified by its program

**`Sequential consistency model（SC）`，也称为顺序一致性模型，其实就是规定了两件事情：**

1. **每个线程内部的指令都是按照程序规定的顺序（program order）执行的（单个线程的视角）**
1. **线程执行的交错顺序可以是任意的，但是所有线程所看见的整个程序的总体执行顺序都是一样的（整个程序的视角）**
    * 即不能存在这样一种情况，对于写操作`W1`和`W2`，处理器1看来，顺序是：`W1 -> W2`；而处理器2看来，顺序是：`W2 -> W1`

### 2.1.2 Relaxed consistency model

**`Relaxed consistency model`也称为宽松内存一致性模型，它的特点是：**

1. **唯一的要求是在同一线程中，对同一原子变量的访问不可以被重排（单个线程的视角）**
1. **除了保证操作的原子性之外，没有限定前后指令的顺序，其他线程看到数据的变化顺序也可能不一样（整个程序的视角）**

## 2.2 std::atomic

`compare_exchange_strong(T& expected_value, T new_value)`方法的第一个参数是个左值

* 当前值与期望值`expected_value`相等时，修改当前值为设定值`new_value`，返回true
* 当前值与期望值`expected_value`不等时，将期望值修改为当前值，返回false（这样更加方便循环，否则还得手动再读一次）

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

**`compare_exchange_weak(T& expected_value, T new_value)`方法与`strong`版本基本相同，唯一的区别是`weak`版本允许偶然出乎意料的返回（相等时却返回了false），在大部分场景中，这种意外是可以接受的，通常比`strong`版本有更高的性能**

## 2.3 std::memory_order

这是个枚举类型，包含6个枚举值

* `memory_order_relaxed`
* `memory_order_consume`
* `memory_order_acquire`
* `memory_order_release`
* `memory_order_acq_rel`
* `memory_order_seq_cst`

### 2.3.1 顺序一致次序（sequential consisten ordering）

`memory_order_seq_cst`属于这种内存模型

`SC`作为默认的内存序，是因为它意味着将程序看做是一个简单的序列。如果对于一个原子变量的操作都是顺序一致的，那么多线程程序的行为就像是这些操作都以一种特定顺序被单线程程序执行

**该原子操作前后的读写（包括非原子的读写操作）不能跨过该操作乱序；该原子操作之前的写操作（包括非原子的写操作）都能被所有线程观察到**

### 2.3.2 松弛次序（relaxed ordering）

`memory_order_relaxed`属于这种内存模型

在原子变量上采用`relaxed ordering`的操作不参与`synchronized-with`关系。在同一线程内对同一变量的操作仍保持`happens-before`关系，但这与别的线程无关

在`relaxed ordering`中唯一的要求是在同一线程中，对同一原子变量的访问不可以被重排

### 2.3.3 获取-释放次序（acquire-release ordering）

`memory_order_release`、`memory_order_acquire`、`memory_order_acq_rel`属于这种内存模型

`memory_order_release`用于写操作`store`，`memory_order_acquire`用于读操作`load`

* `memory_order_release`「原子操作之前的读写（包括非原子的读写）」不能往后乱序；并且之前的写操作（包括非原子的写操作），会被使用`acquire/consume`的线程观察到，这里要注意它和`seq_cst`不同的是只有相关的线程才能观察到写变化，所谓相关线程就是使用`acquire`或`consume`模式加载同一个共享变量的线程；而`seq_cst`是所有线程都观察到了
* `memory_order_acquire`「原子操作之后的读写」不能往前乱序；它能看到`release`线程在调用`load`之前的那些写操作
* `memory_order_acq_rel`是`memory_order_release`与`memory_order_acquire`的合并，前后的读写都是不能跨过这个原子操作，但仅相关的线程能看到前面写的变化
* `memory_order_consume`和`memory_order_acquire`比较接近，也是和`memory_order_release`一起使用的；和`memory_order_acquire`不一样的地方是加了一个限定条件：依赖于该读操作的后续读写不能往前乱序；它可以看到release线程在调用load之前那些依赖的写操作，依赖于的意思是和该共享变量有关的写操作

看个例子：

```
-Thread 1-
 n = 1
 m = 1
 p.store (&n, memory_order_release)

-Thread 2-
 t = p.load (memory_order_acquire);
 if (*t == 1)
    assert(m == 1);

-Thread 3-
 t = p.load (memory_order_consume);
 if (*t == 1)
    assert(m == 1);
```

* 线程2的断言会成功，因为线程1对`n`和`m`在store之前修改；线程2在`load`之后，可以观察到`m`的修改
* 但线程3的断言不一定会成功，因为`m`是和`load/store`操作不相关的变量，线程3不一定能观察看到

## 2.4 参考

* [C++11 - atomic类型和内存模型](https://zhuanlan.zhihu.com/p/107092432)
* [doc-std::memory_order](https://www.apiref.com/cpp-zh/cpp/atomic/memory_order.html)
* [如何理解 C++11 的六种 memory order？](https://www.zhihu.com/question/24301047)
* [并行编程——内存模型之顺序一致性](https://www.cnblogs.com/jiayy/p/3246157.html)
* [漫谈内存一致性模型](https://zhuanlan.zhihu.com/p/91406250)

# 3 chrono

## 3.1 clock

**三种时钟：**

1. `steady_clock`：是单调的时钟。其绝对值无意义，只会增长，适合用于记录程序耗时。
1. `system_clock`：是系统的时钟，且系统的时钟可以修改，甚至可以网络对时。所以用系统时间计算时间差可能不准
1. `high_resolution_clock`：是当前系统能够提供的最高精度的时钟。它也是不可以修改的。相当于`steady_clock`的高精度版本

```sh
auto start = std::chrono::steady_clock::now();
auto end = std::chrono::steady_clock::now();
auto nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
```

# 4 functional

## 4.1 std::function

其功能类似于函数指针，在需要函数指针的地方，可以传入`std::function`类型的对象（不是指针）

## 4.2 std::bind

## 4.3 std::mem_fn

## 4.4 参考

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)

# 5 future

## 5.1 std::promise

## 5.2 std::future

# 6 limits

## 6.1 std::numeric_limits

`std::numeric_limits<int32_t>::max()`

# 7 memory

## 7.1 std::shared_ptr

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

## 7.2 std::enable_shared_from_this

**`std::enable_shared_from_this`能让一个由`std::shared_ptr`管理的对象，安全地生成其他额外的`std::shared_ptr`实例，原实例和新生成的示例共享所有权**

* 只能通过`std::make_shared`来创建实例（不能用`new`），否则会报错
* 普通对象（非只能指针管理）调用`std::enable_shared_from_this::shared_from_this`方法，也会报错

**有什么用途？当你持有的是某个对象的裸指针时（该对象的生命周期由智能指针管理），但此时你又想获取该对象的智能指针，此时就需要依赖`std::enable_shared_from_this`**

* 不能将`this`直接放入某个`std::shared_ptr`中，这样会导致`delete`野指针

```cpp
class Demo : public std::enable_shared_from_this<Demo> {
};

int main() {
    auto ptr = std::make_shared<Demo>();
    auto another_ptr = ptr->shared_from_this();

    std::cout << ptr << std::endl;
    std::cout << another_ptr.get() << std::endl;
}
```

## 7.3 std::unique_ptr

## 7.4 参考

* [C++ 智能指针的正确使用方式](https://www.cyhone.com/articles/right-way-to-use-cpp-smart-pointer/)

# 8 mutex

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

# 9 numeric

## 9.1 std::accumulate

```cpp
int main() {
    std::set<std::string> col = {"a", "b", "c"};

    std::string res = std::accumulate(std::begin(col),
                                      std::end(col),
                                      std::string(),
                                      [](const std::string &a, const std::string &b) {
                                          return a.empty() ? b
                                                           : a + ", " + b;
                                      });

    std::cout << res << std::endl;
}
```

# 10 string

## 10.1 std::string

字符串比较函数：`strcmp`

# 11 thread

## 11.1 std::thread

**如何设置或修改线程名：**

1. `pthread_setname_np/pthread_getname_np`，需要引入头文件`<pthread.h>`
1. `prctl(PR_GET_NAME, name)/prctl(PR_SET_NAME, name)`，需要引入头文件`<sys/prctl.h>`

```cpp
#include <pthread.h>
#include <sys/prctl.h>

#include <chrono>
#include <functional>
#include <iostream>
#include <sstream>
#include <thread>

void* change_thread_name(void* = nullptr) {
    // avoid change name before set original thread name
    std::this_thread::sleep_for(std::chrono::seconds(1));

    char original_thread_name[16];
    prctl(PR_GET_NAME, original_thread_name);
    uint32_t cnt = 0;

    while (true) {
        if (cnt > 1000) {
            cnt = 0;
        }

        std::stringstream ss;
        ss << original_thread_name << "-" << cnt++;
        prctl(PR_SET_NAME, ss.str().data());

        char current_thread_name[16];
        prctl(PR_GET_NAME, current_thread_name);
        std::cout << current_thread_name << std::endl;

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    return nullptr;
}

void create_thread_by_pthread() {
    pthread_t tid;
    pthread_create(&tid, nullptr, change_thread_name, nullptr);
    pthread_setname_np(tid, "pthread");
    pthread_detach(tid);
}

void create_thread_by_std() {
    std::function<void()> func = []() { change_thread_name(); };
    std::thread t(func);
    pthread_setname_np(t.native_handle(), "std-thread");
    t.detach();
}

int main() {
    std::this_thread::sleep_for(std::chrono::milliseconds(333));
    create_thread_by_pthread();

    std::this_thread::sleep_for(std::chrono::milliseconds(333));
    create_thread_by_std();

    prctl(PR_SET_NAME, "main");
    change_thread_name();
}
```

# 12 type_traits

**具体分类可以参考`<type_traits>`头文件的注释**

## 12.1 谓词模板

用于判断类型

1. `std::is_void`
1. `std::is_array`
1. ...

## 12.2 属性模板

用于调整类型信息

1. `std::remove_reference`
1. `std::add_lvalue_reference_t`
1. `std::add_rvalue_reference_t`

## 12.3 别名模板

只是一种简写，例如`std::enable_if_t`等价于`typename enable_if<b,T>::type`

1. `std::enable_if_t`
1. `std::conditional_t`
1. `std::remove_reference_t`
1. `std::result_of_t`
1. `std::invoke_result_t`
1. ...

## 12.4 std::move

标准库的实现如下：

```cpp
  template<typename _Tp>
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```

本质上，就是做了一次类型转换，返回的一定是个右值

## 12.5 std::forward

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

# 13 utility

## 13.1 std::pair

# 14 容器

1. `<vector>`
1. `<array>`
1. `<list>`
1. `<queue>`
1. `<deque>`
1. `<map>`
1. `<unordered_map>`
1. `<set>`
1. `<unordered_set>`

## 14.1 Tips

1. `std::map`和`std::unordered_map`的`value`是`Pointer Stability`，即地址在容器自身容量调整前后是不会变的
1. `std::map`或者`std::set`用下标访问后，即便访问前元素不存在，也会插入一个默认值。因此下标访问是非`const`的

# 15 C标准库

1. `stdio.h`
1. `stddef.h`
1. `stdint.h`
