---
title: Cpp-Tools-LLDB
date: 2026-03-02 23:39:48
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 What is LLDB

1. A modern debugger from the LLVM project that supports C/C++, Objective‑C, Swift, and more.
1. Lets you inspect program state at breakpoints or crashes, including call stacks, variables, registers, and memory.
1. Requires debug info when building (e.g., `-g`) to provide full source/line and symbol fidelity.

Build examples:

```sh
gcc -g hello.c -o hello
g++ -g hello.cpp -o hello
```

# 2 How to use LLDB

LLDB provides an interactive shell with command history, tab completion, and `help <cmd>`.

Common entry patterns:

* `lldb <binary_with_-g>`: create a target for an executable.
* `lldb -c <core> <binary_with_-g>`: analyze a core dump with symbols from the given binary.
* `lldb -p <pid>`: attach to a running process by PID.
* `lldb -o "settings set target.env-vars env1=xxx env2=yyy" -o run -- <binary> <args>`: set env vars and run.

Notes:

* You can also start `lldb` with no arguments, then use `target create <binary>` and `process launch` or `process attach` as needed.
* If you attach to a stripped process, you can later load symbols via `target symbols add <debug_file>`.

Example target/process setup:

```sh
cat > main.cpp << 'EOF'
#include <iostream>
#include <thread>
#include <chrono>

int main() {
    std::cout << "hello, world!" << std::endl;
    int cnt = 0;
    while (true) {
        ++cnt;
        std::this_thread::sleep_for(std::chrono::seconds(1));
        std::cout << "cnt=" << cnt << std::endl;
    }
}
EOF

g++ -o main main.cpp -std=gnu++11 -g
```

```sh
lldb ./main
(lldb) run
```

## 2.1 Symbol Mismatch

When moving binaries between machines, symbol or ABI mismatches can arise due to:

* Library dependencies: different versions or missing shared libraries.
* Architecture differences: e.g., x86_64 vs. aarch64.
* OS/ABI differences: different system call ABIs or loader behavior.
* Compiler/options differences: different debug formats or symbol details.
* 32/64‑bit differences: mixing bitness is incompatible.

Mitigations:

* Build on the target machine (or use cross‑compilers targeting the exact ABI).
* Use containerization to keep userland consistent.
* Provide external debug files (`.dSYM`, `.debug`) and load them with `target symbols add`.

For a core dump analyzed on the same machine that produced it, LLDB uses the binary’s debug info to resolve symbols and should not suffer cross‑machine mismatch problems.

# 3 Command

## 3.1 Run Program

After `lldb <binary>`, the program does not run until you launch it:

* `run`: launch the target until a breakpoint or program exit.
* `process launch --stop-at-entry true`: stop at the entry point (before `main`). To stop at `main`, set a breakpoint on `main` first, then `run`.

Example (SIGSEGV):

```sh
cat > segment_fault.cpp << 'EOF'
int main() {
    int *num = nullptr;
    *num = 100;
    return 0;
}
EOF

g++ -o segment_fault segment_fault.cpp -std=gnu++11 -g
lldb segment_fault
(lldb) run
```

### 3.1.1 Run with args

```sh
lldb /bin/ls
(lldb) run -- -al
```

### 3.1.2 Set args (persist in session)

Equivalent to GDB’s `set args`:

```sh
(lldb) settings set target.run-args -al -h -r -t
(lldb) run
```

### 3.1.3 Pass args at startup

```sh
# lldb -- <binary> <args>
lldb -- /bin/ls -al
```

### 3.1.4 Run with environment variables

```sh
(lldb) settings set target.env-vars FOO=bar BAZ=qux
(lldb) run -- arg1 arg2

# Or at startup
lldb -o "settings set target.env-vars FOO=bar BAZ=qux" -o run -- ./app arg1 arg2
```

## 3.2 Attach Program

* `lldb -p <pid>`
* Or inside LLDB: `process attach --pid <pid>`

## 3.3 Break Point

* Set breakpoints:
  * `breakpoint set -l <line_num>`
  * `breakpoint set -n <func_name>`
  * `breakpoint set -f <file_name> -l <line_num>`
  * `breakpoint set --name <func_name> --file <file_name>`
* List: `breakpoint list`
* Delete: `breakpoint delete [<break_id>]`
* Enable/Disable: `breakpoint enable <break_id>`, `breakpoint disable <break_id>`

## 3.4 Debugging

* `continue` (or `c`): continue until next stop or exit.
* `step` (or `s`): source step into.
* `next` (or `n`): source step over.
* `stepi` (or `si`): instruction step into.
* `nexti` (or `ni`): instruction step over.
* `thread until <line>`: run until a specific line in current file/func.
* `finish`: run until current frame returns.
* Watch variable changes: `watchpoint set variable <expr>`
* Threads:
  * `thread list`
  * `thread select <id>`
