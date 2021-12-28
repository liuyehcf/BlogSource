---
title: Kubernetes-Concept
date: 2018-07-25 10:07:12
tags: 
- 摘录
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 Overview

## 1.1 Kubernetes Components

[Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

### 1.1.1 Master Components

`Master Component`构成了集群的控制面板。`Master Component`是整个集群的决策者，检测并响应集群消息

`Master Component`可以运行在集群中的任意一台机器上，不要在`Master`机器上运行`User Container`

#### 1.1.1.1 kube-apiserver

`kube-apiserver`是整个控制面板的最前端，将`Master Component`通过`Kubernetes API`露出，它被设计成易于水平扩展

#### 1.1.1.2 etcd

`etcd`是高一致性、高可用的`key-value`存储，用于存储`Kubernetes`所有的集群数据

#### 1.1.1.3 kube-shceduler

`kube-shceduler`会观测新创建且尚未被分配的`Pod`，并为其选择一个`Node`来运行

#### 1.1.1.4 kube-controller-manager

`kube-controller-manager`用于在`Master`上运行`Controller`。逻辑上讲，每个`Controller`都是一个独立的进程，但是为了减小实现复杂度，这些被编译进了一个二进制中，运行在同一个进程中

`Controller`包括

1. `Node Controller`: 观测节点，并在节点退出集群时响应
1. `Replication Controller`: 为系统中每个`Replication Controller Object`保持一定数量的`Pod`
1. `Endpoints Controller`: 
1. `Service Account & Token Controller`: 为新`Namespace`创建默认的账号以及API访问的`token`

#### 1.1.1.5 cloud-controller-manager

### 1.1.2 Node

`Node component`运行在每个`Node`之上，保持`Pod`的运行，并提供`Kubernetes`运行环境

#### 1.1.2.1 kubelet

`kubelet`是运行在集群的每个`Node`上的代理。它确保`Container`在`Pod`中正常运行

`kubelet`采用通过各种机制提供的`PodSpecs`来确保`Container`以期望的方式健康运行

`kubelet`不会管理不由`Kubernetes`创建的`Container`

#### 1.1.2.2 kube-proxy

`kube-proxy`通过维护网络规则并转发网络数据包，来支持`Kubernetes Service`的抽象机制

#### 1.1.2.3 Container Runtime

`Kubernetes`支持多种运行时

1. `Docker`
1. `rkt`
1. `runc`

### 1.1.3 Addons

???

### 1.1.4 参考

* [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

## 1.2 Kubernetes Object

`Kubernetes Object`作为持久化的实体，存在于`Kubernetes`系统中，`Kubernetes`用这些实体来表示集群的状态，具体来说

1. 运行着什么容器化的应用程序
1. 可以使用的资源清单
1. 应用程序的策略，包括重启策略、更新、容错等

一个`Kubernetes Object`用于记录我们的意图，一旦我们创建了一个`Kubernetes Object`，那么`Kubernetes`系统就会努力保证对象的存活，并朝着我们预期的状态推进。换言之，创建一个`Kubernetes Object`，意味着告诉`Kubernetes`系统，我们期望它以何种方式运行

我们必须通过`Kubernetes API`来使用`Kubernetes Object`，包括创建、修改、删除等。我们也可以使用`kubectl`命令行工具，本质上，`kubectl`为我们封装了一个或多个`Kubernetes API`的调用。

每个`Kubernetes Object`都至少包含两个`object field`，即`spec`以及`status`

* `spec`：描述了`Kubernetes Object`的期望状态
* `status`：描述了`Kubernetes Object`的实际状态，这个状态由`Kubernetes system`更新

当我们需要创建一个`Kubernetes Object`时，我们需要提供`spec`来描述这个`Kubernetes Object`的期望状态，同时，还需要提供一些基本的信息来描述这个`Kubernetes Object`，例如`name`等。当我们利用`Kubernetes API`来创建`object`时，`API request`中的`request body`必须包含这些信息。通常我们将这些信息记录在`.ymal`文件中，并将文件作为参数传递给`Kubernetes API`

**注意，一个`.yaml`文件中，必须包含如下字段**

1. `apiVersion`：指定`Kubernetes API`的版本
1. `kind`：指定待创建`object`的类型
1. `metadata`：`object`的元数据，包括
    * `name`
    * `UID`
    * `namespace`

### 1.2.1 Name

所有的`Kubernetes Object`都用一个`Name`和一个`UID`精确确定

#### 1.2.1.1 Nmaes

`Names`是一种用户提供的字符串，表示了一个资源的路径，例如`/api/v1/pods/some-name`

在同一时刻，可以为同一种类型的`Kubernetes Object`分配一个名字。当然，如果我们删除了这个`Kubernetes Object`，我们还可以创建一个同名的`Kubernetes Object`

通常，`Name`最大不超过253个字符，只允许包含小写的字母以及`-`和`.`，具体的类型可能还有更加严格的限制

#### 1.2.1.2 UIDs

`UID`是`Kubernetes`系统创建的用于唯一标志`Kubernetes Object`的字符串。每个`Kubernetes Object`在整个生命周期中都会有一个唯一的`UID`，将`Kubernetes Object`先删除再重新创建，会得到一个新的`UID`

### 1.2.2 Namespaces

`Kubernetes`支持同一个物理集群支持多个虚拟集群，这些虚拟集群被称为`Namespaces`。如果一个`Kubernetes`集群仅有数十个用户，那么我们完全不必考虑使用`Namespaces`

#### 1.2.2.1 When to use Multiple Namespaces

`Namespaces`用于为使用同一集群的多个不同的小组、项目提供一定程度的隔离

在同一个`Namespaces`中的资源的名称必须唯一，但是在不同`Namespaces`中的资源名称可以重复

如果仅仅为了隔离资源，例如同一个软件的不同版本，可以使用`Label`而不需要使用`Namespaces`

#### 1.2.2.2 Working with Namespaces

可以通过如下命令查看系统中的`Namespaces`

```sh
kubectl get namespaces
```

`Kubernetes`默认包含三个`Namespaces`

1. `default`: 在未指定`Namespace`时，`Kubernetes Object`默认属于这个`Namespace`
1. `kube-system`: 由`Kubernetes`系统创建的`Kubernetes Object`所属的`Namespace`
1. `kube-public`: 该`Namespace`对所有的用户可见，通常用于共享一些资源

在使用`kubectl`时，我们可以加上`--namespace`来暂时指定`Namespace`

我们可以为`kubectl`设定`Namespace`上下文，后续所有的命令都默认指定该`Namespace`

```sh
kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
# Validate it
kubectl config view | grep namespace:
```

#### 1.2.2.3 Namespaces and DNS（未完成）

当我们创建一个`Service`，它会创建一个相关的`DNS entry`，其格式为`<service-name>.<namespace-name>.svc.cluster.local`

#### 1.2.2.4 Not All Objects are in a Namespace

大部分`Kubernetes`资源位于一个`Namespace`中。某些底层次的资源，例如`Node`以及`PersistentVolume`不属于任何`Namespace`

以下命令用于查看哪些资源位于/不位于`Namespace`中

```sh
# In a namespace
kubectl api-resources --namespaced=true

# Not in a namespace
kubectl api-resources --namespaced=false
```

### 1.2.3 Labels and Selectors

`Labels`是一些依附在`Kubernetes Object`上的键值对。`Lebels`用于为一些对用户有特殊意义的`Kubernetes Object`打标，这些标在`Kubernetes`内核中并无其他含义。`Label`用于组织和选择`Kubernetes Object`。我们可以再任何时刻为`Kubernetes Object`打上`Label`。对于一个`Kubernetes Object`来说，`key`必须是唯一的

#### 1.2.3.1 Motivation

`Lebal`允许用户以一种松耦合的方式将组织结构与`Kubernetes Object`关联起来，用户不必自己存储这些映射关系

服务部署以及一些批处理流水线通常是一个多维度的实体，通常需要交叉式的管理，这会破坏层次结构的严格封装，通常这些封装是由基础设施而非用户完成的

#### 1.2.3.2 Label selectors

与`Name`与`UID`不同，`Label`并不需要保证唯一性。而且，在通常情况下，我们期望多个`Kubernetes Object`共享同一个`Label`

通过`Label Selector`，用户/客户端就可以识别出这些`Kubernetes Object`，因此`Label Selector`是`Kubernetes`管理这些对象的核心

目前，`Kubernetes`支持两种类型的`Selector`：`equality-based`和`set-based`。`Label Selector`由多个`requirement`组成，以逗号分隔，多个`requirement`之间的关系是逻辑与`&&`。**这两种类型可以混用**

`Equality-based requirement`允许通过`Label key`以及`Label value`进行过滤，允许的比较操作包括：`=`、`==`、`!=`，其中`=`与`==`都表示相等型比较

```
environment = production
tier != frontend
environment = production, tier != frontend
```

* 第一个规则表示：匹配`key`等于`environment`且`value`等于`production`的所有`Kubernetes Object`
* 第二个规则表示：匹配`key`等于`tier`且`value`不等于`frontend`的所有`Kubernetes Object`
* 第三个规则表示：前两个规则的逻辑与关系

`Set-based requirement`允许根据一组集合来进行过滤，允许的操作包括：`in`、`notin`、`exists`。`Set-based requirement`表达能力要大于`Equality-based requirement`，即`Equality-based requirement`可以用`Set-based requirement`的方式表示出来

```
environment in (production, qa)
tier notin (frontend, backend)
partition
!partition
```

* 第一个规则表示：匹配`key`等于`environment`且`value`等于`production`或`qa`的所有`Kubernetes Object`
* 第二个规则表示：匹配`key`等于`tier`且`value`不等于`frontend`且`value`不等于`backend`的所有`Kubernetes Object`
* 第三个规则表示：匹配含有`partition`这个`key`的所有`Kubernetes Object`
* 第四个规则表示：匹配不含有`partition`这个`key`的所有`Kubernetes Object`

**selector配置格式**

```yml
selector:
  matchLabels:
    component: redis
  matchExpressions:
    - {key: tier, operator: In, values: [cache]}
    - {key: environment, operator: NotIn, values: [dev]}
```

* `matchLabels`是一个`key-value`的map
* `matchExpressions`是一系列的`selector requirement`
* **所有的条件会以逻辑与的方式组合（包括`matchLabels`和`matchExpressions`）**

#### 1.2.3.3 API

```sh
kubectl get pods -l environment=production,tier=frontend
kubectl get pods -l 'environment in (production),tier in (frontend)'
kubectl get pods -l 'environment in (production, qa)'
kubectl get pods -l 'environment,environment notin (frontend)'
```

### 1.2.4 Annotations

我们可以通过`Label`以及`Annotation`为`Kubernetes Object`添加一些元数据。`Label`通常被用于`Kubernetes Object`的匹配，而`Annotation`通常用于为`Kubernetes Object`添加一些配置，这些配置可以包含一些`Label`不允许的字符

### 1.2.5 Field Selectors

`Field Selector`允许我们基于`Kubernetes Object`的字段匹配来过滤`Kubernetes Object`，支持的匹配操作包括：`=`、`==`、`!=`，其中`=`与`==`都表示相等型比较

```sh
kubectl get pods --field-selector status.phase=Running
kubectl get statefulsets,services --field-selector metadata.namespace!=default
```

### 1.2.6 Recommended Labels

### 1.2.7 参考

* [Understanding Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
* [Imperative Management of Kubernetes Objects Using Configuration Files](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/)

# 2 Architecture

## 2.1 Node

`Node`是`Kubernetes`中的一个工作者。`Node`可能是一个虚拟机或者物理机。每个`Node`被`Master Component`管理，包含了一些运行`Pod`所必须的服务，包括`Container runtime`、`kubelet`、`kube-proxy`

### 2.1.1 Node Status

`Node`的状态包括以下几部分

1. `Address`
1. `Condition`
1. `Capacity`
1. `Info`

#### 2.1.1.1 Addresses

`Address`包含的字段与服务提供方或者裸机配置有关

1. `HostName`: `hostname`由`Node`的内核上报。可以通过`kubelet`参数`--hostname-override`覆盖
1. `ExternalIP`: 公网IP
1. `InternalIP`: 集群内的IP

#### 2.1.1.2 Condition

`conditions`字段描述了`Node`的状态，包括

1. `OutOfDisk`: 如果剩余空间已经无法容纳新的`Pod`时，为`Frue`；否则`False`
1. `Ready`: 如果`Node`可以接收新的`Pod`时，为`True`；如果`Node`无法接纳新的`Pod`时，为`False`；如果`Controller`与该`Node`断连一定时间后（由`node-monitor-grace-period`字段指定，默认40s），为`Unknown`
1. `MemoryPressure`: 存在内存压力时，为`Ture`；否则`False`
1. `PIDPressure`: 存在进程压力时，为`True`；否则`False`
1. `DiskPressure`: 存在磁盘压力时，为`True`；否则`False`
1. `NetworkUnavailable`: 网络异常时，为`True`；否则`False`

#### 2.1.1.3 Capacity

描述了可用资源的数量，包括CPU、内存、最大可运行的`Pod`数量

#### 2.1.1.4 Info

描述了节点的通用信息，包括内核版本，`Kubernetes`版本，`Docker`版本，`OS`名称等等

### 2.1.2 Management

与`Pod`与`Service`不同，`Pod`与`Service`是由`Kubernetes`负责创建的，而`Node`是由云服务商或者使用者提供的。当`Kubernetes`创建了一个`Node`仅仅意味着创建了一个`Kubernetes Object`来描述这个`Node`

目前，存在三个与`Node`交互的组件，他们分别是：`Node Controller`、`kubelet`、`kubectl`

#### 2.1.2.1 Node Controller

`Node Controller`是`Kubernetes master component`，用于管理`Node`的生命周期

1. 当`Node`注册时，为`Node`分配一个`CIDR block`
1. 保持`Node`列表与云服务提供方的可用机器列表一致，当`Node`变得`unhealthy`后，`Node Controller`会询问云服务提供商该`VM`是否仍然可用，若不可用，则会将其从`Node`列表中删除
1. 监视`Node`的健康状况，`Node Controller`会在`Node`变得`unreachable`后将状态从`NodeReady`变为`ConditionUnknown`，然后以优雅的方式移除该`Node`上的所有`Pod`

在`Kubernetes 1.4`版本中，对集群中大批`Node`同时出故障这一情况的处理做了一些优化，`Controller`会观测集群中所有`Node`的状态，来决策`Pod`以何种方式、何种规模进行移除

在大多数情况下，`Node Controller`限制了移除率`--node-eviction-rate`（默认是0.1），意味着，10秒之内最多只有一个`Node`节点上的`Pod`会被移除

当一个可用区（`Zone`）中的某个`Node`发生故障时，`Node`移除的行为发生了改变。`Node Controller`会检测在当前可用区中发生故障的`Node`的占比，如果这个比例最少为`--unhealthy-zone-threshold`（默认0.55）时，移除率会降低。如果集群很小（节点数量小于），移除过程会直接停止

将`Node`分布于不同的可用区的原因是，当一个可用区变得完全不可用时，那这些`Pod`可以迁移到其他的可用区中

### 2.1.3 Node capacity

`Node`容量是`Node Object`的一部分。通常`Node`在向`Master`注册时，需要上报容量信息。如果我们是手动创建和管理`Node`，那么就需要手动设置容量信息

`Kubernetes Scheduler`会保证`Node`上的资源一定大于所有`Pod`占用的资源。注意到，它仅仅会计算通过`kubelet`创建的`Container`所占用的资源数量，而不会计算由`Container runtime`或者手动创建的`Containter`所占用的资源数量

## 2.2 Master-Node communication

### 2.2.1 Cluster to Master

`Node`与`Master`之间的通信全部依靠`Api Server`，除此之外，其他`Master component`不会提供远程服务。在一个典型的部署场景中，`Api Server`会在`443`端口上监听

应该为`Node`配置公共根证书，以便它们可以安全地连接到`Api Server`

`Pod`可以借助`Service Account`来与`Api Server`进行安全通信，`Kubernetes`会在`Pod`实例化的时候，将根证书以及令牌注入到`Pod`中去

`Kubernetes`会为每个`Server`分配一个虚拟IP，`kube-proxy`会将其重定向为`Api Server`的具体IP

因此，`Node`与`Api Server`之间的通信可以在可靠/不可靠的网络下进行

### 2.2.2 Master to Cluster

`Master(Api server)`与`Node`的通信的方式有两种：其一，`Api Server`通过与每个`Node`上的`kubelet`来完成通信；其二，`Api Server`通过`Proxy`来完成与`Node`、`Pod`、`Server`的通信

#### 2.2.2.1 Api server to kubelet

`Api Server`与`kubelet`之间的通信主要用于以下几个用途

1. 获取`Pod`的日志
1. 与运行时的`Pod`进行交互
1. 为`kubelet`提供端口转发服务（`port-forwarding functionality`）

默认情况下，`Api Server`不会校验`kubelet`的服务端证书，因此有可能受到中间人攻击（`man-in-the-middle`），因此在不可信的网络中或者公网上是不安全的。我们可以通过`--kubelet-certificate-authority`来为`Api Server`提供一个根证书，用来校验`kubelet`的证书合法性

#### 2.2.2.2 Api server to nodes, pods, and services

`Api Server`与`Node`、`Pod`、`Service`之间的通信默认用的是HTTP协议，显然这是不安全的。我们可以为`Node`、`Pod`、`Service`的`API URL`指定`https`前缀，来使用HTTPS协议。但是，`Api Server`仍然不会校验证书的合法性，也不会为客户端提供任何凭证，因此在不可信的网络中或者公网上是不安全的

## 2.3 Concepts Underlying the Cloud Controller Manager

最初提出`Cloud Controller Manager(CCM)`概念是为了能够让云服务商与`Kubernetes`可以相互独立地发展

`CCM`是的设计理念是插件化的，这样云服务商就可以以插件的方式与`Kubernetes`进行集成

### 2.3.1 Design

如果没有`CCM`，`Kubernetes`的架构如下：

![ccm_1](/images/Kubernetes-Concept/ccm_1.png)

在上面的架构图中，`Kubernetes`与`Cloud Provider`通过几个不同的组件进行集成

1. `kubelet`
1. `Kubernetes Controller Manager(KCM)`
1. `Kubernetes API server`

在引入`CCM`后，整个`Kubernetes`的架构变为：

![ccm_2](/images/Kubernetes-Concept/ccm_2.png)

### 2.3.2 Components of the CCM

`CCM`打破了`KCM`的一些功能，并且作为一个独立的进程运行。具体来说，`CCM`打破了`KCM`那些依赖于云的`Controller`

`KCM`具有如下`Controller`：

1. `Node Controller`
1. `Volume Controller`
1. `Route Controller`
1. `Service Controller`

`CCM`包含如下`Controller`

1. `Node Controller`
1. `Route Controller`
1. `Service Controller`
1. `PersistentVolumeLabels Controller`

### 2.3.3 Functions of the CCM

#### 2.3.3.1 Kubernetes Controller Manager

`CCM`中大部分的功能都是从`KCM`中继承过来的，包括如下`Controller`

1. `Node Controller`
1. `Route Controller`
1. `Service Controller`
1. `PersistentVolumeLabels Controller`

##### 2.3.3.1.1 Node Controller

`Node Controller`负责初始化`Node`，它会从`Cloud Provier`中获取有关`Node`的一些信息，具体包括

1. 初始化`Node`时，为其打上`zone/region`的标签
1. 初始化`Node`时，记录一些定制化的信息，包括`type`和`size`
1. 获取`Node`的`hostname`和`address`
1. 当`Node`失联时，询问`Cloud Provider`该`Node`是否已被其删除，如果已被删除，那么删除该`Node`对应的`Kubernetes Node Object`

##### 2.3.3.1.2 Route Controller

`Route Controller`负责配置路由信息，以便位于不同`Node`节点上的`Container`能够进行相互通信，目前只与`Google Compute Engine Cluster`兼容

##### 2.3.3.1.3 Service Controller

`Service Controller`负责监听`Service`的创建、更新、删除对应的事件，确保负载均衡可以时时感知服务的状态

##### 2.3.3.1.4 PersistentVolumeLabels Controller

`PersistentVolumeLabels Controller`在`AWS EBS/GCE PD Volume`创建时，为其打上标签。这些标签对于`Pod`的调度至关重要，因为这些`Volume`只在特定的区域，因此被调度的`Pod`也必须位于这些区域才行

`PersistentVolumeLabels Controller`仅用于`CCM`中

#### 2.3.3.2 Kubelet

`Node controller`包含了`kubelet`中依赖于云的功能。在引入`CCM`之前，`kubelet`在初始化`Node`时，还需要负责初始化`IP`地址、区域标签以及实例类型等信息。引入`CCM`后，这些初始化操作将从`kubelet`中被移除，完全由`CCM`负责初始化

在新模式下，`kubelet`可以单纯地创建一个`Node`，而不用关心与云相关的一些依赖信息。在`CCM`完成初始化之前，该`Node`是无法被调度的

#### 2.3.3.3 Kubernetes API server

同样地，`PersistentVolumeLabels`也将`Api Server`中与云相关的部分迁移到`CCM`中

### 2.3.4 Plugin mechanism

`CCM`定义了一系列的接口（`Go`接口），交由云服务商自行提供实现

### 2.3.5 Authorization

#### 2.3.5.1 Node Controller

`Node Controller`只与`Node Object`进行交互，可以进行如下操作

1. `Get`
1. `List`
1. `Create`
1. `Update`
1. `Patch`
1. `Watch`
1. `Delete`

#### 2.3.5.2 Route Controller

`Route Controller`监听`Node Object`的创建以及配置路由规则，可以进行如下操作

1. `Get`

#### 2.3.5.3 Service Controller

`Service Controller`监听`Service Object`的创建、更新、删除，以及配置`endpoint`，可以进行如下操作

1. `List`
1. `Get`
1. `Watch`
1. `Patch`
1. `Update`

#### 2.3.5.4 PersistentVolumeLabels Controller

`PersistentVolumeLabels Controller`监听`PersistentVolume (PV)`的创建，可以进行如下操作

1. `Get`
1. `List`
1. `Watch`
1. `Update`

## 2.4 参考

* [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)

# 3 Workloads

## 3.1 Pods

### 3.1.1 Pod Overview

#### 3.1.1.1 Understanding Pods

`Pod`是Kubernetes中，用户能够创建或部署的最小单元，一个`Pod`代表了一个进程（可能是高耦合的一组进程）。`Pod`封装了以下资源

1. `Container`：一个或多个应用容器
1. `volume`：存储资源
1. `IP`：一个pod会被分配一个IP，在所属的namespace下唯一
1. `options`：控制容器运行的参数

通常，`Pod`在`Kubernetes`集群中有两种主要用法

1. `Pods that run a single container`: 该模式是`Kubernetes`最常用的模式。在这种情况下，我们可以认为`Pod`对`Container`做了一层封装，`Kubernetes`直接管理`Pod`而不是`Container`
1. `Pods that run multiple containers that need to work together`: 在这种模式下，`Pod`封装了由一组高耦合的`Container`构成的应用，这些`Container`需要共享资源

每一个`Pod`都运行着一个应用的一个实例。如果我们想要水平扩展，我们必须使用多个`Pod`，同样，每个`Pod`运行一个实例。在`Kubernetes`中，这称为`replication`。通常，`Replicated Pod`由`Controller`统一创建和管理

`Pod`为`Container`提供了两种共享资源的方式

1. `networking`: 每个`Pod`被分配了一个唯一的`IP`地址，每个`Container`共享网络的`Namespace`，包括`IP`地址以及端口号。位于同一个`Pod`中的`Container`可以通过`localhost`来进行通信。位于不同`Pod`中的`Container`需要借助`host`以及`port`来通信
1. `storage`: `Pod`可以分享一些存储卷。位于同一个`Pod`中的所有`Container`共享这些卷

#### 3.1.1.2 Working with Pods

在`Kubernetes`中，我们很少直接创建独立的`Pod`，**因为`Pod`被设计成一种相对短暂的、一次性的实体**。当`Pod`被创建后（被用户直接创建，或者被`Controller`创建），它就会被调度到某个节点上开始运行。`Pod`会一直在`Node`上运行，直至被终结、`Pod Object`被删除、`Node`宕机

`Pod`自身并不会自我恢复。也就是说，当`Pod`部署失败或者挂了，这个`Pod`的生命周期就结束了。**Kubernetes用一个高层次的概念，即`Controller`，来管理`Pod`的生命周期，包括`Pod`的创建、部署、副本、恢复等工作**

`Controller`可以为我们创建和管理多个`Pod`，水平扩容、提供自我修复能力。例如，当一个`Node`宕机后，`Controller`会自动地在另一个`Node`上重新启动一个新的`Pod`

#### 3.1.1.3 Pod Templates

**`Pod Template`是`Pod`的一份声明（如下），可以被其他`Kubernetes Object`（包括`Replication Controllers`、`Job`等）引用**

```yml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo Hello Kubernetes! && sleep 3600']
```

`Pod Template`更像一个饼干模具，而不是指定所有副本的当前期望状态。当一个饼干制作完成后，它与饼干模具毫无关系。`Pod Template`杜绝了量子纠缠，更新或者替换`Pod Template`对于已经生产的`Pod`不会产生任何影响

### 3.1.2 Pods

#### 3.1.2.1 What is a Pod?

`Pod`包含一个或者一组`Container`，一些共享的存储/网络组件，以及运行应用的方式。`Pod`中的共享上下文包括：`Linux namespaces`，`cgroups`，以及其他可能的隔离因素

在一个`Pod`中的所有`Container`共享一个`IP`地址，以及端口空间，`Container`之间可以通过`localhost`进行通信，或者其他`IPC`方式。不同`Pod`中的`Container`具有不同的`IP`地址，因此，仅能通过`Pod IP`进行通信

在同一个`Pod`中的`Container`可以访问共享卷，共享卷是`Pod`的一部分，并且可以挂载到文件系统上

`Pod`被设计成一种短暂的、一次性的实体。`Pod`在创建时会被赋予一个唯一的`UID`，并且被调度到某个`Node`上一直运行直至被销毁。如果一个`Node`宕机了，那些被调度到该`Node`上的`Pod`会被删除。一个特定的`Pod`（`UID`层面）不会被重新调度到新的`Node`上，相反，它会被一个新的`Pod`替代，这个新`Pod`可以复用之前的名字，但是会被分配一个新的`UID`，因此那么些共享的卷也会重新创建（旧数据无法保留）

#### 3.1.2.2 Motivation for pods

通常一个服务由多个功能单元构成，各模块相互协作，而`Pod`就是这种多协作过程的模型。`Pod`通过提供一个高阶抽象来简化应用的部署、管理。`Pod`是部署，水平扩展和复制的最小单元

`Pod`允许内部的组件共享数据以及相互通信。在一个`Pod`中的所有组件共享同一个网络`Namespace`(`IP`和`port`)，他们之间可以通过`localhost`相互通信，因此在一个`Pod`中的所有组件需要共享`port`，同时，`Pod`也允许其组件与外部通信

`Pod`的`hostname`被设置为`Pod`的名字

#### 3.1.2.3 Durability of pods (or lack thereof)

`Pod`并不是一个高可用的实体。`Pod`不会从调度失败、节点宕机或其他错误中恢复

通常情况下，用户不需要直接创建`Pod`，而应该使用`Controller`，`Controller`提供了一个集群层面上的自我修复能力，以及水平扩容能力和删除能力

`Pod`对外直接露出，其原因如下

1. 提供可插拔式的调度和控制方式
1. 支持`Pod-level`的操作，而不需要通过`Controller API`来代理
1. 解耦`Pod`生命周期与`Controller`生命周期
1. 解耦`Controller`和`Service`
1. 解耦`Kubelet-level`的功能与`cluster-level`的功能
1. 高可用性

#### 3.1.2.4 Termination of Pods

由于`Pod`代表了集群中一组运行的进程，因此允许`Pod`优雅地终结是很有必要的。用户需要发出删除指令，需要了解终结时间，需要确保`Pod`真的被终结了。当用户发出删除`Pod`的请求时，系统会记录一个宽限期（发出删除请求到被强制清除的时间间隔），然后向`Pod`中的所有`Container`发出`TERM signal`，如果超过宽限期，`Pod`还未终结，那么会向`Pod`中的所有`Container`发出`KILL signal`，当`Pod`终结后，它会被`API server`删除

一个具体的例子

1. 用户发出指令删除`Pod`，默认的宽限期是30s
1. `API server`会更新该`Pod`的状态，并且设定宽限期
1. 当用户通过命令查看`Pod`状态时，该被删除的`Pod`会显示`Terminating`状态
1. `Kubelet`观测到`Pod`被标记为`Terminating`状态，以及宽限期后，就开始终结流程
    1. 如果有`Container`定义了`preStop hook`，那么会运行该钩子方法。如果超过宽限期后，`preStop hook`方法还在执行，那么步骤2将会被执行，并且会指定一个更小的宽限期（2s）
    1. 向`Container`发送`TERM`信号
1. `Pod`被移除服务节点列表。因此，那些终止过程十分缓慢的`Pod`，在此时也不会继续提供服务
1. `Kubelet`通过`API server`将宽限期设置为`0`来结束删除过程。之后该`Pod`就对用户彻底不可见了，即彻底被删除了

`Kubernetes`允许强制删除`Pod`，强制删除意味着将该`Pod`从集群状态以及`etcd`中立即删除。当强制删除执行时，`Api Server`不会等待`kubelet`确认删除`Pod`，而是直接将该`Pod`删除，这样一来，一个新的复用了原来名字的`Pod`就可以被立即创建。而那个被删除的`Pod`仍然会给定一个比较小的宽限期来进行上述删除操作。**尽量不要使用这种方式**

### 3.1.3 Pod Lifecycle

#### 3.1.3.1 Pod phase

`Pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`phase`字段

`phase`是对`Pod`生命周期中的状态的高度抽象，仅包含以下几个值

1. **`Pending`**：该`Pod`已被`Kubernetes system`接管，但是`Container`尚未创建完毕。可能处于尚未被调度的状态，或者正在下载容器镜像
1. **`Running`**：所有`Container`已经启动完毕，并且至少有一个`Container`处于运行状态，或者处于启动或者重启的过程中
1. **`Succeeded`**：所有`Container`成功终止，且不会重启
1. **`Failed`**：至少有一个`Container`终止失败
1. **`Unkown`**：系统错误

可以通过如下命令查看`phase`

```sh
kubectl get pod -n <namespace> <pod-name> -o yaml
```

#### 3.1.3.2 Pod conditions

`Pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`conditions`字段，该字段对应的值是一个`PodConditions`对象的数组

每个`PodConditions`对象包含如下字段

1. **`lastProbeTime`**：上一次进行状态监测的时刻
1. **`lastTransitionTime`**：上一次发生状态变更的时刻
1. **`message`**：状态变更的描述，一个`human-readable`的描述
1. **`reason`**：状态变更的原因，一个较为精确的描述
1. **`status`**：`True`、`False`、`Unknown`中的一个
1. **`type`**：以下几种可能值中的一个
    * `PodScheduled`：`Pod`已被调度到一个`node`上
    * `Ready`：`Pod`已经能够提供服务，应该被添加到`load balancing pool`中去 
    * `Initialized`：所有的`Init Container`已经执行完毕
    * `Unschedulable`：调度失败，可能原因是资源不足
    * `ContainersReady`：`Pod`中的所有`Container`已经就绪

#### 3.1.3.3 Container probes

`probe`是`kubelet`对`Container`定期进行的诊断。为了实现诊断，`kubelet`通过调用一个`handler`来完成，该`handler`由容器实现，以下是三种`handler`的类型

1. `ExecAction`：在容器中执行一个命令，当命令执行成功（返回状态码是0）时，诊断成功
1. `TCPSocketAction`：通过`Container`的`IP`以及指定的`port`来进行`TCP`检测，当检测到`port`开启时，诊断成功
1. `HTTPGetAction`：通过`Container`的`IP`以及指定的`port`来进行`HTTP Get`检测，当`HTTP`返回码在200至400之间时，诊断成功

**诊断结果如下**

1. **`Success`**
1. **`Failure`**
1. **`Unknown`**

**`kubelet`可以对运行状态下的`Container`进行如下两种`probe`**

1. **`livenessProbe`**：检测`Container`是否存活（健康检查），若不存活，将杀死这个`Container`
1. **`readinessProbe`**：检测`Container`是否准备好提供服务，若检查不通过，那么会将这个`Pod`从`service`的`endpoint`列表中移除

**我们如何决定该使用`livenessProbe`还是`readinessProbe`**

* 如果我们的`Container`在碰到异常情况时本身就会宕机，那么我们就不需要`livenessProbe`，`kubelet`会自动根据`restartPolicy`采取相应的动作
* 如果我们想要在`probe`失败时杀死或者重启`Container`，那么，我们需要使用`livenessProbe`，同时将`restartPolicy`指定为`Always`或`OnFailure`模式
* 如果我们想要在`Pod`可读时才向其转发网络数据包，那么，我们需要使用`readinessProbe`
* 如果我们的`Container`需要读取大量数据，配置文件或者需要在启动时做数据迁移，那么需要`readinessProbe`
* 如果我们仅仅想要避免流量打到被删除的`Pod`上来，我们无需使用`readinessProbe`。在删除过程中，`Pod`会自动将自己标记为`unready`状态，无论`readinessProbe`是否存在

#### 3.1.3.4 Pod readiness gate

为了织入一些回调逻辑或者信号到`PodStatsu`中来增强`Pod readiness`的可扩展性，`Kubernetes`在`1.11`版本之后引入了一个性特性，称为`Pod ready++`，我们可以在`PodSpec`中使用`ReadinessGate`来增加一些额外的用于判断`Pod readiness`的条件。如果`Kubernetes`在`status.conditions`中没有找到对应于`ReadinessGate`中声明的条件类型，那么检测结果默认是`Flase`

```yml
Kind: Pod
...
spec:
  readinessGates:
    - conditionType: "www.example.com/feature-1"
status:
  conditions:
    - type: Ready  # this is a builtin PodCondition
      status: "True"
      lastProbeTime: null
      lastTransitionTime: 2018-01-01T00:00:00Z
    - type: "www.example.com/feature-1"   # an extra PodCondition
      status: "False"
      lastProbeTime: null
      lastTransitionTime: 2018-01-01T00:00:00Z
  containerStatuses:
    - containerID: docker://abcd...
      ready: true
...
```

#### 3.1.3.5 Restart policy

`PodSpec`有一个`restartPolicy`字段，其可选值为`Always`、`OnFailure`、`Never`。默认值为`Always`。`restartPolicy`对`Pod`中的所有`Container`都会生效。`restartPolicy`仅针对在同一个`Node`中重启`Container`。多次启动之间的时间间隔以指数方式增长（10s、20s、40s...），最多不超过5分钟。在成功重启后10分钟后，时间间隔会恢复默认值

#### 3.1.3.6 Pod lifetime

通常情况下，`Pod`一旦创建就会永远存在，直至被某人或`Controller`销毁。唯一例外就是，当`Pod`的`status.phase`字段为`Succeeded`或`Failed`且超过一段时间后（该时间由`terminated-pod-gc-threshold`设定），该`Pod`会被自动销毁

有三种类型的`Controller`可供选择

1. 使用`Job`，这类`Pod`预期会终止，例如`batch computations`。此时`restartPolicy`通常设置为`OnFailure`或`Never`
1. 使用`ReplicationController`、`ReplicaSet`、`Deployment`，这类`Pod`预期会一直运行，例如`web servers`。此时`restartPolicy`通常设置为`Always`
1. 使用`DaemonSet`，这类`Pod`通常每台机器都会运行一个

这三种类型的`Controller`都含有一个`PodTemplate`。通常，创建一个`Controller`，然后利用它来创建`Pod`是最常规的选择，而不是自己创建`Pod`，因为`Pod`自身是不具有错误恢复能力的，但是`Controller`具备该能力

当某个`Node`宕机或者失联后，`Kubernetes`会将位于这些`Node`上的`Pod`全部标记为`Failed`

### 3.1.4 Init Containers

#### 3.1.4.1 Understanding Init Containers

一个`Pod`中可以运行一个或多个`Container`，同时，一个`Pod`中也可以运行一个或多个`Init Container`（`Init Container`会优先于`Container`运行）

`Init Container`具有如下特性

1. 他们总会结束运行，即并不是一个常驻进程
1. `Init Container`总是一个接一个地运行，上一个`Init Container`运行结束后，下一个`Init Container`才开始运行

如果`Init Container`执行失败，`Kubernetes`会重启`Pod`直至`Init Container`成功执行（至于`Pod`是否重启依赖于`restartPolicy`）

为了将一个`Container`指定为`Init Container`，我们需要在`PodSpec`中添加`initContainers`字段

`Init Container`支持所有普通`Container`的字段，唯独不支持`readiness probe`，因为`Init Container`在`ready`之前已经结束了

#### 3.1.4.2 Detailed behavior

在`Pod`的启动过程中，在网络以及磁盘初始化后，`Init Container`以配置的顺序启动。`Init Container`会一个接一个地启动，且只有前一个启动成功后，后一个才会启动。如果`Init Container`启动失败，会根据`restartPolicy`来决定是否重新启动。特别地，如果`Pod`的`restartPolicy`被设置为`Always`，那么对于`Init Container`而言，就为`OnFailure`

如果`Pod`重启（可能仅仅指重新启动container？并不是销毁`Pod`后再创建一个新的`Pod`），那么所有的`Init Container`都会重新执行

### 3.1.5 Pod Preset

`Pod Preset`用于在`Pod`创建时注入一些运行时的依赖项，我们可以使用`Label Selector`来指定需要注入的`Pod`

**原理**：Kubernetes提供了一个准入控制器（`PodPreset`）。在创建`Pod`时，系统会执行以下操作：

1. 获取所有的`PodPreset`
1. 检查正在创建的`Pod`的`Label`是否匹配某个或某些`PodPreset`的`Label Selector`
1. 将匹配的`PodPreset`所指定的资源注入到待创建的`Pod`中去
1. 如果发生错误，抛出一个事件，该事件记录了错误信息，然后以纯净的方式创建`Pod`（无视所有`PodPreset`中的资源）
1. 修改`Pod`的`status`字段，记录其被`PodPreset`修改过。描述信息如下
    * `podpreset.admission.kubernetes.io/podpreset-<pod-preset name>: "<resource version>".`

一个`Pod Preset`可以应用于多个`Pod`，同样，一个`Pod`也可以关联多个`Pod Preset`

### 3.1.6 Disruptions

#### 3.1.6.1 Voluntary and Involuntary Disruptions

`Pod`会一直存在，直到某人或者`Controller`摧毁它，或者碰到一个无法避免的硬件或者系统问题。我们将这些异常称为`involutary disruption`，包括

1. 硬件错误
1. 集群管理员误删VM实例
1. 内核错误
1. 网络抖动
1. 由于资源耗尽而导致`Pod`被移出`Node`

对于其他的情况，我们称之为`voluntary disruption`，包括

1. 删除管理`Pod`的`Node`
1. 更新了`PodSpec`而导致的`Pod`重启
1. 删除`Pod`
1. 将`Node`从集群中移出，对其进行维护或升级
1. 将`Node`从集群中移出，进行缩容

#### 3.1.6.2 Dealing with Disruptions

下列方法可以减轻`involuntary disruption`造成的影响

1. 确保`Pod`只拿它需要的资源
1. 复制应用，以获得高可用性
1. 将应用副本分别部署到不同的区域的节点上，以获得更高的可用性

#### 3.1.6.3 How Disruption Budgets Work

应用`Owner`可以为每个应用创建一个`PodDisruptionBudget(PDB)`对象。`PDB`限制了应用同时缩容的最大数量，即保证应用在任何时候都有一定数量的`Pod`在运行

当集群管理员利用`kubectl drains`命令将某个`Node`移除时，`Kubernetes`会尝试移除该`Node`上的所有`Pod`，但是这个移除请求可能会被拒绝，然后`Kubernetes`会周期性的重试，直至所有`Pod`都被终结或者超过配置的时间（超过后，直接发送`KILL signal`）

`PDB`无法阻止`involuntary disruptions`。`Pod`由于灰度升级造成的`voluntary disruption`可以被`PDB`管控。但是`Controller`灰度升级不会被`PDB`管控

### 3.1.7 参考

* [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
* [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
* [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
* [Pod Preset](https://kubernetes.io/docs/concepts/workloads/pods/podpreset/)
* [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

## 3.2 Controller

### 3.2.1 ReplicaSet

`ReplicaSet`是新一代的`Replication Controller`，`ReplicaSet`与`Replication Controller`之间的唯一区别就是`select`的方式不同。`ReplicaSet`支持`set-based selector`，而`Replication Controller`仅支持`equality-based selector`

#### 3.2.1.1 How to use a ReplicaSet

大部分支持`Replication Controller`的`kubectl`命令都支持`ReplicaSet`，其中一个例外就是`rolling-update`命令。如果我们想要进行灰度升级，更推荐使用`Deploymenet`

尽管`ReplicaSet`可以独立使用，但到目前为止，它主要的用途就是为`Deployment`提供一种机制---编排`Pod`创建、删除、更新

#### 3.2.1.2 When to use a ReplicaSet

`ReplicaSet`保证了在任何时候，都运行着指定数量的`Pod`副本。然而，`Deployment`是一个更高阶的概念，它管理着`ReplicaSet`、提供声明式的`Pod`升级方式，以及一些其他的特性。因此，推荐使用`Deployment`而不是直接使用`ReplicaSet`，除非我们要使用自定义的升级策略或者根本不需要升级

#### 3.2.1.3 Writing a ReplicaSet manifest

**示例**

```yml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  # modify replicas according to your case
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
          # If your cluster config does not include a dns service, then to
          # instead access environment variables to find service host
          # info, comment out the 'value: dns' line above, and uncomment the
          # line below.
          # value: env
        ports:
        - containerPort: 80
```

与其他`Kubernetes Object`相同，`ReplicaSet`同样需要`apiVersion`、`kind`、`metadata`三个字段。除此之外，还需要以下字段

1. `.spec.template`: 该字段是`.spec`字段的唯一要求的字段，`.spec.template`描述了一个`Pod Template`，其格式与`Pod`几乎完全一致，除了不需要`apiVersion`、`kind`这两个字段
1. `.spec.selector`: `ReplicaSet`会管理所有匹配该`Selector`的`Pod`。注意到`ReplicaSet`并不会区分由它创建或删除的`Pod`与其他人或过程创建或删除的`Pod`，因此，我们可以替换掉`ReplicaSet`，而不会影响到正在执行的`Pod`，它们仍然会被这个新的`ReplicaSet`所管理。此外，`.spec.template.metadata.labels`必须与`.spec.selector`匹配，否则会被`API`拒绝
1. `.metadata.labels`: `ReplicaSet`还允许拥有自己的`Label`，通常来说，`.spec.template.metadata.labels`与`.metadata.labels`是一致的。同样，它们也可以不一致，**但要注意的是，`.metadata.labels`与`.spec.selector`无关**
1. `.spec.replicas`: 该字段指定了`Pod`副本的数量，默认为1

#### 3.2.1.4 Working with ReplicaSets

##### 3.2.1.4.1 Deleting a ReplicaSet and its Pods

如果我们要删除`ReplicaSet`以及所有相关的`Pod`，我们只需要使用`kubectl delete`来删除`ReplicaSet`。`Garbage Controller`默认会自动删除所有相关的`Pod`

##### 3.2.1.4.2 Deleting just a ReplicaSet

如果我们仅仅要删除`ReplicaSet`，那么需要在`kubectl delete`命令加上`--cascade=false`参数

一旦`ReplicaSet`被删除后，我们就可以创建一个新的`ReplicaSet`，如果新的`ReplicaSet`名字与原来的相同，那么它将会接管之前由原来的`ReplicaSet`创建的`Pod`。尽管如此，它不会要求已存在的`Pod`来满足新的`Pod Template`。如果要更新`Pod`使其匹配新的`Spec`，那么需要使用`Rolling Update`

##### 3.2.1.4.3 Isolating Pods from a ReplicaSet

我们可以通过改变`Pod`的`Label`来将其与`ReplicaSet`分离（通常用于分离那些用于`Debug`、`Data recovery`的`Pod`），通过这种方式移除`Pod`后，新的`Pod`随之会被创建出来

##### 3.2.1.4.4 Scaling a ReplicaSet

我们可以简单的修改`ReplicaSet`的`.spec.replicas`字段来进行扩容或缩容。`ReplicaSet Controller`会保证`Pod`的数量与`ReplicaSet`保持一致

##### 3.2.1.4.5 ReplicaSet as a Horizontal Pod Autoscaler Target

`ReplicaSet`也可以是`Horizontal Pod Autoscalers（HPA）`的目标。也就是说，`HPA`可以自动缩放`ReplicaSet`

```yml
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: frontend-scaler
spec:
  scaleTargetRef:
    kind: ReplicaSet
    name: frontend
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

#### 3.2.1.5 Alternatives to ReplicaSet

##### 3.2.1.5.1 Deployment(recommended)

`Deployment`是一个`Kubernetes Object`，它可以包含`ReplicaSet`，并且可以更新`ReplicaSet`以及相关的`Pod`。尽管`ReplicaSet`可以独立使用，但是通常`ReplicaSet`都作为`Deployment`的一种机制来组织`Pod`的创建、删除和更新。当我们使用`Deployment`时，`ReplicaSet`的创建完全由`Deployment`来管控

##### 3.2.1.5.2 Bare Pods

与直接创建`Pod`不同，`ReplicaSet`会在`Pod`删除或者不可用时创建新的`Pod`来替换原有的`Pod`，例如`Node`宕机，或者进行破坏性的维护，例如内核升级。即便我们的应用只需要一个`Pod`，也应该使用`ReplicaSet`而不是直接管理`Pod`

##### 3.2.1.5.3 Job

对于预期会终止的`Pod`而言，推荐使用`Job`而不是`ReplicaSet`

##### 3.2.1.5.4 DaemonSet

`DaemonSet`可以提供机器级别的功能，例如机器监控，机器日志等。这些`Pod`有着与机器强相关的生命周期，且优先于其他普通`Pod`运行。当机器重启或者关机时，可以安全地终止这些`Pod`

##### 3.2.1.5.5 ReplicationController

`ReplicaSet`可以看做是新一代的`ReplicationController`，他们有着相同的使命，且行为相同。此外，`ReplicationController`不支持`set-based Selector`

### 3.2.2 ReplicationController

`ReplicationController`确保：在任何时候，应用都运行着一定数量的副本

#### 3.2.2.1 How a ReplicationController Works

如果`Pod`过多，`ReplicationController`会停止多余的`Pod`。如果`Pod`过少，`ReplicationController`会启动更多的`Pod`。与人工创建的`Pod`不同，如果`Pod`终结了，或者被删除了，那么`ReplicationController`重新启动一个新的`Pod`来代替它

在`Kubernetes`中，我们用缩写`rc`或`rcs`来表示`ReplicationController`

#### 3.2.2.2 Writing a ReplicationController Spec

```yml
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      name: nginx
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

与其他`Kubernetes Config`类似，`ReplicationController`包含`apiVersion`、`kind`、`metadata`以及`spec`这四个字段

1. `.spec.template`: 该字段是`.spec`字段的唯一要求的字段。该字段描述的是一个`Pod Template`，它拥有与`Pod`几乎完全一样的`schema`（没有`apiVersion`与`kind`）。除此之外，必须制定`Label`以及`Restart Policy`（默认是`Always`）
1. `.metadata.labels`: 通常该字段的值与`.spec.template.metadata.labels`一致。如果`.metadata.labels`未设置，那么其值默认与`.spec.template.metadata.labels`相同。尽管如此，这两个字段的值可以不同，但是`.metadata.labels`不影响`ReplicationController`的行为
1. `.spec.selector`: 该字段定义了一个`Label Selector`，`ReplicationController`会管理所有与该`Label Selector`匹配的`Pod`（无论该`Pod`是否由`ReplicationController`创建，**因此要特别注意重叠问题**），这就允许在`Pod`运行时替换`ReplicationController`。如果指定了该字段，那么`.spec.template.metadata.labels`与`.spec.selector`的值必须相同，否则会被`Api Server`拒绝，若`.spec.selector`未指定，那么默认与`.spec.template.metadata.labels`相同
1. `.spec.replicas`: 指定同时运行的副本数量，默认为1

#### 3.2.2.3 Working with ReplicationControllers

##### 3.2.2.3.1 Deleting a ReplicationController and its Pods

若要删除一个`ReplicationController`以及相关联的`Pod`，那么使用`kubectl delete`命令，`kubectl`会负责删除所有相关的`Pod`

##### 3.2.2.3.2 Deleting just a ReplicationController

若仅仅要删除`ReplicationController`，那么在使用`kubectl delete`命令时，需要加上`--cascade=false`选项。当`ReplicationController`被删除后，我们便可以创建一个新的`ReplicationController`，若新旧`ReplicationController`的`.spec.selector`也相同的话，那么新的`ReplicationController`会接管先前的`Pod`，且不会产生影响（即便`Pod Template`不同）。若要更新`Pod`使其匹配新的`Pod Template`，那么需要使用`Rolling Update`

##### 3.2.2.3.3 Isolating pods from a ReplicationController

我们可以通过改变`Pod`的`Label`来将其与`ReplicationController`分离，这种方式通常用于分离那些用于`Debug`或`Data Recovery`的`Pod`，移除后，`ReplicationController`会重新补足`Pod`

#### 3.2.2.4 Common usage patterns

##### 3.2.2.4.1 Rescheduling

`ReplicationController`会保证运行一定数量的副本

##### 3.2.2.4.2 Scaling

我们可以通过修改`replicas`字段来进行扩容和缩容

##### 3.2.2.4.3 Rolling updates

`ReplicationController`旨在通过逐个替换`Pod`来对`Service`进行滚动更新

建议的方法是创建一个具有1个副本的新`ReplicationController`，逐个扩展新的（+1）和旧的（-1）`ReplicationController`，然后在旧的`ReplicationController`达到0个副本后删除它

`ReplicationController`需要考虑到应用的准备情况，且保证在任意时刻都运行着一定数量的副本。因此这两个`ReplicationController`创建的`Pod`的`Label`需要有区分度，例如`image tage`的差异

我们可以通过`kubectl rolling-update`命令来进行滚动更新

##### 3.2.2.4.4 Multiple release tracks

在进行滚动升级时，可能同时运行着多个不同的版本，且通常会持续一段时间，我们要对这多个不同版本进行追踪，追踪将依据`Label`来进行区分

举例来说，最初一个`Service`中的所有`Pod`（10个），其`Label`都是`tier in (frontend), environment in (prod)`。此时，我们需要引入一个新的版本`canary`。我们可以创建一个`ReplicationController`，将其副本数量设定为9，且`Label`为`tier=frontend, environment=prod, track=stable`；另一个`ReplicationController`，将其副本数量设定为1，`Label`为`tier=frontend, environment=prod, track=canary`。于是该`Service`包含了`canary`以及`non-canary`两部分

##### 3.2.2.4.5 Using ReplicationControllers with Services

同一个`Service`可以有多个不同的`ReplicationController`，这样一来，流量可以根据版本进行分流

`ReplicationController`不会自我终结，但是它的生命周期与`Service`不同。一个`Service`包含了由不同`ReplicationController`创建的`Pod`，且在一个`Service`的生命中期中可能会有很多`ReplicationController`被创建和销毁，这些对于`Client`来说是不感知的

#### 3.2.2.5 Writing programs for Replication

由`ReplicationController`创建的`Pod`是可替换的，且在语义上是等价的，尽管随着时间的推移，它们会产生一些差异性。显然，这种特性非常适用于无状态的微服务架构。但是`ReplicationController`同样可以保持有状态服务架构的高可用性，例如`master-elected`、`shared`、`worker-pool`架构的应用。这些应用需要使用动态的分配机制，而不是静态的一次性的配置。这些动态分配的动作应该由另一个控制器来完成（该控制器是应用的一部分）而不是由`ReplicationController`来完成

#### 3.2.2.6 Responsibilities of the ReplicationController

`ReplicationController`仅确保`Pod`保持额定的数量。在未来，可能会在`Replacement Policy`上增加更多的控制，同时引入可供外部用户使用的事件，用来处理更为复杂的`Replacement`

`ReplicationController`的责任仅限于此，`ReplicationController`自身并不会引入`Readiness Probe`或`Liveness Probe`。它通过外部缩放控制器来修改`replicas`字段，而不是提供自动缩放的机制。`ReplicationController`不会引入`Scheduling Policy`

#### 3.2.2.7 API Object

`ReplicationController`是一个顶层的`Kubernetes Rest API`

#### 3.2.2.8 Alternatives to ReplicationController

##### 3.2.2.8.1 ReplicaSet

`ReplicaSet`可以看做是下一代的`ReplicationController`。`ReplicaSet`支持`set-based Label Selector`。`ReplicaSet`作为`Deployment`的一种机制来组织`Pod`的创建、删除和更新。我们强烈推荐使用`Deployement`而不是直接使用`ReplicaSet`

##### 3.2.2.8.2 Deployment(Recommended)

`Deployment`是一种高阶的`API Object`，用于以一种非常简单的方式更新`ReplicaSet`以及`Pod`。`Deployment`具有`Rolling Update`的能力，且它是声明式的，服务级别的，且拥有额外的功能

##### 3.2.2.8.3 Bare Pods

与直接创建`Pod`不同，`ReplicationController`会在`Pod`删除或者不可用时创建新的`Pod`来替换原有的`Pod`，例如`Node`宕机，或者进行破坏性的维护，例如内核升级。即便我们的应用只需要一个`Pod`，也应该使用`ReplicationController`而不是直接管理`Pod`

##### 3.2.2.8.4 Job

对于预期会终止的`Pod`而言，推荐使用`Job`而不是`ReplicationController`

##### 3.2.2.8.5 DaemonSet

`DaemonSet`可以提供机器级别的功能，例如机器监控，机器日志等。这些`Pod`有着与机器强相关的生命周期，且优先于其他普通`Pod`运行。当机器重启或者关机时，可以安全地终止这些`Pod`

### 3.2.3 Deployments

`Deployment`提供了一种声明式的更新`Pod`或`ReplicaSet`的方式

#### 3.2.3.1 Creating a Deployment

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

* 通过`.metadata.name`字段来指定`Deployment`的名字
* 通过`.spec.replicas`字段来指定副本数量
* 通过`.sepc.selector`字段来指定匹配何种标签的`Pod`
* 通过`.spec.template`字段来描述一个`Pod Template`

```sh
# create deployment
kubectl create -f <filepath or url>

# get deployment
kubectl get deployments

# get replicaSet
kubectl get rs

# get pods
kubectl get pods --show-labels
```

#### 3.2.3.2 Updating a Deployment

`Deployment`会保证同时只有一小部分的`Pod`处于升级的过程中（可能会暂时无法提供服务），最多25%

`Deployment`会保证同时只有一小部分的`Pod`处于创建过程中，最多25%

`Deployment`不建议更新`Label Selector`，这意味着，我们最初就需要定义好`Label Selector`。但`Deployment`仍允许我们更新`Label Selector`

* 增加`Label Selector`，那么`Deployment`要求`Pod Template`的`Label`必须匹配`Label Selector`。这个操作是非重叠的，意味着所有旧有的`ReplicaSet`以及`Pod`将会被孤立，新的`ReplicaSet`以及`Pod`会被创建出来
* 修改`Label Selector`，会导致增加`Label Selector`相同的结果
* 删除`Label Selector`中的`key`，不需要修改`Pod Template`的`Label`。现有的`ReplicaSet`不会被孤立，新的`ReplicaSet`不会被创建

#### 3.2.3.3 Rolling Back a Deployment

有时候，我们会想要进行回滚，比如新版本不够稳定，或者出现了很严重的错误。`Deployment`允许我们回滚到任意一次版本

注意到，只有在`Deployment rollout`触发时，才会创建`revision`，这意味着，当且仅当`Pod Template`发生变化时（例如修改`Label`或者镜像），才会创建`revision`。其他的更新，例如进行缩容或者扩容，不会创建`revision`。这意味着回滚到一个早期的版本，回滚的仅仅是`Pod Template`

```sh
# check the revisions of this deployment
kubectl rollout history deployment.v1.apps/nginx-deployment

# see details of specific revision
kubectl rollout history deployment.v1.apps/nginx-deployment --revision=2

# undo the current rollout
kubectl rollout undo deployment.v1.apps/nginx-deployment

# rollback to previous revision
kubectl rollout undo deployment.v1.apps/nginx-deployment --to-revision=2
```

#### 3.2.3.4 Scaling a Deployment

```sh
# scale a deployment
kubectl scale deployment.v1.apps/nginx-deployment --replicas=10

# autoscale
kubectl autoscale deployment.v1.apps/nginx-deployment --min=10 --max=15 --cpu-percent=80
```

#### 3.2.3.5 Pausing and Resuming a Deployment

我们可以暂停一个`Deployment`，然后进行一些更新操作，再还原该`Deployment`

```sh
# pause deployment
kubectl rollout pause deployment.v1.apps/nginx-deployment

# update image
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1

# update resource
kubectl set resources deployment.v1.apps/nginx-deployment -c=nginx --limits=cpu=200m,memory=512Mi

# resume deployment
kubectl rollout resume deployment.v1.apps/nginx-deployment
```

#### 3.2.3.6 Deployment Status

`Deployment`在生命周期中会经历多个不同的状态

1. `progressing`
1. `complete`
1. `failed`

**progressing**

1. 正在创建`ReplicaSet`
1. 正在扩容
1. 正在缩容

**complete**

1. 所有副本都更新到期望的版本了
1. 所有副本都可用了
1. 没有正在运行的旧版本的副本

**failed**

1. 配额不足
1. `Readiness Probe`失败了
1. 拉取镜像失败
1. 权限不足
1. 应用配置有问题

#### 3.2.3.7 Clean up Policy

我们可以通过设置`.spec.revisionHistoryLimit`来控制`Deployment`保留多少个历史版本，默认是10，超过该数值的`ReplicaSet`会被回收

#### 3.2.3.8 Writing a Deployment Spec

与其他`Kubernetes Config`类似，`Deploymenet`必须包含`apiVersion`、`kind`、`metadata`、`spec`四个字段

**Pod Template**

* `.spec.template`: `.spec`的唯一必须的字段，它描述了一个`Pod Template`，`Pod Tempalte`的schema与`Pod`几乎完全一致（不需要`apiVersion`和`kind`）
* `Pod Template`必须指定`Label`以及`Restart Policy`，其中`.spec.template.spec.restartPolicy`只允许设置成`Always`，默认就是`Always`

**Replicas**

* `.spec.replicas`: 指定副本数量，默认1

**Selector**

* `.spec.selector`: 定义了一个`Label Selector`
* `.spec.selector`与`.spec.template.metadata.labels`必须匹配，否则会被拒绝

**Strategy**

* `.spec.strategy`: 定义了新老`Pod`更替的策略，可选项有`Recreate`、`RollingUpdate`，默认是`RollingUpdate`
* `Recreate`在更新时，旧的`Pod`全部被终结后，新的`Pod`才会创建
* `RollingUpdate`: 灰度更新，仅允许一小部分的`Pod`进行更替，始终保持服务的可用状态

#### 3.2.3.9 Alternative to Deployments

使用`kubectl rolling update`来滚动升级`Pod`和`ReplicationController`与`Deployment`是类似的。但是`Deployment`是更推荐的方式，因为它是声明式的，服务级别的，未来可能会有新的功能

### 3.2.4 StatefulSets

与`Deployment`相同，`StagefulSet`管理基于相同容器规范的`Pod`。与`Deployment`不同，`StagefulSet`为每个`Pod`都生成一个唯一且不可变的标志符，这些标志符全局唯一

#### 3.2.4.1 Using StatefulSets

`StagefulSet`有如下特点

1. 稳定，唯一的网络标志
1. 稳定的持久化存储
1. 有序且优雅的部署以及扩缩容
1. 有序自动的滚动更新

#### 3.2.4.2 Limitations

#### 3.2.4.3 Components

#### 3.2.4.4 Pod Selector

#### 3.2.4.5 Pod Indentity

#### 3.2.4.6 Deployment and Scaling Guarantees

#### 3.2.4.7 Update Strategies

### 3.2.5 DaemonSet

### 3.2.6 Garbage Collection

### 3.2.7 TTL Controller for Finished Resources

### 3.2.8 Jobs - Run to Completion

### 3.2.9 CronJob

# 4 Services, Load Balancing and Networking

## 4.1 Services

`Pod`是无法再生的。`ReplicaSet`可以动态地创建或删除`Pod`，每个`Pod`都会分配一个`IP`，显然随着`Pod`的新老更替，这些`IP`是不固定的。这就导致了一个问题，如果一个`Pod`提供了某种服务给其他位于同一集群中的`Pod`，那么这些`Pod`如何找到服务提供方呢

`Service`的引入解决了这个问题，**`Service`是一组`Pod`以及他们访问方式的抽象**。`Service`通过`Label Selector`来匹配对应的`Pod`。`Service`解耦了`Consumer`和`Provider`（从这个角度来说，`Service`与RPC框架解决了类似的问题）

### 4.1.1 Defining a service

与`Pod`类似，`Service`也是一个`Rest Object`，可以通过`Api Server`来创建实例，例如

```yml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

通过上面这份配置，会创建一个名为`my-service`，该`Service`会将`80`端口的流量路由到任意包含标签`app=MyApp`的`Pod`的`9376`端口

每个`Service`都会被分配一个`Cluster IP`，`Service Proxy`会用到这个`Cluster IP`，`Service`的`Label Selector`匹配会持续进行，其结果过会同步到同名的`Endpoint`，**`Endpoint`维护了`Service`与`Pod`的映射关系**

`Service`可以将一个入口端口映射成任意`targetPort`，`targetPort`默认与`port`相同，此外`targetPort`还可以是一个字符串，指代端口的名称，不同的`Pod`包含的端口名与端口的映射关系可以不同，这提供了非常多的灵活性

`Service`支持`TCP`、`UDP`、`SCTP`协议，默认是`TCP`协议

#### 4.1.1.1 Services without selectors

`Service`通常抽象了访问`Pod`的方式，但是它也可以抽象其他后端实体的访问方式，例如

1. 在生产环境以及测试环境中使用的`database`是不同的
1. 我们想将`Service`暴露给另一个`Namespace`或者另一个集群
1. 应用的多分实例中，一部分部署在`Kubernetes`集群中，另一部分部署在`Kubernetes`集群外

在以上这些情况中，我们可以定义一个没有`Label Selector`的`Service`，如下

```yml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
```

由于这个`Service`没有配置`Label Selector`，因此不会有`Endpoint`对象生成。但是，我们可以手动配置`Endpoint`，如下

```yml
kind: Endpoints
apiVersion: v1
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 1.2.3.4
    ports:
      - port: 9376
```

在无`Label Selector`的场景下，`Service`的工作方式还是一样的。流量会被路由到`Endpoint`中

`ExternalName Service`是无`Label Selector`的，且使用的是`DNS`

### 4.1.2 Virtual IPs and service proxies

每个`Node`都运行着`kube-proxy`这个组件。`kube-proxy`为除了`ExternalName`类型之外的`Service`提供了一种虚拟IP

#### 4.1.2.1 Proxy-mode: userspace

1. **该模式最主要的特征是：流量重定向工作是由`kube-proxy`完成的，也就是在用户空间完成的**
1. `kube-proxy`会监听`Service`的创建和删除，当发现新的`Service`创建出来后，`kube-proxy`会在`localhost`网络开启一个随机端口（记为`loPort`）进行监听，同时向`iptable`写入路由规则（`Cluster IP:Port`->`localhost:loPort`），即将流向`Service`的流量转发到本地监听的端口上来
1. `kube-proxy`会监听`Endpoint`的变更，并将`Service`及其对应的`Pod`列表保存起来

![proxy-mode-userspace](/images/Kubernetes-Concept/proxy-mode-userspace.svg)

在`Pod`中访问`Service`的时序图如下

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}
participant Pod
participant localDNS
participant iptable
participant kube_proxy
participant remotePod

Pod->localDNS: 查询serviceName对应的Cluster IP
localDNS-->Pod: return
Pod->iptable: traffic to Cluster IP
iptable->iptable: 规则匹配
iptable->kube_proxy: traffic to kube_proxy
kube_proxy->kube_proxy: 查询代理端口号和Service的映射关系，以及Service和Endpoint的映射关系
kube_proxy->remotePod: traffic to remotePod
```

#### 4.1.2.2 Proxy-mode: iptables

1. **该模式最主要的特征是：流量重定向的工作是由`iptable`完成的，也就是在内核空间完成的**
1. `kube-proxy`会监听`Service`、`Endpoint`的变化，并且更新`iptable`的路由表
1. 更高效、安全，但是灵活性较差（当某个`Pod`没有应答时，不会尝试其他`Pod`）

![proxy-mode-iptables](/images/Kubernetes-Concept/proxy-mode-iptables.svg)

在`Pod`中访问`Service`的时序图如下

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}
participant Pod
participant localDNS
participant iptable
participant remotePod

Pod->localDNS: 查询serviceName对应的Cluster IP
localDNS-->Pod: return
Pod->iptable: traffic to Cluster IP
iptable->iptable: 规则匹配
iptable->remotePod: traffic to remotePod
```

#### 4.1.2.3 Proxy-mode: ipvs

与`iptable`模式类似，`ipvs`也是利用`netfilter`的`hook function`来实现的，但是`ipvs`利用的是哈希表，且工作在内核空间，因此效率非常高，同时`ipvs`还支持多种负载均衡算法

1. `rr`: round-rogin
1. `lc`: least connection
1. `dh`: destination hashing
1. `sh`: source hashing
1. `sed`: shortest expected delay
1. `nq`: never queue

![proxy-mode-ipvs](/images/Kubernetes-Concept/proxy-mode-ipvs.svg)

在以上任何一种模式中，来自`Cluster IP:Port`的流量都会被重定向到其中一个后端`Pod`中，且用户不感知这些过程

### 4.1.3 Multi-Port Services

很多`Service`需要暴露多个端口。`Kubernetes`支持一个`Service`暴露多个端口，在这种方式下，我们必须为每个端口定义一个端口名（端口名只允许包含数字、小写字母以及`-`，且必须以数字或小写字母开头和记为）

```yml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 9376
  - name: https
    protocol: TCP
    port: 443
    targetPort: 9377
```

### 4.1.4 Choosing your own IP address

我们可以通过`.spec.clusterIP`字段为`Service`分配静态的`Cluster IP`。该`IP`必须是一个合法的`Cluster IP`，否则会被`Api Server`拒绝（返回`422`错误码）

### 4.1.5 Discovering services

`Kubernetes`提供了两种服务发现的方式

1. `Environment Variables`
1. `DNS`

#### 4.1.5.1 Environment Variables

`kubelet`会为每个`Service`设置一系列的环境变量，格式为`<SERVICE_NAME>_<VARIABLE_NAME>`，服务名和变量名都会被转成大写+下划线的方式

这种方式会引入顺序的问题，如果`Pod`想要访问一个`Service`，那么这个`Service`必须优先于`Pod`创建

#### 4.1.5.2 DNS

`DNS Server`会监听`Service`的创建，并为其创建`DNS Record`，如此一来，`Pod`就可以通过服务名来访问服务了

举个例子，如果我们有一个`Service`，起名字为`my-service`，其对应的`Namesapce`为`my-ns`，那么`DNS Server`会为这个`Service`创建一个`my-service.my-ns`的记录。所有在`my-ns`下的`Pod`可以通过服务名来访问，即`my-service`；对于在其他`Namespace`下的`Pod`必须通过`my-service.my-ns`来访问

### 4.1.6 Headless services

有时候，我们不需要负载均衡，也不需要`Service IP`，我们可以通过`.spec.clusterIP = None`来进行配置。这种方式允许开发者与`Kubernetes`的服务发现机制解耦，允许开发者使用其他的服务发现机制

在这种模式下，`Service`不会被分配`Cluster IP`，`kube-proxy`也不会处理这些`Service`

如果该模式的`Service`包含`Selector`，`Endpoint Controller`会创建`Endpoint`来记录这个`Service`，并且会修改`DNS`记录（`ServiceName`->`Backend Pod IP`）

如果该模式的`Service`不包含`Selector`，那么`Endpoint Controller`不会为`Service`创建任何`Endponit`

### 4.1.7 Publishing services - service types

有时候，我们的服务需要对外暴露（不仅仅对其他`Pod`提供服务，而是对整个Internet提供服务），`Kubernetes`允许我们为`Service`指定`ServiceType`，默认的类型是`ClusterIP`，所有的可选类型如下

1. `ClusterIP`: 通过`Cluster IP`暴露该`Service`，意味着只有在集群内才能访问这个`Service`。这是默认的类型
1. `NodePort`: 通过`NodePort`暴露该`Service`，即在集群中所有`Node`上都分配一个静态的端口。在该类型下，会自动为`Service`创建`Cluster IP`用于路由，我们也可以从外部通过`<NodeIP>:<NodePort>`来访问这个`Service`
1. `LoadBalancer`: 通过`Load Balancer`对外暴露该`Service`。在该类型下，会自动为`Service`创建`Cluster IP`以及`NodePort`用于路由
1. `ExternalName`: 通过`CNAME`暴露该服务，将服务映射到`externalName`字段对应的域名中，完全由`DNS`负责路由

#### 4.1.7.1 Type NodePort

对于这种模式的`Service`，集群中所有的`Node`都会代理该相同的`Port`，该端口号对应于`Service`的`.spec.ports[*].nodePort`配置项

我们可以通过`--nodeport-addresses`选项来指定一个或一组`IP`的范围（多个的话，以`,`分隔），该选项的默认是是空`[]`，意味着最大的`IP`范围

我们可以通过`nodePort`来指定暴露的`Port`，因此我们需要注意端口冲突的问题，且必须属于合法的`NodePort`范围

这种方式给予了开发者更多的自由度，允许配置自己的负载均衡服务，允许在精简版的`Kubernetes`环境中使用`Service`，允许我们直接暴露`Node`的`IP`来使用`Service`

**服务可以通过`<NodeIP>:spec.ports[*].nodePort`或者`.spec.clusterIP:spec.ports[*].port`两种方式进行访问**

#### 4.1.7.2 Type LoadBalancer

对于提供负载均衡服务的云环境，我们可以将`Service`指定为`LoadBalancer`类型，`Kubernetes`会为`Service`创建`LoadBalancer`，事实上，`LoadBalancer`的创建过程与`Service`的创建过程是异步的。当`LoadBalancer`发布后，会更新`Service`的`.status.loadBalancer`字段

```yml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 9376
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
    - ip: 146.148.47.155
```

`LoadBalancer`接收到来自外部的流量后，会直接路由到提供服务的`Pod`，具体方式依赖于云服务提供商的实现。一些云服务提供商允许指定`loadBalancerIP`，在这种情况下会以配置的`IP`来创建`LoadBalancer`，若`loadBalancerIP`未配置，则会分配一个随机的IP。如果云服务商不提供这个功能，那么这个字段将会被忽略

### 4.1.8 The gory details of virtual IPs

本小节将介绍`Service`的一些细节问题

#### 4.1.8.1 Avoiding collisions

`Kubernetes`的哲学之一就是尽量避免用户因为自身以外的因素，导致应用无法正常工作。对于端口而言，用户自己选择端口号，将会有一定概率导致冲突，因此，`Kubernetes`为用户自动分配端口号

`Kubernetes`确保每个`Service`分配到的`IP`在集群中是唯一的。具体做法是，`Kubernetes`会在`etcd`中维护一个全局的分配映射表

#### 4.1.8.2 IPs and VIPs

`Pod IP`通常可以定位到一个确定的`Pod`，但是`Service`的`Cluster IP(Virtual IP, VIP)`通常映射为一组`Pod`，因此，`Kubernetes`利用`iptables`将`Cluster IP`进行重定向。因此，所有导入`VIP`的流量都会自动路由到一个或一组`Endpoint`中去。`Service`的环境变量和DNS实际上是根据服务的`VIP`和端口填充的

`Kubernetes`支持三种不同的模式，分别是`userspace`、`iptables`、`ipvs`，这三者之间有微小的差异

## 4.2 DNS for Services and Pods

### 4.2.1 Introduction

每个`Service`都会分配一个`DNS Name`。通常情况下，一个`Pod`的`DNS`搜索范围包括`Pod`所在的`Namespace`以及集群的默认`domain`。举例来说，`Namspace bar`中包含`Service foo`，一个运行在`Namspace bar`中的`Pod`可以通过`foo`来搜索这个`Service`，一个运行在`Namspace quux`中的`Pod`可以通过`foo.bar`来搜索这个`Service`

### 4.2.2 Services

#### 4.2.2.1 A Records

1. `Pod`会被分配一个`A Record`，其格式为`<pod-ip-address>.<my-namespace>.pod.cluster.local`
1. 例如一个`Pod`，其`IP`为`1.2.3.4`，其`Namespace`为`default`，且`DNS Name`为`cluster.locals`，那么对应的`A Record`为`1-2-3-4.default.pod.cluster.local`

### 4.2.3 Pods

#### 4.2.3.1 Pod's hostname and subdomain fields

1. 当一个`Pod`创建时，它的`hostname`就是`metadata.name`的值
1. `Pod`还可以指定`spec.hostname`，若`spec.hostname`与`metadata.name`同时存在时，以`spec.hostname`为准
1. `Pod`还可以指定`spec.subdomain`。例如，若一个`Pod`，其`spec.hostname`为`foo`，`spec.subdomain`为`bar`，`Namespace`为`my-namespace`，则对应的`FQDN`为`foo.bar.my-namespace.pod.cluster.local`

```yml
apiVersion: v1
kind: Service
metadata:
  name: default-subdomain
spec:
  selector:
    name: busybox
  clusterIP: None
  ports:
  - name: foo # Actually, no port is needed.
    port: 1234
    targetPort: 1234
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox1
  labels:
    name: busybox
spec:
  hostname: busybox-1
  subdomain: default-subdomain
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    name: busybox
---
apiVersion: v1
kind: Pod
metadata:
  name: busybox2
  labels:
    name: busybox
spec:
  hostname: busybox-2
  subdomain: default-subdomain
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    name: busybox
```

#### 4.2.3.2 Pod's DNS Policy

可以基于每个`Pod`设置`DNS Policy`。目前，`Kubernetes`支持以下几种`DNS Policy`

1. `Default`: 从`Node`中继承`DNS`配置
1. `ClusterFirst`: 任何不匹配集群域名后缀的`DNS Query`都会转发到从`Node`中继承而来的上游`DNS`服务器
1. `ClusterFirstWithHostNet`: 若`Pod`以`hostNetwork`模式运行，那么`DNS`必须设置为`ClusterFirstWithHostNet`
1. `None`: 忽略`Kubernetes`的`DNS Policy`，同时依赖`spec.dnsConfig`提供更细粒度的配置

```yml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: default
spec:
  containers:
  - image: busybox
    command:
      - sleep
      - "3600"
    imagePullPolicy: IfNotPresent
    name: busybox
  restartPolicy: Always
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
```

#### 4.2.3.3 Pod's DNS Config

`Kubernetes`在`v1.9`版本后允许用户进行更细粒度的`DNS`配置，需要通过`--feature-gates=CustomPodDNS=true`选项来开启该功能。开启功能后，我们就可以将`spec.dnsPolicy`字段设置为`None`，并且新增一个字段`dnsConfig`，来进行更细粒度的配置

`dnsConfig`支持以下几项配置

1. `nameservers`: `DNS`服务器列表，最多可以设置3个，最少包含一个
1. `searches`: `DNS Search Domain`列表，最多支持6个
1. `options`: 一些键值对的列表，每个键值对必须包含`Key`，但是`Value`可以没有

```yml
apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: dns-example
spec:
  containers:
    - name: test
      image: nginx
  dnsPolicy: "None"
  dnsConfig:
    nameservers:
      - 1.2.3.4
    searches:
      - ns1.svc.cluster.local
      - my.dns.search.suffix
    options:
      - name: ndots
        value: "2"
      - name: edns0
```

## 4.3 Connecting Applications with Services

在讨论`Kubernetes`的网络通信之前，我们先对比一下`Docker`的常规网络通信方式

默认情况下，`Docker`使用的是`host-private`网络，因此，只有处于同一个机器上的不同`Container`之间才可以通信。因此要想跨`Node`进行通信，那么必须为`Container`所在的机器分配`IP`用以代理该`Container`，这样一来就必须处理`IP`以及`Port`冲突的问题

在不同的开发者之间进行`Port`的统一分配是一件非常困难的事情，并且会增加扩容/缩容的复杂度。`Kubernetes`首先假设`Pod`可以与其他`Pod`进行通信，且无视他们所属的`Node`，`Kubernetes`会为每个`Pod`分配一个`cluster-private-IP`，且我们无需处理这些映射关系。这意味着，位于同一个`Node`上的`Pod`自然可以通过`localhost`进行通信，位于不同`Node`上的`Pod`无需使用`NAT`也可以进行通信，下面将详细介绍`Kubernetes`的实现方式

### 4.3.1 Exposing pods to the cluster

下面，我们用一个`Nginx Pod`作为例子，进行介绍

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
```

下面创建一个`Deployment Object`

```sh
# 创建 Deployment
kubectl create -f ./run-my-nginx.yaml

#-------------------------↓↓↓↓↓↓-------------------------
deployment.apps/my-nginx created
#-------------------------↑↑↑↑↑↑-------------------------

# 查看 Pod
kubectl get pods -l run=my-nginx -o wide

#-------------------------↓↓↓↓↓↓-------------------------
NAME                        READY     STATUS    RESTARTS   AGE       IP           NODE
my-nginx-59497d7745-9z9f7   1/1       Running   0          3m        10.244.1.8   k8s-node-1
my-nginx-59497d7745-kww92   1/1       Running   0          3m        10.244.2.5   k8s-node-2
#-------------------------↑↑↑↑↑↑-------------------------

# 查看 Pod ip
kubectl get pods -l run=my-nginx -o yaml | grep podIP

#-------------------------↓↓↓↓↓↓-------------------------
    podIP: 10.244.1.8
    podIP: 10.244.2.5
#-------------------------↑↑↑↑↑↑-------------------------
```

注意到，这些`Pod`并没有用附属`Node`的`80`端口，也没有配置任何`NAT`规则来路由流量，这意味着，我们可以在同一个`Node`上部署多个`Pod`，并且利用`IP`来访问这些`Pod`

登录`Pod`的命令如下

```sh
kubectl exec -it <pod-name> -n <namespace> -- bash
```

### 4.3.2 Create a Service

理论上，我们可以直接使用这些`Pod`的`IP`来与之通信，但是一旦`Node`挂了之后，又会被`Deployment`部署到其他健康的`Node`中，并分配一个新的`Pod IP`，因此，会带来非常大的复杂度

`Serivce`抽象了一组功能相同的`Pod`。每个`Service`在创建之初就会被分配一个独有的`IP`，称为`Cluster IP`，该`IP`在`Service`的生命周期中保持不变，进入`Service`的流量会通过负载均衡后，路由到其中一个`Pod`上

接着上面的例子，我们可以通过`kubectl expose`来创建一个`Service`

```sh
# 创建service
kubectl expose deployment/my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
service/my-nginx exposed
#-------------------------↑↑↑↑↑↑-------------------------

# 查看service
kubectl get svc my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
my-nginx   ClusterIP   10.96.104.176   <none>        80/TCP    3m
#-------------------------↑↑↑↑↑↑-------------------------

# 查看service的状态
kubectl describe svc my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
Name:              my-nginx
Namespace:         default
Labels:            run=my-nginx
Annotations:       <none>
Selector:          run=my-nginx
Type:              ClusterIP
IP:                10.96.104.176
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.8:80,10.244.2.5:80
Session Affinity:  None
Events:            <none>
#-------------------------↑↑↑↑↑↑-------------------------

kubectl describe svc my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
Name:              my-nginx
Namespace:         default
Labels:            run=my-nginx
Annotations:       <none>
Selector:          run=my-nginx
Type:              ClusterIP
IP:                10.96.104.176
Port:              <unset>  80/TCP
TargetPort:        80/TCP
Endpoints:         10.244.1.8:80,10.244.2.5:80
Session Affinity:  None
Events:            <none>
#-------------------------↑↑↑↑↑↑-------------------------

# 查看endpoint
kubectl get ep my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
NAME       ENDPOINTS                     AGE
my-nginx   10.244.1.8:80,10.244.2.5:80   11m
#-------------------------↑↑↑↑↑↑-------------------------
```

`kubectl expose`等价于`kubectl create -f <如下配置文件>`

```yml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  ports:
  - port: 80
    protocol: TCP
  selector:
    run: my-nginx
```

根据上面的定义，该`Serivce`会代理所有匹配`run: my-nginx`的`Pod`。其中`port`是`Serivce`的流量入口端口；`targetPort`是`Pod`的流量入口端口，默认与`port`相同

这些`Pod`通过`Endpoint`露出，`Service`会持续筛选匹配`Selector`的`Pod`，并将结果输送到与`Pod`同名的`Endpoint`对象中。当一个`Pod`挂了之后，它会自动从`Endpoint`中被移除，新的`Pod`随即会被创建，并添加到`Endpoint`中

### 4.3.3 Accessing the Service

`Kubernetes`提供了两种服务发现的方式：`Environment Variables`以及`DNS`

#### 4.3.3.1 Environment Variables

当`Pod`运行在`Node`之后，`kubectl`会为每个`Service`设置一些环境变量。这种方式会引入顺序问题

首先，我们查看一下现有`Pod`的环境变量

```sh
kubectl exec <pod name> -- printenv | grep SERVICE

#-------------------------↓↓↓↓↓↓-------------------------
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1
#-------------------------↑↑↑↑↑↑-------------------------
```

可以看到，这里没有我们创建的`Service`的相关信息，这是因为我们在创建`Service`之前，首先创建了`Pod`。另一个弊端是，`Scheduler`可能会将上述两个`Pod`部署到同一个`Node`中，这会导致整个`Service`不可用，我们可以通过杀死这两个`Pod`并等待`Deployment`重新创建两个新的`Pod`来修复这个问题

```sh
# 杀死现有的Pod，并创建新的Pod
kubectl scale deployment my-nginx --replicas=0; kubectl scale deployment my-nginx --replicas=2;

#-------------------------↓↓↓↓↓↓-------------------------
deployment.extensions/my-nginx scaled
deployment.extensions/my-nginx scaled
#-------------------------↑↑↑↑↑↑-------------------------

# 查看Pod
kubectl get pods -l run=my-nginx -o wide

#-------------------------↓↓↓↓↓↓-------------------------
NAME                        READY     STATUS    RESTARTS   AGE       IP           NODE
my-nginx-59497d7745-jb8zm   1/1       Running   0          1m        10.244.1.9   k8s-node-1
my-nginx-59497d7745-nrxj7   1/1       Running   0          1m        10.244.2.6   k8s-node-2
#-------------------------↑↑↑↑↑↑-------------------------

# 查看环境变量
kubectl exec <pod name> -- printenv | grep SERVICE

#-------------------------↓↓↓↓↓↓-------------------------
KUBERNETES_SERVICE_HOST=10.96.0.1
KUBERNETES_SERVICE_PORT_HTTPS=443
MY_NGINX_SERVICE_HOST=10.96.104.176
MY_NGINX_SERVICE_PORT=80
KUBERNETES_SERVICE_PORT=443
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 4.3.3.2 DNS

`Kubernetes`提供了一个`DNS cluster addon Service`，它会为每个`Service`分配一个`DNS Name`，我们可以通过如下命令查看

```sh
kubectl get services kube-dns --namespace=kube-system

#-------------------------↓↓↓↓↓↓-------------------------
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   ClusterIP   10.96.0.10   <none>        53/UDP,53/TCP   212d
#-------------------------↑↑↑↑↑↑-------------------------
```

在集群中的任何`Pod`都可以用标准的方式来访问`Service`，我们运行另一个`curl`应用来进行测试

```sh
# 以交互的方式运行一个`container`
kubectl run curl --image=radial/busyboxplus:curl -i --tty

nslookup my-nginx

#-------------------------↓↓↓↓↓↓-------------------------
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      my-nginx
Address 1: 10.96.104.176 my-nginx.default.svc.cluster.local
#-------------------------↑↑↑↑↑↑-------------------------
```

### 4.3.4 Securing the Service

对于需要对外露出的`Service`，我们可以为其添加`TLS/SSL`

```sh
#create a public private key pair
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/nginx.key -out /tmp/nginx.crt -subj "/CN=my-nginx/O=my-nginx"
#convert the keys to base64 encoding
cat /tmp/nginx.crt | base64
cat /tmp/nginx.key | base64
```

下面创建一个`Secret`，配置如下

```yml
apiVersion: "v1"
kind: "Secret"
metadata:
  name: "nginxsecret"
  namespace: "default"
data:
  nginx.crt: "<cat /tmp/nginx.crt | base64 的输出>"
  nginx.key: "<cat /tmp/nginx.key | base64 的输出>"
```

```sh
kubectl create -f nginxsecrets.yaml

#-------------------------↓↓↓↓↓↓-------------------------
secret/nginxsecret created
#-------------------------↑↑↑↑↑↑-------------------------

kubectl get secrets

#-------------------------↓↓↓↓↓↓-------------------------
NAME                  TYPE                                  DATA      AGE
default-token-m7tnl   kubernetes.io/service-account-token   3         212d
nginxsecret           Opaque                                2         14s
#-------------------------↑↑↑↑↑↑-------------------------
```

现在需要替换掉之前的`nginx`服务，配置如下

```yml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
  labels:
    run: my-nginx
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 80
    protocol: TCP
    name: http
  - port: 443
    protocol: TCP
    name: https
  selector:
    run: my-nginx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-nginx
spec:
  selector:
    matchLabels:
      run: my-nginx
  replicas: 1
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      volumes:
      - name: secret-volume
        secret:
          secretName: nginxsecret
      containers:
      - name: nginxhttps
        image: bprashanth/nginxhttps:1.0
        ports:
        - containerPort: 443
        - containerPort: 80
        volumeMounts:
        - mountPath: /etc/nginx/ssl
          name: secret-volume
```

上述的配置清单包括

1. `Deployment`以及`Service`
1. `nginx`暴露了`80`以及`443`端口，`Service`露出了这两个端口，分别是`8080`以及`443`端口
1. `Container`通过挂载到`/etc/nginx/ssl`上的卷来获取`secret key`

利用上述配置，替换原先的`nginx`

```sh
kubectl delete deployments,svc my-nginx; kubectl create -f ./nginx-secure-app.yaml

#-------------------------↓↓↓↓↓↓-------------------------
deployment.extensions "my-nginx" deleted
service "my-nginx" deleted
service/my-nginx created
deployment.apps/my-nginx created
#-------------------------↑↑↑↑↑↑-------------------------
```

于是我们就能通过`Service`来访问`Nginx Server`了

```sh
# 查询Server的Cluster Ip
kubectl get svc -o wide

#-------------------------↓↓↓↓↓↓-------------------------
NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                        AGE       SELECTOR
kubernetes            ClusterIP   10.96.0.1        <none>        443/TCP                        212d      <none>
my-nginx              NodePort    10.102.252.181   <none>        8080:31530/TCP,443:32730/TCP   24m       run=my-nginx
#-------------------------↑↑↑↑↑↑-------------------------

# 通过Cluster IP访问nginx
curl -k https://10.102.252.181

#-------------------------↓↓↓↓↓↓-------------------------
...
<title>Welcome to nginx!</title>
...
#-------------------------↑↑↑↑↑↑-------------------------

curl -k http://10.102.252.181:8080

#-------------------------↓↓↓↓↓↓-------------------------
<title>Welcome to nginx!</title>
#-------------------------↑↑↑↑↑↑-------------------------
```

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: curl-deployment
spec:
  selector:
    matchLabels:
      app: curlpod
  replicas: 1
  template:
    metadata:
      labels:
        app: curlpod
    spec:
      volumes:
      - name: secret-volume
        secret:
          secretName: nginxsecret
      containers:
      - name: curlpod
        command:
        - sh
        - -c
        - while true; do sleep 1; done
        image: radial/busyboxplus:curl
        volumeMounts:
        - mountPath: /etc/nginx/ssl
          name: secret-volume
```

```sh
# 创建另一个curl pod
kubectl create -f ./curlpod.yaml

#-------------------------↓↓↓↓↓↓-------------------------
deployment.apps/curl-deployment created
#-------------------------↑↑↑↑↑↑-------------------------

# 获取pod名称
kubectl get pods -l app=curlpod

#-------------------------↓↓↓↓↓↓-------------------------
NAME                              READY     STATUS    RESTARTS   AGE
curl-deployment-d74d885b7-tc7z8   1/1       Running   0          25s
#-------------------------↑↑↑↑↑↑-------------------------

# 用指定的pod执行curl命令访问ngix服务
kubectl exec curl-deployment-d74d885b7-tc7z8 -- curl https://my-nginx --cacert /etc/nginx/ssl/nginx.crt 

#-------------------------↓↓↓↓↓↓-------------------------
...
<title>Welcome to nginx!</title>
...
#-------------------------↑↑↑↑↑↑-------------------------
```

### 4.3.5 Exposing the Service（未完成）

如果我们的应用想要对外露出，`Kubernetes`提供了两种方式，即`NodePort`以及`LoadBalancer`，上面的例子中，使用的是`NodePort`方式，因此如果`Node`本身就有`Public IP`，那么就可以对外提供服务了

```sh
# 查看nodePort
kubectl get svc my-nginx -o yaml | grep nodePort -C 5

#-------------------------↓↓↓↓↓↓-------------------------
spec:
  clusterIP: 10.102.252.181
  externalTrafficPolicy: Cluster
  ports:
  - name: http
    nodePort: 31530
    port: 8080
    protocol: TCP
    targetPort: 80
  - name: https
    nodePort: 32730
    port: 443
    protocol: TCP
    targetPort: 443
  selector:
    run: my-nginx
#-------------------------↑↑↑↑↑↑-------------------------

# 查看externalIP
kubectl get nodes -o yaml | grep ExternalIP -C 1
```

## 4.4 Ingress

`Ingress`用于管理`Service`的访问方式（通常是`HTTP`）

`Ingress`可以提供`Load Balancing`、`SSL Termination`以及`Virtual Host`等服务

### 4.4.1 Terminology

涉及到的相关术语

1. `Node`: `Kubernetes`集群中的虚拟机或者物理机
1. `Cluster`: 由一组`Node`组成，通常它们由`Kubernetes`进行管理
1. `Edge Router`: 用于执行防火墙策略的路由器，通常形态是云服务商提供的网关或者是一个硬件
1. `Cluster Network`: 用于进群内通信的网络基础设施
1. `Service`: 定义了一组满足特定`Label Selector`的`Pod`，`Serivce`含有一个仅在集群内有效的`Virtual IP`

### 4.4.2 What is Ingress?

`Ingress`定义从`Internet`到`Service`的路由规则，因此`Ingress`可以控制外来访问流量

`Ingress`通常包含`LoadBalancer`、`Edge Router`以及一些其他用于处理流量的组件

`Ingress`不露出任何协议以及端口，要想暴露`Service`而不是`HTTP/HTTPS`的话，应该使用`Service.Type`（设置成`NodePort`或者`LoadBalancer`方式）

### 4.4.3 Ingress controllers

为了使得`Ingress`能够正常工作，必须要在集群运行一个`Ingress Controller`，该`Ingress Controller`与其他`Controller`不同，它不属于`kube-controller-manager`的一部分，且不会自动启动

### 4.4.4 The Ingress Resource

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```

与其他`Kubernetes Object`相同，`Ingress`需要`apiVersion`、`kind`、`metadata`三个字段

每个`HTTP Rule`都包含了如下的信息

1. `host`: 匹配指定的`host`
1. `path`: 匹配指定的`path`，每个`path`都包含了一个后端的`serviceName`以及`servicePort`
1. `backend`: 任何匹配`host`以及`path`的请求，都会被路由到`backend`对应的`Service`中

如果一个`Ingress`没有配置任何的`rule`，那么所有流量都会被路由到一个`default backend`；如果流量不匹配任何的`host`以及`path`，那么该流量也会被路由到`default backend`

`default backend`可以在`Ingress Controller`中进行配置

### 4.4.5 Types of Ingress

#### 4.4.5.1 Single Service Ingress

一个`Ingress`只对应了一个后端的`Service`

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  backend:
    serviceName: testsvc
    servicePort: 80
```

#### 4.4.5.2 Simple fanout

一个`Ingress`对应着多个`Service`

```
foo.bar.com -> 178.91.123.132 -> / foo    service1:4200
                                 / bar    service2:8080
```

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: simple-fanout-example
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: service1
          servicePort: 4200
      - path: /bar
        backend:
          serviceName: service2
          servicePort: 8080
```

#### 4.4.5.3 Name based virtual hosting

该类型常用于将多个`Service`通过同一个IP暴露出去，且对外的域名是不同的

```
foo.bar.com --|                 |-> foo.bar.com s1:80
              | 178.91.123.132  |
bar.foo.com --|                 |-> bar.foo.com s2:80
```

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: name-virtual-host-ingress
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: service1
          servicePort: 80
  - host: bar.foo.com
    http:
      paths:
      - backend:
          serviceName: service2
          servicePort: 80
```

#### 4.4.5.4 TLS

我们可以在`Ingress`之上增加`TSL/SSL`协议

```yml
apiVersion: v1
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
kind: Secret
metadata:
  name: testsecret-tls
  namespace: default
type: kubernetes.io/tls
```

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
    - sslexample.foo.com
    secretName: testsecret-tls
  rules:
    - host: sslexample.foo.com
      http:
        paths:
        - path: /
          backend:
            serviceName: service1
            servicePort: 80
```

#### 4.4.5.5 Loadbalancing

一个`Ingress Controller`通常支持一些负载均衡的设置，包括负载均衡算法、权重策略等，目前尚不支持一些负载均衡的高级配置

### 4.4.6 Updating an Ingress

```sh
kubectl edit ingress test
```

## 4.5 Ingress Controller

为了使得`Ingress`能够生效，我们必须运行一个`Ingress Controller`。与其他`Controller`不同，`Ingress Controller`不会默认启动

### 4.5.1 Additional controllers

`Ingress Controller`有许多不同的实现

1. `Ambassador`
1. `AppsCode Inc`
1. `Contour`
1. `Citrix`
1. `F5 Networks`
1. `Gloo`
1. `HAProxy`
1. `Istio`
1. `Kong`
1. `NGINX, Inc`
1. `Traefik`

## 4.6 Network Policies

`Network Policy`定义了`Pod`之间或者`Pod`与其他`Endpoint`之间的通信方式

### 4.6.1 Isolated and Non-isolated Pods

默认情况下，`Pod`都是`non-isolated`，意味着，它可以接收来自任何源的流量

当`Pod`匹配某个`NetworkPolicy`后，它就变成`isolated`的了，于是，它会拒绝所有不满足`NetworkPolicy`规则的流量

### 4.6.2 The NetworkPolicy Resource

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

1. 与其他`Kubernetes Object`相同，`NetworkPolicy`需要`apiVersion`、`Kind`、`metadata`三个字段
1. `spec`: 描述`NetworkPolicy`的最主要的字段
1. `spec.podSelector`: 用于匹配`Pod`的`Selector`。一个空的`podSelector`会选择当前`Namespace`下的所有`Pod`
1. `spec.policyTypes`: 可以是`Ingress`、`Egress`或者两者。默认情况下，会包含`Ingress`，且如果包含任何`Egress`规则，那么也会包含`Egress`
    * > `ingress`: 每个`NetworkPolicy`都包含了一个`ingress rule`列表，每项规则包含`from`以及`ports`两项。其类型可以是`ipBlock`、`namespaceSelector`或者`podSelector`
    * > `egress`: 每个`NetworkPolicy`都包含另一个`egress rule`列表，每项规则包含`to`以及`ports`两项

### 4.6.3 Behavior of to and from selectors

`igress`的`from`部分与`egress`的`to`部分可以包含如下四种类型

1. `podSelector`: 在`NetworkPolicy`所在的`Namespace`下选择特定的`Pod`
1. `namespaceSelector`: 选择特定的`Namespace`下的所有`Pod`
1. `podSelector`和`namespaceSelector`: 选择特定`Namespace`下的特定`Pod`
1. `ipBlock`: 选择特定的`IP CIDR`范围，且必须是`cluster-external IP`

**区分以下两种配置的区别**

```yml
...
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          user: alice
      podSelector:
        matchLabels:
          role: client
  ...
```

这种配置包含一个规则: `podSelector`和`namespaceSelector`

```yml
...
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          user: alice
    - podSelector:
        matchLabels:
          role: client
  ...
```

这种配置包含两种规则: `podSelector`或`namespaceSelector`

### 4.6.4 Default policies

默认情况下，不存在任何`Policy`，但是我们可以修改默认的行为

#### 4.6.4.1 Default deny all ingress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

#### 4.6.4.2 Default allow all ingress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}
  ingress:
  - {}
  policyTypes:
  - Ingress
```

#### 4.6.4.3 Default deny all egress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Egress
```

#### 4.6.4.4 Default allow all egress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all
spec:
  podSelector: {}
  egress:
  - {}
  policyTypes:
  - Egress
```

#### 4.6.4.5 Default deny all ingress and all egress traffic

```yml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## 4.7 Adding entries to Pod /etc/hosts with HostAliases

当没有DNS的时候，我们可以通过配置`/etc/hosts`来提供一种`Pod-Level`的域名解决方案

### 4.7.1 Default Hosts File Content

```sh
kubectl run nginx --image nginx --generator=run-pod/v1

#-------------------------↓↓↓↓↓↓-------------------------
pod/nginx created
#-------------------------↑↑↑↑↑↑-------------------------

# 查看Pod ip
kubectl get pods --output=wide

#-------------------------↓↓↓↓↓↓-------------------------
NAME          READY     STATUS    RESTARTS   AGE       IP            NODE
nginx         1/1       Running   0          8m        10.244.2.49   k8s-node-2
#-------------------------↑↑↑↑↑↑-------------------------

# 查看nginx的/etc/hosts文件的默认内容
kubectl exec nginx -- cat /etc/hosts

#-------------------------↓↓↓↓↓↓-------------------------
# Kubernetes-managed hosts file.
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
fe00::0	ip6-mcastprefix
fe00::1	ip6-allnodes
fe00::2	ip6-allrouters
10.244.2.49	nginx
#-------------------------↑↑↑↑↑↑-------------------------
```

### 4.7.2 Adding Additional Entries with HostAliases

通过为`Pod`配置`.spec.hostAliases`属性，可以增加额外的域名解析规则，如下

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostaliases-pod
spec:
  restartPolicy: Never
  hostAliases:
  - ip: "127.0.0.1"
    hostnames:
    - "foo.local"
    - "bar.local"
  - ip: "10.1.2.3"
    hostnames:
    - "foo.remote"
    - "bar.remote"
  containers:
  - name: cat-hosts
    image: busybox
    command:
    - cat
    args:
    - "/etc/hosts"
```

```sh
kubectl apply -f hostaliases-pod.yaml

#-------------------------↓↓↓↓↓↓-------------------------
pod/hostaliases-pod created
#-------------------------↑↑↑↑↑↑-------------------------

# 查看Pod IP
kubectl get pod -o=wide

#-------------------------↓↓↓↓↓↓-------------------------
NAME              READY     STATUS      RESTARTS   AGE       IP            NODE
hello-world       1/1       Running     16         225d      10.244.1.49   k8s-node-1
hostaliases-pod   0/1       Completed   0          1m        10.244.2.50   k8s-node-2
#-------------------------↑↑↑↑↑↑-------------------------

kubectl logs hostaliases-pod

#-------------------------↓↓↓↓↓↓-------------------------
# Kubernetes-managed hosts file.
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
fe00::0	ip6-mcastprefix
fe00::1	ip6-allnodes
fe00::2	ip6-allrouters
10.244.2.50	hostaliases-pod
# Entries added by HostAliases.
127.0.0.1	foo.local
127.0.0.1	bar.local
10.1.2.3	foo.remote
10.1.2.3	bar.remote
#-------------------------↑↑↑↑↑↑-------------------------
```

### 4.7.3 Why Does Kubelet Manage the Hosts File?

`kubelet`为每个`Container`管理`host`文件，是为了避免`Docker`在启动容器后修改该文件

由于文件托管的性质，只要在`Container`重新启动或者`Pod`重新被调度的情况下，`kubelet`都会重新载入`host`文件，任何用户编写的内容都将被覆盖，因此，不建议修改文件的内容

# 5 Storage

## 5.1 Volumes

`Container`中的磁盘文件是短暂的，这会带来一些问题。首先，当一个`Container`崩溃之后，`kubelet`会重启该`Container`，但是这些磁盘文件会丢失。其次，在一个`Pod`中运行的不同`Container`之间可能需要共享一些文件。因此`Kubernetes`利用`Volume`来解决上述问题

### 5.1.1 Backgroud

`Docker`也有`Volume`的相关概念，但是其能力相比于`Kubernetes`较弱。在`Docker`中，一个`Volume`就是磁盘中或者其他`Container`中的一个目录，`Volume`的生命周期不受管控。`Docker`现在还提供了`Volume Driver`，但是其功能还是非常薄弱

`Kubernetes`中的`Volume`有明确的生命周期，`Volume`的生命周期比`Pod`中任何`Container`的生命周期更长，因此数据能够在`Container`重启时保留。当然，如果一个`Pod`停止了，那么`Volume`也会相应停止。此外，`Kubernetes`提供了多种类型的`Volume`，且`Pod`可以同时使用任意类型，任意数量的`Volume`

本质上而言，`Volume`就是一个包含数据的可被`Container`访问的目录，至于该目录是如何形成的，支持它的介质以及存储的内容是由具体的类型决定的

我们可以通过配置`.spec.volumes`字段来指定`Volume`的类型以及相应的参数，通过`.spec.containers.volumeMounts`来指定具体的挂载目录

在`Container`中的应用可以看到由`Docker Image`以及`Volume`组成的文件系统视图。`Docker Image`位于文件系统的顶层，所有的`Volume`必须挂载到`Image`中。`Volume`不能挂载到其他`Volume`中或者与其他`Volume`存在`hard link`。在`Pod`中的每个`Container`必须独立地指定每个`Volume`的挂载目录

### 5.1.2 Types of Volumes

1. awsElasticBlockStore
1. azureDisk
1. azureFile
1. cephfs
1. configMap
1. csi
1. downwardAPI
1. emptyDir
1. fc (fibre channel)
1. flexVolume
1. flocker
1. gcePersistentDisk
1. gitRepo (deprecated)
1. glusterfs
1. hostPath
1. iscsi
1. local
1. nfs
1. persistentVolumeClaim
1. projected
1. portworxVolume
1. quobyte
1. rbd
1. scaleIO
1. secret
1. storageos
1. vsphereVolume

## 5.2 Persistent Volumes

## 5.3 Storage Classes

## 5.4 Volume Snapshot Classes

## 5.5 Dynamic Volume Provisioning

## 5.6 Node-specific Volume Limits

# 6 Network

## 6.1 Overview

首先，我们来明确一下，Kubernetes面临的网络问题

1. **Highly-coupled Container-to-Container communications**：高耦合的`Container`之间的网络通信，通过`pods`以及`localhost`通信来解决
1. **Pod-to-Pod communications**：本小节将详细展开说明
1. **Pod-to-Service communications**：通过`services`来解决
1. **External-to-Service communications**：通过`services`来解决

## 6.2 Docker Model

我们先来回顾一下Docker的网络模型，这对于理解Kubernetes的网络模型是很有必要的。**在默认情况下，`Docker`利用`host-private networking`，`Docker`创建了一个虚拟网桥（virtual bridge），默认为`docker0`**。对于`Docker`创建的每个`Container`都会有一个连接到网桥的虚拟以太网卡（virtual Ethernet device）`veth`，从`Container`内部来看，`veth`就被映射成了`eth0`网卡

在这种网络模型下，只要位于同一个物理机上（或者同一个虚拟网桥上），所有的`Container`之间可以进行通信。但是位于不同物理机上的`Container`是无法进行通信的

为了让`Container`可以跨`node`进行交互，必须为它们分配一个宿主物理机的`ip`。这样一来，我们就需要付出额外的精力维护`ip`以及`port`

## 6.3 Kubernetes model

`Kubernetes`要求网络模型必须满足如下条件

1. 所有`Container`之间的通信不能依赖NAT
1. 所有`node`与`Container`之间的通信不能依赖NAT
1. 某个`Container`在内部、外部看到的`ip`一致

这种模式不仅总体上不那么复杂，而且主要与Kubernetes希望将应用程序从VM轻松移植到容器的愿望兼容

到目前为止，都在讨论`Container`，但事实上，`Kubernetes`在`Pod`范围上使用`ip`地址，因此，在一个`Pod`内的所有`Container`共享网络命名空间（network namespaces），当然包括ip地址。这意味着，在一个`Pod`内的`Container`可以通过`localhost`与其他`Container`进行通信。**这称为“IP-per-pod”模式，在这种模式下，一个`Pod`需要有一个`pod contaner`来管理网络命名空间，其他`app container`利用`Docker`的`--net=container:<id>`参数来加入这个网络命名空间即可**

## 6.4 Kubernetes networking model implements

**Kubernetes的网络模型有很多种实现方式，包括但不仅限如下几种**

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

## 6.5 参考

* [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

# 7 Question

1. `Pod IP`在Namespace下唯一，既然可以通过`Namespace`+`Pod IP`准确定位一个`Pod`，为什么还需要`flannel`
1. `flannel`保证了在同一个集群中的`Pod`的ip不重复

# 8 参考

* [英文文档1](https://kubernetes.io/docs/concepts/)
* [中文文档1](http://docs.kubernetes.org.cn/)
* [中文文档2](https://www.kubernetes.org.cn/kubernetes%E8%AE%BE%E8%AE%A1%E6%9E%B6%E6%9E%84)
* [k8s-api-reference](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.14/)
* [k8s-阿里云公开课](https://edu.aliyun.com/course/1651?spm=5176.10731542.0.0.785020be217oeD)
* [nginx ingress doc](https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command)
* [metallb doc](https://metallb.universe.tf/installation/)
* [Borg、Omega 和 Kubernetes：谷歌十几年来从这三个容器管理系统中得到的经验教训](https://segmentfault.com/a/1190000004667502)
* [Kubernetes核心概念总结](http://www.cnblogs.com/zhenyuyaodidiao/p/6500720.html)
* [Kubernetes之Service](https://blog.csdn.net/dkfajsldfsdfsd/article/details/81200411)
* [Kubernetes学习4--容器之间通讯方式及Flannel工作原理](https://blog.csdn.net/weixin_29115985/article/details/78963125)
* [Flannel网络原理](https://www.jianshu.com/p/165a256fb1da)
* [解决Flannel跨主机互联网络问题【Docker】](https://www.jianshu.com/p/be48159fa795)
* [Kubernetes Nginx Ingress 教程](https://mritd.me/2017/03/04/how-to-use-nginx-ingress/)
* [使用kubeadm安装Kubernetes 1.12](https://www.kubernetes.org.cn/4619.html)
* [forbidden: User "system:serviceaccount:kube-system:default" cannot get namespaces in the namespace "default](https://github.com/fnproject/fn-helm/issues/21)
