---
title: Maven-属性
date: 2017-11-27 14:32:21
tags: 
- 摘录
categories: 
- Java
- Maven
---

__目录__

<!-- toc -->
<!--more-->

# 1 内置属性

主要有两个常用的内置属性

1. `${basedir}`：表示项目根目录，即包含pom.xml文件的目录
1. `${version}`：表示项目版本

# 2 POM属性

用户可以使用该类属性引用POM文件中对应元素的值。例如`${project.artifactId}`就对应了`<project><artifactId>`元素的值，常用的POM属性包括：

1. `${project.build.sourceDirectory}`：项目的主源码目录，默认为src/main/java/
1. `${project.build.testSourceDirectory}`：项目的测试源码目录，默认为/src/test/java/
1. `${project.build.directory}`：项目构建输出目录，默认为target/
1. `${project.outputDirectory}`：项目主代码编译输出目录，默认为target/classes/
1. `${project.testOutputDirectory}`：项目测试代码编译输出目录，默认为target/test-classes/
1. `${project.groupId}`：项目的groupId
1. `${project.artifactId}`：项目的artifactId
1. `${project.version}`：项目的version，与${version}等价
1. `${project.build.finalName}`：项目打包输出文件的名称，默认为${project.artifactId}-${project.version}

这些属性都对应了一个POM元素，它们中一些属性的默认值都是在超级POM中定义的

# 3 自定义属性

用户可以在POM的<properties>元素下自定义Maven属性，例如
```xml
<project>
    ...
    <properties>
        <my.prop>hello</my.prop>
    </properties>
    ...
</project>
```

然后在POM中其他地方使用${my.prop}

# 4 Setting属性

与POM属性同理，用户使用以`settings.`开头的属性引用settings.xml文件中的XML元素的值，例如常用的${settings.localRepository}指向用户本地仓库的地址

# 5 Java系统属性

所有Java系统属性都可以使用Maven属性引用，例如${user.home}指向了用户目录。用户可以使用`mvn help:system`查看所有Java系统属性

# 6 环境变量属性

所有环境变量都可以使用以`env.`开头的Maven属性引用。例如${env.JAVA_HOME}指代了JAVA_HOME环境变量的值。用户可以使用`mvn help:system`查看所有环境变量

# 7 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《Maven实战》
