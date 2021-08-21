---
title: Cpp-相关知识点
date: 2021-08-19 09:38:42
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 标准库

## 1.1 std::function

## 1.2 std::bind

## 1.3 std::lock_guard

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

## 1.4 参考

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)

# 2 宏

## 2.1 do while(0) in macros

考虑下面的宏定义

```c++
#define foo(x) bar(x); baz(x)
```

然后我们调用

```c++
foo(wolf);
```

会被展开为

```c++
bar(wolf); baz(wolf);
```

看起来没有问题，我们接着考虑另一个情况

```c++
if (condition) 
    foo(wolf);
```

会被展开为

```c++
if (condition) 
    bar(wolf);
baz(wolf);
```

这并不符合我们的预期，为了避免出现这种问题，需要用一个作用域将宏包围起来，避免语句的作用域发生偏移，于是我们进一步将宏表示为如下形式

```c++
#define foo(x) { bar(x); baz(x); }
```

然后我们调用

```c++
if (condition)
    foo(wolf);
else
    bin(wolf);
```

会被展开为

```c++
if (condition) {
    bar(wolf);
    baz(wolf);
}; // syntax error
else
    bin(wolf);
```

最终，我们将宏优化成如下形式

```c++
#define foo(x) do { bar(x); baz(x); } while (0)
```

## 2.2 参考

