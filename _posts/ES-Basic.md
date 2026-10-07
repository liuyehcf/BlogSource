---
title: ES-Basic
date: 2026-07-06 13:55:06
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Elasticsearch + Kibana Full-Text Search Tutorial

This tutorial covers the following tasks:

1. Start a three-node Elasticsearch 8.18.0 cluster and Kibana with Docker Compose.
2. Download and normalize any dataset supported by `ir_datasets`.
3. Import the normalized documents with Python.
4. Create indices, inspect the cluster, and run full-text queries with either curl or Kibana Dev Tools.

The tutorial keeps configuration, runtime files, datasets, and scripts under one root directory:

```text
tutorial/
├── .env
├── docker-compose.yml
├── runtime/
│   ├── es01/{data,logs,tmp}/
│   ├── es02/{data,logs,tmp}/
│   ├── es03/{data,logs,tmp}/
│   └── kibana/{data,logs,tmp}/
└── dataset/
    ├── .venv/
    ├── .ir_datasets/
    ├── data/
    │   ├── docs.jsonl
    │   ├── queries.jsonl
    │   ├── qrels.tsv
    │   └── metadata.json
    ├── download_dataset.py
    └── load_es.py
```

All paths in this document are relative. Run each shell block from the parent directory that contains `tutorial/`. If your shell is already inside `tutorial/`, omit the leading `tutorial/` component where appropriate.

> Every Elasticsearch API section uses one combined code block. The `# curl` and `# Kibana Dev Tools` comments identify the two equivalent forms. Docker, shell, and Python operations are not Elasticsearch API requests, so they are shown only as terminal commands.

## 1.1 1. Start Elasticsearch and Kibana

### 1.1.1 Create the directories

```bash
mkdir -p tutorial/{runtime,dataset}

mkdir -p \
  tutorial/runtime/es01/{data,logs,tmp} \
  tutorial/runtime/es02/{data,logs,tmp} \
  tutorial/runtime/es03/{data,logs,tmp} \
  tutorial/runtime/kibana/{data,logs,tmp}

chmod 0777 \
  tutorial/runtime/es01/{data,logs,tmp} \
  tutorial/runtime/es02/{data,logs,tmp} \
  tutorial/runtime/es03/{data,logs,tmp} \
  tutorial/runtime/kibana/{data,logs,tmp}
```

Mode `0777` is used only for this local test environment to avoid host/container UID mismatches. For a long-running environment, change ownership to the container user and tighten the permissions.

### 1.1.2 Create `.env`

Create `tutorial/.env`:

```dotenv
ES_VERSION=8.18.0
ES_HEAP=8g
```

### 1.1.3 Create `docker-compose.yml`

Create `tutorial/docker-compose.yml`:

