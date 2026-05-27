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

[Archived OpenJDK General-Availability Releases](https://jdk.java.net/archive/)

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

**Java 1.4 and earlier: `-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=*:8000,suspend=n`**

* `-Xrunjdwp`: Starts the `JDWP, Java Debug Wire Protocol` debugger.
* `transport=dt_socket`: Uses a socket as the transport method.
* `server=y`: Runs as a debug server.
* `address=*:8000`: Listens on port `8000` on all network interfaces. Same as `0.0.0.0`.
    * `8000`
    * `127.0.0.1:8000`
    * `0.0.0.0:8000`
* `suspend=n`: Does not suspend after the `JVM` starts; runs immediately.

**Java 1.5 (JDK 5): `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000`**

* `-agentlib:jdwp`: Starts the `JDWP` debugger using the `jdwp` library, without needing to additionally specify `-Xdebug`.
* `transport=dt_socket`: Uses a socket as the transport method.
* `server=y`: Runs as a debug server.
* `suspend=n`: Does not suspend after the `JVM` starts; runs immediately.
* `address=*:8000`: Listens on port `8000` on all network interfaces. Same as `0.0.0.0`.

## 2.2 jps

Lists the running virtual machine processes, and displays the main class name executed by the virtual machine as well as the **local virtual machine unique `ID (Local Virtual Machine Identifier, LVMID)`** of these processes.

Although its functionality is relatively simple, it is the most frequently used `JDK` command-line tool, because most other `JDK` tools require the `LVMID` queried by it as input to determine which virtual machine process to monitor.

**For a local virtual machine, the `LVMID` is the same as the operating system process `ID (Process Identifier, PID)`**. You can also query the `LVMID` of a virtual machine process using the `Windows` Task Manager or the `UNIX` `ps` command. If multiple virtual machine processes are started at the same time and cannot be identified by process name, you have to rely on the `jps` command's ability to display the main class to distinguish them.

**Pattern:**

* `jps [options] [hostid]`

**Parameter description:**

* `-q`: Outputs only the `LVMID`, omitting the name of the main class.
* `-m`: Outputs the arguments passed to the main class `main()` function when the virtual machine process was started.
* `-l`: Outputs the fully qualified name of the main class; if the process is executing a `Jar` package, outputs the `Jar` path.
* `-v`: Outputs the `JVM` arguments used when the virtual machine process was started.

## 2.3 jstat

`jstat (JVM Statistics Monitoring Tool)` is a command-line tool used to monitor various runtime status information of a virtual machine.

`jstat` can display runtime data such as class loading, memory, garbage collection, and `JIT` compilation for local or remote virtual machine processes. On servers without a `GUI` graphical interface and only a plain-text console environment, it is the preferred tool for locating virtual machine performance issues at runtime.

**Pattern:**

* `jstat [option <vmid> [interval [s|ms] [count] ] ]`

**Parameter description:**

* If it is a local virtual machine process, `VMID` is the same as `LVMID`. If it is a remote virtual machine process, the format of `VMID` should be:
    * `[protocol:] [//] lvmid [@hostname[:port]/servername]`
* `interval` and `count` represent the query interval and number of queries. If these two parameters are omitted, it means querying only once.
    * `jstat -gc 2764 250 20`: Queries the garbage collection status of process `2764` every `250` milliseconds, for a total of `20` times.
* `-class`: Monitors the number of loaded and unloaded classes, total space, and the time spent on class loading.
* `-gc`: Monitors the `Java` heap status, including the capacity, used space, total `GC` time, and other information for the `Eden` area, the two `survivor` areas, the old generation, the permanent generation, etc.
* `-gccapacity`: Monitors basically the same content as `-gc`, but the output mainly focuses on the maximum and minimum space used by each area of the `Java` heap.
* `-gcutil`: Monitors basically the same content as `-gc`, but the output mainly focuses on the percentage of used space relative to total space.
* `-gccause`: Has the same function as `-gcutil`, but additionally outputs the reason that caused the previous `GC`.
* `-gcnew`: Monitors the `GC` status of the young generation.
* `-gcnewcapacity`: Monitors basically the same content as `-gcnew`, with the output mainly focusing on the maximum and minimum space used.
* `-gcold`: Monitors the `GC` status of the old generation.
* `-gcoldcapacity`: Monitors basically the same content as `-gcold`, with the output mainly focusing on the maximum and minimum space used.
* `-gcpermcapacity`: Outputs the maximum and minimum space used by the permanent generation.
* `-compiler`: Outputs information such as methods compiled by the `JIT` compiler and the time spent.
* `-printcompilation`: Outputs methods that have already been compiled by the `JIT`.

**Meaning of output content:**

* `E`: `Eden` area of the young generation.
* `S0\S1`: The two `Survivor` areas: `Survivor0` and `Survivor1`.
* `O`: Old generation `Old`.
* `P`: Permanent generation `Permanent`.
* `YGC`: `Young GC`
* `YGCT`: `Young GC Time`
* `FGC`: `Full GC`
* `FTCG`: `Full GC Time`
* `GCT`: Total time spent on `Minor GC` and `Full GC`

**Examples:**

* **`jstat -gc <vmid> 1000 10`: View `JVM` memory usage, once every 1000 ms, for a total of 10 times.**
* **`jstat -gcutil <vmid> 1000 10`: View `JVM` memory usage as percentages, once every 1000 ms, for a total of 10 times.**

## 2.4 jinfo

`jinfo (Configuration Info for Java)` is used to view and adjust various virtual machine parameters in real time.

You can use the `-v` option of the `jps` command to view the list of parameters explicitly specified when the virtual machine was started. **However, if you want to know the system default values of parameters that were not explicitly specified, besides looking them up in documentation, you can only use the `-flag` option of `jinfo` to query them.**

If you are using `JDK 1.6` or later, you can use `-XX:+PrintFlagsFinal` to view parameter default values.

`jinfo` can also use the `-sysprops` option to print the contents of `System.getProperties()` for the virtual machine process.

**Pattern:**

* `jinfo [option] <vmid>`

**Parameter description**

* `-flag`: Displays default values.
    * `jinfo -flags 1874`: Displays the default values of all items.
    * `jinfo -flag CICompilerCount 1874`: Displays the default value of the specified item.
* `-sysprops`: Prints the contents of `System.getProperties()` for the virtual machine process.

## 2.5 jmap

The `jmap (Memory Map for Java)` command is used to generate heap dump snapshots, generally called `heapdump` or `dump` files.

The purpose of `jmap` is not only to obtain `dump` files. It can also query the `finalize` execution queue, as well as detailed information about the `Java` heap and permanent generation, such as space usage, the currently used collector, and so on.

**Pattern:**

* `jmap [option] <vmid>`

**Parameter description:**

* `-dump`: Generates a Java heap dump snapshot. The format is `-dump:[live, ]format=b, file=<filename>`, where the `live` sub-parameter indicates whether to `dump` only live objects.
* `-finalizerinfo`: Displays objects waiting in the `F-Queue` for the `Finalizer` thread to execute their `finalize` methods.
* `-heap`: Displays detailed information about the `Java` heap, such as which collector is used, parameter configuration, generation status, and so on.
* `-histo`: Displays object statistics in the heap, including classes, number of instances, and total capacity.
* `-permstat`: Displays permanent generation memory status using `ClassLoader` as the statistical scope.
* `-F`: When the virtual machine process does not respond to the `-dump` option, this option can be used to forcibly generate a `dump` snapshot.

**Examples**

* `jmap -dump:format=b,file=<dump_file_name> <java_process_id>`: `dump` the heap of all objects in the process.
* `jmap -dump:live,format=b,file=<dump_file_name> <java_process_id>`: `dump` the heap of live objects in the process; this will trigger a `full gc`.
* `jmap -histo:live <vmid>`: Triggers a `full gc`.
* `jmap -histo <vmid> | sort -k 2 -g -r | less`: Collects memory information about objects in the heap and prints it in descending order by the number of object instances.
* `jmap -histo <vmid> | sort -k 3 -g -r | less`: Collects memory information about objects in the heap and prints it in descending order by object memory usage.

## 2.6 jhat

`jhat` is a virtual machine heap dump snapshot analysis tool.

`Sun JDK` provides the `jhat (JVM Heap Analysis Tool)` command to be used together with `jmap` to analyze heap dump snapshots generated by `jmap`.

`jhat` has a built-in lightweight `HTTP/HTML` server. After generating the analysis results for a `dump` file, you can view them in a browser.

However, in actual work, unless there really are no other tools available, the `jhat` command is generally not used directly to analyze `dump` files, for the following reasons:

* In general, `dump` files are not analyzed directly on the server where the application is deployed. Even if this can be done, the `dump` file is usually copied to another machine for analysis, because analysis is a time-consuming process that consumes hardware resources. Since the analysis is going to be performed on another machine anyway, there is no need to be limited by command-line tools.
* The analysis capabilities of `jhat` are relatively limited. Tools such as `VisualVM`, as well as professional tools specifically used to analyze `dump` files, such as `Eclipse Memory Analyzer` and `IBM HeapAnalyzer`, can provide more powerful and professional analysis capabilities than `jhat`.

**Example used together with jmap**

1. `jmap -dump:format=b,file=dump.bin 1874`
    * The relative file path is `dump.bin`.
    * The `vmid` is 1874.
1. `jhat dump.bin`
    * The following output will specify port `7000`.
    * Enter `http://localhost:7000/` in the browser to view the analysis results. Scroll to the bottom, and it contains the following navigation:
        * All classes including platform.
        * Show all members of the rootset.
        * Show instance counts for all classes (including platform).
        * Show instance counts for all classes (excluding platform).
        * Show heap histogram.
        * Show finalizer summary.
        * Execute Object Query Language (OQL) query.

## 2.7 jstack

`jstack` is a `Java` stack trace tool.

The `jstack (Stack Trace for Java)` command is used to generate a thread snapshot of the virtual machine at the current moment, generally called a `threaddump` or `javacore` file.

A thread snapshot is a collection of the method stacks currently being executed by every thread in the virtual machine. The main purpose of generating a thread snapshot is to locate the causes of long thread pauses, such as thread deadlocks, infinite loops, and long waits caused by requests for external resources, all of which are common causes of long thread pauses.

When a thread pauses, you can use `jstack` to view the call stack of each thread, so you can know exactly what the unresponsive thread is doing in the background, or what resource it is waiting for.

**Pattern:**

* `jstack [option] <vmid>`

**Parameter description:**

* `-F`: Forces thread stack output when a normal output request is not responded to.
* `-l`: Displays additional information about locks in addition to the stack.
* `-m`: Displays the C/C++ stack if native methods are called.

**In `JDK 1.5`, the `java.lang.Thread` class added a `getAllStackTraces()` method to obtain the `StackTraceElement` objects of all threads in the virtual machine. Using this object, most of the functionality of `jstack` can be implemented with just a few simple lines of code. In real projects, you may consider calling this method to build an administrator page, so that you can view thread stacks in a browser at any time.**

## 2.8 java_home

**`/usr/libexec/java_home -V`: Used to view the installation directories of all Java versions on the local machine**

## 2.9 jar

**Creating an archive file: `jar cvf xxx.jar -C ${target_dir1} ${dir_or_file1} -C ${target_dir2} ${dir_or_file2} ...`**

* **Note that `-C` only applies to the argument immediately following it**
* `jar cvf xxx.jar .`
* `jar cvf xxx.jar org com/test/A.class`
* `jar cvf xxx.jar -C classes org -C classes com`

**Extracting an archive file: `jar xvf xxx.jar`**

* `jar xvf /path/xxx.jar`
* `jar xvf /path/xxx.jar xxx.class`: Extract only one file.

**Viewing an archive file: `jar tf xxx.jar`**

### 2.9.1 JAR File Specification

[JAR File Specification](https://docs.oracle.com/en/java/javase/17/docs/specs/jar/jar.html)

* The META-INF directory
    * `service`: Service Provider Interface, SPI
    * `MANIFEST.MF`: Main-Class
* ...

## 2.10 jdb

Debug tool like `gdb`

## 2.11 jcmd

**Useful commands:**

* Heap information: `jcmd <pid> GC.heap_info`
* Metaspace information: `jcmd <pid> VM.metaspace`
* VM flags: `jcmd <pid> VM.flags`
* VM command: `jcmd <pid> VM.command_line`
* Stack and lock: `jcmd <pid> Thread.print -l`
* Big classes: `jcmd <pid> GC.class_histogram live`

# 3 Thirdparty-Tools

## 3.1 Arthas

[Arthas](https://github.com/alibaba/arthas)

[commands](https://arthas.aliyun.com/doc/commands.html)

**Usage:**

1. `help`:
    * `help`
    * `help <command>`
1. `dashboard`
1. `thread`:
    * `thread`
    * `thread -n 3`
1. `trace`:
    * `trace org.apache.paimon.catalog.Catalog getTable`
1. `monitor`:
    * `monitor -c 5 org.apache.paimon.catalog.Catalog getTable`
1. `profiler`
    * `profiler list`: list all supported events
    * `profiler actions`: list all supported actions
    * `profiler start --event alloc --interval 1000000`
        * `interval`: sampling interval in ns
    * `profiler stop --format html`
1. `sc`:
    * `sc org.apache.commons.lang.StringUtils`
    * `sc -E org\\.apache\\.commons\\.lang\\.StringUtils`
    * `sc -d -f org.apache.commons.lang.StringUtils`
1. `classloader`:
    * `classloader -t`
    * `classloader -l`

## 3.2 VisualVM

[All-in-One Java Troubleshooting Tool](https://visualvm.github.io/)

### 3.2.1 Shallow Size vs. Retained Size

`Shallow Size`: This is the amount of memory allocated to store the object itself, not including the objects it references. This includes the memory used by the object's fields (for primitive types) and the memory used to store the references to other objects (for reference types). It does not include the memory used by the objects those references point to. Tools like VisualVM generally show the shallow size by default.

`Retained Size`: This is the total amount of memory that would be freed if the object were garbage collected. This includes the shallow size of the object itself plus the shallow size of any objects that are exclusively referenced by this object (i.e., objects that would be garbage collected if this object were). The retained size provides a more complete picture of the "true" memory impact of an object but can be more complex to calculate. Some profiling tools provide this information, but it may require additional analysis or plugins.

## 3.3 Eclipse Memory Analyzer Tool(MAT)

The [Eclipse Memory Analyzer](https://eclipse.dev/mat/) is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.

How to use:

1. Setup memory for running mat.
    * `vim MemoryAnalyzer.ini`
1. Run analyze task.
    * `./ParseHeapDump.sh /path/to/your/heapdump.hprof org.eclipse.mat.api:suspects`
    * This task will generate a zipped HTML leak suspects report (`*_Leak_Suspects.zip`) ranking the largest objects by retained size; to view it, download and extract the zip file on your local machine and open index.html in a web browser.

# 4 Java Decompiler

[Java Decompilers](http://www.javadecompilers.com/)

## 4.1 CFR

[Class File Reader, CFR](https://github.com/leibnitz27/cfr): Another Java Decompiler, it will decompile modern Java features - including much of Java `9`, `12` & `14`, but is written entirely in Java `6`, so will work anywhere!

```sh
wget https://github.com/leibnitz27/cfr/releases/download/0.152/cfr-0.152.jar

java -jar cfr-0.152.jar xxx.class
java -jar cfr-0.152.jar xxx.jar --outputdir <output>
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
    echo 'eval "jenv enable-plugin export > /dev/null 2>&1"' >> ~/.zshrc

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

## 7.5 How JVM use classpath

Assume the classpath is: `/path/to/a.jar:/path/to/b.jar`, and `a.jar` exists while `b.jar` doesn't exist.

The following steps can work well:

1. Load some class `A` from `a.jar`
1. Put `b.jar` to the right place, i.e `/path/to/b.jar`
1. Load some class `B` from `b.jar`

**And the same process won't work if the classpath is reverted, i.e. `/path/to/b.jar:/path/to/a.jar`, because when JVM load class `A` it already searched `b.jar` and remember it's not existed.**

## 7.6 How to get the location which class belongs to

```java
System.out.println(org.apache.orc.TypeDescription.class.getProtectionDomain().getCodeSource().getLocation());
```

## 7.7 Search which jar file has sepcific .class file

```sh
function search() {
    local dir=$1
    local class_file=$2

    if [ -z "${dir}" ] || [ -z "${class_file}" ]; then
        echo "missing dir or class_file"
        return
    fi

    jar_files=( $(find ${dir} -name "*.jar") )
    for jar_file in ${jar_files[@]}
    do
        if jar tf ${jar_file} | grep "${class_file}"; then
            echo "${jar_file} contains '${class_file}'"
        fi
    done
}
```

## 7.8 SuppressWarnings types

* `SuppressWarnings("all")`
* `SuppressWarnings("unchecked")`
* `SuppressWarnings("rawtypes")`
* `SuppressWarnings("fallthrough")`
* `SuppressWarnings("ResultOfMethodCallIgnored")`

## 7.9 Dual Stack

Just use `-Djava.net.preferIPv4Stack=false -Djava.net.preferIPv6Addresses=true` can enable dual stack, it will try ipv6 first and downgrade to ipv4 if ipv6 failed.

# 8 Reference

* [JVM性能调优监控工具jps、jstack、jmap、jhat、jstat、hprof使用详解](https://my.oschina.net/feichexia/blog/196575)
* [Java应用打开debug端口](https://www.cnblogs.com/lzmrex/articles/12579862.html)
* [别嘲笑我，工作几年的程序员也不一定会远程debug代码](https://www.bilibili.com/video/BV1ky4y1j73x/)
