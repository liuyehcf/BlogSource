---
title: SLF4J
date: 2017-12-12 16:15:35
tags: 
- 摘录
categories: 
- Java
- Framework
- Log
---

**阅读更多**

<!--more-->

# 1 SLF4J概述

SLF4J，即简单日志门面（Simple Logging Facade for Java, SLF4J），不是具体的日志解决方案，它只服务于各种各样的日志系统。按照官方的说法，SLF4J是一个用于日志系统的简单Facade，允许最终用户在部署其应用时使用其所希望的日志System

实际上，SLF4J所提供的核心API是一些接口以及一个LoggerFactory的工厂类。从某种程度上，SLF4J有点类似JDBC，不过比JDBC更简单，在JDBC中，你需要指定驱动程序，而在使用SLF4J的时候，不需要在代码中或配置文件中指定你打算使用那个具体的日志系统。如同使用JDBC基本不用考虑具体数据库一样，SLF4J提供了统一的记录日志的接口，只要按照其提供的方法记录即可，最终日志的格式、记录级别、输出方式等通过具体日志系统的配置来实现，因此可以在应用中灵活切换日志系统

**简单地说，SLF4J只提供日志框架的接口，而不提供具体的实现。因此SLF4J必须配合具体的日志框架才能正常工作**

# 2 Maven依赖

```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-log4j12</artifactId>
    <version>1.7.25</version>
</dependency>
```

`slf4j-log4j12`模块包含了`slf4j-api`以及`log4j`，因此使用slf4j+log4j只需要依赖`slf4j-log4j12`即可

# 3 Log4j

Log4j由三个重要的组件构成：

1. **日志信息的优先级**：从高到低有ERROR、WARN、 INFO、DEBUG，分别用来指定这条日志信息的重要程度
1. **日志信息的输出目的地**：指定了日志将打印到控制台还是文件中
1. **日志信息的输出格式**：控制了日志信息的显示内容

## 3.1 Log级别

1. `ALL Level`：等级最低，用于打开所有日志记录
1. `DEBUG Level`：指出细粒度信息事件对调试应用程序是非常有帮助的
1. `INFO level`：表明消息在粗粒度级别上突出强调应用程序的运行过程
1. `WARN level`：表明会出现潜在错误的情形
1. `ERROR level`：指出虽然发生错误事件，但仍然不影响系统的继续运行
1. `FATAL level`：指出每个严重的错误事件将会导致应用程序的退出
1. `OFF Level`：等级最高，用于关闭所有日志记录
* Log4j建议只使用四个级别，优先级从高到低分别是ERROR、WARN、INFO、DEBUG。通过在这里定义的级别，您可以控制到应用程序中相应级别的日志信息的开关。比如在这里定义了INFO级别，则应用程序中所有DEBUG级别的日志信息将不被打印出来，也是说大于等于的级别的日志才输出

## 3.2 Log4j配置

可以完全不使用配置文件，而是在代码中配置Log4j环境。但是，使用配置文件将使应用程序更加灵活。**Log4j支持两种配置文件格式**，一种是XML格式的文件，一种是Java特性文件（键 = 值）。下面我们介绍使用Java特性文件做为配置文件的方法

### 3.2.1 配置根Logger

配置根Logger，其语法如下：
```
log4j.rootLogger = [ level ] , appenderName, appenderName, ...
```

* level是日志记录的优先级，分为OFF、FATAL、ERROR、WARN、INFO、DEBUG、ALL或者自定义的级别。Log4j建议只使用四个级别，优先级从高到低分别是ERROR、WARN、INFO、DEBUG。通过在这里定义的级别，可以控制到应用程序中相应级别的日志信息的开关。比如在这里定义了INFO级别，则应用程序中所有DEBUG级别的日志信息将不被打印出来
* appenderName就是指B日志信息输出到哪个地方。可以同时指定多个输出目的地

### 3.2.2 配置日志信息输出目的地Appender

语法如下：
```
log4j.appender.<appenderName> = <fully qualified name of appender class>
log4j.appender.<appenderName>.<option1> = <value1>
...
log4j.appender.<appenderName>.<optionN> = <valueN>
```

**其中，Log4j提供的appender有以下几种**

