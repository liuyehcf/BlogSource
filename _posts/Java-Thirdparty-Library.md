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
1. `commons-io:commons-io`
1. `commons-collections:commons-collections`
1. `commons-cli:commons-cli`

**`apache`：**

1. `org.apache.commons:commons-lang3`
1. `org.apache.commons:commons-collections4`

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

## 2.1 Maven依赖

```xml
<dependency>
    <groupId>org.slf4j</groupId>
    <artifactId>slf4j-log4j12</artifactId>
    <version>1.7.25</version>
</dependency>
```

`slf4j-log4j12`模块包含了`slf4j-api`以及`log4j`，因此使用`slf4j+log4j`只需要依赖`slf4j-log4j12`即可

## 2.2 Log4j

`Log4j`由三个重要的组件构成：

1. **日志信息的优先级**：从高到低有`ERROR`、`WARN`、 `INFO`、`DEBUG`，分别用来指定这条日志信息的重要程度
1. **日志信息的输出目的地**：指定了日志将打印到控制台还是文件中
1. **日志信息的输出格式**：控制了日志信息的显示内容

### 2.2.1 Log级别

1. `ALL Level`：等级最低，用于打开所有日志记录
1. `DEBUG Level`：指出细粒度信息事件对调试应用程序是非常有帮助的
1. `INFO level`：表明消息在粗粒度级别上突出强调应用程序的运行过程
1. `WARN level`：表明会出现潜在错误的情形
1. `ERROR level`：指出虽然发生错误事件，但仍然不影响系统的继续运行
1. `FATAL level`：指出每个严重的错误事件将会导致应用程序的退出
1. `OFF Level`：等级最高，用于关闭所有日志记录
* `Log4j`建议只使用四个级别，优先级从高到低分别是`ERROR`、`WARN`、`INFO`、`DEBUG`。通过在这里定义的级别，您可以控制到应用程序中相应级别的日志信息的开关。比如在这里定义了`INFO`级别，则应用程序中所有`DEBUG`级别的日志信息将不被打印出来，也是说大于等于的级别的日志才输出

### 2.2.2 Log4j配置

可以完全不使用配置文件，而是在代码中配置`Log4j`环境。但是，使用配置文件将使应用程序更加灵活。**`Log4j`支持两种配置文件格式**，一种是`XML`格式的文件，一种是属性文件。下面我们介绍属性文件做为配置文件的方法

#### 2.2.2.1 配置根Logger

配置根`Logger`，其语法如下：

```
log4j.rootLogger = [ level ] , appenderName, appenderName, ...
```

* `level`是日志记录的优先级，分为`OFF`、`FATAL`、`ERROR`、`WARN`、`INFO`、`DEBUG`、`ALL`或者自定义的级别。`Log4j`建议只使用四个级别，优先级从高到低分别是`ERROR`、`WARN`、`INFO`、`DEBUG`。通过在这里定义的级别，可以控制到应用程序中相应级别的日志信息的开关。比如在这里定义了`INFO`级别，则应用程序中所有`DEBUG`级别的日志信息将不被打印出来
* `appenderName`就是指日志信息输出到哪个地方。可以同时指定多个输出目的地

#### 2.2.2.2 配置日志信息输出目的地Appender

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

#### 2.2.2.3 配置日志信息的格式

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

1. `%%`：输出一个`%`字符
1. `%c`：输出所属的类目，通常就是所在类的全名
1. `%d`：输出日志时间点的日期或时间，默认格式为`ISO8601`，也可以在其后指定格式，比如：`%d{yyyy-MM-dd HH:mm:ss}`，输出类似：`2017-03-22 18:14:34`
1. `%F`：输出日志消息产生时所在的文件名称
1. `%l`：输出日志事件的发生位置，包括类目名、发生的线程，以及在代码中的行数。举例：`Testlog4.main(TestLog4.java:10)`
1. `%L`：输出代码中的行号
1. `%m`：输出代码中指定的消息，产生的日志具体信息
1. `%n`：输出一个回车换行符，`Windows`平台为`rn`，`Unix`平台为`n`
1. `%p`：输出优先级，即`DEBUG`，`INFO`，`WARN`，`ERROR`，`FATAL`
1. `%r`：输出自应用启动到输出该`log`信息耗费的毫秒数
1. `%t`：输出产生该日志事件的线程名
1. `%x`：输出和当前线程相关联的`NDC`（嵌套诊断环境），尤其用到像`java servlets`这样的多客户多线程的应用中

### 2.2.3 配置文件示例

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

## 2.3 参考

* [详细的log4j配置使用流程](http://blog.csdn.net/sunny_na/article/details/55212029)

# 3 SonarQube

[Quick-Start](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/)

```sh
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

[SonarScanner for Maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

```sh
mvn clean verify sonar:sonar -DskipTests -Dsonar.login=admin -Dsonar.password=xxxx
```

# 4 dom4j

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

## 4.1 基本数据结构

dom4j几乎所有的数据类型都继承自Node接口，下面介绍几个常用的数据类型

1. **`Document`**：表示整个xml文件
1. **`Element`**：元素
1. **`Attribute`**：元素的属性

## 4.2 Node.selectNodes

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

## 4.3 参考

* [Dom4J解析XML](https://www.jianshu.com/p/53ee5835d997)
* [dom4j简单实例](https://www.cnblogs.com/ikuman/archive/2012/12/04/2800872.html)
* [Dom4j为XML文件要结点添加xmlns属性](http://blog.csdn.net/larry_lv/article/details/6613379)
* [Dom4j中SelectNodes使用方法](http://blog.csdn.net/hekaihaw/article/details/54376656)
* [dom4j通过 xpath 处理xmlns](https://www.cnblogs.com/zxcgy/p/6697557.html)
