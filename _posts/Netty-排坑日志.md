---
title: Netty-排坑日志
date: 2020-04-19 20:34:25
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

**阅读更多**

<!--more-->

# 1 issue-1：unsupported message type: TextWebSocketFrame

## 1.1 复现问题

**对Client进行如下改造**：

1. 将`handshake`挪到`connect`之后执行（原本在`WebSocketClientHandler.channelActive`方法中执行）
1. 循环connect，直到出现异常（问题出现的概率较小，因此用死循环循环）
```java
package org.liuyehcf.netty.ws;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.http.DefaultHttpHeaders;
import io.netty.handler.codec.http.HttpClientCodec;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.websocketx.*;
import io.netty.handler.codec.http.websocketx.extensions.compression.WebSocketClientCompressionHandler;
import io.netty.handler.stream.ChunkedWriteHandler;

import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class Client {
    public static void main(String[] args) throws Exception {
        final URI webSocketURI = getUri();
        final EventLoopGroup group = new NioEventLoopGroup();
        while (true) {

            final WebSocketClientHandshaker handShaker = WebSocketClientHandshakerFactory.newHandshaker(
                    webSocketURI, WebSocketVersion.V13, null, true, new DefaultHttpHeaders());
            final WebSocketClientHandler webSocketClientHandler = new WebSocketClientHandler(handShaker);

            final Bootstrap boot = new Bootstrap();
            boot.group(group)
                    .channel(NioSocketChannel.class)
                    .handler(new ChannelInitializer<SocketChannel>() {
                        protected void initChannel(SocketChannel socketChannel) {
                            ChannelPipeline pipeline = socketChannel.pipeline();
                            pipeline.addLast(new HttpClientCodec());
                            pipeline.addLast(new HttpObjectAggregator(65535));
                            pipeline.addLast(new ChunkedWriteHandler());
                            pipeline.addLast(WebSocketClientCompressionHandler.INSTANCE);
                            pipeline.addLast(webSocketClientHandler);
                            pipeline.addLast(new ClientHandler());
                        }
                    })
                    .option(ChannelOption.SO_KEEPALIVE, true)
                    .option(ChannelOption.TCP_NODELAY, true)
                    .option(ChannelOption.SO_BACKLOG, 1024);

            final Channel channel = boot.connect(webSocketURI.getHost(), webSocketURI.getPort()).sync().channel();
            handShaker.handshake(channel);
            webSocketClientHandler.handshakeFuture().sync();

            channel.writeAndFlush(new TextWebSocketFrame("Hello, I'm client"))
                    .addListener((ChannelFuture future) -> {
                        if (!future.isSuccess() && future.cause() != null) {
                            future.cause().printStackTrace();
                            System.exit(1);
                        } else {
                            System.out.println("normal case");
                        }
                    })
                    .addListener(ChannelFutureListener.CLOSE);

        }
    }

    private static URI getUri() {
        try {
            return new URI("ws://localhost:8866");
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }

    private static final class ClientHandler extends SimpleChannelInboundHandler<WebSocketFrame> {
        @Override
        @SuppressWarnings("all")
        protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame msg) throws Exception {
            final String content;
            if (msg instanceof BinaryWebSocketFrame) {
                BinaryWebSocketFrame binaryWebSocketFrame = (BinaryWebSocketFrame) msg;
                ByteBuf byteBuf = binaryWebSocketFrame.content();
                byte[] bytes = new byte[byteBuf.readableBytes()];
                byteBuf.getBytes(0, bytes);
                content = new String(bytes, Charset.defaultCharset());
            } else if (msg instanceof TextWebSocketFrame) {
                content = ((TextWebSocketFrame) msg).text();
            } else if (msg instanceof PongWebSocketFrame) {
                content = "Pong";
            } else if (msg instanceof ContinuationWebSocketFrame) {
                content = "Continue";
            } else if (msg instanceof PingWebSocketFrame) {
                content = "Ping";
            } else if (msg instanceof CloseWebSocketFrame) {
                content = "Close";
                ctx.close();
            } else {
                throw new RuntimeException();
            }

            System.out.println("client receive message: " + content);
        }
    }
}
```

**对WebSocketClientHandler进行如下改造**：

1. 注释掉`handShaker.handshake(ctx.channel());`一句

```java
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        // execution timing must after all the handlers are added
        // other wise exception may occurred (ChannelPipeline does not contain a HttpRequestEncoder or HttpClientCodec)
//        handShaker.handshake(ctx.channel());
        super.channelActive(ctx);
    }
```

