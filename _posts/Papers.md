---
title: Papers
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Paper
---

**阅读更多**

<!--more-->

# 1 Database

| 题目 | 分类 | 概要 | 状态 | 推荐级别 |
|:--|:--|:--|:--|:--|
| [Morsel-Driven Parallelism: A NUMA-Aware Query Evaluation Framework for the Many-Core Age](/resources/paper/Morsel-Driven-Parallelism-A-NUMA-Aware-Query-Evaluation-Framework-for-the-Many-CoreAge.pdf) | <li>`Execution`</li><li>`Parallel`</li> |  | ✅ | ★★★★★ |
| [Push vs. Pull-Based Loop Fusion in Query Engines](/resources/paper/Push-vs-Pull-Based-Loop-Fusion-in-Query-Engines.pdf) | <li>`Execution`</li> |  | ✅ | ★★★ |
| [Implementing Database Operations Using SIMD Instructions](/resources/paper/Implementing-Database-Operations-Using-SIMD-Instructions.pdf) | <li>`Execution`</li> | <li>Branch Misprediction</li><li>Tres struct with SIMD</li><li>B+ Tree's leaf node do not need to be stored in order if sequential search is choosed</li><li>Fully use of SIMD by mapping non-fixed size datatype to fixed size datatype</li><li>Fully speed up SIMD by mapping large size to smaller size which means more data in one instruction, and need a second check by the original datatype due to false positive</li> | ✅ | ★★★★★ |
| [MonetDB/X100: Hyper-Pipelining Query Execution](/resources/paper/MonetDB-X100-Hyper-Pipelining-Query-Execution.pdf) | <li>`Execution`</li><li>`Vector Processing`</li> |  |  |  |
| [Design and Evaluation of Main Memory Hash Join Algorithms for Multi-core CPUs](/resources/paper/Design-and-Evaluation-of-Main-Memory-Hash-Join-Algorithms-for-Multi-core-CPUs.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Sort vs. Hash Revisited Fast Join Implementation on Modern Multi-Core CPUs](/resources/paper/Sort-vs.-Hash-Revisited-Fast-Join-Implementation-on-Modern-Multi-Core-CPUs.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Optimizing main-memory join on modern hardware](https://ieeexplore.ieee.org/abstract/document/1019210/) | <li>`Execution`</li><li>`Sort`</li> | <li>radix-cluster algorithm</li> |  |  |
| [Massively Parallel Sort-Merge Joins in Main Memory Multi-Core Database Systems](/resources/paper/Massively-Parallel-Sort-Merge-Joins-in-Main-Memory-Multi-Core-Database-Systems.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Main-Memory Hash Joins on Multi-Core CPUs Tuning to the Underlying Hardware](/resources/paper/Main-Memory-Hash-Joins-on-Multi-Core-CPUs-Tuning-to-the-Underlying-Hardware.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Efficient Implementation of Sorting on Multi-Core SIMD CPU Architecture](/resources/paper/Efficient-Implementation-of-Sorting-on-Multi-Core-SIMD-CPU-Architecture.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Massively Parallel NUMA-aware Hash Joins](/resources/paper/Massively-Parallel-NUMA-aware-Hash-Joins.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [An Experimental Comparison of Thirteen Relational Equi-Joins in Main Memory](/resources/paper/An-Experimental-Comparison-of-Thirteen-Relational-Equi-Joins-in-Main-Memory.pdf) | <li>`Execution`</li><li>`Sort`</li> |  |  |  |
| [Distributed Top-k Query Processing by Exploiting Skyline Summaries](/resources/paper/Distributed-Top-k-Query-Processing-by-Exploiting-Skyline-Summaries.pdf) | <li>`Execution`</li><li>`Sort`</li> |  | ✅ | ★★★ |
| [Optimization of Analytic Window Functions](/resources/paper/Optimization-of-Analytic-Window-Functions.pdf) | <li>`Execution`</li><li>`Window`</li> | <li>SS-reorderable</li><li>Cover Set-based Evaluation</li> | ✅ | ★★★★★ |
| [Efficient Processing of Window Functions in Analytical SQL Queries](/resources/paper/Efficient-Processing-of-Window-Functions-in-Analytical-SQL-Queries.pdf) | <li>`Execution`</li><li>`Window`</li> | <li>**Concepts**</li><li>Hash Groups</li><li>Segment Tree</li> | ✅ | ★★★★★ |
| [Analytic Functions in Oracle 8i](/resources/paper/Analytic-Functions-in-Oracle-8i.pdf) | <li>`Execution`</li><li>`Window`</li> | <li>Minimization of number of sorts</li><li>Predicate Pushdown</li> | ✅ | ★★★★★ |
| [The Cascades Framework for Query Optimization](/resources/paper/The-Cascades-Framework-For-Query-Optimization.pdf) | <li>`Optimizer`</li> | <li>Framework Concepts and Components</li><li>Sketchily</li> | ✅ | ★★★ |
| [Efficiency in the Columbia Database Query Optimizer](/resources/paper/Efficiency-In-The-Columbia-Database-Query-Optimizer.pdf) | <li>`Optimizer`</li> | <li>Framework Concepts and Components</li><li>Detailedly</li> | ✅ | ★★★★★ |
| [How Good Are Query Optimizers, Really?](/resources/paper/How-Good-Are-Query-Optimizers.pdf) | <li>`Optimizer`</li> | <li>Cardinality Estimation is more important than Cost Model</li> | ✅ | ★★★★★ |
| [Orca: A Modular Query Optimizer Architecture for Big Data](/resources/paper/Orca-A-Modular-Query-Optimizer-Architecture-For-Big-Data.pdf) | <li>`Optimizer`</li> | <li>Easy to integrate into other systems</li><li>Parallel Optimization</li> |  | ★★★ |
| [Orthogonal Optimization of Subqueries and Aggregation](/resources/paper/Orthogonal-Optimization-of-Subqueries-and-Aggregation.pdf) | <li>`Optimizer`</li><li>`Sub Query`</li> | <li>Correlated Sub Query</li><li>Remove Correlations</li> |  |  |
| [Are We Ready For Learned Cardinality Estimation?](/resources/paper/Are-We-Ready-For-Learned-Cardinality-Estimation.pdf) | <li>`Optimizer`</li><li>`Cardinality Estimator`</li> | <li>Cardinality Estimator</li><li>Cost Model</li> | ✅ | ★★★★★ |
| [NeuroCard: One Cardinality Estimator for All Tables](/resources/paper/NeuroCard-One-Cardinality-Estimator-for-All-Tables.pdf) | <li>`Optimizer`</li><li>`Cardinality Estimator`</li> |  |  |  |
| [Sampling-Based Estimation of the Number of Distinct Values of an Attribute](/resources/paper/Sampling-Based-Estimation-of-the-Number-of-Distinct-Values-of-an-Attribute.pdf) | <li>`Optimizer`</li><li>`Sampling`</li> | <li>Introduce Many Estimators</li><li>Data Skewness</li> | ✅ | ★★★★★ |
| [Towards Estimation Error Guarantees for Distinct Values](https://dl.acm.org/doi/pdf/10.1145/335168.335230) | <li>`Optimizer`</li><li>`Sampling`</li> |  |  |  |

# 2 Serverless

| 题目 | 分类 | 概要 | 状态 | 推荐级别 |
|:--|:--|:--|:--|:--|
| [Cloud Programming Simplified: A Berkeley View on Serverless Computing](/resources/paper/Cloud-Programming-Simplified-A-Berkeley-View-on-Serverless-Computing.pdf) | <li>`Survey`</li> |  | ✅ | ★★★★★ |
| [Amazon Redshift Re-invented](/resources/paper/Amazon-Redshit-Re-invented.pdf) | <li>`Execution`</li><li>`Amazon`</li> | <li>Architecture</li><li>MPP</li><li>Code Generation & Compilation Service</li><li>Prefetching</li><li>AZ64 Enconding</li><li>AQUA & Computational Storage, do simple computation at the storage</li><li>Automatic Table Optimization(for a given workloads)</li><li>support SUPER value, typeless, can hold anything(int, double, array, json, etc.)</li> | ✅ | ★★★★★ |

# 3 Less Reference

1. [Filter Representation in Vectorized Query Execution](https://dl.acm.org/doi/abs/10.1145/3465998.3466009)