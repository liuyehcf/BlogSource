---
title: Maven-Test
date: 2017-11-27 10:34:42
tags: 
- 摘录
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 maven-surefire-plugin插件简介

Maven本身并不是一个单元测试框架，Java世界中主流的单元测试框架为Junit和TestNG。**Maven所做的只是在构建执行到特定生命周期阶段的时候，通过插件来执行Junit或者TestNG的测试用例，这一插件就是`maven-surefire-plugin`**

在默认情况下，`maven-surefire-plugin`的test目标会自动执行测试源码路径下所有符合一组命名模式的测试类

1. `**/Test*.java`：任何子目录下所有命名以Test开头的Java类
1. `**/*Test.java`：任何子目录下所有命名以Test结尾的Java类
1. `**/*TestCase.java`：任何子目录下所有命名以TestCase结尾的Java类

# 2 跳过测试

有时候，我们会要求Maven跳过测试，这很简单，在命令行加入参数`skipTests`就可以

* `$mvn package -DskipTests`

我们也可以在POM中配置`maven-surefire-plugin`插件来提供该属性，示意代码如下

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
                    <skipTests>true</skipTests>
                </configuration>
            </plugin>
            ...
        </plugins>
        ...
    </build>
    ...
</project>
```

如果不仅想跳过测试，还想临时性地**跳过测试代码的编译**，Maven也允许，但是不推荐

* `$mvn package -Dmaven.test.skip=true`
* 注意到，参数`maven.test.skip`同时控制了`maven-compiler-plugin`和`maven-surefire-plugin`两个插件的行为，测试代码编译跳过了，测试运行也跳过了

同样地，也可以在POM文件中同时配置这两个插件，来达到参数`maven.test.skip`的效果，示意代码如下

```xml
<project>
    ...
    <build>
        ...
        <plugins>
            ...
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>2.1</version>
                <configuration>
                    <skipTests>true</skipTests>
                </configuration>
            </plugin>

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.5</version>
                <configuration>
                    <skipTests>true</skipTests>
                </configuration>
            </plugin>
            ...
        </plugins>
        ...
    </build>
    ...
</project>
```

实际上，`maven-compiler-plugin`的testCompile目标和`maven-surefire-plugin`的test目标**都提供**了一个参数skip用来跳过测试编译和测试运行，而这个参数对应的命令行表达式为`maven.test.skip`

# 3 动态指定要运行的测试用例

反复运行单个测试用例是日常开发中很常见的行为。`maven-surefire-plugin`提供了一个test参数让Maven用户能够在命令行指定要运行的测试用例

* 指定测试类运行
    * `$mvn test -Dtest=SampleTest`：只有SampleTest这一个测试类得到运行
* 使用通配符`*`
    * `$mvn test -Dtest=*Test`：所有类名以Test结尾的类得到运行
* 使用逗号分隔符`,`
    * `$mvn test -Dtest=SampleTest1,SampleTest2`：SampleTest1与SampleTest2这两个测试类得到执行
* 结合多种特殊符号
    * `$mvn test -Dtest=*Test,SampleTest1,SampleTest2`
* **注意，匹配的是简单类名，既不需要包名以及后缀`.java`**

test参数的值必须匹配一个或者多个测试类，如果`maven-surefire-plugin`找不到任何匹配的测试类，就会报错并导致构建失败。可以加上参数`-DfailIfNoTests=false`，告诉`maven-surefire-plugin`即使没有任何测试也不要报错

* `$mvn test -Dtest -DfailIfNoTests=false`：这也是另外一种跳过测试运行的方法
* `$mvn test -Dtest=NotExists -DfailIfNoTests=false`

`maven-surefire-plugin`**没有提供**任何的命令行参数支持用户从命令行**跳过**指定的测试类，但好在可以在POM文件中配置`maven-surefire-plugin`以排除特定的测试类

# 4 包含与排除测试用例

前面介绍了一组命名模式，符合这一组模式的测试类会自动执行。Maven提倡约定优于配置原则，因此用户应该尽量遵守这一组模式来为测试类命名。即便如此，`maven-surefire-plugin`还是允许用户通过额外的配置来**自定义包含一些其他测试类**，或者**排除一些符合默认命名模式的测试类**

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

**注意**

1. **使用`<includes>`元素后**，默认的匹配规则**将会失效**
1. **使用`<excludes>`元素后**，默认的匹配规则**不会失效**

# 5 测试报告

除了命令行输出，Maven用户可以使用`maven-surefire-plugin`等插件以文件的形式生成更丰富的测试报告

## 5.1 基本的测试报告

默认情况下，`maven-surefire-plugin`会在项目的`target/surefire-reports`目录下生成两种格式的错误报告

1. 简单文本格式
1. 与Junit兼容的XML格式

## 5.2 测试覆盖率报告

测试覆盖率是衡量项目代码质量的一个重要的参考指标。Cobertura是一个优秀的开源测试覆盖率统计工具，Maven通过`cobertura-maven-plugin`与之集成

执行如下命令

* `$mvn cobertura:cobertura`

然后，打开项目目录`target/site/cobertura/`下的index.html文件，就能看到测试覆盖率报告，单击具体的类，还能看到精确到行的覆盖率报告

## 5.3 运行TestNG测试

TestNG是Java社区中除Junit之外另一个流行的单元测试框架

下表为Junit和TestNG的常用类库对应关系

<style>
table th:nth-of-type(1) {
    width: 45px;
}
table th:nth-of-type(2) {
    width: 75px;
}
table th:nth-of-type(3) {
    width: 70px;
}
</style>

| JUnit类 | TestNG类 | 作用 |
|:--|:--|:--|
| org.junit.Test | org.testng.annotations.Test | 标注方法作为测试方法 |
| org.junit.Assert | org.testng.Assert | 检查测试结果 |
| org.junit.Before | org.testng.annotations.BeforeMethod | 标注方法在每个测试方法之前执行 |
| org.junit.After | org.testng.annotations.AfterMethod | 标注方法在每个测试方法之后执行 |
| org.junit.BeforeClass | org.testng.annotations.BeforeClass | 标注方法在所有测试方法之前执行 |
| org.junit.AfterClass | org.testng.annotations.AfterClass | 标注方法在所有测试方法之后执行 |

TestNG允许用户使用一个名为testng.xml的文件来配置想要运行的测试集合。在**项目根目录**创建`testng.xml`文件，内容如下

```xml
<?xml version="1.0" encoding="UTF-8"?>

