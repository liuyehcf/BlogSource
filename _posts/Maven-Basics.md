---
title: Maven-Basics
date: 2017-11-27 06:32:21
tags: 
- 摘录
categories: 
- Java
- Maven
---

**阅读更多**

<!--more-->

# 1 Coordinate and Dependency

## 1.1 Coordinate

Maven坐标为各种构件引入秩序，任何一个构件都必须明确定义自己的坐标，而一组Maven坐标是通过一些元素定义的，详细解释如下：

1. `groupId`：定义当前Maven项目隶属的**实际项目**
    * Maven项目和实际项目不一定是一对一的关系，例如SpringFramework这一实际项目，其对应的Maven项目会有很多，例如spring-core、spring-context等。这是由于Maven中模块的概念，因此一个实际项目往往会被划分成很多模块
    * groupId**不应该**对应项目隶属的组织或公司。因为一个组织下会有很多实际项目，如果groupId只定义到组织级别，那么artifactId将很难定义
    * groupId表示方式与Java包名的表示方式类似，通常与域名反向一一对应
1. `artifactId`：该元素定义实际项目中的一个**Maven项目（模块）**
    * 推荐的做法是使用实际项目名称作为artifactId的前缀，便于构件的寻找
1. `version`：该元素定义Maven项目**当前所处的版本**
1. `packaging`：该元素定义Maven项目的**打包方式**
    * 可选的打包方式有：`jar`、`war`、`maven-plugin`等等
    * 默认打包方式为`jar`
1. `classifier`：该元素用来帮助定义构建输出的一些附属构件
    * 不能直接定义项目的classifier，因为附属构件不是项目直接默认生成的，而是由附加的插件帮助生成的

项目构件的文件名是与坐标相对应的，一般的规则为`artifactId-version[-classifier].packaging`

## 1.2 Dependency Config

根元素`<project>`下的`<dependencies>`元素可以包含一个或多个`<dependency>`元素，以声明一个或者多个项目依赖。每个依赖可以包含的元素详细解释如下：

1. `groupId、artifactId、version`：依赖的基本坐标，**对于任何一个依赖来说，基本坐标是最重要的**
1. `type`：依赖类型，对应于项目坐标定义的`packaging`。大部分情况下，该元素不必声明，其默认值为`jar`
1. `scope`：依赖的范围
1. `optional`：标记依赖是否可选
1. `exclusions`：用来排除传递性依赖

## 1.3 Dependency Scope

Maven在**编译项目主代码**的时候需要用一套classpath，在**编译和执行测试**的时候会使用另外一套classpath，在实际**运行Maven项目**的时候，又会使用一套classpath

**依赖范围就是用来控制依赖与这三种classpath（编译classpath、测试classpath、运行classpath）的关系**

1. `compile`：编译依赖范围
    * **如果没有指定，就会使用该依赖范围**
    * 使用此依赖范围的Maven依赖，对于**编译、测试、运行**三种classpath都有效
    * 典型的例子是spring-core，在编译、测试和运行的时候都需要使用该依赖
1. `test`：测试依赖范围
    * 使用此依赖范围的Maven依赖，只对于**测试**classpath有效，在编译主代码或者运行项目时将无法使用此类依赖
    * 典型的例子是JUnit，它只有在编译测试代码及运行测试的时候才需要
1. `provided`：已提供依赖范围
    * 使用此依赖范围的Maven依赖，对于**编译和测试**classpath有效，但在运行时无效
    * 典型的例子是servlet-api，编译和测试项目的时候需要该依赖，但在运行项目的时候，由于容器已经提供，就不需要Maven重复地引入
1. `runtime`：运行时依赖范围
    * 使用此依赖范围的Maven依赖，对于**测试和运行**classpath有效，但在编译主代码时无效
    * 典型的例子是JDBC驱动实现，项目主代码的编译只需要JDK提供的JDBC接口，只有在实际执行测试或者运行项目的时候才需要实现上述接口的具体JDBC驱动
1. `system`：系统依赖范围
    * 该依赖与三种classpath的关系，和provided依赖范围完全一致
    * 使用system范围的依赖时必须通过systemPath元素显式指定依赖文件路径
    * 由于此依赖不是通过Maven仓库解析，且往往与本机系统绑定，可能造成构建的不可移植，因此应该谨慎使用
1. `import`：导入依赖范围
    * 该依赖范围不会对三种classpath产生实际影响
    * 该范围的依赖只在`<dependencyManagement>`元素下才有效果，使用该范围的依赖通常指向一个POM，作用是：将目标POM中的`<dependencyManagement>`配置导入并合并到当前POM的`<dependencyManagement>`元素中

| 依赖范围（Scope） | 对于编译classpath有效 | 对于测试classpath有效  | 对于运行classpath有效  | 例子  |
|:--|:--|:--|:--|:--|
| compile | Y | Y | Y | spring-core |
| test | N | Y | N | Junit |
| provided | Y | Y | N | servlet-api |
| runtime | N | Y | Y | JDBC驱动实现 |
| system | Y | Y | N | 本地的，Maven仓库之外的类库文件 |

## 1.4 Transitivity of Dependency

Maven会解析各个直接依赖的POM，将哪些必要的间接依赖，以传递性依赖的形式引入到当前项目中

| 传递性依赖范围 | compile | test  | provided  | runtime  |
|:--|:--|:--|:--|:--|
| compile | compile | \ | \ | runtime |
| test | test | \ | \ | test |
| provided | provided | \ | provided | provided |
| runtime | runtime | \ | \ | runtime |

## 1.5 Dependency Mediation

Maven引入的传递性依赖机制，一方面大大简化和方便了依赖声明，另一方面，大部分情况下我们只需要关心项目的直接依赖时什么，而不同考虑这些依赖会引入什么传递性依赖

但有时候，当传递性依赖造成问题的时候，我们就需要清楚地知道该传递性依赖是从哪条依赖路径引入的。例如，`A->B->C->X(1.0)`、`A->D->X(2.0)`，X是A的传递性依赖，但是两条路径上有两个版本的X，那么哪个X会被Maven解析使用呢

* Maven依赖调解的第一原则是：路径最近者优先，在上述例子中，X(1.0)的路径长度为3，而X(2.0)的路径长度为2，因此X(2.0)会被解析使用
* Maven定义了依赖调解的第二原则：第一声明者优先，即在POM中依赖声明的顺序决定了谁会被解析使用，顺序最靠前的那个依赖优胜

