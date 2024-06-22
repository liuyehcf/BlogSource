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
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
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
/root/main.cpp:31: 0x4014d3 print_stack_trace()
/root/main.cpp:24: 0x4014df my_function()
/root/main.cpp:28: 0x4014eb main
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
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
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

## 1.3 bison

* [Bison 3.8.1](https://www.gnu.org/software/bison/manual/bison.html)

Bison is a general-purpose parser generator that converts an annotated context-free grammar into a deterministic LR or generalized LR (GLR) parser employing LALR(1) parser tables. As an experimental feature, Bison can also generate IELR(1) or canonical LR(1) parser tables. Once you are proficient with Bison, you can use it to develop a wide range of language parsers, from those used in simple desk calculators to complex programming languages.

# 2 boost

## 2.1 Installation

### 2.1.1 Package Manager

```sh
yum install -y boost-devel
```

### 2.1.2 From Source

[Boost Downloads](https://www.boost.org/users/download/)

```sh
wget https://boostorg.jfrog.io/artifactory/main/release/1.84.0/source/boost_1_84_0.tar.gz
tar -zxf boost_1_84_0.tar.gz
cd boost_1_84_0

./bootstrap.sh
./b2
sudo ./b2 install
```

## 2.2 Usage

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

## 2.3 Print Stack

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
        throw std::logic_error("error");
    }
    foo(cnt - 1);
}

#if defined(__GNUC__)
// wrap libc's _cxa_throw to print stack trace of exceptions
extern "C" {
void __real___cxa_throw(void* thrown_exception, void* infov, void (*dest)(void*));

void __wrap___cxa_throw(void* thrown_exception, void* infov, void (*dest)(void*));
}
// wrap libc's _cxa_throw that must not throw exceptions again, otherwise causing crash.
void __wrap___cxa_throw(void* thrown_exception, void* info, void (*dest)(void*)) {
    std::cout << boost::stacktrace::stacktrace() << std::endl;

    // call the real __cxa_throw():
    __real___cxa_throw(thrown_exception, info, dest);
}
#endif

int main() {
    std::cout << "Boost version: " << BOOST_VERSION / 100000 << "." << BOOST_VERSION / 100 % 1000 << "."
              << BOOST_VERSION % 100 << std::endl;
    try {
        foo(5);
    } catch (...) {
        // ignore
    }
    return 0;
}
```

### 2.3.1 With addr2line

This approach works fine with `gcc-10.3.0`, but can't work with higher versions like `gcc-11.3.0`, `gcc-12.3.0`. Don't know why so far.

**Compile:**

```sh
# -ldl: link libdl
# -g: generate debug information
gcc -o main main.cpp -DBOOST_STACKTRACE_USE_ADDR2LINE -lstdc++ -std=gnu++17 -Wl,-wrap=__cxa_throw -ldl -g
./main
```

**Output:**

```
Boost version: 1.84.0
 0# boost::stacktrace::basic_stacktrace<std::allocator<boost::stacktrace::frame> >::basic_stacktrace() at /usr/local/include/boost/stacktrace/stacktrace.hpp:129
 1# foo(int) at /root/main.cpp:9
 2# foo(int) at /root/main.cpp:10
 3# foo(int) at /root/main.cpp:10
 4# foo(int) at /root/main.cpp:10
 5# foo(int) at /root/main.cpp:10
 6# foo(int) at /root/main.cpp:10
 7# main at /root/main.cpp:36
 8# 0x00007F14FEF4E24A in /lib/x86_64-linux-gnu/libc.so.6
 9# __libc_start_main in /lib/x86_64-linux-gnu/libc.so.6
10# _start in ./main
```

### 2.3.2 With libbacktrace

**Compile:**

```sh
# -ldl: link libdl
# -g: generate debug information
# -lbacktrace: link libbacktrace
gcc -o main main.cpp -DBOOST_STACKTRACE_USE_BACKTRACE -lstdc++ -std=gnu++17 -Wl,-wrap=__cxa_throw -ldl -lbacktrace -g
./main
```

**Output:**

```
Boost version: 1.84.0
 0# __wrap___cxa_throw at /root/main.cpp:21
 1# foo(int) at /root/main.cpp:9
 2# foo(int) at /root/main.cpp:10
 3# foo(int) at /root/main.cpp:10
 4# foo(int) at /root/main.cpp:10
 5# foo(int) at /root/main.cpp:10
 6# foo(int) at /root/main.cpp:10
 7# main at /root/main.cpp:36
 8# __libc_start_call_main at ../sysdeps/nptl/libc_start_call_main.h:74
 9# __libc_start_main at ../csu/libc-start.c:347
