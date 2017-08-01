---
title: Java concurrent Fork-Join 源码剖析
date: 2017-08-01 17:12:17
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

# 1 什么是Fork/Join框架

Fork/Join框架是Java7提供了的一个用于并行执行任务的框架，是一个把大任务分割成若干个小任务，最终汇总每个小任务结果后得到大任务结果的框架。

我们再通过Fork和Join这两个单词来理解下Fork/Join框架，Fork就是把一个大任务切分为若干子任务并行的执行，Join就是合并这些子任务的执行结果，最后得到这个大任务的结果。比如计算1+2+...＋10000，可以分割成10个子任务，每个子任务分别对1000个数进行求和，最终汇总这10个子任务的结果。Fork/Join的运行流程图如下：

![fig1](/images/Java-concurrent-Fork-Join-源码剖析/fig1.png)

## 1.1 工作窃取算法

工作窃取（work-stealing）算法是指某个线程从其他队列里窃取任务来执行。工作窃取的运行流程图如下：

![fig2](/images/Java-concurrent-Fork-Join-源码剖析/fig2.png)

那么为什么需要使用工作窃取算法呢？假如我们需要做一个比较大的任务，我们可以把这个任务分割为若干互不依赖的子任务，为了减少线程间的竞争，于是把这些子任务分别放到不同的队列里，并为每个队列创建一个单独的线程来执行队列里的任务，线程和队列一一对应，比如A线程负责处理A队列里的任务。但是有的线程会先把自己队列里的任务干完，而其他线程对应的队列里还有任务等待处理。干完活的线程与其等着，不如去帮其他线程干活，于是它就去其他线程的队列里窃取一个任务来执行。而在这时它们会访问同一个队列，所以为了减少窃取任务线程和被窃取任务线程之间的竞争，__通常会使用双端队列，被窃取任务线程永远从双端队列的头部拿任务执行，而窃取任务的线程永远从双端队列的尾部拿任务执行。__

工作窃取算法的优点是充分利用线程进行并行计算，并减少了线程间的竞争，其缺点是在某些情况下还是存在竞争，比如双端队列里只有一个任务时。并且消耗了更多的系统资源，比如创建多个线程和多个双端队列。

# 2 ForkJoinTask继承体系

要利用ForkJoin框架，必须继承ForkJoinTask的两个子类中的一个：RecursiveTask、RecursiveAction

ForkJoinTask的继承结构如下图所示

![fig3](/images/Java-concurrent-Fork-Join-源码剖析/fig3.png)

## 2.1 RecursiveAction

RecursiveAction源码如下，比较简单。其compute方法需要子类来实现，compute方法主要用于定义运算逻辑以及fork和join的逻辑，即定义何时该fork何时该join。for和join方法详见ForkJoinTask的源码分析

RecursiveAction与RecursiveTask的区别在于：

1. RecursiveAction执行的任务没有结果
1. RecursiveTask执行的任务有结果

```Java
public abstract class RecursiveAction extends ForkJoinTask<Void> {
    private static final long serialVersionUID = 5232453952276485070L;

    /**
     * The main computation performed by this task.
     */
    protected abstract void compute();

    /**
     * Always returns {@code null}.
     *
     * @return {@code null} always
     */
    public final Void getRawResult() { return null; }

    /**
     * Requires null completion value.
     */
    protected final void setRawResult(Void mustBeNull) { }

    /**
     * Implements execution conventions for RecursiveActions.
     */
    protected final boolean exec() {
        compute();
        return true;
    }

}
```

## 2.2 RecursiveTask

RecursiveTask源码如下，比较简单。其compute方法需要子类来实现，compute方法主要用于定义运算逻辑以及fork和join的逻辑，即定义何时该fork何时该join。for和join方法详见ForkJoinTask的源码分析

```Java
public abstract class RecursiveTask<V> extends ForkJoinTask<V> {
    private static final long serialVersionUID = 5232453952276485270L;

    /**
     * The result of the computation.
     */
    V result;

    /**
     * The main computation performed by this task.
     * @return the result of the computation
     */
    protected abstract V compute();

    public final V getRawResult() {
        return result;
    }

    protected final void setRawResult(V value) {
        result = value;
    }

    /**
     * Implements execution conventions for RecursiveTask.
     */
    protected final boolean exec() {
        result = compute();
        return true;
    }

}
```

# 3 ForkJoinTask

## 3.1 常量

```Java
    static final int DONE_MASK   = 0xf0000000;  // mask out non-completion bits
    static final int NORMAL      = 0xf0000000;  // must be negative
    static final int CANCELLED   = 0xc0000000;  // must be < NORMAL
    static final int EXCEPTIONAL = 0x80000000;  // must be < CANCELLED
    static final int SIGNAL      = 0x00010000;  // must be >= 1 << 16
    static final int SMASK       = 0x0000ffff;  // short bits for tags
```

