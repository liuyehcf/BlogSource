---
title: Netty-服务端响应源码剖析
date: 2017-12-05 18:58:30
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

# 3 服务端启动回顾

有关服务端的代码清单，以及服务端启动流程，可以参考{% post_link Netty-服务端启动源码剖析 %}

现在我们知道，当服务端启动之后，ServerSocketChannel就被封装到NioServerSocketChannel中了，并且注册到指定关注ACCEPT事件的Selector当中。而Selector的非阻塞响应过程由NioEventLoop来实现，因此服务端监听过程的起始地点就在NioEventLoop的run方法当中

整个服务端响应的具体流程大致可以分为

* 获取SelectionKey
* 创建Channel
* 注册Channel
* 消息处理

# 4 获取SelectionKey

1. 整个响应流程的分析始于`NioEventLoop#run`
    * `run`方法位于`NioEventLoop`中，该方法主要任务包含三点：1)执行select获取selectionKey；2)执行与NIO有关的处理流程；3)执行提交到该线程池的任务
    ```java
    protected void run() {
        for (;;) {
            try {
                switch (selectStrategy.calculateStrategy(selectNowSupplier, hasTasks())) {
                    case SelectStrategy.CONTINUE:
                        continue;
                    case SelectStrategy.SELECT:
                        select(wakenUp.getAndSet(false));

                        //'wakenUp.compareAndSet(false, true)' is always evaluated
                        //before calling 'selector.wakeup()' to reduce the wake-up
                        //overhead. (Selector.wakeup() is an expensive operation.)
                        //
                        //However, there is a race condition in this approach.
                        //The race condition is triggered when 'wakenUp' is set to
                        //true too early.
                        //
                        //'wakenUp' is set to true too early if:
                        //1) Selector is waken up between 'wakenUp.set(false)' and
                        //'selector.select(...)'. (BAD)
                        //2) Selector is waken up between 'selector.select(...)' and
                        //'if (wakenUp.get()) { ... }'. (OK)
                        //
                        //In the first case, 'wakenUp' is set to true and the
                        //following 'selector.select(...)' will wake up immediately.
                        //Until 'wakenUp' is set to false again in the next round,
                        //'wakenUp.compareAndSet(false, true)' will fail, and therefore
                        //any attempt to wake up the Selector will fail, too, causing
                        //the following 'selector.select(...)' call to block
                        //unnecessarily.
                        //
                        //To fix this problem, we wake up the selector again if wakenUp
                        //is true immediately after selector.select(...).
                        //It is inefficient in that it wakes up the selector for both
                        //the first case (BAD - wake-up required) and the second case
                        //(OK - no wake-up required).

                        if (wakenUp.get()) {
                            selector.wakeup();
                        }
                        //fall through
                    default:
                }

                cancelledKeys = 0;
                needsToSelectAgain = false;
                final int ioRatio = this.ioRatio;
                if (ioRatio == 100) {
                    try {
                        processSelectedKeys();
                    } finally {
                        //Ensure we always run tasks.
                        runAllTasks();
                    }
                } else {
                    final long ioStartTime = System.nanoTime();
                    try {
                        processSelectedKeys();
                    } finally {
                        //Ensure we always run tasks.
                        final long ioTime = System.nanoTime() - ioStartTime;
                        runAllTasks(ioTime * (100 - ioRatio) / ioRatio);
                    }
                }
            } catch (Throwable t) {
                handleLoopException(t);
            }
            //Always handle shutdown even if the loop processing threw an exception.
            try {
                if (isShuttingDown()) {
                    closeAll();
                    if (confirmShutdown()) {
                        return;
                    }
                }
            } catch (Throwable t) {
                handleLoopException(t);
            }
        }
    }
    ```

