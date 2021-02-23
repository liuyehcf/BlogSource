---
title: Java-concurrent-ReentrantLock-源码剖析
date: 2017-07-02 22:54:03
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

本篇博客主要分析ReentrantLock的源码，ReentrantLock的实现基于AbstractQeueudSynchronizer(AQS)，AQS源码剖析请参见：{% post_link Java-concurrent-AQS-源码剖析 %}

# 2 内部类Sync

Sync是ReentrantLock的静态内部类，Sync继承自AQS，重写了tryRelease方法，但是并未重写tryAcquire方法而是提供了一个nonfairTryAcquire，这意味着tryAcquire方法会交给Sync的子类实现。ReentrantLock的lock方法unLock方法均会调用Sync实例的相应acquire以及release方法
```java
    /**
     * Base of synchronization control for this lock. Subclassed
     * into fair and nonfair versions below. Uses AQS state to
     * represent the number of holds on the lock.
     */
    abstract static class Sync extends AbstractQueuedSynchronizer {
        private static final long serialVersionUID = -5179523762034025860L;

        /**
         * Performs {@link Lock#lock}. The main reason for subclassing
         * is to allow fast path for nonfair version.
         */
        abstract void lock();

        /**
         * Performs non-fair tryLock.  tryAcquire is implemented in
         * subclasses, but both need nonfair try for trylock method.
         */
        //非公平tryAcquire方法，非公平模式下的tryAcquire实现会直接调用该方法。此外ReentrantLock的tryLock方法也会调用该方法
        final boolean nonfairTryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            //当资源为0时，说明没有线程持有锁
            if (c == 0) {
                //通过CAS竞争方法，尝试更改资源状态
                if (compareAndSetState(0, acquires)) {
                    //竞争成功的线程获取锁，并绑定当前线程
                    setExclusiveOwnerThread(current);
                    return true;
                }
            }
            //当资源不为0时，只有已持有锁的线程才会返回true，这就是可重入的具体含义
            else if (current == getExclusiveOwnerThread()) {
                int nextc = c + acquires;
                if (nextc < 0) //overflow
                    throw new Error("Maximum lock count exceeded");
                setState(nextc);
                return true;
            }
            return false;
        }

        protected final boolean tryRelease(int releases) {
            int c = getState() - releases;
            //调用该方法的线程必须持有锁，否则将抛出IllegalMonitorStateException异常
            if (Thread.currentThread() != getExclusiveOwnerThread())
                throw new IllegalMonitorStateException();
            boolean free = false;
            //若释放后资源为0，那么解除与当前线程的绑定关系。否则仅仅减少一次重入而已
            if (c == 0) {
                free = true;
                setExclusiveOwnerThread(null);
            }
            setState(c);
            return free;
        }

        protected final boolean isHeldExclusively() {
            //While we must in general read state before owner,
            //we don't need to do so to check if current thread is owner
            return getExclusiveOwnerThread() == Thread.currentThread();
        }

        //返回一个条件变量
        final ConditionObject newCondition() {
            return new ConditionObject();
        }

        //Methods relayed from outer class

        final Thread getOwner() {
            return getState() == 0 ? null : getExclusiveOwnerThread();
        }

        final int getHoldCount() {
            return isHeldExclusively() ? getState() : 0;
        }

        final boolean isLocked() {
            return getState() != 0;
        }

        /**
         * Reconstitutes the instance from a stream (that is, deserializes it).
         */
        private void readObject(java.io.ObjectInputStream s)
            throws java.io.IOException, ClassNotFoundException {
            s.defaultReadObject();
            setState(0); //reset to unlocked state
        }
    }
```

## 2.1 内部类NonfairSync

NonfairSync继承自抽象类Sync，是非公平锁。非公平性是指：当一个线程调用lock方法时，不论sync queue中是否有等待的线程，直接尝试获取锁，如果竞争成功便获取锁。这种方式对于已经入队并等待一段时间的节点来说是不公平的。这是ReentrantLock的默认实现
```java
    /**
     * Sync object for non-fair locks
     */
    static final class NonfairSync extends Sync {
        private static final long serialVersionUID = 7316153563782823691L;

        /**
         * Performs lock.  Try immediate barge, backing up to normal
         * acquire on failure.
         */
        final void lock() {
            //如果CAS将资源从0改为1，只需要绑定一下当前线程即可
            if (compareAndSetState(0, 1))
                setExclusiveOwnerThread(Thread.currentThread());
            //否则才调用AQS框架的入口方法acquire
            else
                acquire(1);
        }

        protected final boolean tryAcquire(int acquires) {
            //直接调用Sync中的nonfairTryAcquire方法作为tryAcquire的实现
            return nonfairTryAcquire(acquires);
        }
    }
```

## 2.2 内部类FairSync

内部类FairSync继承自抽象类Sync，是公平锁。公平是指：当一个线程调用lock方法时，如果sync queue中已有节点正在等待，那么当前线程不直接竞争，而是进入sync queue
```java
    /**
     * Sync object for fair locks
     */
    static final class FairSync extends Sync {
        private static final long serialVersionUID = -3000897897090466540L;

        final void lock() {
            acquire(1);
        }

        /**
         * Fair version of tryAcquire.  Don't grant access unless
         * recursive call or no waiters or is first.
         */
        protected final boolean tryAcquire(int acquires) {
            final Thread current = Thread.currentThread();
            int c = getState();
            if (c == 0) {
                //当资源状态为0，即当前没有线程持有锁时，首先检查队列中是否有节点存在，如果没有，才尝试获取，否则进入sync queue
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
    }
```

hasQueuedPredecessors方法如下，这是AQS的方法
```java
    public final boolean hasQueuedPredecessors() {
        //The correctness of this depends on head being initialized
        //before tail and on head.next being accurate if the current
        //thread is first in queue.
        Node t = tail; //Read fields in reverse initialization order
        Node h = head;
        Node s;
        //检查队列中位于第二位的节点所关联的线程是否是当前线程
        return h != t &&
            ((s = h.next) == null || s.thread != Thread.currentThread());
    }
```

# 3 重要方法

ReentrantLock只有一个字段
```java
    /** Synchronizer providing all implementation mechanics */
    private final Sync sync;
```

ReentrantLock有两个构造方法，默认构造方法采用非公平锁
```java
    public ReentrantLock() {
        sync = new NonfairSync();
    }

    public ReentrantLock(boolean fair) {
        sync = fair ? new FairSync() : new NonfairSync();
    }
```

ReentrantLock的一系列lock以及unlock方法仅仅转调用sync的相应方法而已
```java
    public void lock() {
        sync.lock();
    }

    //这个方法不需要依赖AQS，仅仅靠自身逻辑即可完成，毕竟获取失败不需要阻塞，仅仅告知是否成功即可
    public boolean tryLock() {
        return sync.nonfairTryAcquire(1);
    }

    public void unlock() {
        sync.release(1);
    }
```

获取条件对象的方法，关于ConditionObject的内部机制以及源码分析可参考 {% post_link Java-concurrent-AQS-ConditionObject-源码剖析 %}
```java
    public Condition newCondition() {
        return sync.newCondition();
    }
```
