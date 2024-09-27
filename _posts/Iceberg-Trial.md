---
title: Iceberg-Trial
date: 2024-09-23 14:43:47
tags: 
- 原创
categories: 
- Database
- Lakehouse
---

**阅读更多**

<!--more-->

# 1 Killing Feature

# 2 Spark & Iceberg

## 2.1 Step1: Create a shared network

```sh
# Create a network to be used by both spark and hadoop
SHARED_NS=iceberg-ns
docker network create ${SHARED_NS}
```

## 2.2 Step2: Start Hadoop

Start a single-node hadoop cluster joining the shared network.

```sh
SHARED_NS=iceberg-ns
HADOOP_CONTAINER_NAME=iceberg-hadoop

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

## 2.3 Step3: Start Spark

Start a spark container joining the shared network.

```sh
SHARED_NS=iceberg-ns
HADOOP_CONTAINER_NAME=iceberg-hadoop
SPARK_CONTAINER_NAME=iceberg-spark

docker run -dit --name ${SPARK_CONTAINER_NAME} --network ${SHARED_NS} -e HADOOP_CONTAINER_NAME=${HADOOP_CONTAINER_NAME} spark:3.5.2-scala2.12-java17-python3-ubuntu bash
# Setup home directory for user spark, otherwise spark's package installation mechanism won't work, which will store jars in directory: /home/spark/.ivy2/cache
docker exec -u root ${SPARK_CONTAINER_NAME} bash -c 'mkdir -p /home/spark; chmod 755 /home/spark; chown -R spark:spark /home/spark'

# Create iceberg warehouse
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs dfs -mkdir -p /user/iceberg/demo'
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs dfs -chown spark:supergroup /user/iceberg/demo'

docker exec -it ${SPARK_CONTAINER_NAME} /opt/spark/bin/spark-sql \
    --packages org.apache.iceberg:iceberg-spark-runtime-3.5_2.12:1.6.1 \
    --conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions \
    --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog \
    --conf spark.sql.catalog.spark_catalog.type=hive \
    --conf spark.sql.catalog.iceberg_demo=org.apache.iceberg.spark.SparkCatalog \
    --conf spark.sql.catalog.iceberg_demo.type=hadoop \
    --conf spark.sql.catalog.iceberg_demo.warehouse=hdfs://${HADOOP_CONTAINER_NAME}/user/iceberg/demo
```

Test:

```sql
CREATE TABLE iceberg_demo.db.table (id bigint, data string) USING iceberg;
INSERT INTO iceberg_demo.db.table VALUES (1, 'a'), (2, 'b'), (3, 'c');
SELECT * FROM iceberg_demo.db.table;
```

# 3 Trino & Iceberg

Trino only support hive-metastore based catalog rather than raw hadoop filesystem based catalog.

## 3.1 Step1 & Step2

We can use the same container and network created in section [Step1: Create a shared network](#21-step1-create-a-shared-network) and [Step2: Start a hadoop as storage of iceberg](#22-step2-start-hadoop)

## 3.2 Step3: Start Hive

[Apache Hive - Quickstart](https://hive.apache.org/developement/quickstart/)

Start a hive container joining the shared network.

* **Tez-tips: Don't use `apache-tez-0.10.3-bin.tar.gz` directly but use `share/tez.tar.gz` after uncompressing. ([Error: Could not find or load main class org.apache.tez.dag.app.DAGAppMaster](https://stackoverflow.com/questions/72211046/error-could-not-find-or-load-main-class-org-apache-tez-dag-app-dagappmaster))**

```sh
SHARED_NS=iceberg-ns
HADOOP_CONTAINER_NAME=iceberg-hadoop
HIVE_SERVER_CONTAINER_NAME=iceberg-hive-server

# Download tez resources and put to hdfs
docker exec ${HADOOP_CONTAINER_NAME} bash -c '
if ! hdfs dfs -ls /opt/tez/tez.tar.gz > /dev/null 2>&1; then
    mkdir -p /opt/tez
    wget -qO /opt/tez/apache-tez-0.10.3-bin.tar.gz https://downloads.apache.org/tez/0.10.3/apache-tez-0.10.3-bin.tar.gz
    tar -zxf /opt/tez/apache-tez-0.10.3-bin.tar.gz -C /opt/tez
    hdfs dfs -mkdir -p /opt/tez
    hdfs dfs -put -f /opt/tez/apache-tez-0.10.3-bin/share/tez.tar.gz /opt/tez
