---
title: Linux-Network
date: 2018-07-20 15:00:52
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 系统网络参数

网络配置参数与内核配置文件的对应关系，例如`net.ipv4.ip_forward`对应的内核配置文件为`/proc/sys/net/ipv4/ip_forward`

| 配置项 | 说明 |
|:--|:--|
| `net.ipv4.tcp_syncookies` | `1`表示开启`SYN Cookies`。当出现SYN等待队列溢出时，启用`Cookies`来处理，可防范少量SYN攻击，默认为0，表示关闭 |
| `net.ipv4.tcp_tw_reuse` | `1`表示开启重用。允许将`TIME-WAIT`状态的`sockets`重新用于新的TCP连接，默认为0，表示关闭 |
| `net.ipv4.tcp_tw_recycle` | `1`表示开启TCP连接中`TIME-WAIT`状态的`sockets`的快速回收，默认为0，表示关闭 |
| `net.ipv4.conf.<net_device>.proxy_arp` | `1`表示当ARP请求目标跨网段时，网卡设备收到此ARP请求会用自己的MAC地址返回给请求者 |
| `net.ipv4.conf.all.rp_filter` | `1`表示过滤反向路由不通的包，比如进来的数据报是`srcIp->dstIp`，会校验`dstIp->srcIp`的路由是否会经过同一个网卡。换言之，`1`不允许正反链路不一致，`0`允许正反链路不一致 |
| `net.ipv4.ip_local_port_range` | 可用的临时端口号的范围 |
| `fs.file-max` | 整个操作系统最多可打开的文件描述符的数量，一个tcp连接会占用一个文件描述符，因此系统能够打开多少个tcp连接也受到该参数的影响 |
| `fs.nr_open` | 单个进程最多可打开的文件描述符的数量，一个tcp连接会占用一个文件描述符，因此进程能够打开多少个tcp连接也受到该参数的影响 |

# 2 Virtual Networking

## 2.1 bridge

![bridge](/images/Linux-Network/bridge.png)

Linux虚拟网桥类似于一个交换机，它在与其连接的接口之间转发数据包。通常用于在路由器、网关、VM以及网络命名空间之间转发数据包

编写一个脚本，内容如下，这里我取名为`bridge.sh`

```sh
cat > ~/bridge.sh << 'EOF'
#!/bin/bash

export namespace=liuye

export ifname_outside_ns=veth1
export ifname_inside_ns=veth2
export ifname_external=""

export ip_bridge=""
export ip_inside_ns=""

export ip_net=""
export ip_netmask=""
export ip_broadcast=""

export bridge_name=demobridge

function setup(){
	set -x

	ip link add ${bridge_name} type bridge
	ip link set ${bridge_name} up

	ip addr add ${ip_bridge}/${ip_netmask} broadcast ${ip_broadcast} dev ${bridge_name}
    
	ip netns add ${namespace}

	ip link add ${ifname_outside_ns} type veth peer name ${ifname_inside_ns}

	ip link set ${ifname_outside_ns} up

	ip link set ${ifname_outside_ns} master ${bridge_name}
	
	ip link set ${ifname_inside_ns} netns ${namespace}

	ip netns exec ${namespace} ip link set ${ifname_inside_ns} up
	ip netns exec ${namespace} ip addr add ${ip_inside_ns}/${ip_netmask} broadcast ${ip_broadcast} dev ${ifname_inside_ns}

	ip netns exec ${namespace} ip link set lo up

	ip netns exec ${namespace} ip route add default via ${ip_bridge} dev ${ifname_inside_ns}

	iptables -t nat -A POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	iptables -t filter -A FORWARD -i ${ifname_external} -o ${bridge_name} -j ACCEPT
	iptables -t filter -A FORWARD -i ${bridge_name} -o ${ifname_external} -j ACCEPT
	
	echo 1 > /proc/sys/net/ipv4/ip_forward

	mkdir -p /etc/netns/${namespace}
	echo "nameserver 8.8.8.8" > /etc/netns/${namespace}/resolv.conf

	set +x
}

function cleanup(){
	set -x

	iptables -t filter -D FORWARD -i ${ifname_external} -o ${bridge_name} -j ACCEPT
	iptables -t filter -D FORWARD -i ${bridge_name} -o ${ifname_external} -j ACCEPT

	iptables -t nat -D POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	ip link delete ${ifname_outside_ns}
	
	ip netns delete ${namespace}
	rm -rf /etc/netns/${namespace}

	ip link set ${bridge_name} down

	brctl delbr ${bridge_name}

	set +x
}

export -f setup
export -f cleanup
EOF
```

下面进行测试

```sh
# 配置
source bridge.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ip_bridge=192.168.45.2 # 网桥的ip
export ip_inside_ns=192.168.45.3 # 位于网络命名空间内的veth接口的ip
export ip_net=192.168.45.0 # 网桥以及veth接口的网络
export ip_netmask=255.255.255.0 # 子网掩码
export ip_broadcast=192.168.45.255 # 广播ip
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add demobridge type bridge
+ ip link set demobridge up
+ ip addr add 192.168.45.2/255.255.255.0 broadcast 192.168.45.255 dev demobridge
+ ip netns add liuye
+ ip link add veth1 type veth peer name veth2
+ ip link set veth1 up
+ ip link set veth1 master demobridge
+ ip link set veth2 netns liuye
+ ip netns exec liuye ip link set veth2 up
+ ip netns exec liuye ip addr add 192.168.45.3/255.255.255.0 broadcast 192.168.45.255 dev veth2
+ ip netns exec liuye ip link set lo up
+ ip netns exec liuye ip route add default via 192.168.45.2 dev veth2
+ iptables -t nat -A POSTROUTING -s 192.168.45.0/255.255.255.0 -o enp0s3 -j MASQUERADE
+ iptables -t filter -A FORWARD -i enp0s3 -o demobridge -j ACCEPT
+ iptables -t filter -A FORWARD -i demobridge -o enp0s3 -j ACCEPT
+ echo 1
+ mkdir -p /etc/netns/liuye
+ echo 'nameserver 8.8.8.8'
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 测试网络连通性（如果不通的话，可能是被防火墙拦截了）
ip netns exec ${namespace} ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.173) 56(84) bytes of data.
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=1 ttl=32 time=74.8 ms
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=2 ttl=32 time=73.1 ms
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=3 ttl=32 time=74.3 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 73.192/74.111/74.808/0.747 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ iptables -t filter -D FORWARD -i enp0s3 -o demobridge -j ACCEPT
+ iptables -t filter -D FORWARD -i demobridge -o enp0s3 -j ACCEPT
+ iptables -t nat -D POSTROUTING -s 192.168.45.0/255.255.255.0 -o enp0s3 -j MASQUERADE
+ ip link delete veth1
+ ip netns delete liuye
+ rm -i -rf /etc/netns/liuye
+ ip link set demobridge down
+ brctl delbr demobridge
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.2 bonded interface

![bond](/images/Linux-Network/bond.png)

`bond`可以将多张网卡组织成一张逻辑网卡，存在多种组织方式（`mode`），包括

1. `balance-rr`：轮询（`round-robin`）
1. `active-backup`：热备
1. `balance-xor`
1. `broadcast`：广播，每张slave都会收到消息
1. `802.3ad`
1. `balance-tlb`
1. `balance-alb`

下面开始验证，我的测试环境如下：

* 使用kvm虚拟机，安装的镜像为`CentOS-7-x86_64-Minimal-1908.iso`
* 宿主机上有1个网桥：`br0`
	* `br0`：ip为`10.0.2.1/24`，并添加了SNAT配置`iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eno1 -j MASQUERADE`（`eno1`为宿主机的外网网卡）
* kvm虚拟机包含2个网卡，`eth0`和`ens9`，分别接到宿主机上的`br0`

编写一个脚本，内容如下，这里我取名为`bond.sh`

```sh
cat > ~/bond.sh << 'EOF'
#!/bin/bash

export ifname_physics_1=""
export ifname_physics_2=""
export bond_name=""
export bond_mode=""
export ip_bond=""
export ip_gateway=""
export ip_net=""
export ip_netmask=""
export ip_broadcast=""

function setup(){
	set -x

	ip link add ${bond_name} type bond miimon 100 updelay 100 downdelay 100 mode ${bond_mode}

	ip link set ${ifname_physics_1} master ${bond_name}
	ip link set ${ifname_physics_2} master ${bond_name}

	ip link set ${bond_name} up
	ip link set ${ifname_physics_1} up
	ip link set ${ifname_physics_2} up

	ip addr add ${ip_bond}/${ip_netmask} broadcast ${ip_broadcast} dev ${bond_name}

	ip route add default via ${ip_gateway} dev ${bond_name}

	echo "nameserver 8.8.8.8" > /etc/resolv.conf

	set +x
}

function cleanup(){
	set -x

	ip link set ${bond_name} down
	ip link set ${ifname_physics_1} down
	ip link set ${ifname_physics_2} down

	ip link del ${bond_name}

	set +x
}

