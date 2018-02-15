---
title: HTTP请求的原生实现
date: 2018-01-12 21:23:48
tags: 
- 原创
categories: 
- Java
- Framework
- HTTP
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

HTTP协议本质上是__文本协议__，其内容表示形式为__人类可读格式__。通常就是ASCII码或者UTF-8编码所得

在Java中，HTTP客户端种类繁多，包括HttpURLConnection、Netty、OkHttp等等

__本篇博客旨在使用原生的Java IO API来实现一个简单的HttpClient，借此体验一下HTTP协议的运作方式__

# 2 HTTP请求概述

一个HTTP请求大致上可以拆分成如下几个步骤

1. 建立TCP连接
1. 组装HTTP Request，其本质上就是一段String
1. 通过TCP连接，将HTTP Request发送过去

# 3 Raw-HTTP-Demo

## 3.1 HttpRequestBuilder

首先构建一个Builder模式的辅助类，用于创建一个HttpRequest，包含如下几个关键字段。最后创建出来的就是一个String

1. `headers`：请求头
1. `method`：请求方法，GET/POST/DELETE/PUT等
1. `url`：URL
1. `version`：HTTP协议版本
1. `body`：请求包体

```Java
package org.liuyehcf.http.raw;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by HCF on 2017/12/16.
 */
public class HttpRequestBuilder {

    private static final String SPACE = " ";
    private static final String ENTER = "\r";
    private static final String LINE_FEED = "\n";
    private static final String CONTENT_LENGTH = "content-length";
    private static final String COLON = ":";

    private Map<String, String> headers;
    private String method;
    private String url;
    private String version;
    private String body;

    public static HttpRequestBuilder builder() {
        return new HttpRequestBuilder();
    }

    /**
     * 构造方法，填充默认值
     */
    private HttpRequestBuilder() {
        headers = new HashMap<>();
        method = "GET";
        url = null;
        version = "HTTP/1.1";
        body = null;
    }

    public HttpRequestBuilder method(String method) {
        this.method = method;
        return this;
    }

    public HttpRequestBuilder url(String url) {
        this.url = url;
        return this;
    }

    public HttpRequestBuilder version(String version) {
        this.version = version;
        return this;
    }

    public HttpRequestBuilder addHeader(String key, String value) {
        headers.put(key.toLowerCase(), value.toLowerCase());
        return this;
    }

    public HttpRequestBuilder body(String body) {
        this.body = body;
        addHeader(CONTENT_LENGTH, Integer.toString(body.getBytes().length));
        return this;
    }

    public String build() {
        check();

        return method + SPACE + url + SPACE + version + ENTER + LINE_FEED
                + headers()
                + LINE_FEED
                + (body == null ? "" : body);
    }

    private void check() {
        if (url == null) {
            throw new RuntimeException("url尚未初始化");
        }

        if (body != null) {
            int bodyLength = body.getBytes().length;
            if (!headers.containsKey(CONTENT_LENGTH)) {
                throw new RuntimeException("设置了请求Body，单位设置长度参数<content-length>");
            }

            String key = headers.get(CONTENT_LENGTH);

            if (Integer.parseInt(key) != bodyLength) {
                throw new RuntimeException("Body长度参数<content-length>设置错误");
            }
        } else {
            String key;
            if (headers.containsKey(CONTENT_LENGTH)
                    && (key = headers.get(CONTENT_LENGTH)) != null
                    && Integer.parseInt(key) != 0) {
                throw new RuntimeException("Body为空，但是Body长度参数<content-length>不为0");
            }
        }
    }

    private String headers() {
        StringBuilder sb = new StringBuilder();
        for (Map.Entry<String, String> header : headers.entrySet()) {
            sb.append(header.getKey())
                    .append(COLON)
                    .append(header.getValue())
                    .append(ENTER)
                    .append(LINE_FEED);
        }
        return sb.toString();
    }
}
```

## 3.2 Server

用于本地测试的服务端代码详见{% post_link Spring-Boot-Demo %}，这里不再赘述

## 3.3 Test

下面写了一个测试上述三个API的测试用例，由于Java Socket相关的操作可以固化，因此利用模板方法模式，提供了一个模板类RawHttpRequestTemplate，三个API的测试用例分别对应于HomeHttpRequest、ComputeHttpRequest、LoginHttpRequest

