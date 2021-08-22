---
title: Spring-Cloud-Overview
date: 2018-07-12 16:44:34
tags: 
- 摘录
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 Overview

Spring Cloud为开发人员提供了快速构建分布式系统中一些常见模式的工具（**例如`配置管理`，`服务发现`，`断路器`，`智能路由`，`微代理`，`控制总线`**）。 分布式系统的协调导致锅炉板模式，使用Spring Cloud开发人员可以快速站起来实现这些模式的服务和应用程序。 它们适用于任何分布式环境，包括开发人员自己的笔记本电脑，裸机数据中心和Cloud Foundry等托管平台。

# 2 特性

1. 分布式/版本化配置
1. 服务注册和发现
1. 路由
1. 服务调用
1. 负载均衡
1. 断路器
1. 分布式消息

# 3 核心模块

1. Cloud Native Applications
1. Spring Cloud Config
1. Spring Cloud Netflix
1. Spring Cloud OpenFeign
1. Spring Cloud Stream
1. Binder Implementations
1. Spring Cloud Bus
1. Spring Cloud Sleuth
1. Spring Cloud Consul
1. Spring Cloud Zookeeper
1. Spring Cloud Security
1. Spring Cloud for Cloud Foundry
1. Spring Cloud Contract
1. Spring Cloud Vault
1. Spring Cloud Gateway
1. Spring Cloud Function

# 4 Cloud Native Applications

> Cloud Native is a style of application development that encourages easy adoption of best practices in the areas of continuous delivery and value-driven development. A related discipline is that of building 12-factor Applications, in which development practices are aligned with delivery and operations goals — for instance, by using declarative programming and management and monitoring. Spring Cloud facilitates these styles of development in a number of specific ways. The starting point is a set of features to which all components in a distributed system need easy access.

> Many of those features are covered by Spring Boot, on which Spring Cloud builds. Some more features are delivered by Spring Cloud as two libraries: Spring Cloud Context and Spring Cloud Commons. Spring Cloud Context provides utilities and special services for the ApplicationContext of a Spring Cloud application (bootstrap context, encryption, refresh scope, and environment endpoints). Spring Cloud Commons is a set of abstractions and common classes used in different Spring Cloud implementations (such as Spring Cloud Netflix and Spring Cloud Consul).

# 5 Spring Cloud Config

> Spring Cloud Config provides server-side and client-side support for externalized configuration in a distributed system. With the Config Server, you have a central place to manage external properties for applications across all environments. The concepts on both client and server map identically to the Spring Environment and PropertySource abstractions, so they fit very well with Spring applications but can be used with any application running in any language. As an application moves through the deployment pipeline from dev to test and into production, you can manage the configuration between those environments and be certain that applications have everything they need to run when they migrate. The default implementation of the server storage backend uses git, so it easily supports labelled versions of configuration environments as well as being accessible to a wide range of tooling for managing the content. It is easy to add alternative implementations and plug them in with Spring configuration.

微服务架构中，每个微服务的运行，都会读取不同环境的不同配置信息，而Spring Cloud Config（百度的 Disconf 与之类似）便提供了适用于分布式系统的、集中式的外部化配置支持，它能够统一集中管理所有应用的、所有环境的配置文件，且支持热更新。**其默认采用git仓库存储配置信息，好处是git工具便可轻松管理配置内容**

# 6 Spring Cloud Netflix

> This project provides Netflix OSS integrations for Spring Boot apps through autoconfiguration and binding to the Spring Environment and other Spring programming model idioms. With a few simple annotations you can quickly enable and configure the common patterns inside your application and build large distributed systems with battle-tested Netflix components. The patterns provided include **Service Discovery (Eureka), Circuit Breaker (Hystrix), Intelligent Routing (Zuul) and Client Side Load Balancing (Ribbon).**

## 6.1 Eureka

`Eureka`是`Netflix`开发的（现已被集成到`Spring Cloud Netflix`项目中），**一个基于`REST`服务的，服务注册与发现的组件**，它主要包括两个组件：`Eureka Server`和`Eureka Client`

1. `Eureka Client`：一个Java客户端，用于简化与Eureka Server 的交互（通常就是微服务中的客户端和服务端）
1. `Eureka Server`：提供服务注册和发现的能力（通常就是微服务中的注册中心）

