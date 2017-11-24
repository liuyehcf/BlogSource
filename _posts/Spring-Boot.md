---
title: Spring Boot
date: 2017-11-24 12:07:06
tags: 
- 摘录
categories: 
- Java
- Framework
- Spring
- Spring Boot
---

__目录__

<!-- toc -->
<!--more-->

# 1 Hello World

下面利用Maven来快速搭建一个Spring Boot的Demo

__添加以下内容到pom文件中__

```xml
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.8.RELEASE</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>springboot</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>
```

上述配置，需要继承指定的`spring-boot-starter-parent`，如果pom文件中已经有parent了，那么不能采用这种方式，那么可以添加如下内容到pom文件中

```xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <!-- Override Spring Data release train provided by Spring Boot -->
            <dependency>
                <groupId>org.springframework.data</groupId>
                <artifactId>spring-data-releasetrain</artifactId>
                <version>Fowler-SR2</version>
                <scope>import</scope>
                <type>pom</type>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>1.5.8.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
```

__创建`SampleController.java`__

```Java
package org.liuyehcf.controller;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.stereotype.*;
import org.springframework.web.bind.annotation.*;

@Controller
@EnableAutoConfiguration
public class SampleController {

    @RequestMapping("/")
    @ResponseBody
    String home() {
        return "Hello World!";
    }

    public static void main(String[] args) throws Exception {
        SpringApplication.run(SampleController.class, args);
    }
}
```

__启动，访问`http://localhost:8080`__

# 2 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [sing-boot-maven-without-a-parent](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-maven-without-a-parent)
