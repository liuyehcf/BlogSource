---
title: Java 锁机制简介
date: 2017-07-02 22:57:53
tags:
categories:
- Java 锁机制
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言
本篇博客对Java中与 __锁__ 有关的概念进行了整理，大致上分为如下几个部分

* Java内建锁机制
* JVM对内建锁机制的优化
* 自旋锁及其相关变体
* AQS框架

__所有的分析仅基于个人的理解，若有不正之处，请谅解和批评指正，不胜感激！！！__

参考文献

* [1-偏向锁，轻量级锁，自旋锁，重量级锁的详细介绍](http://www.cnblogs.com/wade-luffy/p/5969418.html)
* [2-synchronized实现原理](http://www.cnblogs.com/pureEve/p/6421273.html)
* [3-几种锁算法的实现](https://segmentfault.com/a/1190000002881664)

# 2 Java内建锁机制
## 2.1 synchronized
Java中每一个对象都可以作为锁，这是 synchronized实现同步的基础

* synchronized修饰普通方法，锁是当前实例对象
* synchronized修饰静态方法，锁是当前类的Class对象
* synchronized同步方法块，锁是括号里面的对象

synchronized可以保证方法或者代码块在运行时，同一时刻只有一个方法可以进入到临界区，同时它还可以保证共享变量的内存可见性(同步代码块结束后从工作内存刷新到主内存中)

synchronized是重量级锁，重量级锁通过对象内部的监视器(monitor)实现，其中monitor的本质是依赖于底层操作系统的Mutex Lock实现，操作系统实现线程之间的切换需要从用户态到内核态的切换，切换成本非常高

当退出或者抛出异常时必须要释放锁，synchronized代码块能自动保证这一点

# 3 JVM对内建锁机制的优化

## 3.1 锁消除
为了保证数据的完整性，我们在进行操作时需要对这部分操作进行同步控制，但是在有些情况下，JVM检测到不可能存在共享数据竞争，这是JVM会对这些同步锁进行锁消除，锁消除可以节省毫无意义的请求锁/释放锁的时间。锁消除的依据是逃逸分析的数据支持(逃逸分析的另一用处就是让对象在栈上而非堆中分配空间以提高效率)
如果不存在竞争，为什么还需要加锁呢？变量是否逃逸，对于虚拟机来说需要使用数据流分析来确定，但是对于我们程序员来说这还不清楚么？我们会在明明知道不存在数据竞争的代码块前加上同步吗？但是有时候程序并不是我们所想的那样：我们虽然没有显式使用锁，但是我们在使用一些JDK的内置API时，如StringBuffer、Vector、HashTable等，这个时候会存在隐形的加锁操作

## 3.2 锁粗化
我们知道在使用同步锁的时候，需要让同步块的作用范围尽可能小—仅在共享数据的实际作用域中才进行同步，这样做的目的是为了使需要同步的操作数量尽可能缩小，如果存在锁竞争，那么等待锁的线程也能尽快拿到锁。

在大多数的情况下，上述观点是正确的。但是如果一系列的连续加锁解锁操作，可能会导致不必要的性能损耗，所以引入锁粗化的概念

锁粗化概念比较好理解，就是将多个连续的加锁、解锁操作连接在一起，扩展成一个范围更大的锁

* 例如：vector每次add的时候都需要加锁操作，JVM检测到对同一个对象(vector)连续加锁、解锁操作，会合并一个更大范围的加锁、解锁操作，即加锁解锁操作会移到for循环之外

## 3.3 Java对象头
首先介绍一下Java对象头，这是理解轻量级锁，偏向锁的基础

## 3.4 轻量级锁
引入轻量级锁的主要目的是 __在多没有多线程竞争的前提下__ ，减少传统的重量级锁使用操作系统互斥量产生的性能消耗。当关闭偏向锁功能或者多个线程竞争偏向锁导致偏向锁升级为轻量级锁，则会尝试获取轻量级锁

__获取锁__

1. 判断当前对象是否处于无锁状态(锁标志位01，偏向锁标志位0)
    * 若是，则JVM首先将在当前线程的栈帧中建立一个名为锁记录(Lock Record)的空间，用于存储锁对象目前的Mark Word的拷贝(官方把这份拷贝加了一个Displaced前缀，即Displaced Mark Word)
    * 否则执行步骤(3)
2. JVM利用CAS操作尝试将对象的Mark Word更新为指向Lock Record的指针
    * 如果成功表示竞争到锁，则将锁标志位变成00(表示此对象处于轻量级锁状态)，执行同步操作
    * 如果失败则执行步骤(3)
3. 判断当前对象的Mark Word是否指向当前线程的栈帧
    * 如果是则表示当前线程已经持有当前对象的锁，则直接执行同步代码块
    * 否则只能说明该锁对象已经被其他线程抢占了，这时轻量级锁需要膨胀为重量级锁，锁标志位变成10，后面等待的线程将会进入阻塞状态

__释放锁__

1. 取出在获取轻量级锁保存在Displaced Mark Word中的数据
2. 用CAS操作将取出的数据替换当前对象的Mark Word中
    * 如果成功，则说明释放锁成功
    * 否则执行(3)
3. 如果CAS操作替换失败，说明有其他线程尝试获取该锁，则需要在释放锁的同时唤醒被挂起的线程

![](/images/Java-锁机制简介/轻量级锁膨胀流程图.png)

## 3.5 偏向锁
引入偏向锁主要目的是：为了在无多线程竞争的情况下尽量减少不必要的轻量级锁执行路径(CAS原子指令)。
那么偏向锁是如何来减少不必要的CAS操作呢？我们可以查看Mark work的结构就明白了。只需要检查是否为偏向锁、锁标识为以及ThreadID即可
__获取锁__

1. 检测Mark Word是否为可偏向状态(锁标识位01，偏向锁标志位1)
2. 若为可偏向状态，则测试线程ID是否为当前线程ID
    * 如果是，则执行步骤(5)
    * 否则执行步骤(3)
3. 如果线程ID不为当前线程ID，则通过CAS操作竞争锁
    * 竞争成功，将Mark Word的线程ID替换为当前线程ID，执行步骤(5)
    * 否则执行步骤(4)
4. 通过CAS竞争锁失败，证明当前存在多线程竞争情况，当到达全局安全点，获得偏向锁的线程被挂起，偏向锁升级为轻量级锁，然后被阻塞在安全点的线程继续往下执行同步代码块
5. 执行同步代码块

__释放锁__：偏向锁的释放采用了一种只有竞争才会释放锁的机制，线程是不会主动去释放偏向锁，需要等待其他线程来竞争。偏向锁的撤销需要等待全局安全点(这个时间点是上没有正在执行的代码)。其步骤如下

1. 暂停拥有偏向锁的线程，判断锁对象石是否还处于被锁定状态
2. 撤销偏向锁，恢复到无锁状态(01)或者轻量级锁的状态

![](/images/Java-锁机制简介/偏向锁膨胀流程图.png)

## 3.6 重量级锁
重量锁在JVM中又叫对象监视器(Monitor)，它很像C中的Mutex，除了具备Mutex(0|1)互斥的功能，它还负责实现了Semaphore(信号量)的功能，也就是说它至少包含一个竞争锁的队列，和一个信号阻塞队列(wait队列)，前者负责做互斥，后一个用于做线程同步
重量级锁是使用操作系统互斥量来实现的

## 3.7 总结
偏向锁

* 优点：加锁和解锁不需要额外的消耗，和执行非同步方法比仅存在纳秒级的差距
* 缺点：如果线程间存在锁竞争，会带来额外的锁撤销的消耗
* 场景：适用于只有一个线程访问同步块场景

轻量级锁

* 优点竞争的线程不会阻塞，提高了程序的响应速度
* 缺点：如果始终得不到锁竞争的线程使用自旋会消耗CPU
* 场景：追求响应时间，锁占用时间很短

重量级锁

* 优点：线程竞争不使用自旋，不会消耗CPU
* 缺点：线程阻塞，响应时间缓慢
* 场景：追求吞吐量,锁占用时间较长

# 4 自旋锁及其相关变体

## 4.1 自旋锁
线程的阻塞和唤醒需要CPU从用户态转为核心态，频繁的阻塞和唤醒对CPU来说是一件负担很重的工作，势必会给系统的并发性能带来很大的压力。同时我们发现在许多应用上面，对象锁的锁状态只会持续很短一段时间，为了这一段很短的时间频繁地阻塞和唤醒线程是非常不值得的。所以引入自旋锁

所谓自旋锁，就是让该线程等待一段时间，不会被立即挂起，看持有锁的线程是否会很快释放锁。怎么等待呢？执行一段无意义的循环即可(自旋)

自旋等待不能替代阻塞，虽然它可以避免线程切换带来的开销，但是它占用了处理器的时间

* 如果持有锁的线程很快就释放了锁，那么自旋的效率就非常好
* 反之，自旋的线程就会白白消耗掉处理的资源，它不会做任何有意义的工作，典型的占着茅坑不拉屎，这样反而会带来性能上的浪费
* 所以说，自旋等待的时间(自旋的次数)必须要有一个限度，如果自旋超过了定义的时间仍然没有获取到锁，则应该被挂起。

一个简单的自旋锁Demo
```Java
public class SpinLockDemo {

    private AtomicInteger state = new AtomicInteger();

    public void lock() {
        for (; ; ) {
            if (state.compareAndSet(0, 1)) {
                break;
            }
        }
    }

    public void unlock() {
        if (!state.compareAndSet(1, 0)) {
            throw new RuntimeException();
        }
    }
}
```

自旋锁优劣势总结

* 优势
    * lock-free：不加锁(没有唤醒阻塞的系统开销)
* 劣势
    * CPU开销大
    * 无法响应中断
    * 不支持FIFO

## 4.2 Ticket Lock
Ticket Lock是自旋锁的改进，这种锁机制可以类比去银行办理业务，一开始，我们会拿一个号，然后等着，直到办理业务的工作人员叫到我们的号，然后我们去办理业务

一个简单的Ticket Lock的例子
```Java
public class TicketLockDemo {

    private AtomicInteger serviceNum = new AtomicInteger();//当前服务号

    private AtomicInteger ticketNum = new AtomicInteger();//排队号

    public int lock() {
        //排队前拿个号
        int myTicketNum = ticketNum.getAndIncrement();

        while (serviceNum.get() != myTicketNum) {

        }

        System.out.println(Thread.currentThread() + " is hold the lock, order: " + myTicketNum);

        return myTicketNum;
    }

    public void unlock(int myTicket) {
        int next = myTicket + 1;
        if (!serviceNum.compareAndSet(myTicket, next)) {
            throw new RuntimeException();
        }
        System.out.println(Thread.currentThread() + " is release the lock\n");
    }
}
```

Ticket Lock优劣势总结

* 优势
    * 支持FIFO
    * lock-free：不加锁(没有唤醒阻塞的系统开销)
* 劣势
    * CPU开销大
    * 无法响应中断
    * 多个公共线程在共享资源上自旋，开销较大

## 4.3 CLH锁
CLH锁(Craig，Landin，and Hagersten locks)在Ticket锁的机制上进行了优化，让每个线程在 __非共享变量上自旋__ ，减少了共享变量的同步开销

CLH锁的简单Demo
```Java
class QNode {
    volatile boolean locked;
}

public class CLHLockDemo {
    AtomicReference<QNode> tail = new AtomicReference<QNode>(new QNode());
    ThreadLocal<QNode> currNode;

    public CLHLockDemo() {
        tail = new AtomicReference<QNode>(new QNode());
        currNode = new ThreadLocal<QNode>() {
            protected QNode initialValue() {
                return new QNode();
            }
        };
    }

    public void lock() {
        QNode curr = this.currNode.get();
        curr.locked = true;

        //将当前节点通过CAS操作加到队列尾，返回原先的队列尾，作为它的前继节点
        QNode prev = tail.getAndSet(curr);

        while (prev.locked) {
            //在前继节点的状态上自旋
        }
    }

    public void unlock() {
        QNode qnode = currNode.get();
        qnode.locked = false;
    }
}
```

# 5 AQS框架

AQS框架是CLH锁的变体，AQS相比于CLH锁，AQS采用了自旋与阻塞相结合的策略，提高整体的性能，既不会出现自旋锁盲目自旋消耗大量CPU的情况，也不会出线程频繁的阻塞和唤醒

具体AQS源码剖析，请移步 [Java concurrent AQS 源码剖析](https://liuyehcf.github.io/2017/07/02/Java-concurrent-AQS-%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90/)
