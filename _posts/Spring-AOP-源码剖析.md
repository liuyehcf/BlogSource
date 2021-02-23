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

**阅读更多**

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

**AOP联盟定义了两个重要的基本概念**

1. `Advice`：**增强，代表要织入的逻辑**
1. `Joinpoint`：**织入点，增强逻辑的织入地点**

接下来我们看一下，AOP联盟是如何定义这两个基本概念的

### 1.2.1 Advice

Advice接口的继承体系如下：

1. `Advice`：标记接口，这个接口代表一个增强，**即要执行的动作**
1. `Interceptor`：标记接口，这个接口代表一个通用的拦截器。**Interceptor是Advice的一种具体的语义**
1. `MethodInterceptor`：方法拦截器，**MethodInterceptor是Interceptor的一种具体语义**
1. `ConstructorInterceptor`：构造器拦截器，**ConstructorInterceptor是Interceptor的一种具体语义**

```
 Advice
    |
    ├── Interceptor
    |       |
    |       ├── MethodInterceptor
    |       ├── ConstructorInterceptor
```

各个接口详细定义如下

```java
public interface Advice {

}
```

```java
public interface Interceptor extends Advice {

}
```

```java
public interface MethodInterceptor extends Interceptor {

    Object invoke(MethodInvocation invocation) throws Throwable;

}
```

```java
public interface ConstructorInterceptor extends Interceptor  {

    Object construct(ConstructorInvocation invocation) throws Throwable;

}
```

### 1.2.2 Joinpoint

Joinpoint接口的继承体系如下：

1. `Joinpoint`：织入点，这个接口代表了运行时的`通用`织入点（可以是代码中的任何地方）
1. `Invocation`：调用织入点，这个接口代表了程序中的`调用`织入点，**Invocation是Joinpoint的一种具体语义**
1. `MethodInvocation`：方法调用织入点，这个接口代表了程序中的`方法调用`织入点，**MethodInvocation是Invocation的一种具体语义**

```
 Joinpoint
    |
    ├── Invocation
    |       |
    |       ├── MethodInvocation
    |       ├── ConstructorInvocation
```

各个接口详细定义如下

```java
public interface Joinpoint {

    Object proceed() throws Throwable;

    Object getThis();

    AccessibleObject getStaticPart();

}
```

```java
public interface Invocation extends Joinpoint {

    Object[] getArguments();

}
```

```java
public interface MethodInvocation extends Invocation {

    Method getMethod();

}

```

```java
public interface ConstructorInvocation extends Invocation {

    Constructor<?> getConstructor();

}
```

## 1.3 Spring AOP

Spring AOP并不是自立门户，而是在AOP联盟定义的一系列接口上进行粒度更细的划分

### 1.3.1 Advice

Spring对于Advice接口的继承体系进行了扩展，扩展后的继承体系如下（由于Spring定义的接口众多，这里仅列出几个比较核心的扩展接口）：

1. `IntroductionInterceptor`：标记接口，引介增强，用于类级别的增强
1. `BeforeAdvice`：标记接口，代表前置增强逻辑
1. `AfterAdvice`：标记接口，代表后置增强逻辑
1. `MethodBeforeAdvice`：方法前置增强，**MethodBeforeAdvice是BeforeAdvice的一种具体语义**
1. `AfterReturningAdvice`：方法后置增强，**AfterReturningAdvice是AfterAdvice的一种具体语义**
1. `ThrowsAdvice`：异常增强，**ThrowsAdvice是AfterAdvice的一种具体语义**

```
 Advice (AOP Alliance)
    |
    ├── Interceptor (AOP Alliance)
    |       |
    |       ├── MethodInterceptor (AOP Alliance)
    |        |        |
    |        |        ├── IntroductionInterceptor (Spring AOP)
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

```java
public interface BeforeAdvice extends Advice {

}
```

```java
public interface MethodBeforeAdvice extends BeforeAdvice {

    void before(Method method, Object[] args, Object target) throws Throwable;

}
```

```java
public interface AfterAdvice extends Advice {

}
```

```java
public interface ThrowsAdvice extends AfterAdvice {

}
```

```java
public interface AfterReturningAdvice extends AfterAdvice {

    void afterReturning(Object returnValue, Method method, Object[] args, Object target) throws Throwable;

}
```

### 1.3.2 Joinpoint

Spring AOP对Joinpoint接口进行了少量的扩展

1. `ProxyMethodInvocation`：在MethodInvocation接口的基础上增加了保存目标对象、保存方法参数等能力。是Spring AOP用于织入代理逻辑的核心接口
1. `ReflectiveMethodInvocation`：ProxyMethodInvocation的默认、唯一的实现

```
 Joinpoint (AOP Alliance)
    |
    ├── Invocation (AOP Alliance)
    |       |
    |       ├── MethodInvocation (AOP Alliance)
    |        |        |
    |        |        ├── ProxyMethodInvocation (Spring AOP)
    |        |        |        |
    |        |        |        ├── ReflectiveMethodInvocation (Spring AOP)
    |       ├── ConstructorInvocation (AOP Alliance)
```

### 1.3.3 Pointcut

Pointcut是Spring AOP新增的接口，**该接口定义了Joinpoint的匹配规则，即一个Pointcut关联着一组Joinpoint**

接口定义如下

```java
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
1. `IntroductionAdvisor`：引介切面，用于类级别的增强（增加方法或者属性等）

```
 Advisor 
    |
    ├── PointcutAdvisor
    ├── IntroductionAdvisor
```

Advisor也是Spring AOP新增的接口，可以理解为切面（还有的称为通知器，Advice就是通知）。**PointcutAdvisor接口关联着一个Advice和一个Pointcut，其中Advice代表着织入的逻辑，Pointcut代表着织入的地点集合**。因此一个Advisor包含了**一个增强逻辑**以及**织入地点的集合**

几个核心扩展接口的定义如下

```java
public interface Advisor {

    Advice getAdvice();

    //判断持有的Advice是否关联着一个具体实例，在Spring框架中，总是返回true
    boolean isPerInstance();
}
```

```java
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

Spring AOP源码分析将分为以下几个部分

1. Spring AOP与Spring IoC容器的集成
1. Advisor/Advice的生成
1. Spring动态代理的生成

## 2.1 集成IoC

Spring AOP通常与Spring IoC结合使用，通过BeanPostProcessor接口，以低耦合的方式将Spring AOP整合到Spring IoC容器当中

**在BeanPostProcessor的继承体系中，与Spring AOP相关部分如下**

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

```java
    @Override
    public Object applyBeanPostProcessorsAfterInitialization(Object existingBean, String beanName)
            throws BeansException {

        Object result = existingBean;
        for (BeanPostProcessor beanProcessor : getBeanPostProcessors()) {
            //遍历所有的BeanPostProcessor，这里我们只关心与AOP相关的BeanPostProcessor
            result = beanProcessor.postProcessAfterInitialization(result, beanName);
            if (result == null) {
                return result;
            }
        }
        return result;
    }
