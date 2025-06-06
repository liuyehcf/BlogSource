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
            <td style="text-align:left">✅/👀/🤷🏻</td>
            <td style="text-align:left">★★★</td>
        </tr>
-->

# 1 OLAP

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
                <li>B+ Tree's leaf node do not need to be stored in order if sequential search is choosed</li>
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
            <td style="text-align:left">
                <li>How CPU works
                    <ul>
                        <li>Pipelining, branch, cache, memory access</li>
                        <li>Super-scalar CPU can take multiple instructions into execution in parallel if they are independent, because CPU have more than one pipeline</li>
                        <li>Radix-partitioned hash-join has cache-friendly memory access pattern</li>
                    </ul>
                </li>
                <li>Microbenchmark: TPC-H Query 1
                    <ul>
                        <li>Binary Association Table, BAT</li>
                        <li>Full materialization may offset the benefit from the vectorization, because memory access becomes a bottleneck when bandwidth is full</li>
                    </ul>
                </li>
                <li>Vectorized Query Processor
                    <ul>
                        <li>Chunk at a time, cache-resident data, vector size, range from 1k to 8k, works well</li>
                        <li>Data in vertically fragmented form</li>
                        <li>MonetDB Instruction Language, MIL</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
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
                <li><a href="https://github.com/StarRocks/starrocks/pull/27907">[Feature] improve hash join performance by coroutine-based interleaving</a></li>
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
                <a href="/resources/paper/Self-Tuning-Query-Scheduling-for-Analytical-Workloads.pdf">Self-Tuning Query Scheduling for Analytical Workloads</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Scheduling</code></li>
            </td>
            <td style="text-align:left">
                <li>Context
                    <ul>
                        <li>It's difficult to retain competitive query performance when the system is under a high load. In contrast, system tends to become less responsive, taking longer to provide the desired insights, and the query performance tends to become unpredictable</li>
                        <li>Performance should degrade as gracefully as possible</li>
                        <li>Database systems like PostgreSQL transfer scheduling responsibilities to the operating system (OS). They create individual OS threads or processes for every new connection and execute the incoming requests in an isolated fashion</li>
                        <li>Many modern database systems deviate from this classic approach. Their parallelization scheme closely resembles task-based parallelism. Each query is split into a set of independent tasks, which can be executed in parallel by different OS threads</li>
                        <li>Other systems like HyPer and Umbra relieve the OS from almost all scheduling decisions. On startup, they spawn as many OS threads as there are CPU cores. Since these threads do not block when executing tasks, this maximizes performance. The system is not oversubscribed and context switches are kept to a minimum. The task-based parallelization scheme is realized through so-called morsels. A morsel represents a fixed set of tuples in the context of an executable pipeline and is the smallest unit of work during query execution</li>
                    </ul>
                </li>
                <li>Scalable task scheduling
                    <ul>
                        <li>Stride scheduling gives smaller stride on bigger priority</li>
                        <li>Tasks are executed by OS threads. On startup, Umbra creates as many OS threads as there are CPU cores. We also call these threads worker threads. The worker threads are only responsible for executing scheduler tasks. This design minimizes context switches and prevents oversubscription</li>
                        <li>Worker threads should not block</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/Chap2.3</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Parallel-Merge-Sort.pdf">Parallel Merge Sort</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Sort models, circuits and PRAM(parallel random access memory)
                    <ul>
                        <li>CRCW(concurrent read and concurrent write) PRAM</li>
                        <li>CREW(concurrent read and exclusive write) PRAM</li>
                        <li>EREW(exclusive read and exclusive write) PRAM</li>
                    </ul>
                </li>
                <li>Tree-based merge sort, CREW algorighm
                    <ul>
                        <li><b>Think about the tree-based merge sort, items are merged level by level from bottom up. For merge operation, different level processes different amount of items, and we use <code>log(N)</code> stages to merge <code>N</code> items. And here comes the key observation that the merges at the different levels of the tree can be pipelined</b></li>
                        <li>Runs in <code>O(log(N))</code> time on <code>N</code> processors</li>
                        <li>Definitions:
                            <ul>
                                <li><code>L(u)</code> denotes the final sorted array of the subtree rooted at node <code>u</code></li>
                                <li><code>UP(u)</code> denotes the subset of <code>L(u)</code>, which will become a more accurate approximation of <code>L(u)</code> as stage goes forward</li>
                                <li><code>SUP(u)</code> denotes the subset of <code>UP(u)</code>, which is also sorted</li>
                                <li><code>0 < |UP(u)| < |L(u)|</code>, then node <code>u</code> is inside node</li>
                                <li><code>|UP(u)| = |L(u)|</code>, then node <code>u</code> is external node</li>
                                <li><code>L</code> is a <code>c</code>-cover of <code>J</code> if each interval induced by an item in <code>L</code>(<code>[e, g]</code>, where <code>e</code> and <code>g</code> are two adjacent items in <code>L</code>) contains at most <code>c</code> items from <code>J</code>. And, usually <code>|L| < |J|</code>
                                    <ul>
                                        <li><code>OLDSUP(v)</code> is a 3-cover of <code>SUP(v)</code></li>
                                        <li>As <code>UP(u) = OLDSUP(v) ∪ OLDSUP(w)</code>, we can deduce that <code>UP(v)</code> is a 3-cover of <code>SUP(v)</code> and <code>UP(v)</code> is a 3-cover of <code>SUP(w)</code>, why???</li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li>For every node <code>u</code> at every stage, we do the following two steps:
                            <ul>
                                <li>Formulate <code>SUP(u)</code>
                                    <ul>
                                        <li>For inside node: <code>SUP(u) = every forth item of UP(u)</code></li>
                                        <li>For external node:
                                            <ul>
                                                <li>First stage as it becomes an external node: <code>SUP(u) = every forth item of UP(u)</code></li>
                                                <li>Second stage as it becomes an external node: <code>SUP(u) = every second item of UP(u)</code></li>
                                                <li>Third or later stage as it becomes an external node: <code>SUP(u) = UP(u)</code></li>
                                            </ul>
                                        </li>
                                    </ul>
                                </li>
                                <li>Formulate <code>NEWUP(u)</code>
                                    <ul>
                                        <li>For inside node: <code>NEWUP(u) = SUP(v) ∪ SUP(w)</code>, <code>v</code> and <code>w</code> are child nodes of node <code>u</code>
                                        </li>
                                        <li>For external node: <code>NEWUP(u) = UP(u)</code></li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li>Merge process:
                            <ul>
                                <li>Assume <code>UP(u) -> SUP(v)</code>, <code>UP(u) -> SUP(w)</code></li>
                                <li>Step1: compute <code>NEWUP(u)</code>. If <code>SUP(v) <--> SUP(w)</code>, then we can know rank of any item of <code>SUP(v)</code> or <code>SUP(w)</code> in <code>NEWUP(u)</code> by adding its ranks in <code>SUP(v)</code> and <code>SUP(w)</code></li>
                                    <ul>
                                        <li>Substep1: For each item in <code>SUP(v)</code> we compute its rank in <code>UP(u)</code>, <code>SUP(v) <--> UP(u)</code>, <code>SUP(w) <--> UP(u)</code></li>
                                        <li>Substep2: For each item in <code>SUP(v)</code> we compute its rank in <code>SUP(w)</code> by making use of <code>SUP(v) <--> UP(u)</code>, <code>SUP(w) <--> UP(u)</code></li>
                                    </ul>
                                <li>Step2: compute <code>NEWUP(u) -> NEWSUP(v)</code>, <code>NEWUP(u) -> NEWSUP(w)</code></li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/On-the-Nature-of-Merge-External-Merge-Internal-Merge-and-Parallel-Merge.pdf">On the Nature of Merge: External Merge, Internal Merge, and Parallel Merge</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>External merge takes two distinct rooted structures and joins them into one</li>
                <li>Internal merge takes a subpart of an existing structure as one of two objects</li>
                <li>Parallel merge combines the properties of both</li>
                <li>This article is extremely obscure</li>
            </td>
            <td style="text-align:left">🤷🏻</td>
            <td style="text-align:left">★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Optimizing-parallel-bitonic-sort.pdf">Optimizing parallel bitonic sort</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li><b>Given that this article was published in 1997 when CPU had only one core in most cases, so parallel algorithm need to take network communication into consideration, which no longer exists in the multi-core parallelism</b></li>
                <li>Most of the research on parallel algorithm design in the 70s and 80s has focused on fine-grain models of parallel computation, such as PRAM or network-based models</li>
                <li><code>N</code> keys will be sorted in <code>log(N)</code> stages, for each bitonic sequence of <code>i-th</code> stage contains <code>2^i</code> items, and it can be Butterfly merged in <code>i</code> steps</li>
                <li>Naive and improved data layouts
                    <ul>
                        <li>Blocked layout: mapping <code>N</code> items on <code>P</code> processors, with <code>n = N / P</code>. The first <code>log(n)</code> stages can be exected locally. For the subsequent stages <code>log(n) + k</code>, the first <code>k</code> steps require remote communication whil the last <code>log(n)</code> steps are completely local</li>
                        <li>Cyclic layout: mapping <code>N</code> items on <code>P</code> processors by assigning the <code>i-th</code> item to the <code>(i % n) % P</code> processor, with <code>n = N / P</code>. The first <code>log(n)</code> stages require remote communication. For the subsequent stages <code>log(n) + k</code>, the first <code>k</code> steps are completely local while last <code>log(n)</code> steps require remote communication</li>
                        <li>Cyclic-blocked layout: by periodically remapping the data from a blocked layout to a cyclic layout and vice verse can reduce the communication overhead</li>
                    </ul>
                </li>
                <li>Optimization communication
                    <ul>
                        <li>Absolute address(<code>log(N)</code> bits long): represents the row number of the node in the bitonic storing network</li>
                        <li>Relative address: the first <code>log(P)</code> bits represent the processor number, and the last <code>log(n)</code> bits represent the local address of the node after the remap</li>
                        <li><b>Key observation: After the first <code>log(n)</code> stages (which can be entirely executed locally under a blocked layout) the maximum number of successive steps of the bitonic sorting network that can be executed locally, under any data layout, is <code>log(n)</code> (where <code>n = N / P</code>, <code>N</code> is data size, <code>P</code> is number of processors)</b></li>
                        <li>We can thus reformulate the problem as: Given the tuple (stage, step), which uniquely identifies a column of the bitonic sorting network, how to remap the elements at this point in such a way that the next <code>log(n)</code> steps of the bitonic sorting network are executed locally</li>
                        <li><code>log(n)</code> successive steps may cross stage</li>
                        <li>The purpose of the first <code>log(n)</code> stages is to form a monotonically increasing or decreasing sequence of n keys on each processor, thus we can replace all these stages with a single, highly optimized local sort</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Parallel-Merge-Sort-with-Load-Balancing.pdf">Parallel Merge Sort with Load Balancing</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Main contribution: find a way to merge two lists, each of which is distributed in multiple processors, rather than store them on a single processor</li>
                <li>Items are merged level by level from bottom up:
                    <ul>
                        <li>Group is a set of processors that are in charge of one sorted list, the higher level, the more processors there will be</li>
                        <li>Each merge comprises two groups(partner groups), each group will maintain a histogram</li>
                        <li>Before merging, each group exchanges histograms to form a new one to cover both, and each processor then divideds the intervals of the merged histogram into <code>2 * |group|</code> parts so that the lower indexed processors will keep the smaller half, and the higher will keep the larger half. And each processor sends out the half intervals that belongs to the other processors for further merge</li>
                        <li>Key observation: for each non-overlap interval, which means amoung all the processors only one at most data set exists, no merge operation required. And for each overlap interval, k-merge or cascaded merge is required to merge the 2 or more data sets</li>
                        <li>Questions: 
                            <ul>
                                <li>How to form a histogram if there are mutilply sort keys?</li>
                                <li>How is the balance when there is data skew?</li>
                                <li>How to make sure that each processor maintain a histogram with same intervals</li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Parallelizing-fundamental-algorithms-such-as-sorting-on-multi-core-processors-for-EDA-acceleration.pdf">Parallelizing Fundamental Algorithms such as Sorting on Multi-core Processors for EDA Acceleration</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Granularity vs. Load Balancing. Fine grain has better load balancing while coarse grain has smaller overhead</li>
                <li>Parallel quick sort</li>
                <li>Parallel merge sort</li>
                <li>Parallel map sort</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/A-Simple-Fast-Parallel-Implementation-of-Quicksort-and-its-Performance-Evaluation-on-SUN-Enterprise-10000.pdf">A Simple, Fast Parallel Implementation of Quicksort and its Performance Evaluation on SUN Enterprise 10000</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Parallel quick sort has four phases:
                    <ul>
                        <li>The parallel partition of the data phase
                            <ul>
                                <li>The primary operation unit is a block, which holds a consecutive of keys</li>
                                <li>Pivot(a key) is selected by one of the processors, assuming <code>P0</code> is the selected processor</li>
                                <li>Each processor indenpendly partition its local data with the above pivot using a function called <code>neutralize</code> which takes two blocks from left and and right end as input, the process is similiar to the generic quick sort's partition in the high level. But there may be at most one block remains after partition, because <code>neutralize</code> always requires two blocks as input</li>
                            </ul>
                        </li>
                        <li>The sequential partition of the data phase
                            <ul>
                                <li><code>P0</code> works on the remaing blocks of all the processors in the similar way(<code>neutralize</code>)</li>
                                <li>Finally, we get two subarray stride across the pivot with left side small or equal to pivot, right side large or equal to pivot</li>
                            </ul>
                        </li>
                        <li>The process partition phase
                            <ul>
                                <li>Partition all processors into two groups base on the size of the subarray</li>
                                <li>Repeat the process from phase one to phase three, until every group contains only one processor</li>
                            </ul>
                        </li>
                        <li>The sequential sorting in parallel with helping phase</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Parallelization-of-Modified-Merge-Sort-Algorithm.pdf">Parallelization of Modified Merge Sort Algorithm</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Good summary of previous work</li>
            </td>
            <td style="text-align:left">👀</td>
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
                <a href="/resources/paper/Efficient-External-Sorting-in-DuckDB.pdf">[Efficient-External-Sorting-in-DuckDB]</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>The cost of sorting is dominated by comparing values and moving data around</li>
                <li>Two main ways of implementing merge sort: K-way merge and cascade merge</li>
            </td>
            <td style="text-align:left">👀</td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Merge-Path-A-Visually-Intuitive-Approach-to-Parallel-Merging.pdf">Merge Path - A Visually Intuitive Approach to Parallel Merging</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Key idea: use diagonal to cut the merge path</li>
                <li>Cache Efficiency
                    <ul>
                        <li>Three types of cache miss, compulsory, capacity, contention</li>
                        <li>Three types of associativity, full associative, direct-mapped, group-mapped</li>
                    </ul>
                </li>
                <li>Cache-efficient parallel merge
                    <ul>
                        <li>Key idea: ensure that all elements that may be active at any given time can co-reside in cache</li>
                        <li>Multi-processors process cache-size data at one iteration</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Efficient-Parallel-Merge-Sort-for-Fixed-and-Variable-Length-Keys.pdf">Efficient Parallel Merge Sort for Fixed and Variable Length Keys</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution</code></li>
                <li><code>#Sort</code></li>
            </td>
            <td style="text-align:left">
                <li>Sort algorithm classification:
                    <ul>
                        <li>Radix sort, rely on a binary representation of the sort key</li>
                        <li>Comparison sort, allow user-specified comparison function. Including quick sort, merge sort</li>
                    </ul>
                </li>
                <li>Three stages merge sort with GPU
                    <ul>
                        <li>Block sort, which can be further divided into two stages. First, each thread loads eight elements in registers and sorts them using bitonic sort. Second, merge these 8-element segments together</li>
                        <li>Merge sort-simple, two moving windows, one in register and the other in memory</li>
                        <li>Merge sort-multiple, allow CUDA blocks to cooperate in merging two sequences</li>
                    </ul>
                </li>
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
                <a href="/resources/paper/An-Overview-of-Query-Optimization-in-Relational-Systems.pdf">An Overview of Query Optimization in Relational Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Overview</code></li>
            </td>
            <td style="text-align:left">
                <li>query optimization can be viewed as a difficult search problem:
                    <ul>
                        <li>A space of plans</li>
                        <li>A cost estimation technique</li>
                        <li>An enumeration algorithm</li>
                    </ul>
                </li>
                <li>System R's enumeration algorithm comprises two important parts:
                    <ul>
                        <li>Dynamic programming to produce the optimal plan</li>
                        <li>Interesting orders, the idea of which is later generalized to physical properties</li>
                    </ul>
                </li>
                <li>Search space
                    <ul>
                        <li>Join sequences, including outerjoin and join, while outerjoin has more limitations</li>
                        <li>SPJ with group-by, group-by push down</li>
                        <li>Reducing multi-block queries to single-block:
                            <ul>
                                <li>Merging views, <code>{Q=R⋈V|V=S⋈T} -> {Q=R⋈S⋈T}</code>, then may be freely reordered</li>
                                <li>Merging nested subqueries, the generic way to process the correlated subqueries</li>
                                <li>Using semijoin like techniques for optimizating multi-block queries</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>Statistics and cost estimatio
                    <ul>
                        <li>Statistical summary is a logical property but the cost of a plan is a physical property</li>
                        <li>Histogram
                            <ul>
                                <li>Equi-depth(height) is effective for either high or low skew data</li>
                                <li>Histogram is working on single column, do not provide information on the correlations among columns. One option is to consider 2-dimensional histograms, which will cost much more space</li>
                            </ul>
                        </li>
                        <li>Sampling
                            <ul>
                                <li>Sampling is estimation of statistics, the key challenge is to limit the error in estimation</li>
                                <li>The task of estimating distinct values is provably error prone</li>
                            </ul>
                        </li>
                        <li>Propagation of statistical information through operators</li>
                        <li>Cost computation, CPU/Memory/IO/Paralleliasm</li>
                    </ul>
                </li>
                <li>Enumeration architectures
                    <ul>
                        <li>Starburst
                            <ul>
                                <li>Query Graph Model(QGM)</li>
                                <li>query rewrite phase, without cost info</li>
                                <li>plan optimization phase, with estimated cost and physical properties, properties are propagated as plans are built bottom-up</li>
                            </ul>
                        </li>
                        <li>Colcano/Cascades
                            <ul>
                                <li>Including two kinds of rules, transformation rules and implementation rules. And there is no clearly boundary between the two kinds of rules</li>
                                <li>Logical properties, physical properties and cost are used during enumeration</li>
                                <li>Use dynamic programming in a top-down way, memorization</li>
                                <li>Goal-driven</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>Beyound the fundamentals
                    <ul>
                        <li>Distributed and parallel databases, replication for physical distribution and parallelism for scale-up</li>
                        <li>User defined functions, UDF. Bring problems to cost estimation</li>
                        <li>Materialized Views</li>
                        <li>Defer generation of complete plans subject to availability of runtime information</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/The-Cascades-Framework-For-Query-Optimization.pdf">The Cascades Framework for Query Optimization</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#Framework</code></li>
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
                <li><code>#Framework</code></li>
            </td>
            <td style="text-align:left">
                <li>Framework Concepts and Components
                    <ul>
                        <li>Logical/Physical operators</li>
                        <li>Expression/ExpressionGroup</li>
                        <li>Search space</li>
                        <li>Rules</li>
                        <li>Tasks</li>
                    </ul>
                </li>
                <li>Optimize tasks
                    <ul>
                        <li>Group optimization task is for finding the cheapest plan in this group</li>
                        <li>Group exploration task is for expanding the search space</li>
                        <li>Expression optimization task</li>
                        <li>Rule application task</li>
                        <li>Input optimization task is for property enforcing, cost calculating and pruning</li>
                    </ul>
                </li>
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
                <li>Orca Architecture
                    <ul>
                        <li>Ability to run outside the database system as a stand-alone optimizer through Data eXchange Language(DXL)</li>
                        <li>Memo</li>
                        <li>Search and Job Scheduler, including three main steps: exploration, implementation, optimization</li>
                        <li>Transformations</li>
                        <li>Property Enforcement, including logical property(output columns) and physical property(sort order, distribution)</li>
                        <li>Metadata Cache</li>
                        <li>GPOS</li>
                    </ul>
                </li>
                <li>Optimization workflow
                    <ul>
                        <li>Exploration, possibly creating new group expressions and new groups into memo, such as Join Commutativity Rule/</li>
                        <li>Statistics Derivation, used to derive estimates for cardinality and data skew</li>
                        <li>Implementation, shifting from logical to physical</li>
                        <li>Optimization, properties enforcement and cost computation</li>
                    </ul>
                </li>
                <li>Parallel query optimization, task dependency</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
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
                <li>Subquery coalesce
                    <ul>
                        <li>Of same type, e.g. two exist subqueries</li>
                        <li>Of different type, e.g. exist and not exist subqueries</li>
                    </ul>
                </li>
                <li>Execution enhancements:
                    <ul>
                        <li>Cost-based parallel group-by pushdown, GPD. Short circuit by HAVING clause</li>
                    </ul>
                </li>
                <li>Subquery removal using window functions:
                    <ul>
                        <li>Correlated subsumed subquery, TPCH-Q2/Q17</li>
                        <li>Uncorrelated subsumed subquery, TPCH-Q15</li>
                        <li>Subsumed subquery in HAVING clause, TPCH-Q11</li>
                        <li>Subquery Producing a Multi-Set, MAX(MAX), MIN(MIN)</li>
                    </ul>
                </li>
                <li>Scalable parallel execution:
                    <ul>
                        <li>Grand-total window function optimization, which can be extended to low cardinality partition-by keys</li>
                    </ul>
                </li>
                <li>Null-aware anti join, NAAJ</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
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
                <li>Key idea: for every distinct value of correlated column, if the row set of the subquery and the outer block are exactly the same, then the aggregate of subquery can be replaced with a corresponding window function of outer block</li>
                <li>Conditions that are required to meet
                    <ul>
                        <li>Scalar correlated aggregation subquery with only equal predicate</li>
                        <li>Aggregate function has a corresponding version of window function</li>
                        <li>Aggregate function DO NOT contains DISTINCT</li>
                        <li>Tables of subquery and outer block are exactly the same, taking correlated outer table into account for subquery</li>
                        <li>Predicates of subquery and outer block are exactly the same, except the correlated outer table only related predicates</li>
                    </ul>
                </li>
                <li>TPCH-Q2, TPCH-Q17</li>
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
            <td style="text-align:left">
                <li>Outerjoin workloads:
                    <ul>
                        <li>Database merging, two-sided outerjoin</li>
                        <li>Hierarchical views</li>
                        <li>Nested queries</li>
                        <li>Universal quantifiers</li>
                    </ul>
                </li>
                <li>Outerjoin optimizations:
                    <ul>
                        <li>Outerjoin simplification: LOJ can be rewritten as regular join if later operator discards the null-padded tuples. And this can be extended to ROJ and FOJ</li>
                        <li>Join/Outerjoin associativity</li>
                        <li>Generalized outerjoin</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">🤷🏻</td>
            <td style="text-align:left">★★★</td>
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
            <td style="text-align:left">
                <li>A single group-by(with multi group by columns) is replaced by multi group-by in stages, interleaved with join</li>
                <li>Too few pictures to understand</li>
            </td>
            <td style="text-align:left">🤷🏻/2</td>
            <td style="text-align:left">★★</td>
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
                <a href="/resources/paper/Optimization-of-Common-Table-Expressions-in-MPP-Database-Systems.pdf">Optimization of Common Table Expressions in MPP Database Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Optimizer</code></li>
                <li><code>#CTE</code></li>
            </td>
            <td style="text-align:left">
                <li>The purpose of CTEs is to avoid re-execution of expressions referenced more than once within a query</li>
                <li>CTEs achieve two goals, making query more readable, making execution more efficient</li>
                <li>CTEs follow a producer/consumer model</li>
                <li>Chanllenges
                    <ul>
                        <li>Deadlock hazard, operator's execution order conflicts with the CTE's execution order</li>
                        <li>Enumerating inlining alternatives, determining which ones need to be inline (for example, inline to utilize index) and which ones don't</li>
                        <li>Contextualized Optimization</li>
                    </ul>
                </li>
                <li>CTE representation
                    <ul>
                        <li>CTEProducer</li>
                        <li>CTEConsumer</li>
                        <li>CTEAnchor</li>
                        <li>Sequence</li>
                        <li>For case of CTE inline, CTEAnchor is removed and CTEConsumer is replaced with the whole CTE definition</li>
                        <li>For case of CTE no-inline, CTEAnchor is replaced by Sequence operator which has the CTEProducer as its left child and the original child of the CTEAnchor as its second child</li>
                    </ul>
                </li>
                <li>Plan enumeration
                    <ul>
                        <li>Transformation rules, CTEAnchor/Sequence/NoOp in one group, CTEConsumer/CopyOfCTEDefinition in one group</li>
                        <li>Avoid invalid plans, such as CTEProducer without CTEConsumer, Sequence without CTEConsumer, NoOp with CTEConsumer(inlined)</li>
                        <li>Optimization, predicate push down, always inline single-use CTEs, elimination of unused CTEs</li>
                    </ul>
                </li>
                <li>Contextualized optimization
                    <ul>
                        <li>In ORCA, CTEs are considered later after regular optimization is done</li>
                        <li>Enforcing physical properties, pushing the CTEConsumer's distribution requirement to the CTEProducer</li>
                        <li>Cost Estimation</li>
                    </ul>
                </li>
                <li>CTE based optimizations
                    <ul>
                        <li>CTE-Generating transformations, such as two count(distinct)</li>
                        <li>Common subexpression elimination</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
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
                <a href="/resources/paper/Robust-and-efficient-memory-management-in-Apache-AsterixDB.pdf">Robust and efficient memory management in Apache AsterixDB</a>
            </td>
            <td style="text-align:left">
                <li><code>#Memory</code></li>
            </td>
            <td style="text-align:left">
                <li>AsterixDB has three main memory sections, including one for in-memory components, a buffer cache, and working memory</li>
                <li>Each operator has three memory sections, including input buffer, execution memory, output buffer</li>
                <li>The budget for a memory-intensive operator is determined by operator-specific parameters (eg, 32 MB) and the system converts the budget into a number of pages (M) using the system's page size parameter. This means the memory-intensive operator can request M pages from the working memory at maximum and uses these pages as its execution memory</li>
                <li>Sort operator
                    <ul>
                        <li>Since comparing normalized binary-representations of field values is more efficient than comparing the original values, the concept of normalized key has been widely used</li>
                        <li>Also, rather than moving an actual record during a sort, normally an array of record pointers is used in most implementations to deal with variable-length records</li>
                        <li>An external sort consists of two phases, build and merge. In build phase, the operator gradually allocates more pages to hold incoming records until the buget is exhausted, then sorts it and writes it to a temporary run file on disk, and then continute to process the follow-up incoming data. In merge phase, the operator recursively multiway merges run files and generates the final results</li>
                        <li>The sort operator also uses an additional data structure called the record pointer array that contains the location and the normalized key of each record in memory. This array is needed to avoid performing an in-place swap between two records during in-memory sorting since each record's length is generally different because of variable-length fields. Also, this array can improve the performance since comparing two normalized keys in the record pointer array using binary string comparison can be much faster than comparing the actual values between two records, which requires accessing the actual records in pages</li>
                    </ul>
                </li>
                <li>Group-by operator
                    <ul>
                        <li>Group-by operator use both data partition table abd hash table. Data partition table holds the aggregate records. Hash table holds the localtion of the aggregate records in the data partition table(can be seen as index)</li>
                    </ul>
                </li>
                <li>Hash join operator
                    <ul>
                        <li>In AsterixDB, the hash join and the hash group-by operators use very similar table structures</li>
                    </ul>
                </li>
                <li>Inverted-index search
                    <ul>
                        <li>In AsterixDB, inverted-index is used to perform key word search</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/Chap6</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/An-Overview-of-Data-Warehousing-and-OLAP-Technology.pdf">An Overview of Data Warehousing and OLAP Technology</a>
            </td>
            <td style="text-align:left">
                <li><code>#Overview</code></li>
                <li><code>#Warehousing</code></li>
            </td>
            <td style="text-align:left">
                <li>Maximizing transaction throughput is the key performance metric to OLTP</li>
                <li>Query throughput and response times of ad hoc/complex queries is the key performance metric to OLAP</li>
                <li>Features
                    <ul>
                        <li>Multi dimensions</li>
                        <li>Multi sources might contains data of varying quality, or use inconsistent representations, codes and formats</li>
                        <li>Rollup, increasing the level of aggregation</li>
                        <li>Drill-down, decreasing the level of aggregation or increasing detail</li>
                    </ul>
                </li>
                <li>Extracting/Cleaning/Transforming/Loading</li>
                <li>Refresh through replication techniques, including data shipping and transaction shipping</li>
                <li>Database design methodology
                    <ul>
                        <li>Star schema, consists of a single fact table and a single table for each dimension</li>
                        <li>Snowfalke schema, based on the star schema, where the dimensional hierarchy is explicitly represented by normalizing the dimension tables</li>
                    </ul>
                </li>
                <li>Warehouse server
                    <ul>
                        <li>Index structures</li>
                        <li>Materialized views</li>
                        <li>Transformation of complex queries</li>
                        <li>Parallel processing</li>
                    </ul>
                </li>
                <li>Metadata and warehouse management</li>
            </td>
            <td style="text-align:left">✅</td>
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
                        <li>Filter conditions including source tables, hubs, output columns, output expressions, range constraints, residual constraints, grouping columns, grouping expressions</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
    </tbody>
