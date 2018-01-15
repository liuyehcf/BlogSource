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

# 2 &lt;configuration&gt;

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

# 3 &lt;configuration&gt;各个子元素

## 3.1 &lt;contextName&gt;

`<contextName>`用于设置上下文名称

每个logger都关联到logger上下文，默认上下文名称为"default"。但可以使用`<contextName>`设置成其他名字，用于区分不同应用程序的记录。一旦设置，不能修改

__示例__

```xml
<configuration scan="true" scanPeriod="60 second" debug="false">  
      <contextName>myAppName</contextName>  
      <!-- 其他配置省略-->  
</configuration>
```

## 3.2 &lt;property&gt;

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

## 3.3 &lt;timestamp&gt;

`<timestamp>`元素用于获取时间戳字符串，有两个属性

* key:标识此<timestamp>的名字
* datePattern：设置将当前时间（解析配置文件的时间）转换为字符串的模式，遵循Java.txt.SimpleDateFormat的格式。

__示例__

```xml
<configuration scan="true" scanPeriod="60 second" debug="false">  
      <timestamp key="bySecond" datePattern="yyyyMMdd'T'HHmmss"/>   
      <contextName>${bySecond}</contextName>  
      <!-- 其他配置省略-->  
</configuration>
```

## 3.4 &lt;logger&gt;

用来设置某一个包或者具体的某一个类的日志打印级别、以及指定`<appender>`

`<logger>`仅有一个name属性，一个可选的level和一个可选的additivity属性。

* name：用来指定受此logger约束的某一个包或者具体的某一个类。
* level：用来设置打印级别，大小写无关：__TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF__，还有一个特殊值__INHERITED__或者同义词__NULL__，代表强制执行上级的级别。
    * 如果未设置此属性，那么当前logger将会继承上级的级别。
* additivity：是否向上级logger传递打印信息。默认是true。

`<logger>`可以包含零个或多个`<appender-ref>`元素，标识这个appender将会添加到这个logger

## 3.5 &lt;root&gt;

`<root>`也是`<logger>`元素，但是它是__根logger__。__只有一个level属性，应为已经被命名为"root"__

* level：用来设置打印级别，大小写无关：__TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF__，__不能__设置为__INHERITED__或者同义词__NULL__。默认是DEBUG

`<root>`可以包含零个或多个`<appender-ref>`元素，标识这个appender将会添加到这个logger

## 3.6 &lt;appender&gt;

`<appender>`是`<configuration>`的子元素，是负责写日志的组件。<appender>有两个必要属性name和class。name指定appender名称，class指定appender的全限定名。

### 3.6.1 ConsoleAppender

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

### 3.6.2 FileAppender

把日志添加到文件，有以下子元素：

* `<file>`：被写入的文件名，可以是相对目录，也可以是绝对目录，如果上级目录不存在会自动创建，没有默认值
* `<append>`：如果是true，日志被追加到文件结尾，如果是false，清空现存文件，默认是true
* `<encoder>`：对记录事件进行格式化。
* `<prudent>`：如果是true，日志会被安全的写入文件，即使其他的FileAppender也在向此文件做写入操作，效率低，默认是false

__示例__

```xml
<configuration>  
  <appender name="FILE" class="ch.qos.logback.core.FileAppender">  
    <file>testFile.log</file>  
    <append>true</append>  
    <encoder>  
      <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>  
    </encoder>  
  </appender>  
 
  <root level="DEBUG">  
    <appender-ref ref="FILE" />  
  </root>  
</configuration>
```

### 3.6.3 RollingFIleAppender

滚动记录文件，先将日志记录到指定文件，当符合某个条件时，将日志记录到其他文件。有以下子元素：

* `<file>`：被写入的文件名，可以是相对目录，也可以是绝对目录，如果上级目录不存在会自动创建，没有默认值
* `<append>`：如果是true，日志被追加到文件结尾，如果是false，清空现存文件，默认是true
* `<encoder>`：对记录事件进行格式化。（具体参数稍后讲解）
* `<rollingPolicy>`:当发生滚动时，决定 RollingFileAppender 的行为，涉及文件移动和重命名
* `<triggeringPolicy>`: 告知 RollingFileAppender 何时激活滚动
* `<prudent>`：当为true时，不支持FixedWindowRollingPolicy。支持TimeBasedRollingPolicy，但是有两个限制，1不支持也不允许文件压缩，2不能设置file属性，必须留空

