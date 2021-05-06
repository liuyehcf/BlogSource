---
title: Linux-重要文件路径
date: 2020-08-27 14:11:21
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 /sys目录

首先，先通过`tree -L 1 /sys`看下`/sys`的目录结构，结果如下

```
/sys
├── block
├── bus
├── class
├── dev
├── devices
├── firmware
├── fs
├── hypervisor
├── kernel
├── module
└── power
```

| 子目录 | 作用 |
|:--|:--|
| /sys/block | 该目录下的所有子目录代表着系统中当前被发现的所有块设备。按照功能来说放置在`/sys/class`下会更合适，但由于历史遗留因素而一直存在于`/sys/block`，但从`linux2.6.22`内核开始这部分就已经标记为过去时，只有打开了`CONFIG_SYSFS_DEPRECATED`配置编译才会有这个目录存在，并且其中的内容在从`linux2.6.26`版本开始已经正式移到了`/sys/class/block`，旧的接口`/sys/block`为了向后兼容而保留存在，但其中的内容已经变为了指向它们在`/sys/devices/`中真实设备的符号链接文件 |
| **/sys/bus** | 该目录下的每个子目录都是`kernel`支持并且已经注册了的总线类型。这是内核设备按照总线类型分层放置的目录结构，`/sys/devices`中的所有设备都是连接于某种总线之下的，bus子目录下的每种具体总线之下可以找到每个具体设备的符号链接，一般来说每个子目录（总线类型）下包含两个子目录，一个是`devices`，另一个是`drivers`；其中`devices`下是这个总线类型下的所有设备，这些设备都是符号链接，它们分别指向真正的设备`/sys/devices/name/`；而`drivers`下是所有注册在这个总线上的驱动，每个`driver`子目录下是一些可以观察和修改的driver参数。（它也是构成linux统一设备模型的一部分） |
| **/sys/class** | 该目录下包含所有注册在kernel里面的设备类型，这是按照设备功能分类的设备模型，每个设备类型表达具有一种功能的设备。每个设备类型子目录下都是相应设备类型的各种具体设备的符号链接，这些链接指向`/sys/devices/name`下的具体设备。设备类型和设备并没有一一对应的关系，一个物理设备可能具备多种设备类型；一个设备类型只表达具有一种功能的设备，比如：系统所有输入设备都会出现在`/sys/class/input`之下，而不论它们是以何种总线连接到系统的。（`/sys/class`也是构成linux统一设备模型的一部分） |
| /sys/dev | 该目录下维护一个按照字符设备和块设备的主次号码`major:minor`链接到真实设备`/sys/devices`的符号链接文件 |
| **/sys/devices** | 该目录下是全局设备结构体系，包含所有被发现的注册在各种总线上的各种物理设备。一般来说，所有的物理设备都按其在总线上的拓扑结构来显示，但有两个例外，即`platform devices`和`system devices`。`platform devices`一般是挂在芯片内部的高速或者低速总线上的各种控制器和外设，它们能被CPU直接寻址；`system devices`不是外设，而是芯片内部的核心结构，比如CPU，timer等，它们一般没有相关的驱动，但是会有一些体系结构相关的代码来配置它们。（`sys/devices`是内核对系统中所有设备的分层次表达模型，也是`/sys`文件系统管理设备的最重要的目录结构） |
| /sys/firmware | 该目录下包含对固件对象`firmware object`和属性进行操作和观察的接口，即这里是系统加载固件机制的对用户空间的接口。（关于固件有专用于固件加载的一套API） |
| /sys/fs | 按照设计，该目录使用来描述系统中所有的文件系统，包括文件系统本身和按照文件系统分类存放的已挂载点 |
| /sys/hypervisor | 该目录是与虚拟化Xen相关的装置。（Xen是一个开放源代码的虚拟机监视器） |
| /sys/kernel | 这个目录下存放的是内核中所有可调整的参数 |
| /sys/module | 该目录下有系统中所有的模块信息，不论这些模块是以内联`inlined`方式编译到内核映像文件中还是编译为外模块`.ko文件`，都可能出现在`/sys/module`中。即module目录下包含了所有的被载入kernel的模块。 |
| /sys/power | 该目录是系统中的电源选项，对正在使用的power子系统的描述。这个目录下有几个属性文件可以用于控制整个机器的电源状态，如可以向其中写入控制命令让机器关机/重启等等 |

