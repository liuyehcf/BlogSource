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

## 1.1 Keyword

### 1.1.1 'static

The `'static` lifetime means: lives for the entire program duration.

## 1.2 Data Types

### 1.2.1 Unsafe Raw Pointers

* `*const T`: raw pointer to immutable data.
* `*mut T`: raw pointer to mutable data.

```rust
fn main() {
    let x = 42;
    let r: *const i32 = &x;
    let r_mut: *mut i32 = &x as *const i32 as *mut i32;

    unsafe {
        println!("{}", *r);
        println!("{}", *r_mut);
    }
}
```

## 1.3 Ownership

**Keep these rules in mind as we work through the examples that illustrate them:**

* Each value in Rust has an owner.
* There can only be one owner at a time.
* When the owner goes out of scope, the value will be dropped.
* Rust will never automatically create “deep” copies of your data.

### 1.3.1 Reference

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

### 1.3.2 The Slice Type

A slice is a kind of reference, so it does not have ownership.

## 1.4 Scope

* RAII, Resource Acquisition Is Initialization:
    * The notion of a destructor in Rust is provided through the Drop `trait`.
* Ownership and moves:
    * Because variables are in charge of freeing their own resources, resources can only have one owner.
    * When doing assignments `let x = y` or passing function arguments by value `foo(x)`, the ownership of the resources is transferred. In Rust-speak, this is known as a `move`.
* Borrowing:
    * Most of the time, we'd like to access data without taking ownership over it. To accomplish this, Rust uses a borrowing mechanism. Instead of passing objects by value `T`, objects can be passed by reference `&T`.

## 1.5 Fundamentals of Asynchronous Programming: Async, Await, Futures, and Streams

### 1.5.1 Parallelism and Concurrency

## 1.6 Generic

### 1.6.1 Bounds

When working with generics, the type parameters often must use traits as bounds to stipulate what functionality a type implements.

Multiple bounds for a single type can be applied with a `+`. Like normal, different types are separated with `,`.

## 1.7 Traits

A `trait` is a collection of methods defined for an unknown type: `Self`. They can access other methods declared in the same trait.

**Commonly used traits:**

* `Drop`
* `Iterator`
* `Clone`

### 1.7.1 Dispatch

```rust
trait Speak {
    fn speak(&self);
}

struct Dog;
impl Speak for Dog {
    fn speak(&self) {
        println!("Woof!");
    }
}

struct Cat;
impl Speak for Cat {
    fn speak(&self) {
        println!("Meow!");
    }
}

// Static dispatch
fn talk_static<T: Speak>(animal: T) {
    animal.speak();
}

// Dynamic dispatch
fn talk_dynamic(animal: &dyn Speak) {
    animal.speak();
}

fn main() {
    let dog = Dog;
    let cat = Cat;

    // Using static dispatch
    talk_static(dog);
    talk_static(cat);

    // Using dynamic dispatch
    let animals: Vec<&dyn Speak> = vec![&Dog, &Cat];
    for animal in animals {
        talk_dynamic(animal);
    }
}
```

## 1.8 Attributes

