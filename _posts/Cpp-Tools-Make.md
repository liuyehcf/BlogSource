---
title: Cpp-Tools-Make
date: 2021-09-06 10:55:14
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

**代码变成可执行文件，叫做编译`compile`；先编译这个，还是先编译那个（即编译的安排），叫做构建`build`**

# 1 Makefile文件的格式

**`Makefile`文件由一系列规则`rules`构成。每条规则的形式如下：**

```makefile
<target> : <prerequisites> 
[tab]  <commands>
```

* `target`：目标，是必须的
* `prerequisites`：前置条件，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的
* `commands`：即完成目标需要执行的命令，不是必须的，但是`prerequisites`与`commands`至少有一个是必须的

## 1.1 target

一个目标`target`就构成一条规则。**目标通常是文件名**，指明`make`命令所要构建的对象。目标可以是一个文件名，也可以是多个文件名，之间用空格分隔

**除了文件名，目标还可以是某个操作的名字，这称为「伪目标」`phony target`，例如**

```makefile
clean:
    rm *.o
```

但是，项目中可能有名为`clean`的文件名，`make`发现`clean`文件已经存在，就认为没有必要重新构建了，因此可以明确声明「伪目标」

```makefile
.PHONY: clean
clean:
    rm *.o temp
```

**如果`make`命令运行时没有指定目标，默认会执行`Makefile`文件的第一个目标**

## 1.2 prerequisites

前置条件通常是一组文件名，之间用空格分隔。它指定了目标是否重新构建的判断标准：只要有一个前置文件不存在，或者有过更新（前置文件的`last-modification`时间戳比目标的时间戳新），目标就需要重新构建

```makefile
result.txt: source.txt
    cp source.txt result.txt
```

上面代码中，构建`result.txt`的前置条件是`source.txt`。如果当前目录中，`source.txt`已经存在，那么`make result.txt`可以正常运行，否则必须再写一条规则，来生成`source.txt`

```makefile
source.txt:
    echo "this is the source" > source.txt
```

连续执行两次`make result.txt`。第一次执行会先新建`source.txt`，然后再新建`result.txt`。第二次执行，`make`发现`source.txt`没有变动（时间戳晚于`result.txt`），就不会执行任何操作，`result.txt`也不会重新生成

如果需要生成多个文件，往往采用下面的写法

```makefile
source: file1 file2 file3
```

这样仅需要执行`make source`便可生成3个文件，而无需执行`make file1`、`make file2`、`make file3`

## 1.3 commands

命令`commands`表示如何更新目标文件，由一行或多行的`shell`命令组成。它是构建目标的具体指令，它的运行结果通常就是生成目标文件

每行命令之前必须有一个`tab`键。如果想用其他键，可以用内置变量`.RECIPEPREFIX`声明

```makefile
.RECIPEPREFIX = >
all:
> echo Hello, world
```

**需要注意的是，每行命令在一个单独的`shell`中执行。这些`shell`之间没有继承关系**

```makefile
var-lost:
    export foo=bar
    echo "foo=[$$foo]"
```

一个解决办法是将两行命令写在一行，中间用分号分隔

```makefile
var-kept:
    export foo=bar; echo "foo=[$$foo]"
```

另一个解决办法是在换行符前加反斜杠转义

```makefile
var-kept:
    export foo=bar; \
    echo "foo=[$$foo]"
```

更好的方法是加上`.ONESHELL:`命令

```makefile
.ONESHELL:
var-kept:
    export foo=bar; 
    echo "foo=[$$foo]"
```

# 2 Makefile文件的语法

## 2.1 注释

井号`#`在`Makefile`中表示注释

```makefile
# 这是注释
result.txt: source.txt
    # 这是注释
    cp source.txt result.txt # 这也是注释
```

## 2.2 回声（echoing）

正常情况下，`make`会打印每条命令，然后再执行，这就叫做回声`echoing`

```makefile
test:
    # 这是测试
```

执行上面的规则，会得到下面的结果

```sh
make test
# 这是测试
```

在命令的前面加上`@`，就可以关闭回声

```makefile
test:
    @# 这是测试
```

## 2.3 通配符

通配符`wildcard`用来指定一组符合条件的文件名。`Makefile`的通配符与 `Bash`一致，主要有星号`*`、问号`？`和`...`。比如，`*.o`表示所有后缀名为`o`的文件

