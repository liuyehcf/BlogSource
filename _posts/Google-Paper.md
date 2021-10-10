---
title: Google-Paper
date: 2019-02-11 16:18:03
mathjax: true
tags: 
- 原创
categories: 
- Paper
- Google
---

**阅读更多**

<!--more-->

# 1 History

## 1.1 The anatomy of a large-scale hypertextual Web

### 1.1.1 Key Word

1. `link structure`
1. `PageRank`

### 1.1.2 Goal

1. `quality`: 人类阅读的水平并未随着信息数量的增长而增长，仅仅愿意阅读前10个结果
    * 如何避免垃圾结果
    * 如何按照质量排序结果
1. `scalability`

### 1.1.3 Feature

1. 充分利用`link structure`来为每个网页计算`PageRank`
1. 充分利用`Anchor text`来优化搜索结果

**PageRank**: 网页质量以及重要程度的量化，它不是简单地计算该网页被引用的次数，假设网页{% raw %}$T_1${% endraw %}, {% raw %}$T_2${% endraw %}, ..., {% raw %}$T_n${% endraw %}都引用了网页{% raw %}$A${% endraw %}，那么网页A的`PageRank`可以表示为

{% raw %}$$
PR(A)=(1-d)+d(\frac{PR(T_1)}{C(T_1)}+...+\frac{PR(T_n)}{C(T_n)})
$${% endraw %}

* 其中{% raw %}$C(A)${% endraw %}表示网页A包含的引用数量，即网页A的出度
* {% raw %}$d${% endraw %}为阻尼因子，在0-1之间，通常设置为0.85

**Anchor text**: 链接文本在搜索引擎中是非常重要的，很多搜索引擎仅仅把链接文本与链接文本所在的网页关联起来，但是Google将链接文本与连接所指向的网页关联起来

### 1.1.4 System anatomy

1. `Crawler`: 爬虫，负责下载网页
1. `URL Server`: 负责向`Crawler`输送链接
1. `Store Server`: 将`Crawler`下载的网页压缩并存储到`Repository`
1. `Indexer`: 从`Repository`读取数据并将其解压缩成网页，然后解析这些网页，每个网页都以单词维度进行分解，并用一种称为`hits`的数据结构来存储这些数据，每个`hits`存储了单词、在文中的位置、字体大小、大小写等信息（一个单词对对应着一个`hit list`）。随后`Indexer`将这些`hits`分发到`Barrels`中。此外，`Indexer`将网页中重要的信息封装成一个`Anchor File`存储到`Anchors`中
1. `URL Resolver`: 从`Anchors`读取这些`Anchor File`，将相对URL转换成绝对URL，并生成`docID`，并建立`Anchor`与`docId`的关联。此外，`URL Resolver`创建了一个`Link`的数据库（`docId pair`），该数据库用于计算`PageRank`
1. `Sorter`: 从`Barrel`中取出已经按照docId排序的`hits`，然后按照`wordID`进行排序并以此创建反向索引(`inverted index`)
1. `Lexicon`: 根据`Indexer`创建的词库以及`inverted index`来构建`Searcher`的词库
1. `Searcher`: 搜索者

![fig1](/images/Google-Paper/fig1.png)

### 1.1.5 Data Structure

Google搜索引擎的数据结构经过大量的优化，已达到存储海量爬虫数据、索引、快速搜索的目的。虽然硬件正在快速迭代发展，但是一次硬盘搜索需要消耗10ms，因此Google搜索引擎的设计就是要尽可能地避免硬盘查找，这一设计思路很大程度上决定了数据结构的设计

所有的数据都存储在分布式文件系统上，原始的HTML文本占据了大约一半的存储空间

`document index`采用的是定长索引，`ISAM(Index sequential access mode) index`，索引根据`docID`进行排序。`document index`包含了当前文档的状态、文档的存储位置，文档校验和，以及一些变量数据。同时，例如URL、标题这样的变长数据存储在另一个单独的文件中。此外，存在一个副索引(`auxiliary index`)，用于将`URL`转换成`docID`。词库根据不同的操作会有不同的表现形式，这些词库都是基于内存的哈希表

