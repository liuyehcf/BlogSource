---
title: vim
date: 2018-01-16 22:58:45
top: true
tags: 
- 原创
categories: 
- Editor
---

**阅读更多**

<!--more-->

# 1 基本概念

## 1.1 模式

基本上vim分为三种模式：**一般模式、编辑模式与命令模式**

一般模式与编辑模式以及命令行模式可以相互切换，但是编辑模式与命令行模式之间不可相互切换

### 1.1.1 一般模式

以vim打开一个文件就进入一般模式了（这是默认模式）

在这个模式中，你可以使用上下左右按键来移动光标，可以删除字符或删除整行，也可以复制粘贴你的文件数据

### 1.1.2 编辑模式

在一般模式中，可以进行删除，复制，粘贴等操作，但是却无法编辑文件内容。要等到你按下`i(I),o(O),a(A),r(R)`等任何一个字母后才会进入编辑模式

如果要回到一般模式，必须按下`Esc`这个按键即可退出编辑器

### 1.1.3 命令行模式

在一般模式中，输入`:`、`/`、`?`这三个钟的任何一个按钮，就可以将光标移动到最下面一行，在这个模式中，可以提供你查找数据的操作，而读取、保存、大量替换字符、离开vim、显示行号等操作则是在此模式中完成的

## 1.2 buffer

**每个打开的文件都对应一个buffer。buffer可以显示或者不显示**

## 1.3 window

**window就是我们看到的并且可以操作的那个界面。一个window可以包含一个或多个buffer，总是会显示其中一个buffer（文件或者空）。允许同时开启多个窗口**

## 1.4 tab

**tab可以包含一个或多个window。如果存在多个tab，那么会在最上方显示这些tab，就像一个现代的编辑器一样（vscode）**

## 1.5 ex命令

`ex`是`Unix`下的一个文本编辑器。`vim`就是`ex`的`visual mode`。`vim`中的`:w`、`:q!`就是来自于`ex`命令

`ex`命令远不止这些，实际上所有`:`开头的命令，也就是你在`vim`最下面看到的命令行，都属于`ex`命令。

# 2 操作手册

![vi-vim-cheat-sheet](/images/vim/vi-vim-cheat-sheet.gif)

