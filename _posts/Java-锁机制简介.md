---
title: Java-锁机制简介
date: 2017-07-02 22:57:53
tags: 
- 原创
categories: 
- Java
- Java 并发
- Java 锁机制
---

__阅读更多__

<!--more-->

# 1 前言

本篇博客对Java中与 __锁__ 有关的概念进行了整理，大致上分为如下几个部分

* Java内建锁机制及其优化
* 自旋锁及其相关变体
* AQS框架

# 2 Java内建锁机制及其优化

请参考本篇博客{% post_link Java-synchronized的实现原理与应用 %}

# 3 自旋锁及其相关变体

## 3.1 自旋锁

线程的阻塞和唤醒需要CPU从用户态转为核心态，频繁的阻塞和唤醒对CPU来说是一件负担很重的工作，势必会给系统的并发性能带来很大的压力。同时我们发现在许多应用上面，对象锁的锁状态只会持续很短一段时间，为了这一段很短的时间频繁地阻塞和唤醒线程是非常不值得的。所以引入自旋锁

所谓自旋锁，就是让该线程等待一段时间，不会被立即挂起，看持有锁的线程是否会很快释放锁。怎么等待呢？执行一段无意义的循环即可(自旋)

自旋等待不能替代阻塞，虽然它可以避免线程切换带来的开销，但是它占用了处理器的时间

* 如果持有锁的线程很快就释放了锁，那么自旋的效率就非常好
* 反之，自旋的线程就会白白消耗掉处理的资源，它不会做任何有意义的工作，典型的占着茅坑不拉屎，这样反而会带来性能上的浪费
* 所以说，自旋等待的时间(自旋的次数)必须要有一个限度，如果自旋超过了定义的时间仍然没有获取到锁，则应该被挂起

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

## 3.2 Ticket Lock

Ticket Lock是自旋锁的改进，这种锁机制可以类比去银行办理业务，一开始，我们会拿一个号，然后等着，直到办理业务的工作人员叫到我们的号，然后我们去办理业务

一个简单的Ticket Lock的例子
```Java
public class TicketLockDemo {

    private AtomicInteger serviceNum = new AtomicInteger();// 当前服务号

    private AtomicInteger ticketNum = new AtomicInteger();// 排队号

    public int lock() {
        // 排队前拿个号
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

## 3.3 CLH锁

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

        // 将当前节点通过CAS操作加到队列尾，返回原先的队列尾，作为它的前继节点
        QNode prev = tail.getAndSet(curr);

        while (prev.locked) {
            // 在前继节点的状态上自旋
        }
    }

    public void unlock() {
        QNode qnode = currNode.get();
        qnode.locked = false;
    }
}
```

# 4 AQS框架

AQS框架是CLH锁的变体，AQS相比于CLH锁，AQS采用了自旋与阻塞相结合的策略，提高整体的性能，既不会出现自旋锁盲目自旋消耗大量CPU的情况，也不会出线程频繁的阻塞和唤醒

具体AQS源码剖析，请移步 {% post_link Java-concurrent-AQS-源码剖析 %}

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [1-偏向锁，轻量级锁，自旋锁，重量级锁的详细介绍](http://www.cnblogs.com/wade-luffy/p/5969418.html)
* [2-synchronized实现原理](http://www.cnblogs.com/pureEve/p/6421273.html)
* [3-几种锁算法的实现](https://segmentfault.com/a/1190000002881664)
* [Java并发编程：Synchronized底层优化（偏向锁、轻量级锁）](http://www.cnblogs.com/paddix/p/5405678.html)
