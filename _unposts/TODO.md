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
1. 性能分析
    * bcc
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
        * [Are We Ready For Learned Cardinality Estimation?](https://vldb.org/pvldb/vol14/p1640-wang.pdf) - ref 20
        * [Flow-Loss: Learning Cardinality Estimates That Mater](https://vldb.org/pvldb/vol14/p2019-negi.pdf) - ref 8
        * [Fauce: Fast and Accurate Deep Ensembles with Uncertainty for Cardinality Estimation](https://vldb.org/pvldb/vol14/p1950-liu.pdf) - ref 2
        * [Weighted Distinct Sampling: Cardinality Estimation for SPJ Queries](https://www.cse.ust.hk/~yike/spj-full.pdf) - ref 0
        * [Count-distinct problem](https://en.wikipedia.org/wiki/Count-distinct_problem)
        * 影响Cardinality Estimation准确性的因素
            * 数据倾斜
            * 数据相关信息
            * 值域范围
    * serverless论文
        * Cloud-Programming-Simplified-A-Berkeley-View-on-Serverless-Computing
    * 执行器
        * pull vs. push
            * pull：对limit友好，对filter不友好
            * push：对filter友好，对limit不友好
    * postgre
        * 算数相关的函数：src/backend/utils/adt/numeric.c
    * clickhouse
        * [COW.h](https://github.com/ClickHouse/ClickHouse/blob/master/src/Common/COW.h)
1. license
    * [主流开源协议之间有何异同？](https://www.zhihu.com/question/19568896)
    * apache license
    * elastic license
    * bsd
    * mit
    * gpl
1. cpp
    * std::guard(be/src/runtime/decimalv3.h)
    * std::bind 如何实现
    * std::remove_if
    * std::any 如何实现
    * futex
    * [apache-arrow](https://github.com/apache/arrow)
1. java
    * containsKey结果不对。若Key改变过值，导致hashCode变化之后，就会出现这个问题
1. llvm
    * [llvm-doc](https://llvm.org/docs/)
    * [2008-10-04-ACAT-LLVM-Intro.pdf](https://llvm.org/pubs/2008-10-04-ACAT-LLVM-Intro.pdf)
    * [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
1. 其他
    * [Is Raft more modular than MultiPaxos?](https://maheshba.bitbucket.io/blog/2021/12/14/Modularity.html)
    * 内存分配，伙伴算法
    * brpc框架
        * [BRPC的精华全在bthread上啦（一）：Work Stealing以及任务的执行与切换](https://zhuanlan.zhihu.com/p/294129746)
        * [BRPC的精华全在bthread上啦（二）：ParkingLot 与Worker同步任务状态](https://zhuanlan.zhihu.com/p/346081659)
        * [BRPC的精华全在bthread上啦（三）：bthread上下文的创建](https://zhuanlan.zhihu.com/p/347499412)
        * [BRPC的精华都在bthread上啦（四）：尾声](https://zhuanlan.zhihu.com/p/350582218)
    * thrift
    * 性能对比可以关注的指标
        * cycles
        * ipc
        * instructions
        * L1 Miss
        * LLC Miss
        * Branch Miss
    * codegen原理
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
1. Abbrevation
    * `SMT, Simultaneous multithreading`