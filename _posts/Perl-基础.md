---
title: Perl-基础
date: 2021-12-18 19:15:28
tags: 
- 原创
categories: 
- Perl
---

**阅读更多**

<!--more-->

# 1 前言

**我们已经有`shell`，有`python`了，有什么必要再学一门脚本语言么？**

* 和`shell`杂交非常亲和，`shell`脚本里用`perl`可替换`sed,awk,grep`
* 字符串处理。`q,qq,qx,qw,qr`
* 丰富且顺手的正则方言

# 2 基础语法

1. `Perl`程序有声明与语句组成，程序自上而下执行，包含了循环，条件控制，每个语句以分号`;`结束
1. `Perl`语言没有严格的格式规范，你可以根据自己喜欢的风格来缩进
1. 以`#`开头的是注释
1. 以`=pdo`且以`=cut`结尾的是多行注释
1. 单引号或双引号都表示字符串
1. `Here`文档
    * 必须后接分号
    * 可以自定义开始标识（结束标识与开始标识必须相同）
    * 结束字符必须独占一行，无任何其他多余字符（包括空白）
    * 开始标识可以不带引号，或者带单双引号
        * 不带引号/带双引号，会解释内嵌的变量和转义字符
        * 带单引号，不会解释内嵌的变量和转义字符
    ```perl
    $a = 10;
    $var = <<"EOF";
    这是一个 Here 文档实例，使用双引号。
    可以在这输如字符串和变量。
    例如：a = $a
    EOF
    print "$var\n";

    $var = <<'EOF';
    这是一个 Here 文档实例，使用单引号。
    例如：a = $a
    EOF
    print "$var\n";
    ```

1. 标识符格式为`[_a-zA-Z][_a-zA-Z0-9]*`，对大小写敏感

# 3 数据类型

1. `Perl`是一种弱类型语言，所以变量不需要指定类型，`Perl`解释器会根据上下文自动选择匹配类型
1. `Perl`为每个变量类型设置了独立的命令空间，所以不同类型的变量可以使用相同的名称，你不用担心会发生冲突。例如`$foo`和`@foo`是两个不同的变量
1. 变量使用等号`=`来赋值

## 3.1 标量

1. 标量是一个单一的数据单元。 数据可以是整数，浮点数，字符，字符串，段落等。简单的说它可以是任何东西，对具体类型不做进一步区分
1. 使用时在变量前面加上`$`符号，用于表示标量

```perl
$age = 25;              # 整型
$name = "youj";         # 字符串
$salary = 1445.50;      # 浮点数

print "Age = $age\n";
print "Name = $name\n";
print "Salary = $salary\n";
```

### 3.1.1 字面量

1. `Perl`实际上把整数存在你的计算机中的浮点寄存器中，所以实际上被当作浮点数看待
1. 浮点寄存器通常不能精确地存贮浮点数，从而产生误差，在运算和比较中要特别注意。指数的范围通常为`-309`到`+308`
1. `Perl`中的字符串使用一个标量来表示，定义方式和`C`很像，但是在`Perl`里面字符串不是用`0`来表示结束的。
1. `Perl`双引号和单引号的区别：双引号可以正常解析一些转义字符与变量，而单引号无法解析会原样输出
1. 但是用单引号定义可以使用多行文本

### 3.1.2 特殊字符

1. `__FILE__`：当前脚本文件名
1. `__LINE__`：当前脚本行号
1. `__PACKAGE__`：当前脚本包名
1. 特殊字符是单独的标记，不能写到字符串中

```perl
print "文件名 ". __FILE__ . "\n";
print "行号 " . __LINE__ ."\n";
print "包名 " . __PACKAGE__ ."\n";

# 无法解析
print "__FILE__ __LINE__ __PACKAGE__\n";
```

## 3.2 数组

1. 数组是用于存储一个有序的标量值的变量
1. 数组变量以字符`@`开头，索引从`0`开始
1. 要访问数组的某个成员，可以使用`$变量名[索引值]`格式来访问

```perl
@ages = (25, 30, 40);             
@names = ("google", "youj", "taobao");

print "\$ages[0] = $ages[0]\n";
print "\$ages[1] = $ages[1]\n";
print "\$ages[2] = $ages[2]\n";
print "\$names[0] = $names[0]\n";
print "\$names[1] = $names[1]\n";
print "\$names[2] = $names[2]\n";
```

### 3.2.1 添加删除元素

