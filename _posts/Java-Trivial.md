---
title: Java-Trivial
date: 2018-01-17 09:30:44
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- Command Line Tool
---

**阅读更多**

<!--more-->

# 1 Install JDK

From [Java Downloads](https://www.oracle.com/java/technologies/downloads/), you can find `JDK 22`, `JDK 21`, `JDK 17`, and even `JDK 8`

* For `JDK 8`
    ```sh
    # you need to login in first, can you can download, it is stupid
    tar -zxvf jdk-8u411-linux-x64.tar.gz -C /usr/lib/jvm
    ```

* For `JDK 17`
    ```sh
    wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz
    tar -zxvf jdk-17_linux-x64_bin.tar.gz -C /usr/lib/jvm
    ```

* For `JDK 22`
    ```sh
    wget https://download.oracle.com/java/22/latest/jdk-22_linux-x64_bin.tar.gz
    tar -zxvf jdk-22_linux-x64_bin.tar.gz -C /usr/lib/jvm
    ```

# 2 Builtin

## 2.1 java

### 2.1.1 Execute

**Use `-classpath` Options:**

* `java -classpath /path/aaa.jar com.liuyehcf.demo.MyMain arg1 arg2`
* `java -classpath /path/aaa.jar:/path/bbb.jar com.liuyehcf.demo.MyMain arg1 arg2`
* `java -classpath "/path/*" com.liuyehcf.demo.MyMain arg1 arg2`
* `java -classpath "/path/*":"/path2/*" com.liuyehcf.demo.MyMain arg1 arg2`

**Use `-jar`: The jar file must has record Main class in `META-INF/MANIFEST.MF`**

* `java -jar /path/aaa.jar arg1 arg2`

**Use `-Djava.ext.dirs=` Options:**

* `java -Djava.ext.dirs=/path/jar_dir/ com.liuyehcf.demo.MyMain arg1 arg2`

### 2.1.2 Enable Debug

**Java 1.4 及更早版本: `-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=*:8000,suspend=n`**

* `-Xrunjdwp`：启动`JDWP, Java debug wire protocol`调试器
* `transport=dt_socket`：使用套接字作为传输方式
* `server=y`：作为调试服务器运行
* `address=*:8000`：在所有网络接口上监听`8000`端口。同`0.0.0.0`
    * `8000`
    * `127.0.0.1:8000`
    * `0.0.0.0:8000`
* `suspend=n`：`JVM`启动后不挂起，立即运行

**Java 1.5 (JDK 5): `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000`**

* `-agentlib:jdwp`：使用`jdwp`库启动`JDWP`调试器，且不需要额外指定`-Xdebug`
* `transport=dt_socket`：使用套接字作为传输方式
* `server=y`：作为调试服务器运行
* `suspend=n`：`JVM`启动后不挂起，立即运行
* `address=*:8000`：在所有网络接口上监听`8000`端口。同`0.0.0.0`

## 2.2 jps

列出正在运行的虚拟机进程，并显示虚拟机执行主类名称以及这些进程的**本地虚拟机唯一`ID(Local Virtual Machine Identifier, LVMID)`**

虽然功能比较单一，但它是使用频率最高的`JDK`命令行工具，因为其他`JDK`工具大多需要输入它查询到的`LVMID`来确定要监控的是哪一个虚拟机进程

**对本地虚拟机来说，`LVMID`与操作系统的进程`ID(Process Identifier，PID)`是一致的**，使用`Windows`的任务管理器或者`UNIX`的`ps`命令也可以查询到虚拟机进程的`LVMID`，如果同时启动了多个虚拟机进程，无法根据进程名称定位时，就只能依赖`jps`命令显示主类的功能才能区分了

**格式：**

* `jps [options] [hostid]`

**参数说明：**

* `-q`：只输出`LVMID`，省略主类的名称
* `-m`：输出虚拟机进程启动时传递给主类`main()`函数的参数
* `-l`：输出主类的全名，如果进程执行的是`Jar`包，输出`Jar`路径
* `-v`：输出虚拟机进程启动时的`JVM`参数

## 2.3 jstat

`jstat(JVM Statistics Monitoring Tool)`是用于监视虚拟机各种运行状态信息的命令行工具

`jstat`可以显示本地或者远程虚拟机进程中的类装载、内存、垃圾收集、`JIT`编译等运行数据，在没有`GUI`图形界面，只提供了纯文本控制台环境的服务器上，它将是运行期定位虚拟机性能问题的首选工具

**格式：**

* `jstat [option <vmid> [interval [s|ms] [count] ] ]`

**参数说明：**

* 如果是本地虚拟机进程，`VMID`与`LVMID`是一致的，如果是远程虚拟机进程，那`VMID`的格式应当是
    * `[protocol:] [//] lvmid [@hostname[:port]/servername]`
* `interval`和`count`代表查询间隔和次数，如果省略这两个参数，说明只查询一次
    * `jstat -gc 2764 250 20`：每`250`毫秒查询一次进程`2764`垃圾收集情况，一共查询`20`次
* `-class`：监视类装载、卸载数量、总空间以及类装载所耗费的时间
* `-gc`：监视`Java`堆状况，包括`Eden`区、两个`survivor`区、老年代、永久代等的容量、已用空间、`GC`时间合计等信息
* `-gccapacity`：监视内容与`-gc`基本相同，但输出主要关注`Java`堆各个区域使用到的最大、最小空间
* `-gcutil`：监视内容与`-gc`基本相同，但输出主要关注已使用空间占总空间的百分比
* `-gccause`：与`-gcutil`功能一样，但是会额外输出导致上一次`GC`产生的原因
* `-gcnew`：监视新生代`GC`状况
* `-gcnewcapacity`：监视内容与`-gcnew`基本相同，输出主要关注使用到的最大、最小空间
* `-gcold`：监视老年代`GC`状况
* `-gcoldcapacity`：监视内容与`-gcold`基本相同，输出主要关注使用到的最大、最小空间
* `-gcpermcapacity`：输出永久代使用到的最大、最小空间
* `-compiler`：输出`JIT`编译器编译过的方法、耗时等信息
* `-printcompilation`：输出已经被`JIT`编译的方法

**输出内容意义：**

* `E`：新生代区`Eden`
* `S0\S1`：`Survivor0`、`Survivor1`这两个`Survivor`区
* `O`：老年代`Old`
* `P`：永久代`Permanet`
* `YGC`：`Young GC`
* `YGCT`：`Yount GC Time`
* `FGC`：`Full GC`
* `FTCG`：`Full GC Time`
* `GCT`：`Minor GC`与`Full GC`总耗时

**示例：**

* **`jstat -gc <vmid> 1000 1000`：查看`JVM`内存使用**
* **`jstat -gcutil <vmid> 1000 1000`：查看`JVM`内存使用（百分比）**

## 2.4 jinfo

`jinfo(Configuration Info for Java)`的作用是实时地查看和调整虚拟机各项参数

使用`jps`命令的`-v`参数可以查看虚拟机启动时显示指定的参数列表，**但如果想知道未被显式指定的参数的系统默认值，除了去查找资料外，就只能用`jinfo`的`-flag`选项进行查询**

如果`JDK1.6`或者以上版本，可以使用`-XX:+PrintFlagsFinal`查看参数默认值

`jinfo`还可以使用`-sysprops`选项把虚拟机进程的`System.getProperties()`的内容打印出来

**格式：**

* `jinfo [option] <vmid>`

**参数说明**

* `-flag`：显式默认值
    * `jinfo -flags 1874`：显式所有项的默认值
    * `jinfo -flag CICompilerCount 1874`：显示指定项的默认值
* `-sysprops`：把虚拟机进程的System.getProperties()的内容打印出来

## 2.5 jmap

`jmap(Memory Map for Java)`命令用于生成堆转储快照(一般称为`heapdump`或`dump`文件)

`jmap`的作用并不仅仅为了获取`dump`文件，它还可以查询`finalize`执行队列、`Java`堆和永久代的详细信息，如空间使用率、当前用的是哪种收集器等

**格式：**

* `jmap [option] <vmid>`

**参数说明：**

* `-dump`：生成Java堆转储快照，格式为`-dump:[live, ]format=b, file=<filename>`，其中`live`子参数说明是否只`dump`出存活对象
* `-finalizerinfo`：显示在`F-Queue`中等待`Finalizer`线程执行`finalize`方法的对象
* `-heap`：显示`Java`堆详细信息，如使用哪种回收器，参数配置，分代状况等
* `-histo`：显示堆中对象统计信息，包括类、实例数量、合计容量
* `-permstat`：以`ClassLoader`为统计口径显示永久代内存状态
* `-F`：当虚拟机进程对`-dump`选项没有响应时，可使用这个选项强制生成`dump`快照

**示例**

* `jmap -dump:format=b,file=<dump_文件名> <java进程号>`：`dump`进程所有对象的堆栈
* `jmap -dump:live,format=b,file=<dump_文件名> <java进程号>`：`dump`进程中存活对象的堆栈，会触发`full gc`
* `jmap -histo:live <vmid>`：触发`full gc`
* `jmap -histo <vmid> | sort -k 2 -g -r | less`：统计堆栈中对象的内存信息，按照对象实例个数降序打印
* `jmap -histo <vmid> | sort -k 3 -g -r | less`：统计堆栈中对象的内存信息，按照对象占用内存大小降序打印

## 2.6 jhat

`jhat`是虚拟机堆转储快照分析工具

`Sun JDK`提供`jhat(JVM Heap Analysis Tool)`命令与`jmap`搭配使用，来分析`jmap`生成的堆转储快照

`jhat`内置了一个微型的`HTTP/HTML`服务器，生成`dump`文件的分析结果后，可以在浏览器中查看

不过在实际工作中，除非真的没有别的工具可用，否则一般不会直接使用`jhat`命令来分析`dump`文件，原因如下

* 一般不会再部署应用程序的服务器上直接分析`dump`文件，即使可以这样做，也会尽量将`dump`文件复制到其他机器上进行分析，因为分析工作是一个耗时而且消耗硬件资源的过程，既然都要在其他机器上进行，就没有必要受到命令工具的限制了
* `jhat`的分析功能相对来说比较简陋，`VisualVM`，以及专业用于分析`dump`文件的`Eclipse Memory Analyzer`、`IBM HeapAnalyzer`等工具，都能实现比`jhat`更强大更专业的分析功能

**配合jmap的例子**

1. `jmap -dump:format=b,file=dump.bin 1874`
    * 文件相对路径为`dump.bin`
    * `vmid`为1874
1. `jhat dump.bin`
    * 在接下来的输出中会指定端口`7000`
    * 在浏览器中键入`http://localhost:7000/`就可以看到分析结果，拉到最下面，包含如下导航：
        * All classes including platform
        * Show all members of the rootset
        * Show instance counts for all classes (including platform)
        * Show instance counts for all classes (excluding platform)
        * Show heap histogram
        * Show finalizer summary
        * Execute Object Query Language (OQL) query

## 2.7 jstack

`jstack`是`Java`堆栈跟踪工具

`jstack(Stack Trace for Java)`命令用于生成虚拟机当前时刻的线程快照(一般称为`trheaddump`或者`javacore`文件)

线程快照就是当前虚拟机每一条线程正在执行的方法堆栈的集合，生成线程快照的主要目的是定位线程出现长时间停顿的原因，如线程死锁、死循环、请求外部资源导致的长时间等待都是导致线程长时间停顿的常见原因

线程出现停顿的时候通过`jstack`来查看各个线程的调用堆栈，就可以知道没有响应的线程到底在后台做了什么，或者等待什么资源

**格式：**

* `jstack [option] <vmid>`

**参数说明：**

* `-F`：当正常输出的请求不被响应时，强制输出线程堆栈
* `-l`：除堆栈外，显示关于锁的附加信息
* `-m`：如果调用本地方法的话，可以显示C/C++的堆栈

**在JDK1.5中，java.lang.Thread类新增一个getAllStackTraces()方法用于获取虚拟机中所有线程的StackTraceElement对象，使用这个对象可以通过简单的几行代码就能完成jstack的大部分功能，在实际项目中不妨调用这个方法做个管理员页面，可以随时使用浏览器来查看线程堆栈**

## 2.8 java_home

**`/usr/libexec/java_home -V`：用于查看本机上所有版本java的安装目录**

## 2.9 jar

**制作归档文件：：`jar cvf xxx.jar -C ${target_dir1} ${dir_or_file1} -C ${target_dir2} ${dir_or_file2} ...`**

* **注意`-C`只对后面一个参数有效**
* `jar cvf xxx.jar .`
* `jar cvf xxx.jar org com/test/A.class`
* `jar cvf xxx.jar -C classes org -C classes com`

**解压归档文件：`jar xvf xxx.jar`**

* 不支持解压到指定目录

**查看归档文件：`jar tf xxx.jar`**

### 2.9.1 JAR File Specification

[JAR File Specification](https://docs.oracle.com/en/java/javase/17/docs/specs/jar/jar.html)

* The META-INF directory
    * `service`: Service Provider Interface, SPI
    * `MANIFEST.MF`: Main-Class
* ...

## 2.10 jdb

Debug tool like `gdb`

# 3 Monitor

## 3.1 Arthas

[Arthas](https://github.com/alibaba/arthas)

[commands](https://arthas.aliyun.com/doc/commands.html)

## 3.2 VisualVM

[All-in-One Java Troubleshooting Tool](https://visualvm.github.io/)

### 3.2.1 Shallow Size vs. Retained Size

`Shallow Size`: This is the amount of memory allocated to store the object itself, not including the objects it references. This includes the memory used by the object's fields (for primitive types) and the memory used to store the references to other objects (for reference types). It does not include the memory used by the objects those references point to. Tools like VisualVM generally show the shallow size by default.

`Retained Size`: This is the total amount of memory that would be freed if the object were garbage collected. This includes the shallow size of the object itself plus the shallow size of any objects that are exclusively referenced by this object (i.e., objects that would be garbage collected if this object were). The retained size provides a more complete picture of the "true" memory impact of an object but can be more complex to calculate. Some profiling tools provide this information, but it may require additional analysis or plugins.

# 4 Java Decompiler

[Java Decompilers](http://www.javadecompilers.com/)

## 4.1 CFR

[Class File Reader, CFR](https://github.com/leibnitz27/cfr): Another Java Decompiler, it will decompile modern Java features - including much of Java `9`, `12` & `14`, but is written entirely in Java `6`, so will work anywhere!

```sh
wget https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar
java -jar cfr-0.152.jar xxx.class
```

## 4.2 JD

[Java Decompiler project, JD Project](http://java-decompiler.github.io/): Aims to develop tools in order to decompile and analyze Java 5 “byte code” and the later versions.

```sh
wget https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.jar
java -jar jd-gui-1.6.6.jar
```

## 4.3 JAD

[JAD](http://www.javadecompilers.com/jad): It is dead, and yes, it was not Open Source anyway。

## 4.4 Fernflower

[Fernflower](https://github.com/JetBrains/intellij-community/tree/master/plugins/java-decompiler/engine): The first actually working analytical decompiler for Java and probably for a high-level programming language in general.

* [Unofficial mirror of FernFlower](https://github.com/fesh0r/fernflower)
* Requires Java version >= 17

```sh
git clone https://github.com/fesh0r/fernflower.git
cd fernflower
gradle build

java -jar build/libs/fernflower.jar -dgs=true /path_source_dir /path_target_dir
```

# 5 Java Environment Manager

## 5.1 jenv

[jenv](https://github.com/jenv/jenv)

* For mac
    ```sh
    brew install jenv
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc

    # Export JAVA_HOME path
    jenv enable-plugin export

    # Diagnosis
    jenv doctor

    # Add java version
    jenv add /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
    jenv add /Library/Java/JavaVirtualMachines/jdk-22.jdk/Contents/Home

    # List all available versions
    jenv versions

    # Switch to specific version
    # shell has highest priority(`JENV_VERSION`) and global has lowest priority. local refers to current directory(`.java-version`)
    jenv global 17
    jenv local 22
    jenv shell 22
    ```

* For Linux
    ```sh
    git clone https://github.com/jenv/jenv.git ~/.jenv
    echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(jenv init -)"' >> ~/.zshrc

    # Export JAVA_HOME path
    jenv enable-plugin export

    # Diagnosis
    jenv doctor

    # Add java version
    jenv add /usr/lib/jvm/java-8-openjdk-amd64
    jenv add /usr/lib/jvm/java-17-openjdk-amd64

    # List all available versions
    jenv versions

    # Switch to specific version
    # shell has highest priority(`JENV_VERSION`) and global has lowest priority. local refers to current directory(`.java-version`)
    jenv global 17
    jenv local 1.8
    jenv shell 1.8
    ```

**Tips:**

* `jenv global/local/shell --unset`
* For x86 container running on `OSX` with M-chips, the default `jenv init -` will encounter strange problem, because the shell command turns out to be `/run/rosetta/rosetta /usr/local/bin/zsh zsh`, rather than `zsh` in most cases. And the shell parse step (list as below) in `~/.jenv/libexec/jenv-init` cannot work correctly. **So the solution is using `jenv init - zsh` instead of `jenv init -` by specifying the shell command to skip the pass step**
    ```sh
    shell="$1"
    if [ -z "$shell" ]; then
    shell="$(ps -p "$PPID" -o 'args=' 2>/dev/null || true)"
    shell="${shell%% *}"
    shell="${shell##-}"
    shell="${shell:-$SHELL}"
    shell="${shell##*/}"
    fi
    ```

* How to list all versions: `jenv versions` can only listed all the valid versions
    * `ls ~/.jenv/versions`

# 6 Class Isolation

Here's an example of how to use module class loader to create a isolated environment.

* `module1` and `module2` both have the log dependencies.
* Each module will init its own log context in an isolated environment.

The structure of the project:

```
.
├── common
│   ├── pom.xml
│   └── src
│       └── main
│           └── java
│               └── org
│                   └── liuyehcf
│                       └── moduleisolation
│                           ├── TestMain.java
│                           └── loader
│                               ├── ClassFactory.java
│                               └── ModuleClassLoader.java
├── module1
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── liuyehcf
│           │           └── moduleisolation
│           │               └── module1
│           │                   ├── Function.java
│           │                   └── ModuleClassFactory.java
│           └── resources
│               └── module1_log4j2.xml
├── module2
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── liuyehcf
│           │           └── moduleisolation
│           │               └── module2
│           │                   ├── Function.java
│           │                   └── ModuleClassFactory.java
│           └── resources
│               └── module2_log4j2.xml
└── pom.xml
```

```sh
mkdir class_isolation_demo
cd class_isolation_demo

mkdir -p common/src/main/java/org/liuyehcf/moduleisolation/loader
mkdir -p module1/src/main/java/org/liuyehcf/moduleisolation/module1
mkdir -p module1/src/main/resources
mkdir -p module2/src/main/java/org/liuyehcf/moduleisolation/module2
mkdir -p module2/src/main/resources

cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>ModuleIsolcation</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>pom</packaging>
    <modules>
        <module>common</module>
        <module>module1</module>
        <module>module2</module>
    </modules>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <compiler-plugin.version>3.8.1</compiler-plugin.version>
        <shade-plugin.version>3.2.4</shade-plugin.version>
    </properties>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <version>${compiler-plugin.version}</version>
                    <configuration>
                        <source>${maven.compiler.source}</source>
                        <target>${maven.compiler.target}</target>
                    </configuration>
                </plugin>
                <plugin>
                    <groupId>net.revelc.code.formatter</groupId>
                    <artifactId>formatter-maven-plugin</artifactId>
                </plugin>
                <plugin>
                    <groupId>org.apache.maven.plugins</groupId>
                    <artifactId>maven-shade-plugin</artifactId>
                    <version>${shade-plugin.version}</version>
                    <executions>
                        <execution>
                            <configuration>
                                <filters>
                                    <filter>
                                        <artifact>*:*</artifact>
                                        <excludes>
                                            <exclude>META-INF/*.SF</exclude>
                                            <exclude>META-INF/*.DSA</exclude>
                                            <exclude>META-INF/*.RSA</exclude>
                                        </excludes>
                                    </filter>
                                </filters>
                                <finalName>${project.build.finalName}-jar-with-dependencies</finalName>
                            </configuration>
                            <goals>
                                <goal>shade</goal>
                            </goals>
                            <phase>package</phase>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
EOF

cat > common/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.liuyehcf</groupId>
        <artifactId>ModuleIsolcation</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>

    <artifactId>common</artifactId>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <log4j.version>2.17.1</log4j.version>
        <slf4j.version>1.7.32</slf4j.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>${slf4j.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-slf4j-impl</artifactId>
            <version>${log4j.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-api</artifactId>
            <version>${log4j.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.logging.log4j</groupId>
            <artifactId>log4j-core</artifactId>
            <version>${log4j.version}</version>
        </dependency>
    </dependencies>
</project>
EOF

cat > common/src/main/java/org/liuyehcf/moduleisolation/TestMain.java << 'EOF'
package org.liuyehcf.moduleisolation;

import org.liuyehcf.moduleisolation.loader.ClassFactory;

import java.lang.reflect.Method;

public class TestMain {
    public static void main(String[] args) throws Exception {
        runModule("module1");
        runModule("module2");
    }

    private static void runModule(String moduleName) throws Exception {
        Class<?> classFactoryClass = ClassLoader.getSystemClassLoader().loadClass(
                String.format("org.liuyehcf.moduleisolation.%s.ModuleClassFactory", moduleName));
        ClassFactory classFactory = (ClassFactory) classFactoryClass.newInstance();
        classFactory.initModuleContext();

        Class<?> clazz = classFactory.getClass(
                String.format("org.liuyehcf.moduleisolation.%s.Function", moduleName));
        Method run = clazz.getMethod("run");
        Object function = clazz.newInstance();
        run.invoke(function);
    }
}
EOF

cat > common/src/main/java/org/liuyehcf/moduleisolation/loader/ClassFactory.java << 'EOF'
package org.liuyehcf.moduleisolation.loader;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.core.LoggerContext;
import org.apache.logging.log4j.core.config.Configuration;
import org.apache.logging.log4j.core.config.ConfigurationSource;
import org.apache.logging.log4j.core.config.xml.XmlConfiguration;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.URL;

public abstract class ClassFactory {

    protected ModuleClassLoader classLoader;

    protected ClassFactory() {
        try {
            classLoader = ModuleClassLoader.create(getModuleName());
        } catch (Exception e) {
            rethrow(e);
        }
    }

    @SuppressWarnings("unchecked")
    public static <T extends Throwable> void rethrow(Throwable t) throws T {
        throw (T) t;
    }

    /**
     * Name of module
     */
    protected abstract String getModuleName();

    /**
     * Entry to get class of current module
     */
    public final Class<?> getClass(String className) throws ClassNotFoundException {
        return classLoader.loadClass(className);
    }

    /**
     * Initialize the isolated context of this module
     */
    public final void initModuleContext() throws Exception {
        initLog4j2();
    }

    /**
     * This method is used to initialize the isolated context of log4j2, avoiding conflict between
     * different modules.
     */
    private void initLog4j2() throws Exception {
        Class<?> clazz = getClass(
                "org.liuyehcf.moduleisolation.loader.ClassFactory$Log4jContextInitializer");
        clazz.getMethod("init", String.class).invoke(null, getModuleName());
    }

    public static class Log4jContextInitializer {
        public static void init(String moduleName) throws IOException {
            URL resource = Log4jContextInitializer.class.getClassLoader()
                    .getResource(String.format("%s_log4j2.xml", moduleName));
            if (resource == null) {
                throw new FileNotFoundException(
                        String.format("Cannot find log4j2.xml in module %s", moduleName));
            }
            ConfigurationSource source = new ConfigurationSource(resource.openStream(), resource);
            LoggerContext context = (LoggerContext) LogManager.getContext(false);
            Configuration config = new XmlConfiguration(context, source);
            context.start(config);
        }
    }
}
EOF

cat > common/src/main/java/org/liuyehcf/moduleisolation/loader/ModuleClassLoader.java << 'EOF'
package org.liuyehcf.moduleisolation.loader;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.stream.Collectors;

public class ModuleClassLoader extends URLClassLoader {
    private static final String MODULE_JAR_FILE_PATTERN = "%s-jar-with-dependencies.jar";

    static {
        ClassLoader.registerAsParallelCapable();
    }

    private final File jarFile;
    private final ClassLoaderWrapper parent;

    private ModuleClassLoader(URL[] urls) {
        super(urls, null);
        this.jarFile = new File(urls[0].getPath());
        this.parent = new ClassLoaderWrapper(ClassLoader.getSystemClassLoader());
    }

    public static ModuleClassLoader create(String moduleName) throws MalformedURLException {
        String jarNameSuffix = String.format(MODULE_JAR_FILE_PATTERN, moduleName);
        String classpath = System.getProperty("java.class.path");
        String[] moduleJarFiles = classpath.split(":");
        String targetJarFile = null;
        for (String jarFile : moduleJarFiles) {
            if (jarFile.endsWith(jarNameSuffix)) {
                targetJarFile = jarFile;
                break;
            }
        }
        if (targetJarFile == null) {
            throw new RuntimeException(
                    String.format("Cannot find '%s' in classpath '%s'", jarNameSuffix, classpath));
        }

        return new ModuleClassLoader(new URL[] {new File(targetJarFile).toURI().toURL()});
    }

    public File getJarFile() {
        return jarFile;
    }

    private boolean isValidParentResource(URL url) {
        return url != null && !url.getPath().contains("-reader-jar-with-dependencies.jar");
    }

    @Override
    protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
        try {
            return super.loadClass(name, resolve);
        } catch (ClassNotFoundException cnf) {
            return parent.loadClass(name, resolve);
        }
    }

    @Override
    public Enumeration<URL> getResources(String name) throws IOException {
        // Load resource from current module classLoader
        List<URL> urls = Collections.list(super.getResources(name));
        // Load resource from parent classLoader but exclude other module resources
        urls.addAll(Collections.list(parent.getResources(name)).stream()
                .filter(this::isValidParentResource).collect(Collectors.toList()));
        return Collections.enumeration(urls);
    }

    @Override
    public URL getResource(String name) {
        // Load resource from current module classLoader
        URL url = super.getResource(name);
        if (url == null) {
            // Load resource from parent classLoader but exclude other module resources
            url = parent.getResource(name);
            if (!isValidParentResource(url)) {
                return null;
            }
        }
        return url;
    }

    /**
     * The only function of this wrapper is changing access modifiers of loadClass from protected to
     * public
     */
    private static final class ClassLoaderWrapper extends ClassLoader {
        static {
            ClassLoader.registerAsParallelCapable();
        }

        public ClassLoaderWrapper(ClassLoader parent) {
            super(parent);
        }

        @Override
        public Class<?> findClass(String name) throws ClassNotFoundException {
            return super.findClass(name);
        }

        @Override
        public Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
            return super.loadClass(name, resolve);
        }
    }
}
EOF

cat > module1/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.liuyehcf</groupId>
        <artifactId>ModuleIsolcation</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>

    <artifactId>module1</artifactId>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <compiler-plugin.version>3.8.1</compiler-plugin.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>module1</finalName>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-shade-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

cat > module1/src/main/java/org/liuyehcf/moduleisolation/module1/Function.java << 'EOF'
package org.liuyehcf.moduleisolation.module1;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Function {
    private static final Logger LOGGER = LoggerFactory.getLogger(Function.class);

    public void run() {
        LOGGER.info("This is an info log, classLoader={}, ObjectClass={}, LoggerFactoryClass={}",
                getClass().getClassLoader(), getClassString(Object.class),
                getClassString(LoggerFactory.class));
        LOGGER.error("This is an error log");
    }

    private String getClassString(Class<?> clazz) {
        return clazz.getName() + "@" + Integer.toHexString(System.identityHashCode(clazz));
    }
}
EOF

cat > module1/src/main/java/org/liuyehcf/moduleisolation/module1/ModuleClassFactory.java << 'EOF'
package org.liuyehcf.moduleisolation.module1;

import org.liuyehcf.moduleisolation.loader.ClassFactory;

public class ModuleClassFactory extends ClassFactory {
    @Override
    protected String getModuleName() {
        return "module1";
    }
}
EOF

cat > module1/src/main/resources/module1_log4j2.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Properties>
        <Property name="LOG_DIR">${env:MODULE_LOG_DIR:-/tmp/module_isloation}</Property>
        <Property name="LOG_LEVEL">${env:MODULE_LOG_LEVEL:-info}</Property>
        <Property name="LOG_PATTERN">%d{yyyy-MM-dd HH:mm:ss.SSS} %style{[%thread]}{bright} %highlight{[%-5level] [%X{QueryId}] %logger{36}}{STYLE=Logback} - %msg%n
        </Property>
    </Properties>
    <Appenders>
        <RollingRandomAccessFile name="DefaultAppender" fileName="${LOG_DIR}/module1/default.log"
                                 filePattern="${LOG_DIR}/module1/default-%d{yyyy-MM-dd}-%i.log">
            <PatternLayout
                    pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="1000MB"/>
            </Policies>
            <DefaultRolloverStrategy max="7"/>
        </RollingRandomAccessFile>
        <RollingRandomAccessFile name="ErrorAppender" fileName="${LOG_DIR}/module1/error.log"
                                 filePattern="${LOG_DIR}/module1/error-%d{yyyy-MM-dd}-%i.log">
            <ThresholdFilter level="ERROR" onMatch="ACCEPT" onMismatch="DENY"/>
            <PatternLayout
                    pattern="${LOG_PATTERN}"/>
            <Policies>
                <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
                <SizeBasedTriggeringPolicy size="1000MB"/>
            </Policies>
            <DefaultRolloverStrategy max="7"/>
        </RollingRandomAccessFile>
        <Async name="AsyncDefaultAppender">
            <AppenderRef ref="DefaultAppender"/>
            <AppenderRef ref="ErrorAppender"/>
        </Async>
    </Appenders>
    <Loggers>
        <Root level="${LOG_LEVEL}">
            <AppenderRef ref="AsyncDefaultAppender"/>
        </Root>
    </Loggers>
</Configuration>
EOF

cp -f module1/pom.xml module2/pom.xml
cp -f module1/src/main/java/org/liuyehcf/moduleisolation/module1/Function.java module2/src/main/java/org/liuyehcf/moduleisolation/module2/Function.java
cp -f module1/src/main/java/org/liuyehcf/moduleisolation/module1/ModuleClassFactory.java module2/src/main/java/org/liuyehcf/moduleisolation/module2/ModuleClassFactory.java
cp -f module1/src/main/resources/module1_log4j2.xml module2/src/main/resources/module2_log4j2.xml
sed -i 's/module1/module2/g' module2/pom.xml
sed -i 's/module1/module2/g' module2/src/main/java/org/liuyehcf/moduleisolation/module2/Function.java
sed -i 's/module1/module2/g' module2/src/main/java/org/liuyehcf/moduleisolation/module2/ModuleClassFactory.java
sed -i 's/module1/module2/g' module2/src/main/resources/module2_log4j2.xml

mvn clean package -DskipTests
rm -rf /tmp/module_isloation
java -classpath ./module2/target/module2-jar-with-dependencies.jar:./module1/target/module1-jar-with-dependencies.jar org.liuyehcf.moduleisolation.TestMain
cat /tmp/module_isloation/module1/default.log
cat /tmp/module_isloation/module1/error.log
cat /tmp/module_isloation/module2/default.log
cat /tmp/module_isloation/module2/error.log
```

You can find each module share the same `Object.class` instance, but has unique instance of `LoggerFactory.class`

# 7 Tips

## 7.1 Find JDK Install Path

For linux, the directory usually is: `/usr/lib/jvm`

1. `readlink -f $(which java)`
1. `update-alternatives --config java`
1. `update-alternatives --display java`

For MacOS, the directory usually is: `/Library/Java/JavaVirtualMachines`

1. `readlink -f $(which java)`

## 7.2 How to check whether jar file contains specific class file

* `unzip -l <jar> | grep xxx.class`
* `jar tf <jar> | grep xxx.class`

## 7.3 How to extract jar file to specific directory

* `cd <target_dir>; jar -xf <jar>`
* `unzip <jar> -d <target_dir>`

## 7.4 How to breakthrough checked exception limitation

If you want to throw an checked exception, but you don't want to add `throws clause` to the method signature, there are several ways can make it happen:

1. Use Type Erasure
    ```java
    @SuppressWarnings("unchecked")
    private static <T extends Throwable> void throwException(Throwable exception) throws T {
        throw (T) exception;
    }
    ```

1. Use `Unsafe.throwException`

# 8 参考

* [JVM性能调优监控工具jps、jstack、jmap、jhat、jstat、hprof使用详解](https://my.oschina.net/feichexia/blog/196575)
* [Java应用打开debug端口](https://www.cnblogs.com/lzmrex/articles/12579862.html)
* [别嘲笑我，工作几年的程序员也不一定会远程debug代码](https://www.bilibili.com/video/BV1ky4y1j73x/)
