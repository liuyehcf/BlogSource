---
title: TCP-IP详解-读书笔记
date: 2019-10-28 17:46:22
mathjax: true
tags: 
- 摘录
categories: 
- Network
---

**阅读更多**

<!--more-->

# 1 概述

1. **网桥**是在**链路层**对网络进行互连，而**路由器**则是在**网络层**上对网络进行互连
1. `ICMP`是`IP`的附属协议，`IP`层用它来与其他主机或路由器交换错误报文和其他重要信息
1. 为`ICMP`、`IGMP`、`ARP`、`RARP`协议定位是比较棘手的，在不同的场景下可以位于不同的网络层级

# 2 链路层

1. 在`TCP/IP`协议簇中，链路层主要有三个目的
    * 为`IP`模块发送和接收`IP`数据报
    * 为`ARP`模块发送`ARP`请求和接收`ARP`应答
    * 为`RARP`发送`RARP`请求和接收`RARP`应答
1. 几个不同的标准集
    * `802.3`：整个`CSMA/CD`网络（Carrier Sense, Multiple Access with Collision Detection）
    * `802.4`：针对令牌总线网络
    * `802.5`：针对令牌环网络
1. `802.3`标准定义的帧和以太网的帧都有最小长度要求。`802.3`规定**数据部分**必须至少为38字节，而对于以太网，则要求最少要有46字节（这是为什么？）。为了保证这一点，必须在不足的空间插入填充字节
1. 大多数的产品都支持环回接口（Loopback Interface），以允许运行在同一台主机上的客户程序和服务器程序通过TCP/IP进行通信
1. 以太网和`802.3`对数据帧的长度都有一个限制，其最大值分别是1500和1492字节。链路层的这个特性称为`MTU`，最大传输单元。如果`IP`层有一个数据报要传，且数据报的长度比链路层的`MTU`还大，那么`IP`层就需要进行分片
1. 两台主机之间的通信如果经过多个网络，那么每个网络的链路层可能有不同的`MTU`，在这多个网络中，具有的最小`MTU`称作路径`MTU`
1. 两台主机之间的`MTU`不一定是个常数，它取决于当时所选择的路由，而选路不一定是对称的，因此路径`MTU`在两个方向上不一定是一致的
1. 网络地址划分
    * A类地址：0.0.0.0 -> 127.255.255.255
    * B类地址：128.0.0.0 -> 191.255.255.255
    * C类地址：192.0.0.0 -> 223.255.255.255
    * D类地址：224.0.0.0 -> 239.255.255.255
    * E类地址：240.0.0.0 -> 255.255.255.255

# 3 网际协议

1. `IP`提供不可靠、无连接的数据报传送服务
    * 不可靠：不保证`IP`数据报能成功到达目的地。`IP`仅能提供尽力而为的传输服务
    * 无连接：`IP`并不维护任何关于后续数据报的状态信息，每个数据报的处理是独立的，也就是说，`IP`数据报可以不按发送顺序接收（每个数据报的选路是独立的）
1. `IP`协议格式
    * 4位版本、4位首部长度、8位服务类型（TOS）、16位总长度（字节数）
    * 16位标志、3位标志、13位片偏移
    * 8位生存时间、8位协议、16位首部校验和
    * 32位源IP地址
    * 32位目的IP地址
    * 选项
    * 数据
1. 目前协议版本号是4，因此`IP`有时也称为`IPv4`
1. 首部长度指的是首部占`32bit字`的数目（32bit记为一份），由于这是一个4bit字段（0-15），因此首部最长为 `15*32bit=480bit=60Byte`
1. `TOS`字段包括一个3bit的优先权子字段（现已被忽略）、4bit的`TOS`子字段、1bit的未用字段（必须置0）。其中，4bit的`TOS`子字段分别代表
    * 最小时延（0x10）
    * 最大吞吐量（0x08）
    * 最高可靠性（0x04）
    * 最小费用（0x02）
    * 一般服务（0x00）
1. 总长度字段是指整个`IP`数据报的长度，以字节为单位（区别于首部长度，首部长度的单位是32bit，也就是4字节），由于该字段长度为16bit，所以`IP`数据报最长可达65535字节
1. `TTL`（time-to-live）生存时间字段设置了数据报可以经过的最多路由器数，`TTL`的初始值由源主机设置（通常为32或64），一旦经过一个处理它的路由器，他的值就会减去1。当该字段的值为0时，数据报就被丢弃，并发送`ICMP`报文通知源主机
1. 首部检验和字段是根据IP首部计算的检验和码，他不对首部后面的数据进行计算。`ICMP`、`IGMP`、`UDP`和`TCP`在它们各自的首部中均含有同时覆盖首部和数据的检验和码
1. 最后一个字段是任选项，是数据报中的一个可变长的可选信息，这些选项定义如下（这些选项很少使用，并非所有主机和路由器都支持，且选项都是以32bit作为界限，在必要时需要插入0填充，这样就保证了`IP`首部始终是32bit的整数倍）
    * 安全和处理限制
    * 记录路径
    * 时间戳
    * 宽松的源站选路
    * 严格的源站选路
1. `IP`层既可以配置成路由器的功能，也可以配置成主机的功能。本质的区别在于主机从不把数据报从一个接口转发到另一个接口，而路由器则要转发数据报
1. 路由表包含如下信息
    * 目的`IP`地址，既可以是一个完整的主机地址，也可以是一个网络地址
    * 下一站路由器的`IP`地址，指一个在直接相连网络上的路由器
    * 标志，其中一个标志标明目的IP地址是网络地址还是主机地址，另一个标志指明下一站路由器是否为真正的下一站路由器还是一个直接相连的接口
    * 为数据报传输指定一个网络接口
1. `IP`路由器主要完成如下功能
    * 搜索路由表，寻找能与目的`IP`地址完全匹配的表目
    * 搜索路由表，寻找能与目的网络号相匹配的表目
    * 搜索路由表，寻找标为默认（default）的路由表
1. 现在所有的主机都要求支持子网编址，不是把IP地址看成由单纯的一个网络号和一个主机号组成，而是把主机号再分成一个子网号和一个主机号。这样做的原因是A类和B类地址为主机号分配了太多的空间，可分别容纳的主机数太多了
1. 通常把B类地址留给主机的16bit中的前8bit作为子网地址，后8bit作为主机号
1. 子网对外部路由器来说隐藏了内部网络组织，但是对子网内部的路由器来说是不透明的（与30个C类地址相比，用一个包含30个子网的B类地址的好处是可以减小路由表的规模）
1. 子网掩码用来确定多少bit用于子网号，多少bit用于主机号（网络号的划分是明确的，而子网的划分是不明确的），其中值为1的bit表示网络号和子网号，为0的bit用于主机号
1. 给定IP和子网掩码后，主机就可以确定IP数据报的目的地，根据IP可以确定网络号和子网号的分界线，根据子网掩码可以确定子网号和主机号的分界线
    * 本子网上的主机
    * 本网络中其他子网中的主机
    * 其他网络上的主机

# 4 ARP: 地址解析协议

1. 链路层如以太网或令牌环网都有自己的寻址机制（通常为48bit），这是使用链路层的任何网络都必须遵从的
    * 例如，一组使用`TCP/IP`协议的主机和另一组使用某种PC网络软件的主机可以共享相同的电缆
1. 当一台主机把以太网数据帧发送到位于同一局域网上的另一台主机时，是根据48bit的以太网地址来确定目的接口的。设备驱动程序从不检查`IP`数据报中的目的`IP`地址
1. 地址解析为这两种不同的地址形式提供映射：32bit的`IP`地址和数据链路层使用的任何类型的地址
    * ARP为IP地址到对应的硬件地址之间提供动态映射，动态是指这个过程是自动完成的，一般用户和管理员无需关心
1. **ARP背后有一个基本概念，那就是网络接口有一个硬件地址（一个48bit的值，标识不同的以太网或令牌环网接口）。在硬件层次上进行的数据帧交换必须有正确的接口地址。知道主机的IP并不能让内核发送一帧数据给主机。内核（如以太网驱动程序）必须知道目的端的硬件地址才能发送数据。ARP的功能是在32bit的IP地址和采用不同网络技术的硬件地址之间提供动态映射**
1. ARP高效运行的关键是由于每个主机上都有一个ARP高速缓存。这个高速缓存存放了最近Internet地址到硬件地址之间的映射记录。高速缓存中每一项的生存时间一般为20分钟
    * `arp -a`可以查看高速缓存中的内容
1. 对于一个`IP`数据报，如果目的主机在本网络上（如以太网、令牌环网或点对点链接的另一端），那么`IP`数据报可以直接发送到目的主机上。如果目的主机在一个远程网络上，那么就通过`IP`选路函数来确定位于本地网络上的下一站路由器地址，并让它转发`IP`数据报。这两种情况下，`IP`数据报都是被送到本地网络上的一台主机或路由器（假定是以太网）
    * `ARP`发送一份称为`ARP`请求的以太网数据帧给以太网上的每个主机。这个过程称作广播。`ARP`请求中包含目的主机的IP地址。该请求的意思是：如果你是这个IP地址的拥有者，请回答你的硬件地址
    * 目的主机的`ARP`层收到这份广播报文后，识别出这是发送端在询问它的IP地址，于是发送一个`ARP`应答，这个`ARP`应答包含IP地址及对应的硬件地址
    * 收到`ARP`应答后，使`ARP`进行请求-应答交换的IP数据报现在就可以传送了
    * 发送IP数据报道目的主机