1. `push`：添加元素到尾部
1. `pop`：删除尾部元素
1. `shift`：删除头部元素
1. `unshift`：添加元素到头部

```perl
# create a simple array
@coins = ("Quarter", "Dime", "Nickel");
print "1. \@coins  = @coins\n";

# add one element at the end of the array
push(@coins, "Penny");
print "2. \@coins  = @coins\n";

# add one element at the beginning of the array
unshift(@coins, "Dollar");
print "3. \@coins  = @coins\n";

# remove one element from the last of the array.
pop(@coins);
print "4. \@coins  = @coins\n";

# remove one element from the beginning of the array.
shift(@coins);
print "5. \@coins  = @coins\n";
```

### 3.2.2 `..` - range operator

```perl
@array = (1..10);
print "array = @array\n";

@subarray = @array[3..6];
print "subarray = @subarray\n";
```

### 3.2.3 合并数组

```perl
@numbers1 = (1,3,(4,5,6));
print "numbers1 = @numbers1\n";

@odd = (1,3,5);
@even = (2, 4, 6);
@numbers2 = (@odd, @even);
print "numbers2 = @numbers2\n";
```

### 3.2.4 数组与String转换

```perl
# define Strings
$var_string = "Rain-Drops-On-Roses-And-Whiskers-On-Kittens";
$var_names = "Larry,David,Roger,Ken,Michael,Tom";

# transform above strings into arrays.
@string = split('-', $var_string);
@names  = split(',', $var_names);

$string1 = join( '-', @string );
$string2 = join( ',', @names );

print "$string1\n";
print "$string2\n";
```

### 3.2.5 Tips

1. **用`print`打印数组时，最好放在引号里面，否则输出的时候，数组各元素就直接贴在一起了。而放在引号里面的话，各元素之间会用空格分隔**

## 3.3 哈希

1. 哈希是一个`key/value`对的集合
1. 哈希变量以字符`%`开头
1. 果要访问哈希值，可以使用`$变量名{键值}`格式来访问

```perl
%data = ('google', 45, 'youj', 30, 'taobao', 40);

print "\$data{'google'} = $data{'google'}\n";
print "\$data{'youj'} = $data{'youj'}\n";
print "\$data{'taobao'} = $data{'taobao'}\n";
```

## 3.4 变量上下文

1. 所谓上下文：指的是表达式所在的位置
1. **上下文是由等号左边的变量类型决定的**，等号左边是标量，则是标量上下文，等号左边是列表，则是列表上下文
1. `Perl`解释器会根据上下文来决定变量的类型
1. 上下文种类
    1. 标量上下文
    1. 列表上下文，包括数组和哈希
    1. 布尔上下文
    1. void上下文
    1. 插值上下文，仅发生在引号内

```perl
@names = ('google', 'youj', 'taobao');

@copy = @names;   # 复制数组
$size = @names;   # 数组赋值给标量，返回数组元素个数

print "名字为 : @copy\n";
print "名字数为 : $size\n";
```

# 4 高级特性

## 4.1 引号处理

### 4.1.1 q

### 4.1.2 qq

### 4.1.3 qw

将字符串以空白作为分隔符进行拆分，并返回一个数组

```perl
@String = qw/Ram is a boy/;
print "@String", "\n";
@String = qw{Geeks for Geeks};
print "@String", "\n";
@String = qw[Geeks for Geeks];
print "@String", "\n";
@String = qw'Geeks for Geeks';
print "@String", "\n";
@String = qw"Geeks for Geeks";
print "@String", "\n";
@String = qw!Geeks for Geeks!;
print "@String", "\n";
@String = qw@Geeks for Geeks@;
print "@String", "\n";
```

# 5 编码规范

`Perl`允许我们以一种更易读的方式来写代码，例如

```perl
open(FOO,$foo) || die "Can't open $foo: $!";

print "Starting analysis\n" if $verbose;
```

# 6 参考

* [w3cschool-perl](https://www.w3cschool.cn/perl/)
* [perl仓库-cpan](https://www.cpan.org/)
* [Perl Tutorial](https://www.tutorialspoint.com/perl/perl_function_references.htm)
* [什么编程语言写脚本好？](https://www.zhihu.com/question/505203283/answer/2266164064)
* [Perl | qw Operator](https://www.geeksforgeeks.org/perl-qw-operator/?ref=lbp)
* [$_ the default variable of Perl](https://perlmaven.com/the-default-variable-of-perl)
