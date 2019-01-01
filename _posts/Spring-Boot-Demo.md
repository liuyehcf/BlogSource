---
title: Spring-Boot-Demo
date: 2017-11-24 12:07:06
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 环境

1. `IDEA`
1. `Maven 3.5.2`
1. `Spring Boot`

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
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <!-- 继承自Spring Boot Parent -->
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.9.RELEASE</version>
    </parent>

    <modelVersion>4.0.0</modelVersion>

    <artifactId>spring-boot</artifactId>

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
                    <mainClass>org.liuyehcf.spring.boot.SampleApplication</mainClass>
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

__注意，如果是Web应用的话，`org.springframework.boot:spring-boot-starter-web`是必须的，这个依赖项包含了内嵌的Tomcat容器__

## 3.2 不继承自spring-boot

如果不想继承自`org.springframework.boot:spring-boot-starter-parent`，那么需要通过`<dependencyManagement>`元素引入依赖

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>spring-boot</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

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
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>1.5.9.RELEASE</version>
                <configuration>
                    <fork>true</fork>
                    <mainClass>org.liuyehcf.spring.boot.SampleApplication</mainClass>
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

1. `@EnableAutoConfiguration`：能够自动配置spring的上下文，试图猜测和配置你想要的bean类，通常会自动根据你的类路径和你的bean定义自动配置
1. `@ComponentScan`：会自动扫描指定包下的全部标有@Component的类，并注册成bean，当然包括@Component下的子注解@Service，@Repository，@Controller
1. `@SpringBootApplication`：@SpringBootApplication = (默认属性)@Configuration + @EnableAutoConfiguration + @ComponentScan

__测试__

1. `http://localhost:8080/home/`
1. 其他两个API可以通过post man测试

# 6 Bean的Java配置

从Spring3.0开始，就提供了一种与xml配置文件对称的Java版本的配置

__核心注解__

1. @Configuration
1. @Bean
1. @Value

## 6.1 情景1

```xml
    <bean id="service" class="org.liuyehcf.springboot.Service">
        <property name="name" value="${my.name}" />
    </bean>
```

这对这种配置，建议直接在Service类的name属性上标记@Value注解。如下

```Java
@Component
public class Service{
    @Value("${my.name}")
    private String name;

    @PostConstruct
    public void init() {
        ...
    }
    ...
}
```

属性注入优先于@PostConstruct

## 6.2 情景2

```xml
    <bean id="service" class="org.liuyehcf.springboot.Service">
        <constructor-arg name="name" value="${my.name}" />
        <constructor-arg name="age" value="${my.age}" />
        <constructor-arg name="robot" ref="${my.robot}" />
    </bean>
```

对于这种配置，也可以在构造方法的参数列表中加上@Value注解，以及@Autowired注解。如下

```Java
@Component
public class Service{
    public Service(@Value("${my.name}") String name,
                   @Value("${my.name}") String name,
                   @Autowired("${my.robot}") Robot robot){
        ...
    }

    ...
}
```

__注意，构造方法注入对象，只能用@Autowired而不能用@Resource__

## 6.3 情景3

```xml
    <bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource"  destroy-method="close">  
        <property name="driverClassName" value="${db.driverClass}"></property>  
        <property name="url" value="${db.url}"></property>  
        <property name="username" value="${db.username}"></property>  
        <property name="password" value="${db.password}"></property>    
    </bean>

    <bean id="transactionManager"
          class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <bean id="transactionTemplate"
          class="org.springframework.transaction.support.TransactionTemplate">
        <property name="transactionManager" ref="transactionManager"/>
    </bean>

    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="configLocation" value="classpath:dal/mybatis_config.xml"/>
    </bean>

    <bean id="mapperScannerConfigurer" class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="org.liuyehcf"/>
        <property name="sqlSessionFactoryBeanName" value="sqlSessionFactory"/>
    </bean>

    <tx:annotation-driven transaction-manager="dataSourceTransactionManager"/>

```

对于这种三方类而言，我们没法在源码上增加注解来注入属性或者对象，我们可以通过@Bean注解来配置。如下

