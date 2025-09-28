---
title: Cpp-Meta-Programming
date: 2021-09-06 09:20:53
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

**本文转载摘录自[浅谈 C++ 元编程](https://bot-man-jl.github.io/articles/?post=2017/Cpp-Metaprogramming#%E4%BB%80%E4%B9%88%E6%98%AF%E5%85%83%E7%BC%96%E7%A8%8B)**

# 1 Introduction

## 1.1 What is Metaprogramming

**Metaprogramming calculates the constants, types, and code needed at runtime by manipulating program entities at compile time.**

In general programming, a program is directly written, compiled by a compiler, which produces target code for execution at runtime. Unlike regular programming, metaprogramming uses the template mechanism provided by the language, allowing the compiler to deduce and generate programs at compile time. The program deduced by metaprogramming is then further compiled by the compiler to produce the final target code.

Thus, metaprogramming is also known as two-level programming, generative programming, or template metaprogramming.

## 1.2 The Position of Metaprogramming in C++

**`C++` Language = Superset of C Language + Abstraction Mechanisms + Standard Library**

**`C++` has two main abstraction mechanisms:**

1. Object-Oriented Programming
1. Template Programming

To support object-oriented programming, `C++` provides classes that allow new types to be constructed from existing types in `C++`. In the area of template programming, `C++` provides templates, which represent general concepts in an intuitive way.

**There are two main applications of template programming:**

1. Generic Programming
1. Metaprogramming

The former focuses on the abstraction of general concepts, designing generic types or algorithms without needing to be overly concerned about how the compiler generates specific code.

The latter focuses on selection and iteration during template deduction, designing programs using template techniques.

## 1.3 History of C++ Metaprogramming

## 1.4 Language Support for Metaprogramming

`C++` metaprogramming primarily relies on the template mechanism provided by the language. In addition to templates, modern `C++` also allows the use of `constexpr` functions for constant calculations. Due to the limited functionality of `constexpr` functions, recursion depth and the number of calculations are still constrained by the compiler, and compile-time performance is relatively poor. Therefore, most current metaprogramming programs are based on templates. **This section mainly summarizes the foundational language features related to the `C++` template mechanism, including narrowly defined templates and generic `lambda` expressions.**

### 1.4.1 Narrow Templates

**The latest version of `C++` currently divides templates into four categories:**

1. Class templates
1. Function templates
1. Alias templates
1. Variable templates

The first two can generate new types and are considered type constructors, while the latter two are shorthand notations added by `C++` to simplify the former.

Class templates and function templates are used to define classes and functions with similar functionalities, abstracting types and algorithms in generic programming. In the standard library, containers and functions are applications of class templates and function templates.

Alias templates and variable templates were introduced in `C++11` and `C++14`, respectively, providing shorthand notation for type aliases and constants with template features. The former can implement methods such as nested classes in class templates, while the latter can be achieved through `constexpr` functions, static members of class templates, and function template return values. For example, the alias template `std::enable_if_t<T>` in `C++14` is equivalent to `typename std::enable_if<T>::type`, and the variable template `std::is_same<T, U>` in `C++17` is equivalent to `std::is_same<T, U>::value`. Although these two types of templates are not necessary, they can enhance code readability and improve template compilation performance.

**There are three types of template parameters in `C++`:**

1. Value parameters
1. Type parameters
1. Template parameters

Since `C++11`, `C++` has supported variadic templates, where the number of template parameters can be indefinite. Variadic parameters are folded into a parameter pack, and during usage, each parameter is iterated at compile time. The standard library's tuple, `std::tuple`, is an application of variadic templates (the tuple's type parameters are variable-length and can be matched using `template<typename... Ts>`).

Although template parameters can be passed as general type parameters (a template is also a type), they are distinguished separately because they allow parameter matching for the passed-in template. Code 8 uses `std::tuple` as a parameter, and through matching, extracts the variadic parameters inside `std::tuple`.

Specialization is similar to function overloading, providing a template implementation for all template parameter values or some template parameter values. Instantiation is akin to function binding, where the compiler determines which overload to use based on the number and type of parameters. Since functions and templates have similarities in overloading, their parameter overloading rules are also similar.

### 1.4.2 Generic Lambda Expressions

Since `C++` does not allow templates to be defined within functions, sometimes it's necessary to define a template outside a function to achieve specific local functionality within the function. On one hand, this leads to a loose code structure, making maintenance difficult; on the other, using templates requires passing specific context, which reduces reusability (similar to the callback mechanism in C, where a callback function cannot be defined within a function and must pass context through parameters).

To address this, `C++14` introduced generic lambda expressions, which, on one hand, allow constructing closures within functions like the `lambda` expressions introduced in `C++11`, avoiding the need to define local functionality used within the function outside the function. On the other hand, they enable the functionality of function templates, allowing parameters of any type to be passed.

# 2 Basic Operations of Metaprogramming

The template mechanism in `C++` only provides a pure functional approach, meaning it does not support variables, and all deduction must be completed at compile time. However, the templates provided in `C++` are Turing complete (`turing complete`), so it is possible to use templates to implement full metaprogramming.

There are two basic calculus rules for metaprogramming:

1. Compile-time testing
1. Compile-time iteration

These respectively implement selection and iteration in control structures. Based on these two basic calculus methods, more complex calculations can be achieved.

Additionally, metaprogramming often uses template parameters to pass different policies, allowing for dependency injection and inversion of control. For example, `std::vector<typename T, typename Allocator = std::allocator<T>>` allows passing an `Allocator` to implement custom memory allocation.

## 2.1 Compile-Time Testing

Compile-time testing is equivalent to the selection statement in procedural programming, allowing the implementation of `if-else/switch` selection logic.

Before `C++17`, compile-time testing was achieved through template instantiation and specialization, where the most specific template would be matched each time. `C++17` introduced a new method for compile-time testing using `constexpr-if`.

### 2.1.1 Testing Expressions

Similar to static assertions, the object of compile-time testing is a constant expression, an expression whose result can be determined at compile time. By using different constant expressions as parameters, various required template overloads can be constructed. For example, Code 1 demonstrates how to construct a predicate `isZero<Val>` to determine at compile time whether `Val` is `0`.

**Code 1:**

```cpp
template <unsigned Val>
struct _isZero {
    constexpr static bool value = false;
};

template <>
struct _isZero<0> {
    constexpr static bool value = true;
};

template <unsigned Val>
constexpr bool isZero = _isZero<Val>::value;

static_assert(!isZero<1>, "compile error");
static_assert(isZero<0>, "compile error");
```

### 2.1.2 Testing Types

**In many metaprogramming applications, type testing is required, where different functionality is implemented for different types. Common type tests fall into two categories:**

* **Checking if a type is a specific type:**
    * This can be achieved directly through template specialization.
* **Checking if a type meets certain conditions:**
    * This can be done through the "Substitution Failure Is Not An Error" rule (`SFINAE`), which ensures optimal matching.
    * Tag dispatch can also be used to match enumerable finite cases (for example, `std::advance<Iter>` selects an implementation based on `std::iterator_traits<Iter>::iterator_category` for the iterator type `Iter`).

**To better support `SFINAE`, `C++11`'s `<type_traits>` provides predicate templates `is_*/has_*` for type checking and two additional helpful templates:**

1. `std::enable_if` converts condition checks into constant expressions, similar to the "Test Expression" section's overload selection (though it requires an extra function parameter, function return type, or template parameter).
1. `std::void_t` directly checks for the existence of dependent members/functions; if they do not exist, overload resolution fails (it can be used to construct predicates, then conditions can be checked with `std::enable_if`).

For type-specific checks, similar to Code 1, change `unsigned Val` to `typename Type` and convert the template parameter from a value parameter to a type parameter, then match the overload according to the optimal match principle.

For condition-based type checks, Code 2 demonstrates how to convert basic C language data types to `std::string` in the `ToString` function. The code is divided into three parts:

1. First, three variable templates `isNum/isStr/isBad` are defined, each corresponding to a predicate for three type conditions (using `std::is_arithmetic` and `std::is_same` from `<type_traits>`).
1. Then, based on the `SFINAE` rule, `std::enable_if` is used to overload the function `ToString`, each corresponding to numerical, C-style string, and invalid types.
1. In the first two overloads, `std::to_string` and `std::string` constructors are called, respectively; in the last overload, a static assertion immediately raises an error.

**Code 2:**

```cpp
template <typename T>
constexpr bool isNum = std::is_arithmetic<T>::value;

template <typename T>
constexpr bool isStr = std::is_same<T, const char *>::value;

template <typename T>
constexpr bool isBad = !isNum<T> && !isStr<T>;

template <typename T>
std::enable_if_t<isNum<T>, std::string> ToString(T num) {
    return std::to_string(num);
}

template <typename T>
std::enable_if_t<isStr<T>, std::string> ToString(T str) {
    return std::string(str);
}

template <typename T>
std::enable_if_t<isBad<T>, std::string> ToString(T bad) {
    static_assert(sizeof(T) == 0, "neither Num nor Str");
}

auto a = ToString(1);  // std::to_string (num);
auto b = ToString(1.0);  // std::to_string (num);
auto c = ToString("0x0");  // std::string (str);
auto d = ToString(std::string {});  // not compile :-(
```

