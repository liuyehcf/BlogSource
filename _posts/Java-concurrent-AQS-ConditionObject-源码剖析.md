---
title: Java-concurrent-AQS-ConditionObject-源码剖析
date: 2017-07-02 22:51:51
tags: 
- 原创
categories: 
- Java
- Java Concurrent
- Source Code Analysis
---

**阅读更多**

<!--more-->

# 1 前言

Java语言本身提供了基于Object的wait/notify机制，任何Java Object都可以进行加锁/解锁，并且可以作为一个Monitor进行wait/notify操作，AQS框架也提供类机制，通过AQS内部类ConditionObject来实现
本篇博文针对ConditionObject的源码进行分析，有关AQS的源码分析请参考另一篇博客 {% post_link Java-AQS-SourceAnalysis %}
所有的分析仅基于个人的理解，若有不正之处，请谅解和批评指正，不胜感激！！！

# 2 Condition接口

```java
public interface Condition {

    //在条件变量上等待，直至signal或者被interrupt
    void await() throws InterruptedException;

    //在条件变量上等待，直至signal，并且无视interrupt，这一点就比基于Object的wait更灵活
    void awaitUninterruptibly();

    //在条件变量上等待，直至signal或者被interrupt或者直至超时
    long awaitNanos(long nanosTimeout) throws InterruptedException;

    //在条件变量上等待，直至signal或者被interrupt或直至超时
    boolean await(long time, TimeUnit unit) throws InterruptedException;

    //在条件变量上等待，直至signal或者被interrupt或直至超时
    boolean awaitUntil(Date deadline) throws InterruptedException;

    //唤醒某个在条件变量上阻塞的线程，类似于notify
    void signal();

    //唤醒某个在条件变量上阻塞的线程，类似于notifyAll
    void signalAll();
}
```
Condition接口定义了一系列monitor methods，正如AQS作为synchronized的替代者，一个Condition对象作为Object monitor的替代者
我们不妨先思考一下，实现一个Condition大致上需要哪些结构

* 首先，Condition对象必须提供一个阻塞队列，用于放置那些阻塞与当前Condition对象上的线程
* 其次，Condition对象还需要提供一个同步队列，用于放置那些收到signal的线程，这些线程将会竞争锁(或者资源)

在AQS框架中，ConditionObject的实现确实需要这两个队列，阻塞队列(我称之为condition queue)是ConditionObject自身维护的，而同步队列直接依赖于AQS的sync queue，因此ConditionObject作为内部类存在于AQS中，以便于ConditionObject可以直接利用AQS实现的sync queue
**强调一点：AQS的独占模式才支持ConditionObject**

# 3 源码分析

## 3.1 字段

```java
        /** First node of condition queue. */
        private transient Node firstWaiter;
        /** Last node of condition queue. */
        private transient Node lastWaiter;
```
ConditionObject就两个字段，一个是condition queue头结点，另一个则是condition queue尾节点
ConditionObject利用了AQS中的Node静态内部类用于封装节点。**指的注意的是，对于位于condition queue中的节点而言，这些节点的Node#prev以及Node#next字段是无用的，也就是null，condition queue是利用Node#nextWaiter来连接整个conditoin queue的**

## 3.2 await

该方法类似于Object#wait方法，让当前线程在该ConditionObject上阻塞，直至被signal(类似于Object的notify/notifyAll)或者被中断，必须在持有锁的状态下才能调用该方法，否则会引发异常

```java
        /**
         * Implements interruptible condition wait.
         * <ol>
         * <li> If current thread is interrupted, throw InterruptedException.
         * <li> Save lock state returned by {@link #getState}.
         * <li> Invoke {@link #release} with saved state as argument,
         *      throwing IllegalMonitorStateException if it fails.
         * <li> Block until signalled or interrupted.
         * <li> Reacquire by invoking specialized version of
         *      {@link #acquire} with saved state as argument.
         * <li> If interrupted while blocked in step 4, throw InterruptedException.
         * </ol>
         */
        public final void await() throws InterruptedException {
            if (Thread.interrupted())
                throw new InterruptedException();
            //将节点添加到当前Condition对象的condition queue中
            Node node = addConditionWaiter();
            //释放当前线程持有的资源，因此await方法时，必须处于持有锁的状态，与wait类似(wait/notify必须位于synchronize块内部)
            int savedState = fullyRelease(node);
            //用于记录中断模式
            int interruptMode = 0;
            //循环，直至位于sync queue中或者被中断
            while (!isOnSyncQueue(node)) {
                LockSupport.park(this);
                if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                    break;
            }
            //下面进行一些后续处理
            //可以看出，当前线程通过acquireQueued来获取锁状态直至成功，该方法返回值指示该过程是否被中断
            if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
                interruptMode = REINTERRUPT;
            //这里为什么有可能不是null? signal方法会将节点的nextWaiter字段赋值为null，但是如果因为中断而退出wihle循环，则此字段没有置空
            if (node.nextWaiter != null) //clean up if cancelled
                unlinkCancelledWaiters();
            //根据中断模式，进行相应的中断处理，抛出异常或者回复中断现场等
            if (interruptMode != 0)
                reportInterruptAfterWait(interruptMode);
        }
```
接下来，逐个分析上述方法中调用的子方法。首先是addConditionWaiter()方法，源码如下

