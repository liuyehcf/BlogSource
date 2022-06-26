---
title: Spring-Cloud-Eureka-Based-Demo
date: 2018-07-11 19:02:57
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 Overview

{% post_link Spring-Cloud-Overview %}

本篇博客以`Eureka`作为注册中心搭建一个Spirng-Cloud集群（据最新消息，Eureka已于`2018-07-12`闭源）

Spring-Cloud对注册中心这一模块做了抽象，其实现不局限于`Eureka`，还包括`Zookeeper`等。以`Zookeeper`为注册中心的Demo可以参考{% post_link Spring-Cloud-Zookeeper-Based-Demo %}

# 2 Demo概览

**本Demo工程（`spring-cloud-cluster-eureka-based`）包含了如下几个子模块**

1. `eureka-server`：服务注册/发现的配置中心
1. `eureka-provider`：服务提供方
1. `ribbon-consumer`：服务消费方-以ribbon方式
1. `feign-consumer`：服务消费方-以feign方式
1. `config-server`：应用配置服务方
1. `config-client`：应用配置消费方

`spring-cloud-cluster-eureka-based` Deom工程的的pom文件如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf.spring.cloud</groupId>
    <artifactId>spring-cloud-cluster-eureka-based</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <packaging>pom</packaging>

    <modules>
        <module>eureka-server</module>
        <module>eureka-provider</module>
        <module>feign-consumer</module>
        <module>ribbon-consumer</module>
        <module>config-server</module>
        <module>config-client</module>
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

**`eureka-server`模块的目录结构如下**

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
    │   │                       └── server
    │   │                           └── EurekaServerApplication.java
    │   └── resources
    │       └── application.yml
```

1. pom.xml
1. EurekaServerApplication.java
1. application.yml

## 3.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
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

`@EnableEurekaServer`注解表示当前应用作为Eureka的服务端，即注册中心（RegisterCenter）

```java
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

```yaml
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
    # 在未设置defaultZone的情况下，注册中心在本例中的默认地址就是http://127.0.0.1:1100/eureka/
    # 但奇怪的是，启动注册中心时，控制台还是会打印这个地址的节点：http://localhost:8761/eureka/
    # 而实际服务端注册时，要使用1100端口的才能注册成功，8761端口的会注册失败并报告异常
    serviceUrl:
      # 实际测试：若修改尾部的eureka为其它的，比如/myeureka，注册中心启动没问题，但服务端在注册时会失败
      # 报告异常：com.netflix.discovery.shared.transport.TransportException: Cannot execute request on any known server
      defaultZone: http://127.0.0.1:${server.port}/eureka/
```

## 3.4 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以看到注册中心的控制台页面

# 4 Eureka-Provider

**`eureka-provider`模块的目录结构如下**

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
    │   │                           └── ProviderGreetController.java
    │   └── resources
    │       └── application.yml

```

1. pom.xml
1. EurekaProviderApplication.java
1. ProviderGreetController.java
1. application.yml

## 4.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
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

```java
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

## 4.3 ProviderGreetController.java

提供了一个简单的http服务，打印名字、时间与当前服务器的端口号

```java
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
public class ProviderGreetController {
    @Value("${server.port}")
    private String port;

    @RequestMapping("/hi")
    public String hi(@RequestParam String name) {
        return "hi " + name + ", I'm from port " + port + ", current Time is " + new Date();
    }
}
```

## 4.4 application.yml

1. `Spring Cloud`默认将`spring.application.name`作为`serviceId`
1. 必须知道注册中心的地址

```yaml
server:
  port: 1110

spring:
  application:
    name: GreetService                            # 指定发布的微服务名（以后调用时，只需该名称即可访问该服务）

eureka:
  client:
    serviceUrl:
      defaultZone: http://127.0.0.1:1100/eureka/  # 指定服务注册中心的地址
```

## 4.5 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以在注册中心的控制台页面找到当前节点的信息

# 5 Ribbon-Consumer

**`Spring Cloud`有两种服务调用方式**

1. 一种是`Ribbon`+`RestTemplate`
1. 另一种是`Feign`，其中`Feign`集成了`Ribbon`

本小节先介绍`Ribbon`+`RestTemplate`方式的服务调用

