---
title: Linux-vim
date: 2018-01-16 22:58:45
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 vi的使用

## 1.1 模式

基本上vi分为三种模式：**一般模式、编辑模式与命令模式**

一般模式与编辑模式以及命令行模式可以相互切换，但是编辑模式与命令行模式之间不可相互切换

### 1.1.1 一般模式

以vi打开一个文件就进入一般模式了(这是默认模式)

在这个模式中，你可以使用上下左右按键来移动光标，可以删除字符或删除整行，也可以复制粘贴你的文件数据

### 1.1.2 编辑模式

在一般模式中，可以进行删除，复制，粘贴等操作，但是却无法编辑文件内容。要等到你按下i(I),o(O),a(A),r(R)等任何一个字母后才会进入编辑模式

通常在Linux中，按下这些键时，在界面的左下方会出现INSERT(ioa)或REPLACE(r)的字样，此时才可以进行编辑

如果要回到一般模式，必须按下Esc这个按键即可退出编辑器

### 1.1.3 命令行模式

在一般模式中，输入":"  "/"  "?"这三个钟的任何一个按钮，就可以将光标移动到最下面一行，在这个模式中，可以提供你查找数据的操作，而读取、保存、大量替换字符、离开vi、显示行号等操作则是在此模式中完成的

## 1.2 简单执行范例

1. 直接输入vi [文件名]就能进入vi的一般模式，vi后面必须要加上文件名，无论文件名是否存在
1. 整个界面分为两部分，上半部与下面一行两者可以视为独立的
1. 按下i进入编辑模式
    * 在一般模式中只要按下i、o、a等字符就可以进入编辑模式
    * **此时除了Esc这个按键之外，其他的按键都可以视作一般的输入了**
    * 在vi里，[Tab]键所得到的结果与空格符所得到的结果是不一样的
1. 按下[Esc]键回到一般模式
1. 在一般模式中输入":wq"保存后离开vi

## 1.3 按键说明

**第一部分：一般模式可用的按钮说明，光标移动，复制粘贴，查找替换等**

* `h或向左箭头`：光标向左移动一个字符← 
* `j或向下箭头`：光标向下移动一个字符↓
* `k或向上箭头`：光标向上移动一个字符↑
* `l或向右箭头`：光标向右移动一个字符→
* 可以配合数字使用，如向右移动30个字符30l或30(→)
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
* **`w`：向右移动一个字**
* **`b`：向左移动一个字**
* **`G`：移动到这个文件的最后一行**
* `[n]G`：n为数字，移动到这个文件的第n行
* **`gg`：移动到这个文件的第一行，相当于1G**
* **`[n][Enter]`：光标向下移动n行**
* **`/[word]`：向下寻找一个名为word的字符串，支持正则表达式**
* **`?[word]`：向上寻找一个名为word的字符串，支持正则表达式**
    * `n`：重复前一个查找操作
    * `N`："反向"进行前一个查找操作
