---
title: Dom4j-Demo
date: 2018-01-26 14:04:15
tags: 
- 原创
categories: 
- Java
- Framework
- Dom4j
---

__目录__

<!-- toc -->
<!--more-->

# 1 Demo

这里以一个Spring的配置文件为例，通过一个Demo来展示Dom4j如何写和读取xml文件

1. 由于Spring配置文件的根元素`beans`需要带上xmlns，所以在添加根元素时需要填上xmlns所对应的url，即代码清单中的(1)
1. 在读取该带有xmlns的配置文件时，需要为SAXReader绑定xmlns，即代码清单中的(2)
1. 在写`xPathExpress`时，需要带上xmlns前缀，即代码清单中的(3)

__代码清单__

```Java
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

        // 注意，xmlns只能在创建Element时才能添加，无法通过addAttribute添加xmlns属性
        Element beansElement = doc.addElement("beans", "http:// www.springframework.org/schema/beans");
        beansElement.addAttribute("xmlns:xsi", "http:// www.w3.org/2001/XMLSchema-instance");
        beansElement.addAttribute("xsi:schemaLocation", "http:// www.springframework.org/schema/beans http:// www.springframework.org/schema/beans/spring-beans.xsd");

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
        map.put("xmlns", "http:// www.springframework.org/schema/beans");
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

        list = doc.selectNodes("// xmlns:bean/xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("/beans/*/xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("// xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("/beans// xmlns:property");
        System.out.println(list.size());

        list = doc.selectNodes("// xmlns:property/@value=liuye");
        System.out.println(list.size());

        list = doc.selectNodes("// xmlns:property/@*=liuye");
        System.out.println(list.size());

        list = doc.selectNodes("// xmlns:bean|// xmlns:property");
        System.out.println(list.size());

    }
}
```

__生成的xml文件如下__

```xml
<?xml version="1.0" encoding="UTF-8"?>

<!--a simple demo -->
<beans xmlns="http:// www.springframework.org/schema/beans" xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http:// www.springframework.org/schema/beans http:// www.springframework.org/schema/beans/spring-beans.xsd">
  <bean id="sample" class="org.liuyehcf.dom4j.Person">
    <!--This is comment-->
    <property name="nickName" value="liuye"/>
    <property name="age" value="25"/>
    <property name="country" value="China"/>
  </bean>
</beans>

```

__输出如下__

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

# 2 基本数据结构

dom4j几乎所有的数据类型都继承自Node接口，下面介绍几个常用的数据类型

__Document__：表示整个xml文件

__Element__：元素

__Attribute__：元素的属性

# 3 Node.selectNodes

该方法根据`xPathExpress`来选取节点，`xPathExpress`的语法规则如下

1. `"/beans/bean/property"`：从跟节点`<beans>`开始，经过`<bean>`节点的所有`<property>`节点
1. `"//property"`：所有`<property>`节点
1. "property"：__当前节点开始__的所有`<property>`节点
1. `"/beans//property"`：从根节点`<beans>`开始，所有所有`<property>`节点（无论经过几个中间节点）
1. `"/beans/bean/property/@value"`：从跟节点`<beans>`开始，经过`<bean>`节点，包含属性`value`的所有`<property>`节点
1. `"/beans/bean/property/@value=liuye"`：从跟节点`<beans>`开始，经过`<bean>`节点，包含属性`value`且值为`liuye`的所有`<property>`节点
1. `"/beans/*/property/@*=liuye"`：从跟节点`<beans>`开始，经过任意节点（注意`*`与`//`不同，`*`只匹配一个节点，`//`匹配任意零或多层节点），包含任意属性且值为`liuye`的所有`<property>`节点
* 通配符
    * `*`可以匹配任意节点
    * `@*`可以匹配任意属性
    * `|`表示或运算
* __所有以`/`或者`//`开始的`xPathExpress`都与当前节点的位置无关__

__注意，如果xml文件带有xmlns，那么在写xPathExpress时需要带上xmlns前缀，例如Demo中那样的写法__

# 4 参考

* [Dom4J解析XML](https://www.jianshu.com/p/53ee5835d997)
* [dom4j简单实例](https://www.cnblogs.com/ikuman/archive/2012/12/04/2800872.html)
* [Dom4j为XML文件要结点添加xmlns属性](http://blog.csdn.net/larry_lv/article/details/6613379)
* [Dom4j中SelectNodes使用方法](http://blog.csdn.net/hekaihaw/article/details/54376656)
* [dom4j通过 xpath 处理xmlns](https://www.cnblogs.com/zxcgy/p/6697557.html)
