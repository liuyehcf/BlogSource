---
title: Java concurrent ThreadPoolExecutor 源码剖析
date: 2017-07-02 22:55:09
tags:
categories:
- Java concurrent 源码剖析
---


# 1 前言
ThreadPoolExecutor源码分析分为以下三部分
* 常量简介
* 字段简介
* 内部类简介
* 重要方法源码分析

<!--more-->

# 2 常量简介

```Java
    private static final int COUNT_BITS = Integer.SIZE - 3;
    private static final int CAPACITY   = (1 << COUNT_BITS) - 1;

    private static final int RUNNING    = -1 << COUNT_BITS;
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
    private static final int STOP       =  1 << COUNT_BITS;
    private static final int TIDYING    =  2 << COUNT_BITS;
    private static final int TERMINATED =  3 << COUNT_BITS;
```

* __COUNT_BITS__：对于一个32位整型，用于记录线程数量的位数，29位
* __CAPACITY__：对于一个32位整型，用于记录线程池状态的位数，3位
* __RUNNING__：其数值为：-536870912。此状态下，线程池可以接受新任务，也可以执行任务队列(之前提交的)中的任务
* __SHUTDOWN__：其数值为：0。此状态下，线程池不能接受新任务，但是可以执行任务队列(之前提交的)中的任务
* __STOP__：其数值为：536870912。此状态下，线程池不能接受新任务，也不会执行任务队列中的任务，同时会给正在执行的任务发送一个中断信号(Thread#interrupt())
* __TIDYING__：其数值为：1073741824。所有任务已经终止，workCount为0，将运行terminate钩子方法
* __TERMINATED__：其数值为：1610612736。钩子方法terminate已经运行完毕
* 可以发现，只有RUNNING状态是负值，并且RUNNING-->SHUTDOWN-->STOP-->TIDYING-->TERMINATED数值依次增大

# 3 字段简介

## &emsp;3.1 ctl

```Java
private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0));
```
__该字段起到两个作用__
1. 记录线程池状态(RUNNNG/SHUTDOWN/STOP/TIDYING/TERMINATED)
1. 记录线程池线程的数量

__与该字段相关的方法__

```Java
    //从ctl中提取出runState
    //由于CAPACITY是000111111...111，于是~CAPACITY是111000000...000
    private static int runStateOf(int c)     { return c & ~CAPACITY; }
    //从ctl中提取出workerCount
    private static int workerCountOf(int c)  { return c & CAPACITY; }
    //将runState和workerCount封装成ctl
    private static int ctlOf(int rs, int wc) { return rs | wc; }
```


## &emsp;3.2 其他字段

```Java
    /**
     * The queue used for holding tasks and handing off to worker
     * threads.  We do not require that workQueue.poll() returning
     * null necessarily means that workQueue.isEmpty(), so rely
     * solely on isEmpty to see if the queue is empty (which we must
     * do for example when deciding whether to transition from
     * SHUTDOWN to TIDYING).  This accommodates special-purpose
     * queues such as DelayQueues for which poll() is allowed to
     * return null even if it may later return non-null when delays
     * expire.
     */
    //这就是任务队列，至于BlockingQueue源码将会放在下一篇博客中进行分析，[ArrayBlockingQueue 源码剖析](http://www.cnblogs.com/liuyehcf/p/7080224.html)
    private final BlockingQueue<Runnable> workQueue;

    /**
     * Lock held on access to workers set and related bookkeeping.
     * While we could use a concurrent set of some sort, it turns out
     * to be generally preferable to use a lock. Among the reasons is
     * that this serializes interruptIdleWorkers, which avoids
     * unnecessary interrupt storms, especially during shutdown.
     * Otherwise exiting threads would concurrently interrupt those
     * that have not yet interrupted. It also simplifies some of the
     * associated statistics bookkeeping of largestPoolSize etc. We
     * also hold mainLock on shutdown and shutdownNow, for the sake of
     * ensuring workers set is stable while separately checking
     * permission to interrupt and actually interrupting.
     */
    //重入锁，在访问或者修改workers时，需要该重入锁来保证线程安全。[ReentranLock 源码剖析](http://www.cnblogs.com/liuyehcf/p/7049733.html)
    private final ReentrantLock mainLock = new ReentrantLock();

    /**
     * Set containing all worker threads in pool. Accessed only when
     * holding mainLock.
     */
    //用于存放Worker的集合，采用非线程安全的HashSet，因此该字段的访问和修改必须配合mainLock
    private final HashSet<Worker> workers = new HashSet<Worker>();

    /**
     * Wait condition to support awaitTermination
     */
    //条件对象，[ConditionObject 源码剖析](http://www.cnblogs.com/liuyehcf/p/7048338.html)
    private final Condition termination = mainLock.newCondition();

    /**
     * Tracks largest attained pool size. Accessed only under
     * mainLock.
     */
    //线程池在整个生命周期中，持有线程数量的最大值
    private int largestPoolSize;

    /**
     * Counter for completed tasks. Updated only on termination of
     * worker threads. Accessed only under mainLock.
     */
    //已完成任务的数量
    private long completedTaskCount;

    /*
     * All user control parameters are declared as volatiles so that
     * ongoing actions are based on freshest values, but without need
     * for locking, since no internal invariants depend on them
     * changing synchronously with respect to other actions.
     */

    /**
     * Factory for new threads. All threads are created using this
     * factory (via method addWorker).  All callers must be prepared
     * for addWorker to fail, which may reflect a system or user's
     * policy limiting the number of threads.  Even though it is not
     * treated as an error, failure to create threads may result in
     * new tasks being rejected or existing ones remaining stuck in
     * the queue.
     *
     * We go further and preserve pool invariants even in the face of
     * errors such as OutOfMemoryError, that might be thrown while
     * trying to create threads.  Such errors are rather common due to
     * the need to allocate a native stack in Thread.start, and users
     * will want to perform clean pool shutdown to clean up.  There
     * will likely be enough memory available for the cleanup code to
     * complete without encountering yet another OutOfMemoryError.
     */
    private volatile ThreadFactory threadFactory;

    /**
     * Handler called when saturated or shutdown in execute.
     */
    private volatile RejectedExecutionHandler handler;

    /**
     * Timeout in nanoseconds for idle threads waiting for work.
     * Threads use this timeout when there are more than corePoolSize
     * present or if allowCoreThreadTimeOut. Otherwise they wait
     * forever for new work.
     */
    //当前线程数量超过corePoolSize(核心线程数量)时，如果当前线程空闲超过keepAliveTime，那么当前线程将会结束
    private volatile long keepAliveTime;

    /**
     * If false (default), core threads stay alive even when idle.
     * If true, core threads use keepAliveTime to time out waiting
     * for work.
     */
    //是否允许核心线程超时结束
    private volatile boolean allowCoreThreadTimeOut;

    /**
     * Core pool size is the minimum number of workers to keep alive
     * (and not allow to time out etc) unless allowCoreThreadTimeOut
     * is set, in which case the minimum is zero.
     */   
    //核心线程数量
    private volatile int corePoolSize;

    /**
     * Maximum pool size. Note that the actual maximum is internally
     * bounded by CAPACITY.
     */
    //最大线程池数量
    private volatile int maximumPoolSize;
```

* __corePoolSize__：核心线程数量，所谓核心线是指即便空闲也不会终止的线程(allowCoreThreadTimeOut必须是false)
* __maximumPoolSize__：最大线程数量，核心线程+非核心线程的总数不能超过这个数值
* __largestPoolSize__：在线程池的生命周期中，线程池持有线程数量的最大值
* __keepAliveTime__：非核心线程在空闲状态下保持active的最长时间，超过这个时间若仍然空闲，那么该线程便会结束

# 4 内部类简介


__Worker封装了Thread，因此Worker可以理解为一个线程。Worker实现了Runnable，负责从任务队列中获取任务并执行__

__同时Worker还继承了AQS，（[AQS 源码剖析](http://www.cnblogs.com/liuyehcf/p/7050176.html)）也就是说Work对象本身可以作为Lock来使用，但这是为什么呢?__
* 在ThreadPoolExecutor#runWorker方法中，在成功获取到任务后，会将自己锁定，这个锁定状态用于表示当前work处于工作状态(在执行任务)，当一个任务处理完毕之后，又会解除锁定状态
* 在ThreadPoolExecutor#interruptIdleWorkders方法中会调用Worker#tryLock()方法，该方法就是尝试获取锁，如果获取失败，则表明worker处于工作状态
* 这就是Worker继承AQS的原因，可以不借助其他锁机制，仅依靠AQS来提供一种线程安全的状态表示机制


```Java
/**
     * Class Worker mainly maintains interrupt control state for
     * threads running tasks, along with other minor bookkeeping.
     * This class opportunistically extends AbstractQueuedSynchronizer
     * to simplify acquiring and releasing a lock surrounding each
     * task execution.  This protects against interrupts that are
     * intended to wake up a worker thread waiting for a task from
     * instead interrupting a task being run.  We implement a simple
     * non-reentrant mutual exclusion lock rather than use
     * ReentrantLock because we do not want worker tasks to be able to
     * reacquire the lock when they invoke pool control methods like
     * setCorePoolSize.  Additionally, to suppress interrupts until
     * the thread actually starts running tasks, we initialize lock
     * state to a negative value, and clear it upon start (in
     * runWorker).
     */
    private final class Worker
        extends AbstractQueuedSynchronizer
        implements Runnable
    {
        /**
         * This class will never be serialized, but we provide a
         * serialVersionUID to suppress a javac warning.
         */
        private static final long serialVersionUID = 6138294804551838833L;

        /** Thread this worker is running in.  Null if factory fails. */
        final Thread thread;
        /** Initial task to run.  Possibly null. */
        Runnable firstTask;
        /** Per-thread task counter */
        volatile long completedTasks;

        /**
         * Creates with given first task and thread from ThreadFactory.
         * @param firstTask the first task (null if none)
         */
        Worker(Runnable firstTask) {
            setState(-1); // inhibit interrupts until runWorker
            this.firstTask = firstTask;
            this.thread = getThreadFactory().newThread(this);
        }

        /** Delegates main run loop to outer runWorker  */
        public void run() {
            //这个是主要方法，待会会详细分析
            runWorker(this);
        }

        // Lock methods
        //
        // The value 0 represents the unlocked state.
        // The value 1 represents the locked state.

        protected boolean isHeldExclusively() {
            return getState() != 0;
        }

        protected boolean tryAcquire(int unused) {
            if (compareAndSetState(0, 1)) {
                setExclusiveOwnerThread(Thread.currentThread());
                return true;
            }
            return false;
        }

        //将关联的线程置空，并且将资源状态设为0。该方法被封装成unlock方法，可以发现tryRelease的实现逻辑使得这个unlock方法的调用可以优先于lock方法
        protected boolean tryRelease(int unused) {
            setExclusiveOwnerThread(null);
            setState(0);
            return true;
        }

        //以下方法仅仅封装了AQS的相关方法
        public void lock()        { acquire(1); }
        public boolean tryLock()  { return tryAcquire(1); }
        public void unlock()      { release(1); }
        public boolean isLocked() { return isHeldExclusively(); }

        void interruptIfStarted() {
            Thread t;
            if (getState() >= 0 && (t = thread) != null && !t.isInterrupted()) {
                try {
                    t.interrupt();
                } catch (SecurityException ignore) {
                }
            }
        }
    }
```

# 5 重要方法源码分析

## &emsp;5.1 execute

__该方法是Executor接口的方法，用于向线程池提交任务，其主要逻辑如下__
* 如果当前线程池核心线程数量小于corePoolSize，那么添加一个Work来执行这个提交的任务
* 否则向线程池的任务队列提交这个任务，如果发现线程池现有的线程数量为0，则添加一个Worker
* 如果所有情况均失败，则用线程池指定的拒绝策略拒绝任务

```Java
    /**
     * Executes the given task sometime in the future.  The task
     * may execute in a new thread or in an existing pooled thread.
     *
     * If the task cannot be submitted for execution, either because this
     * executor has been shutdown or because its capacity has been reached,
     * the task is handled by the current {@code RejectedExecutionHandler}.
     *
     * @param command the task to execute
     * @throws RejectedExecutionException at discretion of
     *         {@code RejectedExecutionHandler}, if the task
     *         cannot be accepted for execution
     * @throws NullPointerException if {@code command} is null
     */
    public void execute(Runnable command) {
        if (command == null)
            throw new NullPointerException();
        /*
         * Proceed in 3 steps:
         *
         * 1. If fewer than corePoolSize threads are running, try to
         * start a new thread with the given command as its first
         * task.  The call to addWorker atomically checks runState and
         * workerCount, and so prevents false alarms that would add
         * threads when it shouldn't, by returning false.
         *
         * 2. If a task can be successfully queued, then we still need
         * to double-check whether we should have added a thread
         * (because existing ones died since last checking) or that
         * the pool shut down since entry into this method. So we
         * recheck state and if necessary roll back the enqueuing if
         * stopped, or start a new thread if there are none.
         *
         * 3. If we cannot queue task, then we try to add a new
         * thread.  If it fails, we know we are shut down or saturated
         * and so reject the task.
         */
        int c = ctl.get();
        //如果线程池中线程的数量小于核心线程数量
        if (workerCountOf(c) < corePoolSize) {
            //开启一个新的核心线程来执行这个任务
            if (addWorker(command, true))
                return;
            //addWorker失败(可能由于各种原因，超过线程池线程数量上限，或者线程工厂创建线程失败，等等原因)，继续走下面的逻辑
            c = ctl.get();
        }
        //若线程池处于RUNNING状态，并且向任务队列中成功添加任务
        if (isRunning(c) && workQueue.offer(command)) {
            int recheck = ctl.get();
            //如果线程池处于非RUNNING状态，那么将command从任务队列中删除
            if (! isRunning(recheck) && remove(command))
                //采用线程池指定的策略拒绝任务
                reject(command);
            //线程池处于RUNNING状态，且目前没有active线程
            else if (workerCountOf(recheck) == 0)
                //线程池添加一个Worker
                addWorker(null, false);
        }
        //尝试添加一个包含firstTask的Worker，如果失败了，则表明线程池已经处于SHUTDOWN或者已经饱和，因此执行拒绝策略拒绝任务
        else if (!addWorker(command, false))
            reject(command);
    }
```


## &emsp;5.2 addWorker

__该方法向线程池添加一个Worker，包含以下两个参数__
* firstTask：执行的任务，可以为null。(当线程池中没有线程并且任务队列尚有任务时会传入null参数)
* core：用于标记添加的Worker是否为核心线程

__该方法实现的逻辑如下__
* 首先检查线程池的状态，看是否允许添加新的Worker，若不允许，直接返回false
* 尝试递增线程池计数，如果数量已达上限，直接返回false
* 新建Worker并将其添加到workers中去

```Java
    /**
     * Checks if a new worker can be added with respect to current
     * pool state and the given bound (either core or maximum). If so,
     * the worker count is adjusted accordingly, and, if possible, a
     * new worker is created and started, running firstTask as its
     * first task. This method returns false if the pool is stopped or
     * eligible to shut down. It also returns false if the thread
     * factory fails to create a thread when asked.  If the thread
     * creation fails, either due to the thread factory returning
     * null, or due to an exception (typically OutOfMemoryError in
     * Thread.start()), we roll back cleanly.
     *
     * @param firstTask the task the new thread should run first (or
     * null if none). Workers are created with an initial first task
     * (in method execute()) to bypass queuing when there are fewer
     * than corePoolSize threads (in which case we always start one),
     * or when the queue is full (in which case we must bypass queue).
     * Initially idle threads are usually created via
     * prestartCoreThread or to replace other dying workers.
     *
     * @param core if true use corePoolSize as bound, else
     * maximumPoolSize. (A boolean indicator is used here rather than a
     * value to ensure reads of fresh values after checking other pool
     * state).
     * @return true if successful
     */
    private boolean addWorker(Runnable firstTask, boolean core) {
        retry:
        for (;;) {
            int c = ctl.get();
            int rs = runStateOf(c);

            // Check if queue empty only if necessary.
            //该条件有点复杂，换一种形式：rs>=SHUTDOWN && (rs != SHUTDOWN || firstTask != null || workQueue.isEmpty())
            //条件成立时
                //1. rs>SHUTDOWN(大于SHUTDOWN时添加Worker自然是失败的)
                //2. rs==SHUTDOWN 且 firstTask!=null;(当处于SHUTDOWN时不再接受新的任务，但是可以接受null任务)
                //3. rs==SHUTDOWN 且 firstTask==null 且 workQueue为空(当处于SHUTDOWN时且任务为空，此时如果队列中没有待执行的任务，也是没有必要添加Workder的)
            //条件失败时
                //1. rs==RUNNING(运行状态自然可以添加Worker)
                //2. rs==SHUTDOWN 且 firstTask==null 且 workQueue不为空(当处于SHUTDOWN状态并且添加任务为空时，如果队列中仍有尚未执行的任务，那么允许添加Work)
            if (rs >= SHUTDOWN &&
                ! (rs == SHUTDOWN &&
                   firstTask == null &&
                   ! workQueue.isEmpty()))
                return false;

            //下面这段"循环+CAS"用于串行化ctl的递增操作
            for (;;) {
                int wc = workerCountOf(c);
                //如果Worker数量已达上限，直接返回false。如果core为true，则代表添加的是核心线程，那么与corePoolSize进行比较；否则与maximumPoolSize进行比较
                if (wc >= CAPACITY ||
                    wc >= (core ? corePoolSize : maximumPoolSize))
                    return false;
                //CAS递增，成功时退出该死循环，继续下面的逻辑
                if (compareAndIncrementWorkerCount(c))
                    break retry;
                c = ctl.get();  // Re-read ctl
                //如果线程池状态发生改变，则需要重新进行上面的判断，因此退回到上一层循环
                if (runStateOf(c) != rs)
                    continue retry;
                // else CAS failed due to workerCount change; retry inner loop
            }
        }


        //下面的逻辑就是新建Worker并将其添加到workers中去        
        boolean workerStarted = false;
        boolean workerAdded = false;
        Worker w = null;
        try {
            w = new Worker(firstTask);
            final Thread t = w.thread;
            //这个条件是为了支持线程创建失败。由于Worker内部的线程是通过ThreadFactory来创建的，不同的工厂可能会有不同的创建逻辑。
            if (t != null) {
                final ReentrantLock mainLock = this.mainLock;
                mainLock.lock();
                try {
                    // Recheck while holding lock.
                    // Back out on ThreadFactory failure or if
                    // shut down before lock acquired.
                    int rs = runStateOf(ctl.get());

                    //条件成立时
                        //1. rs==RUNNING
                        //2. rs==SHUTDOWN && firstTask==null
                    if (rs < SHUTDOWN ||
                        (rs == SHUTDOWN && firstTask == null)) {
                        if (t.isAlive()) // precheck that t is startable
                            throw new IllegalThreadStateException();
                        workers.add(w);
                        int s = workers.size();
                        if (s > largestPoolSize)
                            largestPoolSize = s;
                        workerAdded = true;
                    }
                } finally {
                    mainLock.unlock();
                }
                //如果Worker成功添加，则启动线程
                if (workerAdded) {
                    t.start();
                    workerStarted = true;
                }
            }
        } finally {
            if (! workerStarted)
                addWorkerFailed(w);
        }
        //返回线程是否成功启动
        return workerStarted;
    }
```

## &emsp;5.3 runWorker

__runWorker被封装成Worker#run方法，该方法的主要逻辑如下__
* 从任务队列中获取任务并执行
* 如果任务队列为空，则阻塞在获取任务的过程中

```Java
/**
     * Main worker run loop.  Repeatedly gets tasks from queue and
     * executes them, while coping with a number of issues:
     *
     * 1. We may start out with an initial task, in which case we
     * don't need to get the first one. Otherwise, as long as pool is
     * running, we get tasks from getTask. If it returns null then the
     * worker exits due to changed pool state or configuration
     * parameters.  Other exits result from exception throws in
     * external code, in which case completedAbruptly holds, which
     * usually leads processWorkerExit to replace this thread.
     *
     * 2. Before running any task, the lock is acquired to prevent
     * other pool interrupts while the task is executing, and then we
     * ensure that unless pool is stopping, this thread does not have
     * its interrupt set.
     *
     * 3. Each task run is preceded by a call to beforeExecute, which
     * might throw an exception, in which case we cause thread to die
     * (breaking loop with completedAbruptly true) without processing
     * the task.
     *
     * 4. Assuming beforeExecute completes normally, we run the task,
     * gathering any of its thrown exceptions to send to afterExecute.
     * We separately handle RuntimeException, Error (both of which the
     * specs guarantee that we trap) and arbitrary Throwables.
     * Because we cannot rethrow Throwables within Runnable.run, we
     * wrap them within Errors on the way out (to the thread's
     * UncaughtExceptionHandler).  Any thrown exception also
     * conservatively causes thread to die.
     *
     * 5. After task.run completes, we call afterExecute, which may
     * also throw an exception, which will also cause thread to
     * die. According to JLS Sec 14.20, this exception is the one that
     * will be in effect even if task.run throws.
     *
     * The net effect of the exception mechanics is that afterExecute
     * and the thread's UncaughtExceptionHandler have as accurate
     * information as we can provide about any problems encountered by
     * user code.
     *
     * @param w the worker
     */
    final void runWorker(Worker w) {
        Thread wt = Thread.currentThread();
        Runnable task = w.firstTask;
        w.firstTask = null;
        //Worker#unlock的实现逻辑保证，在无锁状态执行unlock是无害的。但从ThreadPoolExecutor源码来看好像没必要，可能是为了防止Worker被误锁定吧
        w.unlock(); // allow interrupts
        boolean completedAbruptly = true;
        try {
            //对于第一次进入该循环时，task=w.firstTask，那么将会首先执行这个任务
            //如果w.firstTask为null或者非第一次循环，那么将会从任务队列中取出任务然后执行，取出任务时处于非阻塞状态
            while (task != null || (task = getTask()) != null) {
                //此处对work本身进行锁定，该锁定的意义就是表示当前Worker处于工作状态，可以通过tryLock来判断该Worker是否处于工作状态
                w.lock();
                // If pool is stopping, ensure thread is interrupted;
                // if not, ensure thread is not interrupted.  This
                // requires a recheck in second case to deal with
                // shutdownNow race while clearing interrupt
                //条件成立时
                    //1. 线程池处于STOP或者RUNNING 或 TIDYING 或 TERMINATED状态，且当前线程尚未被中断
                    //2. 线程处于RUNNING或者SHUTDOWN状态，并且被中断过(Thread.interrupted()方法返回true)
                if ((runStateAtLeast(ctl.get(), STOP) ||
                     (Thread.interrupted() &&
                      runStateAtLeast(ctl.get(), STOP))) &&
                    !wt.isInterrupted())
                    wt.interrupt();
                try {
                    //任务执行前的处理逻辑(该方法为空方法，交给子类实现其扩展语义)，扩展了任务执行的生命周期
                    beforeExecute(wt, task);
                    Throwable thrown = null;
                    try {
                        //调用任务的执行逻辑
                        task.run();
                    } catch (RuntimeException x) {
                        thrown = x; throw x;
                    } catch (Error x) {
                        thrown = x; throw x;
                    } catch (Throwable x) {
                        thrown = x; throw new Error(x);
                    } finally {
                        //任务执行后的处理逻辑(该方法为空方法，交给子类实现其扩展语义)，扩展了任务执行的生命周期
                        afterExecute(task, thrown);
                    }
                } finally {
                    task = null;
                    w.completedTasks++;
                    //对work本身解锁
                    w.unlock();
                }
            }
            //运行到这里属于正常结束
            completedAbruptly = false;
        } finally {
            processWorkerExit(w, completedAbruptly);
        }
    }
```


### &emsp;&emsp;&emsp;5.3.1 processWorkerExit

__线程exit后的处理方法__

```Java
    /**
     * Performs cleanup and bookkeeping for a dying worker. Called
     * only from worker threads. Unless completedAbruptly is set,
     * assumes that workerCount has already been adjusted to account
     * for exit.  This method removes thread from worker set, and
     * possibly terminates the pool or replaces the worker if either
     * it exited due to user task exception or if fewer than
     * corePoolSize workers are running or queue is non-empty but
     * there are no workers.
     *
     * @param w the worker
     * @param completedAbruptly if the worker died due to user exception
     */
    private void processWorkerExit(Worker w, boolean completedAbruptly) {
        //如果意外中断，需要调整ctl
        if (completedAbruptly) // If abrupt, then workerCount wasn't adjusted
            decrementWorkerCount();

        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            //更新该Worker完成的任务数量
            completedTaskCount += w.completedTasks;
            //将该Worker移出workers，由于workers是非线程安全的，因此需要加锁
            workers.remove(w);
        } finally {
            mainLock.unlock();
        }

        tryTerminate();

        int c = ctl.get();
        //如果当前状态是RUNNING或者SHUTDOWN
        if (runStateLessThan(c, STOP)) {
            if (!completedAbruptly) {
                int min = allowCoreThreadTimeOut ? 0 : corePoolSize;
                //此时队列中尚有任务未执行，那么允许的最小线程数量最小是1
                if (min == 0 && ! workQueue.isEmpty())
                    min = 1;
                //如果当前线程数量大于等于所需要的最小线程数量
                if (workerCountOf(c) >= min)
                    return; // replacement not needed
            }
            //尝试添加Worker
            addWorker(null, false);
        }
    }
```

### &emsp;&emsp;&emsp;5.3.2 tryTerminate

__将状态转移成TERMINATED__
* 如果状态是SHUTDOWN并且线程池中无线程且队列为空
* 如果状态是STOP并且线程池中无线程

```Java
    /**
     * Transitions to TERMINATED state if either (SHUTDOWN and pool
     * and queue empty) or (STOP and pool empty).  If otherwise
     * eligible to terminate but workerCount is nonzero, interrupts an
     * idle worker to ensure that shutdown signals propagate. This
     * method must be called following any action that might make
     * termination possible -- reducing worker count or removing tasks
     * from the queue during shutdown. The method is non-private to
     * allow access from ScheduledThreadPoolExecutor.
     */
    final void tryTerminate() {
        for (;;) {
            int c = ctl.get();
            //条件为真
                //1. 线程池处于RUNNING状态
                //2. 线程池处于SHUTDOWN状态，但是任务队列不为空
            if (isRunning(c) ||
                runStateAtLeast(c, TIDYING) ||
                (runStateOf(c) == SHUTDOWN && ! workQueue.isEmpty()))
                return;
            //若线程池仍有线程存在
            if (workerCountOf(c) != 0) { // Eligible to terminate
                //中断一个空闲线程
                interruptIdleWorkers(ONLY_ONE);
                return;
            }

            //此时线程池中无线程存在
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                //将状态改为TIDYING
                if (ctl.compareAndSet(c, ctlOf(TIDYING, 0))) {
                    try {
                        //该方法为空，交由子类实现其逻辑，TIDYING状态存在的意义就是提供一个执行termiated()方法的生命周期
                        terminated();
                    } finally {
                        //将状态改为TERMINATED
                        ctl.set(ctlOf(TERMINATED, 0));
                        termination.signalAll();
                    }
                    return;
                }
            } finally {
                mainLock.unlock();
            }
            // else retry on failed CAS
        }
    }
```

__可以看到TIDYING状态存在的意义就是提供一个额外的terminated()生命周期，该方法为空方法，允许子类执行一些相应的处理逻辑__

## &emsp;5.4 getTask

__该方法从任务队列中获取任务__
* 实现阻塞或者超时终止(keepAliveTime)线程的逻辑
* 以下情况时，该方法返回null，这会导致runWorker方法退出while循环，从而结束线程生命周期
    1. 线程池线程数量已超过上限，因此当前线程可以终止
    1. 线程池已被STOP
    1. 线程池处于SHUTDOWN状态，且任务队列为空
    1. 等待一段时间后仍然没有获取到任务，即阻塞时间超过了(keepAliveTime)

```Java
    /**
     * Performs blocking or timed wait for a task, depending on
     * current configuration settings, or returns null if this worker
     * must exit because of any of:
     * 1. There are more than maximumPoolSize workers (due to
     *    a call to setMaximumPoolSize).
     * 2. The pool is stopped.
     * 3. The pool is shutdown and the queue is empty.
     * 4. This worker timed out waiting for a task, and timed-out
     *    workers are subject to termination (that is,
     *    {@code allowCoreThreadTimeOut || workerCount > corePoolSize})
     *    both before and after the timed wait, and if the queue is
     *    non-empty, this worker is not the last thread in the pool.
     *
     * @return task, or null if the worker must exit, in which case
     *         workerCount is decremented
     */
    private Runnable getTask() {
        boolean timedOut = false; // Did the last poll() time out?

        for (;;) {
            int c = ctl.get();
            int rs = runStateOf(c);

            // Check if queue empty only if necessary.
            //条件成立时
                //1. rs >= STOP，此状态下，线程池不再执行任务
                //2. rs == SHUTDOWN 并且workQueue为空，SHUTDOWN状态下，线程池可以执行任务队列中的任务，但是此时任务队列也为空
            if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
                //所有返回null的地方都需要递减worker计数值
                decrementWorkerCount();
                return null;
            }

            int wc = workerCountOf(c);

            // Are workers subject to culling?
            //当前线程是否允许超时结束，allowCoreThreadTimeOut 为真意味着所有线程都支持，否则只有超出核心线程数量的那部分线程才能超时结束
            boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;

            //条件不成立时
                //1. 当前线程不允许超时，或者允许超时但没有超时
                //2. 当前线程池线程数量为1，并且任务队列不为空
            if ((wc > maximumPoolSize || (timed && timedOut))
                && (wc > 1 || workQueue.isEmpty())) {
                //所有返回null的地方都需要递减worker计数值，但此处用的是CAS
                if (compareAndDecrementWorkerCount(c))
                    return null;
                continue;
            }

            try {
                //根据是否允许超时来调用BlockingQueue的相应方法
                Runnable r = timed ?
                    //最多阻塞指定时间
                    workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                    //阻塞直至获取元素
                    workQueue.take();
                if (r != null)
                    return r;
                timedOut = true;
            } catch (InterruptedException retry) {
                timedOut = false;
            }
        }
    }
```

## &emsp;5.5 shutdown

__该方法的逻辑如下__
* 将线程池的状态提高到SHUTDOWN(若之前线程池的状态是RUNNING，那么线程池的状态将会升级到SHUTDOWN，此后不再接受新的任务)或者保持不变
* 中断所有空闲线程，所谓空闲是指阻塞在getTask()方法调用中的Worker 

```Java
    /**
     * Initiates an orderly shutdown in which previously submitted
     * tasks are executed, but no new tasks will be accepted.
     * Invocation has no additional effect if already shut down.
     *
     * <p>This method does not wait for previously submitted tasks to
     * complete execution.  Use {@link #awaitTermination awaitTermination}
     * to do that.
     *
     * @throws SecurityException {@inheritDoc}
     */
    public void shutdown() {
        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            checkShutdownAccess();
            //如果线程池为RUNNING状态，则将其改为SHUTDOWN
            advanceRunState(SHUTDOWN);
            //对所有空闲线程发送中断信号
            interruptIdleWorkers();
            //shutdown后处理方法，该方法为空方法，交给子类实现
            onShutdown(); // hook for ScheduledThreadPoolExecutor
        } finally {
            mainLock.unlock();
        }
        tryTerminate();
    }
```

### &emsp;&emsp;&emsp;5.5.1 advanceRunState

__将线程池的状态提高到指定状态，或者保持不变__

```Java
    /**
     * Transitions runState to given target, or leaves it alone if
     * already at least the given target.
     *
     * @param targetState the desired state, either SHUTDOWN or STOP
     *        (but not TIDYING or TERMINATED -- use tryTerminate for that)
     */
    private void advanceRunState(int targetState) {
        for (;;) {
            int c = ctl.get();
            if (runStateAtLeast(c, targetState) ||
                ctl.compareAndSet(c, ctlOf(targetState, workerCountOf(c))))
                break;
        }
    }
```

### &emsp;&emsp;&emsp;5.5.2 interruptIdleWorkers

__中断空闲的Worker__
* 如何判断是否空闲：调用Worker#tryLock，若返回true，则说明空闲，否则非空闲

```Java
    /**
     * Common form of interruptIdleWorkers, to avoid having to
     * remember what the boolean argument means.
     */
    private void interruptIdleWorkers() {
        interruptIdleWorkers(false);
    }

    /**
     * Interrupts threads that might be waiting for tasks (as
     * indicated by not being locked) so they can check for
     * termination or configuration changes. Ignores
     * SecurityExceptions (in which case some threads may remain
     * uninterrupted).
     *
     * @param onlyOne If true, interrupt at most one worker. This is
     * called only from tryTerminate when termination is otherwise
     * enabled but there are still other workers.  In this case, at
     * most one waiting worker is interrupted to propagate shutdown
     * signals in case all threads are currently waiting.
     * Interrupting any arbitrary thread ensures that newly arriving
     * workers since shutdown began will also eventually exit.
     * To guarantee eventual termination, it suffices to always
     * interrupt only one idle worker, but shutdown() interrupts all
     * idle workers so that redundant workers exit promptly, not
     * waiting for a straggler task to finish.
     */
    private void interruptIdleWorkers(boolean onlyOne) {
        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            for (Worker w : workers) {
                Thread t = w.thread;
                //如果未被中断，且该Worker处于空闲状态(tryLock返回true就代表空闲状态)
                if (!t.isInterrupted() && w.tryLock()) {
                    try {
                        t.interrupt();
                    } catch (SecurityException ignore) {
                    } finally {
                        //由于之前tryLock可能获取了锁，因此这里要进行释放
                        //Worker#unlock的实现逻辑保证，即便没有获取锁，执行unlock也是无害的
                        w.unlock();
                    }
                }
                //如果只中断一个，那么这里退出即可
                if (onlyOne)
                    break;
            }
        } finally {
            mainLock.unlock();
        }
    }
```


## &emsp;5.6 shutdownNow

__该方法的逻辑如下__
* 将线程池的状态提高到STOP(之前的状态是RUNNING或者SHUTDOWN)或者保持不变
* 中断所有线程

```Java
    /**
     * Attempts to stop all actively executing tasks, halts the
     * processing of waiting tasks, and returns a list of the tasks
     * that were awaiting execution. These tasks are drained (removed)
     * from the task queue upon return from this method.
     *
     * <p>This method does not wait for actively executing tasks to
     * terminate.  Use {@link #awaitTermination awaitTermination} to
     * do that.
     *
     * <p>There are no guarantees beyond best-effort attempts to stop
     * processing actively executing tasks.  This implementation
     * cancels tasks via {@link Thread#interrupt}, so any task that
     * fails to respond to interrupts may never terminate.
     *
     * @throws SecurityException {@inheritDoc}
     */
    public List<Runnable> shutdownNow() {
        List<Runnable> tasks;
        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            checkShutdownAccess();
            //若线程池的状态小于STOP，则将其改为STOP，否则状态不变
            advanceRunState(STOP);
            //中断所有线程
            interruptWorkers();
            //返回所有未执行的任务
            tasks = drainQueue();
        } finally {
            mainLock.unlock();
        }
        tryTerminate();
        return tasks;
    }
```

### &emsp;&emsp;&emsp;5.6.1 interruptWorkers

__中断所有线程__

```Java
    /**
     * Interrupts all threads, even if active. Ignores SecurityExceptions
     * (in which case some threads may remain uninterrupted).
     */
    private void interruptWorkers() {
        final ReentrantLock mainLock = this.mainLock;
        mainLock.lock();
        try {
            for (Worker w : workers)
                w.interruptIfStarted();
        } finally {
            mainLock.unlock();
        }
    }
```


### &emsp;&emsp;&emsp;5.6.2 drainQueue

__返回所有未执行的任务__

```Java
    /**
     * Drains the task queue into a new list, normally using
     * drainTo. But if the queue is a DelayQueue or any other kind of
     * queue for which poll or drainTo may fail to remove some
     * elements, it deletes them one by one.
     */
    private List<Runnable> drainQueue() {
        BlockingQueue<Runnable> q = workQueue;
        ArrayList<Runnable> taskList = new ArrayList<Runnable>();
        //将队列中的元素转移到taskList中
        q.drainTo(taskList);
        //如果queue是一个DelayQueue或者其他特殊的queue，这些queue的poll或drainTo方法可能会失败，因此这里需要一个个移动这些元素
        if (!q.isEmpty()) {
            for (Runnable r : q.toArray(new Runnable[0])) {
                if (q.remove(r))
                    taskList.add(r);
            }
        }
        return taskList;
    }
```



## &emsp;5.7 submit

__该方法是ThreadPoolExecutor父类AbstractExecutorService的方法，AbstractExecutorService实现了ExecutorService接口的部分方法__
* 该方法将Runnable封装成一个RunnableFuture，该接口实现了Runnable，然后交给execute方法执行
* 返回封装好的RunnableFuture，以便调用者使用RunnableFuture执行一些操作，例如cancel等


```Java
    public Future<?> submit(Runnable task) {
        if (task == null) throw new NullPointerException();
        //将Runnable封装成一个RunnableFuture
        RunnableFuture<Void> ftask = newTaskFor(task, null);
        //执行封装后的futureTask
        execute(ftask);
        return ftask;
    }
```

__Future源码分析请参见 [FutureTask 源码剖析](http://www.cnblogs.com/liuyehcf/p/7082739.html)__