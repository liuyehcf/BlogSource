---
title: Linux-性能分析
date: 2019-10-27 18:44:58
tags: 
- 摘录
categories: 
- Linux
---

**阅读更多**

<!--more-->

# 1 概述

# 2 cpu火焰图

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

# 3 参考

* [在Linux下做性能分析1：基本模型](https://zhuanlan.zhihu.com/p/22124514)
* [在Linux下做性能分析2：ftrace](https://zhuanlan.zhihu.com/p/22130013)
* [在Linux下做性能分析3：perf](https://zhuanlan.zhihu.com/p/22194920)
* [Linux下做性能分析4：怎么开始](https://zhuanlan.zhihu.com/p/22202885)
* [Linux下做性能分析5：Amdahl模型](https://www.zhihu.com/column/p/22289770)
* [Linux下做性能分析6：理解一些基础的CPU执行模型](https://zhuanlan.zhihu.com/p/22386524)
* [Linux下做性能分析7：IO等待问题](https://zhuanlan.zhihu.com/p/22389927)
* [Linux下做性能分析8：Docker环境](https://zhuanlan.zhihu.com/p/22409793)
* [Java 火焰图](https://www.jianshu.com/p/bea2b6a1eb6e)
