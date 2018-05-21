---
title: Swagger-Demo
date: 2018-01-19 13:19:19
tags: 
- 原创
categories: 
- Java
- Framework
- Swagger
---

__阅读更多__

<!--more-->

# 1 环境

1. IDEA
1. Maven3.3.9
1. Spring Boot
1. Swagger

# 2 pom文件

引入Spring-boot以及Swagger的依赖即可，完整内容如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>swagger</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.6.1</version>
        </dependency>
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger-ui</artifactId>
            <version>2.6.1</version>
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

# 3 Swagger Config Bean

```Java
package org.liuyehcf.swagger.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("org.liuyehcf.swagger")) // 包路径
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Spring Boot - Swagger - Demo")
                .description("THIS IS A SWAGGER DEMO")
                .termsOfServiceUrl("http:// liuyehcf.github.io") // 这个不知道干嘛的
                .contact("liuye")
                .version("1.0.0")
                .build();
    }

}
```

1. @Configuration：让Spring来加载该类配置
1. @EnableSwagger2：启用Swagger2
* 注意替换`.apis(RequestHandlerSelectors.basePackage("org.liuyehcf.swagger"))`这句中的包路径

# 4 Controller

```Java
package org.liuyehcf.swagger.controller;

import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.liuyehcf.swagger.entity.User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserController {

    private static Map<Integer, User> userMap = new HashMap<>();

    @ApiOperation(value = "GET_USER_API_1", notes = "获取User方式1")
    @RequestMapping(value = "getApi1/{id}", method = RequestMethod.GET)
    @ResponseBody
    public User getUserByIdAndName1(
            @ApiParam(name = "id", value = "用户id", required = true) @PathVariable int id,
            @ApiParam(name = "name", value = "用户名字", required = true) @RequestParam String name) {
        if (userMap.containsKey(id)) {
            User user = userMap.get(id);
            if (user.getName().equals(name)) {
                return user;
            }
        }
        return null;
    }

    @ApiOperation(value = "GET_USER_API_2", notes = "获取User方式2")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "用户id", required = true, paramType = "path", dataType = "int"),
            @ApiImplicitParam(name = "name", value = "用户名字", required = true, paramType = "query", dataType = "String")
    })
    @RequestMapping(value = "getApi2/{id}", method = RequestMethod.GET)
    @ResponseBody
    public User getUserByIdAndName2(
            @PathVariable int id,
            @RequestParam String name) {
        if (userMap.containsKey(id)) {
            User user = userMap.get(id);
            if (user.getName().equals(name)) {
                return user;
            }
        }
        return null;
    }

    @ApiOperation(value = "ADD_USER_API_1", notes = "增加User方式1")
    @RequestMapping(value = "/addUser1", method = RequestMethod.POST)
    @ResponseBody
    public String addUser1(
            @ApiParam(name = "user", value = "用户User", required = true) @RequestBody User user) {
        if (userMap.containsKey(user.getId())) {
            return "failure";
        }
        userMap.put(user.getId(), user);
        return "success";
    }

    @ApiOperation(value = "ADD_USER_API_2", notes = "增加User方式2")
    @ApiImplicitParam(name = "user", value = "用户User", required = true, paramType = "body", dataType = "User")
    @RequestMapping(value = "/addUser2", method = RequestMethod.POST)
    @ResponseBody
    public String addUser2(@RequestBody User user) {
        if (userMap.containsKey(user.getId())) {
            return "failure";
        }
        userMap.put(user.getId(), user);
        return "success";
    }

}
```

我们通过@ApiOperation注解来给API增加说明、通过@ApiParam、@ApiImplicitParams、@ApiImplicitParam注解来给参数增加说明（__其实不加这些注解，API文档也能生成，只不过描述主要来源于函数等命名产生，对用户并不友好，我们通常需要自己增加一些说明来丰富文档内容__）

* @ApiImplicitParam最好指明`paramType`与`dataType`属性。`paramType`可以是`path`、`query`、`body`
* @ApiParam没有`paramType`与`dataType`属性，因为该注解可以从参数（参数类型及其Spring MVC注解）中获取这些信息

## 4.1 User

Controller中用到的实体类

```Java
package org.liuyehcf.swagger.entity;

public class User {
    private int id;

    private String name;

    private String address;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
```

# 5 Application

```Java
package org.liuyehcf.swagger;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

@EnableAutoConfiguration
@ComponentScan("org.liuyehcf.swagger.*")
public class UserApplication {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(UserApplication.class, args);
    }
}
```

成功启动后，即可访问`http://localhost:8080/swagger-ui.html`

# 6 参考

* [Spring Boot中使用Swagger2构建强大的RESTful API文档](https://www.jianshu.com/p/8033ef83a8ed)
* [Spring4集成Swagger：真的只需要四步，五分钟速成](http://blog.csdn.net/blackmambaprogrammer/article/details/72354007)
* [Swagger](https://swagger.io/)
