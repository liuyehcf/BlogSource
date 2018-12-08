---
title: Netty-Demo
date: 2018-10-21 12:06:23
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__阅读更多__

<!--more-->

# 1 WebSocket

下面给的示例中，涉及到SSL，其`keySotre`与`cert`的生成请参考{% post_link SSL协议 %}

## 1.1 Server

```Java
package org.liuyehcf.netty.ws;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.websocketx.*;
import io.netty.handler.codec.http.websocketx.extensions.compression.WebSocketServerCompressionHandler;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.SslHandler;
import io.netty.handler.stream.ChunkedWriteHandler;
import io.netty.handler.timeout.IdleStateHandler;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;
import java.io.File;
import java.io.FileInputStream;
import java.nio.charset.Charset;
import java.security.KeyStore;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class Server {

    private static final String HOST = "localhost";
    private static final int PORT = 8866;
    private static final boolean OPEN_SSL = true;

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_server_ks";
    private static final String STORE_TYPE = "PKCS12";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    public static void main(String[] args) throws Exception {
        final EventLoopGroup boss = new NioEventLoopGroup();
        final EventLoopGroup worker = new NioEventLoopGroup();

        final ServerBootstrap bootstrap = new ServerBootstrap();
        bootstrap.group(boss, worker)
                .channel(NioServerSocketChannel.class)
                .childHandler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel socketChannel) throws Exception {
                        ChannelPipeline pipeline = socketChannel.pipeline();
                        pipeline.addLast(new IdleStateHandler(0, 0, 60, TimeUnit.SECONDS));
                        if (OPEN_SSL) {
                            pipeline.addLast(createSslHandlerUsingRawApi());
//                            pipeline.addLast(createSslHandlerUsingNetty(pipeline));
                        }
                        pipeline.addLast(new HttpServerCodec());
                        pipeline.addLast(new HttpObjectAggregator(65535));
                        pipeline.addLast(new ChunkedWriteHandler());
                        pipeline.addLast(new WebSocketServerCompressionHandler());
                        pipeline.addLast(new WebSocketServerProtocolHandler("/", null, true));
                        pipeline.addLast(new ServerHandler());
                    }
                })
                .option(ChannelOption.SO_BACKLOG, 1024)
                .childOption(ChannelOption.SO_KEEPALIVE, true)
                .childOption(ChannelOption.TCP_NODELAY, true)
                .childOption(ChannelOption.SO_REUSEADDR, true);

        final ChannelFuture future = bootstrap.bind(PORT).sync();
        System.out.println("server start ...... ");

        future.channel().closeFuture().sync();
    }

    private static ChannelHandler createSslHandlerUsingRawApi() throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        SSLEngine sslEngine = sslContext.createSSLEngine();
        sslEngine.setUseClientMode(false);
        return new SslHandler(sslEngine);
    }

    private static ChannelHandler createSslHandlerUsingNetty(ChannelPipeline pipeline) throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        return SslContextBuilder.forServer(keyManagerFactory).build()
                .newHandler(pipeline.channel().alloc(), HOST, PORT);
    }

    private static final class ServerHandler extends SimpleChannelInboundHandler<WebSocketFrame> {
        @Override
        @SuppressWarnings("all")
        protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame msg) {
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

            System.out.println("server receive message: " + content);

            ctx.channel().writeAndFlush(new BinaryWebSocketFrame(Unpooled.wrappedBuffer("Hi, I'm Server".getBytes())));
        }
    }
}
```

## 1.2 Client

```Java
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
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.SslHandler;
import io.netty.handler.stream.ChunkedWriteHandler;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.TrustManagerFactory;
import java.io.File;
import java.io.FileInputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.security.KeyStore;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class Client {

    private static final String HOST = "localhost";
    private static final int PORT = 8866;
    private static final boolean OPEN_SSL = true;

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_client_ks";
    private static final String STORE_TYPE = "PKCS12";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "345678";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    public static void main(String[] args) throws Exception {
        final URI webSocketURI = getUri();

        final WebSocketClientHandler webSocketClientHandler = new WebSocketClientHandler(
                WebSocketClientHandshakerFactory.newHandshaker(
                        webSocketURI, WebSocketVersion.V13, null, true, new DefaultHttpHeaders()));

        final EventLoopGroup group = new NioEventLoopGroup();
        final Bootstrap boot = new Bootstrap();
        boot.group(group)
                .channel(NioSocketChannel.class)
                .handler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel socketChannel) throws Exception {
                        ChannelPipeline pipeline = socketChannel.pipeline();
                        if (OPEN_SSL) {
                            pipeline.addLast(createSslHandlerUsingRawApi());
//                            pipeline.addLast(createSslHandlerUsingNetty(pipeline));
                        }
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
        webSocketClientHandler.handshakeFuture().sync();

        channel.writeAndFlush(new TextWebSocketFrame("Hello, I'm client"));

        TimeUnit.SECONDS.sleep(1);
        System.exit(0);
    }

    private static URI getUri() {
        try {
            return new URI(String.format("%s://%s:%d", OPEN_SSL ? "wss" : "ws", HOST, PORT));
        } catch (URISyntaxException e) {
            throw new RuntimeException(e);
        }
    }

    private static ChannelHandler createSslHandlerUsingRawApi() throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        SSLEngine sslEngine = sslContext.createSSLEngine();
        sslEngine.setUseClientMode(true);
        return new SslHandler(sslEngine);
    }

    private static ChannelHandler createSslHandlerUsingNetty(ChannelPipeline pipeline) throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        return SslContextBuilder.forClient().trustManager(trustManagerFactory).build()
                .newHandler(pipeline.channel().alloc(), HOST, PORT);
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

## 1.3 WebSocketClientHandler

```Java
package org.liuyehcf.netty.ws;

