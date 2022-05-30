---
title: Cpp-三方库
date: 2021-09-06 10:55:52
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 boost

**如何安装：**

```sh
yum install -y boost-devel
```

## 1.1 打印堆栈

**源码如下：**

```cpp
// BOOST_STACKTRACE_USE_ADDR2LINE 用于获取行号
#define BOOST_STACKTRACE_USE_ADDR2LINE
#include <boost/stacktrace.hpp>
#include <iostream>

void foo(int cnt) {
    if (cnt == 0) {
        std::cout << boost::stacktrace::stacktrace() << std::endl;
        return;
    }
    foo(cnt - 1);
}

int main() {
    foo(5);
    return 0;
}
```

**编译执行：**

```sh
# -ldl: link libdl
# -g: 保留行号
# -DBOOST_STACKTRACE_USE_ADDR2LINE: 源码中宏的等效方式
gcc -o main main.cpp -lstdc++ -std=gnu++17 -ldl -g
./main
```

输出如下：

```
 0# boost::stacktrace::basic_stacktrace<std::allocator<boost::stacktrace::frame> >::basic_stacktrace() at xxx/stacktrace.hpp:129
 1# foo(int) at /root/main.cpp:12
 2# foo(int) at /root/main.cpp:12
 3# foo(int) at /root/main.cpp:12
 4# foo(int) at /root/main.cpp:12
 5# foo(int) at /root/main.cpp:12
 6# main at /root/main.cpp:16
 7# __libc_start_main in /lib64/libc.so.6
 8# _start in ./main
```

## 1.2 参考

* [The Boost C++ Libraries BoostBook Documentation Subset](https://www.boost.org/doc/libs/master/doc/html/)
* [How to print current call stack](https://www.boost.org/doc/libs/1_66_0/doc/html/stacktrace/getting_started.html)
* [print call stack in C or C++](https://stackoverflow.com/Questions/3899870/print-call-stack-in-c-or-c)

# 2 gtest

[github-googletest](https://github.com/google/googletest)

**安装googletest**

```sh
git clone https://github.com/google/googletest.git --depth 1
cd googletest

mkdir build
cd build

cmake ..
make
make install
```

**在`cmake`中添加`gtest`依赖**

```cmake
find_package(GTest REQUIRED)
message(STATUS "GTEST_INCLUDE_DIRS: ${GTEST_INCLUDE_DIRS}")
message(STATUS "GTEST_BOTH_LIBRARIES: ${GTEST_BOTH_LIBRARIES}")
message(STATUS "GTEST_LIBRARIES: ${GTEST_LIBRARIES}")
message(STATUS "GTEST_MAIN_LIBRARIES: ${GTEST_MAIN_LIBRARIES}")

target_link_libraries(xxx ${GTEST_LIBRARIES})
```

**完整示例**

```sh
# 编写CMakeLists.txt 
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(gtest_demo)

set(CMAKE_CXX_STANDARD 17)

set(EXEC_FILES ./test_main.cpp)

add_executable(gtest_demo ${EXEC_FILES})

find_package(GTest REQUIRED)
message(STATUS "GTEST_INCLUDE_DIRS: ${GTEST_INCLUDE_DIRS}")
message(STATUS "GTEST_BOTH_LIBRARIES: ${GTEST_BOTH_LIBRARIES}")
message(STATUS "GTEST_LIBRARIES: ${GTEST_LIBRARIES}")
message(STATUS "GTEST_MAIN_LIBRARIES: ${GTEST_MAIN_LIBRARIES}")

target_link_libraries(gtest_demo ${GTEST_LIBRARIES})
EOF

# 编写test_main.cpp
cat > test_main.cpp << 'EOF' 
#include <gtest/gtest.h>

TEST(TestDemo, case_right) {
    ASSERT_EQ(1, 1);
}

TEST(TestDemo, case_wrong) {
    ASSERT_EQ(1, 0);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
EOF

mkdir build
cd build

cmake ..
make

./gtest_demo
```

## 2.1 Tips

1. 假设编译得到的二进制是`test`，通过执行`./test --help`就可以看到所有gtest支持的参数，包括执行特定case等等

# 3 phmap

全称：`parallel-hashmap`，提供了一组高性能、并发安全的map，用于替换`std`以及`boost`中的map

[parallel-hashmap](https://github.com/greg7mdp/parallel-hashmap)

# 4 benchmark

[google-benchmark](https://github.com/google/benchmark)

**安装benchmark**

```sh
git clone https://github.com/google/benchmark.git --depth 1
cd benchmark

mkdir build
cd build

# 这里指定googletest的工程路径（不加任何参数会有提示）
cmake -DGOOGLETEST_PATH=~/googletest/ -DCMAKE_BUILD_TYPE=Release ..
make
make install
```

**在`cmake`中添加`benchmark`依赖**

```cmake
find_package(benchmark REQUIRED)

target_link_libraries(xxx benchmark::benchmark)
```

**完整示例**

```sh
# 编写CMakeLists.txt 
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(benchmark_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -fopt-info-vec")

set(EXEC_FILES ./main.cpp)

add_executable(benchmark_demo ${EXEC_FILES})

find_package(benchmark REQUIRED)

target_link_libraries(benchmark_demo benchmark::benchmark)
EOF

# 编写main.cpp
cat > main.cpp << 'EOF'
#include <string>
#include <benchmark/benchmark.h>

static void BM_StringCreation(benchmark::State& state) {
  for (auto _ : state)
    std::string empty_string;
}
// Register the function as a benchmark
BENCHMARK(BM_StringCreation);

// Define another benchmark
static void BM_StringCopy(benchmark::State& state) {
  std::string x = "hello";
  for (auto _ : state)
    std::string copy(x);
}
BENCHMARK(BM_StringCopy);

BENCHMARK_MAIN();
EOF

mkdir build
cd build

cmake ..
make

./benchmark_demo
```

**输出如下：**

* `Time`：每次迭代消耗的总时间，包括cpu时间+等待时间
* `CPU`：每次迭代真正占用cpu的时间
* `Iterations`：迭代次数

```
------------------------------------------------------------
Benchmark                  Time             CPU   Iterations
------------------------------------------------------------
BM_StringCreation       5.12 ns         5.12 ns    136772962
BM_StringCopy           21.0 ns         21.0 ns     33441350
```

## 4.1 quick-benchmark

[quick-bench（在线）](https://quick-bench.com/)

## 4.2 Tips

### 4.2.1 benchmark::DoNotOptimize

避免优化本不应该优化的代码，其源码如下：

```cpp
inline BENCHMARK_ALWAYS_INLINE void DoNotOptimize(Tp& value) {
#if defined(__clang__)
  asm volatile("" : "+r,m"(value) : : "memory");
#else
  asm volatile("" : "+m,r"(value) : : "memory");
#endif
}
```

## 4.3 参考

* [benchmark/docs/user_guide.md](https://github.com/google/benchmark/blob/main/docs/user_guide.md)
* [c++性能测试工具：google benchmark入门（一）](https://www.cnblogs.com/apocelipes/p/10348925.html)