```yaml
services:
  es01:
    image: docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
    container_name: es01
    environment:
      - node.name=es01
      - cluster.name=search-bench
      - discovery.seed_hosts=es01,es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - node.roles=master,data,ingest
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms${ES_HEAP} -Xmx${ES_HEAP}
      - ES_TMPDIR=/usr/share/elasticsearch/tmp
    ulimits:
      memlock: {soft: -1, hard: -1}
      nofile: {soft: 65535, hard: 65535}
    volumes:
      - ./runtime/es01/data:/usr/share/elasticsearch/data
      - ./runtime/es01/logs:/usr/share/elasticsearch/logs
      - ./runtime/es01/tmp:/usr/share/elasticsearch/tmp
    ports:
      - "9200:9200"

  es02:
    image: docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
    container_name: es02
    environment:
      - node.name=es02
      - cluster.name=search-bench
      - discovery.seed_hosts=es01,es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - node.roles=master,data,ingest
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms${ES_HEAP} -Xmx${ES_HEAP}
      - ES_TMPDIR=/usr/share/elasticsearch/tmp
    ulimits:
      memlock: {soft: -1, hard: -1}
      nofile: {soft: 65535, hard: 65535}
    volumes:
      - ./runtime/es02/data:/usr/share/elasticsearch/data
      - ./runtime/es02/logs:/usr/share/elasticsearch/logs
      - ./runtime/es02/tmp:/usr/share/elasticsearch/tmp

  es03:
    image: docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}
    container_name: es03
    environment:
      - node.name=es03
      - cluster.name=search-bench
      - discovery.seed_hosts=es01,es02,es03
      - cluster.initial_master_nodes=es01,es02,es03
      - node.roles=master,data,ingest
      - bootstrap.memory_lock=true
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms${ES_HEAP} -Xmx${ES_HEAP}
      - ES_TMPDIR=/usr/share/elasticsearch/tmp
    ulimits:
      memlock: {soft: -1, hard: -1}
      nofile: {soft: 65535, hard: 65535}
    volumes:
      - ./runtime/es03/data:/usr/share/elasticsearch/data
      - ./runtime/es03/logs:/usr/share/elasticsearch/logs
      - ./runtime/es03/tmp:/usr/share/elasticsearch/tmp

  kibana:
    image: docker.elastic.co/kibana/kibana:${ES_VERSION}
    container_name: kibana
    depends_on:
      - es01
      - es02
      - es03
    environment:
      - SERVER_NAME=kibana
      - SERVER_HOST=0.0.0.0
      - ELASTICSEARCH_HOSTS=http://es01:9200
      - XPACK_SECURITY_ENABLED=false
      - NODE_OPTIONS=--max-old-space-size=2048
      - TMPDIR=/usr/share/kibana/tmp
    volumes:
      - ./runtime/kibana/data:/usr/share/kibana/data
      - ./runtime/kibana/logs:/usr/share/kibana/logs
      - ./runtime/kibana/tmp:/usr/share/kibana/tmp
    ports:
      - "5601:5601"
```

The `es01/data`, `es02/data`, and `es03/data` directories must be different. Multiple Elasticsearch nodes must never share the same data directory.

This configuration disables authentication and exposes ports 9200 and 5601 on all host interfaces. Use it only on a trusted test network. For local-only access, bind the ports to loopback:

```yaml
ports:
  - "127.0.0.1:9200:9200"
```

For Kibana:

```yaml
ports:
  - "127.0.0.1:5601:5601"
```

### 1.1.4 Start the services

```bash
sudo sysctl -w vm.max_map_count=1048576

cd tutorial
docker compose config --quiet
docker compose up -d
docker compose ps
```

Service endpoints:

```text
Elasticsearch: http://127.0.0.1:9200
Kibana:        http://127.0.0.1:5601
```

For remote access, replace `127.0.0.1` with the server IP address.

### 1.1.5 Check cluster health

Open Kibana and go to `Dev Tools → Console` to run the Dev Tools form.

```text
# curl
curl 'http://127.0.0.1:9200/_cluster/health?pretty'

curl 'http://127.0.0.1:9200/_cat/nodes?v'

# Kibana Dev Tools
GET /_cluster/health

GET /_cat/nodes?v
```

The final three-node state should contain:

```text
status: green
number_of_nodes: 3
number_of_data_nodes: 3
```

## 1.2 2. Download and Normalize a Dataset

### 1.2.1 Create a Python environment

```bash
cd tutorial/dataset

python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install ir_datasets
```

### 1.2.2 Create the generic download script

Do not name the script `ir_datasets.py`. A script with that name shadows the installed package and causes a circular import.

Save the script as:

```text
tutorial/dataset/download_dataset.py
```

