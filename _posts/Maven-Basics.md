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

# 1 坐标和依赖

## 1.1 坐标详解

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

## 1.2 依赖的配置

根元素`<project>`下的`<dependencies>`元素可以包含一个或多个`<dependency>`元素，以声明一个或者多个项目依赖。每个依赖可以包含的元素详细解释如下：

1. `groupId、artifactId、version`：依赖的基本坐标，**对于任何一个依赖来说，基本坐标是最重要的**
1. `type`：依赖类型，对应于项目坐标定义的`packaging`。大部分情况下，该元素不必声明，其默认值为`jar`
1. `scope`：依赖的范围
1. `optional`：标记依赖是否可选
1. `exclusions`：用来排除传递性依赖

## 1.3 依赖范围

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

## 1.4 传递性依赖

Maven会解析各个直接依赖的POM，将哪些必要的间接依赖，以传递性依赖的形式引入到当前项目中

| 传递性依赖范围 | compile | test  | provided  | runtime  |
|:--|:--|:--|:--|:--|
| compile | compile | \ | \ | runtime |
| test | test | \ | \ | test |
| provided | provided | \ | provided | provided |
| runtime | runtime | \ | \ | runtime |

## 1.5 依赖调解

Maven引入的传递性依赖机制，一方面大大简化和方便了依赖声明，另一方面，大部分情况下我们只需要关心项目的直接依赖时什么，而不同考虑这些依赖会引入什么传递性依赖

但有时候，当传递性依赖造成问题的时候，我们就需要清楚地知道该传递性依赖是从哪条依赖路径引入的。例如，`A->B->C->X(1.0)`、`A->D->X(2.0)`，X是A的传递性依赖，但是两条路径上有两个版本的X，那么哪个X会被Maven解析使用呢

* Maven依赖调解的第一原则是：路径最近者优先，在上述例子中，X(1.0)的路径长度为3，而X(2.0)的路径长度为2，因此X(2.0)会被解析使用
* Maven定义了依赖调解的第二原则：第一声明者优先，即在POM中依赖声明的顺序决定了谁会被解析使用，顺序最靠前的那个依赖优胜

## 1.6 可选依赖

假设有这样一个依赖关系，项目A依赖项目B，项目B依赖项目X和Y，B对于X和Y的依赖都是可选依赖，**于是X和Y不会对A有任何影响**

* A->B
* B->X(可选)
* B->Y(可选)

为什么有这样的需求呢？可能项目B实现了两个特性，其中的特性一依赖于X，特性二依赖于Y，且这两个特性是互斥的，用户不可能同时使用两个特性

由于可选依赖不会被传递，**因此A必须显式声明依赖X或依赖Y**

在理想情况下，是**不应该**使用可选依赖的，在面向对象设计中，有一个**单一职责性原则**，意味着一个类应该只有一项职责，而不是糅合太多的功能。**而使用可选依赖的原因是某一个项目实现了多个特性**，违背了单一职责性原则。因此应该将这个项目拆分成多个职责单一的项目，这样一来就不需要使用可选依赖了

## 1.7 排除依赖

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

## 1.8 归类依赖

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

## 1.9 maven-dependency-plugin插件

1. `$mvn dependency:list`
1. `$mvn dependency:tree`
1. `$mvn dependency:analyze`

# 2 仓库

在Maven世界中，任何一个依赖、插件或者项目构建的输出，都可以称为**构件**

在**不使用**Maven的那些项目中，往往能发现命名为lib/的目录，各个项目lib/下的内容存在**大量的重复**

得益于坐标机制，任何Maven项目使用任何一个构件的方式都是完全相同的。在此基础之上，Maven可以在某个位置**统一存储**所有Maven项目共享的构件，这个统一的位置就是**仓库**

实际的Maven项目将不再各自存储其依赖文件，它们只需要声明这些依赖的坐标，在需要的时候，Maven会自动根据坐标找到仓库中的构件，并使用它们

## 2.1 仓库的分类

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

## 2.2 本地仓库

一般来说，Maven项目目录下，没有诸如/lib这样用来存放依赖文件的目录。当Maven在执行编译或测试时，如果需要使用依赖文件，它**总是基于坐标使用本地仓库的依赖文件**

默认情况下，无论在Windows上还是Linux上，每个用户在自己的用户目录下都有一个路径为`.m2/repository/的仓库目录`

若要自定义本地仓库地址，可以编辑`~/.m2/settings.xml`，设置`<localRepository>`元素的值即可。注意到，`~/.m2/settings.xml`文件**默认是不存在**的，**用户需要从Maven安装目录复制`$MAVEN_HOME/conf/settings.xml`文件**，然后再进行编辑

## 2.3 远程仓库

安装好Maven后，如果不执行任何Maven命令，本地仓库目录是不存在的。当用户输入第一条Maven命令后，Maven才会创建本地仓库，然后根据配置和需要，**从远程仓库下载构件**至本地仓库

对于Maven来说，每个用户只有一个本地仓库（书房），但可以配置访问很多远程仓库（书店）

### 2.3.1 中央仓库

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

### 2.3.2 私服

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

## 2.4 远程仓库的配置

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

### 2.4.1 远程仓库的认证

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

### 2.4.2 部署至远程仓库

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

## 2.5 快照版本

快照版本往往对应了多个实际的版本：在快照版本的发布过程中，**Maven会自动为构件打上时间戳**

* 例如`2.1-SNAPSHOT`的实际版本为`2.1-20091214.221414-13`，表示2009年12月14日22点14分14秒的第13次构建

当构建含有快照版本依赖的项目时，Maven会去仓库检查更新（由仓库配置的`<updatePolicy>`元素控制），用户也可以使用命令行`-U`参数强制让Maven检查更新：`$mvn clean install -U`

**快照版本应该只在组织内部的项目或模块间依赖使用**，因为这时，组织对于这些快照版本的依赖具有完全的理解及控制权

**项目不应该依赖于任何组织外部的快照版本依赖**，由于快照版本的不稳定性，这样的依赖会造成潜在的风险。也就是说，即使项目构建今天是成功的，由于外部的快照版本依赖实际对应的构件随时可能变化，项目的构建就可能由于这些外部的不受控制的因素而失败

## 2.6 从仓库解析依赖的机制

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

## 2.7 镜像

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

## 2.8 仓库搜索服务

1. [Sonatype Nexus](http://repository.sonatype.org/)
1. [MVNrepository](http://mvnrepository.com/)

# 3 参考

* 《Maven实战》

