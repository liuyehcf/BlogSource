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

## 2.1 gcc

编辑`/etc/apt/sources.list`，添加如下源：

```conf
deb http://dk.archive.ubuntu.com/ubuntu/ trusty main universe
deb http://dk.archive.ubuntu.com/ubuntu/ xenial main universe
deb http://dk.archive.ubuntu.com/ubuntu/ bionic main universe
deb http://dk.archive.ubuntu.com/ubuntu/ focal main universe
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
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ trusty main universe
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial main universe
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ bionic main universe
deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ focal main universe
```

再次执行`apt update`，安装不同版本的`gcc/g++`

```sh
apt update

apt install -y gcc-5 g++-5
apt install -y gcc-6 g++-6
apt install -y gcc-7 g++-7
apt install -y gcc-8 g++-8
apt install -y gcc-9 g++-9
apt install -y gcc-10 g++-10

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 5
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 5
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 6
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 6
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10

# gcc-11 and g++11 are already installed in ubuntu-22.04
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 11
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 11
```

**切换不同的gcc版本：**

```sh
update-alternatives --config gcc
update-alternatives --config g++
```

## 2.2 make

从[gnu-make](https://ftp.gnu.org/gnu/make/)下载`make-3.81.tar.gz`

```sh
tar -zxf make-3.81.tar.gz
cd make-3.81

./configure --prefix=/usr/local/make-3.81
make -j 4
```

会出现如下错误：

```
undefined reference to `__alloca'
```

修改`make-3.81/glob/glob.c`

```cpp
// 将
# if _GNU_GLOB_INTERFACE_VERSION == GLOB_INTERFACE_VERSION
// 改为
# if _GNU_GLOB_INTERFACE_VERSION >= GLOB_INTERFACE_VERSION
```

再次编译安装即可：

```sh
make -j 4

# make-3.81将会被安装到 /usr/local/make-3.81
make install
```

```sh
update-alternatives --install /usr/bin/make make /usr/bin/make 4
update-alternatives --install /usr/bin/make make /usr/local/make-3.81/bin 3
```

## 2.3 参考

* [ubuntu-install-gcc-6](https://gist.github.com/zuyu/7d5682a5c75282c596449758d21db5ed)
* [Ubuntu 20.04 - gcc version lower than gcc-7](https://askubuntu.com/questions/1235819/ubuntu-20-04-gcc-version-lower-than-gcc-7)
* [安裝 make 3.81 on Ubuntu 18](https://noiseyou99.medium.com/%E5%AE%89%E8%A3%9D-make-3-81-on-ubuntu-18-71350c1569e0)

# 3 Apt

* 源配置文件：`/etc/apt/sources.list`
* 格式：`deb http://site.example.com/debian distribution component1 component2 component3`
    * 其中，`distribution`可以参考[Ubuntu version history](https://en.wikipedia.org/wiki/Ubuntu_version_history)
        * `Trusty`：14.04
        * `Xenial`：16.04
        * `Bionic`：18.04
        * `Focal`：20.04
        * `Jammy`：22.04
* 添加`[trusted=yes]`可以绕开一些安全性设置，如下：
    ```sh
    deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ xenial main universe
    deb [trusted=yes] http://dk.archive.ubuntu.com/ubuntu/ bionic main universe
    ```

## 3.1 参考

* [https://www.linuxfordevices.com/tutorials/linux/fix-updating-from-such-a-repository-cant-be-done-securely-error](https://www.linuxfordevices.com/tutorials/linux/fix-updating-from-such-a-repository-cant-be-done-securely-error)
