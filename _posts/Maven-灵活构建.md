---
title: Maven-灵活构建
date: 2017-11-27 14:52:21
tags: 
- 摘录
categories: 
- Java
- 包管理器
---

__目录__

<!-- toc -->
<!--more-->

# 1 构建环境的差异

在不同的环境中，项目的源码应该使用不同的方式进行构建，最常见的就是数据库配置。这些配置在开发环境、测试环境以及生产环境中大概率是不同的

当然我们可以手动更改配置，但__手动意味着低效和错误__

因此，需要找到一种方法，能够自动地应对构建环境的差异

# 2 资源过滤

为了应对变化，首先需要使用Maven属性将这些将会发生变化的部分提取出来

以数据库配置为例，我们在POM文件中，用一个额外的`<profile>`元素将其包裹起来

```xml
<project>
    ...
    <profiles>
        <profile>
            <id>dev</id>
            <properties>
                <db.driver>com.mysql.jdbc.Driver</db.driver>
                <db.url>jdbc:mysql:// 192.168.1.100:3306/test</db.url>
                <db.username>user_dev</db.username>
                <db.password>12345678</db.password>
            </properties>
        </profile>
    </profiles>
    ...
</project>
```

在`<profile>`元素中定义的Maven属性与直接在POM的`<properties>`元素下定义并无二致，只是这里使用了一个id为dev的profile，其目的是将开发环境的配置与其他环境区分开来。

需要注意的是，__Maven属性默认只有在POM中才会被解析__，也就是说`${db.username}`放到POM中会变成user_dev，但是如果放到/src/main/resources/目录下的文件中，构建的时候它将仍然还是`${db.username}`。__因此，需要让Maven解析资源文件中的Maven属性__

资源文件的处理是`maven-resources-plugin`插件做的事情，__它默认的行为只是将项目主资源文件复制到主代码编译输出目录中，将测试资源文件复制到测试代码编译输出目录中__。不过，只要通过一些简单的设置，该插件就能解析资源文件中的Maven属性，__即开启资源过滤__

Maven默认的主资源目录和测试资源目录的定义是在超级POM中。要为资源目录__开启资源过滤__，只要添加`<filtering>`配置即可

```xml
<project>
    ...
    <build>
        ...
        <resources>
            <resource>
                <filtering>true</filtering>
                <directory>${project.basedir}/src/main/resources</directory>
            </resource>
        </resources>

        <testResources>
            <testResource>
                <filtering>true</filtering>
                <directory>${project.basedir}/src/test/resources</directory>
            </testResource>
        </testResources>
        ...
    </build>
    ...
</project>
```

此外，主资源目录和测试资源目录都可以超过一个，虽然会破坏Maven的约定，但Maven允许用户声明多个资源目录，并为每个资源目录提供不同的过滤配置

# 3 Maven Profile

为了能让构建在各个环境下方便地移植，Maven引入了profile的概念。profile能够在构建的时候修改POM的一个子集，或者添加额外的配置元素。用户可以使用很多方式激活profile，以实现构建在不同环境下的移植

## 3.1 激活Profile

为了尽可能方便用户，Maven支持很多种激活Profile的方式

1. __命令行激活__
1. __settings文件显式激活__
1. __系统属性激活__
1. __操作系统环境激活__
1. __文件存在与否激活__
1. __默认激活__

### 3.1.1 命令行激活

用户可以使用mvn命令行参数`-P`加上profile的id来激活profile，多个id之间以逗号分隔，例如：

* `$mvn clean install -Pdev,test`

### 3.1.2 settings文件显式激活

用户希望某个profile默认一直处于激活状态，就可以配置settings.xml文件的`<activeProfiles>`元素，表示其配置的profile对于所有项目都处于激活状态

```xml
<settings>
    ...
    <activeProfiles>
        <activeProfile>dev</activeProfile>
    </activeProfiles>
    ...
</settings>
```

### 3.1.3 系统属性激活

用户可以配置当某系统属性存在的时候，自动激活profile

