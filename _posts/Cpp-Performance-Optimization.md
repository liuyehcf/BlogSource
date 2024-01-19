---
title: Cpp-Performance-Optimization
date: 2021-10-15 18:45:48
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 Basic

## 1.1 virtual function

### 1.1.1 assembly

```cpp
#include <iostream>

class Base {
public:
    virtual void func_virtual() { std::cout << "Base::func_virtual" << std::endl; }
    void func_normal() { std::cout << "Base::func_normal" << std::endl; }
};

class Derive : public Base {
public:
    virtual void func_virtual() override { std::cout << "Derive::func_virtual" << std::endl; }
};

void invoke_virtual(Base* base) {
    base->func_virtual();
}

void invoke_normal(Base* base) {
    base->func_normal();
}

int main() {
    return 0;
}
```

```sh
# 编译
gcc -o main.c main.cpp -c -Wall -O3 -g

# 反汇编
objdump -drwCS main.c
```

**输出如下：**

```
void invoke_virtual(Base* base) {
    base->func_virtual();
   0:	48 8b 07             	mov    (%rdi),%rax
   3:	ff 20                	jmpq   *(%rax)
   5:	90                   	nop
   6:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

0000000000000010 <invoke_normal(Base*)>:
}

void invoke_normal(Base* base) {
  10:	55                   	push   %rbp
    operator<<(basic_ostream<char, _Traits>& __out, const char* __s)
    {
      if (!__s)
	__out.setstate(ios_base::badbit);
      else
# 省略其他指令（都是内联展开的指令）
```

**结论：**

1. 对于虚函数，由于无法确认实际类型，因此无法进行函数内联优化

### 1.1.2 benchmark

```cpp
#include <benchmark/benchmark.h>

class Base {
public:
    Base() = default;
    virtual ~Base() = default;
    virtual void func_virtual() {}
    void func_normal() {}
};

class Derive : public Base {
public:
    Derive() = default;
    virtual ~Derive() = default;
    virtual void func_virtual() override {}
};

void __attribute__((noinline)) invoke_virtual(Base* base) {
    base->func_virtual();
}

void __attribute__((noinline)) invoke_normal(Base* base) {
    base->func_normal();
}

static void BM_virtual(benchmark::State& state) {
    Base* base = new Derive();
    for (auto _ : state) {
        invoke_virtual(base);
        benchmark::DoNotOptimize(base);
    }
    delete base;
}

static void BM_normal(benchmark::State& state) {
    Base* base = new Derive();
    for (auto _ : state) {
        invoke_normal(base);
        benchmark::DoNotOptimize(base);
    }
    delete base;
}

BENCHMARK(BM_normal);
BENCHMARK(BM_virtual);

BENCHMARK_MAIN();
```

**输出如下：**

```
-----------------------------------------------------
Benchmark           Time             CPU   Iterations
-----------------------------------------------------
BM_normal       0.314 ns        0.313 ns   1000000000
BM_virtual       1.88 ns         1.88 ns    372088713
```

## 1.2 eliminate virtual function

有时候，当子类型确定时，我们希望能够消除虚函数的开销

```cpp
#include <benchmark/benchmark.h>

struct Base {
    virtual ~Base() = default;
    virtual void op() { data += 1; }

    int64_t data = 0;
};

struct ClassFinal final : public Base {
    virtual ~ClassFinal() = default;
    virtual void op() override { data += 2; }
};

struct FunctionFinal : public Base {
    virtual ~FunctionFinal() = default;
    virtual void op() final override { data += 3; }
};

static constexpr size_t TIMES = 1 << 20;

__attribute__((noinline)) void invoke_by_base_ptr(Base* base_ptr) {
    for (size_t i = 0; i < TIMES; ++i) {
        base_ptr->op();
    }
}

__attribute__((noinline)) void invoke_by_class_final_derive_ptr(ClassFinal* derive_ptr) {
    for (size_t i = 0; i < TIMES; ++i) {
        derive_ptr->op();
    }
}

__attribute__((noinline)) void invoke_by_function_final_derive_ptr(FunctionFinal* derive_ptr) {
    for (size_t i = 0; i < TIMES; ++i) {
        derive_ptr->op();
    }
}

__attribute__((noinline)) void invoke_by_base_ref(Base& base_ref) {
    for (size_t i = 0; i < TIMES; ++i) {
        base_ref.op();
    }
}

__attribute__((noinline)) void invoke_by_class_final_derive_ref(ClassFinal& derive_ref) {
    for (size_t i = 0; i < TIMES; ++i) {
        derive_ref.op();
    }
}

__attribute__((noinline)) void invoke_by_function_final_derive_ref(FunctionFinal& derive_ref) {
    for (size_t i = 0; i < TIMES; ++i) {
        derive_ref.op();
    }
}

static void BM_invoke_by_base_ptr(benchmark::State& state) {
    Base* base_ptr = new ClassFinal();
    for (auto _ : state) {
        invoke_by_base_ptr(base_ptr);
    }
    benchmark::DoNotOptimize(base_ptr->data);
    delete base_ptr;
}

static void BM_invoke_by_class_final_derive_ptr(benchmark::State& state) {
    Base* base_ptr = new ClassFinal();
    ClassFinal* derive_ptr = static_cast<ClassFinal*>(base_ptr);
    for (auto _ : state) {
        invoke_by_class_final_derive_ptr(derive_ptr);
    }
    benchmark::DoNotOptimize(derive_ptr->data);
    delete base_ptr;
}

static void BM_invoke_by_function_final_derive_ptr(benchmark::State& state) {
    Base* base_ptr = new FunctionFinal();
    FunctionFinal* derive_ptr = static_cast<FunctionFinal*>(base_ptr);
    for (auto _ : state) {
        invoke_by_function_final_derive_ptr(derive_ptr);
    }
    benchmark::DoNotOptimize(derive_ptr->data);
    delete base_ptr;
}

static void BM_invoke_by_base_ref(benchmark::State& state) {
    Base* base_ptr = new ClassFinal();
    Base& base_ref = static_cast<Base&>(*base_ptr);
    for (auto _ : state) {
        invoke_by_base_ref(base_ref);
    }
    benchmark::DoNotOptimize(base_ref.data);
    delete base_ptr;
}

static void BM_invoke_by_class_final_derive_ref(benchmark::State& state) {
    ClassFinal* derive_ptr = new ClassFinal();
    ClassFinal& derive_ref = *derive_ptr;
    for (auto _ : state) {
        invoke_by_class_final_derive_ref(derive_ref);
    }
    benchmark::DoNotOptimize(derive_ref.data);
    delete derive_ptr;
}

static void BM_invoke_by_function_final_derive_ref(benchmark::State& state) {
    FunctionFinal* derive_ptr = new FunctionFinal();
    FunctionFinal& derive_ref = *derive_ptr;
    for (auto _ : state) {
        invoke_by_function_final_derive_ref(derive_ref);
    }
    benchmark::DoNotOptimize(derive_ref.data);
    delete derive_ptr;
}

BENCHMARK(BM_invoke_by_base_ptr);
BENCHMARK(BM_invoke_by_class_final_derive_ptr);
BENCHMARK(BM_invoke_by_function_final_derive_ptr);
BENCHMARK(BM_invoke_by_base_ref);
BENCHMARK(BM_invoke_by_class_final_derive_ref);
BENCHMARK(BM_invoke_by_function_final_derive_ref);

BENCHMARK_MAIN();
```

**输出如下：**

```
---------------------------------------------------------------------------------
Benchmark                                       Time             CPU   Iterations
---------------------------------------------------------------------------------
BM_invoke_by_base_ptr                      328065 ns       328053 ns         2133
BM_invoke_by_class_final_derive_ptr          1.56 ns         1.56 ns    447363138
BM_invoke_by_function_final_derive_ptr       1.25 ns         1.25 ns    559434318
BM_invoke_by_base_ref                      328087 ns       328078 ns         2133
BM_invoke_by_class_final_derive_ref          1.56 ns         1.56 ns    447476177
BM_invoke_by_function_final_derive_ref       1.25 ns         1.25 ns    559455878
```

可以看到，用超类的指针或者引用调用虚函数，可以直接消除虚函数的开销。**注意，这里有一个关键点，我们给`Derive`加上了`final`关键字，否则编译器也不敢直接消除虚函数**

## 1.3 move smart pointer

在下面这个例子中

* 在函数`add_with_move`的生命周期中
    * 进入`add_with_move`时，调用`shared_ptr`的拷贝构造函数，计数值`+1`
    * 进入`perform_add`时，调用`shared_ptr`的移动构造函数，计数值不变
    * 退出`perform_add`时，调用`shared_ptr`的析构函数，计数值`-1`
    * 退出`add_with_move`，调用`shared_ptr`的析构函数，计数值不变
* 在函数`add_with_copy`的生命周期中
    * 进入`add_with_copy`时，调用`shared_ptr`的拷贝构造函数，计数值`+1`
    * 进入`perform_add`时，调用`shared_ptr`的拷贝构造函数，计数值`+1`
    * 退出`perform_add`时，调用`shared_ptr`的析构函数，计数值`-1`
    * 退出`add_with_copy`，调用`shared_ptr`的析构函数，计数值`-1`

```cpp
#include <benchmark/benchmark.h>

#include <memory>

int __attribute__((noinline)) perform_add(std::shared_ptr<int> num_ptr) {
    return (*num_ptr) + 1;
}

int __attribute__((noinline)) add_with_move(std::shared_ptr<int> num_ptr) {
    return perform_add(std::move(num_ptr));
}

int __attribute__((noinline)) add_with_copy(std::shared_ptr<int> num_ptr) {
    return perform_add(num_ptr);
}

static void BM_add_with_move(benchmark::State& state) {
    std::shared_ptr<int> num_ptr = std::make_shared<int>(10);

    for (auto _ : state) {
        benchmark::DoNotOptimize(add_with_move(num_ptr));
    }
}

static void BM_add_with_copy(benchmark::State& state) {
    std::shared_ptr<int> num_ptr = std::make_shared<int>(10);

    for (auto _ : state) {
        benchmark::DoNotOptimize(add_with_copy(num_ptr));
    }
}
BENCHMARK(BM_add_with_move);
BENCHMARK(BM_add_with_copy);

BENCHMARK_MAIN();
```

**输出如下：**

```
-----------------------------------------------------------
Benchmark                 Time             CPU   Iterations
-----------------------------------------------------------
BM_add_with_move       15.4 ns         15.4 ns     44609411
BM_add_with_copy       31.4 ns         31.4 ns     21773464
```

## 1.4 `++i` or `i++`

一般情况下，单独的`++i`或者`i++`都会被编译器优化成相同的指令集。除非`i++`赋值后的变量无法被优化掉，那么`++i`的性能会略优于`i++`

```cpp
#include <benchmark/benchmark.h>

void __attribute__((noinline)) increment_and_assign(int32_t& num1, int32_t& num2) {
    num1 = ++num2;

    benchmark::DoNotOptimize(num1);
    benchmark::DoNotOptimize(num2);
}

void __attribute__((noinline)) assign_and_increment(int32_t& num1, int32_t& num2) {
    num1 = num2++;

    benchmark::DoNotOptimize(num1);
    benchmark::DoNotOptimize(num2);
}

static void BM_increment_and_assign(benchmark::State& state) {
    int32_t num1 = 0;
    int32_t num2 = 0;
    for (auto _ : state) {
        increment_and_assign(num1, num2);
        benchmark::DoNotOptimize(num1);
        benchmark::DoNotOptimize(num2);
    }
}

static void BM_assign_and_increment(benchmark::State& state) {
    int32_t num1 = 0;
    int32_t num2 = 0;
    for (auto _ : state) {
        assign_and_increment(num1, num2);
        benchmark::DoNotOptimize(num1);
        benchmark::DoNotOptimize(num2);
    }
}
BENCHMARK(BM_increment_and_assign);
BENCHMARK(BM_assign_and_increment);

BENCHMARK_MAIN();
```

**输出如下：**

```
------------------------------------------------------------------
Benchmark                        Time             CPU   Iterations
------------------------------------------------------------------
BM_increment_and_assign       2.75 ns         2.75 ns    254502792
BM_assign_and_increment       2.88 ns         2.88 ns    239756481
```

## 1.5 container lookup

在`vector`查找某个元素只能遍历，查找性能是`O(n)`，但是`set`提供了`O(1)`的查找性能

```cpp
#include <benchmark/benchmark.h>

#include <set>
#include <unordered_set>
#include <vector>

#define UPPER_BOUNDARY 1

bool lookup_for_vector(const std::vector<int64_t>& container, const int64_t& target) {
    for (auto& item : container) {
        if (item == target) {
            return true;
        }
    }
    return false;
}

template <typename Container>
bool lookup_for_set(const Container& container, const typename Container::value_type& target) {
    return container.find(target) != container.end();
}

static void BM_vector(benchmark::State& state) {
    std::vector<int64_t> container;
    for (int64_t i = 1; i <= UPPER_BOUNDARY; i++) {
        container.push_back(i);
    }

    int64_t target = 1;
    for (auto _ : state) {
        benchmark::DoNotOptimize(lookup_for_vector(container, target));
        if (target++ == UPPER_BOUNDARY) {
            target = 1;
        }
    }
}

static void BM_set(benchmark::State& state) {
    std::set<int64_t> container;
    for (int64_t i = 1; i <= UPPER_BOUNDARY; i++) {
        container.insert(i);
    }

    int64_t target = 1;
    for (auto _ : state) {
        benchmark::DoNotOptimize(lookup_for_set(container, target));
        if (target++ == UPPER_BOUNDARY) {
            target = 1;
        }
    }
}

static void BM_unordered_set(benchmark::State& state) {
    std::unordered_set<int64_t> container;
    for (int64_t i = 1; i <= UPPER_BOUNDARY; i++) {
        container.insert(i);
    }

    int64_t target = 1;
    for (auto _ : state) {
        benchmark::DoNotOptimize(lookup_for_set(container, target));
        if (target++ == UPPER_BOUNDARY) {
            target = 1;
        }
    }
}

BENCHMARK(BM_vector);
BENCHMARK(BM_set);
BENCHMARK(BM_unordered_set);

BENCHMARK_MAIN();
```

