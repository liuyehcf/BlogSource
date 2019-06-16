---
title: Spring-Boot-Property
date: 2018-12-24 17:03:42
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

`Spring Boot`允许外部化配置，以便可以在不同的环境中使用相同的应用程序代码。可以使用属性文件，YAML文件，环境变量和命令行参数来外部化配置。可以使用`@Value`注解将属性值直接注入到`bean`中，通过`Spring`的`Environment`抽象访问，或者通过`@ConfigurationProperties`绑定到结构化对象

`Spring Boot`使用一个非常特殊的`PropertySource`顺序，旨在允许合理地覆盖属性值。具体的顺序如下（优先级从上到下降低）

1. 在主目录上配置全局属性值（当`devtools`处于活动状态时，`~/.spring-boot-devtools.properties`）
1. 测试中的`@TestPropertySource`注解
1. 测试中的属性。可在`@SpringBootTest`上使用，以及用于测试应用程序特定片段的测试注解
1. 命令行参数
1. `SPRING_APPLICATION_JSON`中的属性（嵌入在环境变量或系统属性中的内联JSON）
1. `ServletConfig`初始化参数
1. `ServletContext`初始化参数
1. 来自`java:comp/env`的`JNDI`属性
1. `Java`系统变量（`System.getProperties()`）
1. 操作系统环境变量
1. 来自`random.*`的随机变量
1. 二方/三方`jar`包中的属性配置文件（`application-{profile}.properties`或`YAML`）
1. 应用`jar`包中的属性配置文件（`application-{profile}.properties`或`YAML`）
1. 二方/三方`jar`包中的属性配置文件（`application.properties`或`YAML`）
1. 应用`jar`包中的属性配置文件（`application.properties`或`YAML`）
1. `@PropertySource`注解
1. 默认属性（`SpringApplication.setDefaultProperties`）

# 2 Spring-Boot启动时加载Property的位置

`SpringApplication.run`方法

```Java
    public ConfigurableApplicationContext run(String... args) {
    StopWatch stopWatch = new StopWatch();
    stopWatch.start();
    ConfigurableApplicationContext context = null;
    Collection<SpringBootExceptionReporter> exceptionReporters = new ArrayList<>();
    configureHeadlessProperty();
    SpringApplicationRunListeners listeners = getRunListeners(args);
    listeners.starting();
    try {
      ApplicationArguments applicationArguments = new DefaultApplicationArguments(
          args);
            
            /* ====== 此处进行属性值的加载 ====== */
      ConfigurableEnvironment environment = prepareEnvironment(listeners,
          applicationArguments);
      configureIgnoreBeanInfo(environment);
      Banner printedBanner = printBanner(environment);
      context = createApplicationContext();
      exceptionReporters = getSpringFactoriesInstances(
          SpringBootExceptionReporter.class,
          new Class[] { ConfigurableApplicationContext.class }, context);
      prepareContext(context, environment, listeners, applicationArguments,
          printedBanner);
      refreshContext(context);
      afterRefresh(context, applicationArguments);
      stopWatch.stop();
      if (this.logStartupInfo) {
        new StartupInfoLogger(this.mainApplicationClass)
            .logStarted(getApplicationLog(), stopWatch);
      }
      listeners.started(context);
      callRunners(context, applicationArguments);
    }
    catch (Throwable ex) {
      handleRunFailure(context, ex, exceptionReporters, listeners);
      throw new IllegalStateException(ex);
    }

    try {
      listeners.running(context);
    }
    catch (Throwable ex) {
      handleRunFailure(context, ex, exceptionReporters, null);
      throw new IllegalStateException(ex);
    }
    return context;
  }
```

`Spring`默认包含几个`EnvironmentPostProcessor`

1. `SystemEnvironmentPropertySourceEnvironmentPostProcessor`
1. `SpringApplicationJsonEnvironmentPostProcessor`
1. `CloudFoundryVcapEnvironmentPostProcessor`
1. `ConfigFileApplicationListener`: 负责`application.properties`配置文件的解析和加载工作

# 3 @ConfigurationProperties

__限制__

1. 注入的字段，必须包含set方法

# 4 参考

[Spring Boot Externalized Configuration](https://docs.spring.io/spring-boot/docs/2.1.1.RELEASE/reference/htmlsingle/#boot-features-external-config)

