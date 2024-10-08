---
title: Java-NIO
date: 2017-07-10 18:45:20
tags: 
- 摘录
categories: 
- Java
- Java IO
---

**阅读更多**

<!--more-->

# 1 基本概念

## 1.1 用户空间内核空间

现在操作系统都是采用虚拟存储器，那么对32位操作系统而言，它的寻址空间(虚拟储存空间)为4G(2的32次方)。操作系统的核心是内核，独立于普通的应用程序，可以访问受保护的内存空间，也有访问底层硬件设备的所有权限。为了保证用户进程不能直接操作内核，保证内核的安全，操作系统将虚拟空间划分为两个部分，一个部分为内核空间，一部分为用户空间

如何分配这两个空间的大小也是有讲究的，如windows 32位操作系统，默认的用户空间：内核空间的比例是1:1；而在32位Linux系统中的默认比例是3:1(3G用户空间，1G内核空间)

内核空间和用户空间是现代操作系统的两种工作模式，内核模块运行在内核空间，而用户态应用程序运行在用户空间。**它们代表不同的级别，因而对系统资源具有不同的访问权限**。内核模块运行在最高级别(内核态)，这个级下所有的操作都受系统信任，而应用程序运行在较低级别(用户态)。在这个级别，处理器控制着对硬件的直接访问以及对内存的非授权访问。内核态和用户态有自己的内存映射，即自己的地址空间

处理器总处于以下状态中的一种

1. **内核态**，运行于进程上下文，内核代表进程运行于内核空间
1. **内核态**，运行于中断上下文，内核代表硬件运行于内核空间
1. **用户态**，运行于用户空间

用户空间的应用程序，通过系统调用，进入内核空间。由内核代表该进程运行于内核空间，这就涉及到上下文的切换，用户空间和内核空间具有不同的地址映射，通用或专用的寄存器组，而用户空间的进程要传递很多变量、参数给内核，内核也要保存用户进程的一些寄存器、变量等，以便系统调用结束后回到用户空间继续执行

所谓的"进程上下文"，就是一个进程在执行的时候，CPU的所有寄存器中的值、进程的状态以及堆栈上的内容，当内核需要切换到另一个进程时，它需要保存当前进程的所有状态，即保存当前进程的进程上下文，以便再次执行该进程时，能够恢复切换时的状态，继续执行

## 1.2 进程切换

为了控制进程的执行，内核必须要有能力挂起正在CPU上运行的进程，并恢复以前挂起的某个进程的执行。这种行为成为进程的切换。任何进程都是在操作系统内核的支持下运行的，是与内核紧密相关的

进程切换的过程，会经过下面这些变化

1. 保存处理机上下文，包括程序计数器和其他寄存器
1. 更新PCB(process control block)信息
1. 将进程的PCB移入相应的队列，如就绪、在某事件阻塞等队列
1. 选择另外一个进程执行，并更新PCB
1. 更新内存管理的数据结构
1. 恢复处理机上下文

PCB通常包含如以下的信息：

1. **进程标识符**(内部，外部)
1. **处理机的信息**(通用寄存器，指令计数器，PSW，用户的栈指针)
1. **进程调度信息**(进程状态，进程的优先级，进程调度所需的其它信息，事件)
1. **进程控制信息**(程序的数据的地址，资源清单，进程同步和通信机制，链接指针)

## 1.3 同步、异步、阻塞、非阻塞

在讨论这个问题的时候，是需要有具体的上下文的(context)，不同的上下文下，其含义可能不太一致。**本小节的讨论所基于的上下文：Linux环境下的network IO**

首先看Stevens给出的定义(POSIX的定义)

> A synchronous I/O operation causes the requesting process to be blocked until that I/O operation completes;

> An asynchronous I/O operation does not cause the requesting process to be blocked;

两者的区别就在于synchronous IO做"IO operation"的时候会将process阻塞。按照这个定义，blocking IO，non-blocking IO，IO multiplexing都属于synchronous IO

* 定义中所指的"IO operation"是指真实的IO操作(数据报从内核拷贝到用户空间的过程)

**同步与异步(用户是否等待操作完成)：描述的是用户线程与内核的交互方式**，同步指用户线程发起IO请求后需要等待或者轮询内核IO操作完成后才能继续执行；而异步是指用户线程发起IO请求后仍然继续执行，当内核IO操作完成后会通知用户线程，或者调用用户线程注册的回调函数

**阻塞与非阻塞(内核在操作完成前是否返回)**：描述是用户线程调用内核IO操作的方式，阻塞是指IO操作需要彻底完成后才返回到用户空间；而非阻塞是指IO操作被调用后立即返回给用户一个状态值，无需等到IO操作彻底完成

## 1.4 系统调用

