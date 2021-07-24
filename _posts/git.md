---
title: git
date: 2017-08-11 14:02:55
tags: 
- 摘录
categories: 
- Version Control
---

**阅读更多**

<!--more-->

# 1 基本概念

![fig1](/images/git/fig1.png)

## 1.1 工作区(Workspace)

代表你正在工作的那个文件集，也就是git管理的所有文件的集合

**下文用`Workspace`来表示工作区**

## 1.2 版本库(Repository)

工作区有一个隐藏目录**`.git`**，这个不算工作区，而是Git的版本库

Git的版本库里存了很多东西，其中最重要的就是称为`stage`（或者叫`index`）的**暂存区**，还有Git为我们自动创建的第一个分支`master`，以及指向`master`的一个指针叫`HEAD`

**下文用`Index`来表示暂存区，用`HEAD`表示当前分支的最新提交，用`Repository`表示提交区**

# 2 配置

```shell
# 显示当前的Git配置
$ git config --list

# 编辑Git配置文件
$ git config -e [--global]

# 设置提交代码时的用户信息
$ git config [--global] user.name "[name]"
$ git config [--global] user.email "[email address]"
```

# 3 增加/删除文件

```shell
# 添加指定文件到暂存区
$ git add [file1] [file2] ...

# 添加指定目录到暂存区，包括子目录
$ git add [dir]

# 添加当前目录的所有文件到暂存区
$ git add .

# 添加已被track的文件到暂存区，即不会提交新文件
$ git add -u

# 添加每个变化前，都会要求确认
# 对于同一个文件的多处变化，可以实现分次提交
$ git add -p

# 删除工作区文件，并且将这次删除放入暂存区
$ git rm [file1] [file2] ...

# 停止追踪指定文件，但该文件会保留在工作区
$ git rm --cached [file]

# 停止追踪所有文件，但该文件会保留在工作区
$ git rm -r --cached .

# 查看git追踪的文件
$ git ls-files

# 改名文件，并且将这个改名放入暂存区
$ git mv [file-original] [file-renamed]
```

# 4 代码提交

```shell
# 提交暂存区到仓库区
$ git commit -m [message]

# 提交暂存区的指定文件到仓库区
$ git commit [file1] [file2] ... -m [message]

# 提交工作区自上次commit之后的变化，直接到仓库区
$ git commit -a

# 提交时显示所有diff信息
$ git commit -v

# 使用一次新的commit，替代上一次提交
# 如果代码没有任何新变化，则用来改写上一次commit的提交信息
$ git commit --amend -m [message]

# 重做上一次commit，并包括指定文件的新变化
$ git commit --amend [file1] [file2] ...
```

# 5 分支

```shell
# 列出所有本地分支
$ git branch

# 列出所有远程分支
$ git branch -r

# 列出所有本地分支和远程分支
$ git branch -a

# 新建一个分支，但依然停留在当前分支
$ git branch [branch-name]

# 新建一个分支，并切换到该分支
$ git checkout -b [branch]

# 从远程仓库拉取指定分支，并在本地新建一个分支，并切换到该分支
$ git checkout -b [branch_local] origin/[branch_remote]

# 新建一个分支，指向指定commit
$ git branch [branch] [commit]

# 新建一个分支，与指定的远程分支建立追踪关系
$ git branch --track [branch] [remote-branch]

# 切换到指定分支，并更新工作区
$ git checkout [branch-name]

# 切换到上一个分支
$ git checkout -

# 建立追踪关系，在现有分支与指定的远程分支之间
$ git branch --set-upstream [branch] [remote-branch]

# 合并指定分支到当前分支
$ git merge [branch]

# rebase指定分支到当前分支
$ git rebase [branch]

# rebase当前分支的HEAD到指定的提交
$ git rebase -i [commit]

# 选择一个commit，合并进当前分支（从左到右时间线递增，也就是commit1.time 早于 commit2.time）
$ git cherry-pick [commit1] [commit2] ...

# 删除分支
$ git branch -d [branch-name]

# 删除远程分支
$ git push origin --delete [branch-name]
$ git branch -dr [remote/branch]

# 更改分支名字
$ git branch -m [oldbranch] [newbranch]
$ git branch -M [oldbranch] [newbranch]
```

# 6 标签

```shell
# 列出所有tag
$ git tag

# 新建一个tag在当前commit
$ git tag [tag]

# 新建一个tag在指定commit
$ git tag [tag] [commit]

# 删除本地tag
$ git tag -d [tag]

# 删除远程tag
$ git push origin :refs/tags/[tagName]

# 查看tag信息
$ git show [tag]

# 提交指定tag
$ git push [remote] [tag]

# 提交所有tag
$ git push [remote] --tags

# 新建一个分支，指向某个tag
$ git checkout -b [branch] [tag]
```

# 7 查看信息

```shell
# 显示有变更的文件
$ git status

# 显示当前分支的版本历史
$ git log

# 显示commit历史，以及每次commit发生变更的文件
$ git log --stat

# 搜索提交历史，根据关键词
$ git log -S [keyword]

# 显示某个commit之后的所有变动，每个commit占据一行
$ git log [tag] HEAD --pretty=format:%s

# 显示某个commit之后的所有变动，其"提交说明"必须符合搜索条件
$ git log [tag] HEAD --grep feature

# 显示某个文件的版本历史，包括文件改名
$ git log --follow [file]
$ git whatchanged [file]

# 显示指定文件相关的每一次diff
$ git log -p [file]

# 显示过去5次提交
$ git log -5 --pretty --oneline

# 显示所有提交过的用户，按提交次数排序
$ git shortlog -sn

# 显示指定文件是什么人在什么时间修改过
$ git blame [file]

# 显示暂存区和工作区的差异的概要（文件修改了几行，不会列出具体改动）
$ git diff --stat

# 显示暂存区和工作区的差异
$ git diff

# 显示暂存区和上一个commit的差异
$ git diff --cached [file]

# 显示工作区与当前分支最新commit之间的差异
$ git diff HEAD

# 显示两次提交之间的差异
$ git diff [first-branch]...[second-branch]

# 显示今天你写了多少行代码
$ git diff --shortstat "@{0 day ago}"

# 显示某次提交的元数据和内容变化
$ git show [commit]

# 显示某次提交发生变化的文件
$ git show --name-only [commit]

# 显示某次提交时，某个文件的内容
$ git show [commit]:[filename]

# 显示当前分支的最近几次提交
$ git reflog
```