* **`:[n1],[n2]s/[word1]/[word2]/g`：在n1与n2行之间寻找word1这个字符串，并将该字符串替换为word2，支持正则表达式**
* **`:1,$s/[word1]/[word2]/g`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，支持正则表达式**
* **`:1,$s/[word1]/[word2]/gc`：从第一行到最后一行查找word1字符串，并将该字符串替换为word2，且在替换前显示提示字符给用户确认是否替换，支持正则表达式**
* **`x,X`：在一行字当中，x为向后删除一个字符(相当于[Del]键),X为向前删除一个字符(相当于[Backspace])**
* `[n]x`：连续向后删除n个字符
* **`dd`：删除光标所在一整行**
* **`dw`：删除光标所在的字符到光标所在单词的最后一个字符**
* **`[n]dd`：删除光标所在的向下n行(包括当前这一行)**
* **`d1G`：删除光标所在到第一行的所有数据(包括当前这一行)**
* **`dG`：删除光标所在到最后一行的所有数据(包括当前这一行)**
* **`d$`：删除光标所在的字符到该行的最后一个字符(包括光标所指向的字符)**
* **`d0(这是零)`：删除从光标所在的字符到该行最前面一个字符(不包括光标所指向的字符)**
* **`yy`：复制光标所在那一行**
* **`[n]yy`：复制光标所在的向下n行(包括当前这一行)**
* **`y1G`：复制光标所在行到第一行的所有数据(包括当前这一行)**
* **`yG`：复制光标所在行到最后一行的数据(包括当前这一行)**
* **`y0(这是零)`：复制光标所在那个字符到该行第一个字符的所有数据(不包括光标所指向的字符)**
* **`y$`：复制光标所在那个字符到该行最后一个字符的所有数据(包括光标所指向的字符)**
* **`p,P`：p将已复制的数据在光标的下一行粘贴，P为粘贴在光标的上一行**
* `J`：将光标所在行与下一行的数据结合成同一行
* `c`：重复删除多个数据，例如向下删除10行,10cj
* **`u`：复原(撤销)前一个操作**
* **`[Ctrl]+r`：重做上一个操作**
* **`.`：重做上一个操作**
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

**第二部分：一般模式切换到编辑模式的可用按钮说明**

* **`i,I`：进入插入模式，i为从光标所在处插入，I为在目前所在行的第一个非空格处开始插入**
* **`a,A`：进入插入模式，a为从目前光标所在的下一个字符处开始插入，A为从光标所在行的最后一个字符处开始插入**
* **`o,O`：进入插入模式，o为在目前光标所在的下一行处插入新的一行，O为在目前光标所在处的上一行插入新的一行**
* **`s,S`：进入插入模式，s为删除目前光标所在的字符，S为删除目前光标所在的行**
* **`r,R`：进入替换模式，r只会替换光标所在的那一个字符一次，R会一直替换光标所在行的文字，直到按下Esc**
* **`Esc`：退回一般模式**

**第三部分：一般模式切换到命令行模式的可用按钮说明**

* **`:w`：将编辑的数据写入硬盘文件中**
* **`:w!`：若文件属性为只读时，强制写入该文件，不过到底能不能写入，还是跟你对该文件的文件属性权限有关**
* **`:q`：离开**
* **`:q!`：若曾修改过文件，又不想存储，使用"!"为强制离开不保存的意思**
* **`:wq`：保存后离开,若为:wq!则代表强制保存并离开**
* `ZZ`：若文件没有变更，则不保存离开，若文件已经变更过，保存后离开
* `:w [filename]`：将编辑文件保存称为另一个文件,注意w和文件名中间有空格
* `:r [filename]`：在编辑的数据中，读入另一个文件的数据，即将filename这个文件的内容加到光标所在行后面，注意r和文件名之间有空格
* `:[n1],[n2]w [filename]`：将n1到n2的内容保存成filename这个文件，注意w和文件名中间有空格，[n2]与w之间可以没有空格
* `:! [command]`：暂时离开vi到命令模式下执行command的显示结果，例如:! ls /home
* `:set nu`：显示行号
* `:set nonu`：取消行号
* `:set paste`：直接复制，不格式化

# 2 vim的功能

目前大部分distributions都以vim替代vi的功能了

如果使用vi后发现界面右下角有显示光标所在的行列号码，说明vi已经被vim替代了

vim具有颜色显示功能，并且还支持许多程序语法，vim可以帮助直接进行程序除错(debug)的功能

## 2.1 块选择(Visual Block)

vi的操作几乎都是以行为单位的

vim可以处理块范围的数据

**按键：**

* `v`：字符选择：会将光标经过的地方反白选择
* `V`：行选择：会将光标经过的行反白选择
* `[Ctrl]+v`：块选择，可以用长方形的方式选择数据
* `y`：将反白的地方复制
* `d`：将反白的地方删除