**运行后得到如下异常**

```java
java.lang.UnsupportedOperationException: unsupported message type: TextWebSocketFrame (expected: ByteBuf, FileRegion)
    at io.netty.channel.nio.AbstractNioByteChannel.filterOutboundMessage(AbstractNioByteChannel.java:283)
    at io.netty.channel.AbstractChannel$AbstractUnsafe.write(AbstractChannel.java:877)
    at io.netty.channel.DefaultChannelPipeline$HeadContext.write(DefaultChannelPipeline.java:1391)
    at io.netty.channel.AbstractChannelHandlerContext.invokeWrite0(AbstractChannelHandlerContext.java:738)
    at io.netty.channel.AbstractChannelHandlerContext.invokeWrite(AbstractChannelHandlerContext.java:730)
    at io.netty.channel.AbstractChannelHandlerContext.write(AbstractChannelHandlerContext.java:816)
    at io.netty.channel.AbstractChannelHandlerContext.write(AbstractChannelHandlerContext.java:723)
    at io.netty.handler.stream.ChunkedWriteHandler.doFlush(ChunkedWriteHandler.java:305)
    at io.netty.handler.stream.ChunkedWriteHandler.flush(ChunkedWriteHandler.java:135)
    at io.netty.channel.AbstractChannelHandlerContext.invokeFlush0(AbstractChannelHandlerContext.java:776)
    at io.netty.channel.AbstractChannelHandlerContext.invokeFlush(AbstractChannelHandlerContext.java:768)
    at io.netty.channel.AbstractChannelHandlerContext.flush(AbstractChannelHandlerContext.java:749)
    at io.netty.channel.ChannelOutboundHandlerAdapter.flush(ChannelOutboundHandlerAdapter.java:115)
    at io.netty.channel.AbstractChannelHandlerContext.invokeFlush0(AbstractChannelHandlerContext.java:776)
    at io.netty.channel.AbstractChannelHandlerContext.invokeFlush(AbstractChannelHandlerContext.java:768)
    at io.netty.channel.AbstractChannelHandlerContext.access$1500(AbstractChannelHandlerContext.java:38)
    at io.netty.channel.AbstractChannelHandlerContext$WriteAndFlushTask.write(AbstractChannelHandlerContext.java:1152)
    at io.netty.channel.AbstractChannelHandlerContext$AbstractWriteTask.run(AbstractChannelHandlerContext.java:1075)
    at io.netty.util.concurrent.AbstractEventExecutor.safeExecute(AbstractEventExecutor.java:163)
    at io.netty.util.concurrent.SingleThreadEventExecutor.runAllTasks(SingleThreadEventExecutor.java:404)
    at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:466)
    at io.netty.util.concurrent.SingleThreadEventExecutor$5.run(SingleThreadEventExecutor.java:897)
    at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30)
    at java.lang.Thread.run(Thread.java:748)
```

## 1.2 问题分析

我们分别在写回调中的正常case以及异常case处打上断点，看一看正常情况下以及异常情况下`ChannelPipeline`的差异

```java
channel.writeAndFlush(new TextWebSocketFrame("Hello, I'm client"))
    .addListener((ChannelFuture future) -> {
        if (!future.isSuccess() && future.cause() != null) {
            // 这里打个断点，异常情况
            future.cause().printStackTrace();
            System.exit(1);
        } else {
            // 这里打个断点，正常情况
            System.out.println("normal case");
        }
    })
    .addListener(ChannelFutureListener.CLOSE);
```

**正常的时候，其handler如下**

1. WebSocket13FrameDecoder
1. WebSocket13FrameEncoder
1. ChunkedWriteHandler
1. PerMessageDeflateEncoder
1. PerMessageDeflateDecoder
1. WebSocketClientHandler
1. ClientHandler

**异常的时候，其handler如下**

1. WebSocket13FrameDecoder
1. ChunkedWriteHandler
1. PerMessageDeflateEncoder
1. PerMessageDeflateDecoder
1. WebSocketClientHandler
1. ClientHandler

对比正常/异常情况下的handler，我们可以发现，异常情况下，缺少了`WebSocket13FrameEncoder`

`WebSocket13FrameEncoder`在`handshake`过程中被添加到`ChannelPipeline`中去，`handshake`方法如下

