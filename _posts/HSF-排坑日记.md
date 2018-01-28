---
title: HSF-排坑日记
date: 2018-01-07 22:25:37
tags: 
- 原创
categories: 
- Java
- Framework
- HSF
password: 19930101
---

__目录__

<!-- toc -->
<!--more-->

# 1 网络环境问题

情景描述：使用自己的mac电脑，下载了HSFdemo工程，无法发布服务，错误如下：

```Java
...
Exception in thread "main" java.lang.NoClassDefFoundError: Could not initialize class com.taobao.diamond.client.impl.DiamondEnvRepo
...
```

__原因：没有连上内网，HSF-Client拉取不到CS以及Diamond的服务器列表__

于是用阿里郎开启了vpn，重新尝试发布服务，成功（在HSF控制台能够找到我发布的服务，并且进行测试）

于是，接着本地启动HSF-Consumer，无法消费服务，错误如下：

```Java
Caused by: HSFServiceAddressNotFoundException-
描述信息：[HSF-Consumer] 未找到需要调用的服务的目标地址, 需要调用的目标服务为：com.alibaba.chenlu.hsf.TimeService:1.0.6.DAILY 组别为：chenlu ERR-CODE: [HSF-0001], Type: [环境问题], More: [http:// console.taobao.net/help/HSF-0001]
```

__解决方法__

1. ifconfig查询本机ip，找到utunX（X是数字）的ipv4的ip地址，我这里是`10.65.149.244`
1. 增加一条路由规则，命令如下
    * `sudo route change <vpn地址> 127.0.0.1`
    * 以我自己电脑为例，`sudo route change 10.65.149.244 127.0.0.1`

__再次消费，成功！__

---

以上是开启vpn时解决服务无法消费的问题。另一个问题是，我自己的电脑明明连着公司内网，但也无法发布和消费服务，总开vpn也不是个办法

__原因：DNS服务器没有设置！__

__解决方法：增加DNS服务器地址__

1. 10.65.1.3
1. 10.65.1.1
1. 10.20.0.4
1. 10.20.0.97

__发布和消费服务，都成功了！__
