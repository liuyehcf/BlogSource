---
title: Java concurrent FutureTask 源码剖析
date: 2017-07-02 22:56:02
tags:
categories:
- Java concurrent 源码剖析
---


# 1 前言

__FutureTask源码分析将分为以下几个部分__

1. 继承体系介绍
1. 常量简介
1. 字段简介
1. 内部类简介
1. 重要方法源码分析

<!--more-->

# 2 继承体系介绍

# 3 Future接口

```Java
public interface Future<V> {

    //取消任务的执行
        //1. 如果任务已经完成，或者已经被取消，或者由于某种原因不能取消，则返回false。具体要看实现类的逻辑
        //2. 如果成功取消，且任务尚未开始执行，那么任务将不会执行
        //3. 如果成功取消，且任务正在执行，且参数为true，则给当前执行任务的线程发送中断信号
    boolean cancel(boolean mayInterruptIfRunning);
    
    //任务是否被取消
    boolean isCancelled();

    //任务是否完成
    boolean isDone();

    //获取任务结果，若任务未完成，则阻塞当前调用get的线程，直至任务完成
    V get() throws InterruptedException, ExecutionException;

    //获取任务结果，若任务未完成，则阻塞当前调用get的线程，直至任务完成或者超时
    V get(long timeout, TimeUnit unit)
        throws InterruptedException, ExecutionException, TimeoutException;
}
```

## &emsp;3.1 RunnableFuture

__接口仅仅继承了Runnable接口与Future接口，FutureTask实现了RunnableFuture接口__


# 4 常量简介

__FutureTask定义了7个状态常量来表示FutureTask自身的状态__

```Java
    private static final int NEW          = 0;
    private static final int COMPLETING   = 1;
    private static final int NORMAL       = 2;
    private static final int EXCEPTIONAL  = 3;
    private static final int CANCELLED    = 4;
    private static final int INTERRUPTING = 5;
    private static final int INTERRUPTED  = 6;
```

* __NEW__：初始状态，FutureTask对象创建完毕后就处于这个状态
* __COMPLETING__：暂时状态，位于NEW-->NORMAL或者NEW-->EXCEPTION的中间状态。处于该状态下时，会进行outcome的赋值操作，赋值操作完毕后，立即进入NORMAL或者EXCEPTION状态中去
* __NORMAL__：最终状态，正常结束时FutureTask就是这个状态
* __EXCEPTIONAL__：最终状态，任务执行过程中如果抛出异常，那么FutureTask最终会处于该状态下
* __CANCELLED__：最终状态，执行cancel方法，并且mayInterruptIfRunning为false时，FutureTask最终处于该状态
* __INTERRUPTING__：暂时状态，执行cancel方法，并且mayInterruptIfRunning为true时，FutureTask会处于该状态，随后会给关联线程发送一个中断信号，然后转移到INTERRUPTED状态
* __INTERRUPTED__：最终状态，执行cancel方法，并且mayInterruptIfRunning为true时，FutureTask会处于该状态

# 5 字段简介

__FutureTask仅有以下五个字段__

```Java
    /**
     * The run state of this task, initially NEW.  The run state
     * transitions to a terminal state only in methods set,
     * setException, and cancel.  During completion, state may take on
     * transient values of COMPLETING (while outcome is being set) or
     * INTERRUPTING (only while interrupting the runner to satisfy a
     * cancel(true)). Transitions from these intermediate to final
     * states use cheaper ordered/lazy writes because values are unique
     * and cannot be further modified.
     *
     * Possible state transitions:
     * NEW -> COMPLETING -> NORMAL
     * NEW -> COMPLETING -> EXCEPTIONAL
     * NEW -> CANCELLED
     * NEW -> INTERRUPTING -> INTERRUPTED
     */
    private volatile int state;


    /** The underlying callable; nulled out after running */
    private Callable<V> callable;

    /** The result to return or exception to throw from get() */
    //用于保存callable正常执行的结果，或者是保存抛出的异常
    private Object outcome; // non-volatile, protected by state reads/writes

    /** The thread running the callable; CASed during run() */
    //该Runnable关联的线程，该字段只有在run方法内才会赋值(执行线程和创建FutureTask的线程并非同一个)
    private volatile Thread runner;

    /** Treiber stack of waiting threads */
    //封装了线程的节点
    private volatile WaitNode waiters;
```

# 6 内部类简介

## &emsp;6.1 WaitNode

__WaitNode将Thread对象封装成一个链表的节点__

* 那些阻塞在get()方法调用中的线程将会在此链表中排队等候
* 当任务完成或者异常结束时，FutureTask会依次唤醒阻塞在get()方法中的线程

