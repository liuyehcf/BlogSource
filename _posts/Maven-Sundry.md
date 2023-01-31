---
title: Maven-Sundry
date: 2017-11-27 23:39:21
tags: 
- 原创
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 Maven运行Java程序

## 1.1 从命令行运行

运行前先编译代码，`exec:java`不会自动编译代码，你需要手动执行`mvn compile`来完成编译

编译完成后，执行exec运行main方法

```
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main"
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.args="arg0 arg1 arg2"
mvn exec:java -Dexec.mainClass="com.vineetmanohar.module.Main" -Dexec.classpathScope=runtime
```

## 1.2 在pom.xml中指定某个阶段执行

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

## 1.3 在pom.xml中指定某个配置来执行

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

# 2 依赖冲突时的加载顺序

当一个类同时存在于依赖A于依赖B中时，加载的版本依据以下的原则

1. 首先，**依赖路径长度**，依赖路径短的优先加载
1. 其次，**依赖声明顺序（在同一个pom中）**，先声明的依赖优先加载
1. 最后，**依赖覆盖**，子POM文件中的依赖优先加载

# 3 参考

* [使用Maven运行Java main的3种方式](https://www.jianshu.com/p/76abe7d04053)
