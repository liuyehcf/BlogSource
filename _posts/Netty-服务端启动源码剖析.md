---
title: Netty-服务端启动源码剖析
date: 2017-12-05 18:58:22
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

# 1 源码Maven坐标

```xml
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.17.Final</version>
</dependency>
```

# 2 服务端启动示例代码

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

# 3 启动过程剖析

__先不要管那些错误处理的流程，先梳理出一个正常情况下的处理流程__

1. Netty启动过程从`ChannelFuture f = b.bind(port).sync(); // (7)`开始。该`bind`方法位于`AbstractBootstrap`中
    * 
```Java
    public ChannelFuture bind(int inetPort) {
        return bind(new InetSocketAddress(inetPort));
    }
```

1. 继续调用位于`AbstractBootstrap`中的同名方法
    * 
```Java
    public ChannelFuture bind(SocketAddress localAddress) {
        // 在执行bind之前，首先进行一些校验工作
        validate();
        if (localAddress == null) {
            throw new NullPointerException("localAddress");
        }
        return doBind(localAddress);
    }
```

1. 继续调用位于`AbstractBootstrap`中的`doBind`方法
    * 
```Java
    private ChannelFuture doBind(final SocketAddress localAddress) {
        // 初始化Channel，然后进行注册操作。其中注册操作是异步的，返回一个用于获取异步操作结果的ChannelFuture
        final ChannelFuture regFuture = initAndRegister();
        final Channel channel = regFuture.channel();
        if (regFuture.cause() != null) {
            return regFuture;
        }

        // 如果此时，register已经完成，那么在当前线程里面执行doBind0操作
        if (regFuture.isDone()) {
            // At this point we know that the registration was complete and successful.
            ChannelPromise promise = channel.newPromise();
            doBind0(regFuture, channel, localAddress, promise);
            return promise;
        } 
        // 此时，register尚未完成，那么设置一个监听器，当register完成时，执行doBind0操作
        else {
            // Registration future is almost always fulfilled already, but just in case it's not.
            final PendingRegistrationPromise promise = new PendingRegistrationPromise(channel);
            regFuture.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture future) throws Exception {
                    Throwable cause = future.cause();
                    if (cause != null) {
                        // Registration on the EventLoop failed so fail the ChannelPromise directly to not cause an
                        // IllegalStateException once we try to access the EventLoop of the Channel.
                        promise.setFailure(cause);
                    } else {
                        // Registration was successful, so set the correct executor to use.
                        // See https:// github.com/netty/netty/issues/2586
                        promise.registered();

                        doBind0(regFuture, channel, localAddress, promise);
                    }
                }
            });
            return promise;
        }
    }
```

1. 继续调用位于`AbstractBootstrap`中的`initAndRegister`方法，该方法创建了一个Channel，并对其进行初始化操作（init），并且采用异步的方式对Channel进行注册操作（register）
    * 
```Java
    final ChannelFuture initAndRegister() {
        Channel channel = null;
        try {
            channel = channelFactory.newChannel();
            // 注册操作
            init(channel);
        } catch (Throwable t) {
            if (channel != null) {
                // channel can be null if newChannel crashed (eg SocketException("too many open files"))
                channel.unsafe().closeForcibly();
            }
            // as the Channel is not registered yet we need to force the usage of the GlobalEventExecutor
            return new DefaultChannelPromise(channel, GlobalEventExecutor.INSTANCE).setFailure(t);
        }

        // 异步的注册操作
        ChannelFuture regFuture = config().group().register(channel);
        if (regFuture.cause() != null) {
            if (channel.isRegistered()) {
                channel.close();
            } else {
                channel.unsafe().closeForcibly();
            }
        }

        // If we are here and the promise is not failed, it's one of the following cases:
        // 1) If we attempted registration from the event loop, the registration has been completed at this point.
        // i.e. It's safe to attempt bind() or connect() now because the channel has been registered.
        // 2) If we attempted registration from the other thread, the registration request has been successfully
        // added to the event loop's task queue for later execution.
        // i.e. It's safe to attempt bind() or connect() now:
        // because bind() or connect() will be executed *after* the scheduled registration task is executed
        // because register(), bind(), and connect() are all bound to the same thread.

        return regFuture;
    }
```

