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
        - Class Object
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
        - High Performance
        - Efficient CPU Usage
    - Concurrency-Safe Containers
        - ConcurrentHashMap
        - CopyOnWriteArrayList
    - Component
        - AbstractQueuedSynchronizer
        - ReentrantLock
        - BlockingQueue
        - CountDownLatch
        - CyclicBarrier
        - Semaphore
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
        - Program Order Rule
        - Monitor Lock Rule
        - Volatile Variable Rule
        - Thread Start Rule
        - Thread Termination Rule
        - Interruption Rule
    - Synchronization Mechanism
        - volatile
        - synchronized
            - Optimizations
            - Object Head
- JVM(Java Virtual Machine)
    - Garbage Collection Algorithms
        - Mark-Copy (Young Generation in Serial GC, Parallel GC)
        - Mark-Sweep (Old Generation in Serial GC, Parallel GC)
        - Mark and Concurrent Sweep (CMS GC)
        - Mark-Region (G1 GC)
        - Generational Algorithm (Most JVM GCs)
    - Garbage Collectors
        - Serial GC
        - Parallel GC
        - Concurrent Mark Sweep, CMS
        - Garbage First Garbage Collector, G1
    - Java Memory Classification
        - Stack
        - Heap
        - Method Area
        - Program Counter Register
        - Native Stack
    - JVM Tuning and Performance Optimization
- JNI(Java Native Interface)
    - Calling Native Code from Java
    - Calling Java from Native Code
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
    - Antlr4, ANother Tool for Language Recognition
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
        - Template Extension
            - Variadic Templates
            - Template Aliases
            - constexpr functions
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
        - Each class has a complete table, comprising of the memory address of each virtual functions
        - One specific version of virtual function may be shared by multiply tables
    - Dynamic Binding & Polymorphic Behaviors
- Overloading
    - Operator Overloading
    - Function Overloading
- Move Semantics & RValue Reference
    - Perfect Forwarding in Template
    - Transfer of Resources
        - Memory Ownership
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
        - std::decay
            - Remove reference
            - Array to pointer
            - Function to pointer
        - std::declval
            - Get return type of a function at compile time
    - Templates Specialization
    - Variadic Templates
    - Code Generation
    - Meta Programming
        - Type Traits
        - Type Deduction
        - Compile-time Evaluation
            - constexpr
        - SFINAE(Substitution Failure Is Not An Error)
            - Determine if the class has specific members
- Functional Programming
    - Type Erasure(std::function <- Lambda)
    - Function Objects
    - Lambda Expression
    - Higher-Order Functions(Treats Functions as First-Class Citizens)
- Memory Management
    - Manual Memory Management
        - new/delete
    - Automatic Memory Management
        - Smart Pointers
    - Memory Allocation Strategy(malloc, tcmalloc, jemalloc)
        - First Fit, allocates the first block of memory that meets the request
        - Best Fit, allocates the smallest block of memory that meets the request
            - Minimize wastage
            - Fragmentation
        - Worst Fit, allocates the largest available block of memory that meets the request
            - Significant Fragmentation
        - Next Fit, similar to First Fit, but search starts from the last position
        - Buddy System
            - Memory is allocated in powers of two
            - If a request does not match an exact power of two, the next largest size is chosen
            - This system can coalesce buddy blocks to form larger blocks
            - No Fragmentation
        - Slab Allocation
            - It deals with the frequent allocation and deallocation of small objects of the same size
            - This strategy is effective for kernel object allocation where objects of the same size are frequently allocated and deallocated
- RAII(Resource Acquisition Is Initialization)
    - STL Containers
    - Smart Pointers
    - File Stream Objects
    - Mutex Locks
    - std::thread
- Cpp Memory Model
    - Cache Coherence
        - Coherence Protocol
            - MESI
            - MOESI
    - Memory Consistency
        - Memory Ordering
            - Sequential Consistency Ordering
            - Relaxed Ordering(Hardware related)
                - Relax write-read Program Ordering, Supported by TSO
                - Relax write-write Program Ordering
                - Relax read-read and read-write Program Ordering
                - Allow early read that is written by current processor
                - Allow early read that is written by other processors
- Performance Optimization
    - Cache
        - Cache Locality
        - Memory Access Pattern
            - Random Memory Access
            - Sequential Memory Access
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
        - Calling conventions
        - Data representation
        - System call interface
        - Exception handling
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

## 2.1 What is ABI

An Application Binary Interface (ABI) is a set of rules and conventions that dictate how low-level software components, such as libraries and system calls, should interact with each other at the binary level. In other words, it defines the interface between different parts of a computer program, specifying things like:

* **Calling conventions**: How function calls are made and parameters are passed between different parts of a program, including the order in which they are placed in registers or on the stack.
* **Data representation**: How data types are represented in memory or when passed between different parts of a program. This includes issues like endianness (byte order), data alignment, and data structure layout.
* **System call interface**: How applications request services from the operating system, such as file I/O or network communication. ABIs define the conventions for making system calls, passing arguments, and receiving results.
* **Exception handling**: How errors and exceptions are communicated and handled between software components.

# 3 Database