# 8 远程同步

```shell
# 下载远程仓库的所有变动
$ git fetch [remote]

# 显示所有远程仓库
$ git remote -v

# 显示某个远程仓库的信息
$ git remote show [remote]

# 增加一个新的远程仓库，并命名
$ git remote add [shortname] [url]

# 取回远程仓库的变化，并与本地分支合并
$ git pull [remote] [branch]

# 上传本地指定分支到远程仓库
$ git push [remote] [branch]

# 强行推送当前分支到远程仓库，即使有冲突
$ git push [remote] --force

# 推送所有分支到远程仓库
$ git push [remote] --all
```

# 9 撤销

```shell
# 恢复暂存区的指定文件到工作区，注意'--'表示的是：后面接的是path而非分支名
$ git checkout [file]
$ git checkout -- [file]

# 恢复某个commit的指定文件到暂存区和工作区
$ git checkout [commit] [file]

# 恢复暂存区的所有文件到工作区
$ git checkout .
$ git checkout -- .

# 重置暂存区的指定文件，与上一次commit保持一致，但工作区不变
$ git reset [file]

# 重置暂存区与工作区，与上一次commit保持一致
$ git reset --hard

# 重置当前分支的指针为指定commit，同时重置暂存区，但工作区不变
$ git reset [commit]

# 重置当前分支的HEAD为指定commit，同时重置暂存区和工作区，与指定commit一致
$ git reset --hard [commit]

# 重置当前HEAD为指定commit，但保持暂存区和工作区不变
$ git reset --keep [commit]

# 新建一个commit，用来撤销指定commit
# 后者的所有变化都将被前者抵消，并且应用到当前分支
$ git revert [commit]

# 暂时将未提交的变化移除，稍后再移入
$ git stash
$ git stash pop
```

# 10 克隆

```sh
# https方式下载
git clone https://github.com/xxx/yyy.git

# ssh方式下载
git clone git@github.com:xxx/yyy.git

# 不下载历史提交，当整个仓库体积非常大的时候，下载全部会比较耗费存储以及时间
git clone https://github.com/xxx/yyy.git --depth 1
git clone -b <branch_name> https://github.com/xxx/yyy.git --depth 1

# 使用<--depth 1>会衍生另一个问题，无法获取其他分支，可以通过如下方式处理
git remote set-branches origin '<需要获取的分支名>'
git fetch --depth 1 origin '<需要获取的分支名>'
```

# 11 插件

[git-extra](https://github.com/tj/git-extras)

```sh
# 统计代码贡献
git summary --line
```

# 12 其他

```shell
# 生成一个可供发布的压缩包
$ git archive

$ git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

# 13 中文显示为8进制形式的问题

在Windows中，git bash打印的中文可能表示成`\+三个数字`的形式，即八进制表示

通过如下命令可以解决该问题

```shell
$ git config --global core.quotepath false
```

# 14 .gitignore

**基础规则**

1. 空白行，不匹配任何文件，仅增加可读性
1. 规则以`#`开头，表示`注释`
1. 规则`行尾的空格`，会被忽略，除非用`\`进行转义
1. 规则以`!`开头，表示反转该规则（`.gitignore`文件默认的语义是忽略，反转后表示包含）
1.  规则以`/`结尾，表示匹配`目录`以及该目录下的一切
1.  规则以不包含`/`，表示匹配`文件`或`目录`
1. `*`匹配多个字符，不包括`/`
1. `?`匹配单个字符，不包括`/`
1. `[]`匹配指定的多个字符
1.  规则以`/`开头，表示以`根目录`开始，即匹配`绝对路径`。例如`/*.c`匹配`cat-file.c`，但不匹配`mozilla-sha1/sha1.c`
1. `**/`开头，表示匹配所有`目录`。例如`**/foo`匹配`foo`目录或文件。**`**/foo`与`foo`的作用是一样的**
1. `/**`开头，表示匹配内部的一切。例如`abc/**`匹配`abc`目录下的所有文件。**`abc/**`与`abc/`的作用是一样的**
1. `/**/`表示匹配`0`个或`多`个`目录`。例如`a/**/b`匹配`a/b`、`a/x/b`、`a/x/y/b`

# 15 参考

* [git官方文档](https://git-scm.com/docs/gitignore)
* [git教程](https://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000/)
* [git reset soft,hard,mixed之区别深解](http://www.cnblogs.com/kidsitcn/p/4513297.html)
* [GIT基本概念和用法总结](http://guibin.iteye.com/blog/1014369)
* [常用 Git 命令清单](http://www.ruanyifeng.com/blog/2015/12/git-cheat-sheet.html)
* [git rebase简介(基本篇)](http://blog.csdn.net/hudashi/article/details/7664631/)
* [git bash中 中文显示为数字](http://blog.csdn.net/zhujiangtaotaise/article/details/74424157)
* [git 合并历史提交](https://www.cnblogs.com/woshimrf/p/git-rebase.html)
