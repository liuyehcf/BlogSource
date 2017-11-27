---
title: Maven-生命周期和插件
date: 2017-11-27 07:32:21
tags: 
- 摘录
categories: 
- Java
- 包管理器
---

__目录__

<!-- toc -->
<!--more-->

# 1 生命周期详解

Maven拥有__三套相互独立__的生命周期，分别是

1. `cleean`：其目的是__清理项目__
1. `default`：其目的是__构建项目__
1. `site`：其目的是__建立项目站点__

每个生命周期包含一些阶段(phase)，这些阶段有顺序，并且后面的阶段依赖于前面的阶段，__用户和Maven最直接的交互方式就是调用这些生命周期阶段__

另外，三套生命周期之间是相互独立的，用户可以仅仅调用clean生命周期的某个阶段，或者仅仅调用default生命周期的某个阶段。

## 1.1 clean的生命周期

clean生命周期的目的是清理项目，它包含三个阶段：

1. `pre-clean`：执行一些清理前需要完成的工作
1. `clean`：清理上一次构建生成的文件
1. `post-clean`：执行一些清理后需要完成的工作

## 1.2 default生命周期

default生命周期定义了真正构建时所需要执行的所有步骤，__它是所有生命周期中最核心的部分__，包含如下阶段：

1. `validate`
1. `initialize`
1. `generate-sources`
1. __`process-sources`__：处理项目主资源文件。一般来说，是对`src/main/resources`目录的内容进行变量替换等工作后，复制到项目输出的主classpath目录中
1. `generate-resources`
1. `process-resources`
1. __`compile`__：编译项目的主源码。一般来说，是编译`src/main/java`目录下的Java文件至项目输出的主classpath目录中
1. `process-classes`
1. `generate-test-sources`
1. __`process-test-sources`__：处理项目测试资源文件。一般来说，是对`src/test/resources`目录的内容进行变量替换等工作后，复制到项目输出的测试classpath目录中
1. `generate-test-resources`
1. `process-test-resources`
1. __`test-compile`__：编译项目的测试代码。一般来说，是编译`src/test/java`目录下的Java文件至项目输出的测试classpath目录中
1. `process-test-classes`
1. __`test`__：使用单元测试框架运行测试，测试代码不会被打包或部署
1. `prepare-package`
1. __`package`__：接受编译好的代码，打包成可发布的格式，如JAR、WAR等
1. `pre-integration-test`
1. `integration-test`
1. `post-integration-test`
1. `verify`
1. __`install`__：将包安装到__Maven__本地仓库，供本地其他Maven项目使用
1. __`deploy`__：将最终的包复制到远程仓库，供其他开发人员和Maven项目使用

## 1.3 site生命周期

1. `pre-site`：执行一些在生成项目站点之前需要完成的工作
1. `site`：生成项目站点文档
1. `post-site`：执行一些在生成项目站点之后需要完成的工作
1. `site-deploy`：将生成的项目站点发布到服务器上

## 1.4 命令行与生命周期

从命令行执行Maven任务的最主要方式就是调用Maven的生命周期阶段。需要注意的是，各个生命周期是相互独立的，而一个生命周期的阶段是有前后依赖关系的，下面以一些例子进行说明：

1. `$mvn clean`：该命令调用clean生命周期的clean阶段。实际执行的阶段为clean生命周期的pre-clean和clean阶段
1. `$mvn test`：该命令调用default生命周期的test阶段。实际执行的阶段为default生命周期的validate、initialize等，直至test的所有阶段
1. `$mvn clean install`：该命令调用clean生命周期的clean阶段和default生命周期的install阶段。实际执行的阶段为clean生命周期的pre-clean、clean阶段，以及default生命周期的从validate直至install的所有阶段
1. `$mvn clean deploy site-deploy`：该命令调用clean生命周期的clean阶段、default生命周期的deploy阶段，以及site生命周期的site-deploy阶段。实际执行的阶段为clean生命周期的pre-clean、clean阶段，default生命周期的所有阶段，以及site生命周期的所有阶段
* __Maven中主要的生命周期并不多，而常用的Maven命令实际都是基于这些阶段简单组合而成的__

# 2 插件目标

Maven的核心仅仅定义了__抽象的生命周期__，具体的任务是交由插件完成的，插件以独立的构件形式存在，因此，Maven核心的分发包只有不到3MB大小，__Maven会在需要的时候下载并使用插件__

对于插件本身，__为了能够复用代码，它往往能够完成多个任务__。例如`maven-dependency-plugin`，它能够基于项目依赖做很多事情：

1. 能够分析项目依赖，帮助找出潜在的无用依赖；
1. 能够列出项目的依赖树，帮助分析依赖来源；
1. 能够列出项目所有已解析的依赖
1. 等等。

