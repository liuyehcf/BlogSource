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

以vi打开一个文件就进入一般模式了（这是默认模式）

在这个模式中，你可以使用上下左右按键来移动光标，可以删除字符或删除整行，也可以复制粘贴你的文件数据

### 1.1.2 编辑模式

在一般模式中，可以进行删除，复制，粘贴等操作，但是却无法编辑文件内容。要等到你按下`i(I),o(O),a(A),r(R)`等任何一个字母后才会进入编辑模式

如果要回到一般模式，必须按下Esc这个按键即可退出编辑器

### 1.1.3 命令行模式

在一般模式中，输入`:`、`/`、`?`这三个钟的任何一个按钮，就可以将光标移动到最下面一行，在这个模式中，可以提供你查找数据的操作，而读取、保存、大量替换字符、离开`vim`、显示行号等操作则是在此模式中完成的

## 1.2 光标移动

* **`j或↓`：光标向下移动一个字符**
* **`k或↑`：光标向上移动一个字符**
* **`h或←`：光标向左移动一个字符**
* **`l或→`：光标向右移动一个字符**
* 可以配合数字使用，如向右移动30个字符`30l`或`30→`
* **`[Ctrl] + f`：屏幕向下移动一页，相当于`[Page Down]`按键**
* **`[Ctrl] + b`：屏幕向上移动一页，相当于`[Page Up]`按键**
* **`[Ctrl] + d`：屏幕向下移动半页**
* **`[Ctrl] + u`：屏幕向上移动半页**
* **`+`：光标移动到非空格符的下一行**
* **`-`：光标移动到非空格符的上一行**
* `[n][space]`：n表示数字，再按空格键，光标会向右移动n个字符
* **`0（数字零）或[home]`：移动到这一行的最前面字符处**
* **`^`：移动到这一行的最前面的非空白字符处**
* **`$或功能键end`：移动到这一行最后面的字符处**
* **`H`：光标移动到屏幕最上方那一行的第一个字符**
* **`M`：光标移动到这个屏幕的中央那一行的第一个字符**
* **`L`：光标移动到这个屏幕的最下方那一行的第一个字符**
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
* **`f<x>`：向后，跳转到第1个为`x`的字符**
* **`[n]f<x>`：向后，跳转到第n个为`x`的字符**
* **`F<x>`：向前，跳转到第1个为`x`的字符**
* **`[n]F<x>`：向前，跳转到第n个为`x`的字符**
* **`G`：移动到这个文件的最后一行**
* `[n]G`：n为数字，移动到这个文件的第n行
* **`gg`：移动到这个文件的第一行，相当于1G**
* **`[n][Enter]`：光标向下移动n行**

## 1.3 文件跳转

* **`[Ctrl] + ]`：跳转到光标指向的符号的定义处**
* **`[Ctrl] + o`：回到上一次编辑处**
* **`[Ctrl] + i`：回到下一次编辑处**
* **`gf`：跳转光标指向的头文件**
    * 通过`set path=`或`set path+=`设置或增加头文件搜索路径
    * 通过`set path?`可以查看该变量的内容
* **`[Ctrl] + ^`：在前后两个文件之间跳转**

## 1.4 编辑模式

* **`i,I`：进入插入模式，i为从光标所在处插入，I为在目前所在行的第一个非空格处开始插入**
* **`a,A`：进入插入模式，a为从目前光标所在的下一个字符处开始插入，A为从光标所在行的最后一个字符处开始插入**
* **`o,O`：进入插入模式，o为在目前光标所在的下一行处插入新的一行，O为在目前光标所在处的上一行插入新的一行**
* **`s,S`：进入插入模式，s为删除目前光标所在的字符，S为删除目前光标所在的行**
* **`r,R`：进入替换模式，r只会替换光标所在的那一个字符一次，R会一直替换光标所在行的文字，直到按下Esc**
* **`Esc`：退回一般模式**
* **`[Ctrl] + [`：退回一般模式**
* **`[Shift] + [Left]`：向左移动一个单词**
* **`[Shift] + [Right]`：向右移动一个单词**
* **`[Shift] + [Up]`：向上翻页**
* **`[Shift] + [Down]`：向下翻页**

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

## 1.6 代码折叠

**按照折叠所依据的规则，可以分为如下4种：**

1. **`manual`：手工折叠**
    * **`:set foldmethod=manual`**
    * **`zf`：需要配合范围选择，创建折叠**
    * **`zf`还可以与文本对象配合，例如**
        * `zfi{`：折叠大括号之间的内容，不包括大括号所在行
        * `zfa{`：折叠大括号之间的内容，包括大括号所在行
    * `zd/zD`：删除当前折叠**
    * `zE`：删除所有折叠
1. **`indent`：缩进折叠**
    * **`:set foldmethod=indent`**
    * **`:set foldlevel=[n]`**
1. `marker`：标记折叠
    * `:set foldmethod=marker`
1. `syntax`：语法折叠
    * `:set foldmethod=syntax`

**通用操作（大写表示递归）：**

* **`zN`：启用折叠**
* **`zn`：禁用折叠**
* **`za/zA`：折叠/展开当前的代码**
* **`zc/zC`：折叠当前的代码**
* **`zo/zO`：展开当前的代码**
* **`zm/zM`：折叠所有代码**
* **`zr/zR`：展开所有代码**
* **`zj`：移动到下一个折叠**
* **`zk`：移动到上一个折叠**

## 1.7 文本编辑

* **`x,X`：在一行字当中，x为向后删除一个字符（相当于`[Del]`键）,X为向前删除一个字符（相当于`[Backspace]`）**
* `[n]x`：连续向后删除n个字符
* **`dd`：删除光标所在一整行**
* **`dw`：删除光标所在的字符到光标所在单词的最后一个字符**
* **`[n]dd`：删除光标所在的向下n行（包括当前这一行）**
* **`d1G`：删除光标所在到第一行的所有数据（包括当前这一行）**
* **`dG`：删除光标所在到最后一行的所有数据（包括当前这一行）**
* **`d$`：删除光标所在的字符到该行的最后一个字符（包括光标所指向的字符）**
* **`d0（这是零）`：删除从光标所在的字符到该行最前面一个字符（不包括光标所指向的字符）**
* `J`：将光标所在行与下一行的数据结合成同一行
* `cc`：改写当前行（删除当前行并进入插入模式），同`S`
* `cw`：改写光标开始处的当前单词（若光标在单词中间，不会修改整个单词）
* **`ciw`：改写光标所处的单词（若光标在单词中间，也可以修改整个单词）**
* **`ci'`：改写单引号中的内容**
* **`ci"`：改写双引号中的内容**
* **`ci(`：改写小括号中的内容**
* **`ci[`：改写中括号中的内容**
* **`ci{`：改写大括号中的内容**
* **`u`：复原（撤销）前一个操作**
* **`[Ctrl] + r`：重做上一个操作**
* **`.`：重做上一个操作**

## 1.8 复制粘贴

