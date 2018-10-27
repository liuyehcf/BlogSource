---
title: Netty-ChannelPipeline源码剖析
date: 2017-12-07 13:50:27
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__阅读更多__

<!--more-->

# 1 前言

本篇博文以DefaultChannelPipeline为例对ChannelPipeLine的结构进行分析

# 2 继承结构

DefaultChannelPipeline继承关系比较简单，如下图

![DefaultChannelPipeline](/images/Netty-ChannelPipeline源码剖析/DefaultChannelPipeline.png)

## 2.1 ChannelOutboundInvoker

ChannelOutboundInvoker接口定义了与ChannelOutboundHandler相似的方法

![ChannelOutboundInvoker](/images/Netty-ChannelPipeline源码剖析/ChannelOutboundInvoker.png)

## 2.2 ChannelInboundInvoker

ChannelInboundInvoker接口定义了与ChannelInboundHandler相似的方法

![ChannelInboundInvoker](/images/Netty-ChannelPipeline源码剖析/ChannelInboundInvoker.png)

## 2.3 ChannelPipeline

ChannelPipeline增加了一些用于添加和删除Handler的方法。ChannelPipeline的作用就是管理Handler，以及在特定位置触发相应的Handler，从而织入Netty内置的Handler或者用户自定义的Handler

![ChannelPipeline](/images/Netty-ChannelPipeline源码剖析/ChannelPipeline.png)

# 3 DefaultChannelPipeline

DefaultChannelPipeline为ChannelPipeline接口提供了基本的实现

DefaultChannelPipeline的作用就是用于存放所有Netty内置的Handler或者用户自定义的Handler，并且提供触发这些Handler的方法

__包含如下重要字段__

1. `AbstractChannelHandlerContext head`：Pipeline中所有的Handler形成一个双向链表，这是表头
1. `AbstractChannelHandlerContext tail`：Pipeline中所有的Handler形成一个双向链表，这是表尾
1. `Channel channel`：关联的Channel，一个Pipeline与一个Channel一一对应
1. `Map<EventExecutorGroup, EventExecutor> childExecutors`：每个Pipeline可能在不同的EventExecutorGroup中都关联一个EventExecutor，用于存放键值对的Map
1. `firstRegistration = true`：用于标记是否第一次执行注册操作，由于有些handler仅在第一次触发register操作的时候才会执行，例如`handlerAdded`方法（一般与ChannelInitializer配合注入用户自定义的或者Netty内置的Handler到pipeline中去），该handlerAdded方法通过PendingHandlerCallback的execute方法触发
1. `PendingHandlerCallback pendingHandlerCallbackHead`：用于触发一些特定的Handler，例如`handlerAdded`方法，该方法通常只触发一次。与`firstRegistration`字段密切相关

此外，head字段绑定的Handler与tail字段绑定的Handler是两个特殊的Handler，这两个特殊的Handler位于整个pipeline的首尾，因此会进行一些额外的预处理或者收尾工作