1. 首先，我们先来分析一下calculateStrategy方法
    * `calculateStrategy`方法位于`DefaultSelectStrategy`，该方法主要逻辑就是根据当前状态计算执行的策略。如果有task，那么返回selectSupplier.get()；否则返回SelectStrategy.SELECT
    ```java
    public int calculateStrategy(IntSupplier selectSupplier, boolean hasTasks) throws Exception {
        return hasTasks ? selectSupplier.get() : SelectStrategy.SELECT;
    }
    ```

    * `get`方法位于`NioEventLoop`，即返回非阻塞的selectNow的结果
    ```java
    private final IntSupplier selectNowSupplier = new IntSupplier() {
        @Override
        public int get() throws Exception {
            return selectNow();
        }
    };
    ```

    * 其次，我们来看一下`hasTasks`方法，该方法位于`SingleThreadEventLoop`，该方法继续调用父类的同名方法。其效果就是只要两个任务队列有一个含有任务，就返回true
    ```java
    protected boolean hasTasks() {
        return super.hasTasks() || !tailTasks.isEmpty();
    }
    ```

    * 父类`SingleThreadEventExecutor`的`hasTasks`方法如下，很简单，队列是否为空
    ```java
    protected boolean hasTasks() {
        assert inEventLoop();
        return !taskQueue.isEmpty();
    }
    ```

1. 接下来，回到位于`NioEventLoop`中的`run`方法，我们关注一下switch语句，目前来看，要么返回SELECT，要么返回值不小于0（selectNow返回值），为什么会返回CONTINUE（其值-2）？
1. 如果返回值是SELECT，那么执行select方法
    * `select`方法位于`NioEventLoop`，该方法的主要逻辑就是执行select，其结果会保存在关联的selectedKeys字段当中（该字段已通过反射替换掉`sun.nio.ch.SelectorImpl`中原有的selectedKeys字段了，详见{% post_link Netty-NioEventLoop源码剖析 %}）
    * 会根据不同的逻辑调用阻塞的select或者非阻塞的selectNow，具体细节在此不深究
    ```java
    private void select(boolean oldWakenUp) throws IOException {
        Selector selector = this.selector;
        try {
            int selectCnt = 0;
            long currentTimeNanos = System.nanoTime();
            long selectDeadLineNanos = currentTimeNanos + delayNanos(currentTimeNanos);
            for (;;) {
                long timeoutMillis = (selectDeadLineNanos - currentTimeNanos + 500000L) / 1000000L;
                if (timeoutMillis <= 0) {
                    if (selectCnt == 0) {
                        selector.selectNow();
                        selectCnt = 1;
                    }
                    break;
                }

                //If a task was submitted when wakenUp value was true, the task didn't get a chance to call
                //Selector#wakeup. So we need to check task queue again before executing select operation.
                //If we don't, the task might be pended until select operation was timed out.
                //It might be pended until idle timeout if IdleStateHandler existed in pipeline.
                if (hasTasks() && wakenUp.compareAndSet(false, true)) {
                    selector.selectNow();
                    selectCnt = 1;
                    break;
                }

                int selectedKeys = selector.select(timeoutMillis);
                selectCnt ++;

                if (selectedKeys != 0 || oldWakenUp || wakenUp.get() || hasTasks() || hasScheduledTasks()) {
                    //- Selected something,
                    //- waken up by user, or
                    //- the task queue has a pending task.
                    //- a scheduled task is ready for processing
                    break;
                }
                if (Thread.interrupted()) {
                    //Thread was interrupted so reset selected keys and break so we not run into a busy loop.
                    //As this is most likely a bug in the handler of the user or it's client library we will
                    //also log it.
                    //
                    //See https://github.com/netty/netty/issues/2426
                    if (logger.isDebugEnabled()) {
                        logger.debug("Selector.select() returned prematurely because " +
                                "Thread.currentThread().interrupt() was called. Use " +
                                "NioEventLoop.shutdownGracefully() to shutdown the NioEventLoop.");
                    }
                    selectCnt = 1;
                    break;
                }

                long time = System.nanoTime();
                if (time - TimeUnit.MILLISECONDS.toNanos(timeoutMillis) >= currentTimeNanos) {
                    //timeoutMillis elapsed without anything selected.
                    selectCnt = 1;
                } else if (SELECTOR_AUTO_REBUILD_THRESHOLD > 0 &&
                        selectCnt >= SELECTOR_AUTO_REBUILD_THRESHOLD) {
                    //The selector returned prematurely many times in a row.
                    //Rebuild the selector to work around the problem.
                    logger.warn(
                            "Selector.select() returned prematurely {} times in a row; rebuilding Selector {}.",
                            selectCnt, selector);

                    rebuildSelector();
                    selector = this.selector;

                    //Select again to populate selectedKeys.
                    selector.selectNow();
                    selectCnt = 1;
                    break;
                }

                currentTimeNanos = time;
            }

            if (selectCnt > MIN_PREMATURE_SELECTOR_RETURNS) {
                if (logger.isDebugEnabled()) {
                    logger.debug("Selector.select() returned prematurely {} times in a row for Selector {}.",
                            selectCnt - 1, selector);
                }
            }
        } catch (CancelledKeyException e) {
            if (logger.isDebugEnabled()) {
                logger.debug(CancelledKeyException.class.getSimpleName() + " raised by a Selector {} - JDK bug?",
                        selector, e);
            }
            //Harmless exception - log anyway
        }
    }
    ```

