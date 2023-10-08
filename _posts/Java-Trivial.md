---
title: Java-Trivial
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

## 1.1 Execute

* `java -cp /path/aaa.jar com.liuyehcf.demo.MyMain arg1 arg2`：将`/path/aaa.jar`添加到`classpath`中
* `java -cp /path/aaa.jar:/path/bbb.jar com.liuyehcf.demo.MyMain arg1 arg2`：将`/path/aaa.jar`和`/path/bbb.jar`添加到`classpath`中
* `java -cp "/path/*" com.liuyehcf.demo.MyMain arg1 arg2`：将`/path`目录下的所谓`class`文件以及`jar`文件都添加到`classpath`中。这里要用引号，否则`*`展开后，第二项会被作为`main`函数所在的类
* `java -cp "/path/*":"/path2/*" com.liuyehcf.demo.MyMain arg1 arg2`：将`/path`以及`/path2`目录下的所谓`class`文件以及`jar`文件都添加到`classpath`中
* `java -jar /path/aaa.jar arg1 arg2`：运行jar归档文件中指定的`main`函数

## 1.2 Enable Debug

**`java -Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=8000,suspend=n [其他参数]`**

* `-Xrunjdwp`：通知JVM使用`Java debug wire protocol`运行调试环境
* `transport`：指定了调试数据的传送方式，`dt_socket`是指用`SOCKET`模式
* `address`：调试服务器的地址
    * `8000`
    * `127.0.0.1:8000`
    * `0.0.0.0:8000`
* `server=y/n`：y表示当前是调试服务端，n表示当前是调试客户端
* `suspend`：表示启动时不中断。一般用于调试启动不了的问题

# 2 jps

列出正在运行的虚拟机进程，并显示虚拟机执行主类名称以及这些进程的**本地虚拟机唯一`ID(Local Virtual Machine Identifier, LVMID)`**

虽然功能比较单一，但它是使用频率最高的`JDK`命令行工具，因为其他`JDK`工具大多需要输入它查询到的`LVMID`来确定要监控的是哪一个虚拟机进程

**对本地虚拟机来说，`LVMID`与操作系统的进程`ID(Process Identifier，PID)`是一致的**，使用`Windows`的任务管理器或者`UNIX`的`ps`命令也可以查询到虚拟机进程的`LVMID`，如果同时启动了多个虚拟机进程，无法根据进程名称定位时，就只能依赖`jps`命令显示主类的功能才能区分了

**格式：**

* `jps [options] [hostid]`

**参数说明：**

* `-q`：只输出`LVMID`，省略主类的名称
* `-m`：输出虚拟机进程启动时传递给主类`main()`函数的参数
* `-l`：输出主类的全名，如果进程执行的是`Jar`包，输出`Jar`路径
* `-v`：输出虚拟机进程启动时的`JVM`参数

# 3 jstat

`jstat(JVM Statistics Monitoring Tool)`是用于监视虚拟机各种运行状态信息的命令行工具

`jstat`可以显示本地或者远程虚拟机进程中的类装载、内存、垃圾收集、`JIT`编译等运行数据，在没有`GUI`图形界面，只提供了纯文本控制台环境的服务器上，它将是运行期定位虚拟机性能问题的首选工具

**格式：**

* `jstat [option <vmid> [interval [s|ms] [count] ] ]`

**参数说明：**

* 如果是本地虚拟机进程，`VMID`与`LVMID`是一致的，如果是远程虚拟机进程，那`VMID`的格式应当是
    * `[protocol:] [//] lvmid [@hostname[:port]/servername]`
* `interval`和`count`代表查询间隔和次数，如果省略这两个参数，说明只查询一次
    * `jstat -gc 2764 250 20`：每`250`毫秒查询一次进程`2764`垃圾收集情况，一共查询`20`次
