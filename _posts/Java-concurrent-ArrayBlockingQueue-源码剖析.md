---
title: Java concurrent ArrayBlockingQueue 源码剖析
date: 2017-07-02 22:56:52
tags:
categories:
- Java concurrent 源码剖析
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

__ArrayBlockingQueue的分析分为以下几个部分__

* 字段介绍
* 重要方法源码分析

# 2 字段介绍
```Java
    /** The queued items */
    //数组，用于存放元素，注意到该字段是final修饰的，因此ArrayBlockingQueue是不能扩容的，其容量在初始化时就已经确定    
    final Object[] items;

    /** items index for next take, poll, peek or remove */
    //take/poll/peek/remove方法操作的下标
    int takeIndex;

    /** items index for next put, offer, or add */
    //put/offer/add方法操作的下标
    int putIndex;

    /** Number of elements in the queue */
    //队列中的所有元素
    int count;

    /*
     * Concurrency control uses the classic two-condition algorithm
     * found in any textbook.
     */

    /** Main lock guarding all access */
    //重入锁，所有非线程安全字段的访问都需要配合该重入锁
    final ReentrantLock lock;

    /** Condition for waiting takes */
    //条件变量，用于阻塞和唤醒线程
    private final Condition notEmpty;

    /** Condition for waiting puts */
    //条件变量，用于阻塞和唤醒线程
    private final Condition notFull;

    /**
     * Shared state for currently active iterators, or null if there
     * are known not to be any.  Allows queue operations to update
     * iterator state.
     */
    //迭代器
    transient Itrs itrs = null;
```

