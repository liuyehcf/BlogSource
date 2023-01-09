---
title: Java-命令行工具
date: 2018-01-17 09:30:44
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- Command Line Tool
---

**阅读更多**

<!--more-->

# 1 java

## 1.1 开启调试端口

**`java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n [其他参数]`**

* `-Xrunjdwp`：通知JVM使用`Java debug wire protocol`运行调试环境
* `transport`：指定了调试数据的传送方式，`dt_socket`是指用`SOCKET`模式
* `address`：调试服务器的端口号
* `server=y/n`：y表示当前是调试服务端，n表示当前是调试客户端
* `suspend`：表示启动时不中断。一般用于调试启动不了的问题

# 2 jps

列出正在运行的虚拟机进程，并显示虚拟机执行主类(Main Class, main()函数所在的类)名称以及这些进程的**本地虚拟机唯一ID(Local Virtual Machine Identifier, LVMID)**

虽然功能比较单一，但它是使用频率最高的JDK命令行工具，因为其他JDK工具大多需要输入它查询到的LVMID来确定要监控的是哪一个虚拟机进程

**对本地虚拟机来说，LVMID与操作系统的进程ID(Process Identifier，PID)是一致的**，使用Windows的任务管理器或者UNIX的ps命令也可以查询到虚拟机进程的LVMID，如果同时启动了多个虚拟机进程，无法根据进程名称定位时，就只能依赖jps命令显示主类的功能才能区分了

**格式：**

* `jps [options] [hostid]`

**参数说明：**

* `-q`：只输出LVMID，省略主类的名称
* `-m`：输出虚拟机进程启动时传递给主类main()函数的参数
* `-l`：输出主类的全名，如果进程执行的是Jar包，输出Jar路径
* `-v`：输出虚拟机进程启动时的JVM参数

# 3 jstat

jstat(JVM Statistics Monitoring Tool)是用于监视虚拟机各种运行状态信息的命令行工具

jstat可以显示本地或者远程虚拟机进程中的类装载、内存、垃圾收集、JIT编译等运行数据，在没有GUI图形界面，只提供了纯文本控制台环境的服务器上，它将是运行期定位虚拟机性能问题的首选工具

**格式：**

* `jstat [option vmid [interval [s|ms] [count] ] ]`

**参数说明：**

* 如果是本地虚拟机进程，VMID与LVMID是一致的，如果是远程虚拟机进程，那VMID的格式应当是
    * `[protocol:] [//] lvmid [@hostname[:port]/servername]`
* `interval`和`count`代表查询间隔和次数，如果省略这两个参数，说明只查询一次
    * `jstat -gc 2764 250 20`：每250毫秒查询一次进程2764垃圾收集情况，一共查询20次
* `-class`：监视类装载、卸载数量、总空间以及类装载所耗费的时间
* `-gc`：监视Java堆状况，包括Eden区、两个survivor区、老年代、永久代等的容量、已用空间、GC时间合计等信息
* `-gccapacity`：监视内容与-gc基本相同，但输出主要关注Java堆各个区域使用到的最大、最小空间
* `-gcutil`：监视内容与-gc基本相同，但输出主要关注已使用空间占总空间的百分比
* `-gccause`：与-gcutil功能一样，但是会额外输出导致上一次GC产生的原因
* `-gcnew`：监视新生代GC状况
* `-gcnewcapacity`：监视内容与-gcnew基本相同，输出主要关注使用到的最大、最小空间
* `-gcold`：监视老年代GC状况
* `-gcoldcapacity`：监视内容与-gcold基本相同，输出主要关注使用到的最大、最小空间
* `-gcpermcapacity`：输出永久代使用到的最大、最小空间
* `-compiler`：输出JIT编译器编译过的方法、耗时等信息
* `-printcompilation`：输出已经被JIT编译的方法

**输出内容意义：**

* `E`：新生代区Eden
* `S0\S1`：Survivor0、Survivor1这两个Survivor区
* `O`：老年代Old
* `P`：永久代Permanet
* `YGC`：Young GC，即Minor GC次数
* `YGCT`：Yount GC Time，即Minor GC耗时
* `FGC`：Full GC
* `FTCG`：Full GC Time，即Full GC耗时
* `GCT`：Minor GC与Full GC总耗时

# 4 jinfo

jinfo(Configuration Info for Java)的作用是实时地查看和调整虚拟机各项参数

使用jps命令的-v参数可以查看虚拟机启动时显示指定的参数列表，**但如果想知道未被显式指定的参数的系统默认值，除了去查找资料外，就只能用jinfo的-flag选项进行查询**

如果JDK1.6或者以上版本，可以使用-XX:+PrintFlagsFinal查看参数默认值

jinfo还可以使用-sysprops选项把虚拟机进程的System.getProperties()的内容打印出来

**格式：**

* `jinfo [option] pid`

**参数说明**

* `-flag`：显式默认值
    * `jinfo -flags 1874`：显式所有项的默认值
    * `jinfo -flag CICompilerCount 1874`：显示指定项的默认值
* `-sysprops`：把虚拟机进程的System.getProperties()的内容打印出来

# 5 jmap

jmap(Memory Map for Java)命令用于生成堆转储快照(一般称为heapdump或dump文件)

jmap的作用并不仅仅为了获取dump文件，它还可以查询finalize执行队列、Java堆和永久代的详细信息，如空间使用率、当前用的是哪种收集器等