* `-class`：监视类装载、卸载数量、总空间以及类装载所耗费的时间
* `-gc`：监视`Java`堆状况，包括`Eden`区、两个`survivor`区、老年代、永久代等的容量、已用空间、`GC`时间合计等信息
* `-gccapacity`：监视内容与`-gc`基本相同，但输出主要关注`Java`堆各个区域使用到的最大、最小空间
* `-gcutil`：监视内容与`-gc`基本相同，但输出主要关注已使用空间占总空间的百分比
* `-gccause`：与`-gcutil`功能一样，但是会额外输出导致上一次`GC`产生的原因
* `-gcnew`：监视新生代`GC`状况
* `-gcnewcapacity`：监视内容与`-gcnew`基本相同，输出主要关注使用到的最大、最小空间
* `-gcold`：监视老年代`GC`状况
* `-gcoldcapacity`：监视内容与`-gcold`基本相同，输出主要关注使用到的最大、最小空间
* `-gcpermcapacity`：输出永久代使用到的最大、最小空间
* `-compiler`：输出`JIT`编译器编译过的方法、耗时等信息
* `-printcompilation`：输出已经被`JIT`编译的方法

**输出内容意义：**

* `E`：新生代区`Eden`
* `S0\S1`：`Survivor0`、`Survivor1`这两个`Survivor`区
* `O`：老年代`Old`
* `P`：永久代`Permanet`
* `YGC`：`Young GC`
* `YGCT`：`Yount GC Time`
* `FGC`：`Full GC`
* `FTCG`：`Full GC Time`
* `GCT`：`Minor GC`与`Full GC`总耗时

**示例：**

* **`jstat -gc <vmid> 1000 1000`：查看`JVM`内存使用**
* **`jstat -gcutil <vmid> 1000 1000`：查看`JVM`内存使用（百分比）**

# 4 jinfo

`jinfo(Configuration Info for Java)`的作用是实时地查看和调整虚拟机各项参数

使用`jps`命令的`-v`参数可以查看虚拟机启动时显示指定的参数列表，**但如果想知道未被显式指定的参数的系统默认值，除了去查找资料外，就只能用`jinfo`的`-flag`选项进行查询**

如果`JDK1.6`或者以上版本，可以使用`-XX:+PrintFlagsFinal`查看参数默认值

`jinfo`还可以使用`-sysprops`选项把虚拟机进程的`System.getProperties()`的内容打印出来

**格式：**

* `jinfo [option] <vmid>`

**参数说明**

* `-flag`：显式默认值
    * `jinfo -flags 1874`：显式所有项的默认值
    * `jinfo -flag CICompilerCount 1874`：显示指定项的默认值
* `-sysprops`：把虚拟机进程的System.getProperties()的内容打印出来

# 5 jmap

`jmap(Memory Map for Java)`命令用于生成堆转储快照(一般称为`heapdump`或`dump`文件)

`jmap`的作用并不仅仅为了获取`dump`文件，它还可以查询`finalize`执行队列、`Java`堆和永久代的详细信息，如空间使用率、当前用的是哪种收集器等

**格式：**

* `jmap [option] <vmid>`

**参数说明：**

* `-dump`：生成Java堆转储快照，格式为`-dump:[live, ]format=b, file=<filename>`，其中`live`子参数说明是否只`dump`出存活对象
* `-finalizerinfo`：显示在`F-Queue`中等待`Finalizer`线程执行`finalize`方法的对象
* `-heap`：显示`Java`堆详细信息，如使用哪种回收器，参数配置，分代状况等
* `-histo`：显示堆中对象统计信息，包括类、实例数量、合计容量
* `-permstat`：以`ClassLoader`为统计口径显示永久代内存状态
* `-F`：当虚拟机进程对`-dump`选项没有响应时，可使用这个选项强制生成`dump`快照

**示例**

* `jmap -dump:format=b,file=<dump_文件名> <java进程号>`：`dump`进程所有对象的堆栈
* `jmap -dump:live,format=b,file=<dump_文件名> <java进程号>`：`dump`进程中存活对象的堆栈，会触发`full gc`
* `jmap -histo:live <vmid>`：触发`full gc`
* `jmap -histo <vmid> | sort -k 2 -g -r | less`：统计堆栈中对象的内存信息，按照对象实例个数降序打印
* `jmap -histo <vmid> | sort -k 3 -g -r | less`：统计堆栈中对象的内存信息，按照对象占用内存大小降序打印

