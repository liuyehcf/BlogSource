---
title: Linux-重要特性
date: 2019-10-13 16:56:57
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 namespace

该部分转载自[DOCKER基础技术：LINUX NAMESPACE（上）](https://coolshell.cn/articles/17010.html)、[DOCKER基础技术：LINUX NAMESPACE（下）](https://coolshell.cn/articles/17029.html)、[Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/container-creation-using-namespaces-and-bash-6g)

## 1.1 UTS

__UTS(UNIX Time-sharing System) Namespace：用于隔离hostname与domain__

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    printf("Container(uts) - inside the container!\n");
    sethostname("container",10); /* 设置hostname */
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent - start a container!\n");
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | SIGCHLD, NULL); /*启用CLONE_NEWUTS Namespace隔离 */
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

## 1.2 IPC

__IPC(Inter-Process Communication) Namespace：用于隔离进程间的通信方式，例如共享内存、信号量、消息队列等__

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    printf("Container(ipc) - inside the container!\n");
    sethostname("container",10); /* 设置hostname */
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent - start a container!\n");
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWIPC | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

## 1.3 PID

__PID Namespace：用于隔离进程的PID__

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    /* 查看子进程的PID，我们可以看到其输出子进程的 pid 为 1 */
    printf("Container(pid) [%5d] - inside the container!\n", getpid());
    sethostname("container",10);
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent [%5d] - start a container!\n", getpid());
    /*启用PID namespace - CLONE_NEWPID*/
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWPID | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

## 1.4 Mount

__Mount Namespace：用于隔离文件系统__

```c
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

/* 定义一个给 clone 用的栈，栈大小1M */
#define STACK_SIZE (1024 * 1024)
static char container_stack[STACK_SIZE];

char* const container_args[] = {
    "/bin/bash",
    NULL
};

int container_main(void* arg)
{
    printf("Container(mnt) [%5d] - inside the container!\n", getpid());
    sethostname("container",10);
    /* 重新mount proc文件系统到 /proc下 */
    system("mount -t proc proc /proc");
    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    printf("Parent [%5d] - start a container!\n", getpid());
    /* 启用Mount Namespace - 增加CLONE_NEWNS参数 */
    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWPID | CLONE_NEWNS | SIGCHLD, NULL);
    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

__小插曲：`mount -t proc proc /proc`如何解释__

* `-t`参数后跟文件系统类型，这里指`proc`
* 第二个`proc`是设备名
* 第三个`/proc`是挂载目录
* __对于proc文件系统来说，它没有设备，具体的内核代码如下，传什么设备名称都无所谓，因此好的实践是`mount -t proc nodev /proc`__

相关内核源码
```c
static struct dentry *proc_mount(struct file_system_type *fs_type, int flags, const char *dev_name, void *data)
{
    struct pid_namespace *ns;

    if (flags & MS_KERNMOUNT) {
        ns = data;
        data = NULL;
    } else {
        ns = task_active_pid_ns(current);
    }

    return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super);
}
```

## 1.5 User

__User Namespace：用于隔离user以及group__

```c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/mount.h>
#include <sys/capability.h>
#include <stdio.h>
#include <sched.h>
#include <signal.h>
#include <unistd.h>

#define STACK_SIZE (1024 * 1024)

static char container_stack[STACK_SIZE];
char* const container_args[] = {
    "/bin/bash",
    NULL
};

int pipefd[2];

void set_map(char* file, int inside_id, int outside_id, int len) {
    printf("file: '%s'\n", file);
    FILE* mapfd = fopen(file, "w");
    if (NULL == mapfd) {
        perror("open file error");
        return;
    }
    fprintf(mapfd, "%d %d %d", inside_id, outside_id, len);
    fclose(mapfd);
}

void set_uid_map(pid_t pid, int inside_id, int outside_id, int len) {
    char file[256];
    sprintf(file, "/proc/%d/uid_map", pid);
    set_map(file, inside_id, outside_id, len);
}

void set_gid_map(pid_t pid, int inside_id, int outside_id, int len) {
    char file[256];
    sprintf(file, "/proc/%d/gid_map", pid);
    set_map(file, inside_id, outside_id, len);
}

int container_main(void* arg)
{

    printf("Container(user) [%5d] - inside the container!\n", getpid());

    printf("Container: eUID = %ld;  eGID = %ld, UID=%ld, GID=%ld\n",
            (long) geteuid(), (long) getegid(), (long) getuid(), (long) getgid());

    /* 等待父进程通知后再往下执行（进程间的同步） */
    char ch;
    close(pipefd[1]);
    read(pipefd[0], &ch, 1);

    printf("Container [%5d] - setup hostname!\n", getpid());
    //set hostname
    sethostname("container",10);

    //remount "/proc" to make sure the "top" and "ps" show container's information
    mount("proc", "/proc", "proc", 0, NULL);

    execv(container_args[0], container_args);
    printf("Something's wrong!\n");
    return 1;
}

int main()
{
    const int gid=getgid(), uid=getuid();

    printf("Parent: eUID = %ld;  eGID = %ld, UID=%ld, GID=%ld\n",
            (long) geteuid(), (long) getegid(), (long) getuid(), (long) getgid());

    pipe(pipefd);

    printf("Parent [%5d] - start a container!\n", getpid());

    int container_pid = clone(container_main, container_stack+STACK_SIZE,
            CLONE_NEWUTS | CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUSER | SIGCHLD, NULL);

    printf("Parent [%5d] - Container [%5d]!\n", getpid(), container_pid);

    //To map the uid/gid,
    //   we need edit the /proc/PID/uid_map (or /proc/PID/gid_map) in parent
    //The file format is
    //   ID-inside-ns   ID-outside-ns   length
    //if no mapping,
    //   the uid will be taken from /proc/sys/kernel/overflowuid
    //   the gid will be taken from /proc/sys/kernel/overflowgid
    set_uid_map(container_pid, 0, uid, 1);
    set_gid_map(container_pid, 0, gid, 1);

    printf("Parent [%5d] - user/group mapping done!\n", getpid());

    /* 通知子进程 */
    close(pipefd[1]);

    waitpid(container_pid, NULL, 0);
    printf("Parent - container stopped!\n");
    return 0;
}
```

__小插曲__：笔者用的是centos7，该功能默认是关闭的，通过下面的方式可以打开

```sh
# 该命令输出0，代表该功能尚未开启
cat /proc/sys/user/max_user_namespaces

