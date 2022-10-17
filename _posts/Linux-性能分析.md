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

## 1.1 event

![perf_events_map](/images/Linux-性能分析/perf_events_map.png)

**`perf list`可以查看当前环境支持的所有`event`。`event`可以分为`Software event`以及`Tracepoint event`两大类**

* `Software event`：需要采样的`event`。比如需要通过`perf record -F 99`指定采样频率
* `Tracepoint event`：不需要采样的`event`，有其固定的埋点，执行到了就会统计。`Tracepoint event`又可细分为许多类别

## 1.2 参考

* [perf Examples](https://www.brendangregg.com/perf.html)

# 2 Flame Graph

## 2.1 CPU Flame Graph

[Flame Graphs](https://www.brendangregg.com/flamegraphs.html)

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

## 2.2 CPU Flame Graph for Java

[Java Flame Graphs](https://www.brendangregg.com/blog/2014-06-12/java-flame-graphs.html)

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

## 2.3 Cache Miss Flame Graph

## 2.4 CPI Flame Graph

[CPI Flame Graphs: Catching Your CPUs Napping](https://www.brendangregg.com/blog/2014-10-31/cpi-flame-graphs.html)

## 2.5 小结

* `perf record`默认采集的`event`是`cycles`，因此这种方式做出来的就是`CPU`火焰图
* `perf record`配合`-e`参数，指定`event`类型，可以做出任意事件的火焰图

## 2.6 参考

* [工欲性能调优，必先利其器（2）- 火焰图](https://pingcap.com/zh/blog/flame-graph)
* [CPU Flame Graphs](https://www.brendangregg.com/FlameGraphs/cpuflamegraphs.html)
* [Java 火焰图](https://www.jianshu.com/p/bea2b6a1eb6e)
* [Linux 性能诊断 perf使用指南](https://developer.aliyun.com/article/65255#slide-17)

# 3 [Off-CPU Analysis](https://www.brendangregg.com/offcpuanalysis.html)

**分析工具：**

* `>= Linux 4.8`：`eBPF`
    * 要求`Linux`版本至少是`4.8`
    * 开销更小，因为它只捕获和转换独特的堆栈
    * [Linux eBPF Off-CPU Flame Graph](https://www.brendangregg.com/blog/2016-01-20/ebpf-offcpu-flame-graph.html)
* `< Linux 4.8`：针对不同的`blocking`类型（`I/O`，`scheduler`，`lock`），需要使用不同的分析工具，例如`SystemTap`、`perf event logging`
    * [Linux perf_events Off-CPU Time Flame Graph](https://www.brendangregg.com/blog/2015-02-26/linux-perf-off-cpu-flame-graph.html)
* 其他工具
    * `time`：一个非常简单的统计工具
        * `real`：整体耗时
        * `user`：用户态的`CPU`时间
        * `sys`：内核态的`CPU`时间
        * `real - user - sys`：`off-CPU`时间
    * `brpc`

**其他参考：**

* [Off-CPU Flame Graphs](https://www.brendangregg.com/FlameGraphs/offcpuflamegraphs.html)

## 3.1 Using perf

```sh
# 启用调度的tracepoint，需要在root账号下执行，一般账号sudo可能执行不了
echo 1 > /proc/sys/kernel/sched_schedstats

sudo perf record \
    -e sched:sched_stat_sleep \
    -e sched:sched_switch \
    -e sched:sched_process_exit \
    -a -g \
    -o perf.data.raw \
    sleep 1

# 其中，-s 参数主要用于合并 sched_stat 以及 sched_switch 这两个事件，用于生成对应的睡眠时间
sudo perf inject -v -s \
    -i perf.data.raw \
    -o perf.data

sudo perf script -F comm,pid,tid,cpu,time,period,event,ip,sym,dso | \
    sudo awk '
    NF > 4 { exec = $1; period_ms = int($5 / 1000000) } 
    NF > 1 && NF <= 4 && period_ms > 0 { print $2 } 
    NF < 2 && period_ms > 0 { printf "%s\n%d\n\n", exec, period_ms }
    ' | \
    sudo /opt/FlameGraph/stackcollapse.pl | \
    sudo /opt/FlameGraph/flamegraph.pl --countname=ms --title="Off-CPU Time Flame Graph" --colors=io > offcpu.svg
```

# 4 VTune

**大致步骤：**

1. 在个人电脑上（`MacOS`、`Windows`、`Linux`均可）安装`Vtune-Profile`
    * 我的`MacOS`系统版本是`Monterey 12.0.1`，这个版本无法远程Linux机器。如何解决？在目标Linux系统上安装`X Window System`、`Vtune-Profile`，通过`vnc`或者`nx`等远程桌面软件登录目标Linux机器，再通过`vtune-gui`打开`Vtune-Profile`，并分析本地的程序
1. 在目标Linux机器上安装`Vtune-Profile-Target`（采集数据所需的软件包）：
    * 自动安装：`Configure Analysis` -> `Remote Linux(ssh)` -> `Deploy`
    * 手动安装：假设`Vtune-Profile`安装目录是`/opt/intel/oneapi`，将`/opt/intel/oneapi/vtune/2021.8.0/target/linux`下的压缩包拷贝到目标机器上并解压
* `Vtune-Profile`和`Vtune-Profile-Target`可以在同一台机器，也可以在不同机器

**如何通过命令行采集数据：**

```sh
vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 -d 60 a.out
vtune -collect hotspots -knob sampling-mode=hw -knob sampling-interval=0.5 -target-pid=123 -d 60
```

## 4.1 参考

* [Intel® VTune™ Profiler User Guide](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top.html)
* [Intel® VTune™ Profiler User Guide - Run Command Line Analysis](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top/command-line-interface/running-command-line-analysis.html)
* [Intel® VTune™ Profiler User Guide - Window: Bottom-up](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top/reference/user-interface-reference/window-bottom-up.html)
* [Intel® VTune™ Profiler User Guide - Window: Caller/Callee](https://www.intel.com/content/www/us/en/develop/documentation/vtune-help/top/reference/user-interface-reference/window-caller-callee.html)
* [Intel® VTune™ Profiler Performance Analysis Cookbook](https://software.intel.com/content/www/us/en/develop/documentation/vtune-cookbook/top/methodologies/top-down-microarchitecture-analysis-method.html)
* [《A Top-Down Method for Performance Analysis and Counters Architecture》阅读笔记](https://andrewei1316.github.io/2020/12/20/top-down-performance-analysis/)

# 5 Chrome tracing view

https://github.com/StarRocks/starrocks/pull/7649

# 6 [pcm](https://github.com/opcm/pcm)

`Processor Counter Monitor, pmc`包含如下工具：

* `pcm`：最基础监控工具
* `pcm-sensor-server`：在本地提供一个`Http`服务，以`JSON`的格式返回`metrics`
* `pcm-memory`：用于监控内存带宽
* `pcm-latency`：用于监控`L1 cache miss`以及`DDR/PMM memory latency`
* `pcm-pcie`：用于监控每个插槽的`PCIe`带宽
* `pcm-iio`：用于监控每个`PCIe`设备的`PCIe`带宽
* `pcm-numa`：用于监控本地以及远程的内存访问
* `pcm-power`
* `pcm-tsx`
* `pcm-core/pmu-query`
* `pcm-raw`
* `pcm-bw-histogram`

# 7 [sysbench](https://github.com/akopytov/sysbench)

**示例：**

* `sysbench --test=memory --memory-block-size=1M --memory-total-size=10G --num-threads=1 run`
* `sysbench --test=cpu run`
* `sysbench --test=fileio --file-test-mode=seqwr run`
* `sysbench --test=threads run`
* `sysbench --test=mutex run`

# 8 Tips

1. **性能分析需要重点关注的指标**
    * `Cycles`
    * `IPC`
    * `Instructions`
    * `L1 Miss`
    * `LLC Miss, Last Level Cache`
    * `Branch Miss`
    * `Contention`

# 9 参考

* [perf Examples](https://www.brendangregg.com/perf.html)
* [在Linux下做性能分析1：基本模型](https://zhuanlan.zhihu.com/p/22124514)
* [在Linux下做性能分析2：ftrace](https://zhuanlan.zhihu.com/p/22130013)
* [在Linux下做性能分析3：perf](https://zhuanlan.zhihu.com/p/22194920)
* [Linux下做性能分析4：怎么开始](https://zhuanlan.zhihu.com/p/22202885)
* [Linux下做性能分析5：Amdahl模型](https://www.zhihu.com/column/p/22289770)
* [Linux下做性能分析6：理解一些基础的CPU执行模型](https://zhuanlan.zhihu.com/p/22386524)
* [Linux下做性能分析7：IO等待问题](https://zhuanlan.zhihu.com/p/22389927)
* [Linux下做性能分析8：Docker环境](https://zhuanlan.zhihu.com/p/22409793)
