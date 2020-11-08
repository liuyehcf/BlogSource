---
title: Linux-Kernel
date: 2020-10-15 15:12:44
tags: 
- 原创
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 C相关知识储备

## 1.1 宏

1. `#`：用于把一个宏参数转变为字符串
1. `##`：用于把两个宏参数贴合在一起

# 2 如何编译内核

__准备环境：这里我安装的系统是`CentOS-7-x86_64-Minimal-1908.iso`__

__第一步：安装编译相关的软件__

```sh
yum makecache
yum -y install ncurses-devel make gcc bc openssl-devel
yum -y install elfutils-libelf-devel
yum -y install rpm-build
```

__第二步：下载内核源码并解压__

```sh
yum install -y wget
wget -O ~/linux-4.14.134.tar.gz 'http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v4.x/linux-4.14.134.tar.gz'
tar -zxvf ~/linux-4.14.134.tar.gz -C ~
```

__第三步：配置内核编译参数__

```sh
cd ~/linux-4.14.134
cp -v /boot/config-$(uname -r) .config

# 直接save然后exit即可
make menuconfig
```

__第四步：编译内核__

```sh
cd ~/linux-4.14.134
make rpm-pkg
```

__第五步：更新内核__

```sh
rpm -iUv ~/rpmbuild/RPMS/x86_64/*.rpm
```

## 2.1 参考

* [内核源码下载地址](http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/)
* [Compile Linux Kernel on CentOS7](https://linuxhint.com/compile-linux-kernel-centos7/)
* [How to Compile a Linux Kernel](https://www.linux.com/topic/desktop/how-compile-linux-kernel-0/)
* [CentOS 7上Systemtap的安装](https://www.linuxidc.com/Linux/2019-03/157818.htm)

# 3 systemtap

## 3.1 如何安装

__准备环境：这里我安装的系统是`CentOS-7-x86_64-Minimal-1810.iso`__

__第一步：安装systemtap以及其他相关依赖__

```sh
yum makecache
yum install -y systemtap systemtap-runtime systemtap-devel --enablerepo=base-debuginfo
yum install -y yum-utils
yum install -y gcc
```

__第二步：下载并安装跟当前内核版本匹配的rpm包，包括`kernel-devel-$(uname -r).rpm`、`kernel-debuginfo-$(uname -r).rpm`、`kernel-debuginfo-common-x86_64-$(uname -r).rpm`，我的内核版本是`3.10.0-957.el7.x86_64`__

```sh
wget "ftp://ftp.pbone.net/mirror/ftp.scientificlinux.org/linux/scientific/7.6/x86_64/os/Packages/kernel-devel-$(uname -r).rpm"
wget "http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-$(uname -r).rpm"
wget "http://debuginfo.centos.org/7/x86_64/kernel-debuginfo-common-x86_64-$(uname -r).rpm"

rpm -ivh kernel-devel-$(uname -r).rpm kernel-debuginfo-$(uname -r).rpm kernel-debuginfo-common-x86_64-$(uname -r).rpm
```

__第三步：验证__

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

* [SystemTap Doc](http://sourceware.org/systemtap/documentation.html)
* [centos 7 systemtap 安装](https://www.jianshu.com/p/25e84f2e5a95)

# 4 内核源码浅析

## 4.1 syscall

系统调用的声明位于`include/linux/syscall.h`文件中，但是通过vs code等文本编辑工具无法跳转到定义处，这是因为系统调用的定义使用了非常多的宏

如何找到系统调用的定义：举个例子，对于系统调用`open`，它有3个参数，那么就全局搜索`SYSCALL_DEFINE3(open`；对于系统调用`openat`，它有4个参数，那么就全局搜索`SYSCALL_DEFINE4(openat`

### 4.1.1 参考

* [linux 内核源码 系统调用宏定义](https://blog.csdn.net/yueyingshaqiu01/article/details/48786961)

## 4.2 network

### 4.2.1 tcp

socket对应的`file_operations`对象为`socket_file_ops`
tcp对应的`proto_ops`对象为`inet_stream_ops`

#### 4.2.1.1 create socket

```
sys_socket | net/socket.c SYSCALL_DEFINE3(socket
sock_create | net/socket.c
__sock_create | net/socket.c
    pf->create | net/socket.c
        ⬇️  socket --> af_inet
inet_create | net/ipv4/af_inet.c
```

#### 4.2.1.2 write socket

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

#### 4.2.1.3 read socket

__数据从网卡设备流入__

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

__通过系统调用阻塞读取到达的数据__

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

### 4.2.2 ip

```
net/ipv4/ip_input.c
    ip_rcv
    NF_HOOK
    NF_HOOK_THRESH
    nf_hook_thresh
```

### 4.2.3 参考

* [Linux 网络协议栈开发（五）—— 二层桥转发蓝图（上）](https://blog.csdn.net/zqixiao_09/article/details/79057169)
* [最详细的Linux TCP/IP 协议栈源码分析](https://zhuanlan.zhihu.com/p/265102696?utm_source=wechat_session)
* [TCP／IP协议栈之数据包如何穿越各层协议（绝对干货）](http://www.360doc.com/content/19/0815/00/29234429_855009606.shtml)
* [Linux tcp/ip 源码分析 - socket](https://cloud.tencent.com/developer/article/1439063)
* [linux TCP发送源码学习(1)--tcp_sendmsg](https://blog.csdn.net/scdxmoe/article/details/17764917)
* [tcp/ip协议栈--tcp数据发送流程](https://blog.csdn.net/pangyemeng/article/details/78104872)
* [计算机网络基础 — Linux 内核网络协议栈](https://www.cnblogs.com/jmilkfan-fanguiju/p/12789808.html)
* [Linux内核网络栈源代码分析(专栏)](https://blog.csdn.net/geekcome/article/details/8333011)
* [kernel-tcp注释](https://github.com/run/kernel-tcp)
* [linux 内核tcp接收数据的实现](https://blog.csdn.net/scdxmoe/article/details/39314679)
* [再聊 TCP backlog](https://juejin.im/post/6844904071367753736)

## 4.3 file

### 4.3.1 参考

[linux文件系统四 VFS数据读取vfs_read](https://blog.csdn.net/frank_zyp/article/details/88853932)

# 5 杂项

## 5.1 哪里下载rpm包

* [rpm下载地址1](http://rpm.pbone.net/)
* [rpm下载地址2](http://www.rpmfind.net/)
* [debuginfo相关rpm下载地址](http://debuginfo.centos.org/)