</table>

## 1.1 DSPS

Data Stream Processing System, DSPS

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
                <a href="/resources/paper/A-Survey-of-Distributed-Data-Stream-Processing-Frameworks.pdf">A Survey of Distributed Data Stream Processing Frameworks</a>
            </td>
            <td style="text-align:left">
                <li><code>#Survey</code></li>
            </td>
            <td style="text-align:left">
                <li>Batch Processing
                    <ul>
                        <li>Latency, cannot process until all data is loaded</li>
                    </ul>
                </li>
                <li>Architecture of Data Stream Processing System(DSPS)
                    <ul>
                        <li>Data stream ingestion layer, responsible for accepting streams of data into the DSPS
                            <ul>
                                <li>Scalable</li>
                                <li>Resilient</li>
                                <li>Fault-tolerant</li>
                            </ul>
                        </li>
                        <li>Data stream processing layer, data stream processing engine (DSPE),which pre-processes and analyses data in one or more steps,
                            <ul>
                                <li>Data stream management engines, DSME, and the followings are the requirements that should be met
                                    <ul>
                                        <li>Process continuous data on-the-fly without any requirement to store them</li>
                                        <li>Support high-level languages such as SQL</li>
                                        <li>Handle imperfections such as delayed, missing and out-of-order data</li>
                                        <li>Guarantee predictable and repeatable outcomes</li>
                                        <li>Efficiently store, access, modify, and combine (with live streaming data) state information</li>
                                        <li>Ensure that the integrity of the data is maintained at all times and relevant applications are up and available despite failures</li>
                                        <li>Automatically and transparently distribute the data processing load across multiple processors and machines</li>
                                        <li>Respond to high-volume data processing applications in real-time using a highly optimized execution path</li>
                                    </ul>
                                </li>
                                <li>Complex event processing engines, CEPE</li>
                                <li>General-purpose DSPEs, GDSPE</li>
                            </ul>
                        </li>
                        <li>Storage layer, which stores, indexes and manages the data and the generated knowledge
                            <ul>
                                <li>Organized</li>
                                <li>Indexed</li>
                                <li>Metadata</li>
                            </ul>
                        </li>
                        <li>Resource management layer, which manages and coordinates the functions of distributed compute and storage resources
                            <ul>
                                <li>Resource allocation</li>
                                <li>Resource scheduling</li>
                                <li>Server as a coordinator</li>
                            </ul>
                        </li>
                        <li>Output layer, which directs the output data stream and knowledge to other systems or visualization tools</li>
                    </ul>
                </li>
                <li>Key features of DSPEs
                    <ul>
                        <li>Programming models, given the unbounded nature of streaming data
                            <ul>
                                <li>A window is usually defined by either a time duration or a record count. There are many window types: Fixed/Sliding/Session Window</li>
                                <li>Stateless transformations: Map, Filter, FlatMap</li>
                                <li>Stateful transformations: Aggregation, Group-and-aggregate, Join, Sort</li>
                            </ul>
                        </li>
                        <li>Data source interaction model
                            <ul>
                                <li>Push model where a daemon process of a data stream engine keeps listening to an input channel</li>
                                <li>Pull model, A challenge here is that the frequency of pulling and the speed of processing the data by the DSPEs should match the rate of data generation at the source to avoid data loss</li>
                            </ul>
                        </li>
                        <li>Data partitioning strategy
                            <ul>
                                <li>Horizontal method divides data into disjoint sets of rows
                                    <ul>
                                        <li>Round-robin</li>
                                        <li>Range, which is the most popular approach especially when there is a periodic loading of a new data</li>
                                        <li>Hash</li>
                                    </ul>
                                </li>
                                <li>The vertical method divides data into vertical and disjoint sets of columns and can be categorized further into cost-based and procedural approaches</li>
                            </ul>
                        </li>
                        <li>State management
                            <ul>
                                <li>Operators can be stateless or stateful</li>
                                <li>In traditional DSPEs, the state information was stored in a centralized database management system to be shared among applications</li>  
                                <li>The state management facilities in various DSPEs naturally fall along a complexity continuum from naive in-memory-only choice to a persistent state that can be queried and replicated</li>                              
                            </ul>
                        </li>
                        <li>Message processing guarantee, such as at-most-once, at-least-once, exactly once</li>
                        <li>Fault tolerance and recovery
                            <ul>
                                <li>Passive, such as checkpoint, upstream buffer, source replay</li>
                                <li>Active, such as replicas</li>
                            </ul>
                        </li>
                        <li>Deployment, such as local, cluster, cloud</li>
                        <li>Community support, such as forums, meetups and others</li>
                        <li>Support for high level languages, such as java, scala, python, r, sql</li>
                        <li>Support for advanced input sources, such as local file systems, socket connections, databases, queuing tools</li>
                        <li>Support for storage systems</li>
                        <li>Support for analytics</li>
                    </ul>
                </li>
                <li>Popular products:
                    <ul>
                        <li>Flink</li>
                        <li>Samza</li>
                        <li>Apex</li>
                        <li>Storm</li>
                        <li>Spark Streaming</li>
                        <li>StreamBase</li>
                        <li>IBM Streams</li>
                        <li>Kafka Streams</li>
                        <li>Google Dataflow</li>
                        <li>Beam</li>                        
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/A-Survey-of-State-Management-in-Big-Data-Processing-Systems.pdf">A Survey of State Management in Big Data Processing Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Survey</code></li>
            </td>
            <td style="text-align:left">
                <li>First proposals for parallel batch-oriented data processing, BDP, was MapReduce
                    <ul>
                        <li>Advantages: flexibility, fault-tolerance, programming ease, scalability</li>
                        <li>Disadvantages: a low-level programming model, a lack of support for iterations, inability to deal with data streams</li>
                    </ul>
                </li>
                <li>State: a sequence of values in time that contain the intermediate results of a desired computation</li>
                <li>Concepts of State Management
                    <ul>
                        <li>Operations
                            <ul>
                                <li>Purge</li>
                                <li>Update</li>
                                <li>Store
                                    <ul>
                                        <li>On disk</li>
                                        <li>In-memory</li>
                                    </ul>
                                </li>
                                <li>Migrate</li>
                                <li>Expose</li>
                            </ul>
                        </li>
                        <li>Incremental Maintenance
                            <ul>
                                <li>Transformation</li>
                                <li>Differential Computation</li>
                                <li>View Maintenance</li>
                            </ul>
                        </li>
                        <li>State Sharing
                            <ul>
                                <li>Shared Operator State</li>
                                <li>Shared Window</li>
                                <li>Shared Queue</li>
                            </ul>
                        </li>
                        <li>Load Balancing & Elasticity
                            <ul>
                                <li>Scalability</li>
                                <li>Load Balancing</li>
                                <li>Elasticity</li>
                            </ul>
                        </li>
                        <li>Performance
                            <ul>
                                <li>Optimal Placement</li>
                                <li>Optimal Assignment</li>
                                <li>Checkpoint Interval</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>Applications of State
                    <ul>
                        <li>Stateful Computation
                            <ul>
                                <li>Operator Level</li>
                                <li>Application Level</li>
                            </ul>
                        </li>
                        <li>Iterative Processing
                            <ul>
                                <li>Incremental Iteration</li>
                                <li>Bulk Iteration</li>
                            </ul>
                        </li>
                        <li>Fault Tolerance
                            <ul>
                                <li>Correlated Checkpoint</li>
                                <li>Incremental Checkpoint</li>
                                <li>Indenpendent Checkpoint</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>State in different views
                    <ul>
                        <li>System View: Configguration State, Conputation State</li>
                        <li>Application View: Query State, Program State</li>
                        <li>Programming View: Window State, Variable State</li>
                        <li>Operator View: Processing State, Routing State, Buffer State</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/3.1.2p</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/A–Survey-on–the-Evolution-of-Stream-Processing-Systems.pdf">A Survey on the Evolution of Stream Processing Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Survey</code></li>
            </td>
            <td style="text-align:left">
                <li></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
    </tbody>
