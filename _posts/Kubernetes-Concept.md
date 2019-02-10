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

# 1 Kubernetes Components

[Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

## 1.1 Master Components

`Master Component`构成了集群的控制面板。`Master Component`是整个集群的决策者，检测并响应集群消息

`Master Component`可以运行在集群中的任意一台机器上，不要在`Master`机器上运行`User Container`

### 1.1.1 kube-apiserver

`kube-apiserver`是整个控制面板的最前端，将`Master Component`通过`Kubernetes API`露出，它被设计成易于水平扩展

### 1.1.2 etcd

`etcd`是高一致性、高可用的`key-value`存储，用于存储`Kubernetes`所有的集群数据

### 1.1.3 kube-shceduler

`kube-shceduler`会观测新创建且尚未被分配的`Pod`，并为其选择一个`Node`来运行

### 1.1.4 kube-controller-manager

`kube-controller-manager`用于在`Master`上运行`Controller`。逻辑上讲，每个`Controller`都是一个独立的进程，但是为了减小实现复杂度，这些被编译进了一个二进制中，运行在同一个进程中

`Controller`包括

1. `Node Controller`: 观测节点，并在节点退出集群时响应
1. `Replication Controller`: 为系统中每个`Replication Controller Object`保持一定数量的`Pod`
1. `Endpoints Controller`: 
1. `Service Account & Token Controller`: 为新`Namespace`创建默认的账号以及API访问的`token`

### 1.1.5 cloud-controller-manager

## 1.2 Node

`Node component`运行在每个`Node`之上，保持`Pod`的运行，并提供`Kubernetes`运行环境

### 1.2.1 kubelet

`kubelet`是运行在集群的每个`Node`上的代理。它确保`Container`在`Pod`中正常运行

`kubelet`采用通过各种机制提供的`PodSpecs`来确保`Container`以期望的方式健康运行

`kubelet`不会管理不由`Kubernetes`创建的`Container`

### 1.2.2 kube-proxy

`kube-proxy`通过维护网络规则并转发网络数据包，来支持`Kubernetes Service`的抽象机制

### 1.2.3 Container Runtime

`Kubernetes`支持多种运行时

1. `Docker`
1. `rkt`
1. `runc`

## 1.3 Addons

???

## 1.4 参考

* [Kubernetes Components](https://kubernetes.io/docs/concepts/overview/components/)

# 2 Kubernetes Object

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

__注意，一个`.yaml`文件中，必须包含如下字段__

1. `apiVersion`：指定`Kubernetes API`的版本
1. `kind`：指定待创建`object`的类型
1. `metadata`：`object`的元数据，包括
  * `name`
  * `UID`
  * `namespace`

## 2.1 Name

所有的`Kubernetes Object`都用一个`Name`和一个`UID`精确确定

### 2.1.1 Nmaes

`Names`是一种用户提供的字符串，表示了一个资源的路径，例如`/api/v1/pods/some-name`

在同一时刻，可以为同一种类型的`Kubernetes Object`分配一个名字。当然，如果我们删除了这个`Kubernetes Object`，我们还可以创建一个同名的`Kubernetes Object`

通常，`Name`最大不超过253个字符，只允许包含小写的字母以及`-`和`.`，具体的类型可能还有更加严格的限制

### 2.1.2 UIDs

`UID`是`Kubernetes`系统创建的用于唯一标志`Kubernetes Object`的字符串。每个`Kubernetes Object`在整个生命周期中都会有一个唯一的`UID`，将`Kubernetes Object`先删除再重新创建，会得到一个新的`UID`

## 2.2 Namespaces

`Kubernetes`支持同一个物理集群支持多个虚拟集群，这些虚拟集群被称为`Namespaces`。如果一个`Kubernetes`集群仅有数十个用户，那么我们完全不必考虑使用`Namespaces`

### 2.2.1 When to use Multiple Namespaces

`Namespaces`用于为使用同一集群的多个不同的小组、项目提供一定程度的隔离

在同一个`Namespaces`中的资源的名称必须唯一，但是在不同`Namespaces`中的资源名称可以重复

如果仅仅为了隔离资源，例如同一个软件的不同版本，可以使用`Label`而不需要使用`Namespaces`

### 2.2.2 Working with Namespaces

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

### 2.2.3 Namespaces and DNS（未完成）

当我们创建一个`Service`，它会创建一个相关的`DNS entry`，其格式为`<service-name>.<namespace-name>.svc.cluster.local`

### 2.2.4 Not All Objects are in a Namespace

大部分`Kubernetes`资源位于一个`Namespace`中。某些底层次的资源，例如`Node`以及`PersistentVolume`不属于任何`Namespace`

以下命令用于查看哪些资源位于/不位于`Namespace`中

```sh
# In a namespace
$ kubectl api-resources --namespaced=true

# Not in a namespace
$ kubectl api-resources --namespaced=false
```

## 2.3 Labels and Selectors

`Labels`是一些依附在`Kubernetes Object`上的键值对。`Lebels`用于为一些对用户有特殊意义的`Kubernetes Object`打标，这些标在`Kubernetes`内核中并无其他含义。`Label`用于组织和选择`Kubernetes Object`。我们可以再任何时刻为`Kubernetes Object`打上`Label`。对于一个`Kubernetes Object`来说，`key`必须是唯一的

### 2.3.1 Motivation

`Lebal`允许用户以一种松耦合的方式将组织结构与`Kubernetes Object`关联起来，用户不必自己存储这些映射关系

服务部署以及一些批处理流水线通常是一个多维度的实体，通常需要交叉式的管理，这会破坏层次结构的严格封装，通常这些封装是由基础设施而非用户完成的

### 2.3.2 Label selectors

与`Name`与`UID`不同，`Label`并不需要保证唯一性。而且，在通常情况下，我们期望多个`Kubernetes Object`共享同一个`Label`

通过`Label Selector`，用户/客户端就可以识别出这些`Kubernetes Object`，因此`Label Selector`是`Kubernetes`管理这些对象的核心

目前，`Kubernetes`支持两种类型的`Selector`：`equality-based`和`set-based`。`Label Selector`由多个`requirement`组成，以逗号分隔，多个`requirement`之间的关系是逻辑与`&&`。__这两种类型可以混用__

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

__selector配置格式__

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
* __所有的条件会以逻辑与的方式组合（包括`matchLabels`和`matchExpressions`）__

### 2.3.3 API

```sh
kubectl get pods -l environment=production,tier=frontend

kubectl get pods -l 'environment in (production),tier in (frontend)'

kubectl get pods -l 'environment in (production, qa)'

kubectl get pods -l 'environment,environment notin (frontend)'
```

## 2.4 Annotations

我们可以通过`Label`以及`Annotation`为`Kubernetes Object`添加一些元数据。`Label`通常被用于`Kubernetes Object`的匹配，而`Annotation`通常用于为`Kubernetes Object`添加一些配置，这些配置可以包含一些`Label`不允许的字符

## 2.5 Field Selectors

`Field Selector`允许我们基于`Kubernetes Object`的字段匹配来过滤`Kubernetes Object`，支持的匹配操作包括：`=`、`==`、`!=`，其中`=`与`==`都表示相等型比较

```sh
kubectl get pods --field-selector status.phase=Running
kubectl get statefulsets,services --field-selector metadata.namespace!=default
```

## 2.6 Recommended Labels

## 2.7 参考

* [Understanding Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
* [Imperative Management of Kubernetes Objects Using Configuration Files](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/)

# 3 Architecture

## 3.1 Node

`Node`是`Kubernetes`中的一个工作者。`Node`可能是一个虚拟机或者物理机。每个`Node`被`Master Component`管理，包含了一些运行`Pod`所必须的服务，包括`Container runtime`、`kubelet`、`kube-proxy`

### 3.1.1 Node Status

`Node`的状态包括以下几部分

1. `Address`
1. `Condition`
1. `Capacity`
1. `Info`

#### 3.1.1.1 Addresses

`Address`包含的字段与服务提供方或者裸机配置有关

1. `HostName`: `hostname`由`Node`的内核上报。可以通过`kubelet`参数`--hostname-override`覆盖
1. `ExternalIP`: 公网IP
1. `InternalIP`: 集群内的IP

#### 3.1.1.2 Condition

`conditions`字段描述了`Node`的状态，包括

1. `OutOfDisk`: 如果剩余空间已经无法容纳新的`Pod`时，为`Frue`；否则`False`
1. `Ready`: 如果`Node`可以接收新的`Pod`时，为`True`；如果`Node`无法接纳新的`Pod`时，为`False`；如果`Controller`与该`Node`断连一定时间后（由`node-monitor-grace-period`字段指定，默认40s），为`Unknown`
1. `MemoryPressure`: 存在内存压力时，为`Ture`；否则`False`
1. `PIDPressure`: 存在进程压力时，为`True`；否则`False`
1. `DiskPressure`: 存在磁盘压力时，为`True`；否则`False`
1. `NetworkUnavailable`: 网络异常时，为`True`；否则`False`

#### 3.1.1.3 Capacity

描述了可用资源的数量，包括CPU、内存、最大可运行的`Pod`数量

#### 3.1.1.4 Info

描述了节点的通用信息，包括内核版本，`Kubernetes`版本，`Docker`版本，`OS`名称等等

### 3.1.2 Management

与`Pod`与`Service`不同，`Pod`与`Service`是由`Kubernetes`负责创建的，而`Node`是由云服务商或者使用者提供的。当`Kubernetes`创建了一个`Node`仅仅意味着创建了一个`Kubernetes Object`来描述这个`Node`

目前，存在三个与`Node`交互的组件，他们分别是：`Node Controller`、`kubelet`、`kubectl`

#### 3.1.2.1 Node Controller

`Node Controller`是`Kubernetes master component`，用于管理`Node`的生命周期

1. 当`Node`注册时，为`Node`分配一个`CIDR block`
1. 保持`Node`列表与云服务提供方的可用机器列表一致，当`Node`变得`unhealthy`后，`Node Controller`会询问云服务提供商该`VM`是否仍然可用，若不可用，则会将其从`Node`列表中删除
1. 监视`Node`的健康状况，`Node Controller`会在`Node`变得`unreachable`后将状态从`NodeReady`变为`ConditionUnknown`，然后以优雅的方式移除该`Node`上的所有`Pod`

在`Kubernetes 1.4`版本中，对集群中大批`Node`同时出故障这一情况的处理做了一些优化，`Controller`会观测集群中所有`Node`的状态，来决策`Pod`以何种方式、何种规模进行移除

在大多数情况下，`Node Controller`限制了移除率`--node-eviction-rate`（默认是0.1），意味着，10秒之内最多只有一个`Node`节点上的`Pod`会被移除

当一个可用区（`Zone`）中的某个`Node`发生故障时，`Node`移除的行为发生了改变。`Node Controller`会检测在当前可用区中发生故障的`Node`的占比，如果这个比例最少为`--unhealthy-zone-threshold`（默认0.55）时，移除率会降低。如果集群很小（节点数量小于），移除过程会直接停止

将`Node`分布于不同的可用区的原因是，当一个可用区变得完全不可用时，那这些`Pod`可以迁移到其他的可用区中

### 3.1.3 Node capacity

`Node`容量是`Node Object`的一部分。通常`Node`在向`Master`注册时，需要上报容量信息。如果我们是手动创建和管理`Node`，那么就需要手动设置容量信息

`Kubernetes Scheduler`会保证`Node`上的资源一定大于所有`Pod`占用的资源。注意到，它仅仅会计算通过`kubelet`创建的`Container`所占用的资源数量，而不会计算由`Container runtime`或者手动创建的`Containter`所占用的资源数量

## 3.2 Master-Node communication

### 3.2.1 Cluster to Master

`Node`与`Master`之间的通信全部依靠`Api server`，除此之外，其他`Master component`不会提供远程服务。在一个典型的部署场景中，`Api server`会在`443`端口上监听

应该为`Node`配置公共根证书，以便它们可以安全地连接到`Api server`

`Pod`可以借助`Service Account`来与`Api server`进行安全通信，`Kubernetes`会在`Pod`实例化的时候，将根证书以及令牌注入到`Pod`中去

`Kubernetes`会为每个`Server`分配一个虚拟IP，`kube-proxy`会将其重定向为`Api server`的具体IP

因此，`Node`与`Api server`之间的通信可以在可靠/不可靠的网络下进行

### 3.2.2 Master to Cluster

`Master(Api server)`与`Node`的通信的方式有两种：其一，`Api server`通过与每个`Node`上的`kubelet`来完成通信；其二，`Api server`通过`Proxy`来完成与`Node`、`Pod`、`Server`的通信

#### 3.2.2.1 Api server to kubelet

`Api server`与`kubelet`之间的通信主要用于以下几个用途

1. 获取`Pod`的日志
1. 与运行时的`Pod`进行交互
1. 为`kubelet`提供端口转发服务（`port-forwarding functionality`）

默认情况下，`Api server`不会校验`kubelet`的服务端证书，因此有可能受到中间人攻击（`man-in-the-middle`），因此在不可信的网络中或者公网上是不安全的。我们可以通过`--kubelet-certificate-authority`来为`Api server`提供一个根证书，用来校验`kubelet`的证书合法性

#### 3.2.2.2 Api server to nodes, pods, and services

`Api server`与`Node`、`Pod`、`Service`之间的通信默认用的是HTTP协议，显然这是不安全的。我们可以为`Node`、`Pod`、`Service`的`API URL`指定`https`前缀，来使用HTTPS协议。但是，`Api server`仍然不会校验证书的合法性，也不会为客户端提供任何凭证，因此在不可信的网络中或者公网上是不安全的

## 3.3 Concepts Underlying the Cloud Controller Manager

最初提出`Cloud Controller Manager(CCM)`概念是为了能够让云服务商与`Kubernetes`可以相互独立地发展

`CCM`是的设计理念是插件化的，这样云服务商就可以以插件的方式与`Kubernetes`进行集成

### 3.3.1 Design

如果没有`CCM`，`Kubernetes`的架构如下：

![fig1](/images/Kubernetes-Concept/fig1.png)

在上面的架构图中，`Kubernetes`与`Cloud Provider`通过几个不同的组件进行集成

1. `kubelet`
1. `Kubernetes Controller Manager(KCM)`
1. `Kubernetes API server`

在引入`CCM`后，整个`Kubernetes`的架构变为：

![fig2](/images/Kubernetes-Concept/fig2.png)

### 3.3.2 Components of the CCM

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

### 3.3.3 Functions of the CCM

#### 3.3.3.1 Kubernetes Controller Manager

`CCM`中大部分的功能都是从`KCM`中继承过来的，包括如下`Controller`

1. `Node Controller`
1. `Route Controller`
1. `Service Controller`
1. `PersistentVolumeLabels Controller`

##### 3.3.3.1.1 Node Controller

`Node Controller`负责初始化`Node`，它会从`Cloud Provier`中获取有关`Node`的一些信息，具体包括

1. 初始化`Node`时，为其打上`zone/region`的标签
1. 初始化`Node`时，记录一些定制化的信息，包括`type`和`size`
1. 获取`Node`的`hostname`和`address`
1. 当`Node`失联时，询问`Cloud Provider`该`Node`是否已被其删除，如果已被删除，那么删除该`Node`对应的`Kubernetes Node Object`

##### 3.3.3.1.2 Route Controller

`Route Controller`负责配置路由信息，以便位于不同`Node`节点上的`Container`能够进行相互通信，目前只与`Google Compute Engine Cluster`兼容

##### 3.3.3.1.3 Service Controller

`Service Controller`负责监听`Service`的创建、更新、删除对应的事件，确保负载均衡可以时时感知服务的状态

##### 3.3.3.1.4 PersistentVolumeLabels Controller

`PersistentVolumeLabels Controller`在`AWS EBS/GCE PD Volume`创建时，为其打上标签。这些标签对于`Pod`的调度至关重要，因为这些`Volume`只在特定的区域，因此被调度的`Pod`也必须位于这些区域才行

`PersistentVolumeLabels Controller`仅用于`CCM`中

#### 3.3.3.2 Kubelet

#### 3.3.3.3 Kubernetes API server

### 3.3.4 Plugin mechanism

### 3.3.5 Authorization

### 3.3.6 Vendor Implementations

### 3.3.7 Cluster Administration

## 3.4 参考

* [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)

# 4 Pods

## 4.1 Pod Overview

### 4.1.1 Understanding Pods

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

### 4.1.2 Working with Pods

在`Kubernetes`中，我们很少直接创建独立的`Pod`，__因为`Pod`被设计成一种相对短暂的、一次性的实体__。当`Pod`被创建后（被用户直接创建，或者被`Controller`创建），它就会被调度到某个节点上开始运行。`Pod`会一直在`Node`上运行，直至被终结、`Pod Object`被删除、`Node`宕机

`Pod`自身并不会自我恢复。也就是说，当`Pod`部署失败或者挂了，这个`Pod`的生命周期就结束了。__Kubernetes用一个高层次的概念，即`Controller`，来管理`Pod`的生命周期，包括`Pod`的创建、部署、副本、恢复等工作__

`Controller`可以为我们创建和管理多个`Pod`，水平扩容、提供自我修复能力。例如，当一个`Node`宕机后，`Controller`会自动地在另一个`Node`上重新启动一个新的`Pod`

### 4.1.3 Pod Templates

__`Pod Template`是`Pod`的一份声明（如下），可以被其他`Kubernetes Object`（包括`Replication Controllers`、`Job`等）引用__

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

## 4.2 Pods

### 4.2.1 What is a Pod?

`Pod`包含一个或者一组`Container`，一些共享的存储/网络组件，以及运行应用的方式。`Pod`中的共享上下文包括：`Linux namespaces`，`cgroups`，以及其他可能的隔离因素

在一个`Pod`中的所有`Container`共享一个`IP`地址，以及端口空间，`Container`之间可以通过`localhost`进行通信，或者其他`IPC`方式。不同`Pod`中的`Container`具有不同的`IP`地址，因此，仅能通过`Pod IP`进行通信

在同一个`Pod`中的`Container`可以访问共享卷，共享卷是`Pod`的一部分，并且可以挂载到文件系统上

`Pod`被设计成一种短暂的、一次性的实体。`Pod`在创建时会被赋予一个唯一的`UID`，并且被调度到某个`Node`上一直运行直至被销毁。如果一个`Node`宕机了，那些被调度到该`Node`上的`Pod`会被删除。一个特定的`Pod`（`UID`层面）不会被重新调度到新的`Node`上，相反，它会被一个新的`Pod`替代，这个新`Pod`可以复用之前的名字，但是会被分配一个新的`UID`，因此那么些共享的卷也会重新创建（旧数据无法保留）

### 4.2.2 Motivation for pods

通常一个服务由多个功能单元构成，各模块相互协作，而`Pod`就是这种多协作过程的模型。`Pod`通过提供一个高阶抽象来简化应用的部署、管理。`Pod`是部署，水平扩展和复制的最小单元

`Pod`允许内部的组件共享数据以及相互通信。在一个`Pod`中的所有组件共享同一个网络`Namespace`(`IP`和`port`)，他们之间可以通过`localhost`相互通信，因此在一个`Pod`中的所有组件需要共享`port`，同时，`Pod`也允许其组件与外部通信

`Pod`的`hostname`被设置为`Pod`的名字

### 4.2.3 Durability of pods (or lack thereof)

`Pod`并不是一个高可用的实体。`Pod`不会从调度失败、节点宕机或其他错误中恢复

通常情况下，用户不需要直接创建`Pod`，而应该使用`Controller`，`Controller`提供了一个集群层面上的自我修复能力，以及水平扩容能力和删除能力

`Pod`对外直接露出，其原因如下

1. 提供可插拔式的调度和控制方式
1. 支持`Pod-level`的操作，而不需要通过`Controller API`来代理
1. 解耦`Pod`生命周期与`Controller`生命周期
1. 解耦`Controller`和`Service`
1. 解耦`Kubelet-level`的功能与`cluster-level`的功能
1. 高可用性

### 4.2.4 Termination of Pods

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

`Kubernetes`允许强制删除`Pod`，强制删除意味着将该`Pod`从集群状态以及`etcd`中立即删除。当强制删除执行时，`Api server`不会等待`kubelet`确认删除`Pod`，而是直接将该`Pod`删除，这样一来，一个新的复用了原来名字的`Pod`就可以被立即创建。而那个被删除的`Pod`仍然会给定一个比较小的宽限期来进行上述删除操作。__尽量不要使用这种方式__

## 4.3 Pod Lifecycle

### 4.3.1 Pod phase

`Pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`phase`字段

`phase`是对`Pod`生命周期中的状态的高度抽象，仅包含以下几个值

1. __`Pending`__：该`Pod`已被`Kubernetes system`接管，但是`Container`尚未创建完毕。可能处于尚未被调度的状态，或者正在下载容器镜像
1. __`Running`__：所有`Container`已经启动完毕，并且至少有一个`Container`处于运行状态，或者处于启动或者重启的过程中
1. __`Succeeded`__：所有`Container`成功终止，且不会重启
1. __`Failed`__：至少有一个`Container`终止失败
1. __`Unkown`__：系统错误

可以通过如下命令查看`phase`

```sh
kubectl get pod -n <namespace> <pod-name> -o yaml
```

### 4.3.2 Pod conditions

`Pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`conditions`字段，该字段对应的值是一个`PodConditions`对象的数组

每个`PodConditions`对象包含如下字段

1. __`lastProbeTime`__：上一次进行状态监测的时刻
1. __`lastTransitionTime`__：上一次发生状态变更的时刻
1. __`message`__：状态变更的描述，一个`human-readable`的描述
1. __`reason`__：状态变更的原因，一个较为精确的描述
1. __`status`__：`True`、`False`、`Unknown`中的一个
1. __`type`__：以下几种可能值中的一个
  * `PodScheduled`：`Pod`已被调度到一个`node`上
  * `Ready`：`Pod`已经能够提供服务，应该被添加到`load balancing pool`中去 
  * `Initialized`：所有的`Init Container`已经执行完毕
  * `Unschedulable`：调度失败，可能原因是资源不足
  * `ContainersReady`：`Pod`中的所有`Container`已经就绪

### 4.3.3 Container probes

`probe`是`kubelet`对`Container`定期进行的诊断。为了实现诊断，`kubelet`通过调用一个`handler`来完成，该`handler`由容器实现，以下是三种`handler`的类型

1. `ExecAction`：在容器中执行一个命令，当命令执行成功（返回状态码是0）时，诊断成功
1. `TCPSocketAction`：通过`Container`的`IP`以及指定的`port`来进行`TCP`检测，当检测到`port`开启时，诊断成功
1. `HTTPGetAction`：通过`Container`的`IP`以及指定的`port`来进行`HTTP Get`检测，当`HTTP`返回码在200至400之间时，诊断成功

__诊断结果如下__

1. __`Success`__
1. __`Failure`__
1. __`Unknown`__

__`kubelet`可以对运行状态下的`Container`进行如下两种`probe`__

1. __`livenessProbe`__：检测`Container`是否存活（健康检查），若不存活，将杀死这个`Container`
1. __`readinessProbe`__：检测`Container`是否准备好提供服务，若检查不通过，那么会将这个`Pod`从`service`的`endpoint`列表中移除

__我们如何决定该使用`livenessProbe`还是`readinessProbe`__

* 如果我们的`Container`在碰到异常情况时本身就会宕机，那么我们就不需要`livenessProbe`，`kubelet`会自动根据`restartPolicy`采取相应的动作
* 如果我们想要在`probe`失败时杀死或者重启`Container`，那么，我们需要使用`livenessProbe`，同时将`restartPolicy`指定为`Always`或`OnFailure`模式
* 如果我们想要在`Pod`可读时才向其转发网络数据包，那么，我们需要使用`readinessProbe`
* 如果我们的`Container`需要读取大量数据，配置文件或者需要在启动时做数据迁移，那么需要`readinessProbe`
* 如果我们仅仅想要避免流量打到被删除的`Pod`上来，我们无需使用`readinessProbe`。在删除过程中，`Pod`会自动将自己标记为`unready`状态，无论`readinessProbe`是否存在

### 4.3.4 Pod readiness gate

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

### 4.3.5 Restart policy

`PodSpec`有一个`restartPolicy`字段，其可选值为`Always`、`OnFailure`、`Never`。默认值为`Always`。`restartPolicy`对`Pod`中的所有`Container`都会生效。`restartPolicy`仅针对在同一个`Node`中重启`Container`。多次启动之间的时间间隔以指数方式增长（10s、20s、40s...），最多不超过5分钟。在成功重启后10分钟后，时间间隔会恢复默认值

### 4.3.6 Pod lifetime

通常情况下，`Pod`一旦创建就会永远存在，直至被某人或`Controller`销毁。唯一例外就是，当`Pod`的`status.phase`字段为`Succeeded`或`Failed`且超过一段时间后（该时间由`terminated-pod-gc-threshold`设定），该`Pod`会被自动销毁

有三种类型的`Controller`可供选择

1. 使用`Job`，这类`Pod`预期会终止，例如`batch computations`。此时`restartPolicy`通常设置为`OnFailure`或`Never`
1. 使用`ReplicationController`、`ReplicaSet`、`Deployment`，这类`Pod`预期会一直运行，例如`web servers`。此时`restartPolicy`通常设置为`Always`
1. 使用`DaemonSet`，这类`Pod`通常每台机器都会运行一个

这三种类型的`Controller`都含有一个`PodTemplate`。通常，创建一个`Controller`，然后利用它来创建`Pod`是最常规的选择，而不是自己创建`Pod`，因为`Pod`自身是不具有错误恢复能力的，但是`Controller`具备该能力

当某个`Node`宕机或者失联后，`Kubernetes`会将位于这些`Node`上的`Pod`全部标记为`Failed`

## 4.4 Init Containers

### 4.4.1 Understanding Init Containers

一个`Pod`中可以运行一个或多个`Container`，同时，一个`Pod`中也可以运行一个或多个`Init Container`（`Init Container`会优先于`Container`运行）

`Init Container`具有如下特性

1. 他们总会结束运行，即并不是一个常驻进程
1. `Init Container`总是一个接一个地运行，上一个`Init Container`运行结束后，下一个`Init Container`才开始运行

如果`Init Container`执行失败，`Kubernetes`会重启`Pod`直至`Init Container`成功执行（至于`Pod`是否重启依赖于`restartPolicy`）

为了将一个`Container`指定为`Init Container`，我们需要在`PodSpec`中添加`initContainers`字段

`Init Container`支持所有普通`Container`的字段，唯独不支持`readiness probe`，因为`Init Container`在`ready`之前已经结束了

### 4.4.2 Detailed behavior

在`Pod`的启动过程中，在网络以及磁盘初始化后，`Init Container`以配置的顺序启动。`Init Container`会一个接一个地启动，且只有前一个启动成功后，后一个才会启动。如果`Init Container`启动失败，会根据`restartPolicy`来决定是否重新启动。特别地，如果`Pod`的`restartPolicy`被设置为`Always`，那么对于`Init Container`而言，就为`OnFailure`

如果`Pod`重启（可能仅仅指重新启动container？并不是销毁`Pod`后再创建一个新的`Pod`），那么所有的`Init Container`都会重新执行

## 4.5 Pod Preset

`Pod Preset`用于在`Pod`创建时注入一些运行时的依赖项，我们可以使用`Label Selector`来指定需要注入的`Pod`

__原理__：Kubernetes提供了一个准入控制器（`PodPreset`）。在创建`Pod`时，系统会执行以下操作：

1. 获取所有的`PodPreset`
1. 检查正在创建的`Pod`的`Label`是否匹配某个或某些`PodPreset`的`Label Selector`
1. 将匹配的`PodPreset`所指定的资源注入到待创建的`Pod`中去
1. 如果发生错误，抛出一个事件，该事件记录了错误信息，然后以纯净的方式创建`Pod`（无视所有`PodPreset`中的资源）
1. 修改`Pod`的`status`字段，记录其被`PodPreset`修改过。描述信息如下
    * `podpreset.admission.kubernetes.io/podpreset-<pod-preset name>: "<resource version>".`

一个`Pod Preset`可以应用于多个`Pod`，同样，一个`Pod`也可以关联多个`Pod Preset`

## 4.6 Disruptions

### 4.6.1 Voluntary and Involuntary Disruptions

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

### 4.6.2 Dealing with Disruptions

下列方法可以减轻`involuntary disruption`造成的影响

1. 确保`Pod`只拿它需要的资源
1. 复制应用，以获得高可用性
1. 将应用副本分别部署到不同的区域的节点上，以获得更高的可用性

### 4.6.3 How Disruption Budgets Work

应用`Owner`可以为每个应用创建一个`PodDisruptionBudget(PDB)`对象。`PDB`限制了应用同时缩容的最大数量，即保证应用在任何时候都有一定数量的`Pod`在运行

当集群管理员利用`kubectl drains`命令将某个`Node`移除时，`Kubernetes`会尝试移除该`Node`上的所有`Pod`，但是这个移除请求可能会被拒绝，然后`Kubernetes`会周期性的重试，直至所有`Pod`都被终结或者超过配置的时间（超过后，直接发送`KILL signal`）

`PDB`无法阻止`involuntary disruptions`。`Pod`由于灰度升级造成的`voluntary disruption`可以被`PDB`管控。但是`Controller`灰度升级不会被`PDB`管控

## 4.7 参考

* [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
* [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
* [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
* [Pod Preset](https://kubernetes.io/docs/concepts/workloads/pods/podpreset/)
* [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

# 5 Controller

## 5.1 ReplicaSet

`ReplicaSet`是新一代的`Replication Controller`，`ReplicaSet`与`Replication Controller`之间的唯一区别就是`select`的方式不同。`ReplicaSet`支持`set-based selector`，而`Replication Controller`仅支持`equality-based selector`

### 5.1.1 How to use a ReplicaSet

大部分支持`Replication Controller`的`kubectl`命令都支持`ReplicaSet`，其中一个例外就是`rolling-update`命令。如果我们想要进行灰度升级，更推荐使用`Deploymenet`

尽管`ReplicaSet`可以独立使用，但到目前为止，它主要的用途就是为`Deployment`提供一种机制---编排`Pod`创建、删除、更新

### 5.1.2 When to use a ReplicaSet

`ReplicaSet`保证了在任何时候，都运行着指定数量的`Pod`副本。然而，`Deployment`是一个更高阶的概念，它管理着`ReplicaSet`、提供声明式的`Pod`升级方式，以及一些其他的特性。因此，推荐使用`Deployment`而不是直接使用`ReplicaSet`，除非我们要使用自定义的升级策略或者根本不需要升级

### 5.1.3 Writing a ReplicaSet Spec

__示例__

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
1. `.metadata.labels`: `ReplicaSet`还允许拥有自己的`Label`，通常来说，`.spec.template.metadata.labels`与`.metadata.labels`是一致的。同样，它们也可以不一致，__但要注意的是，`.metadata.labels`与`.spec.selector`无关__
1. `.spec.replicas`: 该字段指定了`Pod`副本的数量，默认为1

## 5.2 ReplicationController

### 5.2.1 How a ReplicationController Works

### 5.2.2 Writing a ReplicationController Spec

## 5.3 Deployments

## 5.4 DaemonSet

## 5.5 Garbage Collection

## 5.6 TTL Controller for Finished Resources

## 5.7 Jobs - Run to Completion

## 5.8 CronJob

# 6 Network

## 6.1 Overview

首先，我们来明确一下，Kubernetes面临的网络问题

1. __Highly-coupled Container-to-Container communications__：高耦合的`Container`之间的网络通信，通过`pods`以及`localhost`通信来解决
1. __Pod-to-Pod communications__：本小节将详细展开说明
1. __Pod-to-Service communications__：通过`services`来解决
1. __External-to-Service communications__：通过`services`来解决

## 6.2 Docker Model

我们先来回顾一下Docker的网络模型，这对于理解Kubernetes的网络模型是很有必要的。__在默认情况下，`Docker`利用`host-private networking`，`Docker`创建了一个虚拟网桥（virtual bridge），默认为`docker0`__。对于`Docker`创建的每个`Container`都会有一个连接到网桥的虚拟以太网卡（virtual Ethernet device）`veth`，从`Container`内部来看，`veth`就被映射成了`eth0`网卡

在这种网络模型下，只要位于同一个物理机上（或者同一个虚拟网桥上），所有的`Container`之间可以进行通信。但是位于不同物理机上的`Container`是无法进行通信的

为了让`Container`可以跨`node`进行交互，必须为它们分配一个宿主物理机的`ip`。这样一来，我们就需要付出额外的精力维护`ip`以及`port`

## 6.3 Kubernetes model

`Kubernetes`要求网络模型必须满足如下条件

1. 所有`Container`之间的通信不能依赖NAT
1. 所有`node`与`Container`之间的通信不能依赖NAT
1. 某个`Container`在内部、外部看到的`ip`一致

这种模式不仅总体上不那么复杂，而且主要与Kubernetes希望将应用程序从VM轻松移植到容器的愿望兼容

到目前为止，都在讨论`Container`，但事实上，`Kubernetes`在`Pod`范围上使用`ip`地址，因此，在一个`Pod`内的所有`Container`共享网络命名空间（network namespaces），当然包括ip地址。这意味着，在一个`Pod`内的`Container`可以通过`localhost`与其他`Container`进行通信。__这称为“IP-per-pod”模式，在这种模式下，一个`Pod`需要有一个`pod contaner`来管理网络命名空间，其他`app container`利用`Docker`的`--net=container:<id>`参数来加入这个网络命名空间即可__

## 6.4 Kubernetes networking model implements

__Kubernetes的网络模型有很多种实现方式，包括但不仅限如下几种__

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

# 7 Service

## 7.1 参考

* [Services](https://kubernetes.io/docs/concepts/services-networking/service/)

# 8 Sequence

```plantuml
participant Master
participant NodeA
participant FlannelNetwork
participant NodeB

NodeA->Master: ServiceName
Master-->NodeA: ClasterIP
NodeA->NodeA: Who can provide services?
NodeA->NodeA: Flannel module record the ClasterIp, and transalate it to flannelIp
NodeA->NodeB: request with flannelIp
NodeB->NodeB: resolve flannelIp to ClasterIp
NodeB-->NodeA: response
```

# 9 参考

* [英文文档1](https://kubernetes.io/docs/concepts/)
* [中文文档1](http://docs.kubernetes.org.cn/)
* [中文文档2](https://www.kubernetes.org.cn/kubernetes%E8%AE%BE%E8%AE%A1%E6%9E%B6%E6%9E%84)
* [Borg、Omega 和 Kubernetes：谷歌十几年来从这三个容器管理系统中得到的经验教训](https://segmentfault.com/a/1190000004667502)
* [Kubernetes核心概念总结](http://www.cnblogs.com/zhenyuyaodidiao/p/6500720.html)