__为每个这样的功能编写一个独立的插件显然是不可取的，因为这些任务背后有很多可复用的代码__。因此，__这些功能聚集在一个插件里，每个功能就是一个插件目标__

`maven-dependency-plugin`有十多个目标，每个目标对应了一个功能，上述提到的几个功能分别对应的插件目标为：

1. `dependency:analyze`
1. `dependency:tree`
1. `dependency:list`
* __通用写法是：`<插件前缀>:<插件目标>`__

# 3 插件绑定

__Maven的生命周期与插件相互绑定，用以完成实际的构建任务__。具体而言，是生命周期的阶段与插件的目标相互绑定，以完成某个具体的构建任务。例如项目编译这一任务，它对应了default生命周期的compile这一阶段，而`maven-compiler-plugin`这一插件的compile目标能够完成该任务

## 3.1 内置绑定

为了简化配置，__Maven在核心为一些主要的生命周期阶段绑定了很多插件的目标__，当用户通过命令行调用生命周期阶段的时候，对应的插件目标就会执行相应的任务

__clean生命周期阶段与插件目标的绑定关系__

| 生命周期阶段 | 插件目标 |
|:--|:--|
| pre-clean | \ |
| clean | maven-clean-plugin:clean |
| post-clean | \ |

__site生命周期阶段与插件目标的绑定关系__

| 生命周期阶段 | 插件目标 |
|:--|:--|
| pre-site | \ |
| site | maven-site-plugin:site |
| post-site | \ |
| site-deploy | maven-site-plugin:deploy |

__default生命周期阶段与插件目标的绑定关系__

<style>
table th:nth-of-type(1) {
    width: 100px;
}
table th:nth-of-type(2) {
    width: 150px;
}
table th:nth-of-type(3) {
    width: 100px;
}
</style>

| 生命周期阶段 | 插件目标 | 执行任务 |
|:--|:--|:--|
| process-resources | maven-resources-plugin:resources | 复制主资源文件至主输出目录 |
| compile | maven-compiler-plugin:compile | 编译主代码至主输出目录 |
| process-test-resources | maven-resources-plugin:testResources | 复制测试资源文件至测试输出目录 |
| test-compile | maven-compiler-plugin:testCompile | 编译测试代码至测试输出目录 |
| test | maven-surefire-plugin:test | 执行测试用例 |
| package | maven-jar-plugin:jar | 创建项目jar包 |
| install | maven-install-plugin:install | 将项目输出构建安装到本地仓库 |
| deploy | maven-deploy-plugin:deploy | 将项目输出构建部署到远程仓库 |

## 3.2 自定义绑定

除了内置绑定以外，用户还能够自己选择将某个插件目标绑定到生命周期的某个阶段上，这种自定义绑定方式能让Maven项目在构建过程中执行更多更富特色的任务

一个常见的例子是创建项目的源码jar包，内置的插件绑定关系没有涉及这一任务，因此需要用户自行配置。`maven-source-plugin`可以帮助我们完成该任务，它的jar-no-fork目标能够将项目的主代码打包成jar文件，可以将其绑定到default生命周期的verify阶段上

```xml
    <build>
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
    </build>
```

* 在`<build>`元素下的`<plugins>`子元素中声明插件的使用
* 该例子中用到的是`maven-source-plugin`，其groupId为`org.apache.maven.plugins`，即Maven官方插件的groupId
* 此外，除了基本的插件坐标声明外，还有插件执行配置
    * `<executions>`下每个`<execution>`子元素可以用来配置执行一个任务，在上述例子中
        * 配置了一个`<id>`为attach-sources的任务，就是个名字，随便起
        * __通过`<phrase>`配置，将其绑定到verify生命周期阶段上__
        * __通过`<goals>`配置指定要执行的插件目标__

有时候，即使不通过`<phase>`元素配置生命周期阶段，插件目标也能够绑定到生命周期中，__这是因为很多插件的目标在编写时已经定义了默认的绑定阶段__。可以使用`maven-help-plugin`插件查看指定插件的详细信息，了解插件目标的默认绑定阶段，示例如下：

* `mvn help:describe -Dplugin=org.apache.maven.plugins:maven-source-plugin:2.1.1 -Ddetail`
* 输出如下

```
...
source:test-jar-no-fork
  Description: This goal bundles all the test sources into a jar archive.
    This goal functions the same as the test-jar goal but does not fork the
    build, and is suitable for attaching to the build lifecycle.
  Implementation: org.apache.maven.plugin.source.TestSourceJarNoForkMojo
  Language: java
  Bound to phase: package  // 可以看到，默认绑定到package
...
```

当插件目标__绑定到不同的生命周期阶段__的时候，其执行顺序会由__生命周期阶段的先后顺序决定__。如果多个目标被__绑定到同一个阶段__，那么__插件声明的先后顺序决定了目标的执行顺序__

