---
title: TPC-DS
date: 2021-11-19 14:11:11
mathjax: true
tags: 
- 原创
categories: 
- Database
- Benchmark
---

**阅读更多**

<!--more-->

# 1 实践

在[TPC Download Current Specs/Source](http://tpc.org/tpc_documents_current_versions/current_specifications5.asp)中下载`TCP-DS`相关的程序

## 1.1 编译安装

将上述源码包解压缩，然后编译安装即可（最新版本的gcc貌似有问题，我用的是`gcc 7.x`）

```sh
cd tools

# 安装源
yum install -y centos-release-scl scl-utils

# 安装gcc 7
yum install -y devtoolset-7-toolchain

# 切换软件环境（本小节剩余的操作都需要在这个环境中执行，如果不小心退出来的话，可以再执行一遍重新进入该环境）
scl enable devtoolset-7 bash

make
```

**重要文件以及目录：**

建表语句：`tools/tpcds.sql`

## 1.2 生成数据

```sh
cd tools

mkdir data

# DIR 指定输出目录
# SCALE 指定规模因子
# DELIMITER 指定分隔符，默认是 |
# TERMINATE 是否在每条记录后都增加一个分隔符
./dsdgen -DIR data/ -SCALE 1 -TERMINATE N
```

**将生成后的文件转换成utf-8格式**

```sh
# data 目录是 dsdgen 命令指定的输出目录
cd tools/data

files=( $(find . -name "*.dat") )
for file in ${files[@]}
do
    iconv -f latin1 -t utf-8 --verbose ${file} > ${file}.utf8
done
```

## 1.3 生成sql

```sh
cd tools

# 在每个query模板的最后添加 「define _END = "";」 否则会报错
files=( $(find ../query_templates -name "query*.tpl") )
for file in ${files[@]}
do
    sed -i '/define _END/d' ${file}
    echo "define _END = \"\";" >> ${file}
done

mkdir query

# 生成查询 sql
./dsqgen -OUTPUT_DIR query -INPUT ../query_templates/templates.lst -DIRECTORY ../query_templates -DIALECT oracle -SCALE 1
```