```Java
@Configuration
@MapperScan(basePackages = "org.liuyehcf", sqlSessionFactoryRef = "sqlSessionFactory")
@EnableTransactionManagement
public class DataSourceConfig{
    //@Bean注解还有initMethod属性
    @Bean(name = "dataSource", destroyMethod = "close")
    public DataSource dataSource() {
        BasicDataSource dataSource = new BasicDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("${db.url}");
        dataSource.setUsername("${db.username}");
        dataSource.setPassword("${db.password}");
        return dataSource;
    }

    @Bean(name = "transactionManager")
    public DataSourceTransactionManager transactionManager() {
        DataSourceTransactionManager manager = new DataSourceTransactionManager();
        manager.setDataSource(dataSource());

        return manager;
    }

    @Bean(name = "transactionTemplate")
    public TransactionTemplate transactionTemplate() {
        TransactionTemplate template = new TransactionTemplate();
        template.setTransactionManager(transactionManager());
        return template;
    }

    @Bean(name = "sqlSessionFactory")
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        sqlSessionFactoryBean.setConfigLocation(new ClassPathResource("dal/mybatis_config.xml"));
        return sqlSessionFactoryBean.getObject();
    }
}
```

Spring会为DataSourceConfig生成代理类（Cglib），不用担心多次调用dataSource()方法会创建多个不同的对象

__注意，MapperScannerConfigurer的等效配置必须用@MapperScan注解，否则，整个配置类就会有问题（原因尚不清楚）__

__此外，`<tx:annotation-driven transaction-manager="dataSourceTransactionManager"/>`的等效配置，不知道是不是@EnableTransactionManagement__

## 6.4 情景4

```xml
    <bean id="tool" class="com.baeldung.factorybean.ToolFactory">
        <property name="factoryId" value="9090"/>
        <property name="toolId" value="1"/>
    </bean>
```

对于FactoryBean，我们仍然可以像配置普通Bean一样配置它。__注意必须返回FactoryBean（不要调用getObject()返回Bean对象）__，如果这个FactoryBean实现了一些Aware接口，那么在生成FactoryBean对象时会进行一些额外操作，然后再调用getObject方法创建Bean

```Java
@Configuration
public class FactoryBeanAppConfig {
  
    @Bean(name = "tool")
    public ToolFactory toolFactory() {
        ToolFactory factory = new ToolFactory();
        factory.setFactoryId(7070);
        factory.setToolId(2);
        return factory;
    }
}
```

# 7 属性注入

Spring的属性注入（形如`${xxx.yyy.zzz}`的占位符）有如下几种方式

1. @Value注解
1. xml配置文件中，例如`<property name = "Jack" value = "${jack.name}/>`

注意，像logback配置文件（`logback.xml`）中的属性占位符，Spring默认是不解析的。如果想要使其生效，可以采用如下方式

1. 将`logback.xml`改名为`logback-spring.xml`，就可以利用`springProperty`元素来引入Spring属性值
    * `<springProperty scope="context" name="fluentHost" source="myapp.fluentd.host"/>`
    * 其中，`source`的内容就是Spring属性文件中的属性名称
    * 然后，就可以在logback的配置文件中引用`${fluentHost}`
1. 利用`property`元素导入Spring属性配置文件
    * `<property resource="application.properties"/>`
    * 这种方式不需要Spring配合，完全是logback的一种方式

# 8 Test

## 8.1 @ComponentScan.excludeFilters

当我们在项目中需要做集成测试的时候，我们可以选择`h2 database`来代替`mysql`数据库，但通常数据源的配置仍然包含在指定的包扫描路径下。__那么如何让Spring加载`h2 database`的数据源配置，而不是加载`mysql`的数据源配置呢？__

__我们可以用`@ComponentScan`注解的`excludeFilters`属性来实现这个目标__，`@ComponentScan`注解可以指定排除某个或某些`Bean`。可选的匹配类型有如下几种

1. `FilterType.ANNOTATION`：排除指定注解标记的Bean，注解的类用`classes`属性指定
1. `FilterType.ASSIGNABLE_TYPE`：排除指定类，用`classes`属性指定
1. `FilterType.ASPECTJ`：排除匹配指定模式的类，用`pattern`属性指定`ASPECTJ`格式的通配符
1. `FilterType.REGEX`：排除匹配指定模式的类，用`pattern`属性指定正则表达式
1. `FilterType.CUSTOM`：即用户自定义的`org.springframework.core.type.filter.TypeFilter`

__配置示例：排除项目中的数据源配置__