```python
import json
import os
import zlib
from pathlib import Path

# Change only this value to download another dataset.
DATASET_ID = "msmarco-passage/dev/small"

base_dir = Path(__file__).resolve().parent
output_dir = base_dir / "data"
output_dir.mkdir(parents=True, exist_ok=True)

# Keep source downloads and generated files below this directory.
os.environ.setdefault("IR_DATASETS_HOME", str(base_dir / ".ir_datasets"))

import ir_datasets

dataset = ir_datasets.load(DATASET_ID)

def to_dict(item):
    if hasattr(item, "_asdict"):
        return dict(item._asdict())
    raise TypeError(f"Unsupported record type: {type(item)!r}")

def document_content(record):
    parts = []

    for field in ("title", "text"):
        value = record.get(field)
        if value:
            parts.append(str(value).strip())

    # Fallback for datasets whose document schema does not expose title/text.
    if not parts:
        for field, value in record.items():
            if field != "doc_id" and isinstance(value, str) and value:
                parts.append(value.strip())

    return "\n\n".join(part for part in parts if part)

def export_documents():
    count = 0
    output_file = output_dir / "docs.jsonl"

    with output_file.open("w", encoding="utf-8") as output:
        if not dataset.has_docs():
            return 0

        for doc in dataset.docs_iter():
            record = to_dict(doc)
            doc_id = str(record["doc_id"])

            normalized = {
                "id": doc_id,
                "tenant_id": zlib.crc32(doc_id.encode()) % 1000,
                "content": document_content(record),
            }

            output.write(
                json.dumps(normalized, ensure_ascii=False) + "\n"
            )
            count += 1

            if count % 100000 == 0:
                print(f"documents: {count}", flush=True)

    return count

def export_queries():
    count = 0
    output_file = output_dir / "queries.jsonl"

    with output_file.open("w", encoding="utf-8") as output:
        if not dataset.has_queries():
            return 0

        for query in dataset.queries_iter():
            record = to_dict(query)
            query_text = (
                record.get("text")
                or record.get("query")
                or record.get("narrative")
                or ""
            )

            normalized = {
                "query_id": str(record["query_id"]),
                "text": str(query_text),
            }

            output.write(
                json.dumps(normalized, ensure_ascii=False) + "\n"
            )
            count += 1

    return count

def export_qrels():
    count = 0
    output_file = output_dir / "qrels.tsv"

    with output_file.open("w", encoding="utf-8") as output:
        if not dataset.has_qrels():
            return 0

        for qrel in dataset.qrels_iter():
            record = to_dict(qrel)
            iteration = record.get("iteration", "0")

            output.write(
                f"{record['query_id']}\t{record['doc_id']}\t"
                f"{record['relevance']}\t{iteration}\n"
            )
            count += 1

    return count

document_count = export_documents()
query_count = export_queries()
qrel_count = export_qrels()

metadata = {
    "dataset_id": DATASET_ID,
    "documents": document_count,
    "queries": query_count,
    "qrels": qrel_count,
}

with (output_dir / "metadata.json").open("w", encoding="utf-8") as output:
    json.dump(metadata, output, ensure_ascii=False, indent=2)
    output.write("\n")

print(json.dumps(metadata, ensure_ascii=False, indent=2))
```

### 1.2.3 Run the download

Select the dataset by changing one line in `download_dataset.py`:

```python
DATASET_ID = "msmarco-passage/dev/small"
```

Then run:

```bash
cd tutorial/dataset
.venv/bin/python download_dataset.py
```

The script always writes the same normalized output layout:

```text
.ir_datasets/       # ir_datasets source download cache
data/docs.jsonl     # Normalized id, tenant_id, and content
data/queries.jsonl  # Normalized query_id and text
data/qrels.tsv      # query_id, doc_id, relevance, iteration
data/metadata.json  # Selected dataset ID and exported counts
```

Verify the output:

```bash
wc -l \
  data/docs.jsonl \
  data/queries.jsonl \
  data/qrels.tsv

head -n 2 data/docs.jsonl
cat data/metadata.json
```

For the default MS MARCO Passage v1 dataset, the expected counts are 8,841,823 documents, 6,980 queries, and 7,437 qrels. Other datasets produce different counts; use `metadata.json` as the reference.

The generated document `id` is always a string because several datasets use non-numeric IDs. The index therefore maps `id` as `keyword` rather than `long`.

Some datasets display a usage agreement notice on the first download. If an official endpoint times out, rerun the same script; `ir_datasets` reuses its local cache and attempts a range download when possible.

## 1.3 3. Create the Full-Text Index

The index uses:

- Three primary shards.
- No replicas during the initial load.
- No automatic refresh during the initial load.
- The `standard` analyzer for `content`.
- Positions for phrase queries.
- BM25 with `k1=1.2` and `b=0.75`.

### 1.3.1 Create the index

