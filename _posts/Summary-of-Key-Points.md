---
title: Summary-of-Key-Points
date: 2018-01-19 13:18:39
tags: 
- 原创
categories: 
- Job
---

**阅读更多**

<!--more-->

# 1 Java

{% markmap %}
- Key Features
    - Object-Oriented
        - Encapsulation
        - Polymorphism
        - Inheritance
        - Abstraction
    - Platform Independence
    - Automatic Memory Management
    - Rich Standard Library
- Collections
    - Sequence Collections
        - Array
        - List
        - Queue
    - Unordered Associative Collections
        - Set
        - Map
    - Ordered Associative Collections
        - TreeSet
        - TreeMap
- I/O Interface
    - InputStream/OutputStream
        - ByteArrayInputStream/ByteArrayOutputStream
        - StringBufferInputStream/StringBufferOutputStream
        - ObjectInputStream/ObjectOutputStream
        - FileInputStream/FileOutputStream
        - BufferedInputStream/BufferedOutputStream
    - Reader/Writer
        - StringReader/StringWriter
        - FileReader/FileWriter
        - BufferedReader/BufferedWriter
        - InputStreamReader/OutputStreamWriter
- Functional Programming
    - Stream API
        - filter
        - map
        - distinct
        - sorted
        - anyMatch/allMatch/noneMatch
        - findFirst/findAny
        - flatMap
    - Functional API
        - Consumer/BiConsumer
        - Predicate/BiPredicate
        - UnaryOperator/BinaryOperator
        - Supplier
        - Function
    - Lambda Expressions
- Generics
    - Type Erasure
- Reflection
    - Reflection API
    - Dynamic Proxy
        - Java Proxy
        - Cglib
- Serialization
    - Java Serialization
    - Hessian Serialization
- Annotation
    - Source
        - JSR-269
        - Lombok
    - Runtime
- Concurrent
    - Multithreading
    - Concurrency-Safe Containers
        - ConcurrentHashMap
        - CopyOnWriteArrayList
    - Component
        - AbstractQueuedSynchronizer
        - ReentrantLock
        - BlockingQueue
        - CountDownLatch
    - Concurrency Frameworks
        - Executor Framework
        - Fork/Join Framework