#### 3.6.3.1 &lt;rollingPolicy&gt;

__ch.qos.logback.core.rolling.TimeBasedRollingPolicy__：最常用的滚动策略，它根据时间来制定滚动策略，既负责滚动也负责触发滚动。有以下子节点：

* `<fileNamePattern>`: 必要节点，包含文件名及`%d`转换符
    * `%d`可以包含一个Java.text.SimpleDateFormat指定的时间格式，如：`%d{yyyy-MM}`
    * 如果直接使用%d，默认格式是`yyyy-MM-dd`
    * RollingFileAppender的file子元素可有可无，通过设置file，可以为活动文件和归档文件指定不同位置，当前日志总是记录到file指定的文件（活动文件），活动文件的名字不会改变；如果没设置file，活动文件的名字会根据fileNamePattern的值，每隔一段时间改变一次。"/"或者"\"会被当做目录分隔符。
* `<maxHistory>`: 可选元素，控制保留的归档文件的最大数量，超出数量就删除旧文件。假设设置每个月滚动，且`<maxHistory>`是6，则只保存最近6个月的文件，删除之前的旧文件。注意，删除旧文件是，那些为了归档而创建的目录也会被删除

__ch.qos.logback.core.rolling.FixedWindowRollingPolicy__：根据固定窗口算法重命名文件的滚动策略。有以下子元素：

* `<minIndex>`：窗口索引最小值
* `<maxIndex>`：窗口索引最大值，当用户指定的窗口过大时，会自动将窗口设置为12
* `<fileNamePattern>`：必须包含`%i`
    * 例如，假设最小值和最大值分别为1和2，命名模式为`mylog%i.log`，会产生归档文件`mylog1.log`和`mylog2.log`
    * 还可以指定文件压缩选项，例如，`mylog%i.log.gz`或者`log%i.log.zip`

__示例1：__每天生产一个日志文件，保存30天的日志文件

```xml
<configuration>   
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">   
 
    <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">   
      <fileNamePattern>logFile.%d{yyyy-MM-dd}.log</fileNamePattern>   
      <maxHistory>30</maxHistory>    
    </rollingPolicy>   
 
    <encoder>   
      <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>   
    </encoder>   
  </appender>    
 
  <root level="DEBUG">   
    <appender-ref ref="FILE" />   
  </root>   
</configuration>
```

__示例2：__按照固定窗口模式生成日志文件，当文件大于20MB时，生成新的日志文件。窗口大小是1到3，当保存了3个归档文件后，将覆盖最早的日志

```xml
<configuration>   
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">   
    <file>test.log</file>   
 
    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">   
      <fileNamePattern>tests.%i.log.zip</fileNamePattern>   
      <minIndex>1</minIndex>   
      <maxIndex>3</maxIndex>   
    </rollingPolicy>   
 
    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">   
      <maxFileSize>5MB</maxFileSize>   
    </triggeringPolicy>   
    <encoder>   
      <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>   
    </encoder>   
  </appender>   
 
  <root level="DEBUG">   
    <appender-ref ref="FILE" />   
  </root>   
</configuration>
```

#### 3.6.3.2 &lt;triggeringPolicy&gt;

__ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy__：查看当前活动文件的大小，如果超过指定大小会告知RollingFileAppender触发当前活动文件滚动。只有一个子元素：

* `<maxFileSize>`:这是活动文件的大小，默认值是10MB

__示例__

```xml
<configuration>   
  <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">   
    <file>test.log</file>   
 
    <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">   
      <fileNamePattern>tests.%i.log.zip</fileNamePattern>   
      <minIndex>1</minIndex>   
      <maxIndex>3</maxIndex>   
    </rollingPolicy>   
 
    <triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">   
      <maxFileSize>5MB</maxFileSize>   
    </triggeringPolicy>   
    <encoder>   
      <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>   
    </encoder>   
  </appender>   
 
  <root level="DEBUG">   
    <appender-ref ref="FILE" />   
  </root>   
</configuration>
```

### 3.6.4 &lt;encoder&gt;

`<encoder>`元素负责两件事，一是把日志信息转换成字节数组，二是把字节数组写入到输出流

目前PatternLayoutEncoder是唯一有用的且默认的encoder ，有一个`<pattern>`节点，用来设置日志的输入格式。使用"%"加"转换符"方式，如果要输出"%"，则必须用"\"对"\%"进行转义

