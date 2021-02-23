---
title: Spring-Cloud-Consul-Based-Demo
date: 2018-07-17 08:48:40
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 Consul

## 1.1 安装

**方式1：下载二进制程序**

1. [consul install](https://www.consul.io/downloads.html)

**方式2：直接用包管理工具下载，以macOS为例**

1. `brew install consul`
1. 其他Linux操作系统类似，比如`yum`、`apt-get`等

## 1.2 run

**dev模式**

```sh
consul agent -dev

# 得到如下输出
==> Starting Consul agent...
==> Consul agent running!
           Version: 'v1.2.1'
           Node ID: 'ba0ffb9c-6483-6641-aaa6-70568b58a674'
         Node name: 'hechenfengdeMacBook-Pro.local'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: false)
       Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, DNS: 8600)
      Cluster Addr: 127.0.0.1 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false

==> Log data will now stream in as it occurs:
```

**server模式**

```sh
# 以下命令是官方文档提供的
consul agent -data-dir=/tmp/consul

# 启动失败，得到以下输出
==> No private IPv4 address found

# ifconfig发现确实不存在私有ip，于是通过bind指定一个ip
consul agent -server -data-dir=/tmp/consul -bind=<my ip>

# 启动成功，得到以下输出
==> Starting Consul agent...
==> Consul agent running!
           Version: 'v1.2.1'
           Node ID: 'e5d57d8e-5d28-89b7-8aeb-ef89cd55bba5'
         Node name: 'hechenfengdeMacBook-Pro.local'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: false)
       Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, DNS: 8600)
      Cluster Addr: <my ip> (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false
```
