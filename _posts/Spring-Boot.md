---
title: Spring-Boot
date: 2017-11-24 12:07:06
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

# 1 环境

1. IDEA
1. Maven3.3.9
1. Spring Boot

# 2 pom文件

## 2.1 继承org.springframework.boot:spring-boot-starter-parent

__pom文件完整内容如下：__

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <!-- 继承自Spring Boot Parent -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.9.RELEASE</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>spring-boot-demo</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
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

## 2.2 继承自己项目的父pom文件

如果不想继承自`org.springframework.boot:spring-boot-starter-parent`，那么需要通过`<dependencyManagement>`元素引入依赖

__pom文件完整内容如下：__

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>JavaLearning</artifactId>
        <groupId>org.liuyehcf</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>

    <modelVersion>4.0.0</modelVersion>

    <artifactId>spring-boot-demo</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>1.5.9.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

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

# 3 Controller

```Java
package org.liuyehcf.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/home")
public class SampleController {

    @RequestMapping("/hello")
    @ResponseBody
    public String hello(){
        return "Hello world!";
    }
}
```

# 4 Application

```Java
package org.liuyehcf;

import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.*;
import org.springframework.context.annotation.ComponentScan;

@EnableAutoConfiguration
@ComponentScan("org.liuyehcf.*")
public class SampleApplication {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(SampleApplication.class, args);
    }
}
```

__启动，访问`http://localhost:8080/home/hello`__

## 4.1 关键注解

`@Configuration`

* 提到@Configuration就要提到他的搭档@Bean。使用这两个注解就可以创建一个简单的spring配置类，可以用来替代相应的xml配置文件
* 以下两个配置等价
    * 
```xml
<beans>  
    <bean id = "car" class="com.test.Car">  
        <property name="wheel" ref = "wheel"></property>  
    </bean>  
    <bean id = "wheel" class="com.test.Wheel"></bean>  
</beans> 
```

    * 
```Java
@Configuration  
public class Conf {  
    @Bean  
    public Car car() {  
        Car car = new Car();  
        car.setWheel(wheel());  
        return car;  
    }  
    @Bean   
    public Wheel wheel() {  
        return new Wheel();  
    }  
}  
```

`@EnableAutoConfiguration`

* 能够自动配置spring的上下文，试图猜测和配置你想要的bean类，通常会自动根据你的类路径和你的bean定义自动配置

`@ComponentScan`

* 会自动扫描指定包下的全部标有@Component的类，并注册成bean，当然包括@Component下的子注解@Service，@Repository，@Controller

`@SpringBootApplication`

* @SpringBootApplication = (默认属性)@Configuration + @EnableAutoConfiguration + @ComponentScan

# 5 排错

当我采用第二种pom文件时（不继承spring boot的pom文件），启动时会产生如下异常信息

```
...
Caused by: java.lang.NoSuchMethodError: org.springframework.web.accept.ContentNegotiationManagerFactoryBean.build()Lorg/springframework/web/accept/ContentNegotiationManager;
...
```

这是由于我在项目的父pom文件中引入了5.X.X版本的Spring依赖，这与`spring-boot-dependencies`引入的Spring依赖会冲突（例如，加载了低版本的class文件，但是运行时用到了较高版本特有的方法，于是会抛出`NoSuchMethodError`），将项目父pom文件中引入的Spring的版本改为4.3.13.RELEASE就行

# 6 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [sing-boot-maven-without-a-parent](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-maven-without-a-parent)
* [@SpringBootApplication的使用](http://blog.csdn.net/u013473691/article/details/52353923)
