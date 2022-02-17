1. Linux-常用命令
1. 性能分析
1. 数据库
    * product
        * postgreSQL
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
    * 相关工具
        * [sqlancer](https://github.com/sqlancer/sqlancer)
        * [sqlsmith](https://github.com/anse1/sqlsmith)
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
    * ssb测试集
        * https://www.cnblogs.com/tgzhu/p/9083092.html
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
    * 优化器相关论文
        * The Cascades Framework for Query Optimization
        * Orca-A-Modular-Query-Optimizer-Architecture-For-Big-Data
        * Efficiency-In-The-Columbia-Database-Query-Optimizer
        * How-Good-Are-Query-Optimizers
1. license
    * [主流开源协议之间有何异同？](https://www.zhihu.com/question/19568896)
    * apache license
    * elastic license
    * bsd
    * mit
    * gpl
1. cpp
    * 虚函数如何实现
    * `constexpr`
    * `static_assert`
1. 其他
    * `github.com.cnpmjs.org`不可用
    * [Is Raft more modular than MultiPaxos?](https://maheshba.bitbucket.io/blog/2021/12/14/Modularity.html)
    * 内存分配，伙伴算法
    * rpc框架，thrift
    * codegen原理
    * [什么是图灵完备？](https://www.zhihu.com/question/20115374/answer/288346717)
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)
    * [构建工具bazel](https://github.com/bazelbuild/bazel)