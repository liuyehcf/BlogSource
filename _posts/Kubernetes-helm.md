---
title: Kubernetes-helm
date: 2020-01-02 13:49:16
tags: 
- 摘录
categories: 
- Kubernetes
---

**阅读更多**

<!--more-->

# 1 helm语法

1. [内建对象](https://helm.sh/docs/topics/chart_template_guide/builtin_objects/)

# 2 Tips

从运行时提取信息，并注入到环境变量中

```yaml
containers:
- env:
  - name: NODE_IP
    valueFrom:
      fieldRef:
        fieldPath: status.hostIP
```

环境变量相互引用

```yaml
containers:
  env:
  - name: DB_URL_HOSTNAME               // part 1
    valueFrom:
      secretKeyRef:
        name: my-database-credentials
        key: hostname

  - name: DB_URL_PORT                   // part 2
    valueFrom:
      secretKeyRef:
        name: my-database-credentials
        key: port

  - name: DB_URL_DBNAME                 // part 3
    valueFrom:
      secretKeyRef:
        name: my-database-credentials
        key: database

  - name: DATABASE_URL                  // combine
    value: jdbc:postgresql:$(DB_URL_HOSTNAME):$(DB_URL_PORT)/$(DB_URL_DBNAME)

```

# 3 参考

* [helm doc](https://helm.sh/docs/)
* [Helm 从入门到实践](https://www.jianshu.com/p/4bd853a8068b)
* [Helm模板文件chart编写语法详解](https://blog.51cto.com/qujunorz/2421328)
* [Heml中文文档](https://whmzsu.github.io/helm-doc-zh-cn/chart_template_guide/control_structures-zh_cn.html)
* [Helm教程](https://www.cnblogs.com/lyc94620/p/10945430.html)
* [Error: no available release name found](https://www.jianshu.com/p/5eb3ee63a250)
* [relm repo](https://github.com/helm/charts/tree/master/incubator)
* [https://stackoverflow.com/questions/54173581/combining-multiple-k8s-secrets-into-an-env-variable](https://stackoverflow.com/questions/54173581/combining-multiple-k8s-secrets-into-an-env-variable)
