---
title: Spring-IoC-源码剖析
date: 2018-02-13 13:52:34
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

Spring IoC容器是Spring框架中最核心的部分，源码数量庞大，因此，本篇博客仅在一个较为宏观的层面上对Spring IoC的设计架构、初始化流程进行分析。各个细节部分不做深入讨论

# 2 spring-beans

`spring-beans`模块包含了Spring IoC容器最核心最基础的部分，该模块中最核心的接口就是BeanFactory，其继承体系如下

* `BeanFactory`：IoC容器最顶层的接口，定义了getBean等最基础的方法
* `HierarchicalBeanFactory`：扩展了BeanFactory接口，进而提供父子容器的能力
* `AutowireCapableBeanFactory`：扩展了BeanFactory接口，进而提供自动装配（Autowire）的能力
* `ListableBeanFactory`：扩展了BeanFactory接口，进而提供枚举Bean的能力，例如返回所有Bean的__名字__，返回所有指定类型的Bean的__名字__等等
* __可以看到DefaultListableBeanFactory与XmlBeanFactory出现在所有的继承支路中，这说明了DefaultListableBeanFactory是IoC容器的最核心实现__

```
BeanFactory
    |
    ├── HierarchicalBeanFactory
    |       |
    |       ├── ConfigurableBeanFactory
    |       |       |
    |       |       ├── AbstractBeanFactory
    |       |       |       |
    |       |       |       ├── AbstractAutowireCapableBeanFactory
    |       |       |       |       |
    |       |       |       |       ├── DefaultListableBeanFactory
    |       |       |       |       |       |
    |       |       |       |       |       ├── XmlBeanFactory
    |       |       ├── ConfigurableListableBeanFactory
    |       |       |       |
    |       |       |       ├── DefaultListableBeanFactory
    |       |       |       |       |
    |       |       |       |       ├── XmlBeanFactory
    ├── AutowireCapableBeanFactory
    |       |
    |       ├── ConfigurableListableBeanFactory
    |       |       |
    |       |       ├── DefaultListableBeanFactory
    |       |       |       |
    |       |       |       ├── XmlBeanFactory
    |       ├── AbstractAutowireCapableBeanFactory
    |       |       |
    |       |       ├── DefaultListableBeanFactory
    |       |       |       |
    |       |       |       ├── XmlBeanFactory
    ├── ListableBeanFactory
    |       |
    |       ├── StaticListableBeanFactory
    |       ├── ConfigurableListableBeanFactory
    |       |       |
    |       |       ├── DefaultListableBeanFactory
    |       |       |       |
    |       |       |       ├── XmlBeanFactory
```

![fig1](/images/Spring-IoC-Demo/fig1.png)

# 3 spring-context

