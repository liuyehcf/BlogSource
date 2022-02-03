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

# 无法解析
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

### 3.2.9 数组插值

数组插值`Array Interpolation`，在双引号中的数组，各个元素之间会插入全局变量`$"`，其默认值为空格

```perl
use strict;
use warnings;
use Modern::Perl;

my @alphabet = 'a' .. 'z';
say "[@alphabet]";

{
    local $" = ')(';
    say "[@alphabet]";
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
# 定义数组
@sites = qw(google taobao youj facebook);
print "网站: @sites\n";

# 设置数组的第一个索引为 1
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

### 3.2.14 Tips

1. 用`print`打印数组时，最好放在引号里面，否则输出的时候，数组各元素就直接贴在一起了。而放在引号里面的话，各元素之间会用空格分隔

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

# 添加元素
$data{'facebook'} = 'facebook.com';
@keys = keys %data;
$size = @keys;
say "key size: $size";

# 删除哈希中的元素
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
# 下面这句会报错
# $data{'wtf'} = 'wtf.com';

unlock_keys(%data);
$data{'wtf'} = 'wtf.com';

foreach my $key (keys %data) {
    my $value = $data{$key};
    say "$key : $value";
}
```

## 3.4 引用

引用就是指针，`Perl`引用是一个标量类型，可以指向变量、数组、哈希表（也叫关联数组）甚至函数，可以应用在程序的任何地方

### 3.4.1 创建引用

定义变量的时候，在变量名前面加个`\`，就得到了这个变量的一个引用

```perl
$scalarref = \$foo;     # 标量变量引用
$arrayref  = \@ARGV;    # 列表的引用
$hashref   = \%ENV;     # 哈希的引用
$coderef   = \&handler; # 子过程引用
$globref   = \*foo;     # GLOB句柄引用
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

my $var = 10;

# $r 引用 $var 标量
my $r = \$var;

# 输出本地存储的 $r 的变量值
say '$$r: ', $$r;

my @var = (1, 2, 3);
# $r 引用  @var 数组
$r = \@var;
# 输出本地存储的 $r 的变量值
say '@$r: ', @$r;
say '$$r[0]: ', $$r[0];
say '$r->[0]: ', $r->[0];
say '@{ $r }[0, 1, 2]: ', @{ $r }[0, 1, 2];

my %var = ('key1' => 10, 'key2' => 20);
# $r 引用  %var 数组
$r = \%var;
# 输出本地存储的 $r 的变量值
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

# 函数定义
sub PrintHash {
    my (%hash) = @_;
   
    foreach my $item (%hash) {
        say "元素 : $item";
    }
}
my %hash = ('name' => 'youj', 'age' => 3);

# 创建函数的引用
my $cref = \&PrintHash;

# 使用引用调用函数，方式1
&$cref(%hash);

# 使用引用调用函数，方式2
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

1. `my ($single_element) = find_chores();`：这里的`()`用于给解释器一个提示，虽然`single_element`是个标量，但是仍然要在列表上下文中进行处理。效果是将`find_chores()`返回的列表的第一个元素赋值给`single_element`
1. `my $numeric_x = 0 + $x;`：显式使用数字上下文
1. `my $stringy_x = '' . $x; # forces string context`：显式使用`string`上下文
1. `my $boolean_x = !!$x;`：显式使用布尔上下文

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

## 3.6 默认变量

### 3.6.1 默认标量变量

`$_`又称为默认标量变量（这是`Perl`标志性的特征）。可以用在非常多的地方，包括许多内建的函数

```perl
use strict;
use warnings;
use Modern::Perl;

$_ = 'My name is Paquito';

# say 默认输出 $_
say if /My name is/;

# 默认对 $_ 进行替换操作
s/Paquito/Paquita/;

# 默认对 $_ 进行大小写转换操作
tr/A-Z/a-z/;

# say 默认输出 $_
say;

# 默认的循环变量是 $_
say "#$_" for 1 .. 10;
```

### 3.6.2 默认数组变量

1. `Perl`将传给函数的参数都存储在`@_`变量中
1. `push`、`pop`、`shift`、`unshift`在缺省参数的情况下，默认都对`@_`进行操作
1. `Perl`将命令函参数都存储在`@ARGV`中
1. `@ARGV`还有另一个用途，当从空文件句柄`<>`中读取内容时，`Perl`默认会将`@ARGV`中存储的内容作为文件名进行依次读取，如果`@ARGV`为空，那么会读取标准输入

## 3.7 特殊变量

