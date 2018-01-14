---
title: Logback-简介
date: 2018-01-12 20:50:17
tags: 
- 摘录
categories: 
- Java
- Framework
- Logback
---

__目录__

<!-- toc -->
<!--more-->

# 1 配置文件

根节点是`<configuration>`，可包含0个或多个`<appender>`，0个或多个`<logger>`，最多一个`<root>`

## 1.1 `<logger>`

在配置文件中，logger的配置在
`<logger>`标签中配置，`<logger>`标签只有一个属性是一定要的，那就是name，除了name属性，还有level属性，additivity属性可以配置，不过它们是可选的

level的取值可以是`TRACE, DEBUG, INFO, WARN, ERROR, ALL, OFF, INHERITED, NULL`，其中INHERITED和NULL的作用是一样的，并不是不打印任何日志，而是强制这个logger必须从其父辈继承一个日志级别

additivity的取值是一个布尔值，true或者false

* false：表示只用当前logger的appender-ref。
* true：表示当前logger的appender-ref和rootLogger的appender-ref都有效

`<logger>`标签下只有一种元素，那就是`<appender-ref>`，可以有0个或多个，意味着绑定到这个logger上的Appender

## 1.2 `<root>`

`<root>`标签和`<logger>`标签的配置类似，只不过`<root>`标签只允许一个属性，那就是level属性，并且它的取值范围只能取`TRACE, DEBUG, INFO, WARN, ERROR, ALL, OFF`。
`<root>`标签下允许有0个或者多个 `<appender-ref>`

## 1.3 `<appender>`

`<appender>`标签有两个必须填的属性，分别是name和class，class用来指定具体的实现类。`<appender>`标签下可以包含至多一个`<layout>`，0个或多个`<encoder>`，0个或多个`<filter>`，除了这些标签外，`<appender>`下可以包含一些类似于JavaBean的配置标签。

`<layout>`包含了一个必须填写的属性class，用来指定具体的实现类，不过，如果该实现类的类型是PatternLayout时，那么可以不用填写。`<layout`>也和`<appender>`一样，可以包含类似于JavaBean的配置标签。

`<encoder>`标签包含一个必须填写的属性class，用来指定具体的实现类，如果该类的类型是`PatternLayoutEncoder`，那么class属性可以不填。

## 1.4 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- Logback Configuration. -->
<configuration debug="true">

    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <target>System.out</target>
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="ch.qos.logback.classic.PatternLayout">
                <pattern><![CDATA[
			 [%d{yyyy-MM-dd HH:mm:ss}]  %-5level %logger{0} - %m%n
            ]]></pattern>
            </layout>
        </encoder>
    </appender>

    <appender name="STDERR" class="ch.qos.logback.core.ConsoleAppender">
        <target>System.err</target>
        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="ch.qos.logback.classic.PatternLayout">
                <pattern><![CDATA[
			 [%d{yyyy-MM-dd HH:mm:ss}]  %-5level %logger{0} - %m%n
            ]]></pattern>
            </layout>
        </encoder>
    </appender>

    <root>
        <level value="DEBUG"/>
        <appender-ref ref="STDOUT"/>
        <appender-ref ref="STDERR"/>
    </root>
</configuration>
```

# 2 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [logback 配置详解](https://www.jianshu.com/p/1ded57f6c4e3)