* __DONE_MASK__：completion的掩码，即高四位为completion bits
* __NORMAL__：正常状态，负数
* __CANCELLED__：取消状态，负数，且小于NORMAL
* __EXCEPTIONAL__：异常状态，负数，且小于CANCELLED
* __SIGNAL__：？？？
* __SMASK__：tags的掩码，即低四位

## 3.2 字段

```Java
    volatile int status; // accessed directly by pool and workers
```

* __status__：用于标记任务的状态

## 3.3 重要方法

### 3.3.1 fork

```Java
    /**
     * Arranges to asynchronously execute this task in the pool the
     * current task is running in, if applicable, or using the {@link
     * ForkJoinPool#commonPool()} if not {@link #inForkJoinPool}.  While
     * it is not necessarily enforced, it is a usage error to fork a
     * task more than once unless it has completed and been
     * reinitialized.  Subsequent modifications to the state of this
     * task or any data it operates on are not necessarily
     * consistently observable by any thread other than the one
     * executing it unless preceded by a call to {@link #join} or
     * related methods, or a call to {@link #isDone} returning {@code
     * true}.
     *
     * @return {@code this}, to simplify usage
     */
    public final ForkJoinTask<V> fork() {
        Thread t;
        // 如果当前线程的类型为ForkJoinWorkerThread，意味着当前任务已经在ForkJoinPool中进行处理了
        if ((t = Thread.currentThread()) instanceof ForkJoinWorkerThread)
            // 将当前任务添加到ForkJoinWorkerThread#workQueue中
            ((ForkJoinWorkerThread)t).workQueue.push(this);
        else
            // 否则公用一个ForkJoinPool处理任务，common是一个静态字段，类型为ForkJoinPool
            ForkJoinPool.common.externalPush(this);
        return this;
    }
```

### 3.3.2 join

```Java
    /**
     * Returns the result of the computation when it {@link #isDone is
     * done}.  This method differs from {@link #get()} in that
     * abnormal completion results in {@code RuntimeException} or
     * {@code Error}, not {@code ExecutionException}, and that
     * interrupts of the calling thread do <em>not</em> cause the
     * method to abruptly return by throwing {@code
     * InterruptedException}.
     *
     * @return the computed result
     */
    public final V join() {
        int s;
        if ((s = doJoin() & DONE_MASK) != NORMAL)
            reportException(s);
        return getRawResult();
    }
```

#### 3.3.2.1 doJoin

doJoin方法执行具体的join逻辑，即合并各个线程执行任务的结果

```Java
    /**
     * Implementation for join, get, quietlyJoin. Directly handles
     * only cases of already-completed, external wait, and
     * unfork+exec.  Others are relayed to ForkJoinPool.awaitJoin.
     *
     * @return status upon completion
     */
    private int doJoin() {
        int s; Thread t; ForkJoinWorkerThread wt; ForkJoinPool.WorkQueue w;
        // 下面这个符合语句显得有的复杂，我们进行一下分解
        // 1. 当前状态为负数，即高四位为NORMAL或CANCELLED或EXCEPTIONAL，返回当前状态
        // 2. 当前状态为非负数，当前线程为ForkJoinWorkerThread，且tryUnpush(this)方法返回true且doExec()返回负数时，返回doExec()方法返回的结果
        // 3. 当前状态为非负数，当前线程为ForkJoinWorkerThread，且tryUnpush(this)方法返回false或doExec()返回非负数时，返回wt.pool.awaitJoin(w, this, 0L)方法执行的结果
        // 4. 当前状态为非负数，且当前线程为普通线程时，执行externalAwaitDone
        return (s = status) < 0 ? s :
            ((t = Thread.currentThread()) instanceof ForkJoinWorkerThread) ?
            (w = (wt = (ForkJoinWorkerThread)t).workQueue).
            tryUnpush(this) && (s = doExec()) < 0 ? s :
            wt.pool.awaitJoin(w, this, 0L) :
            externalAwaitDone();
    }
```

* tryUnpush方法详见ForkJoinPool源码剖析

#### 3.3.2.2 doExec

该方法主要目的就是调用exec()方法，该方法是ForkJoinTask暴露给子类的抽象方法，而其子类RecursiveAction与RecursiveTask又对exec()方法进行了一层封装，对外暴露compute方法，因此对于RecursiveAction与RecursiveTask来说，doExec方法最终执行的就是compute()方法的逻辑，也就是用户自定义的运算逻辑

为什么RecursiveAction与RecursiveTask需要对exec()方法再做一层封装？因为exec()方法是有返回值的，而RecursiveAction与RecursiveTask为了提供不同的语义，需要对外暴露不同的compute方法(其返回类型不同)，因此不能直接暴露exec方法给用户

