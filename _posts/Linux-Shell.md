---
title: Linux-Shell
date: 2018-05-20 18:48:20
tags: 
- 原创
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 管道

__管道命令使用的是`|`这个界定符号，这个管道命令`|`仅能处理有前面一个命令传来的`正确信息`，也就是`standard output`的信息，对于standard error并没有直接处理的能力__

__每个管道后面接的`第一个数据必须是命令`，而且这个命令必须能够接受`standard input`的数据才行，例如`less，more，head，tail`等都可以接受standard input的管道命令__

__管道是作为子进程的方式来运行的。因此在管道中进行一些变量赋值操作，在管道结束后会丢失__

# 2 命令替换

__`命令替换(command substitution)`可以让`括号里`或`单引号里`的命令提前于整个命令运行，然后将`执行结果`插入在命令替换符号处。由于命令替换的结果经常交给外部命令，不应该让结果有换行的行为，所以默认将所有的换行符替换为了空格(实际上所有的空白符都被压缩成了单个空格)__

__`命令替换(command substitution)`有如下种形式__

1. \``command`\`
1. `$(command)`
* __同时，上述两种方式也可以被包围在`""`之中，这样就可以保留命令行执行结果的空白__

```sh
echo "what date it is? $(date +%F)"

# 看看下面两个指令的差异
echo "$(ls)"
echo $(ls)
```

# 3 进程替换

__进程替换(Process Substitution)的作用有点类似管道，但在实现方式上有所区别，管道是作为子进程的方式来运行的，而进程替换会在`/dev/fd/`下面产生类似`/dev/fd/63`,`/dev/fd/62`这类临时文件，用来传递数据。用法如下：__

1. __`<(command)`：用来产生标准输出，借助输入重定向，它的结果可以作为另一个命令的输入__
    * `cat <(ls)`
1. __`>(command)`：用来接收标准输入，借助输出重定向，它可以接收另一个命令的输出结果__
    * `ls > >(cat)`
* __注意`<`、`>`与`(`之间不能有空格__

```sh
cat <(ls)   #把 <(ls) 当一个临时文件，文件内容是ls的结果，cat这个临时文件
ls > >(cat) #把 >(cat) 当成临时文件，ls的结果重定向到这个文件，最后这个文件被cat
```

__典型示例，统计文件个数__

```sh
# 正确方式
count=0
while read line
do
    ((count++))
done < <(ls)
echo ${count}

# 错误方式
count=0
ls | while read line
do
    ((count++))
done
echo ${count} # 永远是0
```

__简单读取__

```sh
#!/bin/bash

#这里默认会换行  
echo "输入网站名: "  
#读取从键盘的输入  
read website  
echo "你输入的网站名是 $website"  
exit 0  #退出
```

__`-p`参数，允许在`read`命令行中直接指定一个提示__

```sh
#!/bin/bash

read -p "输入网站名:" website
echo "你输入的网站名是 $website" 
exit 0
```

__`-t`参数指定`read`命令等待输入的秒数，当计时满时，`read`命令返回一个非零退出状态__

```sh
#!/bin/bash

if read -t 5 -p "输入网站名:" website
then
    echo "你输入的网站名是 $website"
else
    echo "\n抱歉，你输入超时了。"
fi
exit 0
```

__`-n`参数设置`read`命令计数输入的字符。当输入的字符数目达到预定数目时，自动退出，并将输入的数据赋值给变量__

```sh
#!/bin/bash

read -n1 -p "Do you want to continue [Y/N]?" answer
case $answer in
    Y|y)
      echo "fine ,continue";;
    N|n)
      echo "ok,good bye";;
    *)
     echo "error choice";;
esac
exit 0
```

__`-s`选项能够使`read`命令中输入的数据不显示在命令终端上（实际上，数据是显示的，只是`read`命令将文本颜色设置成与背景相同的颜色）。输入密码常用这个选项__

```sh
#!/bin/bash

read  -s  -p "请输入您的密码:" pass
echo "\n您输入的密码是 $pass"
exit 0
```

__按行读取文件__

```sh
#!/bin/bash
  