**`ribbon-consumer`模块的目录结构如下**

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
    │   │                   └── ribbon
    │   │                       └── consumer
    │   │                           ├── ConsumerGreetController.java
    │   │                           ├── ConsumerGreetService.java
    │   │                           └── RibbonConsumerApplication.java
    │   └── resources
    │       └── application.yml
```

1. pom.xml
1. ConsumerGreetController.java
1. ConsumerGreetService.java
1. RibbonConsumerApplication.java
1. application.yml

## 5.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
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

## 5.2 ConsumerGreetController.java

该模块对外提供的http服务，可以看到该服务仅仅对`eureka-provier`模块的http服务做了一层代理

```java
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
public class ConsumerGreetController {
    @Resource
    private ConsumerGreetService consumerGreetService;

    @RequestMapping("/sayHi")
    String sayHi(@RequestParam String name) {
        return consumerGreetService.sayHi(name);
    }
}
```

## 5.3 ConsumerGreetService.java

该类实现服务间的调用，在`reqURL`中用服务名（GreetService）代替服务方的ip:port信息，将地址映射交给`Eureka Server`来完成。可以看出来，这种方式比较繁琐，且不太友好，好比用`JDBC Connection`来进行数据库操作

```java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@Service
class ConsumerGreetService {
    @Resource
    private RestTemplate restTemplate;

    String sayHi(String name) {
        String reqURL = "http://GreetService/hi?name=" + name;
        return restTemplate.getForEntity(reqURL, String.class).getBody();
    }
}
```

## 5.4 RibbonConsumerApplication.java

`@EnableDiscoveryClient`注解表示当前应用作为消费方（也可以使用`@EnableEurekaClient`注解）

```java
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

    //开启软均衡负载
    @LoadBalanced
    @Bean
    RestTemplate restTemplate() {
        return new RestTemplate();
    }
}
```

## 5.5 application.yml

1. `Spring Cloud`默认将`spring.application.name`作为`serviceId`
1. 必须知道注册中心的地址

```yaml
server:
  port: 1120

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
      defaultZone: http://127.0.0.1:1100/eureka/
```

## 5.6 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以在注册中心的控制台页面找到当前节点的信息

同时，访问[http://localhost:1120/demo/ribbon/sayHi?name=strange](http://localhost:1120/demo/ribbon/sayHi?name=strange)可以看到提示信息

# 6 Feign-Consumer

`Feign`是一个声明式的伪Http客户端，它使得写Http客户端变得更简单。使用`Feign`，只需要创建一个接口并注解。它具有可插拔的注解特性，可使用`Feign` 注解和JAX-RS注解。`Feign`支持可插拔的编码器和解码器。`Feign`默认集成了`Ribbon`，并和`Eureka`结合，默认实现了负载均衡的效果

* **`Feign`采用的是基于接口的注解**
* **`Feign`整合了`Ribbon`**

**`feign-consumer`模块的目录结构如下**

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
    │   │                           ├── ConsumerGreetController.java
    │   │                           ├── ConsumerGreetService.java
    │   │                           └── FeignConsumerApplication.java
    │   └── resources
    │       └── application.yml

```

1. pom.xml
1. ConsumerGreetController.java
1. ConsumerGreetService.java
1. FeignConsumerApplication.java
1. application.yml

## 6.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`
1. `org.springframework.cloud:spring-cloud-starter-openfeign`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
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

## 6.2 ConsumerGreetController.java

该模块对外提供的http服务，可以看到该服务仅仅对`eureka-provier`模块的http服务做了一层代理

```java
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
public class ConsumerGreetController {
    @Resource
    private ConsumerGreetService consumerGreetService;

    @RequestMapping("/sayHi")
    String sayHi(@RequestParam String name) {
        return consumerGreetService.sayHi(name);
    }
}
```

## 6.3 ConsumerGreetService.java

在`Feign`方式下，我们仅仅利用注解来标记接口（声明式地编程），就能够确定服务消费方与服务提供方的绑定关系，十分简洁高效

* 其中，`@FeignClient`注解的value属性指的是服务提供方的服务名称
* `@RequestMapping`注解的value属性表示的是服务提供方的方法路由路径
* 方法参数以及返回值可以利用http相关注解进行标记，例如`@RequestParam`、`@RequestBody`、`@PathVariable`、`@ResultBody`等

