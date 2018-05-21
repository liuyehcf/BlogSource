---
title: Spring-Overview
date: 2018-01-04 22:45:19
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 Overview

![fig1](/images/Spring-Overview/fig1.png)

# 2 Core Container

__核心容器（Core Container）由`spring-core`、`spring-beans`、`spring-context`、`spring-context-support`、`spring-expression`5个模块构成__

其中，`spring-core`和`spring-beans`模块是Spring框架的基本部分，提供了`IoC`以及`依赖注入`等核心功能，BeanFactory采用了工厂模式，消除了应用对编程式单例的需求，同时，将对象创建与依赖注入进行解耦

`spring-context`模块建立在`spring-core`和`spring-beans`模块构成的坚实基础之上，它提__供了一种框架式的对象访问方式__（例如JNDI registry）。`spring-context`模块继承了`spring-beans`模块的种种特性，同时，并增加了对__国际化__（internationalization，例如使用资源包），__事件传播__（event propagation），__资源加载__（resource loading）以及__上下文透明创建__（例如Servlet容器）的支持。__`ApplicationContext`__接口是`spring-context`模块的核心。此外，`spring-context-support`模块提供了__集成其他三方库到Spring应用上下文__的能力，例如EhCache，Guava，JCache，邮件（JavaMail），调度（CommonJ，Quartz）和模板引擎（FreeMarker，JasperReports，Velocity）等等

`spring-expression`模块__提供了一种在运行时查询以及操作对象图的表达式语言（Expression language）__。它是JSP 2.1规范中规定的统一表达式语言（unified EL）的扩展。该语言支持属性值的存取（getter/setter）、方法调用、数组访问、收集和索引、逻辑和算数运算符、命名变量、从Spring的IoC容器中检索对象

## 2.1 Dependency

### 2.1.1 spring-core

```
spring-core
```

### 2.1.2 spring-beans

```
spring-beans
    └── spring-core
```

### 2.1.3 spring-expression

```
spring-expression
    └── spring-core
```

### 2.1.4 spring-context

```
spring-context
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    └── spring-aop
```

### 2.1.5 spring-context-support

```
spring-context-support
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    └── spring-context
```

# 3 AOP and Instrumentation

`spring-aop`模块__提供了一种兼容AOP联盟面向切面编程接口的实现__，它允许我们定义方法拦截器（MethodInterceptor）以及切点（Pointcut）来解耦本应该进行功能拆分的业务代码。使用源码级（source-level）元数据功能，我们还可以将一些行为整合到代码中（Aspectj，我估计用的是JSR-269插入式注解API）

`spring-aspects`模块整合了AspectJ

The spring-instrument module provides class instrumentation support and classloader implementations to be used in certain application servers（不会翻译，嘻嘻）

`spring-instrument-tomcat`模块包含了Tomcat的Spring工具代理

## 3.1 Dependency

### 3.1.1 spring-aspects

```
spring-aspects
```

### 3.1.2 spring-aop

```
spring-aop
    ├── spring-core
    └── spring-beans
```

### 3.1.3 spring-instrument-tomcat

```
spring-instrument-tomcat
```

# 4 Messaging

Spring 4.x 新增了`spring-messaging`模块，在Spring的集成项目中抽象出了__消息模块__（例如Message、MessageChannel、MessageHandler等）__作为基于消息传递的应用程序的基础__。该模块还包含了一组用于将__消息映射到方法__的注解，__类似于基于Spring MVC注解的编程模式__

## 4.1 Dependency

### 4.1.1 spring-messaging

```
spring-messaging
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    └── spring-context
```

# 5 Data Access/Integration

__Data Access/Integration层由JDBC、ORM、OXM、JMS以及Transaction模块构成__

`spring-jdbc`模块提供了一个JDBC层的抽象，让我们从__单调乏味的JDBC编码以及解析数据库供应商特定的错误代码__中解放出来

`spring-tx`模块支持对POJO（Plain Old Java Object）的__编程式__以及__声明式__事务管理

`spring-orm`模块为流行的ORM（object-relational mapping）API的集成层，包括JPA、JDO以及Hibernate。利用`spring-orm`模块，我们可以将这些ORM框架与Spring提供的其他所有功能结合使用，例如声明式事务管理

`spring-oxm`模块为流行的OXM（object-xml mapping）框架提供一个抽象层，例如JAXB，Castor，XMLBeans，JiBX以及XStream

`spring-jms`模块（Java Messaging Service）提供了__生产和消费消息__的机制，在Spring 4.1之后，它集成了`spring-messaging`模块

## 5.1 Dependency

### 5.1.1 spring-tx

```
spring-tx
    ├── spring-core
    └── spring-beans
```

### 5.1.2 spring-jdbc

```
spring-jdbc
    ├── spring-core
    ├── spring-beans
    └── spring-tx
```

### 5.1.3 spring-orm

```
spring-orm
    ├── spring-core
    ├── spring-beans
    ├── spring-tx
    └── spring-jdbc
```

### 5.1.4 spring-oxm

```
spring-oxm
    ├── spring-core
    └── spring-beans
```

### 5.1.5 spring-jms

```
spring-jms
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    ├── spring-tx
    ├── spring-context
    └── spring-messaging
```

# 6 Web

Web层由`spring-web`、`spring-webmvc`、`spring-websocket`、`spring-webmvc-portlet`模块构成

`spring-web`模块提供了基本的面向Web的集成功能，例如使用Servlet监听器（listener）对IoC容器进行初始化以及面向Web的应用程序上下文。它还包含了一个HTTP客户端和Spring远程处理支持的Web相关部分

`spring-webmvc`模块包含了Spring MVC模型以及Restful Web Service的实现。Spring的MVC框架提供了域模型代码和Web表单之间的清晰分离，并且与Spring框架的所有其他功能集成在一起

`spring-webmvc-portlet`模块（也称为Web-Portlet模块）提供了在Portlet环境中使用的MVC实现，并镜像实现了基于Servlet的spring-webmvc模块的功能

## 6.1 Dependency

### 6.1.1 spring-web

```
spring-web
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    └── spring-context
```

### 6.1.2 spring-webmvc

```
spring-webmvc
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    ├── spring-context
    └── spring-web
```

### 6.1.3 spring-websocket

```
spring-websocket
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    ├── spring-context
    └── spring-web
```

### 6.1.4 spring-webmvc-portlet

```
spring-webmvc-portlet
    ├── spring-core
    ├── spring-beans
    ├── spring-expression
    ├── spring-aop
    ├── spring-context
    ├── spring-web
    └── spring-webmvc
```

# 7 Test

`spring-test`模块支持使用JUnit或TestNG框架对Spring组件进行单元测试和集成测试。它提供了一致的Spring ApplicationContexts加载和缓存这些上下文。它还提供了Mock对象，以隔离的方式测试代码

## 7.1 Dependency

### 7.1.1 spring-test

```
spring-test
    └── spring-core
```

# 8 参考

* [Introduction to the Spring Framework](https://docs.spring.io/spring/docs/4.3.13.RELEASE/spring-framework-reference/html/overview.html)
* [详解spring 每个jar的作用](http://www.cnblogs.com/leehongee/archive/2012/10/01/2709541.html)
