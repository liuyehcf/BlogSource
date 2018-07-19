---
title: Kubernetes-Single-master-cluster-Demo
date: 2018-07-17 21:01:40
tags: 
- 原创
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 环境

`Virtual Box`+`CentOS-7-x86_64-Minimal-1804.iso`

__tips__

1. 主机与`Virtual Box`之间不能共享剪切板（不知道为什么）
    * 开启sshd服务，通过ssh连接到虚拟机即可
1. 虚拟机开启两张网卡，一张是`NAT`，另一张是`Host-only`
    * `NAT`用于访问外网
    * `host-only`用于主机与虚拟机之间互通

# 2 Install Kubeadm

## 2.1 关闭swap

__首先，需要关闭Swap，否则kubelet可能会不正常工作__

1. `swapon -s`：查看swap的设备
1. `swapoff <file-path>`：关闭对应的设备
1. `swapoff -a`：关闭所有swap设备

## 2.2 关闭防火墙

省点事，真的，别费劲了

`systemctl stop firewalld`

## 2.3 修改hostname

```sh
hostnamectl set-hostname <name>
```

## 2.4 检查mac地址以及UUID

执行`ifconfig -a`，发现没有该命令！！！（我下载的镜像是Minimal，并且是最小安装）

于是，执行`yum install ifconfig`，发现没有网络！！！我靠！！！估计是网卡没有开启，下面启用网卡

1. `cd /etc/sysconfig/network-scripts`
1. `vi ifcfg-enp0s3`，将`ONBOOT`设置为yes
1. `systemctl restart network`：重启网卡
* 开启成功（试试看能不能ping通`www.baidu.com`，不行就重启下）

然后，安装`ifconfig`

1. `yum search ifconfig`，找到软件包名为`net-tools.x86_64`
1. `yum install -y net-tools.x86_64`
* 安装完毕

查看mac地址，两个命令2选1

1. `ifconfig -a`
1. `ip link`

查看主板uuid

1. `cat /sys/class/dmi/id/product_uuid`

## 2.5 检查网络适配器

当包含2个及以上的网络适配器时，Kubernetes组件在默认路由配置中是不可达的，因此需要增加路由使得Kubernetes组件可达

## 2.6 安装docker

```sh
yum install -y docker
systemctl enable docker && systemctl start docker
```

## 2.7 安装kubeadm/kubelet/kubectl

* __kubeadm__：用于启动集群
* __kubelet__：存在于集群中所有机器上，用于启动pods以及containers等
* __kubectl__：用于与集群交互

kubelet/kubectl的版本必须与kubeadm一致，否则可能会导致某些异常以及bug

```sh
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
setenforce 0
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

* `setenforce 0`：SELinux转换为宽容模式，否则可能会有权限问题

__这里用的是阿里云的镜像，官方文档提供的是谷歌镜像（海外，需要翻墙），下面的配置流程都以墙内（使用的都是阿里云镜像）为主__

# 3 Start Master

__修改kubernetes配置文件__

```sh
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# 增加如下一行
Environment="KUBELET_ALIYUN_ARGS=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.0"

# 在ExecStart后追加以下内容
$KUBELET_ALIYUN_ARGS
```

__安装完kubeadm/kubelet/kubectl之后，现在就需要启动master节点__

在任意路径下（以`~`为例），创建文件`kubeadm.yaml`（文件名随便），这个文件就是启动master时，指定用到的配置文件，其内容如下

```sh
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
api:
  advertiseAddress: "192.168.56.102" # 只需要修改这里，改成host-only网卡对应的ip
  bindPort: 6443
kubernetesVersion: "v1.11.0"
imageRepository: "registry.cn-hangzhou.aliyuncs.com/google_containers"
networking:
  podSubnet: 10.244.0.0/16
```

__接下来初始化master节点__

```sh
kubeadm init --config kubeadm.yaml