According to the rule of two-phase name lookup, directly using `static_assert(false)` would cause a compilation failure in the first phase, before the template is instantiated. Therefore, a type-dependent `false` expression (typically dependent on the parameter `T`) is required for a failing static assertion.

Similarly, a variable template can be defined as `template <typename...> constexpr bool false_v = false`, and `false_v<T>` can be used in place of `sizeof(T) == 0`.

### 2.1.3 Using if for Compile-Time Testing

For those new to metaprogramming, it's common to try using an `if` statement for compile-time testing. Code 3 is an incorrect version of Code 2, which serves as a representative example of the differences between metaprogramming and regular programming.

**Code 3:**

```cpp
template <typename T>
std::string ToString(T val) {
    if (isNum<T>)
        return std::to_string(val);
    else if (isStr<T>)
        return std::string(val);
    else
        static_assert(!isBad<T>, "neither Num nor Str");
}
```

The error in Code 3 lies in the function `ToString`'s compilation. For a given type `T`, the function needs to perform two function bindings: `val` is passed as an argument to both `std::to_string(val)` and `std::string(val)`, and then a static assertion checks whether `!isBad<T>` is `true`. This causes an issue: one of the two bindings will fail. For instance, if `ToString("str")` is called, during compilation, `std::string(const char *)` can be correctly overloaded, but `std::to_string(const char *)` cannot find a proper overload, leading to a compilation failure.

If this were a scripting language, this code would be fine because scripting languages lack the concept of compilation; all function bindings are performed at runtime. However, in a statically-typed language, function binding is completed at compile time. To allow Code 3's style to be used in metaprogramming, `C++17` introduced `constexpr-if`, where simply replacing `if` with `if constexpr` in Code 3 allows it to compile.

The introduction of `constexpr-if` makes template testing more intuitive, improving the readability of template code. Code 4 demonstrates how to use `constexpr-if` to solve the issue of compile-time selection. Additionally, the catch-all statement no longer requires the `isBad<T>` predicate template and can use a type-dependent `false` expression for a static assertion (though a direct `static_assert(false)` cannot be used).

**Code 4:**

```cpp
template <typename T>
std::string ToString(T val) {
    if constexpr (isNum<T>)
        return std::to_string(val);
    else if constexpr (isStr<T>)
        return std::string(val);
    else
        static_assert(false_v<T>, "neither Num nor Str");
}
```

However, the idea behind `constexpr-if` had already appeared as early as `Visual Studio 2012`. It introduced the `__if_exists` statement, which was used for compile-time testing to check whether an identifier exists.

## 2.2 Compile-Time Iteration

Compile-time iteration is similar to loop statements in procedural programming, allowing logic similar to `for/while/do` loops.

Before `C++17`, unlike in regular programming, metaprogramming calculus rules were purely functional, meaning compile-time iteration could not be achieved through variable iteration and instead had to rely on recursion combined with specialization. **The general approach is to provide two types of overloads: one that accepts arbitrary parameters and recursively calls itself internally, and another that is a template specialization or function overload of the former, directly returning the result, effectively serving as the termination condition for recursion. Their overload conditions can be either expressions or types.**

`C++17` introduced fold expressions to simplify the syntax for iteration.

### 2.2.1 Iterating over Fixed-Length Templates

Code 5 demonstrates how to use compile-time iteration to compute the factorial (`N!`) at compile time. The function `_Factor` has two overloads: one for any non-negative integer and another for `0` as the parameter. The former uses recursion to produce results, while the latter directly returns the result. When `_Factor<2>` is called, the compiler expands it to `2 * _Factor<1>`, then `_Factor<1>` expands to `1 * _Factor<0>`, and finally `_Factor<0>` directly matches the overload with `0` as the parameter.

**Code 5:**

```cpp
template <unsigned N>
constexpr unsigned _Factor() {
    return N * _Factor<N - 1>();
}

template <>
constexpr unsigned _Factor<0>() {
    return 1;
}

template <unsigned N>
constexpr unsigned Factor = _Factor<N>();

static_assert(Factor<0> == 1, "compile error");
static_assert(Factor<1> == 1, "compile error");
static_assert(Factor<4> == 24, "compile error");
```

### 2.2.2 Iterating over Variable-Length Templates

To iterate through each parameter in a variadic template, compile-time iteration can be used to implement loop traversal. Code 6 implements a function that sums all parameters. The function `Sum` has two overloads: one for when there are no function parameters, and another for when there is at least one function parameter. Similar to iteration with fixed-length templates, this is also achieved through recursive calls to traverse the parameters.

**Code 6:**

```cpp
template <typename T>
constexpr auto Sum() {
    return T(0);
}

template <typename T, typename... Ts>
constexpr auto Sum(T arg, Ts... args) {
    return arg + Sum<T>(args...);
}

static_assert(Sum<int>() == 0, "compile error");
static_assert(Sum(1, 2.0, 3) == 6, "compile error");
```

### 2.2.3 Simplifying Compile-Time Iteration with Fold Expressions

When variadic templates were introduced in `C++11`, direct syntax for expanding parameter packs within templates was supported; however, this syntax only allowed unary operations on each parameter within the pack. To perform binary operations between parameters, additional templates were necessary (for example, Code 6 defines two `Sum` function templates, with one expanding the parameter pack to recursively call itself).

`C++17` introduced fold expressions, enabling direct traversal of each parameter within a parameter pack and applying a binary operator to perform either a left fold or right fold. Code 7 improves upon Code 6 by using a left fold expression with an initial value of `0`.

**Code 7:**

```cpp
template <typename... Ts>
constexpr auto Sum(Ts... args) {
    return (0 + ... + args);
}

static_assert(Sum() == 0, "compile error");
static_assert(Sum(1, 2.0, 3) == 6, "compile error");
```

## 2.3 Metaprogramming vs. Regular programming

| Concept| Regular Programming| Metaprogramming |
|:--|:--|:--|
| Sequence | Statements in order | Nested templates, Type deduction |
| Branching | `if`, `else`, `switch` | `std::conditional`, `constexpr if`, `SFINAE`, template specialization |
| Looping (Iteration) | `for`, `while`, `do-while` | Recursive templates, template specialization, `std::integer_sequence` |

# 3 Basic Applications of Metaprogramming

Metaprogramming enables the design of type-safe and runtime-efficient programs with ease. Today, metaprogramming is widely applied in `C++` programming practices. For example, `Todd Veldhuizen` proposed a metaprogramming approach to construct expression templates, optimizing expressions to improve the runtime speed of vector calculations. Additionally, `K. Czarnecki` and `U. Eisenecker` used templates to implement a `Lisp` interpreter.

Although metaprogramming applications vary, they are combinations of three fundamental types: numeric computation, type deduction, and code generation. For instance, in the `ORM` (object-relation mapping) designed by `BOT Man`, type deduction and code generation are primarily used. Based on an object's type in `C++`, the types of each field in the corresponding database relation tuple are deduced. Operations on `C++` objects are mapped to corresponding database statements, generating the relevant code.

## 3.1 Numerical Computation

As one of the earliest applications of metaprogramming, numeric computation can be used for compile-time constant calculation and optimizing runtime expression evaluation.

Compile-time constant calculation allows programmers to use the programming language to define constants at compile time, rather than directly writing constants (magic numbers) or calculating these constants at runtime. For example, Codes 5, 6, and 7 perform compile-time constant calculations.

The earliest concept of using metaprogramming to optimize expression evaluation was proposed by `Todd Veldhuizen`. By utilizing expression templates, it is possible to implement features such as partial evaluation, lazy evaluation, and expression simplification.

## 3.2 Type Deduction

Beyond basic numeric computation, metaprogramming can also be used to deduce conversions between arbitrary types. For example, when combining a domain-specific language natively with `C++`, type deduction can convert types in these languages into `C++` types while ensuring type safety.

`BOT Man` proposed a method for compile-time tuple type deduction in `SQL`. Since all data types in `C++` cannot be `NULL`, whereas `SQL` fields can be `NULL`, fields that may be null are stored in `C++` using the `std::optional` container. For tuples resulting from `SQL` outer joins, where all fields can be `NULL`, `ORM` needs a method to convert tuples with fields that may be either `std::optional<T>` or `T` into a new tuple where all fields are `std::optional<T>`.

**Code 8:**

1. Define `TypeToNullable`, and specialize it for `std::optional<T>`. Its purpose is to automatically convert both `std::optional<T>` and `T` to `std::optional<T>`.
2. Define `TupleToNullable`, which decomposes all types in a tuple, converts them into a parameter pack, passes each type in the parameter pack to `TypeToNullable`, and finally reassembles the results into a new tuple.

```cpp
template <typename T>
struct TypeToNullable {
    using type = std::optional<T>;
};
template <typename T>
struct TypeToNullable<std::optional<T>> {
    using type = std::optional<T>;
};

template <typename... Args>
auto TupleToNullable(const std::tuple<Args...>&) {
    return std::tuple<typename TypeToNullable<Args>::type...>{};
}

auto t1 = std::make_tuple(std::optional<int>{}, int{});
auto t2 = TupleToNullable(t1);
static_assert(!std::is_same<std::tuple_element_t<0, decltype(t1)>, std::tuple_element_t<1, decltype(t1)>>::value,
              "compile error");
static_assert(std::is_same<std::tuple_element_t<0, decltype(t2)>, std::tuple_element_t<1, decltype(t2)>>::value,
              "compile error");
```