* **`yy`：复制光标所在那一行**
* **`[n]yy`：复制光标所在的向下n行（包括当前这一行）**
* **`y1G`：复制光标所在行到第一行的所有数据（包括当前这一行）**
* **`yG`：复制光标所在行到最后一行的数据（包括当前这一行）**
* **`y0（这是零）`：复制光标所在那个字符到该行第一个字符的所有数据（不包括光标所指向的字符）**
* **`y$`：复制光标所在那个字符到该行最后一个字符的所有数据（包括光标所指向的字符）**
* **`p`：将已复制的数据粘贴到光标之前**
* **`P`：将已复制的数据粘贴到光标之后**

### 1.8.1 剪切板

**`vim`中有许多寄存器（该寄存器并不是cpu中的寄存器），或者称为剪切板，分别是：**

* `0-9`：vim用来保存最近复制、删除等操作的内容，其中0号寄存器保存的是最近一次操作的内容
* `a-zA-Z`：用户寄存器，`vim`不会读写这部分寄存器
* `"`：未命名的寄存器
* `+`：关联系统剪切板

**如何使用这些寄存器：`"<reg name><operator>`**

* 最左侧的`"`是固定语法
* `<reg name>`：寄存器名称，比如`0`、`a`、`+`、`"`等
* `<operator>`：需要执行的操作，就是`y/d/p`等等

**示例：**

* `:reg`：查看寄存器的信息
* `:reg <reg name>`：查看某个寄存器的内容
* `"+yy`：将当前行拷贝到系统剪切板
* `"+p`：将系统剪切板中的内容粘贴到光标之后

## 1.9 范围选择

* **`v`：字符选择：会将光标经过的地方反白选择**
* **`vw`：选择光标开始处的当前单词（若光标在单词中间，不会选择整个单词）**
* **`viw`：选择光标所处的单词（若光标在单词中间，也可以选中整个单词）**
* **`vi'`：选择单引号中的内容**
* **`vi"`：选择双引号中的内容**
* **`vi(`：选择小括号中的内容**
* **`vi[`：选择中括号中的内容**
* **`vi{`：选择大括号中的内容**
* **`V`：行选择：会将光标经过的行反白选择**
* **`[Ctrl] + v`：块选择，可以用长方形的方式选择数据**
* `>`：增加缩进
* `<`：减少缩进
* `~`：转换大小写
* `c/y/d`：改写/拷贝/删除
* `u`：变为小写
* `U`：变为大写
* `o`：跳转到标记区的另外一端
* `O`：跳转到标记块的另外一端

## 1.10 查找替换

* **查找**
    * **`/[word]`：向下寻找一个名为word的字符串，支持正则表达式**
    * **`/\<[word]\>`：向下寻找一个名为word的字符串（全词匹配），支持正则表达式**
    * `?[word]`：向上寻找一个名为word的字符串，支持正则表达式
    * `?\<[word]\>`：向上寻找一个名为word的字符串（全词匹配），支持正则表达式
    * `n`：重复前一个查找操作
    * `N`："反向"进行前一个查找操作
* **替换**
    * **`:[n1],[n2]s/[word1]/[word2]/g`：在n1与n2行之间寻找word1这个字符串，并将该字符串替换为word2，支持正则表达式**
    * **`:[n1],[n2]s/\<[word1]\>/[word2]/g`：在n1与n2行之间寻找word1这个字符串（全词匹配），并将该字符串替换为word2，支持正则表达式**
    * **`:1,$s/[word1]/[word2]/g`或者`:%s/[word1]/[word2]/g`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，支持正则表达式**
    * **`:1,$s/[word1]/[word2]/gc`或者`:%s/[word1]/[word2]/gc`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，且在替换前显示提示字符给用户确认是否替换，支持正则表达式**
* **`[Ctrl]+r`以及`[Ctrl]+w`：将光标下的字符串添加到搜索或者替换表达式中**

## 1.11 文件操作

* **`:w`：将编辑的数据写入硬盘文件中**
* **`:w!`：若文件属性为只读时，强制写入该文件，不过到底能不能写入，还是跟你对该文件的文件属性权限有关**
* **`:q`：离开**
* **`:q!`：若曾修改过文件，又不想存储，使用"!"为强制离开不保存的意思**
* **`:wq`：保存后离开,若为:wq!则代表强制保存并离开**
* **`:e [filename]`：打开文件并编辑**
* `ZZ`：若文件没有变更，则不保存离开，若文件已经变更过，保存后离开
* `:w [filename]`：将编辑文件保存称为另一个文件,注意w和文件名中间有空格
* `:r [filename]`：在编辑的数据中，读入另一个文件的数据，即将filename这个文件的内容加到光标所在行后面，注意r和文件名之间有空格
* `:[n1],[n2]w [filename]`：将`n1`到`n2`的内容保存成`filename`这个文件，注意w和文件名中间有空格，`[n2]`与`w`之间可以没有空格
* `vim [filename1] [filename2]...`：同时编辑多个文件
* `:n`：编辑下一个文件
* `:N`：编辑上一个文件
* `:files`：列出这个`vim`打开的所有文件
* **`:Vex`：打开目录**

## 1.12 多窗口功能

有一个文件非常大，在查阅后面的数据时，想要对照前面的数据，如果用翻页等命令`[Ctrl] + f`、`[Ctrl] + b`会显得很麻烦

在一般模式中输入命令`sp:`

* 若要打开同一文件，输入`sp`即可
* 若要代开其他文件，输入`sp [filename]`即可

**窗口切换命令：**

* `[Ctrl] + w + ↓`：首先按下`[Ctrl]`，在按下`w`，然后放开两个键，再按下`↓`切换到下方窗口
* `[Ctrl] + w + ↑`：首先按下`[Ctrl]`，在按下`w`，然后放开两个键，再按下`↑`切换到上方窗口

**分屏**

* **`[Ctrl] + w + <xxx>`：先`[Ctrl]`再`w`，放掉`[Ctrl]`和`w`再按`<xxx>`，以下操作以此为基准**
1. `vim -On file1 file2...`：垂直分屏
1. `vim -on file1 file2...`：左右分屏
1. `[Ctrl] + w + c`：关闭当前窗口（无法关闭最后一个）
1. `[Ctrl] + w + q`：关闭当前窗口（可以关闭最后一个）
1. `[Ctrl] + w + o`：关闭其他窗口
1. `[Ctrl] + w + s`：上下分割当前打开的文件
1. `[Ctrl] + w + v`：左右分割当前打开的文件
1. `:sp filename`：上下分割并打开一个新的文件
1. `:vsp filename`：左右分割，并打开一个新的文件
1. `[Ctrl] + w + l`：把光标移动到右边的屏中
1. `[Ctrl] + w + h`：把光标移动到左边的屏中
1. `[Ctrl] + w + k`：把光标移动到上边的屏中
1. `[Ctrl] + w + j`：把光标移动到下边的屏中
1. **`[Ctrl] + w + w`：把光标移动到下一个屏中，如果只有两个窗口的话，就可以相互切换了**
1. `[Ctrl] + w + L`：向右移动屏幕
1. `[Ctrl] + w + H`：向左移动屏幕
1. `[Ctrl] + w + K`：向上移动屏幕
1. `[Ctrl] + w + J`：向下移动屏幕
1. `[Ctrl] + w + =`：让所有屏幕都有一样的高度
1. `[Ctrl] + w + [+]`：高度增加1
1. `[Ctrl] + w + [n] [+]`：高度增加n
1. `[Ctrl] + w + -`：高度减小1
1. `[Ctrl] + w + [n] -`：高度减小n
1. `[Ctrl] + w + >`：宽度增加1
1. `[Ctrl] + w + [n] + >`：宽度增加n
1. `[Ctrl] + w + <`：宽度减小1
1. `[Ctrl] + w + [n] + <`：宽度减小n

