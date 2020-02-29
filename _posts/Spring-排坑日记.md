---
title: Spring-排坑日记
date: 2018-01-29 22:14:29
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 水坑1-注解扫描路径

情景还原：我在某个Service中需要实现一段逻辑，需要使用Pair来存放两个对象，于是我自定义了下面这个静态内部类

```java
@Service
public class MyService{

    //... 业务逻辑代码 ...

    private static final class Pair<K, V> {
        private final K key;
        private final V value;

        public Pair(K key, V value) {
            this.key = key;
            this.value = value;
        }

        public K getKey() {
            return key;
        }

        public V getValue() {
            return value;
        }
    }
}
```

启动时抛出了如下异常

```
2018-01-29 13:43:15.917 [localhost-startStop-1] ERROR o.s.web.servlet.DispatcherServlet - Context initialization failed
org.springframework.beans.factory.BeanCreationException: Error creating bean with name 'myService.Pair' defined in URL

...
Instantiation of bean failed; nested exception is org.springframework.beans.BeanInstantiationException: Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found; nested exception is java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()
  at org.springframework.beans.factory.support.AbstractAutowireCapableBeanFactory.instantiateBean
```

注意到没有，关键错误信息是

1. `Error creating bean with name 'myService.Pair'`
1. `Failed to instantiate [org.liuyehcf.MyService$Pair]: No default constructor found`
1. `java.lang.NoSuchMethodException: org.liuyehcf.MyService$Pair.<init>()`

这意味着，Spring为我的静态内部类Pair创建了单例，并且通过反射调用默认构造函数，由于我没有定义无参构造函数，于是报错

__那么，问题来了，我根本就没有配置过这个Pair啊！！！__

纠结了一天之后，发现Spring配置文件中的一段配置，如下

```xml
    <context:component-scan base-package="org.liuyehcf.service">
        <context:include-filter type="regex"
                                expression="org\.liuyehcf\.service\..*"/>
    </context:component-scan>
```

__就是这段配置让所有匹配正则表达式的类都被Spring扫描到，并且为之创建单例！！！__

__DONE__

# 2 水坑2-SpringBoot非Web应用

情景还原

1. SpringBoot应用
1. 非Web应用（即没有`org.springframework.boot:spring-boot-starter-web`依赖项）

启动后出现如下异常信息

```java
Caused by: org.springframework.context.ApplicationContextException: Unable to start EmbeddedWebApplicationContext due to missing EmbeddedServletContainerFactorybean.
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.getEmbeddedServletContainerFactory(EmbeddedWebApplicationContext.java:189)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.createEmbeddedServletContainer(EmbeddedWebApplicationContext.java:162)
  at org.springframework.boot.context.embedded.EmbeddedWebApplicationContext.onRefresh(EmbeddedWebApplicationContext.java:134)
  ... 16 more
```

分析：

1. 在普通的Java-Web应用中，Spring容器分为父子容器，其中子容器仅包含MVC层的Bean，父容器包含了其他所有的Bean
1. 出现异常的原因是由于Classpath中包含了`servlet-api`相关class文件，因此Spring boot认为这是一个web application。去掉servlet-api的maven依赖即可

`mvn dependency:tree`查看依赖树，确实发现有servlet-api的依赖项。排除掉servlet有关的依赖项即可

__类似的，还有如下异常（也需要排除掉servlet有关的依赖项）__

```java
Caused by: org.apache.catalina.LifecycleException: A child container failed during start
    at org.apache.catalina.core.ContainerBase.startInternal(ContainerBase.java:949)
    at org.apache.catalina.core.StandardEngine.startInternal(StandardEngine.java:262)
    at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150)
    ... 25 more
```

# 3 水坑3-SpringBoot+配置文件

情景还原

1. SpringBoot应用
1. resources/目录下有一个`application.xml`配置文件

出现的异常

```java
Caused by: org.xml.sax.SAXParseException: 文档根元素 "beans" 必须匹配 DOCTYPE 根 "null"
    at com.sun.org.apache.xerces.internal.util.ErrorHandlerWrapper.createSAXParseException(ErrorHandlerWrapper.java:203)
    at com.sun.org.apache.xerces.internal.util.ErrorHandlerWrapper.error(ErrorHandlerWrapper.java:134)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:396)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:327)
    at com.sun.org.apache.xerces.internal.impl.XMLErrorReporter.reportError(XMLErrorReporter.java:284)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.rootElementSpecified(XMLDTDValidator.java:1599)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.handleStartElement(XMLDTDValidator.java:1877)
    at com.sun.org.apache.xerces.internal.impl.dtd.XMLDTDValidator.startElement(XMLDTDValidator.java:742)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl.scanStartElement(XMLDocumentFragmentScannerImpl.java:1359)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl$ContentDriver.scanRootElementHook(XMLDocumentScannerImpl.java:1289)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl$FragmentContentDriver.next(XMLDocumentFragmentScannerImpl.java:3132)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl$PrologDriver.next(XMLDocumentScannerImpl.java:852)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentScannerImpl.next(XMLDocumentScannerImpl.java:602)
    at com.sun.org.apache.xerces.internal.impl.XMLDocumentFragmentScannerImpl.scanDocument(XMLDocumentFragmentScannerImpl.java:505)
    at com.sun.org.apache.xerces.internal.parsers.XML11Configuration.parse(XML11Configuration.java:842)
    at com.sun.org.apache.xerces.internal.parsers.XML11Configuration.parse(XML11Configuration.java:771)
    at com.sun.org.apache.xerces.internal.parsers.XMLParser.parse(XMLParser.java:141)
    at com.sun.org.apache.xerces.internal.parsers.DOMParser.parse(DOMParser.java:243)
    at com.sun.org.apache.xerces.internal.jaxp.DocumentBuilderImpl.parse(DocumentBuilderImpl.java:339)
    at sun.util.xml.PlatformXmlPropertiesProvider.getLoadingDoc(PlatformXmlPropertiesProvider.java:106)
    at sun.util.xml.PlatformXmlPropertiesProvider.load(PlatformXmlPropertiesProvider.java:78)
    ... 25 common frames omitted
```

原因：xml文件名不能是`application.xml`，改个名字就行！我了个大草！

# 4 水坑4-Duplicate spring bean id

情景还原：

1. SpringBoot应用
1. 用Junit做集成测试

Application.java与TestApplication.java以及Test.java如下

1. Application.java：应用的启动类
1. TestApplication.java：测试的启动类
1. Test.java：测试类

```java
@SpringBootApplication(scanBasePackages = {"xxx.yyy.zzz"})
@ImportResource({"classpath*:application-context.xml"})
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
```

```java
@SpringBootApplication(scanBasePackages = {"com.aliyun.nova.scene"})
@ImportResource({"classpath*:sentinel-tracer.xml","classpath*:application-context.xml"})
public class TestApplication {
}
```

```java
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = {TestApplication.class})
public class Test {
    @Test
    ...
}
```

出现的异常，提示信息是：`Duplicate spring bean id xxx`

原因是配置文件`application-context.xml`被加载了两次，导致bean重复加载了

TestApplication类不应该有`application-context.xml`，否则会加载两次（可能标记了SpringBootApplication注解的类都会被处理，导致了配置文件被加载两次）
