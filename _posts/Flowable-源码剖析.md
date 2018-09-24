---
title: Flowable-源码剖析
date: 2018-09-17 13:01:45
tags: 
- 原创
categories: 
- Java
- Framework
- Flowable
---

__阅读更多__

<!--more-->

# 1 flowable各模块简介

## 1.1 core

### 1.1.1 flowable-engine

### 1.1.2 flowable-engine-common

### 1.1.3 flowable-engine-common-api

### 1.1.4 flowable-form-api

### 1.1.5 flowable-form-model

### 1.1.6 flowable-identitylink-service

### 1.1.7 flowable-identitylink-service-api

### 1.1.8 flowable-job-service

### 1.1.9 flowable-job-service-api

### 1.1.10 flowable-job-spring-service

### 1.1.11 flowable-task-service

### 1.1.12 flowable-task-service-api

### 1.1.13 flowable-variable-service

### 1.1.14 flowable-variable-service-api

### 1.1.15 flowable-content-api

### 1.1.16 flowable-process-validation

### 1.1.17 flowable-image-generator

## 1.2 bpmn

### 1.2.1 flowable-bpmn-converter

### 1.2.2 flowable-bpmn-model

## 1.3 dmn

### 1.3.1 flowable-dmn-api

### 1.3.2 flowable-dmn-model

## 1.4 cmmn

### 1.4.1 flowable-cmmn-api

### 1.4.2 flowable-cmmn-model

## 1.5 idm

### 1.5.1 flowable-idm-api

### 1.5.2 flowable-idm-engine

### 1.5.3 flowable-idm-engine-configurator

### 1.5.4 flowable-idm-spring

### 1.5.5 flowable-idm-spring-configurator

## 1.6 spring

### 1.6.1 flowable-spring

### 1.6.2 flowable-spring-boot-autoconfigure

### 1.6.3 flowable-spring-boot-starter-process

### 1.6.4 flowable-spring-common

# 2 TODO

1. CommandContextInterceptor.execute
    * 重点关注`commandContext.close();`
        * `flushSessions();`
        * `DbSqlSession.flush()`这里会把insert update delete操作集中处理
            * `BulkDeleteOperation`：delete的sql操作入口
1. EndExecutionOperation
    * `run`
        * `handleRegularExecution();`
            * `handleProcessInstanceExecution(executionToContinue);`
                * `executionEntityManager.deleteProcessInstanceExecutionEntity(processInstanceId,`
                    * `deleteExecutionAndRelatedData(processInstanceEntity, deleteReason);`
                        * `ExecutionEntityManagerImpl.deleteRelatedDataForExecution`重点
