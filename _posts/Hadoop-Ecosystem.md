---
title: Hadoop-Ecosystem
date: 2022-07-18 19:17:45
tags: 
- 原创
categories: 
- Database
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

# 2 HDFS

> HDFS has a master/slave architecture. An HDFS cluster consists of a single NameNode, a master server that manages the file system namespace and regulates access to files by clients. In addition, there are a number of DataNodes, usually one per node in the cluster, which manage storage attached to the nodes that they run on. HDFS exposes a file system namespace and allows user data to be stored in files. Internally, a file is split into one or more blocks and these blocks are stored in a set of DataNodes. The NameNode executes file system namespace operations like opening, closing, and renaming files and directories. It also determines the mapping of blocks to DataNodes. The DataNodes are responsible for serving read and write requests from the file system’s clients. The DataNodes also perform block creation, deletion, and replication upon instruction from the NameNode.

![hdfsarchitecture](/images/Hadoop-Ecosystem/hdfsarchitecture.gif)

## 2.1 Deployment via Docker

**Import paths of docker:**

* `/var/log/hadoop`
    * `/var/log/hadoop/hadoop-hadoop-namenode-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-datanode-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-resourcemanager-$(hostname).out`
    * `/var/log/hadoop/hadoop-hadoop-nodemanager-$(hostname).out`
    * `userlogs`: Logs for applications that are submitted to yarn.

**Important ports:**

* `8042`: NodeManager (Web UI)
* `8088`: ResourceManager (Web UI)

```sh
SHARED_NS=hadoop-ns
HADOOP_CONTAINER_NAME=hadoop

docker run -dit --name ${HADOOP_CONTAINER_NAME} --network ${SHARED_NS} -p 8042:8042 -p 8088:8088 apache/hadoop:3.3.6 bash
docker exec ${HADOOP_CONTAINER_NAME} bash -c "cat > /opt/hadoop/etc/hadoop/core-site.xml << EOF
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://${HADOOP_CONTAINER_NAME}</value>
  </property>
</configuration>
EOF"

docker exec ${HADOOP_CONTAINER_NAME} bash -c "cat > /opt/hadoop/etc/hadoop/hdfs-site.xml << EOF
<configuration>
  <property>
    <name>dfs.replication</name>
    <value>1</value>
  </property>
  <property>
    <name>dfs.permissions.enabled</name>
    <value>false</value>
  </property>
</configuration>
EOF"

docker exec ${HADOOP_CONTAINER_NAME} bash -c "cat > /opt/hadoop/etc/hadoop/yarn-site.xml << EOF
<configuration>
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>${HADOOP_CONTAINER_NAME}</value>
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
</configuration>
EOF"

docker exec ${HADOOP_CONTAINER_NAME} bash -c "cat > /opt/hadoop/etc/hadoop/mapred-site.xml << EOF
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
EOF"

# Format
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs namenode -format'

# retart all daemons
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs --daemon stop namenode; hdfs --daemon start namenode'
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs --daemon stop datanode; hdfs --daemon start datanode'
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'yarn --daemon stop resourcemanager; yarn --daemon start resourcemanager'
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'yarn --daemon stop nodemanager; yarn --daemon start nodemanager'
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'mapred --daemon stop historyserver; mapred --daemon start historyserver'

# Report status
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs dfsadmin -report'
```

Test:

```sh
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 10 100'
```

## 2.2 Configuration

1. `core-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/core-site.xml`
    * Description: Contains configuration settings for Hadoop's core system, including the default filesystem URI.
1. `hdfs-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/hdfs-site.xml`
    * Description: Contains configuration settings specific to HDFS.
1. `yarn-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/yarn-site.xml`
    * Description: Contains configuration settings for YARN (Yet Another Resource Negotiator).
1. `mapred-site.xml`
    * Path: `$HADOOP_HOME/etc/hadoop/mapred-site.xml`
    * Description: Contains configuration settings specific to MapReduce.
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

## 2.3 Command-hdfs

### 2.3.1 File Path

```sh
hdfs dfs -ls -R <path>
```

### 2.3.2 File Status

```sh
hdfs fsck <path>
hdfs fsck <path> -files -blocks -replication
```

### 2.3.3 Show Content

```sh
# For text file
hdfs dfs -cat <path>

# For avro file
hdfs dfs -text <path.avro>
```

