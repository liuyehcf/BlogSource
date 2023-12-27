---
title: Kubernetes-ThirdParties
date: 2019-10-13 16:43:09
tags: 
- 摘录
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 [local-path-provisioner](https://github.com/rancher/local-path-provisioner)

# 2 [Rancher](https://github.com/rancher/rancher)

# 3 [Kafka](https://github.com/helm/charts/tree/master/incubator/kafka)

Kafka的服务露出有点问题，如果简单地把`Service`从`ClusterIP`修改为`NodePort`。那么在集群外是可以通过`NodeIp:NodePort`连接到kafka的，但是随即`kafka`会从`zookeeper`查找一个`broker`的IP（这个IP是`PodIP`）返回给集群外的Client，然后Client重新连接这个`IP`，显然在集群外的机器上是无法触达`PodIp`的，因为没有`iptables`规则

## 3.1 Reference

* [External communication with Apache Kafka deployed in Kubernetes cluster](https://argus-sec.com/external-communication-with-apache-kafka-deployed-in-kubernetes-cluster/)
* [基于Kubernetes在AWS上部署Kafka时遇到的一些问题](https://www.bbsmax.com/A/gAJGn9ZzZR/)

# 4 istio

## 4.1 Reference

* [理解 Istio Service Mesh 中 Envoy 代理 Sidecar 注入及流量劫持](https://jimmysong.io/posts/envoy-sidecar-injection-in-istio-service-mesh-deep-dive/?from=groupmessage&isappinstalled=0)

# 5 OAM

* [5分钟带你快速入门和了解 OAM Kubernetes](https://www.cnblogs.com/ants/p/13300407.html)

# 6 sealos

[sealos](https://github.com/labring/sealos)，一个超级便捷的k8s安装工具

[集群生命周期管理](https://sealos.io/en/docs/lifecycle-management/)

**Deploy:**

```sh
wget https://mirror.ghproxy.com/https://github.com/labring/sealos/releases/download/v4.2.0/sealos_4.2.0_linux_amd64.tar.gz
tar -zxvf sealos_4.2.0_linux_amd64.tar.gz sealos && chmod +x sealos && mv sealos /usr/bin

sealos run labring/kubernetes:v1.25.0-4.2.0 labring/helm:v3.8.2 labring/calico:v3.24.1 \
    --masters 172.26.95.56 \
    --nodes 172.26.95.57,172.26.95.59,172.26.95.58 -p xxxxxx
```

**Reset:**

```sh
sealos reset
```

# 7 kind

[kind](https://github.com/kubernetes-sigs/kind). kind is a tool for running local Kubernetes clusters using Docker container "nodes". kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

## 7.1 Reference

* [starrocks-kubernetes-operator](https://github.com/StarRocks/starrocks-kubernetes-operator/blob/main/doc/local_installation_how_to.md)