## 1.6 Optional Dependency

假设有这样一个依赖关系，项目A依赖项目B，项目B依赖项目X和Y，B对于X和Y的依赖都是可选依赖，**于是X和Y不会对A有任何影响**

* A->B
* B->X(可选)
* B->Y(可选)

为什么有这样的需求呢？可能项目B实现了两个特性，其中的特性一依赖于X，特性二依赖于Y，且这两个特性是互斥的，用户不可能同时使用两个特性

由于可选依赖不会被传递，**因此A必须显式声明依赖X或依赖Y**

在理想情况下，是**不应该**使用可选依赖的，在面向对象设计中，有一个**单一职责性原则**，意味着一个类应该只有一项职责，而不是糅合太多的功能。**而使用可选依赖的原因是某一个项目实现了多个特性**，违背了单一职责性原则。因此应该将这个项目拆分成多个职责单一的项目，这样一来就不需要使用可选依赖了

## 1.7 Exclude Dependency

传递性依赖会给项目隐式地引入很多依赖，这极大地简化了项目依赖的管理，但是有些时候这种特性也会带来问题。例如，当前项目有一个第三方依赖，而这个第三方依赖由于某些原因依赖了另外一个类库的SNAPSHOT版本，那么这个SNAPSHOT就会成为当前项目的传递性依赖，而SNAPSHOT的不稳定性会直接影响到当前的项目。**这时候就需要排除掉该SNAPSHOT，并且在当前项目中声明该类库的某个正式发布的版本**

可以使用`<exclusions>`元素声明排除依赖，`<exclusions>`元素可以包含一个或多个`<exclusion>`子元素，因此可以排除一个或多个传递性依赖。**值得注意的是**，声明exclusion的时候**只需要**groupId和artifactId，而**不需要**version，这是因为只需要groupId和artifactId就能唯一定位依赖图中的某个依赖（Maven解析后的依赖图中，不存在groupId和artifactId相同但是version不同的依赖）

```xml
<project>
    ...
    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>liuyehcf-project-a</artifactId>
            <version>1.0.0</version>
            <exclusions>
                <exclusion>
                    <groupId>org.liuyehcf</groupId>
                    <artifactId>liuyehcf-project-b</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
    </dependencies>
    ...
</project>
```

## 1.8 Dependency Classification

有很多关于Spring Framework的依赖，它们分别是`org.springframework:spring-core:4.1.6`、`org.springframework:spring-aop:4.1.6`、`org.springframework:spring-web:4.1.6`等等，**它们是来自同一项目的不同模块，因此，所有这些依赖的版本都是相同的，而且可以预见**，如果将来需要升级Spring Framework，这些依赖的版本会一起升级

可以使用Maven自定义属性来声明依赖项目的版本，将该依赖项目的多个不同模块的version替换为Maven自定义属性，这样只需要修改自定义属性的值，就能够替换整个项目的多个模块的版本

```xml
<project>
    ...
    <properties>
        <spring.version>4.1.6.RELEASE</spring.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-aop</artifactId>
            <version>${spring.version}</version>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-web</artifactId>
            <version>${spring.version}</version>
        </dependency>
    </dependencies>
    ...
</project>
```

## 1.9 Dependency Composition

有时候，我们想要一次构建多个项目，而不是到这些模块的目录下分别执行mvn命令。Maven聚合（或者称多模块）这一特性就是为该需求服务的

**对于聚合项目，其POM文件的`<packaging>`元素必须是pom**，否则无法构建

一个聚合项目，其POM文件包含如下几个重要元素，详见下方示意代码

1. `<packaging>`：打包方式，必须为pom
1. `<name>`：提供一个更易阅读的名字，会在构建时显示
1. `<modules>`：聚合项目的核心配置
    * 每个`<module>`元素的值都是一个当前POM的**相对目录**（很重要）

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

一般来说，为了方便快速定位内容，**模块所处目录的名称应当与其artifactId一致**。当然也可以不一样，只不过需要修改聚合POM文件中的`<module>`元素的值

此外，为了方便用户构建项目，通常将聚合模块放在项目目录的最顶层，其他模块则作为聚合模块的子目录存在。这样当用户得到源码的时候，第一眼发现的就是聚合模块的POM，不用从多个模块中去寻找聚合模块来构建整个项目

### 1.9.1 Inherit

在面向对象的世界中，程序员可以使用类继承在一定程度上消除重复，在Maven的世界中，也有类似的机制能让我们抽取出重复的配置，这就是POM的继承

对于一个父模块，其POM文件包含如下几个重要元素，详见下方示意代码

1. `<packaging>`：打包方式，**必须为pom，这一点与聚合模块一样**
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
    * `<relativePath>`：当前POM的**相对目录**，用于定位父模块pom文件的目录
        * 在项目构建时，Maven会首先根据relativePath检查父POM，如果找不到，再从本地仓库找
        * **relativePath的默认值是：`../pom.xml`，也就是默认父POM在上一层目录下**

#### 1.9.1.1 Inherited Elements

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

#### 1.9.1.2 Dependency Management

Maven提供的`<dependencyManagement>`元素既能让子模块继承到父模块的依赖配置，又能保证子模块依赖使用的灵活性

在父模块的POM文件中的`<dependencyManagement>`元素下的依赖声明**不会引入实际的依赖（父子模块都不会引入实际的依赖）**，不过它能够**约束**`<dependencies>`下的依赖使用

`<dependencyManagement>`元素是**可以被继承**的，但是**并不会引入实际的依赖**。因此在子模块的POM文件中，还是需要在`<dependencies>`元素中声明所需的依赖，但是只需要配置依赖的groupId以及artifactId即可，详见下方示意代码

**父POM文件**

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

**子POM文件**

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

可以看到，子POM文件中的依赖配置较原来简单了一些，所有的springframework只配置了groupId和artifactId，省去了version；而junit不仅省去了version还省去了scope。这是因为**完整的依赖声明已经包含在父POM中**，子模块**只需要配置简单的groupId和artifactId就能获得对应的依赖信息**，从而引入正确的依赖

这种依赖管理机制似乎不能减少太多的POM配置，**不过还是建议采用这种方法**，原因如下

* 父POM中使用`<dependencyManagement>`声明依赖能够**统一**项目范围中**依赖的版本**
* 当依赖版本在父POM中声明之后，子模块在使用依赖的时候就无需声明版本，也就不会发生多个子模块使用依赖版本不一致的情况，这可以帮助降低依赖冲突的概率

