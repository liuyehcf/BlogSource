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

{% markmap %}
- Language
    - Java
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
            - Singleton Pattern
            - Factory Pattern
            - Observer Pattern
            - Builder Pattern
            - Adapter Pattern
            - Strategy Pattern
            - Decorator Pattern
            - Iterator Pattern
            - Proxy Pattern
            - Template Method Pattern
            - Command Pattern
            - Composite Pattern
            - Abstract Factory Pattern
            - State Pattern
            - Prototype Pattern
            - Facade Pattern
            - Bridge Pattern
            - Visitor Pattern
            - Chain of Responsibility Pattern
            - Mediator Pattern
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
    - Cpp
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
- Database
{% endmarkmap %}

# 1 Database

1. Database: 数据库
1. Relational Database Management System (RDBMS): 关系型数据库管理系统
1. Table: 表格
1. Column: 列
1. Row: 行
1. Primary Key: 主键
1. Foreign Key: 外键
1. Index: 索引
1. Query: 查询
1. Transaction: 事务
1. ACID (Atomicity, Consistency, Isolation, Durability): 原子性、一致性、隔离性、持久性
1. Normalization: 数据规范化
1. Denormalization: 数据反规范化
1. Joins: 连接操作
1. SQL (Structured Query Language): 结构化查询语言
1. Stored Procedure: 存储过程
1. Trigger: 触发器
1. Views: 视图
1. Data Manipulation Language (DML): 数据操纵语言
1. Data Definition Language (DDL): 数据定义语言
1. Database Schema: 数据库模式
1. Entity-Relationship (ER) Model: 实体-关系模型
1. Data Modeling: 数据建模
1. Data Warehouse: 数据仓库
1. Data Mining: 数据挖掘
1. Backup and Recovery: 备份与恢复
1. Replication: 复制
1. Sharding: 分片
1. Partitioning: 分区
1. Normal Forms: 正规化形式
1. Aggregate Functions: 聚合函数
1. Data Integrity: 数据完整性
1. Database Indexing: 数据库索引
1. Full-text Search: 全文搜索
1. Data Compression: 数据压缩
1. Data Encryption: 数据加密
1. Database Triggers: 数据库触发器
1. Data Consistency: 数据一致性
1. Data Warehousing: 数据仓储
1. NoSQL Databases: 非关系型数据库
1. Database Replication: 数据库复制
1. Database Clustering: 数据库集群
1. Database Mirroring: 数据库镜像
1. High Availability: 高可用性
1. Disaster Recovery: 灾难恢复
1. Data Warehousing: 数据仓库
1. Online Analytical Processing (OLAP): 联机分析处理
1. Data Mart: 数据集市
1. Data Mining: 数据挖掘
1. Data Cleansing: 数据清洗
1. Data Migration: 数据迁移
1. Data Backup: 数据备份
1. Data Recovery: 数据恢复
1. Database Auditing: 数据库审计
1. Database Security: 数据库安全
1. Database Performance Tuning: 数据库性能调优
1. Database Optimization: 数据库优化
1. Database Scalability: 数据库可扩展性
1. Data Consistency: 数据一致性
1. Database Access Control: 数据库访问控制
1. Data Warehousing: 数据仓库
1. Star Schema: 星型模式
1. Snowflake Schema: 雪花模式
1. Dimensional Modeling: 维度建模
1. Extract, Transform, Load (ETL): 提取、转换、加载
1. Data Mart: 数据集市
1. Fact Table: 事实表
1. Dimension Table: 维度表
1. Data Mining: 数据挖掘
1. Data Governance: 数据治理
1. Master Data Management (MDM): 主数据管理
1. Data Quality Management: 数据质量管理
1. Data Integration: 数据集成
1. Data Virtualization: 数据虚拟化
1. Data Replication: 数据复制
1. Data Masking: 数据脱敏
1. Data Archiving: 数据归档
1. Data Modeling Tools: 数据建模工具
1. Database Administration: 数据库管理
1. Big Data: 大数据
1. Data Definition Language (DDL): 数据定义语言
1. Data Manipulation Language (DML): 数据操纵语言
1. Data Control Language (DCL): 数据控制语言
1. Database Triggers: 数据库触发器
1. Stored Procedures: 存储过程
1. Database Views: 数据库视图
1. Database Constraints: 数据库约束
1. Data Warehouse: 数据仓库
1. Data Mart: 数据集市
1. Data Mining: 数据挖掘
1. Data Governance: 数据治理
1. Data Profiling: 数据剖析
1. Data Cleansing: 数据清洗
1. Data Modeling: 数据建模
1. Database Normalization: 数据库规范化
1. Database Indexing: 数据库索引
1. Database Partitioning: 数据库分区
1. Database Replication: 数据库复制
1. Database Sharding: 数据库分片
1. Data Backup and Recovery: 数据备份与恢复
1. unified storage and computation: 存算一体
1. separation of storage and computation: 存算分离

## 1.1 Event-driven model & Polling Model

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