1. 直到`ARP`应答返回时，`TCP`报文才会被发送，因此对不存在的主机发送`TCP`报文，在链路上是看不到任何`TCP`数据的，但是会触发`TCP`的重传机制
1. `ARP`代理：如果`ARP`请求是从一个网络的主机发往另一个网络的主机，那么连接这两个网络的路由器就可以回答该请求，这个过程称为`ARP`代理（`Proxy ARP`）
1. 免费ARP：是指主机发送ARP查找自己的IP地址，通常它发生在系统引导期间进行接口配置的时候
    * 一个主机可以通过它来确定另一个主机是否设置了相同的IP地址
    * 使其他主机高速缓存中旧的硬件地址进行相应的更新（当某个主机更换了网卡接口的时候）。当某个主机收到了某个IP地址的ARP请求，而且它已经在接受者的高速缓存中，那么就要用ARP请求中的发送端硬件地址对高速缓存中相应的内容进行更新

# 5 RARP: 逆地址解析协议

1. 具有本地磁盘的系统引导时，一般从磁盘上的配置文件中读取`IP`地址。但是无盘机，需要采用其他方法来获得`IP`地址，这种方式就是`RARP`
1. 网络上的每个系统都有唯一的硬件地址，然后发送一份`RARP`请求，请求某个主机响应该误判系统的`IP`地址

# 6 ICMP: Internet控制报文协议

# 7 防火墙和网络地址转换

## 7.1 防火墙

1. 最常用的两种防火墙是`代理防火墙（proxy firewall）和包过滤防火墙（packet-filter）`。他们之间的主要区别是所操作的协议栈的层次以及由此决定IP地址和端口号的使用

### 7.1.1 包过滤防火墙

1. 包过滤防火墙能够过滤（filter）（丢弃）一些网络流量。他们一般都可以配置为丢弃或转发数据包头中符合（或不符合）特定标准的数据报，这些标准称为过滤器（filter）
1. 包过滤防火墙可以看做一个互联网路由器

### 7.1.2 代理防火墙

1. 代理防火墙，并不是真正意义上的互联网路由器。相反，它们本质上是运行一个或多个应用层网关（Application-Layer Gateways, ALG）的主机。该主机拥有多个网络接口，能够在应用层中继两个连接（或关联）之间的特定类型的流量

# 8 TCP: 传输控制协议（初步）

**ARP和重传**

1. Automatic Repeat Request, ARQ: 自从重复请求，是差错处理的一种非常重要的方法
1. 一个直接处理分组丢失（和比特差错）的方法是重发分组直到它被正确接收。这需要一个方法来判断，如下：
    * 接收方是否已收到分组
    * 接收方收到的分组是否与之前发送方发送的一样
    * 接收方给发送方发信号以确认自己已经接收到一个分组，这种方法称为确认（acknowledgment），或ACK。当发送方接收到这个ACK，它再发送另一个分组，这个过程就这样继续，但是会出现一些有意思的问题
        1. 发送方对一个ACK应该等待多长时间？
        1. 如果ACK丢失了怎么办？
        1. 如果分组被接收到了，但是里面有错怎么办？
1. 接收方可能受到被传送分组的重复副本，这个问题要使用序列号（sequence number）来处理

**分组窗口和滑动窗口**

1. 分组窗口（window）：已被发送方注入但还没完成确认的分组的集合。这个窗口中的分组数量称为窗口大小（window size）
    * 术语窗口来自这样的想法：如果你把在一个通信对话中发送的所有分组排成长长的一行，但只能通过一个小孔来观察它们，你就只能看到它们的一个自己---通过一个窗口观看一样
1. 当分组窗口中最左边的分组已收到ACK之后，窗口左侧的边界便可向右移动一格；窗口原右侧边界之外的第一个分组可以进入发送状态，随机进入分组窗口中，于是窗口的右侧边界便可向右移动一格，这便形成了分组窗口的滑动

**变量窗口：流量控制和拥塞控制**

1. 流量控制：用于解决当接收方相对发送方处理速度太慢时产生的问题，具体手段就是强迫发送方慢下来
1. 基于速率（rate-based）流量控制：给发送方指定某个速率，同时确保数据永远不能超过这个速率发送。这种类型的流量控制最适合流应用程序，可被用于广播和组播发现
1. 基于窗口（window-based）流量控制：窗口大小是不固定的，而且允许随时间而变动
    * 必须有一种方法可以通知发送方使用多大的窗口，一般称为窗口通告（window advertisement）或者窗口更新（window update）
1. 拥塞控制：发送方减低速度以不至于压垮其与接收方之间的网络

**设置重传超时**

1. 发送方在重发一个分组之前应等待的时间量大概是下面时间的总和
    1. 发送分组所用的时间
    1. 接收方处理它和发送一个ACK所用的时间
    1. ACK返回到发送方所用的时间
    1. 以及发送方处理ACK所用的时间
    * 遗憾的是，上述这些时间没有一个是固定不变的，都是随着环境的变化而变化的
1. 一个更好的策略是让协议实现尝试去估计这个重传超时时间，这称为往返时间估计（round-trip-time estimation, RTT），这是一个统计过程。总的来说，选择一组RTT样本的样本均值作为真实的RTT是最有可能的，这个平均值很自然地会随着时间而改变，因为通信穿过的网络路径可能会改变
1. 把重传超时时间设置为RTT均值是不合理的，因为很有可能许多实际的RTT将会比较大，从而会导致不必要的重传

**TCP服务模型**

1. TCP和UDP使用相同的网络层（IPv4或IPv6），但是TCP给应用程序提供了一种与UDP完全不同的服务。**TCP提供了一种面向连接的（connection-oriented）、可靠的字节流服务**。
1. 面向连接的：是指使用TCP的两个应用程序必须在它们可能交换数据之前，通过相互联系来建立一个TCP连接、就好像拨打一个电话号码，等待另一方接听电话并说“喂”，然后再说“找谁”。**因此，TCP中不存在广播、组播这种概念**，这两个概念与连接是矛盾的
1. 字节流服务：**TCP不会自动插入记录标志或消息边界**。例如，发送方可能分两次先后写入10字节、20字节，但是接收方可能一次性读入30字节，也有可能分3次每次读入10字节

**TCP中的可靠性**

1. TCP提供一个字节流接口，TCP必须把一个发送应用程序的字节流转换成一组IP可以携带的分组。这被称为组包

# 9 TCP连接管理

TCP服务模型是一个字节流。TCP必须检测并修补所有在IP层产生的数据传输问题，比如丢包、重复以及错误

## 9.1 TCP连接的建立与终止

1. 一个TCP连接由一个4元组构成，他们分别是两个IP地址和两个端口号
1. 一个TCP连接通常分为3个阶段：启动、数据传输和退出
    * ![fig](/images/TCP-IP详解-读书笔记/13-2-1.jpg)
1. TCP建连步骤如下：
    1. 主动开启者（通常称为客户端）发送一个SYN报文段，并指明自己想要连接的端口号和它的客户端初始序列号（`ISN(c)`）
    1. 服务器也发送自己的SYN报文段作为响应，并包含了它的初始序列号（`ISN(s)`）。此外，为了确认客户端的SYN，服务器将其包含的`ISN(c)`数值加1后作为返回的ACK数值。因此，每发送一个SYN，序列号就会自动加1。这样如果出现丢失的情况，该SYN段将会重传
    1. 为了确认服务器的SYN，客户端将`ISN(s)`的数值加1后作为返回的ACK值
    * 三次握手的目的不仅在于让通信双方了解一个连接正在建立，还在于利用数据包的选项来承载特殊的信息，交换初始序列号（Initial Sequence Number, ISN）
1. TCP关闭步骤如下：
    1. 连接的主动关闭者发送一个FIN报文段，指明接受者希望看到的自己当前的序列号（图中的`K`），FIN段还包含了一个ACK段用于确认对方最近一次发来的数据（图中的`L`）
    1. 连接的被动关闭者将`K`的数值加1作为响应的ACK值，以表明它已经成功接收到主动关闭者发送的`FIN`。此时，上层的应用程序会被告知连接的另一端已经提出了关闭的请求。通常，这将导致应用程序发起自己的关闭操作。接着，被动关闭者将身份转变为主动关闭者，并发送自己的FIN。该报文段的序列号为`L`
    1. 为了完成连接的关闭，最后发送的报文段还包含一个ACK用于确认上一个FIN。值得注意的是，如果出现FIN丢失的情况，那么发送方将重新传输直到接收到一个ACK确认为止
1. 通常情况下，建立一个TCP连接需要3个报文段，而关闭一个TCP连接需要4个报文段。此外，TCP的通信模型是双向的，因此还支持半开启/半关闭（很少见）
    * 半开启：只有一个方向正在进行数据传输
    * 半关闭：仅关闭数据流的一个方向
    * 这两个概念描述的可能是同一个状态，只不过角度不同
1. 伯克利套接字的API提供了半关闭操作，用`shutdown()`来代替`close()`
    * 首次发送的两个报文段，与TCP正常关闭时完全相同：主动关闭者发送FIN，被动关闭者回应该FIN的ACK
    * 被动关闭者可以发送任意数量的数据段
    * 当被动关闭者完成数据发送后，他将会发送一个FIN来关闭本方连接，同时向发起半关闭的应用程序发出一个文件尾提示
    * 当第二个FIN被确认后，整个连接完全关闭
    * ![fig](/images/TCP-IP详解-读书笔记/13-2-2.jpg)
1. 同时打开：通信双方在接收到来自对方的SYN之前必须先发送一个SYN（这种情况其实非常少见，但是对于TCP协议的实现来说，必须要考虑这种情况）。
    * 同时打开过程需要交换4个报文段，比普通的三次握手增加了一个
    * ![fig](/images/TCP-IP详解-读书笔记/13-2-3.jpg)
1. 同时关闭：与普通关闭并无太大区别，因为通信双方都需要主动提出关闭请求
    * ![fig](/images/TCP-IP详解-读书笔记/13-2-4.jpg)