* [图片出处](http://www.viemu.com/a_vi_vim_graphical_cheat_sheet_tutorial.html)

## 2.1 编辑模式

* **`i,I`：进入插入模式，i为从光标所在处插入，I为在目前所在行的第一个非空格处开始插入**
* **`a,A`：进入插入模式，a为从目前光标所在的下一个字符处开始插入，A为从光标所在行的最后一个字符处开始插入**
* **`o,O`：进入插入模式，o为在目前光标所在的下一行处插入新的一行，O为在目前光标所在处的上一行插入新的一行**
* **`s,S`：进入插入模式，s为删除目前光标所在的字符，S为删除目前光标所在的行**
* **`r,R`：进入替换模式，r只会替换光标所在的那一个字符一次，R会一直替换光标所在行的文字，直到按下Esc**
* **`Esc`：退回一般模式**
* **`[Ctrl] + [`：退回一般模式**
* **`[Ctrl] + w`：向前删除单词**
* **`[Ctrl] + r + [reg]`：插入寄存器中的内容，例如**
    * `[Ctrl] + r + 0`：插入`0`号寄存器的内容
    * `[Ctrl] + r + "`：插入默认寄存器的内容
* **`[Ctrl] + r + =`：插入表达式计算结果，等号后面跟表达式**
* **`[Ctrl] + r + /`：插入上一次搜索的关键字**
* **`[Ctrl] + o + [cmd]`：临时退出插入模式，执行单条命令又返回插入模式**
    * `[Ctrl] + o + 0`：光标移动到行首，等效于一般模式下的`0`
* **`[Ctrl] + d/t/f`：光标所在的整行减少/增加缩进/自动调整缩进**
* **`[Shift] + [Left]`：向左移动一个单词**
* **`[Shift] + [Right]`：向右移动一个单词**
* **`[Shift] + [Up]`：向上翻页**
* **`[Shift] + [Down]`：向下翻页**

## 2.2 光标移动

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
* **`f<x>`/`[n]f<x>`：向后，跳转到第1个/第n个为`x`的字符**
* **`F<x>`/`[n]F<x>`：向前，跳转到第1个/第n个为`x`的字符**
* **`t<x>`/`[n]t<x>`：向后，跳转到第1个/第n个为`x`的字符前**
* **`T<x>`/`[n]T<x>`：向前，跳转到第1个/第n个为`x`的字符前**
    * **`;`：跳到下一个`f/F/t/T`匹配的位置**
    * **`,`：跳到上一个`f/F/t/T`匹配的位置**
* **`G`：移动到这个文件的最后一行**
* `[n]G`：n为数字，移动到这个文件的第n行
* **`gg`：移动到这个文件的第一行，相当于1G**
* **`[n][Enter]`：光标向下移动n行**
* **`gm`：移动到行中**
* **`gj`：光标下移一行（忽略自动换行）**
* **`gk`：光标上移一行（忽略自动换行）**
* **`%`：跳转到`{} () []`的匹配**
    * 可以通过`:set matchpairs+=<:>`增加对尖括号`<>`的识别。可能会误识别，因为文本中可能包含单个`>`或`<`
* **`=`：按照类型自动调整缩进**
    * `gg=G`

## 2.3 文本编辑

* **`x,X`：在一行字当中，x为向后删除一个字符（相当于`[Del]`键）,X为向前删除一个字符（相当于`[Backspace]`）**
* `[n]x`：连续向后删除n个字符
* **`dd`：删除光标所在一整行**
* **`dw`：删除光标所在的字符到光标所在单词的最后一个字符**
* **`[n]dd`：删除光标所在的向下n行（包括当前这一行）**
* **`d1G`：删除光标所在到第一行的所有数据（包括当前这一行）**
* **`dG`：删除光标所在到最后一行的所有数据（包括当前这一行）**
* **`d$`：删除光标所在的字符到该行的最后一个字符（包括光标所指向的字符）**
* **`d0（这是零）`：删除从光标所在的字符到该行最前面一个字符（不包括光标所指向的字符）**
* **`d%`：删除光标所在的字符（光标所在的字符到该行的最后一个字符之间必须包含左括号，可以是`(`、`[`、`{`）到另一个右括号（与前一个左括号配对）之间的所有数据**
* **`D`：同`d$`**
* `J`：将光标所在行与下一行的数据结合成同一行
* `cc`：改写当前行（删除当前行并进入插入模式），同`S`
* `cw`：改写光标开始处的当前单词（若光标在单词中间，不会修改整个单词）
* **`ciw`：改写光标所处的单词（若光标在单词中间，也可以修改整个单词）**
* **`ci'`：改写单引号中的内容**
* **`ci"`：改写双引号中的内容**
* **`ci(`：改写小括号中的内容**
* **`ci[`：改写中括号中的内容**
* **`ci{`：改写大括号中的内容**
* **`<`：减少缩进**
* **`>`：增加缩进**
* **`u`：复原（撤销）前一个操作**
* **`[Ctrl] + r`：重做上一个操作**
* **`.`：重做上一个操作**

## 2.4 复制粘贴

* **`yy`：复制光标所在那一行**
* **`[n]yy`：复制光标所在的向下n行（包括当前这一行）**
* **`y1G`：复制光标所在行到第一行的所有数据（包括当前这一行）**
* **`yG`：复制光标所在行到最后一行的数据（包括当前这一行）**
* **`y0（这是零）`：复制光标所在那个字符到该行第一个字符的所有数据（不包括光标所指向的字符）**
* **`y$`：复制光标所在那个字符到该行最后一个字符的所有数据（包括光标所指向的字符）**
* **`p`：将已复制的数据粘贴到光标之前**
* **`P`：将已复制的数据粘贴到光标之后**

### 2.4.1 剪切板

**vim中有许多寄存器（该寄存器并不是cpu中的寄存器），或者称为剪切板，分别是：**

* `0-9`：vim用来保存最近复制、删除等操作的内容，其中0号寄存器保存的是最近一次操作的内容
* `a-zA-Z`：用户寄存器，vim不会读写这部分寄存器
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

**ssh到远程主机后，如何将本机系统剪切板的内容粘贴到远程主机的vim中？**

* 首先确认远程主机的vim是否支持`clipboard`，通过`vim --version | grep clipboard`。`-clipboard`说明不支持，`+clipboard`说明支持。`clipboard`需要在`X`环境下才能工作
* 如果系统是CentOS，需要安装图形化界面，比如`GNOME`，然后再安装`vim-X11`，然后用`vimx`代替`vim`。`vimx --version | grep clipboard`可以发现已经支持了`clipboard`。至此，已经可以在ssh终端中通过`vimx`使用远程主机的`clipboard`了
* 未完待续，目前还没搞定本机和远程的`clipboard`的共享

## 2.5 范围选择

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

## 2.6 查找替换

* **查找**
    * **`/[word]`：向下寻找一个名为word的字符串，支持正则表达式**
    * **`/\<[word]\>`：向下寻找一个名为word的字符串（全词匹配），支持正则表达式**
    * `?[word]`：向上寻找一个名为word的字符串，支持正则表达式
    * `?\<[word]\>`：向上寻找一个名为word的字符串（全词匹配），支持正则表达式
    * `n`：重复前一个查找操作
    * `N`："反向"进行前一个查找操作
    * **`*`：以全词匹配的模式（`\<[word]\>`）向后搜索关键词，用于匹配的关键词的获取规则如下：**
        * 光标下的关键词
        * 当前行，光标后最近的关键词
        * 光标下的非空字符串
        * 当前行，光标后最近的非空字符串
    * **`#`：同`*`，区别是向前搜索关键词**
    * **`g*`：同`*`，区别是以非全词匹配的模式**
    * **`g#`：同`#`，区别是以非全词匹配的模式**
* **替换**
    * **`:[n1],[n2]s/[word1]/[word2]/g`：在n1与n2行之间寻找word1这个字符串，并将该字符串替换为word2，支持正则表达式**
    * **`:[n1],[n2]s/\<[word1]\>/[word2]/g`：在n1与n2行之间寻找word1这个字符串（全词匹配），并将该字符串替换为word2，支持正则表达式**
    * **`:1,$s/[word1]/[word2]/g`或者`:%s/[word1]/[word2]/g`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，支持正则表达式**
    * **`:1,$s/[word1]/[word2]/gc`或者`:%s/[word1]/[word2]/gc`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，且在替换前显示提示字符给用户确认是否替换，支持正则表达式**
* **`[Ctrl]+r`以及`[Ctrl]+w`：将光标下的字符串添加到搜索或者替换表达式中**

## 2.7 文件操作

* **`:w`：保存文件**
* **`:wa`：保存所有文件**
* **`:w!`：若文件属性为只读时，强制写入该文件，不过到底能不能写入，还是跟你对该文件的文件属性权限有关**
* **`:q`：离开**
* **`:q!`：若曾修改过文件，又不想存储，使用"!"为强制离开不保存的意思**
* **`:wq`：保存后离开,若为:wq!则代表强制保存并离开**
* **`:e [filename]`：打开文件并编辑**
* **`:e`：重新载入当前文件**
* `ZZ`：若文件没有变更，则不保存离开，若文件已经变更过，保存后离开
* `:w [filename]`：将编辑文件保存称为另一个文件,注意w和文件名中间有空格
* `:r [filename]`：在编辑的数据中，读入另一个文件的数据，即将filename这个文件的内容加到光标所在行后面，注意r和文件名之间有空格
* `:[n1],[n2]w [filename]`：将`n1`到`n2`的内容保存成`filename`这个文件，注意w和文件名中间有空格，`[n2]`与`w`之间可以没有空格
* `vim [filename1] [filename2]...`：同时编辑多个文件
* `:n`：编辑下一个文件
* `:N`：编辑上一个文件
* `:files`：列出这个vim打开的所有文件
* **`:Vex`：打开目录**

## 2.8 文件跳转

* **`[Ctrl] + ]`：跳转到光标指向的符号的定义处**
* **`[Ctrl] + o`：回到上一次编辑处**
* **`[Ctrl] + i`：回到下一次编辑处**
* **`gf`：跳转光标指向的头文件**
    * 通过`set path=`或`set path+=`设置或增加头文件搜索路径
    * 通过`set path?`可以查看该变量的内容
* **`[Ctrl] + ^`：在前后两个文件之间跳转**

## 2.9 文本对象

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

## 2.10 代码折叠

**按照折叠所依据的规则，可以分为如下4种：**

1. **`manual`：手工折叠**
    * **`:set foldmethod=manual`**
    * **`zf`：需要配合范围选择，创建折叠**
    * **`zf`还可以与文本对象配合，例如**
        * `zfi{`：折叠大括号之间的内容，不包括大括号所在行
        * `zfa{`：折叠大括号之间的内容，包括大括号所在行
    * **`zd/zD`：删除当前折叠**
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

## 2.11 buffer

* **`:buffers`：列出所有buffer**
* **`:buffer [n]`：显示指定buffer**
* **`:bnext`：显示下一个buffer**
* **`:bprev`：显示上一个buffer**
* **`:edit [filename]`：将一个文件放入一个新的buffer中**
* **`:bdelete [n]`：删除指定buffer（不指定时，表示当前buffer）**
* **`:%bdelete`：删除所有buffer**
    * **`:%bdelete|e#`：删除除了当前buffer之外的所有buffer。其中`:e#`表示重新打开最后一个关闭的buffer**
* **`:bufdo <cmd>`：对所有buffer执行操作**
    * **`:bufdo e`：重新载入所有buffer对应的文件**

## 2.12 window

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
1. **`[Ctrl] + w + l`：把光标移动到右边的屏中**
1. **`[Ctrl] + w + h`：把光标移动到左边的屏中**
1. **`[Ctrl] + w + k`：把光标移动到上边的屏中**
1. **`[Ctrl] + w + j`：把光标移动到下边的屏中**
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

## 2.13 tab

* **`:tabnew [filename]`：在一个新的tab中打开文件**
* **`:tabm [n]`：将当前标签页移动到位置`n`（`n`从0开始），若不指定`n`，则移动到最后**
* **`gt`/`:tabnext`：下一个tab**
* **`gT`/`:tabprev`：上一个tab**
* **`:tab sball`：将所有buffer**
* **`:tabdo <cmd>`：对所有tab执行操作**
    * **`:tabdo e`：重新载入所有tab对应的文件**

## 2.14 quickfix

* `:copen`：打开`quickfix`窗口（查看编译，grep等信息）
* `:copen 10`：打开`quickfix`窗口，并且设置高度为`10`
* `:cclose`：关闭`quickfix`窗口
* `:cfirst`：跳到`quickfix`中第一个错误信息
* `:clast`：跳到`quickfix`中最后一条错误信息
* `:cc [nr]`：查看错误`[nr]`
* `:cnext`：跳到`quickfix`中下一个错误信息
* `:cprev`：跳到`quickfix`中上一个错误信息
* `:set modifiable`，将`quickfix`改成可写，可以用`dd`等删除某个条目

## 2.15 键位映射

1. **`map`：递归映射**
1. **`noremap`：非递归映射**
1. **`unmap`：将指定按键重置成默认行为**
1. `mapclear`：消所有`map`配置，慎用

| COMMANDS | MODES |
|:--|:--|
| `map`、`noremap`、`unmap` | Normal, Visual, Select, Operator-pending |
| `nmap`、`nnoremap`、`nunmap` | Normal |
| `vmap`、`vnoremap`、`vunmap` | Visual and Select |
| `smap`、`snoremap`、`sunmap` | Select |
| `xmap`、`xnoremap`、`xunmap` | Visual |
| `omap`、`onoremap`、`ounmap` | Operator-pending |
| `map!`、`noremap!`、`unmap!` | Insert and Command-line |
| `imap`、`inoremap`、`iunmap` | Insert |
| `lmap`、`lnoremap`、`lunmap` | Insert, Command-line, Lang-Arg |
| `cmap`、`cnoremap`、`cunmap` | Command-line |
| `tmap`、`tnoremap`、`tunmap` | Terminal-Job |

**查看所有`map`：**

* `:map`
* `:noremap`
* `:nnoremap`

**重定向所有`map`到文件中：**

1. `:redir! > vim_keys.txt`
1. `:silent verbose map`
1. `:redir END`

## 2.16 键位表示

* **`<F-num>`：例如`<F1>`、`<F2>`**
* **`<c-key>`：表示`[Ctrl]`加另一个字母**
* **`<a-key>/<m-key>`：表示`[Alt]`加另一个字母**
* **对于mac上的`[Option]`，并没有`<p-key>`这样的表示方法。而是用`[Option]`加另一个字母实际输出的结果作为映射键值，例如：**
    * `[Option] + a`：`å`

## 2.17 配置

* **`:set <config>?`：可以查看`<config>`的值**
    * `:set filetype?`：查看文件类型

### 2.17.1 常用配置项

```vim
:set nocompatible                   " 设置不兼容原始 vi 模式（必须设置在最开头）
:set backspace=indent,eol,start     " 设置BS键模式
:set softtabstop=4                  " 表示在编辑模式下按退格键时候退回缩进的宽度，建议设置为4
:set shiftwidth=4                   " 表示缩进的宽度，一般设置成和softtabstop一样
:set autoindent                     " 表示自动缩进
:set tabstop=4                      " 表示一个Tab键的宽度，默认是8，建议设置为4
:set expandtab                      " 表示缩进用空格来表示
:set noexpandtab                    " 表示缩进用制表符来表示
:set winaltkeys=no                  " 设置 GVim 下正常捕获 ALT 键
:set nowrap                         " 关闭自动换行
:set ttimeout                       " 允许终端按键检测超时（终端下功能键为一串ESC开头的扫描码）
:set ttm=100                        " 设置终端按键检测超时为100毫秒
:set term=?                         " 设置终端类型，比如常见的 xterm
:set ignorecase                     " 设置搜索忽略大小写（可缩写为 :set ic）
:set noignorecase                   " 设置搜索不忽略大小写（可缩写为 :set noic）
:set smartcase                      " 智能大小写，默认忽略大小写，除非搜索内容里包含大写字母
:set list                           " 设置显示制表符和换行符
:set number                         " 设置显示行号，禁止显示行号可以用 :set nonumber
:set relativenumber                 " 设置显示相对行号（其他行与当前行的距离）
:set paste                          " 进入粘贴模式（粘贴时禁用缩进等影响格式的东西）
:set nopaste                        " 结束粘贴模式
:set spell                          " 允许拼写检查
:set hlsearch                       " 设置高亮查找
:set nohlsearch                     " 结束高亮
:set ruler                          " 总是显示光标位置
:set incsearch                      " 查找输入时动态增量显示查找结果
:set insertmode                     " vim 始终处于插入模式下，使用 [Ctrl] + o 临时执行命令
:set all                            " 列出所有选项设置情况
:set cursorcolumn                   " 高亮当前列
:set cursorline                     " 高亮当前行
:set fileencoding                   " 查看当前文件的编码格式
:set showtabline=0/1/2              " 0：不显示标签页；1：默认值，只有在新建新的tab时才显式标签页；2：总是显式标签页
:syntax on                          " 允许语法高亮
:syntax off                         " 禁止语法高亮
```

### 2.17.2 配置文件

vim会主动将你曾经做过的行为记录下来，好让你下次可以轻松作业，记录操作的文件就是`~/.viminfo`

整体vim的设置值一般放置在`/etc/vimrc`这个文件中，不过不建议修改它，但是可以修改`~/.vimrc`这个文件（默认不存在，手动创建）

**在运行vim的时候，如果修改了`~/.vimrc`文件的内容，可以通过执行`:source ~/.vimrc`来重新加载`~/.vimrc`，立即生效配置**

## 2.18 其他

* **`echo`**
    * **`:echo <variable>`：可以查看`<variable>`的值**
    * **`:echom xxx`：信息会保留在message中，可以通过`:message`查看**
* **命令历史**
    * **`q:`：进入命令历史编辑**
    * **`q/`：进入搜索历史编辑**
    * **`q[a-z`]：q后接任意字母，进入命令记录**
    * 可以像编辑缓冲区一样编辑某个命令，然后回车执行
    * 可以用`[Ctrl] + c`退出历史编辑回到编辑缓冲区，但此时历史编辑窗口不关闭，可以参照之前的命令再自己输入
    * **输入`:x`关闭历史编辑并放弃编辑结果回到编辑缓冲区**
    * 可以在空命令上回车相当于退出历史编辑区回到编辑缓冲区
