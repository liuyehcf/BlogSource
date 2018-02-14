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
* `ListableBeanFactory`：扩展了BeanFactory接口，进而提供枚举Bean的能力（或者说提供Bean集合相关的能力），例如返回所有Bean的__名字__，返回所有指定类型的Bean的__名字__等等
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

`spring-context`模块在`spring-beans`模块之上提供了如下功能（关于Spring各模块的综述可以参考{% post_link Spring-Overview %}）

1. 国际化的支持
1. 事件传播
1. 资源加载
1. 上下文透明创建

__ApplicationContext接口是整个`spring-context`模块的核心__，该接口的继承结构如下

![fig2](/images/Spring-IoC-Demo/fig2.png)

从ApplicationContext接口的继承链路中，我们可以清晰地看出ApplicationContext集成的能力

1. `MessageSource`：提供消息解析的能力，并支持消息的国际化
1. `ListableBeanFactory`：上面分析过，提供Bean集合操作的能力（枚举Bean的能力）
1. `HierarchicalBeanFactory`：上面分析过，提供父子容器的能力
1. `ApplicationEventPublisher`：提供发布事件的能力
1. `ResourcePatternResolver`：提供模式化解析本地资源的能力
1. `EnvironmentCapable`：提供持有和暴露一个环境实例的能力

以ApplicationContext为起点的继承链路如下

```
ApplicationContext
        |
        ├── ConfigurableApplicationContext
        |       |
        |       ├── AbstractApplicationContext
        |       |       |
        |       |       ├── AbstractRefreshableApplicationContext
        |       |       |       |
        |       |       |       ├── AbstractRefreshableConfigApplicationContext
        |       |       |       |       |
        |       |       |       |       ├── AbstractXmlApplicationContext
        |       |       |       |       |       |
        |       |       |       |       |       ├── FileSystemXmlApplicationContext
        |       |       |       |       |       ├── ClassPathXmlApplicationContext
```

以ClassPathXmlApplicationContext为例，下面是它的继承结构。

![fig3](/images/Spring-IoC-Demo/fig3.png)

我们重点分析一下几个节点

1. `ApplicationContext`：众多接口的集成者，包括BeanFactory体系、ResourceLoader体系等。还包括事件发布，消息解析，持有环境实例等能力
1. `AbstractApplicationContext`：__该抽象类实现了ApplicationContext接口包含的大部分方法__。并且定义了如下几个抽象方法，交由子类实现
    * `refreshBeanFactory`
    * `closeBeanFactory`
    * `getBeanFactory`
1. `AbstractRefreshableApplicationContext`：在AbstractApplicationContext的基础之上，增加refresh的能力（实现AbstractApplicationContext提供的几个抽象方法）（每次refresh都会生成一个新的BeanFactory）。并定义了如下抽象方法
    * `loadBeanDefinitions`
1. `AbstractRefreshableConfigApplicationContext`：在AbstractRefreshableApplicationContext的基础之上，增加持有配置文件的能力（`private String[] configLocations;`字段）
1. `AbstractXmlApplicationContext`：该抽象类指明了配置文件的类型是XML，实现了AbstractRefreshableApplicationContext提供的抽象方法（loadBeanDefinitions），即加载配置文件
1. `FileSystemXmlApplicationContext`与`ClassPathXmlApplicationContext`：这两个类是应用中会用到的两个类，分别代表XML路径的不同模式

那么`spring-context`模块与`spring-beans`模块是如何联系到一起的呢？从ClassPathXmlApplicationContext的继承链路来看，并没有用到__`spring-beans`模块中核心的BeanFactory引擎类`DefaultListableBeanFactory`__。其实，在AbstractApplicationContext的实现中，由于__该类提供了一个抽象方法`getBeanFactory`__，于是__所有的BeanFactory体系相关的接口方法的实现都是通过该方法来获取BeanFactory，并委托给getBeanFactory方法返回的实例来实现的__。而getBeanFactory方法的定义在AbstractRefreshableApplicationContext中，也是该类持有了一个BeanFactory字段`private DefaultListableBeanFactory beanFactory`