| UPPER_BOUNDARY | vector | set | unordered_set |
|:--|:--|:--|:--|
| 1 | 0.628 ns | 1.26 ns | 8.55 ns |
| 2 | 0.941 ns | 1.57 ns | 8.47 ns |
| 4 | 1.49 ns | 2.84 ns | 8.51 ns |
| 8 | 2.44 ns | 3.61 ns | 8.50 ns |
| 16 | 3.88 ns | 4.31 ns | 8.52 ns |
| 32 | 10.0 ns | 5.03 ns | 8.55 ns |
| 64 | 21.0 ns | 5.62 ns | 8.54 ns |
| 128 | 33.9 ns | 6.51 ns | 8.52 ns |
| 16384 | 2641 ns | 54.7 ns | 8.51 ns |

## 1.6 integer vs. float with branch

对比整型运算、浮点运算在有无分支情况下的性能差异

```cpp
#include <benchmark/benchmark.h>

#include <algorithm>
#include <iostream>
#include <numeric>
#include <random>

const constexpr int32_t SIZE = 32768;

bool is_init = false;
int32_t data[SIZE];

void init() {
    if (is_init) {
        return;
    }
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u(0, 256);
    for (auto i = 0; i < SIZE; i++) {
        int32_t value = u(e);
        data[i] = value;
    }
}

double sum_int() {
    int32_t sum = 0;
    for (auto i = 0; i < SIZE; i++) {
        sum += data[i];
    }

    return static_cast<double>(sum);
}

double sum_double() {
    double sum = 0;
    for (auto i = 0; i < SIZE; i++) {
        sum += data[i];
    }
    return sum;
}

double sum_int_with_branch() {
    int32_t sum = 0;
    for (auto i = 0; i < SIZE; i++) {
        if (data[i] > 128) [[likely]] {
            sum += data[i];
        }
    }
    return sum;
}

double sum_double_with_branch() {
    double sum = 0;
    for (auto i = 0; i < SIZE; i++) {
        sum += data[i];
    }
    return sum;
}

static void BM_sum_int(benchmark::State& state) {
    init();

    for (auto _ : state) {
        double sum = sum_int();
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_sum_double(benchmark::State& state) {
    init();

    for (auto _ : state) {
        double sum = sum_double();
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_sum_int_with_branch(benchmark::State& state) {
    init();

    for (auto _ : state) {
        double sum = sum_int_with_branch();
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_sum_double_with_branch(benchmark::State& state) {
    init();

    for (auto _ : state) {
        double sum = sum_double_with_branch();
        benchmark::DoNotOptimize(sum);
    }
}

BENCHMARK(BM_sum_int);
BENCHMARK(BM_sum_double);
BENCHMARK(BM_sum_int_with_branch);
BENCHMARK(BM_sum_double_with_branch);

BENCHMARK_MAIN();
```

**输出如下：**

```
--------------------------------------------------------------------
Benchmark                          Time             CPU   Iterations
--------------------------------------------------------------------
BM_sum_int                      3343 ns         3342 ns       209531
BM_sum_double                  41125 ns        41121 ns        17026
BM_sum_int_with_branch          5581 ns         5581 ns       125473
BM_sum_double_with_branch      41075 ns        41071 ns        17027
```

## 1.7 `atomic` or `mutex`

非原子变量、原子变量、`mutex`之间的性能差距

```cpp
#include <benchmark/benchmark.h>

#include <atomic>
#include <mutex>

static void BM_normal(benchmark::State& state) {
    int64_t cnt = 0;

    for (auto _ : state) {
        benchmark::DoNotOptimize(cnt++);
    }
}

static void BM_atomic(benchmark::State& state) {
    std::atomic<int64_t> cnt = 0;

    for (auto _ : state) {
        benchmark::DoNotOptimize(cnt++);
    }
}

static void BM_mutex(benchmark::State& state) {
    std::mutex lock;
    int64_t cnt = 0;

    for (auto _ : state) {
        {
            std::lock_guard<std::mutex> l(lock);
            benchmark::DoNotOptimize(cnt++);
        }
    }
}

BENCHMARK(BM_normal);
BENCHMARK(BM_atomic);
BENCHMARK(BM_mutex);

BENCHMARK_MAIN();
```

**输出如下：**

```
-----------------------------------------------------
Benchmark           Time             CPU   Iterations
-----------------------------------------------------
BM_normal       0.314 ns        0.314 ns   1000000000
BM_atomic        5.65 ns         5.65 ns    124013879
BM_mutex         16.6 ns         16.6 ns     42082466
```

## 1.8 `std::atomic` write

```cpp
#include <benchmark/benchmark.h>

#include <atomic>

static void write_normal(benchmark::State& state) {
    int64_t cnt = 0;
    int64_t date = 0;
    for (auto _ : state) {
        date = cnt++;
        benchmark::DoNotOptimize(date);
    }
}

template <std::memory_order order>
static void write_atomic(benchmark::State& state) {
    int64_t cnt = 0;
    std::atomic<int64_t> date = 0;
    for (auto _ : state) {
        date.store(cnt++, order);
        benchmark::DoNotOptimize(date);
    }
}

BENCHMARK(write_normal);
BENCHMARK(write_atomic<std::memory_order_relaxed>);
BENCHMARK(write_atomic<std::memory_order_seq_cst>);

BENCHMARK_MAIN();
```

**输出如下：**

* 下面这个结果是在`x86`平台上运行得到的。不同平台对于`std::memory_order_relaxed`的实现是有差异的，`x86`采用了更为严格的策略，在这种情况下，和非原子变量的写性能一样，基本可以推断，其他平台上原子变量和非原子变量的写性能，在无竞争的情况下，基本接近

```
----------------------------------------------------------------------------------
Benchmark                                        Time             CPU   Iterations
----------------------------------------------------------------------------------
write_normal                                 0.313 ns        0.313 ns   1000000000
write_atomic<std::memory_order_relaxed>      0.391 ns        0.391 ns   1000000000
write_atomic<std::memory_order_seq_cst>       5.63 ns         5.63 ns    124343398
```

## 1.9 `std::function` or lambda

```cpp
#include <benchmark/benchmark.h>

#include <functional>

void invoke_by_function(const std::function<void()>& func) {
    func();
}

template <typename F>
void invoke_by_template(F&& func) {
    func();
}

static void BM_function(benchmark::State& state) {
    int64_t cnt = 0;

    for (auto _ : state) {
        invoke_by_function([&]() { benchmark::DoNotOptimize(cnt++); });
    }
}

static void BM_lambda(benchmark::State& state) {
    int64_t cnt = 0;

    for (auto _ : state) {
        invoke_by_template([&]() { benchmark::DoNotOptimize(cnt++); });
    }
}

static void BM_inline(benchmark::State& state) {
    int64_t cnt = 0;

    for (auto _ : state) {
        benchmark::DoNotOptimize(cnt++);
    }
}

BENCHMARK(BM_function);
BENCHMARK(BM_lambda);
BENCHMARK(BM_inline);

BENCHMARK_MAIN();
```

**输出如下：**

* `std::function`本质上是个函数指针的封装，当传递它时，编译器很难进行内联优化
* `Lambda`本质上是传递某个匿名类的实例，有确定的类型信息，编译器可以很容易地进行内联优化

```
------------------------------------------------------
Benchmark            Time             CPU   Iterations
------------------------------------------------------
BM_function       1.88 ns         1.88 ns    372813677
BM_lambda        0.313 ns        0.313 ns   1000000000
BM_inline        0.313 ns        0.313 ns   1000000000
```

## 1.10 duff's device

`duff's device`是指一种用于减少循环条件判断次数的特殊优化手段

* 循环中是不包含`switch`的，只包含了一些`label`（即`case`），因此`switch`条件跳转只执行了一次，循环判断执行的次数大约是原始次数的`1/8`

```cpp
#include <benchmark/benchmark.h>

#include <random>

#define SIZE (1024 * 1024)

int src_data[SIZE];
int dst_data[SIZE];

void send(int* dst, int* src, int count) {
    for (int i = 0; i < count; i++) {
        *dst++ = *src++;
    }
}

void send_duff(int* dst, int* src, int count) {
    int n = (count + 7) / 8;
    switch (count % 8) {
    case 0:
        do {
            *dst++ = *src++;
        case 7:
            *dst++ = *src++;
        case 6:
            *dst++ = *src++;
        case 5:
            *dst++ = *src++;
        case 4:
            *dst++ = *src++;
        case 3:
            *dst++ = *src++;
        case 2:
            *dst++ = *src++;
        case 1:
            *dst++ = *src++;
        } while (--n > 0);
    }
}

static void BM_send(benchmark::State& state) {
    std::default_random_engine e;
    std::uniform_int_distribution<int> u;
    for (int i = 0; i < SIZE; ++i) {
        src_data[i] = u(e);
    }
    for (auto _ : state) {
        send(dst_data, src_data, SIZE);
        benchmark::DoNotOptimize(dst_data);
    }
}

static void BM_send_duff(benchmark::State& state) {
    std::default_random_engine e;
    std::uniform_int_distribution<int> u;
    for (int i = 0; i < SIZE; ++i) {
        src_data[i] = u(e);
    }
    for (auto _ : state) {
        send_duff(dst_data, src_data, SIZE);
        benchmark::DoNotOptimize(dst_data);
    }
}

BENCHMARK(BM_send);
BENCHMARK(BM_send_duff);
BENCHMARK_MAIN();
```

**优化级别为`-O0`时，输出如下：**

```
-------------------------------------------------------
Benchmark             Time             CPU   Iterations
-------------------------------------------------------
BM_send         2421895 ns      2421629 ns          246
BM_send_duff    2285804 ns      2285575 ns          308
```

**优化级别为`-O3`时，输出如下：**

```
-------------------------------------------------------
Benchmark             Time             CPU   Iterations
-------------------------------------------------------
BM_send         1101873 ns      1101771 ns          635
BM_send_duff    1106143 ns      1106032 ns          636
```

可见，经过编译器优化后，两者的性能相差无几，因此，我们无需手动做这类优化

## 1.11 hash vs. sort

在数据库场景中，同一个算子的实现可以有多种，比如`Join`可以是`Sort Based Join`或者`Hash Based Join`，理论上来说，`Hash`的性能更高，因为它是`O(N)`复杂度，而`Sort`一般是`O(NlgN)`，但是在实际的场景中，常量也是一个重要的因素，因此下面的benchmark用于探究在不同场景下`Sort`和`Hash`的性能

```cpp
#include <benchmark/benchmark.h>

#include <random>
#include <unordered_map>
#include <vector>

void walk_through_map(const std::vector<int32_t>& values) {
    std::unordered_map<int32_t, int32_t> map;
    for (auto value : values) {
        map[value] = value;
    }
    benchmark::DoNotOptimize(map);
    int32_t sum = 0;
    for (auto& [key, value] : map) {
        sum += value;
    }
    benchmark::DoNotOptimize(sum);
}

void walk_through_sort(const std::vector<int32_t>& values) {
    std::vector<int32_t> ordered(values.begin(), values.end());
    std::sort(ordered.begin(), ordered.end());
    benchmark::DoNotOptimize(ordered);
    int32_t sum = 0;
    for (auto& value : ordered) {
        sum += value;
    }
    benchmark::DoNotOptimize(sum);
}

static void walk_through_map(benchmark::State& state) {
    static std::default_random_engine e;
    const auto length = state.range(0);
    const auto cardinality = state.range(1);
    std::uniform_int_distribution<int32_t> u(0, cardinality);
    std::vector<int32_t> values;
    for (int i = 0; i < length; i++) {
        values.push_back(u(e));
    }
    for (auto _ : state) {
        walk_through_map(values);
    }
}

static void walk_through_sort(benchmark::State& state) {
    static std::default_random_engine e;
    const auto length = state.range(0);
    const auto cardinality = state.range(1);
    std::vector<int32_t> values;
    std::uniform_int_distribution<int32_t> u(0, cardinality);
    for (int i = 0; i < length; i++) {
        values.push_back(u(e));
    }
    for (auto _ : state) {
        walk_through_sort(values);
    }
}

constexpr size_t length_100K = 100000;
constexpr size_t length_1M = 1000000;
constexpr size_t length_10M = 10000000;
constexpr size_t length_100M = 100000000;

#define BUILD_ARGS(length)                           \
    ->Args({length, (long)(length * 1)})             \
            ->Args({length, (long)(length * 0.5)})   \
            ->Args({length, (long)(length * 0.1)})   \
            ->Args({length, (long)(length * 0.05)})  \
            ->Args({length, (long)(length * 0.01)})  \
            ->Args({length, (long)(length * 0.005)}) \
            ->Args({length, (long)(length * 0.001)})

#define BUILD_BENCHMARK(name) \
    BENCHMARK(name)           \
    BUILD_ARGS(length_100K)   \
    BUILD_ARGS(length_1M)     \
    BUILD_ARGS(length_10M)    \
    BUILD_ARGS(length_100M)

BUILD_BENCHMARK(walk_through_map);
BUILD_BENCHMARK(walk_through_sort);

BENCHMARK_MAIN();
```

结果如下，可以发现：

* 当基数较低时，`hash`性能更好
* 当基数较高时，`sort`性能更好