export -f setup
export -f cleanup
EOF
```

开始验证

```sh
# 配置
source bond.sh
export ifname_physics_1="eth0" # 待绑定的子网卡名称1
export ifname_physics_2="ens9" # 待绑定的子网卡名称2
export bond_name="bond_liuye" # bond名称
export bond_mode="active-backup" # bond模式，可以通过 ip link help bond 查询所有的mode
export ip_bond="10.0.2.66"
export ip_gateway="10.0.2.1"
export ip_net="10.0.2.0"
export ip_netmask="255.255.255.0"
export ip_broadcast="10.0.2.255"
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add bond_liuye type bond miimon 100 updelay 100 downdelay 100 mode active-backup
+ ip link set eth0 master bond_liuye
+ ip link set ens9 master bond_liuye
+ ip link set bond_liuye up
+ ip link set eth0 up
+ ip link set ens9 up
+ ip addr add 10.0.2.66/255.255.255.0 broadcast 10.0.2.255 dev bond_liuye
+ ip route add default via 10.0.2.1 dev bond_liuye
+ echo 'nameserver 8.8.8.8'
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 测试连通性
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.168) 56(84) bytes of data.
64 bytes from 47.88.251.168 (47.88.251.168): icmp_seq=1 ttl=31 time=70.6 ms
64 bytes from 47.88.251.168 (47.88.251.168): icmp_seq=2 ttl=31 time=70.3 ms
64 bytes from 47.88.251.168 (47.88.251.168): icmp_seq=3 ttl=31 time=70.5 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 70.335/70.511/70.679/0.258 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 将网卡1关掉，查看连通性
ip link set ${ifname_physics_1} down
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.175) 56(84) bytes of data.
64 bytes from 47.88.251.175 (47.88.251.175): icmp_seq=1 ttl=31 time=81.5 ms
64 bytes from 47.88.251.175 (47.88.251.175): icmp_seq=2 ttl=31 time=81.4 ms
64 bytes from 47.88.251.175 (47.88.251.175): icmp_seq=3 ttl=31 time=81.4 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 81.432/81.487/81.555/0.238 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 查看此时生效的网卡
ip -d link show dev ${bond_name}
#-------------------------↓↓↓↓↓↓-------------------------
12: bond_liuye: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:1e:f1:21 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bond mode active-backup active_slave ens9 miimon 100 updelay 100 downdelay 100 use_carrier 1 arp_interval 0 arp_validate none arp_all_targets any primary_reselect always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1 num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1 packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 1 addrgenmode eui64 numtxqueues 16 numrxqueues 16 gso_max_size 65536 gso_max_segs 65535
#-------------------------↑↑↑↑↑↑-------------------------
# 可以看到，此时生效的网卡是ens9（bond mode active-backup active_slave ens9）

# 打开网卡1，关掉网卡2，再看连通性
ip link set ${ifname_physics_1} up
ip link set ${ifname_physics_2} down
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.198.24) 56(84) bytes of data.
64 bytes from 47.88.198.24 (47.88.198.24): icmp_seq=1 ttl=31 time=80.6 ms
64 bytes from 47.88.198.24 (47.88.198.24): icmp_seq=2 ttl=31 time=80.9 ms
64 bytes from 47.88.198.24 (47.88.198.24): icmp_seq=3 ttl=31 time=80.5 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 80.579/80.725/80.995/0.191 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 查看此时生效的网卡
ip -d link show dev ${bond_name}
#-------------------------↓↓↓↓↓↓-------------------------
12: bond_liuye: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 52:54:00:1e:f1:21 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bond mode active-backup active_slave eth0 miimon 100 updelay 100 downdelay 100 use_carrier 1 arp_interval 0 arp_validate none arp_all_targets any primary_reselect always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1 num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1 packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 1 addrgenmode eui64 numtxqueues 16 numrxqueues 16 gso_max_size 65536 gso_max_segs 65535
#-------------------------↑↑↑↑↑↑-------------------------
# 可以看到，此时生效的网卡是eth0（bond mode active-backup active_slave eth0）

# 清理
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link set bond_liuye down
+ ip link set eth0 down
+ ip link set ens9 down
+ ip link del bond_liuye
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.3 team device

![team](/images/Linux-Network/team.png)

