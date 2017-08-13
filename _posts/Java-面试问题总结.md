---
title: Java 面试问题总结
date: 2017-07-05 08:51:57
tags: 
- 原创
categories: 
- Job
- Java
---

__目录__

<!-- toc -->
<!--more-->

# 1 Java基础

1. 面向对象的三大特性
    > 封装
    > 继承
    > 多态

1. 重载与多态
    > 重载横向，静态双分派。a.f(b)，a的静态类型+b的静态类型
    > 纵向，动态双分派。a.f(b)，a的动态类型+b的静态类型

1. Object的public方法
    > 1. getClass：获取Class对象的实例
    > 1. hashCode：获取hash值，HashMap的实现依赖于hashcode。两个对象的hashCode可能是相同的。默认值与内存位置有关
    > 1. equals：判断对象是否相等
    > 1. toString：返回一个表示当前对象的String
    > 1. notify：重量级锁的wait/Notify机制
    > 1. notifyAll：重量级锁的wait/Notify机制
    > 1. wait：重量级锁的wait/Notify机制

1.  Object的protected方法
    > 1. clone：浅拷贝，仅复制内存，如果包含引用类型，那么拷贝前后将会指向同一个对象
    > 1. finalize：与垃圾收集有关，第一次回收时会调用该方法，但不保证调用，也不保证正确执行。因此别用这个东西，历史遗留问题

1. cloneable接口与浅拷贝/深拷贝
    > 实现cloneable接口必须调用父类Object.clone()方法来进行内存的拷贝
    > 如果不加其他的逻辑，实现的就是浅拷贝。即副本中的内存与原象中的内存完全一致，意味着如果存在引用类型，那么副本与原象将引用的是同一个对象
    > 如果要实现深拷贝，那么就需要加上额外的实现逻辑

1. String/StringBuffer/StringBuilder的区别
    > 1. 只有String中的char[]数组是final的
    > 1. StringBuffer是线程安全的，所有char[]数组的access方法被synchronized关键字修饰
    > 1. StringBuilder非线程安全

1. 容器常用接口
    > 1. Collection
    > 1. List
    > 1. Set
    > 1. Map
    > 1. Queue

1. 容器常用实现
    > 1. ArrayList
    > 1. LinkedList
    > 1. HashSet
    > 1. HashMap
    > 1. TreeMap
    > 1. LinkedHashMap

1. Arrays.sort实现原理
    > 针对对象类型和基本类型，Arrays.sort会采用不同的排序算法
    > 1. 对象类型必须保证稳定性，因此采用的是插入排序以及归并排序的优化版本TimSort，具体详见{% post_link Java-ComparableTimSort-源码剖析 %} 
    > 1. 基本类型的稳定性是不必要的，因此根据数组的长度以及分布规律选择特定的排序算法，包括插入排序，快速排序(3-way-quicksort以及2-pivot-quicksort)，具体详见{% post_link Java-DualPivotQuickSort-源码剖析 %}

1. Collection.sort实现原理
    > Collection.sort在内部会转调用Arrays.sort
    > 1. 调用List#toArray()方法，生成一个数组
    > 1. 调用Arrays.sort方法进行排序
    > 1. 将排序好的序列利用迭代器回填到List当中(为什么用迭代器，因为这样效率是最高的，如果List的实现是LinkedList，那么采用下标将会非常慢)

1. LinkedHashMap的应用
    > 实现一个LRU(Least Recently Used)

### 1.0.1 HashMap的并发问题

http://www.cnblogs.com/kxdblog/p/4323892.html

1. 多线程put操作后，get操作导致死循环。(扩容时)
1. 多线程put非NULL元素后，get操作得到NULL值。(扩容时，插入到了旧表中)
1. 多线程put操作，导致元素丢失。

### 1.0.2 Hashtable和HashMap的区别及实现原理，HashMap会问到数组索引，hash碰撞怎么解决

hashtable给所有的table访问方法加上了synchronized关键字

### 1.0.3 HashMap如何解决碰撞

用链表解决，当链表元素过多时，转换为红黑树

## 1.1 字节码

{% post_link Java-Class文件结构以及字节码阅读 %}

### 1.1.1 foreach和while在编译之后的区别

foreach只能引用于实现了Iterator接口的类，因此在内部实现时会转化为迭代器的遍历，本质上是一种语法糖

while和for循环在编译之后基本相同，利用字节码`goto`来进行循环跳转

## 1.2 泛型

### 1.2.1 擦除

## 1.3 反射

### 1.3.1 反射的原理

### 1.3.2 Class.forName和ClassLoader#loadClass

Class.forName执行过程

1. 加载
1. 验证-准备-解析：该过程称为链接
1. 初始化

ClassLoader#loadClass执行过程

1. 加载

{% post_link Java-类加载机制 %}

### 1.3.3 获取Class对象的方式

1. `Class clazz = Class.forName(<string>)`
1. `Class clazz = obj.getClass()`
1. `Class clazz = <class>.class`

## 1.4 IO

### 1.4.1 Java NIO使用

{% post_link Java-NIO %}

## 1.5 动态代理

{% post_link JDK-动态代理-源码剖析 %}

## 1.6 线程池

{% post_link Java-concurrent-ThreadPoolExecutor-源码剖析 %}

### 1.6.1 线程池的目的

### 1.6.2 线程池的种类，区别和使用场景

所有线程池本质上都是ThreadPoolExecutor，只是配置了不同的初始化参数，核心参数有