1. 初始序列号：TCP报文段在经过网络路由后可能会存在延迟抵达与排序混乱的情况，初始序列号就是为了解决这个问题
    * 在发送用于建立连接的SYN之前通信双方都会选择一个初始序列号。初始序列号会随着时间递增，它被设计成一个32位的计数器，该计数器每4微妙增加1
    * TCP连接由四元组确定，因此即便是同一个连接也会出现不同的实例（同样的四元组建连关闭，再建连再关闭，就是2个不同的实例）
    * 一个TCP报文段只有同时具备连接的四元组与当前活动窗口的序列号，才会在通信过程中被对方认为是正确的的。这也侧面反映了TCP的脆弱性。如果不加以限制，任何人只要知道四元组，就能伪造TCP报文段，从而干扰正常连接
    * 现代系统通常采用半随机的方法选择初始序列号
1. 连接建立超时
    * `net.ipv4.tcp_syn_retries(/proc/sys/net/ipv4/tcp_syn_retries)`：一次主动打开申请中尝试重新发送SYN报文段的最大次数
    * `net.ipv4.tcp_synack_retries(/proc/sys/net/ipv4/tcp_synack_retries)`：表示响应对方的一个主动打开请求时尝试重新发送SYNC+ACK报文段的最大次数

## 9.2 TCP选项

| 种类 | 长度 | 名称 | 参考 | 目的与描述 |
|:--|:--|:--|:--|:--|
| 0 | 1 | EOL | [RFC0793] | 选项列表结束 |
| 1 | 1 | NOP | [RFC0793] | 无操作（用于填补） |
| 2 | 4 | MSS | [RFC0793] | 最大段大小 |
| 3 | 3 | **WSOPT** | [RFC01323] | **窗口放缩因子** |
| 4 | 2 | SACK-Permitted | [RFC02018] | 发送者支持SACK选项 |
| 5 | 可变 | SACK | [RFC02018] | SACK阻塞（接收到乱序数据） |
| 8 | 10 | TSOPT | [RFC01323] | 时间戳选项 |
| 28 | 4 | UTO | [RFC05482] | 用户超时（一段空闲时间后的终止） |
| 29 | 可变 | TCP-AO | [RFC05925] | 认证选项（使用多种算法) |
| 253 | 可变 | Experimental | [RFC04727] | 保留供实验室所用 |
| 254 | 可变 | Experimental | [RFC04727] | 保留供实验室所用 |

1. TCP支持的选项如上表，种类指明了该选项的类型，不能被理解的选项会被直接忽略

### 9.2.1 最大段大小选项

1. 最大段大小是指TCP协议锁允许的从对方接收到的最大报文段，且只记录TCP数据的字节数（不包括其他相关的TCP与IP头部）。默认为536字节。**经典设置值是1460（1460字节的TCP数据+20字节的TCP协议头+20字节的IP协议头=1500，这是MTU的经典设置值）**

### 9.2.2 选择确认选项

1. TCP的选择确认选项（SACK）能够让发送方了解到接收方的窗口信息，从而能够更好地进行重传
1. SACK选项包含了一组SACK块，每个SACK块包含了接收方已经成功接收的数据块的序列号范围，由一对32位的序列号表示。因此，一个SACK选项包含了n个SACK块，长度为(8n+2)
1. 同时，由于TCP头部选项空间是有限的。因此，一个报文段中发送的最大SACK块的数量为3

### 9.2.3 窗口缩放因子

1. 根据[RFC1323]，窗口缩放选项（表示为`WSCALE`或`WSOPT`）能够有效地将TCP窗口字段的范围从16位增加至30位。TCP头部不需要改变窗口字段的大小，仍然维持16位的数值。同时，使用另一个选项作为这16位数值的比例因子。该比例因子能够使窗口字段有效地左移
1. 比例因子最小是0，最大是14，当比例因子是14时，能提供一个最大为{% raw %}$(65536\ *\ 2^{14})${% endraw %}的窗口，该数据接近1GB。因此TCP使用一个32位的值来维护这个"真实"的窗口大小
1. 该选项只能出现于一个SYN报文段中。因此当连接建立之后，比例因子也是与方向有关的。为了保证窗口的调整，通信双方都需要在SYN报文段中包含该选项
1. 默认的比例因子是0

### 9.2.4 时间戳选项与防回绕序列号

1. 时间戳选项（TSOPT）要求发送方在每个报文段中添加2个4字节的时间戳数值。接收方会在确认中反映这些数值（`原封不动传回去`），允许发送方针对每一个接收到的ACK估算TCP连接的往返时间（由于TCP协议经常利用一个ACK来确认多个报文段，此处必须指出“是每个接收到的ACK”而不是“每个报文段”）。关于这部分细节，在`TCP数据流与窗口管理`一章中会详细讨论，这里不展开
1. 该选项并不要求在两台主机之间进行任何形式的时钟同步（比如一端用的是北京时间，一端用的是纽约时间），**两个时间戳都是同一侧产生的（发送方发包时产生一个时间戳，发送方接收ACK时产生一个时间戳，根据这两个时间戳的差值便可计算）**，因此只要每一端保证单调递增即可
1. TCP的序列号是32位的，是个有限的数值，因此它是会循环的。而时间戳选项可以帮助`接收者`有效区分新旧报文，这被称为`防回绕序列号（Protection Against Wrapped Sequence numbers, PAWS）`
    * 如果报文段的时间戳与当前时间戳的间隔超过`MSL（一个报文段在网络中存在的最大时间）`时，根据防回绕序列号算法，会将其丢弃
    * 由于接收方和发送方时钟不同步，接收方只能得知下一个发送方发送的报文段的最小时间戳（记为`MIN_NEXT_TIMESTAMP`)，一定比上一次收到的报文段的时间戳要大（发送方必须确保时间戳单调递增）。因此，当报文段到达的时候，如果`MIN_NEXT_TIMESTAMP - TIME_STAMP > MSL`，那么报文将被丢弃 

### 9.2.5 用户超时选项

1. `用户超时（UTO）`选项的数值`USER_TIMEOUT`指明了TCP发送者在确认对方未能成功接收数据之前愿意等待该数据ACK确认的时间
1. 用户超时选项的数值是建议性的，另一端并不一定要遵从
1. 一般建议值如下
    * 规则1：当TCP连接打到3次重传阈值时应该通知应用程序
    * 规则2：当超时大于100秒时应该关闭连接

### 9.2.6 认证选项

1. TCP设置了一个选项用于增强连接的安全性。通信双方必须采用一种方法在TCP认证选项运行之前建立出一套共享秘钥
1. 发送数据时，TCP会根据共享秘钥生成一个通信秘钥。接收者装配有相同的秘钥，同样也能够生成通信秘钥
1. 由于需要创建并分发一个共享秘钥，该选项并未得到广泛使用

## 9.3 TCP的路径最大传输单元发现

1. 路径最大传输单元（MTU）是指经过两台主机之间路径的所有网络报文段中最大传输单元的最小值。知道路径最大传输单元后能够有助于一些协议（比如TCP）避免分片
1. `分组层路径最大传输单元发现（Packetization Layer Path MTU Discovery, PLPMTUD）`，该算法可以为TCP以及其他协议计算路径最大传输单元，**同时避免使对ICMP的使用（为什么要避免使用ICMP？）**
    * 在该算法中，利用`IPv6`协议中的”数据包太大“`（PTB，Packet Too Big）`来代表ICMPv4地址不可达（需要分片）或ICMPv6数据包太大的消息
1. TCP常规的路径最大传输单元发现过程如下：
    1. 在一个连接建立时，TCP使用对外接口的最大传输单元的最小值，或者根据通信对方声明的最大段大小来选择发送方的最大段大小（SMSS）。`路径最大传输单元发现`不允许TCP发送方有超过另一方声明的最大段大小的行为。如果对方没有指明最大段大小的数值，发送方将假设采用默认的536字节
    1. 一旦为发送方的最大段大小选定了初始值，TCP通过这条连接发送的所有IPv4数据报都会对DF位字段进行设置。**TCP/IP没有DF位字段，因此只需要假设所有的数据报都已经设置了该字段而不必进行实际操作**
    1. 如果接收到了PTB消息，TCP就会减少段的大小，然后用修改过的段进行重传。如果在PTB消息中已经包含了下一跳推荐的最大传输单元，数据段大小的数值可以设置为下一跳最大传输单元的数值减去IPv4（或IPv6）与TCP头部的大小；如果下一跳最大传输单元的数值不存在，发现者可能需要尝试多个数值（例如二分法）
    1. 由于路由是动态变化的，在减少段大小的数值一段时间后需要尝试一个更大的数值（接近初始的发送方最大段大小），该时间间隔大约为10分钟
1. 在互联网环境中，由于防火墙阻塞PTB消息，路径最大传输单元发现过程会存在一些问题
    1. 如果TCP的实现依靠ICMP消息来调整它的段大小的情况下，如果TCP从未接收到任何ICMP消息，那么在路径最大传输单元发现过程中就会造成黑洞问题。其原因可能是防火墙或NAT配置禁止转发ICMP消息
    1. 一些TCP的实现具有“黑洞探测”功能，当一个报文在反复重传数次后，将会尝试发送一个较小的报文段

## 9.4 TCP状态转换

![fig](/images/TCP-IP详解-读书笔记/13-5-1.jpg)

1. 状态图解释
    * 椭圆表示状态
    * 箭头表示状态转换
1. **只有一部分状态转移被认为是“典型的”**
    * 客户端典型的状态转移用深黑色的实线箭头表示
    * 服务端典型的转台转移用虚线箭头表示

![fig](/images/TCP-IP详解-读书笔记/13-5-2.jpg)