* **`q`：出现「记录中」或者「recording」字样时，按`q`可以取消**
* **`[Ctrl] + g`：统计信息**
* **`g + [Ctrl] + g`：字节统计信息**

### 2.18.1 多行更新

**示例：多行同时插入相同内容**

1. 在需要插入内容的列的位置，按`[Ctrl] + v`，选择需要同时修改的行
1. 按`I`进入编辑模式
1. 编写需要插入的文本
1. 按两下`ecs`

**示例：多行同时删除相同的内容**

1. 在需要插入内容的列的位置，按`[Ctrl] + v`，选择需要同时修改的行
1. 选中需要同时修改的列
1. 按`d`即可同时删除

### 2.18.2 中文乱码

**编辑`/etc/vimrc`，追加如下内容**

```sh
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

### 2.18.3 为每个项目配置vim

同一份`~./vimrc`无法适用于所有的项目，不同的项目可能需要一些特化的配置项，可以采用如下的设置方式

```vim
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
```

# 3 vim插件管理

**目前，使用最广泛的插件管理工具是：[vim-plug](https://github.com/junegunn/vim-plug)**

## 3.1 常用插件概览

| 插件名称 | 用途 | 官网地址 |
|:--|:--|:--|
| `gruvbox` | 配色方案 | https://github.com/morhetz/gruvbox |
| `vim-airline` | 状态栏 | https://github.com/vim-airline/vim-airline |
| `indentLine` | 缩进标线 | https://github.com/Yggdroot/indentLine |
| `nerdtree` | 文件管理器 | https://github.com/preservim/nerdtree |
| `vim-cpp-enhanced-highlight` | 语法高亮 | https://github.com/octol/vim-cpp-enhanced-highlight |
| `rainbow_parentheses` | 彩虹括号1 | https://github.com/kien/rainbow_parentheses.vim |
| `rainbow` | 彩虹括号2 | https://github.com/luochen1990/rainbow |
| `ctags` | 符号索引 | https://ctags.io/ |
| `vim-gutentags` | 自动索引 | https://github.com/ludovicchabant/vim-gutentags |
| `LanguageClient-neovim` | `LSP-Client` | https://github.com/autozimu/LanguageClient-neovim |
| `coc.nvim` | `LCP-Client` | https://github.com/neoclide/coc.nvim |
| `coc-explorer` | `coc`插件，文件管理器 | https://github.com/weirongxu/coc-explorer |
| `coc-java` | `coc`插件，`LSP Client For Java` | https://github.com/neoclide/coc-java |
| `coc-snippets` | `coc`插件，代码片段 | https://github.com/neoclide/coc-snippets |
| `vim-snippets` | 提供了大量`snippet`的定义 | https://github.com/honza/vim-snippets |
| `vim-auto-popmenu` | 轻量补全 | https://github.com/skywind3000/vim-auto-popmenu |
| `YouCompleteMe` | 代码补全 | https://github.com/ycm-core/YouCompleteMe |
| `vim-javacomplete2` | `Java`代码补全 | https://github.com/artur-shaik/vim-javacomplete2 |
| `vimspector` | `Debug` | https://github.com/puremourning/vimspector |
| `AsyncRun` | 编译运行 | https://github.com/skywind3000/asyncrun.vim |
| `ALE` | 动态检查 | https://github.com/dense-analysis/ale |
| `vim-signify` | 修改比较 | https://github.com/mhinz/vim-signify |
| `textobj-user` | 文本对象 | https://github.com/kana/vim-textobj-user |
| `LeaderF` | 函数列表 | https://github.com/Yggdroot/LeaderF |
| `fzf.vim` | 全局模糊搜索 | https://github.com/junegunn/fzf.vim |
| `mhinz/vim-grepper` | 全局搜索 | https://github.com/mhinz/vim-grepper |
| `tpope/vim-fugitive` | `git`扩展 | https://github.com/tpope/vim-fugitive |
| `echodoc` | 参数提示 | https://github.com/Shougo/echodoc.vim |
| `nerdcommenter` | 添加注释 | https://github.com/preservim/nerdcommenter |
| `vim-codefmt` | 代码格式化 | https://github.com/google/vim-codefmt |
| `vim-autoformat` | 代码格式化 | https://github.com/vim-autoformat/vim-autoformat |
| `vim-clang-format` | 代码格式化（仅限clang-format） | https://github.com/rhysd/vim-clang-format |
| `vim-surround` | 文本环绕 | https://github.com/tpope/vim-surround |

## 3.2 环境准备

**为什么需要准备环境，vim的插件管理不是会为我们安装插件么？因为某些复杂插件，比如`ycm`是需要手动编译的，而编译就会依赖一些编译相关的工具，并且要求的版本比较高**

**由于我用的系统是`CentOS 7.9`，通过`yum install`安装的工具都过于陈旧，包括`gcc`、`g++`、`clang`、`clang++`、`cmake`等等，这些工具都需要通过其他方式重新安装**

### 3.2.1 安装gcc

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

### 3.2.2 安装python3

```
yum install -y python3
yum install -y python3-devel.x86_64
```

### 3.2.3 安装cmake

**[cmake官网](https://cmake.org/download/)有二进制包可以下载，下载安装即可**

```sh
# 下载二进制包
wget https://github.com/Kitware/CMake/releases/download/v3.21.2/cmake-3.21.2-linux-x86_64.tar.gz
# 解压到/usr/local/lib目录下
tar -zxvf cmake-3.21.2-linux-x86_64.tar.gz -C /usr/local/lib
# 创建软连接
ln -s /usr/local/lib/cmake-3.21.2-linux-x86_64/bin/cmake /usr/local/bin/cmake
```

### 3.2.4 安装llvm

**根据[官网安装说明](https://clang.llvm.org/get_started.html)进行安装，其代码托管在[github-llvm-project](https://github.com/llvm/llvm-project)**

* [Extra Clang Tools](https://clang.llvm.org/extra/)子项目包括如下工具：
    * `clang-tidy`
    * `clang-include-fixer`
    * `clang-rename`
    * `clangd`
    * `clang-doc`

```sh
# 编译过程会非常耗时，非常占内存，如果内存不足的话请分配足够的swap内存
# 我的编译环境是虚拟机，4c8G，swap分配了25G。编译时，最多使用了4G（主存） + 25G（swap）的内存
# 建议准备150G的磁盘空间，以及30G的swap空间
dd if=/dev/zero of=swapfile bs=1M count=30720 status=progress oflag=sync
mkswap swapfile
chmod 600 swapfile
swapon swapfile

git clone -b release/13.x https://github.com.cnpmjs.org/llvm/llvm-project.git --depth 1
cd llvm-project
mkdir build
cd build
# DLLVM_ENABLE_PROJECTS: 选择 clang 以及 clang-tools-extra 这两个子项目
# DCMAKE_BUILD_TYPE: 构建类型指定为MinSizeRel。可选值有 Debug, Release, RelWithDebInfo, and MinSizeRel。其中 Debug 是默认值
cmake -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
-DCMAKE_BUILD_TYPE=MinSizeRel \
-G "Unix Makefiles" ../llvm
make -j 4
make install
```

### 3.2.5 centos安装vim8

上述很多插件对vim的版本有要求，至少是`vim8`，而一般通过`yum install`安装的vim版本是`7.x`

```sh
# 卸载
yum remove vim-* -y

# 通过非官方源fedora安装最新版的vim
curl -L https://copr.fedorainfracloud.org/coprs/lantw44/vim-latest/repo/epel-7/lantw44-vim-latest-epel-7.repo -o /etc/yum.repos.d/lantw44-vim-latest-epel-7.repo
yum install -y vim

# 确认
vim --version | head -1
```

### 3.2.6 符号索引-[ctags](https://ctags.io/)

**`ctags`的全称是`universal-ctags`**

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

**`ctags`参数：**

* `--c++-kinds=+px`：`ctags`记录c++文件中的函数声明，各种外部和前向声明
* `--fields=+ailnSz`：`ctags`要求描述的信息，其中：
    * `a`：如果元素是类成员的话，要标明其调用权限(即public或者private)
    * `i`：如果有继承，则标明父类
    * `l`：标明标记源文件的语言
    * `n`：标明行号
    * `S`：标明函数的签名（即函数原型或者参数列表）
    * `z`：标明`kind`
* `--extras=+q`：强制要求ctags做如下操作，如果某个语法元素是类的一个成员，ctags默认会给其记录一行，以要求ctags对同一个语法元素再记一行，这样可以保证在VIM中多个同名函数可以通过路径不同来区分
* `-R`：`ctags`递归生成子目录的tags（在项目的根目录下很有意义）  

**在工程中生成`ctags`：**

```sh
# 与上面的~/.vimrc中的配置对应，需要将tag文件名指定为.tags
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f .tags *
```

**如何为`C/C++`标准库生成`ctags`，这里生成的标准库对应的`ctags`文件是`~/.vim/.cfamily_systags`**

```sh
mkdir -p ~/.vim
# 下面2种选一个即可

# 1. 通过yum install -y gcc安装的gcc是4.8.5版本
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f ~/.vim/.cfamily_systags \
/usr/include \
/usr/local/include \
/usr/lib/gcc/x86_64-redhat-linux/4.8.5/include/ \
/usr/include/c++/4.8.5/

# 2. 通过上面编译安装的gcc是10.3.0版本
ctags --c++-kinds=+px --fields=+ailnSz --extras=+q -R -f ~/.vim/.cfamily_systags \
/usr/include \
/usr/local/include \
/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include \
/usr/local/include/c++/10.3.0
```

**如何为`Python`标准库生成`ctags`，这里生成的标准库对应的`ctags`文件是`~/.vim/.python_systags`（[ctags, vim and python code](https://stackoverflow.com/questions/47948545/ctags-vim-and-python-code)）**

```sh
ctags --languages=python --python-kinds=-iv --fields=+ailnSz --extras=+q -R -f ~/.vim/.python_systags /usr/lib64/python3.6
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
* **`.tags`是指在vim的当前目录（在vim中执行`:pwd`）下查找`.tags`文件**