```text
# curl
curl --fail-with-body \
  -X PUT \
  'http://127.0.0.1:9200/docs_bench' \
  -H 'Content-Type: application/json' \
  -d '{
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 0,
      "refresh_interval": "-1",
      "similarity": {
        "tutorial_bm25": {
          "type": "BM25",
          "k1": 1.2,
          "b": 0.75
        }
      }
    },
    "mappings": {
      "properties": {
        "id": {"type": "keyword"},
        "tenant_id": {"type": "integer"},
        "content": {
          "type": "text",
          "analyzer": "standard",
          "index_options": "positions",
          "norms": true,
          "similarity": "tutorial_bm25"
        }
      }
    }
  }'

# Kibana Dev Tools
PUT /docs_bench
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 0,
    "refresh_interval": "-1",
    "similarity": {
      "tutorial_bm25": {
        "type": "BM25",
        "k1": 1.2,
        "b": 0.75
      }
    }
  },
  "mappings": {
    "properties": {
      "id": {"type": "keyword"},
      "tenant_id": {"type": "integer"},
      "content": {
        "type": "text",
        "analyzer": "standard",
        "index_options": "positions",
        "norms": true,
        "similarity": "tutorial_bm25"
      }
    }
  }
}
```

Expected response:

```json
{
  "acknowledged": true,
  "shards_acknowledged": true,
  "index": "docs_bench"
}
```

## 1.4 4. Import the Dataset with Python

### 1.4.1 Install the Elasticsearch client

```bash
cd tutorial/dataset
.venv/bin/pip install 'elasticsearch==8.18.0'
```

### 1.4.2 Create the importer

Save the script as:

```text
tutorial/dataset/load_es.py
```

```python
import json
import time
from pathlib import Path

from elasticsearch import Elasticsearch, helpers

base_dir = Path(__file__).resolve().parent
data_file = base_dir / "data" / "docs.jsonl"
index_name = "docs_bench"

es = Elasticsearch(
    "http://127.0.0.1:9200",
    request_timeout=120,
    retry_on_timeout=True,
    max_retries=5,
)

if not es.ping():
    raise RuntimeError("Elasticsearch is not reachable")

def actions():
    with data_file.open("r", encoding="utf-8") as source:
        for line in source:
            doc = json.loads(line)
            yield {
                "_index": index_name,
                "_id": str(doc["id"]),
                "_source": doc,
            }

started_at = time.monotonic()
processed = 0
success = 0
failed = 0

for ok, result in helpers.parallel_bulk(
    es,
    actions(),
    thread_count=4,
    queue_size=8,
    chunk_size=2000,
    max_chunk_bytes=10 * 1024 * 1024,
    request_timeout=120,
    raise_on_error=False,
    raise_on_exception=False,
):
    processed += 1
    if ok:
        success += 1
    else:
        failed += 1
        if failed <= 10:
            print("failed:", result)

    if processed % 100000 == 0:
        elapsed = time.monotonic() - started_at
        print(
            f"processed={processed}, success={success}, failed={failed}, "
            f"docs_per_second={processed / elapsed:.1f}",
            flush=True,
        )

elapsed = time.monotonic() - started_at
rate = processed / elapsed if elapsed else 0

print(
    f"finished: processed={processed}, success={success}, "
    f"failed={failed}, seconds={elapsed:.1f}, "
    f"docs_per_second={rate:.1f}"
)

if failed:
    raise SystemExit(1)
```

Run the importer:

```bash
cd tutorial/dataset
.venv/bin/python load_es.py
```

Default batching parameters:

```text
thread_count=4       # Four sender threads
chunk_size=2000      # At most 2,000 documents per chunk
max_chunk_bytes=10MB # At most 10 MiB per chunk
```

The script prints progress every 100,000 documents. It uses the source `id` as the Elasticsearch `_id`, so rerunning the importer overwrites existing documents instead of creating duplicates.

### 1.4.3 Equivalent `_bulk` API example

Use the Python script for the complete dataset. The following request demonstrates the `_bulk` API used underneath with only two documents.

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/_bulk?refresh=false' \
  -H 'Content-Type: application/x-ndjson' \
  --data-binary $'{"index":{"_index":"docs_bench","_id":"1"}}\n{"id":1,"tenant_id":100,"content":"full text search engine"}\n{"index":{"_index":"docs_bench","_id":"2"}}\n{"id":2,"tenant_id":100,"content":"database engine"}\n'

