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

* 和`shell`杂交非常亲和，`shell`脚本里用`Perl`可替换`sed,awk,grep`
* 字符串处理。`q/qq/qx/qw/qr`
* 正则是`Perl`语法的一部分，功能非常强大，且方言顺手

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
    use strict;
    use warnings;
    use Modern::Perl;

    my $a = 10;
    my $var = <<"EOF";
    这是一个 Here 文档实例，使用双引号。
    可以在这输如字符串和变量。
    例如：a = $a
    EOF
    say "$var";

    $var = <<'EOF';
    这是一个 Here 文档实例，使用单引号。
    例如：a = $a
    EOF
    say "$var";
    ```

1. 标识符格式为`[_a-zA-Z][_a-zA-Z0-9]*`，对大小写敏感

# 3 数据类型

1. `Perl`是一种弱类型语言，所以变量不需要指定类型，`Perl`解释器会根据上下文自动选择匹配类型
1. `Perl`为每个变量类型设置了独立的命令空间，所以不同类型的变量可以使用相同的名称，你不用担心会发生冲突。例如`$foo`和`@foo`是两个不同的变量
1. 变量使用等号`=`来赋值

## 3.1 标量

1. 标量是一个单一的数据单元
1. 标量可能是：
    * 字符串
    * 整数
    * 浮点数
    * 文件句柄
    * 引用
1. 使用时在变量前面加上`$`符号，用于表示标量

```perl
use strict;
use warnings;
use Modern::Perl;

my $age = 25;
my $name = "youj";
my $salary = 1445.50;

say "Age = $age";
say "Name = $name";
say "Salary = $salary";
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
use strict;
use warnings;
use Modern::Perl;

say "filename: ". __FILE__;
say "linenum: " . __LINE__;
say "packagename: " . __PACKAGE__;

# output literal content
say "__FILE__ __LINE__ __PACKAGE__";
```

### 3.1.3 undef

1. `undef`表示变量的值已被声明但是尚未赋值
1. 可以用`defined`来检查一个变量是否定义

```perl
use strict;
use warnings;
use Modern::Perl;

my $num_def = 1;
my $num_undef;

say defined $num_def;
say defined $num_undef;
```

## 3.2 数组

1. 数组是用于存储一个有序的标量值的变量
1. 数组变量以字符`@`开头，索引从`0`开始
1. 要访问数组的某个成员，可以使用`$变量名[索引值]`格式来访问

```perl
use strict;
use warnings;
use Modern::Perl;

my @ages = (25, 30, 40);             
my @names = ("google", "youj", "taobao");

say "\$ages[0] = $ages[0]";
say "\$ages[1] = $ages[1]";
say "\$ages[2] = $ages[2]";
say "\$names[0] = $names[0]";
say "\$names[1] = $names[1]";
say "\$names[2] = $names[2]";
```

### 3.2.1 创建数组

**强调：我们通过`,`操作符来创建数组，而不是`()`，`()`仅为了改变运算符的优先级**

* 对于`@array1 = (1, 2, 'Hello');`，如果不加括号，即`@array1 = 1, 2, 'Hello';`，那么根据优先级关系，赋值运算符`=`的优先级大于逗号运算符`,`，因此数组`@array1`的大小是`1`，首元素是`1`

```perl
use strict;
use warnings;
use Modern::Perl;

my @array1 = (1, 2, 'Hello');
my @array2 = qw/this is an array/;
my @array3 = qw/google
taobao
alibaba
youj/;
```

此外，数组的创建是贪婪的

```perl
use strict;
use warnings;
use Modern::Perl;

my (@array1, @array2) = (1, 2, 3, 4, 5);
my @array3;

say "array1's size: $#array1";
say "array2's size: $#array2";
say "array3's size: $#array3";
```

### 3.2.2 添加删除元素

1. `push`：添加元素到尾部
1. `pop`：删除尾部元素
1. `shift`：删除头部元素
1. `unshift`：添加元素到头部

```perl
use strict;
use warnings;
use Modern::Perl;

# create a simple array
my @coins = ("Quarter", "Dime", "Nickel");
say "1. \@coins  = @coins";

# add one element at the end of the array
push(@coins, "Penny");
say "2. \@coins  = @coins";

# add one element at the beginning of the array
unshift(@coins, "Dollar");
say "3. \@coins  = @coins";

# remove one element from the last of the array.
pop(@coins);
say "4. \@coins  = @coins";

# remove one element from the beginning of the array.
shift(@coins);
say "5. \@coins  = @coins";
```

### 3.2.3 数组序列号

`Perl`提供了可以按序列输出的数组形式，格式为：`起始值 + .. + 结束值`

```perl
use strict;
use warnings;
use Modern::Perl;

my @array = (1..10);
say "array = @array";

my @subarray = @array[3..6];
say "subarray = @subarray";
```

### 3.2.4 数组大小

```perl
use strict;
use warnings;
use Modern::Perl;

my @array = (1,2,3);
$array[50] = 4;

my $size = @array;
my $max_index = $#array;

say "size: $size";
say "max index: $max_index";
```

若要访问倒数第一个元素，除了通过数组大小之外，还可以通过`[-1]`：

```perl
use strict;
use warnings;
use Modern::Perl;

my @array = (1,2,3);
say $array[-1];
```

### 3.2.5 切割数组

```perl
use strict;
use warnings;
use Modern::Perl;

my @sites = qw/google taobao youj weibo qq facebook netease/;

my @sites2 = @sites[3,4,5];
my @sites3 = @sites[3..5];

say "@sites2";
say "@sites3";
```

### 3.2.6 替换数组元素

`Perl`中数组元素替换使用`splice()`函数，语法格式如下：

* `splice @ARRAY, OFFSET [ , LENGTH [ , LIST ] ]`
* `@ARRAY`：要替换的数组
* `OFFSET`：起始位置
* `LENGTH`：替换的元素个数
* `LIST`：替换元素列表

```perl
use strict;
use warnings;
use Modern::Perl;

my @nums = (1..20);
say "before: @nums";

splice(@nums, 5, 5, 21..25); 
say "after: @nums";
```

### 3.2.7 将字符串转换为数组

`Perl`中将字符串转换为数组使用`split()`函数，语法格式如下：

* `split [ PATTERN [ , EXPR [ , LIMIT ] ] ]`
* `PATTERN`：分隔符，默认为空格
* `EXPR`：指定字符串数
* `LIMIT`：如果指定该参数，则返回该数组的元素个数

```perl
use strict;
use warnings;
use Modern::Perl;

my $var_test = "youj";
my $var_string = "www-youj-com";
my $var_names = "google,taobao,youj,weibo";

my @test = split('', $var_test);
my @string = split('-', $var_string);
my @names  = split(',', $var_names);

say "$test[3]";  # j
say "$string[2]";  # com
say "$names[3]";   # weibo
```

### 3.2.8 将数组转换为字符串

`Perl`中将数组转换为字符串使用`join()`函数，语法格式如下：

* `join EXPR, LIST`
* `EXPR`：连接符
* `LIST`：列表或数组

```perl
use strict;
use warnings;
use Modern::Perl;

my $var_string = "www-youj-com";
my $var_names = "google,taobao,youj,weibo";

my @string = split('-', $var_string);
my @names  = split(',', $var_names);

my $string1 = join( '-', @string );
my $string2 = join( ',', @names );

say "$string1";
say "$string2";
```

### 3.2.9 数组打印

* 若数组不在双引号中，那么使用`say`输出后，各元素会紧贴在一起
* 若数组在双引号中，各个元素之间会插入全局变量`$"`，其默认值为空格，称为数组插值`Array Interpolation`

```perl
use strict;
use warnings;
use Modern::Perl;

my @alphabet = 'a' .. 'z';
say "beyound quote, [", @alphabet, "]";
say "within quote, [@alphabet]";

{
    local $" = ')(';
    say "winthin quite and local \$\", [@alphabet]";
}
```

### 3.2.10 数组排序

`Perl`中数组排序使用`sort()`函数，语法格式如下：

* `sort [ SUBROUTINE ] LIST`
* `SUBROUTINE`：指定规则
* `LIMIT`：列表或数组

```perl
use strict;
use warnings;
use Modern::Perl;

my @sites = qw(google taobao youj facebook);
say "before: @sites";

@sites = sort(@sites);
say "after: @sites";
```

### 3.2.11 合并数组

数组的元素是以逗号来分割，我们也可以使用逗号来合并数组

```perl
use strict;
use warnings;
use Modern::Perl;

my @numbers1 = (1,3,(4,5,6));
say "numbers1: @numbers1";

my @odd = (1,3,5);
my @even = (2, 4, 6);
my @numbers2 = (@odd, @even);
say "numbers2: @numbers2";
```

### 3.2.12 数组起始下标

特殊变量`$[`表示数组的第一索引值，一般都为`0`，如果我们将`$[`设置为`1`，则数组的第一个索引值即为`1`，第二个为`2`，以此类推

**该功能在未来版本可能被废弃，不建议使用**

```perl
@sites = qw(google taobao youj facebook);
print "网站: @sites\n";

# set array's first index to 1
$[ = 1;

print "\@sites[1]: $sites[1]\n";
print "\@sites[2]: $sites[2]\n";
```

### 3.2.13 用each循环数组

在`Perl 5.12`之后，可以用`each`循环数组

```perl
use strict;
use warnings;
use Modern::Perl;

my @array = ('A', 'B', 'C');
while (my ($index, $value) = each @array) {
    say "$index: $value";
}
```

## 3.3 哈希

1. 哈希是一个`key/value`对的集合
1. 哈希的键值只能是字符串。显然我们能将整数作为哈希键值，这是因为做了隐式转换
1. 哈希变量以字符`%`开头
1. 果要访问哈希值，可以使用`$变量名{键值}`格式来访问

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google', 45, 'youj', 30, 'taobao', 40);

say "\$data{'google'} = $data{'google'}";
say "\$data{'youj'} = $data{'youj'}";
say "\$data{'taobao'} = $data{'taobao'}";
```

### 3.3.1 创建哈希

创建哈希可以通过以下两种方式：

1. 为每个`key`设置`value`
1. 通过列表设置

```perl
use strict;
use warnings;
use Modern::Perl;

my %data1;
$data1{'google'} = 'google.com';
$data1{'w3cschool'} = 'w3cschool.cn';
$data1{'taobao'} = 'taobao.com';

my %data2 = ('google', 'google.com', 'w3cschool', 'w3cschool.cn', 'taobao', 'taobao.com');
my %data3 = ('baidu' => 'baidu.com', 'aliyun' => 'aliyun.cn', 'douyu' => 'douyu.com');

say "\$data1{'taobao'} = $data1{'taobao'}";
say "\$data2{'google'} = $data2{'google'}";
say "\$data3{'baidu'} = $data3{'baidu'}";
```

访问哈希的格式：`$ + hash_name + { + key + }`，其中`key`如果是`bareword`，那么可以不加引号，`Perl`会自动加引号

* `%data{name}`：`Perl`会自动给`name`加引号
* `%data{'name-1'}`：`name-1`不是`bareword`，必须手动加引号
* `%data{func()}`：若通过函数获取`key`，若函数不需要参数，也必须加上`()`，消除歧义

### 3.3.2 读取哈希的key和value

我们可以使用`keys`函数读取哈希所有的键，语法格式如下：

* `keys %HASH`

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

my @names = keys %data;

say "$names[0]";
say "$names[1]";
say "$names[2]";
```

类似的我么可以使用`values`函数来读取哈希所有的值，语法格式如下：

* `values %HASH`

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

my @urls = values %data;

say "$urls[0]";
say "$urls[1]";
say "$urls[2]";
```

### 3.3.3 检测元素是否存在

如果你在哈希中读取不存在的`key/value`对 ，会返回`undefined`值，且在执行时会有警告提醒。为了避免这种情况，我们可以使用`exists`函数来判断`key`是否存在，存在的时候读取。此外，`key`存在的情况下，`value`也可能是`undef`，我们可以使用`defined`来判断`value`是否赋值过

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com', 'wtf' => undef);

say "google exist" if exists $data{'google'};
say "google defined" if defined $data{'google'};
say "amazon not exist" if not exists $data{'amazon'};
say "amazon not defined" if not defined $data{'amazon'};
say "wtf exist" if exists $data{'wtf'};
say "wtf not defined" if not defined $data{'wtf'};
```

