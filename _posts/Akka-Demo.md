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

# 1 Akka-Common

工具方法，其他demo模块会使用到

## 1.1 目录结构

```
.
├── pom.xml
└── src
    └── main
        ├── java
        │   └── org
        │       └── liuyehcf
        │           └── akka
        │               └── common
        │                   └── util
        │                       ├── AkkaConfigUtils.java
        │                       └── IPUtils.java
```

## 1.2 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>akka-common</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

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

## 1.3 AkkaConfigUtils.java

```java
package org.liuyehcf.akka.common.util;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

/**
 * @author hechenfeng
 * @date 2019/1/25
 */
public abstract class AkkaConfigUtils {
    public static String loadConfig(String classpath) {
        ClassLoader systemClassLoader = ClassLoader.getSystemClassLoader();
        URL resource = systemClassLoader.getResource(classpath);

        if (resource == null) {
            throw new NullPointerException();
        }

        File file = new File(resource.getFile());
        StringBuilder sb = new StringBuilder();
        try (InputStream inputStream = new FileInputStream(file)) {
            int c;
            while ((c = inputStream.read()) != -1) {
                sb.append((char) c);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return sb.toString();
    }
}
```

## 1.4 IPUtils.java

```java
package org.liuyehcf.akka.common.util;

import java.net.Inet4Address;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;

/**
 * @author hechenfeng
 * @date 2019/1/25
 */
public class IPUtils {
    public static String getLocalIp() {
        try {
            Enumeration allNetInterfaces = NetworkInterface.getNetworkInterfaces();
            InetAddress ip;
            while (allNetInterfaces.hasMoreElements()) {
                NetworkInterface netInterface = (NetworkInterface) allNetInterfaces.nextElement();
                Enumeration addresses = netInterface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    ip = (InetAddress) addresses.nextElement();
                    if (ip instanceof Inet4Address) {
                        return ip.getHostAddress();
                    }
                }
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        throw new RuntimeException();
    }
}
```

# 2 Akka-Remote

## 2.1 目录结构

```
.
├── pom.xml
└── src
    └── main
        ├── java
        │   └── org
        │       └── liuyehcf
        │           └── akka
        │               └── remote
        │                   ├── LocalCreateBoot.java
        │                   ├── RemoteActor1.java
        │                   ├── RemoteActor2.java
        │                   └── RemoteCreateBoot.java
        └── resources
            └── remote.conf
```

## 2.2 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>akka-remote</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>akka-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>

        <dependency>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>akka-remote_2.11</artifactId>
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

## 2.3 RemoteActor1

```java
package org.liuyehcf.akka.remote;

import akka.actor.AbstractActor;
import akka.actor.Props;

/**
 * @author hechenfeng
 * @date 2019/1/17
 */
public class RemoteActor1 extends AbstractActor {

    static Props props() {
        return Props.create(RemoteActor1.class);
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .matchAny(msg -> {
                    System.out.println(msg);
                    sender().tell("Hi, I'm remote actor1", self());
                })
                .build();
    }

    @Override
    public void preStart() {
        System.out.println("remote actor1 start");
    }

    @Override
    public void postStop() {
        System.out.println("remote actor1 stop");
    }
}
```

## 2.4 RemoteActor2

```java
package org.liuyehcf.akka.remote;

import akka.actor.AbstractActor;
import akka.actor.Props;

/**
 * @author hechenfeng
 * @date 2019/1/25
 */
public class RemoteActor2 extends AbstractActor {

    static Props props() {
        return Props.create(RemoteActor2.class);
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .matchAny(System.out::println)
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
}
```

## 2.5 LocalCreateBoot