1. `SYN_SENT`：主动发起者发出SYN(K)后，进入到该状态，等待对方回复ACK(K+1)
1. `SYN_RCVD`：被动发起者收到SYN(K)，且回复ACK(K+1)以及SYN(L)之后，进入到该状态，等待对方回复ACK(L+1)
1. `ESTABLISHED`：有两种情况
    * 主动发起者收到ACK(K+1)以及SYN(L)，并回复ACK(L+1)之后，进入到该状态
    * 被动发起者收到ACK(L+1)之后，进入到该状态
1. `FIN_WAIT_1`：主动关闭者发送FIN(M)之后，进入到该状态
1. `CLOSE_WAIT`：被动关闭者收到FIN(M)之后，并回复ACK(M+1)之后，进入到该状态。此时，连接的一个方向已关闭，等待另一个方向的数据传输完毕并发送FIN
1. `FIN_WAIT_2`：主动关闭者收到对方发送的ACK(M+1)之后，进入到该状态。此时，连接的一个方向已关闭，等待另一个方向的数据传输完毕并发送FIN
1. `LAST_ACK`：被动关闭者传输完毕所有数据，发送FIN(N)之后，进入到该状态
1. `TIME_WAIT`：主动关闭者收到FIN(N)，且回复ACK(N+1)之后，进入到该状态
1. `CLOSED`：有两种情况
    * 当被动关闭者收到ACK(N+1)之后，进入到该状态
    * 当主动关闭者等待`2MSL`之后，将会从`TIME_WAIT`进入到该状态

### 9.4.1 TIME_WAIT状态

1. `TIME_WAIT`状态也称为`2MSL`等待状态。在该状态中，TCP将会等待两倍于最大段生存期（Maximum Segment Lifetime，MSL）的时间，有时也被称作加倍等待。它代表任何报文段在被丢弃前在网络中被允许存在的最长时间。这个时间是有限的，因为TCP报文段是以IP数据报的形式传输的，IP数据报拥有TTL字段和条数限制字段。这两个字段限制了IP数据报的有效生存时间
1. [RFC0793]将最大段生存期设置为2分钟。在常见的实现中，最大段生存期的数值可以为30秒、1分钟或2分钟。在linux系统中，`net.ipv4.tcp_fin_timeout（/proc/sys/net/ipv4/tcp_fin_timeout）`记录了`2MSL`状态需要等待的超时时间
1. 当TCP执行一个主动关闭并发送最终的ACK时，连接必须处于`TIME_WAIT`状态并持续两倍于最大生存期的时间。这样就能够让TCP重新发送最终的ACK以避免出现丢失的情况。重新发送最终的ACK并不是因为TCP重传了ACK（ACK不消耗序列号，也不会被TCP重传），而是因为通信另一方重传了它的FIN（它消耗一个序列号）。事实上，TCP总是重传FIN，直到它收到一个最终的ACK
1. **当TCP处于`2MSL`等待状态时，该连接（四元组）不可重新使用（一些实现施加了更加严格的约束，在这些系统中，如果一个端口号处于`2MSL`等待状态，那么该端口号将不能再次被使用）。许多实现和API都提供了绕开这一约束的方法，在伯克利套接字API中`SO_REUSEADDR`套接字选项就支持绕开该操作**
1. 对于交互式的应用程序而言，客户端通常执行主动关闭操作并进入`TIME_WAIT`状态，服务器通常执行被动关闭操作并且不会直接进入`TIME_WAIT`状态

### 9.4.2 静默时间的概念

1. 在TCP四元组都相同的情况下，`2MSL`状态能够防止新的连接将前一个连接的延迟报文段解释成自身数据的情况。如果一台处于`TIME_WAIT`状态下的连接相关联的主机崩溃，然后在`MSL`内重新启动，并且使用与主机崩溃之前处于`TIME_WAIT`状态的连接相同的IP地址与端口号，那么该连接在主机崩溃之前产生的延迟报文段会被认为属于主机重启后创建的新连接。**为了防止上述情况发生，[RFC0793]指出在崩溃或重启后TCP协议应当在创建新的连接之前等待相当于一个`MSL`的时间。该段时间被称为静默时间（只有极少数TCP的实现遵循了这一点，因为如果上层的应用程序自己做了校验或加密，那么这种错误会很容易判断出来）**

### 9.4.3 FIN_WAIT_2状态

1. `FIN_WAIT_2`状态表达式：某TCP通信端已发送一个FIN并已得到另一端的确认
1. 只有收到了另一端的FIN之后，才会从`FIN_WAIT_2`状态转移到`TIME_WAIT`状态，这意味着连接的一端能够永远保持这种状态（另一端会处于`CLOSED_WAIT`状态）
1. 许多方法都能防止连接进入`FIN_WAIT_2`这一无限等待状态：如果负责关闭的应用程序执行的是一个完全关闭操作，而不是用一个半关闭来指明它还期望接收数据，那么就会设置一个计时器。如果当计时器超时时，连接是空闲的，那么TCP连接就会转移到`CLOSED`状态。在Linux中，可以通过调整`net.ipv4.tcp_fin_timeout（/proc/sys/net/ipv4/tcp_fin_timeout（）`的数值来设置计时器的秒数，默认是60s

### 9.4.4 同时打开与关闭的转换

1. 同时打开
    1. 通信两端几乎在相同的时刻都会发送一个SYN报文段，然后它们进入`SYN_SENT`状态
    1. 当它们接收到对方发来的SYN报文段时会将状态迁移至`SYN_RCVD`，然后重新发送一个新的SYN并确认之前收到的SYN
    1. 当通信两端都收到了SYN与ACK，它们的状态都会迁移至`ESTABLISHED`状态
1. 同时关闭
    1. 通信两端的状态都会从`ESTABLISHED`状态迁移至`FIN_WAIT_1`状态。与此同时，都会向对方发送一个FIN
    1. 在接收到对方发来的FIN之后，本地通信段的状态将从`FIN_WAIT_1`状态迁移至`CLOSING`状态，通信双方还会发送最终的ACK
    1. 当接收到最终的ACK后，每个通信段会将状态更改为`TIME_WAIT`，从而初始化`2MSL`等待过程

## 9.5 重置报文段

1. **一个将`RST`字段置位的报文段被称作“重置报文段”或简称为“重置”**
1. 一般来说，当发现一个到达的报文段相对于关联连接而言是不正确时，TCP就会发送一个重置报文段
1. 重置报文段通常会导致TCP连接的快速拆卸

### 9.5.1 针对不存在端口的连接请求

1. 一般而言，当一个连接请求到达本地却没有相关进程在目的端口侦听时，就会产生一个重置报文段
    * UDP使用ICMP目的不可达（端口不可达）消息来表示端口不可用
    * TCP使用重置报文段来代替ICMP消息
1. 对于一个被TCP端接收的重置报文段而言，它的ACK位字段必须被置位，并且ACK的序列号数值必须在正确的窗口范围内，这样有助于防止一种简单的攻击：在这种攻击中，任何人都能够生成一个与相应连接（4元组）匹配的重置报文段，从而扰乱这个连接

### 9.5.2 终止一条连接

1. 终止一条连接的正常方法是由通信一方发送一个FIN，这种方法有时被称为`有序释放`，这种方式通常不会出现丢失数据的情况
1. 在任何时刻，我们都可以通过发送一个重置报文段替代FIN终止一条连接，这种方式有时被称为`终止释放`
1. 终止一条连接可以为应用程序提供两大特性
    1. 任何排队的数据都将被抛弃，一个重置报文段会被立即发送出去
    1. 重置报文段的接收方会说明通信一端采用了终止的方式而不是一次正常关闭
1. 套接字API通过将“逗留于关闭”套接字选项（`SO_LINGER`)数值设为0来实现上述功能。该参数设置为0表示：不会在终止之前为了确定数据是否到达另一端而逗留任何时间
1. 重置报文段中包含了一个序列号与一个确认号。重置报文段不会令通信另一端做出任何响应---它不会被确认。接收重置报文段的一端会终止连接并通知应用程序当前连接已被重置。通常会看到“连接被另一端重置（Connection reset by peer）”的错误提示

### 9.5.3 半开连接

1. 如果在未告知另一端的情况下通信一端关闭或终止连接，那么就认为该条连接处于半开状态。这种情况通常发生在通信一方主机崩溃的情况下。只要不尝试通过半开连接传输数据，正常工作的一端将不会检测出另一端已经崩溃
1. 产生半开连接的另一个共同原因是某一台主机的电源被切断而不是被正常关机
1. 可以利用TCP的keepalive选项发现另一端已经消失

### 9.5.4 时间等待错误

1. 设计`TIME_WAIT`状态的目的是允许任何受制于一条关闭连接的数据报被丢弃。在这段时期，等待的TCP通常不需要做任何操作，它只需要维持当前状态直到`2MSL`的计时结束。然而，如果它在这段时间期内接收到来自于这条连接的一些报文段，或是更加特殊的重置报文段，它将会被破坏。这种情况被称为`时间等待错误`（TIME_WAIT Assassination，TWA）

![fig](/images/TCP-IP详解-读书笔记/13-6-1.jpg)

1. 在上述例子中，服务器完成了其在连接中的角色所承担的工作并清除了所有状态，客户端依然保持`TIME_WAIT`状态。当完成FIN交换，客户端的下一个序列号为K，而服务器的下一个序列号为L。最近到达的报文段是由服务器发送至客户端，它使用的序列号为L-100，包含的ACK号为K-200。当客户端收到这个报文段时，它认为序列号与ACK号的数值都是旧的。因此发送一个ACK作为响应，其中包含了最新的序列号和ACK号（分别是K与L）。然而，当服务器收到这个报文段后，它没有关于这条连接的任何信息，因此发送一个重置报文段作为响应，这会使得客户端过早得从`TIME_WAIT`状态转移至`CLOSED`状态。因此，许多系统规定处于`TIME_WAIT`状态时不对重置报文段作出反应，从而避免了上述问题

