---
title: Netty-Channel源码剖析
date: 2017-12-07 13:49:51
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

本篇博文以NioSocketChannel以及NioServerSocketChannel为例，分析一下Netty中Channel的结构

# 2 NioSocketChannel

## 2.1 继承结构图

![NioSocketChannel](/images/Netty-Channel源码剖析/NioSocketChannel.png)

## 2.2 ChannelOutboundInvoker

ChannelOutboundInvoker接口定义了一些与outbound operation相关的方法，类似的方法也在ChannelOutboundHandler接口中有定义

![ChannelOutboundInvoker](/images/Netty-Channel源码剖析/ChannelOutboundInvoker.png)

## 2.3 Channel

Channel接口非常重要，从该接口中可以看出Netty中Channel的基本组成结构

1. 每个Channel关联一个EventLoop（一般是NioEventLoop），Channel的所有操作都是通过EventLoop来执行的
1. 每个Channel关联一个Unsafe，该Unsafe对象负责完成所有底层的IO操作
1. 每个Channel关联一个PipeLine，PipeLine用于织入一些Netty内置的Handler以及用户自定义的Handler，通过Unsafe、Channel以及PipeLine的相互配合从而触发这些Handler的调用

![Channel](/images/Netty-Channel源码剖析/Channel.png)

## 2.4 DuplexChannel

DuplexChannel进一步将Channel抽象成双向的，包含In方向和Out方向

![DuplexChannel](/images/Netty-Channel源码剖析/DuplexChannel.png)

## 2.5 SocketChannel

SocketChannel进一步引入Socket的相关概念，比如InetSocketAddress，即IP和端口号

![SocketChannel](/images/Netty-Channel源码剖析/SocketChannel.png)

## 2.6 AttributeMap

AttributeMap定义了一种用于添加关键字以及判断关键字是否存在的Map

![AttributeMap](/images/Netty-Channel源码剖析/AttributeMap.png)

## 2.7 DefaultAttributeMap

DefaultAttributeMap抽象类对AttributeMap接口提供了基本的实现

![DefaultAttributeMap](/images/Netty-Channel源码剖析/DefaultAttributeMap.png)

## 2.8 AbstractChannel

AbstractChannel抽象类对Channel接口（包括Channel的父接口）提供了基本的实现，包含了底层的IO操作

![AbstractChannel](/images/Netty-Channel源码剖析/AbstractChannel.png)

**AbstractChannel包含如下关键字段**

1. `Channel parent`：与当前Channel相关联的Channel，比如NioServerSocketChannel中创建的NioSocketChannel，那么NioServerSocketChannel就是NioSocketChannel的parent Channel
1. `Unsafe unsafe`：用于底层IO操作的对象，该字段的初始化会调用一个protected方法，AbstractChannel可以重写该方法来绑定特殊的Unsafe对象
1. `DefaultChannelPipeline pipeline`：关联的PipeLine
1. `SocketAddress localAddress`：本地地址，该地址是抽象的，未指定任何协议
1. `SocketAddress remoteAddress`：远程地址，该地址是抽象的，未指定任何协议
1. `EventLoop eventLoop`：当前Channel关联的EventLoop，即一个线程池

此外，AbstractChannel抽象类实现了**非静态**内部类AbstractUnsafe

## 2.9 AbstractNioChannel

AbstractNioChannel抽象类实现了Channel的isOpen方法，重写了AbstractChannel的几个方法（修改返回类型）

![AbstractNioChannel](/images/Netty-Channel源码剖析/AbstractNioChannel.png)

**AbstractNioChannel包含如下关键字段**

1. `SelectableChannel ch`：底层的Java NIO原生Channel
1. `int readInterestOp`：感兴趣的操作
1. `SelectionKey selectionKey`：底层的Java NIO原生SelectionKey
1. `SocketAddress requestedRemoteAddress`：当主动发起连接时，保存远程的Socket地址

此外，AbstractNioChannel抽象类实现了**非静态**内部类AbstractNioUnsafe

## 2.10 AbstractNioByteChannel

AbstractNioByteChannel抽象类实现了Channel接口的metadata方法

![AbstractNioByteChannel](/images/Netty-Channel源码剖析/AbstractNioByteChannel.png)

此外，AbstractNioByteChannel抽象类实现了**非静态**内部类NioByteUnsafe（实现read方法）

## 2.11 NioSocketChannel

NioSocketChannel类实现了DuplexChannel接口以及SocketChannel提供的方法

![NioSocketChannelMethod](/images/Netty-Channel源码剖析/NioSocketChannelMethod.png)

# 3 NioServerSocketChannel

## 3.1 继承结构图

NioServerSocketChannel的继承关系与NioSocketChannel类似，但有以下区别

* AbstractNioByteChannel被替换成了AbstractNioMessageChannel
* DuplexChannel被替换成了ServerChannel
* SocketChannel被替换成了ServerSocketChannel

![NioServerSocketChannel](/images/Netty-Channel源码剖析/NioServerSocketChannel.png)

## 3.2 ServerChannel

ServerChannel是一个空接口

## 3.3 ServerSocketChannel

ServerSocketChannel接口修改了Channel接口中的3个方法的返回值

![ServerSocketChannel](/images/Netty-Channel源码剖析/ServerSocketChannel.png)

## 3.4 AbstractNioMessageChannel

AbstractNioMessageChannel抽象类主要定义了**非静态内部类**NioMessageUnsafe（实现read方法）
