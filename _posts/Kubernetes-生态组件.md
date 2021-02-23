---
title: Kubernetes-生态组件
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

## 3.1 参考

* [External communication with Apache Kafka deployed in Kubernetes cluster](https://argus-sec.com/external-communication-with-apache-kafka-deployed-in-kubernetes-cluster/)
* [基于Kubernetes在AWS上部署Kafka时遇到的一些问题](https://www.bbsmax.com/A/gAJGn9ZzZR/)

# 4 istio

## 4.1 参考

* [理解 Istio Service Mesh 中 Envoy 代理 Sidecar 注入及流量劫持](https://jimmysong.io/posts/envoy-sidecar-injection-in-istio-service-mesh-deep-dive/?from=groupmessage&isappinstalled=0)