```Java
@Slf4j
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = {TestApplication.class})
public class BaseConfig {
}

@Configuration
@MapperScan(basePackages = {"xxx.yyy.zzz"})
public class TestEmbeddedDatabaseConfig {

    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .addScript("db/create_db.sql")
                .build();
    }

    @Bean
    public DataSourceTransactionManager transactionManager() {
        return new DataSourceTransactionManager(dataSource());
    }

    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource());
        sessionFactory.setTypeAliasesPackage("xxx.yyy.zzz");
        return sessionFactory.getObject();
    }

    @Bean
    public SqlSessionTemplate sqlSessionTemplate() throws Exception {
        return new SqlSessionTemplate(sqlSessionFactory());
    }
}

@SpringBootApplication
@ComponentScan(basePackages = {"xxx.yyy.aaa", "xxx.yyy.bbb"},
        excludeFilters = {@ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, classes = {DataSourceConfig.class, Application.class})})
@PropertySource("classpath:application-test.properties")
public class TestApplication {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

__注意，在上面的`@ComponentScan`注解中，排除了两个类，一个是`DataSourceConfig`，即数据源配置；另一个是`Application`。这么做是有必要的，如果仅排除了`DataSourceConfig`（仅对当前`@ComponentScan`有效），`Application`仍然会被扫描到，而`Application`是应用的启动类，也会配置`@ComponentScan`注解，仍然会扫描到`DataSourceConfig`__

```
# 不配置excludeFilters属性
TestApplication
    ├── Application
    |       ├── DataSourceConfig
    ├── DataSourceConfig

# 配置了excludeFilters属性，但只排除了DataSourceConfig
TestApplication
    ├── Application
    |       ├── DataSourceConfig

# 配置了excludeFilters属性，同时排除了DataSourceConfig以及Application
TestApplication
```

## 8.2 @ContextHierarchy

## 8.3 Spring集成测试&Mockito

__`@MockBean`__：生成一个mock对象，并且添加到Spring的上下文中，将替换掉原有的`bean`，被注入到其他依赖该`bean`的`bean`当中

# 9 配置项

SpringBoot推崇约定大于配置，通常情况下，我们只需要配置少数几个参数，应用就可以正常启动。但是，知道SpringBoot究竟提供了多少默认的配置也是很有用的，给一个[传送门](https://docs.spring.io/spring-boot/docs/2.0.3.RELEASE/reference/htmlsingle/)。在页面上搜索`server.port=8080`，就能定位到配置项说明的地方

SpringBoot默认加载的属性文件，其路径为`classpath:application.properties`或者`classpath:application.yml`。若要修改这个路径，必须用`@PropertySource`注解来标注（而不是用`@ImportResource`注解哦）

# 10 Auto-Configuration

`Spring`集成了非常多的优秀项目，我们在使用这些项目时，仅仅只需要引入相关的依赖即可（对于`Spring-Boot`集成的项目，通常有`spring-boot-starter`后缀），例如`Flowable`

```xml
        <dependency>
            <groupId>org.flowable</groupId>
            <artifactId>flowable-spring-boot-starter</artifactId>
            <version>6.3.0</version>
        </dependency>
```

我们无需做任何配置，`Spring`就会为我们自动初始化这些项目。那么`Spring`如何实现这种`code-free`的`Auto-Configuration`呢？

__答案就是基于约定，`Spring`会默认加载`classpath:META-INF/spring.factories`这个配置文件（加载的代码在`org.springframework.core.io.support.SpringFactoriesLoader`类中）__

# 11 排错

当我采用第二种pom文件时（__不继承spring boot的pom文件__），启动时会产生如下异常信息

```Java
...
Caused by: java.lang.NoSuchMethodError: org.springframework.web.accept.ContentNegotiationManagerFactoryBean.build()Lorg/springframework/web/accept/ContentNegotiationManager;
...
```

这是由于我在项目的父pom文件中引入了5.X.X版本的Spring依赖，这与`spring-boot-dependencies`引入的Spring依赖会冲突（例如，加载了低版本的class文件，但是运行时用到了较高版本特有的方法，于是会抛出`NoSuchMethodError`），将项目父pom文件中引入的Spring的版本改为4.3.13.RELEASE就行

# 12 参考

* [Spring-Boot官方文档](https://docs.spring.io/spring-boot/docs/2.0.3.RELEASE/reference/htmlsingle/)
* [sing-boot-maven-without-a-parent](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#using-boot-maven-without-a-parent)
* [@SpringBootApplication的使用](http://blog.csdn.net/u013473691/article/details/52353923)
* [SpringBoot非官方教程 | 终章：文章汇总](https://blog.csdn.net/forezp/article/details/70341818)
* [Exclude subpackages from Spring autowiring?](https://stackoverflow.com/questions/10725192/exclude-subpackages-from-spring-autowiring)
* [Spring Boot - Unit Testing and Mocking with Mockito and JUnit](http://www.springboottutorial.com/spring-boot-unit-testing-and-mocking-with-mockito-and-junit)
