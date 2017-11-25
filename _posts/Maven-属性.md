---
title: Maven-属性
date: 2017-11-25 21:47:40
tags: 
- 摘录
categories: 
- Java
- 包管理器
---

__目录__

<!-- toc -->
<!--more-->

# 1 内置属性

内置属性由Maven预定义，用户可以直接使用

1. `${basedir}`：表示项目根目录，即包含pom.xml文件的目录
1. `${version}`：表示项目版本
1. `${project.basedir}`：同${basedir}
1. `${project.baseUri}`：表示项目文件地址
1. `${maven.build.timestamp}`：表示项目构件开始时间
1. `${maven.build.timestamp.format}`：表示属性${maven.build.timestamp}的展示格式，默认值为yyyyMMdd-HHmm，可自定义其格式，其类型可参考java.text.SimpleDateFormat。用法如下：
    * 
```xml
<properties>
    <maven.build.timestamp.format>yyyy-MM-dd HH:mm:ss</maven.build.timestamp.format>
</properties>
```
 
# 2 POM属性

使用pom属性可以引用到pom.xml文件对应元素的值

1. `${project.build.directory}`：表示主源码路径
1. `${project.build.sourceEncoding}`：表示主源码的编码格式
1. `${project.build.sourceDirectory}`：表示主源码路径
1. `${project.build.finalName}`：表示输出文件名称
1. `${project.version}`：表示项目版本，与${version}相同
 
# 3 自定义属性

自定义属性是指：在pom.xml文件的`<properties>`标签下定义的Maven属性

```xml
<project>
    <properties>
        <my.pro>abc</my.pro>
    </properties>
</project>
```

在其他地方使用${my.pro}使用该属性值。
 
# 4 settings.xml文件属性

settings.xml文件属性与pom属性同理，用户使用以settings.开头的属性引用settings.xml文件中的XML元素值

1. `${settings.localRepository}`：表示本地仓库的地址
 
# 5 Java系统属性(所有的Java系统属性都可以使用Maven属性引用)

使用`mvn help:system`命令可查看所有的Java系统属性。另外，System.getProperties()也可得到所有的Java属性

1. `${user.home}`表示用户目录
1. 等等
 
# 6 环境变量属性(所有的环境变量都可以用以env.开头的Maven属性引用)

使用`mvn help:system`命令可查看所有环境变量

1. `${env.JAVA_HOME}`表示JAVA_HOME环境变量的值
1. 等等

# 7 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [Maven内置属性及使用](http://blog.csdn.net/wangjunjun2008/article/details/17761355)
