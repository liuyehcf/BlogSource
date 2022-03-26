---
title: SonarQube-Demo
date: 2022-03-26 23:22:38
tags: 
- 摘录
categories: 
- Java
- Framework
- Analysis
---

**阅读更多**

<!--more-->

# 1 使用

[Quick-Start](https://docs.sonarqube.org/latest/setup/get-started-2-minutes/)

```sh
docker run -d --name sonarqube -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true -p 9000:9000 sonarqube:latest
```

[SonarScanner for Maven](https://docs.sonarqube.org/latest/analysis/scan/sonarscanner-for-maven/)

```sh
mvn clean verify sonar:sonar -DskipTests -Dsonar.login=admin -Dsonar.password=xxxx
```