- Design Principle
    - SOLID
        - S: Single Responsibility Principle (SRP)
        - O: Open-Closed Principle (OCP)
        - L: Liskov Substitution Principle (LSP)
        - I: Interface Segregation Principle
        - D: Dependency Inversion Principle (DIP)
    - DRY(Don't Repeat Yourself)
    - KISS(Keep It Super Simple)
- Design Pattern
    - Creational Patterns
        - Singleton Pattern
        - Factory Pattern
        - Abstract Factory Pattern
        - Builder Pattern
        - Prototype Pattern
    - Structural Patterns
        - Adapter Pattern
        - Bridge Pattern
        - Composite Pattern
        - Decorator Pattern
        - Proxy Pattern
    - Behavioral Patterns
        - Observer Pattern
        - Strategy Pattern
        - Template Method Pattern
        - Iterator Pattern
        - State Pattern
        - Chain of Responsibility Pattern
        - Command Pattern
        - Interpreter Pattern
        - Mediator Pattern
        - Visitor Pattern
- JMM(Java Memory Model)
    - Happens-before Relationship
    - Volatile Keyword
    - Synchronization
    - Lock Optimization
        - Object Head
- JVM(Java Virtual Machine)
    - Garbage Collection Algorithms
        - Mark-Copy (Young Generation in Serial GC, Parallel GC)
        - Mark-Sweep (Old Generation in Serial GC, Parallel GC)
        - Mark and Concurrent Sweep (CMS GC)
        - Generational Algorithm (Most JVM GCs)
        - Mark-Region (G1 GC)
    - Garbage Collectors
        - Serial GC
        - Parallel GC
        - Concurrent Mark Sweep, CMS
        - Garbage First Garbage Collector, G1
    - Java Memory Management
        - Heap
        - Stack
        - PermGen
        - Metaspace
        - Program Counter Register
        - Native Stack
    - JVM Tuning and Performance Optimization
- JNI(Java Native Interface)
- JDBC(Java Database Connectivity)
- JNDI(Java Naming and Directory Interface)
- Tools
    - Build Tools
        - Ant
        - Maven
        - Gradle
    - Performance Tuning
        - VisualVM
        - JProfiler
        - Arthas
- Frameworks
    - Sprint
    - Mybatis
    - Netty
    - JUnit & TestNG & Mockito & PowerMock
    - SLF4J & Log4j & Logback
{% endmarkmap %}

## 1.1 Netty

**Components:**

* `Channel`: Represents a network socket and provides an abstraction for I/O operations. Channels are used for sending and receiving data.
    * `Write`：adds the message to the outbound buffer but does not trigger an immediate flush of the buffer. The data remains in the buffer until a flush operation occurs.
    * `WriteAndFlush`：combines two operations: writing the message to the outbound buffer and immediately triggering a flush operation. The message is added to the buffer and flushed to the network without delay.
    * `isWritable`: The isWritable method is typically associated with the Channel class in Netty. This method is used to determine if it's currently possible to write data to the channel without causing it to become congested. In other words, it indicates whether you can safely write data to the channel without overflowing its internal buffers and potentially causing memory issues or performance degradation.
* `EventLoop`: Handles I/O events and executes tasks associated with those events. Each Channel has an associated EventLoop for event processing.
* `ChannelHandler`: Handles inbound and outbound events related to a Channel. ChannelHandlers are responsible for protocol-specific logic, such as encoding, decoding, and processing incoming and outgoing data.
* `ChannelPipeline`: Represents a chain of ChannelHandlers for processing inbound and outbound events in a Channel. It provides an organized way to handle data processing and transformation.
* `ByteBuf`: An efficient data container in Netty that represents a flexible and resizable byte buffer. ByteBuf provides various read and write operations for efficient data manipulation.
* `Codec`: A combination of an encoder and a decoder, used for transforming data between byte streams and Java objects. Codecs are commonly used in ChannelHandlers for protocol-specific encoding and decoding.
* `ChannelFuture`: Represents the result of an asynchronous operation on a Channel. It provides a way to register listeners and handle completion or failure of the operation.
* `Bootstrap`: A helper class for setting up a Channel and its associated resources, such as EventLoopGroup, ChannelHandlers, and options.
* `EventLoopGroup`: Manages one or more EventLoops and their associated Channels. EventLoopGroups handle I/O event processing for multiple Channels efficiently.
* `NIO and Epoll`: Netty provides different transport implementations based on the underlying I/O mechanism. NIO (Non-blocking I/O) and Epoll (Linux-specific event notification) are commonly used for efficient event-driven I/O operations.

## 1.2 Not yet mastered

1. Netty Channel Status, like isWritable

# 2 Cpp

{% markmap %}
- Key Features
    - Object-Oriented
        - Encapsulation
        - Polymorphism
        - Inheritance
        - Abstraction
    - Template Programming
    - High Performance
    - Strong Compatibility
- Cpp Features
    - C++11
        - Move Semantics & RValue
        - Type Deduction
        - Lambda Expression
    - C++14
        - Template Extension
        - constexpr Extension
    - C++17
        - STL Extension
        - Template Extension
        - constexpr Extension
    - C++20
        - coroutines
- Preprocessor Directives
    - #include
    - #define & #undef
    - #ifdef & #ifndef & #else & #endif
    - #pragma
- Pointers and References
    - Pointer Stability
- Virtual Functions
    - Function Overriding
    - override & final
    - Vritual Function Table
    - Dynamic Binding & Polymorphic Behaviors
- Overloading
    - Operator Overloading
    - Function Overloading
- Move Semantics
    - RValue Reference
        - Perfect Forwarding
    - Transfer of Resources
- Containers
    - Sequence Containers
        - vector
        - list
        - array
        - queue
        - deque
    - Ordered Associative Containers
        - set
        - map
    - Unordered Associative Containers
        - unordered_set
        - unordered_map
    - Pointer Stability
- Templates
    - Standard Template Library (STL)
    - Templates Specialization
    - Variadic Templates
    - Code Generation
    - Meta Programming
        - Type Traits
        - Type Deduction
        - Compile-time Evaluation
            - constexpr
        - SFINAE(Substitution Failure Is Not An Error)
- Functional Programming
    - Type Erasure(std::function <- Lambda)
    - Function Objects
    - Lambda Expression
    - Higher-Order Functions(Treats Functions as First-Class Citizens)
- Memory Management
    - new/delete
    - Smart Pointers
    - Memory Allocators and Custom Memory Management
- RAII(Resource Acquisition Is Initialization)
    - Smart Pointers
    - STL Containers
    - File Stream Objects
    - Mutex Locks
    - std::thread
- Cpp Memory Model
    - Cache Coherence
    - Memory Consistency
    - Memory Ordering
- Performance Optimization
    - Cache
        - Cache Locality
        - Memory Access Pattern
        - Branch
        - Inline & Not-Inline(Code Cache)
    - Vectorization
- CLI(Common Language Infrastructure)
    - JNI
- Frameworks
    - Google Test & Boost.Test
    - TCMalloc & JeMalloc
    - Boost
- glibc
    - Standard C Library Functions
    - System Call Wrapper Functions
    - Dynamic Linking
    - Thread Support
    - ABI
- Tools
    - Build Tools
        - Makefile
        - Cmake
        - Bazel
    - Troubleshooting
        - GDB
        - AddressSanitizer
        - Valgrind
        - Memory Profiling
    - Performance Tuning
        - Perf
        - Bcc
        - Vtune
{% endmarkmap %}

# 3 Database

{% markmap %} 
- Basic Concept
    - Database
    - Schema
        - Star Schema
        - Snowflake Schema
        - Constellation Schema
    - Table
        - Fact Table
        - Dimension Table
    - Column
        - Integer
        - String
        - Date
        - Array
        - Map
        - Json
        - Struct
        - Bitmap
        - HyperLogLog
    - Row
    - Key
        - Primary Key
        - Duplicate Key
        - Unique Key
        - Foreign Key
    - Constraints
        - Primary Key Constraint
        - Foreign Key Constraint
        - Unique Constraint
        - Not Null Constraint
        - Check Constraint
    - OLAP & OLTP
    - Lakehouse
        - Low Cost Storage
        - Performance
    - Database Auditing
    - Database Security
    - Database Access Control
    - Database Administration
- SQL Standard
    - Algebraic Identities
    - Join
        - Inner Join
        - Full Outer Join
        - Left/Right Outer Join
        - Left/Right Semi Join
            - Correlated Exist Or In Subquery
            - Existence Predicate
            - Multiply matchs make no differences
        - Left/Right Anti Join
            - Correlated Not Exist Or Not In Subquery
            - Not Existence Predicate
            - Multiply mismatchs make no differences
        - Related Concepts
            - Cardinality Preserved Join
            - Duplication Factor
    - Aggregate
    - Window Function
        - Function
        - Partition By Clause
        - Order By Clause
        - Window Clause
            - Unbounded Window
            - Half Unbounded Window
            - Sliding Window
        - Calculation
            - Naive
            - Cumulative(Unbounded Window)
            - Removable Cumulative(Sliding Window)
            - Segment Tree
    - Predicate
    - View
    - Materialized View
        - Goal
            - Transparent Acceleration
            - Lake Speed Up
            - Real-time Incremental Aggregation
            - Delcarative Modeling(without maintain the ETL workflow)
        - Features
            - Partition
            - Refresh
            - Rewrite
    - Trigger
    - Stored Procedure
    - DML(Data Manipulation Language)
    - DDL(Data Definition Language)
    - DCL(Data Control Language)
- Index
    - B-Tree Index
    - Hash Index
    - Bitmap Index
    - Clustered Index
    - Non-Clustered Index
    - Full-Text Index
    - Zone Map Index
    - Bloom Fiter Index
- Transaction
    - ACID (Atomicity, Consistency, Isolation, Durability)
- Storage
    - High Availability and Scalability
        - Replication
        - Sharding
        - Partitioning
        - Consistency
            - Consensus Protocol
        - Paxos
        - Raft
    - Data Protection
        - Backup and Recovery
        - Disaster Recovery
        - Compression
        - Encryption
        - Write-Ahead Logging (WAL)
    - Performance Optimization
        - LSM-Tree (Log-Structured Merge Tree)
- Database Framework
    - Parser
        - Grammar Checking
    - Analyzer
        - Type Processing
    - Optimizer
        - RBO Optimizer
            - Transformation Rules
                - Predicate Push Down
                - Limit Push Down
                - TopN Push Down
            - Implementation Rules
                - Join Implementations
                    - Algorithm
                        - Nest-Loop Join
                        - Sort-Merge Join
                        - Hash Join
                    - Distribution
                        - Shuffle Join
                        - Broadcast Join
                        - Replication Join
                        - Colocate Join
        - CBO Optimizer
            - Basic Concept
                - Expression
                - ExpressionGroup
                - Optimization Tasks
                    - Group Optimization Task
                        - Find Cheapest Plan
                    - Group Exploration Task
                        - Join Reorder
                        - CTE Enumeration
                    - Expression Optimization Task
                    - Rule Application Task
                    - Input Optimization Task
                        - Property Enforcing
                        - Cost Calculating & Pruning
                - Memo
            - Statistics
                - Basic Statistics
                - Histogram Statistics
        - Heuristic Optimization
            - Subquery
                - Classification
                    - Position
                        - WHERE Clause
                        - SELECT Clause
                        - GRUOP BY Clause
                        - ORDER BY Clause
                        - HAVING Clause
                    - Whether Correlated
                        - Correlated Subquery
                            - Left Outer Join(SELECT Clause)
                            - Left Semi Join(WHERE Clause)
                        - Non-correlated Subquery
                    - Characteristics of Generated Data
                        - Scalar Subquery
                        - Existential Test Subquery
                        - Quantified Comparation Subquery
                            - ANY
                            - SOME
                            - ALL
                - Transformation
                    - Existential Correlated Subquery at Where Clause
                        - Left Semi Join for exist
                        - Left Anti Join for not exist
                    - Existential Correlated Subquery at Select Clause
                        - Left Outer Join for both exist and not exist
                        - Filter above the join to filter null(not exist) or non-null(exist) join-key
                    - Quantified Correlated Subquery at Where Clause
                        - Left Semi Join for in
                        - Null-aware Left Anti Join for not in
                    - Quantified Correlated Subquery at Select Clause
                        - Left Outer Join for both in and not in
                        - Complex Case-when Project for correctness
                        - Not-in with an additional not Compound Predicate
                    - Scalar Correlated Subquery
                        - Left Outer Join
                        - One-row Assertion
            - Window Function
                - Subquery to Window Function
                - Ranking Window Function Optimizations
                    - Predicate Like rk < 100
                    - TopN Like ORDER BY rk LIMIT 100
            - CTE(Common Table Expressions)
                - CTEProducer & CTEConsumer & CTEAnchor
                - Plan Enumeration
            - Multiply Stage Aggregate
                - 1 Stage Aggregate
                    - Agg + GROUP BY distribution column
                        - Data is natrually shuffled from storage
                - 2 Stage Aggregate
                    - AGG
                        - The second stage is used for gather data
                    - AGG + GROUP BY regular column
                        - Data needs to be shuffled
                - 3 Stage Aggregate
                    - AGG(DISTINCT) + GROUP BY column
                        - First two stages are used for local and global distinct, grouping by (agg_column, groupby_column)
                        - Third stage is for global agg, and data is already shuffled
                - 4 Stage Aggregate
                    - AGG(DISTINCT)
                        - First two stages are used for local and global distinct, grouping by (agg_column)
                        - Last two stages are used for local and global agg
    - Execution
        - Morsel-Driven Parallelism(Task-Based Parallelism)
            - Morsel
            - Tasks
                - Independent or Loosely Coupled
            - Worker
            - Scheduling
                - Unit: Execution Link
                - Task Scheduling
                    - Global Balance
                        - Local Queue and Global Queue
                        - Precise Wake-Up to Prevent False Wake-Ups
                    - Work Stealing
                        - Local Queue
                        - False Wake-Ups(Can't steal a task)
                - Task Readiness Analysis
                    - Polling
                        - Unrestricted State Changes
                            - Async Operations
                            - Dependency Relations
                            - Certain Behavior(Materialization)
                        - Separate Thread
                        - Worker Thread
                    - Event-Driven
                        - Restricted State Changes
                            - Message
                            - Mutex/Futex
            - Pros:
                - Fine-Grained Scheduling
                - Flexible Resource Control
                - Flexible Priority Control
        - Volcano Parallelism
            - Kernel Space Scheduling
                - Unit: Execution Tree
            - Pros:
                - Easy of Implementation
        - Optimization
            - Parallelism
                - Resource Utilization
            - Code Generation
                - Better Inline
            - Vectorization
                - Column Oriented
                - Loop
            - Runtime Filter
                - Principle
                    - A JOIN B = (A LEFT SEMI JOIN B) JOIN B
                    - Suitable Scenarios
                        - Inner Join
                        - Left Semi Join
                        - Right Outer/Semi/Anti Join
                        - TopN
                    - Unsuitable Scenarios
                        - Full Join
                        - Left Outer/Anti Join
                - Bloom-Filter(Rows < 100w)
                    - Has False Positive
                    - MinMax Filter
                - In-Filter(Rows < 1000)
                    - No False Positive
- Architecture
    - Shared Nothing Architecture
    - Shared Disk Architecture
    - Shared Memory Architecture
    - Shared Everything Architecture
    - Hybrid Architectures
    - Unified Storage and Computation
    - Separated Storage and Computation
    - HTAP + S3
- Types Of Database
    - Relational Database
        - MySQL
        - Oracle
        - SQL Server
        - PostgreSQL
    - NoSQL Database
        - MongoDB
        - Redis
    - Time-Series Database
        - InfluxDB
        - Prometheus
        - TimescaleDB
    - Graph Database
    - Object-Oriented Database
        - ObjectDB
- Big Data Related Concepts
    - Data Integration
    - Data Extraction, Transformation, and Loading(ETL)
    - Data Cleansing
    - Data Profiling
    - Data Modeling
    - Data Warehousing
    - Data Mart
    - Data Mining
    - Data Governance
    - Data Migration
    - Data Masking
    - Data Archiving
{% endmarkmap %}

## 3.1 Task Readiness Analysis

In the context of task-based parallelism and scheduling, the specific mechanism for determining task readiness is often referred to as task dependency analysis or task readiness analysis. It involves analyzing the dependencies and conditions that need to be met for a task to be considered ready for execution.

Here are a few common approaches:

1. Event-Driven Model: The system may employ event-driven mechanisms to notify the scheduler when a task becomes ready. Tasks or other components of the system can send signals or notifications to the scheduler, indicating that a task is ready to be executed.
1. Polling Model: In some cases, the scheduler may periodically poll or check the state of tasks to determine their readiness. It can iterate over the task list and evaluate their readiness based on certain criteria

**Event-Driven Model:**

* Pros:
    1. Efficiency: In the event-driven model, the program only consumes resources when an event occurs. This leads to efficient resource utilization as the program is not constantly checking for events.
    1. Real-time responsiveness: The event-driven model is well-suited for real-time applications as it can quickly respond to events as they occur, allowing for immediate updates or actions.
    1. Modularity: Events and their associated handlers can be organized into separate modules or components, promoting modular and reusable code.
* Cons:
    1. Complex control flow: The event-driven model can lead to complex control flow, especially in larger applications with numerous event sources and handlers. Understanding and maintaining the flow of events can become challenging.
    * Potential event ordering issues: The order in which events occur and are processed can sometimes introduce subtle bugs or race conditions, requiring careful design and synchronization mechanisms.
    * Difficulty in debugging: Debugging event-driven programs can be more challenging due to their asynchronous nature. Tracking the flow of events and identifying the cause of issues can be trickier compared to sequential programs.

**Polling Model:**

* Pros:
    1. Simplicity: The polling model is straightforward to implement as it involves periodic checking for events. The program follows a sequential flow and is easy to understand.
    1. Control over event checking frequency: With polling, you have control over how frequently events are checked. This can be useful when events are expected to occur at predictable intervals.
    1. Compatibility: The polling model can be used in environments where event-driven mechanisms are not available or practical.
* Cons:
    1. Resource wastage: In the polling model, the program continuously checks for events, even if no events are occurring. This can lead to wasted computational resources and lower efficiency.
    1. Delayed responsiveness: The polling model may introduce latency in event handling since events are not immediately processed but rather checked at regular intervals. Real-time responsiveness can be compromised.
    1. Inefficient resource utilization: Continuous polling can consume unnecessary resources, especially in scenarios where events are infrequent or rare. This can impact system performance and scalability.

In StarRocks' pipeline execution engine, opting for a polling model can offer significant advantages. This preference arises from the fact that the evaluation of driver status lacks strict constraints, necessitating the introduction of event-driven logic in various other common components. As a result, this proliferation of event-driven logic significantly amplifies the overall complexity.

## 3.2 Cache vs. Materialized View

A cache is filled on demand when there is a cache miss (so the first request for a given object is always slow, and you have the cold-start problem mentioned in Figure 5-10). By contrast, a materialized view is precomputed; that is, its entire contents are computed before anyone asks for it—just like an index. This means there is no such thing as a cache miss: if an item doesn’t exist in the materialized view, it doesn’t exist in the database. There is no need to fall back to some other underlying database. (This doesn’t mean the entire view has to be in memory: just like an index, it can be written to disk, and the hot parts will automatically be kept in memory in the operating system’s page cache.)

With a materialized view there is a well-defined translation process that takes the write-optimized events in the log and transforms them into the read-optimized representation in the view. By contrast, in the typical read-through caching approach, the cache management logic is deeply interwoven with the rest of the application, making it prone to bugs and difficult to reason about

## 3.3 Consensus Protocol

## 3.4 Good Cases and Bad Cases of Distinct Agg

This chapter only for Starrocks

[[Enhancement] optimize distinct agg](https://github.com/StarRocks/starrocks/pull/26023)

For sql like `select count(distinct $1) from lineorder group by $2;`, the `count(distinct)` can be achieved through 2-stage agg, 3-stage agg and 4-stage agg.

**2-stage agg(use `multi_distinct_count`):**

* Local `multi_distinct_count`
* Exchange shuffled by `group by key`
* Global `multi_distinct_count`

**3-stage agg:**

* Local Distinct, using both `group by key` and `distinct key` for bucketing
* Exchange shuffled by `group by key`
* Global Distinct, using both `group by key` and `distinct key` for bucketing
* Global Count, use `group by key` for bucketing

**4-stage agg:**

* Local Distinct, using both `group by key` and `distinct key` for bucketing
* Exchange shuffled by `group by key` and `distinct key`
* Global Distinct, using both `group by key` and `distinct key` for bucketing
* Local Count, use `group by key` for bucketing
* Exchange shuffled by `group by key`
* Global Count, use `group by key` for bucketing

### 3.4.1 With Limit

This analysis is only for `select count(distinct $1) from lineorder group by $2 limit 10;`

**2-stage agg(use `multi_distinct_count`):**

* Good Case:
    * The `group by key` has a medium-low cardinality, while `distinct key` has a non-high cardinality
* Bad Case: 
    * The `group by key` has a high cardinality
    * The `group by key` has a low cardinality

**3-stage agg:**

* Good Case:
    The `group by key` has a high cardinality

* Bad Case:
    The `group by key` has a medium-low cardinality

**4-stage agg:**

* Good Case:
    * The `group by key` has a low cardinality, while `distinct key` has a high cardinality
* Bad Case:
    * Other cases

### 3.4.2 Without Limit

This analysis is only for `select count(distinct $1) from lineorder group by $2;`

**2-stage agg:**

* All cases are worse than other approaches

**3-stage agg:**

* Good Case:
    * Almost all the cases
* Bad Case:
    * Worse then 4-stage agg when the `group by key` has a low cardinality, while `distinct key` has a high cardinality

**4-stage agg:**

* Good Case:
    * The `group by key` has a low cardinality, while `distinct key` has a high cardinality
* Bad Case:
    * Other cases

## 3.5 Not yet mastered

1. WAL Structure
1. Consensus Protocol
1. Bitmap Index & Bitmap Column
1. Subuqery classification
1. Cost-based state transition machine
    * The process of the cbo optimization

# 4 Scheduler

{% markmap %}
- Key Metrics
    - Latency
    - Response Time
    - Throughput
    - Fairness
    - Resource Utilization
    - Scheduling Overhead
- CPU Scheduling
    - Algorithm
        - First-Come, First-Served (FCFS)
        - Round Robin (RR)
        - Shortest Job Next (SJN)
        - Highest Response Ratio Next，HRRN
        - Priority Scheduling
        - Multilevel Feedback Queue Scheduling
- Task Scheduling
    - Algorithm
        - List Scheduling
        - Heterogeneous Earliest Finish Time, HEFT
        - Min-Min Scheduling
- Real-Time Scheduling
    - Algorithm
        - Rate-Monotonic Scheduling (RMS)
        - Earliest Deadline First (EDF)
- Disk Scheduling
    - Algorithm
        - First-Come, First-Served (FCFS)
        - Shortest Seek Time First (SSTF)
- Network Packet Scheduling
    - Priority Factors
        - Quality of Service (QoS)
        - Fairness
        - Congestion Control
        - Traffic Control
    - Algorithm
        - Weighted Fair Queuing (WFQ)
        - Deficit Round Robin (DRR)
        - Stochastic Fairness Queuing (SFQ)
- Task Parallelism
    - Scenarios
        - Fork-Join
        - MapReduce
        - OpenMP
        - Morsel-Driven
            - Task Readiness Analysis
                - Event-Driven
                - Polling
- Job Scheduling
    - Algorithm
        - Backfilling
        - Genetic Algorithms
        - Simulated Annealing
{% endmarkmap %}

## 4.1 Which scenarios are suitable for an event-driven model

In both Linux thread scheduling and brpc's bthread coroutine scheduling, the smallest unit of scheduling is respectively a pthread and a bthread.

They share a common characteristic: the state changes of pthread or bthread can only occur through a few limited ways, such as:

* Exhaustion of time slice
* Explicit suspension or wake-up through Mutex/Futex
* Execution of kernel-mode operations, such as system calls, in pthread
* Execution of IO operations in bthread
* Other limited ways

This ensures that the scheduling of pthreads and bthreads is controlled and managed in a controlled manner, and their state transitions adhere to specific mechanisms and events.

## 4.2 Which scenarios are not suitable for event-driven model

In a database system, the state changes of tasks (or operations in query execution plans) are typically more intricate, as they need to consider various factors such as dependencies, buffer capacity, and specific behaviors of operators (materialization, asynchronous operations), among others. These state changes often occur asynchronously, making it challenging to capture all the state transitions through synchronous events. Instead, it is usually necessary to actively query or examine the current state of tasks through function calls or methods.

In scenarios where the state changes of tasks or operations are complex and asynchronous, polling can be a more suitable approach. Polling involves actively querying or checking the current state of tasks or operations at regular intervals to determine if any changes have occurred.

In situations where events are not naturally generated or it is challenging to capture all state transitions through synchronous events, polling allows the system or application to actively monitor and track the status or progress of tasks. It provides a way to continuously check for updates or changes in the state and take appropriate actions based on the observed results.

By regularly polling the status of tasks or operations, applications can adapt dynamically to the changing state, make informed decisions, and trigger subsequent actions or processes accordingly. However, it's important to strike a balance in terms of polling frequency to avoid excessive resource consumption.

Overall, polling can be a practical approach when dealing with complex and asynchronous state changes, allowing systems and applications to proactively monitor and respond to evolving conditions.

# 5 Network

{% markmap %}
- Network Concepts
    - Network Topologies
        - Bus Topology
        - Star Topology
        - Ring Topology
        - Mesh Topology
        - Hybrid Topology
    - Network Protocols
        - IP
        - TCP
            - Connection-Oriented Communication
            - Three-Way Handshake
                - SYN (Synchronize) Segment
                    - Initiates a connection request
                    - Contains initial sequence number
                - SYN-ACK (Synchronize-Acknowledgment) Segment
                    - Acknowledges the connection request
                    - Contains initial sequence number and acknowledgement number
                - ACK (Acknowledgment) Segment
                    - Confirms the establishment of the connection
                    - Contains the next sequence number to be expected
            - Four-Way Handshake (Connection Termination)
                - FIN (Finish) Segment
                    - Initiates the connection termination process by the sender
                - ACK (Acknowledgment) Segment
                    - Acknowledges the receipt of the FIN segment
                - FIN-ACK (Finish-Acknowledgment) Segment
                    - Confirms the termination request by the receiver
                - ACK (Acknowledgment) Segment
                    - Acknowledges the receipt of the FIN-ACK segment
            - Status
                - SYN_SENT
                - SYN_RCVD
                - ESTABLISHED
                - FIN_WAIT_1
                - CLOSE_WAIT
                - FIN_WAIT_2
                - LAST_ACK
                - TIME_WAIT
                - CLOSED
            - Reliable Data Transfer
                - Sequence Numbers
                    - Identifies each byte of data in a TCP segment
                    - Used for reassembling and ordering received segments
                - Positive Acknowledgment with Retransmission (PAR)
                    - Receiver sends an acknowledgment for successfully received data
                    - Sender retransmits unacknowledged data after a timeout
                - Sliding Window
                    - Allows a sender to transmit multiple segments without waiting for individual acknowledgments
                    - Window size determines the number of unacknowledged segments allowed
            - Flow Control
                - Window Size
                    - Specifies the number of bytes a receiver is willing to accept
                    - Prevents overwhelming the receiver with too much data
                    - Sliding Window mechanism used to manage the window size
                - Receiver Window Advertisement
                    - Receiver advertises its current window size to the sender
                    - Allows the sender to adjust the rate of data transmission
            - Congestion Control
                - Congestion Window
                    - Limits the amount of data a sender can transmit before receiving acknowledgments
                    - Adjusted dynamically based on network conditions
                - Slow Start
                    - Initial phase of congestion control
                    - Gradually increases the congestion window size to probe the network's capacity
                - Congestion Avoidance
                    - After reaching a congestion threshold, sender increases the congestion window size more cautiously
                    - Uses additive increase and multiplicative decrease mechanisms
                - Fast Retransmit and Fast Recovery
                    - Detects and recovers from packet loss without waiting for timeout
                    - Resends segments upon receiving duplicate acknowledgments
            - TCP Header
                - Source and Destination Ports
                - Sequence and Acknowledgment Numbers
                - Control Bits(Control Flags)
                    - SYN, ACK, FIN, RST, etc.
                - Window Size
                - Checksum
                - Urgent Pointer
                - Options
                    - Maximum Segment Size (MSS)
                    - Window Scaling
                    - Selective Acknowledgment (SACK)
                    - Timestamps
        - HTTP
        - FTP
        - DNS
        - SMTP
    - OSI Model
        - Physical Layer
        - Data Link Layer
        - Network Layer
        - Transport Layer
        - Session Layer
        - Presentation Layer
        - Application Layer
    - IP Addressing
        - IPv4
        - IPv6
        - Subnetting
        - DHCP
        - NAT
    - Routing
        - Routing Tables
        - Routing Protocols
        - Static Routing
        - Dynamic Routing
    - Network Security
        - Firewalls
        - VPN
        - IDS/IPS
        - Encryption
        - Authentication
    - Network Devices
        - Router
        - Switch
        - Hub
        - Modem
        - Access Point
{% endmarkmap %}

# 6 Other

## 6.1 Unclassified

1. Reactive Programming