```Java
    /**
     * Simple linked list nodes to record waiting threads in a Treiber
     * stack.  See other classes such as Phaser and SynchronousQueue
     * for more detailed explanation.
     */
    static final class WaitNode {
        volatile Thread thread;
        volatile WaitNode next;
        WaitNode() { thread = Thread.currentThread(); }
    }
```

# 7 重要方法源码分析

## &emsp;7.1 构造方法

__FutureTask含有两个构造方法__

* 一个构造方法接受一个Callable对象
* 另一个构造方法接受一个Runnable对象，和一个Result。

```Java
    /**
     * Creates a {@code FutureTask} that will, upon running, execute the
     * given {@code Callable}.
     *
     * @param  callable the callable task
     * @throws NullPointerException if the callable is null
     */
    public FutureTask(Callable<V> callable) {
        if (callable == null)
            throw new NullPointerException();
        this.callable = callable;
        this.state = NEW;       // ensure visibility of callable
    }

    /**
     * Creates a {@code FutureTask} that will, upon running, execute the
     * given {@code Runnable}, and arrange that {@code get} will return the
     * given result on successful completion.
     *
     * @param runnable the runnable task
     * @param result the result to return on successful completion. If
     * you don't need a particular result, consider using
     * constructions of the form:
     * {@code Future<?> f = new FutureTask<Void>(runnable, null)}
     * @throws NullPointerException if the runnable is null
     */
    public FutureTask(Runnable runnable, V result) {
        //将Runnable适配成Callable
        this.callable = Executors.callable(runnable, result);
        this.state = NEW;       // ensure visibility of callable
    }
```

### &emsp;&emsp;&emsp;7.1.1 Executors.callable

__该静态方法负责将Runnable对象适配成一个Callable对象__

```Java
    /**
     * Returns a {@link Callable} object that, when
     * called, runs the given task and returns the given result.  This
     * can be useful when applying methods requiring a
     * {@code Callable} to an otherwise resultless action.
     * @param task the task to run
     * @param result the result to return
     * @param <T> the type of the result
     * @return a callable object
     * @throws NullPointerException if task null
     */
    public static <T> Callable<T> callable(Runnable task, T result) {
        if (task == null)
            throw new NullPointerException();
        return new RunnableAdapter<T>(task, result);
    }
```

__其中适配器RunnableAdapter如下__

* 该类仅仅是将一个Runnable对象适配成一个Callable对象，并无他用
* 注意到result通过构造方法进行赋值，然后在call方法中直接返回，与Runnable无任何关系

```Java

    /**
     * A callable that runs given task and returns given result
     */
    static final class RunnableAdapter<T> implements Callable<T> {
        final Runnable task;
        final T result;
        RunnableAdapter(Runnable task, T result) {
            this.task = task;
            this.result = result;
        }
        public T call() {
            //转调用Runnable的run方法
            task.run();
            //直接返回构造方法中传入的result
            return result;
        }
    }
```


## &emsp;7.2 run

__线程执行的主要方法__

* 首先判断状态，只有NEW状态才能正常执行该方法，否则说明被cancel了。
* 执行Callable的call方法，正常执行或者异常执行将会触发不同的状态转移方法

```Java
    public void run() {
        //当且仅当state==NEW 并且 CAS执行成功的线程才能继续执行
        //为什么需要CAS？FutureTask可能并不一定需要单独开一个线程来执行，总之保证有且仅有一个线程执行这个方法
        if (state != NEW ||
            !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                         null, Thread.currentThread()))
            return;
        try {
            Callable<V> c = callable;
            if (c != null && state == NEW) {
                V result;
                boolean ran;
                try {
                    //调用Callable#call方法，这里才是业务逻辑执行的入口
                    result = c.call();
                    ran = true;
                } catch (Throwable ex) {
                    result = null;
                    ran = false;
                    //异常调用时，设置FutureTask的状态
                    setException(ex);
                }
                if (ran)
                    //正常调用时，设置FutureTask的状态
                    set(result);
            }
        } finally {
            // runner must be non-null until state is settled to
            // prevent concurrent calls to run()
            runner = null;
            // state must be re-read after nulling runner to prevent
            // leaked interrupts
            int s = state;
            //确保该方法退出时，FutureTask处于最终状态，即NORMAL/EXCEPTIONAL/CANCELLED/INTERRUPTED状态中的一种
            if (s >= INTERRUPTING)
                handlePossibleCancellationInterrupt(s);
        }
    }
```

### &emsp;&emsp;&emsp;7.2.1 setException

__该方法逻辑如下__

* 该方法将FutureTask的状态通过CAS改为COMPLETING
* 然后将outcome赋值为异常对象
* 最后唤醒阻塞线程

