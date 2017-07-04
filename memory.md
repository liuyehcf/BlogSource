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



