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

cmake -B build && cmake --build build && build/boost_demo
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
sudo cmake --install build && sudo ldconfig
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
sudo cmake --install build && sudo ldconfig
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
sudo cmake --install build && sudo ldconfig
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
sudo cmake --install build && sudo ldconfig
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
sudo cmake --install build && sudo ldconfig
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
sudo cmake --install build && sudo ldconfig

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

# 7 JNI

[Chapter 4: JNI Functions](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/functions.html)

* `PushLocalFrame`/`PopLocalFrame`: Manage local reference automatically
* `NewGlobalRef`/`DeleteGlobalRef`: Create/Delete global reference manually, this cannot be managed by `PushLocalFrame`/`PopLocalFrame`
* `DeleteLocalRef`: Delete local reference manually created by java function or jni API

## 7.1 Example

### 7.1.1 Hello World

```sh
mkdir -p jni_demo/build
cd jni_demo
cat > HelloWorld.java << 'EOF'
public class HelloWorld {
    public void greet() {
        System.out.println("Hello from Java!");
    }

    public static void main(String[] args) {
        new HelloWorld().greet();
    }
}
EOF

cat > jni_demo.cpp << 'EOF'
#include <jni.h>

#include <iostream>

int main() {
    JavaVM* jvm;
    JNIEnv* env;
    JavaVMInitArgs vm_args;
    JavaVMOption options[1];
    options[0].optionString = (char*)("-Djava.class.path=./");
    vm_args.version = JNI_VERSION_1_8;
    vm_args.nOptions = 1;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;

    // Load and initialize a Java VM, return a JNI interface pointer in env
    jint res = JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
    if (res != JNI_OK) {
        std::cerr << "Failed to create JVM" << std::endl;
        return 1;
    }

    // Verify JVM version
    jint ver = env->GetVersion();
    std::cout << "JVM version: " << ((ver >> 16) & 0x0f) << "." << (ver & 0x0f) << std::endl;

    // Get Class
    jclass cls = env->FindClass("HelloWorld");
    if (cls == nullptr) {
        std::cerr << "Failed to find class" << std::endl;
        jvm->DestroyJavaVM();
        return 1;
    }

    // Get Method
    jmethodID mid = env->GetMethodID(cls, "greet", "()V");
    if (mid == nullptr) {
        std::cerr << "Failed to find method" << std::endl;
        // Print the exception stack trace
        if (env->ExceptionOccurred()) {
            env->ExceptionDescribe();
        }

        jvm->DestroyJavaVM();
        return 1;
    }

    // Create Instance
    jobject obj = env->AllocObject(cls);
    if (obj == nullptr) {
        std::cerr << "Failed to create object" << std::endl;
        jvm->DestroyJavaVM();
        return 1;
    }

    // Invoke
    env->CallVoidMethod(obj, mid);

    // Destroy
    jvm->DestroyJavaVM();

    return 0;
}
EOF

javac HelloWorld.java

# libjvm.so may be in (${JAVA_HOME}/lib/server, ${JAVA_HOME}/jre/lib/amd64/server)
JVM_SO_PATH=$(find $(readlink -f ${JAVA_HOME}) -name "libjvm.so")
JVM_SO_PATH=${JVM_SO_PATH%/*}

# Compile way 1 (Please set JAVA_HOME first)
gcc -o build/jni_demo jni_demo.cpp -I"${JAVA_HOME}/include" -I"${JAVA_HOME}/include/linux" -L"${JVM_SO_PATH}" -lstdc++ -std=gnu++17 -ljvm && LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_demo

# Compile way 2 (Please set JAVA_HOME first)
C_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${C_INCLUDE_PATH} \
CPLUS_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${CPLUS_INCLUDE_PATH} \
LIBRARY_PATH=${JVM_SO_PATH}:${LIBRARY_PATH} \
gcc -o build/jni_demo jni_demo.cpp -lstdc++ -std=gnu++17 -ljvm && LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_demo
```

Output:

```
JVM version: 10.0
Hello from Java!
```

**Tips:**

* Cannot find class: Maybe the javac version is greater than the jvm, double check that.

**Cmake Example: (Share the same `main.cpp` as above)**

