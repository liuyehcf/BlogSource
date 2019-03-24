---
title: Kubernetes-Single-Master-Cluster-Demo
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

__所有node的hostname必须不一样，这个很关键！因为k8s是通过hostname来路由的__

```sh
hostnamectl set-hostname <name>
```

## 2.4 检查mac地址以及UUID

__执行`ifconfig -a`，发现没有该命令！！！（我下载的镜像是Minimal，并且是最小安装）__

__于是，执行`yum install ifconfig`，发现没有网络！！！我靠！！！估计是网卡没有开启，下面启用网卡__

```sh
cd /etc/sysconfig/network-scripts
vi ifcfg-enp0s3 # 将`ONBOOT`设置为yes。（如果有多个网卡配置文件，同样方式设置）
systemctl restart network # 重启网卡
```

__然后，安装`ifconfig`__

```sh
yum search ifconfig # 找到软件包名为`net-tools.x86_64`
yum install -y net-tools.x86_64
```

__查看mac地址__

```sh
ifconfig -a
ip link
```

__查看主板uuid__

```sh
cat /sys/class/dmi/id/product_uuid
```

__建议：通过主机ssh连接到虚拟机。由于虚拟机bash界面不能拷贝命令，而且不能翻看标准输出的内容，用起来非常蛋疼__

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

* __`setenforce 0`：SELinux转换为宽容模式，否则可能会有权限问题（例如，Start kube-proxy就会有问题）__

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

__安装完kubeadm/kubelet/kubectl之后，现在就需要启动master节点。在任意路径下（以`~`为例），创建文件`kubeadm.yml`（文件名随便），这个文件就是启动master时，指定用到的配置文件，其内容如下__

```sh
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
api:
  advertiseAddress: "192.168.56.108" # 只需要修改这里，改成host-only网卡对应的ip
  bindPort: 6443
kubernetesVersion: "v1.11.0"
imageRepository: "registry.cn-hangzhou.aliyuncs.com/google_containers"
networking:
  podSubnet: 10.244.0.0/16
```

__接下来初始化master节点__

```sh
kubeadm init --config kubeadm.yml

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

  kubeadm join 192.168.56.108:6443 --token 3yokh0.16u9wvjk1x50nde2 --discovery-token-ca-cert-hash sha256:c36ac2694b043a660624e9d86a56999fcd23bf13b3994af6560aac713eacc54d
```

* __注意，我们需要保留下上面的join命令，即`kubeadm join ...`这个命令__
* __node节点需要通过这个命令来join master节点__

__根据上述提示，安装network pod。[安装命令参考](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)。这里，我们选择flannel__

```sh
# 为了让kubectl命令行起作用，必须配置如下环境变量
export KUBECONFIG=/etc/kubernetes/admin.conf

# 安装flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
```

__待flannel安装成功后（大约需要5-10分钟），查看节点概要信息。至此，master启动成功__

```sh
# 查看节点概要信息
kubectl get nodes

# 得到如下输出
NAME         STATUS    ROLES     AGE       VERSION
k8s-master   Ready     master    26m       v1.11.1
```

## 3.1 Restart

__如果我们将master这台机器重启的话，k8s服务不会自动起来，需要进行如下操作__

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

