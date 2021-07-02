---
title: Raft协议
date: 2021-06-29 14:21:15
tags: 
- 摘录
categories: 
- Distributed
- Protocol
---

**阅读更多**

<!--more-->

# 1 介绍

**相比于其他一致性算法，`raft`在以下几个方面有差异**

1. **`Leader职责`**：强化了leader的职责。例如，只允许单向同步日志（`leader->follow`）。这有利于降低日志复制的复杂度以及更易于理解
1. **`Leader选举`**：`raft`算法使用一个随机的计时器来辅助选举过程，避免出现投票分散的情况而导致无法选出leader。并且这只是在已有的心跳机制上稍作改动，便可达到一个不错的效果
1. **`Membership变更`**：`raft`通过一系列的约束来保证，在成员关系发生变更时，`leader`无需采取特殊处理过程即可保证日志的最终一致性

**`paxos`有哪些缺陷**

1. `paxos`算法本身比较难理解，即便以单决策作为基础（相比于`multi-paxos`），仍然较难理解
1. `paxos`没有为工程化提供良好的基础，并且，针对多决策系统，目前并未出现一个受到广泛认可的算法，`multi-paxos`对很多细节避而不谈，但正是这些晦涩的细节问题阻碍了工程化的实现
1. `paxos`算法的结构是脱离实际业务的，一般来说，分布式系统是为了解决数据同步的问题（一般来说，这里的数据都是日志）。在算法之外再设计其他机制来保证数据同步的一致性，无疑会大大增加系统复杂度

# 2 参考

* [raft协议论文](https://ramcloud.atlassian.net/wiki/download/attachments/6586375/raft.pdf)
* [raft协议论文翻译](https://github.com/maemual/raft-zh_cn/blob/master/raft-zh_cn.md)
* [raft算法与paxos算法相比有什么优势，使用场景有什么差异？](https://www.zhihu.com/question/36648084)
* [比较Raft和Paxos](https://zhuanlan.zhihu.com/p/365284343)
