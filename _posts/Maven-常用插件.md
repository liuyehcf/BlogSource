---
title: Maven-常用插件
date: 2018-01-19 16:59:56
tags: 
- 摘录
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 shade

以下配置，可以将工程打包成`fat-jar`

`java -jar xxx.jar arg1 arg2 ...`可以执行该`fat-jar`

```xml
<build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.0</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <transformers>
                                <transformer
                                        implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>xxx.yyy.zzz</mainClass>
                                </transformer>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
                <configuration>
                    <filters>
                        <filter>
                            <artifact>*:*</artifact>
                            <excludes>
                                <exclude>META-INF/*.SF</exclude>
                                <exclude>META-INF/*.DSA</exclude>
                                <exclude>META-INF/*.RSA</exclude>
                            </excludes>
                        </filter>
                    </filters>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

# 2 assembly

以下配置，可以将工程打包成`fat-jar`

`java -jar xxx.jar arg1 arg2 ...`可以执行该`fat-jar`

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.1.0</version>
                <configuration>
                    <!--设置启动的类-->
                    <archive>
                        <manifest>
                            <mainClass>xxx.yyy.zzz</mainClass>
                        </manifest>
                    </archive>

                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

# 3 spring-boot-maven-plugin

所有依赖以`嵌套的方式`打包到`Fatjar`内部

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <version>2.1.4.RELEASE</version>
    <configuration>
        <mainClass>xxx.yyy.zzz</mainClass>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>repackage</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

# 4 autoconfig

```xml
<plugin>
    <groupId>com.alibaba.citrus.tool</groupId>
    <artifactId>autoconfig-maven-plugin</artifactId>
    <version>1.2.1-SNAPSHOT</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>autoconfig</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

**搜索步骤**

1. 通过命令行-P参数指定profile的属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若根目录存在antx.properties属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若用户目录存在antx.properties属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若用户目录不存在antx.properties属性文件
    * 那么会在用户目录下新建该属性文件，并且将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错

**对于web项目（打包方式为war）**，则会过滤所有依赖中包含占位符的文件

## 4.1 配置文件

示例代码如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<config>
    <group>
        <property name="datasource.slave.host" defaultValue="127.0.0.1" description="datasource slave host" />
        <property name="datasource.slave.port" defaultValue="3306" description="datasource slave port" />
        <property name="datasource.slave.db" defaultValue="read" description="datasource slave db" />
        <property name="datasource.slave.username" defaultValue="root" description="datasource slave username" />
        <property name="datasource.slave.password" defaultValue="123456" description=" datasource slave password" />
        <property name="datasource.slave.maxconn" defaultValue="50" description="datasource slave maxconn" />
        <property name="datasource.slave.minconn" defaultValue="25" description="datasource slave minconn" />
    </group>
    <group>
        <property name="datasource.master.host" defaultValue="127.0.0.1" description="datasource master host" />
        <property name="datasource.master.port" defaultValue="3306" description="datasource master port" />
        <property name="datasource.master.db" defaultValue="read" description="datasource master db" />
        <property name="datasource.master.username" defaultValue="root" description="datasource master username" />
        <property name="datasource.master.password" defaultValue="123456" description="datasource master password" />
        <property name="datasource.master.maxconn" defaultValue="50" description="datasource master maxconn" />
        <property name="datasource.master.minconn" defaultValue="25" description="datasource master minconn" />
    </group>
    <script>
        <generate template="application.properties.vm" destfile="WEB-INF/classes/application.properties" />
    </script>
</config>
```

其中`<script>`标签中指定需要进行占位符替换的**模板文件**。`group`标签仅仅做了分组，阅读上更清晰，没有其他作用

# 5 参考

* [maven-shade-plugin 入门指南](https://www.jianshu.com/p/7a0e20b30401)
* [maven-将依赖的 jar包一起打包到项目 jar 包中](https://www.jianshu.com/p/0c60f6ef3a4c)
* [Java 打包 FatJar 方法小结](https://www.jianshu.com/p/a7bd1f89f29f)
* [Spring Boot Maven Plugin](https://docs.spring.io/spring-boot/docs/current/maven-plugin/)