Refer to [Attributes](https://doc.rust-lang.org/reference/attributes.html) for more details.

**Attributes can be classified into the following kinds:**

* Built-in attributes
* Proc macro attributes
* Derive macro helper attributes
* Tool attributes

### 1.8.1 Built-in attributes

#### 1.8.1.1 Derive

Attribute `Derive` is used to automatically implement standard traits for a struct or enum.

* `Debug`: Enables `println!("{:?}", x)`
* `Clone`: Allows `.clone()`
* `Copy`: Enables copying instead of moving
* `PartialEq & Eq`: Enables `==` and `!=` comparisons
* `Hash`: Allows using the type in a HashMap

#### 1.8.1.2 inline

Attribute `inline` is used to hint compiler to inline a function.

* `#[inline(always)]`: Forces inlining.
* `#[inline(never)]`: Prevents inlining.

#### 1.8.1.3 allow

Attribute `allow` is used to suppress warnings.

* `#![allow(warnings)]`: Suppress all warnings for the whole file
* `#[allow(unused_variables)]`
* `#[allow(dead_code)]`
* `#[allow(unused_variables, dead_code)]`

#### 1.8.1.4 cfg

Attribute `cfg` is used to enable conditional compilation.

```rust
#[cfg(target_os = "linux")]
fn only_on_linux() {
    println!("Running on Linux!");
}
```

#### 1.8.1.5 test

Marks a test function.

```rust
pub fn add(left: u64, right: u64) -> u64 {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
```

#### 1.8.1.6 Linkage & FFI (Interfacing with C): no_mangle, repr

* `#[no_mangle]`: Prevents Rust from renaming a function.
* `#[repr(C)]`: Ensures a struct has C-compatible layout.

## 1.9 Modular Architecture

**Main Concepts:**

* `Packages`: A Cargo feature that lets you build, test, and share crates
* `Crates`: A tree of modules that produces a library or executable
* `Modules and use`: Let you control the organization, scope, and privacy of paths
* `Paths`: A way of naming an item, such as a struct, function, or module

### 1.9.1 Crate

A crate is the smallest amount of code that the Rust compiler considers at a time. Crates can contain modules, and the modules may be defined in other files that get compiled with the crate.

A crate can come in one of two forms: a binary crate or a library crate. Most of the time when Rustaceans say 'crate', they mean library crate, and they use 'crate' interchangeably with the general programming concept of a 'library'.

### 1.9.2 Package

A package is a bundle of one or more crates that provides a set of functionality. A package contains a `Cargo.toml` file that describes how to build those crates.

Cargo follows a convention that `src/main.rs` is the crate root of a binary crate with the same name as the package. Likewise, Cargo knows that if the package directory contains `src/lib.rs`, the package contains a library crate with the same name as the package, and `src/lib.rs` is its crate root.

A package can have multiple binary crates by placing files in the src/bin directory: each file will be a separate binary crate.

### 1.9.3 Module

**Main keywords:**

* `use`: brings a path into scope.
* `pub`: make items public.

**Here is how modules work:**

* `Start from the crate root`: When compiling a crate, the compiler first looks in the crate root file (usually `src/lib.rs` for a library crate or `src/main.rs` for a binary crate) for code to compile.
* `Declaring modules`: In the crate root file, you can declare new modules; say you declare a `garden` module with `mod garden`;. The compiler will look for the module's code in these places:
    * Inline, within curly brackets that replace the semicolon following `mod garden`.
    * In the file `src/garden.rs`.
    * In the file `src/garden/mod.rs`.
* `Declaring submodules`: In any file other than the crate root, you can declare submodules. For example, you might declare `mod vegetables`; in `src/garden.rs`. The compiler will look for the submodule's code within the directory named for the parent module in these places:
    * Inline, directly following `mod vegetables`, within curly brackets instead of the semicolon.
    * In the file `src/garden/vegetables.rs`
    * In the file `src/garden/vegetables/mod.rs`
* `Paths to code in modules`: Once a module is part of your crate, you can refer to code in that module from anywhere else in that same crate, as long as the privacy rules allow, using the path to the code. For example, an `Asparagus` type in the garden vegetables module would be found at `crate::garden::vegetables::Asparagus`.
* `Private vs. public`: Code within a module is private from its parent modules by default. To make a module public, declare it with `pub mod` instead of `mod`. To make items within a public module public as well, use `pub` before their declarations.
* `The use keyword`: Within a scope, the `use` keyword creates shortcuts to items to reduce repetition of long paths. In any scope that can refer to `crate::garden::vegetables::Asparagus`, you can create a shortcut with use `crate::garden::vegetables::Asparagus`; and from then on you only need to write Asparagus to make use of that type in the scope.

### 1.9.4 Prelude

In Rust, the prelude is a small set of commonly used types, traits, and macros from the standard library that are automatically imported into every Rust crate.

* It's designed to save you from writing repetitive `use` statements for things you almost always need.
* Types and traits in the prelude are considered essential for everyday Rust programming.

**what's in the Prelude:**

* Common types:
    * `Box<T>`: heap-allocated smart pointer.
    * `Vec<T>`: dynamic array.
    * `String`: growable UTF-8 string.
    * `Option<T>`/`Result<T, E>`: optional and error-handling types.
* Common traits:
    * `Copy`
    * `Clone`
    * `Drop`
    * `Eq`
    * `PartialEq`
    * `Ord`
    * `PartialOrd`
* Common macros (imported automatically in prelude macro modules):
    * `println!`
    * `format!`
    * `vec!`

# 2 Standard Library

## 2.1  Smart Pointers: `Box<T>`

```rust
fn main() {
    let b = Box::new(5);
    println!("b = {b}");
}
```

## 2.2 std::sync::Arc

Arc means Atomic Reference Counted.

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3]);

    let mut handles = vec![];
    for i in 0..3 {
        let data_ref = Arc::clone(&data); // increase refcount atomically
        let handle = thread::spawn(move || {
            println!("Thread {} sees: {:?}", i, data_ref);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

## 2.3 std::sync::mpsc

`std::sync::mpsc` in Rust is a standard library module that provides multi-producer, single-consumer (MPSC) channels for safe message passing between threads, enabling concurrent communication through a sender `tx` and a receiver `rx`.

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    // Create a channel
    let (tx, rx) = mpsc::channel();

    // Spawn a thread to send messages
    let sender_thread = thread::spawn(move || {
        let messages = vec![
            String::from("Hello"),
            String::from("from"),
            String::from("the"),
            String::from("thread!"),
        ];

        for msg in messages {
            tx.send(msg).unwrap();
            thread::sleep(Duration::from_secs(1)); // Simulate some work
        }
    });

    // Receive messages in the main thread
    for received in rx {
        println!("Received: {}", received);
    }

    // Wait for the sender thread to finish
    sender_thread.join().unwrap();
}
```

# 3 FFI

## 3.1 Without ffi crate

### 3.1.1 Rust Calling C++

```sh
cargo new rust_invoke_cpp_demo
cd rust_invoke_cpp_demo

cat > Cargo.toml << 'EOF'
[package]
name = "rust_invoke_cpp_demo"
version = "0.1.0"
edition = "2024"
EOF

cat > src/main.rs << 'EOF'
unsafe extern "C" {
    pub fn add(i: i32, j: i32) -> i32;
}

fn main() {
    let res = unsafe { add(1, 2) };
    println!("Add 1 + 2 = {}", res);
}
EOF

mkdir cpp
cat > cpp/math.h << 'EOF'
#pragma once

extern "C" int add(int i, int j);
EOF
cat > cpp/math.cpp << 'EOF'
#include "math.h"

int add(int i, int j) {
    return i + j;
}
EOF

cat > build.rs << 'EOF'
use std::env;
use std::path::Path;
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=cpp/math.h");
    println!("cargo:rerun-if-changed=cpp/math.cpp");

    let out_dir = env::var("OUT_DIR").unwrap();
    let obj_file = Path::new(&out_dir).join("math.o");
    let lib_file = Path::new(&out_dir).join("libmath.a");

    // Compile C++ source to object file
    let output = Command::new("g++")
        .args(["-c", "-fPIC", "-std=gnu++11", "-Icpp", "cpp/math.cpp", "-o"])
        .arg(&obj_file)
        .output()
        .expect("Failed to compile C++ source");

    if !output.status.success() {
        panic!(
            "C++ compilation failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    // Create static library
    let output = Command::new("ar")
        .args(["rcs"])
        .arg(&lib_file)
        .arg(&obj_file)
        .output()
        .expect("Failed to create static library");

    if !output.status.success() {
        panic!(
            "Library creation failed: {}",
            String::from_utf8_lossy(&output.stderr)
        );
    }

    println!("cargo:rustc-link-search=native={}", out_dir);
    println!("cargo:rustc-link-lib=static=math");
    println!("cargo:rustc-link-lib=stdc++");
}
EOF

cargo build && cargo run
```

### 3.1.2 C++ Calling Rust

```sh
cargo new --lib cpp_invoke_rust_demo
cd cpp_invoke_rust_demo

# rust part
cat > Cargo.toml << 'EOF'
[package]
name = "cpp_invoke_rust_demo"
version = "0.1.0"
edition = "2024"

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
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_uint};

// Import the Person struct and functions
use crate::{Person, greet, new_person};

// FFI interface for C++

// Export greet function with C-compatible ABI
#[unsafe(no_mangle)]
extern "C" fn greet_c() -> *mut c_char {
    let result = greet();
    CString::new(result).unwrap().into_raw()
}

// Export function to free string memory
#[unsafe(no_mangle)]
extern "C" fn free_string(s: *mut c_char) {
    unsafe {
        if !s.is_null() {
            let _ = CString::from_raw(s);
        }
    }
}

// Opaque pointer type for Person
type PersonOpaque = Person;

// Convert *mut PersonOpaque back to &Person
unsafe fn person_from_ptr(ptr: *mut PersonOpaque) -> &'static Person {
    unsafe { &*(ptr as *mut Person) }
}

// Convert *mut PersonOpaque back to &mut Person
unsafe fn person_from_ptr_mut(ptr: *mut PersonOpaque) -> &'static mut Person {
    unsafe { &mut *(ptr as *mut Person) }
}

