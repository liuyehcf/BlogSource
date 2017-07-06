---
title: Java final
date: 2017-07-05 17:01:05
tags:
categories:
- Java
- Java Memory Model
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

本篇博客主要介绍final的内存语义

# 2 final域的重排序规则

对于final域，编译器和处理器要遵守两个重要排序规则

* 在构造函数内对一个final域的写入，与随后把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序
* 初次读一个包含final域的对象的引用，与随后初次读这个final域，这两个操作之间不能重排序

__我们将通过以下程序中两个线程的交互来说明这两个规则__

```Java
public class FinalExample {
    int i;//普通变量
    final int j;//final变量

    static FinalExample obj;

    public FinalExample() {//构造函数
        i = 1;//写普通域
        j = 2;//写final域
    }

    public static void writer() {//写线程A执行
        obj = new FinalExample();
    }

    public static void reader() {//读线程B执行
        FinalExample object = obj;//读对象引用
        int a = object.i;//读普通域
        int b = object.j;//读final域
    }
}
```

## 2.1 写final域的重排序规则

写final域的重排序规则禁止把final域的写重排序到构造函数之外。这个规则的实现包含以下2方面

1. JMM禁止编译器把final域的写重排序到构造函数之外
1. 编译器会在final域的写之后，构造函数return之前，插入一个StoreStore屏障。这个屏障禁止处理器把final域的写重排序到构造函数之外

现在分析write方法，write只包含一行代码`obj = new FinalExample();`，这行代码包含以下两个步骤

1. 构造一个FinalExample类型的对象
1. 把这个对象的引用赋值给引用变量obj 

假设线程B读对象引用与读对象成员之间没有重排序，那么下图就是一种可能的执行顺序

```sequence
Note over 线程A:构造函数开始执行
Note over 线程A:写final域：\nj = 2
Note over 线程A:StoreStore屏障
Note over 线程A:构造函数执行结束
Note over 线程A:把构造对象的引用\n赋值给引用变量obj
Note over 线程B:读对象引用obj
Note over 线程B:读对象的普通域i
Note over 线程B:读对象的final域j
Note over 线程A:写普通域：\ni = 1
```

* 上图中，写普通域的操作被编译器重排到了构造函数之外，读线程B错误地读取了普通变量i初始化之前的值
* 而写final域的操作，被写final域的重排序规则"限定"在了构造函数之内，读线程B正确地读取了final变量初始化之后的值
* 如果允许final域的写重排到构造函数之外，那么其他线程将可能访问到一个尚未初始化的final域(此时构造函数已经return，但是对象尚未构造完成)，__这也就是单例模式中双重检测机制为什么存在问题的原因__
* 写final域的重排序规则可以保证：在对象引用为任意线程可见之前，对象的final域已经被正确初始化过了，而普通域不具有这个保障

## 2.2 读final域的重排序规则

读final域的重排序规则是，在一个线程中，初次读取对象引用与初次读取该对象包含的final域，JMM禁止处理器重排序这两个操作(注意，这个规则仅仅针对处理器)。编译器会在读final域操作的前面插入一个LoadLoad屏障

初次读对象引用与初次读该对象包含的final域，__这两个操作之间存在间接依赖关系__

* 由于编译器遵守间接依赖关系，因此不会重排序这两个操作
* 大多数处理器也会遵守间接依赖，也不会重排序这两个操作。但有少数处理器允许对存在间接依赖关系的操作做重排序(比如alpha处理器),__这个规则就是专门用来针对这种处理器的__

reader()方法包含3个操作

* 初次读引用变量obj
* 初次读引用变量obj指向对象的普通域i
* 初次读引用变量obj指向对象的final域j

假设写线程A没有发生任何重排序，同时程序在__不遵守__间接依赖的处理器上执行，那么下图就是一种可能的执行顺序

* __注意__，编译器是不允许这种重排的，但是某些处理器允许

```sequence
Note over 线程A:构造函数开始执行
Note over 线程B:读对象的普通域i
Note over 线程A:写普通域：\ni = 1
Note over 线程A:写final域：\nj = 2
Note over 线程A:StoreStore屏障
Note over 线程A:构造函数执行结束
Note over 线程A:把构造对象的引用\n赋值给引用变量obj
Note over 线程B:读对象引用obj
Note over 线程B:LoadLoad屏障
Note over 线程B:读对象的final域j
```

* 在上图中，读对象的普通域的操作被处理器重排序到读对象引用之前。读普通域时，该域还没有被线程A写入，这是一个错误地读取操作
* 而读final域的重排序规则会把读对象final域的操作"限定"在读对象引用之后，此时该final域已经被A线程初始化过了，这是一个正确地读取操作
* 读final域的重排序规则可以确保：在读一个对象的final域之前，一定会先读包含这个fianl域的对象的引用

# 3 final域为引用类型

对于引用类型，写final域的重排序规则对编译器和处理器增加了如下约束

* 在构造函数内对一个final引用的对象的成员的写入，与随后在构造函数外把这个被构造对象的引用赋值给一个引用变量，这两个操作之间不能重排序
* 确保在final引用的初始化在构造函数内完成，因此一旦其他线程拿到了一个非null的final引用，那么这个引用一定是在构造函数内被正确赋值的(至于是否正确初始化，则不一定，这取决于final引用的赋值语句)

