---
title: Cpp-Thirdparty-Library
date: 2021-09-06 10:55:52
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 GNU

## 1.1 libbacktrace

```sh
git clone https://github.com/ianlancetaylor/libbacktrace.git
cd libbacktrace

./configure CFLAGS="-fPIC"
make -j 4
sudo make install
```

```cpp
#include <backtrace-supported.h>
#include <backtrace.h>
#include <cxxabi.h>

#include <iostream>

// Callback for backtrace_full
static int callback(void* data, uintptr_t pc, const char* filename, int lineno, const char* function) {
    char* demangled = nullptr;
    int status = 0;
    if (function) {
        demangled = abi::__cxa_demangle(function, NULL, NULL, &status);
        if (demangled) {
            function = demangled;
        }
    }
    std::cout << filename << ":" << lineno << ": 0x" << std::hex << pc << " " << function << std::endl;
    free(demangled);
    // Returning 0 continues the backtrace
    return 0;
}

// Error callback
static void error_callback(void* data, const char* msg, int errnum) {
    std::cerr << "ERROR: " << msg << " (" << errnum << ")" << std::endl;
}

// Function to print the current stack trace
void print_stack_trace() {
    struct backtrace_state* state = backtrace_create_state(NULL, BACKTRACE_SUPPORTS_THREADS, error_callback, NULL);
    backtrace_full(state, 0, callback, error_callback, NULL);
}

// Sample function that calls another function to generate a stack trace
void my_function() {
    print_stack_trace();
}

int main() {
    my_function();
    return 0;
}
```

```sh
gcc -o main main.cpp -lstdc++ -std=gnu++17 -lbacktrace -g
./main
```

```
/data25/chenfeng.he/cpp/test/main.cpp:31: 0x4014d3 print_stack_trace()
/data25/chenfeng.he/cpp/test/main.cpp:24: 0x4014df my_function()
/data25/chenfeng.he/cpp/test/main.cpp:28: 0x4014eb main
../csu/libc-start.c:123: 0x7fd890a7c2e0 __libc_start_main
```

## 1.2 libunwind