1. `$/`
1. `$!`
1. `$@`
1. `$|`

# 4 控制流

## 4.1 条件语句

### 4.1.1 if

```perl
if (boolean_expression) {
    # 在布尔表达式 boolean_expression 为 true 执行
}
```

### 4.1.2 if else

```perl
if (boolean_expression) {
    # 在布尔表达式 boolean_expression 为 true 执行
} else {
    # 在布尔表达式 boolean_expression 为 false 执行
}
```

### 4.1.3 if elsif

```perl
if (boolean_expression 1) {
    # 在布尔表达式 boolean_expression 1 为 true 执行
} elsif (boolean_expression 2) {
    # 在布尔表达式 boolean_expression 2 为 true 执行
} elsif (boolean_expression 3) {
    # 在布尔表达式 boolean_expression 3 为 true 执行
} else {
    # 布尔表达式的条件都为 false 时执行
}
```

### 4.1.4 unless

```perl
unless (boolean_expression) {
    # 在布尔表达式 boolean_expression 为 false 执行
}
```

### 4.1.5 unless else

```perl
unless (boolean_expression) {
    # 在布尔表达式 boolean_expression 为 false 执行
} else {
    # 在布尔表达式 boolean_expression 为 true 执行
}
```

### 4.1.6 unless elsif

```perl
unless (boolean_expression 1) {
    # 在布尔表达式 boolean_expression 1 为 false 执行
} elsif (boolean_expression 2) {
    # 在布尔表达式 boolean_expression 2 为 true 执行
} elsif (boolean_expression 3) {
    # 在布尔表达式 boolean_expression 3 为 true 执行
} else {
    #  没有条件匹配时执行
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
       # 跳出迭代
       $a = $a + 1;
       next;
    }
    say "a 的值为: $a";
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
       # 退出循环
       $a = $a + 1;
       last;
    }
    say "a 的值为: $a";
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
    say "a = $a";
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
    say "a = $a";
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
    say "a = $a";
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
       # 跳过迭代
       $a = $a + 1;
       # 使用 goto LABEL 形式
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
       # 跳过迭代
       $a = $a + 1;
       # 使用 goto EXPR 形式
       goto $str1.$str2;    # 类似 goto LOOP
    }
    say "a = $a";
    $a = $a + 1;
} while ($a < 20);
```

# 5 指令

## 5.1 分支指令

```perl
say 'Hello, Bob!' if $name eq 'Bob';
say "You're no Bob!" unless $name eq 'Bob';
```

## 5.2 循环指令

```perl
use strict;
use warnings;
use Modern::Perl;

say "$_ * $_ = ", $_ * $_ for 1 .. 10;
```

# 6 运算符

## 6.1 算数运算符

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

## 6.2 比较运算符

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

## 6.3 字符串比较运算符

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

## 6.4 赋值运算符

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

## 6.5 位运算

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

## 6.6 逻辑运算

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

## 6.7 引号运算

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

# 使用 unix 的 date 命令执行
my $t = qx{date};
say "qx{date} = $t";
```

## 6.8 qw

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

## 6.9 其他运算符

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

# 7 函数

1. `Perl`函数也就是用户定义的函数
1. `Perl`函数即执行一个特殊任务的一段分离的代码，它可以使减少重复代码且使程序易读。
1. `Perl`函数可以出现在程序的任何地方，语法格式如下

```perl
sub subroutine {
    statements;
}
```

## 7.1 向函数传递参数

1. `Perl`函数可以和其他编程一样接受多个参数，函数参数使用特殊数组`@_`标明
1. 因此函数第一个参数为`$_[0]`，第二个参数为`$_[1]`，以此类推
1. 不论参数是标量型还是数组型的，用户把参数传给函数时，`Perl`默认按引用的方式调用它们

```perl
use strict;
use warnings;
use Modern::Perl;

