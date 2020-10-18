---
title: Linux-Kernel
date: 2020-10-15 15:12:44
tags: 
- 原创
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 如何编译内核

__准备环境：这里我安装的系统是`CentOS-7-x86_64-Minimal-1908.iso`__

__第一步：安装编译相关的软件__

```sh
yum makecache
yum -y install ncurses-devel make gcc bc openssl-devel
yum -y install elfutils-libelf-devel
yum -y install rpm-build
```

__第二步：下载内核源码并解压__

```sh
yum install -y wget
wget -O ~/linux-4.14.134.tar.gz 'http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/v4.x/linux-4.14.134.tar.gz'
tar -zxvf ~/linux-4.14.134.tar.gz -C ~
```

__第三步：配置内核编译参数__

```sh
cd ~/linux-4.14.134
cp -v /boot/config-$(uname -r) .config

# 直接save然后exit即可
make menuconfig
```

__第四步：编译内核__

```sh
cd ~/linux-4.14.134
make rpm-pkg
```

__第五步：更新内核__

```sh
rpm -iUv ~/rpmbuild/RPMS/x86_64/*.rpm
```

## 1.1 参考

* [内核源码下载地址](http://ftp.sjtu.edu.cn/sites/ftp.kernel.org/pub/linux/kernel/)
* [Compile Linux Kernel on CentOS7](https://linuxhint.com/compile-linux-kernel-centos7/)
* [How to Compile a Linux Kernel](https://www.linux.com/topic/desktop/how-compile-linux-kernel-0/)

# 2 参考

* [Linux 网络协议栈开发（五）—— 二层桥转发蓝图（上）](https://blog.csdn.net/zqixiao_09/article/details/79057169)
