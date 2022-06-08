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

# 2 `& 0xff`

```java
    public static void main(String[] args) {
        byte b = -1;
        int i1 = (int) b;
        int i2 = b & 0xff;
        System.out.printf("i1=%d%n", i1);
        System.out.printf("i2=%d%n", i2);
    }
```

这段代码的输出如下

```
i1=-1
i2=255
```

对于`byte`而言，`-1`的二进制补码为`11111111`

* 直接转型成`int`类型时，会用符号位填补空缺位置，即`11111111111111111111111111111111`，即值仍为`-1`
* 而用`b & 0xff`，相当于用`0`填补空缺位置，即`00000000000000000000000011111111`，即值为`255`
