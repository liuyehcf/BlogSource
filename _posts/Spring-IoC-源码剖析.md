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

__阅读更多__

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

以ClassPathXmlApplicationContext为例，下面是它的继承结构

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
    //---------------------------------------------------------------------
    //Implementation of BeanFactory interface
    //---------------------------------------------------------------------

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

    //---------------------------------------------------------------------
    //Implementation of ListableBeanFactory interface
    //---------------------------------------------------------------------

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

    //---------------------------------------------------------------------
    //Implementation of HierarchicalBeanFactory interface
    //---------------------------------------------------------------------

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

```plantuml
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
AbstractApplicationContext-->ClassPathXmlApplicationContext: refresh complete
```

## 4.1 prepareRefresh

prepareRefresh方法用于__准备IoC容器初始化过程的上下文环境__：包括设置初始化日期、设置状态标志位、进行属性源（PropertySource）的初始化操作

```Java
    protected void prepareRefresh() {
        this.startupDate = System.currentTimeMillis();
        this.closed.set(false);
        this.active.set(true);

        if (logger.isInfoEnabled()) {
            logger.info("Refreshing " + this);
        }

        //Initialize any placeholder property sources in the context environment
        initPropertySources();

        //Validate that all properties marked as required are resolvable
        //see ConfigurablePropertyResolver#setRequiredProperties
        getEnvironment().validateRequiredProperties();

        //Allow for the collection of early ApplicationEvents,
        //to be published once the multicaster is available...
        this.earlyApplicationEvents = new LinkedHashSet<ApplicationEvent>();
    }
```

## 4.2 obtainFreshBeanFactory

obtainFreshBeanFactory方法用于__创建一个新的BeanFactory__

```Java
    protected ConfigurableListableBeanFactory obtainFreshBeanFactory() {
        refreshBeanFactory();
        ConfigurableListableBeanFactory beanFactory = getBeanFactory();
        if (logger.isDebugEnabled()) {
            logger.debug("Bean factory for " + getDisplayName() + ": " + beanFactory);
        }
        return beanFactory;
    }
```

refreshBeanFactory的实现由AbstractRefreshableApplicationContext提供，其主要逻辑如下

1. 如果已存在一个BeanFactory，那么首先销毁这个BeanFactory
1. 创建一个新的BeanFactory，从XML配置文件加载Bean的定义

```Java
    protected final void refreshBeanFactory() throws BeansException {
        //销毁原有的BeanFactory
        if (hasBeanFactory()) {
            destroyBeans();
            closeBeanFactory();
        }
        try {
            //创建新的BeanFactory
            DefaultListableBeanFactory beanFactory = createBeanFactory();
            beanFactory.setSerializationId(getId());
            customizeBeanFactory(beanFactory);
            //从XML配置文件加载Bean定义
            loadBeanDefinitions(beanFactory);
            synchronized (this.beanFactoryMonitor) {
                this.beanFactory = beanFactory;
            }
        }
        catch (IOException ex) {
            throw new ApplicationContextException("I/O error parsing bean definition source for " + getDisplayName(), ex);
        }
    }
```

## 4.3 prepareBeanFactory

prepareBeanFactory方法用于__为BeanFactory配置一些标准上下文属性，包括类加载器、后处理器等等__