# 6 jhat

`jhat`是虚拟机堆转储快照分析工具

`Sun JDK`提供`jhat(JVM Heap Analysis Tool)`命令与`jmap`搭配使用，来分析`jmap`生成的堆转储快照

`jhat`内置了一个微型的`HTTP/HTML`服务器，生成`dump`文件的分析结果后，可以在浏览器中查看

不过在实际工作中，除非真的没有别的工具可用，否则一般不会直接使用`jhat`命令来分析`dump`文件，原因如下

* 一般不会再部署应用程序的服务器上直接分析`dump`文件，即使可以这样做，也会尽量将`dump`文件复制到其他机器上进行分析，因为分析工作是一个耗时而且消耗硬件资源的过程，既然都要在其他机器上进行，就没有必要受到命令工具的限制了
* `jhat`的分析功能相对来说比较简陋，`VisualVM`，以及专业用于分析`dump`文件的`Eclipse Memory Analyzer`、`IBM HeapAnalyzer`等工具，都能实现比`jhat`更强大更专业的分析功能

**配合jmap的例子**

1. `jmap -dump:format=b,file=dump.bin 1874`
    * 文件相对路径为`dump.bin`
    * `vmid`为1874
1. `jhat dump.bin`
    * 在接下来的输出中会指定端口`7000`
    * 在浏览器中键入`http://localhost:7000/`就可以看到分析结果，拉到最下面，包含如下导航：
        * All classes including platform
        * Show all members of the rootset
        * Show instance counts for all classes (including platform)
        * Show instance counts for all classes (excluding platform)
        * Show heap histogram
        * Show finalizer summary
        * Execute Object Query Language (OQL) query

# 7 jstack

`jstack`是`Java`堆栈跟踪工具

`jstack(Stack Trace for Java)`命令用于生成虚拟机当前时刻的线程快照(一般称为`trheaddump`或者`javacore`文件)

线程快照就是当前虚拟机每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，如线程死锁、死循环、请求外部资源导致的长时间等待都是导致线程长时间停顿的常见原因

线程出现停顿的时候通过`jstack`来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做了什么，或者等待什么资源

**格式：**

* `jstack [option] <vmid>`

**参数说明：**

* `-F`：当正常输出的请求不被响应时，强制输出线程堆栈
* `-l`：除堆栈外，显示关于锁的附加信息
* `-m`：如果调用本地方法的话，可以显示C/C++的堆栈

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

# 11 Arthas

[Arthas](https://github.com/alibaba/arthas)

[commands](https://arthas.aliyun.com/doc/commands.html)

# 12 VisualVM

[All-in-One Java Troubleshooting Tool](https://visualvm.github.io/)

## 12.1 Shallow Size vs. Retained Size

`Shallow Size`: This is the amount of memory allocated to store the object itself, not including the objects it references. This includes the memory used by the object's fields (for primitive types) and the memory used to store the references to other objects (for reference types). It does not include the memory used by the objects those references point to. Tools like VisualVM generally show the shallow size by default.

`Retained Size`: This is the total amount of memory that would be freed if the object were garbage collected. This includes the shallow size of the object itself plus the shallow size of any objects that are exclusively referenced by this object (i.e., objects that would be garbage collected if this object were). The retained size provides a more complete picture of the "true" memory impact of an object but can be more complex to calculate. Some profiling tools provide this information, but it may require additional analysis or plugins.

# 13 Assorted

## 13.1 Install JDK

* [Java SE 17 Archive Downloads](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)

## 13.2 JDK Install Path

Linux：可以通过`readlink -f $(which java)`查看绝对路径，一般来说是`/usr/lib/jvm`

MacOS：`/Library/Java/JavaVirtualMachines`

# 14 参考

* [JVM性能调优监控工具jps、jstack、jmap、jhat、jstat、hprof使用详解](https://my.oschina.net/feichexia/blog/196575)
* [Java应用打开debug端口](https://www.cnblogs.com/lzmrex/articles/12579862.html)
* [别嘲笑我，工作几年的程序员也不一定会远程debug代码](https://www.bilibili.com/video/BV1ky4y1j73x/)