1. __corePoolSize__：核心线程数量，所谓核心线是指即便空闲也不会终止的线程(allowCoreThreadTimeOut必须是false)
1. __maximumPoolSize__：最大线程数量，核心线程+非核心线程的总数不能超过这个数值
1. __keepAliveTime__：非核心线程在空闲状态下保持active的最长时间，超过这个时间若仍然空闲，那么该线程便会结束

Executors.newCachedThreadPool()

* __corePoolSize__：0
* __maximumPoolSize__：MAX
* __keepAliveTime__：60L

Executors.newSingleThreadExecutor()

* __corePoolSize__：1
* __maximumPoolSize__：1
* __keepAliveTime__：0L

Executors.newFixedThreadPool(int nThread)

* __corePoolSize__：nThread
* __maximumPoolSize__：nThread
* __keepAliveTime__：0L

### 1.6.3 分析线程池的实现原理和线程的调度过程

添加一个新的Runnable时

1. 当前线程数量小于最大线程数量时，新开一个线程
1. 当线程数量大于最大线程时，直接将任务压入任务队列

Work即一个工作的线程，会从BlockingQueue获取任务并执行

### 1.6.4 线程池如何调优

http://www.cnblogs.com/jianzh5/p/6437315.html

## 1.7 JDK各个版本的特性

{% post_link JDK-新特性 %}

## 1.8 设计模式

### 1.8.1 单例模式

{% post_link 设计模式-单例模式 %}

{% post_link Java-单例双重检测正确性分析 %}

# 2 JVM相关

## 2.1 垃圾回收

### 2.1.1 垃圾收集算法

{% post_link Java-垃圾收集算法 %}

### 2.1.2 垃圾收集器

{% post_link Java-垃圾收集器 %}

### 2.1.3 JVM参数

{% post_link JVM-常用参数 %}

### 2.1.4 JVM内存分代

新生代、老年代、永久代

JDK 8中并无物理上分隔的分代，仅仅保留概念，取而代之的是Region

其中新生代采用的是复制算法，Eden和Survivor分为8：1

__Java 8的内存分代改进__

1. 用Region来替代，仅仅保留新生代和老年代的概念。
1. G1收集器会维护一个Region的列表，每次回收一个最有受益的Region，这也是G1收集器名字的来源，Garabage first

### 2.1.5 何时触发MinorGC等操作

当堆内存使用量超过一个阈值时进行垃圾回收(针对的是CMS，因为是并发的，需要预留空间给用户使用)，或者主动调用System.gc触发

`-XX:InitiatingHeapOccupancyPercent` 参数可以设置这个阈值

### 2.1.6 jvm中一次完整的GC流程(从ygc到fgc)是怎样的，重点讲讲对象如何晋升到老年代，几种主要的jvm参数等

ygc和fgc是什么意思？

{% post_link JVM-常用参数 %}

### 2.1.7 新生代和老生代的内存回收策略

新生代：复制算法，因为对象朝生夕死

老年代：标记-清除或者标记整理

### 2.1.8 Eden和Survivor的比例分配等

默认8：1，如果不够用，则由老年代来担保

### 2.1.9 G1和CMS的区别，吞吐量优先和响应优先的垃圾收集器选择

G1(Gargabe-First)收集器是当今收集器计数发展的最前沿成果之一。G1是一款面向服务端应用的垃圾收集器，HotSpot开发团队赋予它的使命是(在比较长期的)未来可以替换掉JDK 1.5中发布的CMS收集器，与其他GC收集器相比，G1具备如下特点：

* __并行与并发__：G1能充分利用多CPU，多核环境下的硬件优势，使用多个CPU(或CPU核心)来缩短Stop-The-World停顿的时间(并行)，部分其他收集器原本需要停顿Java线程执行的GC动作，G1收集器仍然可以通过并发的方式让Java程序继续执行
* __分代收集__：与其他收集器一样，分代的概念在G1中仍然保留，虽然G1可以不需要其他收集器配合就能独立管理整个GC堆，但它能够采用不同的方式去处理新创建的对象和已经存活了一段时间的、熬过多次GC的旧对象以获取更好的收集效果
* __空间整合__：与CMS的"标记-清理"算法不同，G1从整体来看是基于"标记-清理"算法实现的收集器，从局部(两个Region之间)上来看是基于"复制"算法实现的，这两种算法都意味着G1运作期间不会产生内存空间碎片，收集后能提供规整的可用内存
* __可预测的停顿__：这是G1相对于CMS的另一大优势，降低停顿时间是G1和CMS共同的关注点，但G1除了追求低停顿外，还能建立可预测的停顿时间模型，能让使用者明确指定在一个长度为M毫秒的时间片段内，消耗在垃圾收集上的时间不得超过N毫秒

### 2.1.10 强/软/弱/虚引用与GC

{% post_link Java-对象生命周期 %}

### 2.1.11 OutOfMemory

经过GC后，仍然无法为新产生的对象分配内存空间

### 2.1.12 StackOverFlow

函数调用层次太深，或者栈内存太小

### 2.1.13 PermGen Space

反射或者动态代理生成的类型对象过多

## 2.2 类加载机制

类加载过程如下

1. 加载：获取.class文件的二进制字节流
1. 验证：文件格式验证、元数据验证、字节码验证、符号引用验证
1. 准备：内存清零
1. 解析：将符号引用替换为直接引用
1. 初始化：执行静态初始化语句以及静态子句
* 验证、准备、解析称为链接

{% post_link Java-类加载机制 %}

### 2.2.1 双亲委派

{% post_link Java-类加载机制 %}

### 2.2.2 三个类加载器

