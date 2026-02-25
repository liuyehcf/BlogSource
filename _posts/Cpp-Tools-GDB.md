---
title: Cpp-Tools-GDB
date: 2021-09-06 10:55:03
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 What is GDB

1. A `debugger` tool that supports many languages, including `c` and `c++`.
1. It allows you to inspect what a program is doing at a specific moment during execution.
1. It can identify the specific causes of errors such as `segmentation faults`.

To debug a `c/c++` program, you need to add the `-g` option before compilation:

```sh
gcc -g hello.c -o hello
g++ -g hello.cpp -o hello
```

# 2 How to use GDB

`gdb` provides an interactive `shell`, where you can use `↑` to browse command history, use `tab` for command-line completion, and use `help [command]` to view documentation.

**Several ways to enter the gdb interactive interface:**

* `gdb <binary_with_-g>`: debug an executable file.
* `gdb <binary_with_-g> core.xxx`: analyze a coredump.
* `gdb <binary_with_-g> <pid_without_-g>`: use the executable as metadata to debug a specified process.
    * `<binary>` must be compiled with the `-g` option; otherwise specifying this file is meaningless.
    * The process corresponding to `<pid>` can be compiled without the `-g` option, as long as the source code is the same.
* `gdb -p <pid_with_-g>`: debug a specified process.
    * If the process corresponding to `<pid>` was compiled with the `-g` option, it is equivalent to `gdb <binary_with_-g>` + `run`.

**Below is a demonstration of entering the gdb shell using `gdb <binary_with_-g> <pid_without_-g>`**

```sh
cat > main.cpp << 'EOF'
#include<iostream>
#include<thread>
#include<chrono>

int main() {
    std::cout << "hello, world!" <<std::endl;

    int cnt = 0;
    while(true) {
        ++cnt;
        std::this_thread::sleep_for(std::chrono::seconds(1));
	std::cout << "cnt=" << cnt << std::endl;
    }
}
EOF

g++ -o main_without_debug main.cpp -std=gnu++11
g++ -o main_with_debug main.cpp -std=gnu++11 -g
```

```sh
./main_without_debug
```

```sh
pid=$(ps -ef | grep main_without_debug | grep -v grep | awk '{print $2}')

gdb main_with_debug ${pid}
```

## 2.1 Symbol Mismatch

Symbol mismatch can occur when you use a binary compiled on one machine and attempt to run it on a different machine, especially if the two machines have different configurations or architectures. Here's why this can happen:

* **Library Dependencies**: Binaries often rely on dynamic link libraries (shared libraries) or other system libraries. If the target machine doesn't have the same versions of these libraries or they are missing altogether, you can encounter symbol mismatch errors.
* **Architecture Differences**: If the two machines have different CPU architectures (e.g., x86 vs. ARM), binaries compiled for one architecture may not run on the other. This is a fundamental incompatibility.
* **Operating System Differences**: Even if two machines have the same architecture, they may have different operating systems with different system calls and ABI (Application Binary Interface) specifications. This can lead to symbol mismatches.
* **Compiler and Compiler Options**: The compiler used to build the binary can affect symbol compatibility. Different compiler versions or options might generate different symbol names or behaviors.
* **Bitness**: Some operating systems and architectures have both 32-bit and 64-bit versions. Trying to run a binary compiled for one bitness on a machine of a different bitness can result in symbol mismatches.

To avoid symbol mismatch issues when moving binaries between machines:

* **Use Static Linking**: Consider statically linking libraries into your binary when compiling. This bundles the necessary libraries into the binary, reducing dependencies on external libraries.
* **Build on the Target Machine**: Whenever possible, compile your code on the machine where you intend to run it. This ensures that the binary is built with the correct dependencies and configurations.
* **Cross-Compilation**: If you must build on one machine and run on another, use cross-compilation tools to generate binaries specifically tailored for the target machine's architecture and operating system.
* **Package Managers**: If you're working with package managers (e.g., apt, yum, brew), use them to manage library dependencies and ensure compatibility between systems.
* **Containerization**: Consider using containerization technologies like Docker to package your application along with its dependencies, ensuring portability across different environments.