import io.netty.channel.*;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.websocketx.*;
import io.netty.util.CharsetUtil;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class WebSocketClientHandler extends SimpleChannelInboundHandler<Object> {

    /**
     * netty build-in web socket hand shaker
     */
    private final WebSocketClientHandshaker handShaker;

    /**
     * future on where hand shaker is completed
     */
    private ChannelPromise handshakeFuture;

    public WebSocketClientHandler(WebSocketClientHandshaker handShaker) {
        this.handShaker = handShaker;
    }

    public ChannelFuture handshakeFuture() {
        return this.handshakeFuture;
    }

    @Override
    public void handlerAdded(ChannelHandlerContext ctx) {
        this.handshakeFuture = ctx.newPromise();
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        // execution timing must after all the handlers are added
        // other wise exception may occurred (ChannelPipeline does not contain a HttpRequestEncoder or HttpClientCodec)
        handShaker.handshake(ctx.channel());
        super.channelActive(ctx);
    }

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, Object msg) {
        final Channel channel = ctx.channel();
        final FullHttpResponse response;
        if (!this.handShaker.isHandshakeComplete()) {
            try {
                response = (FullHttpResponse) msg;
                this.handShaker.finishHandshake(channel, response);

                // listeners is going to be trigger
                this.handshakeFuture.setSuccess();
            } catch (WebSocketHandshakeException var7) {
                FullHttpResponse res = (FullHttpResponse) msg;
                String errorMsg = String.format("webSocket Client failed to connect. status='%s'; reason='%s'", res.status(), res.content().toString(CharsetUtil.UTF_8));

                // listeners is going to be trigger
                this.handshakeFuture.setFailure(new Exception(errorMsg));
            }
        } else if (msg instanceof FullHttpResponse) {
            response = (FullHttpResponse) msg;
            throw new IllegalStateException("unexpected FullHttpResponse (getStatus=" + response.status() + ", content=" + response.content().toString(CharsetUtil.UTF_8) + ')');
        } else if (msg instanceof TextWebSocketFrame) {
            ctx.fireChannelRead(((TextWebSocketFrame) msg).retain());
        } else if (msg instanceof BinaryWebSocketFrame) {
            ctx.fireChannelRead(((BinaryWebSocketFrame) msg).retain());
        } else if (msg instanceof ContinuationWebSocketFrame) {
            // do nothing
        } else if (msg instanceof PingWebSocketFrame) {
            // do nothing
        } else if (msg instanceof PongWebSocketFrame) {
            // do nothing
        } else if (msg instanceof CloseWebSocketFrame) {
            channel.close();
        } else {
            throw new IllegalStateException("unexpected MessageType='" + msg.getClass() + "'");
        }
    }
}
```

# 2 问题

## 2.1 unsupported message type: TextWebSocketFrame

### 2.1.1 复现问题

__对Client进行如下改造__：

1. 将`handshake`挪到`connect`之后执行（原本在`WebSocketClientHandler.channelActive`方法中执行）
1. 循环connect，直到出现异常（问题出现的概率较小，因此用死循环循环）
```Java
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

__对WebSocketClientHandler进行如下改造__：

1. 注释掉`handShaker.handshake(ctx.channel());`一句

```Java
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        // execution timing must after all the handlers are added
        // other wise exception may occurred (ChannelPipeline does not contain a HttpRequestEncoder or HttpClientCodec)
//        handShaker.handshake(ctx.channel());
        super.channelActive(ctx);
    }
```

__运行后得到如下异常__

```Java
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

### 2.1.2 问题分析

我们分别在写回调中的正常case以及异常case处打上断点，看一看正常情况下以及异常情况下`ChannelPipeline`的差异

```Java
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

__正常的时候，其handler如下__

1. WebSocket13FrameDecoder
1. WebSocket13FrameEncoder
1. ChunkedWriteHandler
1. PerMessageDeflateEncoder
1. PerMessageDeflateDecoder
1. WebSocketClientHandler
1. ClientHandler

__异常的时候，其handler如下__

1. WebSocket13FrameDecoder
1. ChunkedWriteHandler
1. PerMessageDeflateEncoder
1. PerMessageDeflateDecoder
1. WebSocketClientHandler
1. ClientHandler

对比正常/异常情况下的handler，我们可以发现，异常情况下，缺少了`WebSocket13FrameEncoder`

`WebSocket13FrameEncoder`在`handshake`过程中被添加到`ChannelPipeline`中去，`handshake`方法如下

```Java
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

## 2.2 webSocket连接占用内存过高

表面原因是由于增加了以下两个Handler，这两个handler会用到`JdkZlibDecoder`，而`JdkZlibDecoder`在处理过程中会分配大量内存

* WebSocketClientCompressionHandler.INSTANCE
* WebSocketServerCompressionHandler

# 3 参考

* [Java SSL 证书细节](https://www.jianshu.com/p/5fcc6a219c8b)
* [JDK自带工具keytool生成ssl证书](https://www.cnblogs.com/zhangzb/p/5200418.html)
* [netty-example](https://github.com/spmallette/netty-example/blob/master/src/test/java/com/genoprime/netty/example/WebSocketClientHandler.java)
* [单机千万并发连接实战](https://zhuanlan.zhihu.com/p/21378825)