```Java
    /**
     * Causes this future to report an {@link ExecutionException}
     * with the given throwable as its cause, unless this future has
     * already been set or has been cancelled.
     *
     * <p>This method is invoked internally by the {@link #run} method
     * upon failure of the computation.
     *
     * @param t the cause of failure
     */
    protected void setException(Throwable t) {
        if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
            outcome = t;
            UNSAFE.putOrderedInt(this, stateOffset, EXCEPTIONAL); // final state
            finishCompletion();
        }
    }
```

### &emsp;&emsp;&emsp;7.2.2 set

__该方法逻辑如下__

* 该方法将FutureTask的状态通过CAS改为COMPLETING
* 然后将outcome赋值Callable#run的返回结果
* 最后唤醒阻塞线程

```Java
    /**
     * Sets the result of this future to the given value unless
     * this future has already been set or has been cancelled.
     *
     * <p>This method is invoked internally by the {@link #run} method
     * upon successful completion of the computation.
     *
     * @param v the value
     */
    protected void set(V v) {
        if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
            outcome = v;
            UNSAFE.putOrderedInt(this, stateOffset, NORMAL); // final state
            finishCompletion();
        }
    }
```

### &emsp;&emsp;&emsp;7.2.3 finishCompletion

__该方法会唤醒所有阻塞在get方法中的所有WaitNode节点__

```Java
    /**
     * Removes and signals all waiting threads, invokes done(), and
     * nulls out callable.
     */
    private void finishCompletion() {
        // assert state > COMPLETING;
        for (WaitNode q; (q = waiters) != null;) {
            //CAS成功的线程才能唤醒节点，例如执行cancel的线程和执行run的线程可能会发生冲突
            if (UNSAFE.compareAndSwapObject(this, waitersOffset, q, null)) {
                //逐个按顺序唤醒阻塞线程
                for (;;) {
                    Thread t = q.thread;
                    if (t != null) {
                        q.thread = null;
                        LockSupport.unpark(t);
                    }
                    WaitNode next = q.next;
                    if (next == null)
                        break;
                    q.next = null; // unlink to help gc
                    q = next;
                }
                break;
            }
        }

        done();

        callable = null;        // to reduce footprint
    }
```

### &emsp;&emsp;&emsp;7.2.4 handlePossibleCancellationInterrupt
```Java
    /**
     * Ensures that any interrupt from a possible cancel(true) is only
     * delivered to a task while in run or runAndReset.
     */
    private void handlePossibleCancellationInterrupt(int s) {
        // It is possible for our interrupter to stall before getting a
        // chance to interrupt us.  Let's spin-wait patiently.
        //如果处于INTERRUPTING，则说明有一个线程正在执行cancel方法，此处只需等待执行完毕即可
        if (s == INTERRUPTING)
            while (state == INTERRUPTING)
                Thread.yield(); // wait out pending interrupt

        // assert state == INTERRUPTED;

        // We want to clear any interrupt we may have received from
        // cancel(true).  However, it is permissible to use interrupts
        // as an independent mechanism for a task to communicate with
        // its caller, and there is no way to clear only the
        // cancellation interrupt.
        //
        // Thread.interrupted();
    }
```


## &emsp;7.3 get

__get方法有两个重载版本__

* 第一个版本会阻塞线程，直至FutureTask以某种方式结束后被唤醒
* 第二个版本可以设定最长阻塞时间。阻塞线程，直至FutureTask以某种方式结束后被唤醒，或者超时。

```Java
    /**
     * @throws CancellationException {@inheritDoc}
     */
    public V get() throws InterruptedException, ExecutionException {
        int s = state;
        if (s <= COMPLETING)
            //无限阻塞
            s = awaitDone(false, 0L);
        return report(s);
    }

    /**
     * @throws CancellationException {@inheritDoc}
     */
    public V get(long timeout, TimeUnit unit)
        throws InterruptedException, ExecutionException, TimeoutException {
        if (unit == null)
            throw new NullPointerException();
        int s = state;
        //条件的意思是，当状态小于等于COMPLETING时阻塞当前线程，如果被唤醒时，状态仍然小于等于COMPLETING，说明是阻塞超时后自动唤醒。于是抛出TimeoutException异常
        if (s <= COMPLETING &&
            (s = awaitDone(true, unit.toNanos(timeout))) <= COMPLETING)
            throw new TimeoutException();
        return report(s);
    }
```

### &emsp;&emsp;&emsp;7.3.1 awaitDone

__阻塞get()方法的调用线程__

