---
title: Cpp-Tools-CMake
date: 2021-09-06 10:55:29
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 tutorial

## 1.1 step1: A Basic Starting Point

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

`CMakeLists.txt`内容如下：

* `cmake_minimum_required`：用于指定`cmake`的最小版本，避免出现兼容性问题（包含了高级版本的特性，但是实际的`cmake`版本较小）
* `project`：用于设置项目名称，并存储到`CMAKE_PROJECT_NAME`变量中，`cmake`中的一些环境变量会以这里指定的项目名称作为前缀，例如
    * `PROJECT_SOURCE_DIR`、`<PROJECT-NAME>_SOURCE_DIR`
    * `PROJECT_BINARY_DIR`、`<PROJECT-NAME>_BINARY_DIR`
* `set`：用于设置一些变量
* `add_executable`：添加目标可执行文件

```cmake
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Tutorial VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# add the executable
add_executable(Tutorial tutorial.cxx)
```

此时文件结构如下：

```
.
├── CMakeLists.txt
└── tutorial.cxx
```

测试：

```sh
mkdir build
cd build
cmake ..
make
./Tutorial 256
```

## 1.2 step2: Adding a Library and Adding Usage Requirements for a Library

接下来，我们用自己实现的求开方的函数替换标准库中的实现。创建`MathFunctions`子目录，并在该子目录添加`MathFunctions.h`以及`mysqrt.cxx`、`CMakeLists.txt`三个文件

`MathFunctions/MathFunctions.h`内容如下：

```c++
double mysqrt(double x);
```

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

`MathFunctions/CMakeLists.txt`内容如下：

```cmake
add_library(MathFunctions mysqrt.cxx)
```

添加`TutorialConfig.h.in`文件，内容如下：

```c++
#cmakedefine USE_MYMATH
```

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

修改`CMakeLists.txt`文件，内容如下：

* `option`：用于添加`cmake`选项，可以通过`-D<OPTION-NAME>=ON/OFF`参数来选择打开或者关闭该选项
    * 例如`cmake .. -DUSE_MYMATH=OFF`
* `configure_file`：一般用于根据cmake选项动态生成头文件
* `if statement`：控制流
* `add_subdirectory`：用于将子目录添加到构建任务中
* `list`：容器相关的操作
* `target_link_libraries`：指定库文件
* `target_include_directories`：指定头文件搜索路径