至此，SelectionKey的获取分析完毕

# 5 创建Channel

1. 如果，上一小结分析的select过程中，产生了新的SelectionKey，那么会在后续的位于`NioEventLoop`中的`run`方法中processSelectedKeys方法的继续处理
    * `processSelectedKeys`方法位于`NioEventLoop`
    ```java
    private void processSelectedKeys() {
        if (selectedKeys != null) {
            processSelectedKeysOptimized();
        } else {
            processSelectedKeysPlain(selector.selectedKeys());
        }
    }
    ```

    * 由于我们之前已经分析过，Selector中的selectedKeys字段已经被替换为自定义的类型，因此这里会走processSelectedKeysOptimized这条支路。`processSelectedKeysOptimized`方法位于`NioEventLoop`，该方法从SelectionKey中提取出附属的Channel，然后调用processSelectedKey方法进行处理
    ```java
    private void processSelectedKeysOptimized() {
        for (int i = 0; i < selectedKeys.size; ++i) {
            final SelectionKey k = selectedKeys.keys[i];
            //null out entry in the array to allow to have it GC'ed once the Channel close
            //See https://github.com/netty/netty/issues/2363
            selectedKeys.keys[i] = null;

            final Object a = k.attachment();

            if (a instanceof AbstractNioChannel) {
                processSelectedKey(k, (AbstractNioChannel) a);
            } else {
                @SuppressWarnings("unchecked")
                NioTask<SelectableChannel> task = (NioTask<SelectableChannel>) a;
                processSelectedKey(k, task);
            }

            if (needsToSelectAgain) {
                //null out entries in the array to allow to have it GC'ed once the Channel close
                //See https://github.com/netty/netty/issues/2363
                selectedKeys.reset(i + 1);

                selectAgain();
                i = -1;
            }
        }
    }
    ```

1. 回到位于`NioEventLoop`的`processSelectedKeysOptimized`方法，继续追踪`processSelectedKey`方法
    * `processSelectedKey`方法位于`NioEventLoop`，该方法从Channel中提取出Unsafe对象执行底层的read操作
    ```java
    private void processSelectedKey(SelectionKey k, AbstractNioChannel ch) {
        final AbstractNioChannel.NioUnsafe unsafe = ch.unsafe();
        if (!k.isValid()) {
            final EventLoop eventLoop;
            try {
                eventLoop = ch.eventLoop();
            } catch (Throwable ignored) {
                //If the channel implementation throws an exception because there is no event loop, we ignore this
                //because we are only trying to determine if ch is registered to this event loop and thus has authority
                //to close ch.
                return;
            }
            //Only close ch if ch is still registered to this EventLoop. ch could have deregistered from the event loop
            //and thus the SelectionKey could be cancelled as part of the deregistration process, but the channel is
            //still healthy and should not be closed.
            //See https://github.com/netty/netty/issues/5125
            if (eventLoop != this || eventLoop == null) {
                return;
            }
            //close the channel if the key is not valid anymore
            unsafe.close(unsafe.voidPromise());
            return;
        }

        try {
            int readyOps = k.readyOps();
            //We first need to call finishConnect() before try to trigger a read(...) or write(...) as otherwise
            //the NIO JDK channel implementation may throw a NotYetConnectedException.
            if ((readyOps & SelectionKey.OP_CONNECT) != 0) {
                //remove OP_CONNECT as otherwise Selector.select(..) will always return without blocking
                //See https://github.com/netty/netty/issues/924
                int ops = k.interestOps();
                ops &= ~SelectionKey.OP_CONNECT;
                k.interestOps(ops);

                unsafe.finishConnect();
            }

            //Process OP_WRITE first as we may be able to write some queued buffers and so free memory.
            if ((readyOps & SelectionKey.OP_WRITE) != 0) {
                //Call forceFlush which will also take care of clear the OP_WRITE once there is nothing left to write
                ch.unsafe().forceFlush();
            }

            //Also check for readOps of 0 to workaround possible JDK bug which may otherwise lead
            //to a spin loop
            if ((readyOps & (SelectionKey.OP_READ | SelectionKey.OP_ACCEPT)) != 0 || readyOps == 0) {
                //这里是关键！！！
                unsafe.read();
            }
        } catch (CancelledKeyException ignored) {
            unsafe.close(unsafe.voidPromise());
        }
    }
    ```

