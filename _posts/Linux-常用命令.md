---
title: Linux-常用命令
date: 2017-08-15 20:17:57
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 系统信息

## 1.1 uname

**格式：**

* `uname [option]`

**参数说明：**

* `-a, --all`：以如下次序输出所有信息。其中若`-p`和`-i`的探测结果不可知则被省略：
* `-s, --kernel-name`：输出内核名称
* `-n, --nodename`：输出网络节点上的主机名
* `-r, --kernel-release`：输出内核发行号
* `-v, --kernel-version`：输出内核版本
* `-m, --machine`：输出主机的硬件架构名称
* `-p, --processor`：输出处理器类型或"unknown"
* `-i, --hardware-platform`：输出硬件平台或"unknown"
* `-o, --operating-system`：输出操作系统名称

**示例：**

* `uname -a`
* `uname -r`
* `uname -s`

## 1.2 chsh

**格式：**

* `chsh [-ls]`

**参数说明：**

* `-l`：列出目前系统上可用的shell，其实就是`/etc/shells`的内容
* `-s`：设置修改自己的shell

## 1.3 man

* `man 1`：标准Linux命令
* `man 2`：系统调用
* `man 3`：库函数
* `man 4`：设备说明
* `man 5`：文件格式
* `man 6`：游戏娱乐
* `man 7`：杂项
* `man 8`：系统管理员命令
* `man 9`：常规内核文件

## 1.4 demsg

kernel会将开机信息存储在`ring buffer`中。您若是开机时来不及查看信息，可利用`dmesg`来查看。开机信息亦保存在`/var/log`目录中，名称为dmesg的文件里

## 1.5 last

**示例：**

* `last -x`

## 1.6 w

该命令用于查看当前谁登录了系统，并且正在做什么事情，比`who`更强大一点

**示例：**

* `w`

## 1.7 useradd

添加账号

**示例：**

* `useradd test -g wheel -G wheel -m -s /bin/bash`

## 1.8 passwd

**示例：**

* `echo '123456' | passwd --stdin root`

## 1.9 readelf

用于读取、解析可执行程序

# 2 常用处理工具

## 2.1 echo

**格式：**

* `echo [-ne] [字符串/变量]`
* `''`中的变量不会被解析，`""`中的变量会被解析

**参数说明：**

* `-n`：不要在最后自动换行
* `-e`：打开反斜杠ESC转义。若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出
    * `\a`：发出警告声
    * `\b`：删除前一个字符
    * `\c`：最后不加上换行符号
    * `\f`：换行但光标仍旧停留在原来的位置
    * `\n`：换行且光标移至行首
    * `\r`：光标移至行首，但不换行
    * `\t`：插入tab
    * `\v`：与\f相同
    * `\\`：插入\字符
    * `\nnn`：插入nnn（八进制）所代表的ASCII字符

**示例：**

* `echo ${a}`
* `echo -e "a\nb"`

**颜色控制，控制选项说明：** 

```sh
echo -e "\033[30m 黑色字 \033[0m"
echo -e "\033[31m 红色字 \033[0m"
echo -e "\033[32m 绿色字 \033[0m"
echo -e "\033[33m 黄色字 \033[0m"
echo -e "\033[34m 蓝色字 \033[0m"
echo -e "\033[35m 紫色字 \033[0m"
echo -e "\033[36m 天蓝字 \033[0m"
echo -e "\033[37m 白色字 \033[0m"

echo -e "\033[40;37m 黑底白字 \033[0m"
echo -e "\033[41;37m 红底白字 \033[0m"
echo -e "\033[42;37m 绿底白字 \033[0m"
echo -e "\033[43;37m 黄底白字 \033[0m"
echo -e "\033[44;37m 蓝底白字 \033[0m"
echo -e "\033[45;37m 紫底白字 \033[0m"
echo -e "\033[46;37m 天蓝底白字 \033[0m"
echo -e "\033[47;30m 白底黑字 \033[0m"
```

## 2.2 sed

**格式：**

* `sed [-nefr] [动作] [文件]`
* `STD IN | sed [-nefr] [动作]`

**参数说明：**

* **`-n`**：使用安静(silent)模式，在一般sed中，所有来自STDIN的数据一般都会被列到屏幕上，加了参数-n后，只有经过sed特殊处理的那一行才会被列出来
* **`-e`**：直接在命令行模式上进行sed的动作编辑
* **`-f`**：直接将sed的动作写在一个文件内，`-f filenmae`则可以执行filename内的sed动作
* **`-r`**：sed的动作支持的是扩展正则表达式的语法
* **`-i`**：直接修改读取的文件内容，而不是由屏幕输出

**动作说明，格式为`[n1 [,n2]]function`，接的动作必须以两个单引号括住**

* **如果没有`[n1 [,n2]]`，表示对所有行均生效**
* **如果仅有`[n1]`，表示仅对`n1`行生效**
* **`n1`与`n2`可以用`/string/`来表示`[ /string_n1/ ,[ /stirng_n2/ ]]`**。**配合`-r`参数，还可以使用正则表达式**
    * **`/string_n1/`**：**从第一行开始**，**`所有`**匹配字符串`string_n1`的行号
    * **`/string_n1/,/stirng_n2/`**：**从第一行开始**，**`第一个`**匹配字符串`string_n1`的行号，到，**从第一行开始**，**`第一个`**匹配字符串`stirng_n2`的行号
    * **当该行包含`string`时，就算匹配成功**
    * **如果要匹配整行，可以利用`-r`参数配合正则表达式通配符`^`与`$`来完成**
    * **由于`/`是特殊字符，因此在正则表达式中，表示一个普通的`/`需要转义**
* **`a`**：新增，a的后面可接字符串，而这些字符串会在新的一行出现(目前行的下一行)
* **`c`**：替换，c的后面可接字符串，这些字符串可以替换n1,n2之间的行
* **`d`**：删除，后面通常不接任何参数
* **`i`**：插入，i的后面可接字符串，而这些字符串会在新的一行出现(目前行的上一行)
* **`p`**：打印，也就是将某个选择的数据打印出来，通常p会与参数sed -n一起运行
* **`s`**：替换，可以直接进行替换的工作，通常这个s可以搭配正则表达式，例如1,20s/lod/new/g  (跟vim里面的很像！！！)
    * **分隔符可以是`/`也可以是`|`**
    * **分隔符若为`/`，那么普通的`|`不需要转义，`/`需要转义**
    * **分隔符若为`|`，那么普通的`/`不需要转义，`|`需要转义**
    * **不加`-r`参数，连`()`都需要转义，因此最好加上`-r`参数**
    * `\0`：表示整个匹配串，`\1`表示group1，以此类推
    * `&`：表示整个匹配串
    * `g`：表示每行全部替换，否则只替换每行第一个
* **`r`**：插入另一个文本的所有内容

**示例：**

* **`a`**：
```sh
echo -e "a\nb\nc" | sed '1,2anewLine'

# 输出如下
a
newLine
b
newLine
c
```

* **`c`**：
```sh
# /^a$/通过正则表达式匹配第一行，需要配合-r参数
echo -e "a\nb\nc" | sed -r '/^a$/,2cnewLine'

# 输出如下
newLine
c
```

* **`d`**：
```sh
# 删除第2行，到第一个包含字符'c'的行
echo -e "a\nb\nc" | sed '2,/c/d'

# 输出如下
a
```

* **`i`**：
```sh
echo -e "a\nb\nc" | sed '1,2inewLine'

# 输出如下
newLine
a
newLine
b
c
```

* **`p`**：
```sh
# $表示最后一行
echo -e "a\nb\nc" | sed -n '/b/,$p'

# 输出如下
b
c
```

* **`s`**：
```sh
# 作用于所有行，对于每一行，将第一个a替换为A
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/'

# 作用于所有行，对于每一行，将所有a替换为A
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/g'

# 作用于所有行，对于每一行，将所有a替换为A，并打印出来
echo -e "abcabc\nbcabca\ncabcab" | sed -n 's/a/A/gp'

# 作用于第一行到第三行，对于所有第三个字符为a的串，删掉字符a，保留前两个字符
# /^abc/匹配第一个以abc开头的行，/cab$/匹配第一个以cab结尾的行
# 以下两个等价，分隔符可以用'/'，可以用'|'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s/(..)a/\1/gp'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s|(..)a|\1|gp'

# 作用于最后一行，对于所有串loverable，替换成lovers
echo -e "loverable" | sed -nr '$s/(love)rable/\1rs/gp'

# 将/root/替换为/，下面两个等价
echo "/root/document/file.txt" | sed -nr 's|/root/|/|p'     # 此时'/'不需要转义，因为分隔符是'|'
echo "/root/document/file.txt" | sed -nr 's/\/root\//\//p'  # 此时'/'需要转义，因为分隔符也是'/'（看起来就不直观）

# 将所有a或b替换成A，下面两个等价
echo "abc" | sed -nr 's/a|b/A/gp'   # 此时'|'不需要转义，因为分隔符是'/'
echo "abc" | sed -nr 's|a\|b|A|gp'  # 此时'|'需要转义，因为分隔符是'|'
```

* **`r`：**
```sh
# 准备文件1
cat > file1.txt << EOF
<html>
<body>
<tag>
</tag>
</body>
</html>
EOF

# 准备文件2
cat > file2.txt << EOF
Hello world!!
EOF

sed '/<tag>/ r file2.txt' file1.txt
```

**注意**：在macOS中，`-i`参数后面要跟一个扩展符，用于备份源文件。如果扩展符长度是0，那么不进行备份

* `sed -i ".back" "s/a/b/g" example`：备份文件为`example.back`
* `sed -i "" "s/a/b/g" example`：不备份

## 2.3 awk

相比于sed(管道命令)常常作用于一整行的处理，awk(管道命令)则比较倾向于将一行分成数个"字段"来处理，因此awk相当适合处理小型的数据处理

**格式：**

* `awk [-F] '[/regex/] 条件类型1{动作1} 条件类型2{动作2}...' [filename]`

**参数说明：**

* `-F`：后接分隔符。例如：`-F ':'`、`-F '[,.;]'`

注意awk后续的所有动作都是以单引号括住的，而且如果以print打印时，非变量的文字部分，包括格式等(例如制表`\t`、换行`\n`等)都需要以双引号的形式定义出来，因为单引号已经是awk的命令固定用法了。例如`last -n 5 | awk '{print $1 "\t" $3}'`

**awk处理流程：**

1. 读入第一行
    * **如果包含正则匹配部分（`[/regex/]`），如果不匹配则跳过该行；如果匹配（任意子串），那么将第一行的数据填入`$0`,`$1`,...等变量中**
    * 如果不包含正则匹配部分，那么将第一行的数据填入`$0`,`$1`,...等变量中
1. 依据条件类型的限制，判断是否需要进行后面的动作
1. 做完所有的动作与条件类型
1. 若还有后续的'行'，重复上面的步骤，直到所有数据都读取完为止

**awk内置变量：**

* `ARGC`：命令行参数个数
* `ARGV`：命令行参数排列
* `ENVIRON`：支持队列中系统环境变量的使用
* `FILENAME`：awk浏览的文件名
* `FNR`：浏览文件的记录数
* **`FS`：设置输入域分隔符，默认是空格键，等价于命令行 -F选项**
* **`NF`：每一行($0)拥有的字段总数**
* **`NR`：目前awk所处理的是第几行**
* `OFS`：输出域分隔符
* `ORS`：输出记录分隔符
* `RS`：控制记录分隔符
* 在动作内部引用这些变量不需要用`$`，例如`last -n 5 | awk '{print $1 "\t  lines: " NR "\t columes: " NF}'`
* 此外，`$0`变量是指整条记录。`$1`表示当前行的第一个域，`$2`表示当前行的第二个域，以此类推

**awk内置函数**

* `sub(r, s [, t])`：用`s`替换字符串`t`中的第一个正则表达式`r`
* `gsub(r, s [, t])`：用`s`替换字符串`t`中的所有正则表达式`r`
* `tolower(s)`：将字符串`s`的每个字母替换成小写字母
* `toupper(s)`：将字符串`s`的每个字母替换成大写字母
* `length(s)`：返回字符串长度

**动作说明：**

* 所有awk的动作，即在`{}`内的动作，如果有需要多个命令辅助时，可以用分号`;`间隔，或者直接以`Enter`按键来隔开每个命令

**BEGIN与END：**

* 在Unix awk中两个特别的表达式，BEGIN和END，这两者都可用于pattern中（参考前面的awk语法），**提供BEGIN和END的作用是给程序赋予初始状态和在程序结束之后执行一些扫尾的工作。**
* **任何在BEGIN之后列出的操作（在`{}`内）将在Unix awk开始扫描输入之前执行，而END之后列出的操作将在扫描完全部的输入之后执行。**因此，通常使用BEGIN来显示变量和预置（初始化）变量，使用END来输出最终结果

**print与printf：**

* print会打印换行符
* printf不会打印换行符

**示例：**

* `cat /etc/passwd | awk '{FS=":"} $3<10 {print $1 "\t" $3}'`：**注意`{FS=":"}`是作为一个动作存在的，因此从第二行开始分隔符才变为":"，第一行分隔符仍然是空格**
* `cat /etc/passwd | awk 'BEGIN {FS=":"} $3<10 {print $1 "\t" $3}'`：**这样写`{FS=":"}`在处理第一行时也会生效**
* `echo -e "abcdefg\nhijklmn\nopqrst\nuvwxyz" | awk '/[au]/ {print $0}'`
* `lvdisplay|awk  '/LV Name/{n=$3} /Block device/{d=$3; sub(".*:","dm-",d); print d,n;}'`
    * 这里有两个动作，这两个动作分别有两个条件，一个包含`LV Name`，另一个包含`Block device`，哪个条件满足就执行哪个动作，如果两个条件都满足，那么两个都执行（在这个case下，不可能同时满足）
    * 首先匹配第一个条件，`n`存储的是卷组名称，假设是`swap`
    * 然后匹配第二个条件，`d`存储的是磁盘名称，假设是`253:1`，经过`sub`函数，将`253:`替换成`dm-`，因此此时d为`dm-1`，打印`d`和`n`
    * 接着匹配第一个条件，`n`存储的是卷组名称，假设是`root`，此时`d`的内容还是`dm-1`
    * 最后匹配第二个条件，`d`存储的是磁盘名称，假设是`253:0`，经过`sub`函数，将`253:`替换成`dm-`，因此此时d为`dm-0`，打印`d`和`n`