```java
    public final ChannelFuture handshake(Channel channel, final ChannelPromise promise) {
        FullHttpRequest request =  newHandshakeRequest();

        HttpResponseDecoder decoder = channel.pipeline().get(HttpResponseDecoder.class);
        if (decoder == null) {
            HttpClientCodec codec = channel.pipeline().get(HttpClientCodec.class);
            if (codec == null) {
               promise.setFailure(new IllegalStateException("ChannelPipeline does not contain " +
                       "a HttpResponseDecoder or HttpClientCodec"));
               return promise;
            }
        }

        channel.writeAndFlush(request).addListener(new ChannelFutureListener() {
            @Override
            public void operationComplete(ChannelFuture future) {
                if (future.isSuccess()) {
                    ChannelPipeline p = future.channel().pipeline();
                    ChannelHandlerContext ctx = p.context(HttpRequestEncoder.class);
                    if (ctx == null) {
                        ctx = p.context(HttpClientCodec.class);
                    }

                    // 实际情况是这里抛出了异常，导致下一句没有执行
                    if (ctx == null) {
                        promise.setFailure(new IllegalStateException("ChannelPipeline does not contain " +
                                "a HttpRequestEncoder or HttpClientCodec"));
                        return;
                    }
                    p.addAfter(ctx.name(), "ws-encoder", newWebSocketEncoder());

                    promise.setSuccess();
                } else {
                    promise.setFailure(future.cause());
                }
            }
        });
        return promise;
    }
```

为什么在外部执行`handshake`会导致这个问题，目前还不清楚

# 2 issue-2：webSocket连接占用内存过高

表面原因是由于增加了以下两个Handler，这两个handler会用到`JdkZlibDecoder`，而`JdkZlibDecoder`在处理过程中会分配大量内存

* WebSocketClientCompressionHandler.INSTANCE
* WebSocketServerCompressionHandler

# 3 issue-3：OutOfDirectMemoryError

在项目中，我需要将获取到的`FullHttpRequest`转成对应的字节数组，用到了Netty提供的`EmbeddedChannel`来进行转换，最开始代码如下

```java
@Override
protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest msg) {
    EmbeddedChannel ch = new EmbeddedChannel(new HttpRequestEncoder());
    ByteBuf byteBuf = null;
    try {
        ch.writeOutbound(msg.retain());
        byteBuf = ch.readOutbound();

        byte[] bytes = new byte[byteBuf.readableBytes()];
        byteBuf.readBytes(bytes);
    } finally {
        ch.close();
    }
}
```

在测试环境压测一端时间后发现了如下的异常

```
[2019-06-25 09:52:15]11.158.132.167
content: io.netty.util.internal.OutOfDirectMemoryError: failed to allocate 16777216 byte(s) of direct memory (used: 1056964615, max: 1073741824)
content: at io.netty.util.internal.PlatformDependent.incrementMemoryCounter(PlatformDependent.java:656)
content: at io.netty.util.internal.PlatformDependent.allocateDirectNoCleaner(PlatformDependent.java:610)
content: at io.netty.buffer.PoolArena$DirectArena.allocateDirect(PoolArena.java:764)
content: at io.netty.buffer.PoolArena$DirectArena.newChunk(PoolArena.java:740)
content: at io.netty.buffer.PoolArena.allocateNormal(PoolArena.java:244)
content: at io.netty.buffer.PoolArena.allocate(PoolArena.java:226)
content: at io.netty.buffer.PoolArena.allocate(PoolArena.java:146)
content: at io.netty.buffer.PooledByteBufAllocator.newDirectBuffer(PooledByteBufAllocator.java:324)
content: at io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:185)
content: at io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:176)
content: at io.netty.buffer.AbstractByteBufAllocator.ioBuffer(AbstractByteBufAllocator.java:137)
content: at io.netty.channel.DefaultMaxMessagesRecvByteBufAllocator$MaxMessageHandle.allocate(DefaultMaxMessagesRecvByteBufAllocator.java:114)
content: at io.netty.channel.nio.AbstractNioByteChannel$NioByteUnsafe.read(AbstractNioByteChannel.java:147)
content: at io.netty.channel.nio.NioEventLoop.processSelectedKey(NioEventLoop.java:648)
content: at io.netty.channel.nio.NioEventLoop.processSelectedKeysOptimized(NioEventLoop.java:583)
content: at io.netty.channel.nio.NioEventLoop.processSelectedKeys(NioEventLoop.java:500)
content: at io.netty.channel.nio.NioEventLoop.run(NioEventLoop.java:462)
content: at io.netty.util.concurrent.SingleThreadEventExecutor$5.run(SingleThreadEventExecutor.java:897)
content: at io.netty.util.concurrent.FastThreadLocalRunnable.run(FastThreadLocalRunnable.java:30)
content: at java.lang.Thread.run(Thread.java:766)
```