```
--------------------------------------------------------------------------------
Benchmark                                      Time             CPU   Iterations
--------------------------------------------------------------------------------
walk_through_map/100000/100000           8636963 ns      8636513 ns           81
walk_through_map/100000/50000            6366875 ns      6366535 ns          109
walk_through_map/100000/10000            1673647 ns      1673538 ns          419
walk_through_map/100000/5000             1250455 ns      1250342 ns          558
walk_through_map/100000/1000              923048 ns       922904 ns          758
walk_through_map/100000/500               882537 ns       882477 ns          792
walk_through_map/100000/100               853013 ns       852950 ns          820
walk_through_map/1000000/1000000       143390781 ns    143372481 ns            5
walk_through_map/1000000/500000        103008123 ns    102991327 ns            7
walk_through_map/1000000/100000         29208765 ns     29205713 ns           24
walk_through_map/1000000/50000          20150060 ns     20148346 ns           35
walk_through_map/1000000/10000           9287158 ns      9286203 ns           75
walk_through_map/1000000/5000            8815741 ns      8814831 ns           79
walk_through_map/1000000/1000            8375886 ns      8375070 ns           84
walk_through_map/10000000/10000000    4002424030 ns   4001833235 ns            1
walk_through_map/10000000/5000000     2693123212 ns   2692943252 ns            1
walk_through_map/10000000/1000000     1076483581 ns   1076438325 ns            1
walk_through_map/10000000/500000       630116707 ns    630089794 ns            1
walk_through_map/10000000/100000       193023047 ns    192987351 ns            4
walk_through_map/10000000/50000        157515867 ns    157498497 ns            4
walk_through_map/10000000/10000         85139131 ns     85128214 ns            8
walk_through_map/100000000/100000000  5.1183e+10 ns   5.1175e+10 ns            1
walk_through_map/100000000/50000000   3.9879e+10 ns   3.9871e+10 ns            1
walk_through_map/100000000/10000000   2.9220e+10 ns   2.9218e+10 ns            1
walk_through_map/100000000/5000000    2.5468e+10 ns   2.5467e+10 ns            1
walk_through_map/100000000/1000000    1.7363e+10 ns   1.7362e+10 ns            1
walk_through_map/100000000/500000     1.3896e+10 ns   1.3894e+10 ns            1
walk_through_map/100000000/100000     1921860931 ns   1921779584 ns            1
walk_through_sort/100000/100000          6057105 ns      6056490 ns          118
walk_through_sort/100000/50000           6036402 ns      6035855 ns          116
walk_through_sort/100000/10000           5569400 ns      5569251 ns          125
walk_through_sort/100000/5000            5246500 ns      5246360 ns          133
walk_through_sort/100000/1000            4401430 ns      4401309 ns          158
walk_through_sort/100000/500             4070692 ns      4070582 ns          171
walk_through_sort/100000/100             3353855 ns      3353763 ns          211
walk_through_sort/1000000/1000000       72202569 ns     72199515 ns           10
walk_through_sort/1000000/500000        72882608 ns     72880609 ns           10
walk_through_sort/1000000/100000        67659113 ns     67654984 ns           10
walk_through_sort/1000000/50000         63923624 ns     63920953 ns           11
walk_through_sort/1000000/10000         55889055 ns     55886778 ns           12
walk_through_sort/1000000/5000          53487160 ns     53485651 ns           13
walk_through_sort/1000000/1000          45948298 ns     45946604 ns           15
walk_through_sort/10000000/10000000    850539566 ns    850505737 ns            1
walk_through_sort/10000000/5000000     842845660 ns    842812567 ns            1
walk_through_sort/10000000/1000000     806016938 ns    805984295 ns            1
walk_through_sort/10000000/500000      769532280 ns    769496042 ns            1
walk_through_sort/10000000/100000      688427730 ns    688391316 ns            1
walk_through_sort/10000000/50000       656184024 ns    656154090 ns            1
walk_through_sort/10000000/10000       580176790 ns    580159655 ns            1
walk_through_sort/100000000/100000000 1.0196e+10 ns   1.0195e+10 ns            1
walk_through_sort/100000000/50000000  9803249176 ns   9802624677 ns            1
walk_through_sort/100000000/10000000  9383023476 ns   9382273047 ns            1
walk_through_sort/100000000/5000000   9016790984 ns   9015835565 ns            1
walk_through_sort/100000000/1000000   8154018906 ns   8153267525 ns            1
walk_through_sort/100000000/500000    7797706457 ns   7796576221 ns            1
walk_through_sort/100000000/100000    7080835898 ns   7079696031 ns            1
```

## 1.12 scheduling conflict

探究一个类似于`while(true)`的线程，对于系统整体的性能的影响

```cpp
#include <pthread.h>

#include <algorithm>
#include <atomic>
#include <iomanip>
#include <iostream>
#include <thread>
#include <vector>

void start_disturb_task(std::atomic<bool>& start, std::atomic<bool>& stop, int32_t cpu_num) {
    while (!start.load(std::memory_order_relaxed))
        ;

    pthread_t thread = pthread_self();
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    for (int32_t i = 0; i < cpu_num; i++) {
        CPU_SET(i, &cpuset);
    }
    pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);

    while (!stop.load(std::memory_order_relaxed))
        ;
}

void start_task(std::atomic<bool>& start, std::atomic<bool>& stop, std::vector<size_t>& counts, int32_t cpu_num,
                int32_t task_id) {
    while (!start.load(std::memory_order_relaxed))
        ;

    pthread_t thread = pthread_self();
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    for (int32_t i = 0; i < cpu_num; i++) {
        CPU_SET(i, &cpuset);
    }
    pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);

    int32_t cnt = 0;
    while (!stop.load(std::memory_order_relaxed)) {
        ++cnt;
    };

    counts[task_id] = cnt;
}

int main(int argc, char* argv[]) {
    if (argc != 4) {
        std::cerr << "required 3 parameters" << std::endl;
        return 1;
    }
    const bool has_disturb_task = std::atoi(argv[1]);
    const int32_t cpu_num = std::atoi(argv[2]);
    const int32_t task_num = std::atoi(argv[3]);
    if (cpu_num >= std::thread::hardware_concurrency()) {
        std::cerr << "the maximum cpu_num is " << std::thread::hardware_concurrency() << std::endl;
        return 1;
    }
    if (cpu_num < task_num) {
        std::cerr << "cpu_num must greater than or equal to task_num" << std::endl;
        return 1;
    }

    std::atomic<bool> start(false);
    std::atomic<bool> stop(false);
    std::vector<std::thread> threads;
    std::vector<size_t> counts(task_num);
    for (int32_t task_id = 0; task_id < task_num; task_id++) {
        threads.emplace_back(
                [&start, &stop, &counts, cpu_num, task_id]() { start_task(start, stop, counts, cpu_num, task_id); });
    }
    if (has_disturb_task) {
        threads.emplace_back([&start, &stop, cpu_num]() { start_disturb_task(start, stop, cpu_num); });
    }

    start.store(true, std::memory_order_relaxed);
    std::this_thread::sleep_for(std::chrono::seconds(1));
    stop.store(true, std::memory_order_relaxed);

    std::for_each(threads.begin(), threads.end(), [](auto& t) { t.join(); });

    std::sort(counts.begin(), counts.end());
    size_t sum = 0;
    for (int32_t task_id = 0; task_id < task_num; task_id++) {
        sum += counts[task_id];
        std::cout << "count=" << counts[task_id] << std::endl;
    }
    const size_t min = counts[0];
    const size_t max = counts[task_num - 1];
    const size_t avg = sum / task_num;
    const size_t distance = max - min;
    std::cout << "min=" << min << ", max=" << max << ", avg=" << avg << ", distance=" << max - min << ", " << std::fixed
              << std::setprecision(2) << distance * 100 / avg << "%" << std::endl;
    return 0;
}
```

**输出如下：**

* 当不启动干扰线程时，各个任务的效率相近
* 当启动干扰线程时
    * 当任务数与使用cpu数相同时，各个任务的性能会有较大的差异
    * 当任务数比使用的cpu数少一个时，任务的性能不受干扰线程的影响

```sh
# 不启动干扰线程
$ ./main 0 4 4
count=1558923686
count=1561655749
count=1561677472
count=1574325894
min=1558923686, max=1574325894, avg=1564145700, distance=15402208, 0%

# 启动干扰线程，任务数与使用的cpu数保持一致
$ ./main 1 4 4
count=784345272
count=795504369
count=1555650488
count=1566268580
min=784345272, max=1566268580, avg=1175442177, distance=781923308, 66%

# 启动干扰线程，任务数比使用的cpu数少一个
$ ./main 1 4 3
count=1541029371
count=1541571957
count=1550834469
min=1541029371, max=1550834469, avg=1544478599, distance=9805098, 0%
```

## 1.13 NUMA

首先，我们将当前线程绑定到`CPU-0`上，一般来说说，`CPU-0`属于`node-0`，因此我们将内存分别分配在`node-0`和`node-1`来对比程序的性能

```cpp
#include <benchmark/benchmark.h>
#include <numa.h>
#include <numaif.h>

#include <limits>
#include <random>

// One cache line only contains one instance
struct alignas(64) Double {
    double data;
};

static_assert(sizeof(Double) == 64);

void matrix_multiply(Double* A, Double* B, Double* C, size_t size) {
    for (size_t i = 0; i < size; i++) {
        for (size_t j = 0; j < size; j++) {
            double sum = 0.0;
            for (size_t k = 0; k < size; k++) {
                sum += A[i * size + k].data * B[k * size + j].data;
            }
            C[i * size + j].data = sum;
        }
    }
}

static void BM_base(benchmark::State& state, size_t node_id) {
    pthread_t thread = pthread_self();
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(0, &cpuset);
    pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);

    size_t size = state.range(0);

    // Assume that cpu0 belongs node0, you can check by `numactl --hardware`
    Double* A = (Double*)numa_alloc_onnode(sizeof(Double) * size * size, node_id);
    Double* B = (Double*)numa_alloc_onnode(sizeof(Double) * size * size, node_id);
    Double* C = (Double*)numa_alloc_onnode(sizeof(Double) * size * size, node_id);

    static std::default_random_engine e;
    static std::uniform_real_distribution<double> u(std::numeric_limits<double>::min(),
                                                    std::numeric_limits<double>::max());
    for (size_t i = 0; i < size * size; i++) {
        A[i].data = u(e);
        B[i].data = u(e);
    }

    for (auto _ : state) {
        matrix_multiply(A, B, C, size);
    }

    numa_free(A, size * size);
    numa_free(B, size * size);
    numa_free(C, size * size);
}

static void BM_of_same_node(benchmark::State& state) {
    BM_base(state, 0);
}

static void BM_of_differenct_node(benchmark::State& state) {
    BM_base(state, 1);
}

BENCHMARK(BM_of_same_node)->Arg(8)->Arg(16)->Arg(32)->Arg(64)->Arg(128)->Arg(256)->Arg(512)->Arg(1024)->Arg(2048);
BENCHMARK(BM_of_differenct_node)->Arg(8)->Arg(16)->Arg(32)->Arg(64)->Arg(128)->Arg(256)->Arg(512)->Arg(1024)->Arg(2048);

BENCHMARK_MAIN();
```

**输出如下：**

```
---------------------------------------------------------------------
Benchmark                           Time             CPU   Iterations
---------------------------------------------------------------------
BM_of_same_node/8                 311 ns          310 ns      2254997
BM_of_same_node/16               2643 ns         2642 ns       264941
BM_of_same_node/32              27342 ns        27331 ns        25599
BM_of_same_node/64             301103 ns       300904 ns         2323
BM_of_same_node/128           3766203 ns      3764507 ns          174
BM_of_same_node/256          50045765 ns     50012669 ns           12
BM_of_same_node/512         478258490 ns    477829744 ns            2
BM_of_same_node/1024       7752174783 ns   7745304607 ns            1
BM_of_same_node/2048       8.5503e+10 ns   8.5426e+10 ns            1
BM_of_differenct_node/8           310 ns          310 ns      2255891
BM_of_differenct_node/16         2641 ns         2640 ns       265112
BM_of_differenct_node/32        27031 ns        27019 ns        25909
BM_of_differenct_node/64       299999 ns       299872 ns         2324
BM_of_differenct_node/128     3714475 ns      3712159 ns          184
BM_of_differenct_node/256    54170223 ns     54113018 ns           12
BM_of_differenct_node/512   475983551 ns    475561817 ns            2
BM_of_differenct_node/1024 1.0282e+10 ns   1.0273e+10 ns            1
BM_of_differenct_node/2048 1.1860e+11 ns   1.1849e+11 ns            1
```

## 1.14 `_mm_pause` and `sched_yield`

The `_mm_pause` instruction is a hardware-specific instruction that provides a hint to the processor to pause for a brief moment. It's beneficial in spin-wait loops because it can reduce the power consumption and potentially increase the performance of the spinning code. This is particularly used in x86 architectures. On the other hand, `sched_yield()` is a system call that yields the processor so another thread or process can run. The context switch overhead associated with `sched_yield()` can be significant compared to the lightweight `_mm_pause`.

### 1.14.1 Overhead

Below is a simple C++ code example to demonstrate the efficiency of `_mm_pause` over `sched_yield` in a spin-wait scenario. This example uses both methods in a tight loop and measures the elapsed time:

```cpp
#include <emmintrin.h> // for _mm_pause
#include <sched.h>     // for sched_yield

#include <chrono>
#include <iostream>
#include <thread>

constexpr int ITERATIONS = 100000000;

void spin_with_pause() {
    for (int i = 0; i < ITERATIONS; ++i) {
        _mm_pause();
    }
}

void spin_with_yield() {
    for (int i = 0; i < ITERATIONS; ++i) {
        sched_yield();
    }
}

int main() {
    auto start = std::chrono::high_resolution_clock::now();
    spin_with_pause();
    auto end = std::chrono::high_resolution_clock::now();
    auto pause_duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

    start = std::chrono::high_resolution_clock::now();
    spin_with_yield();
    end = std::chrono::high_resolution_clock::now();
    auto yield_duration = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();

    std::cout << "__mm_pause took: " << pause_duration << " ms\n";
    std::cout << "sched_yield took: " << yield_duration << " ms\n";

    return 0;
}
```

**Output:**

```
__mm_pause took: 1308 ms
sched_yield took: 40691 ms
```

### 1.14.2 Yield Efficiency