count=1    # 赋值语句，不加空格
cat test.txt | while read line      # cat 命令的输出作为read命令的输入,read读到>的值放在line中
do
   echo "Line $count:$line"
   count=$[ $count + 1 ]          # 注意中括号中的空格。
done
echo "finish"
exit 0
```

# 4 数值运算

## 4.1 `$[]`

__整数扩展，会返回执行后的结果。如果有`,`分隔，那么只返回最后一个表达式执行的结果__

```sh
echo $[ 1 + 3 ]

a=10;b=5
echo $[ $a + $b ]
echo $[ $a - $b ]
echo $[ $a * $b ]       #此时不用对*转义
echo $[ $a / $b ]
echo $[ $a % $b ]

echo $[ 1 + 3, 5 + 6 ]
```

## 4.2 expr

__`expr`是一个用于数值计算的命令，运算符号两边必须加空格，不加空格会原样输出，不会计算__

```sh
expr 1 + 3
 
a=10;b=5
expr $a + $b
expr $a - $b
expr $a \* $b   #因为乘号*在shell中有特殊的含义，所以要转义
expr $a / $b    #除法取商
expr $a % $b    #除法取模
```

## 4.3 `$(())`

__`$(())`有如下两个功能__

1. 数值计算
1. 进制转换
* __在`$(())`中的变量名称，可于其前面加$符号来替换，也可以不用__

```sh
# 数值计算
a=5;b=7;c=2
echo $((a+b*c))
echo $(($a+$b*$c))

