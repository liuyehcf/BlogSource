---
title: Apache-Mina-Demo
date: 2019-01-03 18:59:56
tags: 
- 原创
categories: 
- Java
- Framework
- Mina
---

__阅读更多__

<!--more-->

# 1 Maven依赖

```xml
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
```

# 2 Demo

```Java

```

# 3 修改IdleTimeOut

```Java
        Class<FactoryManager> factoryManagerClass = FactoryManager.class;

        Field field = factoryManagerClass.getField("DEFAULT_IDLE_TIMEOUT");
        Field modifiersField = Field.class.getDeclaredField("modifiers");
        modifiersField.setAccessible(true);
        modifiersField.setInt(field, field.getModifiers() & ~Modifier.FINAL);

        field.setAccessible(true);

        field.set(null, TimeUnit.SECONDS.toMillis(config.getIdleIntervalFrontend()));
```

# 4 参考

* []()
* [Java 反射修改 final 属性值](https://blog.csdn.net/tabactivity/article/details/50726353)

