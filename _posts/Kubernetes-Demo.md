---
title: Kubernetes-Demo
date: 2018-07-17 21:01:40
tags: 
- 原创
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 环境

`Virtual Box`+`CentOS-7-x86_64-Minimal-2009.iso`

**配置（master与worker相同）**

1. 系统配置：`2C4G`
1. 网络配置：`NAT 网络`+`HostOnly`

# 2 搭建步骤

## 2.1 step1：准备工作

该步骤，每台机器都需要执行，包括`master`和`worker`的节点

```sh
# docker安装
# --step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# --step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# --step 3
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# --step 4: 更新并安装docker-ce，可以通过 yum list docker-ce --showduplicates | sort -r 查询可以安装的版本列表
yum makecache fast
yum -y install docker-ce-20.10.5-3.el7
# --step 5: 开启docker服务
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

# 禁用swap
sed -ri '/ swap /s|^([^#].*)$|#\1|' /etc/fstab

# 关闭防火墙
systemctl disable firewalld
systemctl stop firewalld

# 关闭selinux
sed -r -i '/SELINUX=/s/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# 修改主机名，每台机器都必须不一样
hostnamectl set-hostname <xxx>

# 重启
reboot
```

## 2.2 step2：安装kubeadm、kubectl等工具

该步骤，每台机器都需要执行，包括`master`和`worker`的节点

安装步骤可以参考[Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

```sh
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

## 2.3 step3：初始化master

```sh
kubeadm init --pod-network-cidr=10.169.0.0/16 --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers
#-------------------------↓↓↓↓↓↓-------------------------
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.0.2.25:6443 --token yokoe3.huvu1vzcllt96zt7 \
    --discovery-token-ca-cert-hash sha256:fd27e0a6257017ad8c2b25386d02db27ebaaca1916a97d2e8811ce4945bf430b
#-------------------------↑↑↑↑↑↑-------------------------
```

接下来需要安装`CNI`插件，以下插件任选一种即可

* [flannel](https://github.com/flannel-io/flannel)：`kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml`
* `calico`：`kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml`

这里，我选的是`flannel`

```sh
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#-------------------------↓↓↓↓↓↓-------------------------
podsecuritypolicy.policy/psp.flannel.unprivileged created
clusterrole.rbac.authorization.k8s.io/flannel created
clusterrolebinding.rbac.authorization.k8s.io/flannel created
serviceaccount/flannel created
configmap/kube-flannel-cfg created
daemonset.apps/kube-flannel-ds created
#-------------------------↑↑↑↑↑↑-------------------------
```

查看节点状态

```sh
kubectl get nodes
#-------------------------↓↓↓↓↓↓-------------------------
NAME         STATUS   ROLES                  AGE     VERSION
k8s-master   Ready    control-plane,master   6m35s   v1.20.5
#-------------------------↑↑↑↑↑↑-------------------------
```

**不知道为何，k8s没有为容器网络配置snat规则，这里我是手动配置的，否则容器通不了外网，其中`10.169.0.0/16`是demo集群的cidr**

```sh
iptables -t nat -A POSTROUTING -s 10.169.0.0/16 -j MASQUERADE
```

### 2.3.1 查看节点加入所需的指令

```sh
kubeadm token create --print-join-command
```

### 2.3.2 重新生成加入集群所需的token

```sh
# 以下命令在master节点执行

# 1 创建token
kubeadm token create

# 2 计算hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed  's/^ .* //'

# 在node节点执行join命令

kubeadm join <master ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## 2.4 step4：初始化worker

**使用`step3`中提示的命令，进行work的加入动作。如果忘记了这个命令怎么办？在master上执行`kubeadm token create --print-join-command`，重新获取加入指令**

```sh
kubeadm join 10.0.2.25:6443 --token yokoe3.huvu1vzcllt96zt7 \
    --discovery-token-ca-cert-hash sha256:fd27e0a6257017ad8c2b25386d02db27ebaaca1916a97d2e8811ce4945bf430b
```

查看节点状态

```sh
kubectl get nodes
#-------------------------↓↓↓↓↓↓-------------------------
NAME         STATUS   ROLES                  AGE     VERSION
k8s-master   Ready    control-plane,master   24m     v1.20.5
k8s-node-1   Ready    <none>                 8m24s   v1.20.5
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.5 step5：部署demo应用

**为了简单起见，我们用nginx作为demo应用，部署到刚创建的k8s集群中**

**首先，编写应用所在deployment的yml文件，`nginx-deployment.yml`文件如下**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
       mylabel: label_nginx
  template:
    metadata:
      labels:
        mylabel: label_nginx
    spec:
      containers:
      - name: "nginx"
        image: "nginx:1.19"
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
```

**接下来，部署应用**

```sh
kubectl apply -f nginx-deployment.yml
```

**查看pod和deployment运行状态**

```sh
kubectl get deployment
#-------------------------↓↓↓↓↓↓-------------------------
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
nginx   1/1     1            1           32m
#-------------------------↑↑↑↑↑↑-------------------------

kubectl get pods
#-------------------------↓↓↓↓↓↓-------------------------
NAME                     READY   STATUS    RESTARTS   AGE
nginx-59578f7988-chlch   1/1     Running   0          31m
#-------------------------↑↑↑↑↑↑-------------------------

```

**由于我们这个nginx应用服务在80端口，但是上面的`nginx-deployment.yml`文件中配置的是容器端口，我们仍然不能在外界访问这个服务。我们还需要增加一个`nginx-service`，`nginx-service.yml`文件内容如下**

```yml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  ports:
    - port: 4000
      targetPort: 80
      nodePort: 30001
  selector:
    mylabel: label_nginx
  type: NodePort
```

**启动service**

```sh
kubectl create -f nginx-service.yml
```

**查看服务信息**

```sh
kubectl describe svc nginx
#-------------------------↓↓↓↓↓↓-------------------------
Name:                     nginx
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 mylabel=label_nginx
Type:                     NodePort
IP Families:              <none>
IP:                       10.107.164.249
IPs:                      10.107.164.249
Port:                     <unset>  4000/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30001/TCP
Endpoints:                10.169.1.2:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
#-------------------------↑↑↑↑↑↑-------------------------
```

**访问`http://<node_ip>:30001`，成功！**

# 3 Helm

**步骤**

1. 下载，二进制包，传送门[helm release](https://github.com/helm/helm/releases)
1. 解压缩，`tar -zxvf <file>`
1. `mv linux-amd64/helm /usr/local/bin/helm`
1. `helm init`

## 3.1 参考

* [github helm](https://github.com/helm/helm/blob/master/docs/install.md)
* [helm doc](https://helm.sh/docs/using_helm/#quickstart-guide)

# 4 Command

## 4.1 kubectl

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

# 5 参考

* [Kubernetes-Creating a single master cluster with kubeadm](https://kubernetes.io/docs/setup/)
* [Kubernetes-Installing kubeadm](https://kubernetes.io/docs/setup/independent/install-kubeadm/)
* [issue#localhost:8080](https://github.com/kubernetes/kubernetes/issues/44665)
* [issue#x509: certificate has expired or is not yet valid](https://github.com/kubernetes/kubernetes/issues/42791)
* [kubernetes创建资源yaml文件例子--pod](https://blog.csdn.net/liyingke112/article/details/76155428)
* [十分钟带你理解Kubernetes核心概念](http://www.dockone.io/article/932)
* [Kubernetes集群中flannel因网卡名启动失败问题](https://blog.csdn.net/ygqygq2/article/details/81698193)
