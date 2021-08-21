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

# 4 Make

**代码变成可执行文件，叫做编译`compile`；先编译这个，还是先编译那个（即编译的安排），叫做构建`build`**

## 4.1 Makefile文件的格式

**`Makefile`文件由一系列规则`rules`构成。每条规则的形式如下：**

```makefile
<target> : <prerequisites> 
[tab]  <commands>
```

* `target`：目标，是必须的
* `prerequisites`：前置条件，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的
* `commands`：即完成目标需要执行的命令，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的

### 4.1.1 target

一个目标`target`就构成一条规则。**目标通常是文件名**，指明`make`命令所要构建的对象。目标可以是一个文件名，也可以是多个文件名，之间用空格分隔

**除了文件名，目标还可以是某个操作的名字，这称为「伪目标」`phony target`，例如**

```makefile
clean:
    rm *.o
```

但是，项目中可能有名为`clean`的文件名，`make`发现`clean`文件已经存在，就认为没有必要重新构建了，因此可以明确声明「伪目标」

```makefile
.PHONY: clean
clean:
    rm *.o temp
```

**如果`make`命令运行时没有指定目标，默认会执行`Makefile`文件的第一个目标**

### 4.1.2 prerequisites

前置条件通常是一组文件名，之间用空格分隔。它指定了目标是否重新构建的判断标准：只要有一个前置文件不存在，或者有过更新（前置文件的`last-modification`时间戳比目标的时间戳新），目标就需要重新构建

```makefile
result.txt: source.txt
    cp source.txt result.txt
```

上面代码中，构建`result.txt`的前置条件是`source.txt`。如果当前目录中，`source.txt`已经存在，那么`make result.txt`可以正常运行，否则必须再写一条规则，来生成`source.txt`

```makefile
source.txt:
    echo "this is the source" > source.txt
```

连续执行两次`make result.txt`。第一次执行会先新建`source.txt`，然后再新建`result.txt`。第二次执行，`make`发现`source.txt`没有变动（时间戳晚于`result.txt`），就不会执行任何操作，`result.txt`也不会重新生成

如果需要生成多个文件，往往采用下面的写法

```makefile
source: file1 file2 file3
```

这样仅需要执行`make source`便可生成3个文件，而无需执行`make file1`、`make file2`、`make file3`

### 4.1.3 commands

命令`commands`表示如何更新目标文件，由一行或多行的`shell`命令组成。它是构建目标的具体指令，它的运行结果通常就是生成目标文件

每行命令之前必须有一个`tab`键。如果想用其他键，可以用内置变量`.RECIPEPREFIX`声明

```makefile
.RECIPEPREFIX = >
all:
> echo Hello, world
```

**需要注意的是，每行命令在一个单独的`shell`中执行。这些`shell`之间没有继承关系**

```makefile
var-lost:
    export foo=bar
    echo "foo=[$$foo]"
```

一个解决办法是将两行命令写在一行，中间用分号分隔

```makefile
var-kept:
    export foo=bar; echo "foo=[$$foo]"
```

另一个解决办法是在换行符前加反斜杠转义

```makefile
var-kept:
    export foo=bar; \
    echo "foo=[$$foo]"
```

更好的方法是加上`.ONESHELL:`命令

```makefile
.ONESHELL:
var-kept:
    export foo=bar; 
    echo "foo=[$$foo]"
```

## 4.2 Makefile文件的语法

### 4.2.1 注释

井号`#`在`Makefile`中表示注释

```makefile
# 这是注释
result.txt: source.txt
    # 这是注释
    cp source.txt result.txt # 这也是注释
```

### 4.2.2 回声（echoing）

正常情况下，`make`会打印每条命令，然后再执行，这就叫做回声`echoing`

```makefile
test:
    # 这是测试
```

执行上面的规则，会得到下面的结果

```sh
$ make test
# 这是测试
```

在命令的前面加上`@`，就可以关闭回声

```makefile
test:
    @# 这是测试
```

### 4.2.3 通配符

通配符`wildcard`用来指定一组符合条件的文件名。`Makefile`的通配符与 `Bash`一致，主要有星号`*`、问号`？`和`...`。比如，`*.o`表示所有后缀名为`o`的文件

```makefile
clean:
        rm -f *.o
```

