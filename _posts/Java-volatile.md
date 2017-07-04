---
title: Java volatile
date: 2017-07-04 16:02:54
tags:
categories:
- Java Memory Model
---


# 前言

本篇博客将介绍volatile的内存语义以及volatile内存语义的实现


# happens-before

happens-before规则不是描述实际操作的先后顺序，它是用来描述可见性的一种规则

A happens-before B：并不是说A必须在B之前执行，而是指__如果__动作A先于动作B发生，那么B能够看到动作A的改变，即可见性


# volatile 写-读的内存语义

__volatile写的内存语义__

* 当写一个volatile变量时，JVM会把该线程对应的本地内存中的共享变量值刷新到主内存
* 因此，当别的线程从主内存中读取volatile变量时，一定保证是最新的，即最后一次写操作的值

__volatile读的内存语义__

* 当读一个volatile变量时，JVM会把该线程对应的本地内存置为无效。线程接下来将从主内存中读取共享变量
* 因此，当从主内存中读取volatile变量时，读取到的一定是当前或其他线程最后一次写操作的值

__总结__

* 当线程写一个volatile变量时，实质上是该线程向接下来要读这个volatile变量的某个或某些线程发送了一个消息(对共享变量做了修改)
* 当线程读一个volatile变量时，实质上是该线程接收了之前某个线程发出的一个消息(对共享变量做了修改)


# volatile内存语义的实现

__volatile重排规则表__

| 第一个操作/第二个操作 | 普通读/写 | volatile读 | volatile 写|
|:---|:---|:---|:---|
| 普通读/写 | YES | YES | NO |
| volatile读 | NO | NO | NO |
| volatile 写| YES | NO | NO |

* 当第二个操作是volatile写时，不管第一个操作是什么，都不能重排序。

# 参考

__Java并发编程的艺术__
