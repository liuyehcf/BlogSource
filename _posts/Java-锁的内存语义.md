---
title: Java-锁的内存语义
date: 2017-07-08 21:04:00
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- Java Memory Model
---

__阅读更多__

<!--more-->

# 1 前言

众所周知，锁可以让临界区互斥执行。这两将介绍锁的另一个同样重要，但是常常被忽视的功能：锁的内存语义

# 2 锁的释放-获取建立的happen-before关系

锁是Java并发编程中最重要的同步机制，锁除了让临界区互斥执行外，还可以让释放锁的线程向获取同一个锁的线程发送消息，下面以一个示例程序进行讲解

```Java
class MonitorExample{
    int a=0;

    public synchronized void writer(){// 1
        a++;// 2
    }// 3

    public synchronized void reader(){// 4
        int i=a;// 5
        ...
    }// 6
}
```

* 假设线程A执行writer()方法，随后线程B执行reader()方法。根据happens-before规则，这个过程包含的happens-before关系可以分为3类
    * 根据程序次序规则，1 happens-before 2，2 happens-before 3；4 happens-before 5，5 happens-before 6
    * 根据监视器规则，3 happens-before 4
    * 根据happens-before的传递性，2 happens-before 5

```sequence
Note over 线程A:1：线程A获取锁
Note over 线程A:2：线程A执行临界区中的代码
Note over 线程A:3：线程A释放锁
Note over 线程B:4：线程B获取同一个锁
Note over 线程B:5：线程B执行临界区中的代码
Note over 线程B:6：线程B释放锁
```

* 在线程A释放了锁之后，随后线程B获取同一个锁。因此线程A在释放锁之前所有可见的共享变量，在线程B获取同一个锁之后，将立刻变得对B线程可见

# 3 锁的释放或获取的内存语义

## 3.1 锁释放的内存语义

__锁释放的内存语义：当线程释放锁时，JMM会把该线程对应的(所有)本地内存中的共享变量刷新到主内存中__

以上面的MonitorExample为例，A线程释放锁后，共享数据的状态示意图如下

![锁释放共享状态示意图](/images/Java-锁的内存语义/锁释放共享状态.png)

## 3.2 锁获取的内存语义

__锁获取的内存语义：当线程获取锁时，JMM会把该线程对应的(所有)本地内存置为无效，从而使得被监视器保护的临界区代码必须从主内存中读取共享变量__

以上面的MonitorExample为例，B线程获取锁后，共享数据的状态示意图如下

![锁获取共享状态示意图](/images/Java-锁的内存语义/锁获取共享状态.png)

## 3.3 小结

锁释放和锁获取内存语义的总结

1. 线程A释放一个锁，实质上是线程A向接下来将要获取这个锁的某个线程发出了(线程A对共享变量所作修改的)消息
1. 线程B获取一个锁，实质上是线程B接收了之前某个线程发出的(在释放这个锁之前对共享变量所作修改的)消息
1. 线程A释放锁，随后线程B获取锁，这个过程实质上是线程A通过主内存向线程B发送消息

对比锁释放-获取的内存语义与volatile写-读的内存语义可以看出

* 锁释放与volatile写有相同的内存语义
* 锁获取与volatile读有相同的内存语义

# 4 锁内存语义的实现

__正是由于JDK 1.5之后volatile的内存语义得到增强，才可能实现Java concurrent包__

借助ReentrantLock的源代码，来分析锁内存语义的具体实现机制，请看下面代码

```Java
class ReentrantLockExample {
    int a = 0;

    ReentrantLock lock = new ReentrantLock();

    public void writer() {
        lock.lock();// 获取锁
        try {
            a++;
        } finally {
            lock.unlock();// 释放锁
        }
    }

    public void reader() {
        lock.lock();// 获取锁
        try {
            int i = a;
            ...
        } finally {
            lock.unlock();// 释放锁
        }
    }
}
```

