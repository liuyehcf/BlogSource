---
title: Java 单例双重检测正确性分析
date: 2017-07-07 14:35:03
tags:
- 摘录
categories:
- Java
- Java Memory Model
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

在Java多线程程序中，有时候需要采用延迟初始化来降低初始化类和创建对象的开销。双重检查锁定是常见的延迟初始化技术，但它是一个错误的用法。本篇博客将分析双重检查锁定的错误根源，以及两种线程安全的延迟初始化方案

# 2 双重检查锁定的由来

在Java程序中，有时候可能需要推迟一些高开销的对象初始化操作，并且只有在使用这些对象时才进行初始化。此时，程序员可能会采用延迟初始化。但要正确实现线程安全的延迟初始化需要一些技巧，否则很容易出现问题。比如下面是非线程安全的延迟初始化对象的示例代码

```Java
class Instance{

}

class UnsafeLazyInitialization{
    private static Instance instance;

    public static Instance getInstance(){
        if(instance==null)//1：线程A执行
            instance=new Instance();/:2：线程B执行
        return instance;
    }
}
```

* 在UnsafeLazyInitialization类中，假设A线程执行代码1的同时，B线程执行代码2。此时，线程可能会看到instance引用的对象还没有完成初始化

对于UnsafeLazyInitialization类，我们可以对getInstance()方法做同步处理来实现线程安全的延迟初始化，示例代码如下、
```Java
class Instance{

}

class SafeLazyInitialization {
    private static Instance instance;

    public synchronized static Instance getInstance(){
        if(instance==null)
            instance=new Instance();
        return instance;
    }
}
```

* 由于对getInstance()方法做了同步处理，synchronized将导致性能开销。如果getInstance()方法被多个线程频繁调用，将会导致程序执行的性能下降。反之，如果getInstance()方法不会被多个线程频繁的调用，那么这个延迟初始化方案将能提供令人满意的性能

下面是使用双重检查锁定来实现延迟初始化的代码

```Java
class Instance {

}

class DoubleCheckedLocking {//1
    private static Instance instance;//2

    public static Instance getInstance() {//3
        if (instance == null) {//4：第一次检查
            synchronized (DoubleCheckedLocking.class) {//5：加锁
                if (instance == null)//6：第二次检查
                    instance = new Instance();//7：问题的根源出在这里
            }//8
        }//9
        return instance;//10
    }//11
}
```

* 如上面代码所示，如果第一次检查instance不为null，那么就不需要执行下面的加锁和初始化操作。因此，可以大幅降低synchronized带来的性能开销。这样的做法看起来两全其美
    * 多个线程试图在同一时间创建对象时，会通过加锁来保证只有一个线程创建对象
    * 在对象创建好之后，执行getInstance()方法将不需要获取锁，直接返回已经创建好的对象

__双重检查锁定看起来似乎很完美，但这是一个错误的优化！在线程执行到第4行，代码读取到instance不为null时，instance引用的对象有可能还没有完成初始化__

# 3 问题的根源

前面的双重检查锁定示例代码的第七行`instance = new Instance();`创建了一个对象，这一行代码可以分解为如下3行伪代码

1. memory = allocate();//1：分配对象的内存空间
1. ctorInstance(memory);//2：初始化对象
1. instance=memroy;//3：设置instance指向刚分配的内存地址

上面3行伪代码中的2和3之间，可能会被重排序(在一些JIT编译器上，这种重排序是真实发生的)，重排序后时序如下

1. memroy = allocate();//1：分配对象的内存空间
1. instance=memroy;//3：设置instance指向刚分配的内存地址
1. //注意，此时对象还没有被初始化
1. ctorInstance(memory);//2：初始化对象

根据《The Java Language Specification，Java SE 7 Edition》(简称为Java语言规范)，所有线程在执行Java程序时必须要遵守intra-thread semantics。intra-thread semantics保证重排序不会改变单线程内的程序执行结果。换句话说，intra-thread semantics允许那些在单线程内，不会改变单线程程序执行结果的重排序。上面3行伪代码2和3之间虽然被重排序了，但是这个重排序并不会违反intra-thread semantics。这个重排序在没有改变单线程程序执行结果的前提下，可以提高程序的执行性能

为了更好地理解intra-thread semantics，请看如下示意图

```sequence
Note over 线程A:1：分配对象的内存空间
Note over 线程A:3：设置instance指向内存空间
Note over 线程A:2：初始化对象
Note over 线程A:4：初次访问对象
```

