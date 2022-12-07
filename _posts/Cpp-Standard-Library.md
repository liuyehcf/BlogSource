---
title: Cpp-Standard-Library
date: 2021-09-06 10:54:02
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

[C++ Standard Library headers](https://en.cppreference.com/w/cpp/header)

# 1 algorithm

## 1.1 std::sort

```cpp
#include <algorithm>
#include <iostream>
#include <vector>

void print(const std::vector<int32_t>& nums) {
    for (int i = 0; i < nums.size(); ++i) {
        if (i == 0) {
            std::cout << nums[i];
        } else {
            std::cout << ", " << nums[i];
        }
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int32_t> nums{1, 4, 2, 5, 7};

    std::sort(nums.begin(), nums.end());
    print(nums);

    std::sort(nums.begin(), nums.end(), [](int32_t i, int32_t j) { return j - i; });
    print(nums);

    return 0;
}
```

## 1.2 std::merge

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <vector>

void print(const std::vector<int32_t>& nums) {
    for (int i = 0; i < nums.size(); ++i) {
        if (i == 0) {
            std::cout << nums[i];
        } else {
            std::cout << ", " << nums[i];
        }
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int32_t> left{1, 3, 5, 7, 9};
    std::vector<int32_t> right{2, 4, 6, 8, 10};

    std::vector<int32_t> dest1;
    std::merge(left.begin(), left.end(), right.begin(), right.end(), std::back_inserter(dest1));
    print(dest1);

    std::vector<int32_t> dest2;
    dest2.resize(left.size() + right.size());
    std::merge(left.begin(), left.end(), right.begin(), right.end(), dest2.begin());
    print(dest2);
    return 0;
}
```

## 1.3 std::inplace_merge

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <vector>

void print(const std::vector<int32_t>& nums) {
    for (int i = 0; i < nums.size(); ++i) {
        if (i == 0) {
            std::cout << nums[i];
        } else {
            std::cout << ", " << nums[i];
        }
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int32_t> nums{2, 4, 6, 8, 10, 1, 3, 5, 7, 9};

    std::vector<int32_t> dest;
    std::inplace_merge(nums.begin(), nums.begin() + 5, nums.end());
    print(nums);
    return 0;
}
```

## 1.4 std::copy

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <vector>

void print(const std::vector<int32_t>& nums) {
    for (int i = 0; i < nums.size(); ++i) {
        if (i == 0) {
            std::cout << nums[i];
        } else {
            std::cout << ", " << nums[i];
        }
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int32_t> source{1, 3, 5, 7, 9};

    std::vector<int32_t> dest1;
    std::copy(source.begin(), source.end(), std::back_inserter(dest1));
    print(dest1);

    std::vector<int32_t> dest2;
    dest2.resize(source.size());
    std::copy(source.begin(), source.end(), dest2.begin());
    print(dest2);
    return 0;
}
```

## 1.5 std::remove_if

`std::remove_if`用于将容器中满足条件的元素挪到最后，并返回指向这部分元素的起始迭代器，一般配合`erase`一起用

```cpp
#include <algorithm>
#include <iostream>
#include <vector>

int main() {
    std::vector<int> container{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    container.erase(std::remove_if(container.begin(), container.end(), [](int v) { return v % 2 != 0; }),
                    container.end());
    for (const auto& v : container) {
        std::cout << v << std::endl;
    }
    return 0;
}
```

# 2 any

**`std::any`用于持有任意类型的对象，类似于Java中的`java.lang.Object`**

* `std::any_cast`用于将`any`对象转换成对应的类型。若类型错误则会抛出`std::bad_any_cast`

**其实现方式也很直观，在堆上分配内存，用该分配的内存存储拷贝后的对象**

```cpp
#include <any>
#include <iostream>

struct Object {
    Object() { std::cout << "Object()" << std::endl; }
    Object(const Object& obj) { std::cout << "Object(const Object& obj)" << std::endl; }
    Object(Object&& obj) { std::cout << "Object(Object&& obj)" << std::endl; }
};

int main() {
    Object obj1;
    Object obj2;
    std::any a1 = obj1;
    std::any a2 = std::move(obj2);
    return 0;
}
```

# 3 atomic

## 3.1 内存一致性模型

### 3.1.1 Sequential consistency model

> the result of any execution is the same as if the operations of all the processors were executed in some sequential order, and the operations of each individual processor appear in this sequence in the order specified by its program

**`Sequential consistency model（SC）`，也称为顺序一致性模型，其实就是规定了两件事情：**

1. **每个线程内部的指令都是按照程序规定的顺序（program order）执行的（单个线程的视角）**
1. **线程执行的交错顺序可以是任意的，但是所有线程所看见的整个程序的总体执行顺序都是一样的（整个程序的视角）**
    * 即不能存在这样一种情况，对于写操作`W1`和`W2`，处理器1看来，顺序是：`W1 -> W2`；而处理器2看来，顺序是：`W2 -> W1`

### 3.1.2 Relaxed consistency model

**`Relaxed consistency model`也称为宽松内存一致性模型，它的特点是：**

1. **唯一的要求是在同一线程中，对同一原子变量的访问不可以被重排（单个线程的视角）**
1. **除了保证操作的原子性之外，没有限定前后指令的顺序，其他线程看到数据的变化顺序也可能不一样（整个程序的视角）**

## 3.2 std::atomic

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

## 3.3 std::memory_order

这是个枚举类型，包含6个枚举值

* `memory_order_relaxed`
* `memory_order_consume`
* `memory_order_acquire`
* `memory_order_release`
* `memory_order_acq_rel`
* `memory_order_seq_cst`

### 3.3.1 顺序一致次序（sequential consisten ordering）

`memory_order_seq_cst`属于这种内存模型

`SC`作为默认的内存序，是因为它意味着将程序看做是一个简单的序列。如果对于一个原子变量的操作都是顺序一致的，那么多线程程序的行为就像是这些操作都以一种特定顺序被单线程程序执行

**该原子操作前后的读写（包括非原子的读写操作）不能跨过该操作乱序；该原子操作之前的写操作（包括非原子的写操作）都能被所有线程观察到**

### 3.3.2 松弛次序（relaxed ordering）

`memory_order_relaxed`属于这种内存模型

在原子变量上采用`relaxed ordering`的操作不参与`synchronized-with`关系。在同一线程内对同一变量的操作仍保持`happens-before`关系，但这与别的线程无关

在`relaxed ordering`中唯一的要求是在同一线程中，对同一原子变量的访问不可以被重排

### 3.3.3 获取-释放次序（acquire-release ordering）

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

## 3.4 参考

* [C++11 - atomic类型和内存模型](https://zhuanlan.zhihu.com/p/107092432)
* [doc-std::memory_order](https://www.apiref.com/cpp-zh/cpp/atomic/memory_order.html)
* [如何理解 C++11 的六种 memory order？](https://www.zhihu.com/question/24301047)
* [并行编程——内存模型之顺序一致性](https://www.cnblogs.com/jiayy/p/3246157.html)
* [漫谈内存一致性模型](https://zhuanlan.zhihu.com/p/91406250)

# 4 chrono

## 4.1 clock

**三种时钟：**

1. `steady_clock`：是单调的时钟。其绝对值无意义，只会增长，适合用于记录程序耗时。
1. `system_clock`：是系统的时钟，且系统的时钟可以修改，甚至可以网络对时。所以用系统时间计算时间差可能不准
1. `high_resolution_clock`：是当前系统能够提供的最高精度的时钟。它也是不可以修改的。相当于`steady_clock`的高精度版本

```cpp
auto start = std::chrono::steady_clock::now();
auto end = std::chrono::steady_clock::now();
auto nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
auto now_nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
```

# 5 functional

1. `std::function`：其功能类似于函数指针，在需要函数指针的地方，可以传入`std::function`类型的对象（不是指针）
1. `std::bind`
1. `std::mem_fn`

## 5.1 参考

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)

# 6 future

1. `std::promise`
1. `std::future`

# 7 iostream

1. `std::cout`
1. `std::cin`
1. `std::endl`
1. `std::boolalpha`
1. `std::noboolalpha`

# 8 limits

1. `std::numeric_limits`
    * `std::numeric_limits<int32_t>::max()`

# 9 memory

## 9.1 std::shared_ptr

**类型转换**

* `std::static_pointer_cast`
* `std::dynamic_pointer_cast`
* `std::const_pointer_cast`
* `std::reinterpret_pointer_cast`

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

## 9.2 std::enable_shared_from_this

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

## 9.3 std::unique_ptr

## 9.4 参考

* [C++ 智能指针的正确使用方式](https://www.cyhone.com/articles/right-way-to-use-cpp-smart-pointer/)

# 10 mutex

1. `std::mutex`
1. `std::lock_guard`
    * 直接使用`std::mutex`，如下面的例子。如果`getVar`方法抛出异常了，那么就会导致`m.unlock()`方法无法执行，可能会造成死锁
    ```c++
    mutex m;
    m.lock();
    sharedVariable= getVar();
    m.unlock();
    ```

    * 一种优雅的方式是使用`std::lock_guard`，该对象的析构方法中会进行锁的释放，需要将串行部分放到一个`{}`中，当退出该作用域时，`std::lock_guard`对象会析构，并释放锁，在任何正常或异常情况下都能够释放锁

    ```c++
    {
        std::mutex m;
        std::lock_guard<std::mutex> lockGuard(m);
        sharedVariable= getVar();
    }
    ```

1. `std::unique_lock`
1. `std::condition_variable`
    * 调用`wait`方法时，必须获取监视器。而调用`notify`方法时，无需获取监视器
    * `wait`方法被唤醒后，仍然处于获取监视器的状态
    ```cpp
    std::mutex m;
    std::condition_variable cv;
    std::unique_lock<std::mutex> l(m);
    cv.wait(l);
    // wake up here, and still under lock
    ```

## 10.1 参考

* [Do I have to acquire lock before calling condition_variable.notify_one()?](https://stackoverflow.com/questions/17101922/do-i-have-to-acquire-lock-before-calling-condition-variable-notify-one)

# 11 numeric

1. `std::accumulate`
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

# 12 optional

1. `std::optional`

# 13 random

1. `std::default_random_engine`
1. `std::uniform_int_distribution`：左闭右闭区间

# 14 stdexcept

1. `std::logic_error`

# 15 string

1. `std::string`
1. `std::to_string`

# 16 thread

**如何设置或修改线程名：**

1. `pthread_setname_np/pthread_getname_np`，需要引入头文件`<pthread.h>`，`np`表示`non-portable`，即平台相关
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

# 17 type_traits

[Standard library header <type_traits>](https://en.cppreference.com/w/cpp/header/type_traits)

## 17.1 Helper Class

1. `std::integral_constant`
1. `std::bool_constant`
1. `std::true_type`
1. `std::false_type`

## 17.2 Primary type categories

1. `std::is_void`
1. `std::is_null_pointer`
1. `std::is_integral`
1. `std::is_array`
1. `std::is_pointer`
1. ...

## 17.3 Composite type categories

1. `std::is_fundamental`
1. `std::is_arithmetic`
1. `std::is_scalar`
1. `std::is_reference`
1. `std::is_member_pointer`
1. ...

## 17.4 Type properties

1. `std::is_const`
1. `std::is_volatile`
1. `std::is_final`
1. `std::is_empty`
1. `std::is_abstract`
1. ...

## 17.5 Supported operations

1. `std::is_constructible`
1. `std::is_copy_constructible`
1. `std::is_assignable`
1. `std::is_copy_assignable`
1. `std::is_destructible`
1. ...

## 17.6 Property queries

1. `std::alignment_of`
1. `std::rank`
1. `std::extent`

## 17.7 Type relationships

1. `std::is_same`
1. `std::is_base_of`
1. ...

## 17.8 Const-volatility specifiers

1. `std::remove_cv`
1. `std::remove_const`
1. `std::remove_volatile`
1. `std::add_cv`
1. `std::add_const`
1. `std::add_volatile`

## 17.9 References

1. `std::remove_reference`
1. `std::add_lvalue_reference`
1. `std::add_rvalue_reference`
  
## 17.10 Pointers

1. `std::remove_pointer`
1. `std::add_pointer`
  
## 17.11 Sign modifiers

1. `std::make_signed`
1. `std::make_unsigned`

## 17.12 Arrays

1. `std::remove_extent`
1. `std::remove_all_extents`

## 17.13 Miscellaneous transformations

1. `std::enable_if`
1. `std::conditional`
1. `std::void_t`
1. `std::decay`
    * [What is std::decay and when it should be used?](https://stackoverflow.com/questions/25732386/what-is-stddecay-and-when-it-should-be-used)
    * [N2609](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2006/n2069.html)

## 17.14 Alias

`using template`，用于简化上述模板。例如`std::enable_if_t`等价于`typename enable_if<b,T>::type`

1. `std::enable_if_t`
1. `std::conditional_t`
1. `std::remove_reference_t`
1. `std::result_of_t`
1. `std::invoke_result_t`
1. ...

## 17.15 std::move

标准库的实现如下：

```cpp
  template<typename _Tp>
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```

本质上，就是做了一次类型转换，返回的一定是个右值

## 17.16 std::forward

`std::forward`主要用于实现模板的完美转发：因为对于一个变量而言，无论该变量的类型是左值引用还是右值引用，变量本身都是左值，如果直接将变量传递到下一个方法中，那么一定是按照左值来匹配重载函数的，而`std::forward`就是为了解决这个问题。请看下面这个例子：

```cpp
#include <iostream>

std::string func(int& value) {
    return "left reference version";
}

std::string func(int&& value) {
    return "right reference version";
}

template <typename T>
std::string dispatch_without_forward(T&& t) {
    return func(t);
}

template <typename T>
std::string dispatch_with_forward(T&& t) {
    return func(std::forward<T>(t));
}

#define TEST(expr) std::cout << #expr << " -> " << expr << std::endl;

int main() {
    int value = 0;
    int& value_l_ref = value;
    auto get_r_value = []() { return 2; };

    TEST(dispatch_without_forward(value));
    TEST(dispatch_without_forward(value_l_ref));
    TEST(dispatch_without_forward(get_r_value()));
    TEST(dispatch_without_forward(1));
    std::cout << std::endl;

    TEST(dispatch_with_forward(value));
    TEST(dispatch_with_forward(value_l_ref));
    TEST(dispatch_with_forward(get_r_value()));
    TEST(dispatch_with_forward(1));
    std::cout << std::endl;

    TEST(func(std::forward<int>(value)));
    TEST(func(std::forward<int&>(value)));
    TEST(func(std::forward<int&&>(value)));
    std::cout << std::endl;

    TEST(func(std::forward<int>(value_l_ref)));
    TEST(func(std::forward<int&>(value_l_ref)));
    TEST(func(std::forward<int&&>(value_l_ref)));
    std::cout << std::endl;

    TEST(func(std::forward<int>(get_r_value())));
    TEST(func(std::forward<int&&>(get_r_value())));
    std::cout << std::endl;

    TEST(func(std::forward<int>(1)));
    TEST(func(std::forward<int&&>(1)));

    return 0;
}
```

**输出如下：**

```
dispatch_without_forward(value) -> left reference version
dispatch_without_forward(value_l_ref) -> left reference version
dispatch_without_forward(get_r_value()) -> left reference version
dispatch_without_forward(1) -> left reference version

dispatch_with_forward(value) -> left reference version
dispatch_with_forward(value_l_ref) -> left reference version
dispatch_with_forward(get_r_value()) -> right reference version
dispatch_with_forward(1) -> right reference version

func(std::forward<int>(value)) -> right reference version
func(std::forward<int&>(value)) -> left reference version
func(std::forward<int&&>(value)) -> right reference version

func(std::forward<int>(value_l_ref)) -> right reference version
func(std::forward<int&>(value_l_ref)) -> left reference version
func(std::forward<int&&>(value_l_ref)) -> right reference version

func(std::forward<int>(get_r_value())) -> right reference version
func(std::forward<int&&>(get_r_value())) -> right reference version

func(std::forward<int>(1)) -> right reference version
func(std::forward<int&&>(1)) -> right reference version
```

**在使用`std::forward`时，模板实参都是需要显式指定的，而不是推断出来的**

**`std::forward`标准库的实现如下：**

* 如果模板实参是左值、左值引用或右值引用，那么匹配第一个方法
    * 左值：`_Tp&&`得到的是个右值（很奇怪吧，因为一般都不是这么用的）
    * **左值引用：`_Tp&&`得到的是个左值引用（完美转发会用到）**
    * **右值应用：`_Tp&&`得到的是个右值引用（完美转发会用到）**
* 如果模板实参是左值或右值，那么匹配的是第二个方法
    * 右值：`_Tp&&`得到的是个右值
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

### 17.16.1 forwarding reference

**当且仅当`T`是函数模板的模板类型形参时，`T&&`才能称为`forwarding reference`，而其他任何形式，都不是`forwarding reference`。例如如下示例代码：**

* **`std::vector<T>&&`就不是`forwarding reference`，而只是一个`r-value reference`**
* **`C(T&& t)`中的`T&&`也不是`forwarding reference`，因为类型`T`在实例化`C`时，已经可以确定了，无需推导**

```cpp
#include <type_traits>
#include <vector>

class S {};

template <typename T>
void g(const T& t);
template <typename T>
void g(T&& t);

template <typename T>
void gt(T&& t) {
    g(std::move(t)); // Noncompliant : std::move applied to a forwarding reference
}

void use_g() {
    S s;
    g(s);
    g(std::forward<S>(s)); // Noncompliant : S isn't a forwarding reference.
}

template <typename T>
void foo(std::vector<T>&& t) {
    std::forward<T>(t); // Noncompliant : std::vector<T>&& isn't a forwarding reference.
}

template <typename T>
struct C {
    // In class template argument deduction, template parameter of a class template is never a forwarding reference.
    C(T&& t) {
        g(std::forward<T>(t)); // Noncompliant : T&& isn't a forwarding reference. It is an r-value reference.
    }
};
```

**上述程序正确的写法是：**

```cpp
#include <type_traits>
#include <vector>

class S {};

template <typename T>
void g(const T& t);
template <typename T>
void g(T&& t);

template <typename T>
void gt(T&& t) {
    g(std::forward(t));
}

void use_g() {
    S s;
    g(s);
    g(std::move(s));
}

template <typename T>
void foo(std::vector<T>&& t) {
    std::move(t);
}

template <typename T>
struct C {
    C(T&& t) { g(std::move(t)); }
};
```

# 18 utility

1. `std::pair`

# 19 Containers

1. `<vector>`
1. `<array>`
1. `<list>`
1. `<queue>`
1. `<deque>`
1. `<map>`
1. `<unordered_map>`
1. `<set>`
1. `<unordered_set>`

## 19.1 Tips

1. `std::map`或者`std::set`用下标访问后，即便访问前元素不存在，也会插入一个默认值。因此下标访问是非`const`的
1. 容器在扩容时，调用的是元素的拷贝构造函数
1. `std::vector<T> v(n)`会生成`n`个对应元素的默认值，而不是起到预留`n`个元素的空间的作用
1. 不要将`end`方法返回的迭代器传入`erase`方法

# 20 SIMD

[Header files for x86 SIMD intrinsics](https://stackoverflow.com/questions/11228855/header-files-for-x86-simd-intrinsics)

1. `<mmintrin.h>`：MMX
1. `<xmmintrin.h>`：SSE
1. `<emmintrin.h>`：SSE2
1. `<pmmintrin.h>`：SSE3
1. `<tmmintrin.h>`：SSSE3
1. `<smmintrin.h>`：SSE4.1
1. `<nmmintrin.h>`：SSE4.2
1. `<ammintrin.h>`：SSE4A
1. `<wmmintrin.h>`：AES
1. **`<immintrin.h>`**：AVX, AVX2, FMA
    * 一般用这个即可，包含上述其他的头文件

**注意，`gcc`、`clang`默认禁止使用向量化相关的类型以及操作，在使用上述头文件时，需要指定对应的编译参数：**

* `-mmmx`
* `-msse`
* `-msse2`
* `-msse3`
* `-mssse3`
* `-msse4`
* `-msse4a`
* `-msse4.1`
* `-msse4.2`
* `-mavx`
* `-mavx2`
* `-mavx512f`
* `-mavx512pf`, supports prefetching for gather/scatter, mentioned by [Interleaved Multi-Vectorizing](/resources/paper/Interleaved-Multi-Vectorizing.pdf)
* `-mavx512er`
* `-mavx512cd`
* `-mavx512vl`
* `-mavx512bw`
* `-mavx512dq`
* `-mavx512ifma`
* `-mavx512vbmi`
* ...

# 21 C标准库

1. `stdio.h`
1. `stddef.h`
1. `stdint.h`
1. `stdlib.h`
    * `malloc`
1. `cstdlib`
    * `std::atoi`
    * `std::atol`
    * `std::atoll`

## 21.1 csignal

各种信号都定义在`signum.h`这个头文件中

下面的示例代码用于捕获`OOM`并输出当时的进程状态信息

* 化级别用`O0`，否则`v.reserve`会被优化掉
* `ulimit -v 1000000`：设置进程最大内存
* `./main <size>`：不断增大`size`，可以发现`VmPeak`和`VmSize`不断增大。继续增大`size`，当触发`OOM`时，`VmPeak`和`VmSize`这两个值都很小，不会包含那个造成`OOM`的对象的内存

```cpp
#include <csignal>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>

void display_self_status() {
    std::ifstream in("/proc/self/status");
    constexpr size_t BUFFER_SIZE = 512;
    char buf[BUFFER_SIZE];

    while (!in.eof()) {
        in.getline(buf, BUFFER_SIZE);
        std::cout << buf << std::endl;
    }

    in.close();
}

void func(int sig) {
    std::cout << "Cath a signal, sig=" << sig << std::endl;
    display_self_status();
    exit(sig);
}

int main(int argc, char* argv[]) {
    for (int sig = SIGHUP; sig <= SIGSYS; sig++) {
        signal(sig, func);
    }

    display_self_status();

    // trigger OOM
    std::vector<int64_t> v;
    v.reserve(std::atoi(argv[1]));

    display_self_status();

    return 0;
}
```

## 21.2 pthread.h

下面示例代码用于测试各个CPU的性能

* 用`pthread_setaffinity_np`进行绑核
* 化级别用`O0`，否则循环会被优化掉

```cpp
#include <pthread.h>

#include <chrono>
#include <iostream>

int main(int argc, char* argv[]) {
    pthread_t thread = pthread_self();

    for (int cpu_id = 0; cpu_id < CPU_SETSIZE; cpu_id++) {
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(cpu_id, &cpuset);

        if (pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
            return 1;
        }

        if (pthread_getaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
            return 1;
        }
        for (int i = 0; i < CPU_SETSIZE; i++) {
            if (CPU_ISSET(i, &cpuset) && cpu_id != i) {
                return 1;
            }
        }

        std::cout << "Testing cpu(" << cpu_id << ")" << std::endl;

        int64_t cnt = 0;
        auto start = std::chrono::steady_clock::now();
        while (cnt <= 1000000000L) {
            cnt++;
        }
        auto end = std::chrono::steady_clock::now();

        std::cout << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << std::endl;
    }

    return 0;
}
```