</table>

## 1.2 LakeHouse

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
                <a href="/resources/paper/Lakehouse-A-New-Generation-of-Open-Platforms-that-Unify-Data-Warehousing-and-Advanced-Analytics.pdf">Lakehouse: A New Generation of Open Platforms that Unify Data Warehousing and Advanced Analytics</a>
            </td>
            <td style="text-align:left">
                <li><code>#Survey</code></li>
            </td>
            <td style="text-align:left">
                <li>Warehouse' problems
                    <ul>
                        <li>Reliability: Keeping the data lake and warehouse consistent is difficult and costly</li>
                        <li>Data staleness</li>
                        <li>Limited support for advanced analytics</li>
                    </ul>
                </li>
                <li>Goals of Lakehouse Architecture
                    <ul>
                        <li>Reliable data management on data lakes</li>
                        <li>Support for machine learning and data science, i.e. Declarative DataFrame APIs</li>
                        <li>SQL performance</li>
                    </ul>
                </li>
                <li>Lakehouse Architecture: Based on low-cost and directly-accessible storage that also provides traditional analytical DBMS management and performance features such as ACID transactions, data versioning, auditing, indexing, caching, and query optimization
                    <ul>
                        <li>Metadata Layers for Data Management
                            <ul>
                                <li>Defines which objects are part of a table version</li>
                                <li>Provide atomic operation, transaction, zero-copy(provide high-level organization, like table, based on the exsiting storage)</li>
                                <li>Provide data quality enforcement feature</li>
                                <li>Provide governance features such as access control and audit logging</li>
                                <li>Speed up advanced analytics workloads and give them better data management features thanks to the development of declarative DataFrame APIs</li>
                                <li>Both Delta Lake(Databricks), Apache Iceberg, Apache Hudi have implemented this feature</li>
                            </ul>
                        </li>
                        <li>SQL Performance in a Lakehouse
                            <ul>
                                <li>Caching, storing hot data on fast devices such as SSDs</li>
                                <li>Auxiliary data, like statistics and indexes</li>
                                <li>Data layout</li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Photon-A-Fast-Query-Engine-for-Lakehouse-Systems.pdf">Photon: A Fast Query Engine for Lakehouse Systems</a>
            </td>
            <td style="text-align:left">
                <li><code>#Execution Engine</code></li>
            </td>
            <td style="text-align:left">
                <li>Challenges of Photon's design
                    <ul>
                        <li>Perform well on raw, uncurated data, which are highly irregular datasets, poor physical layout, and large fields, all with no useful clustering or data statistics</li>
                        <li>Semantically compatible with, the existing Apache Spark DataFrame API</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/Dremel-Interactive-Analysis-of-Web-Scale-Datasets.pdf">Dremel: Interactive Analysis of Web-Scale Datasets</a>
            </td>
            <td style="text-align:left">
                <li><code>#Format</code></li>
                <li><code>#Parquet</code></li>
            </td>
            <td style="text-align:left">
                <li>Key Points
                    <ul>
                        <li>Goal: Enable fast, interactive analysis (e.g., SQL-like queries) on datasets with trillions of records or petabytes of data</li>
                        <li>Columnar Storage: Dremel uses a column-oriented storage format, which allows it to read only the necessary data for a query, significantly improving performance compared to row-based systems</li>
                        <li>Tree Architecture: Dremel employs a multi-level serving tree to distribute and aggregate queries efficiently. This structure is inspired by systems like Google's web search architecture</li>
                        <li>Nested Data Support: Dremel introduces a method for processing nested, structured data (like Protocol Buffers) efficiently in a columnar format, using a special encoding called record shredding</li>
                        <li>Scalability: It scales to thousands of nodes and has been used on production datasets at Google containing trillions of records</li>
                        <li>Performance: Dremel achieves interactive speeds for most queries, making it ideal for data exploration and analysis</li>
                        <li>Applications: Used internally at Google for analyzing logs, crawling data, and monitoring systems. It also influenced the design of BigQuery, Google's cloud-based data warehouse service</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
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
                <li>support SUPER value, typeless, can hold anything(int, double, array, json, etc.)</li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
    </tbody>