## 3.3 Code Generation

Like generic programming, metaprogramming is often used for code generation. However, unlike simple generic programming, code generated by metaprogramming is often derived through compile-time testing and compile-time iteration. For example, Code 2 generates code that converts basic C language types to `std::string`.

In real projects, we often need to convert between `C++` data structures and domain models related to actual business logic. For example, a `JSON` string representing a domain model might be deserialized into a `C++` object, further processed by business logic, and then serialized back into a `JSON` string. Such serialization/deserialization code generally does not need to be manually written and can be automatically generated.

`BOT Man` proposed a method based on compile-time polymorphism that defines a schema for the domain model, automatically generating code for serialization/deserialization between the domain model and `C++` objects. This allows business logic developers to focus more on handling the business logic without needing to worry about low-level data structure conversions.

# 4 Key Challenges in Metaprogramming

Despite the rich capabilities of metaprogramming, both learning and using it are quite challenging. On one hand, the complex syntax and calculus rules often deter beginners; on the other, even experienced `C++` developers can fall into the hidden pitfalls of metaprogramming.

## 4.1 Complexity

Due to significant language-level limitations in metaprogramming, much metaprogramming code relies heavily on compile-time testing and iteration techniques, often resulting in poor readability. Additionally, designing compile-time calculus in an elegant manner is challenging, making the writability of metaprogramming less favorable compared to typical `C++` programs.

Modern `C++` continuously introduces features aimed at reducing the complexity of metaprogramming:

* Alias templates in `C++11` provide a shorthand for types within templates.
* Variable templates in `C++14` offer a shorthand for constants within templates.
* `constexpr-if` in `C++17` introduces a new syntax for compile-time testing.
* Fold expressions in `C++17` simplify the process of writing compile-time iterations.

Based on the generic `lambda` expressions in `C++14`, `Louis Dionne` designed the metaprogramming library `Boost.Hana`, which proposes metaprogramming without templates, marking the transition from template metaprogramming to modern metaprogramming. The core idea is that using only the generic `lambda` expressions in `C++14` and `constexpr/decltype` from `C++11` enables the quick implementation of basic metaprogramming calculus.

## 4.2 Instantiation Errors

Template instantiation differs from function binding: before compilation, the former imposes few restrictions on the types of parameters passed in, whereas the latter determines the expected parameter types based on the function declaration. Parameter checks for templates occur during instantiation, making it difficult for the program designer to detect potential errors before compilation.

To reduce potential errors, `Bjarne Stroustrup` and others proposed introducing concepts at the language level for templates. With concepts, restrictions can be placed on parameters, allowing only types that meet specific requirements to be passed into the template. For example, the template `std::max` could be constrained to accept only types that support the `<` operator. However, for various reasons, this language feature was not included in the `C++` standard for a long time (though it may have been added in `C++20`). Despite this, compile-time testing and static assertions can still provide checks.

Additionally, in the case of template instantiation errors at deeper levels, the compiler reports each level of instantiation, leading to verbose error messages that can obscure the source of the issue. `BOT Man` proposed a short-circuit compiling method to offer more user-friendly compile-time error messages in metaprogramming libraries. This approach involves having the interface check whether the passed parameters support the required operations before the implementation performs them. If they do not, the interface uses short-circuiting to redirect to an error-reporting interface, stopping compilation and using static assertions to provide error messages. `Paul Fultz II` proposed a similar approach to concept/constraint interface checks (like those in `C++20`) by defining trait templates corresponding to concepts and checking if these traits are met before usage.

## 4.3 Code Bloat

Since templates instantiate for each unique set of template arguments, a large number of parameter combinations can lead to code bloat, resulting in a massive codebase. This code can be divided into two types: dead code and effective code.

In metaprogramming, the focus is often on the final result rather than the process. For example, in Code 5, we only care that `Factor<4> == 24` and do not need the temporary templates generated during intermediate steps. However, when `N` is large, compilation produces many temporary templates. These temporary templates are dead code, meaning they are not executed. The compiler automatically optimizes the final code generation by removing these unused codes at link-time, ensuring that the final output does not include them. Nevertheless, generating excessive dead code wastes valuable compilation time.

In other cases, the expanded code is all effective code—meaning it is executed—but the code size remains large due to the wide variety of parameter types needed. The compiler has limited ability to optimize such code, so programmers should design to avoid code bloat. Thin templates are typically used to reduce the size of template instances; the approach is to abstract common parts of templates instantiated with different parameters into shared base classes or functions, with the distinct parts inheriting from the base class or calling the function to enable code sharing.

For example, in the implementation of `std::vector`, `T*` and `void*` are specialized. Then, the implementation for all `T*` types is inherited from the `void*` implementation, with public functions using casting to convert between `void*` and `T*`. This allows all pointer types in `std::vector` to share a single implementation, avoiding code bloat (Code 9).

**Code 9:**

```cpp
template <typename T>
class vector; // general
template <typename T>
class vector<T*>; // partial spec
template <>
class vector<void*>; // complete spec

template <typename T>
class vector<T*> : private vector<void*> {
    using Base = Vector<void∗>;

public:
    T∗& operator[](int i) {
        return reinterpret_cast<T∗&>(Base::operator[](i));
    }
    ...
}
```

## 4.4 Compile-Time Performance

Although metaprogramming does not add runtime overhead, excessive use can significantly increase compilation time, especially in large projects. Optimizing metaprogramming compile-time performance requires special techniques.

According to the One Definition Rule, a template can be instantiated with the same parameters across multiple translation units and merged into a single instance at link time. However, template operations in each translation unit are independent, which increases compilation time and produces excessive intermediate code. Explicit instantiation is commonly used to avoid repeated template instantiations. The approach is to explicitly define a template instance in one translation unit and declare the same instance with `extern` in other translation units. This method, which separates interface from implementation, is also commonly used for template interfaces in static libraries.

`Chiel Douwes` conducted an in-depth analysis of common template operations in metaprogramming, comparing the costs of several template operations (Cost of operations: The Rule of Chiel) from highest to lowest (without considering `C++14` variable templates):

1. Substitution Failure Is Not An Error (`SFINAE`)
2. Instantiating function templates
3. Instantiating class templates
4. Using alias templates
5. Adding parameters to class templates
6. Adding parameters to alias templates
7. Using cached types

Following these principles, `Odin Holmes` designed the type manipulation library `Kvasir`, which achieves high compilation performance compared to type manipulation libraries based on `C++98/11`. To measure the effectiveness of compilation performance optimizations, `Louis Dionne` developed a CMake-based compile-time benchmarking framework.

Additionally, `Mateusz Pusz` shared some best practices for metaprogramming performance. For example, `std::conditional_t` based on `C++11` alias templates and `std::is_same_v` based on `C++14` variable templates are faster than the traditional `std::conditional/std::is_same` approach. Code 10 demonstrates implementations using `std::is_same` and the variable template-based `std::is_same_v`.

**Code 10:**

```cpp
// traditional, slow
template <typename T, typename U>
struct is_same : std::false_type {};
template <typename T>
struct is_same<T, T> : std::true_type {};
template <typename T, typename U>
constexpr bool is_same_v = is_same<T, U>::value;

// using variable template, fast
template <typename T, typename U>
constexpr bool is_same_v = false;
template <typename T>
constexpr bool is_same_v<T, T> = true;
```

## 4.5 Debugging Templates

The primary runtime challenge in metaprogramming is debugging template code. When debugging code that has undergone extensive compile-time testing and compile-time iteration—meaning the code is a concatenation of various templates with many levels of expansion—one must frequently switch back and forth between template instances during debugging. In such cases, it is difficult for the debugger to pinpoint the issue within the expanded code.

As a result, some large projects avoid complex code generation techniques and instead use traditional code generators to produce repetitive code that is easier to debug. For example, `Chromium`'s common extension API defines `JSON/IDL` files, which a code generator uses to produce the relevant `C++` code and simultaneously generate interface documentation.

# 5 Summary

The emergence of `C++` metaprogramming was a serendipitous discovery: people realized that the template abstraction mechanism provided by `C++` could be effectively applied to metaprogramming. With metaprogramming, it's possible to write type-safe and runtime-efficient code. However, excessive use of metaprogramming can increase compilation time and reduce code readability. Nevertheless, as `C++` continues to evolve, new language features are consistently introduced, offering more possibilities for metaprogramming.

# 6 Applications of Metaprogramming

## 6.1 Utility

### 6.1.1 is_same

```cpp
template <typename T, typename U>
struct is_same {
    static constexpr bool value = false;
};

template <typename T>
struct is_same<T, T> {
    static constexpr bool value = true;
};
```

### 6.1.2 rank

```cpp
#include <iostream>

template <class T>
struct rank {
    static size_t const value = 0u;
};

template <class U, size_t N>
struct rank<U[N]> {
    static size_t const value = 1u + rank<U>::value;
};

int main() {
    using array_t = int[10][20][30];
    std::cout << "rank=" << rank<array_t>::value << std::endl;
    return 0;
}
```

We can also use `std::integral_constant` to achieve the functionality described above.

```cpp
#include <iostream>
#include <type_traits>

// Default version
template <typename T>
struct rank : std::integral_constant<size_t, 0> {};

template <typename U, size_t N>
struct rank<U[N]> : std::integral_constant<size_t, 1 + rank<U>::value> {};

int main() {
    using array_t = int[10][20][30];
    std::cout << "rank=" << rank<array_t>::value << std::endl;
    return 0;
}
```

