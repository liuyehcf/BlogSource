---
title: Akka-Demo
date: 2019-01-17 19:53:55
tags: 
- 原创
categories: 
- Java
- Framework
- Akka
---

__阅读更多__

<!--more-->

# 1 Remote

## 1.1 目录结构

```
.
├── akka-remote-1
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── liuyehcf
│           │           └── akka
│           │               └── cluster
│           │                   └── RemoteActor1.java
│           └── resources
│               └── application.conf
├── akka-remote-2
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── org
│           │       └── liuyehcf
│           │           └── akka
│           │               └── cluster
│           │                   └── RemoteActor2.java
│           └── resources
│               └── application.conf
└── pom.xml
```

## 1.2 主pom

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>akka</artifactId>
    <packaging>pom</packaging>
    <version>1.0-SNAPSHOT</version>
    <modules>
        <module>akka-remote-1</module>
        <module>akka-remote-2</module>
    </modules>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>akka-actor_2.11</artifactId>
            <version>2.5.19</version>
        </dependency>
        <dependency>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>akka-remote_2.11</artifactId>
            <version>2.5.19</version>
        </dependency>
        <dependency>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>akka-cluster-typed_2.11</artifactId>
            <version>2.5.19</version>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

## 1.3 akka-remote-1

### 1.3.1 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>akka</artifactId>
        <groupId>org.liuyehcf</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>akka-remote-1</artifactId>
    <version>1.0-SNAPSHOT</version>
</project>
```

### 1.3.2 RemoteActor1.java

```Java
package org.liuyehcf.akka.cluster;

import akka.actor.AbstractActor;
import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;

/**
 * @author hechenfeng
 * @date 2019/1/17
 */
public class RemoteActor1 extends AbstractActor {

    private static Props props() {
        return Props.create(RemoteActor1.class);
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(Object.class, msg -> {
                    System.out.println(msg);
                    sender().tell("hi, I'm remote actor1", self());
                })
                .build();
    }

    @Override
    public void preStart() {
        System.out.println("remote actor1 start");
    }

    @Override
    public void postStop() {
        System.out.println("remote actor2 stop");
    }

    public static void main(String[] args) {
        ActorSystem system = ActorSystem.create("RemoteSystem1");
        ActorRef remoteActor = system.actorOf(props(), "RemoteActor1");
        System.out.println(remoteActor.path());
    }

}
```

### 1.3.3 application.confg

```
akka {
  actor {
    provider = "remote"
  }
  remote {
    enabled-transports = ["akka.remote.netty.tcp"]
    netty.tcp {
      hostname = 127.0.0.1
      port = 2552
    }
    log-sent-messages = on
    log-received-messages = on
  }
}
```

### 1.3.4 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>akka</artifactId>
        <groupId>org.liuyehcf</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>akka-remote-2</artifactId>
    <version>1.0-SNAPSHOT</version>
</project>
```

## 1.4 akka-remote-2

### 1.4.1 RemoteActor2.java

```Java
package org.liuyehcf.akka.cluster;

import akka.actor.*;

/**
 * @author hechenfeng
 * @date 2019/1/17
 */
public class RemoteActor2 extends AbstractActor {

    private static Props props() {
        return Props.create(RemoteActor2.class);
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(Object.class, System.out::println)
                .build();
    }

    @Override
    public void preStart() {
        System.out.println("remote actor2 start");
    }

    @Override
    public void postStop() {
        System.out.println("remote actor2 stop");
    }

    public static void main(String[] args) {
        ActorSystem system = ActorSystem.create("RemoteSystem2");
        ActorRef remoteActor2 = system.actorOf(props(), "RemoteActor2");

        ActorSelection remoteActor1 = system.actorSelection("akka.tcp://RemoteSystem1@127.0.0.1:2552/user/RemoteActor1");

        remoteActor1.tell("hello, I'm remote actor2", remoteActor2);
    }
}
```

### 1.4.2 application.confg

```
akka {
  actor {
    provider = "remote"
  }
  remote {
    enabled-transports = ["akka.remote.netty.tcp"]
    netty.tcp {
      hostname = 127.0.0.1
      port = 2553
    }
    log-sent-messages = on
    log-received-messages = on
  }
}
```