```vim
" 将 :tn 和 :tp 分别映射到 [Option] + j 和 [Option] + k，即「∆」和「˚」
nnoremap ∆ :tn<cr>
nnoremap ˚ :tp<cr>
" tags搜索模式
set tags=./.tags;,.tags
" c/c++ 标准库的ctags
autocmd FileType c,cpp,objc set tags+=~/.vim/.cfamily_systags
" python 标准库的ctags
autocmd FileType python set tags+=~/.vim/.python_systags
```

### 3.2.7 符号索引-[cscope](http://cscope.sourceforge.net/)

**相比于`ctags`，`cscope`支持更多功能，包括查找定义、查找引用等等。但是该项目最近一次更新是2012年，因此不推荐使用。推荐使用`gtags`**

**如何安装：**

```sh
wget -O cscope-15.9.tar.gz 'https://sourceforge.net/projects/cscope/files/latest/download' --no-check-certificate
tar -zxvf cscope-15.9.tar.gz
cd cscope-15.9

./configure
make
sudo make install
```

**如何使用命令行工具：**

```sh
# 创建索引，该命令会在当前目录生成一个名为cscope.out索引文件
# -R: 在生成索引文件时，搜索子目录树中的代码
# -b: 只生成索引文件，不进入cscope的界面
# -k: 在生成索引文件时，不搜索/usr/include目录
# -q: 生成cscope.in.out和cscope.po.out文件，加快cscope的索引速度
# -i: 指定namefile
# -f: 可以指定索引文件的路径
cscope -Rbkq

# 查找符号，执行下面的命令可以进入一个交互式的查询界面
cscope
```

**如何在vim中使用**

```vim
" 添加数据库
:cscope add cscope.out

" 查找定义
:cscope find g <symbol>

" 查找引用
:cscope find s <symbol>

" 启用 quickfix
" +: 将结果追加到 quickfix 中
" -: 清除 quickfix 中的内容，并将结果添加到 quickfix 中
:set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" 其他配置方式以及使用方式参考help
:help cscope
```

**配置快捷键（`~/.vimrc`）：**

```vim
" 启用 quickfix
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" 最后面的 :copen<cr> 表示打开 quickfix
nnoremap <leader>sd :cscope find g <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sr :cscope find s <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sa :cscope find a <c-r><c-w><cr>:copen<cr>
nnoremap <leader>st :cscope find t <c-r><c-w><cr>:copen<cr>
nnoremap <leader>se :cscope find e <c-r><c-w><cr>:copen<cr>
nnoremap <leader>sf :cscope find f <c-r>=expand("<cfile>")<cr><cr>:copen<cr>
nnoremap <leader>si :cscope find i <c-r>=expand("<cfile>")<cr><cr>:copen<cr>
```

**注意事项：**

* 尽量在源码目录创建数据库，否则cscope默认会扫描所有文件，效率很低

### 3.2.8 符号索引-[gtags](https://www.gnu.org/software/global/global.html)

**`gtags`的全称是`GNU Global source code tagging system`**

**这里有个坑，上面安装的是`gcc-10.3.0`，这个版本编译安装`global`源码会报错（[dev-util/global-6.6.4 : fails to build with -fno-common or gcc-10](https://bugs.gentoo.org/706890)），错误信息大概是`global.o:(.bss+0x74): first defined here`，因此，我们需要再安装一个低版本的gcc，并且用这个低版本的gcc来编译`global`**

```sh
# 安装源
yum install -y centos-release-scl scl-utils

# 安装gcc 7
yum install -y devtoolset-7-toolchain

# 切换软件环境（本小节剩余的操作都需要在这个环境中执行，如果不小心退出来的话，可以再执行一遍重新进入该环境）
scl enable devtoolset-7 bash
```

**[gtags下载地址](https://ftp.gnu.org/pub/gnu/global/)**

```sh
# 安装相关软件
yum install -y ncurses-devel gperf bison flex libtool libtool-ltdl-devel texinfo

wget https://ftp.gnu.org/pub/gnu/global/global-6.6.7.tar.gz --no-check-certificate
tar -zxvf global-6.6.7.tar.gz
cd global-6.6.7

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

**如何使用命令行工具：**

```sh
# 把头文件也当成源文件进行解析，否则可能识别不到头文件中的符号
export GTAGSFORCECPP=1

# 在当前目录构建数据库，会在当前目录生成如下三个文件
# 1. GTAGS: 存储符号定义的数据库
# 2. GRTAGS: 存储符号引用的数据库
# 3. GPATH: 存储路径的数据库
gtags

# 查找定义
global -d <symbol>

# 查找引用
global -r <symbol>
```

**在`~/.vimrc`中增加如下配置**

1. 第一个`GTAGSLABEL`告诉`gtags`默认`C/C++/Java`等六种原生支持的代码直接使用`gtags`本地分析器，而其他语言使用`pygments`模块
1. 第二个环境变量必须设置（在我的环境里，不设置也能work），否则会找不到`native-pygments`和`language map`的定义

```vim
" native-pygments 设置后会出现「gutentags: gtags-cscope job failed, returned: 1」，所以我把它换成了 native
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSLABEL = 'native'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif
```

**`FAQ`：**

1. `global -d`找不到类定义，可能原因包括
    1. **final修饰的类，`gtags`找不到其定义，坑爹的bug，害我折腾了很久**
1. `global -d`无法查找成员变量的定义

### 3.2.9 语义索引-clangd

**`clangd`是`LSP, Language Server Protocol`的一种实现，主要用于`C/C++/Objective-C`等语言**

**安装：前面的[安装llvm](#324-%E5%AE%89%E8%A3%85llvm)小节完成后，`clangd`就已经安装好了**

### 3.2.10 语义索引-ccls

**`ccls`是`LSP, Language Server Protocol`的一种实现，主要用于`C/C++/Objective-C`等语言**

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

### 3.2.11 语义索引-jdtls

**`jdtls`是`LSP, Language Server Protocol`的一种实现，主要用于`Java`语言**

**安装：参照[github官网文档](https://github.com/eclipse/eclipse.jdt.ls)进行编译安装即可**

```sh
git clone https://github.com/eclipse/eclipse.jdt.ls.git --depth 1
cd eclipse.jdt.ls

# 要求java 11及以上的版本
JAVA_HOME=/path/to/java/11 ./mvnw clean verify
```

**安装后的配置文件以及二进制都在`./org.eclipse.jdt.ls.product/target/repository`目录中**

* 运行日志默认在config目录中，例如`./org.eclipse.jdt.ls.product/target/repository/config_linux/`目录下

### 3.2.12 安装vim-plug

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

**修改下载源：默认从`github.com`上下载，稳定性较差，可以按照如下方式修改`~/.vim/autoload/plug.vim`**

```vim
" 将
let fmt = get(g:, 'plug_url_format', 'https://git::@github.com/%s.git')
" 修改为
let fmt = get(g:, 'plug_url_format', 'https://git::@github.com.cnpmjs.org/%s.git')

" 将
\ '^https://git::@github\.com', 'https://github.com', '')
" 修改为
\ '^https://git::@github\.com\.cnpmjs\.org', 'https://github.com.cnpmjs.org', '')
```

**如何安装来自不同源的插件：**

* 方案1：指定插件的完整地址，比如`Plug 'morhetz/gruvbox'`需要改成`Plug 'https://github.com/morhetz/gruvbox'`
* 方案2：禁用`URI`校验。默认情况下，`Plug`不允许插件来自不同源，若要关闭此功能，可以按照如下方式修改`~/.vim/autoload/plug.vim`
    ```vim
    " 删掉如下代码片段
                elsif !compare_git_uri(current_uri, uri)
                    [false, ["Invalid URI: #{current_uri}",
                            "Expected:    #{uri}",
                            "PlugClean required."].join($/)]
    " 删掉如下代码片段
        elseif !s:compare_git_uri(remote, a:spec.uri)
        let err = join(['Invalid URI: '.remote,
                        \ 'Expected:    '.a:spec.uri,
                        \ 'PlugClean required.'], "\n")
    ```

## 3.3 配色方案

### 3.3.1 [gruvbox](https://github.com/morhetz/gruvbox)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'morhetz/gruvbox'

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

**将`gruvbox`中的配色方案（执行完`:PlugInstall`才有这个文件哦）移动到vim指定目录下**

```sh
# ~/.vim/colors 目录默认是不存在的
mkdir ~/.vim/colors
cp ~/.vim/plugged/gruvbox/colors/gruvbox.vim ~/.vim/colors/
```

### 3.3.2 [solarized](https://github.com/altercation/vim-colors-solarized)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'altercation/vim-colors-solarized'

" 启用solarized配色方案（~/.vim/colors目录下需要有solarized对应的.vim文件）
colorscheme solarized
" 设置背景，可选值有：dark, light
set background=dark

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**将`solarized`中的配色方案（执行完`:PlugInstall`才有这个文件哦）移动到vim指定目录下**

```sh
# ~/.vim/colors 目录默认是不存在的
mkdir ~/.vim/colors
cp ~/.vim/plugged/vim-colors-solarized/colors/solarized.vim ~/.vim/colors/
```

## 3.4 状态栏-[vim-airline](https://github.com/vim-airline/vim-airline)

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

## 3.5 缩进标线-[indentLine](https://github.com/Yggdroot/indentLine)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'Yggdroot/indentLine'

let g:indentLine_noConcealCursor = 1
let g:indentLine_color_term = 239
let g:indentLine_char = '|'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 3.6 文件管理器-[nerdtree](https://github.com/preservim/nerdtree)

**前言：`coc.nvim`插件体系提供了`coc-explore`，如果使用了`coc.nvim`插件，就不需要其他的文件管理器了**

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'scrooloose/nerdtree'

" 配置 F2 打开文件管理器 
nmap <F2> :NERDTreeToggle<cr>
" 配置 F3 定位当前文件
nmap <F3> :NERDTreeFind<cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* `:NERDTreeToggle`：打开文件管理器
* `:NERDTreeFind`：打开文件管理器，并且定位到当前文件

## 3.7 语法高亮-[vim-cpp-enhanced-highlight](https://github.com/octol/vim-cpp-enhanced-highlight)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'octol/vim-cpp-enhanced-highlight'

let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_simple_template_highlight = 1
let g:cpp_concepts_highlight = 1

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 3.8 彩虹括号-[rainbow](https://github.com/luochen1990/rainbow)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'luochen1990/rainbow'

let g:rainbow_active = 1

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 3.9 自动索引-[vim-gutentags](https://github.com/ludovicchabant/vim-gutentags)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

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

" 按文件类型分别配置 ctags 的参数
function s:set_cfamily_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
    " 配置 universal ctags 特有参数
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
function s:set_python_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--languages=python']
    let g:gutentags_ctags_extra_args += ['--python-kinds=-iv']
    " 配置 universal ctags 特有参数
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
autocmd FileType c,cpp,objc call s:set_cfamily_configs()
autocmd FileType c,cpp,objc call s:set_python_configs()

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

" 启用高级命令，比如 :GutentagsToggleTrace 等
let g:gutentags_define_advanced_commands = 1

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **`:GutentagsUpdate`：手动触发更新tags**

**问题排查步骤：**

1. `let g:gutentags_define_advanced_commands = 1`：允许`gutentags`打开一些高级命令和选项
1. 运行`:GutentagsToggleTrace`：它会将`ctags/gtags`命令的输出记录在vim的`message`记录里
1. 保存文件，触发数据库更新
1. `:message`：可以重新查看message

**常见问题：**

* `gutentags: gtags-cscope job failed, returned: 1`
    * **原因1：由于`git`仓库切换分支，可能会导致`gtagsdb`乱掉。而`gutentags`会用`gtags --incremental <gtagsdb-path>`这样的命令来更新`gtagsdb`，这样可能会导致`segment fault`，表象就是`gutentags: gtags-cscope job failed, returned: 1`**
        * **解决方式：修改`gutentags`源码，将`--incremental`参数去掉即可。一键修改命令：`sed -ri "s|'--incremental', *||g" ~/.vim/plugged/vim-gutentags/autoload/gutentags/gtags_cscope.vim`**

### 3.9.1 gtags查询快捷键-[gutentags_plus](https://github.com/skywind3000/gutentags_plus)

**没有该插件时，我们一般按照如下方式使用`gtags`**

1. **`set cscopeprg='gtags-cscope'`：让`cscope`命令指向`gtags-cscope`**
1. **`cscope add <gtags-path>/GTAGS`：添加`gtagsdb`到`cscope`中**
1. **`cscope find s <symbol>`：开始符号索引**

该插件提供一个命令`GscopeFind`，用于`gtags`查询

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/gutentags_plus'

" 在查询后，光标切换到 quickfix 窗口
let g:gutentags_plus_switch = 1

" 禁用默认的映射，默认的映射会与 nerdcommenter 插件冲突
let g:gutentags_plus_nomap = 1

" 定义新的映射
nnoremap <leader>gd :GscopeFind g <c-r><c-w><cr>
nnoremap <leader>gr :GscopeFind s <c-r><c-w><cr>
nnoremap <leader>ga :GscopeFind a <c-r><c-w><cr>
nnoremap <leader>gt :GscopeFind t <c-r><c-w><cr>
nnoremap <leader>ge :GscopeFind e <c-r><c-w><cr>
nnoremap <leader>gf :GscopeFind f <c-r>=expand("<cfile>")<cr><cr>
nnoremap <leader>gi :GscopeFind i <c-r>=expand("<cfile>")<cr><cr>

call plug#end()
```