## 1.13 Quickfix

* `:cc`：显示详细信息
* **`:cp`：跳到上一个条目**
* **`:cn`：跳到下一个条目**
* `:cl`：列出所有条目
* `:cw`：如果有错误列表，则打开quickfix窗口 
* `:col`：到前一个旧的错误列表
* `:cnew`：到后一个较新的错误列表

## 1.14 vim常用配置项

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
:set ignorecase     设置搜索忽略大小写（可缩写为 :set ic）
:set noignorecase   设置搜索不忽略大小写（可缩写为 :set noic）
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
:set insertmode     Vim 始终处于插入模式下，使用 [Ctrl] + o 临时执行命令
:set all            列出所有选项设置情况
:syntax on          允许语法高亮
:syntax off         禁止语法高亮
```

## 1.15 vim配置

`vim`会主动将你曾经做过的行为记录下来，好让你下次可以轻松作业，记录操作的文件就是`~/.viminfo`

整体vim的设置值一般放置在`/etc/vimrc`这个文件中，不过不建议修改它，但是可以修改`~/.vimrc`这个文件（默认不存在，手动创建）

**在运行`vim`的时候，如果修改了`~/.vimrc`文件的内容，可以通过执行`:so %`来重新加载`~/.vimrc`，立即生效配置**

### 1.15.1 修改tab的行为

修改`~/.vimrc`，追加如下内容

```vim
" 表示打开文件自动显示行号
set number
" 表示一个Tab键显示出来多少个空格的长度，默认是8，这里设置为4
set tabstop=4
" 表示在编辑模式下按退格键时候退回缩进的长度，设置为4
set softtabstop=4
" 表示每一级缩进的长度，一般设置成和softtabstop长度一样
set shiftwidth=4
" 当设置成expandtab时表示缩进用空格来表示，noexpandtab则用制表符表示一个缩进
set expandtab
" 表示自动缩进
set autoindent
```

### 1.15.2 键位映射

1. **`map`：递归映射**
1. **`noremap`：非递归映射**
1. 映射的作用域包含如下几种：
    * `normal`：如果想要映射仅在这个作用域中生效，那么在前面加上`n`，例如`nmap`以及`nnoremap`
    * `insert`：同上。例如`imap`以及`inoremap`
    * `visual`：同上。例如`vmap`以及`vnoremap`
    * `select`：同上。例如`smap`以及`snoremap`
    * `operator`：同上。例如`omap`以及`onoremap`
1. `unmap`
1. `mapclear`：消所有`map`配置，慎用

**键位表示**

* **`<F-num>`：例如`<F1>`、`<F2>`**
* **`<c-key>`：表示`[Ctrl]`加另一个字母**
* **`<a-key>/<m-key>`：表示`[Alt]`加另一个字母**
* **对于mac上的`[Option]`，并没有`<p-key>`这样的表示方法。而是用`[Option]`加另一个字母实际输出的结果作为映射键值，例如**
    * `[Option] + a`：`å`

## 1.16 其他

* **`set <variable>?`：可以查看`<variable>`的值**
* `[Shift] + 3`：以暗黄色为底色显示所有指定的字符串
* **`[Shift] + >`：向右移动**
* **`[Shift] + <`：向左移动**
* **`:nohlsearch`：取消高亮（no hightlight search）**
* **`q:`：进入命令历史编辑**
* **`q/`：进入搜索历史编辑**
* **`q[a-z`]：q后接任意字母，进入命令记录**
* 针对以上三个：
    * 可以像编辑缓冲区一样编辑某个命令，然后回车执行
    * 可以用`[Ctrl] + c`退出历史编辑回到编辑缓冲区，但此时历史编辑窗口不关闭，可以参照之前的命令再自己输入
    * **输入`:x`关闭历史编辑并放弃编辑结果回到编辑缓冲区**
    * 可以在空命令上回车相当于退出历史编辑区回到编辑缓冲区

## 1.17 Tips

### 1.17.1 多行更新

**示例：多行同时插入相同内容**

1. 在需要插入内容的列的位置，按`[Ctrl] + v`，选择需要同时修改的行
1. 按`I`进入编辑模式
1. 编写需要插入的文本
1. 按两下`ecs`

**示例：多行同时删除相同的内容**

1. 在需要插入内容的列的位置，按`[Ctrl] + v`，选择需要同时修改的行
1. 选中需要同时修改的列
1. 按`d`即可同时删除

### 1.17.2 中文乱码

**编辑`/etc/vimrc`，追加如下内容**

```sh
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

### 1.17.3 为每个项目配置vim

同一份`~./vimrc`无法适用于所有的项目，不同的项目可能需要一些特化的配置项，可以采用如下的设置方式

```vim
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
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
| `vim-cpp-enhanced-highlight` | 语法高亮 | https://github.com/octol/vim-cpp-enhanced-highlight |
| `rainbow_parentheses` | 彩虹括号1 | https://github.com/kien/rainbow_parentheses.vim |
| `rainbow` | 彩虹括号2 | https://github.com/luochen1990/rainbow |
| `Universal CTags` | 符号索引 | https://ctags.io/ |
| `vim-gutentags` | 自动索引 | https://github.com/ludovicchabant/vim-gutentags |
| `LanguageClient-neovim` | 语义索引 | https://github.com/autozimu/LanguageClient-neovim |
| `vim-auto-popmenu` | 轻量补全 | https://github.com/skywind3000/vim-auto-popmenu |
| `YouCompleteMe` | 代码补全 | https://github.com/ycm-core/YouCompleteMe |
| `AsyncRun` | 编译运行 | https://github.com/skywind3000/asyncrun.vim |
| `ALE` | 动态检查 | https://github.com/dense-analysis/ale |
| `vim-signify` | 修改比较 | https://github.com/mhinz/vim-signify |
| `textobj-user` | 文本对象 | https://github.com/kana/vim-textobj-user |
| `LeaderF` | 函数列表 | https://github.com/Yggdroot/LeaderF |
| `fzf.vim` | 全局模糊搜索 | https://github.com/junegunn/fzf.vim |
| `mhinz/vim-grepper` | 全局搜索 | https://github.com/mhinz/vim-grepper |
| `tpope/vim-fugitive` | git扩展 | https://github.com/tpope/vim-fugitive |
| `echodoc` | 参数提示 | https://github.com/Shougo/echodoc.vim |
| `nerdcommenter` | 添加注释 | https://github.com/preservim/nerdcommenter |
| `vim-clang-format` | 代码格式化 | https://github.com/rhysd/vim-clang-format |

## 2.2 环境准备

**为什么需要准备环境，vim的插件管理不是会为我们安装插件么？因为某些复杂插件，比如`ycm`是需要手动编译的，而编译就会依赖一些编译相关的工具，并且要求的版本比较高**

**由于我用的系统是`CentOS 7.9`，通过`yum install`安装的工具都过于陈旧，包括`gcc`、`g++`、`clang`、`clang++`、`cmake`等等，这些工具都需要通过其他方式重新安装**

### 2.2.1 安装gcc

**[gcc各版本源码包下载地址](http://ftp.gnu.org/gnu/gcc/)，我选择的版本是`gcc-10.3.0`**

**若国内下载太慢，可以到[GCC mirror sites](http://gcc.gnu.org/mirrors.html)就近选择镜像源**

```sh
# 下载并解压源码包
wget -O gcc-10.3.0.tar.gz 'http://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.gz'
tar -zxf gcc-10.3.0.tar.gz
cd gcc-10.3.0

# 安装依赖项
yum install -y bzip2 gcc gcc-c++
./contrib/download_prerequisites

# 编译安装（比较耗时，耐心等待）
./configure --disable-multilib --enable-languages=c,c++
make -j 4
make install

# 删除原来的gcc
yum remove -y gcc gcc-c++

# 创建软连接
rm -f /usr/bin/gcc /usr/bin/g++ /usr/bin/cc /usr/bin/c++ /lib64/libstdc++.so.6
ln -s /usr/local/bin/gcc /usr/bin/gcc
ln -s /usr/local/bin/g++ /usr/bin/g++
ln -s /usr/bin/gcc /usr/bin/cc
ln -s /usr/bin/g++ /usr/bin/c++
ln -s /usr/local/lib64/libstdc++.so.6.0.28 /lib64/libstdc++.so.6
```

### 2.2.2 安装python3

```
yum install -y python3
yum install -y python3-devel.x86_64
```

### 2.2.3 安装cmake

**[cmake官网](https://cmake.org/download/)有二进制包可以下载，下载安装即可**

```sh
# 下载二进制包
wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2-linux-x86_64.tar.gz
# 解压到/usr/local/lib目录下
tar -zxvf cmake-3.21.2-linux-x86_64.tar.gz -C /usr/local/lib
# 创建软连接
ln -s /usr/local/lib/cmake-3.21.2-linux-x86_64/bin/cmake /usr/local/bin/cmake
```

### 2.2.4 安装llvm

**根据[官网安装说明](https://clang.llvm.org/get_started.html)进行安装，其代码托管在[github-llvm-project](https://github.com/llvm/llvm-project)**

```sh
# 编译过程会非常耗时，非常占内存，如果内存不足的话请分配足够的swap内存
# 我的编译环境是虚拟机，4c8G，swap分配了25G。编译时，最多使用了4G（主存） + 25G（swap）的内存
# 建议准备150G的磁盘空间，以及30G的swap空间
dd if=/dev/zero of=swapfile bs=1M count=30720 status=progress oflag=sync
mkswap swapfile
chmod 600 swapfile
swapon swapfile

git clone -b release/10.x https://github.com.cnpmjs.org/llvm/llvm-project.git --depth 1
cd llvm-project
mkdir build
cd build
# DLLVM_ENABLE_PROJECTS: 选择clang子项目
# DCMAKE_BUILD_TYPE: 构建类型指定为MinSizeRel。可选值有 Debug, Release, RelWithDebInfo, and MinSizeRel。其中Debug是默认值
cmake -DLLVM_ENABLE_PROJECTS=clang \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-G "Unix Makefiles" ../llvm
make -j 4
make install
```

### 2.2.5 centos安装vim8

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

### 2.2.6 符号索引-[Universal CTags](https://ctags.io/)

**安装：参照[github官网文档](https://github.com/universal-ctags/ctags)进行编译安装即可**

```sh
git clone https://github.com.cnpmjs.org/universal-ctags/ctags.git --depth 1
cd ctags

# 安装依赖工具
yum install -y autoconf automake

./autogen.sh
./configure --prefix=/usr/local
make
make install # may require extra privileges depending on where to install
```

**ctags参数**

* `--c++-kinds=+px`：`ctags`记录c++文件中的函数声明，各种外部和前向声明  
* `--fields=+ialS`：`ctags`要求描述的信息，其中：　　
    * `i`：表示如果有继承，则表示出父类  
	* `a`：表示如果元素是类成员的话，要标明其调用权限(即public或者private)  
	* `l`：表示包含标记源文件的语言  
	* `S`：表示函数的签名(即函数原型或者参数列表)  
* `--extras=+q`：强制要求ctags做如下操作，如果某个语法元素是类的一个成员，ctags默认会给其记录一行，以要求ctags对同一个语法元素再记一行，这样可以保证在VIM中多个同名函数可以通过路径不同来区分
* `-R`：`ctags`递归生成子目录的tags（在项目的根目录下很有意义）  

**在工程中生成ctags**

```sh
# 与上面的~/.vimrc中的配置对应，需要将tag文件名指定为.tags
ctags --c++-kinds=+px --fields=+ialS --extras=+q -R -f .tags *
```

**如何为系统库生成ctags，这里生成的系统库对应的ctags文件是`~/.vim/systags`**

```sh
mkdir -p ~/.vim
# 下面2种选一个即可

# 1. 通过yum install -y gcc安装的gcc是4.8.5版本
ctags --c++-kinds=+px --fields=+ialS --extras=+q -R -f ~/.vim/systags \
/usr/include \
/usr/local/include \
/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include/ \
/usr/include/c++/4.8.5/

# 2. 通过上面编译安装的gcc是10.3.0版本
ctags --c++-kinds=+px --fields=+ialS --extras=+q -R -f ~/.vim/systags \
/usr/include \
/usr/local/include \
/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include \
/usr/local/include/c++/10.3.0
```

**使用：**

* `[Ctrl] + ]`：跳转到符号定义处。如果有多条匹配项，则会跳转到第一个匹配项
* `[Ctrl] + w + ]`：在新的窗口中跳转到符号定义处。如果有多条匹配项，则会跳转到第一个匹配项
* `:ts`：显示所有的匹配项。按`ECS`再输入序号，再按`Enter`就可以进入指定的匹配项
* `:tn`：跳转到下一个匹配项
* `:tp`：跳转到上一个匹配项
* `g + ]`：如果有多条匹配项，会直接显式（同`:ts`）

**推荐配置，在`~/.vimrc`中增加如下配置**

* **注意，这里将tag的文件名从`tags`换成了`.tags`，这样避免污染项目中的其他文件。因此在使用`ctags`命令生成tag文件时，需要通过`-f .tags`参数指定文件名**
* **`./.tags;`表示在文件所在目录下查找名字为`.tags`的符号文件，`;`表示查找不到的话，向上递归到父目录，直到找到`.tags`或者根目录**
* **`.tags`是指在`vim`的当前目录（在`vim`中执行`:pwd`）下查找`.tags`文件**

```vim
" 将 :tn 和 :tp 分别映射到 [Option] + j 和 [Option] + k，即「∆」和「˚」
noremap ∆ :tn<cr>
noremap ˚ :tp<cr>
" tags搜索模式
set tags=./.tags;,.tags
" 系统库的ctags
set tags+=~/.vim/systags
```

### 2.2.7 进阶符号索引-Global source code tagging system

**这里有个坑，上面安装的是`gcc-10.3.0`，这个版本编译安装`global`源码会报错（[dev-util/global-6.6.4 : fails to build with -fno-common or gcc-10](https://bugs.gentoo.org/706890)），错误信息大概是`global.o:(.bss+0x74): first defined here`，因此，我们需要再安装一个低版本的gcc，并且用这个低版本的gcc来编译`global`**

```sh
# 安装源
yum install -y centos-release-scl scl-utils

