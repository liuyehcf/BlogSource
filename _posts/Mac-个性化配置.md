---
title: Mac-个性化配置
date: 2018-01-12 20:53:24
tags: 
- 摘录
categories: 
- 操作系统
- OS X
---

__阅读更多__

<!--more-->

# 1 vim

__vim样式有如下几种__

1. darkblue 
1. delek 
1. elflord 
1. koehler 
1. murphy 
1. peachpuff 
1. shine 
1. torte 
1. default 
1. desert 
1. evening 
1. morning 
1. pablo 
1. ron 
1. slate 
1. zellner

__述样式可以通过如下命令查看__

* `ls /usr/share/vim/vim80/colors`
* 上面路径中的`vim80`可能是`vim+其他数字`，视情况而定

__设置步骤__

1. `vim ~/.vimrc`
1. 添加如下内容

```sh
set nu 
colorscheme desert 
syntax on
```

# 2 ls颜色字体

__步骤__

1. `vim ~/.bash_profile`，追加以下内容
    * 
```sh
export LS_OPTIONS='--color=auto' # 如果没有指定，则自动选择颜色
export CLICOLOR='Yes' #是否输出颜色
export LSCOLORS='CxfxcxdxbxegedabagGxGx' #指定颜色
```

1. `source ~/.bash_profile`

__LSCOLORS含义解释__：这22个字母2个字母一组分别指定一种类型的文件或者文件夹显示的字体颜色和背景颜色

1. 从第1组到第11组分别指定的文件或文件类型为
    * directory
    * symbolic link
    * socket
    * pipe
    * executable
    * block special
    * character special
    * executable with setuid bit set
    * executable with setgid bit set
    * directory writable to others, with sticky bit
    * directory writable to others, without sticky bit
1. 颜色字母对照
    * a 黑色
    * b 红色
    * c 绿色
    * d 棕色
    * e 蓝色
    * f 洋红色
    * g 青色
    * h 浅灰色
    * A 黑色粗体
    * B 红色粗体
    * C 绿色粗体
    * D 棕色粗体
    * E 蓝色粗体
    * F 洋红色粗体
    * G 青色粗体
    * H 浅灰色粗体
    * x 系统默认颜色

# 3 Iterm2

__智能选中__

1. 双击选中
1. 三击选中整行
1. 四击智能选中
1. 选中即复制

__按住Command__

1. 拖拽选中字符串
1. 点击url，访问网页
1. 点击文件，用默认程序打开此文件
1. 点击文件夹，在Finder中打开
1. 同时按住option键，可以以矩形选中，类似于vim中的ctrl v操作

__常用快捷键__

1. 切换tab：`⌘+←`、`⌘+→`、`⌘+数字`
1. 新建tab：`⌘+t`
1. 智能查找：`⌘+f`
1. 历史记录窗口：`⌘+⇧+h`
1. 全屏所有tab：`⌘+⌥+e`
1. 锁定鼠标位置：`⌘+/`

__设置`⌥+←`、`⌥+→`以单词为单位移动光标__

1. 首先打开iTerm2的preferences-->profile-->Keys，将常用的左Alt键设置为换码符（escape character）。如下图所示
    * ![fig1](/images/Mac-个性化配置/fig1)
1. 接下来在Key mappings中找到已经存在的`⌥←`及`⌥→`，如果没有的话，就新建这两个快捷键
1. 将`⌥←`的设置修改为如下内容
    * Keyboard Shortcut: `⌥←`
    * Action: `Send Escape Sequence`
    * Esc+: `b`
1. 将`⌥→`的设置修改为如下内容
    * Keyboard Shortcut: `⌥→`
    * Action: `Send Escape Sequence`
    * Esc+: `f`

# 4 zsh

# 5 参考

* [mac下vim的16种配色方案（代码高亮）展示，及配置](http://blog.csdn.net/myhelperisme/article/details/49700715)
* [mac终端(Terminal)字体颜色更改教程 [ls、vim操作颜色] [复制链接]](https://bbs.feng.com/forum.php?mod=viewthread&tid=10508780)
* [iterm2有什么酷功能？](https://www.zhihu.com/question/27447370)
* [如何在OS X iTerm2中愉快地使用“⌥ ←”及“⌥→ ”快捷键跳过单词？](http://blog.csdn.net/yaokai_assultmaster/article/details/73409826)
* [iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)
