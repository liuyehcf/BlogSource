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

__概念__

1. `Process`：文中称为`流程`、`执行流`
    * `instance`：文中称为`实例`
1. `Event`：文中称为`事件`
1. `Flow`：文中称为`连线`
1. `Gateway`：文中称为`网关`
1. `Task`：文中称为`任务`
1. `Variable`：变量
1. `Expression`：表达式，通常指`UEL`

# 2 Event

`BPMN 2.0`中，存在两种主要的event类型

1. `Catching`：当`process`执行到此类event时，它会等待某个`trigger`来触发
1. `Throwing`：当`process`执行到此类event时，一个`trigger`被触发

__参考__

* [Event](https://www.flowable.org/docs/userguide/index.html#bpmnEvents)

## 2.1 Event Definitions

`Event Definitions`定义了`event`的具体语义（semantics），如果一个`event`不包含`Event Definitions`，那么这个事件不执行任何操作

### 2.1.1 Timer Event Definitions

__Description__

> 顾名思义，`Timer events`由一个事先定义好的`timer`来触发，可以用于`start event`、`intermediate event`、`boundary event`

> 我们可以定义多种不同的`timer`，主要包括如下三种（关于`timer`的详细语法请参考[ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Dates)）

> 1. `timeDate`
> 1. `timeDuration`
> 1. `timeCycle`

__XML representation__

```xml
<!-- timeDate -->
<timerEventDefinition>
    <timeDate>2011-03-11T12:13:14</timeDate>
</timerEventDefinition>

<!-- timeDuration -->
<timerEventDefinition>
    <timeDuration>P10D</timeDuration>
</timerEventDefinition>

<!-- timeCycle -->
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

__Description__

> 首先，声明一点：`BPMN error`与`Java exception`是完全不同的，不能拿来类比。`BPMN error`仅用于描述业务异常

__XML representation__

```xml
<endEvent id="myErrorEndEvent">
    <errorEventDefinition errorRef="myError" />
</endEvent>
```

### 2.1.3 Signal Event Definitions

__Description__

> `Signal Event`指向了一个`signal`。`signal`的作用域是全局的

__XML representation__

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

<!-- 我们可以指定signal的作用域（默认是global） -->
<signal id="alertSignal" name="alert" flowable:scope="processInstance"/>
```

### 2.1.4 Message Event Definitions

__Description__

> `Message Event`指向了一个`message`，一个`message`拥有一个`name`以及`payload`。与`signal`不同，一个`message`只能有一个`receiver`

__XML representation__

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

__Description__

> 顾名思义，`start event`就是一个`process`开始的节点，`start event`的类型定义着`process`的开始方式
> `start event`永远是`catching event`，意思是说，`start event`一直处于wait状态，直到被触发（trigger）

__XML representation__

```xml
<startEvent id="request" flowable:initiator="initiator" />
```

### 2.2.1 None Start Event

__Description__

> 从技术上来说，`none start event`意味着`trigger`未指定，因此这种`process`只能手动启动

__XML representation__

```xml
<startEvent id="start" name="my start event" />
```

```Java
ProcessInstance processInstance = runtimeService.startProcessInstanceByXXX();
```

### 2.2.2 Timer Start Event

__Description__

> 顾名思义，`timer start event`会在指定的时间启动`process`

__XML representation__

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

__Description__

> `message start event`用于启动一个`process`，一个`process definition`允许存在多个`message start event`
> 1. 在一个`process definition`内，`message start event`的名字必须唯一，否则`flowable engine`在部署时会抛出异常
> 1. 不允许不同`process definition`包含具有相同名字的`message start event`，否则否则`flowable engine`在部署时会抛出异常
> 1. 当部署新版本的`process definition`时，之前的`message`订阅关系将会被移除

__XML representation__

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
1. 如果`process definition`包含多个`message start event`以及一个`none start event`，`runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会使用`none start event`来启动`process`
1. 如果`process definition`包含多个`message start event`但不包含`none start event`，`runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会抛出异常
1. 如果`process definition`包含一个`message start event`，那么`runtimeService.startProcessInstanceByKey(…​)`以及`runtimeService.startProcessInstanceById(…​) `会使用`message start event`来启动`process`

### 2.2.4 Signal Start Event

__Description__

> `signal start event`可用于使用命名信号启动`process`实例。可以使用`intermediary signal throw event`或通过API（`runtimeService.signalEventReceivedXXX`方法）从流程实例中触发信号。在这两种情况下，将启动具有相同名称的信号启动事件的所有流程定义

__XML representation__

```xml
<signal id="theSignal" name="The Signal" />

<process id="processWithSignalStart1">
    <startEvent id="theStart">
        <signalEventDefinition id="theSignalEventDefinition" signalRef="theSignal"  />
    </startEvent>
    <sequenceFlow id="flow1" sourceRef="theStart" targetRef="theTask" />
    <userTask id="theTask" name="Task in process A" />
    <sequenceFlow id="flow2" sourceRef="theTask" targetRef="theEnd" />
    <endEvent id="theEnd" />
</process>
```

### 2.2.5 Error Start Event

__Description__

> `error start event`可用于触发`sub-process`。`error start event`不能用于启动`process`实例。`error start event`总是在中断

__XML representation__

```xml
<startEvent id="messageStart" >
    <errorEventDefinition errorRef="someError" />
</startEvent>
```

## 2.3 End Events

`end event`表示`process`或`sub-process`的结束。`end event`一定是`throwing event`。这意味着当`process`执行到达`end event`时，将抛出`result`

### 2.3.1 None End Event

__Description__

> `none end event`表示执行动作未定义。因此，除了结束当前的执行的`process`外，引擎不会做任何额外的事情

__XML representation__

```xml
<endEvent id="end" name="my end event" />
```

### 2.3.2 Error End Event

__Description__

> 当`process`执行到达`error end event`时，当前执行路径结束并抛出`error`。匹配的`intermediate event`或`boundary event`可以捕获此错误。如果未找到匹配的边界错误事件，则将引发异常

__XML representation__

```xml
<endEvent id="myErrorEndEvent">
    <errorEventDefinition errorRef="myError" />
</endEvent>
```

### 2.3.3 Terminate End Event

__Description__

> 到达`terminate end event`时，将终止当前`process`实例或`sub-process`。从概念上讲，当执行到达`terminate end event`时，将确定并结束第一范围（`process`或`sub-process`）。请注意，在`BPMN 2.0`中，子流程可以是一个`embedded sub-process`，`call activity`，`event sub-process`或`transaction sub-process`。此规则通常适用：例如，当存在`call activity`或`embedded sub-process`时，仅该实例结束，其他实例和流程实例不受影响

__XML representation__

```xml
<endEvent id="myEndEvent" >
    <terminateEventDefinition flowable:terminateAll="true"></terminateEventDefinition>
</endEvent>
```

### 2.3.4 Cancel End Event

__Description__

> `cancel end event`只能与BPMN`transaction sub-process`结合使用。当到达`cancel end event`时，抛出`cancel event`，必须由`cancel boundary event`捕获。`cancel boundary event`随后取消事务并触发补偿

__XML representation__

```xml
<endEvent id="myCancelEndEvent">
    <cancelEventDefinition />
</endEvent>
```

## 2.4 Boundary Events

`boundary event`捕获附加到`activity`的事件（`boundary event`一定是`catching event`）。这意味着当`activity`正在运行时，事件正在侦听某种类型的`trigger`。当事件被捕获时，`activity`被中断并且遵循事件的执行流

```xml
<boundaryEvent id="myBoundaryEvent" attachedToRef="theActivity">
      <XXXEventDefinition/>
</boundaryEvent>
```

### 2.4.1 Timer Boundary Event

__Description__

> `timer boundary event`充当秒表和闹钟。当执行到达附加`timer boundary event`的`activity`时，启动计时器。当计时器触发时（例如，在指定的间隔之后），`activity`被中断并且遵循`timer boundary event`之外的执行流

__XML representation__

```xml
<boundaryEvent id="escalationTimer" cancelActivity="true" attachedToRef="firstLineSupport">
    <timerEventDefinition>
        <timeDuration>PT4H</timeDuration>
    </timerEventDefinition>
</boundaryEvent>
```

### 2.4.2 Error Boundary Event

__Description__

> `error boundary event`捕获在定义它的`activity`范围内引发的`error`

__XML representation__

```xml
<boundaryEvent id="catchError" attachedToRef="mySubProcess">
    <errorEventDefinition errorRef="myError"/>
</boundaryEvent>
```

### 2.4.3 Signal Boundary Event

__Description__

> `signal boundary event`用于捕获指定的`signal`

__XML representation__

```xml
<boundaryEvent id="boundary" attachedToRef="task" cancelActivity="true">
    <signalEventDefinition signalRef="alertSignal"/>
</boundaryEvent>
```

### 2.4.4 Message Boundary Event

__Description__

> `message boundary event`用于捕获指定的`message`

__XML representation__

```xml
<boundaryEvent id="boundary" attachedToRef="task" cancelActivity="true">
    <messageEventDefinition messageRef="newCustomerMessage"/>
</boundaryEvent>
```

### 2.4.5 Cancel Boundary Event

__Description__

> `cancel boundary event`触发时，它首先中断当前作用域中的所有`activity`。接下来，它开始补偿事务范围内的所有有效`compensation boundary event`。补偿是同步进行的，换句话说，`boundary event`会等待补偿完成后离开事务

__XML representation__

```xml
<boundaryEvent id="boundary" attachedToRef="transaction" >
    <cancelEventDefinition />
</boundaryEvent>
```

### 2.4.6 Compensation Boundary Event

__Description__

> `compensation boundary event`作为activity的补偿处理过程

__XML representation__

```xml
<boundaryEvent id="compensateBookHotelEvt" attachedToRef="bookHotel" >
    <compensateEventDefinition />
</boundaryEvent>

<association associationDirection="One" id="a1"
    sourceRef="compensateBookHotelEvt" targetRef="undoBookHotel" />

<serviceTask id="undoBookHotel" isForCompensation="true" flowable:class="..." />
```

## 2.5 Intermediate Catching Events

```xml
<intermediateCatchEvent id="myIntermediateCatchEvent" >
    <XXXEventDefinition/>
</intermediateCatchEvent>
```

### 2.5.1 Timer Intermediate Catching Event

__Description__

> `timer intermediate catching event`充当秒表，当`process`到达`timer intermediate catching event`时，`timer`被触发，经过指定时间后，继续后续处理流程

__XML representation__

```xml
<intermediateCatchEvent id="timer">
    <timerEventDefinition>
        <timeDuration>PT5M</timeDuration>
    </timerEventDefinition>
</intermediateCatchEvent>
```

### 2.5.2 Signal Intermediate Catching Event

__Description__

> `signal intermediate catching event`用于捕获指定的`signal`

__XML representation__

```xml
<intermediateCatchEvent id="signal">
    <signalEventDefinition signalRef="newCustomerSignal" />
</intermediateCatchEvent>
```

### 2.5.3 Message Intermediate Catching Event

__Description__

> `message intermediate catching event`用于捕获指定的`message`

__XML representation__

```xml
<intermediateCatchEvent id="message">
    <messageEventDefinition signalRef="newCustomerMessage" />
</intermediateCatchEvent>
```

## 2.6 Intermediate Throwing Event

```xml
<intermediateThrowEvent id="myIntermediateThrowEvent" >
      <XXXEventDefinition/>
</intermediateThrowEvent>
```

### 2.6.1 Intermediate Throwing None Event

__Description__

> `intermediate throwing none event`通常用来表示`process`到达某种状态

__XML representation__

```xml
<intermediateThrowEvent id="noneEvent">
    <extensionElements>
        <flowable:executionListener class="org.flowable.engine.test.bpmn.event.IntermediateNoneEventTest$MyExecutionListener" event="start" />
    </extensionElements>
</intermediateThrowEvent>
```

### 2.6.2 Signal Intermediate Throwing Event

__Description__

> `signal intermediate throwing event`抛出一个`signal`

__XML representation__

```xml
<intermediateThrowEvent id="signal">
    <signalEventDefinition signalRef="newCustomerSignal" />
</intermediateThrowEvent>

<!-- async mode -->
<intermediateThrowEvent id="signal">
  <signalEventDefinition signalRef="newCustomerSignal" flowable:async="true" />
</intermediateThrowEvent>
```

### 2.6.3 Compensation Intermediate Throwing Event

__Description__

> `compensation intermediate throwing event`抛出`compensation event`来触发`compensation`

__XML representation__

```xml
<intermediateThrowEvent id="throwCompensation">
    <compensateEventDefinition />
</intermediateThrowEvent>

<intermediateThrowEvent id="throwCompensation">
    <compensateEventDefinition activityRef="bookHotel" />
</intermediateThrowEvent>
```

# 3 Sequence Flow

`sequence flow`用于表示两个`process`元素的连接关系（路由关系，带有方向）。当`process`执行到某个节点时，所有通过`sequence flow`连接出去的路径都会被同时执行，也就是并发的两条/多条执行链路

```xml
<sequenceFlow id="flow1" sourceRef="theStart" targetRef="theTask" />
```

__参考__

* [Sequence Flow](https://www.flowable.org/docs/userguide/index.html#bpmnSequenceFlow)

## 3.1 Conditional sequence flow

__Description__

> 顾名思义，`conditional sequence flow`允许附带一个条件。条件为真时，继续执行当前路径的后续流程，否则终止当前路径

__XML representation__

```xml
<!-- conditionExpression仅支持 UEL -->
<!-- 且表达式的值必须是bool值，否则会抛出异常 -->
<sequenceFlow id="flow" sourceRef="theStart" targetRef="theTask">
  <conditionExpression xsi:type="tFormalExpression">
    <![CDATA[${order.price > 100 && order.price < 250}]]>
  </conditionExpression>
</sequenceFlow>
```

## 3.2 Default sequence flow

__Description__

> `default sequence flow`当且仅当当前节点的其他`sequence flow`没有被触发时才会生效，起到一个默认路由的作用

__XML representation__

```xml
<!-- The following XML snippet shows an example of an exclusive gateway that has as default sequence flow, flow 2. Only when conditionA and conditionB both evaluate to false, will it be chosen as the outgoing sequence flow for the gateway. -->
<exclusiveGateway id="exclusiveGw" name="Exclusive Gateway" default="flow2" />

<sequenceFlow id="flow1" sourceRef="exclusiveGw" targetRef="task1">
    <conditionExpression xsi:type="tFormalExpression">${conditionA}</conditionExpression>
</sequenceFlow>

<sequenceFlow id="flow2" sourceRef="exclusiveGw" targetRef="task2"/>

<sequenceFlow id="flow3" sourceRef="exclusiveGw" targetRef="task3">
    <conditionExpression xsi:type="tFormalExpression">${conditionB}</conditionExpression>
</sequenceFlow>
```

# 4 Gateway

`gateway`用于控制`process`的执行流。抽象地来说，`gateway`能够使用或者消耗`token`

__参考__

* [Gateway](https://www.flowable.org/docs/userguide/index.html#bpmnGateways)

## 4.1 Exclusive Gateway

__Description__

> `exclusive gateway`又被称为`XOR gateway`，通常用于描述`decision`。当流程执行到`exclusive gateway`时，所有的`sequence flow`会按照定义的顺序进行条件判断（针对`conditional sequence flow`，`sequence flow`也可以看成一个条件永远为真的`conditional sequence flow`）。第一个为真的`conditional sequence flow`将会被选中并继续执行后续流程，其余`sequence flow`被忽略。全都为假时，将会抛出异常

__XML representation__

```xml
<exclusiveGateway id="exclusiveGw" name="Exclusive Gateway" />

<sequenceFlow id="flow2" sourceRef="exclusiveGw" targetRef="theTask1">
  <conditionExpression xsi:type="tFormalExpression">${input == 1}</conditionExpression>
</sequenceFlow>

<sequenceFlow id="flow3" sourceRef="exclusiveGw" targetRef="theTask2">
  <conditionExpression xsi:type="tFormalExpression">${input == 2}</conditionExpression>
</sequenceFlow>

<sequenceFlow id="flow4" sourceRef="exclusiveGw" targetRef="theTask3">
  <conditionExpression xsi:type="tFormalExpression">${input == 3}</conditionExpression>
</sequenceFlow>
```

## 4.2 Parallel Gateway

__Description__

> `parallel gateway`通常用于描述并发执行流，最直接最方便的引入并发特性的元素就是`parallel gateway`。`parallel gateway`可以起到`fork`的作用（从一条路径到多条路径），以及`join`的作用（从多条执行路径到一条执行路径），这取决于`parallel gateway`放置的位置
> 要注意的是，与`parallel gateway`相连的`sequence flow`若是`conditional sequence flow`，则条件的校验将会被直接忽略

__XML representation__

```xml
<startEvent id="theStart" />
<sequenceFlow id="flow1" sourceRef="theStart" targetRef="fork" />

<parallelGateway id="fork" />
<sequenceFlow sourceRef="fork" targetRef="receivePayment" />
<sequenceFlow sourceRef="fork" targetRef="shipOrder" />

<userTask id="receivePayment" name="Receive Payment" />
<sequenceFlow sourceRef="receivePayment" targetRef="join" />

<userTask id="shipOrder" name="Ship Order" />
<sequenceFlow sourceRef="shipOrder" targetRef="join" />

<parallelGateway id="join" />
<sequenceFlow sourceRef="join" targetRef="archiveOrder" />

<userTask id="archiveOrder" name="Archive Order" />
<sequenceFlow sourceRef="archiveOrder" targetRef="theEnd" />

<endEvent id="theEnd" />
```

## 4.3 Inclusive Gateway

__Description__

> `inclusive gateway`可以看成是`exclusive gateway`以及`parallel gateway`的结合体。与`exclusive gateway`类似，`inclusive gateway`会执行`conditional sequence flow`上的条件；与`parallel gateway`类似，`inclusive gateway`同样允许`fork`以及`join`

__XML representation__

```xml
<startEvent id="theStart" />
<sequenceFlow id="flow1" sourceRef="theStart" targetRef="fork" />

<inclusiveGateway id="fork" />
<sequenceFlow sourceRef="fork" targetRef="receivePayment" >
  <conditionExpression xsi:type="tFormalExpression">${paymentReceived == false}</conditionExpression>
</sequenceFlow>
<sequenceFlow sourceRef="fork" targetRef="shipOrder" >
  <conditionExpression xsi:type="tFormalExpression">${shipOrder == true}</conditionExpression>
</sequenceFlow>

<userTask id="receivePayment" name="Receive Payment" />
<sequenceFlow sourceRef="receivePayment" targetRef="join" />

<userTask id="shipOrder" name="Ship Order" />
<sequenceFlow sourceRef="shipOrder" targetRef="join" />

<inclusiveGateway id="join" />
<sequenceFlow sourceRef="join" targetRef="archiveOrder" />

<userTask id="archiveOrder" name="Archive Order" />
<sequenceFlow sourceRef="archiveOrder" targetRef="theEnd" />

<endEvent id="theEnd" />
```

# 5 Task

## 5.1 User Task

__Description__

> `user task`用于描述人类需要完成的工作。当流程执行到此类任务时，将在分配给该任务的任何用户或组的任务列表中创建新任务

__XML representation__

```xml
<!-- normal -->
<userTask id="theTask" name="Important task" />

<!-- documentation -->
<userTask id="theTask" name="Schedule meeting" >
    <documentation>
        Schedule an engineering meeting for next week with the new hire.
    </documentation>
</userTask>

<!-- due date -->
<userTask id="theTask" name="Important task" flowable:dueDate="${dateVariable}"/>

<!-- user assignment -->
<userTask id='theTask' name='important task' >
    <humanPerformer>
        <resourceAssignmentExpression>
            <formalExpression>kermit</formalExpression>
        </resourceAssignmentExpression>
    </humanPerformer>
</userTask>

<!-- candidate user assignment -->
<!-- If no specifics are given as to whether the given text string is a user or group, the engine defaults to group -->
<userTask id='theTask' name='important task' >
    <potentialOwner>
        <resourceAssignmentExpression>
            <formalExpression>user(kermit), group(management)</formalExpression>
        </resourceAssignmentExpression>
    </potentialOwner>
</userTask>

<!-- more flexible way -->
<userTask id="theTask" name="my task" flowable:assignee="kermit" />
<userTask id="theTask" name="my task" flowable:candidateUsers="kermit, gonzo" />
<userTask id="theTask" name="my task" flowable:candidateGroups="management, accountancy" />
<userTask id="theTask" name="my task" flowable:candidateUsers="kermit, gonzo" flowable:candidateGroups="management, accountancy" />
```

__参考__

* [User Task](https://www.flowable.org/docs/userguide/index.html#bpmnUserTask)

## 5.2 Script Task

__Description__

> `script task`是一个自动的`activity`，当一个`process`执行到`script task`时，相关联的`script`就会被执行

__XML representation__

```xml
<scriptTask id="theScriptTask" name="Execute script" scriptFormat="groovy">
    <script>
        sum = 0
        for ( i in inputArray ) {
            sum += i
        }
    </script>
</scriptTask>

<!-- variable store -->
<!-- default value of autoStoreVariables is false -->
<scriptTask id="script" scriptFormat="JavaScript" flowable:autoStoreVariables="false">
    <script>
        def scriptVar = "test123"
        execution.setVariable("myVar", scriptVar)
</script>
</scriptTask>

<!-- script result store -->
<!-- In the following example, the result of the script execution (the value of the resolved expression '#{echo}') is set to the process variable named 'myVar' after the script completes. -->
<scriptTask id="theScriptTask" name="Execute script" scriptFormat="juel" flowable:resultVariable="myVar">
    <script>#{echo}</script>
</scriptTask>
```

__以下名称是保留字符，不可用于变量名__

1. `out`
1. `out:print`
1. `lang:import`
1. `context`
1. `elcontext`

__参考__

* [Script Task](https://www.flowable.org/docs/userguide/index.html#bpmnScriptTask)

## 5.3 Java Service Task

__Description__

> `java service task`用于触发一个Java方法

__XML representation__

```xml
<!-- normal -->
<serviceTask id="javaService"
             name="My Java Service Task"
             flowable:class="org.flowable.MyJavaDelegate" />

<!-- delegate to bean -->
<!-- the delegateExpressionBean is a bean that implements the JavaDelegate interface, defined in, for example, the Spring container -->
<serviceTask id="serviceTask" flowable:delegateExpression="${delegateExpressionBean}" />

<!-- UEL(Unified Expression Language) method expression -->
<serviceTask id="javaService"
             name="My Java Service Task"
             flowable:expression="#{printer.printMessage()}" />

<!-- Field Injected -->
<serviceTask id="javaService"
    name="Java service invocation"
    flowable:class="org.flowable.examples.bpmn.servicetask.ToUpperCaseFieldInjected">
    <extensionElements>
        <flowable:field name="text" stringValue="Hello World" />
    </extensionElements>
</serviceTask>
```

__Implementation__

1. 必须实现`org.flowable.engine.delegate.JavaDelegate`的`execute`方法
1. 所有`process`的实例共享同一个`JavaDelegate`的实例，因此这个类的实现必须是线程安全的（最好无状态）
1. 当第一次被使用时，才会创建`JavaDelegate`的实例

__Field Injection__

1. 通常，会通过setter方法来为`delegated class`注入属性值（超级无敌神坑：若写的是private的字段，而没有提供public的set方法，有时候注入会失败）
1. __字段类型必须是`org.flowable.engine.delegate.Expression`__

__Using a Flowable service from within a JavaDelegate__

1. `RuntimeService runtimeService = Context.getProcessEngineConfiguration().getRuntimeService();`
1. ...

__参考__

* [UEL（Unified Expression Language）](https://docs.oracle.com/javaee/5/tutorial/doc/bnahq.html)
* [Java Service Task](https://www.flowable.org/docs/userguide/index.html#bpmnJavaServiceTask)

## 5.4 Web Service Task

__Description__

> `web service task`用于同步地触发一个外部的Web service

__参考__

* [Web Service Task](https://www.flowable.org/docs/userguide/index.html#bpmnWebserviceTask)

## 5.5 Business Rule Task

__Description__

> `business rule task`用于同步地执行一个或多个rule。`Flowable`使用`Drools Rule Engine`来执行具体的rule

__参考__

* [Business Rule Task](https://www.flowable.org/docs/userguide/index.html#bpmnBusinessRuleTask)

## 5.6 Email Task

__Description__

> Flowable允许您使用向一个或多个收件人发送电子邮件的自动邮件服务任务来增强业务流程

__XML representation__

```xml
<serviceTask id="sendMail" flowable:type="mail">
    <extensionElements>
        <flowable:field name="from" stringValue="order-shipping@thecompany.com" />
        <flowable:field name="to" expression="${recipient}" />
        <flowable:field name="subject" expression="Your order ${orderId} has been shipped" />
        <flowable:field name="html">
            <flowable:expression>
                <![CDATA[
                    <html>
                        <body>
                            Hello ${male ? 'Mr.' : 'Mrs.' } ${recipientName},<br/><br/>

                            As of ${now}, your order has been <b>processed and shipped</b>.<br/><br/>

                            Kind regards,<br/>

                            TheCompany.
                        </body>
                    </html>
                ]]>
            </flowable:expression>
        </flowable:field>
    </extensionElements>
</serviceTask>
```

__参考__

* [Email Task](https://www.flowable.org/docs/userguide/index.html#bpmnEmailTask)

## 5.7 Http Task

__Description__

> `http task`允许发出HTTP请求，增强了`Flowable`的集成功能。请注意，`http task`不是`BPMN 2.0`规范的官方任务（因此没有专用图标）。因此，在Flowable中，`http task`被实现为专用服务任务

__XML representation__

```xml
<serviceTask id="httpGet" flowable:type="http">
    <extensionElements>
        <flowable:field name="requestMethod" stringValue="GET" />
        <flowable:field name="requestUrl" stringValue="http://flowable.org" />
        <flowable:field name="requestHeaders">
            <flowable:expression>
                <![CDATA[
                Accept: text/html
                Cache-Control: no-cache
                ]]>
            </flowable:expression>
        </flowable:field>
        <flowable:field name="requestTimeout">
            <flowable:expression>
                <![CDATA[
                ${requestTimeout}
                ]]>
            </flowable:expression>
        </flowable:field>
        <flowable:field name="resultVariablePrefix">
            <flowable:string>task7</flowable:string>
        </flowable:field>
    </extensionElements>
</serviceTask>
```

__参考__

* [Http Task](https://www.flowable.org/docs/userguide/index.html#bpmnHttpTask)

## 5.8 Mule Task

__Description__

> `mule task`允许您向Mule发送消息，增强Flowable的集成功能。请注意，Mule任务不是`BPMN 2.0`规范的官方任务（因此没有专用图标）。因此，在`Flowable`中，`mule task`任务被实现为专用服务任务

__参考__

* [Mule Task](https://www.flowable.org/docs/userguide/index.html#bpmnMuleTask)

## 5.9 Camel Task

__Description__

> `camel task`允许您向`Camel`发送消息和从`Camel`接收消息，从而增强Flowable的集成功能。请注意，`camel task`不是`BPMN 2.0`规范的官方任务（因此没有专用图标）。因此，在`Flowable`中，`Camel`任务被实现为专用服务任务。另请注意，必须在项目中包含`Flowable Camel`模块才能使用`Camel`任务功能

__参考__

* [Camel Task](https://www.flowable.org/docs/userguide/index.html#bpmnCamelTask)

## 5.10 Manual Task

__Description__

> `manual task`定义BPM引擎外部的任务。它用于模拟由某人完成的工作，引擎不需要知道，也没有系统或用户界面。对于引擎，手动任务作为传递活动处理，从流程执行到达时自动继续流程

__XML representation__

```xml
<manualTask id="myManualTask" name="Call client for more information" />
```
__参考__

* [Manual Task](https://www.flowable.org/docs/userguide/index.html#bpmnManualTask)

## 5.11 Java Receive Task

__Description__

> `java receuve task`务是一个等待某个消息到达的简单任务。目前，我们只为此任务实现了Java语义。当`process`执行到达接收任务时，`process`状态将提交给持久性存储。这意味着`process`将保持此等待状态，直到引擎接收到特定消息，进而触发`java receuve task`，继续执行`process`

__XML representation__

```xml
<receiveTask id="waitState" name="wait" />
```

__参考__

* [Java Receive Task](https://www.flowable.org/docs/userguide/index.html#bpmnReceiveTask)

## 5.12 Shell Task

__Description__

> `shell task`允许您运行shell脚本和命令。请注意，`shell task`不是`BPMN 2.0`规范的官方任务（因此没有专用图标）

__XML representation__

```xml
<!-- cmd /c echo EchoTest -->
<serviceTask id="shellEcho" flowable:type="shell" >
    <extensionElements>
        <flowable:field name="command" stringValue="cmd" />
        <flowable:field name="arg1" stringValue="/c" />
        <flowable:field name="arg2" stringValue="echo" />
        <flowable:field name="arg3" stringValue="EchoTest" />
        <flowable:field name="wait" stringValue="true" />
        <flowable:field name="outputVariable" stringValue="resultVar" />
    </extensionElements>
</serviceTask>
```

__参考__

* [Shell Task](https://www.flowable.org/docs/userguide/index.html#bpmnShellTask)

## 5.13 Execution listener

__Description__

> `execution listener`允许您在流程执行期间发生某些事件时执行外部Java代码或计算表达式。可以捕获的事件是：
> 1. 启动或停止`process`
> 1. 进行转移，即`sequence flow`
> 1. 启动或停止`activity`
> 1. 启动或停止`gateway`
> 1. 启动或停止`intermediate event`
> 1. 结束`start event`或启动`end event`

__示例__

```xml
<process id="executionListenersProcess">

    <!-- 第一个Listener -->
    <!-- 在process的启动时触发Listener -->
    <extensionElements>
        <flowable:executionListener
            class="org.flowable.examples.bpmn.executionlistener.ExampleExecutionListenerOne"
            event="start" />
    </extensionElements>

    <startEvent id="theStart" />
    <sequenceFlow sourceRef="theStart" targetRef="firstTask" />

    <userTask id="firstTask" />

    <!-- 第二个Listener -->
    <!-- 在进行转移时触发Listener -->
    <sequenceFlow sourceRef="firstTask" targetRef="secondTask">
        <extensionElements>
            <flowable:executionListener
                class="org.flowable.examples.bpmn.executionListener.ExampleExecutionListenerTwo" />
        </extensionElements>
    </sequenceFlow>

    <!-- 第一个Listener -->
    <!-- 在userTask结束时触发Listener -->
    <userTask id="secondTask" >
        <extensionElements>
            <flowable:executionListener
                expression="${myPojo.myMethod(execution.event)}"
                event="end" />
        </extensionElements>
    </userTask>
    <sequenceFlow sourceRef="secondTask" targetRef="thirdTask" />

    <userTask id="thirdTask" />
    <sequenceFlow sourceRef="thirdTask" targetRef="theEnd" />

    <endEvent id="theEnd" />

</process>
```

__需要实现的接口：`org.flowable.engine.delegate.ExecutionListener`__

__参考__

* [Execution listener](https://www.flowable.org/docs/userguide/index.html#executionListeners)

## 5.14 Task listener

__Description__

> `task listener`用于在发生某个与任务相关的事件时执行自定义Java逻辑或表达式。`task listener`只能作为`user task`的子元素添加到流程定义中。请注意，这也必须作为`BPMN 2.0 `的`extensionElements`子元素或`flowable namespace`，因为`task listener`是`Flowable`特定的构造

__XML representation__

```xml
<userTask id="myTask" name="My Task" >
    <extensionElements>
        <flowable:taskListener event="create" class="org.flowable.MyTaskCreateListener" />
    </extensionElements>
</userTask>
```

__event的类型（触发的时刻）__

* __`create`__：当Task被创建后，且所有属性设置完毕后
* __`assignment`__：当Task被分配给某人时。当执行流程到达`UserTask`时，`assignment event`会优先于`create event`触发
* __`complete`__：当Task被完成后，且被删除前
* __`delete`__：当Task即将被删除时

__需要实现的接口：`org.flowable.engine.delegate.TaskListener`__

__参考__

* [Task listener](https://www.flowable.org/docs/userguide/index.html#taskListeners)

## 5.15 Multi-instance (for each)

__Description__

> `multi-instance`用于重复执行业务流程中的某个步骤。在编程概念中，`multi-instance`同于`for each`语句：它允许您按顺序或并行地为给定集合中的每个元素执行某个步骤，甚至是完整的子流程

__参考__

* [Multi-instance (for each)](https://www.flowable.org/docs/userguide/index.html#bpmnMultiInstance)

## 5.16 Compensation Handlers

__Description__

> 如果某个`activity`用于补偿另一个`activity`，则可以将其声明为`compensation handler`。`compensation handler`在正常流程中不存在，仅在抛出`compensation event`时执行

__参考__

* [Compensation Handlers](https://www.flowable.org/docs/userguide/index.html#_compensation_handlers)

# 6 Variables

在`Flowable`中，与`process`相关的这些数据被称为`variables`，这些数据存储在数据库中，这些变量可以在表达式中，或者`Java Service Task`中被使用

详细内容请参考[Variables](https://www.flowable.org/docs/userguide/index.html#apiVariables)

# 7 Expression

`Expression`通常指`UEL Expression`，`UEL`的全称是Unified Expression Language

详细内容请参考[Expression](https://www.flowable.org/docs/userguide/index.html#apiExpressions)

## 7.1 Value Expression

```sh
${myVar}
${myBean.myProperty}
```

## 7.2 Method Expression

```sh
${printer.print()}
${myBean.addNewOrder('orderName')}
${myBean.doSomething(myVar, execution)}
```

## 7.3 default Object

1. `execution`：DelegateExecution的对象
1. `task`：DelegateTask的对象
1. `authenticatedUserId`：当前已通过身份验证的用户的id

# 8 Table

## 8.1 Database table names explained

__所有`Flowable`的表名前缀都是`ACT_`__

__`Flowable`的表名的第二段表示了用途，与API对应__

1. __`ACT_RE_*`__：`RE`表示`repository`，通常用于存储静态数据，比如`process definitions`、`process resources`等等
1. __`ACT_RU_*`__：`RU`表示`runtime`，通常用于存储运行时数据，比如`tasks`、`variables`、`jobs`等等
1. __`ACT_HI_*`__：`HI`表示`history`，通常保存历史数据，例如已经执行过的`process instance`、`variables`、`tasks`等等
1. __`ACT_GE_*`__：`GE`表示`general`，通常表示全局通用数据及设置

__参考__

* [Database table names explained](https://www.flowable.org/docs/userguide/index.html#database.tables.explained)
* [activiti工作流表说明](https://blog.csdn.net/u011627980/article/details/51646920)

## 8.2 Creating the database tables

`flowable`的建表语句都在`org.flowable:xxx`中的`org/flowable/db/create`路径下

```
flowable.{db}.{create|drop}.{type}.sql
```

* `{db}`：代表数据库类型
* `{create|drop}`：创建还是销毁
* `{type}`：类型，就两种`history`或`engine`

__sql文件路径（按如下顺序依次执行，表之间是有依赖关系的，切记按顺序执行）__

1. `org.flowable:flowable-engine-common:xxx`中的`org/flowable/common/db/create/flowable.mysql.create.common.sql`
1. `org.flowable:flowable-idm-engine:xxx`中的`org/flowable/idm/db/create/flowable.mysql.create.identity.sql`
1. `org.flowable:flowable-identitylink-service:xxx`中的`org/flowable/identitylink/service/db/create/flowable.mysql.create.identitylink.sql`
1. `org.flowable:flowable-identitylink-service:xxx`中的`org/flowable/identitylink/service/db/create/flowable.mysql.create.identitylink.history.sql`
1. `org.flowable:flowable-variable-service:xxx`中的`org/flowable/variable/service/db/create/flowable.mysql.create.variable.sql`
1. `org.flowable:flowable-variable-service:xxx`中的`org/flowable/variable/service/db/create/flowable.mysql.create.variable.history.sql`
1. `org.flowable:flowable-job-service:xxx`中的`org/flowable/job/service/db/create/flowable.mysql.create.job.sql`
1. `org.flowable:flowable-task-service:xxx`中的`org/flowable/task/service/db/create/flowable.mysql.create.task.sql`
1. `org.flowable:flowable-task-service:xxx`中的`org/flowable/task/service/db/create/flowable.mysql.create.task.history.sql`
1. `org.flowable:flowable-engine:xxx`中的`org/flowable/db/create/flowable.mysql.create.engine.sql`
1. `org.flowable:flowable-engine:xxx`中的`org/flowable/db/create/flowable.mysql.create.history.sql`
* 共计34张表

__参考__

* [Creating the database tables](https://www.flowable.org/docs/userguide/index.html#creatingDatabaseTable)

# 9 参考

* [Flowalbe Doc](https://www.flowable.org/docs/userguide/index.html)
* [BPMN icon](https://wenku.baidu.com/view/92b1bc06cc17552707220854.html)