// Export new_person function with C-compatible ABI
#[unsafe(no_mangle)]
extern "C" fn new_person_c(name: *const c_char, age: c_uint) -> *mut PersonOpaque {
    let name_str = unsafe {
        if name.is_null() {
            "".to_string()
        } else {
            CStr::from_ptr(name).to_string_lossy().into_owned()
        }
    };

    Box::into_raw(new_person(name_str, age as u32)) as *mut PersonOpaque
}

// Export get_name function with C-compatible ABI
#[unsafe(no_mangle)]
extern "C" fn person_get_name(person: *mut PersonOpaque) -> *mut c_char {
    if person.is_null() {
        return std::ptr::null_mut();
    }

    let name = unsafe { person_from_ptr(person).get_name() };

    CString::new(name).unwrap().into_raw()
}

// Export get_age function with C-compatible ABI
#[unsafe(no_mangle)]
extern "C" fn person_get_age(person: *mut PersonOpaque) -> c_uint {
    if person.is_null() {
        return 0;
    }

    unsafe { person_from_ptr(person).get_age() as c_uint }
}

// Export birthday function with C-compatible ABI
#[unsafe(no_mangle)]
extern "C" fn person_birthday(person: *mut PersonOpaque) {
    if !person.is_null() {
        unsafe {
            person_from_ptr_mut(person).birthday();
        }
    }
}