When you generate a core dump file (usually named "core") on one machine (Machine B in your scenario) and attempt to debug it using GDB on the same machine, symbol mismatch should not be a significant issue. Here's why:

* **Binary Compatibility**: The core dump file contains information about the state of the program at the moment it crashed or was interrupted. This includes the memory addresses, registers, and symbol names relevant to the binary that generated the core dump. Since you're using GDB on the same machine where the binary was executed (Machine B), there should be no symbol mismatch problems related to the architecture or libraries of Machine A.
* **GDB Compatibility**: GDB is designed to work with core dump files generated by the same binary or a compatible binary. It will use the debugging information (symbols) embedded in the binary to analyze the core dump. As long as the binary and the core dump are compatible in terms of architecture, compiler options, and library versions, you should be able to use GDB without significant issues.
* **Symbol Resolution**: GDB uses the symbol information present in the binary (if it was compiled with debugging symbols) to resolve symbols during debugging. It doesn't rely on external symbol files or libraries when debugging a core dump on the same machine where the program was running.

# 3 Command

## 3.1 Run Program

When we enter the `gdb shell` using the command `gdb <binary>`, the program will not run immediately. We need to trigger its execution with either the `run` or `start` command.

* `run`: Starts executing the program until it hits the first breakpoint or the program finishes.
* `start`: Starts executing the program and stops at the first line of the main function.

If the program encounters an exception (such as a segmentation fault), we will get some useful information, including the line number where the error occurred, the function's parameters, and more.

```sh
cat > segment_fault.cpp << 'EOF'
int main() {
    int *num = nullptr;
    *num = 100;
    return 0;
}
EOF

g++ -o segment_fault segment_fault.cpp -std=gnu++11 -g

gdb segment_fault

(gdb) run

Starting program: xxx/segment_fault

Program received signal SIGSEGV, Segmentation fault.
0x000000000040051d in main () at segment_fault.cpp:3
3	    *num = 100;
```

### 3.1.1 Run with args

```sh
gdb ls

(gdb) run -al
```

### 3.1.2 set args

The `set args` command in GDB allows you to specify or change the command-line arguments for the program you are debugging during an active GDB session. This can be particularly useful if you want to test your program with different arguments without restarting GDB.

```sh
set args [arguments]
```

**Examples:**

```sh
gdb ls

(gdb) set args -al -h -r -t
(gdb) run
```

### 3.1.3 --args

**The `--args` option in GDB allows you to specify the program and its arguments directly from the command line when starting GDB. This can be very convenient for debugging programs that require command-line arguments.**

```sh
gdb --args program [arguments]
```

**Examples:**

* `gdb --args ls -al`

## 3.2 Attach Program

`gdb -p 12345`

## 3.3 Break Point

* `break`: used to set breakpoints
    * `break <line_num>`
    * `break <func_name>`
    * `break <file_name>:<line_num>`
    * `break <file_name>:<func_name>`
* `info break`: used to view breakpoints
* `delete`: used to remove breakpoints
    * `delete <break_id>`: remove a specified breakpoint
    * `delete`: remove all breakpoints
* `enable`: used to enable breakpoints
    * `enable <break_id>`
* `disable`: used to disable breakpoints
    * `disable <break_id>`

### 3.3.1 demo

```sh
cat > set_break.cpp << 'EOF'
#include <iostream>

void funcA() {
    std::cout << "invoke funcA()" << std::endl;
}

int main() {
    std::cout << "hello world" << std::endl;

    int num = 0;

    int *num_ptr = &num;

    funcA();

    for(int i=0; i < 10; i++) {
        ++(*num_ptr);
    }

    std::cout << "num: " << *num_ptr << std::endl;

    return 0;
}
EOF

g++ -o set_break set_break.cpp -std=gnu++11 -g

gdb set_break

(gdb) list 0
```

