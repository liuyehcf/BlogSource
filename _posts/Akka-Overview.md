---
title: Akka-Overview
date: 2019-01-16 19:54:09
tags: 
- 原创
categories: 
- Java
- Framework
- Akka
---

__阅读更多__

<!--more-->

# 1 重要概念

## 1.1 一些术语

### 1.1.1 并发与并行（Concurrency vs. Parallelism）

`并发`与`并行`是一个老生常谈的概念。简而言之，它们的含义相似，但存在细微差别：`并发`强调的是存在多个任务，但是这些任务并不一定真的同时执行（单核CPU也可有`并发`）；`并行`强调同时执行（单核CPU不可能有`并行`）

### 1.1.2 异步与同步（Asynchronous vs. Synchronous）

对于同步调用，调用方无法做其他事情，直到方法返回或者抛出异常。异步调用可以做其他事情，但是需要借助其他机制来拿到调用的结果，例如`Callback`、`Future`、`Message`

同步与异步是从调用方的角度来看待方法调用

### 1.1.3 非阻塞与阻塞（Non-blocking vs. Blocking）

阻塞指的是一个线程会让其他线程无期限地等待（例如，多个线程共享一个互斥锁，但是某个线程进入了一个死循环中）；而非阻塞指的是一个线程不会让其他线程无期限地等待下去

### 1.1.4 死锁、饥饿、活锁（Deadlock vs. Starvation vs. Live-lock）

当多个线程产生循环依赖时，就可能产生死锁。例如，线程A、B、C分别持有独占资源α、β、γ，但A还需要β，B还需要γ，C还需要α，这样就会产生死锁

当高优先级的任务足够多的时候，如果系统总是优先调度高优先级任务，那么低优先级的任务就会发生饥饿

活锁与死锁很像，区别在于活锁处于一个连续变化的状态，而死锁处于一个静止的状态。例如，线程A、B分别持有独占资源α、β，且A尝试获取β，B尝试获取α，线程A、B若检测到有其他线程正在请求他们所占有的资源时，就会释放该资源

### 1.1.5 非阻塞的保证（on-blocking Guarantees）

#### 1.1.5.1 Wait-freedom

所有方法都在有限步骤内完成，不会发生死锁、饥饿等现象

#### 1.1.5.2 Lock-freedom

几乎所有的方法在有限步骤内完成，不会发生死锁，但是可能发生饥饿现象

#### 1.1.5.3 Obstruction-freedom

方法在有限时间内完成，意味着在执行过程中，其他线程会阻塞

Optimistic concurrency control (OCC)通常是`obstruction-free`。在这种方式下，线程会尝试修改一个共享资源的状态，并且能够感知到状态修改是否有冲突（例如，CAS），当发生冲突时，会重试

## 1.2 Actor System

`Actors`就是一些封装了`状态`和`行为`的对象，它们仅通过`交换消息`来通信。`Actor`严格遵循了OOP（object-oriented programming）原则

### 1.2.1 层次结构

`Actors`自然地形成层次结构。一个`Actor`通常会将一个任务分解成多个简单的任务，并监管这些任务的执行。

每个`Actor`都有一个监督者`Supervisor`，即创建它的那个`Actor`。例如`Actor A`创建了`Actor B`，那么`A`就是`B`的`Supervisor`

`Actor System`的典型特征就是，一个大任务通常会被分解成多个（可能包含多个层级）更易执行的子任务。为了达到这样的目的，任务本身需要清晰地定义，同时，返回的结果也必须清晰地定义。也就是说，一个`Actor`可以处理哪些响应，不可以处理哪些响应都是需要严格设计过的，当一个`Actor`收到了一个它无法处理的消息时，它应该将其返回给它的`Supervisor`，这样可以保证异常情况可以在一个合适的位置得到处理

__设计一个满足上述要求的系统的难点在于：谁来监管什么。通常，这没有一个万能的解决方案，但是下面给出一些建议__

