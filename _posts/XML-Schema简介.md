---
title: XML Schema简介
date: 2018-01-04 22:47:23
tags: 
- 摘录
categories: 
- Web
- XML
---

__目录__

<!-- toc -->
<!--more-->

# 1 概念介绍

## 1.1 示例

随便摘取一段Spring配置文件作为示例

```xml
<beans xmlns="http:// www.springframework.org/schema/beans"
xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="
http:// www.springframework.org/schema/beans
http:// www.springframework.org/schema/beans/spring-beans-3.0.xsd">
</beans>
```

## 1.2 xmlns

xmlns其实是XML Namespace的缩写

## 1.3 如何使用xmlns

使用语法：`xmlns:namespace-prefix="namespaceURI"`

1. `namespace-prefix`为自定义前缀，只要在这个XML文档中保证前缀不重复即可
1. `namespaceURI`是这个前缀对应的XML Namespace的定义

## 1.4 xmlns和xmlns:xsi有什么不同

1. xmlns表示默认的Namespace，例如`xmlns="http://www.springframework.org/schema/beans"`
，对于默认的Namespace中的元素，可以不使用前缀

1. xmlns:xsi表示使用xsi作为前缀的Namespace，当然前缀xsi需要在文档中声明

## 1.5 xsi:schemaLocation有何作用

`xsi:schemaLocation`属性其实是Namespace为`http://www.w3.org/2001/XMLSchema-instance`里的`schemaLocation`属性，正是因为我们一开始声明了`xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"`

它定义了`XML Namespace`和`对应的XSD(Xml Schema Definition)文档的位置`的__关系__

它的值由__一个或多个URI__引用对组成，两个URI之间以空白符分隔(空格和换行均可)

1. 第一个URI是定义的XML Namespace的值
1. 第二个URI给出Schema文档的位置
* Schema处理器将从这个位置读取Schema文档，该文档的target Namespace必须与第一个URI相匹配

# 2 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [XML Schema 简介](http://www.w3school.com.cn/schema/schema_intro.asp)
* [请教xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ](http://bbs.csdn.net/topics/360012676)
