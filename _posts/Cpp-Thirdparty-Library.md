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

# 1 boost

**如何安装：**

```sh
yum install -y boost-devel
```

## 1.1 Print Stack

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

## 1.2 Reference

* [The Boost C++ Libraries BoostBook Documentation Subset](https://www.boost.org/doc/libs/master/doc/html/)
* [How to print current call stack](https://www.boost.org/doc/libs/1_66_0/doc/html/stacktrace/getting_started.html)
* [print call stack in C or C++](https://stackoverflow.com/Questions/3899870/print-call-stack-in-c-or-c)

# 2 [fmt](https://github.com/fmtlib/fmt)

**安装`fmt`：**

```sh
git clone git@github.com:fmtlib/fmt.git
cd fmt

mkdir build
cd build

cmake ..
make -j 4
make install
```

**在`cmake`中添加`fmt`依赖：**
```
find_package(fmt)

target_link_libraries(xxx fmt::fmt)
```

**示例：**

```cpp
#include <fmt/core.h>

#include <iostream>

int main() {
    std::cout << fmt::format("hello {}", "Liuye") << std::endl;
    return 0;
}
```

* `gcc -o main main.cpp -lstdc++ -std=gnu++17 -lfmt`

# 3 Google

## 3.1 gflag

**安装[gflag](https://github.com/gflags/gflags)：**

```sh
git clone git@github.com:gflags/gflags.git
cd gflags

mkdir build
cd build

cmake ..
make -j 4
make install
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

* `gcc -o main main.cpp -lstdc++ -std=gnu++17 -lgflags`
* `./main --test_bool true --test_int32 100 --test_double 6.666 --test_str hello`

## 3.2 glog

**安装[glog](https://github.com/google/glog)：**

```sh
git clone https://github.com/google/glog.git 
cd glog

mkdir build
cd build

# BUILD_SHARED_LIBS用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -DBUILD_SHARED_LIBS=OFF ..
make -j 4
make install
```

**在`cmake`中添加`glog`依赖：**

```cmake
find_package(GLOG)

target_link_libraries(xxx glog::glog)
```

### 3.2.1 Print Stack

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

## 3.3 gtest

**安装[gtest](https://github.com/google/googletest)：**

```sh
git clone https://github.com/google/googletest.git
cd googletest

mkdir build
cd build

# BUILD_SHARED_LIBS用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -DBUILD_SHARED_LIBS=OFF ..
make -j 4
make install
```

**在`cmake`中添加`gtest`依赖：**

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
set(CMAKE_CXX_STANDARD_REQUIRED True)

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

### 3.3.1 Macros

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

### 3.3.2 Tips

1. 假设编译得到的二进制是`test`，通过执行`./test --help`就可以看到所有gtest支持的参数，包括执行特定case等等

## 3.4 benchmark

**安装[benchmark](https://github.com/google/benchmark)：**

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

### 3.4.1 quick-benchmark

[quick-bench（在线）](https://quick-bench.com/)

### 3.4.2 Tips

#### 3.4.2.1 benchmark::DoNotOptimize

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

#### 3.4.2.2 Run Specific Case

使用参数`--benchmark_filter=<regexp>`，此外可以使用`--help`查看所有参数

### 3.4.3 Reference

* [benchmark/docs/user_guide.md](https://github.com/google/benchmark/blob/main/docs/user_guide.md)
* [c++性能测试工具：google benchmark入门（一）](https://www.cnblogs.com/apocelipes/p/10348925.html)

## 3.5 [gperftools/gperftools](https://github.com/gperftools/gperftools)

# 4 ORM

## 4.1 sqlpp11

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

### 4.1.1 Example

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

# Include subdirectories
add_subdirectory(contrib/sqlpp11)
add_subdirectory(contrib/mariadb-connector-c)

# Include header files
target_include_directories (${PROJECT_NAME} PUBLIC "${CMAKE_SOURCE_DIR}/contrib/mariadb-connector-c/include")
target_include_directories (${PROJECT_NAME} PUBLIC "${CMAKE_BINARY_DIR}/contrib/mariadb-connector-c/include")

# Link against libraries
target_link_libraries(${PROJECT_NAME} sqlpp11 mariadbclient)
EOF

cat > users.ddl << 'EOF'
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    age INT,
    sex VARCHAR(10)
);
EOF

contrib/sqlpp11/scripts/ddl2cpp users.ddl users Test

cat > main.cpp << 'EOF'
#include <sqlpp11/all_of.h>
#include <sqlpp11/mysql/mysql.h>
#include <sqlpp11/sqlpp11.h>

#include <iostream>

#include "users.h"

int main() {
    // Configure your MySQL/MariaDB connection details
    auto config = std::make_shared<sqlpp::mysql::connection_config>();
    config->user = "root";
    config->port = 13306;
    config->password = "Abcd1234";
    config->database = "test";
    config->host = "127.0.0.1";

    sqlpp::mysql::connection db(config);

    Test::Users users;

    for (const auto& row : db(select(sqlpp::all_of(users)).from(users).unconditionally())) {
        std::cout << "ID: " << row.id << ", Name: " << row.name << ", Age: " << row.age << std::endl;
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
ID: 1, Name: John Doe, Age: 30
ID: 2, Name: Jane Smith, Age: 25
ID: 3, Name: Michael Johnson, Age: 35
```

# 5 Assorted

1. [Awesome C++ Projects](https://github.com/fffaraz/awesome-cpp)
1. [parallel-hashmap](https://github.com/greg7mdp/parallel-hashmap)：`parallel-hashmap`提供了一组高性能、并发安全的`map`，用于替换`std`以及`boost`中的`map`
    * [phmap_gdb.py](https://github.com/greg7mdp/parallel-hashmap/blob/master/phmap_gdb.py)
1. [cpp-httplib](https://github.com/yhirose/cpp-httplib)：`cpp-httplib`以头文件的方式提供`http`协议的相关支持
1. [json](https://github.com/nlohmann/json)：`json`库
1. [apache-arrow](https://github.com/apache/arrow)
1. [libfiu(Failure Injection Unit)](https://blitiri.com.ar/p/libfiu/)：错误注入
