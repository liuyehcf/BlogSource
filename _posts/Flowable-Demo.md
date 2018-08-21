---
title: Flowable-Demo
date: 2018-07-27 09:55:54
tags: 
- 原创
categories: 
- Java
- Framework
- Flowable
---

__阅读更多__

<!--more-->

# 1 环境

1. `IDEA`
1. `Maven3.5.3`
1. `Spring-Boot-2.0.4.RELEASE`
1. `Flowable-6.3.0`

# 2 工程目录如下

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── flowable
    │   │               ├── Application.java
    │   │               ├── config
    │   │               │   ├── DataSourceConfig.java
    │   │               │   └── ElementAspect.java
    │   │               ├── element
    │   │               │   ├── DemoListener.java
    │   │               │   └── DemoServiceTask.java
    │   │               ├── service
    │   │               │   └── DemoService.java
    │   │               ├── utils
    │   │               │   └── CreateSqlUtils.java
    │   │               └── web
    │   │                   └── DemoController.java
    │   └── resources
    │       ├── application.properties
    │       ├── logback.xml
    │       └── process
    │           └── sample.bpmn20.xml
    └── test
        ├── java
        │   └── org
        │       └── liuyehcf
        │           └── flowable
        │               └── test
        │                   ├── DemoTest.java
        │                   ├── EmbeddedDatabaseConfig.java
        │                   └── TestApplication.java
        └── resources
            └── logback-test.xml
```

# 3 pom文件

__主要依赖项如下__

1. `flowable`
1. `spring-boot`
1. `jdbc`
1. `h2`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>flowable</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <!-- flowable -->
        <dependency>
            <groupId>org.flowable</groupId>
            <artifactId>flowable-spring-boot-starter</artifactId>
            <version>6.3.0</version>
        </dependency>

        <!-- jdbc -->
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>8.0.12</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.6</version>
        </dependency>
        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis-spring</artifactId>
            <version>1.3.2</version>
        </dependency>

        <!-- spring boot -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-core</artifactId>
        </dependency>

        <!-- utility -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <version>1.16.18</version>
        </dependency>
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.48</version>
        </dependency>

        <!-- logback -->
        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.2.3</version>
        </dependency>

        <!-- test -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <version>1.4.197</version>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>2.0.4.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

# 4 Java源文件

## 4.1 Application

```Java
package org.liuyehcf.flowable;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

/**
 * @author hechenfeng
 * @date 2018/7/25
 */
@SpringBootApplication
@ComponentScan(basePackages = "org.liuyehcf.flowable")
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class);
    }
}
```

## 4.2 DataSourceConfig

```Java
package org.liuyehcf.flowable.config;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;

/**
 * @author hechenfeng
 * @date 2018/7/25
 */
@Configuration
public class DataSourceConfig {

    @Value("${spring.datasource.url}")
    private String url;

    @Value("${spring.datasource.username}")
    private String username;

    @Value("${spring.datasource.password}")
    private String password;

    @Bean(name = "dataSource")
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }

    @Bean(name = "transactionManager")
    public DataSourceTransactionManager transactionManager() {
        DataSourceTransactionManager manager = new DataSourceTransactionManager();
        manager.setDataSource(dataSource());

        return manager;
    }

    @Bean(name = "sqlSessionFactory")
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        return sqlSessionFactoryBean.getObject();
    }

}
```

## 4.3 ElementAspect

```Java
package org.liuyehcf.flowable.config;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

/**
 * @author hechenfeng
 * @date 2018/8/17
 */
