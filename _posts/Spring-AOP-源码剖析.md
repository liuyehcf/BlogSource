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

当我们定义好增强接口（Advice）以及切点接口（Pointcut）之后，我们需要有一个对象来持有这两者，这个任务就交由Advisor接口来完成

1. `Advisor`：用于持有一个Advice
1. `PointcutAdvisor`：在Advisor的基础上，用于持有一个Pointcut

```
 Advisor 
    |
    ├── PointcutAdvisor
```

Advisor也是Spring AOP新增的接口。__PointcutAdvisor接口关联着一个Advice和一个Pointcut，其中Advice代表着织入的逻辑，Pointcut代表着织入的地点集合__。因此一个Advisor包含了__一个增强逻辑__以及__织入地点的集合__

几个核心扩展接口的定义如下

```Java
public interface Advisor {

	Advice getAdvice();

	// 判断持有的Advice是否关联着一个具体实例，在Spring框架中，总是返回true
	boolean isPerInstance();
}
```

```Java
public interface PointcutAdvisor extends Advisor {

	Pointcut getPointcut();
}
```

### 1.3.5 关联

Advice、Joinpoint、Pointcut、Advisor之间的关系可以用下面这些图表示

* ![fig1](/images/Spring-AOP-源码剖析/fig1.png)
* ![fig2](/images/Spring-AOP-源码剖析/fig2.jpg)
* ![fig3](/images/Spring-AOP-源码剖析/fig3.jpg)

# 2 源码剖析

首先来看一下，Spirng AOP是如何使用的，详细的Demo可以参考{% post_link Spring-AOP-Demo %}

分析使用的Spring源码版本为4.3.13.RELEASE

Spring AOP实现的核心原理就是：__拦截器+动态代理__

## 2.1 与IoC的关联

Spring AOP通常与Spring IOC结合使用，通过BeanPostProcessor接口，以低耦合的方式将Spring AOP整合到Spring IOC容器当中

__在BeanPostProcessor的继承体系中，与Spring AOP相关部分如下__

```
BeanPostProcessor 
    |
    ├── InstantiationAwareBeanPostProcessor
    |       |
    |       ├── SmartInstantiationAwareBeanPostProcessor
    |       |       |
    |       |       ├── AbstractAutoProxyCreator
    |       |       |       |
    |       |       |       ├── BeanNameAutoProxyCreator
    |       |       |       ├── AbstractAdvisorAutoProxyCreator
    |       |       |       |       |
    |       |       |       |       ├── DefaultAdvisorAutoProxyCreator
    |       |       |       |       ├── InfrastructureAdvisorAutoProxyCreator
    |       |       |       |       ├── AspectJAwareAdvisorAutoProxyCreator
    |       |       |       |       |       |
    |       |       |       |       |       ├── AnnotationAwareAspectJAutoProxyCreator
```

因此，我们从AbstractAutowireCapableBeanFactory.applyBeanPostProcessorsAfterInitialization方法开始AOP源码的分析

```Java
	@Override
	public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
			throws BeansException {

		Object result = existingBean;
		for (BeanPostProcessor beanProcessor : getBeanPostProcessors()) {
            // 遍历所有的BeanPostProcessor
			result = beanProcessor.postProcessAfterInitialization(result, beanName);
			if (result == null) {
				return result;
			}
		}
		return result;
	}
```

这里BeanPostProcessor的实现类是AnnotationAwareAspectJAutoProxyCreator，其postProcessAfterInitialization方法逻辑定义在AbstractAdvisorAutoProxyCreator之中

```Java
@Override
	public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
		if (bean != null) {
			Object cacheKey = getCacheKey(bean.getClass(), beanName);
			if (!this.earlyProxyReferences.contains(cacheKey)) {
                // 依据配置，对bean进行增强处理
				return wrapIfNecessary(bean, beanName, cacheKey);
			}
		}
		return bean;
	}
```

wrapIfNecessary方法也定义在AbstractAdvisorAutoProxyCreator之中。该方法用于判断指定Bean是否需要进行增强，为那些需要织入增强逻辑的Bean创建代理

```Java
    protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {
        // 
		if (beanName != null && this.targetSourcedBeans.contains(beanName)) {
			return bean;
		}
        // 该Bean不需要增强
		if (Boolean.FALSE.equals(this.advisedBeans.get(cacheKey))) {
			return bean;
		}
        // 该Bean为基础设施类（例如Advice、Pontcut等等）则不需要增强
		if (isInfrastructureClass(bean.getClass()) || shouldSkip(bean.getClass(), beanName)) {
			this.advisedBeans.put(cacheKey, Boolean.FALSE);
			return bean;
		}

		// 获取与当前Bean相关的拦截器
		Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);

        // 如果拦截器不是空，那么就为当前Bean创建代理
		if (specificInterceptors != DO_NOT_PROXY) {
			this.advisedBeans.put(cacheKey, Boolean.TRUE);
            // 创建代理类
			Object proxy = createProxy(
					bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
			this.proxyTypes.put(cacheKey, proxy.getClass());
			return proxy;
		}

		this.advisedBeans.put(cacheKey, Boolean.FALSE);
		return bean;
	}

```

## 2.2 创建代理

我们继续上面的分析，接下来看createProxy方法，该方法位于AbstractAdvisorAutoProxyCreator之中。该方法用于为指定Bean创建代理

```Java
protected Object createProxy(
			Class<?> beanClass, String beanName, Object[] specificInterceptors, TargetSource targetSource) {

		if (this.beanFactory instanceof ConfigurableListableBeanFactory) {
			AutoProxyUtils.exposeTargetClass((ConfigurableListableBeanFactory) this.beanFactory, beanName, beanClass);
		}

        // 创建一个代理工厂，并为其设置参数
		ProxyFactory proxyFactory = new ProxyFactory();
		proxyFactory.copyFrom(this);

		if (!proxyFactory.isProxyTargetClass()) {
			if (shouldProxyTargetClass(beanClass, beanName)) {
				proxyFactory.setProxyTargetClass(true);
			}
			else {
				evaluateProxyInterfaces(beanClass, proxyFactory);
			}
		}

        // 获取与当前bean相关的所有Advisor
		Advisor[] advisors = buildAdvisors(beanName, specificInterceptors);
		proxyFactory.addAdvisors(advisors);
		proxyFactory.setTargetSource(targetSource);
		customizeProxyFactory(proxyFactory);

		proxyFactory.setFrozen(this.freezeProxy);
		if (advisorsPreFiltered()) {
			proxyFactory.setPreFiltered(true);
		}

        // 用代理工厂，创建代理
		return proxyFactory.getProxy(getProxyClassLoader());
	}
```

其中，buildAdvisors方法用于获取与当前Bean相关的所有Advisor，前面我们介绍过了，一个Advisor（准确地说是PointcutAdvisor）关联着一个Advice以及一个Pointcut

# 3 参考

* [Spring AOP: What's the difference between JoinPoint and PointCut?](https://stackoverflow.com/questions/15447397/spring-aop-whats-the-difference-between-joinpoint-and-pointcut)
* [What is the difference between Advisor and Aspect in AOP?](https://stackoverflow.com/questions/25092302/what-is-the-difference-between-advisor-and-aspect-in-aop)
* [Spring源码分析----AOP概念(Advice,Pointcut,Advisor)和AOP的设计与实现](http://blog.csdn.net/oChangWen/article/details/57428046)
* 《Spring 技术内幕》
