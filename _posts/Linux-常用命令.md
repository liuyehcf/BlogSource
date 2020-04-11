---
title: Linux-常用命令
date: 2017-08-15 20:17:57
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 uname

__格式：__

* `find [文件路径] [option] [action]`

__参数说明：__

* `-a, --all`：以如下次序输出所有信息。其中若`-p`和`-i`的探测结果不可知则被省略：
* `-s, --kernel-name`：输出内核名称
* `-n, --nodename`：输出网络节点上的主机名
* `-r, --kernel-release`：输出内核发行号
* `-v, --kernel-version`：输出内核版本
* `-m, --machine`：输出主机的硬件架构名称
* `-p, --processor`：输出处理器类型或"unknown"
* `-i, --hardware-platform`：输出硬件平台或"unknown"
* `-o, --operating-system`：输出操作系统名称

__示例：__

* `uname -a`
* `uname -r`
* `uname -s`

# 2 cat

__格式：__

* `cat > [newfile] <<'结束字符'`

__示例__

```sh
cat > /tmp/test << EOF
hello world!
EOF
```

# 3 echo

__格式：__

* `echo [-ne] [字符串/变量]`
* `''`中的变量不会被解析，`""`中的变量会被解析

__参数说明：__

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

__示例：__

* `echo ${a}`
* `echo -e "a\nb"`

__颜色控制，控制选项说明__ 

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

# 4 sed

__格式：__

* `sed [-nefr] [动作] [文件]`
* `STD IN | sed [-nefr] [动作]`

__参数说明：__

* __`-n`__：使用安静(silent)模式，在一般sed中，所有来自STDIN的数据一般都会被列到屏幕上，加了参数-n后，只有经过sed特殊处理的那一行才会被列出来
* __`-e`__：直接在命令行模式上进行sed的动作编辑
* __`-f`__：直接将sed的动作写在一个文件内，`-f filenmae`则可以执行filename内的sed动作
* __`-r`__：sed的动作支持的是扩展正则表达式的语法
* __`-i`__：直接修改读取的文件内容，而不是由屏幕输出

__动作说明，格式为`[n1 [,n2]]function`，接的动作必须以两个单引号括住__

* __如果没有`[n1 [,n2]]`，表示对所有行均生效__
* __如果仅有`[n1]`，表示仅对`n1`行生效__
* __`n1`与`n2`可以用`/string/`来表示`[ /string_n1/ ,[ /stirng_n2/ ]]`__。__配合`-r`参数，还可以使用正则表达式__
    * __`/string_n1/`__：__从第一行开始__，__`所有`__匹配字符串`string_n1`的行号
    * __`/string_n1/,/stirng_n2/`__：__从第一行开始__，__`第一个`__匹配字符串`string_n1`的行号，到，__从第一行开始__，__`第一个`__匹配字符串`stirng_n2`的行号
    * __当该行包含`string`时，就算匹配成功__
    * __如果要匹配整行，可以利用`-r`参数配合正则表达式通配符`^`与`$`来完成__
    * __由于`/`是特殊字符，因此在正则表达式中，表示一个普通的`/`需要转义__
* __`a`__：新增，a的后面可接字符串，而这些字符串会在新的一行出现(目前行的下一行)
* __`c`__：替换，c的后面可接字符串，这些字符串可以替换n1,n2之间的行
* __`d`__：删除，后面通常不接任何参数
* __`i`__：插入，i的后面可接字符串，而这些字符串会在新的一行出现(目前行的上一行)
* __`p`__：打印，也就是将某个选择的数据打印出来，通常p会与参数sed -n一起运行
* __`s`__：替换，可以直接进行替换的工作，通常这个s可以搭配正则表达式，例如1,20s/lod/new/g  (跟vim里面的很像！！！)
    * __分隔符可以是`/`也可以是`|`__
    * __分隔符若为`/`，那么普通的`|`不需要转义，`/`需要转义__
    * __分隔符若为`|`，那么普通的`/`不需要转义，`|`需要转义__
    * __不加`-r`参数，连`()`都需要转义，因此最好加上`-r`参数__
    * `\0`：表示整个匹配串，`\1`表示group1，以此类推
    * `&`：表示整个匹配串

__示例：__

* __`a`__：
```sh
echo -e "a\nb\nc" | sed '1,2anewLine'

# 输出如下
a
newLine
b
newLine
c
```

* __`c`__：
```sh
# /^a$/通过正则表达式匹配第一行，需要配合-r参数
echo -e "a\nb\nc" | sed -r '/^a$/,2cnewLine'

# 输出如下
newLine
c
```

* __`d`__：
```sh
echo -e "a\nb\nc" | sed '2,/c/d'

# 输出如下
a
```

* __`i`__：
```sh
echo -e "a\nb\nc" | sed '1,2inewLine'

# 输出如下
newLine
a
newLine
b
c
```

* __`p`__：
```sh
# $表示最后一行
echo -e "a\nb\nc" | sed -n '/b/,$p'

# 输出如下
b
c
```

* __`s`__：
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
__注意__：在macOS中，`-i`参数后面要跟一个扩展符，用于备份源文件。如果扩展符长度是0，那么不进行备份

* `sed -i ".back" "s/a/b/g" example`：备份文件为`example.back`
* `sed -i "" "s/a/b/g" example`：不备份

# 5 awk

相比于sed(管道命令)常常作用于一整行的处理，awk(管道命令)则比较倾向于将一行分成数个"字段"来处理，因此awk相当适合处理小型的数据处理

__格式：__

* `awk [-F] '[/regex/] 条件类型1{动作1} 条件类型2{动作2}...' [filename]`

__参数说明：__

* `-F`：后接分隔符。例如：`-F ':'`、`-F '[,.;]'`

注意awk后续的所有动作都是以单引号括住的，而且如果以print打印时，非变量的文字部分，包括格式等(例如制表`\t`、换行`\n`等)都需要以双引号的形式定义出来，因为单引号已经是awk的命令固定用法了。例如`last -n 5 | awk '{print $1 "\t" $3}'`

__awk处理流程：__

1. 读入第一行
    * __如果包含正则匹配部分，如果不匹配则跳过该行；如果匹配（任意子串），那么将第一行的数据填入`$0`,`$1`,...等变量中__
    * 如果不包含正则匹配部分，那么将第一行的数据填入`$0`,`$1`,...等变量中
1. 依据条件类型的限制，判断是否需要进行后面的动作
1. 做完所有的动作与条件类型
1. 若还有后续的'行'，重复上面的步骤，直到所有数据都读取完为止

__awk内置变量：__

