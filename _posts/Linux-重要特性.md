---
title: Linux-重要特性
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

### 1.6.1 无网桥

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
[root@liuyehcf ~]$ source netns_without_bridge.sh

# 配置
[root@liuyehcf ~]$ setup
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
[root@liuyehcf ~]$ ip netns exec liuye ping -c 3 www.aliyun.com
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
[root@liuyehcf ~]$ cleanup
#-------------------------↓↓↓↓↓↓-------------------------
1/4: 删除 'FORWARD' 规则
2/4: 删除 'NAT'
3/4: 删除网卡设备 'veth1' 以及 'veth2'
4/4: 删除网络命名空间 'liuye'
#-------------------------↑↑↑↑↑↑-------------------------
```

### 1.6.2 有网桥

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
[root@liuyehcf ~]$ source netns_with_bridge.sh

# 配置
[root@liuyehcf ~]$ setup
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
[root@liuyehcf ~]$ ip netns exec liuye ping -c 3 www.aliyun.com
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
[root@liuyehcf ~]$ cleanup
#-------------------------↓↓↓↓↓↓-------------------------
1/6: 删除 'FORWARD' 规则
2/6: 删除 'NAT'
3/6: 删除网卡设备 'veth1' 以及 'veth2'
4/6: 删除网络命名空间 'liuye'
5/6: 关闭网桥 'demobridge'
6/6: 删除网桥 'demobridge'
#-------------------------↑↑↑↑↑↑-------------------------
```

## 1.7 实现简易容器

