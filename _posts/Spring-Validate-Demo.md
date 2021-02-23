---
title: Spring-Validate-Demo
date: 2018-06-25 09:54:37
tags: 
- 摘录
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 Demo工程目录结构

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── spring
    │   │               └── validate
    │   │                   ├── Application.java
    │   │                   ├── MainController.java
    │   │                   ├── dto
    │   │                   │   └── UserDTO.java
    │   │                   ├── group
    │   │                   │   ├── Create.java
    │   │                   │   └── Update.java
    │   │                   └── service
    │   │                       ├── UserService.java
    │   │                       └── UserServiceImpl.java
    │   └── resources
    └── test
        └── java
            └── org
                └── liuyehcf
                    └── spring
                        └── validate
                            └── TestValidate.java
```

# 2 pom文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>spring-validate</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

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
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>1.5.9.RELEASE</version>
                <configuration>
                    <fork>true</fork>
                    <mainClass>org.liuyehcf.spring.validate.Application</mainClass>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

`spring-boot-starter-web`依赖项包含了如下三个与validate相关的依赖

1. `org.hibernate:hibernate-validator`
1. `com.fasterxml.jackson.core:jackson-databind`
1. `org.springframework:spring-context`：提供`@Validated`相关注解

# 3 group

以下两个接口仅作为validator的分组（例如，作为`@NotBlank`的`groups`属性值），别无它用

```java
package org.liuyehcf.spring.validate.group;
/**
 * @date 2018/7/10
 */
public interface Create {
}

```

```java
package org.liuyehcf.spring.validate.group;

/**
 * @date 2018/7/10
 */
public interface Update {
}
```

# 4 DTO

DTO中用validator相关的注解对字段进行标注，并用`groups`属性进行分组

```java
package org.liuyehcf.spring.validate.dto;

import org.hibernate.validator.constraints.NotBlank;
import org.hibernate.validator.constraints.Range;
import org.liuyehcf.spring.validate.group.Create;
import org.liuyehcf.spring.validate.group.Update;

/**
 * @date 2018/7/10
 */
public class UserDTO {
    @NotBlank(groups = {Create.class, Update.class}, message = "name cannot be blank")
    private String name;

    @Range(min = 1, max = 100, groups = Create.class, message = "age must between 1 and 100")
    private Integer age;

    @NotBlank(groups = Update.class, message = "address cannot be blank")
    private String address;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
```

# 5 Service

下面我们说明一下，如何让validate在`Service Level`生效（如果在`Controller Level`使用validator，那么只需要在参数处标记`@Validated`注解即可。相比于在`Service Level`使用validator要简单许多）

UserService用validator相关注解进行标注，以声明式的方式进行参数校验

1. **必须**，用`@Validated`标记接口（可以指明校验的组别）
1. **非必须**，用`@Validated`标记方法（可以指明校验的组别），会覆盖类级别的`@Validated`注解
1. **必须**，用`@Valid`标记参数，声明对参数进行校验

```java
package org.liuyehcf.spring.validate.service;

import org.liuyehcf.spring.validate.group.Create;
import org.liuyehcf.spring.validate.group.Update;
import org.liuyehcf.spring.validate.dto.UserDTO;
import org.springframework.validation.annotation.Validated;

import javax.validation.Valid;

/**
 * @date 2018/7/10
 */
@Validated
public interface UserService {
    @Validated(Create.class)
    String createUser(@Valid UserDTO userDTO);

    @Validated(Update.class)
    String updateUser(@Valid UserDTO userDTO);
}

```

```java
package org.liuyehcf.spring.validate.service;

import org.liuyehcf.spring.validate.dto.UserDTO;
import org.springframework.stereotype.Service;

/**
 * @date 2018/7/10
 */
@Service("userService")
public class UserServiceImpl implements UserService {

    @Override
    public String createUser(UserDTO userDTO) {
        return "createUser success";
    }