// Export function to free Person memory
#[unsafe(no_mangle)]
extern "C" fn free_person(person: *mut PersonOpaque) {
    unsafe {
        if !person.is_null() {
            let _ = Box::from_raw(person as *mut Person);
        }
    }
}
EOF

cat > build.rs << 'EOF'
fn main() {
    println!("cargo:rerun-if-changed=src/bridge.rs");
    println!("cargo:rerun-if-changed=src/lib.rs");
}
EOF

cargo clean && cargo build --release

# cpp part
mkdir cpp
cat > cpp/main.cpp << 'EOF'
#include <cstring>
#include <iostream>

// Forward declarations for Rust FFI functions
extern "C" {
char* greet_c();
void free_string(char* s);

struct PersonOpaque;
PersonOpaque* new_person_c(const char* name, unsigned int age);
char* person_get_name(PersonOpaque* person);
unsigned int person_get_age(PersonOpaque* person);
void person_birthday(PersonOpaque* person);
void free_person(PersonOpaque* person);
}

int main() {
    // Call Rust function
    char* rust_message = greet_c();
    std::cout << "Rust says: " << rust_message << std::endl;
    free_string(rust_message); // Free the string memory

    // Create a Rust Person instance in C++
    const char* name = "Alice";
    PersonOpaque* person = new_person_c(name, 25);

    // Get and print person's info
    char* person_name = person_get_name(person);
    std::cout << "Person's name: " << person_name << std::endl;
    free_string(person_name); // Free the string memory

    unsigned int person_age = person_get_age(person);
    std::cout << "Person's age: " << person_age << std::endl;

    // Call birthday method
    person_birthday(person);
    person_age = person_get_age(person);
    std::cout << "After birthday, age: " << person_age << std::endl;

    // Free the person memory
    free_person(person);

    return 0;
}
EOF

