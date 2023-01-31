---
title: System-Issue-Logs
date: 2020-11-05 09:58:52
tags: 
- 原创
categories: 
- bleshooting
---

**阅读更多**

<!--more-->

# 1 kubectl get nodes提示tls handshake timeout

抓包结果如下

![1-1](/images/System-Issue-Logs/1-1.png)

我们可以发现如下信息

1. tcp三次握手阶段的交互都是正常的，说明网络是通畅的
1. `seq=3566914759`的这个数据包第一次发送的时候，`len=2015`，且IP数据报头部的DF标志位置位，即不可分片。紧随其后的是多次重传，重传包的大小是`1448`

那么这个数据包发送失败的原因可能就是当前主机的mtu要远高于链路的最小mtu。调小mtu后，再次执行`kubectl get nodes`，能够正常返回结果

如何检查链路的mtu

```sh
# 发送大小是1460 + (28)字节，禁止路由器拆分数据包
ping -s 1460 -M do www.baidu.com
```

如何修改mtu（临时生效，重启后会复原），若要永久生效，那么可以通过nmtui或者nmcli配置相应的网卡连接信息

```sh
IF_NAME="eno1"

echo 1500 > /sys/class/net/${IF_NAME}/mtu
```

# 2 某个cpu的软中断si占用比例特别高

**场景复现：用wget下载一个大文件，使用`top`命令查看每个cpu的使用详情，可以发现cpu1的软中断（si）数值特别高，而其他cpu的该数值基本为0，如下图**

![2-1](/images/System-Issue-Logs/2-1.png)

机器的外网网卡为`enp0s3`，可以通过`/proc/interrupts`找到该网卡设备对应的软中断号

```sh
cat /proc/interrupts | grep 'enp0s3'

#-------------------------↓↓↓↓↓↓-------------------------
 19:         11     271072          0          0   IO-APIC-fasteoi   ehci_hcd:usb1, enp0s3
#-------------------------↑↑↑↑↑↑-------------------------
```

可以看到，该网卡只有一个队列，且该队列的软中断号为`19`，可以通过`/proc/irq/19/smp_affinity`或`/proc/irq/19/smp_affinity_list`文件获取该中断号对应的cpu亲和性配置

对于`/proc/irq/{中断号}/smp_affinity`文件而言，其内容是cpu亲和性掩码

* 假设CPU的序号从0开始，`cpu0 = 1`，`cpu1 = cpu0 * 2`，`cpu2 = cpu1 * 2`，...
* 把该中断号亲和的cpu的数值全部相加，其结果以16进制表示，就是亲和性掩码

```
          Binary       Hex 
  CPU 0    0001         1 
  CPU 1    0010         2
  CPU 2    0100         4
  CPU 3    1000         8
+
  -----------------------
  both     1111         f
```

对于`/proc/irq/{中断号}/smp_affinity_list`文件而言，会直接列出该中断号亲和的所有cpu序号

**查看中断号19的亲和性配置**

```sh
cat /proc/irq/19/smp_affinity

#-------------------------↓↓↓↓↓↓-------------------------
2
#-------------------------↑↑↑↑↑↑-------------------------

cat /proc/irq/19/smp_affinity_list

#-------------------------↓↓↓↓↓↓-------------------------
1
#-------------------------↑↑↑↑↑↑-------------------------
```

**可以发现，该中断只亲和cpu1，这与我们的观测结果是一致的**

**接下来，尝试修改亲和性，想要达到的结果是：所有cpu都能够处理中断号为19的中断**

```sh
# 1 + 2 + 4 + 8 = 15 = f
echo f > /proc/irq/19/smp_affinity
```

**再次用top命令观察，发现cpu0的si数值特别高，而其他的cpu基本为0。这并不符合我们的预期。可能原因：对于网卡设备的某个队列而言，即便配置了多个亲和cpu，但是只有序号最小的cpu会生效**

![2-2](/images/System-Issue-Logs/2-2.png)

**验证刚才这个猜想，将亲和性配置为cpu2和cpu3，预期结果为：只有cpu2的si值特别高，而其他cpu基本为0**

