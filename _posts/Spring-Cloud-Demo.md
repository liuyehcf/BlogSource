---
title: Spring-Cloud-Demo
date: 2018-07-11 19:02:57
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

## 1.1 Feature

__Spring-Cloud集成如下功能__

1. 分布式配置
1. 服务注册与发现
1. 路由
1. 服务间调用
1. 负载均衡
1. 分布式锁
1. master选举
1. 分布式消息

## 1.2 Eureka

Eureka本质上是一个非持久化配置中心，用于服务的注册与发现。当一个应用A要向外提供服务时，需要向Eureka Server进行注册，上报应用相关的地址信息（例如ip:port）以及服务名称（例如，应用A设定的服务名称为`serviceA`）。当另一个应用B需要使用A提供的服务时，只需要向Eureka Server查询指定服务所对应的地址信息即可

# 2 Demo概览

__本Demo工程（`spring-cloud`）包含了如下几个子模块__

1. `eureka-server`：配置中心
1. `eureka-provider`：服务提供方
1. `ribbon-consumer`：服务消费方-以ribbon方式
1. `feign-consumer`：服务消费方-以feign方式

`spring-cloud` Deom工程的的pom文件如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf.spring.cloud</groupId>
    <artifactId>spring.cloud</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <packaging>pom</packaging>

    <modules>
        <module>eureka-server</module>
        <module>eureka-provider</module>
        <module>feign-consumer</module>
        <module>ribbon-consumer</module>
    </modules>

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

# 3 Eureka-Server

__`eureka-server`模块的目录结构如下__

```
.
├── pom.xml
├── src
│   ├── main
│   │   ├── java
│   │   │   └── org
│   │   │       └── liuyehcf
│   │   │           └── spring
│   │   │               └── cloud
│   │   │                   └── eureka
│   │   │                       └── server
│   │   │                           └── EurekaServerApplication.java
│   │   └── resources
│   │       └── application.yml
```

仅包含3个文件

1. pom.xml
1. EurekaServerApplication.java
1. application.yml

## 3.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入`spring-cloud-starter-netflix-eureka-server`依赖即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring.cloud</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>eureka-server</artifactId>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.0.3.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 3.2 EurekaServerApplication.java

`@EnableEurekaServer`注解表示当前应用作为Eureka的服务端，即配置中心（configServer）

```Java
package org.liuyehcf.spring.cloud.eureka.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@EnableEurekaServer
@SpringBootApplication
public class EurekaServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

## 3.3 application.yml

```yml
server:
  port: 1100

eureka:
  client:
    # 设置是否从注册中心获取注册信息（缺省true）
    # 因为这是一个单点的EurekaServer，不需要同步其它EurekaServer节点的数据，故设为false
    fetch-registry: false
    # 设置是否将自己作为客户端注册到注册中心（缺省true）
    # 这里为不需要（查看@EnableEurekaServer注解的源码，会发现它间接用到了@EnableDiscoveryClient）
    register-with-eureka: false
    # 在未设置defaultZone的情况下，注册中心在本例中的默认地址就是http:// 127.0.0.1:1100/eureka/
    # 但奇怪的是，启动注册中心时，控制台还是会打印这个地址的节点：http:// localhost:8761/eureka/
    # 而实际服务端注册时，要使用1100端口的才能注册成功，8761端口的会注册失败并报告异常
    serviceUrl:
      # 实际测试：若修改尾部的eureka为其它的，比如/myeureka，注册中心启动没问题，但服务端在注册时会失败
      # 报告异常：com.netflix.discovery.shared.transport.TransportException: Cannot execute request on any known server
      defaultZone: http:// 127.0.0.1:${server.port}/eureka/
```

# 4 Eureka-Provider

__`eureka-provider`模块的目录结构如下__

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── spring
    │   │               └── cloud
    │   │                   └── eureka
    │   │                       └── provider
    │   │                           ├── EurekaProviderApplication.java
    │   │                           └── ProviderController.java
    │   └── resources
    │       └── application.yml

```