```Java
    /**
     * Awaits completion or aborts on interrupt or timeout.
     *
     * @param timed true if use timed waits
     * @param nanos time to wait, if timed
     * @return state upon completion
     */
    private int awaitDone(boolean timed, long nanos)
        throws InterruptedException {
        //超时时间
        final long deadline = timed ? System.nanoTime() + nanos : 0L;
        WaitNode q = null;
        boolean queued = false;
        for (;;) {
            //检查是否已被中断，如果已被中断，那么将当前线程所关联的WaiterNode移出等待链表
            if (Thread.interrupted()) {
                removeWaiter(q);
                throw new InterruptedException();
            }

            int s = state;
            //当FutureTask已处于最终状态，即run方法已经执行完毕，或者已被cancel
                //1. 如果是第一次循环，即该线程关联的节点尚未入队
                //2. 如果已经入队了，finishCompletion方法在唤醒阻塞节点时会自动跳过这些thread字段为null的节点
            if (s > COMPLETING) {
                if (q != null)
                    //将节点关联的线程置空，removeWaiter方法会将这些thread字段为空的WaiterWaiter移出链表
                    q.thread = null;
                return s;
            }
            //当FutureTask处于暂时状态，等待片刻即可
            else if (s == COMPLETING) // cannot time out yet
                Thread.yield();
            else if (q == null)
                q = new WaitNode();
            //尚未入队，那么通过CAS串行化入队操作
            else if (!queued)
                queued = UNSAFE.compareAndSwapObject(this, waitersOffset,
                                                     q.next = waiters, q);
            //此时已入队，且允许超时阻塞
            else if (timed) {
                //计算剩余阻塞时间
                nanos = deadline - System.nanoTime();
                //此时已超时，将WaiterNode移出链表后返回
                if (nanos <= 0L) {
                    removeWaiter(q);
                    return state;
                }
                //阻塞一段时间
                LockSupport.parkNanos(this, nanos);
            }
            //无限阻塞，直至被唤醒
            else
                LockSupport.park(this);
        }
    }

```

### &emsp;&emsp;&emsp;7.3.2 removeWaiter

__将一个阻塞超时的节点，或者被中断的节点移出链表__

* 这个方法可能存在竞争，但是Doug Lea(作者)并未采用CAS操作串行化链表处理，而是采用另一种方式，一旦发现异常就重新遍历链表
* 这种方式在链表非常长且存在竞争时会导致效率比较低，但是Doug Lea认为并不需要考虑这种特殊情况

```Java
    /**
     * Tries to unlink a timed-out or interrupted wait node to avoid
     * accumulating garbage.  Internal nodes are simply unspliced
     * without CAS since it is harmless if they are traversed anyway
     * by releasers.  To avoid effects of unsplicing from already
     * removed nodes, the list is retraversed in case of an apparent
     * race.  This is slow when there are a lot of nodes, but we don't
     * expect lists to be long enough to outweigh higher-overhead
     * schemes.
     */
    private void removeWaiter(WaitNode node) {
        if (node != null) {
            node.thread = null;
            retry:
            for (;;) {          // restart on removeWaiter race
                for (WaitNode pred = null, q = waiters, s; q != null; q = s) {
                    s = q.next;
                    if (q.thread != null)
                        pred = q;
                    //q.thread==null，且pred!=null，那么需要将q节点从链表中除去
                    else if (pred != null) {
                        pred.next = s;
                        //如果发现pred.thread==null，说明被其他线程改过了，重新遍历一遍节点链表
                        if (pred.thread == null) // check for race
                            continue retry;
                    }
                    //q.thread==null 且 pred==null，说明当前q是头节点，且q是无效节点，因此更改链表的头结点
                    else if (!UNSAFE.compareAndSwapObject(this, waitersOffset,
                                                          q, s))
                        //若CAS失败，说明存在竞争，重新遍历链表
                        continue retry;
                }
                break;
            }
        }
    }
```


### &emsp;&emsp;&emsp;7.3.3 report

__根据FutureTask的状态，返回相应的结果__

* 若FutureTask的最终状态是NORMAL，说明Callable#call正常执行，返回Callable#call方法返回的结果即可
* 若FutureTask的最终状态大于等于CANCEL，说明FutureTask被cancel了，抛出CancellationException异常
* 否则FutureTask的最终状态是EXCEPTIONAL，说明Callable#call执行过程中抛出异常，抛出ExecutionException异常

```Java

    /**
     * Returns result or throws exception for completed task.
     *
     * @param s completed state value
     */
    @SuppressWarnings("unchecked")
    private V report(int s) throws ExecutionException {
        Object x = outcome;
        //说明Callable#call正常执行
        if (s == NORMAL)
            return (V)x;
        //说明FutureTask被cancel了
        if (s >= CANCELLED)
            throw new CancellationException();
        //说明Callable#call执行过程中抛出异常
        throw new ExecutionException((Throwable)x);
    }
```