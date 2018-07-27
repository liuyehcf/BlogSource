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

# 1 杂项

## 1.1 `$()`

在一串命令中，还需要通过其他的命令提供信息，可以使用单反引号或$(命令)

## 1.2 `$(())`

`var=$((运算内容))`，用于计算表达式的值

```sh
count=10
seq 0 $(($count-1))
```

# 2 判断式

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

# 3 字符串

## 3.1 拼接字符串

```sh
your_name="qinjx"
greeting="hello, "${your_name}" \!"
echo ${greeting}
```

## 3.2 获取字符串长度

```sh
text="abcdefg"
echo "字符串长度为 ${#text}"
```

## 3.3 提取子字符串

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

## 3.4 按行读取

__方式1__

```sh
while read line
do
　　echo $line
done < 文件名
```

__方式2__

* __注意，在这种方式下，在while循环内的变量的赋值会丢失，因为管道相当于开启另一个进程__

```sh
STDOUT | while read line
do
　　echo $line
done
```

# 4 数组

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

1. `@`或`*`可以获取数组中的所有元素
    * `${array[@]}`
    * `${array[*]}`
1. 获取数组长度的方法与获取字符串长度的方法相同，即利用`#`
    * ```${#array[@]}```
    * ```${#array[*]}```

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

# 5 控制流

## 5.1 if

```sh
if condition
then
    command1 
    command2
    ...
    commandN 
fi
```

## 5.2 if else

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

## 5.3 if else-if else

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

## 5.4 for

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
for((i=1;i<=10;i++));
do
    command1
    command2
    ...
    commandN
done
```

## 5.5 while

```sh
while condition
do
    command
done
```

## 5.6 until

```sh
until condition
do
    command
done
```

## 5.7 case

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

# 6 方法

## 6.1 read

读取用户输入

# 7 参考

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