```cpp
#include <emmintrin.h>
#include <pthread.h>

#include <atomic>
#include <iostream>
#include <thread>
#include <vector>

struct alignas(64) Counter {
    int64_t cnt = 0;
};

int main(int argc, char** argv) {
    size_t num_threads = std::atoi(argv[1]);
    if (num_threads < 2) {
        std::cerr << "Minimum threads number is 2" << std::endl;
        return 1;
    }

    size_t start_core_num = std::atoi(argv[2]);

    bool has_interrupt_thread = static_cast<bool>(std::atoi(argv[3]));

#ifdef USE_PAUSE
    std::cout << "interrupt thread use _mm_pause" << std::endl;
#elif USE_YIELD
    std::cout << "interrupt thread use sched_yield" << std::endl;
#else
    std::cout << "interrupt use no pause" << std::endl;
#endif

    std::atomic<bool> is_started = false;
    std::atomic<bool> is_stoped = false;
    std::vector<std::thread> threads;

    // Make each Counter use differnt cache line to avoid false sharing
    std::vector<Counter> counters(num_threads);
    for (int32_t i = 0; i < num_threads; i++) {
        Counter& counter = counters[i];
        threads.emplace_back([start_core_num, i, &is_started, &is_stoped, &counter]() {
            // Each thread bind to indivial core
            cpu_set_t cpuset;
            CPU_ZERO(&cpuset);
            CPU_SET(start_core_num + i, &cpuset);
            pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);

            while (!is_started)
                ;

            while (!is_stoped) {
                counter.cnt++;
            }
        });
    }

    if (has_interrupt_thread) {
        threads.emplace_back([start_core_num, num_threads, &is_started, &is_stoped]() {
            // Let the thread to interrupt all the above cores
            cpu_set_t cpuset;
            CPU_ZERO(&cpuset);
            for (int32_t i = 0; i < num_threads; i++) {
                CPU_SET(start_core_num + i, &cpuset);
            }
            pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);
            while (!is_started)
                ;

            std::vector<int64_t> waste_cpu(128, 0);
            int64_t increment = 1;
            while (!is_stoped) {
                for (size_t i = 0; i < waste_cpu.size(); i++) {
                    waste_cpu[i]++;
                }
#ifdef USE_PAUSE
                _mm_pause();
#elif USE_YIELD
                sched_yield();
#else
#endif
            }

            int64_t sum = 0;
            for (size_t i = 0; i < waste_cpu.size(); i++) {
                sum += waste_cpu[i];
            }
            std::cout << "waste_cpu count=" << sum << std::endl;
        });
    }

    is_started = true;
    std::this_thread::sleep_for(std::chrono::seconds(10));
    is_stoped = true;

    for (size_t i = 0; i < num_threads + (has_interrupt_thread ? 1 : 0); i++) {
        threads[i].join();
    }

    for (size_t i = 0; i < num_threads; i++) {
        std::cout << "core[" << start_core_num + i << "], count[" << i << "] = " << counters[i].cnt << std::endl;
    }
}
```

```sh
gcc main.cpp -o main -std=gnu++17 -lstdc++ -O3 -lpthread
gcc main.cpp -o main_pause -std=gnu++17 -lstdc++ -O3 -lpthread -DUSE_PAUSE
gcc main.cpp -o main_yield -std=gnu++17 -lstdc++ -O3 -lpthread -DUSE_YIELD
```

**Output:**

* The interrupt thread is expected to interfere all threads, but only the first is affected.
* `sched_yield` cause less waste cpu, but no workers benefit from this.

```
./main 4 4 0
interrupt use no pause
core[4], count[0] = 6368495550
core[5], count[1] = 6333007854
core[6], count[2] = 6371084322
core[7], count[3] = 6359023912

./main 4 4 1
interrupt use no pause
waste_cpu count=24851352576
core[4], count[0] = 3180423432
core[5], count[1] = 6369418045
core[6], count[2] = 6360849361
core[7], count[3] = 6363051924

./main_pause 4 4 1
interrupt thread use _mm_pause
waste_cpu count=12696568448
core[4], count[0] = 3113864260
core[5], count[1] = 6201393330
core[6], count[2] = 6218519003
core[7], count[3] = 6219291894

./main_yield 4 4 1
interrupt thread use sched_yield
waste_cpu count=1394306304
core[4], count[0] = 3163118852
core[5], count[1] = 6327199281
core[6], count[2] = 6360709178
core[7], count[3] = 6331732824
```

## 1.15 `|` or `||`

```cpp
#include <benchmark/benchmark.h>

#include <algorithm>
#include <random>

static void BM_logical_and(benchmark::State& state) {
    std::vector<std::pair<int32_t, int32_t>> pairs;
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u(0, 100);
    for (size_t i = 0; i < 1000000; i++) {
        pairs.emplace_back(u(e), u(e));
    }

    int64_t sum = 0;

    for (auto _ : state) {
        for (const auto& kv : pairs) {
            if (kv.first > 50 || kv.second < 50) {
                sum++;
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_bit_and(benchmark::State& state) {
    std::vector<std::pair<int32_t, int32_t>> pairs;
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u(0, 100);
    for (size_t i = 0; i < 1000000; i++) {
        pairs.emplace_back(u(e), u(e));
    }

    int64_t sum = 0;

    for (auto _ : state) {
        for (const auto& kv : pairs) {
            if (static_cast<int32_t>(kv.first > 50) | static_cast<int32_t>(kv.second < 50)) {
                sum++;
            }
        }
        benchmark::DoNotOptimize(sum);
    }
}

BENCHMARK(BM_logical_and);
BENCHMARK(BM_bit_and);

BENCHMARK_MAIN();
```

**Output(`-O0`):**

```
---------------------------------------------------------
Benchmark               Time             CPU   Iterations
---------------------------------------------------------
BM_logical_and   21531574 ns     21530951 ns           33
BM_bit_and       15899873 ns     15899244 ns           44
```

**Output(`-O3`):**

```
---------------------------------------------------------
Benchmark               Time             CPU   Iterations
---------------------------------------------------------
BM_logical_and    7310336 ns      7281142 ns           91
BM_bit_and        6431491 ns      6431208 ns          103
```

## 1.16 `if` or `switch`

```cpp
#include <benchmark/benchmark.h>
#include <numa.h>
#include <numaif.h>

void add_by_if(int8_t type, int32_t& num) {
    if (type == 0) {
        num += 1;
    } else if (type == 1) {
        num += -2;
    } else if (type == 2) {
        num += 3;
    } else if (type == 3) {
        num += -4;
    } else if (type == 4) {
        num += 5;
    } else if (type == 5) {
        num += -6;
    } else if (type == 6) {
        num += 7;
    } else if (type == 7) {
        num += -8;
    } else if (type == 8) {
        num += 9;
    } else if (type == 9) {
        num += -10;
    } else if (type == 10) {
        num += 11;
    } else if (type == 11) {
        num += -12;
    } else if (type == 12) {
        num += 13;
    } else if (type == 13) {
        num += -14;
    } else if (type == 14) {
        num += 15;
    } else if (type == 15) {
        num += -16;
    } else if (type == 16) {
        num += 17;
    } else if (type == 17) {
        num += -18;
    } else if (type == 18) {
        num += 19;
    } else if (type == 19) {
        num += -20;
    } else if (type == 20) {
        num += 21;
    }
}

void add_by_switch(int8_t type, int32_t& num) {
    switch (type) {
    case 0:
        num += 1;
        break;
    case 1:
        num += -2;
        break;
    case 2:
        num += 3;
        break;
    case 3:
        num += -4;
        break;
    case 4:
        num += 5;
        break;
    case 5:
        num += -6;
        break;
    case 6:
        num += 7;
        break;
    case 7:
        num += -8;
        break;
    case 8:
        num += 9;
        break;
    case 9:
        num += -10;
        break;
    case 10:
        num += 11;
        break;
    case 11:
        num += -12;
        break;
    case 12:
        num += 13;
        break;
    case 13:
        num += -14;
        break;
    case 14:
        num += 15;
        break;
    case 15:
        num += -16;
        break;
    case 16:
        num += 17;
        break;
    case 17:
        num += -18;
        break;
    case 18:
        num += 19;
        break;
    case 19:
        num += -20;
        break;
    case 20:
        num += 21;
        break;
    }
}

inline constexpr int8_t BRANCH_SIZE = 21;
inline constexpr size_t _1M = 1000000;

static void BM_if(benchmark::State& state) {
    for (auto _ : state) {
        int32_t num = 0;
        for (size_t i = 0; i < _1M; ++i) {
            add_by_if(i % BRANCH_SIZE, num);
        }
        benchmark::DoNotOptimize(num);
    }
}

static void BM_switch(benchmark::State& state) {
    for (auto _ : state) {
        int32_t num = 0;
        for (size_t i = 0; i < _1M; ++i) {
            add_by_if(i % BRANCH_SIZE, num);
        }
        benchmark::DoNotOptimize(num);
    }
}

BENCHMARK(BM_if);
BENCHMARK(BM_switch);

BENCHMARK_MAIN();
```

**Output:**

```
-----------------------------------------------------
Benchmark           Time             CPU   Iterations
-----------------------------------------------------
BM_if         7792759 ns      7792431 ns           90
BM_switch     7764055 ns      7763436 ns           90
```

# 2 pointer aliasing

**`pointer aliasing`指的是两个指针（在作用域内）指向了同一个物理地址，或者说指向的物理地址有重叠。`__restrict`关键词用于给编译器一个提示：确保被标记的指针是独占物理地址的**

## 2.1 assembly

**下面以几个简单的例子说明`__restrict`关键词的作用，以及它是如何引导编译器进行指令优化的**

### 2.1.1 case1

```sh
# 创建源文件
cat > main.cpp << 'EOF'
#include <stdint.h>

uint32_t add1(uint32_t* a, uint32_t* b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

uint32_t add2(uint32_t* __restrict a, uint32_t* __restrict b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

uint32_t add3(uint32_t* __restrict a, uint32_t* b) {
    *a = 1;
    *b = 2;
    return *a + *b;
}

int main() {
    return 0;
}
EOF

# 编译
gcc -o main.c main.cpp -c -Wall -O3 -g

# 反汇编
objdump -drwCS main.c
```

**输出如下：**

```
uint32_t add1(uint32_t* a, uint32_t* b) {
    *a = 1;
   0:	c7 07 01 00 00 00    	movl   $0x1,(%rdi)      # 将1写入rdi指向的地址
    *b = 2;
   6:	c7 06 02 00 00 00    	movl   $0x2,(%rsi)      # 将2写入rsi指向的地址
    return *a + *b;
   c:	8b 07                	mov    (%rdi),%eax      # 将rdi指向的地址中的值写入eax
   e:	83 c0 02             	add    $0x2,%eax        # eax中的值加2
}
  11:	c3                   	retq
  12:	0f 1f 40 00          	nopl   0x0(%rax)
  16:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

0000000000000020 <add2(unsigned int*, unsigned int*)>:

uint32_t add2(uint32_t* __restrict a, uint32_t* __restrict b) {
    *a = 1;
  20:	c7 07 01 00 00 00    	movl   $0x1,(%rdi)      # 将1写入rdi指向的地址
    *b = 2;
    return *a + *b;
}
  26:	b8 03 00 00 00       	mov    $0x3,%eax        # 将3写入eax（直接算出了1 + 2 = 3）
    *b = 2;
  2b:	c7 06 02 00 00 00    	movl   $0x2,(%rsi)      # 将2写入rsi指向的地址
}
  31:	c3                   	retq
  32:	0f 1f 40 00          	nopl   0x0(%rax)
  36:	66 2e 0f 1f 84 00 00 00 00 00 	nopw   %cs:0x0(%rax,%rax,1)

0000000000000040 <add3(unsigned int*, unsigned int*)>:

uint32_t add3(uint32_t* __restrict a, uint32_t* b) {
    *a = 1;
  40:	c7 07 01 00 00 00    	movl   $0x1,(%rdi)      # 将1写入rdi指向的地址
    *b = 2;
    return *a + *b;
}
  46:	b8 03 00 00 00       	mov    $0x3,%eax        # 将3写入eax（直接算出了1 + 2 = 3）
    *b = 2;
  4b:	c7 06 02 00 00 00    	movl   $0x2,(%rsi)      # 将2写入rsi指向的地址
}
  51:	c3                   	retq
```

**结论：**

* 对于函数`add1`，其结果可能是3（`a`和`b`指向不同地址）或者4（`a`和`b`指向相同地址）
* 函数`add2`和`add3`得到的汇编指令是一样的，因为只有`*a = 1;`可能会被`*b = 2;`覆盖

### 2.1.2 case2

```sh
# 创建源文件
cat > main.cpp << 'EOF'
#include <libio.h>
#include <stdint.h>

uint32_t loop1(uint32_t* num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t loop2(uint32_t* __restrict num1, uint32_t* __restrict num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t loop3(uint32_t* __restrict num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

int main() {
    return 0;
}
EOF

# 编译
gcc -o main.c main.cpp -c -Wall -O3 -g

# 反汇编
objdump -drwCS main.c
```

**输出如下：**

```
uint32_t loop1(uint32_t* num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
   0:	31 c0                	xor    %eax,%eax
    uint32_t res = 0;
   2:	45 31 c0             	xor    %r8d,%r8d
   5:	0f 1f 00             	nopl   (%rax)
        *num2 = i;
   8:	89 06                	mov    %eax,(%rsi)
    for (size_t i = 0; i < 100; ++i) {
   a:	48 83 c0 01          	add    $0x1,%rax
        res += *num1;
   e:	44 03 07             	add    (%rdi),%r8d          # 从rdi指向的地址读取值，并累加到r8d中（每次循环都要执行这个）
    for (size_t i = 0; i < 100; ++i) {
  11:	48 83 f8 64          	cmp    $0x64,%rax
  15:	75 f1                	jne    8 <loop1(unsigned int*, unsigned int*)+0x8>
    }
    return res;
}
  17:	44 89 c0             	mov    %r8d,%eax
  1a:	c3                   	retq
  1b:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)

0000000000000020 <loop2(unsigned int*, unsigned int*)>:

uint32_t loop2(uint32_t* __restrict num1, uint32_t* __restrict num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
  20:	6b 07 64             	imul   $0x64,(%rdi),%eax    # 直接将rdi指向的地址中的值乘以100（0x64），并将结果写入eax
  23:	c7 06 63 00 00 00    	movl   $0x63,(%rsi)         # 直接将99写入rsi指向的地址
    }
    return res;
}
  29:	c3                   	retq
  2a:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)

0000000000000030 <loop3(unsigned int*, unsigned int*)>:

uint32_t loop3(uint32_t* __restrict num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < 100; ++i) {
        *num2 = i;
        res += *num1;
  30:	6b 07 64             	imul   $0x64,(%rdi),%eax    # 直接将rdi指向的地址中的值乘以100（0x64），并将结果写入eax
  33:	c7 06 63 00 00 00    	movl   $0x63,(%rsi)         # 直接将99写入rsi指向的地址
    }
    return res;
}
  39:	c3                   	retq
```