* __items__：用于存放元素的数组，注意到该字段是final修饰的，因此ArrayBlockingQueue是不能扩容的，其容量在初始化时就已经确定    
* __takeIndex__：队列头元素的下标，指向take/poll/peek/remove方法操作的元素
* __putIndex__：队列尾元素的下标，指向put/offer/add方法方法操作的元素
* __lock__：重复锁，[Java concurrent ReentrantLock 源码剖析](https://liuyehcf.github.io/2017/07/02/Java-concurrent-ReentrantLock-%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90/)
* __notEmpty__：条件对象(Condition)，关于ConditionObject源码分析，可以参考[Java concurrent AQS-ConditoinObject 源码剖析](https://liuyehcf.github.io/2017/07/02/Java-concurrent-AQS-ConditionObject-%E6%BA%90%E7%A0%81%E5%89%96%E6%9E%90/)
* __notFull__：条件对象(Condition)
* __itrs__：迭代器

# 3 重要方法源码分析

## &emsp;3.1 offer

__该方法向队列中添加一个元素__

* 当队列未满时，会成功添加
* 当队列已满时，添加失败，但不会阻塞调用offer方法的线程

```Java
    /**
     * Inserts the specified element at the tail of this queue if it is
     * possible to do so immediately without exceeding the queue's capacity,
     * returning {@code true} upon success and {@code false} if this queue
     * is full.  This method is generally preferable to method {@link #add},
     * which can fail to insert an element only by throwing an exception.
     *
     * @throws NullPointerException if the specified element is null
     */
    public boolean offer(E e) {
        checkNotNull(e);
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            //队列已满时，直接返回false
            if (count == items.length)
                return false;
            else {
                //enqueue需要配合重入锁lock才能确保线程安全
                enqueue(e);
                return true;
            }
        } finally {
            lock.unlock();
        }
    }
```

### &emsp;&emsp;&emsp;3.1.1 enqueue

```Java
    /**
     * Inserts element at current put position, advances, and signals.
     * Call only when holding lock.
     */
    private void enqueue(E x) {
        // assert lock.getHoldCount() == 1;
        // assert items[putIndex] == null;
        final Object[] items = this.items;
        items[putIndex] = x;
        //更新putIndex
        if (++putIndex == items.length)
            putIndex = 0;
        count++;
        //此时队列至少有一个元素，因此通过条件对象notEmpty唤醒那些阻塞在notEmpty上的其中一个线程
        notEmpty.signal();
    }
```

### &emsp;&emsp;&emsp;3.1.2 offer的另一个重载版本

__这个版本的offer允许阻塞当前线程一段时间__

* 当队列已满时，会阻塞一段指定的时间。直至成功将元素入队，或者超时

```Java
    /**
     * Inserts the specified element at the tail of this queue, waiting
     * up to the specified wait time for space to become available if
     * the queue is full.
     *
     * @throws InterruptedException {@inheritDoc}
     * @throws NullPointerException {@inheritDoc}
     */
    public boolean offer(E e, long timeout, TimeUnit unit)
        throws InterruptedException {

        checkNotNull(e);
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        //允许中断
        lock.lockInterruptibly();
        try {
            //当队列已满
            while (count == items.length) {
                //已经超时，则直接返回false
                if (nanos <= 0)
                    return false;
                //未超时，则阻塞指定时间，awaitNanos会返回剩余时间
                nanos = notFull.awaitNanos(nanos);
            }
            //入队
            enqueue(e);
            return true;
        } finally {
            lock.unlock();
        }
    }
```

## &emsp;3.2 put

__put方法向队列添加一个元素__

* 若队列已满，则阻塞调用put方法的线程，直至队列非满

```Java
    /**
     * Inserts the specified element at the tail of this queue, waiting
     * for space to become available if the queue is full.
     *
     * @throws InterruptedException {@inheritDoc}
     * @throws NullPointerException {@inheritDoc}
     */
    public void put(E e) throws InterruptedException {
        checkNotNull(e);
        final ReentrantLock lock = this.lock;
        //允许中断
        lock.lockInterruptibly();
        try {
            //若队列已满，则阻塞当前线程，直至队列非满
            while (count == items.length)
                //阻塞后，会释放持有的锁。唤醒后又会重新持有锁
                notFull.await();
            //入队
            enqueue(e);
        } finally {
            lock.unlock();
        }
    }
```

## &emsp;3.3 poll

__poll方法从队列中取出一个元素__

* 如果队列为空，则返回null，并不会阻塞当前线程

```Java
    public E poll() {
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {
            return (count == 0) ? null : dequeue();
        } finally {
            lock.unlock();
        }
    }
```

### &emsp;&emsp;&emsp;3.3.1 dequeue

```Java
    /**
     * Extracts element at current take position, advances, and signals.
     * Call only when holding lock.
     */
    private E dequeue() {
        // assert lock.getHoldCount() == 1;
        // assert items[takeIndex] != null;
        final Object[] items = this.items;
        @SuppressWarnings("unchecked")
        E x = (E) items[takeIndex];
        items[takeIndex] = null;
        if (++takeIndex == items.length)
            takeIndex = 0;
        count--;
        //???
        if (itrs != null)
            itrs.elementDequeued();
        //此时队列必定非满，通过条件对象notFull唤醒那些阻塞在notFull上的其中一个线程
        notFull.signal();
        return x;
    }
```

### &emsp;&emsp;&emsp;3.3.2 poll的另一个重载版本

__这个重载版本的poll方法允许阻塞一段指定的时间__

* 当队列为空，则阻塞一段时间，直至获取元素或者阻塞超时

```Java
    public E poll(long timeout, TimeUnit unit) throws InterruptedException {
        long nanos = unit.toNanos(timeout);
        final ReentrantLock lock = this.lock;
        //允许中断
        lock.lockInterruptibly();
        try {
            //当队列为空
            while (count == 0) {
                //此时已超时，直接返回null
                if (nanos <= 0)
                    return null;
                //此时未超时，则等待一段时间
                nanos = notEmpty.awaitNanos(nanos);
            }
            //出队
            return dequeue();
        } finally {
            lock.unlock();
        }
    }
```

## &emsp;3.4 take

__take方法从队列中取出一个元素__

* 如果队列为空，则阻塞当前线程，直至队列不为空

```Java
    public E take() throws InterruptedException {
        final ReentrantLock lock = this.lock;
        //允许中断
        lock.lockInterruptibly();
        try {
            //若队列为空，则阻塞直至队列非空
            while (count == 0)
                notEmpty.await();
            //头元素出队
            return dequeue();
        } finally {
            lock.unlock();
        }
    }
```
