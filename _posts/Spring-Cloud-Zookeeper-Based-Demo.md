---
title: Spring-Cloud-Zookeeper-Based-Demo
date: 2018-07-13 15:07:59
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

本篇博客以`Zookeeper`作为注册中心搭建一个Spirng-Cloud集群

Spring-Cloud对注册中心这一模块做了抽象，其实现不局限于`Zookeeper`，还包括`Eureka`等。以`Eureka`为注册中心的Demo可以参考{% post_link Spring-Cloud-Eureka-Based-Demo %}

# 2 Demo概览

**本Demo工程（`spring-cloud-cluster-zookeeper-based`）包含了如下几个子模块**

1. `zookeeper-provider`：服务提供方
1. `ribbon-consumer`：服务消费方-以ribbon方式
1. `feign-consumer`：服务消费方-以feign方式
1. `config-server`：应用配置服务方
1. `config-client`：应用配置消费方

此外，需要额外启动一个zookeeper进程，作为注册中心，这是与`Eureka`有差异的地方（在`Eureka`方式下，注册中心也是一个Java程序）

`spring-cloud-cluster-zookeeper-based` Deom工程的的pom文件如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <groupId>org.liuyehcf.spring.cloud</groupId>
    <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <packaging>pom</packaging>

    <modules>
        <module>zookeeper-provider</module>
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

# 3 Zookeeper进程

首先，需要在本机安装zookeeper，然后启动zookeeper作为本Demo的注册中心

具体步骤，请移步{% post_link Zookeeper-Overview %}，由于篇幅原因，这里不再赘述

zookeeper启动地址为**`http://localhost:2181`**

# 4 Zookeeper-Provider

**`zookeeper-provider`模块的目录结构如下**

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
│   │   │                   └── zookeeper
│   │   │                       └── provider
│   │   │                           ├── ProviderGreetController.java
│   │   │                           └── ZookeeperProviderApplication.java
│   │   └── resources
│   │       └── application.yml
```

1. pom.xml
1. ProviderGreetController.java
1. ZookeeperProviderApplication.java
1. application.yml

## 4.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-zookeeper-all`
1. `org.apache.zookeeper:zookeeper`
1. `org.springframework.boot:spring-boot-starter-web`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>zookeeper-provider</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-all</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.12</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

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

## 4.2 ProviderGreetController.java

提供了一个简单的http服务，打印名字、时间与当前服务器的端口号

```java
package org.liuyehcf.spring.cloud.zookeeper.provider;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

/**
 * @author hechenfeng
 * @date 2018/7/13
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

## 4.3 ZookeeperProviderApplication.java

与SpringBoot应用完全一致的Application类，无需其他注解

```java
package org.liuyehcf.spring.cloud.zookeeper.provider;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author hechenfeng
 * @date 2018/7/13
 */
@SpringBootApplication
public class ZookeeperProviderApplication {
    public static void main(String[] args) {
        SpringApplication.run(ZookeeperProviderApplication.class, args);
    }
}
```

## 4.4 application.yml

1. `Spring Cloud`默认将`spring.application.name`作为`serviceId`
1. 必须知道注册中心的地址

```yml
server:
  port: 1110

spring:
  application:
    name: ZookeeperProvider

  cloud:
    zookeeper:
      connect-string: localhost:2181
```

## 4.5 Test

启动后，执行`bin/zkCli.sh`运行Zookeeper客户端交互程序

```sh
# 查询`/services`路径下的服务，即注册到zookeeper的应用
[zk: localhost:2181(CONNECTED) 34] ls /services
[ZookeeperProvider]

# 查看ZookeeperProvider服务的信息
[zk: localhost:2181(CONNECTED) 36] get /services/ZookeeperProvider

cZxid = 0x19
ctime = Sat Jul 14 14:58:20 CST 2018
mZxid = 0x19
mtime = Sat Jul 14 14:58:20 CST 2018
pZxid = 0x1e
cversion = 3
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 1

# 我们发现，上述节点信息中，并没有任何节点数据
# 奇怪的是，`numnumChildren`是1，说明有子节点
# 继续查看ZookeeperProvider的子节点
[zk: localhost:2181(CONNECTED) 37] ls /services/ZookeeperProvider
[b3735b44-3e69-4a1c-9de9-c7c813767bb6]