**结论：**

1. 对于函数`loop1`，由于赋值语句`*num2 = i;`的存在，导致编译器无法直接计算结果，因为该语句可能会修改`num1`的值（`num1`和`num2`指向同一地址）
1. 函数`loop2`和`loop3`生成的指令一样，都可以在编译期直接计算结果

## 2.2 benchmark

```cpp
#include <benchmark/benchmark.h>

#define ARRAY_LEN 10000

uint32_t __attribute__((noinline)) sum_without_restrict(uint32_t* num1, uint32_t* num2, size_t len) {
    uint32_t res = 0;
    for (size_t i = 0; i < len; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t __attribute__((noinline)) sum_with_restrict(uint32_t* __restrict num1, uint32_t* __restrict num2, size_t len) {
    uint32_t res = 0;
    for (size_t i = 0; i < len; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

static void BM_sum_without_restrict(benchmark::State& state) {
    uint32_t num1 = 0;
    uint32_t num2 = 0;
    for (auto _ : state) {
        ++num1;
        ++num2;
        benchmark::DoNotOptimize(sum_without_restrict(&num1, &num2, ARRAY_LEN));
    }
}

static void BM_sum_with_restrict(benchmark::State& state) {
    uint32_t num1 = 0;
    uint32_t num2 = 0;
    for (auto _ : state) {
        ++num1;
        ++num2;
        benchmark::DoNotOptimize(sum_with_restrict(&num1, &num2, ARRAY_LEN));
    }
}

BENCHMARK(BM_sum_without_restrict);
BENCHMARK(BM_sum_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
------------------------------------------------------------------
Benchmark                        Time             CPU   Iterations
------------------------------------------------------------------
BM_sum_without_restrict       3145 ns         3145 ns       222606
BM_sum_with_restrict          2.85 ns         2.85 ns    243455429
```

# 3 vectorization

## 3.1 Introduction

**向量化使用的特殊寄存器**

* `xmm`：128-bit
* `ymm`：256-bit
* `zmm`：512-bit

## 3.2 pointer aliasing

### 3.2.1 case1

**在这个`case`中，`sum`和`nums`都是`uint32_t`类型的指针，它们之间是存在`pointer aliasing`的。在不加`__restrict`的情况下，编译器无法对其进行向量化（这与`pointer aliasing`的`benchmark`结果不一致！！！）**

```cpp
#include <benchmark/benchmark.h>

#define LEN 100

void __attribute__((noinline)) loop_without_optimize(uint32_t* sum, uint32_t* nums, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        *sum += nums[i];
    }
}

void __attribute__((noinline)) loop_with_local_sum(uint32_t* sum, uint32_t* nums, size_t len) {
    uint32_t local_sum = 0;
    for (size_t i = 0; i < len; ++i) {
        local_sum += nums[i];
    }
    *sum += local_sum;
}

void __attribute__((noinline)) loop_with_restrict(uint32_t* __restrict sum, uint32_t* nums, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        *sum += nums[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    uint32_t sum;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_without_optimize(&sum, nums, LEN);
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_loop_with_local_sum(benchmark::State& state) {
    uint32_t sum;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_with_local_sum(&sum, nums, LEN);
        benchmark::DoNotOptimize(sum);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    uint32_t sum;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_with_restrict(&sum, nums, LEN);
        benchmark::DoNotOptimize(sum);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_local_sum);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_optimize       52.1 ns         52.1 ns     13414412
BM_loop_with_local_sum         9.69 ns         9.69 ns     72266654
BM_loop_with_restrict          9.79 ns         9.79 ns     70959645
```

### 3.2.2 case2

**在`case1`的基础之上，将`sum`放到一个结构体内，且将sum改成非指针类型**

```cpp
#include <benchmark/benchmark.h>

#define LEN 100

class Aggregator {
public:
    uint32_t& sum() { return _sum; }

private:
    uint32_t _sum = 0;
};

void __attribute__((noinline)) loop_without_optimize(Aggregator* aggregator, uint32_t* nums, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += nums[i];
    }
}

void __attribute__((noinline)) loop_with_local_sum(Aggregator* aggregator, uint32_t* nums, size_t len) {
    uint32_t local_sum = 0;
    for (size_t i = 0; i < len; ++i) {
        local_sum += nums[i];
    }
    aggregator->sum() += local_sum;
}

void __attribute__((noinline)) loop_with_restrict(Aggregator* __restrict aggregator, uint32_t* nums, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += nums[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_without_optimize(&aggregator, nums, LEN);
        benchmark::DoNotOptimize(aggregator);
    }
}

static void BM_loop_with_local_sum(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_with_local_sum(&aggregator, nums, LEN);
        benchmark::DoNotOptimize(aggregator);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    for (auto _ : state) {
        loop_with_restrict(&aggregator, nums, LEN);
        benchmark::DoNotOptimize(aggregator);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_local_sum);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_optimize       52.7 ns         52.6 ns     13278349
BM_loop_with_local_sum         10.2 ns         10.2 ns     68763960
BM_loop_with_restrict          10.2 ns         10.2 ns     69550202
```

**结论：**

1. `gcc`无法对类型的成员变量进行向量化优化
1. `__restrict`与本地数组能达到相似地优化效果

**如果把`uint32_t* nums`换成`std::vector<unt32_t>& nums`或者`std::vector<unt32_t>* nums`。都无法得到上述的结果，因为在这种情况下gcc不会认为`Aggregator::_sum`存在`pointer aliasing`，因此可以直接进行优化**

### 3.2.3 case3

**在`case2`的基础之上，`nums`放到另一个结构体中**

```cpp
#include <benchmark/benchmark.h>

#include <vector>

#define LEN 100

class Aggregator {
public:
    uint32_t& sum() { return _sum; }

private:
    uint32_t _sum = 0;
};

class Container {
public:
    std::vector<uint32_t>& nums() { return _nums; }

private:
    std::vector<uint32_t> _nums;
};

void __attribute__((noinline)) loop_without_optimize(Aggregator* aggregator, Container* container) {
    size_t len = container->nums().size();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += container->nums()[i];
    }
}

void __attribute__((noinline)) loop_with_local_sum(Aggregator* aggregator, Container* container) {
    size_t len = container->nums().size();
    uint32_t local_sum = 0;
    for (size_t i = 0; i < len; ++i) {
        local_sum += container->nums()[i];
    }
    aggregator->sum() += local_sum;
}

void __attribute__((noinline)) loop_with_local_array(Aggregator* aggregator, Container* container) {
    size_t len = container->nums().size();
    auto* local_array = container->nums().data();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += local_array[i];
    }
}

void __attribute__((noinline)) loop_with_local_sum_and_local_array(Aggregator* aggregator, Container* container) {
    size_t len = container->nums().size();
    uint32_t local_sum = 0;
    auto* local_array = container->nums().data();
    for (size_t i = 0; i < len; ++i) {
        local_sum += local_array[i];
    }
    aggregator->sum() += local_sum;
}

void __attribute__((noinline)) loop_with_restrict(Aggregator* __restrict aggregator, Container* container) {
    size_t len = container->nums().size();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += container->nums()[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    Aggregator aggregator;
    Container container;
    for (size_t i = 0; i < LEN; ++i) {
        container.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_without_optimize(&aggregator, &container);
        benchmark::DoNotOptimize(aggregator);
        benchmark::DoNotOptimize(container);
    }
}

static void BM_loop_with_local_sum(benchmark::State& state) {
    Aggregator aggregator;
    Container container;
    for (size_t i = 0; i < LEN; ++i) {
        container.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_with_local_sum(&aggregator, &container);
        benchmark::DoNotOptimize(aggregator);
        benchmark::DoNotOptimize(container);
    }
}

static void BM_loop_with_local_array(benchmark::State& state) {
    Aggregator aggregator;
    Container container;
    for (size_t i = 0; i < LEN; ++i) {
        container.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_with_local_array(&aggregator, &container);
        benchmark::DoNotOptimize(aggregator);
        benchmark::DoNotOptimize(container);
    }
}

static void BM_loop_with_local_sum_and_local_array(benchmark::State& state) {
    Aggregator aggregator;
    Container container;
    for (size_t i = 0; i < LEN; ++i) {
        container.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_with_local_sum_and_local_array(&aggregator, &container);
        benchmark::DoNotOptimize(aggregator);
        benchmark::DoNotOptimize(container);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Aggregator aggregator;
    Container container;
    for (size_t i = 0; i < LEN; ++i) {
        container.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_with_restrict(&aggregator, &container);
        benchmark::DoNotOptimize(aggregator);
        benchmark::DoNotOptimize(container);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_local_sum);
BENCHMARK(BM_loop_with_local_array);
BENCHMARK(BM_loop_with_local_sum_and_local_array);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
---------------------------------------------------------------------------------
Benchmark                                       Time             CPU   Iterations
---------------------------------------------------------------------------------
BM_loop_without_optimize                     51.1 ns         51.1 ns     13628157
BM_loop_with_local_sum                       12.1 ns         12.1 ns     58127051
BM_loop_with_local_array                     51.8 ns         51.8 ns     13632597
BM_loop_with_local_sum_and_local_array       11.0 ns         11.0 ns     63710893
BM_loop_with_restrict                        11.6 ns         11.6 ns     60794941
```

**结论：**

1. 由`loop_without_optimize`与`loop_with_local_array`对比可以看出，是否直接使用数组对性能无影响

### 3.2.4 case4

**在`case3`的基础之上，将`sum`和`nums`放到同一个结构体中，这个case非常奇怪，`sum`和`nums`都是Aggregator的成员，编译器在没有`__restrict`的情况下，居然没法进行优化**

```cpp
#include <benchmark/benchmark.h>

#define LEN 100

class Aggregator {
public:
    uint32_t* nums() { return _nums; }
    size_t len() { return _len; }
    uint32_t& sum() { return _sum; }
    void set_nums(uint32_t* nums, size_t len) {
        _nums = nums;
        _len = len;
    }

private:
    uint32_t* _nums;
    size_t _len;
    uint32_t _sum = 0;
};

void __attribute__((noinline)) loop_without_optimize(Aggregator* aggregator) {
    size_t len = aggregator->len();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += aggregator->nums()[i];
    }
}

void __attribute__((noinline)) loop_with_restrict(Aggregator* __restrict aggregator) {
    size_t len = aggregator->len();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += aggregator->nums()[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }
    aggregator.set_nums(nums, LEN);

    for (auto _ : state) {
        loop_without_optimize(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }
    aggregator.set_nums(nums, LEN);

    for (auto _ : state) {
        loop_with_restrict(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_optimize       54.1 ns         54.1 ns     12959382
BM_loop_with_restrict          14.8 ns         14.8 ns     47479924
```

**`Aggregator::_nums`的类型换成`std::vector<uint32_t>`得到的也是类似的结果**

```cpp
#include <benchmark/benchmark.h>

#include <vector>

#define LEN 100

class Aggregator {
public:
    std::vector<uint32_t>& nums() { return _nums; }
    uint32_t& sum() { return _sum; }

private:
    std::vector<uint32_t> _nums;
    uint32_t _sum = 0;
};

void __attribute__((noinline)) loop_without_optimize(Aggregator* aggregator) {
    size_t len = aggregator->nums().size();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += aggregator->nums()[i];
    }
}

void __attribute__((noinline)) loop_with_restrict(Aggregator* __restrict aggregator) {
    size_t len = aggregator->nums().size();
    for (size_t i = 0; i < len; ++i) {
        aggregator->sum() += aggregator->nums()[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    Aggregator aggregator;
    for (size_t i = 0; i < LEN; ++i) {
        aggregator.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_without_optimize(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Aggregator aggregator;
    for (size_t i = 0; i < LEN; ++i) {
        aggregator.nums().push_back(i);
    }

    for (auto _ : state) {
        loop_with_restrict(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_optimize       52.1 ns         52.1 ns     13445879
BM_loop_with_restrict          17.9 ns         17.9 ns     38901664
```

### 3.2.5 case5

**在`case4`的基础之上，将`sum`的类型改成指针类型。一个`object`参数，内部的多个成员变量的关系，函数是无法判断的，所以传入单个 `object`指针，如果有对多个成员变量的访问（并且还是指针），那gcc也没法判断**

```cpp
#include <benchmark/benchmark.h>

#define LEN 100

class Aggregator {
public:
    uint32_t* nums() { return _nums; }
    size_t len() { return _len; }
    uint32_t* sum() { return _sum; }
    void set_nums(uint32_t* nums, size_t len) {
        _nums = nums;
        _len = len;
    }
    void set_sum(uint32_t* sum) { _sum = sum; }

private:
    uint32_t* _nums;
    size_t _len;
    uint32_t* _sum = 0;
};

void __attribute__((noinline)) loop_without_optimize(Aggregator* aggregator) {
    size_t len = aggregator->len();
    for (size_t i = 0; i < len; ++i) {
        *aggregator->sum() += aggregator->nums()[i];
    }
}

void __attribute__((noinline)) loop_with_restrict(Aggregator* __restrict aggregator) {
    size_t len = aggregator->len();
    for (size_t i = 0; i < len; ++i) {
        *aggregator->sum() += aggregator->nums()[i];
    }
}

static void BM_loop_without_optimize(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }
    aggregator.set_nums(nums, LEN);

    uint32_t sum = 0;
    aggregator.set_sum(&sum);

    for (auto _ : state) {
        loop_without_optimize(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Aggregator aggregator;
    uint32_t nums[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }
    aggregator.set_nums(nums, LEN);

    uint32_t sum = 0;
    aggregator.set_sum(&sum);

    for (auto _ : state) {
        loop_with_restrict(&aggregator);
        benchmark::DoNotOptimize(aggregator);
    }
}

BENCHMARK(BM_loop_without_optimize);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_optimize       54.9 ns         54.9 ns     12764430
BM_loop_with_restrict          52.5 ns         52.4 ns     13384598
```

### 3.2.6 case6: versioned for vectorization