</table>

# 3 Compile Tech

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
                <a href="https://www.researchgate.net/profile/Terence-Parr/publication/273188534_Adaptive_LL_Parsing_The_Power_of_Dynamic_Analysis/links/58b85f9745851591c5d7fd18/Adaptive-LL-Parsing-The-Power-of-Dynamic-Analysis.pdf">Adaptive LL (*) parsing: the power of dynamic analysis</a>
            </td>
            <td style="text-align:left">
                <li><code>#LL</code></li>
            </td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
            <td style="text-align:left"></td>
        </tr>
    </tbody>
</table>

# 4 Cpp

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
                <a href="/resources/paper/Shared-Memory-Consistency-Models-A-Tutorial.pdf">Shared Memory Consistency Models: A Tutorial</a>
            </td>
            <td style="text-align:left">
                <li><code>#Memory Model</code></li>
            </td>
            <td style="text-align:left">
                <li>Effectively, the consistency model places restrictions on the values that can be returned by a read in a shared-memory program execution</li>
                <li>Memory consistency model will affect programmability, performance, and portability at several different levels</li>
                <li>Sequential consistency
                    <ul>
                        <li>A multiprocessor system is sequentially consistent if the result of any execution is the same as if the operations of all the processors were executed in some sequential order, and the operations of each individual processor appear in this sequence in the order specified by its program</li>
                        <li>Seems like each processor issues memory operations in program order and the switch provides the global serialization among all memory operations</li>
                    </ul>
                </li>
                <li>Implementing sequential consistency
                    <ul>
                        <li>Architectures without caches
                            <ul>
                                <li>Write buffers with bypassing capability(hardware optimization), which used in uniprocessors to effectively hide the latency of write operations, but this hardware optimization may violate sequential consistency</li>
                                <li>Overlapping Write Operations(hardware optimization), which allows multiple write operations issued by the same processor may be simultaneously serviced by different memory modules(may let write operations be reordered). And this kind of hardware optimization may violate sequential consistency</li>
                                <li>Non-blocking read operations(hardware optimization)</li>
                            </ul>
                        </li>
                        <li>Architectures with caches
                            <ul>
                                <li>Cache coherence and sequential consistency
                                    <ul>
                                        <li>Several definitions for cache coherence (also referred to as cache consistency) exist in the literature. The strongest definitions treat the term virtually as a synonym for sequential consistency</li>
                                        <li>Specifically, one set of conditions commonly associated with a cache coherence protocol are
                                            <ul>
                                                <li>A write is eventually made visible to all processors</li>
                                                <li>Writes to the same location appear to be seen in the same order by all processors (also referred to as serialization of writes to the same location)</li>
                                            </ul>
                                        </li>
                                    </ul>
                                </li>
                                <li>Detecting the completion of write operations
                                    <ul>
                                        <li>Maintaining the program order from a write to a following operation typically requires an acknowledgement response to signal the completion of the write</li>
                                        <li>This problem can be avoided by leting the following operation wait for the current write operation finishing its invalidation or updating processing</li>
                                    </ul>
                                </li>
                                <li>Maintaining the illusion of atomicity for writes
                                    <ul>
                                        <li>While sequential consistency requires memory operations to appear atomic or instantaneous, propagating changes to multiple cache copies is inherently a non-atomic operation</li>
                                        <li>Sequential consistency can be easily volatiled if two write operations reaching other processors in different order(when delivering updating message from write processor to others, time may differ duo to different paths). The violation can be avoided by imposing the condition that writes to the same location be serialized; i.e., all processors see writes to the same location in the same order. Such serialization can be achieved if all updates or invalidates for a given location originate from a single point (e.g., the directory) and the ordering of these messages between a given source and destination is preserved by the network. An alternative is to delay an update or invalidate from being sent out until any updates or invalidates that have been issued on behalf of a previous write to the same location are acknowledged</li>
                                        <li>And here comes another problem, one processor may see the newly value of write A, but not write B. One possible restriction that prevents such a violation is to prohibit a read from returning a newly written value until all cached copies have acknowledged the receipt of the invalidation or update messages generated by the write</li>
                                        <li>Update-based protocols are more challenging because unlike invalidations, updates directly supply new values to other processors. One solution is to employ a two phase update scheme
                                            <ul>
                                                <li>The first phase involves sending updates to the processor caches and receiving acknowledgements for these updates. In this phase, no processor is allowed to read the value of the updated location</li>
                                                <li>In the second phase, a confirmation message is sent to the updated processor caches to confirm the receipt of all acknowledgements. A processor can use the updated value from its cache once it receives the confirmation message from the second phase</li>
                                            </ul>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li>Compilers
                            <ul>
                                <li>The interaction of the program order aspect of sequential consistency with the compiler is analogous to that with the hardware</li>
                                <li>Compiler optimizations can also volatile sequential consistency. For example, keep reading value from a register(loop situation) can prohibit processor from ever observing the newly written value from shared memory</li>
                                <li>Compiler need information to apply all the optimizations properly without unexpectedly volatiling sequential consistency</li>
                            </ul>
                        </li>
                        <li>Summary for sequential consistency
                            <ul>
                                <li>From the above discussion, it is clear that sequential consistency constrains many common hardware and compiler optimizations. Straightforward hardware implementations of sequential consistency typically need to satisfy the following two requirements
                                    <ul>
                                        <li>First, a processor must ensure that its previous memory operation is complete before proceeding with its next memory operation in program order. We call this requirement the program order requirement. Determining the completion of a write typically requires an explicit acknowledgement message from memory. Additionally, in a cache-based system, a write must generate invalidate or update messages for all cached copies, and the write can be considered complete only when the generated invalidates and updates are acknowledged by the target caches</li>
                                        <li>The second requirement pertains only to cache-based systems and concerns write atomicity. It requires that writes to the same location be serialized (i.e., writes to the same location be made visible in the same order to all processors) and that the value of a write not be returned by a read until all invalidates or updates generated by the write are acknowledged (i.e., until the write becomes visible to all processors). We call this the write atomicity requirement</li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>Relaxed memory models
                    <ul>
                        <li>Characterizing different memory consistency models
                            <ul>
                                <li>We categorize relaxed memory consistency models based on two key characteristics:
                                    <ul>
                                        <li>how they relax the program order requirement, we distinguish models based on whether they relax the order from read-read, read-write, write-read, write-write. In all cases, relaxation only applies to operation pairs with different addresses</li>
                                        <li>how they relax the write atomicity requirement, we distinguish models based on whether they allow a read to return the value of another processor's write before all cached copies of the accessed location receive the invalidation or update messages generated by the write; i.e., before the write is made visible to all other processors</li>
                                    </ul>
                                </li>
                                <li>Relaxations:
                                    <ul>
                                        <li>Relax Write to Read program order</li>
                                        <li>Relax Write to Write program order</li>
                                        <li>Relax Read to Read and Read to Write program orders</li>
                                        <li>Read others' write early</li>
                                        <li>Read own write early</li>
                                    </ul>
                                </li>
                                <li>Relaxed models(Figure 8): SC/IBM 370/TSO, Total Store Ordering/PC, Processor Consistency/PSO, Partial Store Ordering/WO, Weak Ordering/RCsc, RCpc, Release Consistency/Alpha/RMO, Relaxed Memory Order/PowerPC</li>
                            </ul>
                        </li>
                        <li>Relaxing the write to read program order
                            <ul>
                                <li>Relaxing the program order constraints in the case of a write followed by a read to a different location. But for same location, reorder is not allowed</li>
                                <li>Models, including IBM 370, TSO, PC, offer this kind of relaxation. More specifically, allowing a read to be reordered with respect to previous writes from the same processor. But there exists some differences between the above three models when it comes to same location:
                                    <ul>
                                        <li>IBM 370 model prohibits a read from returning the value of a write to the same location before the write is made visible to all processors</li>
                                        <li>TSO model allows a read to return the value of its own processor's write even before the write is serialized with respect to other writes to the same location</li>
                                        <li>PC model allows a read can return the value of any write before the write is serialized or made visible to other processors</li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                        <li>Relaxing the write to read and write to write program orders
                            <ul>
                                <li>This kind further relaxing the program order requirement by eliminating ordering constraints between writes to different locations</li>
                                <li>PSO offers this kind of relaxation</li>
                            </ul>
                        </li>
                        <li>Relaxing all program orders
                            <ul>
                                <li>Further, a read or write operation may be reordered with respect to a following read or write to a different location</li>
                                <li>Models, including WO, RCsc/RCpc, Alpha, RMO, PowerPC, offer this kind of relaxation</li>
                                <li>In hardware, this flexibility provides the possibility of hiding the latency of read operations by implementing true non-blocking reads in the context of either static (in-order) or dynamic (out-of-order) scheduling processors</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>An alternate abstraction for relaxed memory models
                    <ul>
                        <li>The higher performance is accompanied by a higher level of complexity for programmers. Furthermore, the wide range of models supported by different systems requires programmers to deal with various semantics that differ in subtle ways and complicates the task of porting programs across these systems</li>
                        <li>Instead of exposing performance-enhancing optimizations directly to the programmer as is done by a systemcentric specification, a programmer-centric specification requires the programmer to provide certain information about the program. This information is then used by the system to determine whether a certain optimization can be applied without violating the correctness of the program</li>
                        <li>An operation must be defined as a synchronization operation if it forms a race with another operation in any sequentially consistent execution; other operations can be defined as data. An operation may be conservatively distinguished as a synchronization operation if the programmer is not sure whether the particular operation is involved in a race or not</li>
                        <li>Conveying information at the pogramming language level(through grammar, paradigm or lib). The information conveyed at the programming language level must ultimately be provided to the underlying hardware. Therefore, the compiler is often responsible for appropriately translating the higher level information to a form that is supported by the hardware</li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">✅</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
        <tr>
            <td style="text-align:left">
                <a href="/resources/paper/What-Every-Programmer–Should-Know-About-Memory.pdf">What Every Programmer Should Know About Memory</a>
            </td>
            <td style="text-align:left">
                <li><code>#Memory Model</code></li>
            </td>
            <td style="text-align:left">
                <li>Commodity hardware
                    <ul>
                        <li>All CPUs are connected via a common bus (the Front Side Bus, FSB) to the Northbridge</li>
                        <li>The Northbridge contains, among other things, the memory controller, and its implementation determines the type of RAM chips used for the computer</li>
                        <li>To reach all other system devices, the Northbridge must communicate with the Southbridge. The Southbridge, often referred to as the I/O bridge, handles communication with devices through a variety of different buses(PCI/PCI Express, SATA, USB buses, etc.)</li>
                        <li>Such a system structure has a number of noteworthy consequences
                            <ul>
                                <li>All data communication from one CPU to another must travel over the same bus used to communicate with the Northbridge</li>
                                <li>All communication with RAM must pass through the Northbridge</li>
                                <li>Communication between a CPU and a device attached to the Southbridge is routed through the Northbridge</li>
                            </ul>
                        </li>
                        <li>A couple of bottlenecks are immediately apparent in this design
                            <ul>
                                <li>One such bottleneck involves access to RAM for devices. In the earliest days of the PC, all communication with devices on either bridge had to pass through the CPU, negatively impacting overall system performance. To work around this problem some devices became capable of direct memory access (DMA). DMA allows devices, with the help of the Northbridge, to store and receive data in RAM directly without the intervention of the CPU (and its inherent performance cost). Today all high-performance devices attached to any of the buses can utilize DMA</li>
                                <li>A second bottleneck involves the bus from the Northbridge to the RAM. The exact details of the bus depend on the memory types deployed. On older systems there is only one bus to all the RAM chips, so parallel access is not possible. Recent RAM types require two separate buses (or channels as they are called for DDR2) which doubles the available bandwidth</li>
                            </ul>
                        </li>
                        <li>RAM types
                            <ul>
                                <li>Static RAM</li>
                                <li>Dynamic RAM</li>
                            </ul>
                        </li>
                    </ul>
                </li>
                <li>CPU caches
                    <ul>
                        <li>So, instead of putting the SRAM under the control of the OS or user, it becomes a resource which is transparently used and administered by the processors</li>
                        <li>In this mode, SRAM is used to make temporary copies of (to cache, in other words) data in main memory which is likely to be used soon by the processor. This is possible because program code and data has temporal and spatial locality. This means that, over short periods of time, there is a good chance that the same code or data gets reused</li>
                        <li>Realizing that locality exists is key to the concept of CPU caches as we use them today</li>
                        <li>CPU caches in the big picture
                            <ul>
                                <li>The CPU core is no longer directly connected to the main memory if cache system is deployed. All loads and stores have to go through the cache</li>
                                <li>It is of advantage to separate the caches used for code and for data. In recent years another advantage emerged: the instruction decoding step for the most common processors is slow; caching decoded instructions can speed up the execution</li>
                            </ul>
                        </li>
                        <li>Cache operation at high level
                            <ul>
                                <li>Exclusive cache(AMD/VIA), where each line in L1d may not present in L2. Inclusive cache(Intel), where each line in L1d also present in L2, makes evicting from L1d is much faster</li>
                                <li>In symmetric multi-processor (SMP) systems the caches of the CPUs cannot work independently from each other. All processors are supposed to see the same memory content at all times. The maintenance of this uniform view of memory is called “cache coherency”</li>
                                <li>Today's processors all use internal pipelines of different lengths where the instructions are decoded and prepared for execution. Part of the preparation is loading values from memory (or cache) if they are transferred to a register. If the memory load operation can be started early enough in the pipeline, it may happen in parallel with other operations and the entire cost of the load might be hidden</li>
                            </ul>
                        </li>
                        <li>CPU cache implementation details
                            <ul>
                                <li>Cache implementers have the problem that each cell in the huge main memory potentially has to be cached</li>
                                <li>
                                    <ul>
                                        <li>Associativity
                                            <ul>
                                                <li>It would be possible to implement a cache where each cache line can hold a copy of any memory location. This is called a fully associative cache. To access a cache line the processor core would have to compare the tags of each and every cache line with the tag for the requested address. Fully associative caches are practical for small caches(for instance, the TLB caches on some Intel processors are fully associative)</li>
                                                <li>A direct-mapped cache is fast and relatively easy to implement. But it has a drawback: it only works well if the addresses used by the program are evenly distributed with respect to the bits used for the direct mapping, some cache entries are heavily used and therefore repeated evicted while others are hardly used at all or remain empty</li>
                                                <li>A set-associative cache combines the good features of the full associative and direct-mapped caches to largely avoid the weaknesses of those designs</li>
                                            </ul>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                        </li>
                    </ul>
                </li>
            </td>
            <td style="text-align:left">👀/P20</td>
            <td style="text-align:left">★★★★★</td>
        </tr>
    </tbody>