```java
        /**
         * Adds a new waiter to wait queue.
         * @return its new wait node
         */
        private Node addConditionWaiter() {
            Node t = lastWaiter;
            //If lastWaiter is cancelled, clean out.
            //如果condition queue尾节点不是CONDITION，那么该节点状态必然是CANCEL，因为在condition queue中节点只有这两种状态
            if (t != null && t.waitStatus != Node.CONDITION) {
                //从后向前清除那些已经CANCEL的节点
                unlinkCancelledWaiters();
                t = lastWaiter;
            }
            //将当前线程封装成Node节点
            Node node = new Node(Thread.currentThread(), Node.CONDITION);
            //condition queue为空，进行初始化即可
            if (t == null)
                firstWaiter = node;
            //将当前节点连接到condition queue最后即可
            else
                t.nextWaiter = node;
            lastWaiter = node;
            return node;
        }
```
可以看出该方法中的所有赋值操作均不需要加锁，也不需要CAS操作，因为处于独占模式下，当前线程持有锁，那么只有该线程能够执行这些赋值操作，因此是线程安全的。因此await方法必须在持有锁的状态下才能进行调用，另外仅支持AQS独占模式

然后是fullyRelease方法，该方法并非ConditionObject的方法，而是AQS的方法，该方法调用独占模式下的release来释放资源

```java
    /**
     * Invokes release with current state value; returns saved state.
     * Cancels node and throws exception on failure.
     * @param node the condition node for this wait
     * @return previous sync state
     */
    final int fullyRelease(Node node) {
        boolean failed = true;
        try {
            //当前线程持有的资源
            int savedState = getState();
            //释放当前线程持有的资源，如果不释放，那么其他线程是无法获取锁的
            if (release(savedState)) {
                failed = false;
                return savedState;
            } else {
                //如果当前线程不处于锁定状态，那么release将会失败，抛出IllegalMonitorStateException异常
                throw new IllegalMonitorStateException();
            }
        } finally {
            if (failed)
                node.waitStatus = Node.CANCELLED;
        }
    }
```

isOnSyncQueue方法用于判断节点是否位于sync queue，该方法也是AQS的方法而非ConditionObject方法。如果发现节点位于sync queue，说明另一个线程执行了signal/signalAll，节点从condition queue移动到sync queue，此时再次排队竞争锁，如果位于condition queue，那么说明条件还未成立，需要继续阻塞自己

```java
    /**
     * Returns true if a node, always one that was initially placed on
     * a condition queue, is now waiting to reacquire on sync queue.
     * @param node the node
     * @return true if is reacquiring
     */
    final boolean isOnSyncQueue(Node node) {
        //如果节点的状态是CONDITION，那么意味着节点位于condition queue中
        //如果节点的prev为null，那么节点位于condition queue中
        //sync queue头结点的prev字段也是null(setHead方法会将该字段设为null)，但是这种特殊情况在这里是不会出现的，在调用acquireQueued方法之前，节点是不可能获取锁状态的，因此不可能成为头结点
        if (node.waitStatus == Node.CONDITION || node.prev == null)
            return false;
        //如果节点的next字段不为null，说明节点一定位于sync queue中
        //节点的next字段为null，则并不一定说明该节点没有后继，因为Node#next字段是非可靠的。该节点可能通过addWaiter加入到sync queue中(添加操作是通过执行signal方法的线程来完成的)，当前线程在节点的next字段正确赋值之前对其进行了访问
        if (node.next != null) //If has successor, it must be on queue
            return true;

        //节点prev字段不为空，并不一定代表节点位于sync queue中，因为prev字段的赋值操作在CAS操作之前，只有CAS成功之后，节点才会成功入队
        /*
         * node.prev can be non-null, but not yet on queue because
         * the CAS to place it on queue can fail. So we have to
         * traverse from tail to make sure it actually made it.  It
         * will always be near the tail in calls to this method, and
         * unless the CAS failed (which is unlikely), it will be
         * there, so we hardly ever traverse much.
         */
        //从后往前遍历sync queue，查找node节点是否位于sync queue，这种方式是比较慢的，因此在上述判断均不能确定的情况下才会使用
        return findNodeFromTail(node);
    }
```

