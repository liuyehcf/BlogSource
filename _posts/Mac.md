---
title: Mac
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

## 1.6 启动台

`F10`

## 1.7 露出桌面

`F11`

## 1.8 显示隐藏文件夹

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

## 1.9 微粒度音量调节

`⌥ + ⇧ + 音量调节按键`

## 1.10 应用图标抖动

在launchpad界面中，`⌃ + ⌥ + ⌘ + B`

## 1.11 emoji

`⌃ ＋ ⌘ ＋ space`

## 1.12 Page Up/Down

Home键：`Fn+←`
End键：`Fn+→`
Page UP：`Fn+↑`
Page DOWN：`Fn+↓`
向前Delete：`Fn+delete`
 
## 1.13 缩放窗口

[Maximize window shortcut](https://apple.stackexchange.com/questions/372719/maximize-window-shortcut)

窗口缩放功能的配置路径是：`System Preferences`->`Dock`->`Double-click a window's title bar to zoom`

默认情况下，该功能是没有对应的快捷键的，但是我们可以手动设置

1. `System Preferences`->`Keyboard`->`Shortcuts`->`App Shortcuts`
1. 新增快捷键
    * `Application`：所有类型
    * `Menu Title`：`Zoom`
    * `Keyboard Shortcut`：自定义，我设置的是`⌃ + ⌘ + M`

## 1.14 修改大小写切换方式

1. `System Preferences`->`Keyboard`->`Text Input Edit`->`Press and hold to enable typing in all uppercase`
    * 14.x 没有这个配置选项了

## 1.15 如何修改用户名

[Change the name of your macOS user account and home folder](https://support.apple.com/en-in/102547)

## 1.16 如何修改HostName/ComputerName

```sh
scutil --get HostName
scutil --get LocalHostName
scutil --get ComputerName

sudo scutil --set HostName xxx
sudo scutil --set LocalHostName xxx
sudo scutil --set ComputerName xxx
```

## 1.17 禁用密码校验规则

```sh
# back up all account policies
pwpolicy getaccountpolicies > back_policies.xml

# clean account policies
pwpolicy -clearaccountpolicies
```

# 2 Homebrew

## 2.1 常用操作

```sh
# 安装软件
brew install <software>

# 卸载软件
brew uninstall <software>

# 软件安装路径
brew list <software>

# 查看软件信息
brew info <software>
```

## 2.2 国内安装Homebrew

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

## 2.3 更换Homebrew镜像源

```sh
# step 1: 替换brew.git
cd "$(brew --repo)"
# 中国科大:
git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
# 清华大学:
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git

# step 2: 替换homebrew-core.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
# 中国科大:
git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
# 清华大学:
git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git

# step 3: 替换homebrew-bottles
# 中国科大:
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles' >> ~/.bash_profile
source ~/.bash_profile
# 清华大学:
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles' >> ~/.bash_profile
source ~/.bash_profile

# step 4: 应用生效
brew update
```

## 2.4 常用软件下载

```sh
brew install openjdk@11
brew install maven
brew install protobuf
```

### 2.4.1 解压缩

```sh
file xxx.zip

unzip xxx.zip
brew install unar
unar xxx.zip
```

# 3 常用功能

## 3.1 升级bash

```sh
brew install bash
sudo mv /bin/bash  /bin/bash.origin
sudo ln -s /usr/local/bin/bash /bin/bash
```

**注意，`sudo mv /bin/bash  /bin/bash.origin`可能因为权限的问题，无法成功执行，这时，我们需要关闭Mac的SIP机制**

## 3.2 开启关闭SIP

1. 进入恢复模式：
    * Intel：重启，然后按住`⌘ + R`，直到看到`logo`后松开
    * Arm：关机，按住开机键10s以上，直至进入恢复模式
1. 出现界面之后，上面菜单栏 -> 实用工具 -> 终端
1. 在Terminal中输入`csrutil disable`关闭`SIP`(`csrutil enable`打开`SIP`)
1. 重启

## 3.3 开启关闭任何来源

```sh
# 开启
sudo spctl --master-disable

# 关闭
sudo spctl --master-enable
```

## 3.4 刻录iso文件

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

## 3.5 打开/禁止产生.DS_Store文件

```sh
# 禁止
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE

# 打开
defaults delete com.apple.desktopservices DSDontWriteNetworkStores
```

## 3.6 开启HiDPI

[macOS开启HiDPI](https://zhuanlan.zhihu.com/p/227788155)

## 3.7 清理磁盘

[macOS 系统占用储存空间太大怎么办？](https://www.zhihu.com/question/52784342)

最近我的磁盘容量快被系统吃满了，排查了一下，发现这几个路径

1. `/Library/Application Support`
    * `/Library/Application Support/Symantec/AntiVirus`：`Symantec`这个软件一直在做备份
1. `/Library/Caches`
1. `~/Library/Caches`
    * `~/Library/Caches/IntelliJIdea2018.1`：`IntelliJIdea`的一些缓存数据

## 3.8 卸载itunes

为什么要卸载，升级完mac之后，发现某些应用的`f8`快捷键失效了，一按`f8`就会自动打开itunes

我们是无法通过正常方式卸载itunes的，`sudo rm -rf /System/Applications/Music.app`会提示`Operation not permitted`，即便切到`root`账号也无法执行，这是因为mac对此类行为做了安全防护

我们可以通过`csrutil disable`解除这个限制。但是该命令需要到恢复模式才能用

如何进入恢复模式：重启电脑，按`COMMAND+R`组合键进入恢复模式

进入恢复模式后，在屏幕上方点击`实用工具`->`终端`，然后再执行`csrutil disable`即可

当关闭mac的`System Integrity Protection`功能之后，再次尝试删除`itunues`，发现还是删除不了，这次提示的是`Read-only file system`，无语

后来在[Stop F8 key from launching iTunes?](https://discussions.apple.com/thread/3715785)找到了解决方案

* `System Preferences` -> `Keyboard` -> `Keyboard`
* 取消`Use all F1,F2,etc. keys as standard function keys`选项的勾选

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
    * ![fig1](/images/Mac/fig1)
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
* `export LANG=zh_CN.UTF-8`

## 4.1 更换主题

**本小节转载摘录自[iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)**

**先上效果**

![iterm2-theme](/images/Mac/iterm2-theme.png)

**步骤1：[安装iterm2](https://iterm2.com/)，不赘述**

**步骤2：[安装ohmyzsh](https://github.com/ohmyzsh/ohmyzsh)，不赘述。有时国内下载不下来，可以参考下面的步骤安装**

```sh
git clone https://github.com/ohmyzsh/ohmyzsh.git --depth 1
cd ohmyzsh/tools
./install.sh
```

**步骤3：[安装Powerline](https://powerline.readthedocs.io/en/latest/installation.html)**

```sh
sudo brew install pip
sudo pip install powerline-status
```

**步骤4：[安装Powerline的字体库](https://github.com/powerline/fonts)**

```
git clone https://github.com/powerline/fonts.git --depth 1
cd fonts
./install.sh
cd ..
rm -rf fonts
```

安装时，会提示所有字体均已下载到`/Users/<user name>/Library/Fonts`

**步骤5：将iterm2的字体设置为Powerline的字体**

![step5](/images/Mac/step5.png)

在iterm2中使用Powerline字体：`Preferences` -> `Profiles` -> `Text`

**步骤6：[安装配色方案solarized](https://github.com/altercation/solarized)**

```sh
git clone https://github.com/altercation/solarized.git --depth 1
open solarized/iterm2-colors-solarized
```

上面的open命令会弹出finder，然后在弹出的finder中，双击`Solarized Dark.itermcolors`以及`Solarized Light.itermcolors`便可将配色方案安装到iterm2中

然后在iterm2中选择该配色方案即可：`Preferences` -> `Profiles` -> `Colors`

![step6](/images/Mac/step6.png)

**步骤7：[安装agnoster主题](https://github.com/fcamblor/oh-my-zsh-agnoster-fcamblor)**

```sh
git clone  https://github.com/fcamblor/oh-my-zsh-agnoster-fcamblor.git --depth 1
cd oh-my-zsh-agnoster-fcamblor
./install
cd ..
rm -rf oh-my-zsh-agnoster-fcamblor
```

这些主题会被安装到`~/.oh-my-zsh/themes`目录下，然后修改`~/.zshrc`文件，将`ZSH_THEME`配置项的值改成`agnoster`

**如果你选择了白色背景的话，agnoster也需要进行一些调整**

1. `~/.zshrc`增加配置项`SOLARIZED_THEME="light"`
1. `~/.oh-my-zsh/themes/agnoster.zsh-theme`修改背景
    * 找到关键词`build_prompt`，这就是命令提示符的全部构成，每一个配置项的颜色都可以单独调整
    * 以`prompt_context`和`prompt_status`为例，将`prompt_segment`后面接的`black`改为`white`
    ```
    prompt_context() {
    if [[ "$USERNAME" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
        prompt_segment white default "%(!.%{%F{yellow}%}.)%n@%m"
    fi
    }

    prompt_status() {
    local -a symbols

    [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
    [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
    [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

    [[ -n "$symbols" ]] && prompt_segment white default "$symbols"
    }
    ```

**步骤8：[安装zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)用于高亮指令**

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git --depth 1 ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

然后修改`~/.zshrc`文件，修改配置项`plugins`，添加`zsh-syntax-highlighting`

```config
plugins=(<原有插件> zsh-syntax-highlighting)
```

**步骤9：[安装zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)用于指令提示**

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions.git --depth 1 ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
```

然后修改`~/.zshrc`文件，修改配置项`plugins`，添加`zsh-autosuggestions`

```config
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=red,bold'
plugins=(<原有插件> zsh-autosuggestions)
```

**如果在`iterm2`中通过`ssh`访问远程主机，也想获得上述效果，那么需要在远程主机上执行如下几个步骤：**

* **步骤2**
* **步骤7**
* **步骤8**
* **步骤9**

### 4.1.1 Tips

1. **登录时，命令行提示符显式的是`~`，但是执行`cd`后，显示的目录是用户目录的绝对路径，比如`/home/test`。这是因为`HOME`变量设置有问题，该变量最后不能有`/`符号，否则在将主目录替换成`~`的时候就会替换失败**

## 4.2 常用配置

1. 光标形状
    * `Preferences`->`Profile`->`Text`->`Cursor`

## 4.3 `Alt + f/b`在ssh场景下失效

**bash默认使用`emacs`模式，在该模式下，光标按单词移动的快捷键是`Alt + b`以及`Alt + f`，但是`mac`是没有这两个快捷键的，可以通过设置`profile`来解决这个问题，步骤如下：**

1. `Preferences` -> `Profiles` -> `Keys` -> `Key Mappings` -> `+`：新建快捷键
    1. `Alt + b`的替代快捷键
        * `Shortcut`：`⌥←`
        * `Action`：选择`Send Escape Sequence`，填`b`
    1. `Alt + f`的替代快捷键
        * `Shortcut`：`⌥→`
        * `Action`：选择`Send Escape Sequence`，填`f`

## 4.4 `Ctrl + c`失效

有时候（不明确复现路径是什么），在终端中，按下`Ctrl + c`，不会终止当前程序，而是在屏幕上输出`9;5u`，切伴随着响铃，在终端最上面会出现一个🔔的图标。可以按下面的步骤消除该问题：

1. `Preferences` -> `Profiles` -> `Terminal`
    1. `Notification Center Alters`：取消勾选
    1. `Show bell icon in tabs`：取消勾选

# 5 Karabiner-elements

外接如`Filco`的键盘，需要将`win`以及`alt`这两个键位进行交换。其中`win`对应`command`键，`alt`对应`option`键

* `Keys in pc keyboards - application` -> `Modifier keys - fn`
* `Modifier keys left_command` -> `Modifier keys left_option`
* `Modifier keys left_option` -> `Modifier keys left_command`

# 6 FAQ

## 6.1 VirtualBox(rc=-1908)

**解决方式如下（请挨个尝试）：**

**方法1：**

```sh
sudo "/Library/Application Support/VirtualBox/LaunchDaemons/VirtualBoxStartup.sh" restart
```

**方法2：**

```sh
sudo kextload -b org.virtualbox.kext.VBoxDrv
sudo kextload -b org.virtualbox.kext.VBoxNetFlt
sudo kextload -b org.virtualbox.kext.VBoxNetAdp
sudo kextload -b org.virtualbox.kext.VBoxUSB
```

**方法3：**

```
1. 进入恢复模式：重启，然后按住 ⌘ + R
2. 恢复模式中，上面菜单栏->实用工具->启动安全性实用工具，选择无安全性
3. 恢复模式中，上面菜单栏->实用工具->终端，在terminal中输入 csrutil disable
4. 恢复模式中，上面菜单栏->实用工具->终端，在terminal中输入 spctl kext-consent add VB5E2TV963，其中 VB5E2TV963 是 Oracle 的 Developer ID
5. 重启
6. 在系统偏好设置->安全与隐私->允许Virtual Box
7. 重启
```

## 6.2 VirtualBox cannot enable nested VT-x/AMD-V

`nested VT-x/AMD-V`这个特性不开的话，如果在虚拟机里面安装了`VirtualBox`，那么这个`VirtualBox`只能安装32位的系统

[Virtualbox enable nested vtx/amd-v greyed out](https://stackoverflow.com/questions/54251855/virtualbox-enable-nested-vtx-amd-v-greyed-out)

```sh
VBoxManage modifyvm <vm-name> --nested-hw-virt on
```

## 6.3 您没有权限来打开应用程序

```sh
sudo xattr -r -d com.apple.quarantine <app path>
```

## 6.4 中文输入法卡顿

**以下步骤可以解决`Chrome`中的卡顿问题（通用问题）**

1. 系统偏好设置->键盘
    * 键盘：按键重复调到最快，重复前延迟调到最短
    * 文本：所有的功能都关了，什么联想、提示之类的功能

**以下步骤可以解决`Chrome`中的卡顿问题，参考[How To Fix Input Lag And Slow Performance In Google Chrome](https://www.alphr.com/how-to-fix-input-lag-and-slow-performance-in-google-chrome/)**

* `Chrome` -> `Settings` -> `Advanced` -> `System` -> Disable `Use hardware acceleration when available`
    * 开启或关闭可能都会有问题，重新切换一下开关状态可以恢复

**以下步骤可以解决`VSCode`中的卡顿问题，参考[Lagging/freezing using VSCode Insiders in Big Sur](https://github.com/microsoft/vscode/issues/107103#issuecomment-731664821)**

```sh
codesign --remove-signature /Applications/Visual\ Studio\ Code.app/Contents/Frameworks/Code\ Helper\ \(Renderer\).app
```

**以下步骤可以解决中文输入法卡顿的问题，参考[程序开久了之后中文输入法卡顿，不知道怎么解决](https://discussionschinese.apple.com/thread/253846113)-Page2**

1. 系统偏好设置->调度中心
    * 显示器具有单独的空间（取消该选项，取消后会导致其他问题，比如Dock无法跟随鼠标在两个屏幕之间切换）

## 6.5 滚动条总是自动隐藏

`系统偏好设置` -> `通用` -> 选择始终显示滚动条

## 6.6 登录酒店 WIFI 无法弹出登录页面

如果使用了 Proxy SwitchyOmega 配置代理，那么默认新连接的 WIFI 也会带上相关的配置，需要通过如下方式手动删除掉：

`System Settings` -> `Network` -> `Details` -> `Proxies`

## 6.7 配置开机自启动

* `14.x`及以上版本：搜索`Login Items`

## 6.8 快速黑屏

```sh
pmset displaysleepnow
```

# 7 参考

* [Mac 下利用 Launchctl 自启动 mysql](http://squll369.iteye.com/blog/1965185)
* [Mac 有哪些鲜为人知的使用技巧？](https://www.zhihu.com/question/26379660)
* [Mac下刻录ISO到U盘](https://www.jianshu.com/p/62e52ca56440)
* [mac下vim的16种配色方案（代码高亮）展示，及配置](http://blog.csdn.net/myhelperisme/article/details/49700715)
* [mac终端(Terminal)字体颜色更改教程 [ls、vim操作颜色] [复制链接]](https://bbs.feng.com/forum.php?mod=viewthread&tid=10508780)
* [iterm2有什么酷功能？](https://www.zhihu.com/question/27447370)
* [如何在OS X iTerm2中愉快地使用“⌥ ←”及“⌥→ ”快捷键跳过单词？](http://blog.csdn.net/yaokai_assultmaster/article/details/73409826)
* [iTerm 2 && Oh My Zsh【DIY教程——亲身体验过程】](https://www.jianshu.com/p/7de00c73a2bb)
* [更换Homebrew的更新源](https://blog.csdn.net/u010275932/article/details/76080833)
* [VirtualBox 在 macOS 出現 Kernel driver not installed 問題解決方式](https://officeguide.cc/virtualbox-macos-kernel-driver-not-installed-error-solution-2020/)
* [macOS Catalina/Big Sur 无法打开app，提示“因为无法确认开发者身份”问题的解决方法](https://heipg.cn/tutorial/solution-for-macos-10-15-catalina-cant-run-apps.html)
* [macOS 10.15 不能打开软件提示无法打开“app”](https://juejin.im/post/5da68a73f265da5b616de149)
