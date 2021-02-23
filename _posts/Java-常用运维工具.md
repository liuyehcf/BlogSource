---
title: Java-常用运维工具
date: 2019-10-27 18:44:58
tags: 
- 摘录
categories: 
- Java
- DevOps
---

**阅读更多**

<!--more-->

# 1 cpu火焰图

**相关git项目**

* [perf-map-agent](https://github.com/jvm-profiling-tools/perf-map-agent)
* [FlameGraph](https://github.com/brendangregg/FlameGraph)

```sh
# perf record 统计cpu使用情况，执行后会生成文件 perf.data
# -F: 指定频率
# -a: 统计所有进程的cpu使用情况
# -g: 开启gragh模式
sudo perf record -F 90 -a -g -- sleep 300

# 下载并安装perf-map-agent
# 安装依赖cmake，openjdk（只有jre是不够的）
perf-map-agent/bin/create-java-perf-map.sh <pid>

sudo perf script > out.perf

# 下载FlameGraph
FlameGraph/stackcollapse-perf.pl out.perf > out.folded

FlameGraph/flamegraph.pl out.folded > out.svg
```

## 1.1 参考

* [Java 火焰图](https://www.jianshu.com/p/bea2b6a1eb6e)

