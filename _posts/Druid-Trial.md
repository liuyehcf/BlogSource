---
title: Druid-Trial
date: 2022-01-25 09:53:57
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 组件介绍

**组件构成，参考[Design](https://druid.apache.org/docs/latest/design/architecture.html)：**

* **`master`：负责协调集群**
    * `coordinator`：负责集群中数据的可用性管理
    * `overload`：负责对数据导入任务进行调度
    * `zookeeper`
* **`data-server`：包括数据存储、计算等功能**
    * `historical`：负责管理持久化的数据
    * `middle_manager`：负责进行数据的导入
    * `zookeeper`
* **`query-server`：包括控制台，数据导入等功能功能**
    * `broker`：负责处理来自外部客户端的查询请求
    * `router`：负责路由请求
    * `zookeeper`

# 2 部署

## 2.1 部署模式

**`Druid`包含多种部署模式，包括：**

1. `Cluster`
1. `Single-Server`，按照规模大小又可细分为多种规格
    * `large`
    * `medium`
    * `small`
    * `micro-quickstart`：用于Demo
    * `nano-quickstart`：用于Demo

## 2.2 配置

**不同的运行模式对应着不同的配置文件路径，如下（省略具体配置文件）：**

```
conf
├── druid
│   ├── cluster
│   └── single-server
│       ├── large
│       ├── medium
│       ├── micro-quickstart
│       ├── nano-quickstart
│       ├── small
│       └── xlarge
├── supervise
│   ├── cluster
│   └── single-server
└── zk
```

**完整的配置请参考[Configuration reference](https://druid.apache.org/docs/latest/configuration/index.html)**

**下面列出本文涉及到的配置项（省略配置文件路径前缀`conf/druid/cluster/`）：**

| 配置文件路径 | 配置项 | 描述 |
|:--|:--|:--|
| `_common/common.runtime.properties` | `druid.extensions.loadList` | 用于配置更多的扩展加载方式，新增的扩展都要安装相应插件 |
| `_common/common.runtime.properties` | `druid.host` | 当前机器的host，用于服务注册和服务发现 |
| `_common/common.runtime.properties` | `druid.zk.service.host` | 集群中所有机器的host和port，用于服务发现 |
| `_common/common.runtime.properties` | `druid.oss.accessKey` | 阿里云`AccessKey` |
| `_common/common.runtime.properties` | `druid.oss.secretKey` | 阿里云`AccessSecret` |
| `_common/common.runtime.properties` | `druid.oss.endpoint` | OSS的接入区域 |
| `query/broker/runtime.properties` | `druid.server.http.maxSubqueryRows` | 子查询最大的行数，默认是。否则会报错，错误信息：`Resource limit exceeded. Subquery generated results beyond maximum[100000]` |
| `data/historical/runtime.properties` | `druid.segmentCache.locations` | 存储位置以及存储容量 |
| `data/historical/runtime.properties` | `druid.processing.buffer.sizeBytes` | 单个`Buffer`的容量 |
| `data/historical/runtime.properties` | `druid.processing.numMergeBuffers` | 用于`Merge`查询结果的`Buffer`数量 |
| `data/historical/runtime.properties` | `druid.processing.numThreads` | 处理线程数量，最好与物理核数一样。每个线程会独占一个`Buffer` |
| `data/historical/runtime.properties` | `druid.cache.sizeInBytes` | `Cache`的容量 |
| `data/historical/jvm.config` | `-XX:MaxDirectMemorySize` | `DirectMemroy`的容量。该值必须大于`druid.processing.buffer.sizeBytes * (druid.processing.numMergeBuffers + druid.processing.numThreads + 1)` |

## 2.3 集群部署

[Clustered deployment](https://druid.apache.org/docs/latest/tutorials/cluster.html)

**这里我们仅关注`Cluster`模式，其配置文件的目录结构大致如下：**

```
conf
├── druid
│   ├── cluster
│   │   ├── _common
│   │   │   ├── common.runtime.properties
│   │   │   └── log4j2.xml
│   │   ├── data
│   │   │   ├── historical
│   │   │   │   ├── jvm.config
│   │   │   │   ├── main.config
│   │   │   │   └── runtime.properties
│   │   │   ├── indexer
│   │   │   │   ├── jvm.config
│   │   │   │   ├── main.config
│   │   │   │   └── runtime.properties
│   │   │   └── middleManager
│   │   │       ├── jvm.config
│   │   │       ├── main.config
│   │   │       └── runtime.properties
│   │   ├── master
│   │   │   └── coordinator-overlord
│   │   │       ├── jvm.config
│   │   │       ├── main.config
│   │   │       └── runtime.properties
│   │   └── query
│   │       ├── broker
│   │       │   ├── jvm.config
│   │       │   ├── main.config
│   │       │   └── runtime.properties
│   │       └── router
│   │           ├── jvm.config
│   │           ├── main.config
│   │           └── runtime.properties
```

**如果没有太多个性化的配置需要，仅关注`conf/druid/cluster/_common/common.runtime.properties`这个配置文件即可（`master/data-server/query-server`都这样配置）**

* `druid.extensions.loadList`：在最后增加一项`aliyun-oss-extensions`，以便支持从`Aliyun OSS`导入数据。还需要安装相应的插件，后面再说
* `druid.host`：当前部署机器的Ip或者域名，每台机器不一样
* `druid.zk.service.host`：所有待部署机器的`zk-service`列表，以逗号分隔。各个组件就是依靠这个配置来注册自己以及发现对方的，非常重要
    * 例如我有三台机器，ip分别为`192.168.0.1/192.168.0.2/192.168.0.3`，那么该配置项就是`druid.zk.service.host=192.168.0.1:2181,192.168.0.2:2181,192.168.0.3:2181`
* `druid.oss.accessKey`：`Aliyun`的`accessKey`，在阿里云控制台上可以查看
* `druid.oss.secretKey`：`Aliyun`的`accessSecret`，在阿里云控制台上可以查看
* `druid.oss.endpoint`：`Aliyun OSS Bucket`所在的域，例如`oss-cn-zhangjiakou.aliyuncs.com`

**调整`data-server`的存储容量（`conf/druid/cluster/data/historical/runtime.properties`）：**

* `druid.segmentCache.locations`：调整配置项中的`maxSize`字段的值即可

**安装`aliyun-oss-extensions`相关插件（[Aliyun OSS](https://druid.apache.org/docs/latest/development/extensions-contrib/aliyun-oss.html)）：**

* 在工程根目录下执行：`java -classpath "lib/*" org.apache.druid.cli.Main tools pull-deps -c org.apache.druid.extensions.contrib:aliyun-oss-extensions:{YOUR_DRUID_VERSION}`，其中`{YOUR_DRUID_VERSION}`替换为版本号

**启动：**

* `master`：`nohup bin/start-cluster-master-with-zk-server > master.log 2>&1 &`
* `data-server`：`nohup bin/start-cluster-data-server > data.log 2>&1 &`
* `query-server`：`nohup bin/start-cluster-query-server > query.log 2>&1 &`
* 注意，如果在同一台机器上运行多个组件，需要多个工程副本，不能在同一个目录中运行多个组件

# 3 数据导入

**这里仅展示如何从`OSS`中将数据导入`Druid`，至于如何生成对应测试集的`csv/tsv`格式的数据，以及切片上传到`OSS`这些过程都不再赘述**

**导入数据需要提交一个`Spec`，格式一般如下：**

* `spec.dataSchema.dataSource`：表名
* `spec.dataSchema.timestampSpec`：指定时间戳的格式，需要关联列明，用于分区。如果数据表没有表示时间的列，那么随便写一个列名即可，但是配置项必须要有
    * 如果指定的列不存在，那么需要额外配置`spec.dataSchema.dimensionExclusions`
* `spec.dataSchema.dimensionsSpec`：列的定义，包括列名、字段类型、是否支持`bitmap`等
* `spec.ioConfig.inputSource.prefixes`：`OSS`路径前缀，一般来说，我们都会将对应表结构的`csv/tsv`数据分片放在某个目录下，这样就能够加载该目录下的所有`csv/tsv`文件了
* `spec.ioConfig.inputSource.uris`：指定加载某几个文件
* `spec.ioConfig.inputFormat.columns`：`csv/tsv`中数据对应的列名
* `spec.ioConfig.appendToExisting`：是否追加到已有的表中
* `spec.tuningConfig.maxRowsInMemory`：在持久化到硬盘前，内存中最多可以存放的数据的行数（太高容易OOM，看情况设置）
* `spec.tuningConfig.maxNumConcurrentSubTasks`：控制导入的并发度（太高容易OOM，看情况设置）

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "<TBD>",
            "timestampSpec": {},
            "dimensionsSpec": {},
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "prefixes": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "columns": [],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

**此外，有关数据类型可以参考[data-types](https://druid.apache.org/docs/0.22.1/querying/sql.html#data-types)**

## 3.1 转换小工具

**`transform_spec_for_druid.sh`内容如下**

```sh
#!/bin/bash

file=$1
blank_num=$2

blank=""
for((i=0; i<${blank_num}; i++))
do
    blank=${blank}" "
done
fields=( $(cat ${file} | awk '{print $1}') )
types=( $(cat ${file} | awk '{print $2}' | tr 'A-Z' 'a-z') )

function getType() {
    local type=$1
    if [[ "${type}" =~ "char" ]]; then
        echo "string"
        return
    fi
    if [[ "${type}" =~ "int" ]]; then
        echo "long"
        return
    fi
    if [[ "${type}" =~ "date" ]]; then
        echo "string"
        return
    fi
    if [[ "${type}" =~ "decimal" ]]; then
        echo "double"
        return
    fi
    echo "error"
    exit 1
}

echo "spec.dataSchema.dimensionsSpec.dimensions:"

for((i=0; i<${#fields[@]}; i++))
do
    field_name=${fields[i]}
    field_type=$(getType ${types[i]})
    echo "${blank}{"
    echo "${blank}    \"type\": \"${field_type}\","
    echo "${blank}    \"name\": \"${field_name}\","
    echo "${blank}    \"multiValueHandling\": \"SORTED_ARRAY\","
    echo "${blank}    \"createBitmapIndex\": true"
    if [ $i -eq $((${#fields[@]} - 1)) ]; then
        echo "${blank}}"
    else
        echo "${blank}},"
    fi
done

echo
echo "spec.ioConfig.inputFormat.columns:"

for((i=0; i<${#fields[@]}; i++))
do
    field_name=${fields[i]}
    if [ $i -eq $((${#fields[@]} - 1)) ]; then
        echo "${blank}\"${field_name}\""
    else
        echo "${blank}\"${field_name}\","
    fi
done
```

**假设有如下建表语句：**

```sql
create table ship_mode
(
    sm_ship_mode_sk           integer               not null,
    sm_ship_mode_id           char(16)              not null,
    sm_type                   char(30)                      ,
    sm_code                   char(10)                      ,
    sm_carrier                char(20)                      ,
    sm_contract               char(20)
)
```

**将中间部分（即如下内容），粘贴到文件`input.txt`中**

```
    sm_ship_mode_sk           integer               not null,
    sm_ship_mode_id           char(16)              not null,
    sm_type                   char(30)                      ,
    sm_code                   char(10)                      ,
    sm_carrier                char(20)                      ,
    sm_contract               char(20)
```

**然后执行：`./transform_spec_for_druid.sh input.txt 20`，便可以产生如下两段输出，将其粘贴到`spec.json`中的对应位置即可**

1. `spec.dataSchema.dimensionsSpec.dimensions`
1. `spec.ioConfig.inputFormat.columns`

## 3.2 SSB

### 3.2.1 customer

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "customer",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "c_custkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_address",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_nation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_region",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_phone",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_mktsegment",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "c_custkey",
                    "c_name",
                    "c_address",
                    "c_city",
                    "c_nation",
                    "c_region",
                    "c_phone",
                    "c_mktsegment"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.2.2 dates

**`d_datekey`字段存储的是时间（`January 1, 1992`这种格式），不知道怎么配置`timestampSpec`，先用不存在的列表示**

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "dates",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "d_datekey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_dayofweek",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_month",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_year",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_yearmonthnum",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_yearmonth",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_daynuminweek",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_daynuminmonth",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_daynuminyear",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_monthnuminyear",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_weeknuminyear",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_sellingseason",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_lastdayinweekfl",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_lastdayinmonthfl",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_holidayfl",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_weekdayfl",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "d_datekey",
                    "d_date",
                    "d_dayofweek",
                    "d_month",
                    "d_year",
                    "d_yearmonthnum",
                    "d_yearmonth",
                    "d_daynuminweek",
                    "d_daynuminmonth",
                    "d_daynuminyear",
                    "d_monthnuminyear",
                    "d_weeknuminyear",
                    "d_sellingseason",
                    "d_lastdayinweekfl",
                    "d_lastdayinmonthfl",
                    "d_holidayfl",
                    "d_weekdayfl"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.2.3 lineorder

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "lineorder",
            "timestampSpec": {
                "column": "lo_orderdate",
                "format": "yyyyMMdd",
                "missingValue": null
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "lo_orderkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_linenumber",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_custkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_partkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_suppkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_orderdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_orderpriority",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_shippriority",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_extendedprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_ordtotalprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_discount",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_revenue",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_supplycost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_commitdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_shipmode",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "prefixes": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "lo_orderkey",
                    "lo_linenumber",
                    "lo_custkey",
                    "lo_partkey",
                    "lo_suppkey",
                    "lo_orderdate",
                    "lo_orderpriority",
                    "lo_shippriority",
                    "lo_quantity",
                    "lo_extendedprice",
                    "lo_ordtotalprice",
                    "lo_discount",
                    "lo_revenue",
                    "lo_supplycost",
                    "lo_tax",
                    "lo_commitdate",
                    "lo_shipmode"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.2.4 part

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "part",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "p_partkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_mfgr",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_category",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_brand",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_color",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_size",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_container",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "p_partkey",
                    "p_name",
                    "p_mfgr",
                    "p_category",
                    "p_brand",
                    "p_color",
                    "p_type",
                    "p_size",
                    "p_container"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.2.5 supplier

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "supplier",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "s_suppkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_address",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_nation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_region",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_phone",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "s_suppkey",
                    "s_name",
                    "s_address",
                    "s_city",
                    "s_nation",
                    "s_region",
                    "s_phone"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.2.6 lineorder_flat

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "lineorder_flat",
            "timestampSpec": {
                "column": "lo_orderdate",
                "format": "yyyy-MM-dd",
                "missingValue": null
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "string",
                        "name": "lo_orderdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_orderkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_linenumber",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_custkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_partkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_suppkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_orderpriority",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_shippriority",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_extendedprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_ordtotalprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_discount",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_revenue",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_supplycost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "lo_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_commitdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "lo_shipmode",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_address",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_nation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_region",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_phone",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_mktsegment",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_region",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_nation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_address",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_phone",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_mfgr",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_category",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_brand",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_color",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_size",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_container",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "prefixes": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "lo_orderdate",
                    "lo_orderkey",
                    "lo_linenumber",
                    "lo_custkey",
                    "lo_partkey",
                    "lo_suppkey",
                    "lo_orderpriority",
                    "lo_shippriority",
                    "lo_quantity",
                    "lo_extendedprice",
                    "lo_ordtotalprice",
                    "lo_discount",
                    "lo_revenue",
                    "lo_supplycost",
                    "lo_tax",
                    "lo_commitdate",
                    "lo_shipmode",
                    "c_name",
                    "c_address",
                    "c_city",
                    "c_nation",
                    "c_region",
                    "c_phone",
                    "c_mktsegment",
                    "s_region",
                    "s_nation",
                    "s_city",
                    "s_name",
                    "s_address",
                    "s_phone",
                    "p_name",
                    "p_mfgr",
                    "p_category",
                    "p_brand",
                    "p_color",
                    "p_type",
                    "p_size",
                    "p_container"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

## 3.3 TPC-H

### 3.3.1 customer

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "customer",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "C_CUSTKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "C_NAME",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "C_ADDRESS",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "C_NATIONKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "C_PHONE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "C_ACCTBAL",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "C_MKTSEGMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "C_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "C_CUSTKEY",
                    "C_NAME",
                    "C_ADDRESS",
                    "C_NATIONKEY",
                    "C_PHONE",
                    "C_ACCTBAL",
                    "C_MKTSEGMENT",
                    "C_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.2 lineitem

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "lineitem",
            "timestampSpec": {
                "column": "L_SHIPDATE",
                "format": "yyyy-MM-dd",
                "missingValue": null
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "L_ORDERKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "L_PARTKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "L_SUPPKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "L_LINENUMBER",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "L_QUANTITY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "L_EXTENDEDPRICE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "L_DISCOUNT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "L_TAX",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_RETURNFLAG",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_LINESTATUS",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_SHIPDATE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_COMMITDATE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_RECEIPTDATE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_SHIPINSTRUCT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_SHIPMODE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "L_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "prefixes": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "L_ORDERKEY",
                    "L_PARTKEY",
                    "L_SUPPKEY",
                    "L_LINENUMBER",
                    "L_QUANTITY",
                    "L_EXTENDEDPRICE",
                    "L_DISCOUNT",
                    "L_TAX",
                    "L_RETURNFLAG",
                    "L_LINESTATUS",
                    "L_SHIPDATE",
                    "L_COMMITDATE",
                    "L_RECEIPTDATE",
                    "L_SHIPINSTRUCT",
                    "L_SHIPMODE",
                    "L_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.3 nation

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "nation",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "N_NATIONKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "N_NAME",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "N_REGIONKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "N_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "N_NATIONKEY",
                    "N_NAME",
                    "N_REGIONKEY",
                    "N_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.4 orders

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "orders",
            "timestampSpec": {
                "column": "O_ORDERDATE",
                "format": "yyyy-MM-dd",
                "missingValue": null
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "O_ORDERKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "O_CUSTKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "O_ORDERSTATUS",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "O_TOTALPRICE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "O_ORDERDATE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "O_ORDERPRIORITY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "O_CLERK",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "O_SHIPPRIORITY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "O_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "O_ORDERKEY",
                    "O_CUSTKEY",
                    "O_ORDERSTATUS",
                    "O_TOTALPRICE",
                    "O_ORDERDATE",
                    "O_ORDERPRIORITY",
                    "O_CLERK",
                    "O_SHIPPRIORITY",
                    "O_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.5 part

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "part",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "P_PARTKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_NAME",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_MFGR",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_BRAND",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_TYPE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "P_SIZE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_CONTAINER",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "P_RETAILPRICE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "P_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "P_PARTKEY",
                    "P_NAME",
                    "P_MFGR",
                    "P_BRAND",
                    "P_TYPE",
                    "P_SIZE",
                    "P_CONTAINER",
                    "P_RETAILPRICE",
                    "P_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.6 partsupp

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "partsupp",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "PS_PARTKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "PS_SUPPKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "PS_AVAILQTY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "PS_SUPPLYCOST",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "PS_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "PS_PARTKEY",
                    "PS_SUPPKEY",
                    "PS_AVAILQTY",
                    "PS_SUPPLYCOST",
                    "PS_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.7 region

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "region",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "R_REGIONKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "R_NAME",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "R_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "R_REGIONKEY",
                    "R_NAME",
                    "R_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.3.8 supplier

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "supplier",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "S_SUPPKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "S_NAME",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "S_ADDRESS",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "S_NATIONKEY",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "S_PHONE",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "S_ACCTBAL",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "S_COMMENT",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "S_SUPPKEY",
                    "S_NAME",
                    "S_ADDRESS",
                    "S_NATIONKEY",
                    "S_PHONE",
                    "S_ACCTBAL",
                    "S_COMMENT"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

## 3.4 TPC-DS

### 3.4.1 customer_address

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "customer_address",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "ca_address_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_address_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_street_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_street_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_street_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_suite_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_county",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_state",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_zip",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ca_gmt_offset",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "ca_location_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "ca_address_sk",
                    "ca_address_id",
                    "ca_street_number",
                    "ca_street_name",
                    "ca_street_type",
                    "ca_suite_number",
                    "ca_city",
                    "ca_county",
                    "ca_state",
                    "ca_zip",
                    "ca_country",
                    "ca_gmt_offset",
                    "ca_location_type"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.2 customer_demographics

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "customer_demographics",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "cd_demo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cd_gender",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cd_marital_status",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cd_education_status",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cd_purchase_estimate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cd_credit_rating",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cd_dep_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cd_dep_employed_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cd_dep_college_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "cd_demo_sk",
                    "cd_gender",
                    "cd_marital_status",
                    "cd_education_status",
                    "cd_purchase_estimate",
                    "cd_credit_rating",
                    "cd_dep_count",
                    "cd_dep_employed_count",
                    "cd_dep_college_count"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.3 date_dim

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "date_dim",
            "timestampSpec": {
                "column": "d_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "d_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_date_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_month_seq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_week_seq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_quarter_seq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_year",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_dow",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_moy",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_dom",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_qoy",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_fy_year",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_fy_quarter_seq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_fy_week_seq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_day_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_quarter_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_holiday",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_weekend",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_following_holiday",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_first_dom",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_last_dom",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_same_day_ly",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "d_same_day_lq",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_current_day",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_current_week",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_current_month",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_current_quarter",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "d_current_year",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "d_date_sk",
                    "d_date_id",
                    "d_date",
                    "d_month_seq",
                    "d_week_seq",
                    "d_quarter_seq",
                    "d_year",
                    "d_dow",
                    "d_moy",
                    "d_dom",
                    "d_qoy",
                    "d_fy_year",
                    "d_fy_quarter_seq",
                    "d_fy_week_seq",
                    "d_day_name",
                    "d_quarter_name",
                    "d_holiday",
                    "d_weekend",
                    "d_following_holiday",
                    "d_first_dom",
                    "d_last_dom",
                    "d_same_day_ly",
                    "d_same_day_lq",
                    "d_current_day",
                    "d_current_week",
                    "d_current_month",
                    "d_current_quarter",
                    "d_current_year"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.4 warehouse

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "warehouse",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "w_warehouse_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_warehouse_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_warehouse_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "w_warehouse_sq_ft",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_street_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_street_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_street_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_suite_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_county",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_state",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_zip",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "w_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "w_gmt_offset",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "w_warehouse_sk",
                    "w_warehouse_id",
                    "w_warehouse_name",
                    "w_warehouse_sq_ft",
                    "w_street_number",
                    "w_street_name",
                    "w_street_type",
                    "w_suite_number",
                    "w_city",
                    "w_county",
                    "w_state",
                    "w_zip",
                    "w_country",
                    "w_gmt_offset"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.5 ship_mode

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "ship_mode",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "sm_ship_mode_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "sm_ship_mode_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "sm_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "sm_code",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "sm_carrier",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "sm_contract",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "sm_ship_mode_sk",
                    "sm_ship_mode_id",
                    "sm_type",
                    "sm_code",
                    "sm_carrier",
                    "sm_contract"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.6 time_dim

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "time_dim",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "t_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "t_time_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "t_time",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "t_hour",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "t_minute",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "t_second",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "t_am_pm",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "t_shift",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "t_sub_shift",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "t_meal_time",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "t_time_sk",
                    "t_time_id",
                    "t_time",
                    "t_hour",
                    "t_minute",
                    "t_second",
                    "t_am_pm",
                    "t_shift",
                    "t_sub_shift",
                    "t_meal_time"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.7 reason

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "reason",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "r_reason_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "r_reason_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "r_reason_desc",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "r_reason_sk",
                    "r_reason_id",
                    "r_reason_desc"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.8 income_band

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "income_band",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "ib_income_band_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ib_lower_bound",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ib_upper_bound",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "ib_income_band_sk",
                    "ib_lower_bound",
                    "ib_upper_bound"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.9 item

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "item",
            "timestampSpec": {
                "column": "i_rec_start_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "i_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_item_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_rec_start_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_rec_end_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_item_desc",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "i_current_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "i_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "i_brand_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_brand",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "i_class_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "i_category_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_category",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "i_manufact_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_manufact",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_size",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_formulation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_color",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_units",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_container",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "i_manager_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "i_product_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "i_item_sk",
                    "i_item_id",
                    "i_rec_start_date",
                    "i_rec_end_date",
                    "i_item_desc",
                    "i_current_price",
                    "i_wholesale_cost",
                    "i_brand_id",
                    "i_brand",
                    "i_class_id",
                    "i_class",
                    "i_category_id",
                    "i_category",
                    "i_manufact_id",
                    "i_manufact",
                    "i_size",
                    "i_formulation",
                    "i_color",
                    "i_units",
                    "i_container",
                    "i_manager_id",
                    "i_product_name"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.10 store

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "store",
            "timestampSpec": {
                "column": "s_rec_start_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "s_store_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_store_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_rec_start_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_rec_end_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_closed_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_store_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_number_employees",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_floor_space",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_hours",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_market_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_geography_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_market_desc",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_market_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_division_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_division_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "s_company_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_company_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_street_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_street_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_street_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_suite_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_county",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_state",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_zip",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "s_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "s_gmt_offset",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "s_tax_precentage",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "s_store_sk",
                    "s_store_id",
                    "s_rec_start_date",
                    "s_rec_end_date",
                    "s_closed_date_sk",
                    "s_store_name",
                    "s_number_employees",
                    "s_floor_space",
                    "s_hours",
                    "s_manager",
                    "s_market_id",
                    "s_geography_class",
                    "s_market_desc",
                    "s_market_manager",
                    "s_division_id",
                    "s_division_name",
                    "s_company_id",
                    "s_company_name",
                    "s_street_number",
                    "s_street_name",
                    "s_street_type",
                    "s_suite_number",
                    "s_city",
                    "s_county",
                    "s_state",
                    "s_zip",
                    "s_country",
                    "s_gmt_offset",
                    "s_tax_precentage"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.11 call_center

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "call_center",
            "timestampSpec": {
                "column": "cc_rec_start_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "cc_call_center_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_call_center_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_rec_start_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_rec_end_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_closed_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_open_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_employees",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_sq_ft",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_hours",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_mkt_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_mkt_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_mkt_desc",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_market_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_division",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_division_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cc_company",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_company_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_street_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_street_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_street_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_suite_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_county",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_state",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_zip",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cc_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cc_gmt_offset",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cc_tax_percentage",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "cc_call_center_sk",
                    "cc_call_center_id",
                    "cc_rec_start_date",
                    "cc_rec_end_date",
                    "cc_closed_date_sk",
                    "cc_open_date_sk",
                    "cc_name",
                    "cc_class",
                    "cc_employees",
                    "cc_sq_ft",
                    "cc_hours",
                    "cc_manager",
                    "cc_mkt_id",
                    "cc_mkt_class",
                    "cc_mkt_desc",
                    "cc_market_manager",
                    "cc_division",
                    "cc_division_name",
                    "cc_company",
                    "cc_company_name",
                    "cc_street_number",
                    "cc_street_name",
                    "cc_street_type",
                    "cc_suite_number",
                    "cc_city",
                    "cc_county",
                    "cc_state",
                    "cc_zip",
                    "cc_country",
                    "cc_gmt_offset",
                    "cc_tax_percentage"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.12 customer

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "customer",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "c_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_customer_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_current_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_current_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_current_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_first_shipto_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_first_sales_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_salutation",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_first_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_last_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_preferred_cust_flag",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_birth_day",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_birth_month",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "c_birth_year",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_birth_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_login",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_email_address",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "c_last_review_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "c_customer_sk",
                    "c_customer_id",
                    "c_current_cdemo_sk",
                    "c_current_hdemo_sk",
                    "c_current_addr_sk",
                    "c_first_shipto_date_sk",
                    "c_first_sales_date_sk",
                    "c_salutation",
                    "c_first_name",
                    "c_last_name",
                    "c_preferred_cust_flag",
                    "c_birth_day",
                    "c_birth_month",
                    "c_birth_year",
                    "c_birth_country",
                    "c_login",
                    "c_email_address",
                    "c_last_review_date"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.13 web_site

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "web_site",
            "timestampSpec": {
                "column": "web_rec_start_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "web_site_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_site_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_rec_start_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_rec_end_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "web_open_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "web_close_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "web_mkt_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_mkt_class",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_mkt_desc",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_market_manager",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "web_company_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_company_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_street_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_street_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_street_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_suite_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_city",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_county",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_state",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_zip",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "web_country",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "web_gmt_offset",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "web_tax_percentage",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "web_site_sk",
                    "web_site_id",
                    "web_rec_start_date",
                    "web_rec_end_date",
                    "web_name",
                    "web_open_date_sk",
                    "web_close_date_sk",
                    "web_class",
                    "web_manager",
                    "web_mkt_id",
                    "web_mkt_class",
                    "web_mkt_desc",
                    "web_market_manager",
                    "web_company_id",
                    "web_company_name",
                    "web_street_number",
                    "web_street_name",
                    "web_street_type",
                    "web_suite_number",
                    "web_city",
                    "web_county",
                    "web_state",
                    "web_zip",
                    "web_country",
                    "web_gmt_offset",
                    "web_tax_percentage"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.14 store_returns

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "store_returns",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "sr_returned_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_return_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_store_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_reason_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_ticket_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "sr_return_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_return_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_return_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_return_amt_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_fee",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_return_ship_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_refunded_cash",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_reversed_charge",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_store_credit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "sr_net_loss",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "sr_returned_date_sk",
                    "sr_return_time_sk",
                    "sr_item_sk",
                    "sr_customer_sk",
                    "sr_cdemo_sk",
                    "sr_hdemo_sk",
                    "sr_addr_sk",
                    "sr_store_sk",
                    "sr_reason_sk",
                    "sr_ticket_number",
                    "sr_return_quantity",
                    "sr_return_amt",
                    "sr_return_tax",
                    "sr_return_amt_inc_tax",
                    "sr_fee",
                    "sr_return_ship_cost",
                    "sr_refunded_cash",
                    "sr_reversed_charge",
                    "sr_store_credit",
                    "sr_net_loss"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.15 household_demographics

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "household_demographics",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "hd_demo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "hd_income_band_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "hd_buy_potential",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "hd_dep_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "hd_vehicle_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "hd_demo_sk",
                    "hd_income_band_sk",
                    "hd_buy_potential",
                    "hd_dep_count",
                    "hd_vehicle_count"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.16 web_page

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "web_page",
            "timestampSpec": {
                "column": "wp_rec_start_date",
                "format": "yyyy-MM-dd",
                "missingValue": "2000-01-01"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "wp_web_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_web_page_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_rec_start_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_rec_end_date",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_creation_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_access_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_autogen_flag",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_url",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "wp_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_char_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_link_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_image_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wp_max_ad_count",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "wp_web_page_sk",
                    "wp_web_page_id",
                    "wp_rec_start_date",
                    "wp_rec_end_date",
                    "wp_creation_date_sk",
                    "wp_access_date_sk",
                    "wp_autogen_flag",
                    "wp_customer_sk",
                    "wp_url",
                    "wp_type",
                    "wp_char_count",
                    "wp_link_count",
                    "wp_image_count",
                    "wp_max_ad_count"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.17 promotion

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "promotion",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "p_promo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_promo_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_start_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_end_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "p_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "p_response_target",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_promo_name",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_dmail",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_email",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_catalog",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_tv",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_radio",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_press",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_event",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_demo",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_channel_details",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_purpose",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "p_discount_active",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "p_promo_sk",
                    "p_promo_id",
                    "p_start_date_sk",
                    "p_end_date_sk",
                    "p_item_sk",
                    "p_cost",
                    "p_response_target",
                    "p_promo_name",
                    "p_channel_dmail",
                    "p_channel_email",
                    "p_channel_catalog",
                    "p_channel_tv",
                    "p_channel_radio",
                    "p_channel_press",
                    "p_channel_event",
                    "p_channel_demo",
                    "p_channel_details",
                    "p_purpose",
                    "p_discount_active"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.18 catalog_page

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "catalog_page",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "cp_catalog_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cp_catalog_page_id",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cp_start_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cp_end_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cp_department",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cp_catalog_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cp_catalog_page_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cp_description",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "string",
                        "name": "cp_type",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "cp_catalog_page_sk",
                    "cp_catalog_page_id",
                    "cp_start_date_sk",
                    "cp_end_date_sk",
                    "cp_department",
                    "cp_catalog_number",
                    "cp_catalog_page_number",
                    "cp_description",
                    "cp_type"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.19 inventory

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "inventory",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "inv_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "inv_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "inv_warehouse_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "inv_quantity_on_hand",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "inv_date_sk",
                    "inv_item_sk",
                    "inv_warehouse_sk",
                    "inv_quantity_on_hand"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.20 catalog_returns

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "catalog_returns",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "cr_returned_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_returned_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_refunded_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_refunded_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_refunded_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_refunded_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_returning_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_returning_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_returning_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_returning_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_call_center_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_catalog_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_ship_mode_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_warehouse_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_reason_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_order_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cr_return_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_return_amount",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_return_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_return_amt_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_fee",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_return_ship_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_refunded_cash",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_reversed_charge",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_store_credit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cr_net_loss",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "cr_returned_date_sk",
                    "cr_returned_time_sk",
                    "cr_item_sk",
                    "cr_refunded_customer_sk",
                    "cr_refunded_cdemo_sk",
                    "cr_refunded_hdemo_sk",
                    "cr_refunded_addr_sk",
                    "cr_returning_customer_sk",
                    "cr_returning_cdemo_sk",
                    "cr_returning_hdemo_sk",
                    "cr_returning_addr_sk",
                    "cr_call_center_sk",
                    "cr_catalog_page_sk",
                    "cr_ship_mode_sk",
                    "cr_warehouse_sk",
                    "cr_reason_sk",
                    "cr_order_number",
                    "cr_return_quantity",
                    "cr_return_amount",
                    "cr_return_tax",
                    "cr_return_amt_inc_tax",
                    "cr_fee",
                    "cr_return_ship_cost",
                    "cr_refunded_cash",
                    "cr_reversed_charge",
                    "cr_store_credit",
                    "cr_net_loss"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.21 web_returns

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "web_returns",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "wr_returned_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_returned_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_refunded_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_refunded_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_refunded_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_refunded_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_returning_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_returning_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_returning_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_returning_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_web_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_reason_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_order_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "wr_return_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_return_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_return_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_return_amt_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_fee",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_return_ship_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_refunded_cash",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_reversed_charge",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_account_credit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "wr_net_loss",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "wr_returned_date_sk",
                    "wr_returned_time_sk",
                    "wr_item_sk",
                    "wr_refunded_customer_sk",
                    "wr_refunded_cdemo_sk",
                    "wr_refunded_hdemo_sk",
                    "wr_refunded_addr_sk",
                    "wr_returning_customer_sk",
                    "wr_returning_cdemo_sk",
                    "wr_returning_hdemo_sk",
                    "wr_returning_addr_sk",
                    "wr_web_page_sk",
                    "wr_reason_sk",
                    "wr_order_number",
                    "wr_return_quantity",
                    "wr_return_amt",
                    "wr_return_tax",
                    "wr_return_amt_inc_tax",
                    "wr_fee",
                    "wr_return_ship_cost",
                    "wr_refunded_cash",
                    "wr_reversed_charge",
                    "wr_account_credit",
                    "wr_net_loss"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.22 web_sales

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "web_sales",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "ws_sold_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_sold_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_bill_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_bill_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_bill_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_bill_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_web_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_web_site_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_ship_mode_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_warehouse_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_promo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_order_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ws_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_discount_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_coupon_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_ext_ship_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_net_paid",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_net_paid_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_net_paid_inc_ship",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_net_paid_inc_ship_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ws_net_profit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "ws_sold_date_sk",
                    "ws_sold_time_sk",
                    "ws_ship_date_sk",
                    "ws_item_sk",
                    "ws_bill_customer_sk",
                    "ws_bill_cdemo_sk",
                    "ws_bill_hdemo_sk",
                    "ws_bill_addr_sk",
                    "ws_ship_customer_sk",
                    "ws_ship_cdemo_sk",
                    "ws_ship_hdemo_sk",
                    "ws_ship_addr_sk",
                    "ws_web_page_sk",
                    "ws_web_site_sk",
                    "ws_ship_mode_sk",
                    "ws_warehouse_sk",
                    "ws_promo_sk",
                    "ws_order_number",
                    "ws_quantity",
                    "ws_wholesale_cost",
                    "ws_list_price",
                    "ws_sales_price",
                    "ws_ext_discount_amt",
                    "ws_ext_sales_price",
                    "ws_ext_wholesale_cost",
                    "ws_ext_list_price",
                    "ws_ext_tax",
                    "ws_coupon_amt",
                    "ws_ext_ship_cost",
                    "ws_net_paid",
                    "ws_net_paid_inc_tax",
                    "ws_net_paid_inc_ship",
                    "ws_net_paid_inc_ship_tax",
                    "ws_net_profit"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.23 catalog_sales

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "catalog_sales",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "cs_sold_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_sold_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_bill_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_bill_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_bill_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_bill_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_call_center_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_catalog_page_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_ship_mode_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_warehouse_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_promo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_order_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "cs_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_discount_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_coupon_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_ext_ship_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_net_paid",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_net_paid_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_net_paid_inc_ship",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_net_paid_inc_ship_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "cs_net_profit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "cs_sold_date_sk",
                    "cs_sold_time_sk",
                    "cs_ship_date_sk",
                    "cs_bill_customer_sk",
                    "cs_bill_cdemo_sk",
                    "cs_bill_hdemo_sk",
                    "cs_bill_addr_sk",
                    "cs_ship_customer_sk",
                    "cs_ship_cdemo_sk",
                    "cs_ship_hdemo_sk",
                    "cs_ship_addr_sk",
                    "cs_call_center_sk",
                    "cs_catalog_page_sk",
                    "cs_ship_mode_sk",
                    "cs_warehouse_sk",
                    "cs_item_sk",
                    "cs_promo_sk",
                    "cs_order_number",
                    "cs_quantity",
                    "cs_wholesale_cost",
                    "cs_list_price",
                    "cs_sales_price",
                    "cs_ext_discount_amt",
                    "cs_ext_sales_price",
                    "cs_ext_wholesale_cost",
                    "cs_ext_list_price",
                    "cs_ext_tax",
                    "cs_coupon_amt",
                    "cs_ext_ship_cost",
                    "cs_net_paid",
                    "cs_net_paid_inc_tax",
                    "cs_net_paid_inc_ship",
                    "cs_net_paid_inc_ship_tax",
                    "cs_net_profit"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

### 3.4.24 store_sales

```json
{
    "type": "index_parallel",
    "spec": {
        "dataSchema": {
            "dataSource": "store_sales",
            "timestampSpec": {
                "column": "!!!_no_such_column_!!!",
                "missingValue": "2010-01-01T00:00:00Z"
            },
            "dimensionsSpec": {
                "dimensions": [
                    {
                        "type": "long",
                        "name": "ss_sold_date_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_sold_time_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_item_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_customer_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_cdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_hdemo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_addr_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_store_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_promo_sk",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_ticket_number",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "long",
                        "name": "ss_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_ext_discount_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_ext_sales_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_ext_wholesale_cost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_ext_list_price",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_ext_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_coupon_amt",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_net_paid",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_net_paid_inc_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    },
                    {
                        "type": "double",
                        "name": "ss_net_profit",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": true
                    }
                ],
                "dimensionExclusions": [
                    "!!!_no_such_column_!!!"
                ]
            },
            "granularitySpec": {
                "type": "uniform",
                "segmentGranularity": "YEAR",
                "queryGranularity": "HOUR",
                "rollup": false,
                "intervals": null
            }
        },
        "ioConfig": {
            "type": "index_parallel",
            "inputSource": {
                "type": "oss",
                "uris": [
                    "oss://<TBD>"
                ]
            },
            "inputFormat": {
                "type": "tsv",
                "findColumnsFromHeader": false,
                "columns": [
                    "ss_sold_date_sk",
                    "ss_sold_time_sk",
                    "ss_item_sk",
                    "ss_customer_sk",
                    "ss_cdemo_sk",
                    "ss_hdemo_sk",
                    "ss_addr_sk",
                    "ss_store_sk",
                    "ss_promo_sk",
                    "ss_ticket_number",
                    "ss_quantity",
                    "ss_wholesale_cost",
                    "ss_list_price",
                    "ss_sales_price",
                    "ss_ext_discount_amt",
                    "ss_ext_sales_price",
                    "ss_ext_wholesale_cost",
                    "ss_ext_list_price",
                    "ss_ext_tax",
                    "ss_coupon_amt",
                    "ss_net_paid",
                    "ss_net_paid_inc_tax",
                    "ss_net_profit"
                ],
                "delimiter": "|"
            },
            "appendToExisting": false
        },
        "tuningConfig": {
            "type": "index_parallel",
            "maxRowsPerSegment": 5000000,
            "maxRowsInMemory": 25000,
            "reportParseExceptions": true,
            "maxNumConcurrentSubTasks": 8
        }
    }
}
```

# 4 测试

## 4.1 SSB单表测试

## 4.2 SSB单表高并发测试

```sql
-- Q1.1
SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder_flat
WHERE lo_orderdate >= '1993-01-01'
    AND lo_orderdate <= '1993-12-31'
    AND lo_discount BETWEEN 1 AND 3
    AND lo_quantity < 25;

-- Q1.2
SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder_flat
WHERE lo_orderdate >= '1994-01-01'
    AND lo_orderdate <= '1994-01-31'
    AND lo_discount BETWEEN 4 AND 6
    AND lo_quantity BETWEEN 26 AND 35;

-- Q1.3
SELECT SUM(lo_extendedprice * lo_discount) AS revenue
FROM lineorder_flat
WHERE lo_orderdate >= '1994-01-01'
    AND lo_orderdate <= '1994-12-31'
    AND lo_discount BETWEEN 5 AND 7
    AND lo_quantity BETWEEN 26 AND 35;

-- Q2.1
SELECT SUM(lo_revenue), lo_orderdate, p_brand
FROM lineorder_flat
WHERE p_category = 'MFGR#12'
    AND s_region = 'AMERICA'
GROUP BY lo_orderdate, p_brand
ORDER BY lo_orderdate, p_brand;

-- Q2.2
SELECT SUM(lo_revenue), lo_orderdate, p_brand
FROM lineorder_flat
WHERE p_brand >= 'MFGR#2221'
    AND p_brand <= 'MFGR#2228'
    AND s_region = 'ASIA'
GROUP BY lo_orderdate, p_brand
ORDER BY lo_orderdate, p_brand;

-- Q2.3
SELECT SUM(lo_revenue), lo_orderdate, p_brand
FROM lineorder_flat
WHERE p_brand = 'MFGR#2239'
    AND s_region = 'EUROPE'
GROUP BY lo_orderdate, p_brand
ORDER BY lo_orderdate, p_brand;

-- Q3.1
SELECT c_nation, s_nation, lo_orderdate
    , SUM(lo_revenue) AS revenue
FROM lineorder_flat
WHERE c_region = 'ASIA'
    AND s_region = 'ASIA'
    AND lo_orderdate >= '1992-01-01'
    AND lo_orderdate <= '1997-12-31'
GROUP BY c_nation, s_nation, lo_orderdate
ORDER BY lo_orderdate ASC, revenue DESC;

-- Q3.2
SELECT c_city, s_city, lo_orderdate
    , SUM(lo_revenue) AS revenue
FROM lineorder_flat
WHERE c_nation = 'UNITED STATES'
    AND s_nation = 'UNITED STATES'
    AND lo_orderdate >= '1992-01-01'
    AND lo_orderdate <= '1997-12-31'
GROUP BY c_city, s_city, lo_orderdate
ORDER BY lo_orderdate ASC, revenue DESC;

-- Q3.3
SELECT c_city, s_city, lo_orderdate
    , SUM(lo_revenue) AS revenue
FROM lineorder_flat
WHERE c_city IN ('UNITED KI1', 'UNITED KI5')
    AND s_city IN ('UNITED KI1', 'UNITED KI5')
    AND lo_orderdate >= '1992-01-01'
    AND lo_orderdate <= '1997-12-31'
GROUP BY c_city, s_city, lo_orderdate
ORDER BY lo_orderdate ASC, revenue DESC;

-- Q3.4
SELECT c_city, s_city, lo_orderdate
    , SUM(lo_revenue) AS revenue
FROM lineorder_flat
WHERE c_city IN ('UNITED KI1', 'UNITED KI5')
    AND s_city IN ('UNITED KI1', 'UNITED KI5')
    AND lo_orderdate >= '1997-12-01'
    AND lo_orderdate <= '1997-12-31'
GROUP BY c_city, s_city, lo_orderdate
ORDER BY lo_orderdate ASC, revenue DESC;

-- Q4.1
SELECT lo_orderdate, c_nation
    , SUM(lo_revenue - lo_supplycost) AS profit
FROM lineorder_flat
WHERE c_region = 'AMERICA'
    AND s_region = 'AMERICA'
    AND p_mfgr IN ('MFGR#1', 'MFGR#2')
GROUP BY lo_orderdate, c_nation
ORDER BY lo_orderdate ASC, c_nation ASC;

-- Q4.2
SELECT lo_orderdate, s_nation, p_category
    , SUM(lo_revenue - lo_supplycost) AS profit
FROM lineorder_flat
WHERE c_region = 'AMERICA'
    AND s_region = 'AMERICA'
    AND lo_orderdate >= '1997-01-01'
    AND lo_orderdate <= '1998-12-31'
    AND p_mfgr IN ('MFGR#1', 'MFGR#2')
GROUP BY lo_orderdate, s_nation, p_category
ORDER BY lo_orderdate ASC, s_nation ASC, p_category ASC;

-- Q4.3
SELECT lo_orderdate, s_city, p_brand
    , SUM(lo_revenue - lo_supplycost) AS profit
FROM lineorder_flat
WHERE s_nation = 'UNITED STATES'
    AND lo_orderdate >= '1997-01-01'
    AND lo_orderdate <= '1998-12-31'
    AND p_category = 'MFGR#14'
GROUP BY lo_orderdate, s_city, p_brand
ORDER BY lo_orderdate ASC, s_city ASC, p_brand ASC;
```

### 4.2.1 并发测试工具

**由于`Druid`不支持`mysql`协议，因此无法直接使用`mysqlslap`进行并发测试，因此自行实现了一个功能类似的脚本**

```python
import argparse
import http.client
import json
import sys
import threading
import time

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', type=str, default="127.0.0.1")
    parser.add_argument('--port', type=int, default=8888)
    parser.add_argument('--concurrency', type=int, default=1)
    parser.add_argument('--iterations', type=int, default=1)
    parser.add_argument('--number-of-queries', type=int, default=0)
    parser.add_argument('--sql_file', type=str, default='test.sql')
    shell_args = parser.parse_args()
    return shell_args

def parse_sqls(shell_args):
    queries = []
    file = open(shell_args.sql_file, 'r')
    query = ""
    for line in file.readlines():
        line = line.strip()
        if(line == ""):
            continue
        if(line.startswith("--")):
            continue
        query = query + ' ' + line
        if ';' in line:
            queries.append(query.strip(';'))
            query = ""
    return queries

class AtomicInt(object):
    def __init__(self, value=0):
        self.value = value
        self.lock = threading.Lock()

    def getAndIncrement(self):
        self.lock.acquire()
        returnValue = self.value
        self.value += 1
        self.lock.release()
        return returnValue

    def set(self, value):
        self.lock.acquire()
        self.value = value
        self.lock.release()

class CycleBarrier(object):
    def __init__(self, parties):
        self.parties = parties
        self.count = parties
        self.lock = threading.Condition()

    def await(self, callback):
        self.lock.acquire()
        self.count -= 1
        if self.count == 0:
            # auto reset self and notify all block threads
            self.count = self.parties
            self.lock.notifyAll()
            callback()
        else:
            self.lock.wait()
        self.lock.release()

class TaskThread (threading.Thread):

    def __init__(
            self,
            host,
            port,
            iterations,
            number_of_queries,
            queries,
            iterationUseTimes,
            queryCounter,
            cycleBarrier):
        threading.Thread.__init__(self)
        self.queries = queries
        self.host = host
        self.port = port
        self.iterations = iterations
        self.number_of_queries = number_of_queries
        self.iterationUseTimes = iterationUseTimes
        self.queryCounter = queryCounter
        self.cycleBarrier = cycleBarrier
        self.successCount = 0
        self.errorCount = 0

    def doRequest(self, query):
        conn = http.client.HTTPConnection(
            '{}:{}'.format(self.host, self.port))
        headers = {"Content-Type": "application/json",
                   "Accept": "application/json"}
        body = {"query": query}
        conn.request("POST", "/druid/v2/sql",
                     json.dumps(body), headers)
        response = conn.getresponse()
        return response

    def run(self):
        for _ in range(self.iterations):
            start = time.time()

            if self.number_of_queries > 0:
                # if --number-of-queries is set, all the threads of one iteration should run as many as
                # shell_args.number_of_queries
                numQueriesOfSqlFile = len(self.queries)
                num = self.queryCounter.getAndIncrement()
                while num < self.number_of_queries:
                    queryIdx = num % numQueriesOfSqlFile
                    query = self.queries[queryIdx]

                    response = self.doRequest(query)

                    if(response.status == 200):
                        self.successCount += 1
                    else:
                        self.errorCount += 1

                    num = self.queryCounter.getAndIncrement()
            else:
                # otherwise, each thread of one iteration should run all the
                # sqls of the shell_args.sql_file
                for query in self.queries:
                    response = self.doRequest(query)

                    if(response.status == 200):
                        self.successCount += 1
                    else:
                        self.errorCount += 1

            # wait for other threads with same iteration batch to be finished
            iterationUseTime = time.time() - start

            def callback():
                self.queryCounter.set(0)
                self.iterationUseTimes.append(iterationUseTime)
            self.cycleBarrier.await(callback)

def main():
    start = time.time()

    shell_args = parse_args()
    queries = parse_sqls(shell_args)

    print("Warmup start...")
    warmStart = time.time()
    warmupTask = TaskThread(
        shell_args.host,
        shell_args.port,
        1,
        len(queries),
        queries,
        [],
        AtomicInt(0),
        CycleBarrier(1))
    warmupTask.start()
    warmupTask.join()
    warmEnd = time.time()
    print("Warmup end")

    print("Benchmark start...")
    tasks = []
    iterationUseTimes = []
    queryCounter = AtomicInt(0)
    cycleBarrier = CycleBarrier(shell_args.concurrency)
    for i in range(shell_args.concurrency):
        task = TaskThread(
            shell_args.host,
            shell_args.port,
            shell_args.iterations,
            shell_args.number_of_queries,
            queries,
            iterationUseTimes,
            queryCounter,
            cycleBarrier)
        task.start()
        tasks.append(task)

    overallSuccessCount = 0
    overallErrorCount = 0
    for task in tasks:
        task.join()
        overallSuccessCount += task.successCount
        overallErrorCount += task.errorCount

    totalUseTime = 0
    totalUseTime += sum(iterationUseTimes)
    overallMinUseTime = min(iterationUseTimes)
    overallMaxUseTime = max(iterationUseTimes)
    print("Benchmark end")

    end = time.time()

    overallAvgUseTime = totalUseTime / max(1, shell_args.iterations)
    print("Benchmark statistics")
    print(
        "\tOverall time: {}s, warmup time: {}s, success queries: {}, failure queries: {}".format(
            format(
                end -
                start,
                '.3f'),
            format(
                warmEnd -
                warmStart,
                '.3f'),
            overallSuccessCount,
            overallErrorCount))
    print("\tAverage number of seconds to run all queries: {}s".format(
        format(overallAvgUseTime, '.3f')))
    print("\tMinimum number of seconds to run all queries: {}s".format(
        format(overallMinUseTime, '.3f')))
    print("\tMaximum number of seconds to run all queries: {}s".format(
        format(overallMaxUseTime, '.3f')))
    print(
        "\tNumber of clients running queries: {}".format(
            shell_args.concurrency))
    print(
        "\tAverage number of queries per client: {}".format(
            format(
                (overallSuccessCount +
                 overallErrorCount) /
                shell_args.concurrency,
                '.2f')))

if __name__ == "__main__":
    main()
```

**参数：**

* `--host`
* `--port`
* `--concurrency`：并发数量
* `--number-of-queries`：每个线程每轮执行多少个`sql`
* `--iterations`：总共进行几轮测试
    * 当未设置`--number-of-queries`参数时，每个线程执行完`--sql_file`中的所有`sql`就算一轮
    * 当设置了`--number-of-queries`参数时，所有线程总共执行完该参数指定的线程时，才算一轮
* `--sql_file`：测试文件的路径

**用法：**

* `python3 druidslap.py --host=127.0.0.1 --port=8888 --concurrency=16 --iterations=10 --sql_file=test.sql`
* `python3 druidslap.py --host=127.0.0.1 --port=8888 --concurrency=16 --number-of-queries=1000 --sql_file=test.sql`

# 5 使用体验

1. 提供quick-start模式，能够快速体验
1. 集群部署不友好，[Clustered deployment](https://druid.apache.org/docs/latest/tutorials/cluster.html)没有说明哪些配置项是必须修改的，比如`druid.host`、`druid.zk.service.host`这俩配置项
1. 控制台的查询能力弱，主要体现在：
    * `;`是非法字符
    * `` ` ``是非法字符
    * 不支持执行多个sql
    * 不支持执行光标选中的部分
1. 不支持`database`对数据表进行隔离，比如我要同时使用`SSB`以及`TPC-H`进行测试，而这两个测试集中包含同名的数据表
1. 导入数据后，总有一些`segment`会是`unavailable`状态，也不知道如何修复
1. 性能方面
    * 宽表性能不错
    * 多表性能比较差
