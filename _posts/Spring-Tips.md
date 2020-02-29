---
title: Spring-Tips
date: 2019-08-17 21:40:52
tags: 
- 原创
categories: 
- Java
- Framework
- Spring
---

__阅读更多__

<!--more-->

# 1 在`classpath`中以通配符的方式查找资源

可以使用`PathMatchingResourcePatternResolver`

```java
PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();

org.springframework.core.io.Resource[] resources = resolver.getResources("classpath*:liuye/**.json");
```