**格式：**

* `jmap [option] vmid`

**参数说明：**

* `-dump`：生成Java堆转储快照，格式为`-dump:[live, ]format=b, file=<filename>`，其中live子参数说明是否只dump出存活对象
* `-finalizerinfo`：显示在F-Queue中等待Finalizer线程执行finalize方法的对象
* `-heap`：显示Java堆详细信息，如使用哪种回收器，参数配置，分代状况等
* `-histo`：显示堆中对象统计信息，包括类、实例数量、合计容量
* `-permstat`：以ClassLoader为统计口径显示永久代内存状态
* `-F`：当虚拟机进程对-dump选项没有响应时，可使用这个选项强制生成dump快照

**示例**

* `jmap -dump:format=b,file=<dump_文件名> <java进程号>`：dump进程所有对象的堆栈
* `jmap -dump:live,format=b,file=<dump_文件名> <java进程号>`：dump进程中存活对象的堆栈，会触发full gc
* `jmap -histo:live <pid>`：触发full gc
* `jmap -histo <pid> | sort -k 2 -g -r | less`：统计堆栈中对象的内存信息，按照对象实例个数降序打印
* `jmap -histo <pid> | sort -k 3 -g -r | less`：统计堆栈中对象的内存信息，按照对象占用内存大小降序打印

# 6 jhat

jhat是虚拟机堆转储快照分析工具

Sun JDK提供jhat(JVM Heap Analysis Tool)命令与jmap搭配使用，来分析jmap生成的堆转储快照

jhat内置了一个微型的HTTP/HTML服务器，生成dump文件的分析结果后，可以在浏览器中查看

不过在实际工作中，除非真的没有别的工具可用，否则一般不会直接使用jhat命令来分析dump文件，原因如下

* 一般不会再部署应用程序的服务器上直接分析dump文件，即使可以这样做，也会尽量将dump文件复制到其他机器上进行分析，因为分析工作是一个耗时而且消耗硬件资源的过程，既然都要在其他机器上进行，就没有必要受到命令工具的限制了
* jhat的分析功能相对来说比较简陋，VisualVM，以及专业用于分析dump文件的Eclipse Memory Analyzer、IBM HeapAnalyzer等工具，都能实现比jhat更强大更专业的分析功能

**配合jmap的例子**

1. `jmap -dump:format=b,file=dump.bin 1874`
    * 文件相对路径为`dump.bin`
    * `vmid`为1874
1. `jhat dump.bin`
1. 在接下来的输出中会指定端口`7000`
1. 在浏览器中键入`http://localhost:7000/`就可以看到分析结果，拉到最下面，包含如下导航：
    * All classes including platform
    * Show all members of the rootset
    * Show instance counts for all classes (including platform)
    * Show instance counts for all classes (excluding platform)
    * Show heap histogram
    * Show finalizer summary
    * Execute Object Query Language (OQL) query

# 7 jstack

jstack是Java堆栈跟踪工具

jstack(Stack Trace for Java)命令用于生成虚拟机当前时刻的线程快照(一般称为trheaddump或者javacore文件)

线程快照就是当前虚拟机每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，如线程死锁、死循环、请求外部资源导致的长时间等待都是导致线程长时间停顿的常见原因

线程出现停顿的时候通过jstack来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做了什么，或者等待什么资源

**格式：**

* jstack [option] vmid

**参数说明：**

* `-F`：当正常输出的请求不被响应时，强制输出线程堆栈
* `-l`：除堆栈外，显示关于锁的附加信息
* `-m`：如果调用本地方法的话，可以显示C/C++的堆栈

**示例：**

* **`jstat -gcutil vmid 1000 1000`：查看JVM内存使用**

**在JDK1.5中，java.lang.Thread类新增一个getAllStackTraces()方法用于获取虚拟机中所有线程的StackTraceElement对象，使用这个对象可以通过简单的几行代码就能完成jstack的大部分功能，在实际项目中不妨调用这个方法做个管理员页面，可以随时使用浏览器来查看线程堆栈**

# 8 jad

Java反编译工具，[下载地址](http://www.javadecompilers.com/jad)

# 9 java_home

**`/usr/libexec/java_home -V`：用于查看本机上所有版本java的安装目录**

# 10 jar

**制作归档文件：：`jar cvf xxx.jar -C ${target_dir1} ${dir_or_file1} -C ${target_dir2} ${dir_or_file2} ...`**

* **注意`-C`只对后面一个参数有效**
* `jar cvf xxx.jar .`
* `jar cvf xxx.jar org com/test/A.class`
* `jar cvf xxx.jar -C classes org -C classes com`

**解压归档文件：`jar xvf xxx.jar`**

* 不支持解压到指定目录

**查看归档文件：`jar tf xxx.jar`**

# 11 [Arthas](https://github.com/alibaba/arthas)

# 12 参考

* [JVM性能调优监控工具jps、jstack、jmap、jhat、jstat、hprof使用详解](https://my.oschina.net/feichexia/blog/196575)
* [Java应用打开debug端口](https://www.cnblogs.com/lzmrex/articles/12579862.html)
* [别嘲笑我，工作几年的程序员也不一定会远程debug代码](https://www.bilibili.com/video/BV1ky4y1j73x/)
