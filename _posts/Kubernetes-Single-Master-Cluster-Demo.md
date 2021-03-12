---
title: Kubernetes-Single-Master-Cluster-Demo
date: 2018-07-17 21:01:40
tags: 
- 原创
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 环境

`Virtual Box`+`CentOS-7-x86_64-Minimal-1804.iso`

**tips**

1. 主机与`Virtual Box`之间不能共享剪切板（不知道为什么）
    * 开启sshd服务，通过ssh连接到虚拟机即可
1. 虚拟机开启两张网卡，一张是`NAT`，另一张是`Host-only`
    * `NAT`用于访问外网
    * `host-only`用于主机与虚拟机之间互通

# 2 Install Kubeadm

## 2.1 关闭swap

**首先，需要关闭Swap，否则kubelet可能会不正常工作**

```sh
swapon -s # 查看swap的设备
swapoff <file-path> # 关闭对应的设备
swapoff -a # 关闭所有swap设备
```

## 2.2 关闭防火墙

省点事，真的，别费劲了

```sh
systemctl stop firewalld
```

## 2.3 修改hostname

**所有node的hostname必须不一样，这个很关键！因为k8s是通过hostname来路由的**

```sh
hostnamectl set-hostname <name>
```

## 2.4 检查mac地址以及UUID

**执行`ifconfig -a`，发现没有该命令！！！（我下载的镜像是Minimal，并且是最小安装）**

**于是，执行`yum install ifconfig`，发现没有网络！！！我靠！！！估计是网卡没有开启，下面启用网卡**

```sh
cd /etc/sysconfig/network-scripts
vi ifcfg-enp0s3 # 将`ONBOOT`设置为yes。（如果有多个网卡配置文件，同样方式设置）
systemctl restart network # 重启网卡
```

**然后，安装`ifconfig`**

```sh
yum search ifconfig # 找到软件包名为`net-tools.x86_64`
yum install -y net-tools.x86_64
```

**查看mac地址**

```sh
ifconfig -a
ip link
```

**查看主板uuid**

```sh
cat /sys/class/dmi/id/product_uuid
```

**建议：通过主机ssh连接到虚拟机。由于虚拟机bash界面不能拷贝命令，而且不能翻看标准输出的内容，用起来非常蛋疼**

## 2.5 检查网络适配器

当包含2个及以上的网络适配器时，Kubernetes组件在默认路由配置中是不可达的，因此需要增加路由使得Kubernetes组件可达

## 2.6 安装docker

```sh
yum install -y docker
systemctl enable docker && systemctl start docker
```

## 2.7 安装kubeadm/kubelet/kubectl

* **kubeadm**：用于启动集群
* **kubelet**：存在于集群中所有机器上，用于启动pods以及containers等
* **kubectl**：用于与集群交互

kubelet/kubectl的版本必须与kubeadm一致，否则可能会导致某些异常以及bug

```sh
# 设置配置文件
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 关闭SELinux
setenforce 0

# 安装k8s
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet && systemctl start kubelet
```

* **`setenforce 0`：SELinux转换为宽容模式，否则可能会有权限问题（例如，Start kube-proxy就会有问题）**

**这里用的是阿里云的镜像，官方文档提供的是谷歌镜像（海外，需要翻墙），下面的配置流程都以墙内（使用的都是阿里云镜像）为主**

# 3 Start Master

**接下来初始化master节点**

```sh
kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers --apiserver-advertise-address=192.168.56.105

# 其中
# --pod-network-cidr参数指定pod网络（这里用10.244.0.0/16是为了与下面的flannel覆盖网络的默认参数一致）
# --apiserver-advertise-address参数指定master的ip（这个参数是可选的，我的测试虚拟机有两个网段：10.0.2.0/24以及192.168.56.0/24，其中10.0.2.0/24这个网段上，两台虚拟机之间是无法通信的；192.168.56.0/24这个网段，两台虚拟机之间是可以通信的）

# 出现如下信息，提示启动成功
...
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.56.105:6443 --token xlys6c.70evo8lwk7ta4hbo \
    --discovery-token-ca-cert-hash sha256:0fac04a6a3a18aaf7d9c3e154bdf1813119b9840f43e8c1649cbdfe5d50d1f2c
```

