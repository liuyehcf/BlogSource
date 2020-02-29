---
title: Java-concurrent-CyclicBarrier-源码剖析
date: 2017-07-13 16:30:27
tags: 
- 原创
categories: 
- Java
- Java Concurrent
- Source Code Analysis
---

__阅读更多__

<!--more-->

# 1 前言

CyclicBarrier是一个同步辅助类，它允许一组线程互相等待，直到到达某个公共屏障点(common barrier point)。在涉及一组固定大小的线程的程序中，这些线程必须不时地互相等待，此时CyclicBarrier很有用。因为该barrier在释放等待线程后可以重用，所以称它为循环的barrier

# 2 内部类

该内部类用于标记一次Barrier生命周期的状态

1. true：Barrier被打断，调用await()方法将会抛出BrokenBarrierException异常
1. false：Barrier有效

一次Barrier生命周期中Barrier的状态不会影响到下一次生命周期

```java
    /**
     * Each use of the barrier is represented as a generation instance.
     * The generation changes whenever the barrier is tripped, or
     * is reset. There can be many generations associated with threads
     * using the barrier - due to the non-deterministic way the lock
     * may be allocated to waiting threads - but only one of these
     * can be active at a time (the one to which {@code count} applies)
     * and all the rest are either broken or tripped.
     * There need not be an active generation if there has been a break
     * but no subsequent reset.
     */
    private static class Generation {
        boolean broken = false;
    }
```

# 3 字段

```java
    /** The lock for guarding barrier entry */
    private final ReentrantLock lock = new ReentrantLock();
    /** Condition to wait on until tripped */
    private final Condition trip = lock.newCondition();
    /** The number of parties */
    private final int parties;
    /* The command to run when tripped */
    private final Runnable barrierCommand;
    /** The current generation */
    private Generation generation = new Generation();

    /**
     * Number of parties still waiting. Counts down from parties to 0
     * on each generation.  It is reset to parties on each new
     * generation or when broken.
     */
    private int count;
```

* __lock__：重入锁
* __trip__：条件对象，是AQS-ConditionObject内部类
* __parties__
* __barrierCommand__：为了增加CyclicBarrier的生命周期，当足够多的线程通过屏障时，调用相应的处理逻辑，可由构造方法传入
* __generation__：标记本次生命周期的Barrier的状态，如果为true，则Barrier失效。到了next Generation后，又会重新指向一个新的Generation对象
* __count__：计数值

# 4 重要方法

## 4.1 构造方法

```java
    /**
     * Creates a new {@code CyclicBarrier} that will trip when the
     * given number of parties (threads) are waiting upon it, and
     * does not perform a predefined action when the barrier is tripped.
     *
     * @param parties the number of threads that must invoke {@link #await}
     *        before the barrier is tripped
     * @throws IllegalArgumentException if {@code parties} is less than 1
     */
    public CyclicBarrier(int parties) {
        this(parties, null);
    }
```

```java
    /**
     * Creates a new {@code CyclicBarrier} that will trip when the
     * given number of parties (threads) are waiting upon it, and which
     * will execute the given barrier action when the barrier is tripped,
     * performed by the last thread entering the barrier.
     *
     * @param parties the number of threads that must invoke {@link #await}
     *        before the barrier is tripped
     * @param barrierAction the command to execute when the barrier is
     *        tripped, or {@code null} if there is no action
     * @throws IllegalArgumentException if {@code parties} is less than 1
     */
    public CyclicBarrier(int parties, Runnable barrierAction) {
        if (parties <= 0) throw new IllegalArgumentException();
        this.parties = parties;
        this.count = parties;
        this.barrierCommand = barrierAction;
    }
```

## 4.2 await

await方法阻塞当前线程直至累计有count（构造方法的参数）个线程阻塞在了await方法上

```java
    /**
     * Waits until all {@linkplain #getParties parties} have invoked
     * {@code await} on this barrier.
     *
     * <p>If the current thread is not the last to arrive then it is
     * disabled for thread scheduling purposes and lies dormant until
     * one of the following things happens:
     * <ul>
     * <li>The last thread arrives; or
     * <li>Some other thread {@linkplain Thread#interrupt interrupts}
     * the current thread; or
     * <li>Some other thread {@linkplain Thread#interrupt interrupts}
     * one of the other waiting threads; or
     * <li>Some other thread times out while waiting for barrier; or
     * <li>Some other thread invokes {@link #reset} on this barrier.
     * </ul>
     *
     * <p>If the current thread:
     * <ul>
     * <li>has its interrupted status set on entry to this method; or
     * <li>is {@linkplain Thread#interrupt interrupted} while waiting
     * </ul>
     * then {@link InterruptedException} is thrown and the current thread's
     * interrupted status is cleared.
     *
     * <p>If the barrier is {@link #reset} while any thread is waiting,
     * or if the barrier {@linkplain #isBroken is broken} when
     * {@code await} is invoked, or while any thread is waiting, then
     * {@link BrokenBarrierException} is thrown.
     *
     * <p>If any thread is {@linkplain Thread#interrupt interrupted} while waiting,
     * then all other waiting threads will throw
     * {@link BrokenBarrierException} and the barrier is placed in the broken
     * state.
     *
     * <p>If the current thread is the last thread to arrive, and a
     * non-null barrier action was supplied in the constructor, then the
     * current thread runs the action before allowing the other threads to
     * continue.
     * If an exception occurs during the barrier action then that exception
     * will be propagated in the current thread and the barrier is placed in
     * the broken state.
     *
     * @return the arrival index of the current thread, where index
     *         {@code getParties() - 1} indicates the first
     *         to arrive and zero indicates the last to arrive
     * @throws InterruptedException if the current thread was interrupted
     *         while waiting
     * @throws BrokenBarrierException if <em>another</em> thread was
     *         interrupted or timed out while the current thread was
     *         waiting, or the barrier was reset, or the barrier was
     *         broken when {@code await} was called, or the barrier
     *         action (if present) failed due to an exception
     */
    public int await() throws InterruptedException, BrokenBarrierException {
        try {
            return dowait(false, 0L);
        } catch (TimeoutException toe) {
            throw new Error(toe); //cannot happen
        }
    }
```

