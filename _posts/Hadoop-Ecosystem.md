---
title: Hadoop-Ecosystem
date: 2022-07-18 19:17:45
tags: 
- 原创
categories: 
- Hadoop
---

**阅读更多**

<!--more-->

# 1 Overview

Below are the Hadoop components, that together form a Hadoop ecosystem:

* `HDFS` -> Hadoop Distributed File System
* `YARN` -> Yet Another Resource Negotiator
* `MapReduce` -> Data processing using programming
* `Spark` -> In-memory Data Processing
* `PIG` -> Data Processing Services using Query (SQL-like)
* `HBase` -> NoSQL Database
* `Mahout & Spark MLlib` -> Machine Learning
* `Drill` -> SQL on Hadoop
* `Zookeeper` -> Managing Cluster
* `Oozie` -> Job Scheduling
* `Flume` -> Data Ingesting Services
* `Solr & Lucene` -> Searching & Indexing
* `Ambari` -> Provision, Monitor and Maintain cluster

![HADOOP-ECOSYSTEM-Edureka](/images/Hadoop-Ecosystem/HADOOP-ECOSYSTEM-Edureka.png)

![HadoopEcosystem-min](/images/Hadoop-Ecosystem/HadoopEcosystem-min.png)

```plantuml
title Hadoop Component Interaction Diagram (Revised)

actor Client

package "HDFS" {
    node NameNode
    node DataNode1
    node DataNode2
}

package "YARN" {
    node ResourceManager
    node NodeManager1
    node NodeManager2
    node ApplicationMaster
}

' Client interactions
Client --> NameNode : Request file metadata\n(path → block locations)
Client --> DataNode1 : Read/Write HDFS blocks
Client --> DataNode2 : Read/Write HDFS blocks

Client --> ResourceManager : Submit YARN job

' HDFS internal
DataNode1 --> NameNode : Heartbeat + Block Report
DataNode2 --> NameNode : Heartbeat + Block Report

' YARN internal
ResourceManager --> NodeManager1 : Launch ApplicationMaster
ApplicationMaster --> ResourceManager : Request resources
ApplicationMaster --> NodeManager1 : Request container
ApplicationMaster --> NodeManager2 : Request container
ResourceManager --> NodeManager1 : Launch container\n(allocate resources)
ResourceManager --> NodeManager2 : Launch container\n(allocate resources)
NodeManager1 --> ResourceManager : Heartbeat + Resource Status
NodeManager2 --> ResourceManager : Heartbeat + Resource Status
```

# 2 HDFS

> HDFS has a master/slave architecture. An HDFS cluster consists of a single NameNode, a master server that manages the file system namespace and regulates access to files by clients. In addition, there are a number of DataNodes, usually one per node in the cluster, which manage storage attached to the nodes that they run on. HDFS exposes a file system namespace and allows user data to be stored in files. Internally, a file is split into one or more blocks and these blocks are stored in a set of DataNodes. The NameNode executes file system namespace operations like opening, closing, and renaming files and directories. It also determines the mapping of blocks to DataNodes. The DataNodes are responsible for serving read and write requests from the file system's clients. The DataNodes also perform block creation, deletion, and replication upon instruction from the NameNode.

![hdfsarchitecture](/images/Hadoop-Ecosystem/hdfsarchitecture.gif)

## 2.1 Deployment via Docker

**Import paths of docker:**

* `/var/log/hadoop`
    * `/var/log/hadoop/hadoop-hadoop-namenode-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-datanode-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-resourcemanager-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-nodemanager-$(hostname).out`
    * `userlogs`: Logs for applications that are submitted to yarn.

**Ports:**

* `8020`: HDFS NameNode RPC Port
* `9866`: HDFS DataNode Data Transfer Port
* `8088`: YARN ResourceManager Web UI
* `8042`: YARN NodeManager Web UI

### 2.1.1 One Container per Component Architecture

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
DN_CONTAINER_NAME=datanode
NM_CONTAINER_NAME=nodemanager
RM_CONTAINER_NAME=resourcemanager
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
DN_HOSTNAME=${DN_CONTAINER_NAME}.${SHARED_NS}
NM_HOSTNAME=${NM_CONTAINER_NAME}.${SHARED_NS}
RM_HOSTNAME=${RM_CONTAINER_NAME}.${SHARED_NS}