# 打开该功能
echo 10000 > /proc/sys/user/max_user_namespaces

# 其他类似的限制也在该目录中 /proc/sys/user，分别是

cat /proc/sys/user/max_uts_namespaces
cat /proc/sys/user/max_ipc_namespaces
cat /proc/sys/user/max_pid_namespaces
cat /proc/sys/user/max_mnt_namespaces
cat /proc/sys/user/max_user_namespaces
cat /proc/sys/user/max_net_namespaces
```

## 1.6 Network

__Network Namespace：用于隔离网络__

### 1.6.1 无网桥

__编写一个脚本，内容如下，这里我取名为`netns_without_bridge.sh`__

```sh
#!/bin/bash

export namespace=liuye

export ifname_outside_ns=veth1
export ifname_inside_ns=veth2
export ifname_external=enp0s3

export ip_outside_ns=192.168.45.2
export ip_inside_ns=192.168.45.3

export ip_net=192.168.45.0
export ip_netmask=255.255.255.0

function setup(){
	echo "1/10: 创建名为 '${namespace}' 的网络命名空间"
	ip netns add ${namespace}

	echo "2/10: 创建一对 'veth' 类型的网卡设备，一个网卡为 '${ifname_outside_ns}'，另一个网卡为 '${ifname_inside_ns}'"
	ip link add ${ifname_outside_ns} type veth peer name ${ifname_inside_ns}

	echo "3/10: 配置网卡 '${ifname_outside_ns}' 的IP地址 '${ip_outside_ns}'"
	ifconfig ${ifname_outside_ns} ${ip_outside_ns} netmask ${ip_netmask} up

    echo "4/10: 将网卡 '${ifname_inside_ns}' 加入网络命名空间 '${namespace}' 中"
	ip link set ${ifname_inside_ns} netns ${namespace}

	echo "5/10: 将在网络命名空间 '${namespace}' 中的网卡 '${ifname_inside_ns}' 的IP地址设置为 '${ip_inside_ns}'，它需要和网卡 '${ifname_outside_ns}' 的IP地址在同一个网段上"
	ip netns exec ${namespace} ifconfig ${ifname_inside_ns} ${ip_inside_ns} netmask ${ip_netmask} up

	echo "6/10: 将网络命名空间 '${namespace}' 中的默认路由设置为网卡 '${ifname_outside_ns}' 的IP地址 '${ip_outside_ns}'"
	ip netns exec ${namespace} route add default gw ${ip_outside_ns}

	echo "7/10: 配置SNAT，将从网络命名空间 '${namespace}' 中发出的网络包的源IP地址替换为网卡 '${ifname_external}' 的IP地址"
	iptables -t nat -A POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	echo "8/10: 在默认的 'FORWARD' 策略为 'DROP' 时，显式地允许网卡 '${ifname_outside_ns}' 和网卡 '${ifname_external}' 之间的进行数据包转发"
	iptables -t filter -A FORWARD -i ${ifname_external} -o ${ifname_outside_ns} -j ACCEPT
	iptables -t filter -A FORWARD -i ${ifname_outside_ns} -o ${ifname_external} -j ACCEPT

    echo "9/10: 开启内核转发功能"
	echo 1 > /proc/sys/net/ipv4/ip_forward

    echo "10/10: 为网络命名空间 '${namespace}' 配置DNS服务，用于域名解析"
	mkdir -p /etc/netns/${namespace}
	echo "nameserver 8.8.8.8" > /etc/netns/${namespace}/resolv.conf
}

function cleanup(){
	echo "1/4: 删除 'FORWARD' 规则"
	iptables -t filter -D FORWARD -i ${ifname_external} -o ${ifname_outside_ns} -j ACCEPT
        iptables -t filter -D FORWARD -i ${ifname_outside_ns} -o ${ifname_external} -j ACCEPT

	echo "2/4: 删除 'NAT'"
	iptables -t nat -D POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	echo "3/4: 删除网卡设备 '${ifname_outside_ns}' 以及 '${ifname_inside_ns}'"
	ip link delete ${ifname_outside_ns}
	
	echo "4/4: 删除网络命名空间 '${namespace}'"
	ip netns delete ${namespace}
    rm -rf /etc/netns/${namespace}
}

export -f setup
export -f cleanup
```

__下面进行测试__

```sh
# 执行脚本，将函数以及环境变量导出
[root@liuyehcf ~]$ source netns_without_bridge.sh

# 配置
[root@liuyehcf ~]$ setup
#-------------------------output-------------------------
1/10: 创建名为 'liuye' 的网络命名空间
2/10: 创建一对 'veth' 类型的网卡设备，一个网卡为 'veth1'，另一个网卡为 'veth2'
3/10: 配置网卡 'veth1' 的IP地址 '192.168.45.2'
4/10: 将网卡 'veth2' 加入网络命名空间 'liuye' 中
5/10: 将在网络命名空间 'liuye' 中的网卡 'veth2' 的IP地址设置为 '192.168.45.3'，它需要和网卡 'veth1' 的IP地址在同一个网段上
6/10: 将网络命名空间 'liuye' 中的默认路由设置为网卡 'veth1' 的IP地址 '192.168.45.2'
7/10: 配置SNAT，将从网络命名空间 'liuye' 中发出的网络包的源IP地址替换为网卡 'enp0s3' 的IP地址
8/10: 在默认的 'FORWARD' 策略为 'DROP' 时，显式地允许网卡 'veth1' 和网卡 'enp0s3' 之间的进行数据包转发
9/10: 开启内核转发功能
10/10: 为网络命名空间 'liuye' 配置DNS服务，用于域名解析
#-------------------------output-------------------------

