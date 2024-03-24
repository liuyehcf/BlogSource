---
title: Hive-Trial
date: 2022-07-18 19:17:45
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Hadoop

## 1.1 Pseudo Distributed Cluster

Pseudo Distributed Cluster means the cluster has only one machine.

**Run the following script to setup the cluster:**

```sh
#!/bin/bash

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)

wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -zxf hadoop-3.3.6.tar.gz -C ${ROOT}

export HADOOP_HOME=${ROOT}/hadoop-3.3.6
mkdir ${HADOOP_HOME}/runtime

if [ ! -f ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh.bak ]; then
    \cp -vf ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh.bak
fi
JAVA_HOME_PATH=$(readlink -f $(which java))
JAVA_HOME_PATH=${JAVA_HOME_PATH%/bin/java}
sed -i -E "s|^.*export JAVA_HOME=.*$|export JAVA_HOME=${JAVA_HOME_PATH}|g" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
sed -i -E "s|^.*export HADOOP_HOME=.*$|export HADOOP_HOME=${HADOOP_HOME}|g" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh
sed -i -E "s|^.*export HADOOP_LOG_DIR=.*$|export HADOOP_LOG_DIR=\${HADOOP_HOME}/logs|g" ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

if [ ! -f ${HADOOP_HOME}/etc/hadoop/core-site.xml.bak ]; then
    \cp -vf ${HADOOP_HOME}/etc/hadoop/core-site.xml ${HADOOP_HOME}/etc/hadoop/core-site.xml.bak
fi
cat > ${HADOOP_HOME}/etc/hadoop/core-site.xml << 'EOF'
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://10.232.200.19:9000</value>
    </property>
</configuration>
EOF

if [ ! -f ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml.bak ]; then
    \cp -vf ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml.bak
fi
cat > ${HADOOP_HOME}/etc/hadoop/hdfs-site.xml << EOF
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:${HADOOP_HOME}/runtime/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:${HADOOP_HOME}/runtime/datanode</value>
    </property>
</configuration>
EOF

if [ ! -f ${HADOOP_HOME}/etc/hadoop/mapred-site.xml.bak ]; then
    \cp -vf ${HADOOP_HOME}/etc/hadoop/mapred-site.xml ${HADOOP_HOME}/etc/hadoop/mapred-site.xml.bak
fi
cat > ${HADOOP_HOME}/etc/hadoop/mapred-site.xml << 'EOF'
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>
EOF

if [ ! -f ${HADOOP_HOME}/etc/hadoop/yarn-site.xml.bak ]; then
    \cp -vf ${HADOOP_HOME}/etc/hadoop/yarn-site.xml ${HADOOP_HOME}/etc/hadoop/yarn-site.xml.bak
fi
cat > ${HADOOP_HOME}/etc/hadoop/yarn-site.xml << 'EOF'
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>
EOF

# namenode format
${HADOOP_HOME}/bin/hdfs namenode -format

# Start all daemons
${HADOOP_HOME}/bin/hdfs --daemon start namenode
${HADOOP_HOME}/bin/hdfs --daemon start datanode

${HADOOP_HOME}/bin/yarn --daemon start resourcemanager
${HADOOP_HOME}/bin/yarn --daemon start nodemanager

${HADOOP_HOME}/bin/mapred --daemon start historyserver

${HADOOP_HOME}/bin/hdfs dfsadmin -report

jps
```

**Stop all:**

```sh
${HADOOP_HOME}/bin/hdfs --daemon stop namenode
${HADOOP_HOME}/bin/hdfs --daemon stop datanode

${HADOOP_HOME}/bin/yarn --daemon stop resourcemanager
${HADOOP_HOME}/bin/yarn --daemon stop nodemanager

${HADOOP_HOME}/bin/mapred --daemon stop historyserver
```

**Test:**

```sh
${HADOOP_HOME}/bin/hdfs dfs -ls /

echo "Hello Hadoop Goodbye Hadoop" > /tmp/input.txt
${HADOOP_HOME}/bin/hdfs dfs -mkdir /wordcount_input
${HADOOP_HOME}/bin/hdfs dfs -put /tmp/input.txt /wordcount_input
${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar wordcount /wordcount_input /wordcount_output

${HADOOP_HOME}/bin/hdfs dfs -cat "/wordcount_output/*"
```

# 2 Spark

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

# 3 Hive

## 3.1 Install

```sh
#!/bin/bash

ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)

wget https://mirrors.tuna.tsinghua.edu.cn/apache/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
tar -zxf apache-hive-3.1.3-bin.tar.gz -C ${ROOT}

export HIVE_HOME=${ROOT}/apache-hive-3.1.3-bin

cp -f ${HIVE_HOME}/conf/hive-default.xml.template ${HIVE_HOME}/conf/hive-site.xml
```

