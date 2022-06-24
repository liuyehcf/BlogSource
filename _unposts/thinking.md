---
title: thinking
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Thinking
---

**阅读更多**

<!--more-->

1. 什么是互联网
    * 协助、促进人进行信息交换
    * 产品分类
        * 电商
        * 社交
        * 娱乐
    * 特点
        * 必须有人参与
        * 信息由人产生
        * 信息由人消费
    * 消费品市场，品牌化进程
        * 缩短消费决策的流程
        * 高溢价
        * 白牌产品经常出现在人均GDP 5000美元以下的地区
            * 信任不由产品本身直接提供，而是通过社会关系间接提供（这些品牌的生产者和当地社区是融为一体的，因此是有信任背书的）
        * 品牌化的背后是社会经济结构的变化
            * 消费者在进行消费决策的时候，会从对人和关系的信任模式转变为对品牌的信任
1. pull vs. push
    * 驱动方式
        * `pull`：`demand-driven`
            * next方法是个虚函数，有额外的开销
        * `push`：`data-driven`
            * push也是个虚函数，同样有开销
    * 编程模型
        * `iterator-mode`
        * `visitor-mode`
            * 如果需要区分不同的数据类型的话，可以用`visitor-mode`
            * 如果只需要对抽象的数据类型进行操作的话，就不需要用`visitor-mode`了
    * 控制流
        * `pull`：实现上更直观，自顶向下一条控制流
        * `push`：不直观，需要将执行树拆分成多个链，多条执行流，且相互之间可能存在依赖关系
    * 并行粒度
        * `pull`：以`fragment`为单位进行执行，无法进行更细粒度的并行调整
            * 并行度低：对简单算子友好，对复杂算子不友好
            * 并行度高：对简单算子不友好，对复杂算子友好
        * `push`：将一个`fragment`以物化算子为拆分点，拆分成多条pipeline，每条pipeline的并行度可以自适应调整
            * 简单算子可以降低并行度，减少数据合并的操作
            * 复杂算子可以增加并行度，充分利用多核CPU的优势
    * `调度`
        * `pull`：内核态。整个执行，从root算子的视角来看，就一次函数调用，通过`next`方法从孩子节点拉去全量数据。并发查询时，会使用大量线程，线程切换开销较大
        * `push`：用户态。`pipeline`在用户态实现了调度，数据从`source`算子到`sink`算子的一次流转称为一次执行，每次调度可以进行一次或者多次执行。线程数量基本与核数相关，不会随着并发上升而提执行线程数量，线程切换开销较小
            * work stealing
            * thread affinity, [C++11 threads, affinity and hyperthreading](https://eli.thegreenplace.net/2016/c11-threads-affinity-and-hyperthreading/)
    * `limit`
        * `pull`：
            * 对limit算子友好。`source`算子没有输入的时候，提前结束方法即可，无需额外控制流
        * `push`：对limit算子不友好。因为需要额外实现短路控制（控制反转），`sink`算子通知`source`算子提前结束
    * `filter`：下面的结论基于一些预设的前提（因此，实际可能并非如此）
        * `pull`：对filter算子不友好，
            * 相邻算子的逻辑会被内联成一个大函数，而对于`pull`模型来说，分支更多，分支预测失败的概率大
        * `push`：对filter算子友好
            * 同样，相邻算子的逻辑会被内联成一个大函数，而对于`push`模型来说，分支更少，分支预测失败的概率小
        * [filter](/images/thinking/filter.png)
1. DBMS serverless
    * traditional automated tuning
        * cluster maintenance
        * patching
        * monitoring
        * resize
        * backups
        * encryption
    * automatic table optimizations
1. k8s
    * 容器编排
    * 资源管理、资源调度
    * 运维能力，包括部署、扩缩容、异常恢复
    * 应用生命周期管理
