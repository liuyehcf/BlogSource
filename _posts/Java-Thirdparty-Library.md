---
title: Java-Thirdparty-Library
date: 2023-03-10 20:13:29
tags: 
- 原创
categories: 
- Java
---

**阅读更多**

<!--more-->

# 1 Frequently-Used-Utils

**`commons`：**

1. `commons-lang:commons-lang`
1. `commons-collections:commons-collections`
1. `commons-configuration:commons-configuration`
1. `commons-io:commons-io`
1. `commons-codec:commons-codec`
1. `commons-net:commons-net`
1. `commons-cli:commons-cli`
1. `commons-logging:commons-logging`

**`apache`：**

1. `org.apache.commons:commons-lang3`
1. `org.apache.commons:commons-collections4`
1. `org.apache.commons:commons-configuration2`
1. `org.apache.httpcomponents:httpclient`
1. `org.apache.commons:commons-pool2`
1. `org.apache.commons:commons-csv`

**`google`：**

1. `com.google.guava:guava`
1. `com.google.code.gson:gson`

**`Plugin`：**

1. `org.apache.maven.plugins:maven-compiler-plugin`
1. `org.springframework.boot:spring-boot-maven-plugin`
    * 配置参数（`<configuration>`）：
        * `includeSystemScope`
        * `mainClass`
    * 默认情况下，会讲资源文件打包，并放置在`BOOT-INF/classes`。需要使用`Thread.currentThread().getContextClassLoader()`而不能使用`ClassLoader.getSystemClassLoader()`。因为`Thread.currentThread().getContextClassLoader()`这个类加载器是`Spring Boot`应用程序运行时默认使用的类加载器，它知道资源文件放在了`BOOT-INF/classes`，而`ClassLoader.getSystemClassLoader()`并不知道这一信息

# 2 SLF4J

`SLF4J`，即简单日志门面（`Simple Logging Facade for Java, SLF4J`），不是具体的日志解决方案，它只服务于各种各样的日志系统。按照官方的说法，`SLF4J`是一个用于日志系统的简单`Facade`，允许最终用户在部署其应用时使用其所希望的日志系统

实际上，`SLF4J`所提供的核心`API`是一些接口以及一个`LoggerFactory`的工厂类。从某种程度上，`SLF4J`有点类似`JDBC`，不过比`JDBC`更简单，在`JDBC`中，你需要指定驱动程序，而在使用`SLF4J`的时候，不需要在代码中或配置文件中指定你打算使用那个具体的日志系统。如同使用`JDBC`基本不用考虑具体数据库一样，`SLF4J`提供了统一的记录日志的接口，只要按照其提供的方法记录即可，最终日志的格式、记录级别、输出方式等通过具体日志系统的配置来实现，因此可以在应用中灵活切换日志系统

**简单地说，`SLF4J`只提供日志框架的接口，而不提供具体的实现。因此`SLF4J`必须配合具体的日志框架才能正常工作**

## 2.1 log4j2

[Apache Log4j Doc](https://logging.apache.org/log4j/2.x/index.html)

### 2.1.1 Maven

```xml
<dependencies>
    <!-- SLF4J API -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>${slf4j.version}</version>
    </dependency>
    <!-- Log4j2 API -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-api</artifactId>
        <version>${log4j2.version}</version>
    </dependency>
    <!-- Log4j2 Core -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-core</artifactId>
        <version>${log4j2.version}</version>
    </dependency>
    <!-- Log4j2 SLF4J Binding -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-slf4j-impl</artifactId>
        <version>${log4j2.version}</version>
    </dependency>
    <!-- Compatible with Log4j1, only if some dependencies rely on log4j1's api -->
    <dependency>
        <groupId>org.apache.logging.log4j</groupId>
        <artifactId>log4j-1.2-api</artifactId>
        <version>${log4j2.version}</version>
    </dependency>
</dependencies>
```

### 2.1.2 Demo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="ConsoleAppender" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} %style{[%thread]}{bright} %highlight{[%-5level] %logger{36}}{STYLE=Logback} - %msg%n"/>
        </Console>
        <RollingRandomAccessFile name="RollingRandomAccessFileAppender" fileName="logs/app.log" filePattern="logs/app-%d{yyyy-MM-dd}-%i.log">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss.SSS} %style{[%thread]}{bright} %highlight{[%-5level] %logger{36}}{STYLE=Logback} - %msg%n"/>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="10MB"/>
            </Policies>
            <DefaultRolloverStrategy max="7">
                <Delete basePath="logs" maxDepth="1">
                    <IfFileName glob="app-*.log"/>
                    <IfLastModified age="7d"/>
                </Delete>
            </DefaultRolloverStrategy>
        </RollingRandomAccessFile>
        <Async name="AsyncAppender">
            <AppenderRef ref="ConsoleAppender"/>
            <AppenderRef ref="RollingRandomAccessFileAppender"/>
        </Async>
    </Appenders>
    <Loggers>
        <Root level="info">
            <AppenderRef ref="AsyncAppender"/>
        </Root>
    </Loggers>
</Configuration>
```

* Delete Action only works when file rolling triggered.

### 2.1.3 Tips

#### 2.1.3.1 Command-Line Options

* Specify configuration path: `-Dlog4j.configurationFile=path/to/log4j2.xml`
* Enable debug mode (refers to debug mode of `log4j2` itself)：`-Dlog4j.debug=true`

#### 2.1.3.2 Logger Name Pattern

Syntanx: `%logger{precision}` or `%c{precision}`

| Pattern | LoggerName | Result |
|:--|:--|:--|
| `%c{1}` | `org.apache.commons.Foo` | `Foo` |
| `%c{2}` | `org.apache.commons.Foo` | `commons.Foo` |
| `%c{1.}` | `org.apache.commons.Foo` | `o.a.c.Foo` |

#### 2.1.3.3 Color Configuration

[Pattern Layout](https://logging.apache.org/log4j/2.x/manual/layouts.html#pattern-layout)

* {% raw %}%highlight{pattern}{style}{% endraw %}
    * {% raw %}%highlight{[%thread] [%-5level] [%logger{36}]}{FATAL=red blink, ERROR=red, WARN=yellow, INFO=green, DEBUG=cyan, TRACE=blue}{% endraw %}
    * {% raw %}%highlight{[%-5level] %logger{36}}{STYLE=Logback}{% endraw %}
* {% raw %}%style{pattern}{ANSI style}{% endraw %}
    * {% raw %}%style{%logger}{red}{% endraw %}
    * {% raw %}%style{[%thread]}{bright}{% endraw %}

#### 2.1.3.4 Lookups

Lookups provide a way to add values to the Log4j configuration at arbitrary places. They are a particular type of Plugin that implements the StrLookup interface. Information on how to use Lookups in configuration files can be found in the Property Substitution section of the Configuration page.

* System Properties Lookup: `${sys:xxx}`
    * `${sys:xxx:-yyy}`: With default
* Environment Lookup: `${env:xxx}`
    * `${env:xxx:-yyy}`: With default

### 2.1.4 Issues

#### 2.1.4.1 No appenders are available for AsyncAppender

Generally, AsyncAppender relies on one or more Appenders, but if the initializations of these dependencies failed, this exception may occur. Possible reasons are:

* `RollingRandomAccessFile` has no permission to perform write operation, like create directory and file.

#### 2.1.4.2 Binding to log4j-1 Unexpectedly

```
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
log4j:WARN No appenders could be found for logger (org.apache.hadoop.util.Shell).
```

Maybe you don't exclude all log4j-1's dependency in your project, like:

* `org.slf4j:slf4j-reload4j`
* `ch.qos.reload4j:reload4j`

## 2.2 Logback

### 2.2.1 Maven

```xml
<dependencies>
    <!-- SLF4J API -->
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>${slf4j.version}</version>
    </dependency>
    <!-- Logback Classic -->
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>${logback.version}</version>
    </dependency>
    <!-- Logback Core -->
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-core</artifactId>
        <version>${logback.version}</version>
    </dependency>
