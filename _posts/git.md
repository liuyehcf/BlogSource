---
title: git
date: 2017-08-11 14:02:55
tags: 
- 摘录
categories: 
- Command
---

__目录__

<!-- toc -->
<!--more-->

# 1 基本概念

## 1.1 工作区(Working Directory)

代表你正在工作的那个文件集，也就是git管理的所有文件的集合。

__下文用`WorkingDirectory`来表示工作区__

## 1.2 版本库(Repository)

工作区有一个隐藏目录__`.git`__，这个不算工作区，而是Git的版本库。

Git的版本库里存了很多东西，其中最重要的就是称为`stage`（或者叫`index`）的__暂存区__，还有Git为我们自动创建的第一个分支`master`，以及指向`master`的一个指针叫`HEAD`。

__下文用`Index`来表示暂存区，用`HEAD`表示当前分支的最新提交，用`GitDirectory`表示提交区__

# 2 基本操作

## 2.1 add

1. `git add [path]`：track指定文件，并将`Index[path] = WorkingDirectory[path]`
1. `git add .`：track所有文件，并将`Index[ALL] = WorkingDirectory[ALL]`，在这种情况下.gitignore的配置就尤为重要

## 2.2 commit

## 2.3 diff

1. __`git diff [path]`__：这个命令最常用，在每次add进入`Index`前会运行这个命令，查看即将add进入`Index`时所做的内容修改，__即`WorkingDirectory`和`Index`的差异__
1. __`git diff --cached [path]`__：这个命令初学者不太常用，却非常有用，它表示查看已经add进入`Index`但是尚未commit的内容同最后一次commit时的内容的差异。__即`Index`和`GitDirectory`中最新版本的差异__
1. __`git diff [commit-id] [path]`__：这个命令用来查看__`WorkingDirectory`和`GitDirectory`中指定版本的差异__。如果要和`GitDirectory`中最新版比较差别，则令`commit-id = HEAD`。如果要和某一个branch比较差别，则令`commit-id = 分支名字`
1. __`git diff --cached [commit-id] [path]`__：这个命令初学者用的更少，也非常有用，它表示查看已经add进入`Index`但是尚未commit的内容同指定`commit-id`的`GitDirectory`之间的差异。__即`Index`和`GitDirectory`中指定版本的差异。__
1. __`git diff [commit-id1] [commit-id2] [path]`__：__这个命令用来比较`GitDirectory`中任意两个`commit-id`之间的差别__，如果想比较任意一个`commit`和最新版的差别，把其中一个`commit-id`换成`HEAD`即可。

## 2.4 reset

# 3 Alias

`git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"`

# 4 参考

* [git教程](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)
* [git reset soft,hard,mixed之区别深解](http://www.cnblogs.com/kidsitcn/p/4513297.html)
* [GIT基本概念和用法总结](http://guibin.iteye.com/blog/1014369)

