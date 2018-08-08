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

## 1.1 Master

## 1.2 Node

# 2 Kubernetes Object

`Kubernetes Object`作为持久化的实体，存在于`Kubernetes`系统中。每个`Kubernetes Object`都至少包含两个`object field`，即`spec`以及`status`

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

## 2.1 参考

* [Understanding Kubernetes Objects](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/)
* [Imperative Management of Kubernetes Objects Using Configuration Files](https://kubernetes.io/docs/concepts/overview/object-management-kubectl/imperative-config/)

# 3 Network

## 3.1 Overview

首先，我们来明确一下，Kubernetes面临的网络问题

1. __Highly-coupled Container-to-Container communications__：高耦合的`container`之间的网络通信，通过`pods`以及`localhost`通信来解决
1. __Pod-to-Pod communications__：本小节将详细展开说明
1. __Pod-to-Service communications__：通过`services`来解决
1. __External-to-Service communications__：通过`services`来解决

## 3.2 Docker Model

我们先来回顾一下Docker的网络模型，这对于理解Kubernetes的网络模型是很有必要的。__在默认情况下，`Docker`利用`host-private networking`，`Docker`创建了一个虚拟网桥（virtual bridge），默认为`docker0`__。对于`Docker`创建的每个`container`都会有一个连接到网桥的虚拟以太网卡（virtual Ethernet device）`veth`，从`container`内部来看，`veth`就被映射成了`eth0`网卡

在这种网络模型下，只要位于同一个物理机上（或者同一个虚拟网桥上），所有的`container`之间可以进行通信。但是位于不同物理机上的`container`是无法进行通信的

为了让`container`可以跨`node`进行交互，必须为它们分配一个宿主物理机的`ip`。这样一来，我们就需要付出额外的精力维护`ip`以及`port`

## 3.3 Kubernetes model

`Kubernetes`要求网络模型必须满足如下条件

1. 所有`container`之间的通信不能依赖NAT
1. 所有`node`与`container`之间的通信不能依赖NAT
1. 某个`container`在内部、外部看到的`ip`一致

这种模式不仅总体上不那么复杂，而且主要与Kubernetes希望将应用程序从VM轻松移植到容器的愿望兼容

到目前为止，都在讨论`container`，但事实上，`Kubernetes`在`pod`范围上使用`ip`地址，因此，在一个`pod`内的所有`container`共享网络命名空间（network namespaces），当然包括ip地址。这意味着，在一个`pod`内的`container`可以通过`localhost`与其他`container`进行通信。__这称为“IP-per-pod”模式，在这种模式下，一个`pod`需要有一个`pod contaner`来管理网络命名空间，其他`app container`利用`Docker`的`--net=container:<id>`参数来加入这个网络命名空间即可__

## 3.4 Kubernetes networking model implements

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

## 3.5 参考

* [Cluster Networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)

# 4 Pods

## 4.1 Overview

`Pod`是Kubernetes中，用户能够创建或部署的最小单元，一个`Pod`代表了一个进程（可能是高耦合的一组进程）。`Pod`封装了以下资源

1. `container`：一个或多个应用容器
1. `volume`：存储资源
1. `IP`：一个pod会被分配一个IP，在所属的namespace下唯一
1. `options`：控制容器运行的参数

`Pod`自身并不会自我恢复。也就是说，当`Pod`部署失败或者挂了，这个`Pod`的生命周期就结束了。__Kubernetes用一个高层次的概念，即`Controller`，来管理`Pod`的生命周期，包括`Pod`的创建、部署、副本、恢复等工作__

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

## 4.2 Pod（未完成）

`pod`是一个或一组`container`，具有共享存储/网络，以及如何运行容器的规范。 `pod`中的`container`始终位于同一位置并共同调度，并在共享上下文中运行

* `pod`中的共享上下文包括：`Linux namespaces`，`cgroups`，以及其他可能的隔离因素

在一个`pod`中的所有`container`共享一个`IP`地址，以及端口空间，`container`之间可以通过`localhost`进行通信，或者其他`IPC`方式。不同`pod`中的`container`具有不同的`IP`地址，因此，仅能通过`pod IP`进行通信

### 4.2.1 Motivation

`Kubernetes`通过引入`pod`来简化应用程序的部署和管理，`pod`用作部署、水平扩展和复制的单元。对于`pod`中的容器，资源共享、依赖管理、生命周期控制将会自动处理

## 4.3 Pod Lifecycle（未完成）

### 4.3.1 Pod phase

`pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`phase`字段

`phase`是对`pod`生命周期中的状态的高度抽象，仅包含以下几个值

1. __`Pending`__：该`pod`已被`Kubernetes system`接管，但是`container`尚未创建完毕，可能正在拉取镜像
1. __`Running`__：所有`container`已经启动完毕，并且至少有一个`container`处于运行状态
1. __`Succeeded`__：所有`container`成功终止
1. __`Failed`__：至少有一个`container`终止失败
1. __`Unkown`__：系统错误

可以通过如下命令查看`phase`

```sh
kubectl get pod -n <namespace> <pod-name> -o yaml
```

### 4.3.2 Pod conditions

`pod`的`status`字段是一个`PodStatus`对象，该对象包含一个`conditions`字段，该字段对应的值是一个`PodConditions`对象的数组

每个`PodConditions`对象包含如下字段

1. __`lastProbeTime`__：上一次进行状态监测的时刻
1. __`lastTransitionTime`__：上一次发生状态变更的时刻
1. __`message`__：状态变更的描述，一个`human-readable`的描述
1. __`reason`__：状态变更的原因，一个较为精确的描述
1. __`status`__：`True`、`False`、`Unknown`中的一个
1. __`type`__：以下几种可能值中的一个
  * `PodScheduled`：`pod`已被调度到一个`node`上
  * `Ready`：`pod`已经能够提供服务，应该被添加到`load balancing pool`中去 
  * `Initialized`：所有的`init container`已经执行完毕
  * `Unschedulable`：调度失败，可能原因是资源不足
  * `ContainersReady`：`pod`中的所有`container`已经就绪

### 4.3.3 Container probes

`probe`是`kubelet`对`container`定期进行的诊断。为了实现诊断，`kubelet`通过调用一个`handler`来完成，该`handler`由容器实现，以下是三种`handler`的类型

1. `ExecAction`：在容器中执行一个命令，当命令执行成功（返回状态码是0）时，诊断成功
1. `TCPSocketAction`：通过`container`的`IP`以及指定的`port`来进行`TCP`检测，当检测到`port`开启时，诊断成功
1. `HTTPGetAction`：通过`container`的`IP`以及指定的`port`来进行`HTTP Get`检测，当`HTTP`返回码在200至400之间时，诊断成功

__诊断结果如下__

1. __`Success`__
1. __`Failure`__
1. __`Unknown`__

__`kubelet`可以对运行状态下的`container`进行如下两种`probe`__

1. __`livenessProbe`__：检测`container`是否存活（健康检查），若不存活，将杀死这个`container`
1. __`readinessProbe`__：检测`container`是否准备好提供服务，若检查不通过，那么会将这个`pod`从`service`的`endpoint`列表中移除

__restartPolicy__：`PodSpec Object`含有一个`restartPolicy`字段，其值为`Always`、`OnFailure`、`Never`，其中`Always`是默认值。当`container`意外终止时，`kubelet`会根据`restartPolicy`来选择是否重启`container`

### 4.3.4 Pod lifetime

通常情况下，`pod`一旦创建就会永远存在，直至被某人销毁。唯一例外就是，当`pod`的`status.phase`字段为`Succeeded`或`Failed`且超过一段时间后（该时间由`terminated-pod-gc-threshold`设定），该`pod`会被自动销毁

有三种类型的`controller`可供选择

1. 使用`Job`，这类`pod`预期会终止，例如`batch computations`。此时`restartPolicy`通常设置为`OnFailure`或`Never`
1. 使用`ReplicationController`、`ReplicaSet`、`Deployment`，这类`pod`预期会一直运行，例如`web servers`。此时`restartPolicy`通常设置为`Always`
1. 使用`DaemonSet`，这类`pod`通常每台机器都会运行一个

## 4.4 Init Containers

一个`pod`中可以运行一个或多个`container`，同时，一个`pod`中也可以运行一个或多个`init container`（`init container`会优先于`container`运行）

`init container`具有如下特性

1. 他们总会结束运行，即并不是一个常驻进程
1. `init container`总是一个接一个地运行，上一个`init container`运行结束后，下一个`init container`才开始运行

如果`init container`执行失败，`Kubernetes`会重启`pod`直至`init container`成功执行（至于`pod`是否重启依赖于`restartPolicy`）

`init container`支持所有普通`container`的字段，唯独不支持`readiness probe`，因为`init container`在`ready`之前已经结束了

## 4.5 Pod Preset

`Pod Preset`用于在`pod`创建时注入一些运行时的依赖项，我们可以使用`label selector`来指定需要注入的`pod`

__原理__：Kubernetes提供了一个准入控制器（`PodPreset`）。在创建`pod`时，系统会执行以下操作：

1. 获取所有的`PodPreset`
1. 检查正在创建的`pod`是否匹配某个或某些`PodPreset`的`label selectors`
1. 将匹配的`PodPreset`所指定的资源注入到待创建的`pod`中去
1. 修改`pod`的`status`字段，记录其被`PodPreset`修改过。描述信息如下
    * `podpreset.admission.kubernetes.io/podpreset-<pod-preset name>: "<resource version>".`

一个`Pod Preset`可以应用于多个`pod`，同样，一个`pod`也可以关联多个`Pod Preset`

## 4.6 参考

* [Pod Overview](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/)
* [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod/)
* [Pod Lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
* [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
* [Pod Preset](https://kubernetes.io/docs/concepts/workloads/pods/podpreset/)
* [Disruptions](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/)

# 5 Service

## 5.1 参考

* [Services](https://kubernetes.io/docs/concepts/services-networking/service/)

# 6 参考

* [英文文档1](https://kubernetes.io/docs/concepts/)
* [中文文档1](http://docs.kubernetes.org.cn/)
* [中文文档2](https://www.kubernetes.org.cn/kubernetes%E8%AE%BE%E8%AE%A1%E6%9E%B6%E6%9E%84)
* [Borg、Omega 和 Kubernetes：谷歌十几年来从这三个容器管理系统中得到的经验教训](https://segmentfault.com/a/1190000004667502)
