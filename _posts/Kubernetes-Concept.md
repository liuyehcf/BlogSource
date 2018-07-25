---
title: Kubernetes-Concept
date: 2018-07-25 10:07:12
tags: 
- 摘录
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 Network

## 1.1 Overview

首先，我们来明确一下，K8s面临的网络问题

1. __Highly-coupled Container-to-Container communications__：高耦合的`container`之间的网络通信，通过`pods`以及`localhost`通信来解决
1. __Pod-to-Pod communications__：本小节将详细展开说明
1. __Pod-to-Service communications__：通过`services`来解决
1. __External-to-Service communications__：通过`services`来解决

## 1.2 Docker Model

我们先来回顾一下Docker的网络模型，这对于理解K8s的网络模型是很有必要的。__在默认情况下，`Docker`利用`host-private networking`，`Docker`创建了一个虚拟网桥（virtual bridge），默认为`docker0`__。对于`Docker`创建的每个`container`都会有一个连接到网桥的虚拟以太网卡（virtual Ethernet device）`veth`，从`container`内部来看，`veth`就被映射成了`eth0`网卡

在这种网络模型下，只要位于同一个物理机上（或者同一个虚拟网桥上），所有的`container`之间可以进行通信。但是位于不同物理机上的`container`是无法进行通信的

为了让`container`可以跨`node`进行交互，必须为它们分配一个宿主物理机的`ip`。这样一来，我们就需要付出额外的精力维护`ip`以及`port`

## 1.3 Kubernetes model

`K8s`要求网络模型必须满足如下条件

1. 所有`container`之间的通信不能依赖NAT
1. 所有`node`与`container`之间的通信不能依赖NAT
1. 某个`container`在内部、外部看到的`ip`一致

这种模式不仅总体上不那么复杂，而且主要与Kubernetes希望将应用程序从VM轻松移植到容器的愿望兼容

到目前为止，都在讨论`container`，但事实上，`K8s`在`pod`范围上使用`ip`地址，因此，在一个`pod`内的所有`container`共享网络命名空间（network namespaces），当然包括ip地址。这意味着，在一个`pod`内的`container`可以通过`localhost`与其他`container`进行通信。__这称为“IP-per-pod”模式，在这种模式下，一个`pod`需要有一个`pod contaner`来管理网络命名空间，其他`app container`利用`Docker`的`--net=container:<id>`参数来加入这个网络命名空间即可__

## 1.4 Kubernetes networking model implements

__K8s的网络模型有很多种实现方式，包括但不仅限如下几种__

1. ACI
1. AOS from Apstra
1. Big Cloud Fabric from Big Switch Networks
1. Cilium
1. CNI-Genie from Huawei
1. Contiv
1. Contrail
1. Flannel
1. Google Compute Engine (GCE)
1. Kube-router
1. L2 networks and linux bridging
1. Multus (a Multi Network plugin)
1. NSX-T
1. Nuage Networks VCS (Virtualized Cloud Services)
1. OpenVSwitch
1. OVN (Open Virtual Networking)
1. Project Calico
1. Romana
1. Weave Net from Weaveworks

# 2 参考

* [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)
