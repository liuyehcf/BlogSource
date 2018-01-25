---
title: Mybatis-映射器
date: 2018-01-23 18:52:55
tags: 
- 摘录
categories: 
- Java
- Framework
- Mybatis
---

__目录__

<!-- toc -->
<!--more-->

# 1 映射器主要元素

| 元素名称 | 描述 | 备注 |
|:--|:--|:--|
| select | 查询语句、最常用、最复杂的元素 | 可自定义参数、返回结果集 |
| insert | 插入语句 | 执行后返回一个整数，代表插入的行数 |
| update | 更新语句 | 执行后返回一个整数，代表更新的条数 |
| delete | 删除语句 | 执行后返回一个整数，代表删除的条数 |
| parameterMap | 定义参数映射关系 | 即将被删除的元素，不建议使用 |
| sql | 允许定义一部分SQL，然后在各个地方引用 | 例如，一张表列名，我们可以一次定义，在多个SQL语句中引用 |
| resultMap | 用来描述从数据库结果集中来加载对象，它是最复杂、最强大的元素 | 提供映射规则 |
| cache | 给定命名空间的缓存配置 | \ |
| cache-ref | 其他命名空间缓存配置的引用 | \ |

# 2 select元素

| 元素 | 说明 | 备注 |
|:--|:--|:--|
| __id__ | 它和__Mapper的命名空间__组合起来是唯一的，提供给MyBatis调用 | 如果命名空间和id组合起来不唯一，MyBatis将抛出异常 |
| __parameterType__ | 你可以给出类的全命名，也可以给出类的别名，__但使用别名必须是MyBatis内部定义或者自定义的__ | 我们可以选择JavaBean、Map等复杂的参数类型传递给SQL |
| parameterMap | 即将废弃的元素，不做讨论 | \ |
| __resultType__ | __定义类的全路径，在允许自动匹配的情况下，结果集将通过JavaBean的规范映射；或定义为int、double、float等基本类型；也可以使用别名，但是要符合别名规范，不能喝resultMap同时使用__ | 它是我们常用的参数之一，比如我们统计总条数就可以把它设置为int |
| __resultMap__ | 它是映射集的引用，执行强大的映射功能，我们可以使用resultType或者resultMap其中的一个，__resultMap可以给予我们自定义映射规则的机会__ | __它是MyBatis最复杂的元素，可以配置映射规则、级联、typeHandler等__ |
| flushCache | 它的作用是在调用SQL后，是否要求MyBatis清空之前查询的本地缓存和二级缓存 | 取值为布尔值，默认false |
| useCache | 启动二级缓存的开关，是否要求MyBatis将此次结果缓存 | 取值为布尔值，默认true |
| timeout | 设置超时参数，等超时的时候将抛出异常，单位为秒 | 默认值是数据库厂商提供的JDBC驱动所设置的秒数 |
| fetchSize | 获取记录的总条数设定 | 默认值是数据库厂商提供的JDBC驱动所设置的条数 |
| statementType | 告诉MyBatis使用哪个JDBC的Statement工作，取值为STATEMENT（Statement）、PREPARED（PreparedStatement）、CallableStatement | 默认值为PREPARED |
| resultSetType | 这是对JDBC的resultSet接口而言，它的值包括`FORWARD_ONLY`（游标允许向前访问）、`SCROLL_SENSITIVE`(双向滚动，但不及时更新，就是如果数据库里的数据修改过，并不在resultSet中反映出来）、`SCROLL_INSENSITIVE`（双向滚动，并及时跟踪数据库的更新，以便更改resultSet中的数据) | 默认值是数据库厂商提供的JDBC驱动所设置的 |
| databaseId | 数据库标识 | 提供多种数据库的支持 |
| resultOrdered | 这个设置仅适用于嵌套结果集select语句。如果为true，就是假设包含了嵌套结果或者是分组了。当返回一个主结果行的时候，就不能对前面结果集的引用。这就确保了在获取嵌套的结果集的时候不至于导致内存不够用 | 取值为布尔值，true/false，默认值为false |
| resultSets | 适合于多个结果集的情况，它将列出执行SQL后每个结果集的名称，每个名称之间用逗号分隔 | 很少使用 |

## 2.1 自动映射

__有这样一个参数`autoMappingBehavior`，当它不设置为NONE的时候，MyBatis会提供自动映射功能：只要返回的`SQL列名`和`JavaBean属性`一致，MyBatis就会帮助我们回填这些字段而无需任何配置__

在实际的情况中，大部分的数据库规范都是要求每个单词用下划线分隔，而Java则是用驼峰命名法来命名，于是__使用列的别名（`AS`）__就可以使得MyBatis自动映射，__或者直接在配置文件中开启驼峰命名方式__

自动映射可以在settings元素中配置autoMappingBehavior属性值来设置其策略。它包含3个值

1. `NONE`：取消自动映射
1. `PARTIAL`：只会自动映射，没有定义嵌套结果集映射的结果集
1. `FULL`：会自动映射任意复杂的结果集（无论是否嵌套）
* 默认值为PARTIAL，所以在默认情况下，可以做到当前对象的映射，使用FULL是嵌套映射，在性能上会下降

## 2.2 传递多个参数

自动将所有DO进行映射，这样一来就不用写map了，但随之而来的开销就是`AS`
```xml
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="appserverDataSource"/>
        <property name="typeAliasesPackage" value="com.alibaba.alink.appserver.common.dal.dataobject"/>
        <property name="mapperLocations" value="classpath*:com/alibaba/alink/appserver/common/dal/sqlmap/*.xml"/>
    </bean>
```

`#{}`  `${}`的区别

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* 《深入浅出MyBatis技术原理与实战》
* [Mybatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
