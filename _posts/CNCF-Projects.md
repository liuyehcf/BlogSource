---
title: CNCF-Projects
date: 2021-04-06 19:58:15
tags: 
- 摘录
categories: 
- Cloud Native
---

**阅读更多**

<!--more-->

# 1 Overview

[Graduated and incubating projects](https://www.cncf.io/projects/)

# 2 grafana 

## 2.1 prometheus

![grafana-prometheus-node_exporter-architecture](/images/CNCF-Projects/grafana-prometheus-node_exporter-architecture.webp)

### 2.1.1 Step1: Install prometheus

Download package from [here](https://prometheus.io/download/).

```sh
# Default port is 9090
# change the prometheus.yml of config `scrape_configs.job_name(prometheus).static_configs.targets` to 19090
./prometheus --web.listen-address="0.0.0.0:19090"
```

**Tips:**

* `up`: Show all up machines.
* `http://localhost:19090/metrics`: List all metrics in text.

### 2.1.2 Step2: Install node-exporter

Download package from [here](https://prometheus.io/download/).

```sh
# Default port is 9100
./node_exporter --web.listen-address=":19100"
```

Then add the following config to the `scrape_configs` part of `prometheus.yml` and restart prometheus.

```sh
  - job_name: 'node_exporter'

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: ['localhost:19100'] # Adjust the port if your node_exporter listens on a different one.
```

### 2.1.3 Step3: Install grafana

Install grafa following the guide [here](https://grafana.com/grafana/download?pg=get&plcmt=selfmanaged-box1-cta1).

The grafana will be started at the default port `3000`.

Add datasource prometheus, and config the address.

Then search the grafana templates from [here](https://grafana.com/grafana/dashboards) which you can import into your cluster directly.

### 2.1.4 Useful dashboard

1. `1860`: Node Exporter Full

## 2.2 参考

* [Getting started with Prometheus Grafana and Node exporter - Part 1](https://www.youtube.com/watch?v=peH95b16hNI&list=PLm6CFQTqBnAkUzE2efK-4R9QiwQ1koTAB&index=3&t=223s)
* [prometheus download](https://prometheus.io/download/)
* https://www.cnblogs.com/dudu/p/12146344.html
* [kubernetes1.18安装kube-prometheus](https://blog.csdn.net/guoxiaobo2010/article/details/106532357/)
* [grafana templates](https://grafana.com/grafana/dashboards)
* [Prometheus核心组件](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/quickstart/prometheus-arch)

# 3 istio 

## 3.1 参考

* [istio doc](https://istio.io/latest/docs/)
* [Istio：xDS协议解析](https://blog.csdn.net/fly910905/article/details/104036296)
* [Service Mesh和API Gateway关系深度探讨](https://www.servicemesher.com/blog/service-mesh-and-api-gateway/)
* [Istio 中的 Sidecar 注入及透明流量劫持过程详解](https://www.servicemesher.com/blog/sidecar-injection-iptables-and-traffic-routing/)
