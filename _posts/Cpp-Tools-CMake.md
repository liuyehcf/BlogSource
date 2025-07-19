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

`tutorial.cxx`:

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

`CMakeLists.txt`:

* `cmake_minimum_required`: Used to specify the minimum version of `cmake`, to avoid compatibility issues (includes features from newer versions, but the actual `cmake` version may be lower)
* `project`: Used to set the project name and store it in the `CMAKE_PROJECT_NAME` variable. Some environment variables in `cmake` will use the specified project name as a prefix, such as:
    * `PROJECT_SOURCE_DIR`, `<PROJECT-NAME>_SOURCE_DIR`
    * `PROJECT_BINARY_DIR`, `<PROJECT-NAME>_BINARY_DIR`
* `set`: Used to set some variables
* `add_executable`: Adds a target executable file

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

At this point, the file structure is as follows:

```
.
├── CMakeLists.txt
└── tutorial.cxx
```

Test:

```sh
mkdir build
cd build
cmake ..
make
./Tutorial 256
```

## 1.2 step2: Adding a Library and Adding Usage Requirements for a Library

Next, we will replace the standard library's implementation with our own square root function. Create a `MathFunctions` subdirectory, and in that subdirectory, add three files: `MathFunctions.h`, `mysqrt.cxx`, and `CMakeLists.txt`.

The content of `MathFunctions/MathFunctions.h` is as follows:

```c++
double mysqrt(double x);
```

`MathFunctions/mysqrt.cxx`:

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

`MathFunctions/CMakeLists.txt`:

```cmake
add_library(MathFunctions mysqrt.cxx)
```

Add `TutorialConfig.h.in`:

```c++
#cmakedefine USE_MYMATH
```

Modify `tutorial.cxx`: 

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

Modify `CMakeLists.txt`:

* `option`: Used to add a `cmake` option, which can be enabled or disabled using the `-D<OPTION-NAME>=ON/OFF` parameter  
    * For example: `cmake .. -DUSE_MYMATH=OFF`
* `configure_file`: Commonly used to dynamically generate a header file based on cmake options
* `if statement`: Control flow
* `add_subdirectory`: Used to add a subdirectory to the build task
* `list`: Operations related to containers
* `target_link_libraries`: Specifies library files
* `target_include_directories`: Specifies header file search paths

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

At this point, the file structure is as follows:

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

Test:

```sh
# Use customized sqrt
mkdir build
cd build
cmake ..
make
./Tutorial 256

# Use standard lib sqrt
mkdir build
cd build
cmake .. -DUSE_MYMATH=OFF
make
./Tutorial 256
```

## 1.3 step3: Installing

Now, we want to install the binaries, library files, and header files generated by `make`.

Based on `step2`, modify the `MathFunctions/CMakeLists.txt` file and append the following content:

* Here, two relative paths `lib` and `include` are specified. The prefix is determined by the `cmake` variable `CMAKE_INSTALL_PREFIX`, which defaults to `/usr/local`.

```cmake
# add the install targets
install(TARGETS MathFunctions DESTINATION bin)
install(FILES MathFunctions.h DESTINATION include)
```

Based on `step2`, modify the `CMakeLists.txt` file and append the following content:

```cmake
# add the install targets
install (TARGETS Tutorial DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/TutorialConfig.h" DESTINATION include)
```

Test:

```sh
# Use default installation path
mkdir build
cd build
cmake ..
make
make install

# Specify the installation path
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/tmp/mydir
make
make install
```

## 1.4 step4: Testing

Next, add testing functionality. Based on `step2`, modify the `CMakeLists.txt` file and append the following content:

* `add_test`: Used to add a test, where `NAME` specifies the name of the test case and `RUN` specifies the test command
* `function`: Used to define a method
* `set_tests_properties`: Used to set properties of test cases; here, a wildcard is specified for the test result

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

Test:

```
mkdir build
cd build
cmake ..
make
make test
```

## 1.5 step5: Adding System Introspection

The same library may have different implementations on different platforms. For example, platform A might have the function `funcA`, while platform B does not. Therefore, we need a mechanism to detect such differences.

Next, add testing functionality. Based on `step2`, modify the `MathFunctions/CMakeLists.txt` file and append the following content:

* `include`: Loads a `cmake` module. Here, the `CheckSymbolExists` module is loaded, which is used to check whether a specified symbol exists in a specified file.

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

Modify `MathFunctions/mysqrt.cxx`:

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

Test:

```
mkdir build
cd build
cmake ..
make
./Tutorial 25
```

# 2 target

Probably the most important item is targets. Targets represent executables, libraries, and utilities built by CMake. Every `add_library`, `add_executable`, and `add_custom_target` command creates a target.

In addition to storing their type, targets also keep track of general properties. These properties can be set and retrieved using the `set_target_properties` and `get_target_property` commands, or the more general `set_property` and `get_property` commands.

# 3 variables

In CMake, variables themselves are typeless. CMake variables are stored as strings when defined, but these strings can be interpreted as different types (such as boolean, integer, etc.) through CMake commands and syntax. Below are some common variable types and examples of how to use them in CMake:

1. String
    ```cmake
    set(MY_STRING "Hello, World!")
    message(STATUS "String value: ${MY_STRING}")
    ```

1. Boolean
    ```cmake
    set(MY_BOOL ON)
    if(MY_BOOL)
        message(STATUS "Boolean is ON")
    endif()
    ```

1. Integer
    ```cmake
    set(MY_INT 10)
    math(EXPR MY_INT_PLUS_ONE "${MY_INT} + 1")
    message(STATUS "Integer value: ${MY_INT_PLUS_ONE}")
    ```

1. List
    ```cmake
    set(MY_LIST "item1;item2;item3")
    list(APPEND MY_LIST "item4")
    foreach(item IN LISTS MY_LIST)
        message(STATUS "List item: ${item}")
    endforeach()
    ```

## 3.1 Frequently-Used Variables

Refer to（[cmake-variables](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html)）for details:

* `CMAKE_BINARY_DIR`, `PROJECT_BINARY_DIR`, `<PROJECT-NAME>_BINARY_DIR`: Refers to the directory where the project is built. This variable does not change when recursively processing subprojects  
  * If the `-B` parameter is specified, it is the directory specified by `-B`  
  * If the `-B` parameter is not specified, it is the directory where the `cmake` command is executed