[The libunwind project](https://www.nongnu.org/libunwind/index.html)

[github-libunwind](https://github.com/libunwind/libunwind)

```sh
git clone https://github.com/libunwind/libunwind.git
cd libunwind
git checkout v1.6.2

autoreconf -i
./configure
make -j 4
sudo make install
```

```cpp
#include <cxxabi.h> // Include for __cxa_demangle
#include <libunwind.h>

#include <cstdlib> // For free
#include <iostream>

void print_stack_trace() {
    unw_cursor_t cursor;
    unw_context_t context;

    // Initialize context to the current machine state.
    unw_getcontext(&context);
    unw_init_local(&cursor, &context);

    // Walk the stack up, one frame at a time.
    while (unw_step(&cursor) > 0) {
        unw_word_t offset, pc;
        char sym[256];

        if (unw_get_reg(&cursor, UNW_REG_IP, &pc)) {
            std::cout << "Error: cannot read program counter" << std::endl;
            break;
        }

        if (unw_get_proc_name(&cursor, sym, sizeof(sym), &offset) == 0) {
            int status;
            // Attempt to demangle the symbol
            char* demangled_name = abi::__cxa_demangle(sym, nullptr, nullptr, &status);

            std::cout << "0x" << std::hex << pc << ": ";

            if (status == 0 && demangled_name) {
                std::cout << demangled_name << " (+0x" << std::hex << offset << ")" << std::endl;
                free(demangled_name); // Free the demangled name
            } else {
                // If demangling failed, print the mangled name
                std::cout << sym << " (+0x" << std::hex << offset << ")" << std::endl;
            }
        } else {
            std::cout << " -- error: unable to obtain symbol name for this frame" << std::endl;
        }
    }
}

void recursive(uint16_t cnt) {
    if (cnt == 0) {
        print_stack_trace();
        return;
    }
    recursive(cnt - 1);
}

int main(int argc, char** argv) {
    recursive(10);
    return 0;
}
```

```sh
# -DUNW_LOCAL_ONLY is mandatory, otherwise some link error may occur, like:
#    undefined reference to `_Ux86_64_init_local'
#    undefined reference to `_Ux86_64_get_reg'
#    undefined reference to `_Ux86_64_get_proc_name'
#    undefined reference to `_Ux86_64_step'
gcc -o main main.cpp -lstdc++ -std=gnu++17 -lunwind -DUNW_LOCAL_ONLY
./main
```

```
0x401437: recursive(unsigned short) (+0x1a)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x40144a: recursive(unsigned short) (+0x2d)
0x401465: main (+0x19)
0x7f19ef09f2e1: __libc_start_main (+0xf1)
0x40114a: _start (+0x2a)
```

### 1.2.1 How to automatically generate a stacktrace when my program crashes

[How to automatically generate a stacktrace when my program crashes](https://stackoverflow.com/questions/77005/how-to-automatically-generate-a-stacktrace-when-my-program-crashes)

# 2 LLVM

```sh
git clone -b release/16.x https://github.com/llvm/llvm-project.git --depth 1
cd llvm-project
cmake -B build -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
    -DCMAKE_BUILD_TYPE=Release \
    -G "Ninja" \
    llvm
cmake --build build -j 64
sudo cmake --install build

ninja -C build -t targets | grep -E '^install'
```

Install specific target:

```sh
cd build
ninja -j 64 clang
ninja -j 64 clang-format
ninja -j 64 clangd
sudo ninja install-clang
sudo ninja install-clang-format
sudo ninja install-clangd
```

# 3 boost

## 3.1 Installation

### 3.1.1 Package Manager

```sh
yum install -y boost-devel
```

### 3.1.2 From Source

[Boost Downloads](https://www.boost.org/users/download/)

```sh
wget https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz
tar -zxf boost_1_84_0.tar.gz
cd boost_1_84_0

./bootstrap.sh
./b2
sudo ./b2 install
```

## 3.2 Usage

```sh
mkdir boost_demo
cd boost_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(boost_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

set(Boost_USE_STATIC_LIBS ON)
find_package(Boost REQUIRED COMPONENTS filesystem system)

target_link_libraries(${PROJECT_NAME} PRIVATE Boost::filesystem Boost::system)
EOF

cat > boost_demo.cpp << 'EOF'
#include <boost/filesystem.hpp>
#include <iostream>

int main() {
    std::string directory = "/tmp";

    try {
        // Iterate through the directory
        for (const auto& entry : boost::filesystem::directory_iterator(directory)) {
            // Print the file name
            std::cout << entry.path().filename() << std::endl;
        }
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }

    return 0;
}
EOF

cmake -B build
cmake --build build
build/boost_demo
```

## 3.3 Print Stack

Boost.Stacktrace provides several options for printing stack traces, depending on the underlying technology used to capture the stack information:

* `BOOST_STACKTRACE_USE_BACKTRACE`: uses the `backtrace` function from the GNU C Library, which is available on most UNIX-like systems including Linux.
* `BOOST_STACKTRACE_USE_ADDR2LINE`: uses the `addr2line` utility from GNU binutils to convert addresses into file names and line numbers, providing more detailed information.
* `BOOST_STACKTRACE_USE_NOOP`: doesn't capture the stack trace at all. This can be used when you want to disable stack tracing completely.
* `BOOST_STACKTRACE_USE_WINDBG`: utilizes the Windows Debug Help Library when compiling for Windows.

```cpp
#include <boost/stacktrace.hpp>
#include <boost/version.hpp>
#include <iostream>

void foo(int cnt) {
    if (cnt == 0) {
        std::cout << boost::stacktrace::stacktrace() << std::endl;
        return;
    }
    foo(cnt - 1);
}

int main() {
    std::cout << "Boost version: " << BOOST_VERSION / 100000 << "." << BOOST_VERSION / 100 % 1000 << "."
              << BOOST_VERSION % 100 << std::endl;
    foo(5);
    return 0;
}
```

### 3.3.1 With addr2line

This approach works fine with `gcc-10.3.0`, but can't work with higher versions like `gcc-11.3.0`, `gcc-12.3.0`. Don't know why so far.

**Compile:**

```sh
# -ldl: link libdl
# -g: generate debug information
gcc -o main main.cpp -DBOOST_STACKTRACE_USE_ADDR2LINE -lstdc++ -std=gnu++17 -ldl -g
./main
```

**Output:**

```
Boost version: 1.84.0
 0# _ZN5boost10stacktrace16basic_stacktraceISaINS0_5frameEEEC4Ev at /usr/local/include/boost/stacktrace/stacktrace.hpp:129
 1# foo(int) at /root/main.cpp:13
 2# foo(int) at /root/main.cpp:13
 3# foo(int) at /root/main.cpp:13
 4# foo(int) at /root/main.cpp:13
 5# foo(int) at /root/main.cpp:13
 6# main at /root/main.cpp:19
 7# __libc_start_main in /lib64/libc.so.6
 8# _start at :?
```

### 3.3.2 With libbacktrace

**Compile:**

```sh
# -ldl: link libdl
# -g: generate debug information
# -lbacktrace: link libbacktrace
gcc -o main main.cpp -DBOOST_STACKTRACE_USE_BACKTRACE -lstdc++ -std=gnu++17 -ldl -lbacktrace -g
./main
```

**Output:**

```
Boost version: 1.84.0
 0# foo(int) at /root/main.cpp:7
 1# foo(int) at /root/main.cpp:11
 2# foo(int) at /root/main.cpp:11
 3# foo(int) at /root/main.cpp:11
 4# foo(int) at /root/main.cpp:11
 5# foo(int) at /root/main.cpp:11
 6# main at /root/main.cpp:17
 7# __libc_start_main at ../csu/libc-start.c:325
 8# _start in ./main
```

## 3.4 Reference

* [The Boost C++ Libraries BoostBook Documentation Subset](https://www.boost.org/doc/libs/master/doc/html/)
* [How to print current call stack](https://www.boost.org/doc/libs/1_66_0/doc/html/stacktrace/getting_started.html)
* [print call stack in C or C++](https://stackoverflow.com/Questions/3899870/print-call-stack-in-c-or-c)

# 4 [fmt](https://github.com/fmtlib/fmt)

**安装`fmt`：**

```sh
git clone https://github.com/fmtlib/fmt.git
cd fmt

cmake -B build -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j 4
sudo cmake --install build
```

**在`cmake`中添加`fmt`依赖：**
```
find_package(fmt)

target_link_libraries(xxx fmt::fmt)
```

**示例：**

```cpp
#include <fmt/core.h>
#include <fmt/ranges.h>

#include <vector>

int main() {
    std::vector<int32_t> nums{1, 2, 3, 4, 5};
    fmt::print("Joined string: {}\n", fmt::join(nums, ","));
    return 0;
}
```

* `gcc -o main main.cpp -lstdc++ -std=gnu++17 -lfmt`

# 5 Google

## 5.1 gflag

**安装[gflag](https://github.com/gflags/gflags)：**

```sh
git clone https://github.com/gflags/gflags.git
cd gflags

cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j 4
sudo cmake --install build
```

**在`cmake`中添加`gflags`依赖：**

```cmake
find_package(gflags REQUIRED)
message(STATUS "GFLAGS_INCLUDE_DIRS: ${GFLAGS_INCLUDE_DIRS}")
message(STATUS "GFLAGS_BOTH_LIBRARIES: ${GFLAGS_BOTH_LIBRARIES}")
message(STATUS "GFLAGS_LIBRARIES: ${GFLAGS_LIBRARIES}")
message(STATUS "GFLAGS_MAIN_LIBRARIES: ${GFLAGS_MAIN_LIBRARIES}")

target_link_libraries(xxx ${GFLAGS_LIBRARIES})
```

**示例：**

```cpp
#include <gflags/gflags.h>

#include <iostream>

DEFINE_bool(test_bool, false, "test bool");
DEFINE_int32(test_int32, 5, "test int32");
DEFINE_double(test_double, 1.1, "test double");
DEFINE_string(test_str, "default str", "test str");

#define DISPLAY(name) std::cout << #name << ": " << name << std::endl

int main(int argc, char* argv[]) {
    gflags::SetUsageMessage("some message");
    gflags::SetVersionString("1.0.0");
    gflags::ParseCommandLineFlags(&argc, &argv, true);
    std::cout << gflags::CommandlineFlagsIntoString() << std::endl;
    
    DISPLAY(FLAGS_test_bool);
    DISPLAY(FLAGS_test_int32);
    DISPLAY(FLAGS_test_double);
    DISPLAY(FLAGS_test_str);

    return 0;
}
```

* `gcc -o main main.cpp -lstdc++ -std=gnu++17 -lgflags -lpthread`
* `./main --test_bool true --test_int32 100 --test_double 6.666 --test_str hello`

## 5.2 glog

**安装[glog](https://github.com/google/glog)：**

```sh
git clone https://github.com/google/glog.git
cd glog

# BUILD_SHARED_LIBS用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j 4
sudo cmake --install build
```

**在`cmake`中添加`glog`依赖：**

```cmake
find_package(GLOG)

target_link_libraries(xxx glog::glog)
```

### 5.2.1 Print Stack

[[Enhancement] wrap libc's __cxa_throw to print stack trace when throw exceptions](https://github.com/StarRocks/starrocks/pull/13410)

```cpp
#include <glog/logging.h>

#include <iostream>
#include <string>

namespace google {
namespace glog_internal_namespace_ {
void DumpStackTraceToString(std::string* stacktrace);
}
} // namespace google

std::string get_stack_trace() {
    std::string s;
    google::glog_internal_namespace_::DumpStackTraceToString(&s);
    return s;
}

#if defined(__GNUC__)
// wrap libc's _cxa_throw to print stack trace of exceptions
extern "C" {
void __real___cxa_throw(void* thrown_exception, void* infov, void (*dest)(void*));

void __wrap___cxa_throw(void* thrown_exception, void* infov, void (*dest)(void*));
}
// wrap libc's _cxa_throw that must not throw exceptions again, otherwise causing crash.
void __wrap___cxa_throw(void* thrown_exception, void* info, void (*dest)(void*)) {
    auto stack = get_stack_trace();

    std::cerr << stack << std::endl;

    // call the real __cxa_throw():
    __real___cxa_throw(thrown_exception, info, dest);
}
#endif

int main(int argc, char* argv[]) {
    try {
        throw 1;
    } catch (...) {
        std::cout << "catch exception" << std::endl;
    }
    return 0;
}
```

**编译：**

* `glog`需要使用静态库版本，因为动态库版本选择隐藏`DumpStackTraceToString`这个符号（`readelf -s --wide /usr/lib64/libglog.so.0.7.0 | rg DumpStackTraceToString`）

```sh
gcc -o main main.cpp -Wl,-wrap=__cxa_throw -lstdc++ -std=gnu++17 -Wl,-Bstatic -lglog -lgflags -Wl,-Bdynamic -lunwind -lpthread
```

## 5.3 gtest

**安装[gtest](https://github.com/google/googletest)：**

```sh
git clone https://github.com/google/googletest.git
cd googletest

# BUILD_SHARED_LIBS用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j 4
sudo cmake --install build
```

**在`cmake`中添加`gtest`依赖：**

```cmake
find_package(GTest REQUIRED)
message(STATUS "GTEST_INCLUDE_DIRS: ${GTEST_INCLUDE_DIRS}")
message(STATUS "GTEST_BOTH_LIBRARIES: ${GTEST_BOTH_LIBRARIES}")
message(STATUS "GTEST_LIBRARIES: ${GTEST_LIBRARIES}")
message(STATUS "GTEST_MAIN_LIBRARIES: ${GTEST_MAIN_LIBRARIES}")

target_link_libraries(xxx ${GTEST_LIBRARIES})
target_link_libraries(xxx ${GTEST_MAIN_LIBRARIES})
```

**完整示例**

```sh
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(gtest_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(EXEC_FILES ./test_main.cpp)

add_executable(${PROJECT_NAME} ${EXEC_FILES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(GTest REQUIRED)
message(STATUS "GTEST_INCLUDE_DIRS: ${GTEST_INCLUDE_DIRS}")
message(STATUS "GTEST_BOTH_LIBRARIES: ${GTEST_BOTH_LIBRARIES}")
message(STATUS "GTEST_LIBRARIES: ${GTEST_LIBRARIES}")
message(STATUS "GTEST_MAIN_LIBRARIES: ${GTEST_MAIN_LIBRARIES}")

target_link_libraries(${PROJECT_NAME} ${GTEST_LIBRARIES})
target_link_libraries(${PROJECT_NAME} ${GTEST_MAIN_LIBRARIES})
EOF

cat > test_main.cpp << 'EOF' 
#include <gtest/gtest.h>

TEST(TestDemo, case_right) {
    ASSERT_EQ(1, 1);
}

TEST(TestDemo, case_wrong) {
    ASSERT_EQ(1, 0);
}

// ${GTEST_MAIN_LIBRARIES} will provide main method
// int main(int argc, char **argv) {
//     ::testing::InitGoogleTest(&argc, argv);
//     return RUN_ALL_TESTS();
// }
EOF

cmake -B build && cmake --build build

build/gtest_demo
```

### 5.3.1 Macros

1. `TEST(test_case_name, test_name)`: Defines a test case.
    ```cpp
    TEST(TestCaseName, TestName) {
        // Test logic here
    }
    ```

1. `TEST_F(test_fixture, test_name)`: Defines a test case using a test fixture.
    ```cpp
    class MyTestFixture : public ::testing::Test {
    protected:
        void SetUp() override {
            // Common setup logic for test cases
        }

        void TearDown() override {
            // Common cleanup logic for test cases
        }
    };

    TEST_F(MyTestFixture, TestName) {
        // Test logic using the fixture environment
    }
    ```

1. `EXPECT_EQ(expected, actual)`: Expects that two values are equal.
1. `ASSERT_EQ(expected, actual)`: Asserts that two values are equal.
1. `EXPECT_NE(val1, val2)`: Expects that two values are not equal.
1. `ASSERT_NE(val1, val2)`: Asserts that two values are not equal.
1. `EXPECT_LT(val1, val2)`: Expects that val1 is less than val2.
1. `ASSERT_LT(val1, val2)`: Asserts that val1 is less than val2.
1. `EXPECT_LE(val1, val2)`: Expects that val1 is less than or equal to val2.
1. `ASSERT_LE(val1, val2)`: Asserts that val1 is less than or equal to val2.
1. `EXPECT_GT(val1, val2)`: Expects that val1 is greater than val2.
1. `ASSERT_GT(val1, val2)`: Asserts that val1 is greater than val2.
1. `EXPECT_GE(val1, val2)`: Expects that val1 is greater than or equal to val2.
1. `ASSERT_GE(val1, val2)`: Asserts that val1 is greater than or equal to val2.
1. `EXPECT_TRUE(condition)`: Expects that a condition is true.
1. `ASSERT_TRUE(condition)`: Asserts that a condition is true.
1. `EXPECT_FALSE(condition)`: Expects that a condition is false.
1. `ASSERT_FALSE(condition)`: Asserts that a condition is false.
1. `EXPECT_STREQ(expected_str, actual_str)`: Expects that two C-style strings are equal.
1. `ASSERT_STREQ(expected_str, actual_str)`: Asserts that two C-style strings are equal.
1. `EXPECT_STRNE(str1, str2)`: Expects that two C-style strings are not equal.
1. `ASSERT_STRNE(str1, str2)`: Asserts that two C-style strings are not equal.
1. `EXPECT_THROW(statement, exception_type)`: Expects that a specific statement throws a particular exception.
1. `ASSERT_THROW(statement, exception_type)`: Asserts that a specific statement throws a particular exception.

### 5.3.2 Tips

1. 假设编译得到的二进制是`test`，通过执行`./test --help`就可以看到所有gtest支持的参数，包括执行特定case等等

## 5.4 benchmark

**安装[benchmark](https://github.com/google/benchmark)：**

```sh
git clone https://github.com/google/benchmark.git --depth 1
cd benchmark

# 这里指定googletest的工程路径（不加任何参数会有提示）
cmake -B build -DGOOGLETEST_PATH=~/googletest/ -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j 4
sudo cmake --install build
```

**在`cmake`中添加`benchmark`依赖：**

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
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -fopt-info-vec")

set(EXEC_FILES ./main.cpp)

add_executable(${PROJECT_NAME} ${EXEC_FILES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(benchmark REQUIRED)

target_link_libraries(${PROJECT_NAME} benchmark::benchmark)
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

cmake -B build && cmake --build build

build/benchmark_demo
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

### 5.4.1 quick-benchmark

[quick-bench（在线）](https://quick-bench.com/)

### 5.4.2 Tips

#### 5.4.2.1 benchmark::DoNotOptimize

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

#### 5.4.2.2 Run Specific Case

使用参数`--benchmark_filter=<regexp>`，此外可以使用`--help`查看所有参数

### 5.4.3 Reference

* [benchmark/docs/user_guide.md](https://github.com/google/benchmark/blob/main/docs/user_guide.md)
* [c++性能测试工具：google benchmark入门（一）](https://www.cnblogs.com/apocelipes/p/10348925.html)

## 5.5 [gperftools/gperftools](https://github.com/gperftools/gperftools)

# 6 Apache

## 6.1 arrow

[apache-arrow](https://github.com/apache/arrow)

Requirement:

1. `protobuf`

```sh
git clone https://github.com/apache/arrow.git
cd arrow/cpp

cmake --list-presets
cmake --preset -N ninja-release

cmake -B build --preset ninja-release
cmake --build build -j 4
sudo cmake --install build

echo '/usr/local/lib64' | sudo tee /etc/ld.so.conf.d/arrow.conf
sudo ldconfig
```

[Reading and writing Parquet files](https://arrow.apache.org/docs/cpp/parquet.html#)

```cpp
#include <arrow/api.h>
#include <arrow/io/api.h>
#include <arrow/pretty_print.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <filesystem>
#include <iostream>

void CheckStatus(const arrow::Status& status) {
    if (!status.ok()) {
        std::cerr << "Arrow operation failed: " << status.message() << std::endl;
        exit(EXIT_FAILURE);
    }
}

int main() {
    // Create a simple table
    arrow::Int64Builder i64builder;
    CheckStatus(i64builder.AppendValues({1, 2, 3, 4, 5}));

    std::shared_ptr<arrow::Array> array;
    CheckStatus(i64builder.Finish(&array));

    std::shared_ptr<arrow::Schema> schema = arrow::schema({arrow::field("int_column", arrow::int64())});
    auto table = arrow::Table::Make(schema, {array});

    // Write the table to a Parquet file
    std::string file_path = "data.parquet";
    std::shared_ptr<arrow::io::FileOutputStream> outfile;
    CheckStatus(arrow::io::FileOutputStream::Open(file_path).Value(&outfile));
    CheckStatus(parquet::arrow::WriteTable(*table, arrow::default_memory_pool(), outfile, 3));

    // Read the Parquet file back into a table
    std::shared_ptr<arrow::io::ReadableFile> infile;
    CheckStatus(arrow::io::ReadableFile::Open(file_path, arrow::default_memory_pool()).Value(&infile));

    std::unique_ptr<parquet::arrow::FileReader> reader;
    CheckStatus(parquet::arrow::OpenFile(infile, arrow::default_memory_pool(), &reader));

    std::shared_ptr<arrow::Table> read_table;
    CheckStatus(reader->ReadTable(&read_table));

    // Print the table to std::cout
    std::stringstream ss;
    CheckStatus(arrow::PrettyPrint(*read_table.get(), {}, &ss));
    std::cout << ss.str() << std::endl;

    return 0;
}
```

```sh
gcc -o main main.cpp -lstdc++ -std=gnu++17 -larrow -lparquet
./main
```

## 6.2 thrift

```sh
git clone https://github.com/apache/thrift.git
cd thrift
git checkout v0.15.0

./bootstrap.sh
# you can build specific lib by using --with-xxx or --without-xxx
./configure
make -j 64
sudo make install
```

```sh
cat > example.thrift << 'EOF'
namespace cpp example

struct Person {
  1: string name,
  2: i32 age,
  3: string email
}

service PersonService {
  void addPerson(1: Person person)
}
EOF

thrift --gen cpp example.thrift
```

# 7 Pocoproject

```sh
git clone -b master https://github.com/pocoproject/poco.git
cd poco
cmake -B cmake-build
cmake --build cmake-build --config Release -j 64
sudo cmake --install cmake-build
```

## 7.1 Logger

```sh
mkdir poco_logger_demo
cd poco_logger_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(poco_logger_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(Poco REQUIRED COMPONENTS Foundation Net XML JSON)
target_link_libraries(${PROJECT_NAME} Poco::Foundation Poco::Net Poco::XML Poco::JSON)
EOF

cat > poco_logger_demo.cpp << 'EOF'
#include <Poco/AutoPtr.h>
#include <Poco/ConsoleChannel.h>
#include <Poco/FileChannel.h>
#include <Poco/FormattingChannel.h>
#include <Poco/Logger.h>
#include <Poco/PatternFormatter.h>

int main() {
    {
        Poco::AutoPtr<Poco::ConsoleChannel> channel(new Poco::ConsoleChannel);
        Poco::Logger::root().setLevel("trace");
        Poco::Logger::root().setChannel(channel);
        Poco::Logger::get("main_1").information("Hello, World!");
    }
    {
        Poco::AutoPtr<Poco::PatternFormatter> formatter(new Poco::PatternFormatter("%Y.%m.%d %H:%M:%S.%F <%p> %s: %t"));
        Poco::AutoPtr<Poco::ConsoleChannel> console_chanel(new Poco::ConsoleChannel);
        Poco::AutoPtr<Poco::FormattingChannel> channel(new Poco::FormattingChannel(formatter, console_chanel));
        Poco::Logger::root().setLevel("trace");
        Poco::Logger::root().setChannel(channel);
        Poco::Logger::get("main_1").information("Hello, World!");
        Poco::Logger::get("main_2").information("Hello, World!");
    }
    {
        Poco::AutoPtr<Poco::FileChannel> fileChannel(new Poco::FileChannel);
        fileChannel->setProperty("path", "sample.log");
        fileChannel->setProperty("rotation", "1 M"); // Rotate log file monthly

        Poco::AutoPtr<Poco::PatternFormatter> formatter(new Poco::PatternFormatter);
        formatter->setProperty("pattern", "%Y-%m-%d %H:%M:%S %s: %t"); // Customize log pattern

        Poco::AutoPtr<Poco::FormattingChannel> formattingChannel(new Poco::FormattingChannel(formatter, fileChannel));

        Poco::Logger& logger = Poco::Logger::create("FileLogger", formattingChannel, Poco::Message::PRIO_INFORMATION);

        logger.information("This is an informational message.");
        logger.warning("This is a warning message.");
    }
    return 0;
}
EOF

cmake -B build
cmake --build build
build/poco_logger_demo
```

Output:

```
Hello, World!
Hello, World!
2024.04.12 08:22:40.072214 <Information> main_2: Hello, World!
```

## 7.2 JSON

```sh
mkdir poco_json_demo
cd poco_json_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(poco_json_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(Poco REQUIRED COMPONENTS Foundation Net XML JSON)
target_link_libraries(${PROJECT_NAME} Poco::Foundation Poco::Net Poco::XML Poco::JSON)
EOF

cat > poco_json_demo.cpp << 'EOF'
#include <Poco/Dynamic/Var.h>
#include <Poco/JSON/Parser.h>
#include <Poco/JSON/Stringifier.h>

#include <iostream>
#include <sstream>

int main() {
    // JSON string to parse
    std::string jsonString = R"({"name":"John Doe","age":30,"isDeveloper":true})";

    // Parse the JSON string
    Poco::JSON::Parser parser;
    Poco::Dynamic::Var result = parser.parse(jsonString);
    Poco::JSON::Object::Ptr jsonObject = result.extract<Poco::JSON::Object::Ptr>();

    // Extract values
    std::string name = jsonObject->getValue<std::string>("name");
    int age = jsonObject->getValue<int>("age");
    bool isDeveloper = jsonObject->getValue<bool>("isDeveloper");

    std::cout << "Name: " << name << ", Age: " << age << ", Is Developer: " << isDeveloper << std::endl;

    // Create a new JSON object
    Poco::JSON::Object newObject;
    newObject.set("newName", "Jane Smith");
    newObject.set("newAge", 28);
    newObject.set("isNewDeveloper", false);

    // Convert to JSON string
    std::stringstream ss;
    newObject.stringify(ss);

    std::cout << "Generated JSON: " << ss.str() << std::endl;

    return 0;
}
EOF

cmake -B build
cmake --build build
build/poco_json_demo
```

Output:

```
Name: John Doe, Age: 30, Is Developer: 1
Generated JSON: {"isNewDeveloper":false,"newAge":28,"newName":"Jane Smith"}
```

# 8 sqlpp11

**How to integrate:**

```sh

target_link_libraries(xxx sqlpp11)
```

**How to create cpp header files:**

```sh
cat > /tmp/foo.sql << 'EOF'
CREATE TABLE foo (
    id bigint,
    name varchar(50),
    hasFun bool
);
EOF

scripts/ddl2cpp  /tmp/foo.sql /tmp/foo my_ns
```

## 8.1 With Sqlite

```
tree -L 2
.
├── CMakeLists.txt
├── contrib
│   ├── SQLiteCpp
│   └── sqlpp11
├── main.cpp
├── users.ddl
└── users.h
```

```sh
mkdir sqlpp11_demo && cd sqlpp11_demo

git init

# Download source code of these two project
git submodule add https://github.com/rbock/sqlpp11.git contrib/sqlpp11
git submodule add https://github.com/SRombauts/SQLiteCpp.git contrib/SQLiteCpp
git submodule update --init --recursive

# CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(sqlpp11_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${PROJECT_NAME} main.cpp)

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

# Include subdirectories
add_subdirectory(contrib/sqlpp11)
add_subdirectory(contrib/SQLiteCpp)

# Link against libraries
target_link_libraries(${PROJECT_NAME} sqlpp11)
target_link_libraries(${PROJECT_NAME} SQLiteCpp sqlite3 pthread dl)
EOF

# ddl
cat > users.ddl << 'EOF'
CREATE TABLE users (
    id INTEGER NOT NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER NOT NULL,
    PRIMARY KEY(id)
);
EOF

# Create headers  
contrib/sqlpp11/scripts/ddl2cpp users.ddl users Test

# main.cpp
cat > main.cpp << 'EOF'
#include <sqlpp11/all_of.h>
#include <sqlpp11/custom_query.h>
#include <sqlpp11/insert.h>
#include <sqlpp11/sqlite3/sqlite3.h>
#include <sqlpp11/sqlpp11.h>
#include <sqlpp11/verbatim.h>

#include <iostream>
#include <string>

#include "users.h"

template <typename Db, typename Assignment>
void print(Db& db, Assignment assignment) {
    typename Db::_serializer_context_t context{db};
    std::cout << sqlpp::serialize(assignment, context).str() << std::endl;
}

int main() {
    auto config = std::make_shared<sqlpp::sqlite3::connection_config>();
    config->path_to_database = ":memory:";
    config->flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE;
    config->debug = true;

    auto conn_pool = std::make_shared<sqlpp::sqlite3::connection_pool>(config, 5);

    auto db = conn_pool->get();

    db.execute(R"(CREATE TABLE users (
                id INTEGER NOT NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                age INTEGER NOT NULL,
                PRIMARY KEY(id)))");

    Test::Users users;

    {
        auto query = sqlpp::insert_into(users).set(users.id = 10000001, users.firstName = "Emma",
                                                   users.lastName = "Watson", users.age = 15);
        print(db, query);
        db(query);
    }

    {
        auto query = sqlpp::insert_into(users).set(users.id = 10000002, users.firstName = "Leo",
                                                   users.lastName = "Grant", users.age = 18);
        print(db, query);
        db(query);
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).unconditionally();
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).where(users.age <= 20);
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = sqlpp::remove_from(users).where(users.id == 10000001);
        print(db, query);
        db(query);
    }

    return 0;
}
EOF

# compile and run
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j 64
build/sqlpp11_demo
```

```
Sqlite3 debug: Preparing: 'CREATE TABLE users (
                id INTEGER NOT NULL,
                first_name TEXT NOT NULL,
                last_name TEXT NOT NULL,
                age INTEGER NOT NULL,
                PRIMARY KEY(id))'
INSERT INTO users (id,first_name,last_name,age) VALUES(10000001,'Emma','Watson',15)
Sqlite3 debug: Preparing: 'INSERT INTO users (id,first_name,last_name,age) VALUES(10000001,'Emma','Watson',15)'
INSERT INTO users (id,first_name,last_name,age) VALUES(10000002,'Leo','Grant',18)
Sqlite3 debug: Preparing: 'INSERT INTO users (id,first_name,last_name,age) VALUES(10000002,'Leo','Grant',18)'
SELECT users.id,users.first_name,users.last_name,users.age FROM users
Sqlite3 debug: Preparing: 'SELECT users.id,users.first_name,users.last_name,users.age FROM users'
Sqlite3 debug: Constructing bind result, using handle at 0x1f7de20
Sqlite3 debug: Accessing next row of handle at 0x1f7de20
Sqlite3 debug: binding integral result 0 at index: 0
Sqlite3 debug: binding text result at index: 1
Sqlite3 debug: binding text result at index: 2
Sqlite3 debug: binding integral result 0 at index: 3
    -> id=10000001, firstName=Emma, lastName=Watson, age=15
Sqlite3 debug: Accessing next row of handle at 0x1f7de20
Sqlite3 debug: binding integral result 10000001 at index: 0
Sqlite3 debug: binding text result at index: 1
Sqlite3 debug: binding text result at index: 2
Sqlite3 debug: binding integral result 15 at index: 3
    -> id=10000002, firstName=Leo, lastName=Grant, age=18
Sqlite3 debug: Accessing next row of handle at 0x1f7de20
SELECT users.id,users.first_name,users.last_name,users.age FROM users WHERE (users.age<=20)
Sqlite3 debug: Preparing: 'SELECT users.id,users.first_name,users.last_name,users.age FROM users WHERE (users.age<=20)'
Sqlite3 debug: Constructing bind result, using handle at 0x1f7de40
Sqlite3 debug: Accessing next row of handle at 0x1f7de40
Sqlite3 debug: binding integral result 0 at index: 0
Sqlite3 debug: binding text result at index: 1
Sqlite3 debug: binding text result at index: 2
Sqlite3 debug: binding integral result 0 at index: 3
    -> id=10000001, firstName=Emma, lastName=Watson, age=15
Sqlite3 debug: Accessing next row of handle at 0x1f7de40
Sqlite3 debug: binding integral result 10000001 at index: 0
Sqlite3 debug: binding text result at index: 1
Sqlite3 debug: binding text result at index: 2
Sqlite3 debug: binding integral result 15 at index: 3
    -> id=10000002, firstName=Leo, lastName=Grant, age=18
Sqlite3 debug: Accessing next row of handle at 0x1f7de40
DELETE FROM users WHERE (users.id=10000001)
Sqlite3 debug: Preparing: 'DELETE FROM users WHERE (users.id=10000001)'
```

## 8.2 With Mysql

```
tree -L 2
.
├── CMakeLists.txt
├── contrib
│   ├── mysql-connector-c-6.1.11-linux-glibc2.12-x86_64
│   ├── mysql-connector-c-6.1.11-linux-glibc2.12-x86_64.tar.gz
│   └── sqlpp11
├── main.cpp
├── users.ddl
└── users.h
```

```sh
mkdir sqlpp11_demo && cd sqlpp11_demo

git init

# Download source code of these two project
mkdir -p contrib
wget -O contrib/mysql-connector-c-6.1.11-linux-glibc2.12-x86_64.tar.gz https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-6.1.11-linux-glibc2.12-x86_64.tar.gz
tar -zxf contrib/mysql-connector-c-6.1.11-linux-glibc2.12-x86_64.tar.gz -C contrib
git submodule add https://github.com/rbock/sqlpp11.git contrib/sqlpp11
git submodule update --init --recursive

# CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(sqlpp11_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# link_directories must be placed before add_executable or add_library
include_directories(contrib/mysql-connector-c-6.1.11-linux-glibc2.12-x86_64/include)
link_directories(contrib/mysql-connector-c-6.1.11-linux-glibc2.12-x86_64/lib)

add_executable(${PROJECT_NAME} main.cpp)

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

# Include subdirectories
add_subdirectory(contrib/sqlpp11)

# Link against libraries
target_link_libraries(${PROJECT_NAME} sqlpp11 mysqlclient)
EOF

# ddl
cat > users.ddl << 'EOF'
CREATE TABLE users (
    id BIGINT NOT NULL,
    first_name VARCHAR(16) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    age SMALLINT NOT NULL,
    PRIMARY KEY(id)
);
EOF

# Create headers  
contrib/sqlpp11/scripts/ddl2cpp users.ddl users Test

# main.cpp
cat > main.cpp << 'EOF'
#include <sqlpp11/all_of.h>
#include <sqlpp11/custom_query.h>
#include <sqlpp11/insert.h>
#include <sqlpp11/mysql/mysql.h>
#include <sqlpp11/sqlpp11.h>
#include <sqlpp11/verbatim.h>

#include <iostream>
#include <string>

#include "users.h"

struct on_duplicate_key_update {
    std::string _serialized;

    template <typename Db, typename Assignment>
    on_duplicate_key_update(Db& db, Assignment assignment) {
        typename Db::_serializer_context_t context{db};
        _serialized = " ON DUPLICATE KEY UPDATE " + serialize(assignment, context).str();
    }

    template <typename Db, typename Assignment>
    auto operator()(Db& db, Assignment assignment) -> on_duplicate_key_update& {
        typename Db::_serializer_context_t context{db};
        _serialized += ", " + serialize(assignment, context).str();
        return *this;
    }

    auto get() const -> sqlpp::verbatim_t<::sqlpp::no_value_t> { return ::sqlpp::verbatim(_serialized); }
};

template <typename Db, typename Assignment>
void print(Db& db, Assignment assignment) {
    typename Db::_serializer_context_t context{db};
    std::cout << sqlpp::serialize(assignment, context).str() << std::endl;
}

int main() {
    auto config = std::make_shared<sqlpp::mysql::connection_config>();
    config->user = "root";
    config->port = 13306;
    config->password = "Abcd1234";
    config->database = "test";
    config->host = "127.0.0.1";

    auto conn_pool = std::make_shared<sqlpp::mysql::connection_pool>(config, 5);

    auto db = conn_pool->get();

    Test::Users users;

    {
        auto query = sqlpp::custom_query(
                sqlpp::insert_into(users).set(users.id = 10000001, users.firstName = "Emma", users.lastName = "Watson",
                                              users.age = 15),
                on_duplicate_key_update(db, users.firstName = "Emma")(db, users.lastName = "Watson")(db, users.age = 15)
                        .get());
        print(db, query);
        db(query);
    }

    {
        auto query = sqlpp::custom_query(
                sqlpp::insert_into(users).set(users.id = 10000002, users.firstName = "Leo", users.lastName = "Grant",
                                              users.age = 18),
                on_duplicate_key_update(db, users.firstName = "Leo")(db, users.lastName = "Grant")(db, users.age = 18)
                        .get());
        print(db, query);
        db(query);
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).unconditionally();
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).where(users.age <= 20);
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = sqlpp::remove_from(users).where(users.id == 10000001);
        print(db, query);
        db(query);
    }

    return 0;
}
EOF

# compile and run
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j 64
build/sqlpp11_demo
```

## 8.3 With Mariadb

```sh
tree -L 2
.
├── CMakeLists.txt
├── contrib
│   ├── mariadb-connector-c
│   └── sqlpp11
├── main.cpp
├── users.ddl
└── users.h
```

```sh
mkdir sqlpp11_demo && cd sqlpp11_demo

git init

# Download source code of these two project
git submodule add https://github.com/mariadb-corporation/mariadb-connector-c.git contrib/mariadb-connector-c
git submodule add https://github.com/rbock/sqlpp11.git contrib/sqlpp11
git submodule update --init --recursive

# CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(sqlpp11_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${PROJECT_NAME} main.cpp)

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

# Include subdirectories
add_subdirectory(contrib/sqlpp11)
add_subdirectory(contrib/mariadb-connector-c)

# Include header files
target_include_directories (${PROJECT_NAME} PUBLIC "${CMAKE_SOURCE_DIR}/contrib/mariadb-connector-c/include")
target_include_directories (${PROJECT_NAME} PUBLIC "${CMAKE_BINARY_DIR}/contrib/mariadb-connector-c/include")

# Link against libraries
target_link_libraries(${PROJECT_NAME} sqlpp11 mariadbclient)
EOF

# ddl
cat > users.ddl << 'EOF'
CREATE TABLE users (
    id BIGINT NOT NULL,
    first_name VARCHAR(16) NOT NULL,
    last_name VARCHAR(16) NOT NULL,
    age SMALLINT NOT NULL,
    PRIMARY KEY(id)
);
EOF

# Create headers  
contrib/sqlpp11/scripts/ddl2cpp users.ddl users Test

# main.cpp
cat > main.cpp << 'EOF'
#include <sqlpp11/all_of.h>
#include <sqlpp11/custom_query.h>
#include <sqlpp11/insert.h>
#include <sqlpp11/mysql/mysql.h>
#include <sqlpp11/sqlpp11.h>
#include <sqlpp11/verbatim.h>

#include <iostream>
#include <string>

#include "users.h"

struct on_duplicate_key_update {
    std::string _serialized;

    template <typename Db, typename Assignment>
    on_duplicate_key_update(Db& db, Assignment assignment) {
        typename Db::_serializer_context_t context{db};
        _serialized = " ON DUPLICATE KEY UPDATE " + serialize(assignment, context).str();
    }

    template <typename Db, typename Assignment>
    auto operator()(Db& db, Assignment assignment) -> on_duplicate_key_update& {
        typename Db::_serializer_context_t context{db};
        _serialized += ", " + serialize(assignment, context).str();
        return *this;
    }

    auto get() const -> sqlpp::verbatim_t<::sqlpp::no_value_t> { return ::sqlpp::verbatim(_serialized); }
};

template <typename Db, typename Assignment>
void print(Db& db, Assignment assignment) {
    typename Db::_serializer_context_t context{db};
    std::cout << sqlpp::serialize(assignment, context).str() << std::endl;
}

int main() {
    auto config = std::make_shared<sqlpp::mysql::connection_config>();
    config->user = "root";
    config->port = 13306;
    config->password = "Abcd1234";
    config->database = "test";
    config->host = "127.0.0.1";

    auto conn_pool = std::make_shared<sqlpp::mysql::connection_pool>(config, 5);

    auto db = conn_pool->get();

    Test::Users users;

    {
        auto query = sqlpp::custom_query(
                sqlpp::insert_into(users).set(users.id = 10000001, users.firstName = "Emma", users.lastName = "Watson",
                                              users.age = 15),
                on_duplicate_key_update(db, users.firstName = "Emma")(db, users.lastName = "Watson")(db, users.age = 15)
                        .get());
        print(db, query);
        db(query);
    }

    {
        auto query = sqlpp::custom_query(
                sqlpp::insert_into(users).set(users.id = 10000002, users.firstName = "Leo", users.lastName = "Grant",
                                              users.age = 18),
                on_duplicate_key_update(db, users.firstName = "Leo")(db, users.lastName = "Grant")(db, users.age = 18)
                        .get());
        print(db, query);
        db(query);
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).unconditionally();
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = select(sqlpp::all_of(users)).from(users).where(users.age <= 20);
        print(db, query);
        for (const auto& row : db(query)) {
            std::cout << "    -> id=" << row.id << ", firstName=" << row.firstName << ", lastName=" << row.lastName
                      << ", age=" << row.age << std::endl;
        }
    }

    {
        auto query = sqlpp::remove_from(users).where(users.id == 10000001);
        print(db, query);
        db(query);
    }

    return 0;
}
EOF

# compile and run
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j 64
```

You may be presented with the following error messages:

```
CMake Error at contrib/mariadb-connector-c/cmake/install_plugins.cmake:11 (INSTALL):
  INSTALL TARGETS given no LIBRARY DESTINATION for module target "remote_io".
Call Stack (most recent call first):
  contrib/mariadb-connector-c/cmake/plugins.cmake:83 (INSTALL_PLUGIN)
```

Just remove the line 83(`contrib/mariadb-connector-c/cmake/plugins.cmake:83`), which is 

```cmake
INSTALL_PLUGIN(${CC_PLUGIN_TARGET} ${CMAKE_CURRENT_BINARY_DIR})
```

And then compile again:

```sh
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j 64
build/sqlpp11_demo
```

```
INSERT INTO users (id,first_name,last_name,age) VALUES(10000001,'Emma','Watson',15)  ON DUPLICATE KEY UPDATE first_name='Emma', last_name='Watson', age=15
INSERT INTO users (id,first_name,last_name,age) VALUES(10000002,'Leo','Grant',18)  ON DUPLICATE KEY UPDATE first_name='Leo', last_name='Grant', age=18
SELECT users.id,users.first_name,users.last_name,users.age FROM users
    -> id=10000001, firstName=Emma, lastName=Watson, age=15
    -> id=10000002, firstName=Leo, lastName=Grant, age=18
SELECT users.id,users.first_name,users.last_name,users.age FROM users WHERE (users.age<=20)
    -> id=10000001, firstName=Emma, lastName=Watson, age=15
    -> id=10000002, firstName=Leo, lastName=Grant, age=18
DELETE FROM users WHERE (users.id=10000001)
```

# 9 Assorted

1. [Awesome C++ Projects](https://github.com/fffaraz/awesome-cpp)
1. [parallel-hashmap](https://github.com/greg7mdp/parallel-hashmap)：`parallel-hashmap`提供了一组高性能、并发安全的`map`，用于替换`std`以及`boost`中的`map`
    * [phmap_gdb.py](https://github.com/greg7mdp/parallel-hashmap/blob/master/phmap_gdb.py)
1. [cpp-httplib](https://github.com/yhirose/cpp-httplib)：`cpp-httplib`以头文件的方式提供`http`协议的相关支持
1. [json](https://github.com/nlohmann/json)：`json`库
1. [libfiu(Failure Injection Unit)](https://blitiri.com.ar/p/libfiu/)：错误注入
