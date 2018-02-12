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

Advisor也是Spring AOP新增的接口，可以理解为切面（还有的称为通知器，Advice就是通知）。__PointcutAdvisor接口关联着一个Advice和一个Pointcut，其中Advice代表着织入的逻辑，Pointcut代表着织入的地点集合__。因此一个Advisor包含了__一个增强逻辑__以及__织入地点的集合__

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

Spring AOP通常与Spring IoC结合使用，通过BeanPostProcessor接口，以低耦合的方式将Spring AOP整合到Spring IoC容器当中

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
            // 遍历所有的BeanPostProcessor，这里我们只关心与AOP相关的BeanPostProcessor
			result = beanProcessor.postProcessAfterInitialization(result, beanName);
			if (result == null) {
				return result;
			}
		}
		return result;
	}
```

这里BeanPostProcessor的实现类是AnnotationAwareAspectJAutoProxyCreator，其postProcessAfterInitialization方法逻辑定义在AbstractAutoProxyCreator之中

```Java
@Override
	public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
		if (bean != null) {
			Object cacheKey = getCacheKey(bean.getClass(), beanName);
			if (!this.earlyProxyReferences.contains(cacheKey)) {
                // 如果有必要的话，对Bean进行包装（即代理）
				return wrapIfNecessary(bean, beanName, cacheKey);
			}
		}
		return bean;
	}
```

wrapIfNecessary方法也定义在AbstractAutoProxyCreator之中。__该方法用于判断指定Bean是否需要进行增强，为那些需要织入增强逻辑的Bean创建代理__

```Java
    protected Object wrapIfNecessary(Object bean, String beanName, Object cacheKey) {
		if (beanName != null && this.targetSourcedBeans.contains(beanName)) {
			return bean;
		}
		if (Boolean.FALSE.equals(this.advisedBeans.get(cacheKey))) {
			return bean;
		}
		if (isInfrastructureClass(bean.getClass()) || shouldSkip(bean.getClass(), beanName)) {
			this.advisedBeans.put(cacheKey, Boolean.FALSE);
			return bean;
		}

		// 获取Advice或者Advisor
		Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);

		if (specificInterceptors != DO_NOT_PROXY) {
			this.advisedBeans.put(cacheKey, Boolean.TRUE);
            // 为当前Bean创建代理对象
			Object proxy = createProxy(
					bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
			this.proxyTypes.put(cacheKey, proxy.getClass());
			return proxy;
		}

		this.advisedBeans.put(cacheKey, Boolean.FALSE);
		return bean;
	}

```

## Advice/Advisor的获取

在AbstractAutoProxyCreator.wrapIfNecessary方法中调用了getAdvicesAndAdvisorsForBean方法来__获取增强（Advice）或者切面（Advisor）__，该方法是AbstractAutoProxyCreator中的一个抽象方法，具体的实现由子类AbstractAdvisorAutoProxyCreator提供

```Java
	protected Object[] getAdvicesAndAdvisorsForBean(Class<?> beanClass, String beanName, TargetSource targetSource) {
		List<Advisor> advisors = findEligibleAdvisors(beanClass, beanName);
		if (advisors.isEmpty()) {
			return DO_NOT_PROXY;
		}
		return advisors.toArray();
	}
```

继续跟踪findEligibleAdvisors方法，该方法同样位于AbstractAdvisorAutoProxyCreator中，__该方法就是为指定Bean收集所有匹配的Advisor__

```Java
	protected List<Advisor> findEligibleAdvisors(Class<?> beanClass, String beanName) {
		// 获取所有可用于自动代理的Advisor
		List<Advisor> candidateAdvisors = findCandidateAdvisors();
		// 在所有可用于自动代理的Advisor中，筛选出可用于当前Bean的Advisor
		List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);
		extendAdvisors(eligibleAdvisors);
		if (!eligibleAdvisors.isEmpty()) {
			eligibleAdvisors = sortAdvisors(eligibleAdvisors);
		}
		return eligibleAdvisors;
	}