此外，{% post_link Maven-Basics %}中提到了名为import的依赖范围，该范围的依赖只在`<dependencyManagement>`元素下才有效果，使用该范围的依赖通常指向一个POM，作用是：将目标POM中的`<dependencyManagement>`配置导入并合并到当前POM的`<dependencyManagement>`元素中

#### 1.9.1.3 Plug Management

类似的，Maven也提供了`<pluginManagement>`元素帮助管理插件，该元素中配置的依赖**不会造成实际的插件调用行为**。由于`<build>`元素可被继承，因此其子元素`<pluginManagement>`也可以被继承。在子POM文件中配置了真正的`<plugin>`元素，其groupId与artifactId与父POM文件中的`<pluginManagement>`元素中配置的插件匹配时，`<pluginManagement>`的配置才会起作用

同样的，**完整的插件声明已经包含在父POM中**，子模块**只需要配置简单的groupId和artifactId就能获得对应的插件信息**，从而引入正确的插件

**父POM文件**

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

**子POM文件**

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

### 1.9.2 Composition and Inherit

**聚合**主要是为了**方便快速构建项目**，而**继承**主要是为了**消除重复配置**。**聚合和继承是两个正交的概念**

对于聚合模块来说，它知道有哪些被聚合的模块，但那些被聚合的模块不知道这个聚合模块的存在

对于继承关系的父POM来说，它不知道有哪些子模块继承于它，但那些子模块都必须知道自己的父POM是什么

聚合和继承唯一的共性是其`<packaging>`元素的值都是pom

在现有的项目中，往往将聚合与继承合二为一，即一个POM既是聚合POM又是父POM，这么做主要是为了方便

### 1.9.3 Conventions

Maven会假设用户的项目是这样的：

1. 源码目录为：`src/main/java/`
1. 编译输出目录为：`target/classes/`
1. 打包方式为：`jar`
1. 包输出目录为：`target/`

遵循约定虽然损失了一定的灵活性，用户不能随意安排目录结构，但是却能减少配置。更重要的是，遵循约定能够帮助用户遵守构建标准

没有约定，意味着10个项目可能使用10种不同的项目目录结构，这意味着交流学习成本的增加，而这种增加的成本往往就是浪费

任何一个Maven项目都隐式地继承自`超级POM`（`$MAVEN_HOME/lib/maven-model-builder-x.x.jar`中的`org/apache/maven/model/pom-4.0.0.xml`），这有点类似于任何一个Java类都隐式地继承于Object类。**因此大量超级POM的配置都会被所有Maven项目继承，这些配置也就成了Maven所提倡的约定**

## 1.10 maven-dependency-plugin

1. `mvn dependency:list`
1. `mvn dependency:tree`
1. `mvn dependency:analyze`

# 2 Repository Classification

在Maven世界中，任何一个依赖、插件或者项目构建的输出，都可以称为**构件**

在**不使用**Maven的那些项目中，往往能发现命名为lib/的目录，各个项目lib/下的内容存在**大量的重复**

得益于坐标机制，任何Maven项目使用任何一个构件的方式都是完全相同的。在此基础之上，Maven可以在某个位置**统一存储**所有Maven项目共享的构件，这个统一的位置就是**仓库**

实际的Maven项目将不再各自存储其依赖文件，它们只需要声明这些依赖的坐标，在需要的时候，Maven会自动根据坐标找到仓库中的构件，并使用它们

## 2.1 Repository 

对于Maven来说，**Maven仓库**只分为两类：**本地仓库**和**远程仓库**

当Maven根据坐标寻找构件的时候

1. **它首先会查看本地仓库**
    * 如果本地仓库存在此构件，则直接使用
1. 如果本地仓库不存在此构件，或需要查看是否有更新的构件版本，**Maven就会去远程仓库查找**，发现需要的构件之后，下载到本地仓库再使用

**远程仓库**还可以进一步细分

1. **中央仓库**：Maven核心自带的远程仓库
1. **私服**：局域网内的私有仓库服务器，用来代理所有外部的远程仓库
1. **其他公共库**：常见的有Java.net Maven库以及JBoss Maven库

综上，Maven仓库的树形结构图如下：

* Maven仓库
    * 本地仓库
    * 远程仓库
        * 中央仓库
        * 私服
        * 其他公共库

## 2.2 Local Repository

一般来说，Maven项目目录下，没有诸如/lib这样用来存放依赖文件的目录。当Maven在执行编译或测试时，如果需要使用依赖文件，它**总是基于坐标使用本地仓库的依赖文件**

默认情况下，无论在Windows上还是Linux上，每个用户在自己的用户目录下都有一个路径为`.m2/repository/的仓库目录`

若要自定义本地仓库地址，可以编辑`~/.m2/settings.xml`，设置`<localRepository>`元素的值即可。注意到，`~/.m2/settings.xml`文件**默认是不存在**的，**用户需要从Maven安装目录复制`$MAVEN_HOME/conf/settings.xml`文件**，然后再进行编辑

## 2.3 Remote Repository

安装好Maven后，如果不执行任何Maven命令，本地仓库目录是不存在的。当用户输入第一条Maven命令后，Maven才会创建本地仓库，然后根据配置和需要，**从远程仓库下载构件**至本地仓库

对于Maven来说，每个用户只有一个本地仓库（书房），但可以配置访问很多远程仓库（书店）

### 2.3.1 Central Repository

由于最原始的本地仓库是空的，Maven必须知道至少一个可用的远程仓库，才能在执行Maven命令的时候下载到需要的构件，以下是超级POM文件的片段（`$MAVEN_HOME/lib/maven-model-builder-x.x.jar`中的`org/apache/maven/model/pom-4.0.0.xml`）

```xml
<project>
    ...
    <repositories>
        <repository>
            <id>central</id>
            <name>Central Repository</name>
            <url>https://repo.maven.apache.org/maven2</url>
            <layout>default</layout>
            <snapshots>
                <enabled>false</enabled>
            </snapshots>
        </repository>
    </repositories>
    ...
</project>
```

* 这段配置，使用`<id>`元素对中央仓库进行唯一标识

### 2.3.2 Private Repository

私服是一种特殊的远程仓库，它是架设在局域网内的仓库服务，私服代理广域网上的远程仓库，提供局域网内的Maven用户使用

当Maven需要下载构件的时候，它从私服请求，如果私服上不存在该构件，则从外部的远程仓库下载，缓存在私服之上后，再为Maven的下载请求提供服务

