---
title: Linux-定制发行版
date: 2019-11-23 14:19:39
top: true
tags: 
- 原创
categories: 
- Operating System
---

**阅读更多**

<!--more-->

# 1 镜像站

## 1.1 [网易开源镜像站](http://mirrors.163.com)

以`CentOS-7.7.1908`为例，下载地址为：`http://mirrors.163.com/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-Minimal-1908.iso`

## 1.2 [centos镜像站](http://mirror.centos.org/)

以`CentOS-7.7.1908`为例，下载地址列表为：`http://isoredirect.centos.org/centos/7.7.1908/isos/x86_64/`

# 2 CentOS装机

**博主安装的是minimal版本**

1. 配网，修改`/etc/sysconfig/network-scripts/ifcfg-enp0s3`，将`ONBOOT`修改为`yes`，然后执行`systemctl restart network`
1. 安装网络工具包`yum install -y net-tools.x86_64`
1. 安装vim`yum install -y vim`

## 2.1 配置分区容量

默认情况下，CentOS会给根分区分配50G的容量，剩余容量则分配给home分区，我们可以通过一组命令简单得调整一下分区容量

**仍然保留两个分区，将大部分的容量都分配给根分区**

```sh
# 1/11: 备份home分区文件
tar cvf /tmp/home.tar /home

# 2/11: 安装 psmisc（fuser）
yum install -y psmisc

# 3/11: 杀死所有占用/home目录的进程
fuser -km /home/

# 4/11: 卸载/home文件系统
umount /home

# 5/11: 删除/home所在的lv
lvremove /dev/mapper/centos-home

# 6/11: 扩展/root所在的lv
lvextend -L +320G /dev/mapper/centos-root

# 7/11: 扩展/root文件系统
xfs_growfs /dev/mapper/centos-root

# 8/11: 创建一个1G的home LV，然后再将所有的空闲分区追加到home LV
lvcreate -L 1G -n /dev/mapper/centos-home
lvextend -l +100%FREE /dev/mapper/centos-home

# 9/11: 创建home文件系统
mkfs.xfs  /dev/mapper/centos-home

# 10/11: 挂载home文件系统
mount /dev/mapper/centos-home

# 11/11: 恢复home文件系统
tar xvf /tmp/home.tar -C /home/
cd /home/home/
mv * ../
```

**只保留根分区，/home只作为根分区的一个目录**

```sh
# 1/9: 备份home分区文件
tar cvf /tmp/home.tar /home

# 2/9: 安装 psmisc（fuser）
yum install -y psmisc

# 3/9: 杀死所有占用/home目录的进程
fuser -km /home/

# 4/9: 卸载/home文件系统
umount /home

# 5/9: 删除/home所在的lv
lvremove /dev/mapper/centos-home

# 6/9: 扩展/root所在的lv
lvextend -l +100%FREE /dev/mapper/centos-root

# 7/9: 扩展/root文件系统
xfs_growfs /dev/mapper/centos-root

# 8/9: 恢复home文件系统
tar -xvf /tmp/home.tar -C /

# 9/9: 删除home分区记录
vim /etc/fstab
```

## 2.2 添加硬盘以及扩容LVM

### 2.2.1 fdisk

```sh
[root@liuyehcf ~]$ fdisk -l
#-------------------------↓↓↓↓↓↓-------------------------
磁盘 /dev/sda：11.9 GB, 11913920512 字节，23269376 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000b1653

   设备 Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    23269375    10585088   8e  Linux LVM

磁盘 /dev/sdb：8589 MB, 8589934592 字节，16777216 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

磁盘 /dev/mapper/centos-root：9642 MB, 9642704896 字节，18833408 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

磁盘 /dev/mapper/centos-swap：1191 MB, 1191182336 字节，2326528 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
#-------------------------↑↑↑↑↑↑-------------------------

[root@liuyehcf ~]$ fdisk /dev/sdb
#-------------------------↓↓↓↓↓↓-------------------------
欢迎使用 fdisk (util-linux 2.23.2)。

更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。

Device does not contain a recognized partition table
使用磁盘标识符 0xdc61f516 创建新的 DOS 磁盘标签。
#-------------------------↑↑↑↑↑↑-------------------------

命令(输入 m 获取帮助)：m
#-------------------------↓↓↓↓↓↓-------------------------
命令操作
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partitions system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)
#-------------------------↑↑↑↑↑↑-------------------------

命令(输入 m 获取帮助)：n
#-------------------------↓↓↓↓↓↓-------------------------
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
#-------------------------↑↑↑↑↑↑-------------------------

Select (default p): p
分区号 (1-4，默认 1)：# 回车，默认值
起始 扇区 (2048-16777215，默认为 2048)：# 回车，默认值
#-------------------------↓↓↓↓↓↓-------------------------
将使用默认值 2048
#-------------------------↑↑↑↑↑↑-------------------------

Last 扇区, +扇区 or +size{K,M,G} (2048-16777215，默认为 16777215)：# 回车，默认值
#-------------------------↓↓↓↓↓↓-------------------------
将使用默认值 16777215
分区 1 已设置为 Linux 类型，大小设为 8 GiB
#-------------------------↑↑↑↑↑↑-------------------------

命令(输入 m 获取帮助)：t
#-------------------------↓↓↓↓↓↓-------------------------
已选择分区 1
#-------------------------↑↑↑↑↑↑-------------------------

Hex 代码(输入 L 列出所有代码)：L
#-------------------------↓↓↓↓↓↓-------------------------
 0  空              24  NEC DOS         81  Minix / 旧 Linu bf  Solaris
 1  FAT12           27  隐藏的 NTFS Win 82  Linux 交换 / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 隐藏的 C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux 扩展      c7  Syrinx
 5  扩展            41  PPC PReP Boot   86  NTFS 卷集       da  非文件系统数据
 6  FAT16           42  SFS             87  NTFS 卷集       db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux 纯文本    de  Dell 工具
 8  AIX             4e  QNX4.x 第2部分  8e  Linux LVM       df  BootIt
 9  AIX 可启动      4f  QNX4.x 第3部分  93  Amoeba          e1  DOS 访问
 a  OS/2 启动管理器 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad 休 eb  BeOS fs
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT
 f  W95 扩展 (LBA)  54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC
11  隐藏的 FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor
12  Compaq 诊断     5c  Priam Edisk     a9  NetBSD          f4  SpeedStor
14  隐藏的 FAT16 <3 61  SpeedStor       ab  Darwin 启动     f2  DOS 次要
16  隐藏的 FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS
17  隐藏的 HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
18  AST 智能睡眠    65  Novell Netware  b8  BSDI swap       fd  Linux raid 自动
1b  隐藏的 W95 FAT3 70  DiskSecure 多启 bb  Boot Wizard 隐  fe  LANstep
1c  隐藏的 W95 FAT3 75  PC/IX           be  Solaris 启动    ff  BBT
1e  隐藏的 W95 FAT1 80  旧 Minix
#-------------------------↑↑↑↑↑↑-------------------------

Hex 代码(输入 L 列出所有代码)：8e
#-------------------------↓↓↓↓↓↓-------------------------
已将分区“Linux”的类型更改为“Linux LVM”
#-------------------------↑↑↑↑↑↑-------------------------

命令(输入 m 获取帮助)：w
#-------------------------↓↓↓↓↓↓-------------------------
The partition table has been altered!

Calling ioctl() to re-read partition table.
正在同步磁盘。
#-------------------------↑↑↑↑↑↑-------------------------

# 重新读取分区表
[root@liuyehcf ~]$ partprobe
[root@liuyehcf ~]$ fdisk -l
#-------------------------↓↓↓↓↓↓-------------------------
磁盘 /dev/sda：11.9 GB, 11913920512 字节，23269376 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000b1653

   设备 Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    23269375    10585088   8e  Linux LVM

磁盘 /dev/sdb：8589 MB, 8589934592 字节，16777216 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0xd1a484e2

   设备 Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048    16777215     8387584   8e  Linux LVM

磁盘 /dev/mapper/centos-root：9642 MB, 9642704896 字节，18833408 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

磁盘 /dev/mapper/centos-swap：1191 MB, 1191182336 字节，2326528 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
#-------------------------↑↑↑↑↑↑-------------------------

# 查看当前pv
[root@liuyehcf ~]$ pvdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               10.09 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              2584
  Free PE               1
  Allocated PE          2583
  PV UUID               R2tmMS-2sUX-cKKu-A3JN-frjv-11hs-zAIOt7
#-------------------------↑↑↑↑↑↑-------------------------

# 创建pv
[root@liuyehcf ~]$ pvcreate /dev/sdb1
#-------------------------↓↓↓↓↓↓-------------------------
  Physical volume "/dev/sdb1" successfully created.
#-------------------------↑↑↑↑↑↑-------------------------

# 再次查看pv
[root@liuyehcf ~]$ pvdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               10.09 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              2584
  Free PE               1
  Allocated PE          2583
  PV UUID               R2tmMS-2sUX-cKKu-A3JN-frjv-11hs-zAIOt7

  "/dev/sdb1" is a new physical volume of "<8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               <8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               1KFdOD-iwWF-w7uy-vOwp-CxKh-X2nj-wlZXqL
#-------------------------↑↑↑↑↑↑-------------------------

# 查看卷组（volume group）
[root@liuyehcf ~]$ vgdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               10.09 GiB
  PE Size               4.00 MiB
  Total PE              2584
  Alloc PE / Size       2583 / <10.09 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               dgAwma-p7HF-cIKR-07w9-smjU-twhD-cXGeWy
#-------------------------↑↑↑↑↑↑-------------------------

# 将新的pv加入 centos 卷组
[root@liuyehcf ~]$ vgextend centos /dev/sdb1
#-------------------------↓↓↓↓↓↓-------------------------
  Volume group "centos" successfully extended
#-------------------------↑↑↑↑↑↑-------------------------

# 再次查看卷组，可以看到free PE有8G
[root@liuyehcf ~]$ vgdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <18.09 GiB
  PE Size               4.00 MiB
  Total PE              4631
  Alloc PE / Size       2583 / <10.09 GiB
  Free  PE / Size       2048 / 8.00 GiB
  VG UUID               dgAwma-p7HF-cIKR-07w9-smjU-twhD-cXGeWy
#-------------------------↑↑↑↑↑↑-------------------------

# 将当前卷组中剩余 P E添加到 centos-root 中
[root@liuyehcf ~]$ lvextend -l +100%FREE /dev/mapper/centos-root

# 扩展centos-root文件系统
[root@liuyehcf ~]$ xfs_growfs /dev/mapper/centos-root
#-------------------------↓↓↓↓↓↓-------------------------
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=588544 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=2354176, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 2354176 to 4451328
#-------------------------↑↑↑↑↑↑-------------------------
```

### 2.2.2 parted

`fdisk`最多只能添加容量小于2TB的硬盘，当需要添加大于2TB容量的硬盘时，需要使用`parted`

