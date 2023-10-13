
# 1 Optimizer

## 1.1 Uncategory

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
1. `ScalarOperatorToExpr`
    * 将`ScalarOperator`转换成`Expr`，用于最终生成执行计划
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

## 1.2 OptimizerTask

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

## 1.3 Transformation Rules

### 1.3.1 SplitAggregateRule

1. 默认情况下，所有`LogicalAggregationOperator`的聚合类型都是`AggType::GLOBAL`
1. `LogicalAggregationOperator::isSplit = false`且`AggType::GLOBAL`可以应用`SplitAggregateRule`
    * `isSplit`用于标记是否已应用过`SplitAggregateRule`

通常来说：

* 普通聚合函数：2阶段聚合
* `distinct`：2阶段聚合
* `agg(distinct) +  group by`：3阶段聚合
* `agg(distinct)`：4阶段聚合
* `agg(distinct) +  group by`（其中`group by`列低基数倾斜）：4阶段聚合

### 1.3.2 SplitTopNRule

* `isSplit`用于标记是否已应用过`SplitTopNRule`

### 1.3.3 Subquery

* `ExistentialApply2JoinRule`
* `ExistentialApply2OuterJoinRule`
* `QuantifiedApply2JoinRule`
* `QuantifiedApply2OuterJoinRule`
* `ScalarApply2AnalyticRule`
* `ScalarApply2JoinRule`

## 1.4 Merge Group

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

# 2 Other

## 2.1 Service

Frontend-Service

* `FrontendServiceImpl`: server
    * `QeProcessorImpl`: perform the real work
* `FrontendServiceConnection`：client

Backend-Service

* `PInternalServiceImplBase`：server
* `BackendServiceClient`：client

## 2.2 Process

`ConnectProcessor`

* `finalizeCommand`: proxy handling

## 2.3 RBAC

`Authorizer`

# 3 Execution

## 3.1 Column

**Traits:**

* `be/src/column/type_traits.h`
    * `RunTimeTypeTraits`
    * `RunTimeCppType`
    * `RunTimeColumnType`

## 3.2 Expr

* `unary_function.h`
    * `UnpackConstColumnUnaryFunction`
* `binary_function.h`
    * `UnpackConstColumnBinaryFunction`

## 3.3 Agg

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
* Const column will be unpacked by `Aggregator::evaluate_agg_input_column`

## 3.4 Join

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

## 3.5 WindowFunction

* `Window Function`
    * `be/src/exprs/agg/window.h`
    * Frame
        * Unbounded window
        * Half unbounded window
            * Materialized processing
            * Streaming processing
        * Sliding window

## 3.6 RuntimeFilter

* `RuntimeFilterWorker`
* `RuntimeFilterPort`
* `RuntimeFilterMerger`
* `RuntimeFilterBuildDescriptor`
* `RuntimeFilterProbeDescriptor`
* `RuntimeFilterHub`
* `PartialRuntimeFilterMerger`
* `SimdBlockFilter`

## 3.7 Scheduling

### 3.7.1 Queue

* `WorkGroupDriverQueue`: For resource group
    * This queue is just a wrapper, each resource group will use a `QuerySharedDriverQueue`
* `QuerySharedDriverQueue`: Multi-level queue, based on the cumulative execution time.
    * Long running drivers will be placed at the higher level
    * Each level is `SubQuerySharedDriverQueue`

# 4 Storage

![storage](/images/StarRocks/storage.jpeg)

## 4.1 partition vs. tablet vs. bucket

In StarRocks, partition, tablet, and bucket are related concepts that are used to manage data storage and processing in a distributed environment.

**Partition:**

* A partition is a method to divide data into smaller manageable pieces based on certain criteria (usually time-based). Each table can be divided into one or more partitions.
* Partitions allow data to be managed and queried more efficiently. For instance, if you know that your query only concerns data from a specific time range, StarRocks can directly access the corresponding partition without scanning the entire table.
* In StarRocks, each partition has a unique partition key, which is typically determined based on the partitioning method (e.g., a date).

**Bucket(Logical Unit):**

* A bucket is a division of data based on the hash value of the distribution columns. When you create a table, you can specify the number of buckets. StarRocks will then distribute the data among these buckets.
* The primary purpose of bucketing is to ensure a uniform distribution of data. By distributing data across buckets based on a hash function, it reduces data skew and ensures a balanced distribution of data chunks.
* When queries are executed, knowing which bucket contains the required data can help StarRocks optimize the query performance.