# 安装gcc 7
yum install -y devtoolset-7-toolchain

# 切换软件环境（本小节剩余的操作都需要在这个环境中执行，如果不小心退出来的话，可以再执行一遍重新进入该环境）
scl enable devtoolset-7 bash
```

```sh
# 安装相关软件
yum install -y ncurses-devel gperf bison flex libtool libtool-ltdl-devel texinfo

wget http://tamacom.com/global/global-6.6.4.tar.gz --no-check-certificate
tar -zxvf global-6.6.4.tar.gz
cd global-6.6.4

# 检测脚本，缺什么就装什么
sh reconf.sh

# 编译安装
./configure
make
sudo make install

# 安装成功后，在目录 /usr/local/share/gtags 中会有 gtags.vim 以及 gtags-cscope.vim 这两个文件
# 将这两个文件拷贝到 ~/.vim 目录中
cp -vrf /usr/local/share/gtags/gtags.vim /usr/local/share/gtags/gtags-cscope.vim ~/.vim
```

**在`~/.vimrc`中增加如下配置**

1. 第一个`GTAGSLABEL`告诉`gtags`默认`C/C++/Java`等六种原生支持的代码直接使用`gtags`本地分析器，而其他语言使用`pygments`模块
1. 第二个环境变量必须设置，否则会找不到`native-pygments`和`language map`的定义

```vim
" 设置后会出现「gutentags: gtags-cscope job failed, returned: 1」，所以我把它注释了
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif
```

### 2.2.8 语义索引-ccls

**`ccls`是`Language Server Protocol（LSP）`的一种实现，主要用于`C/C++/Objective-C`等语言**

**安装：参照[github官网文档](https://github.com/MaskRay/ccls)进行编译安装即可**

```sh
git clone https://github.com.cnpmjs.org/MaskRay/ccls.git --depth 1
cd ccls