```Java
    // ---------------------------------------------------------------------
	// Implementation of BeanFactory interface
	// ---------------------------------------------------------------------

	@Override
	public Object getBean(String name) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBean(name);
	}

	@Override
	public <T> T getBean(String name, Class<T> requiredType) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBean(name, requiredType);
	}

	@Override
	public <T> T getBean(Class<T> requiredType) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBean(requiredType);
	}

	@Override
	public Object getBean(String name, Object... args) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBean(name, args);
	}

	@Override
	public <T> T getBean(Class<T> requiredType, Object... args) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBean(requiredType, args);
	}

	@Override
	public boolean containsBean(String name) {
		return getBeanFactory().containsBean(name);
	}

	@Override
	public boolean isSingleton(String name) throws NoSuchBeanDefinitionException {
		assertBeanFactoryActive();
		return getBeanFactory().isSingleton(name);
	}

	@Override
	public boolean isPrototype(String name) throws NoSuchBeanDefinitionException {
		assertBeanFactoryActive();
		return getBeanFactory().isPrototype(name);
	}

	@Override
	public boolean isTypeMatch(String name, ResolvableType typeToMatch) throws NoSuchBeanDefinitionException {
		assertBeanFactoryActive();
		return getBeanFactory().isTypeMatch(name, typeToMatch);
	}

	@Override
	public boolean isTypeMatch(String name, Class<?> typeToMatch) throws NoSuchBeanDefinitionException {
		assertBeanFactoryActive();
		return getBeanFactory().isTypeMatch(name, typeToMatch);
	}

	@Override
	public Class<?> getType(String name) throws NoSuchBeanDefinitionException {
		assertBeanFactoryActive();
		return getBeanFactory().getType(name);
	}

	@Override
	public String[] getAliases(String name) {
		return getBeanFactory().getAliases(name);
	}

	// ---------------------------------------------------------------------
	// Implementation of ListableBeanFactory interface
	// ---------------------------------------------------------------------

	@Override
	public boolean containsBeanDefinition(String beanName) {
		return getBeanFactory().containsBeanDefinition(beanName);
	}

	@Override
	public int getBeanDefinitionCount() {
		return getBeanFactory().getBeanDefinitionCount();
	}

	@Override
	public String[] getBeanDefinitionNames() {
		return getBeanFactory().getBeanDefinitionNames();
	}

	@Override
	public String[] getBeanNamesForType(ResolvableType type) {
		assertBeanFactoryActive();
		return getBeanFactory().getBeanNamesForType(type);
	}

	@Override
	public String[] getBeanNamesForType(Class<?> type) {
		assertBeanFactoryActive();
		return getBeanFactory().getBeanNamesForType(type);
	}

	@Override
	public String[] getBeanNamesForType(Class<?> type, boolean includeNonSingletons, boolean allowEagerInit) {
		assertBeanFactoryActive();
		return getBeanFactory().getBeanNamesForType(type, includeNonSingletons, allowEagerInit);
	}

	@Override
	public <T> Map<String, T> getBeansOfType(Class<T> type) throws BeansException {
		assertBeanFactoryActive();
		return getBeanFactory().getBeansOfType(type);
	}

	@Override
	public <T> Map<String, T> getBeansOfType(Class<T> type, boolean includeNonSingletons, boolean allowEagerInit)
			throws BeansException {

		assertBeanFactoryActive();
		return getBeanFactory().getBeansOfType(type, includeNonSingletons, allowEagerInit);
	}

	@Override
	public String[] getBeanNamesForAnnotation(Class<? extends Annotation> annotationType) {
		assertBeanFactoryActive();
		return getBeanFactory().getBeanNamesForAnnotation(annotationType);
	}

	@Override
	public Map<String, Object> getBeansWithAnnotation(Class<? extends Annotation> annotationType)
			throws BeansException {

		assertBeanFactoryActive();
		return getBeanFactory().getBeansWithAnnotation(annotationType);
	}

	@Override
	public <A extends Annotation> A findAnnotationOnBean(String beanName, Class<A> annotationType)
			throws NoSuchBeanDefinitionException{

		assertBeanFactoryActive();
		return getBeanFactory().findAnnotationOnBean(beanName, annotationType);
	}

	// ---------------------------------------------------------------------
	// Implementation of HierarchicalBeanFactory interface
	// ---------------------------------------------------------------------

	@Override
	public BeanFactory getParentBeanFactory() {
		return getParent();
	}

	@Override
	public boolean containsLocalBean(String name) {
		return getBeanFactory().containsLocalBean(name);
	}

	/**
	 * Return the internal bean factory of the parent context if it implements
	 * ConfigurableApplicationContext; else, return the parent context itself.
	 * @see org.springframework.context.ConfigurableApplicationContext#getBeanFactory
	 */
	protected BeanFactory getInternalParentBeanFactory() {
		return (getParent() instanceof ConfigurableApplicationContext) ?
				((ConfigurableApplicationContext) getParent()).getBeanFactory() : getParent();
	}
```

# 4 IoC容器启动过程综述

我们以ClassPathXmlApplicationContext为起点，进行分析。先给出整个初始化流程的时序图

```sequence
participant ClassPathXmlApplicationContext
participant AbstractXmlApplicationContext
participant AbstractRefreshableConfigApplicationContext
participant AbstractRefreshableApplicationContext
participant AbstractApplicationContext

ClassPathXmlApplicationContext->AbstractXmlApplicationContext: construct
AbstractXmlApplicationContext->AbstractRefreshableConfigApplicationContext: construct
AbstractRefreshableConfigApplicationContext->AbstractRefreshableApplicationContext: construct
AbstractRefreshableApplicationContext->AbstractApplicationContext: construct
AbstractApplicationContext-->AbstractRefreshableApplicationContext: construct complete
AbstractRefreshableApplicationContext-->AbstractRefreshableConfigApplicationContext: construct complete
AbstractRefreshableConfigApplicationContext-->AbstractXmlApplicationContext: construct complete
AbstractXmlApplicationContext-->ClassPathXmlApplicationContext: construct complete
ClassPathXmlApplicationContext->ClassPathXmlApplicationContext: setConfigLocations
ClassPathXmlApplicationContext->AbstractApplicationContext: refresh
AbstractApplicationContext->AbstractApplicationContext: prepareRefresh
AbstractApplicationContext->AbstractApplicationContext: obtainFreshBeanFactory
AbstractApplicationContext->AbstractApplicationContext: prepareBeanFactory
AbstractApplicationContext->AbstractApplicationContext: postProcessBeanFactory
AbstractApplicationContext->AbstractApplicationContext: invokeBeanFactoryPostProcessors
AbstractApplicationContext->AbstractApplicationContext: registerBeanPostProcessors
AbstractApplicationContext->AbstractApplicationContext: initMessageSource
AbstractApplicationContext->AbstractApplicationContext: initApplicationEventMulticaster
AbstractApplicationContext->AbstractApplicationContext: onRefresh
AbstractApplicationContext->AbstractApplicationContext: registerListeners
AbstractApplicationContext->AbstractApplicationContext: finishBeanFactoryInitialization
AbstractApplicationContext->AbstractApplicationContext: finishRefresh
AbstractApplicationContext->AbstractApplicationContext: resetCommonCaches
AbstractApplicationContext->ClassPathXmlApplicationContext: refresh complete
```

```flow
```