```
1	#include <iostream>
2
3	void funcA() {
4	    std::cout << "invoke funcA()" << std::endl;
5	}
6
7	int main() {
8	    std::cout << "hello world" << std::endl;
9
10	    int num = 0;
```

```sh
# Press Enter to continue outputting the next 10 lines
(gdb)
```

```
11
12	    int *num_ptr = &num;
13
14	    funcA();
15
16	    for(int i=0; i < 10; i++) {
17	        ++(*num_ptr);
18	    }
19
20	    std::cout << "num: " << *num_ptr << std::endl;
```

```sh
# Press Enter to continue outputting the next 10 lines
(gdb)
```

```
21
22	    return 0;
23	}
```

```sh
# Set a breakpoint at line number 8
(gdb) break 8
Breakpoint 1 at 0x400848: file set_break.cpp, line 8.

# Set a breakpoint at line number 10
(gdb) break set_break.cpp:10
Breakpoint 2 at 0x400864: file set_break.cpp, line 10.

# Set a breakpoint at line number 12
(gdb) break 12
Breakpoint 3 at 0x40086b: file set_break.cpp, line 12.

# Set a breakpoint at line number 4
(gdb) break 4
Breakpoint 4 at 0x400821: file set_break.cpp, line 4.

# Set a breakpoint at line number 17
(gdb) break 17
Breakpoint 5 at 0x400881: file set_break.cpp, line 17.

# Set a breakpoint at line number 20
(gdb) break 20
Breakpoint 6 at 0x40089a: file set_break.cpp, line 20.

# Set a breakpoint at function funcA and find that this breakpoint has already been duplicated
(gdb) break funcA
Note: breakpoint 4 also set at pc 0x400821.
Breakpoint 7 at 0x400821: file set_break.cpp, line 4.

# View all breakpoints
(gdb) info break
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x0000000000400848 in main() at set_break.cpp:8
2       breakpoint     keep y   0x0000000000400864 in main() at set_break.cpp:10
3       breakpoint     keep y   0x000000000040086b in main() at set_break.cpp:12
4       breakpoint     keep y   0x0000000000400821 in funcA() at set_break.cpp:4
5       breakpoint     keep y   0x0000000000400881 in main() at set_break.cpp:17
6       breakpoint     keep y   0x000000000040089a in main() at set_break.cpp:20
7       breakpoint     keep y   0x0000000000400821 in funcA() at set_break.cpp:4

# Run the program with the `run` command, and you will find that it is now stopped at line number 8
(gdb) run
Starting program: xxx/set_break

Breakpoint 1, main () at set_break.cpp:8
8	    std::cout << "hello world" << std::endl;
```

## 3.4 Debugging

* `continue`: continue running until the program ends or hits the next breakpoint
* `step`: source-level single-step debugging, enters functions; also known as `step into`
* `next`: source-level single-step debugging, does not enter functions and treats function calls as one step; also known as `step over`
* `stepi`: instruction-level single-step debugging, enters functions; also known as `step into`
* `nexti`: instruction-level single-step debugging, does not enter functions and treats function calls as one step; also known as `step over`
* `until`: exit a loop
* `finish`: finish executing the current function
* `display <variable>`: track and display a variable; its value is shown each time execution stops
* `undisplay <display_id>`: cancel tracking
* `watch`: set a watchpoint; when the watched variable is modified, it will be printed
* `thread <id>`: switch the debugging thread to the specified thread
* `up [<n>]`: move up one or `n` levels in the stack
* `down [<n>]`: move down one or `n` levels in the stack
* `frame`: display the current stack information, including the current source code
* `frame <n>`: jump to the specified stack level
* `attach <pid>`: reattach to a process

## 3.5 Display Information

* `bt`, `backtrace`, `where`: view the current call stack
    * `bt 3`: the top 3 frames
    * `bt -3`: the bottom 3 frames
