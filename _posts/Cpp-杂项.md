---
title: Cpp-杂项
date: 2021-08-19 09:38:42
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 格式化

`.clang-format`

**如何安装`clang-format`**

```sh
npm install -g clang-format
```

# 2 头文件搜索路径

**头文件`#include "xxx.h"`的搜索顺序**

1. 先搜索当前目录
1. 然后搜索`-I`参数指定的目录
1. 再搜索gcc的环境变量`CPLUS_INCLUDE_PATH`（C程序使用的是`C_INCLUDE_PATH`）
1. 最后搜索gcc的内定目录，包括：
    * `/usr/include`
    * `/usr/local/include`
    * `/usr/lib/gcc/x86_64-redhat-linux/<gcc version>/include`（C头文件）或者`/usr/include/c++/<gcc version>`（C++头文件）

**头文件`#include <xxx.h>`的搜索顺序**

1. 先搜索`-I`参数指定的目录
1. 再搜索gcc的环境变量`CPLUS_INCLUDE_PATH`（C程序使用的是`C_INCLUDE_PATH`）
1. 最后搜索gcc的内定目录，包括：
    * `/usr/include`
    * `/usr/local/include`
    * `/usr/lib/gcc/x86_64-redhat-linux/<gcc version>/include`（C头文件）或者`/usr/include/c++/<gcc version>`（C++头文件）

## 2.1 参考

* [C/C++ 头文件以及库的搜索路径](https://blog.csdn.net/crylearner/article/details/17013187)