```Java
    protected void prepareBeanFactory(ConfigurableListableBeanFactory beanFactory) {
        //Tell the internal bean factory to use the context's class loader etc.
        beanFactory.setBeanClassLoader(getClassLoader());
        beanFactory.setBeanExpressionResolver(new StandardBeanExpressionResolver(beanFactory.getBeanClassLoader()));
        beanFactory.addPropertyEditorRegistrar(new ResourceEditorRegistrar(this, getEnvironment()));

        //Configure the bean factory with context callbacks.
        beanFactory.addBeanPostProcessor(new ApplicationContextAwareProcessor(this));
        beanFactory.ignoreDependencyInterface(EnvironmentAware.class);
        beanFactory.ignoreDependencyInterface(EmbeddedValueResolverAware.class);
        beanFactory.ignoreDependencyInterface(ResourceLoaderAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationEventPublisherAware.class);
        beanFactory.ignoreDependencyInterface(MessageSourceAware.class);
        beanFactory.ignoreDependencyInterface(ApplicationContextAware.class);

        //BeanFactory interface not registered as resolvable type in a plain factory.
        //MessageSource registered (and found for autowiring) as a bean.
        beanFactory.registerResolvableDependency(BeanFactory.class, beanFactory);
        beanFactory.registerResolvableDependency(ResourceLoader.class, this);
        beanFactory.registerResolvableDependency(ApplicationEventPublisher.class, this);
        beanFactory.registerResolvableDependency(ApplicationContext.class, this);

        //Register early post-processor for detecting inner beans as ApplicationListeners.
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(this));

        //Detect a LoadTimeWeaver and prepare for weaving, if found.
        if (beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            //Set a temporary ClassLoader for type matching.
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }

        //Register default environment beans.
        if (!beanFactory.containsLocalBean(ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(ENVIRONMENT_BEAN_NAME, getEnvironment());
        }
        if (!beanFactory.containsLocalBean(SYSTEM_PROPERTIES_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_PROPERTIES_BEAN_NAME, getEnvironment().getSystemProperties());
        }
        if (!beanFactory.containsLocalBean(SYSTEM_ENVIRONMENT_BEAN_NAME)) {
            beanFactory.registerSingleton(SYSTEM_ENVIRONMENT_BEAN_NAME, getEnvironment().getSystemEnvironment());
        }
    }

```

## 4.4 postProcessBeanFactory

postProcessBeanFactory目前的实现逻辑就是一个空方法（钩子方法），交给子类去扩展。__此时BeanFactory处于一个初始化完毕（各种上下文环境设置完毕，Bean定义加载完毕等等），但是尚未开始生产单例Bean的状态__

```Java
    protected void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) {
    }
```

## 4.5 invokeBeanFactoryPostProcessors

invokeBeanFactoryPostProcessors方法用于__触发BeanFactory级别的后处理器（BeanFactoryPostProcessor）__

```Java
    protected void invokeBeanFactoryPostProcessors(ConfigurableListableBeanFactory beanFactory) {
        PostProcessorRegistrationDelegate.invokeBeanFactoryPostProcessors(beanFactory, getBeanFactoryPostProcessors());

        //Detect a LoadTimeWeaver and prepare for weaving, if found in the meantime
        //(e.g. through an @Bean method registered by ConfigurationClassPostProcessor)
        if (beanFactory.getTempClassLoader() == null && beanFactory.containsBean(LOAD_TIME_WEAVER_BEAN_NAME)) {
            beanFactory.addBeanPostProcessor(new LoadTimeWeaverAwareProcessor(beanFactory));
            beanFactory.setTempClassLoader(new ContextTypeMatchClassLoader(beanFactory.getBeanClassLoader()));
        }
    }
```

触发BeanFactory后处理器的逻辑由PostProcessorRegistrationDelegate.invokeBeanFactoryPostProcessors静态方法代理

