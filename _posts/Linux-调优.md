---
title: Linux-调优
date: 2018-11-09 11:25:12
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

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

# 3 参考

* [CHANGING NETWORK KERNEL SETTINGS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/tuning_and_optimizing_red_hat_enterprise_linux_for_oracle_9i_and_10g_databases/sect-oracle_9i_and_10g_tuning_guide-adjusting_network_settings-changing_network_kernel_settings)
* [突破netty单机最大连接数](https://www.jianshu.com/p/490e2981545c)
* [TCP/IP详解--TCP连接中TIME_WAIT状态过多](https://blog.csdn.net/yusiguyuan/article/details/21445883)
* [http的keep-alive和tcp的keepalive区别](https://www.cnblogs.com/yixianyixian/p/8401679.html)
* [Notes on TCP keepalive in Go](https://thenotexpert.com/golang-tcp-keepalive/)
* [TCP keepalive的详解(解惑)](https://www.cnblogs.com/lanyangsh/p/10926806.html)