# 进制转换
a=06;b=09;c=02;
echo $(( 10#$a + 10#$b + 10#$c ))
echo $((16#ff))
echo $((8#77))
```

## 4.4 `(())`

__整数扩展，只计算，不返回值。通常用于重定义变量值，只有赋值语句才能起到重定义变量的作用__

```sh
a=1
((a+10))
echo $a     # 输出1

((a+=10))
echo $a     # 输出11

((a++))
echo $a     # 输出12
```

# 5 特殊符号

shell中的特殊符号包括如下几种

1. __`#`：注释符号(Hashmark[Comments])__
    * 在shell文件的行首，作为shebang标记，`#!/bin/bash`
    * 其他地方作为注释使用，在一行中，#后面的内容并不会被执行
    * 但是用单/双引号包围时，#作为#号字符本身，不具有注释作用
1. __`;`：分号，作为多语句的分隔符(Command separator [semicolon])__
    * 多个语句要放在同一行的时候，可以使用分号分隔
1. __`;;`：连续分号(Terminator [double semicolon])__
    * 在使用case选项的时候，作为每个选项的终结符
1. __`.`：点号(dot command [period])__
    * 相当于bash内建命令source
    * 作为文件名的一部分，在文件名的开头
    * 作为目录名，一个点代表当前目录，两个点号代表上层目录（当前目录的父目录）
    * 正则表达式中，点号表示任意一个字符
1. __`"`：双引号（partial quoting [double quote]）__
    * 双引号包围的内容可以允许变量扩展，__允许转义字符的存在__。如果字符串内出现双引号本身，需要转义。因此不一定双引号是成对的
1. __`'`：单引号(full quoting [single quote])__
    * 单引号内的禁止变量扩展，__不允许转义字符的存在，所有字符均作为字符本身处理（除单引号本身之外）__。单引号必须成对出现
1. __`,`：逗号(comma operator [comma])__
    * 用在连接一连串的数学表达式中，这串数学表达式均被求值，但只有最后一个求值结果被返回。例如`echo $[1+2,3+4,5+6]`返回11
    * 用于参数替代中，表示首字母小写，如果是两个逗号，则表示全部小写。这个特性在`bash version 4`的时候被添加的（Mac OS不支持）
        * `a="ATest";echo ${a,}` 输出aTest
        * `a="ATest";echo ${a,,}` 输出atest
1. __`\`：反斜线，反斜杆(escape [backslash])__
    * 放在特殊符号之前，转义特殊符号的作用，仅表示特殊符号本身，这在字符串中常用
    * 放在一行指令的最末端，表示紧接着的回车无效（其实也就是转义了Enter），后继新行的输入仍然作为当前指令的一部分
1. __`/`：斜线，斜杆（Filename path separator [forward slash]）__
    * 作为路径的分隔符，路径中仅有一个斜杆表示根目录，以斜杆开头的路径表示从根目录开始的路径
    * 在作为运算符的时候，表示除法符号
1. __\`` `\`：反引号，后引号（Command substitution[backquotes])__
    * 命令替换。这个引号包围的为命令，可以执行包围的命令，并将执行的结果赋值给变量
1. __`:`：冒号(null command [colon])__
    * 空命令，这个命令什么都不做，但是有返回值，返回值为0
    * 可做while死循环的条件
    * 在if分支中作为占位符（即某一分支什么都不做的时候）
    * 放在必须要有两元操作的地方作为分隔符
    * 可以作为域分隔符，比如环境变量$PATH中，或者passwd中，都有冒号的作为域分隔符的存在
1. __`!`：感叹号，取反一个测试结果或退出状态（reverse (or negate) [bang],[exclamation mark])__
    * 表示反逻辑，例如`!=`表示不等于
1. __`*`：星号（wildcard/arithmetic operator[asterisk])__
    * 作为匹配文件名扩展的一个通配符，能自动匹配给定目录下的每一个文件
    * 正则表达式中可以作为字符限定符，表示其前面的匹配规则匹配任意次
    * 算术运算中表示乘法
1. __`**`：双星号(double asterisk)__
    * 算术运算中表示求幂运算
1. __`?`：问号（test operator/wildcard[Question mark])__
    * 表示条件测试
    * 条件语句（三元运算符）
    * 参数替换表达式中用来测试一个变量是否设置了值，例如`echo ${a?}`，若a已经设定过值，则与`echo ${a}`相同，否则会出现异常信息`parameter null or not set`
    * 作为通配符，用于匹配文件名扩展特性中，用于匹配单个字符
    * 正则表达式中，表示匹配其前面规则0次或者1次
1. __`$`：美元符号(Variable substitution[Dollar sign])__
    * 作为变量的前导符，用作变量替换，即引用一个变量的内容
    * 在正则表达式中被定义为行末
    * 特殊变量
        * __`$*`__、`$@`：位置参数。这个在使用脚本文件的时候，在传递参数的时候会用到。两者都能返回调用脚本文件的所有参数，但`$*`是将所有参数作为一个整体返回（字符串），而`$@`是将每个参数作为单元返回一个参数列表。注意，在使用的时候需要用双引号将`$*`，`$@`括住。这两个变量受到`$IFS`的影响，如果在实际应用中，要考虑其中的一些细节
        * __`$#`__：表示传递给脚本的参数数量
        * __`$?`__：此变量值在使用的时候，返回的是最后一个命令、函数、或脚本的退出状态码值，如果没有错误则是0，如果为非0，则表示在此之前的最后一次执行有错误
        * __`$$`__：进程ID变量，这个变量保存了运行当前脚本的进程ID值
1. __`()`：圆括号(parentheses)__
    * 命令组（Command group）。由一组圆括号括起来的命令是命令组，__命令组中的命令是在子shell（subshell）中执行__。因为是在子shell内运行，因此在括号外面是没有办法获取括号内变量的值，但反过来，命令组内是可以获取到外面的值，这点有点像局部变量和全局变量的关系，在实作中，如果碰到要cd到子目录操作，并在操作完成后要返回到当前目录的时候，可以考虑使用subshell来处理
    * 用于数组初始化
1. __`{}`：代码块(curly brackets)__
    * 这个是匿名函数，但是又与函数不同，在代码块里面的变量在代码块后面仍能访问
1. __`[]`：中括号（brackets）__
    * __`[`是bash的内部命令__（注意与`[[`的区别）
    * 作为test用途，不支持正则
    * 在数组的上下文中，表示数组元素的索引，方括号内填上数组元素的位置就能获得对应位置的内容，例如`${ary[1]}`
    * 在正表达式中，方括号表示该位置可以匹配的字符集范围
1. __`[[]]`：双中括号(double brackets)__
    * __`[[`是 bash 程序语言的关键字__（注意与`[`的区别）
    * 作为test用途。`[[]]`比`[]`支持更多的运算符，比如：`&&,||,<,>`操作符。同时，支持正则，例如`[[ hello == hell? ]]`
    * bash把双中括号中的表达式看作一个单独的元素，并返回一个退出状态码
1. __`$[...]`：表示整数扩展(integer expansion)__
    * 详见[数值运算](#数值运算)
1. __`(())`：双括号(double parentheses)__
    * 详见[数值运算](#数值运算)
1. __`> >& >> < &< << <>`：重定向(redirection)__
    * 详见[重定向](#重定向)
1. __`|`：管道__
    * 详见[管道](#管道)
1. __`(command)>  <(command)`：进程替换(Process Substitution)__
    * 详见[进程替换](#进程替换)
1. __`&& ||`：逻辑操作符__
    * 在测试结构中，可以用这两个操作符来进行连接两个逻辑值
1. __`&`：与号(Run job in background[ampersand])__
    * 如果命令后面跟上一个&符号，这个命令将会在后台运行

# 6 判断式

__关于某个文件名的“文件类型”判断，如`test -e filename`__

* __`-e`：该文件名是否存在__
* __`-f`：该文件名是否存在且为文件__
* __`-d`：该文件名是否存在且为目录__
* `-b`：该文件名是否存在且为一个block device设备
* `-c`：该文件名是否存在且为一个character device设备
* `-S`：该文件名是否存在且为一个Socket文件
* `-p`：该文件名是否存在且为以FIFO(pipe)文件
* `-L`：该文件名是否存在且为一个链接文件

__关于文件的权限检测，如`test -r filename`__

* __`-r`：检测该文件名是否存在且具有"可读"的权限__
* __`-w`：检测该文件名是否存在且具有"可写"的权限__
* __`-x`：检测该文件名是否存在且具有"可执行"的权限__
* `-u`：检测该文件名是否存在且具有"SUID"的属性
* `-g`：检测该文件名是否存在且具有"GUID"的属性
* `-k`：检测该文件名是否存在且具有"Sticky bit(SBIT)"的属性
* `-s`：检测该文件名是否存在且为"非空白文件"

__两个文件之间的比较，如`test file1 -nt file2`__

* `-nt`：(newer than) 判断file1是否比file2新
* `-ot`：(older than) 判断file1是否比file2旧
* `-ef`：判断file1与file2是否为同一文件，可用在判断hard link的判断上，主要意义在于判断两个文件是否均指向同一个inode

__数值比较，如`test n1 -eq n2`__

* __`-eq`：两数值相等(equal)__
* __`-ne`：两数值不等(not equal)__
* __`-gt`：n1大于n1(greater than)__
* __`-lt`：n1小于n2(less than)__
* __`-ge`：n1大于等于n2(greater than or equal)__
* __`-le`：n1小于n2(less than or equal)__

__字符串比较，例如`test n1 == n2`__

* __`-z`：判定字符串是否为空，空返回true__
    * __在`[]`中，变量需要加引号，例如`[ -z "${a}}" ]`__
    * __在`[[]]`中，变量需要加引号，例如`[[ -z ${a}} ]]`__
* __`-n`：判断字符串是否为空，非空返回true__
    * __在`[]`中，变量需要加引号，例如`[ -n "${a}}" ]`__
    * __在`[[]]`中，变量需要加引号，例如`[[ -n ${a}} ]]`__
* __`=`或`==`：判断str1是否等于str2，好像有问题，使用中括号正确__
* __`!=`：判断str1是否等于str2，好像有问题，使用中括号正确__
* __字符串变量的引用方式：`"${var_name}"`，即必须加上双引号`""`__

__逻辑与/或/非__

* __`-a`：两个条件同时成立，返回true，如test -r file1 -a -x file2__
* __`-o`：任一条件成立，返回true，如test -r file1 -o -x file2__
* __`!`：反向状态__

# 7 判断符号`[]`/`[[]]`

## 7.1 `[]`

__判断符号`[]`与判断式`test`用法基本一致，有以下几条注意事项__

1. 如果要在bash的语法当中使用括号作为shell的判断式时，__必须要注意在中括号的两端需要有空格符来分隔__
1. __逻辑与逻辑或，用的是`&&`和`||`，且需要将条件分开写，如下__
    * `[ condition1 ] && [ condition2 ]`
    * `[ condition1 ] || [ condition2 ]`

__示例__

```sh
# 正确写法
if [ 2 -gt 1 ] && [ 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [ 2 -gt 1 && 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 正确写法
if [ 2 -gt 1 -a 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [ 2 -gt 1 ] -a [ 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi
```

## 7.2 `[[]]`

__判断符号`[[]]`与判断式`test`用法基本一致，有以下几条注意事项__

1. 如果要在bash的语法当中使用括号作为shell的判断式时，__必须要注意在中括号的两端需要有空格符来分隔__
1. __逻辑与逻辑或，用的是`&&`和`||`，用一个`[]`或者用两个`[[]]`都可以，但使用`[[]]`时不能用`-a`和`-o`__

__示例__

```sh
# 正确写法
if [[ 2 -gt 1 ]] && [[ 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 正确写法
if [[ 2 -gt 1 && 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [[ 2 -gt 1 -a 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [[ 2 -gt 1 ]] -a [[ 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi
```

# 8 String

## 8.1 拼接字符串

```sh
your_name="qinjx"
greeting="hello, "${your_name}" \!"
echo ${greeting}
```

## 8.2 获取字符串长度

```sh
text="abcdefg"
echo "字符串长度为 ${#text}"
```

## 8.3 提取子字符串

下面以字符串`http://www.aaa.com/123.htm`为例，介绍几种不同的截取方式

__`#`：删除左边字符，保留右边字符__

* 其中`var`是变量名，`#`是运算符，`*`是通配符，表示从左边开始删除第一个`//`号及左边的所有字符。即删除`http://`，结果是`www.aaa.com/123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var#*//}
```

__`##`：删除左边字符，保留右边字符__

* 其中`var`是变量名，`##`是运算符，`*`是通配符，表示从左边开始删除最后（最右边）一个`/`号及左边的所有字符。即删除`http://www.aaa.com/`，结果是`123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var##*/}
```

__`%`：删除右边字符，保留左边字符__

* 其中`var`是变量名，`%`是运算符，`*`是通配符，表示从从右边开始，删除第一个`/`号及右边的字符。即删除`/123.htm`，结果是`http://www.aaa.com`

```sh
var='http://www.aaa.com/123.htm'
echo ${var%/*}
```

__`%%`：删除右边字符，保留左边字符__

* 其中`var`是变量名，`%%`是运算符，`*`是通配符，表示从右边开始，删除最后（最左边）一个`/`号及右边的字符。即删除`//www.aaa.com/123.htm`，结果是`http:`

```sh
var='http://www.aaa.com/123.htm'
echo ${var%%/*}
```

__从左边第几个字符开始，截取若干个字符__

* 其中`var`是变量名，`0`表示从左边第`1`个字符开始，`5`表示截取`5`个字符，结果是`http:`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0:5}
```

__从左边第几个字符开始，一直到结束__

* 其中`var`是变量名，`7`表示从左边第`8`个字符开始，结果是`www.aaa.com/123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:7}
```

__从右边第几个字符开始，及字符的个数__

* 其中`var`是变量名，`0-7`表示从右边第`7`字符开始，`3`表示截取`3`个字符，结果是`123`
* 注：
    * `k`表示从左边开始第`k+1`个字符
    * `0-k`表示从右边开始第`k`个字符

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7:3}
```

__从右边第几个字符开始，一直到结束__

* 其中`var`是变量名，`0-7`表示从右边第`7`字符开始，结果是`123.htm`
* 注：
    * `k`表示从左边开始第`k+1`个字符
    * `0-k`表示从右边开始第`k`个字符

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7}
```

## 8.4 条件默认值

__变量为空时，返回默认值__

```sh
echo ${FOO:-val2} # 输出val2
test -z "${FOO}"; echo $? # 输出0
FOO=val1
echo ${FOO:-val2} # 输出val1
```

__变量为空时，将变量设置为默认值，然后返回变量的值__

```sh
echo ${FOO:=val2} # 输出val2
test -z "${FOO}"; echo $? # 输出1
FOO=val1
echo ${FOO:=val2} # 输出val1
```

__变量不为空时，返回默认值__

```sh
FOO=val1
echo ${FOO:+val2} # 输出val2
FOO=
echo ${FOO:+val2} # 输出空白
```

__当变量为空时，输出错误信息并退出__

```sh
echo ${FOO:?error} # 输出error
```

## 8.5 按行读取

__方式1__

```sh
# 文件名不包含空格的话，可以不要引号
# 文件名若包含空格，且不用引号，则会报错：ambiguous redirect
while read line
do
　　echo $line
done < "test.txt"

# 或者利用 进程替换

while read line
do
　　echo $line
done < <(cmd) 
```

__方式2__

* __注意，在这种方式下，在while循环内的变量的赋值会丢失，因为管道相当于开启另一个进程__

```sh
STDOUT | while read line
do
　　echo $line
done
```

# 9 Array

Shell 数组用括号来表示，元素用`空格`符号分割开，语法格式如下：

```sh
array_name=(value1 ... valuen)

# 或者直接这样定义，注意，不需要${}
array_name[1]=value1
array_name[2]=value2
...
array_name[n]=valuen
```

__数组属性__

* `@`或`*`可以获取数组中的所有元素
```
${array[@]}
${array[*]}
```

* 获取数组长度的方法与获取字符串长度的方法相同，即利用`#`
```
${#array[@]}
${#array[*]}
```

__示例__

```sh
text='my name is liuye'
array=( $(echo ${text}) )

echo "数组元素为：${array[@]}"
echo "数组元素为：${array[*]}"

echo "数组长度为：${#array[@]}"
echo "数组长度为：${#array[*]}"

for element in ${array[@]}
do
    echo $element
done
```

__注意__

1. 数组下标从0开始

# 10 Map

Shell map用括号来表示，元素用`空格`符号分割开，语法格式如下：

```sh
declare -A map_name=([key1]=value1 ... [keyn]=valuen)

# 或者直接这样定义，注意，不需要${}
declare -A map_name
map_name[key1]=value1
map_name[key2]=value2
...
map_name[keyn]=valuen
```

__属性__

* `@`或`*`可以获取map中的所有value
```
${map[@]}
${map[*]}
```

* 获取map长度的方法与获取字符串长度的方法相同，即利用`#`
```
${#map[@]}
${#map[*]}
```

* `!`可以获取map中关键字集合
```
${!map[@]}
${!map[*]}
```

__示例__

```sh
declare -A map
map['a']=1
map['b']=2
map['c']=3

echo ${map[@]}
echo ${map[*]}

echo ${#map[@]}
echo ${#map[*]}

echo ${!map[@]}
echo ${!map[*]}

for key in ${!map[*]}
do
    echo "value=${map[${key}]}"
done
```

# 11 控制流

## 11.1 if

```sh
if condition
then
    command1 
    command2
    ...
    commandN 
fi
```

## 11.2 if else

```sh
if condition
then
    command1 
    command2
    ...
    commandN
else
    command
fi
```

## 11.3 if else-if else

```sh
if condition1
then
    command1
elif condition2 
then 
    command2
else
    commandN
fi
```

## 11.4 for

```sh
for var in item1 item2 ... itemN
do
    command1
    command2
    ...
    commandN
done
```

```sh
for ((i=1;i<=10;i++))
do
    command1
    command2
    ...
    commandN
done
```

## 11.5 while

```sh
while condition
do
    command
done
```

## 11.6 until

```sh
until condition
do
    command
done
```

## 11.7 case

```sh
case 值 in
模式1)
    command1
    command2
    ...
    commandN
    ;;
模式2）
    command1
    command2
    ...
    commandN
    ;;
esac
```

# 12 函数

## 12.1 参数传递

__传递数组__

1. 用`""`将数组转化成字符串

```sh
function func() {
    # 这里将传入的字符串解析成数组
    param=( $(echo $1) )
    echo "param=${param[*]}"
}

array=('a', 'b', 'c', 'd', 'e')

# 这里用""将数组转为字符串
func "${array[*]}"
```

## 12.2 标准输出

__返回数组__

```sh
function func() {
    # 这里将传入的字符串解析成数组
    array=('a' 'b' 'c' 'd' 'e')
    echo "${array[*]}"
}

# 这里用""将数组转为字符串
array=( $(func) )
echo ${array[*]}
```

## 12.3 返回值

```sh
function func() {
    # 这里必须返回非负整数
    return 66
}

func

# 获取函数返回值
echo $?
```

# 13 重定向

| 命令 | 说明 |
|:--|:--|
| `command > file` | 将输出重定向到`file` |
| `command < file` | 将输入重定向到`file` |
| `command >> file` | 将输出以追加的方式重定向到`file` |
| `n > file` | 将文件描述符为`n`的文件重定向到`file` |
| `n >> file` | 将文件描述符为`n`的文件以追加的方式重定向到 `file` |
| `n >& m` | 将输出文件`m`和`n`合并 |
| `n <& m` | 将输入文件`m`和`n`合并 |
| `<< tag` | 将开始标记 tag 和结束标记 tag 之间的内容作为输入 |

__需要注意的是文件描述符 0 通常是标准输入（STDIN），1 是标准输出（STDOUT），2 是标准错误输出（STDERR）__

## 13.1 Here Document

Here Document 是 Shell 中的一种特殊的重定向方式，用来将输入重定向到一个交互式 Shell 脚本或程序

它的基本的形式如下

```sh
command << delimiter
    document
delimiter
```

例如

```sh
wc -l << EOF
    欢迎来到
    菜鸟教程
    www.runoob.com
EOF
3          # 输出结果为 3 行
```

# 14 捕获信号

`trap`常用来做一些清理工作，比如你在脚本中将一些进程放到后台执行，但如果脚本异常终止（比如用ctrl+c），那么这些后台进程可能得不到及时处理，这个时候就可以用`trap`来捕获信号，从而执行清理动作

__格式__

* `trap "commands" signal-list`

__注意__

* 如果commands中包含变量，那么该变量在执行`trap`语句时就已解析，而非到真正捕获信号的时候才解析

__示例1__

```sh
# do other things

ping www.baidu.com &

ping_pid=$!
trap "kill -9 ${ping_pid}; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

__示例2（错误），该示例与示例1的差别就是用sudo执行ping命令__

* 这样是没法杀死`ping`这个后台进程的，因为`ping_pid`变量获取到的并不是`ping`的`pid`，而是`sudo`的`pid`

```sh
# do other things

sudo ping www.baidu.com &

ping_pid=$!
trap "kill -9 ${ping_pid}; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

__实例3（对实例2进行调整）__

```sh
# do other things

sudo ping www.baidu.com &

ping_pid=$!
trap "pkill -9 ping; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

# 15 方法

## 15.1 read

__格式：__

* `read [-ers] [-a aname] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd] [name ...]`

__参数说明：__

`-a`：后跟一个变量，该变量会被认为是个数组，然后给其赋值，__默认是以空格为分割符__
`-d`：后面跟一个标志符，其实只有其后的第一个字符有用，作为结束的标志
`-p`：后面跟提示信息，即在输入前打印提示信息
`-e`：在输入的时候可以使用命令补全功能
`-n`：后跟一个数字，定义输入文本的长度，很实用
`-r`：屏蔽`\`，如果没有该选项，则`\`作为一个转义字符，有的话`\`就是个正常的字符了
`-s`：安静模式，在输入字符时不再屏幕上显示，例如login时输入密码
`-t`：后面跟秒数，定义输入字符的等待时间
`-u`：后面跟fd，从文件描述符中读入，该文件描述符可以是exec新开启的

## 15.2 getopts

__格式：`getopts [option[:]] VARIABLE`__

* `option`：选项，为单个字母
* `:`：如果某个选项（option）后面出现了冒号（`:`），则表示这个选项后面可以接参数
* `VARIABLE`：表示将某个选项保存在变量`VARIABLE`中

`getopts`是linux系统中的一个内置变量，一般用在循环中。每当执行循环时，`getopts`都会检查下一个命令选项，如果这些选项出现
在option中，则表示是合法选项，否则不是合法选项。并将这些合法选项保存在`VARIABLE`这个变量中

`getopts`还包含两个内置变量，及`OPTARG`和`OPTIND`

1. `OPTARG`：选项后面的参数
1. `OPTIND`：下一个选项的索引（该索引是相对于`$*`的索引，因此如果选项有参数的话，索引是非连续的）

__示例__：`getopts ":a:bc:" opt`（参数部分：`-a 11 -b -c 5`）

* 第一个冒号表示忽略错误
* 字符后面的冒号表示该选项必须有自己的参数
* `$OPTARG`存储相应选项的参数，如例中的`11`、`5`两个参数
* `$OPTIND`总是存储原始`$*`中下一个要处理的选项的索引（注意不是参数，而是选项），此处指的是`a`,`b`,`c`这三个选项（而不是那些数字，当然数字
也是会占有位置的）的索引

    * `OPTIND`初值为1，遇到`x`（选项不带参数），则`OPTIND += 1`；遇到`x:`（选项带参数），则`OPTARG`=argv[OPTIND+1]，`OPTIND += 2`；

```sh
echo $*
while getopts ":a:bc:" opt
do
    case $opt in
        a)
            echo $OPTARG $OPTIND
            ;;
        b)
            echo "b $OPTIND"
            ;;
        c)
            echo "c $OPTIND"
            ;;
        :)
            echo "$OPTARG must have argument"
            exit 1
            ;;
        ?)
            echo "error"
            exit 1
            ;;
    esac
done
```

```sh
# case0
./testGetopts.sh -f
-f
error

# case1
./testGetopts.sh -a
-a
a must have argument

# case2
./testGetopts.sh -a 5
-a 5
5 3

# case3
./testGetopts.sh -a 5 -b
-a 5 -b
5 3
b 4

# case4
./testGetopts.sh -a 5 -b -c 5
-a 5 -b -c 5
5 3
b 4
c 6

# case5
./testGetopts.sh -a 5 -b -c 5 -b
-a 5 -b -c 5 -b
5 3
b 4
c 6
b 7
```

__注意：如果getopts置于函数内部时，getopts解析的是函数的所有入参，可以通过`$@`将脚本的所有参数传递给函数__

# 16 参考

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
* [shell的命令替换和命令组合](https://www.cnblogs.com/f-ck-need-u/archive/2017/08/20/7401591.html)
* [shell脚本--数值计算](https://www.cnblogs.com/-beyond/p/8232496.html)
* [Linux—shell中`$(())`、`$()`与`${}`的区别](https://www.cnblogs.com/chengd/p/7803664.html)
* [shell中各种括号的作用`()`、`(())`、`[]`、`[[]]`、`{}`](https://www.cnblogs.com/fengkui/p/6122702.html)
* [shell特殊符号用法大全](https://www.cnblogs.com/guochaoxxl/p/6871619.html)
* [shell的getopts命令](https://www.jianshu.com/p/baf6e5b7e70a)
* [如何获取后台进程的PID？](https://www.liangzl.com/get-article-detail-168597.html)
* [shell——trap捕捉信号（附信号表）](https://www.cnblogs.com/maxgongzuo/p/6372898.html)
* [Shell进程替换](http://c.biancheng.net/view/3025.html)
* [Bash scripting cheatsheet](https://devhints.io/bash)
