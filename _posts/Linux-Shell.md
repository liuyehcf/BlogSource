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

# 2 字符串

## 2.1 拼接字符串

```sh
your_name="qinjx"
greeting="hello, "${your_name}" \!"
echo ${greeting}
```

## 2.2 获取字符串长度

```sh
text="abcdefg"
echo "字符串长度为 ${#text}"
```

## 2.3 提取子字符串

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

# 3 数组

Shell 数组用括号来表示，元素用`空格`符号分割开，语法格式如下：

```sh
array_name=(value1 ... valuen)
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

# 4 控制流

## 4.1 if

```sh
if condition
then
    command1 
    command2
    ...
    commandN 
fi
```

## 4.2 if else

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

## 4.3 if else-if else

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

## 4.4 for

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

## 4.5 while

```sh
while condition
do
    command
done
```

## 4.6 until

```sh
until condition
do
    command
done
```

## 4.7 case

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

# 5 方法

## 5.1 read

读取用户输入

# 6 参考

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
