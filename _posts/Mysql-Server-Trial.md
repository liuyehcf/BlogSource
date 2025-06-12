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

**测试：**

```sql
CREATE DATABASE IF NOT EXISTS test;
CREATE TABLE test.user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO test.user (username, password, email) 
VALUES 
('alice', 'password123', 'alice@example.com'),
('bob', 'securepass456', 'bob@example.com'),
('charlie', 'mypassword789', 'charlie@example.com');

SELECT * FROM test.user;
```

# 2 Tips

1. `truncate`: `sql/my_decimal.h:my_decimal_round`
1. How to start via docker:
    ```sh
    # with persistent storage
    docker run -dit -p 3306:3306 -e MYSQL_ROOT_PASSWORD='Abcd1234' -v <local_path>:/var/lib/mysql mysql:5.7.37 mysqld --lower_case_table_names=1
    # without persistent storage
    docker run -dit -p 3306:3306 -e MYSQL_ROOT_PASSWORD='Abcd1234' mysql:5.7.37 mysqld --lower_case_table_names=1
    ```

# 3 Install from Archives

[MySQL Product Archives](https://downloads.mysql.com/archives/community/)

```sh
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-9.2.0-linux-glibc2.28-x86_64.tar.xz

tar xf mysql-9.2.0-linux-glibc2.28-x86_64.tar.xz -C /usr/local

# Unifiy path, otherwise if may fail on loading /usr/local/mysql/lib/plugin/mysql_native_password.so:
mv /usr/local/mysql-9.2.0-linux-glibc2.28-x86_64 /usr/local/mysql
```