```makefile
clean:
        rm -f *.o
```

## 2.4 模式匹配

`make`命令允许对文件名，进行类似正则运算的匹配，主要用到的匹配符是`%`。比如，假定当前目录下有`f1.c`和`f2.c`两个源码文件，需要将它们编译为对应的对象文件

```makefile
%.o: %.c
```

等同于下面的写法

```makefile
f1.o: f1.c
f2.o: f2.c
```

**使用匹配符`%`，可以将大量同类型的文件，只用一条规则就完成构建**

## 2.5 变量和赋值符

`Makefile`允许使用等号自定义变量

```makefile
txt = Hello World
test:
    @echo $(txt)
```

上面代码中，变量`txt`等于`Hello World`。**调用时，变量需要放在`$()`之中**

**调用`shell`变量，需要在`$`前，再加一个`$`，这是因为`make`命令会对`$`转义**

```makefile
test:
    @echo $$HOME
```

## 2.6 内置变量（Implicit Variables）

`make`命令提供一系列内置变量，比如，`$(CC)`指向当前使用的编译器，`$(MAKE)`指向当前使用的`make`工具。这主要是为了跨平台的兼容性，详细的内置变量清单见[手册](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html)

```makefile
output:
    $(CC) -o output input.c
```

## 2.7 自动变量（Automatic Variables）

`make`命令还提供一些自动变量，它们的值与当前规则有关。主要有以下几个，可以参考[手册](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)

### 2.7.1 `$@`

`$@`指代当前目标，就是`make`命令当前构建的那个目标。比如，`make foo`的`$@`就指代`foo`

```makefile
a.txt b.txt: 
    touch $@
```

等同于下面的写法

```makefile
a.txt:
    touch a.txt
b.txt:
    touch b.txt
```

### 2.7.2 `$<`

`$<`指代第一个前置条件。比如，规则为`t: p1 p2`，那么`$<`就指代`p1`

```makefile
a.txt: b.txt c.txt
    cp $< $@ 
```

等同于下面的写法

```makefile
a.txt: b.txt c.txt
    cp b.txt a.txt 
```

### 2.7.3 `$?`

`$?`指代比目标更新的所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，其中`p2`的时间戳比`t`新，`$?`就指代`p2`

### 2.7.4 `$^`

`$^`指代所有前置条件，之间以空格分隔。比如，规则为`t: p1 p2`，那么`$^`就指代`p1 p2`

### 2.7.5 `$*`

`$*`指代匹配符`%`匹配的部分，比如`%.txt`匹配`f1.txt`中的`f1`，`$*`就表示`f1`

### 2.7.6 `$(@D)/$(@F)`

`$(@D)`和`$(@F)`分别指向`$@`的目录名和文件名。比如，`$@`是`src/input.c`，那么`$(@D)`的值为`src`，`$(@F)`的值为`input.c`

### 2.7.7 `$(<D)/$(<F)`

`$(<D)`和`$(<F)`分别指向`$<`的目录名和文件名

### 2.7.8 例子

```makefile
dest/%.txt: src/%.txt
    @[ -d dest ] || mkdir dest
    cp $< $@
```

上面代码将`src`目录下的`txt`文件，拷贝到`dest`目录下。首先判断`dest`目录是否存在，如果不存在就新建，然后，`$<`指代前置文件`src/%.txt`，`$@`指代目标文件`dest/%.txt`

## 2.8 判断和循环

`Makefile`使用`Bash`语法，完成判断和循环

```makefile
ifeq ($(CC),gcc)
  libs=$(libs_for_gcc)
else
  libs=$(normal_libs)
endif
```

```makefile
LIST = one two three
all:
    for i in $(LIST); do \
        echo $$i; \
    done

# 等同于

all:
    for i in one two three; do \
        echo $$i; \
    done
```

## 2.9 函数

`Makefile`还可以使用函数，格式如下

```makefile
$(function arguments)
# 或者
${function arguments}
```

`Makefile`提供了许多[内置函数](https://www.gnu.org/software/make/manual/html_node/Functions.html)，可供调用

# 3 make

**参数说明：**

* `-s`：不显示echo
* `-n`：仅打印需要执行的命令，而不是实际运行

# 4 参考

* [Make 命令教程](https://www.ruanyifeng.com/blog/2015/02/make.html)