# Kibana Dev Tools
POST /_bulk?refresh=false
{"index":{"_index":"docs_bench","_id":"1"}}
{"id":1,"tenant_id":100,"content":"full text search engine"}
{"index":{"_index":"docs_bench","_id":"2"}}
{"id":2,"tenant_id":100,"content":"database engine"}
```

Bulk NDJSON must end with a newline.

## 1.5 5. Finalize the Import

### 1.5.1 Restore the refresh interval

```text
# curl
curl --fail-with-body \
  -X PUT \
  'http://127.0.0.1:9200/docs_bench/_settings' \
  -H 'Content-Type: application/json' \
  -d '{
    "index": {
      "refresh_interval": "1s",
      "number_of_replicas": 0
    }
  }'

# Kibana Dev Tools
PUT /docs_bench/_settings
{
  "index": {
    "refresh_interval": "1s",
    "number_of_replicas": 0
  }
}
```

### 1.5.2 Refresh the index

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_refresh'

# Kibana Dev Tools
POST /docs_bench/_refresh
```

### 1.5.3 Check the document count

```text
# curl
curl 'http://127.0.0.1:9200/docs_bench/_count?pretty'

# Kibana Dev Tools
GET /docs_bench/_count
```

The count should match the `documents` value in `dataset/data/metadata.json`. With the default MS MARCO Passage v1 selection, it should be:

```text
8,841,823
```

Section 4.3 is only an API example. With the default MS MARCO dataset, its document IDs `1` and `2` are overwritten by the full import. For a dataset that does not contain those IDs, do not run the example against the final benchmark index, otherwise the index count will include two extra documents.

### 1.5.4 Inspect the index and shards

```text
# curl
curl 'http://127.0.0.1:9200/_cat/indices/docs_bench?v'

curl 'http://127.0.0.1:9200/_cat/shards/docs_bench?v'

# Kibana Dev Tools
GET /_cat/indices/docs_bench?v

GET /_cat/shards/docs_bench?v
```

## 1.6 6. Query the Dataset

### 1.6.1 Inspect analyzer output

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_analyze' \
  -H 'Content-Type: application/json' \
  -d '{
    "analyzer": "standard",
    "text": "Full-text search engine"
  }'

# Kibana Dev Tools
POST /docs_bench/_analyze
{
  "analyzer": "standard",
  "text": "Full-text search engine"
}
```

### 1.6.2 Single-term BM25 Top-10

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_search?request_cache=false' \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 10,
    "track_total_hits": false,
    "_source": false,
    "docvalue_fields": ["id"],
    "query": {
      "match": {
        "content": "engine"
      }
    },
    "sort": [
      {"_score": "desc"},
      {"id": "asc"}
    ]
  }'

# Kibana Dev Tools
POST /docs_bench/_search?request_cache=false
{
  "size": 10,
  "track_total_hits": false,
  "_source": false,
  "docvalue_fields": ["id"],
  "query": {
    "match": {
      "content": "engine"
    }
  },
  "sort": [
    {"_score": "desc"},
    {"id": "asc"}
  ]
}
```

### 1.6.3 Tenant filter + BM25 Top-10

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_search?request_cache=false' \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 10,
    "track_total_hits": false,
    "_source": false,
    "docvalue_fields": ["id"],
    "query": {
      "bool": {
        "filter": [
          {"term": {"tenant_id": 100}}
        ],
        "must": [
          {"match": {"content": "engine"}}
        ]
      }
    },
    "sort": [
      {"_score": "desc"},
      {"id": "asc"}
    ]
  }'

# Kibana Dev Tools
POST /docs_bench/_search?request_cache=false
{
  "size": 10,
  "track_total_hits": false,
  "_source": false,
  "docvalue_fields": ["id"],
  "query": {
    "bool": {
      "filter": [
        {"term": {"tenant_id": 100}}
      ],
      "must": [
        {"match": {"content": "engine"}}
      ]
    }
  },
  "sort": [
    {"_score": "desc"},
    {"id": "asc"}
  ]
}
```

### 1.6.4 Phrase Top-10

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_search?request_cache=false' \
  -H 'Content-Type: application/json' \
  -d '{
    "size": 10,
    "track_total_hits": false,
    "_source": false,
    "docvalue_fields": ["id"],
    "query": {
      "match_phrase": {
        "content": "full text"
      }
    },
    "sort": [
      {"_score": "desc"},
      {"id": "asc"}
    ]
  }'

# Kibana Dev Tools
POST /docs_bench/_search?request_cache=false
{
  "size": 10,
  "track_total_hits": false,
  "_source": false,
  "docvalue_fields": ["id"],
  "query": {
    "match_phrase": {
      "content": "full text"
    }
  },
  "sort": [
    {"_score": "desc"},
    {"id": "asc"}
  ]
}
```

