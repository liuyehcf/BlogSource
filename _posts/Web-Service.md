---
title: Web-Service
date: 2017-12-30 20:07:16
tags: 
- 摘录
categories: 
- Web
- 服务
---

__目录__

<!-- toc -->
<!--more-->

# 1 Web Service与Web Server

Web Service：__一种跨编程语言和跨操作系统平台的远程调用技术__

Web Server：像`IIS`/`APACHE`/`ZEUS`这类的软件都叫做Web Server

# 2 Web Service

Web service是一个平台独立的，低耦合的，自包含的、基于可编程的web的应用程序，可使用开放的XML（标准通用标记语言下的一个子集）标准来__描述、发布、发现、协调和配置__这些应用程序，用于开发分布式的互操作的应用程序

__SOAP、WSDL和UDDI构成了web Service的三要素__

## 2.1 SOAP

Simple Object Access Protocol，中文为简单对象访问协议，简称SOAP

SOAP是基于XML在分散或分布式的环境中交换信息的简单的协议。允许服务提供者和服务客户经过防火墙在INTERNET进行通讯交互

SOAP的设计是为了在一个松散的、分布的环境中使用XML对等地交换结构化的和类型化的信息提供了一个简单且轻量级的机制

## 2.2 WSDL

Web Services Description Language，网络服务描述语言，简称WSDL。它是一门基于XML的语言，用于描述Web Services以及如何对它们进行访问

对于接口来说，接口文档非常重要，它描述如何访问接口。那么WSDL就可以看作Web Service接口的一种标准格式的“文档”。我们通过阅读WSDL就知道如何调用Web Service接口了

## 2.3 UDDI

Universal Description, Discovery and Integration，通用描述、发现与集成服务，简称UDDI

WSDL用来描述了访问特定的Web Service的一些相关的信息，那么在互联网上，或者是在企业的不同部门之间，如何来发现我们所需要的Web Service呢？而Web Service提供商又如何将自己开发的Web Serivce公布到因特网上呢？这就需要使用到UDDI了

UDDI可以帮助Web服务提供商在互联网上发布Web services的信息。UDDI是一种目录服务，企业可以通过UDDI来注册和搜索Web services

## 2.4 Web Services体系结构

在Web Serivce的体系结构中涉及到三个角色：一个是Web Service提供者；一个是Web Service中介者；一个是Web Service请求者

1. __Web Service提供者__：可以发布Web Service，并且对使用自身服务的请求进行响应，Web Service的拥有者，它会等待其他的服务或者是应用程序访问自己
1. __Web Service请求者__：也就是Web Service功能的使用者，它通过服务注册中心也就是Web Service中介者查找到所需要的服务，再利用SOAP消息向Web Service提供者发送请求以获得服务
1. __Web Service中介者__：也称为服务代理，用来注册已经发布的Web Service提供者，并对其进行分类，同时提供搜索服务，简单来说的话，Web Service中介者的作用就是把一个Web Service请求者和合适的Web Service提供者联系在一起，充当一个管理者的角色，一般是通过UDDI来实现

同时还涉及到三类动作：发布；查找；绑定

1. __发布__：通过发布操作，可以使Web Serivce提供者向Web Service中介注册自己的功能以及访问的接口
1. __发现（查找）__：使得Web Service请求者可以通过Web Service中介者来查找到特定种类的Web Service 接口
1. __绑定__：这里就是实现让Web Serivce请求者能够使用Web Serivce提供者提供的Web Serivce接口

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [web service 和 web server区别](https://zhidao.baidu.com/question/13577128.html)
* [浅谈 SOAP Webserver 与 Restful Webserver 区别](https://www.cnblogs.com/hyhnet/archive/2016/06/28/5624422.html)
* [Web Service概念梳理](https://www.cnblogs.com/fnng/p/5524801.html)
