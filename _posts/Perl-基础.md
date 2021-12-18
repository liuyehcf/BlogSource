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

# 2 基础

## 2.1 数组

### 2.1.1 添加删除元素

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

### 2.1.2 `..` - range operator

```perl
@array = (1..10);
print "array = @array\n";

@subarray = @array[3..6];
print "subarray = @subarray\n";
```

### 2.1.3 合并数组

```perl
@numbers1 = (1,3,(4,5,6));
print "numbers1 = @numbers1\n";

@odd = (1,3,5);
@even = (2, 4, 6);
@numbers2 = (@odd, @even);
print "numbers2 = @numbers2\n";
```

### 2.1.4 数组与String转换

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

### 2.1.5 Tips

1. **用`print`打印数组时，最好放在引号里面，否则输出的时候，数组各元素就直接贴在一起了。而放在引号里面的话，各元素之间会用空格分隔**

# 3 高级特性

## 3.1 引号处理

### 3.1.1 q

### 3.1.2 qq

### 3.1.3 qw

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

# 4 编码规范

`Perl`允许我们以一种更易读的方式来写代码，例如

```perl
open(FOO,$foo) || die "Can't open $foo: $!";

print "Starting analysis\n" if $verbose;
```

# 5 参考

* [Perl Tutorial](https://www.tutorialspoint.com/perl/perl_function_references.htm)
* [什么编程语言写脚本好？](https://www.zhihu.com/question/505203283/answer/2266164064)
* [Perl | qw Operator](https://www.geeksforgeeks.org/perl-qw-operator/?ref=lbp)
