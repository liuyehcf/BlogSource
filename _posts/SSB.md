---
title: SSB
date: 2022-01-25 15:24:41
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

## 1.1 编译安装

```sh
git clone https://github.com/electrum/ssb-dbgen.git --depth 1
cd ssb-dbgen
make

# 执行 make 后会发现如下错误，即找不到 pid_t 的定义
#-------------------------↓↓↓↓↓↓-------------------------
driver.c:892:35: error: ‘pid_t’ undeclared (first use in this function)
  892 |   pids = malloc(children * sizeof(pid_t));
      |
#-------------------------↑↑↑↑↑↑-------------------------

# 由于 pid_t 定义在头文件 /usr/include/sys/types.h 中，因此修改 driver.c，在最开始的部分引入该头文件即可
# 即 #include "/usr/include/sys/types.h"

# 再次尝试编译，成功
make
```

修改后的`driver.c`文件部分内容如下：

```cpp
/* @(#)driver.c	2.1.8.4 */
/* main driver for dss banchmark */

#define DECLARER				/* EXTERN references get defined here */
#define NO_FUNC (int (*) ()) NULL	/* to clean up tdefs */
#define NO_LFUNC (long (*) ()) NULL		/* to clean up tdefs */

#include "config.h"
#include <stdlib.h>
#if (defined(_POSIX_)||!defined(WIN32))		/* Change for Windows NT */
#include "/usr/include/sys/types.h"
#ifndef DOS
#include <unistd.h>
#include <sys/wait.h>
#endif
```

## 1.2 生成数据

```sh
# 生成 cutomers 的数据
./dbgen -s 1 -T c

# 生成 lineorder 的数据
./dbgen -s 1 -T l

# 生成 parts 的数据
./dbgen -s 1 -T p

# 生成 suppliers 的数据
./dbgen -s 1 -T s

# 生成 date 的数据
./dbgen -s 1 -T d

# 去除末尾的 DELIMITER
sed -i 's/|$//' $(find *.tbl)
```

## 1.3 创建宽表

```sql
CREATE TABLE IF NOT EXISTS `lineorder_flat` (
    `LO_ORDERKEY` int(11) NOT NULL COMMENT '""',
    `LO_ORDERDATE` date NOT NULL COMMENT '""',
    `LO_LINENUMBER` tinyint(4) NOT NULL COMMENT '""',
    `LO_CUSTKEY` int(11) NOT NULL COMMENT '""',
    `LO_PARTKEY` int(11) NOT NULL COMMENT '""',
    `LO_SUPPKEY` int(11) NOT NULL COMMENT '""',
    `LO_ORDERPRIORITY` varchar(100) NOT NULL COMMENT '""',
    `LO_SHIPPRIORITY` tinyint(4) NOT NULL COMMENT '""',
    `LO_QUANTITY` tinyint(4) NOT NULL COMMENT '""',
    `LO_EXTENDEDPRICE` int(11) NOT NULL COMMENT '""',
    `LO_ORDTOTALPRICE` int(11) NOT NULL COMMENT '""',
    `LO_DISCOUNT` tinyint(4) NOT NULL COMMENT '""',
    `LO_REVENUE` int(11) NOT NULL COMMENT '""',
    `LO_SUPPLYCOST` int(11) NOT NULL COMMENT '""',
    `LO_TAX` tinyint(4) NOT NULL COMMENT '""',
    `LO_COMMITDATE` date NOT NULL COMMENT '""',
    `LO_SHIPMODE` varchar(100) NOT NULL COMMENT '""',
    `C_NAME` varchar(100) NOT NULL COMMENT '""',
    `C_ADDRESS` varchar(100) NOT NULL COMMENT '""',
    `C_CITY` varchar(100) NOT NULL COMMENT '""',
    `C_NATION` varchar(100) NOT NULL COMMENT '""',
    `C_REGION` varchar(100) NOT NULL COMMENT '""',
    `C_PHONE` varchar(100) NOT NULL COMMENT '""',
    `C_MKTSEGMENT` varchar(100) NOT NULL COMMENT '""',
    `S_NAME` varchar(100) NOT NULL COMMENT '""',
    `S_ADDRESS` varchar(100) NOT NULL COMMENT '""',
    `S_CITY` varchar(100) NOT NULL COMMENT '""',
    `S_NATION` varchar(100) NOT NULL COMMENT '""',
    `S_REGION` varchar(100) NOT NULL COMMENT '""',
    `S_PHONE` varchar(100) NOT NULL COMMENT '""',
    `P_NAME` varchar(100) NOT NULL COMMENT '""',
    `P_MFGR` varchar(100) NOT NULL COMMENT '""',
    `P_CATEGORY` varchar(100) NOT NULL COMMENT '""',
    `P_BRAND` varchar(100) NOT NULL COMMENT '""',
    `P_COLOR` varchar(100) NOT NULL COMMENT '""',
    `P_TYPE` varchar(100) NOT NULL COMMENT '""',
    `P_SIZE` tinyint(4) NOT NULL COMMENT '""',
    `P_CONTAINER` varchar(100) NOT NULL COMMENT '""'
)
```

```sql
INSERT INTO lineorder_flat
SELECT `LO_ORDERKEY`, `LO_ORDERDATE`, `LO_LINENUMBER`, `LO_CUSTKEY`, `LO_PARTKEY`
    , `LO_SUPPKEY`, `LO_ORDERPRIORITY`, `LO_SHIPPRIORITY`, `LO_QUANTITY`, `LO_EXTENDEDPRICE`
    , `LO_ORDTOTALPRICE`, `LO_DISCOUNT`, `LO_REVENUE`, `LO_SUPPLYCOST`, `LO_TAX`
    , `LO_COMMITDATE`, `LO_SHIPMODE`, `C_NAME`, `C_ADDRESS`, `C_CITY`
    , `C_NATION`, `C_REGION`, `C_PHONE`, `C_MKTSEGMENT`, `S_NAME`
    , `S_ADDRESS`, `S_CITY`, `S_NATION`, `S_REGION`, `S_PHONE`
    , `P_NAME`, `P_MFGR`, `P_CATEGORY`, `P_BRAND`, `P_COLOR`
    , `P_TYPE`, `P_SIZE`, `P_CONTAINER`
FROM lineorder l
    INNER JOIN customer c ON c.C_CUSTKEY = l.LO_CUSTKEY
    INNER JOIN supplier s ON s.S_SUPPKEY = l.LO_SUPPKEY
    INNER JOIN part p ON p.P_PARTKEY = l.LO_PARTKEY
WHERE year(LO_ORDERDATE) IN (1992, 1993, 1994, 1995, 1996, 1997, 1998);
```

# 2 参考

* [Star Schema Benchmark](https://www.cs.umb.edu/~poneil/StarSchemaB.PDF)
* [ClickHouse-Star Schema Benchmark](https://clickhouse.com/docs/en/getting-started/example-datasets/star-schema/)
* [Starrocks-性能测试](https://docs.starrocks.com/zh-cn/main/benchmarking/SSB_Benchmarking)