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
            Class.forName("org.liuyehcf.error.InitializeThrowError"); //(1)
        } catch (Throwable e) {
            // 这里捕获到的是java.lang.ExceptionInInitializerError
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

```Java
    /**
     * Dispatch an uncaught exception to the handler. This method is
     * intended to be called only by the JVM.
     */
    private void dispatchUncaughtException(Throwable e) {
        getUncaughtExceptionHandler().uncaughtException(this, e);
    }
```

__可以看到，异常是由JVM抛出，并且调用了一个Java实现的handler方法来处理该异常，于是我猜测Java字节码的执行是位于JVM当中的__

对于下面的语句，我__猜测__执行过程如下
1. Java字节码的解释执行__位于JVM空间__
1. 执行语句1，第一次遇到类型A，__隐式触发__类加载过程。这时，用的是当前类加载器（假设是AppClassLoader），于是JVM调用Java代码（`ClassLoader.loadClass(String)`）来执行类加载过程。然后JVM调用Java代码（A的构造方法）创建实例
    * 类加载过程涉及到很多次Java代码与JVM代码交互的过程，可以参考{% post_link Java-类加载原理 %}
1. 执行语句2，再一次遇到类型A，在JVM维护的内部数据结构中，通过类加载器实例（当前类加载器，即AppClassLoader）以及全限定名定位Class实例，发现命中，则不触发加载过程，然后JVM调用Java代码（A的构造方法）创建实例
1. 执行语句3，JVM调用java代码

```Java
    A a1 = new A();// (1)
    A a2 = new A();// (2)
    a2.func();// (3)
```

# 2 NoClassDefFoundError与ClassNotFoundException

ClassNotFoundException：意味着类加载器找不到某个类，即拿不到代表某个类的.class文件，通常来说，是由于classpath没有引入该类的加载路径

NoClassDefFoundError：意味着JVM之前已经尝试加载某个类，__但是由于某些原因，加载失败了__。后来，我们又用到了这个类，于是抛出了该异常。因此，NoClassDefFoundError并不是classpath的问题。__因此，产生NoClassDefFoundError这个异常有两个条件：加载失败；加载失败抛出的异常被捕获，且后来用使用到了这个类__

# 3 参考

* [“NoClassDefFoundError: Could not initialize class” error](https://stackoverflow.com/questions/1401111/noclassdeffounderror-could-not-initialize-class-error)
* [Why am I getting a NoClassDefFoundError in Java?](https://stackoverflow.com/questions/34413/why-am-i-getting-a-noclassdeffounderror-in-java)