fi
'

# Grant permission for user hive
docker exec ${HADOOP_CONTAINER_NAME} bash -c 'hdfs dfs -setfacl -R -m user:hive:rwx /'

cat > /tmp/hive-site.xml << EOF
<configuration>
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
        <value>/opt/hive/scratch_dir</value>
    </property>
    <property>
        <name>hive.user.install.directory</name>
        <value>/opt/hive/install_dir</value>
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
        <value>/opt/hive/data/warehouse</value>
    </property>
    <property>
        <name>metastore.metastore.event.db.notification.api.auth</name>
        <value>false</value>
    </property>
</configuration>
EOF

# Copy hadoop config file from container
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/core-site.xml /tmp/core-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/hdfs-site.xml /tmp/hdfs-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/yarn-site.xml /tmp/yarn-site.xml
docker cp ${HADOOP_CONTAINER_NAME}:/opt/hadoop/etc/hadoop/mapred-site.xml /tmp/mapred-site.xml

docker run -d --name ${HIVE_SERVER_CONTAINER_NAME} --network ${SHARED_NS} -e SERVICE_NAME=hiveserver2 \
  -v /tmp/hive-site.xml:/opt/hive/conf/hive-site.xml \
  -v /tmp/core-site.xml:/opt/hadoop/etc/hadoop/core-site.xml \
  -v /tmp/hdfs-site.xml:/opt/hadoop/etc/hadoop/hdfs-site.xml \
  -v /tmp/yarn-site.xml:/opt/hadoop/etc/hadoop/yarn-site.xml \
  -v /tmp/mapred-site.xml:/opt/hadoop/etc/hadoop/mapred-site.xml \
  apache/hive:4.0.0
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

# 4 API-Demo

```
    <properties>
        <iceberg.version>1.6.1</iceberg.version>
        <parquet.version>1.13.1</parquet.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-api</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-bundled-guava</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-common</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-core</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-hive-metastore</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-parquet</artifactId>
            <version>${iceberg.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.iceberg</groupId>
            <artifactId>iceberg-aws</artifactId>
            <version>${iceberg.version}</version>
        </dependency>

        <dependency>
            <groupId>org.apache.parquet</groupId>
            <artifactId>parquet-common</artifactId>
            <version>${parquet.version}</version>
        </dependency>
        <dependency>
            <groupId>org.apache.parquet</groupId>
            <artifactId>parquet-column</artifactId>
            <version>${parquet.version}</version>
        </dependency>
    </dependencies>
```