@Aspect
@Component
public class ElementAspect {
    @Around("execution(* org.liuyehcf.flowable.element.*.*(..))")
    public Object taskAround(ProceedingJoinPoint proceedingJoinPoint) {

        Object[] args = proceedingJoinPoint.getArgs();

        try {
            return proceedingJoinPoint.proceed(args);
        } catch (Throwable e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
```

## 4.4 DemoListener

```Java
package org.liuyehcf.flowable.element;

import com.alibaba.fastjson.JSON;
import lombok.extern.slf4j.Slf4j;
import org.flowable.bpmn.model.FlowElement;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.ExecutionListener;
import org.flowable.engine.delegate.TaskListener;
import org.flowable.identitylink.api.IdentityLink;
import org.flowable.task.service.delegate.DelegateTask;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * @author hechenfeng
 * @date 2018/8/18
 */
@Component
@Scope(scopeName = "prototype")
@Slf4j
public class DemoListener implements TaskListener, ExecutionListener {
    @Override
    public void notify(DelegateExecution execution) {
        FlowElement currentFlowElement = execution.getCurrentFlowElement();
        log.info("ExecutionListener is trigger. elementId={}", currentFlowElement.getId());
    }

    @Override
    public void notify(DelegateTask delegateTask) {
        String taskName = delegateTask.getName();
        String assignee = delegateTask.getAssignee();
        Set<IdentityLink> candidates = delegateTask.getCandidates();

        List<CandidateInfo> candidateInfoList = candidates.stream().map(CandidateInfo::new).collect(Collectors.toList());
        log.info("TaskListener is trigger. taskName={}; assignee={}; candidateInfoList={}", taskName, assignee, JSON.toJSON(candidateInfoList));
    }

    private static final class CandidateInfo {
        private final String groupId;
        private final String userId;

        private CandidateInfo(IdentityLink identityLink) {
            this.groupId = identityLink.getGroupId();
            this.userId = identityLink.getUserId();
        }

        public String getGroupId() {
            return groupId;
        }

        public String getUserId() {
            return userId;
        }
    }

}
```

## 4.5 DemoServiceTask

```Java
package org.liuyehcf.flowable.element;

import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.common.api.delegate.Expression;
import org.flowable.engine.delegate.DelegateExecution;
import org.flowable.engine.delegate.JavaDelegate;
import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

/**
 * @author hechenfeng
 * @date 2018/8/17
 */
@Component
@Scope(scopeName = "prototype")
@Slf4j
public class DemoServiceTask implements JavaDelegate {

    private Expression field1;

    private Expression field2;

    public void setField1(Expression field1) {
        this.field1 = field1;
    }

    @Override
    public void execute(DelegateExecution execution) {
        if (field1 == null) {
            log.error("Filed injection failed. fieldName={}", "field1");
        } else {
            log.info("Filed injection succeeded. fieldName={}", "field1");
        }

        if (field2 == null) {
            log.error("Filed injection failed. fieldName={}", "field2");
        } else {
            log.info("Filed injection succeeded. fieldName={}", "field2");
        }
    }
}
```

## 4.6 DemoService

```Java
package org.liuyehcf.flowable.service;

import lombok.extern.slf4j.Slf4j;
import org.flowable.engine.RepositoryService;
import org.flowable.engine.RuntimeService;
import org.flowable.engine.TaskService;
import org.flowable.engine.repository.Deployment;
import org.flowable.engine.repository.ProcessDefinition;
import org.flowable.engine.runtime.ProcessInstance;
import org.flowable.task.api.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.List;

/**
 * @author hechenfeng
 * @date 2018/7/26
 */
@Service
@Slf4j
public class DemoService {

    private static final String BPMN_FILE_PATH = "process/sample.bpmn20.xml";

    @Autowired
    private RepositoryService repositoryService;

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private TaskService taskService;

    public String deployProcess() {
        Deployment deployment = repositoryService.createDeployment()
                .addClasspathResource(BPMN_FILE_PATH)
                .deploy();

        ProcessDefinition processDefinition = repositoryService.createProcessDefinitionQuery()
                .deploymentId(deployment.getId())
                .singleResult();

        log.info("Deploy process success! processDefinition={}",
                processDefinition.getId(),
                processDefinition.getName());

        return processDefinition.getId();
    }

    public String startProcess(String processDefinitionId) {

        ProcessInstance processInstance = runtimeService.startProcessInstanceById(processDefinitionId);

        log.info("Start process success! processDefinitionId={}; processInstanceId={}",
                processDefinitionId,
                processInstance.getId());

        return processInstance.getId();
    }

    public String completeUserTaskByAssignee(String assignee) {
        List<Task> taskList = taskService.createTaskQuery().taskAssignee(assignee).list();
        return completeTasks(assignee, taskList);
    }

    public String completeUserTaskByCandidateUser(String candidateUser) {
        List<Task> taskList = taskService.createTaskQuery().taskCandidateUser(candidateUser).list();
        return completeTasks(candidateUser, taskList);
    }

    private String completeTasks(String user, List<Task> taskList) {
        if (CollectionUtils.isEmpty(taskList)) {
            return "user [" + user + "] has no task todo";
        }

        StringBuilder sb = new StringBuilder();

        for (Task task : taskList) {
            String taskId = task.getId();
            taskService.complete(taskId);
            sb.append("task[")
                    .append(taskId)
                    .append("] is complete by ")
                    .append(user)
                    .append('\n');
        }

        return sb.toString();
    }
}
```

## 4.7 CreateSqlUtils

```Java
package org.liuyehcf.flowable.utils;

import org.apache.commons.io.IOUtils;

import java.io.*;
import java.util.Arrays;
import java.util.List;

/**
 * @author hechenfeng
 * @date 2018/8/18
 */
public class CreateSqlUtils {

    private static final List<String> SQL_PATH_LIST = Arrays.asList(
            "org/flowable/common/db/create/flowable.mysql.create.common.sql",

            "org/flowable/idm/db/create/flowable.mysql.create.identity.sql",
            "org/flowable/identitylink/service/db/create/flowable.mysql.create.identitylink.sql",
            "org/flowable/identitylink/service/db/create/flowable.mysql.create.identitylink.history.sql",

            "org/flowable/variable/service/db/create/flowable.mysql.create.variable.sql",
            "org/flowable/variable/service/db/create/flowable.mysql.create.variable.history.sql",
            "org/flowable/job/service/db/create/flowable.mysql.create.job.sql",
            "org/flowable/task/service/db/create/flowable.mysql.create.task.sql",
            "org/flowable/task/service/db/create/flowable.mysql.create.task.history.sql",

            "org/flowable/db/create/flowable.mysql.create.engine.sql",

            "org/flowable/db/create/flowable.mysql.create.history.sql"
    );

    private static final String FILE_NAME = "create.sql";

    public static void createSqlFile(String targetPath) {
        File targetSqlFile;
        try {
            targetSqlFile = getSqlFile(targetPath);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        try (BufferedOutputStream outputStream = new BufferedOutputStream(new FileOutputStream(targetSqlFile))) {

            appendCreateDatabaseSql(outputStream);

            for (String sqlPath : SQL_PATH_LIST) {
                appendCreateTableSql(outputStream, sqlPath);
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private static File getSqlFile(String targetPath) throws IOException {
        if (targetPath == null) {
            throw new NullPointerException();
        }

        File targetDir = new File(targetPath);

        if (!targetDir.exists()) {
            throw new FileNotFoundException(targetPath + " is not exists");
        }

        File sqlFile = new File(targetDir.getAbsolutePath() + File.separator + FILE_NAME);

        if (sqlFile.exists() && !sqlFile.delete()) {
            throw new IOException("failed to delete file " + sqlFile.getAbsolutePath());
        } else if (!sqlFile.createNewFile()) {
            throw new IOException("failed to create file " + sqlFile.getAbsolutePath());
        }

        return sqlFile;
    }

    private static void appendCreateDatabaseSql(OutputStream outputStream) throws IOException {
        outputStream.write(("/**************************************************************/\n" +
                "/*    [START CREATING DATABASE]\n" +
                "/**************************************************************/\n").getBytes());

        outputStream.write("DROP DATABASE IF EXISTS `flowable`;\n".getBytes());
        outputStream.write("CREATE DATABASE `flowable`;\n".getBytes());
        outputStream.write("USE `flowable`;\n".getBytes());

        outputStream.write(("/**************************************************************/\n" +
                "/*    [END CREATING DATABASE]\n" +
                "/**************************************************************/\n").getBytes());

        outputStream.write("\n\n\n".getBytes());
    }

    private static void appendCreateTableSql(OutputStream outputStream, String fileClassPath) throws IOException {
        ClassLoader classLoader = Thread.currentThread().getContextClassLoader();

        String simpleFilePath = fileClassPath.substring(fileClassPath.lastIndexOf(File.separator) + 1).trim();

        InputStream inputStream = classLoader.getResourceAsStream(fileClassPath);

        outputStream.write(("/**************************************************************/\n" +
                "/*    [START]\n" +
                "/*  " + simpleFilePath + "\n" +
                "/**************************************************************/\n").getBytes());

        IOUtils.copy(inputStream, outputStream);
        outputStream.write("\n".getBytes());

        outputStream.write(("/**************************************************************/\n" +
                "/*    [END]\n" +
                "/*  " + simpleFilePath + "\n" +
                "/**************************************************************/\n").getBytes());

        outputStream.write("\n\n\n".getBytes());
        inputStream.close();
    }

    public static void main(String[] args) {
        createSqlFile("/Users/hechenfeng/Desktop");
    }

}
```

## 4.8 DemoController

```Java
package org.liuyehcf.flowable.web;

import org.liuyehcf.flowable.service.DemoService;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

/**
 * @author hechenfeng
 * @date 2018/7/25
 */
@RestController
@RequestMapping("/")
public class DemoController {

    @Resource
    private DemoService demoService;

    @RequestMapping("/process/deploy")
    @ResponseBody
    public String deployProcess() {
        String processDefinitionId = demoService.deployProcess();
        return "Deploy Succeeded, processDefinitionId=" + processDefinitionId + "\n";
    }

    @RequestMapping("/process/start")
    @ResponseBody
    public String startProcess(@RequestParam String processDefinitionId) {
        String processInstanceId = demoService.startProcess(processDefinitionId);
        return "Start Succeeded, processInstance=" + processInstanceId + "\n";
    }

    @RequestMapping("/userTask/completeByAssignee")
    @ResponseBody
    public String completeUserTaskByAssignee(@RequestParam String assignee) {
        return demoService.completeUserTaskByAssignee(assignee) + "\n";
    }

    @RequestMapping("/userTask/completeByCandidateUser")
    @ResponseBody
    public String completeUserTask(@RequestParam String candidateUser) {
        return demoService.completeUserTaskByCandidateUser(candidateUser) + "\n";
    }
}
```

# 5 Resource

## 5.1 application.properties

```properties
server.port=7001
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/flowable?autoReconnect=true&useSSL=false
spring.datasource.username=root
spring.datasource.password=xxx
```

## 5.2 logback.xml

```xml
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%-4relative [%thread] %-5level %logger{35} - %msg %n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```

## 5.3 sample.bpmn20.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://www.omg.org/spec/BPMN/20100524/MODEL"
             xmlns:flowable="http://flowable.org/bpmn"
             targetNamespace="http://www.flowable.org/processdef">

    <process id="process1" name="process1" isExecutable="true">
        <documentation>Example</documentation>

        <startEvent id="startEvent1">
            <extensionElements>
                <flowable:executionListener event="start" delegateExpression="${demoListener}"/>
            </extensionElements>
        </startEvent>

        <serviceTask id="serviceTask1" name="serviceTask1" flowable:async="true"
                     flowable:delegateExpression="${demoServiceTask}">
            <extensionElements>
                <flowable:field name="field1" stringValue="someValue1"/>

                <flowable:field name="field2">
                    <flowable:string><![CDATA[someValue2]]></flowable:string>
                </flowable:field>
                <flowable:taskListener event="create" delegateExpression="${demoListener}"/>
            </extensionElements>
        </serviceTask>

        <userTask id="userTask1" name="userTask1" flowable:assignee="tom">
            <extensionElements>
                <flowable:taskListener event="create" delegateExpression="${demoListener}"/>
            </extensionElements>
        </userTask>

        <userTask id="userTask2" name="userTask2" flowable:candidateUsers="bob,jerry">
            <extensionElements>
                <flowable:taskListener event="create" delegateExpression="${demoListener}"/>
            </extensionElements>
        </userTask>

        <userTask id="userTask3" name="userTask3" flowable:candidateUsers="jerry,lucy">
            <extensionElements>
                <flowable:taskListener event="create" delegateExpression="${demoListener}"/>
            </extensionElements>
        </userTask>

        <endEvent id="endEvent1">
            <extensionElements>
                <flowable:executionListener event="start" delegateExpression="${demoListener}"/>
            </extensionElements>
        </endEvent>

        <sequenceFlow id="flow1" sourceRef="startEvent1" targetRef="serviceTask1"/>
        <sequenceFlow id="flow2" sourceRef="serviceTask1" targetRef="userTask1"/>
        <sequenceFlow id="flow3" sourceRef="userTask1" targetRef="userTask2"/>
        <sequenceFlow id="flow4" sourceRef="userTask2" targetRef="userTask3"/>
        <sequenceFlow id="flow5" sourceRef="userTask3" targetRef="endEvent1"/>
    </process>
</definitions>
```

# 6 步骤

## 6.1 数据库初始化

__详细步骤如下__

1. 首先执行`CreateSqlUtils`中的`main`函数，创建`sql文件`
1. 执行命令`mysql -u root -p`登录数据库
1. 在`mysql`会话中执行`sql`文件：`source <yourDir>/create.sql`
* __至此，建库建表工作完成__

## 6.2 部署工作流

__部署工作流__

* [http://localhost:7001/process/deploy](http://localhost:7001/process/deploy)
* 显示`Deploy Succeeded, processDefinitionId=process1:2:6`

__启动工作流实例（将上面的`processDefinitionId`填入下方url中）__

* [http://localhost:7001/process/start?processDefinitionId=process1:2:6](http://localhost:7001/process/start?processDefinitionId=process1:2:6)
* 显示`Start Succeeded, processInstance=7`

__完成UserTask1__

* [http://localhost:7001//userTask/completeByAssignee?assignee=tom](http://localhost:7001//userTask/completeByAssignee?assignee=tom)
* 显示`task[13] is complete by tom`

__完成UserTask2__

* [http://localhost:7001//userTask/completeByCandidateUser?candidateUser=bob](http://localhost:7001//userTask/completeByCandidateUser?candidateUser=bob)
* 显示`task[17] is complete by bob`

__完成UserTask3__

* [http://localhost:7001//userTask/completeByCandidateUser?candidateUser=lucy](http://localhost:7001//userTask/completeByCandidateUser?candidateUser=lucy)
* 显示`task[23] is complete by lucy`

__日志如下__
```
74514 [http-nio-7001-exec-1] INFO  o.l.flowalbe.service.DemoService - Deploy process success! processDefinition=process1:1:3 
133034 [http-nio-7001-exec-2] INFO  o.l.flowalbe.service.DemoService - Deploy process success! processDefinition=process1:2:6 
270605 [http-nio-7001-exec-5] INFO  o.l.flowalbe.element.DemoListener - ExecutionListener is trigger. elementId=startEvent1 
270637 [http-nio-7001-exec-5] INFO  o.l.flowalbe.service.DemoService - Start process success! processDefinitionId=process1:2:6; processInstanceId=7 
270705 [SimpleAsyncTaskExecutor-1] INFO  o.l.f.element.DemoServiceTask - Filed injection succeeded. fieldName=field1 
270705 [SimpleAsyncTaskExecutor-1] ERROR o.l.f.element.DemoServiceTask - Filed injection failed. fieldName=field2 
270792 [SimpleAsyncTaskExecutor-1] INFO  o.l.flowalbe.element.DemoListener - TaskListener is trigger. taskName=userTask1; assignee=tom; candidateInfoList=[] 
322831 [http-nio-7001-exec-7] INFO  o.l.flowalbe.element.DemoListener - TaskListener is trigger. taskName=userTask2; assignee=null; candidateInfoList=[{"userId":"jerry"},{"userId":"bob"}] 
473009 [http-nio-7001-exec-10] INFO  o.l.flowalbe.element.DemoListener - TaskListener is trigger. taskName=userTask3; assignee=null; candidateInfoList=[{"userId":"jerry"},{"userId":"lucy"}] 
508793 [http-nio-7001-exec-2] INFO  o.l.flowalbe.element.DemoListener - ExecutionListener is trigger. elementId=endEvent1 
```

# 7 Test

## 7.1 DemoTest

__`@ContextHierarchy`将创建子容器，`EmbeddedDatabaseConfig`将会在子容器中加载，会覆盖父容器的同名Bean，通过这种方式来替换数据源的配置__

```Java
package org.liuyehcf.flowable.test;

import lombok.extern.slf4j.Slf4j;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.liuyehcf.flowable.service.DemoService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.ContextHierarchy;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import java.util.concurrent.TimeUnit;

@Slf4j
@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = {TestApplication.class})
@ContextHierarchy({
        @ContextConfiguration(classes = {EmbeddedDatabaseConfig.class})
})
public class DemoTest {

    @Autowired
    private DemoService demoService;

    @Test
    public void test() {
        String processDefinition = demoService.deployProcess();
        log.info("deployProcess succeeded. processDefinition={}", processDefinition);

        String processInstanceId = demoService.startProcess(processDefinition);
        log.info("startProcess succeeded. processInstanceId={}", processInstanceId);

        sleep(1);
        String message;

        message = demoService.completeUserTaskByAssignee("tom");
        log.info("completeUserTaskByAssignee. message={}", message);

        sleep(1);

        message = demoService.completeUserTaskByCandidateUser("bob");
        log.info("completeUserTaskByCandidateUser. message={}", message);

        sleep(1);

        message = demoService.completeUserTaskByCandidateUser("lucy");
        log.info("completeUserTaskByCandidateUser. message={}", message);
    }

    private static void sleep(int second) {
        try {
            TimeUnit.SECONDS.sleep(second);
        } catch (InterruptedException e) {
            // ignore
        }
    }
}
```

## 7.2 EmbeddedDatabaseConfig

配置了`H2 database`，即内存数据库来进行测试

```Java
package org.liuyehcf.flowable.test;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseBuilder;
import org.springframework.jdbc.datasource.embedded.EmbeddedDatabaseType;

import javax.sql.DataSource;

@Configuration
public class EmbeddedDatabaseConfig {

    @Bean
    public DataSource dataSource() {
        return new EmbeddedDatabaseBuilder()
                .setType(EmbeddedDatabaseType.H2)
                .build();
    }

    @Bean
    public DataSourceTransactionManager transactionManager() {
        return new DataSourceTransactionManager(dataSource());
    }

    @Bean
    public SqlSessionFactory sqlSessionFactory() throws Exception {
        SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
        sqlSessionFactoryBean.setDataSource(dataSource());
        return sqlSessionFactoryBean.getObject();
    }

}
```

## 7.3 TestApplication

```Java
package org.liuyehcf.flowable.test;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = "org.liuyehcf.flowable")
public class TestApplication {
    public static void main(String[] args) {
        SpringApplication.run(TestApplication.class, args);
    }
}
```

## 7.4 logback-test.xml

__Test中的`logback`的配置文件必须为`logback-test.xml`才能生效__

```xml
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%-4relative [%thread] %-5level %logger{35} - %msg %n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="STDOUT" />
    </root>
</configuration>
```

# 8 那些年我们一起踩过的坑

## 8.1 ServiceTask Field Injection

从上面的日志中，我们可以看到`DemoServiceTask`的`field2`注入失败，而`field1`与`field2`的唯一区别在于`field1`有`public`的`setter`方法

__情景还原__：

1. 一个`JavaDelegate`（`org.flowable.engine.delegate.JavaDelegate`）的实现类`DemoServiceTask`，该实现类包含了一个类型为`Expression（org.flowable.engine.common.api.delegate.Expression）`的字段`field2`，且该字段没有`public`的`setter`方法
1. 一个Spring AOP，拦截了该`DemoServiceTask`，AOP配置源码已经在之前的小节中给出

给定的`BPMN`文件也很简单，直接在xml文件中写入了`field2`的数值，`BPMN`文件源码在之前的小节已经给出

当运行后，执行到`DemoServiceTask.execute`方法时，`field2`是`null`。这就比较奇怪了，所有的配置看起来都没有问题。后来查阅[Flowable官方文档](https://www.flowable.org/docs/userguide/index.html#bpmnJavaServiceTask)，上面说，字段注入如果不提供`public`的`setter`方法，而仅仅只是提供`private`字段，可能会有`Security`的问题

为了验证上面的说法，本机DEBUG，验证的起点是`org.flowable.engine.impl.bpmn.behavior.ServiceTaskDelegateExpressionActivityBehavior`这个类的`execute`方法。最终调用到了`org.flowable.engine.common.impl.util.ReflectUtil`的`invokeSetterOrField`方法中

```Java
    public static void invokeSetterOrField(Object target, String name, Object value, boolean throwExceptionOnMissingField) {
        Method setterMethod = getSetter(name, target.getClass(), value.getClass());

        if (setterMethod != null) {
            invokeSetter(setterMethod, target, name, value);
            
        } else {
            Field field = ReflectUtil.getField(name, target);
            if (field == null) {
                if (throwExceptionOnMissingField) {
                    throw new FlowableIllegalArgumentException("Field definition uses unexisting field '" + name + "' on class " + target.getClass().getName());
                } else {
                    return;
                }
            }

            // Check if the delegate field's type is correct
            if (!fieldTypeCompatible(value, field)) {
                throw new FlowableIllegalArgumentException("Incompatible type set on field declaration '" + name
                        + "' for class " + target.getClass().getName()
                        + ". Declared value has type " + value.getClass().getName()
                        + ", while expecting " + field.getType().getName());
            }
            
            setField(field, target, value);
        }
    }

    public static void setField(Field field, Object object, Object value) {
        try {
            field.setAccessible(true);
            field.set(object, value);
        } catch (IllegalArgumentException e) {
            throw new FlowableException("Could not set field " + field.toString(), e);
        } catch (IllegalAccessException e) {
            throw new FlowableException("Could not set field " + field.toString(), e);
        }
    }
```

上述`setField`成功调用，说明`field2`字段设置成功了。__重点来了，这里的`object`(`setField`方法的第二个参数)，也就是目标对象，并不是`DemoServiceTask`的实例，而是一个`Cglib`的代理类，这个代理类同样包含了一个`field2`字段，因此`setField`仅仅设置了`Cglib`的代理类的`field2`字段而已。当执行到目标方法，也就是`DemoServiceTask`类的`execute`方法中时，我们取的是`DemoServiceTask`的`field2`字段，也就是说，`DemoServiceTask`根本无法取到那个设置到`Cglib`的代理类中去的`field2`字段__

__其实，这并不是什么`Security`造成的问题，而是AOP使用时的细节问题__

## 8.2 Test

__在测试方法中不要加`@Transactional`注解，由于工作流的执行是由工作流引擎完成的，并不是在当前测试方法中完成的，因此在别的线程无法拿到`Test方法所在线程`的`尚未提交的数据`__