仅包含4个文件

1. pom.xml
1. EurekaProviderApplication.java
1. ProviderController.java
1. application.yml

## 4.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入`spring-cloud-starter-netflix-eureka-server`依赖即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring.cloud</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>eureka-provider</artifactId>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.0.3.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 4.2 EurekaProviderApplication.java

`@EnableEurekaClient`注解表示当前应用作为Eureka的客户端，即服务注册方（服务提供方，service-provider）

```Java
package org.liuyehcf.spring.cloud.eureka.provider;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@EnableEurekaClient
@SpringBootApplication
public class EurekaProviderApplication {
    public static void main(String[] args) {
        SpringApplication.run(EurekaProviderApplication.class, args);
    }
}

```

## 4.3 ProviderController.java

提供了一个简单的http服务，打印名字、时间与当前服务器的端口号

```Java
package org.liuyehcf.spring.cloud.eureka.provider;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@RestController
public class ProviderController {
    @Value("${server.port}")
    private String port;

    @RequestMapping("/hi")
    public String hi(@RequestParam String name) {
        return "hi " + name + ", I'm from port " + port + ", current Time is " + new Date();
    }
}
```

## 4.4 application.yml

```yml
server:
  port: 2100

spring:
  application:
    name: CalculatorServer                        # 指定发布的微服务名（以后调用时，只需该名称即可访问该服务）

eureka:
  client:
    serviceUrl:
      defaultZone: http:// 127.0.0.1:1100/eureka/  # 指定服务注册中心的地址
```

# 5 Ribbon-Consumer

__`Spring Cloud`有两种服务调用方式__

1. 一种是`Ribbon`+`RestTemplate`
1. 另一种是`Feign`，其中`Feign`集成了`Ribbon`

本小结先介绍`Ribbon`+`RestTemplate`方式的服务调用

__`ribbon-consumer`模块的目录结构如下__

```
.
├── pom.xml
├── ribbon-consumer.iml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── spring
    │   │               └── cloud
    │   │                   └── ribbon
    │   │                       └── consumer
    │   │                           ├── CalculatorService.java
    │   │                           ├── ConsumerController.java
    │   │                           └── RibbonConsumerApplication.java
    │   └── resources
    │       └── application.yml
```

仅包含5个文件

1. pom.xml
1. CalculatorService.java
1. ConsumerController.java
1. RibbonConsumerApplication.java
1. application.yml

## 5.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入`spring-cloud-starter-netflix-eureka-server`依赖即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring.cloud</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>ribbon-consumer</artifactId>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.0.3.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 5.2 CalculatorService.java

该类实现服务间的调用，在`reqURL`中用服务名（CalculatorServer）代替服务方的ip:port信息，将地址映射交给`Eureka Server`来完成。可以看出来，这种方式比较繁琐，且不太友好，好比用`JDBC Connection`来进行数据库操作

```Java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@Service
class CalculatorService {
    @Resource
    private RestTemplate restTemplate;

    String sayHi(String name) {
        String reqURL = "http:// CalculatorServer/hi?name=" + name;
        return restTemplate.getForEntity(reqURL, String.class).getBody();
    }
}
```

## 5.3 ConsumerController.java

该模块对外提供的http服务，可以看到该服务仅仅对`eureka-provier`模块的http服务做了一层代理

```Java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@RestController
@RequestMapping("/demo/ribbon")
public class ConsumerController {
    @Resource
    private CalculatorService calculatorService;

    @RequestMapping("/sayHi")
    String sayHi(@RequestParam String name) {
        return calculatorService.sayHi(name);
    }
}
```

## 5.4 RibbonConsumerApplication.java

`@EnableDiscoveryClient`注解表示当前应用作为消费方（也可以使用`@EnableEurekaClient`注解）

```Java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.web.client.RestTemplate;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@EnableDiscoveryClient
@SpringBootApplication
public class RibbonConsumerApplication {
    public static void main(String[] args) {
        SpringApplication.run(RibbonConsumerApplication.class, args);
    }

    // 开启软均衡负载
    @LoadBalanced
    @Bean
    RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

## 5.5 application.yml

```yml
server:
  port: 3100