1. Bootstrap ClassLoader
1. Extension ClassLoader
1. Application ClassLoader

{% post_link Java-类加载机制 %}

### 2.2.3 类的初始化顺序

比如父类静态数据，构造函数，字段，子类静态数据，构造函数，字段，他们的执行顺序

以一个程序来说明

```Java
public class Test {
    public static int init(String s) {
        System.out.println(s);
        return 1;
    }

    public static void main(String[] args){
        new Derive();
    }
}

class Base {
    private static int si = Test.init("init Base's static field");

    private int i=Test.init("init Base's field");

    static{
        Test.init("init Base's static Statement");
    }

    {
        Test.init("init Base's Statement");
    }

    public Base(){
        Test.init("init Base's constructor");
    }
}

class Derive extends Base{
    private static int si = Test.init("init Derive's static field");

    private int i=Test.init("init Derive's field");

    static{
        Test.init("init Derive's static Statement");
    }

    {
        Test.init("init Derive's Statement");
    }

    public Derive(){
        Test.init("init Derive's constructor");
    }
}
```

以下是输出

```
init Base's static field
init Base's static Statement
init Derive's static field
init Derive's static Statement
init Base's field
init Base's Statement
init Base's constructor
init Derive's field
init Derive's Statement
init Derive's constructor
```

### 2.2.4 环境变量classpath

说一说你对环境变量classpath的理解？如果一个类不在classpath下，为什么会抛出ClassNotFoundException异常，如果在不改变这个类路径的前期下，怎样才能正确加载这个类？

环境变量classpath是JVM的App ClassLoader类加载器的加载*.class文件的路径

加载类的过程可以交给自定义的类加载器来执行，可以自定义类加载器，可以从任何地方获取一段.class文件的二进制字节流，这便是类的加载过程

## 2.3 class文件结构

## 2.4 JMM

1. {% post_link Java-内存模型基础 %}
1. {% post_link Java-重排序 %}
1. {% post_link Java-顺序一致性 %}
1. {% post_link Java-volatile的内存语义 %}
1. {% post_link Java-锁的内存语义 %}
1. {% post_link Java-final域的内存语义 %}
1. {% post_link Java-happens-before %}
1. {% post_link Java-单例双重检测正确性分析 %}
1. {% post_link Java-内存模型综述 %}

## 2.5 锁机制

{% post_link Java-锁机制简介 %}
{% post_link Java-synchronized的实现原理与应用 %}

# 3 JUC/并发相关

## 3.1 源码相关

1. {% post_link Java-concurrent-AQS-源码剖析 %}
1. {% post_link Java-concurrent-AQS-ConditionObject-源码剖析 %}
1. {% post_link Java-concurrent-ReentrantLock-源码剖析 %}
1. {% post_link Java-concurrent-ReentrantReadWriteLock-源码剖析 %}
1. {% post_link Java-concurrent-ArrayBlockingQueue-源码剖析 %}
1. {% post_link Java-concurrent-ThreadPoolExecutor-源码剖析 %}
1. {% post_link Java-concurrent-FutureTask-源码剖析 %}
1. {% post_link Java-concurrent-ConcurrentHashMap-源码剖析 %}
1. {% post_link Java-concurrent-CountDownLatch-源码剖析 %}
1. {% post_link Java-concurrent-CyclicBarrier-源码剖析 %}
1. {% post_link Java-concurrent-Exchanger-源码剖析 %}
1. {% post_link Java-concurrent-Semaphore-源码剖析 %}
1. {% post_link Java-concurrent-Fork-Join-源码剖析 %}
1. {% post_link Java-ThreadLocal-源码剖析 %}

## 3.2 ThreadLocal

原理是什么

ThreadLocal的实现需要Thread的配合，Thread内部为ThreadLocal增加了一个字段`threadLocals`，该字段是一个Map<ThreadLocal,T>，也就是说，不同的ThreadLocal对于同一个线程的值将会存放在这个Thread#threadLocals字段中

Map以及Map.Entry都是延迟初始化的

## 3.3 锁

{% post_link Java-锁机制简介 %}

### 3.3.1 synchronized

synchronized是内建的锁机制，依赖于Object Monitor

在JDK 1.6之后对内建锁机制进行了优化，引入的概念有自旋锁，轻量级锁以及偏向锁

{% post_link Java-synchronized的实现原理与应用 %}

### 3.3.2 Lock

Lock是ReentrantLock，其实现依赖于AQS，是一种无锁数据结构

公平锁与非公平锁是ReentrantLock的概念

* 公平锁意味着当一个线程尝试获取锁时，首先检查是否有其他线程正在等待这把锁。如果有其他线程，那么当前线程直接进入等待队列。否则才尝试获取锁
* 非公平锁意味着当一个线程尝试获取锁时，它首先尝试获取一下锁，失败了才会进入队列，这对于已经在队列中等待的线程而言是不公平的，在队列中等待的线程可能会被饿死

## 3.4 ConcurrentHashMap

1. 并发扩容
1. Node/TreeNode/TreeBin/ForwardingNode
1. 链表、红黑树
1. table大小为2的幂次，这样做可以实现一个扩张单调性，类似于一致性hash

{% post_link Java-concurrent-ConcurrentHashMap-源码剖析 %}

## 3.5 原子类实现原理

循环+CAS，即自旋

## 3.6 CAS

{% post_link Java-原子操作的实现原理 %}

## 3.7 如果让你实现一个并发安全的链表，你会怎么做

最简单的就是给每个链表访问的方法加上synchronized关键字