```cmake
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

## 1.3 step3: Installing

现在，我们要安装`make`后产生的二进制、库文件、头文件

在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* 其中这里指定了两个相对路径`lib`、`include`。前缀由`cmake`变量`CMAKE_INSTALL_PREFIX`确定，默认值为`/usr/local`

```cmake
# add the install targets
install (TARGETS MathFunctions DESTINATION bin)
install(FILES MathFunctions.h DESTINATION include)
```

在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

```cmake
# add the install targets
install (TARGETS Tutorial DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/TutorialConfig.h" DESTINATION include)
```

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

## 1.4 step4: Testing

接下来，增加测试功能。在`step2`的基础上，修改`CMakeLists.txt`文件，追加如下内容：

* `add_test`：用于增加测试，其中`NAME`指定的是测试用例的名称，`RUN`指定的是测试的命令
* `function`：用于定义一个方法
* `set_tests_properties`：用于设置测试项的属性，这里指定了测试结果的通配符

```cmake
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

测试：

```
mkdir build
cd build
cmake ..
make
make test
```

## 1.5 step5: Adding System Introspection

同一个库，在不同平台上的实现可能不同，例如A平台有方法`funcA`，而B平台没有`funcA`，因此我们需要有一种机制来检测这种差异

接下来，增加测试功能。在`step2`的基础上，修改`MathFunctions/CMakeLists.txt`文件，追加如下内容：

* `include`：加载`cmake`模块，这里加载了`CheckSymbolExists`模块，该模块用于检测指定文件中的指定符号是否存在

```cmake
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

测试：

```
mkdir build
cd build
cmake ..
make
./Tutorial 25
```

# 2 target

`cmake`可以使用`add_executable`、`add_library`或`add_custom_target`等命令来定义目标`target`。与变量不同，目标在每个作用域都可见，且可以使用`get_property`和`set_property`获取或设置其属性

# 3 variables

在 CMake 中，变量本身是无类型的。CMake 变量在定义时是以字符串形式存储的，但可以通过 CMake 的命令和语法将这些字符串解释为不同的类型（如布尔值、整数等）。以下是一些常见的变量类型和如何在 CMake 中使用它们的示例：

1. 字符串
    ```cmake
    set(MY_STRING "Hello, World!")
    message(STATUS "String value: ${MY_STRING}")
    ```

1. 布尔值
    ```cmake
    set(MY_BOOL ON)
    if(MY_BOOL)
        message(STATUS "Boolean is ON")
    endif()
    ```

1. 整数
    ```cmake
    set(MY_INT 10)
    math(EXPR MY_INT_PLUS_ONE "${MY_INT} + 1")
    message(STATUS "Integer value: ${MY_INT_PLUS_ONE}")
    ```

1. 列表
    ```cmake
    set(MY_LIST "item1;item2;item3")
    list(APPEND MY_LIST "item4")
    foreach(item IN LISTS MY_LIST)
        message(STATUS "List item: ${item}")
    endforeach()
    ```

## 3.1 Frequently-Used Variables

参考（[cmake-variables](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html)）：

* `CMAKE_BINARY_DIR`、`PROJECT_BINARY_DIR`、`<PROJECT-NAME>_BINARY_DIR`：指的是工程编译发生的目录。在递归处理子项目时，该变量不会发生改变
  * 若指定了`-B`参数，即`-B`参数指定的目录
  * 若没有指定`-B`参数，即执行`cmake`命令时所在的目录
* `CMAKE_SOURCE_DIR`、`PROJECT_SOURCE_DIR`、`<PROJECT-NAME>_SOURCE_DIR`：指的是工程顶层目录。在递归处理子项目时，该变量不会发生改变
* `CMAKE_CURRENT_SOURCE_DIR`：指的是当前处理的`cmake`项目的工程目录，一般来说是`CMakeLists.txt`所在目录。在递归处理子项目时，该变量会发生改变
  * [Difference between CMAKE_CURRENT_SOURCE_DIR and CMAKE_CURRENT_LIST_DIR](https://stackoverflow.com/questions/15662497/difference-between-cmake-current-source-dir-and-cmake-current-list-dir)
  * 若通过`include(src/CMakeLists.txt)`引入子项目，假设工程根目录是`project`，那么该子项目在处理的时候，`CMAKE_CURRENT_SOURCE_DIR`是`project`，而`CMAKE_CURRENT_LIST_DIR`是`project/src`
* `CMAKE_CURRENT_BINARY_DIR`：指的是工程编译结果存放的目标目录。在递归处理子项目时，该变量会发生改变。可以通过`set`命令或`ADD_SUBDIRECTORY(src bin)`改变这个变量的值，但是`set(EXECUTABLE_OUTPUT_PATH <new_paht>)`并不改变这个变量的值，只会影响最终的保存路径
* `CMAKE_CURRENT_LIST_DIR`：指的是当前处理的`CMakeLists.txt`所在目录。在递归处理子项目时，该变量会发生改变
* `CMAKE_CURRENT_LIST_FILE`：指的是当前处理的`CMakeLists.txt`的路径。在递归处理子项目时，该变量会发生改变
* `CMAKE_MODULE_PATH`：`include()`、`find_package()`命令的模块搜索路径
* `EXECUTABLE_OUTPUT_PATH`、`LIBRARY_OUTPUT_PATH`：定义最终编译结果的二进制执行文件和库文件的存放目录
* `PROJECT_NAME`：指的是通过`set`设置的`PROJECT`的名称
* `CMAKE_INCLUDE_PATH`、`CMAKE_LIBRARY_PATH`：这两个既可以是系统变量（需要在`bash`中用`export`设置），也可以是`cmake`变量（用`set()`或`-DCMAKE_INCLUDE_PATH=`设置）。用于影响`find_file`以及`find_path`这两个函数的搜索路径
* `CMAKE_MAJOR_VERSION`、`CMAKE_MINOR_VERSION`、`CMAKE_PATCH_VERSION`：主版本号、次版本号，补丁版本号，`2.4.6`中的`2`、`4`、`6`
* `CMAKE_SYSTEM`：系统名称，比如`Linux-2.6.22`
* `CMAKE_SYSTEM_NAME`：不包含版本的系统名，比如`Linux`
* `CMAKE_SYSTEM_VERSION`：系统版本，比如`2.6.22`
* `CMAKE_SYSTEM_PROCESSOR`：处理器名称，比如`i686`
* `UNIX`：在所有的类`UNIX`平台为`TRUE`，包括`OS X`和`cygwin`
* `WIN32`：在所有的`win32`平台为`TRUE`，包括`cygwin`
* `ENV{NAME}`：环境变量，通过`set(ENV{NAME} value)`设置，通过`$ENV{NAME}`引用
* `CMAKE_INSTALL_PREFIX`：安装路径前缀

## 3.2 BUILD_SHARED_LIBS

该参数用于控制`add_library`指令，在缺省类型参数的情况下，生成静态还是动态库

# 4 property

## 4.1 INCLUDE_DIRECTORIES

**去哪找头文件`.h`，`-I（GCC）`**

1. `include_directories`：该方法会在全局维度添加`include`的搜索路径。这些搜索路径会被添加到所有`target`中去（包括所有`sub target`），会追加到所有`target`的`INCLUDE_DIRECTORIES`属性中去
1. `target_include_directories`：该方法为指定`target`添加`include`的搜索路径，会追加到该`target`的`INCLUDE_DIRECTORIES`属性中去

如何查看全局维度以及target维度的`INCLUDE_DIRECTORIES`属性值

```cmake
get_property(dirs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY INCLUDE_DIRECTORIES)
foreach(dir ${dirs})
  message(STATUS "dir of include_directories='${dir}'")
endforeach()

get_target_property(target_dirs <TARGET-NAME> INCLUDE_DIRECTORIES)
foreach(target_dir ${target_dirs})
  message(STATUS "dir of target_include_directories='${target_dir}'")
endforeach()
```

## 4.2 LINK_DIRECTORIES

**去哪找库文件`.so/.dll/.lib/.dylib/...`，`-L（GCC）`**

## 4.3 LINK_LIBRARIES

**需要链接的库文件的名字：`-l（GCC）`**

# 5 command

## 5.1 message

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

## 5.2 set

`set`用于设置：`cmake`变量或环境变量

格式：

* `cmake`变量：`set(<variable> <value>... [PARENT_SCOPE])`
* 环境变量：`set(ENV{<variable>} [<value>]`

变量如何引用：

* `cmake`变量：`${<variable>}`
* 环境变量：`$ENV{<variable>}`

## 5.3 option

`option`用于设置构建选项

格式：`option(<variable> "<help_text>" [value])`

* 其中`value`的可选值就是`ON`和`OFF`，其中`OFF`是默认值

## 5.4 file

`file`用于文件操作

格式：

* `file(READ <filename> <out-var> [...])`
* `file({WRITE | APPEND} <filename> <content>...)`

操作类型说明：

* `READ`：读取文件到变量中
* `WRITE`：覆盖写，文件不存在就创建
* `APPEND`：追加写，文件不存在就创建

## 5.5 add_executable

`add_executable`用于添加可执行文件，示例如下：

```cmake
add_executable(<name> [WIN32] [MACOSX_BUNDLE]
               [EXCLUDE_FROM_ALL]
               [source1] [source2 ...])

# client.cpp ${PROTO_SRC} ${PROTO_HEADER} 都是源文件
add_executable(echo_client client.cpp ${PROTO_SRC} ${PROTO_HEADER})
```

## 5.6 add_library

`add_library`用于生成库文件，格式和示例如下：

* `<name>`：`target`名称
* 第二个参数用于指定库文件类型，可以省略，由`BUILD_SHARED_LIBS`变量控制
  * `STATIC`：静态库
  * `SHARED`：动态库

```cmake
add_library(<name> [STATIC | SHARED | MODULE]
            [EXCLUDE_FROM_ALL]
            [<source>...])

add_library(Exec STATIC ${EXEC_FILES})
```

## 5.7 set_target_properties

为指定`target`设置属性

```cmake
set_target_properties(xxx PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)
```

## 5.8 target_compile_options

为指定`target`设置编译参数

```cmake
target_compile_options(xxx PUBLIC "-O3")
```

## 5.9 Link Libraries

### 5.9.1 link_libraries

[link_libraries](https://cmake.org/cmake/help/latest/command/link_libraries.html)

Link libraries to all targets added later.

```cmake
link_libraries([item1 [item2 [...]]]
               [[debug|optimized|general] <item>] ...)
```

### 5.9.2 target_link_libraries

[target_link_libraries](https://cmake.org/cmake/help/latest/command/target_link_libraries.html)

Specify libraries or flags to use when linking a given target and/or its dependents. Usage requirements from linked library targets will be propagated. Usage requirements of a target's dependencies affect compilation of its own sources.

Each `<item>` may be:

* A library target name
* A full path to a library file
* A plain library name, like `thread`, `dl`
* A link flag

```cmake
target_link_libraries(<target> ... <item>... ...)

# example
target_link_libraries(echo_client ${BRPC_LIB} ${DYNAMIC_LIB})
```

#### 5.9.2.1 Automatic Inclusion of Header File Paths in CMake with target_link_libraries

When using the `target_link_libraries` command in CMake to link a target (such as a library), the related header file paths may automatically be included. This is because modern CMake manages projects based on the concept of "targets," which allows targets to own and propagate attributes used for building and usage, such as include directories, definitions, compile options, etc.

This behavior is primarily achieved through "usage requirements." When you set `INTERFACE`, `PUBLIC`, or `PRIVATE` properties for a target, these properties affect both the target itself and any other targets that link to it:

* `PRIVATE`: These properties are only visible to the target that defines them and do not propagate to other targets that depend on this target.
* `PUBLIC`: These properties apply to both the target that defines them and automatically propagate to any other targets that depend on this target.
* `INTERFACE`: These properties do not apply to the target that defines them but do propagate to any other targets that depend on this target.

**When a library specifies its header file paths in its CMake configuration file using the `target_include_directories` with the `PUBLIC` or `INTERFACE` keywords, these paths automatically become part of the include paths for targets that depend on this library. Therefore, when you link to such a library using `target_link_libraries`, you also implicitly gain access to these include paths.**

This design greatly simplifies dependency management within projects, allowing maintainers to avoid explicitly specifying include paths, compiler, and linker configurations repeatedly. This is also one of the recommended best practices in modern CMake.

## 5.10 Link Directories

### 5.10.1 link_directories

[link_directories](https://cmake.org/cmake/help/latest/command/link_directories.html)

Adds the paths in which the linker should search for libraries. Adds the paths in which the linker should search for libraries. Relative paths given to this command are interpreted as relative to the current source directory. **The command will apply only to targets created after it is called**.

By default the directories specified are appended onto the current list of directories. This default behavior can be changed by setting `CMAKE_LINK_DIRECTORIES_BEFORE` to `ON`. By using `AFTER` or `BEFORE` explicitly, you can select between appending and prepending, independent of the default.

```cmake
link_directories([AFTER|BEFORE] directory1 [directory2 ...])
```

See the below example, only `/pathA/lib` will be added to the library search path.

```cmake
link_directories(/pathA/lib)

add_executable(main)

link_directories(/pathB/lib)
```

### 5.10.2 target_link_directories

[target_link_directories](https://cmake.org/cmake/help/latest/command/target_link_directories.html)

Add link directories to a target. Specifies the paths in which the linker should search for libraries when linking a given target. Each item can be an absolute or relative path, with the latter being interpreted as relative to the current source directory. These items will be added to the link command.

By using `AFTER` or `BEFORE` explicitly, you can select between appending and prepending, independent of the default.

```cmake
target_link_directories(<target> [BEFORE]
  <INTERFACE|PUBLIC|PRIVATE> [items1...]
  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
```

## 5.11 Include Directories

### 5.11.1 include_directories

[include_directories](https://cmake.org/cmake/help/latest/command/include_directories.html)

Add the given directories to those the compiler uses to search for include files. Relative paths are interpreted as relative to the current source directory.

The include directories are added to the `INCLUDE_DIRECTORIES` directory property for the current `CMakeLists` file. They are also added to the `INCLUDE_DIRECTORIES` target property for each target in the current `CMakeLists` file. The target property values are the ones used by the generators.

By default the directories specified are appended onto the current list of directories. This default behavior can be changed by setting `CMAKE_INCLUDE_DIRECTORIES_BEFORE` to `ON`. By using `AFTER` or `BEFORE` explicitly, you can select between appending and prepending, independent of the default.

```cmake
include_directories([AFTER|BEFORE] [SYSTEM] dir1 [dir2 ...])
```

### 5.11.2 target_include_directories

[target_include_directories](https://cmake.org/cmake/help/latest/command/target_include_directories.html)

The `INTERFACE`, `PUBLIC` and `PRIVATE` keywords are required to specify the scope of the following arguments. `PRIVATE` and `PUBLIC` items will populate the `INCLUDE_DIRECTORIES` property of `<target>`. `PUBLIC` and `INTERFACE` items will populate the `INTERFACE_INCLUDE_DIRECTORIES` property of `<target>`. The following arguments specify include directories.

```cmake
target_include_directories(<target> [SYSTEM] [AFTER|BEFORE]
  <INTERFACE|PUBLIC|PRIVATE> [items1...]
  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
```

## 5.12 add_subdirectory

`add_subdirectory`：用于引入一个`cmake`子项目

* `source_dir`：子项目路径，该路径下必须包含`CMakeLists.txt`文件。且必须是子目录，不能是外层目录
* `binary_dir`：二进制路径，生成的可执行文件或者库文件的放置路径
* `EXCLUDE_FROM_ALL`：当指定该参数时，构建父项目时，若无明确依赖子项目（例如通过`target_link_libraries`添加依赖），那么子项目不会被自动构建。若有明确依赖，那么仍然会构建

```cmake
add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL] [SYSTEM])
```

## 5.13 include

`include`：用于引入一个`cmake`子项目。例如`include(src/merger/CMakeLists.txt)`

**`include`和`add_subdirectory`这两个命令都可以用来引入一个`cmake`子项目，它们的区别在于：**

* `add_subdirectory`：该子项目会作为一个独立的`cmake`项目进行处理。所有`CURRENT`相关的变量都会进行切换。此外，`CMakeLists.txt`文件中涉及的所有相对路径，其`base`路径也会切换成`add_subdirectory`指定的目录
* `include`：该子项目不会作为一个独立的`cmake`项目进行处理。只有`CMAKE_CURRENT_LIST_DIR`、`CMAKE_CURRENT_LIST_FILE`这两个`CURRENT`变量会进行切换，而`CMAKE_CURRENT_BINARY_DIR`和`CMAKE_CURRENT_SOURCE_DIR`不会进行切换。此外，`CMakeLists.txt`文件中涉及的所有相对路径，其`base`路径保持不变

## 5.14 find_package

**本小节转载摘录自[Cmake之深入理解find_package()的用法](https://zhuanlan.zhihu.com/p/97369704)**

为了方便我们在项目中引入外部依赖包，`cmake`官方为我们预定义了许多寻找依赖包的`Module`，他们存储在`path_to_your_cmake/share/cmake-<version>/Modules`目录下（例如`/usr/local/lib/cmake-3.21.2-linux-x86_64/share/cmake-3.21/Modules`）。每个以`Find<LibaryName>.cmake`命名的文件都可以帮我们找到一个包。**注意，`find_package(<LibaryName>)`与`Find<LibaryName>.cmake`中的`<LibaryName>`部分，大小写必须完全一致**

我们以`curl`库为例，假设我们项目需要引入这个库，从网站中请求网页到本地，我们看到官方已经定义好了`FindCURL.cmake`。所以我们在`CMakeLists.txt`中可以直接用`find_pakcage`进行引用

对于系统预定义的`Find<LibaryName>.cmake`模块，使用方法如下，每一个模块都会定义以下几个变量（这些信息会在`Find<LibaryName>.cmake`文件的最上方注释中说明）。**注意，这些变量命名只是规范，命名中`<LibaryName>`部分是全部大写还是包含大小写完全由`Find<LibaryName>.cmake`文件决定。一般来说是大写的，例如`FindDemo.cmake`中定义的变量名为`DEMO_FOUND`**

* `<LibaryName>_FOUND`
* `<LibaryName>_INCLUDE_DIR`
* `<LibaryName>_LIBRARY`：该模块通过`add_library`定义的名称
* `<LibaryName>_STATIC_LIB`

```cmake
find_package(CURL)
add_executable(curltest curltest.cc)
if(CURL_FOUND)
    target_include_directories(clib PRIVATE ${CURL_INCLUDE_DIR})
    target_link_libraries(curltest ${CURL_LIBRARY})
else(CURL_FOUND)
    message(FATAL_ERROR ”CURL library not found”)
endif(CURL_FOUND)
```

你可以通过`<LibaryName>_FOUND`来判断模块是否被找到，如果没有找到，按照工程的需要关闭某些特性、给出提醒或者中止编译，上面的例子就是报出致命错误并终止构建。如果`<LibaryName>_FOUND`为真，则将`<LibaryName>_INCLUDE_DIR`加入`INCLUDE_DIRECTORIES`

### 5.14.1 Add Non-Official Library

**通过`find_package`引入非官方的库，该方式只对支持cmake编译安装的库有效**

一般来说说，对于需要引入的三方库`xxx`，步骤通常如下

```sh
git clone https://github.com/xxx.git
cd xxx

mkdir build
cd build

cmake ..
make
make install
```

假设此时我们需要引入`glog`库来进行日志的记录，我们在`Module`目录下并没有找到`FindGlog.cmake`。所以我们需要自行安装`glog`库，再进行引用

```sh
git clone https://github.com/google/glog.git 
cd glog

mkdir build
cd build

# BUILD_SHARED_LIBS用于控制生成动态库还是静态库，默认是动态库，这里我们选择静态库
cmake -DBUILD_SHARED_LIBS=OFF ..
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
make install
```

此时我们便可以通过与引入`curl`库一样的方式引入`glog`库了

```cmake
find_package(GLOG)
add_executable(myexec glogtest.cc)
if(GLOG_FOUND)
    # 由于glog在连接时将头文件直接链接到了库里面，所以这里不用显示调用target_include_directories
    target_link_libraries(myexec glog::glog)
else(GLOG_FOUND)
    message(FATAL_ERROR ”GLOG library not found”)
endif(GLOG_FOUND)
```

### 5.14.2 Module Mode & Config Mode

通过上文我们了解了通过`cmake`引入依赖库的基本用法。知其然也要知其所以然，`find_package`对我们来说是一个黑盒子，那么它是具体通过什么方式来查找到我们依赖的库文件的路径的呢。到这里我们就不得不聊到`find_package`的两种模式，一种是`Module`模式，也就是我们引入`curl`库的方式。另一种叫做`Config`模式，也就是引入`glog`库的模式。下面我们来详细介绍着两种方式的运行机制

在`Module`模式中，`cmake`需要找到一个叫做`Find<LibraryName>.cmake`的文件。这个文件负责找到库所在的路径，为我们的项目引入头文件路径和库文件路径。`cmake`搜索这个文件的路径有两个，一个是上文提到的`cmake`安装目录下的`share/cmake-<version>/Modules`目录（例如`/usr/local/lib/cmake-3.21.2-linux-x86_64/share/cmake-3.21/Modules`），另一个使我们指定的`CMAKE_MODULE_PATH`的所在目录

如果`Module`模式搜索失败，没有找到对应的`Find<LibraryName>.cmake`文件，则转入`Config`模式进行搜索。它主要通过`<LibraryName>Config.cmake`或`<lower-case-package-name>-config.cmake`这两个文件来引入我们需要的库。以我们刚刚安装的`glog`库为例，在我们安装之后，它在`/usr/local/lib/cmake/glog/`目录下生成了`glog-config.cmake`文件，而`/usr/local/lib/cmake/glog/`正是`find_package`函数的搜索路径之一

### 5.14.3 Create Customized `Find<LibraryName>.cmake`

假设我们编写了一个新的函数库，我们希望别的项目可以通过`find_package`对它进行引用我们应该怎么办呢。

我们在当前目录下新建一个`ModuleMode`的文件夹，在里面我们编写一个计算两个整数之和的一个简单的函数库。库函数以手工编写`Makefile`的方式进行安装，库文件安装在`/usr/lib`目录下，头文件放在`/usr/include`目录下。其中的`Makefile`文件如下：

```makefile
# 1、准备工作，编译方式、目标文件名、依赖库路径的定义。
CC = g++
CFLAGS  := -Wall -O3 -std=c++11 

OBJS = libadd.o #.o文件与.cpp文件同名
LIB = libadd.so # 目标文件名
INCLUDE = ./ # 头文件目录
HEADER = libadd.h # 头文件

all : $(LIB)

# 2. 生成.o文件 
$(OBJS) : libadd.cc
    $(CC) $(CFLAGS) -I ./ -fpic -c $< -o $@

# 3. 生成动态库文件
$(LIB) : $(OBJS)
    rm -f $@
    g++ $(OBJS) -shared -o $@ 
    rm -f $(OBJS)

# 4. 删除中间过程生成的文件 
clean:
    rm -f $(OBJS) $(TARGET) $(LIB)

# 5.安装文件
install:
    cp $(LIB) /usr/lib
    cp $(HEADER) /usr/include
```

编译安装：

```sh
make
make install
```

接下来我们回到我们的`cmake`项目中来，在`cmake`文件夹下新建一个`FindAdd.cmake`的文件。我们的目标是找到库的头文件所在目录和共享库文件的所在位置

```cmake
# 在指定目录下寻找头文件和动态库文件的位置，可以指定多个目标路径
find_path(ADD_INCLUDE_DIR libadd.h /usr/include/ /usr/local/include ${CMAKE_SOURCE_DIR}/ModuleMode)
find_library(ADD_LIBRARY NAMES add PATHS /usr/lib/add /usr/local/lib/add ${CMAKE_SOURCE_DIR}/ModuleMode)

if (ADD_INCLUDE_DIR AND ADD_LIBRARY)
    set(ADD_FOUND TRUE)
endif (ADD_INCLUDE_DIR AND ADD_LIBRARY)
```

这时我们便可以像引用`curl`一样引入我们自定义的库了，在`CMakeLists.txt`添加

```cmake
# 将项目目录下的cmake文件夹加入到CMAKE_MODULE_PATH中，让find_pakcage能够找到我们自定义的函数库
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake;${CMAKE_MODULE_PATH}")
add_executable(addtest addtest.cc)
find_package(ADD)
if(ADD_FOUND)
    target_include_directories(addtest PRIVATE ${ADD_INCLUDE_DIR})
    target_link_libraries(addtest ${ADD_LIBRARY})
else(ADD_FOUND)
    message(FATAL_ERROR "ADD library not found")
endif(ADD_FOUND)
```

## 5.15 find_library

`find_library`用于查找库文件，示例如下：

* 所有指定的可能的名字中，只要有一个匹配上了，那么查找过程就终止了
* `CMAKE_FIND_LIBRARY_SUFFIXES`可用于控制优先查找静态库还是优先查找动态库
    * `set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")`：动态库优先，默认值
    * `set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")`：静态库优先

```cmake
set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")
# set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")
find_library(BOOST_FILESYSTEM_LIBRARY NAMES boost_filesystem Boost_filesystem)
find_library(BOOST_SYSTEM_LIBRARY NAMES boost_system Boost_system)

target_link_libraries(${PROJECT_NAME} PRIVATE ${BOOST_FILESYSTEM_LIBRARY} ${BOOST_SYSTEM_LIBRARY})
```

## 5.16 find_path

`find_path`用于查找包含给定文件的目录，示例如下：

* 所有指定的可能的名字中，只要有一个匹配上了，那么查找过程就终止了

```cmake
# NAMES 后可接多个可能的别名，结果保存到变量 BRPC_INCLUDE_PATH 中
find_path(BRPC_INCLUDE_PATH NAMES brpc/server.h)
```

## 5.17 aux_source_directory

Find all source files in a directory

## 5.18 PUBLIC vs. PRIVATE

> In CMake, PUBLIC and PRIVATE are used to specify the visibility of target properties and dependencies. Here's what they mean:

> PUBLIC: A property or dependency marked as PUBLIC is visible to all targets that depend on the current target. This means that the property or dependency will be propagated to any targets that link against the current target.
> * For example, suppose you have a library target called "foo" that depends on another library called "bar". If you mark the dependency on "bar" as PUBLIC, any target that links against "foo" will also link against "bar".

> PRIVATE: A property or dependency marked as PRIVATE is only visible to the current target. This means that the property or dependency will not be propagated to any targets that depend on the current target.
> * For example, suppose you have a library target called "foo" that uses a header file called "bar.h". If you mark the header file as PRIVATE, any targets that depend on "foo" will not be able to access "bar.h".

> To summarize, PUBLIC properties and dependencies are visible to all targets that depend on the current target, while PRIVATE properties and dependencies are only visible to the current target.

示例如下：

```
.
├── CMakeLists.txt
├── bar
│   ├── bar.cpp
│   └── bar.h
├── foo
│   ├── foo.cpp
│   └── foo.h
└── main.cpp
```

```sh
# CMakeLists.txt
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)

# set the project name and version
project(Visibility VERSION 1.0)

# specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# add library bar
add_library(libbar bar/bar.cpp)
target_include_directories(libbar PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/bar)

# add library foo
add_library(libfoo foo/foo.cpp)
target_include_directories(libfoo PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/foo)
target_link_libraries(libfoo PUBLIC libbar)

# add the executable
add_executable(main main.cpp)
target_link_libraries(main PRIVATE libfoo)
EOF

mkdir -p foo

# foo/foo.h
cat > foo/foo.h << 'EOF'
#pragma once

#include <string>

void greet_foo(const std::string& name);
EOF

# foo/foo.cpp
cat > foo/foo.cpp << 'EOF'
#include "foo.h"

#include <iostream>

#include "bar.h"

void greet_foo(const std::string& name) {
    std::cout << "Hello " << name << ", this is foo. And I'll take you to meet bar. ";
    greet_bar("foo");
}
EOF

mkdir -p bar

# bar/bar.h
cat > bar/bar.h << 'EOF'
#pragma once

#include <string>

void greet_bar(const std::string& name);
EOF

# bar/bar.cpp
cat > bar/bar.cpp << 'EOF'
#include "bar.h"

#include <iostream>

void greet_bar(const std::string& name) {
    std::cout << "Hello " << name << ", this is bar." << std::endl;
}
EOF

# main.cpp
cat > main.cpp << 'EOF'
#include "bar.h"
#include "foo.h"

int main() {
    greet_foo("main");
    greet_bar("main");
    return 0;
}
EOF

cmake -B build && cmake --build build
build/main
```

**如果将`target_link_libraries(libfoo PUBLIC libbar)`中的`PUBLIC`改成`PRIVATE`，那么编译将会无法通过，因为`main`没有显式依赖`libbar`，会找不到头文件`bar.h`**

# 6 Tips

## 6.1 Command Line

* `cmake --help`
  * `Generators`，默认使用`Unix Makefiles`
* `build`
  * `cmake <path-to-source>`：当前目录作为`<build_path>`
  * `cmake -S <path-to-source>`：当前目录作为`<build_path>`
  * `cmake -B <build_path>`：当前目录作为`<path-to-source>`
  * `cmake -B <build_path> <path-to-source>`
  * `cmake -B <build_path> -S <path-to-source>`
* `cmake --build <build_path>`：等效于在`<build_path>`中执行`make`命令
  * `cmake --build <build_path> -j $(( (cores=$(nproc))>1?cores/2:1 ))`：等效于在`<build_path>`中执行`make -j $(( (cores=$(nproc))>1?cores/2:1 ))`命令
* `cmake --install <build_path>`：等效于在`<build_path>`中执行`make install`命令

## 6.2 Print

### 6.2.1 Print All Variables

```cmake
get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
```

### 6.2.2 Print All Envs

```cmake
execute_process(COMMAND "${CMAKE_COMMAND}" "-E" "environment")
```

### 6.2.3 Print All Compile Command

TheseWhen using the default generator `Unix Makefiles`, the following three methods are equivalent:

* `cmake -B <build_path> -DCMAKE_VERBOSE_MAKEFILE=ON`
* `make VERBOSE=1`
* `cmake --build <build_path> -- VERBOSE=1`

## 6.3 Compile Options

### 6.3.1 Specify Compiler

**Command:**

```sh
cmake -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ -DCMAKE_C_COMPILER=/usr/local/bin/gcc ..
```

**CMakeLists.txt:**

```cmake
set(CMAKE_C_COMPILER "/path/to/gcc")
set(CMAKE_CXX_COMPILER "/path/to/g++")
```

### 6.3.2 Add Compile Flags

**Command:**

```sh
cmake -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -O3" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -O3" ..
```

**CMakeLists.txt:**

```cmake
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -fopt-info-vec")

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O1 -Wall")
```

**`CMAKE_BUILD_TYPE`的所有可选值包括**

1. `Debug`
1. `Release`
1. `RelWithDebInfo`
1. `MinSizeRel`

### 6.3.3 Macro Definition

**Command:**

```sh
cmake -B build -DUSE_XXX
cmake -B build -DVALUE_YYY=5
```

**CMakeLists.txt:**

```cmake
add_definitions(-DUSE_XXX -DVALUE_YYY=5)
```

### 6.3.4 Add Extra Search Path

```sh
export C_INCLUDE_PATH=
export CPLUS_INCLUDE_PATH=
export LIBRARY_PATH=
```

### 6.3.5 Build Type

```sh
# If you want to build for debug (including source information, i.e. -g) when compiling, use
cmake -DCMAKE_BUILD_TYPE=Debug <path>

# cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo <path>
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo <path>
```

**`CMAKE_BUILD_TYPE`的所有可选值包括**

1. `Debug`
1. `Release`
1. `RelWithDebInfo`
1. `MinSizeRel`

## 6.4 Include All Source File

### 6.4.1 file

```cmake
# Search for all .cpp and .h files in the current directory
file(GLOB MY_PROJECT_SOURCES "*.cpp")

# Add the found files to the executable
add_executable(MyExecutable ${MY_PROJECT_SOURCES})
```

If your project has a more complex structure and you wish to recursively search all subdirectories for files, you can replace the `file(GLOB ...) command with `file(GLOB_RECURSE ...)`:

```cmake
file(GLOB_RECURSE MY_PROJECT_SOURCES "*.cpp")
add_executable(MyExecutable ${MY_PROJECT_SOURCES})
```

### 6.4.2 aux_source_directory

如果同一个目录下有多个源文件，那么在使用`add_executable`命令的时候，如果要一个个填写，那么将会非常麻烦，并且后续维护的代价也很大

```cmake
add_executable(Demo main.cxx opt1.cxx opt2.cxx)
```

我们可以使用`aux_source_directory(<dir> <variable>)`）命令，该命令可以扫描一个目录下得所有源文件，并将文件列表赋值给一个变量

```cmake
# 查找当前目录下的所有源文件
# 并将名称保存到 DIR_SRCS 变量
aux_source_directory(. DIR_SRCS)

# 指定生成目标
add_executable(Demo ${DIR_SRCS})
```

## 6.5 Library

### 6.5.1 Build Static Library By Default

Add following config to project's root `CMakeLists.txt`, then all sub modules (imported via `add_subdirectory`) will be built in static way.

```cmake
set(BUILD_SHARED_LIBS FALSE)
```

### 6.5.2 Import Library From Unified Thirdparty Directory

Suppose you have put all libraries in `${THIRDPARTY_DIR}/lib`, then you can use the following config to import it.

```cmake
add_library(protobuf STATIC IMPORTED)
set_target_properties(protobuf PROPERTIES IMPORTED_LOCATION ${THIRDPARTY_DIR}/lib/libprotobuf.a)
```

### 6.5.3 Priority: Static Libraries vs. Dynamic Libraries

#### 6.5.3.1 find_package

The factors influencing the choice between static and dynamic libraries by the `find_package` command may include:

* **The provided CMake configuration files by the package**: Some packages offer their own CMake configuration files, such as `<PackageName>Config.cmake` (Located at `/usr/local/lib/cmake`). These configuration files may explicitly specify the use of static or dynamic libraries, or make the selection based on the value of the `BUILD_SHARED_LIBS` variable (maybe).
    * For boost, it offers a variable named `Boost_USE_STATIC_LIBS` (Defined at `/usr/local/lib/cmake/Boost-1.84.0/BoostConfig.cmake`) to control whether to use static version or dynamic version.
* **Default behavior**: Certain packages may use specific library types based on conventions or default settings. For instance, if a package typically provides dynamic libraries and does not have explicit configuration options to choose static libraries, the `find_package` command might default to using dynamic libraries.

**Example:**

```cmake
set(Boost_USE_STATIC_LIBS ON)
find_package(Boost REQUIRED COMPONENTS filesystem system)
```

#### 6.5.3.2 find_library

To control whether `find_library` should prefer static libraries or dynamic libraries, you typically set the `CMAKE_FIND_LIBRARY_SUFFIXES` variable. This variable specifies the suffixes that `find_library` searches for when looking for libraries.

Here's how you can control `find_library` to prioritize static libraries or dynamic libraries:

**Prioritize static libraries:**

```cmake
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")
```

**Prioritize dynamic libraries:**

```cmake
set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")
```

## 6.6 compile_commands.json

### 6.6.1 Manually Generate compile_commands.json

`cmake`指定参数`-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`即可。构建完成后，会在构建目录生成`compile_commands.json`，里面包含了每个源文件的编译命令

### 6.6.2 Auto generate compile_commands.json and copy to project source root

参考[Copy compile_commands.json to project root folder](https://stackoverflow.com/questions/57464766/copy-compile-commands-json-to-project-root-folder)

```cmake
add_custom_target(
    copy-compile-commands ALL
    ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_BINARY_DIR}/compile_commands.json
        ${CMAKE_SOURCE_DIR}
    )
```

## 6.7 How to uninstall

After installation, there will be a `install_manifest.txt` recording all the installed files. So we can perform uninstallation by this file.

```sh
xargs rm < install_manifest.txt
```

## 6.8 Ignore -Werror

```sh
cmake --compile-no-warning-as-error -DWERROR=0 ...
```

# 7 Install

**We can get binary distributions from [Get the Software](https://cmake.org/download/):**

```sh
wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2-linux-x86_64.tar.gz

sudo tar -zxvf cmake-3.21.2-linux-x86_64.tar.gz -C /usr/local/lib

sudo ln -s /usr/local/lib/cmake-3.21.2-linux-x86_64/bin/cmake /usr/local/bin/cmake
```

# 8 Reference

* [CMake Tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)
    * [CMake Tutorial对应的source code](https://github.com/Kitware/CMake/tree/master/Help/guide/tutorial)
    * [CMake Tutorial 翻译](https://www.jianshu.com/p/6df3857462cd)
* [CMake 入门实战](https://www.hahack.com/codes/cmake/)
* [CMake 语言 15 分钟入门教程](https://leehao.me/cmake-%E8%AF%AD%E8%A8%80-15-%E5%88%86%E9%92%9F%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B/)
* [CMake Table of Contents](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#manual:cmake-buildsystem(7))
* [What is the difference between include_directories and target_include_directories in CMake?](https://stackoverflow.com/questions/31969547/what-is-the-difference-between-include-directories-and-target-include-directorie/40244458)
* [Cmake之深入理解find_package()的用法](https://zhuanlan.zhihu.com/p/97369704)