### 6.1.3 one_of/type_in/value_in

Here is the implementation approach for `is_one_of`:

* First, define the template.
* `base1`: Define the single-parameter instantiation version, which serves as the termination state for recursion.
* `base2`: Define the instantiation version where the first element matches, also serving as a termination state for recursion.
* Define the instantiation version where the first element differs, and implement recursive instantiation through inheritance (during recursion, be mindful to reduce one parameter with each step).

```cpp
#include <iostream>
#include <type_traits>

// declare the interface only
template <typename T, typename... P0toN>
struct is_one_of;

// base #1: specialization recognizes empty list of types:
template <typename T>
struct is_one_of<T> : std::false_type {};

// base #2: specialization recognizes match at head of list of types:
template <typename T, typename... P1toN>
struct is_one_of<T, T, P1toN...> : std::true_type {};

// specialization recognizes mismatch at head of list of types:
template <typename T, typename P0, typename... P1toN>
struct is_one_of<T, P0, P1toN...> : is_one_of<T, P1toN...> {};

int main() {
    std::cout << is_one_of<double, double, float, long>::value << std::endl;
    std::cout << is_one_of<bool, double, float, long>::value << std::endl;
    return 0;
}
```

We can also use [fold expressions](https://www.bookstack.cn/read/cppreference-language/62e23cda3198622e.md) to implement recursive expansion.

```cpp
#include <iostream>
#include <type_traits>

template <typename T, typename... Args>
constexpr bool type_in = (std::is_same_v<T, Args> || ...);

template <typename T, T v, T... args>
constexpr bool value_in = ((v == args) || ...);

int main() {
    std::cout << type_in<double, double, float, long> << std::endl;
    std::cout << type_in<bool, double, float, long> << std::endl;
    std::cout << value_in<int, 1, 1, 2, 3, 4, 5> << std::endl;
    std::cout << value_in<int, 10, 1, 2, 3, 4, 5> << std::endl;
    return 0;
}
```

### 6.1.4 is_copy_assignable

Let's manually implement `std::is_copy_assignable` from the `<type_traits>` header, which is used to check if a class supports the copy assignment operator.

Example implementation steps and explanation:

* `std::declval<T>` is used to return a `T&&` type (refer to the reference collapsing rules).
* The function template `try_assignment(U&&)` has two type parameters, where the second type parameter is unused (its name is omitted) and has a default value of `typename = decltype(std::declval<U&>() = std::declval<U const&>())`. This part tests whether the specified type supports the copy assignment operation. If the type does not support it, the instantiation of the `try_assignment(U&&)` template will fail, and it will fall back to the default version `try_assignment(...)`. **This is the well-known `SFINAE, Substitution Failure Is Not An Error`.**
    * For implementing `is_copy_constructible`, `is_move_constructible`, or `is_move_assignable`, a similar approach can be used by replacing the expression in this part.
* `try_assignment(...)` is an overload that can match any number and type of arguments.

```cpp
#include <iostream>

template <typename T>
struct is_copy_assignable {
private:
    template <typename U, typename = decltype(std::declval<U&>() = std::declval<U const&>())>
    static std::true_type try_assignment(U&&);

    static std::false_type try_assignment(...);

public:
    using type = decltype(try_assignment(std::declval<T>()));
};

struct SupportCopyAssignment {
    SupportCopyAssignment() = delete;
    SupportCopyAssignment(const SupportCopyAssignment&) = delete;
    SupportCopyAssignment(SupportCopyAssignment&&) = delete;
    SupportCopyAssignment& operator=(const SupportCopyAssignment&) = default;
    SupportCopyAssignment& operator=(SupportCopyAssignment&&) = delete;
};

struct NoSupportCopyAssignment {
    NoSupportCopyAssignment() = delete;
    NoSupportCopyAssignment(const NoSupportCopyAssignment&) = delete;
    NoSupportCopyAssignment(NoSupportCopyAssignment&&) = delete;
    NoSupportCopyAssignment& operator=(const NoSupportCopyAssignment&) = delete;
    NoSupportCopyAssignment& operator=(NoSupportCopyAssignment&&) = delete;
};

int main() {
    std::cout << is_copy_assignable<SupportCopyAssignment>::type::value << std::endl;
    std::cout << is_copy_assignable<NoSupportCopyAssignment>::type::value << std::endl;
    return 0;
}
```

### 6.1.5 has_type_member

Let's implement `has_type_member`, which checks if a given type has a member type named `type`, that is, whether `typename T::type` exists for type `T`.

* The `primitive` version of `has_type_member` has two type parameters, with the second parameter having a default value of `void`.
* `std::void_t<T>` returns `void` for any `T`. For types that have a member type `type`, this specialized version is `well-formed`, so it matches this version; for types without a `type` member, the deduction of the second template parameter fails, falling back to other versions. This also utilizes `SFINAE`.
    * This example demonstrates an application of `std::void_t`.
    * Without `std::void_t`, `has_type_member<T, typename T::type>` would not be a specialization of `template <typename, typename = void>`. These two forms are essentially equivalent, so even if `T::type` exists, it would still match the default version.

```cpp
#include <iostream>
#include <type_traits>

template <typename, typename = void>
struct has_type_member : std::false_type {};

template <typename T>
struct has_type_member<T, std::void_t<typename T::type>> : std::true_type {};

struct WithNonVoidMemberType {
    using type = int;
};

struct WithVoidMemberType {
    using type = void;
};

struct WithNonTypeMemberType {
    static constexpr int type = 1;
};

struct WithoutMemberType {};

int main() {
    std::cout << has_type_member<WithNonVoidMemberType>::value << std::endl;
    std::cout << has_type_member<WithVoidMemberType>::value << std::endl;
    std::cout << has_type_member<WithNonTypeMemberType>::value << std::endl;
    std::cout << has_type_member<WithoutMemberType>::value << std::endl;
    return 0;
}
```

### 6.1.6 has_static_field_member

```cpp
#include <iostream>
#include <string>
#include <type_traits>

template <typename T, typename = void>
struct has_static_field : std::false_type {};

template <typename T>
struct has_static_field<T, std::void_t<decltype(T::value)>> : std::true_type {};

struct Foo {
    static constexpr int value = 0;
};

struct Bar {};

int main() {
    if (has_static_field<Foo>::value) {
        std::cout << "Foo has static field 'value'." << std::endl;
    } else {
        std::cout << "Foo does not have static field 'value'." << std::endl;
    }
    if (has_static_field<Bar>::value) {
        std::cout << "Bar has static field 'value'." << std::endl;
    } else {
        std::cout << "Bar does not have static field 'value'." << std::endl;
    }
    return 0;
}
```

### 6.1.7 has_object_field_member

```cpp
#include <iostream>
#include <string>
#include <type_traits>

template <typename T, typename = void>
struct has_object_field : std::false_type {};

template <typename T>
struct has_object_field<T, std::void_t<decltype(std::declval<T>().value)>> : std::true_type {};

struct Foo {
    int value = 0;
};

struct Bar {};

int main() {
    if (has_object_field<Foo>::value) {
        std::cout << "Foo has an object field named 'value'." << std::endl;
    } else {
        std::cout << "Foo does not have an object field named 'value'." << std::endl;
    }
    if (has_object_field<Bar>::value) {
        std::cout << "Bar has an object field named 'value'." << std::endl;
    } else {
        std::cout << "Bar does not have an object field named 'value'." << std::endl;
    }
    return 0;
}
```

### 6.1.8 has_func_member

```cpp
#include <iostream>
#include <string>
#include <type_traits>

template <typename T, typename = void>
struct has_to_string : std::false_type {};

template <typename T>
struct has_to_string<T, std::void_t<decltype(to_string(std::declval<T>()))>> : std::true_type {};

struct Foo {
    int val;
};

std::string to_string(Foo const& foo) {
    std::string buffer;
    buffer += "Foo(";
    buffer += "val=" + std::to_string(foo.val);
    buffer += ")";
    return buffer;
}

int main() {
    Foo foo;
    foo.val = 5;
    if constexpr (has_to_string<Foo>::value) {
        std::string str = to_string(foo);
        std::cout << to_string(foo) << std::endl;
    }
    return 0;
}
```

### 6.1.9 is_base_of

```cpp
#include <iostream>

template <typename Base, typename Derived>
struct is_base_of {
private:
    // Test if a pointer to Derived can be converted to a pointer to Base.
    static std::true_type test(const volatile Base*);
    static std::false_type test(...);

    // Remove cv-qualifiers for comparison, prevents issues with cv-qualified types
    using DecayedBase = typename std::remove_cv<Base>::type;
    using DecayedDerived = typename std::remove_cv<Derived>::type;

public:
    // Only allow this test when Derived is a class or struct type
    static constexpr bool value = std::is_class_v<DecayedBase> && std::is_class_v<DecayedDerived> &&
                                  decltype(test(static_cast<DecayedDerived*>(nullptr)))::value;
};

struct Foo {};
struct Bar : Foo {};
struct Baz {};

#define PRINT(x) std::cout << #x << ": " << ((x) ? "true" : "false") << std::endl;

int main() {
    PRINT((is_base_of<Foo, Bar>::value));
    PRINT((is_base_of<Foo, Baz>::value));
    return 0;
}
```

### 6.1.10 sequence

**The core idea is as follows:**

* `gen_seq<N>`: Intended to generate `seq<0, 1, 2, 3, ..., N-1>`.
* Use the recursive expansion `gen_seq<size_t N, size_t... S>`, where `N` represents the remaining numbers `1, 2, 3, ..., N-1`, and `S...` represents the already generated sequence. In each recursive step, place `N-1` into the sequence on the right. When `N = 0`, recursion ends.

```cpp
#include <iostream>

// get_first
template <size_t First, size_t... Others>
struct get_first {
    static constexpr size_t value = First;
};

// get_last
template <size_t First, size_t... Nums>
struct get_last;

template <size_t First, size_t... Nums>
struct get_last : get_last<Nums...> {};

template <size_t First>
struct get_last<First> {
    static constexpr size_t value = First;
};

// seq
template <size_t... N>
struct seq {
    static constexpr size_t size = sizeof...(N);
    static constexpr size_t first = get_first<N...>::value;
    static constexpr size_t last = get_last<N...>::value;
};

// seq_gen
template <size_t N, size_t... S>
struct gen_seq;

template <size_t N, size_t... S>
struct gen_seq : gen_seq<N - 1, N - 1, S...> {};

template <size_t... S>
struct gen_seq<0, S...> {
    using type = seq<S...>;
};

template <size_t... S>
using gen_seq_t = typename gen_seq<S...>::type;

int main() {
    std::cout << "size=" << gen_seq_t<100>::size << std::endl;
    std::cout << "first=" << gen_seq_t<100>::first << std::endl;
    std::cout << "last=" << gen_seq_t<100>::last << std::endl;
    return 0;
}
```

### 6.1.11 shared_ptr

| Aspect | `v1::shared_ptr` | `v2::shared_ptr` |
|:--|:--|:--|
| **What's stored?** | A single raw pointer `T* _p;` | A pointer to `helper_base`, which deletes the real object |
| **Deletion strategy** | `delete _p;` — destructor only runs if `T` is complete | Virtual destructor on `helper_base` ensures correct `delete` call |
| **Extra allocation** | None | One extra `new` for the helper object |
| **Runtime overhead** | Minimal (just a pointer) | Extra indirection + virtual call in destructor |
| **Compile-time safety**| Strong — requires `U*` to be convertible to `T*` | Weak — allows any `U*`, type erasure occurs |
| **Code bloat** | Template instantiated per `T` | Still per `T`, but heavy logic in shared virtual base |
| **Heterogeneous use** | Hard — not suitable for storing multiple types uniformly | Easy — `shared_ptr<void>` can hold any type safely |

```cpp
#include <iostream>

namespace v1 {
template <typename T>
class shared_ptr {
    T* _p;

public:
    template <typename U>
    shared_ptr(U* p) : _p(p) {}
    ~shared_ptr() { delete _p; }
};
}; // namespace v1

namespace v2 {
class helper_base {
public:
    virtual ~helper_base() = default;
};

template <typename T>
class helper : public helper_base {
    T* _data;

public:
    helper(T* p) : _data(p) {}
    virtual ~helper() { delete _data; }
};

template <typename T>
class shared_ptr {
    helper_base* _helper;

public:
    template <typename U>
    shared_ptr(U* p) {
        _helper = new helper(p);
    }
    ~shared_ptr() { delete _helper; }
};
} // namespace v2

struct Foo {
    ~Foo() { std::cout << "~Foo()" << std::endl; }
};

int main() {
    {
        std::cout << "Test raw pointer" << std::endl;
        Foo* f1 = new Foo();
        void* f2 = new Foo();
        delete f1;
        delete f2;
    }
    {
        std::cout << "Test v1" << std::endl;
        v1::shared_ptr<Foo> f1(new Foo());
        v1::shared_ptr<void> f2(new Foo());
    }
    {
        std::cout << "Test v2" << std::endl;
        v2::shared_ptr<Foo> f1(new Foo());
        v2::shared_ptr<void> f2(new Foo());
    }
    return 0;
}
```

Output:

```
Test raw pointer
~Foo()
Test v1
~Foo()
Test v2
~Foo()
~Foo()
```

### 6.1.12 variant overloaded

```cpp
#include <iostream>
#include <string>
#include <variant>

struct IntPrinter {
    void operator()(int arg) { std::cout << "Int value: " << arg << std::endl; }
};

struct FloatPrinter {
    void operator()(float arg) { std::cout << "Float value: " << arg << std::endl; }
};

struct StringPrinter {
    void operator()(const std::string& arg) { std::cout << "String value: " << arg << std::endl; }
};

struct MultiPrinter : public IntPrinter, FloatPrinter, StringPrinter {
    using IntPrinter::operator();
    using FloatPrinter::operator();
    using StringPrinter::operator();
};

template <class... Ts>
struct overloaded : Ts... {
    // exposes operator() from every base
    using Ts::operator()...;
};

// C++17 deduction guide, not needed in C++20
template <class... Ts>
overloaded(Ts...) -> overloaded<Ts...>;

int main() {
    MultiPrinter printer;
    std::variant<int, float, std::string> v = "Hello, Variant!";
    std::visit(MultiPrinter{}, v);
    std::visit(overloaded{IntPrinter{}, FloatPrinter{}, StringPrinter{}}, v);

    v = 1;
    std::visit(MultiPrinter{}, v);
    std::visit(overloaded{IntPrinter{}, FloatPrinter{}, StringPrinter{}}, v);

    v = 3.14f;
    std::visit(MultiPrinter{}, v);
    std::visit(overloaded{IntPrinter{}, FloatPrinter{}, StringPrinter{}}, v);
    return 0;
}
```

## 6.2 Iterator 

### 6.2.1 Static Loop

Inspired by [base/base/constexpr_helpers.h](https://github.com/ClickHouse/ClickHouse/blob/master/base/base/constexpr_helpers.h)

```cpp
#include <iostream>
#include <type_traits>

template <typename Func, typename Arg>
bool func_wrapper(Func&& func, Arg&& arg) {
    if constexpr (std::is_void_v<std::invoke_result_t<Func, Arg>>) {
        func(arg);
        return false;
    } else
        return func(arg);
}

template <typename T, T Begin, T Inc, typename Func, T... Is>
constexpr bool static_for_impl(Func&& f, std::integer_sequence<T, Is...>) {
    return (func_wrapper(f, std::integral_constant<T, Begin + Is * Inc>{}) || ...);
}

template <auto Begin, decltype(Begin) End, auto Inc, typename Func>
constexpr bool static_for(Func&& f) {
    using T = decltype(Begin);
    constexpr T count = (End - Begin + Inc - 1) / Inc; // Number of steps based on increment
    return static_for_impl<T, Begin, Inc>(std::forward<Func>(f), std::make_integer_sequence<T, count>{});
}

int main() {
    std::cout << "Increment by 1: ";
    static_for<1, 10, 1>([](auto i) { std::cout << i << ", "; }); // Increment by 1
    std::cout << std::endl;

    std::cout << "Increment by 2: ";
    static_for<1, 10, 2>([](auto i) { std::cout << i << ", "; }); // Increment by 2
    std::cout << std::endl;

    return 0;
}
```

### 6.2.2 Iterate over std::integer_sequence

```cpp
#include <iostream>

template <typename T, T... Is>
void iterate_integer_sequence(std::integer_sequence<T, Is...> sequence) {
    ((std::cout << Is << " "), ...);
}

int main() {
    iterate_integer_sequence(std::make_integer_sequence<int, 100>());
    return 0;
}
```

### 6.2.3 Iterate over std::tuple

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>
#include <tuple>

template <typename Tuple, typename Func, size_t... N>
void func_call_tuple(const Tuple& t, Func&& func, std::index_sequence<N...>) {
    static_cast<void>(std::initializer_list<int>{(func(std::get<N>(t)), 0)...});
}

template <typename... Args, typename Func>
void travel_tuple(const std::tuple<Args...>& t, Func&& func) {
    func_call_tuple(t, std::forward<Func>(func), std::make_index_sequence<sizeof...(Args)>{});
}

int main() {
    auto t = std::make_tuple(1, 4.56, "hello");
    travel_tuple(t, [](auto&& item) { std::cout << item << ","; });
}
```

## 6.3 Type Deduction

**`using template`**: When extracting types with `Traits`, we often need to add `typename` to disambiguate. Therefore, `using` templates can further eliminate the need for redundant `typename`.
**`static member template`**: Static member templates.

```cpp
#include <stddef.h>
#include <stdint.h>

#include <iostream>
#include <string>

enum Type {
    INT = 0,
    LONG,  /* 1 */
    FLOAT, /* 2 */
    DOUBLE /* 3 */
};

template <Type type>
struct TypeTraits {};

template <>
struct TypeTraits<Type::INT> {
    using type = int32_t;
    static constexpr int32_t default_value = 1;
};

template <>
struct TypeTraits<Type::LONG> {
    using type = int64_t;
    static constexpr int64_t default_value = 2;
};

template <>
struct TypeTraits<Type::FLOAT> {
    using type = float;
    static constexpr float default_value = 2.2;
};

template <>
struct TypeTraits<Type::DOUBLE> {
    using type = double;
    static constexpr double default_value = 3.3;
};

template <Type type>
using CppType = typename TypeTraits<type>::type;

int main() {
    typename TypeTraits<Type::INT>::type value1 = TypeTraits<Type::INT>::default_value;
    CppType<Type::LONG> value2 = TypeTraits<Type::LONG>::default_value;
    CppType<Type::FLOAT> value3 = TypeTraits<Type::FLOAT>::default_value;
    CppType<Type::DOUBLE> value4 = TypeTraits<Type::DOUBLE>::default_value;
    std::cout << "value1=" << value1 << std::endl;
    std::cout << "value2=" << value2 << std::endl;
    std::cout << "value3=" << value3 << std::endl;
    std::cout << "value4=" << value4 << std::endl;
}
```

## 6.4 Static Proxy

It's unclear if this falls strictly within the scope of metaprogramming. For more examples, refer to [binary_function.h](https://github.com/liuyehcf/starrocks/blob/main/be/src/exprs/vectorized/binary_function.h).

```cpp
#include <iostream>

struct OP1 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP1(l, r)" << std::endl;
        return l + r;
    }
};