**私服有如下优势**

1. **节省自己的外网带宽**
    * 大量的对于外部仓库的重复请求会消耗很大的带宽，利用私服代理外部仓库之后，对外的重复构件下载便得以消除，即降低外网带宽的压力
1. **加速Maven构建**
    * 不停地连接请求外部仓库是十分耗时的，但是Maven的一些内部机制（如快照更新检查）要求Maven在执行构建的时候不停地检查远程仓库数据库
    * 因此，当项目配置了很多外部远程仓库时，构建的速度会被大大降低
    * 使用私服可以很好地解决这一问题，当Maven只需要检查局域网内私服的数据时，构建的速度得到很大程度的提高
1. **部署第三方构件**
    * 对于无法从外部仓库获得的构件，例如组织内部生成的私有构件，可以部署到内部仓库，提供内部Maven项目使用
1. **提高稳定性，增强控制**
    * Maven构建高度依赖远程仓库，因此，当Internet不稳定时，Maven构建也会变得不稳定，甚至无法构建，使用私服后，即使暂时没有Internet连接，由于私服中已经缓存了大量构件，Maven也仍然可以正常运行
    * 此外，一些私服软件（如Nexus）还提供了很多额外的功能，如权限管理、RELEASE/SNAPSHOT区分等，管理员可以对仓库进行一些更高级的控制
1. **降低中央仓库负荷**
    * 使用私服可以避免很多对中央仓库的重复下载

## 2.4 Config

可以在项目的POM文件中配置仓库，在`<repositories>`元素下，可以使用`<repository>`子元素声明一个或多个远程仓库，其包含的子元素如下

* `<id>`：**任何一个仓库声明的id必须是唯一的**，Maven自带的中央仓库使用的id为central，如果其他仓库声明也使用该id，就会覆盖中央仓库的配置
* `<name>`：仓库名称，方便人阅读，无其他作用
* `<url>`：仓库的地址
* `<releases>`：用于控制Maven对于发布版构件的下载
    * `<enabled>`：控制是否支持下载
    * `<updatePolicy>`：配置从远程仓库检查更新的频率，默认daily，可用参数如下
        * `daily`：默认值，Maven每天检查一次
        * `never`：从不检查更新
        * `always`：每次构建都检查更新
        * `interval:X`：每隔X分钟检查更新
    * `<checksumPolicy>`：配置Maven检查**检验和文件**的策略
* `<snapshots>`：用于控制Maven对于发布版构件的下载
    * `<enabled>`：控制是否支持下载
    * `<updatePolicy>`：同上
    * `<checksumPolicy>`：同上

```xml
<project>
    ...
    <repositories>
        <repository>
            <id>jboss</id>
            <name>JBoss Repository</name>
            <url>http://repository.jobss.com/maven2/</url>
            <releases>
                <enabled>true</enabled>
                <updatePolicy>daily</updatePolicy>
                <checksumPolicy>ignore</checksumPolicy>
            </releases>
            <snapshots>
                <enabled>false</enabled>
                <updatePolicy>daily</updatePolicy>
                <checksumPolicy>ignore</checksumPolicy>
            </snapshots>
            <layout>default</layout>
        </repository>
    </repositories>
    ...
</project>
```

### 2.4.1 Authentication

大部分远程仓库无须认证就可以访问，**但有时候处于安全方面的考虑，我们需要提供认证信息才能访问一些远程仓库**

配置认证信息和配置仓库信息不同，**仓库信息可以直接配置在POM文件中，但是认证信息必须配置在settings.xml文件中**。这是因为，POM往往是被提交到代码仓库中所有成员访问的，而settings.xml一般只放在本机。因此在settings.xml中配置认证信息更为安全，配置代码片段如下

```xml
<settings>
    ...
    <servers>
        <server>
            <id>my-proj</id>
            <username>repo-user</username>
            <password>repo-pwd</password>
        </server>
    </servers>
    ...
</settings>
```

* 其中，**`<server>`元素的id必须与POM中需要认证的`<repository>`元素的id完全一致**

### 2.4.2 Deploy

私服的一大作用就是部署第三方构件，包括组织内部生成的构件以及一些无法从外部仓库直接获取的构件。无论是日常开发中生成的构件，还是正式版本发布的构件，都需要部署到仓库中，供其他团队成员使用

Maven除了能对项目进行编译、测试、打包之外，还能将项目生成的构件部署到仓库中。编辑项目的POM文件，配置`<distributionManagement>`元素，代码如下

```xml
<project>
    ...
    <distributionManagement>
        <repository>
            <id>proj-releases</id>
            <name>Proj Release Repository</name>
            <url>http://192.168.1.100/content/repositories/proj-releases</url>
        </repository>

        <snapshotRepository>
            <id>proj-snapshots</id>
            <name>Proj Snapshot Repository</name>
            <url>http://192.168.1.100/content/repositories/proj-snapshots</url>
        </snapshotRepository>
    </distributionManagement>
    ...
</project>
```

`<distributionManagement>`元素包含`<repository>`和`<snapshotRepository>`子元素。这两个元素都需要配置id、name和url

* `<id>`：为该远程仓库的唯一标识
* `<name>`：是为了方便人阅读
* `<url>`：表示仓库地址

往远程仓库部署构件的时候，往往需要认证，配置方式在上一小节中已经介绍，完全一致

运行命令`$mvn clean deploy`，Maven就会将项目构建输出的构件部署到配置对应的远程仓库，如果项目当前版本是快照版本，则部署到快照版本仓库地址，否则部署到发布版本仓库地址

## 2.5 Snapshot

快照版本往往对应了多个实际的版本：在快照版本的发布过程中，**Maven会自动为构件打上时间戳**

* 例如`2.1-SNAPSHOT`的实际版本为`2.1-20091214.221414-13`，表示2009年12月14日22点14分14秒的第13次构建

当构建含有快照版本依赖的项目时，Maven会去仓库检查更新（由仓库配置的`<updatePolicy>`元素控制），用户也可以使用命令行`-U`参数强制让Maven检查更新：`$mvn clean install -U`

**快照版本应该只在组织内部的项目或模块间依赖使用**，因为这时，组织对于这些快照版本的依赖具有完全的理解及控制权

**项目不应该依赖于任何组织外部的快照版本依赖**，由于快照版本的不稳定性，这样的依赖会造成潜在的风险。也就是说，即使项目构建今天是成功的，由于外部的快照版本依赖实际对应的构件随时可能变化，项目的构建就可能由于这些外部的不受控制的因素而失败