**键位映射说明：**

| keymap | desc |
|--------|------|
| **`\gd`** | **查找光标下符号的定义** |
| **`\gr`** | **查找光标下符号的引用** |
| **`\ga`** | **查找光标下符号的赋值处** |
| `\gt` | 查找光标下的字符串 |
| `\ge` | 以`egrep pattern`查找光标下的字符串 |
| `\gf` | 查找光标下的文件名 |
| **`\gi`** | **查找引用光标下头文件的文件** |

**安装：进入vim界面后执行`:PlugInstall`即可**

### 3.9.2 quickfix预览-[vim-preview](https://github.com/skywind3000/vim-preview)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/vim-preview'

autocmd FileType qf nnoremap <buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <buffer> P :PreviewClose<cr>
" 将 :PreviewScroll +1 和 :PreviewScroll -1 分别映射到 D 和 U
autocmd FileType qf nnoremap <buffer> <c-e> :PreviewScroll +1<cr>
autocmd FileType qf nnoremap <buffer> <c-y> :PreviewScroll -1<cr>

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* **在`quickfix`中，按`p`打开预览**
* **在`quickfix`中，按`P`关闭预览**
* **`D`：预览页向下滚动半页**
* **`U`：预览页向上滚动半页**

## 3.10 LSP Client

### 3.10.1 [coc.nvim](https://github.com/neoclide/coc.nvim)

**该插件是作为`LSP Client`，可以支持多种不同的`LSP Server`**

**编辑`~/.vimrc`，添加Plug相关配置（公共配置）**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 设置默认开启或者关闭，1表示启动（默认值），0表示不启动
" let g:coc_start_at_startup=0

" 在编辑模式下，触发自动补全时，将 <tab> 映射成移动到下一个补全选项
inoremap <silent><expr> <tab>
      \ pumvisible() ? "\<c-n>" :
      \ <SID>check_back_space() ? "\<tab>" :
      \ coc#refresh()
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\c-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" 在编辑模式下，将 <cr> 配置成选中当前补全选项
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

" K 查看文档
nnoremap <silent> K :call <SID>show_documentation()<cr>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" 诊断快捷键
nmap <silent> <c-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <c-j> <Plug>(coc-diagnostic-next)

" 自动根据语义进行范围选择
nmap <silent> <c-s> <Plug>(coc-range-select)
xmap <silent> <c-s> <Plug>(coc-range-select)

" 代码导航的相关映射
nmap <leader>rd <Plug>(coc-definition)
nmap <leader>ry <Plug>(coc-type-definition)
nmap <leader>ri <Plug>(coc-implementation)
nmap <leader>rr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* **`:CocStart`：由于在上面的配置中取消了自启动，因此需要手动开启**
* **`:CocConfig`：编辑配置文件，其路径为`~/.vim/coc-settings.json`**
* **`:CocList [options] [args]`**
    * 编辑模式
        * `[Ctrl] + o`：切换到一般模式
    * 一般模式
        * `i/I/o/O/a/A`：进入编辑模式
        * `p`：开启或关闭预览窗口
        * `[Ctrl] + e`：向下滚动预览窗口中的内容
        * `[Ctrl] + y`：向上滚动预览窗口中的内容
* **`:CocCommand <插件命令>`**
    * `:CocCommand java.open.serverLog`

**相关路径：**

* `~/.config/coc/extensions`：插件目录

**配置文件`~/.vim/coc-settings.json`的内容如下：**

```json
{
    "languageserver": {
        "clangd": {
            "command": "clangd",
            "rootPatterns": ["compile_flags.txt", "compile_commands.json"],
            "filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp"]
        }
    }
}
```

#### 3.10.1.1 [coc-explorer](https://github.com/weirongxu/coc-explorer)

**`coc-explorer`提供了类似于`nerdtree`的文件管理器的功能，结构更清晰也更易用**

**安装：进入vim界面后执行`:CocInstall coc-explorer`即可**

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 省略公共配置
" 将 打开文件管理器 映射到快捷键 [Space] + e
nmap <space>e <cmd>CocCommand explorer<cr>

call plug#end()
```

**配置：`:CocConfig`，增加如下内容**

* `explorer.file.reveal.auto`：使用在文件管理器中高亮当前`buffer`的所对应的文件

```json
{
    "explorer.file.reveal.auto": true
}
```

#### 3.10.1.2 [coc-java](https://github.com/search?q=coc-java)

**`Java`语言的`LSP-Server`的实现是[jdt.ls](https://github.com/eclipse/eclipse.jdt.ls)。而`coc-java`是`coc.nvim`的扩展，对`jdt.ls`进行进一步的封装**

**安装：进入vim界面后执行`:CocInstall coc-java`即可**

* 安装路径：`~/.config/coc/extensions/node_modules/coc-java`
* 数据路径：`~/.config/coc/extensions/coc-java-data`

**配置：`:CocConfig`，增加如下内容**

```json
{
    "java.format.enable": false,
    "java.maven.downloadSources": true,
    "java.saveActions.organizeImports": false,
    "java.trace.server": "verbose"
}
```

**使用：**

* `:CocCommand workspace.showOutput java`：查看`jdt.ls`日志
    * `"java.trace.server": "verbose"`：更详细的日志

**Tips：**

* 若项目用到了`thrift`或者`protobuf`这些会创建源码的三方库。需要将这部分源码以及源码编译生成的`.class`文件打包成`.jar`文件，然后通过配置，告知`jdt.ls`
    * 通过配置`java.project.referencedLibraries`，传入额外的jar路径。该配置好像无法起作用。[Doesn't recognize imports in classpath on a simple project](https://github.com/neoclide/coc-java/issues/93)提到将`vim`换成`neovim`可以解决，其他相关的`issue`如下：
        * [java.project.referencedLibraries](https://github.com/redhat-developer/vscode-java/pull/1196#issuecomment-568192224)
        * [Add multiple folders to src path](https://github.com/microsoft/vscode-java-dependency/issues/412)
        * [Managing Java Projects in VS Code](https://code.visualstudio.com/docs/java/java-project)
        * [referencedLibraries / classpath additions not working](https://github.com/neoclide/coc-java/issues/146)
    * 通过配置`.classpath`，参考配置[eclipse.jdt.ls/org.eclipse.jdt.ls.core/.classpath](https://github.com/eclipse/eclipse.jdt.ls/blob/master/org.eclipse.jdt.ls.core/.classpath)
        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <classpath>
            <classpathentry kind="lib" path="xxx.jar" sourcepath="xxx-source"/>
        </classpath>
        ```

        * 假设子模块用到了`thrift`，那么需要在子模块的目录下放置`.classpath`，而不是在工程根目录放置`.classpath`
