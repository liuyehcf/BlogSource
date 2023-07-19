---
title: Java-Issue-Logs
date: 2021-09-06 10:58:15
tags: 
- 原创
categories: 
- Java
---

**阅读更多**

<!--more-->

# 1 I/O

## 1.1 PipedInputStream读卡顿

情景还原：需要从一组InputStream中读取数据，数据什么时候到达不可知。针对这个问题，一般会有两种思路，其一，为每一个InputStream开启一个线程来进行blocking-IO操作；其二，用一个扫描线程（Scanner）来检查每个流的数据到达状态（即是否有数据可以读取），若发现某个流有数据可读，便交由异步线程来进行IO操作

经过简化后的源码如下，大致上可以拆分为如下两个部分

1. 一个扫描线程`scanThread`，循环检查`PipedInputStream`是否有数据到达（调用InputStream的非阻塞方法available），若发现有数据，则开启异步流程读取数据
1. 一个线程模拟网络数据到达`networkDataThread`，从控制台输入任意输入并按回车后，将会从pipedOutputStream写入数据

```java
package org.liuyehcf.io.pipe;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.nio.charset.Charset;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class BufferIssue {

    private static final ExecutorService THREAD_POOL = Executors.newCachedThreadPool();

    public static void main(String[] args) throws Exception {
        final int writeSize = 2048;
        final int bufferSize = 1024;
        final PipedInputStream pipedInputStream = new PipedInputStream(bufferSize);
        final PipedOutputStream pipedOutputStream = new PipedOutputStream();
        pipedInputStream.connect(pipedOutputStream);

        // non-blocking scanner
        final Thread scanThread = new Thread(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    try {
                        final int available = pipedInputStream.available();
                        if (available > 0) {
                            // do IO operation in other thread
                            THREAD_POOL.execute(() -> {
                                final byte[] bytes = new byte[available];
                                try {
                                    int actualBytes = pipedInputStream.read(bytes);

                                    System.out.println(new String(bytes, 0, actualBytes, Charset.defaultCharset()));

                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            });
                        }
                    } catch (IOException e) {
                        break;
                    }

                    // sleep for a while
                    TimeUnit.MILLISECONDS.sleep(1);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        scanThread.start();

        final Thread networkDataThread = new Thread(() -> {
            Scanner scanner = new Scanner(System.in);
            while (scanner.next() != null) {
                try {
                    pipedOutputStream.write(getString(writeSize).getBytes());
                    pipedOutputStream.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
        networkDataThread.start();

        scanThread.join();
        networkDataThread.join();
    }

    private static String getString(int length) {
        final StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append("a");
        }
        return sb.toString();
    }
}
```

**当`writeSize>bufferSize`会发现数据打印会有明显卡顿**：由于`PipedInputStream`内部实现会有一个缓存，该缓存大小即`PipedInputStream`一次可以接收的最大数据量。当一次到达的数据大于该缓存大小时，必将造成分批读取

因此，依据数据的规模的大小，适当调整bufferSize的大小，可以解决IO卡顿的问题

## 1.2 PipedInputStream出现`Read end dead`异常

情景还原：一个Scanner线程扫描`PipedInputStream`是否有数据到达，若有数据到达则交由异步IO线程池执行IO读操作

经过简化后的源码如下，大致上可以拆分为如下两个部分

1. 一个扫描线程`scanThread`，循环检查`PipedInputStream`是否有数据到达（调用InputStream的非阻塞方法available），若发现有数据，则开启异步流程读取数据
1. 一个线程模拟网络数据到达`networkDataThread`，从控制台输入任意输入并按回车后，将会从pipedOutputStream写入数据

