---
title: Java volatile
date: 2017-07-04 16:02:54
tags:
categories:
- Java Memory Model
---

__目录__

<!-- toc -->
<!--more-->


# 1 前言

本篇博客将介绍volatile的内存语义以及volatile内存语义的实现

# 2 基本概念

__hapens-before__

* happens-before规则不是描述实际操作的先后顺序，它是用来描述可见性的一种规则
* A happens-before B：并不是说A必须在B之前执行，而是指__如果__动作A先于动作B发生，那么B能够看到动作A的改变，即可见性

__Memory Barrier__

* 为了保证内存可见性，Java编译器在生成指令序列的适当位置会插入内存屏障指令来禁止特定类型的处理器重排序

| 屏障类型 | 指令示例 | 说明 |
|:---|:---|:---|
| LoadLoad Barriers | Load1;LoadLoad;Load2 | 确保Load1数据的装载先于Load2及所有后续装载指令的装载 |
| StoreStore Barriers | Store1;StoreStore;Store2 | 确保Store1数据对其他处理器可见(刷新到内存)先于Store2及所有后续存储指令的存储 |
| LoadStore Barriers | Load1;LoadStore;Store2 | 确保Load1数据装载先于Store2及所有后续的存储指令刷新到内存 |
| StoreLoad Barriers | Store1;StoreLoad;Load2 | 确保Store1数据对其他处理器变得可见(指刷新到内存)先于Load2及所有后续装载指令的装载。StoreLoad Barriers会使该屏障之前的所有内存访问指令(存储和装载指令)完成之后，才执行该屏障之后的内存访问指令 |


* StoreLoad Barriers是一个全能型屏障，他同时具有其他3个屏障的效果。现代处理器大多数支持该屏障。执行该屏障开销会很昂贵，因为当前处理器通常要把写缓冲区中的数据全部刷新到内存中(Buffer Fully Flush)

# 3 volatile 写-读的内存语义

__volatile写的内存语义__

* 当写一个volatile变量时，JVM会把该线程对应的本地内存中的共享变量值刷新到主内存
* 因此，当别的线程从主内存中读取volatile变量时，一定保证是最新的，即最后一次写操作的值

__volatile读的内存语义__

* 当读一个volatile变量时，JVM会把该线程对应的本地内存置为无效。线程接下来将从主内存中读取共享变量
* 因此，当从主内存中读取volatile变量时，读取到的一定是当前或其他线程最后一次写操作的值

__总结__

* 当线程写一个volatile变量时，实质上是该线程向接下来要读这个volatile变量的某个或某些线程发送了一个消息(对共享变量做了修改)
* 当线程读一个volatile变量时，实质上是该线程接收了之前某个线程发出的一个消息(对共享变量做了修改)


# 4 volatile内存语义(可见性)

__volatile重排规则表__

| 第一个操作/第二个操作 | 普通读/写 | volatile读 | volatile 写|
|:---|:---|:---|:---|
| 普通读/写 | YES | YES | NO |
| volatile读 | NO | NO | NO |
| volatile 写| YES | NO | NO |


* 当第二个操作是volatile写时，不管第一个操作是什么，都不能重排序。这个规则确保volatile写之前的操作不会被编译器重排序到volatile写之后
    * 如果第一个操作是普通读写操作，第二个操作是volatile写操作，为什么也要禁止重排
    * 如果第一个操作是volatile写操作，第二个操作是普通读写操作，为什么不禁止重排
* 当第一个操作是volatile读时，不管第二个操作是什么，都不能重排序。这个规则确保volatile读之后的操作不会被编译器重排序到volatile读之前
    * 如果第一个操作是volatile读操作，第二个操作是普通读写操作，为什么也要禁止重排
    * 如果第一个操作是普通读写操作，第二个操作是volatile读操作，为什么不禁止重排
* 当第一个操作是volatile写，第二个操作是volatile读时，不能重排序