* 有插件`org.eclipse.m2e:lifecycle-mapping`的时候，`jdt.ls`没法正常工作，目前暂未解决

#### 3.10.1.3 [coc-snippets](https://github.com/neoclide/coc-snippets)

**`coc-snippets`用于提供片段扩展功能（类似于`IDEA`中的`sout`、`psvm`、`.var`等等）**

**安装：进入vim界面后执行`:CocInstall coc-snippets`即可**

* 安装路径：`~/.config/coc/extensions/node_modules/coc-snippets`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 省略公共配置
" 将 触发代码片段扩展 映射到快捷键 [Ctrl] + l
imap <c-l> <Plug>(coc-snippets-expand)
" 在 visual 模式下，将 跳转到下一个占位符 映射到快捷键 [Ctrl] + j
vmap <c-j> <Plug>(coc-snippets-select)
" 在编辑模式下，将 跳转到下一个/上一个占位符 分别映射到 [Ctrl] + j 和 [Ctrl] + k
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

call plug#end()
```

**使用：**

* 在编辑模式下，输入片段后，按`<c-l>`触发片段扩展
* `:CocList snippets`：查看所有可用的`snippet`

##### 3.10.1.3.1 [vim-snippets](https://github.com/honza/vim-snippets)

`vim-snippets`插件提供了一系列`snippet`的定义

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'honza/vim-snippets'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：与`coc-snippets`自带`snippet`的用法一致**

### 3.10.2 [LanguageClient-neovim](https://github.com/autozimu/LanguageClient-neovim)

**该插件是作为`LSP Client`，可以支持多种不同的`LSP Server`**

**编辑`~/.vimrc`，添加Plug相关配置（公共配置）**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" 默认关闭，对于一些大型项目来说，ccls初始化有点慢，需要用的时候再通过 :LanguageClientStart 启动即可
let g:LanguageClient_autoStart = 0
let g:LanguageClient_loadSettings = 1
let g:LanguageClient_diagnosticsEnable = 0
let g:LanguageClient_selectionUI = 'quickfix'
let g:LanguageClient_diagnosticsList = v:null
let g:LanguageClient_hoverPreview = 'Never'
let g:LanguageClient_serverCommands = {}

nnoremap <leader>rd :call LanguageClient#textDocument_definition()<cr>
nnoremap <leader>rr :call LanguageClient#textDocument_references()<cr>
nnoremap <leader>rv :call LanguageClient#textDocument_hover()<cr>
nnoremap <leader>rn :call LanguageClient#textDocument_rename()<cr>

call plug#end()
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

* **`:LanguageClientStart`：由于在上面的配置中取消了自启动，因此需要手动开启**
* **`:LanguageClientStop`：关闭**
* **`:call LanguageClient_contextMenu()`：操作菜单**

**键位映射说明：**

| keymap | desc |
|--------|------|
| **`\rd`** | **查找光标下符号的定义** |
| **`\rr`** | **查找光标下符号的引用** |
| **`\rv`** | **查看光标下符号的说明** |
| **`\rn`** | **重命名光标下的符号** |
| **`\hb`** | **查找光标下符号的父类（ccls独有）** |
| **`\hd`** | **查找光标下符号的子类（ccls独有）** |

#### 3.10.2.1 C-Family

##### 3.10.2.1.1 clangd

**这里我们选用的`LSP-Server`的实现是`clangd`（推荐）**

**编辑`~/.vimrc`，添加Plug相关配置（`clangd`的特殊配置）**

* **`clangd`。相关配置参考[LanguageClient-neovim/wiki/Clangd](https://github.com/autozimu/LanguageClient-neovim/wiki/Clangd)**
* `clangd`无法更改缓存的存储路径，默认会使用`${project}/.cache`作为缓存目录
* **`clangd`会根据`--compile-commands-dir`参数指定的路径查找`compile_commands.json`，若查找不到，则在当前目录，以及每个源文件所在目录递归向上寻找`compile_commands.json`**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 省略公共配置
let g:LanguageClient_serverCommands.c = ['clangd']
let g:LanguageClient_serverCommands.cpp = ['clangd']

call plug#end()
```

##### 3.10.2.1.2 ccls

**这里我们选用的`LSP-Server`的实现是`ccls`（不推荐，大型工程资源占用太高，且经常性卡死）**

**编辑`~/.vimrc`，添加Plug相关配置**

* **`ccls`。相关配置参考[ccls-project-setup](https://github.com/MaskRay/ccls/wiki/Project-Setup)**
* **`ccls`会在工程的根目录寻找`compile_commands.json`**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 省略公共配置
let g:LanguageClient_settingsPath = expand('~/.vim/languageclient.json')
let g:LanguageClient_serverCommands.c = ['ccls']
let g:LanguageClient_serverCommands.cpp = ['ccls']
nnoremap <leader>hb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<cr>
nnoremap <leader>hd :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true})<cr>

call plug#end()
```

**其中，`~/.vim/languageclient.json`的内容示例如下（必须是决定路径，不能用`~`）**

* `ccls`可以通过如下配置更改缓存的存储路径

```json
{
    "ccls": {
        "cache": {
            "directory": "/root/.cache/LanguageClient"
        }
    }
}
```

#### 3.10.2.2 Java

**这里我们选用的`LSP-Server`的实现是`jdtls, Eclipse JDT Language Server`**

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

" 省略公共配置
let g:LanguageClient_serverCommands.java = ['/usr/local/bin/jdtls', '-data', getcwd()]

call plug#end()
```

**创建完整路径为`/usr/local/bin/jdtls`的脚本，内容如下：**

```sh
#!/usr/bin/env sh

server={{ your server installation location }}

java \
    -Declipse.application=org.eclipse.jdt.ls.core.id1 \
    -Dosgi.bundles.defaultStartLevel=4 \
    -Declipse.product=org.eclipse.jdt.ls.core.product \
    -noverify \
    -Xms1G \
    -jar $server/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/plugins/org.eclipse.equinox.launcher_1.*.jar \
    -configuration $server/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target/repository/config_linux/ \
    --add-modules=ALL-SYSTEM \
    --add-opens java.base/java.util=ALL-UNNAMED \
    --add-opens java.base/java.lang=ALL-UNNAMED \
    "$@"
```

**问题：**

* 无法访问JDK以及三方库中的类
* 对于Maven项目，若在标准的目录结构中有额外的目录，例如`<project-name>/src/main/<extra_dir>/com`，那么`jdt.ls`无法自动扫描整个工程，除非手动打开文件，才会把该文件加入解析列表中

## 3.11 代码补全

**前言：`coc.nvim`插件体系提供了大部分语言的代码补全功能，如果使用了`coc.nvim`插件，就不需要使用下面的这些补全插件了**

### 3.11.1 [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)

**这个插件比较复杂，建议手工安装**

```sh
# 定义一个函数，用于调整github的地址，加速下载过程，该函数会用到多次
function setup_github_repo() {
    gitmodules=( $(find . -name '.gitmodules' -type f) )
    for gitmodule in ${gitmodules[@]}
    do
        echo "setup github repo for '${gitmodule}'"
        sed -i 's|//github.com/|//github.com.cnpmjs.org/|g' ${gitmodule}
    done

    git submodule sync --recursive
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

" ycm全局的配置文件，当没有 compile_commands.json 文件时，这个配置会起作用
let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'
" 禁止ycm在每次打开文件时都询问是否要使用全局的配置
let g:ycm_confirm_extra_conf = 0

let g:ycm_add_preview_to_completeopt = 0
let g:ycm_show_diagnostics_ui = 0
let g:ycm_server_log_level = 'info'
let g:ycm_min_num_identifier_candidate_chars = 2
let g:ycm_collect_identifiers_from_comments_and_strings = 1
let g:ycm_complete_in_strings=1
let g:ycm_key_invoke_completion = '<c-z>'
set completeopt=menu,menuone

noremap <c-z> <nop>

let g:ycm_semantic_triggers =  {
           \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
           \ 'cs,lua,javascript': ['re!\w{2}'],
           \ }

call plug#end()
```

**`ycm`如何解析代码：**

1. **使用`compilation database`：如果当前目录下存在`compile_commands.json`， 则读取该文件，对代码进行编译解析**
1. **`.ycm_extra_conf.py`：若没有`compilation database`，那么`ycm`会在当前目录递归向上寻找并加载第一个`.ycm_extra_conf.py`文件，如果都找不到，则加载全局配置（如果配置了`g:ycm_global_ycm_extra_conf`参数的话）**

**配置`~/.ycm_extra_conf.py`，内容如下（仅针对c/c++，对大部分简单的工程均适用），仅供参考**

