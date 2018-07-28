---
title: Linux-Shell
date: 2018-05-20 18:48:20
tags: 
- 原创
categories: 
- 操作系统
- Linux
---

__阅读更多__

<!--more-->

# 1 命令替换

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

# 2 数值运算

## 2.1 `$[]`

```sh
echo $[ 1 + 3 ]

a=10;b=5
echo $[ $a + $b ]
echo $[ $a - $b ]
echo $[ $a * $b ] #此时不用对*转义
echo $[ $a / $b ]
echo $[ $a % $b ]
```

## 2.2 expr

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

## 2.3 `$(())`

__`$(())`有如下两个功能__

1. 数值计算
1. 进制转换
* __在`$(())`中的变量名称，可于其前面加$符号来替换，也可以不用__

```sh
a=5;b=7;c=2
echo $((a+b*c))
echo $(($a+$b*$c))
```

## 2.4 `(())`

__`(())`用于重定义变量值，只有赋值语句才能起到重定义变量的作用__

```sh
a=1
((a+10))
echo $a     # 输出1

((a+=10))
echo $a     # 输出11

((a++))
echo $a     # 输出12
```

# 3 特殊符号

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
1. __`!`：感叹号（reverse (or negate) [bang],[exclamation mark])__
1. __`*`：星号（wildcard/arithmetic operator[asterisk])__
    * 作为匹配文件名扩展的一个通配符，能自动匹配给定目录下的每一个文件
    * 正则表达式中可以作为字符限定符，表示其前面的匹配规则匹配任意次
    * 算术运算中表示乘法
1. __`**`：双星号(double asterisk)__
    * 算术运算中表示求幂运算
1. __`?`：问号（test operator/wildcard[Question mark])__
1. __`$`：美元符号(Variable substitution[Dollar sign])__
    * 作为变量的前导符，用作变量替换，即引用一个变量的内容
    * 在正则表达式中被定义为行末
1. __`()`：圆括号(parentheses)__
    * 命令组（Command group）。由一组圆括号括起来的命令是命令组，__命令组中的命令是在子shell（subshell）中执行__。因为是在子shell内运行，因此在括号外面是没有办法获取括号内变量的值，但反过来，命令组内是可以获取到外面的值，这点有点像局部变量和全局变量的关系，在实作中，如果碰到要cd到子目录操作，并在操作完成后要返回到当前目录的时候，可以考虑使用subshell来处理
1. __`{}`：代码块(curly brackets)__
1. __`[]`：中括号（brackets）__
1. __`>  >>   <   <<`：重定向(redirection)__
1. __`|`：管道__
1. __`&& ||`：逻辑操作符__

# 4 判断式

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

* __`-z` string`：判定字符串是否为空，空返回true__
* __`-n`：判断字符串是否为空，非空返回true__
* __`=`或`==`：判断str1是否等于str2，好像有问题，使用中括号正确__
* __`!=`：判断str1是否等于str2，好像有问题，使用中括号正确__
* __字符串变量的引用方式：`"${var_name}"`__

__逻辑与/或/非__

* __`-a`：两个条件同时成立，返回true，如test -r file1 -a -x file2__
* __`-o`：任一条件成立，返回true，如test -r file1 -o -x file2__
* __`!`：反向状态__

# 5 字符串

## 5.1 拼接字符串

```sh
your_name="qinjx"
greeting="hello, "${your_name}" \!"
echo ${greeting}
```

## 5.2 获取字符串长度

```sh
text="abcdefg"
echo "字符串长度为 ${#text}"
```

## 5.3 提取子字符串

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

* 结果是`http:`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0:5}
```

__从左边第几个字符开始，一直到结束__

* 结果是`www.aaa.com/123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:7}
```

__从右边第几个字符开始，及字符的个数__

* 结果是`123`
* 注：（左边的第一个字符是用`0`表示，右边的第一个字符用`0-1`表示）

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7:3}
```

__从右边第几个字符开始，一直到结束__

* 结果是`123.htm`
* 注：（左边的第一个字符是用`0`表示，右边的第一个字符用`0-1`表示）

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7}
```

## 5.4 按行读取

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

# 6 数组

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

# 7 控制流

## 7.1 if

```sh
if condition
then
    command1 
    command2
    ...
    commandN 
fi
```

## 7.2 if else

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

## 7.3 if else-if else

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

## 7.4 for

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

## 7.5 while

```sh
while condition
do
    command
done
```

## 7.6 until

```sh
until condition
do
    command
done
```

## 7.7 case

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

# 8 进程替换

__用法：__

1. `<(command)`
1. `>(command)`
* __注意`<`、`>`与`(`之间不能有空格__

```sh
cat <(ls)   #把 <(ls) 当一个临时文件，文件内容是ls的结果，cat这个临时文件
ls > >(cat) #把 >(cat) 当成临时文件，ls的结果重定向到这个文件，最后这个文件被cat
```

# 9 方法

## 9.1 read

读取用户输入

# 10 参考

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
* [shell的命令替换和命令组合](https://www.cnblogs.com/f-ck-need-u/archive/2017/08/20/7401591.html)
* [shell脚本--数值计算](https://www.cnblogs.com/-beyond/p/8232496.html)
* [Linux—shell中$(())、$()、\`\`与${}的区别](https://www.cnblogs.com/chengd/p/7803664.html)
* [shell特殊符号用法大全](https://www.cnblogs.com/guochaoxxl/p/6871619.html)