# 出现如下信息，提示启动成功
...
Your Kubernetes master has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of machines by running the following on each node
as root:

  kubeadm join 192.168.56.104:6443 --token po5vmh.454rfy82r7dt40or --discovery-token-ca-cert-hash sha256:e92758ae43ed48c49ea5568d2a7cac85ed04b30b9534495f17eea0f8034b7b61
```

__然后，查看节点的状态（发现错误）__
```sh
kubectl get nodes

# 出现如下错误信息
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

[上述错误解决方案如下](https://github.com/kubernetes/kubernetes/issues/44665)

```sh
sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf
```

__继续，查看节点的状态（发现错误）__

```sh
kubectl get nodes

# 得到如下输出
NAME                    STATUS     ROLES     AGE       VERSION
localhost.localdomain   NotReady   master    5m        v1.11.1
```

__此时，发现master节点的状态是NotReady，然后查看节点的详细信息__

```sh
kubectl describe nodes

# 看到如下信息
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  OutOfDisk        False   Thu, 19 Jul 2018 16:41:30 +0800   Thu, 19 Jul 2018 16:35:33 +0800   KubeletHasSufficientDisk     kubelet has sufficient disk space available
  MemoryPressure   False   Thu, 19 Jul 2018 16:41:30 +0800   Thu, 19 Jul 2018 16:35:33 +0800   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Thu, 19 Jul 2018 16:41:30 +0800   Thu, 19 Jul 2018 16:35:33 +0800   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Thu, 19 Jul 2018 16:41:30 +0800   Thu, 19 Jul 2018 16:35:33 +0800   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            False   Thu, 19 Jul 2018 16:41:30 +0800   Thu, 19 Jul 2018 16:35:33 +0800   KubeletNotReady              runtime network not ready: NetworkReady=false reason:NetworkPluginNotReady message:docker: network plugin is not ready: cni config uninitialized
```

__上述信息表示，network尚未安装，[官方文档](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)给出了解决方法，这里我们选择安装flannel__

```sh
# 为了让kubectl命令行起作用，必须配置如下环境变量
export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
```

__查看flannel安装进度__

```sh
kubectl describe nodes

# 得到如下输出
Non-terminated Pods:         (8 in total)
  Namespace                  Name                                             CPU Requests  CPU Limits  Memory Requests  Memory Limits
  ---------                  ----                                             ------------  ----------  ---------------  -------------
  kube-system                coredns-777d78ff6f-skdvk                         100m (10%)    0 (0%)      70Mi (7%)        170Mi (19%)
  kube-system                coredns-777d78ff6f-vhwsr                         100m (10%)    0 (0%)      70Mi (7%)        170Mi (19%)
  kube-system                etcd-localhost.localdomain                       0 (0%)        0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-apiserver-localhost.localdomain             250m (25%)    0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-controller-manager-localhost.localdomain    200m (20%)    0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-flannel-ds-sqg5h                            100m (10%)    100m (10%)  50Mi (5%)        50Mi (5%)
  kube-system                kube-proxy-zxq8q                                 0 (0%)        0 (0%)      0 (0%)           0 (0%)
  kube-system                kube-scheduler-localhost.localdomain             100m (10%)    0 (0%)      0 (0%)           0 (0%)

# 发现flannel对应的Name是`kube-flannel-ds-sqg5h`，Namespace是`kube-system`
# 查询flannel对应的pod状态
kubectl describe pod -n kube-system kube-flannel-ds-sqg5h

# 得到如下输出（大约5分钟会安装完，耐心点咯）
Events:
  Type    Reason   Age   From                 Message
  ----    ------   ----  ----                 -------
  Normal  Pulling  4m    kubelet, k8s-master  pulling image "quay.io/coreos/flannel:v0.10.0-amd64"
  Normal  Pulled   12s   kubelet, k8s-master  Successfully pulled image "quay.io/coreos/flannel:v0.10.0-amd64"
  Normal  Created  12s   kubelet, k8s-master  Created container
  Normal  Started  12s   kubelet, k8s-master  Started container
  Normal  Pulled   11s   kubelet, k8s-master  Container image "quay.io/coreos/flannel:v0.10.0-amd64" already present on machine
  Normal  Created  11s   kubelet, k8s-master  Created container
  Normal  Started  11s   kubelet, k8s-master  Started container
```

__待flannel安装成功后，再查看节点状态。至此，master启动成功__

```sh
kubectl get nodes

# 输出信息如下
NAME                    STATUS    ROLES     AGE       VERSION
localhost.localdomain   Ready     master    7m        v1.11.1
```

# 4 Start Node

__另外启动两台虚拟机，执行[Install Kubeadm](#InstallKubeadm)小节的所有操作__

__现在需要将新启动的虚拟机，加入刚才启动的master。首先，我们还是回到master机器上，创建指令__

```sh
kubeadm token create --print-join-command

# 输出如下
kubeadm join 192.168.56.104:6443 --token 7rwct3.1jarvf2ls7vajmww --discovery-token-ca-cert-hash sha256:f8e9480f1f6babb8465e16bd5e04460aecde9594a572bea10635bceb617a4301
```

__回到node节点对应的虚拟机，执行上述命令__

```sh
kubeadm join 192.168.56.104:6443 --token 7rwct3.1jarvf2ls7vajmww --discovery-token-ca-cert-hash sha256:f8e9480f1f6babb8465e16bd5e04460aecde9594a572bea10635bceb617a4301

# 得到如下输出
[preflight] running pre-flight checks
  [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[nf_conntrack_ipv4:{} ip_vs:{} ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support
```

__按照提示，安装缺少的模块__

```sh
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
```

__继续执行join指令，加入master节点__

```sh
# 先重置
kubeadm reset

# join
kubeadm join 192.168.56.104:6443 --token 7rwct3.1jarvf2ls7vajmww --discovery-token-ca-cert-hash sha256:f8e9480f1f6babb8465e16bd5e04460aecde9594a572bea10635bceb617a4301

# 得到如下输出
  [WARNING Hostname]: hostname "k8s-node1" could not be reached
  [WARNING Hostname]: hostname "k8s-node1" lookup k8s-node1 on 10.65.0.201:53: server misbehaving
[discovery] Trying to connect to API Server "192.168.56.104:6443"
[discovery] Created cluster-info discovery client, requesting info from "https://192.168.56.104:6443"
[discovery] Requesting info from "https://192.168.56.104:6443" again to validate TLS against the pinned public key
[discovery] Failed to request cluster info, will try again: [Get https://192.168.56.104:6443/api/v1/namespaces/kube-public/configmaps/cluster-info: x509: certificate has expired or is not yet valid]
```

__[上述错误解决方案如下](https://github.com/kubernetes/kubernetes/issues/42791)__

```sh
# 在mster节点安装ntp，并启动
yum install -y ntp
systemctl start ntpd
```

__再次执行join指令，加入master节点__

```sh
# 先重置
kubeadm reset

# join master
kubeadm join 192.168.56.104:6443 --token 7rwct3.1jarvf2ls7vajmww --discovery-token-ca-cert-hash sha256:f8e9480f1f6babb8465e16bd5e04460aecde9594a572bea10635bceb617a4301

# 得到如下输出
This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

__至此k8s-node1加入完毕，另一台node节点重复上述操作__

__全部完成后，回到master节点，执行如下指令__

```sh
kubectl get nodes

# 得到如下输出
NAME         STATUS    ROLES     AGE       VERSION
k8s-master   Ready     master    21m       v1.11.1
k8s-node1    Ready     <none>    8m        v1.11.1
k8s-node2    Ready     <none>    3m        v1.11.1
```

# 5 参考

* [Kubernetes官方文档](https://kubernetes.io/docs/setup/)