## 3.8 ConcurrentLinkedQueue与LinkedBlockingQueue

简而言之

1. ConcurrentLinkedQueue是Queue接口的一个安全实现
1. LinkedBlockingQueue是BlockingQueue的一种实现，被用于生产消费者队列

http://www.cnblogs.com/linjiqin/archive/2013/05/30/3108188.html

## 3.9 CountDownLatch和CyclicBarrier的用法，以及相互之间的差别?

CountDownLatch

> 假设构造方法传入的数值是n，那么某个线程调用了CountDownLatch#await，那么当且仅当有n个线程调用过
CountDownLatch#countDown方法后，调用了CountDownLatch#await才会从阻塞中被唤醒

> 注意调用CountDownLatch#countDown的线程并不会被阻塞

CyclicBarrier

> 假设构造方法传入的是n，那么当且仅当n个线程调用了CyclicBarrier#await后，这n个线程才会从阻塞中被唤醒

## 3.10 Unsafe

Unsafe是JDK实现所依赖的一个非公开的类，用于提供一些内存操作以及CAS操作等等。不具有跨平台性质，不同平台的实现可能有差异。

{% post_link Java-sun-Unsafe-源码剖析 %}

## 3.11 LockSupport

LockSupport.park
LockSupport.unpark

可以先unpark再park，unpark可以理解为获取一个许可。但是多次调用unpark只有一个许可

## 3.12 Condition

两个重要方法，提供类似于wait/notify的机制

1. await
1. signal/signalAll

与Object提供的wait/notify的机制不同，await/signal可以提供多个不同的等待队列

{% post_link Java-concurrent-AQS-ConditionObject-源码剖析 %}

## 3.13 Fork/Join

从宏观上来说就是一个类似于归并的过程，将问题拆分成子问题，最终合并结果

{% post_link Java-concurrent-Fork-Join-源码剖析 %}

### 3.13.1 parallelStream

parallelStream其实就是一个并行执行的流。它通过默认的ForkJoinPool，可能提高你的多线程任务的速度。

JDK 1.8之后，ForkJoinPool内部新添了一个全局的线程池，用于执行那些没有显式创建ForkJoinPool的并行任务。例如parallelStream

http://blog.csdn.net/u011001723/article/details/52794455

## 3.14 分段锁的原理

分段锁就是细化锁操作，类比于表锁和行锁。JDK 1.7中的ConcurrentHashMap的实现就是使用了分段锁，将整个hashtable分成多个Segment，访问某个元素必须获取该元素对应的Segment的锁，如果两个元素位于两个Segment，那么这两个元素的并发操作是不需要同步的

# 4 Spring

## 4.1 Spring AOP与IOC的实现原理

AOP=增强收集以及适配+拦截器机制+动态代理

## 4.2 Spring的BeanFactory和FactoryBean的区别

BeanFactory就是IoC容器本身

FactorBean是一种工厂bean，调用指定的方法来生产对象

## 4.3 为什么CGlib方式可以对接口实现代理？

## 4.4 RMI与代理模式

## 4.5 Spring的事务隔离级别，实现原理

## 4.6 对Spring的理解，非单例注入的原理？它的生命周期？循环注入的原理，aop的实现原理，说说aop中的几个术语，它们是怎么相互工作的？

{% post_link Spring-AOP-源码剖析 %}

## 4.7 Mybatis的底层实现原理

http://www.cnblogs.com/atwanli/articles/4746349.html

## 4.8 MVC框架原理，他们都是怎么做url路由的

## 4.9 spring boot特性，优势，适用场景等

Spring Boot 解决的问题，边界，适用场景
解决的问题：Spring框架创建一个可运行的应用比较麻烦，再加上很多Spring子项目和组件没有完善实践指导，让实际项目上选择使用哪些组件很困难。Spring Boot 的作用在于创建和启动新的基于 Spring 框架的项目。它的目的是帮助开发人员很容易的创建出独立运行和产品级别的基于 Spring 框架的应用。Spring Boot 会选择最适合的 Spring 子项目和第三方开源库进行整合。大部分 Spring Boot 应用只需要非常少的配置就可以快速运行起来。Spring Boot 包含的特性如下：

1. 创建可以独立运行的 Spring 应用。
1. 直接嵌入 Tomcat 或 Jetty 服务器，不需要部署 WAR 文件。
1. 提供推荐的基础 POM 文件来简化 Apache Maven 配置。
1. 尽可能的根据项目依赖来自动配置 Spring 框架。
1. 提供可以直接在生产环境中使用的功能，如性能指标、应用信息和应用健康检查。
1. 没有代码生成，也没有 XML 配置文件。
1. 通过 Spring Boot，创建新的 Spring 应用变得非常容易，而且创建出的 Spring 应用符合通用的最佳实践。只需要简单的几个步骤就可以创建出一个 Web 应用。

## 4.10 quartz和timer对比

Java.util.Timer

> 在Java中有一个任务处理类java.util.Timer，非常方便于处理由时间触发的事件任务，只需建立一个继承java.util.TimerTask的子类，重载父类的run()方法实现具体的任务，然后调用Timer的public void schedule(TimerTask task, long delay, long period)方法实现任务的调度。

> 但是这种方法只能实现简单的任务调度，不能满足任务调度时间比较复杂的需求。比如希望系统在每周的工作日的8：00时向系统用户给出一个提示，这种方法实现起来就困难了，还有更为复杂的任务调度时间要求。

Quartz