```Java
package org.liuyehcf.http.raw.nioapi;

import org.liuyehcf.http.raw.HttpRequestBuilder;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by HCF on 2017/12/16.
 */
public class RowJavaNioApiDemo {

    private static byte[] toByteArray(List<Byte> bytes) {
        byte[] byteArray = new byte[bytes.size()];

        for (int i = 0; i < bytes.size(); i++) {
            byteArray[i] = bytes.get(i);
        }
        return byteArray;
    }

    public static void main(String[] args) {
        new HomeHttpRequest().doRequest();

        new LoginHttpRequest("张三").doRequest();

        new ComputeHttpRequest("1.2", "2.4", "+").doRequest();
    }

    private static abstract class RawHttpRequestTemplate {
        final public void doRequest() {
            try {
                SocketChannel socketChannel = SocketChannel.open();

                // 启动一个本地的Web应用作为服务端
                socketChannel.connect(new InetSocketAddress("localhost", 8080));

                String requestContent = buildRequest();
                printRequest(requestContent);

                ByteBuffer requestByteBuffer = ByteBuffer.wrap(requestContent.getBytes());
                socketChannel.write(requestByteBuffer);

                ByteBuffer responseByteBuffer = ByteBuffer.allocate(16);
                List<Byte> bytes = new ArrayList<>();

                while ((socketChannel.read(responseByteBuffer)) != -1) {
                    responseByteBuffer.flip();

                    while (responseByteBuffer.hasRemaining()) {
                        bytes.add(responseByteBuffer.get());
                    }

                    responseByteBuffer.clear();
                }

                printResponse(new String(toByteArray(bytes)));

                System.out.println("-------------------------------------------");

            } catch (IOException e) {
                e.printStackTrace(System.out);
            }
        }

        protected abstract String buildRequest();

        private void printRequest(String request) {
            System.out.println("HTTP REQUEST:");
            System.out.println("[");
            System.out.println(request);
            System.out.println("]");
        }

        private void printResponse(String response) {
            System.out.println(",");
            System.out.println("HTTP RESPONSE:");
            System.out.println("[");
            System.out.println(response);
            System.out.println("]");
        }
    }

    private static final class HomeHttpRequest extends RawHttpRequestTemplate {
        @Override
        protected String buildRequest() {
            return HttpRequestBuilder.builder()
                    .method("GET")
                    .url("http:// 127.0.0.1:8080/home")
                    .addHeader("Host", "8080")
                    .addHeader("Connection", "close")  // 避免read阻塞
                    .build();
        }
    }

    private static final class ComputeHttpRequest extends RawHttpRequestTemplate {
        private String value1;

        private String value2;

        private String operator;

        public ComputeHttpRequest(String value1, String value2, String operator) {
            this.value1 = value1;
            this.value2 = value2;
            this.operator = operator;
        }

        @Override
        protected String buildRequest() {
            return HttpRequestBuilder.builder()
                    .method("GET")
                    .url("http:// 127.0.0.1:8080/compute?value1=" + value1 + "&value2=" + value2)
                    .addHeader("Host", "8080")
                    .addHeader("Connection", "close")  // 避免read阻塞
                    .addHeader("operator", operator)
                    .build();
        }
    }

    private static final class LoginHttpRequest extends RawHttpRequestTemplate {
        private String name;

        public LoginHttpRequest(String name) {
            this.name = name;
        }

        @Override
        protected String buildRequest() {
            return HttpRequestBuilder.builder()
                    .method("POST")
                    .url("http:// 127.0.0.1:8080/login")
                    .addHeader("Host", "8080")
                    .addHeader("Connection", "close")  // 避免read阻塞
                    .addHeader("Content-Type", "application/json")
                    .body("{\"name\":\"" + this.name + "\"}") // JSON格式的请求包体
                    .build();
        }
    }
}
```

输出

```
HTTP REQUEST:
[
GET http:// 127.0.0.1:8080/home HTTP/1.1
host:8080
connection:close

]
,
HTTP RESPONSE:
[
HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 12
Date: Wed, 14 Feb 2018 15:17:43 GMT
Connection: close

Hello world!
]
-------------------------------------------
HTTP REQUEST:
[
POST http:// 127.0.0.1:8080/login HTTP/1.1
content-length:17
host:8080
connection:close
content-type:application/json

{"name":"张三"}
]
,
HTTP RESPONSE:
[
HTTP/1.1 200 
Content-Type: application/json;charset=UTF-8
Transfer-Encoding: chunked
Date: Wed, 14 Feb 2018 15:17:43 GMT
Connection: close

2d
{"state":"OK","message":"欢迎登陆张三"}
0

]
-------------------------------------------
HTTP REQUEST:
[
GET http:// 127.0.0.1:8080/compute?value1=1.2&value2=2.4 HTTP/1.1
host:8080
connection:close
operator:+

]
,
HTTP RESPONSE:
[
HTTP/1.1 200 
Content-Type: text/plain;charset=UTF-8
Content-Length: 9
Date: Wed, 14 Feb 2018 15:17:43 GMT
Connection: close

3.6000001
]
-------------------------------------------

```

# 4 参考

* [http协议客户端向服务器端请求时一般需要发送的内容](https://yq.aliyun.com/articles/35425)
* [Netty4使用http体验](https://www.jianshu.com/p/11814875d793)
* [binary protocols v. text protocols](https://stackoverflow.com/questions/2645009/binary-protocols-v-text-protocols)
* [Text-based protocol](https://en.wikipedia.org/wiki/Text-based_protocol)