* `ARGC`：命令行参数个数
* `ARGV`：命令行参数排列
* `ENVIRON`：支持队列中系统环境变量的使用
* `FILENAME`：awk浏览的文件名
* `FNR`：浏览文件的记录数
* __`FS`：设置输入域分隔符，默认是空格键，等价于命令行 -F选项__
* __`NF`：每一行($0)拥有的字段总数__
* __`NR`：目前awk所处理的是第几行__
* `OFS`：输出域分隔符
* `ORS`：输出记录分隔符
* `RS`：控制记录分隔符
* 在动作内部引用这些变量不需要用`$`，例如`last -n 5 | awk '{print $1 "\t  lines: " NR "\t columes: " NF}'`
* 此外，`$0`变量是指整条记录。`$1`表示当前行的第一个域，`$2`表示当前行的第二个域，以此类推

__动作说明：__

* 所有awk的动作，即在`{}`内的动作，如果有需要多个命令辅助时，可以用分号`;`间隔，或者直接以`Enter`按键来隔开每个命令

__BEGIN与END__

* 在Unix awk中两个特别的表达式，BEGIN和END，这两者都可用于pattern中（参考前面的awk语法），__提供BEGIN和END的作用是给程序赋予初始状态和在程序结束之后执行一些扫尾的工作。__
* __任何在BEGIN之后列出的操作（在`{}`内）将在Unix awk开始扫描输入之前执行，而END之后列出的操作将在扫描完全部的输入之后执行。__因此，通常使用BEGIN来显示变量和预置（初始化）变量，使用END来输出最终结果

__print与printf__

* print会打印换行符
* printf不会打印换行符

__示例：__

* `cat /etc/passwd | awk '{FS=":"} $3<10 {print $1 "\t" $3}'`：__注意`{FS=":"}`是作为一个动作存在的，因此从第二行开始分隔符才变为":"，第一行分隔符仍然是空格__
* `cat /etc/passwd | awk 'BEGIN {FS=":"} $3<10 {print $1 "\t" $3}'`：__这样写`{FS=":"}`在处理第一行时也会生效__
* `echo -e "abcdefg\nhijklmn\nopqrst\nuvwxyz" | awk '/[au]/ {print $0}'`
* 
```shell
awk 
'BEGIN {FS=":";print "统计销售金额";total=0} 
{print $3;total=total+$3;} 
END {print "销售金额总计：",total}' sx
```

## 5.1 在awk中引用变量

__方式1__

* 以`'"`和`"'`（即，单引号+双引号+shell变量+双引号+单引号）将shell变量包围起来
* __这种方式只能引用数值变量__

```sh
var=4
awk 'BEGIN{print '"$var"'}'
```

__方式2__

* 以`"'`和`'"`（即，双引号+单引号+shell变量+单引号+双引号）将shell变量包围起来
* __这种方式可以引用字符串型变量，但是字符串不允许包含空格__

```sh
var=4
awk 'BEGIN{print "'$var'"}'
var="abc"
awk 'BEGIN{print "'$var'"}'
```

__方式3__

* 用`"'"`（即，双引号+单引号+双引号+shell变量+双引号+单引号+双引号）将shell变量包裹起来
* __这种方式允许引用任意类型的变量__

```sh
var=4
awk 'BEGIN{print "'"$var"'"}'
var="abc"
awk 'BEGIN{print "'"$var"'"}'
var="this a test"
awk 'BEGIN{print "'"$var"'"}'
```

__方式4__

* 使用`-v`参数，变量不是很多的时候，这种方式也蛮简介清晰的

```sh
var="this a test"
awk -v awkVar="$var" 'BEGIN{print awkVar}'
```

## 5.2 在awk中写简单的控制流语句

__以下的示例都在BEGIN中，只执行一次，不需要指定文件或者输入流__

__if语句__
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

__while语句__
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

__for语句__
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

__do语句__
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

## 5.3 在awk中使用正则表达式

```sh
echo "123" |awk '{if($0 ~ /^[0-9]+$/) print $0;}'
```

# 6 cut

__格式：__

* `cut -b list [-n] [file ...]`
* `cut -c list [file ...]`
* `cut -f list [-s] [-d delim] [file ...]`

__参数说明：__

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

__示例：__

* `echo "a:b:c:d:e" | cut -d ":" -f3`：输出c
* `ll | cut -c 1-10`：显示查询结果的 1-10个字符

# 7 grep

grep分析一行信息，若当前有我们所需要的信息，就将该行拿出来

__格式：__

* `grep [-acinvrAB] [--color=auto] '查找的字符串' filename`

__参数说明：__

* `-a`：将binary文件以text文件的方式查找数据
* `-c`：计算找到'查找字符串'的次数
* `-i`：忽略大小写的不同
* `-n`：顺便输出行号
* `-v`：反向选择，即输出没有'查找字符串'内容的哪一行
* `-r`：在指定目录中递归查找
* `--color=auto`：将找到的关键字部分加上颜色
* `-A`：后面可加数字，为after的意思，除了列出该行外，后面的n行也列出来
* `-B`：后面可加数字，为before的意思，除了列出该行外，前面的n行也列出来

__示例：__

* `grep -r [--color=auto] '查找的字符串' [目录名]`

# 8 sort

__格式：__

* `sort [-fbMnrtuk] [file or stdin]`

__参数说明：__

* `-f`：忽略大小写的差异
* `-b`：忽略最前面的空格符部分
* `-M`：以月份的名字来排序，例如JAN，DEC等排序方法
* `-n`：使用"纯数字"进行排序(默认是以文字类型来排序的)
* `-r`：反向排序
* `-u`：就是uniq，相同的数据中，仅出现一行代表
* `-t`：分隔符，默认使用`Tab`来分隔
* `-k`：以哪个区间(field)来进行排序的意思

__示例：__

* `cat /etc/passwd | sort`
* `cat /etc/passwd | sort -t ':' -k 3`

# 9 tr

`tr`指令从标准输入设备读取数据，经过字符串转译后，将结果输出到标准输出设备

__格式：__

* `tr [-cdst] SET1 [SET2]`

__参数说明：__

* `-c, --complement`：反选设定字符。也就是符合`SET1`的部份不做处理，不符合的剩余部份才进行转换
* `-d, --delete`：删除指令字符
* `-s, --squeeze-repeats`：缩减连续重复的字符成指定的单个字符
* `-t, --truncate-set1`：削减`SET1`指定范围，使之与`SET2`设定长度相等

__字符集合的范围__

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

__示例：__

* `echo "abcdefg" | tr "[:lower:]" "[:upper:]"`：将小写替换为大写
* `echo -e "a\nb\nc" | tr "\n" " "`：将`\n`替换成空格
* `echo "hello 123 world 456" | tr -d '0-9'`：删除`0-9`
* `echo -e "aa.,a 1 b#$bb 2 c*/cc 3 \nddd 4" | tr -d -c '0-9 \n'`：删除除了`0-9`、空格、换行符之外的内容
* `echo "thissss is      a text linnnnnnne." | tr -s ' sn'`：删除多余的空格、`s`和`n`
* `head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`：生成随机串

# 10 tee

`>`、`>>`等会将数据流传送给文件或设备，因此除非去读取该文件或设备，否则就无法继续利用这个数据流，如果我们想要将这个数据流的处理过程中将某段信息存下来，可以利用`tee`