* [do {…} while (0) in macros](https://hownot2code.com/2016/12/05/do-while-0-in-macros/)
* [PRE10-C. Wrap multistatement macros in a do-while loop](https://wiki.sei.cmu.edu/confluence/display/c/PRE10-C.+Wrap+multistatement+macros+in+a+do-while+loop)

# 3 三方库

## 3.1 头文件如何查找

## 3.2 参考

* [Linux下c/c++头文件和库文件的查找路径](https://blog.csdn.net/guotianqing/article/details/104224439)

# 4 CMake

## 4.1 tutorial

### 4.1.1 step1: A Basic Starting Point

`tutorial.cxx`内容如下：

```c++
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " number" << std::endl;
    return 1;
  }

  // convert input to double
  const double inputValue = atof(argv[1]);

  // calculate square root
  const double outputValue = sqrt(inputValue);
  std::cout << "The square root of " << inputValue << " is " << outputValue
            << std::endl;
  return 0;
}
```

---

`CMakeLists.txt`内容如下：

* `cmake_minimum_required`：用于指定`cmake`的最小版本，避免出现兼容性问题（包含了高级版本的特性，但是实际的`cmake`版本较小）
* `project`：用于设置项目名称，并存储到`CMAKE_PROJECT_NAME`变量中，`cmake`中的一些环境变量会以这里指定的项目名称作为前缀，例如
    * `PROJECT_SOURCE_DIR`、`<PROJECT-NAME>_SOURCE_DIR`
    * `PROJECT_BINARY_DIR`、`<PROJECT-NAME>_BINARY_DIR`
* `set`：用于设置一些变量
* `add_executable`：添加目标可执行文件

```
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# add the executable
add_executable(Tutorial tutorial.cxx)
```

---

此时文件结构如下：

```
.
├── CMakeLists.txt
└── tutorial.cxx
```

---

测试：

```sh
mkdir build
cd build
cmake ..
make
./Tutorial 256
```

### 4.1.2 step2: Adding a Library and Adding Usage Requirements for a Library

接下来，我们用自己实现的求开方的函数替换标准库中的实现。创建`MathFunctions`子目录，并在该子目录添加`MathFunctions.h`以及`mysqrt.cxx`、`CMakeLists.txt`三个文件

`MathFunctions/MathFunctions.h`内容如下：

```c++
double mysqrt(double x);
```

---

`MathFunctions/mysqrt.cxx`内容如下：

```c++
#include <iostream>

// a hack square root calculation using simple operations
double mysqrt(double x)
{
  if (x <= 0) {
    return 0;
  }

  double result = x;

  // do ten iterations
  for (int i = 0; i < 10; ++i) {
    if (result <= 0) {
      result = 0.1;
    }
    double delta = x - (result * result);
    result = result + 0.5 * delta / result;
    std::cout << "Computing sqrt of " << x << " to be " << result << std::endl;
  }
  return result;
}
```

---

`MathFunctions/CMakeLists.txt`内容如下：

```
add_library(MathFunctions mysqrt.cxx)
```

---

添加`TutorialConfig.h.in`文件，内容如下：

```c++
#cmakedefine USE_MYMATH
```

---

修改`tutorial.cxx`文件，内容如下：

```c++
#include <cmath>
#include <cstdlib>
#include <iostream>
#include <string>
#include "TutorialConfig.h"
#ifdef USE_MYMATH
#  include "MathFunctions.h"
#endif

int main(int argc, char* argv[])
{
  if (argc < 2) {
    std::cout << "Usage: " << argv[0] << " number" << std::endl;
    return 1;
  }

  // convert input to double
  const double inputValue = atof(argv[1]);

  // calculate square root
#ifdef USE_MYMATH
  const double outputValue = mysqrt(inputValue);
#else
  const double outputValue = sqrt(inputValue);
#endif
  std::cout << "The square root of " << inputValue << " is " << outputValue
            << std::endl;
  return 0;
}
```

---

修改`CMakeLists.txt`文件，内容如下：

* `option`：用于添加`cmake`选项，可以通过`-D<OPTION-NAME>=ON/OFF`参数来选择打开或者关闭该选项
    * 例如`cmake .. -DUSE_MYMATH=OFF`
* `configure_file`：一般用于根据cmake选项动态生成头文件
* `if statement`：控制流
* `add_subdirectory`：用于将子目录添加到构建任务中
* `list`：容器相关的操作
* `target_link_libraries`：指定库文件
* `target_include_directories`：指定头文件搜索路径

```
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

option(USE_MYMATH "Use tutorial provided math implementation" ON)

# configure a header file to pass some of the CMake settings
# to the source code
configure_file(TutorialConfig.h.in TutorialConfig.h)

if(USE_MYMATH)
  add_subdirectory(MathFunctions)
  list(APPEND EXTRA_LIBS MathFunctions)
  list(APPEND EXTRA_INCLUDES "${PROJECT_SOURCE_DIR}/MathFunctions")
endif()

# add the executable
add_executable(Tutorial tutorial.cxx)

target_link_libraries(Tutorial PUBLIC ${EXTRA_LIBS})

# add the binary tree to the search path for include files
# so that we will find TutorialConfig.h
target_include_directories(Tutorial PUBLIC
                           "${PROJECT_BINARY_DIR}"
                           ${EXTRA_INCLUDES}
                           )
```

---

此时目录结构如下：

```
.
├── CMakeLists.txt
├── MathFunctions
│   ├── CMakeLists.txt
│   ├── MathFunctions.h
│   └── mysqrt.cxx
├── TutorialConfig.h.in
└── tutorial.cxx
```

---

测试：

```sh
# 使用的是自定义的sqrt函数
mkdir build
cd build
cmake ..
make
./Tutorial 256

# 使用的是标准库的sqrt函数
mkdir build
cd build
cmake .. -DUSE_MYMATH=OFF
make
./Tutorial 256
```

### 4.1.3 step3: Installing

现在，我们要安装`make`后产生的二进制、库文件、头文件

在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* 其中这里指定了两个相对路径`lib`、`include`。前缀由`cmake`变量`CMAKE_INSTALL_PREFIX`确定，默认值为`/usr/local`

```
# add the install targets
install (TARGETS MathFunctions DESTINATION bin)
install(FILES MathFunctions.h DESTINATION include)
```

---

在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

```
# add the install targets
install (TARGETS Tutorial DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/TutorialConfig.h" DESTINATION include)
```

---

测试：

```sh
# 使用默认的安装路径
mkdir build
cd build
cmake ..
make
make install

# 指定安装路径
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/mydir
make
make install
```

### 4.1.4 step4: Testing

接下来，增加测试功能。在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

* `add_test`：用于增加测试，其中`NAME`指定的是测试用例的名称，`RUN`指定的是测试的命令
* `function`：用于定义一个方法
* `set_tests_properties`：用于设置测试项的属性，这里指定了测试结果的通配符

```
enable_testing()

# does the application run
add_test(NAME Runs COMMAND Tutorial 25)

# does the usage message work?
add_test(NAME Usage COMMAND Tutorial)
set_tests_properties(Usage
  PROPERTIES PASS_REGULAR_EXPRESSION "Usage:.*number"
  )

# define a function to simplify adding tests
function(do_test target arg result)
  add_test(NAME Comp_${arg} COMMAND ${target} ${arg})
  set_tests_properties(Comp_${arg}
    PROPERTIES PASS_REGULAR_EXPRESSION ${result}
    )
endfunction(do_test)

# do a bunch of result based tests
do_test(Tutorial 4 "4 is 2")
do_test(Tutorial 9 "9 is 3")
do_test(Tutorial 5 "5 is 2.236")
do_test(Tutorial 7 "7 is 2.645")
do_test(Tutorial 25 "25 is 5")
do_test(Tutorial -25 "-25 is [-nan|nan|0]")
do_test(Tutorial 0.0001 "0.0001 is 0.01")
```

---

测试：

```
mkdir build
cd build
cmake ..
make
make test
```

### 4.1.5 step5: Adding System Introspection

同一个库，在不同平台上的实现可能不同，例如A平台有方法`funcA`，而B平台没有`funcA`，因此我们需要有一种机制来检测这种差异

接下来，增加测试功能。在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* `include`：加载`cmake`模块，这里加载了`CheckSymbolExists`模块，该模块用于检测指定文件中的指定符号是否存在

```
include(CheckSymbolExists)
check_symbol_exists(log "math.h" HAVE_LOG)
check_symbol_exists(exp "math.h" HAVE_EXP)
if(NOT (HAVE_LOG AND HAVE_EXP))
  unset(HAVE_LOG CACHE)
  unset(HAVE_EXP CACHE)
  set(CMAKE_REQUIRED_LIBRARIES "m")
  check_symbol_exists(log "math.h" HAVE_LOG)
  check_symbol_exists(exp "math.h" HAVE_EXP)
  if(HAVE_LOG AND HAVE_EXP)
    target_link_libraries(MathFunctions PRIVATE m)
  endif()
endif()

if(HAVE_LOG AND HAVE_EXP)
  target_compile_definitions(MathFunctions
                             PRIVATE "HAVE_LOG" "HAVE_EXP")
endif()
```

---

修改`MathFunctions/mysqrt.cxx`文件，内容如下：

```c++
#include <iostream>
#include <cmath>

// a hack square root calculation using simple operations
double mysqrt(double x)
{
  if (x <= 0) {
    return 0;
  }

#if defined(HAVE_LOG) && defined(HAVE_EXP)
  double result = exp(log(x) * 0.5);
  std::cout << "Computing sqrt of " << x << " to be " << result
            << " using log and exp" << std::endl;
#else
  double result = x;

  // do ten iterations
  for (int i = 0; i < 10; ++i) {
    if (result <= 0) {
      result = 0.1;
    }
    double delta = x - (result * result);
    result = result + 0.5 * delta / result;
    std::cout << "Computing sqrt of " << x << " to be " << result << std::endl;
  }
#endif
  return result;
}
```

---

测试：

```
mkdir build
cd build
cmake ..
make
./Tutorial 25
```

## 4.2 参考

* [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
    * [CMake Tutorial对应的source code](https://github.com/Kitware/CMake/tree/master/Help/guide/tutorial)
    * [CMake Tutorial 翻译](https://www.jianshu.com/p/6df3857462cd)
* [CMake 语言 15 分钟入门教程](https://leehao.me/cmake-%E8%AF%AD%E8%A8%80-15-%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
* [CMake 入门教程](https://leehao.me/CMake-%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
* [CMake教程](https://www.guyuehome.com/33957)
* [cmake : add_library详解](https://blog.csdn.net/LaineGates/article/details/108242803)
* [cmake导入外部链接库](https://blog.csdn.net/jijun0817/article/details/40395273)