# 测试网络连通性
[root@liuyehcf ~]$ ip netns exec liuye ping -c 3 www.aliyun.com
#-------------------------output-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.163) 56(84) bytes of data.
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=1 ttl=32 time=74.8 ms
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=2 ttl=32 time=73.1 ms
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=3 ttl=32 time=73.4 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2095ms
rtt min/avg/max/mdev = 73.125/73.818/74.841/0.802 ms
#-------------------------output-------------------------

# 清理
[root@liuyehcf ~]$ cleanup
#-------------------------output-------------------------
1/4: 删除 'FORWARD' 规则
2/4: 删除 'NAT'
3/4: 删除网卡设备 'veth1' 以及 'veth2'
4/4: 删除网络命名空间 'liuye'
#-------------------------output-------------------------
```

### 1.6.2 有网桥

__编写一个脚本，内容如下，这里我取名为`netns_with_bridge.sh`__

```sh
#!/bin/bash

export namespace=liuye

export ifname_outside_ns=veth1
export ifname_inside_ns=veth2
export ifname_external=enp0s3

export ip_outside_ns=192.168.45.2
export ip_inside_ns=192.168.45.3

export ip_net=192.168.45.0
export ip_netmask=255.255.255.0

export bridge_name=demobridge

function setup(){
	echo "1/13: 创建网桥 '${bridge_name}'"
	brctl addbr ${bridge_name}
	brctl stp ${bridge_name} off

	echo "2/13: 配置网桥 '${bridge_name}' 的IP '${ip_outside_ns}'"
	ifconfig ${bridge_name} ${ip_outside_ns} netmask ${ip_netmask} up

	echo "3/13: 创建名为 '${namespace}' 的网络命名空间"
	ip netns add ${namespace}

	echo "4/13: 创建一对 'veth' 类型的网卡设备，一个网卡为 '${ifname_outside_ns}'，另一个网卡为 '${ifname_inside_ns}'"
	ip link add ${ifname_outside_ns} type veth peer name ${ifname_inside_ns}

	echo "5/13: 开启网卡 '${ifname_outside_ns}'"
	ip link set ${ifname_outside_ns} up

	echo "6/13: 将网卡 '${ifname_outside_ns}' 绑定到网桥 '${bridge_name}' 上"
        brctl addif ${bridge_name} ${ifname_outside_ns}
	
	echo "7/13: 将网卡 '${ifname_inside_ns}' 加入网络命名空间 '${namespace}' 中"
	ip link set ${ifname_inside_ns} netns ${namespace}

	echo "8/13: 将在网络命名空间 '${namespace}' 中的网卡 '${ifname_inside_ns}' 的IP地址设置为 '${ip_inside_ns}'，它需要和网卡 '${ifname_outside_ns}' 的IP地址在同一个网段上"
	ip netns exec ${namespace} ifconfig ${ifname_inside_ns} ${ip_inside_ns} netmask ${ip_netmask} up

	echo "9/13: 将网络命名空间 '${namespace}' 中的默认路由设置为网卡 '${ifname_outside_ns}' 的IP地址 '${ip_outside_ns}'"
	ip netns exec ${namespace} route add default gw ${ip_outside_ns}

	echo "10/13: 配置SNAT，将从网络命名空间 '${namespace}' 中发出的网络包的源IP地址替换为网卡 '${ifname_external}' 的IP地址"
	iptables -t nat -A POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	echo "11/13: 在默认的 'FORWARD' 策略为 'DROP' 时，显式地允许网桥 '${bridge_name}' 和网卡 '${ifname_external}' 之间的进行数据包转发"
	iptables -t filter -A FORWARD -i ${ifname_external} -o ${bridge_name} -j ACCEPT
	iptables -t filter -A FORWARD -i ${bridge_name} -o ${ifname_external} -j ACCEPT
	
	echo "12/13: 开启内核转发功能"
	echo 1 > /proc/sys/net/ipv4/ip_forward

	echo "13/13: 为网络命名空间 '${namespace}' 配置DNS服务，用于域名解析"
	mkdir -p /etc/netns/${namespace}
	echo "nameserver 8.8.8.8" > /etc/netns/${namespace}/resolv.conf
}

function cleanup(){
	echo "1/6: 删除 'FORWARD' 规则"
	iptables -t filter -D FORWARD -i ${ifname_external} -o ${bridge_name} -j ACCEPT
        iptables -t filter -D FORWARD -i ${bridge_name} -o ${ifname_external} -j ACCEPT

	echo "2/6: 删除 'NAT'"
	iptables -t nat -D POSTROUTING -s ${ip_net}/${ip_netmask} -o ${ifname_external} -j MASQUERADE

	echo "3/6: 删除网卡设备 '${ifname_outside_ns}' 以及 '${ifname_inside_ns}'"
	ip link delete ${ifname_outside_ns}
	
	echo "4/6: 删除网络命名空间 '${namespace}'"
	ip netns delete ${namespace}
	rm -rf /etc/netns/${namespace}

	echo "5/6: 关闭网桥 '${bridge_name}'"
	ifconfig ${bridge_name} down

	echo "6/6: 删除网桥 '${bridge_name}'"
	brctl delbr ${bridge_name}
}

export -f setup
export -f cleanup
```

__下面进行测试__

```sh
# 执行脚本，将函数以及环境变量导出
[root@liuyehcf ~]$ source netns_with_bridge.sh