`tee`会将数据流送与文件与屏幕(screen)，输出到屏幕的就是`stdout`可以让下个命令继续处理(__`>`,`>>`会截断`stdout`，从而无法以`stdin`传递给下一个命令__)

__格式：__

* `tee [-a] file`

__参数说明：__

* `-a`：以累加(append)的方式，将数据加入到file当中

__示例：__

* `command | tee <文件名> | command`

# 11 find

__格式：__

* `find [文件路径] [option] [action]`

__参数说明：__

* `-name`：后接文件名，支持通配符。__注意匹配的是相对路径__
* `-regex`：后接正则表达式，__注意匹配的是完整路径__

__示例：__

* `find . -name "*.c"`
* `find . -regex ".*/.*\.c"`

# 12 tar

__格式：__

* 压缩：
    * `tar -jcv -f [压缩创建的文件(*.tar.bz2)] [-C 切换工作目录] [被压缩的文件或目录1] [被压缩的文件或目录2]...`
    * `tar -zcv -f [压缩创建的文件(*.tar.gz)] [-C 切换工作目录] [被压缩的文件或目录1] [被压缩的文件或目录2]...`
* 查询：
    * `tar -jtv -f [压缩文件(*.tar.bz2)]`
    * `tar -ztv -f [压缩文件(*.tar.gz)]`
* 解压缩：
    * `tar -jxv -f [压缩文件(*.tar.bz2)] [-C 切换工作目录]`
    * `tar -zxv -f [压缩文件(*.tar.gz)] [-C 切换工作目录]`

__参数说明：__

* `-c`：新建打包文件，可以搭配-v查看过程中被打包的文件名
* `-t`：查看打包文件的内容含有那些文件名，终点在查看文件
* `-x`：解打包或解压缩的功能，可搭配-C在特定目录解开
* __注意，c t x是互斥的__
* `-j`：通过bzip2的支持进行压缩/解压，此时文件名最好为*.tar.bz2
* `-z`：通过gzip的支持进行压缩/解压，此时文件名最好是*.tar.gz
* `-v`：在压缩/解压缩过程中，将正在处理的文件名显示出来
* `-f` filename：-f后面接要被处理的文件名，建议-f单独写一个参数
* `-C`：用户切换工作目录，之后的文件名可以使用相对路径
* `-p`：保留备份数据原本权限与属性，常用语备份(-c)重要的配置文件
* `-P`：保留绝对路径，即允许备份数据中含有根目录存在之意

# 13 tree

__格式：__

* `tree [option]`

__参数说明：__

* `-N`：显示非ASCII字符，可以显示中文

# 14 &

在命令最后加上`&`代表将命令丢到后台执行

* 此时bash会给予这个命令一个工作号码(job number)，后接该命令触发的PID
* 不能被[Ctrl]+C中断
* 在后台中执行的命令，如果有stdout以及stderr时，它的数据依旧是输出到屏幕上面，所以我们会无法看到提示符，命令结束后，必须按下[Enter]才能看到命令提示符，同时也无法用[Ctrl]+C中断。解决方法就是利用数据流重定向

__示例：__

* `tar -zpcv -f /tmp/etc.tar.gz /etc > /tmp/log.txt 2>&1 &`

# 15 Ctrl+C

终止当前进程

# 16 Ctrl+Z

暂停当前进程

# 17 jobs

__格式：__

* `jobs [option]`

__参数说明：__

* `-l`：除了列出job number与命令串之外，同时列出PID号码
* `-r`：仅列出正在后台run的工作
* `-s`：仅列出正在后台中暂停(stop)的工作
* 输出信息中的'+'与'-'号的意义：
    * +：最近被放到后台的工作号码，代表默认的取用工作，即仅输入'fg'时，被拿到前台的工作
    * -：代表最近后第二个被放置到后台的工作号码
    * 超过最后第三个以后，就不会有'+'与'-'号存在了

__示例：__

* `jobs -lr`
* `jobs -ls`

# 18 fg

将后台工作拿到前台来处理

__示例：__

* `fg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `fg +`：取出标记为+的工作
* `fg -`：取出标记为-的工作`

# 19 bg

让工作在后台下的状态变为运行中

__示例：__