struct OP2 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP2(l, r)" << std::endl;
        return l - r;
    }
};

struct OP3 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP3(l, r)" << std::endl;
        return l * r;
    }
};

struct OP4 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "OP4(l, r)" << std::endl;
        return r == 0 ? 0 : l / r;
    }
};

template <typename OP>
struct Wrapper1 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper1 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper1 end" << std::endl;
        return res;
    }
};

template <typename OP>
struct Wrapper2 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper2 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper2 end" << std::endl;
        return res;
    }
};

template <typename OP>
struct Wrapper3 {
    static double apply(int32_t l, int32_t r) {
        std::cout << "Wrapper3 start" << std::endl;
        double res = OP::apply(l, r);
        std::cout << "Wrapper3 end" << std::endl;
        return res;
    }
};

int main() {
    Wrapper3<Wrapper2<Wrapper1<OP1>>>::apply(1, 2);
    std::cout << std::endl;
    Wrapper1<Wrapper2<Wrapper3<OP2>>>::apply(1, 2);
    return 0;
}
```

## 6.5 Compile-Time Branching

Sometimes, we want to write different branches of code for different types, but these branches may be incompatible across types. For example, if we want to implement addition, we can use the `+` operator for `int`, but for the `Foo` type, we need to call the `add` method. In this case, regular branching would fail, resulting in a compilation error during instantiation. We can use `if constexpr` to implement compile-time branching to handle this scenario.

```cpp
#include <type_traits>

