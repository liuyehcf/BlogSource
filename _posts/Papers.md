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

<!--
        <tr>
            <td style="text-align:left">
                <a href=""></a>
            </td>
            <td style="text-align:left">
                <li><code>#</code></li>
            </td>
            <td style="text-align:left">
                <li></li>
            </td>
            <td style="text-align:left">✅/👀</td>
            <td style="text-align:left">★★★</td>
        </tr>
-->

<table>
    <thead>
        <tr>
            <th style="text-align:left">题目</th>
            <th style="text-align:left">分类</th>
            <th style="text-align:left">概要</th>
            <th style="text-align:left">状态</th>
            <th style="text-align:left">推荐级别</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Morsel-Driven-Parallelism-A-NUMA-Aware-Query-Evaluation-Framework-for-the-Many-Core-Age.pdf">Morsel-Driven Parallelism: A NUMA-Aware Query Evaluation Framework for the Many-Core Age</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Parallel</code></li>
            </td>
            <td style="text-align:left">
                <li>Mosel is a small fragments of input data</li>
                <li>Many-Core archtecture should take NUMA local processing into account, i.e. NUMA locality</li>
                <li>Machine-dependent number of threads</li>
                <li>Threads are pinned to the cores, avoid thread moving across different cores</li>
                <li>Keep pipeline with homogeneously sized morsels (exchange between to adjacent pipelines) to avoid skewed data distribution</li>
                <li>Scheduling goals
                    <ul>
                        <li>Preserving (NUMA-)locality by assigning data morsels to cores on which the morsels are allocated</li>
                        <li>Full elasticity concerning the level of parallelism of a particular query</li>
                        <li>Load balancing requires that all cores participating in a query pipeline finish their work at the same time in order to prevent (fast) cores from waiting for other (slow) cores</li>
                    </ul>
                </li>
                <li>Work stealing</li>
                <li>The morsel size is not very critical for performance, it only needs to be large enough to amortize scheduling overhead while providing good response times</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Push-vs-Pull-Based-Loop-Fusion-in-Query-Engines.pdf">Push vs. Pull-Based Loop Fusion in Query Engines</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Everything-You-Always-Wanted-to-Know-About-Compiled-and-Vectorized-Queries-But-Were-Afraid-to-Ask.pdf">Everything You Always Wanted to Know About Compiled and Vectorized Queries But Were Afraid to Ask</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
            </td>
            <td style="text-align:left">
                <li>Vectorization(pull base) and data-centric code generation(push base) are both good</li>
                <li>Data-centric code generation is better when executing calculation-heavy queries, while vectorization is good at hiding cache miss latency</li>
                <li>Two constraints of vectorization: It can (i) only work on one data type2 and it (ii) must process multiple tuples</li>
                <li>Data-centric code generation can avoid materialize intermediate result in some degree</li>
                <li>Data-centric code generation perform more complex loop, which leads to more expensive penalty of branch miss and cache miss</li>
                <li>Observation: SIMD is only beneficial when all data fits into the cache</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Implementing-Database-Operations-Using-SIMD-Instructions.pdf">Implementing Database Operations Using SIMD Instructions</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
            </td>
            <td style="text-align:left">
                <li>Branch Misprediction</li>
                <li>Tres struct with SIMD</li>
                <li>B+ Tree’s leaf node do not need to be stored in order if sequential search is choosed</li>
                <li>Fully use of SIMD by mapping non-fixed size datatype to fixed size datatype</li>
                <li>Fully speed up SIMD by mapping large size to smaller size which means more data in one instruction, and need a second check by the original datatype due to false positive</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/MonetDB-X100-Hyper-Pipelining-Query-Execution.pdf">MonetDB/X100: Hyper-Pipelining Query Execution</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Vector Processing</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Interleaved-Multi-Vectorizing.pdf">Interleaved Multi-Vectorizing</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Vector Processing</code></li>
            </td>
            <td style="text-align:left">
                <li>Pointer chasing applications:
                    <ul>
                        <li>traversing skip lists</li>
                        <li>lookup hash table</li>
                        <li>searching trees</li>
                    </ul>
                </li>
                <li>SIMD eliminate branches by compressing and expanding vector</li>
                <li>Miss Status Holding Registers, MSHR, and Line Fill Buffers, LFB</li>
                <li>Prefetching
                    <ul>
                        <li>prefetching distance</li>
                        <li>prefetching-optimized techniques:
                            <ul>
                                <li>Group Prefetching, GP</li>
                                <li>Software Pipelined Prefetching， SPP</li>
                                <li>Memory Access Chaining, AMAC</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>Interleaved Multi-Vectorizing, IMV
                    <ul>
                        <li>Coroutine</li>
                        <li>Splitting states for a vectorized program</li>
                        <li>Residual vectorized states, RVS, with divergent vectorized states, DVS</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Managing-Intra-operator-Parallelism-in-Parallel-Database-Systems.pdf">Managing Intra-operator Parallelism in Parallel Database Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Parallelism</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Design-and-Evaluation-of-Main-Memory-Hash-Join-Algorithms-for-Multi-core-CPUs.pdf">Design and Evaluation of Main Memory Hash Join Algorithms for Multi-core CPUs</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Sort-vs.-Hash-Revisited-Fast-Join-Implementation-on-Modern-Multi-Core-CPUs.pdf">Sort vs. Hash Revisited Fast Join Implementation on Modern Multi-Core CPUs</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a target="_blank" rel="noopener" href="https://ieeexplore.ieee.org/abstract/document/1019210/">Optimizing main-memory join on modern hardware</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Radix-cluster algorithm</li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Massively-Parallel-Sort-Merge-Joins-in-Main-Memory-Multi-Core-Database-Systems.pdf">Massively Parallel Sort-Merge Joins in Main Memory Multi-Core Database Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Main-Memory-Hash-Joins-on-Multi-Core-CPUs-Tuning-to-the-Underlying-Hardware.pdf">Main-Memory Hash Joins on Multi-Core CPUs Tuning to the Underlying Hardware</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Efficient-Implementation-of-Sorting-on-Multi-Core-SIMD-CPU-Architecture.pdf">Efficient Implementation of Sorting on Multi-Core SIMD CPU Architecture</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Massively-Parallel-NUMA-aware-Hash-Joins.pdf">Massively Parallel NUMA-aware Hash Joins</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/An-Experimental-Comparison-of-Thirteen-Relational-Equi-Joins-in-Main-Memory.pdf">An Experimental Comparison of Thirteen Relational Equi-Joins in Main Memory</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Distributed-Top-k-Query-Processing-by-Exploiting-Skyline-Summaries.pdf">Distributed Top-k Query Processing by Exploiting Skyline Summaries</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Optimize TopN when N is large</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Optimization-of-Analytic-Window-Functions.pdf">Optimization of Analytic Window Functions</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Window Function</code></li>
            </td>
            <td style="text-align:left">
                <li>Full Sort, Hashed Sort, Segmented Sort</li>
                <li>Segment Relation</li>
                <li>Reorderable</li>
                <li>SS-reorderable, only reorder in segment level to match expected order property, which not degenerating to full sort</li>
                <li>Cover Set-based Evaluation</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Efficient-Processing-of-Window-Functions-in-Analytical-SQL-Queries.pdf">Efficient Processing of Window Functions in Analytical SQL Queries</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Window Function</code></li>
            </td>
            <td style="text-align:left">
                <li>Basic Concepts:
                    <ul>
                        <li>Partitioning</li>
                        <li>Ordering</li>
                        <li>Framing</li>
                        <li>Window Expression:
                            <ul>
                                <li>ranking, rank/dense_rank/row_number/ntile</li>
                                <li>distribution, percent_rank/cume_dist</li>
                                <li>navigation in partition, lead/lag</li>
                                <li>distinct aggregates, min/max/sum</li>
                                <li>navigation in frame, first_expr/last_expr</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                    <li>Pre-Partitioning into Hash Groups</li>
                    <li>Aggregation Algorithms:
                        <ul>
                            <li>Naive Aggregation</li>
                            <li>Cumulative Aggregation</li>
                            <li>Removable Cumulative Aggregation</li>
                            <li>Segment Tree Aggregation</li>
                        </ul>
                    </li>
                </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Analytic-Functions-in-Oracle-8i.pdf">Analytic Functions in Oracle 8i</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Window Function</code></li>
            </td>
            <td style="text-align:left">
                <li>Minimization of number of sorts</li>
                <li>Predicate Pushdown</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Incremental-Computation-of-Common-Windowed-Holistic-Aggregates.pdf">Incremental Computation of Common Windowed Holistic Aggregates</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Window Function</code></li>
            </td>
            <td style="text-align:left">
                <li>Function classification, including tuple-functions, aggregate-functions, window functions</li>
                <li>Aggregate-functions can be subdivided into distributive aggregates, algebraic aggregates, holistic aggregates</li>
            </td>
            <td style="text-align:left">👀</td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/The-Cascades-Framework-For-Query-Optimization.pdf">The Cascades Framework for Query Optimization</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
            </td>
            <td style="text-align:left">
                <li>Framework Concepts and Components</li>
                <li>Sketchily</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Efficiency-In-The-Columbia-Database-Query-Optimizer.pdf">Efficiency in the Columbia Database Query Optimizer</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
            </td>
            <td style="text-align:left">
                <li>Framework Concepts and Components</li>
                <li>Detailedly</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/How-Good-Are-Query-Optimizers.pdf">How Good Are Query Optimizers, Really?</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
            </td>
            <td style="text-align:left">
                <li>Cardinality Estimation is more important than Cost Model</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Orca-A-Modular-Query-Optimizer-Architecture-For-Big-Data.pdf">Orca: A Modular Query Optimizer Architecture for Big Data</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
            </td>
            <td style="text-align:left">
                <li>Easy to integrate into other systems</li>
                <li>Parallel Optimization</li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Orthogonal-Optimization-of-Subqueries-and-Aggregation.pdf">Orthogonal Optimization of Subqueries and Aggregation</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Subquery</code></li>
            </td>
            <td style="text-align:left">
                <li>Scalar Aggregate means without group by colums, which always returns one row</li>
                <li>Subquery classification: 
                    <ul>
                        <li>boolean-valued subquery, including exist/in/quantified comparisons</li>
                        <li>scalar subquery, which need <code>Max1row</code> operator</li>
                    </ul>
                </li>
                <li>Correlated subquery have three execution strategies: 
                    <ul>
                        <li>correlated execution</li>
                        <li>outerjoin then aggregate</li>
                        <li>aggregate then join</li>
                    </ul>
                </li>
                <li>Algebraic representation</li>
                <li>Remove Correlations, which means the recursive calls between scalar and relational execution are removed, and typically results in outerjoins</li>
                <li>Pushing down Apply</li>
                <li>For <code>(not) exist/in</code> subquery, semijoin for exists, antisemijoin for not exist</li>
                <li>Subquery classes based on different processing strategies: 
                    <ul>
                        <li>Class 1. Subqueries that can be removed with no ad- ditional common subexpressions</li>
                        <li>Class 2. Subqueries that are removed by introducing additional common subexpressions</li>
                        <li>Class 3. Exception subqueries</li>
                    </ul>
                </li>
                <li>GroupBy reorder conditions: 
                    <ul>
                        <li>case groupBy with filter</li>
                        <li>case groupBy with join/outerjoin</li>
                    </ul>
                </li>
                <li>Local Aggregate, Local GroupBy</li>
                <li>SegmentApply, dividing table to indenpendent parts, and perform <code>Apply</code> operator on each parts indenpendently</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a target="_blank" rel="noopener" href="https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.96.5353&amp;rep=rep1&amp;type=pdf">Of Nests aud Trees: A Untied Approach to Processing Queries That Contain Nested Subqueries, Aggregates, and Quantifiers</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Subquery</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Complex-Query-Decorrelation.pdf">Complex Query Decorrelation</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Subquery</code></li>
            </td>
            <td style="text-align:left">
                <li>The concept of correlation in SQL is similar to the use of non-local variables in block-structured programming languages</li>
                <li>Set-oriented</li>
                <li>Count bug, every missing groupBy key is expected to have a zero output</li>
                <li>Magic Decorrelation:
                    <ul>
                        <li>FEED Stage, during which feeding the correlation to its children</li>
                        <li>ABSORB Stage, during which absorbing the correlation and resulting in a decorrelated query</li>
                        <ul>
                            <li>non-SPJ Box, SPJ is the abbreviation of Select-Project-Join</li>
                            <li>SPJ Box</li>
                        </ul>
                    </ul>
                </li>
                <li>Experiment Comparisons:
                    <ul>
                        <li>Nested Iteratio, NI</li>
                        <li>Kim's method</li>
                        <li>Dayal's method</li>
                        <li>Magic Decorrelation</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Enhanced-Subquery-Optimizations-in-Oracle.pdf">Enhanced-Subquery-Optimizations-in-Oracle</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Subquery</code></li>
            </td>
            <td style="text-align:left">
                <li>Subquery coalesce</li>
                <li>Subquery removal using window functions</li>
                <li>Null-aware anti join, NAAJ</li>
            </td>
            <td style="text-align:left">👀</td>
            <td style="text-align:left"></td>
        </tr>
            <tr>
            <td style="text-align:left">
                <a href="/resources/paper/WinMagic-Subquery-Elimination-Using-Window-Aggregation.pdf">WinMagic : Subquery Elimination Using Window Aggregation</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Subquery</code></li>
            </td>
            <td style="text-align:left">
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Outerjoin-Simplification-and-Reordering-for-Query-Optimization.pdf">Outerjoin Simplification and Reordering for Query Optimization</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Join</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Including-Group-By-in-Query-Optimization.pdf">Including Group-By in Query Optimization</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Join</code></li>
                <li><code>#Aggregate</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a target="_blank" rel="noopener" href="http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.102.1517&amp;rep=rep1&amp;type=pdf">Groupwise Processing of Relational Queries</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Join</code></li>
                <li><code>#Aggregate</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Are-We-Ready-For-Learned-Cardinality-Estimation.pdf">Are We Ready For Learned Cardinality Estimation?</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Cardinality Estimator</code></li>
            </td>
            <td style="text-align:left">
                <li>Cardinality Estimator</li>
                <li>Cost Model</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/NeuroCard-One-Cardinality-Estimator-for-All-Tables.pdf">NeuroCard: One Cardinality Estimator for All Tables</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Cardinality Estimator</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Sampling-Based-Estimation-of-the-Number-of-Distinct-Values-of-an-Attribute.pdf">Sampling-Based Estimation of the Number of Distinct Values of an Attribute</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Sampling</code></li>
            </td>
            <td style="text-align:left">
                <li>Introduce Many Estimators</li>
                <li>Data Skewness</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a target="_blank" rel="noopener" href="https://dl.acm.org/doi/pdf/10.1145/335168.335230">Towards Estimation Error Guarantees for Distinct Values</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Sampling</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/SQL-Memory-Management-in-Oracle-9i.pdf">SQL Memory Management in Oracle 9i</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Memory</code></li>
            </td>
            <td style="text-align:left">
                <li>Ways of memory management:
                    <ul>
                        <li>Static configuation</li>
                        <li>Based on estimation</li>
                        <li>Taking into account the used memory</li>
                        <li>Based on demand</li>
                    </ul>
                </li>
                <li>Oracle Memory Architecture:
                    <ul>
                        <li>System Global Area, SGA, is shared by all the server processes</li>
                        <li>Process Global Area, PGA, is indenpendently hold by each server process</li>
                    </ul>
                </li>
                <li>Automatic PGA Memory Management
                    <ul>
                        <li>Feedback</li>
                        <li>Memory Bound is published by a background daemon which indirectly determines the size of each active work</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/4</td>
            <td style="text-align:left"></td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/An-Overview-of-Data-Warehousing-and-OLAP-Technology.pdf">An Overview of Data Warehousing and OLAP Technology</a>
            </td>
            <td style="text-align:left">
                <li><code>#Overview</code></li>
                <li><code>#Warehousing</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Optimizing-Queries-Using-Materialized-Views-A-Practical-Scalable-Solution.pdf">Optimizing Queries Using Materialized Views:A Practical, Scalable Solution</a>
            </td>
            <td style="text-align:left">
                <li><code>#Materialized View</code></li>
            </td>
            <td style="text-align:left">
                <li>Three issues:
                    <ul>
                        <li>View design, about how to store and index</li>
                        <li>View maintenance, about how to update</li>
                        <li>View exploitation, about when to use</li>
                    </ul>
                </li>
                <li>An indexable view must be defined by the following conditions:
                    <ul>
                        <li>A single-level SQL statement containing selections, (inner) joins, and an optional group-by</li>
                        <li>The from clause cannot contain derived tables, i.e. must reference base tables, and subqueries are not allowed</li>
                        <li>The output of an aggregation view must include all groupping columns as output columns and a count column</li>
                        <li>Aggregation functions are limited to sum and count</li>
                    </ul>
                </li>
                <li>View matching is a transformation rule that is invoked on select-project-join-group-by expression, SPJG</li>
                <li>For a SPJ query expression to be computable from a view, the view must satisfy the following requirement:
                    <ul>
                        <li>The view contains all rows needed by the query expression, i.e. checking compability of equality/range/residual predicates</li>
                        <li>All required rows can be selected from the view, i.e. whether columns of compensating equality/range/residual predicates exist</li>
                        <li>All output expressions can be computed from the output of the view, i.e. whether columns of output expressions exist</li>
                        <li>All output rows occur with the correct duplication factor</li>
                    </ul>
                </li>
                <li>Views with extra table
                    <ul>
                        <li>Cardinality-preserving Join, a join between tables T and S is cardinality preserving if every row in T joins with exactly one row in S</li>
                    </ul>
                </li>
                <li>Aggregation queries and view, which can be treated as SPJ query followed by a group-by operation. The following requirements should be satisfied
                    <ul>
                        <li>The SPJ part required requirements</li>
                        <li>All columns required by compensating predicates (if any) are available in the view output</li>
                        <li>The view contains no aggregation or is less aggregated thanthe query</li>
                        <li>All columns required to perform further grouping (if necessary) are available in the view output</li>
                        <li>All columns required to compute output expressions are available in the view output</li>
                    </ul>
                </li>
                <li>Fast filtering of views:
                    <ul>
                        <li>Filter tree</li>
                        <li>Lattice index</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/4</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
    </tbody>
