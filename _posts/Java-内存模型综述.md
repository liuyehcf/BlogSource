---
title: Java-内存模型综述
date: 2017-07-08 21:08:00
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- Java Memory Model
---

**阅读更多**

<!--more-->

# 1 前言

前几篇博客对Java内存模型的基础知识和内存模型的具体实现进行了说明，本篇博文对Java内存模型的相关知识做一个总结

# 2 处理器的内存模型

顺序一致性内存模型是一个理论参考模型，JMM和处理器内存模型在设计时通常会以顺序一致性模型作为参照。在设计时，JMM和处理器内存模型会对顺序一致性模型做一些放松，因为如果完全按照顺序一致性模型来实现处理器和编译器，那么很多的处理器和编译器优化都要禁止，这对执行性能将会有很大影响

根据对不同类型的读/写操作组合的执行顺序的放松，可以把常见处理器的内存模型划分为如下几种类型

* 放松程序中写-读操作的顺序，由此产生了Total Store Ordering内存模型(简称为TSO)
* 在上面的基础上，继续放松程序中写-写操作的顺序，由此产生了Partial Store Order内存模型(简称为PSO)
* 在前面两条的基础上，继续放松程序中读-写和读-读操作的顺序，由此产生了Relaxed Memory Order内存模型(简称RMO)和PowerPC内存模型
* 注意，这里的处理器对读/写操作的放松，是以两个操作之间不存在数据依赖性为前提的(因为处理器要遵守as-if-serial语义，处理器不会对存在数据依赖性的两个内存操作做重排序)

下表展示了常见处理器内存模型的细节特征

| 内存模型名称 | 对应的处理器 | Store-Load重排序 | Store-Store重排序 | Load-Laod和Load-Store重排序 | 可以更早读取到其他处理器的写 | 可以更早读取到当前处理器的写 |
|:--|:--|:--:|:--:|:--:|:--:|:--:|
| TSO | sparc-TSO X64 | Y | N | N | N | Y |
| PSO | sparc-PSO | Y | Y | N | N | Y |
| RMO | ia64 | Y | Y | Y | N | Y |
| PowerPc | PowerPC | Y | Y | Y | Y | Y |

* 所有处理器内存模型都允许写-读重排序，因为它们都使用了写缓存区，写缓存区可能导致写-读重排
* 所有处理器内存模型都允许更早读到当前处理器的写，原因同样是因为写缓存区，由于写缓存区仅对当前处理器可见，这个特性导致当前处理器可以比其他处理器先看到临时保存在自己写缓存区中的写
* 由上到下，模型由强变弱，越是追求性能的处理器，内存模型设计会越弱。因为这些处理器希望内存模型对它们的束缚越少越好，这样它们就能做尽可能多的优化来提高性能
* **由于常见的处理器内存模型比JMM若，Java编译器产生字节码时，会在执行指令序列的适当位置插入内存屏障来限制处理器的重排序**。同时，由于各种处理器内存模型的强弱不同，为了在不同的处理器平台向程序员展示一个一致的内存模型，JMM在不同的处理器中需要插入的内存屏障和数量也不相同，下图展示了JMM在不同处理器内存模型中需要插入的内存屏障示意图

![JMM插入内存屏障示意图](/images/Java-内存模型综述/JMM插入内存屏障示意图.png)

**JMM屏蔽了不同处理器内存模型的差异，它在不同处理器平台之上为Java程序员呈现了一个一致的内存模型**

# 3 各种内存模型之间的关系

JMM是一个语言级的内存模型，处理器内存模型是硬件级的内存模型，顺序一致性内存模型是一个理论参考模型，下图是语言内存模型、处理器内存模型和顺序一致性内存模型的强弱对比示意图

![JMM插入内存屏障示意图](/images/Java-内存模型综述/各种CPU内存模型强弱对比示意图.png)

* 常见的4种处理器内存模型比常用的3种语言内存模型要弱
* 处理器内存模型和语言内存模型都比顺序一致性内存模型要弱
* 同处理器内存模型一样，越是追求执行性能的语言，内存模型设计得会越弱

# 4 JMM的内存可见性保证

按程序类型，Java程序的内存可见性保证可以分为下列3类

1. **单线程程序**：单线程程序不会出现内存可见性问题。编译器、runtime和处理器会共同确保单线程程序的执行结果与该程序在顺序一致性模型中的执行结果相同
1. **正确同步的多线程程序**：正确同步的多线程程序的执行将具有顺序一致性(程序的执行结果与该程序在顺序一致性内存模型中的执行结果相同)。**这是JMM关注的重点**，JMM通过限制编译器和处理器的重排序来为程序员提供内存可见性保证
1. **未同步/未正确同步的多线程程序**：JMM为它们提供了最小安全性保障：线程执行时读取到的值，要么是之前某个线程写入的值，要么是默认值(0、null、false)

注意，最小安全性保障与64位数据的非原子性写并不矛盾。它们是两个不同的概念，它们"发生"的时间点也不同

* 最小安全性保证对象默认初始化之后(设置成员域为0、null或false)，才会被任意线程使用。最小安全性"发生"在对象被任意线程使用之前
* 64位数据的非原子性写入"发生"在对象被多个线程使用的过程中(写共享变量)。当发生问题时(处理器B看到仅仅被处理器A"写了一半"的无效值)，这里虽然处理器B读到了一个被写了一半的无效值，但这个值仍然是处理器A写入的，只不过处理器A还没有写完而已
* **最小安全性保证线程读到的值，要么是之前某个线程写入的值，要么是默认值(0、null、false)。但最小安全性并不保证线程读到的值，一定是某个线程写完后的值。最小安全性保证线程读取到的值不会无中生有的冒出来，但并不保证线程读取到的值一定是正确的**

下图展示了这3类程序在JMM中与在顺序一致性内存模型中的执行结果的异同

![JMM插入内存屏障示意图](/images/Java-内存模型综述/JMM与顺序一致性模型对比示意图.png)

* 只要多线程程序是正确同步的，JMM保证该程序在任意的处理器平台上的执行结果，与该程序在顺序一致性内存模型中的执行结果一致

# 5 JSR-133对旧内存模型的修补

JSR-133对JDK5之前的旧内存模型的修补主要有两个

1. 增强volatile的语义。旧内存模型允许volatile变量与普通变量重排序。JSR-133严格限制volaitle变量与普通变量的重排序，使volatile的写-读和锁的释放-获取具有相同的内存语义
1. 增强final的内存语义。在旧的内存模型中，多次读取同一个final变量的值可能会不相同。为此JSR-133为final增加了两个重排序规则。在保证final引用不会从构造函数内逸出的情况下，final具有初始化安全性
    * 在构造函数内对一个final域的写入，与随后把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序
    * 初次读一个包含final域的对象的引用，与随后初次读这个final域，这两个操作之间不能重排序

# 6 参考

* 《Java并发编程的艺术》
