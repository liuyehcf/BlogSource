---
title: Cpp-三方库
date: 2021-09-06 10:55:52
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 gtest

[github-googletest](https://github.com/google/googletest)

**安装googletest**

```sh
git clone https://github.com/google/googletest.git --depth 1
cd googletest
mkdir build
cd build
cmake ..
make
make install
```

**在`cmake`中添加`gtest`依赖**

```cmake
find_package(GTest REQUIRED)
message(STATUS "GTEST_INCLUDE_DIRS: ${GTEST_INCLUDE_DIRS}")
message(STATUS "GTEST_BOTH_LIBRARIES: ${GTEST_BOTH_LIBRARIES}")
message(STATUS "GTEST_LIBRARIES: ${GTEST_LIBRARIES}")
message(STATUS "GTEST_MAIN_LIBRARIES: ${GTEST_MAIN_LIBRARIES}")

target_link_libraries(xxx ${GTEST_LIBRARIES})
```

## 1.1 Tips

1. 假设编译得到的二进制是`test`，通过执行`./test --help`就可以看到所有gtest支持的参数，包括执行特定case等等

# 2 phmap

全称：`parallel-hashmap`，提供了一组高性能、并发安全的map，用于替换`std`以及`boost`中的map

# 3 benchmark

[google-benchmark](https://github.com/google/benchmark)

## 3.1 参考

* [c++性能测试工具：google benchmark入门（一）](https://www.cnblogs.com/apocelipes/p/10348925.html)