各个微服务启动时，会通过`Eureka Client`向`Eureka Server`注册自己，`Eureka Server`会存储该服务的信息。也就是说，每个微服务的客户端和服务端，都会注册到`Eureka Server`，这就衍生出了微服务相互识别的话题

1. **同步**：每个`Eureka Server`同时也是`Eureka Client`（逻辑上的）。多个`Eureka Server`之间通过复制的方式完成服务注册表的同步，形成`Eureka`的高可用
1. **识别**：`Eureka Client`会缓存`Eureka Server`中的信息。即使所有`Eureka Server`节点都宕掉，服务消费者仍可使用缓存中的信息找到服务提供者
1. **续约**：微服务会周期性（默认30s）地向`Eureka Server`发送心跳以Renew（续约）自己的信息（类似于heartbeat）
1. **续期**：`Eureka Server`会定期（默认60s）执行一次失效服务检测功能。它会检查超过一定时间（默认90s）没有Renew的微服务，发现则会注销该微服务节点

`Eureka`有一个`Region`和`Zone`的概念，你可以理解为现实中的大区（Region）和机房（Zone）

* `Eureka Client`在启动时需要指定`Zone`，它会优先请求自己 `Zone`的`Eureka Server`获取注册列表
* `Eureka Server`在启动时也需要指定`Zone`，如果没有指定的话，其会默认使用`defaultZone`

## 6.2 Hystrix

微服务架构中，一般都存在着很多的服务单元。这样就有可能出现一个单元因为网络原因或自身问题而出现故障或延迟，导致调用方的对外服务也出现延迟。如果此时调用方的请求不断增加，时间一长就会出现由于等待故障方响应而形成任务积压，最终导致调用方自身服务的瘫痪。**为了解决这种问题：便出现了断路器（或者叫熔断器，Cricuit Breaker）模式**。断路器模式源于`Martin Fowler`的`Circuit Breaker`一文。我们日常生活中的断路器，本身是一种开关装置，用于在电路上保护线路过载。当线路中有电器发生短路时，它能够及时切断故障电路，防止发生过载、发热、甚至起火等严重后果。**而微服务架构中的断路器，其作用是：当某个服务单元发生故障（类似用电器短路）之后，通过断路器的故障监控（类似熔断保险丝），向调用方返回一个错误响应，而不是长时间的等待**。这就不会使得线程被故障服务长时间占用而不释放，避免了故障在分布式系统中的蔓延

`Hystrix`正是`Netflix`开源的`javanica`提供的微服务框架套件之一。它是由Java实现的，用来处理分布式系统发生故障或延迟时的容错库，它提供了`断路器`、`资源隔离`、`自我修复`三大功能

1. **断路器**：
    * 实际可初步理解为快速失败，快速失败是防止资源耗尽的关键点
    * 当`Hystrix`发现在过去某段时间内对服务`AA`的调用出错率达到阀值时，它就会“熔断”该服务，后续任何向服务`AA`的请求都会快速失败，而不是白白让调用线程去等待
1. **资源隔离**
    * 首先，`Hystrix`对每一个依赖服务都配置了一个线程池，对依赖服务的调用会在线程池中执行
    * 比如，服务`AA`的线程池大小为20，那么`Hystrix`会最多允许有20个容器线程调用服务AA（超出20，它会拒绝并快速失败）
    * 这样即使服务`AA`长时间未响应，容器最多也只能堵塞20个线程，剩余的线程仍然可以处理用户请求
1. **自我修复**
    * 处于熔断状态的服务，在经过一段时间后，`Hystrix`会让其进入“半关闭”状态（即允许少量请求通过），然后统计调用的成功率，若每个请求都能成功，`Hystrix`会恢复该服务，从而达到自我修复的效果
    * 其中，在服务被熔断到进入“半关闭”状态之间的时间，就是留给开发人员排查错误并恢复故障的时间

`Hystrix`基于命令模式`HystrixCommand`来包装依赖调用逻辑，其每个命令在单独线程中或信号授权下执行（Command 是在 Receiver 和 Invoker 之间添加的中间层，Command 实现了对 Receiver 的封装）。Hystrix支持两种隔离策略：**线程池隔离**和**信号量隔离**（都是限制对共享资源的并发访问量）