# 定义求平均值函数
sub Average{
    # 获取所有传入的参数
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

# 调用函数
Average(10, 20, 30);
```

### 7.1.1 向函数传递列表

1. 由于`@_`变量是一个数组，所以它可以向函数中传递列表
1. 但如果我们需要传入标量和数组参数时，需要把列表放在最后一个参数上

```perl
use strict;
use warnings;
use Modern::Perl;

# 定义函数
sub PrintList {
    my @list = @_;
    say "列表为 : @list";
}
my $a = 10;
my @b = (1, 2, 3, 4);

# 列表参数
PrintList($a, @b);
```

### 7.1.2 向函数传递哈希

当向函数传递哈希表时，它将复制到`@_`中，哈希表将被展开为键/值组合的列表

```perl
use strict;
use warnings;
use Modern::Perl;

# 方法定义
sub PrintHash {
    my (%hash) = @_;

    foreach my $key (keys %hash) {
        my $value = $hash{$key};
        say "$key : $value";
    }
}
my %hash = ('name' => 'youj', 'age' => 3);

# 传递哈希
PrintHash(%hash);
```

### 7.1.3 设置参数默认值

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

## 7.2 匿名函数

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

## 7.3 函数返回值

1. 函数可以向其他编程语言一样使用`return`语句来返回函数值
1. 如果没有使用`return`语句，则函数的最后一行语句将作为返回值

```perl
use strict;
use warnings;
use Modern::Perl;

# 方法定义1
sub add_a_b_1 {
    # 不使用 return
    $_[0]+$_[1];   
}

# 方法定义2
sub add_a_b_2 {
    # 使用 return
    return $_[0]+$_[1];  
}

say add_a_b_1(1, 2);
say add_a_b_2(1, 2);
```

## 7.4 函数的私有变量

1. 默认情况下，`Perl`中所有的变量都是全局变量，这就是说变量在程序的任何地方都可以调用
1. 如果我们需要设置私有变量，可以使用`my`操作符来设置
1. `my`操作符用于创建词法作用域变量，通过`my`创建的变量，存活于声明开始的地方，直到闭合作用域的结尾
1. 闭合作用域指的可以是一对花括号中的区域，可以是一个文件，也可以是一个`if`、`while`、`for`、`foreach`、`eval`字符串

```perl
use strict;
use warnings;
use Modern::Perl;

my $string = "Hello, World!";

# 函数定义
sub PrintHello {
    # PrintHello 函数的私有变量
    my $string;
    $string = "Hello, W3Cschool!";
    say "函数内字符串：$string";
}

# 调用函数
PrintHello();
say "函数外字符串：$string";
```

## 7.5 变量的临时赋值

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
    say "Within PrintW3CSchool: $string";
}

sub PrintMe {
    say "Within PrintMe: $string";
}

sub PrintHello {
    say "Within PrintHello: $string";
}

PrintW3CSchool();
PrintHello();
say "Outside: $string";
```

## 7.6 静态变量

1. `state`操作符功能类似于`C`里面的`static`修饰符，`state`关键字将局部变量变得持久
1. `state`也是词法变量，所以只在定义该变量的词法作用域中有效

```perl
use strict;
use warnings;
use Modern::Perl;
use feature 'state';

sub PrintCount {
    state $count = 0; # 初始化变量

    say "counter 值为：$count";
    $count++;
}

for (1..5) {
    PrintCount();
}
```

## 7.7 函数调用上下文

函数调用过程中，会根据上下文来返回不同类型的值，比如以下`localtime()`函数，在标量上下文返回字符串，在列表上下文返回列表

```perl
use strict;
use warnings;
use Modern::Perl;

# 标量上下文
my $datestring = localtime(time);
say $datestring;

# 列表上下文
my ($sec,$min,$hour,$mday,$mon, $year,$wday,$yday,$isdst) = localtime(time);
printf("%d-%d-%d %d:%d:%d", $year+1990, $mon+1, $mday, $hour, $min, $sec);
```

### 7.7.1 上下文感知

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

## 7.8 函数与命名空间

命名空间（`namespace`）即包（`package`）。默认情况下，函数定义在`main`包中，我们可以显式指定包。同一个命名空间中，某个函数名只能定义一次，重复定义会覆盖前一个定义。编译器会发出警告，可以通过`no warnings 'redefine';`禁止警告

```perl
sub Extensions::Math::add {
    ...
}
```

函数对内部、外部均可见，在同一个命名空间中，可以通过函数名来直接访问；在外部的命名空间中，必须通过全限定名来访问，除非将函数导入（`importing`）到当前命名空间中

### 7.8.1 导入

当使用`use`加载模块时，`Perl`会自动调用该模块的`import()`函数，模块中的接口可以提供自己的`import()`方法来向外部导出符号

模块后跟的名字都会作为`import()`函数的方法，例如

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

## 7.9 报告错误

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

# 8 闭包

## 8.1 创建闭包

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

## 8.2 何时使用闭包

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

## 8.3 参数绑定

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

## 8.4 闭包与state

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

# 9 属性

具名实体，包括变量以及函数都可以拥有属性，语法如下

```perl
my $fortress :hidden;
sub erupt_volcano :ScienceProject { ... }
```

上述定义会触发名为`hidden`以及`ScienceProject`的属性处理过程（` Attribute Handlers`)。如果对应的`Handler`不存在，则会报错