* 
```shell
awk 
'BEGIN {FS=":";print "统计销售金额";total=0} 
{print $3;total=total+$3;} 
END {print "销售金额总计：",total}' sx
```

### 2.3.1 在awk中引用变量

**方式1：**

* 以`'"`和`"'`（即，单引号+双引号+shell变量+双引号+单引号）将shell变量包围起来
* **这种方式只能引用数值变量**

```sh
var=4
awk 'BEGIN{print '"$var"'}'
```

**方式2：**

* 以`"'`和`'"`（即，双引号+单引号+shell变量+单引号+双引号）将shell变量包围起来
* **这种方式可以引用字符串型变量，但是字符串不允许包含空格**

```sh
var=4
awk 'BEGIN{print "'$var'"}'
var="abc"
awk 'BEGIN{print "'$var'"}'
```

**方式3：**

* 用`"'"`（即，双引号+单引号+双引号+shell变量+双引号+单引号+双引号）将shell变量包裹起来
* **这种方式允许引用任意类型的变量**

```sh
var=4
awk 'BEGIN{print "'"$var"'"}'
var="abc"
awk 'BEGIN{print "'"$var"'"}'
var="this a test"
awk 'BEGIN{print "'"$var"'"}'
```

**方式4：**

* 使用`-v`参数，变量不是很多的时候，这种方式也蛮简介清晰的

```sh
var="this a test"
awk -v awkVar="$var" 'BEGIN{print awkVar}'
```

### 2.3.2 在awk中写简单的控制流语句

**以下的示例都在BEGIN中，只执行一次，不需要指定文件或者输入流**

**if语句：**
```sh
awk 'BEGIN{ 
test=100;
if(test>90)
{
    print "very good";
}
else if(test>60)
{
    print "good";
}
else
{
    print "no pass";
}
}'
```

**while语句：**
```sh
awk 'BEGIN{ 
test=100;
total=0;
while(i<=test)
{
    total+=i;
    i++;
}
print total;
}'
```

**for语句：**
```sh
awk 'BEGIN{ 
for(k in ENVIRON)
{
    print k"="ENVIRON[k];
}
}'

awk 'BEGIN{ 
total=0;
for(i=0;i<=100;i++)
{
    total+=i;
}
print total;
}'
```

**do语句：**
```sh
awk 'BEGIN{ 
total=0;
i=0;
do
{
    total+=i;
    i++;
}while(i<=100)
print total;
}'
```

### 2.3.3 在awk中使用正则表达式

```sh
echo "123" |awk '{if($0 ~ /^[0-9]+$/) print $0;}'
```

## 2.4 cut

**格式：**

* `cut -b list [-n] [file ...]`
* `cut -c list [file ...]`
* `cut -f list [-s] [-d delim] [file ...]`

**参数说明：**

* `list`：范围
    * `N`：从第1个开始数的第N个字节、字符或域
    * `N-`：从第N个开始到所在行结束的所有字符、字节或域
    * `N-M`：从第N个开始到第M个之间(包括第M个)的所有字符、字节或域
    * `-M`：从第1个开始到第M个之间(包括第M个)的所有字符、字节或域
* `-b`：以字节为单位进行分割。这些字节位置将忽略多字节字符边界，除非也指定了`-n`标志
* `-c`：以字符为单位进行分割
* `-d`：自定义分隔符，默认为制表符
* `-f`：与`-d`一起使用，指定显示哪个区域
* `-n`：取消分割多字节字符。仅和`-b`标志一起使用。如果字符的最后一个字节落在由`-b`标志的`List`参数指示的范围之内，该字符将被写出；否则，该字符将被排除

**示例：**

* `echo "a:b:c:d:e" | cut -d ":" -f3`：输出c
* `ll | cut -c 1-10`：显示查询结果的 1-10个字符

## 2.5 grep

grep分析一行信息，若当前有我们所需要的信息，就将该行拿出来

**格式：**

* `grep [-acinvrAB] [--color=auto] '查找的字符串' filename`

**参数说明：**

* `-a`：将binary文件以text文件的方式查找数据
* `-c`：计算找到'查找字符串'的次数
* `-i`：忽略大小写的不同
* `-e`：用正则表达式来进行匹配操作
* `-n`：顺便输出行号
* `-v`：反向选择，即输出没有'查找字符串'内容的哪一行
* `-r`：在指定目录中递归查找
* `--color=auto`：将找到的关键字部分加上颜色
* `-A`：后面可加数字，为after的意思，除了列出该行外，后面的n行也列出来
* `-B`：后面可加数字，为before的意思，除了列出该行外，前面的n行也列出来
* `-C`：后面可加数字，除了列出该行外，前后的n行也列出来

**示例：**

* `grep -r [--color=auto] '查找的字符串' [目录名]`

## 2.6 sort

**格式：**

* `sort [-fbMnrtuk] [file or stdin]`

**参数说明：**

* `-f`：忽略大小写的差异
* `-b`：忽略最前面的空格符部分
* `-M`：以月份的名字来排序，例如JAN，DEC等排序方法
* `-n`：使用"纯数字"进行排序(默认是以文字类型来排序的)
* `-r`：反向排序
* `-u`：就是uniq，相同的数据中，仅出现一行代表
* `-t`：分隔符，默认使用`Tab`来分隔
* `-k`：以哪个区间(field)来进行排序的意思

**示例：**

* `cat /etc/passwd | sort`
* `cat /etc/passwd | sort -t ':' -k 3`

## 2.7 tr

`tr`指令从标准输入设备读取数据，经过字符串转译后，将结果输出到标准输出设备

**格式：**

* `tr [-cdst] SET1 [SET2]`

**参数说明：**

* `-c, --complement`：反选设定字符。也就是符合`SET1`的部份不做处理，不符合的剩余部份才进行转换
* `-d, --delete`：删除指令字符
* `-s, --squeeze-repeats`：缩减连续重复的字符成指定的单个字符
* `-t, --truncate-set1`：削减`SET1`指定范围，使之与`SET2`设定长度相等

**字符集合的范围：**

* `\NNN`：八进制值的字符 NNN (1 to 3 为八进制值的字符)
* `\\`：反斜杠
* `\a`：Ctrl-G 铃声
* `\b`：Ctrl-H 退格符
* `\f`：Ctrl-L 走行换页
* `\n`：Ctrl-J 新行
* `\r`：Ctrl-M 回车
* `\t`：Ctrl-I tab键
* `\v`：Ctrl-X 水平制表符
* `CHAR1-CHAR2`：字符范围从 CHAR1 到 CHAR2 的指定，范围的指定以 ASCII 码的次序为基础，只能由小到大，不能由大到小。
* `[CHAR*]`：这是 SET2 专用的设定，功能是重复指定的字符到与 SET1 相同长度为止
* `[CHAR*REPEAT]`：这也是 SET2 专用的设定，功能是重复指定的字符到设定的 REPEAT 次数为止(REPEAT 的数字采 8 进位制计算，以 0 为开始)
* `[:alnum:]`：所有字母字符与数字
* `[:alpha:]`：所有字母字符
* `[:blank:]`：所有水平空格
* `[:cntrl:]`：所有控制字符
* `[:digit:]`：所有数字
* `[:graph:]`：所有可打印的字符(不包含空格符)
* `[:lower:]`：所有小写字母
* `[:print:]`：所有可打印的字符(包含空格符)
* `[:punct:]`：所有标点字符
* `[:space:]`：所有水平与垂直空格符
* `[:upper:]`：所有大写字母
* `[:xdigit:]`：所有 16 进位制的数字
* `[=CHAR=]`：所有符合指定的字符(等号里的`CHAR`，代表你可自订的字符)

**示例：**

* `echo "abcdefg" | tr "[:lower:]" "[:upper:]"`：将小写替换为大写
* `echo -e "a\nb\nc" | tr "\n" " "`：将`\n`替换成空格
* `echo "hello 123 world 456" | tr -d '0-9'`：删除`0-9`
* `echo -e "aa.,a 1 b#$bb 2 c*/cc 3 \nddd 4" | tr -d -c '0-9 \n'`：删除除了`0-9`、空格、换行符之外的内容
* `echo "thissss is      a text linnnnnnne." | tr -s ' sn'`：删除多余的空格、`s`和`n`
* `head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`：生成随机串

## 2.8 tee

`>`、`>>`等会将数据流传送给文件或设备，因此除非去读取该文件或设备，否则就无法继续利用这个数据流，如果我们想要将这个数据流的处理过程中将某段信息存下来，可以利用`tee`

`tee`会将数据流送与文件与屏幕(screen)，输出到屏幕的就是`stdout`可以让下个命令继续处理(**`>`,`>>`会截断`stdout`，从而无法以`stdin`传递给下一个命令**)

**格式：**

* `tee [-a] file`

**参数说明：**

* `-a`：以累加(append)的方式，将数据加入到file当中

**示例：**

* `command | tee <文件名> | command`

## 2.9 cat

**格式：**

* `cat > [newfile] <<'结束字符'`

**示例：注意`EOF`与`'EOF'`的区别**

* `man bash`搜索`Here Documents`查看这两者的区别

```sh
name="test"
cat > /tmp/test << EOF
hello ${name}!
EOF
echo "↓↓↓↓↓↓↓↓↓content↓↓↓↓↓↓↓↓↓"
cat /tmp/test
echo "↑↑↑↑↑↑↑↑↑content↑↑↑↑↑↑↑↑↑"

cat > /tmp/test << 'EOF'
hello ${name}!
EOF
echo "↓↓↓↓↓↓↓↓↓content↓↓↓↓↓↓↓↓↓"
cat /tmp/test
echo "↑↑↑↑↑↑↑↑↑content↑↑↑↑↑↑↑↑↑"
```

## 2.10 find

**格式：**

* `find [文件路径] [option] [action]`

**参数说明：**

* `-name`：后接文件名，支持通配符。**注意匹配的是相对路径**
* `-regex`：后接正则表达式，**注意匹配的是完整路径**
* `-maxdepth`：后接查找深度
* `-regextype`：正则表达式类型
    * `emacs`：默认类型
    * `posix-awk`
    * `posix-basic`
    * `posix-egrep`
    * `posix-extended`

**示例：**

* `find . -name "*.c"`
* `find . -maxdepth 1 -name "*.c"`
* `find . -regex ".*/.*\.c"`
* 查找后缀为cfg以及后缀为conf的文件
    * `find ./ -name '*.cfg' -o -name '*.conf'`
    * `find ./ -regex '.*\.cfg\|.*\.conf'`
    * `find ./ -regextype posix-extended -regex '.*\.(cfg|conf)'`

## 2.11 cp

**示例：**

* `cp -vrf /a /b`：递归拷贝目录`/a`到目录`/b`中，包含目录`/a`中所有的文件、目录、隐藏文件和隐藏目录
* `cp -vrf /a/* /b`：递归拷贝目录`/a`下的所有文件、目录，但不包括隐藏文件和隐藏目录
* `cp -vrf /a/. /b`：递归拷贝目录`/a`中所有的文件、目录、隐藏文件和隐藏目录到目录`/b`中

## 2.12 rm

**示例：**

* `rm -rf /a/*`：递归删除目录`/a`下的所有文件、目录，但不包括隐藏文件和隐藏目录
* `rm -rf /path/{..?*,.[!.]*,*}`：递归删除目录`/path`下的所有文件、目录、隐藏文件和隐藏目录

## 2.13 tar

**格式：**

* 压缩：
    * `tar -jcv -f [压缩创建的文件(*.tar.bz2)] [-C 切换工作目录] [被压缩的文件或目录1] [被压缩的文件或目录2]...`
    * `tar -zcv -f [压缩创建的文件(*.tar.gz)] [-C 切换工作目录] [被压缩的文件或目录1] [被压缩的文件或目录2]...`
* 查询：
    * `tar -jtv -f [压缩文件(*.tar.bz2)]`
    * `tar -ztv -f [压缩文件(*.tar.gz)]`
* 解压缩：
    * `tar -jxv -f [压缩文件(*.tar.bz2)] [-C 切换工作目录]`
    * `tar -zxv -f [压缩文件(*.tar.gz)] [-C 切换工作目录]`

**参数说明：**

* `-c`：新建打包文件，可以搭配-v查看过程中被打包的文件名
* `-t`：查看打包文件的内容含有那些文件名，终点在查看文件
* `-x`：解打包或解压缩的功能，可搭配-C在特定目录解开
* **注意，c t x是互斥的**
* `-j`：通过bzip2的支持进行压缩/解压，此时文件名最好为*.tar.bz2
* `-z`：通过gzip的支持进行压缩/解压，此时文件名最好是*.tar.gz
* `-v`：在压缩/解压缩过程中，将正在处理的文件名显示出来
* `-f` filename：-f后面接要被处理的文件名，建议-f单独写一个参数
* `-C`：用户切换工作目录，之后的文件名可以使用相对路径
* `-p`：保留备份数据原本权限与属性，常用语备份(-c)重要的配置文件
* `-P`：保留绝对路径，即允许备份数据中含有根目录存在之意

**示例：**

* `tar -czvf /test.tar.gz -C /home/liuye`
* `tar -zxvf /test.tar.gz -C /home/liuye`
* `tar cvf - /home/liuye | sha1sum`：`-`表示标准输入输出，这里表示标准出

## 2.14 wget

**格式：**

* `wget [OPTION]... [URL]...`

**参数说明：**

* `-O`：后接下载文件的文件名
* `-r`：递归下载（用于下载文件夹）
* `-nH`：下载文件夹时，不创建host目录
* `-np`：不访问上层目录
* `-P`：指定下载的目录
* `-R`：指定排除的列表

**示例：**

* `wget -O myfile 'https://www.baidu.com'`
* `wget -r -np -nH -P /root/test -R "index.html*" 'http://192.168.66.1/stuff'`
* `wget -r -np -nH -P /root/test 'ftp://192.168.66.1/stuff'`