1. 继续调用`ServerBootstrap`中的`init`方法，该方法用于初始化Channel，包括一些Map，Handler等等
    * 
```Java
    @Override
    void init(Channel channel) throws Exception {
        final Map<ChannelOption<?>, Object> options = options0();
        synchronized (options) {
            setChannelOptions(channel, options, logger);
        }

        final Map<AttributeKey<?>, Object> attrs = attrs0();
        synchronized (attrs) {
            for (Entry<AttributeKey<?>, Object> e: attrs.entrySet()) {
                @SuppressWarnings("unchecked")
                AttributeKey<Object> key = (AttributeKey<Object>) e.getKey();
                channel.attr(key).set(e.getValue());
            }
        }

        ChannelPipeline p = channel.pipeline();

        final EventLoopGroup currentChildGroup = childGroup;
        final ChannelHandler currentChildHandler = childHandler;
        final Entry<ChannelOption<?>, Object>[] currentChildOptions;
        final Entry<AttributeKey<?>, Object>[] currentChildAttrs;
        synchronized (childOptions) {
            currentChildOptions = childOptions.entrySet().toArray(newOptionArray(childOptions.size()));
        }
        synchronized (childAttrs) {
            currentChildAttrs = childAttrs.entrySet().toArray(newAttrArray(childAttrs.size()));
        }

        p.addLast(new ChannelInitializer<Channel>() {
            @Override
            public void initChannel(final Channel ch) throws Exception {
                final ChannelPipeline pipeline = ch.pipeline();
                ChannelHandler handler = config.handler();
                if (handler != null) {
                    pipeline.addLast(handler);
                }

                ch.eventLoop().execute(new Runnable() {
                    @Override
                    public void run() {
                        pipeline.addLast(new ServerBootstrapAcceptor(
                                ch, currentChildGroup, currentChildHandler, currentChildOptions, currentChildAttrs));
                    }
                });
            }
        });
    }
```

    * 注意到`ChannelInitializer`继承了`ChannelInboundHandlerAdapter`，且覆盖了`handlerAdded`方法，当该`ChannelInitializer`被添加到pipeline时，会调用`initChannel`中的方法（该方法在`ChannelInitializer#handlerAdded`中被调用）。该initChannel回调方法在执行后续register的过程中会被调用到
1. 回到`AbstractBootstrap#initAndRegister`方法中，通过`ServerBootstrap#config()`方法返回ServerBootstrapConfig对象，然后调用`ServerBootstrapConfig#group()`方法返回EventLoopGroup对象，然后继续调用位于`MultithreadEventLoopGroup`中的`register`方法，该方法调用next方法获取下一个EventLoop，并转调用`register`方法
    * 
```Java
    @Override
    public ChannelFuture register(Channel channel) {

        return next().register(channel);
    }
```

1. 继续调用位于`SingleThreadEventLoop`中的`register`方法，该方法创建一个DefaultChannelPromise对象，并转调用同名的`register`方法
```Java
    public ChannelFuture register(Channel channel) {
        return register(new DefaultChannelPromise(channel, this));
    }
```

1. 继续调用位于`SingleThreadEventLoop`中的同名的`register`方法
```Java
    public ChannelFuture register(final ChannelPromise promise) {
        ObjectUtil.checkNotNull(promise, "promise");
        // 通过promise对象获取Channel，并获取Unsafe对象，最终通过Unsafe对象调用register方法
        promise.channel().unsafe().register(this, promise);
        return promise;
    }
```