```sh
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(jni_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

set(JAVA_HOME $ENV{JAVA_HOME})
if("${JAVA_HOME}" STREQUAL "")
    message(FATAL_ERROR "env 'JAVA_HOME' is required")
endif()
# For high jdk version
file(GLOB LIB_JVM ${JAVA_HOME}/lib/server/libjvm.so)
if("${LIB_JVM}" STREQUAL "")
    # For low jdk version
    file(GLOB_RECURSE LIB_JVM ${JAVA_HOME}/jre/lib/*/server/libjvm.so)
    if("${LIB_JVM}" STREQUAL "")
    message(FATAL_ERROR "cannot find libjvm.so in ${JAVA_HOME}")
    endif()
endif()
add_library(jvm SHARED IMPORTED)
set_target_properties(jvm PROPERTIES IMPORTED_LOCATION ${LIB_JVM})
target_include_directories(jvm INTERFACE ${JAVA_HOME}/include)
target_include_directories(jvm INTERFACE ${JAVA_HOME}/include/linux)

target_link_libraries(${PROJECT_NAME} PRIVATE jvm)
EOF

rm -rf build
cmake -B build && cmake --build build && build/jni_demo
```

### 7.1.2 Memory Leak

**Observations:**

* The local ref return by java function must be manually released, otherwise OOM may occur

```sh
mkdir -p jni_memory_leak_demo/build
cd jni_memory_leak_demo

cat > MemoryAllocator.java << 'EOF'
public class MemoryAllocator {
    public byte[] allocateMemory(int size) {
        return new byte[size];
    }
}
EOF

cat > jni_memory_leak_demo.cpp << 'EOF'
#include <jni.h>

#include <chrono>
#include <fstream>
#include <iostream>
#include <thread>

constexpr const char* CURSOR_UP = "\033[F";

#define ASSERT_TRUE(expr)                                                                      \
    do {                                                                                       \
        if (!(expr)) {                                                                         \
            std::cerr << "(LINE:" << __LINE__ << ") Assertion failed: " << #expr << std::endl; \
            if (env->ExceptionOccurred()) {                                                    \
                env->ExceptionDescribe();                                                      \
            }                                                                                  \
            jvm->DestroyJavaVM();                                                              \
            exit(1);                                                                           \
            __builtin_unreachable();                                                           \
        }                                                                                      \
    } while (0)

int main(int argc, char* argv[]) {
    const std::string help =
            "Usage: " + std::string(argv[0]) + " <alloc_by_cpp|alloc_by_java> <keep|release> [<use_frame>]";
    if (argc < 3) {
        std::cerr << help << std::endl;
        return 1;
    }
    if (std::string(argv[1]) != "alloc_by_cpp" && std::string(argv[1]) != "alloc_by_java") {
        std::cerr << help << std::endl;
        return 1;
    }
    if (std::string(argv[2]) != "keep" && std::string(argv[2]) != "release") {
        std::cerr << help << std::endl;
        return 1;
    }
    if (argc == 4 && std::string(argv[3]) != "use_frame") {
        std::cerr << help << std::endl;
        return 1;
    }
    const bool alloc_by_cpp = (std::string(argv[1]) == "alloc_by_cpp");
    const bool keep_memory = (std::string(argv[2]) == "keep");
    const bool use_frame = (argc == 4 && std::string(argv[3]) == "use_frame");

    JavaVM* jvm;
    JNIEnv* env;
    JavaVMInitArgs vm_args;
    JavaVMOption options[2];
    options[0].optionString = (char*)("-Djava.class.path=./");
    options[1].optionString = (char*)("-Xmx1g");
    vm_args.version = JNI_VERSION_1_8;
    vm_args.nOptions = 2;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;

    jint res = JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
    ASSERT_TRUE(res == JNI_OK);

    jint version = env->GetVersion();
    std::cout << "JVM version: " << ((version >> 16) & 0x0f) << "." << (version & 0x0f) << std::endl;

    jclass cls = env->FindClass("MemoryAllocator");
    ASSERT_TRUE(cls != nullptr);

    jmethodID m_allocate_memory = env->GetMethodID(cls, "allocateMemory", "(I)[B");
    ASSERT_TRUE(m_allocate_memory != nullptr);

    jobject obj_memory_allocator = env->AllocObject(cls);
    ASSERT_TRUE(obj_memory_allocator != nullptr);

    auto start = std::chrono::steady_clock::now();
    while (true) {
        if (!keep_memory && use_frame) {
            env->PushLocalFrame(1);
        }
        const size_t _10M = 10 * 1024 * 1024;
        jobject bytes = alloc_by_cpp ? env->NewByteArray(_10M)
                                     : env->CallObjectMethod(obj_memory_allocator, m_allocate_memory, _10M);
        ASSERT_TRUE(bytes != nullptr);
        if (!keep_memory) {
            if (use_frame) {
                env->PopLocalFrame(nullptr);
            } else {
                env->DeleteLocalRef(bytes);
            }
        }

        std::ifstream iff("/proc/self/status");
        std::string line;

        std::string vm_size;
        std::string vm_rss;
        std::string vm_hwm;
        while (std::getline(iff, line)) {
            if (line.find("VmSize") != std::string::npos) {
                vm_size = line;
            }
            if (line.find("VmRSS") != std::string::npos) {
                vm_rss = line;
            }
            if (line.find("VmHWM") != std::string::npos) {
                vm_hwm = line;
            }
        }
        std::cout << "Memory Status:" << std::endl;
        std::cout << "    " << vm_size << std::endl;
        std::cout << "    " << vm_rss << std::endl;
        std::cout << "    " << vm_hwm << std::endl;

        std::this_thread::sleep_for(std::chrono::milliseconds(10));

        if (std::chrono::duration_cast<std::chrono::seconds>(std::chrono::steady_clock::now() - start).count() > 5) {
            break;
        }

        // Move cursor up
        std::cout << CURSOR_UP << CURSOR_UP << CURSOR_UP << CURSOR_UP;
    }

    jvm->DestroyJavaVM();

    return 0;
}
EOF

javac MemoryAllocator.java

# libjvm.so may be in (${JAVA_HOME}/lib/server, ${JAVA_HOME}/jre/lib/amd64/server)
JVM_SO_PATH=$(find $(readlink -f ${JAVA_HOME}) -name "libjvm.so")
JVM_SO_PATH=${JVM_SO_PATH%/*}

C_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${C_INCLUDE_PATH} \
CPLUS_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${CPLUS_INCLUDE_PATH} \
LIBRARY_PATH=${JVM_SO_PATH}:${LIBRARY_PATH} \
gcc -o build/jni_memory_leak_demo jni_memory_leak_demo.cpp -lstdc++ -std=gnu++17 -ljvm

LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_memory_leak_demo alloc_by_cpp keep
LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_memory_leak_demo alloc_by_cpp release use_frame
LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_memory_leak_demo alloc_by_java keep use_frame
LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_memory_leak_demo alloc_by_java release
```