* `CMAKE_SOURCE_DIR`, `PROJECT_SOURCE_DIR`, `<PROJECT-NAME>_SOURCE_DIR`: Refers to the top-level directory of the project. This variable does not change when recursively processing subprojects
* `CMAKE_CURRENT_SOURCE_DIR`: Refers to the project directory currently being processed by `cmake`, usually the directory containing the `CMakeLists.txt` file. This variable changes when recursively processing subprojects  
  * [Difference between CMAKE_CURRENT_SOURCE_DIR and CMAKE_CURRENT_LIST_DIR](https://stackoverflow.com/questions/15662497/difference-between-cmake-current-source-dir-and-cmake-current-list-dir)  
  * If a subproject is included via `include(src/CMakeLists.txt)`, assuming the root directory is `project`, during processing, `CMAKE_CURRENT_SOURCE_DIR` is `project` while `CMAKE_CURRENT_LIST_DIR` is `project/src`
* `CMAKE_CURRENT_BINARY_DIR`: Refers to the target directory where the build output is stored. This variable changes when recursively processing subprojects. It can be changed via `set` command or `ADD_SUBDIRECTORY(src bin)`, but `set(EXECUTABLE_OUTPUT_PATH <new_path>)` does not change this variable, it only affects the final output path
* `CMAKE_CURRENT_LIST_DIR`: Refers to the directory containing the currently processed `CMakeLists.txt`. This variable changes when recursively processing subprojects
* `CMAKE_CURRENT_LIST_FILE`: Refers to the path of the currently processed `CMakeLists.txt`. This variable changes when recursively processing subprojects
* `CMAKE_MODULE_PATH`: The search path for modules used by `include()` and `find_package()` commands
* `EXECUTABLE_OUTPUT_PATH`, `LIBRARY_OUTPUT_PATH`: Define the directories where the final compiled executable and library files are stored
* `PROJECT_NAME`: Refers to the project name set by `set(PROJECT_NAME ...)`
* `CMAKE_INCLUDE_PATH`, `CMAKE_LIBRARY_PATH`: These can be system environment variables (set via `export` in bash) or cmake variables (set by `set()` or `-DCMAKE_INCLUDE_PATH=`). `CMAKE_INCLUDE_PATH` affects the search paths for `find_file` and `find_path`, while `CMAKE_LIBRARY_PATH` affects the search path for `find_library`
* `CMAKE_MAJOR_VERSION`, `CMAKE_MINOR_VERSION`, `CMAKE_PATCH_VERSION`: Major, minor, and patch version numbers respectively; e.g., in `2.4.6`, `2` is major, `4` is minor, `6` is patch
* `CMAKE_SYSTEM`: System name, e.g., `Linux-2.6.22`
* `CMAKE_SYSTEM_NAME`: System name without version, e.g., `Linux`
* `CMAKE_SYSTEM_VERSION`: System version, e.g., `2.6.22`
* `CMAKE_SYSTEM_PROCESSOR`: Processor name, e.g., `i686`
* `UNIX`: `TRUE` on all UNIX-like platforms, including OS X and Cygwin
* `WIN32`: `TRUE` on all Win32 platforms, including Cygwin
* `ENV{NAME}`: Environment variable; set via `set(ENV{NAME} value)` and referenced by `$ENV{NAME}`
* `CMAKE_INSTALL_PREFIX`: Installation path prefix
* `CMAKE_PREFIX_PATH`: Semicolon-separated list of directories specifying installation prefixes to be searched by the `find_package()`, `find_program()`, `find_library()`, `find_file()`, and `find_path()` commands. Each command will add appropriate subdirectories (like `bin`, `lib`, or `include`) as specified in its own documentation.

### 3.1.1 BUILD_SHARED_LIBS

This parameter is used to control the `add_library` command, determining whether to generate a static or dynamic library when the type parameter is omitted.

## 3.2 Cached Variables

Sets the given cache `<variable>` (cache entry). Since cache entries are meant to provide user-settable values this does not overwrite existing cache entries by default. Use the `FORCE` option to overwrite existing entries.

```cmake
set(<variable> <value>... CACHE <type> <docstring> [FORCE])
```

```sh
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

set(FOO "foo1" CACHE STRING "foo")
message("FOO='${FOO}'")

# This assignment will never work
set(FOO "foo2" CACHE STRING "foo")
message("FOO='${FOO}'")

set(BAR "bar1" CACHE STRING "bar" FORCE)
message("BAR='${BAR}'")

# This assignment will always work
set(BAR "bar2" CACHE STRING "bar" FORCE)
message("BAR='${BAR}'")
EOF

echo -e "\n\nFirst run:"
cmake -B build
cmake -L -N build

echo -e "\n\nSecond run:"
cmake -DFOO="exist_foo" -DBAR="exist_bar" -B build
cmake -L -N build

echo -e "\n\nThird run:"
cmake -B build
cmake -L -N build
```

**Tips:**

* `cmake -L -N build`: view all non-advanced cached variables.
* `cmake -LA -N build`: view all cached variables, including advanced cached.

# 4 property

## 4.1 INCLUDE_DIRECTORIES

**Where to find header files `.h`, `-I (GCC)`**

1. `include_directories`: This method adds include search paths at a global scope. These search paths are added to all targets (including all sub-targets) and appended to the `INCLUDE_DIRECTORIES` property of every target.  
2. `target_include_directories`: This method adds include search paths to a specific target and appends them to that target's `INCLUDE_DIRECTORIES` property.

How to view the values of the `INCLUDE_DIRECTORIES` property at both the global scope and the target scope

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

**Where to find library files `.so/.dll/.lib/.dylib/...`, `-L (GCC)`**

## 4.3 LINK_LIBRARIES

**Names of libraries to link: `-l (GCC)`**

# 5 command

## 5.1 message

Used to print messages

Format: `message([<mode>] "message text" ...)`

Valid `mode` values include:

* `FATAL_ERROR`: Fatal error, terminates the build
* `SEND_ERROR`: Continues the build but terminates generation
* `WARNING`: Warning message, continues the build
* `AUTHOR_WARNING`: Warning message, continues the build
* `DEPRECATION`: When `CMAKE_ERROR_DEPRECATED` or `CMAKE_WARN_DEPRECATED` is enabled, prints error or warning messages if deprecated features are used
* `NOTICE`: Message printed via `stderr`
* **`STATUS`: The message users should pay most attention to**
* `VERBOSE`: Information for project builders
* `DEBUG`: Information for project debugging
* `TRACE`: Lowest level of information

## 5.2 set

`set` is used to set: `cmake` variables or environment variables

Format:

* `cmake` variable: `set(<variable> <value>... [PARENT_SCOPE])`
* Environment variable: `set(ENV{<variable>} [<value>])`

How to reference variables:

* `cmake` variable: `${<variable>}`
* Environment variable: `$ENV{<variable>}`

## 5.3 option

`option` is used to set build options

Format: `option(<variable> "<help_text>" [value])`

* The optional `value` can be `ON` or `OFF`, with `OFF` as the default

## 5.4 file

`file` is used for file operations

Format:

* `file(READ <filename> <out-var> [...])`
* `file({WRITE | APPEND} <filename> <content>...)`

Operation types explained:

* `READ`: Reads a file into a variable
* `WRITE`: Overwrites the file; creates it if it does not exist
* `APPEND`: Appends to the file; creates it if it does not exist

## 5.5 list

List support many subcommands:

* `APPEND`
* `PREPEND`
* `POP_BACK`
* `POP_FRONT`
* `REMOVE_AT`
* `REMOVE_ITEM`
* `REMOVE_DUPLICATES`
* ...

## 5.6 add_executable

`add_executable` is used to add an executable file. Example as follows:

```cmake
add_executable(<name> [WIN32] [MACOSX_BUNDLE]
               [EXCLUDE_FROM_ALL]
               [source1] [source2 ...])

# client.cpp ${PROTO_SRC} ${PROTO_HEADER} Both are source files
add_executable(echo_client client.cpp ${PROTO_SRC} ${PROTO_HEADER})
```

## 5.7 add_library

`add_library` is used to generate library files. Format and example as follows:

* `<name>`: Name of the `target`
* The second parameter specifies the library type and can be omitted; controlled by the `BUILD_SHARED_LIBS` variable  
  * `STATIC`: Static library  
  * `SHARED`: Shared (dynamic) library

```cmake
add_library(<name> [STATIC | SHARED | MODULE]
            [EXCLUDE_FROM_ALL]
            [<source>...])

add_library(Exec STATIC ${EXEC_FILES})
```

## 5.8 add_custom_target

Adds a target with the given name that executes the given commands:

* `ALL`: Indicate that this target should be added to the default build target so that it will be run every time.
    * If `add_subdirectory` is specified with the `EXCLUDE_FROM_ALL` option, then the `ALL` option becomes ineffective.
* `DEPENDS`: Reference files and outputs of custom commands created with `add_custom_command` command calls in the same directory (`CMakeLists.txt` file). They will be brought up to date when the target is built.
* `VERBATIM`: All arguments to the commands will be escaped properly for the build tool so that the invoked command receives each argument unchanged.

```cmake
add_custom_target(Name [ALL] [command1 [args1...]]
                  [COMMAND command2 [args2...] ...]
                  [DEPENDS depend depend depend ... ]
                  [BYPRODUCTS [files...]]
                  [WORKING_DIRECTORY dir]
                  [COMMENT comment]
                  [JOB_POOL job_pool]
                  [JOB_SERVER_AWARE <bool>]
                  [VERBATIM] [USES_TERMINAL]
                  [COMMAND_EXPAND_LISTS]
                  [SOURCES src1 [src2...]])
```

### 5.8.1 add_custom_command

This defines a command to generate specified `OUTPUT` file(s). A target created in the same directory (`CMakeLists.txt` file) that specifies any output of the custom command as a source file is given a rule to generate the file using the command at build time

* `WORKING_DIRECTORY`: Execute the command with the given current working directory.
* `VERBATIM`: All arguments to the commands will be escaped properly for the build tool so that the invoked command receives each argument unchanged.
* `DEPENDS`: Specify files on which the command depends. If any dependency is an `OUTPUT` of another custom command in the same directory (`CMakeLists.txt` file), CMake automatically brings the other custom command into the target in which this command is built. **If `DEPENDS` is not specified, the command will run whenever the `OUTPUT` is missing; if the command does not actually create the OUTPUT, the rule will always run.** Each argument is converted to a dependency as follows:
    * If the argument is the name of a target (created by the `add_custom_target()`, `add_executable()`, or `add_library()` command) a target-level dependency is created to make sure the target is built before any target using this custom command. Additionally, if the target is an executable or library, a file-level dependency is created to cause the custom command to re-run whenever the target is recompiled.
    * If the argument is an absolute path, a file-level dependency is created on that path.
    * If the argument is the name of a source file that has been added to a target or on which a source file property has been set, a file-level dependency is created on that source file.
    * If the argument is a relative path and it exists in the current source directory, a file-level dependency is created on that file in the current source directory.
    * Otherwise, a file-level dependency is created on that path relative to the current binary directory.

```cmake
add_custom_command(OUTPUT output1 [output2 ...]
                   COMMAND command1 [ARGS] [args1...]
                   [COMMAND command2 [ARGS] [args2...] ...]
                   [MAIN_DEPENDENCY depend]
                   [DEPENDS [depends...]]
                   [BYPRODUCTS [files...]]
                   [IMPLICIT_DEPENDS <lang1> depend1
                                    [<lang2> depend2] ...]
                   [WORKING_DIRECTORY dir]
                   [COMMENT comment]
                   [DEPFILE depfile]
                   [JOB_POOL job_pool]
                   [JOB_SERVER_AWARE <bool>]
                   [VERBATIM] [APPEND] [USES_TERMINAL]
                   [COMMAND_EXPAND_LISTS]
                   [DEPENDS_EXPLICIT_ONLY])
```

## 5.9 set_target_properties

Set properties for the specified `target`

```cmake
set_target_properties(xxx PROPERTIES
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED YES
    CXX_EXTENSIONS NO
)
```

## 5.10 target_compile_options

Set compile options for the specified `target`

```cmake
target_compile_options(xxx PUBLIC "-O3")
```

## 5.11 add_dependencies

Add a dependency between top-level targets.

```cmake
add_dependencies(<target> [<target-dependency>]...)
```

## 5.12 Link Libraries

### 5.12.1 link_libraries

[link_libraries](https://cmake.org/cmake/help/latest/command/link_libraries.html)

Link libraries to all targets added later.

```cmake
link_libraries([item1 [item2 [...]]]
               [[debug|optimized|general] <item>] ...)
```

### 5.12.2 target_link_libraries

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

#### 5.12.2.1 Automatic Inclusion of Header File Paths in CMake with target_link_libraries

When using the `target_link_libraries` command in CMake to link a target (such as a library), the related header file paths may automatically be included. This is because modern CMake manages projects based on the concept of "targets," which allows targets to own and propagate attributes used for building and usage, such as include directories, definitions, compile options, etc.

This behavior is primarily achieved through "usage requirements." When you set `INTERFACE`, `PUBLIC`, or `PRIVATE` properties for a target, these properties affect both the target itself and any other targets that link to it:

* `PRIVATE`: These properties are only visible to the target that defines them and do not propagate to other targets that depend on this target.
* `PUBLIC`: These properties apply to both the target that defines them and automatically propagate to any other targets that depend on this target.
* `INTERFACE`: These properties do not apply to the target that defines them but do propagate to any other targets that depend on this target.

**When a library specifies its header file paths in its CMake configuration file using the `target_include_directories` with the `PUBLIC` or `INTERFACE` keywords, these paths automatically become part of the include paths for targets that depend on this library. Therefore, when you link to such a library using `target_link_libraries`, you also implicitly gain access to these include paths.**

This design greatly simplifies dependency management within projects, allowing maintainers to avoid explicitly specifying include paths, compiler, and linker configurations repeatedly. This is also one of the recommended best practices in modern CMake.

## 5.13 Link Directories

### 5.13.1 link_directories

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

### 5.13.2 target_link_directories

[target_link_directories](https://cmake.org/cmake/help/latest/command/target_link_directories.html)

Add link directories to a target. Specifies the paths in which the linker should search for libraries when linking a given target. Each item can be an absolute or relative path, with the latter being interpreted as relative to the current source directory. These items will be added to the link command.

By using `AFTER` or `BEFORE` explicitly, you can select between appending and prepending, independent of the default.

```cmake
target_link_directories(<target> [BEFORE]
  <INTERFACE|PUBLIC|PRIVATE> [items1...]
  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
```

## 5.14 Include Directories

### 5.14.1 include_directories

[include_directories](https://cmake.org/cmake/help/latest/command/include_directories.html)

Add the given directories to those the compiler uses to search for include files. Relative paths are interpreted as relative to the current source directory.

The include directories are added to the `INCLUDE_DIRECTORIES` directory property for the current `CMakeLists` file. They are also added to the `INCLUDE_DIRECTORIES` target property for each target in the current `CMakeLists` file. The target property values are the ones used by the generators.

By default the directories specified are appended onto the current list of directories. This default behavior can be changed by setting `CMAKE_INCLUDE_DIRECTORIES_BEFORE` to `ON`. By using `AFTER` or `BEFORE` explicitly, you can select between appending and prepending, independent of the default.

```cmake
include_directories([AFTER|BEFORE] [SYSTEM] dir1 [dir2 ...])
```

### 5.14.2 target_include_directories

[target_include_directories](https://cmake.org/cmake/help/latest/command/target_include_directories.html)

The `INTERFACE`, `PUBLIC` and `PRIVATE` keywords are required to specify the scope of the following arguments. `PRIVATE` and `PUBLIC` items will populate the `INCLUDE_DIRECTORIES` property of `<target>`. `PUBLIC` and `INTERFACE` items will populate the `INTERFACE_INCLUDE_DIRECTORIES` property of `<target>`. The following arguments specify include directories.

```cmake
target_include_directories(<target> [SYSTEM] [AFTER|BEFORE]
  <INTERFACE|PUBLIC|PRIVATE> [items1...]
  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
```

## 5.15 add_subdirectory

`add_subdirectory` is used to add a subdirectory to current build target.

* `EXCLUDE_FROM_ALL`: If the `EXCLUDE_FROM_ALL` argument is provided then the `EXCLUDE_FROM_ALL` property will be set on the added directory. This will exclude the directory from a default build. You can use the `add_dependencies` and `target_link_libraries` commands to explicitly add dependencies, thereby incorporating the relevant targets into the default build process.

```cmake
add_subdirectory(source_dir [binary_dir] [EXCLUDE_FROM_ALL] [SYSTEM])
```

## 5.16 include

`include`: Used to include a `cmake` subproject. For example, `include(src/merger/CMakeLists.txt)`

**Both `include` and `add_subdirectory` commands can be used to include a `cmake` subproject. The difference between them is:**

* `add_subdirectory`: The subproject is treated as an independent `cmake` project. All `CURRENT`-related variables are switched accordingly. Additionally, all relative paths in the `CMakeLists.txt` file have their base paths switched to the directory specified by `add_subdirectory`.
* `include`: The subproject is not treated as an independent `cmake` project. Only the `CMAKE_CURRENT_LIST_DIR` and `CMAKE_CURRENT_LIST_FILE` `CURRENT` variables are switched, while `CMAKE_CURRENT_BINARY_DIR` and `CMAKE_CURRENT_SOURCE_DIR` remain unchanged. Moreover, the base paths for all relative paths in the `CMakeLists.txt` file stay the same.

## 5.17 find_package

**This section is reprinted and excerpted from [In-depth Understanding of the Usage of find_package() in CMake](https://zhuanlan.zhihu.com/p/97369704)**

To conveniently include external dependencies in our project, `cmake` officially predefines many modules to find dependency packages. These modules are stored in the `path_to_your_cmake/share/cmake-<version>/Modules` directory (for example, `/usr/local/lib/cmake-3.21.2-linux-x86_64/share/cmake-3.21/Modules`). Each file named `Find<LibraryName>.cmake` helps locate a package. **Note that the `<LibraryName>` part in `find_package(<LibraryName>)` and in `Find<LibraryName>.cmake` must match exactly in case.**

Taking the `curl` library as an example, suppose our project needs to include this library to request web pages from websites to local. We see that the official distribution already defines `FindCURL.cmake`. So we can directly use `find_package` in our `CMakeLists.txt` to reference it.

For system-predefined `Find<LibraryName>.cmake` modules, the usage is as follows. Each module defines several variables (this information is explained in comments at the top of the `Find<LibraryName>.cmake` file). **Note that the naming of these variables is just a convention; whether the `<LibraryName>` part is all uppercase or mixed case depends entirely on the `Find<LibraryName>.cmake` file. Generally, it is uppercase. For example, the variables defined in `FindDemo.cmake` are named `DEMO_FOUND`.**

* `<LibaryName>_FOUND`
* `<LibaryName>_INCLUDE_DIR`
* `<LibaryName>_LIBRARY`: The name defined by this module via `add_library`
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

You can use `<LibraryName>_FOUND` to check whether the module was found. If it was not found, you can disable certain features, give warnings, or stop the build depending on the project's needs. The example above shows how to report a fatal error and terminate the build. If `<LibraryName>_FOUND` is true, then `<LibraryName>_INCLUDE_DIR` is added to `INCLUDE_DIRECTORIES`.

### 5.17.1 Add Non-Official Library

**Using `find_package` to include non-official libraries — this method only works for libraries that support CMake build and installation**

Generally, for a third-party library `xxx` that needs to be included, the usual steps are as follows:

```sh
git clone https://github.com/xxx.git
cd xxx

mkdir build
cd build

cmake ..
make
make install
```

Suppose we need to include the `glog` library for logging, but we do not find `FindGlog.cmake` in the `Module` directory. Therefore, we need to install the `glog` library ourselves before referencing it.

```sh
git clone https://github.com/google/glog.git 
cd glog

mkdir build
cd build

# `BUILD_SHARED_LIBS` is used to control whether to build shared (dynamic) or static libraries. The default is shared libraries; here we choose static libraries.
cmake -DBUILD_SHARED_LIBS=OFF ..
make -j $(( (cores=$(nproc))>1?cores/2:1 ))
make install
```

At this point, we can include the `glog` library in the same way as we included the `curl` library.

```cmake
find_package(GLOG)
add_executable(myexec glogtest.cc)
if(GLOG_FOUND)
    # Since glog links the header files directly into the library during linking, there is no need to explicitly call `target_include_directories` here.
    target_link_libraries(myexec glog::glog)
else(GLOG_FOUND)
    message(FATAL_ERROR ”GLOG library not found”)
endif(GLOG_FOUND)
```

### 5.17.2 Module Mode & Config Mode

From the above, we have learned the basic usage of including dependency libraries via `cmake`. Knowing what to do is important, but understanding why is equally crucial. `find_package` is somewhat of a black box to us, so how exactly does it find the paths of the libraries we depend on? Here we need to talk about two modes of `find_package`: one is the `Module` mode — the way we included the `curl` library; the other is the `Config` mode — the way we included the `glog` library. Below, we explain the operation mechanisms of these two modes in detail.

In `Module` mode, `cmake` needs to find a file called `Find<LibraryName>.cmake`. This file is responsible for locating the library paths and adding the include and library paths to our project. `cmake` searches for this file in two places: one is the `share/cmake-<version>/Modules` directory under the cmake installation directory mentioned earlier (for example, `/usr/local/lib/cmake-3.21.2-linux-x86_64/share/cmake-3.21/Modules`), and the other is the directory specified by the `CMAKE_MODULE_PATH` variable.

If the search in `Module` mode fails and the corresponding `Find<LibraryName>.cmake` file is not found, `cmake` switches to `Config` mode. In this mode, it mainly looks for `<LibraryName>Config.cmake` or `<lower-case-package-name>-config.cmake` files to include the libraries we need. For example, for the `glog` library we just installed, after installation, it generates a `glog-config.cmake` file in the `/usr/local/lib/cmake/glog/` directory, which is one of the search paths of the `find_package` function.

### 5.17.3 Create Customized `Find<LibraryName>.cmake`

Suppose we have written a new function library and we want other projects to reference it via `find_package`. What should we do?

We create a `ModuleMode` folder in the current directory, where we write a simple function library that calculates the sum of two integers. The library is installed manually using a `Makefile`. The library files are installed in the `/usr/lib` directory, and the header files are placed in `/usr/include`. The `Makefile` file is as follows:

```makefile
# 1. Preparation: compilation method, target file name, and dependency library path definitions.
CC = g++
CFLAGS := -Wall -O3 -std=c++11

OBJS = libadd.o  # .o file has the same name as the .cpp file
LIB = libadd.so  # Target file name
INCLUDE = ./     # Header file directory
HEADER = libadd.h  # Header file

all : $(LIB)

# 2. Generate .o file
$(OBJS) : libadd.cc
    $(CC) $(CFLAGS) -I ./ -fpic -c $< -o $@

# 3. Generate shared library file
$(LIB) : $(OBJS)
    rm -f $@
    g++ $(OBJS) -shared -o $@
    rm -f $(OBJS)

# 4. Clean intermediate generated files
clean:
    rm -f $(OBJS) $(TARGET) $(LIB)

# 5. Install files
install:
    cp $(LIB) /usr/lib
    cp $(HEADER) /usr/include
```

Compile and install:

```sh
make
make install
```

Next, we return to our `cmake` project and create a `FindAdd.cmake` file under the `cmake` folder. Our goal is to locate the directory containing the library's header files and the location of the shared library file.

```cmake
# Find the locations of header files and shared library files in specified directories; multiple target paths can be specified
find_path(ADD_INCLUDE_DIR libadd.h /usr/include/ /usr/local/include ${CMAKE_SOURCE_DIR}/ModuleMode)
find_library(ADD_LIBRARY NAMES add PATHS /usr/lib/add /usr/local/lib/add ${CMAKE_SOURCE_DIR}/ModuleMode)

if (ADD_INCLUDE_DIR AND ADD_LIBRARY)
    set(ADD_FOUND TRUE)
endif (ADD_INCLUDE_DIR AND ADD_LIBRARY)
```

At this point, we can include our custom library just like `curl`. Add the following to `CMakeLists.txt`:

```cmake
# Add the `cmake` folder under the project directory to `CMAKE_MODULE_PATH` so that `find_package` can locate our custom function library.
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

## 5.18 find_library

`find_library` is used to locate library files. Example usage:

* The search stops as soon as one of the specified possible names matches.
* `CMAKE_FIND_LIBRARY_SUFFIXES` controls whether to prioritize static or shared libraries.
    * `set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")`: Prioritize shared libraries (default)
    * `set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")`: Prioritize static libraries

```cmake
set(CMAKE_FIND_LIBRARY_SUFFIXES ".so;.a")
# set(CMAKE_FIND_LIBRARY_SUFFIXES ".a;.so")
find_library(BOOST_FILESYSTEM_LIBRARY NAMES boost_filesystem Boost_filesystem)
find_library(BOOST_SYSTEM_LIBRARY NAMES boost_system Boost_system)

target_link_libraries(${PROJECT_NAME} PRIVATE ${BOOST_FILESYSTEM_LIBRARY} ${BOOST_SYSTEM_LIBRARY})
```

## 5.19 find_path

`find_path` is used to find the directory containing a given file. Example usage:

* The search stops as soon as one of the specified possible names matches.

```cmake
# Multiple possible names can be provided after `NAMES`. The result is saved to the variable `BRPC_INCLUDE_PATH`.
find_path(BRPC_INCLUDE_PATH NAMES brpc/server.h)
```

## 5.20 aux_source_directory

Find all source files in a directory

## 5.21 PUBLIC vs. PRIVATE

> In CMake, PUBLIC and PRIVATE are used to specify the visibility of target properties and dependencies. Here's what they mean:

> PUBLIC: A property or dependency marked as PUBLIC is visible to all targets that depend on the current target. This means that the property or dependency will be propagated to any targets that link against the current target.
> * For example, suppose you have a library target called "foo" that depends on another library called "bar". If you mark the dependency on "bar" as PUBLIC, any target that links against "foo" will also link against "bar".

> PRIVATE: A property or dependency marked as PRIVATE is only visible to the current target. This means that the property or dependency will not be propagated to any targets that depend on the current target.
> * For example, suppose you have a library target called "foo" that uses a header file called "bar.h". If you mark the header file as PRIVATE, any targets that depend on "foo" will not be able to access "bar.h".

> To summarize, PUBLIC properties and dependencies are visible to all targets that depend on the current target, while PRIVATE properties and dependencies are only visible to the current target.

Example as follows:

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

**If `PUBLIC` in `target_link_libraries(libfoo PUBLIC libbar)` is changed to `PRIVATE`, the compilation will fail because `main` does not explicitly depend on `libbar`, and the header file `bar.h` will not be found.**

## 5.22 External Project

### 5.22.1 ExternalProject_Add

[ExternalProject](https://cmake.org/cmake/help/latest/module/ExternalProject.html)

The `ExternalProject_Add()` function creates a custom target to drive download, update/patch, configure, build, install and test steps of an external project.

All the options can be divided into following categories:

* Directory Options
* Download Step Options
    * URL
    * Git
    * Subversion
    * Mercurial
    * CVS
* Update Step Options
* Patch Step Options
* Configure Step Options
* Build Step Options
* Install Step Options
* Test Step Options
* Output Logging Options
* Terminal Access Options
* Target Options
* Miscellaneous Options

# 6 Tips

## 6.1 Command Line

* `cmake --help`
  * `Generators`: Default is `Unix Makefiles`
* `build`
  * `cmake <path-to-source>`: Current directory is used as `<build_path>`
  * `cmake -S <path-to-source>`: Current directory is used as `<build_path>`
  * `cmake -B <build_path>`: Current directory is used as `<path-to-source>`
  * `cmake -B <build_path> <path-to-source>`
  * `cmake -B <build_path> -S <path-to-source>`
* `cmake --build <build_path>`: Equivalent to running `make` inside `<build_path>`
  * `cmake --build <build_path> -j $(( (cores=$(nproc))>1?cores/2:1 ))`: Equivalent to running `make -j $(( (cores=$(nproc))>1?cores/2:1 ))` inside `<build_path>`
* `cmake --install <build_path>`: Equivalent to running `make install` inside `<build_path>`

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

### 6.2.4 Cmake Debug Options

* `--trace`: Put cmake in trace mode.
* `--trace-expand`: Put cmake in trace mode with variable.
* `--debug-find`: Put cmake find in a debug mode.

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
add_compile_options(-O3 -Wall -fopt-info-vec)

set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O1 -Wall")
```

**`CMAKE_BUILD_TYPE` options values:**

1. `Debug`
1. `Release`
1. `RelWithDebInfo`
1. `MinSizeRel`

### 6.3.3 Use CMake Options and Variables as Macro

```sh
mkdir -p option_as_macro_demo
cd option_as_macro_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(option_as_macro_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

option(OPT_1 "Use OPT_1" ON)
option(OPT_2 "Use OPT_1" ON)
# Normal variable variable cannot be modified via cmake command
# Cache variable can be modified via cmake command
set(BOOL_VAR_1 ON)
set(BOOL_VAR_2 ON CACHE BOOL "This is a cache variable BOOL_VAR_2")
set(STR_VAR_1 "Default Value1")
set(STR_VAR_2 "Default Value2" CACHE STRING "This is a cache variable STR_VAR_2")

configure_file(${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_BINARY_DIR}/config.h)

add_compile_options(-O3 -Wall)

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR})
EOF

cat > config.h.in << 'EOF'
#pragma once

#cmakedefine01 OPT_1
#cmakedefine01 OPT_2

#cmakedefine01 BOOL_VAR_1
#cmakedefine01 BOOL_VAR_2

#cmakedefine STR_VAR_1 "@STR_VAR_1@"
#cmakedefine STR_VAR_2 "@STR_VAR_2@"
EOF

cat > option_as_macro_demo.cpp << 'EOF'
#include <iostream>

#include "config.h"

int main() {
    std::cout << "OPT_1: " << OPT_1 << std::endl;
    std::cout << "OPT_2: " << OPT_2 << std::endl;
    std::cout << "BOOL_VAR_1: " << BOOL_VAR_1 << std::endl;
    std::cout << "BOOL_VAR_2: " << BOOL_VAR_2 << std::endl;
    std::cout << "STR_VAR_1: " << STR_VAR_1 << std::endl;
    std::cout << "STR_VAR_2: " << STR_VAR_2 << std::endl;
    return 0;
}
EOF

cmake -B build -DOPT_2=0 -DBOOL_VAR_1=0 -DBOOL_VAR_2=0 -DSTR_VAR_1="Changed Value1" -DSTR_VAR_2="Changed Value2"
cmake --build build
build/option_as_macro_demo
```

Output:

```
OPT_1: 1
OPT_2: 0
BOOL_VAR_1: 1
BOOL_VAR_2: 0
STR_VAR_1: Default Value1
STR_VAR_2: Changed Value2
```

### 6.3.4 Macro Definition

**Command:**

```sh
cmake -B build -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -DUSE_XXX -DVALUE_YYY=5" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -DUSE_XXX -DVALUE_YYY=5"
```

**CMakeLists.txt:**

```cmake
add_compile_definitions(FLAG1 FLAG2="Debug")

target_compile_definitions(foo PUBLIC FLAG1 FLAG2="Debug")
```

### 6.3.5 Add Extra Search Path

The only way I can find so far to add extra search path out of the `CMakeLists.txt` are using following environments.

* `CMAKE_INCLUDE_PATH` won't work, it only affects the search path of `find_file` and `find_path`
* `CMAKE_LIBRARY_PATH` won't work, it only affects the search path of `find_library`

```sh
export C_INCLUDE_PATH=
export CPLUS_INCLUDE_PATH=
export LIBRARY_PATH=
```

### 6.3.6 Add Extra Runtime Search Path

```cmake
set_target_properties(<target> PROPERTIES LINK_FLAGS "-Wl,-rpath,'/usr/lib/jvm/default-java/lib/server'")
```

You can check if it works by this command: 

```sh
readelf -d <binary> | grep 'RPATH\|RUNPATH'
```

### 6.3.7 Set Library Search Path

Sometimes, you may use `find_package` to include libraries, but multiple versions of the same library might exist in different paths on your system. By using the `-DCMAKE_PREFIX_PATH` option, you can specify which paths CMake should search.

```cmake
cmake -B build -DCMAKE_PREFIX_PATH=/usr/local
```

### 6.3.8 Build Type

```sh
# If you want to build for debug (including source information, i.e. -g) when compiling, use
cmake -DCMAKE_BUILD_TYPE=Debug <path>

# cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo <path>
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo <path>
```

**All possible values of `CMAKE_BUILD_TYPE` include:**

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

If your project has a more complex structure and you wish to recursively search all subdirectories for files, you can replace the `file(GLOB ...)` command with `file(GLOB_RECURSE ...)`:

```cmake
file(GLOB_RECURSE MY_PROJECT_SOURCES "*.cpp")
add_executable(MyExecutable ${MY_PROJECT_SOURCES})
```

### 6.4.2 aux_source_directory

If there are multiple source files in the same directory, listing them one by one in the `add_executable` command can be very tedious and costly to maintain later.

```cmake
add_executable(Demo main.cxx opt1.cxx opt2.cxx)
```

We can use the `aux_source_directory(<dir> <variable>)` command, which scans all source files in a directory and assigns the list of files to a variable.

```cmake
# Find all source files in the current directory  
# and save their names to the variable DIR_SRCS  
aux_source_directory(. DIR_SRCS)

# Specify the target to generate
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

## 6.6 Custom Command/Target

### 6.6.1 How to make custom command as part of build?

There are three ways:

* Use `add_custom_target` with auto build (The keyword `ALL`):
    ```sh
    mkdir -p custom_command_demo_1
    cd custom_command_demo_1
    cat > CMakeLists.txt << 'EOF'
    cmake_minimum_required(VERSION 3.20)

    project(custom_command_demo_1)

    add_custom_target(${PROJECT_NAME} ALL
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, first message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, second message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, third message"
        VERBATIM
    )
    EOF

    cmake -B build && cmake --build build
    ```

* Use `add_custom_command` and `add_custom_target` with auto build (The keyword `ALL`):
    ```sh
    mkdir -p custom_command_demo_2
    cd custom_command_demo_2
    cat > CMakeLists.txt << 'EOF'
    cmake_minimum_required(VERSION 3.20)

    project(custom_command_demo_2)

    add_custom_command(
        OUTPUT say_hello.txt
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, first message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, second message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, third message"
        COMMAND ${CMAKE_COMMAND} -E echo "Write this to a file" > say_hello.txt
        VERBATIM
    )

    add_custom_target(${PROJECT_NAME} ALL
        DEPENDS say_hello.txt
    )
    EOF

    cmake -B build && cmake --build build
    ```

* Use `add_custom_target` and `add_dependencies`:
    ```sh
    mkdir -p custom_command_demo_3
    cd custom_command_demo_3
    cat > CMakeLists.txt << 'EOF'
    cmake_minimum_required(VERSION 3.20)

    project(custom_command_demo_3)

    file(GLOB MY_PROJECT_SOURCES "*.cpp")
    add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

    target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
    target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

    # This target won't be executed by default
    add_custom_target(say_hello_target
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, first message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, second message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, third message"
        VERBATIM
    )

    # Link target say_hello_target to the default build target
    add_dependencies(${PROJECT_NAME} say_hello_target)
    EOF

    cat > custom_command_demo_3.cpp << 'EOF'
    int main() {
        return 0;
    }
    EOF

    cmake -B build && cmake --build build
    ```

* Use `add_custom_command` and `add_custom_target` and `add_dependencies`:
    ```sh
    mkdir -p custom_command_demo_4
    cd custom_command_demo_4
    cat > CMakeLists.txt << 'EOF'
    cmake_minimum_required(VERSION 3.20)

    project(custom_command_demo_4)

    file(GLOB MY_PROJECT_SOURCES "*.cpp")
    add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

    target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
    target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

    add_custom_command(
        OUTPUT say_hello.txt
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, first message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, second message"
        COMMAND ${CMAKE_COMMAND} -E echo "This is a custom command demo, third message"
        COMMAND ${CMAKE_COMMAND} -E echo "Write this to a file" > say_hello.txt
        VERBATIM
    )

    # This target won't be executed by default
    add_custom_target(say_hello_target
        DEPENDS say_hello.txt
    )

    # Link target say_hello_target to the default build target
    add_dependencies(${PROJECT_NAME} say_hello_target)
    EOF

    cat > custom_command_demo_4.cpp << 'EOF'
    int main() {
        return 0;
    }
    EOF

    cmake -B build && cmake --build build
    ```

### 6.6.2 PRE_BUILD/PRE_LINK/POST_BUILD Events

```sh
mkdir -p build_events_demo
cd build_events_demo
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(build_events_demo)

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

add_custom_command(
    TARGET ${PROJECT_NAME} 
    PRE_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Executed before build"
    VERBATIM
)

add_custom_command(
    TARGET ${PROJECT_NAME} 
    PRE_LINK
    COMMAND ${CMAKE_COMMAND} -E echo "Executed before link"
    VERBATIM
)

add_custom_command(
    TARGET ${PROJECT_NAME} 
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Executed after build"
    VERBATIM
)
EOF

cat > build_events_demo.cpp << 'EOF'
int main() {
    return 0;
}
EOF

cmake -B build && cmake --build build --verbose
```

### 6.6.3 Best Practice

Here we choose `add_custom_command`, `add_custom_target`:

* `add_custom_target`: Adds a target with the given name that executes the given commands. The target has no output file and is always considered out of date even if the commands try to create a file with the name of the target.
* `add_custom_command`: This defines a command to generate specified `OUTPUT` file(s). A target created in the same directory (`CMakeLists.txt` file) that specifies any output of the custom command as a source file is given a rule to generate the file using the command at build time.
    * **If you use `Ninja` as build tool, the standand output of the command will be buffered and put to screen once the command is finished. But we can use `2>&1 | tee /dev/tty` to enable real-time output to the screen.**

```sh
mkdir -p cmake_with_java_demo
cd cmake_with_java_demo

git clone https://github.com/liuyehcf/liuyehcf-framework.git --depth 1

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.20)

project(cmake_with_java_demo)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_compile_options(-O3 -Wall)

file(GLOB MY_PROJECT_SOURCES "*.cpp")
add_executable(${PROJECT_NAME} ${MY_PROJECT_SOURCES})

target_compile_options(${PROJECT_NAME} PRIVATE -static-libstdc++)
target_link_options(${PROJECT_NAME} PRIVATE -static-libstdc++)

# Build java project
find_program(MAVEN_EXECUTABLE mvn)
find_program(JAVA_EXECUTABLE java)
if(NOT MAVEN_EXECUTABLE)
    message(FATAL_ERROR "Maven not found. Please install Maven.")
endif()
if(NOT JAVA_EXECUTABLE)
    message(FATAL_ERROR "Java not found. Please install Java 8.")
endif()

# Check Java version
execute_process(
    COMMAND ${JAVA_EXECUTABLE} -version
    OUTPUT_VARIABLE JAVA_VERSION_OUTPUT
    ERROR_VARIABLE JAVA_VERSION_OUTPUT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE
)
string(REGEX MATCH "version \"([0-9]+)\\.([0-9]+)" JAVA_VERSION_MATCH "${JAVA_VERSION_OUTPUT}")
if(JAVA_VERSION_MATCH)
    string(REGEX REPLACE ".*version \"([0-9]+)\\.([0-9]+).*" "\\1" JAVA_VERSION_MAJOR "${JAVA_VERSION_OUTPUT}")
    string(REGEX REPLACE ".*version \"([0-9]+)\\.([0-9]+).*" "\\2" JAVA_VERSION_MINOR "${JAVA_VERSION_OUTPUT}")
    if(JAVA_VERSION_MAJOR GREATER_EQUAL 11)
        message(STATUS "Found Java version: ${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}")
    else()
        message(FATAL_ERROR "Java version 11 or higher is required. Found version: ${JAVA_VERSION_MAJOR}.${JAVA_VERSION_MINOR}")
    endif()
else()
    message(FATAL_ERROR "Failed to determine Java version.")
endif()

set(JAVA_PROJECT_DIR ${CMAKE_SOURCE_DIR}/liuyehcf-framework/common-tools)
set(JAVA_OUTPUT_DIR ${CMAKE_BINARY_DIR}/lib/jar)

set(MODULE_1_PATH ${JAVA_PROJECT_DIR}/target/common-tools.jar)
set(MODULE_2_PATH ${JAVA_PROJECT_DIR}/target/common-tools-javadoc.jar)

set(ALL_JAR_PATHS
    ${MODULE_1_PATH}
    ${MODULE_2_PATH}
)

file(GLOB_RECURSE JAVA_SOURCES ${JAVA_PROJECT_DIR}/src/main/java/*.java)

add_custom_command(
    OUTPUT ${ALL_JAR_PATHS}
    COMMAND ${MAVEN_EXECUTABLE} --batch-mode --define style.color=always clean package -DskipTests
    WORKING_DIRECTORY ${JAVA_PROJECT_DIR}
    # Add dependencies to all java source files, this command will be executed if any source file changed
    DEPENDS ${JAVA_SOURCES}
    COMMENT "Building Java project with Maven"
    VERBATIM
)

add_custom_target(build_java ALL
    DEPENDS ${ALL_JAR_PATHS}
)

add_custom_command(TARGET build_java POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory ${JAVA_OUTPUT_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${MODULE_1_PATH} ${JAVA_OUTPUT_DIR}
    COMMAND ${CMAKE_COMMAND} -E copy ${MODULE_2_PATH} ${JAVA_OUTPUT_DIR}
    COMMENT "Copying build artifacts to output directory"
    VERBATIM
)
EOF

cat > main.cpp << 'EOF'
#include <iostream>

int main() {
    return 0;
}
EOF

cmake -B build && cmake --build build
```

## 6.7 compile_commands.json

### 6.7.1 Manually Generate compile_commands.json

Specify the parameter `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` in `cmake`. After the build is complete, a `compile_commands.json` file will be generated in the build directory, containing the compilation commands for each source file.

### 6.7.2 Auto generate compile_commands.json and copy to project source root

Refer to [Copy compile_commands.json to project root folder](https://stackoverflow.com/questions/57464766/copy-compile-commands-json-to-project-root-folder)

```cmake
add_custom_target(
    copy-compile-commands ALL
    ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_BINARY_DIR}/compile_commands.json
        ${CMAKE_SOURCE_DIR}
    )
```

## 6.8 How to work with ccache

[How to Use CCache with CMake?](https://stackoverflow.com/questions/1815688/how-to-use-ccache-with-cmake)

Use cmake variable [CMAKE_<LANG>_COMPILER_LAUNCHER](https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_LAUNCHER.html#variable:CMAKE_%3CLANG%3E_COMPILER_LAUNCHER)

```sh
cmake -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache -B build
```

Or, you can use env variable of the same name.

```sh
export CMAKE_C_COMPILER_LAUNCHER=ccache
export CMAKE_CXX_COMPILER_LAUNCHER=ccache
```

How to ensure ccache truely works:

* `grep -rni 'ccache' build`: Find ccache related configs
* `ccache -z && ccache -s && cmake --build build && ccache -s`: Check cache hits

## 6.9 How to uninstall

After installation, there will be a `install_manifest.txt` recording all the installed files. So we can perform uninstallation by this file.

```sh
xargs rm < install_manifest.txt
```

## 6.10 Ignore -Werror

```sh
cmake --compile-no-warning-as-error -DWERROR=0 ...
```

## 6.11 Filename Postfix for Libraries

```sh
cmake -DCMAKE_DEBUG_POSTFIX="d" ...
```

Or

```cmake
set_target_properties(<target> PROPERTIES DEBUG_POSTFIX "d")
```

## 6.12 How to view dependencies

```sh
cmake -B build --graphviz=build/graph/graph.dot

# Generate png
dot -Tpng build/graph/graph.dot -o build/graph/graph.png

# Generate svg(preferred)
dot -Tsvg build/graph/graph.dot -o build/graph/graph.svg
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