```java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@FeignClient(value = "GreetService")
interface ConsumerGreetService {
    @RequestMapping(value = "/hi", method = RequestMethod.GET)
    String sayHi(@RequestParam("name") String name);
}
```

## 6.4 FeignConsumerApplication.java

`@EnableFeignClients`注解表明以`Feign`方式进行服务消费
`@EnableDiscoveryClient`注解表示当前应用作为消费方（也可以使用`@EnableEurekaClient`注解）

```java
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

1. `Spring Cloud`默认将`spring.application.name`作为`serviceId`
1. 必须知道注册中心的地址

```yaml
server:
  port: 1130

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
      defaultZone: http://127.0.0.1:1100/eureka/
```

## 6.6 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以在注册中心的控制台页面找到当前节点的信息

同时，访问[http://localhost:1130/demo/feign/sayHi?name=strange](http://localhost:1130/demo/feign/sayHi?name=strange)可以看到提示信息

# 7 Config-Server

**`config-server`模块的目录结构如下**

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
    │   │                   └── config
    │   │                       └── server
    │   │                           └── ConfigServerApplication.java
    │   └── resources
    │       └── application.yml
```

1. pom.xml
1. ConfigServerApplication.java
1. application.yml

## 7.1 pom.xml

由于配置服务提供方（config-server）既可以直接暴露ip提供服务，也可以通过Eureka来提供服务，这里选择使用Eureka的方式

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`
1. `org.springframework.cloud:spring-cloud-config-server`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>config-server</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
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
</project>
```

## 7.2 ConfigServerApplication.java

`@EnableConfigServer`注解表示当前应用作为Config的服务端
`@EnableEurekaClient`注解表示当前应用将自身地址信息注册到Eureka服务器，供其他应用接入

```java
package org.liuyehcf.spring.cloud.config.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */

@EnableConfigServer
@EnableEurekaClient
@SpringBootApplication
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
```

## 7.3 application.yml

1. `Spring Cloud`默认将`spring.application.name`作为`serviceId`
1. 必须知道注册中心的地址
1. 由于需要从远程git仓库获取配置信息，因此需要配置git仓库的相关元数据

```yaml
server:
  port: 1140

spring:
  application:
    name: ConfigServer
  cloud:
    config:
      server:
        git:
          uri: https://github.com/liuyehcf/spring-cloud-config-demo   # 配置git仓库的地址
          searchPaths: config-repo                                    # git仓库下的相对地址（多个则用半角逗号分隔）
          # username: username                                        # 只有private的项目才需配置用户名和密码
          # password: password                                        # 只有private的项目才需配置用户名和密码

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
      defaultZone: http://127.0.0.1:1100/eureka/
```

## 7.4 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以在注册中心的控制台页面找到当前节点的信息

同时，访问以下URL，可以获取配置信息

