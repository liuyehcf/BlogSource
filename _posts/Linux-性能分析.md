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

# 1 perf

`perf`命令具体用法参考{% post_link Linux-常用命令 %}

## 1.1 cpu火焰图

**相关git项目**

* [FlameGraph](https://github.com/brendangregg/FlameGraph)

```sh
# 以99Hz的频率捕获指定进程的堆栈信息，捕获时长60s
# 该命令会在当前目录生成 perf.data 文件
perf record -F 99 -p <pid> -g -- sleep 60

# 解析 perf.data 文件
perf script > out.perf

# 生成火焰图
# 下面这两个脚本来自FlameGraph项目，我的安装目录是/opt/FlameGraph
/opt/FlameGraph/stackcollapse-perf.pl out.perf > out.folded
/opt/FlameGraph/flamegraph.pl out.folded > out.svg
```

### 1.1.1 java-cpu火焰图

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

# 解析 perf.data 文件
sudo perf script > out.perf

# 生成火焰图
# 下面这两个脚本来自FlameGraph项目，我的安装目录是/opt/FlameGraph
/opt/FlameGraph/stackcollapse-perf.pl out.perf > out.folded
/opt/FlameGraph/flamegraph.pl out.folded > out.svg
```

## 1.2 参考

* [工欲性能调优，必先利其器（2）- 火焰图](https://pingcap.com/zh/blog/flame-graph)
* [CPU Flame Graphs](https://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html)
* [Java 火焰图](https://www.jianshu.com/p/bea2b6a1eb6e)

# 2 VTune

**大致步骤：**

1. 在`MacOS`、`Windows`、`Linux`上安装`Vtune-Profile`
2. 假设安装目录是`/opt/intel/oneapi`，将`/opt/intel/oneapi/vtune/2021.8.0/target/linux`下的压缩包拷贝到目标机器上并解压

```sh
vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 -d 60 a.out
vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 -target-pid=123 -d 60
```

## 2.1 参考

* [Intel® VTune™ Profiler User Guide](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top.html)
* [Intel® VTune™ Profiler User Guide - Run Command Line Analysis](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top/command-line-interface/running-command-line-analysis.html)
* [Intel® VTune™ Profiler Performance Analysis Cookbook](https://software.intel.com/content/www/us/en/develop/documentation/vtune-cookbook/top/methodologies/top-down-microarchitecture-analysis-method.html)
* [《A Top-Down Method for Performance Analysis and Counters Architecture》阅读笔记](https://andrewei1316.github.io/2020/12/20/top-down-performance-analysis/)

# 3 参考

* [在Linux下做性能分析1：基本模型](https://zhuanlan.zhihu.com/p/22124514)
* [在Linux下做性能分析2：ftrace](https://zhuanlan.zhihu.com/p/22130013)
* [在Linux下做性能分析3：perf](https://zhuanlan.zhihu.com/p/22194920)
* [Linux下做性能分析4：怎么开始](https://zhuanlan.zhihu.com/p/22202885)
* [Linux下做性能分析5：Amdahl模型](https://www.zhihu.com/column/p/22289770)
* [Linux下做性能分析6：理解一些基础的CPU执行模型](https://zhuanlan.zhihu.com/p/22386524)
* [Linux下做性能分析7：IO等待问题](https://zhuanlan.zhihu.com/p/22389927)
* [Linux下做性能分析8：Docker环境](https://zhuanlan.zhihu.com/p/22409793)
