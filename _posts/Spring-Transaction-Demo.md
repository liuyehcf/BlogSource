---
title: Spring-Transaction-Demo
date: 2018-08-10 11:41:14
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

**阅读更多**

<!--more-->

# 1 环境

1. `IDEA`
1. `Maven3.5.3`
1. `Spring-Boot-2.0.4.RELEASE`

# 2 Demo工程目录结构

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── spring
    │   │               └── tx
    │   │                   ├── Application.java
    │   │                   ├── DalConfig.java
    │   │                   ├── UserController.java
    │   │                   ├── UserDAO.groovy
    │   │                   ├── UserDO.java
    │   │                   └── UserService.java
    │   └── resources
    │       ├── application.properties
    │       └── create.sql
    └── test
        ├── java
        │   └── org
        │       └── liuyehcf
        │           └── spring
        │               └── tx
        │                   └── test
        │                       ├── BaseConfig.java
        │                       ├── TestApplication.java
        │                       ├── TestController.java
        │                       └── TestDalConfig.java
        └── resources
            └── db
                └── create_h2.sql
```

# 3 pom

Demo工程的依赖配置

1. mysql驱动
1. mybatis以及与spring集成
1. groovy
1. spring-jdbc
1. spring-boot

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>spring-tx</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <properties>
        <spring.boot.version>2.0.4.RELEASE</spring.boot.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.12</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.6</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>1.3.2</version>
        </dependency>
        <dependency>
            <groupId>org.codehaus.groovy</groupId>
            <artifactId>groovy-all</artifactId>
            <version>2.4.15</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>1.4.197</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>${spring.boot.version}</version>
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
                    <compilerId>groovy-eclipse-compiler</compilerId>

                    <!-- groovy与lombok并存需要以下两个配置，以及相应的dependency -->
                    <fork>true</fork>
                    <compilerArguments>
                        <javaAgentClass>lombok.launch.Agent</javaAgentClass>
                    </compilerArguments>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.codehaus.groovy</groupId>
                        <artifactId>groovy-eclipse-compiler</artifactId>
                        <version>2.9.2-01</version>
                    </dependency>
                    <dependency>
                        <groupId>org.codehaus.groovy</groupId>
                        <artifactId>groovy-eclipse-batch</artifactId>
                        <version>2.4.3-01</version>
                    </dependency>
                    <dependency>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>1.16.18</version>
                    </dependency>
                </dependencies>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring.boot.version}</version>
                <configuration>
                    <fork>true</fork>
                    <mainClass>org.liuyehcf.spring.tx.Application</mainClass>
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

# 4 Java

## 4.1 Application

不多说，SpringBoot应用的启动方式

```java
package org.liuyehcf.spring.tx;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
@SpringBootApplication(scanBasePackages = "org.liuyehcf.spring.tx")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

## 4.2 DalConfig

数据层的SpringBoot方式的配置，包括如下注解

* **`MapperScan`**：`Mapper`的扫描路径，通过`sqlSessionFactoryRef`参数指定sql会话工厂
* **`EnableTransactionManagement`**：开启声明式事务

**综上，一个数据层的完整配置包括如下几项**

1. **Mapper映射器**：通过`MapperScan`注解实现
1. **声明式事务**：通过`EnableTransactionManagement`注解开启
1. **数据源**
1. **事务管理器**
1. **会话工厂**

```java
package org.liuyehcf.spring.tx;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
@MapperScan(basePackages = "org.liuyehcf.spring.tx", sqlSessionFactoryRef = "sqlSessionFactory")
@EnableTransactionManagement
@Configuration
public class DalConfig {

    @Value("${db.url}")
    private String url;

    @Value("${db.username}")
    private String username;

    @Value("${db.password}")
    private String password;

    @Bean(name = "dataSource")
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }

    @Bean(name = "transactionManager")
    public DataSourceTransactionManager transactionManager() {
        DataSourceTransactionManager manager = new DataSourceTransactionManager();
        manager.setDataSource(dataSource());

        return manager;
    }

    @Bean(name = "sqlSessionFactory")
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        return sqlSessionFactoryBean.getObject();
    }
}
```

## 4.3 UserController

一个非常普通的`Controller`，包含一个健康检查接口以及一个业务接口（插入一个User）

```java
package org.liuyehcf.spring.tx;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
@RestController
@RequestMapping("/")
public class UserController {

    @Resource
    private UserService userService;

    @RequestMapping("/insert")
    @ResponseBody
    public String insert(@RequestParam("name") String name, @RequestParam("age") Integer age, @RequestParam("ex") Boolean ex) {
        try {
            userService.insert(name, age, ex);
            return "SUCCESS";
        } catch (Throwable e) {
            e.printStackTrace();
            return "FAILURE";
        }
    }

    @RequestMapping("/check_health")
    @ResponseBody
    public String checkHealth() {
        return "OK";
    }
}
```

