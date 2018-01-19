---
title: JVM-常用参数
date: 2017-07-10 18:55:43
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- JVM参数
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

本篇博客将介绍几类常用的JVM参数，JVM参数也就是写在`java`命令中的参数

`-XX参数`被称为__不稳定参数__，之所以这么叫是因为此类参数的设置很容易引起JVM性能上的差异，使JVM存在极大的不稳定性。当然这是在非合理设置的前提下，如果此类参数设置合理将大大提高JVM的性能及稳定性

可以说"不稳定参数"是一柄双刃剑，用的好攻无不克，用的差将带来麻烦。如何合理利用不稳定参数一直是一个不断实践不断改善的过程，无法用统一的标准去衡量。一切都需要在系统的不断运行，问题不断出现，参数不断修改，重新不断运行的循环过程中完善。也就是说没有最好的配置标准，只有适合当前系统的标准。这是一个循序渐进的过程。但有一些前人总结过得经验教训可供我们来参考，并去寻找适合自己的那些配置

# 2 语法规则

以`-X`开头的参数表示非标准(non-standard)，即不保证能够应用于所有JVM的实现，并且可能在之后后发布的JDK版本中更改

以`-XX`开头的参数表示非稳定(not stable)，并且可能在之后发布的JDK版本中更改

__布尔类型参数值__

* -XX:+&lt;option&gt;：`+`表示启用该选项
* -XX:-&lt;option&gt;：`-`表示关闭该选项

__数值类型参数值__

* -XX:&lt;option&gt;=&lt;number&gt;：给选项设置一个数值类型值，可跟随单位，例如：'m'或'M'表示兆字节;'k'或'K'千字节;'g'或'G'千兆字节。32K与32768是相同大小的
* 还有另一种数值类型，没有等于号，直接是参数名称后接数值。例如`-Xms300m`等等

__字符串类型参数值__

* -XX:&lt;option&gt;=&lt;string&gt;：给选项设置一个字符串类型值，通常用于指定一个文件、路径或一系列命令列表。例如：-XX:HeapDumpPath=./dump.core

# 3 堆相关的内存大小设置

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 50px;
}
table th:nth-of-type(3) {
    width: 200px;
}
</style>

| 参数名称 | 类型 | 说明 |
|:--|:--|:--|
| `-Xms<size>` | 数值类型 | 设置堆的初始化大小，这个数值必须是1024的倍数且大于1MB。不设置此参数时，堆的大小为新生代和老年代的总和。新生代的初始大小可由`-Xmn`或者`-XX:NewSize`进行设置。 |
| `-Xmx<size>` | 数值类型 | 设置内存池的最大值，数值必须是1024的倍数且大于2MB。__默认值依赖于系统的配置__。对于部署服务器而言，`-Xms`和`-Xmx`通常设置成相同的数值。`-Xmx`参与与`-XX:MaxHeapSize`参数等价 |
| `-Xmn<size>` | 数值类型 | 设置新生代的__初始值__以及__最大值__(意味着使用该参数后新生代的大小就不再改变了)。新生代是用于存放新对象的区域，GC操作在此区域频繁发生。如果这个区域很小，那么将会增加Minor GC触发频率。如果这个区域很大，那么当触发Minor GC时，将会变得非常耗时。Oracle建议新生代的大小[0.25,0.5]*heapSize。为了避免`-Xmn`同时设定新生代的初始值以及最大值，我们可以用`-XX:NewSize`来设置初始值、`-XX:MaxNewSize`来设置最大值 |
| `-Xss<size>` | 数值类型 | 设置线程堆栈的大小。__默认值依赖于虚拟内存__。该参数与`-XX:ThreadStackSize`参数等价|
| `-XX:InitialHeapSize=<size>` | 数值类型 | 设置内存池的初始大小，数值要么为0，要么是1024的倍数且大于1MB。__默认值依赖于系统的配置__。如果设置为0，那么初始内存池的大小就是新生代和老年代大小的总和 |
| `-XX:MaxHeapSize=<size>` | 数值类型 | 设置内存池的最大值，数值必须为1024的倍数且大于2MB。__默认值依赖于系统的配置__。对于服务器的部署，`-XX:InitialHeapSize`参数与`-XX:MaxHeapSize`参数通常设置成相同的值。该参数与`-Xmx`参数等价 |
| `-XX:NewSize=<size>` | 数值类型 | 设定新生代的__初始值__。新生代是用于存放新对象的区域，GC操作在此区域频繁发生。如果这个区域很小，那么将会增加Minor GC触发频率。如果这个区域很大，那么当触发Minor GC时，将会变得非常耗时。Oracle建议新生代的大小[0.25,0.5]*heapSize。 |
| `-XX:MaxNewSize=<size>` | 数值类型 | 设置新生代的__最大值__。具有默认值(set ergonomically) |
| `-XX:ThreadStackSize=<size>` | 数值类型 | 设置线程的堆栈的大小。__默认值依赖于虚拟内存__。该参数与`-Xss`参数等价 |
| `-XX:PermSize=<size>` | 数值类型 | 设置永久代触发垃圾回收的临界值。超过这个临界值，将触发垃圾回收。这个参数在JDK 8被`-XX:MetaspaceSize`参数取代 |
| `-XX:MaxPermSize=<size>` | 数值类型 | 设置永久代大小的最大值。这个参数在JDK 8被`-XX:MaxMetaspaceSize`参数取代 |
| `-XX:MetaspaceSize=<size>` | 数值类型 | 设置元数据区触发垃圾回收的临界值。超过这个临界值将触发垃圾回收。这个阈值会随着metadata的使用情况而发生改变。__默认值依赖于平台__ |
| `XX:MaxMetaspaceSize=<size>` | 数值类型 | 设置元数据区的最大值。一般来讲，这个元数据的大小是无限制的，因为一个app元数据区的大小依赖于这个app本身，其他依赖的app以及系统所用的内存总和|
| `-XX:NewRatio=<ratio>` | 数值类型 | 设置新生代与老年代大小的比值。__默认值是2__ |
| `-XX:SurvivorRatio=<ratio>` | 数值类型 | 设置Eden与Survivor的比值。__默认是8__。新生代分为一个Eden区域以及两个Survivor区域，采用复制算法，每次使用一个Eden与一个Survivor区域，因此在默认的设置情况下，内存使用率为(8+1)/(8+2)=90% |
| `-XX:MaxTenuringThreshold=<threshold>` | 数值类型 | 分代晋升的阈值。当一个对象在新生代中经过`<threshold>`次Minor GC后仍然存活，那么这个对象将会从新生代移送至老年代。对于老年代较多的应用，适当降低这个阈值可以提高效率。如果将此值设为一个较大值，则新生代对象会在Survivor区进行多次复制，这样可以增加对象在新生代的存活时间，增加在新生代被回收的概率 |