</dependencies>
```

### 2.2.2 Demo

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
-scan:当此属性设置为true时，配置文件如果发生改变，将会被重新加载，默认值为true
-scanPeriod:设置监测配置文件是否有修改的时间间隔，如果没有给出时间单位，默认单位是毫秒
-           当scan为true时，此属性生效。默认的时间间隔为1分钟
-debug:当此属性设置为true时，将打印出logback内部日志信息，实时查看logback运行状态。默认值为false
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
            - 如果隔一段时间没有输出日志，前面过期的日志不会被删除，只有再重新打印日志的时候，会触发删除过期日志的操作
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
 
        <!-- 按照固定窗口模式生成日志文件，当文件大于20MB时，生成新的日志文件
        -    窗口大小是1到3，当保存了3个归档文件后，将覆盖最早的日志
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
    - 3.未设置additivity，默认为true，将此logger的打印信息向上级传递
    - 4.未设置appender，此logger本身不打印任何信息，级别为“DEBUG”及大于“DEBUG”的日志信息传递给root
    -  root接到下级传递的信息，交给已经配置好的名为“STDOUT”的appender处理，“STDOUT”appender将信息打印到控制台
    -->
    <logger name="ch.qos.logback" />
 
    <!--
    - 1.将级别为“INFO”及大于“INFO”的日志信息交给此logger指定的名为“STDOUT”的appender处理，在控制台中打出日志
    -   不再向次logger的上级 <logger name="logback"/> 传递打印信息
    - 2.level：设置打印级别（TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF），还有一个特殊值INHERITED或者同义词NULL，代表强制执行上级的级别
    -        如果未设置此属性，那么当前logger将会继承上级的级别
    - 3.additivity：为false，表示此logger的打印信息不再向上级传递,如果设置为true，会打印两次
    - 4.appender-ref：指定了名字为"STDOUT"的appender
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
    - level:设置打印级别，大小写无关：TRACE, DEBUG, INFO, WARN, ERROR, ALL 和 OFF，不能设置为INHERITED或者同义词NULL
    -       默认是DEBUG
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

### 2.2.3 Tips

#### 2.2.3.1 [颜色](http://logback.qos.ch/manual/layouts.html#coloring)

```xml
<configuration debug="true">
  <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
    <withJansi>true</withJansi>
    <encoder>
      <pattern>[%thread] %highlight(%-5level) %cyan(%logger{15}) - %msg %n</pattern>
    </encoder>
  </appender>
  <root level="DEBUG">
    <appender-ref ref="STDOUT" />
  </root>
</configuration>
```

#### 2.2.3.2 Work with Unit Test

在`test/resources`目录下添加`logback-test.xml`文件即可生效

#### 2.2.3.3 Spring集成

```xml
<configuration>
    <!-- 引入外部属性文件 -->
    <include resource="org/springframework/boot/logging/logback/defaults.xml"/>

    <!-- 依据profile选择性配置 -->
    <springProfile name="local, ci">
        <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
           ...
        </appender>
        <root level="INFO">
            <appender-ref ref="STDOUT"/>
        </root>
    </springProfile>

    <springProfile name="!local, !ci">
        <appender name="ROLLINGFILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
            ...
        </appender>
        <root level="INFO">
            <appender-ref ref="ROLLINGFILE"/>
        </root>
    </springProfile>
</configuration>
```

#### 2.2.3.4 Spring-Boot默认的配置

**参考`org.springframework.boot.logging.logback.DefaultLogbackConfiguration`**

**相关配置项参考`spring-configuration-metadata.json`**

* `logging.pattern.console`：默认的`console pattern`配置
* `logging.config`：用于指定`spring`加载的`logback`配置文件

#### 2.2.3.5 关于AsyncAppender阻塞的问题

`AsyncAppender`会异步打印日志，从而避免磁盘`IO`阻塞当前线程的业务逻辑，其异步的实现方式也是常规的`ThreadPool`+`BlockingQueue`，那么当线程池与队列都被打满时，其行为是如何的？

直接上源码，起点是`ch.qos.logback.classic.Logger`，所有的日志方法都会收敛到`filterAndLog_0_Or3Plus`、`filterAndLog_1`、`filterAndLog_2`这三个方法上

```java
    private void filterAndLog_1(final String localFQCN, final Marker marker, final Level level, final String msg, final Object param, final Throwable t) {

        final FilterReply decision = loggerContext.getTurboFilterChainDecision_1(marker, this, level, msg, param, t);

        if (decision == FilterReply.NEUTRAL) {
            if (effectiveLevelInt > level.levelInt) {
                return;
            }
        } else if (decision == FilterReply.DENY) {
            return;
        }

        buildLoggingEventAndAppend(localFQCN, marker, level, msg, new Object[] { param }, t);
    }

    private void filterAndLog_2(final String localFQCN, final Marker marker, final Level level, final String msg, final Object param1, final Object param2,
                    final Throwable t) {

        final FilterReply decision = loggerContext.getTurboFilterChainDecision_2(marker, this, level, msg, param1, param2, t);

        if (decision == FilterReply.NEUTRAL) {
            if (effectiveLevelInt > level.levelInt) {
                return;
            }
        } else if (decision == FilterReply.DENY) {
            return;
        }

        buildLoggingEventAndAppend(localFQCN, marker, level, msg, new Object[] { param1, param2 }, t);
    }

    private void buildLoggingEventAndAppend(final String localFQCN, final Marker marker, final Level level, final String msg, final Object[] params,
                    final Throwable t) {
        LoggingEvent le = new LoggingEvent(localFQCN, this, level, msg, t, params);
        le.setMarker(marker);
        callAppenders(le);
    }

    public void callAppenders(ILoggingEvent event) {
        int writes = 0;
        for (Logger l = this; l != null; l = l.parent) {
            writes += l.appendLoopOnAppenders(event);
            if (!l.additive) {
                break;
            }
        }
        // No appenders in hierarchy
        if (writes == 0) {
            loggerContext.noAppenderDefinedWarning(this);
        }
    }

    private int appendLoopOnAppenders(ILoggingEvent event) {
        if (aai != null) {
            return aai.appendLoopOnAppenders(event);
        } else {
            return 0;
        }
    }
```

继续跟踪`AppenderAttachableImpl`的`appendLoopOnAppenders`方法

```java
    public int appendLoopOnAppenders(E e) {
        int size = 0;
        final Appender<E>[] appenderArray = appenderList.asTypedArray();
        final int len = appenderArray.length;
        for (int i = 0; i < len; i++) {
            appenderArray[i].doAppend(e);
            size++;
        }
        return size;
    }
```

如果`Appender`是`AsyncAppender`，那么继续跟踪`UnsynchronizedAppenderBase`的`doAppend`方法

```java
    public void doAppend(E eventObject) {
        // WARNING: The guard check MUST be the first statement in the
        // doAppend() method.

        // prevent re-entry.
        if (Boolean.TRUE.equals(guard.get())) {
            return;
        }

        try {
            guard.set(Boolean.TRUE);

            if (!this.started) {
                if (statusRepeatCount++ < ALLOWED_REPEATS) {
                    addStatus(new WarnStatus("Attempted to append to non started appender [" + name + "].", this));
                }
                return;
            }

            if (getFilterChainDecision(eventObject) == FilterReply.DENY) {
                return;
            }

            // ok, we now invoke derived class' implementation of append
            this.append(eventObject);

        } catch (Exception e) {
            if (exceptionCount++ < ALLOWED_REPEATS) {
                addError("Appender [" + name + "] failed to append.", e);
            }
        } finally {
            guard.set(Boolean.FALSE);
        }
    }
