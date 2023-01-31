---
title: Maven-Customized-Plugin
date: 2017-11-27 17:32:21
tags: 
- 摘录
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 编写Maven插件的一般步骤

编写Maven插件的主要步骤如下：

1. **创建一个maven-plugin项目**：
    * 插件本身也是Maven项目，特殊的地方在于它的packaging必须是maven-plugin
    * 用户可以使用`maven-archetype-plugin`快速创建一个Maven插件项目
1. **为插件编写目标**：
    * 每个插件都必须包含一个或多个目标，Maven称之为Mojo（与Pojo对应，后者指Plain Old Java Object，这里指Maven Old Java Object）
    * 编写插件的时候必须提供一个或者多个继承自AbstractMojo的类
1. **为目标提供配置点**：
    * 大部分Maven插件其目标都是可配置的，因此在编写Mojo的时候需要注意提供可配置的参数
1. **编写代码实现目标行为**：
    * 根据实际需要实现Mojo
1. **错误处理及日志**：
    * 当Mojo发生异常时，根据情况控制Maven的运行状态。在代码中编写必要的日志以便为用户提供足够的信息
1. **测试插件**：
    * 编写自动化的测试代码测试行为，然后再实际运行插件以验证其行为

# 2 案例：编写一个用于代码行统计的Maven插件

## 2.1 创建一个Maven插件项目

使用`maven-archetype-plugin`快速创建一个Maven插件项目

* `$mvn archetype:generate`

看到以下输出

```
...
1078: remote -> org.apache.maven.archetypes:maven-archetype-plugin (An archetype which contains a sample Maven plugin.)
...
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): 1082: <在这里键入>
```

然后键入1078，即Maven插件项目（编号可能有变动，参考实际输出信息）

```
Choose a number: 3: <在这里键入>
```

键入`Enter`

```
Define value for property 'groupId': : <在这里键入>
```

键入groupId，我输入的是`org.liuyehcf`

```
Define value for property 'artifactId': : <在这里键入>
```

键入artifactId，我输入的是`maven-count-plugin`

```
Define value for property 'version':  1.0-SNAPSHOT: : <在这里键入>
```

键入`Enter`

```
Define value for property 'package':  org.liuyehcf: : <在这里键入>
```

键入`Enter`

```
 Y: : <在这里键入>
```

键入`Enter`

**生成了如下的Pom文件**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>org.liuyehcf</groupId>
  <artifactId>maven-count-plugin</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>maven-plugin</packaging>

  <name>maven-count-plugin Maven Plugin</name>

  <!-- FIXME change it to the project's website -->
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.apache.maven</groupId>
      <artifactId>maven-plugin-api</artifactId>
      <version>2.0</version>
    </dependency>
    <dependency>
      <groupId>org.apache.maven.plugin-tools</groupId>
      <artifactId>maven-plugin-annotations</artifactId>
      <version>3.2</version>
      <scope>provided</scope>
    </dependency>
    <dependency>
      <groupId>org.codehaus.plexus</groupId>
      <artifactId>plexus-utils</artifactId>
      <version>3.0.8</version>
    </dependency>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.8.2</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-plugin-plugin</artifactId>
        <version>3.2</version>
        <configuration>
          <goalPrefix>maven-count-plugin</goalPrefix>
          <skipErrorNoDescriptorsFound>true</skipErrorNoDescriptorsFound>
        </configuration>
        <executions>
          <execution>
            <id>mojo-descriptor</id>
            <goals>
              <goal>descriptor</goal>
            </goals>
          </execution>
          <execution>
            <id>help-goal</id>
            <goals>
              <goal>helpmojo</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
  <profiles>
    <profile>
      <id>run-its</id>
      <build>

        <plugins>
          <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-invoker-plugin</artifactId>
            <version>1.7</version>
            <configuration>
              <debug>true</debug>
              <cloneProjectsTo>${project.build.directory}/it</cloneProjectsTo>
              <pomIncludes>
                <pomInclude>*/pom.xml</pomInclude>
              </pomIncludes>
              <postBuildHookScript>verify</postBuildHookScript>
              <localRepositoryPath>${project.build.directory}/local-repo</localRepositoryPath>
              <settingsFile>src/it/settings.xml</settingsFile>
              <goals>
                <goal>clean</goal>
                <goal>test-compile</goal>
              </goals>
            </configuration>
            <executions>
              <execution>
                <id>integration-test</id>
                <goals>
                  <goal>install</goal>
                  <goal>integration-test</goal>
                  <goal>verify</goal>
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

