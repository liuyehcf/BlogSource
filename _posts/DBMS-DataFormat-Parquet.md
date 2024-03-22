---
title: DBMS-DataFormat-Parquet
date: 2024-03-22 08:33:17
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Data Format
---

**阅读更多**

<!--more-->

# 1 Format

![file-format-overview](/images/DBMS-Format-Parquet/file-format-overview.jpeg)

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃┏━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┓          ┃
┃┃┌ ─ ─ ─ ─ ─ ─ ┌ ─ ─ ─ ─ ─ ─ ┐┌ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃ RowGroup ┃
┃┃             │                            │ ┃     1    ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃└ ─ ─ ─ ─ ─ ─ └ ─ ─ ─ ─ ─ ─ ┘└ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃ColumnChunk 1  ColumnChunk 2 ColumnChunk 3  ┃          ┃
┃┃ (Column "A")   (Column "B")  (Column "C")  ┃          ┃
┃┗━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┛          ┃
┃┏━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┓          ┃
┃┃┌ ─ ─ ─ ─ ─ ─ ┌ ─ ─ ─ ─ ─ ─ ┐┌ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃│             │             ││              ┃ RowGroup ┃
┃┃             │                            │ ┃     2    ┃
┃┃│             │             ││              ┃          ┃
┃┃             │                            │ ┃          ┃
┃┃└ ─ ─ ─ ─ ─ ─ └ ─ ─ ─ ─ ─ ─ ┘└ ─ ─ ─ ─ ─ ─  ┃          ┃
┃┃ColumnChunk 4  ColumnChunk 5 ColumnChunk 6  ┃          ┃
┃┃ (Column "A")   (Column "B")  (Column "C")  ┃          ┃
┃┗━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━━━ ━┛          ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 1 ("A")             ◀─┃─ ─ ─│
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 1 ("A")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 2 ("B")               ┃     │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 3 ("C")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 3 ("C")               ┃     │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │
┃ Data Page for ColumnChunk 3 ("C")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 4 ("A")             ◀─┃─ ─ ─│─ ┐
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │  │
┃ Data Page for ColumnChunk 5 ("B")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │  │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 5 ("B")               ┃     │  │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃     │  │
┃ Data Page for ColumnChunk 5 ("B")               ┃
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃     │  │
┃┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  ┃
┃ Data Page for ColumnChunk 6 ("C")               ┃     │  │
┃└ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  ┃
┃┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃     │  │
┃┃Footer                                        ┃ ┃
┃┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓ ┃ ┃     │  │
┃┃ ┃File Metadata                             ┃ ┃ ┃
┃┃ ┃ Schema, etc                              ┃ ┃ ┃     │  │
┃┃ ┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┃ ┃ ┃
┃┃ ┃ ┃Row Group 1 Metadata              ┃     ┃ ┃ ┃     │  │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓             ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "A" Metadata┃ Location of ┃     ┃ ┃ ┃     │  │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ first Data  ┣ ─ ─ ╋ ╋ ╋ ─ ─
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ Page, row   ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┃Column "B" Metadata┃ counts,     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ sizes,      ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ min/max     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "C" Metadata┃ values, etc ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛             ┃     ┃ ┃ ┃
┃┃ ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┃ ┃ ┃        │
┃┃ ┃ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓     ┃ ┃ ┃
┃┃ ┃ ┃Row Group 2 Metadata              ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ Location of ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "A" Metadata┃ first Data  ┃     ┃ ┃ ┃        │
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ Page, row   ┣ ─ ─ ╋ ╋ ╋ ─ ─ ─ ─
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ counts,     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "B" Metadata┃ sizes,      ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛ min/max     ┃     ┃ ┃ ┃
┃┃ ┃ ┃┏━━━━━━━━━━━━━━━━━━━┓ values, etc ┃     ┃ ┃ ┃
┃┃ ┃ ┃┃Column "C" Metadata┃             ┃     ┃ ┃ ┃
┃┃ ┃ ┃┗━━━━━━━━━━━━━━━━━━━┛             ┃     ┃ ┃ ┃
┃┃ ┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛     ┃ ┃ ┃
┃┃ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃ ┃
┃┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛ ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## 1.1 Reference

* [parquet thrift definition](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift)

# 2 Optimizing queries

In any query processing system, the following techniques generally improve performance:

1. Reduce the data that must be transferred from secondary storage for processing (reduce I/O)
1. Reduce the computational load for decoding the data (reduce CPU)
1. Interleave/pipeline the reading and decoding of the data (improve parallelism)

The same principles apply to querying Parquet files, as we describe below:

1. Decode optimization
1. Vectorized decode
1. Streaming decode
1. Dictionary preservation
1. Projection pushdown
1. Predicate pushdown
1. RowGroup pruning
1. Page pruning
1. Late materialization
1. I/O pushdown

# 3 Tools

## 3.1 parquet-tools

[parquet-tools](https://github.com/ktrueda/parquet-tools)

**Example:**

* `parquet-tools show date.parquet`: Display data
* `parquet-tools inspect date.parquet`: Display schema

# 4 Reference

* [Querying Parquet with Millisecond Latency](https://arrow.apache.org/blog/2022/12/26/querying-parquet-with-millisecond-latency/)
