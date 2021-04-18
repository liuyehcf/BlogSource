---
title: Linux-常用工具
date: 2018-07-20 14:55:26
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 SSH

# 2 NTP

```sh
yum install -y ntp
systemctl restart ntpd
```

# 3 rc-local

`rc-local`用于在开机时执行一些初始化脚本，它默认是关闭的，可以通过以下命令开启

```sh
chmod +x /etc/rc.d/rc.local
chmod +x /etc/rc.local

systemctl enable rc-local.service
systemctl start rc-local.service
```

将需要开机执行的脚本的`绝对路径`，`追加`到`/etc/rc.local`文件尾，`/etc/rc.d/rc.local`文件不需要手动修改，生效后会自动将`/etc/rc.local`的内容同步到`/etc/rc.d/rc.local`中去

# 4 测速

**互联网测速：[speedtest](https://github.com/sivel/speedtest-cli)**

**局域网测速：iperf**

# 5 参考

* [Linux下使用Speedtest测试网速](https://www.linuxprobe.com/speedtest-network-in-linux.html)
* [使用iPerf进行网络吞吐量测试](https://www.jianshu.com/p/15f888309c72)