## 1.7 7. Inspect BM25 Score Details

Replace `<DOCUMENT_ID>` with an `_id` returned by a search request.

### 1.7.1 `_explain`

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_explain/<DOCUMENT_ID>' \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "content": "engine"
      }
    }
  }'

# Kibana Dev Tools
POST /docs_bench/_explain/<DOCUMENT_ID>
{
  "query": {
    "match": {
      "content": "engine"
    }
  }
}
```

The response includes term frequency, document frequency, document length, average field length, IDF, and the final score.

### 1.7.2 Term vectors

```text
# curl
curl --fail-with-body \
  -X POST \
  'http://127.0.0.1:9200/docs_bench/_termvectors/<DOCUMENT_ID>' \
  -H 'Content-Type: application/json' \
  -d '{
    "fields": ["content"],
    "term_statistics": true,
    "field_statistics": true,
    "positions": true
  }'

# Kibana Dev Tools
POST /docs_bench/_termvectors/<DOCUMENT_ID>
{
  "fields": ["content"],
  "term_statistics": true,
  "field_statistics": true,
  "positions": true
}
```

## 1.8 8. Service Operations

### 1.8.1 View logs

```bash
cd tutorial

docker compose logs --tail=100 es01
docker compose logs --tail=100 kibana
```

### 1.8.2 Stop and start Kibana

Stop Kibana when the UI is not needed:

```bash
docker compose stop kibana
```

Start it again:

```bash
docker compose up -d kibana
```

### 1.8.3 Stop and start the cluster

```bash
docker compose stop
docker compose up -d
```

`docker compose down` removes containers and the Compose network, but it does not remove data bind-mounted under `tutorial/runtime`. Always verify the exact target before deleting any data directory.

## 1.9 9. Troubleshooting

### 1.9.1 `ir_datasets` has no attribute `load`

Do not name the script `ir_datasets.py`. A script with that name shadows the installed package and typically causes:

```text
AttributeError: partially initialized module 'ir_datasets'
has no attribute 'load'
```

### 1.9.2 The Elasticsearch cluster is yellow

Kibana creates system indices during its first startup. Shards can briefly remain in the initializing state. Wait for green status:

```text
# curl
curl 'http://127.0.0.1:9200/_cluster/health?wait_for_status=green&timeout=30s&pretty'

# Kibana Dev Tools
GET /_cluster/health?wait_for_status=green&timeout=30s
```

### 1.9.3 The importer was interrupted

Run `load_es.py` again. The importer uses stable `_id` values, so it overwrites existing documents instead of creating duplicates. Verify the final total with `_count`.

### 1.9.4 Kibana is unavailable

```bash
cd tutorial
docker compose ps
docker compose logs --tail=200 kibana
curl 'http://127.0.0.1:5601/api/status'
```

When Kibana is ready, `status.overall.level` is `available`.

# 2 Common Full-Text Search Datasets

Full-text datasets generally serve two different purposes:

- **Relevance evaluation:** includes documents, queries, and qrels for metrics such as NDCG, MRR, and Recall.
- **Performance evaluation:** emphasizes corpus size, indexing throughput, query latency, and QPS.

## 2.1 Recommended Datasets

| Dataset | Documents | Queries | Best Use |
|---|---:|---:|---|
| MS MARCO Passage v1 | 8,841,823 | 6,980 | Recommended first full benchmark |
| TREC DL 2019 | Same MS MARCO corpus | 43 judged | High-quality ranking evaluation |
| TREC DL 2020 | Same MS MARCO corpus | 54 judged | High-quality ranking evaluation |
| BEIR TREC-COVID | 171,332 | 50 | Medical text, phrase, and Recall tests |
| BEIR NFCorpus | 3,633 | 323 | Fast functional smoke test |
| BEIR FiQA | 57,638 | 648 | Medium-sized financial retrieval |
| BEIR SciFact | 5,183 | 300 | Fast relevance smoke test |
| BEIR Natural Questions | 2,681,468 | 3,452 | Medium-to-large retrieval test |
| MS MARCO Passage v2 | 138,364,198 | Varies | Large-scale stress test |
| Wikipedia Dump | Millions of pages | No qrels | Long-text capacity and indexing throughput |

## 2.2 Download with `ir_datasets`

Install once:

```bash
python3 -m venv .venv
.venv/bin/python -m pip install --upgrade pip
.venv/bin/python -m pip install ir_datasets
```

The generic `download_dataset.py` script in this tutorial downloads and normalizes any dataset listed below. Change only its `DATASET_ID` value:

```python
DATASET_ID = "msmarco-passage/dev/small"
```

Available identifiers include the following. Keep exactly one `DATASET_ID` assignment in the script:

```python
# MS MARCO Passage v1
DATASET_ID = "msmarco-passage/dev/small"

