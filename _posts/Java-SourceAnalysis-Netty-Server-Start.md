---
title: Java-SourceAnalysis-Netty-Server-Start
date: 2017-12-05 18:58:22
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

**阅读更多**

<!--more-->

# 1 源码Maven坐标

```xml
<dependency>
    <groupId>io.netty</groupId>
    <artifactId>netty-all</artifactId>
    <version>4.1.17.Final</version>
</dependency>
```

# 2 服务端启动代码清单

```java
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
        EventLoopGroup bossGroup = new NioEventLoopGroup(); //(1)
        EventLoopGroup workerGroup = new NioEventLoopGroup();
        try {
            ServerBootstrap b = new ServerBootstrap(); //(2)
            b.group(bossGroup, workerGroup) //(3)
                    .channel(NioServerSocketChannel.class) //(4)
                    .childHandler(new ChannelInitializer<SocketChannel>() { //(5)
                        @Override
                        public void initChannel(SocketChannel ch) throws Exception {
                            ch.pipeline().addLast(new EchoServerHandler());
                        }
                    })
                    .option(ChannelOption.SO_BACKLOG, 128)          //(6)
                    .childOption(ChannelOption.SO_KEEPALIVE, true); //(7)

            //Bind and start to accept incoming connections.
            ChannelFuture f = b.bind(port).sync(); //(8)

            //Wait until the server socket is closed.
            //In this example, this does not happen, but you can do that to gracefully
            //shut down your server.
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

# 3 启动过程概述

启动过程可以概括为以下步骤

1. **配置启动参数**
1. **创建Channel**
1. **初始化Channel**
1. **注册Channel**
1. **绑定Channel**

# 4 启动参数配置

1. 根据代码清单中的`(1)`。创建一个boss和一个work，这两个形容词十分形象，boss EventLoopGroup用于监听连接，work EventLoopGroup用于处理数据。NioEventLoopGroup的创建过程在这里先不做分析
1. 根据代码清单中的`(2)`。创建一个ServerBootstrap，会调用无参构造方法，参数的配置采用建造者模式
1. 根据代码清单中的`(3)`。绑定EventLoopGroup
    * `group`方法位于`ServerBootstrap`，该方法首先调用父类的同名方法group，然后绑定child（即work）
    ```java
    public ServerBootstrap group(EventLoopGroup parentGroup, EventLoopGroup childGroup) {
        super.group(parentGroup);
        if (childGroup == null) {
            throw new NullPointerException("childGroup");
        }
        if (this.childGroup != null) {
            throw new IllegalStateException("childGroup set already");
        }
        this.childGroup = childGroup;
        return this;
    }
    ```

    * 接着，我们再看一下位于`AbstractBootstrap`的同名方法`group`，该方法主要作用就是绑定group（即boss）
    ```java
    public B group(EventLoopGroup group) {
        if (group == null) {
            throw new NullPointerException("group");
        }
        if (this.group != null) {
            throw new IllegalStateException("group set already");
        }
        this.group = group;
        return self();
    }
    ```

1. 根据代码清单中的`(4)`。配置生产的Channel类型，这里指定为`NioServerSocketChannel.class`
    * `channel`方法位于`AbstractBootstrap`，该方法用于创建并绑定工厂对象
    ```java
    public B channel(Class<? extends C> channelClass) {
        if (channelClass == null) {
            throw new NullPointerException("channelClass");
        }
        return channelFactory(new ReflectiveChannelFactory<C>(channelClass));
    }
    ```

    * 以下是`ReflectiveChannelFactory`的构造方法，很简单，绑定指定的Class对象
    ```java
    public ReflectiveChannelFactory(Class<? extends T> clazz) {
        if (clazz == null) {
            throw new NullPointerException("clazz");
        }
        this.clazz = clazz;
    }
    ```

    * 接着调用位于`AbstractBootstrap`的`channelFactory`方法，该方法转调用另一个同名方法（接口位置的变更，又得保持兼容，因此导致两层相似的调用）
    ```java
    public B channelFactory(io.netty.channel.ChannelFactory<? extends C> channelFactory) {
        return channelFactory((ChannelFactory<C>) channelFactory);
    }
    ```

    * 最终，调用位于`AbstractBootstrap`的`channelFactory`方法，该方法绑定之前创建好的工厂对象
    ```java
    public B channelFactory(ChannelFactory<? extends C> channelFactory) {
        if (channelFactory == null) {
            throw new NullPointerException("channelFactory");
        }
        if (this.channelFactory != null) {
            throw new IllegalStateException("channelFactory set already");
        }

        //绑定工厂对象
        this.channelFactory = channelFactory;
        return self();
    }
    ```

1. 根据代码清单中的`(5)`。绑定work的Handler
    * `group`方法位于`ServerBootstrap`，该方法用于绑定child（即work）的Handler
    ```java
    public ServerBootstrap childHandler(ChannelHandler childHandler) {
        if (childHandler == null) {
            throw new NullPointerException("childHandler");
        }
        this.childHandler = childHandler;
        return this;
    }
    ```

1. 根据代码清单中的`(6)`。设置boss键值对
    * `option`方法位于`AbstractBootstrap`
    ```java
    public <T> B option(ChannelOption<T> option, T value) {
        if (option == null) {
            throw new NullPointerException("option");
        }
        if (value == null) {
            synchronized (options) {
                options.remove(option);
            }
        } else {
            synchronized (options) {
                options.put(option, value);
            }
        }
        return self();
    }
    ```

1. 根据代码清单中的`(7)`。设置child键值对
    * `childOption`方法位于`ServerBootstrap`
    ```java
    public <T> ServerBootstrap childOption(ChannelOption<T> childOption, T value) {
        if (childOption == null) {
            throw new NullPointerException("childOption");
        }
        if (value == null) {
            synchronized (childOptions) {
                childOptions.remove(childOption);
            }
        } else {
            synchronized (childOptions) {
                childOptions.put(childOption, value);
            }
        }
        return this;
    }
    ```

# 5 创建Channel

1. 根据代码清单中的`(8)`。进行后续创建Channel以及绑定操作
    * `bind`方法位于`AbstractBootstrap`，该方法将int类型的端口号封装成InetSocketAddress，并转调用同名方法bind
    ```java
    public ChannelFuture bind(int inetPort) {
        return bind(new InetSocketAddress(inetPort));
    }
    ```

    * `bind`方法位于`AbstractBootstrap`。该方法首先做一些校验工作，然后调用doBind方法
    ```java
    public ChannelFuture bind(SocketAddress localAddress) {
        //在执行bind之前，首先进行一些校验工作
        validate();
        if (localAddress == null) {
            throw new NullPointerException("localAddress");
        }
        return doBind(localAddress);
    }
    ```

    * `doBind`方法位于`AbstractBootstrap`。该方法创建Channel并注册，然后调用doBind0进行绑定操作
    ```java
    private ChannelFuture doBind(final SocketAddress localAddress) {
        //初始化Channel，然后进行注册操作。其中注册操作是异步的，返回一个用于获取异步操作结果的ChannelFuture
        final ChannelFuture regFuture = initAndRegister();
        final Channel channel = regFuture.channel();
        if (regFuture.cause() != null) {
            return regFuture;
        }

        //如果此时，register已经完成，那么在当前线程里面执行doBind0操作
        if (regFuture.isDone()) {
            //At this point we know that the registration was complete and successful.
            ChannelPromise promise = channel.newPromise();
            doBind0(regFuture, channel, localAddress, promise);
            return promise;
        } 
        //此时，register尚未完成，那么设置一个监听器，当register完成时，执行doBind0操作
        else {
            //Registration future is almost always fulfilled already, but just in case it's not.
            final PendingRegistrationPromise promise = new PendingRegistrationPromise(channel);
            regFuture.addListener(new ChannelFutureListener() {
                @Override
                public void operationComplete(ChannelFuture future) throws Exception {
                    Throwable cause = future.cause();
                    if (cause != null) {
                        //Registration on the EventLoop failed so fail the ChannelPromise directly to not cause an
                        //IllegalStateException once we try to access the EventLoop of the Channel.
                        promise.setFailure(cause);
                    } else {
                        //Registration was successful, so set the correct executor to use.
                        //See https://github.com/netty/netty/issues/2586
                        promise.registered();

                        doBind0(regFuture, channel, localAddress, promise);
                    }
                }
            });
            return promise;
        }
    }
    ```

1. 这里我们先关注initAndRegister方法的调用中的Channel创建过程
    * `initAndRegister`方法位于`AbstractBootstrap`，该方法的作用之一是利用工厂对象生成一个Channel，并进行初始化操作
    ```java
    final ChannelFuture initAndRegister() {
        Channel channel = null;
        try {
            channel = channelFactory.newChannel();
            //注册操作
            init(channel);
        } catch (Throwable t) {
            if (channel != null) {
                //channel can be null if newChannel crashed (eg SocketException("too many open files"))
                channel.unsafe().closeForcibly();
            }
            //as the Channel is not registered yet we need to force the usage of the GlobalEventExecutor
            return new DefaultChannelPromise(channel, GlobalEventExecutor.INSTANCE).setFailure(t);
        }

        //异步的注册操作
        ChannelFuture regFuture = config().group().register(channel);
        if (regFuture.cause() != null) {
            if (channel.isRegistered()) {
                channel.close();
            } else {
                channel.unsafe().closeForcibly();
            }
        }

        //If we are here and the promise is not failed, it's one of the following cases:
        //1) If we attempted registration from the event loop, the registration has been completed at this point.
        //i.e. It's safe to attempt bind() or connect() now because the channel has been registered.
        //2) If we attempted registration from the other thread, the registration request has been successfully
        //added to the event loop's task queue for later execution.
        //i.e. It's safe to attempt bind() or connect() now:
        //because bind() or connect() will be executed *after* the scheduled registration task is executed
        //because register(), bind(), and connect() are all bound to the same thread.

        return regFuture;
    }
    ```

1. 由于在代码清单中配置了NioServerSocketChannel作为生产的Channel类型，我们接着来看一下工厂生产过程
    * `newChannel`方法位于`ReflectiveChannelFactory`，该方法很简单，利用反射获取无参构造器，然后创建对象
    ```java
    public T newChannel() {
        try {
            return clazz.getConstructor().newInstance();
        } catch (Throwable t) {
            throw new ChannelException("Unable to create Channel from class " + clazz, t);
        }
    }
    ```

1. 接着，我们看一下NioServerSocketChannel的构造方法
    * `NioServerSocketChannel`的构造方法调用了newSocket方法，来创建一个ServerSocketChannel
    ```java
    public NioServerSocketChannel() {
        this(newSocket(DEFAULT_SELECTOR_PROVIDER));
    }
    ```

    * `newSocket`方法位于`NioServerSocketChannel`，其中DEFAULT_SELECTOR_PROVIDER的定义如下。该方法创建了`java.nio.channels.ServerSocketChannel`对象
    ```java
    private static final SelectorProvider DEFAULT_SELECTOR_PROVIDER = SelectorProvider.provider();

    private static ServerSocketChannel newSocket(SelectorProvider provider) {
        try {
            /**
             *  Use the {@link SelectorProvider} to open {@link SocketChannel} and so remove condition in
             *  {@link SelectorProvider#provider()} which is called by each ServerSocketChannel.open() otherwise.
             *
             *  See <a href="https://github.com/netty/netty/issues/2308">#2308</a>.
             */
            return provider.openServerSocketChannel();
        } catch (IOException e) {
            throw new ChannelException(
                    "Failed to open a server socket.", e);
        }
    }
    ```

    * 然后，转调用`NioServerSocketChannel`的另一个构造方法，该方法继续调用父类的构造方法（传入参数SelectionKey.OP_ACCEPT），并且配置Config对象
    ```java
    public NioServerSocketChannel(ServerSocketChannel channel) {
        super(null, channel, SelectionKey.OP_ACCEPT);
        config = new NioServerSocketChannelConfig(this, javaChannel().socket());
    }
    ```

    * 继续，调用`AbstractNioMessageChannel`的构造方法，该方法什么也不做，继续调用父类的构造方法
    ```java
    protected AbstractNioMessageChannel(Channel parent, SelectableChannel ch, int readInterestOp) {
        super(parent, ch, readInterestOp);
    }
    ```

    * 继续，调用`AbstractNioChannel`的构造方法。该方法首先调用父类的构造方法，并且设置NIO层面的参数，包括非阻塞模式的设置
    ```java
    protected AbstractNioChannel(Channel parent, SelectableChannel ch, int readInterestOp) {
        super(parent);
        this.ch = ch;
        this.readInterestOp = readInterestOp;
        try {
            //设置为非阻塞模式
            ch.configureBlocking(false);
        } catch (IOException e) {
            try {
                ch.close();
            } catch (IOException e2) {
                if (logger.isWarnEnabled()) {
                    logger.warn(
                            "Failed to close a partially initialized socket.", e2);
                }
            }

            throw new ChannelException("Failed to enter non-blocking mode.", e);
        }
    }
    ```

    * 继续，调用`AbstractChannel`的构造方法，设置信道，并且创建底层的Unsafe对象以及ChannelPipeLine对象
    ```java
    protected AbstractChannel(Channel parent) {
        this.parent = parent;
        id = newId();
        unsafe = newUnsafe();
        pipeline = newChannelPipeline();
    }
    ```

    * `newUnsafe`方法位于`AbstractNioMessageChannel`，该方法创建了NioMessageUnsafe对象，该对象负责Nio以及Message层面的IO操作，这里先不深究
    ```java
    protected AbstractNioUnsafe newUnsafe() {
        return new NioMessageUnsafe();
    }
    ```

    * `newChannelPipeline`方法位于`AbstractChannel`，该方法创建了DefaultChannelPipeline对象，作为DefaultChannelPipeline
    ```java
    protected DefaultChannelPipeline newChannelPipeline() {
        return new DefaultChannelPipeline(this);
    }
    ```

至此，Channel的创建工作完毕

# 6 初始化Channel

1. 我们回到位于`AbstractBootstrap`的`initAndRegister`方法中来，该方法在创建Channel完毕后，调用了init方法对其进行初始化操作
    * `init`方法位于`ServerBootstrap`，该方法主要就是将之前启动时通过建造者模式配置的参数注入到该Channel中去
    * 此外，该方法又通过异步方式添加了ServerBootstrapAcceptor(ChannelInboundHandlerAdapter接口的实现)，该handler用于将用户配置的childHandler（即代码清单中的ChannelInitializer）注入到新产生的NioSocketChannel（即child Channel）的Pipeline中去。在后续NioSocketChannel的注册操作的过程中，才会触发ChannelInitializer的handlerAdded方法，从而将用户配置的Handler注入到NioSocketChannel的Pipeline中去
    ```java
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

