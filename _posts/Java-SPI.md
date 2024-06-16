---
title: Java-SPI
date: 2018-08-10 09:37:05
tags: 
- 原创
categories: 
- Java
- Java SPI
---

**阅读更多**

<!--more-->

# 1 Overview

`SPI`全称为`Service Provider Interface`，它本质上就是一个Java接口，其实现类通常由第三方或者扩展包提供。SPI机制常被用来扩展框架以及制作可插拔插件

`服务`通常由一组接口和（通常是抽象的）类组成。`服务提供者`是`服务`的具体实现。提供者中的类通常实现服务本身定义的接口和子类。服务提供者可以以扩展的形式安装在Java平台的实现中，即JAR文件。也可以通过将它们添加到应用程序的类路径或者通过其他特定于平台的方法获得

# 2 Demo

为了更好地体现SPI的定义、实现以及使用，Demo包含三个模块：

1. `spi-facade`
1. `spi-provider`
1. `spi-consumer`

```
.
├── spi-facade
│   ├── pom.xml
│   └── src
│       └── main
│           └── java
│               └── org
│                   └── liuyehcf
│                       └── spi
│                           └── GreetService.java
│
│
├── spi-provider
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── liuyehcf
│           │           └── spi
│           │               └── provider
│           │                   ├── GreetServiceInChinese.java
│           │                   └── GreetServiceInEnglish.java
│           └── resources
│               └── META-INF
│                   └── services
│                       └── org.liuyehcf.spi.GreetService
│
│
├── spi-consumer
│   ├── pom.xml
│   └── src
│       └── main
│           └── java
│               └── org
│                   └── liuyehcf
│                       └── spi
│                           └── consumer
│                               └── GreetServiceConsumer.java
```

## 2.1 spi-facade

### 2.1.1 pom

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf</groupId>
    <artifactId>spi-facade</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 2.1.2 GreetService

```java
package org.liuyehcf.spi;

public interface GreetService {
    String sayHello(String name);
}

```

## 2.2 spi-provider

### 2.2.1 pom

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf</groupId>
    <artifactId>spi-provider</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>spi-facade</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 2.2.2 GreetServiceInChinese

```java
package org.liuyehcf.spi.provider;

import org.liuyehcf.spi.GreetService;

public class GreetServiceInChinese implements GreetService {
    public String sayHello(String name) {
        return "你好，" + name;
    }
}
```

### 2.2.3 GreetServiceInEnglish

```java
package org.liuyehcf.spi.provider;

import org.liuyehcf.spi.GreetService;

public class GreetServiceInEnglish implements GreetService {
    public String sayHello(String name) {
        return "hello, " + name;
    }
}
```

### 2.2.4 org.liuyehcf.spi.GreetService

```
org.liuyehcf.spi.provider.GreetServiceInEnglish
org.liuyehcf.spi.provider.GreetServiceInChinese
```

## 2.3 spi-consumer

### 2.3.1 pom

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf</groupId>
    <artifactId>spi-consumer</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>spi-provider</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

### 2.3.2 GreetServiceConsumer

```java
package org.liuyehcf.spi.consumer;

import org.liuyehcf.spi.GreetService;

import java.util.ServiceLoader;

public class GreetServiceConsumer {
    public static void main(String[] args) {
        ServiceLoader<GreetService> load = ServiceLoader.load(GreetService.class);

        for (GreetService serviceFacade : load) {
            System.out.println(serviceFacade.sayHello("liuyehcf"));
        }
    }
}
```

# 3 Reference

* [JavaSPI机制学习笔记](https://www.cnblogs.com/lovesqcc/p/5229353.html)
* [Java-SPI机制](https://www.jianshu.com/p/e4262536000d)
* [ServiceLoader使用看这一篇就够了](https://www.jianshu.com/p/7601ba434ff4)
