---
title: Rust-Basics
date: 2025-03-23 21:22:08
tags: 
- 原创
categories: 
- Rust
- Basic
---

**阅读更多**

<!--more-->

# 1 Language

## 1.1 Ownership

**Keep these rules in mind as we work through the examples that illustrate them:**

* Each value in Rust has an owner.
* There can only be one owner at a time.
* When the owner goes out of scope, the value will be dropped.
* Rust will never automatically create “deep” copies of your data.

### 1.1.1 Reference

Mutable references restrictions: 

1. If you have a mutable reference to a value, you can have no other references to that value.
1. We also cannot have a mutable reference while we have an immutable one to the same value.
    * The compiler can tell that the reference is no longer being used at a point before the end of the scope.
    ```rust
    let mut s = String::from("hello");

    let r1 = &s; // no problem
    let r2 = &s; // no problem
    let r3 = &mut s; // BIG PROBLEM

    println!("{}, {}, and {}", r1, r2, r3);
    ```
    ```rust
    let mut s = String::from("hello");

    let r1 = &s; // no problem
    let r2 = &s; // no problem
    println!("{r1} and {r2}");
    // variables r1 and r2 will not be used after this point

    let r3 = &mut s; // no problem
    println!("{r3}");
    ```

The benefit of having this restriction is that Rust can prevent data races at compile time. A data race is similar to a race condition and happens when these three behaviors occur:

* Two or more pointers access the same data at the same time.
* At least one of the pointers is being used to write to the data.
* There's no mechanism being used to synchronize access to the data.

### 1.1.2 The Slice Type

A slice is a kind of reference, so it does not have ownership.

## 1.2 Attributes

