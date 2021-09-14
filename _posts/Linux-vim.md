---
title: Linux-vim
date: 2018-01-16 22:58:45
top: true
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 vim的使用

## 1.1 模式

基本上`vim`分为三种模式：**一般模式、编辑模式与命令模式**

一般模式与编辑模式以及命令行模式可以相互切换，但是编辑模式与命令行模式之间不可相互切换

### 1.1.1 一般模式

以vi打开一个文件就进入一般模式了(这是默认模式)

在这个模式中，你可以使用上下左右按键来移动光标，可以删除字符或删除整行，也可以复制粘贴你的文件数据

### 1.1.2 编辑模式

在一般模式中，可以进行删除，复制，粘贴等操作，但是却无法编辑文件内容。要等到你按下i(I),o(O),a(A),r(R)等任何一个字母后才会进入编辑模式

通常在Linux中，按下这些键时，在界面的左下方会出现INSERT(ioa)或REPLACE(r)的字样，此时才可以进行编辑

如果要回到一般模式，必须按下Esc这个按键即可退出编辑器

### 1.1.3 命令行模式

在一般模式中，输入`:`、`/`、`?`这三个钟的任何一个按钮，就可以将光标移动到最下面一行，在这个模式中，可以提供你查找数据的操作，而读取、保存、大量替换字符、离开`vim`、显示行号等操作则是在此模式中完成的

## 1.2 简单执行范例

1. 直接输入`vim [文件名]`就能进入`vim`的一般模式
1. 整个界面分为两部分，上半部与下面一行两者可以视为独立的
1. 按下`i`进入编辑模式
    * 在一般模式中只要按下`i`、`o`、`a`等字符就可以进入编辑模式
    * **此时除了Esc这个按键之外，其他的按键都可以视作一般的输入了**
    * 在`vim`里，`[Tab]`键所得到的结果与空格符所得到的结果是不一样的
1. 按下`[Esc]`键回到一般模式
1. 在一般模式中输入`:wq`保存后离开`vim`

## 1.3 光标移动

* **`h或向左箭头`：光标向左移动一个字符`←`**
* **`j或向下箭头`：光标向下移动一个字符`↓`**
* **`k或向上箭头`：光标向上移动一个字符`↑`**
* **`l或向右箭头`：光标向右移动一个字符`→`**
* 可以配合数字使用，如向右移动30个字符`30l`或`30→`
* **`[Ctrl]+f`：屏幕向下移动一页，相当于[Page Down]按键**
* **`[Ctrl]+b`：屏幕向上移动一页，相当于[Page Up]按键**
* `[Ctrl]+d`：屏幕向下移动半页
* `[Ctrl]+u`：屏幕向上移动半页
* `+`：光标移动到非空格符的下一行
* `-`：光标移动到非空格符的上一行
* `[n][space]`：n表示数字，再按空格键，光标会向右移动n个字符
* **`0(数字零)或[home]`：移动到这一行的最前面字符处**
* **`$或功能键end`：移动到这一行最后面的字符处**
* `H`：光标移动到屏幕最上方那一行的第一个字符
* `M`：光标移动到这个屏幕的中央那一行的第一个字符
* `L`：光标移动到这个屏幕的最下方那一行的第一个字符
* **`w`：跳到下一个单词开头（标点或空格分隔的单词）**
* **`e`：跳到下一个单词尾部（标点或空格分隔的单词）**
* **`b`：跳到上一个单词开头（标点或空格分隔的单词）**
* `W`：跳到下一个单词开头（空格分隔的单词）
* `E`：跳到下一个单词尾部（空格分隔的单词）
* `B`：跳到上一个单词开头（空格分隔的单词）
* `)`：向前移动一个句子（句号分隔）
* `(`：向后移动一个句子（句号分隔）
* `}`：向前移动一个段落
* `{`：向后移动一个段落
* **`G`：移动到这个文件的最后一行**
* `[n]G`：n为数字，移动到这个文件的第n行
* **`gg`：移动到这个文件的第一行，相当于1G**
* **`[n][Enter]`：光标向下移动n行**

