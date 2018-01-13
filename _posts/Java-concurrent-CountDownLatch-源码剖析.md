---
title: Java-concurrent-CountDownLatch-源码剖析
date: 2017-07-13 16:30:01
tags: 
- 原创
categories: 
- Java
- Java 并发
- Java concurrent 源码剖析
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

CountDownLatch是通过一个计数器来实现的，计数器的初始值为线程的数量。每当一个线程完成了自己的任务后，计数器的值就会减1。当计数器值到达0时，它表示所有的线程已经完成了任务，然后在闭锁上等待的线程就可以恢复执行任务。

# 2 内部类Sync

CountDownLatch会阻塞调用await的线程，而concurrent包下最基础的类就是AbstractQueuedSynchronizer(AQS)，CountDownLatch包含一个Sync内部类，该内部类继承了AQS框架，实现了锁的一个原语。由于CountDownLatch只是在AQS基础上增加了一些额外的语义，而CountDownLatch本身的源码并不多，要想深入理解CountDownLatch还是要先了解AQS的机制以及源码 {% post_link Java-concurrent-AQS-源码剖析 %}

* Sync内部类使用的是AQS中的共享模式

```Java
    /**
     * Synchronization control For CountDownLatch.
     * Uses AQS state to represent count.
     */
    private static final class Sync extends AbstractQueuedSynchronizer {
        private static final long serialVersionUID = 4982264981922014374L;

        // 构造方法，设置资源的数量
        Sync(int count) {
            setState(count);
        }

        int getCount() {
            return getState();
        }

        // 利用的是AQS框架中的共享模式。返回非负数说明获取成功，返回负数说明获取失败。
        // 该方法的逻辑是，当且仅当资源状态为0时才获取成功
        protected int tryAcquireShared(int acquires) {
            return (getState() == 0) ? 1 : -1;
        }

        // 共享模式下的资源释放方法
        protected boolean tryReleaseShared(int releases) {
            // Decrement count; signal when transition to zero
            for (;;) {
                int c = getState();
                if (c == 0)
                    return false;
                int nextc = c-1;
                if (compareAndSetState(c, nextc))
                    return nextc == 0;
            }
        }
    }
```

__注意到，资源状态只减不增，因此CountDownLatch是无法重用的，是一次性的__

## 2.1 为什么要使用共享模式

看完Sync的源码，我们来考虑为什么Sync要使用AQS提供的共享模式？

> 所谓共享模式是指，在sync queue(AQS内部的同步阻塞队列)中的节点会陆续通过临界点，直至资源消耗殆尽

当count个线程执行countDown方法后，资源的状态是0，而tryAcquireShared方法告诉我们，只要资源状态是0，便能够获取到资源。也就意味着，只要资源状态是0，sync queue中的节点__全部__都会通过临界点。因此CountDownLatch可以实现任意多个线程阻塞在await方法上，直到count个线程调用countDown方法，所有这些阻塞在await方法上的线程都会通过

那么独占模式就不能实现唤醒多个阻塞在await方法上的线程吗？不能，因为在独占模式下，每次释放锁，只能唤醒一个在sync queue中等待的线程(假设有线程排队在sync queue中)。要想唤醒多个阻塞在await方法上的线程，只能不停地触发AQS的release方法。因此，采用共享模式能很好的解决这个问题，共享模式的主要特征就是能够在资源可获取时不断地让sync queue中的节点通过临界点

下面就要看看CountDownLatch是如何利用一个共享模式的Sync来实现CountDownLatch的语义

# 3 字段

CountDownLatch仅有一个字段，即上面的内部类Sync的实例。阻塞操作是通过这个实例来完成的

```Java
private final Sync sync;
```

# 4 重要方法

## 4.1 构造方法

CountDownLatch的构造方法接受一个int型的参数，该数字的含义是：当count个线程调用过countDown后，那个调用await的线程才会从阻塞中被唤醒。即释放锁需要的资源数量

```Java
    /**
     * Constructs a {@code CountDownLatch} initialized with the given count.
     *
     * @param count the number of times {@link #countDown} must be invoked
     *        before threads can pass through {@link #await}
     * @throws IllegalArgumentException if {@code count} is negative
     */
    public CountDownLatch(int count) {
        if (count < 0) throw new IllegalArgumentException("count < 0");
        // 初始化sync，并且设置资源数量为count
        this.sync = new Sync(count);
    }
```

## 4.2 countDown

countDown该方法用于释放资源，且每次调用只释放1个资源

```Java
    /**
     * Decrements the count of the latch, releasing all waiting threads if
     * the count reaches zero.
     *
     * <p>If the current count is greater than zero then it is decremented.
     * If the new count is zero then all waiting threads are re-enabled for
     * thread scheduling purposes.
     *
     * <p>If the current count equals zero then nothing happens.
     */
    public void countDown() {
        sync.releaseShared(1);
    }
```

## 4.3 await

该方法会尝试利用sync获取资源，当获取不到资源时便会阻塞。当有count个线程调用countDown后，调用await的线程会从阻塞状态中被唤醒

```Java
    /**
     * Causes the current thread to wait until the latch has counted down to
     * zero, unless the thread is {@linkplain Thread#interrupt interrupted}.
     *
     * <p>If the current count is zero then this method returns immediately.
     *
     * <p>If the current count is greater than zero then the current
     * thread becomes disabled for thread scheduling purposes and lies
     * dormant until one of two things happen:
     * <ul>
     * <li>The count reaches zero due to invocations of the
     * {@link #countDown} method; or
     * <li>Some other thread {@linkplain Thread#interrupt interrupts}
     * the current thread.
     * </ul>
     *
     * <p>If the current thread:
     * <ul>
     * <li>has its interrupted status set on entry to this method; or
     * <li>is {@linkplain Thread#interrupt interrupted} while waiting,
     * </ul>
     * then {@link InterruptedException} is thrown and the current thread's
     * interrupted status is cleared.
     *
     * @throws InterruptedException if the current thread is interrupted
     *         while waiting
     */
    public void await() throws InterruptedException {
        sync.acquireSharedInterruptibly(1);
    }
```