```Java
    /**
     * Primary execution method for stolen tasks. Unless done, calls
     * exec and records status if completed, but doesn't wait for
     * completion otherwise.
     *
     * @return status on exit from this method
     */
    final int doExec() {
        int s; boolean completed;
        if ((s = status) >= 0) {
            try {
                // 其中exec方法是一个抽象方法，其实现详见RecursiveAction与RecursiveTask
                completed = exec();
            } catch (Throwable rex) {
                return setExceptionalCompletion(rex);
            }
            if (completed)
                // 设置任务的状态为正常
                s = setCompletion(NORMAL);
        }
        return s;
    }
```

#### 3.3.2.3 externalAwaitDone

```Java
    /**
     * Blocks a non-worker-thread until completion.
     * @return status upon completion
     */
    private int externalAwaitDone() {
        int s = ((this instanceof CountedCompleter) ? // try helping
                 ForkJoinPool.common.externalHelpComplete(
                     (CountedCompleter<?>)this, 0) :
                 ForkJoinPool.common.tryExternalUnpush(this) ? doExec() : 0);
        if (s >= 0 && (s = status) >= 0) {
            boolean interrupted = false;
            do {
                if (U.compareAndSwapInt(this, STATUS, s, s | SIGNAL)) {
                    synchronized (this) {
                        if (status >= 0) {
                            try {
                                wait(0L);
                            } catch (InterruptedException ie) {
                                interrupted = true;
                            }
                        }
                        else
                            notifyAll();
                    }
                }
            } while ((s = status) >= 0);
            if (interrupted)
                Thread.currentThread().interrupt();
        }
        return s;
    }
```

### 3.3.3 invoke

```Java
    /**
     * Commences performing this task, awaits its completion if
     * necessary, and returns its result, or throws an (unchecked)
     * {@code RuntimeException} or {@code Error} if the underlying
     * computation did so.
     *
     * @return the computed result
     */
    public final V invoke() {
        int s;
        if ((s = doInvoke() & DONE_MASK) != NORMAL)
            reportException(s);
        return getRawResult();
    }
```

# 4 ForkJoinPool

## 4.1 常量

```Java
    static final int SMASK        = 0xffff;        // short bits == max index
    static final int MAX_CAP      = 0x7fff;        // max #workers - 1
    static final int EVENMASK     = 0xfffe;        // even short bits
    static final int SQMASK       = 0x007e;        // max 64 (even) slots

    // Masks and units for WorkQueue.scanState and ctl sp subfield
    static final int SCANNING     = 1;             // false when running tasks
    static final int INACTIVE     = 1 << 31;       // must be negative
    static final int SS_SEQ       = 1 << 16;       // version count

    // Mode bits for ForkJoinPool.config and WorkQueue.config
    static final int MODE_MASK    = 0xffff << 16;  // top half of int
    static final int LIFO_QUEUE   = 0;
    static final int FIFO_QUEUE   = 1 << 16;
    static final int SHARED_QUEUE = 1 << 31;       // must be negative
```

## 4.2 字段

## 4.3 重要方法

### 4.3.1 submit

```Java
    /**
     * Submits a ForkJoinTask for execution.
     *
     * @param task the task to submit
     * @param <T> the type of the task's result
     * @return the task
     * @throws NullPointerException if the task is null
     * @throws RejectedExecutionException if the task cannot be
     *         scheduled for execution
     */
    public <T> ForkJoinTask<T> submit(ForkJoinTask<T> task) {
        // NPE检查
        if (task == null)
            throw new NullPointerException();
        // 执行该task
        externalPush(task);
        return task;
    }
```

#### 4.3.1.1 externalPush

```Java
    /**
     * Tries to add the given task to a submission queue at
     * submitter's current queue. Only the (vastly) most common path
     * is directly handled in this method, while screening for need
     * for externalSubmit.
     *
     * @param task the task. Caller must ensure non-null.
     */
    final void externalPush(ForkJoinTask<?> task) {
        WorkQueue[] ws; WorkQueue q; int m;
        int r = ThreadLocalRandom.getProbe();
        int rs = runState;
        // 下面这堆条件的意思是：workQueues不为null且workQueues不为空且随机取出的WorkQueue不为空且随机数不为0且成功锁定
        if ((ws = workQueues) != null && (m = (ws.length - 1)) >= 0 &&
            (q = ws[m & r & SQMASK]) != null && r != 0 && rs > 0 &&
            U.compareAndSwapInt(q, QLOCK, 0, 1)) {
            ForkJoinTask<?>[] a; int am, n, s;
            if ((a = q.array) != null &&
                (am = a.length - 1) > (n = (s = q.top) - q.base)) {
                // 计算偏移量
                int j = ((am & s) << ASHIFT) + ABASE;
                U.putOrderedObject(a, j, task);
                U.putOrderedInt(q, QTOP, s + 1);
                U.putIntVolatile(q, QLOCK, 0);
                if (n <= 1)
                    signalWork(ws, q);
                return;
            }
            U.compareAndSwapInt(q, QLOCK, 1, 0);
        }
        externalSubmit(task);
    }
```

# 5 参考

* [聊聊并发（八）——Fork/Join框架介绍](http://www.infoq.com/cn/articles/fork-join-introduction)