# 配置
[root@liuyehcf ~]$ setup
#-------------------------output-------------------------
1/13: 创建网桥 'demobridge'
2/13: 配置网桥 'demobridge' 的IP '192.168.45.2'
3/13: 创建名为 'liuye' 的网络命名空间
4/13: 创建一对 'veth' 类型的网卡设备，一个网卡为 'veth1'，另一个网卡为 'veth2'
5/13: 开启网卡 'veth1'
6/13: 将网卡 'veth1' 绑定到网桥 'demobridge' 上
7/13: 将网卡 'veth2' 加入网络命名空间 'liuye' 中
8/13: 将在网络命名空间 'liuye' 中的网卡 'veth2' 的IP地址设置为 '192.168.45.3'，它需要和网卡 'veth1' 的IP地址在同一个网段上
9/13: 将网络命名空间 'liuye' 中的默认路由设置为网卡 'veth1' 的IP地址 '192.168.45.2'
10/13: 配置SNAT，将从网络命名空间 'liuye' 中发出的网络包的源IP地址替换为网卡 'enp0s3' 的IP地址
11/13: 在默认的 'FORWARD' 策略为 'DROP' 时，显式地允许网桥 'demobridge' 和网卡 'enp0s3' 之间的进行数据包转发
12/13: 开启内核转发功能
13/13: 为网络命名空间 'liuye' 配置DNS服务，用于域名解析
#-------------------------output-------------------------

# 测试网络连通性
[root@liuyehcf ~]$ ip netns exec liuye ping -c 3 www.aliyun.com
#-------------------------output-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.173) 56(84) bytes of data.
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=1 ttl=32 time=74.8 ms
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=2 ttl=32 time=73.1 ms
64 bytes from 47.88.251.173 (47.88.251.173): icmp_seq=3 ttl=32 time=74.3 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 73.192/74.111/74.808/0.747 ms
#-------------------------output-------------------------

# 清理
[root@liuyehcf ~]$ cleanup
#-------------------------output-------------------------
1/6: 删除 'FORWARD' 规则
2/6: 删除 'NAT'
3/6: 删除网卡设备 'veth1' 以及 'veth2'
4/6: 删除网络命名空间 'liuye'
5/6: 关闭网桥 'demobridge'
6/6: 删除网桥 'demobridge'
#-------------------------output-------------------------
```

## 1.7 实现简易容器

该部分转载自[Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/)

### 1.7.1 术语解释

__Container__：容器是一组技术的集合，包括`namespace`、`cgroup`，在本小结，我们关注的重点是`namespace`

__Namespace__：包含六种namespace，包括`PID`、`User`、`Net`、`Mnt`、`Uts`、`Ipc`

__Btrfs__：Btrfs是一种采用`Copy On Write`模式的高效、易用的文件系统

### 1.7.2 准备工作

1. 我们需要安装docker（安装docker即可）
    * 需要使用docker导出某个镜像
    * 使用docker自带的网桥
1. 我们需要一个btrfs文件系统，挂载于/btrfs，下面会介绍如何创建（需要安装btrfs命令）

### 1.7.3 详细步骤

#### 1.7.3.1 创建disk image

```sh
# 用dd命令创建一个2GB的空image（就是个文件）
#   if：输入文件/设备，这里指定的是 /dev/zero ，因此输入的是一连串的0
#   of：输出文件/设备，这里指定的是 disk.img
#   bs：block的大小
#   count：block的数量，4194304 = (2 * 1024 * 1024 * 1024 / 512)
[root@liuyehcf ~]$ dd if=/dev/zero of=disk.img bs=512 count=4194304
#-------------------------output-------------------------
记录了4194304+0 的读入
记录了4194304+0 的写出
2147483648字节(2.1 GB)已复制，14.8679 秒，144 MB/秒
#-------------------------output-------------------------
```

#### 1.7.3.2 格式化disk image

```sh
# 利用 mkfs.btrfs 命令，将一个文件格式化成 btrfs 文件系统
[root@liuyehcf ~]$ mkfs.btrfs disk.img
#-------------------------output-------------------------
btrfs-progs v4.9.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               02290d5d-7492-4b19-ab80-48ed5c58cb90
Node size:          16384
Sector size:        4096
Filesystem size:    2.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP             102.38MiB
  System:           DUP               8.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1     2.00GiB  disk.img
#-------------------------output-------------------------
```

#### 1.7.3.3 挂载disk image

```sh
# 将disk.img对应的文件系统挂载到/btrfs目录下
[root@liuyehcf ~]$ mkdir /btrfs
[root@liuyehcf ~]$ mount -t btrfs disk.img /btrfs
```

#### 1.7.3.4 让挂载不可见

```sh
# 让接下来的步骤中容器执行的挂载操作对于外界不可见
#   --make-rprivate：会递归得让所有子目录中的挂载点对外界不可见
[root@liuyehcf ~]$ mount --make-rprivate /
```

#### 1.7.3.5 创建容器镜像

```sh
# 进入文件系统
[root@liuyehcf ~]$ cd /btrfs

# 在 images 目录创建一个 subvolume
[root@liuyehcf btrfs]$ mkdir images containers
[root@liuyehcf btrfs]$ btrfs subvol create images/alpine
#-------------------------output-------------------------
Create subvolume 'images/alpine'
#-------------------------output-------------------------

# docker run 启动一个容器
#   -d：退到容器之外，并打印container id
#   alpine:3.10.2：镜像
#   true：容器执行的命令
[root@liuyehcf btrfs]$ CID=$(docker run -d alpine:3.10.2 true)
[root@liuyehcf btrfs]$ echo $CID
#-------------------------output-------------------------
f9d2df08221a67653fe6af9f99dbb2367a6736aecbba8c5403bf3dbb68310f2a
#-------------------------output-------------------------