struct Foo {
    int val;
};

Foo add_foo(const Foo& left, const Foo& right) {
    return Foo{left.val + right.val};
}

template <typename T>
T add(const T& left, const T& right) {
    if constexpr (std::is_same<T, int>::value) {
        return left + right;
    } else if constexpr (std::is_same<T, Foo>::value) {
        return add_foo(left, right);
    }
}

int main() {
    Foo left, right;
    add(left, right);
    add(1, 2);
    return 0;
}
```

**Type-specific code must be contained within `if constexpr/else if constexpr` blocks. Here is an example of incorrect usage: the intention is to return immediately if the type is not arithmetic, but since `left + right` is outside the static branching, an error will occur when instantiating with `Foo`.**

```cpp
#include <type_traits>

template <typename T>
T add(const T& left, const T& right) {
    if constexpr (!std::is_arithmetic<T>::value) {
        return {};
    }
    return left + right;
}

struct Foo {};

int main() {
    Foo left, right;
    add(left, right);
    return 0;
}
```

## 6.6 Implement std::bind

**The following example reveals the underlying principles of `std::bind`. Here's the meaning of each helper template:**

* `invoke`: Triggers method invocation.
* `seq/gen_seq/gen_seq_t`: Generates an integer sequence.
* `placeholder`: Placeholder.
* `placeholder_num`: Counts the number of placeholders in a given parameter list.
* `bind_return_type`: Extracts the return type of a function.
* `select`: Extracts arguments from `bindArgs` and `callArgs`. If it's a placeholder, it extracts from `callArgs`; otherwise, from `bindArgs`.
* `bind_t`: Encapsulates a class with an overloaded `operator()`.
* `bind`: The interface.

**Core Idea:**

* First, `bind` needs to return a type, referred to as `biner_type`, which overloads the `operator()` function.
* The `operator()` in `biner_type` has a parameter list that is a parameter pack, `Arg...`, enabling dynamic adaptation to different bound objects.
    * The length of this parameter pack matches the number of placeholders.
    * Use `static_assert` to constrain the parameter count to match the number of placeholders specified in `bind`.
* `std::tuple` is used to store the `bind` argument list and the parameter list of `operator()`. Using `std::tuple` allows easy access to the corresponding argument by index.

```cpp
#include <iostream>
#include <string>
#include <tuple>
#include <type_traits>

// invoke
template <typename F, typename... Args>
auto invoke(F&& func, Args&&... args) -> decltype(std::forward<F>(func)(std::forward<Args>(args)...)) {
    return std::forward<F>(func)(std::forward<Args>(args)...);
}

template <typename F, typename... Args>
struct invoke_return_type {
    using type = decltype(invoke(std::declval<F>(), std::declval<Args>()...));
};

// seq
template <size_t... N>
struct seq {};

// seq_gen
template <size_t N, size_t... S>
struct gen_seq;

template <size_t N, size_t... S>
struct gen_seq : gen_seq<N - 1, N - 1, S...> {};

template <size_t... S>
struct gen_seq<0, S...> {
    using type = seq<S...>;
};

template <size_t... S>
using gen_seq_t = typename gen_seq<S...>::type;

// placeholder
template <size_t Num>
struct placeholder {};

static constexpr placeholder<1> _1;
static constexpr placeholder<2> _2;
static constexpr placeholder<3> _3;
static constexpr placeholder<4> _4;
static constexpr placeholder<5> _5;
static constexpr placeholder<6> _6;

template <typename... BindArgs>
struct placeholder_num {
    static constexpr size_t value = 0;
};

template <typename NonPlaceHolderBindArg, typename... BindArgs>
struct placeholder_num<NonPlaceHolderBindArg, BindArgs...> {
    static constexpr size_t value = placeholder_num<BindArgs...>::value;
};

template <size_t Num, typename... BindArgs>
struct placeholder_num<placeholder<Num>, BindArgs...> {
    static constexpr size_t value = 1 + placeholder_num<BindArgs...>::value;
};

// select
template <typename BindArg, typename TCallArgs>
auto select(BindArg&& non_place_holder_bind_arg, TCallArgs&& t_call_args) -> BindArg&& {
    return std::forward<BindArg>(non_place_holder_bind_arg);
}

// select N-th element from Tuple
template <size_t N, typename TCallArgs>
auto select(placeholder<N> place_holder_bind_arg, TCallArgs&& t_call_args)
        -> std::conditional_t<std::is_rvalue_reference<std::tuple_element_t<N - 1, std::decay_t<TCallArgs>>>::value,
                              std::tuple_element_t<N - 1, std::decay_t<TCallArgs>>,
                              decltype(std::get<N - 1>(t_call_args))> {
    return static_cast<
            std::conditional_t<std::is_rvalue_reference<std::tuple_element_t<N - 1, std::decay_t<TCallArgs>>>::value,
                               std::tuple_element_t<N - 1, std::decay_t<TCallArgs>>,
                               decltype(std::get<N - 1>(std::forward<TCallArgs>(t_call_args)))>>(
            std::get<N - 1>(std::forward<TCallArgs>(t_call_args)));
}

// bind_return_type
template <typename F, typename TBindArgs, typename TCallArgs, typename Seq>
struct bind_return_type;

// represent Seq by form seq<S...>, so we can use S... to generate folding expression
template <typename F, typename TBindArgs, typename TCallArgs, size_t... S>
struct bind_return_type<F, TBindArgs, TCallArgs, seq<S...>> {
    using type = decltype(invoke(std::declval<F>(),
                                 select(std::get<S>(std::declval<TBindArgs>()), std::declval<TCallArgs>())...));
};

template <typename F, typename TBindArgs, typename TCallArgs,
          typename Seq = gen_seq_t<std::tuple_size<TBindArgs>::value>>
using bind_return_type_t = typename bind_return_type<F, TBindArgs, TCallArgs, Seq>::type;

// bind_t
template <typename F, typename... BindArgs>
class bind_t {
    using TBindArgs = std::tuple<std::decay_t<BindArgs>...>;
    using CallFun = std::decay_t<F>;

public:
    explicit bind_t(F func, BindArgs... bind_args) : _func(func), _t_bind_args(bind_args...) {}

    template <typename... CallArgs, typename TCallArgs = std::tuple<CallArgs&&...>>
    bind_return_type_t<CallFun, TBindArgs, TCallArgs> operator()(CallArgs&&... call_args) {
        static_assert(placeholder_num<BindArgs...>::value == sizeof...(CallArgs),
                      "number of placeholder must be equal with the number of operator()'s parameter");
        TCallArgs t_call_args(std::forward<CallArgs>(call_args)...);
        return _call(t_call_args, gen_seq_t<std::tuple_size<TBindArgs>::value>());
    }

private:
    template <typename TCallArgs, size_t... S>
    bind_return_type_t<CallFun, TBindArgs, std::decay_t<TCallArgs>> _call(TCallArgs&& t_call_args,
                                                                          seq<S...> /*unused*/) {
        return invoke(_func, select(std::get<S>(_t_bind_args), std::forward<TCallArgs>(t_call_args))...);
    }

