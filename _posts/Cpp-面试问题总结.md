---
title: Cpp-面试问题总结
date: 2017-08-18 20:37:42
tags: 
- 原创
categories: 
- Job
- Cpp
---

__阅读更多__

<!--more-->

# 1 Cpp基础

1. C++堆内存最大是多少
    > 对于32位操作系统，Linux虚拟地址空间占1GB，留给用户进程3GB，Windows各占2GB，用户空间也是用户进程最大的堆申请数量了。但考虑到程序本身的大小，动态库等因素，实际的堆申请数量是打不到最大值的。因此Linux小于3GB，Windows小于2GB