### 3.3.4 获取哈希大小

哈希大小为元素的个数，我们可以通过先获取`key`或`value`的所有元素数组，再计算数组元素多少来获取哈希的大小

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

my @keys = keys %data;
my $key_size = @keys;
say "key size: $key_size";

my @values = values %data;
my $value_size = @values;
say "value size: $value_size";
```

### 3.3.5 哈希中添加或删除元素

添加`key/value`对可以通过简单的赋值来完成。但是删除哈希元素你需要使用`delete`函数

```perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');
my @keys = keys %data;
my $size = @keys;
say "key size: $size";

# add
$data{'facebook'} = 'facebook.com';
@keys = keys %data;
$size = @keys;
say "key size: $size";

# delete
delete $data{'taobao'};
@keys = keys %data;
$size = @keys;
say "key size: $size";
```

### 3.3.6 用each循环数组

在`Perl 5.12`之后，可以用`each`循环数组

```Perl
use strict;
use warnings;
use Modern::Perl;

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

while (my ($key, $value) = each %data) {
    say "$key: $value";
}
```

### 3.3.7 迭代顺序

由于不同版本的`Perl`实现哈希的方式不同，因此哈希的遍历顺序是不固定的。但是对于同一个哈希的`keys`、`values`、`each`，它们的顺序是一致的

### 3.3.8 锁定

1. `lock_hash/unlock_hash`：锁定/解锁整个`hash`。锁定时，不能新增或删除`key`，不能修改已有的`value`
1. `lock_keys/unlock_keys`：锁定`key`。锁定时，不能新增或删除`key`
1. `lock_value/unlock_value`：锁定`value`。锁定时，不能修改`value`

```perl
use strict;
use warnings;
use Modern::Perl;
use Hash::Util qw[lock_hash lock_keys unlock_keys];

my %data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');
lock_keys(%data);
# compile error
# $data{'wtf'} = 'wtf.com';

unlock_keys(%data);
$data{'wtf'} = 'wtf.com';

foreach my $key (keys %data) {
    my $value = $data{$key};
    say "$key : $value";
}
```

### 3.3.9 排序

`sort`仅能排序数组，而无法直接排序`hash`（`hash`的顺序是由其内部的具体实现确定的），我们可以通过如下方式进行排序

1. 将`hash`映射成一个数组，数组的元素是一个数组引用，分别存放`key`和`value`
1. 对这个数组进行排序

```perl
use strict;
use warnings;
use Modern::Perl;

my %extensions = (
    4 => 'Jerryd',
    5 => 'Rudy',
    6 => 'Juwan',
    7 => 'Brandon',
    10 => 'Joel',
    21 => 'Marcus',
    24 => 'Andre',
    23 => 'Martell',
    52 => 'Greg',
    88 => 'Nic',
);

# [] here to create anonymous array
my @pairs = map { [ $_, $extensions{$_} ] } keys %extensions;

# sort by the second element of the array ref
my @sorted_pairs = sort { $a->[1] cmp $b->[1] } @pairs;

# map array ref to readable string
my @formatted_exts = map { "$_->[1]: $_->[0]" } @sorted_pairs;

say for (@formatted_exts);
```

更神奇的是，还能将这些操作组合在一起

```perl
use strict;
use warnings;
use Modern::Perl;

my %extensions = (
    4 => 'Jerryd',
    5 => 'Rudy',
    6 => 'Juwan',
    7 => 'Brandon',
    10 => 'Joel',
    21 => 'Marcus',
    24 => 'Andre',
    23 => 'Martell',
    52 => 'Greg',
    88 => 'Nic',
);

say for (
    map { "$_->[1]: $_->[0]" }
    sort { $a->[1] cmp $b->[1] }
    map { [ $_, $extensions{$_} ] } keys %extensions
);
```

## 3.4 引用

引用就是指针，`Perl`引用是一个标量类型，可以指向变量、数组、哈希表（也叫关联数组）甚至函数，可以应用在程序的任何地方

### 3.4.1 创建引用

定义变量的时候，在变量名前面加个`\`，就得到了这个变量的一个引用

```perl
$scalarref = \$foo;
$arrayref  = \@ARGV;
$hashref   = \%ENV;
$coderef   = \&handler;
$globref   = \*foo;
```

此外，还可以创建匿名数组的引用（`[]`运算符）、匿名哈希的引用（`{}`运算符）、匿名函数的引用

```perl
use strict;
use warnings;
use Modern::Perl;

my $aref1= [ 1,"foo",undef,13 ];
my $aref2 = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
];

my $href= { APR => 4, AUG => 8 };

my $coderef = sub { say "W3CSchool!" };
```

### 3.4.2 解引用

解引用可以根据不同的类型使用`$`、`@`、`%`以及`->`

```perl
use strict;
use warnings;
use Modern::Perl;

# scarlar
my $var = 10;
my $r = \$var;
say '$$r: ', $$r;

# array
my @var = (1, 2, 3);
$r = \@var;
say '@$r: ', @$r;
say '$$r[0]: ', $$r[0];
say '$r->[0]: ', $r->[0];
say '@{ $r }[0, 1, 2]: ', @{ $r }[0, 1, 2];

# hash
my %var = ('key1' => 10, 'key2' => 20);
$r = \%var;
say '%$r: ', %$r;
say '$r->{\'key1\'}: ', $r->{'key1'};
```

如果你不能确定变量类型，你可以使用`ref`来判断，返回值列表如下，如果没有以下的值返回`false`

```perl
use strict;
use warnings;
use Modern::Perl;

my $var = 10;
my $r = \$var;
say "r's ref type: ", ref($r);

my @var = (1, 2, 3);
$r = \@var;
say "r's ref type: ", ref($r);

my %var = ('key1' => 10, 'key2' => 20);
$r = \%var;
say "r's ref type: ", ref($r);
```

### 3.4.3 循环引用

循环引用在两个引用相互包含时出现。你需要小心使用，不然会导致内存泄露

```perl
use strict;
use warnings;
use Modern::Perl;
use Scalar::Util 'weaken';

my $alice = { mother => '', father => '', children => [] };
my $robert = { mother => '', father => '', children => [] };
my $cianne = { mother => $alice, father => $robert, children => [] };

push @{ $alice->{children} }, $cianne;
push @{ $robert->{children} }, $cianne;

weaken( $cianne->{mother} );
weaken( $cianne->{father} );
```

### 3.4.4 引用函数

1. 函数引用格式：`\&`
1. 调用引用函数格式：`&$func_ref(params)`或者`$func_ref->(params)`

```perl
use strict;
use warnings;
use Modern::Perl;

sub PrintHash {
    my (%hash) = @_;
   
    foreach my $item (%hash) {
        say "元素 : $item";
    }
}
my %hash = ('name' => 'youj', 'age' => 3);

my $cref = \&PrintHash;

# form 1
&$cref(%hash);

# form 2
$cref->(%hash);
```

### 3.4.5 级联数据结构

由于数组、哈希都只能存储标量，而引用正好也是标量。因此借助引用，可以创建多级数据结构

```perl
my @famous_triplets = (
    [qw( eenie miney moe )],
    [qw( huey dewey louie )],
    [qw( duck duck goose )],
);

my %meals = (
    breakfast => { entree => 'eggs', side => 'hash browns' },
    lunch => { entree => 'panini', side => 'apple' },
    dinner => { entree => 'steak', side => 'avocado salad' },
);
```

#### 3.4.5.1 访问

我们使用歧义消除块（`disambiguation blocks`）

```perl
my $nephew_count = @{ $famous_triplets[1] };
my $dinner_courses = keys %{ $meals{dinner} };
my ($entree, $side) = @{ $meals{breakfast} }{qw( entree side )};
```

更好更清晰的写法，自然是使用中间变量

```perl
my $breakfast_ref = $meals{breakfast};
my ($entree, $side) = @$breakfast_ref{qw( entree side )};
```

#### 3.4.5.2 Autovivificatio

当我们对一个多级数据结构进行赋值时，无需按层级一层层依次创建，`Perl`会自动帮我们完成这项工作，这个过程就称为`Autovivificatio`

```perl
my @aoaoaoa;
$aoaoaoa[0][0][0][0] = 'nested deeply';

my %hohoh;
$hohoh{Robot}{Santa}{Claus} = 'mostly harmful';
```

#### 3.4.5.3 调试

`Data::Dumper`可以帮助我们打印一个复杂的多级数据结构

```perl
use strict;
use warnings;
use Modern::Perl;
use Data::Dumper;

my @aoaoaoa;
$aoaoaoa[0][0][0][0] = 'nested deeply';

my %hohoh;
$hohoh{Robot}{Santa}{Claus} = 'mostly harmful';
say Dumper( @aoaoaoa );
say Dumper( %hohoh );
```

## 3.5 变量上下文

1. 所谓上下文：指的是表达式所在的位置
1. **上下文是由等号左边的变量类型决定的**，等号左边是标量，则是标量上下文，等号左边是列表，则是列表上下文
1. `Perl`解释器会根据上下文来决定表达式的类型
1. 上下文种类
    1. 标量上下文，包括数字、`string`、布尔
    1. 列表上下文，包括数组和哈希
    1. 布尔上下文
    1. void上下文
    1. 插值上下文，仅发生在引号内
1. 数组在标量上下文中返回的是数组元素的个数
1. 哈希在标量上下文中返回的是哈希键值对的个数
1. 未定义的标量在字符串上下文中返回的是空字符串
1. 未定义的标量在数字上下文中返回的是`0`
1. 不以数字开头的字符串在数字上下文中返回的是`0`

**示例：**

```perl
use strict;
use warnings;
use Modern::Perl;

my @names = ('google', 'youj', 'taobao');

my @copy = @names;
my $size = @names;

say "name: @copy";
say "count: $size";
```

### 3.5.1 显式标量上下文

```perl
# numerical context
my $numeric_x = 0 + $x;

# string context
my $stringy_x = '' . $x;

# boolean context
my $boolean_x = !!$x;

# scarlar context
# anonymous hash can contain nested struct
my $results = {
    cheap_operation => $cheap_operation_results,
    expensive_operation => scalar find_chores(),
};
```

### 3.5.2 显式列表上下文

```perl
# It’s semantically equivalent to assigning the first item in 
# the list to a scalar and assigning the rest of the list to a temporary array, and then throwing away the array
my ($single_element) = find_chores();
```

## 3.6 默认变量

### 3.6.1 默认标量变量

`$_`又称为默认标量变量（这是`Perl`标志性的特征）。可以用在非常多的地方，包括许多内建的函数

```perl
use strict;
use warnings;
use Modern::Perl;

$_ = 'My name is Paquito';

# say working on $_
# matching working on $_
say if /My name is/;

# replacing working on $_
s/Paquito/Paquita/;

# tr working on $_
tr/A-Z/a-z/;

# say working on $_
say;

# for loop working on $_
say "#$_" for 1 .. 10;
```

### 3.6.2 默认数组变量

1. `Perl`将传给函数的参数都存储在`@_`变量中
1. `push`、`pop`、`shift`、`unshift`
    * 在函数上下文中，在缺省参数的情况下，默认对`@_`进行操作
    * 在非函数上下文中，在缺省参数的情况下，默认对`@ARGV`进行操作
1. `Perl`将命令函参数都存储在`@ARGV`中
1. `@ARGV`还有另一个用途，当从空文件句柄`<>`中读取内容时，`Perl`默认会将`@ARGV`中存储的内容作为文件名进行依次读取，如果`@ARGV`为空，那么会读取标准输入

## 3.7 特殊全局变量

详细内容，参考`perldoc perlvar`

1. `$/`：行分隔符
1. `$.`：最近读取的文件句柄的行号
1. `$|`：控制是否自动flush缓存
1. `@ARGV`：命令行参数数组
1. `$!`：最近一次系统调用的错误码
1. `$"`：列表分隔符
1. `%+`：哈希，用于存储具名捕获的结果
1. `$@`：最近一次异常抛出的值
1. `$$`：进程id
1. `@INC`：`use`或者`require`函数查找模块的路径列表
1. `%SIG`：哈希，用于存储信号处理的函数引用

