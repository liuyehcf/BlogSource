---
title: Python-Basics
date: 2018-04-23 19:44:12
tags: 
- 原创
categories: 
- Python
---

**阅读更多**

<!--more-->

# 1 变量

## 1.1 内置变量

```py
# 查看所有内置变量
vars()
```

* `__name__`：模块名称
    * 当你直接执行`<module>.py`的时候，这段脚本的`__name__`变量等于`__main__`
    * 当这段脚本被导入其他程序的时候，`__name__`变量等于脚本本身的名字，即`<module>`
* `__file__`：模块的文件路径

## 1.2 全局变量

**`Python`中`global`关键字的基本规则是：**

* 在函数内部定义变量时，默认情况下它是局部的
* 在函数外部定义变量时，默认情况下它是全局的。不必使用`global`关键字
* 使用`global`关键字，可以在函数内部读写全局变量。读全局变量可以不用`global`关键字
* 在函数外使用`global`关键字无效

```py
global_value = 1

def read_global():
    print(global_value)

def write_global():
    global global_value
    global_value += 2
    print(global_value)

def read_and_write_global():
    global global_value
    global_value += 2
    print(global_value)

read_global()
write_global()
read_and_write_global()
```

# 2 基本类型

## 2.1 整型

`int`类型的最大最小值是不存在的，因为`int`类型是无边界的。[Maximum and Minimum values for ints](https://stackoverflow.com/questions/7604966/maximum-and-minimum-values-for-ints)

## 2.2 浮点型

```py
float('inf')
float('-inf')
```

## 2.3 字符串

```py
str1 = "hello"
str2 = "world"

# 拼接
str1 + ", " + str2

# 格式化
"{}, {}".format(str1, str2)

# 判断是否包含
if "ll" in str1:
    print("str1 contains 'll'")

# 除去首位空白，包括空格、制表、换行
str3 = '   something   \t\t\n\n'
str3.strip()

# 除去首位特定字符
str4 = 'aaaaasomethingbbbb'
str4.strip("ab")
```

# 3 语法

## 3.1 循环

```py
nums = [1, 2, 3, 4, 5]

for num in nums:
    print(num)

for i, num in enumerate(nums):
    print(i, num)
```

# 4 容器

**功能函数**

1. len

## 4.1 list

```py
classmates = ['Michael', 'Bob', 'Tracy']
```

**支持操作**

1. append 方法
1. insert 方法
1. pop 方法

## 4.2 tuple

元组不可变，指的是元组中元素的内存内容不变。言下之意，要是存的是一个`list`，这个`list`仍然可变（改变前后仍然是同一个`list`）

```py
classmates = ('Michael', 'Bob', 'Tracy')
classmates = ('Michael', )
```

包含单个元素的元组，要在最后加个逗号

## 4.3 dict

```py
d = {'Michael': 95, 'Bob': 75, 'Tracy': 85}
```

**支持操作**

1. `get`方法，越界时不抛异常
    * `get(index)`，越界返回空
    * `get(index, default_value)`，越界返回指定默认值
1. `in`操作符
1. `pop`方法
1. `values`方法

## 4.4 set

```py
s = set([1, 2, 3])
```

**支持操作**

1. `add`方法
1. `remove`方法

# 5 高级特性

## 5.1 切片

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

切片操作同样支持字符串。因此`Python`中没有像其他编程语言一样的字符串截取函数，因为切片足够了

## 5.2 迭代

### 5.2.1 list

```py
L = [1, 2, 3, 4]
for l in L:
    print(l)
```

### 5.2.2 tuple

```py
T = (1, 2, 3, 4)
for t in T:
    print(t)
```

### 5.2.3 dict

默认情况下，`dict`迭代的是`key`。如果要迭代`value`，可以用`for value in d.values()`

```py
D = {'a': 1, 'b': 2, 'c': 3}
for key in D:
    print(key)

for value in D.values():
    print(value)
```

### 5.2.4 set

```py
S = set([1, 2, 3])
for s in S:
    print(s)
```

### 5.2.5 字符串

```py
for ch in 'ABC':
    print(ch)
```

### 5.2.6 判断对象是否可以迭代

```py
isinstance('abc', Iterable) 
isinstance([1,2,3], Iterable)
isinstance(123, Iterable) 
```

### 5.2.7 带循环下标

`Python`内置的`enumerate`函数可以把一个`list`变成索引-元素对，这样就可以在`for`循环中同时迭代索引和元素本身

```py
for i, value in enumerate(['A', 'B', 'C']):
    print(i, value)
```

### 5.2.8 多变量迭代

```py
for x, y in [(1, 1), (2, 4), (3, 9)]:
    print(x, y)

for x, y, z in [(1, 1, 1), (2, 4, 8), (3, 9, 27)]:
    print(x, y, z)
```

## 5.3 列表生成式

可以用`Java`里面的`stream`来理解

```py
[x * x for x in range(1, 11)]

[x * x for x in range(1, 11) if x % 2 == 0]

d = {'x': 'A', 'y': 'B', 'z': 'C' }
[k + '=' + v for k, v in d.items()]

L = ['Hello', 'World', 'IBM', 'Apple']
[s.lower() for s in L]
```

## 5.4 生成器

通过列表生成式，我们可以直接创建一个列表。但是，受到内存限制，列表容量肯定是有限的。而且，创建一个包含100万个元素的列表，不仅占用很大的存储空间，如果我们仅仅需要访问前面几个元素，那后面绝大多数元素占用的空间都白白浪费了

所以，如果列表元素可以按照某种算法推算出来，那我们是否可以在循环的过程中不断推算出后续的元素呢？这样就不必创建完整的`list`，从而节省大量的空间。在Python中，这种一边循环一边计算的机制，称为生成器：`generator`

要创建一个`generator`，有很多种方法。第一种方法很简单，只要把一个列表生成式的`[]`改成`()`，就创建了一个`generator`：

```py
g = (x * x for x in range(10))

for n in g:
    print(n)

# 可以用next(<generator>)获取下一个元素，单基本上不太会这样用，一般都是循环
```

如果一个函数定义中包含`yield`关键字，那么这个函数就不再是一个普通函数，而是一个`generator`

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

## 5.5 迭代器

生成器都是`Iterator`对象，但`list`、`dict`、`str`虽然是`Iterable`，却不是`Iterator`（注意区分`Iterable`和`Iterator`）

`Python`的`Iterator`对象表示的是一个数据流，`Iterator`对象可以被`next()`函数调用并不断返回下一个数据，直到没有数据时抛出`StopIteration`错误。可以把这个数据流看做是一个有序序列，但我们却不能提前知道序列的长度，只能不断通过`next()`函数实现按需计算下一个数据，所以`Iterator`的计算是惰性的，只有在需要返回下一个数据时它才会计算

**小结：**

1. 凡是可作用于`for`循环的对象都是`Iterable`类型；
1. 凡是可作用于`next()`函数的对象都是`Iterator`类型，它们表示一个惰性计算的序列；
1. 集合数据类型如`list`、`dict`、`str`等是`Iterable`但不是`Iterator`，不过可以通过`iter()`函数获得一个`Iterator`对象

# 6 函数

## 6.1 main函数

一些编程语言有一个称为的特殊函数`main()`，它是程序文件的执行点。但是，`Python`解释器从文件顶部开始依次运行每一行，并且没有显式`main()`函数

`Python`提供了其他约定来定义执行点。其中之一是使用`Python`文件的`main()`函数和`__name__`属性

`__name__`变量是一个特殊的内置`Python`变量，它显示当前模块的名称

因此，`main`函数可以通过如下方式实现：

```py
def main():
    print("Hello World")

if __name__=="__main__":
    main()
```

## 6.2 常用内置函数

[内置函数清单](https://www.runoob.com/python/python-built-in-functions.html)

### 6.2.1 enumerate

`enumerate()`函数用于将一个可遍历的数据对象(如列表、元组或字符串)组合为一个索引序列，同时列出数据和数据下标，一般用在`for`循环当中

```py
seasons = ['Spring', 'Summer', 'Fall', 'Winter']
list(enumerate(seasons))
list(enumerate(seasons, start=1))

for idx, season in enumerate(seasons):
    print("idx:", idx, ", season:", season)
```

### 6.2.2 filter

思考这样一个场景，我们需要在一个给定的list中删除某些符合条件的元素，应该怎么做？

```py
lst = [1, 2, 3, 4, 5, 6]
newLst = list(filter(lambda x: x % 2 != 0, lst))
print(newLst)

# 或者
def is_odd(num):
    return num % 2 != 0

lst = [1, 2, 3, 4, 5, 6]
newLst = list(filter(is_odd, lst))
print(newLst)

# 或者
lst = [1, 2, 3, 4, 5, 6]
for v in lst[:]:
    if v % 2 == 0:
        lst.remove(v)
print(lst)
```

## 6.3 高阶函数

`Python`支持函数式编程，既可以将函数当做参数传入，也可以将函数作为返回值。也可以在函数内部定义函数

# 7 模块

为了编写可维护的代码，我们把很多函数分组，分别放到不同的文件里，这样，每个文件包含的代码就相对较少，很多编程语言都采用这种组织代码的方式。**在Python中，一个.py文件就称之为一个模块（Module）**

为了避免模块名冲突，Python又引入了按目录来组织模块的方法，称为包（Package）

```
mycompany
├─ __init__.py
├─ abc.py
└─ xyz.py
```

引入了包以后，只要顶层的包名不与别人冲突，那所有模块都不会与别人冲突。现在，`abc.py`模块的名字就变成了`mycompany.abc`，类似的，`xyz.py`的模块名变成了`mycompany.xyz`

请注意，每一个包目录下面都会有一个`__init__.py`的文件，这个文件是必须存在的，否则，Python就把这个目录当成普通目录，而不是一个包。`__init__.py`可以是空文件，也可以有Python代码，因为`__init__.py`本身就是一个模块，而它的模块名就是`mycompany`

类似的，可以有多级目录，组成多级层次的包结构。比如如下的目录结构：

```
mycompany
 ├─ web
 │  ├─ __init__.py
 │  ├─ utils.py
 │  └─ www.py
 ├─ __init__.py
 ├─ abc.py
 └─ utils.py
```

## 7.1 模块搜索路径

当我们试图加载一个模块时，Python会在指定的路径下搜索对应的`.py`文件，如果找不到，就会报错

默认情况下，Python解释器会搜索当前目录、所有已安装的内置模块和第三方模块，搜索路径存放在`sys`模块的`sys.path`变量中

```py
>>> import sys
>>> print(sys.path)
['', '/usr/lib64/python36.zip', '/usr/lib64/python3.6', '/usr/lib64/python3.6/lib-dynload', '/home/disk3/hcf/.local/lib/python3.6/site-packages', '/usr/local/lib64/python3.6/site-packages', '/usr/local/lib/python3.6/site-packages', '/usr/local/lib/python3.6/site-packages/cloud_init-19.1.6-py3.6.egg', '/usr/local/lib/python3.6/site-packages/listCase-1.0.0.0-py3.6.egg', '/usr/lib64/python3.6/site-packages', '/usr/lib/python3.6/site-packages']
```

如果我们要添加自己的搜索目录，有两种方法：

1. 直接修改`sys.path`，添加要搜索的目录（这种方法是在运行时修改，运行结束后失效）：
    ```
    >>> import sys
    >>> sys.path.append('/xxx/yyy/my_py_scripts')
    ```

1. 第二种方法是设置环境变量`PYTHONPATH`，该环境变量的内容会被自动添加到模块搜索路径中。设置方式与设置`Path`环境变量类似

## 7.2 常用内建模块

**[Python 标准库](https://docs.python.org/zh-cn/3/library)**

1. `http`
    * `python3 -m http.server 80`：启动一个`http server`，执行命令的目录会作为`http`资源的根目录
1. `json`
1. `venv`：用来为一个应用创建一套隔离的Python运行环境

## 7.3 Matplotlib

```sh
pip install matplotlib
```

示例1：

```py
import numpy as np
import matplotlib.pyplot as plt

# Create some data
x = np.linspace(0, 10, 1000)
y = np.sin(x)+1
z = np.cos(x**2)+1

# Create a figure
plt.figure(figsize=(8, 4))
plt.plot(x, y, label='$\sin x+1$', color='red', linewidth=2)
plt.plot(x, z, 'b--', label='$\cos x^2+1$')
plt.xlabel('times(s)')
plt.ylabel('volt')
plt.title('a simple example')
plt.ylim(0, 2.2)
plt.legend()

# Show the plot
plt.show()
```

示例2：

```py
import matplotlib.pyplot as plt
import numpy as np

# Create some data
x = np.linspace(0, 10, 100)
y1 = np.sin(x)
y2 = np.cos(x)

# Create a figure with two subplots
fig, (ax1, ax2) = plt.subplots(nrows=2, ncols=1)
fig.suptitle('Some graphs')

# Plot the first subplot (line plot)
ax1.plot(x, y1)
ax1.set_title('Sine Plot')
ax1.set_xlabel('x')
ax1.set_ylabel('y1')
ax1.legend('sin')

# Plot the second subplot (scatter plot)
ax2.scatter(x, y2)
ax2.set_title('Cosine Plot')
ax2.set_xlabel('x')
ax2.set_ylabel('y2')
ax2.legend('cos')

# Adjust the layout of the subplots
plt.tight_layout()

# Show the plot
plt.show()
```

## 7.4 Tips

1. 查看所有模块：`sys.modules.keys()`
1. 查看模块的文档：`help("<module_name>")`
1. 查看库的路径
    * 方法1：
    ```py
    import inspect
    import os
    inspect.getfile(os)
    ```

    * 方法2：
    ```py
    import inspect
    import os
    print(os.__file__)
    ```

    * 方法3：用help

# 8 pip

`pip`是`python`的包管理工具

* 安装路径：`~/.local/lib/python3.10/site-packages`

```sh
pip install xxx

# 指定源
pip install xxx -i https://pypi.tuna.tsinghua.edu.cn/simple
```

**常用国内源：**

* `https://pypi.tuna.tsinghua.edu.cn/simple`：清华
* `https://pypi.mirrors.ustc.edu.cn/simple`：中科大
* `https://mirrors.aliyun.com/pypi/simple`：阿里云

## 8.1 Tips

1. `ModuleNotFoundError: No module named 'pip._vendor.certifi.core'`
    * 重新安装`pip`，参考[pip3 install not working - No module named 'pip._vendor.pkg_resources'](https://stackoverflow.com/questions/49478573/pip3-install-not-working-no-module-named-pip-vendor-pkg-resources)
    ```sh
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python3 get-pip.py --force-reinstall
    ```

1. `CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography and will be removed in a future release.`
    * 安装的`cry`版本太新了，重新安装个老版本即可，参考[netmiko安装报错解决](https://zhuanlan.zhihu.com/p/509547714)
    ```sh
    pip3 install cryptography==3.4.8
    ```

# 9 其他

## 9.1 代码格式化

* [autopep8](https://pypi.org/project/autopep8/)
* [vim-autopep8](https://github.com/tell-k/vim-autopep8)
* [vim-autoformat](https://github.com/vim-autoformat/vim-autoformat)

# 10 参考

* [廖雪峰-Python教程](https://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000)
* [Python 3 教程](https://www.runoob.com/python3/python3-tutorial.html)