* `<size>`：此数值后面可接单位：`k/K  m/M  g/G`
* `<ratio>`：整数，可以是小数吗？
* `<threshold>`：整数

# 4 G1相关参数

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 50px;
}
table th:nth-of-type(3) {
    width: 200px;
}
</style>

| 参数名称 | 类型 | 说明 |
|:--|:--|:--|
| `-XX:+UseG1GC` | 布尔类型 | 使用G1(garbage first)垃圾收集器。G1是一种服务器式垃圾收集器，面向具有大量RAM的多处理器机器。G1可以高概率地满足GC暂停时间目标，同时保持良好的吞吐量。G1收集器主要用于需要6GB或更大内存的应用，并且具有有限的GC等待时间要求（稳定且可预测的暂停时间低于0.5秒）|
| `-XX:MaxGCPauseMillis=<time>` | 数值类型 | 设置GC暂停的最大时长。单位是milliseconds。这是一个非硬性指标，JVM会努力去逼近这个设定，但不一定保证实现。__默认没有上限__ |
| `-XX:InitiatingHeapOccupancyPercent=<percent>` | 数值类型 | 设置开始并发GC循环的堆占用百分比（0到100。垃圾收集器使用的触发并发GC循环，基于整个堆的占用，而不仅仅是一代（例如，G1垃圾收集器。默认情况下，初始值设置为45％。 值为0表示不间断GC循环。 |
| `-XX:NewRatio=<ratio>` | 数值类型 | 上文已经详细说明，此处不再赘述 |
| `-XX:SurvivorRatio=<ratio>` | 数值类型 | 上文已经详细说明，此处不再赘述 |
| `-XX:MaxTenuringThreshold=<threshold>` | 数值类型 | 上文已经详细说明，此处不再赘述 |
| `-XX:ParallelGCThreads=<threads>` | 数值类型 | 设置用于新生代和老年代中并行垃圾收集的线程数。__默认值取决于JVM可用的CPU数量__ |
| `-XX:ConcGCThreads=<threads>` | 数值类型 | 设置用于并发GC的线程数。__默认值取决于JVM可用的CPU数量__ |
| `-XX:G1ReservePercent=<percent>` | 数值类型 | 设置作为空闲空间的预留内存百分比(0-50)，以降低目标空间溢出的风险。__默认值是10__。 |
| `-XX:G1HeapRegionSize=<size>` | 数值类型 | 设置G1 Region的大小(G1收集器用Region来代替新生代老年代，同时仍保留新生代老年代的概念，只不过在G1收集器中，新生代老年代不再物理分离，而是位于不同的Region而已)。可以设置为1MB到32MB之间的数值。__默认值取决于堆的大小__ |

# 5 并行收集器相关参数

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 50px;
}
table th:nth-of-type(3) {
    width: 200px;
}
</style>