### 7.1.3 Work With Spring fat-jar

**JNI cannot work smoothly with fat-jar built by plugin `spring-boot-maven-plugin`. Because the class path is started with `BOOT-INF/` or `BOOT-INF/lib/`, the default classloader cannot find it.**

**The following code can work with `org.springframework.boot:spring-boot-maven-plugin:2.1.4.RELEASE`, no guarantee that it can work with other versions because the Java API may vary.**

```sh
mkdir -p jni_spring_fat_jar_demo/build
cd jni_spring_fat_jar_demo

mkdir -p java
pushd java

mkdir -p src/main/java/org/liuyehcf
cat > src/main/java/org/liuyehcf/Main.java << 'EOF'
package org.liuyehcf;

public class Main {
    public static void main(String[] args) {

    }
}
EOF

cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.liuyehcf</groupId>
    <artifactId>test-spring-fatjar</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <hadoop.version>3.4.0</hadoop.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs-client</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>2.1.4.RELEASE</version>
                <configuration>
                    <mainClass>org.liuyehcf.Main</mainClass>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
EOF

mvn clean package -DskipTests

popd

cat > jni_spring_fat_jar_demo.cpp << 'EOF'
#include <jni.h>

#include <cstring>
#include <iostream>
#include <sstream>

#define ASSERT_TRUE(expr)                                                                                    \
    do {                                                                                                     \
        if (!(expr)) {                                                                                       \
            std::cerr << "(" << __FILE__ << ":" << __LINE__ << ") Assertion failed: " << #expr << std::endl; \
            if (env->ExceptionOccurred()) {                                                                  \
                env->ExceptionDescribe();                                                                    \
            }                                                                                                \
            jvm->DestroyJavaVM();                                                                            \
            exit(1);                                                                                         \
            __builtin_unreachable();                                                                         \
        }                                                                                                    \
    } while (0)

#define TOKEN_CONCAT(x, y) x##y
#define TOKEN_CONCAT_FWD(x, y) TOKEN_CONCAT(x, y)
#define DEFER(expr) [[maybe_unused]] Defer TOKEN_CONCAT_FWD(defer_, __LINE__)([&]() { expr; })
#define LOCAL_REF_GUARD(obj) DEFER(if (obj != nullptr) { env->DeleteLocalRef(obj); })

template <typename T>
class Defer {
public:
    Defer(T&& t) : t(std::forward<T>(t)) {}
    ~Defer() { t(); }

private:
    T t;
};

class ClassLoader {
public:
    virtual jclass load_class(const char* class_name) = 0;
    virtual ~ClassLoader() {}
};

class NormalClassLoader : public ClassLoader {
public:
    NormalClassLoader(JavaVM* jvm_, JNIEnv* env_) : jvm(jvm_), env(env_) {
        std::cout << "Using NormalClassLoader" << std::endl;
    }
    ~NormalClassLoader() override {}

    jclass load_class(const char* class_name) override {
        jclass cls = env->FindClass(class_name);
        ASSERT_TRUE(cls != nullptr);
        return cls;
    }

private:
    JavaVM* jvm;
    JNIEnv* env;
};

class SpringClassLoader : public ClassLoader {
public:
    SpringClassLoader(JavaVM* jvm_, JNIEnv* env_) : jvm(jvm_), env(env_) {
        std::cout << "Using SpringClassLoader" << std::endl;
        init_fat_jar_class_loader();
    }
    ~SpringClassLoader() override {
        if (jgspring_class_loader != nullptr) env->DeleteGlobalRef(jgspring_class_loader);
    }

    jclass load_class(const char* class_name) override {
        jstring jclass_name = env->NewStringUTF(class_name);
        LOCAL_REF_GUARD(jclass_name);
        jclass cls =
                static_cast<jclass>(env->CallObjectMethod(jgspring_class_loader, m_spring_load_class, jclass_name));
        ASSERT_TRUE(cls != nullptr);
        return cls;
    }

private:
    /*
     * Spring API may vary from time to time, I'm not sure if this code can work well with other spring versions
     *
     * For 2.1.4.RELEASE
     * https://github.com/spring-projects/spring-boot/blob/v2.1.4.RELEASE/spring-boot-project/spring-boot-tools/spring-boot-loader/src/main/java/org/springframework/boot/loader/Launcher.java
     *
     * protected void launch(String[] args) {
     *     try {
     *         JarFile.registerUrlProtocolHandler();
     *         ClassLoader classLoader = createClassLoader(getClassPathArchives());
     *         launch(args, getMainClass(), classLoader);
     *     }
     *     catch (Exception ex) {
     *         ex.printStackTrace();
     *         System.exit(1);
     *     }
     * }
     */
    void init_fat_jar_class_loader() {
        jclass cls_jar_launcher = env->FindClass("org/springframework/boot/loader/JarLauncher");
        ASSERT_TRUE(cls_jar_launcher != nullptr);
        LOCAL_REF_GUARD(cls_jar_launcher);

        jmethodID m_jar_launcher_init = env->GetMethodID(cls_jar_launcher, "<init>", "()V");
        ASSERT_TRUE(m_jar_launcher_init != nullptr);
        jmethodID m_get_class_path_archives =
                env->GetMethodID(cls_jar_launcher, "getClassPathArchives", "()Ljava/util/List;");
        ASSERT_TRUE(m_get_class_path_archives != nullptr);
        jmethodID m_create_class_loader =
                env->GetMethodID(cls_jar_launcher, "createClassLoader", "(Ljava/util/List;)Ljava/lang/ClassLoader;");
        ASSERT_TRUE(m_create_class_loader != nullptr);

        // Create JarLauncher instance
        jobject jar_launcher = env->NewObject(cls_jar_launcher, m_jar_launcher_init);
        ASSERT_TRUE(jar_launcher != nullptr);
        LOCAL_REF_GUARD(jar_launcher);

        // Call JarLauncher.getClassPathArchives()
        jobject jarchives = env->CallObjectMethod(jar_launcher, m_get_class_path_archives);
        ASSERT_TRUE(jarchives != nullptr);
        LOCAL_REF_GUARD(jarchives);

        // Call JarLauncher.createClassLoader(jarchives)
        jobject jspring_class_loader = env->CallObjectMethod(jar_launcher, m_create_class_loader, jarchives);
        ASSERT_TRUE(jspring_class_loader != nullptr);
        LOCAL_REF_GUARD(jspring_class_loader);

        this->jgspring_class_loader = env->NewGlobalRef(jspring_class_loader);

        jclass cls_spring_class_loader = env->GetObjectClass(jgspring_class_loader);
        ASSERT_TRUE(cls_spring_class_loader != nullptr);
        LOCAL_REF_GUARD(cls_spring_class_loader);

        this->m_spring_load_class =
                env->GetMethodID(cls_spring_class_loader, "loadClass", "(Ljava/lang/String;)Ljava/lang/Class;");
        ASSERT_TRUE(m_spring_load_class != nullptr);
    }

private:
    JavaVM* jvm;
    JNIEnv* env;
    jobject jgspring_class_loader;
    jmethodID m_spring_load_class;
};

int main(int argc, char* argv[]) {
    const std::string usage = "Usage: " + std::string(argv[0]) + " <normal|spring> <fat_jar_path> <class_name>";
    if (argc < 4 || (std::strcmp(argv[1], "normal") != 0 && std::strcmp(argv[1], "spring") != 0)) {
        std::cerr << usage << std::endl;
        return 1;
    }
    const bool normal_mode = std::strcmp(argv[1], "normal") == 0;
    const char* jar_path = argv[2];
    const std::string class_names = argv[3];

    JavaVM* jvm;
    JNIEnv* env;
    JavaVMInitArgs vm_args;
    JavaVMOption options[1];
    std::string class_path = std::string("-Djava.class.path=").append(jar_path);
    options[0].optionString = const_cast<char*>(class_path.c_str());
    vm_args.version = JNI_VERSION_1_8;
    vm_args.nOptions = 1;
    vm_args.options = options;
    vm_args.ignoreUnrecognized = false;

    jint res = JNI_CreateJavaVM(&jvm, (void**)&env, &vm_args);
    ASSERT_TRUE(res == JNI_OK);
    DEFER(jvm->DestroyJavaVM());

    ClassLoader* loader;
    if (normal_mode) {
        loader = new NormalClassLoader(jvm, env);
    } else {
        loader = new SpringClassLoader(jvm, env);
    }
    DEFER(delete loader);

    std::istringstream class_names_is(class_names);
    std::string class_name;
    while (std::getline(class_names_is, class_name, ',')) {
        jclass cls = loader->load_class(class_name.c_str());
        ASSERT_TRUE(cls != nullptr);
        std::cout << "    Find class: " << class_name << std::endl;
        LOCAL_REF_GUARD(cls);
    }

    return 0;
}
EOF

# libjvm.so may be in (${JAVA_HOME}/lib/server, ${JAVA_HOME}/jre/lib/amd64/server)
JVM_SO_PATH=$(find $(readlink -f ${JAVA_HOME}) -name "libjvm.so")
JVM_SO_PATH=${JVM_SO_PATH%/*}

C_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${C_INCLUDE_PATH} \
CPLUS_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${CPLUS_INCLUDE_PATH} \
LIBRARY_PATH=${JVM_SO_PATH}:${LIBRARY_PATH} \
gcc -o build/jni_spring_fat_jar_demo jni_spring_fat_jar_demo.cpp -lstdc++ -std=gnu++17 -ljvm

LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_spring_fat_jar_demo normal java/target/test-spring-fatjar.jar org.apache.hadoop.fs.LocalFileSystem
LD_LIBRARY_PATH=${JVM_SO_PATH} build/jni_spring_fat_jar_demo spring java/target/test-spring-fatjar.jar org.apache.hadoop.fs.LocalFileSystem,org.liuyehcf.Main
```

