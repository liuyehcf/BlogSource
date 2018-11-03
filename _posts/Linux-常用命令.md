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

# 1 查看文件内容

## 1.1 cat

__格式：__

* `cat > [newfile] <<'结束字符'`

# 2 字符串处理命令

## 2.1 sed

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

## 2.2 awk

相比于sed(管道命令)常常作用于一整行的处理，awk(管道命令)则比较倾向于将一行分成数个"字段"来处理，因此awk相当适合处理小型的数据处理

__格式：__

* `awk [-F] '条件类型1{动作1} 条件类型2{动作2}...' [filename]`

__参数说明：__

* `-F`：后接分隔符。例如：`-F ':'`、`-F '[,.;]'`

注意awk后续的所有动作都是以单引号括住的，而且如果以print打印时，非变量的文字部分，包括格式等(例如制表`\t`、换行`\n`等)都需要以双引号的形式定义出来，因为单引号已经是awk的命令固定用法了。例如`last -n 5 | awk '{print $1 "\t" $3}'`

__awk处理流程：__

1. 读入第一行，并将第一行的数据填入$0,$1,...等变量中
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
* 
```shell
awk 
'BEGIN {FS=":";print "统计销售金额";total=0} 
{print $3;total=total+$3;} 
END {print "销售金额总计：",total}' sx
```

### 2.2.1 如何在awk中引用变量

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

### 2.2.2 在awk中写简单的控制流语句

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

## 2.3 grep

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

# 3 查找

## 3.1 find

__格式：__

* `find [文件路径] [option] [action]`

__参数说明：__

* `-name`：后接文件名，支持通配符。__注意匹配的是相对路径__
* `-regex`：后接正则表达式，__注意匹配的是完整路径__

__示例：__

* `find . -name "*.c"`
* `find . -regex ".*/.*\.c"`

# 4 文件压缩

## 4.1 tar

__格式：__

* 压缩：`tar -jcv -f [压缩创建的文件(*.tar.bz2)] [被压缩的文件或目录1] [被压缩的文件或目录2]...`
* 查询：`tar -jtv -f [压缩文件(*.tar.bz2)]`
* 解压缩：`tar -jxv -f [压缩文件(*.tar.bz2)] -C [欲解压的目录]`

__参数说明：__

* `-c`：新建打包文件，可以搭配-v查看过程中被打包的文件名
* `-t`：查看打包文件的内容含有那些文件名，终点在查看文件
* `-x`：解打包或解压缩的功能，可搭配-C在特定目录解开
* __注意，c t x是互斥的__
* `-j`：通过bzip2的支持进行压缩/解压，此时文件名最好为*.tar.bz2
* `-z`：通过gzip的支持进行压缩/解压，此时文件名最好是*.tar.gz
* `-v`：在压缩/解压缩过程中，将正在处理的文件名显示出来
* `-f` filename：-f后面接要被处理的文件名，建议-f单独写一个参数
* `-C` [目录名]：用于在解压时指定解压目录
* `-p`：保留备份数据原本权限与属性，常用语备份(-c)重要的配置文件
* `-P`：保留绝对路径，即允许备份数据中含有根目录存在之意

# 5 文件系统

## 5.1 tree

__格式：__

* `tree [option]`

__参数说明：__

* `-N`：显示非ASCII字符，可以显示中文

# 6 进程管理

## 6.1 &

在命令最后加上`&`代表将命令丢到后台执行

* 此时bash会给予这个命令一个工作号码(job number)，后接该命令触发的PID
* 不能被[Ctrl]+C中断
* 在后台中执行的命令，如果有stdout以及stderr时，它的数据依旧是输出到屏幕上面，所以我们会无法看到提示符，命令结束后，必须按下[Enter]才能看到命令提示符，同时也无法用[Ctrl]+C中断。解决方法就是利用数据流重定向

__示例：__

* `tar -zpcv -f /tmp/etc.tar.gz /etc > /tmp/log.txt 2>&1 &`

