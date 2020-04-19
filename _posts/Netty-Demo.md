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

## 1.1 AbstractWebSocketHandler

```java
package org.liuyehcf.netty.ws;

import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.handler.codec.http.websocketx.*;

import java.util.ArrayList;
import java.util.List;

public abstract class AbstractWebSocketHandler extends SimpleChannelInboundHandler<WebSocketFrame> {

    private final List<byte[]> fragmentCache = new ArrayList<>();

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, WebSocketFrame webSocketFrame) {
        byte[] curFragmentBytes;
        if (webSocketFrame instanceof TextWebSocketFrame) {
            TextWebSocketFrame textWebSocketFrame = (TextWebSocketFrame) webSocketFrame;
            curFragmentBytes = textWebSocketFrame.text().getBytes();
        } else if (webSocketFrame instanceof BinaryWebSocketFrame) {
            BinaryWebSocketFrame binaryWebSocketFrame = (BinaryWebSocketFrame) webSocketFrame;
            ByteBuf content = binaryWebSocketFrame.content();
            curFragmentBytes = new byte[content.readableBytes()];
            content.getBytes(0, curFragmentBytes);
        } else if (webSocketFrame instanceof ContinuationWebSocketFrame) {
            ContinuationWebSocketFrame continuationWebSocketFrame = (ContinuationWebSocketFrame) webSocketFrame;
            ByteBuf content = continuationWebSocketFrame.content();
            curFragmentBytes = new byte[content.readableBytes()];
            content.getBytes(0, curFragmentBytes);
        } else if (webSocketFrame instanceof PingWebSocketFrame) {
            return;
        } else if (webSocketFrame instanceof PongWebSocketFrame) {
            return;
        } else if (webSocketFrame instanceof CloseWebSocketFrame) {
            ctx.channel().close();
            return;
        } else {
            throw new UnsupportedOperationException("unsupported WebSocketFrame's type. type='" + webSocketFrame.getClass() + "'");
        }

        byte[] frameBytes;

        if (webSocketFrame.isFinalFragment() && fragmentCache.isEmpty()) {
            frameBytes = curFragmentBytes;
        } else if (webSocketFrame.isFinalFragment()) {
            int allLength = 0;
            for (byte[] bytes : fragmentCache) {
                allLength += bytes.length;
            }
            allLength += curFragmentBytes.length;

            frameBytes = new byte[allLength];
            int startPos = 0;
            for (byte[] fragmentBytes : fragmentCache) {
                System.arraycopy(fragmentBytes, 0, frameBytes, startPos, fragmentBytes.length);
                startPos += fragmentBytes.length;
            }

            System.arraycopy(curFragmentBytes, 0, frameBytes, startPos, curFragmentBytes.length);

            fragmentCache.clear();
        } else {
            fragmentCache.add(curFragmentBytes);
            return;
        }

        doChannelRead0(ctx, frameBytes);
    }

    protected abstract void doChannelRead0(ChannelHandlerContext ctx, byte[] bytes);
}
```

## 1.2 Server

```java
package org.liuyehcf.netty.ws;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.HttpServerCodec;
import io.netty.handler.codec.http.websocketx.BinaryWebSocketFrame;
import io.netty.handler.codec.http.websocketx.WebSocketServerProtocolHandler;
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

    private static final class ServerHandler extends AbstractWebSocketHandler {

        @Override
        protected void doChannelRead0(ChannelHandlerContext ctx, byte[] bytes) {
            System.out.println("server receive message: " + new String(bytes, Charset.defaultCharset()));

            ctx.channel().writeAndFlush(new BinaryWebSocketFrame(Unpooled.wrappedBuffer("Hi, I'm Server".getBytes())));
        }
    }
}
```

## 1.3 Client

```java
package org.liuyehcf.netty.ws;

import io.netty.bootstrap.Bootstrap;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.http.DefaultHttpHeaders;
import io.netty.handler.codec.http.HttpClientCodec;
import io.netty.handler.codec.http.HttpObjectAggregator;
import io.netty.handler.codec.http.websocketx.TextWebSocketFrame;
import io.netty.handler.codec.http.websocketx.WebSocketClientHandshakerFactory;
import io.netty.handler.codec.http.websocketx.WebSocketVersion;
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

    private static final class ClientHandler extends AbstractWebSocketHandler {

        @Override
        protected void doChannelRead0(ChannelHandlerContext ctx, byte[] bytes) {
            System.out.println("client receive message: " + new String(bytes, Charset.defaultCharset()));
        }
    }
}
```