```java
package org.liuyehcf.akka.remote;

import akka.actor.ActorRef;
import akka.actor.ActorSelection;
import akka.actor.ActorSystem;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import org.liuyehcf.akka.common.util.AkkaConfigUtils;

/**
 * @author hechenfeng
 * @date 2019/1/25
 */
public class LocalCreateBoot {
    private static final class BootRemoteActor1 {
        public static void main(String[] args) {
            Config localCreatedConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("remote.conf"),
                            "127.0.0.1",
                            10001
                    )
            );

            ActorSystem system = ActorSystem.create("RemoteSystem1", localCreatedConfig);
            ActorRef remoteActor1 = system.actorOf(RemoteActor1.props(), "RemoteActor1");
            System.out.println(remoteActor1.path());
        }
    }

    private static final class BootRemoteActor2 {
        public static void main(String[] args) {
            Config localCreatedConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("remote.conf"),
                            "127.0.0.1",
                            10002
                    )
            );

            ActorSystem system = ActorSystem.create("RemoteSystem2", localCreatedConfig);

            // search actor remotely
            ActorSelection remoteActor1 = system.actorSelection(
                    String.format(
                            "akka.tcp://RemoteSystem1@%s:%d/user/RemoteActor1",
                            "127.0.0.1",
                            10001)
            );

            ActorRef remoteActor2 = system.actorOf(RemoteActor2.props(), "RemoteActor2");
            System.out.println(remoteActor2.path());

            // send message to remote actor
            remoteActor1.tell("Hi, I'm remote actor2", remoteActor2);
        }
    }
}
```

## 2.6 RemoteCreateBoot

```java
package org.liuyehcf.akka.remote;

import akka.actor.*;
import akka.remote.RemoteScope;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import org.liuyehcf.akka.common.util.AkkaConfigUtils;
import org.liuyehcf.akka.common.util.IPUtils;

/**
 * @author hechenfeng
 * @date 2019/1/25
 */
public class RemoteCreateBoot {
    private static final class BootRemoteActor1 {
        public static void main(String[] args) {
            Config remoteCreatedConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("remote.conf"),
                            IPUtils.getLocalIp(),
                            10003
                    )
            );

            // just create an actor system
            ActorSystem.create("RemoteSystem1", remoteCreatedConfig);
        }
    }

    private static final class BootRemoteActor2 {
        public static void main(String[] args) {
            Config remoteCreatedConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("remote.conf"),
                            IPUtils.getLocalIp(),
                            10004
                    )
            );

            ActorSystem system = ActorSystem.create("RemoteSystem2", remoteCreatedConfig);

            // build remote address, choose any of this
            Address addr = new Address("akka.tcp", "RemoteSystem1", IPUtils.getLocalIp(), 10003);
//            Address addr = AddressFromURIString.parse(String.format("akka.tcp://RemoteSystem1@%s:%d", IPUtils.getLocalIp(), 10001));

            // create actor remotely
            ActorRef remoteActor1 = system.actorOf(Props.create(RemoteActor1.class).withDeploy(
                    new Deploy(new RemoteScope(addr))));

            ActorRef remoteActor2 = system.actorOf(RemoteActor2.props(), "RemoteActor2");
            System.out.println(remoteActor2.path());

            // send message to remote actor
            remoteActor1.tell("Hi, I'm remote actor2", remoteActor2);
        }
    }
}
```

## 2.7 remote.conf

```
akka {
  actor {
    provider = "remote"
  }
  remote {
    enabled-transports = ["akka.remote.netty.tcp"]
    netty.tcp {
      hostname = %s
      port = %d
    }
    log-sent-messages = on
    log-received-messages = on
  }
}
```

# 3 Akka-Cluster

## 3.1 目录结构

```
.
├── akka-cluster.iml
├── pom.xml
└── src
    └── main
        ├── java
        │   └── org
        │       └── liuyehcf
        │           └── akka
        │               └── cluster
        │                   ├── ClusterBoot.java
        │                   └── SimpleClusterListener.java
        └── resources
            ├── cluster-with-none-seed-node.conf
            └── cluster-with-static-seed-node.conf
```

## 3.2 pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>akka-cluster</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>akka-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>

        <dependency>
            <groupId>com.typesafe.akka</groupId>
            <artifactId>akka-cluster_2.11</artifactId>
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

## 3.3 SimpleClusterListener