spring:
  application:
    name: client-consumer-ribbon

eureka:
  instance:
    instance-id: ${spring.application.name}:${server.port}
    prefer-ip-address: true
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 15
  client:
    healthcheck:
      enabled: true
    serviceUrl:
      defaultZone: http:// 127.0.0.1:1100/eureka/
```

# 6 Feign-Consumer

`Feign`是一个声明式的伪Http客户端，它使得写Http客户端变得更简单。使用`Feign`，只需要创建一个接口并注解。它具有可插拔的注解特性，可使用`Feign` 注解和JAX-RS注解。`Feign`支持可插拔的编码器和解码器。`Feign`默认集成了`Ribbon`，并和Eureka结合，默认实现了负载均衡的效果

* __`Feign`采用的是基于接口的注解__
* __`Feign`整合了`Ribbon`__

__`feign-consumer`模块的目录结构如下__

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── spring
    │   │               └── cloud
    │   │                   └── feign
    │   │                       └── consumer
    │   │                           ├── CalculatorService.java
    │   │                           ├── ConsumerController.java
    │   │                           └── FeignConsumerApplication.java
    │   └── resources
    │       └── application.yml
```

仅包含5个文件

1. pom.xml
1. CalculatorService.java
1. ConsumerController.java
1. FeignConsumerApplication.java
1. application.yml

## 6.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入`spring-cloud-starter-netflix-eureka-server`以及`spring-cloud-starter-openfeign`依赖即可

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring.cloud</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>feign-consumer</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.0.3.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Finchley.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
```

## 6.2 CalculatorService.java

在`Feign`方式下，我们仅仅利用注解来标记接口（声明式地编程），就能够确定服务消费方与服务提供方的绑定关系，十分简洁高效

* 其中，`@FeignClient`注解的value属性指的是服务提供方的服务名称
* `@RequestMapping`注解的value属性表示的是服务提供方的方法路由路径
* 方法参数以及返回值可以利用http相关注解进行标记，例如`@RequestParam`、`@RequestBody`、`@PathVariable`、`@ResultBody`等

```Java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@FeignClient(value = "CalculatorServer")
interface CalculatorService {
    @RequestMapping(value = "/hi", method = RequestMethod.GET)
    String sayHi(@RequestParam("name") String name);
}
```

## 6.3 ConsumerController.java

该模块对外提供的http服务，可以看到该服务仅仅对eureka-provier模块的http服务做了一层代理

```Java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@RestController
@RequestMapping("/demo/feign")
public class ConsumerController {
    @Resource
    private CalculatorService calculatorService;

    @RequestMapping("/sayHi")
    String sayHi(@RequestParam String name) {
        return calculatorService.sayHi(name);
    }
}
```

## 6.4 FeignConsumerApplication.java

`@EnableFeignClients`注解表明以`Feign`方式进行服务消费
`@EnableDiscoveryClient`注解表示当前应用作为消费方（也可以使用`@EnableEurekaClient`注解）

```Java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@EnableFeignClients
@EnableDiscoveryClient
@SpringBootApplication
public class FeignConsumerApplication {
    public static void main(String[] args) {
        SpringApplication.run(FeignConsumerApplication.class, args);
    }
}

```

## 6.5 application.yml

```yml
server:
  port: 3200

spring:
  application:
    name: client-consumer-feign

eureka:
  instance:
    instance-id: ${spring.application.name}:${server.port}
    prefer-ip-address: true
    lease-renewal-interval-in-seconds: 5
    lease-expiration-duration-in-seconds: 15
  client:
    healthcheck:
      enabled: true
    serviceUrl:
      defaultZone: http:// 127.0.0.1:1100/eureka/
```

# 7 参考

* [史上最简单的 SpringCloud 教程 | 终章](https://blog.csdn.net/forezp/article/details/70148833)
* [SpringCloud-Demo](https://jadyer.cn/category/#SpringCloud)
