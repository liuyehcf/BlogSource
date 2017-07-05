---
title: Java final
date: 2017-07-05 17:01:05
tags:
categories:
- Java Memory Model
---


# 前言

本篇博客主要介绍final的内存语义


<!--more-->


# final域的重排序规则

对于final域，编译器和处理器要遵守两个重要排序规则

* 在构造函数内对一个final域的写入，与随后把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序
* 初次读一个包含final域的对象的引用，与随后初次读这个final域，这两个操作之间不能重排序

## 写final域的重排序规则

写final域的重排序规则禁止把final域的写重排序到构造函数之外。这个规则的实现包含以下2方面

1. JMM禁止编译器把final域的写重排序到构造函数之外
1. 编译器会在final域的写之后，构造函数return之前，插入一个StoreStore屏障。这个屏障禁止处理器把final域的写重排序到构造函数之外


如果允许final域的写重排到构造函数之外，那么其他线程将可能访问到一个尚未初始化的final域(此时构造函数已经return，但是对象尚未构造完成)
* 这也就是单例模式中双重检测机制为什么存在问题的原因

写final域的重排序规则可以保证：在对象引用为任意线程可见之前，对象的final域已经被正确初始化过了，而普通域不具有这个保障

## 读final域的重排序规则

读final域的重排序规则是，在一个线程中，初次读取对象引用与初次读取该对象包含的final域，JMM禁止处理器重排序这两个操作(注意，这个规则仅仅针对处理器)。编译器会在读final域操作的前面插入一个LoadLoad屏障

初次读对象引用与初次读该对象包含的final域，这两个操作之间存在间接依赖关系。由于编译器遵守间接依赖关系，因此不会重排序这两个操作。大多数处理器也会遵守间接依赖，也不会重排序这两个操作。担有少数处理器允许对存在间接依赖关系的操作做重排序(比如alpha处理器)

读final域的重排序规则可以确保：在读一个对象的final域之前，一定会先读包含这个fianl域的对象的引用

* 请看下面的例子

```Java
public class FinalExample {
    int i;
    final int j;

    static FinalExample obj;

    public FinalExample() {
        i = 1;
        j = 2;
    }

    public static void writer() {
        obj = new FinalExample();
    }

    public static void reader() {
        FinalExample object = obj;
        int a = object.i;
        int b = object.j;
    }
}
```

* 如果线程A执行writer()，线程B执行reader()
    * 假定线程A的执行顺序是：构造函数开始执行->写普通域i->写final域j->StoreStore屏障->构造函数执行结束->把构造对象的引用赋值给引用变量obj
    * 线程B的执行时序可能是：读对象的普通域i->读对象引用obj->LoadLoad屏障->读对象的final域j。即普通对象的读操作被重排到了读对象引用obj之前(这里针对的是不遵守间接依赖的处理器，而对于一般处理器，这种重排是不被允许的，请注意)


# final域为引用类型

对于引用类型，写final域的重排序规则对编译器和处理器增加了如下约束

* 在构造函数内对一个final引用的对象的成员的写入，与随后在构造函数外把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序
* 确保在final引用的初始化在构造函数内完成，因此一旦其他线程拿到了一个非null的final引用，那么这个引用指向的对象一定是初始化完成的

# 为什么final引用不能从构造函数中逸出

写final域的重排序规则可以确保：在引用变量为任意线程可见之前，该引用变量指向的对象的final域已经在构造函数中被正确初始化过了

* 其实，要得到这个效果，还需要一个保证：在构造函数内部，不能让这个被构造对象的引用为其他线程所见，也就是对象引用不能再构造函数中"逸出"
* 否则，其他线程可能在构造过程中访问到一个尚未初始化完毕的对象的final域
* 看下面的例子

```Java
public class FinalReferenceEscapeExample {
    final int i;
    static FinalReferenceEscapeExample obj;

    public FinalReferenceEscapeExample() {
        i = 1;
        obj = this;
    }

    public static void writer() {
        new FinalReferenceEscapeExample();
    }

    public static void reader() {
        if (obj != null) {
            int temp = obj.i;
        }
    }
}
```

* 假设线程A执行writer()方法，线程B执行reader()方法。在构造方法内部，`i = 1;`和`obj = this;`可能会被重排，也就是说obj被赋值的时候，final域i可能尚未初始化，因此线程B可能读取到了一个非法的数值

# final语义在处理器中的实现


# JSR-133为什么要增强final的语义