```

其中，findCandidateAdvisors方法用于获取所有的Advisor，该方法定义在AbstractAdvisorAutoProxyCreator中，并且子类
AnnotationAwareAspectJAutoProxyCreator复写了该方法。Spring AOP支持两种配置方式：XML配置，利用`<aop:config>`标签；注解方式，利用`org.aspectj.lang.annotation`包下的相关注解，例如@Aspect、@Before等等。下面给出AnnotationAwareAspectJAutoProxyCreator中的版本

* 通过父类AbstractAdvisorAutoProxyCreator的同名方法获取由Spring XML配置文件定义的Advisor
* 获取由`org.aspectj.lang.annotation`包下的相关AOP注解定义的Advisor

```Java
	@Override
	protected List<Advisor> findCandidateAdvisors() {
		// Add all the Spring advisors found according to superclass rules.
		List<Advisor> advisors = super.findCandidateAdvisors();
		// Build Advisors for all AspectJ aspects in the bean factory.
		advisors.addAll(this.aspectJAdvisorsBuilder.buildAspectJAdvisors());
		return advisors;
	}
```

首先，我们来看下AbstractAdvisorAutoProxyCreator的findCandidateAdvisors方法

```Java
	protected List<Advisor> findCandidateAdvisors() {
		return this.advisorRetrievalHelper.findAdvisorBeans();
	}
```

转交由BeanFactoryAdvisorRetrievalHelper.findAdvisorBeans来实现获取Advisor的逻辑。__该方法的主要逻辑就是从Spring的IoC容器中找出Advisor类型的所有Bean__

```Java
public List<Advisor> findAdvisorBeans() {
		// Determine list of advisor bean names, if not cached already.
		// 获取所有Advisor的Bean的名字
		String[] advisorNames = null;
		synchronized (this) {
			advisorNames = this.cachedAdvisorBeanNames;
			if (advisorNames == null) {
				// Do not initialize FactoryBeans here: We need to leave all regular beans
				// uninitialized to let the auto-proxy creator apply to them!
				advisorNames = BeanFactoryUtils.beanNamesForTypeIncludingAncestors(
						this.beanFactory, Advisor.class, true, false);
				this.cachedAdvisorBeanNames = advisorNames;
			}
		}
		if (advisorNames.length == 0) {
			return new LinkedList<Advisor>();
		}

		List<Advisor> advisors = new LinkedList<Advisor>();
		// 遍历每个Advisor的名字
		for (String name : advisorNames) {
			if (isEligibleBean(name)) {
				if (this.beanFactory.isCurrentlyInCreation(name)) {
					if (logger.isDebugEnabled()) {
						logger.debug("Skipping currently created advisor '" + name + "'");
					}
				}
				else {
					try {
						// 取出对应的Bean，添加到列表中
						advisors.add(this.beanFactory.getBean(name, Advisor.class));
					}
					catch (BeanCreationException ex) {
						Throwable rootCause = ex.getMostSpecificCause();
						if (rootCause instanceof BeanCurrentlyInCreationException) {
							BeanCreationException bce = (BeanCreationException) rootCause;
							if (this.beanFactory.isCurrentlyInCreation(bce.getBeanName())) {
								if (logger.isDebugEnabled()) {
									logger.debug("Skipping advisor '" + name +
											"' with dependency on currently created bean: " + ex.getMessage());
								}
								// Ignore: indicates a reference back to the bean we're trying to advise.
								// We want to find advisors other than the currently created bean itself.
								continue;
							}
						}
						throw ex;
					}
				}
			}
		}
		return advisors;
	}
