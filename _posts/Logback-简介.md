---
title: Logback-简介
date: 2018-01-12 20:50:17
tags: 
- 摘录
categories: 
- Java
- Framework
- Logback
---

__目录__

<!-- toc -->
<!--more-->

# 1 LogBack的结构

LogBack被分为3个组件

1. logback-core
1. logback-classic
1. logback-access

其中logback-core提供了LogBack的核心功能，是另外两个组件的基础

logback-classic则实现了Slf4j的API，所以当想配合Slf4j使用时，需要将logback-classic加入classpath

logback-access是为了集成Servlet环境而准备的，可提供HTTP-access的日志接口

# 2 配置文件

## 2.1 `<configuration>`

根元素`<configuration>`包含的属性包括：

1. scan：当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true
1. scanPeriod：设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒。当scan为true时，此属性生效。默认的时间间隔为1分钟
1. debug：当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false

__示例__

```xml
<configuration scan="true" scanPeriod="60 second" debug="false">  
      <!-- 其他配置省略-->  
</configuration>
```

## 2.2 `<configuration>`各个子元素

### 2.2.1 `<contextName>`

`<contextName>`用于设置上下文名称

每个logger都关联到logger上下文，默认上下文名称为"default"。但可以使用`<contextName>`设置成其他名字，用于区分不同应用程序的记录。一旦设置，不能修改

__示例__

```xml
<configuration scan="true" scanPeriod="60 second" debug="false">  
      <contextName>myAppName</contextName>  
      <!-- 其他配置省略-->  
</configuration>
```

### 2.2.2 `<property>`

`<property>`用来定义变量值的元素

`<property>`有两个属性，name和value

1. 其中name的值是变量的名称
1. value的值时变量定义的值
* 通过`<property>`定义的值会被插入到logger上下文中。定义变量后，可以使`${}`来使用变量。

__示例__

```xml
<configuration scan="true" scanPeriod="60 second" debug="false">  
      <property name="APP_Name" value="myAppName" />   
      <contextName>${APP_Name}</contextName>  
      <!-- 其他配置省略-->  
</configuration>
```

### 2.2.3 `<timestamp>`

`<timestamp>`元素用于获取时间戳字符串，有两个属性

* key:标识此<timestamp>的名字
* datePattern：设置将当前时间（解析配置文件的时间）转换为字符串的模式，遵循Java.txt.SimpleDateFormat的格式。

### 2.2.4 `<logger>`

用来设置某一个包或者具体的某一个类的日志打印级别、以及指定`<appender>`

`<logger>`仅有一个name属性，一个可选的level和一个可选的additivity属性。

* name：用来指定受此logger约束的某一个包或者具体的某一个类。
* level：用来设置打印级别，大小写无关：__TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF__，还有一个特殊值__INHERITED__或者同义词__NULL__，代表强制执行上级的级别。
    * 如果未设置此属性，那么当前logger将会继承上级的级别。
* additivity：是否向上级logger传递打印信息。默认是true。

`<logger>`可以包含零个或多个`<appender-ref>`元素，标识这个appender将会添加到这个logger

### 2.2.5 `<logger>`

`<logger>`也是`<logger>`元素，但是它是__根logger__。__只有一个level属性，应为已经被命名为"root"__

* level：用来设置打印级别，大小写无关：__TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF__，__不能__设置为__INHERITED__或者同义词__NULL__。默认是DEBUG

`<root>`可以包含零个或多个`<appender-ref>`元素，标识这个appender将会添加到这个logger

### 2.2.6 `<appender>`

`<appender>`是`<configuration>`的子元素，是负责写日志的组件。<appender>有两个必要属性name和class。name指定appender名称，class指定appender的全限定名。

#### 2.2.6.1 ConsoleAppender

把日志添加到控制台，有以下子元素：

* `<encoder>`：对日志进行格式化
* `<target>`：字符串System.out或者 System.err，默认System.out

__示例__

```xml
<configuration>  
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">  
    <encoder>  
      <pattern>%-4relative [%thread] %-5level %logger{35} - %msg %n</pattern>  
    </encoder>  
  </appender>  
 
  <root level="DEBUG">  
    <appender-ref ref="STDOUT" />  
  </root>  
</configuration>
```

#### 2.2.6.2 FileAppender

把日志添加到文件，有以下子元素：

* `<file>`：被写入的文件名，可以是相对目录，也可以是绝对目录，如果上级目录不存在会自动创建，没有默认值
* `<append>`：如果是true，日志被追加到文件结尾，如果是false，清空现存文件，默认是true
* `<encoder>`：对记录事件进行格式化。
* `<prudent>`：如果是true，日志会被安全的写入文件，即使其他的FileAppender也在向此文件做写入操作，效率低，默认是false

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [从零开始玩转logback](http://www.importnew.com/22290.html)
* [logback 配置详解](https://www.jianshu.com/p/1ded57f6c4e3)