10# _start in ./main
```

## 2.4 Reference

* [The Boost C++ Libraries BoostBook Documentation Subset](https://www.boost.org/doc/libs/master/doc/html/)
* [How to print current call stack](https://www.boost.org/doc/libs/1_66_0/doc/html/stacktrace/getting_started.html)
* [print call stack in C or C++](https://stackoverflow.com/Questions/3899870/print-call-stack-in-c-or-c)

# 3 [fmt](https://github.com/fmtlib/fmt)

**安装`fmt`：**

```sh
git clone https://github.com/fmtlib/fmt.git
cd fmt

cmake -B build -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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

# 4 Facebook

## 4.1 folly

[folly](https://github.com/facebook/folly)

Prerequisites (These dependencies won't be automatically installed by cachelib's script):

* `boost`
* `jemalloc`

For Ubuntu 18.04, you may need the following dependencies:

```sh
sudo apt install -y libdouble-conversion-dev libevent-dev liblz4-dev libdwarf-dev libsnappy-dev liblzma-dev libbz2-dev libunwind-dev libsodium-dev libnuma-dev libzstd-dev
```

## 4.2 CacheLib

[CacheLib](https://github.com/facebook/CacheLib)

# 5 Google

## 5.1 gflag

**安装[gflag](https://github.com/gflags/gflags)：**

```sh
git clone https://github.com/gflags/gflags.git
cd gflags

cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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
git clone -b v0.6.0 https://github.com/google/glog.git
cd glog

# BUILD_SHARED_LIBS 用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -B build -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC"
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install build
```

**在`cmake`中添加`glog`依赖：**

```cmake
find_package(GLOG)

target_link_libraries(xxx glog::glog)
```

### 5.2.1 Print Stack (Not Recommend)

[[Enhancement] wrap libc's __cxa_throw to print stack trace when throw exceptions](https://github.com/StarRocks/starrocks/pull/13410)

```cpp
#define GLOG_USE_GLOG_EXPORT
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

* `glog`需要使用静态库版本，因为动态库版本选择隐藏`DumpStackTraceToString`这个符号（`nm -D /usr/local/lib/libglog.so | grep 'DumpStackTraceToString'`），且该方法在`0.7.0`版本后被删除

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
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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

## 5.5 gperftools/gperftools

[gperftools/gperftools](https://github.com/gperftools/gperftools)

## 5.6 snappy

[snappy](https://github.com/google/snappy)

Snappy is a compression/decompression library

## 5.7 breakpad

Breakpad is a library and tool suite that allows you to distribute an application to users with compiler-provided debugging information removed, record crashes in compact "minidump" files, send them back to your server, and produce C and C++ stack traces from these minidumps. Breakpad can also write minidumps on request for programs that have not crashed.

It includes following tools:

* `minidump_stackwalk`: This tool processes minidump files to produce a human-readable stack trace. It uses symbol files to translate memory addresses into function names, file names, and line numbers
    * `minidump_stackwalk <minidump_file> <symbol_path>`
* `microdump_stackwalk`: Similar to `minidump_stackwalk`, but specifically designed to process microdump files, which are smaller and contain less information than full minidumps
    * `microdump_stackwalk <microdump_file> <symbol_path>`
* `dump_syms`: This tool extracts debugging symbols from a binary and outputs them in a format that can be uploaded to a symbol server
    * `dump_syms <binary_file> > <output_symbol_file>`

```sh
mkdir -p breakpad_demo
cd breakpad_demo
git clone https://chromium.googlesource.com/breakpad/breakpad.git contrib/breakpad
git clone https://chromium.googlesource.com/linux-syscall-support.git contrib/breakpad/src/third_party/lss

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(breakpad_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${PROJECT_NAME} main.cpp)

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

set(BREAKPAD_SOURCE_DIR ${CMAKE_SOURCE_DIR}/contrib/breakpad)
set(BREAKPAD_BINARY_DIR ${CMAKE_BINARY_DIR}/breakpad_build)

include(ExternalProject)
ExternalProject_Add(
    breakpad
    SOURCE_DIR ${BREAKPAD_SOURCE_DIR}
    BINARY_DIR ${BREAKPAD_BINARY_DIR}
    CONFIGURE_COMMAND ${BREAKPAD_SOURCE_DIR}/configure --prefix=${BREAKPAD_BINARY_DIR}
    # --unset=MAKEFLAGS is mandatory to avoid nested make issues, error message like: make[3]: warning: jobserver unavailable: using -j1.  Add '+' to parent make rule.
    BUILD_COMMAND ${CMAKE_COMMAND} -E env --unset=MAKEFLAGS ${CMAKE_MAKE_PROGRAM} -C ${BREAKPAD_BINARY_DIR} -j${CMAKE_BUILD_PARALLEL_LEVEL}
    INSTALL_COMMAND ""
    BUILD_BYPRODUCTS ${BREAKPAD_BINARY_DIR}/src/client/linux/libbreakpad_client.a
)
add_custom_command(
    TARGET breakpad
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${BREAKPAD_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/breakpad_product
)
add_dependencies(${PROJECT_NAME} breakpad)

target_include_directories(${PROJECT_NAME} PRIVATE ${BREAKPAD_SOURCE_DIR}/src)
target_link_libraries(${PROJECT_NAME} PRIVATE ${BREAKPAD_BINARY_DIR}/src/client/linux/libbreakpad_client.a)
target_link_libraries(${PROJECT_NAME} PRIVATE pthread)
EOF

cat > main.cpp << 'EOF'
#include <client/linux/handler/exception_handler.h>

#include <iostream>
#include <stdexcept>

bool DumpCallback(const google_breakpad::MinidumpDescriptor& descriptor, void* context, bool succeeded) {
    std::cout << descriptor.path() << std::endl;
    return succeeded;
}

int main(int argc, char* argv[]) {
    google_breakpad::MinidumpDescriptor descriptor("./minidumps");
    google_breakpad::ExceptionHandler handler(descriptor, nullptr, DumpCallback, nullptr, true, -1);

    throw std::runtime_error("Test exception");
}
EOF

cmake -B build && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))

find build/breakpad_build -type f -executable

mkdir -p minidumps
# step1: generate symbol file
build/breakpad_build/src/tools/linux/dump_syms/dump_syms build/breakpad_demo > build/breakpad_demo.sym
# step2: generate dump file
dump_path=$(build/breakpad_demo | grep 'minidumps')
# step3: analyze dump file
build/breakpad_build/src/processor/minidump_stackwalk ${dump_path} build/breakpad_demo
```

# 6 Apache

## 6.1 arrow

[apache-arrow](https://github.com/apache/arrow)

* [Building Arrow C++](https://github.com/apache/arrow/blob/main/docs/source/developers/cpp/building.rst): Find all building Optional Components here

Requirement:

1. `protobuf`

```sh
git clone -b apache-arrow-16.1.0 https://github.com/apache/arrow.git
cd arrow/cpp

cmake --list-presets
cmake --preset -N ninja-release

cmake -B build --preset ninja-release -DPARQUET_REQUIRE_ENCRYPTION=ON
cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install build

echo '/usr/local/lib64' | sudo tee /etc/ld.so.conf.d/arrow.conf && sudo ldconfig
```

Build with llvm's libc++

```sh
cmake -B build --preset ninja-release -DPARQUET_REQUIRE_ENCRYPTION=ON \
      -DCMAKE_C_COMPILER=clang \
      -DCMAKE_CXX_COMPILER=clang++ \
      -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
      -DCMAKE_EXE_LINKER_FLAGS="-stdlib=libc++" \
      -DCMAKE_SHARED_LINKER_FLAGS="-stdlib=libc++"
```

### 6.1.1 Parquet Module

**Related Docs:**

* [Reading and writing Parquet files](https://arrow.apache.org/docs/cpp/parquet.html)
* [Parquet Modular Encryption](https://github.com/apache/parquet-format/blob/master/Encryption.md)

**Parquet demo without encryption:**

```cpp
#include <arrow/api.h>
#include <arrow/io/api.h>
#include <arrow/pretty_print.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/type_fwd.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <filesystem>
#include <iostream>

arrow::Status execute() {
    // Create a simple table
    arrow::Int64Builder col_builder1;
    ARROW_RETURN_NOT_OK(col_builder1.AppendValues({1, 2, 3, 4, 5}));
    arrow::DoubleBuilder col_builder2;
    ARROW_RETURN_NOT_OK(col_builder2.AppendValues({1.1, 2.2, 3.3, 4.4, 5.5}));
    arrow::StringBuilder col_builder3;
    ARROW_RETURN_NOT_OK(col_builder3.AppendValues({"Tom", "Jerry", "Alice", "Bob", "Jack"}));

    std::shared_ptr<arrow::Array> col_array1;
    ARROW_RETURN_NOT_OK(col_builder1.Finish(&col_array1));
    std::shared_ptr<arrow::Array> col_array2;
    ARROW_RETURN_NOT_OK(col_builder2.Finish(&col_array2));
    std::shared_ptr<arrow::Array> col_array3;
    ARROW_RETURN_NOT_OK(col_builder3.Finish(&col_array3));
    std::shared_ptr<arrow::Schema> schema = arrow::schema({arrow::field("int_column", arrow::int64(), false),
                                                           arrow::field("double_column", arrow::float64(), false),
                                                           arrow::field("str_column", arrow::utf8(), false)});
    auto table = arrow::Table::Make(schema, {col_array1, col_array2, col_array3});

    // Write the table to a Parquet file
    std::string file_path = "data.parquet";
    std::shared_ptr<arrow::io::FileOutputStream> outfile;
    ARROW_RETURN_NOT_OK(arrow::io::FileOutputStream::Open(file_path).Value(&outfile));
    ARROW_RETURN_NOT_OK(parquet::arrow::WriteTable(*table, arrow::default_memory_pool(), outfile, 3));

    // Read the Parquet file back into a table
    std::shared_ptr<arrow::io::ReadableFile> infile;
    ARROW_RETURN_NOT_OK(arrow::io::ReadableFile::Open(file_path, arrow::default_memory_pool()).Value(&infile));

    std::unique_ptr<parquet::arrow::FileReader> reader;
    ARROW_RETURN_NOT_OK(parquet::arrow::OpenFile(infile, arrow::default_memory_pool(), &reader));

    std::shared_ptr<arrow::Table> read_table;
    ARROW_RETURN_NOT_OK(reader->ReadTable(&read_table));

    // Print the table to std::cout
    std::stringstream ss;
    ARROW_RETURN_NOT_OK(arrow::PrettyPrint(*read_table.get(), {}, &ss));
    std::cout << ss.str() << std::endl;

    return arrow::Status::OK();
}

int main() {
    auto status = execute();
    return 0;
}
```

```sh
gcc -o arrow_parquet_demo arrow_parquet_demo.cpp -lstdc++ -std=gnu++17 -larrow -lparquet
./arrow_parquet_demo
```

**Parquet demo with encryption:**

```cpp
#include <arrow/api.h>
#include <arrow/io/api.h>
#include <arrow/pretty_print.h>
#include <arrow/result.h>
#include <arrow/status.h>
#include <arrow/type_fwd.h>
#include <parquet/arrow/reader.h>
#include <parquet/arrow/writer.h>
#include <parquet/exception.h>

#include <filesystem>
#include <iostream>

arrow::Status execute(bool footer_plaintext, bool column_use_footer_key) {
    // Create a simple table
    arrow::Int64Builder int_col_builder;
    ARROW_RETURN_NOT_OK(int_col_builder.AppendValues({1, 2, 3, 4, 5}));
    arrow::DoubleBuilder double_col_builder;
    ARROW_RETURN_NOT_OK(double_col_builder.AppendValues({1.1, 2.2, 3.3, 4.4, 5.5}));
    arrow::StringBuilder str_col_builder;
    ARROW_RETURN_NOT_OK(str_col_builder.AppendValues({"Tom", "Jerry", "Alice", "Bob", "Jack"}));

    std::shared_ptr<arrow::Array> int_col_array;
    ARROW_RETURN_NOT_OK(int_col_builder.Finish(&int_col_array));
    std::shared_ptr<arrow::Array> double_col_array;
    ARROW_RETURN_NOT_OK(double_col_builder.Finish(&double_col_array));
    std::shared_ptr<arrow::Array> str_col_array;
    ARROW_RETURN_NOT_OK(str_col_builder.Finish(&str_col_array));
    std::shared_ptr<arrow::Schema> schema = arrow::schema({arrow::field("int_column", arrow::int64(), false),
                                                           arrow::field("double_column", arrow::float64(), false),
                                                           arrow::field("str_column", arrow::utf8(), false)});
    auto table = arrow::Table::Make(schema, {int_col_array, double_col_array, str_col_array});

    // Write the table to a Parquet file
    const std::string file_path = "data.parquet";
    std::shared_ptr<arrow::io::FileOutputStream> outfile;
    ARROW_RETURN_NOT_OK(arrow::io::FileOutputStream::Open(file_path).Value(&outfile));

    // Lenght of key must be 16 or 24 or 32
    const std::string footer_key = "footer_key______________";
    const std::string int_column_key = "int_column_key__________";
    const std::string double_column_key = "double_column_key_______";
    const std::string str_column_key = "str_column_key__________";

    parquet::FileEncryptionProperties::Builder file_encryption_props_builder(footer_key);
    file_encryption_props_builder.algorithm(parquet::ParquetCipher::AES_GCM_V1);
    if (footer_plaintext) {
        file_encryption_props_builder.set_plaintext_footer();
    }
    if (!column_use_footer_key) {
        parquet::ColumnPathToEncryptionPropertiesMap encrypted_columns;
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("int_column");
            column_encryption_props_builder.key(int_column_key);
        }
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("double_column");
            column_encryption_props_builder.key(double_column_key);
        }
        {
            parquet::ColumnEncryptionProperties::Builder column_encryption_props_builder("str_column");
            column_encryption_props_builder.key(str_column_key);
        }
        file_encryption_props_builder.encrypted_columns(encrypted_columns);
    }
    std::shared_ptr<parquet::FileEncryptionProperties> file_encryption_props = file_encryption_props_builder.build();
    std::shared_ptr<parquet::WriterProperties> write_props =
            parquet::WriterProperties::Builder().encryption(file_encryption_props)->build();

    ARROW_RETURN_NOT_OK(parquet::arrow::WriteTable(*table, arrow::default_memory_pool(), outfile, 3, write_props));

    // Read the Parquet file back into a table
    std::shared_ptr<arrow::io::ReadableFile> infile;
    ARROW_RETURN_NOT_OK(arrow::io::ReadableFile::Open(file_path, arrow::default_memory_pool()).Value(&infile));

    parquet::FileDecryptionProperties::Builder file_decryption_props_builder;
    // Why footer key required if set_plaintext_footer is called
    file_decryption_props_builder.footer_key(footer_key);
    if (!column_use_footer_key) {
        parquet::ColumnPathToDecryptionPropertiesMap decrypted_columns;
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("int_column");
            column_decryption_props_builder.key(int_column_key);
        }
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("double_column");
            column_decryption_props_builder.key(double_column_key);
        }
        {
            parquet::ColumnDecryptionProperties::Builder column_decryption_props_builder("str_column");
            column_decryption_props_builder.key(str_column_key);
        }
        file_decryption_props_builder.column_keys(decrypted_columns);
    }
    std::shared_ptr<parquet::FileDecryptionProperties> file_decryption_props = file_decryption_props_builder.build();

    parquet::ReaderProperties read_props;
    read_props.file_decryption_properties(file_decryption_props);
    parquet::arrow::FileReaderBuilder file_reader_builder;
    ARROW_RETURN_NOT_OK(file_reader_builder.Open(infile, read_props));
    std::unique_ptr<parquet::arrow::FileReader> reader;
    ARROW_RETURN_NOT_OK(file_reader_builder.Build(&reader));

    std::shared_ptr<arrow::Table> read_table;
    ARROW_RETURN_NOT_OK(reader->ReadTable(&read_table));

    // Print the table to std::cout
    std::stringstream ss;
    ARROW_RETURN_NOT_OK(arrow::PrettyPrint(*read_table.get(), {}, &ss));
    std::cout << ss.str() << std::endl;

    return arrow::Status::OK();
}