* `disassemble`: view the current assembly instructions
    * `disassemble`: assembly instructions of the current function
    * `disassemble <function>`: assembly instructions of a specified function
    * `set disassembly-flavor intel`: set the assembly style to `Intel Syntax`
    * `set disassembly-flavor att`: set the assembly style to `AT&T Syntax`, which is the default
* `list`: view source code
    * `list`: continue from the previous output and display the next 10 lines of source code
    * `list -`: continue from the previous output and display the previous 10 lines of source code
    * `list <linenumber>`: display 10 lines of source code starting from the specified line number in the current file
    * `list <linenumber>, <end_linenumber>`: display source code within the specified line number range
    * `list <function>`: display 10 lines of source code for the specified function
    * `list <filename:linenum>`: display 10 lines of source code starting from the specified line number in the specified file
    * `list <filename:function>`: display 10 lines of source code for the specified function in the specified file
    * `set substitute-path /root/starrocks /other/path/starrocks`: modify the source code indexing path. When a binary is compiled on machine A or inside Docker but a core file is analyzed on machine B, the source code paths usually do not match, so this command is needed to adjust them
* `info`: used to view various debugging-related information
    * `info break`: view breakpoints
    * `info reg`: view registers
    * `info all-reg`: view all registers, including floating-point and vector registers
    * `info stack`: view the stack
    * `info thread`: view threads
    * `info locals`: view local variables
    * `info args`: view arguments
    * `info symbol <address>`: view the symbol information corresponding to the specified memory address (if any)
* `print`: used to view variables
    * `print <variable>`
    * `print <variable>.<field>`
    * `print (<type>)*<address>`: view the object pointed to by the address, requires type casting
    * `print *(<type>*)<address>`: view the object pointed to by the address, requires type casting
    * `print <array>[0]@5`: view a subset starting from index `0` with a length of `5`
    * View and set properties: `show print <property>`, `set print <property> on/off`. Below are several commonly used property names (all properties can be viewed via `show print [tab][tab]` or `help show print`)
        * `address`: display the function address when showing function information; enabled by default
        * `array`: display each array element on a separate line; disabled by default
        * `elements`: maximum length of arrays to display; elements beyond this length will not be shown; `0` means unlimited
        * `raw-values`: print raw content. In `GNU gdb (Ubuntu 12.1-0ubuntu1~22.04) 12.1`, when printing standard library objects, optimized content (container element details) is printed by default instead of the detailed fields of the container itself
        * **`pretty`: whether to display in a human-friendly format (line breaks, indentation, etc.); disabled by default**
* `x/<count><format><size> <addr>`: print memory content in the specified format
    * `<count>`: a positive integer indicating the number of memory units to display; that is, display the contents of `<count>` memory units starting from the current address; the size of each memory unit is defined by the third parameter `<size>`
    * `<format>`: the output format of the memory content pointed to by `addr`
        * `o`: `octal`
        * `x`: `hex`
        * `d`: `decimal`
        * `u`: `unsigned decimal`
        * `t`: `binary`
        * `f`: `float`
        * `a`: `address`
        * `i`: `instruction`
        * `c`: `char`
        * `s`: `string`
        * `z`: `hex, zero padded on the left`
    * `<size>`: the number of bytes per memory unit, default is 4
        * `b`: 1 byte
        * `h`: 2 bytes
        * `w`: 4 bytes
        * `g`: 8 bytes
    * Examples:
        * `x/1ug $rbp-0x4`: view the content stored at the address obtained by subtracting `0x4` from the value stored in register `rbp`
        * `x/1xg $rsp`: view the content stored at the address stored in register `rsp`

**`info reg` displays the contents of all registers. The contents are printed in two columns: the first column is output in hexadecimal form (`raw format`), and the second column is output in its original form (`natural format`). Below, the sizes and types of all registers are shown.**

