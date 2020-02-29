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

# 1 General Concepts

## 1.1 Terminology Concepts

### 1.1.1 Concurrency vs. Parallelism

`并发`与`并行`是一个老生常谈的概念。简而言之，它们的含义相似，但存在细微差别：`并发`强调的是存在多个任务，但是这些任务并不一定真的同时执行（单核CPU也可有`并发`）；`并行`强调同时执行（单核CPU不可能有`并行`）

### 1.1.2 Asynchronous vs. Synchronous

对于同步调用，调用方无法做其他事情，直到方法返回或者抛出异常。异步调用可以做其他事情，但是需要借助其他机制来拿到调用的结果，例如`Callback`、`Future`、`Message`

同步与异步是从调用方的角度来看待方法调用

### 1.1.3 Non-blocking vs. Blocking

阻塞指的是一个线程会让其他线程无期限地等待（例如，多个线程共享一个互斥锁，但是某个线程进入了一个死循环中）；而非阻塞指的是一个线程不会让其他线程无期限地等待下去

### 1.1.4 Deadlock vs. Starvation vs. Live-lock

当多个线程产生循环依赖时，就可能产生死锁。例如，线程A、B、C分别持有独占资源α、β、γ，但A还需要β，B还需要γ，C还需要α，这样就会产生死锁

当高优先级的任务足够多的时候，如果系统总是优先调度高优先级任务，那么低优先级的任务就会发生饥饿

活锁与死锁很像，区别在于活锁处于一个连续变化的状态，而死锁处于一个静止的状态。例如，线程A、B分别持有独占资源α、β，且A尝试获取β，B尝试获取α，线程A、B若检测到有其他线程正在请求他们所占有的资源时，就会释放该资源

### 1.1.5 Non-blocking Guarantees

#### 1.1.5.1 Wait-freedom

所有方法都在有限步骤内完成，不会发生死锁、饥饿等现象

#### 1.1.5.2 Lock-freedom

几乎所有的方法在有限步骤内完成，不会发生死锁，但是可能发生饥饿现象

#### 1.1.5.3 Obstruction-freedom

方法在有限时间内完成，意味着在执行过程中，其他线程会阻塞

Optimistic concurrency control (OCC)通常是`obstruction-free`。在这种方式下，线程会尝试修改一个共享资源的状态，并且能够感知到状态修改是否有冲突（例如，CAS），当发生冲突时，会重试

## 1.2 Actor System

`Actors`就是一些封装了`状态`和`行为`的对象，它们仅通过`交换消息`来通信。`Actor`严格遵循了OOP（object-oriented programming）原则

### 1.2.1 Hierarchical Structure

`Actors`自然地形成层次结构。一个`Actor`通常会将一个任务分解成多个简单的任务，并监管这些任务的执行。

每个`Actor`都有一个监督者`Supervisor`，即创建它的那个`Actor`。例如`Actor A`创建了`Actor B`，那么`A`就是`B`的`Supervisor`

`Actor System`的典型特征就是，一个大任务通常会被分解成多个（可能包含多个层级）更易执行的子任务。为了达到这样的目的，任务本身需要清晰地定义，同时，返回的结果也必须清晰地定义。也就是说，一个`Actor`可以处理哪些响应，不可以处理哪些响应都是需要严格设计过的，当一个`Actor`收到了一个它无法处理的消息时，它应该将其返回给它的`Supervisor`，这样可以保证异常情况可以在一个合适的位置得到处理

__设计一个满足上述要求的系统的难点在于：谁来监管什么。通常，这没有一个万能的解决方案，但是下面给出一些建议__

1. If one actor manages the work another actor is doing, e.g. by passing on sub-tasks, then the manager should supervise the child. The reason is that the manager knows which kind of failures are expected and how to handle them.
1. If one actor carries very important data (i.e. its state shall not be lost if avoidable), this actor should source out any possibly dangerous sub-tasks to children it supervises and handle failures of these children as appropriate. Depending on the nature of the requests, it may be best to create a new child for each request, which simplifies state management for collecting the replies. This is known as the “Error Kernel Pattern” from Erlang.
1. If one actor depends on another actor for carrying out its duty, it should watch that other actor’s liveness and act upon receiving a termination notice. This is different from supervision, as the watching party has no influence on the supervisor strategy, and it should be noted that a functional dependency alone is not a criterion for deciding where to place a certain child actor in the hierarchy.

