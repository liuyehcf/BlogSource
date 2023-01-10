---
title: Java-Frequently-Used-Libs
date: 2019-04-20 20:15:29
tags: 
- 原创
categories: 
- Java
- Library
---

**阅读更多**

<!--more-->

# 1 JMH

比较的序列化框架如下

1. `fastjson`
1. `kryo`
1. `hessian`
1. `java-builtin`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>jmh</artifactId>
    <version>1.0.0</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-core</artifactId>
            <version>1.21</version>
        </dependency>
        <dependency>
            <groupId>org.openjdk.jmh</groupId>
            <artifactId>jmh-generator-annprocess</artifactId>
            <version>1.21</version>
        </dependency>

        <dependency>
            <groupId>com.caucho</groupId>
            <artifactId>hessian</artifactId>
            <version>4.0.51</version>
        </dependency>

        <dependency>
            <groupId>com.esotericsoftware</groupId>
            <artifactId>kryo</artifactId>
            <version>4.0.2</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.62</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

```java
package org.liuyehcf.jmh.serialize;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2019/10/15
 */
@Warmup(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Measurement(iterations = 5, time = 1, timeUnit = TimeUnit.SECONDS)
@Fork(1)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
public class SerializerCmp {

    private static final Map<String, String> MAP_SIZE_1 = new HashMap<>();
    private static final Map<String, String> MAP_SIZE_10 = new HashMap<>();
    private static final Map<String, String> MAP_SIZE_100 = new HashMap<>();

    static {
        for (int i = 0; i < 1; i++) {
            MAP_SIZE_1.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }

        for (int i = 0; i < 10; i++) {
            MAP_SIZE_10.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }

        for (int i = 0; i < 100; i++) {
            MAP_SIZE_100.put(UUID.randomUUID().toString(), UUID.randomUUID().toString());
        }
    }

    @Benchmark
    public void json_size_1() {
        CloneUtils.jsonClone(MAP_SIZE_1);
    }

    @Benchmark
    public void kryo_size_1() {
        CloneUtils.kryoClone(MAP_SIZE_1);
    }

    @Benchmark
    public void hessian_size_1() {
        CloneUtils.hessianClone(MAP_SIZE_1);
    }

    @Benchmark
    public void java_size_1() {
        CloneUtils.javaClone(MAP_SIZE_1);
    }

    @Benchmark
    public void json_size_10() {
        CloneUtils.jsonClone(MAP_SIZE_10);
    }

    @Benchmark
    public void kryo_size_10() {
        CloneUtils.kryoClone(MAP_SIZE_10);
    }

    @Benchmark
    public void hessian_size_10() {
        CloneUtils.hessianClone(MAP_SIZE_10);
    }

    @Benchmark
    public void java_size_10() {
        CloneUtils.javaClone(MAP_SIZE_10);
    }

    @Benchmark
    public void json_size_100() {
        CloneUtils.jsonClone(MAP_SIZE_100);
    }

    @Benchmark
    public void kryo_size_100() {
        CloneUtils.kryoClone(MAP_SIZE_100);
    }

    @Benchmark
    public void hessian_size_100() {
        CloneUtils.hessianClone(MAP_SIZE_100);
    }

    @Benchmark
    public void java_size_100() {
        CloneUtils.javaClone(MAP_SIZE_100);
    }

    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder()
                .include(SerializerCmp.class.getSimpleName())
                .build();

        new Runner(opt).run();
    }
}
```

**注解含义解释**

1. `Warmup`：配置预热参数
    * `iterations`: 预测执行次数
    * `time`：每次执行的时间
    * `timeUnit`：每次执行的时间单位
1. `Measurement`：配置测试参数
    * `iterations`: 测试执行次数
    * `time`：每次执行的时间
    * `timeUnit`：每次执行的时间单位
1. `Fork`：总共运行几轮
1. `BenchmarkMode`：衡量的指标，包括平均值，峰值等
1. `OutputTimeUnit`：输出结果的时间单位

**输出**

```
...

Benchmark                       Mode  Cnt      Score       Error  Units
SerializerCmp.hessian_size_1    avgt    5   5307.286 ±   327.709  ns/op
SerializerCmp.hessian_size_10   avgt    5   8745.407 ±   248.948  ns/op
SerializerCmp.hessian_size_100  avgt    5  47200.123 ±  2167.454  ns/op
SerializerCmp.java_size_1       avgt    5   4959.845 ±   300.456  ns/op
SerializerCmp.java_size_10      avgt    5  12948.638 ±   229.580  ns/op
SerializerCmp.java_size_100     avgt    5  97033.259 ±  1465.232  ns/op
SerializerCmp.json_size_1       avgt    5    631.037 ±    39.292  ns/op
SerializerCmp.json_size_10      avgt    5   4364.215 ±   740.259  ns/op
SerializerCmp.json_size_100     avgt    5  57205.805 ±  4211.084  ns/op
SerializerCmp.kryo_size_1       avgt    5   1780.679 ±    84.639  ns/op
SerializerCmp.kryo_size_10      avgt    5   5426.511 ±   264.606  ns/op
SerializerCmp.kryo_size_100     avgt    5  48886.075 ± 13722.655  ns/op
```

## 1.1 参考

* [JMH: 最装逼，最牛逼的基准测试工具套件](https://www.jianshu.com/p/0da2988b9846)
* [使用JMH做Java微基准测试](https://www.jianshu.com/p/09837e2b4408)

# 2 Guava

1. `com.google.common.cache.Cache`
1. `com.google.common.collect.Range`