## 1.4 编辑模式

* **`i,I`：进入插入模式，i为从光标所在处插入，I为在目前所在行的第一个非空格处开始插入**
* **`a,A`：进入插入模式，a为从目前光标所在的下一个字符处开始插入，A为从光标所在行的最后一个字符处开始插入**
* **`o,O`：进入插入模式，o为在目前光标所在的下一行处插入新的一行，O为在目前光标所在处的上一行插入新的一行**
* **`s,S`：进入插入模式，s为删除目前光标所在的字符，S为删除目前光标所在的行**
* **`r,R`：进入替换模式，r只会替换光标所在的那一个字符一次，R会一直替换光标所在行的文字，直到按下Esc**
* **`Esc`：退回一般模式**
* **`Shift + Left`：向左移动一个单词**
* **`Shift + Right`：向右移动一个单词**
* **`Shift + Up`：向上翻页**
* **`Shift + Down`：向下翻页**

## 1.5 文本对象

**文本对象：`c`、`d`、`v`、`y`等命令后接文本对象，一般格式为：`<范围><类型>`**

* **范围：可选值有`a`和`i`**
    * `a`：表示包含边界
    * `i`：表示不包含边界
* **类型：小括号、大括号、中括号、单引号、双引号等等**
    * `'`
    * `"`
    * `(`
    * `[`
    * `{`

**示例：**

* `i)`：小括号内
* `a)`：小括号内（包含小括号本身）
* `i]`：中括号内
* `a]`：中括号内（包含中括号本身）
* `i}`：大括号内
* `a}`：大括号内（包含大括号本身）
* `i'`：单引号内
* `a'`：单引号内（包含单引号本身）
* `i"`：双引号内
* `a"`：双引号内（包含双引号本身）

## 1.6 文本编辑

* **`x,X`：在一行字当中，x为向后删除一个字符(相当于[Del]键),X为向前删除一个字符(相当于[Backspace])**
* `[n]x`：连续向后删除n个字符
* **`dd`：删除光标所在一整行**
* **`dw`：删除光标所在的字符到光标所在单词的最后一个字符**
* **`[n]dd`：删除光标所在的向下n行(包括当前这一行)**
* **`d1G`：删除光标所在到第一行的所有数据(包括当前这一行)**
* **`dG`：删除光标所在到最后一行的所有数据(包括当前这一行)**
* **`d$`：删除光标所在的字符到该行的最后一个字符(包括光标所指向的字符)**
* **`d0(这是零)`：删除从光标所在的字符到该行最前面一个字符(不包括光标所指向的字符)**
* `J`：将光标所在行与下一行的数据结合成同一行
* `cc`：改写当前行（删除当前行并进入插入模式），同`S`
* `cw`：改写光标开始处的当前单词（若光标在单词中间，不会修改整个单词）
* **`ciw`：改写光标所处的单词（若光标在单词中间，也可以修改整个单词）**
* **`ci'`：改写单引号中的内容**
* **`ci"`：改写双引号中的内容**
* **`ci(`：改写小括号中的内容**
* **`ci[`：改写中括号中的内容**
* **`ci{`：改写大括号中的内容**
* **`u`：复原(撤销)前一个操作**
* **`[Ctrl]+r`：重做上一个操作**
* **`.`：重做上一个操作**

## 1.7 赋值粘贴