Maven插件项目的POM有两个特殊的地方

1. 它的packaging必须为maven-plugin，这种特殊的打包类型能控制Maven为其在生命周期阶段绑定插件处理相关的目标，例如在compile阶段，Maven需要为插件项目构建一个特殊插件描述符文件
1. 包含了一个artifactId为maven-plugin-api的依赖，该依赖中包含了插件开发所必须的类，例如AbstractMojo

## 2.2 为插件编写目标

在上一步骤中，使用Archetype生成的插件项目包含了一个名为MyMojo的Java文件，将其删除，创建一个CountMojo，其代码如下

```java
package org.liuyehcf;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by HCF on 2017/11/25.
 */
@Mojo(name = "count", defaultPhase = LifecyclePhase.PROCESS_SOURCES)
public class CountMojo extends AbstractMojo {

    private static final String[] INCLUDES_DEFAULT = {".java", ".xml", ".properties"};

    @Parameter(defaultValue = "${basedir}", property = "baseDir", required = true)
    private File baseDir;

    private List<File> legalFiles;

    @Parameter(property = "suffixes")
    private String[] suffixes;

    public void execute() throws MojoExecutionException, MojoFailureException {
        initialize();

        if (!isParamLegal()) {
            getLog().error("Param is illegal");
            return;
        }

        findOutAllLegalFilesRecursionWithDirection(baseDir);

        countEachLegalFile();
    }

    private void initialize() {
        legalFiles = new ArrayList<File>();

        if (suffixes == null || suffixes.length == 0) {
            suffixes = INCLUDES_DEFAULT;
        }

        getLog().info("baseDir: " + baseDir);
    }

    private boolean isParamLegal() {
        if (baseDir == null || !baseDir.isDirectory()) {
            return false;
        }
        return true;
    }

    private void findOutAllLegalFilesRecursionWithDirection(File baseDir) {
        File[] curFiles = baseDir.listFiles();

        for (File file : curFiles) {
            if (file.isFile()
                    && isLegalFileName(file.getName())) {
                legalFiles.add(file);
            } else if (file.isDirectory()) {
                findOutAllLegalFilesRecursionWithDirection(file);
            }
        }
    }

    private boolean isLegalFileName(String fileName) {
        for (String suffix : suffixes) {
            if (fileName.endsWith(suffix)) {
                return true;
            }
        }
        return false;
    }

    private void countEachLegalFile() {
        printStartFriendInfo();

        for (File file : legalFiles) {

            try {
                BufferedReader bufferedReader = new BufferedReader(new FileReader(file));

                int countLine = 0;

                while (bufferedReader.readLine() != null) {
                    countLine++;
                }

                getLog().info(file.getAbsolutePath() + ": " + countLine + (countLine > 1 ? " lines" : " line"));

            } catch (IOException e) {
                getLog().error("Can't open the file " + file.getName());
            }
        }

        printEndFriendInfo();
    }

    private void printStartFriendInfo() {
        getLog().info("");
        getLog().info("              COUNT LINE");
        getLog().info("");

    }

    private void printEndFriendInfo() {
        getLog().info("");
        getLog().info("");
    }

}
```

## 2.3 将插件部署到本地

运行如下命令

* `$mvn clean install`

