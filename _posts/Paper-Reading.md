---
title: Paper-Reading
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Paper
---

**阅读更多**

<!--more-->

# 1 Morsel-Driven Parallelism: A NUMA-Aware Query Evaluation Framework for the Many-Core Age

1. 为什么现在开始关注`many-core`架构：随着内存带宽的增长，出现了一些内存级的数据库（广义或者狭义，狭义指的是所有数据完全存在于内存中；广义指的是部分数据以某种形式存在于内存中，比如缓存），对于这些数据库系统，I/O不再是性能瓶颈，能否高效利用好计算机的多个`core`决定了系统整体的性能
1. 核心是调度机制：（称为`dispatcher`），能够灵活的调整pipeline的并发度
1. 我们的调度程序运行固定的、依赖于机器的线程数，这样即使有新查询到达，也不会出现资源超额订阅，并且这些线程被固定在核心上，这样就不会由于操作系统将线程移动到不同的核心
1. `morsel`：data fragment，主要指数据格式，量词，一小部分
1. `morsel-driven`调度器的关键特征：任务的分配是在运行时完成的，因此是完全弹性的。即使面对不确定的中间结果大小分布，以及现代CPU内核难以预测的性能（即使工作量相同，性能也会变化）也能有较好的表现
1. 有一些系统采用了`operator`维度的并发控制，但是这会引入不必要的同步开销，因为在大部分场景下，operator之间是存在关联关系的，下一个operator需要接受上一个operator的输入，频繁的数据同步操作会带来负增益
1. `morsel-driven`和`volcano`模型的区别诶是：`volcano`中的执行单元是相互独立的，但是`mosel-driven`中不同的pipeline之间是存在依赖的，它们之间会通过`lock-free`机制来实现数据共享
1. `morsel-at-a-time`：一次处理一组数据，随后即进入调度，避免复杂低优先级查询饿死简单高优先级查询
1. `dispatcher`的运行有两种方式：其一，用独立的线程或者线程池来完成分发相关的code；其二，每个worker分别运行分发相关的code（take task from a lock-free-queue）
1. 由于pipeline之间是有依赖关系的，因此，当前驱pipeline完成后需要通知并驱动下一个pipeline，这种机制叫做`passive state machine`
1. `elasticity`：在任何时候可以将core分配给任何查询任务的能力
1. 在`morsel-driven`架构中，取消查询的代价非常低（可能原因是用户取消查询，或者内存分配超限等等异常情况），只需要将查询相关的pipeline标记为`cancel`，那么所有的worker便不再处理这个查询了（相比于让操作系统杀掉线程的操作来说轻量很多）

**progress：5/12 3.3**

# 2 Efficiency in the Columbia Database Query Optimizer

# 3 Fast Selection and Aggregation on Encoded Data using Operator Specialization

# 4 Shared memory consistency models - A tutorial