{% markmap %} 
- Basic Concept
    - Database
    - Schema
        - Star Schema
            - One Fact Table & Multiple Dimension Tables
        - Snowflake Schema
            - One Fact Table & Multiple Related Normalized Dimension Tables
        - Constellation Schema
            - Multiple Fact Table & Multiple Related Normalized Dimension Tables
    - Table
        - Fact Table
        - Dimension Table
    - Column
        - Type
            - Bitmap
            - Hll
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
        - σ, Select
        - π, Projection
        - ∪, Union
        - ∩, Intersection
        - -, Difference
        - ×, Product
        - ⋈, Join
        - ⋉, Left semi join
        - ⋊, Right semi join
        - ⟕, Left outer join
        - ⟖, Right outer join
        - ρ, Rename
        - ←, Assignment
        - δ, Duplicate Elimination
        - γ, Aggregation
        - τ, Sorting
        - ÷, Division
    - Join
        - Inner Join
        - Full Outer Join
        - Left/Right Outer Join
        - Left/Right Semi Join
            - Multiply matchs make no differences
        - Left/Right Anti Join
            - Multiply mismatchs make no differences
        - Related Concepts
            - Cardinality Preserved Join
            - Duplication Factor
    - Aggregate
        - Agg Functions Support Rollup
            - Sum
            - Count
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
            - Segment Tree(Sliding Window, Min/Max)
    - Predicate
    - View
    - Materialized View
        - Goal
            - Transparent Acceleration
            - Lake Speed Up
            - Real-time Incremental Aggregation
            - Declarative Modeling(without maintaining the ETL workflow)
        - Features
            - Partition
            - Refresh
            - Rewrite
        - Concepts
            - Roll-up
            - Drill-down
    - Trigger
    - Stored Procedure
    - DML(Data Manipulation Language)
    - DDL(Data Definition Language)
    - DCL(Data Control Language)
- Index
    - B-Tree Index
    - Hash Index
    - Clustered Index
    - Non-Clustered Index
    - Full-Text Index
    - ShortKey Index
    - Zone Map Index
    - Bitmap Index
    - Bloom Fiter Index
- Transaction
    - ACID (Atomicity, Consistency, Isolation, Durability)
        - Isolation in Mysql
            - READ UNCOMMITTED
                - No Read Lock
                - Write Row-Level Lock, free after transaction
            - READ COMMITTED
                - Read Row-Level Lock, free after read
                - Write Row-Level Lock, free after transaction
            - REPEATABLE READ
                - Read Row-Level Lock, free after transaction
                - Write Row-Level Lock, free after transaction
            - SERIALIZABLE
                - Read Table-Level Lock, free after transaction
                - Write Table-Level Lock, free after transaction
- Meta Management
    - Storage
        - LevelDB
        - RocksDB
- Storage
    - High Availability and Scalability
        - Replication
        - Sharding
        - Partitioning
        - Consistency
            - Consensus Protocol Paxos vs. Raft
                - Understandability
                - Design Principles
                - Leader Election
                - Data Model
    - Data Protection
        - Backup and Recovery
        - Disaster Recovery
        - Compression
        - Encryption
        - Write-Ahead Logging (WAL)
    - Performance Optimization
        - LSM-Tree (Log-Structured Merge Tree)
        - Buffer Pool
            - Replacement Policy(Page Evict)
                - LRU
                - LFU
    - Analytic Data Format
        - Column-wise
            - Arrow
            - Parquet
            - ORC
            - Iceberg
