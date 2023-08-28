
# 1 postgre

* 算数相关的函数：src/backend/utils/adt/numeric.c

# 2 clickhouse

* [COW.h](https://github.com/ClickHouse/ClickHouse/blob/master/src/Common/COW.h)

# 3 StarRocks

## 3.1 Optimizer

### 3.1.1 Uncategory

1. `Scope`：类似于命名空间namespace
1. `Relation`：关系实体，数据集
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
        * `standardize`：标准化，window子句
    * `SqlToScalarOperatorTranslator`：将`Expr`转换成`ScalarOperator`
1. `Operator`
    * `LogicalOperator`：逻辑算子
    * `PhysicalOperator`：物理算子
1. `PropertyDeriver`：被`EnforceAndCostTask`调用
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
1. `AggType`：名字起的很奇怪，目的是为了达到Local和Global交替的效果
    * `LOCAL`
    * `GLOBAL`
    * `DISTINCT_GLOBAL`
    * `DISTINCT_LOCAL`
1. `JoinNode.DistributionMode`：描述数据的分布模式
    * `NONE`
    * `BROADCAST`
    * `PARTITIONED`
    * `LOCAL_HASH_BUCKET`：以存储层的`Hash`算法散列得到的数据分布
    * `SHUFFLE_HASH_BUCKET`：以Shuffle的`Hash`算法散列后得到的数据分布
    * `COLOCATE`：互为colocate的表，相同的`key`对应的数据一定在同一个机器上
    * `REPLICATED`

### 3.1.2 OptimizerTask

与论文[Efficiency-In-The-Columbia-Database-Query-Optimizer](/resources/paper/Efficiency-In-The-Columbia-Database-Query-Optimizer.pdf)中`P63-Figure 17`的概念一一对应

* **`OptimizeGroupTask(O_GROUP)`**：入口
    * 驱动`OptimizeExpressionTask`
    * 驱动`EnforceAndCostTask`
* **`OptimizeExpressionTask(O_EXPR)`**
    * 收集所有的`Rule`，驱动`ApplyRuleTask`执行
    * 驱动`DeriveStatsTask`
    * 驱动`ExploreGroupTask`
* **`EnforceAndCostTask(O_INPUTS)`**：基于物理`Plan`
    * 计算`Cost`、裁剪`Cost`
    * 根据`Property`插入`Enforence`节点
    * 驱动孩子节点进行`OptimizeGroupTask`
    * 可重入
* **`ExploreGroupTask(E_GROUP)`**：空间探索
    * 驱动`OptimizeExpressionTask`
* **`ApplyRuleTask(APPLY_RULE)`**：执行`Rule`，若`Rule`产生了新的`Expression`：
    * 若生成了`PhysicalOperator`，则驱动`OptimizeExpressionTask`
    * 若生成了`PhysicalOperator`，则驱动`EnforceAndCostTask`
* `RewriteTreeTask`：执行Transformation Rule
* `DeriveStatsTask`：基于逻辑`Plan`，自底向上计算统计信息

```
        Optimize()
            │
            │
            ▼
  ┌───────────────────┐                  ┌────────────────────┐
  │ OptimizeGroupTask │ ◄──────────────► │ EnforceAndCostTask │
  └───────────────────┘                  └────────────────────┘
            │                                      ▲
            │                                      │
            ▼                                      │
┌────────────────────────┐                 ┌───────────────┐
│ OptimizeExpressionTask │ ◄─────────────► │ ApplyRuleTask │
└────────────────────────┘                 └───────────────┘
            ▲
            │
            ▼
  ┌──────────────────┐
  │ ExploreGroupTask │
  └──────────────────┘

OR

     Optimize()
         │
         │
         ▼
    ┌─────────┐                  ┌──────────┐
    │ O_GROUP │ ◄──────────────► │ O_INPUTS │
    └─────────┘                  └──────────┘
         │                             ▲
         │                             │
         ▼                             │
    ┌─────────┐                 ┌────────────┐
    │ O_EXPR  │ ◄─────────────► │ APPLY_RULE │
    └─────────┘                 └────────────┘
         ▲
         │
         ▼
    ┌─────────┐
    │ E_GROUP │
    └─────────┘
```

### 3.1.3 Transformation Rules

#### 3.1.3.1 SplitAggregateRule

1. 默认情况下，所有`LogicalAggregationOperator`的聚合类型都是`AggType::GLOBAL`
1. `LogicalAggregationOperator::isSplit = false`且`AggType::GLOBAL`可以应用`SplitAggregateRule`
    * `isSplit`用于标记是否已应用过`SplitAggregateRule`

通常来说：

* 普通聚合函数：2阶段聚合
* `distinct`：2阶段聚合
* `agg(distinct) +  group by`：3阶段聚合
* `agg(distinct)`：4阶段聚合
* `agg(distinct) +  group by`（其中`group by`列低基数倾斜）：4阶段聚合

#### 3.1.3.2 SplitTopNRule

* `isSplit`用于标记是否已应用过`SplitTopNRule`

#### 3.1.3.3 Subquery

* `ExistentialApply2JoinRule`
* `ExistentialApply2OuterJoinRule`
* `QuantifiedApply2JoinRule`
* `QuantifiedApply2OuterJoinRule`
* `ScalarApply2AnalyticRule`
* `ScalarApply2JoinRule`

### 3.1.4 Merge Group

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

## 3.2 RPC

Frontend-Service

* `QeProcessorImpl`：server
* `FrontendServiceConnection`：client

Backend-Service

* `PInternalServiceImplBase`：server
* `BackendServiceClient`：client

## 3.3 Execution

### 3.3.1 Column

**Traits:**

* `be/src/column/type_traits.h`
    * `RunTimeTypeTraits`
    * `RunTimeCppType`
    * `RunTimeColumnType`

### 3.3.2 Agg

In StarRocks, `update`, `merge`, `serialize`, and `finalize` are four steps in the aggregate operation that are used to compute aggregated values.

`update`: The update step takes a new input row and updates the intermediate results for the corresponding aggregate functions. For example, if we are computing the sum of a column, the update step would add the value of the new input row to the current intermediate sum.

`merge`: The merge step is used to combine intermediate results from multiple parallel execution threads or nodes. In distributed systems, the aggregation computation may be executed on different nodes, so the intermediate results from each node must be merged together to produce the final result.

`serialize`: The serialize step is used to convert the intermediate results into a binary format for efficient storage or transmission. This is typically done by packing the intermediate results into a byte array.

`finalize`: The finalize step computes the final result of the aggregation function from the intermediate results. This is typically the last step in the aggregation computation, and it involves performing any final calculations or transformations to produce the desired output.

In summary, `update` is used to update intermediate results for an aggregate function for each input row, `merge` is used to combine intermediate results from multiple execution threads or nodes, `serialize` is used to convert intermediate results into a binary format, and `finalize` is used to compute the final result of the aggregate function.

**Register Agg Functions:**

* `aggregate_factory.h`
    * `AggregateFuncResolver::get_aggregate_info`
* `aggregate_resolver.hpp`: Different aggregate functions have different resover logic
    * `aggregate_resolver_avg.cpp`
    * `aggregate_resolver_window.cpp`
    * ...

**Interface:**

* `AggregateFunction`(`be/src/exprs/agg/aggregate.h`): Interface
    * `update`: Consume data to update the aggregation state, for one row for a specific state
    * `merge`: For two stages aggregation, all data will be sent to one particular node, and this node need to merge all the aggregation state into one.
    * `finalize_to_column`: Output the result of aggregation
    * `serialize_to_column`: When performing two or more stages aggregation, the intermediate results(agg state) must be transmit over the network. This method is used for serializing the aggregation state into byte stream
    * `convert_to_serialize_format`: Similar to `serialize_to_column`, this method is used to transform the original data as the intermediate formatting(agg state), when the aggregation degree is relatively low. Because the second stage aggregation only processes the aggregated formatted data.
    * **`batch_xxx`**: These kind of method is used to reduce the overhead of virtual function call
        * `update_batch_single_state`: Similar to update, but update multiply rows for a specific state
        * `update_batch`: Similar to update, but update multiply rows for multiply states
* `NullableAggregateFunctionUnary`: Contains the common Nullable Column process for single parameter agg function
* `NullableAggregateFunctionVariadic`: Same as `NullableAggregateFunctionUnary`, but for variadic parameter agg function

**Process:**

1. Fist go through the hash table, to build the `_tmp_agg_states` for current chunk, new `AggState` will be created if necessary
1. Then update agg state by iterating the `_tmp_agg_states` for better SIMD optimiazation
* AggState memory footprint(For a given chunk)
    * Each row has a pointer, e.g. `AggDataPtr`
        * Different rows may store the same `AggDataPtr`, based on the value of group by columns
        * All rows store the same `AggDataPtr` if there is no group by clause
        * `AggDataPtr` are shared by hash table 
    * Each `AggData` contain all the memory areas for all the agg functions, an offset array is required to distinguish between them
    * ![agg_state_mem_footprint](/images/Source-Reading/agg_state_mem_footprint.jpeg)

### 3.3.3 Join

```
             +-------------------+
             | HashJoinOperator  |
             +---------+---------+
                       |
                       |
                       v
             +---------+----------+
             |     HashJoiner     |
             +---------+----------+
                       |
           +-----------+-----------+
           |                       |
           v                       v
 +---------+----------+  +-------- +---------+
 |   HashJoinProber   |  |  HashJoinBuilder  |
 +---------+----------+  +---------+---------+
           |                       |
           v                       v
         +--------------+------------+
         |        JoinHashTable      |
         +---------------------------+
```

### 3.3.4 WindowFunction

* `Window Function`
    * `be/src/exprs/agg/window.h`
    * Frame
        * Unbounded window
        * Half unbounded window
            * Materialized processing
            * Streaming processing
        * Sliding window

### 3.3.5 RuntimeFilter

* `RuntimeFilterWorker`
* `RuntimeFilterPort`
* `RuntimeFilterMerger`
* `RuntimeFilterBuildDescriptor`
* `RuntimeFilterProbeDescriptor`
* `RuntimeFilterHub`
* `PartialRuntimeFilterMerger`
* `SimdBlockFilter`

## 3.4 Storage

### 3.4.1 partition vs. tablet vs. bucket

In StarRocks, partition, tablet, and bucket are related concepts that are used to manage data storage and processing in a distributed environment.

A partition refers to a logical division of data based on a partition key. When a table is created in StarRocks, it can be partitioned based on one or more columns. Each partition contains a subset of the data in the table, and partitions can be processed in parallel to improve query performance.

A tablet in StarRocks is a unit of data storage and processing that is served by a single replica on a single node in the cluster. A tablet is created for each partition and contains a subset of the data in the partition. Tablets can be split or merged based on data size or resource availability.

A bucket in StarRocks is a physical unit of storage that is used to store data within a tablet. Buckets are created based on the hash value of the data distribution key and are stored on separate disks to allow for parallel I/O operations. Each bucket contains a subset of the rows in the tablet and is processed in parallel with other buckets to improve query performance.

In summary, partitions are used to logically divide data based on a partition key, tablets are created for each partition to manage data storage and processing, and buckets are used to physically store and process data within each tablet. The use of partitions, tablets, and buckets helps to improve scalability, fault tolerance, and query performance in distributed data processing environments.

Here is a diagram that illustrates the relationship between partitions, tablets, and buckets in StarRocks:

```
                           +------------+
                           |    Node    |
                           | 1.1.1.1    |
                           +------------+
                             |     |
               +-------------+     +--------------+
               |                                  |
+--------------v--------------+   +--------------v--------------+
|           Tablet            |   |           Tablet            |
| Partition 1, Tablet 1, Buckets |   | Partition 1, Tablet 2, Buckets |
|   +-------------+            |   |            +-------------+   |
|   |   Bucket 1  |            |   |            |   Bucket 1  |   |
|   |   Bucket 2  |            |   |            |   Bucket 2  |   |
|   |   Bucket 3  |            |   |            |   Bucket 3  |   |
|   |   Bucket 4  |            |   |            |   Bucket 4  |   |
|   +-------------+            |   |            +-------------+   |
+--------------+---------------+---+--------------+-------------+
               |                                  |
+--------------v--------------+   +--------------v--------------+
|           Tablet            |   |           Tablet            |
| Partition 2, Tablet 3, Buckets |   | Partition 2, Tablet 4, Buckets |
|            +-------------+   |   |   +-------------+            |
|            |   Bucket 1  |   |   |   |   Bucket 1  |            |
|            |   Bucket 2  |   |   |   |   Bucket 2  |            |
|            |   Bucket 3  |   |   |   |   Bucket 3  |            |
|            |   Bucket 4  |   |   |   |   Bucket 4  |            |
|            +-------------+   |   |   +-------------+            |
+-------------------------------+---+----------------------------+
```

### 3.4.2 How many tablets that a partition should have

The number of tablets that a partition should have in StarRocks depends on several factors, including the size of the data, the available resources, and the desired query performance. Here are some general guidelines to consider when determining the number of tablets:

Size of the data: The size of the data in the partition can impact the number of tablets. Generally, a larger partition may require more tablets to distribute the data across the cluster and improve parallel processing.

Available resources: The number of tablets in a partition should be based on the available resources, including disk space and memory, on the nodes in the cluster. If the number of tablets is too high, it may lead to resource contention and affect the system's performance.

Desired query performance: The number of tablets can impact query performance in StarRocks. More tablets can allow for better parallel processing and faster query performance, but too many tablets can lead to performance issues due to resource contention.

Based on these factors, a common practice is to use the number of CPU cores on each node as a guideline to determine the number of tablets for a partition. For example, if a node has 8 CPU cores, the partition can be divided into 8 tablets. However, this is just a rough guideline, and the number of tablets should be adjusted based on the actual data size and available resources in the cluster.

In summary, the number of tablets that a partition should have in StarRocks should be determined based on the size of the data, the available resources, and the desired query performance. It is a balancing act between distributing the data across the cluster, ensuring optimal resource utilization, and achieving fast query performance.