1. ThreadPool
    * 根据配置把不同命令分配到不同的线程池中，这是比较常用的隔离策略，其优点是隔离性好，并且可以配置断路
    * 某个依赖被设置断路之后，系统不会再尝试新起线程运行它，而是直接提示失败，或返回fallback值
    * 它的缺点是新起线程执行命令，在执行时必然涉及上下文的切换，这会造成一定的性能消耗，但是`Netflix`做过实验，这种消耗对比其带来的价值是完全可以接受的，具体的数据参见[Hystrix-Wiki](https://github.com/Netflix/Hystrix/wiki/How-it-Works#Isolation)
1. Semaphores
    * 顾名思义就是使用一个信号量来做隔离
    * 开发者可以限制系统对某一个依赖的最高并发数，这个基本上就是一个限流的策略
    * 每次调用依赖时都会检查一下是否到达信号量的限制值，如达到，则拒绝
    * 该策略的优点是不新起线程执行命令，减少上下文切换，缺点是无法配置断路，每次都一定会去尝试获取信号量

## 6.3 Zuul

服务提供方和消费方都注册到注册中心，使得消费方能够直接通过 `ServiceId`访问服务方。但是，**通常我们的服务方可能都需要做`接口权限校验`、`限流`、`软负载均衡`等等**。而这类工作，**完全可以交给服务方的更上一层：服务网关，来集中处理**。这样做是为了保证微服务的无状态性，使其更专注于业务处理。所以说，服务网关是微服务架构中一个很重要的节点，`Spring Cloud Netflix`中的`Zuul`就担任了这样的角色。当然了，除了`Zuul`之外，还有很多软件也可以作为`API Gateway`的实现，比如`Nginx Plus`、`Kong`等等

通过服务路由的功能，可以在对外提供服务时，只暴露`Zuul`中配置的调用地址，而调用方就不需要了解后端具体的微服务主机。`Zuul`提供了两种映射方式：`URL映射`和`ServiceId映射`（后者需要将`Zuul`注册到注册中心，使之能够发现后端的微服务）

* `ServiceId`映射的好处是：它支持软负载均衡，基于`URL`的方式是不支持的

## 6.4 Ribbon

[Ribbon](https://github.com/Netflix/ribbon)是一个基于 `HTTP`和`TCP`客户端的负载均衡器

它可以在客户端配置`ribbonServerList`（服务端列表），然后轮询请求以实现均衡负载。**它在联合`Eureka`使用时，`ribbonServerList`会被 `DiscoveryEnabledNIWSServerList`重写，扩展成从`Eureka`注册中心获取服务端列表**。同时它也会用 `NIWSDiscoveryPing`来取代`IPing`，**它将职责委托给`Eureka`来确定服务端是否已经启动**

# 7 Spring Cloud OpenFeign

> This project provides OpenFeign integrations for Spring Boot apps through autoconfiguration and binding to the Spring Environment and other Spring programming model idioms.

`Spring Cloud Netflix`的微服务都是以`HTTP`接口的形式暴露的，所以可以用`Apache`的`HttpClient`或`Spring`的`RestTemplate`去调用。而[Feign](https://github.com/OpenFeign/feign)是一个使用起来更加方便的`HTTP`客户端，它用起来就好像调用本地方法一样，完全感觉不到是调用的远程方法

总结起来就是：发布到注册中心的服务方接口，是`HTTP`的，也可以不用 `Ribbon`或者`Feign`，直接浏览器一样能够访问

只不过`Ribbon`或者`Feign`调用起来要方便一些，最重要的是：它俩都支持软负载均衡（`Feign`封装了`Ribbon`）

# 8 Spring Cloud Stream

> A Spring Cloud Stream application consists of a middleware-neutral core. The application communicates with the outside world through input and output channels injected into it by Spring Cloud Stream. Channels are connected to external brokers through middleware-specific Binder implementations.

# 9 Binder Implementations

# 10 Spring Cloud Bus

> Spring Cloud Bus links the nodes of a distributed system with a lightweight message broker. This broker can then be used to broadcast state changes (such as configuration changes) or other management instructions. A key idea is that the bus is like a distributed actuator for a Spring Boot application that is scaled out. However, it can also be used as a communication channel between apps. This project provides starters for either an AMQP broker or Kafka as the transport.

简而言之，消息中间件

# 11 Spring Cloud Sleuth

# 12 Spring Cloud Consul

> This project provides Consul integrations for Spring Boot apps through autoconfiguration and binding to the Spring Environment and other Spring programming model idioms. With a few simple annotations you can quickly enable and configure the common patterns inside your application and build large distributed systems with Consul based components. The patterns provided include Service Discovery, Control Bus and Configuration. Intelligent Routing (Zuul) and Client Side Load Balancing (Ribbon), Circuit Breaker (Hystrix) are provided by integration with Spring Cloud Netflix.

# 13 Spring Cloud Zookeeper

> This project provides Zookeeper integrations for Spring Boot applications through autoconfiguration and binding to the Spring Environment and other Spring programming model idioms. With a few annotations, you can quickly enable and configure the common patterns inside your application and build large distributed systems with Zookeeper based components. The provided patterns include Service Discovery and Configuration. Integration with Spring Cloud Netflix provides Intelligent Routing (Zuul), Client Side Load Balancing (Ribbon), and Circuit Breaker (Hystrix).

# 14 Spring Cloud Security

> Spring Cloud Security offers a set of primitives for building secure applications and services with minimum fuss. A declarative model which can be heavily configured externally (or centrally) lends itself to the implementation of large systems of co-operating, remote components, usually with a central indentity management service. It is also extremely easy to use in a service platform like Cloud Foundry. Building on Spring Boot and Spring Security OAuth2 we can quickly create systems that implement common patterns like single sign on, token relay and token exchange.

# 15 Spring Cloud for Cloud Foundry

> Spring Cloud for Cloudfoundry makes it easy to run Spring Cloud apps in Cloud Foundry (the Platform as a Service). Cloud Foundry has the notion of a "service", which is middlware that you "bind" to an app, essentially providing it with an environment variable containing credentials (e.g. the location and username to use for the service).

# 16 Spring Cloud Contract

# 17 Spring Cloud Vault

> Spring Cloud Vault Config provides client-side support for externalized configuration in a distributed system. With HashiCorp’s Vault you have a central place to manage external secret properties for applications across all environments. Vault can manage static and dynamic secrets such as username/password for remote applications/resources and provide credentials for external services such as MySQL, PostgreSQL, Apache Cassandra, MongoDB, Consul, AWS and more.

# 18 Spring Cloud Gateway

> This project provides an API Gateway built on top of the Spring Ecosystem, including: Spring 5, Spring Boot 2 and Project Reactor. Spring Cloud Gateway aims to provide a simple, yet effective way to route to APIs and provide cross cutting concerns to them such as: security, monitoring/metrics, and resiliency.

# 19 Spring Cloud Function

> Spring Cloud Function is a project with the following high-level goals:
> * Promote the implementation of business logic via functions.
> * Decouple the development lifecycle of business logic from any specific runtime target so that the same code can run as a web endpoint, a stream processor, or a task.
> * Support a uniform programming model across serverless providers, as well as the ability to run standalone (locally or in a PaaS).
> * Enable Spring Boot features (auto-configuration, dependency injection, metrics) on serverless providers.

# 20 参考

* [Spring Cloud官方文档](http://cloud.spring.io/spring-cloud-static/Finchley.RELEASE/single/spring-cloud.html)
* [SpringCloud系列第02节之注册中心Eureka](https://jadyer.cn/2017/01/16/springcloud-eureka/)
* [SpringCloud系列第04节之注册中心Eureka高可用](https://jadyer.cn/2017/01/18/springcloud-eureka-high-availability/)
* [SpringCloud系列第05节之服务消费Ribbon和Feign](https://jadyer.cn/2017/01/19/springcloud-ribbon-feign/)
* [SpringCloud系列第06节之断路器Hystrix](https://jadyer.cn/2017/04/14/springcloud-hystrix/)
* [SpringCloud系列第07节之服务网关Zuul](https://jadyer.cn/2017/04/15/springcloud-zuul/)
* [SpringCloud系列第08节之配置中心Config](https://jadyer.cn/2017/04/17/springcloud-config/)
* [SpringCloud系列第09节之消息总线Bus](https://jadyer.cn/2017/04/19/springcloud-bus/)
* [SpringCloud服务注册中心比较:Consul vs Zookeeper vs Etcd vs Eureka](https://blog.csdn.net/qq_24084925/article/details/78869474)
