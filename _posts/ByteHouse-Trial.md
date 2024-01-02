---
title: ByteHouse-Trial
date: 2022-07-18 22:17:45
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Development Env

[ByConity development environment](https://byconity.github.io/docs/quick-start/set-up-byconity-dev-env)

# 2 Deployment

## 2.1 k8s

[Deploy ByConity in Kubernetes](https://byconity.github.io/docs/deployment/deploy-k8s)

## 2.2 Bare Metal

[Package Deployment](https://byconity.github.io/docs/deployment/package-deployment)

### 2.2.1 FoundationDB Installation

[FoundationDB Installation](https://byconity.github.io/docs/deployment/foundationdb-installation)

**For all nodes:**

```sh
curl -L -o fdbserver.x86_64 https://mirror.ghproxy.com/https://github.com/apple/foundationdb/releases/download/7.1.25/fdbserver.x86_64
curl -L -o fdbmonitor.x86_64 https://mirror.ghproxy.com/https://github.com/apple/foundationdb/releases/download/7.1.25/fdbmonitor.x86_64
curl -L -o fdbcli.x86_64 https://mirror.ghproxy.com/https://github.com/apple/foundationdb/releases/download/7.1.25/fdbcli.x86_64

mv fdbcli.x86_64 fdbcli
mv fdbmonitor.x86_64 fdbmonitor
mv fdbserver.x86_64 fdbserver
chmod ug+x fdbcli fdbmonitor fdbserver

yum install -y sshpass
```

**For all nodes:**

```sh
export WORKING_DIR="<working dir>"
export CUR_IP_ADDRESS="<current node ip address>"

mkdir -p ${WORKING_DIR}/fdb_runtime/config
mkdir -p ${WORKING_DIR}/fdb_runtime/data
mkdir -p ${WORKING_DIR}/fdb_runtime/logs
mkdir -p ${WORKING_DIR}/foundationdb/bin

\cp -f fdbcli fdbmonitor fdbserver ${WORKING_DIR}/foundationdb/bin

cat > ${WORKING_DIR}/fdb_runtime/config/foundationdb.conf << EOF
[fdbmonitor]
user = root

[general]
cluster-file = ${WORKING_DIR}/fdb_runtime/config/fdb.cluster
restart-delay = 60

[fdbserver]

command = ${WORKING_DIR}/foundationdb/bin/fdbserver
datadir = ${WORKING_DIR}/fdb_runtime/data/\$ID
logdir = ${WORKING_DIR}/fdb_runtime/logs/
public-address = auto:\$ID
listen-address = public

[fdbserver.4500]
class=stateless
[fdbserver.4501]
class=transaction
[fdbserver.4502]
class=storage
[fdbserver.4503]
class=stateless
EOF

cat > ${WORKING_DIR}/fdb_runtime/config/fdb.cluster << EOF
clusterdsc:test@${CUR_IP_ADDRESS}:4500
EOF

cat > ${WORKING_DIR}/fdb_runtime/config/fdb.service << EOF
[Unit]
Description=FoundationDB (KV storage for cnch metastore)

[Service]
Restart=always
RestartSec=30
TimeoutStopSec=600
ExecStart=${WORKING_DIR}/foundationdb/bin/fdbmonitor --conffile ${WORKING_DIR}/fdb_runtime/config/foundationdb.conf --lockfile ${WORKING_DIR}/fdb_runtime/fdbmonitor.pid

[Install]
WantedBy=multi-user.target
EOF

\cp -f ${WORKING_DIR}/fdb_runtime/config/fdb.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable fdb.service
systemctl start fdb.service
systemctl status fdb.service
```

**For first node:**

```sh
export FDB_COORDINATOR_ADDRESSES=( "<coordinator ip address 1>" "<coordinator ip address 2>" "<coordinator ip address 3>" )
export PASSWD=""

${WORKING_DIR}/foundationdb/bin/fdbcli -C ${WORKING_DIR}/fdb_runtime/config/fdb.cluster --exec "configure new single ssd"
ADD_COORDINATORS_CMD="coordinators ${FDB_COORDINATOR_ADDRESSES[@]/%/:4500}"
${WORKING_DIR}/foundationdb/bin/fdbcli -C ${WORKING_DIR}/fdb_runtime/config/fdb.cluster --exec "${ADD_COORDINATORS_CMD}"

# Then copy file `${WORKING_DIR}/fdb_runtime/config/fdb.cluster` in first node to the other nodes, and then executes `systemctl restart fdb.service` in all nodes.
for FDB_COORDINATOR_ADDRESS in ${FDB_COORDINATOR_ADDRESSES[@]}
do
    if [ "${CUR_IP_ADDRESS}" != "${FDB_COORDINATOR_ADDRESS}" ]; then
        sshpass -p "${PASSWD}" scp -o StrictHostKeyChecking=no ${WORKING_DIR}/fdb_runtime/config/fdb.cluster root@${FDB_COORDINATOR_ADDRESS}:${WORKING_DIR}/fdb_runtime/config/fdb.cluster
    fi
done
```

**For all nodes:**

```sh
systemctl restart fdb.service
```

**For first node:**

```sh
${WORKING_DIR}/foundationdb/bin/fdbcli -C ${WORKING_DIR}/fdb_runtime/config/fdb.cluster --exec "configure double"
${WORKING_DIR}/foundationdb/bin/fdbcli -C ${WORKING_DIR}/fdb_runtime/config/fdb.cluster --exec "status"
${WORKING_DIR}/foundationdb/bin/fdbcli -C ${WORKING_DIR}/fdb_runtime/config/fdb.cluster --exec "status details"

# Check If all nodes are reachable
# ...
# Coordination servers:
#  172.26.95.241:4500  (reachable)
#  172.26.95.242:4500  (reachable)
#  172.26.95.243:4500  (reachable)
```

### 2.2.2 HDFS Installation

[HDFS Installation](https://byconity.github.io/docs/deployment/hdfs-installation)

**For all nodes:**

```sh
wget https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz

yum install -y java-1.8.0-openjdk-devel
```

```sh
export WORKING_DIR="<working dir>"
export HDFS_NAME_NODE_ADDRESS="<name node ip address>"

mkdir -p ${WORKING_DIR}/hdfs
tar -zxf hadoop-3.3.6.tar.gz -C ${WORKING_DIR}/hdfs

export HADOOP_DIR=${WORKING_DIR}/hdfs/hadoop-3.3.6

if [ ! -f ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh.bak ]; then
    \cp -vf ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh.bak
fi

JAVA_HOME_PATH=$(readlink -f $(which java))
JAVA_HOME_PATH=${JAVA_HOME_PATH%/jre/bin/java}
sed -i -E "s|^.*export JAVA_HOME=.*$|export JAVA_HOME=${JAVA_HOME_PATH}|g" ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh
sed -i -E "s|^.*export HADOOP_HOME=.*$|export HADOOP_HOME=${WORKING_DIR}/hdfs/hadoop-3.3.6|g" ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh
sed -i -E "s|^.*export HADOOP_LOG_DIR=.*$|export HADOOP_LOG_DIR=\${HADOOP_HOME}/logs|g" ${HADOOP_DIR}/etc/hadoop/hadoop-env.sh

cat > ${HADOOP_DIR}/etc/hadoop/core-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
        <property>
                <name>fs.defaultFS</name>
                <value>hdfs://${HDFS_NAME_NODE_ADDRESS}:12000</value>
        </property>
</configuration>
EOF
```

**For name node:**

```sh
export HDFS_DATA_NODE_ADDRESSES=( "<data node ip address 1>" "<data node ip address 2>" )

rm -f ${WORKING_DIR}/hdfs/datanodes_list.txt
for HDFS_DATA_NODE_ADDRESS in ${HDFS_DATA_NODE_ADDRESSES[@]}
do
    echo ${HDFS_DATA_NODE_ADDRESS} >> ${WORKING_DIR}/hdfs/datanodes_list.txt
done

mkdir -p ${WORKING_DIR}/hdfs/root_data_path_for_namenode

cat > ${HADOOP_DIR}/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file://${WORKING_DIR}/hdfs/root_data_path_for_namenode</value>
    </property>
    <property>
        <name>dfs.hosts</name>
        <value>${WORKING_DIR}/hdfs/datanodes_list.txt</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
</configuration>
EOF
```

**For data nodes:**

```sh
mkdir -p ${WORKING_DIR}/hdfs/root_data_path_for_datanode

cat > ${HADOOP_DIR}/etc/hadoop/hdfs-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
    <property>
        <name>dfs.data.dir</name>
        <value>file://${WORKING_DIR}/hdfs/root_data_path_for_datanode</value>
    </property>
    <property>
        <name>dfs.permissions</name>
        <value>false</value>
    </property>
</configuration>
EOF
```

**For name node:**

```sh
${HADOOP_DIR}/bin/hdfs namenode -format
${HADOOP_DIR}/bin/hdfs --daemon stop namenode
${HADOOP_DIR}/bin/hdfs --daemon start namenode
```

**For data nodes:**

```sh
${HADOOP_DIR}/bin/hdfs --daemon stop datanode
${HADOOP_DIR}/bin/hdfs --daemon start datanode
```

**For name node: Create some directory for next deployment.**

```sh
${HADOOP_DIR}/bin/hdfs dfs -mkdir -p /user/clickhouse/
${HADOOP_DIR}/bin/hdfs dfs -chown clickhouse /user/clickhouse
${HADOOP_DIR}/bin/hdfs dfs -chmod -R 775 /user/clickhouse
```

**Other operations:**

```sh
${HADOOP_DIR}/bin/hdfs dfsadmin -report
${HADOOP_DIR}/bin/hdfs dfs -ls /user
${HADOOP_DIR}/bin/hdfs dfs -df /user/clickhouse
```

### 2.2.3 Install FoundationDB client

The Foundation client package are tight coupled to version of FoundationDB server. So we need to choose the client package with version that match the version of FoundationDB server.

For all nodes:

```sh
wget https://mirror.ghproxy.com/https://github.com/apple/foundationdb/releases/download/7.1.25/foundationdb-clients-7.1.25-1.el7.x86_64.rpm

rpm -ivh foundationdb-clients-*.rpm
```

### 2.2.4 Deploy ByConity Packages

**Components:**

* The `byconity-resource-manager`, `byconity-daemon-manger` and `byconity-tso` are light weight service so it could be install in shared machine with other package.
* But for `byconity-server`, `byconity-worker`, `byconity-worker-write` we should install them in separate machines. These components are incompatible with each other for they all locking the file `/var/lib/byconity-server/status` exclusively.

**For all nodes:**

```sh
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-common-static-0.3.0.x86_64.rpm

rpm -ivh byconity-common-static-*.rpm

rm -f /etc/byconity-server/fdb.cluster
ln -s ${WORKING_DIR}/fdb_runtime/config/fdb.cluster /etc/byconity-server/fdb.cluster
```

**Config files:**

* `/etc/byconity-server/cnch_config.xml`: contains service_discovery config, hdfs config, foundationdb cluster config path.
    * search `your` and change them all(including the `hostname`).
* `/etc/byconity-server/fdb.cluster`: the cluster config file of FoundationDB cluster.

```sh
export BYCONITY_PANEL_NODE_ADDRESS="<panel node ip address>"
export BYCONITY_PANEL_NODE_HOSTNAME="<panel node hostname>"
export DNS_PAIRS=( "<panel node ip address>:<panel node hostname>" "<worker node ip address>:<worker node hostname>" "<worker-wirte node ip address>:<worker-wirte node hostname>" )
export CUR_IP_ADDRESS="<current node ip address>"

if [ ! -f /etc/byconity-server/cnch_config.xml.bak ]; then
    \cp -vf /etc/byconity-server/cnch_config.xml /etc/byconity-server/cnch_config.xml.bak
fi

# Set host and hostname of server, tso, daemon_manager, resource_manager to the panel node.
sed -i -E "s|<host>.*</host>|<host>${BYCONITY_PANEL_NODE_ADDRESS}</host>|g" /etc/byconity-server/cnch_config.xml
sed -i -E "s|<hostname>.*</hostname>|<hostname>${BYCONITY_PANEL_NODE_HOSTNAME}</hostname>|g" /etc/byconity-server/cnch_config.xml

# Set hdfs
sed -i -E "s|<hdfs_nnproxy>.*</hdfs_nnproxy>|<hdfs_nnproxy>hdfs://${HDFS_NAME_NODE_ADDRESS}:12000</hdfs_nnproxy>|g" /etc/byconity-server/cnch_config.xml

# Set dns config. This is optional to make sure that dns works well if you have changed the node name manually.
set +H
for DNS_PAIR in ${DNS_PAIRS[@]}
do
    IP_ADDRESS=${DNS_PAIR%:*}
    HOSTNAME=${DNS_PAIR#*:}
    if grep -q "${IP_ADDRESS}" /etc/hosts; then
        if ! grep -q "${IP_ADDRESS}.*${HOSTNAME}" /etc/hosts; then
          sed -i -E "/${IP_ADDRESS}.*${HOSTNAME}/!{0,/${IP_ADDRESS}/s|${IP_ADDRESS}.*|& ${HOSTNAME}|}" /etc/hosts
        fi
    else
        echo "${IP_ADDRESS} ${HOSTNAME}" >> /etc/hosts
    fi
done
set -H
```

**For panel node: Install tso, resource-manager, daemon-manager, server.**

```sh
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-tso-0.3.0.x86_64.rpm
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-resource-manager-0.3.0.x86_64.rpm
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-daemon-manager-0.3.0.x86_64.rpm
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-server-0.3.0.x86_64.rpm

rpm -ivh byconity-tso-*.rpm
rpm -ivh byconity-resource-manager-*.rpm
rpm -ivh byconity-daemon-manager-*.rpm
rpm -ivh byconity-server-*.rpm

systemctl start byconity-tso
systemctl start byconity-resource-manager
systemctl start byconity-daemon-manager
systemctl start byconity-server

systemctl status byconity-tso
systemctl status byconity-resource-manager
systemctl status byconity-daemon-manager
systemctl status byconity-server
```

**For worker node: Install worker.**

```sh
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-worker-0.3.0.x86_64.rpm

rpm -ivh byconity-worker-*.rpm

systemctl start byconity-worker

systemctl status byconity-worker
```

**For worker-write node: Install worker-write.**

```sh
wget https://mirror.ghproxy.com/https://github.com/ByConity/ByConity/releases/download/0.3.0/byconity-worker-write-0.3.0.x86_64.rpm

rpm -ivh byconity-worker-write-*.rpm

systemctl start byconity-worker-write

systemctl status byconity-worker-write
```

**Other operations:**

```sh
systemctl list-units | grep byconity
```

# 3 Load

## 3.1 TPC-DS

[byconity-tpcds](https://github.com/ByConity/byconity-tpcds/blob/main/README.md)

From this repo, we can get all the data, ddl sql and test sql:

* `./gen_data.sh 1`: Generate data
* `byconity-tpcds/ddl/tpcds.sql`: DDL sqls.
* `byconity-tpcds/sql/standard`: DML sqls.

```sh
tables=( $(echo "call_center catalog_page catalog_returns catalog_sales customer customer_address customer_demographics date_dim household_demographics income_band inventory item promotion reason ship_mode store store_returns store_sales time_dim warehouse web_page web_returns web_sales web_site") )

for table in ${tables[@]}
do
    files=( $(ls | grep -E "${table}[_0-9]*\.dat") )
    echo "table: ${table}, file count: ${#files[@]}"
    cat "${files[@]}" > ${table}.csv
done
```

### 3.1.1 TPC-DS With Foreign Key

* `tests/optimizers/tpcds/sql/create_table.sql`: DDL sqls with foreign key constraints ([ByConity](https://github.com/ByConity/ByConity)-Commit: `a76f48b3d9`)

# 4 System

## 4.1 Settings

```sql
SELECT * FROM system.settings;
```

## 4.2 Work Group

```sql
SELECT * FROM system.workers;
SELECT * FROM system.worker_groups;
SELECT * FROM system.virtual_warehouses;
```

# 5 Options

1. `--input_format_allow_errors_num`
1. `--input_format_allow_errors_ratio`
1. `--format_csv_delimiter`
1. `--multiquery`
1. `--query`: Execute a single SQL query from the command line.
1. `--queries-file`: File path with queries to execute