```java
package org.liuyehcf.io.pipe;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.nio.charset.Charset;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/11/24
 */
public class ReadEndDeadIssue {

    /**
     * 这里讲keepAliveTime设置为1s，即任务执行结束1s之内，没有收到新的任务，那么线程将会结束
     */
    private static final ExecutorService THREAD_POOL = new ThreadPoolExecutor(0, Integer.MAX_VALUE, 1L, TimeUnit.SECONDS, new SynchronousQueue<>());

    public static void main(String[] args) throws Exception {
        final int bufferSize = 1024;
        final PipedInputStream pipedInputStream = new PipedInputStream(bufferSize);
        final PipedOutputStream pipedOutputStream = new PipedOutputStream();
        pipedInputStream.connect(pipedOutputStream);

        // non-blocking scanner
        final Thread scanThread = new Thread(() -> {
            try {
                while (!Thread.currentThread().isInterrupted()) {
                    try {
                        final int available = pipedInputStream.available();
                        if (available > 0) {
                            // do IO operation in other thread
                            THREAD_POOL.execute(() -> {
                                final byte[] bytes = new byte[available];
                                try {
                                    int actualBytes = pipedInputStream.read(bytes);

                                    System.out.println(new String(bytes, 0, actualBytes, Charset.defaultCharset()));

                                } catch (IOException e) {
                                    e.printStackTrace();
                                }
                            });
                        }
                    } catch (IOException e) {
                        break;
                    }

                    // sleep for a while
                    TimeUnit.MILLISECONDS.sleep(1);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
        scanThread.start();

        final Thread networkDataThread = new Thread(() -> {
            Scanner scanner = new Scanner(System.in);
            while (scanner.next() != null) {
                try {
                    pipedOutputStream.write("hello".getBytes());
                    pipedOutputStream.flush();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
        networkDataThread.start();

        scanThread.join();
        networkDataThread.join();
    }
}
```

启动后，在控制台输入任意字符，1s之后，再输入任意字符，即可复现该问题。

解决方案：让每一个`PipedInputStream`执行IO操作的线程是同一个

## 1.3 ZipOutputStream打包相同文件后得到的字节数组不同

因为你压缩文件，实际上是根据原文件，copy出一个新文件然后把这个文件压缩进zip文件中。那么，这个新文件，实际上是有`最后修改时间`的，这个属性肯定是不同的。文件属性的不同，导致你把整个zip文件拉入`MD5`算法计算其散列值的时候，肯定会算出不同的散列值。

```java
try {
            BufferedInputStream bis = new BufferedInputStream(
                    new FileInputStream(file));
            ZipEntry entry = new ZipEntry(basedir + file.getName());
            entry.setTime(file.lastModified());//时间设置为源文件的最后修改时间，避免每次MD5不同
            out.putNextEntry(entry);
            int count;
            byte data[] = new byte[BUFFER];
           // System.out.println("===================压缩流字节====================");
            while ((count = bis.read(data, 0, BUFFER)) != -1) {
                //System.out.println("data "+data.length +":"+ ArrayUtils.toString(data));
                out.write(data, 0, count);
            }
            bis.close();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
```

**此外，在内存中将一个`byte array`打包成一个`zipped byte array`时，需要调用`ZipOutputStream.finish()`方法，否则得到的是一个不完整的zip文件**

```java
public static byte[] packageFiles(ZipEntity... entities) {
        try (ByteArrayOutputStream bos = new ByteArrayOutputStream(); ZipOutputStream zos = new ZipOutputStream(bos)) {

            for (ZipEntity entity : entities) {
                ZipEntry zipEntry = new ZipEntry(entity.getFileName());
                // 将zip包中文件的修改时间改为1970年1月1日，避免修改时间不同而导致整个zip字节序列的差异
                zipEntry.setLastModifiedTime(FileTime.fromMillis(0));
                zos.putNextEntry(zipEntry);
                zos.write(entity.getBytes());
                zos.flush();
                zos.closeEntry();
            }

            // 追加文件尾（当内层OutputStream为ByteArrayOutputStream，这一句是必须的，否则将输出的字节重新写入文件后，得到的是一个不完整的zip文件）
            zos.finish();

            return bos.toByteArray();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static final class ZipEntity {
        private String fileName;

        private byte[] bytes;
    }
```

## 1.4 颜色输出

```java
    public static void main(String[] args) {
        System.out.println("\033[30;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[31;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[32;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[33;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[34;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[35;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[36;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[37;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[40;31;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[41;32;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[42;33;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[43;34;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[44;35;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[45;36;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[46;37;4m" + "我滴个颜什" + "\033[0m");
        System.out.println("\033[47;4m" + "我滴个颜什" + "\033[0m");
    }
```

