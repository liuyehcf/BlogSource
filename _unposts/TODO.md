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
    * 相关工具
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
        * [trino-subquery](https://docs.google.com/document/d/18HN7peS2eR8lZsErqcmnoWyMEPb6p4OQeidH1JP_EkA)
    * 测试集
        * tsbs
        * taxi
    * https://cloud.google.com/blog/products/databases/alloydb-for-postgresql-intelligent-scalable-storage
1. 体系结构
    * 内存屏障在汇编层面的表示
1. cpp
    * std::guard(be/src/runtime/decimalv3.h,be/src/util/guard.h)
    * std::bind 如何实现
    * struct alising
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
    * 胜者树、败者树
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
    * [Zipf Distribution](https://www.sciencedirect.com/topics/computer-science/zipf-distribution)
    * [Meaning of ‘i’,‘g’ and ‘c’ in Oracle Database Version](https://www.linkedin.com/pulse/meaning-ig-c-oracle-database-version-piyush-prakash)