* For registers of type `int64`, the `natural format` is represented in decimal
* For registers of type `data_ptr` and `code_ptr`, the `natural format` is still represented in hexadecimal, so you will see two columns with exactly the same values

```xml
<reg name="rax" bitsize="64" type="int64"/>
<reg name="rbx" bitsize="64" type="int64"/>
<reg name="rcx" bitsize="64" type="int64"/>
<reg name="rdx" bitsize="64" type="int64"/>
<reg name="rsi" bitsize="64" type="int64"/>
<reg name="rdi" bitsize="64" type="int64"/>
<reg name="rbp" bitsize="64" type="data_ptr"/>
<reg name="rsp" bitsize="64" type="data_ptr"/>
<reg name="r8" bitsize="64" type="int64"/>
<reg name="r9" bitsize="64" type="int64"/>
<reg name="r10" bitsize="64" type="int64"/>
<reg name="r11" bitsize="64" type="int64"/>
<reg name="r12" bitsize="64" type="int64"/>
<reg name="r13" bitsize="64" type="int64"/>
<reg name="r14" bitsize="64" type="int64"/>
<reg name="r15" bitsize="64" type="int64"/>

<reg name="rip" bitsize="64" type="code_ptr"/>
<reg name="eflags" bitsize="32" type="i386_eflags"/>
<reg name="cs" bitsize="32" type="int32"/>
<reg name="ss" bitsize="32" type="int32"/>
<reg name="ds" bitsize="32" type="int32"/>
<reg name="es" bitsize="32" type="int32"/>
<reg name="fs" bitsize="32" type="int32"/>
<reg name="gs" bitsize="32" type="int32"/>
```

### 3.5.1 Tips for debugging std::vector

* `print sizeof(*v._M_impl._M_start)`: Check element size.
* `print v._M_impl._M_finish - v._M_impl._M_start`: Get element number.
* `print v._M_impl._M_start[i]`: Get the ith element.
* `print &v._M_impl._M_start[i]`: Get address of the ith element.
* `print v._M_impl._M_start[i]@j`：Print item with offset from i to j.

### 3.5.2 Tips for debugging std::shared_ptr

* `print *p._M_ptr`: Show details, it may print something like `<vtable for Derive+16>`.
* `print *(<type>*)p._M_ptr`: Show details of derived type.
* `x/1a p._M_ptr`: Get first item of vtable.
* `x/1a *(void**)p._M_ptr`: Useful when `x/1a p._M_ptr` can't see useful info.
* `x/10a *(void**)p._M_ptr`: Get first 10 items of vtable.
    * `*(void**)` dereferences the `void**` pointer, effectively accessing the first entry in the vtable, which is a pointer to another `void*`.

### 3.5.3 demo of print

```sh
cat > print.cpp << 'EOF'
struct Person {
    const char* name;
    const char* phone_num;
    const int age;
};

int main() {
    Person p {"Tom", "123456789", 18};
    return 0;
}
EOF

g++ -o print print.cpp -std=gnu++11 -g

gdb print

(gdb) list
```

```
1	struct Person {
2	    const char* name;
3	    const char* phone_num;
4	    const int age;
5	};
6
7	int main() {
8	    Person p {"Tom", "123456789", 18};
9	    return 0;
10	}
```

```sh
# Set a breakpoint
(gdb) break 9
Breakpoint 1 at 0x400528: file print.cpp, line 9.

# Run the program; it will stop at the breakpoint
(gdb) run
Starting program: xxx/print

Breakpoint 1, main () at print.cpp:9
9	    return 0;

# View relevant information
(gdb) print p
$1 = {name = 0x4005c0 "Tom", phone_num = 0x4005c7 "123456789", age = 18}
(gdb) print p.name
$2 = 0x4005c0 "Tom"
(gdb) print p.phone_num
$3 = 0x4005c7 "123456789"
(gdb) print p.age
$4 = 18
(gdb) print &p
$5 = (Person *) 0x7fffffffe0c0
```

## 3.6 Load Symbol Table

