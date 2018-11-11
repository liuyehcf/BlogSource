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

# 3 参考

* [CHANGING NETWORK KERNEL SETTINGS](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/tuning_and_optimizing_red_hat_enterprise_linux_for_oracle_9i_and_10g_databases/sect-oracle_9i_and_10g_tuning_guide-adjusting_network_settings-changing_network_kernel_settings)
* [突破netty单机最大连接数](https://www.jianshu.com/p/490e2981545c)