> OpenSymphony 的Quartz提供了一个比较完美的任务调度解决方案。
> Quartz 是个开源的作业调度框架，为在 Java 应用程序中进行作业调度提供了简单却强大的机制。
> Quartz中有两个基本概念：作业和触发器。作业是能够调度的可执行任务，触发器提供了对作业的调度。

## 4.11 spring的controller是单例还是多例，怎么保证并发的安全

单例，无状态的单例本身就是线程安全的，有状态的单例那么就需要用ThreadLocal来保证线程安全了，即每个线程有自己的一份拷贝

# 5 其他框架

## 5.1 Mybatis

## 5.2 Netty

## 5.3 OkHttp

## 5.4 MINA

## 5.5 Cglib

# 6 操作系统

1. 操作系统内存管理
    > 1. {% post_link 操作系统内存管理简介 %}
    > 1. {% post_link 操作系统内存管理详解 %}

1. 虚拟内存和物理内存是怎样一个关系
    > 呵呵，一言难尽。{% post_link 操作系统内存管理详解 %}

1. 一个二进制的程序跑起来的它各个段在内存中的分布是什么样的
    > 代码段、数据段、堆、栈、共享内存、内核

1. 读取一个2G的文件需要多久？为什么？还有哪些因素会影响读取速度？
1. cache是什么东西
    > 读写速度，成本，局部性原理

1. 缓存替换策略有哪些
    > 待补充

1. 介绍一下线程和进程
    > {% post_link 进程与线程 %}

1. 如果一个进程里有多个线程，其中一个崩溃了会发生什么
    > (共享内存、信号、信号的处理)https://www.zhihu.com/question/22397613

1. 进程间通信
    > 1. {% post_link 进程通信-管道 %}
    > 1. {% post_link 进程通信-消息队列 %}
    > 1. {% post_link 进程通信-信号量 %}
    > 1. {% post_link 进程通信-信号 %}
    > 1. {% post_link 进程通信-共享内存 %}
    > 1. {% post_link 进程通信-套接字 %}

1. 如果有10个进程两两一对儿要通信，用一个消息队列能不能行
    > 待补充

1. 共享内存有啥缺陷
    > 待补充

1. 多进程和多线程有什么区别
    > (还是很常规的问题，现在我想着如果大家自己做过一个小操作系统，这种东西是不是直接聊出风采；我说得并不好，一深挖就露怯，纸上得来终觉浅。比如会问到进程和线程的适用场景(需要有经验)，进程切换比线程慢的原因(需要懂原理)，切换时需要保存哪些数据，问得很细，光说PCB都不够，比如我说切换打开的文件符和资源什么的比较慢，面试官一针见血地说这些东西本来就在内存中，切换的时候难道需要关闭吗？问到最后只好承认并不清楚了)

1. 进程有哪些运行状态
    > 待验证
    > 就绪、运行中、等待、停止？
    > 运行状态什么时候会切到就绪态(比如时间片用完)
    > 什么时候会切到等待(比如遇到IO)

# 7 Linux

1. 统计一个文件的行数
    > `wc -l`

1. Linux线程同步的方式都有哪些(对于与Java线程同步也是一样的)
    > 互斥锁、信号量、条件变量

1. Linux下怎么查看进程的CPU占用、IO占用、内存占用
    > `ps aux`
    > `top`
    > `netstat`

1. Linux Signal有什么作用
    > 进程间通信，{% post_link 进程通信-信号 %}

1. 如果有一个服务要求不能启动两次，用什么机制来做
    > 说写bash每次启动前检查(ps配合grep)
    > 纯C程序怎么写

1. 找出一篇文章中某个单词的出现次
    > 待补充

# 8 分布式相关

1. 说说分布式计算
    > 待补充

## 8.1 分布式存储

{% post_link 分布式存储 %}

## 8.2 zookeeper

1. {% post_link zookeeper-概论 %}
1. {% post_link zookeeper-基础 %}
1. {% post_link zookeeper-原理 %}
1. {% post_link zookeeper-应用场景 %}
1. {% post_link Paxos算法 %}

### 8.2.1 zookeeper适用场景

{% post_link zookeeper-应用场景 %}

### 8.2.2 zookeeper watch机制

http://blog.csdn.net/z69183787/article/details/53023578

### 8.2.3 Zookeeper的用途

zookeeper是注册中心，提供目录和节点服务，watch机制

http://blog.csdn.net/tycoon1988/article/details/38866395

### 8.2.4 zookeeper选举原理

ZAB协议，paxox算法{% post_link Paxos算法 %}

### 8.2.5 redis/zookeeper节点宕机如何处理

重新选举leader

## 8.3 Dubbo

### 8.3.1 Dubbo和zookeeper的联系与区别

dubbo和zookeeper的区别和关系
http://blog.csdn.net/daiqinge/article/details/51282874

### 8.3.2 Dubbo的底层实现原理和机制

https://zhidao.baidu.com/question/1951046178708452068.html

dubbo的负载均衡已经是服务层面的了，和nginx的负载均衡还在http请求层面完全不同。至于二者哪个优秀，当然没办法直接比较。
涉及到负载均衡就涉及到你的业务，根据业务来选择才是最适合的。
dubbo具备了server注册，发现、路由、负载均衡的功能，在所有实现了这些功能的服务治理组件中，个人觉得dubbo还是略微笨重了，因为它本身是按照j2EE范畴所制定的中规中矩的服务治理框架。
dubbo在服务发现这个地方做的更像一个dns(个人感觉)，一个消费者需要知道哪里有这么一个服务，dubbo告诉他，然后他自己去调用。
而nginx在具备了以上功能，还有两个最主要的功能是，1，维持尽可能多的连接。2，把每个连接的具体服务需求pass到真正的worker上。
但是这两个功能，dubbo做不到第一个。
所以，结合你自己的业务来选择用什么，nginx和dubbo在使用上说白了就是一个先后的关系而已(当然也是我个人感觉)。