1. If one actor manages the work another actor is doing, e.g. by passing on sub-tasks, then the manager should supervise the child. The reason is that the manager knows which kind of failures are expected and how to handle them.
1. If one actor carries very important data (i.e. its state shall not be lost if avoidable), this actor should source out any possibly dangerous sub-tasks to children it supervises and handle failures of these children as appropriate. Depending on the nature of the requests, it may be best to create a new child for each request, which simplifies state management for collecting the replies. This is known as the “Error Kernel Pattern” from Erlang.
1. If one actor depends on another actor for carrying out its duty, it should watch that other actor’s liveness and act upon receiving a termination notice. This is different from supervision, as the watching party has no influence on the supervisor strategy, and it should be noted that a functional dependency alone is not a criterion for deciding where to place a certain child actor in the hierarchy.

### 1.2.2 Actor最佳实践

1. `Actors`应该像一群友好的同事：高效地工作，避免打扰其他人，且不占用资源。对应到编程领域，这意味着以事件驱动的方式处理事件，并生成响应。`Actor`不应该阻塞在一些外部的实体上，例如锁、socket等
1. 不要在`Actor`之间传递可变对象（mutable objects），而应该传递不可变的消息。如果将可变状态暴露到外部，那么`Actor`的封装将会被破坏，这样就回到了传统的Java并发编程中
1. `Actor`被设计成`状态`和`行为`的容器，不要通过消息来传递行为（例如，一个封装了行为的闭包对象）。其风险就是在`Actor`之间传递可变状态，这种方式破坏了`Actor`编程模型
1. 上游`Actor`是错误内核最核心的部分，要谨慎地对待它们

## 1.3 什么是Actor

`Actor`是一个包含了`Stage`、`Behavior`、`a Mailbox`、`Child Actors`、`a Supervisor Strategy`的容器，这些被封装在了一个`Actor`的引用中

值得一提的是，`Actor`有一个明确的生命周期：`Actor`不会自动销毁，即便你不再使用它。当创建了一个`Actor`后，销毁它便是我们的职责，这样有助于更好地控制资源的释放

### 1.3.1 Actor Reference

为了从`Actor`模型中获益，我们需要将`Actor object`与外部屏蔽。`Actor Reference`是我们使用`Actor`的唯一方式

这种分为内部对象和外部对象的方法可以实现所有所需操作的透明性：我们可以简单地重启`Actor`，而不用关心引用的更新；将`Actor`对象放在远程主机上；在完全不同的应用程序中向`Actor`发送消息。在任何时候，我们都不要将`Actor`内部的状态暴露出来，或者依赖这些状态

### 1.3.2 Stage

`Actor`会包含一些变量用以表示它当前的状态。这些数据正是`Actor`的核心价值所在，它们必须被严格保护起来，防止被外部污染。每个`Actor`都有它自己的轻量线程，这完全与系统的其他部分隔离开。这意味着，对于同一个`Actor`来说，其处理逻辑是无序考虑并发问题的（与Netty Handler类似）

Akka会在一组真实线程上运行一系列的`Actor`，通常情况下多个`Actor`共享一个线程，且一个`Actor`在其生命周期中，可能运行在不同的真实线程上，但这并不影响`Actor`的`单线程`特性

由于这些状态对于`Actor`来说至关重要，因此，状态不一致是致命的。当一个`Actor`出现异常被`Supervisor`重启，那么这个新的`Actor`与原来的`Actor`无任何关系。但是可以通过持久化消息，并重新执行来恢复先前的状态

### 1.3.3 Behavior

每次处理消息时，它都与当前`Actor`的行为匹配。行为指的是在某个时间点对某个消息的处理动作（通常表现形式是一个函数）

### 1.3.4 Mailbox

`Acotr`的目的就是处理消息。这些消息或是从一个`Actor`发往另一个`Actor`，或者来自外部系统。连接`Sender`与`Receiver`的就是`Mailbox`。每个`Actor`有且仅有一个`Mailbox`，接受来自所有`Actor`发送的消息。对于不同的`Sender`来说，消息`enqueue`的顺序是未知的。但是对于同一个`Sender`来说，消息`enqueue`的顺序与发送的顺序严格一致

`Mailbox`有多种不同的实现，默认的是`FIFO`模式：消息被处理的顺序与消息入队的顺序严格一致。其次，还有`Priority`模式，即消息处理的顺序可能与入队的顺序不一致，每次总是处理优先级最高的消息

### 1.3.5 Child Actors

