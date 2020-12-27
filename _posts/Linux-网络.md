---
title: Linux-网络
date: 2018-07-20 15:00:52
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 系统网络参数

网络配置参数与内核配置文件的对应关系，例如`net.ipv4.ip_forward`对应的内核配置文件为`/proc/sys/net/ipv4/ip_forward`

| 配置项 | 说明 |
|:--|:--|
| `net.ipv4.tcp_syncookies` | `1`表示开启`SYN Cookies`。当出现SYN等待队列溢出时，启用`Cookies`来处理，可防范少量SYN攻击，默认为0，表示关闭 |
| `net.ipv4.tcp_tw_reuse` | `1`表示开启重用。允许将`TIME-WAIT`状态的`sockets`重新用于新的TCP连接，默认为0，表示关闭 |
| `net.ipv4.tcp_tw_recycle` | `1`表示开启TCP连接中`TIME-WAIT`状态的`sockets`的快速回收，默认为0，表示关闭 |
| `net.ipv4.conf.<net_device>.proxy_arp` | `1`表示当ARP请求目标跨网段时，网卡设备收到此ARP请求会用自己的MAC地址返回给请求者 |

# 2 虚拟机的网络模式

## 2.1 Network Address Translation (NAT)

在NAT模式下，当一个VM操作系统启动时，它通常通过发送一个`DHCP Request`来获取一个`IP`地址。`VirtualBox`将会处理这个`DHCP Request`，然后返回一个`DHCP Response`给VM，这个`DHCP Response`包含了一个`IP`地址以及网关地址，其中网关地址用于路由`Outbound connections`

在这种模式下，每一个VM被分配到的都是一个相同的IP（`10.0.2.15`），因为每一个VM都认为他们处于一个隔离的网络中，也就是说不同的VM之间无法感知到对方的存在

当VM通过网关（`10.0.2.2`）发送流量时，`VirtualBox`会重写数据包，使其看起来好像来自主机，而不是来自VM（在主机内运行）

逻辑上，网络看起来像下面这样

![fig1](/images/Linux-网络/fig1.png)

总结一下，NAT包含如下特征

1. VM处于一个私有的局域网
1. `VirtualBox`扮演着`DHCP`服务器的角色
1. `VirtualBox Engine`起到转换地址的作用
1. 适用于当VM作为Client的场景，因此不是适用于VM作为Server的场景
1. VM可以访问外界网络，而外界网络无法访问VM

## 2.2 Bridged Networking

当您希望您的VM成为完整的网络公民，即与网络上的主机相同时，使用`Bridged Networking`；在此模式下，虚拟NIC“桥接”到主机上的物理网卡

这样做的结果是每个VM都可以像访问主机一样访问物理网络。它可以像访问主机一样访问网络上的任何服务，例如外部DHCP服务，名称查找服务和路由信息

逻辑上，网络看起来像下面这样

![fig2](/images/Linux-网络/fig2.png)

总结一下，`Bridged Networking`网络包含如下特征

1. `VirtualBox`桥接到主机网络
1. 会消耗IP地址
1. 适用于Client VM或Server VM

## 2.3 Internal Networking

`Internal Networking`网络（在本例中为“intnet”）是一个完全隔离的网络，因此非常“安静”。当您需要一个单独的，干净的网络时，这适用于测试，您可以使用VM创建复杂的内部网络，为内部网络提供自己的服务。（例如Active Directory，DHCP等）。__请注意，即使主机也不是内部网络的成员__，但即使主机未连接到网络（例如，在平面上），此模式也允许VM运行

逻辑上，网络看起来像下面这样

![fig3](/images/Linux-网络/fig3.png)

请注意，在此模式下，`VirtualBox`不提供`DHCP`等“便利”服务，因此必须静态配置您的计算机，或者VM需要提供`DHCP`/名称服务

总结一下，`Internal Networking`网络包含如下特征

1. 不同VM之间处于同一个私有网络
1. VM无法访问外部网络
1. 宿主机断网时，VM也能正常工作（本来就不需要外网）

## 2.4 Host-only Networking

坐在这个“vboxnet0”网络上的所有VM都会看到对方，此外，主机也可以看到这些VM。但是，其他外部计算机无法在此网络上看到VM，因此名称为“Host-only”

逻辑上，网络看起来像下面这样