```Java
    public static void invokeBeanFactoryPostProcessors(
            ConfigurableListableBeanFactory beanFactory, List<BeanFactoryPostProcessor> beanFactoryPostProcessors) {

        //Invoke BeanDefinitionRegistryPostProcessors first, if any.
        Set<String> processedBeans = new HashSet<String>();

        if (beanFactory instanceof BeanDefinitionRegistry) {
            BeanDefinitionRegistry registry = (BeanDefinitionRegistry) beanFactory;
            List<BeanFactoryPostProcessor> regularPostProcessors = new LinkedList<BeanFactoryPostProcessor>();
            List<BeanDefinitionRegistryPostProcessor> registryProcessors = new LinkedList<BeanDefinitionRegistryPostProcessor>();

            for (BeanFactoryPostProcessor postProcessor : beanFactoryPostProcessors) {
                if (postProcessor instanceof BeanDefinitionRegistryPostProcessor) {
                    BeanDefinitionRegistryPostProcessor registryProcessor =
                            (BeanDefinitionRegistryPostProcessor) postProcessor;
                    registryProcessor.postProcessBeanDefinitionRegistry(registry);
                    registryProcessors.add(registryProcessor);
                }
                else {
                    regularPostProcessors.add(postProcessor);
                }
            }

            //Do not initialize FactoryBeans here: We need to leave all regular beans
            //uninitialized to let the bean factory post-processors apply to them!
            //Separate between BeanDefinitionRegistryPostProcessors that implement
            //PriorityOrdered, Ordered, and the rest.
            List<BeanDefinitionRegistryPostProcessor> currentRegistryProcessors = new ArrayList<BeanDefinitionRegistryPostProcessor>();

            //First, invoke the BeanDefinitionRegistryPostProcessors that implement PriorityOrdered.
            String[] postProcessorNames =
                    beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
            for (String ppName : postProcessorNames) {
                if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                    currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                    processedBeans.add(ppName);
                }
            }
            sortPostProcessors(currentRegistryProcessors, beanFactory);
            registryProcessors.addAll(currentRegistryProcessors);
            invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
            currentRegistryProcessors.clear();

            //Next, invoke the BeanDefinitionRegistryPostProcessors that implement Ordered.
            postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
            for (String ppName : postProcessorNames) {
                if (!processedBeans.contains(ppName) && beanFactory.isTypeMatch(ppName, Ordered.class)) {
                    currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                    processedBeans.add(ppName);
                }
            }
            sortPostProcessors(currentRegistryProcessors, beanFactory);
            registryProcessors.addAll(currentRegistryProcessors);
            invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
            currentRegistryProcessors.clear();

            //Finally, invoke all other BeanDefinitionRegistryPostProcessors until no further ones appear.
            boolean reiterate = true;
            while (reiterate) {
                reiterate = false;
                postProcessorNames = beanFactory.getBeanNamesForType(BeanDefinitionRegistryPostProcessor.class, true, false);
                for (String ppName : postProcessorNames) {
                    if (!processedBeans.contains(ppName)) {
                        currentRegistryProcessors.add(beanFactory.getBean(ppName, BeanDefinitionRegistryPostProcessor.class));
                        processedBeans.add(ppName);
                        reiterate = true;
                    }
                }
                sortPostProcessors(currentRegistryProcessors, beanFactory);
                registryProcessors.addAll(currentRegistryProcessors);
                invokeBeanDefinitionRegistryPostProcessors(currentRegistryProcessors, registry);
                currentRegistryProcessors.clear();
            }

            //Now, invoke the postProcessBeanFactory callback of all processors handled so far.
            invokeBeanFactoryPostProcessors(registryProcessors, beanFactory);
            invokeBeanFactoryPostProcessors(regularPostProcessors, beanFactory);
        }

        else {
            //Invoke factory processors registered with the context instance.
            invokeBeanFactoryPostProcessors(beanFactoryPostProcessors, beanFactory);
        }

        //Do not initialize FactoryBeans here: We need to leave all regular beans
        //uninitialized to let the bean factory post-processors apply to them!
        String[] postProcessorNames =
                beanFactory.getBeanNamesForType(BeanFactoryPostProcessor.class, true, false);

        //Separate between BeanFactoryPostProcessors that implement PriorityOrdered,
        //Ordered, and the rest.
        List<BeanFactoryPostProcessor> priorityOrderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        List<String> orderedPostProcessorNames = new ArrayList<String>();
        List<String> nonOrderedPostProcessorNames = new ArrayList<String>();
        for (String ppName : postProcessorNames) {
            if (processedBeans.contains(ppName)) {
                //skip - already processed in first phase above
            }
            else if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                priorityOrderedPostProcessors.add(beanFactory.getBean(ppName, BeanFactoryPostProcessor.class));
            }
            else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
                orderedPostProcessorNames.add(ppName);
            }
            else {
                nonOrderedPostProcessorNames.add(ppName);
            }
        }

        //First, invoke the BeanFactoryPostProcessors that implement PriorityOrdered.
        sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
        invokeBeanFactoryPostProcessors(priorityOrderedPostProcessors, beanFactory);

        //Next, invoke the BeanFactoryPostProcessors that implement Ordered.
        List<BeanFactoryPostProcessor> orderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        for (String postProcessorName : orderedPostProcessorNames) {
            orderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
        }
        sortPostProcessors(orderedPostProcessors, beanFactory);
        invokeBeanFactoryPostProcessors(orderedPostProcessors, beanFactory);

        //Finally, invoke all other BeanFactoryPostProcessors.
        List<BeanFactoryPostProcessor> nonOrderedPostProcessors = new ArrayList<BeanFactoryPostProcessor>();
        for (String postProcessorName : nonOrderedPostProcessorNames) {
            nonOrderedPostProcessors.add(beanFactory.getBean(postProcessorName, BeanFactoryPostProcessor.class));
        }
        invokeBeanFactoryPostProcessors(nonOrderedPostProcessors, beanFactory);

        //Clear cached merged bean definitions since the post-processors might have
        //modified the original metadata, e.g. replacing placeholders in values...
        beanFactory.clearMetadataCache();
    }
```