```java
package org.byconity.iceberg;

import org.apache.commons.compress.utils.Lists;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.util.Sets;
import org.apache.iceberg.*;
import org.apache.iceberg.catalog.Namespace;
import org.apache.iceberg.catalog.TableIdentifier;
import org.apache.iceberg.data.GenericRecord;
import org.apache.iceberg.data.Record;
import org.apache.iceberg.data.parquet.GenericParquetReaders;
import org.apache.iceberg.data.parquet.GenericParquetWriter;
import org.apache.iceberg.deletes.EqualityDeleteWriter;
import org.apache.iceberg.deletes.PositionDelete;
import org.apache.iceberg.deletes.PositionDeleteWriter;
import org.apache.iceberg.hadoop.HadoopCatalog;
import org.apache.iceberg.io.*;
import org.apache.iceberg.parquet.Parquet;
import org.apache.iceberg.types.Types;

import java.io.Closeable;
import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public class IceBergDemo {
    private final static Schema POSITIONAL_DELETE_SCHEMA =
            // Those field ids are reserved
            new Schema(Types.NestedField.required(2147483546, "file_path", Types.StringType.get()),
                    Types.NestedField.required(2147483545, "pos", Types.LongType.get()));

    private final Configuration hdfsConf;
    private final Path warehousePath;
    private final List<Record> records = Lists.newArrayList();

    private HadoopCatalog hadoopCatalog;
    private Table table;
    private String dataFilePath;
    private Schema idEqdeleteSchema;

    public IceBergDemo(String host, int port) {
        this.hdfsConf = new Configuration();
        this.hdfsConf.set("fs.defaultFS", String.format("hdfs://%s:%d", host, port));
        // Use full path here, including the protocol, otherwise, spark cannot parse metadata
        // correctly
        this.warehousePath = new Path(String.format("hdfs://%s:%d/user/iceberg/demo", host, port));
    }

    public void run() throws IOException {
        try {
            createTable();
            writeDataToTable();
            readDataFromTable();
            deleteIdEqualsTo(1);
            deleteSpecificRowByPosition(2);
            readDataFromTable();
        } finally {
            close();
        }
    }

    private void close() throws IOException {
        if (hadoopCatalog != null) {
            hadoopCatalog.close();
        }
    }

    private void clearPath() throws IOException {
        FileSystem fileSystem = FileSystem.get(hdfsConf);
        fileSystem.delete(warehousePath, true);
        fileSystem.mkdirs(warehousePath);
    }

    private void createTable() throws IOException {
        clearPath();

        hadoopCatalog = new HadoopCatalog(hdfsConf, warehousePath.toString());

        Schema schema = new Schema(Types.NestedField.required(1, "id", Types.IntegerType.get()),
                Types.NestedField.optional(2, "name", Types.StringType.get()),
                Types.NestedField.optional(3, "age", Types.IntegerType.get()));

        String namespaceName = "demo_namespace";
        Namespace namespace = Namespace.of(namespaceName);

        List<Namespace> namespaces = hadoopCatalog.listNamespaces();
        if (!namespaces.contains(namespace)) {
            hadoopCatalog.createNamespace(namespace);
        }

        String tablename = "demo_table";
        TableIdentifier tableIdentifier = TableIdentifier.of(namespaceName, tablename);
        List<TableIdentifier> tableIdentifiers = hadoopCatalog.listTables(namespace);
        if (!tableIdentifiers.contains(tableIdentifier)) {
            hadoopCatalog.createTable(tableIdentifier, schema);
        }

        table = hadoopCatalog.loadTable(tableIdentifier);
    }

    private Record buildRecord(int id, String name, int age) {
        Record record = GenericRecord.create(table.schema());
        record.setField("id", id);
        record.setField("name", name);
        record.setField("age", age);
        records.add(record);
        return record;
    }

    private void writeDataToTable() throws IOException {
        try (FileIO io = table.io()) {
            dataFilePath = table.location() + String.format("/data/%s.parquet", UUID.randomUUID());
            OutputFile outputFile = io.newOutputFile(dataFilePath);

            try (FileAppender<Record> writer = Parquet.write(outputFile).schema(table.schema())
                    .createWriterFunc(GenericParquetWriter::buildWriter).build()) {
                writer.add(buildRecord(1, "Alice", 30));
                writer.add(buildRecord(2, "Tom", 18));
                writer.add(buildRecord(3, "Jerry", 22));
            }

            DataFile dataFile = DataFiles.builder(PartitionSpec.unpartitioned())
                    .withInputFile(outputFile.toInputFile()).withRecordCount(1)
                    .withFormat(FileFormat.PARQUET).build();

            AppendFiles append = table.newAppend();
            append.appendFile(dataFile);
            append.commit();
        }
    }

    private void deleteSpecificRowByPosition(long position) throws IOException {
        try (FileIO io = table.io()) {
            OutputFile outputFile = io.newOutputFile(
                    table.location() + "/pos-deletes-" + UUID.randomUUID() + ".parquet");

            PositionDeleteWriter<Record> writer = Parquet.writeDeletes(outputFile).forTable(table)
                    .rowSchema(table.schema()).createWriterFunc(GenericParquetWriter::buildWriter)
                    .overwrite().withSpec(PartitionSpec.unpartitioned()).buildPositionWriter();

            PositionDelete<Record> record = PositionDelete.create();
            record = record.set(dataFilePath, position, records.get((int) position));
            try (Closeable ignore = writer) {
                writer.write(record);
            }

            table.newRowDelta().addDeletes(writer.toDeleteFile()).commit();
        }

        table.refresh();
    }

    private void deleteIdEqualsTo(int id) throws IOException {
        idEqdeleteSchema = new Schema(Types.NestedField.required(1, "id", Types.IntegerType.get()));

        try (FileIO io = table.io()) {
            OutputFile outputFile = io.newOutputFile(
                    table.location() + "/equality-deletes-" + UUID.randomUUID() + ".parquet");

            EqualityDeleteWriter<Record> writer = Parquet.writeDeletes(outputFile).forTable(table)
                    .rowSchema(idEqdeleteSchema).createWriterFunc(GenericParquetWriter::buildWriter)
                    .overwrite().equalityFieldIds(1).buildEqualityWriter();

            Record deleteRecord = GenericRecord.create(idEqdeleteSchema);
            deleteRecord.setField("id", id);
            try (Closeable ignore = writer) {
                writer.write(deleteRecord);
            }

            RowDelta rowDelta = table.newRowDelta();
            rowDelta.addDeletes(writer.toDeleteFile()); // Here, the writer must be at closed state
            rowDelta.commit();
        }

        table.refresh();
    }

    private void readDataFromTable() throws IOException {
        System.out.println("Current Snapshot ID: " + table.currentSnapshot().snapshotId());

        TableScan scan = table.newScan();
        try (CloseableIterable<FileScanTask> tasks = scan.planFiles()) {
            for (FileScanTask task : tasks) {
                List<DeleteFile> deletes = task.deletes();
                Set<Integer> deletedIds = Sets.newHashSet();
                Set<Long> deletedPos = Sets.newHashSet();
                for (DeleteFile delete : deletes) {
                    switch (delete.content()) {
                        case EQUALITY_DELETES:
                            try (FileIO io = table.io()) {
                                InputFile inputFile = io.newInputFile(delete.path().toString());
                                try (CloseableIterable<Record> records = Parquet.read(inputFile)
                                        .project(idEqdeleteSchema)
                                        .createReaderFunc(messageType -> GenericParquetReaders
                                                .buildReader(idEqdeleteSchema, messageType))
                                        .build()) {

                                    for (Record record : records) {
                                        System.out.println("Equality delete record: " + record);
                                        deletedIds.add((int) record.getField("id"));
                                    }
                                }
                            }
                            break;
                        case POSITION_DELETES:
                            try (FileIO io = table.io()) {
                                InputFile inputFile = io.newInputFile(delete.path().toString());
                                try (CloseableIterable<Record> records = Parquet.read(inputFile)
                                        .project(POSITIONAL_DELETE_SCHEMA)
                                        .createReaderFunc(messageType -> GenericParquetReaders
                                                .buildReader(POSITIONAL_DELETE_SCHEMA, messageType))
                                        .build()) {

                                    for (Record record : records) {
                                        System.out.println("Position delete record: " + record);
                                        deletedPos.add((long) record.getField("pos"));
                                    }
                                }
                            }
                            break;
                    }
                }
                try (FileIO io = table.io()) {
                    InputFile inputFile = io.newInputFile(task.file().path().toString());
                    try (CloseableIterable<Record> records =
                            Parquet.read(inputFile).project(table.schema())
                                    .createReaderFunc(messageType -> GenericParquetReaders
                                            .buildReader(table.schema(), messageType))
                                    .build()) {

                        long pos = -1;
                        for (Record record : records) {
                            pos++;
                            if (!deletedIds.contains((int) record.getField("id"))
                                    && !deletedPos.contains(pos)) {
                                System.out.println(record);
                            }
                        }
                    }
                }
            }
        }
    }

    public static void main(String[] args) throws IOException {
        IceBergDemo iceBergDemo = new IceBergDemo("192.168.64.2", 9000);
        iceBergDemo.run();
    }
}
```

# 5 Tips

## 5.1 Reserved Field Ids

Refer to [Reserved Field IDs](https://github.com/apache/iceberg/blob/main/format/spec.md) for details.

# 6 Reference

* [Iceberg Docs](https://iceberg.apache.org/docs/nightly/)
* [Iceberg Spec](https://iceberg.apache.org/spec/)
* [优化数据查询性能：StarRocks 与 Apache Iceberg 的强强联合](https://mp.weixin.qq.com/s/wP9q7NACYEyY-TdrSceq4A)
* [StarRocks Lakehouse 快速入门——Apache Iceberg](https://mp.weixin.qq.com/s/pIXKXKNBLG5EPkAkiowBLQ)