# 4 插件配置

完成了插件和生命周期的绑定后，用户还可以配置插件目标的参数，进一步调整插件目标所执行的任务，以满足项目的需求

## 4.1 命令行插件配置

很多插件目标的参数都支持从命令行配置，用户可以在Maven命令中使用`-D`参数，并伴随一个`参数键=参数值`的形式，来配置插件目标的参数

例如，`maven-surefire-plugin`提供了一个maven.test.skip参数，当其值为true的时候，就会跳过执行测试。于是，在运行命令行的时候，加上如下`-D`参数就能跳过测试：

* `mvn install -Dmaven.test.skip=true`

参数`-D`是Java自带的，其功能是通过命令行设置一个Java系统属性，Maven简单地重用了该参数，在准备插件的时候检查系统属性，便实现了该插件参数的配置

## 4.2 POM中插件全局配置

并不是所有插件参数都适合从命令行配置，有些参数的值从项目创建到项目发布都不会改变，或者说很少改变，对于这种情况，在POM文件中一次性配置就显然比重复在命令行中输入要方便

用户可以在声明插件的时候，对此插件进行一个全局的配置。也就是说，所有基于该插件目标的任务，都会使用这些配置。例如，我们通常会需要配置`maven-compiler-plugin`，告诉它编译Java 1.5版本的源文件，生成与JVM 1.5兼容的字节码文件

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>2.1</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
```

* 这样一来，不管绑定到compile阶段的`maven-compiler-plugin:compile`任务，还是绑定到test-compiler阶段的`maven-compiler-plugin:testCompiler`任务，都能够使用该配置，基于Java 1.8版本进行编译

## 4.3 POM中插件全局配置

除了为插件配置全局的参数，用户还可以为某个插件任务配置特定的参数。以`maven-antrun-plugin`为例，它有一个目标run，可以用来在Maven中调用Ant任务。用户将`maven-antrun-plugin:run`绑定到许多生命周期阶段上，再加上不同配置，就可以让Maven在不同的生命周期阶段执行不同的任务（参数不同的同一个目标）

```xml
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-antrun-plugin</artifactId>
                <version>1.3</version>
                <executions>
                    <execution>
                        <id>ant-validate</id>
                        <phase>validate</phase>
                        <goals>
                            <goal>run</goal>
                        </goals>
                        <configuration>
                            <tasks>
                                <echo>I'm bound to validate phase.</echo>
                            </tasks>
                        </configuration>
                    </execution>

                    <execution>
                        <id>ant-verify</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>run</goal>
                        </goals>
                        <configuration>
                            <tasks>
                                <echo>I'm bound to verify phase.</echo>
                            </tasks>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

* `maven-antrun-plugin:run`首先与validate阶段绑定，从而构成一个id为ant-validate的任务，输出一段文字到命令行
* 插件全局配置中的`<configuration>`元素位于`<plugin>`元素下面，而这里的`<configuration>`元素则位于`<execution>`元素下，表示这是特定任务的配置，而非插件整体的配置
* 第二个任务的id为ant-verify，绑定到了verify阶段，输出一段文字到命令行

# 5 获取插件信息

Maven插件非常多，而其中大部分没有完善的文档，因此使用正确的插件并进行正确的配置，并不是一件容易的事情

## 5.1 在线插件信息

