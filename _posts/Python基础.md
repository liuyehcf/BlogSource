---
title: Python基础
date: 2018-04-23 19:44:12
tags: 
- 原创
categories: 
- Python
- 基础
- 语法
---

__目录__

<!-- toc -->
<!--more-->

# 1 集合

__功能函数__

1. len

## 1.1 list

```py
classmates = ['Michael', 'Bob', 'Tracy']
```

__支持操作__

1. append 方法
1. insert 方法
1. pop 方法

## 1.2 tuple

元组不可变，指的是元组中元素的内存内容不变。言下之意，要是存的是一个list，这个list仍然可变（改变前后仍然是同一个list）

```py
classmates = ('Michael', 'Bob', 'Tracy')
classmates = ('Michael', )
```

包含单个元素的元组，要在最后加个逗号

## 1.3 dict

```py
d = {'Michael': 95, 'Bob': 75, 'Tracy': 85}
```

__支持操作__

1. get 方法，越界时不抛异常
    * get(index)，越界返回空
    * get(index, default_value)，越界返回指定默认值
1. in 操作符
1. pop 方法
1. values 方法

## 1.4 set

```py
s = set([1, 2, 3])
```

__支持操作__

1. add 方法
1. remove 方法

# 2 高级特性

## 2.1 切片

```py
L = ['Michael', 'Sarah', 'Tracy', 'Bob', 'Jack']
L[1:3] # 取元素 'Sarah', 'Tracy', 'Bob'
L[:3] # 取元素 'Michael', 'Sarah', 'Tracy', 'Bob'。默认从0开始
L[-2:] # 取元素 'Bob', 'Jack'。这里注意一下，负数的切片也是往数增大的方向（-1）走的。默认到0结束
```

```py
L = list(range(100))

L[:10:2] # 前10个数，每两个取一个
L[::5] # 所有数，每5个取一个
L[:] # 原样复制一个list
```

切片操作同样支持字符串。因此Python中没有像其他编程语言一样的字符串截取函数，因为切片足够了

## 2.2 迭代

### 2.2.1 list

```py
L = [1, 2, 3, 4]
for l in L:
    print(l)
```

### 2.2.2 tuple

```py
T = (1, 2, 3, 4)
for t in T:
    print(t)
```

### 2.2.3 dict

默认情况下，dict迭代的是key。如果要迭代value，可以用for value in d.values()

```py
D = {'a': 1, 'b': 2, 'c': 3}
for key in D:
    print(key)

for value in D.values():
    print(value)
```

### 2.2.4 set

```py
S = set([1, 2, 3])
for s in S:
    print(s)
```

### 2.2.5 字符串

```py
for ch in 'ABC':
    print(ch)
```

### 2.2.6 判断对象是否可以迭代

```py
isinstance('abc', Iterable) 
isinstance([1,2,3], Iterable) isinstance(123, Iterable) 
```

### 2.2.7 带循环下标

Python内置的enumerate函数可以把一个list变成索引-元素对，这样就可以在for循环中同时迭代索引和元素本身

```py
for i, value in enumerate(['A', 'B', 'C']):
    print(i, value)
```

### 2.2.8 多变量迭代

```py
for x, y in [(1, 1), (2, 4), (3, 9)]:
    print(x, y)

for x, y, z in [(1, 1, 1), (2, 4, 8), (3, 9, 27)]:
    print(x, y, z)
```

## 2.3 列表生成式

可以用Java里面的stream来理解

```py
[x * x for x in range(1, 11)]

[x * x for x in range(1, 11) if x % 2 == 0]

d = {'x': 'A', 'y': 'B', 'z': 'C' }
[k + '=' + v for k, v in d.items()]

L = ['Hello', 'World', 'IBM', 'Apple']
[s.lower() for s in L]
```

## 2.4 生成器

通过列表生成式，我们可以直接创建一个列表。但是，受到内存限制，列表容量肯定是有限的。而且，创建一个包含100万个元素的列表，不仅占用很大的存储空间，如果我们仅仅需要访问前面几个元素，那后面绝大多数元素占用的空间都白白浪费了。

所以，如果列表元素可以按照某种算法推算出来，那我们是否可以在循环的过程中不断推算出后续的元素呢？这样就不必创建完整的list，从而节省大量的空间。在Python中，这种一边循环一边计算的机制，称为生成器：generator。

要创建一个generator，有很多种方法。第一种方法很简单，只要把一个列表生成式的[]改成()，就创建了一个generator：

```py
g = (x * x for x in range(10))

for n in g:
    print(n)

# 可以用next(<generator>)获取下一个元素，单基本上不太会这样用，一般都是循环
```

如果一个函数定义中包含yield关键字，那么这个函数就不再是一个普通函数，而是一个generator

```py
def fib(max):
    n, a, b = 0, 0, 1
    while n < max:
        yield b
        a, b = b, a + b
        n = n + 1
    return 'done'

f = fib(6)

for n in f:
    print(n)
```

## 2.5 迭代器

生成器都是`Iterator`对象，但list、dict、str虽然是`Iterable`，却不是`Iterator`（注意区分`Iterable`和`Iterator`）

Python的Iterator对象表示的是一个数据流，Iterator对象可以被next()函数调用并不断返回下一个数据，直到没有数据时抛出StopIteration错误。可以把这个数据流看做是一个有序序列，但我们却不能提前知道序列的长度，只能不断通过next()函数实现按需计算下一个数据，所以Iterator的计算是惰性的，只有在需要返回下一个数据时它才会计算

__小结__

1. 凡是可作用于for循环的对象都是Iterable类型；
1. 凡是可作用于next()函数的对象都是Iterator类型，它们表示一个惰性计算的序列；
1. 集合数据类型如list、dict、str等是Iterable但不是Iterator，不过可以通过iter()函数获得一个Iterator对象。

# 3 参考

* [廖雪峰-Python教程](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)
