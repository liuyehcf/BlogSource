---
title: Linux-Shell
date: 2018-05-20 18:48:20
tags: 
- 摘录
categories: 
- 操作系统
- Linux
---

__阅读更多__

<!--more-->

# 1 杂项

## 1.1 `$()`

## 1.2 `$(())`

`var=$((运算内容))`，用于计算表达式的值

```sh
count=10
seq 0 $(($count-1))
```

# 2 字符串

## 2.1 字符串截取

1. `${var:7}`：从左边第7个字符开始，一直到结束

# 3 数组

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

# 5 参考

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