* `bg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `bg +`：取出标记为+的工作
* `bg -`：取出标记为-的工作
* 不能让类似vim的工作变为运行中，即便使用该命令会，该工作又立即变为暂停状态

# 20 kill

管理后台当中的工作

__格式：__

* `kill [-signal] PID`
* `kill [-signal] %jobnumber`
* `kill -l`

__参数说明：__

* `-l`：列出目前kill能够使用的signal有哪些
* `-signal`：
    * `-1`：重新读取一次参数的配置文件，类似reload
    * `-2`：代表与由键盘输入[Ctrl]+C同样的操作
    * `-9`：立刻强制删除一个工作，通常在强制删除一个不正常的工作时使用
    * `-15`：以正常的程序方式终止一项工作，与-9是不同的，-15以正常步骤结束一项工作，这是默认值
* 与bg、fg不同，若要管理工作，kill中的%不可省略，因为kill默认接PID

# 21 pkill

__格式：__

* `pkill [-signal] PID`
* `pkill [-signal] [-Ptu] [arg]`

__参数说明：__

* `-signal`：同`kill`
* `-P ppid,...`：匹配指定`parent id`
* `-s sid,...`：匹配指定`session id`
* `-t term,...`：匹配指定`terminal`
* `-u euid,...`：匹配指定`effective user id`
* `-U uid,...`：匹配指定`real user id`
* __不指定匹配规则时，默认匹配进程名字__

__示例：__

* `pkill -9 -t pts/0`
* `pkill -9 -u user1`

# 22 ps

__格式：__

* `ps aux`：查看系统所有进程数据
* `ps -lA`：查看所有系统的数据
* `ps axjf`：连同部分进程数状态

__参数说明：__

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

__`ps -l`打印参数说明__

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

__`ps aux`打印参数说明：__

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

# 23 pgrep

__格式：__

* `pgrep [-lon] <pattern>`

__参数说明：__

* `-l`：列出pid以及进程名
* `-o`：列出oldest的进程
* `-n`：列出newest的进程

__示例：__

* `pgrep sshd`
* `pgrep -l sshd`
* `pgrep -lo sshd`
* `pgrep -ln sshd`
* `pgrep -l ssh*`

# 24 nohup

__`nohup`会忽略所有挂断（SIGHUP）信号__。比如通过`ssh`登录到远程服务器上，然后启动一个程序，当`ssh`登出时，这个程序就会随即终止。如果用`nohup`方式启动，那么当`ssh`登出时，这个程序仍然会继续运行

__格式：__

* `nohup command [args] [&]`

__参数说明：__

* `command`：要执行的命令
* `args`：命令所需的参数
* `&`：在后台执行

__示例：__

* `nohup java -jar xxx.jar &`

# 25 screen

__如果想在关闭`ssh`连接后继续运行启动的程序，可以使用`nohup`。如果要求下次`ssh`登录时，还能查看到上一次`ssh`登录时运行的程序的状态，那么就需要使用`screen`__

__格式：__

* `screen`
* `screen cmd [ args ]`
* `screen [–ls] [-r pid]`
* `screen -X -S <pid> kill`
* `screen -d -m cmd [ args ]`

__参数说明：__

* `cmd`：执行的命令
* `args`：执行的命令所需要的参数
* `-ls`：列出所有`screen`会话的详情
* `-r`：后接`pid`，进入指定进程号的`screen`会话
* `-d`：退出当前运行的session

__示例：__

* `screen`
* `screen -ls`
* `screen -r 123`

__会话管理__

1. `Ctrl a + w`：显示所有窗口列表
1. `Ctrl a + Ctrl a`：切换到之前显示的窗口
1. `Ctrl a + c`：创建一个新的运行shell的窗口并切换到该窗口
1. `Ctrl a + n`：切换到下一个窗口
1. `Ctrl a + p`：切换到前一个窗口(与`Ctrl a + n`相对)
1. `Ctrl a + 0-9`：切换到窗口0..9
1. `Ctrl a + d`：暂时断开screen会话
1. `Ctrl a + k`：杀掉当前窗口

# 26 pstree

__格式：__

* `pstree [-A|U] [-up]`

__参数说明：__

* `-A`：各进程树之间的连接以ASCII字符来连接(连接符号是ASCII字符)
* `-U`：各进程树之间的连接以utf8码的字符来连接，在某些终端接口下可能会有错误(连接符号是utf8字符，比较圆滑好看)
* `-p`：同时列出每个进程的PID
* `-u`：同时列出每个进程所属账号名称

# 27 运维相关

# 28 top

__格式：__

* `top [-H] [-p <pid>]`

__参数说明：__

* `-H`：显示线程
* `-p`：查看指定进程

__示例：__

* `top -p 123`：查看进程号为123的进程
* `top -Hp 123`：查看进程号为123以及该进程的所有线程

__打印参数说明：__

* __第一行__：
    * 目前的时间
    * 开机到目前为止所经过的时间
    * 已经登录的人数
    * 系统在1，5，15分钟的平均工作负载
* __第二行__：显示的是目前进程的总量，与各个状态下进程的数量
* __第三行__：显示的CPU整体负载，特别注意wa，这个代表的是I/Owait，通常系统变慢都是I/O产生的问题比较大
* __第四五行__：物理内存与虚拟内存的使用情况，注意swap的使用量越少越好，大量swap被使用说明系统物理内存不足
* __第六行__：top进程中，输入命令时显示的地方
* __第七行以及以后__：每个进程的资源使用情况
    * PID：每个进程的ID
    * USER：进程所属用户名称
    * PR：Priority，优先顺序，越小优先级越高
    * NI：Nice，与Priority有关，越小优先级越高
    * %CPU：CPU使用率
    * %MEN：内存使用率
    * TIME+：CPU使用时间累加
    * COMMAND
* __top默认使用CPU使用率作为排序的终点，键入`h`显示帮助菜单__
* __排序顺序__
    * `P`：按CPU使用量排序，默认从大到小，`R`更改为从小到大
    * `M`：按内存使用量排序，默认从大到小，`R`更改为从小到大
    * `T`：按使用时间排序，默认从大到小，`R`更改为从小到大

# 29 netstat

__格式：__

* `netstat -[rn]`
* `netstat -[antulpc]`

__参数说明：__

1. __与路由有关的参数__
    * `-r`：列出路由表(route table)，功能如同route
    * `-n`：不使用主机名与服务名称，使用IP与port number，如同route -n
1. __与网络接口有关的参数__
    * `-a`：列出所有的连接状态，包括tcp/udp/unix socket等
    * `-t`：仅列出TCP数据包的连接
    * `-u`：仅列出UDP数据包的连接
    * `-l`：仅列出已在Listen(监听)的服务的网络状态
    * `-p`：列出PID与Program的文件名
    * `-c`：可以设置几秒种后自动更新一次，例如-c 5为每5s更新一次网络状态的显示

__与路由有关的显示参数说明__

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

__与网络接口有关的显示参数说明：__

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

netstat的功能就是查看网络的连接状态，而网络连接状态中，又以__"我目前开了多少port在等待客户端的连接"__以及__"目前我的网络连接状态中，有多少连接已建立或产生问题"__最常见

__示例__

1. __`netstat -n | awk '/^tcp/ {++y[$NF]} END {for(w in y) print w, y[w]}'`__

# 30 lsof

__格式：__

* `lsof [-aU] [-u 用户名] [+d] [-i address]`

__参数说明：__

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

__示例：__

* `lsof -i 6tcp@localhost:22`
* `lsof -i 4tcp@127.0.0.1:22`
* `lsof -i tcp@127.0.0.1:22`
* `lsof -i tcp@localhost`
* `lsof -i tcp:22`

# 31 ss

`ss`是`Socket Statistics`的缩写。顾名思义，`ss`命令可以用来获取`socket`统计信息，它可以显示和`netstat`类似的内容。`ss`的优势在于它能够显示更多更详细的有关TCP和连接状态的信息，而且比`netstat`更快速更高效。

当服务器的socket连接数量变得非常大时，无论是使用`netstat`命令还是直接`cat /proc/net/tcp`，执行速度都会很慢。

`ss`快的秘诀在于，它利用到了TCP协议栈中`tcp_diag`。`tcp_diag`是一个用于分析统计的模块，可以获得Linux内核中第一手的信息，这就确保了`ss`的快捷高效

__格式：__

* `ss [-talspnr]`

__参数说明：__

* `-t`：列出tcp-socket
* `-a`：列出所有socket
* `-l`：列出所有监听的socket
* `-s`：仅显示摘要信息
* `-p`：显示用了该socket的进程
* `-n`：不解析服务名称
* `-r`：解析服务名称
* `-m`：显示内存占用情况
* `-h`：查看帮助文档

__示例：__

* `ss -t -a`：显示所有tcp-socket
* `ss -u –a`：显示所有udp-socket
* `ss -lp | grep 22`：找出打开套接字/端口应用程序
* `ss -o state established`：显示所有状态为established的socket
* `ss -o state FIN-WAIT-1 dst 192.168.25.100/24`：显示出处于`FIN-WAIT-1`状态的，目标网络为`192.168.25.100/24`所有socket
* `ss -nap`

# 32 ip

## 32.1 ip addr

简写为`ip a`

## 32.2 ip link

简写为`ip l`

## 32.3 ip route

简写为`ip r`

### 32.3.1 route table

__linux最多可以支持255张路由表，每张路由表有一个`table id`和`table name`。其中有4张表是linux系统内置的__

* __`table id = 0`：系统保留__
* __`table id = 255`：本地路由表，表名为`local`__。像本地接口地址，广播地址，以及NAT地址都放在这个表。该路由表由系统自动维护，管理员不能直接修改
    * `ip r show table local`
* __`table id = 254`：主路由表，表名为`main`__。如果没有指明路由所属的表，所有的路由都默认都放在这个表里。一般来说，旧的路由工具（如`route`）所添加的路由都会加到这个表。`main`表中路由记录都是普通的路由记录。而且，使用`ip route`配置路由时，如果不明确指定要操作的路由表，默认情况下也是对主路由表进行操作
    * `ip r show table main`
* __`table id = 253`：称为默认路由表，表名为`default`__。一般来说默认的路由都放在这张表
    * `ip r show table default`

__此外__

* 系统管理员可以根据需要自己添加路由表，并向路由表中添加路由记录
* 可以通过`/etc/iproute2/rt_tables`文件查看`table id`和`table name`的映射关系。
* 如果管理员新增了一张路由表，需要在`/etc/iproute2/rt_tables`文件中为新路由表添加`table id`和`table name`的映射

### 32.3.2 route type

__`unicast`__：单播路由是路由表中最常见的路由。这是到目标网络地址的典型路由，它描述了到目标的路径。即使是复杂的路由（如下一跳路由）也被视为单播路由。如果在命令行上未指定路由类型，则假定该路由为单播路由

```sh
ip route add unicast 192.168.0.0/24 via 192.168.100.5
ip route add default via 193.7.255.1
ip route add unicast default via 206.59.29.193
ip route add 10.40.0.0/16 via 10.72.75.254
```

__`broadcast`__：此路由类型用于支持广播地址概念的链路层设备（例如以太网卡）。此路由类型仅在本地路由表中使用，通常由内核处理

```sh
ip route add table local broadcast 10.10.20.255 dev eth0 proto kernel scope link src 10.10.20.67
ip route add table local broadcast 192.168.43.31 dev eth4 proto kernel scope link src 192.168.43.14
```

__`local`__：当IP地址添加到接口时，内核会将条目添加到本地路由表中。这意味着IP是本地托管的IP

```sh
ip route add table local local 10.10.20.64 dev eth0 proto kernel scope host src 10.10.20.67
ip route add table local local 192.168.43.12 dev eth4 proto kernel scope host src 192.168.43.14
```

__`nat`__：当用户尝试配置无状态NAT时，内核会将此路由条目添加到本地路由表中

```sh
ip route add nat 193.7.255.184 via 172.16.82.184
ip route add nat 10.40.0.0/16 via 172.40.0.0
```

__`unreachable`__：当对路由决策的请求返回的路由类型不可达的目的地时，将生成ICMP unreachable并返回到源地址

```sh
ip route add unreachable 172.16.82.184
ip route add unreachable 192.168.14.0/26
ip route add unreachable 209.10.26.51
```

__`prohibit`__：当路由选择请求返回具有禁止路由类型的目的地时，内核会生成禁止返回源地址的ICMP

```sh
ip route add prohibit 10.21.82.157
ip route add prohibit 172.28.113.0/28
ip route add prohibit 209.10.26.51
```

__`blackhole`__：匹配路由类型为黑洞的路由的报文将被丢弃。没有发送ICMP，也没有转发数据包

```sh
ip route add blackhole default
ip route add blackhole 202.143.170.0/24
ip route add blackhole 64.65.64.0/18
```

__`throw`__：引发路由类型是一种便捷的路由类型，它会导致路由表中的路由查找失败，从而将路由选择过程返回到RPDB。当有其他路由表时，这很有用。请注意，如果路由表中没有默认路由，则存在隐式抛出，因此尽管合法，但是示例中第一个命令创建的路由是多余的

```sh
ip route add throw default
ip route add throw 10.79.0.0/16
ip route add throw 172.16.0.0/12
```

### 32.3.3 route scope

__`global`__：全局有效

__`site`__：仅在当前站点有效（IPV6）

__`link`__：仅在当前设备有效

__`host`__：仅在当前主机有效

### 32.3.4 route proto

__`proto`：表示路由的添加时机。可由数字或字符串表示，数字与字符串的对应关系详见`/etc/iproute2/rt_protos`__

1. __`redirect`__：表示该路由是因为发生`ICMP`重定向而添加的
1. __`kernel`__：该路由是内核在安装期间安装的自动配置
1. __`boot`__：该路由是在启动过程中安装的。如果路由守护程序启动，它将会清除这些路由规则
1. __`static`__：该路由由管理员安装，以覆盖动态路由

### 32.3.5 route src

这被视为对内核的提示（用于回答：如果我要将数据包发往host X，我该用本机的哪个IP作为Source IP），该提示是关于要为该接口上的`传出`数据包上的源地址选择哪个IP地址

### 32.3.6 参数解释

__`ip r show table local`参数解释（示例如下）__

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

## 32.4 ip rule

基于策略的路由比传统路由在功能上更强大，使用更灵活，它使网络管理员不仅能够根据目的地址而且能够根据报文大小、应用或IP源地址等属性来选择转发路径。简单地来说，linux系统有多张路由表，而路由策略会根据一些条件，将路由请求转向不同的路由表。例如源地址在某些范围走路由表A，另外的数据包走路由表，类似这样的规则是有路由策略rule来控制

在linux系统中，一条路由策略`rule`主要包含三个信息，即`rule`的优先级，条件，路由表。其中rule的优先级数字越小表示优先级越高，然后是满足什么条件下由指定的路由表来进行路由。__在linux系统启动时，内核会为路由策略数据库配置三条缺省的规则，即`rule 0`，`rule 32766`，`rule 32767`（数字是rule的优先级），具体含义如下__：

1. __`rule 0`__：匹配任何条件的数据包，查询路由表`local（table id = 255）`。`rule 0`非常特殊，不能被删除或者覆盖。
1. __`rule 32766`__：匹配任何条件的数据包，查询路由表`main（table id = 254）`。系统管理员可以删除或者使用另外的策略覆盖这条策略
1. __`rule 32767`__：匹配任何条件的数据包，查询路由表`default（table id = 253）`。对于前面的缺省策略没有匹配到的数据包，系统使用这个策略进行处理。这个规则也可以删除
* 在linux系统中是按照rule的优先级顺序依次匹配。假设系统中只有优先级为`0`，`32766`及`32767`这三条规则。那么系统首先会根据规则`0`在本地路由表里寻找路由，如果目的地址是本网络，或是广播地址的话，在这里就可以找到匹配的路由；如果没有找到路由，就会匹配下一个不空的规则，在这里只有`32766`规则，那么将会在主路由表里寻找路由；如果没有找到匹配的路由，就会依据`32767`规则，即寻找默认路由表；如果失败，路由将失败

__示例__

```sh
# 增加一条规则，规则匹配的对象是所有的数据包，动作是选用路由表1的路由，这条规则的优先级是32800
$ ip rule add [from 0/0] table 1 pref 32800

