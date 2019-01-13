---
title: Java-volatile的内存语义
date: 2017-07-08 21:03:00
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- Java Memory Model
---

__阅读更多__

<!--more-->

# 1 前言

本篇博客将介绍volatile的内存语义以及volatile内存语义的实现

# 2 基本概念

__hapens-before__

* happens-before规则不是描述实际操作的先后顺序，它是用来描述可见性的一种规则
* A happens-before B：动作A发生在动作B之前，且动作A对于动作B来说可见(如果这两个动作之间不存在依赖而且重排序后不会影响执行结果，那么JVM可以对其进行重排序，也就是说真正的执行顺序并不一定，但是保证结果一致)

__Memory Barrier__

* 为了保证内存可见性，Java编译器在生成指令序列的适当位置会插入内存屏障指令来禁止特定类型的处理器重排序。JMM把内存屏障分为4类，如下表所示

| 屏障类型 | 指令示例 | 说明 |
|:---|:---|:---|
| LoadLoad Barriers | Load1;LoadLoad;Load2 | 确保Load1数据的装载先于Load2及所有后续装载指令的装载 |
| StoreStore Barriers | Store1;StoreStore;Store2 | 确保Store1数据对其他处理器可见(刷新到内存)先于Store2及所有后续存储指令的存储 |
| LoadStore Barriers | Load1;LoadStore;Store2 | 确保Load1数据装载先于Store2及所有后续的存储指令刷新到内存 |
| StoreLoad Barriers | Store1;StoreLoad;Load2 | 确保Store1数据对其他处理器变得可见(指刷新到内存)先于Load2及所有后续装载指令的装载。StoreLoad Barriers会使该屏障之前的所有内存访问指令(存储和装载指令)完成之后，才执行该屏障之后的内存访问指令 |

* StoreLoad Barriers是一个全能型屏障，他同时具有其他3个屏障的效果。现代处理器大多数支持该屏障。执行该屏障开销会很昂贵，因为当前处理器通常要把写缓冲区中的数据全部刷新到内存中(Buffer Fully Flush)

Memory Barrier的其他参考资料

