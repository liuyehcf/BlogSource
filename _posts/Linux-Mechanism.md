---
title: Linux-Mechanism
date: 2019-10-13 16:56:57
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 namespace

该部分转载自[DOCKER基础技术：LINUX NAMESPACE（上）](https://coolshell.cn/articles/17010.html)、[DOCKER基础技术：LINUX NAMESPACE（下）](https://coolshell.cn/articles/17029.html)、[Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/container-creation-using-namespaces-and-bash-6g)

## 1.1 UTS

**UTS(UNIX Time-sharing System) Namespace：用于隔离hostname与domain**

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

**IPC(Inter-Process Communication) Namespace：用于隔离进程间的通信方式，例如共享内存、信号量、消息队列等**

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

**PID Namespace：用于隔离进程的PID**

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

**Mount Namespace：用于隔离文件系统**

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

**小插曲：`mount -t proc proc /proc`如何解释**

* `-t`参数后跟文件系统类型，这里指`proc`
* 第二个`proc`是设备名
* 第三个`/proc`是挂载目录
* **对于proc文件系统来说，它没有设备，具体的内核代码如下，传什么设备名称都无所谓，因此好的实践是`mount -t proc nodev /proc`**

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

**User Namespace：用于隔离user以及group**

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

**小插曲**：笔者用的是centos7，该功能默认是关闭的，通过下面的方式可以打开

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

**Network Namespace：用于隔离网络**

### 1.6.1 Without Bridge

**编写一个脚本，内容如下，这里我取名为`netns_without_bridge.sh`**

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

**下面进行测试**

```sh
# 执行脚本，将函数以及环境变量导出
source netns_without_bridge.sh

# 配置
setup
#-------------------------↓↓↓↓↓↓-------------------------
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
#-------------------------↑↑↑↑↑↑-------------------------

# 测试网络连通性
ip netns exec liuye ping -c 3 www.aliyun.com
#-------------------------↓↓↓↓↓↓-------------------------
PING xjp-adns.aliyun.com.gds.alibabadns.com (47.88.251.163) 56(84) bytes of data.
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=1 ttl=32 time=74.8 ms
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=2 ttl=32 time=73.1 ms
64 bytes from 47.88.251.163 (47.88.251.163): icmp_seq=3 ttl=32 time=73.4 ms

--- xjp-adns.aliyun.com.gds.alibabadns.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2095ms
rtt min/avg/max/mdev = 73.125/73.818/74.841/0.802 ms
#-------------------------↑↑↑↑↑↑-------------------------

# 清理
cleanup
#-------------------------↓↓↓↓↓↓-------------------------
1/4: 删除 'FORWARD' 规则
2/4: 删除 'NAT'
3/4: 删除网卡设备 'veth1' 以及 'veth2'
4/4: 删除网络命名空间 'liuye'
#-------------------------↑↑↑↑↑↑-------------------------
```

### 1.6.2 With Bridge

**编写一个脚本，内容如下，这里我取名为`netns_with_bridge.sh`**

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

**下面进行测试**

```sh
# 执行脚本，将函数以及环境变量导出
source netns_with_bridge.sh

# 配置
setup
#-------------------------↓↓↓↓↓↓-------------------------
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
#-------------------------↑↑↑↑↑↑-------------------------

# 测试网络连通性
ip netns exec liuye ping -c 3 www.aliyun.com
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
1/6: 删除 'FORWARD' 规则
2/6: 删除 'NAT'
3/6: 删除网卡设备 'veth1' 以及 'veth2'
4/6: 删除网络命名空间 'liuye'
5/6: 关闭网桥 'demobridge'
6/6: 删除网桥 'demobridge'
#-------------------------↑↑↑↑↑↑-------------------------
```

## 1.7 Implement Docker

该部分转载自[Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/)

### 1.7.1 Terms

**Container**：容器是一组技术的集合，包括`namespace`、`cgroup`，在本小节，我们关注的重点是`namespace`

**Namespace**：包含六种namespace，包括`PID`、`User`、`Net`、`Mnt`、`Uts`、`Ipc`

**Btrfs**：Btrfs是一种采用`Copy On Write`模式的高效、易用的文件系统

### 1.7.2 Preparation

1. 我们需要安装docker（安装docker即可）
    * 需要使用docker导出某个镜像
    * 使用docker自带的网桥
1. 我们需要一个btrfs文件系统，挂载于/btrfs，下面会介绍如何创建（需要安装btrfs命令）

### 1.7.3 Detail Steps

#### 1.7.3.1 Create Disk Image

```sh
# 用dd命令创建一个2GB的空image（就是个文件）
#   if：输入文件/设备，这里指定的是 /dev/zero ，因此输入的是一连串的0
#   of：输出文件/设备，这里指定的是 disk.img
#   bs：block的大小
#   count：block的数量，4194304 = (2 * 1024 * 1024 * 1024 / 512)
dd if=/dev/zero of=disk.img bs=512 count=4194304
#-------------------------↓↓↓↓↓↓-------------------------
记录了4194304+0 的读入
记录了4194304+0 的写出
2147483648字节(2.1 GB)已复制，14.8679 秒，144 MB/秒
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.2 Format Disk Image

```sh
# 利用 mkfs.btrfs 命令，将一个文件格式化成 btrfs 文件系统
mkfs.btrfs disk.img
#-------------------------↓↓↓↓↓↓-------------------------
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
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.3 Mount Disk Image

```sh
# 将disk.img对应的文件系统挂载到/btrfs目录下
mkdir /btrfs
mount -t btrfs disk.img /btrfs
```

#### 1.7.3.4 Invisible Image

```sh
# 让接下来的步骤中容器执行的挂载操作对于外界不可见
#   --make-rprivate：会递归得让所有子目录中的挂载点对外界不可见
mount --make-rprivate /
```

#### 1.7.3.5 Create Container Image

```sh
# 进入文件系统
cd /btrfs

# 在 images 目录创建一个 subvolume
mkdir images containers
btrfs subvol create images/alpine
#-------------------------↓↓↓↓↓↓-------------------------
Create subvolume 'images/alpine'
#-------------------------↑↑↑↑↑↑-------------------------

# docker run 启动一个容器
#   -d：退到容器之外，并打印container id
#   alpine:3.10.2：镜像
#   true：容器执行的命令
CID=$(docker run -d alpine:3.10.2 true)
echo $CID
#-------------------------↓↓↓↓↓↓-------------------------
f9d2df08221a67653fe6af9f99dbb2367a6736aecbba8c5403bf3dbb68310f2a
#-------------------------↑↑↑↑↑↑-------------------------

# 将容器对应的镜像导出到 images/alpine/ 目录中
docker export $CID | tar -C images/alpine/ -xf-
ls images/alpine/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 以 images/alpine/ 为源，制作快照 containers/tupperware
btrfs subvol snapshot images/alpine/ containers/tupperware
#-------------------------↓↓↓↓↓↓-------------------------
Create a snapshot of 'images/alpine/' in 'containers/tupperware'
#-------------------------↑↑↑↑↑↑-------------------------

# 在快照中创建一个文件
touch containers/tupperware/NICK_WAS_HERE

# 在快照路径中ls，发现存在文件 NICK_WAS_HERE
ls containers/tupperware/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 在源路径中ls，发现不存在文件 NICK_WAS_HERE
ls images/alpine/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.6 Test with chroot

```sh
# 将 containers/tupperware/  作为 /root，并执行/root/bin/sh（这里root就是指change之后的root）
chroot containers/tupperware/ /bin/sh

# 配置环境变量，否则找不到命令
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

ls
#-------------------------↓↓↓↓↓↓-------------------------
NICK_WAS_HERE  dev            home           media          opt            root           sbin           sys            usr
bin            etc            lib            mnt            proc           run            srv            tmp            var
#-------------------------↑↑↑↑↑↑-------------------------

exit
```

#### 1.7.3.7 Use namespace

```sh
# 以6种隔离维度执行bash命令
unshare --mount --uts --ipc --net --pid --fork /bin/bash

# 更换hostname
hostname tupperware

# 使得hostname生效，注意这个命令不会生成一个新的bash，与直接执行bash有区别
exec bash

# 查看进程，发现进程号并不是1开始
ps
#-------------------------↓↓↓↓↓↓-------------------------
  PID TTY          TIME CMD
 1583 pts/0    00:00:00 bash
 2204 pts/0    00:00:00 unshare
 2205 pts/0    00:00:00 bash
 2281 pts/0    00:00:00 ps
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.8 Mount proc

```sh
# 挂载proc
mount -t proc nodev /proc

# 再次查看进程，发现进程号从1开始
ps
#-------------------------↓↓↓↓↓↓-------------------------
  PID TTY          TIME CMD
    1 pts/0    00:00:00 bash
   25 pts/0    00:00:00 ps
#-------------------------↑↑↑↑↑↑-------------------------

# 暂且先取消挂载
umount /proc
```

#### 1.7.3.9 Pivot root

```sh
# 接下来，利用 mount 命令以及 pivot_root 命令把 /btrfs/containers/tupperware 作为文件系统的根目录
# 创建目录oldroot，之后会将当前的根文件系统挂载到 oldroot 上
mkdir /btrfs/containers/tupperware/oldroot
# mount --bind 将目录挂载到目录上
mount --bind /btrfs/containers/tupperware /btrfs

# 进入到 /btrfs 目录中，看下是否已将容器挂载到该目录下
cd /btrfs/
ls
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  oldroot  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 利用 pivot_root 交换两个文件系统的挂载点
# 执行完毕之后，旧的文件系统（宿主机的根文件系统）的挂载点就是oldroot，新的文件系统（容器）的挂载点是/
pivot_root . oldroot

# 由于根文件系统已经切换了，需要重新配下环境变量，否则找不到命令
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

cd /

# 查看当前的根目录，其实就是容器
ls
#-------------------------↓↓↓↓↓↓-------------------------
NICK_WAS_HERE  dev            home           media          oldroot        proc           run            srv            tmp            var
bin            etc            lib            mnt            opt            root           sbin           sys            usr
#-------------------------↑↑↑↑↑↑-------------------------

# 查看原始的根目录，之前的根文件系统挂载到了 oldroot
ls oldroot/
#-------------------------↓↓↓↓↓↓-------------------------
bin       boot      btrfs     dev       disk.img  etc       home      lib       lib64     media     mnt       opt       proc      root      run       sbin      srv       sys       tmp       usr       var
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.10 Mountpoints

```sh

# 必须先挂载proc，因为mount命令依赖proc
mount -t proc nodev /proc

# 查看当前挂载点，可以发现存在非常多的挂载点，这些挂载点不应该对容器可见
mount | head
#-------------------------↓↓↓↓↓↓-------------------------
/dev/mapper/centos-root on /oldroot type xfs (rw,seclabel,relatime,attr2,inode64,noquota)
devtmpfs on /oldroot/dev type devtmpfs (rw,seclabel,nosuid,size=929308k,nr_inodes=232327,mode=755)
tmpfs on /oldroot/dev/shm type tmpfs (rw,seclabel,nosuid,nodev)
devpts on /oldroot/dev/pts type devpts (rw,seclabel,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
hugetlbfs on /oldroot/dev/hugepages type hugetlbfs (rw,seclabel,relatime)
mqueue on /oldroot/dev/mqueue type mqueue (rw,seclabel,relatime)
proc on /oldroot/proc type proc (rw,nosuid,nodev,noexec,relatime)
systemd-1 on /oldroot/proc/sys/fs/binfmt_misc type autofs (rw,relatime,fd=34,pgrp=0,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=8897)
sysfs on /oldroot/sys type sysfs (rw,seclabel,nosuid,nodev,noexec,relatime)
#-------------------------↑↑↑↑↑↑-------------------------

umount -a
#-------------------------↓↓↓↓↓↓-------------------------
umount: can't unmount /oldroot/btrfs: Resource busy
umount: can't unmount /oldroot: Resource busy
#-------------------------↑↑↑↑↑↑-------------------------

# 继续挂载proc，因为mount依赖proc
mount -t proc nodev /proc

# 在上一步 umount -a 中，由于/oldroot未被卸载掉，因此这里仍然可以看到
mount
#-------------------------↓↓↓↓↓↓-------------------------
/dev/mapper/centos-root on /oldroot type xfs (rw,seclabel,relatime,attr2,inode64,noquota)
/dev/loop0 on /oldroot/btrfs type btrfs (ro,seclabel,relatime,space_cache,subvolid=5,subvol=/)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------↑↑↑↑↑↑-------------------------

# 卸载 /oldroot
#   -l：like将文件系统从挂载点detach出来，当它不繁忙时，再进行剩余清理工作
umount -l /oldroot

# 至此，挂载点整理完毕
mount
#-------------------------↓↓↓↓↓↓-------------------------
rootfs on / type rootfs (rw)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.11 Network Namespace

**以下命令，在容器终端执行（unshare创建的容器终端）**

```sh
ping 8.8.8.8
#-------------------------↓↓↓↓↓↓-------------------------
PING 8.8.8.8 (8.8.8.8): 56 data bytes
ping: sendto: Network unreachable
#-------------------------↑↑↑↑↑↑-------------------------

ifconfig -a
#-------------------------↓↓↓↓↓↓-------------------------
lo        Link encap:Local Loopback
          LOOPBACK  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
#-------------------------↑↑↑↑↑↑-------------------------
```

**以下命令，在另一个终端执行（非上述unshare创建的容器终端）**

```sh

CPID=$(pidof unshare)
echo $CPID
#-------------------------↓↓↓↓↓↓-------------------------
2204
#-------------------------↑↑↑↑↑↑-------------------------

# 创建一对网卡设备，名字分别为 h2204 以及 c2204
ip link add name h$CPID type veth peer name c$CPID

# 将网卡 c2204 放入容器网络的命名空间中，网络命名空间就是容器的pid，即2204
ip link set c$CPID netns $CPID
```

**以下命令，在容器终端执行（unshare创建的容器终端）**

```sh
ifconfig -a
#-------------------------↓↓↓↓↓↓-------------------------
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
#-------------------------↑↑↑↑↑↑-------------------------
```

**以下命令，在另一个终端执行（非上述unshare创建的容器终端）**

```sh
# 利用 ip link set 将网卡 c2204 关联到网桥 docker0
ip link set h$CPID master docker0 up
ifconfig docker0
#-------------------------↓↓↓↓↓↓-------------------------
docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 0.0.0.0
        inet6 fe80::42:e3ff:feda:6184  prefixlen 64  scopeid 0x20<link>
        ether 02:42:e3:da:61:84  txqueuelen 0  (Ethernet)
        RX packets 2  bytes 152 (152.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3  bytes 258 (258.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
#-------------------------↑↑↑↑↑↑-------------------------
```

**以下命令，在容器终端执行（unshare创建的容器终端）**

```sh
# 开启loopback网卡
ip link set lo up

# 将网卡 c2204 重命名为eth0，并将其打开
ip link set c2204 name eth0 up

# 给网卡eth0分配ip，要注意，该ip必须与网桥 docker0 位于同一网段
ip addr add 172.17.42.3/16 dev eth0

# 将网桥 docker0 设为默认路由
ip route add default via 172.17.0.1

# 查看网卡设备
ifconfig
#-------------------------↓↓↓↓↓↓-------------------------
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
#-------------------------↑↑↑↑↑↑-------------------------

ping -c 3 8.8.8.8
#-------------------------↓↓↓↓↓↓-------------------------
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: seq=0 ttl=49 time=30.481 ms
64 bytes from 8.8.8.8: seq=1 ttl=49 time=31.170 ms
64 bytes from 8.8.8.8: seq=2 ttl=49 time=30.111 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 30.111/30.587/31.170 ms
#-------------------------↑↑↑↑↑↑-------------------------
```

### 1.7.4 Clean Up

```sh
# 退出容器终端
exit
#-------------------------↓↓↓↓↓↓-------------------------
exit
#-------------------------↑↑↑↑↑↑-------------------------

cd /
umount /btrfs
rm -f disk.img
rmdir /btrfs/
```

## 1.8 Reference

* [DOCKER基础技术：LINUX NAMESPACE（上）](https://coolshell.cn/articles/17010.html)
* [DOCKER基础技术：LINUX NAMESPACE（下）](https://coolshell.cn/articles/17029.html)
* [Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/container-creation-using-namespaces-and-bash-6g)
* [Netruon 理解（12）：使用 Linux bridge 将 Linux network namespace 连接外网](https://www.bbsmax.com/A/VGzl4XYzbq/)

# 2 cgroup

**`cgroup`, similar to `namespace`, also groups processes, but its purpose differs from `namespace`. `namespace` is meant to isolate resources between process groups (each process has an isolated resource view), while `cgroup` is for unified resource monitoring and limitation for a group of processes.**

## 2.1 hierarchy

**A `hierarchy` can be understood as a `cgroup` tree, where each `node` in the tree represents a `process group`, and each tree is associated with zero or more `subsystems`.** Within a single tree, all processes in the Linux system are included, but each process can belong to only one node (process group). There can be many `cgroup` trees in the system, each associated with different `subsystems`. A process can belong to multiple trees, meaning a process can belong to multiple process groups, but these process groups are associated with different `subsystems`. Currently, Linux supports 12 types of `subsystems`, and if we exclude cases where no `subsystem` is associated (such as `systemd`), Linux can have a maximum of 12 `cgroup` trees, each associated with one `subsystem`. Of course, it is also possible to create only one tree and associate it with all `subsystems`. When a `cgroup` tree is not associated with any `subsystem`, it means that this tree only groups processes, and what to do with these groups is left up to the application itself. `systemd` is an example of this kind of usage.

## 2.2 Subsystem

**A `subsystem` is a kernel module that, once associated with a `cgroup` tree, performs specific actions on each node (process group) in the tree.** `Subsystems` are often called `resource controllers` because they are mainly used to allocate or limit the resources of each process group. However, this term is not entirely accurate, as sometimes we group processes simply for monitoring purposes, such as the `perf_event subsystem`. So far, Linux supports 12 types of `subsystems`, for example, limiting CPU usage time, limiting memory usage, tracking CPU usage, freezing and resuming a group of processes, and so on. These subsystems will be introduced one by one later.

**The following are the 12 `cgroup` subsystems**

1. `blkio`: Limits `cgroup` block device `IO` speeds
1. **`cpu`: Used to limit `cgroup` CPU usage**
1. `cpuacct`: Tracks `cgroup` CPU usage
1. `cpuset`: Binds `cgroup` to specified `CPUs` and `NUMA` nodes
1. `devices`: Limits `cgroup` permissions for creating (via `mknod`) and accessing devices
1. `freezer`: `suspend` and `restore` all processes in a `cgroup`
1. `hugetlb`: Limits `cgroup` use of huge pages
1. **`memory`: Tracks and limits `cgroup` memory usage, including `process memory`, `kernel memory`, and `swap`**
1. `net_cls`: Tags all network packets created by processes in a `cgroup` with a `classid` for use with `tc` and `iptables`. Only affects outgoing packets, not incoming ones
1. `net_prio`: Sets `cgroup` access priority for each network interface
1. `perf_event`: Monitors the performance of a `cgroup`
1. **`pids`: Limits the total number of processes within a `cgroup` and its descendant `cgroups`**

**You can check the subsystems supported by the system by running `cat /proc/cgroups` or `mount -t cgroup`.**

### 2.2.1 CPU Subsystem

The `cpu` subsystem can control the amount of CPU access for `cgroups`. The following two schedulers can be used to manage access to CPU resources:

* Completely Fair Scheduler (CFS): A proportional allocation scheduler that distributes CPU time (CPU bandwidth) among `cgroups` proportionally based on task priority/weight or the share assigned to each `cgroup`.
* Real-Time Scheduler (RT): A task scheduler that limits the CPU usage time for real-time tasks.

**We can control the upper limit of CPU usage through the parameters `cpu.cfs_period_us` and `cpu.cfs_quota_us`.**

1. `cpu.cfs_period_us`: This parameter, in microseconds, defines the bandwidth (duration) of the CPU scheduling period.
1. `cpu.cfs_quota_us`: This parameter, also in microseconds, defines the CPU bandwidth that can be used within one CPU scheduling period.

**The ratio of `cpu.cfs_quota_us` to `cpu.cfs_period_us` represents the CPU usage ratio (it can be greater than 1, indicating the number of cores used in a multi-core machine). However, while maintaining the same ratio, the actual behavior of processes can also be affected by the value of `cpu.cfs_period_us`.**

* If `cpu.cfs_period_us` is very large, for example, `1s`, and the usage ratio is 20%, the process behavior may be full-load operation for the first `0.2s` and blocking for the following `0.8s`, resulting in a stronger sense of stalling.
* If `cpu.cfs_period_us` is very small, for example, `10ms`, and the usage ratio is 20%, the process behavior might be full-load operation for the first `2ms` and blocking for the next `8ms`, giving a weaker sense of stalling and a relatively smoother experience.

**Verification:**

```sh
# Terminal A
cat > test_cpu_subsystem.c << 'EOF'
#include <stdio.h>
void main()
{
    long cnt = 0;

    while(1) {
        printf("cnt=%d\n", cnt++);
    }
}
EOF

gcc -o test_cpu_subsystem test_cpu_subsystem.c

# Terminal A: Run program
./test_cpu_subsystem

# Terminal B: Create a new node (directory) in the hierarchy structure of the CPU subsystem
mkdir /sys/fs/cgroup/cpu/test_cpu_subsystem

# Set `cpu.cfs_period_us` to 1s and `cpu.cfs_quota_us` to 0.2s, giving a ratio of 20%
echo 1000000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_period_us
echo 200000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_quota_us
pgrep -f test_cpu_subsystem > /sys/fs/cgroup/cpu/test_cpu_subsystem/tasks
# At this point, you can observe in Terminal A that there is a noticeable stuttering in the output rate. It runs for 0.2s, pauses for 0.8s, and then repeats this cycle.

# Set `cpu.cfs_period_us` to 10ms and `cpu.cfs_quota_us` to 2ms, with the same ratio of 20%
echo 10000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_period_us
echo 2000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_quota_us
# Now, you can observe in Terminal A that the output is much smoother.

# Terminal B: Stop the process and delete the test `cgroup` node
pkill -f test_cpu_subsystem
cgdelete cpu:test_cpu_subsystem
```

**We can use the parameters `cpu.rt_period_us` and `cpu.rt_runtime_us` to set CPU limits for specific tasks.**

* `cpu.rt_period_us`: This parameter, in microseconds, defines the period for reallocation of CPU resources within a `cgroup` over a specified time frame.
* `cpu.rt_runtime_us`: This parameter, in microseconds, defines the maximum continuous CPU access time for tasks within a `cgroup` during a specified period (this limit is established to prevent tasks within one `cgroup` from monopolizing CPU time).

**`cpu.stat` records CPU time statistics**

* `nr_periods`: The number of CPU scheduling periods that have passed.
* `nr_throttled`: The number of times tasks in the `cgroup` have been throttled (prevented from running after exhausting all quota time).
* `throttled_time`: The total time tasks in the `cgroup` have been throttled.

**If we want to control the relative CPU time ratio between two `cgroups`, we can use `cpu.shares`. For example, if the first `cgroup` is set to 200 and the second to 100, then the former can access twice the CPU time of the latter.**

**When a process is added to a `cgroup`'s task list, any threads created by that process will automatically belong to this `cgroup`. In other words, previously created threads do not automatically belong to this `cgroup`!!!**

## 2.3 Kernel Implementation

![cgroup_struct](/images/Linux-Mechanism/cgroup_struct.png)

The diagram above describes the relationship between processes and `cgroups` in terms of overall structure. The `P` at the bottom represents a process. In each process descriptor, there is a pointer to an auxiliary data structure called `css_set` (`cgroups subsystem set`). Processes pointing to a specific `css_set` are added to the process list of that `css_set`. A process can only belong to one `css_set`, while a `css_set` can contain multiple processes. Processes within the same `css_set` are subject to the resource limits associated with that `css_set`.

The `M×N Linkage` in the diagram illustrates that `css_set` can be associated with nodes in the hierarchy structure through an auxiliary data structure in a many-to-many relationship. However, `cgroup` does not allow a `css_set` to be linked to multiple nodes within the same hierarchy, as `cgroup` does not permit multiple resource limit configurations for the same type of resource on the same group of processes.

When a `css_set` is associated with nodes across multiple hierarchies, it indicates that the processes in the current `css_set` need to be controlled for multiple resources. Conversely, when a node in a hierarchy is associated with multiple `css_sets`, it means that the process lists under these `css_sets` are subject to the same resource limitations.

```c
struct task_struct {
    /* ... Omitted */

#ifdef CONFIG_CGROUPS
    /* Control Group info protected by css_set_lock */
    struct css_set __rcu *cgroups;
    /* cg_list protected by css_set_lock and tsk->alloc_lock */
    struct list_head cg_list;
#endif

    /* ... Omitted */
};

struct css_set {

    /* Reference count */
    atomic_t refcount;

    /*
     * List running through all cgroup groups in the same hash
     * slot. Protected by css_set_lock
     */
    struct hlist_node hlist;

    /*
     * List running through all tasks using this cgroup
     * group. Protected by css_set_lock
     */
    struct list_head tasks;

    /*
     * List of cg_cgroup_link objects on link chains from
     * cgroups referenced from this css_set. Protected by
     * css_set_lock
     */
    struct list_head cg_links;

    /*
     * Set of subsystem states, one for each subsystem. This array
     * is immutable after creation apart from the init_css_set
     * during subsystem registration (at boot time) and modular subsystem
     * loading/unloading.
     */
    struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];

    /* For RCU-protected deletion */
    struct rcu_head rcu_head;
};

struct cgroup_subsys_state {
    /*
     * The cgroup that this subsystem is attached to. Useful
     * for subsystems that want to know about the cgroup
     * hierarchy structure
     */
    struct cgroup *cgroup;

    /*
     * State maintained by the cgroup system to allow subsystems
     * to be "busy". Should be accessed via css_get(),
     * css_tryget() and css_put().
     */

    atomic_t refcnt;

    unsigned long flags;
    /* ID for this css, if possible */
    struct css_id __rcu *id;

    /* Used to put @cgroup->dentry on the last css_put() */
    struct work_struct dput_work;
};

struct cgroup {
    unsigned long flags;		/* "unsigned long" so bitops work */

    /*
     * count users of this cgroup. >0 means busy, but doesn't
     * necessarily indicate the number of tasks in the cgroup
     */
    atomic_t count;

    int id;				/* ida allocated in-hierarchy ID */

    /*
     * We link our 'sibling' struct into our parent's 'children'.
     * Our children link their 'sibling' into our 'children'.
     */
    struct list_head sibling;	/* my parent's children */
    struct list_head children;	/* my children */
    struct list_head files;		/* my files */

    struct cgroup *parent;		/* my parent */
    struct dentry *dentry;		/* cgroup fs entry, RCU protected */

    /*
     * This is a copy of dentry->d_name, and it's needed because
     * we can't use dentry->d_name in cgroup_path().
     *
     * You must acquire rcu_read_lock() to access cgrp->name, and
     * the only place that can change it is rename(), which is
     * protected by parent dir's i_mutex.
     *
     * Normally you should use cgroup_name() wrapper rather than
     * access it directly.
     */
    struct cgroup_name __rcu *name;

    /* Private pointers for each registered subsystem */
    struct cgroup_subsys_state *subsys[CGROUP_SUBSYS_COUNT];

    struct cgroupfs_root *root;

    /*
     * List of cg_cgroup_links pointing at css_sets with
     * tasks in this cgroup. Protected by css_set_lock
     */
    struct list_head css_sets;

    struct list_head allcg_node;	/* cgroupfs_root->allcg_list */
    struct list_head cft_q_node;	/* used during cftype add/rm */

    /*
     * Linked list running through all cgroups that can
     * potentially be reaped by the release agent. Protected by
     * release_list_lock
     */
    struct list_head release_list;

    /*
     * list of pidlists, up to two for each namespace (one for procs, one
     * for tasks); created on demand.
     */
    struct list_head pidlists;
    struct mutex pidlist_mutex;

    /* For RCU-protected deletion */
    struct rcu_head rcu_head;
    struct work_struct free_work;

    /* List of events which userspace want to receive */
    struct list_head event_list;
    spinlock_t event_list_lock;

    /* directory xattrs */
    struct simple_xattrs xattrs;
};
```

## 2.4 docker and cgroup

**`cgroup driver`:**

1. `system cgroup driver`
1. `cgroupfs cgroup driver`

## 2.5 kubernetes and cgroup

In Kubernetes, resources are limited at the pod level (making full use of the `cgroup` `hierarchy`), with the corresponding directory located at `/sys/fs/cgroup/<resource type>/kubepods.slice`.

## 2.6 cgroup Command Line

```sh
yum install -y libcgroup libcgroup-tools
```

**Examples:**

* `sudo cgcreate -g cpu,memory:/my_cgroup`
    * Then config cgroup in path `/sys/fs/cgroup/my_cgroup`
* `sudo cgexec -g cpu,memory:/my_cgroup <command>`

## 2.7 Cgroup2

Here are the key differences between `cgroup v1` and `cgroup v2`:

1. **Unified Hierarchy**: 
   * **cgroup v1** allows multiple hierarchies, with different controllers mounted to separate hierarchies, which can create complexity and inconsistencies in resource limits.
   * **cgroup v2** uses a single unified hierarchy where all controllers are mounted together, simplifying management and resource allocation.
1. **Simplified Resource Distribution**: 
   * In **cgroup v1**, each subsystem could have a different hierarchy, resulting in processes belonging to different cgroups across subsystems, complicating resource distribution.
   * **cgroup v2** enforces consistent resource distribution by having all controllers in the same hierarchy, ensuring that resources are allocated more predictably and effectively.
1. **Improved Resource Control**: 
   * **cgroup v2** offers enhanced features for CPU and I/O management, like the `io.weight` attribute, which replaces the older `blkio` subsystem for I/O control. This allows finer-grained control over resources.
   * CPU throttling in **cgroup v2** is managed by `cpu.max` instead of `cpu.cfs_period_us` and `cpu.cfs_quota_us` from **cgroup v1**, simplifying CPU limit configuration.
1. **Better Memory Management**: 
   * **cgroup v2** provides a single memory controller that combines `memory` and `memsw` (swap) control, which in **cgroup v1** were separate. This unified memory control simplifies memory management.
1. **Process Management Enhancements**:
   * **cgroup v2** introduces the `cgroup.procs` file, which lists only the PIDs of the immediate child processes in each cgroup, while **cgroup v1** uses `tasks`, which includes all threads and child processes.
   * With **cgroup v2**, thread granularity is no longer supported directly, as all threads of a process belong to the same cgroup by default, making process management more straightforward.
1. **Stricter Rules for Nested Control**:
   * In **cgroup v2**, child cgroups can inherit resource limits set by parent cgroups, enforcing stricter hierarchical resource control. This is beneficial for containerized environments like Kubernetes where resource limits are defined hierarchically.
   * **cgroup v1** does not enforce this as strictly, which can lead to misconfigurations and unexpected behavior in nested control.
1. **Compatibility and Adoption**:
   * **cgroup v1** is still widely used for legacy applications, but **cgroup v2** has become the default in many modern distributions, especially as container runtimes and orchestrators like Kubernetes adopt it for better resource control.

These enhancements make **cgroup v2** more efficient and easier to use in modern resource-constrained environments, especially with containerized applications.

In `cgroup v2`, the CPU subsystem configuration is streamlined, offering a simplified way to control CPU resource allocation. Here are the main parameters used to configure CPU limits in `cgroup2`:

1. **cpu.max**:
    * `cpu.max` controls the maximum CPU bandwidth available to the `cgroup`.
    * It accepts two values: `quota` and `period`, formatted as `quota period`.
        * `quota`: The maximum amount of time in microseconds that a `cgroup` can use CPU in each period. If set to "max", there is no limit.
        * `period`: The time window in microseconds for each quota cycle. The default is `100000` (100ms).
    * Example: `echo "50000 100000" > /sys/fs/cgroup/<path>/cpu.max`
        * This setting allows the `cgroup` to use up to 50ms of CPU time in every 100ms period, effectively capping it at 50% CPU usage.
1. **cpu.weight**:
    * `cpu.weight` specifies the relative weight of CPU time the `cgroup` should receive when compared to other `cgroups`.
    * It accepts values between `1` and `10000`, with `100` as the default. A higher value gives the `cgroup` more CPU time relative to other `cgroups` with lower weights.
    * Example: `echo "200" > /sys/fs/cgroup/<path>/cpu.weight`
        * This sets the `cgroup` to have twice the default CPU share.
1. **cpu.pressure**:
    * `cpu.pressure` provides CPU pressure information, indicating how much CPU demand exceeds supply in the `cgroup`. It is a read-only metric that helps monitor how frequently tasks are waiting for CPU time.
    * It contains three values:
        * `some`: Percentage of time at least one task is delayed by CPU pressure.
        * `full`: Percentage of time all tasks are delayed by CPU pressure.
        * `avg10`, `avg60`, `avg300`: Average CPU pressure over 10, 60, and 300 seconds.
    * Example: `cat /sys/fs/cgroup/<path>/cpu.pressure`
        * This gives insight into CPU resource contention within the `cgroup`.

## 2.8 FAT

### 2.8.1 Will cpu subsystem limit cpu load as well?

The load average is calculated based on the number of tasks waiting for CPU time, but with cgroup limitations, the kernel scheduler keeps most of the threads in a throttled state, so they are not actively contending for CPU in a way that contributes significantly to system-wide load.

## 2.9 Reference

* [【docker 底层知识】cgroup 原理分析](https://blog.csdn.net/zhonglinzhang/article/details/64905759)
* [Linux Cgroup 入门教程：基本概念](https://fuckcloudnative.io/posts/understanding-cgroups-part-1-basics/)
* [Linux Cgroup 入门教程：CPU](https://fuckcloudnative.io/posts/understanding-cgroups-part-2-cpu/)
* [Linux Cgroup 入门教程：内存](https://fuckcloudnative.io/posts/understanding-cgroups-part-3-memory/)
* [Linux资源管理之cgroups简介](https://tech.meituan.com/2015/03/31/cgroups.html)
* [Linux Cgroup浅析](https://zhuanlan.zhihu.com/p/102372680)
* [RedHat-资源管理指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/resource_management_guide/index)
* [DOCKER基础技术：LINUX CGROUP](https://coolshell.cn/articles/17049.html)
* [LINUX CGROUP总结](https://www.cnblogs.com/menkeyi/p/10941843.html)
* [clone-manpage](http://man7.org/linux/man-pages/man2/clone.2.html)
* [Docker 背后的内核知识——cgroups 资源限制](https://www.infoq.cn/article/docker-kernel-knowledge-cgroups-resource-isolation/)
* [理解Docker（4）：Docker 容器使用 cgroups 限制资源使用](https://www.cnblogs.com/sammyliu/p/5886833.html)
* [kubernetes kubelet组件中cgroup的层层"戒备"](https://www.cnblogs.com/gaorong/p/11716907.html)

# 3 Systemd

本小节转载自[Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

## 3.1 Overview

历史上，Linux的启动一直采用`init`进程，这种方法有两个缺点

1. 一是启动时间长。`init`进程是串行启动，只有前一个进程启动完，才会启动下一个进程
1. 二是启动脚本复杂。`init`进程只是执行启动脚本，不管其他事情。脚本需要自己处理各种情况，这往往使得脚本变得很长

**`Systemd`就是为了解决这些问题而诞生的。它的设计目标是，为系统的启动和管理提供一套完整的解决方案**

## 3.2 Unit

`Systemd`可以管理所有系统资源。不同的资源统称为`Unit`（单位），`Unit`一共分成12种

1. **`Service unit`：系统服务**
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

每一个`Unit`都有一个配置文件，告诉`Systemd`怎么启动这个`Unit`。**`Systemd`默认从目录`/etc/systemd/system/`读取配置文件。但是，里面存放的大部分文件都是符号链接，指向目录`/usr/lib/systemd/system/`，真正的配置文件存放在那个目录**。`systemctl enable`命令用于在上面两个目录之间，建立符号链接关系。与之对应的，`systemctl disable`命令用于在两个目录之间，撤销符号链接关系，相当于撤销开机启动。配置文件的后缀名，就是该`Unit`的种类。如果省略，**`Systemd`默认后缀名为`.service`**

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
* **注意，从配置文件的状态无法看出，该`Unit`是否正在运行。若要查看`Unit`的运行状态，需要使用`systemctl status`命令**

## 3.3 Config Format

**`systemctl cat`可以查看配置文件的内容，例如`systemctl cat sshd.service`**

一般来说，一个`Unit`的格式如下

```
[Unit]
...

[Service]
...

[Install]
...
```

**`[Unit]`区块通常是配置文件的第一个区块，用来定义`Unit`的元数据，以及配置与其他`Unit`的关系。它的主要字段如下**

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

**`[Service]`区块定义如何启动当前`Service`（只有`Service`类型的`Unit`才有这个区块）。它的主要字段如下**

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
    * `Environment="VAR1=xxx" "VAR2=true" "VAR3=yyy"`：可以同时指定多个
    * 或者写多个`Environment`配置
        ```
        Environment="VAR1=xxx"
        Environment="VAR2=true"
        Environment="VAR3=yyy"
        ```

* `PrivateTmp`：是否拥有私有的`/tmp`目录

**`[Install]`区块，定义如何安装这个配置文件，即怎样做到开机启动**

* `WantedBy`：表示该配置所在的`Target`
* `Target`的含义是服务组，表示一组服务。`WantedBy=multi-user.target`指的是，`sshd`所在的`Target`是`multi-user.target`。这个设置非常重要，因为执行`systemctl enable sshd.service`命令时，`sshd.service`的一个符号链接，就会放在`/etc/systemd/system`目录下面的`multi-user.target.wants`子目录之中

完整的配置项清单参考[systemd.unit — Unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)

## 3.4 Command Line

### 3.4.1 systemctl

* `systemctl start xxx.service`
* `systemctl stop xxx.service`
* `systemctl enable xxx.service`
* `systemctl disable xxx.service`
* `systemctl status xxx.service`
* `systemctl status <pid>`
* `systemctl restart xxx.service`
* `systemctl reload xxx.service`
* `systemctl list-units --type=service`: List all services.
* `systemctl daemon-reload`: Reload unit config.
* `systemctl show xxx.service`: Show all properties.
    * `systemctl show xxx.service --property=ActiveState`
    * `systemctl show xxx.service --property=MainPID`
* **`systemctl set-default xxx.target`: Set default run level. Similar to `CentOS 6.x run level`**
    * `poweroff.target`：对应`level-0`
    * `rescue.target`：对应`level-1`
    * `multi-user.target`：对应`level-2/3/4`
    * `graphical.target`：对应`level-5`
    * `reboot.target`：对应`level-6`
* **`systemctl get-default`**

### 3.4.2 journalctl

* `journalctl -u xxx.service`
    * `journalctl -u xxx.service -n 100`
    * `journalctl -u xxx.service -f`
* `journalctl --vacuum-time=2d`: Removes archived journal files older than the specified timespan. Accepts the usual `s` (default), `m`, `h`, `days`, `months`, `weeks` and `years` suffixes.
* `journalctl --vacuum-size=500M`: Removes the oldest archived journal files until the disk space they use falls below the specified size. Accepts the usual `K`, `M`, `G` and `T` suffixes (to the base of `1024`).

## 3.5 User Service Manager

**特点：**

* **用户级服务**：针对单个用户的服务，这些服务在用户登录时启动，退出登录时停止
* **权限**：运行在用户级别的服务通常不需要（也不应该）超级用户权限
* **作用域**：只影响启动这些服务的特定用户
* **配置文件位置**：用户级服务的配置文件通常位于用户的`~/.config/systemd/user/`目录
* **用途**：用户特定的应用程序、开发工具、个人软件实例等

**示例：只要加上`--user`即可，其他用法均类似**

* `systemctl --user daemon-reload`
* `systemctl --user status`
* `systemctl --user start xxx.service`

## 3.6 demo

**下面写了一个非常简单的程序（文件名为`demo-service.c`）：接受并处理`1`、`2`、`15`三种信号**

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

**接下来将它注册到systemd中**

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

**测试**

```sh
# 编译
gcc -o demo-service demo-service.c

# 启动demo-service
systemctl start demo-service.service

# 查看demo-service的运行状态
systemctl status demo-service.service
#-------------------------↓↓↓↓↓↓-------------------------
● demo-service.service - Systemd Demo Service
   Loaded: loaded (/usr/lib/systemd/system/demo-service.service; enabled; vendor preset: disabled)
   Active: active (running) since 日 2019-11-24 03:21:52 EST; 46s ago
     Docs: https://liuyehcf.github.io/2019/10/13/Linux-%E9%87%8D%E8%A6%81%E7%89%B9%E6%80%A7/
  Process: 3368 ExecStop=/bin/kill -s QUIT $MAINPID (code=exited, status=0/SUCCESS)
 Main PID: 3392 (demo-service)
   CGroup: /system.slice/demo-service.service
           └─3392 /root/demo-service

11月 24 03:21:52 localhost.localdomain systemd[1]: Started Systemd Demo Service.
#-------------------------↑↑↑↑↑↑-------------------------

# 重新加载配置文件（发送 SIGHUP 信号）
systemctl reload demo-service.service
# 查看日志文件
cat /root/default.log
#-------------------------↓↓↓↓↓↓-------------------------
捕获信号 1, 重新加载配置文件
#-------------------------↑↑↑↑↑↑-------------------------

# 停止服务
systemctl stop demo-service.service
#-------------------------↓↓↓↓↓↓-------------------------
捕获信号 1, 重新加载配置文件
捕获信号 15, 退出进程
#-------------------------↑↑↑↑↑↑-------------------------
```

## 3.7 Reference

* [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
* [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
* [最简明扼要的 Systemd 教程，只需十分钟](https://blog.csdn.net/weixin_37766296/article/details/80192633)
* [systemd添加自定义系统服务设置自定义开机启动](https://www.cnblogs.com/wjb10000/p/5566801.html)
* [systemd创建自定义服务(Ubuntu)](https://www.cnblogs.com/wintersoft/p/9937839.html)
* [Use systemd to Start a Linux Service at Boot](https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/)
* [Play With Container Network Interface](https://arthurchiao.github.io/blog/play-with-container-network-if/)
* [systemd forking vs simple?](https://superuser.com/questions/1274901/systemd-forking-vs-simple)

# 4 SELinux

## 4.1 DAC

自主式存取控制(Discretionary Access Control, DAC)。基本上，就是依据程序的拥有者与文件资源的`rwx`权限来决定有无存取的能力

## 4.2 MAC

委任式存取控制(Mandatory Access Control, MAC)。MAC可以针对特定的程序与特定的文件资源来进行权限的控管。也就是说，即使你是`root`，那么在使用不同的程序时，你所能取得的权限并不一定是`root`，而得要看当时该程序的配置而定。如此一来，我们针对控制的『主体』变成了『程序』而不是用户。此外，这个主体程序也不能任意使用系统文件资源，因为每个文件资源也有针对该主体程序配置可取用的权限。如此一来，控制项目就细的多了。但整个系统程序那么多、文件那么多，一项一项控制可就没完没了。所以`SELinux`也提供一些默认的政策(Policy)，并在该政策内提供多个守则(rule)，让你可以选择是否激活该控制守则

## 4.3 SELinux Run Mode

`SELinux`是透过MAC的方式来控管程序，他控制的主体是程序，而目标则是该程序能否读取的『文件资源』

**主体(Subject)**：`SELinux`主要想要管理的就是`程序`，因此你可以将『主体』跟`process`划上等号

**目标(Object)**：主体程序能否存取的『目标资源』一般就是文件系统。因此这个目标项目可以等`文件系统`划上等号

**政策(Policy)**：由於程序与文件数量庞大，因此`SELinux`会依据某些服务来制订基本的存取安全性政策。这些政策内还会有详细的守则(rule)来指定不同的服务开放某些资源的存取与否。`SELinux`提供两个主要的政策，分别是：

* `targeted`：针对网络服务限制较多，针对本机限制较少，是默认的政策
* `strict`：完整的`SELinux`限制，限制方面较为严格
* 建议使用默认的`targeted`政策即可。

**安全性本文(security context)**：我们刚刚谈到了主体、目标与政策面，但是主体能不能存取目标除了政策指定之外，主体与目标的安全性本文必须一致才能够顺利存取。这个安全性本文(security context)有点类似文件系统的`rwx`。安全性本文的内容与配置是非常重要的。如果配置错误，你的某些服务(主体程序)就无法存取文件系统(目标资源)，当然就会一直出现『权限不符』的错误信息了

![fig1](/images/Linux-Mechanism/selinux.jpg)

上图的重点在『主体』如何取得『目标』的资源存取权限。由上图我们可以发现，主体程序必须要通过`SELinux`政策内的守则放行后，就可以与目标资源进行安全性本文的比对，若比对失败则无法存取目标，若比对成功则可以开始存取目标。问题是，最终能否存取目标还是与文件系统的`rwx`权限配置有关

## 4.4 Security Context

**安全性本文存在於`主体程序`中与`目标文件资源`中**

* **程序在内存内，所以安全性本文可以存入是没问题**
* **那文件的安全性本文是记录在哪里呢？事实上，安全性本文是放置到文件的`inode`内的**，因此主体程序想要读取目标文件资源时，同样需要读取`inode`，这`inode`内就可以比对安全性本文以及`rwx`等权限值是否正确，而给予适当的读取权限依据

安全性本文主要用冒号分为三个栏位，这三个栏位的意义为

1. **身份识别(Identify)**：相当於帐号方面的身份识别。主要的身份识别则有底下三种常见的类型：
    * `root`：表示`root`的帐号身份
    * `system_u`：表示系统程序方面的识别，通常就是程序
    * `user_u`：代表的是一般使用者帐号相关的身份
    * 系统上面大部分的数据都会是`system_u`或`root`
    * 如果是在`/home`底下的数据，那么大部分应该就会是`user_u`
1. **角色(Role)**：这个数据是属於程序、文件资源还是代表使用者。一般的角色有：
    * `object_r`：代表的是文件或目录等文件资源，这应该是最常见的
    * `system_r`：代表的就是程序。不过，一般使用者也会被指定成为`system_r`喔
1. **类型(Type)**：在默认的`targeted`政策中，`Identify`与`Role`栏位基本上是不重要的。重要的在於这个类型(type)栏位。基本上，一个主体程序能不能读取到这个文件资源，与类型栏位有关，而类型栏位在文件与程序的定义不太相同，分别是
    * `type`：在文件资源(Object)上面称为类型(Type)
    * `domain`：在主体程序(Subject)则称为领域(domain)了
    * `domain`需要与`type`搭配，则该程序才能够顺利的读取文件资源

## 4.5 Reference

* [第十七章、程序管理与 SELinux 初探](http://cn.linux.vbird.org/linux_basic/0440processcontrol_5.php)
* [INTRODUCTION TO SELINUX](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/5/html/deployment_guide/ch-selinux)
* [sVIrt概述](https://www.cnblogs.com/ck1020/p/5901662.html)

# 5 cBPF vs. eBPF

**概念：**

* `cBPF, classic BPF, Berkeley Packet Filter`：`seccomp/tcpdump`仍然在使用`cBPF`，但是在更新的版本上，通常会被转换成`eBPF`字节码再执行
* `eBPF, extended BPF`：具有更好的扩展性，更好的性能
    * 一般来说，`BPF`就是指`eBPF`

## 5.1 [bcc](https://github.com/iovisor/bcc)

`bcc, BPF Compiler Collection`

* [bcc/INSTALL.md](https://github.com/iovisor/bcc/blob/master/INSTALL.md)
* [bcc/docs/tutorial.md](https://github.com/iovisor/bcc/blob/master/docs/tutorial.md)

**下图是所有`bcc`包含的工具**

![bcc](/images/Linux-Mechanism/bcc.png)

## 5.2 [bpftrace](https://github.com/iovisor/bpftrace)

## 5.3 Reference

* [Linux Extended BPF (eBPF) Tracing Tools](https://www.brendangregg.com/ebpf.html)
* [Learn eBPF Tracing: Tutorial and Examples](https://www.brendangregg.com/blog/2019-01-01/learn-ebpf-tracing.html)
* [socket tracer](https://mp.weixin.qq.com/s/0w5t_KkHRLXkEY1_qbdTtw)

# 6 Interrupt

## 6.1 Reference

* [linux异常处理体系结构](https://www.cnblogs.com/gulan-zmc/p/11604437.html)
* [Linux的中断处理机制 [一] - 数据结构(1)](https://zhuanlan.zhihu.com/p/83709066)
* [Linux的中断处理机制 [二] - 数据结构(2)](https://zhuanlan.zhihu.com/p/85353687)
* [Linux的中断处理机制 [三] - hardirq](https://zhuanlan.zhihu.com/p/85454778)
* [Linux 中断](https://zhuanlan.zhihu.com/p/94788008)
* [Linux 内核中断内幕](https://www.ibm.com/developerworks/cn/linux/l-cn-linuxkernelint/index.html)
* [彻底搞懂异常控制流](https://www.cnblogs.com/niuyourou/p/12097856.html)
* [嵌入式杂谈之中断向量表](https://zhuanlan.zhihu.com/p/125480457)

# 7 NUMA

`NUMA`（`Non-Uniform Memory Access`，非一致性内存访问）是一种计算机系统体系结构，用于解决多处理器系统中共享内存的问题。在`NUMA`架构中，系统内存被划分为多个节点（`Node`），每个节点有自己的内存和处理器。节点之间通过互联网络进行通信，进程可以在不同的节点上运行，并访问不同节点的内存。

`NUMA`相对于传统的`SMP`（`Symmetric Multi-Processing`，对称多处理）架构来说，可以提供更好的可扩展性和更高的性能。在`SMP`架构中，所有处理器共享一个全局内存，因此内存访问的延迟和带宽是一致的。但是在`NUMA`架构中，不同节点之间的内存访问延迟和带宽可能不同，这就需要程序员进行显式的内存分配和管理，以保证内存访问的局部性和性能

在`NUMA`架构中，操作系统和编译器需要提供支持，以便程序员可以使用`NUMA`相关的`API`和指令来控制内存分配和访问。例如，`Linux`提供了`libnuma`库和`numactl`工具，可以用于控制进程和内存的亲和性和绑定性，以及使用`NUMA`相关的系统调用和环境变量来进行内存分配和管理。在编译器层面，一些编译器可以通过特定的编译选项来生成`NUMA`意识的代码，以优化内存访问的性能和局部性

## 7.1 Reference

* [十年后数据库还是不敢拥抱NUMA？](https://zhuanlan.zhihu.com/p/387117470)

