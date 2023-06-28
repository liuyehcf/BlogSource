---
title: Recap-of-Key-Points
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
- Collections
    - Array
    - List
    - Set
    - Map
- Functional Programming
    - Stream API
        - flatMap
    - Functional API
    - Lambda Expressions
- Generics
    - Type Erasure
- Reflection
    - Reflection API
    - Dynamic Proxy
- Serialization
- Annotation
    - Source
        - JSR-269
        - Lombok
    - Runtime
- Concurrent
    - Multithreading
    - Concurrency-Safe Containers
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
    - KISS
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
        - Mark-Sweep (Serial GC, Parallel GC)
        - Mark-Copy (Young Generation in Serial GC, Parallel GC):
        - Mark-Sweep-Compact (Parallel Old GC)
        - Mark and Concurrent Sweep (CMS GC)
        - Generational Algorithm (Most JVM GCs)
        - Mark-Region (G1 GC)
    - Garbage Collectors
        - Serial GC
        - Parallel GC
        - Concurrent Mark Sweep, CMS
        - G1 Garbage Collector
    - Java Memory Management
        - Heap
        - Stack
        - PermGen
        - Metaspace
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
- Frameworks
    - Sprint
    - Mybatis
    - Netty
    - JUnit & TestNG & Mockito & PowerMock
    - SLF4J & Log4j & Logback
{% endmarkmap %}

# 2 Cpp

{% markmap %}
- Key Features
    - Object-Oriented
        - Encapsulation
        - Polymorphism
        - Inheritance
        - Abstraction
- Cpp Features
    - C++11
    - C++14
    - C++17
    - C++20
- Preprocessor Directives
    - #include
    - #define & #undef
    - #ifdef & #ifndef & #else & #endif
    - #pragma
- Pointers and References
    - Pointer Stability
- Virtual Functions
    - override & final
- Overloading
    - Operator Overloading
    - Function Overloading
- Move Semantics
    - Perfect Forwarding
- Containers
    - vector
    - list
    - map
    - array
    - queue
    - deque
    - stack
- Templates
    - Standard Template Library (STL)
    - Templates Specialization
    - Variadic templates
    - Code Generation
    - Meta Programming
        - Type Traits
        - Type Deduction
        - Compile-time Programming
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
    - Table
        - Fact Table
        - Dimension Table
    - Column
    - Row
    - Key
        - Primary Key
        - Foreign Key
    - Constraints
        - Primary Key Constraint
        - Foreign Key Constraint
        - Unique Constraint
        - Not Null Constraint
        - Check Constraint
    - OLAP & OLTP
    - Database Auditing
    - Database Security
    - Database Access Control
    - Database Administration
- SQL Standard
    - Join
        - Inner Join
        - Full Outer Join
        - Left/Right Outer Join
        - Left/Right Semi Join
    - Aggregate
    - Window Function
        - Function
        - Partition By Clause
        - Order By Clause
        - Window Clause
            - Unbounded Window
            - Half Unbounded Window
            - Bounded Window
    - Predicate
    - View
    - Materialized View
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
- Transaction
    - ACID (Atomicity, Consistency, Isolation, Durability)
- Storage
    - Backup and Recovery
    - Replication
    - Sharding
    - Partitioning
    - Disaster Recovery
    - Compression
    - Encryption
    - Consistency
    - High Availability
    - Scalability
    - Consensus Protocol
        - Paxos
        - Raft
    - LSM-Tree
    - WAL
- Database Framework
    - Parser
        - Grammar Checking
    - Analyzer
        - Type Processing
    - Optimizer
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
            - Transformation Rules
            - Implementation Rules
        - Heuristic Optimization
            - Subquery
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
            - CTE(Common Table Expressions)
                - CTEProducer & CTEConsumer & CTEAnchor
                - Plan Enumeration
            - Multiply Stage Aggregate
                - 3 Stage Aggregate(COUNT(DISTINCT) + GROUP BY)
                - 4 Stage Aggregate(COUNT(DISTINCT))
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
                - Bloom-Filter 
                - In-Filter
                - Scenarios
                    - Join
                    - TopN
- Architecture
    - Shared Nothing Architecture
    - Shared Disk Architecture
    - Shared Memory Architecture
    - Shared Everything Architecture
    - Hybrid Architectures
    - Unified Storage and Computation
    - Separated Storage and Computation
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

## 3.4 Unclassified

1. 异步schema变更原理

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

# 5 Other

## 5.1 Unclassified

1. Reactive Programming
