---
title: Mac-常用命令与快捷键
date: 2017-10-11 23:21:45
tags: 
- 摘录
categories: 
- 操作系统
- OS X
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

# 3 快捷键

## 3.1 清屏

`command + k`

## 3.2 显示隐藏文件夹

`⌘ + ⇧ + .`

__也有如下非快捷键的方法__

```
// 显示
defaults write com.apple.finder AppleShowAllFiles -boolean true 
killall Finder// 重启Finder

// 隐藏
defaults write com.apple.finder AppleShowAllFiles -boolean false
killall Finder// 重启Finder
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

# 4 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [Mac 下利用 Launchctl 自启动 mysql](http://squll369.iteye.com/blog/1965185)
* [Mac 有哪些鲜为人知的使用技巧？](https://www.zhihu.com/question/26379660)