function setup_github_repo() {
    CONFIGS=( $(grep -rnl 'https://github.com' .git) )
    for CONFIG in ${CONFIGS[@]}
    do
        echo "setup github repo for '${CONFIG}'"
        sed -i 's|https://github.com/|https://github.com.cnpmjs.org/|g' ${CONFIG}
    done
}
# 初始化子模块
setup_github_repo
git submodule init && git submodule update

# 其中 CMAKE_PREFIX_PATH 用于指定 clang/llvm 相关头文件和lib的搜索路径，按照「安装llvm」小节中的安装方法，安装路径就是 /usr/local
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/usr/local

# 编译
cmake --build Release

# 安装
cmake --build Release --target install
```

**如何为工程生成全量索引？**

1. 通过`cmake`等构建工具生成`compile_commands.json`，并将该文件至于工程根目录下
1. 配置`LSP-client`插件，我用的是`LanguageClient-neovim`
1. vim打开工程，便开始自动创建索引

### 2.2.9 安装vim-plug

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
let fmt = get(g:, 'plug_url_format', 'https://git::@github.com.cnpmjs.org/%s.git')

// 将
\ '^https://git::@github\.com', 'https://github.com', '')
// 修改为
\ '^https://git::@github\.com\.cnpmjs\.org', 'https://github.com.cnpmjs.org', '')
```

**退格失效，编辑`~/.vimrc`，追加如下内容**

```vim
set backspace=indent,eol,start
```

## 2.3 配色方案

### 2.3.1 [gruvbox](https://github.com/morhetz/gruvbox)

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

### 2.3.2 [solarized](https://github.com/altercation/vim-colors-solarized)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'altercation/vim-colors-solarized'

" -------- 下面是该插件的一些参数 --------

" 启用solarized配色方案（~/.vim/colors目录下需要有solarized对应的.vim文件）
colorscheme solarized
" 设置背景，可选值有：dark, light
set background=dark

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**将`solarized`中的配色方案（执行完`:PlugInstall`才有这个文件哦）移动到`vim`指定目录下**

```sh
# ~/.vim/colors 目录默认是不存在的
mkdir ~/.vim/colors
cp ~/.vim/plugged/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/
```

## 2.4 状态栏-[vim-airline](https://github.com/vim-airline/vim-airline)

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

## 2.5 缩进标线-[indentLine](https://github.com/Yggdroot/indentLine)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'Yggdroot/indentLine'