### 4.2.1 dowait

dowait方法是实现CyclicBarrier语义的主要方法

```java
    /**
     * Main barrier code, covering the various policies.
     */
    private int dowait(boolean timed, long nanos)
        throws InterruptedException, BrokenBarrierException,
               TimeoutException {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            final Generation g = generation;

            //如果是broken状态，则抛出BrokenBarrierException异常。该bool值在breakBarrier方法中被设置为true
            if (g.broken)
                throw new BrokenBarrierException();

            //如果被中断了则设置broken为true，然后抛出InterruptedException异常
            if (Thread.interrupted()) {
                breakBarrier();
                throw new InterruptedException();
            }

            //递减count
            int index = --count;
            //如果index为0，说明有足够多的线程调用了await方法，此时应该放行所有线程
            if (index == 0) {  //tripped
                boolean ranAction = false;
                try {
                    final Runnable command = barrierCommand;
                    //执行一些额外的逻辑
                    if (command != null)
                        command.run();
                    //如果在执行run方法中抛出了任何异常，则ranAction为false状态
                    ranAction = true;
                    //进入下一个生命周期
                    nextGeneration();
                    return 0;
                } finally {
                    if (!ranAction)
                        //将Barrier的当前生命周期的状态标记为不可用
                        breakBarrier();
                }
            }

            //阻塞当前线程直至被中断，打断或者超时
            //loop until tripped, broken, interrupted, or timed out
            for (;;) {
                try {
                    //如果不允许超时，将当前线程直接挂起，阻塞在条件对象trip的condition queue(ConditionObject中维护的等待队列)中
                    if (!timed)
                        trip.await();
                    //如果允许超时，阻塞在条件对象trip的condition queue中一段时间
                    else if (nanos > 0L)
                        nanos = trip.awaitNanos(nanos);
                } catch (InterruptedException ie) {
                    //当Barrier处于有效状态
                    if (g == generation && ! g.broken) {
                        //设置为打断状态
                        breakBarrier();
                        throw ie;
                    } else {
                        //We're about to finish waiting even if we had not
                        //been interrupted, so this interrupt is deemed to
                        //"belong" to subsequent execution.
                        Thread.currentThread().interrupt();
                    }
                }

                //如果Barrier被打断，则抛出BrokenBarrierException异常
                if (g.broken)
                    throw new BrokenBarrierException();

                //意味着调用await时处于上一个生命周期，而此时却进入了下一个生命周期中
                if (g != generation)
                    return index;

                //允许超时，并且已经超时
                if (timed && nanos <= 0L) {
                    breakBarrier();
                    throw new TimeoutException();
                }
            }
        } finally {
            lock.unlock();
        }
    }
```

### 4.2.2 nextGeneration

该方法使得CyclicBarrier进入下一次生命周期，唤醒阻塞在trip上的线程，并且重置所有状态

```java
    /**
     * Updates state on barrier trip and wakes up everyone.
     * Called only while holding lock.
     */
    private void nextGeneration() {
        //signal completion of last generation
        //唤醒所有阻塞在condition queue中的线程，即那些阻塞在await方法上的线程
        trip.signalAll();
        //set up next generation
        //这就是CyclicBarrier可重用的原因
        count = parties;
        //重新生成Generation
        generation = new Generation();
    }
```

## 4.3 isBroken

检查当前Barrier生命周期是否有效

```java
    /**
     * Queries if this barrier is in a broken state.
     *
     * @return {@code true} if one or more parties broke out of this
     *         barrier due to interruption or timeout since
     *         construction or the last reset, or a barrier action
     *         failed due to an exception; {@code false} otherwise.
     */
    public boolean isBroken() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return generation.broken;
        } finally {
            lock.unlock();
        }
    }
```

## 4.4 reset

重置Barrier，使其进入下一个生命周期。对于那些阻塞在上一个生命周期中的线程，会通过nextGeneration方法进行唤醒

```java
    /**
     * Resets the barrier to its initial state.  If any parties are
     * currently waiting at the barrier, they will return with a
     * {@link BrokenBarrierException}. Note that resets <em>after</em>
     * a breakage has occurred for other reasons can be complicated to
     * carry out; threads need to re-synchronize in some other way,
     * and choose one to perform the reset.  It may be preferable to
     * instead create a new barrier for subsequent use.
     */
    public void reset() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            breakBarrier();   //break the current generation
            nextGeneration(); //start a new generation
        } finally {
            lock.unlock();
        }
    }
```

## 4.5 getNumberWaiting

检查有多少个线程阻塞在await方法的调用中

```java
    /**
     * Returns the number of parties currently waiting at the barrier.
     * This method is primarily useful for debugging and assertions.
     *
     * @return the number of parties currently blocked in {@link #await}
     */
    public int getNumberWaiting() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return parties - count;
        } finally {
            lock.unlock();
        }
    }
```
