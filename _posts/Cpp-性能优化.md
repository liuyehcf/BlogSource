---
title: Cpp-性能优化
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

```sh
# 创建源文件
cat > main.cpp << 'EOF'
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
EOF

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
# 省略其他指令（都是内敛展开的指令）
```

**结论：**

1. 对于虚函数，由于无法确认实际类型，因此无法进行函数内敛优化

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

### 1.2.1 benchmark

```cpp
#include <benchmark/benchmark.h>

#include <type_traits>

struct Base {
    virtual void op() { data += 1; }

protected:
    int data = 0;
};

struct Derive : public Base {
    virtual void op() override { data -= 1; }
};

static void BM_invoke_by_base_prt(benchmark::State& state) {
    Base* base_prt = new Derive();
    for (auto _ : state) {
        base_prt->op();
        benchmark::DoNotOptimize(base_prt);
    }
}

static void BM_invoke_by_derive_ptr(benchmark::State& state) {
    Base* base_prt = new Derive();
    Derive* derive_ptr = static_cast<Derive*>(base_prt);
    for (auto _ : state) {
        derive_ptr->op();
        benchmark::DoNotOptimize(base_prt);
    }
}

static void BM_invoke_by_derive_ref(benchmark::State& state) {
    Base* base_ptr = new Derive();
    Derive& derive_ref = static_cast<Derive&>(*base_ptr);
    for (auto _ : state) {
        derive_ref.op();
        benchmark::DoNotOptimize(base_ptr);
    }
}

static void BM_invoke_by_derive_obj_1(benchmark::State& state) {
    Base* base_ptr = new Derive();
    Derive& derive_ref = static_cast<Derive&>(*base_ptr);
    for (auto _ : state) {
        // Remove reference property
        static_cast<Derive>(derive_ref).op();
        benchmark::DoNotOptimize(base_ptr);
    }
}

static void BM_invoke_by_derive_obj_2(benchmark::State& state) {
    Base* base_ptr = new Derive();
    Derive derive_obj = *static_cast<Derive*>(base_ptr);
    for (auto _ : state) {
        derive_obj.op();
        benchmark::DoNotOptimize(base_ptr);
    }
}

BENCHMARK(BM_invoke_by_base_prt);
BENCHMARK(BM_invoke_by_derive_ptr);
BENCHMARK(BM_invoke_by_derive_ref);
BENCHMARK(BM_invoke_by_derive_obj_1);
BENCHMARK(BM_invoke_by_derive_obj_2);

BENCHMARK_MAIN();
```

**输出如下：**

```
--------------------------------------------------------------------
Benchmark                          Time             CPU   Iterations
--------------------------------------------------------------------
BM_invoke_by_base_prt           1.71 ns         1.71 ns    414362787
BM_invoke_by_derive_ptr         1.64 ns         1.64 ns    426661973
BM_invoke_by_derive_ref         1.65 ns         1.64 ns    425877401
BM_invoke_by_derive_obj_1      0.314 ns        0.314 ns   1000000000
BM_invoke_by_derive_obj_2      0.314 ns        0.314 ns   1000000000
```

可以看到，即便指针或者引用的类型已经是子类的类型了，仍然会作为虚函数进行调用。只有通过普通对象调用时，才能消除虚函数的开销

## 1.3 move smart pointer

### 1.3.1 benchmark

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

### 1.4.1 benchmark

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

### 1.5.1 benchmark

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

### 1.6.1 benchmark

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

### 1.7.1 benchmark

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

## 1.8 `std::function` or template

### 1.8.1 benchmark

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

static void BM_template(benchmark::State& state) {
    int64_t cnt = 0;

    for (auto _ : state) {
        invoke_by_template([&]() { benchmark::DoNotOptimize(cnt++); });
    }
}

BENCHMARK(BM_function);
BENCHMARK(BM_template);

BENCHMARK_MAIN();
```

**输出如下：**

```
------------------------------------------------------
Benchmark            Time             CPU   Iterations
------------------------------------------------------
BM_function       1.89 ns         1.89 ns    371459322
BM_template      0.314 ns        0.314 ns   1000000000
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

# 3 auto vectorization

## 3.1 简介

**向量化使用的特殊寄存器**

* `xmm`：128-bit
* `ymm`：256-bit
* `zmm`：512-bit

**gcc中与向量化有关的参数**

* `-fopt-info-vec`/`-fopt-info-vec-optimized`：The compiler will log which loops (by line N°) are being vector optimized.
* `-fopt-info-vec-missed`：Detailed info about loops not being vectorized, and a lot of other detailed information.
* `-fopt-info-vec-note`：Detailed info about all loops and optimizations being done.
* `-fopt-info-vec-all`：All previous options together.

## 3.2 pointer aliasing

### 3.2.1 benchmark

#### 3.2.1.1 case1

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

#### 3.2.1.2 case2

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

#### 3.2.1.3 case3

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

#### 3.2.1.4 case4

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

#### 3.2.1.5 case5

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

#### 3.2.1.6 case6: versioned for vectorization

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

### 3.3.1 benchmark

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

### 3.4.1 benchmark

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

## 3.5 参考

* [Auto-vectorization in GCC](https://gcc.gnu.org/projects/tree-ssa/vectorization.html)
* [Type-Based Alias Analysis](https://www.drdobbs.com/cpp/type-based-alias-analysis/184404273)

# 4 prefetch

**内置函数`__builtin_prefetch(const void* addr, [rw], [locality])`用于将可能在将来被访问的数据提前加载到缓存中来，以提高命中率**

* **`rw`：可选参数，编译期常量，可选值`0`或`1`。`0`（默认值）表示预取的数据用于`read`。`1`表示预取的数据用于`write`**
* **`locality`：可选参数，编译期常量，可选值`0`、`1`、`2`、`3`。其中`0`表示数据没有局部性，在数据访问后无需放在cache的左边。`3`（默认值）表示数据具有很高的局部性，尽可能将数据放在cache的左边。`1`和`2`介于两者之间**

## 4.1 benchmark

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

## 4.2 参考

* [Other Built-in Functions Provided by GCC](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)

# 5 branch prediction

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

## 5.1 benchmark

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

## 5.2 参考

* [Branch-aware programming](https://stackoverflow.com/questions/32581644/branch-aware-programming)
* [Why is processing a sorted array faster than processing an unsorted array?](https://stackoverflow.com/questions/11227809/why-is-processing-a-sorted-array-faster-than-processing-an-unsorted-array)