    @Override
    public String updateUser(UserDTO userDTO) {
        return "updateUser success";
    }
}
```

# 6 Controller

在校验参数时，如果参数非法，那么会抛出`ConstraintViolationException`异常，错误信息（`@NotBlank`等注解指定的提示信息）藏在`ConstraintViolation`中，ConstraintViolationException异常对象持有`Set<ConstraintViolation>`。每一个异常校验对应着一个ConstraintViolation对象

我们可以先捕获ConstraintViolationException异常，然后取出所有异常信息，拼接成提示信息然后返回

```java
package org.liuyehcf.spring.validate;

import org.liuyehcf.spring.validate.dto.UserDTO;
import org.liuyehcf.spring.validate.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;

/**
 * @date 2018/7/10
 */
@Controller
@RequestMapping("/")
public class MainController {

    @Resource
    private UserService userService;

    @RequestMapping("/create")
    @ResponseBody
    public String createUser(@RequestBody UserDTO userDTO) {
        try {
            return userService.createUser(userDTO);
        } catch (ConstraintViolationException e) {
            StringBuilder sb = new StringBuilder();
            for (ConstraintViolation<?> constraintViolation : e.getConstraintViolations()) {
                sb.append(constraintViolation.getMessage())
                        .append(";");
            }
            if (sb.length() != 0) {
                sb.setLength(sb.length() - 1);
            }
            return sb.toString();
        }
    }

    @RequestMapping("/update")
    @ResponseBody
    public String updateUser(@RequestBody UserDTO userDTO) {
        try {

            return userService.updateUser(userDTO);
        } catch (ConstraintViolationException e) {
            StringBuilder sb = new StringBuilder();
            for (ConstraintViolation<?> constraintViolation : e.getConstraintViolations()) {
                sb.append(constraintViolation.getMessage())
                        .append(";");
            }
            if (sb.length() != 0) {
                sb.setLength(sb.length() - 1);
            }
            return sb.toString();
        }
    }
}
```

# 7 Application

```java
package org.liuyehcf.spring.validate;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

/**
 * @date 2018/7/10
 */
@EnableAutoConfiguration
@ComponentScan("org.liuyehcf.spring.validate")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class);
    }
}
```

# 8 Validate With Junit

```java
package org.liuyehcf.spring.validate;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.liuyehcf.spring.validate.dto.UserDTO;
import org.liuyehcf.spring.validate.group.Create;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;
import java.util.Set;

import static org.junit.Assert.assertEquals;

/**
 * @author hechenfeng
 * @date 2018/7/10
 */
public class TestValidate {
    private static ValidatorFactory validatorFactory;
    private static Validator validator;

    @BeforeClass
    public static void createValidator() {
        validatorFactory = Validation.buildDefaultValidatorFactory();
        validator = validatorFactory.getValidator();
    }

    @AfterClass
    public static void close() {
        validatorFactory.close();
    }

    @Test
    public void testGroupCreate() {
        UserDTO userDTO = new UserDTO();
        userDTO.setName("小明");
        userDTO.setAge(0);

        Set<ConstraintViolation<UserDTO>> validates = validator.validate(userDTO, Create.class);

        assertEquals(validates.size(), 1);
        ConstraintViolation<UserDTO> violation = validates.iterator().next();

        assertEquals(violation.getPropertyPath().toString(), "age");
    }
}
```

# 9 总结

在实际项目当中，我们会把接口以及DTO单独作为一个模块进行维护，此时我们可以用validate注解来告诉接口调用方，哪些参数是必须的，哪些不是必须的，同时也省下了重复的参数校验工作。我们可以在接口模块中引入如下依赖（`scope`为`provided`，避免造成依赖污染，尽量保持接口模块依赖关系的简洁性）

```xml
    <dependency>
        <groupId>org.hibernate</groupId>
        <artifactId>hibernate-validator</artifactId>
        <scope>provided</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>spring-context</artifactId>
        <scope>provided</scope>
    </dependency>
```

# 10 参考

* [Bean Validation Unit Testing](http://farenda.com/java/bean-validation-unit-testing/)
