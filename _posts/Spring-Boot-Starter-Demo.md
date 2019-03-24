---
title: Spring-Boot-Starter-Demo
date: 2018-12-24 11:41:19
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 条件注解

## 1.1 Class Conditions

1. `@ConditionalOnClass`：`classpath`中包含指定类时，包含配置
1. `@ConditionalOnMissingClass`：`classpath`中不包含指定类时，包含配置
* 其中`value`属性填写的是真实的类（Class对象），`name`属性，填写的是类名

## 1.2 Bean Conditions

1. `@ConditionalOnBean`：`ApplicationContext`中包含指定`Bean`时，包含配置
1. `@ConditionalOnMissingBean`：`ApplicationContext`中不包含指定`Bean`时，包含配置
* 其中`value`属性按类型匹配`Bean`，`name`属性按名字匹配`Bean`
* 条件是否成立，只取决于Spring在处理注解时的`ApplicationContext`
* 如果`@ConditionalOnBean`和`@ConditionalOnMissingBean`标记在类上，且类中无一条件匹配，那么类上标记的`@Configuration`将会被忽略（换言之，该类本身不会生成`Bean`）

## 1.3 Property Conditions

1. `@ConditionalOnProperty`：允许基于`Spring Environment`属性包含配置。使用`prefix`和`name`属性指定应检查的属性。默认情况下，匹配存在且不等于`false`的任何属性。您还可以使用`havingValue`和`matchIfMissing`属性创建更高级的检查

## 1.4 Resource Conditions

1. `@ConditionalOnResource`：允许存在特定资源时包含配置。可以使用常用的`Spring`约定来指定资源，例如：`file:/home/user/test.dat`

## 1.5 Web Application Conditions

1. `@ConditionalOnWebApplication`：当应用是`Web Application`时，包含配置
1. `@ConditionalOnNotWebApplication`：当应用不是`Web Application`时，包含配置
1. `Web Application`是指包含了`WebApplicationContext`，或`StandardServletEnvironment`的应用

## 1.6 SpEL Expression Conditions

1. `@ConditionalOnExpression`：基于`SpEL expression`的结果，决定是否包含配置

## 1.7 Starter的结构

一般而言，一个`Spring-Boot-Starter`应用，一般包含如下两个模块：

1. `autoconfigure module`：用于包含配置代码
1. `starter module`：依赖于`autoconfigure module`，以及其他应用的依赖
* 我们也可以将以上两个模块合成一个模块

# 2 META-INF/spring.factories

一些三方项目如何与Spring集成，并且无需任何配置就可以自动注入到我们应用的上下文中？答案就是：`基于约定`。
`META-INF/spring.factories`是`spring-autoconfig`的核心配置文件

1. `org.springframework.boot.diagnostics.FailureAnalyzer`
1. `org.springframework.boot.autoconfigure.EnableAutoConfiguration`
1. `org.springframework.context.ApplicationContextInitializer`
1. `org.springframework.context.ApplicationListener`
1. `org.springframework.boot.env.EnvironmentPostProcessor`
1. `org.springframework.boot.autoconfigure.AutoConfigurationImportListener`
1. `org.springframework.boot.autoconfigure.AutoConfigurationImportFilter`
1. `org.springframework.boot.autoconfigure.template.TemplateAvailabilityProvider`
1. `org.springframework.test.context.TestExecutionListener`
1. `org.springframework.test.context.ContextCustomizerFactory`
1. `org.springframework.boot.env.PropertySourceLoader`
1. `org.springframework.boot.SpringApplicationRunListener`
1. `org.springframework.boot.diagnostics.FailureAnalysisReporter`

# 3 todo

ConfigurationProperties 属性必须有get/set方法

# 4 参考

* [Spring Boot 制作一个自己的 Starter](https://blog.csdn.net/wo18237095579/article/details/81197245)
* [Spring-boot实例学习之 自定义starter](https://blog.csdn.net/Revivedsun/article/details/77151899)
* [Spring Boot Understanding Auto-configured Beans](https://docs.spring.io/spring-boot/docs/2.1.1.RELEASE/reference/htmlsingle/#boot-features-developing-auto-configuration)
* [Spring Boot 'How-to' guides](https://docs.spring.io/spring-boot/docs/2.1.1.RELEASE/reference/htmlsingle/#howto)
