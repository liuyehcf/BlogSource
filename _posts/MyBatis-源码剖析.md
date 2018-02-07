---
title: MyBatis-源码剖析
date: 2018-02-07 08:30:09
tags: 
- 原创
categories: 
- Java
- Framework
- MyBatis
---

__目录__

<!-- toc -->
<!--more-->

# 前言

本文围绕以下几个问题展开对MyBatis源码的研究

1. MyBatis如何为我们定义的DAO接口生成实现类
1. DAO接口与映射器的XML文件如何关联
1. DAO接口的实现类如何进行SQL操作

# 代理生成