<suite name="Suite1" verbose="1">
    <test name="TestNG1">
        <classes>
            <class name="org.liuyehcf.SampleNGTest"/>
            <class name="org.liuyehcf.SampleNGTest1"/>
            <class name="org.liuyehcf.SampleNGTest2"/>
        </classes>
    </test>
</suite>
```

然后配置POM文件

```xml
<project>
    ...
    <dependencies>
        ...
        <dependency>
            <groupId>org.testng</groupId>
            <artifactId>testng</artifactId>
            <version>RELEASE</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        ...
        <plugins>
            ...
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.5</version>
                <configuration>
                    <suiteXmlFiles>
                        <suiteXmlFile>testng.xml</suiteXmlFile>
                    </suiteXmlFiles>
                </configuration>
            </plugin>
        </plugins>
        ...
    </build>
    ...
</project>
```

此外，TestNG较Junit的一大优势在于它支持测试组的概念

* `@Test(groups={"group1","group2"})`

然后在POM文件中配置测试组即可

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
                    <suiteXmlFiles>
                        <suiteXmlFile>testng.xml</suiteXmlFile>
                    </suiteXmlFiles>
                    <groups>group2</groups>
                </configuration>
            </plugin>
        </plugins>
        ...
    </build>
    ...
</project>
```

**注意**

1. 不要同时包含Junit以及TestNG的依赖，否则Junit的测试用例不会生效
1. 使用TestNG且配置了`<suiteXmlFiles>`元素后，默认的匹配规则将不会生效，且`<includes>`元素以及`<excludes>`元素也不会生效

# 6 重用测试代码

默认的打包行为是不会包含测试代码的，因此在使用外部依赖的时候，其构件一般都不会包含测试代码

如果我们想要重用某个用于测试的代码，我们可以通过配置`maven-jar-plugin`将测试类打包，示意代码如下

```xml
<project>
    ...
    <build>
        ...
        <plugins>
            ...
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>2.5</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>test-jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
        ...
    </build>
    ...
</project>
```

`maven-jar-plugin`有两个目标，分别是jar和test-jar，前者通过Maven的内置绑定在default生命周期的package阶段运行，其行为就是对项目主代码进行打包，而后者并没有内置绑定，因此上述的插件配置**显式声明该目标**来打包测试代码。test-jar的默认绑定生命周期阶段为package。因此，执行`$mvn clean package`后，就可以在`target/`目录中看到测试jar包了

# 7 参考

* 《Maven实战》