属性可以包含一系列参数，`Perl`会将其视为一组常量字符串

**大部分时候，你不需要使用属性**

# 10 Perl 格式化输出

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
# 左边对齐，字符长度为6
first: ^<<<<<
    $text
# 左边对齐，字符长度为6
second: ^<<<<<
    $text
# 左边对齐，字符长度为5，taobao 最后一个 o 被截断
third: ^<<<<
    $text  
.
write
```

## 10.1 格式行

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

# 重置text
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

## 10.2 格式变量

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

# 添加分页 $% 
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

## 10.3 输出到其他文件

默认情况下函数`write`将结果输出到标准输出文件`STDOUT`，我们也可以使它将结果输出到任意其它的文件中。最简单的方法就是把文件变量作为参数传递给`write`。例如，`write(MYFILE);`，`write`就用缺省的名为`MYFILE`的打印格式输出到文件`MYFILE`中。但是这样就不能用`$~`变量来改变所使用的打印格式，因为系统变量`$~`只对默认文件变量起作用

```perl
use strict;
use warnings;
use Modern::Perl;

if (open(MYFILE, ">tmp")) {
$~ = "MYFORMAT";
write MYFILE; # 含文件变量的输出，此时会打印与变量同名的格式，即MYFILE。$~里指定的值被忽略。

format MYFILE = # 与文件变量同名 
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
select (MYFILE); # 使得默认文件变量的打印输出到MYFILE中
$~ = "OTHER";
write;           # 默认文件变量，打印到select指定的文件中，必使用$~指定的格式 OTHER

format OTHER =
=================================
  使用定义的格式输入到文件中
=================================
. 
close MYFILE;
}
```

# 11 作用域

`Perl`中的所有符号都存在作用域（`Scope`）

## 11.1 词法作用域

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

## 11.2 包作用域

每个包都有一个符号表，该符号表中包含了所有包作用域下的变量。我们可以检查和修改该符号表，这就是导入（`importing`）的工作原理，也是只有全局变量或者包全局变量能够本地化（`local`）的原因

## 11.3 动态作用域

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

## 11.4 静态作用域

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

# 12 包

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

# 13 文件

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

# 14 Builtin

参考[perlfunc](https://perldoc.perl.org/perlfunc)。此外可以通过`perldoc perlfunc`查看

1. `say`：将给定字符串（默认为`$_`）输出到当前`select`的文件句柄中
1. `chomp`：删除给定字符串（默认为`$_`）中尾部的换行符
1. `defined`：判断给定变量是否已定义（是否赋值过）
1. `use`
1. `our`：为`package`变量创建别名
1. `my`
1. `state`：声明静态变量
1. `map`
1. `grep`
1. `sort`

# 15 进阶

[modern-perl.pdf](/resources/modern-perl.pdf)

**工具：**

1. `perldoc`
    * `perldoc perlop`
    * `perldoc perlsyn`
    * `perldoc perltoc`
    * `perldoc perlfunc`
    * `perldoc List::Util`
    * `perldoc Moose::Manual`
    * `perldoc -f wantarray`
1. `cpan`
    * `cpan Modern::Perl`
1. `perlbrew`

**站点：**

* [homepage](https://www.perl.org)
* [dev](https://dev.perl.org)
* [cpan](https://www.cpan.org)
* [community-perlmonks](https://perlmonks.org)
* [blogs](https://blogs.perl.org)
* [bestpractical](https://bestpractical.com)

**模块：**

* `Test::More`
    * `ok`
    * `is`
    * `isnt`

**TODO：**

1. map
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
1. `qr`
1. `AUTOLOAD` - P85

# 16 参考

* [w3cschool-perl](https://www.w3cschool.cn/perl/)
* [perl仓库-cpan](https://www.cpan.org/)
* [modern-perl.pdf](/resources/modern-perl.pdf)
* [Perl Tutorial](https://www.tutorialspoint.com/perl/perl_function_references.htm)
* [什么编程语言写脚本好？](https://www.zhihu.com/question/505203283/answer/2266164064)
* [Perl | qw Operator](https://www.geeksforgeeks.org/perl-qw-operator/?ref=lbp)
* [$_ the default variable of Perl](https://perlmaven.com/the-default-variable-of-perl)