* **注意，我们需要保留下上面的join命令，即`kubeadm join ...`这个命令**
* **node节点需要通过这个命令来join master节点**

**根据上述提示，安装network pod。[安装命令参考，一定要看这个，不同版本url是不同的](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)。这里，我们选择flannel（安装过程需要翻墙，否则拉取镜像会失败！！）**

```sh
# 在master上，为了让kubectl命令行起作用，必须配置如下环境变量
export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装flannel（这里只是参考，详见上面的安装命令参考）
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/62e44c867a2846fefb68bd5f178daf4da3095ccb/Documentation/kube-flannel.yml
```

**待flannel安装成功后（大约需要5-10分钟），查看节点概要信息。至此，master启动成功**

```sh
# 查看节点概要信息
kubectl get nodes

# 得到如下输出
NAME         STATUS    ROLES     AGE       VERSION
k8s-master   Ready     master    26m       v1.11.1
```

## 3.1 重新生成kubeadm join所需的token

```sh
# 以下命令在master节点执行

# 1 创建token
kubeadm token create

# 2 计算hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed  's/^ .* //'

# 在node节点执行join命令

kubeadm join <master ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 3.2 Restart

**如果我们将master这台机器重启的话，k8s服务不会自动起来，需要进行如下操作**

```sh
# 关闭swap
swapoff -a

# 关闭防火墙
systemctl stop firewalld

# 关闭SELinux
setenforce 0

# 重启kubelet
systemctl start kubelet

# 配置环境变量
export KUBECONFIG=/etc/kubernetes/admin.conf
```

# 4 Start Node

**另外启动两台虚拟机，执行 [Install Kubeadm](#install-kubeadm) 小节的所有操作**

**现在需要将新启动的虚拟机，加入刚才启动的master**

* 还记得master节点初始化k8s输出的`kubeadm join`命令吗，这个指令就用于node节点
* 如果忘记了，我们还可以通过在master节点上执行`kubeadm token create --print-join-command`来创建`kubeadm join`命令

**回到node节点对应的虚拟机，执行上述`kubeadm join`命令（该过程需要翻墙，因为会安装flannel，需要拉取镜像）**

```sh
kubeadm join 192.168.56.108:6443 --token 3yokh0.16u9wvjk1x50nde2 --discovery-token-ca-cert-hash sha256:c36ac2694b043a660624e9d86a56999fcd23bf13b3994af6560aac713eacc54d
# 得到如下输出

[preflight] running pre-flight checks
  [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{} ip_vs:{}]
you can solve this problem with following methods:
 1. Run 'modprobe -- ' to load missing kernel modules;
2. Provide the missing builtin kernel ipvs support
```

**按照提示，安装缺少的模块**

```sh
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
```

**继续执行join指令，加入master节点**

```sh
# 先重置
kubeadm reset

# join
kubeadm join 192.168.56.108:6443 --token 3yokh0.16u9wvjk1x50nde2 --discovery-token-ca-cert-hash sha256:c36ac2694b043a660624e9d86a56999fcd23bf13b3994af6560aac713eacc54d

# 得到如下输出
This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

**至此一台node节点加入master节点完毕（大约需要5分钟的时间，才能在master上看到ready状态），另一台node节点重复上述操作**

**全部完成后，回到master节点，执行如下指令**

```sh
kubectl get nodes

# 得到如下输出
NAME         STATUS    ROLES     AGE       VERSION
k8s-master   Ready     master    27m       v1.11.1
k8s-node-1   Ready     <none>    2m        v1.11.1
k8s-node-2   Ready     <none>    11m       v1.11.1
```

# 5 部署应用

## 5.1 制作镜像

这里以一个简单的`Spring-Boot`应用为例，制作一个镜像。**具体示例代码详见{% post_link Spring-Boot-Demo %}**

**首先，将`Spring-Boot`应用打包成一个fat-jar**，例如`spring-boot-1.0-SNAPSHOT.jar`

* 你可以随便搞一个简单的Web应用

**然后，创建Dockerfile，内容如下**