### 1.2.2 Actor Best Practices

1. `Actors`应该像一群友好的同事：高效地工作，避免打扰其他人，且不占用资源。对应到编程领域，这意味着以事件驱动的方式处理事件，并生成响应。`Actor`不应该阻塞在一些外部的实体上，例如锁、socket等
1. 不要在`Actor`之间传递可变对象（mutable objects），而应该传递不可变的消息。如果将可变状态暴露到外部，那么`Actor`的封装将会被破坏，这样就回到了传统的Java并发编程中
1. `Actor`被设计成`状态`和`行为`的容器，不要通过消息来传递行为（例如，一个封装了行为的闭包对象）。其风险就是在`Actor`之间传递可变状态，这种方式破坏了`Actor`编程模型
1. 上游`Actor`是错误内核最核心的部分，要谨慎地对待它们

## 1.3 What is an Actor

`Actor`是一个包含了`Stage`、`Behavior`、`a Mailbox`、`Child Actors`、`a Supervisor Strategy`的容器，这些被封装在`Actor Reference`中

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

### 1.3.7 When an Actor Terminates

当`Actor`出现异常，且不被重启，那么它将自我终结，或者被`Supervisor`终结。`Actor`终结后，它会释放资源，将`Mailbox`中所有未处理的message全部流转到系统的`Dead Letter Mailbox`，该邮箱将它们作为死信转发到事件流。然后将`Actor`中的`Mailbox`替换成`System Mailbox`，将所有新消息作为死信重定向到事件流。但是，这是在尽最大努力的基础上完成的，因此不要依赖它来构建`guaranteed delivery`

## 1.4 Supervision and Monitoring

### 1.4.1 What Supervision Means

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

### 1.4.2 What Restarting Means

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

### 1.4.3 What Lifecycle Monitoring Means

与`Subordinate Actor`和`Supervisor Actor`的特殊关系不同，一个`Actor`可以`Monitor`任意其他`Actor`的生命周期。由于`Actor`的封装，重启等操作对于外部是不可见的，因此唯一可监控的状态变化就是从激活到终结。`Monitor`被用来将两个`Actor`绑定在一起，以便一个`Actor`可以感知另一个`Actor`的终结

`Lifecycle Monitoring`是通过发送终结消息（Terminated message）来实现的，该消息默认的处理行为就是抛出`DeathPactException`异常。`ActorContext.watch(targetActorRef)`方法开始监控，`ActorContext.unwatch(targetActorRef)`方法结束监控

值得一提的是，`Lifecycle Monitoring`中一个重要的属性就是：即便某个`Actor A`早已终结，后来`Actor B`监控了`Actor A`，`Actor B`仍然会收到`Terminated message`

### 1.4.4 BackoffSupervisor pattern

当`Actor`发生异常，且需要重启时，有时候我们需要延迟一段时间。例如`Actor`发生异常的原因是数据库宕机或者负载过高，我们需要等待一段时间，再重启该`Actor`，此时我们就可以使用内建的延迟重启策略

此外，加上一个随机因子，以避免`Actor`都在同一时刻重启

```java
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

```java
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

![fig2](/images/Akka-Overview/fig2.png)

### 1.5.1 What is an Actor Reference

`Actor Reference`指的是`ActorRef`的子类，通常，我们用`Actor Reference`来发送消息。我们可以调用`Actor.self()`方法来获取到`Actor`自身对应的`Actor Reference`，同样，我们可以调用`Actor.sender()`方法来获取到消息发送方对应的`Actor Reference`

`Actor Reference`的种类

1. `Purely Local Actor Reference`: 不支持网络通信，无法跨应用，无法跨JVM
1. `Local Actor Reference`: 支持网络通信，但仅限在同一个JVM中的多个Java进程，无法跨JVM
1. `Remote Actor Reference`: 支持网络通信，可以跨JVM

### 1.5.2 What is an Actor Path

由于`Actor`之间有严格的层级结构，因此对于每个`Actor`，根据层级关系，有唯一确定的名字。这些名字可以看做是文件系统中的文件。因此我们将这些名字称为`Actor Path`

#### 1.5.2.1 Difference Between Actor Reference and Path