## 2.15 tree

**格式：**

* `tree [option]`

**参数说明：**

* `-N`：显示非ASCII字符，可以显示中文

## 2.16 base64

用于对输入进行`base64`编码以及解码

**示例：**

* `echo "hello" | base64`
* `echo "hello" | base64 | base64 -d`

## 2.17 md5sum

计算输入或文件的MD5值

**示例：**

* `echo "hello" | md5sum`

## 2.18 openssl

openssl可以对文件，以指定算法进行加密或者解密

**示例：**

* `openssl -h`：查看所有支持的加解密算法
* `openssl aes-256-cbc -a -salt -in blob.txt -out cipher`
* `openssl aes-256-cbc -a -d -in cipher -out blob-rebuild.txt`

# 3 设备管理

## 3.1 mount

mount用于挂载一个文件系统

**格式：**

* `mount [-t vfstype] [-o options] device dir`

**参数说明：**

* `-t`：后接文件系统类型，不指定类型的话会自适应
* `-o`：后接挂载选项

**示例：**

* `mount -o loop /CentOS-7-x86_64-Minimal-1908.iso /mnt/iso`

### 3.1.1 传播级别

内核引入`mount namespace`之初，各个`namespace`之间的隔离性较差，例如在某个`namespace`下做了`mount`或者`umount`动作，那么这一事件会被传播到其他的`namespace`中，在某些场景下，是不适用的

因此，在`2.6.15`版本之后，内核允许将一个挂载点标记为`shared`、`private`、`slave`、`unbindable`，以此来提供细粒度的隔离性控制

* `shared`：默认的传播级别，`mount`、`unmount`事件会在不同`namespace`之间相互传播
* `private`：禁止`mount`、`unmount`事件在不同`namespace`之间相互传播
* `slave`：仅允许单向传播，即只允许`master`产生的事件传播到`slave`中
* `unbindable`：不允许`bind`操作，在这种传播级别下，无法创建新的`namespace`

## 3.2 umount

umount用于卸载一个文件系统

**示例：**

* `umount /home`

## 3.3 findmnt

findmnt用于查看挂载点的信息

**参数说明：**

* `-o [option]`：指定要显示的列

**示例：**

* `findmnt -o TARGET,PROPAGATION`

## 3.4 free

**格式：**

* `free [-b|-k|-m|-g|-h] [-t]`

**参数说明：**

* `-b`：bytes
* `-m`：MB
* `-k`：KB
* `-g`：GB
* `-h`：单位自适应

**显示参数介绍**：

* `Men`：物理内存
* `Swap`：虚拟内存
* `total`：内存总大小，该信息可以从`/proc/meminfo`中获取（`MemTotal`、`SwapTotal`）
* `user`：已使用的内存大小，计算方式为`total - free - buffers - cache`
* `free`：未被使用的内存大小，该信息可以从`/proc/meminfo`中获取（`MemFree`、`SwapFree`）
* `shared`：被`tmpfs`使用的内存大小，该信息可以从`/proc/meminfo`中获取（`Shmem`）
* `buffers`：内核`buffer`使用的内存大小，该信息可以从`/proc/meminfo`中获取（`Buffers`）
* `cached`：`slabs`以及`page cache`使用的内存大小，该信息可以从`/proc/meminfo`（`Cached`）
* `available`：仍然可以分配给应用程序的内存大小（非`swap`内存），该信息可以从`/proc/meminfo`（`MemAvailable`）
* **一般来说系统会很有效地将所有内存用光，目的是为了让系统的访问性能加速，这一点与Windows很不同，因此对于Linux系统来说，内存越大越好**

**示例：**

* `free -m`

## 3.5 swap

**制作swap：**

```sh
dd if=/dev/zero of=/tmp/swap bs=1M count=128
mkswap /tmp/swap
swapon /tmp/swap
free
```

## 3.6 df

**参数说明：**

* `-h`：以`K`，`M`，`G`为单位，提高信息的可读性
* `-i`：显示inode信息

**示例：**

* `df -h`
* `df -ih`

## 3.7 du

**格式：**

* `du`

**参数说明：**

* `-h`：以`K`，`M`，`G`为单位，提高信息的可读性
* `-s`：仅显示总计
* `-d <depth>`：指定显示的文件/文件夹的深度

**示例：**

* `du -sh`：当前文件夹的总大小
* `du -h -d 1`：列出深度为1的所有文件/文件夹大小

## 3.8 lsblk

`lsblk`命令用于列出所有可用块设备的信息

**格式：**

* `lsblk [option]`

**参数说明：**

* `-a, --all`：打印所有设备
* `-b, --bytes`：以字节为单位而非易读的格式来打印 SIZE
* `-d, --nodeps`：不打印从属设备(slave)或占位设备(holder)
* `-D, --discard`：打印时丢弃能力
* `-e, --exclude <列表>`：根据主设备号排除设备(默认：内存盘)
* `-I, --include <列表>`：只显示有指定主设备号的设备
* `-f, --fs`：输出文件系统信息
* `-h, --help`：使用信息(此信息)
* `-i, --ascii`：只使用 ascii 字符
* `-m, --perms`：输出权限信息
* `-l, --list`：使用列表格式的输出
* `-n, --noheadings`：不打印标题
* `-o, --output <列表>`：输出列
* `-p, --paths`：打印完整设备路径
* `-P, --pairs`：使用 key=“value” 输出格式
* `-r, --raw`：使用原生输出格式
* `-s, --inverse`：反向依赖
* `-t, --topology`：输出拓扑信息
* `-S, --scsi`：输出有关 SCSI 设备的信息

**示例：**

* `lsblk -fp`
* `lsblk -o name,mountpoint,label,size,uuid`

## 3.9 lsusb

`lsusb`命令用于列出所有usb接口的设备

## 3.10 lspci

`lspci`命令用于列出所有pci接口的设备

## 3.11 sync

`sync`指令会将存于`buffer`中的资料强制写入硬盘中

# 4 进程管理

**后台进程（&）：**

在命令最后加上`&`代表将命令丢到后台执行

* 此时bash会给予这个命令一个工作号码(job number)，后接该命令触发的PID
* 不能被[Ctrl]+C中断
* 在后台中执行的命令，如果有stdout以及stderr时，它的数据依旧是输出到屏幕上面，所以我们会无法看到提示符，命令结束后，必须按下[Enter]才能看到命令提示符，同时也无法用[Ctrl]+C中断。解决方法就是利用数据流重定向

**示例：**

* `tar -zpcv -f /tmp/etc.tar.gz /etc > /tmp/log.txt 2>&1 &`

**`Ctrl+C`**：终止当前进程

**`Ctrl+Z`**：暂停当前进程

## 4.1 jobs

**格式：**

* `jobs [option]`

**参数说明：**

* `-l`：除了列出job number与命令串之外，同时列出PID号码
* `-r`：仅列出正在后台run的工作
* `-s`：仅列出正在后台中暂停(stop)的工作
* 输出信息中的'+'与'-'号的意义：
    * +：最近被放到后台的工作号码，代表默认的取用工作，即仅输入'fg'时，被拿到前台的工作
    * -：代表最近后第二个被放置到后台的工作号码
    * 超过最后第三个以后，就不会有'+'与'-'号存在了

**示例：**

* `jobs -lr`
* `jobs -ls`

## 4.2 fg

将后台工作拿到前台来处理

**示例：**

* `fg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `fg +`：取出标记为+的工作
* `fg -`：取出标记为-的工作`

## 4.3 bg

让工作在后台下的状态变为运行中

**示例：**