__示例__

```xml
<encoder>   
   <pattern>%-4relative [%thread] %-5level %logger{35} - %msg%n</pattern>   
</encoder>
```

__格式修饰符，与转换符共同使用__：可选的格式修饰符位于"%"和转换符之间

* 第一个可选修饰符是左对齐标志，符号是减号"-"
* 接着是可选的最小宽度修饰符，用十进制数表示。如果字符小于最小宽度，则左填充或右填充，默认是左填充（即右对齐），填充符为空格。如果字符大于最小宽度，字符永远不会被截断
* 最大宽度修饰符，符号是点号"."后面加十进制数。如果字符大于最大宽度，则从前面截断。点符号"."后面加减号"-"在加数字，表示从尾部截断

# 4 示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
-scan:当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true
-scanPeriod:设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒。
-           当scan为true时，此属性生效。默认的时间间隔为1分钟
-debug:当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false。
-
- configuration 子节点为 appender、logger、root
-->
<configuration scan="true" scanPeriod="60 second" debug="false">
 
    <!-- 负责写日志,控制台日志 -->
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
 
        <!-- 一是把日志信息转换成字节数组,二是把字节数组写入到输出流 -->
        <encoder>
            <Pattern>[%d{yyyy-MM-dd HH:mm:ss.SSS}] [%5level] [%thread] %logger{0} %msg%n</Pattern>
            <charset>UTF-8</charset>
        </encoder>
    </appender>
 
    <!-- 文件日志 -->
    <appender name="DEBUG" class="ch.qos.logback.core.FileAppender">
        <file>debug.log</file>
        <!-- append: true,日志被追加到文件结尾; false,清空现存文件;默认是true -->
        <append>true</append>
        <filter class="ch.qos.logback.classic.filter.LevelFilter">
            <!-- LevelFilter: 级别过滤器，根据日志级别进行过滤 -->
            <level>DEBUG</level>
            <onMatch>ACCEPT</onMatch>
            <onMismatch>DENY</onMismatch>
        </filter>
        <encoder>
            <Pattern>[%d{yyyy-MM-dd HH:mm:ss.SSS}] [%5level] [%thread] %logger{0} %msg%n</Pattern>
            <charset>UTF-8</charset>
        </encoder>
    </appender>
 
    <!-- 滚动记录文件，先将日志记录到指定文件，当符合某个条件时，将日志记录到其他文件 -->
    <appender name="INFO" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <File>info.log</File>
 
        <!-- ThresholdFilter:临界值过滤器，过滤掉 TRACE 和 DEBUG 级别的日志 -->
        <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
            <level>INFO</level>
        </filter>
 
        <encoder>
            <Pattern>[%d{yyyy-MM-dd HH:mm:ss.SSS}] [%5level] [%thread] %logger{0} %msg%n</Pattern>
            <charset>UTF-8</charset>
        </encoder>
 
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <!-- 每天生成一个日志文件，保存30天的日志文件
            - 如果隔一段时间没有输出日志，前面过期的日志不会被删除，只有再重新打印日志的时候，会触发删除过期日志的操作。
            -->
            <fileNamePattern>info.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
            <TimeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </TimeBasedFileNamingAndTriggeringPolicy>
        </rollingPolicy>
    </appender >
 
    <!--<!– 异常日志输出 –>-->
    <!--<appender name="EXCEPTION" class="ch.qos.logback.core.rolling.RollingFileAppender">-->
        <!--<file>exception.log</file>-->
        <!--<!– 求值过滤器，评估、鉴别日志是否符合指定条件. 需要额外的两个JAR包，commons-compiler.jar和janino.jar –>-->
        <!--<filter class="ch.qos.logback.core.filter.EvaluatorFilter">-->
            <!--<!– 默认为 ch.qos.logback.classic.boolex.JaninoEventEvaluator –>-->
            <!--<evaluator>-->
                <!--<!– 过滤掉所有日志消息中不包含"Exception"字符串的日志 –>-->
                <!--<expression>return message.contains("Exception");</expression>-->
            <!--</evaluator>-->
            <!--<OnMatch>ACCEPT</OnMatch>-->
            <!--<OnMismatch>DENY</OnMismatch>-->
        <!--</filter>-->
 
        <!--<triggeringPolicy class="ch.qos.logback.core.rolling.SizeBasedTriggeringPolicy">-->
            <!--<!– 触发节点，按固定文件大小生成，超过5M，生成新的日志文件 –>-->
            <!--<maxFileSize>5MB</maxFileSize>-->
        <!--</triggeringPolicy>-->
    <!--</appender>-->
 
    <appender name="ERROR" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>error.log</file>
 
        <encoder>
            <Pattern>[%d{yyyy-MM-dd HH:mm:ss.SSS}] [%5level] [%thread] %logger{0} %msg%n</Pattern>
            <charset>UTF-8</charset>
        </encoder>
 
        <!-- 按照固定窗口模式生成日志文件，当文件大于20MB时，生成新的日志文件。
        -    窗口大小是1到3，当保存了3个归档文件后，将覆盖最早的日志。
        -    可以指定文件压缩选项
        -->
        <rollingPolicy class="ch.qos.logback.core.rolling.FixedWindowRollingPolicy">
            <fileNamePattern>error.%d{yyyy-MM}(%i).log.zip</fileNamePattern>
            <minIndex>1</minIndex>
            <maxIndex>3</maxIndex>
            <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                <maxFileSize>100MB</maxFileSize>
            </timeBasedFileNamingAndTriggeringPolicy>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
    </appender>
 
    <!-- 异步输出 -->
    <appender name ="ASYNC" class= "ch.qos.logback.classic.AsyncAppender">
        <!-- 不丢失日志.默认的,如果队列的80%已满,则会丢弃TRACT、DEBUG、INFO级别的日志 -->
        <discardingThreshold >0</discardingThreshold>
        <!-- 更改默认的队列的深度,该值会影响性能.默认值为256 -->
        <queueSize>512</queueSize>
        <!-- 添加附加的appender,最多只能添加一个 -->
        <appender-ref ref ="ERROR"/>
    </appender>
 
    <!--
    - 1.name：包名或类名，用来指定受此logger约束的某一个包或者具体的某一个类
    - 2.未设置打印级别，所以继承他的上级<root>的日志级别“DEBUG”
    - 3.未设置additivity，默认为true，将此logger的打印信息向上级传递；
    - 4.未设置appender，此logger本身不打印任何信息，级别为“DEBUG”及大于“DEBUG”的日志信息传递给root，
    -  root接到下级传递的信息，交给已经配置好的名为“STDOUT”的appender处理，“STDOUT”appender将信息打印到控制台；
    -->
    <logger name="ch.qos.logback" />
 
    <!--
    - 1.将级别为“INFO”及大于“INFO”的日志信息交给此logger指定的名为“STDOUT”的appender处理，在控制台中打出日志，
    -   不再向次logger的上级 <logger name="logback"/> 传递打印信息
    - 2.level：设置打印级别（TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF），还有一个特殊值INHERITED或者同义词NULL，代表强制执行上级的级别。
    -        如果未设置此属性，那么当前logger将会继承上级的级别。
    - 3.additivity：为false，表示此logger的打印信息不再向上级传递,如果设置为true，会打印两次
    - 4.appender-ref：指定了名字为"STDOUT"的appender。
    -->
    <logger name="com.weizhi.common.LogMain" level="INFO" additivity="false">
        <appender-ref ref="STDOUT"/>
        <!--<appender-ref ref="DEBUG"/>-->
        <!--<appender-ref ref="EXCEPTION"/>-->
        <!--<appender-ref ref="INFO"/>-->
        <!--<appender-ref ref="ERROR"/>-->
        <appender-ref ref="ASYNC"/>
    </logger>
 
    <!--
    - 根logger
    - level:设置打印级别，大小写无关：TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF，不能设置为INHERITED或者同义词NULL。
    -       默认是DEBUG。
    -appender-ref:可以包含零个或多个<appender-ref>元素，标识这个appender将会添加到这个logger
    -->
    <root level="DEBUG">
        <appender-ref ref="STDOUT"/>
        <!--<appender-ref ref="DEBUG"/>-->
        <!--<appender-ref ref="EXCEPTION"/>-->
        <!--<appender-ref ref="INFO"/>-->
        <appender-ref ref="ASYNC"/>
    </root>
</configuration>
```

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [从零开始玩转logback](http://www.importnew.com/22290.html)
* [logback的使用和logback.xml详解](https://www.cnblogs.com/warking/p/5710303.html)
* [logback 配置详解](https://www.jianshu.com/p/1ded57f6c4e3)