# 4 控制流

## 4.1 条件语句

### 4.1.1 if

```perl
if (boolean_expression) {
    ...
}
```

### 4.1.2 if else

```perl
if (boolean_expression) {
    ...
} else {
    ...
}
```

### 4.1.3 if elsif

```perl
if (boolean_expression 1) {
    ...
} elsif (boolean_expression 2) {
    ...
} elsif (boolean_expression 3) {
    ...
} else {
    ...
}
```

### 4.1.4 unless

```perl
unless (boolean_expression) {
    ...
}
```

### 4.1.5 unless else

```perl
unless (boolean_expression) {
    ...
} else {
    ...
}
```

### 4.1.6 unless elsif

```perl
unless (boolean_expression 1) {
    ...
} elsif (boolean_expression 2) {
    ...
} elsif (boolean_expression 3) {
    ...
} else {
    ...
}
```

### 4.1.7 switch

`switch case`执行是基于`Switch`模块，`Switch`模块使用`Filter::Util::Call`和`Text::Balanced`来执行，这两个模块都需要安装

```perl
use Switch;

switch(argument){
    case 1            { print "数字 1" }
    case "a"          { print "字符串 a" }
    case [1..10,42]   { print "数字在列表中" }
    case (\@array)    { print "数字在数组中" }
    case /\w+/        { print "正则匹配模式" }
    case qr/\w+/      { print "正则匹配模式" }
    case (\%hash)     { print "哈希" }
    case (\&sub)      { print "子进程" }
    else              { print "不匹配之前的条件" }
}
```

## 4.2 循环

### 4.2.1 while

```perl
while(condition) {
    statement(s);
}
```

### 4.2.2 until

```perl
until(condition) {
    statement(s);
}
```

### 4.2.3 for

```perl
for(init; condition; increment){
    statement(s);
}
```

### 4.2.4 foreach

```perl
foreach var (list) {
    statement(s);
}
```

### 4.2.5 do while

```perl
do {
    statement(s);
} while(condition);
```

## 4.3 循环控制语句

### 4.3.1 next

`Perl next`语句用于停止执行从`next`语句的下一语句开始到循环体结束标识符之间的语句，转去执行`continue`语句块，然后再返回到循环体的起始处开始执行下一次循环。语法为：`next [ LABEL ];`，其中`LABEL`是可选的

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
while ($a < 20) {
    if ( $a == 15) {
       $a = $a + 1;
       next;
    }
    say "a: $a";
    $a = $a + 1;
}
```

### 4.3.2 last

`Pe`rl last`语句用于退出循环语句块，从而结束循环，`last`语句之后的语句不再执行，`continue`语句块也不再执行。语法为：`last [LABEL];`，其中`LABEL`是可选的

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
while ($a < 20) {
    if ($a == 15) {
       $a = $a + 1;
       last;
    }
    say "a: $a";
    $a = $a + 1;
}
```

### 4.3.3 continue

`Perl continue`块通常在条件语句再次判断前执行。`continue`语句可用在`while`和`foreach`循环中，语法如下：

```perl
while (condition) {
    statement(s);
} continue {
    statement(s);
}

foreach $a (@listA) {
    statement(s);
} continue {
    statement(s);
}
```

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 0;
while ($a < 3) {
    say "a: $a";
} continue {
    $a = $a + 1;
}
```

```perl
use strict;
use warnings;
use Modern::Perl;

my @list = (1, 2, 3, 4, 5);
foreach $a (@list) {
    say "a: $a";
} continue {
    last if $a == 4;
}
```

### 4.3.4 redo

`Perl redo`语句直接转到循环体的第一行开始重复执行本次循环，`redo`语句之后的语句不再执行，`continue`语句块也不再执行。语法为：`redo [LABEL];`，其中`LABEL`是可选的

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 0;
while ($a < 10) {
    if($a == 5) {
      $a = $a + 1;
      redo;
    }
    say "a: $a";
} continue {
    $a = $a + 1;
}
```

### 4.3.5 godo

`Perl`有三种`goto`形式：

1. `got LABLE`：找出标记为`LABEL`的语句并且从那里重新执行
1. `goto EXPR`：`goto EXPR`形式只是`goto LABEL`的一般形式。它期待表达式生成一个标记名称，并跳到该标记处执行
1. `goto &NAME`：它把正在运行着的子进程替换为一个已命名子进程的调用

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
LOOP:do
{
    if ($a == 15) {
       $a = $a + 1;
       goto LOOP;
    }
    say "a = $a";
    $a = $a + 1;
} while ($a < 20);
```

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
my $str1 = "LO";
my $str2 = "OP";

LOOP:do
{
    if ($a == 15) {
       $a = $a + 1;
       # equal with goto LOOP;
       goto $str1.$str2;
    }
    say "a = $a";
    $a = $a + 1;
} while ($a < 20);
```

## 4.4 指令

### 4.4.1 分支指令

```perl
say 'Hello, Bob!' if $name eq 'Bob';
say "You're no Bob!" unless $name eq 'Bob';
```

### 4.4.2 循环指令

```perl
use strict;
use warnings;
use Modern::Perl;

say "$_ * $_ = ", $_ * $_ for 1 .. 10;

my @letters = 'a' .. 'z';
say for (@letters);
```

# 5 运算符

## 5.1 算数运算符

1. `+`：加
1. `-`：减
1. `*`：乘
1. `/`：除
1. `%`：求余
1. `**`：幂乘

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
my $b = 20;

say "\$a = $a , \$b = $b";

my $c = $a + $b;
say '$a + $b = ' . $c;

$c = $a - $b;
say '$a - $b = ' . $c;

$c = $a * $b;
say '$a * $b = ' . $c;

$c = $a / $b;
say '$a / $b = ' . $c;

$c = $a % $b;
say '$a % $b = ' . $c;

$a = 2;
$b = 4;
$c = $a ** $b;
say '$a ** $b = ' . $c;
```

## 5.2 比较运算符

1. `==`
1. `!=`
1. `<=>`：比较两个操作数是否相等
    * 左边小于右边，返回`-1`
    * 相等，返回`0`
    * 左边大于右边，返回`1`
1. `>`
1. `<`
1. `>=`
1. `<=`

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
my $b = 20;

say "\$a = $a , \$b = $b";

if ($a == $b) {
    say "$a == \$b => true";
} else {
    say "\$a == \$b => false";
}

if ($a != $b) {
    say "\$a != \$b => true";
} else {
    say "\$a != \$b => false";
}

my $c = $a <=> $b;
say "\$a <=> \$b => $c";

if ($a > $b) {
    say "\$a > \$b => true";
} else {
    say "\$a > \$b => false";
}

if ($a >= $b){
    say "\$a >= \$b => true";
} else {
    say "\$a >= \$b => false";
}

if ($a < $b) {
    say "\$a < \$b => true";
} else {
    say "\$a < \$b => false";
}

if ($a <= $b) {
    say "\$a <= \$b => true";
} else {
    say "\$a <= \$b => false";
}
```

## 5.3 字符串比较运算符

1. `lt`
1. `gt`
1. `le`
1. `ge`
1. `eq`
1. `ne`
1. `cmp`：比较两个字符串是否相等
    * 左边小于右边，返回`-1`
    * 相等，返回`0`
    * 左边大于右边，返回`1`

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = "abc";
my $b = "xyz";

say "\$a = $a ，\$b = $b";

if ($a lt $b) {
    say "\$a lt \$b => true";
} else {
    say "\$a lt \$b => false";
}

if ($a gt $b) {
    say "\$a gt \$b => true";
} else {
    say "\$a gt \$b => false";
}

if ($a le $b) {
    say "\$a le \$b => true";
} else {
    say "\$a le \$b => false";
}

if ($a ge $b) {
    say "\$a ge \$b => true";
} else {
    say "\$a ge \$b => false";
}

if ($a ne $b) {
    say "\$a ne \$b => true";
} else {
    say "\$a ne \$b => false";
}

my $c = $a cmp $b;
say "\$a cmp \$b => $c";
```

## 5.4 赋值运算符

1. `=`
1. `+=`
1. `-=`
1. `*=`
1. `/=`
1. `%=`
1. `%=`
1. `**=`
1. `//=`：定义或赋值

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
my $b = 20;
my $c = $a + $b;

say "\$a: $a, \$b: $b, \$c: $c";

$c += $a;
say "\$c: $c, st: '\$c += \$a'";

$c -= $a;
say "\$c: $c, st: '\$c -= \$a'";

$c *= $a;
say "\$c: $c, st: '\$c *= \$a'";

$c /= $a;
say "\$c: $c, st: '\$c /= \$a'";

$c %= $a;
say "\$c: $c, st: '\$c %= \$a'";

$c = 2;
$a = 4;
say "\$a: $a, \$c = $c";
$c **= $a;
say "\$c: $c, st: '\$c **= \$a'";

my %data;
$data{'first'} = $a;
$data{'first'} //= $b;
say "\$data{'first'}: $data{'first'}, st: '\$data{'first'} //= \$b'";
```

## 5.5 位运算

1. `&`
1. `|`
1. `^`
1. `~`
1. `<<`
1. `>>`

```perl
use integer;
use strict;
use warnings;
use Modern::Perl;

my $a = 60;
my $b = 13;

say "\$a = $a , \$b = $b";

my $c = $a & $b;
say "\$a & \$b = $c";

$c = $a | $b;
say "\$a | \$b = $c";

$c = $a ^ $b;
say "\$a ^ \$b = $c";

$c = ~$a;
say "~\$a = $c";

$c = $a << 2;
say "\$a << 2 = $c";

$c = $a >> 2;
say "\$a >> 2 = $c";
```

## 5.6 逻辑运算

1. `and`
1. `&&`
1. `or`
1. `||`
1. `not`

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 1;
my $b = 0;

say "\$a = $a , \$b = $b";

my $c = ($a and $b);
say "\$a and \$b = $c";

$c = ($a  && $b);
say "\$a && \$b = $c";

$c = ($a or $b);
say "\$a or \$b = $c";

$c = ($a || $b);
say "\$a || \$b = $c";

$a = 0;
$c = not($a);
say "not(\$a) = $c";
```

## 5.7 引号运算

有时候，需要在程序中定义一些复杂的字符串，比如包含引号本身，普通的写法会比较麻烦，例如`$name = "\"hello\"";`。可以使用引号运算来处理

1. `q{}/q()`：为字符串添加单引号，`q{abcd}`结果为`'abcd'`
1. `qq{}/qq()`：为字符串添加双引号，`qq{abcd}`结果为`"abcd"`
1. `qx{}/qx()`：为字符串添加反引号，`qx{abcd}`结果为`` `abcd` ``
* 其中，起始分隔符和结束分隔符可以成对，比如`{}`、`()`、`[]`；起始分隔符和结束分隔符也可以相同，比如`^^`等

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = 10;
 
my $b = q{a = $a};
say "q{a = \$a} = $b";

$b = qq{a = $a};
say "qq{a = \$a} = $b";

my $t = qx{date};
say "qx{date} = $t";
```

## 5.8 qw

将字符串以空白作为分隔符进行拆分，并返回一个数组

```perl
use strict;
use warnings;
use Modern::Perl;

my @str = qw/Ram is a boy/;
say "@str";
@str = qw{Geeks for Geeks};
say "@str";
@str = qw[Geeks for Geeks];
say "@str";
@str = qw'Geeks for Geeks';
say "@str";
@str = qw"Geeks for Geeks";
say "@str";
@str = qw!Geeks for Geeks!;
say "@str";
@str = qw@Geeks for Geeks@;
say "@str";
```

## 5.9 其他运算符

1. `.`：用于连接两个字符串
1. `x`：将给定字符串重复给定次数
1. `..`：范围运算符
1. `++`：自增
1. `--`：自减
1. `->`：用于指定一个类的方法

```perl
use strict;
use warnings;
use Modern::Perl;

my $a = "run";
my $b = "oob";

say "\$a  = $a ， \$b = $b";
 
my $c = $a . $b;
say "\$a . \$b = $c";

