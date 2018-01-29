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

# 1 包扫描路径

情景还原：我在某个Service中需要实现一段逻辑，需要使用Pair来存放两个对象，于是我自定义了下面这个静态内部类类

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