* 虽然2和3重排序了，但是只要保证2排在4前面执行，单线程内的执行结果就不会被改变

```sequence
Note over 线程A:1：分配对象的内存空间
Note over 线程A:3：设置instance指向内存空间
Note over 线程B:判断instance是否为null
Note over 线程B:B线程初次访问对象
Note over 线程A:2：初始化对象
Note over 线程A:4：初次访问对象
```

* 由于单线程要遵循intra-thread semantics，从而能保证A线程的执行结果不会被改变。__但是当线程A和B按上图时序执行时，B线程将看到一个还没有被初始化的对象__

总结一下

| 时间 | 线程A | 线程B |
|:--:|:--|:--|
| t1 | A1：分配对象的内存空间 |  |
| t2 | A3：设置instance指向内存空间 |  |
| t3 |  | B1：判断instance是否为空 |
| t4 |  | B2：由于instance不为null，线程B将访问instance引用的对象 |
| t5 | A2：初始化对象 |  |
| t6 | A4：访问instance引用的对象 |  |

* 这里A2和A3虽然重排序了，但Java内存模型的intra-thread semantics将确保A2一定会排在A4前面执行。因此，线程A的intra-thread semantics没有改变
* 但是A2和A3重排序，将导致线程B在B1处判断出instance不为空，线程B接下来将访问instance引用的对象。此时，线程B将会访问到一个还未初始化的对象
* 在知道了问题发生的根源后，我们可以想出两个办法来实现线程安全的延迟初始化
    * 不允许2和3重排
    * 允许2和3重排，但是不允许其他线程"看到"这个重排序

# 4 基于volatlie的解决方案

对于前面的基于双重检查锁定来实现延迟初始化的方案(指DoubleCheckedLocking示例代码)，只需要做一点小的修改(把instance声明为volatile型)，就可以实现线程安全的延迟初始化

* 这个解决方案需要JDK5或更高版本(因为从JDK5开始使用新的JSR-133内存模型规范，这个规范增强了volatile的语义)

```Java
class Instance {

}

class SafeDoubleCheckedLocking {
    private volatile static Instance instance;

    public static Instance getInstance() {
        if (instance == null) {
            synchronized (SafeDoubleCheckedLocking.class) {
                if (instance == null)
                    instance = new Instance();//instance为volatile，现在没问题了
            }
        }
        return instance;
    }
}
```

* 当声明对象的引用为volatile后，上一节中三行伪代码中的2和3之间的重排序，在多线程环境中将会被禁止
* 这个方案本质上是通过禁止2和3之间的重排序，来保证线程安全的延迟初始化

# 5 基于类初始化的解决方案

JVM在类的初始化阶段(即在Class被加载后，且被线程使用之前)，会执行类的初始化。在执行类的初始化期间，JVM会获取一个锁。这个锁可以同步多个线程对同一个类的初始化。基于这个特性，可以实现另一种线程安全的延迟初始化方案(这个方案被称之为Initialization On Demand Holder idiom)

```Java
class Instance {

}

class InstanceFactory {
    private static class InstanceHolder{
        public static Instance instance=new Instance();
    }

    public static Instance getInstance(){
        return InstanceHolder.instance;//这里将导致InstanceHolder类被初始化
    }
}
```

* 这个方案的实质是：允许前一小节提到的3行伪代码中的2和3的重排序，但不允许非构造线程"看到"这个重排序

初始化一个类，包括执行这个类的静态初始化和初始化在这个类中声明的静态字段。根据Java语言规范，在首次发生下列任意一种情况时，一个类或接口类型T将被立即初始化

1. T是一个类，而且一个T类型的实例被创建
1. T是一个类，且T中声明的一个静态方法被调用
1. T中声明的一个静态字段被赋值
1. T中声明的一个静态字段被使用，而且这个字段不是一个常量字段
1. T是一个顶级类(Top Level Class)，而且一个断言语句嵌套在T内部被执行???

Java语言是多线程的，多个线程可能在同一时间尝试去初始化同一个类或接口(比如这里多个线程可能在同一时刻调用getInstance()方法来初始化InstanceHolder类)。因此，在Java中初始化一个类或接口时，需要做细致的同步处理

