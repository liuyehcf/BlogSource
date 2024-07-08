---
title: Maven-Frequently-Used-Plugins
date: 2018-01-19 16:59:56
tags: 
- 摘录
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 Package Plugins

* `maven-assembly-plugin`: This plugin extracts all dependency JARs into raw classes and groups them together. It can also be used to build an executable JAR by specifying the main class. **It works in project with less dependencies only; for large project with many dependencies, it will cause Java class names or resource files to conflict**
    * **Cannot work well with Service Provider Interface(SPI)**, because multiply service config files across multiply dependencies may overwrite each other, and only one of them will left
* `maven-shade-plugin`: It packages all dependencies into one uber-JAR. It can also be used to build an executable JAR by specifying the main class. This plugin is particularly useful as it merges content of specific files instead of overwriting them by relocating classes. **This is needed when there are resource files that have the same name across the JARs and the plugin tries to package all the resource files together**
    * **Work well with Service Provider Interface(SPI)**, because multiply service config files across multiply dependencies will be concated to a final one.
* `spring-boot-maven-plugin`: Best for packaging Spring Boot applications, simplifies creating executable JARs/WARs with Spring Boot runtime.
    * **Cannot work well with JNI**, because JNI don't know how to parse the jar file by default
    * Work well with Service Provider Interface(SPI)

## 1.1 maven-assembly-plugin

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>3.1.0</version>
    <configuration>
        <!-- set main class -->
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
```

**Here's an example of how it CANNOT works with SPI:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.byconity</groupId>
    <artifactId>test-assembly-with-spi</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <hadoop.version>3.4.0</hadoop.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs-client</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.1.0</version>
                <configuration>
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
</project>
```

```sh
mvn clean package -DskipTests
unzip -p target/test-assembly-with-spi-jar-with-dependencies.jar META-INF/services/org.apache.hadoop.fs.FileSystem
```

And you can see only one service config file provided by `hadoop-common` is reserved, the same file provided by `hadoop-hdfs-client` is missed.

```
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

org.apache.hadoop.fs.LocalFileSystem
org.apache.hadoop.fs.viewfs.ViewFileSystem
org.apache.hadoop.fs.HarFileSystem
org.apache.hadoop.fs.http.HttpFileSystem
org.apache.hadoop.fs.http.HttpsFileSystem
```

## 1.2 maven-shade-plugin