## 1.4 WebSocketClientHandler

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

## 1.5 重点

websocket在握手完毕之后，是会剔除http相关的handler的，具体的细节请参考`WebSocketClientHandshaker.finishHandshake`方法

# 2 Http

HttpRequest转换

```java
import com.alibaba.fastjson.JSON;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.handler.codec.http.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.apache.commons.collections4.MapUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.EntityBuilder;
import org.apache.http.client.methods.HttpRequestBase;
import org.apache.http.client.methods.RequestBuilder;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.message.BasicNameValuePair;

import java.net.URI;
import java.net.URISyntaxException;
import java.nio.charset.Charset;
import java.util.List;
import java.util.Map;

/**
 * @author chenfeng.hcf
 * @date 2019/6/19
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class HttpDelegateRequest implements Payload {

    private static final String ACCEPT_CONTENT_TYPE = "Accept";
    private static final String REQUEST_CONTENT_TYPE = "Content-Type";
    private static final String CONTENT_LENGTH = "Content-Length";

    private String method;
    private String requestContentType;
    private String acceptContentType;

    private String path;
    private Map<String, String> headers = Maps.newHashMap();
    private Map<String, String> queryParams = Maps.newHashMap();
    private Map<String, String> formParams = Maps.newHashMap();
    private byte[] body;

    public static HttpDelegateRequest parse(byte[] bytes) {
        return JSON.parseObject(new String(bytes, Charset.defaultCharset()), HttpDelegateRequest.class);
    }

    public HttpRequestBase toApacheRequest(String schema, String host, int port) {
        RequestBuilder builder = RequestBuilder.create(this.method);

        // HTTP + HOST + PATH + Query Parameter
        try {
            URIBuilder uriBuilder = new URIBuilder();
            uriBuilder.setScheme(schema);
            uriBuilder.setHost(host);
            uriBuilder.setPort(port);
            uriBuilder.setPath(path);
            if (MapUtils.isNotEmpty(this.queryParams)) {
                for (Map.Entry<String, String> entry : this.queryParams.entrySet()) {
                    uriBuilder.addParameter(entry.getKey(), entry.getValue());
                }
            }
            builder.setUri(uriBuilder.build());
        } catch (URISyntaxException e) {
            throw new RuntimeException("build http request uri failed", e);
        }

        EntityBuilder bodyBuilder = EntityBuilder.create();
        bodyBuilder.setContentType(ContentType.parse(requestContentType));
        if (MapUtils.isNotEmpty(this.formParams)) {
            // 如果formParams不为空
            // 将Form中的内容以urlQueryParams的格式存放在body中(k1=v1&k2=v2&k3=v3)
            List<NameValuePair> paramList = Lists.newArrayList();
            for (Map.Entry<String, String> entry : this.formParams.entrySet()) {
                paramList.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
            }
            bodyBuilder.setParameters(paramList);
            builder.setEntity(bodyBuilder.build());
        } else if (ArrayUtils.isNotEmpty(this.body)) {
            bodyBuilder.setBinary(this.body);
            builder.setEntity(bodyBuilder.build());
        }

        for (Map.Entry<String, String> entry : this.headers.entrySet()) {
            builder.addHeader(entry.getKey(), entry.getValue());
        }

        return (HttpRequestBase) builder.build();
    }

    public FullHttpRequest toNettyRequest() {
        URI uri;
        // PATH + Query Parameter
        try {
            URIBuilder uriBuilder = new URIBuilder();
            uriBuilder.setPath(path);
            if (MapUtils.isNotEmpty(this.queryParams)) {
                for (Map.Entry<String, String> entry : this.queryParams.entrySet()) {
                    uriBuilder.addParameter(entry.getKey(), entry.getValue());
                }
            }

            uri = uriBuilder.build();
        } catch (URISyntaxException e) {
            throw new RuntimeException("build http request uri failed", e);
        }

        EntityBuilder bodyBuilder = EntityBuilder.create();
        bodyBuilder.setContentType(ContentType.parse(requestContentType));
        if (MapUtils.isNotEmpty(this.formParams)) {
            // 如果formParams不为空
            // 将Form中的内容以urlQueryParams的格式存放在body中(k1=v1&k2=v2&k3=v3)
            List<NameValuePair> paramList = Lists.newArrayList();
            for (Map.Entry<String, String> entry : this.formParams.entrySet()) {
                paramList.add(new BasicNameValuePair(entry.getKey(), entry.getValue()));
            }
            bodyBuilder.setParameters(paramList);
        } else if (ArrayUtils.isNotEmpty(this.body)) {
            bodyBuilder.setBinary(this.body);
        }

        byte[] bodyBytes = bodyBuilder.getBinary();
        ByteBuf bodyByteBuf;

        if (ArrayUtils.isNotEmpty(bodyBytes)) {
            bodyByteBuf = Unpooled.wrappedBuffer(bodyBytes);
        } else {
            bodyByteBuf = Unpooled.buffer(0);
        }

        DefaultHttpHeaders headers = new DefaultHttpHeaders();

        if (StringUtils.isNotBlank(requestContentType)) {
            headers.add(REQUEST_CONTENT_TYPE, requestContentType);
        }
        if (StringUtils.isNotBlank(acceptContentType)) {
            headers.add(ACCEPT_CONTENT_TYPE, acceptContentType);
        }

        for (Map.Entry<String, String> entry : this.headers.entrySet()) {
            headers.add(entry.getKey(), entry.getValue());
        }

        if (ArrayUtils.isNotEmpty(bodyBytes)) {
            headers.add(CONTENT_LENGTH, bodyBytes.length);
        } else {
            headers.add(CONTENT_LENGTH, 0);
        }

        return new DefaultFullHttpRequest(HttpVersion.HTTP_1_1, HttpMethod.valueOf(method), uri.toASCIIString(),
                bodyByteBuf, headers, new DefaultHttpHeaders(true));
    }

    @Override
    public String toAbstractInfo() {
        Map<String, String> map = Maps.newHashMap();
        map.put("method", method);
        map.put("path", path);

        return JSON.toJSONString(map);
    }
}
```