The template of `${HIVE_HOME}/conf/hive-site.xml` is called `${HIVE_HOME}/conf/hive-default.xml.template`

## 3.2 Hive Metastore

### 3.2.1 Use Derby

Dependencies are already installed with hive.

**Edit `${HIVE_HOME}/conf/hive-site.xml` as follows:**

```
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:derby:;databaseName=metastore_db;create=true</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.apache.derby.jdbc.EmbeddedDriver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>APP</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>mine</value>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>hive.exec.local.scratchdir</name>
        <value>/tmp/hive</value>
    </property>
</configuration>
```

**Init:**

```sh
${HIVE_HOME}/bin/schematool -dbType derby -initSchema
```

### 3.2.2 Use Mysql

**Start a mysql server via docker:**

```sh
docker run -dit -p 13306:3306 -e MYSQL_ROOT_PASSWORD='Abcd1234' -v /path/xxx/mysql:/var/lib/mysql mysql:5.7.37 mysqld --lower_case_table_names=1
```

**Download mysql jdbc driver from [MySQL Community Downloads](https://dev.mysql.com/downloads/connector/j/):**

* choose `Platform Independent`

```sh
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.3.0.tar.gz
tar -zxvf mysql-connector-j-8.3.0.tar.gz
cp -f mysql-connector-j-8.3.0/mysql-connector-j-8.3.0.jar ${HIVE_HOME}/lib/
```

**Edit `${HIVE_HOME}/conf/hive-site.xml` as follows:**

```
<configuration>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://localhost:13306/metastore_db?createDatabaseIfNotExist=true</value>
        <description>Metadata storage DB connection URL</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.cj.jdbc.Driver</value>
        <description>Driver class for the DB</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>root</value>
        <description>Username for accessing the DB</description>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>Abcd1234</value>
        <description>Password for accessing the DB</description>
    </property>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>hive.exec.local.scratchdir</name>
        <value>/tmp/hive</value>
    </property>
</configuration>
```

**Init:**

```sh
${HIVE_HOME}/bin/schematool -dbType mysql -initSchema
```

## 3.3 Hive on Hadoop

**Test:**

```sh
cat > /tmp/employees.txt << 'EOF'
1,John Doe,12000,IT
2,Jane Doe,15000,HR
3,Jim Beam,9000,Marketing
4,Sarah Connor,18000,IT
5,Gordon Freeman,20000,R&D
EOF

${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse/test_db/
${HADOOP_HOME}/bin/hdfs dfs -put /tmp/employees.txt /user/hive/warehouse/test_db/

${HIVE_HOME}/bin/hive

hive> CREATE DATABASE IF NOT EXISTS test_db;
hive> USE test_db;
hive> CREATE TABLE IF NOT EXISTS employees (
  id INT,
  name STRING,
  salary INT,
  department STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
hive> LOAD DATA INPATH '/user/hive/warehouse/test_db/employees.txt' INTO TABLE employees;

hive> SELECT * FROM employees;
hive> SELECT name, salary FROM employees WHERE department = 'IT';
hive> SELECT department, AVG(salary) AS average_salary FROM employees GROUP BY department;
```

## 3.4 Hive on Spark

**Edit `${HIVE_HOME}/conf/hive-site.xml`, add following properties:**

```
    <property>
        <name>hive.execution.engine</name>
        <value>spark</value>
    </property>
    <property>
        <name>spark.master</name>
        <value>spark://localhost:7077</value>
    </property>
```

**Test:**

```sh
cat > /tmp/employees.txt << 'EOF'
1,John Doe,12000,IT
2,Jane Doe,15000,HR
3,Jim Beam,9000,Marketing
4,Sarah Connor,18000,IT
5,Gordon Freeman,20000,R&D
EOF

${HADOOP_HOME}/bin/hdfs dfs -mkdir -p /user/hive/warehouse/test_db/
${HADOOP_HOME}/bin/hdfs dfs -put /tmp/employees.txt /user/hive/warehouse/test_db/

${HIVE_HOME}/bin/hive

hive> CREATE DATABASE IF NOT EXISTS test_db;
hive> USE test_db;
hive> CREATE TABLE IF NOT EXISTS employees (
  id INT,
  name STRING,
  salary INT,
  department STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
hive> LOAD DATA INPATH '/user/hive/warehouse/test_db/employees.txt' INTO TABLE employees;

hive> SELECT * FROM employees;
hive> SELECT name, salary FROM employees WHERE department = 'IT';
hive> SELECT department, AVG(salary) AS average_salary FROM employees GROUP BY department;
```