成功build，但是出现如下error以及warning
```
[ERROR] 

Artifact Ids of the format maven-___-plugin are reserved for 
plugins in the Group Id org.apache.maven.plugins
Please change your artifactId to the format ___-maven-plugin
In the future this error will break the build.

[WARNING] 

Goal prefix is specified as: 'maven-count-plugin'. Maven currently expects it to be 'count'.
```

* `[ERROR]`：我们之前设定的artifactId为`maven-count-plugin`，这种形式是保留给groupId为`org.apache.maven.plugins`的插件的
* `[WARNING]`：自动生成的pom文件中有如下一句`<goalPrefix>maven-count-plugin</goalPrefix>`，即前缀名称为maven-count-plugin，这里Maven建议前缀可以修改为`count`

于是，修改pom文件，将artifactId改为`count-maven-plugin`，且前缀改为`count`

然后在运行命令进行部署

* `$mvn clean install`

## 2.4 使用插件

在另一个项目的pom文件中增加如下内容

```xml
<project>
    ...
    <build>
        <plugins>

            <!-- 其他plugin -->

            <plugin>
                <groupId>org.liuyehcf</groupId>
                <artifactId>count-maven-plugin</artifactId>
                <version>1.0-SNAPSHOT</version>
                <executions>
                    <execution>
                        <id>count-line</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>count</goal>
                        </goals>
                        <configuration>
                            <suffixes>
                                <suffix>.java</suffix>
                                <suffix>.xml</suffix>
                            </suffixes>

                            <baseDir>.</baseDir>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
    ...
</project>
```

执行以下命令

* `$mvn clean compile`

得到如下输出

```
...
--- count-maven-plugin:1.0-SNAPSHOT:count (count-line) @ SampleMaven ---
[INFO] baseDir: /Users/HCF/Documents/tmp/SampleMaven
[INFO] 
[INFO]               COUNT LINE
[INFO] 
[INFO] /Users/HCF/Documents/tmp/SampleMaven/pom.xml: 111 lines
[INFO] /Users/HCF/Documents/tmp/SampleMaven/src/test/java/org/liuyehcf/SampleTest.java: 24 lines
[INFO] /Users/HCF/Documents/tmp/SampleMaven/src/main/java/org/liuyehcf/Sample.java: 9 lines
[INFO] 
[INFO] 
...
```

# 3 注解

## 3.1 @Mojo

@Mojo注解包含如下属性

1. `name`：这是唯一必须声明的属性，即目标（goal）的名称
1. `defaultPhase`：默认绑定的阶段
1. 其他属性不详细罗列了

## 3.2 @Parameter

@Parameter注解包含如下属性

1. `property`：指定参数名称
1. `defaultValue`：默认值
1. `required`：该属性是否必须配置
1. `readonly`：只读属性，不可修改

# 4 错误处理和日志

AbstractMoj实现了Mojo接口，execute()方法会抛出两种异常：

1. `MojoExecutionException`
1. `MojoFailureException`

当Maven执行插件目标的时候遇到MojoFailureException，就会显示"BUILD FAILURE"的错误信息，这种异常表示Mojo在运行时发现了预期的错误

当Maven执行插件目标的时候遇到MojoExecutionException，就会显示"BUILD ERROR"的错误信息，这种异常表示Mojo在运行时发现了未预期的错误

此外，AbstractMoj提供了一个getLog()方法，用户可以使用该方法获得一个Log对象

# 5 测试插件

测试插件有两种方式

1. 手动测试
1. 集成测试

手动测试无非就是将插件安装到本地仓库后，然后再找个项目测试该插件

集成测试需要一个实际的Maven项目，配置该项目使用插件，然后在该项目上运行Maven构建，最后再验证该构建成功与否。Maven社区有一个来帮助插件集成测试的插件，就是`maven-invoker-plugin`，该插件能够用来在一组项目上执行Maven，并检查每个项目是否构建成功，最后，它还可以执行BeanShell或Groovy脚本来验证项目构建的输出

# 6 参考

* 《Maven实战》
