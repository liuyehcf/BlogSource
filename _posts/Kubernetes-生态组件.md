---
title: Kubernetes-生态组件
date: 2019-10-13 16:43:09
tags: 
- 摘录
categories: 
- Kubernetes
---

__阅读更多__

<!--more-->

# 1 [local-path-provisioner](https://github.com/rancher/local-path-provisioner)

# 2 [Rancher](https://github.com/rancher/rancher)

# 3 Helm

```sh
# 创建一个char模板，其中charName是对应的名称
helm create <charName>

# 渲染，模板，可以查看渲染后的输出格式
helm template <charName>
```

## 3.1 参考

* [Helm 从入门到实践](https://www.jianshu.com/p/4bd853a8068b)
* [Helm模板文件chart编写语法详解](https://blog.51cto.com/qujunorz/2421328)
* [Heml中文文档](https://whmzsu.github.io/helm-doc-zh-cn/chart_template_guide/control_structures-zh_cn.html)
* [Helm教程](https://www.cnblogs.com/lyc94620/p/10945430.html)
* [Error: no available release name found](https://www.jianshu.com/p/5eb3ee63a250)

# 4 istio

## 4.1 参考

* [理解 Istio Service Mesh 中 Envoy 代理 Sidecar 注入及流量劫持](https://jimmysong.io/posts/envoy-sidecar-injection-in-istio-service-mesh-deep-dive/?from=groupmessage&isappinstalled=0)
