---
title: Zookeeper-原理
date: 2017-07-11 23:38:28
tags: 
- 摘录
categories: 
- 分布式
- Zookeeper
---

__阅读更多__

<!--more-->

# 1 前言

ZooKeeper是一个分布式的，开放源码的分布式应用程序协调服务，它包含一个简单的原语集，分布式应用程序可以基于它实现同步服务，配置维护和命名服务等。Zookeeper是hadoop的一个子项目，其发展历程无需赘述。在分布式应用中，由于工程师不能很好地使用锁机制，以及基于消息的协调机制不适合在某些应用中使用，因此需要有一种可靠的、可扩展的、分布式的、可配置的协调机制来统一系统的状态。Zookeeper的目的就在于此。本文简单分析Zookeeper的工作原理，对于如何使用Zookeeper不是本文讨论的重点

# 2 Zookeeper的基本概念

## 2.1 角色

Zookeeper中的角色主要有以下三类，如下表所示：

| 角色 | 描述 |
|:--|:--|
| 领导者(Leader) | 领导者负责进行投票的发起和决议，更新系统状态 |
| 跟随者(Follower) | Follower用于接受客户请求并向客户端返回结果，在选主过程中参与投票 |
| 观察者(Observer) | Observer可以接受客户端连接，将写请求转发给leader节点。但Observer不参加投票过程，只同步leader的状态。Observer的目的是扩展系统，提高读取速度 |
| 客户端(Client) | 请求发起方 |

* 其中跟__随者(Follower)__和__观察者(Observer)__统称为__学习者(Leaner)__

## 2.2 设计目的

__最终一致性__：client不论连接到哪个Server，展示给它都是同一个视图，这是Zookeeper最重要的性能

__可靠性__：具有简单、健壮、良好的性能，如果消息m被到一台服务器接受，那么它将被所有的服务器接受

__实时性__：Zookeeper保证客户端将在一个时间间隔范围内获得服务器的更新信息，或者服务器失效的信息。但由于网络延时等原因，Zookeeper不能保证两个客户端能同时得到刚更新的数据，如果需要最新数据，应该在读数据之前调用sync()接口

__等待无关（wait-free）__：慢的或者失效的client不得干预快速的client的请求，使得每个client都能有效的等待

__原子性__：更新只能成功或者失败，没有中间状态

__顺序性__：包括全局有序和偏序两种：全局有序是指如果在一台服务器上消息a在消息b前发布，则在所有Server上消息a都将在消息b前被发布；偏序是指如果一个消息b在消息a后被同一个发送者发布，a必将排在b前面

# 3 ZooKeeper的工作原理

Zookeeper的核心是__原子广播__，这个机制保证了各个Server之间的同步。实现这个机制的协议叫做Zab协议。Zab协议有两种模式，它们分别是__恢复模式（选主）__和__广播模式（同步）__。当服务启动或者在领导者崩溃后，Zab就进入了恢复模式，当领导者被选举出来，且大多数Server完成了和leader的状态同步以后，恢复模式就结束了。状态同步保证了leader和Server具有相同的系统状态

__为了保证事务的顺序一致性，Zookeeper采用了递增的事务id号（zxid）来标识事务。__所有的提议（proposal）都在被提出的时候加上了zxid。实现中zxid是一个64位的数字，它高32位是epoch用来标识leader关系是否改变，每次一个leader被选出来，它都会有一个新的epoch，标识当前属于那个leader的统治时期。低32位用于递增计数

每个Server在工作过程中有三种状态：

1. LOOKING：当前Server不知道leader是谁，正在搜寻
1. LEADING：当前Server即为选举出来的leader
1. FOLLOWING：leader已经选举出来，当前Server与之同步

## 3.1 选主流程

当leader崩溃或者leader失去大多数的follower，这时候zk进入恢复模式，恢复模式需要重新选举出一个新的leader，让所有的Server都恢复到一个正确的状态。Zk的选举算法有两种：

1. __一种是基于basic paxos实现的__
1. __另外一种是基于fast paxos算法实现的__
* 系统默认的选举算法为fast paxos

先介绍basic paxos流程：

1. 选举线程由当前Server发起选举的线程担任，其主要功能是对投票结果进行统计，并选出推荐的Server
1. 选举线程首先向所有Server发起一次询问(包括自己)
1. 选举线程收到回复后，验证是否是自己发起的询问(验证zxid是否一致)，然后获取对方的id(myid)，并存储到当前询问对象列表中，最后获取对方提议的leader相关信息(id,zxid)，并将这些信息存储到当次选举的投票记录表中
1. 收到所有Server回复以后，就计算出zxid最大的那个Server，并将这个Server相关信息设置成下一次要投票的Server
1. 线程将当前zxid最大的Server设置为当前Server要推荐的Leader，如果此时获胜的Server获得n/2 + 1的Server票数， 设置当前推荐的leader为获胜的Server，将根据获胜的Server相关信息设置自己的状态，否则，继续这个过程，直到leader被选举出来

# 4 参考

* [Zookeeper原理（转）](http://cailin.iteye.com/blog/2014486)
