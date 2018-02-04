---
title: Spring-AOP-源码剖析
date: 2017-07-10 18:47:23
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

# 1 AOP基本概念

AOP是Aspect-Oriented Pogramming（面向切面编程）的简称

## 1.1 模块化

初学编程时喜欢把所有代码写进一个main函数里，这种编码方式造成了一个很不好的结果：程序维护性很差

于是，开始用子函数来对程序进行模块划分，并对一些基本的功能进行封装

后来，为了让代码维护更方便，又把不同的子函数的实现放到了不同的文件中。这样更方便了，不仅不用再一长串的代码文件里查找和维护，还可以让不同的开发人员并行开发和维护，大大提高开发效率

面向对象设计其实也是一种模块化的方法，它把相关的数据及其处理方法放在了一起。与单纯使用子函数进行封装相比，面向对象的模块化特性更完备，它体现了计算的一个基本原则---让计算尽可能靠近数据。一个类基本就是一个基本的模块。利用继承关系使得类得到重用，提高开发效率

但是程序中总会出现一些重复代码，而且不太方便使用继承的方法把他们重用和管理起来。它们功能重复并且需要用在不同的地方，虽然可以对这些代码左一些简单的封装，使之成为公共函数，但是在这种显式调用中，使用它们不是很方便

在使用这些公共函数的时候，往往也需要进行一些逻辑设计，也就是需要代码实现来支持，而且这些逻辑代码也是需要维护的

使用AOP后，可以将这些重复的代码抽取出来单独维护，在需要使用时统一调用，还可以为如何使用这些公共代码提供丰富灵活的手段

## 1.2 AOP Alliance

__AOP联盟定义了两个重要的基本概念__

1. `Advice`：__增强，代表要织入的逻辑__
1. `Joinpoint`：__织入点，增强逻辑的织入地点__

接下来我们看一下，AOP联盟是如何定义这两个基本概念的

### 1.2.1 Advice

Advice接口的继承体系如下：

1. `Advice`：标记接口，这个接口代表一个增强，__即要执行的动作__
1. `Interceptor`：标记接口，这个接口代表一个通用的拦截器。__Interceptor是Advice的一种具体的语义__
1. `MethodInterceptor`：方法拦截器，__MethodInterceptor是Interceptor的一种具体语义__
1. `ConstructorInterceptor`：构造器拦截器，__ConstructorInterceptor是Interceptor的一种具体语义__

```
 Advice
    |
    ├── Interceptor
    |       |
    |       ├── MethodInterceptor
    |       ├── ConstructorInterceptor
```

各个接口详细定义如下

```Java
public interface Advice {

}
```

```Java
public interface Interceptor extends Advice {

}
```

```Java
public interface MethodInterceptor extends Interceptor {
	
	Object invoke(MethodInvocation invocation) throws Throwable;

}
```

```Java
public interface ConstructorInterceptor extends Interceptor  {

	Object construct(ConstructorInvocation invocation) throws Throwable;

}
```

### 1.2.2 Joinpoint

Joinpoint接口的继承体系如下：

1. `Joinpoint`：织入点，这个接口代表了运行时的`通用`织入点（可以是代码中的任何地方）
1. `Invocation`：调用织入点，这个接口代表了程序中的`调用`织入点，__Invocation是Joinpoint的一种具体语义__
1. `MethodInvocation`：方法调用织入点，这个接口代表了程序中的`方法调用`织入点，__MethodInvocation是Invocation的一种具体语义__

```
 Joinpoint
    |
    ├── Invocation
    |       |
    |       ├── MethodInvocation
    |       ├── ConstructorInvocation
```

各个接口详细定义如下

```Java
public interface Joinpoint {

	Object proceed() throws Throwable;

	Object getThis();

	AccessibleObject getStaticPart();

}
```

```Java
public interface Invocation extends Joinpoint {

	Object[] getArguments();

}
```