## 4.4 UserDAO

该类用`groovy`来编写，需要引入`org.codehaus.groovy:groovy-all`才能编译。使用`groovy`的好处是可以写整段的sql语句，而不需要进行字符串拼接

```groovy
package org.liuyehcf.spring.tx

import org.apache.ibatis.annotations.Insert
import org.apache.ibatis.annotations.Mapper
import org.apache.ibatis.annotations.SelectKey
import org.apache.ibatis.mapping.StatementType

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
@Mapper
interface UserDAO {
    @Insert('''
        INSERT INTO user(
        name,
        age
        )VALUES(
        #{name},
        #{age}
        )
    ''')
    @SelectKey(before = false, keyProperty = "id", resultType = Long.class, statementType = StatementType.STATEMENT, statement = "SELECT LAST_INSERT_ID()")
    int insert(UserDO userDO)
}
```

## 4.5 UserDO

```java
package org.liuyehcf.spring.tx;

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
public class UserDO {
    private Long id;
    private String name;
    private Integer age;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    @Override
    public String toString() {
        return "UserDO{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", age=" + age +
                '}';
    }
}
```

## 4.6 UserService

这里通过一个参数`ex`来控制是否抛出异常，便于校验`@Transactional`是否进行了回滚

```java
package org.liuyehcf.spring.tx;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/8/11
 */
@Service
public class UserService {

    @Resource
    private UserDAO userDAO;

    @Transactional
    public int insert(String name, Integer age, Boolean ex) {
        UserDO userDO = new UserDO();
        userDO.setName(name);
        userDO.setAge(age);

        int res = userDAO.insert(userDO);

        if (ex) {
            throw new RuntimeException();
        }

        return res;
    }
}
```

# 5 Resource

## 5.1 application.properties

配置项

```property
server.port=7001
db.url=jdbc:mysql://127.0.0.1:3306/mybatis?autoReconnect=true&useSSL=false
db.username=root
db.password=xxx
```

## 5.2 create.sql

上述工程用到的数据表的建表语句

```sql
DROP DATABASE mybatis;
CREATE DATABASE mybatis;

USE mybatis;

CREATE TABLE user(
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL,
age INT UNSIGNED NOT NULL,
PRIMARY KEY(id),
UNIQUE KEY(name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
```

## 5.3 测试步骤