1. 继续追踪read方法
    * `read`方法位于`AbstractNioMessageChannel`的**非静态**内部类`NioMessageUnsafe`中，该方法的核心是doReadMessages方法
    ```java
        public void read() {
            assert eventLoop().inEventLoop();
            final ChannelConfig config = config();
            final ChannelPipeline pipeline = pipeline();
            final RecvByteBufAllocator.Handle allocHandle = unsafe().recvBufAllocHandle();
            allocHandle.reset(config);

            boolean closed = false;
            Throwable exception = null;
            try {
                try {
                    do {
                        int localRead = doReadMessages(readBuf);
                        if (localRead == 0) {
                            break;
                        }
                        if (localRead < 0) {
                            closed = true;
                            break;
                        }

                        allocHandle.incMessagesRead(localRead);
                    } while (allocHandle.continueReading());
                } catch (Throwable t) {
                    exception = t;
                }

                int size = readBuf.size();
                for (int i = 0; i < size; i ++) {
                    readPending = false;
                    pipeline.fireChannelRead(readBuf.get(i));
                }
                readBuf.clear();
                allocHandle.readComplete();
                pipeline.fireChannelReadComplete();

                if (exception != null) {
                    closed = closeOnReadError(exception);

                    pipeline.fireExceptionCaught(exception);
                }

                if (closed) {
                    inputShutdown = true;
                    if (isOpen()) {
                        close(voidPromise());
                    }
                }
            } finally {
                //Check if there is a readPending which was not processed yet.
                //This could be for two reasons:
                //* The user called Channel.read() or ChannelHandlerContext.read() in channelRead(...) method
                //* The user called Channel.read() or ChannelHandlerContext.read() in channelReadComplete(...) method
                //
                //See https://github.com/netty/netty/issues/2254
                if (!readPending && !config.isAutoRead()) {
                    removeReadOp();
                }
            }
        }
    ```

1. 然后，我们来看一下`doReadMessages`方法
    * `doReadMessages`方法位于`NioServerSocketChannel`中，该方法调用SocketUtils.accept方法获取一个java.nio.channels.SocketChannel，然后将其封装成NioSocketChannel中去
    ```java
    protected int doReadMessages(List<Object> buf) throws Exception {
        SocketChannel ch = SocketUtils.accept(javaChannel());

        try {
            if (ch != null) {
                buf.add(new NioSocketChannel(this, ch));
                return 1;
            }
        } catch (Throwable t) {
            logger.warn("Failed to create a new channel from an accepted socket.", t);

            try {
                ch.close();
            } catch (Throwable t2) {
                logger.warn("Failed to close a socket.", t2);
            }
        }

        return 0;
    }
    ```