## 9.6 与TCP连接管理相关的攻击

### 9.6.1 SYN泛洪

1. SYN泛洪是一种TCP拒绝服务攻击，在这种攻击中一个或多个恶意的客户端产生一系列TCP连接尝试（SYN报文段），并将它们发送给一台服务器，它们通常采用“伪造”的源IP地址。服务器会为每一条连接分配一定数量的连接资源。由于连接尚未完全建立，服务器为了维护大量的板打开连接会耗尽自身内存后拒绝为后续的合法连接请求服务
1. `SYN cookies`是解决SYN泛洪问题的一种机制，**它的主要思想是，当一个SYN到达时，这条连接存储的大部分信息都会被编码并保存在SYN+ACK报文段的序列号字段**。采用`SYN cookies`的目标主机不需要为进入的连接请求分配任何存储资源--只有当SYN+ACK报文段本身被确认后（并且已返回初始序列号）才会分配真正的内存
1. 服务器在接收到一个SYN后会采用下面的方法设置初始序列号（保存于SYN+ACK报文段，供于客户端）的数值
    * 首5位是t模32的结果，其中t是一个32位的计数器，每个64秒增加1
    * 接着3位是服务器最大段大小（8种可能之一）的编码值；剩余的24位保存了4元组与t值的散列值
1. **这种方法有2个缺陷，因此这一功能未作为默认设置**
    * 需要对最大段大小进行编码，这种方法禁止使用任意大小的报文段
    * 计数器会回绕，连接建立过程会因周期非常长（长于64秒）而无法正常工作

### 9.6.2 劫持

1. 如何实现劫持
    * 在连接建立过程中引发不正确的状态传输（类似于时间等待错误）
    * 在`ESTABLISHED`状态下产生额外的数据（被攻击者认为连接已经建立，其实是和攻击者建立的连接）
    * 于是攻击者就能在连接中注入新的流量

### 9.6.3 欺骗攻击

1. 这类攻击所涉及的TCP报文段都是攻击者精心定制的，目的在于破坏或改变现有TCP连接的行为
1. 攻击者可以生成一个伪造的重置报文段并将其发送给一个TCP通信节点，假定与连接相关的4元组以及校验和都是正确的，序列号也处在正确的范围。这样就会造成连接的任意一端失败

# 10 TCP超时与重传

## 10.1 概要

1. 当数据段或确认信息丢失，TCP启动重传操作，重传尚未确认的数据
1. TCP拥有两套独立机制来完成重传，一是基于时间，二是基于确认信息的构成。第二种方法通常比第一种方法更有效
1. TCP在发送数据时会设置一个计时器，若至计时器超时仍未收到数据确认信息，则会引发相应的`超时`或`基于计时器的重传`操作，计时器超时称为`重传超时（RTO）`
1. 另一种方式称为`快速重传`，通常发生在没有延时的情况下。若TCP累积确认无法返回新的ACK，或者当ACK包含的选择确认信息（SACK）表明出现失序报文段时，快速重传会推断出现丢包

## 10.2 简单的超时与重传

## 10.3 设置重传超时

1. RTT（Round Trip Time）和RTO（Retransmission Timeout）
    * 若TCP先于RTT开始重传，可能会在网络中引入不必要的重复数据
    * 若延迟远大于RTT的间隔发送重传数据，整体网络利用率（及单个连接吞吐量）会随之下降
1. RTT的测量较为复杂，根据路由与网络资源的不同，它会随时间而改变。TCP必须跟踪这些变化并适时做出调整来维持好的性能
1. **TCP在收到数据后会返回确认信息，因此可在该信息中携带一个字节的数据（采用一个特殊序列号，注意，不是TCP的时间戳选项）来测量传输该确认信息所需的时间，每个此类的测量称为`RTT样本`**

### 10.3.1 经典方法

1. 最初的TCP规范[RFC0793]采用如下公式计算得到平滑的RTT估计值（称为SRTT）
    * {% raw %}$$SRTT ← \alpha(SRTT) + (1 - \alpha)RTT_s$${% endraw %}
    * 其中{% raw %}$RTT_s${% endraw %}是新的样本值，常量{% raw %}$\alpha${% endraw %}为平滑因子，推荐值为`0.8~0.9`
