---
title: Spring Boot
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

__创建`SampleApplication.java`__

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

__创建`SampleController.java`__

```Java
package org.liuyehcf.controller;

import org.liuyehcf.service.SampleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
@RequestMapping("/home")
public class SampleController {

    @Autowired
    private SampleService sampleService;

    @RequestMapping("/hello")
    @ResponseBody
    public String hello(){
        return sampleService.getHelloWorld();
    }

}
```

__创建`SampleService.java`__
```Java
package org.liuyehcf.service;

import org.springframework.stereotype.Service;

@Service
public class SampleService {
    public String getHelloWorld(){
        return "Hello world!";
    }
}

```

__启动，访问`http://localhost:8080/home/hello`__

# 2 关键注解

`@Configuration`

* 提到@Configuration就要提到他的搭档@Bean。使用这两个注解就可以创建一个简单的spring配置类，可以用来替代相应的xml配置文件。
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

* 会自动扫描指定包下的全部标有@Component的类，并注册成bean，当然包括@Component下的子注解@Service，@Repository，@Controller。

`@SpringBootApplication`

* @SpringBootApplication = (默认属性)@Configuration + @EnableAutoConfiguration + @ComponentScan

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [sing-boot-maven-without-a-parent](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-maven-without-a-parent)
* [@SpringBootApplication的使用](http://blog.csdn.net/u013473691/article/details/52353923)