docker rm -f ${NN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${NM_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${RM_CONTAINER_NAME} > /dev/null 2>&1

# Hadoop container is not stable in MacOS, always exited right after started without any logs, so start them in loop here.
while true; do
    # namenode
    if ! docker inspect ${NN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NN_CONTAINER_NAME} \
            --hostname ${NN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8020:8020 \
            apache/hadoop:3.3.6 bash
    fi

    # datanode
    if ! docker inspect ${DN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_CONTAINER_NAME} \
            --hostname ${DN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:9866:9866 \
            apache/hadoop:3.3.6 bash
    fi

    # nodemanager
    if ! docker inspect ${NM_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NM_CONTAINER_NAME} \
            --hostname ${NM_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8042:8042 \
            apache/hadoop:3.3.6 bash
    fi

    # resourcemanager
    if ! docker inspect ${RM_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${RM_CONTAINER_NAME} \
            --hostname ${RM_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8088:8088 \
            apache/hadoop:3.3.6 bash
    fi

    sleep 5
    cnt=0;
    for container in "${NN_CONTAINER_NAME}" "${DN_CONTAINER_NAME}" "${NM_CONTAINER_NAME}" "${RM_CONTAINER_NAME}"
    do
        if [ "$(docker inspect -f '{{.State.Status}}' ${container})" = "running" ]; then
            ((cnt++))
        else
            echo "${container} is not running"
            docker rm -f ${container}
        fi
    done
    if [ ${cnt} -eq 4 ]; then
        break
    fi
done

# Generate configs
cat > /tmp/core-site.xml << EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${NN_HOSTNAME}:8020</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_HOSTNAME}</value>
    </property>
</configuration>
EOF

cat > /tmp/yarn-site.xml << EOF
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>${RM_HOSTNAME}</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
    <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>4</value>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>
</configuration>
EOF

cat > /tmp/mapred-site.xml << EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>/opt/hadoop/share/hadoop/mapreduce/*,/opt/hadoop/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOF

for container in "${NN_CONTAINER_NAME}" "${DN_CONTAINER_NAME}" "${NM_CONTAINER_NAME}" "${RM_CONTAINER_NAME}"
do
    docker cp /tmp/core-site.xml ${container}:/opt/hadoop/etc/hadoop/core-site.xml
    docker cp /tmp/hdfs-site.xml ${container}:/opt/hadoop/etc/hadoop/hdfs-site.xml
    docker cp /tmp/yarn-site.xml ${container}:/opt/hadoop/etc/hadoop/yarn-site.xml
    docker cp /tmp/mapred-site.xml ${container}:/opt/hadoop/etc/hadoop/mapred-site.xml
done

# Format
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs namenode -format'
docker exec ${DN_CONTAINER_NAME} bash -c 'mkdir -p /opt/hadoop/data'

# Retart all daemons
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs --daemon stop namenode; hdfs --daemon start namenode'
docker exec ${DN_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${NM_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'
docker exec ${RM_CONTAINER_NAME} bash -c 'yarn --daemon stop resourcemanager; yarn --daemon start resourcemanager'

# Report status
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs dfsadmin -report'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn node -list -showDetails'
```

**Test:**

```sh
docker exec ${NN_CONTAINER_NAME} bash -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn application -list -appStates ALL'
```

### 2.1.2 Multi-Component Shared Container Model

**Compoment Structure:**

* 1 Namenode and 1 ResourceManager share 1 node
* 2 Datanodes and 2 NodeManagers share 2 nodes

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
DN_1_CONTAINER_NAME=datanode-1
DN_2_CONTAINER_NAME=datanode-2
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
DN_1_HOSTNAME=${DN_1_CONTAINER_NAME}.${SHARED_NS}
DN_2_HOSTNAME=${DN_2_CONTAINER_NAME}.${SHARED_NS}

docker rm -f ${NN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_1_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_2_CONTAINER_NAME} > /dev/null 2>&1

# Hadoop container is not stable in MacOS, always exited right after started without any logs, so start them in loop here.
while true; do
    # namenode and resourcemanager
    if ! docker inspect ${NN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NN_CONTAINER_NAME} \
            --hostname ${NN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6 bash
    fi

    # datanode 1 and nodemanager 1
    if ! docker inspect ${DN_1_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_1_CONTAINER_NAME} \
            --hostname ${DN_1_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6 bash
    fi

    # datanode 2 and nodemanager 2
    if ! docker inspect ${DN_2_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_2_CONTAINER_NAME} \
            --hostname ${DN_2_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6 bash
    fi

    sleep 5
    cnt=0;
    for container in "${NN_CONTAINER_NAME}" "${DN_1_CONTAINER_NAME}" "${DN_2_CONTAINER_NAME}"
    do
        if [ "$(docker inspect -f '{{.State.Status}}' ${container})" = "running" ]; then
            ((cnt++))
        else
            echo "${container} is not running"
            docker rm -f ${container}
        fi
    done
    if [ ${cnt} -eq 3 ]; then
        break
    fi
done

# Generate configs
cat > /tmp/core-site.xml << EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${NN_HOSTNAME}:8020</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-non-datanode.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-datanode-1.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_1_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_1_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_1_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_1_HOSTNAME}</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-datanode-2.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_2_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_2_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_2_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_2_HOSTNAME}</value>
    </property>
</configuration>
EOF

cat > /tmp/yarn-site.xml << EOF
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>${NN_HOSTNAME}</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
    <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>4</value>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>
</configuration>
EOF

cat > /tmp/mapred-site.xml << EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>/opt/hadoop/share/hadoop/mapreduce/*,/opt/hadoop/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOF

for container in "${NN_CONTAINER_NAME}" "${DN_1_CONTAINER_NAME}" "${DN_2_CONTAINER_NAME}"
do
    docker cp /tmp/core-site.xml ${container}:/opt/hadoop/etc/hadoop/core-site.xml
    docker cp /tmp/hdfs-site-for-non-datanode.xml ${container}:/opt/hadoop/etc/hadoop/hdfs-site.xml
    docker cp /tmp/yarn-site.xml ${container}:/opt/hadoop/etc/hadoop/yarn-site.xml
    docker cp /tmp/mapred-site.xml ${container}:/opt/hadoop/etc/hadoop/mapred-site.xml
done
docker cp /tmp/hdfs-site-for-datanode-1.xml ${DN_1_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/hdfs-site-for-datanode-2.xml ${DN_2_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml

# Format
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs namenode -format'
docker exec ${DN_1_CONTAINER_NAME} bash -c 'mkdir -p /opt/hadoop/data'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'mkdir -p /opt/hadoop/data'

# Retart all daemons
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs --daemon stop namenode; hdfs --daemon start namenode'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn --daemon stop resourcemanager; yarn --daemon start resourcemanager'
docker exec ${DN_1_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${DN_1_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'

# Report status
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs dfsadmin -report'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn node -list -showDetails'
```

**Test:**

```sh
docker exec ${NN_CONTAINER_NAME} bash -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn application -list -appStates ALL'
```

## 2.2 Configuration

1. `core-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/core-site.xml`
    * Description: Contains configuration settings for Hadoop's core system, including the default filesystem URI.
    * [core-default.xml](https://hadoop.apache.org/docs/r3.3.6/hadoop-project-dist/hadoop-common/core-default.xml)
1. `hdfs-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/hdfs-site.xml`
    * Description: Contains configuration settings specific to HDFS.
    * [hdfs-default.xml](https://hadoop.apache.org/docs/r3.3.6/hadoop-project-dist/hadoop-hdfs/hdfs-default.xml)
1. `yarn-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/yarn-site.xml`
    * Description: Contains configuration settings for YARN (Yet Another Resource Negotiator).
    * [yarn-default.xml](https://hadoop.apache.org/docs/r3.3.6/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)
1. `mapred-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/mapred-site.xml`
    * Description: Contains configuration settings specific to MapReduce.
    * [mapred-default.xml](https://hadoop.apache.org/docs/r3.3.6/hadoop-mapreduce-client/hadoop-mapreduce-client-core/mapred-default.xml)
1. `hadoop-env.sh`
    * Path: `$HADOOP_HOME/etc/hadoop/hadoop-env.sh`
    * Description: Sets environment variables for Hadoop processes, such as JAVA_HOME.
1. `yarn-env.sh`
    * Path: `$HADOOP_HOME/etc/hadoop/yarn-env.sh`
    * Description: Sets environment variables for YARN.
1. `log4j.properties`
    * Path: `$HADOOP_HOME/etc/hadoop/log4j.properties`
    * Description: Configures logging for Hadoop.

### 2.2.1 How to config dfs.nameservices

**`core-site.xml`**
```xml
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://mycluster</value>
    </property>
</configuration>
```

**`hdfs-site.xml`**
```xml
<configuration>
    <property>
        <name>dfs.nameservices</name>
        <value>mycluster</value>
    </property>

    <property>
        <name>dfs.ha.namenodes.mycluster</name>
        <value>p0,p1,p2</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.mycluster.p0</name>
        <value>192.168.0.1:12000</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.mycluster.p1</name>
        <value>192.168.0.2:12000</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.mycluster.p2</name>
        <value>192.168.0.3:12000</value>
    </property>

    <property>
        <name>dfs.client.failover.proxy.provider.mycluster</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>
    <property>
        <name>dfs.ha.automatic-failover.enabled.mycluster</name>
        <value>true</value>
    </property>
</configuration>
```

### 2.2.2 Support config hot loading

`FileSystem::CACHE` will cache filesystem object, cache key is built from `uri` and `Configuration`, if you only modify `hdfs-site.xml` file itself, the object `Configuration` will be exactly the same, so comes with the cache hit.

How to disable it?, set property `fs.<protocol>.impl.disable.cache` to `true` in `hdfs-site.xml`

* For hdfs, the property name is: `fs.hdfs.impl.disable.cache`

### 2.2.3 Hedge read

* `dfs.client.hedged.read.threadpool.size`
* `dfs.client.hedged.read.threshold.millis`

## 2.3 Command

### 2.3.1 daemon

```sh
hdfs --daemon stop namenode
hdfs --daemon stop datanode
yarn --daemon stop resourcemanager
yarn --daemon stop nodemanager
mapred --daemon stop historyserver

hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver
```

### 2.3.2 hdfs

#### 2.3.2.1 File Path

```sh
hdfs dfs -ls -R <path>
```

#### 2.3.2.2 File Status

```sh
hdfs fsck <path>
hdfs fsck <path> -files -blocks -replication
```

#### 2.3.2.3 Show Content

```sh
# For text file
hdfs dfs -cat <path>

# For avro file
hdfs dfs -text <path.avro>
```

#### 2.3.2.4 Grant Permission

```sh
hdfs dfs -setfacl -R -m user:hive:rwx /
hdfs dfs -setfacl -R -m default:user:hive:rwx /
hdfs dfs -getfacl /
```

### 2.3.3 yarn

#### 2.3.3.1 Node

```sh
yarn node -list
yarn node -list -showDetails
```

#### 2.3.3.2 Application

```sh
yarn application -list
yarn application -list -appStates ALL

yarn application -status <appid>
yarn logs -applicationId <appid>

yarn application -kill <appid>
```

## 2.4 Tips

### 2.4.1 How to access a hadoop cluster started via docker

For linux, there are two ways of approaching this:

1. Access hadoop via container's ip.

For mac with m chip, the above methods cannot work, because there will be an extra virtualization layer between mac and the container. Here are steps of how we can access hadoop in this situation:

* We can use hostname to access both namenode and datanode, the hostname must be resolved in both container and Mac, and the container's name should be the best solution.
1. Set port mapping for namenode's port (`8020` bydefault) and datanode's port (`9866` by default).
1. Update `/etc/hosts`, mapping hadoop's container's name to `127.0.0.1`.
1. Config `dfs.datanode.hostname` at hadoop side (i.e. Container side), set its value to container's name.
1. Config `dfs.client.use.datanode.hostname` to `true` at the client side (i.e. Mac side), otherwise it will use container's ip address, which is unconnected between mac and container because of the extra virtualization layer.
1. Access hadoop via container's name.

### 2.4.2 SDK don't recognize HADOOP_CONF_DIR automatically

You need to implement the parsing of the path yourself.

```java
    public static void main(String[] args) {
        Configuration hadoopConf = new Configuration();
        String hadoopConfDir = System.getenv(HADOOP_CONF_ENV);
        if (StringUtils.isNotBlank(hadoopConfDir)) {
            addHadoopConfIfFound(hadoopConf, hadoopConfDir);
        }
        // ...
    }

    private static void addHadoopConfIfFound(Configuration configuration,
            String possibleHadoopConfPath) {
        if (new File(possibleHadoopConfPath).exists()) {
            if (new File(possibleHadoopConfPath + "/core-site.xml").exists()) {
                configuration.addResource(
                        new org.apache.hadoop.fs.Path(possibleHadoopConfPath + "/core-site.xml"));
                LOGGER.debug("Adding {}/core-site.xml to hadoop configuration",
                        possibleHadoopConfPath);
            }
            if (new File(possibleHadoopConfPath + "/hdfs-site.xml").exists()) {
                configuration.addResource(
                        new org.apache.hadoop.fs.Path(possibleHadoopConfPath + "/hdfs-site.xml"));
                LOGGER.debug("Adding {}/hdfs-site.xml to hadoop configuration",
                        possibleHadoopConfPath);
            }
        }
    }
```

# 3 Spark

[What Is Apache Spark?](https://www.databricks.com/glossary/what-is-apache-spark)

![spark-cluster-overview](/images/Hadoop-Ecosystem/spark-cluster-overview.png)

## 3.1 Deployment

```sh
#!/bin/bash

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)

wget https://mirrors.tuna.tsinghua.edu.cn/apache/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
tar -zxf spark-3.5.1-bin-hadoop3.tgz

export SPARK_HOME=${ROOT}/spark-3.5.1-bin-hadoop3
cat > ${SPARK_HOME}/conf/spark-env.sh << 'EOF'
SPARK_MASTER_HOST=localhost
EOF

${SPARK_HOME}/sbin/start-master.sh
${SPARK_HOME}/sbin/start-worker.sh spark://127.0.0.1:7077
```

**Stop:**

```sh
${SPARK_HOME}/sbin/stop-master.sh
${SPARK_HOME}/sbin/stop-worker.sh
```

**Test:**

```sh
${SPARK_HOME}/bin/spark-shell

scala> val nums = sc.parallelize(1 to 10)
scala> println(nums.count())
scala> :quit

${SPARK_HOME}/bin/spark-submit ${SPARK_HOME}/examples/src/main/python/pi.py 10
```

## 3.2 Deployment via Docker

```sh
SHARED_NS=hadoop-ns
SPARK_MASTER_CONTAINER_NAME=spark-master
SPARK_WORKER_CONTAINER_NAME=spark-worker

docker run -dit \
  --name ${SPARK_MASTER_CONTAINER_NAME} \
  --hostname ${SPARK_MASTER_CONTAINER_NAME} \
  --network ${SHARED_NS} \
  -p 8080:8080 -p 7077:7077 \
  spark:3.5.6-java17 \
  bash

docker exec ${SPARK_MASTER_CONTAINER_NAME} /opt/spark/sbin/start-master.sh

docker run -dit \
  --name ${SPARK_WORKER_CONTAINER_NAME} \
  --hostname ${SPARK_WORKER_CONTAINER_NAME} \
  --network ${SHARED_NS} \
  spark:3.5.6-java17 \
  bash

docker exec ${SPARK_WORKER_CONTAINER_NAME} /opt/spark/sbin/start-worker.sh spark://${SPARK_MASTER_CONTAINER_NAME}:7077
```

**Test:**

```sh
docker exec -it ${SPARK_MASTER_CONTAINER_NAME} \
    /opt/spark/bin/spark-submit /opt/spark/examples/src/main/python/pi.py 10
```

## 3.3 Tips

### 3.3.1 Spark-Sql

```sql
show catalogs;
set catalog <catalog_name>;

show databases;
use <database_name>;
```

### 3.3.2 Spark-Shell

#### 3.3.2.1 Read parquet/orc/avro file

```sh
# avro is not built-in format
spark-shell --packages org.apache.spark:spark-avro_2.12:3.5.2
```

```sh
spark.read.format("parquet").load("hdfs://192.168.64.2/user/iceberg/demo/db/table/data/00000-0-e424d965-50e8-4f61-abc7-6e6c117876f4-0-00001.parquet").show(truncate=false)
spark.read.format("avro").load("hdfs://192.168.64.2/user/iceberg/demo/demo_namespace/demo_table/metadata/snap-2052751058123365495-1-7a31848a-3e5f-43c7-886a-0a8d5f6c8ed7.avro").show(truncate=false)
```

# 4 Hive

[What is Apache Hive?](https://www.databricks.com/glossary/apache-hive)

![hive_core_architecture](/images/Hadoop-Ecosystem/hive_core_architecture.jpeg)

## 4.1 Components

### 4.1.1 Hive-Server 2 (HS2)

HS2 supports multi-client concurrency and authentication. It is designed to provide better support for open API clients like JDBC and ODBC.

### 4.1.2 Hive Metastore Server (HMS)

The Hive Metastore (HMS) is a central repository of metadata for Hive tables and partitions in a relational database, and provides clients (including Hive, Impala and Spark) access to this information using the metastore service API. It has become a building block for data lakes that utilize the diverse world of open-source software, such as Apache Spark and Presto. In fact, a whole ecosystem of tools, open-source and otherwise, are built around the Hive Metastore, some of which this diagram illustrates.

## 4.2 Deployment via Docker

[Apache Hive - Quickstart](https://hive.apache.org/developement/quickstart/)

Here is a summary of the compatible versions of Apache Hive and Hadoop (refer to [Apache Hive Download](https://hive.apache.org/general/downloads/) for details):

* `Hive 4.0.0`: Works with `Hadoop 3.3.6`, `Tez 0.10.3`

**Issues:**

* **When setting `IS_RESUME=true`, container `hiveserver2` can restart if it is started via `docker run -d`. And it cannot restart if it is started via `docker create & docker start`, still don't know why.**
* **Don't use `apache-tez-0.10.3-bin.tar.gz` directly but use `share/tez.tar.gz` after uncompressing. ([Error: Could not find or load main class org.apache.tez.dag.app.DAGAppMaster](https://stackoverflow.com/questions/72211046/error-could-not-find-or-load-main-class-org-apache-tez-dag-app-dagappmaster))**

### 4.2.1 Prepare Hive Image

Add some tools to official image.

```sh
rm -rf /tmp/hive_with_tools
mkdir -p /tmp/hive_with_tools
cat > /tmp/hive_with_tools/Dockerfile << 'EOF'
FROM apache/hive:4.0.0
USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y sudo iproute2 iputils-ping netcat vim-tiny less

RUN mkdir -p /home/hive && chown -R hive:hive /home/hive

RUN echo "hive ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER hive
EOF

docker build -t apache/hive:4.0.0_with_tools /tmp/hive_with_tools
```

### 4.2.2 Hive with MapReduce on Yarn(Deprecated)

#### 4.2.2.1 Use built-in Derby

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
HIVE_METASTORE_CONTAINER_NAME=hive-metastore
HIVE_SERVER_CONTAINER_NAME=hive-server
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${SHARED_NS}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${SHARED_NS}
HIVE_DIR_NAME=hive-with-derby

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>mr</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Use customized entrypoint
cat > /tmp/updated_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/updated_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    --entrypoint /updated_entrypoint.sh \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e IS_RESUME=true \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'
```

Test:

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u 'jdbc:hive2://localhost:10000/' -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

#### 4.2.2.2 Use External Postgres

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
HIVE_METASTORE_CONTAINER_NAME=hive-metastore
HIVE_SERVER_CONTAINER_NAME=hive-server
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${SHARED_NS}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${SHARED_NS}
HIVE_DIR_NAME=hive-with-postgres
IS_RESUME="false"

POSTGRES_CONTAINER_NAME=postgres
POSTGRES_HOSTNAME=${POSTGRES_CONTAINER_NAME}.${SHARED_NS}
POSTGRES_USER="hive_postgres"
POSTGRES_PASSWORD="Abcd1234"
POSTGRES_DB="hive-metastore"

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${POSTGRES_CONTAINER_NAME} > /dev/null 2>&1

# How to use sql:
# 1. docker exec -it ${POSTGRES_CONTAINER_NAME} bash
# 2. psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
docker run -dit \
    --name ${POSTGRES_CONTAINER_NAME} \
    --hostname ${POSTGRES_HOSTNAME} \
    --network ${SHARED_NS} \
    -e POSTGRES_USER="${POSTGRES_USER}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    postgres:17.0

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DB}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>${POSTGRES_USER}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>${POSTGRES_PASSWORD}</value>
    </property>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>mr</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Prepare jdbc driver
if [ ! -e /tmp/postgresql-42.7.4.jar ]; then
    wget -O /tmp/postgresql-42.7.4.jar 'https://jdbc.postgresql.org/download/postgresql-42.7.4.jar'
fi

# Use customized entrypoint
cat > /tmp/updated_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/updated_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=${IS_RESUME} \
    --entrypoint /updated_entrypoint.sh \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=true \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'
```

Test:

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u 'jdbc:hive2://localhost:10000/' -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

### 4.2.3 Hive with Tez on Yarn

```plantuml
title Hive with Tez on YARN Execution Flow

actor User
participant "Hive CLI / Beeline" as Client
participant "HiveServer2" as HS2
participant "HiveCompiler" as Compiler
participant "Tez DAG Generator" as DAGGen
participant "YARN ResourceManager" as RM
participant "NodeManager(s)" as NM
participant "Tez AM (ApplicationMaster)" as TezAM

User -> Client: Submit SQL query
Client -> HS2: Send query
HS2 -> Compiler: Compile query
Compiler -> DAGGen: Convert to Tez DAG
HS2 -> RM: Request YARN resources for Tez AM
RM -> NM: Allocate container for Tez AM
NM -> TezAM: Launch Tez AM
TezAM -> RM: Register ApplicationMaster
HS2 -> TezAM: Submit DAG
TezAM -> RM: Request containers for tasks

loop For each task
    RM -> NM: Allocate container for task
    TezAM -> NM: Launch task container
    NM -> TezAM: Run Tez task (mapper/reducer)
end

TezAM -> HS2: Report DAG completion
HS2 -> Client: Return results
```

#### 4.2.3.1 Use built-in Derby

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
HIVE_METASTORE_CONTAINER_NAME=hive-metastore
HIVE_SERVER_CONTAINER_NAME=hive-server
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${SHARED_NS}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${SHARED_NS}
HIVE_DIR_NAME=hive-with-derby

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz 'https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz'
fi
docker exec ${NN_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${NN_CONTAINER_NAME}:/opt/tez
docker exec ${NN_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.runtime.optimize.local.fetch</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.exec.submit.local.task.via.child</name>
        <value>false</value>
    </property>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Use customized entrypoint
cat > /tmp/updated_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/updated_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    --entrypoint /updated_entrypoint.sh \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e IS_RESUME=true \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'
```

Test:

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u 'jdbc:hive2://localhost:10000/' -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

#### 4.2.3.2 Use External Postgres

```sh
SHARED_NS=hadoop-ns
NN_CONTAINER_NAME=namenode
NN_HOSTNAME=${NN_CONTAINER_NAME}.${SHARED_NS}
HIVE_METASTORE_CONTAINER_NAME=hive-metastore
HIVE_SERVER_CONTAINER_NAME=hive-server
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${SHARED_NS}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${SHARED_NS}
HIVE_DIR_NAME=hive-with-postgres
IS_RESUME="false"

POSTGRES_CONTAINER_NAME=postgres
POSTGRES_HOSTNAME=${POSTGRES_CONTAINER_NAME}.${SHARED_NS}
POSTGRES_USER="hive_postgres"
POSTGRES_PASSWORD="Abcd1234"
POSTGRES_DB="hive-metastore"

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${POSTGRES_CONTAINER_NAME} > /dev/null 2>&1

# How to use sql:
# 1. docker exec -it ${POSTGRES_CONTAINER_NAME} bash
# 2. psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
docker run -dit \
    --name ${POSTGRES_CONTAINER_NAME} \
    --hostname ${POSTGRES_HOSTNAME} \
    --network ${SHARED_NS} \
    -e POSTGRES_USER="${POSTGRES_USER}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    postgres:17.0

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz 'https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz'
fi
docker exec ${NN_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${NN_CONTAINER_NAME}:/opt/tez
docker exec ${NN_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DB}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>${POSTGRES_USER}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>${POSTGRES_PASSWORD}</value>
    </property>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.runtime.optimize.local.fetch</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.exec.submit.local.task.via.child</name>
        <value>false</value>
    </property>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Prepare jdbc driver
if [ ! -e /tmp/postgresql-42.7.4.jar ]; then
    wget -O /tmp/postgresql-42.7.4.jar 'https://jdbc.postgresql.org/download/postgresql-42.7.4.jar'
fi

# Use customized entrypoint
cat > /tmp/updated_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/updated_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=${IS_RESUME} \
    --entrypoint /updated_entrypoint.sh \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=true \
    apache/hive:4.0.0_with_tools

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'
```

Test:

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u 'jdbc:hive2://localhost:10000/' -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

### 4.2.4 Tips

1. Logdir: `/tmp/hive`

## 4.3 Hive Metastore Demo

[hive_metastore.thrift](https://github.com/apache/hive/blob/master/standalone-metastore/metastore-common/src/main/thrift/hive_metastore.thrift)

```sh
mkdir hive_metastore_demo
cd hive_metastore_demo

wget https://raw.githubusercontent.com/apache/hive/master/standalone-metastore/metastore-common/src/main/thrift/hive_metastore.thrift
```

Modify `hive_metastore.thrift`, remove `fb` parts:

```diff
25,26d24
< include "share/fb303/if/fb303.thrift"
<
2527c2525
< service ThriftHiveMetastore extends fb303.FacebookService
---
> service ThriftHiveMetastore
```

```sh
thrift --gen cpp hive_metastore.thrift

mkdir build

# create libhms.a
gcc -o build/ThriftHiveMetastore.o -c gen-cpp/ThriftHiveMetastore.cpp -O3 -Wall -fPIC
gcc -o build/hive_metastore_constants.o -c gen-cpp/hive_metastore_constants.cpp -O3 -Wall -fPIC
gcc -o build/hive_metastore_types.o -c gen-cpp/hive_metastore_types.cpp -O3 -Wall -fPIC
ar rcs build/libhms.a build/ThriftHiveMetastore.o build/hive_metastore_constants.o build/hive_metastore_types.o

# main.cpp
cat > main.cpp << 'EOF'
#include <thrift/protocol/TBinaryProtocol.h>
#include <thrift/transport/TSocket.h>
#include <thrift/transport/TTransportUtils.h>

#include <iostream>

#include "gen-cpp/ThriftHiveMetastore.h"

using namespace apache::thrift;
using namespace apache::thrift::transport;
using namespace apache::thrift::protocol;

int main(int argc, char* argv[]) {
    if (argc < 4) {
        std::cerr << "requires 4 arguments" << std::endl;
        return 1;
    }
    const std::string hms_ip = argv[1];
    const int hms_port = std::atoi(argv[2]);
    const std::string db_name = argv[3];
    const std::string table_name = argv[4];

    std::cout << "hms_ip: " << hms_ip << ", hms_port: " << hms_port << ", db_name: " << db_name
              << ", table_name: " << table_name << std::endl;

    std::shared_ptr<TTransport> socket(new TSocket(hms_ip, hms_port));
    std::shared_ptr<TTransport> transport(new TBufferedTransport(socket));
    std::shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));
    Apache::Hadoop::Hive::ThriftHiveMetastoreClient client(protocol);

    try {
        transport->open();

        // Fetch and print the list of databases
        std::vector<std::string> databases;
        client.get_all_databases(databases);
        std::cout << "Databases:" << std::endl;
        for (const auto& db : databases) {
            std::cout << "    " << db << std::endl;
        }

        // Fetch and print the list of tables in a specific database
        std::vector<std::string> tables;
        client.get_all_tables(tables, db_name);
        std::cout << "Tables in database '" << db_name << "':" << std::endl;
        for (const auto& table : tables) {
            std::cout << "    " << table << std::endl;
        }

        // Fetch and print the details of a specific table
        Apache::Hadoop::Hive::Table table;
        client.get_table(table, db_name, table_name);
        std::cout << "Table details for '" << table_name << "':" << std::endl;
        std::cout << "    Table name: " << table.tableName << std::endl;
        std::cout << "    Database name: " << table.dbName << std::endl;
        std::cout << "    Owner: " << table.owner << std::endl;
        std::cout << "    Create time: " << table.createTime << std::endl;
        std::cout << "    Location: " << table.sd.location << std::endl;

        transport->close();
    } catch (TException& tx) {
        std::cerr << "Exception occurred: " << tx.what() << std::endl;
    }

    return 0;
}
EOF

gcc -o build/main main.cpp -O3 -Lbuild -lhms -lstdc++ -std=gnu++17 -lthrift -lm
build/main <ip> 9083 default hive_test_table
```

## 4.4 Syntax

### 4.4.1 Partition

```sql
CREATE TABLE sales (
  sale_id INT,
  product STRING,
  amount DOUBLE
)
PARTITIONED BY (year INT, month INT)
STORED AS PARQUET;

INSERT INTO TABLE sales PARTITION (year=2023, month=6)
VALUES
  (1, 'Product A', 100.0),
  (2, 'Product B', 150.0),
  (3, 'Product C', 200.0);

INSERT INTO TABLE sales PARTITION (year=2023, month=7)
VALUES
  (4, 'Product D', 120.0),
  (5, 'Product E', 130.0),
  (6, 'Product F', 140.0);

SELECT * FROM sales;
```

## 4.5 Configuration Properties

* `hive.enforce.bucketing`: Whether bucketing is enforced. If true, while inserting into the table, bucketing is enforced.
    * Hive 0.x: false
    * Hive 1.x: false
    * Hive 2.x: removed, which effectively makes it always true.

# 5 Flink

Here's a example of how to use [docker-spark](https://github.com/big-data-europe/docker-spark) to start a flink cluster and do some tests.

```sh
git clone https://github.com/big-data-europe/docker-flink.git
cd docker-flink
docker-compose up -d

cat > person.csv << 'EOF'
1,"Tom",18
2,"Jerry",19
3,"Spike",20
4,"Tyke",21
EOF

docker exec flink-master mkdir -p /opt/data
docker exec flink-worker mkdir -p /opt/data
docker cp person.csv flink-master:/opt/data/person.csv
docker cp person.csv flink-worker:/opt/data/person.csv

docker exec -it flink-master bash
sql-client.sh

CREATE TABLE person (
    id INT,
    name STRING,
    age INT
) WITH (
    'connector' = 'filesystem',
    'path' = 'file:///opt/data/person.csv',
    'format' = 'csv'
);

SELECT * FROM person;
```

# 6 Deployment with Kerberos

## 6.1 Kerberos Component Relationship

```plantuml
' ============================================
' Kerberos component diagram (improved version)
' ============================================

skinparam component {
  BackgroundColor #F6F6F6
  BorderColor #333333
  FontSize 12
  FontName "Segoe UI"
}
skinparam arrow {
  Color #555555
  Thickness 1.2
}

title Kerberos Component Relationship Diagram

' ---- Define components ----
package "Kerberos KDC" {
  [Authentication Server\n(AS)] as AS
  [Ticket‑Granting Server\n(TGS)] as TGS
  [Kerberos Database] as DB
}

[Kerberos Admin Server\n(kadmin / kpasswd)] as KADMIN
[Client\n(kinit / libkrb5)] as CLIENT
[Application Server\n(Service)] as SERVICE

' ---- Component interactions ----
DB --> AS : Lookup user secret keys
DB --> TGS : Lookup service secret keys
KADMIN --> DB : Register user/service principals\nReset passwords, etc.

CLIENT -up-> AS : ① AS-REQ (username)
AS -down-> CLIENT : ② AS-REP (TGT encrypted with KDC key\nSession key encrypted with user key)

CLIENT -up-> TGS : ③ TGS-REQ (TGT + service principal\n+ authenticator)
TGS -down-> CLIENT : ④ TGS-REP (Service Ticket\nencrypted with session key)

CLIENT -up-> SERVICE : ⑤ AP-REQ (Service Ticket\n+ timestamp authenticator)
SERVICE -down-> CLIENT : ⑥ AP-REP (optional\nmutual authentication)

' ---- Note to clarify service key usage ----
note right of SERVICE
  Uses key registered in DB
  (no direct DB access)
end note

legend right
<color:#0000FF>**Kerberos Protocol Flow**</color>
①-⑥ Standard authentication sequence
* TGT = Ticket-Granting Ticket (KDC encrypted)
* Service Ticket = Encrypted with service key
* Authenticator contains timestamp
* Session key shared between client and service
endlegend
```

| Step | Initiator | Receiver | Description|
|:--|:--|:--|:--|
| ① | CLIENT | AS | Requests initial ticket (TGT) |
| ② | AS | CLIENT | Returns encrypted TGT and session key |
| ③ | CLIENT | TGS| Requests service ticket using TGT |
| ④ | TGS| CLIENT | Returns encrypted service ticket and session key |
| ⑤ | CLIENT | SERVICE| Uses service ticket to request access |
| ⑥ | SERVICE| CLIENT | Optional mutual authentication response |

## 6.2 Kerberos Basics

**Concepts:**

* Key Distribution Center, KDC
    * The central server responsible for managing authentication.
    * Comprises two sub-components:
        * Authentication Server (AS): Authenticates the client and issues the Ticket Granting Ticket (TGT).
        * Ticket Granting Server (TGS): Issues service-specific tickets upon request.
* Principal: A unique identity (user, service, or host) in the Kerberos system, e.g., `user@REALM` or `service/hostname@REALM`.
* Realm: A logical network served by a single KDC, identified by an uppercase string, e.g., `EXAMPLE.COM`.
* Keytab: A file storing pre-shared credentials for a user or service, used for automated authentication.
* Ticket: A temporary set of credentials that allows a principal to authenticate to services.
    * Ticket Granting Ticket (TGT): Issued by the AS, used to request service tickets.
    * Service Ticket: Allows access to a specific service.

**Kerberos Commands:**

* `kinit <principal>[@<kerberos_realm>]`: Login with password.
    * `kinit -c <cache_path> <principal>[@<kerberos_realm>]`: Login with password and specific cache path.
* `kinit -kt <keytabpath> <principal>[@<kerberos_realm>]`: Login with keytab.
    * `kinit -kt <keytabpath> -c <cache_path> <principal>[@<kerberos_realm>]`: Login with keytab and specific cache path.
* `klist`: Display credentials cache.
* `klist -c <cache_path>`: Display specifies credentials cache.
* `klist -e -d -k -t -K <keytabpath>`: Display keytab information.
* `kdestroy`: Destroy credentials cache.
* `kdestroy -c <cache_path>`: Destroy specifies credentials cache.
* Environments:
    * `export KRB5_TRACE=/dev/stdout`: For debug.
    * `export KRB5_CONFIG=<path/to/krb5.conf>`: Specify the config file, parse logic domain to real domain.
    * `export KRB5CCNAME=FILE:/tmp/krb5cc_testuser`: Use local file as cache.
    * `export KRB5CCNAME=MEMORY:`: Use meory as cache.

**`kadmin.local` Commands:**

* `?`: help doc.

**Tips:**

* Make sure target user has permission to read related files, including config, TGT, keyTab etc.

## 6.3 Prepare Kerberos Images

### 6.3.1 ubuntu:xenial_with_kerberos

```sh
rm -rf /tmp/ubuntu-with-kerberos
mkdir -p /tmp/ubuntu-with-kerberos
cat > /tmp/ubuntu-with-kerberos/Dockerfile << 'EOF'
FROM ubuntu:xenial

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y ntp python-dev python-pip python-wheel python-setuptools python-pkg-resources \
    krb5-admin-server krb5-kdc \
    vim iputils-ping iproute2 less
EOF

docker build -t ubuntu:xenial_with_kerberos /tmp/ubuntu-with-kerberos
```

### 6.3.2 apache/hadoop:3.3.6_with_kerberos

In `org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor` mode, `/opt/hadoop/bin/container-executor` is used as the Linux container executor. This binary depends on `libcrypto.so.1.1`, but the default image only includes `libcrypto.so.1.0`, so `libcrypto.so.1.1` needs to be installed manually.

```sh
rm -rf /tmp/hadoop_with_libs
mkdir -p /tmp/hadoop_with_libs
cat > /tmp/hadoop_with_libs/Dockerfile << 'EOF'
FROM apache/hadoop:3.3.6
USER root

RUN wget --no-check-certificate -O /opt/openssl-1.1.1w.tar.gz 'https://www.openssl.org/source/openssl-1.1.1w.tar.gz'
RUN tar -zxvf /opt/openssl-1.1.1w.tar.gz -C /opt/
RUN mv /etc/yum.repos.d /etc/yum.repos.d.bak
RUN mkdir /etc/yum.repos.d
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
RUN yum clean all
RUN yum makecache
RUN yum install -y perl gcc make
RUN cd /opt/openssl-1.1.1w && ./config && make -j $(( (cores=$(nproc))>1?cores/2:1 )) && make install && echo '/usr/local/lib64' | tee /etc/ld.so.conf.d/crypto.conf && ldconfig

USER hadoop
EOF

docker build -t apache/hadoop:3.3.6_with_libs /tmp/hadoop_with_libs
```

### 6.3.3 apache/hive:4.0.0_with_kerberos

```sh
rm -rf /tmp/hive_with_kerberos
mkdir -p /tmp/hive_with_kerberos
cat > /tmp/hive_with_kerberos/Dockerfile << 'EOF'
FROM apache/hive:4.0.0
USER root

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y krb5-user libkrb5-3 \
    sudo iproute2 iputils-ping netcat vim-tiny less

RUN mkdir -p /home/hive && chown -R hive:hive /home/hive

RUN echo "hive ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /etc/security/keytabs && chmod 755 /etc/security/keytabs

USER hive
EOF

docker build -t apache/hive:4.0.0_with_kerberos /tmp/hive_with_kerberos
```

## 6.4 Deploy Kerberos

**Key points:**

* To ensure proper Kerberos authentication, it's essential that each component's hostname resolves consistently in both forward and reverse DNS lookups. Otherwise, Kerberos authentication may fail due to hostname mismatches.
    * Forward DNS lookup: `getent hosts <domain>`
    * Reverse DNS lookup: `getent hosts <ip>`
* The simplest approach is to use the Docker network namespace name as the Kerberos realm domain name. This naturally aligns with Docker's DNS resolution mechanism, ensuring that both forward and reverse lookups work consistently with Kerberos principals.

```sh
SHARED_NS=liuyehcf.org
# Kerberos
REAL_DOMAIN=${SHARED_NS}
KERBEROS_CONTAINER_NAME=kerberos
KERBEROS_HOSTNAME=${KERBEROS_CONTAINER_NAME}.${REAL_DOMAIN}
KERBEROS_LOGIC_DOMAIN=example.com
KERBEROS_LOGIC_DOMAIN_UPPER=$(echo ${KERBEROS_LOGIC_DOMAIN} | tr "[:lower:]" "[:upper:]")
# Hadoop, One Container per Component Architecture
NN_CONTAINER_NAME=namenode-with-kerberos
DN_CONTAINER_NAME=datanode-with-kerberos
NM_CONTAINER_NAME=nodemanager-with-kerberos
RM_CONTAINER_NAME=resourcemanager-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
DN_HOSTNAME=${DN_CONTAINER_NAME}.${REAL_DOMAIN}
NM_HOSTNAME=${NM_CONTAINER_NAME}.${REAL_DOMAIN}
RM_HOSTNAME=${RM_CONTAINER_NAME}.${REAL_DOMAIN}
# Hadoop, Multi-Component Shared Container Model
NN_CONTAINER_NAME=namenode-with-kerberos
DN_1_CONTAINER_NAME=datanode-1-with-kerberos
DN_2_CONTAINER_NAME=datanode-2-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
DN_1_HOSTNAME=${DN_1_CONTAINER_NAME}.${REAL_DOMAIN}
DN_2_HOSTNAME=${DN_2_CONTAINER_NAME}.${REAL_DOMAIN}
# Hive
HIVE_METASTORE_CONTAINER_NAME=hive-metastore-with-kerberos
HIVE_SERVER_CONTAINER_NAME=hive-server-with-kerberos
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${REAL_DOMAIN}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${REAL_DOMAIN}

# Must explicit mapping for udp, otherwise ICMP package from host machine cannot work with kerberos inside container.
docker run -dit \
    --name ${KERBEROS_CONTAINER_NAME} \
    --hostname ${KERBEROS_HOSTNAME} \
    --network ${SHARED_NS} --privileged \
    -p 127.0.0.1:88:88/tcp -p 127.0.0.1:88:88/udp \
    -p 127.0.0.1:464:464/tcp -p 127.0.0.1:464:464/udp \
    -p 127.0.0.1:749:749/tcp -p 127.0.0.1:749:749/udp \
    ubuntu:xenial_with_kerberos

# Setup kerberos config
docker exec ${KERBEROS_CONTAINER_NAME} bash -c "tee /etc/krb5.conf > /dev/null << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF"

docker exec ${KERBEROS_CONTAINER_NAME} bash -c "cat > /etc/krb5kdc/kdc.conf << EOF
[kdcdefaults]
    kdc_ports = 88
    kdc_tcp_ports = 88

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        database_name = /var/lib/krb5kdc/principal
        admin_keytab = /etc/krb5kdc/kadm5.keytab
        acl_file = /etc/krb5kdc/kadm5.acl
        key_stash_file = /etc/krb5kdc/stash
        log_file = /var/log/krb5kdc.log
        kdc_ports = 88
        max_life = 10h 0m 0s
        max_renewable_life = 7d 0h 0m 0s
    }
EOF"

docker exec ${KERBEROS_CONTAINER_NAME} bash -c "cat > /etc/krb5kdc/kadm5.acl << EOF
*/admin@${KERBEROS_LOGIC_DOMAIN_UPPER} *
EOF"

docker exec ${KERBEROS_CONTAINER_NAME} bash -c 'kdb5_util create -s <<EOF
!Abcd1234
!Abcd1234
EOF'
docker exec ${KERBEROS_CONTAINER_NAME} bash -c '/usr/sbin/krb5kdc'
docker exec ${KERBEROS_CONTAINER_NAME} bash -c '/usr/sbin/kadmind'

# Create principal for hadoop
docker exec ${KERBEROS_CONTAINER_NAME} bash -c 'mkdir -p /etc/security/keytabs'
docker exec ${KERBEROS_CONTAINER_NAME} bash -c "kadmin.local <<EOF
addprinc -randkey nn/${NN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
addprinc -randkey dn/${DN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
addprinc -randkey nm/${NM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
addprinc -randkey rm/${RM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}

addprinc -randkey dn_1/${DN_1_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
addprinc -randkey dn_2/${DN_2_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
listprincs

ktadd -k /etc/security/keytabs/hadoop.service.keytab \
    nn/${NN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} \
    dn/${DN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} \
    nm/${NM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} \
    rm/${RM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} \
    \
    dn_1/${DN_1_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} \
    dn_2/${DN_2_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}

quit
EOF"

# Create principal for hive
docker exec ${KERBEROS_CONTAINER_NAME} bash -c 'mkdir -p /etc/security/keytabs'
docker exec ${KERBEROS_CONTAINER_NAME} bash -c "kadmin.local <<EOF
addprinc -randkey hive/${HIVE_METASTORE_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
addprinc -randkey hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}
listprincs

ktadd -k /etc/security/keytabs/hive.service.keytab hive/${HIVE_METASTORE_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER} hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}

quit
EOF"

# Create principal for user_with_password
docker exec ${KERBEROS_CONTAINER_NAME} bash -c "kadmin.local <<EOF
addprinc -pw 123456 user_with_password@${KERBEROS_LOGIC_DOMAIN_UPPER}
listprincs

quit
EOF"

# Create principal for user_with_keytab
docker exec ${KERBEROS_CONTAINER_NAME} bash -c "kadmin.local <<EOF
addprinc -randkey user_with_keytab@${KERBEROS_LOGIC_DOMAIN_UPPER}
ktadd -k /etc/security/keytabs/user_with_keytab.service.keytab user_with_keytab@${KERBEROS_LOGIC_DOMAIN_UPPER}
listprincs

quit
EOF"
```

**Test:**

* Test user_with_password

    ```sh
    # inside docker(password: 123456)
    kinit user_with_password
    klist

    # outside docker(password: 123456)
    docker cp ${KERBEROS_CONTAINER_NAME}:/etc/krb5.conf ~/.krb5.conf
    sudo sed -i "/127.0.0.1 ${KERBEROS_HOSTNAME}/d" /etc/hosts
    echo "127.0.0.1 ${KERBEROS_HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null
    export KRB5_CONFIG=~/.krb5.conf
    kinit user_with_password
    klist
    ```

* Test user_with_keytab

    ```sh
    # inside docker
    kinit -kt /etc/security/keytabs/user_with_keytab.service.keytab user_with_keytab
    klist

    # outside docker
    docker cp ${KERBEROS_CONTAINER_NAME}:/etc/krb5.conf ~/.krb5.conf
    sudo sed -i "/127.0.0.1 ${KERBEROS_HOSTNAME}/d" /etc/hosts
    echo "127.0.0.1 ${KERBEROS_HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null
    docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/user_with_keytab.service.keytab ~/.user_with_keytab.service.keytab
    export KRB5_CONFIG=~/.krb5.conf
    kinit -kt ~/.user_with_keytab.service.keytab user_with_keytab
    klist
    ```

## 6.5 Deploy Hadoop

**Key points:**

* Do not use the `_HOST` placeholder in Kerberos principal configuration, because the configuration will be shard by multiply containers, like hadoop, hive, etc.
* Directory `/opt/hadoop/data` must can be accessed by the user started datanode.
* Credential file `/etc/security/keytabs/hadoop.service.keytab` must can be accessed by the user started datanode.
* If `ignore.secure.ports.for.testing` is set to `false`, then the http port and tcp port must be smaller than 1023, otherwise it cannot pass the check.
* Remember kinit before execute any hadoop commands, like `hdfs`, `yarn`.
* When use `<principal>` to submit mapreduce task, the node manager must has the Linux account with the same name as `<principal>` for writing data/logs locally. (Other node, like namenode, datanode, resourcemanager are not required to have the Linux account)

### 6.5.1 One Container per Component Architecture

```sh
SHARED_NS=liuyehcf.org
# Kerberos
REAL_DOMAIN=${SHARED_NS}
KERBEROS_CONTAINER_NAME=kerberos
KERBEROS_HOSTNAME=${KERBEROS_CONTAINER_NAME}.${REAL_DOMAIN}
KERBEROS_LOGIC_DOMAIN=example.com
KERBEROS_LOGIC_DOMAIN_UPPER=$(echo ${KERBEROS_LOGIC_DOMAIN} | tr "[:lower:]" "[:upper:]")
# Hadoop, One Container per Component Architecture
NN_CONTAINER_NAME=namenode-with-kerberos
DN_CONTAINER_NAME=datanode-with-kerberos
NM_CONTAINER_NAME=nodemanager-with-kerberos
RM_CONTAINER_NAME=resourcemanager-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
DN_HOSTNAME=${DN_CONTAINER_NAME}.${REAL_DOMAIN}
NM_HOSTNAME=${NM_CONTAINER_NAME}.${REAL_DOMAIN}
RM_HOSTNAME=${RM_CONTAINER_NAME}.${REAL_DOMAIN}

docker rm -f ${NN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${NM_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${RM_CONTAINER_NAME} > /dev/null 2>&1

# Hadoop container is not stable in MacOS, always exited right after started without any logs, so start them in loop here.
while true; do
    # namenode
    if ! docker inspect ${NN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NN_CONTAINER_NAME} \
            --hostname ${NN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8020:8020 \
            apache/hadoop:3.3.6_with_libs bash
    fi

    # datanode
    if ! docker inspect ${DN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_CONTAINER_NAME} \
            --hostname ${DN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:9866:9866 \
            apache/hadoop:3.3.6_with_libs bash
    fi

    # nodemanager
    if ! docker inspect ${NM_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NM_CONTAINER_NAME} \
            --hostname ${NM_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8042:8042 \
            apache/hadoop:3.3.6_with_libs bash
    fi

    # resourcemanager
    if ! docker inspect ${RM_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${RM_CONTAINER_NAME} \
            --hostname ${RM_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            -p 127.0.0.1:8088:8088 \
            apache/hadoop:3.3.6_with_libs bash
    fi

    sleep 5
    cnt=0;
    for container in "${NN_CONTAINER_NAME}" "${DN_CONTAINER_NAME}" "${NM_CONTAINER_NAME}" "${RM_CONTAINER_NAME}"
    do
        if [ "$(docker inspect -f '{{.State.Status}}' ${container})" = "running" ]; then
            ((cnt++))
        else
            echo "${container} is not running"
            docker rm -f ${container}
        fi
    done
    if [ ${cnt} -eq 4 ]; then
        break
    fi
done

# Generate configs
cat > /tmp/core-site.xml << EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${NN_HOSTNAME}:8020</value>
    </property>
    <property>
      <name>hadoop.security.authentication</name>
      <value>kerberos</value>
    </property>
    <property>
      <name>hadoop.security.authorization</name>
      <value>true</value>
    </property>

    <property>
        <name>hadoop.proxyuser.hadoop.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hadoop.groups</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hive.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hive.groups</name>
        <value>*</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_HOSTNAME}</value>
    </property>

    <property>
        <name>dfs.namenode.kerberos.principal</name>
        <value>nn/${NN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>dfs.namenode.keytab.file</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>dn/${DN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>

    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.block.access.token.master.key.num</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.block.access.token.lifetime</name>
        <value>600</value>
    </property>
    <property>
        <name>ignore.secure.ports.for.testing</name>
        <value>true</value>
    </property>
</configuration>
EOF

cat > /tmp/yarn-site.xml << EOF
<configuration>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>${RM_HOSTNAME}</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>${RM_HOSTNAME}:8031</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>4</value>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>

    <property>
        <name>yarn.resourcemanager.principal</name>
        <value>rm/${RM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>yarn.resourcemanager.keytab</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>yarn.nodemanager.principal</name>
        <value>nm/${NM_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>yarn.nodemanager.keytab</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>

    <property>
        <name>yarn.acl.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.nodemanager.container-executor.class</name>
        <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
    </property>
</configuration>
EOF

cat > /tmp/mapred-site.xml << EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>/opt/hadoop/share/hadoop/mapreduce/*,/opt/hadoop/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOF

# Set yarn.nodemanager.container-executor.class to org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor will use /opt/hadoop/bin/container-executor as executor
# Config for /opt/hadoop/bin/container-executor(users is group which account hadoop belongs to)
cat > /tmp/container-executor.cfg << EOF
yarn.nodemanager.local-dirs=/opt/hadoop/data
yarn.nodemanager.log-dirs=/opt/hadoop/logs
min.user.id=1000
allowed.system.users=hadoop
yarn.nodemanager.linux-container-executor.group=users
banned.users=root
EOF

# Generate kerberos config
cat > /tmp/krb5.conf << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF

docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hadoop.service.keytab /tmp/hadoop.service.keytab

for container in "${NN_CONTAINER_NAME}" "${DN_CONTAINER_NAME}" "${NM_CONTAINER_NAME}" "${RM_CONTAINER_NAME}"
do
    docker cp /tmp/core-site.xml ${container}:/opt/hadoop/etc/hadoop/core-site.xml
    docker cp /tmp/hdfs-site.xml ${container}:/opt/hadoop/etc/hadoop/hdfs-site.xml
    docker cp /tmp/yarn-site.xml ${container}:/opt/hadoop/etc/hadoop/yarn-site.xml
    docker cp /tmp/mapred-site.xml ${container}:/opt/hadoop/etc/hadoop/mapred-site.xml
    docker cp /tmp/krb5.conf ${container}:/etc/krb5.conf

    # Copy keytab
    docker cp /tmp/hadoop.service.keytab ${container}:/etc/security/keytabs/hadoop.service.keytab
    docker exec ${container} bash -c 'sudo chmod 644 /etc/security/keytabs/hadoop.service.keytab'
done

# Linux Container Executor permissions(users is group which account hadoop belongs to) and create Linux account user_with_password
docker cp /tmp/container-executor.cfg ${NM_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/container-executor.cfg
docker exec ${NM_CONTAINER_NAME} bash -c '
sudo chown -R root:users /opt
sudo chmod 0400 /opt/hadoop/etc/hadoop/container-executor.cfg
sudo chmod 6050 /opt/hadoop/bin/container-executor
sudo useradd -m user_with_password
sudo usermod -a -G hadoop user_with_password
'

# Format
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs namenode -format'
docker exec ${DN_CONTAINER_NAME} bash -c 'mkdir -p /opt/hadoop/data'

# Retart all daemons
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs --daemon stop namenode; hdfs --daemon start namenode'
docker exec ${DN_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${NM_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'
docker exec ${RM_CONTAINER_NAME} bash -c 'yarn --daemon stop resourcemanager; yarn --daemon start resourcemanager'

# Report status
docker exec ${NN_CONTAINER_NAME} bash -c "kinit user_with_password <<EOF
123456
EOF"
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs dfsadmin -report'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn node -list -showDetails'
```

**Verify**

```sh
for container in "${NN_HOSTNAME}" "${DN_HOSTNAME}" "${NM_HOSTNAME}" "${RM_HOSTNAME}"
do
    forward_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${container}")
    ip=$(echo ${forward_lookup} | cut -d " " -f1)
    reverse_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${ip}")

    if [ "${forward_lookup}" = "${reverse_lookup}" ]; then
        echo "DNS check for container host '${container}'" is successful.
    else
        echo "DNS check for container host '${container}'" is failed.
    fi
done
```

**Test:**

```sh
docker exec ${NN_CONTAINER_NAME} bash -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn application -list -appStates ALL'
```

### 6.5.2 Multi-Component Shared Container Model

```sh
SHARED_NS=liuyehcf.org
# Kerberos
REAL_DOMAIN=${SHARED_NS}
KERBEROS_CONTAINER_NAME=kerberos
KERBEROS_HOSTNAME=${KERBEROS_CONTAINER_NAME}.${REAL_DOMAIN}
KERBEROS_LOGIC_DOMAIN=example.com
KERBEROS_LOGIC_DOMAIN_UPPER=$(echo ${KERBEROS_LOGIC_DOMAIN} | tr "[:lower:]" "[:upper:]")
# Hadoop, One Container per Component Architecture
NN_CONTAINER_NAME=namenode-with-kerberos
DN_1_CONTAINER_NAME=datanode-1-with-kerberos
DN_2_CONTAINER_NAME=datanode-2-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
DN_1_HOSTNAME=${DN_1_CONTAINER_NAME}.${REAL_DOMAIN}
DN_2_HOSTNAME=${DN_2_CONTAINER_NAME}.${REAL_DOMAIN}

docker rm -f ${NN_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_1_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${DN_2_CONTAINER_NAME} > /dev/null 2>&1

# Hadoop container is not stable in MacOS, always exited right after started without any logs, so start them in loop here.
while true; do
    # namenode and resourcemanager
    if ! docker inspect ${NN_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${NN_CONTAINER_NAME} \
            --hostname ${NN_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6_with_libs bash
    fi

    # datanode 1 and nodemanager 1
    if ! docker inspect ${DN_1_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_1_CONTAINER_NAME} \
            --hostname ${DN_1_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6_with_libs bash
    fi

    # datanode 2 and nodemanager 2
    if ! docker inspect ${DN_2_CONTAINER_NAME} > /dev/null 2>&1; then
        docker run -dit \
            --name ${DN_2_CONTAINER_NAME} \
            --hostname ${DN_2_HOSTNAME} \
            --network ${SHARED_NS} --privileged \
            apache/hadoop:3.3.6_with_libs bash
    fi

    sleep 5
    cnt=0;
    for container in "${NN_CONTAINER_NAME}" "${DN_1_CONTAINER_NAME}" "${DN_2_CONTAINER_NAME}"
    do
        if [ "$(docker inspect -f '{{.State.Status}}' ${container})" = "running" ]; then
            ((cnt++))
        else
            echo "${container} is not running"
            docker rm -f ${container}
        fi
    done
    if [ ${cnt} -eq 3 ]; then
        break
    fi
done

# Generate configs
cat > /tmp/core-site.xml << EOF
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://${NN_HOSTNAME}:8020</value>
    </property>
    <property>
      <name>hadoop.security.authentication</name>
      <value>kerberos</value>
    </property>
    <property>
      <name>hadoop.security.authorization</name>
      <value>true</value>
    </property>

    <property>
        <name>hadoop.proxyuser.hadoop.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hadoop.groups</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hive.hosts</name>
        <value>*</value>
    </property>
    <property>
        <name>hadoop.proxyuser.hive.groups</name>
        <value>*</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-non-datanode.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
        <property>
        <name>dfs.namenode.kerberos.principal</name>
        <value>nn/${NN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>dfs.namenode.keytab.file</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.block.access.token.master.key.num</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.block.access.token.lifetime</name>
        <value>600</value>
    </property>
    <property>
        <name>ignore.secure.ports.for.testing</name>
        <value>true</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-datanode-1.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_1_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_1_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_1_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_1_HOSTNAME}</value>
    </property>
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>dn_1/${DN_1_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.block.access.token.master.key.num</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.block.access.token.lifetime</name>
        <value>600</value>
    </property>
    <property>
        <name>ignore.secure.ports.for.testing</name>
        <value>true</value>
    </property>
</configuration>
EOF

cat > /tmp/hdfs-site-for-datanode-2.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.permissions.enabled</name>
        <value>false</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/hadoop/data</value>
    </property>
    <property>
        <name>dfs.datanode.address</name>
        <value>${DN_2_HOSTNAME}:9866</value>
    </property>
    <property>
        <name>dfs.datanode.http.address</name>
        <value>${DN_2_HOSTNAME}:9864</value>
    </property>
    <property>
        <name>dfs.datanode.ipc.address</name>
        <value>${DN_2_HOSTNAME}:9867</value>
    </property>
    <property>
        <name>dfs.datanode.hostname</name>
        <value>${DN_2_HOSTNAME}</value>
    </property>
    <property>
        <name>dfs.datanode.kerberos.principal</name>
        <value>dn_2/${DN_2_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>dfs.datanode.keytab.file</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>dfs.block.access.token.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.block.access.token.master.key.num</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.block.access.token.lifetime</name>
        <value>600</value>
    </property>
    <property>
        <name>ignore.secure.ports.for.testing</name>
        <value>true</value>
    </property>
</configuration>
EOF

YARN_SITE_CONFIG_COMMON=$(cat << EOF
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>${NN_HOSTNAME}</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>${NN_HOSTNAME}:8031</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
    <name>yarn.nodemanager.resource.memory-mb</name>
        <value>8192</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>4</value>
    </property>
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>1024</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>

    <property>
        <name>yarn.resourcemanager.principal</name>
        <value>nn/${NN_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>yarn.resourcemanager.keytab</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>
    <property>
        <name>yarn.nodemanager.keytab</name>
        <value>/etc/security/keytabs/hadoop.service.keytab</value>
    </property>

    <property>
        <name>yarn.acl.enable</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.nodemanager.container-executor.class</name>
        <value>org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor</value>
    </property>
EOF
)

cat > /tmp/yarn-site-for-non-datanode.xml << EOF
<configuration>
    ${YARN_SITE_CONFIG_COMMON}
</configuration>
EOF

cat > /tmp/yarn-site-for-datanode-1.xml << EOF
<configuration>
    ${YARN_SITE_CONFIG_COMMON}
    <property>
        <name>yarn.nodemanager.principal</name>
        <value>dn_1/${DN_1_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
</configuration>
EOF

cat > /tmp/yarn-site-for-datanode-2.xml << EOF
<configuration>
    ${YARN_SITE_CONFIG_COMMON}
    <property>
        <name>yarn.nodemanager.principal</name>
        <value>dn_2/${DN_2_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
</configuration>
EOF

cat > /tmp/mapred-site.xml << EOF
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/hadoop</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>/opt/hadoop/share/hadoop/mapreduce/*,/opt/hadoop/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>
EOF

# Set yarn.nodemanager.container-executor.class to org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor will use /opt/hadoop/bin/container-executor as executor
# Config for /opt/hadoop/bin/container-executor(users is group which account hadoop belongs to)
cat > /tmp/container-executor.cfg << EOF
yarn.nodemanager.local-dirs=/opt/hadoop/data
yarn.nodemanager.log-dirs=/opt/hadoop/logs
min.user.id=1000
allowed.system.users=hadoop
yarn.nodemanager.linux-container-executor.group=users
banned.users=root
EOF

# Generate kerberos config
cat > /tmp/krb5.conf << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF

docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hadoop.service.keytab /tmp/hadoop.service.keytab

for container in "${NN_CONTAINER_NAME}" "${DN_1_CONTAINER_NAME}" "${DN_2_CONTAINER_NAME}"
do
    docker cp /tmp/core-site.xml ${container}:/opt/hadoop/etc/hadoop/core-site.xml
    docker cp /tmp/hdfs-site-for-non-datanode.xml ${container}:/opt/hadoop/etc/hadoop/hdfs-site.xml
    docker cp /tmp/yarn-site-for-non-datanode.xml ${container}:/opt/hadoop/etc/hadoop/yarn-site.xml
    docker cp /tmp/mapred-site.xml ${container}:/opt/hadoop/etc/hadoop/mapred-site.xml
    docker cp /tmp/krb5.conf ${container}:/etc/krb5.conf

    # Copy keytab
    docker cp /tmp/hadoop.service.keytab ${container}:/etc/security/keytabs/hadoop.service.keytab
    docker exec ${container} bash -c 'sudo chmod 644 /etc/security/keytabs/hadoop.service.keytab'
done
docker cp /tmp/hdfs-site-for-datanode-1.xml ${DN_1_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site-for-datanode-1.xml ${DN_1_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/hdfs-site-for-datanode-2.xml ${DN_2_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site-for-datanode-2.xml ${DN_2_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml

# Linux Container Executor permissions(users is group which account hadoop belongs to) and create Linux account user_with_password
for container in "${DN_1_CONTAINER_NAME}" "${DN_2_CONTAINER_NAME}"
do
    docker cp /tmp/container-executor.cfg ${container}:/opt/hadoop/etc/hadoop/container-executor.cfg
    docker exec ${container} bash -c '
sudo chown -R root:users /opt
sudo chmod 0400 /opt/hadoop/etc/hadoop/container-executor.cfg
sudo chmod 6050 /opt/hadoop/bin/container-executor
sudo useradd -m user_with_password
sudo usermod -a -G hadoop user_with_password
'
done

# Format
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs namenode -format'
docker exec ${DN_1_CONTAINER_NAME} bash -c 'sudo mkdir -p /opt/hadoop/data && sudo chown -R hadoop:users /opt/hadoop/data'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'sudo mkdir -p /opt/hadoop/data && sudo chown -R hadoop:users /opt/hadoop/data'

# Retart all daemons
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs --daemon stop namenode; hdfs --daemon start namenode'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn --daemon stop resourcemanager; yarn --daemon start resourcemanager'

docker exec ${DN_1_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${DN_1_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${DN_2_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'

# Report status
docker exec ${NN_CONTAINER_NAME} bash -c "kinit user_with_password <<EOF
123456
EOF"
docker exec ${NN_CONTAINER_NAME} bash -c 'hdfs dfsadmin -report'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn node -list -showDetails'
```

**Verify**

```sh
for container in "${NN_HOSTNAME}" "${DN_1_HOSTNAME}" "${DN_2_HOSTNAME}"
do
    forward_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${container}")
    ip=$(echo ${forward_lookup} | cut -d " " -f1)
    reverse_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${ip}")

    if [ "${forward_lookup}" = "${reverse_lookup}" ]; then
        echo "DNS check for container host '${container}'" is successful.
    else
        echo "DNS check for container host '${container}'" is failed.
    fi
done
```

**Test:**

```sh
docker exec ${NN_CONTAINER_NAME} bash -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100'
docker exec ${NN_CONTAINER_NAME} bash -c 'yarn application -list -appStates ALL'
```

## 6.6 Deploy Hive

**Key points:**

* First part of principal must be `hive`, equals to the user of the container. Also need to add `hadoop.proxyuser.hive.hosts` and `hadoop.proxyuser.hive.groups` to `core-site.xml`, which allows user hive to impersonate any actual users.
* Both the Hive Metastore and HiveServer must include Kerberos-related configuration properties for each other.
* Check if kerberos authentication successfully: `grep -rni 'keytab' /tmp/hive`.
* When a client accesses the Hive Metastore, whether from within the container network or from outside. It must use a domain name that exactly matches the second part of the Kerberos principal. Otherwise, errors such as 'principal not found' may occur.
    * Outside of container network: You need to setup `<container_ip> <hostname>` in `/etc/hosts` manually, including both hadoop's containers and hive's containers.
* Make sure the container's hostname matches the second part of the Kerberos principal exactly.

### 6.6.1 Use built-in Derby

```sh
SHARED_NS=liuyehcf.org
# Kerberos
REAL_DOMAIN=${SHARED_NS}
KERBEROS_CONTAINER_NAME=kerberos
KERBEROS_HOSTNAME=${KERBEROS_CONTAINER_NAME}.${REAL_DOMAIN}
KERBEROS_LOGIC_DOMAIN=example.com
KERBEROS_LOGIC_DOMAIN_UPPER=$(echo ${KERBEROS_LOGIC_DOMAIN} | tr "[:lower:]" "[:upper:]")
# Hadoop
NN_CONTAINER_NAME=namenode-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
# Hive
HIVE_METASTORE_CONTAINER_NAME=hive-metastore-with-kerberos
HIVE_SERVER_CONTAINER_NAME=hive-server-with-kerberos
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${REAL_DOMAIN}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${REAL_DOMAIN}
HIVE_DIR_NAME=hive-with-derby

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz 'https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz'
fi
docker exec ${NN_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${NN_CONTAINER_NAME}:/opt/tez
docker exec ${NN_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.runtime.optimize.local.fetch</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.exec.submit.local.task.via.child</name>
        <value>false</value>
    </property>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>

    <property>
        <name>hive.metastore.sasl.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.metastore.kerberos.principal</name>
        <value>hive/${HIVE_METASTORE_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>hive.metastore.kerberos.keytab.file</name>
        <value>/etc/security/keytabs/hive.service.keytab</value>
    </property>
    <property>
        <name>hive.server2.authentication</name>
        <value>KERBEROS</value>
    </property>
    <property>
        <name>hive.server2.authentication.kerberos.principal</name>
        <value>hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>hive.server2.authentication.kerberos.keytab</name>
        <value>/etc/security/keytabs/hive.service.keytab</value>
    </property>
        <property>
        <name>hive.server2.enable.doAs</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.server2.proxy.user</name>
        <value>*</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Temporary entrypoint
cat > /tmp/tmp_entrypoint.sh << 'EOF'
#!/bin/bash

sleep 86400
EOF
chmod a+x /tmp/tmp_entrypoint.sh

# Use customized entrypoint for hivemetastore
cat > /tmp/hivemetastore_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/hivemetastore_entrypoint.sh

# Use customized entrypoint for hiveserver
cat > /tmp/hiveserver_entrypoint.sh << 'EOF'
#!/bin/bash
/entrypoint.sh
EOF
chmod a+x /tmp/hiveserver_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    --entrypoint /hivemetastore_entrypoint.sh \
    apache/hive:4.0.0_with_kerberos

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/tmp_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/hivemetastore_entrypoint.sh

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Setup kerberos config and copy keytab
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c "sudo tee /etc/krb5.conf > /dev/null << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF"
docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab /tmp/hive.service.keytab
docker cp /tmp/hive.service.keytab ${HIVE_METASTORE_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c 'sudo chmod 644 /etc/security/keytabs/hive.service.keytab'

docker cp /tmp/hivemetastore_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/hivemetastore_entrypoint.sh
docker restart ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e IS_RESUME=true \
    --entrypoint /hiveserver_entrypoint.sh \
    apache/hive:4.0.0_with_kerberos

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/tmp_entrypoint.sh ${HIVE_SERVER_CONTAINER_NAME}:/hiveserver_entrypoint.sh

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Setup kerberos config and copy keytab
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c "sudo tee /etc/krb5.conf > /dev/null << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF"
docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab /tmp/hive.service.keytab
docker cp /tmp/hive.service.keytab ${HIVE_SERVER_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c 'sudo chmod 644 /etc/security/keytabs/hive.service.keytab'

docker cp /tmp/hiveserver_entrypoint.sh ${HIVE_SERVER_CONTAINER_NAME}:/hiveserver_entrypoint.sh

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker restart ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'

docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c "kinit user_with_password <<EOF
123456
EOF"
```

**Verify**

```sh
for container in "${HIVE_METASTORE_HOSTNAME}" "${HIVE_SERVER_HOSTNAME}"
do
    forward_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${container}")
    ip=$(echo ${forward_lookup} | cut -d " " -f1)
    reverse_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${ip}")

    if [ "${forward_lookup}" = "${reverse_lookup}" ]; then
        echo "DNS check for container host '${container}'" is successful.
    else
        echo "DNS check for container host '${container}'" is failed.
    fi
done
```

**Test:**

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}" -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

### 6.6.2 Use External Postgres

```sh
SHARED_NS=liuyehcf.org
# Kerberos
REAL_DOMAIN=${SHARED_NS}
KERBEROS_CONTAINER_NAME=kerberos
KERBEROS_HOSTNAME=${KERBEROS_CONTAINER_NAME}.${REAL_DOMAIN}
KERBEROS_LOGIC_DOMAIN=example.com
KERBEROS_LOGIC_DOMAIN_UPPER=$(echo ${KERBEROS_LOGIC_DOMAIN} | tr "[:lower:]" "[:upper:]")
# Hadoop
NN_CONTAINER_NAME=namenode-with-kerberos
NN_HOSTNAME=${NN_CONTAINER_NAME}.${REAL_DOMAIN}
# Hive
HIVE_METASTORE_CONTAINER_NAME=hive-metastore-with-kerberos
HIVE_SERVER_CONTAINER_NAME=hive-server-with-kerberos
HIVE_METASTORE_HOSTNAME=${HIVE_METASTORE_CONTAINER_NAME}.${REAL_DOMAIN}
HIVE_SERVER_HOSTNAME=${HIVE_SERVER_CONTAINER_NAME}.${REAL_DOMAIN}
HIVE_DIR_NAME=hive-with-postgres

POSTGRES_CONTAINER_NAME=postgres
POSTGRES_HOSTNAME=${POSTGRES_CONTAINER_NAME}.${SHARED_NS}
POSTGRES_USER="hive_postgres"
POSTGRES_PASSWORD="Abcd1234"
POSTGRES_DB="hive-metastore"
IS_RESUME="false"

docker rm -f ${HIVE_METASTORE_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${HIVE_SERVER_CONTAINER_NAME} > /dev/null 2>&1
docker rm -f ${POSTGRES_CONTAINER_NAME} > /dev/null 2>&1

# How to use sql:
# 1. docker exec -it ${POSTGRES_CONTAINER_NAME} bash
# 2. psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
docker run -dit \
    --name ${POSTGRES_CONTAINER_NAME} \
    --hostname ${POSTGRES_HOSTNAME} \
    --network ${SHARED_NS} \
    -e POSTGRES_USER="${POSTGRES_USER}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    postgres:17.0

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz 'https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz'
fi
docker exec ${NN_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${NN_CONTAINER_NAME}:/opt/tez
docker exec ${NN_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

cat > /tmp/hive-site.xml << EOF
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://${POSTGRES_HOSTNAME}/${POSTGRES_DB}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.postgresql.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>${POSTGRES_USER}</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>${POSTGRES_PASSWORD}</value>
    </property>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_HOSTNAME}:9083</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>

    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.runtime.optimize.local.fetch</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.exec.submit.local.task.via.child</name>
        <value>false</value>
    </property>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>hdfs://${NN_CONTAINER_NAME}:8020/opt/${HIVE_DIR_NAME}/install_dir</value>
    </property>

    <property>
        <name>hive.metastore.sasl.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.metastore.kerberos.principal</name>
        <value>hive/${HIVE_METASTORE_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>hive.metastore.kerberos.keytab.file</name>
        <value>/etc/security/keytabs/hive.service.keytab</value>
    </property>
    <property>
        <name>hive.server2.authentication</name>
        <value>KERBEROS</value>
    </property>
    <property>
        <name>hive.server2.authentication.kerberos.principal</name>
        <value>hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}</value>
    </property>
    <property>
        <name>hive.server2.authentication.kerberos.keytab</name>
        <value>/etc/security/keytabs/hive.service.keytab</value>
    </property>
        <property>
        <name>hive.server2.enable.doAs</name>
        <value>true</value>
    </property>
    <property>
        <name>hive.server2.proxy.user</name>
        <value>*</value>
    </property>
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${NN_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml

# Prepare jdbc driver
if [ ! -e /tmp/postgresql-42.7.4.jar ]; then
    wget -O /tmp/postgresql-42.7.4.jar 'https://jdbc.postgresql.org/download/postgresql-42.7.4.jar'
fi

# Temporary entrypoint
cat > /tmp/tmp_entrypoint.sh << 'EOF'
#!/bin/bash

sleep 86400
EOF
chmod a+x /tmp/tmp_entrypoint.sh

# Use customized entrypoint for hivemetastore
cat > /tmp/hivemetastore_entrypoint.sh << 'EOF'
#!/bin/bash

echo "IS_RESUME=${IS_RESUME}"
FLAG_FILE=/opt/hive/already_init_schema

if [ -z "${IS_RESUME}" ] || [ "${IS_RESUME}" = "false" ]; then
    if [ -f ${FLAG_FILE} ]; then
        echo "Skip init schema when restart."
        IS_RESUME=true /entrypoint.sh
    else
        echo "Try to init schema for the first time."
        touch ${FLAG_FILE}
        IS_RESUME=false /entrypoint.sh
    fi
else
    echo "Skip init schema for every time."
    IS_RESUME=true /entrypoint.sh
fi
EOF
chmod a+x /tmp/hivemetastore_entrypoint.sh

# Use customized entrypoint for hiveserver
cat > /tmp/hiveserver_entrypoint.sh << 'EOF'
#!/bin/bash
/entrypoint.sh
EOF
chmod a+x /tmp/hiveserver_entrypoint.sh

# Start standalone metastore
docker create \
    --name ${HIVE_METASTORE_CONTAINER_NAME} \
    --hostname ${HIVE_METASTORE_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:9083:9083 \
    -e SERVICE_NAME=metastore \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=${IS_RESUME} \
    --entrypoint /hivemetastore_entrypoint.sh \
    apache/hive:4.0.0_with_kerberos

docker cp /tmp/hive-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/tmp_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/hivemetastore_entrypoint.sh
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Setup kerberos config and copy keytab
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c "sudo tee /etc/krb5.conf > /dev/null << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF"
docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab /tmp/hive.service.keytab
docker cp /tmp/hive.service.keytab ${HIVE_METASTORE_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c 'sudo chmod 644 /etc/security/keytabs/hive.service.keytab'

docker cp /tmp/hivemetastore_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/hivemetastore_entrypoint.sh
docker restart ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create \
    --name ${HIVE_SERVER_CONTAINER_NAME} \
    --hostname ${HIVE_SERVER_HOSTNAME} \
    --network ${SHARED_NS} \
    -p 127.0.0.1:10000:10000 \
    -e SERVICE_NAME=hiveserver2 \
    -e DB_DRIVER=postgres \
    -e IS_RESUME=true \
    --entrypoint /hiveserver_entrypoint.sh \
    apache/hive:4.0.0_with_kerberos

docker cp /tmp/hive-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/tmp_entrypoint.sh ${HIVE_SERVER_CONTAINER_NAME}:/hiveserver_entrypoint.sh
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_SERVER_CONTAINER_NAME}

# Setup kerberos config and copy keytab
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c "sudo tee /etc/krb5.conf > /dev/null << EOF
[libdefaults]
    default_realm = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    dns_lookup_realm = false
    dns_lookup_kdc = false
    ticket_lifetime = 24h
    renew_lifetime = 7d
    forwardable = true

[realms]
    ${KERBEROS_LOGIC_DOMAIN_UPPER} = {
        kdc = ${KERBEROS_HOSTNAME}
        admin_server = ${KERBEROS_HOSTNAME}
    }

[domain_realm]
    ${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
    .${REAL_DOMAIN} = ${KERBEROS_LOGIC_DOMAIN_UPPER}
EOF"
docker cp ${KERBEROS_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab /tmp/hive.service.keytab
docker cp /tmp/hive.service.keytab ${HIVE_SERVER_CONTAINER_NAME}:/etc/security/keytabs/hive.service.keytab
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c 'sudo chmod 644 /etc/security/keytabs/hive.service.keytab'

docker cp /tmp/hiveserver_entrypoint.sh ${HIVE_SERVER_CONTAINER_NAME}:/hiveserver_entrypoint.sh

# Wait for hivemetastore to start up
docker exec ${HIVE_METASTORE_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 9083; then
        break
    fi
    sleep 1
done
'

docker restart ${HIVE_SERVER_CONTAINER_NAME}

# Wait for hiveserver to start up
docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c '
while true
do
    if nc -vz 127.0.0.1 10000; then
        break
    fi
    sleep 1
done
'

docker exec ${HIVE_SERVER_CONTAINER_NAME} bash -c "kinit user_with_password <<EOF
123456
EOF"
```

**Verify**

```sh
for container in "${HIVE_METASTORE_HOSTNAME}" "${HIVE_SERVER_HOSTNAME}"
do
    forward_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${container}")
    ip=$(echo ${forward_lookup} | cut -d " " -f1)
    reverse_lookup=$(docker exec ${KERBEROS_CONTAINER_NAME} bash -c "getent hosts ${ip}")

    if [ "${forward_lookup}" = "${reverse_lookup}" ]; then
        echo "DNS check for container host '${container}'" is successful.
    else
        echo "DNS check for container host '${container}'" is failed.
    fi
done
```

**Test:**

```sh
docker exec -it ${HIVE_SERVER_CONTAINER_NAME} beeline -u "jdbc:hive2://localhost:10000/default;principal=hive/${HIVE_SERVER_HOSTNAME}@${KERBEROS_LOGIC_DOMAIN_UPPER}" -e "
create table hive_example(a string, b int) partitioned by(c int);
alter table hive_example add partition(c=1);
insert into hive_example partition(c=1) values('a', 1), ('a', 2),('b',3);
select * from hive_example;
drop table hive_example;
"
```

### 6.6.3 Hive Metastore With Kerberos Demo

```sh
mkdir -p hive_metastore_with_kerberos_demo
cd hive_metastore_with_kerberos_demo

cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>hms-with-kerveros-demo</artifactId>
    <version>1.0.0</version>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <compiler-plugin.version>3.8.1</compiler-plugin.version>
        <shade-plugin.version>3.2.4</shade-plugin.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>3.3.6</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-mapreduce-client-core</artifactId>
            <version>3.3.6</version>
        </dependency>
        <dependency>
            <groupId>org.apache.hive</groupId>
            <artifactId>hive-metastore</artifactId>
            <version>4.0.0</version>
        </dependency>
    </dependencies>

    <build>
        <finalName>${artifactId}</finalName>
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
                            <transformers>
                                <transformer
                                        implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                                    <mainClass>org.liuyehcf.HiveMetastoreWithKerberosTest</mainClass>
                                </transformer>

                                <!-- Work with SPI -->
                                <transformer
                                        implementation="org.apache.maven.plugins.shade.resource.ServicesResourceTransformer"/>
                            </transformers>
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
    </build>
</project>
EOF

mkdir -p src/main/java/org/liuyehcf
cat > src/main/java/org/liuyehcf/HiveMetastoreWithKerberosTest.java << 'EOF'
package org.liuyehcf;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hive.conf.HiveConf;
import org.apache.hadoop.hive.metastore.HiveMetaStoreClient;
import org.apache.hadoop.hive.metastore.api.Database;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.thrift.TException;

import java.io.IOException;
import java.util.List;

public class HiveMetastoreWithKerberosTest {

    public static void main(String[] args) {
        if (args.length != 4) {
            System.err.println(
                    "Usage: HiveMetastoreWithKerberosTest <principal> <hmsHost> <hmsPort>"
                            + " <ticketPath>");
            System.exit(1);
        }
        String principal = args[0];
        String hmsHost = args[1];
        int hmsPort = Integer.parseInt(args[2]);
        String ticketPath = args[3];
        String hiveMetastoreUri = String.format("thrift://%s:%d", hmsHost, hmsPort);
        String kerberosConfigFromProperty = System.getProperty("java.security.krb5.conf");
        if (kerberosConfigFromProperty == null || kerberosConfigFromProperty.isEmpty()) {
            String kerberosConfigFromEnv = System.getenv("KRB5_CONFIG");
            if (kerberosConfigFromEnv == null) {
                throw new RuntimeException(
                        "Missing java property 'java.security.krb5.conf' or env 'KRB5_CONFIG'");
            }
            System.setProperty("java.security.krb5.conf", kerberosConfigFromEnv);
        }

        try {
            Configuration hadoopConf = new Configuration();
            hadoopConf.set("hadoop.security.authentication", "kerberos");
            hadoopConf.set("hadoop.security.authorization", "true");
            UserGroupInformation.setConfiguration(hadoopConf);
            UserGroupInformation ugi = UserGroupInformation.getBestUGI(ticketPath, null);

            System.out.println("Kerberos authentication successful. Logged in as: " + ugi);

            HiveConf conf = new HiveConf();
            conf.set("hive.metastore.uris", hiveMetastoreUri);
            conf.set("hive.metastore.sasl.enabled", "true");
            conf.set("hive.metastore.kerberos.principal", principal);
            System.out.println("Final hive.metastore.uris: " + conf.get("hive.metastore.uris"));

            HiveMetaStoreClient client = new HiveMetaStoreClient(conf);

            List<String> databases = client.getAllDatabases();
            System.out.println("Databases:");
            for (String dbName : databases) {
                Database db = client.getDatabase(dbName);
                System.out.println(" - " + dbName + " (Location: " + db.getLocationUri() + ")");
            }

            client.close();
        } catch (IOException e) {
            System.err.println("Kerberos authentication failed: " + e.getMessage());
            e.printStackTrace();
        } catch (TException e) {
            System.err.println("Hive Metastore operation failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

mvn clean package

export KRB5_CONFIG=/etc/krb5.conf
kinit -c ~/.ticket_cache_user_with_password user_with_password << EOF
123456
EOF

java -jar target/hms-with-kerveros-demo-jar-with-dependencies.jar hive/_HOST@EXAMPLE.COM hive-metastore-with-kerberos.liuyehcf.org 9083 ~/.ticket_cache_user_with_password

java -jar target/hms-with-kerveros-demo-jar-with-dependencies.jar hive/hive-metastore-with-kerberos.liuyehcf.org@EXAMPLE.COM hive-metastore-with-kerberos.liuyehcf.org 9083 ~/.ticket_cache_user_with_password
```

# 7 Docker-Compose

* [Big Data Europe](https://github.com/big-data-europe)
    * [docker-hadoop](https://github.com/big-data-europe/docker-hadoop)
    * [docker-hive](https://github.com/big-data-europe/docker-hive)
    * [docker-spark](https://github.com/big-data-europe/docker-spark)
    * [docker-flink](https://github.com/big-data-europe/docker-flink)