HttpReponse转换

```java
import com.google.common.collect.Maps;
import io.netty.buffer.ByteBuf;
import io.netty.handler.codec.http.FullHttpResponse;
import lombok.Data;
import org.apache.commons.lang3.StringUtils;
import org.apache.http.Header;
import org.apache.http.HttpResponse;
import org.apache.http.util.EntityUtils;

import java.io.IOException;
import java.util.Map;

/**
 * @author chenfeng.hcf
 * @date 2019/6/19
 */
@Data
public class HttpDelegateResponse {

    private static final String CONTENT_TYPE = "Content-Type";

    private int statusCode;
    private String contentType;
    private String message;
    private Map<String, String> headers = Maps.newHashMap();
    private byte[] body;

    public static HttpDelegateResponse fromApacheResponse(HttpResponse httpResponse) {
        try {
            HttpDelegateResponse result = new HttpDelegateResponse();

            // status code
            if (httpResponse.getStatusLine() != null) {
                result.setStatusCode(httpResponse.getStatusLine().getStatusCode());
            }

            if (httpResponse.getEntity() != null) {
                // content type
                Header contentType = httpResponse.getEntity().getContentType();
                if (contentType != null) {
                    result.setContentType(contentType.getValue());
                }

                // body
                result.setBody(EntityUtils.toByteArray(httpResponse.getEntity()));
            } else {
                if (httpResponse.getAllHeaders() != null) {
                    for (Header header : httpResponse.getAllHeaders()) {
                        if (StringUtils.equalsIgnoreCase(CONTENT_TYPE, header.getName())) {
                            result.setContentType(header.getValue());
                            break;
                        }
                    }
                }
            }

            // headers
            result.setHeaders(Maps.newHashMap());
            for (Header header : httpResponse.getAllHeaders()) {
                result.getHeaders().put(header.getName(), header.getValue());
            }

            // message
            if (httpResponse.getStatusLine() != null) {
                result.setMessage(httpResponse.getStatusLine().getReasonPhrase());
            }

            return result;
        } catch (IOException e) {
            throw new RuntimeException("convert http response failed", e);
        }
    }

    public static HttpDelegateResponse fromNettyResponse(FullHttpResponse fullHttpResponse) {
        HttpDelegateResponse result = new HttpDelegateResponse();

        // status code
        if (fullHttpResponse.status() != null) {
            result.setStatusCode(fullHttpResponse.status().code());
        }

        // body
        ByteBuf content = fullHttpResponse.content();
        if (content != null) {
            byte[] bytes = new byte[content.readableBytes()];
            content.readBytes(bytes);
            result.setBody(bytes);
        }

        // content type
        if (fullHttpResponse.headers() != null) {
            for (Map.Entry<String, String> header : fullHttpResponse.headers()) {
                if (StringUtils.equalsIgnoreCase(CONTENT_TYPE, header.getKey())) {
                    result.setContentType(header.getValue());
                    break;
                }
            }
        }

        // headers
        result.setHeaders(Maps.newHashMap());
        for (Map.Entry<String, String> header : fullHttpResponse.headers()) {
            result.getHeaders().put(header.getKey(), header.getValue());
        }

        // message
        if (fullHttpResponse.status() != null) {
            result.setMessage(fullHttpResponse.status().reasonPhrase());
        }

        return result;
    }
}
```