```

继续跟踪`AsyncAppenderBase`的`append`方法，重点来了，注意第一个if语句

* 条件1：如果当前队列的容量的剩余值小于`discardingThreshold`，该值默认为队列容量的`1/5`
* 条件2：如果当前日志事件可以丢弃，对于`AsyncAppender`来说，`INFO`以下的日志是可以丢弃的

```java
    protected void append(E eventObject) {
        if (isQueueBelowDiscardingThreshold() && isDiscardable(eventObject)) {
            return;
        }
        preprocess(eventObject);
        put(eventObject);
    }

    private boolean isQueueBelowDiscardingThreshold() {
        return (blockingQueue.remainingCapacity() < discardingThreshold);
    }

    public void start() {
        // 省略无关代码...

        if (discardingThreshold == UNDEFINED)
            discardingThreshold = queueSize / 5;
        
        // 省略无关代码...
    }
```

`AsyncAppender`的`isDiscardable`方法

```java
    protected boolean isDiscardable(ILoggingEvent event) {
        Level level = event.getLevel();
        return level.toInt() <= Level.INFO_INT;
    }
```

**总结：根据上面的分析可以发现，如果打日志的并发度非常高，且打的是`WARN`或`ERROR`日志，仍然会阻塞当前线程**

### 2.2.4 参考

* [官方文档（很详细）](http://logback.qos.ch/manual/)
* [从零开始玩转logback](http://www.importnew.com/22290.html)
* [logback的使用和logback.xml详解](https://www.cnblogs.com/warking/p/5710303.html)
* [logback 配置详解](https://www.jianshu.com/p/1ded57f6c4e3)
* [在logback中使用spring的属性值](https://stackoverflow.com/questions/36743386/accessing-the-application-properties-in-logback-xml)
* [SLF4J与Logback、Log4j1、Log4j2、JCL、J.U.L是如何关联使用的](https://blog.csdn.net/yangzl2008/article/details/81503579)
* [layout官方文档](http://logback.qos.ch/manual/layouts.html)

## 2.3 Tips

### 2.3.1 How to make sure there is only one logging implementation

Use `mvn dependency:tree` to check dependencies:

* `log4j`:
    * `log4j:log4j`
* `log4j2`:
    * `org.apache.logging.log4j:*`
* `logback`:
    * `ch.qos.logback:*`
* `reload4j`:
    * `org.slf4j:slf4j-reload4j`
    * `ch.qos.reload4j:reload4j`

# 3 Test

## 3.1 EasyMock

`mock`测试就是在测试过程中，对于某些不容易构造或者不容易获取的对象，**用一个虚拟的对象（不要被虚拟误导，就是Java对象，虚拟描述的是这个对象的行为）来创建以便测试的测试方法**

真实对象具有不可确定的行为，产生不可预测的效果，（如：股票行情，天气预报）真实对象很难被创建的真实对象的某些行为很难被触发真实对象实际上还不存在的（和其他开发小组或者和新的硬件打交道）等等

使用一个接口来描述这个对象。在产品代码中实现这个接口，在测试代码中实现这个接口，在被测试代码中只是通过接口来引用对象，所以它不知道这个引用的对象是真实对象，还是`mock`对象

### 3.1.1 示例

该示例的目的并不是教你如何去用`mock`进行测试，而是给出`mock`对象的创建过程以及它的行为

1. 首先创建`Mock`对象，即代理对象
1. 设定`EasyMock`的相应逻辑，即打桩
1. 调用`mock`对象的相应逻辑

```java
interface Human {
    boolean isMale(String name);
}

public class TestEasyMock {
    public static void main(String[] args) {
        Human mock = EasyMock.createMock(Human.class);

        EasyMock.expect(mock.isMale("Bob")).andReturn(true);
        EasyMock.expect(mock.isMale("Alice")).andReturn(true);

        EasyMock.replay(mock);

        System.out.println(mock.isMale("Bob"));
        System.out.println(mock.isMale("Alice"));
        System.out.println(mock.isMale("Robot"));
    }
}
```

以下是输出

```java
true
true
java.lang.AssertionError: 
  Unexpected method call Human.isMale("Robot"):
    at org.easymock.internal.MockInvocationHandler.invoke(MockInvocationHandler.java:44)
    at org.easymock.internal.ObjectMethodsFilter.invoke(ObjectMethodsFilter.java:85)
Disconnected from the target VM, address: '127.0.0.1:59825', transport: 'socket'
    at org.liuyehcf.easymock.$Proxy0.isMale(Unknown Source)
    at org.liuyehcf.easymock.TestEasyMock.main(TestEasyMock.java:28)
```

输出的结果很有意思，在`EasyMock.replay(mock)`语句之前用两个`EasyMock.expect`设定了`Bob`和`Alice`的预期结果，因此结果符合设定；而`Robot`并没有设定，因此抛出异常

接下来我们将分析以下上述例子中所涉及到的源码，解开`mock`神秘的面纱

### 3.1.2 源码详解

首先来看一下静态方法`EasyMock.createMock`，该方法返回一个`Mock`对象(给定接口的实例)

```java
    /**
     * Creates a mock object that implements the given interface, order checking
     * is disabled by default.
     * 
     * @param <T>
     *            the interface that the mock object should implement.
     * @param toMock
     *            the class of the interface that the mock object should
     *            implement.
     * @return the mock object.
     */
    public static <T> T createMock(final Class<T> toMock) {
        return createControl().createMock(toMock);
    }
```

其中`createMock`是`IMocksControl`接口的方法。该方法接受`Class`对象，并返回`Class`对象所代表类型的实例

```java
    /**
     * Creates a mock object that implements the given interface.
     * 
     * @param <T>
     *            the interface or class that the mock object should
     *            implement/extend.
     * @param toMock
     *            the interface or class that the mock object should
     *            implement/extend.
     * @return the mock object.
     */
    <T> T createMock(Class<T> toMock);
```

了解了`createMock`接口定义后，我们来看看具体的实现(`MocksControl#createMock`)

```java
    public <T> T createMock(final Class<T> toMock) {
        try {
            state.assertRecordState();
            //创建一个代理工厂
            final IProxyFactory<T> proxyFactory = createProxyFactory(toMock);
            //利用工厂产生代理类的对象
            return proxyFactory.createProxy(toMock, new ObjectMethodsFilter(toMock,
                    new MockInvocationHandler(this), null));
        } catch (final RuntimeExceptionWrapper e) {
            throw (RuntimeException) e.getRuntimeException().fillInStackTrace();
        }
    }
```

`IProxyFactory`接口有两个实现，`JavaProxyFactory`（`JDK`动态代理）和`ClassProxyFactory`（`Cglib`）。我们以`JavaProxyFactory`为例进行讲解，动态代理的实现不是本篇博客的重点。下面给出`JavaProxyFactory#createProxy`方法的源码

```java
    public T createProxy(final Class<T> toMock, final InvocationHandler handler) {
        //就是简单调用了JDK动态代理的接口，没有任何难度
        return (T) Proxy.newProxyInstance(toMock.getClassLoader(), new Class[] { toMock }, handler);
    }
```

我们再来回顾一下上述例子中的代码，我们发现一个很奇怪的现象。在`EasyMock.replay`方法前后，调用`mock.isMale`所产生的行为是不同的。**在这里`EasyMock.replay`类似于一个开关**，可以改变`mock`对象的行为。可是这是如何做到的呢？

```java
        //这里调用mock的isMale方法不会抛出异常
        EasyMock.expect(mock.isMale("Bob")).andReturn(true);
        EasyMock.expect(mock.isMale("Alice")).andReturn(true);

        //关键开关语句
        EasyMock.replay(mock);

        //这里只能调用上面预定义行为的方法，若没有设定预期值那么将抛出异常
        System.out.println(mock.isMale("Bob"));
        System.out.println(mock.isMale("Alice"));
        System.out.println(mock.isMale("Robot"));
```