在while循环中等待时，需要检查当前线程是被unpark正常唤醒还是被interrupt唤醒

```java
        /**
         * Checks for interrupt, returning THROW_IE if interrupted
         * before signalled, REINTERRUPT if after signalled, or
         * 0 if not interrupted.
         */
        private int checkInterruptWhileWaiting(Node node) {
            return Thread.interrupted() ?
                (transferAfterCancelledWait(node) ? THROW_IE : REINTERRUPT) :
                0;
        }
```

transferAfterCancelledWait方法在发生中断时，将节点从condition queue中转移到sync queue中去。该方法是AQS的方法

```java
    /**
     * Transfers node, if necessary, to sync queue after a cancelled wait.
     * Returns true if thread was cancelled before being signalled.
     *
     * @param node the node
     * @return true if cancelled before the node was signalled
     */
    final boolean transferAfterCancelledWait(Node node) {
        //将节点状态改为0后入队，必须由一个线程来完成
        //为什么可能存在竞争？当前线程被中断，于是进入该方法，此时另一个线程恰好执行signal，会进入另一个方法transferForSignal，这两个方法均会执行CAS操作将节点状态从CONDITION改为0
        //或者节点的状态是CANCELLED
        if (compareAndSetWaitStatus(node, Node.CONDITION, 0)) {
            enq(node);
            return true;
        }
        /*
         * If we lost out to a signal(), then we can't proceed
         * until it finishes its enq().  Cancelling during an
         * incomplete transfer is both rare and transient, so just
         * spin.
         */
        //可能出现上述竞争场景，于是等待另一个线程入队操作完毕，这个等待不会很久
        while (!isOnSyncQueue(node))
            Thread.yield();
        return false;
    }
```
可以看出，执行transferAfterCancelledWait方法的线程CAS成功时返回true，中断模式为THROW_IN；失败时返回false，中断模式为REINTERRUPT
注意，因为interrupt而被已送至sync queue的节点，仍然位于condition queue中(其状态不为CONDITION)，其nextWaiter字段不为空，在await方法中会执行unlinkCancelledWaiters方法，来除去这些异常节点

## 3.3 signal

signal方法类似于Object#notify方法，将一个节点(线程)从条件变量的阻塞队列(condition queue)中移动到同步队列中(sync queue)，让该节点重新尝试获取资源

```java
        /**
         * Moves the longest-waiting thread, if one exists, from the
         * wait queue for this condition to the wait queue for the
         * owning lock.
         *
         * @throws IllegalMonitorStateException if {@link #isHeldExclusively}
         *         returns {@code false}
         */
        public final void signal() {
            //同理，执行signal方法的线程必须持有独占锁，否则抛出IllegalMonitorStateException异常
            if (!isHeldExclusively())
                throw new IllegalMonitorStateException();
            //唤醒condition queue中第一个节点
            Node first = firstWaiter;
            if (first != null)
                doSignal(first);
        }
```

下面是doSignal方法源码。该方法调整阻塞队列头结点，并且执行transferForSignal方法将节点移送至sync queue，让其重新入队尝试获取锁

```java
        /**
         * Removes and transfers nodes until hit non-cancelled one or
         * null. Split out from signal in part to encourage compilers
         * to inline the case of no waiters.
         * @param first (non-null) the first node on condition queue
         */
        private void doSignal(Node first) {
            do {
                //这里更新头结点
                if ( (firstWaiter = first.nextWaiter) == null)
                    lastWaiter = null;
                first.nextWaiter = null;
            } 
            //直至transferForSignal成功一次，或者队列为空
            while (!transferForSignal(first) &&
                     (first = firstWaiter) != null);
        }
```

以下是transferForSignal方法，该方法是AQS的方法

