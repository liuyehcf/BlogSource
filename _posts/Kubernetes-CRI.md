---
title: Kubernetes-CRI
date: 2021-02-18 17:07:27
tags: 
- 摘录
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 容器

## 1.1 容器发展史

![container_timeline](/images/Kubernetes-CRI/container_timeline.jpeg)

## 1.2 docker组件介绍

**docker（`/usr/bin/docker`）**：在早期版本中（`1.11.x`之前），docker的所有功能都用这一个二进制完成，同时充当`docker-cli`以及`docker-daemon`。`1.11.x`版本之后，docker只充当`docker-cli`这一角色

**dockerd（`/usr/bin/dockerd`）**：以`Docker Engine API`对外提供服务，可以通过三类socket进行API调用，分别是：`unix`、`tcp`、`fd`（默认用的是`unix`。实际上，`dockerd`只是一个中间层，容器、镜像的生命周期管理动作，实际上是由`containerd`完成的，`dockerd`与`containerd`之间通过`grpc`通信

**containerd（`/usr/bin/docker-containerd`）**：`containerd`是`1.11.x`引入的组件，是`OCI`规范的标准实现。功能大致包括

1. 镜像管理
1. 容器管理（实际上利用`RunC`）
1. 存储管理
1. 网络管理
1. 命名空间管理
1. ...

**RunC（`/usr/bin/docker-runc`）**：与其他组件不同，`RunC`是个可执行程序（提供创建和运行容器的cli工具），而并非一个常驻进程。它的主要职责就是运行容器。`RunC`直接与容器所依赖的`cgroup/namespace`等进行交互，负责为容器配置`cgroup/namespace`等启动容器所需的环境，创建启动容器的相关进程

**containerd-ctr（`/usr/bin/docker-containerd-ctr`）**：可以直接与`containerd`交互的客户端，类似于`docker-cli`和`dockerd`之间的关系

**containerd-shim（`/usr/bin/docker-containerd-shim`）**：`containerd`并不直接操作容器，而是通过`containerd-shim`来间接地操作容器或与容器通信。从进程关系上讲，`containerd-shim`进程由`containerd`进程拉起，容器进程由`containerd-shim`进程拉起（每个容器进程都会对应一个独立的`containerd-shim`进程）。`containerd-shim`主要起到以下作用：

1. 由于`containerd-shim`与容器是父子进程关系，因此可以拿到容器的`stdout`、`stderr`，可以将容器的`stdin`、`stdout`转存到日志文件中（`/var/lib/docker/containers/<容器id>/<容器id>-json.log`）。与此对应的功能是`docker logs <container>`或`kubectl logs <pod> -c <container>`
1. 由于`containerd-shim`与容器是父子进程关系，因此可以拿到容器的`stdin`、`stdout`、`stderr`，通过socket将容器的`stdin`、`stdout`、`stderr`暴露给外界，以提供流式传输的功能。与此对应的功能是`docker exec -it <container>`或`kubectl exec -it <pod>`
1. 用于追踪容器的`exit code`。在`detached`模式下，`RunC`在启动完容器后便退出了，此时容器进程的父子进程关系将会调整。如果没有`containerd-shim`，那么容器的父进程将会变成`containerd`，如果`containerd`重启了或意外退出了，那么容器的父进程又会进一步变成`pid = 1`的进程，于是容器的状态信息将会全部丢失；引入`containerd-shim`后，容器的父进程就变成了`containerd-shim`，而`containerd-shim`会等待容器运行直至退出，从而能够捕获到容器的`exit code`

## 1.3 OCI