1. 这种估算方法称为指数加权移动平均，或低通过滤器
1. [RFC0793]推荐根据如下公式设置RTO
    * {% raw %}$$RTO = min(ubound, max(lbound, (SRTT)\beta)$${% endraw %}
    * 其中{% raw %}$\beta${% endraw %}为离散因子，推荐之为`1.3~2.0`，`ubound`为RTO的上边界（建议值1分钟），lbound为RTO的下边界（建议值1s）
1. 对于相对稳定的RTT分布来说，这种方法能取得不错的性能。若TCP运行于RTT变化较大的网络中，则无法获得期望的效果

### 10.3.2 标准方法

1. 可以通过记录RTT测量值的变化情况以及均值来得到较为准确的估计值。基于均值和估计值的变化来设置RTO，将比仅使用均值的常数倍来计算RTO更能适应RTT变化幅度较大的情况
1. 平均偏差（mean deviation）是对标准偏差的一种好的逼近。计算标准差需要对方差进行平方根运算，对于快速TCP实现来说代价较大
1. 可对每个RTT测量值{% raw %}$M${% endraw %}（前面称为{% raw %}$RTT_s${% endraw %}）采用如下算式 
    * {% raw %}$srtt${% endraw %}值代替了之前的SRTT，且{% raw %}$rttvar${% endraw %}为平均偏差的EWMA，而非采用先前的{% raw %}$\beta${% endraw %}来设置RTO
{% raw %}$$
srtt ← (1 - g)(srtt) + (g)M \\
rttvar ← (1 - h)rttvar +(h)(|M - srtt|) \\
RTO = srtt + 4(rttvar)
$${% endraw %}

1. 上述算式可以简化为
    * {% raw %}$srtt${% endraw %}为均值的EWMA，{% raw %}$rttvar${% endraw %}为绝对误差{% raw %}$|Err|${% endraw %}的EWMA，{% raw %}$Err${% endraw %}为测量值{% raw %}$M${% endraw %}与当前RTT估计值{% raw %}$srtt${% endraw %}之间的偏差
    * {% raw %}$srtt${% endraw %}与{% raw %}$rttvar${% endraw %}均用于计算RTO且随时间变化
    * 增量{% raw %}$g${% endraw %}为新RTT样本{% raw %}$M${% endraw %}占{% raw %}$srtt${% endraw %}估计值的权重，取{% raw %}$1/8${% endraw %}
    * 增量{% raw %}$h${% endraw %}为新平均偏差样本（新样本{% raw %}$M${% endraw %}与当前平均值{% raw %}$srtt${% endraw %}之间的绝对误差）占偏差估计值{% raw %}$rttvar${% endraw %}的权重，取{% raw %}$1/4${% endraw %}
    * g和h取值为2的负幂次，使得计算过程较为简单，只需要移位和加法即可
{% raw %}$$
Err = M - srtt \\
srtt ← srtt + g(Err) \\
rttvar ← rttvar + h(|Err| - rttvar) \\
RTO = srtt + 4(rttvar)
$${% endraw %}

#### 10.3.2.1 时钟粒度与RTO边界

1. 时钟粒度会影响RTT的测量以及RTO的设置。在[RFC6298]中，粒度用于优化RTO的更新情况，并给RTO设置一个下界
    * 这里G为计时器粒度，1000ms为RTO的下界值。因此RTO至少为1s
{% raw %}$$
RTO = max(srtt + max(G, 4(rttvar)), 1000)
$${% endraw %}

#### 10.3.2.2 初始值

1. 在首个SYN交换前，TCP无法设置RTO初始值。除非系统提供（有些系统在转发表中缓存了该信息），否则也无法设置估计器的初始值
1. 根据[RFC6298]，RTO的初始值为1s，而初始SYN报文段采用的超时时间间隔为3s
1. 当接收到首个RTT的测量结果M，估计器按如下方式进行初始化
{% raw %}$$
srtt ← M \\
rttvar ← M/2
$${% endraw %}

#### 10.3.2.3 重传二义性与Karn算法

1. 在测量RTT样本的过程中若出现重传，就可能导致某些问题。**假设一个包的传输出现超时，该数据包会被重传，接着收到一个确认信息。那么该信息是对第一次还是第二次传输的确认就存在二义性**
1. [KP87]指出，当出现超时重传时，接收到重传数据的确认信息时不能更新RTT估计值。**这是Karn算法的第一部分**
1. 如果我们在设置RTO过程中简单将重传问题完全忽略，就可能将网络提供的一些有用信息也同时忽略
1. TCP在计算RTO过程中采用一个退避系数（backoff factor），每当重传计时器出现超时，退避系数加倍，该过程一直持续至接收到非重传数据。此时，退避系数重新设为1，重传计时器返回正常值。**这是Karn算法的第二部分**
1. **Karn算法定义**：当接收到重复传输（即至少重传一次）数据的确认信息时，不进行该数据包的RTT测量，可以避免重传二义性问题。另外，对数据后续的包采取退避策略。仅当接收到未经重传的数据时，该SRTT采用与计算RTO
1. Karn算法一直作为TCP实现的必要方法。当然也有例外情况，在使用TCP时间戳选项的情况下，可以避免二义性，因此在这种情况下，Karn算法的第一部分不适用

#### 10.3.2.4 带时间戳选项的RTT测量

1. 时间戳值（TSV）携带于初始SYN的TSOPT中，并在SYN+ACK的TSOPT的TSER部分返回，以此设定srtt、rttvar与RTO的初始值
1. 由于初始SYN可看做数据（即同样采取丢失重传策略且占用一个序列号），应测量其RTT值。其他报文段包含TSOPT，因此可结合其他样本值估算该连接的RTT
1. 该过程看似简单但实际存在很多不确定因素，因为TCP并非对接收到的每个报文段都返回ACK。例如，当传输大批量的数据时，TCP通常采取每两个报文段返回一个ACK的方法。另外，当数据出现丢失、失序、或重传成功时，TCP的累积确认机制表明报文段与其ACK之间并非严格的一一对应关系
1. 为了解决上述问题，采用如下算法来测量RTT样本值
    * TCP发送端：
        1. 在其发送的每个报文段的TSOPT的TSV部分携带一个32比特的时间戳值。该值包含数据发送时刻的TCP时钟值
        1. 接收到ACK后，将当前TCP时钟减去TSOPT的TSER部分的值，得到的差值即为新的RTT样本估计值。**注意，如果该ACK没有使得窗口前移，那么该ACK的TSER将被忽略，例如发生丢包时重复的ACK**
    * TCP接收端：
        1. 用一个名为`TsRecent`的变量记录收到的TSV值
        1. 用一个名为`LastACK`的变量记录其上一个发送的ACK序列号。回忆一下，ACK号代表接收端（即ACK的发送方）期望接收的下一个有序序号
        1. 发送任何一个ACK都包含TSOPT，其中，TSER部分的值为变量`TsRecent`的值
        1. 当一个新的报文段到达TCP接收端时，如果其序号与变量`LastACK`的值吻合（即为下一个期望接收的报文段），则将变量`TsRecent`的值更新为这个新报文段的TSV值

### 10.3.3 Linux采用的方法

1. Linux的RTT测量过程与标准方法有所差别。它采用的时钟粒度为1ms，与其他实现方法相比，其粒度更细，TSOPT也是如此。采用更频繁的RTT测量与更细的时钟粒度，RTT测量也更为精确，但也易于导致rttvar值随时间减为最小。这是由于当累积了大量的平均偏差样本时，这些样本之间易产生相互抵消的效果。这是其RTO设置区别于标准方法的一个原因
1. **此外，当某个RTT样本显著低于现有的RTT估计值srtt时，标准方法会增大rttvar**。为了更好地理解这个问题，首先回顾一下RTO通常设置为{% raw %}$srtt + 4(rttvar)${% endraw %}。因此，无论最大RTT样本值是大于还是小于srtt，rttvar的任何大的变动都会导致RTO增大（这与直觉相反--若实际RTT大幅降低，RTO应该减小才对）Linux通过减小RTT样本值大幅下降对rttvar的影响来解决这一问题
1. 与标准方法一样，Linux也记录变量srtt与rttvar值，但同时还记录两个新的变量，即mdev和mdev_max
    * **mdev为采用标准方法的瞬时平均偏差估计值，即前面方法的rttvar**
    * **mdev_max则记录在测量RTT样本过程中的最大mdev，其最小值不小于50ms**
    * **另外，rttvar需定期更新已保证其不小于mdev_max，因此RTO不会小于200ms**

![fig](/images/TCP-IP详解-读书笔记/14-3-1.jpg)

* 上述示例中，初始RTT测量值如下
    * {% raw %}$srtt = 16ms${% endraw %}
    * {% raw %}$mdev = (\frac{16}{2})ms = 8ms${% endraw %}
    * {% raw %}$rttvar = mdev\_max = max(mdev, TCP\_RTO\_MIN) = max(8, 50) = 50ms${% endraw %}
    * {% raw %}$RTO = srtt + 4(rttvar) = 16 + 4(50) = 216ms${% endraw %}
* 在初始SYN交换后，发送端对接收端的SYN返回一个ACK，接收端则进行一次相应的窗口更新
* 当应用首次执行写操作，发送端TCP发送两个报文段（seq=1，seq=1401），每个报文段包含一个值为127的TSV。由于两次发送间隔小于1ms（发送端TCP时钟粒度），因此这两个值相等
* 接收端变量`LastACK`记录上一个发送ACK的序列号，此时是1。当序列号为1的报文段到达时，将`TsRecent`变量更新为新接收分组的TSV，即127；序列号为1401的报文段到达时，由于该序列号与`LastACK`记录的值不同，因此不更新`TsRecent`变量。接收端返回ACK时，需要在TSER部分包含`TsRecent`变量的值，同时更新`LastACK`的值为2801
* 当序列号为2801的ACK到达发送端时，TCP就可以进行第二个RTT样本的测量。首先获得当前TCP时钟值，减去已接收ACK包含的TSER，即样本值{% raw %}$m = 233 - 127 = 96${% endraw %}，Linux按如下步骤更新变量
    * {% raw %}$mdev = mdev(\frac{3}{4}) + |m - srtt|(\frac{1}{4}) = 8(\frac{3}{4}) + |80|(\frac{1}{4}) = 26ms${% endraw %}
    * {% raw %}$mdev\_max = max(mdev\_max, mdev) = max(50, 26) = 50ms${% endraw %}
    * {% raw %}$srtt = srtt(\frac{7}{8}) + m(\frac{1}{8}) = 16(\frac{7}{8}) + 96(\frac{1}{8}) = 14 + 12 = 26ms${% endraw %}
    * {% raw %}$rttvar = mdev\_max = 50ms${% endraw %}
    * {% raw %}$RTO = srtt + 4(rttvar) = 26 + 4(50) = 226ms${% endraw %}
1. 若每个窗口只测量一个RTT样本，rttvar相对变动则较小。利用时间戳和对每个包的测量就可以得到更多的样本值。但同时，短时间内得到的大量样本值可能导致平均偏差变小（接近0，基于大数定理）。为了解决这个问题，Linux维护瞬时平均偏差估计值mdev，但设置RTO时则基于rttvar（在一个窗口数据期间记录的最大mdev，且最小值为50ms）。仅当进入下一个窗口时，rttvar才可能减小
1. 标准方法中，rttvar所占权重较大（系数为4），因此即使当RTT减小时，也会导致RTO增长。在时钟粒度较粗时，这种情况不会造成很大影响，因为RTO可用值很少。若时钟粒度较细，如Linux的1ms，就可能出现问题。针对RTT减小的情况，若新样本值小于RTT估计范围的下界（srtt - mdev），则减小新样本的权重，完整的关系如下
{% raw %}$$
if (m < (srtt - mdev)) \\
mdev = (\frac{31}{32})mdev + (\frac{1}{32})|srtt-m| \\
else \\
mdev = (\frac{3}{4})mdev + (\frac{1}{4})|srtt-m|
$${% endraw %}

### 10.3.4 RTT估计器行为

1. Linux的RTO始终保持在200ms以上，且避免了所有不必要的重传（尽管可能由于RTO较大，计时器未超时，导致丢包时性能降低）
1. 标准方法可能出现`伪重传`的问题

### 10.3.5 RTTM对丢包和失序的鲁棒性

1. 当没有丢包情况时，不论接收端是否延迟发送ACK，TSOPT可以很好地工作。该算法在以下几种情况下都能正确运行
    * 失序报文段：当接收端收到失序报文段时，通常是由于在此之前出现了丢包，应当立即返回ACK以启动快速重传算法。**该ACK的TSER部分包含了TSV值为接收端收到最近的有序报文段的时刻（即最新的使窗口前进的报文段，通常不会是失序报文段）**。这会使得发送端RTT样本增大，由此导致相应的RTO增大。这在一定程度上是有利的，即当包失序时，发送端有更多的时间去发现是出现了失序而非丢包，由此可避免不必要的重传
    * 成功重传：当收到接收端缓存中缺失的报文段时（如成功接收重传报文段），窗口通常会前移。此时对应ACK中的TSV值来自最新到达的报文段，这是比较有利的。若采用原来报文段中的TSV，可能对应的是前一个RTO，导致发送端RTT估算的偏离

![fig](/images/TCP-IP详解-读书笔记/14-3-2.jpg)

* 第一个ACK，序号为1025，时间戳为1（正常的数据确认）
* 第二个ACK，序号为1025，时间戳为1（失序的数据确认）
* 第三个ACK，序号为3073，时间戳为2，该时间戳是报文2而非报文3的时间戳
* 当分组失序（或丢失）时，RTT会被过高估算。较大的RTT估计值使得RTO也更大，由此发送端也不会急于重传。在失序的情况下这是很有利的，因为过分积极的重传可能导致伪重传

## 10.4 基于计时器的重传

1. 在设定计时器之前，需要记录被计时的报文段序列号，若计时收到了该报文段的ACK，那么计时器被取消。之后发送端发送一个新的数据包时，需设定一个新的计时器，并记录新的序列号。因此每个TCP连接的发送端不断地设定和取消一个重传计时器；如果没有数据丢失，则不会出现计时器超时
1. 若在连接设定的RTO内，TCP没有收到被计时的报文段的ACK，将会触发超时重传。当发送重传时，它通过降低当前数据发送率率对此进行快速响应，实现它有两种方法：
    * 第一种方法：基于拥塞控制机制减小发送窗口大小
    * 第二种方法：重传时，增大RTO的退避因子{% raw %}$RTO = \gamma RTO${% endraw %}。通常情况下，{% raw %}$\gamma${% endraw %}为1，随着多次重传{% raw %}$\gamma${% endraw %}呈加倍增长，同时{% raw %}$\gamma${% endraw %}不能超过最大的退避因子，通常是120s。一旦收到ACK，{% raw %}$\gamma${% endraw %}会重置为1

## 10.5 快速重传

1. 快速重传机制[RFC5681]，基于接收端的反馈信息来引发重传，而非重传计时器的超时。因此与超时重传相比，快速重传能更加及时有效地修复丢包情况。典型的TCP同时实现了两者
1. 当接收到失序报文段时，TCP需要立即生成确认信息（重复ACK），并且失序情况表明在后续数据到达前出现了丢段，即接收端缓存出现了空缺。**当采用SACK时，重复ACK通常也包含SACK信息，利用该信息可以获知多个空缺**
1. 重复ACK（不论是否包含SACK信息）到达发送端表明先前发送的某个分组已丢失。但是重复ACK也可能在另一种情况出现，即当网络中出现失序分组时---若接收端收到当前期盼序列号的后续分组时，当前期盼的包可能丢失，也可能仅为延迟到达。**通常我们无法得知是哪种情况，因此TCP等待一定数据的重复ACK（称为重复ACK阈值或dupthresh，通常为常量值3），来决定数据是否丢失并触发快速重传**
1. 快速重传算法概括如下：TCP发送端在观测到至少dupthresh个重复ACK后，即重传可能丢失的数据分组，而不必等到重传计时器超时。当然也可以同时发送新的数据。根据重复ACK推断的包通常与网络拥塞有关，因此伴随快速重传应触发拥塞控制机制。不采用SACK时，接收到有效ACK前之多只能重传一个报文段。采用SACK，ACK可包含额外信息，是的发送端在每个RTT时间内可以填补多个空缺

## 10.6 带选择确认的重传

1. TCP接收端可提供SACK功能，通过TCP头部的累积ACK号字段来描述其接收到的数据。之前提到过，ACK号与接收端缓存中的其他数据之间的间隔称为空缺。序列号高于空缺的数据称为失序数据，因为这些数据和之前接收的序列号不连续
1. TCP发送端的任务是通过重传丢失的数据来填补接收端缓存中的空缺，但同时也要尽可能保证不重传已正确接收到的数据。在很多环境下，合理采用SACK信息能更快地实现空缺填补，且能减少不必要的重传，原因在于其在一个RTT内能获知多个空缺。当采用SACK选项时，一个ACK可包含三四个告知失序数据的SACK信息。每个SACK信息包含32位的序列号，代表接收端存储的失序数据的起始至最后一个序列号
1. SACK选项指定n个块的长度为`8n + 2`字节，因此40字节可能包含最多4个块。通常SACK会与TSOPT一同使用，因此需要额外的10个字节，这意味着SACK在每个ACK中只能包含3个块
    * 每个SACK块包含8个字节，指明了一个序列号空间（左闭右开），`[leftSeqNum, rightSeqNum)`，这个序列号空间中的数据已被接收端接收
1. 包含一个或多个SACK块的ACK有时也简单称为SACK

### 10.6.1 SACK接收端行为

1. 接收端在TCP连接建立时期收到SACK许可选项即可生成SACK
1. 通常来说，每当缓存中存在失序数据时，接收端就可生成SACK
1. **在一个SACK中，第一个SACK块内包含的是`最近接收到的（most recently received）`报文段的序列号范围。其余的SACK块包含的内容也按照接收的先后依次排列。也就是说，SACK除了包含最近接收的序列号信息之外，还需重复之前的SACK块**
1. 一个SACK选项中包含多个SACK块，并且在多个SACK中重复这些块信息的目的在于，为了防止SACK丢失提供一些备份。若SACK不丢失，那么每个SACK包含一个SACK块即可实现SACK的全部功能。不幸的是，SACK和普通的ACK有时会丢失，且不会被重传（没有数据）

### 10.6.2 SACK发送端行为

1. 发送端也应提供SACK功能，并且合理地利用接收到的SACK块来进行丢失重传，该过程也称为`选择性重传（selective retransmission）`或`选择性重发（selective repeat）`
1. 发送端记录接收到的累积ACK信息（像大多数TCP发送端一样），还需记录接收到的SACK信息，并利用该信息来避免重传正确接收的数据。一种方法是当接收到相应序列号范围的ACK时，则在其重传缓存中标记该报文段的选择重传成功
1. 当SACK发送端执行重传时，通常是由于其收到了SACK或重复ACK，它可以选择发送新数据或重传旧数据。SACK信息提供接收端数据的序列号范围，因此发送端可据此推断需要重传的空缺数据。最简单的方法是使发送方首先填补接收端的空缺，然后再继续发送新数据，这也是最常用的方法
1. 在[RFC2018]中，SACK选项和SACK块的当前规范是`建议性的（advisory）`。这意味着，接收端可能提供一个SACK告诉发送端已成功接收一定序列号范围的数据，而之后作出变更（食言）。**由于这个原因，SACK发送端不能在收到一个SACK后立即清空其重传缓存中的数据；只有当接收端的普通TCP ACK号大于其最大序列号值时才可清除**。这一规则同样影响重传计时器的行为，当TCP发送端启用基于计时器的重传时，应忽略SACK显示的任何关于接收端失序的信息。如果接收端仍存在失序数据，那么重传报文的ACK就包含附加的SACK块，以便发送者使用

## 10.7 伪超时与重传

1. 在很多情况下，即使数据没有出现丢失也可能引发重传。这种不必要的重传称为`伪重传（spurious retransmission）`，其主要原因是`伪超时（spurious timeout）`，其他因素如包失序、包重复，或ACK丢失也可能导致该现象。在实际RTT显著增长，超过当前RTO时，可能出现伪超时
1. 为处理伪超时问题提出了许多方法，这些方法通常包含`检测（detection）算法`与`响应（response）算法`
    * 检测算法用于判断某个超时或基于计时器的重传是否真实，一旦认定出现伪超时则执行响应算法，用于撤销或减轻该超时带来的影响

### 10.7.1 重复SACK（DSACK）扩展

1. 在非SACK的TCP中，ACK只能向发送端告知最大的有序报文段。采用SACK则可告知其他的（失序）报文段。基本的SACK机制对接收端收到重复数据段时怎样运作没有规定
1. **在SACK接收端采用DSACK（或称作D-SACK），及重复SACK，并结合通常的SACK发送端，可在第一个SACK块中告知接收端收到的重复报文段序列号**。DSACK的主要目的是判断何时的重传是不必要的，并了解网络中的其他事项。因此发送端至少可以推断是否发生了包失序、ACK丢失、包重复或伪重传
1. DSACK相比于传统SACK并不需要额外的协商过程。为使其正常工作，接收端返回的SACK的内容会有所改变，对应的发送端的响应也会随之变化
1. **DSACK相比于传统SACK，其接收端的变化在于：第一个SACK块允许包含序列号小于（或等于）累积ACK号字段的SACK**
    * 如果第一个SACK块允许包含序列号小于累积ACK，则表明第一个SACK块的数据空间被至少接收了两次
    * 如果第一个SACK块允许包含序列号大于累积ACK，则需要比较第一个SACK块的序列号空间与第二个SACK块的序列号空间是否有重复（如果有第二个SACK块的话）
1. DSACK信息不会再多个SACK中重复。因此DSACK较通常的SACK鲁棒性低

### 10.7.2 Eifel检测算法

1. 实验性的`Eifel检测算法`[RFC3522]利用了TCP的TSOPT来检测伪重传。在发生超时重传后，Eifel算法等待接收下一个ACK，若为针对第一次传输（即原始传输）的确认，则判定该重传为伪重传
1. 利用Eifel检测算法能比仅采用DSACK更早检测到伪重传行为，因为它判断伪重传的ACK是在启动丢失恢复之前生成的。相反，DSACK只有在重复报文段到达接收端后才能发送，并且在DSACK返回至发送端才能有所响应
1. Eifel检测算法的机制很简单，他需要使用TCP的TSOPT，当发送一个重传（不论是基于计时器的重传还是快速重传）后，保存其TSV值。当接收到相应分组的ACK后，检查该ACK的TSER部分：若TSER值小于之前存储的TSV值，则可判断该ACK对应的是原始传输分组，即该重传是伪重传
1. Eifel检测算法可与DSACK结合使用，这样可以解决整个窗口的ACK信息均丢失，但原始传输和重传分组都成功到达接收端的情况。在这种特殊情况下，重传分组的到达会生成一个DSACK。Eifel检测算法会理所当然地认定出现了伪重传。然而，在出现了如此多的的ACK丢失的情况下，使得TCP相信该重传不是伪重传是有用的（例如，使其减慢发送速率--采用拥塞控制的后果）。因此，DSACK的到达会使得Eifel检测算法认定相应的重传不是伪重传

### 10.7.3 前移RTO恢复（F-RTO）

1. `前移RTO恢复（Forward-RTO Recovery，F-RTO）`是检测伪重传的标准算法。它不需要任何TCP选项，因此只要在发送端实现该方法后，即使针对不支持TSOPT的接收端也能有效工作。该算法只检测由重传计时器引发的伪重传；对之前提到的其他原因引起的伪重传则无法判断
1. 在一次基于计时器的重传之后，F-RTO会对TCP的常用行为作出一定修改。由于这类重传针对的是没有收到ACK信息的最小序列号，通常情况下，TCP会继续按序发送相邻的分组，这就是前面描述的“回退N”行为
1. **F-RTO会修改TCP的行为，基本思路是：在超时之后发送新数据（非重传数据），并观察之后的两个ACK，若两个ACK都不是重复ACK（是否与超时之前收到的ACK序列号相同），那么就认为是伪重传**
    * 可能情况1：数据包并未丢失而只是delay了，接收端在收到该delay数据包后，回复相应的ACK，使得窗口前移（该ACK肯定不是重复ACK）
    * 可能情况2：数据包正常接收，只是ACK丢失了，那么接收端在收到新的数据后（计时器超时后发送的新数据），回复相应的ACK，使得窗口前移（该ACK肯定不是冗余重复ACK）

### 10.7.4 Eifel响应算法

1. 一旦判断出现伪重传，则会引发一套标准操作，即`Eifel响应算法`[RFC4015]
1. 响应算法逻辑上与Eifel检测算法分离，所以它可以与我们前面讨论的任何一种检测方法结合使用。原则上超时重传和快速重传都可使用Eifel响应算法，单目前只针对超时重传做了相关规定
1. 尽管Eifel响应算法可结合其他检测算法使用，但根据是否能尽早（如Eifel检测算法或F-RTO）或较迟（如DSACK）检测出伪超时的不同而有所区别
    * 前者称为`伪超时`，通过检查ACK或原始传输来实现
    * 后者称为`迟伪超时`，基于由（伪）超时而引发的重传所返回的ACK来判定
1. 响应算法只针对第一种重传事件。若在恢复阶段完成之前再次发生超时，则不会执行响应算法。在重传计时器超时后，它会查看srtt和rttvar的值，并按如下方式记录新的变量`srtt_prev`和`rttvar_prev`
    * 在任何一次计时器超时后，都会指定这两个变量，但只有在判定出现伪超时时才会使用它们，用于设定新的RTO
    * {% raw %}$G${% endraw %}代表时钟粒度。{% raw %}$srtt\_prev${% endraw %}设置为{% raw %}$srtt${% endraw %}加上两倍的时钟粒度是由于：{% raw %}$srtt${% endraw %}的值过小，可能出现伪超时。如果{% raw %}$srtt${% endraw %}稍大，就可能不会发生超时
{% raw %}$$
srtt\_prev = srtt + 2(G) \\
rttvar\_prev = rttvar
$${% endraw %}

1. 完成{% raw %}$srtt\_prev${% endraw %}和{% raw %}$rttvar\_prev${% endraw %}的存储后，就要触发某种检测算法。运行检测算法后可得到一个特殊的值，称为`伪恢复（SpuriousRecovery）`。如果检测到一次`伪超时`，则将`伪恢复`设置为`SPUR_TO`。如果检测到`迟伪超时`，则将其设置为`LATE_SPUR_TO`。否则，该次超时为正常超时，TCP继续执行正常的响应行为
1. 若`伪恢复`为`SPUR_TO`，TCP可在恢复阶段完成之前进行操作，通过将下一个要发送的报文段（称为`SND.NXT`）的序列号修改为最新的未发送过的报文段（称为`SND.MAX`），这样就可在首次重传后避免不必要的“回退N”行为。若`伪恢复`为`LATE_SPUR_TO`，此时已收到首次重传的ACK，则`SND.NXT`不改变。以上两种情况中，都要重新设置拥塞控制状态，并且一旦接收到重传计时器超时后发送的报文段的ACK，就要按如下方式更新{% raw %}$srtt${% endraw %}、{% raw %}$rttvar${% endraw %}和RTO
    * {% raw %}$m${% endraw %}是一个RTT样本值，它是基于超时后收个发送数据收到的ACK而计算得到的
    * 进行这些变量更新的目的在于：实际的RTT值可能发生了很大变化，RTT当前估计值已不适用于设置RTO。若路径上的实际RTT突然增大，当前的{% raw %}$srtt${% endraw %}和{% raw %}$rttvar${% endraw %}就显得过小，应重新设置；而另一方面，RTT的增大可能只是暂时的，这时重新设置{% raw %}$srtt${% endraw %}和{% raw %}$rttvar${% endraw %}就不那么明智了，因为它们原先的值可能更为精确
{% raw %}$$
srtt ← max(srtt\_prev, m) \\
rttvar ← max(rttvar\_prev, \frac{m}{2}) \\
RTO = srtt + max(G, 4(rttvar))
$${% endraw %}

1. 在新RTT样本值较大的情况下，上述等式尽力获得上述两种情况的平衡。这样做可以有效地抛弃之前的RTT历史值（和RTT的历史变化情况）。只有在响应算法中{% raw %}$srtt${% endraw %}和{% raw %}$rttvar${% endraw %}的值才会增大。若RTT不会增大，则维持估计值不变，这本质上是忽略超时情况发生。两种情况中，RTO还是按正常方式进行鞥新，并针对此次超时设置新的重传计时器值

## 10.8 包失序与包重复

### 10.8.1 失序

1. 在IP网络中出现包失序的原因在于IP层不能保证包传输是有序进行的。对IP层来说，这样做是有利的，因为IP可以选择另一条传输链路（例如传输速度更快的路径），而不用担心新发送的分组会先于旧数据到达，这就导致数据的接收顺序与发送顺序不一致。此外，在硬件方面一些高性能路由器会采用多个并行数据链路，不同的处理延时也会导致包的离开顺序与到达顺序不匹配
1. 失序问题也可能存在于TCP连接的正向或反向链路中。数据段的失序与ACK包的失序对TCP的影响有一定差别
    * 如果失序发生在反向（ACK）链路，就会使得TCP发送端窗口快速前移，接着有可能收到一些显然重复而应被丢弃的ACK。由于TCP的拥塞控制行为，这种情况会导致发送端出现不必要的流量突发（瞬时高速发送）行为，影响可用网络带宽
    * 如果失序发生在正向链路，TCP可能无法正确识别失序和丢包。数据的丢失和失序都会导致接收端收到无序的包，造成数据之间的空缺。当失序程度不是很大（如两个相邻的包交换顺序），这种情况可以迅速得到处理。反之，当出现严重失序时，TCP会误认为数据包已经丢失，这种情况会造成伪重传，主要来自快速重传算法
1. 区分丢包与失序不是一个很重要的问题。要解决它要判断发送端是否已经等待了足够长的时间来填补空缺。幸运的是，互联网中严重的失序并不常见，因此将`dupthresh`（快速重传的ACK重复次数）设置为相对较小的值（默认是3）就能处理绝大部分情况。其他严重的情况可以通过调整`dupthresh`来应对

### 10.8.2 重复

1. 尽管出现的比较少，IP协议也可能出现将单个包传输多次的情况。例如，当链路层网络协议执行一次重传，并生成同一个包的两个副本。当重复生成时，TCP可能出现混淆
1. 包的多次重复会使得接收端生成一系列重复ACK，有可能触发伪快速重传，对于非SACK的发送端就会产生误解。利用SACK（特别是DSACK）可以简单地忽略这个问题

## 10.9 目的度量

1. TCP能不断“学习”发送端与接收端之间的链路特征。学习的结果显示为发送端记录一些状态变量，如{% raw %}$srtt${% endraw %}和{% raw %}$rttvar${% endraw %}。一些TCP实现也记录一段时间内已出现的失序包的估计值。一般来说，一旦该连接关闭，这些学习结果也会丢失。即与一个接收端建立一个新的TCP连接后，他必须从头开始获得状态变量值
1. 较新的TCP实现维护了这些度量值，即使在连接断开后，也能保存之前存在的路由或转发表项，或其他的一些系统数据结构。当创立一个新的连接时，首先查看数据结构中是否存在于该目的端的先前通信信息。如果存在，则选择较近的信息，据此为{% raw %}$srtt${% endraw %}和{% raw %}$rttvar${% endraw %}以及其他变量设初值。在Linux中可以通过命令`ip route show cache 1.1.1.1`查看这些变量值

## 10.10 重新组包

1. 当TCP超时重传，他并不需要完全重传相同的报文段。TCP允许执行`重新组包（repacketization）`，发送一个更大的报文段来提高性能（通常该更大的报文段不能超过接收端通告的MSS，也不能大于路径MTU）
1. TCP能重传一个与元报文段不同大小的报文段，这从一定意义上解决了重传二义性的问题。STODER[TZZ05]就是基于该思想，采用重新组包的方法来检测伪超时

## 10.11 与TCP重传相关的攻击

1. 有一类DoS攻击称为低速率DoS攻击[KK03]。在这类攻击中，攻击者向网关或主机发送大量数据，使得受害系统持续处于重传超时的状态。由于攻击者可预知受害者TCP何时启动重传，并在每次重传时生成并发送大量数据。因此，受害TCP总能感知到拥塞的存在，根据Karn算法不断减小发送速率并退避发送，导致无法正常使用网络带宽。针对此类攻击的预防方法就是随机选择RTO，使得攻击者无法预知确切的重传时间
1. 与DoS相关但不同的一种攻击为减慢受害者TCP的发送，使得RTT估计值过大。这样受害者在丢包后不会立即重传。相反的攻击也是有可能的：攻击者在数据发送完成但还未到达接收端时伪造ACK。这样攻击者就能使受害者TCP认为连接的RTT远小于实际值，导致过分发送，造成大量的无效传输

# 11 TCP数据流与窗口管理

## 11.1 引言

1. 本章探讨TCP的动态数据传输，首先关注交互式连接，接着介绍流量控制以及窗口管理规范
1. “交互式”TCP连接是指，该连接需要在客户端和服务器之间传输用户输入信息，如按键操作、短消息、操作杆或鼠标的动作等。如采用较小的报文段来承载这些用户信息，那么传输协议需要耗费很高的代价，因为每个交换分组中包含的有效负载字节较少。反之，报文段较大则会引入更大的延时，对延迟敏感类应用（如在线游戏、协同工具等）造成负面影响。因此需要权衡相关因素，找到折中方法

## 11.2 交互式通信

1. 按照TCP数据段大小的不同，大致可以分为两类，`大批量数据`和`交互式数据`。批量数据段通常较大（1500字节或更大），而交互式数据段则会比较小（几十字节的用户数据）
1. 对于ssh这一应用，许多TCP/IP的初学者会惊奇地发现，每个交互按键都通常会生成一个单独的数据包。也就是说，每个按键是独立传输的。另外，ssh会在远程系统（服务器端）调用一个shell（命令解释器），对客户端的输入字符作出回显。因此，每个输入的字符会生成4个TCP数据段
    1. 客户端的交互击键输入
    1. 服务器端对击键的确认
    1. 服务器端生成的回显
    1. 客户端对该回显的确认
    * 通常，第2段和第3段可以合并

# 12 参考

* [传输层学习之五（TCP的SACK，F-RTO）](https://blog.csdn.net/shenwansangz/article/details/38400919)
