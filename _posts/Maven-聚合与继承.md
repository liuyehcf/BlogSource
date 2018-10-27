---
title: Maven-聚合与继承
date: 2017-11-27 08:29:34
tags: 
- 摘录
categories: 
- Java
- Maven
---

__阅读更多__

<!--more-->

# 1 聚合

有时候，我们想要一次构建多个项目，而不是到这些模块的目录下分别执行mvn命令。Maven聚合（或者称多模块）这一特性就是为该需求服务的

__对于聚合项目，其POM文件的`<packaging>`元素必须是pom__，否则无法构建

一个聚合项目，其POM文件包含如下几个重要元素，详见下方示意代码

1. `<packaging>`：打包方式，必须为pom
1. `<name>`：提供一个更易阅读的名字，会在构建时显示
1. `<modules>`：聚合项目的核心配置
    * 每个`<module>`元素的值都是一个当前POM的__相对目录__（很重要）

```xml
<project>
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>sample-aggregator</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>Sample Aggregator</name>

    <modules>
        <module>sample-module1</module>
        <module>sample-module2</module>
    </modules>
    ...
</project>
```

一般来说，为了方便快速定位内容，__模块所处目录的名称应当与其artifactId一致__。当然也可以不一样，只不过需要修改聚合POM文件中的`<module>`元素的值

此外，为了方便用户构建项目，通常将聚合模块放在项目目录的最顶层，其他模块则作为聚合模块的子目录存在。这样当用户得到源码的时候，第一眼发现的就是聚合模块的POM，不用从多个模块中去寻找聚合模块来构建整个项目

# 2 继承

在面向对象的世界中，程序员可以使用类继承在一定程度上消除重复，在Maven的世界中，也有类似的机制能让我们抽取出重复的配置，这就是POM的继承

对于一个父模块，其POM文件包含如下几个重要元素，详见下方示意代码

1. `<packaging>`：打包方式，__必须为pom，这一点与聚合模块一样__
1. `<name>`：提供一个更易阅读的名字，会在构建时显示

```xml
<project>
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>sample-parent</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>Sample Parent</name>
    ...
</project>
```

对于子模块，其POM文件包含如下几个重要元素，详见下方示意代码

1. `<parent>`：用于声明父模块
    * `<groupId>`、`<artifactId>`、`<version>`：父模块的坐标，必须指定
    * `<relativePath>`：当前POM的__相对目录__，用于定位父模块pom文件的目录
        * 在项目构建时，Maven会首先根据relativePath检查父POM，如果找不到，再从本地仓库找
        * __relativePath的默认值是：`../pom.xml`，也就是默认父POM在上一层目录下__

## 2.1 可继承的POM元素

1. `<groupId>`：项目组ID，项目坐标核心元素
1. `<version>`：项目组版本，项目坐标核心元素
1. `<description>`：项目的描述信息
1. `<organization>`：项目的组织信息
1. `<inceptionYear>`：项目的创始年份
1. `<url>`：项目的URL地址
1. `<developers>`：项目的开发者信息
1. `<contributors>`：项目的贡献者信息
1. `<distributionManagement>`：项目的部署配置
1. `<issueManagement>`：项目的缺陷跟踪系统信息
1. `<ciManagement>`：项目的持续集成系统信息
1. `<scm>`：项目的版本控制系统信息
1. `<mailingList>`：项目的邮件列表信息
1. `<properties>`：自定义的Maven属性
1. `<dependencies>`：项目的依赖配置
1. `<dependencyManagement>`：项目的依赖管理配置
1. `<repositories>`：项目的仓库配置
1. `<build>`：包括项目的源码目录配置、输出目录配置、插件配置、插件管理配置等
1. `<reporting>`：包括项目的报告输出目录配置、报告插件配置等

## 2.2 依赖管理

Maven提供的`<dependencyManagement>`元素既能让子模块继承到父模块的依赖配置，又能保证子模块依赖使用的灵活性

在父模块的POM文件中的`<dependencyManagement>`元素下的依赖声明__不会引入实际的依赖（父子模块都不会引入实际的依赖）__，不过它能够__约束__`<dependencies>`下的依赖使用

`<dependencyManagement>`元素是__可以被继承__的，但是__并不会引入实际的依赖__。因此在子模块的POM文件中，还是需要在`<dependencies>`元素中声明所需的依赖，但是只需要配置依赖的groupId以及artifactId即可，详见下方示意代码

__父POM文件__

```xml
<project>
    ...
    <properties>
        <springframework.version>4.1.6</springframework.version>
        <junit.version>4.12</junit.version>
    </properties>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-core</artifactId>
                <version>${springframework.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-beans</artifactId>
                <version>${springframework.version}</version>
            </dependency>
            <dependency>
                <groupId>org.springframework</groupId>
                <artifactId>spring-context</artifactId>
                <version>${springframework.version}</version>
            </dependency>

            <dependency>
                <groupId>junit</groupId>
                <artifactId>junit</artifactId>
                <version>${junit.version}</version>
                <scope>test</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    ...
</project>
```

__子POM文件__

