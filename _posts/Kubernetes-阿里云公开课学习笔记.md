---
title: Kubernetes-阿里云公开课学习笔记
date: 2019-11-20 09:17:34
tags: 
- 摘录
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 Kubernetes 网络模型进阶

## 1.1 Service

1. 一组Pod组成一组功能后端
1. 定义一个稳定的虚IP作为访问前端，一般还附赠一个DNS域名，Client无需感知Pod的细节
1. kube-proxy是实现核心，隐藏了大量复杂性，通过apiserver监控Pod/Service的变化，反馈到LB配置中
1. LB的实现机制与目标解耦，可以是个用户态进程，也可以是一堆精心设计的Rules（iptables/ipvs）

__如何实现一个LVS版Service__

```sh
# 第一步，绑定VIP到本地（欺骗内核）
ip route add to local 192.168.166.166/32 dev lo

# 第二步，为这个虚IP创建一个IPVS的virtual server
ipvsadm -A -t 192.168.166.166:16666 -s rr -p 600

# 第三步，为这个IPVS service创建相应的real server
ipvsadm -a -t 192.168.166.166:16666 -r 127.0.0.1:22 -m
```

# 2 参考

* [k8s-阿里云公开课](https://edu.aliyun.com/course/1651?spm=5176.10731542.0.0.785020be217oeD)

