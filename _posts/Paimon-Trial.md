---
title: Paimon-Trial
date: 2024-06-07 23:05:38
tags: 
- 原创
categories: 
- Database
- Lakehouse
---

**阅读更多**

<!--more-->

# 1 Paimon With Hive

[Doc](https://paimon.apache.org/docs/master/engines/hive/)

First, start a hive cluster by [docker-hive](https://github.com/big-data-europe/docker-hive)

```sh
cd docker-hive
docker-compose up -d
```

Second, download paimon-hive-connector with corresponding version.

```sh
wget -O paimon-hive-connector-2.3-0.8.0.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-hive-connector-2.3/0.8.0/paimon-hive-connector-2.3-0.8.0.jar'
```

Then, copy the jar file into hive's container, and restart it

```sh
docker exec docker-hive-hive-server-1 mkdir -p /opt/hive/auxlib
docker cp paimon-hive-connector-2.3-0.8.0.jar docker-hive-hive-server-1:/opt/hive/auxlib
docker restart docker-hive-hive-server-1
```

Finally, test it:

```sh
docker exec -it docker-hive-hive-server-1 bash
/opt/hive/bin/beeline -u jdbc:hive2://localhost:10000

CREATE TABLE `hive_paimon_test_table`(
  `a` int COMMENT 'The a field',
  `b` string COMMENT 'The b field'
) STORED BY 'org.apache.paimon.hive.PaimonStorageHandler';

INSERT INTO hive_paimon_test_table (a, b) VALUES (1, '1'), (2, '2');

SELECT * FROM hive_paimon_test_table;
```

# 2 Paimon With Spark

[Doc](https://paimon.apache.org/docs/master/spark/quick-start/)

First, start a spark cluster by [docker-spark](https://github.com/big-data-europe/docker-spark)

```sh
cd docker-spark
docker-compose up -d
```

Second, download paimon-spark with corresponding version.

```sh
wget -O paimon-spark-3.3-0.8.0.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-spark-3.3/0.8.0/paimon-spark-3.3-0.8.0.jar'
```

Then, copy the jar file into spark's container

```sh
docker cp paimon-spark-3.3-0.8.0.jar spark-master:/spark/jars
```

Finally, test it:

```sh
docker exec -it spark-master bash
# Catalogs are configured using properties under spark.sql.catalog.(catalog_name)
/spark/bin/spark-sql --jars /spark/jars/paimon-spark-3.3-0.8.0.jar \
    --conf spark.sql.catalog.my_test_paimon=org.apache.paimon.spark.SparkCatalog \
    --conf spark.sql.catalog.my_test_paimon.warehouse=file:/spark/paimon \
    --conf spark.sql.extensions=org.apache.paimon.spark.extensions.PaimonSparkSessionExtensions

USE my_test_paimon;
USE default;

create table my_table (
    k int,
    v string
) tblproperties (
    'primary-key' = 'k'
);

INSERT INTO my_table VALUES (1, 'Hi'), (2, 'Hello');

SELECT * FROM my_table;

# Switch back to default catalog
USE spark_catalog;
USE default;

SELECT * FROM my_test_paimon.default.my_table;
```

# 3 Paimon With Flink

[Doc](https://paimon.apache.org/docs/master/flink/quick-start/)

```sh
PAIMON_VERSION=0.8.2
SHARED_NS=hadoop-ns
FILESYSTEM_TYPE=${FILESYSTEM_TYPE:-minio} # or hadoop
FLINK_JOBMANAGER_CONTAINER_NAME="flink-jobmanager"
FLINK_TASKMANAGER_CONTAINER_NAME="flink-taskmanager"
MINIO_CONTAINER_NAME="minio"

# First, start a flink container by [Flink Docker Setup](https://nightlies.apache.org/flink/flink-docs-master/docs/deployment/resource-providers/standalone/docker/)
cat > /tmp/paimon-docker-compose.yml << EOF
version: "2.2"
services:
  ${FLINK_JOBMANAGER_CONTAINER_NAME}:
    image: apache/flink:1.19-java8
    container_name: ${FLINK_JOBMANAGER_CONTAINER_NAME}
    hostname: ${FLINK_JOBMANAGER_CONTAINER_NAME}
    ports:
      - "8081:8081"
    command: jobmanager
    environment:
      - |
        FLINK_PROPERTIES=
        jobmanager.rpc.address: ${FLINK_JOBMANAGER_CONTAINER_NAME}        

  ${FLINK_TASKMANAGER_CONTAINER_NAME}:
    image: apache/flink:1.19-java8
    container_name: ${FLINK_TASKMANAGER_CONTAINER_NAME}
    hostname: ${FLINK_TASKMANAGER_CONTAINER_NAME}
    depends_on:
      - ${FLINK_JOBMANAGER_CONTAINER_NAME}
    command: taskmanager
    scale: 1
    environment:
      - |
        FLINK_PROPERTIES=
        jobmanager.rpc.address: ${FLINK_JOBMANAGER_CONTAINER_NAME}
        taskmanager.numberOfTaskSlots: 2     

  ${MINIO_CONTAINER_NAME}:
    image: minio/minio:RELEASE.2024-04-18T19-09-19Z
    container_name: ${MINIO_CONTAINER_NAME}
    hostname: ${MINIO_CONTAINER_NAME}
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: admin123
    command: server /data --console-address ":9001"
    volumes:
      - minio_data:/data

volumes:
  minio_data:

networks:
  default:
    name: ${SHARED_NS}
    external: true
EOF

docker compose -f /tmp/paimon-docker-compose.yml up -d

# Second, download paimon-flink with corresponding version.
if [ ! -e /tmp/paimon-flink-1.19-${PAIMON_VERSION}.jar ]; then
    wget -O /tmp/paimon-flink-1.19-${PAIMON_VERSION}.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-flink-1.19/${PAIMON_VERSION}/paimon-flink-1.19-${PAIMON_VERSION}.jar'
fi
if [ ! -e /tmp/paimon-flink-action-${PAIMON_VERSION}.jar ]; then
    wget -O /tmp/paimon-flink-action-${PAIMON_VERSION}.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-flink-action/${PAIMON_VERSION}/paimon-flink-action-${PAIMON_VERSION}.jar'
fi
if [ ! -e /tmp/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar ]; then
    wget -O /tmp/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar 'https://repo.maven.apache.org/maven2/org/apache/flink/flink-shaded-hadoop-2-uber/2.8.3-10.0/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar'
fi
if [ ! -e /tmp/paimon-s3-${PAIMON_VERSION}.jar ]; then
    wget -O /tmp/paimon-s3-${PAIMON_VERSION}.jar 'https://repo.maven.apache.org/maven2/org/apache/paimon/paimon-s3/${PAIMON_VERSION}/paimon-s3-${PAIMON_VERSION}.jar'
fi

# Then, copy the jar files into flink's container
containers=( "${FLINK_JOBMANAGER_CONTAINER_NAME}" "${FLINK_TASKMANAGER_CONTAINER_NAME}" )
for container in ${containers[@]}
do
    docker cp /tmp/paimon-flink-1.19-${PAIMON_VERSION}.jar ${container}:/opt/flink/lib
    docker cp /tmp/paimon-flink-action-${PAIMON_VERSION}.jar ${container}:/opt/flink/lib
    docker cp /tmp/flink-shaded-hadoop-2-uber-2.8.3-10.0.jar ${container}:/opt/flink/lib

    if [ "${FILESYSTEM_TYPE}" = "minio" ]; then
        docker cp /tmp/paimon-s3-${PAIMON_VERSION}.jar ${container}:/opt/flink/lib
        docker exec -it ${container} cp /opt/flink/opt/flink-s3-fs-hadoop-1.19.3.jar /opt/flink/lib/
        docker exec -it ${container} cp /opt/flink/opt/flink-s3-fs-hadoop-1.19.3.jar /opt/flink/lib/
    fi
done
```

**Test:**

* For minio:

    ```sh
    docker exec -it ${MINIO_CONTAINER_NAME} bash -c "
    mc alias set local http://localhost:9000 admin admin123
    mc mb local/paimon-bucket
    mc ls local/
    "

    cat > /tmp/paimon.sql << EOF
    CREATE CATALOG my_catalog WITH (
        'type'='paimon',
        'warehouse'='s3://paimon-bucket/warehouse',
        's3.endpoint' = 'http://${MINIO_CONTAINER_NAME}:9000',
        's3.access-key' = 'admin',
        's3.secret-key' = 'admin123',
        's3.path.style.access' = 'true'
    );
    USE CATALOG my_catalog;

    -- create a word count table
    CREATE TABLE word_count (
        word STRING PRIMARY KEY NOT ENFORCED,
        cnt BIGINT
    );

    -- create a word data generator table
    CREATE TEMPORARY TABLE word_table (
        word STRING
    ) WITH (
        'connector' = 'datagen',
        'fields.word.length' = '1'
    );

    -- paimon requires checkpoint interval in streaming mode
    SET 'execution.checkpointing.interval' = '10 s';

    -- write streaming data to dynamic table
    INSERT INTO word_count SELECT word, COUNT(*) FROM word_table GROUP BY word;

    -- use tableau result mode
    SET 'sql-client.execution.result-mode' = 'tableau';

    -- switch to batch mode
    RESET 'execution.checkpointing.interval';
    SET 'execution.runtime-mode' = 'batch';

    -- olap query the table
    SELECT * FROM word_count;

    -- switch to streaming mode
    SET 'execution.runtime-mode' = 'streaming';

    -- track the changes of table and calculate the count interval statistics
    SELECT \`interval\`, COUNT(*) AS interval_cnt FROM
        (SELECT cnt / 10000 AS \`interval\` FROM word_count) GROUP BY \`interval\`;
    EOF

    docker cp /tmp/paimon.sql ${FLINK_JOBMANAGER_CONTAINER_NAME}:/tmp/paimon.sql
    docker exec -it ${FLINK_JOBMANAGER_CONTAINER_NAME} /opt/flink/bin/sql-client.sh embedded -f /tmp/paimon.sql
    ```

* For hadoop: (You need to start hadoop cluster in same namespace by your own)
    ```sh
    HADOOP_CONTAINER_NAME="namenode"

    cat > /tmp/paimon.sql << EOF
    CREATE CATALOG my_catalog WITH (
        'type'='paimon',
        'warehouse'='hdfs://${HADOOP_CONTAINER_NAME}/paimon/warehouse'
    );
    USE CATALOG my_catalog;

    -- create a word count table
    CREATE TABLE word_count (
        word STRING PRIMARY KEY NOT ENFORCED,
        cnt BIGINT
    );

    -- create a word data generator table
    CREATE TEMPORARY TABLE word_table (
        word STRING
    ) WITH (
        'connector' = 'datagen',
        'fields.word.length' = '1'
    );

    -- paimon requires checkpoint interval in streaming mode
    SET 'execution.checkpointing.interval' = '10 s';

    -- write streaming data to dynamic table
    INSERT INTO word_count SELECT word, COUNT(*) FROM word_table GROUP BY word;

    -- use tableau result mode
    SET 'sql-client.execution.result-mode' = 'tableau';

    -- switch to batch mode
    RESET 'execution.checkpointing.interval';
    SET 'execution.runtime-mode' = 'batch';

    -- olap query the table
    SELECT * FROM word_count;

    -- switch to streaming mode
    SET 'execution.runtime-mode' = 'streaming';

    -- track the changes of table and calculate the count interval statistics
    SELECT \`interval\`, COUNT(*) AS interval_cnt FROM
        (SELECT cnt / 10000 AS \`interval\` FROM word_count) GROUP BY \`interval\`;
    EOF

    docker cp /tmp/paimon.sql ${FLINK_JOBMANAGER_CONTAINER_NAME}:/tmp/paimon.sql
    docker exec -it ${FLINK_JOBMANAGER_CONTAINER_NAME} /opt/flink/bin/sql-client.sh embedded -f /tmp/paimon.sql
    ```

# 4 Paimon With Trino

[Doc](https://paimon.apache.org/docs/master/engines/trino/)

Firstly, assuming that you've already started a trino container named `trino`, and can access a hdfs cluster. This can be done according to {% post_link Trino-Trial %}

```sh
git clone https://github.com/apache/paimon-trino.git
cd paimon-trino/paimon-trino-427
mvn clean install -DskipTests

cd target
mkdir plugin
tar -zxf paimon-trino-427-*.tar.gz -C plugin
docker cp plugin/paimon trino:/usr/lib/trino/plugin

docker exec -it trino bash -c 'echo -e "connector.name=paimon\nmetastore=filesystem\nwarehouse=hdfs://namenode:8020/user/paimon" > /etc/trino/catalog/paimon.properties'
docker restart trino
docker exec -it trino trino --catalog paimon
```

How to clean:

```sh
docker exec -it --user root trino bash -c 'rm -f /etc/trino/catalog/paimon.properties'
docker exec -it --user root trino bash -c 'rm -rf /usr/lib/trino/plugin/paimon'
```

# 5 Options

1. `org.apache.paimon.CoreOptions`

# 6 Features

1. Changelog Producer
1. [Deletion Vectors](https://paimon.apache.org/docs/0.8/primary-key-table/deletion-vectors/)

# 7 SDK Demos

## 7.1 Kerberos

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.paimon.catalog.Catalog;
import org.apache.paimon.catalog.CatalogContext;
import org.apache.paimon.catalog.CatalogFactory;
import org.apache.paimon.options.CatalogOptions;
import org.apache.paimon.options.Options;

public class KerberosDemo {
    public static void main(String[] args) throws Exception {
        System.setProperty("sun.security.krb5.debug", "true");
        String namenode = args[0];
        String user = args[1];
        String keytabPath = args[2];
        String kerberosConfigPath = args[3];
        System.setProperty("java.security.krb5.conf", kerberosConfigPath);

        // Initialize Hadoop security
        Configuration hadoopConf = new Configuration();
        hadoopConf.set("hadoop.security.authentication", "kerberos");
        hadoopConf.set("hadoop.security.authorization", "true");
        UserGroupInformation.setConfiguration(hadoopConf);
        UserGroupInformation.loginUserFromKeytab(user, keytabPath);

        // Set Paimon options
        Options options = new Options();
        options.set(CatalogOptions.METASTORE, "filesystem");
        options.set(CatalogOptions.WAREHOUSE,
                String.format("hdfs://%s:8020/users/paimon/warehouse", namenode));

        // Create and use the catalog
        CatalogContext context = CatalogContext.create(options);
        Catalog catalog = CatalogFactory.createCatalog(context);

        System.out.println("Catalog created successfully: " + catalog);
    }
}
```

# 8 Issue

## 8.1 Timeout waiting for connection from pool

* [S3A Performance](https://paimon.apache.org/docs/0.8/filesystems/s3/)
* [Spark on Amazon EMR: "Timeout waiting for connection from pool"](https://stackoverflow.com/questions/39185956/spark-on-amazon-emr-timeout-waiting-for-connection-from-pool)

**Please DO remember to close the reader/writer instance, otherwise, the connections may not be properly released**

* S3 catalog has this issue.