```

这里BeanPostProcessor的实现类是AnnotationAwareAspectJAutoProxyCreator，其postProcessAfterInitialization方法逻辑定义在AbstractAutoProxyCreator之中

```java
@Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        if (bean != null) {
            Object cacheKey = getCacheKey(bean.getClass(), beanName);
            if (!this.earlyProxyReferences.contains(cacheKey)) {
                //如果有必要的话，对Bean进行包装（即代理）
                return wrapIfNecessary(bean, beanName, cacheKey);
            }
        }
        return bean;
    }
```

wrapIfNecessary方法也定义在AbstractAutoProxyCreator之中。该方法主要逻辑如下

1. 首先判断当前Bean是否需要进行代理增强
1. 获取Advice或者Advisor集合
1. 创建代理类

```java
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

        //获取Advice或者Advisor
        Object[] specificInterceptors = getAdvicesAndAdvisorsForBean(bean.getClass(), beanName, null);

        if (specificInterceptors != DO_NOT_PROXY) {
            this.advisedBeans.put(cacheKey, Boolean.TRUE);
            //为当前Bean创建代理对象
            Object proxy = createProxy(
                    bean.getClass(), beanName, specificInterceptors, new SingletonTargetSource(bean));
            this.proxyTypes.put(cacheKey, proxy.getClass());
            return proxy;
        }

        this.advisedBeans.put(cacheKey, Boolean.FALSE);
        return bean;
    }

```

## 2.2 Advice/Advisor的获取

在AbstractAutoProxyCreator.wrapIfNecessary方法中调用了getAdvicesAndAdvisorsForBean方法来**获取增强（Advice）或者切面（Advisor）**，该方法是AbstractAutoProxyCreator中的一个抽象方法，具体的实现由子类AbstractAdvisorAutoProxyCreator提供

```java
    protected Object[] getAdvicesAndAdvisorsForBean(Class<?> beanClass, String beanName, TargetSource targetSource) {
        List<Advisor> advisors = findEligibleAdvisors(beanClass, beanName);
        if (advisors.isEmpty()) {
            return DO_NOT_PROXY;
        }
        return advisors.toArray();
    }
```

继续跟踪findEligibleAdvisors方法，该方法同样位于AbstractAdvisorAutoProxyCreator中，**该方法就是为指定Bean收集所有匹配的Advisor**，其逻辑可以分为如下三部分

1. 找出所有可用的Advisor
1. 在所有Advisor中筛选出匹配当前Bean的Advisor
1. 添加一些扩展的Advisor，这些Advisor通常是由Spring AOP内部提供，与业务无关

```java
    protected List<Advisor> findEligibleAdvisors(Class<?> beanClass, String beanName) {
        //获取所有可用于自动代理的Advisor
        List<Advisor> candidateAdvisors = findCandidateAdvisors();
        //在所有可用于自动代理的Advisor中，筛选出可用于当前Bean的Advisor
        List<Advisor> eligibleAdvisors = findAdvisorsThatCanApply(candidateAdvisors, beanClass, beanName);
        extendAdvisors(eligibleAdvisors);
        if (!eligibleAdvisors.isEmpty()) {
            //按照@Order注解标注的值进行排序
            eligibleAdvisors = sortAdvisors(eligibleAdvisors);
        }
        return eligibleAdvisors;
    }

    protected List<Advisor> sortAdvisors(List<Advisor> advisors) {
        List<PartiallyComparableAdvisorHolder> partiallyComparableAdvisors =
                new ArrayList<PartiallyComparableAdvisorHolder>(advisors.size());
        for (Advisor element : advisors) {
            partiallyComparableAdvisors.add(
                    new PartiallyComparableAdvisorHolder(element, DEFAULT_PRECEDENCE_COMPARATOR));
        }
        List<PartiallyComparableAdvisorHolder> sorted =
                PartialOrder.sort(partiallyComparableAdvisors);
        if (sorted != null) {
            List<Advisor> result = new ArrayList<Advisor>(advisors.size());
            for (PartiallyComparableAdvisorHolder pcAdvisor : sorted) {
                result.add(pcAdvisor.getAdvisor());
            }
            return result;
        }
        else {
            return super.sortAdvisors(advisors);
        }
    }

    public static <T extends PartialComparable> List<T> sort(List<T> objects) {
        // lists of size 0 or 1 don't need any sorting
        if (objects.size() < 2) {
            return objects;
        }

        // ??? we might want to optimize a few other cases of small size

        // ??? I don't like creating this data structure, but it does give good
        // ??? separation of concerns.
        List<SortObject<T>> sortList = new LinkedList<SortObject<T>>();
        for (Iterator<T> i = objects.iterator(); i.hasNext();) {
            addNewPartialComparable(sortList, i.next());
        }

        // System.out.println(sortList);

        // now we have built our directed graph
        // use a simple sort algorithm from here
        // can increase efficiency later
        // List ret = new ArrayList(objects.size());
        final int N = objects.size();
        for (int index = 0; index < N; index++) {
            // System.out.println(sortList);
            // System.out.println("-->" + ret);

            SortObject<T> leastWithNoSmallers = null;

            for (SortObject<T> so: sortList) {
                if (so.hasNoSmallerObjects()) {
                    if (leastWithNoSmallers == null || so.object.fallbackCompareTo(leastWithNoSmallers.object) < 0) {
                        leastWithNoSmallers = so;
                    }
                }
            }

            if (leastWithNoSmallers == null) {
                return null;
            }

            removeFromGraph(sortList, leastWithNoSmallers);
            objects.set(index, leastWithNoSmallers.object);
        }

        return objects;
    }
```

其中，findCandidateAdvisors方法用于获取所有的Advisor，该方法定义在AbstractAdvisorAutoProxyCreator中，并且子类
AnnotationAwareAspectJAutoProxyCreator复写了该方法。Spring AOP支持两种配置方式：XML配置，利用`<aop:config>`标签；注解方式，利用`org.aspectj.lang.annotation`包下的相关注解，例如@Aspect、@Before等等。下面给出AnnotationAwareAspectJAutoProxyCreator中的版本，其主要逻辑如下

* 通过父类AbstractAdvisorAutoProxyCreator的同名方法获取由Spring XML配置文件定义的Advisor
* 获取由`org.aspectj.lang.annotation`包下的相关AOP注解定义的Advisor

```java
    @Override
    protected List<Advisor> findCandidateAdvisors() {
        //Add all the Spring advisors found according to superclass rules.
        List<Advisor> advisors = super.findCandidateAdvisors();
        //Build Advisors for all AspectJ aspects in the bean factory.
        advisors.addAll(this.aspectJAdvisorsBuilder.buildAspectJAdvisors());
        return advisors;
    }
```

首先，我们来看下父类AbstractAdvisorAutoProxyCreator.findCandidateAdvisors方法

```java
    protected List<Advisor> findCandidateAdvisors() {
        return this.advisorRetrievalHelper.findAdvisorBeans();
    }
