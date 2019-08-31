---
title: Maven-Release
date: 2019-05-20 16:37:09
tags: 
- 摘录
categories: 
- Java
- Maven
---

__阅读更多__

<!--more-->

# 1 Overview

本篇博文介绍如何将自己的项目发布到Maven中央仓库

__大致步骤如下:__

1. 注册`Sonatype Jira`帐户
1. 为新项目托管创建`Jira issue`
1. 安装`gpg`加密工具
1. 使用`gpg`生成密钥对
1. 上传密钥
1. 编写项目的`pom.xml`文件
1. 修改maven的`settings.xml`文件
1. 发布项目

# 2 注册`Sonatype Jira`帐户

[点击注册 Sonatype Jira](https://issues.sonatype.org/secure/Signup!default.jspa)

__分别填写__

1. `Email`: 邮箱
1. `Full name`: 不知道什么用
1. `Username`: 这是用于登陆的账号
1. `Password`: 登陆密码

__记录一下账号__

1. Full Name: Chenfeng He
1. username: liuyehcf
1. mail: 1559500551@qq.com
1. password: !H+routine

# 3 为新项目托管创建`Jira issue`

[点击创建 Jira issue](https://issues.sonatype.org/secure/CreateIssue.jspa?issuetype=21&pid=10134)

__分别填写__

1. `概要`: 描述一下你的项目
1. `Group Id`: 非常重要，如果你已经有一个公司或者个人的域名了，可以将这个域名作为`Group Id`，如果随便填写了一个，那么后续工作人员会要求你修改成一个合法域名，或者可以免费使用`com.github.xxx`
1. `Project URL`: 项目url，例如`https://github.com/liuyehcf/compile-engine`
1. `SCM url`: 例如`https://github.com/liuyehcf/compile-engine.git`

[博主创建的issue](https://issues.sonatype.org/browse/OSSRH-48769)

# 4 安装`gpg`加密工具

装个工具，这里就不啰嗦了

# 5 使用`gpg`生成密钥对

`gpg --full-gen-key`创建秘钥对

```
gpg (GnuPG) 2.2.11; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

请选择您要使用的密钥种类：
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (仅用于签名)
   (4) RSA (仅用于签名)
您的选择？ 1
RSA 密钥长度应在 1024 位与 4096 位之间。
您想要用多大的密钥尺寸？(2048)
您所要求的密钥尺寸是 2048 位
请设定这把密钥的有效期限。
         0 = 密钥永不过期
      <n>  = 密钥在 n 天后过期
      <n>w = 密钥在 n 周后过期
      <n>m = 密钥在 n 月后过期
      <n>y = 密钥在 n 年后过期
密钥的有效期限是？(0)
密钥永远不会过期
以上正确吗？(y/n)y

You need a user ID to identify your key; the software constructs the user ID
from the Real Name, Comment and Email Address in this form:
    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

真实姓名：Chenfeng He
电子邮件地址：1559500551@qq.com
注释：xxx
您选定了这个用户标识：
    “Chenfeng He (xxx) <1559500551@qq.com>”

更改姓名(N)、注释(C)、电子邮件地址(E)或确定(O)/退出(Q)？O
我们需要生成大量的随机字节。这个时候您可以多做些琐事(像是敲打键盘、移动
鼠标、读写硬盘之类的)，这会让随机数字发生器有更好的机会获得足够的熵数。
我们需要生成大量的随机字节。这个时候您可以多做些琐事(像是敲打键盘、移动
鼠标、读写硬盘之类的)，这会让随机数字发生器有更好的机会获得足够的熵数。
gpg: 密钥 80251AB9CBDE37E2 被标记为绝对信任
gpg: revocation certificate stored as '/Users/hechenfeng/.gnupg/openpgp-revocs.d/6592F29ED898696AD57C3F9180251AB9CBDE37E2.rev'
公钥和私钥已经生成并经签名。

pub   rsa2048 2019-06-01 [SC]
      6592F29ED898696AD57C3F9180251AB9CBDE37E2
uid                      Chenfeng He (xxx) <1559500551@qq.com>
sub   rsa2048 2019-06-01 [E]
```

在交互过程中，会让你输入一个密码，记住这个密码，待会配置`settings.xml`需要用到

# 6 上传密钥

设置好加密密钥后，需要发布到`OSSRH`服务器上，因为，你会使用这个密钥加密你的jar包，当你上传你的jar包到`OSSRH`服务器时，它就会用它来解密

可以用`gpg --list-key`查看刚才创建的密钥

使用命令`gpg --keyserver hkp://pool.sks-keyservers.net --send-keys 6592F29ED898696AD57C3F9180251AB9CBDE37E2`上传秘钥

上传公钥时，提示`no route to host`，可以用ip替换域名（ping一下这个域名得到ip）

`gpg --keyserver 216.66.15.2 --send-keys 6592F29ED898696AD57C3F9180251AB9CBDE37E2`

# 7 编写项目的`pom.xml`文件

`OSSRH`接受的项目的POM文件需要包含如下内容

1. `<modelVersion/>`
1. `<groupId/>`
1. `<artifactId/>`
1. `<version/>`
1. `<packaging/>`
1. `<name/>`
1. `<description/>`
1. `<url/>`
1. `<licenses/>`
1. `<developers/>`
1. `<scm/>`

此外，发布过程还会依赖一些插件，包括

1. `maven-release-plugin`
1. `maven-source-plugin`
1. `maven-surefire-plugin`
1. `maven-scm-plugin`
1. `nexus-staging-maven-plugin`
1. `maven-gpg-plugin`
1. `maven-javadoc-plugin`
1. `maven-deploy-plugin`

__下面是博主编译引擎项目的`pom`文件示例__

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.github.liuyehcf</groupId>
    <artifactId>compile-engine</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    <name>compile-engine</name>
    <description>compile engine</description>
    <url>https://github.com/liuyehcf/liuyehcf-framework</url>

    <licenses>
        <license>
            <name>The Apache Software License, Version 2.0</name>
            <url>http://www.apache.org/licenses/LICENSE-2.0.txt</url>
            <distribution>repo</distribution>
        </license>
    </licenses>

    <scm>
        <connection>scm:git:git@github.com:liuyehcf/liuyehcf-framework.git</connection>
        <developerConnection>scm:git:git@github.com:liuyehcf/liuyehcf-framework.git</developerConnection>
        <url>git@github.com:liuyehcf/liuyehcf-framework.git</url>
        <tag>1.0.0</tag>
    </scm>

    <developers>
        <developer>
            <id>liuye</id>
            <name>Chenfeng He</name>
            <email>1559500551@qq.com</email>
        </developer>
    </developers>

    <distributionManagement>
        <snapshotRepository>
            <id>ossrh</id>
            <url>https://oss.sonatype.org/content/repositories/snapshots</url>
        </snapshotRepository>
    </distributionManagement>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <finalName>compile-engine</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-release-plugin</artifactId>
                <version>2.5.3</version>
                <configuration>
                    <mavenExecutorId>forked-path</mavenExecutorId>
                    <useReleaseProfile>false</useReleaseProfile>
                    <arguments>-Psonatype-oss-release</arguments>
                    <pushChanges>false</pushChanges>
                    <localCheckout>false</localCheckout>
                    <autoVersionSubmodules>true</autoVersionSubmodules>
                    <checkModificationExcludes>
                        <checkModificationExclude>.idea/</checkModificationExclude>
                        <checkModificationExclude>.idea/*</checkModificationExclude>
                        <checkModificationExclude>.idea/libraries/*</checkModificationExclude>
                        <checkModificationExclude>pom.xml</checkModificationExclude>
                    </checkModificationExcludes>
                </configuration>
                <dependencies>
                    <dependency>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-scm-plugin</artifactId>
                        <version>1.8.1</version>
                    </dependency>
                </dependencies>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-scm-plugin</artifactId>
                <version>1.8.1</version>
            </plugin>
            <plugin>
                <groupId>org.sonatype.plugins</groupId>
                <artifactId>nexus-staging-maven-plugin</artifactId>
                <version>1.6.7</version>
                <extensions>true</extensions>
                <configuration>
                    <serverId>ossrh</serverId>
                    <nexusUrl>https://oss.sonatype.org/</nexusUrl>
                    <autoReleaseAfterClose>true</autoReleaseAfterClose>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-gpg-plugin</artifactId>
                <executions>
                    <execution>
                        <id>sign-artifacts</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>sign</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <version>2.1.2</version>
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
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-javadoc-plugin</artifactId>
                <version>2.9.1</version>
                <configuration>
                    <aggregate>true</aggregate>
                    <charset>UTF-8</charset>
                    <encoding>UTF-8</encoding>
                    <docencoding>UTF-8</docencoding>
                    <additionalparam>-Xdoclint:none</additionalparam>
                </configuration>
                <executions>
                    <execution>
                        <id>attach-javadocs</id>
                        <goals>
                            <goal>jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <artifactId>maven-deploy-plugin</artifactId>
                <version>2.8.2</version>
                <executions>
                    <execution>
                        <id>default-deploy</id>
                        <phase>deploy</phase>
                        <goals>
                            <goal>deploy</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

    <profiles>
        <profile>
            <id>sonatype-oss-release</id>
            <build>
                <plugins>
                    <plugin>
                        <groupId>org.apache.maven.plugins</groupId>
                        <artifactId>maven-source-plugin</artifactId>
                        <version>2.1.2</version>
                        <executions>
                            <execution>
                                <id>attach-sources</id>
                                <goals>
                                    <goal>jar-no-fork</goal>
                                </goals>
                            </execution>
                        </executions>
                    </plugin>
                </plugins>
            </build>
        </profile>
    </profiles>
</project>
```

# 8 修改maven的`settings.xml`文件

`settings.xml`需要配置如下内容

1. 配置`Sonatype Jira`账户信息
1. `gpg`密码配置

下面是博主的`settings.xml`文件示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <pluginGroups>
  </pluginGroups>

  <proxies>
  </proxies>

  <servers>
      <server>
        <id>ossrh</id>
        <username>liuyehcf</username>
        <password>Sonatype Jira账号密码</password>
      </server>
  </servers>

  <mirrors>
  </mirrors>

  <profiles>
    <profile>
      <id>ossrh</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <properties>
        <gpg.executable>gpg</gpg.executable>
        <gpg.passphrase>创建gpg秘钥的时候配置的密码</gpg.passphrase>
      </properties>
    </profile>
  </profiles>

</settings>
```

# 9 发布项目

执行`mvn clean deploy`，大概1-2天，在maven中央仓库就可以看到你的项目了

__注意，在执行过程中，可能会遇到如下问题__

* gpg: signing failed: Inappropriate ioctl for device
* 原因是 gpg 在当前终端无法弹出密码输入页面。
* 解决办法很简单：`export GPG_TTY=$(tty)`，然后再执行`mvn clean deploy`，就能弹出一个密码输入界面了

# 10 参考

* [sonatype仓库-查看已deploy的项目的进度](https://oss.sonatype.org/index.html#welcome)
* [如何将自己的开源项目发布到Maven中央仓库中](https://www.jdon.com/idea/publish-to-center-maven.html)
* [将你自己的项目发布到maven中央仓库](https://www.jianshu.com/p/8c3d7fb09bce)
* [发布项目到Maven中央仓库的最佳实践](https://www.jianshu.com/p/5f6135e1925f)
* [OSSRH Guide](https://central.sonatype.org/pages/ossrh-guide.html)
* [发布部署](https://central.sonatype.org/pages/releasing-the-deployment.html)
* [repo](https://repo.maven.apache.org/maven2/)
* [maven repo](https://search.maven.org/)
* [将项目发布到Maven Central仓库](https://www.liangshuang.name/2017/08/15/upload-to-maven-central/)
* [gpg: signing failed: Inappropriate ioctl for device](https://www.jianshu.com/p/2ed292ae2365)