http://dubbo.io/developer-guide/%E6%A1%86%E6%9E%B6%E8%AE%BE%E8%AE%A1.html

![fig1](/images/Java-面试问题总结/fig1.jpg)

### 8.3.3 Dubbo的服务请求失败怎么处理

dubbo启动时默认有重试机制和超时机制。
超时机制的规则是如果在一定的时间内，provider没有返回，则认为本次调用失败，
重试机制在出现调用失败时，会再次调用。如果在配置的调用次数内都失败，则认为此次请求异常，抛出异常。

http://www.cnblogs.com/binyue/p/5380322.html

## 8.4 消息中间件

1. {% post_link 消息中间件简介 %}
1. {% post_link 消息中间件的消息发送一致性 %}
1. {% post_link 消息的重复产生和应对 %}

## 8.5 分布式事务

1. {% post_link 分布式事务 %}
1. {% post_link 分布式事务-两阶段三阶段协议 %}

## 8.6 分布式锁

http://www.cnblogs.com/PurpleDream/p/5559352.html

## 8.7 接口的幂等性的概念

{% post_link 分布式系统接口幂等性 %}

## 8.8 数据库拆分

### 8.8.1 垂直拆分/水平拆分

垂直拆分，将一张表中的不同类别的数据分别放到不同的表中去

水平拆分，将一张表的不同数据项放到两台机器上

### 8.8.2 数据库分库分表策略

### 8.8.3 分库分表后的全表查询问题

http://blog.csdn.net/dinglang_2009/article/details/53195835

## 8.9 负载均衡算法

{% post_link 负载均衡算法 %}

## 8.10 分布式集群下的唯一序列号

1. 数据库自增id
1. uuid(MacAddress+timeStamp)

http://www.cnblogs.com/haoxinyue/p/5208136.html

## 8.11 消息队列(Message Queue)

1. 用过哪些MQ，怎么用的，和其他mq比较有什么优缺点，MQ的连接是线程安全的吗

### 8.11.1 MQ系统的数据如何保证不丢失

{% post_link 消息中间件的消息发送一致性 %}

## 8.12 描述一个服务从发布到被消费的详细过程

## 8.13 分布式系统怎么做服务治理

http://www.jianshu.com/p/104b27d1e943

# 9 算法

1. 贪心的计算思想是什么？
1. LRU的实现
    > hash+双向链表

1. 单源最短路径
    > {% post_link 单源最短路径 %}

1. BTree
    > {% post_link B-tree-详解 %}
    > {% post_link BPlus-tree-详解 %}

1. 大根堆
    > 待补充

1. 单链表排序
    > 归并，fast/slow指针

1. 除了平衡二叉树这种结构还知道别的支持lgn插入的结构吗？
    > redis里的skip list

1. 给一棵二叉树，找到这棵树中最大的二叉查找子树——即找到这棵树的一棵子树
    > 待补充

1. 无序数组的最长递增子序列(LCS)

## 9.1 并查集

## 9.2 海量url去重类问题(布隆过滤器)

{% post_link Bloom-Filter %}

## 9.3 海量url中找到出现次数最多的10个url

map-reduce

## 9.4 数组和链表数据结构描述，各自的时间复杂度

太简单

## 9.5 二叉树遍历

{% post_link 树的遍历 %}

## 9.6 快速排序

{% post_link Java-DualPivotQuickSort-源码剖析 %}

## 9.7 BTree相关的操作

## 9.8 在工作中遇到过哪些设计模式，是如何应用的

## 9.9 hash算法的有哪几种，优缺点，使用场景

链表法，开放寻址法

## 9.10 什么是一致性hash

{% post_link 一致性hash %}

## 9.11 paxos算法

{% post_link Paxos算法 %}

## 9.12 在装饰器模式和代理模式之间，你如何抉择，请结合自身实际情况聊聊

装饰器模式关注于在一个对象上动态的添加方法，然而代理模式关注于控制对对象的访问。换句话说，用代理模式，代理类(proxy class)可以对它的客户隐藏一个对象的具体信息。因此，当使用代理模式的时候，我们常常在一个代理类中创建一个对象的实例。并且，当我们使用装饰器模式的时候，我们通常的做法是将原始对象作为一个参数传给装饰者的构造器。

## 9.13 代码重构的步骤和原因，如果理解重构到模式？

## 9.14 二叉树的最大搜索子树

# 10 数据库

1. 数据库触发器是什么

## 10.1 MySQL InnoDB存储的文件结构

{% post_link 数据库引擎 %}

## 10.2 索引树是如何维护的？

B+树，不同的引擎有不同的方式

{% post_link 数据库引擎 %}

## 10.3 数据库自增主键可能的问题

## 10.4 MySQL的几种优化

http://blog.csdn.net/u013474436/article/details/49908683

## 10.5 mysql索引为什么使用B+树

范围查找会比较快捷

## 10.6 数据库锁表的相关处理

## 10.7 索引失效场景

http://blog.csdn.net/zmx729618/article/details/52701370

## 10.8 高并发下如何做到安全的修改同一行数据，乐观锁和悲观锁是什么，INNODB的行级锁有哪2种，解释其含义