将应用启动后，访问[http://localhost:7001/insert?name=liuyehcf&age=10&ex=true](http://localhost:7001/insert?name=liuyehcf&age=10&ex=true)，带上了`ex=true`参数时，`UserService.insert`方法将会抛出异常。`@Transactional`注解在不指定`rollbackFor`属性时，默认回滚`RuntimeException`以及`Error`，但是`Exception`不会回滚

查看数据库，发现并没有插入数据，说明已经回滚了

# 6 集成测试

需要人肉访问url还是比较麻烦的，这里希望实现自动化的集成测试

## 6.1 BaseConfig

集成测试配置的基类，避免重复配置。集成测试类继承该基类即可

```java
package org.liuyehcf.spring.tx.test;

import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * @author hechenfeng
 * @date 2018/8/26
 */
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = TestApplication.class)
public class BaseConfig {

}
```

## 6.2 TestDalConfig

集成测试数据源配置，这里选择的是`h2-database`

```java
package org.liuyehcf.spring.tx.test;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;

/**
 * @author hechenfeng
 * @date 2018/8/26
 */
@MapperScan(basePackages = "org.liuyehcf.spring.tx", sqlSessionFactoryRef = "sqlSessionFactory")
@EnableTransactionManagement
@Configuration
public class TestDalConfig {
    @Bean(name = "dataSource")
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .addScript("db/create_h2.sql")
                .build();
    }

    @Bean(name = "transactionManager")
    public DataSourceTransactionManager transactionManager() {
        DataSourceTransactionManager manager = new DataSourceTransactionManager();
        manager.setDataSource(dataSource());

        return manager;
    }

    @Bean(name = "sqlSessionFactory")
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        return sqlSessionFactoryBean.getObject();
    }
}
```

## 6.3 TestApplication

集成测试`SpringBoot`启动类。这里用到了`@ComponentScan`注解的excludeFilters属性，用于排除一些类，本例中排除了启动类`Application`以及数据源配置类`DalConfig`，这样一来，集成测试加载的数据源配置就只有`TestDalConfig`了

为什么需要额外排除`Application`？如果只排除`DalConfig`的话，`Application`仍然在`TestApplication`配置的扫描路径下，且`excludeFilters`属性只对`TestApplication`有效，对`Application`无效，因此`Application`还是能够扫描到`DalConfig`

```java
package org.liuyehcf.spring.tx.test;

import org.liuyehcf.spring.tx.Application;
import org.liuyehcf.spring.tx.DalConfig;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.FilterType;

/**
 * @author hechenfeng
 * @date 2018/8/26
 */
@SpringBootApplication(scanBasePackages = "org.liuyehcf.spring.tx")
@ComponentScan(basePackages = "org.liuyehcf.spring.tx",
        excludeFilters = @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = {Application.class, DalConfig.class})
)
public class TestApplication {
}
```

## 6.4 TestController

普通测试类，继承`BaseConfig`来获取集成测试的相关配置

```java
package org.liuyehcf.spring.tx.test;

import org.junit.Test;
import org.liuyehcf.spring.tx.UserController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.transaction.annotation.Transactional;

/**
 * @author hechenfeng
 * @date 2018/8/26
 */
public class TestController extends BaseConfig {

    @Autowired
    private UserController userController;

    @Test
    @Transactional
    public void test() {
        userController.insert("liuye", 10, false);
    }
}
```

## 6.5 create_h2.sql

**注意，千万别忘了`SET mode MySQL;`这句**

```sql
SET mode MySQL;

CREATE TABLE user(
id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
name VARCHAR(20) NOT NULL,
age INT UNSIGNED NOT NULL,
PRIMARY KEY(id),
UNIQUE KEY(name)
)ENGINE=InnoDB;
```

# 7 源码剖析

**`Spring-tx`利用了`Spring-aop`，在目标方法上织入了一系列事务相关的逻辑。相关织入逻辑可以参考{% post_link SourceAnalysis-Spring-AOP %}。这里仅介绍事务相关的增强逻辑**

**分析的起点是`TransactionInterceptor.invoke`，该类是事务对应的增强类，或者说拦截器（Spring AOP的本质就是一系列的拦截器）**

```java
    @Override
    @Nullable
    public Object invoke(MethodInvocation invocation) throws Throwable {
        // Work out the target class: may be {@code null}.
        // The TransactionAttributeSource should be passed the target class
        // as well as the method, which may be from an interface.
        Class<?> targetClass = (invocation.getThis() != null ? AopUtils.getTargetClass(invocation.getThis()) : null);

        // Adapt to TransactionAspectSupport's invokeWithinTransaction...
        return invokeWithinTransaction(invocation.getMethod(), targetClass, invocation::proceed);
    }
```

**沿着调用链往下走，下面是`TransactionAspectSupport.invokeWithinTransaction`，主要关注三个方法调用**

1. **`createTransactionIfNecessary`方法**：在必要时，创建一个事务。与事务传播方式等等有关系
1. **`completeTransactionAfterThrowing`方法**：拦截到异常时，根据异常类型选择是否进行回滚操作
1. **`commitTransactionAfterReturning`方法**：未拦截到异常时，提交本次事务

```java
    @Nullable
    protected Object invokeWithinTransaction(Method method, @Nullable Class<?> targetClass,
            final InvocationCallback invocation) throws Throwable {

        // If the transaction attribute is null, the method is non-transactional.
        TransactionAttributeSource tas = getTransactionAttributeSource();
        final TransactionAttribute txAttr = (tas != null ? tas.getTransactionAttribute(method, targetClass) : null);
        final PlatformTransactionManager tm = determineTransactionManager(txAttr);
        final String joinpointIdentification = methodIdentification(method, targetClass, txAttr);

        if (txAttr == null || !(tm instanceof CallbackPreferringPlatformTransactionManager)) {
            // Standard transaction demarcation with getTransaction and commit/rollback calls.
            // 有必要时，创建一个事务
            TransactionInfo txInfo = createTransactionIfNecessary(tm, txAttr, joinpointIdentification);
            Object retVal = null;
            try {
                // This is an around advice: Invoke the next interceptor in the chain.
                // This will normally result in a target object being invoked.
                retVal = invocation.proceedWithInvocation();
            }
            catch (Throwable ex) {
                // target invocation exception
                // 当拦截到异常时的处理逻辑，可能会回滚，也可能不会滚
                completeTransactionAfterThrowing(txInfo, ex);
                throw ex;
            }
            finally {
                cleanupTransactionInfo(txInfo);
            }
            // 正常的处理逻辑，即commit本次事务
            commitTransactionAfterReturning(txInfo);
            return retVal;
        }

        else {
            final ThrowableHolder throwableHolder = new ThrowableHolder();

            // It's a CallbackPreferringPlatformTransactionManager: pass a TransactionCallback in.
            try {
                Object result = ((CallbackPreferringPlatformTransactionManager) tm).execute(txAttr, status -> {
                    TransactionInfo txInfo = prepareTransactionInfo(tm, txAttr, joinpointIdentification, status);
                    try {
                        return invocation.proceedWithInvocation();
                    }
                    catch (Throwable ex) {
                        if (txAttr.rollbackOn(ex)) {
                            // A RuntimeException: will lead to a rollback.
                            if (ex instanceof RuntimeException) {
                                throw (RuntimeException) ex;
                            }
                            else {
                                throw new ThrowableHolderException(ex);
                            }
                        }
                        else {
                            // A normal return value: will lead to a commit.
                            throwableHolder.throwable = ex;
                            return null;
                        }
                    }
                    finally {
                        cleanupTransactionInfo(txInfo);
                    }
                });

                // Check result state: It might indicate a Throwable to rethrow.
                if (throwableHolder.throwable != null) {
                    throw throwableHolder.throwable;
                }
                return result;
            }
            catch (ThrowableHolderException ex) {
                throw ex.getCause();
            }
            catch (TransactionSystemException ex2) {
                if (throwableHolder.throwable != null) {
                    logger.error("Application exception overridden by commit exception", throwableHolder.throwable);
                    ex2.initApplicationException(throwableHolder.throwable);
                }
                throw ex2;
            }
            catch (Throwable ex2) {
                if (throwableHolder.throwable != null) {
                    logger.error("Application exception overridden by commit exception", throwableHolder.throwable);
                }
                throw ex2;
            }
        }
    }
```

## 7.1 createTransactionIfNecessary

我们先来看一下`createTransactionIfNecessary`方法，该方法的核心逻辑就是

1. **`getTransaction`**：获取`TransactionStatus`对象（该对象包含了当前事务的一些状态信息，包括`是否是新事务`、`是否为rollback-only模式`、`是否有savepoint`），基本Spring事务的核心概念都在这个方法中有所体现，包括事务的传播方式等等
1. **`prepareTransactionInfo`**：创建一个`TransactionInfo`对象（该对象持有了一系列事务相关的对象，包括`PlatformTransactionManager`、`TransactionAttribute`、`TransactionStatus`等对象）

```java
    protected TransactionInfo createTransactionIfNecessary(@Nullable PlatformTransactionManager tm,
            @Nullable TransactionAttribute txAttr, final String joinpointIdentification) {

        // If no name specified, apply method identification as transaction name.
        if (txAttr != null && txAttr.getName() == null) {
            txAttr = new DelegatingTransactionAttribute(txAttr) {
                @Override
                public String getName() {
                    return joinpointIdentification;
                }
            };
        }

        TransactionStatus status = null;
        if (txAttr != null) {
            if (tm != null) {
                // 获取TransactionStatus对象
                status = tm.getTransaction(txAttr);
            }
            else {
                if (logger.isDebugEnabled()) {
                    logger.debug("Skipping transactional joinpoint [" + joinpointIdentification +
                            "] because no transaction manager has been configured");
                }
            }
        }
        // 获取TransactionInfo对象
        return prepareTransactionInfo(tm, txAttr, joinpointIdentification, status);
    }

```

## 7.2 completeTransactionAfterThrowing

**继续跟踪`TransactionAspectSupport.completeTransactionAfterThrowing`方法。首先会根据异常类型以及事务配置的属性值来判断，本次是否进行回滚操作。主要的判断逻辑在`txInfo.transactionAttribute.rollbackOn`方法中，本Demo对应的`TransactionAttribute`接口的实现类是
`RuleBasedTransactionAttribute`**

```java
    protected void completeTransactionAfterThrowing(@Nullable TransactionInfo txInfo, Throwable ex) {
        if (txInfo != null && txInfo.getTransactionStatus() != null) {
            if (logger.isTraceEnabled()) {
                logger.trace("Completing transaction for [" + txInfo.getJoinpointIdentification() +
                        "] after exception: " + ex);
            }
            if (txInfo.transactionAttribute != null && txInfo.transactionAttribute.rollbackOn(ex)) {
                try {
                    txInfo.getTransactionManager().rollback(txInfo.getTransactionStatus());
                }
                catch (TransactionSystemException ex2) {
                    logger.error("Application exception overridden by rollback exception", ex);
                    ex2.initApplicationException(ex);
                    throw ex2;
                }
                catch (RuntimeException | Error ex2) {
                    logger.error("Application exception overridden by rollback exception", ex);
                    throw ex2;
                }
            }
            else {
                // We don't roll back on this exception.
                // Will still roll back if TransactionStatus.isRollbackOnly() is true.
                try {
                    txInfo.getTransactionManager().commit(txInfo.getTransactionStatus());
                }
                catch (TransactionSystemException ex2) {
                    logger.error("Application exception overridden by commit exception", ex);
                    ex2.initApplicationException(ex);
                    throw ex2;
                }
                catch (RuntimeException | Error ex2) {
                    logger.error("Application exception overridden by commit exception", ex);
                    throw ex2;
                }
            }
        }
    }
```

**我们接着来看一下`RuleBasedTransactionAttribute.rollbackOn`方法**

```java
    public boolean rollbackOn(Throwable ex) {
        if (logger.isTraceEnabled()) {
            logger.trace("Applying rules to determine whether transaction should rollback on " + ex);
        }

        RollbackRuleAttribute winner = null;
        int deepest = Integer.MAX_VALUE;

        if (this.rollbackRules != null) {
            for (RollbackRuleAttribute rule : this.rollbackRules) {
                int depth = rule.getDepth(ex);
                if (depth >= 0 && depth < deepest) {
                    deepest = depth;
                    winner = rule;
                }
            }
        }

        if (logger.isTraceEnabled()) {
            logger.trace("Winning rollback rule is: " + winner);
        }

        // User superclass behavior (rollback on unchecked) if no rule matches.
        if (winner == null) {
            logger.trace("No relevant rollback rule found: applying default rules");
            // 默认的判断逻辑
            return super.rollbackOn(ex);
        }

        return !(winner instanceof NoRollbackRuleAttribute);
    }
```

**`RuleBasedTransactionAttribute`的父类`DefaultTransactionAttribute`的`rollbackOn`方法如下，可以看到，默认的回滚异常类型就是`RuntimeException`以及`Error`**

```java
    public boolean rollbackOn(Throwable ex) {
        return (ex instanceof RuntimeException || ex instanceof Error);
    }
```

# 8 小插曲

## 8.1 忘记mysql密码

以`Mac OS(10.13.6)`、`mysql-5.7.22`为例

```sh
# 关闭mysql server
mysql.server stop

# 以安全模式运行mysql
mysqld_safe --skip-grant-tables &

# 无密码登录
mysql -u root

# 进入数据库 mysql，并修改密码
# 这里修改的是authentication_string字段，不同的版本中，修改的字段名称可能不同，你可以看下user表的字段有哪些，大概就能知道代表密码的字段是哪个
update mysql.user set authentication_string=PASSWORD("xxx") where User='root';
flush privileges;
```

# 9 todo

1. 何时注入事务上下文

```java
org.springframework.transaction.interceptor.TransactionInterceptor.invokeWithinTransaction
* createTransactionIfNecessary
* prepareTransactionInfo
org.springframework.transaction.interceptor.TransactionAspectSupport#transactionInfoHolder
```

1. @Transactional with @Test

@Transactional默认会在执行完测试方法后回滚

```java
org.springframework.test.context.junit4.statements.RunAfterTestMethodCallbacks
org.springframework.test.context.junit4.statements.RunAfterTestClassCallbacks
org.springframework.test.context.transaction.TransactionalTestExecutionListener
org.springframework.test.context.transaction.TransactionContext
// 注意flaggedForRollback字段
```

1. 调用堆栈的时序图
1. `<tx:annotation-driven transaction-manager="transactionManager" order="0"/>` 好像无法改变实际的order值
1. `Establishing SSL connection without server's identity verification is not recommended.` 
    * [Warning about SSL connection when connecting to MySQL database](https://stackoverflow.com/questions/34189756/warning-about-ssl-connection-when-connecting-to-mysql-database)

# 10 参考

* [is there a way to force a transactional rollback without encountering an exception?](https://stackoverflow.com/questions/832375/is-there-a-way-to-force-a-transactional-rollback-without-encountering-an-excepti)
* [Spring整合Junit测试，并且配置事务](https://blog.csdn.net/u013516966/article/details/46699165)
* [can @Order be applied on @Transactional?](https://stackoverflow.com/questions/35460436/can-order-be-applied-on-transactional)
* [spring aop 和Transaction一起使用执行顺序问题](https://my.oschina.net/yugj/blog/615396)