</table>

# 2 Serverless

<table>
    <thead>
        <tr>
            <th style="text-align:left">题目</th>
            <th style="text-align:left">分类</th>
            <th style="text-align:left">概要</th>
            <th style="text-align:left">状态</th>
            <th style="text-align:left">推荐级别</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Cloud-Programming-Simplified-A-Berkeley-View-on-Serverless-Computing.pdf">Cloud Programming Simplified: A Berkeley View on Serverless Computing</a>
            </td>
            <td style="text-align:left">
                <li><code>#Survey</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Amazon-Redshit-Re-invented.pdf">Amazon Redshift Re-invented</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Amazon</code></li>
            </td>
            <td style="text-align:left">
                <li>Architecture</li>
                <li>MPP</li>
                <li>Code Generation &amp; Compilation Service</li>
                <li>Prefetching</li>
                <li>AZ64 Enconding</li>
                <li>AQUA &amp; Computational Storage, do simple computation at the storage</li>
                <li>Automatic Table Optimization(for a given workloads)</li>
                <li>support SUPER value, typeless, can hold anything(int, double, array, json, etc.)</li></td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
    </tbody>
</table>

# 3 Less Reference

1. [Filter Representation in Vectorized Query Execution](https://dl.acm.org/doi/abs/10.1145/3465998.3466009)

# 4 TODO

* Survey
    * [An Overview of Query Optimization in Relational Systems](https://dl.acm.org/doi/pdf/10.1145/275487.275492)
* SubQuery
    * [Reusing Invariants: A New Strategy for Correlated Queries](https://dl.acm.org/doi/pdf/10.1145/276304.276309)
    * [On Optimizing an SQL-like Nested Query](https://dl.acm.org/doi/pdf/10.1145/319732.319745)
* Memory
    * [Efficient Use of Memory Bandwidth to Improve Network Processor Throughput](http://www.cs.ucr.edu/~bhuyan/cs162/LECTURE12b.pdf)
* Oracle
    * [Automatic SQL Tuning in Oracle 10g](/resources/paper/Automatic-SQL-Tuning-in-Oracle-10g.pdf)
    * [Optimizer Plan Change Management: Improved Stability and Performance in Oracle 11g](/resources/paper/Optimizer-Plan-Change-Management-Improved-Stability-and-Performance-in-Oracle-11g.pdf)
    * [Query Optimization in Oracle 12c Database In-Memory](/resources/paper/Query-Optimization-in-Oracle-12c-Database-In-Memory.pdf)
* Statistics/Sample
    * [NeuroCard: One Cardinality Estimator for All Tables](https://vldb.org/pvldb/vol14/p61-yang.pdf)
    * [Flow-Loss: Learning Cardinality Estimates That Mater](https://vldb.org/pvldb/vol14/p2019-negi.pdf)
    * [Learning to Sample: Counting with Complex Queries](https://vldb.org/pvldb/vol13/p390-walenz.pdf)
    * [SetSketch: Filling the Gap between MinHash and HyperLogLog](https://vldb.org/pvldb/vol14/p2244-ertl.pdf)
    * [Fauce: Fast and Accurate Deep Ensembles with Uncertainty for Cardinality Estimation](https://vldb.org/pvldb/vol14/p1950-liu.pdf)
    * [Weighted Distinct Sampling: Cardinality Estimation for SPJ Queries](https://www.cse.ust.hk/~yike/spj-full.pdf)
    * [Learning to be a Statistician: Learned Estimator for Number of Distinct Values](https://vldb.org/pvldb/vol15/p272-wu.pdf)
    * [Count-distinct problem](https://en.wikipedia.org/wiki/Count-distinct_problem)
    * 伯努利采样
    * 皮尔逊系数
    * 泊松分布
    * Kernel Density Estimation
    * 影响Cardinality Estimation准确性的因素
        * 数据倾斜
        * 数据相关信息
        * 值域范围
* Computer Architecture
    * [Residency-Aware Virtual Machine Communication Optimization: Design Choices and Techniques](/resources/paper/Residency-Aware-Virtual-Machine-Communication-Optimization-Design-Choices-and-Techniques.pdf)
* [Implementation of Two Semantic Query Optimization Techniques in DB2 Universal Database](https://www.researchgate.net/profile/Jarek-Gryz/publication/221309776_Implementation_of_Two_Semantic_Query_Optimization_Techniques_in_DB2_Universal_Database/links/0912f51279e7662532000000/Implementation-of-Two-Semantic-Query-Optimization-Techniques-in-DB2-Universal-Database.pdf)
