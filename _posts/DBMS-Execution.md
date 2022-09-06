---
title: DBMS-Execution
date: 2022-06-24 08:33:17
mathjax: true
tags: 
- 摘录
categories: 
- Database
- Basic Concepts
---

**阅读更多**

<!--more-->

# 1 优化点

1. IO线程和执行线程速率的匹配。IO线程产生chunk的速率，和算子消费chunk的速率不对等。在push模型下，会增加调度次数，每次调度只处理了几个chunk
    * [introduce unplug mechanism to improve scalability](https://github.com/StarRocks/starrocks/pull/8979)