### 4.2.4 模式匹配

`make`命令允许对文件名，进行类似正则运算的匹配，主要用到的匹配符是`%`。比如，假定当前目录下有`f1.c`和`f2.c`两个源码文件，需要将它们编译为对应的对象文件

```makefile
%.o: %.c
```

等同于下面的写法

```makefile
f1.o: f1.c
f2.o: f2.c
```

**使用匹配符`%`，可以将大量同类型的文件，只用一条规则就完成构建**

### 4.2.5 变量和赋值符

`Makefile`允许使用等号自定义变量

```makefile
txt = Hello World
test:
    @echo $(txt)
```

上面代码中，变量`txt`等于`Hello World`。**调用时，变量需要放在`$()`之中**

**调用`shell`变量，需要在`$`前，再加一个`$`，这是因为`make`命令会对`$`转义**

```makefile
test:
    @echo $$HOME
```

### 4.2.6 内置变量（Implicit Variables）

`make`命令提供一系列内置变量，比如，`$(CC)`指向当前使用的编译器，`$(MAKE)`指向当前使用的`make`工具。这主要是为了跨平台的兼容性，详细的内置变量清单见[手册](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html)

```makefile
output:
    $(CC) -o output input.c
```

### 4.2.7 自动变量（Automatic Variables）

