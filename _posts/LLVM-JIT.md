---
title: LLVM-JIT
date: 2023-07-10 15:21:21
tags: 
- 摘录
categories: 
- LLVM
---

**阅读更多**

<!--more-->

# 1 Introduction

LLVM JIT stands for "Just-In-Time" compilation in the context of the LLVM (Low Level Virtual Machine) compiler infrastructure. LLVM is a collection of modular and reusable compiler and toolchain technologies designed to optimize and compile programming languages.

The LLVM JIT refers to a feature within LLVM that enables dynamic compilation and execution of code at runtime. Instead of statically compiling the entire program before execution, the JIT compiler compiles parts of the code on-the-fly as they are needed during runtime. This dynamic compilation allows for various optimizations to be applied based on runtime information, potentially improving performance.

Here's a general overview of how LLVM JIT works:

1. **Parsing**: The source code or intermediate representation (IR) of a program is parsed and transformed into an LLVM-specific representation called LLVM IR.
1. **Optimization**: The LLVM IR goes through various optimization passes to improve performance, reduce code size, and eliminate redundant operations.
1. **JIT Compilation**: When the program is executed, the JIT compiler dynamically compiles LLVM IR into machine code for the target platform. The JIT compilation can occur on a per-function basis or even smaller code units, depending on the specific implementation.
1. **Execution**: The compiled machine code is executed immediately, providing the desired functionality to the running program.

The LLVM JIT approach offers several advantages. It allows for dynamic code generation, which is useful in scenarios such as just-in-time language implementations (e.g., dynamic languages like Python, JavaScript) or runtime optimization of performance-critical sections of code. It enables runtime profiling and adaptation, where the JIT compiler can gather information about program behavior during execution and adapt the generated code accordingly. Additionally, the JIT compilation process can leverage the extensive optimization infrastructure of LLVM to generate highly optimized machine code.

Overall, LLVM JIT is a powerful feature of the LLVM framework that enables dynamic compilation and execution, providing flexibility, performance optimizations, and dynamic adaptation for various programming language implementations and runtime environments.

# 2 Reference

* [StarRocks JIT RFC](https://uestc.feishu.cn/docx/WDJUdVXrRooYG2xjF2YcYVUencc)