## 4.6 registerBeanPostProcessors

registerBeanPostProcessors方法用于__初始化已注册的Bean级别的后处理器（BeanPostProcessor）__

```Java
    protected void registerBeanPostProcessors(ConfigurableListableBeanFactory beanFactory) {
        PostProcessorRegistrationDelegate.registerBeanPostProcessors(beanFactory, this);
    }
```

触发BeanFactory后处理器的逻辑由PostProcessorRegistrationDelegate.registerBeanPostProcessors静态方法代理

```Java
    public static void registerBeanPostProcessors(
            ConfigurableListableBeanFactory beanFactory, AbstractApplicationContext applicationContext) {

        String[] postProcessorNames = beanFactory.getBeanNamesForType(BeanPostProcessor.class, true, false);

        //Register BeanPostProcessorChecker that logs an info message when
        //a bean is created during BeanPostProcessor instantiation, i.e. when
        //a bean is not eligible for getting processed by all BeanPostProcessors.
        int beanProcessorTargetCount = beanFactory.getBeanPostProcessorCount() + 1 + postProcessorNames.length;
        beanFactory.addBeanPostProcessor(new BeanPostProcessorChecker(beanFactory, beanProcessorTargetCount));

        //Separate between BeanPostProcessors that implement PriorityOrdered,
        //Ordered, and the rest.
        List<BeanPostProcessor> priorityOrderedPostProcessors = new ArrayList<BeanPostProcessor>();
        List<BeanPostProcessor> internalPostProcessors = new ArrayList<BeanPostProcessor>();
        List<String> orderedPostProcessorNames = new ArrayList<String>();
        List<String> nonOrderedPostProcessorNames = new ArrayList<String>();
        for (String ppName : postProcessorNames) {
            if (beanFactory.isTypeMatch(ppName, PriorityOrdered.class)) {
                BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
                priorityOrderedPostProcessors.add(pp);
                if (pp instanceof MergedBeanDefinitionPostProcessor) {
                    internalPostProcessors.add(pp);
                }
            }
            else if (beanFactory.isTypeMatch(ppName, Ordered.class)) {
                orderedPostProcessorNames.add(ppName);
            }
            else {
                nonOrderedPostProcessorNames.add(ppName);
            }
        }

        //First, register the BeanPostProcessors that implement PriorityOrdered.
        sortPostProcessors(priorityOrderedPostProcessors, beanFactory);
        registerBeanPostProcessors(beanFactory, priorityOrderedPostProcessors);

        //Next, register the BeanPostProcessors that implement Ordered.
        List<BeanPostProcessor> orderedPostProcessors = new ArrayList<BeanPostProcessor>();
        for (String ppName : orderedPostProcessorNames) {
            BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
            orderedPostProcessors.add(pp);
            if (pp instanceof MergedBeanDefinitionPostProcessor) {
                internalPostProcessors.add(pp);
            }
        }
        sortPostProcessors(orderedPostProcessors, beanFactory);
        registerBeanPostProcessors(beanFactory, orderedPostProcessors);

        //Now, register all regular BeanPostProcessors.
        List<BeanPostProcessor> nonOrderedPostProcessors = new ArrayList<BeanPostProcessor>();
        for (String ppName : nonOrderedPostProcessorNames) {
            BeanPostProcessor pp = beanFactory.getBean(ppName, BeanPostProcessor.class);
            nonOrderedPostProcessors.add(pp);
            if (pp instanceof MergedBeanDefinitionPostProcessor) {
                internalPostProcessors.add(pp);
            }
        }
        registerBeanPostProcessors(beanFactory, nonOrderedPostProcessors);

        //Finally, re-register all internal BeanPostProcessors.
        sortPostProcessors(internalPostProcessors, beanFactory);
        registerBeanPostProcessors(beanFactory, internalPostProcessors);

        //Re-register post-processor for detecting inner beans as ApplicationListeners,
        //moving it to the end of the processor chain (for picking up proxies etc).
        beanFactory.addBeanPostProcessor(new ApplicationListenerDetector(applicationContext));
    }
```