$c = "-" x 3;
say "\"-\" x 3 = $c";

my @c = (2..5);
say "(2..5) = @c";

$a = 10;
$b = 15;
say "\$a  = $a ， \$b = $b";

$a++;
$c = $a ;
say "\$a 执行 \$a++ = $c";

$b--;
$c = $b ;
say "\$b 执行 \$b-- = $c";
```

# 6 函数

1. `Perl`函数也就是用户定义的函数
1. `Perl`函数即执行一个特殊任务的一段分离的代码，它可以使减少重复代码且使程序易读。
1. `Perl`函数可以出现在程序的任何地方，语法格式如下

```perl
sub subroutine {
    statements;
}
```

## 6.1 向函数传递参数

1. `Perl`函数可以和其他编程一样接受多个参数，函数参数使用特殊数组`@_`标明
1. 因此函数第一个参数为`$_[0]`，第二个参数为`$_[1]`，以此类推
1. 不论参数是标量型还是数组型的，用户把参数传给函数时，`Perl`默认按引用的方式调用它们

```perl
use strict;
use warnings;
use Modern::Perl;

sub Average{
    my $n = scalar(@_);
    my $sum = 0;

    foreach my $item (@_) {
       $sum += $item;
    }
    my $average = $sum / $n;
    say 'params : ',"@_";
    say "first param : $_[0]";
    say "average : $average";
}

Average(10, 20, 30);
```

### 6.1.1 向函数传递列表

1. 由于`@_`变量是一个数组，所以它可以向函数中传递列表
1. 但如果我们需要传入标量和数组参数时，需要把列表放在最后一个参数上

```perl
use strict;
use warnings;
use Modern::Perl;

sub PrintList {
    my @list = @_;
    say "列表为 : @list";
}
my $a = 10;
my @b = (1, 2, 3, 4);

PrintList($a, @b);
```

### 6.1.2 向函数传递哈希

当向函数传递哈希表时，它将复制到`@_`中，哈希表将被展开为键/值组合的列表

```perl
use strict;
use warnings;
use Modern::Perl;

sub PrintHash {
    my (%hash) = @_;

    foreach my $key (keys %hash) {
        my $value = $hash{$key};
        say "$key : $value";
    }
}
my %hash = ('name' => 'youj', 'age' => 3);

PrintHash(%hash);
```

### 6.1.3 设置参数默认值

方式一：使用`//=`运算符，只有在变量未定义的时候才会赋值

```perl
sub make_sundae {
    my %parameters = @_;
    $parameters{flavor} //= 'Vanilla';
    $parameters{topping} //= 'fudge';
    $parameters{sprinkles} //= 100;
    ...
}
```

方式二：

```perl
sub make_sundae {
    my %parameters =
    (
        flavor => 'Vanilla',
        topping => 'fudge',
        sprinkles => 100,
        @_,
    );
    ...
}
```

## 6.2 匿名函数

匿名函数与普通函数的唯一差别就是匿名函数没有名字，且仅能通过引用对其进行操作。格式如下：

```perl
my $anon_sub = sub { ... };
```

```perl
use strict;
use warnings;
use Modern::Perl;

my %dispatch = (
    plus => sub { $_[0] + $_[1] },
    minus => sub { $_[0] - $_[1] },
    times => sub { $_[0] * $_[1] },
    goesinto => sub { $_[0] / $_[1] },
    raisedto => sub { $_[0] ** $_[1] },
);
sub dispatch {
    my ($left, $op, $right) = @_;
    die "Unknown operation!" unless exists $dispatch{ $op };
    return $dispatch{ $op }->( $left, $right );
}

say dispatch ( 2, "times", 4 );
```

## 6.3 函数返回值

1. 函数可以向其他编程语言一样使用`return`语句来返回函数值
1. 如果没有使用`return`语句，则函数的最后一行语句将作为返回值

```perl
use strict;
use warnings;
use Modern::Perl;

sub add_a_b_1 {
    # 不使用 return
    $_[0]+$_[1];   
}

sub add_a_b_2 {
    # 使用 return
    return $_[0]+$_[1];  
}

say add_a_b_1(1, 2);
say add_a_b_2(1, 2);
```

## 6.4 函数的私有变量

1. 默认情况下，`Perl`中所有的变量都是全局变量，这就是说变量在程序的任何地方都可以调用
1. 如果我们需要设置私有变量，可以使用`my`操作符来设置
1. `my`操作符用于创建词法作用域变量，通过`my`创建的变量，存活于声明开始的地方，直到闭合作用域的结尾
1. 闭合作用域指的可以是一对花括号中的区域，可以是一个文件，也可以是一个`if`、`while`、`for`、`foreach`、`eval`字符串

```perl
use strict;
use warnings;
use Modern::Perl;

my $string = "Hello, World!";

sub PrintHello {
    my $string;
    $string = "Hello, W3Cschool!";
    say "inside: $string";
}

PrintHello();
say "outside: $string";
```

## 6.5 变量的临时赋值

1. 我们可以使用`local`为全局变量提供临时的值，在退出作用域后将原来的值还回去
1. `local`定义的变量不存在于主程序中，但存在于该函数和该函数调用的函数中。定义时可以给其赋值

```perl
use strict;
use warnings;
use Modern::Perl;

our $string = "Hello, World!";

sub PrintW3CSchool {
    local $string;
    $string = "Hello, W3Cschool!";

    PrintMe();
    say "within PrintW3CSchool: $string";
}

sub PrintMe {
    say "within PrintMe: $string";
}

sub PrintHello {
    say "within PrintHello: $string";
}

PrintW3CSchool();
PrintHello();
say "outside: $string";
```

## 6.6 静态变量

1. `state`操作符功能类似于`C`里面的`static`修饰符，`state`关键字将局部变量变得持久
1. `state`也是词法变量，所以只在定义该变量的词法作用域中有效

```perl
use strict;
use warnings;
use Modern::Perl;
use feature 'state';

sub PrintCount {
    state $count = 0;

    say "counter 值为：$count";
    $count++;
}

for (1..5) {
    PrintCount();
}
```

## 6.7 函数调用上下文

函数调用过程中，会根据上下文来返回不同类型的值，比如以下`localtime()`函数，在标量上下文返回字符串，在列表上下文返回列表

```perl
use strict;
use warnings;
use Modern::Perl;

my $datestring = localtime(time);
say $datestring;

my ($sec,$min,$hour,$mday,$mon, $year,$wday,$yday,$isdst) = localtime(time);
printf("%d-%d-%d %d:%d:%d", $year+1990, $mon+1, $mday, $hour, $min, $sec);
```

### 6.7.1 上下文感知

`wantarray`用于判断上下文信息

* 处于`void`上下文时，返回`undef`
* 处于标量上下文时，返回`false`
* 处于列表上下文时，返回`true`

```perl
use strict;
use warnings;
use Modern::Perl;
sub context {
    my $context = wantarray();
    say defined $context
        ? $context
            ? 'list'
            : 'scalar'
        : 'void';
    return 0;
}
my @list_slice = (1, 2, 3)[context()];
my @array_slice = @list_slice[context()];
my $array_index = $array_slice[context()];
# say imposes list context
say context();
# void context is obvious
context()
```

## 6.8 函数与命名空间

命名空间（`namespace`）即包（`package`）。默认情况下，函数定义在`main`包中，我们可以显式指定包。同一个命名空间中，某个函数名只能定义一次，重复定义会覆盖前一个定义。编译器会发出警告，可以通过`no warnings 'redefine';`禁止警告

```perl
sub Extensions::Math::add {
    ...
}
```

函数对内部、外部均可见，在同一个命名空间中，可以通过函数名来直接访问；在外部的命名空间中，必须通过全限定名来访问，除非将函数导入（`importing`）到当前命名空间中

## 6.9 报告错误

在函数中，我们可以通过`caller`获取调用者的相关信息

```perl
use strict;
use warnings;
use Modern::Perl;

package main;
main();

sub main {
    show_call_information();
}

sub show_call_information {
    my ($package, $file, $line) = caller();
    say "Called from $package in $file at $line";
}
```

此外，我们可以向`caller`传递一个参数，用于表示沿着当前调用栈往前追溯的深度，且会额外返回调用者的信息

```perl
use strict;
use warnings;
use Modern::Perl;

package main;
main();

sub main {
    show_call_information();
}

sub show_call_information {
    my ($package, $file, $line, $func) = caller(0);
    say "Called $func from $package in $file at $line";
}
```

此外，我们还可以使用`Carp`模块来方便地报告错误

```perl
use strict;
use warnings;
use Modern::Perl;
use Carp 'croak';

sub add_two_numbers {
    croak 'add_two_numbers() takes two and only two arguments' unless @_ == 2;
}

add_two_numbers();
```

`Params::Validate`模块还可以进行参数类型的校验，这里不再赘述

## 6.10 原型

原型（`prototype`）用于给函数增加一些额外的元信息，用于提示编译器参数的类型。具体参考`perldoc perlsub`

* `$`：标量
* `@`：数组
* `%`：哈希
* `&`：代码块
* `\$`：标量引用
* `\@`：数组引用
* `\%`：哈希引用
* ...

```perl
sub mypush (\@@) {
    my ($array, @rest) = @_;
    push @$array, @rest;
}
```

## 6.11 闭包

### 6.11.1 创建闭包

什么是闭包（`Closure`），闭包是包含了一个外部环境的函数。看下面这个例子，当`make_iterator`函数结束调用时，`return`语句返回的函数仍然指向`@items`、`$count`这两个变量，因此这两个变量的生命周期延长了（与`$cousins`的生命周期相同）。同时由于`@items`、`$count`这两个变量是拷贝出来的，因此，在`make_iterator`函数结束后，除了闭包本身，没有其他方式访问到这两个变量

```perl
use strict;
use warnings;
use Modern::Perl;

sub make_iterator {
    my @items = @_;
    my $count = 0;
    return sub {
        return if $count == @items;
        return $items[ $count++ ];
    }
}
my $cousins = make_iterator(qw( Rick Alex Kaycee Eric Corey ));

say $cousins->() for 1 .. 5;
```

### 6.11.2 何时使用闭包

闭包可以在固定大小的列表上生成有效的迭代器。当迭代一个过于昂贵而无法直接引用的项目列表时，它们表现出更大的优势，要么是因为它代表的数据一次计算的成本很高，要么它太大而无法直接进入载入内存

```perl
use strict;
use warnings;
use Modern::Perl;

sub gen_fib {
    my @fibs = (0, 1, 1);
    return sub {
        my $item = shift;
        if ($item >= @fibs) {
            for my $calc ((@fibs - 1) .. $item) {
                $fibs[$calc] = $fibs[$calc - 2] + $fibs[$calc - 1];
            }
        }
        return $fibs[$item];
    }
}

my $fiber = gen_fib();
say $fiber->(3);
say $fiber->(10);
```

上面这个例子可以进一步抽象（用于生成一些其他数列）：

1. 一个数组来存储计算后的值
1. 一个用于计算的方法
1. 返回计算或者缓存的结果

```perl
use strict;
use warnings;
use Modern::Perl;

sub gen_caching_closure {
    my ($calc_element, @cache) = @_;
    return sub {
        my $item = shift;
        $calc_element->($item, \@cache) unless $item < @cache;
        return $cache[$item];
    };
}

sub gen_fib {
    my @fibs = (0, 1, 1);
    return gen_caching_closure(
        sub {
            my ($item, $fibs) = @_;
            for my $calc ((@$fibs - 1) .. $item) {
                $fibs->[$calc] = $fibs->[$calc - 2] + $fibs->[$calc - 1];
            }
        },
        @fibs
    );
}

my $fiber = gen_fib();
say $fiber->(3);
say $fiber->(10);
```

### 6.11.3 参数绑定

通过闭包，我们能够固定函数的部分参数

```perl
sub make_sundae {
    my %args = @_;
    my $ice_cream = get_ice_cream( $args{ice_cream} );
    my $banana = get_banana( $args{banana} );
    my $syrup = get_syrup( $args{syrup} );
    ...
}

my $make_cart_sundae = sub {
    return make_sundae( @_,
        ice_cream => 'French Vanilla',
        banana => 'Cavendish',
    );
};
```