生成代理对象的方法分析(`IMocksControl#createMock`)我们先暂时放在一边，我们现在先来跟踪一下`EasyMock.replay`方法的执行逻辑。源码如下

```java
    /**
     * Switches the given mock objects (more exactly: the controls of the mock
     * objects) to replay mode. For details, see the EasyMock documentation.
     * 
     * @param mocks
     *            the mock objects.
     */
    public static void replay(final Object... mocks) {
        for (final Object mock : mocks) {
            //依次对每个mock对象执行下面的逻辑
            getControl(mock).replay();
        }
    }
```

源码的官方注释中提到，该方法用于切换`mock`对象的控制模式。再来看下`EasyMock.getControl`方法

```java
    private static MocksControl getControl(final Object mock) {
        return ClassExtensionHelper.getControl(mock);
    }

    public static MocksControl getControl(final Object mock) {
        try {
            ObjectMethodsFilter handler;

            //mock是由JDK动态代理产生的类型的实例
            if (Proxy.isProxyClass(mock.getClass())) {
                handler = (ObjectMethodsFilter) Proxy.getInvocationHandler(mock);
            }
            //mock是由Cglib产生的类型的实例
            else if (Enhancer.isEnhanced(mock.getClass())) {
                handler = (ObjectMethodsFilter) getInterceptor(mock).getHandler();
            } else {
                throw new IllegalArgumentException("Not a mock: " + mock.getClass().getName());
            }
            //获取ObjectMethodsFilter封装的MockInvocationHandler的实例，并从MockInvocationHandler的实例中获取MocksControl的实例
            return handler.getDelegate().getControl();
        } catch (final ClassCastException e) {
            throw new IllegalArgumentException("Not a mock: " + mock.getClass().getName());
        }
    }
```

注意到`ObjectMethodsFilter`是`InvocationHandler`接口的实现，而`ObjectMethodsFilter`内部（`delegate`字段）又封装了一个`InvocationHandler`接口的实现，其类型是`MockInvocationHandler`。下面给出`MockInvocationHandler`的源码

```java
public final class MockInvocationHandler implements InvocationHandler, Serializable {

    private static final long serialVersionUID = -7799769066534714634L;

    //非常重要的字段，直接决定了下面invoke方法的行为
    private final MocksControl control;

    //注意到构造方法接受了MocksControl作为参数
    public MockInvocationHandler(final MocksControl control) {
        this.control = control;
    }

    public Object invoke(final Object proxy, final Method method, final Object[] args) throws Throwable {
        try {
            //如果是记录模式
            if (control.getState() instanceof RecordState) {
                LastControl.reportLastControl(control);
            }
            return control.getState().invoke(new Invocation(proxy, method, args));
        } catch (final RuntimeExceptionWrapper e) {
            throw e.getRuntimeException().fillInStackTrace();
        } catch (final AssertionErrorWrapper e) {
            throw e.getAssertionError().fillInStackTrace();
        } catch (final ThrowableWrapper t) {
            throw t.getThrowable().fillInStackTrace();
        }
        //then let all unwrapped exceptions pass unmodified
    }

    public MocksControl getControl() {
        return control;
    }
}
```

再回到`EasyMock.replay`方法中，`getControl(mock)`方法返回后调用`MocksControl#replay`方法，下面给出`MocksControl#replay`的源码

```java
    public void replay() {
        try {
            state.replay();
            //替换state，将之前收集到的行为(behavior)作为参数传给ReplayState的构造方法
            state = new ReplayState(behavior);
            LastControl.reportLastControl(null);
        } catch (final RuntimeExceptionWrapper e) {
            throw (RuntimeException) e.getRuntimeException().fillInStackTrace();
        }
    }
```

这就是为什么调用`EasyMock.replay`前后`mock`对象的行为会发生变化的原因。可以这样理解，如果`state`是`RecordState`时，调用`mock`的方法将会记录行为；如果`state`是`ReplayState`时，调用`mock`的方法将会从之前记录的行为中进行查找，如果找到了则调用，如果没有则抛出异常

`EasyMock`的源码就分析到这里，日后再细究`ReplayState`与`RecordState`的源码

# 4 Lombok

## 4.1 Overview

**lombok中常用的注解**

1. `@AllArgsConstructor`
1. `@NoArgsConstructor`
1. `@RequiredArgsConstructor`
1. `@Builder`
1. `@Getter`
1. `@Setter`
1. `@Data`
1. `@ToString`
1. `@EqualsAndHashCode`
1. `@Singular`
1. `@Slf4j`

**原理：`lombok`注解都是`编译期`注解，`编译期`注解最大的魅力就是能够干预编译器的行为，相关技术就是`JSR-269`**。我在另一篇博客中详细介绍了`JSR-269`的相关原理以及接口的使用方式，并且实现了类似`lombok`的`@Builder`注解。**对原理部分感兴趣的话，请移步{% post_link Java-JSR-269-插入式注解处理器 %}**

## 4.2 构造方法

`lombok`提供了3个注解，用于创建构造方法，它们分别是

1. **`@AllArgsConstructor`**：`@AllArgsConstructor`会生成一个全量的构造方法，包括所有的字段（非`final`字段以及未在定义处初始化的`final`字段）
1. **`@NoArgsConstructor`**：`@NoArgsConstructor`会生成一个无参构造方法（当然，不允许类中含有未在定义处初始化的`final`字段）
1. **`@RequiredArgsConstructor`**：`@RequiredArgsConstructor`会生成一个仅包含必要参数的构造方法，什么是必要参数呢？就是那些未在定义处初始化的`final`字段

## 4.3 @Builder

**`@Builder`是我最爱的lombok注解，没有之一**。通常我们在业务代码中，时时刻刻都会用到数据传输对象（`DTO`），例如，我们调用一个`RPC`接口，需要传入一个`DTO`，代码通常是这样的

```java
// 首先构造DTO对象
XxxDTO xxxDTO = new XxxDTO();
xxxDTO.setPro1(...);
xxxDTO.setPro2(...);
...
xxxDTO.setPron(...);

// 然后调用接口
rpcService.doSomething(xxxDTO);
```

其实，上述代码中的`xxxDTO`对象的创建以及赋值的过程，仅与`rpcService`有关，但是从肉眼来看，这确确实实又是两部分，我们无法快速确定`xxxDTO`对象只在`rpcService.doSomething`方法中用到。显然，这个代码片段最核心的部分就是`rpcService.doSomething`方法调用，**而上面这种写法使得核心代码淹没在非核心代码中**

借助`lombok`的`@Builder`注解，我们便可以这样重构上面这段代码

```java
rpcService.doSomething(
    XxxDTO.builder()
        .setPro1(...)
        .setPro2(...)
        ...
        .setPron(...)
        .build()
);
```

这样一来，由于`XxxDTO`的实例仅在`rpcService.doSomething`方法中用到，我们就把创建的步骤放到方法参数里面去完成，代码更内聚了。**通过这种方式，业务流程的脉络将会更清晰地展现出来，而不至于淹没在一大堆`set`方法的调用之中**

### 4.3.1 使用方式

如果是一个简单的`DTO`，**那么直接在类上方标记`@Builder`注解，同时需要提供一个全参构造方法**，`lombok`就会在编译期为该类创建一个`建造者模式`的静态内部类

```java
@Builder
public class BaseCarDTO {
    private Double width;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}
```

将编译后的`.class`文件反编译得到的`.java`文件如下。可以很清楚的看到，多了一个静态内部类，且采用了建造者模式，这也是`@Builder`注解名称的由来

