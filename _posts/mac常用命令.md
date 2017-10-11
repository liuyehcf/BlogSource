---
title: mac常用命令
date: 2017-10-11 23:21:45
tags: 
- 摘录
categories: 
- 操作系统
- Linux
---

__目录__

<!-- toc -->
<!--more-->

# 1 软件安装

## 1.1 brew

__格式：__

* `brew install <software>`
* `brew uninstall <software>`
* `brew update <software>`
* `brew search <software>`
* `brew list <software>`

# 2 启动服务

## 2.1 launchctl

__以ssh为例：__

* `sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist`
* `sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist`
* `sudo launchctl list | grep ssh`

## 2.2 其他方式

__mysql：__

* `mysql.server start`
* `mysql.server stop`

#其他

## 2.3 清屏

`command + k`

## 2.4 显示隐藏文件夹

显示所有隐藏文件以及文件夹
```
defaults write com.apple.finder AppleShowAllFiles -boolean true 
killall Finder// 重启Finder
```

关闭显示所有隐藏文件以及文件夹
```
defaults write com.apple.finder AppleShowAllFiles -boolean false
killall Finder// 重启Finder
```

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [Mac 下利用 Launchctl 自启动 mysql](http://squll369.iteye.com/blog/1965185)