### 6.11.4 闭包与state

闭包是一种能够在函数调用中持久化数据（不用全局变量）的简单、高效且安全的方式。如果我们想在普通函数中共享某些变量，我们需要引入额外的作用域

```perl
{
    my $safety = 0;
    sub enable_safety { $safety = 1 }
    sub disable_safety { $safety = 0 }
    sub do_something_awesome {
        return if $safety;
        ...
    }
}
```

# 7 正则表达式

正则表达式（`regular expression`）描述了一种字符串匹配的模式，可以用来检查一个串是否含有某种子串、将匹配的子串做替换或者从某个串中取出符合某个条件的子串等

`Perl`语言的正则表达式功能非常强大，基本上是常用语言中最强大的，很多语言设计正则式支持的时候都参考`Perl`的正则表达式，详情参考：

* `perldoc perlretut`
* `perldoc perlre`
* `perldoc perlreref`

`Perl`的正则表达式的三种形式，分别是匹配，替换和转化：

* 匹配：`m//`（还可以简写为`//`，略去`m`）
* 替换：`s///`
* 转化：`tr///`

这三种形式一般都和`=~`或`!~`搭配使用，`=~`表示相匹配，`!~`表示不匹配

## 7.1 匹配操作符

匹配操作符`m//`用于匹配一个字符串语句或者一个正则表达式。模式匹配常用的修饰符，如下：

* `i`：如果在修饰符中加上`i`，则正则将会取消大小写敏感性，即`a`和`A`是一样的
* `m`：多行模式。默认情况下，开始`^`和结束`$`只是对于正则字符串。如果在修饰符中加上`m`，那么开始和结束将会指字符串的每一行：每一行的开头就是`^`，结尾就是`$`
* `o`：仅赋值一次
* `s`：单行模式，`.`匹配`\n`（默认不匹配）
* `x`：忽略模式中的空白以及`#`符号及其后面的字符，通常用于写出更易读的正则表达式
* `g`：允许记住字符串的位置，这样就可以多次且连续地处理同一个字符串，通常与`\G`一起使用
* `cg`：全局匹配失败后，允许再次查找匹配串

`Perl`处理完后会给匹配到的值存在三个特殊变量名：

* ``$` ``：匹配部分的前一部分字符串
* `$&`：匹配的字符串
* `$'`：还没有匹配的剩余字符串
* 如果将这三个变量放在一起，将得到原始字符串

```perl
use strict;
use warnings;
use Modern::Perl;

my $string = "welcome to w3cschool site.";
$string =~ m/w3c/;
say "before matched: $`";
say "matched: $&";
say "after matched: $'";
```

## 7.2 替换操作符

替换操作符`s///`是匹配操作符的扩展，使用新的字符串替换指定的字符串。基本格式如下：

```perl
s/PATTERN/REPLACEMENT/;
```

```perl
use strict;
use warnings;
use Modern::Perl;

my $string = "welcome to google site.";
$string =~ s/google/w3cschool/;

say "$string";
```

模式替换常用的修饰符，如下：

* `i`：如果在修饰符中加上`i`，则正则将会取消大小写敏感性，即`a`和`A`是一样的
* `m`：多行模式。默认情况下，开始`^`和结束`$`只是对于正则字符串。如果在修饰符中加上`m`，那么开始和结束将会指字符串的每一行：每一行的开头就是`^`，结尾就是`$`
* `o`：表达式只执行一次
* `s`：单行模式，`.`匹配`\n`（默认不匹配）
* `x`：忽略模式中的空白以及`#`符号及其后面的字符，通常用于写出更易读的正则表达式
* `g`：替换所有匹配的字符串
* `e`：替换字符串作为表达式

## 7.3 转化操作符

```perl
use strict;
use warnings;
use Modern::Perl;

my $string = 'welcome to w3cschool site.';
$string =~ tr/a-z/A-Z/;

say "$string";
```

模式替换常用的修饰符，如下：

* `c`：转化所有未指定字符
* `d`：删除所有指定字符
* `s`：把多个相同的输出字符缩成一个

## 7.4 qr操作符

`qr`用于创建正则表达式。相比于普通变量，`qr`还可以额外存储修饰符

```perl
use strict;
use warnings;
use Modern::Perl;

my $hat = qr/hat/;
my $name = "I have a hat!";
say 'Found a hat!' if $name =~ /$hat/;

my $hat_i = qr/hat/i;
$name = "I have a Hat!";
say 'Found a hat!' if $name =~ /$hat_i/;
```

## 7.5 具名捕获

具名捕获格式如下：

```perl
(?<name> ... )
```

其中，`?<name>`是正则表达式的名称，其右边是常规的正则表达式，整个部分用`()`包围起来。当字符串匹配时，匹配部分会被存储在`$+`中（`$+`是一个哈希），其中，`key`是正则表达式的名称

```perl
use strict;
use warnings;
use Modern::Perl;

my $phone_number = qr/[0-9]{8}/;
my $contact_info = 'CN-88888888';

if ($contact_info =~ /(?<phone>$phone_number)/) {
    say "Found a number $+{phone}";
}
```

## 7.6 非具名捕获

非具名捕获的格式如下：

```perl
(...)
```

我们可以通过数字来引用被捕获的部分，比如`$1`、`$2`等。编号由什么决定？由`(`出现的顺序决定，即第一个`(`出现的分区用`$1`，第二个用`$2`，以此类推

```perl
use strict;
use warnings;
use Modern::Perl;

my $phone_number = qr/[0-9]{8}/;
my $contact_info = 'CN-88888888';

if ($contact_info =~ /($phone_number)/) {
    say "Found a number $1";
}
```

此外，在列表上下文中，`Perl`会按照捕获组的顺序，依次给列表中的变量赋值

```perl
use strict;
use warnings;
use Modern::Perl;

my $country = qr/[a-zA-Z]+/;
my $phone_number = qr/[0-9]{8}/;
my $contact_info = 'CN-88888888';

if (my ($c, $p) = $contact_info =~ /($country)-($phone_number)/) {
    say "$c: $p";
}
```

## 7.7 交替

交替元字符（`Alternation Metacharacter`）`|`，表示前面的任何一个片段都可能匹配

```perl
use strict;
use warnings;
use Modern::Perl;
use Test::More tests => 3;

my $r = qr/^rice|beans$/;

like('rice', $r, 'Match rice');
like('beans', $r, 'Match beans');
like('ricbeans', $r, 'Match weird hybrid');
```

注意到，`rice|beans`也可以表示`ric + e|b + eans`。为了避免混淆，可以加上括号

```perl
use strict;
use warnings;
use Modern::Perl;
use Test::More tests => 3;

my $r = qr/^(rice|beans)$/;

like('rice', $r, 'Match rice');
like('beans', $r, 'Match beans');
unlike('ricbeans', $r, 'Unmatch weird hybrid');
```

或者，使用`(?:...)`，如下：

```perl
use strict;
use warnings;
use Modern::Perl;
use Test::More tests => 3;

my $r = qr/^(?:rice|beans)$/;

like('rice', $r, 'Match rice');
like('beans', $r, 'Match beans');
unlike('ricbeans', $r, 'Unmatch weird hybrid');
```

## 7.8 断言

断言都是零长度的，它不消耗匹配字符串中的字符，仅表示一些位置信息

* `\A`：整个匹配串的起始位置
* `\Z`：整个匹配串的结束位置
* `^`：行的起始位置
* `$`：行的结束位置
* `\b`：它的前一个字符和后一个字符不全是(一个是，一个不是或不存在)`\w`
* `\B`：它的前一个字符和后一个字符不全是(一个是，一个不是或不存在)`\W`
* `(?!...)`：表示前面的模式后面不能紧跟`...`表示的模式。`zero-width negative look-ahead assertion`
* `(?=...)`：表示前面的模式后面必须紧跟`...`表示的模式。`zero-width positive look-ahead assertion`
* `(?<!...)`：表示后面的模式，其前面不能紧跟`...`表示的模式。`zero-width negative look-behind assertion`
* `(?<=...)`：表示后面的模式，其前面必须紧跟`...`表示的模式。`zero-width positive look-behind assertion`

```perl
use strict;
use warnings;
use Modern::Perl;
use Test::More tests => 6;

my $r1 = qr/\Aabcd\Z/;
my $r2 = qr/some(?!thing)/;
my $r3 = qr/some(?=thing)/;
my $r4 = qr/(?<!some)thing/;
my $r5 = qr/(?<=some)thing/;

like('abcd', $r1, 'exactly abcd');
unlike('abcde', $r1, 'not exactly abcd');
unlike('something', $r2, 'some is immediately followed by thing');
like('something', $r3, 'some is immediately followed by thing');
unlike('something', $r4, 'some is immediately before thing');
like('something', $r5, 'some is immediately before thing');
```

## 7.9 循环匹配

`\G`用于表示最近一次匹配的位置，一般用于循环处理一个长文本，每次处理一小块（下面这个例子，不加`\G`效果也一样）

* `g`表示记录本次匹配后，字符串的位置
* `\G`表示从上次匹配后记录的字符串的位置开始

```perl
use strict;
use warnings;
use Modern::Perl;

my $contents = '
010-99991111
0571-88888888
021-11117789
';

while ($contents =~ /\G.*?(\d{3, 4})-(\d{8}).*?/gs) {
    say "area num: $1, number: $2";
}
```

# 8 作用域

`Perl`中的所有符号都存在作用域（`Scope`）

## 8.1 词法作用域

什么是词法作用域（`Lexical Scope`），由大括号`{}`包围的范围就是一个词法作用域。可以是一个普通的`{}`；可以是一个循环语句；可以是函数定义；`given`语句；可以是其他语法构成的`{}`

```perl
# outer lexical scope
{
    package My::Class;
    my $outer;
    sub awesome_method {
        my $inner;
        do {
            my $do_scope;
            ...
        } while (@_);
        # sibling inner lexical scope
        for (@_) {
            my $for_scope;
            ...
        }
    }
}
```

## 8.2 包作用域

每个包都有一个符号表，该符号表中包含了所有包作用域下的变量。我们可以检查和修改该符号表，这就是导入（`importing`）的工作原理，也是只有全局变量或者包全局变量能够本地化（`local`）的原因

## 8.3 动态作用域

我们可以通过`local`来调整全局变量（或者包全局变量）的作用域，在当前作用域内修改该全局变量的值，不会影响在当前作用域之外的该全局变量的值。通常在处理一些特殊变量时，比较有用

```perl
use strict;
use warnings;
use Modern::Perl;

{
    our $scope;
    sub inner {
        say $scope;
    }
    sub main {
        say $scope;
        local $scope = 'main() scope';
        middle();
    }
    sub middle {
        say $scope;
        inner();
    }
    $scope = 'outer scope';
    main();
    say $scope;
}
```

## 8.4 静态作用域

我们可以通过`state`来创建具有静态作用域的变量，该变量的生命周期延长至整个程序，但是该变量的可见性依然没有变

```perl
use strict;
use warnings;
use Modern::Perl;

sub counter {
    state $count = 1;
    return $count++;
}

say counter();
say counter();
say counter();
```

# 9 包和模块

## 9.1 包

`Perl`中每个包（`Package`）有一个单独的符号表，定义语法为：

```perl
package mypack;
```

此语句定义一个名为`mypack`的包，在此后定义的所有变量和函数的名字都存贮在该包关联的符号表中，直到遇到另一个`package`语句为止

每个符号表有其自己的一组变量、函数名，各组名字是不相关的，因此可以在不同的包中使用相同的变量名，而代表的是不同的变量。

从一个包中访问另外一个包的变量，可通过`package_name::variable_name`的方式指定

存贮变量和函数的名字的默认符号表是与名为`main`的包相关联的。如果在程序里定义了其它的包，当你想切换回去使用默认的符号表，可以重新指定`main`包

每个包包含三个默认的函数：

1. `VERSION()`
1. `import()`
1. `unimport()`

### 9.1.1 UNIVERSAL

`Perl`提供了一个特殊的包，叫做`UNIVERSAL`，它是所有包的祖先，提供了一些方法，包括

