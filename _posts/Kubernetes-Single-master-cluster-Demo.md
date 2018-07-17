---
title: Kubernetes-Single-master-cluster-Demo
date: 2018-07-17 21:01:40
tags: 
- 原创
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 环境

`CentOS-7-x86_64-Minimal-1804.iso`

# 2 Install Kubeadm

## 2.1 关闭swap

__首先，需要关闭Swap，否则kubelet可能会不正常工作__

1. `swapon -s`：查看swap的设备
1. `swapoff <file-path>`：关闭对应的设备

## 2.2 检查mac地址以及UUID

执行`ifconfig -a`，发现没有该命令！！！我下载的镜像是Minimal，并且是最小安装

于是，执行`yum install ifconfig`，发现没有网络！！！我靠！！！估计是网卡没有开启，下面启用网卡

1. `cd /etc/sysconfig/network-scripts`
1. `vi ifcfg-enp0s3`，将`ONBOOT`设置为yes
1. `systemctl restart network`：重启网卡
* 开启成功

然后，安装`ifconfig`

1. `yum search ifconfig`，找到软件包名为`net-tools.x86_64`
1. `yum install net-tools.x86_64`
* 安装完毕

查看mac地址，两个命令2选1

1. `ifconfig -a`
1. `ip link`

查看主板uuid

1. `cat /sys/class/dmi/id/product_uuid`

## 2.3 检查网络适配器

当包含2个及以上的网络适配器时，Kubernetes组件在默认路由配置中是不可达的，因此需要增加路由使得Kubernetes组件可达

# 3 参考

* [Kubernetes官方文档](https://kubernetes.io/docs/setup/)
