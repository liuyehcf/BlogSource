---
title: Mybatis-映射文件详解
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

自动将所有DO进行映射，这样一来就不用写map了，但随之而来的开销就是`AS`
```xml
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="appserverDataSource"/>
        <property name="typeAliasesPackage" value="com.alibaba.alink.appserver.common.dal.dataobject"/>
        <property name="mapperLocations" value="classpath*:com/alibaba/alink/appserver/common/dal/sqlmap/*.xml"/>
    </bean>
```

`#{}`  `${}`的区别

# 1 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [Mybatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