以下是[维基百科](https://en.wikipedia.org/wiki/Open_Container_Initiative)对于`OCI`的定义：

> The Open Container Initiative (OCI) is a Linux Foundation project to design open standards for operating-system-level virtualization, most importantly Linux containers. There are currently two specifications in development and in use: Runtime Specification (runtime-spec) and the Image Specification (image-spec).

> OCI develops runc, a container runtime that implements their specification and serves as a basis for other higher-level tools. runC was first released in July 2015 as version 0.0.1

翻译过来就是：

> `OCI`是Linux基础项目，旨在为操作系统层级的虚拟化技术（最主要的就是Linux容器）设计开放标准。当前有两个规范正在开发和使用中：运行时规范（`runtime-spec`）和映像规范（`image-spec`）

> `OCI`开发了`Runc`，它一个容器运行时，该运行时实现了`OCI`规范，并作为其他高级工具的基础。`Runc`于2015年7月首次发布，版本为0.0.1。

# 2 CRI

`CRI`在`Kubernetes 1.5`中引入，在此之前，`Kubernetes`与`docker`强耦合（在代码中直接硬编码调用`docker-api`）。虽然`docker`是容器领域中最受瞩目的项目，但它并不是容器领域中的唯一选择，不同的容器实现方案都有其各自的优势，`Kubernetes`为了在容器运行时的选择上更具灵活性，因此需要与`docker`进行解耦，而软件如何解耦？那就加一层接口咯，这层接口就叫做`CRI`。如此一来，`docker`就是满足`CRI`的一个实现，只要各个容器方案都实现了`CRI`接口，`Kubernetes`就能完成容器运行时的自由切换

**整体架构大致如下（图中仅包含部分CRI实现，以及部分OCI实现）**

![relationship](/images/Kubernetes-CRI/relationship.png)

**其中**

* `cri-o`是由`Kubernetes`孵化的项目，天然支持`CRI`
* `cri-containerd`是为了在不改造`containerd`的前提下，让`containerd`支持`CRI`规范
* `docker-shim`是为了在不改造`docker`的前提下，让`docker`支持`CRI`规范

`Kubernetes`对于`CRI`的定义，可以参考[kubernetes/cri-api](https://github.com/kubernetes/cri-api)，主要包含两部分`RuntimeService`以及`ImageService`

```go
// Runtime service defines the public APIs for remote container runtimes
service RuntimeService {
    // Version returns the runtime name, runtime version, and runtime API version.
    rpc Version(VersionRequest) returns (VersionResponse) {}

    // RunPodSandbox creates and starts a pod-level sandbox. Runtimes must ensure
    // the sandbox is in the ready state on success.
    rpc RunPodSandbox(RunPodSandboxRequest) returns (RunPodSandboxResponse) {}
    // StopPodSandbox stops any running process that is part of the sandbox and
    // reclaims network resources (e.g., IP addresses) allocated to the sandbox.
    // If there are any running containers in the sandbox, they must be forcibly
    // terminated.
    // This call is idempotent, and must not return an error if all relevant
    // resources have already been reclaimed. kubelet will call StopPodSandbox
    // at least once before calling RemovePodSandbox. It will also attempt to
    // reclaim resources eagerly, as soon as a sandbox is not needed. Hence,
    // multiple StopPodSandbox calls are expected.
    rpc StopPodSandbox(StopPodSandboxRequest) returns (StopPodSandboxResponse) {}
    // RemovePodSandbox removes the sandbox. If there are any running containers
    // in the sandbox, they must be forcibly terminated and removed.
    // This call is idempotent, and must not return an error if the sandbox has
    // already been removed.
    rpc RemovePodSandbox(RemovePodSandboxRequest) returns (RemovePodSandboxResponse) {}
    // PodSandboxStatus returns the status of the PodSandbox. If the PodSandbox is not
    // present, returns an error.
    rpc PodSandboxStatus(PodSandboxStatusRequest) returns (PodSandboxStatusResponse) {}
    // ListPodSandbox returns a list of PodSandboxes.
    rpc ListPodSandbox(ListPodSandboxRequest) returns (ListPodSandboxResponse) {}

    // CreateContainer creates a new container in specified PodSandbox
    rpc CreateContainer(CreateContainerRequest) returns (CreateContainerResponse) {}
    // StartContainer starts the container.
    rpc StartContainer(StartContainerRequest) returns (StartContainerResponse) {}
    // StopContainer stops a running container with a grace period (i.e., timeout).
    // This call is idempotent, and must not return an error if the container has
    // already been stopped.
    // The runtime must forcibly kill the container after the grace period is
    // reached.
    rpc StopContainer(StopContainerRequest) returns (StopContainerResponse) {}
    // RemoveContainer removes the container. If the container is running, the
    // container must be forcibly removed.
    // This call is idempotent, and must not return an error if the container has
    // already been removed.
    rpc RemoveContainer(RemoveContainerRequest) returns (RemoveContainerResponse) {}
    // ListContainers lists all containers by filters.
    rpc ListContainers(ListContainersRequest) returns (ListContainersResponse) {}
    // ContainerStatus returns status of the container. If the container is not
    // present, returns an error.
    rpc ContainerStatus(ContainerStatusRequest) returns (ContainerStatusResponse) {}
    // UpdateContainerResources updates ContainerConfig of the container.
    rpc UpdateContainerResources(UpdateContainerResourcesRequest) returns (UpdateContainerResourcesResponse) {}
    // ReopenContainerLog asks runtime to reopen the stdout/stderr log file
    // for the container. This is often called after the log file has been
    // rotated. If the container is not running, container runtime can choose
    // to either create a new log file and return nil, or return an error.
    // Once it returns error, new container log file MUST NOT be created.
    rpc ReopenContainerLog(ReopenContainerLogRequest) returns (ReopenContainerLogResponse) {}

    // ExecSync runs a command in a container synchronously.
    rpc ExecSync(ExecSyncRequest) returns (ExecSyncResponse) {}
    // Exec prepares a streaming endpoint to execute a command in the container.
    rpc Exec(ExecRequest) returns (ExecResponse) {}
    // Attach prepares a streaming endpoint to attach to a running container.
    rpc Attach(AttachRequest) returns (AttachResponse) {}
    // PortForward prepares a streaming endpoint to forward ports from a PodSandbox.
    rpc PortForward(PortForwardRequest) returns (PortForwardResponse) {}

    // ContainerStats returns stats of the container. If the container does not
    // exist, the call returns an error.
    rpc ContainerStats(ContainerStatsRequest) returns (ContainerStatsResponse) {}
    // ListContainerStats returns stats of all running containers.
    rpc ListContainerStats(ListContainerStatsRequest) returns (ListContainerStatsResponse) {}

    // UpdateRuntimeConfig updates the runtime configuration based on the given request.
    rpc UpdateRuntimeConfig(UpdateRuntimeConfigRequest) returns (UpdateRuntimeConfigResponse) {}

    // Status returns the status of the runtime.
    rpc Status(StatusRequest) returns (StatusResponse) {}
}

// ImageService defines the public APIs for managing images.
service ImageService {
    // ListImages lists existing images.
    rpc ListImages(ListImagesRequest) returns (ListImagesResponse) {}
    // ImageStatus returns the status of the image. If the image is not
    // present, returns a response with ImageStatusResponse.Image set to
    // nil.
    rpc ImageStatus(ImageStatusRequest) returns (ImageStatusResponse) {}
    // PullImage pulls an image with authentication config.
    rpc PullImage(PullImageRequest) returns (PullImageResponse) {}
    // RemoveImage removes the image.
    // This call is idempotent, and must not return an error if the image has
    // already been removed.
    rpc RemoveImage(RemoveImageRequest) returns (RemoveImageResponse) {}
    // ImageFSInfo returns information of the filesystem that is used to store images.
    rpc ImageFsInfo(ImageFsInfoRequest) returns (ImageFsInfoResponse) {}
}
```

# 3 参考

* [Docker的历史与发展](https://www.jianshu.com/p/4c9ff1619e96)
* [Kubernetes 容器运行时演进](https://zhuanlan.zhihu.com/p/73728920)
* [如何为Kubernetes选择合适的容器运行时？](https://www.zhihu.com/question/324124344)
* [40 年回顾，一文读懂容器发展史](https://www.infoq.cn/article/ss6sitklgolexqp4umr5)
* [Runtime 技术概览](http://k8s.cn/index.php/2018/05/21/799/)
* [Dockershim Deprecation: Is Docker Truly out of Game?](https://kubesphere.io/blogs/dockershim-out-of-kubernetes/)
* [containerd-doc](https://containerd.io/)
* [kubernetes-blog](https://kubernetes.io/blog/)
* [揭秘开放容器标准（OCI）规范](http://www.dockerone.com/article/2533)
* [docker进程模型，架构分析](https://segmentfault.com/a/1190000011294361)
* [Implementing Container Runtime Shim: runc](https://iximiuz.com/en/posts/implementing-container-runtime-shim/)
* [Docker components explained](http://alexander.holbreich.org/docker-components-explained/)
* [OCI,CRI到kubernetes runtime](https://www.jianshu.com/p/c7748893ab00)
* [About the Open Container Initiative](https://opencontainers.org/about/overview/)
* [OCI,CRI,CRI-O,Containerd 名词解释](https://blog.csdn.net/weixin_40864891/article/details/86655846)
* [Introducing Container Runtime Interface (CRI) in Kubernetes](https://kubernetes.io/blog/2016/12/container-runtime-interface-cri-in-kubernetes/)
* [关于Kubernetes废弃内置docker CRI功能的说明](https://zhuanlan.zhihu.com/p/332603285)
* [K8s、CRI与container](https://zhuanlan.zhihu.com/p/102897620)
* [CRI: the Container Runtime Interface](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-node/container-runtime-interface.md)
* [kubernetes/cri-api](https://github.com/kubernetes/cri-api)
