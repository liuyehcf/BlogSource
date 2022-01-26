---
title: Linux-Kernel
date: 2020-10-15 15:12:44
tags: 
- 原创
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 C相关知识储备

## 1.1 宏

1. `#`：用于把一个宏参数转变为字符串
1. `##`：用于把两个宏参数贴合在一起

# 2 如何编译内核

**准备环境：这里我安装的系统是`CentOS-7-x86_64-Minimal-1908.iso`**

**第一步：安装编译相关的软件**

```sh
yum makecache
yum -y install ncurses-devel make gcc bc openssl-devel
yum -y install elfutils-libelf-devel
yum -y install rpm-build
```

**第二步：下载内核源码并解压**

```sh
yum install -y wget
wget -O ~/linux-4.14.134.tar.gz 'http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v4.x/linux-4.14.134.tar.gz'
tar -zxvf ~/linux-4.14.134.tar.gz -C ~
```

**第三步：配置内核编译参数**

```sh
cd ~/linux-4.14.134
cp -v /boot/config-$(uname -r) .config

# 直接save然后exit即可
make menuconfig
```

**第四步：编译内核**

```sh
cd ~/linux-4.14.134
make rpm-pkg
```

**第五步：更新内核**

```sh
# 查看rpm包的信息
rpm2cpio kernel-4.14.134.x86_64.rpm | cpio -div

rpm -iUv ~/rpmbuild/RPMS/x86_64/*.rpm
```

## 2.1 参考