* `isa()`：类方法，用于判断是否继承自某个类
* `can()`：类方法，用于判断是否包含某个方法
* `VERSION()`：类方法，返回包的版本。该方法还能传入一个版本参数，若版本小于该参数，则会抛异常
* ` DOES()`：类方法，用于判断是否扮演了某个角色

## 9.2 模块

`Perl5`中用`Perl`包来创建模块。

`Perl`模块是一个可重复使用的包，模块的名字与包名相同，定义的文件后缀为`.pm`

`Perl`中关于模块需要注意以下几点：

* 函数`require`和`use`将载入一个模块
* `@INC`是`Perl`内置的一个特殊数组，它包含指向库例程所在位置的目录路径。
* `require`和`use`函数调用`eval`函数来执行代码
* 末尾`1;`执行返回`TRUE`，这是必须的，否则返回错误

**`use`和`require`的区别：**

1. `require`用于载入`module`或`perl`程序（`.pm`后缀可以省略，但`.pl`必须有）
1. `use`语句是编译时引入，`require`是运行时引入
1. `use`引入模块的同时，也引入了模块的子模块。而`require`则不能引入子模块
1. `use`是在当前默认的`@INC`里面去寻找，一旦模块不在`@INC`中的话,用`use`是不可以引入的，但是`require`可以指定路径
1. `use`引用模块时，如果模块名称中包含`::`双冒号，该双冒号将作为路径分隔符，相当于`Unix`下的`/`或者`Windows`下的`\`

### 9.2.1 导入

当使用`use`加载模块时，`Perl`会自动调用该模块的`import()`函数，模块中的接口可以提供自己的`import()`方法来向外部导出符号

模块后跟的名字都会作为`import()`方法的参数，例如

```perl
use strict 'refs';
use strict qw( subs vars );
```

上面这两句等价于

```perl
BEGIN {
    require strict;
    strict->import( 'refs' );
    strict->import( qw( subs vars ) );
}
```

`no`函数会调用模块的`unimport`方法

# 10 面向对象

`Perl 5`中用`package`来为类提供命名空间。（`Moose`模块可以用`cpan Moose`来安装）

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Cat;
    use Moose;
}

my $brad = Cat->new();
my $jack = Cat->new();
```

这里，箭头运算符`->`用于调用类或对象的方法

## 10.1 方法

1. 方法的调用总是有一个`invocant`，该方法在该`invocant`上运行。方法调用者可以是类名，也可以是类的一个实例
1. `invocant`会作为方法的第一个参数。这里存在一个普遍的约定，就是会将该参数保存到`$self`变量中
1. 方法调用会涉及到分发策略，就是决定调用方法的哪一个具体的实现（多态）

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Cat;
    use Moose;
    sub meow {
        my $self = shift;
        say 'Meow!';
    }
}

my $alarm = Cat->new();
$alarm->meow();
$alarm->meow();
$alarm->meow();

Cat->meow() for 1 .. 3;
```

## 10.2 属性

我们通过`has`来定义属性（`perldoc Moose`），其中

* `is`：声明属性的读写属性，即是否可读，是否可写
    * `ro`：表示只读
    * `rw`：表示读写
* `isa`：声明属性的类型
* `writer`：提供私有的，类内部使用的写入器
* **特别地，该行定义会根据读写属性创建相应的访问属性的方法和修改属性的方法。比如下面这个例子，就会创建一个访问属性的方法`name()`，且允许在构造函数里传入一个`name`参数用于初始化该属性**

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Cat;
    use Moose;
    has 'name' => (is => 'ro', isa => 'Str');
}

for my $name (qw( Tuxie Petunia Daisy )) {
    my $cat = Cat->new( name => $name );
    say "Created a cat for ", $cat->name();
}
```

此外，`has`还可以有多种不同的书写方式：

```perl
has 'name', is => 'ro', isa => 'Str';
has( 'name', 'is', 'ro', 'isa', 'Str' );
has( qw( name is ro isa Str ) );
has 'name' => (
    is => 'ro',
    isa => 'Str',
    # advanced Moose options; perldoc Moose
    init_arg => undef,
    lazy_build => 1,
);
```

### 10.2.1 属性默认值

通过`default`关键词，可以将一个函数引用关联到属性上，当构造函数未提供该属性的初始值时，会通过该函数应用来创建初始值

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Cat;
    use Moose;
    has 'name' => (is => 'ro', isa => 'Str');
    has 'diet' => (is => 'rw', isa => 'Str');
    has 'birth_year' => (is => 'ro', isa => 'Int', default => sub { (localtime)[5] + 1900 });
}

my $cat = Cat->new( name => "Tuxie", diet => "Junk Food");
say $cat->birth_year();
```

## 10.3 多态

多态（`polymorphism`）是`OOP`中的一个重要属性。在`Perl`中，只要两个对象提供了相同的外部接口，就可以将一个类的对象替换为另一个类的对象。某些语言（比如Java/C++）可能会要求额外的信息，比如类的继承关系，接口的实现关系等等，然后才允许多态发生

## 10.4 角色

角色（`Role`）是一组行为和状态的具名集合。一个类就是一个角色，类和角色之间的重要区别就是，类可以实例化成对象，而角色不行（感觉，角色这个概念，就类似于其他语言中的接口）

* `requires`关键词声明角色需要包含哪些方法
* `with`关键词声明类扮演了哪些角色。通常`with`会写在属性定义后面，这样`Moose`为属性生成的访问方法或者修改方法也可以作为扮演角色所必须实现的方法
* `DOES`用于检查实例是否扮演了某个角色

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package LivingBeing;
    use Moose::Role;
    requires qw( name age diet );
}

{
    package Cat;
    use Moose;
    has 'name' => (is => 'ro', isa => 'Str');
    has 'diet' => (is => 'rw', isa => 'Str');
    has 'birth_year' => (is => 'ro', isa => 'Int', default => (localtime)[5] + 1900);
    
    with 'LivingBeing';

    sub age {
        my $self = shift;
        my $year = (localtime)[5] + 1900;
        return $year - $self->birth_year();
    }
}

my $fluffy = Cat->new( name => "Fluffy", diet => "Junk Food");
my $cheese = Cat->new( name => "Cheese", diet => "Junk Food");

say 'Alive!' if $fluffy->DOES('LivingBeing');
say 'Moldy!' if $cheese->DOES('LivingBeing');
```

此外，我们还可以将公共的部分抽取出来放到一个角色中，进一步复用代码

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package LivingBeing;
    use Moose::Role;
    requires qw( name age diet );
}

{
    package CalculateAge::From::BirthYear;
    use Moose::Role;
    has 'birth_year' => (is => 'ro', isa => 'Int', default => sub { (localtime)[5] + 1900 });
    sub age {
        my $self = shift;
        my $year = (localtime)[5] + 1900;
        return $year - $self->birth_year();
    }
}

{
    package Cat;
    use Moose;
    has 'name' => (is => 'ro', isa => 'Str');
    has 'diet' => (is => 'rw', isa => 'Str');
    
    with 'LivingBeing', 'CalculateAge::From::BirthYear';
}

my $fluffy = Cat->new( name => "Fluffy", diet => "Junk Food");
my $cheese = Cat->new( name => "Cheese", diet => "Junk Food");

say 'Alive!' if $fluffy->DOES('LivingBeing');
say 'Moldy!' if $cheese->DOES('LivingBeing');
```

可以看到，我们将通过`birth_year`计算`age`的这部分代码单独移到了角色`CalculateAge::From::BirthYear`中，且`Cat`继承了该角色的`age`方法，且正好满足`LivingBeing`的要求（提供`age`方法）。`Cat`可以选择自己提供`age`方法或者从其他`Role`中直接继承，只要有就可以，这就叫做同构（`Allomorphism`）

## 10.5 继承

`Perl 5`提供的另一个特性就是继承（`Inheritance`）。继承在两个类之间建立关联，子类可以继承父类的属性和方法以及角色。**事实上，实践表明，我们可以在所有需要继承的地方将其替换为角色，因为角色具有更好的安全性、类型检查、更少的代码耦合**

* `extends`关键词来声明继承的父类列表
* `has '+candle_power', default => 100;`中的`+`表示显式覆盖父类中的属性
* `override`关键词用于显式声明方法重写，并且提供调用父类方法的方式，即`super()`
* `isa`用于检查实例是否继承自某个类

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package LightSource;
    use Moose;
    has 'candle_power' => (is => 'ro', isa => 'Int', default => 1);
    has 'enabled' => (is => 'ro', isa => 'Bool', default => 0, writer => '_set_enabled');
    sub light {
        my $self = shift;
        $self->_set_enabled(1);
    }
    sub extinguish {
        my $self = shift;
        $self->_set_enabled(0);
    }
}

{
    package LightSource::SuperCandle;
    use Moose;
    extends 'LightSource';
    has '+candle_power' => (default => 100);
}

{
    package LightSource::Glowstick;
    use Moose;
    extends 'LightSource';
    sub extinguish {}
}

{
    package LightSource::Cranky;
    use Carp;
    use Moose;
    extends 'LightSource';
    override light => sub {
        my $self = shift;
        Carp::carp( "Can't light a lit light source!" ) if $self->enabled;
        super();
    };
    override extinguish => sub {
        my $self = shift;
        Carp::carp( "Can't extinguish an unlit light source!" ) unless $self->enabled;
        super();
    };
}

my $sconce = LightSource::Glowstick->new();
say 'Looks like a LightSource' if $sconce->isa( 'LightSource' );
```

当有多个父类都提供了同一个方法时，`Perl`的分派策略（`perldoc mro`）：查找第一个父类（递归查找父类的父类）的方法，再查找第二个父类，直到找到方法

## 10.6 原生OOP

**上面介绍的都是基于`Moose`的`OOP`，下面再介绍一下`Perl 5`原生的`OOP`**

`Perl`中有两种不同地面向对象编程的实现：

1. 一是基于匿名哈希表的方式，每个对象实例的实质就是一个指向匿名哈希表的引用。在这个匿名哈希表中，存储来所有的实例属性
1. 二是基于数组的方式，在定义一个类的时候，我们将为每一个实例属性创建一个数组，而每一个对象实例的实质就是一个指向这些数组中某一行索引的引用。在这些数组中，存储着所有的实例属性

### 10.6.1 基本概念

面向对象有很多基础概念，最核心的就是下面三个：

* 对象：对象是对类中数据项的引用
* 类：类是个`Perl`包，其中含提供对象方法的类（`Perl`对类和包没有明确的区分）
* 方法：方法是个`Perl`子程序，类名是其第一个参数。

`Perl`提供了`bless()`函数，`bless`是用来构造对象的，通过`bless`把一个引用和这个类名相关联，返回这个引用就构造出一个对象

### 10.6.2 类的定义

1. 一个类只是一个简单的包
1. 可以把一个包当作一个类用，并且把包里的函数当作类的方法来用
1. `Perl`的包提供了独立的命名空间，所以不同包的方法与变量名不会冲突
1. `Perl`类的文件后缀为`.pm`

### 10.6.3 创建和使用对象

1. 创建一个类的实例 (对象) 我们需要定义一个构造函数，大多数程序使用类名作为构造函数，`Perl`中可以使用任何名字，通常来说，用`new`（这个`new`不是关键词，而是个普通的函数名）
1. 你可以使用多种`Perl`的变量作为`Perl`的对象。大多数情况下我们会使用数组或哈希的引用

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Person;
    sub new {
        my $class = shift;
        my $self = {
            _firstName => shift,
            _lastName  => shift,
            _ssn       => shift,
        };

        say "First name: $self->{_firstName}";
        say "Last name: $self->{_lastName}";
        say "Num: $self->{_ssn}";
        bless $self, $class;
        return $self;
    }
}