- Database Framework
    - Parser
        - Grammar Checking
    - Analyzer
        - Type Processing
        - Limitation Checking
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
                    - Contains equivalent expressions that produce the same result
                - Optimization Tasks
                    - Group Optimization Task
                        - Find Cheapest Plan
                    - Group Exploration Task
                        - Join Reorder
                        - CTE Enumeration
                    - Expression Optimization Task
                        - Trigger Rule Application Task
                        - Trigger Group Exploration Task
                    - Rule Application Task
                    - Input Optimization Task
                        - Property Enforcing
                        - Cost Calculating & Pruning
                - Memo
            - Statistics
                - Basic Statistics
                    - Cardinality
                    - NDV, Number of Distinct Values
                    - MCV, Most Common Value
                    - Min/Max
                - Histogram Statistics
                    - Distribution
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
                - CTEProducer & CTEConsumer & CTEAnchor & Sequence
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
                - A small chunk or portion of data
            - Pipeline & PipelineDriver
                - Independent or Loosely Coupled
                - Execution Link
                - Scheduling Unit
            - Scheduling
                - Worker
                    - The number of workers equals to the number of CPU cores
                    - Core-Binding for better locality
                - Task Scheduling
                    - Global Balance
                        - Local Queue and Global Queue
                        - Precise Wake-Up to Prevent False Wake-Ups
                    - Work Stealing
                        - Only Local Queue
                        - False Wake-Ups(Can't steal a task)
                - Task Readiness Analysis
                    - Polling
                        - Unrestricted State Changes
                            - Async Operations
                            - Dependency Relations
                            - Complex Condition Expressions(Rely on multiply components or variables)
                        - Separate Thread
                        - Worker Thread
                    - Event-Driven
                        - Restricted State Changes
                            - Time Slice Exhausted
                            - Hardware Interrupts
                            - System Calls
                            - Mutex/Futex
                            - Explicit Yielding
            - Pros:
                - Fine-Grained Scheduling
                - Flexible Resource and Priority Control
                - Flexible Parallelism Control
        - Volcano Parallelism
            - Kernel Space Scheduling
                - Unit: Execution Tree
            - Pros:
                - Easy of Implementation
        - Optimization
            - Storage
                - Index
                - Late Materialization
                - Cache
            - Pre-Calculation
                - Pre Agg
                - Pre Sort
                - Query Cache
                - MV
            - Data Type Mapping
                - Low Cardinality String Dictionary
            - Parallelism(Resource Utilization)
                - Mixed Workloads
                - Query Parallelism
                - IO Parallelism
                - Calculation Parallelism
                - MPP
                - Skew Elimination
            - Code Generation(Better Inline)
                - JIT
            - Vectorization
                - Column Oriented
                - Loop
                - SIMD
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
            - Cache
                - Data Cache
                - Query Cache
                - Metadata Cache
        - Tradeoff
            - Exchange Overhead(Hash, Random read/write) will increase as node number increase
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
        - DolphinDB
    - Graph Database
    - Object-Oriented Database
        - ObjectDB
- Test Sets
    - SSB
    - TPC-H
    - TPC-DS
    - TSBS
    - Taxi
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
    - Retention Analysis
    - Funnel Analysis
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
    1. Potential event ordering issues: The order in which events occur and are processed can sometimes introduce subtle bugs or race conditions, requiring careful design and synchronization mechanisms.
    1. Difficulty in debugging: Debugging event-driven programs can be more challenging due to their asynchronous nature. Tracking the flow of events and identifying the cause of issues can be trickier compared to sequential programs.

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

A cache is filled on demand when there is a cache miss (so the first request for a given object is always slow, and you have the cold-start problem mentioned in Figure 5-10). By contrast, a materialized view is precomputed; that is, its entire contents are computed before anyone asks for it—just like an index. This means there is no such thing as a cache miss: if an item doesn't exist in the materialized view, it doesn't exist in the database. There is no need to fall back to some other underlying database. (This doesn't mean the entire view has to be in memory: just like an index, it can be written to disk, and the hot parts will automatically be kept in memory in the operating system's page cache.)

With a materialized view there is a well-defined translation process that takes the write-optimized events in the log and transforms them into the read-optimized representation in the view. By contrast, in the typical read-through caching approach, the cache management logic is deeply interwoven with the rest of the application, making it prone to bugs and difficult to reason about

## 3.3 Consensus Protocol

### 3.3.1 Paxos vs. Raft

Paxos and Raft are both consensus algorithms used to achieve agreement among a group of distributed systems. They are crucial for ensuring data consistency and fault-tolerance in distributed systems. Though they aim to solve the same fundamental problem, they differ in their design principles, ease of understanding, and some implementation details.

Here are the primary differences between Paxos and Raft:

1. **Origins and History:**
    * **Paxos**: Proposed by Leslie Lamport in the 1980s, Paxos is often considered the foundation for many distributed consensus systems. Its initial description was theoretical and presented in the form of a fictional Greek island, which made it difficult for many to understand.
    * **Raft**: Introduced by Diego Ongaro and John Ousterhout in 2013, Raft was explicitly designed to be a more understandable alternative to Paxos. The primary motivation was to simplify the design and explanation of consensus to make it easier for system builders.
1. **Understandability:**
    * **Paxos**: Paxos has been historically considered hard to understand and implement correctly. Many nuances are required for its correct implementation, and its theoretical basis can be daunting.
    * **Raft**: Raft's design focuses on understandability. Its creators intentionally aimed for a consensus mechanism where the state and transitions are more directly tied, making it easier to build and reason about.
1. **Design Principles:**
    * **Paxos**: Paxos operates in phases like 'prepare' and 'accept'. It provides the foundation for many consensus systems, so variations like Multi-Paxos have been developed to handle continuous operation.
    * **Raft**: Raft breaks the consensus problem into smaller subproblems and addresses them individually. It employs terms like "leader election" and "log replication" to make the protocol more direct.
1. **Leader Election:**
    * **Paxos**: Paxos does not natively emphasize a strong leader principle. Though it can have a leader in practice (like in Multi-Paxos), its base form doesn't mandate one.
    * **Raft**: Raft relies on a strong leader approach. The system elects a leader, and all changes to the system state go through this leader. This design simplifies many aspects of the consensus process.
1. **Data Model:**
    * **Paxos**: Paxos abstractly aims to reach consensus on a single value. For practical systems, enhancements (like Multi-Paxos) are used to agree on sequences of values or operations.
    * **Raft**: Raft natively works with a log-based model where the consensus is achieved on a sequence of commands. This ties in well with many practical systems that require a consistent and ordered history of operations.

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

## 3.5 Subquery Classification

{% post_link DBMS-Optimizer %}

## 3.6 Bitmap Index

### 3.6.1 Bitmap Index

**Function of Bitmap Index**:

* **Efficiency in Low Cardinality**: If a column in a database has only a few unique values (like "Male" or "Female" in a gender column), then a traditional B-tree index isn't very efficient. Bitmap indexes are much more space-efficient and can be faster for this type of data.
* **Combining Multiple Indexes**: Bitmap indexes can be combined (using Boolean operations) more efficiently than other types of indexes. This makes them useful for queries that have multiple predicates.
* **Space Efficient**: Bitmaps can be compressed, making them space-efficient compared to some other types of indexing mechanisms.

**Example:**

| Book ID | Title                  | Genre       |
|---------|------------------------|-------------|
| 1       | A Journey Within       | Fiction     |
| 2       | The Life of a Scientist | Biography   |
| 3       | Universe Explained      | Non-Fiction |
| 4       | The Mountain's Whisper  | Fiction     |
| 5       | Leaders of Our Time     | Biography   |
| 6       | Secrets of the Ocean    | Non-Fiction |

**Bitmap Index for the Genre column(Each distinct value has a bitmap):**

* Fiction -> `1 0 0 1 0 0`
* Biography -> `0 1 0 0 1 0`
* Non-Fiction -> `0 0 1 0 0 1`

### 3.6.2 Bitmap Column

Bitmap columns, as used in systems like StarRocks, are a specialized storage format designed for efficiently representing sets of integers, typically IDs. The underlying principle is rooted in bitmap compression methods, especially Roaring Bitmaps, which is a popular technique used in many analytical databases and systems.

Let's dive into the concept:

**Basic Bitmaps:**

At a basic level, a bitmap is a sequence of bits where each bit position corresponds to an integer. If the integer is present in the set, the bit is set to `1`; otherwise, it's `0`.

**Example:**

Imagine you have a set of integers representing user IDs that accessed a website on a particular day: `{2, 4, 5, 6}`, a bitmap would look something like this:

```
Position: 1 2 3 4 5 6 7 8 9 ...
Bitmap:   0 1 0 1 1 1 0 0 0 ...
```

**Compression:**

Storing raw bitmaps for large ID spaces would be inefficient, especially if the IDs are sparse. For instance, if you have an ID of `1,000,000` but only ten IDs in that range, a straightforward bitmap would have a lot of `0`s and be space-inefficient.

This is where bitmap compression techniques, like Roaring Bitmaps, come into play.

**Roaring Bitmaps:**

Roaring Bitmaps are a form of compressed bitmap that divides the range of integers into chunks and represents each chunk in the most space-efficient manner:

* **Array Containers**: If a chunk has a small number of values, it might store them as a simple array of 16-bit integers.
* **Bitmap Containers**: If a chunk has a moderate number of values, it might represent them with a 64KB bitmap.
* **Run-Length Encoding (RLE) Containers**: If a chunk has long runs of consecutive values, it will represent them as runs (start, length).

The container type that's the most space-efficient for the chunk's particular set of integers is used.

**Example:**

Now, imagine our user IDs are `{2, 4, 5, 6, 10,000}`.

If you were to use a straightforward bitmap, you'd have a very long string of `0`s between the `1` for the ID `6` and the `1` for the ID `10,000`. This is where the Roaring Bitmap approach becomes efficient.

Roaring Bitmap divides the range of integers into chunks. Let's simplify this by saying each chunk represents a range of 8 numbers. (In real implementations, the chunk size is much larger.)

* `Chunk 1` (1-8): `{2, 4, 5, 6}` would be represented as `01011100`.
* `Chunk 2` (9-16): No values, so all `0`s: `00000000`.
* ...
* `Chunk 1250` (9993-10000): Just the `10,000` ID, so `00000001`.

Now, instead of storing all these chunks as is, Roaring Bitmaps compresses them:

* **Array Containers**: If there's a small number of values in a chunk (like our first chunk), it could store them as a simple array: `[2, 4, 5, 6]`.
* **Run-Length Encoding (RLE) Containers**: If there's a long sequence of the same value, like our many chunks of all `0`s between ID `6` and ID `10,000`, it would just store the sequence as a start and length: `(9, 9992)` indicating from position `9` there are `9992` zeroes.
* **Bitmap Containers**: If there's a moderate number of values, it would store them as a mini bitmap. We didn't have such an example in our data, but imagine if in one of the chunks, half the IDs were present; it would use a bitmap for that chunk.

### 3.6.3 Difference

* Bitmap Index needs to get all row information of a particular value. But Bitmap Column only needs to check if a given value exists.
* For Bitmap Index, each distinct value has a unique bitmap. But For Bitmap Column, each row has a bitmap.
* For Bitmap Index, each position represents a row. For Bitmap Column, each position represents a existing value.

## 3.7 The Process of the CBO Optimization

```

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

## 3.8 Buffer Pool

### 3.8.1 Replacement Policy

**LRU**:
    
**LFU**:

*  Disadvantages: When some page is frequently used for a period of time, and it will stay in the poll for a long while(May be it can be solved with frequency degradation)

## 3.9 Not yet mastered

1. WAL Structure
1. LSM Structure

# 4 Operating System

{% markmap %}
- Functions
    - Process Management
        - Process Creation
            - Process States
                - New
                - Ready
                - Running
                - Blocked
                - Terminated
            - Process Control Block (PCB)
            - Fork and Exec
        - Process Scheduling
            - CPU Scheduling Algorithms
                - Completely Fair Scheduling (CFS)
                - Round Robin (RR) Scheduling
                - FIFO (First In, First Out) Scheduling
        - Inter-Process Communication (IPC)
            - Message Passing
                - Pipe
                - Message Queue
                - Socket
            - Shared Memory
                - Memory-mapped Files
            - Synchronization Mechanism
                - Semaphore
                - Sinal
                - File Locking
        - Process Synchronization
            - Semaphores
            - Mutexes
            - Deadlock Handling
    - Memory Management
        - Memory Hierarchy
            - Registers
            - Cache(L1, L2, L3)
                - L1 and L2 are dedicated by each core
                - L3 is shared by all cores
            - Main Memory (RAM)
            - Secondary Storage (Disk)
        - Memory Address Spaces
            - Logical Address
            - Linear Address
            - Physical Address
            - Logical Address --segmentation--> Linear Address --paging--> Physical Address
        - Memory Allocation
            - Contiguous Memory Allocation
            - Segmentation Memory Allocation
                - Avoid Memory Space Conflict
                - Partly controled by hardware
                - 80286
            - Paging Memory Allocation
                - Better Efficiency & No External Fragmentation
                - Partly controled by hardware
                - Linux
            - Combination of Paging and Segmentation
                - 80386
        - Virtual Memory
            - Each Virtual Memory Address contains the Page Number and Page Offset
            - Page Tables
                - Each process typically has its own dedicated page table
                - cr3
                - TLB
                    - Hardware caches that are typically shared among all running programs
                    - Each core typically has its own TLB
                    - TLB shootdown
                        - Coherence protocol is required, just like what MESI does
            - Page Replacement Algorithms (LRU, FIFO, etc.)
                - FIFO (First-In-First-Out)
                - LRU (Least Recently Used)
                - LFU (Least Frequently Used)
            - Page Fault Exception
                - A process is trying to access a page (or memory location) in virtual memory that is currently not loaded into physical memory
                - Lazy Allocation (Demand Paging)
            - brk vs. mmap
                - mmap
                    - It can be used for both memory allocation and memory-mapped file operations in modern Unix-like systems
                    - The smallest size is a single page, typically 4KB
                - brk, Program Break
                    - It control the size of the heap(increase or decrease) in older Unix programs.
            - Standard File I/O vs. mmap
                - mmap
                    - The file access is essentially treated as memory access
                    - Avoid the double-buffering scenario
                    - Suitable for performance-critical applications with random access patterns
                - Standard File I/O
                    - There might be double buffering: one buffer in the application and another in the kernel.
                    - Generally suitable for sequential file operations or when there's a need for granular control over I/O
            - Slab Allocation
            - Linux Virtual Memory Layout(From Highest to Lowest)
                - Kernel Space
                - Stack Bottom
                - Stack Top
                - Unallocated Space
                - Heap Top (Program Break)
                - Heap Bottom
                - Uninitialized Data(bss)
                - Initialized Data
                - Text(Program Code)
        - Memory Protection
            - Read-Only Memory (ROM)
            - Memory Segmentation
            - Memory Segmentation Violations
        - MemorySwapping
            - Page-in and Page-out
        - Memory Fragmentation
            - External Fragmentation
            - Internal Fragmentation
    - File System Management
    - Device Management
        - Disk Scheduling
            - FCFS (First-Come-First-Served)
            - SSTF (Shortest Seek Time First)
            - SCAN (Elevator Algorithm)
                - C-SCAN (Circular SCAN)
                - N-Step-SCAN
            - LOOK
                - C-LOOK (Circular LOOK)
- Virtualization
    - Full Virtualization
    - Paravirtualization
    - Hardware-Assisted Virtualization
- Components
    - Kernel
    - Shell
    - File System
    - User Interface
    - Hardware
- Concepts
    - Multitasking
    - Multiprocessing
    - Multithreading
    - Synchronization
    - Deadlock
    - Virtual Memory
    - Paging
    - Caching
- Security
    - Authentication
    - Authorization
    - Encryption
    - Access Control
- Types
    - Batch OS
    - Interactive OS
    - Real-Time OS
    - Distributed OS
{% endmarkmap %}

## 4.1 Linux Memory Management

{% post_link Linux-Memory-Management %}

## 4.2 Virtualization

{% post_link Linux-Virtualization %}

Classification:

* **Full Virtualization**: Full virtualization is a virtualization technique that allows multiple fully independent virtual machines (VMs), each with its own operating system and applications, to run on physical hardware. In full virtualization, VMs are unaware that they are running in a virtualized environment; they believe they are running on dedicated physical machines. This type of virtualization typically requires a hypervisor to manage the creation and execution of VMs.
* **Paravirtualization**: Paravirtualization is a virtualization technique in which VMs are aware that they are running in a virtualized environment and cooperate with the virtualization layer. The operating systems within the VMs are modified to communicate with the virtualization layer, which can improve performance and efficiency. Paravirtualization often does not require a hypervisor as heavyweight as in full virtualization because the VMs are more tightly integrated with the virtualization layer.
* **Hardware-Assisted Virtualization**: Hardware-assisted virtualization is a virtualization technique that relies on virtualization support extensions in the processor (CPU) and other hardware components. These extensions can enhance the performance and efficiency of virtual machines and reduce the reliance on virtualization software. For example, Intel's VT-x and AMD's AMD-V are common hardware virtualization extensions.

# 5 System Architecture

{% markmap %}
- ISA
    - CISC
        - x86
    - RISC
        - MIPS
        - SPARC
        - Alpha（DEC）
        - ARMv7
        - ARMv8
        - OpenRISC
- Pipeline
    - Definition
        - Sequential process breakdown
        - Overlapping of instruction phases
    - Types of Pipelining
        - Linear Pipelining
            - Regular interval execution
        - Non-linear Pipelining
            - Different interval execution
    - Stages (Classic Five-stage Pipeline for RISC)
        - IF (Instruction Fetch)
            - Fetch instruction from memory
        - ID (Instruction Decode)
            - Decode fetched instruction
            - Read registers
        - EX (Execute)
            - Arithmetic operations
            - Data movements
        - MEM (Memory Access)
            - Load or store operations
        - WB (Write Back)
            - Write the result to the destination register
    - Hazards
        - Structural Hazards
            - Resource conflicts
        - Data Hazards
            - Read-after-write (RAW)
            - Write-after-read (WAR)
            - Write-after-write (WAW)
        - Control Hazards
            - Branch instructions and their outcomes
    - Solutions to Hazards
        - Pipeline Stalling
        - Data Forwarding
        - Branch Prediction
    - Advantages
        - Increased throughput
        - Efficient resource utilization
        - Concurrent processing
- Storage Hierarchy
    - Cache
        - Mapping Rules
            - Direct Mapping
            - Fully Associative
            - Set Associative Mapping
        - Lookup Method
        - Replacement Algorithm
            - Random
            - FIFO
            - LRU
        - Write Policy
        - Speed
            - SRAM-L1：3–5 cycles
            - SRAM-L2：8–20 cycles
            - SRAM-L3：30–80 cycles
            - DRAM-Memory：150-180 cycles
        - Size
            - L1：8KB - 64KB
            - L2：256KB - 8MB
            - L3：10MB - 64MB
    - Memory
        - Random Access Memory
            - DDR3, Double Data Rate Type 3
            - DDR4, Double Data Rate Type 4
            - DDR5, Double Data Rate Type 5
- Endianness
    - Big-Endian(High-end IBM)
    - Little-Endian(x86)
        - Simplified Arithmetic Operations
        - Efficient Handling of Sub-Word Data
        - Compatibility with Growing Word Sizes
- Parallelism
    - ILP
    - TLP
    - DLP
- Hardware Interfaces
    - PCI Express (PCIe)
    - SATA
    - USB Ports
    - HDMI
    - M.2 Slot
{% endmarkmap %}

## 5.1 X86

Pros:

* **Wide Compatibility**: x86 processors are widely used in desktops, laptops, and servers, making them compatible with a vast array of software applications and operating systems designed for this architecture.
* **High Performance**: In many cases, x86 processors offer excellent performance, especially in applications that benefit from a high clock speed and complex instruction set.
* **Virtualization**: x86 processors have robust virtualization support, which is essential for running multiple virtual machines on a single server.
* **Optimized for Legacy Software**: Many legacy applications and software packages have been developed specifically for x86 architecture, making it a good choice for running older software.

Cons:

* **Power Consumption**: x86 processors tend to consume more power compared to ARM processors, which can be a disadvantage in mobile and battery-powered devices.
* **Heat Generation**: High-performance x86 processors generate more heat, requiring more advanced cooling solutions in some cases.
* **Cost**: x86 processors are often more expensive than ARM processors, which can impact the cost-effectiveness of devices and servers.

## 5.2 Arm

Pros:

* **Power Efficiency**: ARM processors are known for their power efficiency, making them ideal for mobile devices, IoT (Internet of Things) devices, and battery-powered gadgets.
* **Scalability**: ARM processors come in a wide range of configurations, from low-power microcontrollers to high-performance server-grade chips, allowing for scalability across various applications.
* **Customization**: ARM architecture allows for more customization, which can be advantageous for companies looking to design their own chips tailored to specific needs.
* **Reduced Heat Generation**: ARM processors generate less heat compared to high-performance x86 processors, reducing cooling requirements.

Cons:

* **Software Compatibility**: ARM-based devices may have limitations when it comes to running certain legacy x86 software, although this gap is closing with technologies like emulation and virtualization.
* **Performance**: While ARM processors have made significant performance gains, they may not match the raw performance of high-end x86 processors in some compute-intensive tasks.
* **Complexity for Desktop and Server Applications**: While ARM is making inroads in these areas, x86 architecture is still dominant for desktops and servers due to software compatibility and performance considerations.

## 5.3 Hardware

Computer motherboards typically have a variety of interfaces, each designed for different types of devices or functions. Here are some common types of interfaces you'll find:

* `Peripheral Component Interconnect Express (PCIe)`: This is the most common type of expansion slot, used for graphics cards, sound cards, network cards, etc.
    * `Non-Volatile Memory Express (NVMe, Protocol)`: NVMe is a communication protocol specifically developed for SSDs to take advantage of the high speeds provided by PCIe connections. NVMe drives are much faster than their SATA counterparts due to this protocol's efficiency and the speed of the PCIe bus.
* `Serial Advanced Technology Attachment (SATA)`: Used for connecting hard disk drives and solid-state drives.
* `USB Ports`: For connecting various USB devices like keyboards, mice, printers, etc.
* `HDMI/DisplayPort`: For connecting monitors.
* `RJ45 (Ethernet Port)`: For network connections.
* `Audio Interfaces`: Includes ports for headphones, microphones, and speakers.
* `DIMM Slots`: For installing RAM (memory sticks).
* `M.2 Slot`: For installing M.2 form factor solid-state drives.
    * `M.2 (Form Factor)`: `M.2` is a specification for internally mounted computer expansion cards and associated connectors. It's particularly known for its small size, making it ideal for laptops and compact PCs. `M.2` slots can accommodate a variety of devices, including Wi-Fi cards and SSDs. M.2 SSDs can use either the `SATA` interface (slower) or the `PCIe` interface (faster).
* `PS/2 Ports`: For connecting older keyboards or mice.
* `BIOS/CMOS Battery`: For storing system time and basic hardware settings.
* `Power Connectors`: Including the 24-pin main power connector and the CPU power connector.

# 6 Scheduler

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

## 6.1 Which scenarios are suitable for an event-driven model

In both Linux thread scheduling and brpc's bthread coroutine scheduling, the smallest unit of scheduling is respectively a pthread and a bthread.

They share a common characteristic: the state changes of pthread or bthread can only occur through a few limited ways, such as:

* Exhaustion of time slice
* Explicit suspension or wake-up through Mutex/Futex
* Execution of kernel-mode operations, such as system calls, in pthread
* Execution of IO operations in bthread
* Other limited ways

This ensures that the scheduling of pthreads and bthreads is controlled and managed in a controlled manner, and their state transitions adhere to specific mechanisms and events.

## 6.2 Which scenarios are not suitable for event-driven model

In a database system, the state changes of tasks (or operations in query execution plans) are typically more intricate, as they need to consider various factors such as dependencies, buffer capacity, and specific behaviors of operators (materialization, asynchronous operations), among others. These state changes often occur asynchronously, making it challenging to capture all the state transitions through synchronous events. Instead, it is usually necessary to actively query or examine the current state of tasks through function calls or methods.

In scenarios where the state changes of tasks or operations are complex and asynchronous, polling can be a more suitable approach. Polling involves actively querying or checking the current state of tasks or operations at regular intervals to determine if any changes have occurred.

In situations where events are not naturally generated or it is challenging to capture all state transitions through synchronous events, polling allows the system or application to actively monitor and track the status or progress of tasks. It provides a way to continuously check for updates or changes in the state and take appropriate actions based on the observed results.

By regularly polling the status of tasks or operations, applications can adapt dynamically to the changing state, make informed decisions, and trigger subsequent actions or processes accordingly. However, it's important to strike a balance in terms of polling frequency to avoid excessive resource consumption.

Overall, polling can be a practical approach when dealing with complex and asynchronous state changes, allowing systems and applications to proactively monitor and respond to evolving conditions.

## 6.3 Event-driven system

Key characteristics of an event-driven system include:

* **Events**: Events are occurrences that can trigger actions or reactions within the system. These events can be diverse, ranging from user interactions like button clicks, mouse movements, or keyboard input, to system-generated events like data updates, timeouts, or errors.
* **Event Handlers**: Event handlers are pieces of code responsible for processing specific types of events. When an event occurs, the appropriate event handler is invoked to perform the necessary actions or computations. Event handlers are designed to handle one or more event types and are typically registered with the system in advance.
* **Asynchronicity**: Event-driven systems are inherently asynchronous, meaning that components do not execute in a predetermined order. Instead, they respond to events as they occur, allowing for greater flexibility and responsiveness in handling dynamic situations.
* **Loose Coupling**: In event-driven architectures, components are loosely coupled, which means they are not directly dependent on one another. This promotes modularity and reusability, as individual components can be added, removed, or replaced without affecting the entire system's functionality.
* **Callbacks**: Callbacks are a common mechanism used in event-driven programming. A callback function is provided as an argument to an event handler or registration function. When the associated event occurs, the callback function is invoked, allowing developers to define custom reactions to events.
* **Publish-Subscribe Model**: A popular approach within event-driven systems is the publish-subscribe model. In this model, components can publish events to a central event bus or dispatcher. Other components, known as subscribers, can then register to listen for specific types of events and react accordingly when those events are published.
* **Scalability and Responsiveness**: Event-driven architectures are well-suited for building scalable and responsive systems. By distributing the workload across multiple event handlers and components, the system can efficiently handle a large number of concurrent events and maintain responsiveness.

# 7 Network

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

# 8 IO

{% markmap %}
- Concepts
    - IO Amplification
    - IO Alignment
        - Disk's physical sector
        - Filesystem block size
        - Caching mechanisms
            - cache line
            - page cache
        - Database page alignment
        - Best Practice (iops & latency)
            - Linux Filesystem: 128K
    - IO Operator
        - Sequential IO
        - Random IO
        - Synchronous IO
        - Asynchronous IO
        - Direct IO
        - Buffered IO
        - Block IO
        - File IO
        - IO Throttling
    - Optimization
        - Zero-Copy IO
        - IO Coalescing
        - IO Prefetching
            - Prefetch buffer size usually equals to data buffer size
            - Core idea is preventing the CPU from waiting for I/O
    - System Call
        - epoll
        - aio
        - select
        - io_uring
- Metrics
    - inode Number
    - File Handle Number
    - IOPS
    - Latency
{% endmarkmap %}

* **Caching mechanisms:**
    * Using memory caches: Store frequently accessed data in memory to reduce the number of accesses to the hard drive.
    * Read/write caching: Use caching mechanisms provided by the operating system or databases to optimize read and write speeds.
* **Batch processing and buffering techniques:**
    * Data buffering: When writing data to disk, first write the data to a buffer and then perform bulk writes to the disk once a certain amount has accumulated.
    * Batch requests: Combine multiple IO requests into one larger request to reduce the number of IO operations.
* **Concurrency and parallel processing:**
    * Multithreading or multiprocessing: Use multithreading or multiprocessing to parallel process data, which can effectively improve the performance of IO-intensive applications.
    * Asynchronous IO: Use asynchronous IO models to handle input and output operations, enhancing the responsiveness and throughput of applications.
* **Choosing appropriate hardware:**
    * SSD (Solid State Drives): Compared to traditional HDDs (Hard Disk Drives), SSDs provide faster read and write speeds.
    * High-performance IO interfaces: Such as using SAS (Serial Attached SCSI) or NVMe (Non-Volatile Memory Express) for faster data transfer rates.
* **Optimizing data storage and access patterns:**
    * Data prefetching: Based on the access patterns of the application, preload data that is likely to be accessed soon.
    * Data distribution: Properly distribute data to ensure it is evenly spread across different storage devices to avoid bottlenecks.
* **File system optimizations:**
    * Choosing the right file system: Different file systems (e.g., EXT4, XFS, Btrfs) perform differently under various scenarios.
    * Adjusting file system parameters: Adjust configurations like block size and logging level according to specific needs.
* **Database-level optimizations:**
    * Index optimization: Proper use of indexes can speed up queries and reduce disk IO.
    * Partitioning: By partitioning a database, distribute data across different physical drives to improve access efficiency.

# 9 Other

## 9.1 Parsing Algorithms

`LL(1)` and `LR(1)` are both types of parsing algorithms used in the context of compiler construction. They are used to generate a syntax tree or parse tree from the source code of a programming language. These algorithms differ in terms of their parsing techniques and the grammars they can handle.

**`LL(1)` Parsing:**

* `LL(1)` stands for "Left-to-Right, Leftmost derivation, with 1 token lookahead."
It is a top-down parsing technique, meaning it starts from the root of the parse tree and works its way down to the leaves.

* `LL(1)` parsers use a predictive parsing table to decide which production rule to apply based on the next token in the input stream.
* `LL(1)` grammars are a subset of context-free grammars (CFGs) that are more restrictive. They must be unambiguous and have no left recursion.
* The `LL(1)` parser is often easier to implement and more human-readable compared to `LR(1)` parsers.
* It's commonly used in simpler programming languages or for educational purposes.

**`LR(1)` Parsing:**

* `LR(1)` stands for "Left-to-Right, Rightmost derivation, with 1 token lookahead."
It is a bottom-up parsing technique, meaning it starts with the individual tokens and builds up the parse tree from the leaves to the root.

* `LR(1)` parsers use a state machine and a lookahead symbol to decide how to reduce or shift in the parsing process. `LR(1)` parsers are more powerful than `LL(1)` parsers.
* `LR(1)` grammars are a superset of `LL(1)` grammars. They can handle a broader range of context-free grammars, including those with left recursion.
* `LR(1)` parsers can handle more complex and ambiguous grammars, making them suitable for parsing real-world programming languages like C, C++, and Java.
* Implementing an `LR(1)` parser can be more challenging and requires tools like parser generators (e.g., Bison, Yacc) to generate the parsing tables automatically.

In summary, `LL(1)` and `LR(1)` are both parsing techniques used in compiler construction, but they differ in terms of their parsing approach and the complexity of grammars they can handle. `LL(1)` is simpler and more limited in the grammars it can handle, while `LR(1)` is more powerful and can handle a wider range of grammars, making it more suitable for parsing complex programming languages.

## 9.2 Cache

* **Cache Hit:** A cache hit occurs when a requested data is found in the cache. This leads to reduced data retrieval time and less load on the database, as the information can be served directly from the cache without querying the primary data source.
* **Cache Miss:** A cache miss happens when the requested data is not found in the cache. This necessitates a query to the underlying database or service to retrieve the data, which is then often stored in the cache for future requests. Cache misses can increase the latency of data retrieval and put more load on the database.
* **Cache Penetration (缓存穿透):** Cache penetration refers to a situation where queries are made for data that does not exist in the database or the cache, usually through non-existent keys or IDs. This can lead to unnecessary database queries, increasing load and potentially affecting performance. Strategies to mitigate cache penetration include using a null object pattern (caching the null result for a non-existent key) or implementing tighter validation of input queries.
* **Cache Breakdown (缓存击穿):** Cache breakdown, also known as cache breakdown, occurs when a frequently accessed cache item expires, leading to concurrent requests hitting the database before the cache is refreshed. This can cause sudden spikes in database load, potentially leading to performance issues. Solutions to prevent cache breakdown include setting staggered expiration times, using a lock or semaphore to ensure only one query refreshes the cache, or employing "hot" data handling techniques where critical data is refreshed in the cache proactively.
* **Cache Avalanche (缓存雪崩):** A cache avalanche is a more severe issue that occurs when many, or even all, cache entries expire simultaneously or the cache fails entirely, leading to a massive surge of database requests that can overwhelm the database and cause widespread system failure. Strategies to avoid cache avalanches include using varied expiration times for cached items to prevent simultaneous expirations, implementing redundant caching systems, and ensuring that the system has fallback mechanisms in place.

## 9.3 Assorted

1. Reactive Programming
1. Failed retry will loose fairness
1. Distributed system, CAP problem.
1. Micro Services
    * 服务发现
    * 负载均衡
    * 超时控制
    * 熔断
    * 限流
    * 访问控制
    * 并发控制
    * 流量调度
1. Undo log vs. redo log