为了实现volatile的内存语义，编译器在生成字节码时，会在指令序列中插入内存屏障(lock addl)来禁止特定类型的处理器重排序。对于编译器来说，__发现一个最优布置来最小化插入屏障的总数几乎是不可能的__。因此，JVM采取保守策略

* 在每个volatile __写__ 操作 __前面__ 插入一个 __StoreStore__ 屏障
* 在每个volatile __写__ 操作 __后面__ 插入一个 __StoreLoad__ 屏障
* 在每个volatile __读__ 操作 __后面__ 插入一个 __LoadLoad__ 屏障
* 在每个volatile __读__ 操作 __后面__ 插入一个 __LoadStore__ 屏障


为了保证能正确实现volatile的内存语义，JMM采取了保守策略：在每个volatile写的后面，或者在每个volatile读的前面插入一个StoreLoad屏障。从整体执行效率的角度考虑，JMM最终选择了在每个volatile写的后面插入一个StoreLoad屏障。因为volatile写-读内存语义的常见使用模式是：一个写线程写volaitle变量，多个读线程读同一个volatile变量。当读线程的数量大大超过写线程时，选择在volatile写之后插入StoreLoad屏障将带来可观的执行效率提升

# 5 volatile内存语义的增强

在JSR-133之前的旧Java内存模型中，虽然不允许volatile变量之间重排序，但旧的Java内存模型允许volatile变量与普通变量重排序

在旧的内存模型中，volatile的写-读没有锁的释放-获取所具有的内存语义。__为了提供一种比锁更轻量级的线程之间的通信的机制__，JSR-133专家组决定增强volatile的内存语义：严格限制编译器和处理器对volatile变量与普通变量的重排序，__确保volatile的写-读和锁的释放-获取具有相同的内存语义__。从编译器重排序规则和处理器内存屏障插入策略来看，只要volatile变量与普通变量之间的重排序可能会破坏volatile的内存语义，这种重排序就会被编译器重排序规则和处理器内存屏障插入策略禁止


# 6 锁的内存语义(可见性)

锁可以让临界区互斥执行，但锁还有另一个同样重要且常常被忽视的功能：锁的内存语义

* 释放锁的线程向获取同一个锁的线程发送消息


__锁释放的内存语义__

* 当线程释放锁时，JMM会把该线程对应的本地内存中的共享变量刷新到主内存中
* 这就是synchronized关键字能保证 __可见性__ 的原因

__锁获取的内存语义__

* 当线程获取锁时，JMM会把该线程对应的本地内存置为无效
* 这就是synchronized关键字能保证 __可见性__ 的原因


__总结__

* 锁的释放与volatile写有相同的内存语义
* 锁的获取与volatile读有相同的内存语义
* 线程释放一个锁，实质上是该线程向接下来将要获取这个锁的某个线程发出(该线程对共享变量所做的修改)一个消息
* 线程获取一个锁，实质上是该线程接收了之前某个线程发出的(在释放这个锁之前对共享变量所做的修改)一个消息


# 7 CAS操作的内存语义(可见性)

```Java
    public final native boolean compareAndSwapInt(Object o, long offset, int expected, int x);
```

其源码如下

```C
    inline jint Atomic::cmpxchg(jint exchange_value, volatile jint* dest, jint compare_value){
        //alternative for InterlockedCompareExchange
        int mp = os::is_MP();
        __asm{
            mov edx, dest
            mov ecx, exchange_value
            mov eax, compare_value
            LOCK_IF_MP(mp)//程序会根据当前处理器的类型来决定是否为cmpxchg指令添加lock前缀
            cmpxchg dword ptr [edx], ecx
        }
    }
```

intel手册对lock的前缀说明如下

1. 确保对内存的读-改-写操作原子执行
1. 禁止该指令，与之前和之后的读和写指令重排序
1. 把写缓冲区中的所有数据刷新到内存中
* 第2点和第3点具有内存屏障效果，足以同时实现volatile读和volatile写的内存语义

# 8 参考

__Java并发编程的艺术__