* `symbol-file /path/to/binary_file.debuginfo`

## 3.7 Execute outside commands

Format: `!<command> [params]`

```sh
(gdb) !pwd
xxx/gdb_tutorial
```

## 3.8 Handle Signal

```sh
(gdb) handle <signal> <action>
```

* `<signal>`: The name or number of the signal (e.g., `SIGINT`, `SIGSEGV`)
* `<action>`: One or more actions to specify how GDB should handle the signal. The actions can include:
    * `nostop`: GDB should not stop the program when this signal is received.
    * `stop`: GDB should stop the program when this signal is received.
    * `noignore`: GDB should not ignore the signal (default action for most signals).
    * `ignore`: GDB should ignore the signal.
    * `noprint`: GDB should not print a message when the program receives this signal.
    * `print`: GDB should print a message when the program receives this signal.

## 3.9 Tips

### 3.9.1 Redirect source file path

The `set substitute-path` command is used in GDB (GNU Debugger) to remap source paths. This is useful when the source code was compiled on one machine with a different directory structure and you need to debug it on another machine where the directory structure is different.

```sh
(gdb) set substitute-path <original-path> <new-path>
```

### 3.9.2 Redirect Thread Info to File

```sh
(gdb) set pagination off
(gdb) set logging file /tmp/threads.txt
(gdb) set logging on
(gdb) info threads
(gdb) set logging off
```

### 3.9.3 Redirect Thread Stack to File

```sh
(gdb) set pagination off
(gdb) set logging file /tmp/threads.txt
(gdb) set logging on
(gdb) thread apply all bt
(gdb) set logging off
```

### 3.9.4 Print all Threads Stack

```sh
gdb -ex "set pagination 0" -ex "thread apply all bt" -batch
```

# 4 Tips

## 4.1 How to Analyze a Core File

Here are some of tips:

1. `info threads`: The default thread may not be where the crash occurred.
1. `thread <n>`: Switch to the specific thread where there may be something wrong.
1. `bt <n>`: List the call stack.
1. `frame <n>`: Go to the specific call frame.
1. `info locals`、`info args`: See local variables and arguments.
1. `print`: See details of something.

## 4.2 Debugging an x86 application in Rosetta for Linux

I'm runing a centos7.9/amd64 docker container on my mac(M3), and fail to debug a core file with the error message below:

```
$ gdb main core

GNU gdb (GDB) Red Hat Enterprise Linux 10.2-6.el7
Copyright (C) 2021 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from main...

warning: Can't open file /run/rosetta/rosetta during file-backed mapping note processing

warning: core file may not match specified executable file.
[New LWP 17530]

warning: Selected architecture i386:x86-64 is not compatible with reported target architecture aarch64

warning: Architecture rejected target-supplied description

warning: Unexpected size of section `.reg/17530' in core file.

warning: Unexpected size of section `.reg2/17530' in core file.
Core was generated by `/run/rosetta/rosetta ./main ./main'.
Program terminated with signal SIGABRT, Aborted.

warning: Unexpected size of section `.reg/17530' in core file.

warning: Unexpected size of section `.reg2/17530' in core file.
#0  0x0000effff7dfba50 in ?? ()
```

And there's a mechanism called Rosetta:

> This is a software bridge that allows applications compiled for one instruction set architecture (such as Intel x86) to run on a different architecture (like Apple's ARM-based processors). Apple has used two versions: Rosetta for the transition from PowerPC to Intel processors, and Rosetta 2 for the transition from Intel to Apple Silicon.

According to [Debugging an x86 application in Rosetta for Linux](https://sporks.space/2023/04/12/debugging-an-x86-application-in-rosetta-for-linux/), I can debug the program by:

```sh
# This will hang
ROSETTA_DEBUGSERVER_PORT=1234 ./main &