Refer to [Attributes](https://doc.rust-lang.org/reference/attributes.html) for more details.

**Attributes can be classified into the following kinds:**

* Built-in attributes
* Proc macro attributes
* Derive macro helper attributes
* Tool attributes

### 1.2.1 Built-in attributes

#### 1.2.1.1 Derive

Attribute `Derive` is used to automatically implement standard traits for a struct or enum.

* `Debug`: Enables `println!("{:?}", x)`
* `Clone`: Allows `.clone()`
* `Copy`: Enables copying instead of moving
* `PartialEq & Eq`: Enables `==` and `!=` comparisons
* `Hash`: Allows using the type in a HashMap

#### 1.2.1.2 inline

Attribute `inline` is used to hint compiler to inline a function.

* `#[inline(always)]`: Forces inlining.
* `#[inline(never)]`: Prevents inlining.

#### 1.2.1.3 allow

Attribute `allow` is used to suppress warnings.

* `#![allow(warnings)]`: Suppress all warnings for the whole file
* `#[allow(unused_variables)]`
* `#[allow(dead_code)]`
* `#[allow(unused_variables, dead_code)]`

#### 1.2.1.4 cfg

Attribute `cfg` is used to enable conditional compilation.

```rust
#[cfg(target_os = "linux")]
fn only_on_linux() {
    println!("Running on Linux!");
}
```

#### 1.2.1.5 test

Marks a test function.

#### 1.2.1.6 Linkage & FFI (Interfacing with C): no_mangle, repr

* `#[no_mangle]`: Prevents Rust from renaming a function.
* `#[repr(C)]`: Ensures a struct has C-compatible layout.

# 2 Cargo

## 2.1 Tips

### 2.1.1 Search Library

```sh
cargo tree

cargo search regex

cargo info regex
```

# 3 FFI

## 3.1 Rust Calling C++

```sh
cargo new rust_invoke_cpp_demo
cd rust_invoke_cpp_demo

cat > Cargo.toml << 'EOF'
[package]
name = "rust_invoke_cpp_demo"
version = "0.1.0"
edition = "2024"

[dependencies]
cxx = "1.0"

[build-dependencies]
cxx-build = "1.0"
EOF

cat > src/main.rs << 'EOF'
#[cxx::bridge]
mod ffi {
    unsafe extern "C++" {
        include!("rust_invoke_cpp_demo/cpp/math.h");

        fn add(i: i32, j: i32) -> i32;
    }
}

fn main() {
    let res = ffi::add(1, 2);
    println!("Add 1 + 2 = {}", res);
}
EOF

mkdir cpp
cat > cpp/math.h << 'EOF'
int add(int i, int j);
EOF
cat > cpp/math.cpp << 'EOF'
#include "math.h"

int add(int i, int j) {
    return i + j;
}
EOF

cat > build.rs << 'EOF'
fn main() {
    println!("cargo:rerun-if-changed=cpp/math.h");
    println!("cargo:rerun-if-changed=cpp/math.cpp");

    cxx_build::bridge("src/main.rs")
        .file("cpp/math.cpp")
        .include("cpp")
        .compile("math");

    println!("cargo:rustc-link-lib=stdc++");
}
EOF

cargo build && cargo run
```

## 3.2 C++ Calling Rust

```sh
cargo new --lib cpp_invoke_rust_demo
cd cpp_invoke_rust_demo

# rust part
cat > Cargo.toml << 'EOF'
[package]
name = "cpp_invoke_rust_demo"
version = "0.1.0"
edition = "2024"

[dependencies]
cxx = "1.0"

[build-dependencies]
cxx-build = "1.0"

[lib]
name = "cpp_invoke_rust_demo"
crate-type = ["staticlib", "cdylib"]
EOF

cat > src/lib.rs << 'EOF'
mod bridge;

pub fn greet() -> String {
    "Hello from Rust!".to_string()
}

pub struct Person {
    name: String,
    age: u32,
}

impl Person {
    pub fn new(name: String, age: u32) -> Box<Self> {
        Box::new(Self { name, age })
    }

    pub fn get_name(&self) -> String {
        self.name.clone()
    }

    pub fn get_age(&self) -> u32 {
        self.age
    }

    pub fn birthday(&mut self) {
        self.age += 1;
    }
}

pub fn new_person(name: String, age: u32) -> Box<Person> {
    Person::new(name, age)
}
EOF

cat > src/bridge.rs << 'EOF'
#[cxx::bridge]
mod ffi {
    extern "Rust" {
        fn greet() -> String;

        type Person;
        fn new_person(name: String, age: u32) -> Box<Person>;
        fn get_name(&self) -> String;
        fn get_age(&self) -> u32;
        fn birthday(&mut self);
    }
}

pub use crate::{greet, new_person, Person}; // Expose the function so it can be found
EOF

cat > build.rs << 'EOF'
fn main() {
    cxx_build::bridge("src/bridge.rs") // Generates the bridge
        .flag_if_supported("-std=c++14") // Ensures C++14 support
        .compile("rust_cpp_demo");

    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=src/lib.rs");
}
EOF

cargo clean && cargo build --release

# cpp part
mkdir cpp
cat > cpp/main.cpp << 'EOF'
#include <iostream>

#include "cpp_invoke_rust_demo/src/bridge.rs.h" // Generated C++ header
#include "rust/cxx.h"

int main() {
    // Call Rust function
    rust::String rust_message = greet();
    std::cout << "Rust says: " << rust_message.c_str() << std::endl;

    // Create a Rust Person instance in C++
    rust::Box<Person> person = new_person("Alice", 25);

    // Get and print person's info
    std::cout << "Person's name: " << person->get_name().c_str() << std::endl;
    std::cout << "Person's age: " << person->get_age() << std::endl;

    // Call birthday method
    person->birthday();
    std::cout << "After birthday, age: " << person->get_age() << std::endl;

    return 0;
}
EOF

mkdir build
g++ -o build/main_static cpp/main.cpp target/release/libcpp_invoke_rust_demo.a -I target/cxxbridge -lpthread -ldl
build/main_static

# Dynamic version cannot work
g++ -o build/main_dynamic cpp/main.cpp -Ltarget/release -lcpp_invoke_rust_demo -I target/cxxbridge -lpthread -ldl
LD_LIBRARY_PATH=target/release ./main_dynamic

# Or you can use cmake to build this
cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.10)

project(cpp_invoke_rust_demo)

set(CMAKE_CXX_STANDARD 17)

# Compile Rust
add_custom_target(rust
    COMMAND cargo build --release
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Building Rust project"
)

set(RUST_LIB_DIR "${CMAKE_SOURCE_DIR}/target")
set(RUST_INCLUDE_DIR "${RUST_LIB_DIR}/cxxbridge")

add_executable(${PROJECT_NAME} cpp/main.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${RUST_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE
    ${RUST_LIB_DIR}/release/libcpp_invoke_rust_demo.a
    pthread
    dl
)

add_dependencies(${PROJECT_NAME} rust)
EOF

rm -rf target build
cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
cmake --build build
build/cpp_invoke_rust_demo
```

# 4 Reference

* [Rust Documentation](https://doc.rust-lang.org/stable/)
* [The Rust Programming Language](https://doc.rust-lang.org/stable/book/index.html)
* [The Rust Reference](https://doc.rust-lang.org/stable/reference/)
* [The Cargo Book](https://doc.rust-lang.org/stable/cargo/)
* [The rustc book](https://doc.rust-lang.org/stable/rustc/index.html)
* [CXX — safe interop between Rust and C++](https://cxx.rs/)
* [Crate cxx](https://docs.rs/cxx/latest/cxx/#cargo-based-setup)
