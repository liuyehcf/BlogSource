---
title: Linux-调优
date: 2018-11-09 11:25:12
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 内核参数

`/proc/sys/net`

# 2 网络调优

## 2.1 调整socket缓存大小

```sh
sudo sysctl -w net.core.rmem_default=262144
sudo sysctl -w net.core.wmem_default=262144
sudo sysctl -p
```

## 2.2 修改连接数量限制

```sh
sudo vim /etc/security/limits.conf

# 在最后添加如下两行，若有则修改其数值
* soft nofile 1000000
* hard nofile 1000000

# reboot 重启生效
sudo reboot
```

## 2.3 修改全局文件句柄限制

```sh
sudo sysctl -w fs.file-max=1000000
sudo sysctl -p
```

## 2.4 服务端出现大量的TIMEWAIT

TIMEWAIT表示，连接已经正常断开，但是socket尚未关闭

编辑文件`/etc/sysctl.conf`，加入以下内容：

```sh
# 表示开启SYN Cookies。当出现SYN等待队列溢出时，启用cookies来处理，可防范少量SYN攻击，默认为0，表示关闭
net.ipv4.tcp_syncookies = 1

# 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭
net.ipv4.tcp_tw_reuse = 1

# 表示开启TCP连接中TIME-WAIT sockets的快速回收，默认为0，表示关闭
net.ipv4.tcp_tw_recycle = 1

# 修改系默认的 TIMEOUT 时间
net.ipv4.tcp_fin_timeout = 30
```

然后执行`/sbin/sysctl -p`让参数生效。

## 2.5 keep alive

TCP的keepAlive是平台相关的，下面仅介绍linux中的相关配置

与Tcp-keepAlive相关的内核参数有如下三个

1. `/proc/sys/net/ipv4/tcp_keepalive_time`：该参数表示，当tcp连接超过多少秒没有数据交互时，就发起keepAlive心跳包
1. `/proc/sys/net/ipv4/tcp_keepalive_intvl`：多次keepAlive心跳之间的时间间隔
1. `/proc/sys/net/ipv4/tcp_keepalive_probes`：发起多少次keepAlive心跳都没有接收到响应时，就认为连接已断开

```
tcp_keepalive_intvl (integer; default: 75; since Linux 2.4)
      The number of seconds between TCP keep-alive probes.

tcp_keepalive_probes (integer; default: 9; since Linux 2.2)
      The maximum number of TCP keep-alive probes to send before
      giving up and killing the connection if no response is
      obtained from the other end.

tcp_keepalive_time (integer; default: 7200; since Linux 2.2)
      The number of seconds a connection needs to be idle before TCP
      begins sending out keep-alive probes.  Keep-alives are sent
      only when the SO_KEEPALIVE socket option is enabled.  The
      default value is 7200 seconds (2 hours).  An idle connection
      is terminated after approximately an additional 11 minutes (9
      probes an interval of 75 seconds apart) when keep-alive is
      enabled.

      Note that underlying connection tracking mechanisms and
      application timeouts may be much shorter.
```

go语言中如何修改keepAlive配置，由于keepAlive的配置是与平台相关的，下面仅提供os=linux的配置方式

