---
title: Cpp-常用技巧
date: 2021-09-06 10:54:30
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 形参类型是否需要左右值引用

# 2 返回类型是否需要左右值引用

# 3 traits编译期萃取类型信息

## 3.1 示例1

```c++
#include<iostream>

template<typename T>
constexpr bool isVoid = false;

// 特化
template<>
inline constexpr bool isVoid<void> = true;

int main() {
    std::cout << std::boolalpha;
    std::cout << "isVoid<void>=" << isVoid<void> << std::endl;
    std::cout << "isVoid<int>=" << isVoid<int> << std::endl;
};
```

## 3.2 示例2

用`std::conditional_t`

## 3.3 标准库中的`traits`

1. `std::is_const_v`
1. `std::is_reference_v`
1. `std::is_lvalue_reference_v`
1. `std::is_rvalue_reference_v`
1. `std::is_pointer_v`
1. ...