# Enter Gdb
gdb
(gdb) set architecture i386:x86-64
(gdb) file main
(gdb) target remote localhost:1234
(gdb) continue
```

Or for lldb

```sh
# This will hang
ROSETTA_DEBUGSERVER_PORT=1234 ./main &

# Enter lldb
lldb
(lldb) platform select remote-linux
(lldb) target create ./main
(lldb) gdb-remote localhost:1234
(lldb) continue
```

## 4.3 How to ignore interrupt of sepcific signal

For gdb:

```
(gdb) handle SIGSEGV pass noprint nostop
(gdb) handle all pass noprint nostop
```

For lldb:

* `-p <boolean> ( --pass <boolean> )`: Whether or not the signal should be passed to the process.
* `-s <boolean> ( --stop <boolean> )`: Whether or not the process should be stopped if the signal is received.
* `-n <boolean> ( --notify <boolean> )`: Whether or not the debugger should notify the user if the signal is received.
* When debugging process with JNI, you may receive many interruptions from `libjvm.so`, like `stop reason = signal SIGSEGV: address access protected`, which is truly annoying, so you can use this to ignore them

```
(lldb) process handle -p true -s false -n true SIGSEGV

(lldb) process handle
```

## 4.4 How to print env

For environment variables set up before starting program, we can check them by `/proc/<pid>/environ`. But for environment variables set up at runtime, we can check them using the following approach:

```
(gdb) call (char *)getenv("TERM")
```

## 4.5 How to catch all exceptions

```
(gdb) catch throw
```

# 5 gdb-dashboard

[gdb-dashboard](https://github.com/cyrus-and/gdb-dashboard) builds on top of `gdb` and provides a more user-friendly formatted interface.

* `help dashboard`: view the help manual.
* `dashboard thread`: enable/disable thread information (in large projects with many threads, this is usually disabled).
* `dashboard`: refresh; typically used after viewing some variable information with `print`, to refresh and redisplay the details.

# 6 LLDB

[Tutorial](https://lldb.llvm.org/use/tutorial.html)

## 6.1 Tips

### 6.1.1 Command

* `lldb -c <core> <binary>`: Analyze core file.
* `lldb -- <binary> <args>`: Run with arguments.
* `lldb -o "settings set target.env-vars env1=xxx env2=yyy" -o run -- <binary> <args>`: Run with arguments and envs.

### 6.1.2 Display/Select Frame

* `(lldb) frame select <id>`/`f <id>`: select a frame.

### 6.1.3 Break on all cpp exceptions

* `(lldb) breakpoint set -E c++`: tells LLDB to break on C++ exceptions.

### 6.1.4 Show source code

* `(lldb) list -<count>`: Print previous `<count>` lines.

### 6.1.5 Redirect source file path

* `(lldb) settings set target.source-map <original-path> <new-path>`

### 6.1.6 Display source file path

* `(lldb) image dump line-table <source_file>`
    * `(lldb) image dump line-tabl main.cpp`
* `(lldb) image lookup -v -n <symbol>`
    * `(lldb) image lookup -v -n main`

# 7 Reference

* [GDB Tutorial - A Walkthrough with Examples](https://www.cs.umd.edu/~srhuang/teaching/cmsc212/gdb-tutorial-handout.pdf)
* [GDB Command Reference](https://visualgdb.com/gdbreference/commands/)
* [《100个gdb小技巧》](https://wizardforcel.gitbooks.io/100-gdb-tips/content/break-on-linenum.html)
* [GDB corrupted stack frame - How to debug?](https://stackoverflow.com/questions/9809810/gdb-corrupted-stack-frame-how-to-debug)
* [追core笔记之五：如何查看一个corrupt stack的core](https://izualzhy.cn/why-the-code-stack-is-overflow)
* [How do you set GDB debug flag with cmake?](https://stackoverflow.com/questions/10005982/how-do-you-set-gdb-debug-flag-with-cmake)
* [GDB info registers command - Second column of output](https://stackoverflow.com/questions/31026000/gdb-info-registers-command-second-column-of-output)