![fig4](/images/Linux-网络/fig4.png)

这看起来非常类似于`Internal Networking`，但主机现在位于“vboxnet0”并且可以提供`DHCP`服务

总结一下，`Host-only Networking`网络包含如下特征

1. `VirtualBox`为VM以及宿主机创建了一个私有网络
1. `VirtualBox`提供DHCP服务
1. VM无法看到外部网络
1. 宿主机断网时，VM也能正常工作（本来就不需要外网）

## 2.5 Port-Forwarding with NAT Networking

如果您在笔记本电脑上购买移动演示或开发环境并且您有一台或多台VM需要其他机器连接，该怎么办？而且你不断地跳到不同的VM网络上。在这样的场景下

1. NAT：无法满足，因为外部机器无法连接到VM上
1. Bridged：可以满足，但是会消耗IP资源，且VM网络环境随着外部网络环境的改变而改变
1. Internal：无法满足，因为外部机器无法连接到VM上
1. Host-only：无法满足，因为外部机器无法连接到VM上

当外部机器连接到宿主机的“host:port”时，`VirtualBox`会将连接`forward`到VM的“guest:port”上

逻辑上，网络看起来像下面这样（forward并没有在这张图体现出来，所以这幅图与NAT很像）

![fig5](/images/Linux-网络/fig5.png)

## 2.6 参考