### 2.3.4 Grant Permission

```sh
hdfs dfs -setfacl -R -m user:hive:rwx /
hdfs dfs -setfacl -R -m default:user:hive:rwx /
hdfs dfs -getfacl /
```

## 2.4 Command-yarn

### 2.4.1 Node

```sh
yarn node -list
yarn node -list -showDetails
```

### 2.4.2 Application

```sh
yarn application -list
yarn application -list -appStates ALL

yarn application -status <appid>
yarn logs -applicationId <appid>

yarn application -kill <appid>
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

## 3.2 Tips

### 3.2.1 Spark-Sql

```sql
show catalogs;
set catalog <catalog_name>;

show databases;
use <database_name>;
```

### 3.2.2 Spark-Shell

#### 3.2.2.1 Read parquet/orc/avro file

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

Here is a summary of the compatible versions of Apache Hive and Hadoop (refer to [Apache Hive Download](https://hive.apache.org/general/downloads/) for details):

* `Hive 4.0.0`: Works with `Hadoop 3.3.6`, `Tez 0.10.3`

**Issues:**

* **When setting `IS_RESUME=true`, container `hiveserver2` can restart if it is started via `docker run -d`. And it cannot restart if it is started via `docker create & docker start`, still don't know why.**
* **Don't use `apache-tez-0.10.3-bin.tar.gz` directly but use `share/tez.tar.gz` after uncompressing. ([Error: Could not find or load main class org.apache.tez.dag.app.DAGAppMaster](https://stackoverflow.com/questions/72211046/error-could-not-find-or-load-main-class-org-apache-tez-dag-app-dagappmaster))**

### 4.2.1 Use built-in Derby

[Apache Hive - Quickstart](https://hive.apache.org/developement/quickstart/)

Start a hive container joining the shared network.

```sh
SHARED_NS=hadoop-ns
HADOOP_CONTAINER_NAME=hadoop
HIVE_PREFIX=hive-with-derby
HIVE_METASTORE_CONTAINER_NAME=${HIVE_PREFIX}-metastore
HIVE_SERVER_CONTAINER_NAME=${HIVE_PREFIX}-server

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz  https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz
fi
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${HADOOP_CONTAINER_NAME}:/opt/tez
docker exec ${HADOOP_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

HIVE_SITE_CONFIG_COMMON=$(cat << EOF
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>/opt/${HIVE_PREFIX}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>/opt/${HIVE_PREFIX}/install_dir</value>
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
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>/opt/${HIVE_PREFIX}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
EOF
)

cat > /tmp/hive-site-for-metastore.xml << EOF
<configuration>
    ${HIVE_SITE_CONFIG_COMMON}
</configuration>
EOF

cat > /tmp/hive-site-for-hiveserver2.xml << EOF
<configuration>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_CONTAINER_NAME}:9083</value>
    </property>
    ${HIVE_SITE_CONFIG_COMMON}
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml /tmp/mapred-site.xml

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
docker create --name ${HIVE_METASTORE_CONTAINER_NAME} --network ${SHARED_NS} -p 9083:9083 -e SERVICE_NAME=metastore --entrypoint /updated_entrypoint.sh apache/hive:4.0.0

docker cp /tmp/hive-site-for-metastore.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/mapred-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create --name ${HIVE_SERVER_CONTAINER_NAME} --network ${SHARED_NS} -p 10000:10000 -e SERVICE_NAME=hiveserver2 -e IS_RESUME=true apache/hive:4.0.0

docker cp /tmp/hive-site-for-hiveserver2.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/mapred-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml

docker start ${HIVE_SERVER_CONTAINER_NAME}
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

### 4.2.2 Use External Postgres