```python
def Settings(**kwargs):
    if kwargs['language'] == 'cfamily':
        return {
            'flags': ['-x', 'c++', '-Wall', '-Wextra', '-Werror'],
        }
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **默认情况下，只能进行通用补全，比如将文件中已经出现的字符加入到字典中，这样如果编写同样的字符串的话，就能够提示补全了**
* **如果要进行语义补全，可以结合`compile_commands.json`，通过`cmake`等构建工具生成`compile_commands.json`，并将该文件至于工程根目录下。再用vim打开工程便可进行语义补全**
* `[Ctrl] + n`：下一个条目
* `[Ctrl] + p`：上一个条目

### 3.11.2 [vim-javacomplete2](https://github.com/artur-shaik/vim-javacomplete2)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'artur-shaik/vim-javacomplete2'

" 关闭默认的配置项
let g:JavaComplete_EnableDefaultMappings = 0
" 开启代码补全
autocmd FileType java setlocal omnifunc=javacomplete#Complete
" import相关
autocmd FileType java nmap <leader>jI <Plug>(JavaComplete-Imports-AddMissing)
autocmd FileType java nmap <leader>jR <Plug>(JavaComplete-Imports-RemoveUnused)
autocmd FileType java nmap <leader>ji <Plug>(JavaComplete-Imports-AddSmart)
autocmd FileType java nmap <leader>jii <Plug>(JavaComplete-Imports-Add)
" 代码生成相关
autocmd FileType java nmap <leader>jM <Plug>(JavaComplete-Generate-AbstractMethods)
autocmd FileType java nmap <leader>jA <Plug>(JavaComplete-Generate-Accessors)
autocmd FileType java nmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
autocmd FileType java nmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
autocmd FileType java nmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
autocmd FileType java nmap <leader>jts <Plug>(JavaComplete-Generate-ToString)
autocmd FileType java nmap <leader>jeq <Plug>(JavaComplete-Generate-EqualsAndHashCode)
autocmd FileType java nmap <leader>jc <Plug>(JavaComplete-Generate-Constructor)
autocmd FileType java nmap <leader>jcc <Plug>(JavaComplete-Generate-DefaultConstructor)
autocmd FileType java vmap <leader>js <Plug>(JavaComplete-Generate-AccessorSetter)
autocmd FileType java vmap <leader>jg <Plug>(JavaComplete-Generate-AccessorGetter)
autocmd FileType java vmap <leader>ja <Plug>(JavaComplete-Generate-AccessorSetterGetter)
" 其他
autocmd FileType java nmap <silent> <buffer> <leader>jn <Plug>(JavaComplete-Generate-NewClass)
autocmd FileType java nmap <silent> <buffer> <leader>jN <Plug>(JavaComplete-Generate-ClassInFile)

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

## 3.12 编译运行-[AsyncRun](https://github.com/skywind3000/asyncrun.vim)

本质上，`AsyncRun`插件就是提供了异步执行命令的机制，我们可以利用这个机制定义一些动作，比如`编译`、`构建`、`运行`、`测试`等，提供类似于`IDE`的体验

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'skywind3000/asyncrun.vim'

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 quickfix 窗口
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

## 3.13 动态检查-[ALE](https://github.com/dense-analysis/ale)

**前言：`coc.nvim`插件体系提供了大部分语言的错误诊断功能，如果使用了`coc.nvim`插件，就不需要使用其他的错误诊断插件了**

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

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
nmap <silent> <c-k> <plug>(ale_previous_wrap)
nmap <silent> <c-j> <plug>(ale_next_wrap)

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**使用：**

* **`:ALEInfo`：查看配置信息，拉到最后有命令执行结果**
* **如何配置`C/C++`项目：不同`C/C++`项目的结构千差万别，构建工具也有很多种，因此`ALE`很难得知需要用什么编译参数来编译当前文件。因此`ALE`会尝试读取工程目录下的`compile_commands.json`文件，并以此获取编译参数**
* **指定三方库的头文件路径。每种类型的编译器对应的环境变量名是不同的，这里仅以`gcc`和g`++`为例**
    * `export C_INCLUDE_PATH=${C_INCLUDE_PATH}:<third party include path...>`
    * `export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:<third party include path...>`

**问题：**

1. **若`linter`使用的是`gcc`或者`g++`，即便有语法错误，也不会有提示信息。但是使用`:ALEInfo`查看，是可以看到报错信息的。这是因为ALE识别错误是通过一个关键词`error`，而在我的环境中，gcc编译错误输出的是中文`错误`，因此ALE不认为这是个错误。修改方式如下**
    1. `mv /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    1. `mv /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo /usr/local/share/locale/zh_CN/LC_MESSAGES/gcc.mo.bak`
    * 如果找不到`gcc.mo`文件的话，可以用`locate`命令搜索一下

## 3.14 修改比较-[vim-signify](https://github.com/mhinz/vim-signify)

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

## 3.15 文本对象-[textobj-user](https://github.com/kana/vim-textobj-user)

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

## 3.16 函数列表-[LeaderF](https://github.com/Yggdroot/LeaderF)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

" 将文件模糊搜索映射到快捷键 [Ctrl] + p
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_ShortcutB = '<m-n>'
" 将 :LeaderfMru 映射到快捷键 [Ctrl] + n
nnoremap <c-n> :LeaderfMru<cr>
" 将 :LeaderfFunction! 映射到快捷键 [Option] + p，即「π」
nnoremap π :LeaderfFunction!<cr>
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

## 3.17 全局模糊搜索-[fzf.vim](https://github.com/junegunn/fzf.vim)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" 将 :Ag 和 :Rg 分别映射到 \ag 和 \rg
nnoremap <leader>ag :Ag<cr>
nnoremap <leader>rg :Rg<cr>
" 配置快捷键[Ctrl] + a，[Ctrl] + q，将结果导入quickfix
" https://github.com/junegunn/fzf.vim/issues/185
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction
let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list') }
let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
" 排除 :Ag 和 :Rg 搜索结果中仅匹配文件名的条目
" https://github.com/junegunn/fzf.vim/issues/346
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

* 安装会额外执行`~/.vim/plugged/fzf/install`这个脚本，来下载`fzf`的二进制，如果长时间下载不下来的话，可以改成代理地址后，再手动下载