* ReentrantLock的实现依赖于Java同步器框架AbstractQueuedSynchronizer(简称为AQS)，关于concurrent包下源码分析，请参考[Java concurrent 源码剖析](https://liuyehcf.github.io/categories/Java/Java-%E5%B9%B6%E5%8F%91/Java-concurrent-%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90/)
* __AQS使用一个整型的volatile变量(state)来维护同步状态，这个volatile变量是实现ReentrantLock内存语义实现的关键__

ReentrantLock分为公平锁和非公平锁

## 4.1 公平锁

使用公平锁时，加锁方法lock()调用轨迹如下

1. ReentrantLock：lock()
1. FairSync：lock()
1. AQS：acquire(int arg)
1. ReentrantLock：tryAcquire(int acquires)

```Java
protected final boolean tryAcquire(int acquires) {
    final Thread current = Thread.currentThread();
    int c = getState();// 获取锁的开始，首先读volatile变量state
    if (c == 0) {
        if (!hasQueuedPredecessors() &&
            compareAndSetState(0, acquires)) {
            setExclusiveOwnerThread(current);
            return true;
        }
    }
    else if (current == getExclusiveOwnerThread()) {
        int nextc = c + acquires;
        if (nextc < 0)
            throw new Error("Maximum lock count exceeded");
        setState(nextc);
        return true;
    }
    return false;
}
```

* 首先读取volaitle变量state，根据volatile读的内存语义：当从主内存中读取volatile变量时，读取到的一定是当前或其他线程最后一次写操作的值

使用公平锁时，解锁方法unlock()调用轨迹如下

1. ReentrantLock：unlock()
1. AQS：release(int arg)
1. Sync：tryRelease(int release)

```Java
protected final boolean tryRelease(int releases) {
    int c = getState() - releases;
    if (Thread.currentThread() != getExclusiveOwnerThread())
        throw new IllegalMonitorStateException();
    boolean free = false;
    if (c == 0) {
        free = true;
        setExclusiveOwnerThread(null);
    }
    setState(c);// 释放锁后，写volatile变量state
    return free;
}
```

* 公平锁在释放锁的最后写volatile变量state，在获取锁时首先读取这个volatile变量。根据volatile的happens-before规则，释放锁的线程在写volatile变量之前可见的共享变量，在获取锁的线程读取同一个volatile变量后将立即变得对获取锁的线程可见

## 4.2 非公平锁

现在来分析非公平锁的内存语义的实现。非公平锁的释放与公平锁完全一致，所以这里仅分析非公平锁的获取

使用非公平锁时，加锁方法lock()的调用轨迹如下

1. ReentrantLock：lock()
1. NonfairSync：lock()
1. AQS：compareAndSetState(int expect,int update)

```Java
protected final boolean compareAndSetState(int expect, int update) {
    // See below for intrinsics setup to support this
    return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
}
```

* 该方法以原子操作的方式更新state变量，该操作简称为CAS，该操作具有volatile读和写的内存语义

接下来分别从编译器和处理器的角度来分析，CAS如何同时具有volatile读和volatile写的内存语义

### 4.2.1 CAS的内存语义

编译器不会对volatile读和volatile读后面的任意内存操作重排序；编译器不会对volatile写与volatile写前面的任何内存操作重排序。组合这两个条件，意味着同时实现了volatile读和volaitle写的内存语义，编译器不能对CAS于CAS前后任何内存操作重排序

接下来，我们分析在常见的intel x86处理器中，CAS是如何同时具有volatile读和volatile写的内存语义的

下面是sun.misc.Unsafe类的compareAndSwapInt()方法的源码

```Java
    public final native boolean compareAndSwapInt(Object o, long offset, int expected, int x);
```

* 这是一个本地方法调用，其源码片段如下

```C
    inline jint Atomic::cmpxchg(jint exchange_value, volatile jint* dest, jint compare_value){
        // alternative for InterlockedCompareExchange
        int mp = os::is_MP();
        __asm{
            mov edx, dest
            mov ecx, exchange_value
            mov eax, compare_value
            LOCK_IF_MP(mp)// 程序会根据当前处理器的类型来决定是否为cmpxchg指令添加lock前缀
            cmpxchg dword ptr [edx], ecx
        }
    }
```

* 如上面代码所示，程序会根据当前处理器的类型来决定是否为cmpxchg指令添加lock前缀
    * 如果程序是在多处理器上运行，就为cmpxchg指令加上lock前缀
    * 如果程序是在单处理器上运行，就省略lock前缀

intel手册对lock前缀说明如下

1. 确保对内存的读-改-写操作原子执行
1. 禁止该指令，与之前和之后的读和写指令重排序
1. 把写缓冲区中的所有数据刷新到内存中

上面第2点和第3点所具有的内存屏障的效果足以同时实现volatile度和volatile写的内存语义，现在终于明白为什么JDK文档说CAS同时具有volatile读和volatile写的内存语义了

## 4.3 小结

现在对公平锁和非公平锁的内存语义做个总结

1. 公平锁和非公平锁释放时，最后都要写一个volatile变量state
1. 公平锁获取时，首先会去读volatile变量
1. 非公平锁获取时，首先会用CAS更新volatile变量，这个操作同时具有volatie读和volatile写的内存语义

__从本文对ReentrantLock的分析可以看出，锁释放-获取的内存语义的实现至少有下面两种方式__

1. 利用volatile变量的写-读所具有的内存语义
1. 利用CAS所附带的volatile读和volatile写的内存语义

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《Java并发编程的艺术》

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