```cpp
#include <benchmark/benchmark.h>

#define ARRAY_LEN 10000

void __attribute__((noinline)) loop_without_restrict(uint32_t* dest, uint32_t* value, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        dest[i] += *value;
    }
}

void __attribute__((noinline)) loop_with_restrict(uint32_t* __restrict dest, uint32_t* __restrict value, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        dest[i] += *value;
    }
}

static void BM_loop_without_restrict(benchmark::State& state) {
    uint32_t dstdata[ARRAY_LEN];
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dstdata[i] = 0;
    }

    uint32_t value = 0;
    for (auto _ : state) {
        value += 1;
        loop_without_restrict(dstdata, &value, ARRAY_LEN);

        benchmark::DoNotOptimize(dstdata);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    uint32_t dstdata[ARRAY_LEN];
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dstdata[i] = 0;
    }

    uint32_t value = 0;
    for (auto _ : state) {
        value += 1;
        loop_with_restrict(dstdata, &value, ARRAY_LEN);

        benchmark::DoNotOptimize(dstdata);
    }
}

BENCHMARK(BM_loop_without_restrict);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
-------------------------------------------------------------------
Benchmark                         Time             CPU   Iterations
-------------------------------------------------------------------
BM_loop_without_restrict       2386 ns         2386 ns       295003
BM_loop_with_restrict          2379 ns         2378 ns       294599
```

**分析：**

* 可以看到，就不加`__restrict`性能差不多，若编译时加上`-fopt-info-vec`参数，那么会输出如下信息
    * `6:26: optimized: loop vectorized using 16 byte vectors`
    * `6:26: optimized: loop versioned for vectorization because of possible aliasing`
* **其中第`6`行就是`loop_without_restrict`的`for`循环，可以看到，即便不加`__restrict`，编译器也能向量化，这是为什么呢？下面是我的猜测**
    * 这个函数的主要作用就是在`dest`的每个元素上都增加`value`。由于`value`和`dest`可能存在`pointer aliasing`的关系。那么编译器可以假定存在`pointer aliasing`，那么`&value == &dest[k]`，那么此时循环可以分割成两部分：`0, 1, ..., k-1`以及`k+1, k+2, ..., n`，那么此时，这两部分一定不存在`pointer aliasing`的关系，可以分别向量化

## 3.3 integer vs floating

```cpp
#include <benchmark/benchmark.h>

#define LEN 100

void __attribute__((noinline))
loop_with_integer(uint32_t* __restrict a, uint32_t* __restrict b, uint32_t* __restrict c, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        b[i]++;
        c[i]++;
        a[i] = b[i] + c[i];
    }
}

void __attribute__((noinline))
loop_with_float(double* __restrict a, double* __restrict b, double* __restrict c, size_t len) {
    for (size_t i = 0; i < len; ++i) {
        b[i]++;
        c[i]++;
        a[i] = b[i] + c[i];
    }
}

static void BM_loop_with_integer(benchmark::State& state) {
    uint32_t a[LEN], b[LEN], c[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        a[i] = i;
        b[i] = i;
        c[i] = i;
    }

    for (auto _ : state) {
        loop_with_integer(a, b, c, LEN);
        benchmark::DoNotOptimize(a);
        benchmark::DoNotOptimize(b);
        benchmark::DoNotOptimize(c);
    }
}

static void BM_loop_with_float(benchmark::State& state) {
    double a[LEN], b[LEN], c[LEN];
    for (size_t i = 0; i < LEN; ++i) {
        a[i] = i;
        b[i] = i;
        c[i] = i;
    }

    for (auto _ : state) {
        loop_with_float(a, b, c, LEN);
        benchmark::DoNotOptimize(a);
        benchmark::DoNotOptimize(b);
        benchmark::DoNotOptimize(c);
    }
}

BENCHMARK(BM_loop_with_integer);
BENCHMARK(BM_loop_with_float);

BENCHMARK_MAIN();
```

**输出如下：**

```
---------------------------------------------------------------
Benchmark                     Time             CPU   Iterations
---------------------------------------------------------------
BM_loop_with_integer       64.0 ns         64.0 ns     10942085
BM_loop_with_float         97.3 ns         97.3 ns      7197218
```

## 3.4 manual vs. auto

对比手动实现`simd`和编译器自动优化产生的`simd`之间的性能差异

下面的代码，用三种不同的方式分别计算`d = 3 * a + 4 * b + 5 * c`

* `BM_auto_simd`：最直观的方式写循环
* `BM_fusion_simd`：手动写`simd`，在每个循环内进行处理
* `BM_compose_simd`：手动写`simd`，在循环外进行处理

```cpp
#include <benchmark/benchmark.h>
#include <immintrin.h>

#include <random>

std::vector<int32_t> create_random_vector(int64_t size, int32_t seed) {
    std::vector<int32_t> v;
    v.reserve(size);
    std::default_random_engine e(seed);
    std::uniform_int_distribution<int32_t> u;
    for (size_t i = 0; i < size; ++i) {
        v.emplace_back(u(e));
    }
    return v;
}

void auto_simd(int32_t* __restrict a, int32_t* __restrict b, int32_t* __restrict c, int32_t* __restrict d, int n) {
    for (int i = 0; i < n; i++) {
        d[i] = 3 * a[i] + 4 * b[i] + 5 * c[i];
    }
}

void fusion_simd(int32_t* a, int32_t* b, int32_t* c, int32_t* d, int n) {
    __m512i c0 = _mm512_set1_epi32(3);
    __m512i c1 = _mm512_set1_epi32(4);
    __m512i c2 = _mm512_set1_epi32(5);

    int i = 0;
    for (i = 0; (i + 16) < n; i += 16) {
        __m512i x = _mm512_loadu_epi32(a + i);
        __m512i y = _mm512_loadu_epi32(b + i);
        __m512i z = _mm512_loadu_epi32(c + i);
        x = _mm512_mul_epi32(x, c0);
        y = _mm512_mul_epi32(y, c1);
        x = _mm512_add_epi32(x, y);
        z = _mm512_mul_epi32(z, c2);
        x = _mm512_add_epi32(x, z);
        _mm512_storeu_epi32(d + i, x);
    }

    while (i < n) {
        d[i] = 3 * a[i] + 4 * b[i] + 5 * c[i];
        i += 1;
    }
}

void simd_add(int32_t* a, int32_t* b, int32_t* c, int n) {
    int i = 0;
    for (i = 0; (i + 16) < n; i += 16) {
        __m512i x = _mm512_loadu_epi32(a + i);
        __m512i y = _mm512_loadu_epi32(b + i);
        x = _mm512_add_epi32(x, y);
        _mm512_storeu_epi32(c + i, x);
    }

    while (i < n) {
        c[i] = a[i] + b[i];
        i += 1;
    }
}

void simd_mul(int32_t* a, int32_t b, int32_t* c, int n) {
    int i = 0;
    __m512i c0 = _mm512_set1_epi32(b);
    for (i = 0; (i + 16) < n; i += 16) {
        __m512i x = _mm512_loadu_epi32(a + i);
        x = _mm512_mul_epi32(x, c0);
        _mm512_storeu_epi32(c + i, x);
    }

    while (i < n) {
        c[i] = a[i] * b;
        i += 1;
    }
}

static void BM_auto_simd(benchmark::State& state) {
    size_t n = state.range(0);
    auto a = create_random_vector(n, 10);
    auto b = create_random_vector(n, 20);
    auto c = create_random_vector(n, 30);
    std::vector<int32_t> d(n);

    for (auto _ : state) {
        state.PauseTiming();
        d.assign(n, 0);
        state.ResumeTiming();
        auto_simd(a.data(), b.data(), c.data(), d.data(), n);
    }
}

static void BM_fusion_simd(benchmark::State& state) {
    size_t n = state.range(0);
    auto a = create_random_vector(n, 10);
    auto b = create_random_vector(n, 20);
    auto c = create_random_vector(n, 30);
    std::vector<int32_t> d(n);

    for (auto _ : state) {
        state.PauseTiming();
        d.assign(n, 0);
        state.ResumeTiming();
        fusion_simd(a.data(), b.data(), c.data(), d.data(), n);
    }
}

static void BM_compose_simd(benchmark::State& state) {
    size_t n = state.range(0);
    auto a = create_random_vector(n, 10);
    auto b = create_random_vector(n, 20);
    auto c = create_random_vector(n, 30);
    std::vector<int32_t> d(n);

    for (auto _ : state) {
        state.PauseTiming();
        d.assign(n, 0);
        std::vector<int32_t> t0(n), t1(n), t2(n), t3(n), t4(n);
        state.ResumeTiming();
        simd_mul(a.data(), 3, t0.data(), n);
        simd_mul(b.data(), 4, t1.data(), n);
        simd_mul(c.data(), 5, t2.data(), n);
        simd_add(t0.data(), t1.data(), t3.data(), n);
        simd_add(t2.data(), t3.data(), d.data(), n);
    }
}

static const int N0 = 4096;
static const int N1 = 40960;
static const int N2 = 409600;

BENCHMARK(BM_auto_simd)->Arg(N0)->Arg(N1)->Arg(N2);
BENCHMARK(BM_fusion_simd)->Arg(N0)->Arg(N1)->Arg(N2);
BENCHMARK(BM_compose_simd)->Arg(N0)->Arg(N1)->Arg(N2);

BENCHMARK_MAIN();
```

**输出如下：**

```
-----------------------------------------------------------------
Benchmark                       Time             CPU   Iterations
-----------------------------------------------------------------
BM_auto_simd/4096            1788 ns         1806 ns       387113
BM_auto_simd/40960          13218 ns        13219 ns        53342
BM_auto_simd/409600        262020 ns       262027 ns         2667
BM_fusion_simd/4096          1637 ns         1662 ns       421221
BM_fusion_simd/40960        11190 ns        11184 ns        62686
BM_fusion_simd/409600      266659 ns       266668 ns         2614
BM_compose_simd/4096         4094 ns         4097 ns       171206
BM_compose_simd/40960       45822 ns        45874 ns        15676
BM_compose_simd/409600    1395080 ns      1394972 ns          517
```

可以发现，`BM_auto_simd`与`BM_fusion_simd`性能相当，且明显优于`BM_compose_simd`，这是因为`BM_compose_simd`有物化操作，需要保存全量的中间结果，而`BM_fusion_simd`只需要保留`simd`指令长度大小的中间结果

## 3.5 cache line size

对比不同的数据宽度对于向量化的影响

```cpp
#include <benchmark/benchmark.h>

#include <iostream>
#include <random>

static const int SIZE = 1024;

static std::default_random_engine e;
static std::uniform_int_distribution<int> u(0, 1);

template <size_t size>
struct Obj {
    int data[size];
};

template <size_t size>
void init(Obj<size>& obj) {
    obj.data[0] = u(e);
}

#define BENCHMARK_OBJ_WITH_SIZE(size)                     \
    static void BM_size_##size(benchmark::State& state) { \
        Obj<size> objs[SIZE];                             \
        for (auto& obj : objs) {                          \
            init(obj);                                    \
        }                                                 \
        int sum = 0;                                      \
        for (auto _ : state) {                            \
            for (auto& obj : objs) {                      \
                sum += obj.data[0];                       \
            }                                             \
            benchmark::DoNotOptimize(sum);                \
        }                                                 \
    }                                                     \
    BENCHMARK(BM_size_##size);

BENCHMARK_OBJ_WITH_SIZE(1);
BENCHMARK_OBJ_WITH_SIZE(2);
BENCHMARK_OBJ_WITH_SIZE(4);
BENCHMARK_OBJ_WITH_SIZE(8);
BENCHMARK_OBJ_WITH_SIZE(16);
BENCHMARK_OBJ_WITH_SIZE(32);
BENCHMARK_OBJ_WITH_SIZE(64);
BENCHMARK_OBJ_WITH_SIZE(128);
BENCHMARK_OBJ_WITH_SIZE(256);

BENCHMARK_MAIN();
```

编译参数为：`-O3 -Wall -fopt-info-vec -mavx512f`。编译输出信息如下：

```
[ 50%] Building CXX object CMakeFiles/benchmark_demo.dir/main.cpp.o
/home/disk3/hcf/cpp/benchmark/main.cpp:38:1: optimized: loop vectorized using 64 byte vectors
/home/disk3/hcf/cpp/benchmark/main.cpp:39:1: optimized: loop vectorized using 64 byte vectors
/home/disk3/hcf/cpp/benchmark/main.cpp:40:1: optimized: loop vectorized using 64 byte vectors
/home/disk3/hcf/cpp/benchmark/main.cpp:41:1: optimized: loop vectorized using 64 byte vectors
/home/disk3/hcf/cpp/benchmark/main.cpp:38:1: optimized: basic block part vectorized using 64 byte vectors
[100%] Linking CXX executable benchmark_demo
[100%] Built target benchmark_demo
```

我们可以看到`size=1/2/4/8`时会进行向量化的优化，而当`size=16/32/64/128/256`时，无法进行向量化的优化。因为测试机器的`CACHE_LINE_SIZE=64Byte`，对于`size=1/2/4/8`时，对应的`Obj`对象的大小是`4/8/16/32`，一次`load`操作可以加载2个以上的对象；而对于`size=16/32/64/128/256`时，对应的`Obj`对象的大小是`64/128/256/512/1024`，一次`load`操作无法加载更多的数据时，向量化就无法获得增益了，因此编译器不再使用向量化

**输出如下：**

```
------------------------------------------------------
Benchmark            Time             CPU   Iterations
------------------------------------------------------
BM_size_1         44.7 ns         44.7 ns     15662513
BM_size_2         31.4 ns         31.4 ns     22260941
BM_size_4         67.9 ns         67.9 ns     10305525
BM_size_8          157 ns          157 ns      4468198
BM_size_16         443 ns          443 ns      1580283
BM_size_32         535 ns          535 ns      1366307
BM_size_64         752 ns          752 ns       947927
BM_size_128        695 ns          695 ns      1007176
BM_size_256       1305 ns         1305 ns       538811
```

## 3.6 data alignment