# 将容器对应的镜像导出到 images/alpine/ 目录中
[root@liuyehcf btrfs]$ docker export $CID | tar -C images/alpine/ -xf-
[root@liuyehcf btrfs]$ ls images/alpine/
#-------------------------output-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------output-------------------------

# 以 images/alpine/ 为源，制作快照 containers/tupperware
[root@liuyehcf btrfs]$ btrfs subvol snapshot images/alpine/ containers/tupperware
#-------------------------output-------------------------
Create a snapshot of 'images/alpine/' in 'containers/tupperware'
#-------------------------output-------------------------

# 在快照中创建一个文件
[root@liuyehcf btrfs]$ touch containers/tupperware/NICK_WAS_HERE

# 在快照路径中ls，发现存在文件 NICK_WAS_HERE
[root@liuyehcf btrfs]$ ls containers/tupperware/
#-------------------------output-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------output-------------------------

# 在源路径中ls，发现不存在文件 NICK_WAS_HERE
[root@liuyehcf btrfs]$ ls images/alpine/
#-------------------------output-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------output-------------------------
```

#### 1.7.3.6 使用chroot测试

```sh
# 将 containers/tupperware/  作为 /root，并执行/root/bin/sh（这里root就是指change之后的root）
[root@liuyehcf btrfs]$ chroot containers/tupperware/ /bin/sh

# 配置环境变量，否则找不到命令
/ $ export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

/ $ ls
#-------------------------output-------------------------
NICK_WAS_HERE  dev            home           media          opt            root           sbin           sys            usr
bin            etc            lib            mnt            proc           run            srv            tmp            var
#-------------------------output-------------------------

exit
```

#### 1.7.3.7 使用命名空间

```sh
# 以6种隔离维度执行bash命令
[root@liuyehcf btrfs]$ unshare --mount --uts --ipc --net --pid --fork /bin/bash

# 更换hostname
[root@liuyehcf btrfs]$ hostname tupperware

# 使得hostname生效，注意这个命令不会生成一个新的bash，与直接执行bash有区别
[root@liuyehcf btrfs]$ exec bash

# 查看进程，发现进程号并不是1开始
[root@tupperware btrfs]$ ps
#-------------------------output-------------------------
  PID TTY          TIME CMD
 1583 pts/0    00:00:00 bash
 2204 pts/0    00:00:00 unshare
 2205 pts/0    00:00:00 bash
 2281 pts/0    00:00:00 ps
#-------------------------output-------------------------
```

#### 1.7.3.8 挂载proc

```sh
# 挂载proc
[root@tupperware btrfs]$ mount -t proc nodev /proc

# 再次查看进程，发现进程号从1开始
[root@tupperware btrfs]$ ps
#-------------------------output-------------------------
  PID TTY          TIME CMD
    1 pts/0    00:00:00 bash
   25 pts/0    00:00:00 ps
#-------------------------output-------------------------

# 暂且先取消挂载
[root@tupperware btrfs]$ umount /proc
```

#### 1.7.3.9 交换根文件系统(pivot root)

```sh
# 接下来，利用 mount 命令以及 pivot_root 命令把 /btrfs/containers/tupperware 作为文件系统的根目录
# 创建目录oldroot，之后会将当前的根文件系统挂载到 oldroot 上
[root@tupperware btrfs]$ mkdir /btrfs/containers/tupperware/oldroot
# mount --bind 将目录挂载到目录上
[root@tupperware btrfs]$ mount --bind /btrfs/containers/tupperware /btrfs

# 进入到 /btrfs 目录中，看下是否已将容器挂载到该目录下
[root@tupperware btrfs]$ cd /btrfs/
[root@tupperware btrfs]$ ls
#-------------------------output-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  oldroot  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------output-------------------------

# 利用 pivot_root 交换两个文件系统的挂载点
# 执行完毕之后，旧的文件系统（宿主机的根文件系统）的挂载点就是oldroot，新的文件系统（容器）的挂载点是/
[root@tupperware btrfs]$ pivot_root . oldroot

# 由于根文件系统已经切换了，需要重新配下环境变量，否则找不到命令
[root@tupperware btrfs]$ export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

[root@tupperware btrfs]$ cd /

# 查看当前的根目录，其实就是容器
[root@tupperware /]$ ls
#-------------------------output-------------------------
NICK_WAS_HERE  dev            home           media          oldroot        proc           run            srv            tmp            var
bin            etc            lib            mnt            opt            root           sbin           sys            usr
#-------------------------output-------------------------

# 查看原始的根目录，之前的根文件系统挂载到了 oldroot
[root@tupperware /]$ ls oldroot/
#-------------------------output-------------------------
bin       boot      btrfs     dev       disk.img  etc       home      lib       lib64     media     mnt       opt       proc      root      run       sbin      srv       sys       tmp       usr       var
#-------------------------output-------------------------
```

#### 1.7.3.10 整理挂载点

```sh

# 必须先挂载proc，因为mount命令依赖proc
[root@tupperware /]$ mount -t proc nodev /proc

# 查看当前挂载点，可以发现存在非常多的挂载点，这些挂载点不应该对容器可见
[root@tupperware /]$ mount | head
#-------------------------output-------------------------
/dev/mapper/centos-root on /oldroot type xfs (rw,seclabel,relatime,attr2,inode64,noquota)
devtmpfs on /oldroot/dev type devtmpfs (rw,seclabel,nosuid,size=929308k,nr_inodes=232327,mode=755)
tmpfs on /oldroot/dev/shm type tmpfs (rw,seclabel,nosuid,nodev)
devpts on /oldroot/dev/pts type devpts (rw,seclabel,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
hugetlbfs on /oldroot/dev/hugepages type hugetlbfs (rw,seclabel,relatime)
mqueue on /oldroot/dev/mqueue type mqueue (rw,seclabel,relatime)
proc on /oldroot/proc type proc (rw,nosuid,nodev,noexec,relatime)
systemd-1 on /oldroot/proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=34,pgrp=0,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=8897)
sysfs on /oldroot/sys type sysfs (rw,seclabel,nosuid,nodev,noexec,relatime)
#-------------------------output-------------------------