# 增加一条规则，规则匹配的对象是IP为192.168.3.112, tos等于0x10的包，使用路由表2，这条规则的优先级是1500，动作是丢弃。
$ ip rule add from 192.168.3.112/32 [tos 0x10] table 2 pref 1500 prohibit
```

## 32.5 ip netns

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

__示例__

* `ip netns list`：列出网络命名空间（只会从`/var/run/netns`下读取）
* `ip netns exec test-ns ifconfig`：在网络命名空间`test-ns`中执行`ifconfig`

__与nsenter的区别__：由于`ip netns`只从`/var/run/netns`下读取网络命名空间，而`nsenter`默认会读取`/proc/${pid}/ns/net`。但是`docker`会隐藏容器的网络命名空间，即默认不会在`/var/run/netns`目录下创建命名空间，因此如果要使用`ip netns`进入到容器的命名空间，还需要做个软连接

```sh
pid=$(docker inspect -f '{{.State.Pid}}' ${container_id})
mkdir -p /var/run/netns/
ln -sfT /proc/$pid/ns/net /var/run/netns/$container_id
```

# 33 tcpdump

__格式：__

* `tcpdump [-AennqX] [-i 接口] [port 端口号] [-w 存储文件名] [-c 次数] [-r 文件] [所要摘取数据包的格式]`

__参数说明：__

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
* 此外，还可以用`and`拼接多个条件

__显示格式说明__

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

__示例：__

* `tcpdump -i lo0 port 22 -w output7.cap`
* `tcpdump -i eth0 host www.baidu.com`
* `tcpdump -i any -w output1.cap`
* `tcpdump -n -i any -e icmp and host www.baidu.com`

## 33.1 tips

如何查看具体的协议，例如ssh协议

利用wireshark

1. 任意选中一个`length`不为`0`的数据包，右键选择解码（`decode as`），右边`Current`一栏，选择对应的协议即可

# 34 iptables

## 34.1 规则的查看

__格式：__

* `iptables [-S] [-t tables] [-L] [-nv]`

__参数说明：__

* `-S`：输出指定table的规则，若没有指定table，则输出所有的规则，类似`iptables-save`
* `-t`：后面接table，例如nat或filter，若省略此项目，则使用默认的filter
* `-L`：列出目前的table的规则
* `-n`：不进行IP与HOSTNAME的反查，显示信息的速度回快很多
* `-v`：列出更多的信息，包括通过该规则的数据包总数，相关的网络接

__输出信息介绍__

* 每一个Chain就是每个链，Chain所在的括号里面的是默认的策略(即没有规则匹配时采取的操作(target))
* `target`：代表进行的操作
    * __`ACCEPT`__：表示放行
    * __`DROP`__：表示丢弃
    * __`QUEUE`__：将数据包传递到用户空间
    * __`RETURN`__：表示停止遍历当前链，并在上一个链中的下一个规则处恢复（假设在`Chain A`中调用了`Chain B`，`Chain B RETURN`后，继续`Chain A`的下一个规则）
    * __还可以是一个自定义的Chain__
* `port`：代表使用的数据包协议，主要有TCP、UDP、ICMP3中数据包
* `opt`：额外的选项说明
* `source`：代表此规则是针对哪个来源IP进行限制
* `destination`：代表此规则是针对哪个目标IP进行限制

__示例：__

* `iptables -nL`
* `iptables -t nat -nL`

由于`iptables`的上述命令的查看只是做格式化的查阅，要详细解释每个规则可能会与原规则有出入，因此，建议使用`iptables-save`这个命令来查看防火墙规则

__格式：__

* `iptables-save [-t table]`

__参数说明：__

* `-t`：可以针对某些表格来输出，例如仅针对NAT或Filter等

__输出信息介绍__

* 星号开头的指的是表格，这里为Filter
* 冒号开头的指的是链，3条内建的链，后面跟策略

## 34.2 规则的清除

__格式：__

* `iptables [-t tables] [-FXZ] [chain]`

__参数说明：__

* `-F [chain]`：清除指定chain或者所有chian中的所有的已制定的规则
* `-X [chain]`：清除指定`user-defined chain`或所有`user-defined chain`
* `-Z [chain]`：将指定chain或所有的chain的计数与流量统计都归零

## 34.3 定义默认策略

当数据包不在我们设置的规则之内时，该数据包的通过与否都以Policy的设置为准

__格式：__

* `iptables [-t nat] -P [INPUT,OUTPUT,FORWARD] [ACCEPT,DROP]`

__参数说明：__

* `-P`：定义策略(Policy)
    * `ACCEPT`：该数据包可接受
    * `DROP`：该数据包直接丢弃，不会让Client知道为何被丢弃

__示例：__

* `iptables -P INPUT DROP`
* `iptables -P OUTPUT ACCEPT`
* `iptables -P FORWARD ACCEPT`

## 34.4 数据包的基础对比：IP、网络及接口设备

__格式：__

* `iptables [-AI 链名] [-io 网络接口] [-p 协议] [-s 来源IP/网络] [-d 目标IP/网络] -j [ACCEPT|DROP|REJECT|LOG]`

__参数说明：__

* `-AI 链名`：针对某条链进行规则的"插入"或"累加"
    * `-A`：新增加一条规则，该规则增加在原规则后面，例如原来有4条规则，使用-A就可以加上第五条规则
    * `-I`：插入一条规则，如果没有指定此规则的顺序，默认插入变成第一条规则
    * `链`：有INPUT、OUTPUT、FORWARD等，此链名称又与-io有关
* `-io 网络接口`：设置数据包进出的接口规范
    * `-i`：数据包所进入的那个网络接口，例如eth0，lo等，需要与INPUT链配合
    * `-o`：数据包所传出的网络接口，需要与OUTPUT配合
* `-p 协议`：设置此规则适用于哪种数据包格式
    * 主要的数据包格式有：tcp、udp、icmp以及all
* `-s 来源IP/网络`：设置此规则之数据包的来源地，可指定单纯的IP或网络
    * `IP`：例如`192.168.0.100`
    * `网络`：例如`192.168.0.0/24`、`192.168.0.0/255.255.255.0`均可
    * __若规范为"不许"时，加上`!`即可，例如`! -s 192.168.100.0/24`__
* `-d 目标 IP/网络`：同-s，只不过这里是目标的
* `-j`：后面接操作
    * `ACCEPT`
    * `DROP`
    * `QUEUE`
    * `RETURN`
    * __其他Chain__
* __重要的原则：没有指定的项目，就表示该项目完全接受__
    * 例如`-s`和`-d`不指定，就表示来源或去向的任意IP/网络都接受

__示例：__

* `iptables -A INPUT -i lo -j ACCEPT`：不论数据包来自何处或去向哪里，只要是lo这个接口，就予以接受，这就是所谓的信任设备
* `iptables -A INPUT -i eth1 -j ACCEPT`：添加接口为eth1的网卡为信任设备
* `iptables -A INPUT -s 192.168.2.200 -j LOG`：该网段的数据包，其相关信息就会被写入到内核日志文件中，即`/var/log/messages`，然后，该数据包会继续进行后续的规则比对(这一点与其他规则不同)

## 34.5 TCP、UDP的规则：针对端口设置

TCP与UDP比较特殊的就是端口(port)，在TCP方面则另外有所谓的连接数据包状态，包括最常见的SYN主动连接的数据包格式

__格式：__

* `iptables [-AI 链] [-io 网络接口] [-p tcp|udp] [-s 来源IP/网络] [--sport 端口范围] [-d 目标IP/网络] [--dport 端口范围] --syn -j [ACCEPT|DROP|REJECT]`

__参数说明：__

* `--sport 端口范围`：限制来源的端口号码，端口号码可以是连续的，例如1024:65535
* `--dport 端口范围`：限制目标的端口号码
* `--syn`：主动连接的意思
* __与之前的命令相比，就是多了`--sport`以及`--dport`这两个选项，因此想要使用`--dport`或`--sport`必须加上`-p tcp`或`-p udp`才行__

__示例：__

* `iptables -A INPUT -i eth0 -p tcp --dport 21 -j DROP`：想要进入本机port 21的数据包都阻挡掉
* `iptables -A INPUT -i eth0 -p tcp --sport 1:1023 --dport 1:1023 --syn -j DROP`：来自任何来源port 1:1023的主动连接到本机端的1:1023连接丢弃

## 34.6 iptables匹配扩展

`iptables`可以使用扩展的数据包匹配模块。当指定`-p`或`--protocol`时，或者使用`-m`或`--match`选项，后跟匹配的模块名称；之后，取决于特定的模块，可以使用各种其他命令行选项。可以在一行中指定多个扩展匹配模块，并且可以在指定模块后使用`-h`或`--help`选项来接收特定于该模块的帮助文档（`iptables -m comment -h`，输出信息的最下方有`comment`模块的参数说明）

__常用模块__，详细内容请参考[Match Extensions](https://linux.die.net/man/8/iptables)

1. `comment`：增加注释
1. `conntrack`：与连接跟踪结合使用时，此模块允许访问比“状态”匹配更多的连接跟踪信息。（仅当iptables在支持该功能的内核下编译时，此模块才存在）
1. `tcp`
1. `udp`

## 34.7 iptables目标扩展

iptables可以使用扩展目标模块，并且可以在指定目标后使用`-h`或`--help`选项来接收特定于该目标的帮助文档（`iptables -j DNAT -h`）

__常用__

1. `DNAT`
1. `SNAT`
1. `REJECT`

## 34.8 ICMP数据包规则的比对：针对是否响应ping来设计

__格式：__

* `iptables -A INPUT [-p icmp] [--icmp-type 类型] -j ACCEPT`

__参数说明：__

* `--icmp-type`：后面必须要接ICMP的数据包类型，也可以使用代号

# 35 nsenter

nsenter用于在某个网络命名空间下执行某个命令。例如某些docker容器是没有curl命令的，但是又想在docker容器的环境下执行，这个时候就可以在宿主机上使用nsenter

__格式：__

* `nsenter -t <pid> -n <cmd>`

__参数说明：__

* `-t`：后接进程id
* `-n`：后接需要执行的命令

__示例：__

* `nsenter -t 123 -n curl baidu.com`

# 36 iostat

__格式：__

* `iostat [ -c | -d ] [ -k | -m ] [ -t ] [ -x ] [ interval [ count ] ]`

__参数说明：__

* `-c`：与`-d`互斥，只显示cpu相关的信息
* `-d`：与`-c`互斥，只显示磁盘相关的信息
* `-k`：以`kB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-m`：以`MB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-t`：打印日期信息
* `-x`：打印扩展信息
* `interval`: 打印间隔
* `count`: 打印几次，不填一直打印

__示例：__

* `iostat -d -t -x 1`

# 37 socat

__格式：__

* `socat [options] <address> <address>`
* 其中这2个`address`就是关键了，`address`类似于一个文件描述符，Socat所做的工作就是在2个`address`指定的描述符间建立一个 `pipe`用于发送和接收数据

__参数说明：__

* `address`：可以是如下几种形式之一
    * `-`：表示标准输入输出
    * `/var/log/syslog`：也可以是任意路径，如果是相对路径要使用`./`，打开一个文件作为数据流。
    * `TCP:127.0.0.1:1080`：建立一个TCP连接作为数据流，TCP也可以替换为UDP
    * `TCP-LISTEN:12345`：建立TCP监听端口，TCP也可以替换为UDP
    * `EXEC:/bin/bash`：执行一个程序作为数据流。

__示例：__

* `socat - /var/www/html/flag.php`：通过Socat读取文件，绝对路径
* `socat - ./flag.php`：通过Socat读取文件，相对路径
* `echo "This is Test" | socat - /tmp/hello.html`：写入文件
* `socat TCP-LISTEN:80,fork TCP:www.baidu.com:80`：将本地端口转到远端
* `socat TCP-LISTEN:12345 EXEC:/bin/bash`：在本地开启shell代理

# 38 dhclient

__格式：__

* `dhclient [-dqr]`

__参数说明：__

* `-d`：总是以前台方式运行程序
* `-q`：安静模式，不打印任何错误的提示信息
* `-r`：释放ip地址

__示例：__

* `dhclient`：获取ip
* `dhclient -r`：释放ip

# 39 tc

流量的处理由三种对象控制，它们是：`qdisc`（排队规则）、`class`（类别）和`filter`（过滤器）。

__格式：__

* `tc qdisc [ add | change | replace | link ] dev DEV [ parent qdisc-id | root ] [ handle qdisc-id ] qdisc [ qdisc specific parameters ]`
* `tc class [ add | change | replace ] dev DEV parent qdisc-id [ classid class-id ] qdisc [ qdisc specific parameters ]`
* `tc filter [ add | change | replace ] dev DEV [ parent qdisc-id | root ] protocol protocol prio priority filtertype [ filtertype specific parameters ] flowid flow-id`
* `tc [-s | -d ] qdisc show [ dev DEV ]`
* `tc [-s | -d ] class show dev DEV`
* `tc filter show dev DEV`

__参数说明：__

__示例：__

* `tc qdisc add dev em1 root netem delay 300ms`：设置网络延迟300ms
* `tc qdisc add dev em1 root netem loss 8% 20%`：设置8%~20%的丢包率 
* `tc qdisc del dev em1 root `：删除指定设置

# 40 free

__格式：__

* `free [-b|-k|-m|-g] [-t]`

__参数说明：__

* `-b`：bytes
* `-m`：MB
* `-k`：KB
* `-g`：GB

__显示参数介绍__：

* `Men`：物理内存
* `Swap`：虚拟内存
* `total`：总量
* `user`：使用量
* `free`：剩余可用量
* `shared`与`buffers/cached`：被使用的量当中用来作为缓冲以及快取的量
* `buffers`：缓冲记忆
* `cached`：缓存
* __一般来说系统会很有效地将所有内存用光，目的是为了让系统的访问性能加速，这一点与Windows很不同，因此对于Linux系统来说，内存越大越好__

__示例：__

* `free -m`

# 41 swap

__制作swap__

```sh
dd if=/dev/zero of=/tmp/swap bs=1M count=128
mkswap /tmp/swap
swapon /tmp/swap
free
```

# 42 route

__格式：__

* `route [-nee]`
* `route add [-net|-host] [网络或主机] netmask [mask] [gw|dev]`
* `route del [-net|-host] [网络或主机] netmask [mask] [gw|dev]`

__参数说明：__

* `-n`：不要使用通信协议或主机名，直接使用IP或port number，即在默认情况下，route会解析出该IP的主机名，若解析不到则会有延迟，因此一般加上这个参数
* `-ee`：显示更详细的信息
* `-net`：表示后面接的路由为一个网络
* `-host`：表示后面接的为连接到单个主机的路由
* `netmask`：与网络有关，可设置netmask决定网络的大小
* `gw`：gateway的缩写，后接IP数值
* `dev`：如果只是要制定由哪块网卡连接出去，则使用这个设置，后接网卡名，例如eth0等

__打印参数说明：__

* __Destination、Genmask__：这两个参数就分别是network与netmask
* __Gateway__：该网络通过哪个Gateway连接出去，若显示`0.0.0.0(default)`表示该路由直接由本级传送，也就是通过局域网的MAC直接传送，如果显示IP的话，表示该路由需要经过路由器(网关)的帮忙才能发送出去
* __Flags__：
    * `U(route is up)`：该路由是启动的
    * `H(target is a host)`：目标是一台主机而非网络
    * `G(use gateway)`：需要通过外部的主机来传递数据包
    * `R(reinstate route for dynamic routing)`：使用动态路由时，恢复路由信息的标志
    * `D(Dynamically installed by daemon or redirect)`：动态路由
    * `M(modified from routing daemon or redirect)`：路由已经被修改了
    * `!(reject route)`：这个路由将不会被接受
* __Iface__：该路由传递数据包的接口

__示例：__

* `route -n`
* `route add -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`
* `route del -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`

# 43 tsar

__格式：__

* `tsar [-l]`

__参数说明：__

* `-l`：查看实时数据

__示例：__

* `tsar -l`

# 44 watch

__格式：__

* `watch [option] [cmd]`

__参数说明：__

* `-n`：watch缺省该参数时，每2秒运行一下程序，可以用`-n`或`-interval`来指定间隔的时间
* `-d`：`watch`会高亮显示变化的区域。`-d=cumulative`选项会把变动过的地方(不管最近的那次有没有变动)都高亮显示出来
* `-t`：关闭watch命令在顶部的时间间隔命令，当前时间的输出

__示例：__

* `watch -n 1 -d netstat -ant`：每隔一秒高亮显示网络链接数的变化情况
* `watch -n 1 -d 'pstree | grep http'`：每隔一秒高亮显示http链接数的变化情况
* `watch 'netstat -an | grep :21 | grep <ip> | wc -l'`：实时查看模拟攻击客户机建立起来的连接数
* `watch -d 'ls -l | grep scf'`：监测当前目录中 scf' 的文件的变化
* `watch -n 10 'cat /proc/loadavg'`：10秒一次输出系统的平均负载

# 45 dstat

__格式：__

* `dstat [options]`

__示例：__

* `dstat -h`：参数说明
* `dstat 5 10`：5秒刷新一次，刷新10次
* `dstat -cdgilmnprstTy`

# 46 nethogs

# 47 iptraf

# 48 ifstat

该命令用于查看网卡的流量状况，包括成功接收/发送，以及错误接收/发送的数据包，看到的东西基本上和`ifconfig`类似

# 49 iftop

# 50 ssh

__格式：__

* `ssh [-f] [-o options] [-p port] [account@]host [command]`

__参数说明：__

* `-f`：需要配合后面的[command]，不登录远程主机直接发送一个命令过去而已
* `-o`：后接`options`
    * `ConnectTimeout=<seconds>`：等待连接的秒数，减少等待的事件
    * `StrictHostKeyChecking=[yes|no|ask]`：默认是ask，若要让public key主动加入known_hosts，则可以设置为no即可
* `-p`：后接端口号，如果sshd服务启动在非标准的端口，需要使用此项目

__示例：__

* `ssh 127.0.0.1`：由于SSH后面没有加上账号，因此默认采用当前的账号来登录远程服务器
* `ssh student@127.0.0.1`：账号为该IP的主机上的账号，而非本地账号哦
* `ssh student@127.0.0.1 find / &> ~/find1.log`
* `ssh -f student@127.0.0.1 find / &> ~/find1.log`：会立即注销127.0.0.1，find在远程服务器运行

## 50.1 免密登录

__Client端步骤__

1. `ssh-keygen [-t rsa|dsa]`
1. `scp ~/.ssh/id_rsa.pub [account@]host:~`

__Server端步骤__

1. `mkdir ~/.ssh; chmod 700 .ssh`，若不存在`~/.ssh`文件夹，则创建
1. `cat id_rsa.pub >> .ssh/authorized_keys`
1. `chmod 644 .ssh/authorized_keys`

# 51 scp

__格式：__

* `scp [-pPr] [-l 速率] local_file [account@]host:dir`
* `scp [-pPr] [-l 速率] [account@]host:file local_dir`

__参数说明：__

* `-p`：保留源文件的权限信息
* `-P`：指定端口号
* `-r`：复制来源为目录时，可以复制整个目录(含子目录)
* `-l`：可以限制传输速率，单位Kbits/s

__示例：__

* `scp /etc/hosts* student@127.0.0.1:~`
* `scp /tmp/Ubuntu.txt root@192.168.136.130:~/Desktop`
* `scp -P 16666 root@192.168.136.130:/tmp/test.log ~/Desktop`：指定主机`192.168.136.130`的端口号为16666

# 52 chsh

__格式：__

* `chsh [-ls]`

__参数说明：__

* `-l`：列出目前系统上可用的shell，其实就是`/etc/shells`的内容
* `-s`：设置修改自己的shell

# 53 sudo

__注意，sudo本身是一个进程。比如用`sudo tail -f xxx`，在另一个会话中`ps aux | grep tail`会发现两个进程__

__配置文件：__

* `/etc/sudoers`

<!--

__格式：__

* `find [文件路径] [option] [action]`

__参数说明：__

* `-name`：后接文件名，支持通配符。__注意匹配的是相对路径__

__示例：__

* `find . -name "*.c"`

-->

# 54 参考

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