```sh
SHARED_NS=hadoop-ns
POSTGRES_CONTAINER_NAME=postgres
POSTGRES_USER="hive_postgres"
POSTGRES_PASSWORD="Abcd1234"
POSTGRES_DB="hive-metastore"
HADOOP_CONTAINER_NAME=hadoop
HIVE_PREFIX=hive-with-postgres
HIVE_METASTORE_CONTAINER_NAME=${HIVE_PREFIX}-metastore
HIVE_SERVER_CONTAINER_NAME=${HIVE_PREFIX}-server
IS_RESUME="false"

# How to use sql:
# 1. docker exec -it ${POSTGRES_CONTAINER_NAME} bash
# 2. psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}
docker run --name ${POSTGRES_CONTAINER_NAME} --network ${SHARED_NS} \
    -e POSTGRES_USER="${POSTGRES_USER}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    -d postgres:17.0

# Download tez resources and put to hdfs
if [ ! -e /tmp/apache-tez-0.10.3-bin.tar.gz ]; then
    wget -O /tmp/apache-tez-0.10.3-bin.tar.gz  https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz
fi
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'mkdir -p /opt/tez'
docker cp /tmp/apache-tez-0.10.3-bin.tar.gz ${HADOOP_CONTAINER_NAME}:/opt/tez
docker exec ${HADOOP_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    rm -rf /opt/tez/apache-tez-0.10.3-bin
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

HIVE_SITE_CONFIG_COMMON=$(cat << EOF
    <property>
        <name>hive.server2.enable.doAs</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.tez.exec.inplace.progress</name>
        <value>false</value>
    </property>
    <property>
        <name>hive.exec.scratchdir</name>
        <value>/opt/${HIVE_PREFIX}/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>/opt/${HIVE_PREFIX}/install_dir</value>
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
        <name>tez.local.mode</name>
        <value>false</value>
    </property>
    <property>
        <name>tez.lib.uris</name>
        <value>/opt/tez/tez.tar.gz</value>
    </property>
    <property>
        <name>hive.execution.engine</name>
        <value>tez</value>
    </property>
    <property>
        <name>metastore.warehouse.dir</name>
        <value>/opt/${HIVE_PREFIX}/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
EOF
)

cat > /tmp/hive-site-for-metastore.xml << EOF
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:postgresql://${POSTGRES_CONTAINER_NAME}/${POSTGRES_DB}</value>
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
    ${HIVE_SITE_CONFIG_COMMON}
</configuration>
EOF

cat > /tmp/hive-site-for-hiveserver2.xml << EOF
<configuration>
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://${HIVE_METASTORE_CONTAINER_NAME}:9083</value>
    </property>
    ${HIVE_SITE_CONFIG_COMMON}
</configuration>
EOF

# Copy hadoop config file to hive container
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml /tmp/mapred-site.xml

# Prepare jdbc driver
if [ ! -e /tmp/postgresql-42.7.4.jar ]; then
    wget -O /tmp/postgresql-42.7.4.jar  https://jdbc.postgresql.org/download/postgresql-42.7.4.jar
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
docker create --name ${HIVE_METASTORE_CONTAINER_NAME} --network ${SHARED_NS} -p 9083:9083 -e SERVICE_NAME=metastore -e DB_DRIVER=postgres -e IS_RESUME=${IS_RESUME} --entrypoint /updated_entrypoint.sh apache/hive:4.0.0

docker cp /tmp/hive-site-for-metastore.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/mapred-site.xml ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml
docker cp /tmp/updated_entrypoint.sh ${HIVE_METASTORE_CONTAINER_NAME}:/updated_entrypoint.sh
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_METASTORE_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_METASTORE_CONTAINER_NAME}

# Start standalone hiveserver2
docker create --name ${HIVE_SERVER_CONTAINER_NAME} --network ${SHARED_NS} -p 10000:10000 -e SERVICE_NAME=hiveserver2 -e DB_DRIVER=postgres -e IS_RESUME=true apache/hive:4.0.0

docker cp /tmp/hive-site-for-hiveserver2.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/conf/hive-site.xml
docker cp /tmp/core-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml
docker cp /tmp/hdfs-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml
docker cp /tmp/yarn-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml
docker cp /tmp/mapred-site.xml ${HIVE_SERVER_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml
docker cp /tmp/postgresql-42.7.4.jar ${HIVE_SERVER_CONTAINER_NAME}:/opt/hive/lib/postgresql-42.7.4.jar

docker start ${HIVE_SERVER_CONTAINER_NAME}
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

# 6 Docker-Compose

* [Big Data Europe](https://github.com/big-data-europe)
    * [docker-hadoop](https://github.com/big-data-europe/docker-hadoop)
    * [docker-hive](https://github.com/big-data-europe/docker-hive)
    * [docker-spark](https://github.com/big-data-europe/docker-spark)
    * [docker-flink](https://github.com/big-data-europe/docker-flink)
