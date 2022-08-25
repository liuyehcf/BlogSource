---
title: Source-Reading
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Source Reading
---

**阅读更多**

<!--more-->

# 1 postgre

* 算数相关的函数：src/backend/utils/adt/numeric.c

# 2 clickhouse

* [COW.h](https://github.com/ClickHouse/ClickHouse/blob/master/src/Common/COW.h)

# 3 StarRocks

## 3.1 优化器

1. `Scope`：类似于命名空间namespace
1. `Relation`
    * `ViewRelation`
    * `TableRelation`
    * `JoinRelation`
    * `CTERelation`
    * `SubqueryRelation`
    * `QueryRelation`
        * `SelectRelation`
1. `Expr`
1. `ScalarOperator`
    * `ColumnRefOperator`
1. `Operator`
1. `Transformer`
    * `QueryTransformer`
    * `RelationTransformer`
    * `SubqueryTransformer`
1. `SqlToScalarOperatorTranslator`：将`Expr`转换成`ScalarOperator`
1. `OptimizerTask`
    * `OptimizeExpressionTask`
    * `EnforceAndCostTask`：基于物理`Plan`，计算`Cost`、裁剪`Cost`，以及根据`Property`插入`Enforence`节点
    * `OptimizeGroupTask`：空间探索
    * `DeriveStatsTask`：基于逻辑`Plan`，自底向上计算统计信息
    * `ApplyRuleTask`：执行Rule
1. `DistributionType`
    * `ANY`
    * `BROADCAST`
    * `SHUFFLE`：`Hash`
    * `GATHER`：例如无`Partition-By`的窗口函数
1. `HashDistributionDesc.SourceType`
    * `LOCAL`，来自`Scan`节点的`Hash`属性
    * `SHUFFLE_AGG`，来自`Gruop-By`的`Hash`属性
    * `SHUFFLE_JOIN`，来自`Join Predicate`的`Hash`属性
    * `BUCKET`，来自`Non-Scan`节点的`Hash`属性，采用了与存储层相同的`Hash`算法
    * `SHUFFLE_ENFORCE`，由于前后算子`Hash`属性不匹配，而插入的`Hash`属性
    * 为什么要用2种不同的hash算法？因为需要获得更好的散列度
1. `JoinNode.DistributionMode`
    * `NONE`
    * `BROADCAST`
    * `PARTITIONED`
    * `LOCAL_HASH_BUCKET`：以存储层的`Hash`算法得到的分布来进行散列
    * `SHUFFLE_HASH_BUCKET`
    * `COLOCATE`
    * `REPLICATED`