## 2.6 Resolving Dependency from Repository

1. 当依赖的范围是system的时候，Maven直接从本地文件系统解析构件
1. 根据依赖坐标计算仓库路径后，尝试直接从本地仓库寻找构件，如果发现相应构件，则解析成功
1. 在本地仓库不存在相应构件的情况下，如果依赖的版本是显式的发布版本构件，如`1.2`、`2.1-beta-1`等，则遍历所有的远程仓库，发现后，下载并解析使用
1. 如果依赖的版本是RELEASE（最新发布版本）或者LATEST（最新版本，可能是快照版本），则基于更新策略读取所有远程仓库的元数据`groupId/artifactId/maven-metadata.xml`，将其与本地仓库的对应元数据合并后，计算出RELEASE或者LATEST真实的值，然后基于这个真实的值检查本地仓库和远程仓库，如步骤2和3
1. 如果依赖的版本是SNAPSHOT，则基于更新策略读取所有远程仓库的元数据`groupId/artifactId/version/maven-metadata.xml`，将其与本地仓库的对应元数据合并后，得到最新快照版本的值，然后基于该值检查本地仓库，或者从远程仓库下载
1. 如果最后解析得到的构件版本是时间戳格式的快照，如`1.4.1-20091104.121450-121`，则复制其时间戳格式的文件至非时间戳格式，如SNAPSHOT，并使用该非时间戳格式的构件

**当依赖的版本不明晰的时候**，例如RELEASE、LATEST和SNAPSHOT，**Maven就需要基于更新远程仓库的更新策略来检查更新**

1. `<releases><enable>`和`<snapshots><enable>`：只有仓库开启了对于发布版本/快照版本的支持时，才能访问该仓库的发布版本/快照版本的构件信息
1. `<releases>`和`<snapshots>`的子元素`<updatePolicy>`：该元素配置了检查更新的频率，每日、从不、每次构建、自定义时间间隔等
1. 从命令行加入参数`-U`，强制检查更新，使用参数后，Maven就会**忽略**`<updatePolicy>`元素的配置

需要注意的是，在依赖声明中使用LATEST和RELEASE是不推荐的做法，因为Maven随时都可能解析到不同的构件，可能今天LATEST是`1.3.6`，明天就成为`1.4.0-SNAPSHOT`了，**且Maven不会明确告诉用户这样的变化**。这种变化造成构建失败时，发现问题会变得比较困难。RELEASE对应的是最新发布版，还相对可靠，LATEST就非常不可靠了。为此，Maven3不再支持在插件配置中使用LATEST和RELEASE了

## 2.7 Mirror

如果仓库X可以提供仓库Y存储的所有内容，那么就可以认为X是Y的一个镜像。换句话说，任何一个可以从仓库Y获取的构件，都可以从它的镜像中获取。由于地理位置因素，镜像往往能够提供比中央仓库更快的服务

可以在`setting.xml`文件中用`<mirror>`元素配置镜像

* `<mirrorOf>`：仓库的id，所有对该仓库的请求都会转至该镜像
    * `<mirrorOf>*</mirrorOf>`：**匹配所有远程仓库**
    * `<mirrorOf>external:*</mirrorOf>`：匹配所有远程仓库，使用localhost的除外，使用file://协议的除外。也就是说，**匹配所有不在本机上的远程仓库**
    * `<mirrorOf>repo1,repo2</mirrorOf>`：匹配仓库repo1和repo2，使用逗号分隔多个远程仓库
    * `<mirrorOf>*,!repo1</mirrorOf>`：匹配所有远程仓库，repo1除外
* `<id>`：镜像的id，作为镜像仓库的唯一标识
* `<name>`：镜像名称，便于人阅读
* `<url>`：镜像地址

需要注意的是，**镜像仓库**完全**屏蔽**了**被镜像仓库**，当镜像仓库不稳定或者停止服务的时候，Maven仍将无法访问被镜像仓库，因而将无法下载构件

```xml
<settings>
    ...
    <mirrors>
        <mirror>
            <id>mirrorId</id>
            <mirrorOf>repositoryId</mirrorOf>
            <name>Human Readable Name for this Mirror.</name>
            <url>http://my.repository.com/repo/path</url>
        </mirror>
    </mirrors>
    ...
</settings>
```

如果镜像需要认证，则在`settings.xml`中配置一个id与镜像id一致的`<server>`元素即可，与**配置远程仓库的认证**完全一致

## 2.8 Common Repository