`make`命令还提供一些自动变量，它们的值与当前规则有关。主要有以下几个，可以参考[手册](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

#### 4.2.7.1 `$@`

`$@`指代当前目标，就是`make`命令当前构建的那个目标。比如，`make foo`的`$@`就指代`foo`

```makefile
a.txt b.txt: 
    touch $@
```

等同于下面的写法

```makefile
a.txt:
    touch a.txt
b.txt:
    touch b.txt
```

#### 4.2.7.2 `$<`

`$<`指代第一个前置条件。比如，规则为`t: p1 p2`，那么`$<`就指代`p1`

```makefile
a.txt: b.txt c.txt
    cp $< $@ 
```

等同于下面的写法

```makefile
a.txt: b.txt c.txt
    cp b.txt a.txt 
```

#### 4.2.7.3 `$?`

`$?`指代比目标更新的所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，其中`p2`的时间戳比`t`新，`$?`就指代`p2`

#### 4.2.7.4 `$^`

`$^`指代所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，那么`$^`就指代`p1 p2`

#### 4.2.7.5 `$*`

`$*`指代匹配符`%`匹配的部分，比如`%.txt`匹配`f1.txt`中的`f1`，`$*`就表示`f1`

#### 4.2.7.6 `$(@D)/$(@F)`

`$(@D)`和`$(@F)`分别指向`$@`的目录名和文件名。比如，`$@`是`src/input.c`，那么`$(@D)`的值为`src`，`$(@F)`的值为`input.c`

#### 4.2.7.7 `$(<D)/$(<F)`

`$(<D)`和`$(<F)`分别指向`$<`的目录名和文件名

#### 4.2.7.8 例子

```makefile
dest/%.txt: src/%.txt
    @[ -d dest ] || mkdir dest
    cp $< $@
```

上面代码将`src`目录下的`txt`文件，拷贝到`dest`目录下。首先判断`dest`目录是否存在，如果不存在就新建，然后，`$<`指代前置文件`src/%.txt`，`$@`指代目标文件`dest/%.txt`

### 4.2.8 判断和循环

`Makefile`使用`Bash`语法，完成判断和循环

```makefile
ifeq ($(CC),gcc)
  libs=$(libs_for_gcc)
else
  libs=$(normal_libs)
endif
```

```makefile
LIST = one two three
all:
    for i in $(LIST); do \
        echo $$i; \
    done

# 等同于

all:
    for i in one two three; do \
        echo $$i; \
    done
```

### 4.2.9 函数

`Makefile`还可以使用函数，格式如下

```makefile
$(function arguments)
# 或者
${function arguments}
```

`Makefile`提供了许多[内置函数](https://www.gnu.org/software/make/manual/html_node/Functions.html)，可供调用

## 4.3 参考

* [Make 命令教程](https://www.ruanyifeng.com/blog/2015/02/make.html)

# 5 CMake

## 5.1 tutorial

### 5.1.1 step1: A Basic Starting Point

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

### 5.1.2 step2: Adding a Library and Adding Usage Requirements for a Library

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

### 5.1.3 step3: Installing

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

### 5.1.4 step4: Testing

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

### 5.1.5 step5: Adding System Introspection

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

## 5.2 target

`cmake`可以使用`add_executable`、`add_library`或`add_custom_target`等命令来定义目标`target`。与变量不同，目标在每个作用域都可见，且可以使用`get_property`和`set_property`获取或设置其属性

## 5.3 property

### 5.3.1 INCLUDE_DIRECTORIES

1. `include_directories`：该方法会在全局维度添加`include`的搜索路径。这些搜索路径会被添加到所有`target`中去（包括所有`sub target`），会追加到所有`target`的`INCLUDE_DIRECTORIES`属性中去
1. `target_include_directories`：该方法为指定`target`添加`include`的搜索路径，会追加到该`target`的`INCLUDE_DIRECTORIES`属性中去

如何查看全局维度以及target维度的`INCLUDE_DIRECTORIES`属性值

```
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
  message(STATUS "dir of include_directories='${dir}'")
endforeach()

get_target_property(target_dirs <TARGET-NAME> INCLUDE_DIRECTORIES)
foreach(target_dir ${target_dirs})
  message(STATUS "dir of target_include_directories='${target_dir}'")
endforeach()
```

## 5.4 command

### 5.4.1 message

用于打印信息

格式：`message([<mode>] "message text" ...)`

合法的`mode`包括

* `FATAL_ERROR`：致命错误，终止构建
* `SEND_ERROR`：继续构建，终止`generation`
* `WARNING`：告警信息，继续构建
* `AUTHOR_WARNING`：告警信息，继续构建
* `DEPRECATION`：当`CMAKE_ERROR_DEPRECATED`或`CMAKE_WARN_DEPRECATED`参数启用时，若使用了`deprecated`的特性，会打印`error`或者`warn`信息
* `NOTICE`：通过`stderr`打印的信息
* **`STATUS`：用户最应该关注的信息**
* `VERBOSE`：项目构建者需要关注的信息
* `DEBUG`：项目调试需要关注的信息
* `TRACE`：最低级别的信息

### 5.4.2 set

`set`用于设置：`cmake`变量或环境变量

格式：

* `cmake`变量：`set(<variable> <value>... [PARENT_SCOPE])`
* 环境变量：`set(ENV{<variable>} [<value>]`

变量如何引用：

* `cmake`变量：`${<variable>}`
* 环境变量：`$ENV{<variable>}`

### 5.4.3 option

`option`用于设置构建选项

格式：`option(<variable> "<help_text>" [value])`

* 其中`value`的可选值就是`ON`和`OFF`，其中`OFF`是默认值

### 5.4.4 aux_source_directory

Find all source files in a directory

## 5.5 Tips

### 5.5.1 同一目录，多个源文件

如果同一个目录下有多个源文件，那么在使用`add_executable`命令的时候，如果要一个个填写，那么将会非常麻烦，并且后续维护的代价也很大

```
add_executable(Demo main.cxx opt1.cxx opt2.cxx)
```

我们可以使用`aux_source_directory(<dir> <variable>)`）命令，该命令可以扫描一个目录下得所有源文件，并将文件列表赋值给一个变量

```sh
# 查找当前目录下的所有源文件
# 并将名称保存到 DIR_SRCS 变量
aux_source_directory(. DIR_SRCS)

# 指定生成目标
add_executable(Demo ${DIR_SRCS})
```

## 5.6 参考

* [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
    * [CMake Tutorial对应的source code](https://github.com/Kitware/CMake/tree/master/Help/guide/tutorial)
    * [CMake Tutorial 翻译](https://www.jianshu.com/p/6df3857462cd)
* [CMake 入门实战](https://www.hahack.com/codes/cmake/)
* [CMake 语言 15 分钟入门教程](https://leehao.me/cmake-%E8%AF%AD%E8%A8%80-15-%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
* [CMake Table of Contents](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#manual:cmake-buildsystem(7))
* [What is the difference between include_directories and target_include_directories in CMake?](https://stackoverflow.com/questions/31969547/what-is-the-difference-between-include-directories-and-target-include-directorie/40244458)
