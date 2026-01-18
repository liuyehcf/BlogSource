---
title: Linux-Filepath
date: 2020-08-27 14:11:21
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 /etc Directory

1. `/etc/passwd`: The file contains essential information about the system's user accounts.
    1. `username`
    1. `password`: An `x` or `*` indicates that the encrypted password is stored in `/etc/shadow` for security reasons.
    1. `UID`
    1. `GID`
    1. `UID Info`
    1. `Home Directory`
    1. `Shell`
1. `/etc/redhat-release`: The file contains information about the specific version of Red Hat Enterprise Linux (RHEL) or its derivative that is installed on the system.
1. `/etc/issue`: The file contains a system identification message, typically displayed before the login prompt on a terminal.
1. `/etc/motd`: The file (Message of the Day, motd) is a text file that displays a message to users after they successfully log in to the system.
1. `/etc/update-motd.d`: The directory contains scripts that are used to dynamically generate the message of the day (MOTD) on systems where the MOTD is updated automatically.
1. `/etc/localtime`: The file is a symlink or a copy of a timezone data file that defines the system's local timezone. It can be updated via `timedatectl` or manually.
    * `/usr/share/zoneinfo/<zone_name>`
1. `/etc/timezone`: The file contains the name of the system's time zone in a human-readable format.
1. `/etc/ssl/certs`: The directory is a common location on Unix-like systems that stores SSL/TLS certificates.
1. `/etc/security/limits.conf`: The file is used to set resource limits for users and processes on a Unix-like system.
    * `echo "* soft core unlimited" >> /etc/security/limits.conf`
    * `echo "* hard core unlimited" >> /etc/security/limits.conf`
1. `/etc/rc.local`: The file is a script that is traditionally used to execute commands at the end of the system's boot process. It allows administrators to specify custom startup tasks that are not part of the usual system initialization sequence. Although it is not commonly used on modern Linux systems with systemd, it is still present for backward compatibility on some distributions.
    * `chmod +x /etc/rc.d/rc.local`
    * `chmod +x /etc/rc.local`
    * `systemctl enable rc-local.service`
    * `systemctl start rc-local.service`
    * Append the absolute path of the script that needs to be executed at startup to the end of the `/etc/rc.local` file. There is no need to manually modify the `/etc/rc.d/rc.local` file, as the content of `/etc/rc.local` will automatically be synchronized to `/etc/rc.d/rc.local` after taking effect.

# 2 /sys Directory

The `/sys` directory, also known as `sysfs`, is a virtual filesystem in Linux that exposes kernel information, hardware devices, and drivers in a structured and organized way. It provides a way for user space to interact with kernel components, device drivers, and system hardware. First, check the directory structure of `/sys` using the command `tree -L 1 /sys`. The result is as follows:

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

| Subdirectory | Description |
|:--|:--|
| `/sys/block` | Contains information about block devices (e.g., disks, partitions). Each block device has its own subdirectory with files representing various attributes like size, device type, and status. |
| **`/sys/bus`** | Lists all the buses (e.g., PCI, USB) available on the system. It contains subdirectories for each bus type and exposes information about the devices connected to each bus, as well as drivers for these devices. |
| **`/sys/class`** | Organizes devices into classes based on their type (e.g., `net` for network interfaces, `tty` for terminals). It provides a high-level view of devices regardless of their specific hardware connection, making it easier to interact with them based on their functionality. |
| `/sys/dev` | Exposes information about the devices available on the system. It contains two subdirectories: 1. `char`, character devices (e.g., `/dev/tty`); 2. `block`, block devices (e.g., `/dev/sda`). |
| **`/sys/devices`** | Provides a detailed hierarchy of physical devices connected to the system, organized by their topology (e.g., buses, controllers, hardware addresses). This tree view allows users to see how devices are interconnected. |
| /sys/firmware | Offers information about the firmware on the system (e.g., BIOS, ACPI, EFI). It can also be used to configure certain firmware parameters, depending on hardware support. |
| /sys/fs | Contains information related to filesystem features and types. For example, the `/sys/fs/cgroup/` directory contains information about control groups (cgroups) used for resource management. |
| /sys/hypervisor | Provides information about the hypervisor if the system is running in a virtualized environment. This directory is useful for identifying details about the host and guest operating system. |
| /sys/kernel | Exposes kernel-related parameters and information, such as security settings, module parameters, and control knobs for kernel subsystems (e.g., debugging options). |
| /sys/module | Contains subdirectories for each kernel module currently loaded, showing information about module parameters and usage statistics. |
| /sys/power | Used to control power management features, such as suspend, hibernate, and power states. Writing to files in this directory can trigger power state changes (e.g., putting the system into sleep mode). |

