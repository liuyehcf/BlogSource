---
title: Spring-Boot-Demo
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
1. Maven 3.5.2
1. Spring Boot

# 2 Demo工程目录结构

```
.
├── pom.xml
└── src
    └── main
        └── java
            └── org
                └── liuyehcf
                    └── spring
                        └── boot
                            ├── SampleApplication.java
                            ├── controller
                            │   └── SampleController.java
                            └── dto
                                ├── LoginRequestDTO.java
                                └── LoginResponseDTO.java

```

# 3 pom文件

## 3.1 继承自spring-boot

pom文件可以直接继承自`org.springframework.boot:spring-boot-starter-parent`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xmlns="http:// maven.apache.org/POM/4.0.0"
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

## 3.2 继承自己项目的父pom文件

如果不想继承自`org.springframework.boot:spring-boot-starter-parent`，那么需要通过`<dependencyManagement>`元素引入依赖

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xmlns="http:// maven.apache.org/POM/4.0.0"
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

    <!-- 引入依赖 -->
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

# 4 Controller

```Java
package org.liuyehcf.spring.boot.controller;

import org.liuyehcf.spring.boot.dto.LoginRequestDTO;
import org.liuyehcf.spring.boot.dto.LoginResponseDTO;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

/**
 * Created by HCF on 2017/11/24.
 */
@Controller
@RequestMapping("/")
public class SampleController {

    @RequestMapping(value = "/home", method = RequestMethod.GET)
    @ResponseBody
    public String home() {
        return "Hello world!";
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    @ResponseBody
    public LoginResponseDTO login(@RequestBody LoginRequestDTO request) {
        LoginResponseDTO loginResponse = new LoginResponseDTO();
        loginResponse.setState("OK");
        loginResponse.setMessage("欢迎登陆" + request.getName());
        return loginResponse;
    }

    @RequestMapping(value = "/compute", method = RequestMethod.GET)
    @ResponseBody
    public String compute(@RequestParam String value1,
                          @RequestParam String value2,
                          @RequestHeader String operator) {
        switch (operator) {
            case "+":
                return Float.toString(
                        Float.parseFloat(value1)
                                + Float.parseFloat(value2));
            case "-":
                return Float.toString(
                        Float.parseFloat(value1)
                                - Float.parseFloat(value2));
            case "*":
                return Float.toString(
                        Float.parseFloat(value1)
                                * Float.parseFloat(value2));
            default:
                return "wrong operation";
        }
    }
}
```

## 4.1 DTO

```Java
package org.liuyehcf.spring.boot.dto;

/**
 * Created by Liuye on 2017/12/15.
 */
public class LoginRequestDTO {
    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

```Java
package org.liuyehcf.spring.boot.dto;

/**
 * Created by Liuye on 2017/12/15.
 */
public class LoginResponseDTO {
    private String state;

    private String message;

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
```

# 5 Application

```Java
package org.liuyehcf.spring.boot;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

@EnableAutoConfiguration
@ComponentScan("org.liuyehcf.*")
public class SampleApplication {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(SampleApplication.class, args);
    }
}
```

__测试__

1. `http://localhost:8080/home/`
1. 其他两个API可以通过post man测试

## 5.1 关键注解

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

# 6 排错

当我采用第二种pom文件时（__不继承spring boot的pom文件__），启动时会产生如下异常信息

```Java
...
Caused by: java.lang.NoSuchMethodError: org.springframework.web.accept.ContentNegotiationManagerFactoryBean.build()Lorg/springframework/web/accept/ContentNegotiationManager;
...
```

这是由于我在项目的父pom文件中引入了5.X.X版本的Spring依赖，这与`spring-boot-dependencies`引入的Spring依赖会冲突（例如，加载了低版本的class文件，但是运行时用到了较高版本特有的方法，于是会抛出`NoSuchMethodError`），将项目父pom文件中引入的Spring的版本改为4.3.13.RELEASE就行

# 7 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [sing-boot-maven-without-a-parent](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-maven-without-a-parent)
* [@SpringBootApplication的使用](http://blog.csdn.net/u013473691/article/details/52353923)