至此，Channel初始化工作完毕

# 7 注册Channel

1. 我们继续回到位于`AbstractBootstrap`的`initAndRegister`方法中来，该方法在创建并初始化Channel完毕后，通过异步的方式进行了注册操作
    * `register`方法位于`MultithreadEventLoopGroup`，该方法调用next()方法获取下一个EventLoop，并通过该EventLoop进行register操作
    ```java
    public ChannelFuture register(Channel channel) {
        return next().register(channel);
    }
    ```

    * `register`方法位于`SingleThreadEventLoop`，该方法创建了一个DefaultChannelPromise对象（绑定了一个Channel以及一个EventExecutor），并继续调用同名方法
    ```java
    public ChannelFuture register(Channel channel) {
        return register(new DefaultChannelPromise(channel, this));
    }
    ```

    * `register`方法位于`SingleThreadEventLoop`，该方法获取Unsafe对象来执行register操作
    ```java
    public ChannelFuture register(final ChannelPromise promise) {
        ObjectUtil.checkNotNull(promise, "promise");
        promise.channel().unsafe().register(this, promise);
        return promise;
    }
    ```

    * `register`方法位于`AbstractChannel`的**非静态**内部类`AbstractUnsafe`中，该方法通过异步方式调用register0
    ```java
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

1. 接着，我们来看一下register0方法
    * `register0`方法位于`AbstractChannel`的**非静态**内部类`AbstractUnsafe`中
    * 首先，执行doRegister方法，进行真正的底层的register操作
    * 然后，执行`pipeline.invokeHandlerAddedIfNeeded();`，触发位于`ServerBootstrap`的`init`方法中的ChannelInitializer（封装了handler，注意哦，不是childHandler，在代码清单中我们没有配置过这个handler）
    * **将initAndRegister对应的ChannelFuture设置为成功**
    * 最后，触发其他生命周期，例如`fireChannelRegistered`以及`fireChannelActive`
    ```java
       private void register0(ChannelPromise promise) {
            try {
                //check if the channel is still open as it could be closed in the mean time when the register
                //call was outside of the eventLoop
                if (!promise.setUncancellable() || !ensureOpen(promise)) {
                    return;
                }
                boolean firstRegistration = neverRegistered;
                doRegister();
                neverRegistered = false;
                registered = true;

                //Ensure we call handlerAdded(...) before we actually notify the promise. This is needed as the
                //user may already fire events through the pipeline in the ChannelFutureListener.
                pipeline.invokeHandlerAddedIfNeeded();

                // initAndRegister对应的ChannelFuture设置为成功
                safeSetSuccess(promise);
                pipeline.fireChannelRegistered();
                //Only fire a channelActive if the channel has never been registered. This prevents firing
                //multiple channel actives if the channel is deregistered and re-registered.
                if (isActive()) {
                    if (firstRegistration) {
                        pipeline.fireChannelActive();
                    } else if (config().isAutoRead()) {
                        //This channel was registered before and autoRead() is set. This means we need to begin read
                        //again so that we process inbound data.
                        //
                        //See https://github.com/netty/netty/issues/4805
                        beginRead();
                    }
                }
            } catch (Throwable t) {
                //Close the channel directly to avoid FD leak.
                closeForcibly();
                closeFuture.setClosed();
                safeSetFailure(promise, t);
            }
        }
    ```

1. 首先，我们来跟踪一下doRegister的执行过程
    * `doRegister`方法位于`AbstractNioChannel`，该方法将java.nio.channels.ServerSocketChannel注册到指定Selector中。很简单，都是Java NIO的API，没什么好说的
    ```java
    protected void doRegister() throws Exception {
        boolean selected = false;
        for (;;) {
            try {
                selectionKey = javaChannel().register(eventLoop().unwrappedSelector(), 0, this);
                return;
            } catch (CancelledKeyException e) {
                if (!selected) {
                    //Force the Selector to select now as the "canceled" SelectionKey may still be
                    //cached and not removed because no Select.select(..) operation was called yet.
                    eventLoop().selectNow();
                    selected = true;
                } else {
                    //We forced a select operation on the selector before but the SelectionKey is still cached
                    //for whatever reason. JDK bug ?
                    throw e;
                }
            }
        }
    }
    ```

1. 接着，我们来跟踪一下invokeHandlerAddedIfNeeded方法的执行过程
    * `invokeHandlerAddedIfNeeded`方法位于`DefaultChannelPipeline`，只有第一次注册的时候才会执行后续操作
    ```java
    final void invokeHandlerAddedIfNeeded() {
        assert channel.eventLoop().inEventLoop();
        if (firstRegistration) {
            firstRegistration = false;
            //We are now registered to the EventLoop. It's time to call the callbacks for the ChannelHandlers,
            //that were added before the registration was done.
            callHandlerAddedForAllHandlers();
        }
    }
    ```

    * `callHandlerAddedForAllHandlers`方法位于`DefaultChannelPipeline`，该方法触发所有task的execute的方法
    ```java
    private void callHandlerAddedForAllHandlers() {
        final PendingHandlerCallback pendingHandlerCallbackHead;
        synchronized (this) {
            assert !registered;

            //This Channel itself was registered.
            registered = true;

            pendingHandlerCallbackHead = this.pendingHandlerCallbackHead;
            //Null out so it can be GC'ed.
            this.pendingHandlerCallbackHead = null;
        }

        //This must happen outside of the synchronized(...) block as otherwise handlerAdded(...) may be called while
        //holding the lock and so produce a deadlock if handlerAdded(...) will try to add another handler from outside
        //the EventLoop.
        PendingHandlerCallback task = pendingHandlerCallbackHead;
        while (task != null) {
            task.execute();
            task = task.next;
        }
    }
    ```

    * `execute`方法位于`DefaultChannelPipeline`中的**非静态**内部类`PendingHandlerAddedTask`中，该方法主要作用就是执行callHandlerAdded0方法
    ```java
        void execute() {
            EventExecutor executor = ctx.executor();
            if (executor.inEventLoop()) {
                callHandlerAdded0(ctx);
            } else {
                try {
                    executor.execute(this);
                } catch (RejectedExecutionException e) {
                    if (logger.isWarnEnabled()) {
                        logger.warn(
                                "Can't invoke handlerAdded() as the EventExecutor {} rejected it, removing handler {}.",
                                executor, ctx.name(), e);
                    }
                    remove0(ctx);
                    ctx.setRemoved();
                }
            }
        }
    ```

    * `callHandlerAdded0`方法位于`DefaultChannelPipeline`，**该方法主要作用就是触发绑定的Handler的handlerAdded方法**。handlerAdded方法触发的地方非常少，到目前仅在此一处出现。这也保证了在ChannelInitializer配置的Handler不会被重复添加
    ```java
    private void callHandlerAdded0(final AbstractChannelHandlerContext ctx) {
        try {
            ctx.handler().handlerAdded(ctx);
            ctx.setAddComplete();
        } catch (Throwable t) {
            boolean removed = false;
            try {
                remove0(ctx);
                try {
                    ctx.handler().handlerRemoved(ctx);
                } finally {
                    ctx.setRemoved();
                }
                removed = true;
            } catch (Throwable t2) {
                if (logger.isWarnEnabled()) {
                    logger.warn("Failed to remove a handler: " + ctx.name(), t2);
                }
            }

            if (removed) {
                fireExceptionCaught(new ChannelPipelineException(
                        ctx.handler().getClass().getName() +
                        ".handlerAdded() has thrown an exception; removed.", t));
            } else {
                fireExceptionCaught(new ChannelPipelineException(
                        ctx.handler().getClass().getName() +
                        ".handlerAdded() has thrown an exception; also failed to remove.", t));
            }
        }
    }
    ```

至此，Channel注册工作完毕

# 8 绑定Channel

1. 现在我们回到位于`AbstractBootstrap`的`doBind`方法中，继续调用`doBind0`方法
    * `doBind0`方法位于`AbstractBootstrap`中，该方法主要通过异步方式调用bind方法
    ```java
    private static void doBind0(
            final ChannelFuture regFuture, final Channel channel,
            final SocketAddress localAddress, final ChannelPromise promise) {

        //This method is invoked before channelRegistered() is triggered.  Give user handlers a chance to set up
        //the pipeline in its channelRegistered() implementation.
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

1. 继续跟踪bind方法的异步调用
    * `bind`方法位于`AbstractChannel`，通过其绑定的pipeline继续调用bind方法
    ```java
    public ChannelFuture bind(SocketAddress localAddress, ChannelPromise promise) {
        return pipeline.bind(localAddress, promise);
    }
    ```

    * `bind`方法位于`DefaultChannelPipeline`，该方法通过tail字段继续调用同名方法
    ```java
    public final ChannelFuture bind(SocketAddress localAddress, ChannelPromise promise) {
        return tail.bind(localAddress, promise);
    }
    ```

    * `bind`方法位于`AbstractChannelHandlerContext`，该方法通过同步或异步的方式执行invokeBind方法
    ```java
    public ChannelFuture bind(final SocketAddress localAddress, final ChannelPromise promise) {
        if (localAddress == null) {
            throw new NullPointerException("localAddress");
        }
        if (isNotValidPromise(promise, false)) {
            //cancelled
            return promise;
        }

        //获取ChannelHandlerContext
        final AbstractChannelHandlerContext next = findContextOutbound();
        EventExecutor executor = next.executor();
        if (executor.inEventLoop()) {
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

    * `invokeBind`方法位于`AbstractChannelHandlerContext`，该方法获取绑定的handler，然后执行bind操作
    ```java
    private void invokeBind(SocketAddress localAddress, ChannelPromise promise) {
        //这个判断条件没看懂
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

    * `bind`方法位于`DefaultChannelPipeline`的**非静态**内部类`HeadContext`中，该方法通过其关联的Unsafe对象执行底层的bind操作。关于HeadContext以及TailContext暂时不太清楚设计目的
    ```java
        public void bind(
                ChannelHandlerContext ctx, SocketAddress localAddress, ChannelPromise promise)
                throws Exception {
            unsafe.bind(localAddress, promise);
        }
    ```

    * `bind`方法位于`AbstractChannel`的**非静态**内部类`AbstractUnsafe`中，该方做了一些额外校验工作后，触发doBind方法
    ```java
        @Override
        public final void bind(final SocketAddress localAddress, final ChannelPromise promise) {
            assertEventLoop();

            if (!promise.setUncancellable() || !ensureOpen(promise)) {
                return;
            }

            //See: https://github.com/netty/netty/issues/576
            if (Boolean.TRUE.equals(config().getOption(ChannelOption.SO_BROADCAST)) &&
                localAddress instanceof InetSocketAddress &&
                !((InetSocketAddress) localAddress).getAddress().isAnyLocalAddress() &&
                !PlatformDependent.isWindows() && !PlatformDependent.maybeSuperUser()) {
                //Warn a user about the fact that a non-root user can't receive a
                //broadcast packet on *nix if the socket is bound on non-wildcard address.
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
                        pipeline.fireChannelActive();
                    }
                });
            }

            safeSetSuccess(promise);
        }
    ```

    * `doBind`方法位于`NioServerSocketChannel`，该方法执行Java NIO API的绑定操作
    ```java
    protected void doBind(SocketAddress localAddress) throws Exception {
        if (PlatformDependent.javaVersion() >= 7) {
            javaChannel().bind(localAddress, config.getBacklog());
        } else {
            javaChannel().socket().bind(localAddress, config.getBacklog());
        }
    }
    ```

至此，Channel绑定工作完毕