    CallFun _func;
    TBindArgs _t_bind_args;
};

// bind
template <typename F, typename... BindArgs>
bind_t<std::decay_t<F>, std::decay_t<BindArgs>...> bind(F&& func, BindArgs&&... bind_args) {
    return bind_t<std::decay_t<F>, std::decay_t<BindArgs>...>(std::forward<F>(func),
                                                              std::forward<BindArgs>(bind_args)...);
}

void print(const std::string& s, int i, double d) {
    std::cout << "str=" << s << ", int=" << i << ", double=" << d << std::endl;
}

int main() {
    auto f1 = bind(print, _1, 1, 1.1);
    auto f2 = bind(print, "fixed_str_2", _1, 2.2);
    auto f3 = bind(print, "fixed_str_3", 3, _1);
    auto f5 = bind(print, _1, _2, _3);

    f1("str_1");
    f2(2);
    f3(3.3);
    f5("str_5", 5, 5.5);
    return 0;
}
```

Simplified version:

```cpp
#include <iostream>
#include <string>
#include <tuple>
#include <type_traits>

// placeholder
template <size_t Num>
struct placeholder {};

static constexpr placeholder<1> _1;
static constexpr placeholder<2> _2;
static constexpr placeholder<3> _3;
static constexpr placeholder<4> _4;
static constexpr placeholder<5> _5;
static constexpr placeholder<6> _6;

// Calculate how many placeholders.
template <typename... BindArgs>
struct placeholder_num {
    static constexpr size_t value = 0;
};
template <typename... BindArgs>
constexpr size_t placeholder_num_v = placeholder_num<BindArgs...>::value;
template <typename NonPlaceHolderBindArg, typename... BindArgs>
struct placeholder_num<NonPlaceHolderBindArg, BindArgs...> {
    static constexpr size_t value = placeholder_num_v<BindArgs...>;
};
template <size_t Num, typename... BindArgs>
struct placeholder_num<placeholder<Num>, BindArgs...> {
    static constexpr size_t value = 1 + placeholder_num_v<BindArgs...>;
};

// Select non-placeholder element.
template <typename BindArg, typename TCallArgs>
auto select(BindArg&& non_place_holder_bind_arg, TCallArgs&& t_call_args) {
    return std::forward<BindArg>(non_place_holder_bind_arg);
}
// Select placeholder element.
template <size_t N, typename TCallArgs>
auto select(placeholder<N> place_holder_bind_arg, TCallArgs&& t_call_args) {
    return std::get<N - 1>(std::forward<TCallArgs>(t_call_args));
}

// The implementation of bind, provide overloaded operator() to call the original function with placeholders and actual args.
template <typename CallFun, typename... BindArgs>
class bind_t {
    using TBindArgs = std::tuple<BindArgs...>;
    static constexpr size_t TBindArgsSize = std::tuple_size_v<TBindArgs>;

public:
    explicit bind_t(CallFun func, BindArgs... bind_args) : _func(func), _t_bind_args(bind_args...) {}

    template <typename... CallArgs, typename TCallArgs = std::tuple<CallArgs&&...>>
    auto operator()(CallArgs&&... call_args) {
        static_assert(placeholder_num_v<BindArgs...> == sizeof...(CallArgs),
                      "number of placeholder must be equal with the number of operator()'s parameter");
        // The reason we use TCallArgs is that the size of CallArgs is different from the size of TBindArgs
        // so they cannot be unfolded together at `_call`
        TCallArgs t_call_args(std::forward<CallArgs>(call_args)...);
        return _call(t_call_args, std::make_index_sequence<TBindArgsSize>());
    }

private:
    // represent Seq by form std::index_sequence<S...>, so we can use S... to generate folding expression
    template <typename TCallArgs, size_t... S>
    auto _call(TCallArgs&& t_call_args, std::index_sequence<S...> /*unused*/) {
        return _func(select(std::get<S>(_t_bind_args), std::forward<TCallArgs>(t_call_args))...);
    }

    // The original function
    CallFun _func;
    // Contains all args of original function, including non-placeholder values and placeholders
    TBindArgs _t_bind_args;
};

// Entrance
template <typename F, typename... BindArgs>
auto bind(F&& func, BindArgs&&... bind_args) {
    return bind_t(std::forward<F>(func), std::forward<BindArgs>(bind_args)...);
}

void print(const std::string& s, int i, double d) {
    std::cout << "str=" << s << ", int=" << i << ", double=" << d << std::endl;
}

int main() {
    auto f1 = bind(print, _1, 1, 1.1);
    auto f2 = bind(print, "fixed_str_2", _1, 2.2);
    auto f3 = bind(print, "fixed_str_3", 3, _1);
    auto f5 = bind(print, _1, _2, _3);

    f1("str_1");
    f2(2);
    f3(3.3);
    f5("str_5", 5, 5.5);
    return 0;
}
```

## 6.7 Quick Sort

**[quicksort in C++ template metaprogramming](https://gist.github.com/cleoold/c26d4e2b4ff56985c42f212a1c76deb9)**

```cpp
#include <iostream>

namespace quicksort {
template <int VALUE>
struct Value {
    static constexpr int value = VALUE;
};

/*==============================================================*/

template <int... VALUES>
struct Array {
    // Any derived type can be represented as an Array
    using array_type = Array;
};
using EmptyArray = Array<>;

/*==============================================================*/

template <typename TARGET_ARRAY>
struct FirstOf;
template <int FIRST_VALUE, int... VALUES>
struct FirstOf<Array<FIRST_VALUE, VALUES...>> : Value<FIRST_VALUE> {};

/*==============================================================*/

template <typename TARGET_ARRAY, int VALUE>
struct PrependTo;
template <int FIRST_VALUE, int... VALUES>
struct PrependTo<Array<VALUES...>, FIRST_VALUE> : Array<FIRST_VALUE, VALUES...> {};

/*==============================================================*/

template <typename TARGET_ARRAY, int VALUE>
struct AppendValueTo;
template <int LAST_VALUE, int... VALUES>
struct AppendValueTo<Array<VALUES...>, LAST_VALUE> : Array<VALUES..., LAST_VALUE> {};

/*==============================================================*/

template <typename TARGET_ARRAY, typename SOURCE_ARRAY>
struct AppendArrayTo;
template <typename TARGET_ARRAY, int FIRST_VALUE, int... VALUES>
struct AppendArrayTo<TARGET_ARRAY, Array<FIRST_VALUE, VALUES...>>
        : AppendArrayTo<typename AppendValueTo<TARGET_ARRAY, FIRST_VALUE>::array_type, Array<VALUES...>> {};
template <typename TARGET_ARRAY>
struct AppendArrayTo<TARGET_ARRAY, EmptyArray> : TARGET_ARRAY {};

/*==============================================================*/

template <typename TARGET_ARRAY, int TARGET_VALUE, bool CONDITION>
struct LessEqualFilterAdviser;
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct LessEqualFilterAdviser<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, true>
        : PrependTo<typename LessEqualFilterAdviser<Array<VALUES...>, TARGET_VALUE,
                                                    (FirstOf<Array<VALUES...>>::value <= TARGET_VALUE)>::array_type,
                    FIRST_VALUE> {};
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct LessEqualFilterAdviser<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, false>
        : LessEqualFilterAdviser<Array<VALUES...>, TARGET_VALUE, (FirstOf<Array<VALUES...>>::value <= TARGET_VALUE)> {};
template <int TARGET_VALUE, int FIRST_VALUE>
struct LessEqualFilterAdviser<Array<FIRST_VALUE>, TARGET_VALUE, true> : Array<FIRST_VALUE> {};
template <int TARGET_VALUE, int FIRST_VALUE>
struct LessEqualFilterAdviser<Array<FIRST_VALUE>, TARGET_VALUE, false> : EmptyArray {};

template <typename TARGET_ARRAY, int TARGET_VALUE>
struct LessEqualFilter
        : LessEqualFilterAdviser<TARGET_ARRAY, TARGET_VALUE, (FirstOf<TARGET_ARRAY>::value <= TARGET_VALUE)> {};
template <int TARGET_VALUE>
struct LessEqualFilter<EmptyArray, TARGET_VALUE> : EmptyArray {};

/*==============================================================*/

template <typename TARGET_ARRAY, int TARGET_VALUE, bool CONDITION>
struct GreaterThanAdvisor;
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct GreaterThanAdvisor<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, true>
        : PrependTo<typename GreaterThanAdvisor<Array<VALUES...>, TARGET_VALUE,
                                                (FirstOf<Array<VALUES...>>::value > TARGET_VALUE)>::array_type,
                    FIRST_VALUE> {};
template <int TARGET_VALUE, int FIRST_VALUE, int... VALUES>
struct GreaterThanAdvisor<Array<FIRST_VALUE, VALUES...>, TARGET_VALUE, false>
        : GreaterThanAdvisor<Array<VALUES...>, TARGET_VALUE, (FirstOf<Array<VALUES...>>::value > TARGET_VALUE)> {};
template <int TARGET_VALUE, int FIRST_VALUE>
struct GreaterThanAdvisor<Array<FIRST_VALUE>, TARGET_VALUE, true> : Array<FIRST_VALUE> {};
template <int TARGET_VALUE, int FIRST_VALUE>
struct GreaterThanAdvisor<Array<FIRST_VALUE>, TARGET_VALUE, false> : EmptyArray {};

template <typename TARGET_ARRAY, int TARGET_VALUE>
struct GreaterThan : GreaterThanAdvisor<TARGET_ARRAY, TARGET_VALUE, (FirstOf<TARGET_ARRAY>::value > TARGET_VALUE)> {};
template <int TARGET_VALUE>
struct GreaterThan<EmptyArray, TARGET_VALUE> : EmptyArray {};

/*==============================================================*/

template <typename TARGET_ARRAY>
struct QuickSort;
template <int FIRST_VALUE, int... VALUES>
struct QuickSort<Array<FIRST_VALUE, VALUES...>>
        : AppendArrayTo<
                  typename QuickSort<typename LessEqualFilter<Array<VALUES...>, FIRST_VALUE>::array_type>::array_type,
                  typename PrependTo<typename QuickSort<typename GreaterThan<Array<VALUES...>,
                                                                             FIRST_VALUE>::array_type>::array_type,
                                     FIRST_VALUE>::array_type> {};
template <>
struct QuickSort<EmptyArray> : EmptyArray {};

} // namespace quicksort