该部分转载自[Container Creation Using Namespaces and Bash](https://dev.to/nicolasmesa/)

### 1.7.1 术语解释

**Container**：容器是一组技术的集合，包括`namespace`、`cgroup`，在本小结，我们关注的重点是`namespace`

**Namespace**：包含六种namespace，包括`PID`、`User`、`Net`、`Mnt`、`Uts`、`Ipc`

**Btrfs**：Btrfs是一种采用`Copy On Write`模式的高效、易用的文件系统

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
#-------------------------↓↓↓↓↓↓-------------------------
记录了4194304+0 的读入
记录了4194304+0 的写出
2147483648字节(2.1 GB)已复制，14.8679 秒，144 MB/秒
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.2 格式化disk image

```sh
# 利用 mkfs.btrfs 命令，将一个文件格式化成 btrfs 文件系统
[root@liuyehcf ~]$ mkfs.btrfs disk.img
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
#-------------------------↓↓↓↓↓↓-------------------------
Create subvolume 'images/alpine'
#-------------------------↑↑↑↑↑↑-------------------------

# docker run 启动一个容器
#   -d：退到容器之外，并打印container id
#   alpine:3.10.2：镜像
#   true：容器执行的命令
[root@liuyehcf btrfs]$ CID=$(docker run -d alpine:3.10.2 true)
[root@liuyehcf btrfs]$ echo $CID
#-------------------------↓↓↓↓↓↓-------------------------
f9d2df08221a67653fe6af9f99dbb2367a6736aecbba8c5403bf3dbb68310f2a
#-------------------------↑↑↑↑↑↑-------------------------

# 将容器对应的镜像导出到 images/alpine/ 目录中
[root@liuyehcf btrfs]$ docker export $CID | tar -C images/alpine/ -xf-
[root@liuyehcf btrfs]$ ls images/alpine/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 以 images/alpine/ 为源，制作快照 containers/tupperware
[root@liuyehcf btrfs]$ btrfs subvol snapshot images/alpine/ containers/tupperware
#-------------------------↓↓↓↓↓↓-------------------------
Create a snapshot of 'images/alpine/' in 'containers/tupperware'
#-------------------------↑↑↑↑↑↑-------------------------

# 在快照中创建一个文件
[root@liuyehcf btrfs]$ touch containers/tupperware/NICK_WAS_HERE

# 在快照路径中ls，发现存在文件 NICK_WAS_HERE
[root@liuyehcf btrfs]$ ls containers/tupperware/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 在源路径中ls，发现不存在文件 NICK_WAS_HERE
[root@liuyehcf btrfs]$ ls images/alpine/
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.6 使用chroot测试

```sh
# 将 containers/tupperware/  作为 /root，并执行/root/bin/sh（这里root就是指change之后的root）
[root@liuyehcf btrfs]$ chroot containers/tupperware/ /bin/sh

# 配置环境变量，否则找不到命令
/ $ export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

/ $ ls
#-------------------------↓↓↓↓↓↓-------------------------
NICK_WAS_HERE  dev            home           media          opt            root           sbin           sys            usr
bin            etc            lib            mnt            proc           run            srv            tmp            var
#-------------------------↑↑↑↑↑↑-------------------------

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
#-------------------------↓↓↓↓↓↓-------------------------
  PID TTY          TIME CMD
 1583 pts/0    00:00:00 bash
 2204 pts/0    00:00:00 unshare
 2205 pts/0    00:00:00 bash
 2281 pts/0    00:00:00 ps
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.8 挂载proc

```sh
# 挂载proc
[root@tupperware btrfs]$ mount -t proc nodev /proc

# 再次查看进程，发现进程号从1开始
[root@tupperware btrfs]$ ps
#-------------------------↓↓↓↓↓↓-------------------------
  PID TTY          TIME CMD
    1 pts/0    00:00:00 bash
   25 pts/0    00:00:00 ps
#-------------------------↑↑↑↑↑↑-------------------------

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
#-------------------------↓↓↓↓↓↓-------------------------
bin  dev  etc  home  lib  media  mnt  NICK_WAS_HERE  oldroot  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
#-------------------------↑↑↑↑↑↑-------------------------

# 利用 pivot_root 交换两个文件系统的挂载点
# 执行完毕之后，旧的文件系统（宿主机的根文件系统）的挂载点就是oldroot，新的文件系统（容器）的挂载点是/
[root@tupperware btrfs]$ pivot_root . oldroot

# 由于根文件系统已经切换了，需要重新配下环境变量，否则找不到命令
[root@tupperware btrfs]$ export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

[root@tupperware btrfs]$ cd /

# 查看当前的根目录，其实就是容器
[root@tupperware /]$ ls
#-------------------------↓↓↓↓↓↓-------------------------
NICK_WAS_HERE  dev            home           media          oldroot        proc           run            srv            tmp            var
bin            etc            lib            mnt            opt            root           sbin           sys            usr
#-------------------------↑↑↑↑↑↑-------------------------

# 查看原始的根目录，之前的根文件系统挂载到了 oldroot
[root@tupperware /]$ ls oldroot/
#-------------------------↓↓↓↓↓↓-------------------------
bin       boot      btrfs     dev       disk.img  etc       home      lib       lib64     media     mnt       opt       proc      root      run       sbin      srv       sys       tmp       usr       var
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.10 整理挂载点

```sh

# 必须先挂载proc，因为mount命令依赖proc
[root@tupperware /]$ mount -t proc nodev /proc

# 查看当前挂载点，可以发现存在非常多的挂载点，这些挂载点不应该对容器可见
[root@tupperware /]$ mount | head
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

[root@tupperware /]$ umount -a
#-------------------------↓↓↓↓↓↓-------------------------
umount: can't unmount /oldroot/btrfs: Resource busy
umount: can't unmount /oldroot: Resource busy
#-------------------------↑↑↑↑↑↑-------------------------

# 继续挂载proc，因为mount依赖proc
[root@tupperware /]$ mount -t proc nodev /proc

# 在上一步 umount -a 中，由于/oldroot未被卸载掉，因此这里仍然可以看到
[root@tupperware /]$ mount
#-------------------------↓↓↓↓↓↓-------------------------
/dev/mapper/centos-root on /oldroot type xfs (rw,seclabel,relatime,attr2,inode64,noquota)
/dev/loop0 on /oldroot/btrfs type btrfs (ro,seclabel,relatime,space_cache,subvolid=5,subvol=/)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------↑↑↑↑↑↑-------------------------

# 卸载 /oldroot
#   -l：like将文件系统从挂载点detach出来，当它不繁忙时，再进行剩余清理工作
[root@tupperware /]$ umount -l /oldroot

# 至此，挂载点整理完毕
[root@tupperware /]$ mount
#-------------------------↓↓↓↓↓↓-------------------------
rootfs on / type rootfs (rw)
/dev/loop0 on / type btrfs (ro,seclabel,relatime,space_cache,subvolid=258,subvol=/containers/tupperware)
proc on /proc type proc (rw,relatime)
#-------------------------↑↑↑↑↑↑-------------------------
```

#### 1.7.3.11 网络命名空间

**以下命令，在容器终端执行（unshare创建的容器终端）**

```sh
[root@tupperware /]$ ping 8.8.8.8
#-------------------------↓↓↓↓↓↓-------------------------
PING 8.8.8.8 (8.8.8.8): 56 data bytes
ping: sendto: Network unreachable
#-------------------------↑↑↑↑↑↑-------------------------

[root@tupperware /]$ ifconfig -a
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

[root@liuyehcf ~]$ CPID=$(pidof unshare)
[root@liuyehcf ~]$ echo $CPID
#-------------------------↓↓↓↓↓↓-------------------------
2204
#-------------------------↑↑↑↑↑↑-------------------------

# 创建一对网卡设备，名字分别为 h2204 以及 c2204
[root@liuyehcf ~]$ ip link add name h$CPID type veth peer name c$CPID

# 将网卡 c2204 放入容器网络的命名空间中，网络命名空间就是容器的pid，即2204
[root@liuyehcf ~]$ ip link set c$CPID netns $CPID
```

**以下命令，在容器终端执行（unshare创建的容器终端）**

```sh
[root@tupperware /]$ ifconfig -a
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
[root@liuyehcf ~]$ ip link set h$CPID master docker0 up
[root@liuyehcf ~]$ ifconfig docker0
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
[root@tupperware /]$ ip link set lo up

# 将网卡 c2204 重命名为eth0，并将其打开
[root@tupperware /]$ ip link set c2204 name eth0 up

# 给网卡eth0分配ip，要注意，该ip必须与网桥 docker0 位于同一网段
[root@tupperware /]$ ip addr add 172.17.42.3/16 dev eth0

# 将网桥 docker0 设为默认路由
[root@tupperware /]$ ip route add default via 172.17.0.1

# 查看网卡设备
[root@tupperware /]$ ifconfig
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

[root@tupperware /]$ ping -c 3 8.8.8.8
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

### 1.7.4 清理

```sh
# 退出容器终端
[root@tupperware /]$ exit
#-------------------------↓↓↓↓↓↓-------------------------
exit
#-------------------------↑↑↑↑↑↑-------------------------

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

**`cgroup`和`namespace`类似，也是将进程进行分组，但它的目的和`namespace`不一样，`namespace`是为了隔离进程组之间的资源（每个进程都有一个隔离的资源视图），而`cgroup`是为了对一组进程进行统一的资源监控和限制**

## 2.1 层级结构（hierarch）

**一个`hierarchy`可以理解为一棵`cgroup`树，树的每个`节点`就是一个`进程组`，每棵树都会与零到多个`subsystem`关联**。在一颗树里面，会包含Linux系统中的所有进程，但每个进程只能属于一个节点（进程组）。系统中可以有很多颗`cgroup`树，每棵树都和不同的`subsystem`关联，一个进程可以属于多颗树，即一个进程可以属于多个进程组，只是这些进程组和不同的`subsystem`关联。目前Linux支持12种`subsystem`，如果不考虑不与任何`subsystem`关联的情况（`systemd`就属于这种情况），Linux里面最多可以建12颗`cgroup`树，每棵树关联一个`subsystem`，当然也可以只建一棵树，然后让这棵树关联所有的`subsystem`。当一颗`cgroup`树不和任何`subsystem`关联的时候，意味着这棵树只是将进程进行分组，至于要在分组的基础上做些什么，将由应用程序自己决定，`systemd`就是一个这样的例子

## 2.2 子系统（subsystem）

**一个`subsystem`就是一个内核模块，他被关联到一颗`cgroup`树之后，就会在树的每个节点（进程组）上做具体的操作。**`subsystem`经常被称作`resource controller`，因为它主要被用来调度或者限制每个进程组的资源，但是这个说法不完全准确，因为有时我们将进程分组只是为了做一些监控，观察一下他们的状态，比如`perf_event subsystem`。到目前为止，Linux支持12种`subsystem`，比如限制CPU的使用时间，限制使用的内存，统计CPU的使用情况，冻结和恢复一组进程等，后续会对它们一一进行介绍

**以下是12种`cgroup`子系统**

1. `blkio`：限制`cgroup`访问块设备的IO速度
1. **`cpu`：用来限制`cgroup`的CPU使用率**
1. `cpuacct`：统计`cgroup`的CPU的使用率
1. `cpuset`：绑定`cgroup`到指定`CPUs`和`NUMA`节点
1. `devices`：限制`cgroup`创建（`mknod`）和访问设备的权限
1. `freezer`：`suspend`和`restore`一个`cgroup`中的所有进程
1. `hugetlb`：限制`cgroup`的`huge pages`的使用量
1. **`memory`：统计和限制`cgroup`的内存的使用率，包括`process memory`、`kernel memory`、和`swap`**
1. `net_cls`：将一个`cgroup`中进程创建的所有网络包加上一个`classid`标记，用于`tc`和`iptables`。只对发出去的网络包生效，对收到的网络包不起作用
1. `net_prio`：针对每个网络接口设置`cgroup`的访问优先级
1. `perf_event`：对`cgroup`进行性能监控
1. **`pids`：限制一个`cgroup`及其子孙`cgroup`中的总进程数**

**可以通过`cat /proc/cgroups`或者`mount -t cgroup`查看系统支持的子系统**

### 2.2.1 cpu子系统

cpu子系统可以调度`cgroup`对cpu的获取量。可用以下两个调度程序来管理对cpu资源的获取

* 完全公平调度程序（CFS）：一个比例分配调度程序，可根据任务优先级∕权重或cgroup分得的份额，在cgroups间按比例分配cpu时间（cpu带宽）
* 实时调度程序（RT）：一个任务调度程序，可对实时任务使用cpu的时间进行限定

**我们可以通过`cpu.cfs_period_us`、`cpu.cfs_quota_us`这两个参数来控制cpu的使用上限**

1. `cpu.cfs_period_us`：该参数的单位是微秒，用于定义cpu调度周期的带宽（时间长度）
1. `cpu.cfs_quota_us`：该参数的单位是微秒，用于定义在一个cpu调度周期中，可以使用的cpu的带宽

**`cpu.cfs_quota_us`与`cpu.cfs_period_us`的比值，就是cpu的占用比。但是，在保证比例不变的情况下，`cpu.cfs_period_us`数值的大小也会影响进程实际的行为**

* 若`cpu.cfs_period_us`非常大，比如`1s`，然后占用比是20%，进程的行为可能就是，前`0.2s`满负荷运行，后面`0.8s`阻塞，停滞的感觉会比较强
* 若`cpu.cfs_period_us`非常小，比如`10ms`，然后占用比是20%，进程的行为可能就是，前`2ms`满负荷运行，后面`8ms`阻塞，停滞的感觉会比较弱，相对较平顺

**下面进行验证**

```sh
# 终端A：编写测试程序
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

# 终端A：运行该程序
./test_cpu_subsystem

# 终端B：在cpu子系统所在的层级结构上创建一个新的节点（目录）
mkdir /sys/fs/cgroup/cpu/test_cpu_subsystem

# cpu.cfs_period_us设置成1s，cpu.cfs_quota_us设置成0.2s，占比是20%
echo 1000000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_period_us
echo 200000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_quota_us
pgrep -f test_cpu_subsystem > /sys/fs/cgroup/cpu/test_cpu_subsystem/tasks
# 此时可以发现，在终端A中，输出的速率有明显顿挫，刷屏0.2s后，会停0.8s，然后循环此过程

# cpu.cfs_period_us设置成10ms，cpu.cfs_quota_us设置成2ms，占比也是20%
echo 10000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_period_us
echo 2000 > /sys/fs/cgroup/cpu/test_cpu_subsystem/cpu.cfs_quota_us
# 此时可以发现，在终端A中，刷屏比较平顺

# 终端B：停止进程，并删除测试cgroup节点
pkill -f test_cpu_subsystem
cgdelete cpu:test_cpu_subsystem
```

**我们可以通过`cpu.rt_period_us`、`cpu.rt_runtime_us`这两个参数，用来限制某个任务的cpu限制**

* `cpu.rt_period_us`：该参数的单位是微秒，用于定义在某个时间段中，cgroup对cpu资源访问重新分配的时间周期
* `cpu.rt_runtime_us`：该参数的单位是微秒，用于定义在某个时间段中，cgroup中的任务对cpu资源的最长连续访问时间（建立这个限制是为了防止一个cgroup中的任务独占cpu时间）

**`cpu.stat`记录了cpu时间统计**

* `nr_periods`：经过的cpu调度周期的个数
* `nr_throttled`：cgrpu中任务被节流的次数（耗尽所有配额时间后，被禁止运行）
* `throttled_time`：`cgroup`中任务被节流的时间总量

**若我们想控制两个`cgroup`的相对比例，可以通过配置`cpu.shares`来实现。例如，第一个`cgroup`设置成200，第二个`cgroup`设置成100，那么前者可使用的cpu时间是后者的两倍**

**当一个进程被添加到某个cgroup中的task中后，由该进程创建的线程都自动属于这个cgroup。换言之，就是在之前创建的那些线程，并不会自动属于这个cgroup！！！**

## 2.3 内核实现

![cgroup_struct](/images/Linux-重要特性/cgroup_struct.png)

上面这个图从整体结构上描述了进程与`cgroup`之间的关系。最下面的`P`代表一个进程。每一个进程的描述符中有一个指针指向了一个辅助数据结构`css_set`（`cgroups subsystem set`）。指向某一个`css_set`的进程会被加入到当前`css_set`的进程链表中。一个进程只能隶属于一个`css_set`，一个`css_set`可以包含多个进程，隶属于同一`css_set`的进程受到同一个`css_set`所关联的资源限制

上图中的`M×N Linkage`说明的是`css_set`通过辅助数据结构可以与层级结构的`节点`进行多对多的关联。但是`cgroup`不允许`css_set`同时关联同一个层级结构下的多个`节点`，这是因为`cgroup`对同一组进程的同一种资源不允许有多个限制配置

一个`css_set`关联多个层级结构的`节点`时，表明需要对当前`css_set`下的进程进行多种资源的控制。而一个层级结构的`节点`关联多个`css_set`时，表明多个`css_set`下的进程列表受到同一份资源的相同限制

```c
struct task_struct {
    /* ... 省略无关定义 */

#ifdef CONFIG_CGROUPS
    /* Control Group info protected by css_set_lock */
    struct css_set __rcu *cgroups;
    /* cg_list protected by css_set_lock and tsk->alloc_lock */
    struct list_head cg_list;
#endif

    /* ... 省略无关定义 */
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

## 2.4 docker与cgroup

**2种`cgroup`驱动**

1. `system cgroup driver`
1. `cgroupfs cgroup driver`

## 2.5 kubernetes与cgroup

在k8s中，以pod为单位进行资源限制（充分利用了`cgroup`的`hierarchy`），对应的目录为`/sys/fs/cgroup/<resource type>/kubepods.slice`

## 2.6 cgroup相关命令行工具

```sh
yum install -y libcgroup libcgroup-tools
```

## 2.7 参考

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

本小结转载自[Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)

## 3.1 概述

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

## 3.3 文件格式

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
* `PrivateTmp`：是否拥有私有的`/tmp`目录

**`[Install]`区块，定义如何安装这个配置文件，即怎样做到开机启动**

* `WantedBy`：表示该配置所在的`Target`
* `Target`的含义是服务组，表示一组服务。`WantedBy=multi-user.target`指的是，`sshd`所在的`Target`是`multi-user.target`。这个设置非常重要，因为执行`systemctl enable sshd.service`命令时，`sshd.service`的一个符号链接，就会放在`/etc/systemd/system`目录下面的`multi-user.target.wants`子目录之中

完整的配置项清单参考[systemd.unit — Unit configuration](https://www.freedesktop.org/software/systemd/man/systemd.unit.html)

## 3.4 命令行工具

**systemctl命令行工具**

* `systemctl start xxx.service`：启动xxx服务
* `systemctl stop xxx.service`：停止xxx服务
* `systemctl enable xxx.service`：允许xxx服务开机自启动
* `systemctl disable xxx.service`：进制xxx服务开机自启动
* `systemctl status xxx.service`：查看xxx服务的状态
* `systemctl restart xxx.service`：重新启动xxx服务
* `systemctl reload xxx.service`：让xxx服务重新加载配置文件（如果有的话）
* `systemctl list-units --type=service`：列出所有的服务
* `systemctl daemon-reload`：重新加载`systemd`的配置文件，当我们修改了`/usr/lib/systemd/system/`目录下的文件时，我们需要使用这个命令来使修改生效
* `systemctl show xxx.service`
* `systemctl show xxx.service --property=ActiveState`：查看服务的某个属性
* **`systemctl set-default xxx.target`：设置系统的启动级别，常用的有`multi-user.target`、`graphical.target`。与`CentOS 6.x`的`run level`类似**
    * `poweroff.target`：对应`level-0`
    * `rescue.target`：对应`level-1`
    * `multi-user.target`：对应`level-2/3/4`
    * `graphical.target`：对应`level-5`
    * `reboot.target`：对应`level-6`
* **`systemctl get-default`：查看系统的启动级别**

**journalctl命令行工具**

* `journalctl -u xxx.service`：查看xxx服务的日志

## 3.5 demo

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
[root@localhost ~]$ gcc -o demo-service demo-service.c

# 启动demo-service
[root@localhost ~]$ systemctl start demo-service.service

# 查看demo-service的运行状态
[root@localhost ~]$ systemctl status demo-service.service
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
[root@localhost ~]$ systemctl reload demo-service.service
# 查看日志文件
[root@localhost ~]$ cat /root/default.log
#-------------------------↓↓↓↓↓↓-------------------------
捕获信号 1, 重新加载配置文件
#-------------------------↑↑↑↑↑↑-------------------------

# 停止服务
[root@localhost ~]$ systemctl stop demo-service.service
#-------------------------↓↓↓↓↓↓-------------------------
捕获信号 1, 重新加载配置文件
捕获信号 15, 退出进程
#-------------------------↑↑↑↑↑↑-------------------------
```

## 3.6 参考

* [Systemd 入门教程：命令篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html)
* [Systemd 入门教程：实战篇](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)
* [最简明扼要的 Systemd 教程，只需十分钟](https://blog.csdn.net/weixin_37766296/article/details/80192633)
* [systemd添加自定义系统服务设置自定义开机启动](https://www.cnblogs.com/wjb10000/p/5566801.html)
* [systemd创建自定义服务(Ubuntu)](https://www.cnblogs.com/wintersoft/p/9937839.html)
* [Use systemd to Start a Linux Service at Boot](https://www.linode.com/docs/quick-answers/linux/start-service-at-boot/)
* [Play With Container Network Interface](https://arthurchiao.github.io/blog/play-with-container-network-if/)
* [systemd forking vs simple?](https://superuser.com/questions/1274901/systemd-forking-vs-simple)

# 4 中断

## 4.1 参考

* [linux异常处理体系结构](https://www.cnblogs.com/gulan-zmc/p/11604437.html)
* [Linux的中断处理机制 [一] - 数据结构(1)](https://zhuanlan.zhihu.com/p/83709066)
* [Linux的中断处理机制 [二] - 数据结构(2)](https://zhuanlan.zhihu.com/p/85353687)
* [Linux的中断处理机制 [三] - hardirq](https://zhuanlan.zhihu.com/p/85454778)
* [Linux 中断](https://zhuanlan.zhihu.com/p/94788008)
* [Linux 内核中断内幕](https://www.ibm.com/developerworks/cn/linux/l-cn-linuxkernelint/index.html)
* [彻底搞懂异常控制流](https://www.cnblogs.com/niuyourou/p/12097856.html)
* [嵌入式杂谈之中断向量表](https://zhuanlan.zhihu.com/p/125480457)

# 5 动态链接

## 5.1 demo

```sh
cat > sample.c << 'EOF'
#include <stdio.h>
int main(void) {
    printf("Calling the fopen() function...\n");
    FILE *fd = fopen("test.txt","r");
    if (!fd) {
        printf("fopen() returned NULL\n");
        return 1;
    }
    printf("fopen() succeeded\n");
    return 0;
}
EOF
gcc -o sample sample.c

./sample 
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
fopen() returned NULL
#-------------------------↑↑↑↑↑↑-------------------------

touch test.txt
./sample
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
fopen() succeeded
#-------------------------↑↑↑↑↑↑-------------------------

cat > myfopen.c << 'EOF'
#include <stdio.h>
FILE *fopen(const char *path, const char *mode) {
    printf("This is my fopen!\n");
    return NULL;
}
EOF

gcc -Wall -fPIC -shared -o myfopen.so myfopen.c

LD_PRELOAD=./myfopen.so ./sample
#-------------------------↓↓↓↓↓↓-------------------------
Calling the fopen() function...
This is my fopen!
fopen() returned NULL
#-------------------------↑↑↑↑↑↑-------------------------
```

## 5.2 参考

* [Linux hook：Ring3下动态链接库.so函数劫持](https://www.cnblogs.com/reuodut/articles/13723437.html)

