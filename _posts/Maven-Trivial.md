---
title: Maven-Trivial
date: 2017-11-27 23:39:21
tags: 
- 原创
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 Tips

## 1.1 Run Java Program

### 1.1.1 Run from Command Line

运行前先编译代码，`exec:java`不会自动编译代码，你需要手动执行`mvn compile`来完成编译

编译完成后，执行exec运行main方法

```
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main"
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.args="arg0 arg1 arg2"
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.classpathScope=runtime
```

### 1.1.2 Run at Specific Stage

将`CodeGenerator.main()`方法的执行绑定到maven的`test`阶段，通过下面的命令可以执行main方法：

```xml
<build>  
    <plugins>  
        <plugin>  
            <groupId>org.codehaus.mojo</groupId>  
            <artifactId>exec-maven-plugin</artifactId>  
            <version>1.1.1</version>  
            <executions>  
                <execution>  
                    <phase>test</phase>  
                    <goals>  
                        <goal>java</goal>  
                    </goals>  
                    <configuration>  
                        <mainClass>com.vineetmanohar.module.CodeGenerator</mainClass>  
                        <arguments>  
                            <argument>arg0</argument>  
                            <argument>arg1</argument>  
                        </arguments>  
                    </configuration>  
                </execution>  
            </executions>  
        </plugin>  
    </plugins>  
 </build>
```

### 1.1.3 Run at Specific Profile

将配置用`<profile>`标签包裹后就能通过指定该配置文件来执行main方法，如下
```
mvn test -Pcode-generator
```

```xml
<profiles>  
    <profile>  
        <id>code-generator</id>  
        <build>  
            <plugins>  
                <plugin>  
                    <groupId>org.codehaus.mojo</groupId>  
                    <artifactId>exec-maven-plugin</artifactId>  
                    <version>1.1.1</version>  
                    <executions>  
                        <execution>  
                            <phase>test</phase>  
                            <goals>  
                                <goal>java</goal>  
                            </goals>  
                            <configuration>  
                                <mainClass>com.vineetmanohar.module.CodeGenerator</mainClass>  
                                <arguments>  
                                    <argument>arg0</argument>  
                                    <argument>arg1</argument>  
                                </arguments>  
                            </configuration>  
                        </execution>  
                    </executions>  
                </plugin>  
            </plugins>  
        </build>  
    </profile>  
</profiles>
```

## 1.2 Download Specific Jar

```sh
mvn dependency:get -DgroupId=[groupId] -DartifactId=[artifactId] -Dversion=[version] -DrepoUrl=https://repo.maven.apache.org/maven2/ -Dtransitive=false
```

**Example:**

```sh
mvn dependency:get -DgroupId=org.apache.hive -DartifactId=hive-exec -Dversion=3.1.2 -DrepoUrl=https://repo.maven.apache.org/maven2/ -Dtransitive=false
```

## 1.3 Build Specific Modules

* `-pl,--projects`: Comma-delimited list of specified reactor projects to build instead of all projects. A project can be specified by `[groupId]:artifactId` or by its relative path
* `-am,--also-make`: If project list is specified, also build projects required by the list

```sh
mvn clean package -DskipTests -pl module-a,module-b -am
```

## 1.4 The Scope of Plugin Configuration

* When you place the configuration outside the `<execution>` block, it means that the configuration is applied globally to all executions of the plugin within the given phase or goals.
* When you place the configuration inside an `<execution>` block, it is scoped to that specific execution. This is useful when you need different configurations for different executions of the same plugin. Each `<execution>` block can specify different goals, phases, and configurations. 

## 1.5 Run with JVM Options

use `export MAVEN_OPTS=`

## 1.6 Maven Central Repository FTP Address

[https://repo1.maven.org/maven2/](https://repo1.maven.org/maven2/)

# 2 Loading Order When Dependencies Conflict

当一个类同时存在于依赖A于依赖B中时，加载的版本依据以下的原则

1. 首先，**依赖路径长度**，依赖路径短的优先加载
1. 其次，**依赖声明顺序（在同一个pom中）**，先声明的依赖优先加载
1. 最后，**依赖覆盖**，子POM文件中的依赖优先加载

# 3 Domestic Source

```xml
<settings>
    <mirrors>
        <mirror>
            <id>alimaven</id>
            <name>aliyun maven</name>
            <mirrorOf>central</mirrorOf>
            <url>https://maven.aliyun.com/repository/central</url>
        </mirror>
    </mirrors>
</settings>
```

# 4 Reference

* [使用Maven运行Java main的3种方式](https://www.jianshu.com/p/76abe7d04053)
