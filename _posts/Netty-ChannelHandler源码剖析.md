---
title: Netty-ChannelHandler源码剖析
date: 2017-12-07 16:10:14
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

本篇博文主要以ChannelInboundHandlerAdapter以及ChannelOutboundHandlerAdapter为例，对ChannelHandler的组成结构进行分析

# 2 ChannelInboundHandlerAdapter

## 2.1 继承结构

![ChannelInboundHandlerAdapter](/images/Netty-ChannelHandler源码剖析/ChannelInboundHandlerAdapter.png)

## 2.2 ChannelHandler

ChannelHandler定义了最近本的Handler的功能，即添加或删除Handler

![ChannelHandler](/images/Netty-ChannelHandler源码剖析/ChannelHandler.png)

## 2.3 ChannelInboundHandler

ChannelInboundHandler接口定义了与Inbound operations相关的一些方法

![ChannelInboundHandler](/images/Netty-ChannelHandler源码剖析/ChannelInboundHandler.png)

## 2.4 ChannelHandlerAdapter

ChannelHandlerAdapter为ChannelHandler接口提供的方法提供了一个__空的实现__，并且增加了用于判断是否是共享Handler的方法。如果是共享的Handler，则Netty可以为所有的Pipeline都注入同一个Handler，从而避免创建Handler对象的开销

由于添加或删除Handler的方法仅仅在非常特定的时刻会被触发（例如第一次register的时候），因此这里提供了一个空的实现。常见的实现该方法的类有ChannelInitializer

![ChannelHandlerAdapter](/images/Netty-ChannelHandler源码剖析/ChannelHandlerAdapter.png)

## 2.5 ChannelInboundHandlerAdapter的实现

ChannelInboundHandlerAdapter为ChannelInboundHandler接口提供了基础的实现

可以看到，ChannelInboundHandlerAdapter对于ChannelInboundHandler接口的实现非常简单。仅仅调用ChannelHandlerContext的实例ctx执行相应的方法，即将该操作的执行权传递给后面的ChannelInboundHandler。

因此，我们在自定义ChannelInboundHandler的时候，仅需要继承该ChannelInboundHandlerAdapter类，并且重写我们需要的方法即可，如果需要将操作向后传递，则务必记得加上形如`ctx.fireChannelRegistered();`的语句。对于其他不需要重写的方法，使用ChannelInboundHandlerAdapter提供的默认版本即可，即保证操作的传递性

```Java
public class ChannelInboundHandlerAdapter extends ChannelHandlerAdapter implements ChannelInboundHandler {

    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelRegistered();
    }

    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelUnregistered();
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelActive();
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelInactive();
    }

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
        ctx.fireChannelRead(msg);
    }

    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelReadComplete();
    }

    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
        ctx.fireUserEventTriggered(evt);
    }

    @Override
    public void channelWritabilityChanged(ChannelHandlerContext ctx) throws Exception {
        ctx.fireChannelWritabilityChanged();
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause)
            throws Exception {
        ctx.fireExceptionCaught(cause);
    }
}
```

# 3 ChannelOutboundHandlerAdapter

## 3.1 继承结构

![ChannelOutboundHandlerAdapter](/images/Netty-ChannelHandler源码剖析/ChannelOutboundHandlerAdapter.png)

## 3.2 ChannelOutboundHandler

ChannelOutboundHandler接口定义了与Outbound operations相关的一些方法

![ChannelOutboundHandler](/images/Netty-ChannelHandler源码剖析/ChannelOutboundHandler.png)

## 3.3 ChannelOutboundHandlerAdapter的实现

ChannelOutboundHandlerAdapter为ChannelOutboundHandler接口提供了基础实现

与ChannelInboundHandlerAdapter的实现类似，ChannelOutboundHandlerAdapter的实现也仅仅保证了操作的传递性

用户在自定义ChannelOutboundHandler的时候，只需要继承该类，并且重写关注的方法即可

```Java
public class ChannelOutboundHandlerAdapter extends ChannelHandlerAdapter implements ChannelOutboundHandler {

    @Override
    public void bind(ChannelHandlerContext ctx, SocketAddress localAddress,
            ChannelPromise promise) throws Exception {
        ctx.bind(localAddress, promise);
    }

    @Override
    public void connect(ChannelHandlerContext ctx, SocketAddress remoteAddress,
            SocketAddress localAddress, ChannelPromise promise) throws Exception {
        ctx.connect(remoteAddress, localAddress, promise);
    }

    @Override
    public void disconnect(ChannelHandlerContext ctx, ChannelPromise promise)
            throws Exception {
        ctx.disconnect(promise);
    }

    @Override
    public void close(ChannelHandlerContext ctx, ChannelPromise promise)
            throws Exception {
        ctx.close(promise);
    }

    @Override
    public void deregister(ChannelHandlerContext ctx, ChannelPromise promise) throws Exception {
        ctx.deregister(promise);
    }

    @Override
    public void read(ChannelHandlerContext ctx) throws Exception {
        ctx.read();
    }

    @Override
    public void write(ChannelHandlerContext ctx, Object msg, ChannelPromise promise) throws Exception {
        ctx.write(msg, promise);
    }

    @Override
    public void flush(ChannelHandlerContext ctx) throws Exception {
        ctx.flush();
    }
}
```

# 4 传递性的实现

关于这部分内容，请参考{% post_link Netty-ChannelHandlerContext源码剖析 %}