int main() {
    auto status = execute(false, false);
    if (!status.ok()) std::cout << status.message() << std::endl;

    status = execute(false, true);
    if (!status.ok()) std::cout << status.message() << std::endl;

    status = execute(true, false);
    if (!status.ok()) std::cout << status.message() << std::endl;

    status = execute(true, true);
    if (!status.ok()) std::cout << status.message() << std::endl;
    return 0;
}
```

```sh
gcc -o arrow_parquet_demo arrow_parquet_demo.cpp -lstdc++ -std=gnu++17 -larrow -lparquet
./arrow_parquet_demo
```

## 6.2 thrift

Requirement:

1. `libtool`
1. `bison`
1. `flex`
1. `openssl-devel`

```sh
git clone -b v0.16.0 https://github.com/apache/thrift.git
cd thrift

./bootstrap.sh
# you can build specific lib by using --with-xxx or --without-xxx
./configure --with-cpp=yes --with-java=no --with-python=no --with-py3=no --with-nodejs=no
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo make install

echo '/usr/local/lib' | sudo tee /etc/ld.so.conf.d/thrift.conf && sudo ldconfig
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

# 7 Independent Projects

## 7.1 Pocoproject

```sh
git clone -b poco-1.13.3-release https://github.com/pocoproject/poco.git
cd poco
cmake -B cmake-build
cmake --build cmake-build --config Release -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install cmake-build
```

