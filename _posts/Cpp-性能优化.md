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

# 1 Pointer Aliasing

**`Pointer Aliasing`指的是两个指针（在作用域内）指向了同一个物理地址，或者说指向的物理地址有重叠。`__restrict`关键词用于给编译器一个提示：确保被标记的指针是独占物理地址的**

## 1.1 汇编

**下面以几个简单的例子说明`__restrict`关键词的作用，以及它是如何引导编译器进行指令优化的**

### 1.1.1 case1

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

### 1.1.2 case2

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

## 1.2 benchmark

```cpp
#include <benchmark/benchmark.h>

#define ARRAY_LEN 10000

uint32_t __attribute__((noinline)) sum_without_restrict(uint32_t* num1, uint32_t* num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

uint32_t __attribute__((noinline)) sum_with_restrict(uint32_t* __restrict num1, uint32_t* __restrict num2) {
    uint32_t res = 0;
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        *num2 = i;
        res += *num1;
    }
    return res;
}

void __attribute__((noinline)) loop_without_restrict(float* dest, float* value) {
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dest[i] += *value;
    }
}

void __attribute__((noinline)) loop_with_restrict(float* __restrict dest, float* __restrict value) {
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dest[i] += *value;
    }
}

void __attribute__((noinline)) transform_without_restrict(float* dest, float* src, float* matrix, size_t n) {
    for (size_t i = 0; i < n; ++i, src += 4, dest += 4) {
        dest[0] = src[0] * matrix[0] + src[1] * matrix[1] + src[2] * matrix[2] + src[3] * matrix[3];
        dest[1] = src[0] * matrix[4] + src[1] * matrix[5] + src[2] * matrix[6] + src[3] * matrix[7];
        dest[2] = src[0] * matrix[8] + src[1] * matrix[9] + src[2] * matrix[10] + src[3] * matrix[11];
        dest[3] = src[0] * matrix[12] + src[1] * matrix[13] + src[2] * matrix[14] + src[3] * matrix[15];
    }
}

void __attribute__((noinline))
transform_with_restrict(float* __restrict dest, float* __restrict src, float* __restrict matrix, size_t n) {
    for (size_t i = 0; i < n; ++i, src += 4, dest += 4) {
        dest[0] = src[0] * matrix[0] + src[1] * matrix[1] + src[2] * matrix[2] + src[3] * matrix[3];
        dest[1] = src[0] * matrix[4] + src[1] * matrix[5] + src[2] * matrix[6] + src[3] * matrix[7];
        dest[2] = src[0] * matrix[8] + src[1] * matrix[9] + src[2] * matrix[10] + src[3] * matrix[11];
        dest[3] = src[0] * matrix[12] + src[1] * matrix[13] + src[2] * matrix[14] + src[3] * matrix[15];
    }
}

static void BM_sum_without_restrict(benchmark::State& state) {
    uint32_t num1 = 0;
    uint32_t num2 = 0;
    for (auto _ : state) {
        ++num1;
        ++num2;
        sum_without_restrict(&num1, &num2);
    }
}

static void BM_sum_with_restrict(benchmark::State& state) {
    uint32_t num1 = 0;
    uint32_t num2 = 0;
    for (auto _ : state) {
        ++num1;
        ++num2;
        sum_with_restrict(&num1, &num2);
    }
}

static void BM_loop_without_restrict(benchmark::State& state) {
    float dstdata[ARRAY_LEN];
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dstdata[i] = 0;
    }

    float value = 0;
    for (auto _ : state) {
        value += 1.0;
        loop_without_restrict(dstdata, &value);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    float dstdata[ARRAY_LEN];
    for (size_t i = 0; i < ARRAY_LEN; ++i) {
        dstdata[i] = 0;
    }

    float value = 0;
    for (auto _ : state) {
        value += 1.0;
        loop_with_restrict(dstdata, &value);
    }
}

static void BM_transform_without_restrict(benchmark::State& state) {
    float srcdata[4 * ARRAY_LEN];
    float dstdata[4 * ARRAY_LEN];
    float matrix[16];

    for (size_t i = 0; i < 16; ++i) {
        matrix[i] = 1;
    }
    for (size_t i = 0; i < 4 * ARRAY_LEN; ++i) {
        srcdata[i] = i;
        dstdata[i] = 0;
    }
    for (auto _ : state) {
        transform_without_restrict(dstdata, srcdata, matrix, ARRAY_LEN);
    }
}

static void BM_transform_with_restrict(benchmark::State& state) {
    float srcdata[4 * ARRAY_LEN];
    float dstdata[4 * ARRAY_LEN];
    float matrix[16];

    for (size_t i = 0; i < 16; ++i) {
        matrix[i] = 1;
    }
    for (size_t i = 0; i < 4 * ARRAY_LEN; ++i) {
        srcdata[i] = i;
        dstdata[i] = 0;
    }
    for (auto _ : state) {
        transform_with_restrict(dstdata, srcdata, matrix, ARRAY_LEN);
    }
}

BENCHMARK(BM_sum_without_restrict);
BENCHMARK(BM_sum_with_restrict);

BENCHMARK(BM_loop_without_restrict);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK(BM_transform_without_restrict);
BENCHMARK(BM_transform_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
------------------------------------------------------------------------
Benchmark                              Time             CPU   Iterations
------------------------------------------------------------------------
BM_sum_without_restrict             6301 ns         6300 ns       111172
BM_sum_with_restrict                2.89 ns         2.89 ns    242847831
BM_loop_without_restrict            1106 ns         1106 ns       632797
BM_loop_with_restrict               1113 ns         1113 ns       615683
BM_transform_without_restrict      16108 ns        16106 ns        43250
BM_transform_with_restrict         15619 ns        15617 ns        44817
```

