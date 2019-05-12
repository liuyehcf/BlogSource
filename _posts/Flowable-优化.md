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
CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_EXECUTION(PROC_INST_ID_);

CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_TASK(PROC_INST_ID_);

CREATE INDEX IDX_OPTIMIZATION_EXECUTION_ID ON ACT_RU_DEADLETTER_JOB(EXECUTION_ID_);

CREATE INDEX IDX_OPTIMIZATION_DEPLOYMENT_ID ON ACT_GE_BYTEARRAY(DEPLOYMENT_ID_);

CREATE INDEX IDX_OPTIMIZATION_PROC_INST_ID ON ACT_RU_EXECUTION(PROC_INST_ID_);
```

# 2 清理历史数据

```sql

delete from act_hi_actinst
where START_TIME_ < '2019-02-01 00:00:00.000'

delete from act_hi_detail
where TIME_ < '2019-02-01 00:00:00.000'

delete from act_hi_identitylink
where CREATE_TIME_ < '2019-02-01 00:00:00.000'

delete from act_hi_procinst
where START_TIME_ < '2019-02-01 00:00:00.000'

delete from act_hi_taskinst
where START_TIME_ < '2019-02-01 00:00:00.000'

delete from act_hi_varinst
where CREATE_TIME_ < '2019-02-01 00:00:00.000'

delete from act_re_deployment
where DEPLOY_TIME_ < '2019-02-01 00:00:00.000'

delete from act_re_procdef 
where DEPLOYMENT_ID_ NOT IN(SELECT ID_ FROM act_re_deployment)

delete from act_ru_deadletter_job
where EXECUTION_ID_ NOT IN (SELECT ID_ FROM act_ru_execution)

delete from act_ru_execution
where START_TIME_ < '2019-02-01 00:00:00.000'

delete from act_ru_identitylink
WHERE PROC_INST_ID_ NOT IN(SELECT  PROC_INST_ID_ FROM ACT_HI_PROCINST)

delete from act_ru_task
where CREATE_TIME_ < '2019-02-01 00:00:00.000'

delete from act_ru_variable
where EXECUTION_ID_ NOT IN (SELECT ID_ FROM act_ru_execution)

select count(*) from act_evt_log    0
select count(*) from act_ge_bytearray    10732
select count(*) from act_ge_property     10
select count(*) from act_hi_actinst    62717
select count(*) from act_hi_attachment    0
select count(*) from act_hi_comment      0
select count(*) from act_hi_detail     78866
select count(*) from act_hi_identitylink    59566
select count(*) from act_hi_procinst  29560
select count(*) from act_hi_taskinst   27529
select count(*) from act_hi_varinst     76198
select count(*) from act_id_bytearray     0
select count(*) from act_id_group     0
select count(*) from act_id_info     0
select count(*) from act_id_membership    0
select count(*) from act_id_priv     0
select count(*) from act_id_priv_mapping    0
select count(*) from act_id_property     1
select count(*) from act_id_token    0
select count(*) from act_id_user    2
select count(*) from act_procdef_info     0
select count(*) from act_re_deployment  6022
select count(*) from act_re_model    0
select count(*) from act_re_procdef    6305
select count(*) from act_ru_deadletter_job   2602
select count(*) from act_ru_event_subscr  0
select count(*) from act_ru_execution  56686
select count(*) from act_ru_history_job     0
select count(*) from act_ru_identitylink  30831
select count(*) from act_ru_job    0
select count(*) from act_ru_suspended_job    64
select count(*) from act_ru_task    25673
select count(*) from act_ru_timer_job    0
select count(*) from act_ru_variable   69611 
```