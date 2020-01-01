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
#-------------------------↓↓↓↓↓↓-------------------------
service/hello-world-service created
#-------------------------↑↑↑↑↑↑-------------------------

[root@k8s-master ~]$ kubectl apply -f hello-world-deployment.yml
#-------------------------↓↓↓↓↓↓-------------------------
deployment.apps/hello-world-deployment created
#-------------------------↑↑↑↑↑↑-------------------------
```

查找一下该`pod`部署在哪个`node`上

```sh
[root@k8s-master ~]$ kubectl get pods -o wide
#-------------------------↓↓↓↓↓↓-------------------------
NAME                                     READY   STATUS    RESTARTS   AGE   IP           NODE      NOMINATED NODE   READINESS GATES
hello-world-deployment-cbdf4db7b-j6fpq   1/1     Running   0          56s   10.244.1.5   k8s-n-1   <none>           <none>
#-------------------------↑↑↑↑↑↑-------------------------
```

发现，应用部署在`k8s-n-1`上，查看`k8s-n-1`节点上的`iptables`规则，用`30001`作为条件过滤

```sh
[root@k8s-n-1 ~]$ iptables-save | grep '30001'
#-------------------------↓↓↓↓↓↓-------------------------
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
#-------------------------↑↑↑↑↑↑-------------------------
```

我们找到了名为`KUBE-NODEPORTS`的`Chain`的两条规则，继续用`KUBE-NODEPORTS`寻找上游`Chain`

```sh
[root@k8s-n-1 ~]$ iptables-save | grep 'KUBE-NODEPORTS'
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-NODEPORTS - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
#-------------------------↑↑↑↑↑↑-------------------------
```

我们找到了名为`KUBE-SERVICES`的`Chain`的一条规则，继续用`KUBE-SERVICES`寻找上游`Chain`

```sh
[root@k8s-n-1 ~]$ iptables-save | grep 'KUBE-SERVICES'
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SERVICES - [0:0]
-A INPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A FORWARD -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m conntrack --ctstate NEW -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
:KUBE-SERVICES - [0:0]
-A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.103.220/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.103.220/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.1/32 -p tcp -m comment --comment "default/kubernetes:https cluster IP" -m tcp --dport 443 -j KUBE-SVC-NPX46M4PTMTKRN6Y
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p udp -m comment --comment "kube-system/kube-dns:dns cluster IP" -m udp --dport 53 -j KUBE-SVC-TCOU7JCQXEZGVUNU
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:dns-tcp cluster IP" -m tcp --dport 53 -j KUBE-SVC-ERIFXISQEP7F7OF4
-A KUBE-SERVICES ! -s 10.244.0.0/16 -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-MARK-MASQ
-A KUBE-SERVICES -d 10.96.0.10/32 -p tcp -m comment --comment "kube-system/kube-dns:metrics cluster IP" -m tcp --dport 9153 -j KUBE-SVC-JD5MR3NA4I4DYORP
-A KUBE-SERVICES -m comment --comment "kubernetes service nodeports; NOTE: this must be the last rule in this chain" -m addrtype --dst-type LOCAL -j KUBE-NODEPORTS
#-------------------------↑↑↑↑↑↑-------------------------
```

我们发现，`PREROUTING`、`INPUT`、`FORWARD`、`OUTPUT`为`KUBE-SERVICES`的上游`Chain`

接着我们回到`Chain KUBE-NODEPORTS`的规则，继续往下游分析，查看`Chain KUBE-SVC-5MRENC7Q6ZQR6GKR`

```sh
[root@k8s-n-1 ~]$ iptables-save | grep 'KUBE-SVC-5MRENC7Q6ZQR6GKR'
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SVC-5MRENC7Q6ZQR6GKR - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES -d 10.96.103.220/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-2KIVNDBOTOCNVG2U
#-------------------------↑↑↑↑↑↑-------------------------
```

找到了一条规则，该规则指向了另一个`Chain KUBE-SEP-2KIVNDBOTOCNVG2U`，继续往下查看

```sh
[root@k8s-n-1 ~]$ iptables-save | grep 'KUBE-SEP-2KIVNDBOTOCNVG2U'
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SEP-2KIVNDBOTOCNVG2U - [0:0]
-A KUBE-SEP-2KIVNDBOTOCNVG2U -s 10.244.1.5/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-2KIVNDBOTOCNVG2U -p tcp -m tcp -j DNAT --to-destination 10.244.1.5:8080
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-2KIVNDBOTOCNVG2U
#-------------------------↑↑↑↑↑↑-------------------------
```

找到了一条DNAT规则，该规则将数据包的目的ip以及端口改写为`10.244.1.5`以及`8080`，然后继续查找路由表

```sh
[root@k8s-n-1 ~]$ ip r | grep '10.244.1.0/24'
#-------------------------↓↓↓↓↓↓-------------------------
10.244.1.0/24 dev cni0 proto kernel scope link src 10.244.1.1
#-------------------------↑↑↑↑↑↑-------------------------
```

我们发现，路由表指向的是`cni0`，每个pod都对应了一个`veth pair`，一端连接在网桥上，另一端在容器的网络命名空间中，我们可以通过`brctl`来查看网桥`cni0`的相关信息

```sh
[root@k8s-n-1 ~]$ brctl show cni0
#-------------------------↓↓↓↓↓↓-------------------------
bridge name	bridge id		STP enabled	interfaces
cni0		8000.2a11eb4c8527	no		veth8469bbce
#-------------------------↑↑↑↑↑↑-------------------------

