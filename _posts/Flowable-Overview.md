---
title: Flowable-Overview
date: 2018-07-25 11:31:35
tags: 
- 原创
categories: 
- Java
- Framework
- Flowable
---

__阅读更多__

<!--more-->

# 1 Overview

# 2 Event

`BPMN 2.0`中，存在两种主要的event类型

1. `Catching`：
1. `Throwing`：

## 2.1 Event Definitions

`Event Definitions`定义了`event`的具体语义（semantics），如果一个`event`不包含`Event Definitions`，那么这个事件不执行任何操作

### 2.1.1 Timer Event Definitions

顾名思义，`Timer events`由一个事先定义好的`timer`来触发，可以用于`start event`、`intermediate event`、`boundary event`

我们可以定义多种不同的`timer`，主要包括如下三种（关于`timer`的详细语法请参考[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Dates)）

1. `timeDate`
1. `timeDuration`
1. `timeCycle`

__`timeDate`的示例如下__

```xml
<timerEventDefinition>
    <timeDate>2011-03-11T12:13:14</timeDate>
</timerEventDefinition>
```

__`timeDuration`的示例如下__

```xml
<timerEventDefinition>
    <timeDuration>P10D</timeDuration>
</timerEventDefinition>
```

__`timeCycle`的示例如下__

```xml
<timerEventDefinition>
    <timeCycle flowable:endDate="2015-02-25T16:42:11+00:00">R3/PT10H</timeCycle>
</timerEventDefinition>

<timerEventDefinition>
    <timeCycle>R3/PT10H/${EndDate}</timeCycle>
</timerEventDefinition>

<timerEventDefinition>
    <timeCycle>0 0/5 * * * ?</timeCycle>
</timerEventDefinition>
```

### 2.1.2 Error Event Definitions

__首先，声明一点：`BPMN error`与`Java exception`是完全不同的，不能拿来类比。`BPMN error`仅用于描述业务异常。示例如下__

```xml
<endEvent id="myErrorEndEvent">
    <errorEventDefinition errorRef="myError" />
</endEvent>
```

### 2.1.3 Signal Event Definitions

__`Signal Event`指向了一个`signal`。`signal`的作用域是全局的。示例如下__

```xml
<definitions... >
    <!-- declaration of the signal -->
    <signal id="alertSignal" name="alert" />

    <process id="catchSignal">
        <intermediateThrowEvent id="throwSignalEvent" name="Alert">
            <!-- signal event definition -->
            <signalEventDefinition signalRef="alertSignal" />
        </intermediateThrowEvent>
        ...
        <intermediateCatchEvent id="catchSignalEvent" name="On Alert">
            <!-- signal event definition -->
            <signalEventDefinition signalRef="alertSignal" />
        </intermediateCatchEvent>
        ...
    </process>
</definitions>
```

__我们可以指定`signal`的作用域（默认是`global`）__

```xml
<signal id="alertSignal" name="alert" flowable:scope="processInstance"/>
```

### 2.1.4 Message Event Definitions

__`Message Event`指向了一个`message`，一个`message`拥有一个`name`以及`payload`。与`signal`不同，一个`message`只能有一个`receiver`。示例如下__

```xml
<definitions id="definitions"
  xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
  xmlns:flowable="http://flowable.org/bpmn"
  targetNamespace="Examples"
  xmlns:tns="Examples">

  <message id="newInvoice" name="newInvoiceMessage" />
  <message id="payment" name="paymentMessage" />

  <process id="invoiceProcess">

    <startEvent id="messageStart" >
        <messageEventDefinition messageRef="newInvoice" />
    </startEvent>
    ...
    <intermediateCatchEvent id="paymentEvt" >
        <messageEventDefinition messageRef="payment" />
    </intermediateCatchEvent>
    ...
  </process>

</definitions>
```

## 2.2 Start Events

顾名思义，`start event`就是一个`process`开始的节点，`start event`的类型定义着`process`的开始方式

__`start event`永远是`catching event`，意思是说，`start event`一直处于wait状态，直到被触发（trigger）。示例如下__

```xml
<startEvent id="request" flowable:initiator="initiator" />
```

### 2.2.1 None Start Event

__从技术上来说，`none start event`意味着`trigger`未指定，因此这种`process`只能手动启动。示例如下__

```xml
<startEvent id="start" name="my start event" />
```

```Java
ProcessInstance processInstance = runtimeService.startProcessInstanceByXXX();
```

### 2.2.2 Timer Start Event

顾名思义，`timer start event`会在指定的时间启动`process`。示例如下

```xml
<startEvent id="theStart">
  <timerEventDefinition>
    <timeCycle>R4/2011-03-11T12:13/PT5M</timeCycle>
  </timerEventDefinition>
</startEvent>

<startEvent id="theStart">
  <timerEventDefinition>
    <timeDate>2011-03-11T12:13:14</timeDate>
  </timerEventDefinition>
</startEvent>
```

__注意事项__

1. `sub-process`不允许含有`timer start event`
1. `timer start event`在部署时就被`scheduler`（后台运行一个job，定时启动`process`）。因此不需要手动启动`process`（不需要而不是不能）
1. 当一个新版本部署时，旧版本的`timer`（后台那个job）会被移除

### 2.2.3 Message Start Event

`message start event`用于启动一个`process`，一个`process definition`允许存在多个`message start event`

1. 在一个`process definition`内，`message start event`的名字必须唯一，否则`flowable engine`在部署时会抛出异常
1. 不允许不同`process definition`包含具有相同名字的`message start event`，否则否则`flowable engine`在部署时会抛出异常
1. 当部署新版本的`process definition`时，之前的`message`订阅关系将会被移除

__示例如下__

```xml
<definitions id="definitions"
  xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
  xmlns:flowable="http://flowable.org/bpmn"
  targetNamespace="Examples"
  xmlns:tns="Examples">

  <message id="newInvoice" name="newInvoiceMessage" />

  <process id="invoiceProcess">

    <startEvent id="messageStart" >
        <messageEventDefinition messageRef="tns:newInvoice" />
    </startEvent>
    ...
  </process>

</definitions>
```

__注意事项__

1. `message start event`仅支持顶层`process`，即不支持`sub-process`
1. 如果`process definition`包含多个`message start event`，那么`runtimeService.startProcessInstanceByMessage(…​) `会选择适当的`message`来启动`process`
1. 如果`process definition`包含多个`message start event`以及一个`none start event`， `runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会使用`none start event`来启动`process`
1. 如果`process definition`包含多个`message start event`但不包含`none start event`，`runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会抛出异常
1. 如果`process definition`包含一个`message start event`，那么`runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会使用`message start event`来启动`process`

# 3 参考

* [Flowalbe Doc](https://www.flowable.org/docs/userguide/index.html)
* [BPMN icon](https://wenku.baidu.com/view/92b1bc06cc17552707220854.html)
