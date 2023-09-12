
1. Linux-常用命令
    * gprof
1. 性能分析
    * perf
        * perf lock
    * vtune如何在虚拟机上进行user-mode sampling
    * valgrind (by andy pavlo)
        * [The Valgrind Quick Start Guide](http://valgrind.org/docs/manual/quick-start.html)
        * [Callgrind: a call-graph generating cache and branch prediction profiler](https://valgrind.org/docs/manual/cl-manual.html)
        * [kcachegrind](https://kcachegrind.github.io/html/Usage.html)
        * [Tips for the Profiling/Optimization process](https://kcachegrind.github.io/html/Tips.html)
1. 数据库
    * 模型
        * 星星模型
        * 雪花模型
    * 相关概念
        * 确定性事务
        * 2pc
    * snowflake
        * [ALTER SESSION](https://docs.snowflake.com/en/sql-reference/sql/alter-session.html)
            * `ALTER ACCOUNT SET USE_CACHED_RESULT = FALSE`
            * `ALTER SESSION SET USE_CACHED_RESULT = FALSE`
        * [Overview of Warehouses](https://docs.snowflake.com/en/user-guide/warehouses-overview.html#warehouse-size)
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
        * [trino-subquery](https://docs.google.com/document/d/18HN7peS2eR8lZsErqcmnoWyMEPb6p4OQeidH1JP_EkA)
    * 测试集
        * tsbs
        * taxi
    * 统计信息
        * mcv, most common value, topn
    * Join
        * RuntimeFilter
    * Type
        * bitmap
        * hll
    * 其他
        * [Spark性能优化指南——高级篇](https://tech.meituan.com/2016/05/12/spark-tuning-pro.html)
    * 稳定性问题：
        * Bug
        * Crash
        * Performance
    * product
        * Snowflake、BigQuery、SingleStore、Firebolt、Pinot、Trino、Rockset
        * [chroma](https://www.trychroma.com/)
        * [milvus](https://milvus.io/blog)
    * profiling
        * [clickhouse-flamegraph](https://github.com/Slach/clickhouse-flamegraph)
        * [profile_example.txt](https://gist.github.com/alexey-milovidov/92758583dd41c24c360fdb8d6a4da194)
        * [libunwind](https://github.com/libunwind/libunwind)
        * [Boost.Stacktrace](https://www.boost.org/doc/libs/1_76_0/doc/html/stacktrace.html)
        * [Google's Abseil(absl::debugging_internal::StackTrace)](https://github.com/abseil/abseil-cpp)
        * [Backtrace Library](https://github.com/ianlancetaylor/libbacktrace)
1. 体系结构
    * numa
1. nodejs
    * `npm install -g n`
    * `n 16`
1. cpp
    * futex
    * 如何用老的glibc跑二进制
    * fault injection: https://github.com/StarRocks/starrocks/pull/23378/files
1. java
    * commons-cli
1. python
    * python -m pdb test.py
1. llvm
    * [llvm-doc](https://llvm.org/docs/)
    * [2008-10-04-ACAT-LLVM-Intro.pdf](https://llvm.org/pubs/2008-10-04-ACAT-LLVM-Intro.pdf)
    * [My First Language Frontend with LLVM Tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html)
1. 其他
    * [Is Raft more modular than MultiPaxos?](https://maheshba.bitbucket.io/blog/2021/12/14/Modularity.html)
    * 内存分配，伙伴算法
    * thrift
    * 胜者树、败者树
    * [lxcfs](https://github.com/lxc/lxcfs)
    * [什么是图灵完备？](https://www.zhihu.com/question/20115374/answer/288346717)
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)
    * [构建工具bazel](https://github.com/bazelbuild/bazel)
    * Quad Trees and R-Trees
    * [Zipf Distribution](https://www.sciencedirect.com/topics/computer-science/zipf-distribution)
    * [Speed up random memory access using prefetch](https://stackoverflow.com/questions/40950254/speed-up-random-memory-access-using-prefetch)
    * https://github.com/scylladb/seastar
    * 加盐
    * duckdb parallel merge sort
        * https://github.com/duckdb/duckdb/pull/1666
    * cgroup_v2