* `bg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `bg +`：取出标记为+的工作
* `bg -`：取出标记为-的工作
* 不能让类似vim的工作变为运行中，即便使用该命令会，该工作又立即变为暂停状态

## 4.4 kill

管理后台当中的工作

**格式：**

* `kill [-signal] PID`
* `kill [-signal] %jobnumber`
* `kill -l`

**参数说明：**

* `-l`：列出目前kill能够使用的signal有哪些
* `-signal`：
    * `-1`：重新读取一次参数的配置文件，类似reload
    * `-2`：代表与由键盘输入[Ctrl]+C同样的操作
    * `-9`：立刻强制删除一个工作，通常在强制删除一个不正常的工作时使用
    * `-15`：以正常的程序方式终止一项工作，与-9是不同的，-15以正常步骤结束一项工作，这是默认值
* 与bg、fg不同，若要管理工作，kill中的%不可省略，因为kill默认接PID

## 4.5 pkill

**格式：**

* `pkill [-signal] PID`
* `pkill [-signal] [-Ptu] [arg]`

**参数说明：**

* `-f`：匹配完整的`command line`，默认情况下只能匹配15个字符
* `-signal`：同`kill`
* `-P ppid,...`：匹配指定`parent id`
* `-s sid,...`：匹配指定`session id`
* `-t term,...`：匹配指定`terminal`
* `-u euid,...`：匹配指定`effective user id`
* `-U uid,...`：匹配指定`real user id`
* **不指定匹配规则时，默认匹配进程名字**

**示例：**

* `pkill -9 -t pts/0`
* `pkill -9 -u user1`

## 4.6 ps

**格式：**

* `ps aux`：查看系统所有进程数据
* `ps -lA`：查看所有系统的数据
* `ps axjf`：连同部分进程数状态

**参数说明：**

* `-A`：所有的进程均显示出来
* `-a`：不与terminal有关的所有进程
* `-u`：有效用户相关进程
* `x`：通常与a这个参数一起使用，可列出较完整的信息
* `l`：较长、较详细地将该PID的信息列出
* `j`：工作的格式(job format)
* `-f`：做一个更为完整的输出
* `ps -l`：查阅自己的bash中的程序
* `ps aux`：查阅系统所有运行的程序
* `ps aux -Z`：-Z参数可以让我们查阅进程的安全上下文

**`ps -l`打印参数说明：**

* `F`：代表这个进程标志(process flags)
    * 若为4：表示此进程的权限为root
    * 若为1：表示此子进程尽可进行复制，而无法实际执行
* `S`：代表这个进程的状态(STAT)
    * R(Running)：该进程正在运行中
    * S(Sleep)：该进程目前正在睡眠状态(idle)，但可以被唤醒(signal)
    * D：不可被唤醒的睡眠状态，通常这个进程可能在等待I/O的情况
    * T：停止状态(stop)
    * Z(Zombie)：僵尸状态，进程已经终止但无法被删除至内存外
* `UIP/PID/PPID`：用户标识号/进程PID号码/父进程的PID号码
* `C`：CPU使用率，单位为百分比
* `PRI/NI`：Prority/Nice的缩写，代表此进程被CPU所执行的优先级，数值越小代表越快被CPU执行
* `ADDR/SZ/WCHAN`：都与内存有关
    * ADDR是kernel function，指出该进程在内存的哪个部分，如果是个running的进程，一般就会显示"-"
    * SZ表示此进程用掉多少内存
    * WCHAN表示目前进程是否运行中，'-'表示正在运行中，'wait'表示等待中
* `TTY`：登陆者的终端机位置，若为远程登录则使用动态终端机接口(pts/n)
* `TIME`：使用掉的CPU时间，是此进程实际花费CPU运行的时间
* `CMD`：造成此程序的出发进程的命令为何

**`ps aux`打印参数说明：**

* `USER`：该进程所属的用户名
* `PID`：该进程的PID
* `%CPU`：该进程使用掉的CPU资源百分比
* `%MEN`：该进程占用的物理内存百分比
* `VSZ`：该进程使用掉的虚拟内存量
* `RSS`：该进程占用的固定内存量
* `TTY`：该进程是所属终端机，tty1~tty6是本地，pts/0是网络连接主机的进程(GNOME上的bash)
* `STAT`：该进程目前的状态，状态显示与ps -l的S标志相同
* `START`：该进程被触发的启动时间
* `TIME`：该进程实际使用CPU的时间
* `COMMAND`：该进程的实际命令
* 一般来说ps aux会按照PID的顺序来排序显示

## 4.7 pgrep

**格式：**

* `pgrep [-lon] <pattern>`

**参数说明：**

* `-f`：匹配完整的`command line`，默认情况下只能匹配15个字符
* `-l`：列出pid以及进程名
* `-o`：列出oldest的进程
* `-n`：列出newest的进程

**示例：**

* `pgrep sshd`
* `pgrep -l sshd`
* `pgrep -lo sshd`
* `pgrep -ln sshd`
* `pgrep -l ssh*`

## 4.8 pstree

**格式：**

* `pstree [-A|U] [-up]`

**参数说明：**

* `-A`：各进程树之间的连接以ASCII字符来连接(连接符号是ASCII字符)
* `-U`：各进程树之间的连接以utf8码的字符来连接，在某些终端接口下可能会有错误(连接符号是utf8字符，比较圆滑好看)
* `-p`：同时列出每个进程的PID
* `-u`：同时列出每个进程所属账号名称

## 4.9 taskset

查看或者设置进程的cpu亲和性

**格式：**

* `taskset [options] -p pid`
* `taskset [options] -p [mask|list] pid`

**参数说明：**

* `-c`：以列表格式显示cpu亲和性
* `-p`：指定进程的pid

**示例：**

* `taskset -p 152694`：查看pid为`152694`的进程的cpu亲和性，显示方式为掩码
* `taskset -c -p 152694`：查看pid为`152694`的进程的cpu亲和性，显示方式为列表
* `taskset -p f 152694`：设置pid为`152694`的进程的cpu亲和性，设置方式为掩码
* `taskset -c -p 0,1,2,3,4,5 152694`：设置pid为`152694`的进程的cpu亲和性，设置方式为列表

**什么是cpu亲和性掩码（16进制）**

* `cpu0 = 1`
* `cpu1 = cpu0 * 2 = 2`
* `cpu2 = cpu1 * 2 = 4`
* `cpu(n) = cpu(n-1) * 2`
* `mask = cpu0 + cpu1 + ... + cpu(n)`
* 举几个例子
    * `0 ==> 1 = 0x1`
    * `0,1,2,3 ==> 1 + 2 + 4 + 8 = 15 = 0xf`
    * `0,1,2,3,4,5 ==> 1 + 2 + 4 + 8 + 16 + 32 = 0x3f`
    * `2,3 ==> 4 + 8 = 12 = 0xc`
 
## 4.10 sudo

**注意，sudo本身是一个进程。比如用`sudo tail -f xxx`，在另一个会话中`ps aux | grep tail`会发现两个进程**

**配置文件：**

* `/etc/sudoers`

## 4.11 pkexec

允许授权用户以其他身份执行程序

**格式：**

* `pkexec [command]`

## 4.12 nohup

**`nohup`会忽略所有挂断（SIGHUP）信号**。比如通过`ssh`登录到远程服务器上，然后启动一个程序，当`ssh`登出时，这个程序就会随即终止。如果用`nohup`方式启动，那么当`ssh`登出时，这个程序仍然会继续运行

**格式：**

* `nohup command [args] [&]`

**参数说明：**

* `command`：要执行的命令
* `args`：命令所需的参数
* `&`：在后台执行

**示例：**

* `nohup java -jar xxx.jar &`

## 4.13 screen

**如果想在关闭`ssh`连接后继续运行启动的程序，可以使用`nohup`。如果要求下次`ssh`登录时，还能查看到上一次`ssh`登录时运行的程序的状态，那么就需要使用`screen`**

**格式：**

* `screen`
* `screen cmd [ args ]`
* `screen [–ls] [-r pid]`
* `screen -X -S <pid> kill`
* `screen -d -m cmd [ args ]`

**参数说明：**

* `cmd`：执行的命令
* `args`：执行的命令所需要的参数
* `-ls`：列出所有`screen`会话的详情
* `-r`：后接`pid`，进入指定进程号的`screen`会话
* `-d`：退出当前运行的session

**示例：**

* `screen`
* `screen -ls`
* `screen -r 123`

**会话管理：**

1. `Ctrl a + w`：显示所有窗口列表
1. `Ctrl a + Ctrl a`：切换到之前显示的窗口
1. `Ctrl a + c`：创建一个新的运行shell的窗口并切换到该窗口
1. `Ctrl a + n`：切换到下一个窗口
1. `Ctrl a + p`：切换到前一个窗口(与`Ctrl a + n`相对)
1. `Ctrl a + 0-9`：切换到窗口0..9
1. `Ctrl a + d`：暂时断开screen会话
1. `Ctrl a + k`：杀掉当前窗口

# 5 网络管理

## 5.1 netstat

**格式：**

* `netstat -[rn]`
* `netstat -[antulpc]`

**参数说明：**

1. **与路由有关的参数**
    * `-r`：列出路由表(route table)，功能如同route
    * `-n`：不使用主机名与服务名称，使用IP与port number，如同route -n
1. **与网络接口有关的参数**
    * `-a`：列出所有的连接状态，包括tcp/udp/unix socket等
    * `-t`：仅列出TCP数据包的连接
    * `-u`：仅列出UDP数据包的连接
    * `-l`：仅列出已在Listen(监听)的服务的网络状态
    * `-p`：列出PID与Program的文件名
    * `-c`：可以设置几秒种后自动更新一次，例如-c 5为每5s更新一次网络状态的显示

**与路由有关的显示参数说明**

* `Destination`：Network的意思
* `Gateway`：该接口的Gateway的IP，若为0.0.0.0，表示不需要额外的IP
* `Genmask`：就是Netmask，与Destination组合成为一台主机或网络
* `Flags`：共有多个标志来表示该网络或主机代表的意义
    * `U`：代表该路由可用
    * `G`：代表该网络需要经由Gateway来帮忙传递
    * `H`：代表该行路由为一台主机，而非一整个网络
    * `D`：代表该路由是由重定向报文创建的
    * `M`：代表该路由已被重定向报文修改
    * `Iface`：就是Interface(接口)的意思

**与网络接口有关的显示参数说明：**

* `Proto`：该连接的数据包协议，主要为TCP/UDP等数据包
* `Recv-Q`：非用户程序连接所复制而来的总byte数
* `Send-Q`：由远程主机发送而来，但不具有ACK标志的总byte数，亦指主动连接SYN或其他标志的数据包所占的byte数
* `Local Address`：本地端的地址，可以使IP，也可以是完整的主机名，使用的格式是"IP:port"
* `Foreign Address`：远程主机IP与port number
* `stat`：状态栏
    * `ESTABLISED`：已建立连接的状态
    * `SYN_SENT`：发出主动连接(SYN标志)的连接数据包
    * `SYN_RECV`：接收到一个要求连接的主动连接数据包
    * `FIN_WAIT1`：该套接字服务已中断，该连接正在断线当中
    * `FIN_WAIT2`：该连接已挂断，但正在等待对方主机响应断线确认的数据包中
    * `TIME_WAIT`：该连接已挂断，但socket还在网络上等待结束
    * `LISTEN`：通常在服务的监听port，可以使用-l参数查阅

netstat的功能就是查看网络的连接状态，而网络连接状态中，又以**"我目前开了多少port在等待客户端的连接"**以及**"目前我的网络连接状态中，有多少连接已建立或产生问题"**最常见

**示例：**

1. **`netstat -n | awk '/^tcp/ {++y[$NF]} END {for(w in y) print w, y[w]}'`**

## 5.2 tc

流量的处理由三种对象控制，它们是：`qdisc`（排队规则）、`class`（类别）和`filter`（过滤器）。

**格式：**

* `tc qdisc [ add | change | replace | link ] dev DEV [ parent qdisc-id | root ] [ handle qdisc-id ] qdisc [ qdisc specific parameters ]`
* `tc class [ add | change | replace ] dev DEV parent qdisc-id [ classid class-id ] qdisc [ qdisc specific parameters ]`
* `tc filter [ add | change | replace ] dev DEV [ parent qdisc-id | root ] protocol protocol prio priority filtertype [ filtertype specific parameters ] flowid flow-id`
* `tc [-s | -d ] qdisc show [ dev DEV ]`
* `tc [-s | -d ] class show dev DEV`
* `tc filter show dev DEV`

**参数说明：**

**示例：**

* `tc qdisc add dev em1 root netem delay 300ms`：设置网络延迟300ms
* `tc qdisc add dev em1 root netem loss 8% 20%`：设置8%~20%的丢包率 
* `tc qdisc del dev em1 root `：删除指定设置

## 5.3 lsof

**格式：**

* `lsof [-aU] [-u 用户名] [+d] [-i address]`

**参数说明：**

* `-a`：多项数据需要“同时成立”才显示结果
* `-U`：仅列出Unix like系统的socket文件类型
* `-u`：后面接username，列出该用户相关进程所打开的文件
* `+d`：后面接目录，及找出某个目录下面已经被打开的文件
* `-i`：后面接网络地址，格式如下
    * `[46][protocol][@hostname|hostaddr][:service|port]`
    * `46`：ipv4/ipv6
    * `protocol`：tcp/udp
    * `hostname`：主机名
    * `hostaddr`：主机ip
    * `service`：服务
    * `port`端口号

**示例：**

* `lsof -i 6tcp@localhost:22`
* `lsof -i 4tcp@127.0.0.1:22`
* `lsof -i tcp@127.0.0.1:22`
* `lsof -i tcp@localhost`
* `lsof -i tcp:22`

## 5.4 ss

`ss`是`Socket Statistics`的缩写。顾名思义，`ss`命令可以用来获取`socket`统计信息，它可以显示和`netstat`类似的内容。`ss`的优势在于它能够显示更多更详细的有关TCP和连接状态的信息，而且比`netstat`更快速更高效。

当服务器的socket连接数量变得非常大时，无论是使用`netstat`命令还是直接`cat /proc/net/tcp`，执行速度都会很慢。

`ss`快的秘诀在于，它利用到了TCP协议栈中`tcp_diag`。`tcp_diag`是一个用于分析统计的模块，可以获得Linux内核中第一手的信息，这就确保了`ss`的快捷高效

**格式：**

* `ss [-talspnr]`

**参数说明：**

* `-t`：列出tcp-socket
* `-u`：列出udp-socket
* `-a`：列出所有socket
* `-l`：列出所有监听的socket
* `-s`：仅显示摘要信息
* `-p`：显示用了该socket的进程
* `-n`：不解析服务名称
* `-r`：解析服务名称
* `-m`：显示内存占用情况
* `-h`：查看帮助文档
* `-i`：显示tcp-socket详情

**示例：**

* `ss -t -a`：显示所有tcp-socket
* `ss -ti -a`：显示所有tcp-socket以及详情
* `ss -u –a`：显示所有udp-socket
* `ss -lp | grep 22`：找出打开套接字/端口应用程序
* `ss -o state established`：显示所有状态为established的socket
* `ss -o state FIN-WAIT-1 dst 192.168.25.100/24`：显示出处于`FIN-WAIT-1`状态的，目标网络为`192.168.25.100/24`所有socket
* `ss -nap`
* `ss -naptu`

## 5.5 ip

### 5.5.1 ip address

具体用法参考`ip address help`

### 5.5.2 ip link

具体用法参考`ip link help`

**示例**

* `ip link`：查看所有网卡
* `ip link up`：查看up状态的网卡
* `ip -d link`：查看详细的信息
* `ip link set eth0 up`：开启网卡
* `ip link set eth0 down`：关闭网卡
* `cat /sys/class/net/xxx/carrier`：查看网卡是否插了网线（对应于`ip link`的`state UP`或`state DOWN`

### 5.5.3 ip route

具体用法参考`ip route help`

#### 5.5.3.1 route table

**linux最多可以支持255张路由表，每张路由表有一个`table id`和`table name`。其中有4张表是linux系统内置的**

* **`table id = 0`：系统保留**
* **`table id = 255`：本地路由表，表名为`local`**。像本地接口地址，广播地址，以及NAT地址都放在这个表。该路由表由系统自动维护，管理员不能直接修改
    * `ip r show table local`
* **`table id = 254`：主路由表，表名为`main`**。如果没有指明路由所属的表，所有的路由都默认都放在这个表里。一般来说，旧的路由工具（如`route`）所添加的路由都会加到这个表。`main`表中路由记录都是普通的路由记录。而且，使用`ip route`配置路由时，如果不明确指定要操作的路由表，默认情况下也是对主路由表进行操作
    * `ip r show table main`
* **`table id = 253`：称为默认路由表，表名为`default`**。一般来说默认的路由都放在这张表
    * `ip r show table default`

**此外：**

* 系统管理员可以根据需要自己添加路由表，并向路由表中添加路由记录
* 可以通过`/etc/iproute2/rt_tables`文件查看`table id`和`table name`的映射关系。
* 如果管理员新增了一张路由表，需要在`/etc/iproute2/rt_tables`文件中为新路由表添加`table id`和`table name`的映射
* 路由表存储于内存中，通过`procfs`文件系统对用户态露出，具体的文件位置是`/proc/net/route`

#### 5.5.3.2 route type

**`unicast`**：单播路由是路由表中最常见的路由。这是到目标网络地址的典型路由，它描述了到目标的路径。即使是复杂的路由（如下一跳路由）也被视为单播路由。如果在命令行上未指定路由类型，则假定该路由为单播路由

```sh
ip route add unicast 192.168.0.0/24 via 192.168.100.5
ip route add default via 193.7.255.1
ip route add unicast default via 206.59.29.193
ip route add 10.40.0.0/16 via 10.72.75.254
```

**`broadcast`**：此路由类型用于支持广播地址概念的链路层设备（例如以太网卡）。此路由类型仅在本地路由表中使用，通常由内核处理

```sh
ip route add table local broadcast 10.10.20.255 dev eth0 proto kernel scope link src 10.10.20.67
ip route add table local broadcast 192.168.43.31 dev eth4 proto kernel scope link src 192.168.43.14
```

**`local`**：当IP地址添加到接口时，内核会将条目添加到本地路由表中。这意味着IP是本地托管的IP

```sh
ip route add table local local 10.10.20.64 dev eth0 proto kernel scope host src 10.10.20.67
ip route add table local local 192.168.43.12 dev eth4 proto kernel scope host src 192.168.43.14
```

**`nat`**：当用户尝试配置无状态NAT时，内核会将此路由条目添加到本地路由表中

```sh
ip route add nat 193.7.255.184 via 172.16.82.184
ip route add nat 10.40.0.0/16 via 172.40.0.0
```

**`unreachable`**：当对路由决策的请求返回的路由类型不可达的目的地时，将生成ICMP unreachable并返回到源地址

```sh
ip route add unreachable 172.16.82.184
ip route add unreachable 192.168.14.0/26
ip route add unreachable 209.10.26.51
```

**`prohibit`**：当路由选择请求返回具有禁止路由类型的目的地时，内核会生成禁止返回源地址的ICMP

```sh
ip route add prohibit 10.21.82.157
ip route add prohibit 172.28.113.0/28
ip route add prohibit 209.10.26.51
```

**`blackhole`**：匹配路由类型为黑洞的路由的报文将被丢弃。没有发送ICMP，也没有转发数据包

```sh
ip route add blackhole default
ip route add blackhole 202.143.170.0/24
ip route add blackhole 64.65.64.0/18
```

**`throw`**：引发路由类型是一种便捷的路由类型，它会导致路由表中的路由查找失败，从而将路由选择过程返回到RPDB。当有其他路由表时，这很有用。请注意，如果路由表中没有默认路由，则存在隐式抛出，因此尽管合法，但是示例中第一个命令创建的路由是多余的

```sh
ip route add throw default
ip route add throw 10.79.0.0/16
ip route add throw 172.16.0.0/12
```

#### 5.5.3.3 route scope

**`global`**：全局有效

**`site`**：仅在当前站点有效（IPV6）

**`link`**：仅在当前设备有效

**`host`**：仅在当前主机有效

#### 5.5.3.4 route proto

**`proto`：表示路由的添加时机。可由数字或字符串表示，数字与字符串的对应关系详见`/etc/iproute2/rt_protos`**

1. **`redirect`**：表示该路由是因为发生`ICMP`重定向而添加的
1. **`kernel`**：该路由是内核在安装期间安装的自动配置
1. **`boot`**：该路由是在启动过程中安装的。如果路由守护程序启动，它将会清除这些路由规则
1. **`static`**：该路由由管理员安装，以覆盖动态路由

#### 5.5.3.5 route src

这被视为对内核的提示（用于回答：如果我要将数据包发往host X，我该用本机的哪个IP作为Source IP），该提示是关于要为该接口上的`传出`数据包上的源地址选择哪个IP地址

#### 5.5.3.6 参数解释

**`ip r show table local`参数解释（示例如下）**

1. 第一个字段指明该路由是用于`广播地址`、`IP地址`还是`IP范围`，例如
    * `local 192.168.99.35`表示`IP地址`
    * `broadcast 127.255.255.255`表示`广播地址`
    * `local 127.0.0.0/8 dev`表示`IP范围`
1. 第二个字段指明该路由通过哪个设备到达目标地址，例如
    * `dev eth0 proto kernel`
    * `dev lo proto kernel`
1. 第三个字段指明该路由的作用范围，例如
    * `scope host`
    * `scope link`
1. 第四个字段指明传出数据包的源IP地址
    * `src 127.0.0.1`

```sh
[root@tristan]$ ip route show table local
local 192.168.99.35 dev eth0  proto kernel  scope host  src 192.168.99.35 
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0.1 
broadcast 192.168.99.255 dev eth0  proto kernel  scope link  src 192.168.99.35 
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1 
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1 
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
```

### 5.5.4 ip rule

基于策略的路由比传统路由在功能上更强大，使用更灵活，它使网络管理员不仅能够根据目的地址而且能够根据报文大小、应用或IP源地址等属性来选择转发路径。简单地来说，linux系统有多张路由表，而路由策略会根据一些条件，将路由请求转向不同的路由表。例如源地址在某些范围走路由表A，另外的数据包走路由表，类似这样的规则是有路由策略rule来控制

在linux系统中，一条路由策略`rule`主要包含三个信息，即`rule`的优先级，条件，路由表。其中rule的优先级数字越小表示优先级越高，然后是满足什么条件下由指定的路由表来进行路由。**在linux系统启动时，内核会为路由策略数据库配置三条缺省的规则，即`rule 0`，`rule 32766`，`rule 32767`（数字是rule的优先级），具体含义如下**：

1. **`rule 0`**：匹配任何条件的数据包，查询路由表`local（table id = 255）`。`rule 0`非常特殊，不能被删除或者覆盖。
1. **`rule 32766`**：匹配任何条件的数据包，查询路由表`main（table id = 254）`。系统管理员可以删除或者使用另外的策略覆盖这条策略
1. **`rule 32767`**：匹配任何条件的数据包，查询路由表`default（table id = 253）`。对于前面的缺省策略没有匹配到的数据包，系统使用这个策略进行处理。这个规则也可以删除
* 在linux系统中是按照rule的优先级顺序依次匹配。假设系统中只有优先级为`0`，`32766`及`32767`这三条规则。那么系统首先会根据规则`0`在本地路由表里寻找路由，如果目的地址是本网络，或是广播地址的话，在这里就可以找到匹配的路由；如果没有找到路由，就会匹配下一个不空的规则，在这里只有`32766`规则，那么将会在主路由表里寻找路由；如果没有找到匹配的路由，就会依据`32767`规则，即寻找默认路由表；如果失败，路由将失败

**示例：**

```sh
# 增加一条规则，规则匹配的对象是所有的数据包，动作是选用路由表1的路由，这条规则的优先级是32800
$ ip rule add [from 0/0] table 1 pref 32800