## 4.7 initMessageSource

initMessageSource方法用于__初始化消息源（MessageSource）__

```Java
    protected void initMessageSource() {
        ConfigurableListableBeanFactory beanFactory = getBeanFactory();
        if (beanFactory.containsLocalBean(MESSAGE_SOURCE_BEAN_NAME)) {
            this.messageSource = beanFactory.getBean(MESSAGE_SOURCE_BEAN_NAME, MessageSource.class);
            //Make MessageSource aware of parent MessageSource.
            if (this.parent != null && this.messageSource instanceof HierarchicalMessageSource) {
                HierarchicalMessageSource hms = (HierarchicalMessageSource) this.messageSource;
                if (hms.getParentMessageSource() == null) {
                    //Only set parent context as parent MessageSource if no parent MessageSource
                    //registered already.
                    hms.setParentMessageSource(getInternalParentMessageSource());
                }
            }
            if (logger.isDebugEnabled()) {
                logger.debug("Using MessageSource [" + this.messageSource + "]");
            }
        }
        else {
            //Use empty MessageSource to be able to accept getMessage calls.
            DelegatingMessageSource dms = new DelegatingMessageSource();
            dms.setParentMessageSource(getInternalParentMessageSource());
            this.messageSource = dms;
            beanFactory.registerSingleton(MESSAGE_SOURCE_BEAN_NAME, this.messageSource);
            if (logger.isDebugEnabled()) {
                logger.debug("Unable to locate MessageSource with name '" + MESSAGE_SOURCE_BEAN_NAME +
                        "': using default [" + this.messageSource + "]");
            }
        }
    }
```

## 4.8 initApplicationEventMulticaster

initApplicationEventMulticaster方法用于__初始化应用事件传播组件（ApplicationEventMulticaster）__

```Java
    protected void initApplicationEventMulticaster() {
        ConfigurableListableBeanFactory beanFactory = getBeanFactory();
        if (beanFactory.containsLocalBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME)) {
            this.applicationEventMulticaster =
                    beanFactory.getBean(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, ApplicationEventMulticaster.class);
            if (logger.isDebugEnabled()) {
                logger.debug("Using ApplicationEventMulticaster [" + this.applicationEventMulticaster + "]");
            }
        }
        else {
            this.applicationEventMulticaster = new SimpleApplicationEventMulticaster(beanFactory);
            beanFactory.registerSingleton(APPLICATION_EVENT_MULTICASTER_BEAN_NAME, this.applicationEventMulticaster);
            if (logger.isDebugEnabled()) {
                logger.debug("Unable to locate ApplicationEventMulticaster with name '" +
                        APPLICATION_EVENT_MULTICASTER_BEAN_NAME +
                        "': using default [" + this.applicationEventMulticaster + "]");
            }
        }
    }
```

## 4.9 onRefresh

onRefresh方法目前的实现逻辑就是一个空方法（钩子方法），交给子类去扩展。__该方法被设计用于初始化一些特殊的上下文环境，生成一些特殊的Bean，此时BeanFactory尚未初始化单例Bean__