# 3 Converter

## 3.1 Http Converter

有时候，在项目中可能会有这样的需求，我们接收一个`Message`，然后需要将其转换成字节流再进行处理。例如，我们在接收到`FullHttpRequest`后，想要将其转成字节流然后再进行处理。netty中的`EmbeddedChannel`可以完成这样的功能，示例代码如下（__注意，当http的body比较大的时候，有可能需要读取多次，因此下面的代码用while循环读取，直到读取完所有的数据__）

```java
package org.liuyehcf.netty;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.ByteBufHolder;
import io.netty.buffer.Unpooled;
import io.netty.channel.embedded.EmbeddedChannel;
import io.netty.handler.codec.http.FullHttpRequest;
import io.netty.handler.codec.http.FullHttpResponse;
import io.netty.handler.codec.http.HttpRequestEncoder;
import io.netty.handler.codec.http.HttpResponseEncoder;
import io.netty.util.ReferenceCountUtil;

/**
 * @author chenfeng.hcf
 * @date 2019/7/23
 */
public abstract class HttpConverter {

    public static byte[] convertRequest2Bytes(FullHttpRequest msg, boolean needRetain) {
        EmbeddedChannel ch = new EmbeddedChannel(new HttpRequestEncoder());
        return convert2Bytes(ch, msg, needRetain);
    }

    public static byte[] convertResponse2Bytes(FullHttpResponse msg, boolean needRetain) {
        EmbeddedChannel ch = new EmbeddedChannel(new HttpResponseEncoder());
        return convert2Bytes(ch, msg, needRetain);
    }

    private static byte[] convert2Bytes(EmbeddedChannel ch, ByteBufHolder msg, boolean needRetain) {
        ByteBuf byteBuf;
        ByteBuf cache = Unpooled.buffer();
        try {
            if (needRetain) {
                ch.writeOutbound(msg.retain());
            } else {
                ch.writeOutbound(msg);
            }

            while ((byteBuf = ch.readOutbound()) != null) {
                try {
                    cache.writeBytes(byteBuf);
                } finally {
                    ReferenceCountUtil.release(byteBuf);
                }
            }

            byte[] totalBytes = new byte[cache.readableBytes()];
            cache.readBytes(totalBytes);

            return totalBytes;
        } finally {
            ReferenceCountUtil.release(cache);
            ch.close();
        }
    }
}
```

## 3.2 SSL Converter

### 3.2.1 AbstractSslConverter

