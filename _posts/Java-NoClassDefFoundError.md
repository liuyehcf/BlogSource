---
title: Java-NoClassDefFoundError
date: 2018-01-21 00:27:06
tags: 
- 原创
categories: 
- Java
- Exception
---

__目录__

<!-- toc -->
<!--more-->

# 1 情景复现

一个类的静态域或者静态块在初始化的过程中，如果抛出异常，那么在类加载的时候将会抛出`java.lang.ExceptionInInitializerError`。__如果用try-catch语句捕获该异常__，那么在使用该类的时候就会抛出`java.lang.NoClassDefFoundError`，且提示信息是`Could not initialize class XXX`

```Java
package org.liuyehcf.error;

public class NoClassDefFoundErrorDemo {
    public static void main(String[] args) {
        try {
            Class.forName("org.liuyehcf.error.InitializeThrowError");
        } catch (Throwable e) {
            // 这里捕获到的是java.lang.ExceptionInInitializerError
            e.printStackTrace();
        }

        try {
            InitializeThrowError.INSTANCE.sayHello();
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }
}

class InitializeThrowError {
    public static final InitializeThrowError INSTANCE = new InitializeThrowError();

    public InitializeThrowError() {
        throw new RuntimeException();
    }

    public void sayHello() {
        System.out.println("hello, world!");
    }
}

```

# 2 NoClassDefFoundError与ClassNotFoundException

ClassNotFoundException：意味着类加载器找不到某个类，即拿不到代表某个类的.class文件，通常来说，是由于classpath没有引入该类的加载路径

NoClassDefFoundError：意味着JVM之前已经尝试加载某个类，__但是由于某些原因，加载失败了__。后来，我们又用到了这个类，于是抛出了该异常。因此，NoClassDefFoundError并不是classpath的问题。__因此，产生NoClassDefFoundError这个异常有两个条件：加载失败；加载失败抛出的异常被捕获，且后来用使用到了这个类__

# 3 参考

* [“NoClassDefFoundError: Could not initialize class” error](https://stackoverflow.com/questions/1401111/noclassdeffounderror-could-not-initialize-class-error)
* [Why am I getting a NoClassDefFoundError in Java?](https://stackoverflow.com/questions/34413/why-am-i-getting-a-noclassdeffounderror-in-java)