```

接着，我们回到AnnotationAwareAspectJAutoProxyCreator的findCandidateAdvisors方法中，看一下buildAspectJAdvisors方法的具体逻辑，该方法定义在BeanFactoryAspectJAdvisorsBuilder之中。__该方法的主要逻辑是：针对每一个用@Aspect注解标记的类，遍历其所有标记了注解（包括@Before、@After等）的方法，将每个方法封装成一个Advice，然后再封装成Advisor__

```Java
	public List<Advisor> buildAspectJAdvisors() {
		// 获取所有标记了@Aspect注解的Bean的名字
		List<String> aspectNames = this.aspectBeanNames;

		// 下面这个if子句用于初始化this.aspectBeanNames
		if (aspectNames == null) {
			synchronized (this) {
				aspectNames = this.aspectBeanNames;
				if (aspectNames == null) {
					List<Advisor> advisors = new LinkedList<Advisor>();
					aspectNames = new LinkedList<String>();
					// 获取所有Bean的名字
					String[] beanNames = BeanFactoryUtils.beanNamesForTypeIncludingAncestors(
							this.beanFactory, Object.class, true, false);
					// 遍历这些Bean的名字
					for (String beanName : beanNames) {
						if (!isEligibleBean(beanName)) {
							continue;
						}
						// We must be careful not to instantiate beans eagerly as in this case they
						// would be cached by the Spring container but would not have been weaved.
						Class<?> beanType = this.beanFactory.getType(beanName);
						if (beanType == null) {
							continue;
						}

						// 这里检验这个类型是否被@Aspect注解标记，或者用Aspect编译器编译过。总是就是检查是否与Aspect相关
						if (this.advisorFactory.isAspect(beanType)) {
							aspectNames.add(beanName);
							AspectMetadata amd = new AspectMetadata(beanType, beanName);
							if (amd.getAjType().getPerClause().getKind() == PerClauseKind.SINGLETON) {
								MetadataAwareAspectInstanceFactory factory =
										new BeanFactoryAspectInstanceFactory(this.beanFactory, beanName);
								List<Advisor> classAdvisors = this.advisorFactory.getAdvisors(factory);
								if (this.beanFactory.isSingleton(beanName)) {
									this.advisorsCache.put(beanName, classAdvisors);
								}
								else {
									this.aspectFactoryCache.put(beanName, factory);
								}
								advisors.addAll(classAdvisors);
							}
							else {
								// Per target or per this.
								if (this.beanFactory.isSingleton(beanName)) {
									throw new IllegalArgumentException("Bean with name '" + beanName +
											"' is a singleton, but aspect instantiation model is not singleton");
								}
								MetadataAwareAspectInstanceFactory factory =
										new PrototypeAspectInstanceFactory(this.beanFactory, beanName);
								this.aspectFactoryCache.put(beanName, factory);
								advisors.addAll(this.advisorFactory.getAdvisors(factory));
							}
						}
					}
					this.aspectBeanNames = aspectNames;
					return advisors;
				}
			}
		}

		// 到这，说明已经初始化过一次了，直接从缓存中拿即可
		if (aspectNames.isEmpty()) {
			return Collections.emptyList();
		}
		List<Advisor> advisors = new LinkedList<Advisor>();
		for (String aspectName : aspectNames) {
			List<Advisor> cachedAdvisors = this.advisorsCache.get(aspectName);
			if (cachedAdvisors != null) {
				advisors.addAll(cachedAdvisors);
			}
			else {
				MetadataAwareAspectInstanceFactory factory = this.aspectFactoryCache.get(aspectName);
				advisors.addAll(this.advisorFactory.getAdvisors(factory));
			}
		}
		return advisors;
	}
```

接着，回到AbstractAdvisorAutoProxyCreator的findEligibleAdvisors方法中，继续分析findAdvisorsThatCanApply方法。__该方法用于在给定的Advisor集合中，筛选出匹配指定Bean的Advisor__

```Java
	protected List<Advisor> findAdvisorsThatCanApply(
			List<Advisor> candidateAdvisors, Class<?> beanClass, String beanName) {

		ProxyCreationContext.setCurrentProxiedBeanName(beanName);
		try {
			return AopUtils.findAdvisorsThatCanApply(candidateAdvisors, beanClass);
		}
		finally {
			ProxyCreationContext.setCurrentProxiedBeanName(null);
		}
	}
```

具体的逻辑由AopUtils的同名方法实现

```Java
	public static List<Advisor> findAdvisorsThatCanApply(List<Advisor> candidateAdvisors, Class<?> clazz) {
		if (candidateAdvisors.isEmpty()) {
			return candidateAdvisors;
		}
		List<Advisor> eligibleAdvisors = new LinkedList<Advisor>();
		for (Advisor candidate : candidateAdvisors) {
			if (candidate instanceof IntroductionAdvisor && canApply(candidate, clazz)) {
				eligibleAdvisors.add(candidate);
			}
		}
		boolean hasIntroductions = !eligibleAdvisors.isEmpty();
		for (Advisor candidate : candidateAdvisors) {
			if (candidate instanceof IntroductionAdvisor) {
				// already processed
				continue;
			}
			if (canApply(candidate, clazz, hasIntroductions)) {
				eligibleAdvisors.add(candidate);
			}
		}
		return eligibleAdvisors;
	}