1. [Sonatype Nexus](http://repository.sonatype.org/)
1. [MVNrepository](http://mvnrepository.com/)

# 3 Property

## 3.1 Built-in Property

主要有两个常用的内置属性

1. `${basedir}`：表示项目根目录，即包含pom.xml文件的目录
1. `${version}`：表示项目版本

## 3.2 POM Property

用户可以使用该类属性引用POM文件中对应元素的值。例如`${project.artifactId}`就对应了`<project><artifactId>`元素的值，常用的POM属性包括：

1. `${project.build.sourceDirectory}`：项目的主源码目录，默认为`src/main/java/`
1. `${project.build.testSourceDirectory}`：项目的测试源码目录，默认为`/src/test/java/`
1. `${project.build.directory}`：项目构建输出目录，默认为`target/`
1. `${project.build.outputDirectory}`：项目主代码编译输出目录，默认为`target/classes/`
1. `${project.build.testOutputDirectory}`：项目测试代码编译输出目录，默认为`target/test-classes/`
1. `${project.groupId}`：项目的`groupId`
1. `${project.artifactId}`：项目的`artifactId`
1. `${project.version}`：项目的`version`，与`${version}`等价
1. `${project.build.finalName}`：项目打包输出文件的名称，默认为`${project.artifactId}-${project.version}`
1. `${project.basedir}`：当前POM文件所在的路径
1. `${project.parent.basedir}`：父POM文件所在的路径

这些属性都对应了一个POM元素，它们中一些属性的默认值都是在超级POM中定义的

## 3.3 Customized Property

用户可以在POM的`<properties>`元素下自定义Maven属性，例如

```xml
<project>
    ...
    <properties>
        <my.prop>hello</my.prop>
    </properties>
    ...
</project>
```

然后在POM中其他地方使用`${my.prop}`

## 3.4 Setting Property

与POM属性同理，用户使用以`settings.`开头的属性引用`settings.xml`文件中的XML元素的值，例如常用的`${settings.localRepository}`指向用户本地仓库的地址

## 3.5 Java Property

所有Java系统属性都可以使用Maven属性引用，例如`${user.home}`指向了用户目录。用户可以使用`mvn help:system`查看所有Java系统属性

## 3.6 Env Property

所有环境变量都可以使用以`env.`开头的Maven属性引用。例如`${env.JAVA_HOME}`指代了`JAVA_HOME`环境变量的值。用户可以使用`mvn help:system`查看所有环境变量

## 3.7 Tips

### 3.7.1 How to Check Property

* `mvn help:evaluate -Dexpression=os.name`
* `mvn help:evaluate -Dexpression=os.arch`

# 4 Maven Profile

为了能让构建在各个环境下方便地移植，Maven引入了profile的概念。profile能够在构建的时候修改POM的一个子集，或者添加额外的配置元素。用户可以使用很多方式激活profile，以实现构建在不同环境下的移植

## 4.1 Activate Profile

为了尽可能方便用户，Maven支持很多种激活Profile的方式

1. **命令行激活**
1. **settings文件显式激活**
1. **系统属性激活**
1. **操作系统环境激活**
1. **文件存在与否激活**
1. **默认激活**

### 4.1.1 Command Activation

用户可以使用mvn命令行参数`-P`加上profile的id来激活profile，多个id之间以逗号分隔，例如：

* `$mvn clean install -Pdev,test`

### 4.1.2 Settings Activation

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

### 4.1.3 System Property Activation

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

### 4.1.4 OS Activation

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

### 4.1.5 File Activation

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

### 4.1.6 Default Activation

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

需要注意的是，**如果POM中任何一个profile通过以上其他任意一种方式被激活了，所有的默认激活配置都会失效。**

### 4.1.7 Check Activation

如果项目中有很多的profile，它们的激活方式各异，`maven-help-plugin`提供了一个目标帮助用户了解当前激活的profile

* `$mvn help:active-profiles`

`maven-help-plugin`还有另外一个目标用来列出当前所有profile

* `$mvn help:all-profiles`

**此外，如果多个不同的profile对同一个Maven属性都进行了定义，且他们都被激活了，那么在POM文件中位于最后面位置的profile中定义的Maven属性将会在过滤中生效**

## 4.2 Profile Classification

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

# 5 Plugin Lifecycle

## 5.1 Lifecycle Classification

Maven拥有**三套相互独立**的生命周期，分别是

1. `cleean`：其目的是**清理项目**
1. `default`：其目的是**构建项目**
1. `site`：其目的是**建立项目站点**

每个生命周期包含一些阶段(phase)，这些阶段有顺序，并且后面的阶段依赖于前面的阶段，**用户和Maven最直接的交互方式就是调用这些生命周期阶段**

另外，三套生命周期之间是相互独立的，用户可以仅仅调用clean生命周期的某个阶段，或者仅仅调用default生命周期的某个阶段

### 5.1.1 clean

clean生命周期的目的是清理项目，它包含三个阶段：

1. `pre-clean`：执行一些清理前需要完成的工作
1. `clean`：清理上一次构建生成的文件
1. `post-clean`：执行一些清理后需要完成的工作

### 5.1.2 default

default生命周期定义了真正构建时所需要执行的所有步骤，**它是所有生命周期中最核心的部分**，包含如下阶段：

1. `validate`
1. `initialize`
1. `generate-sources`
1. **`process-sources`**：处理项目主资源文件。一般来说，是对`src/main/resources`目录的内容进行变量替换等工作后，复制到项目输出的主classpath目录中
1. `generate-resources`
1. `process-resources`
1. **`compile`**：编译项目的主源码。一般来说，是编译`src/main/java`目录下的Java文件至项目输出的主classpath目录中
1. `process-classes`
1. `generate-test-sources`
1. **`process-test-sources`**：处理项目测试资源文件。一般来说，是对`src/test/resources`目录的内容进行变量替换等工作后，复制到项目输出的测试classpath目录中
1. `generate-test-resources`
1. `process-test-resources`
1. **`test-compile`**：编译项目的测试代码。一般来说，是编译`src/test/java`目录下的Java文件至项目输出的测试classpath目录中
1. `process-test-classes`
1. **`test`**：使用单元测试框架运行测试，测试代码不会被打包或部署
1. `prepare-package`
1. **`package`**：接受编译好的代码，打包成可发布的格式，如JAR、WAR等
1. `pre-integration-test`
1. `integration-test`
1. `post-integration-test`
1. `verify`
1. **`install`**：将包安装到**Maven**本地仓库，供本地其他Maven项目使用
1. **`deploy`**：将最终的包复制到远程仓库，供其他开发人员和Maven项目使用

### 5.1.3 site

1. `pre-site`：执行一些在生成项目站点之前需要完成的工作
1. `site`：生成项目站点文档
1. `post-site`：执行一些在生成项目站点之后需要完成的工作
1. `site-deploy`：将生成的项目站点发布到服务器上

### 5.1.4 Command vs. Lifecycle

从命令行执行Maven任务的最主要方式就是调用Maven的生命周期阶段。需要注意的是，各个生命周期是相互独立的，而一个生命周期的阶段是有前后依赖关系的，下面以一些例子进行说明：

1. `$mvn clean`：该命令调用clean生命周期的clean阶段。实际执行的阶段为clean生命周期的pre-clean和clean阶段
1. `$mvn test`：该命令调用default生命周期的test阶段。实际执行的阶段为default生命周期的validate、initialize等，直至test的所有阶段
1. `$mvn clean install`：该命令调用clean生命周期的clean阶段和default生命周期的install阶段。实际执行的阶段为clean生命周期的pre-clean、clean阶段，以及default生命周期的从validate直至install的所有阶段
1. `$mvn clean deploy site-deploy`：该命令调用clean生命周期的clean阶段、default生命周期的deploy阶段，以及site生命周期的site-deploy阶段。实际执行的阶段为clean生命周期的pre-clean、clean阶段，default生命周期的所有阶段，以及site生命周期的所有阶段
* **Maven中主要的生命周期并不多，而常用的Maven命令实际都是基于这些阶段简单组合而成的**

## 5.2 Target

Maven的核心仅仅定义了**抽象的生命周期**，具体的任务是交由插件完成的，插件以独立的构件形式存在，因此，Maven核心的分发包只有不到3MB大小，**Maven会在需要的时候下载并使用插件**

对于插件本身，**为了能够复用代码，它往往能够完成多个任务**。例如`maven-dependency-plugin`，它能够基于项目依赖做很多事情：

1. 能够分析项目依赖，帮助找出潜在的无用依赖
1. 能够列出项目的依赖树，帮助分析依赖来源
1. 能够列出项目所有已解析的依赖
1. 等等

**为每个这样的功能编写一个独立的插件显然是不可取的，因为这些任务背后有很多可复用的代码**。因此，**这些功能聚集在一个插件里，每个功能就是一个插件目标**

`maven-dependency-plugin`有十多个目标，每个目标对应了一个功能，上述提到的几个功能分别对应的插件目标为：

1. `dependency:analyze`
1. `dependency:tree`
1. `dependency:list`
* **通用写法是：`<插件前缀>:<插件目标>`**

## 5.3 Bind

**Maven的生命周期与插件相互绑定，用以完成实际的构建任务**。具体而言，是生命周期的阶段与插件的目标相互绑定，以完成某个具体的构建任务。例如项目编译这一任务，它对应了default生命周期的compile这一阶段，而`maven-compiler-plugin`这一插件的compile目标能够完成该任务

### 5.3.1 Built-in Bind

为了简化配置，**Maven在核心为一些主要的生命周期阶段绑定了很多插件的目标**，当用户通过命令行调用生命周期阶段的时候，对应的插件目标就会执行相应的任务

**clean生命周期阶段与插件目标的绑定关系**

| 生命周期阶段 | 插件目标 |
|:--|:--|
| pre-clean | \ |
| clean | maven-clean-plugin:clean |
| post-clean | \ |

**site生命周期阶段与插件目标的绑定关系**

| 生命周期阶段 | 插件目标 |
|:--|:--|
| pre-site | \ |
| site | maven-site-plugin:site |
| post-site | \ |
| site-deploy | maven-site-plugin:deploy |

**default生命周期阶段与插件目标的绑定关系**

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

### 5.3.2 Customized Bind

除了内置绑定以外，用户还能够自己选择将某个插件目标绑定到生命周期的某个阶段上，这种自定义绑定方式能让Maven项目在构建过程中执行更多更富特色的任务

一个常见的例子是创建项目的源码jar包，内置的插件绑定关系没有涉及这一任务，因此需要用户自行配置。`maven-source-plugin`可以帮助我们完成该任务，它的jar-no-fork目标能够将项目的主代码打包成jar文件，可以将其绑定到default生命周期的verify阶段上

```xml
<project>
    ...
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
    ...
</project>
```

* 在`<build>`元素下的`<plugins>`子元素中声明插件的使用
* 该例子中用到的是`maven-source-plugin`，其groupId为`org.apache.maven.plugins`，即Maven官方插件的groupId
* 此外，除了基本的插件坐标声明外，还有插件执行配置
    * `<executions>`下每个`<execution>`子元素可以用来配置执行一个任务，在上述例子中
        * 配置了一个`<id>`为attach-sources的任务，就是个名字，随便起
        * **通过`<phrase>`配置，将其绑定到verify生命周期阶段上**
        * **通过`<goals>`配置指定要执行的插件目标**

有时候，即使不通过`<phase>`元素配置生命周期阶段，插件目标也能够绑定到生命周期中，**这是因为很多插件的目标在编写时已经定义了默认的绑定阶段**。可以使用`maven-help-plugin`插件查看指定插件的详细信息，了解插件目标的默认绑定阶段，示例如下：

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
  Bound to phase: package  //可以看到，默认绑定到package
...
```

当插件目标**绑定到不同的生命周期阶段**的时候，其执行顺序会由**生命周期阶段的先后顺序决定**。如果多个目标被**绑定到同一个阶段**，那么**插件声明的先后顺序决定了目标的执行顺序**

## 5.4 Plugin Config

完成了插件和生命周期的绑定后，用户还可以配置插件目标的参数，进一步调整插件目标所执行的任务，以满足项目的需求

### 5.4.1 Command

很多插件目标的参数都支持从命令行配置，用户可以在Maven命令中使用`-D`参数，并伴随一个`参数键=参数值`的形式，来配置插件目标的参数

例如，`maven-surefire-plugin`提供了一个maven.test.skip参数，当其值为true的时候，就会跳过执行测试。于是，在运行命令行的时候，加上如下`-D`参数就能跳过测试：

* `mvn install -Dmaven.test.skip=true`

参数`-D`是Java自带的，其功能是通过命令行设置一个Java系统属性，Maven简单地重用了该参数，在准备插件的时候检查系统属性，便实现了该插件参数的配置

### 5.4.2 POM

并不是所有插件参数都适合从命令行配置，有些参数的值从项目创建到项目发布都不会改变，或者说很少改变，对于这种情况，在POM文件中一次性配置就显然比重复在命令行中输入要方便

用户可以在声明插件的时候，对此插件进行一个全局的配置。也就是说，所有基于该插件目标的任务，都会使用这些配置。例如，我们通常会需要配置`maven-compiler-plugin`，告诉它编译Java 1.5版本的源文件，生成与JVM 1.5兼容的字节码文件

```xml
<project>
    ...
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
    ...
</project>
```

* 这样一来，不管绑定到compile阶段的`maven-compiler-plugin:compile`任务，还是绑定到test-compiler阶段的`maven-compiler-plugin:testCompiler`任务，都能够使用该配置，基于Java 1.8版本进行编译

除了为插件配置全局的参数，用户还可以为某个插件任务配置特定的参数。以`maven-antrun-plugin`为例，它有一个目标run，可以用来在Maven中调用Ant任务。用户将`maven-antrun-plugin:run`绑定到许多生命周期阶段上，再加上不同配置，就可以让Maven在不同的生命周期阶段执行不同的任务（参数不同的同一个目标）

```xml
<project>
    ...
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
    ...
</project>
```

* `maven-antrun-plugin:run`首先与validate阶段绑定，从而构成一个id为ant-validate的任务，输出一段文字到命令行
* 插件全局配置中的`<configuration>`元素位于`<plugin>`元素下面，而这里的`<configuration>`元素则位于`<execution>`元素下，表示这是特定任务的配置，而非插件整体的配置
* 第二个任务的id为ant-verify，绑定到了verify阶段，输出一段文字到命令行

## 5.5 Get Plugin Information

Maven插件非常多，而其中大部分没有完善的文档，因此使用正确的插件并进行正确的配置，并不是一件容易的事情

### 5.5.1 Online

**基本上所有主要的插件都来自Apache和Codehaus**。由于Maven本身属于Apache软件基金会的，因此它有很多官方的插件，详细的列表参见[Available Plugins](https://maven.apache.org/plugins/index.html)

虽然并非所有插件都提供了完善的文档，但一些核心插件的文档还是非常丰富的。例如`maven-surefire-plugin`，详见[Maven Surefire Plugin](https://maven.apache.org/surefire/maven-surefire-plugin/)

### 5.5.2 maven-help-plugin

除了访问在线的插件文档之外，还可以借助`maven-help-plugin`来获取插件的详细信息，例如：`mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin:2.1`

* 这里执行的是`maven-help-plugin`的describe目标，在参数plugin中输入需要描述插件的groupId、artifactId和version

可以省去版本信息，让Maven自动获取最新版本来进行表述，例如：`mvn help:describe -Dplugin=org.apache.maven.plugins:maven-compiler-plugin`

进一步简化，可以使用插件目标前缀替换坐标，例如`mvn help:describe -Dplugin=compiler`

如果想让`maven-help-plugin`输出更详细的信息，可以加上detail参数，例如`mvn help:describe -Dplugin=compiler -Ddetail`

## 5.6 Use Plugin From Command

在命令行中运行`mvn -h`可以显示命令帮助，基本用法如下

* `usage: mvn [options] [<goal(s)>] [<phase(s)>]`

除了选项options之外，mvn命令后面可以添加一个或者多个goal和phase，它们分别是指插件目标和生命周期阶段

我们可以通过mvn命令激活生命周期阶段，从而执行那些绑定在生命周期阶段上的插件目标。**但Maven还支持直接从命令行调用插件目标**。Maven支持这种方式是因为**有些任务不适合绑定在生命周期上**，例如`maven-help-plugin:describe`，我们不需要在构建项目的时候去描述插件信息，又如`maven-dependency-plugin:tree`，我们也不需要在构建项目的时候去显示依赖树。**因此这些插件目标应该通过如下方式使用**：

* `mvn help:describe -Dplugin=compiler`
* `mvn dependency:tree`

这里产生了一个问题，describe是`maven-help-plugin`的目标，但是冒号前面的help既不是groupId也不是artifactId

回答上述问题之前，先尝试如下命令

* `mvn org.apache.maven.plugins:maven-help-plugin:2.2:describe -Dplugin=compiler`
* `mvn org.apache.maven.plugins:maven-dependency-plugin:2.1:tree`

上述两条命令与之前两条命令是一样的，但显然前面的那种更简洁，更容易记忆和使用。为了达到该目的，**Maven引入了目标前缀的概念**，help是`maven-help-plugin`的目标前缀，dependency是`maven-dependency-plugin`的目标前缀。有了目标前缀，Maven就能找到对应的artifactId。**不过除了artifactId，Maven还需要groupId和version才能精确定位到某个插件，下一节中详细解释**

## 5.7 Plugin Resolution Mechanism

为了方便用户使用和配置插件，**Maven不需要用户提供完整的插件坐标信息**，就可以解析得到正确的插件，Maven的这一特性是一把双刃剑，虽然简化了插件的使用和配置，可一旦插件的行为出现异常，用户就很难快速定位到出问题的插件构件

### 5.7.1 Plugin Repository

**与依赖构件一样，插件构件同样基于坐标存储在Maven仓库中**。在需要的时候，Maven会从本地仓库寻找插件，如果不存在，则从远程仓库查找。找到插件之后，再下载到本地仓库使用

值得一提的是，**Maven会区别对待依赖的远程仓库和插件的远程仓库**

* 当Maven需要的依赖在本地仓库不存在时，它会去所配置的远程仓库查找
* 当Maven需要的插件在本地仓库不存在时，它就不会去这些（可能是指自己设定的仓库，对于在中央仓库的核心插件而言，还是会查找然后下载到本地的）远程仓库查找

插件的远程仓库使用<pluginRepositories>和<pluginRepository>配置

### 5.7.2 Default groupId

在POM中配置插件的时候，如果该插件是Maven的官方插件，即`org.apache.maven.plugins`，就可以省略groupId的配置。**不建议这样使用，会让人感到费解**

### 5.7.3 Version Resolution

为了简化插件的配置和使用，在用户没有提供插件版本的情况下，Maven会自动解析插件版本

Maven在超级POM中为所有核心插件设定了版本，超级POM是所有Maven项目的父POM，所有项目都继承了这个超级POM的配置，因此，即使用户不加任何配置，Maven使用核心插件的时候，它们的版本已经确定了。这些插件包括`maven-clean-plugin`、`maven-compiler-plugin`、`maven-surefire-plugin`

当用户使用某个非核心插件且没有声明版本的时候，Maven会将版本解析为所有可用仓库中的稳定版本

依赖Maven解析插件版本其实是不推荐的做法，会导致潜在的不稳定性。**因此使用插件的时候，应该一直显式地设定版本**，这也解释了Maven为什么要在超级POM为核心插件设定版本

### 5.7.4 Plugin Prefix Match

mvn命令行支持使用插件前缀来简化插件的使用，**插件前缀与groupId:artifactid是一一对应的，这种匹配关系存储在仓库元数据中**，这里的仓库元数据为`groupId/maven-metadata.xml`，这里的`groupId`是指默认的`org.apache.maven.plugins`和`org.codehaus.mojo`，也可以通过配置`settings.xml`让Maven检查其他`groupId`上的插件仓库元数据

```xml
<settings>
    ...
    <pluginGroups>
        <pluginGroup>com.your.plugins</pluginGroup>
    </pluginGroups>
    ...
</settings>
```

* 基于该配置，Maven就不仅仅会检查`org/apache/maven/plugins/maven-metadata.xml`和`org/codehaus/mojo/maven-metadata.xml`，还会检查`com/your/plugins/maven-metadata.xml`

当Maven解析到`dependency:tree`这样的命令后，首先基于默认的`groupId`归并所有插件仓库的元数据`org/apache/maven/plugins/maven-metadata.xml`，然后检查归并后的元数据，找到对应的`artifactId`为`maven-dependency-plugin`，然后结合当前元数据的`groupId`，即`org.apache.maven.plugins`。最后使用前一小结的方法解析`version`，这时就得到了完整的插件坐标。如果`org/apache/maven/plugins/maven-metadata.xml`没有记录该插件前缀，则接着检查其他`groupId`下的元数据，若都找不到，则报错

# 6 Reference

* 《Maven实战》

