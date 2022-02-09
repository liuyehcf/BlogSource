---
title: Presto-Trial
date: 2022-02-09 20:27:19
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 核心概念

**组件类型：**

* `Coordinator`：
    * 解析sql
    * 生成查询计划
    * 管理并调度`Worker`。同时，其自身也可作为`Worker`
* `Worker`
    * 从`Connector`中获取数据，并按照执行计划进行计算

![presto_architecture](/images/Database-Products/presto_architecture.png)

# 2 部署

一个`Presto`集群至少包含一个`Coordinator`和一个`Worker`，其中`Coordinator`可以同时作为`Coordinator`和`Worker`（生产环境最好不要这样做）

## 2.1 配置简介

**`Presto`配置相关的目录结构如下：**

* `etc/catalog`：各个`Connector`的配置，可以参考[Connectors](https://prestodb.io/docs/current/connector.html)
* `config.properties`：核心配置
* `jvm.config`：Java虚拟机相关的配置
* `log.properties`：日志相关的配置
* `node.properties`：节点元数据相关的配置

```
etc
├── catalog
│   └── mysql.properties
├── config.properties
├── jvm.config
├── log.properties
└── node.properties
```

## 2.2 部署Coordinator

参考[Deploying Presto](https://prestodb.io/docs/current/installation/deployment.html)

### 2.2.1 config.properties

* `coordinator`：必须为`true`
* `node-scheduler.include-coordinator`：`true`表示该`Coordinator`同时也作为`Worker`，单节点的`Presto`集群或者测试环境可以配置成`true`
* `http-server.http.port`：监听的`http`端口，用于节点间交互
* `discovery-server.enabled`：`true`表示当前节点作为服务发现的`server`
* `discovery.uri`：服务发现的`server`的`uri`，一般情况下，用`Coordinator`作为`server`，因此，`uri`通常为`http://<coordinator_host>:<coordinator_http-server.http.port>`

```properties
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
query.max-memory=50GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery-server.enabled=true
discovery.uri=http://example.net:8080
```

### 2.2.2 jvm.config

Java虚拟机的配置

```
-server
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
```

### 2.2.3 log.properties

一般用于配置日志级别

```properties
com.facebook.presto=INFO
```

### 2.2.4 node.properties

* `node.id`：每个机器得不一样
* `node.data-dir`：数据目录，包括日志以及运行时数据

```
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/presto/data
```

## 2.3 部署Worker

参考[Deploying Presto](https://prestodb.io/docs/current/installation/deployment.html)

### 2.3.1 config.properties

* `coordinator`：必须为false
* `http-server.http.port`：监听的`http`端口，用于节点间交互
* `discovery.uri`：服务发现的`server`的`uri`，一般情况下，用`Coordinator`作为`server`，因此，`uri`通常为`http://<coordinator_host>:<coordinator_http-server.http.port>`

```properties
coordinator=false
http-server.http.port=8080
query.max-memory=50GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery.uri=http://example.net:8080
```

### 2.3.2 jvm.config

Java虚拟机的配置

```
-server
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
```

### 2.3.3 log.properties

一般用于配置日志级别

```properties
com.facebook.presto=INFO
```

### 2.3.4 node.properties

* `node.id`：每个机器得不一样
* `node.data-dir`：数据目录，包括日志以及运行时数据

```
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/presto/data
```