* **`yy`：复制光标所在那一行**
* **`[n]yy`：复制光标所在的向下n行(包括当前这一行)**
* **`y1G`：复制光标所在行到第一行的所有数据(包括当前这一行)**
* **`yG`：复制光标所在行到最后一行的数据(包括当前这一行)**
* **`y0(这是零)`：复制光标所在那个字符到该行第一个字符的所有数据(不包括光标所指向的字符)**
* **`y$`：复制光标所在那个字符到该行最后一个字符的所有数据(包括光标所指向的字符)**
* **`p,P`：p将已复制的数据在光标的下一行粘贴，P为粘贴在光标的上一行**
* **`v`：字符选择：会将光标经过的地方反白选择**
* **`vw`：选择光标开始处的当前单词（若光标在单词中间，不会选择整个单词）**
* **`viw`：选择光标所处的单词（若光标在单词中间，也可以选中整个单词）**
* **`vi'`：选择单引号中的内容**
* **`vi"`：选择双引号中的内容**
* **`vi(`：选择小括号中的内容**
* **`vi[`：选择中括号中的内容**
* **`vi{`：选择大括号中的内容**
* **`V`：行选择：会将光标经过的行反白选择**
* **`[Ctrl]+v`：块选择，可以用长方形的方式选择数据**

## 1.8 查找替换

* **`/[word]`：向下寻找一个名为word的字符串，支持正则表达式**
* **`?[word]`：向上寻找一个名为word的字符串，支持正则表达式**
    * `n`：重复前一个查找操作
    * `N`："反向"进行前一个查找操作
* **`:[n1],[n2]s/[word1]/[word2]/g`：在n1与n2行之间寻找word1这个字符串，并将该字符串替换为word2，支持正则表达式**
* **`:1,$s/[word1]/[word2]/g`或者`:%s/[word1]/[word2]/g`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，支持正则表达式**
* **`:1,$s/[word1]/[word2]/gc`或者`:%s/[word1]/[word2]/gc`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，且在替换前显示提示字符给用户确认是否替换，支持正则表达式**

## 1.9 文件操作

* **`:w`：将编辑的数据写入硬盘文件中**
* **`:w!`：若文件属性为只读时，强制写入该文件，不过到底能不能写入，还是跟你对该文件的文件属性权限有关**
* **`:q`：离开**
* **`:q!`：若曾修改过文件，又不想存储，使用"!"为强制离开不保存的意思**
* **`:wq`：保存后离开,若为:wq!则代表强制保存并离开**
* `ZZ`：若文件没有变更，则不保存离开，若文件已经变更过，保存后离开
* `:w [filename]`：将编辑文件保存称为另一个文件,注意w和文件名中间有空格
* `:r [filename]`：在编辑的数据中，读入另一个文件的数据，即将filename这个文件的内容加到光标所在行后面，注意r和文件名之间有空格
* `:[n1],[n2]w [filename]`：将n1到n2的内容保存成filename这个文件，注意w和文件名中间有空格，[n2]与w之间可以没有空格
* `vim [filename1] [filename2]...`：同时编辑多个文件
* `:n`：编辑下一个文件
* `:N`：编辑上一个文件
* `:files`：列出这个`vim`打开的所有文件
* **`:Vex`：打开目录**

## 1.10 多窗口功能

有一个文件非常大，在查阅后面的数据时，想要对照前面的数据，如果用翻页等命令`[Ctrl]+f`、`[Ctrl]+b`会显得很麻烦

在一般模式中输入命令`sp:`

* 若要打开同一文件，输入`sp`即可
* 若要代开其他文件，输入`sp [filename]`即可

**窗口切换命令：**

* `[Ctrl]+w+↓`：首先按下`Ctrl`，在按下`w`，然后放开两个键，再按下`↓`切换到下方窗口
* `[Ctrl]+w+↑`：首先按下`Ctrl`，在按下`w`，然后放开两个键，再按下`↑`切换到上方窗口

**分屏**

