# 进程与线程
    * 区别
    * 切换的区别
    * 通信的方式



# Java 线程之间的通信
* 同步--基于共享内存
* while轮询--基于共享内存
* wait/notify机制(await/signal)--什么机制
* java.io.PipedInputStream 和 java.io.PipedOutputStream--我觉得本质上还是共享内存
* BlockingQueue


需要有一个java.io.PipedInputStream 和 java.io.PipedOutputStream的源码分析
* 原理类似于生产者消费者


每种方式给个例子



# Java 并发之原子性、可见性、有序性

对于重排序而言，一定涉及到至少两个指令，那么这整个操作就是非原子的，于是在并发情况下，重排序可能会带来灾难，例如对象构造方法return(这里指的是字节码return)和字段的写操作被重排了，即写操作被重排到了return之后，对于单线程而言，这些字节码就对应了一条new语句，不会有影响，但是在并发情况下，另一个线程可能访问到尚未初始化的对象
* 这一段可以加在单例模式中



什么叫原子的操作？并发情况下，其他线程无法看到这个操作的中间状态