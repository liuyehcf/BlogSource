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
1. volcano vs pipeline
    * 实现难度
        * `volcano`：实现上更直观，自顶向下一条控制流
        * `pipeline`：不直观，需要将执行树拆分成多个链，多条执行流，且相互之间可能存在依赖关系
    * 并行粒度
        * `volcano`：以`fragment`为单位进行执行，无法进行更细粒度的并行调整
        * `pipeline`：将一个`fragment`以物化算子为拆分点，拆分成多条pipeline，每条pipeline的并行度可以自适应调整
    * `调度`
        * `volcano`：内核态。整个执行，从root算子的视角来看，就一次函数调用，通过`next`方法从孩子节点拉去全量数据。并发查询时，会使用大量线程，线程切换开销较大
        * `pipeline`：用户态。`pipeline`在用户态实现了调度，数据从`source`算子到`sink`算子的一次流转称为一次执行，每次调度可以进行一次或者多次执行。线程数量基本与核数相关，不会随着并发上升而提执行线程数量，线程切换开销较小
            * work stealing
    * `pull vs. push`
        * `volcano`：pull模型，对limit算子友好。`source`算子没有输入的时候，提前结束方法即可，无需额外控制流
        * `pipeline`：push模型，对limit算子不友好。因为需要额外实现短路控制（控制反转），`sink`算子通知`source`算子提前结束