**问题：**

1. 若`sum_with_restrict`以及`sum_without_restrict`的循环长度不写死，而是传入参数，那么结果完全不同。传入参数的情况下，两个函数被优化成一样的了
1. **`loop_without_restrict`以及`loop_with_restrict`没有差异。如果把其他几组测试的代码全删除（包括待测函数、BM函数），那么结果是有差异的。不知道为啥，非常奇怪**

# 2 虚函数

## 2.1 汇编

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

## 2.2 benchmark

```cpp
#include <benchmark/benchmark.h>

class Base {
public:
    Base() = default;
    virtual ~Base() = default;
    virtual void func_virtual() {}
    void func_normal() {}

protected:
    size_t value = 0;
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

# 3 向量化

## 3.1 benchmark

```cpp
#include <benchmark/benchmark.h>

#include <vector>

#define LEN 100

class Buffer {
public:
    std::vector<size_t>& container() { return _container; }
    void append(size_t value) { _container.push_back(value); }
    size_t& sum() { return _sum; }

private:
    std::vector<size_t> _container;
    size_t _sum = 0;
};

void __attribute__((noinline)) loop_non_optimize(Buffer* buffer) {
    size_t len = buffer->container().size();
    for (size_t i = 0; i < len; ++i) {
        buffer->sum() += buffer->container()[i];
    }
}

void __attribute__((noinline)) loop_with_local_array(Buffer* buffer) {
    size_t len = buffer->container().size();
    auto* data = buffer->container().data();
    for (size_t i = 0; i < len; ++i) {
        buffer->sum() += data[i];
    }
}

void __attribute__((noinline)) loop_with_local_sum(Buffer* buffer) {
    size_t len = buffer->container().size();
    size_t local_sum = 0;
    for (size_t i = 0; i < len; ++i) {
        local_sum += buffer->container()[i];
    }
    buffer->sum() += local_sum;
}

void __attribute__((noinline)) loop_with_local_array_and_local_sum(Buffer* buffer) {
    size_t len = buffer->container().size();
    auto* data = buffer->container().data();
    size_t local_sum = 0;
    for (size_t i = 0; i < len; ++i) {
        local_sum += data[i];
    }
    buffer->sum() += local_sum;
}

void __attribute__((noinline)) loop_with_restrict(Buffer* __restrict buffer) {
    size_t len = buffer->container().size();
    for (size_t i = 0; i < len; ++i) {
        buffer->sum() += buffer->container()[i];
    }
}

static void BM_loop_non_optimize(benchmark::State& state) {
    Buffer buffer;
    for (size_t i = 0; i < LEN; ++i) {
        buffer.append(i);
    }

    for (auto _ : state) {
        loop_non_optimize(&buffer);
        benchmark::DoNotOptimize(buffer);
    }
}

static void BM_loop_with_local_array(benchmark::State& state) {
    Buffer buffer;
    for (size_t i = 0; i < LEN; ++i) {
        buffer.append(i);
    }

    for (auto _ : state) {
        loop_with_local_array(&buffer);
        benchmark::DoNotOptimize(buffer);
    }
}

static void BM_loop_with_local_sum(benchmark::State& state) {
    Buffer buffer;
    for (size_t i = 0; i < LEN; ++i) {
        buffer.append(i);
    }

    for (auto _ : state) {
        loop_with_local_sum(&buffer);
        benchmark::DoNotOptimize(buffer);
    }
}

static void BM_loop_with_local_array_and_local_sum(benchmark::State& state) {
    Buffer buffer;
    for (size_t i = 0; i < LEN; ++i) {
        buffer.append(i);
    }

    for (auto _ : state) {
        loop_with_local_array_and_local_sum(&buffer);
        benchmark::DoNotOptimize(buffer);
    }
}

static void BM_loop_with_restrict(benchmark::State& state) {
    Buffer buffer;
    for (size_t i = 0; i < LEN; ++i) {
        buffer.append(i);
    }

    for (auto _ : state) {
        loop_with_restrict(&buffer);
        benchmark::DoNotOptimize(buffer);
    }
}

BENCHMARK(BM_loop_non_optimize);
BENCHMARK(BM_loop_with_local_array);
BENCHMARK(BM_loop_with_local_sum);
BENCHMARK(BM_loop_with_local_array_and_local_sum);
BENCHMARK(BM_loop_with_restrict);

BENCHMARK_MAIN();
```

**输出如下：**

```
---------------------------------------------------------------------------------
Benchmark                                       Time             CPU   Iterations
---------------------------------------------------------------------------------
BM_loop_non_optimize                         52.3 ns         52.3 ns     13586761
BM_loop_with_local_array                     53.7 ns         53.7 ns     13387695
BM_loop_with_local_sum                       21.2 ns         21.2 ns     32628088
BM_loop_with_local_array_and_local_sum       21.2 ns         21.2 ns     33101760
BM_loop_with_restrict                        21.3 ns         21.3 ns     32676862
```

**结论：**

1. `gcc`无法对类型的成员变量进行向量化优化
1. `__restrict`与本地数组能达到相似地优化效果

## 3.2 参考

* [Auto-vectorization in GCC](https://gcc.gnu.org/projects/tree-ssa/vectorization.html)