```java
    /**
     * Transfers a node from a condition queue onto sync queue.
     * Returns true if successful.
     * @param node the node
     * @return true if successfully transferred (else the node was
     * cancelled before signal)
     */
    final boolean transferForSignal(Node node) {
        /*
         * If cannot change waitStatus, the node has been cancelled.
         */
        //可能存在竞争：另一个线程在执行await时，被中断，然后执行transferAfterCancelledWait方法；当前线程执行signal，然后执行次方法。这两个方法都会通过CAS操作将节的状态从CONDITION改为0
        //或者节点的状态已经是CANCELLED
        if (!compareAndSetWaitStatus(node, Node.CONDITION, 0))
            return false;

        /*
         * Splice onto queue and try to set waitStatus of predecessor to
         * indicate that thread is (probably) waiting. If cancelled or
         * attempt to set waitStatus fails, wake up to resync (in which
         * case the waitStatus can be transiently and harmlessly wrong).
         */
        //通过enq入队(sync queue)，该方法返回node节点的前继节点
        Node p = enq(node);
        int ws = p.waitStatus;
        //若前继节点状态为CANCELLED，或者将前继节点置为SIGNAL失败，那么需要找到前继节点，并将其设为SIGNAL状态后才能安心阻塞，因此唤醒一下，让节点关联的线程去自行处理
        //这里唤醒节点，醒来的地方可能是await方法中的while循环内，紧接着会执行acquireQueued方法
        if (ws > 0 || !compareAndSetWaitStatus(p, ws, Node.SIGNAL))
            LockSupport.unpark(node.thread);
        return true;
    }
```

## 3.4 signalAll

signalAll方法类似于Object的notifyAll方法，该方法唤醒所有阻塞在condition queue中的节点，并将其全部移送至sync queue中

```java
        /**
         * Moves all threads from the wait queue for this condition to
         * the wait queue for the owning lock.
         *
         * @throws IllegalMonitorStateException if {@link #isHeldExclusively}
         *         returns {@code false}
         */
        public final void signalAll() {
            //必须处于独占模式下，并且必须持有锁，否则抛出IllegalMonitorStateException异常
            if (!isHeldExclusively())
                throw new IllegalMonitorStateException();
            Node first = firstWaiter;
            if (first != null)
                doSignalAll(first);
        }
```

以下是doSignalAll源码。该方法将所有位于condition queue中的节点全部移送至sync queue中

```java
        /**
         * Removes and transfers all nodes.
         * @param first (non-null) the first node on condition queue
         */
        private void doSignalAll(Node first) {
            //清空阻塞队列
            lastWaiter = firstWaiter = null;
            //循环将condition queue中每个节点按次序移送至sync queue中
            do {
                Node next = first.nextWaiter;
                first.nextWaiter = null;
                transferForSignal(first);
                first = next;
            } while (first != null);
        }

```

## 3.5 其他形式的await

首先是awaitNanos(long nanosTimeout)，该方法等待指定时间，超时后便直接转移到sync queue中。方法返回剩余纳秒数

```java
        /**
         * Implements timed condition wait.
         * <ol>
         * <li> If current thread is interrupted, throw InterruptedException.
         * <li> Save lock state returned by {@link #getState}.
         * <li> Invoke {@link #release} with saved state as argument,
         *      throwing IllegalMonitorStateException if it fails.
         * <li> Block until signalled, interrupted, or timed out.
         * <li> Reacquire by invoking specialized version of
         *      {@link #acquire} with saved state as argument.
         * <li> If interrupted while blocked in step 4, throw InterruptedException.
         * </ol>
         */
        public final long awaitNanos(long nanosTimeout)
                throws InterruptedException {
            if (Thread.interrupted())
                throw new InterruptedException();
            Node node = addConditionWaiter();
            int savedState = fullyRelease(node);
            //设置deadline时刻
            final long deadline = System.nanoTime() + nanosTimeout;
            int interruptMode = 0;
            while (!isOnSyncQueue(node)) {
                //从这里开始与await方法略有不同
                //如果已超时，与中断处理方式相同，将节点转移到sync queue中
                if (nanosTimeout <= 0L) {
                    transferAfterCancelledWait(node);
                    break;
                }
                //如果剩余等待时间大于自旋threshold，那么阻塞自己一定时间。否则自旋等待即可，这段时间非常短，自旋的收益要大于阻塞/唤醒
                if (nanosTimeout >= spinForTimeoutThreshold)
                    LockSupport.parkNanos(this, nanosTimeout);
                //检查中断
                if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                    break;
                //更新剩余等待时间
                nanosTimeout = deadline - System.nanoTime();
            }
            if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
                interruptMode = REINTERRUPT;
            if (node.nextWaiter != null)
                unlinkCancelledWaiters();
            if (interruptMode != 0)
                reportInterruptAfterWait(interruptMode);
            return deadline - System.nanoTime();
        }
```

