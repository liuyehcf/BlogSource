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

# 2 Demo

```cpp
#include <iostream>

#include "llvm/ADT/STLExtras.h"
#include "llvm/ExecutionEngine/Orc/Core.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/TargetSelect.h"

using namespace llvm;
using namespace llvm::orc;

int main() {
    // Initialize LLVM components.
    InitializeNativeTarget();
    InitializeNativeTargetAsmPrinter();

    // Create an LLJIT instance.
    auto JIT = LLJITBuilder().create();
    if (!JIT) {
        std::cerr << "Failed to create LLJIT: " << toString(JIT.takeError()) << "\n";
        return 1;
    }

    // Create an LLVM module.
    LLVMContext Context;
    auto M = std::make_unique<Module>("add_module", Context);
    Module* Mod = M.get();

    // Create the add function.
    FunctionType* FT =
            FunctionType::get(Type::getInt32Ty(Context), {Type::getInt32Ty(Context), Type::getInt32Ty(Context)}, false);
    Function* F = Function::Create(FT, Function::ExternalLinkage, "add", Mod);

    // Create a basic block and set the insertion point.
    BasicBlock* BB = BasicBlock::Create(Context, "Entry", F);
    IRBuilder<> Builder(BB);

    // Retrieve arguments, add them, and create a return instruction.
    auto Args = F->args().begin();
    Value* X = &*Args++;
    Value* Y = &*Args;
    Value* Sum = Builder.CreateAdd(X, Y, "sum");
    Builder.CreateRet(Sum);

    // Add the module to the JIT and get a handle to the added module.
    if (auto Err = JIT->get()->addIRModule(ThreadSafeModule(std::move(M), std::make_unique<LLVMContext>()))) {
        std::cerr << "Failed to add module to LLJIT: " << toString(std::move(Err)) << "\n";
        return 1;
    }

    // Look up the JIT'd function, cast it to a function pointer, then call it.
    auto AddFnSym = JIT->get()->lookup("add");
    if (!AddFnSym) {
        std::cerr << "Failed to look up function: " << toString(AddFnSym.takeError()) << "\n";
        return 1;
    }

    // Cast the symbol's address to a function pointer and call it.
    int (*AddFn)(int, int) = (int (*)(int, int))(intptr_t)AddFnSym->getAddress();
    int Result = AddFn(10, 20);

    std::cout << "Result of add(10, 20): " << Result << "\n";

    return 0;
}
```

```sh
# It works fine for version 13.x and 14.x
# -lpthread: Links against the POSIX threads library.
# -ldl: Links against the dynamic linking loader.
# -lz: Links against the zlib compression library.
# -lncurses: Links against the ncurses library.
clang++ -std=c++17 add_example.cpp `llvm-config --cxxflags --ldflags --libs core orcjit native` -lpthread -ldl -lz -lncurses -o add_example

# Execute
./add_example
```

# 3 Reference

* [StarRocks JIT RFC](https://uestc.feishu.cn/docx/WDJUdVXrRooYG2xjF2YcYVUencc)
* [StarRocks JIT PR](https://github.com/StarRocks/starrocks/pull/28477)