`Actor Reference`代表着一个`Actor`，因此`Actor Reference`的生命周期与`Actor`的生命周期匹配。`Actor Path`仅代表一个名字，本身并没有生命周期，因此永远不会失效。我们可以在不创建`Actor`的情况下，创建`Actor Path`；但是，不可以在不创建`Actor`的情况下，创建`Actor Reference`

我们可以创建一个`Actor`，然后终结它，然后再创建一个新的`Actor`，共享同一个`Actor Path`。这两个`Actor`仅仅共享了`Actor Path`，除此之外，无任何关系

#### 1.5.2.2 Actor Path Anchors

__pure local actor path__: `akka://<akka-system-name>/user/<actor-hierarchy-path>`

__remote actor path__: `akka.<protocol>://<akka-system-name>@<host>:<port>/user/<actor-hierarchy-path>`

* 默认的`protocol`是`tcp`

#### 1.5.2.3 Logical Actor Paths

`Logical Actor Path`指的是：沿着`Supervision Link`，从`Root Guardian`到指定`Actor`的路径。即`/user/<actor-hierarchy-path>`

#### 1.5.2.4 Physical Actor Paths

有时候，我们会在一个远程的`Actor System`中创建一个`Actor`，此时仅仅用`Logical Actor Path`，那么我们就需要处理额外的网络通信逻辑，这一部分会带来较大的工作量

值得注意的是，一个`Physical Actor Path`是全局唯一的，而`Logical Actor Path`仅仅在当前`Actor System`中唯一

#### 1.5.2.5 Symbolic Link

与传统的文件系统不同，`Actor Path`不支持`Symbolic Link`

### 1.5.3 How are Actor References obtained

简单来说，获取`Actor Reference`的方式有且仅有两种：`创建`或者`查找`

#### 1.5.3.1 Creating Actors

通过`ActorSystem.actorOf`方法或者`ActorContext.actorOf`方法来创建

1. `ActorSystem.actorOf`方法创建的`Logical Actor Path`为`/user/<actor-name>`
1. `ActorContext.actorOf`方法创建的`Logical Actor Path`为`/user/<original-actor-path>/<new-actor-name>`

#### 1.5.3.2 Looking up Actors by Concrete Path

通过`ActorSystem.actorSelection`方法或者`ActorContext.actorSelection`方法来搜索

1. `ActorSystem.actorSelection`方法的搜索起点是顶部
1. `ActorContext.actorSelection`方法的搜索起点是当前Actor

#### 1.5.3.3 Querying the Logical Actor Hierarchy

### 1.5.4 Actor Reference and Path Equality

只有当`Actor Path`相同，且封装了同一个`Actor`时，`Actor Reference`才相同。在`Actor`发生`re-create`（先`terminate`后`create`）前后的两个`Actor Reference`是不同的；在`Actor`发生`re-start`前后的两个`Actor`是相同的

### 1.5.5 Reusing Actor Paths

当一个`Actor`终结后，又重新创建了一个新的`Actor`，这两个`Actor`复用同一个`Actor Path`。Akka不保证在此过渡期间发往该`Actor`的任何事件的有序性，换言之，新创建的`Actor`可能收到本该发往旧`Actor`的消息

### 1.5.6 The Interplay with Remote Deployment

在远程模式下，我们创建一个`Actor`，Akka系统会决定在本地JVM创建该`Actor`或者在远程JVM中创建该`Actor`。对于后者，`Action`的创建可能触发在另一个远程JVM中，显然对应的是另一个`Actor System`。因此，__`Actor System`会为这种方式创建的`Actor`赋予一个特殊的`Actor Path`__。在这种情况下，新创建的`Actor`，其对应的`Supervisor Actor`就在另一个`Actor System`中（触发创建动作的`Actor System`），因此`context.parent`与`context.path.parent`并不是同一个`Actor`

![fig3](/images/Akka-Overview/fig3.png)

### 1.5.7 What is the Address part used for

当通过网络传递一个`Actor Reference`时，`Actor Path`即代表了这个`Actor Reference`。因此，`Actor Path`必须将所有必要的信息打包进`Actor Path`当中，这些信息包括`protocol`、`host`、`port`。当`Actor System`接收一个来自远程节点的`Actor Reference`时，首先会检查`Actor Path`是否匹配了本地的一个`Actor`，如果匹配成功，则将其替换成一个`Local Actor Reference`，否则就是`Remote Actor Reference`