* `Ctrl+w &`：先Ctrl再w，放掉Ctrl和w再按&，以下操作以此为基准
1. `vim -On file1 file2...`：垂直分屏
1. `vim -on file1 file2...`：左右分屏
1. `Ctrl+w c`：关闭当前窗口(无法关闭最后一个)
1. `Ctrl+w q`：关闭当前窗口(可以关闭最后一个)
1. `Ctrl+w o`：关闭其他窗口
1. `Ctrl+w s`：上下分割当前打开的文件
1. `Ctrl+w v`：左右分割当前打开的文件
1. `:sp filename`：上下分割并打开一个新的文件
1. `:vsp filename`：左右分割，并打开一个新的文件
1. `Ctrl+w l`：把光标移动到右边的屏中
1. `Ctrl+w h`：把光标移动到左边的屏中
1. `Ctrl+w k`：把光标移动到上边的屏中
1. `Ctrl+w j`：把光标移动到下边的屏中
1. **`Ctrl+w w`：把光标移动到下一个屏中，如果只有两个窗口的话，就可以相互切换了**
1. `Ctrl+w L`：向右移动屏幕
1. `Ctrl+w H`：向左移动屏幕
1. `Ctrl+w K`：向上移动屏幕
1. `Ctrl+w J`：向下移动屏幕
1. `Ctrl+w =`：让所有屏幕都有一样的高度
1. `Ctrl+w +`：增加高度
1. `Ctrl+w -`：减小高度

## 1.11 vim常用配置项

```
:set nocompatible   设置不兼容原始 vi 模式（必须设置在最开头）
:set bs=?           设置BS键模式，现代编辑器为 :set bs=eol,start,indent
:set sw=4           设置缩进宽度为 4
:set ts=4           设置制表符宽度为 4
:set noet           设置不展开 tab 成空格
:set et             设置展开 tab 成空格
:set winaltkeys=no  设置 GVim 下正常捕获 ALT 键
:set nowrap         关闭自动换行
:set ttimeout       允许终端按键检测超时（终端下功能键为一串ESC开头的扫描码）
:set ttm=100        设置终端按键检测超时为100毫秒
:set term=?         设置终端类型，比如常见的 xterm
:set ignorecase     设置搜索忽略大小写(可缩写为 :set ic)
:set noignorecase   设置搜索不忽略大小写(可缩写为 :set noic)
:set smartcase      智能大小写，默认忽略大小写，除非搜索内容里包含大写字母
:set list           设置显示制表符和换行符
:set number         设置显示行号，禁止显示行号可以用 :set nonumber
:set relativenumber 设置显示相对行号（其他行与当前行的距离）
:set paste          进入粘贴模式（粘贴时禁用缩进等影响格式的东西）
:set nopaste        结束粘贴模式
:set spell          允许拼写检查
:set hlsearch       设置高亮查找
:set ruler          总是显示光标位置
:set incsearch      查找输入时动态增量显示查找结果
:set insertmode     Vim 始终处于插入模式下，使用 ctrl-o 临时执行命令
:set all            列出所有选项设置情况
:syntax on          允许语法高亮
:syntax off         禁止语法高亮
```

## 1.12 vim配置文件

`vim`会主动将你曾经做过的行为记录下来，好让你下次可以轻松作业，记录操作的文件就是`~/.viminfo`

整体vim的设置值一般放置在`/etc/vimrc`这个文件中，不过不建议修改它，但是可以修改`~/.vimrc`这个文件(默认不存在，手动创建)

**在运行`vim`的时候，如果修改了`~/.vimrc`文件的内容，可以通过执行`:so %`来重新加载`~/.vimrc`，立即生效配置**

### 1.12.1 修改tab的行为

修改`~/.vimrc`，追加如下内容

```
set ts=4
set expandtab
set autoindent
```

## 1.13 其他

**第一部分：一般模式可用的按钮说明，光标移动，复制粘贴，查找替换等**

* `[Shift]+3`：以暗黄色为底色显示所有指定的字符串
* **`[Shift]+>`：向右移动**
* **`[Shift]+<`：向左移动**
* `:nohlsearch`：取消[Shift]+3的显示(no hightlight search)
* **`q:`：进入命令历史编辑**
* **`q/`：进入搜索历史编辑**
* **`q[a-z`]：q后接任意字母，进入命令记录**
* 针对以上三个：
    * 可以像编辑缓冲区一样编辑某个命令，然后回车执行
    * 可以用ctrl-c退出历史编辑回到编辑缓冲区，但此时历史编辑窗口不关闭，可以参照之前的命令再自己输入
    * **输入`:x`关闭历史编辑并放弃编辑结果回到编辑缓冲区**
    * 可以在空命令上回车相当于退出历史编辑区回到编辑缓冲区