# TREC Deep Learning
DATASET_ID = "msmarco-passage/trec-dl-2019/judged"
DATASET_ID = "msmarco-passage/trec-dl-2020/judged"

# BEIR
DATASET_ID = "beir/trec-covid"
DATASET_ID = "beir/nfcorpus/test"
DATASET_ID = "beir/fiqa/test"
DATASET_ID = "beir/scifact/test"
DATASET_ID = "beir/nq"

# MS MARCO Passage v2
DATASET_ID = "msmarco-passage-v2/dev1"
```

After selecting an identifier, run the same command every time:

```bash
cd tutorial/dataset
.venv/bin/python download_dataset.py
```

The script overwrites `data/docs.jsonl`, `data/queries.jsonl`, `data/qrels.tsv`, and `data/metadata.json` with the selected dataset. Move or rename `data/` first if previous output must be retained.

Iterating `docs_iter()`, `queries_iter()`, or `qrels_iter()` triggers the download. `ir_datasets` reuses its local cache, so TREC DL does not download the MS MARCO corpus again when it is already present.

## 2.3 Wikipedia Download

Wikipedia is useful for scale testing but does not include standard queries or relevance judgments.

```bash
mkdir -p tutorial/dataset/wikipedia
cd tutorial/dataset/wikipedia

# Get available versions in the blow two links.
# https://dumps.wikimedia.org/enwiki
# https://dumps.wikimedia.org/zhwiki
VERSION=20260901

# English Wikipedia
curl -L --fail \
    --retry 100 \
    --retry-all-errors \
    --retry-delay 5 \
    --speed-limit 1024 \
    --speed-time 60 \
    -C - \
    -o enwiki-${VERSION}-pages-articles-multistream.xml.bz2 \
    "https://dumps.wikimedia.org/enwiki/${VERSION}/enwiki-${VERSION}-pages-articles-multistream.xml.bz2"

# Chinese Wikipedia
curl -L --fail \
    --retry 100 \
    --retry-all-errors \
    --retry-delay 5 \
    --speed-limit 1024 \
    --speed-time 60 \
    -C - \
    -o zhwiki-${VERSION}-pages-articles-multistream.xml.bz2 \
    "https://dumps.wikimedia.org/zhwiki/${VERSION}/zhwiki-${VERSION}-pages-articles-multistream.xml.bz2"

# Extract both
source ~/.venv/bin/activate
pip install wikiextractor

~/.venv/bin/wikiextractor --json \
    --processes 8 \
    --output enwiki-${VERSION}-pages-articles-multistream-extracted \
    enwiki-${VERSION}-pages-articles-multistream.xml.bz2

~/.venv/bin/wikiextractor --json \
    --processes 8 \
    --output zhwiki-${VERSION}-pages-articles-multistream-extracted \
    zhwiki-${VERSION}-pages-articles-multistream.xml.bz2

