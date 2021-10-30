---
title: Mac-相关
date: 2018-01-12 20:53:24
tags: 
- 摘录
categories: 
- Operating System
- OS X
---

**阅读更多**

<!--more-->

# 1 快捷键

## 1.1 清屏

`command + k`

## 1.2 关闭显示器

* **`⌃ ＋ ⇧ ＋ 电源键`（貌似只能锁屏，并未关闭显示器）**
* **系统偏好设置->调度中心->触发角（亲测可用）**

## 1.3 锁定屏幕

`⌃ ＋ ⌘ ＋ Q`

## 1.4 显示当前应用的多个窗口

`^ + ↓`

## 1.5 显示正在执行的任务

`^ + ↑`

## 1.6 显示隐藏文件夹

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

## 1.7 微粒度音量调节

`⌥ + ⇧ + 音量调节按键`

## 1.8 应用图标抖动

在launchpad界面中，`⌃ + ⌥ + ⌘ + B`

## 1.9 emoji

`⌃ ＋ ⌘ ＋ space`

## 1.10 Page Up/Down

Home键：`Fn+←`
End键：`Fn+→`
Page UP：`Fn+↑`
Page DOWN：`Fn+↓`
向前Delete：`Fn+delete`

# 2 常用功能

## 2.1 国内安装homebrew