```java
package org.liuyehcf.netty.ssl;

import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.embedded.EmbeddedChannel;
import io.netty.util.ReferenceCountUtil;

public abstract class AbstractSslConverter {

    protected final EmbeddedChannel channel;

    protected AbstractSslConverter(EmbeddedChannel channel) {
        this.channel = channel;
    }

    public void writeOutbound(byte[] bytes, InboundConsumer inboundConsumer, OutboundConsumer outboundConsumer) {
        channel.writeOutbound(Unpooled.wrappedBuffer(bytes));
        channel.flushOutbound();

        if (inboundConsumer != null) {
            byte[] inboundData = readInbound();
            if (inboundData != null) {
                inboundConsumer.consumeInbound(inboundData);
            }
        }

        if (outboundConsumer != null) {
            byte[] outboundData = readOutbound();
            if (outboundData != null) {
                outboundConsumer.consumeOutbound(outboundData);
            }
        }
    }

    public void writeInbound(byte[] bytes, InboundConsumer inboundConsumer, OutboundConsumer outboundConsumer) {
        channel.writeInbound(Unpooled.wrappedBuffer(bytes));
        channel.flushInbound();

        if (inboundConsumer != null) {
            byte[] inboundData = readInbound();
            if (inboundData != null) {
                inboundConsumer.consumeInbound(inboundData);
            }
        }

        if (outboundConsumer != null) {
            byte[] outboundData = readOutbound();
            if (outboundData != null) {
                outboundConsumer.consumeOutbound(outboundData);
            }
        }
    }

    public byte[] readInbound() {
        ByteBuf byteBuf;
        ByteBuf cache = Unpooled.buffer();
        try {
            while ((byteBuf = channel.readInbound()) != null) {
                try {
                    cache.writeBytes(byteBuf);
                } finally {
                    ReferenceCountUtil.release(byteBuf);
                }
            }

            int readableBytes = cache.readableBytes();
            if (readableBytes == 0) {
                return null;
            }

            byte[] totalBytes = new byte[readableBytes];
            cache.readBytes(totalBytes);

            return totalBytes;
        } finally {
            ReferenceCountUtil.release(cache);
        }
    }

    public byte[] readOutbound() {
        ByteBuf byteBuf;
        ByteBuf cache = Unpooled.buffer();
        try {
            while ((byteBuf = channel.readOutbound()) != null) {
                try {
                    cache.writeBytes(byteBuf);
                } finally {
                    ReferenceCountUtil.release(byteBuf);
                }
            }

            int readableBytes = cache.readableBytes();
            if (readableBytes == 0) {
                return null;
            }

            byte[] totalBytes = new byte[readableBytes];
            cache.readBytes(totalBytes);

            return totalBytes;
        } finally {
            ReferenceCountUtil.release(cache);
        }
    }

    public void close() {
        channel.close();
    }

    @FunctionalInterface
    public interface InboundConsumer {

        /**
         * consume bytes
         *
         * @param bytes data
         */
        void consumeInbound(byte[] bytes);
    }

    @FunctionalInterface
    public interface OutboundConsumer {

        /**
         * consume bytes
         *
         * @param bytes data
         */
        void consumeOutbound(byte[] bytes);
    }
}
```

### 3.2.2 SslClientConverter

```java
package org.liuyehcf.netty.ssl;

import io.netty.channel.embedded.EmbeddedChannel;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.ssl.util.InsecureTrustManagerFactory;

import javax.net.ssl.SSLException;

/**
 * @author hechenfeng
 * @date 2019/8/29
 */
public class SslClientConverter extends AbstractSslConverter {

    private static final SslContext SSL_CONTEXT;

    static {
        try {
            SSL_CONTEXT = SslContextBuilder.forClient()
                    .trustManager(InsecureTrustManagerFactory.INSTANCE)
                    .build();
        } catch (SSLException e) {
            throw new Error();
        }
    }

    private SslClientConverter(EmbeddedChannel channel) {
        super(channel);
    }

    public static SslClientConverter create() {
        EmbeddedChannel channel = new EmbeddedChannel();
        channel.pipeline().addLast(SSL_CONTEXT.newHandler(channel.alloc()));
        return new SslClientConverter(channel);
    }
}
```

### 3.2.3 SslServerConverter

其中`KeyStore`的创建指令如下

```sh
keytool -genkey -v -alias liuyehcf_server_key -keyalg RSA -keystore ~/liuyehcf_server_ks -storetype PKCS12 -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 123456
```