```go
package main

import (
	"github.com/liuyehcf/common-gtools/log"
	"net"
	"syscall"
	"time"
)

var logger = log.GetLogger("default")

const (
	keepAlive         = 1
	keepAliveIdle     = 30
	keepAliveInterval = 2
	keepAliveCount    = 3
)

func netDial(network, addr string) (conn net.Conn, err error) {
	dialer := &net.Dialer{
		KeepAlive: keepAliveIdle * time.Second,
	}
	logger.Info("set webSocket keepAlive={}s", keepAliveIdle)
	conn, err = dialer.Dial(network, addr)
	if err != nil {
		logger.Error("failed to dial, errorMsg={}", err.Error())
		return conn, err
	}

	if tcpConn, ok := conn.(*net.TCPConn); ok {
		// Getting the file handle of the socket
		sockFile, err := tcpConn.File()
		if err != nil {
			logger.Error("failed to open file of tcpConn, errorMsg={}", err.Error())
			return conn, err
		}

		// got socket file handle. Getting descriptor.
		defer func() {
			_ = sockFile.Close()
		}()
		fd := int(sockFile.Fd())

		// open tcp keepalive
		err = syscall.SetsockoptInt(fd, syscall.SOL_SOCKET, syscall.SO_KEEPALIVE, keepAlive)
		if err != nil {
			logger.Error("failed to set 'SO_KEEPALIVE', errorMsg={}", err.Error())
			return conn, err
		}

		// keepalive idle
		err = syscall.SetsockoptInt(fd, syscall.SOL_TCP, syscall.TCP_KEEPIDLE, keepAliveIdle)
		if err != nil {
			logger.Error("failed to set 'TCP_KEEPIDLE', errorMsg={}", err.Error())
			return conn, err
		}

		// keepalive interval
		err = syscall.SetsockoptInt(fd, syscall.SOL_TCP, syscall.TCP_KEEPINTVL, keepAliveInterval)
		if err != nil {
			logger.Error("failed to set 'TCP_KEEPINTVL', errorMsg={}", err.Error())
			return conn, err
		}

		// keepalive count
		err = syscall.SetsockoptInt(fd, syscall.SOL_TCP, syscall.TCP_KEEPCNT, keepAliveCount)
		if err != nil {
			logger.Error("failed to set 'TCP_KEEPCNT', errorMsg={}", err.Error())
			return conn, err
		}

		logger.Info("open tcp keepalive mechanism in linux, SO_KEEPALIVE={}; TCP_KEEPIDLE={}; TCP_KEEPINTVL={}; TCP_KEEPCNT={}",
			keepAlive, keepAliveIdle, keepAliveInterval, keepAliveCount)

		return conn, err
	} else {
		logger.Error("non tcpConn")
		return conn, err
	}
}
```

# 3 文件系统缓存

主机宕机前的内核日志如下：

```
...
Apr 11 03:39:40 localhost kernel: INFO: task kworker/u8:0:30794 blocked for more than 120 seconds.
Apr 11 03:39:40 localhost kernel: "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Apr 11 03:39:40 localhost kernel: kworker/u8:0    D ffff99788fa95140     0 30794      2 0x00000080
Apr 11 03:39:40 localhost kernel: Call Trace:
Apr 11 03:39:40 localhost kernel: [<ffffffffb6bc2392>] ? mapping_tagged+0x12/0x20
Apr 11 03:39:40 localhost kernel: [<ffffffffb7168c19>] schedule+0x29/0x70
Apr 11 03:39:40 localhost kernel: [<ffffffffb71666f1>] schedule_timeout+0x221/0x2d0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6adce3c>] ? select_task_rq_fair+0x63c/0x760
Apr 11 03:39:40 localhost kernel: [<ffffffffb6c1b449>] ? ___slab_alloc+0x209/0x4f0
Apr 11 03:39:40 localhost kernel: [<ffffffffb7168fcd>] wait_for_completion+0xfd/0x140
Apr 11 03:39:40 localhost kernel: [<ffffffffb6ad6e40>] ? wake_up_state+0x20/0x20
Apr 11 03:39:40 localhost kernel: [<ffffffffb6ac1b0a>] kthread_create_on_node+0xaa/0x140
Apr 11 03:39:40 localhost kernel: [<ffffffffb6abad40>] ? manage_workers.isra.25+0x2a0/0x2a0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6aba90b>] create_worker+0xeb/0x200
Apr 11 03:39:40 localhost kernel: [<ffffffffb6abab96>] manage_workers.isra.25+0xf6/0x2a0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6abb0c3>] worker_thread+0x383/0x3c0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6abad40>] ? manage_workers.isra.25+0x2a0/0x2a0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6ac1cb1>] kthread+0xd1/0xe0
Apr 11 03:39:40 localhost kernel: [<ffffffffb6ac1be0>] ? insert_kthread_work+0x40/0x40
Apr 11 03:39:40 localhost kernel: [<ffffffffb7175c37>] ret_from_fork_nospec_begin+0x21/0x21
Apr 11 03:39:40 localhost kernel: [<ffffffffb6ac1be0>] ? insert_kthread_work+0x40/0x40
...
```

> This is a know bug. By default Linux uses up to 40% of the available memory for file system caching. After this mark has been reached the file system flushes all outstanding data to disk causing all following IOs going synchronous. For flushing out this data to disk this there is a time limit of 120 seconds by default. In the case here the IO subsystem is not fast enough to flush the data withing 120 seconds. This especially happens on systems with a lof of memory.
> The problem is solved in later kernels and there is not “fix” from Oracle. I fixed this by lowering the mark for flushing the cache from 40% to 10% by setting “vm.dirty_ratio=10” in /etc/sysctl.conf. This setting does not influence overall database performance since you hopefully use Direct IO and bypass the file system cache completely.

