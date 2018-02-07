---
title: MyBatis-Demo
date: 2018-02-07 09:22:04
tags: 
- 原创
categories: 
- Java
- Framework
- MyBatis
---

__目录__

<!-- toc -->
<!--more-->

# 纯MyBatisDemo

## Demo目录结构

```
```

## MyBatis配置文件源码清单

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 定义别名 -->
    <typeAliases>
        <typeAlias alias="crmUserDO" type="org.liuyehcf.mybatis.CrmUserDO"/>
    </typeAliases>

    <!-- 定义数据库信息，默认使用id为development的environment -->
    <environments default="development">
        <environment id="development">
            <!-- 采用JDBC事务管理 -->
            <transactionManager type="JDBC"/>

            <!-- 配置数据库连接信息 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://127.0.0.1:3306/mybatis"/>
                <property name="username" value="root"/>
                <property name="password" value="123456"/>
            </dataSource>
        </environment>
    </environments>

    <!-- 定义映射器 -->
    <mappers>
        <mapper resource="org/liuyehcf/mybatis/crm-user.xml"/>
    </mappers>
</configuration>
```

## Java源码清单

```Java
```

## 映射器配置文件源码清单

```xml
```

## todo

1. 对于没有@Param注解标记的参数，且不是JavaBean，那么在test中想要引用该参数，需要用到`_parameter`，就像这样`<if test="_parameter != null and _parameter !=''">`
    * 该字符串，出现在`TextSqlNode`以及`DynamicContext`中
    * 对于有@Param注解标记的参数，那么test用该注解指定的名字就能拿到该参数

1. DynamicSqlSource

1. 生成占位符  MappedStatement.getBoundSql

1. 执行真正的SQL在SimpleExecutor.doUpdate中执行

1. 参数的绑定发生在SimpleExecutor.doUpdate