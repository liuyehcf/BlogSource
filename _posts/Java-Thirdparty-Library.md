---
title: Java-Thirdparty-Library
date: 2023-03-10 20:13:29
tags: 
- 原创
categories: 
- Java
---

**阅读更多**

<!--more-->

# 1 Frequently-Used-Utils

**`commons`：**

1. `commons-lang:commons-lang`
1. `commons-io:commons-io`
1. `commons-collections:commons-collections`
1. `commons-cli:commons-cli`

**`apache`：**

1. `org.apache.commons:commons-lang3`
1. `org.apache.commons:commons-collections4`

**`google`：**

1. `com.google.guava:guava`
1. `com.google.code.gson:gson`

**`Plugin`：**

1. `org.apache.maven.plugins:maven-compiler-plugin`
1. `org.springframework.boot:spring-boot-maven-plugin`
    * 配置参数（`<configuration>`）：
        * `includeSystemScope`
        * `mainClass`
    * 默认情况下，会讲资源文件打包，并放置在`BOOT-INF/classes`。需要使用`Thread.currentThread().getContextClassLoader()`而不能使用`ClassLoader.getSystemClassLoader()`。因为`Thread.currentThread().getContextClassLoader()`这个类加载器是`Spring Boot`应用程序运行时默认使用的类加载器，它知道资源文件放在了`BOOT-INF/classes`，而`ClassLoader.getSystemClassLoader()`并不知道这一信息