```java
public class BaseCarDTO {
    private Double width;
    private Double length;
    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return this.width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return this.length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return this.weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public static BaseCarDTO.BaseCarDTOBuilder builder() {
        return new BaseCarDTO.BaseCarDTOBuilder();
    }

    public static class BaseCarDTOBuilder {
        private Double width;
        private Double length;
        private Double weight;

        BaseCarDTOBuilder() {
        }

        public BaseCarDTO.BaseCarDTOBuilder width(Double width) {
            this.width = width;
            return this;
        }

        public BaseCarDTO.BaseCarDTOBuilder length(Double length) {
            this.length = length;
            return this;
        }

        public BaseCarDTO.BaseCarDTOBuilder weight(Double weight) {
            this.weight = weight;
            return this;
        }

        public BaseCarDTO build() {
            return new BaseCarDTO(this.width, this.length, this.weight);
        }

        public String toString() {
            return "BaseCarDTO.BaseCarDTOBuilder(width=" + this.width + ", length=" + this.length + ", weight=" + this.weight + ")";
        }
    }
}
```

### 4.3.2 具有继承关系的DTO

我们来考虑一种更特殊的情况，假设有两个`DTO`，一个是`TruckDTO`，另一个是`BaseCarDTO`。`TruckDTO`继承了`BaseCarDTO`。其中`BaseCarDTO`与`TruckDTO`如下

* 我们需要在`@Builder`注解指定`builderMethodName`属性，区分一下两个静态方法

