---
title: Mysql-Server-Trial
date: 2022-02-25 13:29:26
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 编译安装

**前置依赖：**

* `gcc/g++`
* `boost`：[boost release](https://boostorg.jfrog.io/artifactory/main/release/)

**编译：**

```sh
git clone https://github.com/mysql/mysql-server.git --depth 1
cd mysql-server

mkdir build
cd build

cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DCMAKE_C_COMPILER=/usr/local/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/local/bin/g++ \
    -DWITH_BOOST=/usr/local/boost \
    ..

make
```

编译之后，`mysql-server/build/runtime_output_directory`目录下会生成二进制`mysqld`

**启动：**

```sh
cd mysql-server/build/runtime_output_directory

# 初始化，会在 mysql-server/build 目录下生成 data 子目录
./mysqld --initialize-insecure

# 启动
./mysqld
```

# 2 Tips

1. `truncate`函数：`sql/my_decimal.h`中的`my_decimal_round`函数
