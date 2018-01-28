---
title: Spring-模块简介
date: 2018-01-04 22:45:19
tags: 
- 摘录
categories: 
- Java
- Framework
- Spring
---

__目录__

<!-- toc -->
<!--more-->

# 1 spring-core

该模块包含Spring框架基本的核心工具类。Spring其它组件要都要使用到这个包里的类，是其它组件的基本核心

# 2 spring-bean

该模块是所有应用都要用到的，它包含访问配置文件、创建和管理bean以及进行Inversion of Control/Dependency Injection（IoC/DI）操作相关的所有类。如果应用只需基本的IoC/DI支持，引入`spring-core`及`spring-beans`模块就可以了

依赖的模块

* `spring-core`

# 3 spring-aop

该模块包含在应用中使用Spring的AOP特性时所需的类和源码级元数据支持。使用基于AOP的Spring特性，如声明型事务管理（Declarative Transaction Management），也要在应用里包含这个模块

依赖的模块

* `spring-beans`

# 4 spring-context

该模块为Spring核心提供了大量扩展。可以找到使用Spring ApplicationContext特性时所需的全部类，JDNI所需的全部类，instrumentation组件以及校验Validation方面的相关类

依赖的模块

* `spring-aop`

# 5 spring-dao

该模块包含Spring DAO、Spring Transaction进行数据访问的所有类。为了使用声明型事务支持，还需在自己的应用里包含`spring-aop`

依赖的模块

* `spring-context`

# 6 spring-jdbc

该模块包含对Spring 对JDBC数据访问进行封装的所有类

# 7 spring-support

该模块包含支持UI模版（Velocity，FreeMarker，JasperReports），邮件服务，脚本服务(JRuby)，缓存Cache（EHCache），任务计划Scheduling（uartz）方面的类

依赖的模块

* `spring-jdbc`

# 8 spring-web

该模块包含Web应用开发时，用到Spring框架时所需的核心类，包括自动载入Web Application Context特性的类、Struts与JSF集成类、文件上传的支持类、Filter类和大量工具辅助类

# 9 spring-webmvc

该模块包含Spring MVC框架相关的所有类。包括框架的Servlets，Web MVC框架，控制器和视图支持

# 10 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [详解spring 每个jar的作用](http://www.cnblogs.com/leehongee/archive/2012/10/01/2709541.html)