[root@tupperware /]$ umount -a
#-------------------------output-------------------------
umount: can't unmount /oldroot/btrfs: Resource busy
umount: can't unmount /oldroot: Resource busy
#-------------------------output-------------------------

# 继续挂载proc，因为mount依赖proc
[root@tupperware /]$ mount -t proc nodev /proc

# 在上一步 umount -a 中，由于/oldroot未被卸载掉，因此这里仍然可以看到
[root@tupperware /]$ mount
#-------------------------output-------------------------
/dev/mapper/centos-root on /oldroot type xfs (rw,seclabel,relatime,attr2,inode64,noquota)
/dev/loop0 on /oldroot/btrfs type btrfs (ro,seclabel,relatime,space_cache,subvolid=5,subvol=/)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------output-------------------------

# 卸载 /oldroot
#   -l：like将文件系统从挂载点detach出来，当它不繁忙时，再进行剩余清理工作
[root@tupperware /]$ umount -l /oldroot

# 至此，挂载点整理完毕
[root@tupperware /]$ mount
#-------------------------output-------------------------
rootfs on / type rootfs (rw)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------output-------------------------
```

#### 1.7.3.11 网络命名空间

__以下命令，在容器终端执行（unshare创建的容器终端）__

```sh
[root@tupperware /]$ ping 8.8.8.8
#-------------------------output-------------------------
PING 8.8.8.8 (8.8.8.8): 56 data bytes
ping: sendto: Network unreachable
#-------------------------output-------------------------

[root@tupperware /]$ ifconfig -a
#-------------------------output-------------------------
lo        Link encap:Local Loopback
          LOOPBACK  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
#-------------------------output-------------------------
```

__以下命令，在另一个终端执行（非上述unshare创建的容器终端）__

```sh

[root@liuyehcf ~]$ CPID=$(pidof unshare)
[root@liuyehcf ~]$ echo $CPID
#-------------------------output-------------------------
2204
#-------------------------output-------------------------

# 创建一对网卡设备，名字分别为 h2204 以及 c2204
[root@liuyehcf ~]$ ip link add name h$CPID type veth peer name c$CPID