* [Why Memory Barriers？](http://www.wowotech.net/kernel_synchronization/Why-Memory-Barriers.html)
* [CPU流水线的探秘之旅](http://blog.jobbole.com/40844/)

# 3 volatile的特性

理解volatile特性的一个好方法是把__对volatile变量的单个读/写，看成是使用同一个锁对这些单个读/写操作做了同步__，下面以一个示例来说明

```Java
class VolatileFeatureExample {
    volatile long vl = 0L;//使用volatile声明64位的long型变量

    public void set(long l) {
        vl = 1;//单个volatile变量的写
    }

    public void getAndIncrement() {
        vl++;//复合(多个)volatile变量的读/写
    }

    public long get() {
        return vl;//单个volatile变量的读
    }
}
```

* 假设有多个线程分别调用上面程序的3个方法，这个程序在语义上和下面程序等价

```Java
class VolatileFeatureExample {
    long vl = 0L;//64位的long型普通变量

    public synchronized void set(long l) {//对单个普通变量的写用一个锁同步
        vl = 1;
    }

    public void getAndIncrement() {//普通方法调用
        long temp = get();//调用已同步的读方法
        temp += 1L;//普通写操作
        set(temp);//调用已同步的写方法
    }

    public synchronized long get() {//对单个普通变量的读用同一个锁同步
        return vl;
    }
}
```

如上面的示例程序所示，一个volatile变量的单个读/写操作，与一个普通变量的读/写操作都是使用同一个锁来同步，它们之间的执行效果相同

* 锁的happens-before规则保证释放锁和获取锁的两个线程之间的内存可见性，这意味着对一个volatile变量的读，总是能看到(任意线程)对这个volatile变量的最后写入
* 锁的语义决定了临界区代码的执行具有原子性。这意味着，即使是64位的long型和double型变量，只要它是volatile变量，对该变量的读/写就具有原子性。如果是__多个volatile操作__或__类似于volatile++这种复合操作__，这些操作整体上就不具有原子性
    * 为什么多个volatile操作不具有原子性？答案很简单，这些volatile读写操作并不是连续着执行的，另一个线程可以看到中间状态：例如前n个volatile读写操作执行完毕，后m个volatile读写操作尚未执行时的状态

简而言之，volatile变量__自身__具有下列特性

* 可见性：对一个volatile变量的读，总能看到(任意线程)对这个volatile变量最后的写入
* 原子性：对任意单个volatile变量的读/写具有原子性，但是类似于volatile++这种复合操作不具有原子性

# 4 volatile 写-读建立的happens-before关系

上一小结结尾总结了volatile__自身__的特性，对程序员来说，volatile对线程的内存可见性的影响比volatile自身的特性更为重要，也更需要我们去关注

从JSR-133开始(JDK 1.5开始)，volatile变量的写-读可以实现线程之间的通信

从内存语义的角度来说，volatile的写-读与锁的释放-获取有相同的内存效果：

* volatile写和锁的释放有相同的内存语义
* volatile读与锁的获取有相同的内存语义

请看下面的示例

```Java
class VolatileExample {
    int a = 0;

    volatile boolean flag = false;

    public void writer() {
        a = 1;           //1
        flag = true;     //2
    }

    public void reader() {
        if (flag) {
            int i = a;   //3
            ...          //4
        }
    }
}
```

* __假设__线程A执行writer()方法之后，线程B执行reader()方法。根据happens-before规则，这个过程建立的happens-before关系可以分为3类，时序图如下
1. 根据程序次序规则：1 happens-before 2；3 happens-before 4
1. 根据volatile规则：2 happens-before 3
1. 根据happens-before的传递性规则，1 happens-before 4

```plantuml
Note over 线程A:1：线程A修改共享变量
Note over 线程A:2：线程A写volatile变量
Note over 线程B:3：线程B读同一个volatile变量
Note over 线程B:4：线程B读共享变量
```

* 这里A线程写一个volatile变量后，B线程读同一个volatile变量。__A线程在写volatile变量之前所有可见的共享变量，在B线程读同一个volatile变量后，将立即变得对B线程可见__(这是下文中提到的volatile重排规则表为什么要禁止普通读写与volatile读写重排序的原因之一)

# 5 volatile 写-读的内存语义

## 5.1 volatile写的内存语义

__volatile写的内存语义：当写一个volatile变量时，JVM会把该线程对应的本地内存中的共享变量(不仅仅是该volatile变量，而是该线程缓存的所有共享变量)值刷新到主内存__

* 因此，当别的线程从主内存中读取volatile变量时，一定保证是最新的，即最后一次写操作的值

以上面的示例程序VolatileExample为例，假设线程A首先执行writer()方法，随后线程B执行reader()方法，初始时两个线程的本地内存中的flag和a都是初始状态，下图是线程A执行volatile写之后，共享变量的状态示意图

![共享变量状态示意图](/images/Java-volatile/volatile写共享变量状态.png)

* 线程A在写flag变量后，本地内存A中被线程A更新过的__两个变量(volatile之后会插入StoreLoad内存屏障，这个屏障会将线程缓冲区内所有的变量刷新到主内存中去)__的值被刷新到主内存中。此时，本地内存A和主内存中的共享变量的值是一致的

## 5.2 volatile读的内存语义

__volatile读的内存语义：当读一个volatile变量时，JVM会把该线程对应的本地内存(不仅仅是该volatile对应的内存，而是该线程缓存的所有变量的内存)置为无效。线程接下来将从主内存中读取共享变量__

* 因此，当从主内存中读取volatile变量时，读取到的一定是当前或其他线程最后一次写操作的值

以上面的示例程序VolatileExample为例，假设线程A首先执行writer()方法，随后线程B执行reader()方法，初始时两个线程的本地内存中的flag和a都是初始状态，下图是线程B执行volatile读之后，共享变量的状态示意图

![共享变量状态示意图](/images/Java-volatile/volatile读共享变量状态.png)

* 在读flag变量后，本地内存和B包含的值已经被置为无效。此时，线程B必须从主内存中读取共享变量。线程B的读取操作将导致本地内存B和主内存中的共享变量的值变成一致

## 5.3 小结

如果我们把volatile写和volatile读两个步骤总和起来看，在读线程B读一个volatile变量之后，写线程A在写这个volatile变量之前所有可见的共享变量的值都将立即变得对线程B可见，下面对volatile写和volatile读的内存语义做个总结

* 当线程写一个volatile变量时，实质上是该线程向接下来要读这个volatile变量的某个线程发出了(该线程对共享变量所作修改的)消息
* 当线程读一个volatile变量时，实质上是该线程接收了之前某个线程发出的(某个线程在写这个volatile变量之前对共享变量所作修改的)消息

# 6 volatile内存语义的实现

下面来看看JMM如何实现volatile写/读的内存语义。重排序分为编译器和处理器重排序。为了实现volatile内存语义，JMM会分别限制这两种类型的重排序类型，下面是JMM针对编译器指定的__volatile重排规则表__

| 第一个操作/第二个操作 | 普通读/写 | volatile读 | volatile 写|
|:---|:---|:---|:---|
| 普通读/写 | YES | YES | NO |
| volatile读 | NO | NO | NO |
| volatile 写| YES | NO | NO |

1. 当第二个操作是volatile写时，不管第一个操作是什么，都不能重排序。这个规则确保volatile写之前的操作不会被编译器重排序到volatile写之后
1. 当第一个操作是volatile读时，不管第二个操作是什么，都不能重排序。这个规则确保volatile读之后的操作不会被编译器重排序到volatile读之前
1. 当第一个操作是volatile写，第二个操作是volatile读时，不能重排序

为了实现volatile的内存语义，编译器在生成字节码时，会在指令序列中插入内存屏障(lock addl)来禁止特定类型的处理器重排序。对于编译器来说，__发现一个最优布置来最小化插入屏障的总数几乎是不可能的__。因此，JVM采取保守策略

* 在每个volatile __写__ 操作 __前面__ 插入一个 __StoreStore__ 屏障
* 在每个volatile __写__ 操作 __后面__ 插入一个 __StoreLoad__ 屏障
* 在每个volatile __读__ 操作 __后面__ 插入一个 __LoadLoad__ 屏障
* 在每个volatile __读__ 操作 __后面__ 插入一个 __LoadStore__ 屏障

为了保证能正确实现volatile的内存语义，JMM采取了保守策略：在每个volatile写的后面，或者在每个volatile读的前面插入一个StoreLoad屏障。从整体执行效率的角度考虑，JMM最终选择了在每个volatile写的后面插入一个StoreLoad屏障。因为volatile写-读内存语义的常见使用模式是：一个写线程写volaitle变量，多个读线程读同一个volatile变量。当读线程的数量大大超过写线程时，选择在volatile写之后插入StoreLoad屏障将带来可观的执行效率提升

## 6.1 volatile重排规则表为什么这样制定

关于编译器和处理器禁止对 __volatile读__ 和 __volatile写__ 之间的重排序，很好理解

* volatile读和volatile是原子操作，并且volatile读-写操作具有与锁的加锁-解锁相同的内存语义，所以volatile读写之间是不能重排的

但是编译器为什么 __选择性__ 地禁止 __普通读写__ 和 __volatile读写__ 之间的重排序?

1. 如果第一个操作是普通读写操作，第二个操作是volatile写操作，为什么__要禁止__重排
1. 如果第一个操作是volatile写操作，第二个操作是普通读写操作，为什么__不禁止__重排
1. 如果第一个操作是volatile读操作，第二个操作是普通读写操作，为什么__要禁止__重排
1. 如果第一个操作是普通读写操作，第二个操作是volatile读操作，为什么__不禁止__重排

关于问题1和问题3，仍然以上文提到的示例程序VolatileExample进行讲解

* 如果不禁止`a = 1;`与`flag = ture;`之间的重排序，假设重排序后先执行`flag = ture;`，后执行`a = 1;`，这样会导致a的修改可能对线程B并不可见；而重排之前共享变量a的修改必然对线程B可见(因为volatile写之后会插入StoreLoad内存屏障，刷新所有缓存中的共享变量到主内存中去)。解答了问题1
* 如果不禁止`if (flag)`与`int i = a;`之间的重排序，假设重排序后先执行`int i = a;`(这里指的是读取共享变量a这部分操作，而i的赋值操作是不能先执行的，因为存在依赖，这里要注意)，后执行`if (flag)`(这里指的是读取共享变量flag这个操作，而if语句的操作是不能后执行的，因为存在依赖，这里要注意)，这样会导致线程B可能看到了一个尚未修改的共享变量a的值；而重排之前线程B必定能看到线程A对共享变量a的修改。解答了问题3
* 存在`volatile写 happens-before volatile读`的规则，而volatile写会将线程缓冲区所有共享变量刷新到主存当中，因此重排序普通读写与volatile写会导致程序结果发生变化。volatile读会将线程缓冲区所有共享变量置为无效状态，因此重排序volatile读与普通读写会导致程序结果发生变化。侧面解答了问题1和3

关于问题2和问题4，以如下示例程序进行讲解

```Java
class VolatileExample2 {
    volatile int a = 0;

    boolean flag = false;

    public void writer() {
        a = 1;           //1
        flag = true;     //2
    }

    public void reader() {
        if (flag) {
            int i = a;   //3
            ...          //4
        }
    }
}
```

* reader()以非volatile的变量作为if条件，而普通变量不具备可见性的保证，因此这本身就是非线程安全的。再怎么重排都不影响结果，回答了问题2和4

# 7 volatile内存语义的增强

在JSR-133之前的旧Java内存模型中，虽然不允许volatile变量之间重排序，但旧的Java内存模型允许volatile变量与普通变量重排序

__volatile内存语义的增强：选择性地禁止volatile变量与普通变量的重排序，目的是为了让volatile写-读具有与锁的释放-获取相同的内存语义__

* volatile写与锁的释放有相同的内存语义：__当线程 `释放锁`/`写volatile变量` 时，JMM会把该线程对应的(所有)本地内存中的共享变量刷新到主内存中__
* volatile读与锁的获取有相同的内存语义：__当线程 `获取锁`/`读volatile变量` 时，JMM会把该线程对应的(所有)本地内存置为无效，从而使得被监视器保护的临界区代码必须从主内存中读取共享变量__

在旧的内存模型中，volatile的写-读没有锁的释放-获取所具有的内存语义。__为了提供一种比锁更轻量级的线程之间的通信的机制__，JSR-133专家组决定增强volatile的内存语义：严格限制编译器和处理器对volatile变量与普通变量的重排序，__确保volatile的写-读和锁的释放-获取具有相同的内存语义__。从编译器重排序规则和处理器内存屏障插入策略来看，只要volatile变量与普通变量之间的重排序可能会破坏volatile的内存语义，这种重排序就会被编译器重排序规则和处理器内存屏障插入策略禁止

# 8 参考

* 《Java并发编程的艺术》

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