## 1.14 Tips

### 1.14.1 多行更新

**示例：多行同时插入相同内容**

1. 在需要插入内容的列的位置，按`[Ctrl]+v`，选择需要同时修改的行
1. 按`I`进入编辑模式
1. 编写需要插入的文本
1. 按两下`ecs`

**示例：多行同时删除相同的内容**

1. 在需要插入内容的列的位置，按`[Ctrl]+v`，选择需要同时修改的行
1. 选中需要同时修改的列
1. 按`d`即可同时删除

### 1.14.2 中文乱码

**编辑`/etc/vimrc`，追加如下内容**

```sh
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

# 2 vim插件管理

**目前，使用最广泛的插件管理工具是：[vim-plug](https://github.com/junegunn/vim-plug)**

## 2.1 常用插件概览

| 插件名称 | 用途 | 官网地址 |
|:--|:--|:--|
| `gruvbox` | 配色方案 | https://github.com/morhetz/gruvbox |
| `vim-airline` | 状态栏 | https://github.com/vim-airline/vim-airline |
| `indentLine` | 缩进标线 | https://github.com/Yggdroot/indentLine |
| `nerdtree` | 文件管理器 | https://github.com/preservim/nerdtree |
| `tagbar` | 代码提纲 | https://github.com/preservim/tagbar |
| `rainbow_parentheses` | 彩虹括号 | https://github.com/kien/rainbow_parentheses.vim |
| `Universal CTags` | 符号索引 | https://ctags.io/ |
| `vim-gutentags` | 自动索引 | https://github.com/ludovicchabant/vim-gutentags |
| `AsyncRun` | 编译运行 | https://github.com/skywind3000/asyncrun.vim |
| `ALE` | 动态检查 | https://github.com/dense-analysis/ale |
| `vim-signify` | 修改比较 | https://github.com/mhinz/vim-signify |
| `textobj-user` | 文本对象 | https://github.com/kana/vim-textobj-user |
| `vim-cpp-enhanced-highlight` | 语法高亮 | https://github.com/octol/vim-cpp-enhanced-highlight |
| `YouCompleteMe` | 代码补全 | https://github.com/ycm-core/YouCompleteMe |
| `LeaderF` | 函数列表 | https://github.com/Yggdroot/LeaderF |
| `echodoc` | 参数提示 | https://github.com/Shougo/echodoc.vim |

## 2.2 centos安装vim8

上述很多插件对`vim`的版本有要求，至少是`vim8`，而一般通过`yum install`安装的`vim`版本是`7.x`

```sh
# 卸载
yum remove vim-* -y

# 通过非官方源fedora安装最新版的vim
curl -L https://copr.fedorainfracloud.org/coprs/lantw44/vim-latest/repo/epel-7/lantw44-vim-latest-epel-7.repo -o /etc/yum.repos.d/lantw44-vim-latest-epel-7.repo
yum install -y vim

# 确认
vim --version | head -1
```

## 2.3 安装vim-plug

按照[vim-plug](https://github.com/junegunn/vim-plug)官网文档，通过一个命令直接安装即可

```sh
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

**基本用法**

1. 以`call plug#begin()`开头
1. 中间是`Plug`的相关命令
1. 以`call plug#end()`结尾，默认会开启如下功能，如果不需要的话，可以手动关闭
    * `filetype plugin indent on`
    * `syntax enable`

**基本操作**

* `:PlugStatus`：查看插件状态
* `:PlugInstall`：安装插件
* `:PlugClean`：清除插件

**修改下载源：默认从`github`上下载，稳定性较差，可以按照如下方式修改`~/.vim/autoload/plug.vim`**