```

AbstractAdvisorAutoProxyCreator.findCandidateAdvisors方法方法继续转调用BeanFactoryAdvisorRetrievalHelper.findAdvisorBeans，**该方法的主要逻辑就是从Spring的IoC容器中找出Advisor类型的所有Bean**

```java
public List<Advisor> findAdvisorBeans() {
        //Determine list of advisor bean names, if not cached already.
        //获取所有Advisor的Bean的名字
        String[] advisorNames = null;
        synchronized (this) {
            advisorNames = this.cachedAdvisorBeanNames;
            if (advisorNames == null) {
                //Do not initialize FactoryBeans here: We need to leave all regular beans
                //uninitialized to let the auto-proxy creator apply to them!
                advisorNames = BeanFactoryUtils.beanNamesForTypeIncludingAncestors(
                        this.beanFactory, Advisor.class, true, false);
                this.cachedAdvisorBeanNames = advisorNames;
            }
        }
        if (advisorNames.length == 0) {
            return new LinkedList<Advisor>();
        }

        List<Advisor> advisors = new LinkedList<Advisor>();
        //遍历每个Advisor的名字
        for (String name : advisorNames) {
            if (isEligibleBean(name)) {
                if (this.beanFactory.isCurrentlyInCreation(name)) {
                    if (logger.isDebugEnabled()) {
                        logger.debug("Skipping currently created advisor '" + name + "'");
                    }
                }
                else {
                    try {
                        //取出对应的Bean，添加到列表中
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
                                //Ignore: indicates a reference back to the bean we're trying to advise.
                                //We want to find advisors other than the currently created bean itself.
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

接着，我们回到AnnotationAwareAspectJAutoProxyCreator.findCandidateAdvisors方法中，看一下buildAspectJAdvisors方法的具体逻辑，该方法定义在BeanFactoryAspectJAdvisorsBuilder之中。**该方法的主要逻辑是：针对每一个用@Aspect注解标记的类，遍历其所有标记了注解（包括@Before、@After等）的方法，将每个方法封装成一个Advice，然后再封装成Advisor**

```java
    public List<Advisor> buildAspectJAdvisors() {
        //获取所有标记了@Aspect注解的Bean的名字
        List<String> aspectNames = this.aspectBeanNames;

        //下面这个if子句用于初始化this.aspectBeanNames
        if (aspectNames == null) {
            synchronized (this) {
                aspectNames = this.aspectBeanNames;
                if (aspectNames == null) {
                    List<Advisor> advisors = new LinkedList<Advisor>();
                    aspectNames = new LinkedList<String>();
                    //获取所有Bean的名字
                    String[] beanNames = BeanFactoryUtils.beanNamesForTypeIncludingAncestors(
                            this.beanFactory, Object.class, true, false);
                    //遍历这些Bean的名字
                    for (String beanName : beanNames) {
                        if (!isEligibleBean(beanName)) {
                            continue;
                        }
                        //We must be careful not to instantiate beans eagerly as in this case they
                        //would be cached by the Spring container but would not have been weaved.
                        Class<?> beanType = this.beanFactory.getType(beanName);
                        if (beanType == null) {
                            continue;
                        }

                        //这里检验这个类型是否被@Aspect注解标记，或者用Aspect编译器编译过。总是就是检查是否与Aspect相关
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
                                //Per target or per this.
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

        //到这，说明已经初始化过一次了，直接从缓存中拿即可
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

接着，回到AbstractAdvisorAutoProxyCreator.findEligibleAdvisors方法中，继续分析findAdvisorsThatCanApply方法。**该方法用于在给定的Advisor集合中，筛选出匹配指定Bean的Advisor**

```java
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

具体的逻辑由AopUtils的同名方法实现，AopUtils提供了一些静态工具方法。该方法主要逻辑如下

1. 首先处理IntroductionAdvisor类型的Advisor
1. 然后处理PointcutAdvisor类型的Advisor

```java
    public static List<Advisor> findAdvisorsThatCanApply(List<Advisor> candidateAdvisors, Class<?> clazz) {
        if (candidateAdvisors.isEmpty()) {
            return candidateAdvisors;
        }
        List<Advisor> eligibleAdvisors = new LinkedList<Advisor>();

        //首先处理IntroductionAdvisor类型的Advisor
        for (Advisor candidate : candidateAdvisors) {
            if (candidate instanceof IntroductionAdvisor && canApply(candidate, clazz)) {
                eligibleAdvisors.add(candidate);
            }
        }
        boolean hasIntroductions = !eligibleAdvisors.isEmpty();

        //然后处理PointcutAdvisor类型的Advisor
        for (Advisor candidate : candidateAdvisors) {
            if (candidate instanceof IntroductionAdvisor) {
                //already processed
                continue;
            }
            if (canApply(candidate, clazz, hasIntroductions)) {
                eligibleAdvisors.add(candidate);
            }
        }
        return eligibleAdvisors;
    }
```

继续跟踪位于AopUtils中的canApply方法，该方法有不同的重载版本，大致逻辑如下

1. 如果Advisor实现了IntroductionAdvisor接口，那么简单用类过滤器进行判断即可
1. 如果Advisor实现了PointcutAdvisor接口，由于这是方法级别的切面，处理逻辑相对复杂：需要提取出目标类实现的所有实现的接口，并将这些接口的所有方法与Pointcut进行匹配，至少有一个匹配成功就返回true

```java
    public static boolean canApply(Advisor advisor, Class<?> targetClass) {
        return canApply(advisor, targetClass, false);
    }

    public static boolean canApply(Advisor advisor, Class<?> targetClass, boolean hasIntroductions) {
        //如果是IntroductionAdvisor，那么根据类过滤器进行判断即可
        if (advisor instanceof IntroductionAdvisor) {
            return ((IntroductionAdvisor) advisor).getClassFilter().matches(targetClass);
        }
        //如果是PointcutAdvisor，那么继续调用另一个重载版本进行判断
        else if (advisor instanceof PointcutAdvisor) {
            PointcutAdvisor pca = (PointcutAdvisor) advisor;
            return canApply(pca.getPointcut(), targetClass, hasIntroductions);
        }
        else {
            //It doesn't have a pointcut so we assume it applies.
            return true;
        }
    }

    public static boolean canApply(Pointcut pc, Class<?> targetClass, boolean hasIntroductions) {
        Assert.notNull(pc, "Pointcut must not be null");
        //如果类不匹配，那么直接返回false
        if (!pc.getClassFilter().matches(targetClass)) {
            return false;
        }

        MethodMatcher methodMatcher = pc.getMethodMatcher();
        //如果是一个默认的单例对象，那么直接返回true
        if (methodMatcher == MethodMatcher.TRUE) {
            //No need to iterate the methods if we're matching any method anyway...
            return true;
        }

        IntroductionAwareMethodMatcher introductionAwareMethodMatcher = null;
        if (methodMatcher instanceof IntroductionAwareMethodMatcher) {
            introductionAwareMethodMatcher = (IntroductionAwareMethodMatcher) methodMatcher;
        }

        //获取所有指定类直接或间接实现的接口
        Set<Class<?>> classes = new LinkedHashSet<Class<?>>(ClassUtils.getAllInterfacesForClassAsSet(targetClass));
        classes.add(targetClass);
        for (Class<?> clazz : classes) {
            //获取所有方法
            Method[] methods = ReflectionUtils.getAllDeclaredMethods(clazz);
            //如果至少有一个方法匹配成功，那么就返回true
            for (Method method : methods) {
                if ((introductionAwareMethodMatcher != null &&
                        introductionAwareMethodMatcher.matches(method, targetClass, hasIntroductions)) ||
                        methodMatcher.matches(method, targetClass)) {
                    return true;
                }
            }
        }

        return false;
    }
```

## 2.3 创建代理

回到AbstractAutoProxyCreator.wrapIfNecessary方法中继续分析，接下来看createProxy方法，该方法位于AbstractAutoProxyCreator之中。该方法用于为指定Bean创建代理，其主要逻辑如下

1. 创建代理工厂对象
1. 处理给定的拦截器，必要时进行封装（将Advice封装成Advisor）
1. 生成代理对象

```java
    protected Object createProxy(
            Class<?> beanClass, String beanName, Object[] specificInterceptors, TargetSource targetSource) {

        if (this.beanFactory instanceof ConfigurableListableBeanFactory) {
            AutoProxyUtils.exposeTargetClass((ConfigurableListableBeanFactory) this.beanFactory, beanName, beanClass);
        }

        //创建一个代理工厂，并为其设置参数
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

        //处理由前面获取到的Advisor
        Advisor[] advisors = buildAdvisors(beanName, specificInterceptors);
        proxyFactory.addAdvisors(advisors);
        proxyFactory.setTargetSource(targetSource);
        customizeProxyFactory(proxyFactory);

        proxyFactory.setFrozen(this.freezeProxy);
        if (advisorsPreFiltered()) {
            proxyFactory.setPreFiltered(true);
        }

        //用代理工厂，创建代理
        return proxyFactory.getProxy(getProxyClassLoader());
    }
```

AbstractAutoProxyCreator.buildAdvisors方法用于将Advice封装成Advisor，**例如将MethodBeforeAdvice、AfterReturningAdvice之类的接口转换成标准的方法拦截器接口MethodInterceptor**

```java
    protected Advisor[] buildAdvisors(String beanName, Object[] specificInterceptors) {
        //Handle prototypes correctly...
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
            //这里是封装的核心
            advisors[i] = this.advisorAdapterRegistry.wrap(allInterceptors.get(i));
        }
        return advisors;
    }
```

我们继续看wrap方法，该方法定义在DefaultAdvisorAdapterRegistry（该类是AdvisorAdapterRegistry接口的唯一实现）中。该方法用于将Advice类型的对象封装成一个Advisor，**在封装的过程中，会用到一系列适配器（Adapter），例如MethodBeforeAdviceAdapter、ThrowsAdviceAdapter、AfterReturningAdviceAdapter，这些适配器的作用就是将MethodBeforeAdvice、AfterReturningAdvice之类的接口转换成标准的方法拦截器接口MethodInterceptor**（我们之前分析的AbstractAdvisorAutoProxyCreator.getAdvicesAndAdvisorsForBean方法获取到的本身就是Advisor，因此，这些Advisor在wrap方法的处理逻辑中直接就返回了）

```java
    //可以看到DefaultAdvisorAdapterRegistry默认注册了三个适配器
    public DefaultAdvisorAdapterRegistry() {
        registerAdvisorAdapter(new MethodBeforeAdviceAdapter());
        registerAdvisorAdapter(new AfterReturningAdviceAdapter());
        registerAdvisorAdapter(new ThrowsAdviceAdapter());
    }

    public Advisor wrap(Object adviceObject) throws UnknownAdviceTypeException {
        //如果本身就是Advisor那么直接返回即可
        if (adviceObject instanceof Advisor) {
            return (Advisor) adviceObject;
        }
        if (!(adviceObject instanceof Advice)) {
            throw new UnknownAdviceTypeException(adviceObject);
        }
        Advice advice = (Advice) adviceObject;
        if (advice instanceof MethodInterceptor) {
            //So well-known it doesn't even need an adapter.
            return new DefaultPointcutAdvisor(advice);
        }
        for (AdvisorAdapter adapter : this.adapters) {
            //Check that it is supported.
            //查看该Advice是否被现有的Adpater支持
            if (adapter.supportsAdvice(advice)) {
                //封装成Advisor
                return new DefaultPointcutAdvisor(advice);
            }
        }
        throw new UnknownAdviceTypeException(advice);
    }
```

接下来，分析getProxy方法。我们首先来看一下ProxyFactory的继承结构

1. `ProxyConfig`：用于管理一些代理所需的配置信息
1. `AdvisedSupport`：AOP代理配置管理器的基类，这个类没有创建代理对象的能力，通常其子类拥有创建代理对象的能力
1. `ProxyCreatorSupport`：代理工厂的基类
1. `ProxyFactoryBean`：AOP与IoC集成所需要的类，用于显式为指定bean创建代理
1. `ProxyFactory`：AOP代理的工厂，用于编程使用，与ProxyFactoryBean的配置式使用方式不同。此外，这个类提供了一个获取和配置AOP代理对象的方法
1. `AspectJProxyFactory`：基于AspectJ的代理工厂，允许编程构建Aspect切面的代理对象

```
ProxyConfig
    ├── AdvisedSupport
    |        ├── ProxyCreatorSupport
    |        |        ├── ProxyFactoryBean
    |        |        ├── ProxyFactory
    |        |        ├── AspectJProxyFactory
```

继续分析ProxyFactory.getProxy方法。该方法的主要逻辑如下

1. 通过createAopProxy方法创建AopProxy的实例
1. 然后调用AopProxy.getProxy方法获取代理对象

```java
    public Object getProxy(ClassLoader classLoader) {
        return createAopProxy().getProxy(classLoader);
    }
```

首先，我们来看一下createAopProxy的具体逻辑，该方法位于ProxyCreatorSupport中。该类持有了一个AopProxyFactory接口的实例，AopProxyFactory接口很简单，只有一个默认实现DefaultAopProxyFactory

```java
    private AopProxyFactory aopProxyFactory;

    protected final synchronized AopProxy createAopProxy() {
        if (!this.active) {
            activate();
        }
        return getAopProxyFactory().createAopProxy(this);
    }

    public AopProxyFactory getAopProxyFactory() {
        return this.aopProxyFactory;
    }
```

DefaultAopProxyFactory.createAopProxy方法具体逻辑如下

```java
    public AopProxy createAopProxy(AdvisedSupport config) throws AopConfigException {
        if (config.isOptimize() || config.isProxyTargetClass() || hasNoUserSuppliedProxyInterfaces(config)) {
            Class<?> targetClass = config.getTargetClass();
            if (targetClass == null) {
                throw new AopConfigException("TargetSource cannot determine target class: " +
                        "Either an interface or a target is required for proxy creation.");
            }
            //如果目标类型是接口，或者是Proxy的子类，那么可以用JDK动态代理
            if (targetClass.isInterface() || Proxy.isProxyClass(targetClass)) {
                return new JdkDynamicAopProxy(config);
            }
            //否则只能用CGlib动态代理
            return new ObjenesisCglibAopProxy(config);
        }
        else {
            return new JdkDynamicAopProxy(config);
        }
    }
```

接下来分别讨论JdkDynamicAopProxy与ObjenesisCglibAopProxy

### 2.3.1 JdkDynamicAopProxy

JdkDynamicAopProxy利用JDK动态代理创建代理类

首先，来看一下JdkDynamicAopProxy.getProxy方法。该方法主要逻辑如下

1. 通过AopProxyUtils辅助类获取代理接口集合，这些信息保存在了AdvisedSupport类中
1. 在接口集合中查找是否包含了equal、hashCode方法，如果不包含这两个方法，那么代理类默认不拦截这两个方法

```java
    public Object getProxy() {
        return getProxy(ClassUtils.getDefaultClassLoader());
    }

    public Object getProxy(ClassLoader classLoader) {
        if (logger.isDebugEnabled()) {
            logger.debug("Creating JDK dynamic proxy: target source is " + this.advised.getTargetSource());
        }
        //获取代理接口
        Class<?>[] proxiedInterfaces = AopProxyUtils.completeProxiedInterfaces(this.advised, true);
        //查找在这些接口中是否包含equal、hashCode方法
        findDefinedEqualsAndHashCodeMethods(proxiedInterfaces);
        //利用JDK动态代理API创建代理实例
        return Proxy.newProxyInstance(classLoader, proxiedInterfaces, this);
    }
```

注意到，JdkDynamicAopProxy本身实现了InvocationHandler接口，因此我们重点关注invoke方法，该方法的关键逻辑如下

1. 获取拦截器链
1. 创建织入点（ReflectiveMethodInvocation），并触发织入动作（process方法）

```java
public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        //织入点
        MethodInvocation invocation;
        Object oldProxy = null;
        boolean setProxyContext = false;

        TargetSource targetSource = this.advised.targetSource;
        Class<?> targetClass = null;
        Object target = null;

        try {
            //如果代理接口中不包含equals方法，那么直接透传，不织入增强
            if (!this.equalsDefined && AopUtils.isEqualsMethod(method)) {
                //The target does not implement the equals(Object) method itself.
                return equals(args[0]);
            }
            //如果代理接口中不包含hashCode方法，那么直接透传，不织入增强
            else if (!this.hashCodeDefined && AopUtils.isHashCodeMethod(method)) {
                //The target does not implement the hashCode() method itself.
                return hashCode();
            }
            else if (method.getDeclaringClass() == DecoratingProxy.class) {
                //There is only getDecoratedClass() declared -> dispatch to proxy config.
                return AopProxyUtils.ultimateTargetClass(this.advised);
            }
            else if (!this.advised.opaque && method.getDeclaringClass().isInterface() &&
                    method.getDeclaringClass().isAssignableFrom(Advised.class)) {
                //Service invocations on ProxyConfig with the proxy config...
                return AopUtils.invokeJoinpointUsingReflection(this.advised, method, args);
            }

            Object retVal;

            if (this.advised.exposeProxy) {
                //Make invocation available if necessary.
                oldProxy = AopContext.setCurrentProxy(proxy);
                setProxyContext = true;
            }

            //May be null. Get as late as possible to minimize the time we "own" the target,
            //in case it comes from a pool.
            target = targetSource.getTarget();
            if (target != null) {
                targetClass = target.getClass();
            }

            //Get the interception chain for this method.
            //获取拦截器链
            List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);

            //Check whether we have any advice. If we don't, we can fallback on direct
            //reflective invocation of the target, and avoid creating a MethodInvocation.
            if (chain.isEmpty()) {
                //We can skip creating a MethodInvocation: just invoke the target directly
                //Note that the final invoker must be an InvokerInterceptor so we know it does
                //nothing but a reflective operation on the target, and no hot swapping or fancy proxying.
                Object[] argsToUse = AopProxyUtils.adaptArgumentsIfNecessary(method, args);
                //由于拦截器链是空的，直接反射调用目标方法
                retVal = AopUtils.invokeJoinpointUsingReflection(target, method, argsToUse);
            }
            else {
                //We need to create a method invocation...
                //创建一个方法织入点，用于触发拦截器的调用链，该织入点包含了触发目标方法的所有内容，包括对象本身，方法参数等
                invocation = new ReflectiveMethodInvocation(proxy, target, method, args, targetClass, chain);
                //Proceed to the joinpoint through the interceptor chain.
                //触发拦截器的调用链
                //目标对象的目标方法将会在proceed内部调用
                retVal = invocation.proceed();
            }

            //Massage return value if necessary.
            Class<?> returnType = method.getReturnType();
            if (retVal != null && retVal == target &&
                    returnType != Object.class && returnType.isInstance(proxy) &&
                    !RawTargetAccess.class.isAssignableFrom(method.getDeclaringClass())) {
                //Special case: it returned "this" and the return type of the method
                //is type-compatible. Note that we can't help if the target sets
                //a reference to itself in another returned object.
                retVal = proxy;
            }
            else if (retVal == null && returnType != Void.TYPE && returnType.isPrimitive()) {
                throw new AopInvocationException(
                        "Null return value from advice does not match primitive return type for: " + method);
            }
            return retVal;
        }
        finally {
            if (target != null && !targetSource.isStatic()) {
                //Must have come from TargetSource.
                targetSource.releaseTarget(target);
            }
            if (setProxyContext) {
                //Restore old proxy.
                AopContext.setCurrentProxy(oldProxy);
            }
        }
    }
```

接下来，看一下AdvisedSupport.getInterceptorsAndDynamicInterceptionAdvice方法。**该方法的逻辑很简单，将每个方法的拦截器链保存在缓存中，若不命中，则调用AdvisorChainFactory.getInterceptorsAndDynamicInterceptionAdvice方法来初始化**

```java
    public List<Object> getInterceptorsAndDynamicInterceptionAdvice(Method method, Class<?> targetClass) {
        MethodCacheKey cacheKey = new MethodCacheKey(method);
        List<Object> cached = this.methodCache.get(cacheKey);
        if (cached == null) {
            cached = this.advisorChainFactory.getInterceptorsAndDynamicInterceptionAdvice(
                    this, method, targetClass);
            this.methodCache.put(cacheKey, cached);
        }
        return cached;
    }
```

该方法利用AdvisorChainFactory接口的实例来创建拦截器链。AdvisorChainFactory接口的继承体系也很简单，只有一个默认实现DefaultAdvisorChainFactory

```java
    public List<Object> getInterceptorsAndDynamicInterceptionAdvice(
            Advised config, Method method, Class<?> targetClass) {

        //This is somewhat tricky... We have to process introductions first,
        //but we need to preserve order in the ultimate list.
        List<Object> interceptorList = new ArrayList<Object>(config.getAdvisors().length);
        Class<?> actualClass = (targetClass != null ? targetClass : method.getDeclaringClass());
        boolean hasIntroductions = hasMatchingIntroductions(config, actualClass);

        //获取Advisor适配器的注册器
        AdvisorAdapterRegistry registry = GlobalAdvisorAdapterRegistry.getInstance();

        for (Advisor advisor : config.getAdvisors()) {
            //Advisor分为两类，一类是PointcutAdvisor
            if (advisor instanceof PointcutAdvisor) {
                //Add it conditionally.
                PointcutAdvisor pointcutAdvisor = (PointcutAdvisor) advisor;
                //判断当前类是否匹配该Pointcut
                if (config.isPreFiltered() || pointcutAdvisor.getPointcut().getClassFilter().matches(actualClass)) {
                    //通过适配器注册器将advisor转化成拦截器
                    MethodInterceptor[] interceptors = registry.getInterceptors(advisor);
                    MethodMatcher mm = pointcutAdvisor.getPointcut().getMethodMatcher();
                    //判断当前方法是否匹配该Pointcut
                    if (MethodMatchers.matches(mm, method, actualClass, hasIntroductions)) {
                        if (mm.isRuntime()) {
                            //Creating a new object instance in the getInterceptors() method
                            //isn't a problem as we normally cache created chains.
                            for (MethodInterceptor interceptor : interceptors) {
                                interceptorList.add(new InterceptorAndDynamicMethodMatcher(interceptor, mm));
                            }
                        }
                        else {
                            interceptorList.addAll(Arrays.asList(interceptors));
                        }
                    }
                }
            }
            //另一类Advisor就是IntroductionAdvisor
            else if (advisor instanceof IntroductionAdvisor) {
                IntroductionAdvisor ia = (IntroductionAdvisor) advisor;
                //判断当前类是否匹配IntroductionAdvisor
                if (config.isPreFiltered() || ia.getClassFilter().matches(actualClass)) {
                    Interceptor[] interceptors = registry.getInterceptors(advisor);
                    interceptorList.addAll(Arrays.asList(interceptors));
                }
            }
            //其他Advisor
            else {
                Interceptor[] interceptors = registry.getInterceptors(advisor);
                interceptorList.addAll(Arrays.asList(interceptors));
            }
        }

        return interceptorList;
    }
```

在上述方法中，利用了AdvisorAdapterRegistry.getInterceptors将不同类型的Advice转化成MethodInterceptor。之前介绍过AdvisorAdapterRegistry的唯一实现就是DefaultAdvisorAdapterRegistry，其实例以单例的方式被GlobalAdvisorAdapterRegistry持有。下面来看一下AdvisorAdapterRegistry.getInterceptors方法的源码，该方法的主要逻辑如下

1. 从Advisor中取出Advice
1. 若Advice的实际类型是MethodInterceptor，直接添加到集合中
1. 否则，使用相应的适配器（Adapter）将其封装成MethodInterceptor。例如MethodBeforeAdviceAdapter可以将MethodBeforeAdvice封装成MethodInterceptor

```java
    public MethodInterceptor[] getInterceptors(Advisor advisor) throws UnknownAdviceTypeException {
        List<MethodInterceptor> interceptors = new ArrayList<MethodInterceptor>(3);
        //取出Advice
        Advice advice = advisor.getAdvice();
        if (advice instanceof MethodInterceptor) {
            interceptors.add((MethodInterceptor) advice);
        }
        for (AdvisorAdapter adapter : this.adapters) {
            if (adapter.supportsAdvice(advice)) {
                //进行适配，将advice封装成MethodInterceptor
                interceptors.add(adapter.getInterceptor(advisor));
            }
        }
        if (interceptors.isEmpty()) {
            throw new UnknownAdviceTypeException(advisor.getAdvice());
        }
        return interceptors.toArray(new MethodInterceptor[interceptors.size()]);
    }
```

以MethodBeforeAdviceAdapter为例，我们来看一下，适配过程是怎样的

```java
class MethodBeforeAdviceAdapter implements AdvisorAdapter, Serializable {

    @Override
    public boolean supportsAdvice(Advice advice) {
        return (advice instanceof MethodBeforeAdvice);
    }

    @Override
    public MethodInterceptor getInterceptor(Advisor advisor) {
        MethodBeforeAdvice advice = (MethodBeforeAdvice) advisor.getAdvice();
        return new MethodBeforeAdviceInterceptor(advice);
    }
}

public class MethodBeforeAdviceInterceptor implements MethodInterceptor, Serializable {

    private MethodBeforeAdvice advice;

    public MethodBeforeAdviceInterceptor(MethodBeforeAdvice advice) {
        Assert.notNull(advice, "Advice must not be null");
        this.advice = advice;
    }

    @Override
    //这里将before方法包装在invoke方法之中
    public Object invoke(MethodInvocation mi) throws Throwable {
        this.advice.before(mi.getMethod(), mi.getArguments(), mi.getThis() );
        //必须调用MethodInvocation.proceed方法，继续推动拦截器链的织入
        return mi.proceed();
    }
}

```

我们接着回到JdkDynamicAopProxy的invoke方法当中，来看一下ReflectiveMethodInvocation这个类。**这个类实现了ProxyMethodInvocation接口，其继承链路的起点是Joinpoint，ReflectiveMethodInvocation就是一个连接点（增强织入点）。且包含了触发目标对象的目标方法所需的所有条件，目标对象的目标方法的触发是交由该对象来完成的，其最核心的方法就是proceed**

```java
    protected final Object proxy;

    protected final Object target;

    protected final Method method;

    protected Object[] arguments;

    private final Class<?> targetClass;

    public Object proceed() throws Throwable {
        //    We start with an index of -1 and increment early.
        //如果拦截器已经调用完毕了，那么触发目标方法
        if (this.currentInterceptorIndex == this.interceptorsAndDynamicMethodMatchers.size() - 1) {
            return invokeJoinpoint();
        }

        //获取下一个拦截器
        Object interceptorOrInterceptionAdvice =
                this.interceptorsAndDynamicMethodMatchers.get(++this.currentInterceptorIndex);
        //这个类就是之前在获取拦截器链的时候封装Method以及MethodMatcher的类
        if (interceptorOrInterceptionAdvice instanceof InterceptorAndDynamicMethodMatcher) {
            //Evaluate dynamic method matcher here: static part will already have
            //been evaluated and found to match.
            InterceptorAndDynamicMethodMatcher dm =
                    (InterceptorAndDynamicMethodMatcher) interceptorOrInterceptionAdvice;
            //如果匹配当前方法，则触发拦截器调用
            if (dm.methodMatcher.matches(this.method, this.targetClass, this.arguments)) {
                return dm.interceptor.invoke(this);
            }
            else {
                //Dynamic matching failed.
                //Skip this interceptor and invoke the next in the chain.
                //否则跳过当前拦截器，继续proceed方法
                return proceed();
            }
        }
        else {
            //It's an interceptor, so we just invoke it: The pointcut will have
            //been evaluated statically before this object was constructed.
            //否则就是MethodInterceptor接口的实现类，直接触发拦截器即可
            return ((MethodInterceptor) interceptorOrInterceptionAdvice).invoke(this);
        }
    }

    protected Object invokeJoinpoint() throws Throwable {
        //这里就是直接利用反射调用目标方法
        return AopUtils.invokeJoinpointUsingReflection(this.target, this.method, this.arguments);
    }
```

辅助方法AopUtils.invokeJoinpointUsingReflection如下，该方法逻辑很简单，就是利用反射触发目标方法

```java
public static Object invokeJoinpointUsingReflection(Object target, Method method, Object[] args)
            throws Throwable {

        //Use reflection to invoke the method.
        try {
            //如果方法不可访问，那么设置为可访问
            ReflectionUtils.makeAccessible(method);
            //直接反射调用
            return method.invoke(target, args);
        }
        catch (InvocationTargetException ex) {
            //Invoked method threw a checked exception.
            //We must rethrow it. The client won't see the interceptor.
            throw ex.getTargetException();
        }
        catch (IllegalArgumentException ex) {
            throw new AopInvocationException("AOP configuration seems to be invalid: tried calling method [" +
                    method + "] on target [" + target + "]", ex);
        }
        catch (IllegalAccessException ex) {
            throw new AopInvocationException("Could not access method [" + method + "]", ex);
        }
    }
```

至此JDK动态代理分析完毕

### 2.3.2 ObjenesisCglibAopProxy

ObjenesisCglibAopProxy利用Cglib动态代理创建代理类，且ObjenesisCglibAopProxy继承了CglibAopProxy并集成了Objenesis框架，支持绕开构造函数创建一个Java对象，降低了Cglib代理必须实现默认构造方法的限制

我们首先来看CglibAopProxy.getProxy方法，该方法的主要逻辑如下

1. 创建并初始化Enhancer对象
1. 获取Callback
1. 创建代理对象

```java
    public Object getProxy() {
        return getProxy(null);
    }

    @Override
    public Object getProxy(ClassLoader classLoader) {
        if (logger.isDebugEnabled()) {
            logger.debug("Creating CGLIB proxy: target source is " + this.advised.getTargetSource());
        }

        try {
            Class<?> rootClass = this.advised.getTargetClass();
            Assert.state(rootClass != null, "Target class must be available for creating a CGLIB proxy");

            Class<?> proxySuperClass = rootClass;
            if (ClassUtils.isCglibProxyClass(rootClass)) {
                proxySuperClass = rootClass.getSuperclass();
                Class<?>[] additionalInterfaces = rootClass.getInterfaces();
                for (Class<?> additionalInterface : additionalInterfaces) {
                    this.advised.addInterface(additionalInterface);
                }
            }

            //Validate the class, writing log messages as necessary.
            validateClassIfNecessary(proxySuperClass, classLoader);

            //Configure CGLIB Enhancer...
            Enhancer enhancer = createEnhancer();
            if (classLoader != null) {
                enhancer.setClassLoader(classLoader);
                if (classLoader instanceof SmartClassLoader &&
                        ((SmartClassLoader) classLoader).isClassReloadable(proxySuperClass)) {
                    enhancer.setUseCache(false);
                }
            }
            enhancer.setSuperclass(proxySuperClass);
            enhancer.setInterfaces(AopProxyUtils.completeProxiedInterfaces(this.advised));
            enhancer.setNamingPolicy(SpringNamingPolicy.INSTANCE);
            enhancer.setStrategy(new ClassLoaderAwareUndeclaredThrowableStrategy(classLoader));

            //获取回调逻辑
            Callback[] callbacks = getCallbacks(rootClass);
            Class<?>[] types = new Class<?>[callbacks.length];
            for (int x = 0; x < types.length; x++) {
                types[x] = callbacks[x].getClass();
            }
            //fixedInterceptorMap only populated at this point, after getCallbacks call above
            enhancer.setCallbackFilter(new ProxyCallbackFilter(
                    this.advised.getConfigurationOnlyCopy(), this.fixedInterceptorMap, this.fixedInterceptorOffset));
            enhancer.setCallbackTypes(types);

            //Generate the proxy class and create a proxy instance.
            //创建代理对象
            return createProxyClassAndInstance(enhancer, callbacks);
        }
        catch (CodeGenerationException ex) {
            throw new AopConfigException("Could not generate CGLIB subclass of class [" +
                    this.advised.getTargetClass() + "]: " +
                    "Common causes of this problem include using a final class or a non-visible class",
                    ex);
        }
        catch (IllegalArgumentException ex) {
            throw new AopConfigException("Could not generate CGLIB subclass of class [" +
                    this.advised.getTargetClass() + "]: " +
                    "Common causes of this problem include using a final class or a non-visible class",
                    ex);
        }
        catch (Throwable ex) {
            //TargetSource.getTarget() failed
            throw new AopConfigException("Unexpected AOP exception", ex);
        }
    }

```

我们先来看一下getCallbacks方法，该方法位于CglibAopProxy中。我们重点关注前半段逻辑（`Callback[] callbacks;`语句之前）

1. 创建DynamicAdvisedInterceptor的实例，增强织入的核心入口（Joinpoint）
1. 创建Callback集合

```java
    private Callback[] getCallbacks(Class<?> rootClass) throws Exception {
        //Parameters used for optimization choices...
        boolean exposeProxy = this.advised.isExposeProxy();
        boolean isFrozen = this.advised.isFrozen();
        boolean isStatic = this.advised.getTargetSource().isStatic();

        //Choose an "aop" interceptor (used for AOP calls).
        Callback aopInterceptor = new DynamicAdvisedInterceptor(this.advised);

        //Choose a "straight to target" interceptor. (used for calls that are
        //unadvised but can return this). May be required to expose the proxy.
        Callback targetInterceptor;
        if (exposeProxy) {
            targetInterceptor = isStatic ?
                    new StaticUnadvisedExposedInterceptor(this.advised.getTargetSource().getTarget()) :
                    new DynamicUnadvisedExposedInterceptor(this.advised.getTargetSource());
        }
        else {
            targetInterceptor = isStatic ?
                    new StaticUnadvisedInterceptor(this.advised.getTargetSource().getTarget()) :
                    new DynamicUnadvisedInterceptor(this.advised.getTargetSource());
        }

        //Choose a "direct to target" dispatcher (used for
        //unadvised calls to static targets that cannot return this).
        Callback targetDispatcher = isStatic ?
                new StaticDispatcher(this.advised.getTargetSource().getTarget()) : new SerializableNoOp();

        Callback[] mainCallbacks = new Callback[] {
                aopInterceptor,  //for normal advice
                targetInterceptor,  //invoke target without considering advice, if optimized
                new SerializableNoOp(),  //no override for methods mapped to this
                targetDispatcher, this.advisedDispatcher,
                new EqualsInterceptor(this.advised),
                new HashCodeInterceptor(this.advised)
        };

        Callback[] callbacks;

        //If the target is a static one and the advice chain is frozen,
        //then we can make some optimizations by sending the AOP calls
        //direct to the target using the fixed chain for that method.
        if (isStatic && isFrozen) {
            Method[] methods = rootClass.getMethods();
            Callback[] fixedCallbacks = new Callback[methods.length];
            this.fixedInterceptorMap = new HashMap<String, Integer>(methods.length);

            //TODO: small memory optimization here (can skip creation for methods with no advice)
            for (int x = 0; x < methods.length; x++) {
                //获取拦截器调用链
                List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(methods[x], rootClass);
                fixedCallbacks[x] = new FixedChainStaticTargetInterceptor(
                        chain, this.advised.getTargetSource().getTarget(), this.advised.getTargetClass());
                this.fixedInterceptorMap.put(methods[x].toString(), x);
            }

            //Now copy both the callbacks from mainCallbacks
            //and fixedCallbacks into the callbacks array.
            callbacks = new Callback[mainCallbacks.length + fixedCallbacks.length];
            System.arraycopy(mainCallbacks, 0, callbacks, 0, mainCallbacks.length);
            System.arraycopy(fixedCallbacks, 0, callbacks, mainCallbacks.length, fixedCallbacks.length);
            this.fixedInterceptorOffset = mainCallbacks.length;
        }
        else {
            callbacks = mainCallbacks;
        }
        return callbacks;
    }
```

DynamicAdvisedInterceptor是CglibAopProxy中的静态内部类，它继承了org.springframework.cglib.proxy.MethodInterceptor（注意不是Aopliance的MethodInterceptor）。我们重点关注intercept接口方法的实现，其主要逻辑如下

1. 获取拦截器调用链（与JDK方式一致）
1. 通过CglibMethodInvocation（Joinpont的实现）来织入拦截器调用链

```java
        public Object intercept(Object proxy, Method method, Object[] args, MethodProxy methodProxy) throws Throwable {
            Object oldProxy = null;
            boolean setProxyContext = false;
            Class<?> targetClass = null;
            Object target = null;
            try {
                if (this.advised.exposeProxy) {
                    //Make invocation available if necessary.
                    oldProxy = AopContext.setCurrentProxy(proxy);
                    setProxyContext = true;
                }
                //May be null. Get as late as possible to minimize the time we
                //"own" the target, in case it comes from a pool...
                target = getTarget();
                if (target != null) {
                    targetClass = target.getClass();
                }

                //获取拦截器调用链
                List<Object> chain = this.advised.getInterceptorsAndDynamicInterceptionAdvice(method, targetClass);
                Object retVal;
                //Check whether we only have one InvokerInterceptor: that is,
                //no real advice, but just reflective invocation of the target.
                //当拦截器调用链为空时，不织入增强，直接调用目标方法
                if (chain.isEmpty() && Modifier.isPublic(method.getModifiers())) {
                    //We can skip creating a MethodInvocation: just invoke the target directly.
                    //Note that the final invoker must be an InvokerInterceptor, so we know
                    //it does nothing but a reflective operation on the target, and no hot
                    //swapping or fancy proxying.
                    Object[] argsToUse = AopProxyUtils.adaptArgumentsIfNecessary(method, args);
                    retVal = methodProxy.invoke(target, argsToUse);
                }
                else {
                    //We need to create a method invocation...
                    //否则创建一个Joinpoint来织入增强
                    retVal = new CglibMethodInvocation(proxy, target, method, args, targetClass, chain, methodProxy).proceed();
                }
                retVal = processReturnType(proxy, target, method, retVal);
                return retVal;
            }
            finally {
                if (target != null) {
                    releaseTarget(target);
                }
                if (setProxyContext) {
                    //Restore old proxy.
                    AopContext.setCurrentProxy(oldProxy);
                }
            }
        }
```

CglibMethodInvocation继承了ReflectiveMethodInvocation，并针对Cglib进行了改造。proceed方法沿用ReflectiveMethodInvocation中的实现，上面已经分析过，这里不再赘述

```java
    private static class CglibMethodInvocation extends ReflectiveMethodInvocation {

        private final MethodProxy methodProxy;

        private final boolean publicMethod;

        public CglibMethodInvocation(Object proxy, Object target, Method method, Object[] arguments,
                Class<?> targetClass, List<Object> interceptorsAndDynamicMethodMatchers, MethodProxy methodProxy) {

            //调用父类ReflectiveMethodInvocation的构造方法，持有这些参数
            super(proxy, target, method, arguments, targetClass, interceptorsAndDynamicMethodMatchers);
            this.methodProxy = methodProxy;
            this.publicMethod = Modifier.isPublic(method.getModifiers());
        }

        //针对Cglib改造一下invokeJoinpoint方法
        @Override
        protected Object invokeJoinpoint() throws Throwable {
            if (this.publicMethod) {
                return this.methodProxy.invoke(this.target, this.arguments);
            }
            else {
                return super.invokeJoinpoint();
            }
        }
    }
```

接着，回到CglibAopProxy.getProxy方法中，再看createProxyClassAndInstance方法，ObjenesisCglibAopProxy重写了该方法

```java
    protected Object createProxyClassAndInstance(Enhancer enhancer, Callback[] callbacks) {
        //创建代理类
        Class<?> proxyClass = enhancer.createClass();
        Object proxyInstance = null;

        //尝试用Objenesis创建对象
        if (objenesis.isWorthTrying()) {
            try {
                proxyInstance = objenesis.newInstance(proxyClass, enhancer.getUseCache());
            }
            catch (Throwable ex) {
                logger.debug("Unable to instantiate proxy using Objenesis, " +
                        "falling back to regular proxy construction", ex);
            }
        }

        //如果Objenesis创建对象失败，再用普通方式创建对象（调用构造方法）
        if (proxyInstance == null) {
            //Regular instantiation via default constructor...
            try {
                proxyInstance = (this.constructorArgs != null ?
                        proxyClass.getConstructor(this.constructorArgTypes).newInstance(this.constructorArgs) :
                        proxyClass.newInstance());
            }
            catch (Throwable ex) {
                throw new AopConfigException("Unable to instantiate proxy using Objenesis, " +
                        "and regular proxy instantiation via default constructor fails as well", ex);
            }
        }

        ((Factory) proxyInstance).setCallbacks(callbacks);
        return proxyInstance;
    }
```

至此Cglib动态代理分析完毕

# 3 参考

* [Spring AOP: What's the difference between JoinPoint and PointCut?](https://stackoverflow.com/questions/15447397/spring-aop-whats-the-difference-between-joinpoint-and-pointcut)
* [What is the difference between Advisor and Aspect in AOP?](https://stackoverflow.com/questions/25092302/what-is-the-difference-between-advisor-and-aspect-in-aop)
* [Spring源码分析----AOP概念(Advice,Pointcut,Advisor)和AOP的设计与实现](http://blog.csdn.net/oChangWen/article/details/57428046)
* 《Spring 技术内幕》