**用法（搜索相关的语法可以参考[junegunn/fzf-search-syntax](https://github.com/junegunn/fzf#search-syntax)）：**

1. `:Ag`：进行全局搜索（依赖命令行工具`ag`，安装方式参考该插件[github主页](https://github.com/ggreer/the_silver_searcher)）
    * `[Ctrl] + j/k`可以在条目中上下移动
1. `:Rg`：进行全局搜索（依赖命令行工具`rg`，安装方式参考该插件[github主页](https://github.com/BurntSushi/ripgrep)）
    * `[Ctrl] + j/k`可以在条目中上下移动
* **匹配规则**
    * **`xxx`：模糊匹配（可能被分词）**
    * **`'xxx`：非模糊匹配（不会被分词）**
    * **`^xxx`：前缀匹配**
    * **`xxx$`：后缀匹配**
    * **`!xxx`：反向匹配**
    * **上述规则均可自由组合**
    * **如何精确匹配一个包含空格的字符串：`'Hello\ world`。由于常规的空格被用作分词符，因此空格前要用`\`进行转义**

## 3.18 全局搜索-[vim-grepper](https://github.com/mhinz/vim-grepper)

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

## 3.19 git扩展-[vim-fugitive](https://github.com/tpope/vim-fugitive)

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

## 3.20 添加注释-[nerdcommenter](https://github.com/preservim/nerdcommenter)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

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

## 3.21 代码格式化-[vim-codefmt](https://github.com/google/vim-codefmt)

**支持各种格式化工具：**

* `C-Family`：`clang-format`
* `CSS`/`Sass`/`SCSS`/`Less`：`js-beautify`
* `JSON`：`js-beautify`
* `HTML`：`js-beautify`
* `Go`：`gofmt`
* `Java`：`google-java-format`/`clang-format`
* `Python`：`Autopep8`/`Black`/`YAPF`
* `Shell`：`shfmt`

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" 将 :FormatCode 映射到快捷键 [Ctrl] + l
nnoremap <c-l> :FormatCode<cr>

call plug#end()

" ......................
" 以下配置放在plug#end()之后
" ......................

call glaive#Install()
" 设置google-java-format的启动命令，其中
" /usr/local/share/google-java-format-1.14.0-all-deps.jar 是我的安装路径
" --aosp 采用aosp风格，缩进为4个空格
Glaive codefmt google_java_executable="java -jar /usr/local/share/google-java-format-1.14.0-all-deps.jar --aosp"
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* `:FormatCode`：格式化
* `:Glaive codefmt`：查看配置

**安装`Python`的格式化工具`autopep8`**

```sh
pip install --upgrade autopep8

# 创建软连接（下面是我的安装路径，改成你自己的就行）
sudo chmod a+x /home/home/liuyehcf/.local/lib/python3.6/site-packages/autopep8.py
sudo ln /home/home/liuyehcf/.local/lib/python3.6/site-packages/autopep8.py /usr/local/bin/autopep8
```

## 3.22 文本环绕-[vim-surround](https://github.com/tpope/vim-surround)

**编辑`~/.vimrc`，添加Plug相关配置**

```vim
call plug#begin()

" ......................
" .....其他插件及配置.....
" ......................

Plug 'tpope/vim-surround'

call plug#end()
```

**安装：进入vim界面后执行`:PlugInstall`即可**

**用法：**

* 完整用法参考`:help surround`
* `cs`：`cs, change surroundings`，用于替换当前文本的环绕符号
    * `cs([`
    * `cs[{`
    * `cs{<q>`
* `ds`：`ds, delete surroundings`，用于删除当前文本的环绕符号
    * `ds{`
    * `ds<`
    * `ds<q>`
* `ys`：`you surround`，用于给指定文本加上环绕符号。文本指定通常需要配合文本对象一起使用
    * `ysiw[`：`iw`是文本对象
    * `ysa"fprint`：其中`a"`是文本对象，`f`表示用函数调用的方式环绕起来，`print`是函数名。形式为`print(<text>)`
    * `ysa"Fprint`：类似`ysa"fprint`，`F`表示会在参数列表前后多加额外的空格。形式为`print( <text> )`
    * `ysa"<c-f>print`：类似`ysa"fprint`，`<c-f>`表示环绕符号加到最外侧。形式为`(print <text>)`
* `yss`：给当前行加上环绕符号（不包含`leading whitespace`和`trailing whitespace`）
    * `yss(`
    * `yssb`
    * `yss{`
    * `yssB`
* `yS`：类似`ys`，但会在选中文本的前一行和后一行加上环绕符号
    * `ySiw[`：`iw`是文本对象
* `ySS`：类似`yes`，但会在选中文本的前一行和后一行加上环绕符号
    * `ySS(`
    * `ySSb`
    * `ySS{`
    * `ySSB`
* `[visual]S`：用于给`visual mode`选中的文本加上环绕符号
    * `vllllS'`：其中，`v`表示进入`visual`模式，`llll`表示向右移动4个字符
    * `vllllSfprint`：其中，`v`表示进入`visual`模式，`llll`表示向右移动4个字符，`f`表示用函数调用的方式环绕起来，`print`是函数名。形式为`print(<text>)`
    * `vllllSFprint`：类似`vllllSfprint`，`F`表示会在参数列表前后多加额外的空格。形式为`print( <text> )`
    * `vllllS<c-f>print`：类似`vllllSfprint`，`<c-f>`表示环绕符号加到最外侧。形式为`(print <text>)`

## 3.23 个人完整配置

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

" 按文件类型分别配置 ctags 的参数
function s:set_cfamily_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
    " 配置 universal ctags 特有参数
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
function s:set_python_configs()
    let g:gutentags_ctags_extra_args = ['--fields=+ailnSz']
    let g:gutentags_ctags_extra_args += ['--languages=python']
    let g:gutentags_ctags_extra_args += ['--python-kinds=-iv']
    " 配置 universal ctags 特有参数
    let g:ctags_version = system('ctags --version')[0:8]
    if g:ctags_version == "Universal"
        let g:gutentags_ctags_extra_args += ['--extras=+q', '--output-format=e-ctags']
    endif
endfunction
autocmd FileType c,cpp,objc call s:set_cfamily_configs()
autocmd FileType c,cpp,objc call s:set_python_configs()

" 禁用 gutentags 自动加载 gtags 数据库的行为
let g:gutentags_auto_add_gtags_cscope = 0

" 启用高级命令，比如 :GutentagsToggleTrace 等
let g:gutentags_define_advanced_commands = 1

" 检测 ~/.cache/tags 不存在就新建
if !isdirectory(s:vim_tags)
   silent! call mkdir(s:vim_tags, 'p')
endif

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/gutentags_plus'

" 在查询后，光标切换到 quickfix 窗口
let g:gutentags_plus_switch = 1

" 禁用默认的映射，默认的映射会与 nerdcommenter 插件冲突
let g:gutentags_plus_nomap = 1

" 定义新的映射
nnoremap <leader>gd :GscopeFind g <c-r><c-w><cr>
nnoremap <leader>gr :GscopeFind s <c-r><c-w><cr>
nnoremap <leader>ga :GscopeFind a <c-r><c-w><cr>
nnoremap <leader>gt :GscopeFind t <c-r><c-w><cr>
nnoremap <leader>ge :GscopeFind e <c-r><c-w><cr>
nnoremap <leader>gf :GscopeFind f <c-r>=expand("<cfile>")<cr><cr>
nnoremap <leader>gi :GscopeFind i <c-r>=expand("<cfile>")<cr><cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/vim-preview'

autocmd FileType qf nnoremap <buffer> p :PreviewQuickfix<cr>
autocmd FileType qf nnoremap <buffer> P :PreviewClose<cr>
" 将 :PreviewScroll +1 和 :PreviewScroll -1 分别映射到 D 和 U
autocmd FileType qf nnoremap <buffer> <c-e> :PreviewScroll +1<cr>
autocmd FileType qf nnoremap <buffer> <c-y> :PreviewScroll -1<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'neoclide/coc.nvim', {'branch': 'release'}

" 设置默认开启或者关闭，1表示启动（默认值），0表示不启动
" let g:coc_start_at_startup=0

" 在编辑模式下，触发自动补全时，将 <tab> 映射成移动到下一个补全选项
inoremap <silent><expr> <tab>
      \ pumvisible() ? "\<c-n>" :
      \ <SID>check_back_space() ? "\<tab>" :
      \ coc#refresh()
inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\c-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" 在编辑模式下，将 <cr> 配置成选中当前补全选项
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

" K 查看文档
nnoremap <silent> K :call <SID>show_documentation()<cr>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" 诊断快捷键
nmap <silent> <c-k> <Plug>(coc-diagnostic-prev)
nmap <silent> <c-j> <Plug>(coc-diagnostic-next)

" 自动根据语义进行范围选择
nmap <silent> <c-s> <Plug>(coc-range-select)
xmap <silent> <c-s> <Plug>(coc-range-select)

" 代码导航的相关映射
nmap <leader>rd <Plug>(coc-definition)
nmap <leader>ry <Plug>(coc-type-definition)
nmap <leader>ri <Plug>(coc-implementation)
nmap <leader>rr <Plug>(coc-references)
nmap <leader>rn <Plug>(coc-rename)

" 将 打开文件管理器 映射到快捷键 [Space] + e
nmap <space>e <cmd>CocCommand explorer<cr>

" 将 触发代码片段扩展 映射到快捷键 [Ctrl] + l
imap <c-l> <Plug>(coc-snippets-expand)
" 在 visual 模式下，将 跳转到下一个占位符 映射到快捷键 [Ctrl] + j
vmap <c-j> <Plug>(coc-snippets-select)
" 在编辑模式下，将 跳转到下一个/上一个占位符 分别映射到 [Ctrl] + j 和 [Ctrl] + k
let g:coc_snippet_next = '<c-j>'
let g:coc_snippet_prev = '<c-k>'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'honza/vim-snippets'

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'skywind3000/asyncrun.vim'

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

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
nnoremap <c-n> :LeaderfMru<cr>
" 将 :LeaderfFunction! 映射到快捷键 [Option] + p，即「π」
nnoremap π :LeaderfFunction!<cr>
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

" 将 :Ag 和 :Rg 分别映射到 \ag 和 \rg
nnoremap <leader>ag :Ag<cr>
nnoremap <leader>rg :Rg<cr>
" 配置快捷键[Ctrl] + a，[Ctrl] + q，将结果导入quickfix
" https://github.com/junegunn/fzf.vim/issues/185
function! s:build_quickfix_list(lines)
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
    copen
    cc
endfunction
let g:fzf_action = { 'ctrl-q': function('s:build_quickfix_list') }
let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
" 排除 :Ag 和 :Rg 搜索结果中仅匹配文件名的条目
" https://github.com/junegunn/fzf.vim/issues/346
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)
command! -bang -nargs=* Rg call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

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

Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

" 将 :FormatCode 映射到快捷键 [Ctrl] + l
nnoremap <c-l> :FormatCode<cr>

" <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Plug 'tpope/vim-surround'

call plug#end()

" vim-codefmt的额外配置
call glaive#Install()
" 设置google-java-format的启动命令，其中
" /usr/local/share/google-java-format-1.14.0-all-deps.jar 是我的安装路径
" --aosp 采用aosp风格，缩进为4个空格
Glaive codefmt google_java_executable="java -jar /usr/local/share/google-java-format-1.14.0-all-deps.jar --aosp"

" ctags的配置
" 将 :tn 和 :tp 分别映射到 [Option] + j 和 [Option] + k，即「∆」和「˚」
nnoremap ∆ :tn<cr>
nnoremap ˚ :tp<cr>
" tags搜索模式
set tags=./.tags;,.tags
" c/c++ 标准库的ctags
autocmd FileType c,cpp,objc set tags+=~/.vim/.cfamily_systags
" python 标准库的ctags
autocmd FileType python set tags+=~/.vim/.python_systags

" gtags的配置
" native-pygments 设置后会出现「gutentags: gtags-cscope job failed, returned: 1」，所以我把它换成了 native
" let $GTAGSLABEL = 'native-pygments'
let $GTAGSLABEL = 'native'
let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
if filereadable(expand('~/.vim/gtags.vim'))
    source ~/.vim/gtags.vim
endif
if filereadable(expand('~/.vim/gtags-cscope.vim'))
    source ~/.vim/gtags-cscope.vim
endif

" 编辑模式，光标移动快捷键
" 将移动到行首（同一般模式下的 ^）映射到 [Ctrl] + a
" 将移动到行尾（同一般模式下的 $）映射到 [Ctrl] + e
inoremap <silent> <c-a> <c-o>^
inoremap <silent> <c-e> <c-o>$

" 替换映射到 [Option] + r，即「®」
" 其中，<c-r><c-w> 表示 [Ctrl] + r 以及 [Ctrl] + w，用于将光标所在的单词填入搜索/替换项中
nnoremap ® :%s/<c-r><c-w>

" tab 切换
nnoremap ¬ :tabnext<cr>
nnoremap ˙ :tabprev<cr>

" 回车时，默认取消搜索高亮
nnoremap <silent> <cr> :nohlsearch<cr><cr>
" \qc 关闭 quickfix
nnoremap <leader>qc :cclose<cr>

" 折叠，默认不启用
set nofoldenable
set foldmethod=indent
set foldlevel=0
" 其他常用
set backspace=indent,eol,start
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hlsearch
set number
set cursorline
set matchpairs+=<:>

" 设置头文件搜索路径，可以在项目的 .workspace.vim 文件中通过 set path+= 追加搜索路径
set path=.,/usr/include,/usr/local/include,/usr/local/lib/gcc/x86_64-pc-linux-gnu/10.3.0/include,/usr/local/include/c++/10.3.0

" 加载额外的配置
if filereadable(expand("~/.vimrc_extra"))
    source ~/.vimrc_extra
endif

" 加载项目定制化配置
if filereadable("./.workspace.vim")
    source ./.workspace.vim
endif
```

# 4 vim-script

## 4.1 Tips

1. `filereadable`无法识别`~`，需要用`expand`，例如`filereadable(expand('~/.vim/gtags.vim'))`

# 5 参考

* **[《Vim 中文速查表》](https://github.com/skywind3000/awesome-cheatsheets/blob/master/editors/vim.txt)**
* **[如何在 Linux 下利用 Vim 搭建 C/C++ 开发环境?](https://www.zhihu.com/question/47691414)**
* **[Vim 8 中 C/C++ 符号索引：GTags 篇](https://zhuanlan.zhihu.com/p/36279445)**
* **[Vim 8 中 C/C++ 符号索引：LSP 篇](https://zhuanlan.zhihu.com/p/37290578)**
* **[三十分钟配置一个顺滑如水的 Vim](https://zhuanlan.zhihu.com/p/102033129)**
* **[CentOS Software Repo](https://www.softwarecollections.org/en/scls/user/rhscl/)**
* **[《Vim 中文版入门到精通》](https://github.com/wsdjeg/vim-galore-zh_cn)**
* **[VimScript 五分钟入门（翻译）](https://zhuanlan.zhihu.com/p/37352209)**
* **[使用 Vim 搭建 Java 开发环境](https://spacevim.org/cn/use-vim-as-a-java-ide/)**
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
* [The Vim/Cscope tutorial](http://cscope.sourceforge.net/cscope_vim_tutorial.html)
* [GNU Global manual](https://phenix3443.github.io/notebook/emacs/modes/gnu-global-manual.html)
* [Vim Buffers, Windows and Tabs — an overview](https://medium.com/@paulodiovani/vim-buffers-windows-and-tabs-an-overview-8e2a57c57afa)