mkdir build
# Static version
gcc -o build/main_static -Itarget/cxxbridge cpp/main.cpp target/release/libcpp_invoke_rust_demo.a -lstdc++ -std=gnu++17 -lpthread -ldl
build/main_static

# Dynamic version
gcc -o build/main_dynamic -Itarget/cxxbridge -Ltarget/release cpp/main.cpp -lcpp_invoke_rust_demo -lstdc++ -std=gnu++17 -lpthread -ldl
LD_LIBRARY_PATH=target/release build/main_dynamic

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

## 3.2 Using cxx

### 3.2.1 Rust Calling C++

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
#pragma once

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

### 3.2.2 C++ Calling Rust

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
name = "rust_ffi"
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
#[cxx::bridge(namespace = "RustFFI")]
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

pub use crate::{Person, greet, new_person}; // Expose the function so it can be found
EOF

cat > build.rs << 'EOF'
fn main() {
    cxx_build::bridge("src/bridge.rs") // Generates the bridge
        .flag_if_supported("-std=c++17") // Ensures C++17 support
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
    rust::String rust_message = RustFFI::greet();
    std::cout << "Rust says: " << rust_message.c_str() << std::endl;

    // Create a Rust Person instance in C++
    rust::Box<RustFFI::Person> person = RustFFI::new_person("Alice", 25);

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
OUT=$(echo target/release/build/cpp_invoke_rust_demo-*/out)
CXXOUT=$(echo target/release/build/cxx-*/out)
# Static version
gcc -o build/main_static -I"$OUT/cxxbridge/include" cpp/main.cpp target/release/librust_ffi.a -lstdc++ -std=gnu++17 -lpthread -ldl
build/main_static

# Dynamic version cannot work
gcc -o build/main_dynamic -I"$OUT/cxxbridge/include" -Ltarget/release cpp/main.cpp "$OUT/cxxbridge/sources/cpp_invoke_rust_demo/src/bridge.rs.cc" "$CXXOUT/libcxxbridge1.a" -lrust_ffi -lstdc++ -std=gnu++17 -lpthread -ldl
LD_LIBRARY_PATH=target/release build/main_dynamic

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
    ${RUST_LIB_DIR}/release/librust_ffi.a
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

# 4 Tools

## 4.1 Toolchain management: rustup

**[Install](https://www.rust-lang.org/tools/install):**

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Usage:**

* `rustup show`
* `rustup default stable`
    * `rustup default 1.85`
* `rustup component add rust-analyzer`

## 4.2 Cargo

### 4.2.1 Format Code

* `cargo fmt`: It will use edition of `Cargo.toml`

### 4.2.2 Search Library

* `cargo tree`
* `cargo search regex`
* `cargo info regex`

## 4.3 rustfmt

Rustfmt is designed to be very configurable. You can create a TOML file called `rustfmt.toml` or `.rustfmt.toml`, place it in the project or any other parent directory and it will apply the options in that file. If none of these directories contain such a file, both your home directory and a directory called `rustfmt` in your global config directory (e.g. `.config/rustfmt/`) are checked as well.

```toml
cat > ~/.rustfmt.toml << 'EOF'
edition = "2021"
EOF
```

# 5 Tips

## 5.1 Check all compile checks

`rustc -W help`

# 6 Reference

* [Rust Documentation](https://doc.rust-lang.org/stable/)
    * [The Rust Programming Language](https://doc.rust-lang.org/stable/book/index.html)
    * [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
    * [The Rust Reference](https://doc.rust-lang.org/stable/reference/)
    * [The Cargo Book](https://doc.rust-lang.org/stable/cargo/)
    * [The rustc book](https://doc.rust-lang.org/stable/rustc/index.html)
* [CXX — safe interop between Rust and C++](https://cxx.rs/)
* [Crate cxx](https://docs.rs/cxx/latest/cxx/#cargo-based-setup)