* Stack/frame navigation:
  * `bt` or `thread backtrace`
  * `up [n]`, `down [n]`
  * `frame select <n>`: alias: `f <n>`
  * Re‑attach: `process attach --pid <pid>`

## 3.5 Display Information

* Backtrace:
  * `bt` or `thread backtrace`
  * `thread backtrace -c 3`: shows top 3 frames
* Disassembly:
  * `disassemble`: current function.
  * `disassemble -n <function>`
  * `settings set target.x86-disassembly-flavor intel` (or `att`)
* Source:
  * `list <count>`: Print next `<count>` lines.
  * `list -<count>`: Print previous `<count>` lines.
  * `list <file>:<line>`: displays at `file:line`.
  * Source map: `settings set target.source-map <orig> <new>`
* Image/symbol lookup:
  * `image lookup -n <symbol>`
  * `image lookup -v -n <symbol>`: verbose output.
  * `image lookup -a <address>`
* Line/addr mapping:
  * `image dump line-table <source_file>`
* Variables:
  * `frame variable`: locals/args.
  * `frame variable <name>`
  * `expr <c/c++ expression>`: alias: `p`
* Registers:
  * `register read`: all GP regs.
  * `register read --all`: incl. FP/vector if available.

Memory examine:

* `memory read [-f <fmt>] [-s <size>] [-c <count>] <addr>`
  * Formats: `x`(hex), `o`(oct), `d`(dec), `u`(unsigned), `t`(bin), `f`(float), `a`(addr), `c`(char), `s`(string), `i`(inst)
  * Example: `memory read -f u -s 8 -c 1 $rbp-0x4`
  * Example: `memory read -f x -s 8 -c 1 $rsp`

### 3.5.1 Tips for debugging std::vector

* LLDB ships data formatters for C++ STL/libc++ containers. Often `frame variable v` or `p v` prints size and elements directly.
* Access elements: `p v[0]`, `p v[1]` (uses operator[]; may evaluate code).
* Get size/capacity: `p v.size()`, `p v.capacity()`.
* For raw memory view: `p v.data()` then `memory read -f x -s sizeof(*v.data()) -c <n> <addr>`.

### 3.5.2 Tips for debugging std::shared_ptr

* Get managed pointer: `p p.get()`
* Dereference pointee: `p *p` or `expr *(Type*)p.get()`
* Inspect vtable: `memory read -f a -c 1 p.get()` and nearby addresses, or cast to dynamic type if known.

## 3.6 Load Symbol Table

* `target symbols add <path/to/debug_or_dsym>`
* For a specific library: `target symbols add --shlib <libname> <debugfile>`

## 3.7 Execute outside commands

Run a host shell command from LLDB:

```sh
(lldb) shell pwd
```

## 3.8 Handle Signal

```sh
(lldb) process handle -p <true|false> -s <true|false> -n <true|false> <signal>
```

* `-p/--pass`: pass the signal to the process.
* `-s/--stop`: stop the process on the signal.
* `-n/--notify`: notify in the debugger when received.

## 3.9 Tips

### 3.9.1 Redirect source file path

```sh
(lldb) settings set target.source-map <original-path> <new-path>
```

### 3.9.2 Save thread list/stack to file (batch)

Use batch mode and redirect stdout:

```sh
# Thread list
lldb -b -o "thread list" -o quit -c <core> <binary> > /tmp/threads.txt

# All thread stacks
lldb -b -o "thread backtrace all" -o quit -c <core> <binary> > /tmp/stacks.txt
```

### 3.9.3 Print all Threads Stack (interactive)

```sh
(lldb) thread backtrace all
```

# 4 Tips

## 4.1 How to Analyze a Core File

Suggested steps:

1. `thread list`: identify likely crashing thread.
1. `thread select <n>`: switch thread.
1. `bt` or `thread backtrace`: view call stack.
1. `frame select <n>`/`f <n>`: select a frame.
1. `frame variable` / `expr`: inspect locals/args and expressions.
1. `register read`: inspect registers.
1. `image lookup -a <addr>`: resolve addresses to symbols/lines.

## 4.2 How to ignore interrupt of specific signal

```sh
(lldb) process handle -p true -s false -n true SIGSEGV
(lldb) process handle
```

## 4.3 How to print env

For runtime environment variables:

```sh
(lldb) expr (char*)getenv("TERM")
```

## 4.4 How to catch all C++ exceptions

```sh
(lldb) breakpoint set -E c++
```

# 5 Reference

* LLDB Tutorial: https://lldb.llvm.org/use/tutorial.html
* LLDB Command Reference: https://lldb.llvm.org/use/map.html
* LLDB man page (options): https://lldb.llvm.org/use/command_guide.html
* Rosetta remote debugging article: https://sporks.space/2023/04/12/debugging-an-x86-application-in-rosetta-for-linux/
