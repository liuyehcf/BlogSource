---
title: TODO
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- TODO
---

**阅读更多**

<!--more-->

1. Linux-常用命令
    * numactl --hardware
1. 性能分析
    * bcc
    * perf
        * perf lock
        * [How to find expensive locks in multithreaded application.](https://easyperf.net/blog/2019/10/12/MT-Perf-Analysis-part2)
    * bpftrace
    * valgrind (by andy pavlo)
        * [The Valgrind Quick Start Guide](http://valgrind.org/docs/manual/quick-start.html)
        * [Callgrind: a call-graph generating cache and branch prediction profiler](https://valgrind.org/docs/manual/cl-manual.html)
        * [kcachegrind](https://kcachegrind.github.io/html/Usage.html)
        * [Tips for the Profiling/Optimization process](https://kcachegrind.github.io/html/Tips.html)
1. 数据库
    * 相关概念
        * 确定性事务
        * 2pc
    * 时序数据库
        * [LSM树详解](https://zhuanlan.zhihu.com/p/181498475)
    * starrocks
        * [apache-incubator-doris](https://github.com/apache/incubator-doris/wiki)
        * [query-schedule](https://15445.courses.cs.cmu.edu/fall2020/schedule.html)
        * [数据库内核杂谈](https://www.infoq.cn/theme/46)
        * [Develop your own Database](https://hpi.de/plattner/teaching/archive/winter-term-201819/develop-your-own-database.html)
        * [DorisDB doc](http://doc.dorisdb.com)
        * segment
            * SegmentsReadCount
    * 相关工具
        * [sqlancer](https://github.com/sqlancer/sqlancer)
        * [sqlsmith](https://github.com/anse1/sqlsmith)
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
        * [trino-subquery](https://docs.google.com/document/d/18HN7peS2eR8lZsErqcmnoWyMEPb6p4OQeidH1JP_EkA)
    * rewrite
        * 各种表达式的重写和化简
        * 列裁剪
        * 谓词下推
        * Limit Merge, Limit 下推
        * 聚合 Merge
        * 等价谓词推导（常量传播）
        * Outer Join 转 Inner Join
        * 常量折叠
        * 公共表达式复用
        * 子查询重写
        * Lateral Join 化简
        * 分区分桶裁剪
        * Empty Node 优化
        * Empty Union, Intersect, Except 裁剪
        * Intersect Reorder
        * Count Distinct 相关聚合函数重写
    * 统计
        * 伯努利采样
        * 皮尔逊系数
        * 泊松分布
        * Kernel Density Estimation
        * [Learning to Sample: Counting with Complex Queries](https://vldb.org/pvldb/vol13/p390-walenz.pdf) - ref 6
        * [SetSketch: Filling the Gap between MinHash and HyperLogLog](https://vldb.org/pvldb/vol14/p2244-ertl.pdf) - ref 2
        * [Learning to be a Statistician: Learned Estimator for Number of Distinct Values](https://vldb.org/pvldb/vol15/p272-wu.pdf) - ref 0
        * [NeuroCard: One Cardinality Estimator for All Tables](https://vldb.org/pvldb/vol14/p61-yang.pdf) - ref 42
        * [Flow-Loss: Learning Cardinality Estimates That Mater](https://vldb.org/pvldb/vol14/p2019-negi.pdf) - ref 8
        * [Fauce: Fast and Accurate Deep Ensembles with Uncertainty for Cardinality Estimation](https://vldb.org/pvldb/vol14/p1950-liu.pdf) - ref 2
        * [Weighted Distinct Sampling: Cardinality Estimation for SPJ Queries](https://www.cse.ust.hk/~yike/spj-full.pdf) - ref 0
        * [Count-distinct problem](https://en.wikipedia.org/wiki/Count-distinct_problem)
        * 影响Cardinality Estimation准确性的因素
            * 数据倾斜
            * 数据相关信息
            * 值域范围
    * 测试集
        * tsbs
        * taxi
    * postgre
        * 算数相关的函数：src/backend/utils/adt/numeric.c
    * clickhouse
        * [COW.h](https://github.com/ClickHouse/ClickHouse/blob/master/src/Common/COW.h)
    * https://cloud.google.com/blog/products/databases/alloydb-for-postgresql-intelligent-scalable-storage
    * window functions
        * aggregate
        * ranking
        * values
1. 体系结构
    * 内存屏障在汇编层面的表示
    * 《Residency-Aware Virtual Machine Communication Optimization: Design Choices and Techniques》
1. cpp
    * std::guard(be/src/runtime/decimalv3.h,be/src/util/guard.h)
    * std::bind 如何实现
    * struct alising
    * 如何消除虚函数的调用（down_cast）
    * [apache-arrow](https://github.com/apache/arrow)
1. java
1. llvm
    * [llvm-doc](https://llvm.org/docs/)
    * [2008-10-04-ACAT-LLVM-Intro.pdf](https://llvm.org/pubs/2008-10-04-ACAT-LLVM-Intro.pdf)
    * [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
1. 其他
    * [Is Raft more modular than MultiPaxos?](https://maheshba.bitbucket.io/blog/2021/12/14/Modularity.html)
    * 内存分配，伙伴算法
    * thrift
    * codegen
        * 复杂表达式计算，例如a+b+c，正常需要先计算a+b，其结果再加c。而利用codegen可以生成定制的处理过程，直接处理a+b+c，避免物化中间结果
        * 算子的内敛。例如scan + filter + aggregate，正常是三个算子，利用codegen可以把三个逻辑放一起，用一个大循环搞定，同样避免物化中间结果
        * 实现方式：生成中间代码，再利用LLVM编译成二进制
    * git worktree
    * 向量化
        * 无法向量化的场景
            * 复杂的表达式
            * 分支
            * data alignment
    * [lxcfs](https://github.com/lxc/lxcfs)
    * [什么是图灵完备？](https://www.zhihu.com/question/20115374/answer/288346717)
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)
    * [构建工具bazel](https://github.com/bazelbuild/bazel)
    * Quad Trees and R-Trees
    * futex