```Java
    protected void onRefresh() throws BeansException {
        //For subclasses: do nothing by default.
    }
```

## 4.10 registerListeners

registerListeners方法用于__注册那些实现了ApplicationListener接口的Listener__

```Java
    protected void registerListeners() {
        //Register statically specified listeners first.
        for (ApplicationListener<?> listener : getApplicationListeners()) {
            getApplicationEventMulticaster().addApplicationListener(listener);
        }

        //Do not initialize FactoryBeans here: We need to leave all regular beans
        //uninitialized to let post-processors apply to them!
        String[] listenerBeanNames = getBeanNamesForType(ApplicationListener.class, true, false);
        for (String listenerBeanName : listenerBeanNames) {
            getApplicationEventMulticaster().addApplicationListenerBean(listenerBeanName);
        }

        //Publish early application events now that we finally have a multicaster...
        Set<ApplicationEvent> earlyEventsToProcess = this.earlyApplicationEvents;
        this.earlyApplicationEvents = null;
        if (earlyEventsToProcess != null) {
            for (ApplicationEvent earlyEvent : earlyEventsToProcess) {
                getApplicationEventMulticaster().multicastEvent(earlyEvent);
            }
        }
    }
```

## 4.11 finishBeanFactoryInitialization

finishBeanFactoryInitialization方法用于__初始化所有单例Bean__

```Java
    protected void finishBeanFactoryInitialization(ConfigurableListableBeanFactory beanFactory) {
        //Initialize conversion service for this context.
        if (beanFactory.containsBean(CONVERSION_SERVICE_BEAN_NAME) &&
                beanFactory.isTypeMatch(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class)) {
            beanFactory.setConversionService(
                    beanFactory.getBean(CONVERSION_SERVICE_BEAN_NAME, ConversionService.class));
        }

        //Register a default embedded value resolver if no bean post-processor
        //(such as a PropertyPlaceholderConfigurer bean) registered any before:
        //at this point, primarily for resolution in annotation attribute values.
        if (!beanFactory.hasEmbeddedValueResolver()) {
            beanFactory.addEmbeddedValueResolver(new StringValueResolver() {
                @Override
                public String resolveStringValue(String strVal) {
                    return getEnvironment().resolvePlaceholders(strVal);
                }
            });
        }

        //Initialize LoadTimeWeaverAware beans early to allow for registering their transformers early.
        String[] weaverAwareNames = beanFactory.getBeanNamesForType(LoadTimeWeaverAware.class, false, false);
        for (String weaverAwareName : weaverAwareNames) {
            getBean(weaverAwareName);
        }

        //Stop using the temporary ClassLoader for type matching.
        beanFactory.setTempClassLoader(null);

        //Allow for caching all bean definition metadata, not expecting further changes.
        beanFactory.freezeConfiguration();

        //Instantiate all remaining (non-lazy-init) singletons.
        beanFactory.preInstantiateSingletons();
    }

```

## 4.12 finishRefresh

finishRefresh方法用于触发LifecycleProcessor.onRefresh方法，以及发布上下文初始化事件

```Java
    protected void finishRefresh() {
        //Initialize lifecycle processor for this context.
        initLifecycleProcessor();

        //Propagate refresh to lifecycle processor first.
        getLifecycleProcessor().onRefresh();

        //Publish the final event.
        publishEvent(new ContextRefreshedEvent(this));

        //Participate in LiveBeansView MBean, if active.
        LiveBeansView.registerApplicationContext(this);
    }
```

## 4.13 resetCommonCaches

resetCommonCaches方法用于__重置Spring core的核心cache__

```Java
    protected void resetCommonCaches() {
        ReflectionUtils.clearCache();
        ResolvableType.clearCache();
        CachedIntrospectionResults.clearClassLoader(getClassLoader());
    }
```

# 5 参考

* [Introduction to the Spring Framework](https://docs.spring.io/spring/docs/4.3.13.RELEASE/spring-framework-reference/html/overview.html)
* 《Spring技术内幕》

```flow
```
