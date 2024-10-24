
1. Linux-常用命令
    * gprof
    * bottom, gtop, glances, gping, procs, hyperfine, xh, curlie, dog
1. 性能分析
    * perf
        * perf lock
    * vtune如何在虚拟机上进行user-mode sampling
    * valgrind (by andy pavlo)
        * [The Valgrind Quick Start Guide](http://valgrind.org/docs/manual/quick-start.html)
        * [Callgrind: a call-graph generating cache and branch prediction profiler](https://valgrind.org/docs/manual/cl-manual.html)
        * [kcachegrind](https://kcachegrind.github.io/html/Usage.html)
        * [Tips for the Profiling/Optimization process](https://kcachegrind.github.io/html/Tips.html)
    * DTrace (Dynamic Tracing)
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
        * tpc，基于每个列独立平均分布的前提来进行生成的。所以传统的基数估计方法可以达到一个比较好的效果
    * 统计信息
        * mcv, most common value, topn
        * ndv, number of distinct values
    * Join
        * RuntimeFilter
        * FactorJoin，基数估计
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
        * Aliyun E-MapReduce
        * [chroma](https://www.trychroma.com/)
        * [milvus](https://milvus.io/blog)
    * profiling
        * [clickhouse-flamegraph](https://github.com/Slach/clickhouse-flamegraph)
        * [profile_example.txt](https://gist.github.com/alexey-milovidov/92758583dd41c24c360fdb8d6a4da194)
        * [libunwind](https://github.com/libunwind/libunwind)
        * [Boost.Stacktrace](https://www.boost.org/doc/libs/1_76_0/doc/html/stacktrace.html)
        * [Google's Abseil(absl::debugging_internal::StackTrace)](https://github.com/abseil/abseil-cpp)
        * [Backtrace Library](https://github.com/ianlancetaylor/libbacktrace)
    * VC, Venture Capital
        * NASDAQ(National Association of Securities Deal Automated Quotations), 中概股
        * US，美国各种基金（近几年由于中美关系紧张，这部分渠道几乎断了）
        * EU
        * 中东
    * Teradata
        * 替换方案，目前只有华为在做
    * 数据底座
        * abroad: iceberg, hudi
    * retention analysis
    * funnel analysis
    * sql skew 优化技巧
    * shuffle optimization
        * [A fast alternative to the modulo reduction](https://lemire.me/blog/2016/06/27/a-fast-alternative-to-the-modulo-reduction/)
    * IO
        * IO聚合
    * Remote File Cache
        * Based on file:
            * read small data from a gig file will cause big latency
            * low space utility
            * simple
        * Based on block
            * cache only needed block of data
            * high space utility
            * complex
    * LSM
        * leveldb
    * Data Lake
        * DataBricks
            * [DataBricks Introduction to Data Lakes](https://www.databricks.com/discover/data-lakes)
            * [What is a data lakehouse?](https://docs.databricks.com/en/lakehouse/index.html)
        * SR [LakeHouse](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzI1MTYxOTkxNQ==&action=getalbum&album_id=2644153329677254658&scene=173&subscene=&sessionid=svr_67ba9ce1dc0&enterid=1727074152&from_msgid=2247493481&from_itemidx=1&count=3&nolastread=1#wechat_redirect)
            * [一场 Meetup，把数据湖讲透了！](https://mp.weixin.qq.com/s/A3I501LCkXI23D6KZ1rm_g)
            * [如何打造一款极速数据湖分析引擎](https://mp.weixin.qq.com/s/I-KJn2fZjb6mRAxYG_e8_w)
            * [技术内幕 | StarRocks 支持 Apache Hudi 原理解析](https://mp.weixin.qq.com/s/oROdpb4dHjGwTM8xLvKsWw)
            * [StarRocks 3.0 极速统一的湖仓新范式](https://mp.weixin.qq.com/s/N9zpkQHROG098uHlwTFZfA)
            * [优化数据查询性能：StarRocks 与 Apache Iceberg 的强强联合](https://mp.weixin.qq.com/s/wP9q7NACYEyY-TdrSceq4A)
            * [Data Lakehouse：你的下一个数据仓库](https://mp.weixin.qq.com/s/TiHoG5Nve8EQbT8gsn6J9A)
            * [StarRocks Lakehouse 快速入门——Apache Iceberg](https://mp.weixin.qq.com/s/pIXKXKNBLG5EPkAkiowBLQ)
            * [StarRocks Lakehouse 快速入门——Apache Paimon](https://mp.weixin.qq.com/s/IWyFkdceXOhuBUDABCSbuA)
        * AWS
            * Glue & Athena
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
1. k8s
    * kubectl -n byconity port-forward service/byconity-server 9000:9000
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