# 增加一条规则，规则匹配的对象是IP为192.168.3.112, tos等于0x10的包，使用路由表2，这条规则的优先级是1500，动作是丢弃。
$ ip rule add from 192.168.3.112/32 [tos 0x10] table 2 pref 1500 prohibit
```

### 5.5.5 ip netns

```sh
Usage: ip netns list
       ip netns add NAME
       ip netns set NAME NETNSID
       ip [-all] netns delete [NAME]
       ip netns identify [PID]
       ip netns pids NAME
       ip [-all] netns exec [NAME] cmd ...
       ip netns monitor
       ip netns list-id
```

**示例：**

* `ip netns list`：列出网络命名空间（只会从`/var/run/netns`下读取）
* `ip netns exec test-ns ifconfig`：在网络命名空间`test-ns`中执行`ifconfig`

**与nsenter的区别**：由于`ip netns`只从`/var/run/netns`下读取网络命名空间，而`nsenter`默认会读取`/proc/${pid}/ns/net`。但是`docker`会隐藏容器的网络命名空间，即默认不会在`/var/run/netns`目录下创建命名空间，因此如果要使用`ip netns`进入到容器的命名空间，还需要做个软连接

```sh
pid=$(docker inspect -f '{{.State.Pid}}' ${container_id})
mkdir -p /var/run/netns/
ln -sfT /proc/$pid/ns/net /var/run/netns/$container_id
```

## 5.6 iptables

### 5.6.1 规则的查看

**格式：**

* `iptables [-S] [-t tables] [-L] [-nv]`

**参数说明：**

* `-S`：输出指定table的规则，若没有指定table，则输出所有的规则，类似`iptables-save`
* `-t`：后面接table，例如nat或filter，若省略此项目，则使用默认的filter
* `-L`：列出目前的table的规则
* `-n`：不进行IP与HOSTNAME的反查，显示信息的速度回快很多
* `-v`：列出更多的信息，包括通过该规则的数据包总数，相关的网络接

**输出信息介绍：**

* 每一个Chain就是每个链，Chain所在的括号里面的是默认的策略(即没有规则匹配时采取的操作(target))
* `target`：代表进行的操作
    * **`ACCEPT`**：表示放行
    * **`DROP`**：表示丢弃
    * **`QUEUE`**：将数据包传递到用户空间
    * **`RETURN`**：表示停止遍历当前链，并在上一个链中的下一个规则处恢复（假设在`Chain A`中调用了`Chain B`，`Chain B RETURN`后，继续`Chain A`的下一个规则）
    * **还可以是一个自定义的Chain**
* `port`：代表使用的数据包协议，主要有TCP、UDP、ICMP3中数据包
* `opt`：额外的选项说明
* `source`：代表此规则是针对哪个来源IP进行限制
* `destination`：代表此规则是针对哪个目标IP进行限制

**示例：**

* `iptables -nL`
* `iptables -t nat -nL`

由于`iptables`的上述命令的查看只是做格式化的查阅，要详细解释每个规则可能会与原规则有出入，因此，建议使用`iptables-save`这个命令来查看防火墙规则

**格式：**

* `iptables-save [-t table]`

**参数说明：**

* `-t`：可以针对某些表格来输出，例如仅针对NAT或Filter等

**输出信息介绍：**

* 星号开头的指的是表格，这里为Filter
* 冒号开头的指的是链，3条内建的链，后面跟策略
* 链后面跟的是`[Packets:Bytes]`，分别表示通过该链的数据包/字节的数量

### 5.6.2 规则的清除

**格式：**

* `iptables [-t tables] [-FXZ] [chain]`

**参数说明：**

* `-F [chain]`：清除指定chain或者所有chian中的所有的已制定的规则
* `-X [chain]`：清除指定`user-defined chain`或所有`user-defined chain`
* `-Z [chain]`：将指定chain或所有的chain的计数与流量统计都归零

### 5.6.3 定义默认策略

当数据包不在我们设置的规则之内时，该数据包的通过与否都以Policy的设置为准

**格式：**

* `iptables [-t nat] -P [INPUT,OUTPUT,FORWARD] [ACCEPT,DROP]`

**参数说明：**

* `-P`：定义策略(Policy)
    * `ACCEPT`：该数据包可接受
    * `DROP`：该数据包直接丢弃，不会让Client知道为何被丢弃

**示例：**

* `iptables -P INPUT DROP`
* `iptables -P OUTPUT ACCEPT`
* `iptables -P FORWARD ACCEPT`

### 5.6.4 数据包的基础对比：IP、网络及接口设备

**格式：**

* `iptables [-t tables] [-AI chain] [-io ifname] [-p prop] [-s ip/net] [-d ip/net] -j [ACCEPT|DROP|REJECT|LOG]`

**参数说明：**

* `-t tables`：指定tables，默认的tables是`filter`
* `-AI chain`：针对某条链进行规则的"插入"或"累加"
    * `-A chain`：新增加一条规则，该规则增加在原规则后面，例如原来有4条规则，使用-A就可以加上第五条规则
    * `-I chain [rule num]`：插入一条规则，可以指定插入的位置。如果没有指定此规则的顺序，默认插入变成第一条规则
    * `链`：可以是内建链（`INPUT`、`OUTPUT`、`FORWARD`、`PREROUTING`、`POSTROUTING`）；也可以是自定义链
* `-io ifname`：设置数据包进出的接口规范
    * `-i`：数据包所进入的那个网络接口，例如eth0，lo等，需要与INPUT链配合
    * `-o`：数据包所传出的网络接口，需要与OUTPUT配合
* `-p prop`：设置此规则适用于哪种数据包格式
    * 主要的数据包格式有：tcp、udp、icmp以及all
* `-s ip/net`：设置此规则之数据包的来源地，可指定单纯的IP或网络
    * `ip`：例如`192.168.0.100`
    * `net`：例如`192.168.0.0/24`、`192.168.0.0/255.255.255.0`均可
    * **若规范为"不许"时，加上`!`即可，例如`! -s 192.168.100.0/24`**
* `-d ip/net`：同-s，只不过这里是目标的
* `-j target`：后面接`target`
    * `ACCEPT`
    * `DROP`
    * `QUEUE`
    * `RETURN`
    * **其他Chain**
    * **规则的匹配过程类似于函数栈，从一个链跳到另一个链相当于函数调用。某些target会停止匹配过程，比如常见的`ACCEPT`、`DROP`、`SNAT`、`MASQUERADE`等等；某些target不会停止匹配过程，比如当target是另一个`Chain`时，或者常见的`LOG`、`ULOG`、`TOS`等**
* **重要的原则：没有指定的项目，就表示该项目完全接受**
    * 例如`-s`和`-d`不指定，就表示来源或去向的任意IP/网络都接受

**示例：**

* `iptables -A INPUT -i lo -j ACCEPT`：不论数据包来自何处或去向哪里，只要是lo这个接口，就予以接受，这就是所谓的信任设备
* `iptables -A INPUT -i eth1 -j ACCEPT`：添加接口为eth1的网卡为信任设备
* `iptables -A INPUT -s 192.168.2.200 -j LOG`：该网段的数据包，其相关信息就会被写入到内核日志文件中，即`/var/log/messages`，然后，该数据包会继续进行后续的规则比对(这一点与其他规则不同)
* 配置打印日志的规则（这些规则要放在第一条，否则命中其他规则时，当前规则就不执行了）
    * `iptables -I INPUT -p icmp -j LOG --log-prefix "liuye-input: "`
    * `iptables -I FORWARD -p icmp -j LOG --log-prefix "liuye-forward: "`
    * `iptables -I OUTPUT -p icmp -j LOG --log-prefix "liuye-output: "`
    * `iptables -t nat -I PREROUTING -p icmp -j LOG --log-prefix "liuye-prerouting: "`
    * `iptables -t nat -I POSTROUTING -p icmp -j LOG --log-prefix "liuye-postrouting: "`

### 5.6.5 TCP、UDP的规则：针对端口设置

TCP与UDP比较特殊的就是端口(port)，在TCP方面则另外有所谓的连接数据包状态，包括最常见的SYN主动连接的数据包格式

**格式：**

* `iptables [-AI 链] [-io 网络接口] [-p tcp|udp] [-s 来源IP/网络] [--sport 端口范围] [-d 目标IP/网络] [--dport 端口范围] --syn -j [ACCEPT|DROP|REJECT]`

**参数说明：**

* `--sport 端口范围`：限制来源的端口号码，端口号码可以是连续的，例如1024:65535
* `--dport 端口范围`：限制目标的端口号码
* `--syn`：主动连接的意思
* **与之前的命令相比，就是多了`--sport`以及`--dport`这两个选项，因此想要使用`--dport`或`--sport`必须加上`-p tcp`或`-p udp`才行**

**示例：**

* `iptables -A INPUT -i eth0 -p tcp --dport 21 -j DROP`：想要进入本机port 21的数据包都阻挡掉
* `iptables -A INPUT -i eth0 -p tcp --sport 1:1023 --dport 1:1023 --syn -j DROP`：来自任何来源port 1:1023的主动连接到本机端的1:1023连接丢弃

### 5.6.6 iptables匹配扩展

`iptables`可以使用扩展的数据包匹配模块。当指定`-p`或`--protocol`时，或者使用`-m`或`--match`选项，后跟匹配的模块名称；之后，取决于特定的模块，可以使用各种其他命令行选项。可以在一行中指定多个扩展匹配模块，并且可以在指定模块后使用`-h`或`--help`选项来接收特定于该模块的帮助文档（`iptables -m comment -h`，输出信息的最下方有`comment`模块的参数说明）

**常用模块**，详细内容请参考[Match Extensions](https://linux.die.net/man/8/iptables)

1. `comment`：增加注释
1. `conntrack`：与连接跟踪结合使用时，此模块允许访问比“状态”匹配更多的连接跟踪信息。（仅当iptables在支持该功能的内核下编译时，此模块才存在）
1. `tcp`
1. `udp`

### 5.6.7 iptables目标扩展

iptables可以使用扩展目标模块，并且可以在指定目标后使用`-h`或`--help`选项来接收特定于该目标的帮助文档（`iptables -j DNAT -h`）

**常用（可以通过`man iptables`或`man 8 iptables-extensions`，并搜索关键词`target`）：**

1. `ACCEPT`
1. `DROP`
1. `RETURN`
1. `REJECT`
1. `DNAT`
1. `SNAT`
1. `MASQUERADE`：用于实现自动化SNAT，若出口ip经常变化的话，可以通过该目标来实现SNAT

### 5.6.8 ICMP数据包规则的比对：针对是否响应ping来设计

**格式：**

* `iptables -A INPUT [-p icmp] [--icmp-type 类型] -j ACCEPT`

**参数说明：**

* `--icmp-type`：后面必须要接ICMP的数据包类型，也可以使用代号

## 5.7 bridge

### 5.7.1 bridge link

Bridge port

**示例：**

1. `bridge link show`

### 5.7.2 bridge fdb

Forwarding Database entry

**示例：**

1. `bridge fdb show`

### 5.7.3 bridge mdb

Multicast group database entry

### 5.7.4 bridge vlan

VLAN filter list

### 5.7.5 bridge monitor

## 5.8 route

**格式：**

* `route [-nee]`
* `route add [-net|-host] [网络或主机] netmask [mask] [gw|dev]`
* `route del [-net|-host] [网络或主机] netmask [mask] [gw|dev]`

**参数说明：**

* `-n`：不要使用通信协议或主机名，直接使用IP或port number，即在默认情况下，route会解析出该IP的主机名，若解析不到则会有延迟，因此一般加上这个参数
* `-ee`：显示更详细的信息
* `-net`：表示后面接的路由为一个网络
* `-host`：表示后面接的为连接到单个主机的路由
* `netmask`：与网络有关，可设置netmask决定网络的大小
* `gw`：gateway的缩写，后接IP数值
* `dev`：如果只是要制定由哪块网卡连接出去，则使用这个设置，后接网卡名，例如eth0等

**打印参数说明：**

* **Destination、Genmask**：这两个参数就分别是network与netmask
* **Gateway**：该网络通过哪个Gateway连接出去，若显示`0.0.0.0(default)`表示该路由直接由本级传送，也就是通过局域网的MAC直接传送，如果显示IP的话，表示该路由需要经过路由器(网关)的帮忙才能发送出去
* **Flags**：
    * `U(route is up)`：该路由是启动的
    * `H(target is a host)`：目标是一台主机而非网络
    * `G(use gateway)`：需要通过外部的主机来传递数据包
    * `R(reinstate route for dynamic routing)`：使用动态路由时，恢复路由信息的标志
    * `D(Dynamically installed by daemon or redirect)`：动态路由
    * `M(modified from routing daemon or redirect)`：路由已经被修改了
    * `!(reject route)`：这个路由将不会被接受
* **Iface**：该路由传递数据包的接口

**示例：**

* `route -n`
* `route add -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`
* `route del -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`

## 5.9 nsenter

nsenter用于在某个网络命名空间下执行某个命令。例如某些docker容器是没有curl命令的，但是又想在docker容器的环境下执行，这个时候就可以在宿主机上使用nsenter

**格式：**

* `nsenter -t <pid> -n <cmd>`

**参数说明：**

* `-t`：后接进程id
* `-n`：后接需要执行的命令

**示例：**

* `nsenter -t 123 -n curl baidu.com`

## 5.10 tcpdump

**格式：**

* `tcpdump [-AennqX] [-i 接口] [port 端口号] [-w 存储文件名] [-c 次数] [-r 文件] [所要摘取数据包的格式]`

**参数说明：**

* `-A`：数据包的内容以ASCII显示，通常用来抓取WWW的网页数据包数据
* `-e`：使用数据链路层(OSI第二层)的MAC数据包数据来显示
* `-n`：直接以IP以及port number显示，而非主机名与服务名称
* `-q`：仅列出较为简短的数据包信息，每一行的内容比较精简
* `-X`：可以列出十六进制(hex)以及ASCII的数据包内容，对于监听数据包很有用
* `-i`：后面接要监听的网络接口，例如eth0等
* `port`：后接要监听的端口号，例如22等
* `-w`：将监听得到的数据包存储下来
* `-r`：从后面接的文件将数据包数据读出来
* `-c`：监听数据包数，没有这个参数则会一直监听，直到[ctrl]+C
* `-vv/-vvv`：输出更多的信息，配合`-w`使用时，会显示目前监听的多少数据包
* 此外，还可以用`and`拼接多个条件

**显示格式说明：**

* `src > dst: flags data-seqno ack window urgent options`
* `src`: 源ip/port（或域名）
* `dst`: 宿ip/port（或域名）
* `flags`: TCP标志位的组合
    * `S`: `SYNC`
    * `F`: `FIN`
    * `P`: `PUSH`
    * `R`: `RST`
    * `U`: `URG`
    * `W`: `ECN CWR`
    * `E`: `ECN-Echo`
    * `.`: `ACK`
    * `none`: 无任何标志位
* `data-seqno`: 数据包的序号，可能是一个或多个（`1:4`）
* `ack`: 表示期望收到的下一个数据包的序号
* `window`: 接收缓存的大小
* `urgent`: 表示当前数据包是否包含紧急数据
* `option`: 用`<>`包围的部分

**示例：**

* `tcpdump -i lo0 port 22 -w output7.cap`
* `tcpdump -i eth0 host www.baidu.com`
* `tcpdump -i any -w output1.cap`
* `tcpdump -n -i any -e icmp and host www.baidu.com`

### 5.10.1 tcpdump条件表达式

该表达式用于决定哪些数据包将被打印。如果不给定条件表达式，网络上所有被捕获的包都会被打印，否则，只有满足条件表达式的数据包被打印

表达式由一个或多个`表达元`组成（表达元, 可理解为组成表达式的基本元素）。一个表达元通常由一个或多个修饰符`qualifiers`后跟一个名字或数字表示的`id`组成（即：`qualifiers id`）。有三种不同类型的修饰符：`type`，`direction`以及`protocol`

**表达元格式：`[protocol] [direction] [type] id`**

* **type**：包括`host`、`net`、`port`、`portrange`。默认值为`host`
* **direction**：包括`src`、`dst`、`src and dst`、`src or dst`4种可能的方向。默认值为`src or dst`
* **protocol**：包括`ether`、`fddi`、`tr`、`wlan`、`ip`、`ip6`、`arp`、`rarp`、`decnet`、`tcp`、`upd`等等。默认包含所有协议
    * **其中`protocol`要与`type`相匹配，比如当`protocol`是`tcp`时，那么`type`就不能是`host`或`net`，而应该是`port`或`portrange`**
* **逻辑运算**：`条件表达式`可由多个`表达元`通过`逻辑运算`组合而成。逻辑运算包括（`!`或`not`）、（`&&`或`and`）、（`||`或`or`）三种逻辑运算

**示例**

* `tcp src port 123`
* `tcp src portrange 100-200`
* `host www.baidu.com and port 443`

### 5.10.2 tips

如何查看具体的协议，例如ssh协议

利用wireshark

1. 任意选中一个`length`不为`0`的数据包，右键选择解码（`decode as`），右边`Current`一栏，选择对应的协议即可

### 5.10.3 如何使用tcpdump抓dockerd的http协议的数据

dockerd使用的是域套接字，对应的套接字文件是`/var/run/docker.sock`，而域套接字是不经过网卡设备的，因此tcpdump无法直接抓取相应的数据

**方式1：改变client的访问方式**

```sh
# 在终端1执行，监听本机的18080，然后将流量转到docker的域套接字
# 两个-d参数会输出fatel、error以及notice级别的信息
socat -d -d TCP-LISTEN:18080,fork,bind=127.0.0.1 UNIX:/var/run/docker.sock