```sh
[root@liuyehcf ~]$ fdisk -l
#-------------------------↓↓↓↓↓↓-------------------------
磁盘 /dev/sda：11.9 GB, 11913920512 字节，23269376 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000b1653

   设备 Boot      Start         End      Blocks   Id  System
/dev/sda1   *        2048     2099199     1048576   83  Linux
/dev/sda2         2099200    23269375    10585088   8e  Linux LVM

磁盘 /dev/sdb：8589 MB, 8589934592 字节，16777216 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

磁盘 /dev/mapper/centos-root：9642 MB, 9642704896 字节，18833408 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节

磁盘 /dev/mapper/centos-swap：1191 MB, 1191182336 字节，2326528 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
#-------------------------↑↑↑↑↑↑-------------------------

[root@liuyehcf ~]$ parted /dev/sdb
#-------------------------↓↓↓↓↓↓-------------------------
GNU Parted 3.1
使用 /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
#-------------------------↑↑↑↑↑↑-------------------------

(parted) help
#-------------------------↓↓↓↓↓↓-------------------------
  align-check TYPE N                        check partition N for TYPE(min|opt) alignment
  help [COMMAND]                           print general help, or help on COMMAND
  mklabel,mktable LABEL-TYPE               create a new disklabel (partition table)
  mkpart PART-TYPE [FS-TYPE] START END     make a partition
  name NUMBER NAME                         name partition NUMBER as NAME
  print [devices|free|list,all|NUMBER]     display the partition table, available devices, free space, all found partitions, or a particular partition
  quit                                     exit program
  rescue START END                         rescue a lost partition near START and END

  resizepart NUMBER END                    resize partition NUMBER
  rm NUMBER                                delete partition NUMBER
  select DEVICE                            choose the device to edit
  disk_set FLAG STATE                      change the FLAG on selected device
  disk_toggle [FLAG]                       toggle the state of FLAG on selected device
  set NUMBER FLAG STATE                    change the FLAG on partition NUMBER
  toggle [NUMBER [FLAG]]                   toggle the state of FLAG on partition NUMBER
  unit UNIT                                set the default unit to UNIT
  version                                  display the version number and copyright information of GNU Parted
#-------------------------↑↑↑↑↑↑-------------------------

(parted) mklabel gpt
(parted) unit MB
(parted) mkpart primary 0.00MB 8589.00MB
#-------------------------↓↓↓↓↓↓-------------------------
警告: The resulting partition is not properly aligned for best performance.
#-------------------------↑↑↑↑↑↑-------------------------
忽略/Ignore/放弃/Cancel? ignore

(parted) print
#-------------------------↓↓↓↓↓↓-------------------------
Model: ATA VBOX HARDDISK (scsi)
Disk /dev/sdb: 8590MB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags:

Number  Start   End     Size    File system  Name     标志
 1      0.02MB  8589MB  8589MB               primary
#-------------------------↑↑↑↑↑↑-------------------------

(parted) quit
#-------------------------↓↓↓↓↓↓-------------------------
信息: You may need to update /etc/fstab.
#-------------------------↑↑↑↑↑↑-------------------------

# 磁盘格式化
[root@liuyehcf ~]$ mkfs.xfs /dev/sdb1
#-------------------------↓↓↓↓↓↓-------------------------
meta-data=/dev/sdb1              isize=512    agcount=4, agsize=524230 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2096919, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
#-------------------------↑↑↑↑↑↑-------------------------

# 查看物理卷
[root@liuyehcf ~]$ pvdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               10.09 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              2584
  Free PE               1
  Allocated PE          2583
  PV UUID               R2tmMS-2sUX-cKKu-A3JN-frjv-11hs-zAIOt7
#-------------------------↑↑↑↑↑↑-------------------------

# 创建物理卷
[root@liuyehcf ~]$ pvcreate /dev/sdb1
WARNING: xfs signature detected on /dev/sdb1 at offset 0. Wipe it? [y/n]: y
#-------------------------↓↓↓↓↓↓-------------------------
  Wiping xfs signature on /dev/sdb1.
  Physical volume "/dev/sdb1" successfully created.
#-------------------------↑↑↑↑↑↑-------------------------

# 查看物理卷，发现多了个 /dev/sdb1
[root@liuyehcf ~]$ pvdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               centos
  PV Size               10.09 GiB / not usable 0
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              2584
  Free PE               1
  Allocated PE          2583
  PV UUID               R2tmMS-2sUX-cKKu-A3JN-frjv-11hs-zAIOt7

  "/dev/sdb1" is a new physical volume of "<8.00 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb1
  VG Name
  PV Size               <8.00 GiB
  Allocatable           NO
  PE Size               0
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               cBcZHS-RiCM-OElU-1l7g-fQfT-sazO-yd0eg3
#-------------------------↑↑↑↑↑↑-------------------------

# 查看卷组
[root@liuyehcf ~]$ vgdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               10.09 GiB
  PE Size               4.00 MiB
  Total PE              2584
  Alloc PE / Size       2583 / <10.09 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               dgAwma-p7HF-cIKR-07w9-smjU-twhD-cXGeWy
  #-------------------------↑↑↑↑↑↑-------------------------

# 将新的pv加入 centos 卷组
[root@liuyehcf ~]$ vgextend centos /dev/sdb1
#-------------------------↓↓↓↓↓↓-------------------------
  Volume group "centos" successfully extended
#-------------------------↑↑↑↑↑↑-------------------------

# 再次查看卷组，发现Free PE有8个G
[root@liuyehcf ~]$ vgdisplay
#-------------------------↓↓↓↓↓↓-------------------------
  --- Volume group ---
  VG Name               centos
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               <18.09 GiB
  PE Size               4.00 MiB
  Total PE              4631
  Alloc PE / Size       2583 / <10.09 GiB
  Free  PE / Size       2048 / 8.00 GiB
  VG UUID               dgAwma-p7HF-cIKR-07w9-smjU-twhD-cXGeWy
#-------------------------↑↑↑↑↑↑-------------------------

# 将当前卷组中剩余 P E添加到 centos-root 中
[root@liuyehcf ~]$ lvextend -l +100%FREE /dev/mapper/centos-root
#-------------------------↓↓↓↓↓↓-------------------------
  Size of logical volume centos/root changed from 8.98 GiB (2299 extents) to 16.98 GiB (4347 extents).
  Logical volume centos/root successfully resized.
#-------------------------↑↑↑↑↑↑-------------------------

# 扩展centos-root文件系统
[root@liuyehcf ~]$ xfs_growfs /dev/mapper/centos-root
#-------------------------↓↓↓↓↓↓-------------------------
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=588544 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=2354176, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 2354176 to 4451328
#-------------------------↑↑↑↑↑↑-------------------------
```

## 2.3 修复因断电导致磁盘inode损坏

**步骤**

1. 进入`emergency`模式
    * 在CentOS的boot菜单下按`e`，并编辑grub命令，在`linux16`配置项最后追加`systemd.unit=emergency.target`，按`Ctrl+x`即可进入`emergency`模式
    * ![2-3-1](/images/Linux-定制发行版/2-3-1.png)
1. 找到`Linux LVM`的根分区地址和设备
1. `cat /etc/fstab`确定根分区文件系统类型，通常为`ext4`或`xfs`
    * 若文件系统为`ext4`，运行`fsck -f`，例如`fsck -f /dev/mapper/centos-root`
    * 若文件系统为`xfs`，运行`xfs_repair -v /dev/mapper/centos-root`
        * 针对根分区已加载的情况下，可以执行`xfs_repair -d /dev/mapper/centos-root`尝试修复
        * 如果修复失败，可以添加参数`-L`进行修复，但是这样会丢失一部分文件系统日志，不建议一开始就尝试，可以作为最终解决方案

## 2.4 忘记root密码

**方法1**

1. 进入`Single User && Emergency`模式
    * 在CentOS的boot菜单下按`e`，并编辑grub命令，在`linux16`配置项最后追加`rw init=/sysroot/bin/bash`，按`Ctrl+x`即可进入
        * `rw`表示以可读写的方式挂载根分区
        * `init=/sysroot/bin/bash`：系统安装所在分区里面路径为`/bin/bash`的文件，内核启动过程中会查找系统安装所在分区，然后把该分区挂载到`/sysroot`目录下
    * ![2-3-2](/images/Linux-定制发行版/2-3-2.png)
1. 修改密码
    * `chroot /sysroot`
    * `passwd`：修改密码，键入两次新密码即可
    * `touch /.autorelabel`
    * `exit`
    * `reboot -f`
    * ![2-3-3](/images/Linux-定制发行版/2-3-3.png)

**`touch /.autorelabel`这个命令有什么作用**：当我们用`passwd`修改密码时，`/etc/shadow`文件会在错误的`SELinux`上下文中被修改。`touch /.autorelabel`命令会创建一个隐藏文件，在下次启动时，`SELinux`子系统将检测到该文件，然后使用正确的`SELinux`上下文重新标记文件系统上的所有文件。在大磁盘上，此过程可能消耗大量的时间

---

**方法2**

1. 进入`Single User`模式
    * 在CentOS的boot菜单下按`e`，并编辑grub命令，在`linux16`配置项最后追加`init=/bin/bash`，按`Ctrl+x`即可进入
        * `init=/bin/bash`：内核启动过程中临时文件系统（`initrd.img`）里面路径为`/bin/bash`的文件
    * ![2-3-4](/images/Linux-定制发行版/2-3-4.png)
1. 修改密码
    * `mount -o remount,rw /`：重新以`rw`的方式挂载根分区（因为这次，我们没有在内核参数中增加`rw`参数）
    * `passwd`：修改密码，键入两次新密码即可
    * `touch /.autorelabel`
    * `/sbin/reboot -f`
    * ![2-3-5](/images/Linux-定制发行版/2-3-5.png)

---

**方法3**

1. 进入`Single User && Emergency`模式
    * 在CentOS的boot菜单下按`e`，并编辑grub命令，在`linux16`配置项最后追加`rd.break`，按`Ctrl+x`即可进入
        * `rd.break`：`rd`指的是`init ram disk`；`break`指的是`boot`程序在将控制权从`initramfs`转交给`systemd`之前进行中断
    * ![2-3-6](/images/Linux-定制发行版/2-3-6.png)
1. 修改密码
    * `mount -o remount,rw /sysroot`：重新以`rw`的方式挂载根分区（因为这次，我们没有在内核参数中增加`rw`参数）
    * `chroot /sysroot`
    * `passwd`
    * `touch /.autorelabel`
    * `exit`
    * `reboot -f`
    * ![2-3-7](/images/Linux-定制发行版/2-3-7.png)

## 2.5 恢复boot分区

当boot分区不小心被破坏之后（比如，用fdisk将boot分区误删了），机器是无法启动成功的，会出现如下错误页面

![2-3-8](/images/Linux-定制发行版/2-3-8.png)

**可以通过以下步骤进行恢复**

**第一步**：找到系统的iso，并制作u盘启动盘。插入u盘后开机

**第二步**：在grub菜单页，依次选择`Troubleshooting`、`Rescue a CentOS system`

* ![2-3-9](/images/Linux-定制发行版/2-3-9.png)
* ![2-3-10](/images/Linux-定制发行版/2-3-10.png)

**第三步**：从u盘启动linux系统，并获取shell

* ![2-3-11](/images/Linux-定制发行版/2-3-11.png)

**第四步**：重新安装grub以及grub配置文件

* ![2-3-12](/images/Linux-定制发行版/2-3-12.png)

```sh
# 硬盘的挂载点是/mnt/sysimage
sh-4.2$ chroot /mnt/sysimage

# 将cdrom挂载到/mnt/cdrom目录，可以通过lsblk查看cdrom设备名
sh-4.2$ mkdir -p /mnt/cdrom
sh-4.2$ mount /dev/sr0 /mnt/cdrom

# 将可执行内核拷贝到/boot目录中
sh-4.2$ cp /mnt/cdrom/isolinux/vmlinuz /boot/vmlinuz-`uname -r`

# 重新制作initram
sh-4.2$ mkinitrd /boot/initramfs-`uname -r`.img `uname -r`

# 重新安装grub2，磁盘盘符视实际情况而定（我这里是/dev/sda）
sh-4.2$ grub2-install /dev/sda
sh-4.2$ grub2-mkconfig > /boot/grub2/grub.cfg
```

**第五步（可选）**：这一步取决于boot分区是如何被破坏的，如果整个分区都删掉了，那么需要修改`/etc/fstab`将`/boot`分区的配置项注释掉，然后重启

## 2.6 概念理解

1. 物理卷（physics volume）
    * 可以用`pvdisplay`查看逻辑卷
1. 卷组（volume group）
    * 可以用`vgdisplay`查看逻辑卷
1. 逻辑卷（logical volume）
    * 可以用`lvdisplay`查看逻辑卷
    * 上面出现的`/dev/centos/root`就是逻辑卷，而`/dev/mapper/centos-root`其实是一个逻辑磁盘（`dm`就是`device mapper`的缩写）
        * `/dev/mapper/centos-root`其实是个链接文件，链接到了`/dev/dm-0`，在你的电脑上可能不是`0`
        * `dmsetup info /dev/dm-0`可以查看`/dev/dm-0`的信息
        * `sudo lvdisplay|awk  '/LV Name/{n=$3} /Block device/{d=$3; sub(".*:","dm-",d); print d,n;}'`可以查看映射关系

## 2.7 参考

