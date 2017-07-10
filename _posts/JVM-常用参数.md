---
title: JVM 常用参数
date: 2017-07-10 18:55:43
tags:
---

__目录__

<!-- toc -->
<!--more-->

# 前言

本篇博客将介绍几类常用的JVM参数，JVM参数也就是写在`java`命令中的参数

`-XX参数`被称为__不稳定参数__，之所以这么叫是因为此类参数的设置很容易引起JVM性能上的差异，使JVM存在极大的不稳定性。当然这是在非合理设置的前提下，如果此类参数设置合理将大大提高JVM的性能及稳定性。

可以说"不稳定参数"是一柄双刃剑，用的好攻无不克，用的差将带来麻烦。如何合理利用不稳定参数一直是一个不断实践不断改善的过程，无法用统一的标准去衡量。一切都需要在系统的不断运行，问题不断出现，参数不断修改，重新不断运行的循环过程中完善。也就是说没有最好的配置标准，只有适合当前系统的标准。这是一个循序渐进的过程。但有一些前人总结过得经验教训可供我们来参考，并去寻找适合自己的那些配置。

# 语法规则

布尔类型参数值
* -XX:+&lt;option&gt;：'+'表示启用该选项
* -XX:-&lt;option&gt;：'-'表示关闭该选项

数字类型参数值
* -XX:&lt;option&gt;=&lt;number&gt;：给选项设置一个数字类型值，可跟随单位，例如：'m'或'M'表示兆字节;'k'或'K'千字节;'g'或'G'千兆字节。32K与32768是相同大小的。

字符串类型参数值：
* -XX:&lt;option&gt;=&lt;string&gt;：给选项设置一个字符串类型值，通常用于指定一个文件、路径或一系列命令列表。例如：-XX:HeapDumpPath=./dump.core

# 堆大小设置

JVM中堆的大小有以下三方面的限制：
1. 相关操作系统的数据模型（32-bt/64-bit）限制
1. 系统的可用虚拟内存限制
1. 系统的可用物理内存限制。32位系统下，一般限制在1.5G~2G，64为操作系统对内存无限制

示例1：`java -Xmx3550m -Xms3550m -Xmn2g -Xss128k`

* __-Xmx3550m__：设置JVM最大可用内存为3550M
* __-Xms3550m__：设置JVM促使内存为3550m。此值可以设置与-Xmx相同，以避免每次垃圾回收完成后JVM重新分配内存
* __-Xmn2g__：设置年轻代大小为2G。整个堆大小 = 年轻代大小 + 年老代大小 + 持久代大小。持久代一般固定大小为64m，所以增大年轻代后，将会减小年老代大小。此值对系统性能影响较大，Sun官方推荐配置为整个堆的3/8
* __-Xss128k__：设置每个线程的堆栈大小。JDK5.0以后每个线程堆栈大小为1M，以前每个线程堆栈大小为256K。更具应用的线程所需内存大小进行调整。在相同物理内存下，减小这个值能生成更多的线程。但是操作系统对一个进程内的线程数还是有限制的，不能无限生成，经验值在3000~5000左右

示例2：`java -Xmx3550m -Xms3550m -Xss128k -XX:NewRatio=4 -XX:SurvivorRatio=4 -XX:MaxPermSize=16m -XX:MaxTenuringThreshold=0`
* __-XX:NewRatio=4__:设置年轻代（包括Eden和两个Survivor区）与年老代的比值（除去持久代）。设置为4，则年轻代与年老代所占比值为1：4，年轻代占整个堆栈的1/5
* __-XX:SurvivorRatio=4__：设置年轻代中Eden区与Survivor区的大小比值。设置为4，则两个Survivor区与一个Eden区的比值为2:4，一个Survivor区占整个年轻代的1/6
* __-XX:MaxPermSize=16m__:设置持久代大小为16m
* __-XX:MaxTenuringThreshold=0__：设置垃圾最大年龄。如果设置为0的话，则年轻代对象不经过Survivor区，直接进入年老代。对于年老代比较多的应用，可以提高效率。如果将此值设置为一个较大值，则年轻代对象会在Survivor区进行多次复制，这样可以增加对象再年轻代的存活时间，增加在年轻代即被回收的概论


# 垃圾收集器设置