```

## 2.2 创建代理

回到AbstractAutoProxyCreator的wrapIfNecessary方法中继续分析，接下来看createProxy方法，该方法位于AbstractAutoProxyCreator之中。该方法用于为指定Bean创建代理

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

        // 处理由前面获取到的Advisor
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

AbstractAutoProxyCreator.buildAdvisors方法用于将Advice封装成Advisor（由于之前获取到的specificInterceptors本身就是Advisor，因此，在我们分析的链路来看，该方法不起什么作用），__例如将MethodBeforeAdvice、AfterReturningAdvice之类的接口转换成标准的方法拦截器接口MethodInterceptor__

```Java
	protected Advisor[] buildAdvisors(String beanName, Object[] specificInterceptors) {
		// Handle prototypes correctly...
		Advisor[] commonInterceptors = resolveInterceptorNames();

		List<Object> allInterceptors = new ArrayList<Object>();
		if (specificInterceptors != null) {
			allInterceptors.addAll(Arrays.asList(specificInterceptors));
			if (commonInterceptors.length > 0) {
				if (this.applyCommonInterceptorsFirst) {
					allInterceptors.addAll(0, Arrays.asList(commonInterceptors));
				}
				else {
					allInterceptors.addAll(Arrays.asList(commonInterceptors));
				}
			}
		}
		if (logger.isDebugEnabled()) {
			int nrOfCommonInterceptors = commonInterceptors.length;
			int nrOfSpecificInterceptors = (specificInterceptors != null ? specificInterceptors.length : 0);
			logger.debug("Creating implicit proxy for bean '" + beanName + "' with " + nrOfCommonInterceptors +
					" common interceptors and " + nrOfSpecificInterceptors + " specific interceptors");
		}

		Advisor[] advisors = new Advisor[allInterceptors.size()];
		for (int i = 0; i < allInterceptors.size(); i++) {
			// 这里是封装的核心
			advisors[i] = this.advisorAdapterRegistry.wrap(allInterceptors.get(i));
		}
		return advisors;
	}
```

我们继续看wrap方法，该方法定义在DefaultAdvisorAdapterRegistry中。该方法用于将Advice类型的对象封装成一个Advisor，__在封装的过程中，会用到一系列适配器（Adapter），例如MethodBeforeAdviceAdapter、ThrowsAdviceAdapter、AfterReturningAdviceAdapter，这些适配器的作用就是将MethodBeforeAdvice、AfterReturningAdvice之类的接口转换成标准的方法拦截器接口MethodInterceptor__

```Java
	// 可以看到DefaultAdvisorAdapterRegistry默认注册了三个适配器
	public DefaultAdvisorAdapterRegistry() {
		registerAdvisorAdapter(new MethodBeforeAdviceAdapter());
		registerAdvisorAdapter(new AfterReturningAdviceAdapter());
		registerAdvisorAdapter(new ThrowsAdviceAdapter());
	}

	public Advisor wrap(Object adviceObject) throws UnknownAdviceTypeException {
		// 如果本身就是Advisor那么直接返回即可
		if (adviceObject instanceof Advisor) {
			return (Advisor) adviceObject;
		}
		if (!(adviceObject instanceof Advice)) {
			throw new UnknownAdviceTypeException(adviceObject);
		}
		Advice advice = (Advice) adviceObject;
		if (advice instanceof MethodInterceptor) {
			// So well-known it doesn't even need an adapter.
			return new DefaultPointcutAdvisor(advice);
		}
		for (AdvisorAdapter adapter : this.adapters) {
			// Check that it is supported.
			// 查看该Advice是否被现有的Adpater支持
			if (adapter.supportsAdvice(advice)) {
				// 封装成Advisor
				return new DefaultPointcutAdvisor(advice);
			}
		}
		throw new UnknownAdviceTypeException(advice);
	}
```

# 3 参考

* [Spring AOP: What's the difference between JoinPoint and PointCut?](https://stackoverflow.com/questions/15447397/spring-aop-whats-the-difference-between-joinpoint-and-pointcut)
* [What is the difference between Advisor and Aspect in AOP?](https://stackoverflow.com/questions/25092302/what-is-the-difference-between-advisor-and-aspect-in-aop)
* [Spring源码分析----AOP概念(Advice,Pointcut,Advisor)和AOP的设计与实现](http://blog.csdn.net/oChangWen/article/details/57428046)
* 《Spring 技术内幕》
