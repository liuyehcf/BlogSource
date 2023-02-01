---
title: SourceAnalysis-Netty-ChannelHandlerContext
date: 2017-12-07 13:50:34
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

**阅读更多**

<!--more-->

# 1 前言

本篇博文以DefaultChannelHandlerContext为例对ChannelHandler的结构进行分析

# 2 继承结构

![DefaultChannelHandlerContext](/images/SourceAnalysis-Netty-ChannelHandlerContext/DefaultChannelHandlerContext.png)

## 2.1 ChannelOutboundInvoker

ChannelOutboundInvoker接口定义了与ChannelOutboundHandler相似的方法

![ChannelOutboundInvoker](/images/SourceAnalysis-Netty-ChannelPipeline/ChannelOutboundInvoker.png)

## 2.2 ChannelInboundInvoker

ChannelInboundInvoker接口定义了与ChannelInboundHandler相似的方法

![ChannelInboundInvoker](/images/SourceAnalysis-Netty-ChannelPipeline/ChannelInboundInvoker.png)

## 2.3 AttributeMap

AttributeMap接口定义了一种用于添加关键字以及判断关键字是否存在的Map

![AttributeMap](/images/SourceAnalysis-Netty-Channel/AttributeMap.png)

## 2.4 DefaultAttributeMap

DefaultAttributeMap抽象类对AttributeMap接口提供了基本的实现

![DefaultAttributeMap](/images/SourceAnalysis-Netty-Channel/DefaultAttributeMap.png)

## 2.5 ChannelHandlerContext

该接口作为Handler的上下文，继承自ChannelOutboundInvoker以及ChannelInboundInvoker接口，于是包含了触发这些Handler特定方法的方法

此外，ChannelHandlerContext作为Handler的上下文

1. 与Channel一一对应
1. 与EventExecutor一一对应
1. 与Handler一一对应
1. 与Pipeline一一对应

![ChannelHandlerContext](/images/SourceAnalysis-Netty-ChannelHandlerContext/ChannelHandlerContext.png)

# 3 AbstractChannelHandlerContext

AbstractChannelHandlerContext抽象类为ChannelHandlerContext接口提供了基础实现

![AbstractChannelHandlerContext](/images/SourceAnalysis-Netty-ChannelHandlerContext/AbstractChannelHandlerContext.png)

**AbstractChannelHandlerContext包含如下重要字段**

1. `boolean inbound`：用于标记当前持有的Handler是否为ChannelInbondHandler
1. `boolean outbound`：用于标记当前持有的Handler是否为ChannelOutnbondHandler
1. `DefaultChannelPipeline pipeline`：关联的DefaultChannelPipeline
1. `boolean ordered`：关联的executor是否是OrderedEventExecutor
1. `EventExecutor executor`：关联的EventExecutor，用于执行所有的异步任务

**以`fireChannelRead`为例，分析一下Handler特定生命周期如何被触发，以及在同一个生命周期中，调用过程如何在各个ChannelHandlerContext之间的传递**

1. 首先调用findContextInbound()方法，从当前位置开始（当前ChannelHandlerContext位于双向链表中的位置）向后寻找下一个Inbond类型的ChannelHandlerContext
1. 通过静态方法invokeChannelRead触发ChannelRead方法
1. 同步或者异步方式触发指定ChannelHandlerContext的channelRead方法
1. 如果在该Handler的channelRead方法中包含`ctx.channelRead(ctx,msg)`，那么该条执行链路就会沿着双向链表向后传递

```java
    public ChannelHandlerContext fireChannelRead(final Object msg) {
        //沿着双向链表的当前位置向后找到第一个Inbound类型的ChannelHandlerContext
        invokeChannelRead(findContextInbound(), msg);
        return this;
    }

    private AbstractChannelHandlerContext findContextInbound() {
        AbstractChannelHandlerContext ctx = this;
        do {
            ctx = ctx.next;
        } while (!ctx.inbound);
        return ctx;
    }

    static void invokeChannelRead(final AbstractChannelHandlerContext next, Object msg) {
        final Object m = next.pipeline.touch(ObjectUtil.checkNotNull(msg, "msg"), next);
        EventExecutor executor = next.executor();
        if (executor.inEventLoop()) {
            //通过ChannelHandlerContext触发ChannelRead方法
            next.invokeChannelRead(m);
        } else {
            executor.execute(new Runnable() {
                @Override
                public void run() {
                    //通过ChannelHandlerContext触发ChannelRead方法
                    next.invokeChannelRead(m);
                }
            });
        }
    }

    private void invokeChannelRead(Object msg) {
        if (invokeHandler()) {
            try {
                //重定向为Handler的channelRead方法
                ((ChannelInboundHandler) handler()).channelRead(this, msg);
            } catch (Throwable t) {
                notifyHandlerException(t);
            }
        } else {
            fireChannelRead(msg);
        }
    }
```

# 4 DefaultChannelHandlerContext

**DefaultChannelHandlerContext包含如下重要字段**

1. `ChannelHandler handler`：持有的Handler
