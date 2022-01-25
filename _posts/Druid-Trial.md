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

**组件构成：**

* **`master`：负责协调集群**
    * `coordinator`
    * `overload`
    * `zookeeper`
* **`data-server`：包括数据存储、计算等功能**
    * `historical`
    * `middle_manager`
    * `zookeeper`
* **`query-server`：包括控制台，数据导入等功能功能**
    * `broker`
    * `router`
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

## 2.2 配置文件

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

## 3.1 SSB

### 3.1.1 customer

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

### 3.1.2 dates

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

### 3.1.3 lineorder

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
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_linenumber",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_custkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_partkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_suppkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_orderdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
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
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_extendedprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_ordtotalprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_discount",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_revenue",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_supplycost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "string",
                        "name": "lo_commitdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
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

### 3.1.4 part

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

### 3.1.5 supplier

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

### 3.1.6 lineorder_flat

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
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_orderkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_linenumber",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_custkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_partkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_suppkey",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
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
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_quantity",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_extendedprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_ordtotalprice",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_discount",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_revenue",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_supplycost",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "long",
                        "name": "lo_tax",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
                    },
                    {
                        "type": "string",
                        "name": "lo_commitdate",
                        "multiValueHandling": "SORTED_ARRAY",
                        "createBitmapIndex": false
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
                        "createBitmapIndex": false
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

## 3.2 TPC-H

## 3.3 TPC-DS