可以看到`/sys`下的目录结构是经过精心设计的：在`/sys/devices`下是所有设备的真实对象，包括如视频卡和以太网卡等真实的设备，也包括`ACPI`等不那么显而易见的真实设备、还有`tty`、`bonding`等纯粹虚拟的设备；在其它目录如`class`、`bus`等中则在分类的目录中含有大量对`/sys/devices`中真实对象引用的符号链接文件

**举例**

1. `/sys/class/net`：网卡（包含物理网卡+虚拟网卡的符号链接文件）
1. `/sys/devices/virtual/net`：虚拟网卡
1. `/sys/class/dmi/id`：主板相关信息
    * `/sys/class/dmi/id/product_uuid`：主板uuid

## 1.1 参考

* [linux 目录/sys 解析](https://blog.csdn.net/zqixiao_09/article/details/50320799)
* [What's the “/sys” directory for?](https://askubuntu.com/questions/720471/whats-the-sys-directory-for)

# 2 /proc目录

1. `/proc/buddyinfo`：内存碎片信息
1. `/proc/cmdline`：系统启动时输入给内核的命令行参数
1. `/proc/version`：内核版本
1. `/proc/cpuinfo`：cpu硬件信息
1. `/proc/filesystems`：当前内核支持的文件系统列表
1. `/proc/kallsyms`：内核符号表
1. `/proc/kmsg`：内核消息，对应dmesg命令
1. `/proc/modules`：已经加载的模块列表，对应lsmod命令
1. `/proc/mounts`：已经挂载的文件系统，对应mount命令
1. `/proc/stat`：全面统计状态表
1. `/proc/interrupts`：中断映射表
1. `/proc/self`：我们可以通过`/proc/${pid}`目录来获取指定进程的信息。当pid可能发生变化时，我们还可以通过`/proc/self`来访问当前进程的信息，不同的进程访问该目录下的文件得到的结果是不同的
1. `/proc/sys/net`：网络相关配置
1. `/proc/net`：网络相关的统计信息
    * `/proc/net/route`：路由表
    * `/proc/net/arp`：mac地址表
    * `/proc/net/tcp`：tcp连接信息
        * `1 -> TCP_ESTABLISHED`
        * `2 -> TCP_SYN_SENT`
        * `3 -> TCP_SYN_RECV`
        * `4 -> TCP_FIN_WAIT1`
        * `5 -> TCP_FIN_WAIT2`
        * `6 -> TCP_TIME_WAIT`
        * `7 -> TCP_CLOSE`
        * `8 -> TCP_CLOSE_WAIT`
        * `9 -> TCP_LAST_ACL`
        * `10 -> TCP_LISTEN`
        * `11 -> TCP_CLOSING`

# 3 /var目录

1. `/var/crash`：内核crash日志
1. `/var/log`：日志
    * `/var/log/audit`：审计日志

# 4 其他

1. `/dev/disk/by-path`：以磁盘路径为名称的软链接文件
1. `/dev/disk/by-partuuid`：以分区uuid为名称的软链接文件
1. `/dev/disk/by-uuid`：以uuid为名称的软链接文件
1. `/dev/disk/by-partlabel`：以分区标签为名称的软链接文件
1. `/dev/disk/by-id`：以id为名称的软链接文件
1. `/usr/share/zoneinfo`：时区配置文件
    * `/etc/localtime`：时区配置文件的软连接，实际生效的时区配置