__另外启动两台虚拟机，执行 [Install Kubeadm](#install-kubeadm) 小节的所有操作__

__现在需要将新启动的虚拟机，加入刚才启动的master__

* 还记得master节点初始化k8s输出的`kubeadm join`命令吗，这个指令就用于node节点
* 如果忘记了，我们还可以通过在master节点上执行`kubeadm token create --print-join-command`来创建`kubeadm join`命令

__回到node节点对应的虚拟机，执行上述`kubeadm join`命令__

```sh
kubeadm join 192.168.56.108:6443 --token 3yokh0.16u9wvjk1x50nde2 --discovery-token-ca-cert-hash sha256:c36ac2694b043a660624e9d86a56999fcd23bf13b3994af6560aac713eacc54d
# 得到如下输出

[preflight] running pre-flight checks
  [WARNING RequiredIPVSKernelModulesAvailable]: the IPVS proxier will not be used, because the following required kernel modules are not loaded: [ip_vs ip_vs_rr ip_vs_wrr ip_vs_sh] or no builtin kernel ipvs support: map[ip_vs_rr:{} ip_vs_wrr:{} ip_vs_sh:{} nf_conntrack_ipv4:{} ip_vs:{}]
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
kubeadm join 192.168.56.108:6443 --token 3yokh0.16u9wvjk1x50nde2 --discovery-token-ca-cert-hash sha256:c36ac2694b043a660624e9d86a56999fcd23bf13b3994af6560aac713eacc54d

# 得到如下输出
This node has joined the cluster:
* Certificate signing request was sent to master and a response
  was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the master to see this node join the cluster.
```

__至此一台node节点加入master节点完毕（大约需要5分钟的时间，才能在master上看到ready状态），另一台node节点重复上述操作__

__全部完成后，回到master节点，执行如下指令__

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

这里以一个简单的`Spring-Boot`应用为例，制作一个镜像。__具体示例代码详见{% post_link Spring-Boot-Demo %}__

__首先，将`Spring-Boot`应用打包成一个fat-jar__，例如`spring-boot-1.0-SNAPSHOT.jar`

* 你可以随便搞一个简单的Web应用

__然后，创建Dockerfile，内容如下__

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

__将上述`Dockerfile`与`spring-boot-1.0-SNAPSHOT.jar`放入同一个目录下，此时目录结构如下__

```
.
├── Dockerfile
└── spring-boot-1.0-SNAPSHOT.jar
```

__接着，我们开始制作镜像__

```sh
# -t参数指定tag
# docker build -h 查看详细用法
docker build -t hello-world:v1 .
```

__本地测试一下，能否运行起来（经验证，没问题）__

```sh
# docker run -help 查看详细用法
docker run hello-world:v1
```

## 5.2 上传镜像到镜像仓库

__这里以`阿里云-容器镜像服务`为例，将刚才制作的镜像上传到镜像仓库。详细操作请参考[阿里云-容器镜像服务](https://www.aliyun.com/product/acr?spm=5176.10695662.1996646101.searchclickresult.3cab795dkMnIFM)__

创建完成后，镜像仓库`url`如下（你创建的镜像仓库肯定与我的不同）

```
registry.cn-hangzhou.aliyuncs.com/liuyehcf_default/liuye_repo 
```

__在`阿里云-容器镜像服务`控制台，点击刚才创建的镜像-管理，按照文档说明上传镜像，大致分为两步（以我的镜像仓库`url`为例）__

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

__首先，编写应用所在pod的yml文件，hello-world.yml文件如下__

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

__在master节点上，启动该pod__

```sh
kubectl create -f hello-world.yml
```

__查看pod运行状态，可以看到pod部署成功__

```sh
kubectl get pod

# 以下是输出信息
NAME          READY     STATUS    RESTARTS   AGE
hello-world   1/1       Running   0          4m
```

__由于我们这个Web应用服务在8080端口，但是上面的`hello-world.yml`文件中配置的是容器端口，我们仍然不能在外界访问这个服务。我们还需要增加一个`hello-world-service`，`hello-world-service.yml`文件内容如下__

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

__启动service__

```sh
kubectl create -f hello-world-service.yml
```

__查看端口号（nodePort）__

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

__访问`http://<node_ip>:30001/home`，成功！__

# 6 Helm

__步骤__

1. 下载，二进制包，传送门[helm release](https://github.com/helm/helm/releases)
1. 解压缩，`tar -zxvf <file>`
1. `mv linux-amd64/helm /usr/local/bin/helm`
1. `helm init`

## 6.1 参考

* [github helm](https://github.com/helm/helm/blob/master/docs/install.md)
* [helm doc](https://helm.sh/docs/using_helm/#quickstart-guide)

# 7 Ingress

__helm安装（未成功）__

1. `helm install stable/nginx-ingress --name my-nginx`

__非helm安装__

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

__Ingress Controller的作用__

1. 读取`Ingress`，并写入到nginx的配置文件中
1. 监听集群中`Service`的变化，及时更新backend

## 7.1 参考

* [nginx ingress doc](https://kubernetes.github.io/ingress-nginx/deploy/#prerequisite-generic-deployment-command)
* [metallb doc](https://metallb.universe.tf/installation/)

# 8 Command

## 8.1 kubectl

```sh
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

# 9 参考

* [Kubernetes-Creating a single master cluster with kubeadm](https://kubernetes.io/docs/setup/)
* [Kubernetes-Installing kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [issue#localhost:8080](https://github.com/kubernetes/kubernetes/issues/44665)
* [issue#x509: certificate has expired or is not yet valid](https://github.com/kubernetes/kubernetes/issues/42791)
* [kubernetes创建资源yaml文件例子--pod](https://blog.csdn.net/liyingke112/article/details/76155428)
* [十分钟带你理解Kubernetes核心概念](http://www.dockone.io/article/932)