### 1.5.8 Top-Level Scopes for Actor Paths

1. `/`: 根路径
1. `/user`: 所有`Normal Actor`的起始路径
1. `/system`: 所有`System-created Actor`的起始路径，包括`Logging Actor`
1. `/deadLetters`: 所有发往已终结或者不存在的`Actor`的消息，最终都会被路由到这里
1. `/temp`: `Short-lived System-created Actor`的起始路径
1. `/remote`: `Remote Actor`的起始路径（其`Supervisor Actor`位于远程节点上）

## 1.6 Location Transparency

### 1.6.1 Distributed by Default

__Akka在设计之初就考虑到了分布式的场景：`Actor`之间所有的交互都是通过Message来完成的，且都是异步的，这就保证了所有的操作在单节点或者多节点上都是等价的__。为了实现这一愿景，所有的机制都是从`Remote`模式开始设计，然后对于`Local`模式进行优化。而不是从`Local`开始，然后再去考虑`Remote`的场景

### 1.6.2 How is Remoting Used

__Akka几乎没有提供任何有关Remote的API，是否以Remote模式工作，完全取决于配置__。这种特性可以让我们在不改动任何一行代码的情况下，让`Akka System`工作于不同的模式下，并且可以得到很好的可伸缩性、扩展性

Akka中唯一个与Remote相关的API就是：我们可以向`Props`提供一个`Deploy`参数，来改变模式。但是当`Code`与`Configuration`共存时，`Configuration`最终生效

### 1.6.3 Peer-to-Peer vs. Client-Server

`Akka Remote`是一个基于`Peer-to-Peer`的通信模块，用于连接多个`Actor System`，该模块是构建`Akka Clustering`的基础

选用`Peer-to-Peer`模式而不是`Client-Server`模式，主要有以下几个原因

1. 不同`Actor System`之间的通信是镜像对称的：`Actor System A`可以连接到`Actor System B`；同时`Actor System B`也可以连接到`Actor System A`
1. 不同`Actor System`在通信系统中的角色是镜像对称的，没有一个`Actor System`只接受连接，也没有一个`Actor System`只发起连接

### 1.6.4 Marking Points for Scaling Up with Routers

__更进一步，有时候，我们不想让我们的系统拆分成多个部分运行在不同的节点上，而是想让我们的系统在不同的节点上运行多个实例__。Akka提供了不同的路由策略，包括`round-robin`。

The only thing necessary to achieve this is that the developer needs to declare a certain actor as “withRouter”, then—in its stead—a router actor will be created which will spawn up a configurable number of children of the desired type and route to them in the configured fashion. Once such a router has been declared, its configuration can be freely overridden from the configuration file, including mixing it with the remote deployment of (some of) the children.

## 1.7 Akka and the Java Memory Model

### 1.7.1 Java Memory Model

在Java 5之前，Java的内存模型存在很多问题

1. 可见性问题：一个线程可以看到其他线程写的值
1. 有序性问题：指令未能按照期望的顺序执行

在JSR-133之后，这些问题都得到了解决。Java内存模型中引入了`happens-before`原则，详细请参考{% post_link Java-happens-before %}

### 1.7.2 Actors and Java Memory Model

介于`Actor`在Akka中的实现方式，多个线程同时操作共享内存的方式有如下两种

1. 在大多数情况下，发送的消息要求是不可变的。但是如果消息是可变的，那么将不会存在`happens-before`规则，接受者可能看到构建了一半的对象，或者说看到了某些值的一部分（例如double以及long）
1. 如果`Actor`在处理某个消息时修改了该消息的内部状态，并且在后续某个时间点又访问了这个消息的状态。`Actor Model`不保证同一个`Actor`在处理不同消息时位于同一个线程中

__为了避免可见性问题以及有序性问题，Akka保证了如下两条happens-before规则__

1. `The actor send rule`：对于同一个`Actor`，消息的发送`happens-before`消息的接收？？？
1. `The actor subsequent processing rule`：对于同一个`Actor`，处理某个消息`happens-before`处理下一个消息

### 1.7.3 Futures and the Java Memory Model

`Future`的完成`happens-before`注册回调的触发