1. 继续调用位于`AbstractChannel`中的__非静态__内部类`AbstractUnsafe`的`register`方法，该方法经过一系列校验后，继续调用位于`AbstractUnsafe`中的`register0`方法。
```Java
        public final void register(EventLoop eventLoop, final ChannelPromise promise) {
            if (eventLoop == null) {
                throw new NullPointerException("eventLoop");
            }
            if (isRegistered()) {
                promise.setFailure(new IllegalStateException("registered to an event loop already"));
                return;
            }
            if (!isCompatible(eventLoop)) {
                promise.setFailure(
                        new IllegalStateException("incompatible event loop type: " + eventLoop.getClass().getName()));
                return;
            }

            AbstractChannel.this.eventLoop = eventLoop;

            if (eventLoop.inEventLoop()) {
                // 真正进行注册操作的地方
                register0(promise);
            } else {
                try {
                    eventLoop.execute(new Runnable() {
                        @Override
                        public void run() {
                            register0(promise);
                        }
                    });
                } catch (Throwable t) {
                    logger.warn(
                            "Force-closing a channel whose registration task was not accepted by an event loop: {}",
                            AbstractChannel.this, t);
                    closeForcibly();
                    closeFuture.setClosed();
                    safeSetFailure(promise, t);
                }
            }
        }
```

1. 继续调用位于`AbstractChannel`中的__非静态__内部类`AbstractUnsafe`的`register0`方法
    * 
```Java
        private void register0(ChannelPromise promise) {
            try {
                // check if the channel is still open as it could be closed in the mean time when the register
                // call was outside of the eventLoop
                if (!promise.setUncancellable() || !ensureOpen(promise)) {
                    return;
                }
                boolean firstRegistration = neverRegistered;

                // 该方法进行底层Java NIO API的注册操作
                doRegister();
                neverRegistered = false;
                registered = true;

                // Ensure we call handlerAdded(...) before we actually notify the promise. This is needed as the
                // user may already fire events through the pipeline in the ChannelFutureListener.
                pipeline.invokeHandlerAddedIfNeeded();

                safeSetSuccess(promise);

                // 此时注册完毕，触发pipeline中的特定生命周期
                pipeline.fireChannelRegistered();
                // Only fire a channelActive if the channel has never been registered. This prevents firing
                // multiple channel actives if the channel is deregistered and re-registered.
                if (isActive()) {
                    if (firstRegistration) {
                        // 此时，已经激活，触发pipeline中的特定生命周期
                        pipeline.fireChannelActive();
                    } else if (config().isAutoRead()) {
                        // This channel was registered before and autoRead() is set. This means we need to begin read
                        // again so that we process inbound data.
                        // 
                        // See https:// github.com/netty/netty/issues/4805
                        beginRead();
                    }
                }
            } catch (Throwable t) {
                // Close the channel directly to avoid FD leak.
                closeForcibly();
                closeFuture.setClosed();
                safeSetFailure(promise, t);
            }
        }
```

1. 继续调用位于`AbstractNioChannel`的`doRegister`方法，该方法才深入到了Java NIO API的底层操作，将当前Channel注册到指定的Selector中
    * 
```Java
    protected void doRegister() throws Exception {
        boolean selected = false;
        for (;;) {
            try {
                // 进行Java NIO原生API的register操作
                selectionKey = javaChannel().register(eventLoop().unwrappedSelector(), 0, this);
                return;
            } catch (CancelledKeyException e) {
                if (!selected) {
                    // Force the Selector to select now as the "canceled" SelectionKey may still be
                    // cached and not removed because no Select.select(..) operation was called yet.
                    eventLoop().selectNow();
                    selected = true;
                } else {
                    // We forced a select operation on the selector before but the SelectionKey is still cached
                    // for whatever reason. JDK bug ?
                    throw e;
                }
            }
        }
    }
```

1. 回到`AbstractBootstrap#doBind`方法中，继续调用位于`AbstractBootstrap`中的`doBind0`方法，注册操作是通过线程池来执行的
    * 
```Java
    private static void doBind0(
            final ChannelFuture regFuture, final Channel channel,
            final SocketAddress localAddress, final ChannelPromise promise) {

        // This method is invoked before channelRegistered() is triggered.  Give user handlers a chance to set up
        // the pipeline in its channelRegistered() implementation.
        channel.eventLoop().execute(new Runnable() {
            @Override
            public void run() {
                if (regFuture.isSuccess()) {
                    channel.bind(localAddress, promise).addListener(ChannelFutureListener.CLOSE_ON_FAILURE);
                } else {
                    promise.setFailure(regFuture.cause());
                }
            }
        });
    }
```

1. 继续调用位于`AbstractChannel`中的`bind`方法，该方法继续回调同名方法
    * 