# 继续查看子节点的节点信息
[zk: localhost:2181(CONNECTED) 38] get /services/ZookeeperProvider/b3735b44-3e69-4a1c-9de9-c7c813767bb6
{"name":"ZookeeperProvider","id":"b3735b44-3e69-4a1c-9de9-c7c813767bb6","address":"192.168.31.104","port":1110,"sslPort":null,"payload":{"@class":"org.springframework.cloud.zookeeper.discovery.ZookeeperInstance","id":"application-1","name":"ZookeeperProvider","metadata":{}},"registrationTimeUTC":1531551844868,"serviceType":"DYNAMIC","uriSpec":{"parts":[{"value":"scheme","variable":true},{"value":"://","variable":false},{"value":"address","variable":true},{"value":":","variable":false},{"value":"port","variable":true}]}}
cZxid = 0x1e
ctime = Sat Jul 14 15:04:05 CST 2018
mZxid = 0x1e
mtime = Sat Jul 14 15:04:05 CST 2018
pZxid = 0x1e
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x1000013a8d70003
dataLength = 525
numChildren = 0
```

上述`/services/ZookeeperProvider/b3735b44-3e69-4a1c-9de9-c7c813767bb6`节点的节点内容如下（后面那串字符串是随机生成的临时id，你电脑上极大概率是不同的）

```json
{
    "name": "ZookeeperProvider", 
    "id": "b3735b44-3e69-4a1c-9de9-c7c813767bb6", 
    "address": "192.168.31.104", 
    "port": 1110, 
    "sslPort": null, 
    "payload": {
        "@class": "org.springframework.cloud.zookeeper.discovery.ZookeeperInstance", 
        "id": "application-1", 
        "name": "ZookeeperProvider", 
        "metadata": { }
    }, 
    "registrationTimeUTC": 1531551844868, 
    "serviceType": "DYNAMIC", 
    "uriSpec": {
        "parts": [
            {
                "value": "scheme", 
                "variable": true
            }, 
            {
                "value": "://", 
                "variable": false
            }, 
            {
                "value": "address", 
                "variable": true
            }, 
            {
                "value": ":", 
                "variable": false
            }, 
            {
                "value": "port", 
                "variable": true
            }
        ]
    }
}
```

于是，我们可以得出结论：

1. **Spring-Cloud-Zookeeper在注册服务时，会根据服务名创建一个节点（一个服务对应一个节点），其路径为`/services/<service name>`**
1. **一个服务可能会有多个实例存在，每个实例对应着一个子节点，子节点的名称是一个类似uuid的字符串，且子节点保存着对应实例的注册信息，包括ip，port等一系列元数据**

# 5 Ribbon-Consumer

**`ribbon-consumer`模块的目录结构如下**

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
│   │   │                   └── ribbon
│   │   │                       └── consumer
│   │   │                           ├── ConsumerGreetController.java
│   │   │                           ├── ConsumerGreetService.java
│   │   │                           └── RibbonConsumerApplication.java
│   │   └── resources
│   │       └── application.yml
```

1. pom.xml
1. ConsumerGreetController.java
1. ConsumerGreetService.java
1. RibbonConsumerApplication.java
1. application.yml

## 5.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-zookeeper-all`
1. `org.apache.zookeeper:zookeeper`
1. `org.springframework.boot:spring-boot-starter-web`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>ribbon-consumer</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-all</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.12</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

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

该模块对外提供的http服务，可以看到该服务仅仅对`zookeeper-provider`模块的http服务做了一层代理

```java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/13
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

该类实现服务间的调用，在`reqURL`中用服务名（ZookeeperProvider）代替服务方的ip:port信息，将地址映射交给`Zookeeper`来完成。可以看出来，这种方式比较繁琐，且不太友好，好比用`JDBC Connection`来进行数据库操作

```java
package org.liuyehcf.spring.cloud.ribbon.consumer;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/13
 */
@Service
public class ConsumerGreetService {
    @Resource
    private RestTemplate restTemplate;

    String sayHi(String name) {
        String reqURL = "http://ZookeeperProvider/hi?name=" + name;
        return restTemplate.getForEntity(reqURL, String.class).getBody();
    }
}
```

## 5.4 RibbonConsumerApplication.java

`@EnableDiscoveryClient`注解表示当前应用作为消费方

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
 * @date 2018/7/13
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

```yml
server:
  port: 1120

spring:
  application:
    name: RibbonConsumer

  cloud:
    zookeeper:
      connect-string: localhost:2181