每个`Actor`都可以是一个`Supervisor`，如果一个`Actor`创建了`Subordinate Actor`用于处理子任务，那么它将会自动监管这些`Subordinate Actor`。`Subordinate Actor List`保存在`Actor`的上下文中，我们可以通过`context.actorOf(...)`或` (context.stop(child))`来改变`Subordinate Actor List`，这些操作会立即生效。值得一提的是，这些操作是异步执行的，并不会阻塞当前`Actor`

### 1.3.6 Supervisor Strategy

Akka会透明地处理错误，由于`Strategy`是如何构建`Actor System`的基础，因此一旦创建了`Actor`，就不能更改它

考虑到每个`Actor`有且仅有一个`Strategy`，如果一个`Actor`的`Subordinate Actor`包含了不同的`Strategy`，那么这些`Subordinate Actor`将会根据`Strategy`进行分组

### 1.3.7 Actor的终结

当`Actor`出现异常，且不被重启，那么它将自我终结，或者被`Supervisor`终结。`Actor`终结后，它会释放资源，将`Mailbox`中所有未处理的message全部流转到系统的`Dead Letter Mailbox`，该邮箱将它们作为死信转发到事件流。然后将`Actor`中的`Mailbox`替换成`System Mailbox`，将所有新消息作为死信重定向到事件流。但是，这是在尽最大努力的基础上完成的，因此不要依赖它来构建`guaranteed delivery`

## 1.4 Supervision and Monitoring

### 1.4.1 什么是Supervision

`Supervision`描述了`Actor System`中各个`Actor`的依赖关系：主管`Supervisor`将任务委托给下属，因此必须处理由下属回报的错误信息。当一个`Actor`发现一个错误时，它会终止它以及它的所有`Subordinate Actor`，并将错误信息通过message发送给`Supervisor Actor`。作为一个`Supervisor Actor`，当其接收到来自`Subordinate Actor`的错误信息时，通常有如下几种处理方式

1. 恢复`Subordinate Actor`，并保持其累积的内部状态
1. 重启`Subordinate Actor`，重置其内部状态
1. 永久地终结该`Subordinate Actor`
1. 升级错误，继续向上层`Supervisor Actor`汇报，因此自身也会进入异常状态

![fig1](/images/Akka-Overview/fig1.png)

如上图所示，一个`Actor Ssystem`至少包含三个`Actor`

1. `The Root Guardian`：整个`Actor System`中只有它没有`Subordinate Actor`，且它处理错误的策略就是终结
1. `The Guardian Actor`：它是我们创建的所有`Normal Actor`的父亲。用`system.actorOf()`方法创建的`Actor`就是`User Actor`的`Subordinate Actor`。当它进行错误升级，即向`Root Actor`汇报错误时，默认的行为就是终止该`User Actor`，于是所有`Normal Actor`都被终结了，因此整个`Actor System`都被终结了
1. `The System Guardian`：这个特殊的`Actor`用于实现有序的关闭顺序，要知道`Logging`模块也是一个`Actor`，因此必须保证`Logging Actor`在所有其他`Normal Actor`终结之前，还处于激活状态

### 1.4.2 Restarting的含义

`Actor`进入异常状态的原因，大致上可以分成以下三类

1. 系统错误，此时会收到一些特殊的Message
1. 在处理消息时由外部资源的异常引起
1. `Actor`错误的内部状态引起

除非错误能够被精确地识别，那就不能排除第三种原因的可能性。如果能够断定某个`Subordinate Actor`产生的异常与自身或者其他`Subordinate Actor`无关时，最佳做法便是重启这个异常的`Subordinate Actor`。重启意味着创建一个新的`Subordinate Actor`，并且更新`Subordinate Actor List`，这也是封装的原因之一，使用者无须关心重启的细节。新创建的`Actor`会继续处理`Mailbox`中的消息，但是不会重复处理引发异常的那个消息。总之，对于外部而言，`Actor`重启是不可见的，无须感知的

__重启的步骤__