```xml
<project>
    ...
    <properties>
        <javax.mail.version>1.4.1</javax.mail.version>
        <greenmail.version>1.3.1b</greenmail.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
        </dependency>
            <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-beans</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
        </dependency>

        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
        </dependency>

        <dependency>
            <groupId>javax.mail</groupId>
            <artifactId>mail</artifactId>
            <version>${javax.mail.version}</version>
        </dependency>
        <dependency>
            <groupId>com.icegreen</groupId>
            <artifactId>greenmail</artifactId>
            <version>${greenmail.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    ...
</project>
```

可以看到，子POM文件中的依赖配置较原来简单了一些，所有的springframework只配置了groupId和artifactId，省去了version；而junit不仅省去了version还省去了scope。这是因为__完整的依赖声明已经包含在父POM中__，子模块__只需要配置简单的groupId和artifactId就能获得对应的依赖信息__，从而引入正确的依赖

这种依赖管理机制似乎不能减少太多的POM配置，__不过还是建议采用这种方法__，原因如下

* 父POM中使用`<dependencyManagement>`声明依赖能够__统一__项目范围中__依赖的版本__
* 当依赖版本在父POM中声明之后，子模块在使用依赖的时候就无需声明版本，也就不会发生多个子模块使用依赖版本不一致的情况，这可以帮助降低依赖冲突的概率

此外，{% post_link Maven-基本概念 %}中提到了名为import的依赖范围，该范围的依赖只在`<dependencyManagement>`元素下才有效果，使用该范围的依赖通常指向一个POM，作用是：将目标POM中的`<dependencyManagement>`配置导入并合并到当前POM的`<dependencyManagement>`元素中

## 2.3 插件管理

类似的，Maven也提供了`<pluginManagement>`元素帮助管理插件，该元素中配置的依赖__不会造成实际的插件调用行为__。由于`<build>`元素可被继承，因此其子元素`<pluginManagement>`也可以被继承。在子POM文件中配置了真正的`<plugin>`元素，其groupId与artifactId与父POM文件中的`<pluginManagement>`元素中配置的插件匹配时，`<pluginManagement>`的配置才会起作用

同样的，__完整的插件声明已经包含在父POM中__，子模块__只需要配置简单的groupId和artifactId就能获得对应的插件信息__，从而引入正确的插件

__父POM文件__

```xml
<project>
    ...
    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-source-plugin</artifactId>
                    <version>2.1.1</version>
                    <executions>
                        <execution>
                            <id>attach-sources</id>
                            <phase>verify</phase>
                            <goals>
                                <goal>jar-no-fork</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
    ...
</project>
```

__子POM文件__

```xml
<project>
    ...
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
    ...
</project>
```

# 3 聚合与继承的关系

__聚合__主要是为了__方便快速构建项目__，而__继承__主要是为了__消除重复配置__。__聚合和继承是两个正交的概念__

对于聚合模块来说，它知道有哪些被聚合的模块，但那些被聚合的模块不知道这个聚合模块的存在

对于继承关系的父POM来说，它不知道有哪些子模块继承于它，但那些子模块都必须知道自己的父POM是什么

聚合和继承唯一的共性是其`<packaging>`元素的值都是pom

在现有的项目中，往往将聚合与继承合二为一，即一个POM既是聚合POM又是父POM，这么做主要是为了方便

# 4 约定优于配置

Maven会假设用户的项目是这样的：

1. 源码目录为：`src/main/java/`
1. 编译输出目录为：`target/classes/`
1. 打包方式为：`jar`
1. 包输出目录为：`target/`

遵循约定虽然损失了一定的灵活性，用户不能随意安排目录结构，但是却能减少配置。更重要的是，遵循约定能够帮助用户遵守构建标准

没有约定，意味着10个项目可能使用10种不同的项目目录结构，这意味着交流学习成本的增加，而这种增加的成本往往就是浪费

任何一个Maven项目都隐式地继承自`超级POM`（`$MAVEN_HOME/lib/maven-model-builder-x.x.jar`中的`org/apache/maven/model/pom-4.0.0.xml`），这有点类似于任何一个Java类都隐式地继承于Object类。__因此大量超级POM的配置都会被所有Maven项目继承，这些配置也就成了Maven所提倡的约定__

# 5 反应堆

在一个多模块的Maven项目中，反应堆（Reactor）是指所有模块组成的一个构建结构

* 对于单模块项目，反应堆就是该模块本身
* 对于多模块项目，反应堆就包含了各模块之间继承与依赖的关系，从而能够自动计算出合理的模块构建顺序

实际的构建顺序是这样的：Maven按序读取POM，如果该POM没有依赖模块，那么就构建该模块，否则就先构建其依赖模块，如果该依赖还依赖于其他模块，则进一步先构建依赖的依赖

模块间的依赖关系会将反应堆构成一个有向非循环图（有向无环图的遍历，BFS与DFS均可实现），若出现了环状依赖，那么Maven在构建时会报错

## 5.1 裁剪反应堆

Maven提供很多命令行选项支持裁剪反应堆，输入`$mvn -h`可以看到以下选项

* `-am,--also-make`：同时构建所列出的依赖模块
* `-amd,--also-make-dependents`：同时构建依赖于所列模块的模块
* `-pl,--projects <arg>`：构建指定模块，模块间用逗号分隔
* `-rf,--resume-from <arg>`：从指定的模块回复反应堆

# 6 参考

* 《Maven实战》