__基本上所有主要的插件都来自Apache和Codehaus__。由于Maven本身属于Apache软件基金会的，因此它有很多官方的插件，详细的列表参见[Available Plugins](https://maven.apache.org/plugins/index.html)

虽然并非所有插件都提供了完善的文档，但一些核心插件的文档还是非常丰富的。例如`maven-surefire-plugin`，详见[Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)

## 5.2 使用`maven-help-plugin`描述插件

除了访问在线的插件文档之外，还可以借助`maven-help-plugin`来获取插件的详细信息，例如：`mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin:2.1`

* 这里执行的是`maven-help-plugin`的describe目标，在参数plugin中输入需要描述插件的groupId、artifactId和version

可以省去版本信息，让Maven自动获取最新版本来进行表述，例如：`mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin`

进一步简化，可以使用插件目标前缀替换坐标，例如`mvn help:describe -Dplugin=compiler`

如果想让`maven-help-plugin`输出更详细的信息，可以加上detail参数，例如`mvn help:describe -Dplugin=compiler -Ddetail`

# 6 从命令行调用插件

在命令行中运行`mvn -h`可以显示命令帮助，基本用法如下

* `usage: mvn [options] [<goal(s)>] [<phase(s)>]`

除了选项options之外，mvn命令后面可以添加一个或者多个goal和phase，它们分别是指插件目标和生命周期阶段

我们可以通过mvn命令激活生命周期阶段，从而执行那些绑定在生命周期阶段上的插件目标。__但Maven还支持直接从命令行调用插件目标__。Maven支持这种方式是因为__有些任务不适合绑定在生命周期上__，例如`maven-help-plugin:describe`，我们不需要在构建项目的时候去描述插件信息，又如`maven-dependency-plugin:tree`，我们也不需要在构建项目的时候去显示依赖树。__因此这些插件目标应该通过如下方式使用__：

* `mvn help:describe -Dplugin=compiler`
* `mvn dependency:tree`

这里产生了一个问题，describe是`maven-help-plugin`的目标，但是冒号前面的help既不是groupId也不是artifactId。

回答上述问题之前，先尝试如下命令

* `mvn org.apache.maven.plugins:maven-help-plugin:2.2:describe -Dplugin=compiler`
* `mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:tree`

上述两条命令与之前两条命令是一样的，但显然前面的那种更简洁，更容易记忆和使用。为了达到该目的，__Maven引入了目标前缀的概念__，help是`maven-help-plugin`的目标前缀，dependency是`maven-dependency-plugin`的目标前缀。有了目标前缀，Maven就能找到对应的artifactId。__不过除了artifactId，Maven还需要groupId和version才能精确定位到某个插件，下一节中详细解释__

# 7 插件解析机制

为了方便用户使用和配置插件，__Maven不需要用户提供完整的插件坐标信息__，就可以解析得到正确的插件，Maven的这一特性是一把双刃剑，虽然简化了插件的使用和配置，可一旦插件的行为出现异常，用户就很难快速定位到出问题的插件构件

## 7.1 插件仓库

__与依赖构件一样，插件构件同样基于坐标存储在Maven仓库中__。在需要的时候，Maven会从本地仓库寻找插件，如果不存在，则从远程仓库查找。找到插件之后，再下载到本地仓库使用

值得一提的是，__Maven会区别对待依赖的远程仓库和插件的远程仓库__

* 当Maven需要的依赖在本地仓库不存在时，它会去所配置的远程仓库查找
* 当Maven需要的插件在本地仓库不存在时，它就不会去这些（可能是指自己设定的仓库，对于在中央仓库的核心插件而言，还是会查找然后下载到本地的）远程仓库查找

插件的远程仓库使用<pluginRepositories>和<pluginRepository>配置

## 7.2 插件的默认groupId

在POM中配置插件的时候，如果该插件是Maven的官方插件，即org.apache.maven.plugins，就可以省略groupId的配置。__不建议这样使用，会让人感到费解__

## 7.3 解析插件版本

为了简化插件的配置和使用，在用户没有提供插件版本的情况下，Maven会自动解析插件版本。

Maven在超级POM中为所有核心插件设定了版本，超级POM是所有Maven项目的父POM，所有项目都继承了这个超级POM的配置，因此，即使用户不加任何配置，Maven使用核心插件的时候，它们的版本已经确定了。这些插件包括`maven-clean-plugin`、`maven-compiler-plugin`、`maven-surefire-plugin`

当用户使用某个非核心插件且没有声明版本的时候，Maven会将版本解析为所有可用仓库中的稳定版本

依赖Maven解析插件版本其实是不推荐的做法，会导致潜在的不稳定性。__因此使用插件的时候，应该一直显式地设定版本__，这也解释了Maven为什么要在超级POM为核心插件设定版本

## 7.4 解析插件前缀

mvn命令行支持使用插件前缀来简化插件的使用，__插件前缀与groupId:artifactid是一一对应的，这种匹配关系存储在仓库元数据中__，这里的仓库元数据为`groupId/maven-metadata.xml`，这里的groupId是指默认的org.apache.maven.plugins和org.codehaus.mojo，也可以通过配置settings.xml让Maven检查其他groupId上的插件仓库元数据

```xml
<settings>
    <pluginGroups>
        <pluginGroup>com.your.plugins</pluginGroup>
    </pluginGroups>
</settings>
```

* 基于该配置，Maven就不仅仅会检查org/apache/maven/plugins/maven-metadata.xml和org/codehaus/mojo/maven-metadata.xml，还会检查com/your/plugins/maven-metadata.xml

当Maven解析到`dependency:tree`这样的命令后，首先基于默认的groupId归并所有插件仓库的元数据org/apache/maven/plugins/maven-metadata.xml，然后检查归并后的元数据，找到对应的artifactId为maven-dependency-plugin，然后结合当前元数据的groupId，即org.apache.maven.plugins。最后使用前一小结的方法解析version，这时就得到了完整的插件坐标。如果org/apache/maven/plugins/maven-metadata.xml没有记录该插件前缀，则接着检查其他groupId下的元数据，若都找不到，则报错

# 8 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* 《Maven实战》