```js
// 将
let fmt = get(g:, 'plug_url_format', 'https://git::@github.com/%s.git')
// 修改为
let fmt = get(g:, 'plug_url_format', 'https://git::@hub.fastgit.org/%s.git')

// 将
\ '^https://git::@github\.com', 'https://github.com', '')
// 修改为
\ '^https://git::@hub.fastgit\.org', 'https://hub.fastgit.org', '')
```

**退格失效，编辑`~/.vimrc`，追加如下内容**

```vim
set backspace=indent,eol,start
```

## 2.4 配色方案-`gruvbox`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'morhetz/gruvbox'

" -------- 下面是该插件的一些参数 --------

" 启用gruvbox配色方案（~/.vim/colors目录下需要有gruvbox对应的.vim文件）
colorscheme gruvbox
" 设置背景，可选值有：dark, light
set background=dark
" 设置软硬度，可选值有soft、medium、hard。针对dark和light主题分别有一个配置项
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**将`gruvbox`中的配色方案（执行完`:PlugInstall`才有这个文件哦）移动到`vim`指定目录下**

```sh
# ~/.vim/colors 目录默认是不存在的
mkdir ~/.vim/colors
cp ~/.vim/plugged/gruvbox/colors/gruvbox.vim ~/.vim/colors/
```

## 2.5 状态栏-`vim-airline`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'vim-airline/vim-airline'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.6 缩进标线-`indentLine`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'Yggdroot/indentLine'

" -------- 下面是该插件的一些参数 --------

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 0
let g:indentLine_char = '|'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.7 文件管理器-`nerdtree`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'scrooloose/nerdtree'

" -------- 下面是该插件的一些参数 --------

" F2 快速切换
nmap <F2> :NERDTreeToggle<CR>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.8 代码提纲-`tagbar`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'majutsushi/tagbar'

" -------- 下面是该插件的一些参数 --------

nmap <F8> :TagbarToggle<CR>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.9 彩虹括号-`rainbow_parentheses`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'kien/rainbow_parentheses.vim'

" -------- 下面是该插件的一些参数 --------

let g:rbpt_colorpairs = [
    \ ['brown', 'RoyalBlue3'],
    \ ['Darkblue', 'SeaGreen3'],
    \ ['darkgray', 'DarkOrchid3'],
    \ ['darkgreen', 'firebrick3'],
    \ ['darkcyan', 'RoyalBlue3'],
    \ ['darkred', 'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown', 'firebrick3'],
    \ ['gray', 'RoyalBlue3'],
    \ ['black', 'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue', 'firebrick3'],
    \ ['darkgreen', 'RoyalBlue3'],
    \ ['darkcyan', 'SeaGreen3'],
    \ ['darkred', 'DarkOrchid3'],
    \ ['red', 'firebrick3'],
    \ ]
let g:rbpt_max = 8
let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
au Syntax * RainbowParenthesesLoadChevrons

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.10 符号索引-`Universal CTags`