```sh
# 4 + 8 = 12 = c
echo c > /proc/irq/19/smp_affinity
```

**用top命令观察，发现cpu2的si数值特别高，而其他的cpu基本为0，符合我们的猜想**

![2-3](/images/System-Issue-Logs/2-3.png)

**结论：**

1. 对于单队列的网卡而言，设置亲和多个cpu是无效的，只有编号最小的cpu会处理中断请求
1. 对于多队列的网卡而言，可以单独配置每个队列亲和的cpu，以达到更高的性能

**问题：`irq, Interrupt Request`是指硬件中断，为什么会导致`si`偏高，不应该是`hi`么**

* [软中断会吃掉你多少CPU？](https://zhuanlan.zhihu.com/p/80513852)
* [网卡软中断过高问题优化总结](https://blog.csdn.net/yue530tomtom/article/details/76216503)
* **硬中断与软中断之区别与联系？**
    1. 硬中断是有外设硬件发出的，需要有中断控制器之参与。其过程是外设侦测到变化，告知中断控制器，中断控制器通过`CPU`或内存的中断脚通知`CPU`，然后硬件进行程序计数器及堆栈寄存器之现场保存工作（引发上下文切换），并根据中断向量调用硬中断处理程序进行中断处理
    1. 软中断则通常是由硬中断处理程序或者进程调度程序等软件程序发出的中断信号，无需中断控制器之参与，直接以一个`CPU`指令之形式指示`CPU`进行程序计数器及堆栈寄存器之现场保存工作（亦会引发上下文切换），并调用相应的软中断处理程序进行中断处理（即我们通常所言之系统调用）
    1. 硬中断直接以硬件的方式引发，处理速度快。软中断以软件指令之方式适合于对响应速度要求不是特别严格的场景
    1. 硬中断通过设置`CPU`的屏蔽位可进行屏蔽，软中断则由于是指令之方式给出，不能屏蔽
    1. **硬中断发生后，通常会在硬中断处理程序中调用一个软中断来进行后续工作的处理**
    1. 硬中断和软中断均会引起上下文切换（进程/线程之切换），进程切换的过程是差不多的

## 2.1 参考

* [软中断过高问题如何解决](https://blog.csdn.net/rainharder/article/details/73198010)
* [软中断竟然是可一个CPU使劲造？](https://zhuanlan.zhihu.com/p/80619249)

# 3 du/df看到的大小不同

**区别**

* du是递归统计某个目录下所有子文件和子目录的大小，可以横跨多个文件系统
* df只是读取目录所在文件系统的`super block`，无法横跨多个文件系统

因此，这两个命令输出的结果不相同是在情理之中的，可能情况包括

1. 目录并非挂载点，例如`/root`目录一般来说就是`/`目录下的一个普通目录，如果执行`df -h /root`，结果等效于`df -h /`
1. 子目录作为另一个文件系统的挂载点，`df`不会统计这个子文件系统，但是`du`会统计
1. A进程在读某个文件F，B进程将文件F强制删除。此时`du`会发现空间减小，但是`df`仍然是删除之前的大小，因为此时`inode`尚未释放

# 4 no space left on device（mount namespace）

最近项目上碰到一个非常奇怪的问题：执行`docker cp`拷贝容器内的文件或者执行`docker run`运行一个新的容器，都会报`no space left on device`这个错误

但是通过`df -h`以及`df -ih`查看，磁盘空间以及`inode`，剩余资源都非常充足

查阅大量资料后，在[[WIP] Fix mount loop on "docker cp" #38993](https://github.com/moby/moby/pull/38993)中找到了问题的根本原因：**问题容器将主机的根目录挂载到了容器内，造成了挂载视图的扩散，每次执行docker cp都会将容器视图下的mount数量翻倍（内核默认的mount数量是10万，可以通过`fs.mount-max`参数进行设置）**

**复现方式如下**

```sh
# 启动容器，将宿主机的根目录挂载到容器内
docker run --name test -d -v /:/rootfs busybox sleep 3d

# 查看容器视图下的mount数量
docker exec test wc -l /proc/self/mountinfo

#-------------------------↓↓↓↓↓↓-------------------------
182 /proc/self/mountinfo
#-------------------------↑↑↑↑↑↑-------------------------

# 执行5次docker cp操作
docker cp test:/etc/resolv.conf /tmp/resolv.conf
docker cp test:/etc/resolv.conf /tmp/resolv.conf
docker cp test:/etc/resolv.conf /tmp/resolv.conf
docker cp test:/etc/resolv.conf /tmp/resolv.conf
docker cp test:/etc/resolv.conf /tmp/resolv.conf

# 再次查看容器视图下的mount数量
docker exec test wc -l /proc/self/mountinfo

#-------------------------↓↓↓↓↓↓-------------------------
13309 /proc/self/mountinfo
#-------------------------↑↑↑↑↑↑-------------------------
```

**如何解决：`mount namespace`支持多种不同的传播级别，可以通过命令（`mount / --make-private`）将根目录的传播级别设置为`private`，这样就可以避免两个命名空间的挂载视图相互污染**

## 4.1 参考

* [[WIP] Fix mount loop on "docker cp" #38993](https://github.com/moby/moby/pull/38993)
* [Linux Namespace系列（04）：mount namespaces (CLONE_NEWNS)](https://segmentfault.com/a/1190000006912742)
* [黄东升: mount namespace和共享子树](https://cloud.tencent.com/developer/article/1518101)

# 5 文件系统inode被docker占满

项目中使用的docker版本是19.x，`storage driver`用的是`overlay2`，`/var/lib/docker/overlay2`目录下有几万条数据（大部分目录对应的容器早已退出），可以通过下面这个脚本清理

```sh
#!/bin/bash

# 1. 找出所有容器的overlayId，包括正在运行的和已停止的容器
ALL_CONTAINER_IDS=( $(docker ps -aq) )
TOTAL_CONTAINER_NUM=${#ALL_CONTAINER_IDS[@]}
declare -A VALID_OVERLAY_IDS
for ((i=0;i<${TOTAL_CONTAINER_NUM};i++)) 
do
    CONTAINER_ID=${ALL_CONTAINER_IDS[i]}
    MERGED_DIRECTORY=$(docker inspect ${CONTAINER_ID} -f '{{.GraphDriver.Data.MergedDir}}')
    if [ -n "${MERGED_DIRECTORY}" ]; then
        # 除去最后的merged
        OVERLAY_ID=${MERGED_DIRECTORY%/merged}
        # 除去开头的/var/lib/docker/overlay2/
        OVERLAY_ID=${OVERLAY_ID#/var/lib/docker/overlay2/}

        VALID_OVERLAY_IDS[${OVERLAY_ID}]=${CONTAINER_ID}
        
        echo "$((${i}+1))/${TOTAL_CONTAINER_NUM}: collecting valid overlay_id '${OVERLAY_ID}'"
    fi
done

# 2. 找出所有泄漏的容器的overlayId，并删除
ALL_INIT_DIRECTORIES=( $(ls -1 /var/lib/docker/overlay2 | grep -- '-init') )
TOTAL_OVERLAY_NUM=${#ALL_INIT_DIRECTORIES[@]}

echo -e "\n\n\033[31mvalid overlay size=${#ALL_CONTAINER_IDS[@]}, all overlay size=${TOTAL_OVERLAY_NUM}\033[0m\n\n"
sleep 3

for ((i=0;i<${TOTAL_OVERLAY_NUM};i++)) 
do  
    # 除去最后的-init
    OVERLAY_ID=${ALL_INIT_DIRECTORIES[i]%-init}
    # 除去开头的/var/lib/docker/overlay2/
    OVERLAY_ID=${OVERLAY_ID#/var/lib/docker/overlay2/}

    CONTAINER_ID=${VALID_OVERLAY_IDS[${OVERLAY_ID}]}
    if [ -n "${CONTAINER_ID}" ]; then
        echo "$((${i}+1))/${TOTAL_OVERLAY_NUM}: overlayId '${OVERLAY_ID}' is related to exist container '${CONTAINER_ID}', do nothing"
    else
        echo "$((${i}+1))/${TOTAL_OVERLAY_NUM}: overlayId '${OVERLAY_ID}' is isolated, now remove related directories"
        rm -rf /var/lib/docker/overlay2/${OVERLAY_ID}
        rm -rf /var/lib/docker/overlay2/${OVERLAY_ID}-init
    fi
done
```

## 5.1 参考

* [Docker does not free up disk space after container, volume and image removal](https://github.com/moby/moby/issues/32420)

# 6 系统内存彪高

机器的规格为`4c8g`

首先通过`free -h`查看系统内存使用情况，发现`available`的大小为`730M`，内存基本被占满

然后，通过`ps aux | awk '{mem+=$6}END{print mem/1024/1024 G}'`查看所有用户态进程的内存占用情况，发现总和只有`4.16G`

由于我们的应用是个接入层的应用，系统上会存在大量的连接，可以通过如下手段继续分析

1. `cat /proc/net/sockstat`或者`ss -s`查看socket的使用情况
1. `dmesg`看下是否有`socket out of memory`
1. 查看tcp的一些配置信息，包括
    * `/proc/sys/net/ipv4/tcp_rmem`
    * `/proc/sys/net/ipv4/tcp_wmem`
    * `/proc/sys/net/ipv4/tcp_mem`
1. `cat /proc/sys/fs/file-nr`查看系统总共使用了多少文件描述符
    * 第一列：已分配文件句柄的数目（包括socket）
    * 第二列：已分配未使用文件句柄的数目
    * 第三列：文件句柄的最大数目（也可以通过`cat /proc/sys/fs/file-max`查看）
1. `slabtop`查看内核占用的内存大小

## 6.1 参考

* [linux服务器性能分析_TCP内存](http://leeqx.github.io/2019/03/22/linux%E6%9C%8D%E5%8A%A1%E5%99%A8%E6%80%A7%E8%83%BD%E5%88%86%E6%9E%90_TCP%E5%86%85%E5%AD%98/)

# 7 conntrack insert failed

在k8s集群中的两个服务通过k8s-service频繁相互调用，有概率会出现阻塞的情况

**由于通过`k8s-service`进行服务的访问，那么势必会存在`DNAT/SNAT`规则，因为需要将`service-name`对应的`clusterIp`通过`DNAT`规则转换成指定的`podIp`。问题由此产生，生产环境中使用的k8s版本较低，还为支持`NF_NAT_RANGE_PROTO_RANDOM_FULLY`参数，当存在大量NAT转换的场景下，可能会出现冲突，一旦出现冲突，那么表象就是`insert failed`，如下图：**

![7-1](/images/System-Issue-Logs/7-1.png)

**解决方式：将k8s升级到支持`NF_NAT_RANGE_PROTO_RANDOM_FULLY`参数的版本**

## 7.1 参考

* [k8s与debug--解决conntrack insert failed](https://segmentfault.com/a/1190000021865782)
* [话说kubernetes网络疑难杂症](https://yuerblog.cc/2020/03/06/%E8%AF%9D%E8%AF%B4kubernetes%E7%BD%91%E7%BB%9C%E7%96%91%E9%9A%BE%E6%9D%82%E7%97%87/)
* [k8s-connection-reset](https://github.com/tcarmet/k8s-connection-reset)

# 8 参考

* [docker 卡死引起的 container runtime is down](http://team.jiunile.com/blog/2020/10/docker-hang.html)
* [一个因tcp_tw_recycle引起的跨机房连接超时问题](https://zhuanlan.zhihu.com/p/35684094)
* [服务器TIME_WAIT和CLOSE_WAIT详解和解决办法](https://zhuanlan.zhihu.com/p/60382685)
* [线上大量CLOSE_WAIT的原因深入分析](https://juejin.cn/post/6844903734300901390)
* [NMI watchdog: BUG: soft lockup](https://zzyongx.github.io/blogs/NMI_watchdog_BUG_soft_lockup.html)
