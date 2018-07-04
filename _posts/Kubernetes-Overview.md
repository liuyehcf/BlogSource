---
title: Kubernetes-Overview
date: 2018-07-03 20:07:25
tags: 
- 摘录
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 Kubernetes是什么

> Kubernetes is a portable, extensible open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation. It has a large, rapidly growing ecosystem. Kubernetes services, support, and tools are widely available.

# 2 Kubernetes组件

## 2.1 Master组件

> Master components provide the cluster’s control plane. Master components make global decisions about the cluster (for example, scheduling), and detecting and responding to cluster events (starting up a new pod when a replication controller’s ‘replicas’ field is unsatisfied).

### 2.1.1 kube-apiserver

> Component on the master that exposes the Kubernetes API.

### 2.1.2 etcd

> Consistent and highly-available key value store used as Kubernetes’ backing store for all cluster data.

### 2.1.3 kube-scheduler

> Component on the master that watches newly created pods that have no node assigned, and selects a node for them to run on.

### 2.1.4 kube-controller-manager

> Component on the master that runs controllers .
Logically, each controller  is a separate process, but to reduce complexity, they are all compiled into a single binary and run in a single process.
These controllers include:
> * Node Controller: Responsible for noticing and responding when nodes go down.
> * Replication Controller: Responsible for maintaining the correct number of pods for every replication controller object in the system.
> * Endpoints Controller: Populates the Endpoints object (that is, joins Services & Pods).
> * Service Account & Token Controllers: Create default accounts and API access tokens for new namespaces

### 2.1.5 cloud-controller-manager

## 2.2 Node组件

### 2.2.1 kubelet

> An agent that runs on each node in the cluster. It makes sure that containers are running in a pod.

### 2.2.2 kube-proxy

> kube-proxy enables the Kubernetes service abstraction by maintaining network rules on the host and performing connection forwarding.

### 2.2.3 Container Runtime

> The container runtime is the software that is responsible for running containers. Kubernetes supports several runtimes: Docker, rkt, runc and any OCI runtime-spec implementation.

## 2.3 Addons

> Addons are pods and services that implement cluster features.

### 2.3.1 DNS

> While the other addons are not strictly required, all Kubernetes clusters should have cluster DNS, as many examples rely on it.

### 2.3.2 Web UI

> Dashboard is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage and troubleshoot applications running in the cluster, as well as the cluster itself.

### 2.3.3 Container Resource Monitoring

> Container Resource Monitoring records generic time-series metrics about containers in a central database, and provides a UI for browsing that data.

### 2.3.4 Cluster-level Logging

> A Cluster-level logging mechanism is responsible for saving container logs to a central log store with search/browsing interface.

# 3 The Kubernetes API

# 4 参考

* [What is Kubernetes?](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/)
* [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)
* [The Kubernetes API](https://kubernetes.io/docs/concepts/overview/kubernetes-api/)
