---
title: Java-排坑日志
date: 2021-09-06 10:58:15
tags: 
- 原创
categories: 
- Java
---

**阅读更多**

<!--more-->

# 1 containsKey不符合预期

若`key`发生过变化，且该变化会导致hashCode变化，就会出现这个问题