```java
package org.liuyehcf.akka.cluster;

import akka.actor.AbstractActor;
import akka.actor.Props;
import akka.cluster.Cluster;
import akka.cluster.ClusterEvent;
import akka.event.Logging;
import akka.event.LoggingAdapter;

public class SimpleClusterListener extends AbstractActor {

    private final LoggingAdapter log = Logging.getLogger(getContext().getSystem(), this);
    private final Cluster cluster = Cluster.get(getContext().getSystem());

    static Props props() {
        return Props.create(SimpleClusterListener.class);
    }

    //subscribe to cluster changes
    @Override
    public void preStart() {
        cluster.subscribe(getSelf(), ClusterEvent.initialStateAsEvents(),
                ClusterEvent.MemberEvent.class, ClusterEvent.UnreachableMember.class);
    }

    //re-subscribe when restart
    @Override
    public void postStop() {
        cluster.unsubscribe(getSelf());
    }

    @Override
    public Receive createReceive() {
        return receiveBuilder()
                .match(ClusterEvent.MemberUp.class,
                        mUp -> log.info("Member is Up: {}", mUp.member()))
                .match(ClusterEvent.UnreachableMember.class,
                        mUnreachable -> log.info("Member detected as unreachable: {}", mUnreachable.member()))
                .match(ClusterEvent.MemberRemoved.class,
                        mRemoved -> log.info("Member is Removed: {}", mRemoved.member())
                )
                .match(ClusterEvent.MemberEvent.class,
                        message -> {
                            // ignore
                        }
                )
                .build();
    }
}
```

## 3.4 ClusterBoot

```java
package org.liuyehcf.akka.cluster;

import akka.actor.ActorSystem;
import akka.actor.Address;
import akka.cluster.Cluster;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigFactory;
import org.liuyehcf.akka.common.util.AkkaConfigUtils;
import org.liuyehcf.akka.common.util.IPUtils;

import java.util.Collections;

public class ClusterBoot {
    private static final class SeedNode {
        public static void main(String[] args) {
            Config clusterConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("cluster-with-static-seed-node.conf"),
                            "127.0.0.1",
                            1100
                    )
            );

            ActorSystem.create("MyClusterSystem", clusterConfig);
        }
    }

    private static final class Member1 {
        public static void main(String[] args) {
            Config clusterConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("cluster-with-static-seed-node.conf"),
                            IPUtils.getLocalIp(),
                            1101
                    )
            );

            ActorSystem system = ActorSystem.create("MyClusterSystem", clusterConfig);
            system.actorOf(SimpleClusterListener.props());
        }
    }

    private static final class Member2 {
        public static void main(String[] args) {
            Config clusterConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("cluster-with-static-seed-node.conf"),
                            IPUtils.getLocalIp(),
                            1102
                    )
            );

            ActorSystem system = ActorSystem.create("MyClusterSystem", clusterConfig);
            system.actorOf(SimpleClusterListener.props());
        }
    }

    private static final class Member3 {
        public static void main(String[] args) {
            Config clusterConfig = ConfigFactory.parseString(
                    String.format(
                            AkkaConfigUtils.loadConfig("cluster-with-none-seed-node.conf"),
                            IPUtils.getLocalIp(),
                            1103
                    )
            );

            ActorSystem system = ActorSystem.create("MyClusterSystem", clusterConfig);
            system.actorOf(SimpleClusterListener.props());

            final Cluster cluster = Cluster.get(system);
            // use member2 as seed node
            Address address = new Address("akka.tcp", "MyClusterSystem", IPUtils.getLocalIp(), 1102);
            cluster.joinSeedNodes(Collections.singletonList(address));
        }
    }
}
```

## 3.5 cluster-with-static-seed-node.conf

```java
akka {
  actor {
    provider = "cluster"
  }
  remote {
    log-remote-lifecycle-events = off
    netty.tcp {
      hostname = %s
      port = %d
    }
  }

  cluster {
    seed-nodes = [
      "akka.tcp://MyClusterSystem@127.0.0.1:1100"
    ]

    # auto downing is NOT safe for production deployments.
    # you may want to use it during development, read more about it in the docs.
    #
    # auto-down-unreachable-after = 10s
  }
}
```

## 3.6 cluster-with-none-seed-node.conf

```java
akka {
  actor {
    provider = "cluster"
  }
  remote {
    log-remote-lifecycle-events = off
    netty.tcp {
      hostname = %s
      port = %d
    }
  }

  cluster {
    seed-nodes = []

    # auto downing is NOT safe for production deployments.
    # you may want to use it during development, read more about it in the docs.
    #
    # auto-down-unreachable-after = 10s
  }
}
```