* [CentOS 7 调整 home分区 扩大 root分区](https://my.oschina.net/jasonMrliu/blog/1604954)
* [手把手教你给 CentOS 7 添加硬盘及扩容(LVM)](https://aurthurxlc.github.io/Aurthur-2017/Centos-7-extend-lvm-volume.html)
* [Linux Creating a Partition Size Larger Than 2TB](https://www.cyberciti.biz/tips/fdisk-unable-to-create-partition-greater-2tb.html)
* [What is this dm-0 device?(/dev/mapper/centos-root以及/dev/dm-0)](https://superuser.com/questions/131519/what-is-this-dm-0-device)
* [centos7中的网卡名称相关知识](https://www.cnblogs.com/yanh0606/p/10910808.html)
* [What does /.autorelabel do when we reset the password in Red Hat?](https://unix.stackexchange.com/questions/509798/what-does-autorelabel-do-when-we-reset-the-password-in-red-hat)
* [Reset lost root password](https://wiki.archlinux.org/index.php/Reset_lost_root_password)
* [How to Boot into Single User Mode in CentOS/RHEL 7](https://www.tecmint.com/boot-into-single-user-mode-in-centos-7/)
* [Three Methods Boot CentOS/RHEL 7/8 Systems in Single User Mode](https://www.2daygeek.com/boot-centos-7-8-rhel-7-8-single-user-mode/)
* [CHAPTER 26. WORKING WITH GRUB 2](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader#sec-Changing_and_Resetting_the_Root_Password)

# 3 CentOS自定义发行版iso镜像制作

## 3.1 初次尝试制作镜像

在本小结，我们将iso镜像文件解压，然后将解压之后的文件原封不动地打成iso镜像，目的是为了熟悉镜像制作的各个命令行工具

为了减少环境因素对镜像制作造成的影响，这里使用docker容器来进行打包，DockerFile如下，非常简单，基础镜像为`centos:7.6.1810`，并用yum安装了镜像制作的相关工具

```Dockerfile
FROM centos:7.6.1810

WORKDIR /

RUN yum install -y createrepo genisoimage syslinux-utils syslinux isomd5sum
```

接下来制作docker镜像

```sh
docker build -t create-iso-env:1.0.0 .
```

我们先研究一下官方的iso文件的结构，我下载的是`CentOS-7-x86_64-Minimal-1908.iso`，解压之后，目录结构如下（rpm包太多了，这里省略掉）

```
.
├── CentOS_BuildTag
├── EFI
│   ├── BOOT
│   │   ├── BOOTIA32.EFI
│   │   ├── BOOTX64.EFI
│   │   ├── TRANS.TBL
│   │   ├── fonts
│   │   │   ├── TRANS.TBL
│   │   │   └── unicode.pf2
│   │   ├── grub.cfg
│   │   ├── grubia32.efi
│   │   ├── grubx64.efi
│   │   ├── mmia32.efi
│   │   └── mmx64.efi
│   └── TRANS.TBL
├── EULA
├── GPL
├── LiveOS
│   ├── TRANS.TBL
│   └── squashfs.img
├── Packages
│   ├── GeoIP-1.5.0-14.el7.x86_64.rpm
│   ├── ...
│   └── zlib-1.2.7-18.el7.x86_64.rpm
├── RPM-GPG-KEY-CentOS-7
├── RPM-GPG-KEY-CentOS-Testing-7
├── TRANS.TBL
├── images
│   ├── TRANS.TBL
│   ├── efiboot.img
│   └── pxeboot
│       ├── TRANS.TBL
│       ├── initrd.img
│       └── vmlinuz
├── isolinux
│   ├── TRANS.TBL
│   ├── boot.cat
│   ├── boot.msg
│   ├── grub.conf
│   ├── initrd.img
│   ├── isolinux.bin
│   ├── isolinux.cfg
│   ├── memtest
│   ├── splash.png
│   ├── vesamenu.c32
│   └── vmlinuz
└── repodata
    ├── 16890efb08ba2667b3cfd83c4d234d5fabea890e6ed2ade4d4d7adec9670a9a5
    ├── 3654075e05ea799f20d35bc250759378ae24bbba929973efc9ab809b182a4c7c
    ├── 4af1fba0c1d6175b7e3c862b4bddfef93fffb84c37f7d5f18cfbff08abc47f8a
    ├── 521f322f05f9802f2438d8bb7d97558c64ff3ff74c03322d77787ade9152d8bb
    ├── 5a783c36d40a53713ff101426228dc9d0459e7246e1a1bdb530c97a478784d53
    ├── 7b2c05dfb46ff4a36822aa3c9d3484a7bdd3f356f4638ddf239f89d5f8f9bca1
    ├── 83b61f9495b5f728989499479e928e09851199a8846ea37ce008a3eb79ad84a0
    ├── 848a2b870c34dbf5186e3a09d6e0105959117b6864a5715df3cf3a40d8b04e60
    ├── TRANS.TBL
    ├── d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936
    ├── fa095a8e52d5d2f81f1947b3a25f10608250d40b14b579469a93c28fced5d60e
    ├── repomd.xml
    └── repomd.xml.asc
```

运行docker。这里挂载了3个目录

1. `/Users/hechenfeng/Desktop/source/CentOS-7-x86_64-Minimal-1908`：该目录是我解压iso文件之后得到的目录，对应于容器中的`/source`目录
1. `/Users/hechenfeng/Desktop/workspace`：该目录是镜像制作的工作目录，对应于容器中的`/workspace`目录
1. `/Users/hechenfeng/Desktop/iso`：该目录用于放置生成的iso文件，对应于容器中的`/target`目录

```sh
docker run \
-v /Users/hechenfeng/Desktop/source/CentOS-7-x86_64-Minimal-1908:/source \
-v /Users/hechenfeng/Desktop/workspace:/workspace \
-v /Users/hechenfeng/Desktop/iso:/target \
-it create-iso-env:1.0.0 bash
```

**以下命令均在容器中执行**

第一步：将`/source`目录中的内容，拷贝到`/workspace`目录中

```sh
# 删除除了. ..之外的所有文件以及目录，包括隐藏文件以及隐藏目录
rm -rf /workspace/{..?*,.[!.]*,*}

# 递归拷贝所有文件以及目录，包括隐藏文件以及隐藏目录
cp -vrf /source/. /workspace/
```

第二步：根据`comps.xml`制作本地repo。这里有一个坑，官方的CentOS镜像解压后，是不存在`comps.xml`这个文件的，这个文件存在于`repodata`目录中（容器中的路径为`/workspace/repodata`），且名字是一个随机字符串。可以通过如下命令将该文件重命名且移动至上层目录，然后重新制作本地repo。此外，也可以从[CentOS的官方文档](http://mirror.centos.org/centos/7/os/x86_64/repodata/)中下载`comps.xml`文件

```sh
# 找到该comps.xml文件
file=$(grep -r '<id>anaconda-tools</id>' /workspace/repodata | awk -F ':' '{print $1}')

echo "file: '${file}'"

# 移动至上层目录
mv ${file} /workspace/comps.xml

# 清理原有的repo
rm -rf /workspace/repodata/

# 重新制作repo
createrepo -g /workspace/comps.xml /workspace
```

第四步：接下来，就可以制作镜像了，详细流程可以参考[RedHat文档](https://www.redhat.com/en/blog/building-custom-boot-iso-red-hat-virtualization-hypervisor?source=searchresultlisting)

```sh
fileName=/target/my-centos-1.iso
label="CentOS 7 x86_64"

genisoimage \
       -V "${label}" \
       -A "${label}" \
       -o ${fileName} \
       -joliet-long \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -boot-info-table \
       -eltorito-alt-boot -e images/efiboot.img \
       -no-emul-boot \
       -R -J -v -T \
       /workspace/

isohybrid --uefi ${fileName}

implantisomd5 ${fileName}
```

## 3.2 修改发行版信息

我们重新运行一个容器来制作镜像

```sh
docker run \
-v /Users/hechenfeng/Desktop/source/CentOS-7-x86_64-Minimal-1908:/source \
-v /Users/hechenfeng/Desktop/workspace:/workspace \
-v /Users/hechenfeng/Desktop/iso:/target \
-it create-iso-env:1.0.0 bash
```

**以下命令均在容器中执行**

第一步：将`/source`目录中的内容，拷贝到`/workspace`目录中

```sh
# 删除除了. ..之外的所有文件以及目录，包括隐藏文件以及隐藏目录
rm -rf /workspace/{..?*,.[!.]*,*}

# 递归拷贝所有文件以及目录，包括隐藏文件以及隐藏目录
cp -vrf /source/. /workspace/
```

第二步：修改标签以及标题

```sh
originalLabelEscape="CentOS\\\\x207\\\\x20x86_64"
originalLabel="CentOS 7 x86_64"
originalTitle="CentOS 7"

newLabelEscape="LABEL_LIUYEHCF"
newLabel="LABEL_LIUYEHCF"
newTitle="TITLE_LIUYEHCF"

# 先找出需要修改的文件列表
files=$(find /workspace -name '*.cfg' -o -name '*.conf' -o -name '*.cfgn')

# 先判断一下哪些需要进行过滤
for file in ${files}
do
    totalNum=0
    num=$(cat ${file} | sed -n "s/${originalLabelEscape}/${newLabelEscape}/gp" | wc -l)
    totalNum=$[ ${totalNum} + ${num} ]
    num=$(cat ${file} | sed -n "s/${originalLabel}/${newLabel}/gp" | wc -l)
    totalNum=$[ ${totalNum} + ${num} ]
    num=$(cat ${file} | sed -n "s/${originalTitle}/${newTitle}/gp" | wc -l)
    totalNum=$[ ${totalNum} + ${num} ]

    if [ ${totalNum} -gt 0 ]; then
        cp -a ${file} ${file}.bak

        sed -i "s/${originalLabelEscape}/${newLabelEscape}/g" ${file}
        sed -i "s/${originalLabel}/${newLabel}/g" ${file}
        sed -i "s/${originalTitle}/${newTitle}/g" ${file}

        echo -e "\n文件 '${file}'，修改前后差异如下"
        diff ${file}.bak ${file}

        echo -e "\n"
    fi
done
```

第三步：根据`comps.xml`制作本地repo

```sh
# 找到该comps.xml文件
file=$(grep -r '<id>anaconda-tools</id>' /workspace/repodata | awk -F ':' '{print $1}')

echo "file: '${file}'"

# 移动至上层目录
mv ${file} /workspace/comps.xml

# 清理原有的repo
rm -rf /workspace/repodata/

# 重新制作repo
createrepo -g /workspace/comps.xml /workspace
```

第四步：制作镜像

```sh
fileName=/target/my-centos-2.iso
label="LABEL_LIUYEHCF"

genisoimage \
       -V "${label}" \
       -A "${label}" \
       -o ${fileName} \
       -joliet-long \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -boot-info-table \
       -eltorito-alt-boot -e images/efiboot.img \
       -no-emul-boot \
       -R -J -v -T \
       /workspace/

isohybrid --uefi ${fileName}

implantisomd5 ${fileName}
```

## 3.3 使用kickstart定制化安装流程

在正常装机完成之后，会有一个`/root/anaconda.ks`文件，其内容如下。我们的`kickstart`文件可以参考这个文件的内容来编写

```sh
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --onboot=off --ipv6=auto --no-activate
network  --bootproto=dhcp --device=enp0s8 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain

# Root password
rootpw --iscrypted $6$06oxYFWoYXYYJSk/$QFoFc4yAthMW1H/oQPsTJQtUjvd5O0pqynKe84N6HVDXTYxmn2ERpAoplp9aX88eYpShM/ARNrhU.vgC35HSO1
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end
```

我们重新运行一个容器来制作镜像

```sh
docker run \
-v /Users/hechenfeng/Desktop/source/CentOS-7-x86_64-Minimal-1908:/source \
-v /Users/hechenfeng/Desktop/workspace:/workspace \
-v /Users/hechenfeng/Desktop/iso:/target \
-it create-iso-env:1.0.0 bash
```

**以下命令均在容器中执行**

第一步：将`/source`目录中的内容，拷贝到`/workspace`目录中

```sh
# 删除除了. ..之外的所有文件以及目录，包括隐藏文件以及隐藏目录
rm -rf /workspace/{..?*,.[!.]*,*}

# 递归拷贝所有文件以及目录，包括隐藏文件以及隐藏目录
cp -vrf /source/. /workspace/
```

第二步：编写`kickstart`文件，路径为`/workspace/liuyehcf.ks`，相比于上面展示的`/root/anaconda.ks`，改造点如下

* 禁用了root账号
* 增加了一个用户`liuyehcf`，其密码为`!Abcd1234`，密文可以通过命令`python3 -c 'import crypt; print(crypt.crypt("!Abcd1234", crypt.mksalt()))'`获取
* 禁用自动分区，注释掉`autopart --type=lvm`
* 避免安装完成重启时，仍然从iso启动，增加`reboot --eject`
* 第一个post，将iso中的`EFI`目录拷贝到操作系统中的`/EFI`目录（可以是任意文件或目录，这里用`EFI`来做示范）
    * **需要指定`--nochroot`参数**
    * **`/run/install/repo`：iso的挂载点**
    * **`/mnt/sysimage`：操作系统根目录的挂载点**
* 第二个post，执行一些定制化的步骤，这里是写了一个文件，`/root/greet`

```sh
cat > /workspace/liuyehcf.ks << 'EOF'
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --onboot=off --ipv6=auto --no-activate
network  --bootproto=dhcp --device=enp0s8 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain

# Root password
rootpw --lock
# Custom user password
user --groups=wheel --name=liuyehcf --password=$6$jWXzp2aDfZJ96SJt$/F.3oD7m6ymvcKtN77Lmkp3ckLMAExxL1Fh64vk4XluEbEszSti85vRCvun6dAvf0Kfs81tFYkBP2tSQH3HdY. --iscrypted --gecos="LiuyeHcf" --shell=/usr/bin/bash
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
#autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda

# Avoid loading from iso on restart
reboot --eject

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

# Copy the files in iso to the operating system
%post --nochroot
#!/bin/sh

mkdir -p /mnt/sysimage/EFI
cp -a /run/install/repo/EFI/* /mnt/sysimage/EFI/

%end

# Do something special
%post --interpreter=/usr/bin/bash --log=/root/ks-post.log --erroronfail
#!/bin/sh

echo "hello world" > /root/greet

%end
EOF
```

第三步：修改配置文件，关联这个`kickstart`文件（`/workspace/liuyehcf.ks`）

```sh
# ks文件的路径，工作目录/workspace，对iso来说就是根目录
ksPath=/liuyehcf.ks
labelEscape="CentOS\\\\x207\\\\x20x86_64"
instStage2Content="inst.stage2=hd:LABEL="${labelEscape}
instKsContent="inst.ks=hd:LABEL="${labelEscape}:${ksPath}

# 先找出需要修改的文件列表
files=$(find /workspace -name '*.cfg' -o -name '*.conf' -o -name '*.cfgn')

# 先判断一下哪些需要进行过滤
for file in ${files}
do
    num=$(cat ${file} | sed -n "s|${instStage2Content}|${instStage2Content} ${instKsContent}|gp" | wc -l)

    if [ ${num} -gt 0 ]; then
        cp -a ${file} ${file}.bak

        sed -i "s|${instStage2Content}|${instStage2Content} ${instKsContent}|g" ${file}

        echo -e "\n文件 '${file}'，修改前后差异如下"
        diff ${file}.bak ${file}

        echo -e "\n"
    fi
done
```

第四步：根据`comps.xml`制作本地repo

```sh
# 找到该comps.xml文件
file=$(grep -r '<id>anaconda-tools</id>' /workspace/repodata | awk -F ':' '{print $1}')

echo "file: '${file}'"

# 移动至上层目录
mv ${file} /workspace/comps.xml

# 清理原有的repo
rm -rf /workspace/repodata/

# 重新制作repo
createrepo -g /workspace/comps.xml /workspace
```

第五步：制作镜像

```sh
fileName=/target/my-centos-3.iso
label="CentOS 7 x86_64"

genisoimage \
       -V "${label}" \
       -A "${label}" \
       -o ${fileName} \
       -joliet-long \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -boot-info-table \
       -eltorito-alt-boot -e images/efiboot.img \
       -no-emul-boot \
       -R -J -v -T \
       /workspace/

isohybrid --uefi ${fileName}

implantisomd5 ${fileName}
```

**验证**

1. 装机的时候，只需要进行一步操作，磁盘分区，其他操作都是自动进行的
1. 用`liuyehcf/!Abcd1234`登录
1. 检查`/EFI`目录以及子文件子目录是否存在
1. 检查`root/greet`文件是否存在

## 3.4 Preboot Execution Environment, PXE

**PXE安装的核心流程，下面拆分了`DHCP Server`、`PXE Server`、`ISO Server`，在实际情况中，这三者通常来说是同一个服务器**

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}

participant client as "PXE Client"
participant dhcp_server as "DHCP Server"
participant pxe_server as "PXE Server"
participant iso_server as "ISO Server"

client->dhcp_server: dhcp请求
dhcp_server->client: dhcp响应，PXE-Server的ip及文件pxelinux.0的位置
...
client->pxe_server: 请求pxelinux.0（基于tftp）
pxe_server->client: 返回pxelinux.0
...
client->pxe_server: 请求pxelinux.0的配置文件pxelinux.cfg/default（基于tftp）
pxe_server->client: 返回pxelinux.0的配置文件pxelinux.cfg/default
...
client->client: 显示grub菜单，然后选中某一项
...
client->pxe_server: 请求内核文件vmlinuz以及文件系统initrd.img（基于tftp）
pxe_server->client: 返回内核文件vmlinuz以及文件系统initrd.img
...
client->client: 客户端收到文件，启动内核映像文件
...
client->iso_server: 请求iso源文件以及相关脚本（基于http、ftp、nfs中的任意一种）
iso_server->client: 返回iso源文件以及相关脚本
```

**下面以一个简单的例子来演示一下如何搭建PXE环境，在示例中`DHCP Server`、`PXE Server`、`ISO Server`是同一台服务器。此外`PXE`有四种启动模式，分别为`IPV4 legacy`，`IPV4 UEFI`，`IPV6 legacy`，`IPV6 UEFI`，这里主要介绍`IPV4 legacy`启动模式需要的文件**

### 3.4.1 预备工作

1. 操作系统，我用的是`CentOS 7.6`
1. iso文件，我用的是`CentOS-7-x86_64-Minimal-1908.iso`
1. 安装`dhcpd`
    * `yum install -y dhcp`
1. 安装`tftp`
    * `yum install -y tftp-server`
1. 安装`ftp`/`http`、`nfs`中的任意一种，这里我选用ftp
    * `yum install -y vsftpd`

### 3.4.2 配置并启动dhcp服务

```sh
# 备份
mv /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

# dhcpd配置
cat > /etc/dhcp/dhcpd.conf << 'EOF'
 # dhcpd.conf
 ddns-update-style interim;
 ignore client-updates;
 allow booting;
 allow bootp;
 class "pxeclients" {
    match if substring(option vendor-class-identifier,0,9)="PXEClient";
    next-server 192.168.66.1;
    filename "pxelinux.0";
 }
 subnet 192.168.66.0 netmask 255.255.255.0 {
    option broadcast-address 192.168.66.255;
    option routers 192.168.66.1;
    option subnet-mask 255.255.255.0;
    range 192.168.66.2 192.168.66.254;
    default-lease-time 8640000;
 }
EOF

# 设置静态ip
nmtui

# 重启网络，生效静态ip
systemctl restart network

# 启动dhcp服务
systemctl enable dhcpd
systemctl restart dhcpd
systemctl status dhcpd
```

* `allow booting`：允许客户端在`booting`阶段查询`host declaration`
* `allow bootp`：允许对`bootp query`做出响应
* `PXE`相关配置
    * `PXE Server`的ip是`192.168.66.1`
    * 启动引导器的文件名是`pxelinux.0`
* `DHCP`相关配置
    * `DHCP Server`的ip是`192.168.66.1`
    * 广播地址是`192.168.66.255`
    * 可分配的IP范围是`192.168.66.2`到`192.168.66.254`

### 3.4.3 配置并启动tftp服务

```sh
# 清理tftp目录
rm -rf /var/lib/tftpboot/*

# 安装syslinux加载器
yum install -y syslinux

# 拷贝pxelinux.0以及vesamenu.c32到tftp目录
cp -vrf /usr/share/syslinux/pxelinux.0 \
/usr/share/syslinux/vesamenu.c32 \
/var/lib/tftpboot

# 挂载镜像
mkdir -p /mnt/iso
mount -o loop /CentOS-7-x86_64-Minimal-1908.iso /mnt/iso

# 拷贝vmlinuz以及initrd.img到tftp目录
mkdir /var/lib/tftpboot/iso
cp -vrf /mnt/iso/isolinux/vmlinuz \
/mnt/iso/isolinux/initrd.img \
/var/lib/tftpboot/iso

# 启动tftp服务
systemctl enable tftp
systemctl restart tftp
systemctl status tftp
```

### 3.4.4 配置并启动ftp服务

```sh
# 清理ftp目录
rm -rf /var/ftp/*
mkdir /var/ftp/iso

# 由于上一步已经挂载了iso，如果未挂载，需要先挂载
# mount -o loop /CentOS-7-x86_64-Minimal-1908.iso /mnt/iso

# 拷贝iso相关文件
cp -vrf /mnt/iso/. /var/ftp/iso

# 启动ftp服务
systemctl enable vsftpd
systemctl restart vsftpd
systemctl status vsftpd
```

### 3.4.5 编写pxelinux.cfg/default文件

```sh
# 清理
rm -rf /var/lib/tftpboot/pxelinux.cfg

# 拷贝isolinux.cfg文件
mkdir /var/lib/tftpboot/pxelinux.cfg
cp -vrf /mnt/iso/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default

originalKernelVmlinuz="kernel vmlinuz"
originalInitrd="initrd=initrd.img"
originalStage2="inst.stage2=hd:LABEL=CentOS\\\\x207\\\\x20x86_64"

# vmlinuz以及initrd.img的路径：相对于tftp的工作目录/var/lib/tftpboot的路径
newKernelVmlinuz="kernel iso/vmlinuz"
newInitrd="initrd=iso/initrd.img"
# ks.cfg的路径：相对于ftp工作目录/var/ftp的路径
newKickstart="ks=ftp://192.168.66.1/iso/ks.cfg"

# 修改vmlinuz的路径（基于tftp）
sed -i "s|${originalKernelVmlinuz}|${newKernelVmlinuz}|g" /var/lib/tftpboot/pxelinux.cfg/default
# 修改initrd.img的路径（基于tftp）
sed -i "s|${originalInitrd}|${newInitrd}|g" /var/lib/tftpboot/pxelinux.cfg/default
# 删除inst.stage2配置，增加ks配置（基于ftp）
sed -i "s|${originalStage2}|${newKickstart}|g" /var/lib/tftpboot/pxelinux.cfg/default

echo "/mnt/iso/isolinux/isolinux.cfg 与 /var/lib/tftpboot/pxelinux.cfg/default 的差异"
diff /mnt/iso/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
```

### 3.4.6 编写kickstart文件

```sh
cat > /var/ftp/iso/ks.cfg << 'EOF'
#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use network installation
url --url="ftp://192.168.66.1/iso"
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=enp0s3 --onboot=off --ipv6=auto --no-activate
network  --bootproto=dhcp --device=enp0s8 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain

# Root password
rootpw --lock
# Custom user password
user --groups=wheel --name=liuyehcf --password=$6$jWXzp2aDfZJ96SJt$/F.3oD7m6ymvcKtN77Lmkp3ckLMAExxL1Fh64vk4XluEbEszSti85vRCvun6dAvf0Kfs81tFYkBP2tSQH3HdY. --iscrypted --gecos="LiuyeHcf" --shell=/usr/bin/bash
# System services
services --enabled="chronyd"
# System timezone
timezone America/New_York --isUtc
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
#autopart --type=lvm
# Partition clearing information
clearpart --all --initlabel --drives=sda

# Avoid loading from iso on restart
reboot --eject

%packages
@^minimal
@core
chrony
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

# Do something special
%post --interpreter=/usr/bin/bash --log=/root/ks-post.log --erroronfail
#!/bin/sh

# Download the files in iso to the operating system
mkdir /EFI
wget -r ftp://192.168.66.1/iso/EFI/* -P /EFI
mv /EFI/192.168.66.1/iso/EFI/* /EFI
rm -rf /EFI/192.168.66.1

echo "hello world" > /root/greet

%end
EOF
```

* 配置从网络安装：`url --url="ftp://192.168.66.1/iso"`
* 镜像中的其他目录，可以在post阶段通过wget进行下载

### 3.4.7 关闭防火墙

关掉防火墙，避免`dhcp`、`tftp`、`ftp`、`http`等服务无法访问

```sh
systemctl disable firewalld
systemctl stop firewalld
```

### 3.4.8 配置从网络启动

**BIOS配置（仅供参考，不同机器的BIOS菜单可能差异很大）**

1. `NO Disk(PXE)`：改为enable
1. `CSM Configuration`：
    * `Boot option filter`：`UEFI and Legacy`
    * `Network`：Legacy
    * `Storage`：Legacy
    * `Video`：Legacy
    * `Other PCI devices`：Legacy

## 3.5 其他

### 3.5.1 iso包含大文件（4G以上）

用`genisoimage`制作iso的时候，如果包含了超过4G的文件，那么需要加上参数`-allow-limited-size`。**但是，这样会造成一个问题：如果iso中的某些文件在kickstart中会拷贝到目标的操作系统当中，那么这些文件的执行权限会丢失**

如果包含了4G以上的文件，那就无法使用FAT32文件系统来制作U盘启动盘。**但是我们可以使用`split`以及`cat`命令来拆分以及重建大文件，如此一来就又可以使用FAT32文件系统了**

```sh
# 拆分
split -b 2048M bigfile bigfile-slice-

# 重建
cat bigfile-slice-* > rebuild-bigfile
```

### 3.5.2 下载某个软件的rpm包

**针对当前环境，下载缺失的rpm包：`yum install --downloadonly --downloaddir=<downloadDir> <app1> <app2> ...`**

* `yum install --downloadonly --downloaddir=/rpm gcc`

**下载所有的rpm包（无论当前系统是否存在）：`repotrack -a x86_64 -p <downloadDir> <app1> <app2> ...`**

* `repotrack -a x86_64 -p /rpm/ gcc wget`

**安装rpm包并解决冲突**：`rpm -ivh --replacepkgs --upgrade=*.rpm <directory>/*.rpm`

* `rpm -ivh --replacepkgs --upgrade=*.rpm /rpm/*.rpm`

### 3.5.3 安装时如何切换tty

* 从图形化界面切换到tty：`ctrl+alt+f<n>`，n可以是1-5
* 从tty切换到图形化界面：`ctrl+alt+f6`

### 3.5.4 查找官方iso中的comps.xml文件

1. 在`CentOS 7.6.1810`以及`CentOS 7.7.1908`中，该xml都存在于`repodata`目录中，只是名字是个随机串
1. 在`CentOS 7.8.2003`中，该xml以压缩包的形式存在于`repodata`目录中，压缩包的名字也是个随机串

### 3.5.5 kickstart语法

#### 3.5.5.1 %packages

`%packages`用于指定安装包（rpm包），在`CentOS-7-x86_64-DVD-xxx/repodata`目录下，有个`comps.xml`文件，该文件内有包含`environment`、`group`等的定义，可以用`<environment>`以及`<group>`来搜索相关的定义

**指定`environment`**

```
%packages
@^Infrastructure Server
%end
```

**指定`group`**

```
%packages
@X Window System
@Desktop
@Sound and Video
%end
```

**指定独立的rpm包，支持通配符**

```
%packages
sqlite
curl
aspell
docbook*
%end
```

**排除指定的`environment`、`group`以及独立的rpm包**

```
%packages
-@Graphical Internet
-autofs
-ipa*fonts
%end
```

## 3.6 参考

* [使用isolinux制作liveUSB](https://blog.csdn.net/trochiluses/article/details/17585525)
* [CentOS Composer](https://docs.centos.org/en-US/centos/install-guide/Composer/)
* [按部就班---半自动化系统安装](https://zhuanlan.zhihu.com/p/45791653)
* [mkisofs制作镜像文件](https://www.cnblogs.com/klb561/p/9108712.html)
* [Building a Custom Boot ISO for Red Hat Virtualization Hypervisor](https://www.redhat.com/en/blog/building-custom-boot-iso-red-hat-virtualization-hypervisor?source=searchresultlisting)
* [How to use and edit comps.xml for package groups](https://fedoraproject.org/wiki/How_to_use_and_edit_comps.xml_for_package_groups)
* [定制自己的CentOS发行版](https://blog.51cto.com/716737/1302970)
* [CentOS官方comps.xml文件](http://mirror.centos.org/centos/7/os/x86_64/repodata/)
* [使用ISOLinux制作Linux系统安装盘](https://blog.csdn.net/liujixin8/article/details/4029887)
* [CentOS Kickstart 官方文档](https://docs.centos.org/en-US/centos/install-guide/Kickstart2/)
* [Red Hat Kickstart 官方文档](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/installation_guide/sect-kickstart-syntax)
* [Anaconda kickstart 官方文档](https://fedoraproject.org/wiki/Anaconda/Kickstart/zh-cn)
* [Anaconda kickstart and rootpw option](https://serverfault.com/questions/588532/anaconda-kickstart-and-rootpw-option)
* [kickstart 中文文档](https://octowhale.gitbooks.io/kickstart/content/chapter2-kickstart-options-clearpart.html)
* [Kickstart详解(转载)](https://blog.csdn.net/u010039418/article/details/79984341)
* [CentOS/RHEL 7 LVM Partitioning in Kickstart?](https://serverfault.com/questions/826006/centos-rhel-7-lvm-partitioning-in-kickstart)
* [PXE Network Boot Server](https://www.tecmint.com/install-pxe-network-boot-server-in-centos-7/)
* [PXE的部署过程](https://www.jianshu.com/p/6a44b0a6b87b)
* [PXE自动化系统安装服务器(DHCP + TFTP + syslinux +vsftpd)](https://blog.51cto.com/14181896/2350339)
* [dhcp、tftp及pxe简介](https://www.cnblogs.com/hanshanxiaoheshang/p/10162905.html)
* [Linux-pxe~install网络安装](https://blog.csdn.net/andre_riven/article/details/78795487)
* [Computer says “succeed to download nbp file” but doesn't boot into PE](https://superuser.com/questions/771031/computer-says-succeed-to-download-nbp-file-but-doesnt-boot-into-pe)
* [how to make the first disk /dev/sda always](https://access.redhat.com/discussions/746373)
* [Download all dependencies with yumdownloader, even if already installed?](https://unix.stackexchange.com/questions/50642/download-all-dependencies-with-yumdownloader-even-if-already-installed)

# 4 核心概念

## 4.1 BIOS与UEFI

`BIOS（Basic Input Output System）`是基本输入输出系统。它是一组固化到计算机内主板上一个`ROM`芯片上的程序，保存着计算机最重要的基本输入输出的程序、开机后自检程序和系统自启动程序，它可从`CMOS`中读写系统设置的具体信息

`UEFI（Unified Extensible Firmware Interface）`是统一可扩展固件界面，用来定义操作系统与系统硬件之间的软件界面，作为BIOS的替代方案。可扩展固件接口负责加电自检（POST），联系操作系统以及提供连接作业系统与硬体的介面

**实际上PC的启动固件的引导流程从IBM PC机诞生第一天起，就没有本质改变过，无论传统BIOS还是UEFI，阳光之下没有什么新鲜的东西，启动本身无外乎三个步骤**

1. `Rom Stage`：在这个阶段没有内存，需要在`ROM`上运行代码。这时因为没有内存，没有C语言运行需要的栈空间，开始往往是汇编语言，直接在`ROM`空间上运行。在找到个临时空间（`Cache`空间用作`RAM`，`Cache As Ram, CAR`）后，C语言终于可以粉墨登场了，后期用C语言初始化内存和为这个目的需要做的一切服务
1. `Ram Stage`：在经过`ROM`阶段的困难情况后，我们终于有了可以大展拳脚的内存，很多额外需要大内存的东西可以开始运行了。在这时我们开始进行初始化芯片组、CPU、主板模块等等核心过程
1. `Find something to boot Stage`：终于要进入正题了，需要启动，我们找到启动设备。就要枚举设备，发现启动设备，并把启动设备之前需要依赖的节点统统打通。然后开始移交工作，Windows或者Linux的时代开始

传统BIOS尽管开始全部用汇编语言完成，但后期也部分引入了C语言，这些步骤完全是一样的。什么`MBR`分区啊，`UEFI`分区都是枝节问题，都是技术上可以做到的，没有什么是`UEFI`可以做，传统BIOS不可以做到的。**那既然有BIOS了，为什么还需要UEFI呢**

1. 传统`BIOS`来自于IBM，之后就进入战国时代，激烈的商战让接口统一成为了不可能做到的事，只有在面对微软这个大用户的时候，才勉强提供了`兼容`的基于软中断的接口。它封闭、神秘和充满各种不清不楚的预设和祖传代码，在调试`PCI`的`ROM`时要小心各种`ROM`之间互相踩，各种只有老师傅才知道的神奇`诀窍`。要写个驱动，让它在各个BIOS厂商那里都能跑，简直成为了一件不可能完成的任务
1. 由Intel推动，在一开始就将标准公开，拉上了微软这个PC界的霸主，强势统一了江湖。在近20年的深耕下，统一了固件启动阶段基础框架`Spec：PI Spec`与操作系统的接口`Spec：UEFI Spec`，并将抽象硬件的原语性`Spec: ACPI Spec`也拉入这个大家庭，都变成`UEFI Forum`的一份子
1. 现在只要符合`UEFI driver model`的驱动都可以在各个`BIOS`上运行，打通了各个`BIOS`厂商之间的栅栏；与此同时，符合`UEFI`标准的操作系统都可以流畅的在各种主板上运行，无论是`Windows`，还是`Linux`各种发行版，甚至是`Android`。实际上，PC生态圈的繁荣，和`UEFI`的推广和被广泛接受是分不开的。值得一提的是`UEFI`内核的大部分代码是由Intel的中国工程师开发的。在大家一次次电脑的正常运行后面，有他们辛勤工作背影。他们也为固件的开源和国产化做出了自己的贡献。代码已经全部开源一部分时间了

`CSM Configuration（Compatibility Support Module）`（兼容性支持模块）是`BIOS`上`Boot`选项里的一个下拉子项目（一些老的主板上没有此选项），与`Secure Boot`（安全启动，仅适用于使用UEFI启动的操作系统）是并列项。`CSM`开启使得可以支持`UEFI`启动和非`UEFI`启动

1. **若是需要启动传统`MBR`设备，则需开启`CSM`，关闭`Secure Boot`**
1. **若是需要启动`UEFI`设备，则需要关闭`CSM`，开启`Secure Boot`**

## 4.2 Grub

**`GRUB`的作用有以下几个：**

1. 加载操作系统的内核
1. 拥有一个可以让用户选择的的菜单，来选择到底启动哪个系统
1. 可以调用其他的启动引导程序，来实现多系统引导

按照启动流程，`BIOS`在自检完成后，会到第一个启动设备的`MBR`中读取`GRUB`。在`MBR`中用来放置启动引导程序的空间只有`446`Byte，那么`GRUB`可以放到这里吗？答案是空间不够，`GRUB`的功能非常强大，`MBR`空间是不够使用的。**那么`Linux`的解决办法是把`GRUB`的程序分成了三个阶段来执行**

1. **`Stage 1`：执行`GRUB`主程序**：第一阶段是用来执行`GRUB`主程序的，这个主程序必须放在启动区中（也就是`MBR`或者引导扇区中）。但是`MBR`太小了，所以只能安装`GRUB`的最小的主程序，而不能安装`GRUB`的相关配置文件。这个主程序主要是用来启动`Stage 1.5`和`Stage 2`的。
1. **`Stage 1.5`：识别不同的文件系统**：`Stage 2`比较大，只能放在文件系统中（分区），但是`Stage 1`不能识别不同的文件系统，所以不能直接加载`Stage 2`。这时需要先加载`Stage 1.5`，由`Stage 1.5`来加载不同文件系统中的`Stage 2`
    * 还有一个问题，难道`Stage 1.5`不是放在文件系统中的吗？如果是，那么`Stage 1`同样不能找到`Stage 1.5`。其实，`Stage 1.5`还真没有放在文件系统中，而是在安装`GRUB`时，直接安装到紧跟`MBR`之后的`32KB`的空间中，这段硬盘空间是空白无用的，而且是没有文件系统的，所以`Stage 1`可以直接读取`Stage 1.5`。读取了`Stage 1.5`就能识别不同的文件系统，才能加载`Stage 2`
1. **`Stage 2`：加载`GRUB`的配置文件**：`Stage 2`阶段主要就是加载`GRUB`的配置文件`/boot/grub/grub.conf`，然后根据配置文件中的定义，加载内核和虚拟文件系统。接下来内核就可以接管启动过程，继续自检与加载硬件模块了

## 4.3 Grub2

[GNU GRUB Manual 2.04](https://www.gnu.org/software/grub/manual/grub/html_node/index.html#SEC_Contents)

**系统启动流程**

1. 加载`BIOS`的硬件信息与进行自检，并依据设置取得第一个可启动的设备（硬盘，光盘，U盘）
1. 读取并执行第一个启动设备内`MBR`（主引导分区）的`boot loader`（如`grub2`）
    * 严格意义上，`MBR`就是`grub2`中的`boot.img`，`boot.img`的唯一作用就是读取`core.img`的第一个扇区并跳转到它身上，将控制权交给该扇区的`img`。由于体积原因，`boot.img`是无法理解文件系统的，因此`core.img`的位置是以硬编码的方式记录在`boot.img`中的
    * `core.img`加载启动菜单、加载目标操作系统的信息等
1. 依据`grub2`的设置加载`Kernel`，`Kernel`会开始检测硬件与加载驱动程序
1. 在硬件驱动成功后，`Kernel`会主动调用`systemd`进程（原来的`init`进程），并以`default.targert`流程开机

### 4.3.1 基础内容

#### 4.3.1.1 [grub2和grub的区别](https://www.gnu.org/software/grub/manual/grub/html_node/Changes-from-GRUB-Legacy.html#Changes-from-GRUB-Legacy)

1. **配置文件的名称改变了。在`grub`中，配置文件为`grub.conf`或`menu.lst`(`grub.conf`的一个软链接)，在grub2中改名为`grub.cfg`**
1. `grub2`增添了许多语法，更接近于脚本语言了，例如支持变量、条件判断、循环
1. **`grub2`中，设备分区名称从`1`开始，而在`grub`中是从`0`开始的。**
1. **`grub2`使用`img`文件，不再使用`grub`中的`stage1`、`stage1.5`和`stage2`**
1. 支持图形界面配置grub，但要安装grub-customizer包，epel源提供该包。
1. 在已进入操作系统环境下，不再提供`grub`命令，也就是不能进入`grub`交互式界面，只有在开机时才能进入，算是一大缺憾。
1. 在`grub2`中没有了好用的`find`命令，算是另一大缺憾。

#### 4.3.1.2 [命名习惯和文件路径表示方式](https://www.gnu.org/software/grub/manual/grub/html_node/Naming-convention.html#Naming-convention)

1. `(fd0)`：表示第一块软盘
1. `(hd0,msdos2)`：表示第一块硬盘的第二个`mbr`分区。**`grub2`中分区从`1`开始编号，传统的`grub`是从`0`开始编号的**
1. `(hd0,msdos5)`：表示第一块硬盘的第一个逻辑分区
1. `(hd0,gpt1)`：表示第一块硬盘的第一个`gpt`分区
1. `/vmlinuz`：相对路径，表示根设备下的`vmlinuz`文件
1. `(hd0,msdos1)/vmlinuz`：绝对路径，表示第一硬盘第一分区下的`vmlinuz`文件

#### 4.3.1.3 [grub2引导操作系统的方式](https://www.gnu.org/software/grub/manual/grub/html_node/General-boot-methods.html#General-boot-methods)

`grub2`支持两种方式引导操作系统：

1. 直接引导：`(direct-load)`直接通过默认的`grub2 boot loader`来引导写在默认配置文件中的操作系统
1. 链式引导：`(chain-load)`使用默认`grub2 boot loader`链式引导另一个`boot loader`，该`boot loader`将引导对应的操作系统
* 一般只使用第一种方式，只有想引导grub默认不支持的操作系统时才会使用第二种方式。**比如安装了`Windows`和`Linux`双系统时，系统的`boot loader`是`grub2`，但是`grub2`并不能引导启动`Windows`，所以需要将执行权转交给`Widnwos`系统分区的`boot loader`**

#### 4.3.1.4 文件分布

`grub`的配置文件放置位置为`/boot/grub/`，在`grub2`中，这些文件被分别放置到如下位置中

1. `/boot/grub/grub.cfg`：
1. `/etc/grub.d/`：放置`grub`脚本的位置，这些脚本用于构建`grub.cfg`
1. `/etc/default/grub`：这个文件包含`grub`的基础配置，这些配置在构建`grub.cfg`时，会被脚本读取

**接下来介绍一下`grub`脚本，脚本名称前面的数字代表了脚本执行的先后顺序**

1. `00_header`：该脚本用于读取`grub`的基础配置`/etc/default/grub`，包括超时等等
1. `10_linux`：该脚本用于加载发行版的菜单项
1. `30_os-prober`：该脚本用于扫描硬盘上其他操作系统并将其添加到启动菜单
1. `40_custom`：是一个模板，可用于创建要添加到启动菜单的其他条目

**如何构建新的grub.cfg文件**

* `CentOS`：`grub2-mkconfig –o /boot/grub2/grub.cfg`，不加`-o`参数会直接以标准输出的方式打印到屏幕上
* `Ubuntu`：`update-grub`

**`grub.cfg`文件位置**

* `CentOS`：`/boot/efi/EFI/centos/grub.cfg`或者`/boot/grub2/grub.cfg`
* `Ubuntu`：`/boot/grub/grub.cfg`

#### 4.3.1.5 boot loader和grub的关系

当使用`grub`来管理启动菜单时，那么`boot loader`都是`grub`程序安装的。

传统的`grub`将`Stage 1`转换后的内容安装到`MBR`(`VBR`或`EBR`)中的`boot loader`部分，将`Stage 1.5`转换后的内容安装在紧跟在`MBR`后的扇区中，将`Stage 2`转换后的内容安装在`/boot`分区中。

`grub2`将`boot.img`转换后的内容安装到`MBR`(`VBR`或`EBR`)中的`boot loader`部分，将`diskboot.img`和`kernel.img`结合成为`core.img`，同时还会嵌入一些模块或加载模块的代码到`core.img`中，然后将`core.img`转换后的内容安装到磁盘的指定位置处

#### 4.3.1.6 [grub2的安装位置](https://www.gnu.org/software/grub/manual/grub/html_node/BIOS-installation.html#BIOS-installation)

**严格地说是`core.img`的安装位置，因为`boot.img`的位置是固定在`MBR`或`VBR`或`EBR`上的**

**MBR**

`MBR`格式的分区表用于`PC BIOS`平台，这种格式允许四个主分区和额外的逻辑分区。使用这种格式的分区表，有两种方式安装`grub`：

1. 嵌入到`MBR`和第一个分区中间的空间，这部分就是大众所称的`boot track`，`MBR gap`或`embedding area`，它们大致需要31kB的空间
    * 使用嵌入的方式安装`grub`，就没有保留的空闲空间来保证安全性，例如有些专门的软件就是使用这段空间来实现许可限制的；另外分区的时候，虽然会在MBR和第一个分区中间留下空闲空间，但可能留下的空间会比这更小
1. 将`core.img`安装到某个文件系统中，然后使用分区的第一个扇区(严格地说不是第一个扇区，而是第一个`block`)存储启动它的代码
    * 方法二安装`grub`到文件系统，但这样的`grub`是脆弱的。例如，文件系统的某些特性需要做尾部包装，甚至某些`fsck`检测，它们可能会移动这些block
* **`grub`开发团队建议将`grub`嵌入到`MBR`和第一个分区之间，除非有特殊需求，但仍必须要保证第一个分区至少是从第31kB(第63个扇区)之后才开始创建的**
* 现在的磁盘设备，一般都会有分区边界对齐的性能优化提醒，所以第一个分区可能会自动从第1MB处开始创建

**gpt**

* 一些新的系统使用`GUID`分区表(GPT)格式，这种格式是`EFI`固件所指定的一部分。但如果操作系统支持的话，`gpt`也可以用于`BIOS`平台(即`MBR`风格结合`gpt`格式的磁盘)，使用这种格式，需要使用独立的`BIOS boot`分区来保存`grub`，`grub`被嵌入到此分区，不会有任何风险
* 当在`gpt`磁盘上创建一个`BIOS boot`分区时，需要保证两件事
    1. 它最小是31kB大小，但一般都会为此分区划分1MB的空间用于可扩展性
    1. 必须要有合理的分区类型标识(flag type)
        * **`gun parted`工具可以设置`bios_grub`标识**
        * 如果使用`gdisk`分区工具时，则分类类型设置为`EF02`

#### 4.3.1.7 进入grub命令行

在传统的`grub`上，可以直接在`bash`下敲入`grub`命令进入命令交互模式，但`grub2`只能在系统启动前进入`grub`交互命令行

按下`e`见可以编辑所选菜单对应的`grub`菜单配置项，按下`c`键可以进入`grub`命令行交互模式

### 4.3.2 安装grub2

**这里的安装指的不是安装`grub`程序，而是安装`Boot loader`，但一般都称之为安装`grub`，且后文都是这个意思**

#### 4.3.2.1 grub安装命令

安装方式非常简单，只需调用`grub2-install`，然后给定安装到的设备名即可

```sh
grub2-install /dev/sda
```

这样的安装方式，默认会将`img`文件放入到`/boot`目录下，如果想自定义放置位置，则使用`--boot-directory`选项指定，可用于测试练习`grub`的时候使用，但在真实的`grub`环境下不建议做任何改动

```sh
grub2-install --boot-director=/mnt/boot /dev/fd0
```

如果是`EFI`固件平台，则必须挂载好`efi`系统分区，一般会挂在`/boot/efi`下，这是默认的，此时可直接使用`grub2-install`安装

```sh
grub2-install
```

如果不是挂载在`/boot/efi`下，则使用`--efi-directory`指定`efi`系统分区路径

```sh
grub2-install --efi-directory=/mnt/efi
```

#### 4.3.2.2 [各种img和stage文件的说明](https://www.gnu.org/software/grub/manual/grub/html_node/Images.html#Images)

`img`文件是`grub2`生成的，`stage`文件是传统`grub`生成的。下面是各种文件的说明

##### 4.3.2.2.1 grub2中的img文件

`grub2`生成了好几个`img`文件，有些分布在`/usr/lib/grub/i386-pc`目录下，有些分布在`/boot/grub2/i386-pc`目录

下图描述了各个`img`文件之间的关系。其中`core.img`是动态生成的，路径为`/boot/grub2/i386-pc/core.img`，而其他的`img`则存在于`/usr/lib/grub/i386-pc`目录下。当然，在安装`grub`时，`boot.img`会被拷贝到`/boot/grub2/i386-pc`目录下

![4-3-2-2-1](/images/Linux-定制发行版/4-3-2-2-1.png)

1. `boot.img`
    * 在`BIOS`平台下，`boot.img`是`grub`启动的第一个`img`文件，它被写入到`MBR`中或分区的`boot sector`中，因为`boot sector`的大小是`512`字节，所以该`img`文件的大小也是`512`字节
    * `boot.img`唯一的作用是读取属于`core.img`的第一个扇区并跳转到它身上，将控制权交给该扇区的`img`。由于体积大小的限制，`boot.img`无法理解文件系统的结构，因此`grub2-install`将会把`core.img`的位置硬编码到`boot.img`中，这样就一定能找到`core.img`的位置
1. `core.img`
    * `core.img`根据`diskboot.img`、`kernel.img`和一系列的模块被`grub2-mkimage`程序动态创建。`core.img`中嵌入了足够多的功能模块以保证`grub`能访问`/boot/grub`，并且可以加载相关的模块实现相关的功能，例如加载启动菜单、加载目标操作系统的信息等，由于`grub2`大量使用了动态功能模块，使得`core.img`体积变得足够小
    * `core.img`中包含了多个`img`文件的内容，包括`diskboot.img`、`kernel.img`等
    * `core.img`的安装位置随`MBR`磁盘和`GPT`磁盘而不同
1. `diskboot.img`
    * 如果启动设备是硬盘，即从硬盘启动时，`core.img`中的第一个扇区的内容就是`diskboot.img`。`diskboot.img`的作用是读取`core.img`中剩余的部分到内存中，并将控制权交给`kernel.img`，由于此时还不识别文件系统，所以将`core.img`的全部位置以block列表的方式编码，使得`diskboot.img`能够找到剩余的内容。
    * 该`img`文件因为占用一个扇区，所以体积为512字节
1. `cdboot.img`
    * 如果启动设备是光驱(`cd-rom`)，即从光驱启动时，`core.img`中的第一个扇区的的内容就是`cdboo.img`。它的作用和`diskboot.img`是一样的
1. `pexboot.img`
    * 如果是从网络的PXE环境启动，`core.img`中的第一个扇区的内容就是`pxeboot.img`。
1. `kernel.img`
    * `kernel.img`文件包含了`grub`的基本运行时环境：设备框架、文件句柄、环境变量、救援模式下的命令行解析器等等。很少直接使用它，因为它们已经整个嵌入到了`core.img`中了。**注意，`kernel.img`是`grub`的`kernel`，和操作系统的内核无关**
    * 如果细心的话，会发现`kernel.img`本身就占用28KB空间，但嵌入到了`core.img`中后，`core.img`文件才只有26KB大小。这是因为`core.img`中的`kernel.img`是被压缩过的
1. `lnxboot.img`
    * 该`img`文件放在`core.img`的最前部位，使得`grub`像是`linux`的内核一样，这样`core.img`就可以被LILO的`image=`识别。当然，这是配合LILO来使用的，但现在谁还适用LILO呢
1. `*.mod`
    * 各种功能模块，部分模块已经嵌入到`core.img`中，或者会被`grub`自动加载，但有时也需要使用`insmod`命令手动加载

##### 4.3.2.2.2 传统grub中的stage文件

`grub2`的设计方式和传统`grub`大不相同，因此和`stage`之间的对比关系其实没那么标准，但是将它们拿来比较也有助于理解`img`和`stage`文件的作用。

`stage`文件也分布在两个地方：`/usr/share/grub/RELEASE`目录下和`/boot/grub`目录下，`/boot/grub`目录下的`stage`文件是安装`grub`时从`/usr/share/grub/RELEASE`目录下拷贝过来的

1. `stage1`
    * `stage1`文件在功能上等价于`boot.img`文件。目的是跳转到`stage1_5`或`stage2`的第一个扇区上
1. `*_stage1_5`
    * `*stage1_5`文件包含了各种识别文件系统的代码，使得`grub`可以从文件系统中读取体积更大功能更复杂的`stage2`文件。从这一方面考虑，它类似于`core.img`中加载对应文件系统模块的代码部分，但是`core.img`的功能远比`stage1_5`多
    * `stage1_5`一般安装在`MBR`后、第一个分区前的那段空闲空间中，也就是`MBR gap`空间，它的作用是跳转到`stage2`的第一个扇区。
    * 其实传统的`grub`在某些环境下是可以不用`stage1_5`文件就能正常运行的，但是`grub2`则不能缺少`core.img`
1. `stage2`
    * `stage2`的作用是加载各种环境和加载内核，在`grub2`中没有完全与之相对应的`img`文件，但是`core.img`中包含了`stage2`的所有功能
    * 当跳转到`stage2`的第一个扇区后，该扇区的代码负责加载`stage2`剩余的内容
    * 注意，`stage2`是存放在磁盘上的，并没有像`core.img`一样嵌入到磁盘上
1. `stage2_eltorito`
    * 功能上等价于`grub2`中的`core.img`中的`cdboot.img`部分。一般在制作救援模式的`grub`时才会使用到`cd-rom`相关文件
1. `pxegrub`
    * 功能上等价于`grub2`中的`core.img`中的`pxeboot.img`部分

#### 4.3.2.3 安装grub涉及的过程

安装`grub2`的过程大体分两步：

1. 一是根据`/usr/lib/grub/i386-pc/`目录下的文件生成`core.img`，并拷贝`boot.img`和`core.img`涉及的某些模块文件到`/boot/grub2/i386-pc/`目录下
1. 二是根据`/boot/grub2/i386-pc`目录下的文件向磁盘上写`boot loader`

当然，到底是先拷贝，还是先写`boot loader`，没必要去搞清楚，只要`/boot/grub2/i386-pc`下的`img`文件一定能通过`grub2`相关程序再次生成`boot loader`。所以，既可以认为`/boot/grub2/i386-pc`目录下的`img`文件是`boot loader`的特殊备份文件，也可以认为是`boot loader`的源文件

不过，`img`文件和`boot loader`的内容是不一致的，因为`img`文件还要通过`grub2`相关程序来转换才是真正的`boot loader`

对于传统的`grub`而言，拷贝的不是`img`文件，而是`stage`文件。

### 4.3.3 命令行和菜单项中的命令

#### 4.3.3.1 [grub菜单](https://www.gnu.org/software/grub/manual/grub/html_node/menuentry.html#menuentry)

**菜单格式如下**

```sh
menuentry <title> [--class=<class> ...] [--users=<users>] [--unrestricted] [--hotkey=<key>] [--id=<id>] { 
    command; 
    ...
}
```

这是`grub.cfg`中最重要的项。该命令定义了一个名为`<title>`的`grub`菜单项。执行顺序如下：

1. 执行大括号中的命令列表
1. 如果大括号中的命令全部执行成功，且成功加载了对应的内核，将执行`boot`命令（`menuentry`都会在最后隐式携带一个`boot`命令），随后`grub`就将控制权交给了操作系统内核

#### 4.3.3.2 命令

##### 4.3.3.2.1 help命令

```sh
help [pattern]
```

显示能匹配到`pattern`的所有命令的说明信息和`usage`信息，如果不指定`patttern`，将显示所有命令的简短信息

##### 4.3.3.2.2 boot命令

`boot`：用于启动已加载的操作系统

只在交互式命令行下可用。其实在`menuentry`命令的结尾就隐含了`boot`命令

##### 4.3.3.2.3 set命令和unset命令

1. `set`：设置环境变量的值，如果不给定参数，则列出当前环境变量
1. `unset`：释放环境变量的值

**示例**

```sh
set [envvar=value]
unset envvar
```

##### 4.3.3.2.4 lsmod命令和insmod命令

1. `lsmod`：列出已加载的模块
1. `insmod`：调用指定的模块

##### 4.3.3.2.5 linux和linux16命令

```sh
linux file [kernel_args]
linux16 file [kernel_args]
linuxefi file [kernel_args]
```

`linux`/`linux16`/`linuxefi`：都表示装载指定的内核文件，并传递内核启动参数。`linux16`表示以传统的16位启动协议启动内核，`linux`表示以`32`位启动协议启动内核，但`linux`命令比`linux16`有一些限制。但绝大多数时候，它们是可以通用的

在`linux`或`linux16`或`linuxefi`命令之后，必须紧跟着使用`initrd`或`initrd16`或`initrdefi`命令装载`init ramdisk`文件

内核文件一般为`/boot`分区下的`vmlinuz-RELEASE_NUM`文件

在`grub`环境下，`boot`分区被当作`root device`，即根设备，假如`boot`分区为第一块磁盘的第一个分区，则应该写成

```sh
linux (hd0,msdos1)/vmlinuz-XXX
```

或者相对路径

```sh
set root='hd0,msdos1'
linux /vmlinuz-XXX
```

在grub阶段可以传递内核的启动参数(内核的参数包括3类：编译内核时参数，启动时参数和运行时参数)，可以传递的启动参数非常非常多，[完整的启动参数列表](http://redsymbol.net/linux-kernel-boot-parameters)。这里只列出几个常用的

1. `init=`：指定Linux启动的第一个进程init的替代程序
1. `root=`：指定`根文件系统`所在分区，在grub中，该选项必须给定。另外，root启动参数有多种定义方式
    * 可以使用UUID的方式指定，例如`linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=UUID=edb1bf15-9590-4195-aa11-6dac45c7f6f3 ro rhgb quiet LANG=en_US.UTF-8`
    * 也可以直接指定根文件系统所在分区，如`linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=/dev/sda2 ro rhgb quiet LANG=en_US.UTF-8`
1. `ro,rw`：启动时，根分区以只读还是可读写方式挂载。不指定时默认为ro
1. `initrd`：指定`init ramdisk`的路径。在grub中因为使用了`initrd`或`initrd16`命令，所以不需要指定该启动参数
1. `rhgb`：以图形界面方式启动系统
1. `quiet`：以文本方式启动系统，且禁止输出大多数的log message
1. `net.ifnames=0`：用于CentOS 7，禁止网络设备使用一致性命名方式
1. `biosdevname=0`：用于CentOS 7，也是禁止网络设备采用一致性命名方式。
* 只有`net.ifnames`和`biosdevname`同时设置为0时，才能完全禁止一致性命名，得到eth0-N的设备名

##### 4.3.3.2.6 initrd和initrd16命令

```sh
initrd file
initrd16 file
initrdefi file
```

只能紧跟在`linux`或`linux16`或`linuxefi`命令之后使用，用于为即将启动的内核传递`init ramdisk`路径

同样，基于根设备，可以使用绝对路径，也可以使用相对路径。路径的表示方法和`linux`或`linux16`或`linuxefi`命令相同，例如

```sh
linux16 /vmlinuz-0-rescue-d13bce5e247540a5b5886f2bf8aabb35 root=UUID=b2a70faf-aea4-4d8e-8be8-c7109ac9c8b8 ro crashkernel=auto quiet
initrd16 /initramfs-0-rescue-d13bce5e247540a5b5886f2bf8aabb35.img
```

##### 4.3.3.2.7 search命令

```sh
search [--file|--label|--fs-uuid] [--set [var]] [--no-floppy] [--hint args] name
```

通过文件`[--file]`、卷标`[--label]`、文件系统UUID`[--fs-uuid]`来搜索设备。

如果使用了`--set`选项，则会将第一个找到的设备设置为环境变量`var`的值，默认的变量`var`为`root`

搜索时可使用`--no-floppy`选项来禁止搜索软盘，因为软盘速度非常慢，已经被淘汰了

有时候还会指定`--hint=XXX`，表示优先选择满足提示条件的设备，若指定了多个`hint`条件，则优先匹配第一个`hint`，然后匹配第二个，依次类推

```sh
if [ x$feature_platform_search_hint = xy ]; then

  search --no-floppy --fs-uuid --set=root --hint-bios=hd0,msdos1 --hint-efi=hd0,msdos1 --hint-baremetal=ahci0,msdos1 --hint='hd0,msdos1'  367d6a77-033b-4037-bbcb-416705ead095

else

  search --no-floppy --fs-uuid --set=root 367d6a77-033b-4037-bbcb-416705ead095

fi

linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=UUID=b2a70faf-aea4-4d8e-8be8-c7109ac9c8b8 ro crashkernel=auto quiet LANG=en_US.UTF-8

initrd16 /initramfs-3.10.0-327.el7.x86_64.img
```

* 上述`if`语句中的第一个`search`中搜索uuid为`367d6a77-033b-4037-bbcb-416705ead095`的设备，但使用了多个`hint`选项，表示先匹配`bios`平台下`/boot`分区为`(hd0,msdos1)`的设备，之后还指定了几个`hint`，但因为`search`使用的是`uuid`搜索方式，所以这些`hint`选项是多余的，因为单磁盘上分区的`uuid`是唯一的

再举个例子，如果某启动设备上有两个`boot`分区(如多系统共存时)，分别是`(hd0,msdos1)`和`(hd0,msdos5)`，如果此时不使用`uuid`搜索，而是使用`label`方式搜索

```sh
search --no-floppy --fs-label=boot --set=root --hint=hd0,msdos5
```

#### 4.3.3.3 几个常设置的内置变量

##### 4.3.3.3.1 root变量

该变量指定`根设备`的名称，使得后续使用从`/`开始的相对路径引用文件时将从该`root`变量指定的路径开始。一般该变量是`grub`启动的时候由`grub`根据`prefix`变量设置而来的

例如，如果`grub`安装在第一个硬盘的的第一个分区上，那么`prefix`就是`(hd0,msdos1)/boot/grub`；`root`就是`(hd0,msdos1)`

**注意：在Linux中，从根`/`开始的路径表示绝对路径，如`/etc/fstab`。但grub中，从`/`开始的表示相对路径，其相对的基准是`root`变量设置的值，而使用`(dev_name)/`开始的路径才表示绝对路径**

**一般`root`变量都表示`/boot`所在的分区**。但这不是绝对的，如果设置为根文件系统所在分区，如`root=(hd0,gpt2)`，则后续可以使用`/etc/fstab`来引用`(hd0,gpt2)/etc/fstab`文件

**另外，`root`变量还应该于`linux`或`linux16`或`linuxefi`命令所指定的内核启动参数`root=`区分开来，内核启动参数中的`root=`的意义是固定的，其指定的是`根文件系统所在分区`。例如：**

```sh
set root='hd0,msdos1'

linux16 /vmlinuz-3.10.0-327.el7.x86_64 root=UUID=b2a70faf-aea4-4d8e-8be8-c7109ac9c8b8 ro crashkernel=auto quiet LANG=en_US.UTF-8

initrd16 /initramfs-3.10.0-327.el7.x86_64.img
```

**一般情况下，`/boot`都会单独分区，所以`root`变量指定的根设备和`root`启动参数所指定的根分区不是同一个分区**，除非/boot不是单独的分区，而是在根分区下的一个目录

##### 4.3.3.3.2 chosen变量

当开机时选中某个菜单项启动时，该菜单的`title`将被赋值给`chosen`变量。该变量一般只用于引用，而不用于修改

##### 4.3.3.3.3 cmdpath变量

`grub2`加载的`core.img`的目录路径，是绝对路径，即包括了设备名的路径，如`(hd0,gpt1)/boot/grub2/`。该变量值不应该修改

##### 4.3.3.3.4 default

指定默认的菜单项，一般其后都会跟随`timeout`变量

`default`指定默认菜单时，可使用菜单的`title`，也可以使用菜单的`id`，或者数值顺序，当使用数值顺序指定`default`时，从0开始计算

##### 4.3.3.3.5 timeout变量

设置菜单等待超时时间，设置为0时将直接启动默认菜单项而不显示菜单，设置为`-1`时将永久等待手动选择

##### 4.3.3.3.6 fallback变量

当默认菜单项启动失败，则使用该变量指定的菜单项启动，指定方式同`default`，可使用数值(从0开始计算)、`title`或`id`指定

##### 4.3.3.3.7 grub_platform变量

指定该平台是`pc`还是`efi`，`pc`表示的就是传统的`bios`平台

该变量不应该被修改，而应该被引用，例如用于if判断语句中

##### 4.3.3.3.8 prefix变量

在`grub`启动的时候，`grub`自动将`/boot/grub2`目录的绝对路径赋值给该变量，使得以后可以直接从该变量所代表的目录下加载各文件或模块。

例如，可能自动设置为`set prefix = (hd0,gpt1)/boot/grub2/`

所以可以使用`$prefix/grubN.cfg`来引用`/boot/grub2/grubN.cfg`文件。

该变量不应该修改，且若手动设置，则必须设置正确，否则牵一发而动全身

## 4.4 重要文件介绍

### 4.4.1 vmlinuz

`vmlinuz`是可引导的、压缩的内核。`vm`代表`Virtual Memory`。Linux支持虚拟内存，不像老的操作系统比如DOS有640KB内存的限制。Linux能够使用硬盘空间作为虚拟内存，因此得名`vm`。`vmlinuz`是可执行的Linux内核，路径为`/boot/vmlinuz`（具体来说形如`/boot/vmlinuz-3.10.0-957.el7.x86_64`）

### 4.4.2 initrd

`initrd`是`initial ramdisk`的简写。`initrd`是在系统引导过程中挂载的一个`临时根文件系统`，用来支持两阶段的引导过程。**`initrd`文件中包含了各种可执行程序和驱动程序，它们可以用来挂载实际的根文件系统**（当挂载完真实的根文件系统之后，可以将这个`initrd`卸载，并释放内存，在很多嵌入式Linux系统中，`initrd`就是最终的根文件系统）

`initrd`中包含了实现这个目标所需要的目录和可执行程序的最小集合，例如将内核模块加载到内核中所使用的`insmod`工具

**`initrd`是什么文件系统？内核直接能识别这个文件系统吗？**：`initrd`的文件系统是`ext2`，内核应该内置了`ext2`的相关模块

#### 4.4.2.1 initramfs

`kernel 2.6`以来都是`initramfs`了，只是很多还沿袭传统使用`initrd`的名字

`initramfs`的工作方式更加简单直接一些，启动的时候加载内核和`initramfs`到内存执行，内核初始化之后，切换到用户态执行`initramfs`的程序/脚本，加载需要的驱动模块、必要配置等，然后加载`rootfs`切换到真正的`rootfs`上去执行后续的`init`过程。`initrd`是`kernel 2.4`及更早的用法（现在你能见到的`initrd`文件实际差不多都是`initramfs`了），运行过程大概是内核启动，执行一些`initrd`的内容，加载模块啥的，然后交回控制权给内核，最后再切到用户态去运行用户态的启动流程

**可以通过命令行工具`lsinitrd`查看`initramfs`的内容**

```sh
lsinitrd
lsinitrd /boot/initramfs-$(uname -r).img
```

## 4.5 参考

* [UEFI 引导与 BIOS 引导在原理上有什么区别？](https://www.zhihu.com/question/21672895)
* [How to make Windows 7 USB flash install media from Linux?](https://serverfault.com/questions/6714/how-to-make-windows-7-usb-flash-install-media-from-linux)
* [详解uefi、legacy以及U盘格式对系统安装的影响](https://zhuanlan.zhihu.com/p/91131208)
* [MBR与GPT](https://zhuanlan.zhihu.com/p/26098509)
* [聊聊BIOS、UEFI、MBR、GPT、GRUB](https://segmentfault.com/a/1190000020850901)
* [GRUB bootloader - Full tutorial](https://www.dedoimedo.com/computers/grub.html)
* [GRUB 2 bootloader - Full tutorial](https://www.dedoimedo.com/computers/grub-2.html)
* [GRUB 官方文档(简体中文)](https://wiki.archlinux.org/index.php/GRUB_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))
* [grub2详解(翻译和整理官方手册)](https://www.cnblogs.com/f-ck-need-u/archive/2017/06/29/7094693.html)
* [GRUB2配置文件"grub.cfg"详解(GRUB2实战手册)](http://www.jinbuguo.com/linux/grub.cfg.html)
* [GRUB legacy和GRUB 2介绍 与 命令【包含kernel 与 initrd的详解】使用](https://blog.csdn.net/xiaoyi23000/article/details/51461256)
* [Linux启动引导程序（GRUB）加载内核的过程](https://blog.csdn.net/u010783226/article/details/106070429)
* [GRUB入门教程](https://wiki.ubuntu.org.cn/GRUB%E5%85%A5%E9%97%A8%E6%95%99%E7%A8%8B)
* [What exactly is GRUB?](https://askubuntu.com/questions/347203/what-exactly-is-grub)
* [你知道计算机启动过程吗？](https://zhuanlan.zhihu.com/p/60751152)
* [系统启动流程](https://blog.csdn.net/qq_41453285/article/details/88632950)
* [UEFI启动和Bios（Legacy）启动的区别](https://blog.csdn.net/zhangxiangweide/article/details/95342334)
* [Linux initial RAM disk (initrd) overview](https://developer.ibm.com/technologies/linux/articles/l-initrd/)
* [Initramfs/指南](https://wiki.gentoo.org/wiki/Initramfs/Guide/zh-cn)
* [浅谈linux启动的那些事（initrd.img）](https://blog.csdn.net/li33293884/article/details/53183622)
* [boot分区-百度百科](https://baike.baidu.com/item/boot%E5%88%86%E5%8C%BA/16830421?fr=aladdin)
* [initrd-百度百科](https://baike.baidu.com/item/initrd/3239796?fr=aladdin)
* [grub Kernel_parameters](https://wiki.archlinux.org/index.php/Kernel_parameters)
* [grub Kernel_parameters（极详细）](https://www.kernel.org/doc/html/latest/admin-guide/kernel-parameters.html)
* [启动流程、模块管理、BootLoader(Grub2)](https://www.jianshu.com/p/7276a98e74cf)
* [What on earth is Dracut?](https://www.techradar.com/news/software/operating-systems/what-on-earth-is-dracut-1078647)
* [initrd和initramfs的区别是什么?](https://www.zhihu.com/question/22045825)
* [The difference between initrd and initramfs?](https://stackoverflow.com/questions/10603104/the-difference-between-initrd-and-initramfs)
* [Initramfs 原理和实践](https://www.cnblogs.com/wipan/p/9269505.html)

# 5 Ubuntu装机

**博主安装的是server版本**

1. 设置root密码：`sudo passwd root`
1. 网卡配置文件为`/etc/network/interfaces`（无需修改）
1. 安装openssh：`apt-get install -y openssh-server`
1. 修改ssh配置文件`/etc/ssh/sshd_config`，将`PermitRootLogin`改为`yes`，重启sshd：`service ssh restart`

# 6 Ubuntu自定义发行版iso镜像制作

## 6.1 初次尝试制作镜像

在本小结，我们将iso镜像文件解压，然后将解压之后的文件原封不动地打成iso镜像，目的是为了熟悉镜像制作的各个命令行工具

为了减少环境因素对镜像制作造成的影响，这里使用docker容器来进行打包，DockerFile如下，非常简单，基础镜像为`centos:7.6.1810`，并用yum安装了镜像制作的相关工具

```Dockerfile
FROM centos:7.6.1810

WORKDIR /

RUN yum install -y createrepo genisoimage syslinux-utils syslinux isomd5sum
```

接下来制作docker镜像

```sh
docker build -t create-iso-env:1.0.0 .
```

运行docker。这里挂载了3个目录

1. `/Users/hechenfeng/Desktop/source/ubuntu-18.04.4-live-server-amd64`：该目录是我解压iso文件之后得到的目录，对应于容器中的`/source`目录
1. `/Users/hechenfeng/Desktop/workspace`：该目录是镜像制作的工作目录，对应于容器中的`/workspace`目录
1. `/Users/hechenfeng/Desktop/iso`：该目录用于放置生成的iso文件，对应于容器中的`/target`目录

```sh
docker run \
-v /Users/hechenfeng/Desktop/source/ubuntu-18.04.4-live-server-amd64:/source \
-v /Users/hechenfeng/Desktop/workspace:/workspace \
-v /Users/hechenfeng/Desktop/iso:/target \
-it create-iso-env:1.0.0 bash
```

**以下命令均在容器中执行**

第一步：将`/source`目录中的内容，拷贝到`/workspace`目录中

```sh
# 删除除了. ..之外的所有文件以及目录，包括隐藏文件以及隐藏目录
rm -rf /workspace/{..?*,.[!.]*,*}

# 递归拷贝所有文件以及目录，包括隐藏文件以及隐藏目录
cp -vrf /source/. /workspace/
```

第二步：接下来，就可以制作镜像了

```sh
fileName=/target/my-ubuntu-1.iso
label="Custom Ubuntu"

genisoimage \
       -V "${label}" \
       -A "${label}" \
       -o ${fileName} \
       -joliet-long \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -boot-info-table \
       -eltorito-alt-boot -e boot/grub/efi.img \
       -no-emul-boot \
       -R -J -v -T \
       /workspace/

isohybrid --uefi ${fileName}

implantisomd5 ${fileName}
```

## 6.2 使用kickstart定制化安装流程

我们重新运行一个容器来制作镜像，这里使用另一个iso（`ubuntu-18.04.4-desktop-amd64.iso`）来示范

```sh
docker run \
-v /Users/hechenfeng/Desktop/source/ubuntu-18.04.4-desktop-amd64:/source \
-v /Users/hechenfeng/Desktop/workspace:/workspace \
-v /Users/hechenfeng/Desktop/iso:/target \
-it create-iso-env:1.0.0 bash
```

**以下命令均在容器中执行**

第一步：将`/source`目录中的内容，拷贝到`/workspace`目录中

* **注意，拷贝时要用`cp -vrf /source/. /workspace/`，而不是`cp -vrf /source/* /workspace/`，因为`/source`目录下存在一个隐藏文件夹`.disk`，如果该文件夹丢失的话，做出来的iso在装机阶段会出现`unable to find a medium containing a live file system`**

```sh
# 删除除了. ..之外的所有文件以及目录，包括隐藏文件以及隐藏目录
rm -rf /workspace/{..?*,.[!.]*,*}

# 递归拷贝所有文件以及目录，包括隐藏文件以及隐藏目录
cp -vrf /source/. /workspace/
```

第二步：编写`preseed.cfg`文件，路径为`/workspace/preseed.cfg`

* 如何生成加密的密码
    1. `openssl passwd -crypt <my password>`
    1. `perl -e "print crypt('<my password>','sa');"`
    1. `ruby -e 'print "<my password>".crypt("JU"); print("\n");'`
    1. `php -r "print(crypt('<my password>','JU') . \"\n\");"`
    1. `python -c 'import crypt; print crypt.crypt("<my password>","Fx")'`

```sh
cat > /workspace/preseed.cfg << 'EOF'
### Partitioning
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-auto/choose_recipe select atomic

# This makes partman automatically partition without confirmation
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Locale
d-i debian-installer/locale string en_US
d-i console-setup/ask_detect boolean false
d-i console-setup/layoutcode string us

# Network
d-i netcfg/get_hostname string unassigned-hostname
d-i netcfg/get_domain string unassigned-domain
d-i netcfg/choose_interface select auto

# Clock
d-i clock-setup/utc-auto boolean true
d-i clock-setup/utc boolean true
d-i time/zone string US/Pacific
d-i clock-setup/ntp boolean true

# Packages, Mirrors, Image
d-i base-installer/kernel/override-image string linux-server
d-i base-installer/kernel/override-image string linux-image-amd64
d-i mirror/country string US
d-i mirror/http/proxy string
d-i apt-setup/restricted boolean true
d-i apt-setup/universe boolean true
d-i pkgsel/install-language-support boolean false
tasksel tasksel/first multiselect ubuntu-desktop

# Users
d-i passwd/user-fullname string Liuyehcf
d-i passwd/username string liuyehcf
d-i passwd/user-password-crypted password kVLmI88znPkHI
d-i passwd/root-login boolean true
d-i passwd/root-password-crypted password kVLmI88znPkHI
d-i user-setup/allow-password-weak boolean true

# Grub
d-i grub-installer/grub2_instead_of_grub_legacy boolean true
d-i grub-installer/only_debian boolean true
d-i finish-install/reboot_in_progress note

# Custom Commands
EOF
```

第三步：修改grub配置文件`/workspace/isolinux/txt.cfg`，关联这个`kickstart`文件（`/workspace/preseed.cfg`）

```sh
mv /workspace/isolinux/txt.cfg /workspace/isolinux/txt.cfg.bak

# 这里要写preseed.cfg相对于/workspace的路径
cat > /workspace/isolinux/txt.cfg << 'EOF'
default live-install
label live-install
  menu label ^Install Ubuntu
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed.cfg auto=true priority=critical debian-installer/locale=en_US keyboard-configuration/layoutcode=us ubiquity/reboot=true languagechooser/language-name=English countrychooser/shortlist=US localechooser/supported-locales=en_US.UTF-8 boot=casper automatic-ubiquity initrd=/casper/initrd quiet splash noprompt noshell ---
EOF

diff /workspace/isolinux/txt.cfg.bak /workspace/isolinux/txt.cfg
```

第四步：接下来，就可以制作镜像了

```sh
fileName=/target/my-ubuntu-2.iso
label="Custom Ubuntu"

genisoimage \
       -V "${label}" \
       -A "${label}" \
       -o ${fileName} \
       -joliet-long \
       -b isolinux/isolinux.bin \
       -c isolinux/boot.cat \
       -no-emul-boot \
       -boot-load-size 4 \
       -boot-info-table \
       -eltorito-alt-boot -e boot/grub/efi.img \
       -no-emul-boot \
       -R -J -v -T \
       /workspace/

isohybrid --uefi ${fileName}

implantisomd5 ${fileName}
```

## 6.3 其他

### 6.3.1 确定目标磁盘挂载点

如何确定目标磁盘的挂载点：`mount | grep <硬盘盘符>`，例如`mount | grep sda`

### 6.3.2 下载某个软件的deb包1

我们可以通过`apt install -d <name>`来下载某个软件及其所有依赖的deb包。deb包的下载目录是：`/var/cache/apt/archives`

### 6.3.3 ~~下载某个软件的deb包2~~

我们可以通过`apt-get download <name>`来下载软件包，但是该命令只会下载指定的软件包，而不会下载依赖以及依赖的依赖

我们如何确定一个软件包以及所有依赖？可以借助工具`apt-rdepends`

```sh
# 安装apt-rdepends
apt install apt-rdepends

# 查看依赖
apt-rdepends <name>
```

下载完成后，可以通过`dpkg -i *.deb`来进行软件安装

我们可以借助下面的脚本来完成依赖分析以及下载

```sh
cat > ~/download.sh << 'EOF'
#!/bin/bash

# 这里填写你需要安装的软件包
SOFTWARES=( "cron" "dnsutils" "cpufrequtils" "jq" )
DEB_POOL=( )

function isInstalled() {
    local name=$1
    dpkg -l ${name} > /dev/null 2>&1
    return $?
}

function getDebs() {
    local name=$1
    output="$(apt-rdepends ${name})"
    leftNames=( $(echo "$output" | grep -v ' ') )
    rightNames=( $(echo "$output" | grep : | awk -F ': ' '{print $2}' | awk '{print $1}') )
    combineNames=( $(echo ${leftNames[@]} ${rightNames[@]} | tr ' ' '\n' | sort | uniq) )

    echo ${combineNames[@]}
}

for software in ${SOFTWARES[@]}
do
    depends=( $(getDebs ${software}) )
    for depend in ${depends[@]}
    do  
        isInstalled ${depend}
        if [ $? -ne 0 ]; then
            echo "depend '${depend}' need install"
            DEB_POOL[${#DEB_POOL[@]}]=${depend}
        else
            echo "depend '${depend}' needn't install"
        fi
    done
done

DEB_POOL=( $(echo ${DEB_POOL[@]} | sort | uniq) )

for deb in ${DEB_POOL[@]}
do
    echo "download deb '${deb}'"
    apt-get download -y ${deb}
done
EOF
```

## 6.4 参考

* [Automatic Installation](https://help.ubuntu.com/lts/installation-guide/powerpc/ch04s05.html)
* [Appendix B. Automating the installation using preseeding](https://help.ubuntu.com/lts/installation-guide/powerpc/apb.html)
* [ubuntu preseed无人应答安装](https://zhangguanzhang.github.io/2019/08/06/preseed/)
* [preseed 示例](https://zhangguanzhang.github.io/2019/08/06/preseed/)
* [定制ubuntu发行版](https://blog.csdn.net/wf_wf_wf_1985/article/details/5964246)
* [如何创建完全无人值守的Ubuntu Desktop 16.04.1 LTS安装？](https://qastack.cn/ubuntu/806820/how-do-i-create-a-completely-unattended-install-of-ubuntu-desktop-16-04-1-lts)
* [如何创建完全无人值守的Ubuntu安装？](https://qastack.cn/ubuntu/122505/how-do-i-create-a-completely-unattended-install-of-ubuntu)
* [ubuntu安装光盘iso修改方法总结](http://www.seteuid0.com/ubuntu%E5%AE%89%E8%A3%85%E5%85%89%E7%9B%98iso%E4%BF%AE%E6%94%B9%E6%96%B9%E6%B3%95%E6%80%BB%E7%BB%93/)
* [InstallCDCustomization](https://help.ubuntu.com/community/InstallCDCustomization)
* [定制ubuntu镜像](https://blog.csdn.net/u011774239/article/details/52328374?utm_source=blogxgwz0)
* [XPS 9560 cannot install Ubuntu. ACPI Error / Empty Installation type / "unable to find a medium containing a live file system”](https://askubuntu.com/questions/1021369/xps-9560-cannot-install-ubuntu-acpi-error-empty-installation-type-unable-t)
* [debian软件包下载站](https://www.debian.org/distrib/packages)
* [ubuntu安装/查看已安装包的方法](https://blog.csdn.net/sunchenzl/article/details/82117212)

# 7 查看版本号

1. `lsb_release -a`：`yum install -y redhat-lsb`
1. `uname -r`：内核版本号
1. `/etc/*-release`，包括
    * `/etc/os-release`
    * `/etc/centos-release`：发行版
1. `/proc/version`

# 8 制作U盘启动盘

## 8.1 MacOS

```sh
# 先列出所有设备
diskutil list

# 找到u盘对应的设备，比如这里是 /dev/disk6，卸载它
diskutil unmountDisk /dev/disk6

# 烧制ISO文件到u盘
sudo dd if=<iso文件路径> of=/dev/disk6 bs=1m

# 弹出磁盘
diskutil eject /dev/disk6
```

## 8.2 Linux

```sh
# 先列出所有设备
fdisk -l

# 找到u盘对应的设备，比如这里是 /dev/sdb，卸载它
umount /dev/sdb

# 烧制ISO文件到u盘，通过status=progress显示实时进度
sudo dd bs=4M if=<iso文件路径> of=/dev/sdb status=progress oflag=sync
```