1. `org.apache.log4j.ConsoleAppender`：控制台
1. `org.apache.log4j.FileAppender`：文件
1. `org.apache.log4j.DailyRollingFileAppender`：每天产生一个日志文件
1. `org.apache.log4j.RollingFileAppender`：文件大小到达指定尺寸的时候产生一个新的文件
1. `org.apache.log4j.WriterAppender`：将日志信息以流格式发送到任意指定的地方

### 3.2.3 配置日志信息的格式

语法如下：
```
log4j.appender.<appenderName> = <fully qualified name of appender class>
log4j.appender.<appenderName>.<option1> = <value1>
...
log4j.appender.<appenderName>.<optionN> = <valueN>
```

**其中，Log4j提供的layout有以下几种**

1. `org.apache.log4j.HTMLLayout`：以HTML表格形式布局
1. `org.apache.log4j.PatternLayout`：可以灵活地指定布局模式
1. `org.apache.log4j.SimpleLayout`：包含日志信息的级别和信息字符串
1. `org.apache.log4j.TTCCLayout`：包含日志产生的时间、线程、类别等等信息

**Log4J采用类似C语言中的printf函数的打印格式格式化日志信息**

1. `%%`：输出一个"%"字符
1. `%c`：输出所属的类目，通常就是所在类的全名
1. `%d`：输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyyy-MM-dd HH:mm:ss}，输出类似：2017-03-22 18:14:34,829
1. `%F`：输出日志消息产生时所在的文件名称
1. `%l`：输出日志事件的发生位置，包括类目名、发生的线程，以及在代码中的行数。举例：Testlog4.main(TestLog4.java:10)
1. `%L`：输出代码中的行号
1. `%m`：输出代码中指定的消息,产生的日志具体信息
1. `%n`：输出一个回车换行符，Windows平台为"rn"，Unix平台为"n"
1. `%p`：输出优先级，即DEBUG，INFO，WARN，ERROR，FATAL
1. `%r`：输出自应用启动到输出该log信息耗费的毫秒数
1. `%t`：输出产生该日志事件的线程名
1. `%x`：输出和当前线程相关联的NDC（嵌套诊断环境）,尤其用到像java servlets这样的多客户多线程的应用中

# 4 配置文件示例

```
### 设置###
log4j.rootLogger = debug,debug,info,error,stdout

### 输出信息到控制抬 ###
log4j.appender.stdout = org.apache.log4j.ConsoleAppender
log4j.appender.stdout.Target = System.out
log4j.appender.stdout.layout = org.apache.log4j.PatternLayout
log4j.appender.stdout.layout.ConversionPattern = [%-5p] %d{yyyy-MM-dd HH:mm:ss,SSS} method:%l - %m%n

### DEBUG 级别以上的日志到指定路径 ###
log4j.appender.debug = org.apache.log4j.DailyRollingFileAppender
log4j.appender.debug.File = ./aliyun/target/logs/debug.log
log4j.appender.debug.Append = true
log4j.appender.debug.Threshold = DEBUG
log4j.appender.debug.layout = org.apache.log4j.PatternLayout
log4j.appender.debug.layout.ConversionPattern = %-d{yyyy-MM-dd HH:mm:ss}  [ %t:%r ] - [ %p ]  %m%n

### INFO 级别以上的日志到指定路径 ###
log4j.appender.info = org.apache.log4j.DailyRollingFileAppender
log4j.appender.info.File = ./aliyun/target/logs/info.log
log4j.appender.info.Append = true
log4j.appender.info.Threshold = INFO
log4j.appender.info.layout = org.apache.log4j.PatternLayout
log4j.appender.info.layout.ConversionPattern = %-d{yyyy-MM-dd HH:mm:ss}  [ %t:%r ] - [ %p ]  %m%n

### 输出ERROR 级别以上的日志到指定路径 ###
log4j.appender.error = org.apache.log4j.DailyRollingFileAppender
log4j.appender.error.File =./aliyun/target/logs/error.log
log4j.appender.error.Append = true
log4j.appender.error.Threshold = ERROR
log4j.appender.error.layout = org.apache.log4j.PatternLayout
log4j.appender.error.layout.ConversionPattern = %-d{yyyy-MM-dd HH:mm:ss}  [ %t:%r ] - [ %p ]  %m%n

```

# 5 参考

* [详细的log4j配置使用流程](http://blog.csdn.net/sunny_na/article/details/55212029)