**安装：参照[github官网文档](https://github.com/universal-ctags/ctags)进行编译安装即可**

```sh
git clone https://github.com/universal-ctags/ctags.git --depth 1
cd ctags
./autogen.sh
./configure --prefix=/usr/local
make
make install # may require extra privileges depending on where to install
```

**推荐配置，在`~/.vimrc`中增加如下配置**

* **注意，这里将tag的文件名从`tags`换成了`.tags`，这样避免污染项目中的其他文件。因此在使用`ctags`命令生成tag文件时，需要通过`-f .tags`参数指定文件名**

```vim
set tags=./.tags;,.tags
```

**在工程中生成ctags**

```sh
# 与上面的~/.vimrc中的配置对应，需要将tag文件名指定为.tags
ctags -R -f .tags *
```

**如何为系统库生成ctags**

```sh
ctags --fields=+iaS --extras=+q -R -f ~/.vim/systags \
/usr/include \
/usr/local/include \
/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include/ \
/usr/include/c++/4.8.5/
```

然后在`~/.vimrc`中增加如下配置

```vim
set tags+=~/.vim/systags
```

**使用：**

* `ctrl + ]`：跳转到符号定义处
* `ctrl + w + ]`：在新的窗口中跳转到符号定义处
* `:ts`：显示所有的匹配项。按`ECS`再输入序号，再按`Enter`就可以进入指定的匹配项

## 2.11 自动索引-`vim-gutentags`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'ludovicchabant/vim-gutentags'

" -------- 下面是该插件的一些参数 --------

" gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.12 编译运行-`AsyncRun`

本质上，`AsyncRun`插件就是提供了异步执行命令的机制，我们可以利用这个机制定义一些动作，比如`编译`、`构建`、`运行`、`测试`等，提供类似于`IDE`的体验

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/asyncrun.vim'

" -------- 下面是该插件的一些参数 --------

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" 设置编译项目的快捷键（这里只是示例，具体命令需要自行调整） 
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

" 设置运行项目的快捷键（这里只是示例，具体命令需要自行调整） 
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>

" 设置测试项目的快捷键（这里只是示例，具体命令需要自行调整） 
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.13 动态检查-`ALE`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'dense-analysis/ale'

" -------- 下面是该插件的一些参数 --------

" 不显示状态栏+不需要高亮行
let g:ale_sign_column_always = 0
let g:ale_set_highlights = 0

" 错误和警告标志
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚡'

" 设置linter（但是并没有效果，所以我注释了
" let g:ale_linters_explicit = 1
" let g:ale_linters = {
"   \   'c': ['gcc'],
"   \   'cpp': ['g++'],
"   \}

let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

" 设置编译器的参数（由于我无法更改默认的linter，所以下面的配置也是无效的，我也注释掉了
" let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
" let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
" let g:ale_c_cppcheck_options = ''
" let g:ale_cpp_cppcheck_options = ''

" 默认的linter是cc，cc是个alias，包含了clang、clang++、gcc、g++，且默认会用clang和clang++
" :ALEInfo 可以看到这些配置
let g:ale_c_cc_executable = 'clang'
let g:ale_cpp_cc_executable = 'clang++'
let g:ale_cpp_cc_options = '-std=c++11 -Wall'
let g:ale_c_cc_options = '-std=c11 -Wall'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **`:ALEInfo`：查看配置信息，拉到最后有命令执行结果**

**问题：**

1. 即便我为`cpp`指定了`g:ale_linters`，并将`g:ale_linters_explicit`设置成1，但是实际的`linter`仍然是默认的`cc`，默认使用的是`clang`、`clang++`

## 2.14 修改比较-`vim-signify`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'mhinz/vim-signify'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* `set signcolumn=yes`，有改动的行会标出
* `:SignifyDiff`：以左右分屏的方式对比当前文件的差异

## 2.15 文本对象-`textobj-user`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'kana/vim-textobj-user'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.16 语法高亮-`vim-cpp-enhanced-highlight`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'octol/vim-cpp-enhanced-highlight'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.17 代码补全-`YouCompleteMe`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'ycm-core/YouCompleteMe'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.18 个人完整配置

**`~/.vimrc`完整配置如下**

```vim
call plug#begin()

Plug 'morhetz/gruvbox'

" 启用gruvbox配色方案（~/.vim/colors目录下需要有gruvbox对应的.vim文件）
colorscheme gruvbox
" 设置背景，可选值有：dark, light
set background=dark
" 设置软硬度，可选值有soft、medium、hard。针对dark和light主题分别有一个配置项
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_contrast_light = 'hard'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'vim-airline/vim-airline'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'Yggdroot/indentLine'

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 0
let g:indentLine_char = '|'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'scrooloose/nerdtree'

" F2 快速切换
nmap <F2> :NERDTreeToggle<CR>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'majutsushi/tagbar'

nmap <F8> :TagbarToggle<CR>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'kien/rainbow_parentheses.vim'

let g:rbpt_colorpairs = [
    \ ['brown', 'RoyalBlue3'],
    \ ['Darkblue', 'SeaGreen3'],
    \ ['darkgray', 'DarkOrchid3'],
    \ ['darkgreen', 'firebrick3'],
    \ ['darkcyan', 'RoyalBlue3'],
    \ ['darkred', 'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown', 'firebrick3'],
    \ ['gray', 'RoyalBlue3'],
    \ ['black', 'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue', 'firebrick3'],
    \ ['darkgreen', 'RoyalBlue3'],
    \ ['darkcyan', 'SeaGreen3'],
    \ ['darkred', 'DarkOrchid3'],
    \ ['red', 'firebrick3'],
    \ ]
let g:rbpt_max = 8
let g:rbpt_loadcmd_toggle = 0
au VimEnter * RainbowParenthesesToggle
au Syntax * RainbowParenthesesLoadRound
au Syntax * RainbowParenthesesLoadSquare
au Syntax * RainbowParenthesesLoadBraces
au Syntax * RainbowParenthesesLoadChevrons

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'ludovicchabant/vim-gutentags'

" gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

" 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/asyncrun.vim'

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'dense-analysis/ale'

" 不显示状态栏+不需要高亮行
let g:ale_sign_column_always = 0
let g:ale_set_highlights = 0

" 错误和警告标志
let g:ale_sign_error = '✗'
let g:ale_sign_warning = '⚡'

" 设置linter（但是并没有效果，所以我注释了
" let g:ale_linters_explicit = 1
" let g:ale_linters = {
"   \   'c': ['gcc'],
"   \   'cpp': ['g++'],
"   \}

let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

" 设置编译器的参数（由于我无法更改默认的linter，所以下面的配置也是无效的，我也注释掉了
" let g:ale_c_gcc_options = '-Wall -O2 -std=c99'
" let g:ale_cpp_gcc_options = '-Wall -O2 -std=c++14'
" let g:ale_c_cppcheck_options = ''
" let g:ale_cpp_cppcheck_options = ''

" 默认的linter是cc，cc是个alias，包含了clang、clang++、gcc、g++，且默认会用clang和clang++
" :ALEInfo 可以看到这些配置
let g:ale_c_cc_executable = 'clang'
let g:ale_cpp_cc_executable = 'clang++'
let g:ale_cpp_cc_options = '-std=c++11 -Wall'
let g:ale_c_cc_options = '-std=c11 -Wall'

call plug#end()

" ctags的配置
set tags=./.tags;,.tags
set tags+=~/.vim/systags

" 退格失效的配置
set backspace=indent,eol,start

" tab相关配置
set ts=4
set expandtab
set autoindent
```

# 3 参考

* **[《Vim 中文版入门到精通》](https://github.com/wsdjeg/vim-galore-zh_cn)**
* **[《Vim 中文速查表》](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)**
* **[如何在 Linux 下利用 Vim 搭建 C/C++ 开发环境?](https://www.zhihu.com/question/47691414)**
* **[三十分钟配置一个顺滑如水的 Vim](https://zhuanlan.zhihu.com/p/102033129)**
* [如何优雅的使用 Vim（二）：插件介绍](https://segmentfault.com/a/1190000014560645)
* [打造 vim 编辑 C/C++ 环境](https://carecraft.github.io/language-instrument/2018/06/config_vim/)
* [VIM-Plug安装插件时，频繁更新失败，或报端口443被拒绝等](https://blog.csdn.net/htx1020/article/details/114364510)
* [Cannot find color scheme 'gruvbox' #85](https://github.com/morhetz/gruvbox/issues/85)
* 《鸟哥的Linux私房菜》
* [Mac 的 Vim 中 delete 键失效的原因和解决方案](https://blog.csdn.net/jiang314/article/details/51941479)
* [解决linux下vim中文乱码的方法](https://blog.csdn.net/zhangjiarui130/article/details/69226109)
* [vim-set命令使用](https://www.jianshu.com/p/97d34b62d40d)