# 在终端2执行tcpdump进行抓包
tcpdump -i lo -netvv port 18080 -w file1.cap

# 在终端3执行docker命令
docker -H tcp://localhost:18080 images
```

**方式2：不改变client的访问方式**

```sh
# 在终端1执行，mv命令修改原始域套接字的文件名，这个操作不会改变文件的fd，因此，在移动后，dockerd监听的套接字是/var/run/docker.sock.original
sudo mv /var/run/docker.sock /var/run/docker.sock.original
sudo socat TCP-LISTEN:18081,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock.original

# 在终端2执行
sudo socat UNIX-LISTEN:/var/run/docker.sock,fork TCP-CONNECT:127.0.0.1:18081

# 在终端3执行tcpdump进行抓包
tcpdump -i lo -vv port 18081 -w file2.cap

# 在终端3执行docker命令
docker -H tcp://localhost:18081 images
```

## 5.11 tcpkill

`tcpkill`用于杀死tcp连接，语法与`tcpdump`基本类似。其工作原理非常简单，首先会监听相关的数据报文，获取了`sequence number`之后，然后发起`Reset`报文。因此，当且仅当连接有报文交互的时候，`tcpkill`才能起作用

**如何安装：**

```sh
yum install -y epel-release
yum install -y dsniff
```

**格式：**

* `tcpkill [-i interface] [-1...9] expression`

**参数说明：**

* `-i`：指定网卡
* `-1...9`：优先级，优先级越高越容易杀死
* `expression`：表达元，与tcpdump类似

**示例：**

* `tcpkill -9 -i any host 127.0.0.1 and port 22`

## 5.12 socat

**格式：**

* `socat [options] <address> <address>`
* 其中这2个`address`就是关键了，`address`类似于一个文件描述符，Socat所做的工作就是在2个`address`指定的描述符间建立一个 `pipe`用于发送和接收数据

**参数说明：**

* `address`：可以是如下几种形式之一
    * `-`：表示标准输入输出
    * `/var/log/syslog`：也可以是任意路径，如果是相对路径要使用`./`，打开一个文件作为数据流。
    * `TCP:127.0.0.1:1080`：建立一个TCP连接作为数据流，TCP也可以替换为UDP
    * `TCP-LISTEN:12345`：建立TCP监听端口，TCP也可以替换为UDP
    * `EXEC:/bin/bash`：执行一个程序作为数据流。

**示例：**

* `socat - /var/www/html/flag.php`：通过Socat读取文件，绝对路径
* `socat - ./flag.php`：通过Socat读取文件，相对路径
* `echo "This is Test" | socat - /tmp/hello.html`：写入文件
* `socat TCP-LISTEN:80,fork TCP:www.baidu.com:80`：将本地端口转到远端
* `socat TCP-LISTEN:12345 EXEC:/bin/bash`：在本地开启shell代理

## 5.13 dhclient

**格式：**

* `dhclient [-dqr]`

**参数说明：**

* `-d`：总是以前台方式运行程序
* `-q`：安静模式，不打印任何错误的提示信息
* `-r`：释放ip地址

**示例：**

* `dhclient`：获取ip
* `dhclient -r`：释放ip

## 5.14 arp

**示例：**

* `arp`：查看arp缓存
* `arp -n`：查看arp缓存，显示ip不显示域名
* `arp 192.168.56.1`：查看`192.168.56.1`这个ip的mac地址

## 5.15 [arp-scan](https://github.com/royhills/arp-scan)

**如何安装：**

```sh
yum install -y git
git clone https://github.com/royhills/arp-scan.git

cd arp-scan

yum install -y autoconf automake libtool
autoreconf --install

yum install -y libpcap.x86_64 libpcap-devel.x86_64
./configure

yum install -y make
make

make install
```

**示例：**

* `arp-scan -l`
* `arp-scan 10.0.2.0/24`
* `arp-scan -I enp0s8 -l`
* `arp-scan -I enp0s8 192.168.56.1/24`

## 5.16 ping

**参数说明：**

* `-c`：后接发包次数
* `-s`：指定数据大小
* `-M [do|want|dont]`：设置MTU策略，`do`表示不允许分片；`want`表示当数据包比较大时可以分片；`dont`表示不设置`DF`标志位

**示例：**

* `ping -c 3 www.baidu.com`
* `ping -s 1460 -M do baidu.com`：发送大小包大小是1460（+28）字节，且禁止分片

## 5.17 arping

**格式：**

* `arping [-fqbDUAV] [-c count] [-w timeout] [-I device] [-s source] destination`

**参数说明：**

* `-c`：指定发包次数
* `-b`：持续用广播的方式发送request
* `-w`：指定超时时间
* `-I`：指定使用哪个以太网设备
* `-D`：开启地址冲突检测模式

**示例：**

* `arping -c 1 -w 1 -I eth0 -b -D 192.168.1.1`：该命令可以用于检测局域网是否存在IP冲突
    * 若该命令行返回0：说明不存在冲突；否则存在冲突

**-D参数为啥能够检测ip冲突**

* 环境说明
    * 机器A，ip为：`192.168.2.2/24`，mac地址为`68:ed:a4:39:92:4b`
    * 机器B，ip为：`192.168.2.2/24`，mac地址为`68:ed:a4:39:91:e6`
    * 路由器，ip为：`192.168.2.1/24`，mac地址为`c8:94:bb:af:bd:8c`
* 在机器A执行`arping -c 1 -w 1 -I eno1 -b 192.168.2.2`，分别在机器A、机器B上抓包，抓包结果如下
    * ![arping-1](/images/Linux-常用命令/arping-1.png)
    * ![arping-2](/images/Linux-常用命令/arping-2.png)
    * arp-reply发送到路由器后，路由器不知道将数据包转发给谁，就直接丢弃了
* 在机器A执行`arping -c 1 -w 1 -I eno1 -D -b 192.168.2.2`，分别在机器A、机器B上抓包，抓包结果如下
    * ![arping-3](/images/Linux-常用命令/arping-3.png)
    * ![arping-3](/images/Linux-常用命令/arping-4.png)
    * arp-reply直接指定了目标机器的mac地址，因此直接送达机器A

## 5.18 hping3

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装hping3
yum install -y hping3
```

**参数说明：**

* `-c`：发送、接收数据包的数量（如果只发包不收包是不会停止的）
* `-d`：指定数据包大小（不包含header）
* `-S`：只发送syn数据包
* `-w`：设置tcp窗口大小
* `-p`：目的端口
* `--flood`：洪范模式，尽可能快地发送数据包
* `--rand-source`：使用随机ip作为源IP

**示例：**

* `hping3 -c 10000 -d 120 -S -w 64 -p 21 --flood --rand-source www.baidu.com`

# 6 运维监控

## 6.1 ssh

**格式：**

* `ssh [-f] [-o options] [-p port] [account@]host [command]`

**参数说明：**

* `-f`：需要配合后面的[command]，不登录远程主机直接发送一个命令过去而已
* `-o`：后接`options`
    * `ConnectTimeout=<seconds>`：等待连接的秒数，减少等待的事件
    * `StrictHostKeyChecking=[yes|no|ask]`：默认是ask，若要让public key主动加入known_hosts，则可以设置为no即可
