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

# 3 参考

* [CHANGING NETWORK KERNEL SETTINGS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/tuning_and_optimizing_red_hat_enterprise_linux_for_oracle_9i_and_10g_databases/sect-oracle_9i_and_10g_tuning_guide-adjusting_network_settings-changing_network_kernel_settings)
* [突破netty单机最大连接数](https://www.jianshu.com/p/490e2981545c)
* [TCP/IP详解--TCP连接中TIME_WAIT状态过多](https://blog.csdn.net/yusiguyuan/article/details/21445883)