悲观锁(Pessimistic Lock), 顾名思义，就是很悲观，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会block直到它拿到锁。传统的关系型数据库里边就用到了很多这种锁机制，比如行锁，表锁等，读锁，写锁等，都是在做操作之前先上锁。

乐观锁(Optimistic Lock), 顾名思义，就是很乐观，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号等机制。乐观锁适用于多读的应用类型，这样可以提高吞吐量，像数据库如果提供类似于write_condition机制的其实都是提供的乐观锁。

两种锁各有优缺点，不可认为一种好于另一种，像乐观锁适用于写比较少的情况下，即冲突真的很少发生的时候，这样可以省去了锁的开销，加大了系统的整个吞吐量。但如果经常产生冲突，上层应用会不断的进行retry，这样反倒是降低了性能，所以这种情况下用悲观锁就比较合适。

http://blog.csdn.net/hongchangfirst/article/details/26004335

共享锁、排他锁

1. 共享锁(S锁)：如果事务T对数据A加上共享锁后，则其他事务只能对A再加共享锁，不能加排他锁。获准共享锁的事务只能读数据，不能修改数据。
1. 排他锁(X锁)：如果事务T对数据A加上排他锁后，则其他事务不能再对A加任任何类型的封锁。获准排他锁的事务既能读数据，又能修改数据。
* .共享锁下其它用户可以并发读取，查询数据。但不能修改，增加，删除数据。资源共享

## 10.9 数据库会死锁吗，举一个死锁的例子，mysql怎么解决死锁

虽然进程在运行过程中，可能发生死锁，但死锁的发生也必须具备一定的条件，死锁的发生必须具备以下四个必要条件。

1. 互斥条件：指进程对所分配到的资源进行排它性使用，即在一段时间内某资源只由一个进程占用。如果此时还有其它进程请求资源，则请求者只能等待，直至占有资源的进程用毕释放。
1. 请求和保持条件：指进程已经保持至少一个资源，但又提出了新的资源请求，而该资源已被其它进程占有，此时请求进程阻塞，但又对自己已获得的其它资源保持不放。
1. 不剥夺条件：指进程已获得的资源，在未使用完之前，不能被剥夺，只能在使用完时由自己释放。
1. 环路等待条件：指在发生死锁时，必然存在一个进程——资源的环形链，即进程集合{P0，P1，P2，···，Pn}中的P0正在等待一个P1占用的资源；P1正在等待P2占用的资源，……，Pn正在等待已被P0占用的资源。

https://baike.baidu.com/item/%E6%95%B0%E6%8D%AE%E5%BA%93%E6%AD%BB%E9%94%81/10015665?fr=aladdin

# 11 Redis&缓存相关

## 11.1 Redis的并发竞争问题如何解决，了解Redis事务的CAS操作吗

## 11.2 缓存机器增删如何对系统影响最小，一致性哈希的实现

{% post_link 一致性hash %}

## 11.3 Redis持久化的几种方式，优缺点是什么，怎么实现的

http://www.baidu.com/s?wd=Redis%E6%8C%81%E4%B9%85%E5%8C%96%E7%9A%84%E6%96%B9%E6%B3%95&rsv_spt=1&rsv_iqid=0xf5434a7700002b49&issp=1&f=8&rsv_bp=1&rsv_idx=2&ie=utf-8&rqlang=cn&tn=baiduhome_pg&rsv_enter=0&oq=Redis%25E7%259A%2584%25E5%25B9%25B6%25E5%258F%2591%25E7%25AB%259E%25E4%25BA%2589%25E9%2597%25AE%25E9%25A2%2598%25E5%25A6%2582%25E4%25BD%2595%25E8%25A7%25A3%25E5%2586%25B3&inputT=3331&rsv_t=221fy%2FwM1ef08YAzcyN6orkBkRI%2FpPYtZqETuz%2F0jQISV%2FdE0umrOx8SIqO8sbCJVbVp&rsv_pq=ee991a9a000058fc&rsv_sug3=182&rsv_sug2=0&rsv_sug4=3331

## 11.4 Redis的缓存失效策略

## 11.5 缓存穿透的解决办法

## 11.6 redis集群，高可用，原理

## 11.7 mySQL里有2000w数据，redis中只存20w的数据，如何保证redis中的数据都是热点数据

## 11.8 用Redis和任意语言实现一段恶意登录保护的代码，限制1小时内每用户Id最多只能登录5次

## 11.9 redis的数据淘汰策略

# 12 网络相关

1. 介绍你知道的传输层协议
    > TCP、UDP

1. HTTP和HTTPS的区别
    > 待补充
    > (中间人攻击、加密)。
    > 那么它是怎么实现加密的？(非对称交换密钥，然后用密钥对称加密消息)

1. TIME_WAIT状态什么情况下会产生，以及它有什么用
    > 待验证
    > 它可以保证重发丢失的ACK，还可以防止之后重用这个端口的进程不至于被对端认成前任(假如ACK包丢掉的话)

1. HTTP请求详细过程
    > {% post_link HTTP请求详细过程 %}

1. 一个IP包大概是多大呢，有限制没有？
    > IP数据包的最大长度是64K字节(65535)，因为在IP包头中用2个字节描述报文长度，2个字节所能表达的最大数字就是65535。  

1. 什么情况下会考虑UDP、什么情况下会考虑TCP
    > TCP一般用于文件传输(FTP、HTTP对数据准确性要求高，速度可以相对慢)，发送或接收邮件(POP、IMAP、SMTP对数据准确性要求高，非紧急应用)，远程登录(TELNET、SSH对数据准确性有一定要求，有连接的概念)等等；
    > UDP一般用于即时通信(QQ聊天 对数据准确性和丢包要求比较低，但速度必须快)，在线视频(RTSP 速度一定要快，保证视频连续，但是偶尔花了一个图像帧，人们还是能接受的)，网络语音电话(VoIP 语音数据包一般比较小，需要高速发送，偶尔断音或串音也没有问题)等等。

