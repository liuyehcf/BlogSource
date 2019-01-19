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

# 1 How the Actor Model Meets the Needs of Modern, Distributed Systems

To achieve any meaningful concurrency and performance on current systems, threads must delegate tasks among each other in an efficient way without blocking. With this style of task-delegating concurrency (and even more so with networked/distributed computing) call stack-based error handling breaks down and new, explicit error signaling mechanisms need to be introduced. Failures become part of the domain model.

Concurrent systems with work delegation needs to handle service faults and have principled means to recover from them. Clients of such services need to be aware that tasks/messages might get lost during restarts. Even if loss does not happen, a response might be delayed arbitrarily due to previously enqueued tasks (a long queue), delays caused by garbage collection, etc. In face of these, concurrent systems should handle response deadlines in the form of timeouts, just like networked/distributed systems.

![fig1](/images/Akka-Overview/fig1.png)

In summary, this is what happens when an actor receives a message:

1. The actor adds the message to the end of a queue.
1. If the actor was not scheduled for execution, it is marked as ready to execute.
1. A (hidden) scheduler entity takes the actor and starts executing it.
1. Actor picks the message from the front of the queue.
1. Actor modifies internal state, sends messages to other actors.
1. The actor is unscheduled.

To accomplish this behavior, actors have:

1. A mailbox (the queue where messages end up).
1. A behavior (the state of the actor, internal variables etc.).
1. Messages (pieces of data representing a signal, similar to method calls and their parameters).
1. An execution environment (the machinery that takes actors that have messages to react to and invokes their message handling code).
1. An address (more on this later).

This is a very simple model and it solves the issues enumerated previously:

1. Encapsulation is preserved by decoupling execution from signaling (method calls transfer execution, message passing does not).
1. There is no need for locks. Modifying the internal state of an actor is only possible via messages, which are processed one at a time eliminating races when trying to keep invariants.
1. There are no locks used anywhere, and senders are not blocked. Millions of actors can be efficiently scheduled on a dozen of threads reaching the full potential of modern CPUs. Task delegation is the natural mode of operation for actors.
1. State of actors is local and not shared, changes and data is propagated via messages, which maps to how modern memory hierarchy actually works. In many cases, this means transferring over only the cache lines that contain the data in the message while keeping local state and data cached at the original core. The same model maps exactly to remote communication where the state is kept in the RAM of machines and changes/data is propagated over the network as packets.

Since we no longer have a shared call stack between actors that send messages to each other, we need to handle error situations differently. There are two kinds of errors we need to consider:

1. The first case is when the delegated task on the target actor failed due to an error in the task (typically some validation issue, like a non-existent user ID). In this case, the service encapsulated by the target actor is intact, it is only the task that itself is erroneous. The service actor should reply to the sender with a message, presenting the error case. There is nothing special here, errors are part of the domain and hence become ordinary messages.
1. The second case is when a service itself encounters an internal fault. Akka enforces that all actors are organized into a tree-like hierarchy, i.e. an actor that creates another actor becomes the parent of that new actor. This is very similar how operating systems organize processes into a tree. Just like with processes, when an actor fails, its parent actor is notified and it can react to the failure. Also, if the parent actor is stopped, all of its children are recursively stopped, too. This service is called supervision and it is central to Akka.

![fig2](/images/Akka-Overview/fig2.png)

# 2 Overview of Akka libraries and modules

1. Actor library
1. Remoting
1. Cluster
1. Cluster Sharding
1. Cluster Singleton
1. Cluster Publish-Subscribe
1. Persistence
1. Distributed Data
1. Streams
1. HTTP

## 2.1 参考