[root@k8s-n-1 ~]$ brctl showmacs cni0
#-------------------------↓↓↓↓↓↓-------------------------
port no	mac addr		is local?	ageing timer
  2	a6:92:e2:fd:6c:9c	yes		   0.00
  2	a6:92:e2:fd:6c:9c	yes		   0.00
  2	ca:97:47:ed:dd:01	no		   3.75
#-------------------------↑↑↑↑↑↑-------------------------
```

可以看到，目前网桥`cni0`上只有一张网卡，该网卡类型是`veth`，veth是一对网卡，其中一张网卡在默认的网络命名空间中，另外一张网卡在pod的网络命名空间中。`brctl showmacs cni0`输出的三条数据中，其`port`都是2，代表这些对应着同一个网卡，即`veth`网卡，`is local`字段为`true`表示位于默认网络命名空间中，`is local`字段为`false`表示位于另一个网络命名空间中，接下来找到该docker的命名空间，然后进入该命名空间查看一下网卡的mac地址是否为`ca:97:47:ed:dd:01`，同时看一下该网卡的ip是否为`10.244.1.5`

* 注意，`brctl showmacs cni0`的输出中，`is local`为`false`的这条数据，`ageing timer`不是`0.00`，大约在300s后，这条数据将会消息。可以通过重新访问该`veth`网卡来激活（`ping`一下对应的`pod ip`）

```sh
# 其中 e464807dae4f 是容器id
[root@k8s-n-1 ~]$ pid=$(docker inspect -f '{{.State.Pid}}' e464807dae4f)
[root@k8s-n-1 ~]$ nsenter -t ${pid} -n ifconfig
#-------------------------↓↓↓↓↓↓-------------------------
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1450
        inet 10.244.1.5  netmask 255.255.255.0  broadcast 0.0.0.0
        inet6 fe80::c897:47ff:feed:dd01  prefixlen 64  scopeid 0x20<link>
        ether ca:97:47:ed:dd:01  txqueuelen 0  (Ethernet)
        RX packets 64  bytes 6286 (6.1 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 49  bytes 5643 (5.5 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
#-------------------------↑↑↑↑↑↑-------------------------
```

接着，我们看下在`k8s-n-2`节点上，路由规则是怎样的

```sh
[root@k8s-n-2 ~]$ ip r | grep '10.244.1.0/24'
#-------------------------↓↓↓↓↓↓-------------------------
10.244.1.0/24 via 10.244.1.0 dev flannel.1 onlink
#-------------------------↑↑↑↑↑↑-------------------------
```

可以看到，在`k8s-n-1`节点上，直接路由到了`flannel.1`这样网卡，然后通过`flannel`的网络（主机网络或覆盖网络）到达`k8s-n-1`上

# 2 多副本

__deployment（hello-world-deployment.yml）__

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world-deployment
  labels:
    mylabel: label_hello_world_deployment
spec:
  replicas: 3 # 这里改成3副本
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
#-------------------------↓↓↓↓↓↓-------------------------
service/hello-world-service created
#-------------------------↑↑↑↑↑↑-------------------------

[root@k8s-master ~]$ kubectl apply -f hello-world-deployment.yml
#-------------------------↓↓↓↓↓↓-------------------------
deployment.apps/hello-world-deployment created
#-------------------------↑↑↑↑↑↑-------------------------
```

查看一下`pod`的部署情况

```sh
[root@k8s-master ~]$ kubectl get pods -o wide
#-------------------------↓↓↓↓↓↓-------------------------
NAME                                     READY   STATUS    RESTARTS   AGE     IP           NODE      NOMINATED NODE   READINESS GATES
hello-world-deployment-cbdf4db7b-5qflq   1/1     Running   0          5m      10.244.2.2   k8s-n-2   <none>           <none>
hello-world-deployment-cbdf4db7b-j6fpq   1/1     Running   1          5h35m   10.244.1.6   k8s-n-1   <none>           <none>
hello-world-deployment-cbdf4db7b-qc624   1/1     Running   0          5m      10.244.1.7   k8s-n-1   <none>           <none>
#-------------------------↑↑↑↑↑↑-------------------------
```

我们以`k8s-n-1`为例，首先以`NodePort`为关键字进行搜索

```sh
[root@k8s-n-1 ~]$ iptables-save | grep 30001
#-------------------------↓↓↓↓↓↓-------------------------
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-MARK-MASQ
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
#-------------------------↑↑↑↑↑↑-------------------------
```

上游`Chain`与单副本完全一致，不再赘述，继续沿着下游`Chain`进行分析，搜索`KUBE-SVC-5MRENC7Q6ZQR6GKR`关键词

```sh
[root@k8s-n-1 ~]$ iptables-save | grep KUBE-SVC-5MRENC7Q6ZQR6GKR
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SVC-5MRENC7Q6ZQR6GKR - [0:0]
-A KUBE-NODEPORTS -p tcp -m comment --comment "default/hello-world-service:" -m tcp --dport 30001 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SERVICES -d 10.96.103.220/32 -p tcp -m comment --comment "default/hello-world-service: cluster IP" -m tcp --dport 4000 -j KUBE-SVC-5MRENC7Q6ZQR6GKR
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-NQUZNNDG4S4UQTZI
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-XYEBSHB6XMTA6LVQ
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-AFBU56PEPWZ4VPIJ
#-------------------------↑↑↑↑↑↑-------------------------
```

这里，我们就能发现单副本与多副本之间的差异了，在单副本的例子中，只有一条规则，而多副本的例子中，有多条规则（规则数量与副本数保持一致），并且使用了`statistic`模块，引入了随机因子，用于实现负载均衡的功能（`iptables -m statistic -h`查看该模块的参数），然后，分别查看三个下游`Chain`

```sh
[root@k8s-n-1 ~]$ iptables-save | grep KUBE-SEP-NQUZNNDG4S4UQTZI
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SEP-NQUZNNDG4S4UQTZI - [0:0]
-A KUBE-SEP-NQUZNNDG4S4UQTZI -s 10.244.1.6/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-NQUZNNDG4S4UQTZI -p tcp -m tcp -j DNAT --to-destination 10.244.1.6:8080
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -m statistic --mode random --probability 0.33333333349 -j KUBE-SEP-NQUZNNDG4S4UQTZI
#-------------------------↑↑↑↑↑↑-------------------------

[root@k8s-n-1 ~]$ iptables-save | grep KUBE-SEP-XYEBSHB6XMTA6LVQ
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SEP-XYEBSHB6XMTA6LVQ - [0:0]
-A KUBE-SEP-XYEBSHB6XMTA6LVQ -s 10.244.1.7/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-XYEBSHB6XMTA6LVQ -p tcp -m tcp -j DNAT --to-destination 10.244.1.7:8080
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -m statistic --mode random --probability 0.50000000000 -j KUBE-SEP-XYEBSHB6XMTA6LVQ
#-------------------------↑↑↑↑↑↑-------------------------

[root@k8s-n-1 ~]$ iptables-save | grep KUBE-SEP-AFBU56PEPWZ4VPIJ
#-------------------------↓↓↓↓↓↓-------------------------
:KUBE-SEP-AFBU56PEPWZ4VPIJ - [0:0]
-A KUBE-SEP-AFBU56PEPWZ4VPIJ -s 10.244.2.2/32 -j KUBE-MARK-MASQ
-A KUBE-SEP-AFBU56PEPWZ4VPIJ -p tcp -m tcp -j DNAT --to-destination 10.244.2.2:8080
-A KUBE-SVC-5MRENC7Q6ZQR6GKR -j KUBE-SEP-AFBU56PEPWZ4VPIJ
#-------------------------↑↑↑↑↑↑-------------------------
```

这里，可以看到，三个`Chain`，每个`Chain`分别配置了一个DNAT，指向某一个`pod`。后续的链路，如果在`pod`在本机，则走`cni0`网桥，否则就走`flannel`

# 3 总结

1. 每个`node`上的`pod`，其子网都相同
1. 同个`node`之间`pod`相互访问，最终会走到`cni`网桥，该网桥等价于一个二层交换机，接着一对`veth`网卡，其中一段在默认的网络命名空间，另一端在`pod`的网络命名空间
1. 不同`node`之间的`pod`相互访问，最终会走到`flannel`

# 4 todo

1. 网桥、二层交换机、三层交换机、路由器

https://www.globalknowledge.com/us-en/resources/resource-library/articles/what-s-the-difference-between-hubs-switches-bridges/

They(switch) use the multi-port ability of the hub with the filtering of a bridge, allowing only the destination to see the unicast traffic

# 5 参考

* [kubernetes入门之kube-proxy实现原理](https://xuxinkun.github.io/2016/07/22/kubernetes-proxy/)
* [kubernetes 简介：service 和 kube-proxy 原理](https://cizixs.com/2017/03/30/kubernetes-introduction-service-and-kube-proxy/)
* [kube-proxy工作原理](https://cloud.tencent.com/developer/article/1097449)
* [如何找到VEth设备的对端接口VEth peer](https://juejin.im/post/5caccf256fb9a06851504647)
* [技术干货|深入理解flannel](https://zhuanlan.zhihu.com/p/34749675)
