---
title: Ubuntu-Trial
date: 2022-11-18 20:38:17
tags: 
- 原创
categories: 
- Operating System
---

**阅读更多**

<!--more-->

# 1 Network

用`NetworkManager`来配置网络

```sh
apt install -y network-manager
systemctl enable NetworkManager
systemctl start NetworkManager
```

编辑`/etc/NetworkManager/NetworkManager.conf`文件，确保包含如下内容

```conf
[main]
plugins=ifupdown,keyfile

[keyfile]
unmanaged-devices=*,except:type:wifi,except:type:wwan,except:type:ethernet

[ifupdown]
managed=true
```

通过`nmtui`添加网卡并启动

## 1.1 参考

* [NetworkManager doesn't show ethernet connection](https://askubuntu.com/questions/904545/networkmanager-doesnt-show-ethernet-connection)

# 2 Multiple compiling environments

编辑`/etc/apt/sources.list`，添加如下源：

```conf
deb http://dk.archive.ubuntu.com/ubuntu/ xenial main
deb http://dk.archive.ubuntu.com/ubuntu/ xenial universe
```

然后执行`apt update`，会报如下错误：

```
W: GPG error: http://dk.archive.ubuntu.com/ubuntu xenial InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 40976EAF437D05B5 NO_PUBKEY 3B4FE6ACC0B21F32
E: The repository 'http://dk.archive.ubuntu.com/ubuntu xenial InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```

修改`/etc/apt/sources.list`，添加`[trusted=yes]`，如下：

```conf
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial main
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial universe
```

再次执行`apt update`

## 2.1 参考

* [Ubuntu 20.04 - gcc version lower than gcc-7](https://askubuntu.com/questions/1235819/ubuntu-20-04-gcc-version-lower-than-gcc-7)

# 3 Apt

* 源配置文件：`/etc/apt/sources.list`
    * `[trusted=yes]`可以绕开一些安全性设置
    ```sh
    deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial main
    deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial universe
    ```

## 3.1 参考

* [https://www.linuxfordevices.com/tutorials/linux/fix-updating-from-such-a-repository-cant-be-done-securely-error](https://www.linuxfordevices.com/tutorials/linux/fix-updating-from-such-a-repository-cant-be-done-securely-error)
