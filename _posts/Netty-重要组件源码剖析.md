---
title: Netty-重要组件源码剖析
date: 2017-12-05 10:55:31
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__阅读更多__

<!--more-->

# 1 源码Maven坐标

```xml
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.17.Final</version>
</dependency>
```

# 2 Echo Server示例

__Handler代码清单如下__

```Java
package org.liuyehcf.protocol.echo;

import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;

/**
 * Created by HCF on 2017/12/2.
 */
public class EchoServerHandler extends ChannelInboundHandlerAdapter { // (1)

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) { // (2)
        ctx.write(msg); // (1)
        ctx.flush(); // (2)
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) { // (4)
        // Close the connection when an exception is raised.
        cause.printStackTrace();
        ctx.close();
    }
}
```

__Server代码清单如下__

```Java
package org.liuyehcf.protocol.echo;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;

/**
 * Created by HCF on 2017/12/2.
 */
public class EchoServer {
    private int port;

    public EchoServer(int port) {
        this.port = port;
    }

    public void run() throws Exception {
        EventLoopGroup bossGroup = new NioEventLoopGroup(); // (1)
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        try {
            ServerBootstrap b = new ServerBootstrap(); // (2)
            b.group(bossGroup, workerGroup)
                    .channel(NioServerSocketChannel.class) // (3)
                    .childHandler(new ChannelInitializer<SocketChannel>() { // (4)
                        @Override
                        public void initChannel(SocketChannel ch) throws Exception {
                            ch.pipeline().addLast(new EchoServerHandler());
                        }
                    })
                    .option(ChannelOption.SO_BACKLOG, 128)          // (5)
                    .childOption(ChannelOption.SO_KEEPALIVE, true); // (6)

            // Bind and start to accept incoming connections.
            ChannelFuture f = b.bind(port).sync(); // (7)

            // Wait until the server socket is closed.
            // In this example, this does not happen, but you can do that to gracefully
            // shut down your server.
            f.channel().closeFuture().sync();
        } finally {
            workerGroup.shutdownGracefully();
            bossGroup.shutdownGracefully();
        }
    }

    public static void main(String[] args) throws Exception {
        int port;
        if (args.length > 0) {
            port = Integer.parseInt(args[0]);
        } else {
            port = 8080;
        }
        new EchoServer(port).run();
    }
}
```

从示例代码中，我们找出几个核心的类型

1. `ServerBootstrap`
1. `NioEventLoopGroup`
1. `NioServerSocketChannel`
1. `ChannelInitializer`

# 3 ServerBootstrap

由于Netty启动涉及到很多复杂的步骤，因此提供了一个辅助类`ServerBootstrap`来帮助用户启动Netty，由于可配置参数种类繁多，为了保持较好的可伸缩性以及可扩展性，ServerBootstrap采用了建造者模式

ServerBootstrap的继承关系如下

![ServerBootstrap](/images/Netty-重要组件源码剖析/ServerBootstrap.png)

其中ServerBootstrap包含如下字段

1. `Map<ChannelOption<?>, Object> childOptions`：一个Map
1. `Map<AttributeKey<?>, Object> childAttrs`：一个Map
1. `ServerBootstrapConfig config`：该字段用于获取ServerBootstrap的各项参数
1. `EventLoopGroup childGroup`：
1. `ChannelHandler childHandler`：

这里涉及到两个概念，`parent`以及`child`

* parent：用于accept连接的那些组件
* child：用于客户端连接的那些组件

## 3.1 ServerBootstrapConfig

ServerBootstrapConfig用于获取ServerBootstrap的各项参数，即使ServerBootstrap的功能趋于单一

ServerBootstrapConfig的继承结构图如下

![ServerBootstrapConfig](/images/Netty-重要组件源码剖析/ServerBootstrapConfig.png)

* `AbstractBootstrapConfig`
    * 用于返回AbstractBootstrap的各项参数
* `ServerBootstrapConfig`
    * 用于返回ServerBootstrap相比于AbstractBootstrap所额外提供的参数（child相关的参数）

# 4 NioEventLoopGroup

NioEventLoopGroup管理了一组线程池，而其本身又可以被抽象成一个线程池，对NioEventLoopGroup执行的操作会通过相应策略，从其管理的线程池组中选择一个线程池进行执行

NioEventLoopGroup的继承结构图如下

![NioEventLoopGroup](/images/Netty-重要组件源码剖析/NioEventLoopGroup.png)

* `EventExecutorGroup`
    * 管理了一组Executor（一个Executor可以理解为一个线程池）
    * 另一方面，由于`EventExecutorGroup`接口间接继承自`ExecutorService`接口，因此`EventExecutorGroup`也可以看成是一个Executor，这是比较奇特的一个地方
    * 提供了一个重要的方法next
* `EventLoopGroup`
    * 在`EventExecutorGroup`基础之上，提供了__异步的__`register`方法
* `AbstractEventExecutorGroup`
    * 为那些从JDK接口中继承而来的方法提供基础实现，就是调用next()方法然后调用对应的方法
    * next()方法依据不同策略从管理的所有Executor中选出下一个
