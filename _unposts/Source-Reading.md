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

## 3.1 Optimizer

### 3.1.1 Concepts

1. `Scope`：类似于命名空间namespace
1. `Relation`：关系实体
    * `ViewRelation`
    * `TableRelation`
    * `JoinRelation`
    * `CTERelation`
    * `SubqueryRelation`
    * `QueryRelation`
        * `SelectRelation`
1. `Expr`：表达式的基类
1. `ScalarOperator`：与`Expr`类似，由新`Analyzer`引入的一套对象系统
    * `ColumnRefOperator`
1. `ScalarOperatorEvaluator`：常量计算
1. `ScalarOperatorRewriter`：重写`ScalarOperator`
1. `Transformer`
    * `QueryTransformer`
    * `RelationTransformer`
    * `SubqueryTransformer`
    * `WindowTransformer`
    * `SqlToScalarOperatorTranslator`：将`Expr`转换成`ScalarOperator`
1. `Operator`
    * `LogicalOperator`：逻辑算子
    * `PhysicalOperator`：物理算子
1. `OptimizerTask`
    * `ApplyRuleTask`：执行Rule
    * `DeriveStatsTask`：基于逻辑`Plan`，自底向上计算统计信息
    * `EnforceAndCostTask`：基于物理`Plan`，计算`Cost`、裁剪`Cost`，以及根据`Property`插入`Enforence`节点
    * `ExploreGroupTask`
    * `OptimizeExpressionTask`：空间探索
    * `OptimizeGroupTask`：空间探索
    * `RewriteTreeTask`：执行Transformation Rule
1. `PropertyDeriver`
    * `RequiredPropertyDeriver`：当前节点对于孩子节点的所要求的属性，无需依赖孩子节点，可根据算子类型以及参数直接得到。可以有多组，比如join算子，不同的实现方式下（`broadcast/colocate/shuffle/bucket_shuffle`），对孩子节点的属性要求也是不一样的
    * `OutputPropertyDeriver`：计算当前节点的实际输出的属性，依赖孩子节点，因此整体计算是自底向上的
    * `ChildOutputPropertyGuarantor`：主要针对Join
1. `DistributionType`
    * `ANY`：任意
    * `BROADCAST`：广播
    * `SHUFFLE`：`Hash`分布
    * `GATHER`：例如无`Partition-By`的窗口函数
1. `HashDistributionDesc.SourceType`：Hash属性的来源
    * `LOCAL`：来自存储层`Bucket`键
    * `SHUFFLE_AGG`：来自`Gruop-By`
    * `SHUFFLE_JOIN`：来自`Shuffle Join`
    * `BUCKET`：来自`Bucket Shuffle Join`，其采用的哈希算法与`LOCAL`一致
    * `SHUFFLE_ENFORCE`：来自`Enforce`
    * 为什么要用2种不同的hash算法？因为需要获得更好的散列度
1. `JoinNode.DistributionMode`：描述数据的分布模式
    * `NONE`
    * `BROADCAST`
    * `PARTITIONED`
    * `LOCAL_HASH_BUCKET`：以存储层的`Hash`算法散列得到的数据分布
    * `SHUFFLE_HASH_BUCKET`：以Shuffle的`Hash`算法散列后得到的数据分布
    * `COLOCATE`：互为colocate的表，相同的`key`对应的数据一定在同一个机器上
    * `REPLICATED`

## 3.2 Merge Group

位置：`Memo::mergeGroup`

当两个`GroupExpression`等价时（判断其`identification`是否相同），这两个`GroupExpression`所在的Group需要进行合并。其中，`GroupExpression`的`identification`是指：

1. `Operator`
1. `Child Group`

具体流程（假设两个`Group`分别为`srcGroup`与`destGroup`）：

1. 遍历`Memo`中的所有`GroupExpression`，检查其所在的`Group`以及所有`Child Group`
    * 若`Group`为`srcGroup`，将其修改为`dstGroup`
    * 若`Child Group`为`srcGroup`，将其修改为`dstGroup`。这个修改会导致`GroupExpression`的`identification`发生改变，因此需要重新将其加入到`Memo`中
        * 若变更后的`GroupExpression`不在`Memo`中，那么插入即可
        * 若变更后的`GroupExpression`存在于`Memo`中，那么需要进行合并
            * 如果两者对应的`Group`等价，那么合并这两个`GroupExpression`即可
            * 如果两者对应的`Group`不等价，那么需要对`Group`进行进一步合并，这里记录到`needMergeGroup`中
1. 合并`srcGroup`以及`destGroup`
1. 合并`needMergeGroup`中记录的`Group`对
