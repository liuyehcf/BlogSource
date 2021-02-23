---
title: Mac-个性化配置
date: 2018-01-12 20:53:24
tags: 
- 摘录
categories: 
- Operating System
- OS X
---

**阅读更多**

<!--more-->

# 1 vim

**vim样式有如下几种**

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

**述样式可以通过如下命令查看**

* `ls /usr/share/vim/vim80/colors`
* 上面路径中的`vim80`可能是`vim+其他数字`，视情况而定

**设置步骤**

1. `vim ~/.vimrc`
1. 添加如下内容

```sh
set nu 
colorscheme desert 
syntax on
```

# 2 ls颜色字体

**步骤**

1. `vim ~/.bash_profile`，追加以下内容
    * 
```sh
export LS_OPTIONS='--color=auto' # 如果没有指定，则自动选择颜色
export CLICOLOR='Yes' #是否输出颜色
export LSCOLORS='CxfxcxdxbxegedabagGxGx' #指定颜色
```

1. `source ~/.bash_profile`

**LSCOLORS含义解释**：这22个字母2个字母一组分别指定一种类型的文件或者文件夹显示的字体颜色和背景颜色

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

**智能选中**

1. 双击选中
1. 三击选中整行
1. 四击智能选中
1. 选中即复制

**按住Command**

1. 拖拽选中字符串
1. 点击url，访问网页
1. 点击文件，用默认程序打开此文件
1. 点击文件夹，在Finder中打开
1. 同时按住option键，可以以矩形选中，类似于vim中的ctrl v操作

**常用快捷键**

1. 切换窗口：`⌘+←`、`⌘+→`、`⌘+数字`
1. 新建窗口：`⌘+t`
1. 垂直切分当前窗口：`⌘+d`
1. 水平切分当前窗口：`⌘+⇧+d`
1. 智能查找：`⌘+f`
1. 历史记录窗口：`⌘+⇧+h`
1. 全屏所有tab：`⌘+⌥+e`
1. 锁定鼠标位置：`⌘+/`

**设置`⌥+←`、`⌥+→`以单词为单位移动光标**

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

**设置滚动行数**

* `Preferences`->`Profiles`->`Terminal`

**设置语言**

* `export LANG=en_US.UTF-8`
* `export zh_CN.UTF-8`

# 4 zsh

# 5 更换home-brew镜像源

```sh
# step 1: 替换brew.git
$ cd "$(brew --repo)"
# 中国科大:
$ git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
# 清华大学:
$ git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git

# step 2: 替换homebrew-core.git
$ cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
# 中国科大:
$ git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
# 清华大学:
$ git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

# step 3: 替换homebrew-bottles
# 中国科大:
$ echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
$ source ~/.bash_profile
# 清华大学:
$ echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
$ source ~/.bash_profile

# step 4: 应用生效
$ brew update
```

# 6 升级bash

```sh
brew install bash
sudo mv /bin/bash  /bin/bash.origin
sudo ln -s /usr/local/bin/bash /bin/bash
```

**注意，`sudo mv /bin/bash  /bin/bash.origin`可能因为权限的问题，无法成功执行，这时，我们需要关闭Mac的SIP机制，具体步骤如下**

1. 重启，然后按住`Command+R`
1. 出现界面之后，上面菜单栏->实用工具->终端
1. 在Terminal中输入`csrutil disable`关闭SIP(csrutil enable打开SIP)
1. 重启

# 7 清理磁盘

最近我的磁盘容量快被系统吃满了，排查了一下，发现这几个路径

1. `/Library/Application Support`
    * `/Library/Application Support/Symantec/AntiVirus`：`Symantec`这个软件一直在做备份
1. `/Library/Caches`
1. `~/Library/Caches`
    * `~/Library/Caches/IntelliJIdea2018.1`：`IntelliJIdea`的一些缓存数据

# 8 卸载itunes

为什么要卸载，升级完mac之后，发现某些应用的`f8`快捷键失效了，一按`f8`就会自动打开itunes

我们是无法通过正常方式卸载itunes的，`sudo rm -rf /System/Applications/Music.app`会提示`Operation not permitted`，即便切到`root`账号也无法执行，这是因为mac对此类行为做了安全防护

我们可以通过`csrutil disable`解除这个限制。但是该命令需要到恢复模式才能用

如何进入恢复模式：重启电脑，按`COMMAND+R`组合键进入恢复模式

进入恢复模式后，在屏幕上方点击`实用工具`->`终端`，然后再执行`csrutil disable`即可

当关闭mac的`System Integrity Protection`功能之后，再次尝试删除`itunues`，发现还是删除不了，这次提示的是`Read-only file system`，无语

后来在[Stop F8 key from launching iTunes?](https://discussions.apple.com/thread/3715785)找到了解决方案

* `System Preferences` -> `Keyboard` -> `Keyboard`
* 取消`Use all F1,F2,etc. keys as standard function keys`选项的勾选

# 9 参考

* [mac下vim的16种配色方案（代码高亮）展示，及配置](http://blog.csdn.net/myhelperisme/article/details/49700715)
* [mac终端(Terminal)字体颜色更改教程 [ls、vim操作颜色] [复制链接]](https://bbs.feng.com/forum.php?mod=viewthread&tid=10508780)
* [iterm2有什么酷功能？](https://www.zhihu.com/question/27447370)
* [如何在OS X iTerm2中愉快地使用“⌥ ←”及“⌥→ ”快捷键跳过单词？](http://blog.csdn.net/yaokai_assultmaster/article/details/73409826)
* [iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)
* [更换Homebrew的更新源](https://blog.csdn.net/u010275932/article/details/76080833)