* `MultithreadEventExecutorGroup`
    * 该类主要作用就是进行一些关键的初始化动作
    * 该类定义了关键字段children（EventExecutor数组）以及chooser（依据children的大小选择不同的next的策略）
* `MultithreadEventLoopGroup`
    * 为`EventLoopGroup`接口提供的方法提供基础实现

## 4.1 NioEventLoop

NioEventLoop本质上就是一个线程池，被NioEventLoopGroup管理

NioEventLoop的继承结构图如下

![NioEventLoop](/images/Netty-重要组件源码剖析/NioEventLoop.png)

* `EventExecutor`
    * 增加了几个新的方法，包括`parent`、`inEventLoop`、以及创建Future和Promise的方法
* `AbstractEventExecutor`
    * 为`EventExecutor`接口以及`EventLoopGroup`接口提供的方法提供基础实现
* `AbstractScheduledEventExecutor`
    * 为`ScheduledExecutorService`接口提供的方法提供基础实现
* `OrderedEventExecutor`
    * 空接口
* `EventLoop`
    * 修改parent方法的返回值
* `SingleThreadEventExecutor`
    * 实现了线程池的主要逻辑
* `SingleThreadEventLoop`
    * 综合两条继承链路
    * 为`EventLoopGroup`接口提供的方法提供基础实现

# 5 ChannelInitializer

ChannelInitializer的继承结构图如下

![ChannelInitializer](/images/Netty-重要组件源码剖析/ChannelInitializer.png)

* `ChannelHandler`
    * 提供了添加和移除Handler的方法
* `ChannelHandlerAdapter`
    * 为`ChannelHandler`接口提供基本的“骨架”实现
* `ChannelInboundHandler`
    * 在channel状态改变时插入相应的hook method，用于回调
* `ChannelInboundHandlerAdapter`
    * 为`ChannelInboundHandler`接口提供的方法提供基础实现，以便让用户自行选择是否覆盖某个hook method

# 6 DefaultChannelPipeline

DefaultChannelPipeline继承结构图如下

![DefaultChannelPipeline](/images/Netty-重要组件源码剖析/DefaultChannelPipeline.png)

* `ChannelInboundInvoker`
    * 将接收数据这一个过程抽象出多个生命周期，用于用户自定义处理逻辑
* `ChannelOutboundInvoker`
    * 将发送数据这一个过程抽象出多个生命周期，用于用户自定义处理逻辑
* `ChannelPipeline`
    * 将`ChannelInboundInvoker`与`ChannelOutboundInvoker`进行合并
    * 添加了一系列add以及remove方法用于添加handler

那么这些生命周期由谁触发呢？大部分IO的底层操作由`AbstractChannel`完成，因此这些生命周期会在这些底层操作之中显式触发。这些触发的操作大致由`AbstractChannelHandlerContext`、`DefaultChannelPipeline`以及`AbstractChannel`协作完成，在此先不深究细节

# 7 NioServerSocketChannel

NioServerSocketChannel继承结构图如下

![NioServerSocketChannel](/images/Netty-重要组件源码剖析/NioServerSocketChannel.png)

* `AttributeMap`
    * 用于存放属性值的Map
* `DefaultAttributeMap`
    * 为`AttributeMap`接口提供基础实现
* `Channel`
    * 定义Netty中Channel的一系列方法
    * 此外，还定义了Unsafe接口（不是sun实现中的Unsafe）
* `AbstractChannel`
    * 为`Channel`接口提供基础实现
    * 基本上所有底层的IO操作都在这个类中实现
* `AbstractNioChannel`
    * Netty中底层的NIO操作，都在这个类中实现，包括Selector等
* `AbstractNioMessageChannel`
    * 相比于`AbstractNioChannel`，`AbstractNioMessageChannel`提供更高一层的抽象，提供可以处理`Message`的抽象方法
* `ServerChannel`
    * 空接口，仅用于标记
* `ServerSocketChannel`
    * 定义用于监听连接的ServerChannel

# 8 DefaultChannelPromise

DefaultChannelPromise继承结构图如下

![DefaultChannelPromise](/images/Netty-重要组件源码剖析/DefaultChannelPromise.png)

* `Future`
    * 该Future继承自JUC中的同名Future接口
    * 增加了添加和删除监听器的方法，以及sync方法和await方法等
* `AbstractFuture`
    * 为JUC中的Future接口的get方法提供基础实现
* `Promise`
    * 增加了`setSuccess/setFailure`、`trySuccess/tryFailure`等方法
* `ChannelFuture`
    * 增加了返回Channel的方法，以及判断是否为Void型的channel的方法
* `ChannelPromise`
    * 结合了`ChannelFuture`以及`Promise`接口
* `DefaultPromise`
    * 为`Promise`以及`Future`接口提供了基础实现
* `DefaultChannelPromise`
    * 为`ChannelPromise`接口提供默认实现

# 9 SocketUtils

该类封装了一系列底层Java NIO API的基本操作