大致含义是：原因在于，默认情况下，Linux会最多使用40%的可用内存作为文件系统缓存。当超过这个阈值后，文件系统会把将缓存中的内存全部写入磁盘， 导致后续的IO请求都是同步的。将缓存写入磁盘时，有一个默认120秒的超时时间。出现上面的问题的原因是IO子系统的处理速度不够快，不能在120秒将缓存中的数据全部写入磁盘。IO系统响应缓慢，导致越来越多的请求堆积，最终系统内存全部被占用，导致系统失去响应。这个Linux延迟写机制带来的问题，并且在主机内存越大时，出现该问题的可能性更大

与该机制相关的配置包括

1. `vm.dirty_background_ratio`：是内存可以填充「脏数据」的百分比。这些「脏数据」在稍后是会写入磁盘的，`pdflush/flush/kdmflush`这些后台进程会稍后清理「脏数据」。举一个例子，我有32G内存，那么有3.2G的内存可以待着内存里，超过3.2G的话就会有后来进程来清理它
1. `vm.dirty_background_bytes`：是内存可以填充「脏数据」的大小，默认为0，即不限制（一般通过百分比来配置）
1. `vm.dirty_ratio`：是内存可以填充「脏数据」的最大百分比，内存里的「脏数据」百分比不能超过这个值，如果超过，将强制刷写到磁盘。如果「脏数据」超过这个数量，新的IO请求将会被阻挡，直到「脏数据」被写进磁盘。这是造成IO卡顿的重要原因，但这也是保证内存中不会存在过量「脏数据」的保护机制
1. `vm.dirty_bytes`：是内存可以填充「脏数据」的最大大小，默认为0，即不限制（一般通过百分比来配置）
1. `vm.dirty_expire_centisecs`：指定「脏数据」能存活的时间。在这里它的值是30秒。当`pdflush/flush/kdmflush`进程起来时，它会检查是否有「脏数据」超过这个时限，如果有，则会把它异步地写到磁盘中。毕竟「脏数据」在内存里待太久也会有丢失风险
1. `vm.dirty_writeback_centisecs`：指定多长时间`pdflush/flush/kdmflush`这些进程会起来一次

**默认值如下**

```sh
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 30
vm.dirty_writeback_centisecs = 500
```

**我们可以从以下思路进行调优：**

1. 减少「脏数据」的比例，避免刷写超时，降低`vm.dirty_background_ratio`以及`vm.dirty_ratio`
1. 减小「脏数据」在内存中的存放时间，避免积少成多，降低`vm.dirty_expire_centisecs`

# 4 参考

* [CHANGING NETWORK KERNEL SETTINGS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/tuning_and_optimizing_red_hat_enterprise_linux_for_oracle_9i_and_10g_databases/sect-oracle_9i_and_10g_tuning_guide-adjusting_network_settings-changing_network_kernel_settings)
* [突破netty单机最大连接数](https://www.jianshu.com/p/490e2981545c)
* [TCP/IP详解--TCP连接中TIME_WAIT状态过多](https://blog.csdn.net/yusiguyuan/article/details/21445883)
* [http的keep-alive和tcp的keepalive区别](https://www.cnblogs.com/yixianyixian/p/8401679.html)
* [Notes on TCP keepalive in Go](https://thenotexpert.com/golang-tcp-keepalive/)
* [TCP keepalive的详解(解惑)](https://www.cnblogs.com/lanyangsh/p/10926806.html)
* [主机内存脏数据写入超时导致主机死机，提示：echo 0 > /proc/sys/kernel/hung_task_timeout_secs.](https://hwilu.github.io/2019/07/27/%E4%B8%BB%E6%9C%BA%E8%84%8F%E6%95%B0%E6%8D%AE%E5%AF%BC%E8%87%B4linux%E4%B8%BB%E6%9C%BA%E6%AD%BB%E6%9C%BA/)
* [Linux Kernel panic issue: How to fix hung_task_timeout_secs and blocked for more than 120 seconds problem](https://www.blackmoreops.com/2014/09/22/linux-kernel-panic-issue-fix-hung_task_timeout_secs-blocked-120-seconds-problem/)