```Java
public interface MethodInvocation extends Invocation {

	Method getMethod();

}

```

```Java
public interface ConstructorInvocation extends Invocation {

    Constructor<?> getConstructor();

}
```

## 1.3 Spring AOP

Spring AOP并不是自立门户，而是在AOP联盟定义的一系列接口上进行粒度更细的划分

### 1.3.1 Advice

Spring对于Advice接口的继承体系进行了扩展，扩展后的继承体系如下（由于Spring定义的接口众多，这里仅列出几个比较核心的扩展接口）：

1. `BeforeAdvice`：标记接口，代表前置增强逻辑
1. `AfterAdvice`：标记接口，代表后置增强逻辑
1. `MethodBeforeAdvice`：方法前置增强，__MethodBeforeAdvice是BeforeAdvice的一种具体语义__
1. `AfterReturningAdvice`：方法后置增强，__AfterReturningAdvice是AfterAdvice的一种具体语义__
1. `ThrowsAdvice`：异常增强，__ThrowsAdvice是AfterAdvice的一种具体语义__

```
 Advice (AOP Alliance)
    |
    ├── Interceptor (AOP Alliance)
    |       |
    |       ├── MethodInterceptor (AOP Alliance)
    |       ├── ConstructorInterceptor (AOP Alliance)
    |
    ├── BeforeAdvice (Spring AOP)
    |       |
    |       ├── MethodBeforeAdvice (Spring AOP)
    |
    ├── AfterAdvice (Spring AOP)
    |       |
    |       ├── ThrowsAdvice (Spring AOP)
    |       ├── AfterReturningAdvice (Spring AOP)
  
```

几个核心扩展接口的定义如下

```Java
public interface BeforeAdvice extends Advice {

}
```

```Java
public interface MethodBeforeAdvice extends BeforeAdvice {

	void before(Method method, Object[] args, Object target) throws Throwable;

}
```

```Java
public interface AfterAdvice extends Advice {

}
```

```Java
public interface ThrowsAdvice extends AfterAdvice {

}
```

```Java
public interface AfterReturningAdvice extends AfterAdvice {

	void afterReturning(Object returnValue, Method method, Object[] args, Object target) throws Throwable;

}
```

### 1.3.2 Joinpoint

Spring AOP没有扩展Joinpoint接口

### 1.3.3 Pointcut

Pointcut是Spring AOP新增的接口，__该接口定义了Joinpoint的匹配规则，即一个Pointcut关联着一组Joinpoint__

接口定义如下

```Java
public interface Pointcut {

	ClassFilter getClassFilter();

	MethodMatcher getMethodMatcher();

	Pointcut TRUE = TruePointcut.INSTANCE;

}
```

### 1.3.4 Advisor

Advisor也是Spring AOP新增的接口，称为切面。__该接口关联着一个Advice和一个Pointcut，其中Advice代表着织入的逻辑，Pointcut代表着织入的地点集合__。因此一个Advisor包含了__一个增强逻辑__以及__织入地点的集合__

### 1.3.5 关联

Advice、Joinpoint、Pointcut、Advisor之间的关系可以用下面这些图表示

* ![fig1](/images/Spring-AOP-源码剖析/fig1.png)
* ![fig2](/images/Spring-AOP-源码剖析/fig2.jpg)
* ![fig3](/images/Spring-AOP-源码剖析/fig3.jpg)

# 2 源码剖析

首先来看一下，Spirng AOP是如何使用的，详细的Demo可以参考{% post_link Spring-AOP-Demo %}

# 3 参考

* [Spring AOP: What's the difference between JoinPoint and PointCut?](https://stackoverflow.com/questions/15447397/spring-aop-whats-the-difference-between-joinpoint-and-pointcut)
* [What is the difference between Advisor and Aspect in AOP?](https://stackoverflow.com/questions/25092302/what-is-the-difference-between-advisor-and-aspect-in-aop)
