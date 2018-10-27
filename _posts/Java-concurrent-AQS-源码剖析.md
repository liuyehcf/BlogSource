---
title: Java-concurrent-AQS-源码剖析
date: 2017-07-02 22:46:56
tags: 
- 原创
categories: 
- Java
- Java Concurrent
- Source Code Analysis
---

__阅读更多__

<!--more-->

# 1 引言

AQS(AbstractQueuedSynchronizer，同步阻塞队列)是concurrent包下锁机制实现的基础框架
这篇博客主要针对AbstractQueuedSynchronizer的源码进行分析，大致分为三个部分：

* 静态内部类Node的解析
* 重要常量以及字段的解析
* 重要方法的源码详解

所有的分析仅基于个人的理解，若有不正之处，请谅解和批评指正，不胜感激！！！

# 2 Node解析

AQS在内部维护了一个同步阻塞队列，__下面简称sync queue__，该队列的元素即静态内部类Node的实例。首先来看Node中涉及的常量定义，源码如下
```Java
        /** Marker to indicate a node is waiting in shared mode */
        static final Node SHARED = new Node();
        /** Marker to indicate a node is waiting in exclusive mode */
        static final Node EXCLUSIVE = null;

        /** waitStatus value to indicate thread has cancelled */
        static final int CANCELLED =  1;
        /** waitStatus value to indicate successor's thread needs unparking */
        static final int SIGNAL    = -1;
        /** waitStatus value to indicate thread is waiting on condition */
        static final int CONDITION = -2;
        /**
         * waitStatus value to indicate the next acquireShared should
         * unconditionally propagate
         */
        static final int PROPAGATE = -3;
```

以下两个均为Node#nextWaiter字段的可取值

* __SHARED__：若Node#nextWaiter为SHARED，那么表明该Node节点处于共享模式
* __EXCLUSIVE__：若Node#nextWaiter为EXCLUSIVE，那么表明该Node节点处于独占模式

以下五个均为Node#waitStatus字段的可取值

* __CANCELLED__：用于标记一个已被取消的节点，一旦Node#waitStatus的值被设为CANCELLED，那么waitStatus的值便不再被改变
* __SIGNAL__：__标记一个节点(记为node)处于这样一种状态：当node释放资源(unlock/release)时，node节点必须唤醒其后继节点__
* __CONDITION__：用于标记一个节点位于条件变量的阻塞队列中(我称这个阻塞队列为Condition queue)，本篇暂不介绍Condition相关源码，因此读者可以暂时忽略
* __PROPAGATE__：仅用于标记sync queue头节点，用于确保release操作propagate下去

其次，再看Node中重要字段，源码如下
```Java
        /**
         * Status field, taking on only the values:
         *   SIGNAL:     The successor of this node is (or will soon be)
         *               blocked (via park), so the current node must
         *               unpark its successor when it releases or
         *               cancels. To avoid races, acquire methods must
         *               first indicate they need a signal,
         *               then retry the atomic acquire, and then,
         *               on failure, block.
         *   CANCELLED:  This node is cancelled due to timeout or interrupt.
         *               Nodes never leave this state. In particular,
         *               a thread with cancelled node never again blocks.
         *   CONDITION:  This node is currently on a condition queue.
         *               It will not be used as a sync queue node
         *               until transferred, at which time the status
         *               will be set to 0. (Use of this value here has
         *               nothing to do with the other uses of the
         *               field, but simplifies mechanics.)
         *   PROPAGATE:  A releaseShared should be propagated to other
         *               nodes. This is set (for head node only) in
         *               doReleaseShared to ensure propagation
         *               continues, even if other operations have
         *               since intervened.
         *   0:          None of the above
         *
         * The values are arranged numerically to simplify use.
         * Non-negative values mean that a node doesn't need to
         * signal. So, most code doesn't need to check for particular
         * values, just for sign.
         *
         * The field is initialized to 0 for normal sync nodes, and
         * CONDITION for condition nodes.  It is modified using CAS
         * (or when possible, unconditional volatile writes).
         */
        volatile int waitStatus;

        /**
         * Link to predecessor node that current node/thread relies on
         * for checking waitStatus. Assigned during enqueuing, and nulled
         * out (for sake of GC) only upon dequeuing.  Also, upon
         * cancellation of a predecessor, we short-circuit while
         * finding a non-cancelled one, which will always exist
         * because the head node is never cancelled: A node becomes
         * head only as a result of successful acquire. A
         * cancelled thread never succeeds in acquiring, and a thread only
         * cancels itself, not any other node.
         */
        volatile Node prev;

        /**
         * Link to the successor node that the current node/thread
         * unparks upon release. Assigned during enqueuing, adjusted
         * when bypassing cancelled predecessors, and nulled out (for
         * sake of GC) when dequeued.  The enq operation does not
         * assign next field of a predecessor until after attachment,
         * so seeing a null next field does not necessarily mean that
         * node is at end of queue. However, if a next field appears
         * to be null, we can scan prev's from the tail to
         * double-check.  The next field of cancelled nodes is set to
         * point to the node itself instead of null, to make life
         * easier for isOnSyncQueue.
         */
        volatile Node next;

        /**
         * The thread that enqueued this node.  Initialized on
         * construction and nulled out after use.
         */
        volatile Thread thread;

        /**
         * Link to next node waiting on condition, or the special
         * value SHARED.  Because condition queues are accessed only
         * when holding in exclusive mode, we just need a simple
         * linked queue to hold nodes while they are waiting on
         * conditions. They are then transferred to the queue to
         * re-acquire. And because conditions can only be exclusive,
         * we save a field by using special value to indicate shared
         * mode.
         */
        Node nextWaiter;
```

