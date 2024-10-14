---
title: DataStructure-LSM-Tree
date: 2021-08-16 15:12:30
tags: 
- 摘录
categories: 
- Data Structure
- Tree
---

<!--more-->

# 1 Introduction

LSM-tree stands for Log-Structured Merge Tree. It is a data structure used in computer systems, particularly in storage and database systems, to efficiently manage and store large volumes of data with high write throughput.

The LSM-tree structure is designed to optimize write operations, which are typically more expensive in traditional storage structures. It achieves this by leveraging the characteristics of sequential disk I/O and reducing the number of random disk accesses.

The basic idea behind LSM-trees is to separate write and read operations by maintaining multiple levels of data structures. When data is written, it is first inserted into an in-memory component called a memtable, which serves as a write buffer. The memtable is typically implemented as a skip list or a hash table for efficient insertion and retrieval.

Periodically, the contents of the memtable are flushed to disk as sorted run files, also known as SSTables (Sorted String Tables). SSTables are immutable and ordered by the keys, which allows efficient sequential reads. Each SSTable corresponds to a specific time interval or a size limit.

To handle read operations efficiently, LSM-trees use a combination of the in-memory memtable and the on-disk SSTables. When a read request arrives, the LSM-tree first checks the memtable for the requested data. If the data is not found there, it searches the SSTables in a bottom-up manner, starting from the most recent SSTable to the oldest. This process is known as a merge operation.

To maintain consistency and prevent data inconsistencies between the memtable and SSTables, LSM-trees employ background compaction processes. Compaction merges overlapping or redundant data from SSTables into a new, compacted SSTable. This process reduces the number of SSTables and helps to optimize read performance.

LSM-trees provide several advantages:

1. Efficient write performance: The LSM-tree structure optimizes write operations by buffering writes in an in-memory component and reducing disk random accesses.
1. Scalability: LSM-trees can efficiently handle large volumes of data and scale horizontally by adding more machines to the system.
1. Crash recovery: The LSM-tree's append-only design and use of SSTables make crash recovery simpler and faster by replaying the write-ahead logs.
1. Flexibility: LSM-trees can be tuned to balance the trade-offs between write and read performance based on system requirements.

LSM-trees are widely used in various storage and database systems, including Apache Cassandra, LevelDB, RocksDB, and HBase, to name a few.

# 2 Implementation

## 2.1 Core Components

1. `Memtable`: An in-memory key-value store (often implemented as a sorted tree like a Red-Black Tree or SkipList).
1. `Immutable Memtable`: When a memtable is full, it becomes immutable and awaits flushing to disk.
1. `SSTables (Sorted String Tables)`: Disk-based, read-only data structures that store sorted key-value pairs.
1. `Write-Ahead Log (WAL)`: A log to ensure durability by recording operations before writing them to the memtable.
1. `Compaction`: Merges multiple SSTables to remove duplicates and reclaim space.

## 2.2 Operations in an LSM Tree

**On a Write Operation**

1. Log the operation in the Write-Ahead Log (WAL):
    * This ensures that the data can be recovered in case of a crash before it's written to the SSTable.
1. Write the key-value pair to the active memtable:
    * The memtable is a fast, in-memory data structure (e.g., a Red-Black Tree or SkipList) that holds the latest data.

**When the Memtable is Full**

1. Convert the active memtable into an immutable memtable:
    * The active memtable is marked as immutable. No further writes are allowed to it, ensuring thread safety during the flush operation.
1. Flush the immutable memtable to disk as an SSTable:
    * The immutable memtable is serialized into a new SSTable (Sorted String Table) on disk.
1. Clear the active memtable:
    * Once the immutable memtable is flushed, the active memtable is reset, and a new memtable is ready to accept writes.

**Periodic Compaction**

1. Identify SSTables for compaction:
    * As more SSTables are created, older ones may contain duplicate or obsolete key-value pairs. Compaction ensures that these are merged into a single, optimized SSTable.
1. Merge SSTables:
    * Compaction reads multiple SSTables, removes redundant or outdated entries, and creates a new SSTable with the latest values.
1. Delete the old SSTables:
    * Once compaction is complete, the old SSTables are removed to save space.

**Read Operation**

1. Search the active memtable:
    * On a read request, the system first checks the active memtable.
1. Search the immutable memtable (if any):
    * If the key is not found in the active memtable, the system checks the immutable memtable (if it exists).
1. Search SSTables on disk:
    * If the key is not found in the memtables, the system searches the SSTables on disk using the index block for efficient lookups.
    * Bloom filters (if used) help determine if the key might exist in an SSTable to avoid unnecessary disk reads.