</table>

# 5 TODO

* Survey
    * [Query Evaluation Techniques for Large Databases](https://cgi.cse.unsw.edu.au/~cs9315/20T1/readings/query.pdf)
* Optimization
    * SubQuery
        * [Reusing Invariants: A New Strategy for Correlated Queries](https://dl.acm.org/doi/pdf/10.1145/276304.276309)
        * [On Optimizing an SQL-like Nested Query](https://dl.acm.org/doi/pdf/10.1145/319732.319745)
    * Group-by
        * [Including group-by in query optimization](https://www.vldb.org/conf/1994/P354.PDF)
        * [Eager aggregation and lazy aggregation](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.50.7294&rep=rep1&type=pdf)
        * [Aggregate-query processing in data warehousing environments](http://ilpubs.stanford.edu:8090/101/1/1995-33.pdf)
        * [Optimizing queries with aggregate views](https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.28.8212&rep=rep1&type=pdf)
    * [Implementation of Two Semantic Query Optimization Techniques in DB2 Universal Database](https://www.researchgate.net/profile/Jarek-Gryz/publication/221309776_Implementation_of_Two_Semantic_Query_Optimization_Techniques_in_DB2_Universal_Database/links/0912f51279e7662532000000/Implementation-of-Two-Semantic-Query-Optimization-Techniques-in-DB2-Universal-Database.pdf)
* Execution
    * Vectorization
        * [Filter Representation in Vectorized Query Execution](https://dl.acm.org/doi/abs/10.1145/3465998.3466009)
    * Parallel
        * [Managing Intra-operator Parallelism in Parallel Database Systems](/resources/paper/Managing-Intra-operator-Parallelism-in-Parallel-Database-Systems.pdf)
    * Join
        * [The Complete Story of Joins (in HyPer)](https://www.btw2017.informatik.uni-stuttgart.de/slidesandpapers/F1-10-37/paper_web.pdf)
        * [Adaptive Optimization of Very Large Join Queries](https://dsl.cds.iisc.ac.in/~course/TIDS/papers/hugejoins_SIGMOD2018.pdf)
        * [Optimizing main-memory join on modern hardware](https://ieeexplore.ieee.org/abstract/document/1019210/)
        * [Massively Parallel Sort-Merge Joins in Main Memory Multi-Core Database Systems](/resources/paper/Massively-Parallel-Sort-Merge-Joins-in-Main-Memory-Multi-Core-Database-Systems.pdf)
        * [Main-Memory Hash Joins on Multi-Core CPUs Tuning to the Underlying Hardware](/resources/paper/Main-Memory-Hash-Joins-on-Multi-Core-CPUs-Tuning-to-the-Underlying-Hardware.pdf)
        * [Massively Parallel NUMA-aware Hash Joins](/resources/paper/Massively-Parallel-NUMA-aware-Hash-Joins.pdf)
        * [An Experimental Comparison of Thirteen Relational Equi-Joins in Main Memory](/resources/paper/An-Experimental-Comparison-of-Thirteen-Relational-Equi-Joins-in-Main-Memory.pdf)
    * Sort
        * [Merge Path - Parallel Merging Made Simple](/resources/paper/Merge-Path-Parallel-Merging-Made-Simple.pdf)
        * [Efficient Computation of Frequent and Top-k Elements in Data Streams](/resources/paper/Efficient-Computation-of-Frequent-and-Top-k-Elements-in-Data-Streams.pdf)
        * [Design and Evaluation of Main Memory Hash Join Algorithms for Multi-core CPUs](/resources/paper/Design-and-Evaluation-of-Main-Memory-Hash-Join-Algorithms-for-Multi-core-CPUs.pdf)
        * [Sort vs. Hash Revisited Fast Join Implementation on Modern Multi-Core CPUs](/resources/paper/Sort-vs.-Hash-Revisited-Fast-Join-Implementation-on-Modern-Multi-Core-CPUs.pdf)
        * [Implementing Sorting in Database Systems](http://lgis.informatik.uni-kl.de/archiv/wwwdvs.informatik.uni-kl.de/courses/DBSREAL/SS2005/Vorlesungsunterlagen/Implementing_Sorting.pdf)
        * [Sort vs. Hash Revisited: Fast Join Implementation on Modern Multi-Core CPUs](http://www.kaldewey.com/pubs/Sort_vs_Hash__VLDB09.pdf)
        * 《Fast multi-column sorting in main-memory column-stores》
        * [BlockQuicksort: Avoiding Branch Mispredictions in Quicksort](https://kclpure.kcl.ac.uk/portal/files/123577916/BlockQuicksort_Avoiding_Branch_Mispredictions_EDELKAMP_PublishedAugust2016_VoR_CC_BY_.pdf)
        * [Efficient Implementation of Sorting on Multi-Core SIMD CPU Architecture](/resources/paper/Efficient-Implementation-of-Sorting-on-Multi-Core-SIMD-CPU-Architecture.pdf)
        * [A Comparative Study of Parallel Sort Algorithms](/resources/paper/A-Comparative-Study-of-Parallel-Sort-Algorithms.pdf)
        * [Fast Segmented Sort on GPUs](https://dl.acm.org/doi/pdf/10.1145/3079079.3079105)
    * CodeGen
        * [Exploiting Code Generation for Efficient LIKE Pattern Matching](/resources/paper/Exploiting-Code-Generation-for-Efficient-LIKE-Pattern-Matching.pdf)
* Memory
    * [Efficient Use of Memory Bandwidth to Improve Network Processor Throughput](http://www.cs.ucr.edu/~bhuyan/cs162/LECTURE12b.pdf)
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
* MV
    * [Implementing Data Cubes Efficiently](/resources/paper/Implementing-Data-Cubes-Efficiently.pdf)
    * [Incremental Processing with Change Queries in Snowflake](/resources/paper/Incremental-Processing-with-Change-Queries-in-Snowflake.pdf)
    * [Automated Generation of Materialized Views in Oracle](/resources/paper/Automated-Generation-of-Materialized-Views-in-Oracle.pdf)
* Consensus Algorithm
    * [In Search of an Understandable Consensus Algorithm](/resources/paper/In-Search-of-an-Understandable-Consensus-Algorithm.pdf)
* Other DBMS
    * Oracle
        * [Automatic SQL Tuning in Oracle 10g](/resources/paper/Automatic-SQL-Tuning-in-Oracle-10g.pdf)
        * [Optimizer Plan Change Management: Improved Stability and Performance in Oracle 11g](/resources/paper/Optimizer-Plan-Change-Management-Improved-Stability-and-Performance-in-Oracle-11g.pdf)
        * [Query Optimization in Oracle 12c Database In-Memory](/resources/paper/Query-Optimization-in-Oracle-12c-Database-In-Memory.pdf)
    * facebook
        * [Velox: Meta's Unified Execution Engine](https://scontent-hkg4-2.xx.fbcdn.net/v/t39.8562-6/302757195_3033291893628871_4556621853780203235_n.pdf?_nc_cat=109&ccb=1-7&_nc_sid=ad8a9d&_nc_ohc=hY-ITB_TXPQAX8Ylsh_&_nc_ht=scontent-hkg4-2.xx&oh=00_AT9PVOmf5doA__7E1n_itQFL30Ri-4TTXQbVqhmSEMUjDA&oe=6314D2A7)
    * Stream processing
        * [Apache Flink™: Stream and Batch Processing in a Single Engine](/resources/paper/Apache-Flink-Stream-and-Batch-Processing-in-a-Single-Engine.pdf)
        * [A Survey Of Stream Processing](/resources/paper/A-Survey-Of-Stream-Processing.pdf)
        * [Scalable Distributed Stream Processing](/resources/paper/Scalable-Distributed-Stream-Processing.pdf)
* Computer Architecture
    * [Residency-Aware Virtual Machine Communication Optimization: Design Choices and Techniques](/resources/paper/Residency-Aware-Virtual-Machine-Communication-Optimization-Design-Choices-and-Techniques.pdf)
    * [GPU Computing](/resources/paper/GPU-Computing.pdf)
* Storage
    * [What's the Story in EBS Glory: Evolutions and Lessons in Building Cloud Block Store](/resources/paper/Whats-the-Story-in-EBS-Glory-Evolutions-and-Lessons-in-Building-Cloud-Block-Store.pdf)
* Parquet
    * [Lakehouse: A New Generation of Open Platforms that Unify Data Warehousing and Advanced Analytics](/resources/paper/Lakehouse-A-New-Generation-of-Open-Platforms-that-Unify-Data-Warehousing-and-Advanced-Analytics.pdf)
    * [Seamless Integration of Parquet Files into Data Processing](/resources/paper/Seamless-Integration-of-Parquet-Files-into-Data-Processing.pdf)
* AI
    * [Understanding Deep Learning (Still) Requires Rethinking Generalization](/resources/paper/Understanding-Deep-Learning-Requires-Rethinking-Generalization.pdf)
    * [A Closer Look at Memorization in Deep Networks](/resources/paper/A-Closer-Look-at-Memorization-in-Deep-Networks.pdf)
    * [The Loss Surfaces of Multilayer Networks](/resources/paper/The-Loss-Surfaces-of-Multilayer-Networks.pdf)
    * [Attention Is All You Need](/resources/paper/Attention-Is-All-You-Need.pdf)
    * [BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding](/resources/paper/BERT-Pre-training-of-Deep-Bidirectional-Transformers-for-Language-Understanding.pdf)
    * [Language Models are Unsupervised Multitask Learners](/resources/paper/Language-Models-are-Unsupervised-Multitask-Learners.pdf)