JVM给了三种选择：串行收集器、并行收集器、并发收集器，但是串行收集器只适用于小数据量的情况，所以这里的选择主要针对并行收集器和并发收集器。默认情况下，JDK5.0以前都是使用串行收集器，如果想使用其他收集器需要在启动时加入相应参数。JDK5.0以后，JVM会根据当前系统配置进行判断。
吞吐量优先的并行收集器


* __UseParNewGC__：打开此开关后，使用ParNew+Serial Old的收集器组合进行内存回收
* __UseConcMarkSweepGC__：打开此开关后，使用ParNew+CMS+Serial Old的收集器组合进行内存回收，Serial Old收集器将作为CMS收集器出现在Concurrent Mode Failure失败后的后备收集器使用
* __UseParallelGC__：虚拟机运行在Server模式下的默认值，打开此开关后，使用Parallel Scavenge+Serial Old(PS MarkSweep)的收集器组合进行内存回收
* __UseParallelOldGC__：打开此开关后，使用Parallel Scavenge+Parallel Old的收集器组合进行内存回收
* __SurvivorRatio__：新生代中Eden区域与Survivor区域的容量比值，默认为8，代表Eden：Survivor=8：1
* __PretenureSizeThreshold__：直接晋升到老年代的对象大小，设置这个参数后，大于这个参数的对象将直接在老年代分配
* __MaxTenuringThreshold__：晋升到老年代的对象年龄，每个对象在坚持过一次Minor GC之后，年龄就增加1，当超过这个参数值时就进入老年代
* __UseAdaptiveSizePolicy__：动态调整Java堆中各个区域的大小以及进入老年代的年龄
* __HandlePromotionFailure__：是否允许分配担保失败，即老年代的剩余空间不足以应付新生代的整个Eden和Survivor区的所有对象都存活的极端情况
* __ParallelGCThreads__：设置并行GC时进行内存回收的线程总数
* __GCTimeRatio__：GC时间占总时间的比率，默认值为99，即允许1%的GC时间，仅在使用Parallel Scavenge收集器时生效
* __MaxGCPauseMillis__：设置GC的最大停顿时间，仅在使用Parallel Scavenge收集器时生效
* __CMSInitiatingOccupancyFraction__：设置CMS收集器在老年代空间被使用多少后出发垃圾收集，默认值为68%，仅在使用CMS收集器时生效
* __UseCMSCompactAtFullCollection__：设置CMS收集器在完成垃圾收集后是否要进行一次内存碎片整理，仅在使用CMS收集时生效
* __CMSFullGCsBeforeCompaction__：设置CMS收集器在进行若干垃圾收集后再启动一次内存碎片整理，仅在使用CMS收集器时生效



示例1：`java -Xmx3800m -Xms3800m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:ParallelGCThreads=20`
* __-XX:+UseParallelGC__：选择垃圾收集器为并行收集器。此配置仅对年轻代有效。即上述配置下，年轻代使用并发收集，而年老代仍旧使用串行收集
* __-XX:ParallelGCThreads=20__：配置并行收集器的线程数，即：同时多少个线程一起进行垃圾回收。此值最好配置与处理器数目相等

示例2：`java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:ParallelGCThreads=20 -XX:+UseParallelOldGC`
* __-XX:+UseParallelOldGC__：配置年老代垃圾收集方式为并行收集。JDK6.0支持对年老代并行收集

示例3：`java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:MaxGCPauseMillis=100`
* __-XX:MaxGCPauseMillis=100__:设置每次年轻代垃圾回收的最长时间，如果无法满足此时间，JVM会自动调整年轻代大小，以满足此值

示例4：`java -Xmx3550m -Xms3550m -Xmn2g -Xss128k -XX:+UseParallelGC -XX:MaxGCPauseMillis=100-XX:+UseAdaptiveSizePolicy`
* __-XX:+UseAdaptiveSizePolicy__：设置此选项后，并行收集器会自动选择年轻代区大小和相应的Survivor区比例，以达到目标系统规定的最低相应时间或者收集频率等，此值建议使用并行收集器时，一直打开


# 参数大全

| 参数名 | 描述 |
|:--|:--|
| __-XX:[+-]UseSerialGC__ | 虚拟机运行在Client模式下的默认值，打开此开关后，使用Serial+Serial Old的收集器组合进行内存回收 |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |
|  |  |