## 6.2 Ctrl+C

终止当前进程

## 6.3 Ctrl+Z

暂停当前进程

## 6.4 jobs

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

## 6.5 fg

将后台工作拿到前台来处理

__示例：__

* `fg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `fg +`：取出标记为+的工作
* `fg -`：取出标记为-的工作`

## 6.6 bg

让工作在后台下的状态变为运行中

__示例：__

* `bg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `bg +`：取出标记为+的工作
* `bg -`：取出标记为-的工作
* 不能让类似vim的工作变为运行中，即便使用该命令会，该工作又立即变为暂停状态

## 6.7 kill

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

## 6.8 ps

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

## 6.9 top

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
* __top默认使用CPU使用率作为排序的终点__

## 6.10 pstree

__格式：__

* `pstree [-A|U] [-up]`

__参数说明：__

* `-A`：各进程树之间的连接以ASCII字符来连接(连接符号是ASCII字符)
* `-U`：各进程树之间的连接以utf8码的字符来连接，在某些终端接口下可能会有错误(连接符号是utf8字符，比较圆滑好看)
* `-p`：同时列出每个进程的PID
* `-u`：同时列出每个进程所属账号名称

## 6.11 lsof

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

# 7 网络管理

## 7.1 netstat

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

__显示参数说明：__

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

## 7.2 route

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

## 7.3 tcpdump

__格式：__

* `tcpdump [-AennqX] [-i 接口] [port 端口号] [-w 存储文件名] [-c 次数] [-r 文件] [所要摘取数据包的格式]`

__参数说明：__

* `-A`：数据包的内容以ASCII显示，通常用来抓取WWW的网页数据包数据
* `-e`：使用数据链路层(OSI第二层)的MAC数据包数据来显示
* `-nn`：直接以IP以及port number显示，而非主机名与服务名称
* `-q`：仅列出较为简短的数据包信息，每一行的内容比较精简
* `-X`：可以列出十六进制(hex)以及ASCII的数据包内容，对于监听数据包很有用
* `-i`：后面接要监听的网络接口，例如eth0等
* `port`：后接要监听的端口号，例如22等
* `-w`：将监听得到的数据包存储下来
* `-r`：从后面接的文件将数据包数据读出来
* `-c`：监听数据包数，没有这个参数则会一直监听，直到[ctrl]+C

__示例：__

* `tcpdump -i lo0 port 22 -w output7.cap`

# 8 远程连接

## 8.1 ssh

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

### 8.1.1 免密登录

__Client端步骤__

1. `ssh-keygen [-t rsa|dsa]`
1. `scp ~/.ssh/id_rsa.pub [account@]host:~`

__Server端步骤__

1. `mkdir ~/.ssh; chmod 700 .ssh`，若不存在`~/.ssh`文件夹，则创建
1. `cat id_rsa.pub >> .ssh/authorized_keys`
1. `chmod 644 .ssh/authorized_keys`

## 8.2 scp

__格式：__

* `scp [-pr] [-l 速率] local_file [account@]host:dir`
* `scp [-pr] [-l 速率] [account@]host:file local_dir`

__参数说明：__

* `-p`：保留源文件的权限信息
* `-r`：复制来源为目录时，可以复制整个目录(含子目录)
* `-l`：可以限制传输速率，单位Kbits/s

__示例：__

* `scp /etc/hosts* student@127.0.0.1:~`
* `scp /tmp/Ubuntu.txt root@192.168.136.130:~/Desktop`

# 9 账号管理

## 9.1 chsh

__格式：__

* `chsh [-ls]`

__参数说明：__

* `-l`：列出目前系统上可用的shell，其实就是`/etc/shells`的内容
* `-s`：设置修改自己的shell

# 10 权限管理

## 10.1 sudo

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

# 11 参考

* 《鸟哥的Linux私房菜》
* [linux shell awk 流程控制语句（if,for,while,do)详细介绍](https://www.cnblogs.com/chengmo/archive/2010/10/04/1842073.html)
