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

```sh
git clone https://github.com/gflags/gflags.git --depth 1
cd gflags
cmake -B build
cd build
make -j 6
sudo make install
```

**安装`protobuf`**

```sh
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
cmake -B build
cd build
make -j 6
sudo make install
```

**安装`leveldb`**

```sh
git clone https://github.com/google/leveldb.git
cd leveldb
git submodule update --init --recursive
cmake -B build
cd build
make -j 6
sudo make install
```

# 2 Build

```sh
git clone https://github.com/apache/incubator-brpc.git --depth 1
cd incubator-brpc
cmake -B build
cd build
make -j 6
```