`hit list`记录了一个单词的相关信息，包括出现位置，字体大小等。`hit list`包含了正向和反向索引，因此占据了大量的空间，`hit list`的编码十分重要（候选的算法包括简单的编码，压缩编码，以及霍夫曼编码），Google选用了优化的压缩算法，因为该算法相比于简单的编码更节省空间；相比于霍夫曼编码复杂度更小。在该算法中，每个`hit`占据了两个字节的大小，且`hit list`最开始存储了`hit`的长度，为了进一步节省空间，长度和`wordID`被编码进了正向索引，长度和`docID`被编码进了反向索引

正向索引由`Indexer`生成，并存储到`Barrels`中，通常一篇文章的单词对应的`hit`会分散存储到不同的`Barrel`中，每个存储着这些`hit`的`Barrel`都会记录这篇文章的`docID`。反向索引包含了相同的`Barrel`，对于每个有效的`wordID`，`lexicon`都存储着该`wordId`对应的`hit`所在的`barrel`。反向索引指向一个`docID`列表，以及这些文章对应的`hit`列表，这个列表表示包含该单词的所有文章的集合

总结

1. 正向索引：`doc->word list`
1. 反向索引：`word->doc list`

一个非常重要的问题就是这些`docID`在`doc list`中出现的顺序。一个简单的方法就是按照`docId`对其进行排列，这种方式易于对多关键字搜索的结果进行合并。另一种方式就是一句该单词在不同文章中出现的次数来进行排序，但这样会导致合并难以进行。最终选用了一种折衷方案，将`barrel`分为两组，一组用于存储包含文章标题的`hit list`或者包含`anchor`的`hit list`；另一组包含了所有的`hit list`，在这种方案下，位于第一组`barrel`的`hit list`所对应的文章优先级高

## 1.2 Crawling the Web

网页爬虫也是一个挑战极大的任务，它不仅涵盖性能、实现性的问题，而且可能包含社会问题

一个主要的性能压力来自DNS搜索，因此每个爬虫程序都有一个本地的DNS缓存

# 2 Cloud Programming Simplified: A Berkeley View on Serverless Computing

对于一个低层级的抽象，比如`AWS-EC2`、`Alibaba-ECS`等，用户通常还需要如下配置

1. 多副本部署，避免单机故障
1. 多机房部署，容灾
1. 负载均衡+消息路由
1. 自动的缩容与扩容
1. 健康检查
1. 调试或者监控所需的日志
1. 系统升级
1. 迁移

简单来说，`serverless computing=FaaS + BaaS`，换言之，必须在无用户提供任何物质的情况下，自动扩容缩容，且按量收费

`Serverless Computing`与`Serverful Computing`的区别

1. 解耦运算与存储，运算与存储得以分离，并且能够独立计价。通常，存储由独立的云服务提供，而计算通常是无状态的
1. 执行代码而不管理资源分配。用户不是请求资源，而是提供一段代码，云自动提供资源来执行该代码
1. 基于使用的资源而非分配的资源来进行收费

`Serverless`的概念早在90年代已经提出，现代的`Serverless`与90年代的`Serverless`存在以下几点差异

1. 更好的扩容/缩容能力
1. 存储隔离
1. 更好的灵活性
1. 服务生态

为了加速`VM-like isolation`环境的创建，AWS引入`warm pool`以及`active pool`，最近许多提案都旨在降低租户隔离的系统开销，手段包括

1. containers
1. unikernels
1. library OSes
1. language VMs

`Kubernetes`是服务于`Serverful Computing`的。`Hosted Kubernetes`是一种类似于`Serverless Computing`的模式，它们之间的区别是：计费方式的差异，`Hosted Kubernetes`基于分配资源来进行收费，而`Serverful Computing`基于实际使用的资源来进行收费