* Java语言规范规定，对于每一个类或接口C，都有一个唯一的初始化锁LC与之对应。从C到LC的映射，由JVM的具体实现去自由实现。JVM在类初始化期间会获取这个初始化锁，并且每个线程至少获取一次锁来确保这个类已经被初始化过了(事实上，Java语言规范允许JVM的具体实现在这里做一些优化，见后文说明)

对于类或接口的初始化，Java语言规范制定了精巧而复杂的类初始化处理过程。Java初始化一个类或接口的处理过程可以分为如下几个部分(这里对类初始化处理过程的说明，省略了与本文无关的部分；同时为了更好地说明类初始化过程中的同步处理机制，__Java并发编程艺术__的作者把类初始化的处理过程分为了5个阶段)，将分为几个小节进行描述

## 5.1 阶段1

__第1阶段：通过在Class对象上同步(即获取Class对象的初始化锁)，来控制类或接口的初始化。这个获取锁的过程会一直等待，直到当前线程能够获取到这个初始化锁__

假设Class对象当前还没有被初始化(初始化状态state，此时被标记为state = noInitialization)，且有两个线程A和B试图同时初始化这个Class对象

| 时间 | 线程A | 线程B |
|:--:|:--|:--|
| t1 | A1：尝试获取Class对象的初始化锁，这里假设线程A获取到了初始化锁 | B1：尝试获取Class对象的初始化锁，由于线程A获取到了锁，线程B将一直等待获取初始化锁 |
| t2 | A2：线程A看到类还未被初始化(因为读取到state == noInitialization)，线程设置state = initializing |  |
| t3 | A3：线程A释放初始化锁 |  |

__该阶段的时序示意图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段1开始
Note over 线程A,线程B:A1/B1：尝试获取Class对象的初始化锁。\n这里假设线程A获取到了初始化锁；\n线程B将等待获取初始化锁
Note over 线程A:A2：线程A看到类还未被初始化\n因为读取到state == noInitialization，\n线程设置state = initializing
Note over 线程A:A3：线程A释放初始化锁
线程A-->线程C:阶段1结束
```

## 5.2 阶段2

__第2阶段：线程A执行类的初始化，同时线程B在初始化锁对应的condition上等待__

| 时间 | 线程A | 线程B |
|:--:|:--|:--|
| t1 | A1：执行类的静态初始化和初始化类中声明的静态字段 | B1：获取到初始化锁 |
| t2 |  | B2：读取到state == initializing |
| t3 |  | B3：释放初始化锁 |
| t4 |  | B4：在初始化锁的condition中等待 |

__该阶段的时序示意图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段2开始
Note over 线程A,线程B:A1：执行类的静态初始化\n和初始化类中声明的静态字段\nB1：获取到初始化锁
Note over 线程B:B2：读取到state = initializing
Note over 线程B:B3：释放初始化锁
Note over 线程B:B4：在初始化锁的condition中等待
线程A-->线程C:阶段2结束
```

## 5.3 阶段3

__第3阶段：线程A设置state = initialized，然后唤醒在condition中等待的所有线程__

| 时间 | 线程A |
|:--:|:--|
| t1 | A1：获取初始化锁 |
| t2 | A2：设置state = initialized | 
| t3 | A3：唤醒在condition中等待的所有线程 | 
| t4 | A4：释放初始化锁 | 
| t5 | A5：线程A的初始化处理过程完成 | 

__该阶段的时序示意图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段3开始
Note over 线程A:A1：获取初始化锁
Note over 线程A:A2：设置state = initialized
Note over 线程A:A3：唤醒在condition中等待的所有线程
Note over 线程A:A4：释放初始化锁
Note over 线程A:A5：线程A的初始化处理过程完成
线程A-->线程C:阶段3结束
```

## 5.4 阶段4

__第4阶段：线程B结束类的初始化处理__

| 时间 | 线程B |
|:--:|:--|
| t1 | B1：获取初始化锁 |
| t2 | B2：读取到state = initialized | 
| t3 | B3：释放初始化锁 | 
| t4 | B4：线程B的类初始化处理过程完成 | 

__该阶段的时序示意图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段4开始
Note over 线程B:B1：获取初始化锁
Note over 线程B:B2：读取到state = initialized
Note over 线程B:B3：释放初始化锁
Note over 线程B:B4：线程B的类初始化处理过程完成
线程A-->线程C:阶段4结束
```

