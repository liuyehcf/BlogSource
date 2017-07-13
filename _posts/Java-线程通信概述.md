---
title: Java 线程通信概述
date: 2017-07-04 23:33:12
tags:
- 原创
categories:
- Java
- Java 并发
- 线程通信
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

在命令式编程中，线程之间的通信机制有两种

1. 共享内存
1. 消息传递

Java线程之间的通信采用的是共享内存，在共享内存的并发模型里，线程之间共享程序的公共状态，通过写-读内存中的公共状态进行__隐式通信__

# 2 同步

Java中可以利用内建的synchronized关键字来进行同步，同步意味着原本并发的程序将串行执行。那么通信是什么意思呢？根据JMM的happens-before规则，__锁的释放 happens-before 锁的获取__。这条规则的意思是：一个线程A在释放锁时会将当前线程中的共享变量刷新到主内存当中去，那么对于随后获取锁的线程B而言，线程B能够看到线程A对于共享变量的改变，而共享变量状态的变化则是线程A传递给线程B的消息。

这种通信方式的本质是共享内存，因此通信是隐式发生的。

另外Java concurrent包中提供的ReentrantLock也能进行线程之间的同步，因为ReentrantLock在释放锁时会进行volatile变量的写操作，在获取锁时会进行volatile变量的读操作。而volatile变量的写-读操作具有与锁释放-获取相同的内存语义。关于volatile的内存语义，详见{% post_link Java-volatile的内存语义 %}

volatile变量的读写操作本身也是同步的，也能进行线程间的通信。根据JMM的happens-before规则，__volatile写操作 happens-before volatile读操作__。这条规则的意思是：一个线程A在进行volatile写操作时会将当前线程中的共享变量刷新到主内存当中去，那么对于随后对同一个volatile变量进行volatile读操作的线程B而言，线程B能够看到线程A对于共享变量的改变，而共享变量状态的变化则是线程A传递给线程B的消息。

# 3 while轮询

# 4 wait/notify机制

# 5 BlockingQueue

# 6 管道