```docker
# 设置基础镜像
FROM centos:7.5.1804

# 设置工作目录
WORKDIR /web

# 将当前目录下的内容添加到docker容器中的/web/lib路径中
ADD . /web/lib

# 执行命令，安装java依赖
RUN yum install -y java

# 暴露8080端口
EXPOSE 8080

# docker run执行的命令
CMD ["java", "-jar", "lib/spring-boot-1.0-SNAPSHOT.jar"]
```

**将上述`Dockerfile`与`spring-boot-1.0-SNAPSHOT.jar`放入同一个目录下，此时目录结构如下**

```
.
├── Dockerfile
└── spring-boot-1.0-SNAPSHOT.jar
```

**接着，我们开始制作镜像**

```sh
# -t参数指定tag
# docker build -h 查看详细用法
docker build -t hello-world:v1 .
```

**本地测试一下，能否运行起来（经验证，没问题）**

```sh
# docker run -help 查看详细用法
docker run hello-world:v1
```

## 5.2 上传镜像到镜像仓库

**这里以`阿里云-容器镜像服务`为例，将刚才制作的镜像上传到镜像仓库。详细操作请参考[阿里云-容器镜像服务](https://www.aliyun.com/product/acr?spm=5176.10695662.1996646101.searchclickresult.3cab795dkMnIFM)**

创建完成后，镜像仓库`url`如下（你创建的镜像仓库肯定与我的不同）

```
registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo 
```

**在`阿里云-容器镜像服务`控制台，点击刚才创建的镜像-管理，按照文档说明上传镜像，大致分为两步（以我的镜像仓库`url`为例）**

```sh
# 登录
sudo docker login --username=<your user name> registry.cn-hangzhou.aliyuncs.com

# 打刚才制作的镜像打上tag
# 详细用法请参考 docker tag -h
docker tag hello-world:v1 registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo:v1 

# push镜像
sudo docker push registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo:v1
```

## 5.3 部署应用

**首先，编写应用所在pod的yml文件，hello-world.yml文件如下**

```yml
apiVersion: v1
kind: Pod
metadata:
  name: "hello-world"
  labels:
    mylabel: label_hello_world
spec:
  restartPolicy: Always
  containers:
  - name: "hello-world"
    image: "registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo:v1"
    imagePullPolicy: IfNotPresent
    command: ["java", "-jar", "lib/spring-boot-1.0-SNAPSHOT.jar"]
    ports:
    - containerPort: 8080
```

**在master节点上，启动该pod**

```sh
kubectl create -f hello-world.yml
```

**查看pod运行状态，可以看到pod部署成功**

```sh
kubectl get pod

# 以下是输出信息
NAME          READY     STATUS    RESTARTS   AGE
hello-world   1/1       Running   0          4m
```

**由于我们这个Web应用服务在8080端口，但是上面的`hello-world.yml`文件中配置的是容器端口，我们仍然不能在外界访问这个服务。我们还需要增加一个`hello-world-service`，`hello-world-service.yml`文件内容如下**

```yml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
spec:
  ports:
    - port: 4000
      targetPort: 8080
      nodePort: 30001
  selector:
    mylabel: label_hello_world
  type: NodePort
```

**启动service**

```sh
kubectl create -f hello-world-service.yml
```

**查看端口号（nodePort）**

```sh
kubectl describe svc hello-world-service

# 输出信息如下
Name:                     hello-world-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 mylabel=label_hello_world
Type:                     NodePort
IP:                       10.108.106.70
Port:                     <unset>  4000/TCP   # service port
TargetPort:               8080/TCP            # target port
NodePort:                 <unset>  30001/TCP  # node port
Endpoints:                10.244.1.94:8080    # pod Ip:port
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

**访问`http://<node_ip>:30001/home`，成功！**

# 6 Helm

**步骤**

1. 下载，二进制包，传送门[helm release](https://github.com/helm/helm/releases)
1. 解压缩，`tar -zxvf <file>`
1. `mv linux-amd64/helm /usr/local/bin/helm`
1. `helm init`

## 6.1 参考

* [github helm](https://github.com/helm/helm/blob/master/docs/install.md)
* [helm doc](https://helm.sh/docs/using_helm/#quickstart-guide)

# 7 Ingress

todo ingress nginx

**helm安装（未成功）**

1. `helm install stable/nginx-ingress --name my-nginx`

**非helm安装**

1. 安装`nginx-ingress-controller`
    * `kubectl apply -f mandatory.yaml`
    * [mandatory.yaml下载链接](https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml)
1. 安装`MetalLB`
    * `kubectl apply -f metallb.yaml`
    * [metallb.yaml下载链接](https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml)
1. 部署`nginx service`
    * `kubectl apply -f service-nodeport.yaml`
    * [service-nodeport.yaml下载链接](https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/provider/baremetal/service-nodeport.yaml)
1. 修改`service-nodeport.yaml`中的`ingress-nginx`的`Type`，改为`LoadBalancer`
    * `kubectl edit svc ingress-nginx -n ingress-nginx`
1. 添加`configmap`
    * `kubectl apply -f metallb-system.yml`
1. 添加`ingress`
    * `kubectl apply -f test-ingress.yml`
1. 修改`hello-world-service`的`Type`，改为`LoadBalancer`
    * `kubectl edit svc hello-world-service`

`metallb-system.yml`如下

```yml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.56.101-192.168.56.103
```

`test-ingress.yml`如下

```yml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /home
        backend:
          serviceName: hello-world-service
          servicePort: 4000
```

查看ingress

```sh
kubectl get ingress test-ingress

test-ingress   *         192.168.56.101   80        19d
```

[https://192.168.56.101/home](https://192.168.56.101/home)

**Ingress Controller的作用**

1. 读取`Ingress`，并写入到nginx的配置文件中
1. 监听集群中`Service`的变化，及时更新backend

## 7.1 参考

* [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx)
* [nginx ingress doc](https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command)
* [metallb doc](https://metallb.universe.tf/installation/)

# 8 Command

## 8.1 kubectl

```sh
# 列出所有资源类型
kubectl api-resources

# 查看node概要信息
kubectl get nodes
kubectl get node <node-name>

# 查看node详细信息
kubectl describe nodes
kubectl describe node <node-name>

# 查看namespace空间
kubectl get namespace

# 查看pod概要信息
kubectl get pod -n <namespace>
kubectl get pod -n <namespace> <pod-name>
kubectl get pod -n <namespace> <pod-name> -o wide
kubectl get pod --all-namespaces

# 查看pod详细信息
kubectl describe pod -n <namespace>
kubectl describe pod -n <namespace> <pod-name>

# 删除pod
kubectl delete pod <pod-name> -n <namespace>
kubectl delete pod <pod-name> --force --grace-period=0 -n <namespace>

# 查看service概要信息
kubectl get svc <service-name>

# 查看service详细信息
kubectl describe svc <service-name>

# 查看object
kubectl get -f <filename|url> -o yaml
kubectl get pod -n <namespace> <pod-name> -o yaml

# 打label
kubectl label pod -n <namespace> <pod-name> <label_name>=<label_value>
```

---

# 9 2021-03-09再次部署

```sh
#!/bin/bash

# docker安装
# step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# Step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# Step 3
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# Step 4: 更新并安装Docker-CE
yum makecache fast
yum -y install docker-ce-18.06.3.ce-3.el7
# Step 4: 开启Docker服务
systemctl enable docker
systemctl start docker

# 配置内核参数
cat >> /etc/sysctl.conf << 'EOF'
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
fs.inotify.max_user_watches=524288
vm.swappiness = 0
EOF
sysctl -p /etc/sysctl.conf

# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld

# 关闭selinux
sed -r -i '/SELINUX=/s/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 重启
reboot
```

# 10 参考

* [Kubernetes-Creating a single master cluster with kubeadm](https://kubernetes.io/docs/setup/)
* [Kubernetes-Installing kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [issue#localhost:8080](https://github.com/kubernetes/kubernetes/issues/44665)
* [issue#x509: certificate has expired or is not yet valid](https://github.com/kubernetes/kubernetes/issues/42791)
* [kubernetes创建资源yaml文件例子--pod](https://blog.csdn.net/liyingke112/article/details/76155428)
* [十分钟带你理解Kubernetes核心概念](http://www.dockone.io/article/932)
* [Kubernetes集群中flannel因网卡名启动失败问题](https://blog.csdn.net/ygqygq2/article/details/81698193)
