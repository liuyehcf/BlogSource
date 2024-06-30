---
title: brpc-Trial
date: 2022-06-07 20:10:30
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 Prepare

**安装`gflag`**

* 需要额外指定编译参数`-fPIC`，否则`brpc`链接的时候会报错
* {% post_link Cpp-Thirdparty-Library %}

**安装`protobuf`**

* 需要额外指定编译参数`-fPIC`，否则`brpc`链接的时候会报错
* `brpc`对`protobuf`的版本有要求，这里我们选择`v3.14.0`版本

```sh
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git checkout v3.14.0
git submodule update --init --recursive
cmake -B build -S cmake -DCMAKE_C_FLAGS="${CMAKE_C_FLAGS} -fPIC" -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC" && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install build && sudo ldconfig
```

**安装`leveldb`**

* 需要额外指定编译参数`-fPIC`，否则`brpc`链接的时候会报错

```sh
git clone https://github.com/google/leveldb.git
cd leveldb
git submodule update --init --recursive
cmake -B build -DCMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -fPIC" && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install build && sudo ldconfig
```

# 2 Build

```sh
git clone https://github.com/apache/incubator-brpc.git
cd incubator-brpc
git checkout 1.9.0
cmake -B build && cmake --build build -j $(( (cores=$(nproc))>1?cores/2:1 ))
sudo cmake --install build && sudo ldconfig
```

# 3 FAQ

1. `brpc`会使用协程，在协程内使用`std::mutex`可能会产生死锁的问题，需要使用`bthread::Mutex`

# 4 TODO

1. `bvar`

# 5 参考

* [BRPC的精华全在bthread上啦（一）：Work Stealing以及任务的执行与切换](https://zhuanlan.zhihu.com/p/294129746)
* [BRPC的精华全在bthread上啦（二）：ParkingLot 与Worker同步任务状态](https://zhuanlan.zhihu.com/p/346081659)
* [BRPC的精华全在bthread上啦（三）：bthread上下文的创建](https://zhuanlan.zhihu.com/p/347499412)
* [BRPC的精华都在bthread上啦（四）：尾声](https://zhuanlan.zhihu.com/p/350582218)
* [contention_profiler.md](https://github.com/apache/incubator-brpc/blob/master/docs/cn/contention_profiler.md)