my $object = new Person( "Bruce", "Lee", 23234345);
```

### 10.6.4 定义方法

1. `Perl`类的方法只但是是个`Perl`子程序而已，也即通常所说的成员函数
1. `Perl`面向对象中`Perl`的方法定义不提供任何特别语法，但规定方法的第一个参数为对象或其被引用的包
1. `Perl`没有提供私有变量，但我们可以通过辅助的方式来管理对象数据

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Person;
    sub new {
        my $class = shift;
        my $self = {
            _firstName => shift,
            _lastName  => shift,
            _ssn       => shift,
        };

        say "First name: $self->{_firstName}";
        say "Last name: $self->{_lastName}";
        say "Num: $self->{_ssn}";
        bless $self, $class;
        return $self;
    }

    sub setFirstName {
        my ( $self, $firstName ) = @_;
        $self->{_firstName} = $firstName if defined($firstName);
        return $self->{_firstName};
    }

    sub getFirstName {
        my( $self ) = @_;
        return $self->{_firstName};
    }
}

my $object = new Person( "Bruce", "Lee", 23234345);
my $firstName = $object->getFirstName();
say "firstName: $firstName";

$object->setFirstName("John");

$firstName = $object->getFirstName();
say "firstName: $firstName";
```

### 10.6.5 继承

1. `Perl`里类方法通过`@ISA`数组继承，这个数组里面包含其他包（类）的名字，变量的继承必须明确设定
1. 多继承就是这个`@ISA`数组包含多个类（包）名字
1. 通过`@ISA`能继承方法和数据

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Person;
    sub new {
        my $class = shift;
        my $self = {
            _firstName => shift,
            _lastName  => shift,
            _ssn       => shift,
        };

        say "First name: $self->{_firstName}";
        say "Last name: $self->{_lastName}";
        say "Num: $self->{_ssn}";
        bless $self, $class;
        return $self;
    }

    sub setFirstName {
        my ( $self, $firstName ) = @_;
        $self->{_firstName} = $firstName if defined($firstName);
        return $self->{_firstName};
    }

    sub getFirstName {
        my( $self ) = @_;
        return $self->{_firstName};
    }
}

{
    package Employee;
    our @ISA = qw(Person);
}

my $object = new Employee( "Bruce", "Lee", 23234345);
my $firstName = $object->getFirstName();
say "firstName: $firstName";

$object->setFirstName("John");

$firstName = $object->getFirstName();
say "firstName: $firstName";
```

### 10.6.6 方法重写

```perl
use strict;
use warnings;
use Modern::Perl;

{
    package Person;
    sub new {
        my $class = shift;
        my $self = {
            _firstName => shift,
            _lastName  => shift,
            _ssn       => shift,
        };

        say "First name: $self->{_firstName}";
        say "Last name: $self->{_lastName}";
        say "Num: $self->{_ssn}";
        bless $self, $class;
        return $self;
    }

    sub setFirstName {
        my ( $self, $firstName ) = @_;
        $self->{_firstName} = $firstName if defined($firstName);
        return $self->{_firstName};
    }

    sub getFirstName {
        my( $self ) = @_;
        return $self->{_firstName};
    }
}

{
    package Employee;
    our @ISA = qw(Person);

    sub new {
        my ($class) = @_;

        my $self = $class->SUPER::new( $_[1], $_[2], $_[3] );

        $self->{_id}   = undef;
        $self->{_title} = undef;
        bless $self, $class;
        return $self;
    }

    sub getFirstName {
        my( $self ) = @_;
        say "Employee::getFirstName";
        return $self->{_firstName};
    }

    sub setLastName {
        my ( $self, $lastName ) = @_;
        $self->{_lastName} = $lastName if defined($lastName);
        return $self->{_lastName};
    }

    sub getLastName {
        my( $self ) = @_;
        return $self->{_lastName};
    }
}

my $object = new Employee( "Bruce", "Lee", 23234345);
my $firstName = $object->getFirstName();
say "firstName: $firstName";

$object->setFirstName("John");

$firstName = $object->getFirstName();
say "firstName: $firstName";

my $lastName = $object->getLastName();
say "lastName: $lastName";

$object->setLastName("Chen");

