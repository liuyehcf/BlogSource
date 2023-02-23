---
title: DBMS-Execution
date: 2022-06-24 08:33:17
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Basic Concepts
---

**阅读更多**

<!--more-->

# 1 Concepts

## 1.1 Materialize

物化，在不同的场景下有不同的含义：

* 需要等到所有数据都到达后，才能进行处理。在这种定义下，`Agg`算子、`Sort`算子、`Join`算子等等都属于物化算子
* 数据在处理的过程中，脱离寄存器，比如写到另一个内存区域，或者落盘，可以算作物化。在这种定义下，`Project`算子中的表达式计算也属于物化

# 2 优化点

1. IO线程和执行线程速率的匹配。IO线程产生chunk的速率，和算子消费chunk的速率不对等。在push模型下，会增加调度次数，每次调度只处理了几个chunk
    * [introduce unplug mechanism to improve scalability](https://github.com/StarRocks/starrocks/pull/8979)
1. 分区倾斜的场景下排序如何优化
    * 「每路同时独立排序」 -> 「依次对每路数据做并行排序」