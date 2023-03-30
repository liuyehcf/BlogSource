---
title: DBMS-Optimizer
date: 2022-06-24 08:32:09
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Basic Concepts
---

**阅读更多**

<!--more-->

# 1 Overview

**优化器涉及到的优化点包括：**

* `Limit`合并
* `Limit`下推
* 子查询重写
* 各种表达式的重写和化简
* 列裁剪
* 谓词下推
* 聚合合并
* 等价谓词推导（常量传播）
* `Outer Join`转`Inner Join`
* 常量折叠
* 公共表达式复用（CTE）
* 子查询重写
* `Lateral Join`化简
* 分区分桶裁剪
* `Empty Node`优化
* `Empty Union, Intersect, Except`裁剪
* `Intersect Reorder`
* `Count Distinct`相关聚合函数重写
* `GroupBy Reordering`

# 2 Subquery Rewrite

[Roadmap of subquery](https://github.com/StarRocks/starrocks/issues/9922)

**子查询分类**

* 按子查询所在的位置进行分类
    * **`WHERE`子句**
    * `SELECT`子句
    * `GROUP BY`子句
    * `ORDER BY`子句
    * `HAVING`子句
* 按是否相关进行分类
    * `Correlated Subquery`，即相关子查询
    * `Non-correlated Subquery`，即非相关子查询
* 按产生的数据特征来分类
    * `Scalar Subquery`，即标量子查询
        * 聚合子查询
        * 非聚合子查询
    * `Existential Test Subquery`，存在性检测子查询，如`EXISTS`子查询
    * `Quantified Comparation Subquery`，集合比较子查询，如`ANY/SOME/ALL`子查询
        * `x = SOME(statement) -> IN (statement)`
        * `x <> ALL(statement) -> NOT IN (statement)`
        * ![quantified_comparisons](/images/DBMS-Optimizer/quantified_comparisons.png)

**上述不同分类均可自由组合**

**下面的讨论都基于如下的数据集：**

```sql
DROP TABLE IF EXISTS `S`;
CREATE TABLE IF NOT EXISTS `S` (
  `s1` int(11) NULL,
  `s2` int(11) NULL,
  `s3` int(11) NULL
) ENGINE=OLAP
DUPLICATE KEY(`s1`)
DISTRIBUTED BY HASH(`s1`) BUCKETS 10
PROPERTIES (
 "replication_num" = "1"
);

INSERT INTO `S` (s1, s2, s3) values
    (1, 2, 3),
    (1, 2, 3),
    (4, 5, 6),
    (4, 5, 6),
    (7, 8, 9),
    (10, NULL, 12),
    (13, 14, 15),
    (16, 17, 18);

DROP TABLE IF EXISTS `R`;
CREATE TABLE IF NOT EXISTS `R` (
  `r1` int(11) NULL,
  `r2` int(11) NULL,
  `r3` int(11) NULL
) ENGINE=OLAP
DUPLICATE KEY(`r1`)
DISTRIBUTED BY HASH(`r1`) BUCKETS 10
PROPERTIES (
 "replication_num" = "1"
);

INSERT INTO `R` (r1, r2, r3) values
    (1, 2, 3),
    (1, 2, NULL),
    (4, 55, 6),
    (7, NULL, 9),
    (7, 8, 9),
    (10, NULL, 12),
    (13, 14, NULL),
    (19, 20, 21);
```

## 2.1 Scalar Subquery

## 2.2 Exists Subquery

### 2.2.1 Implement with Semi Join

**对于在`WHERE Clause`中的`Exists Subquery`，一般用`Semi Join`来进行转换。下面用一个例子来说明，原`SQL`如下，其含义是，针对`S`表中的每一行，在`R`表中找出满足`S.s3 = R.r3`的所有行，并提取出`R.r2`作为结果集`A`，看结果集`A`是否存在非空元素，并以此作为过滤条件，过滤`S`的数据**

```sql
SELECT S.s1, S.s2
FROM S
WHERE EXISTS (
  SELECT R.r2
  FROM R
  WHERE S.s3 = R.r3
)
```

**重写后的`SQL`如下：**

```sql
SELECT S.s1, S.s2
FROM S LEFT SEMI JOIN R
ON S.s3 = R.r3
```

### 2.2.2 Implement with Outer Join

**对于在`SELECT Clause`中的`Exists Subquery`，一般用`Outer Join`来进行转换。下面用一个例子来说明，原`SQL`如下，其含义是，针对`S`表中的每一行，在`R`表中找出满足`S.s3 = R.r3`的所有行，并提取出`R.r2`作为结果集`A`，看这个结果集`A`是否存在非空元素**

```sql
SELECT S.s1, EXISTS (
  SELECT R.r2
  FROM R
  WHERE S.s3 = R.r3
)
FROM S;
```

**重写后的`SQL`如下：**

```sql
SELECT S.s1, R_GroupBy.r3_Row IS NOT NULL FROM
S LEFT JOIN (
  SELECT R.r3, COUNT(1) AS r3_Row FROM
  R GROUP BY R.r3
) AS R_GroupBy
ON S.s3 = R_GroupBy.r3;
```

## 2.3 In Subquery

### 2.3.1 Implement with Semi Join

**对于在`WHERE Clause`中的`In Subquery`，一般用`Semi Join`来进行转换。下面用一个例子来说明，原`SQL`如下，其含义是，针对`S`表中的每一行，在`R`表中找出满足`S.s3 = R.r3`的所有行，并提取出`R.r2`作为结果集`A`，看`S.s2`是否在这个结果集`A`中，并以此作为过滤条件，过滤`S`的数据**

```sql
SELECT S.s1, S.s2
FROM S
WHERE S.s2 IN
(
  SELECT R.r2
  FROM R
  WHERE S.s3 = R.r3
)
```

**重写后的`SQL`如下：**

```sql
SELECT S.s1, S.s2
FROM S LEFT SEMI JOIN R
ON S.s2 = R.r2 AND S.s3 = R.r3
```

### 2.3.2 Implement with Outer Join

**对于在`SELECT Clause`中的`In Subquery`，一般用`Outer Join`来进行转换。下面用一个例子来说明，原`SQL`如下，其含义是，针对`S`表中的每一行，在`R`表中找出满足`S.s3 = R.r3`的所有行，并提取出`R.r2`作为结果集`A`，看`S.s2`是否在这个结果集`A`中**

```sql
SELECT S.s1, S.s2 IN
(
  SELECT R.r2
  FROM R
  WHERE S.s3 = R.r3
)
FROM S;
```

* 若`S.s2`为`NULL`，那么返回`NULL`
* 若结果集`A`为空，那么返回`false`
* 对于当前行（固定`S.s3`的值），若`R`表中不存在满足`R.r3 = S.s3`的行，那么返回`false`

**重写后的`SQL`如下：**

```sql
WITH R_CTE AS (SELECT R.r2, R.r3 FROM R)
SELECT S.s1,
       CASE 
           WHEN R_CountRow.R_Rows IS NULL THEN FALSE
           WHEN S.s2 IS NULL THEN NULL
           WHEN R_GroupBy.r2 IS NOT NULL THEN TRUE
           WHEN R_CountRow.r2_NotNulls < R_CountRow.R_Rows THEN NULL
           ELSE FALSE
       END
FROM S
LEFT OUTER JOIN
  (
    SELECT R_CTE.r2, R_CTE.r3
    FROM R_CTE
    GROUP BY R_CTE.r2, R_CTE.r3
  ) AS R_GroupBy 
  ON S.s2 = R_GroupBy.r2
  AND S.s3 = R_GroupBy.r3
LEFT OUTER JOIN
  (
    SELECT r3,
          count(*) AS R_Rows,
          count(R_CTE.r2) AS r2_NotNulls
    FROM R_CTE
    GROUP BY R_CTE.r3
  ) AS R_CountRow 
  ON  S.s3 = R_CountRow.r3;
```

* `R_GroupBy`：通过`Left Outer Join`将谓词`IN`调整谓词`==`
* `R_CountRow`：用于统计`R`表中各分组（`by r3`）下的总行数以及`R.r2`非`NULL`的行数
* **`CASE WHEN`语句分析：**
    * `CASE WHEN 1`：若`R_CountRow.R_Rows IS NULL`，我们知道`count(*)`是不会产生空值的，因此该空值一定是`Left Outer Join`产生的，意味着对于当前行（固定`S.s3`的值），`R`表中不存在满足`R.r3 = S.s3`的行，即集合`A`为空。因此根据`ANY_OR_NULL IN (empty) -> false`，谓词`IN`的结果就是`false`
    * 否则，意味着对于当前行（固定`S.s3`的值），`R`表中存在满足`R.r3 = S.s3`的行，即集合`A`不为空
    * `CASE WHEN 2`：若`S.s2 IS NULL`。因此根据`NULL IN (ANY_OR_NULL...) -> NULL`，谓词`IN`的结果就是`NULL`
    * 否则，意味着`S.s2 IS NOT NULL`
    * `CASE WHEN 3`：若`R_GroupBy.r2 IS NOT NULL`，意味着对于当前行（固定`S.s3`的值），集合`A`中至少存在一个元素满足`S.s2 = R.r2`，因此根据`X IN (X, [ANY_OR_NULL...]) -> true`，谓词`IN`的结果就是`true`
    * 否则，意味着`R_GroupBy.r2 IS NULL`
    * `CASE WHEN 4`：若`R_CountRow.r2_NotNulls < R_CountRow.R_Rows`，意味着对于当前行（固定`S.s3`的值），集合`A`中一定存在`NULL`元素。因此根据`X IN (NULL, [NOT_X_OR_NULL...]) -> NULL`，谓词`IN`的结果就是`NULL`
    * 否则，意味着`R_CountRow.r2_NotNulls = R_CountRow.R_Rows`，则集合`A`中不存在`NULL`元素，因此根据`X IN (NOT_X...) -> false`，谓词`IN`的结果就是`false`

## 2.4 Generic Decorrelation Algorithm

[Complex Query Decorrelation](/resources/paper/Complex-Query-Decorrelation.pdf)

**下面用一个例子来解释该算法：**

* `Dept`：部门信息，其中`building`字段表示该部门的主要办公地点（意味着，该部门下的员工也可以在其他地点办公）
* `Emp`：员工信息

下面这个`SQL`的业务含义是，找出预算小于`10000`，且主要办公地点无法容纳该部门所有员工的部门

```sql
SELECT D.name
FROM Dept D
WHERE D.budget < 10000 
AND D.num_emps > (
    SELECT COUNT(*) FROM Emp E WHERE D.building = E.building
)
```

### 2.4.1 FEED Stage

**请结合论文中的`Figure 2`看如下的分析**

#### 2.4.1.1 step a

初始状态。显然，`Child_1`与`CurBox`存在关联

```sql
-- CurBox
SELECT Q1.name
FROM Dept Q1, Temp_1 Q2
WHERE Q1.budget < 10000
AND Q1.num_emps > Q2.$1;

-- Temp_1 如下
SELECT COUNT(*) FROM Child_1;

-- Child_1 如下
SELECT * FROM Emp Q3
WHERE Q1.building = Q3.building;
```

#### 2.4.1.2 step b

将谓词`Q1.budget < 10000`下推，构造出`Supp`替换原来的`Dept`

```sql
-- CurBox
SELECT Q1.name
FROM Supp Q1, Temp_1 Q2
WHERE Q1.num_emps > Q2.$1;

-- Supp 如下
SELECT * FROM Dept
WHERE Dept.budget < 10000;

-- Temp_1 如下
SELECT COUNT(*) FROM Child_1;

-- Child_1 如下
SELECT * FROM Emp Q3
WHERE Q1.building = Q3.building;
```

#### 2.4.1.3 step c

接着，从`Supp`中构造出`Magic_1`

```sql
-- CurBox
SELECT Q1.name
FROM Supp Q1, Temp_1 Q2
WHERE Q1.num_emps > Q2.$1;

-- Supp 如下
SELECT * FROM Dept
WHERE Dept.budget < 10000;

-- 新构造的 Magic_1 如下
SELECT DISTINCT(building) FROM Supp;

-- Temp_1 如下
SELECT COUNT(*) FROM Child_1;

-- Child_1 如下
SELECT * FROM Emp Q3
WHERE Q1.building = Q3.building;
```

#### 2.4.1.4 step d

这一步比较复杂，引入`DCO(Decorrelated Output) Box`以及`CI(Correlated Input) Box`

* `CiBox_1`与`CurBox`存在关联，但这个相关性可以通过`Eq Join`解除
    * 对于`CiBox_1`，每个`building`只有一条数据
    ```sql
    SELECT Q1.name
    FROM Supp Q1 JOIN CiBox_1 Q2
    ON Q1.building = Q2.building
    WHERE Q1.num_emps > Q2.$1;
    ```

* `Child_1`与`CurBox`存在关联，但由于`Magic_1`的存在，`Child_1`与`DcoBox_1`也存在关联。因此，关联关系就被下推了
* 于是`CurBox`的相关性就被解除了

```sql
-- CurBox
SELECT Q1.name
FROM Supp Q1, CiBox_1 Q2
WHERE Q1.num_emps > Q2.$1;

-- Supp 如下
SELECT * FROM Dept
WHERE Dept.budget < 10000;

-- Magic_1 如下
SELECT DISTINCT(building) FROM Supp;

-- CiBox_1 如下
SELECT * FROM DcoBox_1 Q3
WHERE Q3.building = Q1.building;

-- DcoBox_1 如下
SELECT Q4.building, Q5.$1
FROM Magic_1 Q4, Temp_2 Q5;

-- Temp_2 如下
SELECT COUNT(*) FROM Child_1;

-- Child_1 如下
SELECT * FROM Emp Q3
WHERE Q1.building = Q3.building;
```

### 2.4.2 ABSORB Stage

`ABSORB`阶段的目标是将相关性整个除去。紧接着`FEEE Stage`的`step d`继续流程，此时`CurBox`指向的是`Temp_2`

#### 2.4.2.1 non-SPJ Box

情况1，即`CurBox`指向的不是一个`SPJ Box`，比如是一个`Aggregate Box`

##### 2.4.2.1.1 step a

该状态等同于`FEEE Stage`的`step d`，只不过`CurBox`下移了

##### 2.4.2.1.2 step b

此时，可以进一步对`CurBox`的父节点使用`FEEE Stage`的流程

```sql
-- DcoBox_1 如下
SELECT Q4.building, Q5.$1
FROM Magic_1 Q4, Temp_2 Q5;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_2 如下
SELECT COUNT(*) FROM CiBox_2 Q6;

-- CiBox_2 如下
SELECT * FROM DcoBox_2 Q7
WHERE Q4.building = Q7.building;

-- DcoBox_2 如下
SELECT * FROM Magic_2 Q8, Temp_3 Q9;

-- Temp_3 如下
SELECT * FROM Emp Q3 
WHERE Q8.building = Q3.building;
```

##### 2.4.2.1.3 step c

此时，`DcoBox_1`与`CiBox_2`存在相关性，但是`CiBox_2`可以从其孩子节点中获取相关性，因此`DcoBox_1`与`CiBox_2`的相关性是冗余的，可以通过`LOJ`直接移除

```sql
-- DcoBox_1 如下
SELECT Q4.building, Coalesce(Q5.count, 0)
FROM Magic_1 Q4 LEFT OUTER JOIN Temp_2 Q5
ON Q4.building = Q5.building;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_2 如下
SELECT Q6.building, COUNT(*) as count
FROM CiBox_2 Q6
GROUP BY Q6.building;

-- CiBox_2 如下
SELECT * FROM DcoBox_2 Q7;

-- DcoBox_2 如下
SELECT * FROM Magic_2 Q8, Temp_3 Q9;

-- Temp_3 如下
SELECT * FROM Emp Q3 
WHERE Q8.building = Q3.building;
```

##### 2.4.2.1.4 step d

这一步比较简单，移除冗余的`CiBox_2`即可

```sql
-- DcoBox_1 如下
SELECT Q4.building, Coalesce(Q5.count, 0)
FROM Magic_1 Q4 LEFT OUTER JOIN Temp_2 Q5
ON Q4.building = Q5.building;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_2 如下
SELECT Q6.building, COUNT(*) as count
FROM DcoBox_2 Q6
GROUP BY Q6.building;

-- DcoBox_2 如下
SELECT Q8.building, Q9.* FROM Magic_2 Q8, Temp_3 Q9;

-- Temp_3 如下
SELECT * FROM Emp Q3 
WHERE Q8.building = Q3.building;
```

#### 2.4.2.2 SPJ Box

此时`CurBox`继续下移，指向了`step d`中的`Temp_3`

##### 2.4.2.2.1 step a

```sql
-- DcoBox_2 如下
SELECT Q8.building, Q9.* FROM Magic_2 Q8, Temp_3 Q9;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_3 如下
SELECT * FROM Emp Q3 
WHERE Q8.building = Q3.building;
```

##### 2.4.2.2.2 step b

`Temp_3`将`Magic_2`添加到其`From Clause`中，并改写`Join On Predicate`，于是`DcoBox_2`与`Temp_3`的相关性就被移除了

```sql
-- DcoBox_2 如下
SELECT Q8.building, Q9.* FROM Magic_2 Q8, Temp_3 Q9;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_3 如下
SELECT Q3.* 
FROM Magic_2 Q10, Emp Q3 
WHERE Q10.building = Q3.building;
```

##### 2.4.2.2.3 step c

`Temp_3`增加输出列`Q10.building`

```sql
-- DcoBox_2 如下
SELECT Q9.* FROM Temp_3 Q9;

-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_3 如下
SELECT Q10.building, Q3.* 
FROM Magic_2 Q10, Emp Q3 
WHERE Q10.building = Q3.building;
```

##### 2.4.2.2.4 step d

移除冗余的`DcoBox_2`

```sql
-- Magic_2 如下
SELECT DISTINCT(building) FROM Magic_1;

-- Temp_3 如下
SELECT Q10.building, Q3.* 
FROM Magic_2 Q10, Emp Q3 
WHERE Q10.building = Q3.building;
```

## 2.5 Subquery Elimination by Window Function

[[Enhancement] Subquery elimination by window function](https://github.com/StarRocks/starrocks/issues/11694)

## 2.6 参考

* [子查询漫谈](https://mp.weixin.qq.com/s/5jRt9R1G7lPMC1nB3ekw7A)

# 3 GroupBy Reordering

[Orthogonal Optimization of Subqueries and Aggregation](/resources/paper/Orthogonal-Optimization-of-Subqueries-and-Aggregation.pdf)

用{% raw %}$G_{A,F}(R)${% endraw %}表示`GroupBy`，其中`A`表示`GroupBy`列，`F`表示输出列

## 3.1 Filter

### 3.1.1 push down

{% raw %}$$\sigma_{p}G_{A,F}(R) \rightarrow G_{A,F}(\sigma_{p}R)$${% endraw %}

**上述转换成立的条件如下：**

* `Filter`中用到的列全部来自于`GroupBy`的输入列。换言之，不对`GroupBy`的输出列进行过滤

## 3.2 Join

### 3.2.1 push down

{% raw %}$$G_{A,F}(S \Join_{p} R) \rightarrow S \Join_{p} G_{A \cup columns(p)-columns(S),F}(R)$${% endraw %}

**上述转换成立的条件如下：**

* `Join Predicate p`中与`R`有关的列必须存在于`GroupBy`列中
* `S`的主键必须存在于`GroupBy`列中
* 聚合操作仅用到了`R`中的列

### 3.2.2 pull above

{% raw %}$$S \Join_{p} G_{A,F}(R) \rightarrow G_{A \cup columns(S),F}(S \Join_{p} R)$${% endraw %}

**上述转换成立的条件如下：**

* `Join`的表有主键
* `Join`没有用到聚合函数的结果列

## 3.3 Outer Join

### 3.3.1 push down

{% raw %}$$G_{A,F}(S ⟕_{p} R) \rightarrow \pi_{c}(S ⟕_{p} G_{A - columns(S),F}(R))$${% endraw %}

**上述转换成立的条件如下（同`Join push down`）：**

* `Join Predicate p`中与`R`有关的列必须存在于`GroupBy`列中
* `S`的主键必须存在于`GroupBy`列中
* 聚合操作仅用到了`R`中的列

**可以发现，`Outer Join`与`Join`的差异是，多了一个{% raw %}$\pi_{c}${% endraw %}**

* 当`GroupBy`列为`NULL`时，若聚合函数针对该`NULL`分组可以生成`NULL`时，比如`sum`，无需引入额外的{% raw %}$\pi_{c}${% endraw %}
* 当`GroupBy`列为`NULL`时，若聚合函数针对该`NULL`分组无法生成`NULL`时，比如`count`，则需引入额外的{% raw %}$\pi_{c}${% endraw %}，来产生相应的`NULL`值

**下面用一个例子来说明**

```sql
DROP TABLE IF EXISTS `S`;
CREATE TABLE IF NOT EXISTS `S` (
  `s1` int(11) NOT NULL,
  `s2` int(11) NOT NULL
) ENGINE=OLAP
DUPLICATE KEY(`s1`)
DISTRIBUTED BY HASH(`s1`) BUCKETS 10
PROPERTIES (
 "replication_num" = "1"
);

INSERT INTO `S` (s1, s2) values
    (1, 2),
    (2, 4),
    (3, 6);

DROP TABLE IF EXISTS `R`;
CREATE TABLE IF NOT EXISTS `R` (
  `r1` int(11) NULL,
  `r2` int(11) NULL
) ENGINE=OLAP
DUPLICATE KEY(`r1`)
DISTRIBUTED BY HASH(`r1`) BUCKETS 10
PROPERTIES (
 "replication_num" = "1"
);

INSERT INTO `R` (r1, r2) values
    (1, 12),
    (2, 22);
```

```sql
-- Q1.1
SELECT r1, sum FROM S LEFT OUTER JOIN (SELECT sum(r2) AS sum, r1 FROM R GROUP BY r1)a ON s1 = r1;
-- Q1.2
SELECT r1, sum(r2) AS sum FROM (SELECT * FROM S LEFT OUTER JOIN R ON s1 = r1)a GROUP BY r1;

-- Q2.1
SELECT r1, cnt FROM S LEFT OUTER JOIN (SELECT count(r2) AS cnt, r1 FROM R GROUP BY r1)a ON s1 = r1;
-- Q2.2
SELECT r1, count(r2) AS cnt FROM (SELECT * FROM S LEFT OUTER JOIN R ON s1 = r1)a GROUP BY r1;
-- Q2.3
SELECT r1,
CASE
    WHEN r1 IS NULL
    THEN NULL
    ELSE count(r2)
END AS cnt
FROM (SELECT * FROM S LEFT OUTER JOIN R ON s1 = r1)a GROUP BY r1;
```

**可以发现：**

* `Q1.1`和`Q1.2`可以产生相同的输出，因为聚合函数`sum`对于`NULL`分组可以正常产生`NULL`值
* `Q2.1`和`Q2.2`无法产生相同的输出，因为聚合函数`count`对于`NULL`分组会输出`0`或`1`。因此这里我们通过`case when`语句来对输出列进行改写`Q2.3`，以达到纠正的目的

# 4 Data Skew

* [[Enhancement] Add GroupByCountDistinctDataSkewEliminateRule](https://github.com/StarRocks/starrocks/pull/17643)
* [[Enhancement] Support [skew] hints in group-by-multi-column-count-distinct-one-column](https://github.com/StarRocks/starrocks/pull/20219)

Given the following case, where column `v1` has very limited cardinality, and column `v2` has very large cardinality and severely skewed. For example, for `v1 = 'x'`, a great number of distinct values of `v2` within this group, but for other values of `v1`, the number of `v2`'s distinct value is much more smaller, this kind of data distribution will lead to poor execution performance.

```sql
SELECT v1, COUNT(DISTINCT v2) FROM t0 GROUP BY v1
```

This query can be optimized, as down below, by introducing another group by dimension(hash of `v2`) to make sure the processing of count distinct can be fully paralleled.

```sql
SELECT v1, SUM(CNT_IN_BUCKET) 
FROM (
     SELECT v1, (MURMUR_HASH3_32(v2)%1024) AS BUCKET, COUNT(DISTINCT v1) AS CNT_IN_BUCKET 
     FROM t0
     GROUP BY v1, BUCKET
) a
GROUP BY v1
```

# 5 Property

## 5.1 HashProperty

`Shuffle by v1`可以满足`Shuffle by v1, v2`，只不过到了每个节点后，还需要再对`v2`进行一次shuffle