```Java
    public ChannelFuture bind(SocketAddress localAddress, ChannelPromise promise) {
        return pipeline.bind(localAddress, promise);
    }
```

1. 继续调用位于`DefaultChannelPipeline`中的`bind`方法，该方法继续调用同名方法
    * 
```Java
    public final ChannelFuture bind(SocketAddress localAddress, ChannelPromise promise) {
        return tail.bind(localAddress, promise);
    }
```

1. 继续调用位于`AbstractChannelHandlerContext`中的`bind`方法
    * 
```Java
    public ChannelFuture bind(final SocketAddress localAddress, final ChannelPromise promise) {
        if (localAddress == null) {
            throw new NullPointerException("localAddress");
        }
        if (isNotValidPromise(promise, false)) {
            // cancelled
            return promise;
        }

        // 获取下一个ChannelHandlerContext
        final AbstractChannelHandlerContext next = findContextOutbound();
        EventExecutor executor = next.executor();
        // 若executor位于当前EventLoop中
        if (executor.inEventLoop()) {
            // 通过该next调用bind方法
            next.invokeBind(localAddress, promise);
        } else {
            safeExecute(executor, new Runnable() {
                @Override
                public void run() {
                    next.invokeBind(localAddress, promise);
                }
            }, promise, null);
        }
        return promise;
    }
```

1. 继续调用位于`AbstractChannelHandlerContext`的`invokeBind`方法
    * 
```Java
    private void invokeBind(SocketAddress localAddress, ChannelPromise promise) {
        if (invokeHandler()) {
            try {
                ((ChannelOutboundHandler) handler()).bind(this, localAddress, promise);
            } catch (Throwable t) {
                notifyOutboundHandlerException(t, promise);
            }
        } else {
            bind(localAddress, promise);
        }
    }
```

1. 继续调用位于`DefaultChannelPipeline`的__非静态__内部类`HeadContext`的`bind`方法
    * 
```Java
        public void bind(
                ChannelHandlerContext ctx, SocketAddress localAddress, ChannelPromise promise)
                throws Exception {
            unsafe.bind(localAddress, promise);
        }
```

1. 继续调用位于`AbstractChannel`的__非静态__内部类`AbstractUnsafe`的`bind`方法
    * 
```Java
        public final void bind(final SocketAddress localAddress, final ChannelPromise promise) {
            assertEventLoop();

            if (!promise.setUncancellable() || !ensureOpen(promise)) {
                return;
            }

            // See: https:// github.com/netty/netty/issues/576
            if (Boolean.TRUE.equals(config().getOption(ChannelOption.SO_BROADCAST)) &&
                localAddress instanceof InetSocketAddress &&
                !((InetSocketAddress) localAddress).getAddress().isAnyLocalAddress() &&
                !PlatformDependent.isWindows() && !PlatformDependent.maybeSuperUser()) {
                // Warn a user about the fact that a non-root user can't receive a
                // broadcast packet on *nix if the socket is bound on non-wildcard address.
                logger.warn(
                        "A non-root user can't receive a broadcast packet if the socket " +
                        "is not bound to a wildcard address; binding to a non-wildcard " +
                        "address (" + localAddress + ") anyway as requested.");
            }

            boolean wasActive = isActive();
            try {
                doBind(localAddress);
            } catch (Throwable t) {
                safeSetFailure(promise, t);
                closeIfClosed();
                return;
            }

            if (!wasActive && isActive()) {
                invokeLater(new Runnable() {
                    @Override
                    public void run() {
                        // 此时，已经激活，执行pipeline中的特定生命周期
                        pipeline.fireChannelActive();
                    }
                });
            }

            safeSetSuccess(promise);
        }
```

1. 继续调用位于`NioServerSocketChannel`的`doBind`方法，该方法调用Java NIO API的bind方法
    * 
```Java
    protected void doBind(SocketAddress localAddress) throws Exception {
        if (PlatformDependent.javaVersion() >= 7) {
            javaChannel().bind(localAddress, config.getBacklog());
        } else {
            javaChannel().socket().bind(localAddress, config.getBacklog());
        }
    }
```