1. 接下来，我们来跟踪一下NioSocketChannel的创建过程
    * 首先来看一下`NioSocketChannel`的构造方法，该方法继续调用父类构造方法，并且初始化config对象
    ```java
    public NioSocketChannel(Channel parent, SocketChannel socket) {
        super(parent, socket);
        config = new NioSocketChannelConfig(this, socket.socket());
    }
    ```

    * 接下来是`AbstractNioByteChannel`的构造方法，该构造方法继续调用父类构造方法，并传入参数`SelectionKey.OP_READ`
    ```java
    protected AbstractNioByteChannel(Channel parent, SelectableChannel ch) {
        super(parent, ch, SelectionKey.OP_READ);
    }
    ```

    * 接下来是`AbstractNioChannel`的构造方法，该方法设置NIO层面的相关参数，包括readInterestOp以及是否开启非阻塞模式，并继续调用父类构造方法
    ```java
    protected AbstractNioChannel(Channel parent, SelectableChannel ch, int readInterestOp) {
        super(parent);
        this.ch = ch;
        this.readInterestOp = readInterestOp;
        try {
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

    * 接下来是`AbstractChannel`的构造方法，该方法创建Unsafe对象来执行底层的IO操作，并且初始化pipeline
    ```java
    protected AbstractChannel(Channel parent) {
        this.parent = parent;
        id = newId();
        unsafe = newUnsafe();
        pipeline = newChannelPipeline();
    }
    ```

1. 接下来，回到位于`AbstractNioMessageChannel`的**非静态**内部类`NioMessageUnsafe`的`read`方法中，于是触发了一些生命周期，例如fireChannelRead以及fireChannelReadComplete等
    * 注意到，在服务端启动过程中，在NioServerSocketChannel中绑定了一个`ServerBootstrapAcceptor`，绑定的地方：**位于`ServerBootstrap`的`init`方法**，详见{% post_link Netty-服务端启动源码剖析 %}
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

                //这里进行了异步注入，注入了一个服务端内置的ChannelInboundHandler
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

1. 接下来，我们分析一下ServerBootstrapAcceptor这个服务端内置的Handler
    * `ServerBootstrapAcceptor`位于`ServerBootstrap`，是一个**静态**内部类。我们关注channelRead方法，该方法将我们在代码清单中配置的childHandler（即那个ChannelInitializer）添加到child Channel的Pipeline中，要注意，此时注入的仅仅是这个ChannelInitializer，而非用户自定义的Handler
    * 用户自定义的Handler要等到后续的register操作过程中被注入到child Channel的Pipeline中
    ```java
    private static class ServerBootstrapAcceptor extends ChannelInboundHandlerAdapter {

        private final EventLoopGroup childGroup;
        private final ChannelHandler childHandler;
        private final Entry<ChannelOption<?>, Object>[] childOptions;
        private final Entry<AttributeKey<?>, Object>[] childAttrs;
        private final Runnable enableAutoReadTask;

        ServerBootstrapAcceptor(
                final Channel channel, EventLoopGroup childGroup, ChannelHandler childHandler,
                Entry<ChannelOption<?>, Object>[] childOptions, Entry<AttributeKey<?>, Object>[] childAttrs) {
            this.childGroup = childGroup;
            this.childHandler = childHandler;
            this.childOptions = childOptions;
            this.childAttrs = childAttrs;

            //Task which is scheduled to re-enable auto-read.
            //It's important to create this Runnable before we try to submit it as otherwise the URLClassLoader may
            //not be able to load the class because of the file limit it already reached.
            //
            //See https://github.com/netty/netty/issues/1328
            enableAutoReadTask = new Runnable() {
                @Override
                public void run() {
                    channel.config().setAutoRead(true);
                }
            };
        }

        @Override
        @SuppressWarnings("unchecked")
        public void channelRead(ChannelHandlerContext ctx, Object msg) {
            final Channel child = (Channel) msg;

            //这里将我们在代码清单中配置的childHandler（即那个ChannelInitializer）添加到child的Pipeline中
            child.pipeline().addLast(childHandler);

            setChannelOptions(child, childOptions, logger);

            for (Entry<AttributeKey<?>, Object> e: childAttrs) {
                child.attr((AttributeKey<Object>) e.getKey()).set(e.getValue());
            }

            try {
                childGroup.register(child).addListener(new ChannelFutureListener() {
                    @Override
                    public void operationComplete(ChannelFuture future) throws Exception {
                        if (!future.isSuccess()) {
                            forceClose(child, future.cause());
                        }
                    }
                });
            } catch (Throwable t) {
                forceClose(child, t);
            }
        }

        private static void forceClose(Channel child, Throwable t) {
            child.unsafe().closeForcibly();
            logger.warn("Failed to register an accepted channel: {}", child, t);
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            final ChannelConfig config = ctx.channel().config();
            if (config.isAutoRead()) {
                //stop accept new connections for 1 second to allow the channel to recover
                //See https://github.com/netty/netty/issues/1328
                config.setAutoRead(false);
                ctx.channel().eventLoop().schedule(enableAutoReadTask, 1, TimeUnit.SECONDS);
            }
            //still let the exceptionCaught event flow through the pipeline to give the user
            //a chance to do something with it
            ctx.fireExceptionCaught(cause);
        }
    }
    ```

1. 于是，回到位于`AbstractNioMessageChannel`的**非静态**内部类`NioMessageUnsafe`的`read`方法中来，触发的生命周期fireChannelRead将会触发`ServerBootstrapAcceptor`中的`channelRead`方法的调用，于是完成了Channel的创建以及初始化工作

至此，Channel的创建以及初始化工作完毕

# 6 注册Channel

**这之后的执行过程与{% post_link Netty-服务端启动源码剖析 %}中的register过程完全一致**

1. 我们接着回到位于`ServerBootstrap`的**静态**内部来`ServerBootstrapAcceptor`的`channelRead`方法中来，继续register方法的分析
    * `register`方法位于`MultithreadEventLoopGroup`，调用next方法获取EventLoop来执行register方法
    ```java
    public ChannelFuture register(Channel channel) {
        return next().register(channel);
    }
    ```

    * `register`方法位于`SingleThreadEventLoop`，该方法创建了一个ChannelPromise，并继续调用同名的register方法
    ```java
    public ChannelFuture register(Channel channel) {
        return register(new DefaultChannelPromise(channel, this));
    }
    ```

    * `register`方法位于`SingleThreadEventLoop`，该方法获取Unsafe对象来执行相应的register操作
    ```java
    public ChannelFuture register(final ChannelPromise promise) {
        ObjectUtil.checkNotNull(promise, "promise");
        promise.channel().unsafe().register(this, promise);
        return promise;
    }
    ```

    * `register`方法位于`AbstractChannel`中的**非静态**内部类`AbstractUnsafe`，该方法主要通过异步方式执行了register0方法
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

1. 接下来跟踪register0的执行流程
    * `register0`方法位于`AbstractChannel`中的**非静态**内部类`AbstractUnsafe`，该方法主要执行了doRegister方法，并触发了一些生命周期，例如invokeHandlerAddedIfNeeded、fireChannelRegistered、fireChannelActive
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

    * `doRegister`方法位于`AbstractNioChannel`，该方法执行底层的Java NIO API的register操作
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

1. 接着，我们关注一下invokeHandlerAddedIfNeeded的执行路径
    * `invokeHandlerAddedIfNeeded`方法位于`DefaultChannelPipeline`，该方法只有在第一次注册的时候才会触发callHandlerAddedForAllHandlers
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

    * `callHandlerAddedForAllHandlers`方法位于`DefaultChannelPipeline`，该方法执行了pendingTask的execute方法，该task的实现类是PendingHandlerAddedTask
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

    * `execute`方法位于`DefaultChannelPipeline`中的**非静态**内部类`PendingHandlerAddedTask`，该方法主要用于触发callHandlerAdded0方法
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

    * `callHandlerAdded0`方法位于`DefaultChannelPipeline`，这里显式调用了handler的handlerAdded方法。注意到handler()方法返回的是我们在代码清单中配置的ChannelInitializer，因此调用该ChannelInitializer的handlerAdded方法，会将我们配置的用户的Handler注入到Channel的pipeline中
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

至此，Channel注册分析完毕