* [http://localhost:1140/cloud.config.demo-dev.properties](http://localhost:1140/cloud.config.demo-dev.properties)
* [http://localhost:1140/cloud.config.demo-dev.yml](http://localhost:1140/cloud.config.demo-dev.yml)
* [http://localhost:1140/master/cloud.config.demo-dev.properties](http://localhost:1140/master/cloud.config.demo-dev.properties)
* [http://localhost:1140/master/cloud.config.demo-dev.yml](http://localhost:1140/master/cloud.config.demo-dev.yml)
* [http://localhost:1140/temp/cloud.config.demo-dev.properties](http://localhost:1140/temp/cloud.config.demo-dev.properties)
* [http://localhost:1140/temp/cloud.config.demo-dev.yml](http://localhost:1140/temp/cloud.config.demo-dev.yml)
* 其中，`master`和`temp`是[git](https://github.com/liuyehcf/spring-cloud-config-demo)仓库的两个分支

**HTTP URL与Resource的对应关系如下，其中**

1. `{application}`：表示的是文件名，**一般来说会以应用名作为配置的文件名，因此占位符的名字叫`application`**
1. `{profile}`：表示profile后缀
1. `{label}`：表示git的分支

```
/{application}/{profile}[/{label}]
/{application}-{profile}.yml
/{label}/{application}-{profile}.yml
/{application}-{profile}.properties
/{label}/{application}-{profile}.properties
```

# 8 Config-Client

**`config-client`模块的目录结构如下**

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
    │   │                   └── config
    │   │                       └── client
    │   │                           └── ConfigClientApplication.java
    │   └── resources
    │       ├── application.yml
    │       └── bootstrap.yml
```

1. pom.xml
1. ConfigClientApplication.java
1. application.yml
1. bootstrap.yml

## 8.1 pom.xml

由于配置服务消费方（config-client）可以强关联服务提供方的ip来使用服务，也可以通过Eureka来使用服务，这里选择使用Eureka的方式

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-netflix-eureka-server`
1. `org.springframework.cloud:spring-cloud-starter-config`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-eureka-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>config-client</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <!-- 这个依赖虽然没有显式用到，但是会在占位符注入时起作用 -->
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
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
</project>
```

## 8.2 ConfigClientApplication.java

`@EnableEurekaClient`注解表示当前应用将通过Eureka来发现服务，该注解可以替换为`@EnableDiscoveryClient`注解

```java
package org.liuyehcf.spring.cloud.config.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author hechenfeng
 * @date 2018/7/12
 */
@RestController
@EnableEurekaClient
@SpringBootApplication
@RequestMapping("/demo/config")
public class ConfigClientApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigClientApplication.class, args);
    }

    //获取配置中心的属性
    @Value("${host}")
    private String host;

    //获取配置中心的属性
    @Value("${description}")
    private String description;

    @GetMapping("/getHost")
    public String getHost() {
        return this.host;
    }

    @GetMapping("/getDescription")
    public String getDescription() {
        return this.description;
    }
}
```

## 8.3 application.yml

```yaml
server:
  port: 1150

eureka:
  instance:
    instance-id: ${spring.application.name}:${server.port}
    prefer-ip-address: true                       # 设置微服务调用地址为IP优先（缺省为false）
    lease-renewal-interval-in-seconds: 5          # 心跳时间，即服务续约间隔时间（缺省为30s）
    lease-expiration-duration-in-seconds: 15      # 发呆时间，即服务续约到期时间（缺省为90s）
  client:
    healthcheck:
      enabled: true                               # 开启健康检查（依赖spring-boot-starter-actuator）
```

## 8.4 bootstrap.yml

应用读取配置中心参数时，会配置配置中心的地址等相关参数，而这部分配置需优先于`application.yml`被应用读取。`Spring Cloud`中的 `bootstrap.yml`是会比`application.yml`先加载的，所以这部分配置要定义在`bootstrap.yml`里面，这就引申出两个需要注意的地方

* `spring.application.name`：它应该配置在`bootstrap.yml`，它的名字应该等于配置中心的配置文件的`{application}`。**所以配置中心在给配置文件取名字时，最好让它等于对应的应用服务名**
* **配置中心与注册中心联合使用：若应用通过`serviceId`而非`url`来指定配置中心**，则`eureka.client.serviceUrl.defaultZone`也要配置在`bootstrap.yml`，要不启动的时候，应用会找不到注册中心，自然也就找不到配置中心了

```yaml
spring:
  application:
    name: cloud.config.demo         # 指定配置中心配置文件的{application}
  cloud:
    config:
      profile: dev                  # 指定配置中心配置文件的{profile}
      label: temp                   # 指定配置中心配置文件的{label}
      discovery:
        enabled: true               # 使用注册中心里面已注册的配置中心
        serviceId: ConfigServer     # 指定配置中心注册到注册中心的serviceId

eureka:
  client:
    serviceUrl:
      defaultZone: http://127.0.0.1:1100/eureka/
```

## 8.5 Test

启动后，访问[http://localhost:1100/](http://localhost:1100/)就可以在注册中心的控制台页面找到当前节点的信息

同时，访问如下URL，可以看到成功从`config-server`获取了配置信息

* [http://localhost:1150/demo/config/getHost](http://localhost:1150/demo/config/getHost)
* [http://localhost:1150/demo/config/getDescription](http://localhost:1150/demo/config/getDescription)

# 9 参考

* [Spring Cloud官方文档](http://cloud.spring.io/spring-cloud-static/Finchley.RELEASE/single/spring-cloud.html)
* [史上最简单的 SpringCloud 教程 | 终章](https://blog.csdn.net/forezp/article/details/70148833)
* [SpringCloud-Demo](https://jadyer.cn/category/#SpringCloud)