" -------- 下面是该插件的一些参数 --------

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.6 文件管理器-[nerdtree](https://github.com/preservim/nerdtree)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'scrooloose/nerdtree'

" -------- 下面是该插件的一些参数 --------

" 配置 F2 打开文件管理器 
nmap <F2> :NERDTreeToggle<CR>
" 配置 F3 定位当前文件
nmap <F3> :NERDTreeFind<CR>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* `:NERDTreeToggle`：打开文件管理器
* `:NERDTreeFind`：打开文件管理器，并且定位到当前文件

## 2.7 语法高亮-[vim-cpp-enhanced-highlight](https://github.com/octol/vim-cpp-enhanced-highlight)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'octol/vim-cpp-enhanced-highlight'

" -------- 下面是该插件的一些参数 --------

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.8 彩虹括号-[rainbow](https://github.com/luochen1990/rainbow)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'luochen1990/rainbow'

" -------- 下面是该插件的一些参数 --------

let g:rainbow_active = 1

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.9 自动索引-[vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)

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

" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('ctags')
	let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
endif

" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extras=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**问题排查：**

1. `let g:gutentags_define_advanced_commands = 1`：允许`gutentags`打开一些高级命令和选项
1. 运行`:GutentagsToggleTrace`：它会将`ctags/gtags`命令的输出记录在`vim`的`message`记录里
1. 保存文件，触发数据库更新
1. `:message`：可以重新查看message

### 2.9.1 gtags查询快捷键-[gutentags_plus](https://github.com/skywind3000/gutentags_plus)

该插件提供一个命令`GscopeFind`，用于`gtags`查询

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/gutentags_plus'

" -------- 下面是该插件的一些参数 --------

" 在查询后，光标切换到 Quickfix 窗口
let g:gutentags_plus_switch = 1

" 禁用默认的映射，默认的映射会与 nerdcommenter 插件冲突
let g:gutentags_plus_nomap = 1

" 定义新的映射
noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>
noremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>

call plug#end()
```

**键位映射说明：**

| keymap | desc |
|--------|------|
| **`<leader>gs`** | 查找光标下符号的引用 |
| `<leader>gg` | 查找光标下符号的定义 |
| `<leader>gd` | 查找被当前函数调用的函数 |
| **`<leader>gc`** | **查找调用当前函数的函数** |
| `<leader>gt` | 查找光标下的字符串 |
| `<leader>ge` | 以`egrep pattern`查找光标下的字符串 |
| `<leader>gf` | 查找光标下的文件名 |
| **`<leader>gi`** | **查找引用光标下头文件的文件** |
| **`<leader>ga`** | **查找光标下符号的赋值处** |
| `<leader>gz` | 在`ctags`中查找光标下的符号 |

**安装：进入vim界面后执行`:PlugInstall`即可**

### 2.9.2 Quickfix预览-[vim-preview](https://github.com/skywind3000/vim-preview)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/vim-preview'

" -------- 下面是该插件的一些参数 --------

autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* 在`Quickfix`中，按`p`打开预览
* 在`Quickfix`中，按`P`关闭预览

## 2.10 语义索引-[LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)

**该插件是作为`LSP`的客户端，这里我们选用的`LSP`的实现是`ccls`**

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
    
" -------- 下面是该插件的一些参数 --------

let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_serverCommands = {}
let g:LanguageClient_serverCommands.c = ['ccls']
let g:LanguageClient_serverCommands.cpp = ['ccls']

noremap <leader>rd :call LanguageClient#textDocument_definition()<cr>
noremap <leader>rr :call LanguageClient#textDocument_references()<cr>
noremap <leader>rv :call LanguageClient#textDocument_hover()<cr>
noremap <leader>rn :call LanguageClient#textDocument_rename()<cr>
noremap <leader>hb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<cr>
noremap <leader>hd :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true})<cr>

call plug#end()
```

**其中，`~/.vim/languageclient.json`的内容示例如下（必须是决定路径，不能用`~`）**

```json
{
	"ccls": {
		"cache": {
			"directory": "/root/.cache/LanguageClient"
		}
	}
}
```

**安装：进入vim界面后执行`:PlugInstall`即可。由于安装时，还需执行一个脚本`install.sh`，该脚本要从github下载一个二进制，在国内容易超时失败，可以用如下方式进行手动安装**

```sh
# 假定通过 :PlugInstall 已经将工程下载到本地了
cd ~/.vim/plugged/LanguageClient-neovim

# 修改地址
sed -i 's|github.com/|github.com.cnpmjs.org/|' install.sh

# 手动执行安装脚本
./install.sh
```

**用法：**

* `\rd`：查找光标下符号的定义
* `\rr`：查找光标下符号的引用
* `\rv`：查看光标下符号的说明
* `\rn`：重命名光标下的符号
* `\hb`：查找光标下符号的父类
* `\hd`：查找光标下符号的子类

## 2.11 代码补全-[YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)

**这个插件比较复杂，建议手工安装**

```sh
# 定义一个函数，用于调整github的地址，加速下载过程，该函数会用到多次
function setup_github_repo() {
    CONFIGS=( $(grep -rnl 'https://github.com' .git) )
    for CONFIG in ${CONFIGS[@]}
    do
        echo "setup github repo for '${CONFIG}'"
        sed -i 's|https://github.com/|https://github.com.cnpmjs.org/|g' ${CONFIG}
    done
}

cd ~/.vim/plugged
git clone https://github.com.cnpmjs.org/ycm-core/YouCompleteMe.git --depth 1
cd YouCompleteMe

# 递归下载ycm的子模块
git submodule update --init --recursive

# 如果下载超时了，重复执行下面这两个命令，直至完毕
setup_github_repo
git submodule update --init --recursive

# 编译
python3 install.py --clang-completer
```

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'ycm-core/YouCompleteMe'

" -------- 下面是该插件的一些参数 --------

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0

let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone

noremap <c-z> <NOP>

let g:ycm_semantic_triggers =  {
           \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
           \ 'cs,lua,javascript': ['re!\w{2}'],
           \ }

call plug#end()
```

**配置`~/.ycm_extra_conf.py`，内容如下（仅针对c/c++），仅供参考**

* 由于我安装的是`gcc`的`10.3.0`版本，所以c和c++的头文件的路径分别是
    * `/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include`
    * `/usr/local/include/c++/10.3.0`

```python
import os
import ycm_core
 
flags = [
    '-Wall',
    '-Wextra',
    '-Werror',
    '-Wno-long-long',
    '-Wno-variadic-macros',
    '-fexceptions',
    '-DNDEBUG',
    '-std=c++14',
    '-x',
    'c++',
    '-I',
    '/usr/include',
    '-isystem',
    '/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include',
    '-isystem',
    '/usr/local/include/c++/10.3.0',
  ]
 
SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', ]
 
def FlagsForFile( filename, **kwargs ):
  return {
    'flags': flags,
    'do_cache': True
  }
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 2.12 编译运行-[AsyncRun](https://github.com/skywind3000/asyncrun.vim)

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

## 2.13 动态检查-[ALE](https://github.com/dense-analysis/ale)

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

" 设置linters，并且仅用指定的linters
" 由于在我的环境中，Available Linters中并没有gcc和g++，但是有cc（Linter Aliases）。cc包含clang、clang++、gcc、g++
" 于是，下面两个配置会使得最终ALE生效的Linter是cc
let g:ale_linters_explicit = 1
let g:ale_linters = {
  \   'c': ['gcc'],
  \   'cpp': ['g++'],
  \}

" 上面的配置使得linter是cc，cc是个alias，包含了clang、clang++、gcc、g++，且默认会用clang和clang++
" 这边我改成gcc、g++
let g:ale_c_cc_executable = 'gcc'
let g:ale_cpp_cc_executable = 'g++'
" -std=c17 和 -std=c++17 会有很多奇怪的问题，因此改用 gnu17 和 gnu++17
let g:ale_c_cc_options = '-std=gnu17 -Wall'
let g:ale_cpp_cc_options = '-std=gnu++17 -Wall'

let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

" 配置快捷键用于在warnings/errors之间跳转
" [Ctrl] + j: 下一个warning/error
" [Ctrl] + k: 上一个warning/error
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

call plug#end()
```

**指定三方库的头文件路径。每种类型的编译器对应的环境变量名是不同的，这里仅以`gcc`和g`++`为例**

```sh
# c头文件路径（gcc）
export C_INCLUDE_PATH=${C_INCLUDE_PATH}:<third party include path...>

# c++头文件路径（g++）
export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:<third party include path...>
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **`:ALEInfo`：查看配置信息，拉到最后有命令执行结果**

**问题：**

1. **若`linter`使用的是`gcc`或者`g++`，即便有语法错误，也不会有提示信息。但是使用`:ALEInfo`查看，是可以看到报错信息的。这是因为ALE识别错误是通过一个关键词`error`，而在我的环境中，gcc编译错误输出的是中文`错误`，因此ALE不认为这是个错误。修改方式如下**
    1. `mv /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    1. `mv /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    * 如果找不到`gcc.mo`文件的话，可以用`locate`命令搜索一下

## 2.14 修改比较-[vim-signify](https://github.com/mhinz/vim-signify)

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

## 2.15 文本对象-[textobj-user](https://github.com/kana/vim-textobj-user)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 其中 kana/vim-textobj-user 提供了自定义文本对象的基础能力，其他插件是基于该插件的扩展
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **`i,/a,`：函数对象。可以用`vi,`/`di,`/`ci,`来选中/删除/改写当前参数**
* **`ii/ai`：缩进对象。可以用`vii`/`dii`/`cii`来选中/删除/改写同一缩进层次的内容**
* **`if/af`：函数对象。可以用`vif`/`dif`/`cif`来选中/删除/改写当前函数的内容**

## 2.16 函数列表-[LeaderF](https://github.com/Yggdroot/LeaderF)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" -------- 下面是该插件的一些参数 --------

" 将文件模糊搜索映射到快捷键 [Ctrl] + p
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
" 将 :LeaderfMru 映射到快捷键 [Ctrl] + n
noremap <c-n> :LeaderfMru<cr>
" 将 :LeaderfFunction! 映射到快捷键 [Option] + p，即「π」
noremap π :LeaderfFunction!<cr>
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

1. `:LeaderfFunction!`：弹出函数列表
    * `tab`可以在搜索和移动两种模式之间进行切换
    * 移动模式下：`j/k`：上下移动
    * 搜索模式下：输入即可进行模糊搜索
1. `:LeaderfMru`：查找最近访问的文件，通过上面的配置映射到快捷键`[Ctrl] + n`
1. 通过上面的配置，将文件模糊搜索映射到快捷键`[Ctrl] + p`

## 2.17 全局模糊搜索-[fzf.vim](https://github.com/junegunn/fzf.vim)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" -------- 下面是该插件的一些参数 --------

" 将 :Rg 映射到快捷键 [Ctrl] + a
noremap <c-a> :Rg<cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法（搜索相关的语法可以参考[junegunn/fzf-search-syntax](https://github.com/junegunn/fzf#search-syntax)）：**

1. `:Ag`：进行全局搜索（依赖命令行工具`ag`，安装方式参考该插件github主页）
    * `[Ctrl] + j/k`可以在条目中上下移动
1. `:Rg`：进行全局搜索（依赖命令行工具`rg`，安装方式参考该插件github主页）
    * `[Ctrl] + j/k`可以在条目中上下移动
* **匹配规则**
    * **`xxx`：模糊匹配（可能被分词）**
    * **`'xxx`：非模糊匹配（不会被分词）**
    * **`^xxx`：前缀匹配**
    * **`xxx$`：后缀匹配**
    * **`!xxx`：反向匹配**
    * **上述规则均可自由组合**

## 2.18 全局搜索-[vim-grepper](https://github.com/mhinz/vim-grepper)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'mhinz/vim-grepper'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* `:Grepper`：进行全局搜索（依赖grep命令）

## 2.19 git扩展-[vim-fugitive](https://github.com/tpope/vim-fugitive)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'tpope/vim-fugitive'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* `:Git`：作为`git`的替代，后跟`git`命令行工具的正常参数即可

## 2.20 添加注释-[nerdcommenter](https://github.com/preservim/nerdcommenter)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'preservim/nerdcommenter'

" -------- 下面是该插件的一些参数 --------

let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* **`\cc`：添加注释，对每一行都会添加注释**
* **`\cm`：对被选区域用一对注释符进行注释**
* **`\cs`：添加性感的注释**
* **`\ca`：更换注释的方式**
* **`\cu`：取消注释**
* **`\c<space>`：如果被选区域有部分被注释，则对被选区域执行取消注释操作，其它情况执行反转注释操作**

## 2.21 代码格式化-[vim-clang-format](https://github.com/rhysd/vim-clang-format)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'rhysd/vim-clang-format'

" -------- 下面是该插件的一些参数 --------

" 将 :ClangFormat 映射到快捷键 [Option] + l，即「¬」
noremap ¬ :ClangFormat<cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* **`:ClangFormat`：会使用工程目录下的`.clang-format`或者用户目录下的`~/.clang-format`来对代码进行格式化**

## 2.22 个人完整配置

**初学`vim`，水平有限，仅供参考，`~/.vimrc`完整配置如下**

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
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'scrooloose/nerdtree'

" 配置 F2 打开文件管理器 
nmap <F2> :NERDTreeToggle<CR>
" 配置 F3 定位当前文件
nmap <F3> :NERDTreeFind<CR>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'octol/vim-cpp-enhanced-highlight'

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'luochen1990/rainbow'

let g:rainbow_active = 1

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'ludovicchabant/vim-gutentags'

" gutentags 搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归
let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']

" 所生成的数据文件的名称
let g:gutentags_ctags_tagfile = '.tags'

" 同时开启 ctags 和 gtags 支持：
let g:gutentags_modules = []
if executable('ctags')
	let g:gutentags_modules += ['ctags']
endif
if executable('gtags-cscope') && executable('gtags')
	let g:gutentags_modules += ['gtags_cscope']
endif

" 将自动生成的 ctags/gtags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 配置 ctags 的参数，老的 Exuberant-ctags 不能有 --extras=+q，注意
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" 如果使用 universal ctags 需要增加下面一行，老的 Exuberant-ctags 不能加下一行
let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/gutentags_plus'

" 在查询后，光标切换到 Quickfix 窗口
let g:gutentags_plus_switch = 1

" 禁用默认的映射，默认的映射会与 nerdcommenter 插件冲突
let g:gutentags_plus_nomap = 1

" 定义新的映射
noremap <silent> <leader>gs :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>gg :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>gc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>gt :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>ge :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>gf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>gi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>gd :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>ga :GscopeFind a <C-R><C-W><cr>
noremap <silent> <leader>gz :GscopeFind z <C-R><C-W><cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/vim-preview'

autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_serverCommands = {}
let g:LanguageClient_serverCommands.c = ['ccls']
let g:LanguageClient_serverCommands.cpp = ['ccls']

noremap <leader>rd :call LanguageClient#textDocument_definition()<cr>
noremap <leader>rr :call LanguageClient#textDocument_references()<cr>
noremap <leader>rv :call LanguageClient#textDocument_hover()<cr>
noremap <leader>rn :call LanguageClient#textDocument_rename()<cr>
noremap <leader>hb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<cr>
noremap <leader>hd :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true})<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'ycm-core/YouCompleteMe'

let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
let g:ycm_confirm_extra_conf = 0

let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone

noremap <c-z> <NOP>

let g:ycm_semantic_triggers =  {
           \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
           \ 'cs,lua,javascript': ['re!\w{2}'],
           \ }

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

" 设置linters，并且仅用指定的linters
" 由于在我的环境中，Available Linters中并没有gcc和g++，但是有cc（Linter Aliases）。cc包含clang、clang++、gcc、g++
" 于是，下面两个配置会使得最终ALE生效的Linter是cc
let g:ale_linters_explicit = 1
let g:ale_linters = {
  \   'c': ['gcc'],
  \   'cpp': ['g++'],
  \}

" 上面的配置使得linter是cc，cc是个alias，包含了clang、clang++、gcc、g++，且默认会用clang和clang++
" 这边我改成gcc、g++
let g:ale_c_cc_executable = 'gcc'
let g:ale_cpp_cc_executable = 'g++'
" -std=c17 和 -std=c++17 会有很多奇怪的问题，因此改用 gnu17 和 gnu++17
let g:ale_c_cc_options = '-std=gnu17 -Wall'
let g:ale_cpp_cc_options = '-std=gnu++17 -Wall'

let g:ale_completion_delay = 500
let g:ale_echo_delay = 20
let g:ale_lint_delay = 500
let g:ale_echo_msg_format = '[%linter%] %code: %%s'
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_insert_leave = 1
let g:airline#extensions#ale#enabled = 1

" 配置快捷键用于在warnings/errors之间跳转
" [Ctrl] + j: 下一个warning/error
" [Ctrl] + k: 上一个warning/error
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

" 其中 kana/vim-textobj-user 提供了自定义文本对象的基础能力，其他插件是基于该插件的扩展
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-syntax'
Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
Plug 'sgur/vim-textobj-parameter'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" 将文件模糊搜索映射到快捷键 [Ctrl] + p
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
" 将 :LeaderfMru 映射到快捷键 [Ctrl] + n
noremap <c-n> :LeaderfMru<cr>
" 将 :LeaderfFunction! 映射到快捷键 [Option] + p，即「π」
noremap π :LeaderfFunction!<cr>
let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }

let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
let g:Lf_WorkingDirectoryMode = 'Ac'
let g:Lf_WindowHeight = 0.30
let g:Lf_CacheDirectory = expand('~/.vim/cache')
let g:Lf_ShowRelativePath = 0
let g:Lf_HideHelp = 1
let g:Lf_StlColorscheme = 'powerline'
let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 将 :Rg 映射到快捷键 [Ctrl] + a
noremap <c-a> :Rg<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'mhinz/vim-grepper'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'tpope/vim-fugitive'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'preservim/nerdcommenter'

let g:NERDCreateDefaultMappings = 1
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDDefaultAlign = 'left'
let g:NERDAltDelims_java = 1
" let g:NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' }
let g:NERDCommentEmptyLines = 1
let g:NERDTrimTrailingWhitespace = 1
let g:NERDToggleCheckAllLines = 1

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'rhysd/vim-clang-format'

" 将 :ClangFormat 映射到快捷键 [Option] + l，即「¬」
noremap ¬ :ClangFormat<cr>

call plug#end()

" ctags的配置
" 将 :tn 和 :tp 分别映射到 [Option] + j 和 [Option] + k，即「∆」和「˚」
noremap ∆ :tn<cr>
noremap ˚ :tp<cr>
" tags搜索模式
set tags=./.tags;,.tags
" 系统库的ctags
set tags+=~/.vim/systags

" gtags的配置
" 设置后会出现「gutentags: gtags-cscope job failed, returned: 1」，所以我把它注释了
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif

" 搜索和替换的快捷键配置
" 搜索和替换分别映射到 [Option] + f 和 [Option] + r，即「ƒ」和「®」
" 其中，<c-r><c-w> 表示 [Ctrl] + r 以及 [Ctrl] + w，用于将光标所在的单词填入搜索/替换项中
noremap ƒ :/<c-r><c-w>
noremap ® :%s/<c-r><c-w>

" 退格失效的配置
set backspace=indent,eol,start

" 折叠，默认不启用
set nofoldenable
set foldmethod=indent
set foldlevel=0

" 回车时，默认取消搜索高亮
nnoremap <CR> :nohlsearch<CR><CR>

" 其他配置
set number
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" 设置头文件搜索路径，可以在项目的 .workspace.vim 文件中通过 set path+= 追加搜索路径
set path=.,/usr/include,/usr/local/include,/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include,/usr/local/include/c++/10.3.0

" 加载项目定制化配置
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
```

# 3 参考

* **[《Vim 中文版入门到精通》](https://github.com/wsdjeg/vim-galore-zh_cn)**
* **[《Vim 中文速查表》](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)**
* **[如何在 Linux 下利用 Vim 搭建 C/C++ 开发环境?](https://www.zhihu.com/question/47691414)**
* **[Vim 8 中 C/C++ 符号索引：GTags 篇](https://zhuanlan.zhihu.com/p/36279445)**
* **[Vim 8 中 C/C++ 符号索引：LSP 篇](https://zhuanlan.zhihu.com/p/37290578)**
* **[三十分钟配置一个顺滑如水的 Vim](https://zhuanlan.zhihu.com/p/102033129)**
* **[CentOS Software Repo](https://www.softwarecollections.org/en/scls/user/rhscl/)**
* [如何优雅的使用 Vim（二）：插件介绍](https://segmentfault.com/a/1190000014560645)
* [打造 vim 编辑 C/C++ 环境](https://carecraft.github.io/language-instrument/2018/06/config_vim/)
* [Vim2021：超轻量级代码补全系统](https://zhuanlan.zhihu.com/p/349271041)
* [How To Install GCC on CentOS 7](https://linuxhostsupport.com/blog/how-to-install-gcc-on-centos-7/)
* [8.x版本的gcc以及g++](https://www.softwarecollections.org/en/scls/rhscl/devtoolset-8/)
* [VIM-Plug安装插件时，频繁更新失败，或报端口443被拒绝等](https://blog.csdn.net/htx1020/article/details/114364510)
* [Cannot find color scheme 'gruvbox' #85](https://github.com/morhetz/gruvbox/issues/85)
* 《鸟哥的Linux私房菜》
* [Mac 的 Vim 中 delete 键失效的原因和解决方案](https://blog.csdn.net/jiang314/article/details/51941479)
* [解决linux下vim中文乱码的方法](https://blog.csdn.net/zhangjiarui130/article/details/69226109)
* [vim-set命令使用](https://www.jianshu.com/p/97d34b62d40d)
* [解決 ale 的 gcc 不顯示錯誤 | 把 gcc 輸出改成英文](https://aben20807.blogspot.com/2018/03/1070302-ale-gcc-gcc.html)
* [Mapping keys in Vim - Tutorial](https://vim.fandom.com/wiki/Mapping_keys_in_Vim_-_Tutorial_(Part_2))
* [centos7 安装GNU GLOBAL](http://www.cghlife.com/tool/install-gnu-global-on-centos7.html)