## 7.2 libhdfs

[hadoop-libhdfs](https://github.com/apache/hadoop/tree/trunk/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs)

**`getJNIEnv`:**

* Each thread must have its own instance. Sharing this between different threads may cause unexpected issues

```cpp
/**
 * getJNIEnv: A helper function to get the JNIEnv* for the given thread.
 * If no JVM exists, then one will be created. JVM command line arguments
 * are obtained from the LIBHDFS_OPTS environment variable.
 *
 * Implementation note: we rely on POSIX thread-local storage (tls).
 * This allows us to associate a destructor function with each thread, that
 * will detach the thread from the Java VM when the thread terminates.  If we
 * failt to do this, it will cause a memory leak.
 *
 * However, POSIX TLS is not the most efficient way to do things.  It requires a
 * key to be initialized before it can be used.  Since we don't know if this key
 * is initialized at the start of this function, we have to lock a mutex first
 * and check.  Luckily, most operating systems support the more efficient
 * __thread construct, which is initialized by the linker.
 *
 * @param: None.
 * @return The JNIEnv* corresponding to the thread.
 */
JNIEnv* getJNIEnv(void)
```

**Build libhdfs:** You need to download [hadoop](https://github.com/apache/hadoop) somewhere(this works well with tag `rel/release-3.4.0`), and set project path to env `export HADOOP_PATH=/path/to/hadoop`. And we need to comment out some of the hdfs classes initialization code if we don't need hdfs:

```diff
diff --git a/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs/jni_helper.c b/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs/jni_helper.c
index 8f00a08b..797b0a82 100644
--- a/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs/jni_helper.c
+++ b/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs/jni_helper.c
@@ -745,16 +745,6 @@ static JNIEnv* getGlobalJNIEnv(void)
                     "with error: %d\n", rv);
             return NULL;
         }
-
-        // We use findClassAndInvokeMethod here because the jclasses in
-        // jclasses.h have not loaded yet
-        jthr = findClassAndInvokeMethod(env, NULL, STATIC, NULL, HADOOP_FS,
-                "loadFileSystems", "()V");
-        if (jthr) {
-            printExceptionAndFree(env, jthr, PRINT_EXC_ALL,
-                    "FileSystem: loadFileSystems failed");
-            return NULL;
-        }
     } else {
         //Attach this thread to the VM
         vm = vmBuf[0];
@@ -832,12 +822,6 @@ JNIEnv* getJNIEnv(void)
     }

     jthrowable jthr = NULL;
-    jthr = initCachedClasses(state->env);
-    if (jthr) {
-      printExceptionAndFree(state->env, jthr, PRINT_EXC_ALL,
-                            "initCachedClasses failed");
-      goto fail;
-    }
     return state->env;

 fail:
```

```sh
mkdir -p libhdfs_jni
cd libhdfs_jni

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.16)

project(hdfs_jni)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(HADOOP_PATH $ENV{HADOOP_PATH})
if("${HADOOP_PATH}" STREQUAL "")
    message(FATAL_ERROR "env 'HADOOP_PATH' is required")
endif()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall")

# Add target library
set(LIBHDFS_PATH ${HADOOP_PATH}/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfs)
file(GLOB LIBHDFS_SOURCES "${LIBHDFS_PATH}/*.c" "${LIBHDFS_PATH}/os/posix/*.c")
message(STATUS "LIBHDFS_SOURCES: ${LIBHDFS_SOURCES}")
add_library(${PROJECT_NAME} ${LIBHDFS_SOURCES})
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_SOURCE_DIR}/include # for empty config.h
    ${LIBHDFS_PATH}
    ${LIBHDFS_PATH}/include
    ${LIBHDFS_PATH}/os
    ${LIBHDFS_PATH}/os/posix)

# Add x-platform dependency
add_definitions(-DUSE_X_PLATFORM_DIRENT)
set(X_PLATFORM_PATH ${HADOOP_PATH}/hadoop-hdfs-project/hadoop-hdfs-native-client/src/main/native/libhdfspp/lib/x-platform)
target_include_directories(${PROJECT_NAME} PRIVATE
    ${X_PLATFORM_PATH}/..)

# Dependency jvm
set(JAVA_HOME $ENV{JAVA_HOME})
if("${JAVA_HOME}" STREQUAL "")
    message(FATAL_ERROR "env 'JAVA_HOME' is required")
endif()
# For high jdk version
file(GLOB LIB_JVM ${JAVA_HOME}/lib/server/libjvm.so)
if("${LIB_JVM}" STREQUAL "")
    # For low jdk version
    file(GLOB_RECURSE LIB_JVM ${JAVA_HOME}/jre/lib/*/server/libjvm.so)
    if("${LIB_JVM}" STREQUAL "")
    message(FATAL_ERROR "cannot find libjvm.so in ${JAVA_HOME}")
    endif()
endif()
add_library(jvm SHARED IMPORTED)
set_target_properties(jvm PROPERTIES IMPORTED_LOCATION ${LIB_JVM})
target_include_directories(jvm INTERFACE ${JAVA_HOME}/include)
target_include_directories(jvm INTERFACE ${JAVA_HOME}/include/linux)
target_link_libraries(${PROJECT_NAME} PRIVATE jvm)
EOF

mkdir include
touch include/config.h

cmake -B build && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
```

And we can use `build/libhdfs_jni.a` as following:

```sh
cat > libhdfs_jni_demo.cpp << 'EOF'
#include <jni.h>

#include <iostream>
#include <thread>
#include <vector>

extern "C" JNIEnv* getJNIEnv(void);

#define ASSERT(expr)                    \
    if (!(expr)) {                      \
        if (env->ExceptionOccurred()) { \
            env->ExceptionDescribe();   \
            exit(1);                    \
        }                               \
    }

int main() {
    std::vector<std::thread> threads;
    for (int i = 0; i < 10; ++i) {
        threads.emplace_back([i]() {
            auto* env = getJNIEnv();

            // Get java.lang.System
            jclass cls_system = env->FindClass("java/lang/System");
            ASSERT(cls_system != nullptr);

            // Get out field
            jfieldID f_out = env->GetStaticFieldID(cls_system, "out", "Ljava/io/PrintStream;");
            jobject obj_out = env->GetStaticObjectField(cls_system, f_out);

            // Get Class
            jclass cls_stream = env->FindClass("java/io/PrintStream");
            ASSERT(cls_stream != nullptr);

            // Get Method
            jmethodID m_println = env->GetMethodID(cls_stream, "println", "(Ljava/lang/String;)V");
            ASSERT(m_println != nullptr);

            // Invoke
            std::string content = "Hello world, this is thread: " + std::to_string(i);
            jstring jcontent = env->NewStringUTF(const_cast<const char*>((content).c_str()));
            env->CallVoidMethod(obj_out, m_println, jcontent);
            env->DeleteLocalRef(jcontent);
        });
    }
    for (int i = 0; i < 10; ++i) {
        threads[i].join();
    }

    return 0;
}
EOF

# libjvm.so may be in (${JAVA_HOME}/lib/server, ${JAVA_HOME}/jre/lib/amd64/server)
JVM_SO_PATH=$(find $(readlink -f ${JAVA_HOME}) -name "libjvm.so")
JVM_SO_PATH=${JVM_SO_PATH%/*}

C_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${C_INCLUDE_PATH} \
CPLUS_INCLUDE_PATH=${JAVA_HOME}/include:${JAVA_HOME}/include/linux:${CPLUS_INCLUDE_PATH} \
LIBRARY_PATH=${JVM_SO_PATH}:${LIBRARY_PATH} \
gcc -o build/libhdfs_jni_demo libhdfs_jni_demo.cpp -lstdc++ -std=gnu++17 -Lbuild -lhdfs_jni -ljvm -lpthread && LD_LIBRARY_PATH=${JVM_SO_PATH} CLASSPATH= build/libhdfs_jni_demo
```

## 7.3 Tips

### 7.3.1 Tricky JVM options

1. `-Djdk.lang.processReaperUseDefaultStackSize=true`
    * [JDK-8130425 : libjvm crash due to stack overflow in executables with 32k tbss/tdata](https://bugs.java.com/bugdatabase/view_bug?bug_id=8130425)
    * [JDK-8316968 : Add an option that allows to set the stack size of Process reaper threads](https://bugs.java.com/bugdatabase/view_bug?bug_id=8316968)
    * [Apache HDFS](https://docs.oracle.com/en/middleware/goldengate/big-data/21.1/gadbd/apache-hdfs-target.html#GUID-4B870E57-3219-4663-9EFD-41133B0EDE06)
1. `-Xrs`: Reduces the use of operating system signals by the JVM
    * [Java Platform, Standard Edition Tools Reference](https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html)

### 7.3.2 GC vs. signal SIGSEGV

Here is an assumption: Jvm will use signal `SIGSEGV` to indicate that the gc process should run. And you can check it by `gdb` or `lldb` with a jni program, during which you may be interrupted frequently by `SIGSEGV`

```
Process 2494122 stopped
* thread #1, name = 'jni_demo', stop reason = signal SIGSEGV: invalid address (fault address: 0x0)
    frame #0: 0x00007fffe7c842b9
->  0x7fffe7c842b9: movl   (%rsi), %eax
    0x7fffe7c842bb: leaq   0xf8(%rbp), %rsi
    0x7fffe7c842c2: vmovdqu %ymm0, (%rsi)
    0x7fffe7c842c6: vmovdqu %ymm7, 0x20(%rsi)
```

### 7.3.3 How to add jar directory to classpah

JNI doesn't support wildcard `*`, so you need to generate all jar paths and join them with `:`, and then pass to `-Djava.class.path=` option.

# 8 Independent Projects

## 8.1 Pocoproject

```sh
git clone -b poco-1.13.3-release https://github.com/pocoproject/poco.git
cd poco
cmake -B cmake-build
cmake --build cmake-build --config Release -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install cmake-build
```

### 8.1.1 Logger

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

cmake -B build && cmake --build build && build/poco_logger_demo
```

Output:

```
2024.05.30 08:23:56.061053 <Information> main_1: Hello, World!
2024.05.30 08:23:56.061093 <Information> main_2: Hello, World!
2024-05-30 08:23:56 MultiChannelLogger: This is an informational message.
2024-05-30 08:23:56 MultiChannelLogger: This is a warning message.
```

#### 8.1.1.1 Colorful Output

You can refer to [Clickhouse-base/base/terminalColors.cpp](https://github.com/ClickHouse/ClickHouse/blob/master/base/base/terminalColors.cpp) for colorful output.

```sh
mkdir poco_logger_color_demo
cd poco_logger_color_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(poco_logger_color_demo)

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

cat > poco_logger_color_demo.cpp << 'EOF'
#include <Poco/AutoPtr.h>
#include <Poco/ConsoleChannel.h>
#include <Poco/FormattingChannel.h>
#include <Poco/Logger.h>
#include <Poco/PatternFormatter.h>

namespace ck_color {
using UInt8 = uint8_t;
using UInt64 = uint64_t;
std::string setColor(UInt64 hash) {
    /// Make a random RGB color that has constant brightness.
    /// https://en.wikipedia.org/wiki/YCbCr

    /// Note that this is darker than the middle relative luminance, see "Gamma_correction" and "Luma_(video)".
    /// It still looks awesome.
    UInt8 y = 128;

    UInt8 cb = static_cast<UInt8>(hash % 256);
    UInt8 cr = static_cast<UInt8>(hash / 256 % 256);

    UInt8 r = static_cast<UInt8>(std::max(0.0, std::min(255.0, y + 1.402 * (cr - 128))));
    UInt8 g = static_cast<UInt8>(std::max(0.0, std::min(255.0, y - 0.344136 * (cb - 128) - 0.714136 * (cr - 128))));
    UInt8 b = static_cast<UInt8>(std::max(0.0, std::min(255.0, y + 1.772 * (cb - 128))));

    /// ANSI escape sequence to set 24-bit foreground font color in terminal.
    return "\033[38;2;" + std::to_string(r) + ";" + std::to_string(g) + ";" + std::to_string(b) + "m";
}

const char* setColorForLogPriority(int priority) {
    if (priority < 1 || priority > 8) return "";

    static const char* colors[] = {
            "",
            "\033[1;41m", /// Fatal
            "\033[7;31m", /// Critical
            "\033[1;31m", /// Error
            "\033[0;31m", /// Warning
            "\033[0;33m", /// Notice
            "\033[1m",    /// Information
            "",           /// Debug
            "\033[2m",    /// Trace
    };

    return colors[priority];
}

const char* resetColor() {
    return "\033[0m";
}
} // namespace ck_color

class ColorfulPatternFormatter : public Poco::PatternFormatter {
public:
    ColorfulPatternFormatter(Poco::AutoPtr<Poco::PatternFormatter> formatter) : _formatter(std::move(formatter)) {}

    void format(const Poco::Message& msg, std::string& text) override {
        // You can customize here. Here is an example
        if (msg.getPriority() >= Poco::Message::PRIO_INFORMATION) {
            text.append(ck_color::setColor(std::hash<std::string>{}(msg.getText())));
            _formatter->format(msg, text);
            text.append(ck_color::resetColor());
        } else {
            text.append(ck_color::setColorForLogPriority(msg.getPriority()));
            _formatter->format(msg, text);
            text.append(ck_color::resetColor());
        }
    }

private:
    Poco::AutoPtr<Poco::PatternFormatter> _formatter;
};

int main() {
    {
        Poco::AutoPtr<Poco::ConsoleChannel> console_channel(new Poco::ConsoleChannel);

        Poco::AutoPtr<Poco::PatternFormatter> formatter(
                new Poco::PatternFormatter("%Y-%m-%d %H:%M:%S [%P:%I] [%p] %s - %t"));
        Poco::AutoPtr<Poco::PatternFormatter> colorful_formatter(new ColorfulPatternFormatter(formatter));
        Poco::AutoPtr<Poco::FormattingChannel> formatting_channel(
                new Poco::FormattingChannel(colorful_formatter, console_channel));

        Poco::Logger& logger =
                Poco::Logger::create("MultiChannelLogger", formatting_channel, Poco::Message::PRIO_TRACE);
        logger.trace("This is a trace message(1).");
        logger.trace("This is a trace message(2).");
        logger.debug("This is an debug message(1).");
        logger.debug("This is an debug message(2).");
        logger.information("This is an information message(1).");
        logger.information("This is an information message(2).");
        logger.warning("This is a warning message(1).");
        logger.warning("This is a warning message(2).");
        logger.error("This is an error message(1).");
        logger.error("This is an error message(2).");
        logger.critical("This is an critical message(1).");
        logger.critical("This is an critical message(2).");
        logger.fatal("This is a fatal message(1).");
        logger.fatal("This is a fatal message(2).");
    }
    return 0;
}
EOF

cmake -B build && cmake --build build && build/poco_logger_color_demo
```

### 8.1.2 JSON

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

cmake -B build && cmake --build build && build/poco_json_demo
```

Output:

```
Name: John Doe, Age: 30, Is Developer: 1
Generated JSON: {"isNewDeveloper":false,"newAge":28,"newName":"Jane Smith"}
```

### 8.1.3 Http

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

cmake -B build && cmake --build build && build/poco_http_demo
```

Output:

```
HTTP Server started on port 9080.
<html><head><title>Hello</title></head><body><h1>Hello from Poco HTTP Server</h1></body></html>
^C
```

### 8.1.4 Application

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

cmake -B build && cmake --build build
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

## 8.2 sqlpp11

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

### 8.2.1 With Sqlite

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

### 8.2.2 With Mysql

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

### 8.2.3 With Mariadb

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

## 8.3 libcurl

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

# 9 Assorted

1. [Awesome C++ Projects](https://github.com/fffaraz/awesome-cpp)
1. [parallel-hashmap](https://github.com/greg7mdp/parallel-hashmap)：`parallel-hashmap`提供了一组高性能、并发安全的`map`，用于替换`std`以及`boost`中的`map`
    * [phmap_gdb.py](https://github.com/greg7mdp/parallel-hashmap/blob/master/phmap_gdb.py)
1. [cpp-httplib](https://github.com/yhirose/cpp-httplib)：`cpp-httplib`以头文件的方式提供`http`协议的相关支持
1. [json](https://github.com/nlohmann/json)：`json`库
1. [libfiu(Failure Injection Unit)](https://blitiri.com.ar/p/libfiu/)：错误注入
1. bison: Parser