```java
public static final String ANSI_RESET = "\u001B[0m";
public static final String ANSI_BLACK = "\u001B[30m";
public static final String ANSI_RED = "\u001B[31m";
public static final String ANSI_GREEN = "\u001B[32m";
public static final String ANSI_YELLOW = "\u001B[33m";
public static final String ANSI_BLUE = "\u001B[34m";
public static final String ANSI_PURPLE = "\u001B[35m";
public static final String ANSI_CYAN = "\u001B[36m";
public static final String ANSI_WHITE = "\u001B[37m";

System.out.println(ANSI_RED + "This text is red!" + ANSI_RESET);

public static final String ANSI_BLACK_BACKGROUND = "\u001B[40m";
public static final String ANSI_RED_BACKGROUND = "\u001B[41m";
public static final String ANSI_GREEN_BACKGROUND = "\u001B[42m";
public static final String ANSI_YELLOW_BACKGROUND = "\u001B[43m";
public static final String ANSI_BLUE_BACKGROUND = "\u001B[44m";
public static final String ANSI_PURPLE_BACKGROUND = "\u001B[45m";
public static final String ANSI_CYAN_BACKGROUND = "\u001B[46m";
public static final String ANSI_WHITE_BACKGROUND = "\u001B[47m";

System.out.println(ANSI_GREEN_BACKGROUND + "This text has a green background but default text!" + ANSI_RESET);
System.out.println(ANSI_RED + "This text has red text but a default background!" + ANSI_RESET);
System.out.println(ANSI_GREEN_BACKGROUND + ANSI_RED + "This text has a green background and red text!" + ANSI_RESET);
```

## 1.5 Process死锁问题

下面这段代码会阻塞（如果在你电脑上执行不阻塞的话，可以把循环次数调大）

```sh
    public static void main(String[] args) throws Exception {
        ProcessBuilder command = new ProcessBuilder()
                .command("/bin/sh", "-c", "for ((i=1;i<=10000;i++))\n" +
                        "do \n" +
                        "    echo \"some text\"\n" +
                        "done");

        Process process = command.start();
        process.waitFor();

        System.out.println(process.exitValue());
    }
```

产生这一现象的原因：`start`方法会通过系统调用创建一个子进程用于执行命令行，这个子进程和父进程（java进程）之间通过缓冲区来传递`stdout`、`stderr`、`stdin`，既然有缓冲区，那么必然有一个容量限制，当缓冲区被填满时，那么数据将无法写入，进而造成进程阻塞

1. 父进程（java进程）在`start`后立即调用了`waitFor`，因此并未从缓冲区读取子进程的输入
1. 子进程一直在执行`echo`，该命令会不断向缓冲区写数据
1. 当缓冲区被写满的时候，子进程就被阻塞挂起了
1. 父进程由于等待子进程退出，也被阻塞挂起了，死锁就此产生

**解决方法**

1. 使用`inheritIO`方法，让java进程从缓冲区读取数据
1. 自己异步从缓冲区读取数据

```java
    public static void main(String[] args) throws Exception {
        ProcessBuilder command = new ProcessBuilder()
                .inheritIO()
                .command("/bin/sh", "-c", "for ((i=1;i<=10000;i++))\n" +
                        "do \n" +
                        "    echo \"some text\"\n" +
                        "done");

        Process process = command.start();
        process.waitFor();

        System.out.println(process.exitValue());
    }
```

```java
    public static void main(String[] args) throws Exception {
        ProcessBuilder command = new ProcessBuilder()
                .command("/bin/sh", "-c", "for ((i=1;i<=10000;i++))\n" +
                        "do \n" +
                        "    echo \"some text\"\n" +
                        "done");

        Process process = command.start();

        new Thread(() -> {
            InputStream inputStream = process.getInputStream();
            try {
                int read;
                while ((read = inputStream.read()) != -1) {
                    System.out.print((char) read);
                }
            } catch (Exception e) {
                // ignore
            }
        }).start();

        process.waitFor();

        System.out.println(process.exitValue());
    }
```

## 1.6 参考