template <int FIRST_VALUE, int... VALUES>
static void print(quicksort::Array<FIRST_VALUE, VALUES...> /*unused*/) {
    std::cout << '(' << FIRST_VALUE;
    [[maybe_unused]] int _[] = {0, ((void)(std::cout << ", " << VALUES), 0)...};
    std::cout << ")\n";
}

static void print(quicksort::EmptyArray /*unused*/) {
    std::cout << "()\n";
}

template <int... VALUES>
static void test_quick_sort() {
    using original = quicksort::Array<VALUES...>;
    using sorted = quicksort::QuickSort<original>;
    std::cout << "before: ";
    print(original());
    std::cout << "after : ";
    print(sorted());
    std::cout << '\n';
}

int main() {
    test_quick_sort<>();
    test_quick_sort<1>();
    test_quick_sort<8, 1>();
    test_quick_sort<1, 2, 5, 8, -3, 2, 100, 4, 9, 3, -8, 33, 21, 3, -4, -4, -4, -7, 2, 5, 1, 8, 2, 88, 42, 956, 21, 27,
                    39, 55, 1, 4, -5, -31, 9>();
}
```

## 6.8 Conditional Members

Sometimes, we want certain specialized versions of a template class to include additional fields, while the default version does not contain these extra fields.

```cpp
#include <type_traits>

struct Empty {};

template <typename T>
struct Extra {
    T extra_value;
};

template <typename T>
struct Node : public std::conditional_t<std::is_integral<T>::value, Extra<T>, Empty> {
    T value;
};

int main() {
    Node<int> n1;
    n1.value = 1;
    n1.extra_value = 2;

    Node<double> n2;
    n2.value = 3.14;
    // n2.extra_value = 2.71;
    return 0;
}
```

## 6.9 Type Guard

[StarRocks-guard.h](https://github.com/StarRocks/starrocks/blob/main/be/src/util/guard.h)

```cpp
#include <cstdint>
#include <type_traits>

using Guard = int;

template <typename T, typename... Args>
constexpr bool type_in = (std::is_same_v<T, Args> || ...);

template <typename T, T v, T... args>
constexpr bool value_in = ((v == args) || ...);

template <typename T, typename... Args>
using TypeGuard = std::enable_if_t<((std::is_same_v<T, Args>) || ...), Guard>;

// TYPE_GUARD is used to define a type guard.
// for an example:
//
// TYPE_GUARD(DecimalArithmeticOp, is_decimal_arithmetic_op, AddOp, SubOp, MulOp, DivOp);
//
// This macro define a guard and a compile-time conditional expression.
//
// guard: DecimalArithmeticOp<T>,  it is Guard(i.e. int) if T is AddOp|SubOp|MulOp|DivOp,
//  it is nothing(i.e. cpp template specialization matching failure) otherwise.
// conditional expression: is_decimal_arithmetic_op<T> return true if T is AddOp|SubOp|MulOp|DivOp,
//  return false otherwise.

#define TYPE_GUARD(guard_name, pred_name, ...)                   \
    template <typename T>                                        \
    struct pred_name##_struct {                                  \
        static constexpr bool value = type_in<T, ##__VA_ARGS__>; \
    };                                                           \
    template <typename T>                                        \
    constexpr bool pred_name = pred_name##_struct<T>::value;     \
    template <typename T>                                        \
    using guard_name = TypeGuard<T, ##__VA_ARGS__>;

TYPE_GUARD(MyGuard, type_is_unsigned_int, uint8_t, uint16_t, uint32_t, uint64_t);

template <typename T>
void check(T& t) {
    static_assert(type_is_unsigned_int<T>, "type must be ordinal");
}

int main() {
    uint32_t u;
    check(u);
    // double d;
    // check(d);
}
```

## 6.10 enum name

There is an key observation inspired by [nameof](https://github.com/Neargye/nameof.git), the enum name information cannot be generated by template itself but can come from MACRO like `__PRETTY_FUNCTION__`.

Also, we cannot know the right boundary of a enum. So we can predefine a large enough valeu as the common boundary of all enum classes.

```cpp
#include <iostream>
#include <type_traits>

#define ENUM_MIN 0
#define ENUM_MAX 128

template <typename Func, typename Arg>
constexpr bool func_wrapper(Func&& func, Arg&& arg) {
    if constexpr (std::is_void_v<std::invoke_result_t<Func, Arg>>) {
        func(arg);
        return false;
    } else {
        static_assert(std::is_same_v<bool, std::invoke_result_t<Func, Arg>>);
        return func(arg);
    }
}

template <typename T, T Begin, typename Func, T... Is>
constexpr bool static_for_impl(Func&& f, std::integer_sequence<T, Is...> /*unused*/) {
    // Support short-circuiting
    return (func_wrapper(std::forward<Func>(f), std::integral_constant<T, Begin + Is>{}) || ...);
}

template <auto Begin, decltype(Begin) End, typename Func>
constexpr bool static_for(Func&& f) {
    using T = decltype(Begin);
    return static_for_impl<T, Begin>(std::forward<Func>(f), std::make_integer_sequence<T, End - Begin>{});
}

template <typename E, E v>
constexpr auto enum_name() {
    // __PRETTY_FUNCTION__ is something like: constexpr auto gen_pretry_name() [with E = Color; E v = RED]
    std::string_view name = std::string_view{__PRETTY_FUNCTION__, sizeof(__PRETTY_FUNCTION__) - 2};

    for (std::size_t i = name.size(); i > 0; --i) {
        if ((name[i - 1] < '0' || name[i - 1] > '9') && (name[i - 1] < 'a' || name[i - 1] > 'z') &&
            (name[i - 1] < 'A' || name[i - 1] > 'Z') && (name[i - 1] != '_')) {
            name.remove_prefix(i);
            break;
        }
    }

    if (name.size() > 0 &&
        ((name[0] >= 'a' && name[0] <= 'z') || (name[0] >= 'A' && name[0] <= 'Z') || (name[0] == '_'))) {
        return name;
    }

    // Invalid name.
    return std::string_view{};
}

template <typename E>
std::string_view enum_name_of(E v) {
    using U = std::underlying_type_t<E>;
    std::string_view res;
    static_for<static_cast<U>(ENUM_MIN), static_cast<U>(ENUM_MAX)>([&](auto i) {
        if (static_cast<U>(i) == static_cast<U>(v)) {
            // Key point: v is not an constexpr, so we need to rebuild v of the same value from an constexpr
            // And here, iterator variable 'i' is the constexpr we needed.
            //
            // Using static_cast may has error
            // https://reviews.llvm.org/D130058, https://reviews.llvm.org/D131307
            constexpr E c_v = __builtin_bit_cast(E, static_cast<U>(i));
            res = enum_name<E, c_v>();
            return true;
        }
        return false;
    });

    return res;
}

enum Color { RED, GREEN, BLUE };

#define print(x) std::cout << #x << " -> '" << x << "'" << std::endl;

int main() {
    Color color = Color::RED;
    print(enum_name_of(color));
    color = Color::GREEN;
    print(enum_name_of(color));
    color = Color::BLUE;
    print(enum_name_of(color));
    color = static_cast<Color>(100);
    print(enum_name_of(color));

    return 0;
}
```

# 7 Reference

* [ClickHouse](https://github.com/ClickHouse/ClickHouse/blob/master/base/base/constexpr_helpers.h)
* [C++雾中风景16:std::make_index_sequence, 来试一试新的黑魔法吧](https://www.cnblogs.com/happenlee/p/14219925.html)
* [CppCon 2014: Walter E. Brown "Modern Template Metaprogramming: A Compendium, Part I"](https://www.youtube.com/watch?v=Am2is2QCvxY)
* [CppCon 2014: Walter E. Brown "Modern Template Metaprogramming: A Compendium, Part II"](https://www.youtube.com/watch?v=a0FliKwcwXE)
    * Unevaluated operands(sizeof, typeid, decltype, noexcept), 12:30
* [fork_stl](https://github.com/cplusplus-study/fork_stl)
    * [bind.hpp](https://github.com/cplusplus-study/fork_stl/blob/master/include/bind.hpp)