线程A在第2阶段的A1执行类的初始化，并在第3阶段的A4释放初始化锁；线程B在第4阶段的B1获取同一个初始化锁，并在第4阶段的B4之后才开始访问这个类。根据Java内存模型规范的锁规则，这里将存在如下的happens-before关系

* 这个happens-before关系将保证：线程A执行类的初始化时的写入操作(执行类的静态初始化和初始化类中声明的静态字段)，线程B一定能看到

## 5.5 阶段5

__第5阶段：线程C执行类的初始化的处理__

| 时间 | 线程C |
|:--:|:--|
| t1 | C1：获取初始化锁 |
| t2 | C2：读取到state = initialized | 
| t3 | C3：释放初始化锁 | 
| t4 | C4：线程C的类初始化处理过程完成 | 

__该阶段的时序示意图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段5开始
Note over 线程C:C1：获取初始化锁
Note over 线程C:C2：读取到state = initialized
Note over 线程C:C3：释放初始化锁
Note over 线程C:C4：线程C的类初始化处理过程完成
线程A-->线程C:阶段5结束
```

在第3阶段之后，类已经完成了初始化。因此线程C在第5阶段的类初始化处理过程相对简单一些(前面的线程A和B的类初始化处理过程都经历了两次锁获取-锁释放，而线程C的类初始化处理只需要经理一次锁获取，锁释放)

线程A在第2阶段的A1执行类的初始化，并在第3阶段的A4释放锁；线程C在第5阶段的C1获取同一个锁，并在第5个阶段的C4之后才开始访问这个类。根据Java内存模型规范的锁规则，将存在如下的happens-before关系

* 这个happens-before关系将保证：线程A执行类的初始化时的写入操作，线程C一定能看到

## 5.6 小节

上述过程中讲到的state和condition是本文虚构出来的，Java语言规范并没有硬性规定一定要用condition和state标记。JVM的具体实现只要实现类似功能即可

__整合上述5个阶段的时序图如下__

```sequence
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段1开始
Note over 线程A,线程B:A1/B1：尝试获取Class对象的初始化锁。\n这里假设线程A获取到了初始化锁；\n线程B将等待获取初始化锁
Note over 线程A:A2：线程A看到类还未被初始化\n因为读取到state == noInitialization，\n线程设置state = initializing
Note over 线程A:A3：线程A释放初始化锁
线程A-->线程C:阶段1结束
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段2开始
Note over 线程A,线程B:A1：执行类的静态初始化\n和初始化类中声明的静态字段\nB1：获取到初始化锁
Note over 线程B:B2：读取到state = initializing
Note over 线程B:B3：释放初始化锁
Note over 线程B:B4：在初始化锁的condition中等待
线程A-->线程C:阶段2结束
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段3开始
Note over 线程A:A1：获取初始化锁
Note over 线程A:A2：设置state = initialized
Note over 线程A:A3：唤醒在condition中等待的所有线程
Note over 线程A:A4：释放初始化锁
Note over 线程A:A5：线程A的初始化处理过程完成
线程A-->线程C:阶段3结束
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段4开始
Note over 线程B:B1：获取初始化锁
Note over 线程B:B2：读取到state = initialized
Note over 线程B:B3：释放初始化锁
Note over 线程B:B4：线程B的类初始化处理过程完成
线程A-->线程C:阶段4结束
participant 线程A
participant 线程B
participant 线程C
线程A-->线程C:阶段5开始
Note over 线程C:C1：获取初始化锁
Note over 线程C:C2：读取到state = initialized
Note over 线程C:C3：释放初始化锁
Note over 线程C:C4：线程C的类初始化处理过程完成
线程A-->线程C:阶段5结束
```

# 6 总结

通过对比基于volatile的双重检查锁定的方案和基于类初始化的方案，我们会发现基于类初始化的方案的实现代码更简洁。基于volatile的双重检查锁定的方案有一个额外的优势：除了可以对静态字段实现延迟初始化外，还可以对实例字段实现延迟初始化

字段延迟初始化降低了初始化类或创建实例的开销，但增加了访问被延迟初始化的字段的开销。在大多数时候，正常的初始化要优于延迟初始化。如果确实需要对实例字段使用线程安全的延迟初始化，请使用上面介绍的基于volatile的延迟初始化的方案；如果确实需要对静态字段使用线程安全的延迟初始化，请使用上面介绍的基于类初始化的方案

# 7 参考

__Java并发编程的艺术__

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