```xml
<project>
    ...
    <profiles>
        <profile>
            ...
            <activation>
                <property>
                    <name>test</name>
                </property>
            </activation>
            ...
        </profile>
    </profiles>
    ...
</project>
```

可以进一步配置，当系统属性test存在，且值等于x的时候激活profile

```xml
<project>
    ...
    <profiles>
        <profile>
            ...
            <activation>
                <property>
                    <name>test</name>
                    <value>x</value>
                </property>
            </activation>
            ...
        </profile>
    </profiles>
    ...
</project>
```

用户可以在命令行中声明系统属性，例如

* `$mvn clean install -Dtest=x`（好像有问题）

### 3.1.4 操作系统环境激活

Profile还可以自动根据操作系统环境激活，如果构建在不同的操作系统有差异，用户完全可以将这些差异写进profile，然后配置它们自动基于操作系统环境激活

```xml
<project>
    ...
    <profiles>
        <profile>
            ...
            <activation>
                <os>
                    <name>Windows XP</name>
                    <family>Windows</family>
                    <arch>x86</arch>
                    <version>5.1.2600</version>
                </os>
            </activation>
            ...
        </profile>
    </profiles>
    ...
</project>
```

### 3.1.5 文件存在与否激活

Maven能够根据项目中某个文件存在与否来决定是否激活profile

```xml
<project>
    ...
    <profiles>
        <profile>
            ...
            <activation>
                <file>
                    <missing>x.properties</missing>
                    <exists>y.properties</exists>
                </file>
            </activation>
            ...
        </profile>
    </profiles>
    ...
</project>
```

### 3.1.6 默认激活

用户可以在定义profile的时候指定默认激活

```xml
<project>
    ...
    <profiles>
        <profile>
            ...
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
            ...
        </profile>
    </profiles>
    ...
</project>
```

需要注意的是，__如果POM中任何一个profile通过以上其他任意一种方式被激活了，所有的默认激活配置都会失效。__

### 3.1.7 查看激活情况

如果项目中有很多的profile，它们的激活方式各异，`maven-help-plugin`提供了一个目标帮助用户了解当前激活的profile

* `$mvn help:active-profiles`

`maven-help-plugin`还有另外一个目标用来列出当前所有profile

* `$mvn help:all-profiles`

__此外，如果多个不同的profile对同一个Maven属性都进行了定义，且他们都被激活了，那么在POM文件中位于最后面位置的profile中定义的Maven属性将会在过滤中生效__

## 3.2 Profile的种类

根据具体的需要，可以在以下位置声明profile

1. `pom.xml`：很显然，pom.xml中声明的profile只对当前项目有效
1. `用户settings.xml`：用户目录下，`.m2/settings.xml`中的profile对本机上该用户所有的Maven项目有效
1. `全局settings.xml`：Maven安装目录下`conf/settings.xml`中的profile对本机上所有的Maven项目有效

不同类型的profile中可以声明的POM元素也是不同的，pom.xml中的profile能够随着pom.xml一起被提交到代码仓库中、被Maven安装到本地仓库中、被部署到远程Maven仓库中。换言之，可以保证该profile伴随着某个特定的pom.xml一起存在，因此它可以修改或增加很多POM元素，详见如下代码

```xml
<project>
    <repositories></repositories>
    <pluginRepositories></pluginRepositories>
    <distributionManagement></distributionManagement>
    <dependencies></dependencies>
    <dependencyManagement></dependencyManagement>
    <modules></modules>
    <properties></properties>
    <reporting></reporting>
    <build>
        <plugins></plugins>
        <defaultGoal></defaultGoal>
        <resources></resources>
        <testResources></testResources>
        <finalName></finalName>
    </build>
</project>
```

对于其余两种profile，由于无法保证它们能够随着特定的pom.xml一起被分发，因此Maven不允许它们添加或者修改绝大部分的POM元素，只允许修改以下几种元素

```xml
<project>
    <repositories></repositories>
    <pluginRepositories></pluginRepositories>
    <properties></properties>
</project>
```

# 4 Web资源过滤

# 5 在profile中激活集成测试

# 6 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* 《Maven实战》