与`bond`类似，`team`也提供了将两个网络接口组合成一个逻辑网络接口的方法，它工作在二层。`bond`与`team`之间的差异可以参考[Bonding vs. Team features](https://github.com/jpirko/libteam/wiki/Bonding-vs.-Team-features)

下面开始验证，我的测试环境如下：

* 使用kvm虚拟机，安装的镜像为`CentOS-7-x86_64-Minimal-1908.iso`
* 宿主机上有1个网桥：`br0`
	* `br0`：ip为`10.0.2.1/24`，并添加了SNAT配置`iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eno1 -j MASQUERADE`（`eno1`为宿主机的外网网卡）
* kvm虚拟机包含2个网卡，`eth0`和`ens9`，分别接到宿主机上的`br0`

编写一个脚本，内容如下，这里我取名为`team.sh`

```sh
cat > ~/team.sh << 'EOF'
#!/bin/bash

export ifname_physics_1=""
export ifname_physics_2=""
export team_name=""
export ip_team=""
export ip_gateway=""
export ip_net=""
export ip_netmask=""
export ip_broadcast=""

function setup(){
	set -x

	teamd -o -n -U -d -t ${team_name} -c '{"runner": {"name": "activebackup"},"link_watch": {"name": "ethtool"}}'

	ip link set ${ifname_physics_1} master ${team_name}
	ip link set ${ifname_physics_2} master ${team_name}

	ip link set ${team_name} up
	ip link set ${ifname_physics_1} up
	ip link set ${ifname_physics_2} up

	ip addr add ${ip_team}/${ip_netmask} broadcast ${ip_broadcast} dev ${team_name}

	ip route add default via ${ip_gateway} dev ${team_name}

	echo "nameserver 8.8.8.8" > /etc/resolv.conf

	set +x
}

function cleanup(){
	set -x

	ip link set ${team_name} down
	ip link set ${ifname_physics_1} down
	ip link set ${ifname_physics_2} down

	ip link del ${team_name}

	set +x
}

export -f setup
export -f cleanup
EOF
```

开始验证

```sh
# 配置
source team.sh
export ifname_physics_1="eth0" # 待绑定的子网卡名称1
export ifname_physics_2="ens9" # 待绑定的子网卡名称2
export team_name="team_liuye" # team名称
export ip_team="10.0.2.66"
export ip_gateway="10.0.2.1"
export ip_net="10.0.2.0"
export ip_netmask="255.255.255.0"
export ip_broadcast="10.0.2.255"
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ teamd -o -n -U -d -t team_liuye -c '{"runner": {"name": "activebackup"},"link_watch": {"name": "ethtool"}}'
This program is not intended to be run as root.
+ ip link set eth0 master team_liuye
+ ip link set ens9 master team_liuye
+ ip link set team_liuye up
+ ip link set eth0 up
+ ip link set ens9 up
+ ip addr add 10.0.2.66/255.255.255.0 broadcast 10.0.2.255 dev team_liuye
+ ip route add default via 10.0.2.1 dev team_liuye
+ echo 'nameserver 8.8.8.8'
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 测试连通性
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.174) 56(84) bytes of data.
64 bytes from 47.88.251.174 (47.88.251.174): icmp_seq=1 ttl=30 time=69.2 ms
64 bytes from 47.88.251.174 (47.88.251.174): icmp_seq=2 ttl=30 time=68.8 ms
64 bytes from 47.88.251.174 (47.88.251.174): icmp_seq=3 ttl=30 time=68.6 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 68.633/68.912/69.219/0.386 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 将网卡1关掉，查看连通性
ip link set ${ifname_physics_1} down
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.176) 56(84) bytes of data.
64 bytes from 47.88.251.176 (47.88.251.176): icmp_seq=1 ttl=31 time=70.3 ms
64 bytes from 47.88.251.176 (47.88.251.176): icmp_seq=2 ttl=31 time=70.2 ms
64 bytes from 47.88.251.176 (47.88.251.176): icmp_seq=3 ttl=31 time=70.2 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 70.205/70.266/70.313/0.045 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 打开网卡1，关掉网卡2，再看连通性
ip link set ${ifname_physics_1} up
ip link set ${ifname_physics_2} down
ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.171) 56(84) bytes of data.
64 bytes from 47.88.251.171 (47.88.251.171): icmp_seq=1 ttl=30 time=82.7 ms
64 bytes from 47.88.251.171 (47.88.251.171): icmp_seq=2 ttl=30 time=218 ms
64 bytes from 47.88.251.171 (47.88.251.171): icmp_seq=3 ttl=30 time=340 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 82.756/213.799/340.219/105.160 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link set team_liuye down
+ ip link set eth0 down
+ ip link set ens9 down
+ ip link del team_liuye
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.4 vlan（virtual lan）

## 2.5 vxlan（virtual extensible lan）

## 2.6 macvlan

在`macvlan`出现之前，我们只能为一块以太网卡添加多个`IP`地址，却不能添加多个`MAC`地址，因为`MAC`地址正是通过其全球唯一性来标识一块以太网卡的，即便你使用了创建`ethx:y`这样的方式，你会发现所有这些“网卡”的`MAC`地址和`ethx`都是一样的，本质上，它们还是一块网卡，这将限制你做很多二层的操作。有了`macvlan`技术，你可以这么做了

`macvlan`允许你在主机的一个网络接口上配置多个虚拟的网络接口，这些网络interface有自己独立的`MAC`地址，也可以配置上`IP`地址进行通信。`macvlan`下的虚拟机或者容器网络和主机在同一个网段中，共享同一个广播域。`macvlan`和`Bridge`比较相似，但因为它省去了`Bridge`的存在，所以配置和调试起来比较简单，而且效率也相对高。除此之外`macvlan`自身也完美支持`VLAN`

同一`VLAN`间数据传输是通过二层互访，即`MAC`地址实现的，不需要使用路由。不同`VLAN`的用户单播默认不能直接通信，如果想要通信，还需要三层设备做路由，`macvlan`也是如此。用`macvlan`技术虚拟出来的虚拟网卡，在逻辑上和物理网卡是对等的。物理网卡也就相当于一个交换机，记录着对应的虚拟网卡和`MAC`地址，当物理网卡收到数据包后，会根据目的 MAC 地址判断这个包属于哪一个虚拟网卡。**这也就意味着，只要是从`macvlan`子接口发来的数据包（或者是发往`macvlan`子接口的数据包），物理网卡只接收数据包，不处理数据包，所以这就引出了一个问题：本机 macvlan 网卡上面的 IP 无法和物理网卡上面的 IP 通信！**

**macvlan的技术实现：**

![macvlan_principle](/images/Linux-Network/macvlan_principle.jpg)

**`macvlan`有以下特点：**

* 可让使用者在同一张实体网卡上设定多个`MAC`地址
	* 带有上述设定的`MAC`地址的网卡称为子接口（`sub interface`）
	* 实体网卡则称为父接口（`parent interface`）
* `parent interface`可以是一个物理接口（eth0），可以是一个`802.1q`的子接口（`eth0.10`），也可以是`bonding`接口
* 可在`parent/sub interface`上设定的不只是`MAC`地址，`IP`地址同样也可以被设定
* `sub interface`无法直接与`parent interface`通讯 (带有`sub interface`的`VM`或容器无法与`host`直接通讯)
	* 若`VM`或容器需要与`host`通讯，那就必须额外建立一个`sub interface`给`host`用
* `sub interface`通常以`mac0@eth0`的形式来命名以方便区別

**准备一个脚本，用于验证各个模式**

```sh
cat > ~/macvlan.sh << 'EOF'
#!/bin/bash

export macvlan_mode=""

export namespace1=liuye1
export namespace2=liuye2

export ifname_external=""
export ifname_macvlan1=macvlan1
export ifname_macvlan2=macvlan2

export ip_host=""
export default_gateway=""
export ip_macvlan1=""
export ip_macvlan2=""
export ip_netmask=""

function setup() {
	set -x

	ip link add ${ifname_macvlan1} link ${ifname_external} type macvlan mode ${macvlan_mode}
	ip link add ${ifname_macvlan2} link ${ifname_external} type macvlan mode ${macvlan_mode}

	ip netns add ${namespace1}
	ip netns add ${namespace2}

	ip link set ${ifname_macvlan1} netns ${namespace1}
	ip link set ${ifname_macvlan2} netns ${namespace2}

	ip netns exec ${namespace1} ip link set ${ifname_macvlan1} up
	ip netns exec ${namespace1} ip addr add ${ip_macvlan1}/${ip_netmask} dev ${ifname_macvlan1}
	if [ -z "${default_gateway}" ]; then
		ip netns exec ${namespace1} ip route add default dev ${ifname_macvlan1}
	else
		ip netns exec ${namespace1} ip route add default via ${default_gateway} dev ${ifname_macvlan1}
	fi

	ip netns exec ${namespace2} ip link set ${ifname_macvlan2} up
	ip netns exec ${namespace2} ip addr add ${ip_macvlan2}/${ip_netmask} dev ${ifname_macvlan2}
	if [ -z "${default_gateway}" ]; then
		ip netns exec ${namespace2} ip route add default dev ${ifname_macvlan2}
	else
		ip netns exec ${namespace2} ip route add default via ${default_gateway} dev ${ifname_macvlan2}
	fi

	set +x
}

function cleanup() {
	set -x
	ip netns exec ${namespace1} ip link delete ${ifname_macvlan1}
	ip netns exec ${namespace2} ip link delete ${ifname_macvlan2}

	ip netns delete ${namespace1}
	ip netns delete ${namespace2}
	set +x
}

export -f setup
export -f cleanup
EOF
```

### 2.6.1 private mode

![macvlan_private](/images/Linux-Network/macvlan_private.jpg)

此种模式相当于`vepa`模式的增强模式，其完全阻止共享同一父接口的`macvlan`虚拟网卡之间的通讯，即使配置了`Hairpin`让从父接口发出的流量返回到宿主机，相应的通讯流量依然被丢弃。**具体实现方式是丢弃广播/多播数据，这就意味着以太网地址解析`arp`将不可运行，除非手工探测`MAC`地址，否则通信将无法在同一宿主机下的多个`macvlan`网卡间展开**。之所以隔离广播流量，是因为以太网是基于广播的，隔离了广播，以太网将失去了依托

### 2.6.2 bridge mode

![macvlan_bridge](/images/Linux-Network/macvlan_bridge.jpg)

**验证1：macvlan接口与宿主机同一个网段**

1. macvlan接口之间是否连通
1. macvlan接口和主机是否连通
1. macvlan接口是否能通外网

```sh
# 配置
source macvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export macvlan_mode="bridge"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="10.0.2.2" # 默认路由网关ip
export ip_macvlan1="10.0.2.16" # macvlan接口1的ip
export ip_macvlan2="10.0.2.17" # macvlan接口2的ip
export ip_netmask="255.255.255.0" # macvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add macvlan1 link enp0s3 type macvlan mode bridge
+ ip link add macvlan2 link enp0s3 type macvlan mode bridge
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set macvlan1 netns liuye1
+ ip link set macvlan2 netns liuye2
+ ip netns exec liuye1 ip link set macvlan1 up
+ ip netns exec liuye1 ip addr add 10.0.2.16/255.255.255.0 dev macvlan1
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye1 ip route add default via 10.0.2.2 dev macvlan1
+ ip netns exec liuye2 ip link set macvlan2 up
+ ip netns exec liuye2 ip addr add 10.0.2.17/255.255.255.0 dev macvlan2
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye2 ip route add default via 10.0.2.2 dev macvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping macvlan2的ip
ip netns exec ${namespace1} ping ${ip_macvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.17 (10.0.2.17) 56(84) bytes of data.
64 bytes from 10.0.2.17: icmp_seq=1 ttl=64 time=0.104 ms
64 bytes from 10.0.2.17: icmp_seq=2 ttl=64 time=0.071 ms
64 bytes from 10.0.2.17: icmp_seq=3 ttl=64 time=0.105 ms

--- 10.0.2.17 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2017ms
rtt min/avg/max/mdev = 0.071/0.093/0.105/0.017 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan2所在的网络命名空间中ping macvlan1的ip
ip netns exec ${namespace2} ping ${ip_macvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.16 (10.0.2.16) 56(84) bytes of data.
64 bytes from 10.0.2.16: icmp_seq=1 ttl=64 time=0.047 ms
64 bytes from 10.0.2.16: icmp_seq=2 ttl=64 time=0.069 ms
64 bytes from 10.0.2.16: icmp_seq=3 ttl=64 time=0.174 ms

--- 10.0.2.16 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2053ms
rtt min/avg/max/mdev = 0.047/0.096/0.174/0.056 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping 主机的ip（同一个网段）
ip netns exec ${namespace1} ping ${ip_host} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.

--- 10.0.2.15 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2052ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping 外网ip
ip netns exec ${namespace1} ping 223.5.5.5 -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=1 ttl=117 time=17.9 ms
64 bytes from 223.5.5.5: icmp_seq=2 ttl=117 time=1.77 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=117 time=1.52 ms

--- 223.5.5.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 1.527/7.075/17.927/7.674 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete macvlan1
+ ip netns exec liuye2 ip link delete macvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论1：两个macvlan子接口可以相互ping通，但是ping不通master接口。在ip正确配置的情况下，能够正常通外网**

* 我的实验环境是`VirtualBox`虚拟机，第一次setup之后，`ping 223.5.5.5`是可以通的，但是当执行`cleanup`后再次执行`setup`，此时发现`ping 223.5.5.5`是无法ping通的，估计是因为VirtualBox对mac地址是有缓存的，先后两次创建的`macvlan`的mac地址不同，但是ip是相同的，转发逻辑就出问题了。这时，只需要修改macvlan的ip地址，就能再次ping通`223.5.5.5`了

**验证2：macvlan接口与宿主机不同网段**

1. macvlan接口之间是否连通

```sh
# 配置
source macvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export macvlan_mode="bridge"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="" # 默认路由网关ip
export ip_macvlan1="192.168.100.1" # macvlan接口1的ip
export ip_macvlan2="192.168.200.1" # macvlan接口2的ip
export ip_netmask="255.255.255.0" # macvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add macvlan1 link enp0s3 type macvlan mode bridge
+ ip link add macvlan2 link enp0s3 type macvlan mode bridge
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set macvlan1 netns liuye1
+ ip link set macvlan2 netns liuye2
+ ip netns exec liuye1 ip link set macvlan1 up
+ ip netns exec liuye1 ip addr add 192.168.100.1/255.255.255.0 dev macvlan1
+ '[' -z '' ']'
+ ip netns exec liuye1 ip route add default dev macvlan1
+ ip netns exec liuye2 ip link set macvlan2 up
+ ip netns exec liuye2 ip addr add 192.168.200.1/255.255.255.0 dev macvlan2
+ '[' -z '' ']'
+ ip netns exec liuye2 ip route add default dev macvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping macvlan2的ip
ip netns exec ${namespace1} ping ${ip_macvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=64 time=0.243 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=64 time=0.041 ms
64 bytes from 192.168.200.1: icmp_seq=3 ttl=64 time=0.045 ms

--- 192.168.200.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2056ms
rtt min/avg/max/mdev = 0.041/0.109/0.243/0.095 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan2所在的网络命名空间中ping macvlan1的ip
ip netns exec ${namespace2} ping ${ip_macvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.042 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.126 ms
64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=0.052 ms

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2280ms
rtt min/avg/max/mdev = 0.042/0.073/0.126/0.038 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete macvlan1
+ ip netns exec liuye2 ip link delete macvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论2：两个macvlan接口，即便配置不同网段的ip，也能相互ping通**

### 2.6.3 vepa mode

在`vepa`模式下，所有从`macvlan`接口发出的流量，不管目的地全部都发送给父接口，即使流量的目的地是共享同一个父接口的其它`macvlan`接口。在二层网络场景下，由于生成树协议的原因，两个`macvlan`接口之间的通讯会被阻塞，这时需要上层路由器上为其添加路由（需要外部交换机配置`Hairpin`支持，即需要兼容`802.1Qbg`的交换机支持，其可以把源和目的地址都是本地`macvlan`接口地址的流量发回给相应的接口）。此模式下从父接口收到的广播包，会泛洪给`vepa`模式的所有子接口。

现在大多数交换机都不支持`Hairpin`模式，但`Linux`主机中可以通过一种`Harpin`模式的`Bridge`来让`vepa`模式下的不同`macvlan`接口通信(前文已经提到，`Bridge`其实就是一种旧式交换机)。怎么配置呢？非常简单，通过一条命令就可以解决：

```sh
# 方式1
brctl hairpin br0 eth1 on

# 方式2
bridge link set dev eth0 hairpin on

# 方式3
echo 1 >/sys/class/net/br0/brif/eth1/hairpin_mode
```

![macvlan_vepa](/images/Linux-Network/macvlan_vepa.jpg)

**验证1：macvlan接口与宿主机同一个网段**

1. macvlan接口之间是否连通
1. macvlan接口和主机是否连通
1. macvlan接口是否能通外网

```sh
# 配置
source macvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export macvlan_mode="vepa"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="10.0.2.2" # 默认路由网关ip
export ip_macvlan1="10.0.2.16" # macvlan接口1的ip
export ip_macvlan2="10.0.2.17" # macvlan接口2的ip
export ip_netmask="255.255.255.0" # macvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add macvlan1 link enp0s3 type macvlan mode vepa
+ ip link add macvlan2 link enp0s3 type macvlan mode vepa
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set macvlan1 netns liuye1
+ ip link set macvlan2 netns liuye2
+ ip netns exec liuye1 ip link set macvlan1 up
+ ip netns exec liuye1 ip addr add 10.0.2.16/255.255.255.0 dev macvlan1
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye1 ip route add default via 10.0.2.2 dev macvlan1
+ ip netns exec liuye2 ip link set macvlan2 up
+ ip netns exec liuye2 ip addr add 10.0.2.17/255.255.255.0 dev macvlan2
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye2 ip route add default via 10.0.2.2 dev macvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping macvlan2的ip
ip netns exec ${namespace1} ping ${ip_macvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.17 (10.0.2.17) 56(84) bytes of data.

--- 10.0.2.17 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2004ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan2所在的网络命名空间中ping macvlan1的ip
ip netns exec ${namespace2} ping ${ip_macvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.16 (10.0.2.16) 56(84) bytes of data.

--- 10.0.2.16 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2005ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping 主机的ip（同一个网段）
ip netns exec ${namespace1} ping ${ip_host} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.

--- 10.0.2.15 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2010ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping 外网ip
ip netns exec ${namespace1} ping 223.5.5.5 -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=1 ttl=117 time=16.8 ms
64 bytes from 223.5.5.5: icmp_seq=2 ttl=117 time=8.12 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=117 time=4.62 ms

--- 223.5.5.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 4.627/9.862/16.839/5.136 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete macvlan1
+ ip netns exec liuye2 ip link delete macvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论1：macvlan接口之间无法ping通（要求switch支持`802.1Qbg/VPEA`，我的测试环境是virtualBox虚拟机，估计不支持），macvlan接口与宿主机无法ping通。ip配置正确的情况下，可以通外网**

**验证2：macvlan接口与宿主机不同网段**

1. macvlan接口之间是否连通

```sh
# 配置
source macvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export macvlan_mode="vepa"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="" # 默认路由网关ip
export ip_macvlan1="192.168.100.1" # macvlan接口1的ip
export ip_macvlan2="192.168.200.1" # macvlan接口2的ip
export ip_netmask="255.255.255.0" # macvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add macvlan1 link enp0s3 type macvlan mode vepa
+ ip link add macvlan2 link enp0s3 type macvlan mode vepa
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set macvlan1 netns liuye1
+ ip link set macvlan2 netns liuye2
+ ip netns exec liuye1 ip link set macvlan1 up
+ ip netns exec liuye1 ip addr add 192.168.100.1/255.255.255.0 dev macvlan1
+ '[' -z '' ']'
+ ip netns exec liuye1 ip route add default dev macvlan1
+ ip netns exec liuye2 ip link set macvlan2 up
+ ip netns exec liuye2 ip addr add 192.168.200.1/255.255.255.0 dev macvlan2
+ '[' -z '' ']'
+ ip netns exec liuye2 ip route add default dev macvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan1所在的网络命名空间中ping macvlan2的ip
ip netns exec ${namespace1} ping ${ip_macvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.

--- 192.168.200.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2031ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在macvlan2所在的网络命名空间中ping macvlan1的ip
ip netns exec ${namespace2} ping ${ip_macvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2037ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete macvlan1
+ ip netns exec liuye2 ip link delete macvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论2：macvlan接口之间无法ping通（要求switch支持`802.1Qbg/VPEA`，我的测试环境是virtualBox虚拟机，估计不支持）**

### 2.6.4 passthru mode

![macvlan_passthru](/images/Linux-Network/macvlan_passthru.jpg)

## 2.7 ipvlan

**内核版本3.19才支持这一特性**

ipvlan和macvlan比较相似，区别就是ipvlan虚拟出来的接口都具有相同的mac地址。对于ipvlan，只要父接口相同，即使子接口不在同一个网络，也可以互相ping通对方，因为ipvlan会在中间做报文的转发工作

内核默认是没有启用ipvlan模块的，需要设置内核参数`CONFIG_IPVLAN=y`并重新编译内核，如何编译请参考{% post_link Linux-Kernel %}，执行`make menuconfig`时开启该参数，操作如下

1. `Networking support`
	* `Networking options`
		* `L3 Master device support`：选中（对应配置项`CONFIG_NET_L3_MASTER_DEV`）
1. `Device Drivers`
	* `Network device support`
		* `IP-VLAN support`：选中（对应配置项`CONFIG_IPVLAN`）
			* `IP-VLAN based tap driver`：选中（对应配置项`CONFIG_IPVTAP`）

**ipvlan包含如下三种模式**

1. `l2`：该模式下，父接口有点像交换机或者网桥，工作在2层
1. `l3`：该模式下，父接口有点像路由器的功能，工作在3层
1. `l3s`

**准备一个脚本，用于验证各个模式**

```sh
cat > ~/ipvlan.sh << 'EOF'
#!/bin/bash

export ipvlan_mode=""

export namespace1=liuye1
export namespace2=liuye2

export ifname_external=""
export ifname_ipvlan1=ipvlan1
export ifname_ipvlan2=ipvlan2

export ip_host=""
export default_gateway=""
export ip_ipvlan1=""
export ip_ipvlan2=""
export ip_netmask=""

function setup() {
	set -x

	ip link add ${ifname_ipvlan1} link ${ifname_external} type ipvlan mode ${ipvlan_mode}
	ip link add ${ifname_ipvlan2} link ${ifname_external} type ipvlan mode ${ipvlan_mode}

	ip netns add ${namespace1}
	ip netns add ${namespace2}

	ip link set ${ifname_ipvlan1} netns ${namespace1}
	ip link set ${ifname_ipvlan2} netns ${namespace2}

	ip netns exec ${namespace1} ip link set ${ifname_ipvlan1} up
	ip netns exec ${namespace1} ip addr add ${ip_ipvlan1}/${ip_netmask} dev ${ifname_ipvlan1}
	if [ -z "${default_gateway}" ]; then
		ip netns exec ${namespace1} ip route add default dev ${ifname_ipvlan1}
	else
		ip netns exec ${namespace1} ip route add default via ${default_gateway} dev ${ifname_ipvlan1}
	fi

	ip netns exec ${namespace2} ip link set ${ifname_ipvlan2} up
	ip netns exec ${namespace2} ip addr add ${ip_ipvlan2}/${ip_netmask} dev ${ifname_ipvlan2}
	if [ -z "${default_gateway}" ]; then
		ip netns exec ${namespace2} ip route add default dev ${ifname_ipvlan2}
	else
		ip netns exec ${namespace2} ip route add default via ${default_gateway} dev ${ifname_ipvlan2}
	fi

	set +x
}

function cleanup() {
	set -x

	ip netns exec ${namespace1} ip link delete ${ifname_ipvlan1}
	ip netns exec ${namespace2} ip link delete ${ifname_ipvlan2}

	ip netns delete ${namespace1}
	ip netns delete ${namespace2}

	set +x
}

export -f setup
export -f cleanup
EOF
```

### 2.7.1 l2 mode

![ipvlan_l2](/images/Linux-Network/ipvlan_l2.png)

**验证1：ipvlan接口与宿主机同一个网段**

1. ipvlan接口之间是否连通
1. ipvlan接口和主机是否连通
1. ipvlan接口是否能通外网

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l2"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="10.0.2.2" # 默认路由网关ip
export ip_ipvlan1="10.0.2.16" # ipvlan接口1的ip
export ip_ipvlan2="10.0.2.17" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l2
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l2
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 10.0.2.16/255.255.255.0 dev ipvlan1
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye1 ip route add default via 10.0.2.2 dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 10.0.2.17/255.255.255.0 dev ipvlan2
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye2 ip route add default via 10.0.2.2 dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.17 (10.0.2.17) 56(84) bytes of data.
64 bytes from 10.0.2.17: icmp_seq=1 ttl=64 time=1.01 ms
64 bytes from 10.0.2.17: icmp_seq=2 ttl=64 time=0.422 ms
64 bytes from 10.0.2.17: icmp_seq=3 ttl=64 time=0.050 ms

--- 10.0.2.17 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2057ms
rtt min/avg/max/mdev = 0.050/0.494/1.012/0.396 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.16 (10.0.2.16) 56(84) bytes of data.
64 bytes from 10.0.2.16: icmp_seq=1 ttl=64 time=0.033 ms
64 bytes from 10.0.2.16: icmp_seq=2 ttl=64 time=0.050 ms
64 bytes from 10.0.2.16: icmp_seq=3 ttl=64 time=0.043 ms

--- 10.0.2.16 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2091ms
rtt min/avg/max/mdev = 0.033/0.042/0.050/0.007 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 主机的ip（同一个网段）
ip netns exec ${namespace1} ping ${ip_host} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.

--- 10.0.2.15 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2010ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 外网ip
ip netns exec ${namespace1} ping 223.5.5.5 -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=2 ttl=63 time=43.6 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=63 time=94.1 ms

--- 223.5.5.5 ping statistics ---
3 packets transmitted, 2 received, 33% packet loss, time 2018ms
rtt min/avg/max/mdev = 43.677/68.897/94.118/25.221 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论1：ipvlan接口之间可以相互ping通，但是无法ping通master接口。ip配置正确的情况下，可以通外网**

**验证2：ipvlan接口与宿主机不同网段**

1. ipvlan接口之间是否连通

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l2"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="" # 默认路由网关ip
export ip_ipvlan1="192.168.100.1" # ipvlan接口1的ip
export ip_ipvlan2="192.168.200.1" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l2
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l2
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 192.168.100.1/255.255.255.0 dev ipvlan1
+ '[' -z '' ']'
+ ip netns exec liuye1 ip route add default dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 192.168.200.1/255.255.255.0 dev ipvlan2
+ '[' -z '' ']'
+ ip netns exec liuye2 ip route add default dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=64 time=0.783 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=64 time=0.041 ms
64 bytes from 192.168.200.1: icmp_seq=3 ttl=64 time=0.087 ms

--- 192.168.200.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2085ms
rtt min/avg/max/mdev = 0.041/0.303/0.783/0.340 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.029 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.089 ms
64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=0.047 ms

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2074ms
rtt min/avg/max/mdev = 0.029/0.055/0.089/0.025 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论2：ipvlan接口之间可以相互ping通，即便网段不同**

### 2.7.2 l3 mode

![ipvlan_l3](/images/Linux-Network/ipvlan_l3.png)

**验证1：ipvlan接口与宿主机同一个网段**

1. ipvlan接口之间是否连通
1. ipvlan接口和主机是否连通
1. ipvlan接口是否能通外网

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l3"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="10.0.2.2" # 默认路由网关ip
export ip_ipvlan1="10.0.2.16" # ipvlan接口1的ip
export ip_ipvlan2="10.0.2.17" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l3
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l3
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 10.0.2.16/255.255.255.0 dev ipvlan1
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye1 ip route add default via 10.0.2.2 dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 10.0.2.17/255.255.255.0 dev ipvlan2
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye2 ip route add default via 10.0.2.2 dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.17 (10.0.2.17) 56(84) bytes of data.
64 bytes from 10.0.2.17: icmp_seq=1 ttl=64 time=0.037 ms
64 bytes from 10.0.2.17: icmp_seq=2 ttl=64 time=0.039 ms
64 bytes from 10.0.2.17: icmp_seq=3 ttl=64 time=0.055 ms

--- 10.0.2.17 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2044ms
rtt min/avg/max/mdev = 0.037/0.043/0.055/0.011 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.16 (10.0.2.16) 56(84) bytes of data.
64 bytes from 10.0.2.16: icmp_seq=1 ttl=64 time=0.037 ms
64 bytes from 10.0.2.16: icmp_seq=2 ttl=64 time=0.043 ms
64 bytes from 10.0.2.16: icmp_seq=3 ttl=64 time=0.206 ms

--- 10.0.2.16 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2058ms
rtt min/avg/max/mdev = 0.037/0.095/0.206/0.078 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 主机的ip（同一个网段）
ip netns exec ${namespace1} ping ${ip_host} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.

--- 10.0.2.15 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2077ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 外网ip
ip netns exec ${namespace1} ping 223.5.5.5 -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=1 ttl=63 time=5.50 ms
64 bytes from 223.5.5.5: icmp_seq=2 ttl=63 time=7.81 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=63 time=8.21 ms

--- 223.5.5.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2005ms
rtt min/avg/max/mdev = 5.503/7.177/8.215/1.195 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论1：ipvlan接口之间可以相互ping通，但是无法ping通master接口。ip配置正确的情况下，可以通外网**

**验证2：ipvlan接口与宿主机不同网段**

1. ipvlan接口之间是否连通

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l3"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="" # 默认路由网关ip
export ip_ipvlan1="192.168.100.1" # ipvlan接口1的ip
export ip_ipvlan2="192.168.200.1" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l3
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l3
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 192.168.100.1/255.255.255.0 dev ipvlan1
+ '[' -z '' ']'
+ ip netns exec liuye1 ip route add default dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 192.168.200.1/255.255.255.0 dev ipvlan2
+ '[' -z '' ']'
+ ip netns exec liuye2 ip route add default dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=64 time=0.044 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=64 time=0.066 ms
64 bytes from 192.168.200.1: icmp_seq=3 ttl=64 time=0.047 ms

--- 192.168.200.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2149ms
rtt min/avg/max/mdev = 0.044/0.052/0.066/0.011 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.032 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.097 ms
64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=0.042 ms

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2036ms
rtt min/avg/max/mdev = 0.032/0.057/0.097/0.028 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论2：ipvlan接口之间可以相互ping通，即便网段不同**

### 2.7.3 l3s mode

**验证1：ipvlan接口与宿主机同一个网段**

1. ipvlan接口之间是否连通
1. ipvlan接口和主机是否连通
1. ipvlan接口是否能通外网

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l3s"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="10.0.2.2" # 默认路由网关ip
export ip_ipvlan1="10.0.2.16" # ipvlan接口1的ip
export ip_ipvlan2="10.0.2.17" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l3s
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l3s
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 10.0.2.16/255.255.255.0 dev ipvlan1
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye1 ip route add default via 10.0.2.2 dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 10.0.2.17/255.255.255.0 dev ipvlan2
+ '[' -z 10.0.2.2 ']'
+ ip netns exec liuye2 ip route add default via 10.0.2.2 dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.17 (10.0.2.17) 56(84) bytes of data.
64 bytes from 10.0.2.17: icmp_seq=1 ttl=64 time=0.119 ms
64 bytes from 10.0.2.17: icmp_seq=2 ttl=64 time=0.042 ms
64 bytes from 10.0.2.17: icmp_seq=3 ttl=64 time=0.046 ms

--- 10.0.2.17 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2074ms
rtt min/avg/max/mdev = 0.042/0.069/0.119/0.035 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.16 (10.0.2.16) 56(84) bytes of data.
64 bytes from 10.0.2.16: icmp_seq=1 ttl=64 time=0.078 ms
64 bytes from 10.0.2.16: icmp_seq=2 ttl=64 time=0.046 ms
64 bytes from 10.0.2.16: icmp_seq=3 ttl=64 time=0.037 ms

--- 10.0.2.16 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2104ms
rtt min/avg/max/mdev = 0.037/0.053/0.078/0.019 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 主机的ip（同一个网段）
ip netns exec ${namespace1} ping ${ip_host} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 10.0.2.15 (10.0.2.15) 56(84) bytes of data.

--- 10.0.2.15 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2061ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping 外网ip
ip netns exec ${namespace1} ping 223.5.5.5 -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 223.5.5.5 (223.5.5.5) 56(84) bytes of data.
64 bytes from 223.5.5.5: icmp_seq=1 ttl=63 time=88.4 ms
64 bytes from 223.5.5.5: icmp_seq=2 ttl=63 time=66.6 ms
64 bytes from 223.5.5.5: icmp_seq=3 ttl=63 time=159 ms

--- 223.5.5.5 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2069ms
rtt min/avg/max/mdev = 66.605/104.814/159.405/39.617 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论1：ipvlan接口之间可以相互ping通，但是无法ping通master接口。ip配置正确的情况下，可以通外网**

**验证2：ipvlan接口与宿主机不同网段**

1. ipvlan接口之间是否连通

```sh
source ipvlan.sh
export ifname_external="enp0s3" # 主机的外网网卡
export ipvlan_mode="l3s"
export ip_host="10.0.2.15" # 主机ip
export default_gateway="" # 默认路由网关ip
export ip_ipvlan1="192.168.100.1" # ipvlan接口1的ip
export ip_ipvlan2="192.168.200.1" # ipvlan接口2的ip
export ip_netmask="255.255.255.0" # ipvlan接口的子网掩码
setup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip link add ipvlan1 link enp0s3 type ipvlan mode l3s
+ ip link add ipvlan2 link enp0s3 type ipvlan mode l3s
+ ip netns add liuye1
+ ip netns add liuye2
+ ip link set ipvlan1 netns liuye1
+ ip link set ipvlan2 netns liuye2
+ ip netns exec liuye1 ip link set ipvlan1 up
+ ip netns exec liuye1 ip addr add 192.168.100.1/255.255.255.0 dev ipvlan1
+ '[' -z '' ']'
+ ip netns exec liuye1 ip route add default dev ipvlan1
+ ip netns exec liuye2 ip link set ipvlan2 up
+ ip netns exec liuye2 ip addr add 192.168.200.1/255.255.255.0 dev ipvlan2
+ '[' -z '' ']'
+ ip netns exec liuye2 ip route add default dev ipvlan2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan1所在的网络命名空间中ping ipvlan2的ip
ip netns exec ${namespace1} ping ${ip_ipvlan2} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.200.1 (192.168.200.1) 56(84) bytes of data.
64 bytes from 192.168.200.1: icmp_seq=1 ttl=64 time=0.059 ms
64 bytes from 192.168.200.1: icmp_seq=2 ttl=64 time=0.045 ms
64 bytes from 192.168.200.1: icmp_seq=3 ttl=64 time=0.122 ms

--- 192.168.200.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2191ms
rtt min/avg/max/mdev = 0.045/0.075/0.122/0.034 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 在ipvlan2所在的网络命名空间中ping ipvlan1的ip
ip netns exec ${namespace2} ping ${ip_ipvlan1} -c 3
#-------------------------↓↓↓↓↓↓-------------------------
PING 192.168.100.1 (192.168.100.1) 56(84) bytes of data.
64 bytes from 192.168.100.1: icmp_seq=1 ttl=64 time=0.033 ms
64 bytes from 192.168.100.1: icmp_seq=2 ttl=64 time=0.043 ms
64 bytes from 192.168.100.1: icmp_seq=3 ttl=64 time=0.049 ms

--- 192.168.100.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2037ms
rtt min/avg/max/mdev = 0.033/0.041/0.049/0.009 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
+ ip netns exec liuye1 ip link delete ipvlan1
+ ip netns exec liuye2 ip link delete ipvlan2
+ ip netns delete liuye1
+ ip netns delete liuye2
+ set +x
#-------------------------↑↑↑↑↑↑-------------------------
```

**结论2：ipvlan接口之间可以相互ping通，但是无法ping通master接口。ip配置正确的情况下，可以通外网**

## 2.8 macvtap/ipvtap

## 2.9 macsec

## 2.10 veth（virtual ethernet）

## 2.11 vcan（virtual can）

## 2.12 vxcan（virtual can tunnel）

## 2.13 ipoib（ip-over-infiniBand）

## 2.14 nlmon（netlink monitor）

## 2.15 dummy interface

## 2.16 ifb（intermediate functional block）

## 2.17 netdevsim

## 2.18 参考

* [Introduction to Linux interfaces for virtual networking](https://developers.redhat.com/blog/2018/10/22/introduction-to-linux-interfaces-for-virtual-networking/)
* [CONFIGURING AND MANAGING NETWORKING](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_networking/index)
* [IPVLAN Driver HOWTO](https://www.kernel.org/doc/html/latest/networking/ipvlan.html)
* [VLAN 基础知识](https://zhuanlan.zhihu.com/p/35616289)
* [Kubernetes网络的IPVlan方案](https://kernel.taobao.org/2019/11/ipvlan-for-kubernete-net/)
* [IPVLAN网络模式](https://support.huaweicloud.com/dpmg-kunpengwebs/kunpengnginx_04_0010.html)
* [linux 网络虚拟化： macvlan](https://cizixs.com/2017/02/14/network-virtualization-macvlan/)
* [Macvlan与ipvlan解析](https://www.dazhuanlan.com/2019/12/12/5df17e01243b0/)
* [Linux 虚拟网卡技术：Macvlan](https://fuckcloudnative.io/posts/netwnetwork-virtualization-macvlan/)
* [VXLAN 基础教程：VXLAN 协议原理介绍](https://fuckcloudnative.io/posts/vxlan-protocol-introduction/)
* [VXLAN 基础教程：在 Linux 上配置 VXLAN 网络](https://fuckcloudnative.io/posts/vxlan-linux/)
* [Linux bonding研究及实现](https://developer.aliyun.com/article/478834)

# 3 Netfilter

Linux中最常用的基本防火墙软件称为`iptables`。`iptables`防火墙通过与Linux内核的网络堆栈中的数据包过滤`hook`进行交互来工作。这些内核`hook`称为`netfilter`框架

进入网络系统（`incoming`或`outgoing`）的每个数据包将在它通过网络堆栈时触发这些`hook`，允许注册这些`hook`的程序与关键点的流量进行交互。与`iptables`相关联的内核模块在这些`hook`处注册，以确保流量符合防火墙的设定

## 3.1 Netfilter Hooks

`netfilter`一共包含5个`hook`。当数据包通过网络堆栈时，注册到这些`hook`的内核模块将被触发执行。数据包是否触发`hook`，取决于数据包是`incoming`还是`outgoing`，数据包的目标，以及数据包是否在之前的点已被丢弃或拒绝

1. **`NF_IP_PRE_ROUTING`**：该`hook`会在任意`incoming`数据包进入网络堆栈时触发。并且，会在做出路由决定前处理完毕
1. **`NF_IP_LOCAL_IN`**：该`hook`会在某个`incoming`数据包被路由到`local system`时触发
1. **`NF_IP_FORWARD`**：该`hook`会在某个`incoming`数据包被`forwarded`到其他主机时触发
1. **`NF_IP_LOCAL_OUT`**：该`hook`会在任意`outgoing`数据包进入网络堆栈时触发
1. **`NF_IP_POST_ROUTING`**：该`hook`会在任意`outgoing`或`forwarded`数据包发生路由之后，传输之前触发

在`hook`处注册的内核模块必须提供优先级编号，来确定触发`hook`时调用内核模块的顺序。每个模块将按照优先级顺序依次被调用，并在处理后将处理结果返回`netfilter`，以便让`netfilter`决定对数据包进行何种操作

## 3.2 IPTables Tables and Chains

`iptables`防火墙使用`table`来组织其`rule`。这些`table`根据决策类型进行分类。例如，如果`rule`处理网络地址转换，它将被放入`nat table`中。如果该`rule`用于决定是否允许数据包继续到其目的地，则可能会将其添加到`filter table`中

在每个`iptables table`中，`rule`进一步被拆分到不同的`chain`中。**其中，`table`代表了决策类型；`chain`表示由哪个`hook`来触发，即决定`rule`何时进行校验**

| `Chain` | `hoook` |
|:--|:--|
| `PREROUTING` | `NF_IP_PRE_ROUTING` |
| `INPUT` | `NF_IP_LOCAL_IN` |
| `FORWARD` | `NF_IP_FORWARD` |
| `OUTPUT` | `NF_IP_LOCAL_OUT` |
| `POSTROUTING` | `NF_IP_POST_ROUTING` |

`chain`允许管理员控制数据包的传递路径中的评估`rule`。由于每个`table`都有多个`chain`，因此一个`table`的作用点可能会有多个（关联到了多个`hook`）。由于某些类型的决策仅在网络堆栈中的某些点有意义，因此`talbe`不会在每个内核`hook`中进行注册

只有五个`netfilter`内核`hook`，因此，每个`hook`注册了多个来自不同`table`的`chian`。例如，三个`table`具有`PREROUTING chain`。当这些`chain`在相关的`NF_IP_PRE_ROUTING hook`处注册时，它们指定一个优先级，该优先级指示每个`table`的`PREROUTING chain`被调用的顺序。在进入下一个`PREROUTING`链之前，将按顺序评估最高优先级`PREROUTING chain`中的每个`rule`

![netfilter_hook](/images/Linux-Network/netfilter_hook.jpg)

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

**Chain Traversal Order**

1. **Incoming packets destined for the local system**：`PREROUTING -> INPUT`
1. **Incoming packets destined to another host**：`PREROUTING -> FORWARD -> POSTROUTING`
1. **Locally generated packets**：`OUTPUT -> POSTROUTING`

举个例子，一个`incoming`数据包，其目的地是`local systeml`，那么`PREROUTING chain`会被首先触发，按照优先级顺序，依次是`raw table`、`mangle table`、`nat table`的逻辑会被执行。然后`INPUT chain`会被触发，按照优先级顺序，依次是`mangle table`、`filter table`、`security table`以及`nat table`

## 3.5 IPTables Rules

**一个`rule`由一个`table`以及一个`chain`唯一确定**。每个`rule`都有一个`matching component`以及一个`action component`

**`matching component`用于指定数据包必须满足的条件，以便执行相关的操作**。匹配系统非常灵活，可以通过系统上的`iptables`进行配置，允许进行如下粒度的配置

1. **协议类型**
1. **目的地或源地址**
1. **目的地或源端口**
1. **目的地或源网络**
1. **输入或输出接口**
1. **报头或连接状态以及其他标准**
* 上述规则可以自由组合，用来创建相当复杂的规则集以区分不同的流量

**`action component`用于在满足规则匹配条件时，输出一个`target`**：`target`通常分为以下两类

1. **`Terminating targets`**：执行一个动作，该动作终止`chain`中的执行逻辑并将控制返回到`netfilter`的`hook`中。根据提供的返回值，`hook`可能会丢弃数据包或允许数据包继续进行下一个处理阶段
1. **`Non-terminating targets`**：执行一个动作，并继续`chain`中的执行逻辑。尽管每个`chain`最终必须传回`Terminating targets`，但是可以预先执行任意数量的`Non-terminating targets`

## 3.6 Jumping to User-Defined Chains

这里需要提到一个特殊的`Non-terminating targets`，即`jump target`。`jump target`可以跳转到其他`chain`中执行额外的处理逻辑。在上面讨论到的`built-in chains`已经预先注册到了`netfilter hook`中，而`User-Defined Chains`是不允许注册到`hook`中的。尽管如此，`iptables`仍然允许用户自定义`chain`，其原理就是用到了`jump target`

## 3.7 IPTables and Connection Tracking

在讨论`raw table`时，我们介绍了在`netfilter`框架之上实现的`connection tracking`。`connection tracking`允许`iptables`在当前连接的上下文中查看数据包。`connection tracking`为`iptables`提供执行“有状态”操作所需的功能

数据包进入网络堆栈后很快就会应用`connection tracking`。**`raw table chains`和一些基本的健全性检查是在将`数据包`与`连接`相关联之前对数据包执行的唯一逻辑**

**`connection tracking`是实现`NAT`地址转换的灵魂，一个连接仅在首次经过`netfilter`链条时会计算`NAT`表，一旦`connection tracking`记录下这次的改写关系，后续无论是去程包还是回程包都是依据`connection tracking`表进行改写关系的处理，不会再重复执行`NAT`表中的`DNAT/SNAT`规则**

系统根据一组现有连接检查每个数据包，将更新数据包所属连接的状态，或增加一个新的连接。**在`raw table chains`中标记有`NOTRACK target`的数据包将绕过`connection tracking`处理流程**

在`connection tracking`中，一个数据包可能被标记为如下几种状态

1. **`NEW`**：当前数据包不属于任何一个现有的`connection`，且是一个合法的`first package`，那么将会创建一个新的`connection`
1. **`ESTABLISHED`**：当收到一个`response`时，`connection`会从`NEW`状态变为`ESTABLISHED`状态。对于`TCP`，这意味着这是一个`SYN/ACK`数据包；对于`UDP`，这意味着这是一个`ICMP`数据包
1. **`RELATED`**：当前数据包不属于任何一个现有的`connection`，但是关联到某个`connection`。这通常是一个`helper connection`，例如`FTP data transmission connection`或者是`ICMP`对其他协议的`连接尝试`的响应
1. **`INVALID`**：当前数据包不属于任何一个现有的`connection`，也不是一个合法的`first package`
1. **`UNTRACKED`**：通过`raw table`的配置，绕过`connection tracking`的处理流程
1. **`SNAT`**：`source address`被`NAT`修改时设置的虚拟状态，被记录在`connection tracking`中，以便在`reply package`（我回复别人）中更改`source address`
1. **`DNAT`**：`destination address`被`NAT`修改时设置的虚拟状态，被记录在`connection tracking`中，以便在路由`reply package`（别人回复我）时知道更改`destination address`

#### 3.7.0.1 conntrack

**示例：**

* `conntrack -S`：查看统计信息，以cpu为维度进行聚合，当机器的核数很多时，会输出比cpu核数更多的行，但是多出来的那部分都是冗余的数据，无实际意义
* `conntrack -L`

## 3.8 NAT原理

**NAT的实现依赖`connection tracking`**

以一个示例来进行解释，条件如下：

1. `Machine A`在私网环境下，其`IP`是`192.168.1.2`
1. `NAT Gateway A`有两张网卡
    * 一张网卡的`IP`为`192.168.1.1`，与`Machine A`在同一个网段，且为`Machine A`的默认路由地址
    * 一张网卡的`IP`为`100.100.100.1`，为公网`IP`
1. `Machine B`在私网环境下，其IP是`192.168.2.2`
1. `NAT Gateway B`有两张网卡
    * 一张网卡的`IP`为`192.168.2.1`，与`Machine B`在同一个网段，且为`Machine B`的默认路由地址
    * 一张网卡的`IP`为`200.200.200.1`，为公网`IP`

**Request from Machine A to Machine B**

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

**Response from Machine B to Machine A**

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

**细心的朋友可能会发现，`NAT Gateway A`只配置了`SNAT`，而`NAT Gateway B`只配置了`DNAT`，但是在`Response`的链路中，`NAT Gateway A`做了`DNAT`的工作，而`NAT Gateway B`做了`SNAT`的工作**

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

**如此一来，有了IP+端口，一台网关就可以为多台机器配置SNAT；同理，也可以为多台机器配置DNAT**

**但是，如果两台私网的机器A和B（均在网关上配置了SNAT规则），同时ping某个外网IP的话，NAT又是如何工作的呢？（ICMP协议没有port，而只根据IP是没法区分这两台私网机器的）方法就是：创造端口（下面这种做法是我猜的，与实际情况未必一致，但是思路是相似的）**

* 假设A的IP为`192.168.1.2`，`NAT Gateway`的IP是`100.100.100.1`，ping的公网IP是`200.200.200.1`
* 当`ICMP Request`报文到达`NAT Gateway`的时候，根据`identifier`生成源端口号，修改`srcIP`，以及`identifier`并增加如下记录（SNAT）
    * 其中，`mapFunc`表示从`identifier`转换为端口号的算法

| osrcIP | osrcPort | msrcIP | msrcPort | protocol |
|:--|:--|:--|:--|:--|
| 192.168.0.2 | mapFunc(oIdentifier) | 200.10.2.1 | mapFunc(mIdentifier) | ICMP |

* 当`ICMP Response`报文到达`NAT Gateway`的时候，会查找`dstIP`与`msrcIP`相同且`dstPort`（通过`mapFunc`计算`ICMP Response`中的`identifier`）与`msrcPort`相同的表项，并将`dstIP`替换成`osrcIP`，`identifier`替换成`mapFuncInv(osrcPort)`（DNAT）
    * 其中，`mapFuncInv`表示从端口号转换为`identifier`的算法

## 3.9 iptable命令使用

参见{% post_link Linux-Frequently-Used-Commands %}

## 3.10 参考

* [A Deep Dive into Iptables and Netfilter Architecture](https://www.digitalocean.com/community/tutorials/a-deep-dive-into-iptables-and-netfilter-architecture)
* [ICMP报文如何通过NAT来地址转换](https://blog.csdn.net/sinat_33822516/article/details/81088724)
* [Understanding how dnat works in iptables](https://superuser.com/questions/662325/understanding-how-dnat-works-in-iptables)
* [How Network Address Translation Works](https://computer.howstuffworks.com/nat.htm)
* [Traditional IP Network Address Translator (Traditional NAT) - 4.1](https://tools.ietf.org/html/rfc3022)
* [纯文本作图-asciiflow.com](http://asciiflow.com/)
* [连接跟踪（conntrack）：原理、应用及 Linux 内核实现](http://arthurchiao.art/blog/conntrack-design-and-implementation-zh/)

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

**集线器，交换机和网桥之间的主要区别在于：集线器工作在`OSI`模型的第`1`层，而网桥和交换机工作在第`2`层（使用MAC地址）。集线器在所有端口上广播传入的流量，而网桥和交换机仅将流量路由到目的端口（交换机上的端口）**

## 5.1 什么是Hub

集线器为每个设备提供专用的物理连接，这有助于减少一台计算机发生故障将导致所有计算机失去连接的可能性。但是，由于集线器仍是共享带宽的设备，因此连接仅限于半双工。冲突仍然是一个问题，因此集线器无助于提高网络性能

集线器本质上是多端口中继器。他们忽略了以太网帧的内容，只是简单地从集线器的每个接口中重新发送收到的每个帧。挑战在于，以太网帧将显示在连接到集线器的每个设备上，而不仅是预期的目的地（安全漏洞），而且入站帧通常会与出站帧发生冲突（性能问题）

## 5.2 什么是Bridge

在现实世界中，桥梁连接着河流或铁轨两侧的道路。**在技术领域，网桥连接两个物理网段**。每个网桥都跟踪连接到其每个接口的网络上的MAC地址。当网络流量到达网桥并且其目标地址在网桥的那一侧是本地的时，网桥会过滤该以太网帧，因此它仅停留在网桥的本地

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

# 6 虚拟机的网络模式

## 6.1 Network Address Translation (NAT)

在NAT模式下，当一个VM操作系统启动时，它通常通过发送一个`DHCP Request`来获取一个`IP`地址。`VirtualBox`将会处理这个`DHCP Request`，然后返回一个`DHCP Response`给VM，这个`DHCP Response`包含了一个`IP`地址以及网关地址，其中网关地址用于路由`Outbound connections`

在这种模式下，每一个VM被分配到的都是一个相同的IP（`10.0.2.15`），因为每一个VM都认为他们处于一个隔离的网络中，也就是说不同的VM之间无法感知到对方的存在

当VM通过网关（`10.0.2.2`）发送流量时，`VirtualBox`会重写数据包，使其看起来好像来自主机，而不是来自VM（在主机内运行）

逻辑上，网络看起来像下面这样

![vm_nat](/images/Linux-Network/vm_nat.png)

总结一下，NAT包含如下特征

1. VM处于一个私有的局域网
1. `VirtualBox`扮演着`DHCP`服务器的角色
1. `VirtualBox Engine`起到转换地址的作用
1. 适用于当VM作为Client的场景，因此不是适用于VM作为Server的场景
1. VM可以访问外界网络，而外界网络无法访问VM

## 6.2 Bridged Networking

当您希望您的VM成为完整的网络公民，即与网络上的主机相同时，使用`Bridged Networking`；在此模式下，虚拟NIC“桥接”到主机上的物理网卡

这样做的结果是每个VM都可以像访问主机一样访问物理网络。它可以像访问主机一样访问网络上的任何服务，例如外部DHCP服务，名称查找服务和路由信息

逻辑上，网络看起来像下面这样

![vm_bridge](/images/Linux-Network/vm_bridge.png)

总结一下，`Bridged Networking`网络包含如下特征

1. `VirtualBox`桥接到主机网络
1. 会消耗IP地址
1. 适用于Client VM或Server VM

## 6.3 Internal Networking

`Internal Networking`网络（在本例中为“intnet”）是一个完全隔离的网络，因此非常“安静”。当您需要一个单独的，干净的网络时，这适用于测试，您可以使用VM创建复杂的内部网络，为内部网络提供自己的服务。（例如Active Directory，DHCP等）。**请注意，即使主机也不是内部网络的成员**，但即使主机未连接到网络（例如，在平面上），此模式也允许VM运行

逻辑上，网络看起来像下面这样

![vm_internel](/images/Linux-Network/vm_internel.png)

请注意，在此模式下，`VirtualBox`不提供`DHCP`等“便利”服务，因此必须静态配置您的计算机，或者VM需要提供`DHCP`/名称服务

总结一下，`Internal Networking`网络包含如下特征

1. 不同VM之间处于同一个私有网络
1. VM无法访问外部网络
1. 宿主机断网时，VM也能正常工作（本来就不需要外网）

## 6.4 Host-only Networking

坐在这个“vboxnet0”网络上的所有VM都会看到对方，此外，主机也可以看到这些VM。但是，其他外部计算机无法在此网络上看到VM，因此名称为“Host-only”

逻辑上，网络看起来像下面这样

![vm_host_only](/images/Linux-Network/vm_host_only.png)

这看起来非常类似于`Internal Networking`，但主机现在位于“vboxnet0”并且可以提供`DHCP`服务

总结一下，`Host-only Networking`网络包含如下特征

1. `VirtualBox`为VM以及宿主机创建了一个私有网络
1. `VirtualBox`提供DHCP服务
1. VM无法看到外部网络
1. 宿主机断网时，VM也能正常工作（本来就不需要外网）

## 6.5 Port-Forwarding with NAT Networking

如果您在笔记本电脑上购买移动演示或开发环境并且您有一台或多台VM需要其他机器连接，该怎么办？而且你不断地跳到不同的VM网络上。在这样的场景下

1. NAT：无法满足，因为外部机器无法连接到VM上
1. Bridged：可以满足，但是会消耗IP资源，且VM网络环境随着外部网络环境的改变而改变
1. Internal：无法满足，因为外部机器无法连接到VM上
1. Host-only：无法满足，因为外部机器无法连接到VM上

当外部机器连接到宿主机的“host:port”时，`VirtualBox`会将连接`forward`到VM的“guest:port”上

逻辑上，网络看起来像下面这样（forward并没有在这张图体现出来，所以这幅图与NAT很像）

![vm_nat_forwarding](/images/Linux-Network/vm_nat_forwarding.png)

## 6.6 参考

* [Oracle VM VirtualBox: Networking options and how-to manage them](https://blogs.oracle.com/scoter/networking-in-virtualbox-v2)
* [Chapter 6. Virtual networking](https://www.virtualbox.org/manual/ch06.html#network_bridged)
* [VMware虚拟机三种网络模式详解](https://www.linuxidc.com/Linux/2016-09/135521.htm)

# 7 配网

## 7.1 配置文件

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

* **`BOOTPROTO`**：可选项有`static`或`dhcp`
* **`DEFROUTE`**：是否生成default路由，注意，一台机器只能有一个网卡可以设置默认路由，否则即便有多个默认路由，第二个默认路由也是无效的
* **`IPADDR`**：ip地址
* **`NETMASK`**：子网掩码
* **`GATEWAY`**：网关ip
* **`ONBOOT`**：是否开机启动
* **`DNS1/DNS2/.../DNSx`**：dns配置

## 7.2 network-manager

`NetworkManager`是Linux下管理网络的一个服务，此外还有另一个服务`network`（这个服务已经过时，且与`NetworkManager`存在冲突

`NetworkManager`服务提供了两个客户端用于网络配置，分别是`nmcli`以及`nmtui`

### 7.2.1 设计

在`NetworkManager`的设计中，存在两种概念，一个是网卡设备`device`，另一个是连接`conn`，一个`device`可以对应多个`conn`，但是这个多个`conn`中只有一个是开启状态。如何控制`conn`的启动优先级呢？可以通过设置`connection.autoconnect-priority`

### 7.2.2 nmcli

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

# 添加网络配置
nmcli conn add con-name <conn name> type <net type> ifname <if name> -- ipv4.address <ip/netmask>

# 修改某个配置值
nmcli conn modify <id>/<uuid>/<path> ipv4.address <ip/netmask>

# 启用/停用conn
nmcli conn up <id>/<uuid>/<path>
nmcli conn down <id>/<uuid>/<path>
```

**重要配置项**

1. `ipv4.never-default`：`1`表示永远不设置为默认路由，`0`反之
    * `nmcli conn modify eno1 ipv4.never-defaul 1`：连接`eno1`永远不设置默认路由
1. `connection.autoconnect-priority`：当一个网卡设备，包含多个`conn`时，且`connection.autoconnect`的值都是`1`（即默认开启）时，可以通过设置该值来改变`conn`的优先级，优先级高的`conn`将会生效

### 7.2.3 nmtui

带有图形化界面的配网工具

### 7.2.4 配置文件

路径：`/etc/NetworkManager/NetworkManager.conf`

配置文件详细内容参考[NetworkManager.conf](https://developer.gnome.org/NetworkManager/stable/NetworkManager.conf.html)

### 7.2.5 网卡配置文件

**`CentOS`**

* 与`network`共用同一套配置文件，目录是：`/etc/sysconfig/network-scripts/`
* 文件名：`ifcfg-<conn name>`

**`ubuntu`**

* 目录是：`/etc/NetworkManager/system-connections`
* 文件名：以`<conn name>`作为文件名

## 7.3 netplan

`Ubuntu`从17.10版本之后，开始用`netplan`进行网络配置。取代了之前的`ifup/down`命令和`/etc/network/interfaces`配置文件

**`netplan`相关文件路径**：

* `/etc/netplan/*.yaml`。一个简单的示例如下：
	```yaml
	network:
    ethernets:
        enp0s3:
            addresses: []
            dhcp4: true
            optional: true
    ethernets:
        enp0s8:
            addresses: []
            dhcp4: true
            optional: true
    version: 2
	```

## 7.4 参考

* [NetworkManager官方文档](https://wiki.archlinux.org/index.php/NetworkManager)
* [为 Red Hat Enterprise Linux 7 配置和管理联网](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/networking_guide/index)
* [Networking Guide](https://docs.fedoraproject.org/en-US/Fedora/25/html/Networking_Guide/index.html)
* [Connecting to a Network Using nmcli](https://docs.fedoraproject.org/en-US/Fedora/25/html/Networking_Guide/sec-Connecting_to_a_Network_Using_nmcli.html)
* [Linux DNS 查询剖析（第三部分）](https://zhuanlan.zhihu.com/p/43556975)
* [一台主机上只能保持最多 65535 个 TCP 连接吗？](https://www.zhihu.com/question/361111920/answer/1861488526)
* [Ubuntu20.04网络配置](https://www.360blogs.top/ubuntu20-04-netplan/)