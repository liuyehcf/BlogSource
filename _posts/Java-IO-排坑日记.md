---
title: Java-IO-排坑日记
date: 2018-11-01 15:31:38
tags: 
- 原创
categories: 
- Java
- IO
---

__阅读更多__

<!--more-->

# 1 PipeInputStream

todo

情景：

1. 需要管理一组PipeInputStream
1. 不想给每个PipeInputStream开一个线程，来读取数据
1. 需要实现一个StreamSelector，来轮询检查，若发现某个PipeInputStream有数据到达，就触发相应的回调方法执行读取数据的逻辑

问题：

1. 只要这个StreamSelector循环加上sleep，哪怕1纳秒，整个IO性能就会变得很差

原因：

1. PipeInputStream的默认buffer大小是1024，如果StreamSelector不sleep，那么每次调用InputStream.available方法能拿到的数据大概率小于1024，也就是数据的读取速度能够比得上数据的写入速度。一旦加上sleep，导致write数据堆积了一段时间，这段时间堆积的数据大概率大于1024，导致扫描一次无法拿到所有数据，最多1024，这就使得整个IO性能下降了