| 参数名称 | 类型 | 说明 |
|:--|:--|:--|
| `-XX:+UseParallelGC` | 布尔类型 | 使用并行清除垃圾收集器（也称为吞吐量收集器）来利用多个处理器来提高应用程序的性能。__该参数默认不设置，并根据机器的配置和JVM的类型自动选择收集器__。 当设置`-XX:+UseParallelGC`参数时，则`-XX：+ UseParallelOldGC`参数将自动设置，除非您明确禁用它 |
| `-XX:+UseParNewGC` | 布尔类型 | 在新生代中使用并发收集器。__该参数默认不设置__。当设置`-XX:+UseConcMarkSweepGC`参数时，则`-XX:+UseParNewGC`参数将自动设置。 JDK 8中不允许设置`-XX:+UseParNewGC`参数而不设置`-XX:+UseConcMarkSweepGC`参数 |
| `-XX:+UseParallelOldGC` | 布尔类型 | 在老年代(对应Full GC)中启用并发收集器。__该参数默认不设置__。当设置`-XX:+UseParallelGC`参数时，则`-XX:+UseParallelOldGC`参数将自动设置 |
| `-XX:MaxGCPauseMillis=<time>` | 数值类型 | 上文已经详细说明，此处不再赘述 |
| `-XX:GCTimeRatio=<ratil>` | 数值类型 | 设置吞吐量的大小(吞吐量 = 运行用户代码的时间/(运行用户代码的时间 + 垃圾收集时间))。该参数的值应当是一个大于0小于100的整数，若设置为19，则意味着允许的最大GC时间占总时间的`5%=1/(1+19)`。__默认为99，即`1%=1/(1+99)`__ |
| `-XX:ParallelGCThreads=<threads>` | 数值类型 | 上文已经详细说明，此处不再赘述 |
| `-XX:+UseAdaptiveSizePolicy` | 布尔类型 | 启动自适应的比例(Eden与Survivor的比值)配置。__该参数默认设置__。若要禁用，则必须显式设置`-XX:-UseAdaptiveSizePolicy`参数，并且设置`-XX：SurvivorRatio`参数 |
| `-XX:+ScavengeBeforeFullGC` | 布尔类型 | 在Full GC之前先进行一次Minor GC。__此参数默认设置__。Oracle建议不要禁用该参数，because scavenging the young generation before a full GC can reduce the number of objects reachable from the old generation space into the young generation space |

# 6 CMS相关参数

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 50px;
}
table th:nth-of-type(3) {
    width: 200px;
}
</style>

| 参数名称 | 类型 | 说明 |
|:--|:--|:--|
| `-XX:+UseConcMarkSweepGC` | 布尔类型 | 在老年代中启用CMS并行收集器。Oracle建议您在吞吐量`-XX：+ UseParallelGC`垃圾收集器无法满足应用程序延迟要求时，使用CMS垃圾收集器。 G1垃圾回收器`-XX：+ UseG1GC`是另一种选择。__此参数默认不设置，并根据机器的配置和JVM的类型自动选择收集器__。启用此选项时，将自动设置`-XX：+ UseParNewGC`参数，并且不应禁用该参数。JDK 8禁止这样设置：`-XX:+UseConcMarkSweepGC`和`-XX:-UseParNewGC`(即不能启用CMS的同时禁用ParNew) |
| `-XX:+AggressiveHeap` | 布尔类型 | 启动堆优化，根据计算机(RAM和CPU)的配置进行优化，能够提升那些长时间运作的应用的性能。__该参数默认不设置，即堆不会优化__ |
| `-XX:CMSFullGCsBeforeCompaction=<n>` | 数值类型 | 由于并发收集器不对内存空间进行压缩、整理。所以运行一段时间以后会产生"碎片"，碎片使得运行效率降低。此值设置运行多少次Full GC以后对内存空间进行压缩、整理。__该参数默认为0，即每次Full GC都会进行碎片整理__ |
| `-XX+UseCMSCompactAtFullCollection` | 布尔类型 | CMS采用`标记-清除`算法，容易产生内存碎片，浪费内存资源。该参数启用内存压缩，清理碎片，可能会影响性能，但是可以消除碎片 |
| `-XX:+UseCMSInitiatingOccupancyOnly` | 布尔类型 | 允许使用占用值作为启动CMS收集器的唯一标准。 默认情况下，此选项被禁用，并且可以使用其他条件。 |
| `-XX:CMSInitiatingOccupancyFraction=<percent>` | 数值类型 | 由于CMS存在并发清理过程，即清理时用户线程继续运行，因此可能产生垃圾，所以在触发Full GC时，需要预留空间供用户线程使用。该参数设置触发CAS进行Full GC的内存占用比(0到100)。__默认为-1，任何负值包括默认值，意味着需要设置`-XX:CMSTriggerRatio`来定义初始占用比__ |
| `-XX:CMSInitiatingPermOccupancyFraction=<percent>` | 数值类型 | 设置永久代触发GC的占用比，此参数在JDK 8中被弃用，且无替代参数 |
| `-XX:+CMSIncrementalMode` | 布尔类型 | 启用增量式的CMS收集器。该参数在JDK 8中被弃用，且无替代参数 |

# 7 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [JMV Options 官方文档1](http://www.oracle.com/technetwork/articles/java/vmoptions-jsp-140102.html)
* [JMV Options 官方文档2](http://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html#BABDJJFI)