```cpp
#include <benchmark/benchmark.h>

// In my env, size of L1 is 32768 and the maximum alignment is 256,
// so in order to keep all the data in the L1, the maximum array len
// must be less than 32768 / 256 = 128, and be conservative, I choose 64
#define ARRAY_LEN 64

#define BENCHMARK_WITH_ALIGN(SIZE)                                  \
    struct Foo_##SIZE {                                             \
        int v;                                                      \
    } __attribute__((aligned(SIZE)));                               \
    Foo_##SIZE foo_##SIZE[ARRAY_LEN];                               \
    static void BM_foo_with_align_##SIZE(benchmark::State& state) { \
        for (auto _ : state) {                                      \
            int sum = 0;                                            \
            for (auto& foo : foo_##SIZE) {                          \
                sum += foo.v;                                       \
            }                                                       \
            benchmark::DoNotOptimize(sum);                          \
        }                                                           \
    }                                                               \
    BENCHMARK(BM_foo_with_align_##SIZE)

BENCHMARK_WITH_ALIGN(1);
BENCHMARK_WITH_ALIGN(2);
BENCHMARK_WITH_ALIGN(4);
BENCHMARK_WITH_ALIGN(8);
BENCHMARK_WITH_ALIGN(16);
BENCHMARK_WITH_ALIGN(32);
BENCHMARK_WITH_ALIGN(64);
BENCHMARK_WITH_ALIGN(128);
BENCHMARK_WITH_ALIGN(256);

BENCHMARK_MAIN();
```

**输出如下：**

```
----------------------------------------------------------------
Benchmark                      Time             CPU   Iterations
----------------------------------------------------------------
BM_foo_with_align_1         2.18 ns         2.17 ns    322062971
BM_foo_with_align_2         2.17 ns         2.17 ns    322256756
BM_foo_with_align_4         2.17 ns         2.17 ns    324490230
BM_foo_with_align_8         3.14 ns         3.14 ns    222560332
BM_foo_with_align_16        5.55 ns         5.55 ns    126288497
BM_foo_with_align_32        11.1 ns         11.1 ns     63154730
BM_foo_with_align_64        23.6 ns         23.6 ns     25750233
BM_foo_with_align_128       23.5 ns         23.5 ns     29785503
BM_foo_with_align_256       23.5 ns         23.5 ns     29786540
```

## 3.7 Reference