* [Overview of Akka libraries and modules](https://doc.akka.io/docs/akka/current/guide/modules.html)

# 3 General Concepts

## 3.1 Terminology, Concepts

### 3.1.1 Concurrency vs. Parallelism

Concurrency and parallelism are related concepts, but there are small differences. Concurrency means that two or more tasks are making progress even though they might not be executing simultaneously. This can for example be realized with time slicing where parts of tasks are executed sequentially and mixed with parts of other tasks. Parallelism on the other hand arise when the execution can be truly simultaneous.

### 3.1.2 Asynchronous vs. Synchronous

A method call is considered synchronous if the caller cannot make progress until the method returns a value or throws an exception. On the other hand, an asynchronous call allows the caller to progress after a finite number of steps, and the completion of the method may be signalled via some additional mechanism (it might be a registered callback, a Future, or a message).

A synchronous API may use blocking to implement synchrony, but this is not a necessity. A very CPU intensive task might give a similar behavior as blocking. In general, it is preferred to use asynchronous APIs, as they guarantee that the system is able to progress. Actors are asynchronous by nature: an actor can progress after a message send without waiting for the actual delivery to happen.

### 3.1.3 Non-blocking vs. Blocking

We talk about blocking if the delay of one thread can indefinitely delay some of the other threads. A good example is a resource which can be used exclusively by one thread using mutual exclusion. If a thread holds on to the resource indefinitely (for example accidentally running an infinite loop) other threads waiting on the resource can not progress. In contrast, non-blocking means that no thread is able to indefinitely delay others.

Non-blocking operations are preferred to blocking ones, as the overall progress of the system is not trivially guaranteed when it contains blocking operations.

### 3.1.4 Deadlock vs. Starvation vs. Live-lock

Deadlock arises when several participants are waiting on each other to reach a specific state to be able to progress. As none of them can progress without some other participant to reach a certain state (a “Catch-22” problem) all affected subsystems stall. Deadlock is closely related to blocking, as it is necessary that a participant thread be able to delay the progression of other threads indefinitely.

In the case of deadlock, no participants can make progress, while in contrast Starvation happens, when there are participants that can make progress, but there might be one or more that cannot. Typical scenario is the case of a naive scheduling algorithm that always selects high-priority tasks over low-priority ones. If the number of incoming high-priority tasks is constantly high enough, no low-priority ones will be ever finished.

Livelock is similar to deadlock as none of the participants make progress. The difference though is that instead of being frozen in a state of waiting for others to progress, the participants continuously change their state. An example scenario when two participants have two identical resources available. They each try to get the resource, but they also check if the other needs the resource, too. If the resource is requested by the other participant, they try to get the other instance of the resource. In the unfortunate case it might happen that the two participants “bounce” between the two resources, never acquiring it, but always yielding to the other.

## 3.2 What is an Actor?

1. Actor Reference
1. State
1. Behavior
1. Mailbox
1. Child Actors
1. Supervisor Strategy
1. When an Actor Terminates

## 3.3 Supervision and Monitoring

### 3.3.1 Supervisor Options

1. Resume the subordinate, keeping its accumulated internal state
1. Restart the subordinate, clearing out its accumulated internal state
1. Stop the subordinate permanently
1. Escalate the failure, thereby failing itself

### 3.3.2 One-For-One Strategy vs All-For-One Strategy

There are two classes of supervision strategies which come with Akka: OneForOneStrategy and AllForOneStrategy. Both are configured with a mapping from exception type to supervision directive (see above) and limits on how often a child is allowed to fail before terminating it. The difference between them is that the former applies the obtained directive only to the failed child, whereas the latter applies it to all siblings as well. Normally, you should use the OneForOneStrategy, which also is the default if none is specified explicitly.

## 3.4 Actor References, Paths and Addresses

![fig3](/images/Akka-Overview/fig3.png)

### 3.4.1 What is an Actor Reference?

There are several different types of actor references that are supported depending on the configuration of the actor system:

1. `Purely local actor references`
    * `"akka://my-sys/user/service-a/worker1"`
1. `Local actor references`
1. `Remote actor references`
    * `"akka.tcp://my-sys@host.example.com:5678/user/service-b"`

### 3.4.2 What is an Actor Path?

Since actors are created in a strictly hierarchical fashion, there exists a unique sequence of actor names given by recursively following the supervision links between child and parent down towards the root of the actor system. This sequence can be seen as enclosing folders in a file system, hence we adopted the name “path” to refer to it, although actor hierarchy has some fundamental difference from file system hierarchy.

An actor path consists of an anchor, which identifies the actor system, followed by the concatenation of the path elements, from root guardian to the designated actor; the path elements are the names of the traversed actors and are separated by slashes.

#### 3.4.2.1 What is the Difference Between Actor Reference and Path?

An actor reference designates a single actor and the life-cycle of the reference matches that actor’s life-cycle; an actor path represents a name which may or may not be inhabited by an actor and the path itself does not have a life-cycle, it never becomes invalid. You can create an actor path without creating an actor, but you cannot create an actor reference without creating corresponding actor.

### 3.4.3 How are Actor References obtained?

1. Creating Actors
    * `ActorSystem.actorOf`
    * `ActorContext.actorOf`
1. Looking up Actors by Concrete Path
    * `ActorSystem.actorSelection`

### 3.4.4 参考

* [Actor References, Paths and Addresses](https://doc.akka.io/docs/akka/current/general/addressing.html)

## 3.5 Configuration

### 3.5.1 参考

* [Listing of the Reference Configuration](https://doc.akka.io/docs/akka/2.5/general/configuration.html)

# 4 Actors

## 4.1 How to user actors

### 4.1.1 参考

* [Actors](https://doc.akka.io/docs/akka/current/actors.html)