参考[国内安装homebrew](https://zhuanlan.zhihu.com/p/111014448)

**常规安装脚本（推荐/完全体/几分钟安装完成）：**

```sh
/bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```

**极速安装脚本（精简版/几秒钟安装完成）：**

```sh
/bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)" speed
```

**卸载脚本：**

```sh
/bin/bash -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh)"
```

**[FAQ](https://gitee.com/cunkai/HomebrewCN/blob/master/error.md)**

## 2.2 更换homebrew镜像源

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

## 2.3 升级bash

```sh
brew install bash
sudo mv /bin/bash  /bin/bash.origin
sudo ln -s /usr/local/bin/bash /bin/bash
```

**注意，`sudo mv /bin/bash  /bin/bash.origin`可能因为权限的问题，无法成功执行，这时，我们需要关闭Mac的SIP机制**

## 2.4 开关SIP

1. 进入恢复模式：重启，然后按住`⌘ + R`
1. 出现界面之后，上面菜单栏->实用工具->终端
1. 在Terminal中输入`csrutil disable`关闭SIP(csrutil enable打开SIP)
1. 重启

## 2.5 刻录iso文件

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

## 2.6 打开/禁止产生.DS_Store文件

```sh
# 禁止
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# 打开
defaults delete com.apple.desktopservices DSDontWriteNetworkStores
```

## 2.7 清理磁盘

[macOS 系统占用储存空间太大怎么办？](https://www.zhihu.com/question/52784342)

最近我的磁盘容量快被系统吃满了，排查了一下，发现这几个路径

1. `/Library/Application Support`
    * `/Library/Application Support/Symantec/AntiVirus`：`Symantec`这个软件一直在做备份
1. `/Library/Caches`
1. `~/Library/Caches`
    * `~/Library/Caches/IntelliJIdea2018.1`：`IntelliJIdea`的一些缓存数据

## 2.8 卸载itunes

为什么要卸载，升级完mac之后，发现某些应用的`f8`快捷键失效了，一按`f8`就会自动打开itunes

我们是无法通过正常方式卸载itunes的，`sudo rm -rf /System/Applications/Music.app`会提示`Operation not permitted`，即便切到`root`账号也无法执行，这是因为mac对此类行为做了安全防护

我们可以通过`csrutil disable`解除这个限制。但是该命令需要到恢复模式才能用

如何进入恢复模式：重启电脑，按`COMMAND+R`组合键进入恢复模式

进入恢复模式后，在屏幕上方点击`实用工具`->`终端`，然后再执行`csrutil disable`即可

当关闭mac的`System Integrity Protection`功能之后，再次尝试删除`itunues`，发现还是删除不了，这次提示的是`Read-only file system`，无语

后来在[Stop F8 key from launching iTunes?](https://discussions.apple.com/thread/3715785)找到了解决方案

* `System Preferences` -> `Keyboard` -> `Keyboard`
* 取消`Use all F1,F2,etc. keys as standard function keys`选项的勾选

# 3 常见问题

## 3.1 VirtualBox(rc=-1908)

**解决方式如下：**

1. 进入恢复模式：重启，然后按住`⌘ + R`
1. 出现界面之后，上面菜单栏->实用工具->终端
1. 在terminal中输入`spctl kext-consent add VB5E2TV963`，其中`VB5E2TV963`是`Oracle`的`Developer ID`
1. 重启
1. 在系统偏好设置->安全与隐私->允许Virtual Box
1. 重启

# 4 Iterm2

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
    * ![fig1](/images/Mac-相关/fig1)
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

## 4.1 更换主题

**本小节转载摘录自[iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)**

**先上效果**

![iterm2-theme](/images/Mac-相关/iterm2-theme.png)

**步骤1：[安装iterm2](https://iterm2.com/)，不赘述**

**步骤2：[安装ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)，不赘述**

**步骤3：[安装Powerline](https://powerline.readthedocs.io/en/latest/installation.html)**

```sh
$ sudo brew install pip
$ sudo pip install powerline-status
```

**步骤4：[安装Powerline的字体库](https://github.com/powerline/fonts)**

```
$ git clone https://github.com/powerline/fonts.git --depth 1
$ cd fonts
$ ./install.sh
$ cd ..
$ rm -rf fonts
```

安装时，会提示所有字体均已下载到`/Users/<user name>/Library/Fonts`

**步骤5：将iterm2的字体设置为Powerline的字体**

![step5](/images/Mac-相关/step5.png)

在iterm2中使用Powerline字体：`Preferences` -> `Profiles` -> `Text`

**步骤6：[安装配色方案solarized](https://github.com/altercation/solarized)**

```sh
$ git clone https://github.com/altercation/solarized.git --depth 1
$ open solarized/iterm2-colors-solarized
```

上面的open命令会弹出finder，然后在弹出的finder中，双击`Solarized Dark.itermcolors`以及`Solarized Light.itermcolors`便可将配色方案安装到iterm2中

然后在iterm2中选择该配色方案即可：`Preferences` -> `Profiles` -> `Colors`

![step6](/images/Mac-相关/step6.png)

**步骤7：[安装agnoster主题](https://github.com/fcamblor/oh-my-zsh-agnoster-fcamblor)**

```sh
$ git clone  https://github.com/fcamblor/oh-my-zsh-agnoster-fcamblor.git --depth 1
$ cd oh-my-zsh-agnoster-fcamblor
$ ./install
$ cd ..
$ rm -rf oh-my-zsh-agnoster-fcamblor
```

这些主题会被安装到`~/.oh-my-zsh/themes`目录下，然后修改`~/.zshrc`文件，将`ZSH_THEME`配置项的值改成`agnoster`

**如果你选择了白色背景的话，agnoster也需要进行一些调整**

1. `~/.zshrc`增加配置项`SOLARIZED_THEME="light"`
1. `~/.oh-my-zsh/themes/agnoster.zsh-theme`修改背景
    * 找到关键词`build_prompt`，这就是命令提示符的全部构成，每一个配置项的颜色都可以单独调整
    * 以`prompt_context`为例，将`prompt_segment`后跟的`black`改为`white`
    ```
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment white default "%(!.%{%F{yellow}%}.)%n@%m"
  fi
}
    ```

**步骤8：[安装zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)用于高亮指令**

```sh
# 进入到 .zshrc 所在的目录，一般在用户目录下
$ cd ~
$ git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
```

然后修改`.zshrc`文件，在最后添加下面内容

```
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
plugins=(zsh-syntax-highlighting)
```

# 5 参考

* [Mac 下利用 Launchctl 自启动 mysql](http://squll369.iteye.com/blog/1965185)
* [Mac 有哪些鲜为人知的使用技巧？](https://www.zhihu.com/question/26379660)
* [Mac下刻录ISO到U盘](https://www.jianshu.com/p/62e52ca56440)
* [mac下vim的16种配色方案（代码高亮）展示，及配置](http://blog.csdn.net/myhelperisme/article/details/49700715)
* [mac终端(Terminal)字体颜色更改教程 [ls、vim操作颜色] [复制链接]](https://bbs.feng.com/forum.php?mod=viewthread&tid=10508780)
* [iterm2有什么酷功能？](https://www.zhihu.com/question/27447370)
* [如何在OS X iTerm2中愉快地使用“⌥ ←”及“⌥→ ”快捷键跳过单词？](http://blog.csdn.net/yaokai_assultmaster/article/details/73409826)
* [iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)
* [更换Homebrew的更新源](https://blog.csdn.net/u010275932/article/details/76080833)