```

## 5.6 Test

启动后，执行`bin/zkCli.sh`运行Zookeeper客户端交互程序

```sh
# 查询`/services`路径下的服务，即注册到zookeeper的应用
[zk: localhost:2181(CONNECTED) 39] ls /services
[ZookeeperProvider, RibbonConsumer]
```

同时，访问[http://localhost:1120/demo/ribbon/sayHi?name=strange](http://localhost:1120/demo/ribbon/sayHi?name=strange)可以看到提示信息

# 6 Feign-Consumer

`Feign`是一个声明式的伪Http客户端，它使得写Http客户端变得更简单。使用`Feign`，只需要创建一个接口并注解。它具有可插拔的注解特性，可使用`Feign` 注解和JAX-RS注解。`Feign`支持可插拔的编码器和解码器。`Feign`默认集成了`Ribbon`，并和`Zookeeper`结合，默认实现了负载均衡的效果

* **`Feign`采用的是基于接口的注解**
* **`Feign`整合了`Ribbon`**

**`feign-consumer`模块的目录结构如下**

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
│   │   │                   └── feign
│   │   │                       └── consumer
│   │   │                           ├── ConsumerGreetController.java
│   │   │                           ├── ConsumerGreetService.java
│   │   │                           └── FeignConsumerApplication.java
│   │   └── resources
│   │       └── application.yml
```

1. pom.xml
1. ConsumerGreetController.java
1. ConsumerGreetService.java
1. FeignConsumerApplication.java
1. application.yml

## 6.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-zookeeper-all`
1. `org.apache.zookeeper:zookeeper`
1. `org.springframework.cloud:spring-cloud-starter-openfeign`
1. `org.springframework.boot:spring-boot-starter-web`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>feign-consumer</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-all</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.12</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-openfeign</artifactId>
        </dependency>

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

该模块对外提供的http服务，可以看到该服务仅仅对`zookeeper-provier`模块的http服务做了一层代理

```java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/13
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
 * @date 2018/7/13
 */
@FeignClient(value = "ZookeeperProvider")
public interface ConsumerGreetService {
    @RequestMapping(value = "hi", method = RequestMethod.GET)
    String sayHi(@RequestParam("name") String name);
}
```

## 6.4 FeignConsumerApplication.java

`@EnableFeignClients`注解表明以`Feign`方式进行服务消费
`@EnableDiscoveryClient`注解表示当前应用作为消费方

```java
package org.liuyehcf.spring.cloud.feign.consumer;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * @author hechenfeng
 * @date 2018/7/13
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

```yml
server:
  port: 1130

spring:
  application:
    name: FeignConsumer

  cloud:
    zookeeper:
      connect-string: localhost:2181
```

## 6.6 Test

启动后，执行`bin/zkCli.sh`运行Zookeeper客户端交互程序

```sh
# 查询`/services`路径下的服务，即注册到zookeeper的应用
[zk: localhost:2181(CONNECTED) 40] ls /services
[ZookeeperProvider, FeignConsumer, RibbonConsumer]
```

同时，访问[http://localhost:1130/demo/feign/sayHi?name=strange](http://localhost:1130/demo/feign/sayHi?name=strange)可以看到提示信息

# 7 Config-Server

**`config-server`模块的目录结构如下**

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
│   │   │                   └── config
│   │   │                       └── server
│   │   │                           └── ConfigServerApplication.java
│   │   └── resources
│   │       └── application.yml
```

1. pom.xml
1. ConfigServerApplication.java
1. application.yml

## 7.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-zookeeper-all`
1. `org.apache.zookeeper:zookeeper`
1. `org.springframework.cloud:spring-cloud-config-server`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>config-server</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-all</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.12</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
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

## 7.2 ConfigServerApplication.java

`@EnableConfigServer`注解表示当前应用作为Config的服务端
`@EnableDiscoveryClient`注解表示当前应用作为消费方

```java
package org.liuyehcf.spring.cloud.config.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.config.server.EnableConfigServer;

/**
 * @author hechenfeng
 * @date 2018/7/13
 */
@EnableConfigServer
@EnableDiscoveryClient
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

```yml
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

    zookeeper:
      connect-string: localhost:2181
```

## 7.4 Test

启动后，执行`bin/zkCli.sh`运行Zookeeper客户端交互程序

```sh
# 查询`/services`路径下的服务，即注册到zookeeper的应用
[zk: localhost:2181(CONNECTED) 42] ls /services
[ZookeeperProvider, FeignConsumer, ConfigServer, RibbonConsumer]
```

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
├── src
│   ├── main
│   │   ├── java
│   │   │   └── org
│   │   │       └── liuyehcf
│   │   │           └── spring
│   │   │               └── cloud
│   │   │                   └── config
│   │   │                       └── client
│   │   │                           └── ConfigClientApplication.java
│   │   └── resources
│   │       ├── application.yml
│   │       └── bootstrap.yml
```