* `-p`：后接端口号，如果sshd服务启动在非标准的端口，需要使用此项目

**示例：**

* `ssh 127.0.0.1`：由于SSH后面没有加上账号，因此默认采用当前的账号来登录远程服务器
* `ssh student@127.0.0.1`：账号为该IP的主机上的账号，而非本地账号哦
* `ssh student@127.0.0.1 find / &> ~/find1.log`
* `ssh -f student@127.0.0.1 find / &> ~/find1.log`：会立即注销127.0.0.1，find在远程服务器运行

### 6.1.1 免密登录

**Client端步骤：**

1. `ssh-keygen [-t rsa|dsa]`
1. `scp ~/.ssh/id_rsa.pub [account@]host:~`

**Server端步骤：**

1. `mkdir ~/.ssh; chmod 700 .ssh`，若不存在`~/.ssh`文件夹，则创建
1. `cat id_rsa.pub >> .ssh/authorized_keys`
1. `chmod 644 .ssh/authorized_keys`

## 6.2 scp

**格式：**

* `scp [-pPr] [-l 速率] local_file [account@]host:dir`
* `scp [-pPr] [-l 速率] [account@]host:file local_dir`

**参数说明：**

* `-p`：保留源文件的权限信息
* `-P`：指定端口号
* `-r`：复制来源为目录时，可以复制整个目录(含子目录)
* `-l`：可以限制传输速率，单位Kbits/s

**示例：**

* `scp /etc/hosts* student@127.0.0.1:~`
* `scp /tmp/Ubuntu.txt root@192.168.136.130:~/Desktop`
* `scp -P 16666 root@192.168.136.130:/tmp/test.log ~/Desktop`：指定主机`192.168.136.130`的端口号为16666

## 6.3 watch

**格式：**

* `watch [option] [cmd]`

**参数说明：**

* `-n`：watch缺省该参数时，每2秒运行一下程序，可以用`-n`或`-interval`来指定间隔的时间
* `-d`：`watch`会高亮显示变化的区域。`-d=cumulative`选项会把变动过的地方(不管最近的那次有没有变动)都高亮显示出来
* `-t`：关闭watch命令在顶部的时间间隔命令，当前时间的输出

**示例：**

* `watch -n 1 -d netstat -ant`：每隔一秒高亮显示网络链接数的变化情况
* `watch -n 1 -d 'pstree | grep http'`：每隔一秒高亮显示http链接数的变化情况
* `watch 'netstat -an | grep :21 | grep <ip> | wc -l'`：实时查看模拟攻击客户机建立起来的连接数
* `watch -d 'ls -l | grep scf'`：监测当前目录中 scf' 的文件的变化
* `watch -n 10 'cat /proc/loadavg'`：10秒一次输出系统的平均负载

## 6.4 top

**格式：**

* `top [-H] [-p <pid>]`

**参数说明：**

* `-H`：显示线程
* `-p`：查看指定进程

**示例：**

* `top -p 123`：查看进程号为123的进程
* `top -Hp 123`：查看进程号为123以及该进程的所有线程

**打印参数说明：**

* **第一行**：
    * 目前的时间
    * 开机到目前为止所经过的时间
    * 已经登录的人数
    * 系统在1，5，15分钟的平均工作负载
* **第二行**：显示的是目前进程的总量，与各个状态下进程的数量
* **第三行**：显示的CPU整体负载，特别注意wa，这个代表的是I/Owait，通常系统变慢都是I/O产生的问题比较大
* **第四五行**：物理内存与虚拟内存的使用情况，注意swap的使用量越少越好，大量swap被使用说明系统物理内存不足
* **第六行**：top进程中，输入命令时显示的地方
* **第七行以及以后**：每个进程的资源使用情况
    * PID：每个进程的ID
    * USER：进程所属用户名称
    * PR：Priority，优先顺序，越小优先级越高
    * NI：Nice，与Priority有关，越小优先级越高
    * %CPU：CPU使用率
    * %MEN：内存使用率
    * TIME+：CPU使用时间累加
    * COMMAND
* **top默认使用CPU使用率作为排序的终点，键入`h`显示帮助菜单**
* **排序顺序**
    * `P`：按CPU使用量排序，默认从大到小，`R`更改为从小到大
    * `M`：按内存使用量排序，默认从大到小，`R`更改为从小到大
    * `T`：按使用时间排序，默认从大到小，`R`更改为从小到大
* **其他功能按键**
    * `1`：概览信息中分别展示每个核的使用状态
    * `2`：概览信息和只展示所有核的平均使用状态
    * `x`：高亮排序的列
    * `-R`：反转排序
    * `n [num]`：只显示前几列，当num=0时，表示无限制
    * `l`：调整cpu负载信息的展示方式
    * `t`：调整cpu以及任务详情的展示方式
    * `m`：调整memory详情的展示方式
    * `c`：展示完整command
    * `V`：以树型格式展示command
    * `H`：展示线程

## 6.5 slabtop

`slabtop`用于展示内核的`slab cache`相关信息

**示例：**

* `slabtop`

## 6.6 sar

sar是由有类似日志切割的功能的，它会依据`/etc/cron.d/sysstat`中的计划任务，将日志放入`/var/log/sa/`中

**格式：**

* `sar [ 选项 ] [ <时间间隔> [ <次数> ] ]`

**参数说明：**

* `-u`：查看cpu使用率
* `-q`：查看cpu负载
* `-r`：查看内存使用情况
* `-b`：I/O 和传输速率信息状况
* `-f <filename>`：指定sa日志文件
* `-n [关键词]`：查看网络相关的情况，其中关键词可以是
    * `DEV`：网卡
    * `SOCK`：套接字
    * `IP`：IP流
    * `TCP`：TCP流
    * `UDP`：UDP流

**示例：**

* `sar -u 1 10`
* `sar -n DEV 1`

## 6.7 tsar

**格式：**

* `tsar [-l]`

**参数说明：**

* `-l`：查看实时数据

**示例：**

* `tsar -l`

## 6.8 vmstat

**格式：**

* `vmstat [options] [delay [count]]`

**参数说明：**

* `-a, --active`：显示活跃和非活跃内存
* `-f, --forks`：从系统启动至今的fork数量，linux下创建进程的系统调用是fork
    * 信息是从`/proc/stat`中的processes字段里取得的
* `-m, --slabs`：查看系统的slab信息
* `-s, --stats`：查看内存使用的详细信息
* `-d, --disk`：查看磁盘使用的详细信息
* `-D, --disk-sum`         summarize disk statistics
* `-p, --partition <dev>`：查看指定分区的详细信息
* `-S, --unit <char>`：指定输出单位，只支持`k/K`以及`m/M`，默认是`K`
* `-w, --wide`：输出更详细的信息
* `-t, --timestamp`：输出时间戳
* `delay`：采样间隔
* `count`：采样次数

**输出信息介绍：**

* `process`
    * `r`：运行中的进程数量（`running`或`waiting`状态
    * `b`：阻塞中的进程数量
* `memory`
    * `swpd`：虚拟内存总量
    * `free`：空闲内存总量
    * `buff`：被用作buffer的内存总量
    * `cache`：被用作cache的内存总量
    * `inact`：无效内存总量（需要加`-a`参数）
    * `active`：有效内存总量（需要加`-a`参数）
* `swap`
    * `si`：每秒从磁盘交换的内存总量
    * `so`：每秒交换到磁盘的内存总量
* `io`
    * `bi`：每秒从块设备接收的block数量
    * `bo`：每秒写入块设备的block数量
* `system`
    * `in`：每秒中断次数，包括时钟中断
    * `cs`：每秒上下文切换的次数
* `cpu`
    * `us`：用户cpu时间
    * `sy`：系统（内核）cpu时间
    * `id`：空闲cpu时间
    * `wa`：等待IO的cpu时间
    * `st`：从虚拟机窃取的时间

**示例：**

* `vmstat`
* `vmstat 2`
* `vmstat 2 5`
* `vmstat -s`
* `vmstat -s -S m`
* `vmstat -f`
* `vmstat -d`
* `vmstat -p /dev/sda1`
* `vmstat -m`

## 6.9 mpstat

`mpstat`（`multiprocessor statistics`）是实时监控工具，报告与cpu的一些统计信息这些信息都存在`/proc/stat`文件中，在多cpu系统里，其不但能查看所有的cpu的平均状况的信息，而且能够有查看特定的cpu信息，`mpstat`最大的特点是可以查看多核心的cpu中每个计算核心的统计数据；而且类似工具`vmstat`只能查看系统的整体cpu情况

**输出信息介绍：**

* **`%usr`**：用户cpu时间百分比
* `%nice`：改变过优先级的进程的占用cpu时间百分比
    * `PRI`是比较好理解的，即进程的优先级，或者通俗点说就是程序被cpu执行的先后顺序，此值越小进程的优先级别越高。那`NI`呢？就是我们所要说的`nice`值了，其表示进程可被执行的优先级的修正数值。如前面所说，`PRI`值越小越快被执行，那么加入`nice`值后，将会使得`PRI`变为：`PRI(new) = PRI(old) + nice`
    * 在linux系统中，`nice`值的范围从`-20`到`+19`（不同系统的值范围是不一样的），正值表示低优先级，负值表示高优先级，值为零则表示不会调整该进程的优先级。具有最高优先级的程序，其`nice`值最低，所以在linux系统中，值`-20`使得一项任务变得非常重要；**与之相反，如果任务的`nice`为`+19`，则表示它是一个高尚的、无私的任务，允许所有其他任务比自己享有宝贵的CPU时间的更大使用份额，这也就是`nice`的名称的来意**
    * 进程在创建时被赋予不同的优先级值，而如前面所说，`nice`的值是表示进程优先级值可被修正数据值，因此，每个进程都在其计划执行时被赋予一个`nice`值，这样系统就可以根据系统的资源以及具体进程的各类资源消耗情况，主动干预进程的优先级值。在通常情况下，子进程会继承父进程的`nice`值，比如在系统启动的过程中，`init`进程会被赋予`0`，其他所有进程继承了这个`nice`值（因为其他进程都是`init`的子进程）
    * **对`nice`值一个形象比喻，假设在一个cpu轮转中，有2个runnable的进程`A`和`B`，如果他们的`nice`值都为0，假设内核会给他们每人分配1k个cpu时间片。但是假设进程`A`的`nice`值为0，但是`B`的`nice`值为-10，那么此时cpu可能分别给`A`和`B`分配1k和1.5k的时间片。故可以形象的理解为，`nice`的值影响了内核分配给进程的cpu时间片的多少，时间片越多的进程，其优先级越高，其优先级值（PRI）越低。`%nice`：就是改变过优先级的进程的占用cpu的百分比，如上例中就是`0.5k / 2.5k = 1/5 = 20%`**
    * 由此可见，进程`nice`值和进程优先级不是一个概念，但是进程`nice`值会影响到进程的优先级变化
* **`%sys`**：系统（内核）cpu时间百分比，不包括处理硬中断和软中断的时间
* **`%iowait`**：在系统有未完成的磁盘`I/O`请求期间，一个或多个CPU空闲的时间百分比
* `%irq`：处理硬中断的cpu时间百分比
* `%soft`：处理软中断的cpu时间百分比
* `%steal`：在管理程序为另一个虚拟处理器提供服务时，一个或多个虚拟CPU在非自愿等待中花费的时间百分比
* `%guest`：一个或多个CPU运行虚拟处理器所花费的时间百分比
* `%gnice`：一个或多个CPU运行一个`niced guest`所花费的时间百分
* **`%idle`**：一个或多个CPU空闲且系统没有未完成的磁盘`I/O`请求的时间百分比

**示例：**

* `mpstat 2 5`：打印整体信息，间隔2s，打印5次
* `mpstat -P ALL 2 5`：已单核为粒度打印信息，间隔2s，打印5次

## 6.10 iostat

**格式：**

* `iostat [ -c | -d ] [ -k | -m ] [ -t ] [ -x ] [ interval [ count ] ]`

**参数说明：**

* `-c`：与`-d`互斥，只显示cpu相关的信息
* `-d`：与`-c`互斥，只显示磁盘相关的信息
* `-k`：以`kB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-m`：以`MB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-t`：打印日期信息
* `-x`：打印扩展信息
* `interval`: 打印间隔
* `count`: 打印几次，不填一直打印

**输出信息介绍：**

* `cpu`
    * `%user`：用户cpu时间百分比
    * `%nice`：改变过优先级的进程的占用cpu时间百分比
    * `%system`：系统（内核）cpu时间百分比，不包括处理硬中断和软中断的时间
    * `%iowait`：在系统有未完成的磁盘I/O请求期间，一个或多个CPU空闲的时间百分比
    * `%steal`：在管理程序为另一个虚拟处理器提供服务时，一个或多个虚拟CPU在非自愿等待中花费的时间
    * `%idle`：一个或多个CPU空闲且系统没有未完成的磁盘I/O请求的时间百分比
* `device`
    * `tps`：每秒处理的io请求
    * `Blk_read/s (kB_read/s, MB_read/s)`：每秒读取的数据量，单位可以是Block、kB、MB
    * `Blk_wrtn/s (kB_wrtn/s, MB_wrtn/s)`：每秒写入的数据量，单位可以是Block、kB、MB
    * `Blk_read (kB_read, MB_read)`：读取的数据总量，单位可以是Block、kB、MB
    * `Blk_wrtn (kB_wrtn, MB_wrtn)`：写入的数据总量，单位可以是Block、kB、MB

**示例：**

* `iostat -d -t -x 1`

## 6.11 dstat

**格式：**

* `dstat [options]`

**参数说明：**

* `-c, --cpu`：cpu统计信息
    * `system`
    * `user`
    * `idle`
    * `wait`
    * `hardware interrupt`
    * `software interrupt`
* `-d, --disk`：磁盘统计信息
    * `read`
    * `write`
* `-i, --int`：中断统计信息
* `-l, --load`：cpu负载统计信息
    * `1 min`
    * `5 mins`
    * `15mins`
