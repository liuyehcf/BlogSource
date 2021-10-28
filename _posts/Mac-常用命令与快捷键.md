---
title: Mac-常用命令与快捷键
date: 2017-10-11 23:21:45
tags: 
- 摘录
categories: 
- Operating System
- OS X
---

**阅读更多**

<!--more-->

# 1 软件安装

## 1.1 brew

**格式：**

* `brew install <software>`
* `brew uninstall <software>`
* `brew update <software>`
* `brew search <software>`
* `brew list <software>`

# 2 启动服务

## 2.1 launchctl

**以ssh为例：**

* `sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist`
* `sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist`
* `sudo launchctl list | grep ssh`

## 2.2 其他方式

**mysql：**

* `mysql.server start`
* `mysql.server stop`

# 3 快捷键

## 3.1 清屏

`command + k`

## 3.2 显示隐藏文件夹

`⌘ + ⇧ + .`

**也有如下非快捷键的方法**

```
//显示
defaults write com.apple.finder AppleShowAllFiles -boolean true 
killall Finder//重启Finder

//隐藏
defaults write com.apple.finder AppleShowAllFiles -boolean false
killall Finder//重启Finder
```

## 3.3 微粒度音量调节

`⌥ + ⇧ + 音量调节按键`

## 3.4 应用图标抖动

在launchpad界面中，`⌃ + ⌥ + ⌘ + B`

## 3.5 emoji

`⌃ ＋ ⌘ ＋ space`

## 3.6 关闭显示器

`⌃ ＋ ⇧ ＋ 电源键`

## 3.7 锁定屏幕

`⌃ ＋ ⌘ ＋ Q`

## 3.8 Page Up/Down

Home键：`Fn+←`
End键：`Fn+→`
Page UP：`Fn+↑`
Page DOWN：`Fn+↓`
向前Delete：`Fn+delete`

## 3.9 显示当前应用的多个窗口

`^ + ↓`

## 3.10 显示正在执行的任务

`^ + ↑`

# 4 刻录iso文件

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

# 5 打开/禁止产生.DS_Store文件

```sh
# 禁止
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# 打开
defaults delete com.apple.desktopservices DSDontWriteNetworkStores
```

# 6 参考

* [Mac 下利用 Launchctl 自启动 mysql](http://squll369.iteye.com/blog/1965185)
* [Mac 有哪些鲜为人知的使用技巧？](https://www.zhihu.com/question/26379660)
* [Mac下刻录ISO到U盘](https://www.jianshu.com/p/62e52ca56440)