[Apache Maven Shade Plugin](https://maven.apache.org/plugins/maven-shade-plugin/index.html)

* [Resource Transformers](https://maven.apache.org/plugins/maven-shade-plugin/examples/resource-transformers.html)
    * ResourceBundleAppendingTransformer
    * ServicesResourceTransformer

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.2.0</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <finalName>${project.build.finalName}-jar-with-dependencies</finalName>
                <transformers>
                    <transformer
                            implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>xxx.yyy.zzz</mainClass>
                    </transformer>

                    <!-- Work with SPI -->
                    <transformer
                            implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
                </transformers>
                <filters>
                    <filter>
                        <artifact>*:*</artifact>
                        <excludes>
                            <!-- Avoid following issues: -->
                            <!-- Exception in thread "main" java.lang.SecurityException: Invalid signature file digest for Manifest main attributes -->
                            <exclude>META-INF/*.SF</exclude>
                            <exclude>META-INF/*.DSA</exclude>
                            <exclude>META-INF/*.RSA</exclude>
                        </excludes>
                    </filter>
                </filters>
            </configuration>
        </execution>
    </executions>
</plugin>
```

**Here's an example of how it works with SPI:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>org.byconity</groupId>
    <artifactId>test-shade-with-spi</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <hadoop.version>3.4.0</hadoop.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs-client</artifactId>
            <version>${hadoop.version}</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
                <version>3.2.0</version>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>shade</goal>
                        </goals>
                        <configuration>
                            <finalName>${project.build.finalName}-jar-with-dependencies</finalName>
                            <transformers>
                                <!-- Work with SPI -->
                                <transformer
                                        implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
                            </transformers>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

```sh
mvn clean package -DskipTests
unzip -p target/test-shade-with-spi-jar-with-dependencies.jar META-INF/services/org.apache.hadoop.fs.FileSystem
```

And you can see the different service config files, provided by `hadoop-common` and `hadoop-hdfs-client`, are combined together.

```
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

org.apache.hadoop.fs.LocalFileSystem
org.apache.hadoop.fs.viewfs.ViewFileSystem
org.apache.hadoop.fs.HarFileSystem
org.apache.hadoop.fs.http.HttpFileSystem
org.apache.hadoop.fs.http.HttpsFileSystem
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

org.apache.hadoop.hdfs.DistributedFileSystem
org.apache.hadoop.hdfs.web.WebHdfsFileSystem
org.apache.hadoop.hdfs.web.SWebHdfsFileSystem
```

## 1.3 spring-boot-maven-plugin

The actual main class is `JarLauncher` or `WarLauncher`, which will prepare the classloader that can understand these nested fat-jar's structure. And these information is stored in the `META-INF/MANIFEST.MF`

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

# 2 autoconfig

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

## 2.1 Demo

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

# 3 Format Plugin

## 3.1 formatter-maven-plugin

[Introduction](https://code.revelc.net/formatter-maven-plugin/)

* [Eclipse Version Compatibility](https://code.revelc.net/formatter-maven-plugin/eclipse-versions.html)

**Goals:**

* `validate`
    * `mvn formatter:validate`
* `format`
    * `mvn formatter:format`

```xml
<plugin>
    <groupId>net.revelc.code.formatter</groupId>
    <artifactId>formatter-maven-plugin</artifactId>
    <!-- version 2.11.0 is compatable with java 8 -->
    <version>2.11.0</version>
    <configuration>
        <configFile>../eclipse-java-google-style.xml</configFile>
        <encoding>UTF-8</encoding>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>validate</goal>
            </goals>
            <phase>compile</phase>
        </execution>
    </executions>    
</plugin>
```

## 3.2 Format Config

* [AOSP external/google-styleguide/eclipse-java-google-style.xml](https://cs.android.com/android/platform/superproject/main/+/main:external/google-styleguide/eclipse-java-google-style.xml?hl=zh-cn)
    * Search for `java-google-style.xml`

**Eclipse Config Keys:**

* `org.eclipse.jdt.core.formatter.tabulation.size`

# 4 Test

## 4.1 maven-surefire-plugin

Maven本身并不是一个单元测试框架，Java世界中主流的单元测试框架为Junit和TestNG。**Maven所做的只是在构建执行到特定生命周期阶段的时候，通过插件来执行Junit或者TestNG的测试用例，这一插件就是`maven-surefire-plugin`**

By default, the `maven-surefire-plugin`'s test goal automatically executes all test classes in the test source directory that match a set of naming patterns

1. `**/Test*.java`
1. `**/*Test.java`
1. `**/*TestCase.java`

### 4.1.1 Skip Test

* `mvn package -DskipTests`: Compile test project but don't run tests.
* `mvn package -Dmaven.test.skip=true`: Skip both compilation and execution.

### 4.1.2 Run Specific Tests

* `mvn test -Dtest=SampleTest`
* `mvn test -Dtest=SampleTest#case1`
* `mvn test -Dtest=*Test`
* `mvn test -Dtest=SampleTest1,SampleTest2`
* `mvn test -Dtest=*Test,SampleTest1,SampleTest2`

### 4.1.3 Exclude Tests

* When using the `<includes>` element, the default matching rules will be disabled.
* When using the `<excludes>` element, the default matching rules will not be disabled.

```xml
<project>
    ...
    <build>
        ...
        <plugins>
            ...
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.5</version>
                <configuration>
                    <includes>
                        <include>**/*Tests.java</include>
                    </includes>
                    <excludes>
                        <exclude>**/*ServiceTest.java</exclude>
                        <exclude>**/TempDaoTest.java</exclude>
                    </excludes>
                </configuration>
            </plugin>
            ...
        </plugins>
        ...
    </build>
    ...
</project>
```

# 5 Reference

* [Difference between the maven-assembly-plugin, maven-jar-plugin and maven-shade-plugin?](https://stackoverflow.com/questions/38548271/difference-between-the-maven-assembly-plugin-maven-jar-plugin-and-maven-shade-p)
* [hadoop No FileSystem for scheme: file](https://stackoverflow.com/questions/17265002/hadoop-no-filesystem-for-scheme-file)