$lastName = $object->getLastName();
say "lastName: $lastName";
```

### 10.6.7 默认载入

1. 如果在当前类、当前类所有的基类、还有`UNIVERSAL`类中都找不到请求的方法，这时会再次查找名为`AUTOLOAD()`的一个方法。如果找到了`AUTOLOAD`，那么就会调用，同时设定全局变量`$AUTOLOAD`的值为缺失的方法的全限定名称
1. 如果还不行，那么`Perl`就宣告失败并出错

如果你不想继承基类的`AUTOLOAD`，很简单，只需要一句：

```perl
sub AUTOLOAD;
```

### 10.6.8 析构函数及垃圾回收

1. 当对象的最后一个引用释放时，对象会自动析构
1. 如果你想在析构的时候做些什么，那么你可以在类中定义一个名为`DESTROY`的方法。它将在适合的时机自动调用，并且按照你的意思执行额外的清理动作
1. `Perl`会把对象的引用作为 唯一的参数传递给`DESTROY`。注意这个引用是只读的，也就是说你不能通过访问`$_[0]`来修改它。但是对象自身（比如`${$_[0]`或者`@{$_[0]}`还有`%{$_[0]}`等等）还是可写的
1. 如果你在析构器返回之前重新`bless`了对象引用，那么`Perl`会在析构器返回之后接着调用你重新`bless`的那个对象的`DESTROY`方法
1. 在当前对象释放后，包含在当前对象中的其它对象会自动释放

```perl
package MyClass;
...
sub DESTROY {
    print "MyClass::DESTROY called\n";
}
```

# 11 格式化输出

1. `Perl`是一个非常强大的文本数据处理语言
1. `Perl`中可以使用`format`来定义一个模板，然后使用`write`按指定模板输出数据

`Perl`格式化定义语法格式如下

```perl
format FormatName =
fieldline
value_one, value_two, value_three
fieldline
value_one, value_two
.
```

参数解析：

* `FormatName`：格式化名称
* `fieldline`：格式行，用来定义一个输出行的格式，类似`@`、`^`、`|`这样的字符
* `value_one`、`value_two`、`...` ：数据行，用来向前面的格式行中插入值，都是`Perl`的变量。
* `.`：结束符号

```perl
use strict;
use warnings;
use Modern::Perl;

my $text = "google youj taobao";
format STDOUT =
# left align, length is 6
first: ^<<<<<
    $text
# left align, length is 6
second: ^<<<<<
    $text
# left align, length is 5
third: ^<<<<
    $text  
.
write
```

## 11.1 格式行

**[格式行中涉及的符号](https://perldoc.perl.org/perlform)：**

* 普通字符：格式行中也可以包含普通字符，包括空格等
* `@`：格式串的起始符号。并不意味着是格式行的起始符号，该符号前也可以有普通字符
* `^`：格式串的起始符号。并不意味着是格式行的起始符号，该符号前也可以有普通字符
* `<`：左对齐
* `|`：居中对齐
* `>`：右对齐
* `#`：数字字段中的有效位数
    * 整数部分，不足会在前面补空格
    * 小数部分，不足会在后面补`0`
* `.`：数字字段中的小数点
* `@*`：整个多行文本
* `^*`：多行文本的下一行
* `~`：禁止所有字段为空的行
* `~~`：重复行，直到所有字段都用完，放最前最后都可以。放最前面的话，`~~`同时还起到两个空格的作用，若要顶格输出，那么将`~~`放到最后即可

```perl
use strict;
use warnings;
use Modern::Perl;

my $text = "line 1\nline 2\nline 3";

format MUTI_LINE_1 =
Text: @*
$text
.
$~ = "MUTI_LINE_1";
write;

format MUTI_LINE_2 =
Text: ^*
$text
~~    ^*
$text
.
$~ = "MUTI_LINE_2";
write;

# reset text
$text = "line 1\nline 2\nline 3";
format MUTI_LINE_3 =
Text: ^*
$text
^*~~
$text
.
$~ = "MUTI_LINE_3";
write;
```

```perl
use strict;
use warnings;
use Modern::Perl;

my @nums = (1, 123.456, 0.78999);
format STDOUT = 
@##
$nums[0]
@###.####
$nums[1]
@.###
$nums[2]
.
write
```

## 11.2 格式变量

* `$~`：格式名称，默认是`STDOUT`
* `$^`：每页的页头格式，默认是`STDOUT_TOP`
* `$%`：当前页号
* `$=`：当前页中的行号
* `$|`：是否自动刷新输出缓冲区存储
* `$^L`

```perl
format EMPLOYEE =
===================================
@<<<<<<<<<<<<<<<<<<<<<< @<< 
$name, $age
@#####.##
$salary
===================================
.

# add paging $% 
format EMPLOYEE_TOP =
===================================
Name                    Age Page @<
                                 $%
=================================== 
.

select(STDOUT);
$~ = EMPLOYEE;
$^ = EMPLOYEE_TOP;

@n = ("Ali", "W3CSchool", "Jaffer");
@a = (20,30, 40);
@s = (2000.00, 2500.00, 4000.000);

$i = 0;
foreach (@n) {
   $name = $_;
   $age = $a[$i];
   $salary = $s[$i++];
   write;
}
```

## 11.3 输出到其他文件

默认情况下函数`write`将结果输出到标准输出文件`STDOUT`，我们也可以使它将结果输出到任意其它的文件中。最简单的方法就是把文件变量作为参数传递给`write`。例如，`write(MYFILE);`，`write`就用缺省的名为`MYFILE`的打印格式输出到文件`MYFILE`中。但是这样就不能用`$~`变量来改变所使用的打印格式，因为系统变量`$~`只对默认文件变量起作用

```perl
use strict;
use warnings;
use Modern::Perl;

if (open(MYFILE, ">tmp")) {
    $~ = "MYFORMAT";
    write MYFILE;

    format MYFILE =
=================================
      输入到文件中
=================================
.
    close MYFILE;
}
```

我们可以使用`select`改变默认文件变量时，它返回当前默认文件变量的内部表示，这样我们就可以创建函数，按自己的想法输出，又不影响程序的其它部分

```perl
use strict;
use warnings;
use Modern::Perl;

if (open(MYFILE, ">>tmp")) {
    select (MYFILE);
    $~ = "OTHER";
    write;

    format OTHER =
=================================
  使用定义的格式输入到文件中
=================================
. 
    close MYFILE;
}
```

# 12 文件

`Perl 5`包含三个标准的文件句柄（文件句柄表示一个用于输入或者输出的通道）

1. `STDIN`：标准输入
1. `STDOUT`：标准输出
1. `STDERR`：标准错误

## 12.1 读文件

默认情况下，`say`或者`print`会将内容输出到`STDOUT`中，`warn`会将内容输出到`STDERR`中

我们可以通过`open`打开一个外部文件

* 第一个参数：文件描述符
* 第二个参数：读写方式
    * `<`：读
    * `>`：覆盖写
    * `>>`：追加写
    * `+<`：读写

从文件中迭代读取内容的经典`while`循环如下：

```perl
use autodie;

open my $fh, '<', $file;
while (<$fh>) {
    ...
}
```

`Perl`在解析上面这段代码时，等效于处理下面这段逻辑。如果没有这个隐式的`defined`，那么碰到空行就会结束循环了（空行在布尔上下文中会转换成`false`）。在迭代到文件尾时，会返回`undef`

```
while (defined($_ = <$fh>)) {
    ...
}
```

特别地，`<>`表示空文件句柄，`Perl`默认会将`@ARGV`中存储的内容作为文件名进行依次读取，如果`@ARGV`为空，那么会读取标准输入

```
while (<>) {
    ...
}
```

### 12.1.1 一次性读取全部内容

特殊变量`$/`表示行分隔符。在不同平台中，行分隔符可能是`\n`、`\r`或者`\r\n`等等。默认情况下，`<filehandler>`每次读取一行

我们可以将`$/`设置为`undef`，这样一来，我们就能一次性读取到整行内容

```perl
use strict;
use warnings;
use Modern::Perl;

open my $fh, '<', 'data.txt' or die;
undef $/;
my $content = <$fh>;
say $content;
```

由于`$/`是全局变量，上述写法可能会造成一些干扰，我们可以采用如下写法

```perl
use strict;
use warnings;
use Modern::Perl;

open my $fh, '<', 'data.txt' or die;
my $content = do { local $/; <$fh>; };
say $content;
```

或者下面这种写法。该写法稍具迷惑性，由于`localization`优先于文件读取，`local $/ = <$fh>;`这个语句的顺序是：

1. `localization $/`
1. 读取文件内容，由于此时`$/`是`undef`，因此会读取全部内容
1. 将文件内容赋值给`$/`

```perl
use strict;
use warnings;
use Modern::Perl;

open my $fh, '<', 'data.txt' or die;
my $content = do { local $/ = <$fh>; };
say $content;
```

## 12.2 写文件

1. `$out_fh`和要输出的内容之间没有逗号
1. 若指定的文件描述符是个复杂的表达式，要用`{}`来消除歧义，否则解释器会把`$config`当成文件描述符

```perl
use strict;
use warnings;
use Modern::Perl;

open my $out_fh, '>', 'output_file.txt';
print $out_fh "Here's a line of text\n";
say $out_fh "... and here's another";
my $config = {
    output => $out_fh
};
say {$config->{output}} "... and here's another2";

close $out_fh;
```

默认情况下，`Perl`会将内容先缓存起来，直到超过缓存大小时，才会将其真正写入到磁盘。我们可以通过修改`$|`来实现实时刷新，或者直接调用`autoflush`方法

```perl
use strict;
use warnings;
use Modern::Perl;
use FileHandle;

open my $fh, '>', 'pecan.log';
$fh->autoflush( 1 );
```

## 12.3 目录

1. `opendir`函数用于获取指定目录的句柄
1. `readdir`函数用于读取目录下的文件或者子目录
1. `closedir`函数用于关闭目录句柄

```perl
use strict;
use warnings;
use Modern::Perl;

# iteration
opendir my $dirh, '.';
while (my $file = readdir $dirh) {
    say "filename: $file";
}
closedir $dirh;

# flattening into a list
opendir my $otherdirh, '.';
my @files = readdir $otherdirh;
say "files: @files";
closedir $otherdirh;
```

## 12.4 文件运算符

1. `-e`：判断文件或目录是否存在
1. `-f`：判断是否为文件
1. `-d`：判断是否为目录
1. `-r`：判断当前用户对该文件是否有读权限
1. `-w`：判断当前用户对该文件是否有写权限
1. `-z`：判断是否为空文件

```perl
use strict;
use warnings;
use Modern::Perl;

my $filename = "notexist";
say 'Present!' if -e $filename;
```

## 12.5 其他文件操作

1. `rename`：用于重命名
1. `chdir`：用于切换当前工作目录
1. `File::Copy`：文件拷贝和移动

# 13 常用库

## 13.1 Test

`Test::More`提供了测试相关的能力

* `tests`可选参数，用于指定测试的数量
* `ok`：断言，布尔上下文
* `is`：断言，标量上下文，用`eq`判断两个参数是否相同
* `isnt`：断言，与`is`含义相反
* `cmp_ok`：断言，用于指定操作符来判断两个参数是否相同
* `isa_ok`：断言，类型判断
* `can_ok`：断言，判断是否包含指定的方法（或方法列表）
* `is_deeply`：断言，比较两个对象的内容是否相同

```perl
use strict;
use warnings;
use Modern::Perl;
use Test::More tests => 7;

ok( 1, 'the number one should be true' );
ok( ! 0, '... and the number zero should not' );
ok( ! '', 'the empty string should be false' );
ok( '!', '... and a non-empty string should not' );

is( 4, 2 + 2, 'addition should hold steady across the universe' );
isnt( 'pancake', 100, 'pancakes should have a delicious numeric value' );

{
    use Clone;
    my $numbers = [ 4, 8, 15, 16, 23, 42 ];
    my $clonenums = Clone::clone( $numbers );
    is_deeply( $numbers, $clonenums, 'Clone::clone() should produce identical structures' );
}

done_testing();
```

## 13.2 Carp

`Carp`用于输出告警信息，包括代码上下文等

```perl
use strict;
use warnings;
use Modern::Perl;
use Carp;

sub only_two_arguments {
    my ($lop, $rop) = @_;
    Carp::carp( 'Too many arguments provided' ) if @_ > 2;
}

my ($first, $second, $third) = (1, 2, 3);
only_two_arguments($first, $second, $third);
```

## 13.3 Path

`Path::Class`提供了跨平台的路径操作方式（不必关系路径分隔符是`/`还是`\`诸如此类的问题）

```perl
use strict;
use warnings;
use Modern::Perl;
use Path::Class;

my $dir  = dir('foo', 'bar');       # Path::Class::Dir object
my $file = file('bob', 'file.txt'); # Path::Class::File object

say "dir: $dir";
say "file: $file";

my $subdir  = $dir->subdir('baz');  # foo/bar/baz
my $parent  = $subdir->parent;      # foo/bar
my $parent2 = $parent->parent;      # foo

say "subdir: $subdir";
say "parent: $parent";
say "parent2: $parent2";
```

## 13.4 Cwd

`Cwd`主要用于计算真实路径，例如`/tmp/././a`就返回`/tmp/a`。详细用法参考`perldoc Cwd`

```perl
use strict;
use warnings;
use Modern::Perl;
use Cwd;

say "abs path of '/tmp/a/b/..':", Cwd::abs_path("/tmp/a/b/..");
```

## 13.5 File

详细用法参考`perldoc File::Spec`、`perldoc File::Basename`

```perl
use strict;
use warnings;
use Modern::Perl;
use File::Spec;
use File::Basename;

my $path = File::Spec->rel2abs(__FILE__);
my ($vol, $dir, $file) = File::Spec->splitpath($path);

say "path: $path";
say "vol: $vol";
say "dir: $dir";
say "file: $file";

my $rel_dir = dirname(__FILE__);
say "rel_dir: $rel_dir";
```

## 13.6 Time

`Perl`提供了`localtime`函数用于获取时间信息

```perl
use strict;
use warnings;
use Modern::Perl;

my @months = qw( 一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月 );
my @days = qw(星期天 星期一 星期二 星期三 星期四 星期五 星期六);

my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
say "$mday $months[$mon] $days[$wday]";
```

如果只想获取年份的话可以使用`Time`模块，详细请参考`perldoc Time::Piece`

```perl
use strict;
use warnings;
use Modern::Perl;
use Time::Piece;

my $now = Time::Piece->new();
say "year:", $now->year;
say "mon:", $now->month;
say "day_of_month:", $now->day_of_month;
say "hour:", $now->hour;
say "minute:", $now->minute;
say "second:", $now->second;
```

# 14 高级特性

## 14.1 属性

具名实体，包括变量以及函数都可以拥有属性，语法如下

```perl
my $fortress :hidden;
sub erupt_volcano :ScienceProject { ... }
```

上述定义会触发名为`hidden`以及`ScienceProject`的属性处理过程（` Attribute Handlers`)。如果对应的`Handler`不存在，则会报错

属性可以包含一系列参数，`Perl`会将其视为一组常量字符串

**大部分时候，你不需要使用属性**

# 15 Builtin

参考[perlfunc](https://perldoc.perl.org/perlfunc)。此外可以通过`perldoc perlfunc`查看

1. `say`：将给定字符串（默认为`$_`）输出到当前`select`的文件句柄中
1. `chomp`：删除给定字符串（默认为`$_`）中尾部的换行符
1. `defined`：判断给定变量是否已定义（是否赋值过）
1. `use`：引入包
1. `our`：为`package`变量创建别名
1. `my`：声明局部变量
1. `state`：声明静态变量
1. `map`：映射
1. `grep`：过滤
1. `sort`：排序
1. `scalar`：显式声明标量上下文

# 16 进阶

[modern-perl.pdf](/resources/book/modern-perl.pdf)

**语言设计哲学：**

1. `TIMTOWTDI`：There’s more than one way to do it!

**工具：**

1. `perldoc`
    * `perldoc perltoc`：文档内容表
    * `perldoc perlsyn`：语法
    * `perldoc perlop`：运算符
    * `perldoc perlfunc`：`builtin`函数
        * `perldoc -f wantarray`
    * `perldoc perlsub`：函数
    * `perldoc perlretut`：正则表达式教程
    * `perldoc perlre`：正则表达式详细文档
    * `perldoc perlreref`：正则表达式指导
    * `perldoc perlmod`
    * `perldoc perlvar`：预定义的全局变量
    * `perldoc List::Util`
    * `perldoc Moose::Manual`
    * `perldoc -D <keyword>`：搜索包含关键字的文档
    * `perldoc -v <variable>`
        * `perldoc -v $/`
1. `cpan`
    * `cpan Modern::Perl`
    * `cpan Moose`
1. `perlbrew`

**站点：**

* [homepage](https://www.perl.org)
* [dev](https://dev.perl.org)
* [cpan](https://www.cpan.org)
* [community-perlmonks](https://perlmonks.org)
* [blogs](https://blogs.perl.org)
* [bestpractical](https://bestpractical.com)

**一些概念：**

* `Bareword`：A bareword is an identifier without a sigil or other attached disambiguation as to its intended syntactical function.
* `prototype`：A prototype is a piece of optional metadata attached to a function declaration

**TODO：**

1. `map`
1. `To count the number of elements returned from an expression in list context without using a temporary variable, you use the idiom` - P21
1. `You do not need parentheses to create lists; the comma operator creates lists` - P22
1. `Lists and arrays are not interchangeable in Perl. Lists are values and arrays are containers.` - P22
1. `If you must use $_ rather than a named variable, make the topic variable lexical with my $_:` - P29
1. `Given/When` - P33
1. `Scalars may be lexical, package, or global (see Global Variables, page 153) variables.` - P35
1. `Reset a hash’s iterator with the use of keys or values in void context` - P43
1. `if your cached value evaluates to false in a boolean context, use the defined-or assignment operator (//=) instead` - P46
1. `Filehandle References` - P54
1. `Dualvars` - P48
1. `Aliasing` - P66
1. `use Carp 'cluck';` - P70
1. `AUTOLOAD` - P85
1. `Named Captures` - P94
1. `abc|def` 和 `(abc|def)`的差异
1. `use autodie;` - P167

# 17 Best Practice

## 17.1 文本处理

```perl
use warnings;
use strict;
use Modern::Perl;
use List::Util qw(min max sum);
use Data::Dumper;

my $fileName=shift or die "missing 'fileName'";
my $indexName=shift or die "missing 'indexName'";

open my $fh, "< $fileName" or die "$!";
my $indexNamePat0=qr/\b$indexName\b/;
my $indexNamePat1=qr/\b$indexName\b\s*:\s*(\d+(?:\.\d+)?)(ns|us|ms)/;
my $indexNamePat2=qr/\b$indexName\b\s*:\s*(\d+)s(\d+)ms/;
sub norm_time1($$){
    my ($n,$u)=@_;
    if ($u eq "ns") {
        return $n/1000000000.0;
    } elsif ($u eq "us") {
        return $n/1000000.0;
    } elsif ($u eq "ms") {
        return $n;
    } else {
        return $n*1000.0;
    }
}
sub norm_time2($$) {
    my ($sec, $ms)=@_;
    return $sec*1000.0+$ms;
}

my @lines0=map {chomp;$_} <$fh>;
my @lines=grep {/$indexNamePat0/} map {$_.":".$lines0[$_-1]} 1..scalar(@lines0);
my @norm_lines1=map {/$indexNamePat1/;[norm_time1($1, $2), $_]} grep {/$indexNamePat1/} @lines;
my @norm_lines2=map {/$indexNamePat2/;[norm_time2($1, $2), $_]} grep {/$indexNamePat2/} @lines;
my @norm_lines=(@norm_lines1, @norm_lines2);
my @sorted_lines = sort {$a->[0] <=> $b->[0]} @norm_lines;
for my $line (@sorted_lines) {
    printf "cost=%d, %s\n", $line->[0], $line->[1];
}
```

# 18 参考

* [w3cschool-perl](https://www.w3cschool.cn/perl/)
* [perl仓库-cpan](https://www.cpan.org/)
* [modern-perl.pdf](/resources/book/modern-perl.pdf)
* [Perl Tutorial](https://www.tutorialspoint.com/perl/perl_function_references.htm)
* [什么编程语言写脚本好？](https://www.zhihu.com/question/505203283/answer/2266164064)
* [Perl | qw Operator](https://www.geeksforgeeks.org/perl-qw-operator/?ref=lbp)
* [$_ the default variable of Perl](https://perlmaven.com/the-default-variable-of-perl)