1. 如果要进行可靠的传输，又想要用UDP，你觉得可行吗
    > 简单来讲，要使用UDP来构建可靠的面向连接的数据传输，就要实现类似于TCP协议的超时重传，有序接受，应答确认，滑动窗口流量控制等机制，等于说要在传输层的上一层(或者直接在应用层)实现TCP协议的可靠数据传输机制，比如使用UDP数据包+序列号，UDP数据包+时间戳等方法，在服务器端进行应答确认机制，这样就会保证不可靠的UDP协议进行可靠的数据传输

1. HTTP请求在服务器应答、数据传完之后会怎么样一个操作呢？
    > 服务端主动关闭连接，至于为什么，参考：https://www.zhihu.com/question/24338653

1. select和epoll的区别
    > {% post_link Java-NIO %}
    > select描述符个数限制是多少？(1024)，能不能改怎么改等等(不能，想改得编译内核)

1. 介绍一下TCP三次握手/四次挥手、流量控制、拥塞控制
    > 三次握手、四次挥手详见{% post_link TCP-IP %}

1. TCP粘包问题
    > http://www.cnblogs.com/qiaoconglovelife/p/5733247.html

1. TCP是面向流的面向连接的对吧，解释一下什么叫连接
    > 待补充

1. accept是在三次握手的哪个阶段？
    > 三次握手后，http://blog.csdn.net/wukui1008/article/details/7691499

1. 假如三次握手后我没有调accept，那么你能感知到我是否调用了accept吗？
    > (不能，但是我能朝你发消息)能发成功吗？(可以的吧，我发过去的消息就是被操作系统缓存在那个buffer里)那你可以一直发吗？(那不能一直发，如果buffer满了之后，那你那边控制的那个叫receive wnd就减成0了)receive wnd是啥？(接收方维护的一个变量，用来做流量控制的)

1. HTTP的状态码知道哪些
    > 1XX、2XX、3XX、4XX、5XX

1. 两台电脑用一根网线直连，发现带宽总是跑不满，会是什么原因？
    > 待补充

## 12.1 http1.0和http1.1有什么区别

http://www.cnblogs.com/shijingxiang/articles/4434643.html

## 12.2 http和https的区别

SSL(以RSA为加密算法)

## 12.3 TCP/IP协议

{% post_link TCP-IP %}

## 12.4 TCP三次握手和四次挥手的流程，为什么断开连接要4次,如果握手只有两次，会出现什么

## 12.5 `TIME_WAIT`和`CLOSE_WAIT`的区别

`CLOSE_WAIT`：被动关闭方接收到了对方FIN信号，但由于TCP连接是双向的，但是仍有数据要传给对方

`TIME_WAIT`：为了连接成功断开，需要延迟一小段时间

{% post_link TCP-IP %}

## 12.6 TIME_WAIT状态的原理

http://blog.csdn.net/najiutan/article/details/15814095

## 12.7 TCP流量控制拥塞控制

## 12.8 介绍你知道的传输层协议

TCP和UDP

## 12.9 说说你知道的几种HTTP响应码

{% post_link HTTP协议 %}

## 12.10 当你用浏览器打开一个链接的时候，计算机做了哪些工作步骤

{% post_link HTTP协议 %}

## 12.11 TCP/IP如何保证可靠性，数据包有哪些数据组成

## 12.12 长连接与短连接

http://www.cnblogs.com/cswuyg/p/3653263.html

## 12.13 Http请求get和post的区别以及数据包格式

{% post_link HTTP协议 %}

## 12.14 简述tcp建立连接3次握手，和断开连接4次握手的过程；关闭连接时，出现TIMEWAIT过多是由什么原因引起，是出现在主动断开方还是被动断开方

{% post_link TCP-IP %}

# 13 操作系统

## 13.1 操作系统内存管理

http://blog.csdn.net/hguisu/article/details/5713164

# 14 其他

## 14.1 maven解决依赖冲突,快照版和发行版的区别

## 14.2 Linux下IO模型有几种，各自的含义是什么

## 14.3 实际场景问题，海量登录日志如何排序和处理SQL操作，主要是索引和聚合函数的应用

## 14.4 实际场景问题解决，典型的TOP K问题

利用最小最大堆

TOP Max K用最小堆

TOP Min K用最大堆

## 14.5 线上bug处理流程

## 14.6 如何从线上日志发现问题

## 14.7 linux利用哪些命令，查找哪里出了问题(例如io密集任务，cpu过度)

## 14.8 场景问题，有一个第三方接口，有很多个线程去调用获取数据，现在规定每秒钟最多有10个线程同时调用它，如何做到

## 14.9 用三个线程按顺序循环打印abc三个字母，比如abcabcabc

## 14.10 常见的缓存策略有哪些，你们项目中用到了什么缓存系统，如何设计的

## 14.11 设计一个秒杀系统，30分钟没付款就自动关闭交易(并发会很高)

## 14.12 请列出你所了解的性能测试工具

## 14.13 后台系统怎么防止请求重复提交？

## 14.14 mock测试框架

## 14.15 tomcat结构，类加载器流程

# 15 一些面经

* [【杂文】从实习到校招到工作](http://www.cnblogs.com/leesf456/p/6019583.html)

