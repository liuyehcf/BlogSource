---
title: Apache-Mina-Demo
date: 2019-01-03 18:59:56
tags: 
- 原创
categories: 
- Java
- Framework
- Mina
---

__阅读更多__

<!--more-->

# 1 Maven依赖

```xml
        <!-- mina -->
        <dependency>
            <groupId>org.apache.sshd</groupId>
            <artifactId>sshd-core</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.sshd</groupId>
            <artifactId>sshd-sftp</artifactId>
            <version>2.1.0</version>
        </dependency>

        <!-- jsch -->
        <dependency>
            <groupId>com.jcraft</groupId>
            <artifactId>jsch</artifactId>
            <version>0.1.55</version>
        </dependency>

        <!-- java native hook -->
        <dependency>
            <groupId>com.1stleg</groupId>
            <artifactId>jnativehook</artifactId>
            <version>2.1.0</version>
        </dependency>
```

__其中__

1. `jsch`是另一个`ssh-client`库
1. `jnativehook`用于捕获键盘的输入，如果仅用Java标准输入，则无法捕获类似`ctrl + c`这样的按键组合

# 2 Demo

## 2.1 BaseDemo

```Java
package org.liuyehcf.mina;

import org.jnativehook.GlobalScreen;
import org.jnativehook.keyboard.NativeKeyEvent;
import org.jnativehook.keyboard.NativeKeyListener;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.nio.charset.Charset;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
class BaseDemo {

    private static final ExecutorService EXECUTOR = Executors.newCachedThreadPool();

    private static final int PIPE_STREAM_BUFFER_SIZE = 1024 * 100;
    final PipedInputStream sshClientInputStream = new PipedInputStream(PIPE_STREAM_BUFFER_SIZE);
    final PipedOutputStream sshClientOutputStream = new PipedOutputStream();
    private final PipedInputStream bizInputStream = new PipedInputStream(PIPE_STREAM_BUFFER_SIZE);
    private final PipedOutputStream bizOutputStream = new PipedOutputStream();

    BaseDemo() throws IOException {
        sshClientInputStream.connect(bizOutputStream);
        sshClientOutputStream.connect(bizInputStream);
    }

    void beginRead() {
        EXECUTOR.execute(() -> {
            final byte[] buffer = new byte[10240];
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    int readNum = bizInputStream.read(buffer);

                    final byte[] actualBytes = new byte[readNum];
                    System.arraycopy(buffer, 0, actualBytes, 0, readNum);

                    println(new String(actualBytes, Charset.defaultCharset()));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    void beginWriteJnativehook() {
        EXECUTOR.execute(() -> {
            try {
                Logger logger = Logger.getLogger(GlobalScreen.class.getPackage().getName());
                logger.setLevel(Level.OFF);
                GlobalScreen.registerNativeHook();
                GlobalScreen.addNativeKeyListener(new NativeKeyListener() {
                    @Override
                    public void nativeKeyTyped(NativeKeyEvent nativeKeyEvent) {
                        byte keyCode = (byte) nativeKeyEvent.getKeyChar();

                        try {
                            bizOutputStream.write(keyCode);
                            bizOutputStream.flush();
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void nativeKeyPressed(NativeKeyEvent nativeKeyEvent) {
                        // default
                    }

                    @Override
                    public void nativeKeyReleased(NativeKeyEvent nativeKeyEvent) {
                        // default
                    }
                });
            } catch (Throwable e) {
                e.printStackTrace();
            }
        });
    }

    void beginWriteStd() {
        EXECUTOR.execute(() -> {
            try {
                final Scanner scanner = new Scanner(System.in);
                while (!Thread.currentThread().isInterrupted()) {
                    final String command = scanner.nextLine();

                    bizOutputStream.write((command + "\n").getBytes());
                    bizOutputStream.flush();
                }
            } catch (Throwable e) {
                e.printStackTrace();
            }
        });
    }

    private void println(Object obj) {
        synchronized (System.out) {
            System.out.println(obj);
            System.out.flush();
        }
    }
}
```

## 2.2 MinaSshDemo

```Java
package org.liuyehcf.mina;

import org.apache.sshd.client.SshClient;
import org.apache.sshd.client.channel.ChannelShell;
import org.apache.sshd.client.channel.ClientChannelEvent;
import org.apache.sshd.client.future.ConnectFuture;
import org.apache.sshd.client.session.ClientSession;
import org.apache.sshd.common.util.io.NoCloseInputStream;
import org.apache.sshd.common.util.io.NoCloseOutputStream;

import java.io.IOException;
import java.util.Collections;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
public class MinaSshDemo extends BaseDemo {

    private MinaSshDemo() throws IOException {

    }

    public static void main(String[] args) throws Exception {
        new MinaSshDemo().boot();
    }

    private void boot() throws Exception {
        final SshClient client = SshClient.setUpDefaultClient();
        client.start();
        final ConnectFuture connect = client.connect("HCF", "localhost", 22);
        connect.await(5000L);
        final ClientSession session = connect.getSession();
        session.addPasswordIdentity("???");
        session.auth().verify(5000L);

        final ChannelShell channel = session.createShellChannel();
        channel.setIn(new NoCloseInputStream(sshClientInputStream));
        channel.setOut(new NoCloseOutputStream(sshClientOutputStream));
        channel.setErr(new NoCloseOutputStream(sshClientOutputStream));
        channel.open();

        beginRead();
//        beginWriteJnativehook();
        beginWriteStd();

        channel.waitFor(Collections.singleton(ClientChannelEvent.CLOSED), 0);
    }
}
```

## 2.3 JschSshDemo

```Java
package org.liuyehcf.mina;

import com.jcraft.jsch.ChannelShell;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
public class JschSshDemo extends BaseDemo {

    private JschSshDemo() throws IOException {

    }

    public static void main(final String[] args) throws Exception {
        new JschSshDemo().boot();
    }

    private void boot() throws Exception {
        JSch jsch = new JSch();

        Session session = jsch.getSession("HCF", "localhost", 22);
        java.util.Properties config = new java.util.Properties();
        config.put("StrictHostKeyChecking", "no");
        session.setConfig(config);
        session.setPassword("???");
        session.connect();

        ChannelShell channel = (ChannelShell) session.openChannel("shell");
        channel.setInputStream(sshClientInputStream);
        channel.setOutputStream(sshClientOutputStream);
        channel.connect();

        beginRead();
        beginWriteJnativehook();
//        beginWriteStd();

        TimeUnit.SECONDS.sleep(1000000);
    }
}
```

# 3 修改IdleTimeOut

```Java
        Class<FactoryManager> factoryManagerClass = FactoryManager.class;

        Field field = factoryManagerClass.getField("DEFAULT_IDLE_TIMEOUT");
        Field modifiersField = Field.class.getDeclaredField("modifiers");
        modifiersField.setAccessible(true);
        modifiersField.setInt(field, field.getModifiers() & ~Modifier.FINAL);

        field.setAccessible(true);

        field.set(null, TimeUnit.SECONDS.toMillis(config.getIdleIntervalFrontend()));
```

# 4 修复显示异常的问题

```sh
stty cols 190 && stty rows 21 && export TERM=xterm-256color && bash
```

# 5 参考

* [mina-sshd](https://github.com/apache/mina-sshd)
* [jnativehook](https://github.com/kwhat/jnativehook)
* [Java 反射修改 final 属性值](https://blog.csdn.net/tabactivity/article/details/50726353)
