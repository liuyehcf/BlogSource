---
title: Spring-AOP-Demo
date: 2018-01-04 22:43:54
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 Maven依赖最小集

所有的`<version>`在`<dependencyManagement>`中进行管理，均为`RELEASE`，下面仅列出`groupId`以及`artifactId`

```xml
    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-aop</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.aspectj</groupId>
            <artifactId>aspectjrt</artifactId>
        </dependency>
        <dependency>
            <groupId>org.aspectj</groupId>
            <artifactId>aspectjweaver</artifactId>
        </dependency>
    </dependencies>
```

# 2 注解版本

## 2.1 applicationContext.xml配置如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/aop
        http://www.springframework.org/schema/aop/spring-aop.xsd">
    <!-- 配置扫描路径 -->
    <context:component-scan base-package="org.liuyehcf.spring.aop"/>

    <!-- 使得AOP相关的注解生效 -->
    <aop:aspectj-autoproxy/>
</beans>
```

## 2.2 AOP配置类

```Java
package org.liuyehcf.spring.aop;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

import java.util.Arrays;

@Component
@Aspect
public class SimpleSpringAdvisor {
    @Pointcut("execution(* org.liuyehcf.spring.aop.HelloService.*(..))")
    public void pointCut() {
    }

    @After("pointCut()")
    public void after(JoinPoint joinPoint) {
        System.out.println("after aspect executed");
    }

    @Before("pointCut()")
    public void before(JoinPoint joinPoint) {

        System.out.println("before aspect executing");
    }

    @AfterReturning(pointcut = "pointCut()", returning = "returnVal")
    public void afterReturning(JoinPoint joinPoint, Object returnVal) {
        System.out.println("afterReturning executed, return result is "
                + returnVal);
    }

    @Around("pointCut()")
    public void around(ProceedingJoinPoint proceedingJoinPoint) throws Throwable {
        System.out.println("around start..");
        Class<?> clazz = null;
        String methodName = null;
        Object[] args = null;
        Object result = null;
        try {
            clazz = proceedingJoinPoint.getSignature().getDeclaringType();
            methodName = proceedingJoinPoint.getSignature().getName();
            args = proceedingJoinPoint.getArgs();
            result = proceedingJoinPoint.proceed(args);
        } catch (Throwable ex) {
            System.out.println("error in around");
            throw ex;
        } finally {
            System.out.println("class: " + clazz);
            System.out.println("methodName: " + methodName);
            System.out.println("args: " + Arrays.toString(args));
            System.out.println("result: " + result);
        }
    }

    @AfterThrowing(pointcut = "pointCut()", throwing = "error")
    public void afterThrowing(JoinPoint jp, Throwable error) {
        System.out.println("error:" + error);
    }
}
```

其中

* `@Aspect`：配置切面，注意Spring默认不支持该注解，因此需要在配置文件中增加`<aop:aspectj-autoproxy/>`使得该注解能够生效
* `@Pointcut`：配置切点
* `@After`、`@Before`、`@AfterReturning`、`@Around`：配置增强

## 2.3 被增强的Bean

Spring会根据配置的匹配规则，__为匹配成功的bean创建代理__，因此Bean的类型不能是final的，否则无法通过cglib创建代理。除此之外，无须其他配置

# 3 XML版本

## 3.1 applicationContext.xml配置如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:aop="http://www.springframework.org/schema/aop"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        http://www.springframework.org/schema/context/spring-context.xsd
        http://www.springframework.org/schema/aop
        http://www.springframework.org/schema/aop/spring-aop.xsd">
    <!-- 配置扫描路径 -->
    <context:component-scan base-package="org.liuyehcf.spring.aop"/>

    <!-- 配置MethodInterceptor接口的实现类 -->
    <bean id="simpleMethodInterceptor" class="org.liuyehcf.spring.aop.SimpleMethodInterceptor"/>
    <bean id="simpleBeforeMethodAdvisor" class="org.liuyehcf.spring.aop.SimpleBeforeMethodAdvisor"/>

    <aop:config>
        <!-- 配置切点 -->
        <aop:pointcut id="simplePointcut" expression="execution(* org.liuyehcf.spring.aop.HelloService.*(..))"/>

        <!-- 配置切面，包括切点和增强 -->
        <aop:advisor advice-ref="simpleMethodInterceptor" pointcut-ref="simplePointcut"/>
        <aop:advisor advice-ref="simpleBeforeMethodAdvisor" pointcut-ref="simplePointcut"/>

    </aop:config>
</beans>
```

## 3.2 增强类

SimpleMethodInterceptor简单地实现了MethodInterceptor接口，注意必须执行`        Object result = methodInvocation.proceed();`这一句

```Java
package org.liuyehcf.spring.aop;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

public class SimpleMethodInterceptor implements MethodInterceptor {
    @Override
    public Object invoke(MethodInvocation methodInvocation) throws Throwable {
        System.out.println("before invoke");
        Object result = methodInvocation.proceed();
        System.out.println("after invoke");
        return result;
    }
}

```

SimpleBeforeMethodAdvisor实现了MethodBeforeAdvice接口，在Spring启动过程中，SimpleBeforeMethodAdvisor会被封装成MethodInterceptor接口的实现类，本质上还是遵循了MethodInterceptor接口。除此之外，还有MethodAfterAdvice、ThrowAdvice、AfterReturningAdvice

```Java
package org.liuyehcf.spring.aop;

import org.springframework.aop.MethodBeforeAdvice;
import org.springframework.lang.Nullable;

import java.lang.reflect.Method;

/**
 * Created by HCF on 2018/1/4.
 */
public class SimpleBeforeMethodAdvisor implements MethodBeforeAdvice {
    @Override
    public void before(Method method, Object[] objects, @Nullable Object o) throws Throwable {
        System.out.println("before method advice");
    }
}
```

