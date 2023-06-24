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
- Execution
    - Execution Model
        - Task-Based Parallelization
            - User Space Scheduling
                - Event-Driven Model
                - Polling-Driven Model
        - Volcano Model
            - Kernel Space Scheduling
- Database Optimization
    - Plan Stage Optimization
        - Parser
            - Grammar Checking
        - Analyzer
            - Type Processing
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
    - Execution Stage Optimization
        - Parallelism
        - Code Generation
        - Vectorization
        - Runtime Filter
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

## 3.1 Event-driven model & Polling Model

Event-Driven Model:

* Pros:
    1. Efficiency: In the event-driven model, the program only consumes resources when an event occurs. This leads to efficient resource utilization as the program is not constantly checking for events.
    1. Real-time responsiveness: The event-driven model is well-suited for real-time applications as it can quickly respond to events as they occur, allowing for immediate updates or actions.
    1. Modularity: Events and their associated handlers can be organized into separate modules or components, promoting modular and reusable code.
* Cons:
    1. Complex control flow: The event-driven model can lead to complex control flow, especially in larger applications with numerous event sources and handlers. Understanding and maintaining the flow of events can become challenging.
    * Potential event ordering issues: The order in which events occur and are processed can sometimes introduce subtle bugs or race conditions, requiring careful design and synchronization mechanisms.
    * Difficulty in debugging: Debugging event-driven programs can be more challenging due to their asynchronous nature. Tracking the flow of events and identifying the cause of issues can be trickier compared to sequential programs.

Polling Model:

* Pros:
    1. Simplicity: The polling model is straightforward to implement as it involves periodic checking for events. The program follows a sequential flow and is easy to understand.
    1. Control over event checking frequency: With polling, you have control over how frequently events are checked. This can be useful when events are expected to occur at predictable intervals.
    1. Compatibility: The polling model can be used in environments where event-driven mechanisms are not available or practical.
* Cons:
    1. Resource wastage: In the polling model, the program continuously checks for events, even if no events are occurring. This can lead to wasted computational resources and lower efficiency.
    1. Delayed responsiveness: The polling model may introduce latency in event handling since events are not immediately processed but rather checked at regular intervals. Real-time responsiveness can be compromised.
    1. Inefficient resource utilization: Continuous polling can consume unnecessary resources, especially in scenarios where events are infrequent or rare. This can impact system performance and scalability.

## 3.2 Cache vs. Materialized View

A cache is filled on demand when there is a cache miss (so the first request for a given object is always slow, and you have the cold-start problem mentioned in Figure 5-10). By contrast, a materialized view is precomputed; that is, its entire contents are computed before anyone asks for it—just like an index. This means there is no such thing as a cache miss: if an item doesn’t exist in the materialized view, it doesn’t exist in the database. There is no need to fall back to some other underlying database. (This doesn’t mean the entire view has to be in memory: just like an index, it can be written to disk, and the hot parts will automatically be kept in memory in the operating system’s page cache.)

With a materialized view there is a well-defined translation process that takes the write-optimized events in the log and transforms them into the read-optimized representation in the view. By contrast, in the typical read-through caching approach, the cache management logic is deeply interwoven with the rest of the application, making it prone to bugs and difficult to reason about
