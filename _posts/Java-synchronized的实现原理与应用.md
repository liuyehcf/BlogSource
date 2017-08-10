---
title: Java synchronized的实现原理与应用
date: 2017-07-09 19:51:35
tags: 
- 摘录
categories: 
- Java
- Java 并发
- Java 并发机制的底层实现原理
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

在多线程并发编程中synchronized一直是元老级角色，很多人都会称呼它为重量级锁。但是随着Java SE 1.6对synchronized进行了各种优化之后，有些情况下它就并不那么重要了。这些优化包括轻量级锁以及偏向锁等等

首先来看一下利用synchronized实现同步的基础：Java中每一个对象都可以作为锁。具体表现为以下三种形式

1. 对于普通同步方法，锁是当前实例对象
1. 对于静态同步方法，锁是当前类的Class对象
1. 对于同步方法块，锁是synchronized括号里配置的对象

当一个线程试图访问同步代码块时，它首先必须得到锁，退出或抛出异常时必须释放锁。那么锁到底存在哪里呢？锁里面会存储什么信息呢？

从JVM规范中可以看到synchronized在JVM里的实现原理，JVM基于进入和退出Monitor对象来实现方法同步和代码块同步，但两者实现细节不一样。代码块同步是使用`monitorenter`与`monitorexit`指令实现的，而方法同步是使用另外一种方式实现的，细节在JVM中并没有说明，但是方法的同步同样可以使用这两个字节码来实现

`monitorenter`指令是在编译后插入到同步代码块的开始位置，而monitorexit是插入到方法结束处和异常处，JVM要保证每个`monitorenter`必须有对应的`monitorexit`与之配对。任何对象都有一个monitor与之关联，当一个monitor被持有后，它将处于锁定状态。线程执行到`monitorenter`指令时，将会尝试获取对象所对应的monitor的所有权，即尝试获得对象的锁

# 2 Java对象头

synchronized用的锁是存在Java对象头里的。如果对象是数组类型，则虚拟机用3个字节宽(Word)存储对象头。如果对象是非数组类型，则用2字宽存储对象头。在32位虚拟机中，1字宽等于4字节，即32bit，如下表所示

| 长度 | 内容 | 说明 |
|:--|:--|:--|
| 32/64bit | Mark Word | 存储对象的hashCode或锁信息 |
| 32/64bit | Class Metadata Address | 存储到对象类型数据的指针 |
| 32/64bit | Array length | 数组的长度(如果当前对象是数组) |

* `Class Metadata Address`指向一个`Klass对象`，`Klass对象`是`Class对象`在JVM内部的表示方式，包含了`Java class`的所有信息，包括注解，构造方法，字段，方法，内部类等等。个人认为这个元数据指针就是为了实现Obejct#getClass()方法，即每个Java对象都能直接访问到其所属类型的信息。

Java对象头里的Mark Word里默认存储对象的HashCode、分代年龄和锁标记位。32位JVM的Mark Word的默认存储结构如下表所示

| 锁状态 | 25bit | 4bit | 1bit是否偏向锁 | 2bit锁标志位 |
|:--|:--|:--|:--|:--|
| 无锁状态 | 对象的hashCode | 对象分代年龄 | 0 | 01 |

在运行期间，Mark Word里存储的数据会随着锁标志位的变化而变化。Mark Word可能变化为存储以下4种数据

<table> <tr> <th rowspan="2" width="80px">锁状态</th> <th colspan="2" width="160px">25bit</th> <th rowspan="2" width="160px">4bit</th> <th width="80px">1bit</th> <th width="80px">2bit</th> </tr> <tr> <th>23bit</th> <th>2bit</th> <th>是否偏向锁</th> <th>锁标志位</th> </tr> <tr> <td>轻量级锁</td> <td colspan="4">指向栈中锁记录的指针</td> <td>00</td> </tr> <tr> <td>重量级锁</td> <td colspan="4">指向互斥量(重量级锁)的指针</td> <td>10</td> </tr> <tr> <td>GC标记</td> <td colspan="4">空</td> <td>11</td> </tr> <tr> <td>偏向锁</td> <td>线程ID</td> <td>Epoch</td> <td>对象分代年龄</td> <td>1</td> <td>01</td> </tr> </table>

# 3 锁的升级与对比

Java SE 1.6为了减少获得锁和释放锁带来的性能消耗，引入了`"偏向锁"`和`"轻量级锁"`，在Java SE 1.6中，锁一共有四种状态，级别从低到高依次是：`无锁状态`、`偏向锁状态`、`轻量级锁状态`、`重量级锁状态`，这几个状态会随着竞争情况逐渐升级。__锁可以升级但不能降级__，意味着偏向锁升级成轻量级锁之后不能降级成偏向锁。这种锁升级却不能降级的策略，目的是为了提高获得锁和释放锁的效率。

# 4 参考

* Java并发编程的艺术

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