可以看到`/sys`下的目录结构是经过精心设计的：在`/sys/devices`下是所有设备的真实对象，包括如视频卡和以太网卡等真实的设备，也包括`ACPI`等不那么显而易见的真实设备、还有`tty`、`bonding`等纯粹虚拟的设备；在其它目录如`class`、`bus`等中则在分类的目录中含有大量对`/sys/devices`中真实对象引用的符号链接文件

1. `/sys/class`
    * `/sys/class/net`：网卡（包含物理网卡+虚拟网卡的符号链接文件）
    * `/sys/class/dmi/id`：主板相关信息
        * `/sys/class/dmi/id/product_uuid`：主板uuid
1. `/sys/devices`
    * `/sys/devices/virtual/net`：虚拟网卡
    * `/sys/devices/system/cpu/cpu0/cache/`：`Cache`相关的信息，`getconf -a | grep -i cache`也可以查看相关信息

## 2.1 Reference

* [linux 目录/sys 解析](https://blog.csdn.net/zqixiao_09/article/details/50320799)
* [What's the “/sys” directory for?](https://askubuntu.com/questions/720471/whats-the-sys-directory-for)

# 3 /proc Directory

You can view the documentation through `man proc`.

1. `/proc/buddyinfo`: The file provides information about the memory allocator's "buddy system" in the Linux kernel.
    * Order 0: Represents the smallest possible block (a single memory page, usually 4 KB).
    * Higher orders represent blocks that are exponentially larger (order 1 is 2 pages, order 2 is 4 pages, and so on).
    ```
    Node 0, zone      DMA     90      6      2      1      1      ...
    Node 0, zone   Normal   1650    310      5      0      0      ...
    Node 0, zone  HighMem      2      0      0      1      1      ...
    ```

    * Related file: `/proc/sys/vm/compact_memory`、`/proc/sys/vm/drop_caches`
1. `/proc/cmdline`: The file contains the kernel command line arguments passed to the Linux kernel at the time of boot.
1. `/proc/version`: The file contains kernel version.
1. `/proc/cpuinfo`: The file contains detailed information about the CPU(s) in your system.
    * `processor`: The unique ID of the CPU core (starting from 0).
    * `physical id`: Represents the unique identifier for a physical CPU socket on the motherboard.
    * `cpu cores`: Number of physical cores per CPU package.
    * `siblings`: This value represents the total number of logical processors for a given physical CPU.
1. `/proc/meminfo`: The file provides a snapshot of the system's memory usage.
    * `MemTotal`: Total usable RAM (i.e., physical RAM minus some reserved areas used by the kernel).
    * `MemFree`: Amount of RAM that is currently free and not being used at all by the system.
    * **`MemAvailable`: An estimate of how much memory is available for starting new applications, without swapping. It considers both free memory and reclaimable page cache.**
    * `Buffers`: Amount of memory used by the kernel buffers for I/O operations, such as block device caching.
    * `Cached`: Memory used by the page cache and slabs. This memory can be quickly freed if needed.
    * `Slab`: Memory used by the kernel for data structures. It consists of `SReclaimable` and `SUnreclaim`.
        * `SReclaimable`: Part of the slab that can be reclaimed (e.g., inode and dentry caches). Related to `MemAvailable`.
        * `SUnreclaim`: Part of the slab that cannot be reclaimed.
    * `Hugepage{xxx}`: `Hugepage` Related configs.
1. `/proc/zoneinfo`: The file provides detailed information about the memory zones in the Linux kernel's memory management system.
    * `Linux 2.6` began supporting `NUMA, Non-Uniform Memory Access` memory management mode. In multi-CPU systems, memory is divided into different `Nodes` based on CPUs. Each CPU is attached to a `Node`, and accessing its local `Node` is significantly faster than accessing `Nodes` on other CPUs.
    * `numactl -H` can be used to view `NUMA` hardware information.
    * Each `Node` is divided into one or more `Zones`. The reasons for having `Zones` are:
        1. The memory range accessible by `DMA` devices is limited (`ISA` devices can only access `16MB`).
        1. The address space of `x86-32bit` systems is limited (32-bit can only handle up to 4GB). To use more memory, the `HIGHMEM` mechanism is needed.
    * `cat /proc/zoneinfo | grep -E "zone|free |managed"`
1. `/proc/slabinfo`: The file provides detailed information about the kernel's slab allocator, which is used for efficient memory management of small objects in the kernel space. 
1. `/proc/cgroups`: The file provides information about control groups (cgroups) available on the system.
1. `/proc/filesystems`: The file lists all the filesystem types that the kernel currently supports.
1. `/proc/kallsyms`: The file contains the addresses, symbols (names), and types of all kernel functions and variables that are currently loaded.
1. `/proc/kmsg`: The file provides access to the kernel's message buffer, containing messages generated by the kernel. Used by logging daemons (e.g., `dmesg`, `syslogd`) to read kernel messages for system diagnostics and debugging.
1. `/proc/modules`: The file lists all kernel modules that are currently loaded into the kernel. Used by `lsmod`.
1. `/proc/mounts`: A symlink to `/proc/self/mounts`, display all mounted filesystems.
1. `/proc/stat`: The file provides various system statistics since the last boot, including CPU usage, I/O, system interrupts, and context switches.
1. `/proc/softirqs`: The file provides statistics about the number of soft interrupts (softirqs) handled by the kernel.
1. `/proc/interrupts`: The file provides statistics about the interrupts handled by the system, both hardware and software, on a per-CPU basis.
    * The first column of the file represents the interrupt vector number or identifier. 
1. `/proc/irq/<irq>`: The directory contains information and configurations related to a specific interrupt request (IRQ) line in the system.
    * `/proc/irq/<irq>/smp_affinity`: Controls which CPU cores are allowed to handle this IRQ using a mask format.
    * `/proc/irq/<irq>/smp_affinity_list`: Similar to smp_affinity, but specifies CPU affinity using a list format.
1. `/proc/loadavg`: The file provides information about the system's load average, which represents the average system load over different periods of time.
    * `1-minute`, `5-minute`, and `15-minute` load averages: Three numbers indicating the average system load over the past 1, 5, and 15 minutes.
    * The meaning of `cpu load`: the number of processes that are either executing or waiting to execute. In the kernel code (`3.10.x`), the method to calculate `cpu load` is `spu_calc_load`.
    * `cpu_load = α * cpu_load + (1 - α) * active_task_size`. `cpu_load` is related to both its previous value and the current number of active processes. The value of `α` varies in the cases of 1 minute, 5 minutes, and 15 minutes.
1. `/proc/self`: The directory is a symbolic link that points to the /proc directory of the currently running process that is accessing it.
1. `/proc/sys/net`: The directory contains files and subdirectories that allow you to view and configure various networking parameters in the Linux kernel. It provides control over network behavior, such as IP configuration, TCP settings, and firewall rules.
1. `/proc/sys/kernel`: The directory contains files and settings that allow you to view and configure various kernel parameters, affecting the system's behavior and operation.
    * `/proc/sys/kernel/core_pattern`: The file defines the pattern used to name core dump files created when a process crashes.
    * `/proc/sys/kernel/yama/ptrace_scope`: The file controls the `ptrace` system call, which is used for debugging processes.
        * `0 - classic ptrace permissions`: No restrictions; any process can trace any other process (default behavior).
        * `1 - restricted ptrace`: Only child processes can be traced. This is the default on many modern Linux distributions.
        * `2 - admin-only attach`: Restricted; only processes with a specific ptrace relationship (using `ptrace_attach`) or capabilities (`CAP_SYS_PTRACE`) can trace.
        * `3 - no attach`: No process may be traced, even by privileged processes, unless exceptions are explicitly allowed.
    * `/proc/sys/kernel/random/uuid`: The file provides a simple interface to generate random UUIDs.
1. `/proc/sys/fs`: The directory contains files and subdirectories related to filesystem settings and limits.
    * `/proc/sys/fs/file-max`: The maximum number of file handles that the kernel can allocate.
    * `/proc/sys/fs/inode-max`: The maximum number of inodes (filesystem objects like files and directories) that the kernel can allocate.
    * `/proc/sys/fs/nr_open`: The maximum number of file descriptors a single process can open.
    * `/proc/sys/fs/file-nr`: Displays the number of allocated file handles and the maximum limit.
        * First column (allocated): The number of file handles that the kernel has currently allocated. This value includes both open file handles and reserved but not currently used handles.
        * Second column (unused): The number of file handles that are currently allocated but are not being used. This can be seen as "spare" file handles that the kernel can reuse for new file operations without needing to allocate more.
        * Third column (maximum): The maximum number of file handles that the kernel can allocate. This limit is set by the `/proc/sys/fs/file-max` parameter and represents the upper limit on file handles available to the system.
    * `/proc/sys/fs/aio-max-nr`
    * `/proc/sys/fs/mount-max`
1. `/proc/net`: A symlink to `/proc/self/net`.
    * `/proc/net/route`
    * `/proc/net/arp`: Mac address.
    * `/proc/net/sockstat`
    * `/proc/net/tcp`
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
        ```sh
        cat /proc/net/tcp | awk 'BEGIN {
            split("ESTABLISHED SYN_SENT SYN_RECV FIN_WAIT1 FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT LAST_ACK LISTEN CLOSING", s, " ")
            for(i=1;i<=11;i++) state[sprintf("%02X", i)] = s[i]
        }
        {
            split($2, la, ":"); split($3, ra, ":")
            li=sprintf("%d.%d.%d.%d", strtonum("0x" substr(la[1],7,2)), strtonum("0x" substr(la[1],5,2)), strtonum("0x" substr(la[1],3,2)), strtonum("0x" substr(la[1],1,2)))
            lp=strtonum("0x" la[2])
            ri=sprintf("%d.%d.%d.%d", strtonum("0x" substr(ra[1],7,2)), strtonum("0x" substr(ra[1],5,2)), strtonum("0x" substr(ra[1],3,2)), strtonum("0x" substr(ra[1],1,2)))
            rp=strtonum("0x" ra[2])
            st=state[$4]
            txq=strtonum("0x" substr($5,1,8))
            rxq=strtonum("0x" substr($5,10,8))
            tr=strtonum("0x" $6)
            tm_when=strtonum("0x" $7)
            retrnsmt=strtonum("0x" $8)
            uid=$8
            inode=$10
            printf "%s:%d -> %s:%d State:%s TX:%d RX:%d TR:%d TM:%d RETR:%d UID:%s Inode:%s\n", li,lp,ri,rp,st,txq,rxq,tr,tm_when,retrnsmt,uid,inode
        }'
        ```

    * `/proc/net/tcp6`
        ```sh
        cat /proc/net/tcp6 | awk 'BEGIN {
            split("ESTABLISHED SYN_SENT SYN_RECV FIN_WAIT1 FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT LAST_ACK LISTEN CLOSING", s, " ")
            for(i=1;i<=11;i++) state[sprintf("%02X", i)] = s[i]
        }
        function hex_to_ipv6(hex) {
            addr = ""
            for(i=0;i<32;i+=4) {
                addr = addr sprintf("%s%s", addr==""?"":"", substr(hex,i+1,4))
                if(i<28) addr = addr ":"
            }
            return addr
        }
        {
            split($2, la, ":"); split($3, ra, ":")
            li = hex_to_ipv6(la[1])
            lp = strtonum("0x" la[2])
            ri = hex_to_ipv6(ra[1])
            rp = strtonum("0x" ra[2])
            st = state[$4]
            txq = strtonum("0x" substr($5,1,8))
            rxq = strtonum("0x" substr($5,10,8))
            tr = strtonum("0x" $6)
            tm_when = strtonum("0x" $7)
            retrnsmt = strtonum("0x" $8)
            uid = $8
            inode = $10
            printf "%s:%d -> %s:%d State:%s TX:%d RX:%d TR:%d TM:%d RETR:%d UID:%s Inode:%s\n", li,lp,ri,rp,st,txq,rxq,tr,tm_when,retrnsmt,uid,inode
        }'
        ```

1. `/proc/<pid>`: The directory contains information about each running process on the system.
    * `/proc/<pid>/status`: The file contains detailed information about a specific process's status. It provides a snapshot of the process's attributes, including memory usage, CPU utilization, and process state. The data is presented in a human-readable format, making it useful for system monitoring and debugging.
        * `VmPeak`: Peak Virtual Memory Size.
        * `VmSize`: Virtual Memory Size.
        * `VmHWM`: The peak amount of physical memory (RAM) that the process has used at any point.
        * `VmRSS`: The current amount of physical memory (RAM) the process is using.
        * `Threads`: The number of threads currently running within the process.
        ```cpp
        #include <fstream>
        #include <iostream>
        #include <vector>

        void print_rss() {
            std::ifstream ifs("/proc/self/status");
            std::string line;
            std::cout << "Part of /proc/self/status: " << std::endl;
            while (std::getline(ifs, line)) {
                if (line.find("Vm") != std::string::npos) {
                    std::cout << line << std::endl;
                }
            }
            std::cout << std::endl;
        }

        int main() {
            std::vector<int> v;
            print_rss();
            v.reserve(1000000000);
            print_rss();
            v.resize(1000000000);
            print_rss();
        }       
        ```

    * `/proc/<pid>/smaps_rollup`: Memory mappings with statistics
        * Referenced: The amount of memory in this mapping that has been recently accessed (i.e., referenced) by the process, which is also called `WSS`(Working Set Size).
    * **`/proc/<pid>/net`: Does not only list network information related to that process, but all the network information in the network namespace which that process belongs to.**
        * `/proc/pid>/net/tcp`
            * Display all listening addresses for a given pid:
                ```sh
                pid=${pid:-1}
                while IFS= read -r inode; do
                    # begin brace must be placed at one line with condition expression
                    cat /proc/net/tcp | awk -v inode="$inode" '$10 == inode && $4 == "0A" {
                        # Split local address into IP and port
                        split($2, arr, ":");
                        ip_hex = arr[1];
                        port_hex = arr[2];

                        # Convert IP from hex to dotted decimal format
                        ipv4 = sprintf("%d.%d.%d.%d",
                            strtonum("0x" substr(ip_hex, 7, 2)),
                            strtonum("0x" substr(ip_hex, 5, 2)),
                            strtonum("0x" substr(ip_hex, 3, 2)),
                            strtonum("0x" substr(ip_hex, 1, 2)));

                        # Convert port from hex to decimal
                        port = strtonum("0x" port_hex);

                        # Print IP:port
                        print ipv4 ":" port;
                    }'
                done < <(ls -l /proc/${pid}/fd | grep 'socket:' | awk -F'[][]' '{print $2}')
                ```

            * Disply all tcp connections of a given pid:
                ```sh
                pid=${pid:-1}
                while IFS= read -r inode; do
                    cat /proc/net/tcp | awk -v inode="$inode" 'BEGIN {
                        split("ESTABLISHED SYN_SENT SYN_RECV FIN_WAIT1 FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT LAST_ACK LISTEN CLOSING", s, " ")
                        for(i=1;i<=11;i++) state[sprintf("%02X", i)] = s[i]
                    }
                    # begin brace must be placed at one line with condition expression
                    $10 == inode {
                        split($2, la, ":"); split($3, ra, ":")
                        li=sprintf("%d.%d.%d.%d", strtonum("0x" substr(la[1],7,2)), strtonum("0x" substr(la[1],5,2)), strtonum("0x" substr(la[1],3,2)), strtonum("0x" substr(la[1],1,2)))
                        lp=strtonum("0x" la[2])
                        ri=sprintf("%d.%d.%d.%d", strtonum("0x" substr(ra[1],7,2)), strtonum("0x" substr(ra[1],5,2)), strtonum("0x" substr(ra[1],3,2)), strtonum("0x" substr(ra[1],1,2)))
                        rp=strtonum("0x" ra[2])
                        st=state[$4]
                        txq=strtonum("0x" substr($5,1,8))
                        rxq=strtonum("0x" substr($5,10,8))
                        tr=strtonum("0x" $6)
                        tm_when=strtonum("0x" $7)
                        retrnsmt=strtonum("0x" $8)
                        uid=$8
                        printf "%s:%d -> %s:%d State:%s TX:%d RX:%d TR:%d TM:%d RETR:%d UID:%s Inode:%s\n", li,lp,ri,rp,st,txq,rxq,tr,tm_when,retrnsmt,uid,inode
                    }'
                done < <(ls -l /proc/${pid}/fd | grep 'socket:' | awk -F'[][]' '{print $2}')
                ```

        * `/proc/pid>/net/tcp6`
            * Display all listening addresses for a given pid:
                ```sh
                pid=${pid:-1}
                while IFS= read -r inode; do
                    # begin brace must be placed at one line with condition expression
                    cat /proc/net/tcp6 | awk -v inode="$inode" '$10 == inode && $4 == "0A" {
                        # Split local address into IP and port
                        split($2, arr, ":");
                        ip_hex = arr[1];
                        port_hex = arr[2];

                        # Convert IP from hex to dotted decimal format
                        ipv6 = sprintf("%x:%x:%x:%x:%x:%x:%x:%x",
                            strtonum("0x" substr(ip_hex, 1, 4)),
                            strtonum("0x" substr(ip_hex, 5, 4)),
                            strtonum("0x" substr(ip_hex, 9, 4)),
                            strtonum("0x" substr(ip_hex, 13, 4)),
                            strtonum("0x" substr(ip_hex, 17, 4)),
                            strtonum("0x" substr(ip_hex, 21, 4)),
                            strtonum("0x" substr(ip_hex, 25, 4)),
                            strtonum("0x" substr(ip_hex, 29, 4)));

                        # Convert port from hex to decimal
                        port = strtonum("0x" port_hex);

                        # Print IP:port
                        print ipv6 ":" port;
                    }'
                done < <(ls -l /proc/${pid}/fd | grep 'socket:' | awk -F'[][]' '{print $2}')
                ```

            * Disply all tcp connections of a given pid:
                ```sh
                pid=${pid:-1}
                while IFS= read -r inode; do
                    cat /proc/net/tcp | awk -v inode="$inode" 'BEGIN {
                        split("ESTABLISHED SYN_SENT SYN_RECV FIN_WAIT1 FIN_WAIT2 TIME_WAIT CLOSE CLOSE_WAIT LAST_ACK LISTEN CLOSING", s, " ")
                        for(i=1;i<=11;i++) state[sprintf("%02X", i)] = s[i]
                    }
                    function hex_to_ipv6(hex) {
                        addr = ""
                        for(i=0;i<32;i+=4) {
                            addr = addr sprintf("%s%s", addr==""?"":"", substr(hex,i+1,4))
                            if(i<28) addr = addr ":"
                        }
                        return addr
                    }
                    # begin brace must be placed at one line with condition expression
                    $10 == inode {
                        split($2, la, ":"); split($3, ra, ":")
                        li = hex_to_ipv6(la[1])
                        lp = strtonum("0x" la[2])
                        ri = hex_to_ipv6(ra[1])
                        rp = strtonum("0x" ra[2])
                        st = state[$4]
                        txq = strtonum("0x" substr($5,1,8))
                        rxq = strtonum("0x" substr($5,10,8))
                        tr = strtonum("0x" $6)
                        tm_when = strtonum("0x" $7)
                        retrnsmt = strtonum("0x" $8)
                        uid = $8
                        printf "%s:%d -> %s:%d State:%s TX:%d RX:%d TR:%d TM:%d RETR:%d UID:%s Inode:%s\n", li,lp,ri,rp,st,txq,rxq,tr,tm_when,retrnsmt,uid,inode
                    }'
                done < <(ls -l /proc/${pid}/fd | grep 'socket:' | awk -F'[][]' '{print $2}')
                ```

    * `/proc/<pid>/maps`: The file provides a detailed view of the memory regions used by a specific process (`<pid>`).
    * `/proc/<pid>/smaps`: The file provides a more detailed breakdown of the memory usage for each memory region of a specific process (`<pid>`). It extends the information found in `/proc/<pid>/maps` with detailed statistics about the memory consumption and attributes of each region, making it valuable for in-depth memory analysis.
    * `/proc/<pid>/fd/`: The directory contains symbolic links to the file descriptors opened by the process with the specified process ID (`<pid>`). Each file descriptor (`FD`) is represented by a numbered entry (e.g., `0`, `1`, `2`, etc.) within this directory.
        * `socket` type, for example, `/proc/6497/fd/1018 -> socket:[42446535]`
            * To determine the socket creation time, check the creation time of `/proc/6497/fd/1018`.
            * What does the number inside the brackets mean? It represents the `inode` number, and you can view the detailed information of the corresponding `socket` using `ss -nap -e | grep 42446535`.
    * `/proc/<pid>/limits`: The file provides information about the resource limits set for the process with the specified process ID (`<pid>`).
    * `/proc/<pid>/environ`: The file contains the environment variables for the process with the specified process ID (`<pid>`).
        * `cat /proc/<pid>/environ | tr '\0' '\n'`
    * `/proc/<pid>/cwd`: The file is a symbolic link that points to the current working directory of the process identified by process ID (`<pid>`).

## 3.1 Reference

* [How is CPU usage calculated?](https://stackoverflow.com/questions/3748136/how-is-cpu-usage-calculated)
* [Linux内存管理 -- /proc/{pid}/smaps讲解](https://www.jianshu.com/p/8203457a11cc)

# 4 /var Directory

1. `/var/crash`: is the directory where Linux systems store crash dump files and related reports generated when programs or the kernel crash, useful for post-mortem debugging and analysis.
1. `/var/log`
    * `/var/log/audit`: is the directory where the Linux Audit framework stores logs (typically via auditd), recording detailed security-related events such as system calls, file access, permission changes, and user actions for auditing and compliance purposes.
    * `/var/log/syslog`: a general-purpose system log file that records messages from the kernel, system services, and user-space applications for troubleshooting and monitoring.

## 4.1 Reference

* [Differences in /var/log/{syslog,dmesg,messages} log files](https://superuser.com/questions/565927/differences-in-var-log-syslog-dmesg-messages-log-files)

# 5 /dev Directory

1. `/dev/disk/by-path`: The directory contains symbolic links to disk devices based on their physical or logical path on the system.
1. `/dev/disk/by-partuuid`: The directory contains symbolic links to partitions on storage devices based on their Partition UUIDs (PARTUUIDs).
1. `/dev/disk/by-uuid`: The directory contains symbolic links to storage device partitions, identified by their UUIDs (Universally Unique Identifiers).
1. `/dev/disk/by-partlabel`: The directory contains symbolic links to partitions on storage devices identified by their partition labels.
1. `/dev/disk/by-id`: The directory contains symbolic links to storage devices based on their unique hardware identifiers.
1. `/dev/tty`: is a special file in Unix-like operating systems that represents the controlling terminal for the current process. In other words, it is a reference to the terminal device (such as a command-line interface) that is currently interacting with the user.
1. `/dev/kmsg`: is a kernel message interface in Linux. It provides direct, structured access to the kernel log buffer, and it is the modern replacement / complement to the legacy `/proc/kmsg`.
    * Add some log to dmesg: `echo "<6>TEST dmesg timestamp check: $(date -Ins)" | sudo tee /dev/kmsg >/dev/null`
