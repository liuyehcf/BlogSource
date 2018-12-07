---
title: Flowable-优化
date: 2018-09-24 08:44:23
tags: 
- 原创
categories: 
- Java
- Framework
- Flowable
---

__阅读更多__

<!--more-->

# 1 慢SQL

Flowable中很多操作会使用id来查询这些数据，但是数据表却没有为这些id列增加索引，导致了非常多的慢sql

## 1.1 act_ru_identitylink

```sql
SELECT *
FROM act_ru_identitylink
WHERE proc_inst_id_ = 'f69a1b42-bf55-11e8-86a7-00163e0e390f'
```

```sql
DELETE FROM act_ru_identitylink
WHERE task_id_ = '20720152-be30-11e8-a50e-00163e045396'
```

## 1.2 act_ru_execution

```sql
SELECT *
FROM act_ru_execution
WHERE parent_id_ = '1fc7b7f6-be30-11e8-a50e-00163e045396'

SELECT *
FROM act_ru_execution
WHERE super_exec_ = '41198800-be30-11e8-a50e-00163e045396'

SELECT *
FROM ACT_RU_EXECUTION
WHERE PROC_INST_ID_ = 'f11e4b5e-fa1d-11e8-9ab2-00163e1afb6d'
AND PARENT_ID_ IS NOT NULL
```

## 1.3 act_ru_task

```sql
SELECT t.*
FROM act_ru_task t
WHERE t.proc_inst_id_ = '3f47fd17-be30-11e8-a50e-00163e045396'
```

## 1.4 act_ru_deadletter_job

```sql
SELECT *
FROM act_ru_deadletter_job j
WHERE j.execution_id_ = '1fc7b7f6-be30-11e8-a50e-00163e045396'
```

## 1.5 act_ge_bytearray

```sql
SELECT * FROM act_ge_bytearray
WHERE deployment_id_ = 'f8575101-bf54-11e8-86a7-00163e0e390f'
ORDER BY name_ ASC
```

## 1.6 建议索引

```sql
CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_IDENTITYLINK(PROC_INST_ID_);
CREATE INDEX IDX_OPTIMIZATION_TASK_ID ON ACT_RU_IDENTITYLINK(TASK_ID_);

CREATE INDEX IDX_OPTIMIZATION_PARENT_ID ON ACT_RU_EXECUTION(PARENT_ID_);
CREATE INDEX IDX_OPTIMIZATION_SUPER_EXEC ON ACT_RU_EXECUTION(SUPER_EXEC_);

CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_TASK(PROC_INST_ID_);

CREATE INDEX IDX_OPTIMIZATION_EXECUTION_ID ON ACT_RU_DEADLETTER_JOB(EXECUTION_ID_);

CREATE INDEX IDX_OPTIMIZATION_DEPLOYMENT_ID ON ACT_GE_BYTEARRAY(DEPLOYMENT_ID_);

CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_EXECUTION(PROC_INST_ID_);
```