1. 暂停当前`Actor`、递归暂停所有的`Subordinate Actor`，暂停意味着停止处理消息
1. 触发旧实例的`preRestart`钩子方法，该方法默认会发送`terminatation request`给所有的`Subordinate Actor`（可以被覆盖，也就是说具体会给哪些`Subordinate Actor`发送`terminatation request`是可以定制的），并触发`postStop`钩子方法
1. 在`preRestart`钩子方法中等待所有`要求被终结`的`Subordinate Actor`终结完毕（正如第二条所说，具体会给哪些`Subordinate Actor`发送`terminatation request`是可以定制的，因此这里用的是`要求被终结`的`Subordinate Actor`）
1. 创建新的`Actor`实例，即触发工厂方法创建实例
1. 触发新实例的`postRestart`钩子方法
1. 对第三步中的所有`未终结`的`Subordinate Actor`发送重启信号，重启的步骤重复步骤2-5
1. 恢复当前`Actor`

### 1.4.3 Lifecycle Monitoring的含义

与`Subordinate Actor`和`Supervisor Actor`的特殊关系不同，一个`Actor`可以`Monitor`任意其他`Actor`的生命周期。由于`Actor`的封装，重启等操作对于外部是不可见的，因此唯一可监控的状态变化就是从激活到终结。`Monitor`被用来将两个`Actor`绑定在一起，以便一个`Actor`可以感知另一个`Actor`的终结

`Lifecycle Monitoring`是通过发送终结消息（Terminated message）来实现的，该消息默认的处理行为就是抛出`DeathPactException`异常。`ActorContext.watch(targetActorRef)`方法开始监控，`ActorContext.unwatch(targetActorRef)`方法结束监控

值得一提的是，`Lifecycle Monitoring`中一个重要的属性就是：即便某个`Actor A`早已终结，后来`Actor B`监控了`Actor A`，`Actor B`仍然会收到`Terminated message`

### 1.4.4 BackoffSupervisor pattern

当`Actor`发生异常，且需要重启时，有时候我们需要延迟一段时间。例如`Actor`发生异常的原因是数据库宕机或者负载过高，我们需要等待一段时间，再重启该`Actor`，此时我们就可以使用内建的延迟重启策略

此外，加上一个随机因子，以避免`Actor`都在同一时刻重启

```Java
final Props childProps = Props.create(EchoActor.class);

final Props  supervisorProps = BackoffSupervisor.props(
  Backoff.onStop(
    childProps,
    "myEcho",
    Duration.ofSeconds(3),
    Duration.ofSeconds(30),
    0.2)); // adds 20% "noise" to vary the intervals slightly

system.actorOf(supervisorProps, "echoSupervisor");
```

```Java
final Props childProps = Props.create(EchoActor.class);

final Props  supervisorProps = BackoffSupervisor.props(
  Backoff.onFailure(
    childProps,
    "myEcho",
    Duration.ofSeconds(3),
    Duration.ofSeconds(30),
    0.2)); // adds 20% "noise" to vary the intervals slightly

system.actorOf(supervisorProps, "echoSupervisor");
```

上述两个例子的差异

1. `Backoff.onStop`：`Actor`正常终结的情况
1. `Backoff.onFailure`：`Actor`崩溃的异常情况

### 1.4.5 One-For-One Strategy vs. All-For-One Strategy

在Akka中存在两种`Supervision Strategy`

1. `OneForOneStrategy`：默认的策略，只针对异常`Subordinate Actor`
1. `AllForOneStrategy`：针对所有的`Subordinate Actor`

`AllForOneStrategy`通常用在`Subordinate Actor`之间关系紧密的场景下，一旦某个`Subordinate Actor`异常了，整体就无法正常处理消息。如果不用这种模式，我们就必须保证在异常`Subordinate Actor`恢复之前，只缓存消息，不处理消息

通常来说，在`OneForOneStrategy`模式下，终结一个`Subordinate Actor`不会影响到其他`Subordinate Actor`。但是，如果`Terminated message`没有被`Supersivor Actor`处理，那么`Supersivor Actor`就会抛出`DeathPactException`，并重启，于是默认的`preRestart`方法会终结所有`Subordinate Actor`

## 1.5 Actor References, Paths and Addresses

### 1.5.1 什么是Actor Reference

### 1.5.2 什么是Actor Path

### 1.5.3 如何获取Actor References

### 1.5.4 Actor Reference与Path的等价性

### 1.5.5 重用Actor Path

## 1.6 参考

* [General Concepts](https://doc.akka.io/docs/akka/current/general/index.html)