```java
package org.liuyehcf.netty.ssl;

import io.netty.channel.embedded.EmbeddedChannel;
import io.netty.handler.ssl.SslContext;
import io.netty.handler.ssl.SslContextBuilder;

import javax.net.ssl.KeyManagerFactory;
import java.io.InputStream;
import java.security.KeyStore;

/**
 * @author hechenfeng
 * @date 2019/8/29
 */
public class SslServerConverter extends AbstractSslConverter {

    private static final SslContext SSL_CONTEXT;

    private static final String STORE_TYPE = "PKCS12";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    private static final KeyManagerFactory KEY_MANAGER_FACTORY;

    static {
        try {
            KEY_MANAGER_FACTORY = initKeyManagerFactory();

            SSL_CONTEXT = SslContextBuilder.forServer(KEY_MANAGER_FACTORY).build();
        } catch (Exception e) {
            throw new Error();
        }
    }

    private SslServerConverter(EmbeddedChannel channel) {
        super(channel);
    }

    private static KeyManagerFactory initKeyManagerFactory() throws Exception {
        InputStream keyStoreStream = ClassLoader.getSystemClassLoader().getResourceAsStream("liuyehcf_server_ks");

        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(keyStoreStream, KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        return keyManagerFactory;
    }

    public static SslServerConverter create() {
        EmbeddedChannel channel = new EmbeddedChannel();
        channel.pipeline().addLast(SSL_CONTEXT.newHandler(channel.alloc()));
        return new SslServerConverter(channel);
    }
}
```

### 3.2.4 SslNonSocketDemo

```java
package org.liuyehcf.netty.ssl;

import java.util.concurrent.*;

/**
 * @author hechenfeng
 * @date 2019/8/29
 */
@SuppressWarnings("all")
public class SslNonSocketDemo {

    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(3);

    public static void main(String[] args) throws Exception {
        BlockingQueue<byte[]> clientToServerPipe = new ArrayBlockingQueue<>(1024);
        BlockingQueue<byte[]> serverToClientPipe = new ArrayBlockingQueue<>(1024);
        BlockingQueue<byte[]> serverReceiveSignal = new SynchronousQueue<>();

        SslClientConverter client = SslClientConverter.create();
        SslServerConverter server = SslServerConverter.create();

        byte[] greetFromClientToServer = "Hello, I'm client!".getBytes();
        byte[] greetFromServerToClient = "Hello, I'm server!".getBytes();

        AbstractSslConverter.InboundConsumer clientInboundConsumer = (inboundBytes) -> {
            System.out.println("receive message from server: " + new String(inboundBytes));
        };
        AbstractSslConverter.OutboundConsumer clientOutboundConsumer = (outboundBytes) -> {
            try {
                clientToServerPipe.put(outboundBytes);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        };

        client.writeOutbound(greetFromClientToServer, clientInboundConsumer, clientOutboundConsumer);

        // 模拟IO事件，client端接受来自服务端的数据
        EXECUTOR.execute(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    byte[] bytes = serverToClientPipe.take();

                    client.writeInbound(bytes, clientInboundConsumer, clientOutboundConsumer);
                }
            } catch (InterruptedException e) {
                System.out.println("client pipe loop finished");
            }
        });

        AbstractSslConverter.InboundConsumer serverInboundConsumer = (inboundBytes) -> {
            System.out.println("receive message from client: " + new String(inboundBytes));
            try {
                serverReceiveSignal.put(greetFromServerToClient);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        };
        AbstractSslConverter.OutboundConsumer serverOutboundConsumer = (outboundBytes) -> {
            try {
                serverToClientPipe.put(outboundBytes);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        };

        // 模拟IO事件，server端接受来自client端的数据
        EXECUTOR.execute(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    byte[] bytes = clientToServerPipe.take();

                    server.writeInbound(bytes, serverInboundConsumer, serverOutboundConsumer);
                }
            } catch (InterruptedException e) {
                System.out.println("server pipe loop finished");
            }
        });

        // 当server端接收到client的消息后，回复客户端
        EXECUTOR.execute(() -> {
            try {
                byte[] bytes = serverReceiveSignal.take();
                server.writeOutbound(bytes, serverInboundConsumer, serverOutboundConsumer);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });

        TimeUnit.SECONDS.sleep(1);

        System.out.println("finished");
        EXECUTOR.shutdownNow();
    }
}
```

# 4 参考

* [Java SSL 证书细节](https://www.jianshu.com/p/5fcc6a219c8b)
* [JDK自带工具keytool生成ssl证书](https://www.cnblogs.com/zhangzb/p/5200418.html)
* [netty-example](https://github.com/spmallette/netty-example/blob/master/src/test/java/com/genoprime/netty/example/WebSocketClientHandler.java)
* [单机千万并发连接实战](https://zhuanlan.zhihu.com/p/21378825)