* __waitStatus__：节点的状态，可取值有五种，分别是SIGNAL、CANCEL、CONDITION、PROPAGATE、0
    * __独占模式__仅涉及到SIGNAL、CANCEL、0三种状态
    * __共享模式__仅涉及到SIGNAL、CANCEL、PROPAGATE、0四种状态
    * CONDITION状态不会出现在sync queue中，而是位于条件变量的Condition queue中，本篇博客暂不讨论ConditoinObject
* __pre__：前继节点，该字段通过CAS操作进行赋值，__保证可靠__(现在不理解没关系，后面的方法解析会多次提到)
* __next__：后继节点，该字段的赋值操作是非线程安全的，__即next是不可靠的__(Node#next为null并不代表节点不存在后继)。但是，一旦next不为null，那么next也是可靠的(现在不理解没关系，后面的方法解析会多次提到)
* __thread__：该节点关联的线程
* __nextWaiter__：独占模式中就是null，共享模式中就是SHARED。在ConditionObject的Condition queue中指向下一个节点
* __注意：Condition queue用nextWaiter来连接单向链表(pre与next是无用的)，sync queue利用pre和next来连接双向链表(nextWaiter仅用于标记独占或者共享模式而已)，不要搞混了！！！__

# 3 AQS字段解析

AQS字段仅有三个，源码如下
```Java
    /**
     * Head of the wait queue, lazily initialized.  Except for
     * initialization, it is modified only via method setHead.  Note:
     * If head exists, its waitStatus is guaranteed not to be
     * CANCELLED.
     */
    private transient volatile Node head;

    /**
     * Tail of the wait queue, lazily initialized.  Modified only via
     * method enq to add new wait node.
     */
    private transient volatile Node tail;

    /**
     * The synchronization state.
     */
    private volatile int state;
```

* __head__：sync queue队列的头节点，只通过setHead方法进行修改。并且头结点的状态不可能是CANCEL
* __tail__：sync queue队列的尾节点，仅通过addWaiter方法向尾部增加新节点
* __state__：资源状态，该状态与Node#waitStatus含义完全不同，注意区分

# 4 重要方法解析

## 4.1 acquire

__acquire方法用于获取指定数量的资源，如果获取不到则当前线程会被阻塞__

* 该方法内部不响应中断，在成功获取资源后会恢复中断现场，但是不会抛出InterruptedException异常
* 首先，利用tryAcquire尝试获取资源，如果成功了，则方法直接返回，当前线程直接获取锁状态；如果失败了，当前线程被封装成Node节点并添加到sync queue中，并在一个死循环中尝试获取资源直至成功
* 通常，AQS子类会将该方法再进行一层封装，例如ReentrantLock#lock()方法就会调用这里的acquire方法来实现加锁的语义

```Java
    /**
     * Acquires in exclusive mode, ignoring interrupts.  Implemented
     * by invoking at least once {@link #tryAcquire},
     * returning on success.  Otherwise the thread is queued, possibly
     * repeatedly blocking and unblocking, invoking {@link
     * #tryAcquire} until success.  This method can be used
     * to implement method {@link Lock#lock}.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquire} but is otherwise uninterpreted and
     *        can represent anything you like.
     */
    public final void acquire(int arg) {
        //首先执行tryAcquire(arg)尝试获取资源，如果成功则直接返回
        //如果tryAcquire(arg)获取资源失败，则将当前线程封装成Node节点加入到sync queue队列中，并通过acquireQueued进行获取资源直至成功(如果尚未有资源可获取，那么acquireQueued会阻塞当前线程)
        if (!tryAcquire(arg) &&
            acquireQueued(addWaiter(Node.EXCLUSIVE), arg))
            selfInterrupt();
    }    
```

### 4.1.1 tryAcquire

__tryAcquire方法用于判断是否能够获取资源__

* 本方法仅抛出一个异常，意味着该方法的具体含义交给AQS的子类去完成
* 注意，该方法的实现不可有任何耗时操作，更不可阻塞线程，仅实现是否可获取资源(换言之，是否可获取锁)的逻辑即可

```Java
    protected boolean tryAcquire(int arg) {
        throw new UnsupportedOperationException();
    }
```

### 4.1.2 addWaiter

__无法获取资源的线程将被封装成Node节点，通过addWaiter方法将指定节点添加到到sync queue中__

* 根据指定模式，将当前线程封装成一个Node节点，并且添加到sync queue中
* 首先尝试直接入队，若失败则交给enq方法处理

```Java
    /**
     * Creates and enqueues node for current thread and given mode.
     *
     * @param mode Node.EXCLUSIVE for exclusive, Node.SHARED for shared
     * @return the new node
     */
    private Node addWaiter(Node mode) {
        //生成指定模式的Node节点
        Node node = new Node(Thread.currentThread(), mode);
        //Try the fast path of enq; backup to full enq on failure
        Node pred = tail;
        //以下几行进行入队操作，如果失败，交给enq进行入队处理。其实，我认为可以直接调用enq，不知道作者设置如下几行的意图
        if (pred != null) {
            node.prev = pred;
            //通过CAS操作串行化并发入队操作，仅有一个线程会成功，由于node节点的prev字段是在CAS操作之前进行的，一旦CAS操作成功，node节点的prev字段就是指向了其前继节点，因此说prev字段是安全的
            if (compareAndSetTail(pred, node)) {
                //这里直接通过赋值操作赋值next字段，注意，可能有别的线程会在next字段赋值之前访问到next字段，因此next字段是非可靠的(一个节点的next字段为null并不代表该节点没有后继)
                pred.next = node;
                //一旦next字段赋值成功，那么next字段又变为可靠的了
                return node;
            }
        }
        //通过enq入队
        enq(node);
        return node;
    }
```

### 4.1.3 enq

__enq方法确保给定节点成功入队__

* addWaiter方法会首先尝试一次入队
* 如果失败了(可能原因是CAS失败或者sync queue尚未初始化)，那么通过enq方法进行入队操作
* 可以看到enq也是采用了死循环+CAS操作，这是使用CAS的通用模式

```Java
    /**
     * Inserts node into queue, initializing if necessary. See picture above.
     * @param node the node to insert
     * @return node's predecessor
     */
    private Node enq(final Node node) {
        //死循环进行入队操作，CAS操作常规模式
        for (;;) {
            Node t = tail;
            //此时队列为空，需要初始化
            if (t == null) { //Must initialize
                //此时可能多个线程都在执行该方法，因此只有一个线程才能初始化sync queue，此处添加的节点我称之为Dummy Node，该节点没有关联线程
                if (compareAndSetHead(new Node()))
                    tail = head;
            } else {
                //以下四行与addWaiter类似，不再赘述
                node.prev = t;
                if (compareAndSetTail(t, node)) {
                    t.next = node;
                    return t;
                }
            }
        }
    }                
```
__这里抛出一个问题__

* 在初始化sync queue中，将一个new Node()设置为了sync queue的头结点，该节点没有关联任何线程，我称之为"Dummy Node"，这个头结点"Dummy Node"待会可能会被后继节点设置为SIGNAL状态，那么它是如何唤醒后继节点的呢？我会在在讲到release时进行解释

### 4.1.4 acquireQueued

__至此，线程已被封装成节点，并且成功添加到sync queue中去了，接下来，来看最重要的acquireQueued方法__

* 该方法不断地通过死循环+CAS操作的方式获取资源(当且仅当节点是sync queue中第二个节点时才有资格获取资源)
* 如果节点不是队列中第二个节点或者tryAcquire失败，那么需要阻塞自己，阻塞自己前必须将前继节点标记为SIGNAL状态
* 该方法会记录中断信号，并且在成功返回后交给上层函数来恢复中断现场
* 只有成果获取资源后才能够返回，这也就是阻塞语义的实现

```Java
    /**
     * Acquires in exclusive uninterruptible mode for thread already in
     * queue. Used by condition wait methods as well as acquire.
     *
     * @param node the node
     * @param arg the acquire argument
     * @return {@code true} if interrupted while waiting
     */
    final boolean acquireQueued(final Node node, int arg) {
        //用于记录是否获取成功，我现在还不清楚何时会失败= =
        boolean failed = true;
        try {
            //记录是否被中断过，如果被中断过，则需要在acquire方法中恢复中断现场
            boolean interrupted = false;
            //同样的套路，CAS配合死循环
            for (;;) {
                //获取node节点的前继节点p
                final Node p = node.predecessor();
                //当p为sync queue头结点时，才有资格尝试获取资源，换言之，当且仅当一个节点是sync queue中第二个节点时，它才有资格获取资源
                if (p == head && tryAcquire(arg)) {
                    //一旦获取成功，以下语句都是线程安全的，所有字段直接赋值即可，不需要CAS或者加锁
                    setHead(node);
                    p.next = null; //help GC
                    failed = false;
                    return interrupted;
                }
                //否则，找到前继节点，并将其设置为SIGNAL状态后阻塞自己
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
                //如果失败了
                cancelAcquire(node);
        }
    }
```

### 4.1.5 shouldParkAfterFailedAcquire以及parkAndCheckInterrupt

__shouldParkAfterFailedAcquire方法用于判断当前节点是否可以阻塞自己__

* 若前继节点为SIGNAL则返回true，表示该节点可以放心阻塞自己
* 否则找到有效前继节点，并尝试将其状态改为SIGNAL，并返回false，交给上一层函数继续处理

```Java
    /**
     * Checks and updates status for a node that failed to acquire.
     * Returns true if thread should block. This is the main signal
     * control in all acquire loops.  Requires that pred == node.prev.
     *
     * @param pred node's predecessor holding status
     * @param node the node
     * @return {@code true} if thread should block
     */
    private static boolean shouldParkAfterFailedAcquire(Node pred, Node node) {
        int ws = pred.waitStatus;
        //一旦发现前继节点是SIGNAL状态，就返回true，在acquireQueued方法中会阻塞当前线程
        if (ws == Node.SIGNAL)
            /*
             * This node has already set status asking a release
             * to signal it, so it can safely park.
             */
            //这里给出两个问题：
                 //1.如果在当前线程阻塞之前，前继节点就唤醒了当前线程，那么当前线程不就永远阻塞下去了吗？
                 //2.万一有别的线程更改了前继节点的状态，导致前继节点不唤醒当前线程，那么当前线程不就永远阻塞下去了吗？
            return true;

        //如果前继节点处于CANCELL状态(仅有CANCELL状态大于0)
        if (ws > 0) {
            //那么跳过那些被CANCELL的节点，先前找到第一个有效节点
            /*
             * Predecessor was cancelled. Skip over predecessors and
             * indicate retry.
             */
            do {
                node.prev = pred = pred.prev;
            } while (pred.waitStatus > 0);
            pred.next = node;
        } else {
        //前继节点状态要么是0，要么是PROPAGATE，将其通过CAS操作设为SIGNAL，不用管是否成功，退回到上层函数acquireQueued进行再次判断
            /*
             * waitStatus must be 0 or PROPAGATE.  Indicate that we
             * need a signal, but don't park yet.  Caller will need to
             * retry to make sure it cannot acquire before parking.
             */
            compareAndSetWaitStatus(pred, ws, Node.SIGNAL);
        }
        return false;
    }
```

__关于上面提到的两个问题__

* 如果在当前线程阻塞之前，前继节点就唤醒了当前线程，那么当前线程不就永远阻塞下去了吗？
    * AQS采用的是Unsafe#park以及Unsafe#unpark，这对方法能够很好的处理这类问题，可以先unpark获取一枚许可，然后执行park不会阻塞当前线程，而是消耗这个提前获取的许可，注意，多次unpark仅能获取一枚许可
* 万一有别的线程更改了前继节点的状态，导致前继节点不唤醒当前线程，那么当前线程不就永远阻塞下去了吗？
    * 一旦一个节点被设为SIGNAL状态，AQS框架保证，任何改变其SIGNAL状态的操作都会唤醒其后继节点，因此，只要节点看到其前继节点为SIGNAL状态，便可放心阻塞自己

__parkAndCheckInterrupt方法用于阻塞当前线程__

* 阻塞当前线程，一旦被唤醒(unpark)或者被中断(interrupt)后返回中断标志位的状态，便于外层方法恢复中断现场

```Java
    /**
     * Convenience method to park and then check if interrupted
     *
     * @return {@code true} if interrupted
     */
    private final boolean parkAndCheckInterrupt() {
        LockSupport.park(this);
        //返回是否被中断过
        return Thread.interrupted();
    }
```
__至此，独占模式的acquire调用链分析完毕，总结一下__

* 首先尝试获取锁(tryAcquire)，若成功则直接返回
* 若失败，将当前线程封装成Node节点加入到sync queue队列中，当该节点位于第二个节点时，会重新尝试获取锁，获取成功则返回，失败或者当前节点不是sync queue第二个节点则将前继节点设置为SIGNAL状态后阻塞自己，直至前继节点唤醒自己或者被中断

__AQS通过死循环以及CAS操作来串行化并发操作，并且通过这种适当的自旋加阻塞，来减少频繁的加锁解锁操作__

## 4.2 release

__release方法是独占模式下实现解锁语义的入口方法__

* 只有当头结点的状态不为0时，才会执行唤醒后继节点的动作
* 对于独占模式中，节点状态只有SIGNAL、0和CANCELL，而CANCELL状态的节点不会成为头结点，因此(h !=0 )在这里只有一种可能，就是SIGNAL状态
* AQS子类通常将该方法包装成unlock方法，例如ReentrantLock

```Java
    /**
     * Releases in exclusive mode.  Implemented by unblocking one or
     * more threads if {@link #tryRelease} returns true.
     * This method can be used to implement method {@link Lock#unlock}.
     *
     * @param arg the release argument.  This value is conveyed to
     *        {@link #tryRelease} but is otherwise uninterpreted and
     *        can represent anything you like.
     * @return the value returned from {@link #tryRelease}
     */
    public final boolean release(int arg) {
        //调用tryRelease尝试释放资源
        if (tryRelease(arg)) {
            Node h = head;
            //只要头节点不为空且状态不为0，就唤醒后继节点，对于独占模式也就只有SIGNAL状态一种，头结点在任何情况下都不可能为CANCELL状态
            if (h != null && h.waitStatus != 0)
                unparkSuccessor(h);
            return true;
        }
        return false;
    }
```

__在此，解释一下enq方法中提到的问题__

* 即那个"Dummy Node"如何唤醒后继：由于"Dummy Node"不关联任何线程，因此真正的唤醒操作实际上是由外部的线程来完成的，这里的外部线程是指从未进入sync queue的线程(即那些执行acquire直接通过tryAcquire返回的线程)，因此，"Dummy Node"节点设置为SIGNAL状态，也能够正常唤醒后继

### 4.2.1 tryRelease

__tryRelease方法用于判断是否能够释放资源__

* 交给AQS子类实现的方法，只需要定义释放资源的逻辑即可
* 该方法的实现不应该有耗时的操作，更不该阻塞

```Java
    protected boolean tryRelease(int arg) {
        throw new UnsupportedOperationException();
    }
```

### 4.2.2 unparkSuccessor

__通过unparkSuccessor方法唤醒指定节点的后继节点__

* 通过节点的next字段定位后继，若next字段为null，并不代表一定没有后继，从tail往前找到后继节点

```Java
    /**
     * Wakes up node's successor, if one exists.
     *
     * @param node the node
     */
    private void unparkSuccessor(Node node) {
        /*
         * If status is negative (i.e., possibly needing signal) try
         * to clear in anticipation of signalling.  It is OK if this
         * fails or if status is changed by waiting thread.
         */
        int ws = node.waitStatus;
        //若节点状态小于0，将其通过CAS操作改为0，表明本次SIGNAL的任务已经完成，至于CAS是否成功，或者是否再次被其他线程修改，都与本次无关unparkSuccessor无关，只是该节点被赋予了新的任务而已
        if (ws < 0)
            compareAndSetWaitStatus(node, ws, 0);

        /*
         * Thread to unpark is held in successor, which is normally
         * just the next node.  But if cancelled or apparently null,
         * traverse backwards from tail to find the actual
         * non-cancelled successor.
         */
        //这里通过非可靠的next字段直接获取后继，如果非空，那么说明该字段可靠，如果为空，那么利用可靠的prev字段从tail向前找到当前node节点的后继节点
        Node s = node.next;
        if (s == null || s.waitStatus > 0) {
            s = null;
            for (Node t = tail; t != null && t != node; t = t.prev)
                if (t.waitStatus <= 0)
                    s = t;
        }
        //唤醒后继节点
        if (s != null)
            LockSupport.unpark(s.thread);
    }        
```

## 4.3 acquireShared

__acquireShared方法是共享模式下实现加锁语义的入口方法__

* 该方法通过tryAcquireShared尝试获取资源，如果返回值大于等于0，则说明获取成功，直接返回
* tryAcquireShared返回值小于0，说明获取失败。那么将线程封装成共享模式的节点并添加到sync queue中
* 该方法不响应中断，在获取资源后会恢复中断现场

```Java
    /**
     * Acquires in shared mode, ignoring interrupts.  Implemented by
     * first invoking at least once {@link #tryAcquireShared},
     * returning on success.  Otherwise the thread is queued, possibly
     * repeatedly blocking and unblocking, invoking {@link
     * #tryAcquireShared} until success.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquireShared} but is otherwise uninterpreted
     *        and can represent anything you like.
     */
    public final void acquireShared(int arg) {
        //尝试获取锁，如果返回值不小于9，则说明获取成功，直接返回
        //如果获取失败，则进入doAcquireShared方法，执行后续操作
        if (tryAcquireShared(arg) < 0)
            doAcquireShared(arg);
    }    
```

### 4.3.1 tryAcquireShared

__tryAcquireShared方法用于判断是否能够获取资源__

* 交给AQS子类实现的方法，只需要定义获取资源的逻辑即可
* 该方法的实现不应该有耗时的操作，更不该阻塞

```Java
    protected int tryAcquireShared(int arg) {
        throw new UnsupportedOperationException();
    }
```

### 4.3.2 doAcquireShared

__doAcquireShared方法是核心方法__

* doAcquireShared方法将当前线程封装成共享模式的节点，并加入到sync queue中
* 通过死循环并尝试获取资源。共享模式下，仍然只有sync queue中第二个节点才有资格获取资源。所有节点必须排队依次通过
    * 假设现有资源数量是2，第二个节点需要3，第三个节点需要1。那么第三个节点是无法通过的，它必须等到第二个节点成功获取资源后才能尝试获取资源
* 如果节点不是sync queue中第二个节点或者获取资源失败，那么阻塞自己，阻塞自己前必须将前继节点标记为SIGNAL状态
* 该方法不响应中断，而是在返回之前恢复中断现场

```Java
    /**
     * Acquires in shared uninterruptible mode.
     * @param arg the acquire argument
     */
    private void doAcquireShared(int arg) {
        //首先，将当前线程封装成共享模式的节点，并添加到sync queue中
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            //标记获取资源过程中是否被中断，如果被中断了，则需要还原中断现场
            boolean interrupted = false;
            //老套路，死循环+CAS操作
            for (;;) {
                final Node p = node.predecessor();
                //与独占模式类似，共享模式下也仅有第二个节点有资格获取资源
                if (p == head) {
                    int r = tryAcquireShared(arg);
                    //返回值不小于0，则意味着获取资源成功
                    if (r >= 0) {
                        //以下代码都是线程安全的：虽然共享模式下可以有多个获取资源的线程，但是在队列中仅有第二个节点在成功获取资源的情况下，才能执行以下逻辑
                        //该方法是共享模式下的重点方法，稍后详细分析
                        setHeadAndPropagate(node, r);
                        p.next = null; //help GC
                        if (interrupted)
                            selfInterrupt();
                        failed = false;
                        return;
                    }
                }
                //否则，将前继节点设置为SIGNAL后，阻塞自己
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    interrupted = true;
            }
        } finally {
            if (failed)
                //获取失败
                cancelAcquire(node);
        }
    }
```

### 4.3.3 setHeadAndPropagate

__setHeadAndPropagate方法主要逻辑__

* 将当前节点设置为头结点，并且当仍有资源可供其他线程获取时，让其他线程继续获取资源，这也就是共享模式的含义
* 虽然在共享模式下可能有多个线程获取资源，但是有且仅有一个线程能够修改头结点(因为只有sync queue中第二个节点才能获取资源，而其他已经获取资源的线程已经不在队列中了)，因此头结点的修改是线程安全的

```Java
    /**
     * Sets head of queue, and checks if successor may be waiting
     * in shared mode, if so propagating if either propagate > 0 or
     * PROPAGATE status was set.
     *
     * @param node the node
     * @param propagate the return value from a tryAcquireShared
     */
    private void setHeadAndPropagate(Node node, int propagate) {
        Node h = head; //Record old head for check below
        //将当前节点设置为头结点
        setHead(node);
        /*
         * Try to signal next queued node if:
         *   Propagation was indicated by caller,
         *     or was recorded (as h.waitStatus either before
         *     or after setHead) by a previous operation
         *     (note: this uses sign-check of waitStatus because
         *      PROPAGATE status may transition to SIGNAL.)
         * and
         *   The next node is waiting in shared mode,
         *     or we don't know, because it appears null
         *
         * The conservatism in both of these checks may cause
         * unnecessary wake-ups, but only when there are multiple
         * racing acquires/releases, so most need signals now or soon
         * anyway.
         */
        //这是一堆极其诡异的条件，我暂时分析不清楚，但是感觉大概率是true，也就是，大概率会触发doReleaseShared方法
        if (propagate > 0 || h == null || h.waitStatus < 0 ||
            (h = head) == null || h.waitStatus < 0) {
            Node s = node.next;
            if (s == null || s.isShared())
                doReleaseShared();
        }
    }
```
doReleaseShared方法将放在下一小节中进行分析

## 4.4 releaseShared

__releaseShared方法是共享模式下实现解锁语义的入口方法__

```Java
    /**
     * Releases in shared mode.  Implemented by unblocking one or more
     * threads if {@link #tryReleaseShared} returns true.
     *
     * @param arg the release argument.  This value is conveyed to
     *        {@link #tryReleaseShared} but is otherwise uninterpreted
     *        and can represent anything you like.
     * @return the value returned from {@link #tryReleaseShared}
     */
    public final boolean releaseShared(int arg) {
        //通过tryReleaseShared方法尝试释放资源
        if (tryReleaseShared(arg)) {
            doReleaseShared();
            return true;
        }
        return false;
    }
```

### 4.4.1 tryReleaseShared

__tryReleaseShared方法用于判断是否能够释放资源__

* 交给AQS子类实现的方法，只需要定义释放资源的逻辑即可
* 该方法的实现不应该有耗时的操作，更不该阻塞

```Java
    protected boolean tryReleaseShared(int arg) {
        throw new UnsupportedOperationException();
    }
```

### 4.4.2 doReleaseShared

__doReleaseShared方法是共享模式下共享含义体现的重要方法__

* 该方法配合setHeadAndPropagate方法能够实现release propagate
* 如果仍有资源可获取，那么sync queue中的节点会陆续获取资源，直至无资源可获取或者队列为空时，传播停止

```Java
    /**
     * Release action for shared mode -- signals successor and ensures
     * propagation. (Note: For exclusive mode, release just amounts
     * to calling unparkSuccessor of head if it needs signal.)
     */
    private void doReleaseShared() {
        /*
         * Ensure that a release propagates, even if there are other
         * in-progress acquires/releases.  This proceeds in the usual
         * way of trying to unparkSuccessor of head if it needs
         * signal. But if it does not, status is set to PROPAGATE to
         * ensure that upon release, propagation continues.
         * Additionally, we must loop in case a new node is added
         * while we are doing this. Also, unlike other uses of
         * unparkSuccessor, we need to know if CAS to reset status
         * fails, if so rechecking.
         */
        for (;;) {
            Node h = head;
            if (h != null && h != tail) {
                int ws = h.waitStatus;
                //若头结点为SIGNAL状态，则将其通过CAS操作改为0
                if (ws == Node.SIGNAL) {
                    //如果失败，说明存在竞争，可能有其他线程也在执行该方法，那么由竞争成功的线程执行unparkSuccessor方法即可
                    if (!compareAndSetWaitStatus(h, Node.SIGNAL, 0))
                        continue;            //loop to recheck cases
                    //运行到这，说明当前线程竞争成功，执行unparkSuccessor唤醒头结点的后继节点，即sync queue中第二个节点
                    unparkSuccessor(h);
                }
                //如果头结点状态是0，意味着后面没有节点了，这里失败的可能原因是新节点加入，将头结点重新设置为SIGNAL
                else if (ws == 0 &&
                         !compareAndSetWaitStatus(h, 0, Node.PROPAGATE))
                    //如果CAS失败了，此时可能有新节点将头结点重新标记为SIGNAL，如果此时不执行continue，将会导致该方法结束，这样便没有达到propagate的目的，因此必须区分CAS结果进行不同处理
                    continue;                //loop on failed CAS
            }
            //如果头结点没有发生变化，则退出死循环
            if (h == head)                   //loop if head changed
                break;
        }
    }    
```

__为什么要将头节点从SIGNAL先改为0，再从0改为PROPAGATE，而不是直接从SIGNAL改成PROPAGATE？__

> 注意，当一次循环后头结点没有发生变化时，就会退出循环，因此__不可能__将同一个节点从SIGNAL改为0然后再从0改为PROPAGATE

> 将头结点从从SIGNAL先改为0时，唤醒后继节点，此时会有两种结果
> 1. 第一种结果是后继节点无法继续获取资源，导致传播状态结束，头结点重新被设置为SIGNAL，然后退出循环，结束该方法
> 1. 另一种结果是后继节点成功获取资源，并更新头结点，继续新一轮的循环
> 
> 可以看出，无论是哪种情况，原来的头结点都不会变为PROPAGATE状态

__仅有头结点能处于PROPAGATE，那么什么时候会被设置成PROPAGATE状态呢？__

> 当队列中仅有头结点时，其状态是0，然后被设置成PROPAGATE，表示一种传播状态，即仍有资源可供获取

## 4.5 acquireInterruptibly

__相比于acquire，acquireInterruptibly会响应interrupt，并且抛出InterruptedException异常__

```Java
    /**
     * Acquires in exclusive mode, aborting if interrupted.
     * Implemented by first checking interrupt status, then invoking
     * at least once {@link #tryAcquire}, returning on
     * success.  Otherwise the thread is queued, possibly repeatedly
     * blocking and unblocking, invoking {@link #tryAcquire}
     * until success or the thread is interrupted.  This method can be
     * used to implement method {@link Lock#lockInterruptibly}.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquire} but is otherwise uninterpreted and
     *        can represent anything you like.
     * @throws InterruptedException if the current thread is interrupted
     */
    public final void acquireInterruptibly(int arg)
            throws InterruptedException {
        //先检查一次是否被中断，如果是，则直接抛出异常
        if (Thread.interrupted())
            throw new InterruptedException();
        if (!tryAcquire(arg))
            doAcquireInterruptibly(arg);
    }
```

### 4.5.1 doAcquireInterruptibly

__doAcquireInterruptibly方法与acquireQueued的区别如下__

* acquireQueued在发现线程被中断时，并不立即响应，而是等方法返回后重现中断现场
* doAcquireInterruptibly在发现线程被中断时，立即响应，即抛出InterruptedException异常

__与acquireQueued方法的差异部分已用注释标记，其余部分的逻辑与acquireQueued类似，不再赘述__

```Java

    /**
     * Acquires in exclusive interruptible mode.
     * @param arg the acquire argument
     */
    private void doAcquireInterruptibly(int arg)
        throws InterruptedException {
        //将当前线程封装成独占模式下的节点，并入队
        final Node node = addWaiter(Node.EXCLUSIVE);
        boolean failed = true;
        try {
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; //help GC
                    failed = false;
                    return;
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    //与acquiredQueued的区别在此，这里是直接抛出异常
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```

## 4.6 acquireSharedInterruptibly

__相比于acquireShared，acquireSharedInterruptibly会响应interrupt，并且抛出InterruptedException异常__

```Java
    /**
     * Acquires in shared mode, aborting if interrupted.  Implemented
     * by first checking interrupt status, then invoking at least once
     * {@link #tryAcquireShared}, returning on success.  Otherwise the
     * thread is queued, possibly repeatedly blocking and unblocking,
     * invoking {@link #tryAcquireShared} until success or the thread
     * is interrupted.
     * @param arg the acquire argument.
     * This value is conveyed to {@link #tryAcquireShared} but is
     * otherwise uninterpreted and can represent anything
     * you like.
     * @throws InterruptedException if the current thread is interrupted
     */
    public final void acquireSharedInterruptibly(int arg)
            throws InterruptedException {
        //首先检查一下是否被中断，如果是，则直接抛出InterruptedException异常
        if (Thread.interrupted())
            throw new InterruptedException();
        if (tryAcquireShared(arg) < 0)
            doAcquireSharedInterruptibly(arg);
    }
```

### 4.6.1 doAcquireSharedInterruptibly

__doAcquireSharedInterruptibly方法与doAcquireShared的区别如下__

* doAcquireShared在发现线程被中断时，并不立即响应，而是等方法返回后重现中断现场
* doAcquireSharedInterruptibly在发现线程被中断时，立即响应，即抛出InterruptedException异常

__与doAcquireShared方法的差异部分已用注释标记，其余部分的逻辑与doAcquireShared类似，不再赘述__

```Java
    /**
     * Acquires in shared interruptible mode.
     * @param arg the acquire argument
     */
    private void doAcquireSharedInterruptibly(int arg)
        throws InterruptedException {
        //将当前线程封装成共享模式下的节点，并添加到sync queue中
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            for (;;) {
                final Node p = node.predecessor();
                if (p == head) {
                    int r = tryAcquireShared(arg);
                    if (r >= 0) {
                        setHeadAndPropagate(node, r);
                        p.next = null; //help GC
                        failed = false;
                        return;
                    }
                }
                if (shouldParkAfterFailedAcquire(p, node) &&
                    parkAndCheckInterrupt())
                    //与doAcquireShared的区别在此，这里是直接抛出异常
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```

## 4.7 tryAcquireNanos

__独占模式下，该方法允许阻塞指定时间，同时能够响应中断__

```Java
    /**
     * Attempts to acquire in exclusive mode, aborting if interrupted,
     * and failing if the given timeout elapses.  Implemented by first
     * checking interrupt status, then invoking at least once {@link
     * #tryAcquire}, returning on success.  Otherwise, the thread is
     * queued, possibly repeatedly blocking and unblocking, invoking
     * {@link #tryAcquire} until success or the thread is interrupted
     * or the timeout elapses.  This method can be used to implement
     * method {@link Lock#tryLock(long, TimeUnit)}.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquire} but is otherwise uninterpreted and
     *        can represent anything you like.
     * @param nanosTimeout the maximum number of nanoseconds to wait
     * @return {@code true} if acquired; {@code false} if timed out
     * @throws InterruptedException if the current thread is interrupted
     */
    public final boolean tryAcquireNanos(int arg, long nanosTimeout)
            throws InterruptedException {
        if (Thread.interrupted())
            throw new InterruptedException();
        return tryAcquire(arg) ||
            doAcquireNanos(arg, nanosTimeout);
    }
```

### 4.7.1 doAcquireNanos

__doAcquireNanos方法与acquireQueued的区别如下__

* acquireQueued会阻塞直至获取资源，且不响应中断，只是在返回后恢复中断现场
* doAcquireNanos会阻塞直至获取资源或者超时，且可以响应中断，直接抛出InterruptedException异常

__与acquireQueued方法的差异部分已用注释标记，其余部分的逻辑与acquireQueued类似，不再赘述__

```Java
    /**
     * Acquires in exclusive timed mode.
     *
     * @param arg the acquire argument
     * @param nanosTimeout max wait time
     * @return {@code true} if acquired
     */
    private boolean doAcquireNanos(int arg, long nanosTimeout)
            throws InterruptedException {
        //若指定的阻塞时间小于0，则直接返回false
        if (nanosTimeout <= 0L)
            return false;
        //设置超时时刻
        final long deadline = System.nanoTime() + nanosTimeout;
        final Node node = addWaiter(Node.EXCLUSIVE);
        boolean failed = true;
        try {
            for (;;) {
                final Node p = node.predecessor();
                if (p == head && tryAcquire(arg)) {
                    setHead(node);
                    p.next = null; //help GC
                    failed = false;
                    return true;
                }
                //剩余等待时间
                nanosTimeout = deadline - System.nanoTime();
                //如果已超时，则直接返回
                if (nanosTimeout <= 0L)
                    return false;
                //当剩余时间超过阻塞阈值时，阻塞自己一段时间，否则自旋等待
                if (shouldParkAfterFailedAcquire(p, node) &&
                    nanosTimeout > spinForTimeoutThreshold)
                    LockSupport.parkNanos(this, nanosTimeout);
                //若已被中断，则抛出异常响应中断
                if (Thread.interrupted())
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }
```

## 4.8 tryAcquireSharedNanos

__共享模式下，该方法允许阻塞指定时间，同时能够响应中断__

```Java
    /**
     * Attempts to acquire in shared mode, aborting if interrupted, and
     * failing if the given timeout elapses.  Implemented by first
     * checking interrupt status, then invoking at least once {@link
     * #tryAcquireShared}, returning on success.  Otherwise, the
     * thread is queued, possibly repeatedly blocking and unblocking,
     * invoking {@link #tryAcquireShared} until success or the thread
     * is interrupted or the timeout elapses.
     *
     * @param arg the acquire argument.  This value is conveyed to
     *        {@link #tryAcquireShared} but is otherwise uninterpreted
     *        and can represent anything you like.
     * @param nanosTimeout the maximum number of nanoseconds to wait
     * @return {@code true} if acquired; {@code false} if timed out
     * @throws InterruptedException if the current thread is interrupted
     */
    public final boolean tryAcquireSharedNanos(int arg, long nanosTimeout)
            throws InterruptedException {
        //如果已被中断，则直接抛出InterruptedException异常
        if (Thread.interrupted())
            throw new InterruptedException();
        return tryAcquireShared(arg) >= 0 ||
            doAcquireSharedNanos(arg, nanosTimeout);
    }
```

### 4.8.1 doAcquireSharedNanos

__doAcquireSharedNanos方法与acquireShared的区别如下__

* acquireShared会阻塞直至获取资源，且不响应中断，只是在返回后恢复中断现场
* doAcquireSharedNanos会阻塞直至获取资源或者超时，且可以响应中断，直接抛出InterruptedException异常

__与acquireShared方法的差异部分已用注释标记，其余部分的逻辑与acquireShared类似，不再赘述__

```Java
    /**
     * Acquires in shared timed mode.
     *
     * @param arg the acquire argument
     * @param nanosTimeout max wait time
     * @return {@code true} if acquired
     */
    private boolean doAcquireSharedNanos(int arg, long nanosTimeout)
            throws InterruptedException {
        //若指定的阻塞时间小于0，则直接返回false
        if (nanosTimeout <= 0L)
            return false;
        //设定超时时刻
        final long deadline = System.nanoTime() + nanosTimeout;
        final Node node = addWaiter(Node.SHARED);
        boolean failed = true;
        try {
            for (;;) {
                final Node p = node.predecessor();
                if (p == head) {
                    int r = tryAcquireShared(arg);
                    if (r >= 0) {
                        setHeadAndPropagate(node, r);
                        p.next = null; //help GC
                        failed = false;
                        return true;
                    }
                }
                //更新剩余时间
                nanosTimeout = deadline - System.nanoTime();
                //若已经超时，则直接返回
                if (nanosTimeout <= 0L)
                    return false;
                //若剩余时间超过阻塞阈值，则阻塞自己指定时间，否则自旋等待
                if (shouldParkAfterFailedAcquire(p, node) &&
                    nanosTimeout > spinForTimeoutThreshold)
                    LockSupport.parkNanos(this, nanosTimeout);
                //如果已被中断，则抛出InterruptedException异常
                if (Thread.interrupted())
                    throw new InterruptedException();
            }
        } finally {
            if (failed)
                cancelAcquire(node);
        }
    }

```