# View
head -n 1 enwiki-${VERSION}-pages-articles-multistream-extracted/AA/wiki_00 | jq
head -n 1 zhwiki-${VERSION}-pages-articles-multistream-extracted/AA/wiki_00 | jq
```

Wikipedia dumps are MediaWiki XML and must be converted to plain text or JSONL before indexing.

### 2.3.1 Create the index

```text
# curl
curl --fail-with-body \
  -X PUT \
  'http://127.0.0.1:9200/zhwiki_20260901' \
  -H 'Content-Type: application/json' \
  -d '{
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 0,
      "refresh_interval": "-1",
      "similarity": {
        "tutorial_bm25": {
          "type": "BM25",
          "k1": 1.2,
          "b": 0.75
        }
      }
    },
    "mappings": {
      "properties": {
        "id": {
          "type": "keyword"
        },
        "revid": {
          "type": "keyword"
        },
        "url": {
          "type": "keyword",
          "index": false,
          "doc_values": false
        },
        "title": {
          "type": "text",
          "analyzer": "standard",
          "index_options": "positions",
          "norms": true,
          "similarity": "tutorial_bm25",
          "fields": {
            "raw": {
              "type": "keyword",
              "ignore_above": 512
            }
          }
        },
        "text": {
          "type": "text",
          "analyzer": "standard",
          "index_options": "positions",
          "norms": true,
          "similarity": "tutorial_bm25"
        }
      }
    }
  }'

# Kibana Dev Tools
PUT /zhwiki_20260901
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 0,
    "refresh_interval": "-1",
    "similarity": {
      "tutorial_bm25": {
        "type": "BM25",
        "k1": 1.2,
        "b": 0.75
      }
    }
  },
  "mappings": {
    "properties": {
      "id": {
        "type": "keyword"
      },
      "revid": {
        "type": "keyword"
      },
      "url": {
        "type": "keyword",
        "index": false,
        "doc_values": false
      },
      "title": {
        "type": "text",
        "analyzer": "standard",
        "index_options": "positions",
        "norms": true,
        "similarity": "tutorial_bm25",
        "fields": {
          "raw": {
            "type": "keyword",
            "ignore_above": 512
          }
        }
      },
      "text": {
        "type": "text",
        "analyzer": "standard",
        "index_options": "positions",
        "norms": true,
        "similarity": "tutorial_bm25"
      }
    }
  }
}
```

## 2.4 Suggested Order

```text
NFCorpus or SciFact
  → MS MARCO Passage v1
  → TREC DL 2019/2020
  → MS MARCO Passage v2 or Wikipedia
```

For most experiments, start with MS MARCO Passage v1. It provides the best balance of realistic queries, relevance labels, corpus size, and manageable download cost.

# 3 Assorted

## 3.1 esrally

* [rally](https://github.com/elastic/rally): is the macrobenchmarking framework for Elasticsearch.
* [rally-tracks](https://github.com/elastic/rally-tracks): contains the default track specifications for the Elasticsearch benchmarking tool Rally.

```sh
# List available tracks.
esrally list tracks

# Test with existing es cluster.
esrally race \
  --pipeline=benchmark-only \
  --track=pmc \
  --target-hosts=127.0.0.1:9200 \
  --client-options="use_ssl:true,verify_certs:false,basic_auth_user:'elastic',basic_auth_password:'<password>'"

esrally race \
  --pipeline=benchmark-only \
  --track=wikipedia \
  --target-hosts=127.0.0.1:9200 \
  --client-options="use_ssl:true,verify_certs:false,basic_auth_user:'elastic',basic_auth_password:'<password>'"
```

Data directory:

* `~/.rally/benchmarks/data`
    * `~/.rally/benchmarks/data/pmc`

## 3.2 ES APIs

```sh
ES_PASSWORD=${ES_PASSWORD:-a12345678A}
ES_HOST=${ES_HOST:-127.0.0.1}
ES_PORT=${ES_PORT:-9200}

# Check health
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cluster/health"
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cluster/health?pretty"

# Check shards
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cat/shards"
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason"

# Check tasks
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cat/tasks?v&detailed"

# Get all indexes(datasets)
curl -k -u elastic:${ES_PASSWORD} "https://${ES_HOST}:${ES_PORT}/_cat/indices?v"

# Delete index(named with 'my-index')
curl -k -u elastic:${ES_PASSWORD} -X DELETE "https://${ES_HOST}:${ES_PORT}/my-index?pretty"
```

## 3.3 Kibana Tips

Navigation:

* Management -> Stack Management