**Tablet(Physical Storage and Distribution Unit):**

* After the data is divided into buckets, each bucket's data is then stored in what is called a "tablet". So, you can think of a tablet as a physical storage unit or container for the data of a bucket.
* Each tablet contains a portion of the table's data (from one of the buckets) and is replicated across different nodes in a StarRocks cluster. This replication ensures high availability and fault tolerance.
* When a query is processed, StarRocks figures out which tablets to access based on the query's criteria and then processes the data in those tablets.

Here is a diagram that illustrates the relationship between partitions, tablets, and buckets in StarRocks:

* Table with 2 partitions and 4 buckets. So we have `2 * 4 = 8` tablets.
* There are 4 nodes in the cluster.
* Each Tablet has two replicas sharing the same TabletId but with distinguished BackendId
* TabletId and BackendId can determine a unique tablet.

```
+--------------------------------+   +--------------------------------+
|             Node 1             |   |             Node 2             |
|  +-------------------------+   |   |  +-------------------------+   |
|  |      Partition 1        |   |   |  |      Partition 1        |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 1 (Bucket 1) | |   |   |  | | Tablet 5 (Bucket 3) | |   |
|  | |     BackendId 1     | |   |   |  | |     BackendId 2     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 2 (Bucket 2) | |   |   |  | | Tablet 6 (Bucket 4) | |   |
|  | |     BackendId 1     | |   |   |  | |     BackendId 2     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  +-------------------------+   |   |  +-------------------------+   |
|  +-------------------------+   |   |  +-------------------------+   |
|  |      Partition 2        |   |   |  |      Partition 2        |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 3 (Bucket 1) | |   |   |  | | Tablet 7 (Bucket 3) | |   |
|  | |     BackendId 1     | |   |   |  | |     BackendId 2     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 4 (Bucket 2) | |   |   |  | | Tablet 8 (Bucket 4) | |   |
|  | |     BackendId 1     | |   |   |  | |     BackendId 2     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  +-------------------------+   |   |  +-------------------------+   |
+--------------------------------+   +--------------------------------+

+--------------------------------+   +--------------------------------+
|             Node 3             |   |             Node 4             |
|  +-------------------------+   |   |  +-------------------------+   |
|  |      Partition 1        |   |   |  |      Partition 1        |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 1 (Bucket 1) | |   |   |  | | Tablet 5 (Bucket 3) | |   |
|  | |     BackendId 3     | |   |   |  | |     BackendId 4     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 2 (Bucket 2) | |   |   |  | | Tablet 6 (Bucket 4) | |   |
|  | |     BackendId 3     | |   |   |  | |     BackendId 4     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  +-------------------------+   |   |  +-------------------------+   |
|  +-------------------------+   |   |  +-------------------------+   |
|  |      Partition 2        |   |   |  |      Partition 2        |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 3 (Bucket 1) | |   |   |  | | Tablet 7 (Bucket 3) | |   |
|  | |     BackendId 3     | |   |   |  | |     BackendId 4     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  | | Tablet 4 (Bucket 2) | |   |   |  | | Tablet 8 (Bucket 4) | |   |
|  | |     BackendId 3     | |   |   |  | |     BackendId 4     | |   |
|  | +---------------------+ |   |   |  | +---------------------+ |   |
|  +-------------------------+   |   |  +-------------------------+   |
+--------------------------------+   +--------------------------------+
```

## 4.2 Colocate

The primary motivation behind colocate storage is to reduce data movement/shuffling when executing joins. If related tables (which are frequently joined together) are colocated on the same node, then join operations can be done locally without having to move data between nodes, thus increasing performance and reducing network overhead.

To understand how StarRocks achieves colocate storage, consider the following key aspects:

* **Colocate Group**: StarRocks allows users to specify tables that should be colocated together by putting them in the same colocate group. This ensures that related tables are physically stored on the same nodes.
* **Distribution Key**: The tables within a colocate group are typically distributed based on a common distribution key. This ensures that related rows (rows with the same distribution key value) from different tables are stored together on the same node.
* **Balancing**: StarRocks continuously monitors the distribution of data and can move data around to maintain colocation as data grows or changes. For instance, if a new node is added to the cluster, StarRocks can rebalance data to ensure the colocate property is maintained.
* **Bucket Shuffle**: If the distribution keys are properly chosen, StarRocks can perform bucket shuffle joins, which means it can directly merge data from the two tables without having to reshuffle it. This can significantly boost join performance.
* **Query Optimization**: The query optimizer in StarRocks is aware of the colocation property. When generating execution plans for queries that involve joins between tables in the same colocate group, it can take advantage of the colocation to generate more efficient plans.
* **Failure Handling**: In case of node failures, StarRocks can still access data from replicas since data in StarRocks is typically replicated across multiple nodes for fault tolerance. However, if a node is down, some of the benefits of colocation might be temporarily lost until recovery.
* **Constraints**: It's worth noting that while colocate storage offers performance benefits, it also comes with some constraints. For instance, tables in the same colocate group typically need to have the same distribution key and the same number of buckets.

## 4.3 How many tablets that a partition should have

The number of tablets that a partition should have in StarRocks depends on several factors, including the size of the data, the available resources, and the desired query performance. Here are some general guidelines to consider when determining the number of tablets:

Size of the data: The size of the data in the partition can impact the number of tablets. Generally, a larger partition may require more tablets to distribute the data across the cluster and improve parallel processing.

Available resources: The number of tablets in a partition should be based on the available resources, including disk space and memory, on the nodes in the cluster. If the number of tablets is too high, it may lead to resource contention and affect the system's performance.

Desired query performance: The number of tablets can impact query performance in StarRocks. More tablets can allow for better parallel processing and faster query performance, but too many tablets can lead to performance issues due to resource contention.

Based on these factors, a common practice is to use the number of CPU cores on each node as a guideline to determine the number of tablets for a partition. For example, if a node has 8 CPU cores, the partition can be divided into 8 tablets. However, this is just a rough guideline, and the number of tablets should be adjusted based on the actual data size and available resources in the cluster.

In summary, the number of tablets that a partition should have in StarRocks should be determined based on the size of the data, the available resources, and the desired query performance. It is a balancing act between distributing the data across the cluster, ensuring optimal resource utilization, and achieving fast query performance.

## 4.4 Index

### 4.4.1 ShortKey Index

For each segment, a ShortKey Index is generated. The ShortKey Index is an index for quickly querying based on a given prefix column, sorted by the given key. During the data writing process, an index entry is generated every certain number of lines (usually every 1024 lines), pointing to the corresponding data record.

* **Sparse Indexing**: The "ShortKey Index" uses a sparse indexing structure. Unlike dense indexes that create an index entry for every row in the table, a sparse index generates an entry at specified intervals. This can save on storage and improve write performance, but may require more I/O operations for certain query patterns.
* **Index Granularity**: The granularity of the index determines the frequency at which index entries are generated. By default, StarRocks generates an index entry every 1024 rows, but this value is configurable. Adjusting the index granularity allows for optimization based on specific workloads and query patterns.
* **Performance Considerations**: A smaller index granularity can increase the size of the index but might enhance query performance since the number of data blocks that need scanning could be reduced. Conversely, a larger index granularity can decrease the size of the index but might increase the I/O operations required in certain query scenarios.
* **Usage:**
    * Equality predicate
    * Range predicate
    * Is Null predicate

![short_key](/images/StarRocks/short_key.png)

### 4.4.2 Zonemap Index

The ZoneMap index stores statistical information for each Segment and for each column corresponding to each Page. This statistical information can help speed up queries and reduce the amount of data scanned. The statistics include the Min (maximum value), Max (minimum value), whether there are null values (HashNull), and information on whether all values are not null (HasNotNull).

* **Usage:**
    * Equality predicate
    * Range predicate
    * Is Null predicate

![zone_map](/images/StarRocks/zone_map.png)

### 4.4.3 Bitmap Index

The Bitmap Index indexes an entire segment's column, rather than generating one for each page. During writing, a map is maintained to record the row numbers corresponding to each key value, using Roaring bitmap encoding. It is suitable for value columns with limited values, such as country, region, and so on.

* **Usage:**
    * Equality predicate
    * Range predicate
    * Is Null predicate

![bitmap](/images/StarRocks/bitmap.png)

### 4.4.4 Bloomfilter Index

Bloom filter index is suitable for datasets with high cardinality, provided they are appropriately sized and tuned to manage the desired false positive rate.

* **Usage:** Only Equality predicate