# 将网卡 c2204 放入容器网络的命名空间中，网络命名空间就是容器的pid，即2204
[root@liuyehcf ~]$ ip link set c$CPID netns $CPID
```

__以下命令，在容器终端执行（unshare创建的容器终端）__

```sh
[root@tupperware /]$ ifconfig -a
#-------------------------output-------------------------
c2204     Link encap:Ethernet  HWaddr 32:35:C2:08:CF:D6
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          LOOPBACK  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
#-------------------------output-------------------------
```

__以下命令，在另一个终端执行（非上述unshare创建的容器终端）__

```sh
# 利用 ip link set 将网卡 c2204 关联到网桥 docker0
[root@liuyehcf ~]$ ip link set h$CPID master docker0 up
[root@liuyehcf ~]$ ifconfig docker0
#-------------------------output-------------------------
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        inet6 fe80::42:e3ff:feda:6184  prefixlen 64  scopeid 0x20<link>
        ether 02:42:e3:da:61:84  txqueuelen 0  (Ethernet)
        RX packets 2  bytes 152 (152.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3  bytes 258 (258.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
#-------------------------output-------------------------
```

__以下命令，在容器终端执行（unshare创建的容器终端）__

```sh
# 开启loopback网卡
[root@tupperware /]$ ip link set lo up

# 将网卡 c2204 重命名为eth0，并将其打开
[root@tupperware /]$ ip link set c2204 name eth0 up

# 给网卡eth0分配ip，要注意，该ip必须与网桥 docker0 位于同一网段
[root@tupperware /]$ ip addr add 172.17.42.3/16 dev eth0

# 将网桥 docker0 设为默认路由
[root@tupperware /]$ ip route add default via 172.17.0.1

# 查看网卡设备
[root@tupperware /]$ ifconfig
#-------------------------output-------------------------
eth0      Link encap:Ethernet  HWaddr 32:35:C2:08:CF:D6
          inet addr:172.17.42.3  Bcast:0.0.0.0  Mask:255.255.0.0
          inet6 addr: fe80::3035:c2ff:fe08:cfd6/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:8 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:648 (648.0 B)  TX bytes:648 (648.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
#-------------------------output-------------------------

[root@tupperware /]$ ping -c 3 8.8.8.8
#-------------------------output-------------------------
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=49 time=30.481 ms
64 bytes from 8.8.8.8: seq=1 ttl=49 time=31.170 ms
64 bytes from 8.8.8.8: seq=2 ttl=49 time=30.111 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 30.111/30.587/31.170 ms
#-------------------------output-------------------------
```

### 1.7.4 清理

```sh
# 退出容器终端
[root@tupperware /]$ exit
#-------------------------output-------------------------
exit
#-------------------------output-------------------------

[root@liuyehcf btrfs]$ cd /
[root@liuyehcf /]$ umount /btrfs
[root@liuyehcf /]$ rm -f disk.img
[root@liuyehcf /]$ rmdir /btrfs/
```

## 1.8 参考

* [DOCKER基础技术：LINUX NAMESPACE（上）](https://coolshell.cn/articles/17010.html)
* [DOCKER基础技术：LINUX NAMESPACE（下）](https://coolshell.cn/articles/17029.html)
* [Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/container-creation-using-namespaces-and-bash-6g)
* [Netruon 理解（12）：使用 Linux bridge 将 Linux network namespace 连接外网](https://www.bbsmax.com/A/VGzl4XYzbq/)

# 2 cgroup

__2种cgroup驱动__

1. `system cgroup driver`
1. `cgroupfs cgroup driver`

__容器中常用的cgroup__

1. `cpu cpuset cpuacct`
1. `memory`
1. `device`：控制可以在容器中看到的设备
1. `freezer`：在停止容器的时候使用，冻结容器内所有进程，防止进程逃逸到宿主机？？？
1. `blkio`：限制容器用到的磁盘的iops、vps速率限制
1. `pid`：容器可以用到的最大进程数量

__查看当前系统可用的cgroup__

* `mount -t cgroup`

## 2.1 参考

* [DOCKER基础技术：LINUX CGROUP](https://coolshell.cn/articles/17049.html)
* [资​​​源​​​管​​​理​​​指​​​南​​​-RedHat](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/6/html-single/resource_management_guide/index#ch-Subsystems_and_Tunable_Parameters)
* [clone-manpage](http://man7.org/linux/man-pages/man2/clone.2.html)
* [Linux资源管理之cgroups简介](https://tech.meituan.com/2015/03/31/cgroups.html)
* [Docker 背后的内核知识——cgroups 资源限制](https://www.infoq.cn/article/docker-kernel-knowledge-cgroups-resource-isolation/)

# 3 Systemd

本小结转载自[Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

## 3.1 概述

历史上，Linux的启动一直采用`init`进程，这种方法有两个缺点

1. 一是启动时间长。`init`进程是串行启动，只有前一个进程启动完，才会启动下一个进程
1. 二是启动脚本复杂。`init`进程只是执行启动脚本，不管其他事情。脚本需要自己处理各种情况，这往往使得脚本变得很长

__`Systemd`就是为了解决这些问题而诞生的。它的设计目标是，为系统的启动和管理提供一套完整的解决方案__

## 3.2 Unit

`Systemd`可以管理所有系统资源。不同的资源统称为`Unit`（单位），`Unit`一共分成12种

1. __`Service unit`：系统服务__
1. `Target unit`：多个 Unit 构成的一个组
    * 启动计算机的时候，需要启动大量的`Unit`。如果每一次启动，都要一一写明本次启动需要哪些`Unit`，显然非常不方便。`Systemd`的解决方案就是`Target`
    * 简单说，`Target`就是一个`Unit`组，包含许多相关的`Unit`。启动某个`Target`的时候，`Systemd`就会启动里面所有的 `Unit`。从这个意义上说，`Target`这个概念类似于“状态点”，启动某个`Target`就好比启动到某种状态
    * 传统的`init`启动模式里面，有`RunLevel`的概念，跟`Target`的作用很类似。不同的是，`RunLevel`是互斥的，不可能多个 `RunLevel`同时启动，但是多个`Target`可以同时启动。
1. `Device Unit`：硬件设备
1. `Mount Unit`：文件系统的挂载点
1. `Automount Unit`：自动挂载点
1. `Path Unit`：文件或路径
1. `Scope Unit`：不是由 Systemd 启动的外部进程
1. `Slice Unit`：进程组
1. `Snapshot Unit`：Systemd 快照，可以切回某个快照
1. `Socket Unit`：进程间通信的 socket
1. `Swap Unit`：swap 文件
1. `Timer Unit`：定时器

每一个`Unit`都有一个配置文件，告诉`Systemd`怎么启动这个`Unit`。__`Systemd`默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/usr/lib/systemd/system/`，真正的配置文件存放在那个目录__。`systemctl enable`命令用于在上面两个目录之间，建立符号链接关系。与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。配置文件的后缀名，就是该`Unit`的种类。如果省略，__`Systemd`默认后缀名为`.service`__

```sh
systemctl enable demo-service.service
# 等同于
ln -s '/usr/lib/systemd/system/demo-service.service' '/etc/systemd/system/multi-user.target.wants/demo-service.service'
```

`systemctl list-unit-files`这个命令会输出一个列表，这个列表显示每个配置文件的状态，一共有四种

1. `enabled`：已建立启动链接
1. `disabled`：没建立启动链接
1. `static`：该配置文件没有`[Install]`部分（无法执行），只能作为其他配置文件的依赖
1. `masked`：该配置文件被禁止建立启动链接
* __注意，从配置文件的状态无法看出，该`Unit`是否正在运行。若要查看`Unit`的运行状态，需要使用`systemctl status`命令__

## 3.3 文件格式

__`systemctl cat`可以查看配置文件的内容，例如`systemctl cat sshd.service`__

一般来说，一个`Unit`的格式如下

```
[Unit]
...

[Service]
...

[Install]
...
```

__`[Unit]`区块通常是配置文件的第一个区块，用来定义`Unit`的元数据，以及配置与其他`Unit`的关系。它的主要字段如下__

* `Description`：简短描述
* `Documentation`：文档地址
* `Requires`：当前`Unit`依赖的其他`Unit`，如果它们没有运行，当前`Unit`会启动失败
* `Wants`：与当前`Unit`配合的其他`Unit`，如果它们没有运行，当前`Unit`不会启动失败
* `BindsTo`：与`Requires`类似，它指定的`Unit`如果退出，会导致当前`Unit`停止运行
* `Before`：如果该字段指定的`Unit`也要启动，那么必须在当前`Unit`之后启动
* `After`：如果该字段指定的`Unit`也要启动，那么必须在当前`Unit`之前启动
* `Conflicts`：这里指定的`Unit`不能与当前`Unit`同时运行
* `Condition...`：当前`Unit`运行必须满足的条件，否则不会运行
* `Assert...`：当前`Unit`运行必须满足的条件，否则会报启动失败

__`[Service]`区块用来`Service`的配置，只有`Service`类型的`Unit`才有这个区块。它的主要字段如下__

* `Type`：定义启动时的进程行为。它有以下几种值。
    * `simple`：默认值，执行`ExecStart`指定的命令，启动主进程
    * `forking`：以`fork`方式从父进程创建子进程，创建后父进程会立即退出
    * `oneshot`：一次性进程，`Systemd`会等当前服务退出，再继续往下执行
    * `dbus`：当前服务通过`D-Bus`启动
    * `notify`：当前服务启动完毕，会通知`Systemd`，再继续往下执行
    * `idle`：若有其他任务执行完毕，当前服务才会运行
* `ExecStart`：启动当前服务的命令
* `ExecStartPre`：启动当前服务之前执行的命令
* `ExecStartPost`：启动当前服务之后执行的命令
* `ExecReload`：重启当前服务时执行的命令
* `ExecStop`：停止当前服务时执行的命令
* `ExecStopPost`：停止当其服务之后执行的命令
* `RestartSec`：自动重启当前服务间隔的秒数
* `Restart`：定义何种情况`Systemd`会自动重启当前服务，可能的值包括
    * `always`：总是重启
    * `on-success`
    * `on-failure`
    * `on-abnormal`
    * `on-abort`
    * `on-watchdog`
* `TimeoutSec`：定义`Systemd`停止当前服务之前等待的秒数
* `Environment`：指定环境变量

完整的配置项清单参考[systemd.unit — Unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)

## 3.4 命令行工具

__systemctl命令行工具__

* `systemctl start xxx.service`：启动xxx服务
* `systemctl stop xxx.service`：停止xxx服务
* `systemctl enable xxx.service`：允许xxx服务开机自启动
* `systemctl disable xxx.service`：进制xxx服务开机自启动
* `systemctl status xxx.service`：查看xxx服务的状态
* `systemctl restart xxx.service`：重新启动xxx服务
* `systemctl reload xxx.service`：让xxx服务重新加载配置文件（如果有的话）
* `systemctl list-units --type=service`：列出所有的服务
* `systemctl daemon-reload`：重新加载`systemd`的配置文件，当我们修改了`/usr/lib/systemd/system/`目录下的文件时，我们需要使用这个命令来使修改生效

__journalctl命令行工具__

* `journalctl -u xxx.service`：查看xxx服务的日志

## 3.5 demo

__下面写了一个非常简单的程序（文件名为`demo-service.c`）：接受并处理`1`、`2`、`15`三种信号__

1. `SIGHUP(1)`：打印日志，模拟加载配置文件
1. `SIGINT(2)`：打印日志，以错误码1结束进程
1. `SIGTERM(15)`：打印日志，以错误码0结束进程

```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <signal.h>

void sigHandler(int);
FILE *fp = NULL;

int main() {
    // 打开日志文件
    fp = fopen("/root/default.log", "a+");
    if (fp < 0) {
        exit(1);
    }

    // kill -l 查看每个signal的含义
    signal(1, sigHandler);
    signal(2, sigHandler);
    signal(15, sigHandler);

    // dead loop
    while (1) {
        sleep(1);
    }
}

void sigHandler(int signum) {
    fprintf(fp, "捕获信号 %d, ", signum);
    fflush(fp);

    switch (signum) {
        case 1:
            fprintf(fp, "重新加载配置文件\n");
            fflush(fp);
            break;
        case 2:
            fprintf(fp, "中断进程\n");
            fflush(fp);
            exit(1);
        case 15:
            fprintf(fp, "退出进程\n");
            fflush(fp);
            exit(0);
        default:
            fprintf(fp, "忽略该信号\n");
            fflush(fp);
    }
}
```

__接下来将它注册到systemd中__

文件路径：`/usr/lib/systemd/system/demo-service.service`

```
[Unit]
Description=Systemd Demo Service
Documentation=https://liuyehcf.github.io/2019/10/13/Linux-%E9%87%8D%E8%A6%81%E7%89%B9%E6%80%A7/

[Service]
Type=simple
ExecStart=/root/demo-service
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
Restart=always
RestartSec=3
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

__测试__

```sh
# 编译
[root@localhost ~]$ gcc -o demo-service demo-service.c

# 启动demo-service
[root@localhost ~]$ systemctl start demo-service.service

# 查看demo-service的运行状态
[root@localhost ~]$ systemctl status demo-service.service
#-------------------------output-------------------------
● demo-service.service - Systemd Demo Service
   Loaded: loaded (/usr/lib/systemd/system/demo-service.service; enabled; vendor preset: disabled)
   Active: active (running) since 日 2019-11-24 03:21:52 EST; 46s ago
     Docs: https://liuyehcf.github.io/2019/10/13/Linux-%E9%87%8D%E8%A6%81%E7%89%B9%E6%80%A7/
  Process: 3368 ExecStop=/bin/kill -s QUIT $MAINPID (code=exited, status=0/SUCCESS)
 Main PID: 3392 (demo-service)
   CGroup: /system.slice/demo-service.service
           └─3392 /root/demo-service

11月 24 03:21:52 localhost.localdomain systemd[1]: Started Systemd Demo Service.
#-------------------------output-------------------------

# 重新加载配置文件（发送 SIGHUP 信号）
[root@localhost ~]$ systemctl reload demo-service.service
# 查看日志文件
[root@localhost ~]$ cat /root/default.log
#-------------------------output-------------------------
捕获信号 1, 重新加载配置文件
#-------------------------output-------------------------

# 停止服务
[root@localhost ~]$ systemctl stop demo-service.service
#-------------------------output-------------------------
捕获信号 1, 重新加载配置文件
捕获信号 15, 退出进程
#-------------------------output-------------------------
```

## 3.6 参考

* [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
* [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
* [最简明扼要的 Systemd 教程，只需十分钟](https://blog.csdn.net/weixin_37766296/article/details/80192633)
* [systemd添加自定义系统服务设置自定义开机启动](https://www.cnblogs.com/wjb10000/p/5566801.html)
* [systemd创建自定义服务(Ubuntu)](https://www.cnblogs.com/wintersoft/p/9937839.html)
* [Use systemd to Start a Linux Service at Boot](https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/)