```java
@Builder
public class BaseCarDTO {
    private Double width;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}

@Builder(builderMethodName = "trunkBuilder")
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double volume) {
        this.volume = volume;
    }

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

我们来看一下`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件的样子，如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double volume) {
        this.volume = volume;
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public static TrunkDTO.TrunkDTOBuilder trunkBuilder() {
        return new TrunkDTO.TrunkDTOBuilder();
    }

    public static class TrunkDTOBuilder {
        private Double volume;

        TrunkDTOBuilder() {
        }

        public TrunkDTO.TrunkDTOBuilder volume(Double volume) {
            this.volume = volume;
            return this;
        }

        public TrunkDTO build() {
            return new TrunkDTO(this.volume);
        }

        public String toString() {
            return "TrunkDTO.TrunkDTOBuilder(volume=" + this.volume + ")";
        }
    }
}
```

可以看到，这个内部类`TrunkDTOBuilder`仅包含了子类`TrunkDTO`的字段，而不包含父类`BaseCarDTO`的字段

那么，我们如何让`TrunkDTOBuilder`也包含父类的字段呢？答案就是，我们需要将`@Builder`注解标记在构造方法处，构造方法包含多少字段，那么这个静态内部类就包含多少个字段，如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    @Builder(builderMethodName = "trunkBuilder")
    public TrunkDTO(Double width, Double length, Double weight, Double volume) {
        super(width, length, weight);
        this.volume = volume;
    }

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

上述`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double width, Double length, Double weight, Double volume) {
        super(width, length, weight);
        this.volume = volume;
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public static TrunkDTO.TrunkDTOBuilder trunkBuilder() {
        return new TrunkDTO.TrunkDTOBuilder();
    }

    public static class TrunkDTOBuilder {
        private Double width;
        private Double length;
        private Double weight;
        private Double volume;

        TrunkDTOBuilder() {
        }

        public TrunkDTO.TrunkDTOBuilder width(Double width) {
            this.width = width;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder length(Double length) {
            this.length = length;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder weight(Double weight) {
            this.weight = weight;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder volume(Double volume) {
            this.volume = volume;
            return this;
        }

        public TrunkDTO build() {
            return new TrunkDTO(this.width, this.length, this.weight, this.volume);
        }

        public String toString() {
            return "TrunkDTO.TrunkDTOBuilder(width=" + this.width + ", length=" + this.length + ", weight=" + this.weight + ", volume=" + this.volume + ")";
        }
    }
}
```

### 4.3.3 初始值

仅靠`@Builder`注解，那么生成的静态内部类是不会处理初始值的，如果我们要让静态内部类处理初始值，那么就需要在相关的字段上标记`@Builder.Default`注解

```java
@Builder
public class BaseCarDTO {
    @Builder.Default
    private Double width = 5.0;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}
```

**注意，字段在被`@Builder.Default`修饰后，生成class文件中是没有初始值的，这是个大坑！**

### 4.3.4 @EqualsAndHashCode

`@EqualsAndHashCode`注解用于创建`Object`的`hashCode`方法以及`equals`方法，同样地，如果一个`DTO`包含父类，那么最平凡的`@EqualsAndHashCode`注解不会考虑父类包含的字段。**因此如果子类的`hashCode`方法以及`equals`方法需要考虑父类的字段，那么需要将`@EqualsAndHashCode`注解的`callSuper`属性设置为`true`，这样就会调用父类的同名方法**

```java
public class BaseCarDTO {

    private Double width = 5.0;

    private Double length;

    private Double weight;

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}

@EqualsAndHashCode(callSuper = true)
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

上述`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO() {
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        } else if (!(o instanceof TrunkDTO)) {
            return false;
        } else {
            TrunkDTO other = (TrunkDTO)o;
            if (!other.canEqual(this)) {
                return false;
            } else if (!super.equals(o)) {
                return false;
            } else {
                Object this$volume = this.getVolume();
                Object other$volume = other.getVolume();
                if (this$volume == null) {
                    if (other$volume != null) {
                        return false;
                    }
                } else if (!this$volume.equals(other$volume)) {
                    return false;
                }

                return true;
            }
        }
    }

    protected boolean canEqual(Object other) {
        return other instanceof TrunkDTO;
    }

    public int hashCode() {
        int PRIME = true;
        int result = 1;
        int result = result * 59 + super.hashCode();
        Object $volume = this.getVolume();
        result = result * 59 + ($volume == null ? 43 : $volume.hashCode());
        return result;
    }
}
```

## 4.4 @Getter/@Setter

`@Getter`以及`@Setter`注解用于为字段创建`getter`方法以及`setter`方法

## 4.5 @ToString

`@ToString`注解用于创建`Object`的`toString`方法

## 4.6 @Data

`Data`注解包含了`@Getter`、`@Setter`、`@RequiredArgsConstructor`、`@ToString`以及`@EqualsAndHashCode`、的功能

## 4.7 @Slf4j

`@Slf4j`注解用于生成一个`log`字段，可以指定参数`topic`的值，其值代表`loggerName`

`@Slf4j(topic = "error")`等效于下面这段代码

```java
  private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger("error");
```

## 4.8 Tips

### 4.8.1 java16编译失败

若编译器版本是`java16`的话，编译使用了`lombok`的项目会出现如下的错误

```
Fatal error compiling: java.lang.ExceptionInInitializerError: Unable to make field private com.sun.tools.javac.processing.JavacProcessingEnvironment$DiscoveredProcessors com.sun.tools.javac.processing.JavacProcessingEnvironment.discoveredProcs accessible: module jdk.compiler does not "opens com.sun.tools.javac.processing" to unnamed module
```

解决方式：安装低版本的`java`，比如`java8`，设置`JAVA_HOME`环境变量用于指定`java`版本

# 5 Mina

`Mina`是一个`Java`版本的`ssh-lib`

## 5.1 Maven依赖

```xml
        <!-- mina -->
        <dependency>
            <groupId>org.apache.sshd</groupId>
            <artifactId>sshd-core</artifactId>
            <version>2.1.0</version>
        </dependency>
        <dependency>
            <groupId>org.apache.sshd</groupId>
            <artifactId>sshd-sftp</artifactId>
            <version>2.1.0</version>
        </dependency>

        <!-- jsch -->
        <dependency>
            <groupId>com.jcraft</groupId>
            <artifactId>jsch</artifactId>
            <version>0.1.55</version>
        </dependency>

        <!-- java native hook -->
        <dependency>
            <groupId>com.1stleg</groupId>
            <artifactId>jnativehook</artifactId>
            <version>2.1.0</version>
        </dependency>
```

**其中**

1. `jsch`是另一个`ssh-client`库
1. `jnativehook`用于捕获键盘的输入，如果仅用`Java`标准输入，则无法捕获类似`ctrl + c`这样的按键组合

## 5.2 Demo

### 5.2.1 BaseDemo

```java
package org.liuyehcf.mina;

import org.jnativehook.GlobalScreen;
import org.jnativehook.keyboard.NativeKeyEvent;
import org.jnativehook.keyboard.NativeKeyListener;

import java.io.IOException;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.nio.charset.Charset;
import java.util.Scanner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
class BaseDemo {

    private static final ExecutorService EXECUTOR = Executors.newCachedThreadPool();

    private static final int PIPE_STREAM_BUFFER_SIZE = 1024 * 100;
    final PipedInputStream sshClientInputStream = new PipedInputStream(PIPE_STREAM_BUFFER_SIZE);
    final PipedOutputStream sshClientOutputStream = new PipedOutputStream();
    private final PipedInputStream bizInputStream = new PipedInputStream(PIPE_STREAM_BUFFER_SIZE);
    private final PipedOutputStream bizOutputStream = new PipedOutputStream();

    BaseDemo() throws IOException {
        sshClientInputStream.connect(bizOutputStream);
        sshClientOutputStream.connect(bizInputStream);
    }

    void beginRead() {
        EXECUTOR.execute(() -> {
            final byte[] buffer = new byte[10240];
            while (!Thread.currentThread().isInterrupted()) {
                try {
                    int readNum = bizInputStream.read(buffer);

                    final byte[] actualBytes = new byte[readNum];
                    System.arraycopy(buffer, 0, actualBytes, 0, readNum);

                    writeAndFlush(actualBytes);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }

    void beginWriteJnativehook() {
        EXECUTOR.execute(() -> {
            try {
                Logger logger = Logger.getLogger(GlobalScreen.class.getPackage().getName());
                logger.setLevel(Level.OFF);
                GlobalScreen.registerNativeHook();
                GlobalScreen.addNativeKeyListener(new NativeKeyListener() {
                    @Override
                    public void nativeKeyTyped(NativeKeyEvent nativeKeyEvent) {
                        byte keyCode = (byte) nativeKeyEvent.getKeyChar();

                        try {
                            bizOutputStream.write(keyCode);
                            bizOutputStream.flush();
                        } catch (Throwable e) {
                            e.printStackTrace();
                        }
                    }

                    @Override
                    public void nativeKeyPressed(NativeKeyEvent nativeKeyEvent) {
                        // default
                    }

                    @Override
                    public void nativeKeyReleased(NativeKeyEvent nativeKeyEvent) {
                        // default
                    }
                });
            } catch (Throwable e) {
                e.printStackTrace();
            }
        });
    }

    void beginWriteStd() {
        EXECUTOR.execute(() -> {
            try {
                final Scanner scanner = new Scanner(System.in);
                while (!Thread.currentThread().isInterrupted()) {
                    final String command = scanner.nextLine();

                    bizOutputStream.write((command + "\n").getBytes());
                    bizOutputStream.flush();
                }
            } catch (Throwable e) {
                e.printStackTrace();
            }
        });
    }

    private void writeAndFlush(byte[] bytes) throws IOException {
        synchronized (System.out) {
            System.out.write(bytes);
            System.out.flush();
        }
    }
}
```

### 5.2.2 MinaSshDemo

```java
package org.liuyehcf.mina;

import org.apache.sshd.client.SshClient;
import org.apache.sshd.client.channel.ChannelShell;
import org.apache.sshd.client.channel.ClientChannelEvent;
import org.apache.sshd.client.future.ConnectFuture;
import org.apache.sshd.client.session.ClientSession;
import org.apache.sshd.common.util.io.NoCloseInputStream;
import org.apache.sshd.common.util.io.NoCloseOutputStream;

import java.io.IOException;
import java.util.Collections;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
public class MinaSshDemo extends BaseDemo {

    private MinaSshDemo() throws IOException {

    }

    public static void main(String[] args) throws Exception {
        new MinaSshDemo().boot();
    }

    private void boot() throws Exception {
        final SshClient client = SshClient.setUpDefaultClient();
        client.start();
        final ConnectFuture connect = client.connect("HCF", "localhost", 22);
        connect.await(5000L);
        final ClientSession session = connect.getSession();
        session.addPasswordIdentity("???");
        session.auth().verify(5000L);

        final ChannelShell channel = session.createShellChannel();
        channel.setIn(new NoCloseInputStream(sshClientInputStream));
        channel.setOut(new NoCloseOutputStream(sshClientOutputStream));
        channel.setErr(new NoCloseOutputStream(sshClientOutputStream));

        // 解决颜色显示以及中文乱码的问题
        channel.setPtyType("xterm-256color");
        channel.setEnv("LANG", "zh_CN.UTF-8");
        channel.open();

        beginRead();
//        beginWriteJnativehook();
        beginWriteStd();

        channel.waitFor(Collections.singleton(ClientChannelEvent.CLOSED), 0);
    }
}
```

### 5.2.3 JschSshDemo

```java
package org.liuyehcf.mina;

import com.jcraft.jsch.ChannelShell;
import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;

import java.io.IOException;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2018/12/20
 */
public class JschSshDemo extends BaseDemo {

    private JschSshDemo() throws IOException {

    }

    public static void main(final String[] args) throws Exception {
        new JschSshDemo().boot();
    }

    private void boot() throws Exception {
        JSch jsch = new JSch();

        Session session = jsch.getSession("HCF", "localhost", 22);
        java.util.Properties config = new java.util.Properties();
        config.put("StrictHostKeyChecking", "no");
        session.setConfig(config);
        session.setPassword("???");
        session.connect();

        ChannelShell channel = (ChannelShell) session.openChannel("shell");
        channel.setInputStream(sshClientInputStream);
        channel.setOutputStream(sshClientOutputStream);
        channel.connect();

        beginRead();
        beginWriteJnativehook();
//        beginWriteStd();

        TimeUnit.SECONDS.sleep(1000000);
    }
}
```

## 5.3 修改IdleTimeOut

```java
        Class<FactoryManager> factoryManagerClass = FactoryManager.class;

        Field field = factoryManagerClass.getField("DEFAULT_IDLE_TIMEOUT");
        Field modifiersField = Field.class.getDeclaredField("modifiers");
        modifiersField.setAccessible(true);
        modifiersField.setInt(field, field.getModifiers() & ~Modifier.FINAL);

        field.setAccessible(true);

        field.set(null, TimeUnit.SECONDS.toMillis(config.getIdleIntervalFrontend()));
```

## 5.4 修复显示异常的问题

```sh
stty cols 190 && stty rows 21 && export TERM=xterm-256color && bash
```

## 5.5 参考

* [mina-sshd](https://github.com/apache/mina-sshd)
* [jnativehook](https://github.com/kwhat/jnativehook)
* [Java 反射修改 final 属性值](https://blog.csdn.net/tabactivity/article/details/50726353)

# 6 SonarQube

[Quick-Start](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/)

```sh
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

[SonarScanner for Maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

```sh
mvn clean verify sonar:sonar -DskipTests -Dsonar.login=admin -Dsonar.password=xxxx
```

# 7 Swagger

下面给一个示例

## 7.1 环境

1. `IDEA`
1. `Maven3.3.9`
1. `Spring Boot`
1. `Swagger`

## 7.2 Demo工程目录结构

```
.
├── pom.xml
├── src
│   └── main
│       └── java
│           └── org
│               └── liuyehcf
│                   └── swagger
│                       ├── UserApplication.java
│                       ├── config
│                       │   └── SwaggerConfig.java
│                       ├── controller
│                       │   └── UserController.java
│                       └── entity
│                           └── User.java
```

## 7.3 pom文件

引入`Spring-boot`以及`Swagger`的依赖即可，完整内容如下

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>swagger</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.6.1</version>
        </dependency>
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger-ui</artifactId>
            <version>2.6.1</version>
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
                    <mainClass>org.liuyehcf.swagger.UserApplication</mainClass>
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

## 7.4 Swagger Config Bean

```java
package org.liuyehcf.swagger.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("org.liuyehcf.swagger")) //包路径
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Spring Boot - Swagger - Demo")
                .description("THIS IS A SWAGGER DEMO")
                .termsOfServiceUrl("http://liuyehcf.github.io") //这个不知道干嘛的
                .contact("liuye")
                .version("1.0.0")
                .build();
    }

}
```

1. `@Configuration`：让`Spring`来加载该类配置
1. `@EnableSwagger2`：启用`Swagger2`
* 注意替换`.apis(RequestHandlerSelectors.basePackage("org.liuyehcf.swagger"))`这句中的包路径

## 7.5 Controller

```java
package org.liuyehcf.swagger.controller;

import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.liuyehcf.swagger.entity.User;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/user")
public class UserController {

    private static Map<Integer, User> userMap = new HashMap<>();

    @ApiOperation(value = "GET_USER_API_1", notes = "获取User方式1")
    @RequestMapping(value = "getApi1/{id}", method = RequestMethod.GET)
    @ResponseBody
    public User getUserByIdAndName1(
            @ApiParam(name = "id", value = "用户id", required = true) @PathVariable int id,
            @ApiParam(name = "name", value = "用户名字", required = true) @RequestParam String name) {
        if (userMap.containsKey(id)) {
            User user = userMap.get(id);
            if (user.getName().equals(name)) {
                return user;
            }
        }
        return null;
    }

    @ApiOperation(value = "GET_USER_API_2", notes = "获取User方式2")
    @ApiImplicitParams({
            @ApiImplicitParam(name = "id", value = "用户id", required = true, paramType = "path", dataType = "int"),
            @ApiImplicitParam(name = "name", value = "用户名字", required = true, paramType = "query", dataType = "String")
    })
    @RequestMapping(value = "getApi2/{id}", method = RequestMethod.GET)
    @ResponseBody
    public User getUserByIdAndName2(
            @PathVariable int id,
            @RequestParam String name) {
        if (userMap.containsKey(id)) {
            User user = userMap.get(id);
            if (user.getName().equals(name)) {
                return user;
            }
        }
        return null;
    }

    @ApiOperation(value = "ADD_USER_API_1", notes = "增加User方式1")
    @RequestMapping(value = "/addUser1", method = RequestMethod.POST)
    @ResponseBody
    public String addUser1(
            @ApiParam(name = "user", value = "用户User", required = true) @RequestBody User user) {
        if (userMap.containsKey(user.getId())) {
            return "failure";
        }
        userMap.put(user.getId(), user);
        return "success";
    }

    @ApiOperation(value = "ADD_USER_API_2", notes = "增加User方式2")
    @ApiImplicitParam(name = "user", value = "用户User", required = true, paramType = "body", dataType = "User")
    @RequestMapping(value = "/addUser2", method = RequestMethod.POST)
    @ResponseBody
    public String addUser2(@RequestBody User user) {
        if (userMap.containsKey(user.getId())) {
            return "failure";
        }
        userMap.put(user.getId(), user);
        return "success";
    }

}
```

我们通过`@ApiOperation`注解来给`API`增加说明、通过`@ApiParam`、`@ApiImplicitParams`、`@ApiImplicitParam`注解来给参数增加说明（**其实不加这些注解，`API`文档也能生成，只不过描述主要来源于函数等命名产生，对用户并不友好，我们通常需要自己增加一些说明来丰富文档内容**）

* `@ApiImplicitParam`最好指明`paramType`与`dataType`属性。`paramType`可以是`path`、`query`、`body`
* `@ApiParam`没有`paramType`与`dataType`属性，因为该注解可以从参数（参数类型及其`Spring MVC`注解）中获取这些信息

### 7.5.1 User

`Controller`中用到的实体类

```java
package org.liuyehcf.swagger.entity;

public class User {
    private int id;

    private String name;

    private String address;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }
}
```

## 7.6 Application

```java
package org.liuyehcf.swagger;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.context.annotation.ComponentScan;

@EnableAutoConfiguration
@ComponentScan("org.liuyehcf.swagger.*")
public class UserApplication {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(UserApplication.class, args);
    }
}
```

成功启动后，即可访问`http://localhost:8080/swagger-ui.html`

## 7.7 参考

* [Spring Boot中使用Swagger2构建强大的RESTful API文档](https://www.jianshu.com/p/8033ef83a8ed)
* [Spring4集成Swagger：真的只需要四步，五分钟速成](http://blog.csdn.net/blackmambaprogrammer/article/details/72354007)
* [Swagger](https://swagger.io/)

# 8 dom4j

这里以一个`Spring`的配置文件为例，通过一个示例来展示`Dom4j`如何写和读取`xml`文件

1. 由于`Spring`配置文件的根元素`beans`需要带上`xmlns`，所以在添加根元素时需要填上`xmlns`所对应的`url`
1. 在读取该带有`xmlns`的配置文件时，需要为`SAXReader`绑定`xmlns`
1. 在写`xPathExpress`时，需要带上`xmlns`前缀

**代码清单**

```java
package org.liuyehcf.dom4j;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Dom4jDemo {
    public static final String FILE_PATH = "dom4j/src/main/resources/sample.xml";

    public static void main(String[] args) {
        writeXml();

        readXml();
    }

    private static void writeXml() {
        Document doc = DocumentHelper.createDocument();
        doc.addComment("a simple demo ");

        //注意，xmlns只能在创建Element时才能添加，无法通过addAttribute添加xmlns属性
        Element beansElement = doc.addElement("beans", "http://www.springframework.org/schema/beans");
        beansElement.addAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
        beansElement.addAttribute("xsi:schemaLocation", "http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd");

        Element beanElement = beansElement.addElement("bean");
        beanElement.addAttribute("id", "sample");
        beanElement.addAttribute("class", "org.liuyehcf.dom4j.Person");
        beanElement.addComment("This is comment");

        Element propertyElement = beanElement.addElement("property");
        propertyElement.addAttribute("name", "nickName");
        propertyElement.addAttribute("value", "liuye");

        propertyElement = beanElement.addElement("property");
        propertyElement.addAttribute("name", "age");
        propertyElement.addAttribute("value", "25");

        propertyElement = beanElement.addElement("property");
        propertyElement.addAttribute("name", "country");
        propertyElement.addAttribute("value", "China");

        OutputFormat format = OutputFormat.createPrettyPrint();
        XMLWriter writer = null;
        try {
            writer = new XMLWriter(new FileWriter(new File(FILE_PATH)), format);
            writer.write(doc);
            writer.flush();
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void readXml() {
        SAXReader saxReader = new SAXReader();

        Map<String, String> map = new HashMap<>();
        map.put("xmlns", "http://www.springframework.org/schema/beans");
        saxReader.getDocumentFactory().setXPathNamespaceURIs(map);

        Document doc = null;
        try {
            doc = saxReader.read(new File(FILE_PATH));
        } catch (DocumentException e) {
            e.printStackTrace();
            return;
        }

        List list = doc.selectNodes("/beans/xmlns:bean/xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("//xmlns:bean/xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("/beans/*/xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("//xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("/beans//xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("//xmlns:property/@value=liuye");
        System.out.println(list.size());

        list = doc.selectNodes("//xmlns:property/@*=liuye");
        System.out.println(list.size());

        list = doc.selectNodes("//xmlns:bean|//xmlns:property");
        System.out.println(list.size());

    }
}
```

**生成的xml文件如下**

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--a simple demo -->
<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">
  <bean id="sample" class="org.liuyehcf.dom4j.Person">
    <!--This is comment-->
    <property name="nickName" value="liuye"/>
    <property name="age" value="25"/>
    <property name="country" value="China"/>
  </bean>
</beans>

```

**输出如下**

```
3
3
3
3
3
1
1
4
```

## 8.1 基本数据结构

dom4j几乎所有的数据类型都继承自Node接口，下面介绍几个常用的数据类型

1. **`Document`**：表示整个xml文件
1. **`Element`**：元素
1. **`Attribute`**：元素的属性

## 8.2 Node.selectNodes

该方法根据`xPathExpress`来选取节点，`xPathExpress`的语法规则如下

1. `"/beans/bean/property"`：从跟节点`<beans>`开始，经过`<bean>`节点的所有`<property>`节点
1. `"//property"`：所有`<property>`节点
1. "property"：**当前节点开始**的所有`<property>`节点
1. `"/beans//property"`：从根节点`<beans>`开始，所有所有`<property>`节点（无论经过几个中间节点）
1. `"/beans/bean/property/@value"`：从跟节点`<beans>`开始，经过`<bean>`节点，包含属性`value`的所有`<property>`节点
1. `"/beans/bean/property/@value=liuye"`：从跟节点`<beans>`开始，经过`<bean>`节点，包含属性`value`且值为`liuye`的所有`<property>`节点
1. `"/beans/*/property/@*=liuye"`：从跟节点`<beans>`开始，经过任意节点（注意`*`与`//`不同，`*`只匹配一个节点，`//`匹配任意零或多层节点），包含任意属性且值为`liuye`的所有`<property>`节点
* 通配符
    * `*`可以匹配任意节点
    * `@*`可以匹配任意属性
    * `|`表示或运算
* **所有以`/`或者`//`开始的`xPathExpress`都与当前节点的位置无关**

**注意，如果`xml`文件带有`xmlns`，那么在写`xPathExpress`时需要带上`xmlns`前缀，例如示例中那样的写法**

## 8.3 参考

* [Dom4J解析XML](https://www.jianshu.com/p/53ee5835d997)
* [dom4j简单实例](https://www.cnblogs.com/ikuman/archive/2012/12/04/2800872.html)
* [Dom4j为XML文件要结点添加xmlns属性](http://blog.csdn.net/larry_lv/article/details/6613379)
* [Dom4j中SelectNodes使用方法](http://blog.csdn.net/hekaihaw/article/details/54376656)
* [dom4j通过 xpath 处理xmlns](https://www.cnblogs.com/zxcgy/p/6697557.html)

# 9 Cglib

# 10 JMH

比较的序列化框架如下

1. `fastjson`
1. `kryo`
1. `hessian`
1. `java-builtin`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>jmh</artifactId>
    <version>1.0.0</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-core</artifactId>
            <version>1.21</version>
        </dependency>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-generator-annprocess</artifactId>
            <version>1.21</version>
        </dependency>

        <dependency>
            <groupId>com.caucho</groupId>
            <artifactId>hessian</artifactId>
            <version>4.0.51</version>
        </dependency>

        <dependency>
            <groupId>com.esotericsoftware</groupId>
            <artifactId>kryo</artifactId>
            <version>4.0.2</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.62</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
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
        </plugins>
    </build>
</project>
```

```java
package org.liuyehcf.jmh.serialize;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2019/10/15
 */
@Warmup(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(1)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
public class SerializerCmp {

    private static final Map<String, String> MAP_SIZE_1 = new HashMap<>();
    private static final Map<String, String> MAP_SIZE_10 = new HashMap<>();
    private static final Map<String, String> MAP_SIZE_100 = new HashMap<>();

    static {
        for (int i = 0; i < 1; i++) {
            MAP_SIZE_1.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }

        for (int i = 0; i < 10; i++) {
            MAP_SIZE_10.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }

        for (int i = 0; i < 100; i++) {
            MAP_SIZE_100.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }
    }

    @Benchmark
    public void json_size_1() {
        CloneUtils.jsonClone(MAP_SIZE_1);
    }

    @Benchmark
    public void kryo_size_1() {
        CloneUtils.kryoClone(MAP_SIZE_1);
    }

    @Benchmark
    public void hessian_size_1() {
        CloneUtils.hessianClone(MAP_SIZE_1);
    }

    @Benchmark
    public void java_size_1() {
        CloneUtils.javaClone(MAP_SIZE_1);
    }

    @Benchmark
    public void json_size_10() {
        CloneUtils.jsonClone(MAP_SIZE_10);
    }

    @Benchmark
    public void kryo_size_10() {
        CloneUtils.kryoClone(MAP_SIZE_10);
    }

    @Benchmark
    public void hessian_size_10() {
        CloneUtils.hessianClone(MAP_SIZE_10);
    }

    @Benchmark
    public void java_size_10() {
        CloneUtils.javaClone(MAP_SIZE_10);
    }

    @Benchmark
    public void json_size_100() {
        CloneUtils.jsonClone(MAP_SIZE_100);
    }

    @Benchmark
    public void kryo_size_100() {
        CloneUtils.kryoClone(MAP_SIZE_100);
    }

    @Benchmark
    public void hessian_size_100() {
        CloneUtils.hessianClone(MAP_SIZE_100);
    }

    @Benchmark
    public void java_size_100() {
        CloneUtils.javaClone(MAP_SIZE_100);
    }

    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder()
                .include(SerializerCmp.class.getSimpleName())
                .build();

        new Runner(opt).run();
    }
}
```

**注解含义解释**

1. `Warmup`：配置预热参数
    * `iterations`: 预测执行次数
    * `time`：每次执行的时间
    * `timeUnit`：每次执行的时间单位
1. `Measurement`：配置测试参数
    * `iterations`: 测试执行次数
    * `time`：每次执行的时间
    * `timeUnit`：每次执行的时间单位
1. `Fork`：总共运行几轮
1. `BenchmarkMode`：衡量的指标，包括平均值，峰值等
1. `OutputTimeUnit`：输出结果的时间单位

**输出**

```
...

Benchmark                       Mode  Cnt      Score       Error  Units
SerializerCmp.hessian_size_1    avgt    5   5307.286 ±   327.709  ns/op
SerializerCmp.hessian_size_10   avgt    5   8745.407 ±   248.948  ns/op
SerializerCmp.hessian_size_100  avgt    5  47200.123 ±  2167.454  ns/op
SerializerCmp.java_size_1       avgt    5   4959.845 ±   300.456  ns/op
SerializerCmp.java_size_10      avgt    5  12948.638 ±   229.580  ns/op
SerializerCmp.java_size_100     avgt    5  97033.259 ±  1465.232  ns/op
SerializerCmp.json_size_1       avgt    5    631.037 ±    39.292  ns/op
SerializerCmp.json_size_10      avgt    5   4364.215 ±   740.259  ns/op
SerializerCmp.json_size_100     avgt    5  57205.805 ±  4211.084  ns/op
SerializerCmp.kryo_size_1       avgt    5   1780.679 ±    84.639  ns/op
SerializerCmp.kryo_size_10      avgt    5   5426.511 ±   264.606  ns/op
SerializerCmp.kryo_size_100     avgt    5  48886.075 ± 13722.655  ns/op
```

## 10.1 参考

* [JMH: 最装逼，最牛逼的基准测试工具套件](https://www.jianshu.com/p/0da2988b9846)
* [使用JMH做Java微基准测试](https://www.jianshu.com/p/09837e2b4408)