* `-m, --mem`：内存统计信息
    * `used`
    * `buffers`
    * `cache`
    * `free`
* `-n, --net`：网络统计信息
    * `receive`
    * `send`
* `-p, --proc`：进程统计信息
    * `runnable`
    * `uninterruptible`
    * `new`
* `-r, --io`：I/O统计信息
    * `read requests`
    * `write requests`
* `-s, --swap`：swap统计信息
    * `used`
    * `free`
* `-t, --time`：时间信息
* `-y, --sys`：系统统计信息
    * `interrupts`
    * `context switches`
* `--fs, --filesystem`：文件系统统计信息
    * `open files`
    * `inodes`
* `--ipc`：ipc统计信息
    * `message queue`
    * `semaphores`
    * `shared memory`
* `--lock`：文件锁统计信息
    * `posix`
    * `flock`
    * `read`
    * `write`
* `--socket`：socket统计信息
    * `total`
    * `tcp`
    * `udp`
    * `raw`
    * `ip-fragments`
* `--tcp`：tcp统计信息，包括
    * `listen`
    * `established`
    * `syn`
    * `time_wait`
    * `close`
* `--udp`：udp统计信息，包括
    * `listen`
    * `active`
* **`-f, --full`**：显示详情，例如cpu会按每个cpu分别展示，network会按网卡分别展示
* `--top-cpu`：显示最耗cpu资源的进程
* `--top-io`：显示最耗io资源的进程
* `--top-mem`：显示最耗mem资源的进程

**示例：**

* `dstat -h`：参数说明
* `dstat 5 10`：5秒刷新一次，刷新10次
* `dstat -cdgilmnprstTy`
* `dstat -tcndylp --top-cpu`
    * 等价于`dstat --time --cpu --net --disk --sys --load --proc --top-cpu`
* `dstat -tcyif`

## 6.12 ifstat

该命令用于查看网卡的流量状况，包括成功接收/发送，以及错误接收/发送的数据包，看到的东西基本上和`ifconfig`类似

## 6.13 pidstat

## 6.14 nethogs

nethogs会以进程为单位，列出每个进程占用的网卡以及带宽

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装nethogs
yum install -y nethogs
```

**示例：**

* `nethogs`

## 6.15 iptraf

## 6.16 iftop

iftop会以连接为单位，列出每个连接的进出流量

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装ifgop
yum install -y iftop
```

**示例：**

* `iftop`

## 6.17 iotop

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装iotop
yum install -y iotop
```

**示例：**

* `iotop`

## 6.18 strace

`strace`是Linux环境下的一款程序调试工具，用来监察一个应用程序所使用的系统调用
`strace`是一个简单的跟踪系统调用执行的工具。在其最简单的形式中，它可以从开始到结束跟踪二进制的执行，并在进程的生命周期中输出一行具有系统调用名称，每个系统调用的参数和返回值的文本行

在Linux中，进程是不能直接去访问硬件设备的，比如读取磁盘文件、接收网络数据等，但可以将用户态模式切换到内核模式，通过系统调用来访问硬件设备。这时`strace`就可以跟踪到一个进程产生的系统调用，包括参数，返回值，执行消耗的时间、调用次数，成功和失败的次数

**strace能做什么：**

1. 基于特定的系统调用或系统调用组进行过滤
1. 通过统计特定系统调用的使用次数，所花费的时间，以及成功和错误的数量来分析系统调用的使用
1. 跟踪发送到进程的信号
1. 通过pid附加到任何正在运行的进程
1. 调试性能问题，查看系统调用的频率，找出耗时的程序段
1. 查看程序读取的是哪些文件从而定位比如配置文件加载错误问题
1. 查看某个php脚本长时间运行“假死”情况
1. 当程序出现`Out of memory`时被系统发出的SIGKILL信息所kill
1. 另外因为strace拿到的是系统调用相关信息，一般也即是IO操作信息，这个对于排查比如cpu占用100%问题是无能为力的。这个时候就可以使用GDB工具了

**参数说明：**

* `-c`：输出统计报表
* `-e`：后接系统调用的表达式
* `-p`：后接进程id，用于跟踪指定进程

**示例：**

1. `strace cat /etc/fstab`：跟踪cat查看文件使用了哪些系统调用（按时间顺序）
1. `strace -e read cat /etc/fstab`：跟踪cat查看文件时使用的`read`这一系统调用
1. `strace -c cat /etc/fstab`：统计cat查看文件的系统调用（按调用频率）
1. `timeout 10 strace -p {PID} -f -c`：统计指定进程的系统调用

# 7 addr2line

该工具用于查看二进制的偏移量与源码的对应关系

**示例：**

* `addr2line 4005f5 -e test`：查看二进制`test`中位置为`4005f5`指令对应的源码

# 8 audit

## 8.1 架构

![audit_architecture](/images/Linux-常用命令/audit_architecture.png)

审核系统包含两个主要部分：用户空间的应用程序、实用程序，以及`kernel-side`系统调用处理。Kernel的组件从用户空间的应用程序接受系统调用，并且通过三个过滤器中的一个过滤器来进行筛选：`user`、`task`或者`exit`。一旦系统调用通过其中的一个过滤器，就将通过`exclude`过滤器进行传送，这是基于审核规则的配置，并把它传送给审核的守护程序做进一步的处理

处理过程和`iptables`差不多，有规则链，可以在链中增加规则，它发现一个`syscall`或者特殊事件的时候会去遍历这个链，然后按规则处理，吐不同的日志

**与audit相关的内核编译参数**

```
CONFIG_AUDIT_ARCH=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_IMA_AUDIT=y
CONFIG_KVM_MMU_AUDIT=y
```

**只要编译内核时，开启了审计的选项，那么内核就会产生审计事件，并将审计事件送往一个socket，然后auditd负责从这个socket读出审计事件并记录**

## 8.2 auditctl

### 8.2.1 控制规则

**参数说明：**

* `-b`：设置允许的未完成审核缓冲区的最大数量，默认值是`64`
* `-e [0..2]`：设置启用标志位
    * `0`：关闭审计功能
    * `1`：开启审计功能，且允许修改配置
    * `2`：开启审计功能，且不允许修改配置
* `-f [0..2]`：设置异常标志位（告诉内如如何处理这些异常）
    * `0`：silent，当发现异常时，不处理（静默）
    * `1`：printk，打日志（这是默认值）
    * `2`：panic，崩溃
* `-r`：消息产生的速率，单位秒
* `-s`：报告审核系统状态
* `-l`：列出所有当前装载的审核规则
* `-D`：清空所有规则以及watch

**示例：**

* `auditctl -b 8192`
* `auditctl -e 0`
* `auditctl -r 0`
* `auditctl -s`
* `auditctl -l`

### 8.2.2 文件系统规则

**格式：**

* `auditctl -w <path_to_file> -p <permissions> -k <key_name>`

**参数说明：**

* `-w`：路径名称
* `-p`：后接权限，包括
    * `r`：读取文件或者目录
    * `w`：写入文件或者目录
    * `x`：运行文件或者目录
    * `a`：改变在文件或者目录中的属性
* `-k`：后接字符串，可以任意指定，用于搜索

**示例：**

* `auditctl -w /etc/shadow -p wa -k passwd_changes`：等价于`auditctl -a always,exit -F path=/etc/shadow -F perm=wa -k passwd_changes`

### 8.2.3 系统调用规则

**格式：**

* `auditctl -a <action>,<filter> -S <system_call> -F field=value -k <key_name>`

**参数说明：**

* `-a`：后接`action`和`filter`
    * `action`：决定匹配`filter`的审计事件是否要记录，可选值包括
        * `always`：记录
        * `never`：不记录
    * `filter`：审计事件过滤器，可选值包括
        * `task`：匹配进程创建时（`fork`或`clone`）产生的审计事件
        * **`exit`：匹配系统调用结束时产生的审计事件**
        * `user`：匹配来自用户空间的审计事件
        * `exclude`：用于屏蔽不想要的审计事件
* `-S`：后接系统调用名称，系统调用清单可以参考`/usr/include/asm/unistd_64.h`，如果要指定多个系统调用名称，那么需要多个`-S`参数，每个指定一个系统调用
* `-F`：扩展选项，键值对
* `-k`：后接字符串，可以任意指定，用于搜索

**示例：**

* `auditctl -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change`

## 8.3 ausearch

**参数说明：**

* `-i`：翻译结果，使其更可读
* `-m`：指定类型
* `-sc`：指定系统调用名称
* `-sv`：系统调用是否成功

**示例：**

* `ausearch -i`：搜索全量事件
* `ausearch --message USER_LOGIN --success no --interpret`：搜索登录失败的相关事件
* `ausearch -m ADD_USER -m DEL_USER -m ADD_GROUP -m USER_CHAUTHTOK -m DEL_GROUP -m CHGRP_ID -m ROLE_ASSIGN -m ROLE_REMOVE -i`：搜索所有的账户，群组，角色变更相关的事件
* `ausearch --start yesterday --end now -m SYSCALL -sv no -i`：搜寻从昨天至今所有的失败的系统调用相关的事件
* `ausearch -m SYSCALL -sc open -i`：搜寻系统调用open相关的事件

## 8.4 审核记录类型

[B.2. 审核记录类型](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/sec-Audit_Record_Types)

# 9 内建

## 9.1 set

**格式：**

* `set [option]`

**参数说明：**

* `-e`：当任意一个命令的返回值为非0时，立即退出
* `-x`：将每个命令及其详细参数输出到标准输出中
* `-o pipefail`：针对管道命令，取从右往左第一个非零返回值作为整个管道命令的返回值

**示例：**

* `set -e`
* `set -x`
* `set -o pipefail`

## 9.2 exec

`exec`用于进程替换（类似系统调用`exec`），或者标准输入输出的重定向

**示例：**

* `exec 1>my.log 2>&1`：将标准输出、以及标准异常重定向到my.log文件中，对后续的所有命令都生效

# 10 包管理工具

## 10.1 yum

**示例：**

* `yum list docker-ce --showduplicates | sort -r`：查询软件的版本信息

<!--

**格式：**

* `find [文件路径] [option] [action]`

**参数说明：**

* `-name`：后接文件名，支持通配符。**注意匹配的是相对路径**

**示例：**

* `find . -name "*.c"`

-->

# 11 参考

* 《鸟哥的Linux私房菜》
* [linux shell awk 流程控制语句（if,for,while,do)详细介绍](https://www.cnblogs.com/chengmo/archive/2010/10/04/1842073.html)
* [awk 正则表达式、正则运算符详细介绍](https://www.cnblogs.com/chengmo/archive/2010/10/11/1847772.html)
* [解决Linux关闭终端(关闭SSH等)后运行的程序自动停止](https://blog.csdn.net/gatieme/article/details/52777721)
* [Linux ss命令详解](https://www.cnblogs.com/ftl1012/p/ss.html)
* [Socat 入门教程](https://www.hi-linux.com/posts/61543.html)
* [Linux 流量控制工具 TC 详解](https://blog.csdn.net/wuruixn/article/details/8210760)
* [docker networking namespace not visible in ip netns list](https://stackoverflow.com/questions/31265993/docker-networking-namespace-not-visible-in-ip-netns-list)
* [Guide to IP Layer Network Administration with Linux](http://linux-ip.net/html/)
* [Linux ip命令详解](https://www.jellythink.com/archives/469)
* [linux中路由策略rule和路由表table](https://blog.csdn.net/wangjianno2/article/details/72853735)
* [ip address scope parameter](https://serverfault.com/questions/63014/ip-address-scope-parameter)
* [Displaying a routing table with ip route show](http://linux-ip.net/html/tools-ip-route.html)
* [What does “proto kernel” means in Unix Routing Table?](https://stackoverflow.com/questions/10259266/what-does-proto-kernel-means-in-unix-routing-table)
* [Routing Tables](http://linux-ip.net/html/routing-tables.html)
* [How to execute a command in screen and detach?](https://superuser.com/questions/454907/how-to-execute-a-command-in-screen-and-detach)
* [Linux使echo命令输出结果带颜色](https://www.cnblogs.com/yoo2767/p/6016300.html)
* [How to insert the content of a file into another file before a pattern (marker)?](https://unix.stackexchange.com/questions/32908/how-to-insert-the-content-of-a-file-into-another-file-before-a-pattern-marker)
* [Insert contents of a file after specific pattern match](https://stackoverflow.com/questions/16715373/insert-contents-of-a-file-after-specific-pattern-match)
* [How can I copy a hidden directory recursively and preserving its permissions?](https://unix.stackexchange.com/questions/285644/how-can-i-copy-a-hidden-directory-recursively-and-preserving-its-permissions)
* [rm -rf all files and all hidden files without . & .. error](https://unix.stackexchange.com/questions/77127/rm-rf-all-files-and-all-hidden-files-without-error)
* [通过tcpdump对Unix Domain Socket 进行抓包解析](https://plantegg.github.io/2018/01/01/%E9%80%9A%E8%BF%87tcpdump%E5%AF%B9Unix%20Socket%20%E8%BF%9B%E8%A1%8C%E6%8A%93%E5%8C%85%E8%A7%A3%E6%9E%90/)
* [tcpdump 选项及过滤规则](https://www.cnblogs.com/tangxiaosheng/p/4950055.html)
* [如何知道进程运行在哪个 CPU 内核上？](https://www.jianshu.com/p/48ca58e55077)
* [Don't understand [0:0] iptable syntax](https://serverfault.com/questions/373871/dont-understand-00-iptable-syntax)
* [Linux iptables drop日志记录](https://blog.csdn.net/magerguo/article/details/81052106)
* [Iptables 指南 1.1.19](https://www.frozentux.net/iptables-tutorial/cn/iptables-tutorial-cn-1.1.19.html)
* [redhat-安全性指南-定义审核规则](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/sec-defining_audit_rules_and_controls)
* [addr2line](https://www.jianshu.com/p/c2e2b8f8ea0d)
* [How to use OpenSSL to encrypt/decrypt files?](https://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files)
* [confusion about mount options](https://unix.stackexchange.com/questions/117414/confusion-about-mount-options)