### 7.1.1 Logger

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
#include <Poco/SplitterChannel.h>

int main() {
    {
        Poco::AutoPtr<Poco::ConsoleChannel> console_channel(new Poco::ConsoleChannel);
        Poco::AutoPtr<Poco::PatternFormatter> formatter(new Poco::PatternFormatter("%Y.%m.%d %H:%M:%S.%F <%p> %s: %t"));
        Poco::AutoPtr<Poco::FormattingChannel> formatting_channel(
                new Poco::FormattingChannel(formatter, console_channel));
        Poco::Logger::root().setLevel("trace");
        Poco::Logger::root().setChannel(formatting_channel);
        Poco::Logger::get("main_1").information("Hello, World!");
        Poco::Logger::get("main_2").information("Hello, World!");
    }
    {
        Poco::AutoPtr<Poco::FileChannel> file_channel(new Poco::FileChannel("sample.log"));
        file_channel->setProperty("rotation", "1 M");

        Poco::AutoPtr<Poco::PatternFormatter> formatter(new Poco::PatternFormatter("%Y-%m-%d %H:%M:%S %s: %t"));
        Poco::AutoPtr<Poco::FormattingChannel> formatting_channel(new Poco::FormattingChannel(formatter, file_channel));

        Poco::Logger& logger = Poco::Logger::create("FileLogger", formatting_channel, Poco::Message::PRIO_INFORMATION);
        logger.information("This is an informational message.");
        logger.warning("This is a warning message.");
    }
    {
        Poco::AutoPtr<Poco::ConsoleChannel> console_channel(new Poco::ConsoleChannel);

        Poco::AutoPtr<Poco::FileChannel> file_channel(new Poco::FileChannel("sample.log"));
        file_channel->setProperty("rotation", "1 M");

        Poco::AutoPtr<Poco::SplitterChannel> split_channel(new Poco::SplitterChannel);
        split_channel->addChannel(console_channel);
        split_channel->addChannel(file_channel);

        Poco::AutoPtr<Poco::PatternFormatter> formatter(new Poco::PatternFormatter("%Y-%m-%d %H:%M:%S %s: %t"));
        Poco::AutoPtr<Poco::FormattingChannel> formatting_channel(
                new Poco::FormattingChannel(formatter, split_channel));

        Poco::Logger& logger =
                Poco::Logger::create("MultiChannelLogger", formatting_channel, Poco::Message::PRIO_INFORMATION);
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
2024.05.30 08:23:56.061053 <Information> main_1: Hello, World!
2024.05.30 08:23:56.061093 <Information> main_2: Hello, World!
2024-05-30 08:23:56 MultiChannelLogger: This is an informational message.
2024-05-30 08:23:56 MultiChannelLogger: This is a warning message.
```

### 7.1.2 JSON

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

### 7.1.3 Http

```sh
mkdir poco_http_demo
cd poco_http_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(poco_http_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(Poco REQUIRED COMPONENTS Foundation Net Util)
target_link_libraries(${PROJECT_NAME} Poco::Foundation Poco::Net Poco::Util)
EOF

cat > poco_http_demo.cpp << 'EOF'
#include <Poco/Net/HTTPClientSession.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPRequestHandler.h>
#include <Poco/Net/HTTPRequestHandlerFactory.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/HTTPServer.h>
#include <Poco/Net/HTTPServerParams.h>
#include <Poco/Net/HTTPServerRequest.h>
#include <Poco/Net/HTTPServerResponse.h>
#include <Poco/Net/ServerSocket.h>
#include <Poco/StreamCopier.h>
#include <Poco/Util/ServerApplication.h>

#include <iostream>
#include <sstream>

class HelloRequestHandler : public Poco::Net::HTTPRequestHandler {
public:
    void handleRequest(Poco::Net::HTTPServerRequest& request, Poco::Net::HTTPServerResponse& response) override {
        std::cout << "Received request from: " << request.clientAddress().toString() << std::endl;

        response.setKeepAlive(request.getKeepAlive());
        response.setChunkedTransferEncoding(true);
        response.setContentType("text/html");

        std::ostream& ostr = response.send();
        ostr << "<html><head><title>Hello</title></head>";
        ostr << "<body><h1>Hello from Poco HTTP Server</h1></body></html>";
        ostr.flush();
    }
};

class HelloRequestHandlerFactory : public Poco::Net::HTTPRequestHandlerFactory {
public:
    Poco::Net::HTTPRequestHandler* createRequestHandler(const Poco::Net::HTTPServerRequest& request) override {
        return new HelloRequestHandler();
    }
};

class HTTPServerApp : public Poco::Util::ServerApplication {
protected:
    int main(const std::vector<std::string>& args) {
        Poco::Net::ServerSocket svs({"0.0.0.0", 9080}); // set the server port here
        /// Sets the following default values:
        ///   - timeout:              60 seconds
        ///   - keepAlive:            true
        ///   - maxKeepAliveRequests: 0
        ///   - keepAliveTimeout:     10 seconds
        Poco::Net::HTTPServer server(new HelloRequestHandlerFactory(), svs, new Poco::Net::HTTPServerParams());

        server.start();
        std::cout << "HTTP Server started on port 9080." << std::endl;

        // Wait for CTRL-C or kill
        waitForTerminationRequest();

        server.stop();
        return Application::EXIT_OK;
    }
};

int main(int argc, char** argv) {
    std::thread server_thread([argc, argv]() {
        HTTPServerApp app;
        app.run(argc, argv);
    });

    std::this_thread::sleep_for(std::chrono::seconds(1));

    Poco::Net::HTTPClientSession session("127.0.0.1", 9080);
    session.setKeepAlive(true);

    {
        // First request
        Poco::Net::HTTPRequest request(Poco::Net::HTTPRequest::HTTP_GET, "/");
        request.setKeepAlive(true);
        session.sendRequest(request);

        Poco::Net::HTTPResponse response;
        std::istream& response_body_is = session.receiveResponse(response);

        std::string response_body;
        Poco::StreamCopier::copyToString(response_body_is, response_body);

        std::cout << response_body << std::endl;
    }

    {
        // Second request reuse the same session
        Poco::Net::HTTPRequest request(Poco::Net::HTTPRequest::HTTP_GET, "/");
        session.sendRequest(request);

        Poco::Net::HTTPResponse response;
        std::istream& response_body_is = session.receiveResponse(response);

        std::string response_body;
        Poco::StreamCopier::copyToString(response_body_is, response_body);

        std::cout << response_body << std::endl;
    }

    server_thread.join();
    return 0;
}
EOF

cmake -B build
cmake --build build
build/poco_http_demo
```

Output:

```
HTTP Server started on port 9080.
<html><head><title>Hello</title></head><body><h1>Hello from Poco HTTP Server</h1></body></html>
^C
```

### 7.1.4 Application

```sh
mkdir poco_application_demo
cd poco_application_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(poco_application_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

find_package(Poco REQUIRED COMPONENTS Foundation Util)
target_link_libraries(${PROJECT_NAME} Poco::Foundation Poco::Util)
EOF

cat > poco_application_demo.cpp << 'EOF'
#include <Poco/Util/Application.h>
#include <Poco/Util/HelpFormatter.h>
#include <Poco/Util/Option.h>
#include <Poco/Util/OptionSet.h>

#include <iostream>

class DemoApp : public Poco::Util::Application {
protected:
    void initialize(Application& self) {
        loadConfiguration();
        Application::initialize(self);
    }

    void uninitialize() { Application::uninitialize(); }

    void defineOptions(Poco::Util::OptionSet& options) {
        Application::defineOptions(options);

        options.addOption(Poco::Util::Option("help", "h", "display help information")
                                  .required(false)
                                  .repeatable(false)
                                  .callback(Poco::Util::OptionCallback<DemoApp>(this, &DemoApp::handleHelp)));

        options.addOption(Poco::Util::Option("config-file", "C", "path of configuration file")
                                  .required(false)
                                  .repeatable(false)
                                  .argument("<file>")
                                  .binding("config-file"));
    }

    void handleHelp(const std::string& name, const std::string& value) {
        _is_help = true;
        Poco::Util::HelpFormatter helpFormatter(options());
        helpFormatter.setCommand(commandName());
        helpFormatter.setUsage("OPTIONS");
        helpFormatter.setHeader("A simple command line application that demonstrates parsing options with POCO.");
        helpFormatter.format(std::cout);
        stopOptionsProcessing();
    }

    int main(const std::vector<std::string>& args) {
        if (_is_help) {
            return Application::EXIT_OK;
        }
        std::cout << "config-file: " << config().getString("config-file", "unknow") << std::endl;
        return Application::EXIT_OK;
    }

private:
    bool _is_help = false;
};

POCO_APP_MAIN(DemoApp)
EOF

cmake -B build
cmake --build build
build/poco_application_demo --help
# --config is not ambiguous, so it can be parsed to --config-file
build/poco_application_demo --config /etc/config.xml
build/poco_application_demo --config-file /etc/config.xml
```

Output:

```
usage: poco_application_demo OPTIONS
A simple command line application that demonstrates parsing options with POCO.

-h, --help                      display help information
-C<file>, --config-file=<file>  path of configuration file
config-file: /etc/config.xml
```

## 7.2 sqlpp11

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

### 7.2.1 With Sqlite

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
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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

### 7.2.2 With Mysql

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
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
build/sqlpp11_demo
```

### 7.2.3 With Mariadb

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
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
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

## 7.3 libcurl

* [command line tool and library for transferring data with URLs (since 1998)](https://curl.se/)
    * [The libcurl API](https://curl.se/libcurl/c/)
* [github-curl](https://github.com/curl/curl)

```sh
tree -L 2
.
├── CMakeLists.txt
├── contrib
│   ├── curl-8.8.0
│   └── curl-8.8.0.tar.gz
└── main.cpp
```

```sh
mkdir curl_demo && cd curl_demo

# Download source code of these two project
mkdir -p contrib
wget -O contrib/curl-8.8.0.tar.gz https://curl.se/download/curl-8.8.0.tar.gz
tar -zxf contrib/curl-8.8.0.tar.gz -C contrib

# CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(curl_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(${PROJECT_NAME} main.cpp)

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

# Include subdirectories
add_subdirectory(contrib/curl-8.8.0)

# Link against libraries
target_link_libraries(${PROJECT_NAME} CURL::libcurl)
EOF

cat > main.cpp << 'EOF'
#include <curl/curl.h>

#include <iostream>
#include <string>

// This callback function gets called by libcurl as soon as there is data received that needs to be saved.
// The size of the data pointed to by *ptr is size multiplied by nmemb, it will not be zero terminated.
// Return the number of bytes actually taken care of.
// If that amount differs from the amount passed to your function, it'll signal an error to the library.
size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

int main() {
    CURL* curl;
    CURLcode res;
    std::string readBuffer;

    // Initialize a CURL session
    curl = curl_easy_init();
    if (!curl) {
        std::cerr << "Failed to initialize CURL session" << std::endl;
        return 1;
    }

    struct curl_slist* headers = NULL; // Initialize header list
    headers = curl_slist_append(headers, "Content-Type: application/json");
    headers = curl_slist_append(headers, "Custom-Header: CustomValue");

    // Set the URL for the request
    curl_easy_setopt(curl, CURLOPT_URL, "http://jsonplaceholder.typicode.com/posts");

    // Set the custom headers
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

    // Set the callback function to save the data
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    // Set the data pointer to save the response
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);

    // Perform the HTTP request
    res = curl_easy_perform(curl);
    if (res != CURLE_OK) {
        std::cerr << "curl_easy_perform() failed: " << curl_easy_strerror(res) << std::endl;
    } else {
        std::cout << readBuffer << std::endl;
    }

    // Cleanup header list
    curl_slist_free_all(headers);
    // Cleanup CURL session
    curl_easy_cleanup(curl);

    return 0;
}
EOF

# compile and run
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
build/curl_demo
```

**Tips:**

* According to [Can I use libcurls CURLOPT_WRITEFUNCTION with a C++11 lambda expression?](https://stackoverflow.com/questions/6624667/can-i-use-libcurls-curlopt-writefunction-with-a-c11-lambda-expression), if you want to use lambda expression as the callback function, then declare the lambda with `+` before empty capture list `[]`, which is `+[]`

# 8 Assorted

1. [Awesome C++ Projects](https://github.com/fffaraz/awesome-cpp)
1. [parallel-hashmap](https://github.com/greg7mdp/parallel-hashmap)：`parallel-hashmap`提供了一组高性能、并发安全的`map`，用于替换`std`以及`boost`中的`map`
    * [phmap_gdb.py](https://github.com/greg7mdp/parallel-hashmap/blob/master/phmap_gdb.py)
1. [cpp-httplib](https://github.com/yhirose/cpp-httplib)：`cpp-httplib`以头文件的方式提供`http`协议的相关支持
1. [json](https://github.com/nlohmann/json)：`json`库
1. [libfiu(Failure Injection Unit)](https://blitiri.com.ar/p/libfiu/)：错误注入
1. bison: Parser