**示例**

* 多行同时插入相同内容
    1. 在需要插入内容的列的位置，按`[Ctrl]+v`，选择需要同时修改的行
    1. 按`I`进入编辑模式
    1. 编写需要插入的文本
    1. 按两下`ecs`

## 2.2 多文件编辑

想要将文件A中的数据复制到文件B中去，由于vim都是独立的，无法在执行A文件时执行nyy再到B文件执行p。可以使用鼠标圈选，但是会将[Tab]转为空格，并非所预期，这时候可以用多文件编辑

**按键：**

* `vim [filename1] [filename2]...`：同时编辑多个文件
* `:n`：编辑下一个文件
* `:N`：编辑上一个文件
* `:files`：列出这个vim打开的所有文件

## 2.3 多窗口功能

有一个文件非常大，在查阅后面的数据时，想要对照前面的数据，如果用翻页等命令([Ctrl]+f  [Ctrl]+b)会显得很麻烦

在一般模式中输入命令"sp:"

* 若要打开同一文件，输入"sp"即可
* 若要代开其他文件，输入"sp [filename]"即可

**窗口切换命令：**

* `[Ctrl]+w+↓`：首先按下[Ctrl]，在按下w，然后放开两个键，再按下↓切换到下方窗口
* `[Ctrl]+w+↑`：首先按下[Ctrl]，在按下w，然后放开两个键，再按下↑切换到上方窗口

**分屏**

* `Ctrl+w &`：先Ctrl再w，放掉Ctrl和w再按&，以下操作以此为基准
1. `vim -On file1 file2...`：垂直分屏
1. `vim -on file1 file2...`：左右分屏
1. `Ctrl+w c`：关闭当前窗口(无法关闭最后一个)
1. `Ctrl+w q`：关闭当前窗口(可以关闭最后一个)
1. `Ctrl+w s`：上下分割当前打开的文件
1. `Ctrl+w v`：左右分割当前打开的文件
1. `:sp filename`：上下分割并打开一个新的文件
1. `:vsp filename`：左右分割，并打开一个新的文件
1. `Ctrl+w l`：把光标移动到右边的屏中
1. `Ctrl+w h`：把光标移动到左边的屏中
1. `Ctrl+w k`：把光标移动到上边的屏中
1. `Ctrl+w j`：把光标移动到下边的屏中
1. `Ctrl+w w`：把光标移动到下一个屏中
1. `Ctrl+w L`：向右移动屏幕
1. `Ctrl+w H`：向左移动屏幕
1. `Ctrl+w K`：向上移动屏幕
1. `Ctrl+w J`：向下移动屏幕
1. `Ctrl+w =`：让所有屏幕都有一样的高度
1. `Ctrl+w +`：增加高度
1. `Ctrl+w -`：减小高度

## 2.4 vim环境设置与记录:~/.vimrc,~/.viminfo

vim会主动将你曾经做过的行为记录下来，好让你下次可以轻松作业，记录操作的文件就是~/.viminfo

整体vim的设置值一般放置在/etc/vimrc这个文件中，不过不建议修改它，但是可以修改~/.vimrc这个文件(默认不存在，手动创建)

# 3 问题

## 3.1 中文乱码

**编辑`/etc/vimrc`，追加如下内容**

```sh
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
```

# 4 参考

* [Linux 中的各种栈：进程栈 线程栈 内核栈 中断栈](http://blog.csdn.net/yangkuanqaz85988/article/details/52403726)
* 《鸟哥的Linux私房菜》
* [Mac 的 Vim 中 delete 键失效的原因和解决方案](https://blog.csdn.net/jiang314/article/details/51941479)
* [解决linux下vim中文乱码的方法](https://blog.csdn.net/zhangjiarui130/article/details/69226109)
* [vim-set命令使用](https://www.jianshu.com/p/97d34b62d40d)