**原因，没有释放`ch.readOutbound()`返回的`ByteBuf`，调整代码如下：**

```java
@Override
protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest msg) {
    EmbeddedChannel ch = new EmbeddedChannel(new HttpRequestEncoder());
    ByteBuf byteBuf = null;
    try {
        ch.writeOutbound(msg.retain());
        byteBuf = ch.readOutbound();

        byte[] bytes = new byte[byteBuf.readableBytes()];
        byteBuf.readBytes(bytes);
    } finally {
        ReferenceCountUtil.release(byteBuf); // 释放
        ch.close();
    }
}
```

# 4 issue-4：LEAK: ByteBuf.release() was not called before it's garbage-collected

在使用`EmbeddedChannel`的时候，并发高的时候，总是会出现如下异常堆栈。我已经在适当的时间进行资源清理操作了（调用了`EmbeddedChannel#close()`）

```java
2020-04-17 10:30:24.784 [ERROR] [nioEventLoopGroup-3-4] --- LEAK: ByteBuf.release() was not called before it's garbage-collected. See http://netty.io/wiki/reference-counted-objects.html for more information.
Recent access records:
Created at:
	io.netty.buffer.PooledByteBufAllocator.newDirectBuffer(PooledByteBufAllocator.java:331)
	io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:185)
	io.netty.buffer.AbstractByteBufAllocator.directBuffer(AbstractByteBufAllocator.java:176)
	io.netty.buffer.AbstractByteBufAllocator.buffer(AbstractByteBufAllocator.java:113)
	io.netty.handler.ssl.SslHandler.allocate(SslHandler.java:1914)
	io.netty.handler.ssl.SslHandler.allocateOutNetBuf(SslHandler.java:1923)
	io.netty.handler.ssl.SslHandler.wrap(SslHandler.java:822)
	io.netty.handler.ssl.SslHandler.wrapAndFlush(SslHandler.java:793)
	io.netty.handler.ssl.SslHandler.flush(SslHandler.java:774)
	io.netty.handler.ssl.SslHandler.flush(SslHandler.java:1650)
	io.netty.handler.ssl.SslHandler.closeOutboundAndChannel(SslHandler.java:1618)
	io.netty.handler.ssl.SslHandler.close(SslHandler.java:732)
	io.netty.channel.AbstractChannelHandlerContext.invokeClose(AbstractChannelHandlerContext.java:624)
	io.netty.channel.AbstractChannelHandlerContext.close(AbstractChannelHandlerContext.java:608)
	io.netty.channel.CombinedChannelDuplexHandler$DelegatingChannelHandlerContext.close(CombinedChannelDuplexHandler.java:507)
	io.netty.channel.ChannelOutboundHandlerAdapter.close(ChannelOutboundHandlerAdapter.java:71)
	io.netty.channel.CombinedChannelDuplexHandler.close(CombinedChannelDuplexHandler.java:318)
	io.netty.channel.AbstractChannelHandlerContext.invokeClose(AbstractChannelHandlerContext.java:624)
	io.netty.channel.AbstractChannelHandlerContext.close(AbstractChannelHandlerContext.java:608)
	io.netty.channel.DefaultChannelPipeline.close(DefaultChannelPipeline.java:1040)
	io.netty.channel.AbstractChannel.close(AbstractChannel.java:274)
	io.netty.channel.embedded.EmbeddedChannel.close(EmbeddedChannel.java:550)
	io.netty.channel.embedded.EmbeddedChannel.close(EmbeddedChannel.java:537)
```

原因如下：`EmbeddedChannel`在异常情况下关闭时，可能还存在尚未读取的消息或者尚未写入的消息，这些消息如果不得到即使清理（调用release方法），那么就会产生`LEAK`异常

正确的做法是，调用`EmbeddedChannel#finishAndReleaseAll()`方法来清理资源，该方法会负责清理所有暂未处理的消息

## 4.1 参考

* [Correctly close EmbeddedChannel and release buffers](https://github.com/netty/netty/pull/9851)

