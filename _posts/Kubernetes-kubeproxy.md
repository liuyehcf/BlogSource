---
title: Kubernetes-kubeproxy
date: 2019-12-23 14:43:11
tags: 
- 原创
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 单副本

__deployment（hello-world-deployment.yml）__

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
  labels:
    mylabel: label_hello_world_deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      mylabel: label_hello_world
  template:
    metadata:
      labels:
        mylabel: label_hello_world
    spec:
      containers:
      - name: hello-world
        image: registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo:v1
        imagePullPolicy: IfNotPresent
        command: ["java", "-jar", "lib/spring-boot-1.0-SNAPSHOT.jar"]
        ports:
        - containerPort: 8080
```

__service（hello-world-service.yml）__

```yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  ports:
    - protocol: TCP
      port: 4000
      targetPort: 8080
      nodePort: 30001
  selector:
    mylabel: label_hello_world
  type: NodePort
```

创建`deployment`以及`service`

```sh
[root@k8s-master ~]$ kubectl apply -f hello-world-service.yml
#-------------------------output-------------------------
service/hello-world-service created
#-------------------------output-------------------------

[root@k8s-master ~]$ kubectl apply -f hello-world-deployment.yml
#-------------------------output-------------------------
deployment.apps/hello-world-deployment created
#-------------------------output-------------------------
```

查找一下该pod部署在哪个node上

```sh
[root@k8s-master ~]$ kubectl get pods -o wide
#-------------------------output-------------------------
NAME                                     READY   STATUS    RESTARTS   AGE    IP            NODE         NOMINATED NODE   READINESS GATES
hello-world-deployment-7db4ffd7b-pg5ht   1/1     Running   0          100s   10.244.3.81   k8s-node-2   <none>           <none>
#-------------------------output-------------------------
```

发现，应用部署在`k8s-n-2`上，查看`k8s-n-1`节点上的`iptables`规则，用`30001`作为条件过滤

```sh
[root@k8s-node-2 ~]$ iptables-save | grep '30001'
#-------------------------output-------------------------
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
#-------------------------output-------------------------
```

我们找到了名为`KUBE-NODEPORTS`的`Chain`的两条规则，继续用`KUBE-NODEPORTS`寻找上游`Chain`

```sh
[root@k8s-node-2 ~]$ iptables-save | grep 'KUBE-NODEPORTS'
#-------------------------output-------------------------
:KUBE-NODEPORTS - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
#-------------------------output-------------------------
```

我们找到了名为`KUBE-SERVICES`的`Chain`的一条规则，继续用`KUBE-SERVICES`寻找上游`Chain`

```sh
[root@k8s-node-2 ~]$ iptables-save | grep 'KUBE-SERVICES'
#-------------------------output-------------------------
:KUBE-SERVICES - [0:0]
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.108.160.127/32 -p tcp -m comment --comment "kube-system/tiller-deploy:tiller cluster IP" -m tcp --dport 44134 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.108.160.127/32 -p tcp -m comment --comment "kube-system/tiller-deploy:tiller cluster IP" -m tcp --dport 44134 -j KUBE-SVC-K7J76NXP7AUZVFGS
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.106.183.112/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.106.183.112/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
:KUBE-SERVICES - [0:0]
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
#-------------------------output-------------------------
```

我们发现，`PREROUTING`、`INPUT`、`FORWARD`、`OUTPUT`为`KUBE-SERVICES`的上游`Chain`

接着我们回到`Chain KUBE-NODEPORTS`的规则，继续往下游分析，查看`Chain KUBE-SVC-5MRENC7Q6ZQR6GKR`

```sh
[root@k8s-node-2 ~]$ iptables-save | grep 'KUBE-SVC-5MRENC7Q6ZQR6GKR'
#-------------------------output-------------------------
:KUBE-SVC-5MRENC7Q6ZQR6GKR - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES -d 10.106.183.112/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-JNUJINTC6VOLRDUD
#-------------------------output-------------------------
```

找到了一条规则，该规则指向了另一个`Chain KUBE-SEP-JNUJINTC6VOLRDUD`，继续往下查看

```sh
[root@k8s-node-2 ~]$ iptables-save | grep 'KUBE-SEP-JNUJINTC6VOLRDUD'
#-------------------------output-------------------------
:KUBE-SEP-JNUJINTC6VOLRDUD - [0:0]
-A KUBE-SEP-JNUJINTC6VOLRDUD -s 10.244.3.81/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-JNUJINTC6VOLRDUD -p tcp -m tcp -j DNAT --to-destination 10.244.3.81:8080
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-JNUJINTC6VOLRDUD
#-------------------------output-------------------------
```

找到了一条DNAT规则，该规则将数据包的目的ip以及端口改写为`10.244.3.81`以及`8080`，然后继续查找路由表

```sh
[root@k8s-node-2 netns]$ ip r | grep '10.244.3.0/24'
#-------------------------output-------------------------
10.244.3.0/24 dev cni0 proto kernel scope link src 10.244.3.1
#-------------------------output-------------------------
```

我们发现，路由表指向的是`cni0`，每个pod都对应了一个`veth pair`，一端连接在网桥上，另一端在容器的网络命名空间中

接着，我们看下在`k8s-n-1`节点上，路由规则是怎样的

```sh
[root@k8s-node-1 ~]$ ip r | grep '10.244.3.0/24'
10.244.3.0/24 via 10.244.3.0 dev flannel.1 onlink
```

可以看到，在`k8s-n-1`节点上，直接路由到了`flannel.1`这样网卡，然后通过`flannel`的网络（主机网络或覆盖网络）到达`k8s-n-1`上

# 2 todo

1. 每个node上的pod，其子网都相同
1. 同个node之间的应用相互调用，最终会走到cni网桥
1. 不同node之间的应用相互调用，最终会走到flannel
1. cni0是个网桥（二层交换机）
1. 同一个网段走二层转发，不同网段走三层转发

# 3 参考

* [kubernetes入门之kube-proxy实现原理](https://xuxinkun.github.io/2016/07/22/kubernetes-proxy/)
* [kubernetes 简介：service 和 kube-proxy 原理](https://cizixs.com/2017/03/30/kubernetes-introduction-service-and-kube-proxy/)
* [kube-proxy工作原理](https://cloud.tencent.com/developer/article/1097449)
* [如何找到VEth设备的对端接口VEth peer](https://juejin.im/post/5caccf256fb9a06851504647)