* [Auto-vectorization in GCC](https://gcc.gnu.org/projects/tree-ssa/vectorization.html)
* [Type-Based Alias Analysis](https://www.drdobbs.com/cpp/type-based-alias-analysis/184404273)

# 4 cache

缓存局部性对于程序的性能起着至关重要的作用，下面我们探究当`L1`、`L2`、`L3`分别无法命中时，程序的性能的变化规律

* 每次循环时，读取的数据，其内存间隔是`CACHE_LINESIZE`，这样能避免一个`cache`包含多个数据

## 4.1 cache miss

```cpp
#include <benchmark/benchmark.h>

#include <iostream>
#include <random>

// You can get these cache info by `getconf -a | grep -i cache`
constexpr size_t CACHE_LINESIZE = 64;
constexpr size_t LEVEL1_DCACHE_SIZE = 32768;
constexpr size_t LEVEL2_CACHE_SIZE = 1048576;
constexpr size_t LEVEL3_CACHE_SIZE = 37486592;

// Suppose that 90% of capacity of cache is used by this program
constexpr double FACTOR = 0.9;

constexpr size_t MAX_ARRAY_SIZE_L1 = FACTOR * LEVEL1_DCACHE_SIZE / CACHE_LINESIZE;
constexpr size_t MAX_ARRAY_SIZE_L2 = FACTOR * LEVEL2_CACHE_SIZE / CACHE_LINESIZE;
constexpr size_t MAX_ARRAY_SIZE_L3 = FACTOR * LEVEL3_CACHE_SIZE / CACHE_LINESIZE;
constexpr size_t MAX_ARRAY_SIZE_MEMORY = LEVEL3_CACHE_SIZE * 16 / CACHE_LINESIZE;

constexpr const size_t ITERATOR_TIMES =
        std::max(MAX_ARRAY_SIZE_L1, std::max(MAX_ARRAY_SIZE_L2, std::max(MAX_ARRAY_SIZE_L3, MAX_ARRAY_SIZE_MEMORY)));

// Size of Item equals to CACHE_LINESIZE
struct Item {
    int value;

private:
    int pad[CACHE_LINESIZE / 4 - 1];
};

static_assert(sizeof(Item) == CACHE_LINESIZE, "Item size is not equals to CACHE_LINESIZE");

template <size_t size>
struct Obj {
    Item data[size];
};

static Obj<MAX_ARRAY_SIZE_L1> obj_L1;
static Obj<MAX_ARRAY_SIZE_L2> obj_L2;
static Obj<MAX_ARRAY_SIZE_L3> obj_L3;
static Obj<MAX_ARRAY_SIZE_MEMORY> obj_MEMORY;

template <size_t size>
void init(Obj<size>& obj) {
    static std::default_random_engine e;
    static std::uniform_int_distribution<int> u(0, 1);
    for (size_t i = 0; i < size; ++i) {
        obj.data[i].value = u(e);
    }
}

#define BM_cache(level)                               \
    static void BM_##level(benchmark::State& state) { \
        init(obj_##level);                            \
        int sum = 0;                                  \
        for (auto _ : state) {                        \
            int count = ITERATOR_TIMES;               \
            size_t i = 0;                             \
            while (count-- > 0) {                     \
                sum += obj_##level.data[i].value;     \
                i++;                                  \
                if (i >= MAX_ARRAY_SIZE_##level) {    \
                    i = 0;                            \
                }                                     \
                benchmark::DoNotOptimize(sum);        \
            }                                         \
        }                                             \
    }                                                 \
    BENCHMARK(BM_##level);

BM_cache(L1);
BM_cache(L2);
BM_cache(L3);
BM_cache(MEMORY);

BENCHMARK_MAIN();
```

**输出如下：**

```
-----------------------------------------------------
Benchmark           Time             CPU   Iterations
-----------------------------------------------------
BM_L1         9580669 ns      9579618 ns           73
BM_L2        10879559 ns     10878353 ns           64
BM_L3        29881167 ns     29878105 ns           22
BM_MEMORY    71274681 ns     71265860 ns           12
```

**用如下指令，分别运行每个case（`--benchmark_filter=<case_name>`），并统计`cache`的相关信息。注意，一定要分别运行，否则没法统计对应case的`cache`信息**

```sh
perf stat -e cycles,instructions,cache-references,cache-misses,LLC-loads,LLC-load-misses,L1-dcache-loads,L1-dcache-load-misses,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,mem_load_retired.l3_hit,mem_load_retired.l3_miss ./benchmark_demo --benchmark_filter=BM_L1$

perf stat -e cycles,instructions,cache-references,cache-misses,LLC-loads,LLC-load-misses,L1-dcache-loads,L1-dcache-load-misses,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,mem_load_retired.l3_hit,mem_load_retired.l3_miss ./benchmark_demo --benchmark_filter=BM_L2$

perf stat -e cycles,instructions,cache-references,cache-misses,LLC-loads,LLC-load-misses,L1-dcache-loads,L1-dcache-load-misses,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,mem_load_retired.l3_hit,mem_load_retired.l3_miss ./benchmark_demo --benchmark_filter=BM_L3$

perf stat -e cycles,instructions,cache-references,cache-misses,LLC-loads,LLC-load-misses,L1-dcache-loads,L1-dcache-load-misses,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,mem_load_retired.l3_hit,mem_load_retired.l3_miss ./benchmark_demo --benchmark_filter=BM_MEMORY$
```

| case | cycles | instructions | cache-references | cache-misses | LLC-loads | LLC-load-misses | L1-dcache-loads | L1-dcache-load-misses | mem_load_retired.l1_hit | mem_load_retired.l1_miss | mem_load_retired.l2_hit | mem_load_retired.l2_miss | mem_load_retired.l3_hit | mem_load_retired.l3_miss |
|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|:--|
| BM_L1 | 2,580,899,770 | 6,316,558,424 | 67,075 | 54,708 | 19,069 | 14,247 | 783,076,486 | 1,281,746 | 787,627,200 | 1,153,236 | 1,142,573 | 53 | 42 | 4 |
| BM_L2 | 2,644,677,790 | 5,270,199,361 | 149,121,104 | 58,763 | 114,711,770 | 12,800 | 654,805,999 | 654,277,742 | 10,215,078 | 635,440,716 | 520,463,254 | 116,147,170 | 116,264,593 | 27,948 |
| BM_L3 | 3,488,153,900 | 2,586,195,616 | 316,924,200 | 56,031,272 | 145,189,756 | 46,160,920 | 328,373,676 | 324,813,866 | 11,230,993 | 295,707,789 | 147,271,877 | 144,866,927 | 99,777,364 | 43,817,659 |
| BM_MEMORY | 3,488,254,228 | 1,566,040,554 | 129,917,307 | 129,303,556 | 76,093,050 | 76,158,704 | 143,625,462 | 133,384,322 | 21,427,515 | 119,363,616 | 41,484,680 | 77,617,805 | 206,262 | 76,375,636 |

**可以发现：**

* `BM_L1`：由于循环所需的数据正好能存放在`L1`中，所以`L1`的命中率非常高，且`L2`和`L3`的`miss`率很低
* `BM_L2`：由于循环所需的数据无法全部放在`L1`中，所以`L1`的`miss`率非常高。但同时，数据能全部放在`L2`中，所以`L2`的命中率非常高，`L3`的`miss`率很低
* `BM_L3`：由于循环所需的数据无法全部放在`L2`中，所以`L1`和`L2`的`miss`率非常高。但同时，数据能全部放在`L3`中，所以`L3`的命中率较高
* `BM_MEMORY`：由于循环所需的数据无法全部放在`L3`中，所以`L1`、`L2`、`L3`的`miss`率都较高

## 4.2 prefetch

**内置函数`__builtin_prefetch(const void* addr, [rw], [locality])`用于将可能在将来被访问的数据提前加载到缓存中来，以提高命中率**

* **`rw`：可选参数，编译期常量，可选值`0`或`1`。`0`（默认值）表示预取的数据用于`read`。`1`表示预取的数据用于`write`**
* **`locality`：可选参数，编译期常量，可选值`0`、`1`、`2`、`3`。其中`0`表示数据没有局部性，在数据访问后无需放在cache的左边。`3`（默认值）表示数据具有很高的局部性，尽可能将数据放在cache的左边。`1`和`2`介于两者之间**

```cpp
#include <benchmark/benchmark.h>

#define LEN 10000

int64_t binary_search_without_prefetch(int64_t* nums, int64_t len, int64_t target) {
    int64_t left = 0, right = len - 1;

    while (left < right) {
        int64_t mid = (left + right) >> 1;

        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return nums[left] == target ? left : -1;
}

int64_t binary_search_with_prefetch_locality_0(int64_t* nums, int64_t len, int64_t target) {
    int64_t left = 0, right = len - 1;

    while (left < right) {
        int64_t mid = (left + right) >> 1;

        {
            // left part
            int64_t next_left = left, next_right = mid;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 0);
        }

        {
            // right part
            int64_t next_left = mid + 1, next_right = right;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 0);
        }

        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return nums[left] == target ? left : -1;
}

int64_t binary_search_with_prefetch_locality_1(int64_t* nums, int64_t len, int64_t target) {
    int64_t left = 0, right = len - 1;

    while (left < right) {
        int64_t mid = (left + right) >> 1;

        {
            // left part
            int64_t next_left = left, next_right = mid;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 1);
        }

        {
            // right part
            int64_t next_left = mid + 1, next_right = right;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 1);
        }

        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return nums[left] == target ? left : -1;
}

int64_t binary_search_with_prefetch_locality_2(int64_t* nums, int64_t len, int64_t target) {
    int64_t left = 0, right = len - 1;

    while (left < right) {
        int64_t mid = (left + right) >> 1;

        {
            // left part
            int64_t next_left = left, next_right = mid;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 2);
        }

        {
            // right part
            int64_t next_left = mid + 1, next_right = right;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 2);
        }

        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return nums[left] == target ? left : -1;
}

int64_t binary_search_with_prefetch_locality_3(int64_t* nums, int64_t len, int64_t target) {
    int64_t left = 0, right = len - 1;

    while (left < right) {
        int64_t mid = (left + right) >> 1;

        {
            // left part
            int64_t next_left = left, next_right = mid;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 3);
        }

        {
            // right part
            int64_t next_left = mid + 1, next_right = right;
            int64_t next_mid = (next_left + next_right) >> 1;
            __builtin_prefetch(&nums[next_mid], 0, 3);
        }

        if (nums[mid] == target) {
            return mid;
        } else if (nums[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }

    return nums[left] == target ? left : -1;
}

int64_t nums[LEN];
bool is_nums_init = false;

void init_nums() {
    if (is_nums_init) {
        return;
    }

    for (size_t i = 0; i < LEN; ++i) {
        nums[i] = i;
    }

    is_nums_init = true;
}

static void BM_binary_search_without_prefetch(benchmark::State& state) {
    init_nums();

    for (auto _ : state) {
        for (size_t i = 0; i < LEN; ++i) {
            benchmark::DoNotOptimize(binary_search_without_prefetch(nums, LEN, nums[i]));
        }
    }
}

static void BM_binary_search_with_prefetch_locality_0(benchmark::State& state) {
    init_nums();

    for (auto _ : state) {
        for (size_t i = 0; i < LEN; ++i) {
            benchmark::DoNotOptimize(binary_search_with_prefetch_locality_0(nums, LEN, nums[i]));
        }
    }
}

static void BM_binary_search_with_prefetch_locality_1(benchmark::State& state) {
    init_nums();

    for (auto _ : state) {
        for (size_t i = 0; i < LEN; ++i) {
            benchmark::DoNotOptimize(binary_search_with_prefetch_locality_1(nums, LEN, nums[i]));
        }
    }
}

static void BM_binary_search_with_prefetch_locality_2(benchmark::State& state) {
    init_nums();

    for (auto _ : state) {
        for (size_t i = 0; i < LEN; ++i) {
            benchmark::DoNotOptimize(binary_search_with_prefetch_locality_2(nums, LEN, nums[i]));
        }
    }
}

static void BM_binary_search_with_prefetch_locality_3(benchmark::State& state) {
    init_nums();

    for (auto _ : state) {
        for (size_t i = 0; i < LEN; ++i) {
            benchmark::DoNotOptimize(binary_search_with_prefetch_locality_3(nums, LEN, nums[i]));
        }
    }
}

BENCHMARK(BM_binary_search_without_prefetch);
BENCHMARK(BM_binary_search_with_prefetch_locality_0);
BENCHMARK(BM_binary_search_with_prefetch_locality_1);
BENCHMARK(BM_binary_search_with_prefetch_locality_2);
BENCHMARK(BM_binary_search_with_prefetch_locality_3);

BENCHMARK_MAIN();
```

**输出如下：**

```
------------------------------------------------------------------------------------
Benchmark                                          Time             CPU   Iterations
------------------------------------------------------------------------------------
BM_binary_search_without_prefetch             402491 ns       402450 ns         1737
BM_binary_search_with_prefetch_locality_0     281033 ns       281001 ns         2440
BM_binary_search_with_prefetch_locality_1     273952 ns       273921 ns         2558
BM_binary_search_with_prefetch_locality_2     274237 ns       274204 ns         2557
BM_binary_search_with_prefetch_locality_3     272844 ns       272819 ns         2560
```

## 4.3 branch prediction

分支预测的成功率对于执行效率的影响非常大，对于如下代码

```cpp
    for (auto i = 0; i < SIZE; i++) {
        if (data[i] > 128) {
            sum += data[i];
        }
    }
```

如果条件`data[i] > 128`恒成立，即分支预测的正确率为100%，其效率等效于

```cpp
    for (auto i = 0; i < SIZE; i++) {
        sum += data[i];
    }
```

若分支预测正确率较低，那么CPU流水线会产生非常多的停顿，导致整体的CPI下降

**注意，优化参数为`-O0`，否则经过编译器优化之后，性能相差不大**

```cpp
#include <benchmark/benchmark.h>

#include <algorithm>
#include <iostream>
#include <random>

const constexpr int32_t SIZE = 32768;

bool is_init = false;
int32_t unsorted_array[SIZE];
int32_t sorted_array[SIZE];

void init() {
    if (is_init) {
        return;
    }
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u(0, 256);
    for (auto i = 0; i < SIZE; i++) {
        int32_t value = u(e);
        unsorted_array[i] = value;
        sorted_array[i] = value;
    }

    std::sort(sorted_array, sorted_array + SIZE);
}

void traverse_unsorted_array(int32_t& sum) {
    for (auto i = 0; i < SIZE; i++) {
        if (unsorted_array[i] > 128) {
            sum += unsorted_array[i];
        }
    }
}

void traverse_sorted_array(int32_t& sum) {
    for (auto i = 0; i < SIZE; i++) {
        if (sorted_array[i] > 128) {
            sum += sorted_array[i];
        }
    }
}

void traverse_unsorted_array_branchless(int32_t& sum) {
    for (auto i = 0; i < SIZE; i++) {
        int32_t tmp = (unsorted_array[i] - 128) >> 31;
        sum += ~tmp & unsorted_array[i];
    }
}

void traverse_sorted_array_branchless(int32_t& sum) {
    for (auto i = 0; i < SIZE; i++) {
        int32_t tmp = (sorted_array[i] - 128) >> 31;
        sum += ~tmp & sorted_array[i];
    }
}

static void BM_traverse_unsorted_array(benchmark::State& state) {
    init();
    int32_t sum = 0;

    for (auto _ : state) {
        traverse_unsorted_array(sum);
    }

    benchmark::DoNotOptimize(sum);
}

static void BM_traverse_sorted_array(benchmark::State& state) {
    init();
    int32_t sum = 0;

    for (auto _ : state) {
        traverse_sorted_array(sum);
    }

    benchmark::DoNotOptimize(sum);
}

static void BM_traverse_unsorted_array_branchless(benchmark::State& state) {
    init();
    int32_t sum = 0;

    for (auto _ : state) {
        traverse_unsorted_array_branchless(sum);
    }

    benchmark::DoNotOptimize(sum);
}

static void BM_traverse_sorted_array_branchless(benchmark::State& state) {
    init();
    int32_t sum = 0;

    for (auto _ : state) {
        traverse_sorted_array_branchless(sum);
    }

    benchmark::DoNotOptimize(sum);
}

BENCHMARK(BM_traverse_unsorted_array);
BENCHMARK(BM_traverse_sorted_array);
BENCHMARK(BM_traverse_unsorted_array_branchless);
BENCHMARK(BM_traverse_sorted_array_branchless);

BENCHMARK_MAIN();
```

**输出如下：**

```
--------------------------------------------------------------------------------
Benchmark                                      Time             CPU   Iterations
--------------------------------------------------------------------------------
BM_traverse_unsorted_array                229909 ns       229886 ns         3046
BM_traverse_sorted_array                   87657 ns        87648 ns         7977
BM_traverse_unsorted_array_branchless      81263 ns        81253 ns         8604
BM_traverse_sorted_array_branchless        81282 ns        81274 ns         8620
```

## 4.4 branch elimination

我们可以通过一些技术手段消除特定类型的分支

**我们知道，整型在计算机中是用补码表示的，由补码的性质可以推导出一些恒等式**

```cpp
-x = ~x + 1
~x = x ^ -1
x = x & -1
```

**三元表达式恒等变形，其中，`C`为条件，`X`和`Y`均为整型表达式**

* `C ? X : Y`等价于`Y - (C ? (Y - X): 0))`
* 借助位运算，`Y - (C ? (Y - X): 0))`又可进一步简化为`Y - ((true / false) & (Y - X))`，其中
    * `true`对应的值为`-1`，`-1`的补码为`1111...1`，任何数与`-1`进行与运算都恒等于该数本身
    * `false`对应的值为`0`，`0`的补码为`000...0`，任何数与`0`进行与运算都恒等于0

**整型相等性判断**。例如`x == y`，等价于`x - y == 0`

1. 首先判断`x - y`的正负性，即符号位，若为`1`，则说明`x < y`，判断结束
1. 若`x - y`的符号位为`0`，则说明`x >= y`
1. 进一步判断`x - y - 1`的符号位，若符号位为`1`，则说明`x - y < 1`，于是`x == y`成立
1. 若`x - y - 1`的符号位为`0`，则说明`x >= y + 1`
* **简单来说，就是判断`x - y`、`x - y - 1`这两个表达式的符号位，将这两个符号位进行异或运算，当结果为`1`时，`x == y`成立**
    * `(0, 0)`：`0 ^ 0 = 0` ==> `x > y`
    * `(0, 1)`：`0 ^ 1 = 1` ==> `x == y `
    * `(1, 0)`：这种符号位结果不可能，因为`x < y`和`x >= y + 1`是矛盾的
    * `(1, 1)`：`1 ^ 1 = 1` ==> `x < y`
* **符号为计算公式如下：**
    * `(exp >> (bit_wides - 1)) & 1`

```cpp
#include <benchmark/benchmark.h>

#include <iostream>
#include <random>

static const int SIZE = 16384;

static int data[SIZE];
static std::default_random_engine e;
static std::uniform_int_distribution<int> u(0, 1);

void fill(int* data) {
    for (int i = 0; i < SIZE; ++i) {
        data[i] = u(e);
    }
}

void count_eq(int* data, int* eq_times, int target) {
    for (int i = 0; i < SIZE; ++i) {
        if (data[i] == target) {
            (*eq_times)++;
        }
    }
}

void count_ge(int* data, int* eq_times, int target) {
    for (int i = 0; i < SIZE; ++i) {
        if (data[i] >= target) {
            (*eq_times)++;
        }
    }
}

void count_eq_branch_elimination(int* data, int* eq_times, int target) {
    for (int i = 0; i < SIZE; ++i) {
        int diff = data[i] - target;
        int diff_minus_1 = diff - 1;
        int sign_diff = (diff >> 31) & 1;
        int sign_diff_minus_1 = (diff_minus_1 >> 31) & 1;
        int sign_xor = sign_diff ^ sign_diff_minus_1;
        *eq_times += (-sign_xor) & 1;
    }
}

void count_ge_branch_elimination(int* data, int* eq_times, int target) {
    for (int i = 0; i < SIZE; ++i) {
        int diff = data[i] - target;
        int sign_diff = (diff >> 31) & 1;
        *eq_times += (sign_diff - 1) & 1;
    }
}

static void BM_count_eq(benchmark::State& state) {
    int eq_times = 0;
    fill(data);
    for (auto _ : state) {
        count_eq(data, &eq_times, 1);
        benchmark::DoNotOptimize(eq_times);
    }
}

static void BM_count_eq_branch_elimination(benchmark::State& state) {
    int eq_times = 0;
    fill(data);
    for (auto _ : state) {
        count_eq_branch_elimination(data, &eq_times, 1);
        benchmark::DoNotOptimize(eq_times);
    }
}

static void BM_count_ge(benchmark::State& state) {
    int eq_times = 0;
    fill(data);
    for (auto _ : state) {
        count_ge(data, &eq_times, 1);
        benchmark::DoNotOptimize(eq_times);
    }
}

static void BM_count_ge_branch_elimination(benchmark::State& state) {
    int eq_times = 0;
    fill(data);
    for (auto _ : state) {
        count_ge_branch_elimination(data, &eq_times, 1);
        benchmark::DoNotOptimize(eq_times);
    }
}

BENCHMARK(BM_count_eq);
BENCHMARK(BM_count_eq_branch_elimination);
BENCHMARK(BM_count_ge);
BENCHMARK(BM_count_ge_branch_elimination);

BENCHMARK_MAIN();
```

**优化级别为`-O0`时，输出如下：**

```
-------------------------------------------------------------------------
Benchmark                               Time             CPU   Iterations
-------------------------------------------------------------------------
BM_count_eq                        117660 ns       117645 ns         5952
BM_count_eq_branch_elimination      72826 ns        72816 ns         9400
BM_count_ge                        113074 ns       113063 ns         6123
BM_count_ge_branch_elimination      53712 ns        53702 ns        15270
```

**优化级别为`-O1`时，输出如下：**

```
-------------------------------------------------------------------------
Benchmark                               Time             CPU   Iterations
-------------------------------------------------------------------------
BM_count_eq                         69159 ns        68591 ns        10194
BM_count_eq_branch_elimination      28016 ns        28014 ns        24993
BM_count_ge                         70391 ns        70287 ns        10186
BM_count_ge_branch_elimination      27706 ns        27701 ns        25078
```

**优化级别为`-O2`时，输出如下：**

```
-------------------------------------------------------------------------
Benchmark                               Time             CPU   Iterations
-------------------------------------------------------------------------
BM_count_eq                         12175 ns        12174 ns        63584
BM_count_eq_branch_elimination      15399 ns        15397 ns        51654
BM_count_ge                         13201 ns        13200 ns        48040
BM_count_ge_branch_elimination      12381 ns        12380 ns        50465
```

可以看到，在优化级别为`-O0`和`-O1`时，手动编写的分支消除逻辑可以提高执行效率。当优化级别为`-O2`及以上时，手动编写的分支消除逻辑的性能比不上编译器优化

## 4.5 false sharing

2个线程，独自修改一个变量，逻辑上互不干扰，但如果这两个变量的地址比较接近，位于一个cacheline中，那么会导致cache频繁失效，性能急剧下降

```cpp
#include <atomic>
#include <chrono>
#include <iostream>
#include <thread>

constexpr int32_t TIMES = 10000000;
constexpr int32_t CACHE_LINE_SIZE = 64;
alignas(64) std::atomic<int8_t> atoms[128];

static_assert(sizeof(atoms) > CACHE_LINE_SIZE, "atoms smaller than cache line");

template <int32_t distance>
void test_false_sharing() {
    auto start = std::chrono::steady_clock::now();

    std::thread t1([]() {
        int32_t cnt = 0;
        while (++cnt <= TIMES) {
            atoms[0]++;
        }
    });
    std::thread t2([]() {
        int32_t cnt = 0;
        while (++cnt <= TIMES) {
            atoms[distance]++;
        }
    });

    t1.join();
    t2.join();

    auto end = std::chrono::steady_clock::now();
    std::cout << "distinct=" << distance
              << ", time=" << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << "ms"
              << std::endl;
}

int main(int argc, char* argv[]) {
    test_false_sharing<1>();
    test_false_sharing<2>();
    test_false_sharing<4>();
    test_false_sharing<8>();
    test_false_sharing<16>();
    test_false_sharing<32>();
    test_false_sharing<63>();
    test_false_sharing<64>();
    return 0;
}
```

**输出如下：**

```
distinct=1, time=267ms
distinct=2, time=279ms
distinct=4, time=294ms
distinct=8, time=271ms
distinct=16, time=316ms
distinct=32, time=297ms
distinct=63, time=277ms
distinct=64, time=56ms
```

## 4.6 Reference

* [Other Built-in Functions Provided by GCC](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)
* [Branch-aware programming](https://stackoverflow.com/questions/32581644/branch-aware-programming)
* [Why is processing a sorted array faster than processing an unsorted array?](https://stackoverflow.com/questions/11227809/why-is-processing-a-sorted-array-faster-than-processing-an-unsorted-array)
* [程序的分支消除](https://leetcode.cn/circle/article/GSJ5XS/)
* [只会写 if 的菜炸了，手动分支消除，带你装〇带你飞！](https://www.bilibili.com/video/BV1L7411f7g3?t=2&p=2)

# 5 Tools

## 5.1 Test Cache Performance

Please refer to [cache miss](#41-cache-miss)

## 5.2 Test Cpu Performance

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

        /*
         * !!! Please use `-O0` to compile this source file, otherwise the following loop maybe optimized out !!!
         */
        while (cnt <= 1000000000L) {
            cnt++;
        }
        auto end = std::chrono::steady_clock::now();

        std::cout << std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() << std::endl;
    }

    return 0;
}
```

# 6 Others

1. [slide window frame, vectorization agg & removable cumulative agg](https://quick-bench.com/q/y7oHsGuG9CTk-Kq5edcWtsLMjpE)
