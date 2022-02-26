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
            * multi-expressions: A Multi-expression consists of a logical or physical operator and takes groups as inputs
            * group：A Group is a set of logically equivalent expressions
            * pattern/substitute/transformation rule/implementation rule
            * catalogs(cardinality, number of pages, indexes)
            * Starburst
                * QGM, Query Graph Model, namely, re-write
                * plan optimizer, determine join orders
            * Exodus Optimizer
            * Volcano Optimizer
            * Cascades Optimizer Framework
                * task, tasks are collected by stack
                * memo(inherited from Volcano), search space
            * Cascades derives on demand while Volcano always derives
            * Columbia Optimizer(Based on the Cascades framework)
                * item operator vs. bulk operators
                * catalog, cost model, text file + parser vs. hard code
                * search engine
                    * rule set
                    * search space
                    * tasks
                * group lower bound: minimal cost of copying out tuples of the group and fetching tuples from the tables of the group (see details in section 4.1.2.3).
                * Calculation of the lower bound? P52
                * Bindery, bind logical operators only
                    * Expression binderies
                    * Group binderies
                * Enforcer Rule: inserts physical operators
                * Enforcer: The physical operator inserted by an enforcer rule is called an enforcer
                * physical property?
                * Task
                    * O_GROUP, group optimization
                    * E_GROUP, group exploration
                    * O_EXPR, expression optimization
                    * O_INPUTS, input optimization, altorhtim complicated P81
                    * APPLY_RULE, rule application
                * prune 
                    * Lower Bound Group Pruning
                    * Global Epsilon Pruning
        * How-Good-Are-Query-Optimizers
    * serverless论文
        * Cloud-Programming-Simplified-A-Berkeley-View-on-Serverless-Computing
    * 执行器
        * pull vs. push
            * pull：对limit友好，对filter不友好
            * push：对filter友好，对limit不友好
1. license
    * [主流开源协议之间有何异同？](https://www.zhihu.com/question/19568896)
    * apache license
    * elastic license
    * bsd
    * mit
    * gpl
1. cpp
    * gtest
        * PARALLEL_TEST
    * std::guard(be/src/runtime/decimalv3.h)
    * std::enable_if_t(be/src/util/decimal_types.h)，用来设置类型边界
1. 其他
    * `github.com.cnpmjs.org`不可用
    * [Is Raft more modular than MultiPaxos?](https://maheshba.bitbucket.io/blog/2021/12/14/Modularity.html)
    * 内存分配，伙伴算法
    * rpc框架，thrift
    * codegen原理
    * [lxcfs](https://github.com/lxc/lxcfs)
    * [什么是图灵完备？](https://www.zhihu.com/question/20115374/answer/288346717)
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)
    * [构建工具bazel](https://github.com/bazelbuild/bazel)
    * 设计需要考虑的因素
        * 工程实现难度
        * 易用性
        * 隔离性
        * 性能