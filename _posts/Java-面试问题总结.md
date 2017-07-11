---
title: Java 面试问题总结
date: 2017-07-05 08:51:57
tags:
- 原创
categories:
- Java
---

<!--more-->

# 1 Java基础

## 1.1 Arrays.sort实现原理和Collection.sort实现原理 

Arrays.sort在JDK 1.7之用使用的是timsort，timsort是归并排序的一个变种，相比于普通的归并排序，存在如下3点优化

1. 提高合并效率
1. 减少合并次数
1. 在元素数量较少时直接采用插入排序

[TimSort详解](http://blog.jobbole.com/99681/)

Collection.sort在内部会转调用Arrays.sort

1. 调用List#toArray()方法，生成一个数组
1. 调用Arrays.sort方法进行排序
1. 将排序好的序列利用迭代器回填到List当中(为什么用迭代器，因为这样效率是最高的，如果List的实现是LinkedList，那么采用下标将会非常慢)

## 1.2 foreach和while的区别(编译之后) 

foreach只能引用于实现了Iterator接口的类，因此在内部实现时会转化为迭代器的遍历，本质上是一种语法糖

while和for循环在编译之后基本相同，利用字节码`goto`来进行循环跳转

## 1.3 线程池的种类，区别和使用场景 

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

## 1.4 分析线程池的实现原理和线程的调度过程 
## 1.5 线程池如何调优 
## 1.6 线程池的最大线程数目根据什么确定 
## 1.7 动态代理的几种方式 
## 1.8 HashMap的并发问题 
## 1.9 了解LinkedHashMap的应用吗
## 1.10 反射的原理，反射创建类实例的三种方式是什么？ 
## 1.11 cloneable接口实现原理，浅拷贝or深拷贝 

实现cloneable接口必须调用父类Object.clone()方法来进行内存的拷贝

如果不加其他的逻辑，实现的就是浅拷贝。即副本中的内存与原象中的内存完全一致，意味着如果存在引用类型，那么副本与原象将引用的是同一个对象

如果要实现深拷贝，那么就需要加上额外的实现逻辑

## 1.12 Java NIO使用 

SocketChannel

* 支持非阻塞模式

ServerSocketChannel

* 支持非阻塞模式

FileChannel

* 只有阻塞模式

Selector

这里差一篇博客介绍NIO

## 1.13 Hashtable和HashMap的区别及实现原理，HashMap会问到数组索引，hash碰撞怎么解决 

hashtable给所有的table访问方法加上了synchronized关键字

用链表解决，当链表元素过多时，转换为红黑树

## 1.14 Arraylist和Linkedlist区别及实现原理 

ArrayList内部采用数组来实现

LinkedList内部采用链表来实现

## 1.15 反射中，Class.forName和ClassLoader区别 

Class.forName执行过程

1. 加载
1. 验证-准备-解析：该过程称为链接
1. 初始化

ClassLoader#loadClass执行过程

1. 加载

具体详见 {% post_link Java-类加载机制 %}

## 1.16 String，StringBuffer，StringBuilder的区别？ 

String 中的char[]数组是final的

StringBuffer是线程安全的，所有char[]数组的access方法被synchronized关键字修饰

StringBuilder非线程安全

## 1.17 有没有可能2个不相等的对象有相同的hashcode 

完全可能

## 1.18 简述NIO的最佳实践，比如netty，mina 

## 1.19 TreeMap的实现原理

红黑树

# 2 JVM相关

## 2.1 类的实例化顺序，比如父类静态数据，构造函数，字段，子类静态数据，构造函数，字段，他们的执行顺序 
## 2.2 JVM内存分代 
## 2.3 Java 8的内存分代改进 
## 2.4 JVM垃圾回收机制，何时触发MinorGC等操作 
## 2.5 jvm中一次完整的GC流程（从ygc到fgc）是怎样的，重点讲讲对象如何晋升到老年代，几种主要的jvm参数等 
## 2.6 你知道哪几种垃圾收集器，各自的优缺点，重点讲下cms，g1 
## 2.7 新生代和老生代的内存回收策略 
## 2.8 Eden和Survivor的比例分配等 
## 2.9 深入分析了Classloader，双亲委派机制 
## 2.10 JVM的编译优化 
## 2.11 对Java内存模型的理解，以及其在并发中的应用 
## 2.12 指令重排序，内存栅栏等 
## 2.13 OOM错误，stackoverflow错误，permgen space错误 
## 2.14 JVM常用参数 
## 2.15 tomcat结构，类加载器流程 
## 2.16 volatile的语义，它修饰的变量一定线程安全吗

单个volatile读写语句当然是线程安全的

但是符合的volatile读写语句或者类似于volaitle++这样的读改写操作就不是线程安全的

{% post_link Java-volatile的内存语义 %}

## 2.17 g1和cms区别,吞吐量优先和响应优先的垃圾收集器选择 

G1(Gargabe-First)收集器是当今收集器计数发展的最前沿成果之一。G1是一款面向服务端应用的垃圾收集器，HotSpot开发团队赋予它的使命是(在比较长期的)未来可以替换掉JDK 1.5中发布的CMS收集器，与其他GC收集器相比，G1具备如下特点：

* __并行与并发__：G1能充分利用多CPU，多核环境下的硬件优势，使用多个CPU(或CPU核心)来缩短Stop-The-World停顿的时间(并行)，部分其他收集器原本需要停顿Java线程执行的GC动作，G1收集器仍然可以通过并发的方式让Java程序继续执行
* __分代收集__：与其他收集器一样，分代的概念在G1中仍然保留，虽然G1可以不需要其他收集器配合就能独立管理整个GC堆，但它能够采用不同的方式去处理新创建的对象和已经存活了一段时间的、熬过多次GC的旧对象以获取更好的收集效果
* __空间整合__：与CMS的"标记-清理"算法不同，G1从整体来看是基于"标记-清理"算法实现的收集器，从局部(两个Region之间)上来看是基于"复制"算法实现的，这两种算法都意味着G1运作期间不会产生内存空间碎片，收集后能提供规整的可用内存
* __可预测的停顿__：这是G1相对于CMS的另一大优势，降低停顿时间是G1和CMS共同的关注点，但G1除了追求低停顿外，还能建立可预测的停顿时间模型，能让使用者明确指定在一个长度为M毫秒的时间片段内，消耗在垃圾收集上的时间不得超过N毫秒

## 2.18 环境变量classpath

说一说你对环境变量classpath的理解？如果一个类不在classpath下，为什么会抛出ClassNotFoundException异常，如果在不改变这个类路径的前期下，怎样才能正确加载这个类？ 

环境变量classpath是JVM的App ClassLoader类加载器的加载*.class文件的路径

加载类的过程可以交给自定义的类加载器来执行，可以自定义类加载器，可以从任何地方获取一段.class文件的二进制字节流，这便是类的加载过程

## 2.19 说一下强引用、软引用、弱引用、虚引用以及他们之间和gc的关系

# 3 JUC/并发相关

## 3.1 ThreadLocal用过么，原理是什么，用的时候要注意什么 

ThreadLocal的实现需要Thread的配合，Thread内部为ThreadLocal增加了一个字段`threadLocals`，该字段是一个Map<ThreadLocal,T>，也就是说，不同的ThreadLocal对于同一个线程的值将会存放在这个Thread#threadLocals字段中

## 3.2 synchronized和Lock的区别

synchronized是内建的锁机制，依赖于Object Monitor

Lock是ReentrantLock，其实现依赖于AQS，是一种无锁数据结构

## 3.3 synchronized 的原理，什么是自旋锁，偏向锁，轻量级锁，什么叫可重入锁，什么叫公平锁和非公平锁 

{% post_link Java-synchronized的实现原理与应用 %}

## 3.4 concurrenthashmap具体实现及其原理，jdk8下的改版 

{% post_link Java-concurrent-ConcurrentHashMap-源码剖析 %}

## 3.5 用过哪些原子类，他们的参数以及原理是什么

AtomicInteger，就是循环CAS来实现的

## 3.6 cas是什么，他会产生什么问题（ABA问题的解决，如加入修改次数、版本号） 

{% post_link Java-原子操作的实现原理 %}

## 3.7 如果让你实现一个并发安全的链表，你会怎么做

最简单的就是给每个链表访问的方法加上synchronized关键字

## 3.8 简述ConcurrentLinkedQueue和LinkedBlockingQueue的用处和不同之处 
## 3.9 简述AQS的实现原理 

{% post_link Java-concurrent-AQS-源码剖析 %}

## 3.10 countdowlatch和cyclicbarrier的用法，以及相互之间的差别? 
## 3.11 concurrent包中使用过哪些类？分别说说使用在什么场景？为什么要使用？
## 3.12 LockSupport工具 
## 3.13 Condition接口及其实现原理 

{% post_link Java-concurrent-AQS-ConditionObject-源码剖析 %}

## 3.14 Fork/Join框架的理解 
## 3.15 jdk8的parallelStream的理解 
## 3.16 分段锁的原理,锁力度减小的思考

# 4 Spring

## 4.1 Spring AOP与IOC的实现原理 
## 4.2 Spring的beanFactory和factoryBean的区别 
## 4.3 为什么CGlib方式可以对接口实现代理？ 
## 4.4 RMI与代理模式 
## 4.5 Spring的事务隔离级别，实现原理 
## 4.6 对Spring的理解，非单例注入的原理？它的生命周期？循环注入的原理，aop的实现原理，说说aop中的几个术语，它们是怎么相互工作的？
## 4.7 Mybatis的底层实现原理 
## 4.8 MVC框架原理，他们都是怎么做url路由的 
## 4.9 spring boot特性，优势，适用场景等 
## 4.10 quartz和timer对比 
## 4.11 spring的controller是单例还是多例，怎么保证并发的安全

# 5 分布式相关

## 5.1 Dubbo的底层实现原理和机制 
## 5.2 描述一个服务从发布到被消费的详细过程 
## 5.3 分布式系统怎么做服务治理 
## 5.4 接口的幂等性的概念 
## 5.5 消息中间件如何解决消息丢失问题 
## 5.6 Dubbo的服务请求失败怎么处理 
## 5.7 重连机制会不会造成错误 
## 5.8 对分布式事务的理解 
## 5.9 如何实现负载均衡，有哪些算法可以实现？
## 5.10 Zookeeper的用途，选举的原理是什么？ 
## 5.11 数据的垂直拆分水平拆分。
## 5.12 zookeeper原理和适用场景 
## 5.13 zookeeper watch机制 
## 5.14 redis/zk节点宕机如何处理 
## 5.15 分布式集群下如何做到唯一序列号 
## 5.16 如何做一个分布式锁 
## 5.17 用过哪些MQ，怎么用的，和其他mq比较有什么优缺点，MQ的连接是线程安全的吗 
## 5.18 MQ系统的数据如何保证不丢失 
## 5.19 列举出你能想到的数据库分库分表策略；分库分表后，如何解决全表查询的问题。

# 6 算法&数据结构&设计模式

## 6.1 海量url去重类问题（布隆过滤器）
## 6.2 数组和链表数据结构描述，各自的时间复杂度 
## 6.3 二叉树遍历 
## 6.4 快速排序 
## 6.5 BTree相关的操作 
## 6.6 在工作中遇到过哪些设计模式，是如何应用的 
## 6.7 hash算法的有哪几种，优缺点，使用场景 
## 6.8 什么是一致性hash 
## 6.9 paxos算法 
## 6.10 在装饰器模式和代理模式之间，你如何抉择，请结合自身实际情况聊聊 
## 6.11 代码重构的步骤和原因，如果理解重构到模式？

# 7 数据库

## 7.1 MySQL InnoDB存储的文件结构 
## 7.2 索引树是如何维护的？ 
## 7.3 数据库自增主键可能的问题
## 7.4 MySQL的几种优化 
## 7.5 mysql索引为什么使用B+树 
## 7.6 数据库锁表的相关处理 
## 7.7 索引失效场景 
## 7.8 高并发下如何做到安全的修改同一行数据，乐观锁和悲观锁是什么，INNODB的行级锁有哪2种，解释其含义 
## 7.9 数据库会死锁吗，举一个死锁的例子，mysql怎么解决死锁

# 8 Redis&缓存相关

## 8.1 Redis的并发竞争问题如何解决了解Redis事务的CAS操作吗 
## 8.2 缓存机器增删如何对系统影响最小，一致性哈希的实现 
## 8.3 Redis持久化的几种方式，优缺点是什么，怎么实现的 
## 8.4 Redis的缓存失效策略 
## 8.5 缓存穿透的解决办法 
## 8.6 redis集群，高可用，原理 
## 8.7 mySQL里有2000w数据，redis中只存20w的数据，如何保证redis中的数据都是热点数据 
## 8.8 用Redis和任意语言实现一段恶意登录保护的代码，限制1小时内每用户Id最多只能登录5次 
## 8.9 redis的数据淘汰策略

# 9 网络相关

## 9.1 http1.0和http1.1有什么区别 
## 9.2 TCP/IP协议 
## 9.3 TCP三次握手和四次挥手的流程，为什么断开连接要4次,如果握手只有两次，会出现什么 
## 9.4 TIME_WAIT和CLOSE_WAIT的区别 
## 9.5 说说你知道的几种HTTP响应码 
## 9.6 当你用浏览器打开一个链接的时候，计算机做了哪些工作步骤 
## 9.7 TCP/IP如何保证可靠性，数据包有哪些数据组成 
## 9.8 长连接与短连接 
## 9.9 Http请求get和post的区别以及数据包格式 
## 9.10 简述tcp建立连接3次握手，和断开连接4次握手的过程；关闭连接时，出现TIMEWAIT过多是由什么原因引起，是出现在主动断开方还是被动断开方。

# 10 其他

## 10.1 maven解决依赖冲突,快照版和发行版的区别 
## 10.2 Linux下IO模型有几种，各自的含义是什么
## 10.3 实际场景问题，海量登录日志如何排序和处理SQL操作，主要是索引和聚合函数的应用 
## 10.4 实际场景问题解决，典型的TOP K问题 
## 10.5 线上bug处理流程 
## 10.6 如何从线上日志发现问题 
## 10.7 linux利用哪些命令，查找哪里出了问题（例如io密集任务，cpu过度） 
## 10.8 场景问题，有一个第三方接口，有很多个线程去调用获取数据，现在规定每秒钟最多有10个线程同时调用它，如何做到。 
## 10.9 用三个线程按顺序循环打印abc三个字母，比如abcabcabc。 
## 10.10 常见的缓存策略有哪些，你们项目中用到了什么缓存系统，如何设计的 
## 10.11 设计一个秒杀系统，30分钟没付款就自动关闭交易（并发会很高） 
## 10.12 请列出你所了解的性能测试工具 
## 10.13 后台系统怎么防止请求重复提交？
