---
title: Maven-实用附录表
date: 2017-11-28 12:53:46
tags: 
- 摘录
categories: 
- Java
- Maven
---

__目录__

<!-- toc -->
<!--more-->

# 1 POM元素表

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 30px;
}
</style>

| 元素名称 | 简介 |
|:--|:--|
| `<project>` | POM的XML根元素 |
| `<project> <parent>` | 声明继承 |
| `<project> <modules> <module>` | 声明聚合 |
| `<project> <groupId>` | 坐标元素之一 |
| `<project> <artifactId>` | 坐标元素之一 |
| `<project> <version>` | 坐标元素之一 |
| `<project> <packaging>` | 坐标元素之一，默认jar |
| `<project> <name>` | 名称 |
| `<project> <description>` | 描述 |
| `<project> <organization>` | 所属组织 |
| `<project> <licenses> <license>` | 许可证 |
| `<project> <mailingLists> <mailingList>` | 邮件列表 |
| `<project> <developers> <developer>` | 开发者 |
| `<project> <contributors> <contributor>` | 贡献者 |
| `<project> <issueManagement>` | 问题追踪系统 |
| `<project> <ciManagement>` | 持续集成系统 |
| `<project> <scm>` | 版本控制系统 |
| `<project> <prerequisites> <maven>` | 要求Maven最低版本，默认2.0 |
| `<project> <build> <sourceDirectory>` | 主源码目录 |
| `<project> <build> <scriptSourceDirectory>` | 脚本源码目录 |
| `<project> <build> <testSourceDirectory>` | 测试源码目录 |
| `<project> <build> <outputDirectory>` | 主源码输出目录 |
| `<project> <build> <testOutputDirectory>` | 测试源码输出目录 |
| `<project> <build> <resources> <resource>` | 主资源目录 |
| `<project> <build> <testResources> <testResource>` | 测试资源目录 |
| `<project> <build> <finalName>` | 输出主构件名称 |
| `<project> <build> <directory>` | 输出目录 |
| `<project> <build> <filters> <filter>` | 通过properties文件定义资源过滤属性 |
| `<project> <build> <extensions> <extension>` | 扩展Maven的核心 |
| `<project> <build> <pluginManagement>` | 插件管理 |
| `<project> <build> <plugins> <plugin>` | 插件 |
| `<project> <profiles> <profile>` | POM Profile |
| `<project> <distributionManagement> <repository>` | 发布版本部署仓库 |
| `<project> <distributionManagement> <snapshotRepository>` | 快照版本部署仓库 |
| `<project> <distributionManagement> <site>` | 站点部署 |
| `<project> <repositories> <repository>` | 仓库 |
| `<project> <pluginRepositories> <pluginRepository>` | 插件仓库 |
| `<project> <dependencies> <dependency>` | 依赖 |
| `<project> <dependencyManagement>` | 依赖管理 |
| `<project> <properties>` | Maven自定义属性 |
| `<project> <reporting> <plugins>` | 报告插件 |

# 2 Settings元素表

| 元素名称 | 简介 |
|:--|:--|
| `<settings>` | settings.xml文档的根元素 |
| `<settings> <localRepository>` | 本地仓库 |
| `<settings> <interactiveMode>` | Maven是否与用户交互，默认值true |
| `<settings> <offline>` | 离线模式，默认值false |
| `<settings> <pluginGroups> <pluginGroup>` | 插件组 |
| `<settings> <servers> <server>` | 下载与部署仓库的认证信息 |
| `<settings> <mirrors> <mirror>` | 仓库镜像 |
| `<settings> <proxies> <proxy>` | 代理 |
| `<settings> <profiles> <profile>` | Settings Profile |
| `<settings> <activeProfiles> <activeProfile>` | 激活Profile |

# 3 常用插件表

<style>
table th:nth-of-type(1) {
    width: 70px;
}
table th:nth-of-type(2) {
    width: 70px;
}
table th:nth-of-type(3) {
    width: 20px;
}
</style>

| 插件名称 | 用途 | 来源 |
|:--|:--|:--|
| maven-help-plugin | 获取项目及Maven环境的信息 | Apache |
| maven-archetype-plugin | 基于Archetype生成项目骨架 | Apache |
| maven-clean-plugin | 清理项目 | Apache |
| maven-compiler-plugin | 编译项目 | Apache |
| maven-deploy-plugin | 部署项目 | Apache |
| maven-install-plugin | 安装项目 | Apache |
| maven-dependency-plugin | 依赖分析及控制 | Apache |
| maven-resources-plugin | 处理资源文件 | Apache |
| maven-site-plugin | 生成站点 | Apache |
| maven-surefire-plugin | 执行测试 | Apache |
| maven-jar-plugin | 构建JAR项目 | Apache |
| maven-war-plugin | 构件WAR项目 | Apache |
| maven-source-plugin | 生成源码包 | Apache |
| maven-shade-plugin | 构件包含依赖的JAR包 | Apache |
| maven-assembly-plugin | 构建自定义格式的分发包 | Apache |
| maven-changelog-plugin | 生成版本控制变更报告 | Apache |
| maven-checkstyle-plugin | 生成CheckStyle报告 | Apache |
| maven-javadoc-plugin | 生成JavaDoc文档 | Apache |
| maven-jxr-plugin | 生成源码交叉引用文档 | Apache |
| maven-pmd-plugin | 生成PMD报告 | Apache |
| maven-project-info-reports-plugin | 生成项目信息报告 | Apache |
| maven-surefire-report-plugin | 生成单元测试报告 | Apache |
| maven-antrun-plugin | 调用Ant任务 | Apache |
| maven-enforcer-plugin | 定义规则并强制要求项目遵循 | Apache |
| maven-pgp-plugin | 为项目构件生成PGP签名 | Apache |
| maven-invoker-plugin | 自动运行Maven项目构建并验证 | Apache |
| maven-release-plugin | 自动化项目版本发布 | Apache |
| maven-scm-plugin | 集成版本控制系统 | Apache |
| maven-eclipse-plugin | 生成Eclipse项目环境配置 | Apache |
| build-helper-maven-plugin | 包含各种支持构建生命周期的目标 | Codehaus |
| exec-maven-plugin | 运行系统程序或者Java程序 | Codehaus |
| jboss-maven-plugin | 启动、停止Jobss，部署项目 | Codehaus |
| properties-maven-plugin | 从properties文件读写Maven属性  | Codehaus |
| sql-maven-plugin | 运行SQL脚本 | Codehaus |
| tomcat-maven-plugin | 启动、停止Tomcat、部署项目 | Codehaus |
| versions-maven-plugin | 自动化批量更新POM版本 | Codehaus |
| cargo-maven-plugin | 启动/停止/配置各类Web容器自动化部署Web项目 | Cargo |
| jetty-maven-plugin | 集成Jetty容器，实现快速开发测试 | Eclipse |
| maven-gae-plugin | 集成Google App Engine | Googlecode |
| maven-license-plugin | 自动化添加许可证证明至源码文件 | Googlecode |
| maven-android-plugin | 构建Android项目 | Googlecode |

# 4 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《Maven实战》