* [java 使用Process调用exe程序 及 Process.waitFor() 死锁问题了解和解决](https://www.jianshu.com/p/3d974ce66e51)

# 2 Netty

## 2.1 unsupported message type: TextWebSocketFrame

### 2.1.1 复现问题

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

### 2.1.2 问题分析

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

## 2.2 webSocket连接占用内存过高

表面原因是由于增加了以下两个Handler，这两个handler会用到`JdkZlibDecoder`，而`JdkZlibDecoder`在处理过程中会分配大量内存

* WebSocketClientCompressionHandler.INSTANCE
* WebSocketServerCompressionHandler

## 2.3 OutOfDirectMemoryError

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

## 2.4 LEAK: ByteBuf.release() was not called before it's garbage-collected

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

## 2.5 Sync

在`EventLoop`中调用`write(xxx).sync()`、`writeAndFlush(xxx).sync()`会导致死锁，可能的问题堆栈如下：

```
io.netty.util.concurrent.BlockingOperationException: DefaultChannelPromise@74669c9b(incomplete)
	at io.netty.util.concurrent.DefaultPromise.checkDeadLock(DefaultPromise.java:462)
	at io.netty.channel.DefaultChannelPromise.checkDeadLock(DefaultChannelPromise.java:159)
	at io.netty.util.concurrent.DefaultPromise.await(DefaultPromise.java:247)
	at io.netty.channel.DefaultChannelPromise.await(DefaultChannelPromise.java:131)
	at io.netty.channel.DefaultChannelPromise.await(DefaultChannelPromise.java:30)
	at io.netty.util.concurrent.DefaultPromise.sync(DefaultPromise.java:404)
	at io.netty.channel.DefaultChannelPromise.sync(DefaultChannelPromise.java:119)
	at io.netty.channel.DefaultChannelPromise.sync(DefaultChannelPromise.java:30)
```

正确的做法是，在自定义的线程池中用`sync`逻辑

## 2.6 参考

* [Correctly close EmbeddedChannel and release buffers](https://github.com/netty/netty/pull/9851)

# 3 Spring

## 3.1 注解扫描路径

情景还原：我在某个Service中需要实现一段逻辑，需要使用Pair来存放两个对象，于是我自定义了下面这个静态内部类

```java
@Service
public class MyService{

    //... 业务逻辑代码 ...

    private static final class Pair<K, V> {
        private final K key;
        private final V value;

        public Pair(K key, V value) {
            this.key = key;
            this.value = value;
        }

        public K getKey() {
            return key;
        }

        public V getValue() {
            return value;
        }
    }
}
```

启动时抛出了如下异常

```
2018-01-29 13:43:15.917 [localhost-startStop-1] ERROR o.s.web.servlet.DispatcherServlet - Context initialization failed
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'myService.Pair' defined in URL

...
Instantiation of bean failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found; nested exception is java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()
  at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.instantiateBean
```

注意到没有，关键错误信息是

1. `Error creating bean with name 'myService.Pair'`
1. `Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found`
1. `java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()`

这意味着，Spring为我的静态内部类Pair创建了单例，并且通过反射调用默认构造函数，由于我没有定义无参构造函数，于是报错

**那么，问题来了，我根本就没有配置过这个Pair啊！！！**

纠结了一天之后，发现Spring配置文件中的一段配置，如下

```xml
    <context:component-scan base-package="org.liuyehcf.service">
        <context:include-filter type="regex"
                                expression="org\.liuyehcf\.service\..*"/>
    </context:component-scan>
```

**就是这段配置让所有匹配正则表达式的类都被Spring扫描到，并且为之创建单例！！！**

**DONE**

## 3.2 SpringBoot非Web应用

情景还原

1. SpringBoot应用
1. 非Web应用（即没有`org.springframework.boot:spring-boot-starter-web`依赖项）

启动后出现如下异常信息

```java
Caused by: org.springframework.context.ApplicationContextException: Unable to start EmbeddedWebApplicationContext due to missing EmbeddedServletContainerFactorybean.
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.getEmbeddedServletContainerFactory(EmbeddedWebApplicationContext.java:189)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.createEmbeddedServletContainer(EmbeddedWebApplicationContext.java:162)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.onRefresh(EmbeddedWebApplicationContext.java:134)
  ... 16 more
```

分析：

1. 在普通的Java-Web应用中，Spring容器分为父子容器，其中子容器仅包含MVC层的Bean，父容器包含了其他所有的Bean
1. 出现异常的原因是由于Classpath中包含了`servlet-api`相关class文件，因此Spring boot认为这是一个web application。去掉servlet-api的maven依赖即可

`mvn dependency:tree`查看依赖树，确实发现有servlet-api的依赖项。排除掉servlet有关的依赖项即可

**类似的，还有如下异常（也需要排除掉servlet有关的依赖项）**

```java
Caused by: org.apache.catalina.LifecycleException: A child container failed during start
    at org.apache.catalina.core.ContainerBase.startInternal(ContainerBase.java:949)
    at org.apache.catalina.core.StandardEngine.startInternal(StandardEngine.java:262)
    at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150)
    ... 25 more
```

## 3.3 SpringBoot配置文件

情景还原

1. SpringBoot应用
1. resources/目录下有一个`application.xml`配置文件

出现的异常

```java
Caused by: org.xml.sax.SAXParseException: 文档根元素 "beans" 必须匹配 DOCTYPE 根 "null"
    at com.sun.org.apache.xerces.internal.util.ErrorHandlerWrapper.createSAXParseException(ErrorHandlerWrapper.java:203)
    at com.sun.org.apache.xerces.internal.util.ErrorHandlerWrapper.error(ErrorHandlerWrapper.java:134)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:396)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:327)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:284)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.rootElementSpecified(XMLDTDValidator.java:1599)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.handleStartElement(XMLDTDValidator.java:1877)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.startElement(XMLDTDValidator.java:742)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl.scanStartElement(XMLDocumentFragmentScannerImpl.java:1359)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl$ContentDriver.scanRootElementHook(XMLDocumentScannerImpl.java:1289)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl$FragmentContentDriver.next(XMLDocumentFragmentScannerImpl.java:3132)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl$PrologDriver.next(XMLDocumentScannerImpl.java:852)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl.next(XMLDocumentScannerImpl.java:602)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl.scanDocument(XMLDocumentFragmentScannerImpl.java:505)
    at com.sun.org.apache.xerces.internal.parsers.XML11Configuration.parse(XML11Configuration.java:842)
    at com.sun.org.apache.xerces.internal.parsers.XML11Configuration.parse(XML11Configuration.java:771)
    at com.sun.org.apache.xerces.internal.parsers.XMLParser.parse(XMLParser.java:141)
    at com.sun.org.apache.xerces.internal.parsers.DOMParser.parse(DOMParser.java:243)
    at com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderImpl.parse(DocumentBuilderImpl.java:339)
    at sun.util.xml.PlatformXmlPropertiesProvider.getLoadingDoc(PlatformXmlPropertiesProvider.java:106)
    at sun.util.xml.PlatformXmlPropertiesProvider.load(PlatformXmlPropertiesProvider.java:78)
    ... 25 common frames omitted
```

原因：xml文件名不能是`application.xml`，改个名字就行！我了个大草！

## 3.4 Duplicate spring bean id

情景还原：

1. SpringBoot应用
1. 用Junit做集成测试

Application.java与TestApplication.java以及Test.java如下

1. Application.java：应用的启动类
1. TestApplication.java：测试的启动类
1. Test.java：测试类

```java
@SpringBootApplication(scanBasePackages = {"xxx.yyy.zzz"})
@ImportResource({"classpath*:application-context.xml"})
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

```java
@SpringBootApplication(scanBasePackages = {"com.aliyun.nova.scene"})
@ImportResource({"classpath*:sentinel-tracer.xml","classpath*:application-context.xml"})
public class TestApplication {
}
```

```java
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = {TestApplication.class})
public class Test {
    @Test
    ...
}
```

出现的异常，提示信息是：`Duplicate spring bean id xxx`

原因是配置文件`application-context.xml`被加载了两次，导致bean重复加载了

TestApplication类不应该有`application-context.xml`，否则会加载两次（可能标记了SpringBootApplication注解的类都会被处理，导致了配置文件被加载两次）

# 4 containsKey不符合预期

若`key`发生过变化，且该变化会导致hashCode变化，就会出现这个问题

# 5 `& 0xff`

```java
    public static void main(String[] args) {
        byte b = -1;
        int i1 = (int) b;
        int i2 = b & 0xff;
        System.out.printf("i1=%d%n", i1);
        System.out.printf("i2=%d%n", i2);
    }
```

这段代码的输出如下

```
i1=-1
i2=255
```

对于`byte`而言，`-1`的二进制补码为`11111111`

* 直接转型成`int`类型时，会用符号位填补空缺位置，即`11111111111111111111111111111111`，即值仍为`-1`
* 而用`b & 0xff`，相当于用`0`填补空缺位置，即`00000000000000000000000011111111`，即值为`255`

# 6 NoClassDefFoundError

## 6.1 情景复现

一个类的静态域或者静态块在初始化的过程中，如果抛出异常，那么在类加载的时候将会抛出`java.lang.ExceptionInInitializerError`。**如果用try-catch语句捕获该异常**，那么在使用该类的时候就会抛出`java.lang.NoClassDefFoundError`，且提示信息是`Could not initialize class XXX`

```java
package org.liuyehcf.error;

public class NoClassDefFoundErrorDemo {
    public static void main(String[] args) {
        try {
            Class.forName("org.liuyehcf.error.InitializeThrowError"); //(1)
        } catch (Throwable e) {
            //这里捕获到的是java.lang.ExceptionInInitializerError
            e.printStackTrace();
        }

        System.out.println(InitializeThrowError.i); //(2)

    }
}

class InitializeThrowError {
    public static final int i = initError();

    private static int initError() {
        throw new RuntimeException("Initialize Error");
    }

    public void sayHello() {
        System.out.println("hello, world!");
    }
}
```

在执行代码清单中的`(2)`时，发现JVM调用了如下方法，该方法位于`java.lang.Thread`中

```java
    /**
     * Dispatch an uncaught exception to the handler. This method is
     * intended to be called only by the JVM.
     */
    private void dispatchUncaughtException(Throwable e) {
        getUncaughtExceptionHandler().uncaughtException(this, e);
    }
```

**可以看到，异常是由JVM抛出，并且调用了一个Java实现的handler方法来处理该异常，于是我猜测Java字节码的执行是位于JVM当中的**

对于下面的语句，我**猜测**执行过程如下

1. Java字节码的解释执行**位于JVM空间**
1. 执行语句1，第一次遇到类型A，**隐式触发**类加载过程。这时，用的是当前类加载器（假设是AppClassLoader），于是JVM调用Java代码（`ClassLoader.loadClass(String)`）来执行类加载过程。然后JVM调用Java代码（A的构造方法）创建实例
    * 类加载过程涉及到很多次Java代码与JVM代码交互的过程，可以参考{% post_link Java-类加载原理 %}
1. 执行语句2，再一次遇到类型A，在JVM维护的内部数据结构中，通过类加载器实例（当前类加载器，即AppClassLoader）以及全限定名定位Class实例，发现命中，则不触发加载过程，然后JVM调用Java代码（A的构造方法）创建实例
1. 执行语句3，JVM调用java代码

```java
    A a1 = new A();//(1)
    A a2 = new A();//(2)
    a2.func();//(3)
```

## 6.2 NoClassDefFoundError与ClassNotFoundException

ClassNotFoundException：意味着类加载器找不到某个类，即拿不到代表某个类的.class文件，通常来说，是由于classpath没有引入该类的加载路径

NoClassDefFoundError：意味着JVM之前已经尝试加载某个类，**但是由于某些原因，加载失败了**。后来，我们又用到了这个类，于是抛出了该异常。因此，NoClassDefFoundError并不是classpath的问题。**因此，产生NoClassDefFoundError这个异常有两个条件：加载失败；加载失败抛出的异常被捕获，且后来用使用到了这个类**

## 6.3 参考

* [“NoClassDefFoundError: Could not initialize class” error](https://stackoverflow.com/questions/1401111/noclassdeffounderror-could-not-initialize-class-error)
* [Why am I getting a NoClassDefFoundError in Java?](https://stackoverflow.com/questions/34413/why-am-i-getting-a-noclassdeffounderror-in-java)
