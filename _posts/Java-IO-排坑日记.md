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

# 3 ZipOutputStream打包相同文件后得到的字节数组不同

因为你压缩文件，实际上是根据原文件，copy出一个新文件然后把这个文件压缩进zip文件中。那么，这个新文件，实际上是有`最后修改时间`的，这个属性肯定是不同的。文件属性的不同，导致你把整个zip文件拉入`MD5`算法计算其散列值的时候，肯定会算出不同的散列值。

```Java
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

__此外，在内存中将一个`byte array`打包成一个`zipped byte array`时，需要调用`ZipOutputStream.finish()`方法，否则得到的是一个不完整的zip文件__

```Java
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

# 4 颜色输出

```Java
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

```Java
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