1. pom.xml
1. ConfigClientApplication.java
1. application.yml
1. bootstrap.yml

## 8.1 pom.xml

在`<dependencyManagement>`中引入Spring-Boot和Spring-Cloud相关依赖

在`<dependencies>`中引入如下依赖

1. `org.springframework.cloud:spring-cloud-starter-zookeeper-all`
1. `org.apache.zookeeper:zookeeper`
1. `org.springframework.cloud:spring-cloud-starter-config`
1. `org.springframework.boot:spring-boot-starter-web`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>spring-cloud-cluster-zookeeper-based</artifactId>
        <groupId>org.liuyehcf.spring.cloud</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>config-client</artifactId>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-zookeeper-all</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.apache.zookeeper</groupId>
                    <artifactId>zookeeper</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.zookeeper</groupId>
            <artifactId>zookeeper</artifactId>
            <version>3.4.12</version>
            <exclusions>
                <exclusion>
                    <groupId>org.slf4j</groupId>
                    <artifactId>slf4j-log4j12</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <!-- 这个依赖虽然没有显式用到，但是会在占位符注入时起作用 -->
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>

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

## 8.2 ConfigClientApplication.java

`@EnableDiscoveryClient`注解表示当前应用作为消费方

```java
package org.liuyehcf.spring.cloud.config.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author hechenfeng
 * @date 2018/7/13
 */
@EnableDiscoveryClient
@SpringBootApplication
@RestController
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

```yml
server:
  port: 1150
```

## 8.4 bootstrap.yml

应用读取配置中心参数时，会配置配置中心的地址等相关参数，而这部分配置需优先于`application.yml`被应用读取。`Spring Cloud`中的 `bootstrap.yml`是会比`application.yml`先加载的，所以这部分配置要定义在`bootstrap.yml`里面，这就引申出两个需要注意的地方

* `spring.application.name`：它应该配置在`bootstrap.yml`，它的名字应该等于配置中心的配置文件的`{application}`。**所以配置中心在给配置文件取名字时，最好让它等于对应的应用服务名**
* **配置中心与注册中心联合使用：若应用通过`serviceId`而非`url`来指定配置中心**，则`spring.cloud.zookeeper.connect-string`也要配置在`bootstrap.yml`，要不启动的时候，应用会找不到注册中心，自然也就找不到配置中心了
* **此外还必须配置`spring.cloud.zookeeper.discovery.register`属性。按照Spring-Cloud的官方文档，该属性默认是true，但是配置了`spring.cloud.config`相关配置项后，必须手动将`spring.cloud.zookeeper.discovery.register`属性设置为true，否则将不会注册到Zookeeper中**

```yml
spring:
  application:
    name: cloud.config.demo         # 指定配置中心配置文件的{application}

  cloud:
    config:
      profile: dev                  # 指定配置中心配置文件的{profile}
      label: master                 # 指定配置中心配置文件的{label}
      discovery:
        enabled: true               # 使用注册中心里面已注册的配置中心
        serviceId: ConfigServer     # 指定配置中心注册到注册中心的serviceId

    zookeeper:
      discovery:
        register: true              # 当前应用注册到Zookeeper中，其默认值为true，但是由于配置了`spring.cloud.config`的相关属性，还需要手动设置为true
      connect-string: localhost:2181
```

## 8.5 Test

启动后，执行`bin/zkCli.sh`运行Zookeeper客户端交互程序

```sh
# 查询`/services`路径下的服务，即注册到zookeeper的应用
[zk: localhost:2181(CONNECTED) 126] ls /services
[ZookeeperProvider, cloud.config.demo, FeignConsumer, ConfigServer, RibbonConsumer]
```

同时，访问如下URL，可以看到成功从`config-server`获取了配置信息

* [http://localhost:1150/demo/config/getHost](http://localhost:1150/demo/config/getHost)
* [http://localhost:1150/demo/config/getDescription](http://localhost:1150/demo/config/getDescription)

# 9 参考

* [Spring Cloud官方文档](http://cloud.spring.io/spring-cloud-static/Finchley.RELEASE/single/spring-cloud.html)
* [史上最简单的 SpringCloud 教程 | 终章](https://blog.csdn.net/forezp/article/details/70148833)
* [SpringCloud-Demo](https://jadyer.cn/category/#SpringCloud)

