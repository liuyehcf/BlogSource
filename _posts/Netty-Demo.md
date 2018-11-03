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

## 1.1 Server

```java
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
import io.netty.handler.stream.ChunkedWriteHandler;
import io.netty.handler.timeout.IdleStateHandler;

import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class Server {
    public static void main(String[] args) {
        EventLoopGroup boss = new NioEventLoopGroup();
        EventLoopGroup worker = new NioEventLoopGroup();

        try {
            ServerBootstrap bootstrap = new ServerBootstrap();
            bootstrap.group(boss, worker)
                    .channel(NioServerSocketChannel.class)
                    .childHandler(new ChannelInitializer<SocketChannel>() {
                        @Override
                        protected void initChannel(SocketChannel socketChannel) {
                            ChannelPipeline pipeline = socketChannel.pipeline();
                            pipeline.addLast(new IdleStateHandler(0, 0, 60, TimeUnit.SECONDS));
                            pipeline.addLast(new HttpServerCodec());
                            pipeline.addLast(new ChunkedWriteHandler());
                            pipeline.addLast(new HttpObjectAggregator(65535));
                            pipeline.addLast(new WebSocketServerCompressionHandler());
                            pipeline.addLast(new WebSocketServerProtocolHandler("/", null, true));
                            pipeline.addLast(new ServerHandler());
                        }
                    })
                    .option(ChannelOption.SO_BACKLOG, 128)
                    .childOption(ChannelOption.SO_KEEPALIVE, true)
                    .childOption(ChannelOption.TCP_NODELAY, true)
                    .childOption(ChannelOption.SO_REUSEADDR, true);

            ChannelFuture future = bootstrap.bind(8866).sync();
            System.out.println("server start ...... ");

            future.channel().closeFuture().sync();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            boss.shutdownGracefully();
            worker.shutdownGracefully();
        }
    }

    private static final class ServerHandler extends SimpleChannelInboundHandler<WebSocketFrame> {
        @Override
        protected final void channelRead0(ChannelHandlerContext ctx, WebSocketFrame msg) {
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

        @Override
        public final void channelActive(ChannelHandlerContext ctx) {
            System.out.println("channelActive");
        }

        @Override
        public final void channelInactive(ChannelHandlerContext ctx) {
            System.out.println("channelInactive");
        }

        @Override
        public final void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
            ctx.channel().close();
            cause.printStackTrace();
        }
    }
}
```

## 1.2 Client

```java
package org.liuyehcf.netty.ws;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.http.DefaultHttpHeaders;
import io.netty.handler.codec.http.HttpClientCodec;
import io.netty.handler.codec.http.HttpHeaders;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.websocketx.*;
import io.netty.handler.codec.http.websocketx.extensions.compression.WebSocketClientCompressionHandler;
import io.netty.handler.logging.LogLevel;
import io.netty.handler.logging.LoggingHandler;
import io.netty.handler.stream.ChunkedWriteHandler;

import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/11/3
 */
public class Client {
    public static void main(String[] args) {
        URI webSocketURI = getUri();
        HttpHeaders httpHeaders = new DefaultHttpHeaders();
        WebSocketClientHandshaker handShaker = WebSocketClientHandshakerFactory.newHandshaker(webSocketURI, WebSocketVersion.V13, null, true, httpHeaders);

        WebSocketClientHandler webSocketClientHandler = new WebSocketClientHandler(handShaker);

        EventLoopGroup group = new NioEventLoopGroup();
        Bootstrap boot = new Bootstrap();
        boot.group(group)
                .handler(new LoggingHandler(LogLevel.INFO))
                .channel(NioSocketChannel.class)
                .handler(new ChannelInitializer<SocketChannel>() {
                    protected void initChannel(SocketChannel socketChannel) {
                        ChannelPipeline pipeline = socketChannel.pipeline();
                        pipeline.addLast(new HttpClientCodec());
                        pipeline.addLast(new ChunkedWriteHandler());
                        pipeline.addLast(new HttpObjectAggregator(65535));
                        pipeline.addLast(WebSocketClientCompressionHandler.INSTANCE);
                        pipeline.addLast(webSocketClientHandler);
                        pipeline.addLast(new ClientHandler());
                    }
                })
                .option(ChannelOption.SO_KEEPALIVE, true)
                .option(ChannelOption.TCP_NODELAY, true)
                .option(ChannelOption.SO_BACKLOG, 1024 * 1024 * 10);

        try {
            final Channel channel = boot.connect(webSocketURI.getHost(), webSocketURI.getPort()).sync().channel();
            handShaker.handshake(channel);
            webSocketClientHandler.handshakeFuture().sync();

            channel.writeAndFlush(new TextWebSocketFrame("Hello, I'm client"));

            TimeUnit.SECONDS.sleep(2);
            System.exit(0);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
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
        protected final void channelRead0(ChannelHandlerContext ctx, WebSocketFrame msg) {
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

        @Override
        public final void channelActive(ChannelHandlerContext ctx) {
            System.out.println("channelActive");
        }

        @Override
        public final void channelInactive(ChannelHandlerContext ctx) {
            System.out.println("channelInactive");
        }

        @Override
        public final void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
            ctx.channel().close();
            cause.printStackTrace();
        }
    }
}
```

## 1.3 WebSocketClientHandler

```java
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
    private final WebSocketClientHandshaker handShaker;
    private ChannelPromise handshakeFuture;

    WebSocketClientHandler(WebSocketClientHandshaker handShaker) {
        this.handShaker = handShaker;
    }

    @Override
    public void handlerAdded(ChannelHandlerContext ctx) {
        this.handshakeFuture = ctx.newPromise();
    }

    ChannelFuture handshakeFuture() {
        return this.handshakeFuture;
    }

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

# 2 参考

* [Java SSL 证书细节](https://www.jianshu.com/p/5fcc6a219c8b)
* [JDK自带工具keytool生成ssl证书](https://www.cnblogs.com/zhangzb/p/5200418.html)
