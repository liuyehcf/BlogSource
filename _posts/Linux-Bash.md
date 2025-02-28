---
title: Linux-Bash
date: 2017-12-12 19:17:25
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 前言

以下介绍的大多数Bash快捷键仅当在`emacs`编辑模式时有效，若你将Bash配置为`vi`编辑模式，那将遵循vi的按键绑定。Bash默认为`emacs`编辑模式。如果你的Bash不在`emacs`编辑模式，可通过`set -o emacs`设置

`^S、^Q、^C、^Z`是由终端设备处理的，可用`stty`命令设置

**Bash有两种输入模式`vi`模式和`emacs`模式，其中`emacs`是默认模式，而且操作起来也比`vi`模式要快捷。可以通过`set -o vi`和`set -o emacs`来转换。下面介绍的各种快捷键，其实就是`emacs`的快捷键**

# 2 编辑命令

* `Ctrl + a`：移到命令行首
* `Ctrl + e`：移到命令行尾
* `Ctrl + f`：按字符前移（右向）
* `Ctrl + b`：按字符后移（左向）
* `Alt + f`：按单词前移（右向）
* `Alt + b`：按单词后移（左向）
* `Ctrl + xx`：在命令行首和光标之间移动
* `Ctrl + u`：从光标处删除至命令行首
* `Ctrl + k`：从光标处删除至命令行尾
* `Ctrl + w`：从光标处删除至字首
* `Alt + d`：从光标处删除至字尾
* `Ctrl + d`：删除光标处的字符
* `Ctrl + h`：删除光标前的字符
* `Ctrl + y`：粘贴至光标后
* `Alt + c`：从光标处更改为首字母大写的单词
* `Alt + u`：从光标处更改为全部大写的单词
* `Alt + l`：从光标处更改为全部小写的单词
* `Ctrl + t`：交换光标处和之前的字符
* `Alt + t`：交换光标处和之前的单词
* `Alt + Backspace`：与`Ctrl + w`相同类似，分隔符有些差别

# 3 重新执行命令

* `Ctrl + r`：逆向搜索命令历史
* `Ctrl + s`：正向搜索命令历史（与`Ctrl + r`方向相反）
    * 默认情况下，`Ctrl + s`在许多终端中用于暂停屏幕输出，所以你可能需要先禁用这个流控功能（`stty -ixon`）
* `Ctrl + g`：从历史搜索模式退出
* `Ctrl + p`：历史中的上一条命令
* `Ctrl + n`：历史中的下一条命令
* `Alt + .`：使用上一条命令的最后一个参数

# 4 控制命令

* `Ctrl + l`：清屏
* `Ctrl + o`：执行当前命令，并选择上一条命令
* `Ctrl + s`：阻止屏幕输出
* `Ctrl + q`：允许屏幕输出
* `Ctrl + c`：终止命令
* `Ctrl + z`：挂起命令

# 5 Bang (!) 命令

* `!!`：执行上一条命令
* `!blah`：执行最近的以`blah`开头的命令，如`!ls`
* `!blah:p`：仅打印输出，而不执行
* `!$`：上一条命令的最后一个参数，与`Alt + .`相同
* `!$:p`：打印输出`!$`的内容
* `!*`：上一条命令的所有参数
* `!*:p`：打印输出`!*`的内容
* `^blah`：删除上一条命令中的`blah`
* `^blah^foo`：将上一条命令中的`blah`替换为`foo`
* `^blah^foo^`：将上一条命令中所有的`blah`都替换为`foo`

# 6 补全

**默认情况下，bash只有路径补全、命令补全，而没有命令行参数的补全**

**如何安装命令行参数补全？**

```sh
yum install -y bash-completion
```

**相关的配置文件：`/etc/profile.d/bash_completion.sh`**

# 7 Bash相关文件

1. `/etc/profile`：系统整体设置（所有用户）
1. `~/.bash_profile`：bash个性化设置，login shell（当前用户）
1. `~/.bashrc`：bash个性化设置，non-login shell（当前用户）
1. `~/.bash_history`：历史命令记录（当前用户）
1. `~/.bash_logout`：记录了当注销bash后系统再帮我完成什么操作后才离开（当前用户）
1. `/etc/motd`：登录成功后显示的欢迎界面
1. `/etc/issue`：本地串口登录前的显示栏

# 8 参考

* [Bash 实用技巧大全](https://www.cnblogs.com/napoleon_liu/articles/1952228.html)
* [较完整的Bash快捷键，让命令更有效率](http://www.linuxde.net/2011/11/1877.html)
* [linux 欢迎界面](https://www.cnblogs.com/linquan/p/4998175.html)