所谓系统调用，就是用户在程序中调用操作系统所提供的一些子功能(程序)。**它是通过系统调用命令，中断现行程序而转去执行相应的子程序，以完成特定的系统功能**。完成后，控制又返回到发出系统调用命令之后的一条指令，被中断的程序将继续执行下去
`系统调用`与`过程调用`不同，其主要区别是：

1. **运行的状态不同**：在程序中的过程一般都是用户程序，或者都是系统程序，即都是运行在同一个系统状态的（用户态或系统态）
1. **进入的方式不同**：一般的过程调用可以直接由调用过程转向被调用的过程。而执行系统调用时，**由于调用过程与被调用过程是处于不同的状态**，因而不允许由调用过程直接转向被调用过程，通常是通过`访问管中断（即软中断）`进入，先进入操作系统，经分析后，才能转向相应的命令处理程序
1. **返回方式的不同**
1. **代码层次不同**：一般过程调用中的被调用程序是用户级程序，而系统调用是操作系统中的代码程序，是系统级程序
1. **被调用代码的位置不同**：过程（函数）调用是一种静态调用，调用者和被调用代码在同一程序内，经过连接编辑后作为目标代码的一部份。当过程（函数）升级或修改时，必须重新编译连结。而系统调用是一种动态调用，系统调用的处理代码在调用程序之外（在操作系统中），这样一来，系统调用处理代码升级或修改时，与调用程序无关。而且，调用程序的长度也大大缩短，减少了调用程序占用的存储空间

# 2 Linux-IO模型

**Linux系统IO分为`内核准备数据`和`将数据从内核拷贝到用户空间`两个阶段**

![fig1](/images/Java-NIO/fig1.png)

## 2.1 阻塞IO(Blocking IO)

![fig2](/images/Java-NIO/fig2.png)

在这个模型中，应用程序为了执行这个read操作，会调用相应的一个system call，将系统控制权交给内核，然后就进行等待(这个等待的过程就是被阻塞了)，内核开始执行这个system call，执行完毕后会向应用程序返回响应，应用程序得到响应后，就不再阻塞，并进行后面的工作

**优点**：

1. 能够及时返回数据，无延迟

**缺点**：

1. 对用户来说处于等待就要付出性能代价

## 2.2 非阻塞IO(Non-Blocking IO)

![fig3](/images/Java-NIO/fig3.png)

当用户进程发出read操作时，调用相应的system call，这个system call会立即从内核中返回。但是在返回的这个时间点，内核中的数据可能还没有准备好，也就是说内核只是很快就返回了system call，只有这样才不会阻塞用户进程，对于应用程序，虽然这个IO操作很快就返回了，但是它并不知道这个IO操作是否真的成功了，为了知道IO操作是否成功，应用程序需要主动的循环去问内核

**优点**：

1. 能够在等待的时间里去做其他的事情

**缺点**：

1. 任务完成的响应延迟增大了，因为每过一段时间去轮询一次read操作，而任务可能在两次轮询之间的任意时间完成，这对导致整体数据吞吐量的降低

## 2.3 多路复用IO(I/O Multiplexing)

![fig4](/images/Java-NIO/fig4.png)

I/O multiplexing这里面的multiplexing指的其实是在单个线程(内核级线程)通过记录跟踪每一个Sock(I/O流)的状态来同时管理多个I/O流

如果IO多路复用配合Reactor设计模式，可以从select调用的阻塞中解放出来，一旦有sock准备好，来主动通知，这样用户在等待数据准备好之前，可以做自己的事情

**select**：

1. select会修改传入的参数数组，这个对于一个需要调用很多次的函数，是非常不友好的
1. select如果任何一个sock(I/O stream)出现了数据，select仅仅会返回，但是并不会告诉你是那个sock上有数据，于是你只能自己一个一个的找，10几个sock可能还好，要是几万的sock每次都找一遍，这个无谓的开销就颇有海天盛筵的豪气了
1. select只能监视1024个链接，linux将其定义在头文件中，参见FD_SETSIZE
1. select不是线程安全的，如果你把一个sock加入到select，然后突然另外一个线程发现，尼玛，这个socket不用，要收回。对不起，这个select不支持的，如果你丧心病狂的竟然关掉这个socket，select的标准行为是不可预测的，这个可是写在文档中的哦

**poll**：

1. 去掉了1024个链接的限制
1. poll从设计上来说，不再修改传入数组
1. 但是poll仍然不是线程安全的，这就意味着，不管服务器有多强悍，你也只能在一个线程里面处理一组I/O流

**epoll**：

1. epoll现在是线程安全的
1. epoll现在不仅告诉你sock组里面数据，还会告诉你具体哪个sock有数据，你不用自己去找了

## 2.4 信号驱动IO

![fig5](/images/Java-NIO/fig5.png)

## 2.5 异步IO

![fig6](/images/Java-NIO/fig6.png)

# 3 参考

* [select/poll/epoll](http://www.cnblogs.com/Anker/p/3265058.html)