```Java
public class FinalReferenceExample {
    final int[] intArray;//final是引用类型

    static FinalReferenceExample obj;

    public FinalReferenceExample() {//构造函数
        intArray = new int[1];//1
        intArray[0] = 1;//2
    }

    public static void writerOne() {//写线程A执行
        obj = new FinalReferenceExample();//3
    }

    public static void writerTwo() {//写线程B执行
        obj.intArray[0] = 2;//4
    }

    public static void reader() {
        if (obj != null) {
            int temp1 = obj.intArray[0];
        }
    }
}
```

假设首先线程A执行writerOne()方法，执行完后线程B执行writerTwo()方法，执行完后线程C执行reader()方法，下图是一种可能的执行时序

```sequence
participant 线程A
participant 线程B
participant 线程C
Note over 线程A:构造函数开始执行
Note over 线程A:1：写final引用
Note over 线程A:2：写final引用对象的成员域
Note over 线程A:StoreStore屏障
Note over 线程A:构造函数执行结束
Note over 线程A:3：把构造对象的引用\n赋值给引用变量obj
Note over 线程C:5：读对象引用obj
Note over 线程C:LoadLoad屏障
Note over 线程C:6：读final引用的成员域
Note over 线程B:4：写final引用对象的成员域
```

* 1和3不能重排序，2和3也不能重排序
* JMM可以确保读线程C至少能看到写线程A在构造函数中对final引用对象的成员域的写入，即C至少能看到数组下标0的值为1
* 而写线程B对数组元素的写入，读线程C可能看得到，也可能看不到。JMM不保证线程B的写入对读线程C可见，因为写线程B和读线程C之间存在数据竞争，此时执行结果不可预知
* 如果想要确保读线程C看到写线程B对数组元素的写入，写线程B和读线程C之间需要使用同步原语(lock或volatile)来保证内存可见性

# 4 为什么final引用不能从构造函数中逸出

写final域的重排序规则可以确保：在引用变量为任意线程可见之前，该引用变量指向的对象的final域已经在构造函数中被正确初始化过了

* 其实，要得到这个效果，还需要一个保证：在构造函数内部，不能让这个被构造对象的引用为其他线程所见，也就是对象引用不能再构造函数中"逸出"
* 否则，其他线程可能在构造过程中访问到一个尚未初始化完毕的对象的final域
* 看下面的例子

```Java
public class FinalReferenceEscapeExample {
    final int i;
    static FinalReferenceEscapeExample obj;

    public FinalReferenceEscapeExample() {
        i = 1;//1 写final域
        obj = this;//2 this引用在此"逸出"
    }

    public static void writer() {
        new FinalReferenceEscapeExample();
    }

    public static void reader() {
        if (obj != null) {//3
            int temp = obj.i;//4
        }
    }
}
```

假设一个线程A执行writer()方法，另一个线程B执行reader()方法，下图是一种可能的执行时序

```sequence
Note over 线程A:构造函数开始执行
Note over 线程A:obj = this;\n2：被构造对象的引用在此"逸出"
Note over 线程B:if(obj != null)\n3：读取不为null的对象引用a
Note over 线程B:int temp = obj.i;\n4：这里将读到final域初始化之前的值
Note over 线程A:i=1;\n1：对final域初始化
Note over 线程A:构造函数结束
```

* 这里操作2使得对象还未完成构造前就为线程B可见。即使这里的操作2是构造函数的最后一步，且在程序中操作2排在操作1后面，执行read()方法的线程仍然可能无法看到final域被初始化后的值，因为操作1和操作2之间可能被重排序(final域的重排规则仅仅保证了final域的写必须在构造方法返回前完成，但是并没有规定构造函数中final域的写与其他语句不能重排序)
* 在构造函数返回之前，被构造对象的引用不能为其他线程所见，因为此时的final域可能还没有被初始化。在构造函数返回后，任意线程都将保证能看到final域正确初始化之后的值

# 5 final语义在处理器中的实现

上面提到

* 写final域的重排序规则会要求编译器在final域的写之后，构造函数return之前插入一个StoreStore屏障
* 读final域的重排序规则会要求编译器在读final域的操作前面插入一个LoadLoad屏障

由于X86处理器不会对写-写操作做重排序，所以在X86处理器中，写final域需要的StoreStore屏障会被省略掉。同样X86处理器不会对存在间接依赖关系的操作做重排序，所以在X86处理器中，读final域需要的LoadLoad屏障也会被省略掉，也就是说，在X86处理器中，final域的读写不会插入任何的内存屏障

# 6 JSR-133为什么要增强final的语义

在旧的Java内存模型中，一个最严重的缺陷就是线程可以看到final域的值会改变。比如，一个线程当前看到一个整型final域的值为0(还未初始化之前的默认值)，过一段时间之后这个线程再去读这个final域的值时，却发现值变为1(被某个线程初始化之后的值)。最常见的例子就是在旧的Java内存模型中，String的值可能会改变

为了修补这个漏洞，JSR-133专家组增强了final的语义。通过为final域增加写和读重排序规则，可以为Java程序员提供初始化安全保证：__只要对象时正确构造的(被构造对象的引用在构造函数中没有"逸出")，那么不需要使用同步(指lock和volatile的使用)就可以保证任意线程都能看到这个final域在构造函数中被初始化之后的值__

* 要看到域，前提是必须获取该对象的引用。而获取到引用的时候，这个final域必定已经正确初始化，因此是安全的

# 7 参考

__Java并发编程的艺术__

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