Akka建议不要将`non-final`字段包装到闭包当中，如果一定要将`non-final`字段包装到闭包当中，那么这个字段需要用`volatile`关键字标记

## 1.8 Message Delivery Reliability

## 1.9 参考

* [General Concepts](https://doc.akka.io/docs/akka/current/general/index.html)

# 2 Clustering

## 2.1 Cluster Specification

`Akka Cluster`提供了去中心化的容错机制，即无单点故障以及单机瓶颈。它使用了`gossip`协议以及自动故障检测机制。`Akka Cluster`允许构建一个分布式的应用，即整个应用/服务部署在多个节点上（准确地说是多个`Actor System`）

### 2.1.1 Term

__`node`（下文称为节点）__：`Akka Cluster`中的逻辑单元，由`hostname:port:uid`三元组唯一确定。一台物理机上可能运行着多个`node`

__`cluster`（下文称为集群）__：由多个`node`组成的一个有机整体

__`leader`__：在`cluster`中扮演者领导者的__单个`node`__。管理者`cluter`以及`node`状态的转换

### 2.1.2 Membership

`cluster`由一组`node`构成。每个`node`的由三元组`hostname:port:uid`唯一确定。这个标志符包含了一个`UID`，这个`UID`在`hostname:port`范围下是唯一的，也就是说，一个`Actor System`无法重复加入到一个集群之中，当创建一个新的`Actor System`时，会生成一个新的`UID`

#### 2.1.2.1 Gossip

集群节点之间的通信，使用的是`Gossip Protocol`。集群状态信息会及时在节点上收敛，收敛意味着，一个节点观测到的集群状态与其他节点观测到的集群状态一致。

当任何节点变得`unreachable`时，这些节点需要变成`reachable`、`down`、`removed`状态，在此之前，处于非收敛状态

#### 2.1.2.2 Failure Detector

`Failure Detector`用于检测那些`unreachable`的节点。`Failure Detector`用于解耦`monitoring`和`interpretation`。`Failure Detector`会保留一系列历史的异常数据，用于估计节点`up`或`down`的概率

`threshold`用于调整`Failure Detector`的行为。举个例子，一个较低的`threshold`可能会产生较多的错误估计，但是能够快速地响应一些异常状态；一个较高的`threshold`很少会犯错，但是通常检测一个节点处于异常状态会消耗更多的时间。默认的`threshold`是8，适用于绝大部分的应用

在一个集群中，一个节点通常被多个节点监视（默认情况下，不超过5个），当任何一个监视节点检测到该节点变得`unreachable`时，借助于`gossip`协议，就会将该信息传播到集群的其他节点上。换句话说，当一个节点发现某个节点变得`unreachable`后，在很短时间内，其他节点也会同步这一信息

节点每秒都会发送心跳包，每个心跳包包含了`request/reploy`对，其中`reploy`被当做`Failure Detector`的输入

此外，`Failure Detector`还会检测到节点重新变回`reachable`状态，当所有检测节点都检测到该节点变为`reachable`状态，且经过`gossip`传播后，会将其标记为`reachable`状态

如果系统消息无法达到一个节点，那么该节点将会被隔离，且永远无法从`unreachable`中恢复。此时，节点会被标记为`down`或者`removed`状态，该`Actor System`只有重启后，才允许再次加入集群中

#### 2.1.2.3 Leader

当达到`gossip`收敛状态后，`leader`才会被确定，在`Akka`中，`leader`不是通过选举产生的，在集群达到收敛状态后，`leader`总能被任意节点确定出来。`leader`只是一个角色，任何节点都可以成为`leader`，且可能在不同的收敛轮次内发生改变。`leader`通常是有序节点中的第一个节点，对应的状态是`up`或`leaving`

`leader`的作用是将节点加入或移除集群，将刚加入集群的节点标记为`up`状态，或者将已存在的节点标记为`removed`状态。同时，`leader`也拥有一定的特权，根据`Failure Detector`的结果，它可以将一个处于`unreachable`的节点标记为`down`状态

#### 2.1.2.4 Seed Nodes

`Seed Nodes`是为新加入集群的节点所配置的接触点。当一个节点需要加入集群时，它会向所有`Seed Node`发送消息，并向最先回复的`Seed Node`发送`Join Command`消息

`Seed Node`的配置不会影响集群的运行时，它们只与加入集群的新节点相关，`Seed Node`帮助新节点找到发送`Join Command`消息的节点。新节点可以将该消息发送给集群中的任意节点，而不仅仅是`Seed Node`。换言之，集群中的任意节点都可以是`Seed Node`

#### 2.1.2.5 Membership Lifecycle

一个节点从`joining`状态开始生命周期，当集群中的所有节点都观测到该节点加入后，`leader`就会将该节点标记为`up`

一个节点如果以一种安全、期望的方式离开集群，那么就会进入`leaving`状态，当`leader`观测到集群在`leaving`状态收敛时，就会将它标记为`exiting`，当其他所有节点观测到该节点进入`exiting`状态后，`leader`就会将其标记为`removed`状态

当一个节点变得`unreachable`时，收敛状态将无法达到，在此时，`leader`无法做任何工作（比如，让一个节点加入集群）。为了达到一个可收敛的状态，该节点必须重新`reachable`或者被标记为`down`状态，如果这个节点想要重新加入到集群中，那么它必须重新启动，然后重新走一遍join的流程。`leader`会在规定时间之后（基于配置），将`unreachable`节点标记为`down`状态

上面说到，当节点进入变得`unreachable`时，集群无法达到收敛状态，我们可以通过配置`akka.cluster.allow-weakly-up-members`（默认开启），这样一来，在非收敛状态时，新节点允许进入集群，但会被标记为`weaklyup`状态，当收敛状态重新达到时，`leader`会将`weaklyup`标记为`up`

__`akka.cluster.allow-weakly-up-members=off`时，状态机如下__

![fig4](/images/Akka-Overview/fig4.png)

__`akka.cluster.allow-weakly-up-members=on`时，状态机如下__

![fig5](/images/Akka-Overview/fig5.png)

__成员状态__

1. `joinging`：节点加入集群时的瞬态
1. `weakly up`：当集群未收敛，且`akka.cluster.allow-weakly-up-members=on`时，节点加入集群时的瞬态
1. `up`：正常的工作状态
1. `leaving/exiting`：以优雅、期望地方式离开集群的状态
1. `down`：不再参与集群的决策
1. `removed`：不再是集群的成员

__用户可以进行的操作__

1. `join`：加入集群
1. `leave`：优雅地离开集群
1. `down`：将节点标记为down

__leader actions__

1. `joinint->up`
1. `weakly up->up`
1. `exiting->removed`

## 2.2 Cluster Usage

### 2.2.1 When and where to use Akka Cluster

微服务架构有着诸多的优点，微服务的独立性允许多个更小、更专业的团队能够频繁地提供新功能，能够快速响应业务需求

__在微服务架构中，我们必须考虑`服务间`以及`服务内`这两种通信方式__

通常，我们不建议用`Akka Cluster`来完成服务间的通信，因为这会导致两个微服务产生严重的代码耦合，且会带来部署的依赖性，这与微服务架构的初衷相悖

但是，对于一个微服务的不同节点之间的通信（一个微服务通常是一个集群，部署在多台机器上）对于耦合性的要求就很低，因为它们的代码是相同的，且是同时部署的

### 2.2.2 Joining to Seed Nodes

我们可以手动配置`Seed Node`或自动配置`Seed Node`。在完成连接过程之后，`Seed Node`与其他节点并无差别。此外，集群中的任意节点都可以作为`Seed Node`（即便配置文件中的`Seed Node`列表不包含该节点，只要该节点正常加入集群后，该节点就可以作为`Seed Node`）

我们可以在配置文件中配置`Seed Node`

```conf
akka.cluster.seed-nodes = [
  "akka.tcp://ClusterSystem@host1:2552",
  "akka.tcp://ClusterSystem@host2:2552"]
```

或者，在启动JVM时，指定环境变量

```conf
-Dakka.cluster.seed-nodes.0=akka.tcp://ClusterSystem@host1:2552
-Dakka.cluster.seed-nodes.1=akka.tcp://ClusterSystem@host2:2552
```

`Seed Node`可以以任意顺序启动，除了第一个`Seed Node`，该`Seed Node`节点必须作为集群启动的第一个节点，否则其他`Seed Node`以及其他节点将无法加入集群。将第一个`Seed Node`特殊处理的原因是，避免形成多个孤立的集群

当`Seed Node`的数量超过1时，且集群正常启动后，停止第一个`Seed Node`是没有关系的，如果这个`Seed Node`再次加入，那么它首先会尝试连接其他的`Seed Node`。注意，如果我们将所有的`Seed Node`全部停止，然后重启所有的`Seed Node`，那么就会创建一个全新的集群，而不是重新加入之前的集群，于是之前的集群变成了一个孤岛（这也是为什么需要特殊处理第一个`Seed Node`的原因）

借助[Cluster Bootstrap](https://developer.lightbend.com/docs/akka-management/current/bootstrap/index.html)，我们无需手动配置`Seed Node`，便可以自动化地创建`Seed Node`

此外，我们还可以通过编程的方式，指定`Seed Node`

```java
final Cluster cluster = Cluster.get(system);
List<Address> list = new LinkedList<>(); //replace this with your method to dynamically get seed nodes
cluster.joinSeedNodes(list);
```

### 2.2.3 Downing

当一个节点被`Failure Detector`认为是`unreachable`时，`Leader`便无法正常工作（因为此时集群处于非收敛状态），例如，无法将一个新加入集群的节点标记为`up`状态。该`unreachable`节点必须重新变得`reachable`或者被标记为`down`状态后，集群才会进入收敛状态，`Leader`才能进行正常工作。节点可以以手动或者自动的方式被标记为`down`状态。默认以手动方式，利用`JMX`或`HTTP`。此外，还可以以编程的方式将节点标记为`down`，即`Cluster.get(system).down(address)`

如果一个正常执行的节点将自身标记为`down`，那么该节点将会终止

此外，`Akka`还提供了一种自动将`unreachable`节点标记为`down`的机制，这意味着`Leader`会自动将超过配置时间的`unreachable`节点标记为`down`。__`Akka`强烈建议`不要使用该特性`__：该`auto-down`特性不应该在生产环境使用，因为当出现网络抖动时（或者长时间的Full GC，或者其他原因），集群的两部分变得相互不可见，于是会将对方移除集群，随后形成了两个完全独立的集群

### 2.2.4 Leaving

节点离开集群的方式有两种

1. 直接杀掉JVM进程，该节点会被检测为`unreachable`，于是被自动或手动地标记为`down`
1. 告诉集群将要离开集群，这种方式更为优雅，可以通过`JMX`或`HTTP`来实现，或者通过编程方式来实现，如下

```java
final Cluster cluster = Cluster.get(system);
cluster.leave(cluster.selfAddress());
```

### 2.2.5 WeaklyUp Members

当集群中的某节点变得`unreachable`后，集群无法收敛，`Leader`无法正常工作，在这种情况下，我们仍然想让新节点加入到集群中来

新加入的节点会首先被标记为`WeaklyUp`，当集群进入收敛状态，`Leader`会将标记为`WeaklyUp`状态的节点标记为`Up`，该特性是默认开启的，可以通过`akka.cluster.allow-weakly-up-members = off`来关闭

我们可以订阅`MemberWeaklyUp`事件来感知这一状态，但是由于这一事件是发生在集群非收敛状态下的，即节点并不一定能够感知到这个状态（网络问题或其他原因），因此不要基于这个状态来作出某些决策

### 2.2.6 Subscribe to Cluster Events

我们可以通过`Cluster.get(system).subscribe`来订阅某些消息

```java
cluster.subscribe(getSelf(), MemberEvent.class, UnreachableMember.class);
```

__与节点生命周期相关的事件如下__

1. `ClusterEvent.MemberJoined`：节点刚加入集群，被标记为`joining`状态
1. `ClusterEvent.MemberUp`：节点加入集群，被标记为`up`状态
1. `ClusterEvent.MemberExited`：节点离开集群，被标记为`exiting`状态。注意到，当其他节点收到该消息时，离开集群的节点可能早已终结
1. `ClusterEvent.MemberRemoved`：节点被集群移除
1. `ClusterEvent.UnreachableMember`：节点被`Failure Detector`或者其他任意节点检测为`unreachable`
1. `ClusterEvent.ReachableMember`：节点再次被检测为`reachable`。之前`所有`检测到该节点为`unreachable`的节点，都需要再次检测到该节点为`reachable`

## 2.3 参考

* [Clustering](https://doc.akka.io/docs/akka/current/index-cluster.html)