* [Oracle VM VirtualBox: Networking options and how-to manage them](https://blogs.oracle.com/scoter/networking-in-virtualbox-v2)
* [Chapter 6. Virtual networking](https://www.virtualbox.org/manual/ch06.html#network_bridged)
* [VMware虚拟机三种网络模式详解](https://www.linuxidc.com/Linux/2016-09/135521.htm)

# 3 Netfilter

Linux中最常用的基本防火墙软件称为`iptables`。`iptables`防火墙通过与Linux内核的网络堆栈中的数据包过滤`hook`进行交互来工作。这些内核`hook`称为`netfilter`框架

进入网络系统（`incoming`或`outgoing`）的每个数据包将在它通过网络堆栈时触发这些`hook`，允许注册这些`hook`的程序与关键点的流量进行交互。与`iptables`相关联的内核模块在这些`hook`处注册，以确保流量符合防火墙的设定

## 3.1 Netfilter Hooks

`netfilter`一共包含5个`hook`。当数据包通过网络堆栈时，注册到这些`hook`的内核模块将被触发执行。数据包是否触发`hook`，取决于数据包是`incoming`还是`outgoing`，数据包的目标，以及数据包是否在之前的点已被丢弃或拒绝

1. __`NF_IP_PRE_ROUTING`__：该`hook`会在任意`incoming`数据包进入网络堆栈时触发。并且，会在做出路由决定前处理完毕
1. __`NF_IP_LOCAL_IN`__：该`hook`会在某个`incoming`数据包被路由到`local system`时触发
1. __`NF_IP_FORWARD`__：该`hook`会在某个`incoming`数据包被`forwarded`到其他主机时触发
1. __`NF_IP_LOCAL_OUT`__：该`hook`会在任意`outgoing`数据包进入网络堆栈时触发
1. __`NF_IP_POST_ROUTING`__：该`hook`会在任意`outgoing`或`forwarded`数据包发生路由之后，传输之前触发

在`hook`处注册的内核模块必须提供优先级编号，来确定触发`hook`时调用内核模块的顺序。每个模块将按照优先级顺序依次被调用，并在处理后将处理结果返回`netfilter`，以便让`netfilter`决定对数据包进行何种操作

## 3.2 IPTables Tables and Chains

`iptables`防火墙使用`table`来组织其`rule`。这些`table`根据决策类型进行分类。例如，如果`rule`处理网络地址转换，它将被放入`nat table`中。如果该`rule`用于决定是否允许数据包继续到其目的地，则可能会将其添加到`filter table`中

在每个`iptables table`中，`rule`进一步被拆分到不同的`chain`中。__其中，`table`代表了决策类型；`chain`表示由哪个`hook`来触发，即决定`rule`何时进行校验__

| `Chain` | `hoook` |
|:--|:--|
| `PREROUTING` | `NF_IP_PRE_ROUTING` |
| `INPUT` | `NF_IP_LOCAL_IN` |
| `FORWARD` | `NF_IP_FORWARD` |
| `OUTPUT` | `NF_IP_LOCAL_OUT` |
| `POSTROUTING` | `NF_IP_POST_ROUTING` |

`chain`允许管理员控制数据包的传递路径中的评估`rule`。由于每个`table`都有多个`chain`，因此一个`table`的作用点可能会有多个（关联到了多个`hook`）。由于某些类型的决策仅在网络堆栈中的某些点有意义，因此`talbe`不会在每个内核`hook`中进行注册

只有五个`netfilter`内核`hook`，因此，每个`hook`注册了多个来自不同`table`的`chian`。例如，三个`table`具有`PREROUTING chain`。当这些`chain`在相关的`NF_IP_PRE_ROUTING hook`处注册时，它们指定一个优先级，该优先级指示每个`table`的`PREROUTING chain`被调用的顺序。在进入下一个`PREROUTING`链之前，将按顺序评估最高优先级`PREROUTING chain`中的每个`rule`

![fig6](/images/Linux-网络/fig6.jpg)

## 3.3 Which Tables are Available?

### 3.3.1 The Filter Table

`filter table`是`iptables`中最常使用的，`filter table`用于决定放行数据包，还是拒绝数据包通过

### 3.3.2 The NAT Table

`net table`通常进行网络地址转换（`NAT`）。当数据包进入网络堆栈，`net table`中的`rule`将会决定是否以及怎样修改数据包的`源地址`以及`目的地址`

### 3.3.3 The Mangle Table

`mangle table`用于修改`IP header`，例如修改数据包的`TTL(Time to Live)`属性值

### 3.3.4 The Raw Table

`iptables`防火墙是有状态的，这意味着，对于一个数据包的规则校验可以关联到前面若干个数据包。构建在`netfilter`框架之上的`connection tracking`功能允许`iptables`将数据包视为正在进行的`connection`或`session`的一部分，而不是作为离散的，无关的数据包

`connection tracking`的处理逻辑会在数据包到达网络接口时被执行。`raw table`的目的就是绕过`connection tracking`的功能

### 3.3.5 The Security Table

`security table`主要用于为数据包设置`SELinux`的安全上下文

## 3.4 Which Chains are Implemented in Each Table?

下标从左到右是五个`chain`；从上到下是若干个`table`，上面的`table`其优先级要比下面的`table`高。同时，`nat table`被拆分成两个表，一个是`SNAT table`（修改`source address`），另一个是`DNAT table`（修改`destination address`）

| Tables↓/Chains→ | PREROUTING | INPUT | FORWARD | OUTPUT | POSTROUTING |
|:--|:--:|:--:|:--:|:--:|:--:|
| `(routing decision)` | | | | ✓ | |
| `raw` | ✓ | | | ✓ | |
| `(connection tracking enabled)` | ✓ | | | ✓ | |
| `mangle` | ✓ | ✓ | ✓ | ✓ |✓ |
| `nat (DNAT)` | ✓ | | | ✓ | |
| `(routing decision)` | ✓ | | | ✓ | |
| `filter`| | ✓ | ✓ | ✓ | |
| `security`| | ✓ | ✓ | ✓ | |
| `nat (SNAT)` | | ✓ | | | ✓ |

__Chain Traversal Order__

1. __Incoming packets destined for the local system__：`PREROUTING -> INPUT`
1. __Incoming packets destined to another host__：`PREROUTING -> FORWARD -> POSTROUTING`
1. __Locally generated packets__：`OUTPUT -> POSTROUTING`

举个例子，一个`incoming`数据包，其目的地是`local systeml`，那么`PREROUTING chain`会被首先触发，按照优先级顺序，依次是`raw table`、`mangle table`、`nat table`的逻辑会被执行。然后`INPUT chain`会被触发，按照优先级顺序，依次是`mangle table`、`filter table`、`security table`以及`nat table`

## 3.5 IPTables Rules

__一个`rule`由一个`table`以及一个`chain`唯一确定__。每个`rule`都有一个`matching component`以及一个`action component`

__`matching component`用于指定数据包必须满足的条件，以便执行相关的操作__。匹配系统非常灵活，可以通过系统上的`iptables`进行配置，允许进行如下粒度的配置

1. __协议类型__
1. __目的地或源地址__
1. __目的地或源端口__
1. __目的地或源网络__
1. __输入或输出接口__
1. __报头或连接状态以及其他标准__
* 上述规则可以自由组合，用来创建相当复杂的规则集以区分不同的流量

__`action component`用于在满足规则匹配条件时，输出一个`target`__：`target`通常分为以下两类

1. __`Terminating targets`__：执行一个动作，该动作终止`chain`中的执行逻辑并将控制返回到`netfilter`的`hook`中。根据提供的返回值，`hook`可能会丢弃数据包或允许数据包继续进行下一个处理阶段
1. __`Non-terminating targets`__：执行一个动作，并继续`chain`中的执行逻辑。尽管每个`chain`最终必须传回`Terminating targets`，但是可以预先执行任意数量的`Non-terminating targets`

## 3.6 Jumping to User-Defined Chains

这里需要提到一个特殊的`Non-terminating targets`，即`jump target`。`jump target`可以跳转到其他`chain`中执行额外的处理逻辑。在上面讨论到的`built-in chains`已经预先注册到了`netfilter hook`中，而`User-Defined Chains`是不允许注册到`hook`中的。尽管如此，`iptables`仍然允许用户自定义`chain`，其原理就是用到了`jump target`

## 3.7 IPTables and Connection Tracking

在讨论`raw table`时，我们介绍了在`netfilter`框架之上实现的`connection tracking`。`connection tracking`允许`iptables`在当前连接的上下文中查看数据包。`connection tracking`为`iptables`提供执行“有状态”操作所需的功能

数据包进入网络堆栈后很快就会应用`connection tracking`。__`raw table chains`和一些基本的健全性检查是在将`数据包`与`连接`相关联之前对数据包执行的唯一逻辑__

系统根据一组现有连接检查每个数据包，将更新数据包所属连接的状态，或增加一个新的连接。__在`raw table chains`中标记有`NOTRACK target`的数据包将绕过`connection tracking`处理流程__

在`connection tracking`中，一个数据包可能被标记为如下几种状态

1. __`NEW`__：当前数据包不属于任何一个现有的`connection`，且是一个合法的`first package`，那么将会创建一个新的`connection`
1. __`ESTABLISHED`__：当收到一个`response`时，`connection`会从`NEW`状态变为`ESTABLISHED`状态。对于`TCP`，这意味着这是一个`SYN/ACK`数据包；对于`UDP`，这意味着这是一个`ICMP`数据包
1. __`RELATED`__：当前数据包不属于任何一个现有的`connection`，但是关联到某个`connection`。这通常是一个`helper connection`，例如`FTP data transmission connection`或者是`ICMP`对其他协议的`连接尝试`的响应
1. __`INVALID`__：当前数据包不属于任何一个现有的`connection`，也不是一个合法的`first package`
1. __`UNTRACKED`__：通过`raw table`的配置，绕过`connection tracking`的处理流程
1. __`SNAT`__：`source address`被`NAT`修改时设置的虚拟状态，被记录在`connection tracking`中，以便在`reply package`（我回复别人）中更改`source address`
1. __`DNAT`__：`destination address`被`NAT`修改时设置的虚拟状态，被记录在`connection tracking`中，以便在路由`reply package`（别人回复我）时知道更改`destination address`

## 3.8 NAT原理

以一个示例来进行解释，条件如下：

1. `Machine A`在私网环境下，其`IP`是`192.168.1.2`
1. `NAT Gateway A`有两张网卡
    * 一张网卡的`IP`为`192.168.1.1`，与`Machine A`在同一个网段，且为`Machine A`的默认路由地址
    * 一张网卡的`IP`为`100.100.100.1`，为公网`IP`
1. `Machine B`在私网环境下，其IP是`192.168.2.2`
1. `NAT Gateway B`有两张网卡
    * 一张网卡的`IP`为`192.168.2.1`，与`Machine B`在同一个网段，且为`Machine B`的默认路由地址
    * 一张网卡的`IP`为`200.200.200.1`，为公网`IP`

__Request from Machine A to Machine B__

1. `Request`从`Machine A`发出，经过默认路由到达`NAT Gateway A`
1. `NAT Gateway A`发现配置了`SNAT规则`，于是将`srcIP`从`192.168.1.2`改为`100.100.100.1`
1. `Request`从`NAT Gateway A`经过公网流转到`NAT Gateway B`
1. `NAT Gateway B`发现配置了`DNAT`规则，于是将`dstIP`从`200.200.200.1`改为`192.168.2.2`
1. `Request`最终流转至`Machine B`
* 对于`Machine B`来说，它认为`Request`就是`NAT Gateway A`发过来的，而完全感知不到`Machine A`
* 同理，对于`Machine A`来说，它认为`Request`最终发给了`NAT Gateway B`，而完全感知不到`Machine B`

```
                +--------------------------+                                               +--------------------------+
                |  src ip  : 192.168.1.2   |                                               |  src ip  : 100.100.100.1 |
   Machine A    |  src port: 56303         |                                               |  src port: 56303         |    Machine B
  192.168.1.2   +--------------------------+                                               +--------------------------+   192.168.2.2
                |  dst ip  : 200.200.200.1 |                                               |  dst ip  : 192.168.2.2   |
                |  dst port: 443           |                                               |  dst port: 443           |
                +------------+-------------+                                               +------------+-------------+
                             |                                                                          ^
                             |                                                                          |
                             | route                                                                    | route
                             |                                                                          |
                             v                                                                          |
                +------------+-------------+                                               +------------+-------------+
                |  osrc ip : 192.168.1.2   |                                               |  src ip  : 100.100.100.1 |
NAT Gateway A   |  msrc ip : 100.100.100.1 |                   internet                    |  src port: 56303         |   NAT Gateway B
 192.168.1.1    |  src port: 56303         | +-------------------------------------------> +--------------------------+    192.168.2.1
100.100.100.1   +--------------------------+                                               |  odst ip : 200.200.200.1 |   200.200.200.1
                |  dst ip  : 200.200.200.1 |                                               |  mdst ip : 192.168.2.2   |
                |  dst port: 443           |                                               |  dst port: 443           |
                +--------------------------+                                               +--------------------------+
```

__Response from Machine B to Machine A__

1. `Response`从`Machine B`发出，经过默认路由到达`NAT Gateway B`
1. `NAT Gateway B`发现配置了`DNAT`规则，于是将`srcIP`从`192.168.2.2`改为`200.200.200.1`
1. `Response`从`NAT Gateway B`经过公网流转到`NAT Gateway A`
1. `NAT Gateway A`发现配置了`SNAT`规则，于是将`dstIP`从`100.100.100.1`改为`192.168.1.2`
1. `Response`最终流转至`Machine A`

```
                +--------------------------+                                               +--------------------------+
                |  src ip  : 200.200.200.1 |                                               |  src ip  : 192.168.2.2   |
   Machine A    |  src port: 443           |                                               |  src port: 443           |    Machine B
  192.168.1.2   +--------------------------+                                               +--------------------------+   192.168.2.2
                |  dst ip  : 192.168.1.2   |                                               |  dst ip  : 100.100.100.1 |
                |  dst port: 56303         |                                               |  dst port: 56303         |
                +------------+-------------+                                               +-----------+--------------+
                             ^                                                                         |
                             |                                                                         |
                             | route                                                                   |  route
                             |                                                                         |
                             |                                                                         v
                +------------+-------------+                                               +-----------+--------------+
                |  src ip  : 200.200.200.1 |                                               |  osrc ip : 192.168.2.2   |
NAT Gateway A   |  src port: 443           |                   internet                    |  msrc ip : 200.200.200.1 |   NAT Gateway B
 192.168.1.1    +--------------------------+ <-------------------------------------------+ |  src port: 443           |    192.168.2.1
100.100.100.1   |  odst ip : 100.100.100.1 |                                               +--------------------------+   200.200.200.1
                |  mdst ip ： 192.168.1.2   |                                               |  dst ip  : 100.100.100.1 |
                |  dst port: 56303         |                                               |  dst port: 56303         |
                +--------------------------+                                               +--------------------------+
```

__细心的朋友可能会发现，`NAT Gateway A`只配置了`SNAT`，而`NAT Gateway B`只配置了`DNAT`，但是在`Response`的链路中，`NAT Gateway A`做了`DNAT`的工作，而`NAT Gateway B`做了`SNAT`的工作__

* 当`Request`到达`NAT Gateway A`时，`NAT Gateway A`会在`NAT`表中添加一行，然后再改写`srcIP`（SNAT）
    * 前缀`o`是`original`的缩写
    * 前缀`m`是`modified`的缩写

| osrcIP | osrcPort | msrcIP | msrcPort | protocol |
|:--|:--|:--|:--|:--|
| 192.168.1.2 | 56303 | 100.100.100.1 | 56303 | xxx |

* 当`Request`到达`NAT Gateway B`时，`NAT Gateway B`会在`NAT`表中添加一行，然后再改写`dstIP`（DNAT）

| odstIP | odstPort | mdstIP | mdstPort | protocol |
|:--|:--|:--|:--|:--|
| 200.200.200.1 | 443 | 192.168.2.2 | 443 | xxx |

* 当`Response`到达`NAT Gateway B`时，会查找`srcIP`与`mdstIP`相同且`srcPort`与`mdstPort`相同的表项，并将`srcIP`和`srcPort`替换成`odstIP`和`odstPort`（SNAT）
* 当`Response`到达`NAT Gateway A`时，会查找`dstIP`与`msrcIP`相同且`dstPort`与`msrcPort`相同的表项，并将`dstIP`和`dstPort`替换成`osrcIP`和`osrcPort`（DNAT）

__如此一来，有了IP+端口，一台网关就可以为多台机器配置SNAT；同理，也可以为多台机器配置DNAT__

__但是，如果两台私网的机器A和B（均在网关上配置了SNAT规则），同时ping某个外网IP的话，NAT又是如何工作的呢？（ICMP协议没有port，而只根据IP是没法区分这两台私网机器的）方法就是：创造端口（下面这种做法是我猜的，与实际情况未必一致，但是思路是相似的）__

* 假设A的IP为`192.168.1.2`，`NAT Gateway`的IP是`100.100.100.1`，ping的公网IP是`200.200.200.1`
* 当`ICMP Request`报文到达`NAT Gateway`的时候，根据`identifier`生成源端口号，修改`srcIP`，以及`identifier`并增加如下记录（SNAT）
    * 其中，`mapFunc`表示从`identifier`转换为端口号的算法

| osrcIP | osrcPort | msrcIP | msrcPort | protocol |
|:--|:--|:--|:--|:--|
| 192.168.0.2 | mapFunc(oIdentifier) | 200.10.2.1 | mapFunc(mIdentifier) | ICMP |

* 当`ICMP Response`报文到达`NAT Gateway`的时候，会查找`dstIP`与`msrcIP`相同且`dstPort`（通过`mapFunc`计算`ICMP Response`中的`identifier`）与`msrcPort`相同的表项，并将`dstIP`替换成`osrcIP`，`identifier`替换成`mapFuncInv(osrcPort)`（DNAT）
    * 其中，`mapFuncInv`表示从端口号转换为`identifier`的算法

## 3.9 iptable命令使用

参见{% post_link Linux-常用命令 %}

## 3.10 参考

* [A Deep Dive into Iptables and Netfilter Architecture](https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture)
* [ICMP报文如何通过NAT来地址转换](https://blog.csdn.net/sinat_33822516/article/details/81088724)
* [Understanding how dnat works in iptables](https://superuser.com/questions/662325/understanding-how-dnat-works-in-iptables)
* [How Network Address Translation Works](https://computer.howstuffworks.com/nat.htm)
* [Traditional IP Network Address Translator (Traditional NAT) - 4.1](https://tools.ietf.org/html/rfc3022)
* [纯文本作图-asciiflow.com](http://asciiflow.com/)

# 4 tcpdump

tcpdump是通过libpcap来抓取报文的，libpcap在不同平台有不同的实现，下面仅以Linux平台来作说明。

首先Linux平台在用户态获取报文的Mac地址等链路层信息并不是什么特殊的事情，通过AF_PACK套接字就可以实现，而tcpdump或libpcap也正是用这种方式抓取报文的(可以strace tcpdump的系统调用来验证)。关于AF_PACK的细节，可查看man 7 packet。

其次，上面已经提到tcpdumap使用的是AF_PACK套接字，不是Netfilter。使用Netfilter至少有2点不合理的地方：

1. 数据包进入Netfilter时其实已经在协议栈做过一些处理了，数据包可能已经发生一些改变了。比较明显的一个例子，进入Netfilter前需要重组分片，所以Netfilter中无法抓取到原始的报文分片。而在发送方向，报文离开Netfilter时也未完全结束协议栈的处理，所以抓取到的报文也会有不完整的可能。
1. 在Netfilter抓取的报文，向用户态递送时也会较为复杂。Netfilter的代码处在中断上下文和进程上下文两种运行环境，无法使用传统系统调用，简单的做法就是使用Netlink。而这还不如直接用AF_PACKET抓取报文来得简单（对内核和用户态程序都是如此）。

## 4.1 参考

* [tcpdump 抓包的原理？](https://www.zhihu.com/question/41710052)
* [NAT技术基本原理与应用](https://www.cnblogs.com/dongzhuangdian/p/5105844.html)
* [Linux-虚拟网络设备-veth pair](https://blog.csdn.net/sld880311/article/details/77650937)
* [Linux虚拟网络设备之bridge(桥)](https://segmentfault.com/a/1190000009491002?utm_source=tag-newest)
* [VLAN是二层技术还是三层技术？](https://www.zhihu.com/question/52278720/answer/140914508)
* [tcpdump官网](https://www.tcpdump.org/)

# 5 网桥/交换机/集线器

__集线器，交换机和网桥之间的主要区别在于：集线器工作在`OSI`模型的第`1`层，而网桥和交换机工作在第`2`层（使用MAC地址）。集线器在所有端口上广播传入的流量，而网桥和交换机仅将流量路由到目的端口（交换机上的端口）__

## 5.1 什么是Hub

集线器为每个设备提供专用的物理连接，这有助于减少一台计算机发生故障将导致所有计算机失去连接的可能性。但是，由于集线器仍是共享带宽的设备，因此连接仅限于半双工。冲突仍然是一个问题，因此集线器无助于提高网络性能

集线器本质上是多端口中继器。他们忽略了以太网帧的内容，只是简单地从集线器的每个接口中重新发送收到的每个帧。挑战在于，以太网帧将显示在连接到集线器的每个设备上，而不仅是预期的目的地（安全漏洞），而且入站帧通常会与出站帧发生冲突（性能问题）

## 5.2 什么是Bridge

在现实世界中，桥梁连接着河流或铁轨两侧的道路。__在技术领域，网桥连接两个物理网段__。每个网桥都跟踪连接到其每个接口的网络上的MAC地址。当网络流量到达网桥并且其目标地址在网桥的那一侧是本地的时，网桥会过滤该以太网帧，因此它仅停留在网桥的本地

如果网桥无法在接收流量的那一侧找到目标地址，它将跨网桥转发帧，希望目的地在另一个网段上。有时，到达目标地址需要经过多个网桥

最大的挑战是广播和多播流量必须在每个网桥之间转发，因此每个设备都有机会读取这些消息。如果网络管理器构建了冗余电路，通常会导致广播或多播流量泛滥，从而阻止单播流量

## 5.3 什么是Switch

交换机在将数据从一台设备移动到另一台设备中起着至关重要的作用。具体而言，与集线器相比，交换机通过为每个终端设备提供专用带宽，支持全双工连接，利用MAC地址表来做出转发决策以及利用`ASIC`和`CAM`表来提高帧速率，从而大大提高了网络性能

交换机会充分利用集线器和桥接器的功能，同时增加更多功能。他们将集线器的多端口功能与网桥过滤一起使用，仅允许目的地查看单播流量。交换机允许冗余链接，并且由于为网桥开发了生成树协议（STP），因此广播和多播的运行不会引起风暴

交换机会跟踪每个接口中的MAC地址，因此它们可以将流量仅快速发送到帧的目的地

这是使用交换机的一些好处：

1. 交换机是即插即用设备。一旦第一个数据包到达，他们便开始学习接口或端口以到达所需的地址
1. 交换机通过仅将流量发送到目标设备来提高安全性
1. 交换机提供了一种简单的方法来连接以不同速度运行的网段，例如`10 Mbps`，`100 Mbps`，`1 Gigabit`以及`10 Gigabit`网络
1. 交换机使用特殊的芯片在硬件中做出决定，从而降低了处理延迟并提高了性能
1. 交换机正在取代网络内部的路由器，因为它们在以太网网络上转发帧的速度快10倍以上

## 5.4 参考

* [What’s the Difference Between Hubs, Switches & Bridges?](https://www.globalknowledge.com/us-en/resources/resource-library/articles/what-s-the-difference-between-hubs-switches-bridges/)
* [集线器、交换机、网桥区别](https://blog.csdn.net/dataiyangu/article/details/82496340)

# 6 配网

## 6.1 配置文件

`CentOS`的网卡配置文件的位置在`/etc/sysconfig/network-scripts/`，配置文件的名称为`ifcfg-<网卡名>`，例如网卡名为`eno1`时，配置文件名称为`ifcfg-eno1`。示例配置如下

```sh
TYPE=Ethernet
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=static
DEFROUTE=yes
IPADDR=10.0.2.20
NETMASK=255.255.255.0
GATEWAY=10.0.2.2
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
NAME=enp0s3
UUID=08f8a712-444c-4906-9a94-c9fcf4987d3d
DEVICE=enp0s3
ONBOOT=yes
DNS1=223.5.5.5
```

* __`BOOTPROTO`__：可选项有`static`或`dhcp`
* __`DEFROUTE`__：是否生成default路由，注意，一台机器只能有一个网卡可以设置默认路由，否则即便有多个默认路由，第二个默认路由也是无效的
* __`IPADDR`__：ip地址
* __`NETMASK`__：子网掩码
* __`GATEWAY`__：网关ip
* __`ONBOOT`__：是否开机启动
* __`DNS1/DNS2/.../DNSx`__：dns配置

## 6.2 network-manager

`NetworkManager`是Linux下管理网络的一个服务，此外还有另一个服务`network`（这个服务已经过时，且与`NetworkManager`存在冲突

`NetworkManager`服务提供了两个客户端用于网络配置，分别是`nmcli`以及`nmtui`

### 6.2.1 设计

在`NetworkManager`的设计中，存在两种概念，一个是网卡设备`device`，另一个是连接`conn`，一个`device`可以对应多个`conn`，但是这个多个`conn`中只有一个是开启状态。如何控制`conn`的启动优先级呢？可以通过设置`connection.autoconnect-priority`

### 6.2.2 nmcli

```sh
# 查看所有网络连接
nmcli con show

# 查看指定网络连接（可以看到所有属性）
nmcli conn show <id>/<uuid>/<path>

# 查看指定网络连接（可以看到所有属性，且有分隔符区分不同类型的配置项）
nmcli -p conn show <id>/<uuid>/<path>

# 查看网络设备
nmcli device status

# 查看网络设备的详细配置
nmcli device show
nmcli -p device show

# 进入交互的编辑模式
nmcli conn edit <id>/<uuid>/<path>

# 修改某个配置值
nmcli conn modify <id>/<uuid>/<path> ipv4.address <ip/netmask>

# 启用/停用conn
nmcli conn up <id>/<uuid>/<path>
nmcli conn down <id>/<uuid>/<path>
```

__重要配置项__

1. `ipv4.never-default`：`1`表示永远不设置为默认路由，`0`反之
    * `nmcli conn modify eno1 ipv4.never-defaul 1`：连接`eno1`永远不设置默认路由
1. `connection.autoconnect-priority`：当一个网卡设备，包含多个`conn`时，且`connection.autoconnect`的值都是`1`（即默认开启）时，可以通过设置该值来改变`conn`的优先级，优先级高的`conn`将会生效

### 6.2.3 nmtui

带有图形化界面的配网工具

### 6.2.4 配置文件

路径：`/etc/NetworkManager/NetworkManager.conf`

配置文件详细内容参考[NetworkManager.conf](https://developer.gnome.org/NetworkManager/stable/NetworkManager.conf.html)

## 6.3 参考

* [NetworkManager官方文档](https://wiki.archlinux.org/index.php/NetworkManager)
* [为 Red Hat Enterprise Linux 7 配置和管理联网](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/index)
* [Networking Guide](https://docs.fedoraproject.org/en-US/Fedora/25/html/Networking_Guide/index.html)
* [Connecting to a Network Using nmcli](https://docs.fedoraproject.org/en-US/Fedora/25/html/Networking_Guide/sec-Connecting_to_a_Network_Using_nmcli.html)
* [Linux DNS 查询剖析（第三部分）](https://zhuanlan.zhihu.com/p/43556975)
