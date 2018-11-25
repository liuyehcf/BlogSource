---
title: Java-IO-排坑日记
date: 2018-11-01 15:31:38
tags: 
- 原创
categories: 
- Java
- IO
---

__阅读更多__

<!--more-->

# 1 PipedInputStream读卡顿

情景还原：需要从一组InputStream中读取数据，数据什么时候到达不可知。针对这个问题，一般会有两种思路，其一，为每一个InputStream开启一个线程来进行blocking-IO操作；其二，用一个扫描线程（Scanner）来检查每个流的数据到达状态（即是否有数据可以读取），若发现某个流有数据可读，便交由异步线程来进行IO操作

经过简化后的源码如下，大致上可以拆分为如下两个部分

1. 一个扫描线程`scanThread`，循环检查`PipedInputStream`是否有数据到达（调用InputStream的非阻塞方法available），若发现有数据，则开启异步流程读取数据
1. 一个线程模拟网络数据到达`networkDataThread`，从控制台输入任意输入并按回车后，将会从pipedOutputStream写入数据

```Java
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

__当`writeSize>bufferSize`会发现数据打印会有明显卡顿__：由于`PipedInputStream`内部实现会有一个缓存，该缓存大小即`PipedInputStream`一次可以接收的最大数据量。当一次到达的数据大于该缓存大小时，必将造成分批读取

因此，依据数据的规模的大小，适当调整bufferSize的大小，可以解决IO卡顿的问题

# 2 PipedInputStream出现`Read end dead`异常

情景还原：一个Scanner线程扫描`PipedInputStream`是否有数据到达，若有数据到达则交由异步IO线程池执行IO读操作

经过简化后的源码如下，大致上可以拆分为如下两个部分

1. 一个扫描线程`scanThread`，循环检查`PipedInputStream`是否有数据到达（调用InputStream的非阻塞方法available），若发现有数据，则开启异步流程读取数据
1. 一个线程模拟网络数据到达`networkDataThread`，从控制台输入任意输入并按回车后，将会从pipedOutputStream写入数据

```Java
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
