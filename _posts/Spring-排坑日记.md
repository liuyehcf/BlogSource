---
title: Spring-排坑日记
date: 2018-01-29 22:14:29
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

# 1 水坑1-注解扫描路径

情景还原：我在某个Service中需要实现一段逻辑，需要使用Pair来存放两个对象，于是我自定义了下面这个静态内部类

```Java
@Service
public class MyService{

    // ... 业务逻辑代码 ...

    private static final class Pair<K, V> {
        private final K key;
        private final V value;

        public Pair(K key, V value) {
            this.key = key;
            this.value = value;
        }

        public K getKey() {
            return key;
        }

        public V getValue() {
            return value;
        }
    }
}
```

启动时抛出了如下异常

```
2018-01-29 13:43:15.917 [localhost-startStop-1] ERROR o.s.web.servlet.DispatcherServlet - Context initialization failed
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'myService.Pair' defined in URL

...
Instantiation of bean failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found; nested exception is java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()
  at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.instantiateBean
```

注意到没有，关键错误信息是

1. `Error creating bean with name 'myService.Pair'`
1. `Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found`
1. `java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()`

这意味着，Spring为我的静态内部类Pair创建了单例，并且通过反射调用默认构造函数，由于我没有定义无参构造函数，于是报错

__那么，问题来了，我根本就没有配置过这个Pair啊！！！__

纠结了一天之后，发现Spring配置文件中的一段配置，如下

```xml
    <context:component-scan base-package="org.liuyehcf.service">
        <context:include-filter type="regex"
                                expression="org\.liuyehcf\.service\..*"/>
    </context:component-scan>
```

__就是这段配置让所有匹配正则表达式的类都被Spring扫描到，并且为之创建单例！！！__

__DONE__

# 2 水坑2-SpringBoot非Web应用

情景还原

1. SpringBoot应用
1. 非Web应用（即没有`org.springframework.boot:spring-boot-starter-web`依赖项）

启动后出现如下异常信息

```Java
Caused by: org.springframework.context.ApplicationContextException: Unable to start EmbeddedWebApplicationContext due to missing EmbeddedServletContainerFactorybean.
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.getEmbeddedServletContainerFactory(EmbeddedWebApplicationContext.java:189)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.createEmbeddedServletContainer(EmbeddedWebApplicationContext.java:162)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.onRefresh(EmbeddedWebApplicationContext.java:134)
  ... 16 more
```

分析：

1. 在普通的Java-Web应用中，Spring容器分为父子容器，其中子容器仅包含MVC层的Bean，父容器包含了其他所有的Bean
1. 出现异常的原因是由于Classpath中包含了`servlet-api`相关class文件，因此Spring boot认为这是一个web application。去掉servlet-api的maven依赖即可

`mvn dependency:tree`查看依赖树，确实发现有servlet-api的依赖项
