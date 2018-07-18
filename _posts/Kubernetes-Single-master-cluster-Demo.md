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

`Virtual Box`+`CentOS-7-x86_64-Minimal-1804.iso`

__tips__

1. 主机与`Virtual Box`之间不能共享剪切板（不知道为什么）
    * 开启sshd服务，通过ssh连接到虚拟机即可
1. 虚拟机配置的网卡是NAT，ssh连接到虚拟机非常卡
    * 

# 2 Install Kubeadm

## 2.1 关闭swap

__首先，需要关闭Swap，否则kubelet可能会不正常工作__

1. `swapon -s`：查看swap的设备
1. `swapoff <file-path>`：关闭对应的设备
1. `swapoff -a`：关闭所有swap设备

## 2.2 关闭防火墙

省点事，真的，别费劲了

`systemctl stop firewalld`

## 2.3 检查mac地址以及UUID

执行`ifconfig -a`，发现没有该命令！！！（我下载的镜像是Minimal，并且是最小安装）

于是，执行`yum install ifconfig`，发现没有网络！！！我靠！！！估计是网卡没有开启，下面启用网卡

1. `cd /etc/sysconfig/network-scripts`
1. `vi ifcfg-enp0s3`，将`ONBOOT`设置为yes
1. `systemctl restart network`：重启网卡
* 开启成功（试试看能不能ping通`www.baidu.com`，不行就重启下）

然后，安装`ifconfig`

1. `yum search ifconfig`，找到软件包名为`net-tools.x86_64`
1. `yum install net-tools.x86_64`
* 安装完毕

查看mac地址，两个命令2选1

1. `ifconfig -a`
1. `ip link`

查看主板uuid

1. `cat /sys/class/dmi/id/product_uuid`

## 2.4 检查网络适配器

当包含2个及以上的网络适配器时，Kubernetes组件在默认路由配置中是不可达的，因此需要增加路由使得Kubernetes组件可达

## 2.5 安装docker

```sh
yum install -y docker
systemctl enable docker && systemctl start docker
```

## 2.6 安装kubeadm/kubelet/kubectl

* __kubeadm__：用于启动集群
* __kubelet__：存在于集群中所有机器上，用于启动pods以及containers等
* __kubectl__：用于与集群交互

kubelet/kubectl的版本必须与kubeadm一致，否则可能会导致某些异常以及bug

```sh
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

1. `setenforce 0`：SELinux转换为宽容模式，否则可能会有权限问题

# 3 问题

## 3.1 虚拟机网络问题

1. 执行`systemctl restart network`之后，可以ping通主机，但是无法ping通`www.baidu.com`，重启虚拟机，又好了
    * 我开了两张网卡，一张NAT，一张桥接
    * 单张NAT网卡时，没有这种情况

# 4 参考

* [Kubernetes官方文档](https://kubernetes.io/docs/setup/)