其次是await(long time, TimeUnit unit)，该方法与awaitNanos(long nanosTimeout)基本一致，返回是否超时

```java
        /**
         * Implements timed condition wait.
         * <ol>
         * <li> If current thread is interrupted, throw InterruptedException.
         * <li> Save lock state returned by {@link #getState}.
         * <li> Invoke {@link #release} with saved state as argument,
         *      throwing IllegalMonitorStateException if it fails.
         * <li> Block until signalled, interrupted, or timed out.
         * <li> Reacquire by invoking specialized version of
         *      {@link #acquire} with saved state as argument.
         * <li> If interrupted while blocked in step 4, throw InterruptedException.
         * <li> If timed out while blocked in step 4, return false, else true.
         * </ol>
         */
        public final boolean await(long time, TimeUnit unit)
                throws InterruptedException {
            //将时间信息转为纳秒
            long nanosTimeout = unit.toNanos(time);
            if (Thread.interrupted())
                throw new InterruptedException();
            Node node = addConditionWaiter();
            int savedState = fullyRelease(node);
            final long deadline = System.nanoTime() + nanosTimeout;
            boolean timedout = false;
            int interruptMode = 0;
            while (!isOnSyncQueue(node)) {
                if (nanosTimeout <= 0L) {
                    timedout = transferAfterCancelledWait(node);
                    break;
                }
                if (nanosTimeout >= spinForTimeoutThreshold)
                    LockSupport.parkNanos(this, nanosTimeout);
                if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                    break;
                nanosTimeout = deadline - System.nanoTime();
            }
            if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
                interruptMode = REINTERRUPT;
            if (node.nextWaiter != null)
                unlinkCancelledWaiters();
            if (interruptMode != 0)
                reportInterruptAfterWait(interruptMode);
            return !timedout;
        }
```

最后是awaitUntil(Date deadline)，该方法指定超时时刻，逻辑与上述两种方法基本一致。返回是否超时

```java
        /**
         * Implements absolute timed condition wait.
         * <ol>
         * <li> If current thread is interrupted, throw InterruptedException.
         * <li> Save lock state returned by {@link #getState}.
         * <li> Invoke {@link #release} with saved state as argument,
         *      throwing IllegalMonitorStateException if it fails.
         * <li> Block until signalled, interrupted, or timed out.
         * <li> Reacquire by invoking specialized version of
         *      {@link #acquire} with saved state as argument.
         * <li> If interrupted while blocked in step 4, throw InterruptedException.
         * <li> If timed out while blocked in step 4, return false, else true.
         * </ol>
         */
        public final boolean awaitUntil(Date deadline)
                throws InterruptedException {
            //获取具体时刻，对应前面几种方法的deadline
            long abstime = deadline.getTime();
            if (Thread.interrupted())
                throw new InterruptedException();
            Node node = addConditionWaiter();
            int savedState = fullyRelease(node);
            boolean timedout = false;
            int interruptMode = 0;
            while (!isOnSyncQueue(node)) {
                if (System.currentTimeMillis() > abstime) {
                    timedout = transferAfterCancelledWait(node);
                    break;
                }
                LockSupport.parkUntil(this, abstime);
                if ((interruptMode = checkInterruptWhileWaiting(node)) != 0)
                    break;
            }
            if (acquireQueued(node, savedState) && interruptMode != THROW_IE)
                interruptMode = REINTERRUPT;
            if (node.nextWaiter != null)
                unlinkCancelledWaiters();
            if (interruptMode != 0)
                reportInterruptAfterWait(interruptMode);
            return !timedout;
        }
```

至此ConditionObject源码大致上分析完毕

回顾一下AQS中独占模式下nextWaiter字段是null，而节点从condition queue中转移到sync queue中，由于一定是独占模式，因此只需要将nextWaiter设置为null即可
但是那些由于await被中断而进入sync queue的节点，这些节点的nextWaiter可能一直是非null的状态，但是没有关系，并不影响AQS的模式判断(只要nextWaiter不是SHARED就是独占模式)