* [内核源码下载地址](http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/)
* [Compile Linux Kernel on CentOS7](https://linuxhint.com/compile-linux-kernel-centos7/)
* [How to Compile a Linux Kernel](https://www.linux.com/topic/desktop/how-compile-linux-kernel-0/)
* [CentOS 7上Systemtap的安装](https://www.linuxidc.com/Linux/2019-03/157818.htm)
* [如何解压RPM包](https://www.cnblogs.com/joeblackzqq/archive/2011/03/19/1989137.html)
* [教你三步在CentOS 7 中安装或升级最新的内核](https://www.linuxprobe.com/update-kernel-centos7.html)

# 3 systemtap

## 3.1 如何安装

**准备环境：这里我安装的系统是`CentOS-7-x86_64-Minimal-1810.iso`**

**第一步：安装systemtap以及其他相关依赖**

```sh
yum makecache
yum install -y systemtap systemtap-runtime systemtap-devel --enablerepo=base-debuginfo
yum install -y yum-utils
yum install -y gcc
```

**第二步：下载并安装跟当前内核版本匹配的rpm包，包括`kernel-devel-$(uname -r).rpm`、`kernel-debuginfo-$(uname -r).rpm`、`kernel-debuginfo-common-x86_64-$(uname -r).rpm`，我的内核版本是`3.10.0-957.el7.x86_64`**

```sh
wget "ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/7.6/x86_64/os/Packages/kernel-devel-$(uname -r).rpm"
wget "http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-$(uname -r).rpm"
wget "http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-$(uname -r).rpm"

rpm -ivh kernel-devel-$(uname -r).rpm kernel-debuginfo-$(uname -r).rpm kernel-debuginfo-common-x86_64-$(uname -r).rpm
```

**第三步：验证**

```sh
stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'

#-------------------------↓↓↓↓↓↓-------------------------
Pass 1: parsed user script and 473 library scripts using 271776virt/69060res/3500shr/65708data kb, in 680usr/60sys/890real ms.
Pass 2: analyzed script: 1 probe, 1 function, 7 embeds, 0 globals using 436952virt/232648res/4856shr/230884data kb, in 2560usr/760sys/3456real ms.
Pass 3: translated to C into "/tmp/stapYnJEvY/stap_0969603f9a0fb68895de95cd2ffea0a4_2770_src.c" using 436952virt/232904res/5112shr/230884data kb, in 10usr/80sys/86real ms.
Pass 4: compiled C into "stap_0969603f9a0fb68895de95cd2ffea0a4_2770.ko" in 8930usr/1690sys/10746real ms.
Pass 5: starting run.
ERROR: module version mismatch (#1 SMP Tue Oct 30 14:13:26 CDT 2018 vs #1 SMP Thu Nov 8 23:39:32 UTC 2018), release 3.10.0-957.el7.x86_64
WARNING: /usr/bin/staprun exited with status: 1
Pass 5: run completed in 20usr/40sys/271real ms.
Pass 5: run failed.  [man error::pass5]
#-------------------------↑↑↑↑↑↑-------------------------
```

可以看到报错信息`ERROR: module version mismatch (#1 SMP Tue Oct 30 14:13:26 CDT 2018 vs #1 SMP Thu Nov 8 23:39:32 UTC 2018), release 3.10.0-957.el7.x86_64`，这是由于`compile.h`文件中的时间与`uname -a`中的时间不一致

其中，`compile.h`的文件路径为`/usr/src/kernels/$(uname -r)/include/generated/compile.h`，我们将该文件中的时间修改为`uname -a`中的时间信息。编辑`compile.h`文件，将`#define UTS_VERSION "#1 SMP Tue Oct 30 14:13:26 CDT 2018"`修改为`#define UTS_VERSION "#1 SMP Thu Nov 8 23:39:32 UTC 2018"`

再次尝试验证

```sh
stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'

#-------------------------↓↓↓↓↓↓-------------------------
Pass 1: parsed user script and 473 library scripts using 271696virt/69056res/3500shr/65628data kb, in 640usr/40sys/687real ms.
Pass 2: analyzed script: 1 probe, 1 function, 7 embeds, 0 globals using 436944virt/230840res/4804shr/230876data kb, in 1930usr/440sys/2376real ms.
Pass 3: using cached /root/.systemtap/cache/09/stap_0969603f9a0fb68895de95cd2ffea0a4_2770.c
Pass 4: using cached /root/.systemtap/cache/09/stap_0969603f9a0fb68895de95cd2ffea0a4_2770.ko
Pass 5: starting run.
ERROR: module version mismatch (#1 SMP Tue Oct 30 14:13:26 CDT 2018 vs #1 SMP Thu Nov 8 23:39:32 UTC 2018), release 3.10.0-957.el7.x86_64
WARNING: /usr/bin/staprun exited with status: 1
Pass 5: run completed in 0usr/40sys/259real ms.
Pass 5: run failed.  [man error::pass5]
#-------------------------↑↑↑↑↑↑-------------------------
```

发现还是报同样的信息，这是因为我们的修改尚未生效，系统读取的是缓存数据，将`Pass 3`和`Pass 4`中提到的两个缓存文件删除，再重新执行即可

```sh
rm -f /root/.systemtap/cache/09/stap_0969603f9a0fb68895de95cd2ffea0a4_2770.c
rm -f /root/.systemtap/cache/09/stap_0969603f9a0fb68895de95cd2ffea0a4_2770.ko

stap -v -e 'probe vfs.read {printf("read performed\n"); exit()}'

#-------------------------↓↓↓↓↓↓-------------------------
Pass 1: parsed user script and 473 library scripts using 271696virt/69056res/3500shr/65628data kb, in 660usr/40sys/699real ms.
Pass 2: analyzed script: 1 probe, 1 function, 7 embeds, 0 globals using 436944virt/230052res/4804shr/230876data kb, in 1920usr/400sys/2333real ms.
Pass 3: translated to C into "/tmp/stappTXBiJ/stap_0969603f9a0fb68895de95cd2ffea0a4_2770_src.c" using 436944virt/230316res/5068shr/230876data kb, in 10usr/80sys/88real ms.
Pass 4: compiled C into "stap_0969603f9a0fb68895de95cd2ffea0a4_2770.ko" in 1540usr/370sys/1927real ms.
Pass 5: starting run.
read performed
Pass 5: run completed in 10usr/50sys/327real ms.
#-------------------------↑↑↑↑↑↑-------------------------
```

## 3.2 语法

### 3.2.1 probe的种类

1. `begin`：探测开始的地方
1. `end`：探测结束的地方
1. `kernel.function("sys_open")`：指定系统调用的入口处
1. `syscall.close.return`：系统调用`close`返回处
1. `module("ext3").statement(0xdeadbeef)`：文件系统`ext3`驱动的指定位置
1. `timer.ms(200)`：定时器，单位毫秒
1. `timer.profile`：每个CPU时钟都会触发
1. `process("a.out").statement("*@main.c:200")`：二进制程序`a.out`的200行的位置

## 3.3 参考

* [SystemTap Wiki](https://sourceware.org/systemtap/wiki)
* [SystemTap Kprobe原理](http://lzz5235.github.io/2013/12/18/systemtap-kprobe.html)
* [centos 7 systemtap 安装](https://www.jianshu.com/p/25e84f2e5a95)
* [再聊 TCP backlog](https://juejin.im/post/6844904071367753736)
* [systemtap从入门到放弃（一）](https://zhuanlan.zhihu.com/p/347313289)

# 4 ftrace

**本小节转载摘录自[Linux ftrace框架介绍及运用](https://www.cnblogs.com/arnoldlu/p/7211249.html)**

在日常工作中，经常会需要对内核进行debug、或者进行优化工作。一些简单的问题，可以通过`dmesg/printk`查看，优化借助一些工具进行。但是当问题逻辑复杂，优化面宽泛的时候，往往无从下手。需要从上到下、模块到模块之间分析，这时候就不得不借助于Linux提供的静态（`trace event`）动态（各种`tracer`）工具进行分析。同时还不得不借助工具、或者编写脚本进行分析，以缩小问题范围、发现问题。简单的使用`tracepoint`已经不能满足需求，因此就花点精力进行梳理

`ftrace`是`function trace`的意思，最开始主要用于记录内核函数运行轨迹，随着功能的逐渐增加，演变成一个跟踪框架。包含了静态`tracepoint`，针对不同`subsystem`提供一个目录进行开关。还包括不同的动态跟踪器，`function`、`function_graph`、`wakeup`等等

`ftrace`的帮助文档在`Documentation/trace`，`ftrace`代码主要在`kernel/trace`，`ftrace`相关头文件在`include/trace`中

## 4.1 ftrace框架介绍

整个`ftrace`框架可以分为几部分：

1. `ftrace`核心框架：整个`ftrace`功能的纽带，包括对内和的修改，`tracer`的注册，`ring`的控制等等
1. `ring buffer`：静态动态`ftrace`的载体
1. `debugfs`：提供了用户空间对`ftrace`设置接口
1. `tracepoint`：静态`trace`
    * 他需要提前编译进内核
    * 可以定制打印内容，自由添加
    * 内核对主要`subsystem`提供了`tracepoint`
1. `tracer`：包含如下几类
    * `函数类`：`function`、`function_graph`、`stack`
    * `延时类`：`irqsoff`、`preemptoff`、`preemptirqsoff`、`wakeup`、`wakeup_rt`、`waktup_dl`
    * `其他`：`nop`、`mmiotrace`、`blk`

## 4.2 ftrace的配置和使用

`/sys/kernel/debug/tracing`目录下提供了ftrace的设置和属性接口，对`ftrace`的配置可以通过echo。了解每个文件的作用和如何设置对于理解整个`ftrace`框架很有作用

kernel很贴心的在这个目录下准备了一个README文档，查看这个文档就可以看到所有文件的使用方式和具体含义

```sh
cat /sys/kernel/debug/tracing/README
```

**通用配置：**

* **`available_tracers`当前编译及内核的跟踪器列表，`current_tracer`必须是这里面支持的跟踪器**
* **`current_tracer`：用于设置或者显示当前使用的跟踪器列表。系统启动缺省值为`nop`，使用echo将跟踪器名字写入即可打开。可以通过写入`nop`重置跟踪器**
* `buffer_size_kb`：用于设置单个CPU所使用的跟踪缓存的大小。跟踪缓存为`ring buffer`形式，如果跟踪太多，旧的信息会被新的跟踪信息覆盖掉。需要先将`current_trace`设置为nop才可以
* `buffer_total_size_kb`：显示所有的跟踪缓存大小，不同之处在于`buffer_size_kb`是单个CPU的，`buffer_total_size_kb`是所有CPU的和
* `free_buffer`：此文件用于在一个进程被关闭后，同时释放`ring buffer`内存，并将调整大小到最小值
* `hwlat_detector/`：
* `instances/`：创建不同的`trace buffer`实例，可以在不同的`trace buffers`中分开记录
* `tracing_cpumask`：可以通过此文件设置允许跟踪特定CPU，二进制格式
* `per_cpu`：CPU相关的trace信息，包括`stats`、`trace`、`trace_pipe`和`trace_pipe_raw`
* `printk_formats`：提供给工具读取原始格式`trace`的文件
* `saved_cmdlines`：存放`pid`对应的`comm`名称作为`ftrace`的`cache`，这样`ftrace`中不光能显示`pid`还能显示`comm`
* `saved_cmdlines_size`：`saved_cmdlines`的数目
* `snapshot`：是对trace的snapshot
    * `echo 0`：清空缓存，并释放对应内存
    * `echo 1`：进行对当前trace进行snapshot，如没有内存则分配
    * `echo 2`：清空缓存，不释放也不分配内存
* **`trace`：查看获取到的跟踪信息的接口，`echo > trace`可以清空当前`ring buffer`**
* `trace_pipe`：输出和`trace`一样的内容，但是此文件输出`trace`同时将`ring buffer`中的内容删除，这样就避免了`ring buffer`的溢出。可以通过`cat trace_pipe > trace.txt &`保存文件
* `trace_clock`：显示当前`trace`的`timestamp`所基于的时钟，默认使用local时钟
    * `local`：默认时钟；可能无法在不同CPU间同步
    * `global`：不同CUP间同步，但是可能比local慢
    * `counter`：这是一个跨CPU计数器，需要分析不同CPU间event顺序比较有效
* `trace_marker`：从用户空间写入标记到trace中，用于用户空间行为和内核时间同步
* `trace_marker_raw`：以二进制格式写入到trace中
* `trace_options`：控制`trace`打印内容或者操作跟踪器，可以通过`trace_options`添加很多附加信息
* `options`：`trace`选项的一系列文件，和`trace_options`对应
* `trace_stat/`：每个CPU的`trace`统计信息
* `tracing_max_latency`：记录`tracer`的最大延时
* **`tracing_on`：用于控制跟踪打开或停止**
    * `echo 0`：停止跟踪
    * `echo 1`：继续跟踪
* `tracing_thresh`：延时记录`trace`的阈值，当延时超过此值时才开始记录`trace`。单位是ms，只有非0才起作用

**events配置：**

* **`available_events`：列出系统中所有可用的`trace events`，分两个层级，用冒号隔开**
* `events/`：系统`trace events`目录，在每个`events`下面都有`enable`、`filter`和`fotmat`。`enable`是开关；`format`是`events`的格式，然后根据格式设置`filter`
* `set_event`：将`trace events`名称直接写入`set_event`就可以打开
* `set_event_pid`：指定追踪特定进程的`events`

**function配置：**

* **`available_filter_functions`：记录了当前可以跟踪的内核函数，不在该文件中列出的函数，无法跟踪其活动**
* `dyn_ftrace_total_info`：显示`available_filter_functins`中跟中函数的数目，两者一致
* `enabled_functions`：显示有回调附着的函数名称
* `function_profile_enabled`：打开此选项，在`trace_stat`中就会显示`function`的统计信息
* `set_ftrace_filter`：用于显示指定要跟踪的函数
* `set_ftrace_notrace`：用于指定不跟踪的函数，缺省为空
* `set_ftrace_pid`：用于指定要追踪特定进程的函数

**function graph配置：**

* `max_graph_depth`：函数嵌套的最大深度
* `set_graph_function`：设置要清晰显示调用关系的函数，在使用`function_graph`跟踪器是使用，缺省对所有函数都生成调用关系
* `set_graph_notrace`：不跟踪特定的函数嵌套调用

**Stack trace设置：**

* `stack_max_size`：当使用`stack`跟踪器时，记录产生过的最大`stack size`
* `stack_trace`：显示`stack`的`back trace`
* `stack_trace_filter`：设置`stack tracer`不检查的函数名称

## 4.3 trace-cmd

```sh
# 该命令会在当前目录下生成一个trace.dat文件
# （注意，不要在/sys/kernel/debug/tracing这个目录下使用这个命令，因为无法在这些目录中创建trace.dat文件）
trace-cmd record -e irq

# 该命令会分析当前目录下的trace.dat文件
trace-cmd report
```

## 4.4 参考

* [Linux ftrace框架介绍及运用](https://www.cnblogs.com/arnoldlu/p/7211249.html)
* [Ftrace Linux Kernel Tracing（论文）](https://events.static.linuxfound.org/slides/2010/linuxcon_japan/linuxcon_jp2010_rostedt.pdf)
* [ftrace和trace-cmd：跟踪内核函数的利器](https://blog.csdn.net/weixin_44410537/article/details/103587609)
* [使用 ftrace 跟踪内核](https://blog.csdn.net/qq_32534441/article/details/90244495)
* [【Kernel ftrace】使用kernel ftrace追踪IRQ的例子](https://www.cnblogs.com/smilingsusu/p/12705780.html)
* [使用 ftrace 来跟踪系统问题 - ftrace 介绍](https://www.jianshu.com/p/99e127973abe)

# 5 dump

## 5.1 kdump

**如何模拟内核crash？执行下面这个命令即可**

```sh
# 执行完后，会在/var/crash目录下生成dump文件，并会重启机器
echo c > /proc/sysrq-trigger
```

**下载分析crash文件所需的rpm包**

```sh
# 首先，我们需要下载带有完整调试信息的内核映像文件(编译时带-g选项)，内核调试信息包kernel-debuginfo有两个
# 1. kernel-debuginfo
# 2. kernel-debuginfo-common

wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-`uname -r`.rpm
wget http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-`uname -r`.rpm

# 安装，之后我们就可以在/lib/debug/lib/modules/`uname -r`目录下看到vmlinux内核映像文件
rpm -ivh *.rpm
ll /lib/debug/lib/modules/`uname -r`
```

**如何分析系统crash文件**

```sh
crash /lib/debug/lib/modules/`uname -r`/vmlinux /var/crash/127.0.0.1-2021-07-24-22\:59\:34/vmcore
```

* `bt`：backtrace打印内核栈回溯信息，`bt pid`打印指定进程栈信息
    * 最重要的是RIP信息，指出了发生crash的`function`以及`offset`
* `log`：打印vmcore所在的系统内核日志信息
* `dis`：反汇编出指令所在代码开始，`dis -l (function+offset)`，其中`function+offset`可以是`bt`中RIP对应的信息
    * 示例：`dis -l sysrq_handle_crash+22`
* `mod`：查看当时内核加载的所有内核模块信息
* `sym`：将地址转换为符号信息，其中地址可以是`bt`中RIP对应的信息
    * 示例：`sym ffffffff8d26d9b6`
* `ps`：打印内核崩溃时，正常的进程信息
* `files`：`files pid`打印指定进程所打开的文件信息
* `vm`：`vm pid`打印某指定进程当时虚拟内存基本信息
* `task`：查看当前进程或指定进程`task_struct`和`thread_info`的信息
* `kmem`：查看当时系统内存使用信息
* 上述命令的详细用法可以通过`help <cmd>`
* 其他命令可以通过`help`查看

## 5.2 coredump

`core dump`又叫核心转储，当程序运行过程中发生异常，程序异常退出时, 由操作系统把程序当前的内存状况存储在一个core文件中，叫`core dump`

**产生`core dump`的可能原因**

1. 内存访问越界
1. 多线程程序使用了线程不安全的函数
1. 多线程读写的数据未加锁保护
1. 非法指针
1. 使用空指针
1. 随意使用指针转换
1. 堆栈溢出
1. ...

**与`core dump`相关的配置项**

* `ulimit -c`：若是0，则不支持，可以通过`ulimit -c unlimited`或者`ulimit -c <size>`来开启
    * 或者通过编辑`/etc/security/limits.conf`文件来使配置永久生效
    * `echo "* soft core unlimited" >> /etc/security/limits.conf`
    * `echo "* hard core unlimited" >> /etc/security/limits.conf`
* `/proc/sys/kernel/core_pattern`：`core dump`的存储路径
    * 默认是`core`，若程序产生`core dump`，那么其存放路径位于当前路径
    * `echo "/data/coredump/core.%e.%p" >/proc/sys/kernel/core_pattern`：可以通过类似的语句修改存储路径，其中`%e`表示二进制名称，`%p`表示进程id
* `/proc/sys/kernel/core_pipe_limit`
* `/proc/sys/kernel/core_uses_pid`：如果这个文件的内容被配置成`1`，那么即使`core_pattern`中没有设置`%p`，最后生成的`core dump`文件名仍会加上进程id

**如何分析**

```sh
# 其中可执行程序<binary>需要通过-g参数编译而来，这样会带上debug信息，才能分析core dump文件
gdb <binary> <core dump file>
```

## 5.3 参考

* [比较 kdump makedumpfile 中的压缩方法](https://feichashao.com/compare_compression_method_of_makedumpfile/)
* [使用CRASH分析LINUX内核崩溃转储文件VMCORE](https://www.freesion.com/article/1560535243/)

# 6 内核源码浅析

## 6.1 syscall

系统调用的声明位于`include/linux/syscall.h`文件中，但是通过vs code等文本编辑工具无法跳转到定义处，这是因为系统调用的定义使用了非常多的宏

如何找到系统调用的定义：举个例子，对于系统调用`open`，它有3个参数，那么就全局搜索`SYSCALL_DEFINE3(open`；对于系统调用`openat`，它有4个参数，那么就全局搜索`SYSCALL_DEFINE4(openat`

### 6.1.1 参考

* [linux 内核源码 系统调用宏定义](https://blog.csdn.net/yueyingshaqiu01/article/details/48786961)

## 6.2 network

### 6.2.1 tcp

socket对应的`file_operations`对象为`socket_file_ops`
tcp对应的`proto_ops`对象为`inet_stream_ops`

#### 6.2.1.1 create socket

```
sys_socket | net/socket.c SYSCALL_DEFINE3(socket
sock_create | net/socket.c
__sock_create | net/socket.c
    pf->create | net/socket.c
        ⬇️  socket --> af_inet
inet_create | net/ipv4/af_inet.c
```

#### 6.2.1.2 write socket

```
# syscall
sys_write | fs/read_write.c SYSCALL_DEFINE3(write
vfs_write | fs/read_write.c
do_sync_write | fs/read_write.c
    filp->f_op->aio_write
        ⬇️  file --> socket
# socket
socket_file_ops.aio_write ==> sock_aio_write | net/socket.c
do_sock_write | net/socket.c
__sock_sendmsg | net/socket.c
__sock_sendmsg_nosec | net/socket.c
    sock->ops->sendmsg
        ⬇️  socket --> inet_stream
# inet_stream
inet_stream_ops.sendmsg ==> inet_sendmsg | net/ipv4/af_inet.c
    sk->sk_prot->sendmsg
        ⬇️  inet_stream --> tcp
# tcp
tcp_prot.sendmsg ==> tcp_sendmsg | net/ipv4/tcp.c
tcp_push | net/ipv4/tcp.c
__tcp_push_pending_frames | net/ipv4/tcp_output.c
tcp_write_xmit | net/ipv4/tcp_output.c
tcp_transmit_skb | net/ipv4/tcp_output.c
    icsk->icsk_af_ops->queue_xmit
        ⬇️  tcp -> ip
# ip
ipv4_specific.queue_xmit ==> ip_queue_xmit | net/ipv4/tcp_ipv4.c
ip_local_out | net/ipv4/ip_output.c
dst_output | include/net/dst.h
    skb_dst(skb)->output(skb) ==> ip_output | net/ipv4/ip_output.c
ip_finish_output | net/ipv4/ip_output.c
ip_finish_output2 | net/ipv4/ip_output.c
dst_neigh_output | include/net/dst.h
        ⬇️  ip -> dev(layer 2)
# link
dev_queue_xmit | net/core/dev.c
dev_hard_start_xmit | net/core/dev.c
ops->ndo_start_xmit
        ⬇️  dev --> driver
# dev driver
e1000_netdev_ops.ndo_start_xmit ==> e1000_xmit_frame | drivers/net/ethernet/intel/e1000/e1000_main.c
```

#### 6.2.1.3 read socket

**数据从网卡设备流入**

```
# link
deliver_skb | net/core/dev.c
    pt_prev->func
        ⬇️  dev --> ip
# ip
ip_packet_type.func ==> ip_rcv | net/ipv4/ip_input.c
ip_rcv_finish | net/ipv4/ip_input.c
dst_input | include/net/dst.h
    skb_dst(skb)->input ==> ip_local_deliver | net/ipv4/ip_input.c
ip_local_deliver_finish | net/ipv4/ip_input.c
    ipprot->handler
        ⬇️  ip --> tcp
# tcp
tcp_protocol.handler ==> tcp_v4_rcv | net/ipv4/tcp_ipv4.c
tcp_v4_do_rcv | net/ipv4/tcp_ipv4.c
tcp_rcv_established | net/ipv4/tcp_ipv4.c
```

**通过系统调用阻塞读取到达的数据**

```
# syscall
sys_read | fs/read_write.c SYSCALL_DEFINE3(read
vfs_read | fs/read_write.c
do_sync_read | fs/read_write.c
    filp->f_op->aio_read
        ⬇️  file --> socket
# socket
socket_file_ops.aio_read ==> sock_aio_read | net/socket.c
do_sock_read | net/socket.c
__sock_recvmsg | net/socket.c
__sock_recvmsg_nosec | net/socket.c
    sock->ops->recvmsg
        ⬇️  socket --> inet_stream
# inet_stream
inet_stream_ops.recvmsg ==> inet_recvmsg | net/ipv4/af_inet.c
    sk->sk_prot->recvmsg
        ⬇️  inet_stream --> tcp
# tcp
tcp_prot.recvmsg ==> tcp_recvmsg | net/ipv4/tcp_ipv4.c
```

### 6.2.2 ip

```
net/ipv4/ip_input.c
    ip_rcv
    NF_HOOK
    NF_HOOK_THRESH
    nf_hook_thresh
```

### 6.2.3 参考

* [Linux 网络协议栈开发（五）—— 二层桥转发蓝图（上）](https://blog.csdn.net/zqixiao_09/article/details/79057169)
* [计算机网络基础 — Linux 内核网络协议栈](https://www.cnblogs.com/jmilkfan-fanguiju/p/12789808.html)
* [TCP／IP协议栈之数据包如何穿越各层协议（绝对干货）](http://www.360doc.com/content/19/0815/00/29234429_855009606.shtml)
* [Linux内核网络栈源代码分析(专栏)](https://blog.csdn.net/geekcome/article/details/8333011)
* [linux 内核tcp接收数据的实现](https://blog.csdn.net/scdxmoe/article/details/39314679)
* [Linux tcp/ip 源码分析 - socket](https://cloud.tencent.com/developer/article/1439063)
* [linux TCP发送源码学习(1)--tcp_sendmsg](https://blog.csdn.net/scdxmoe/article/details/17764917)
* [tcp/ip协议栈--tcp数据发送流程](https://blog.csdn.net/pangyemeng/article/details/78104872)
* [最详细的Linux TCP/IP 协议栈源码分析](https://zhuanlan.zhihu.com/p/265102696?utm_source=wechat_session)
* [kernel-tcp注释](https://github.com/run/kernel-tcp)

## 6.3 file

### 6.3.1 参考

[linux文件系统四 VFS数据读取vfs_read](https://blog.csdn.net/frank_zyp/article/details/88853932)

# 7 杂项

## 7.1 哪里下载rpm包

* [rpm下载地址1](http://rpm.pbone.net/)
* [rpm下载地址2](http://www.rpmfind.net/)
* [debuginfo相关rpm下载地址](http://debuginfo.centos.org/)
* [kernel官方下载地址](https://mirrors.edge.kernel.org/pub/linux/kernel/)
