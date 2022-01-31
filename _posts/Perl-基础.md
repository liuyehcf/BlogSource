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

### 3.2.1 创建数组

```perl
@array1 = (1, 2, 'Hello');
@array2 = qw/这是 一个 数组/;
@array3 = qw/google
taobao
alibaba
youj/;
```

### 3.2.2 添加删除元素

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

### 3.2.3 数组序列号

`Perl`提供了可以按序列输出的数组形式，格式为：`起始值 + .. + 结束值`

```perl
@array = (1..10);
print "array = @array\n";

@subarray = @array[3..6];
print "subarray = @subarray\n";
```

### 3.2.4 数组大小

```perl
@array = (1,2,3);
$array[50] = 4;

$size = @array;
$max_index = $#array;

print "数组大小: $size\n";
print "最大索引: $max_index\n";
```

### 3.2.5 切割数组

```perl
@sites = qw/google taobao youj weibo qq facebook 网易/;

@sites2 = @sites[3,4,5];
@sites3 = @sites[3..5];

print "@sites2\n";
print "@sites3\n";
```

### 3.2.6 替换数组元素

`Perl`中数组元素替换使用`splice()`函数，语法格式如下：

* `splice @ARRAY, OFFSET [ , LENGTH [ , LIST ] ]`
* `@ARRAY`：要替换的数组
* `OFFSET`：起始位置
* `LENGTH`：替换的元素个数
* `LIST`：替换元素列表

```perl
@nums = (1..20);
print "替换前 - @nums\n";

splice(@nums, 5, 5, 21..25); 
print "替换后 - @nums\n";
```

### 3.2.7 将字符串转换为数组

`Perl`中将字符串转换为数组使用`split()`函数，语法格式如下：

* `split [ PATTERN [ , EXPR [ , LIMIT ] ] ]`
* `PATTERN`：分隔符，默认为空格
* `EXPR`：指定字符串数
* `LIMIT`：如果指定该参数，则返回该数组的元素个数

```perl
# 定义字符串
$var_test = "youj";
$var_string = "www-youj-com";
$var_names = "google,taobao,youj,weibo";

# 字符串转为数组
@test = split('', $var_test);
@string = split('-', $var_string);
@names  = split(',', $var_names);

print "$test[3]\n";  # 输出 j
print "$string[2]\n";  # 输出 com
print "$names[3]\n";   # 输出 weibo
```

### 3.2.8 将数组转换为字符串

`Perl`中将数组转换为字符串使用`join()`函数，语法格式如下：

* `join EXPR, LIST`
* `EXPR`：连接符
* `LIST`：列表或数组

```perl
# 定义字符串
$var_string = "www-youj-com";
$var_names = "google,taobao,youj,weibo";

# 字符串转为数组
@string = split('-', $var_string);
@names  = split(',', $var_names);

# 数组转为字符串
$string1 = join( '-', @string );
$string2 = join( ',', @names );

print "$string1\n";
print "$string2\n";
```

### 3.2.9 数组排序

`Perl`中数组排序使用`sort()`函数，语法格式如下：

* `sort [ SUBROUTINE ] LIST`
* `SUBROUTINE`：指定规则
* `LIMIT`：列表或数组

```perl
# 定义数组
@sites = qw(google taobao youj facebook);
print "排序前: @sites\n";

# 对数组进行排序
@sites = sort(@sites);
print "排序后: @sites\n";
```

### 3.2.10 合并数组

数组的元素是以逗号来分割，我们也可以使用逗号来合并数组

```perl
@numbers1 = (1,3,(4,5,6));
print "numbers1 = @numbers1\n";

@odd = (1,3,5);
@even = (2, 4, 6);
@numbers2 = (@odd, @even);
print "numbers2 = @numbers2\n";
```

### 3.2.11 数组起始下标

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

### 3.2.12 Tips

1. 用`print`打印数组时，最好放在引号里面，否则输出的时候，数组各元素就直接贴在一起了。而放在引号里面的话，各元素之间会用空格分隔

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

### 3.3.1 创建哈希

创建哈希可以通过以下两种方式：

1. 为每个`key`设置`value`
    ```perl
    $data{'google'} = 'google.com';
    $data{'w3cschool'} = 'w3cschool.cn';
    $data{'taobao'} = 'taobao.com';
    ```

1. 通过列表设置
    ```perl
    %data1 = ('google', 'google.com', 'w3cschool', 'w3cschool.cn', 'taobao', 'taobao.com');
    %data2 = ('baidu' => 'baidu.com', 'aliyun' => 'aliyun.cn', 'douyu' => 'douyu.com');

    print "\$data1{'google'} = $data1{'google'}\n";

    print "\$data2{'baidu'} = $data2{'baidu'}\n";
    ```

### 3.3.2 读取哈希的key和value

我们可以使用`keys`函数读取哈希所有的键，语法格式如下：

* `keys %HASH`

```perl
%data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

@names = keys %data;

print "$names[0]\n";
print "$names[1]\n";
print "$names[2]\n";
```

类似的我么可以使用`values`函数来读取哈希所有的值，语法格式如下：

* `values %HASH`

```perl
%data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

@urls = values %data;

print "$urls[0]\n";
print "$urls[1]\n";
print "$urls[2]\n";
```

### 3.3.3 检测元素是否存在

如果你在哈希中读取不存在的`key/value`对 ，会返回`undefined`值，且在执行时会有警告提醒。为了避免这种情况，我们可以使用`exists`函数来判断`key`是否存在，存在的时候读取

```perl
%data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

if (exists($data{'facebook'})) {
    print "facebook 的网址为 $data{'facebook'} \n";
} else {
    print "facebook 键不存在\n";
}
```

### 3.3.4 获取哈希大小

哈希大小为元素的个数，我们可以通过先获取`key`或`value`的所有元素数组，再计算数组元素多少来获取哈希的大小

```perl
%data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');

@keys = keys %data;
$size = @keys;
print "1 - 哈希大小: $size\n";

@values = values %data;
$size = @values;
print "2 - 哈希大小: $size\n";
```

### 3.3.5 哈希中添加或删除元素

添加`key/value`对可以通过简单的赋值来完成。但是删除哈希元素你需要使用`delete`函数

```perl
%data = ('google' => 'google.com', 'w3cschool' => 'w3cschool.cn', 'taobao' => 'taobao.com');
@keys = keys %data;
$size = @keys;
print "1 - 哈希大小: $size\n";

# 添加元素
$data{'facebook'} = 'facebook.com';
@keys = keys %data;
$size = @keys;
print "2 - 哈希大小: $size\n";

# 删除哈希中的元素
delete $data{'taobao'};
@keys = keys %data;
$size = @keys;
print "3 - 哈希大小: $size\n";
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
do
{
    statement(s);
} while (condition);
```

## 4.3 循环控制语句

### 4.3.1 next

`Perl next`语句用于停止执行从`next`语句的下一语句开始到循环体结束标识符之间的语句，转去执行`continue`语句块，然后再返回到循环体的起始处开始执行下一次循环。语法为：`next [ LABEL ];`，其中`LABEL`是可选的

```perl
$a = 10;
while ($a < 20) {
    if ( $a == 15) {
       # 跳出迭代
       $a = $a + 1;
       next;
    }
    print "a 的值为: $a\n";
    $a = $a + 1;
}
```

### 4.3.2 last

`Pe`rl last`语句用于退出循环语句块，从而结束循环，`last`语句之后的语句不再执行，`continue`语句块也不再执行。语法为：`last [LABEL];`，其中`LABEL`是可选的

```perl
$a = 10;
while ($a < 20) {
    if ($a == 15) {
       # 退出循环
       $a = $a + 1;
       last;
    }
    print "a 的值为: $a\n";
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
$a = 0;
while ($a < 3) {
    print "a = $a\n";
} continue {
    $a = $a + 1;
}
```

```perl
@list = (1, 2, 3, 4, 5);
foreach $a (@list) {
    print "a = $a\n";
} continue {
    last if $a == 4;
}
```

### 4.3.4 redo

`Perl redo`语句直接转到循环体的第一行开始重复执行本次循环，`redo`语句之后的语句不再执行，`continue`语句块也不再执行。语法为：`redo [LABEL];`，其中`LABEL`是可选的

```perl
$a = 0;
while ($a < 10) {
    if($a == 5) {
      $a = $a + 1;
      redo;
    }
    print "a = $a\n";
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
$a = 10;
LOOP:do
{
    if ($a == 15) {
       # 跳过迭代
       $a = $a + 1;
       # 使用 goto LABEL 形式
       goto LOOP;
    }
    print "a = $a\n";
    $a = $a + 1;
} while ($a < 20);
```

```perl
$a = 10;
$str1 = "LO";
$str2 = "OP";

LOOP:do
{
    if ($a == 15) {
       # 跳过迭代
       $a = $a + 1;
       # 使用 goto EXPR 形式
       goto $str1.$str2;    # 类似 goto LOOP
    }
    print "a = $a\n";
    $a = $a + 1;
} while ($a < 20);
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
$a = 10;
$b = 20;

print "\$a = $a , \$b = $b\n";

$c = $a + $b;
print '$a + $b = ' . $c . "\n";

$c = $a - $b;
print '$a - $b = ' . $c . "\n";

$c = $a * $b;
print '$a * $b = ' . $c . "\n";

$c = $a / $b;
print '$a / $b = ' . $c . "\n";

$c = $a % $b;
print '$a % $b = ' . $c. "\n";

$a = 2;
$b = 4;
$c = $a ** $b;
print '$a ** $b = ' . $c . "\n";
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
$a = 10;
$b = 20;

print "\$a = $a , \$b = $b\n";

if ($a == $b) {
    print "$a == \$b 结果 true\n";
} else {
    print "\$a == \$b 结果 false\n";
}

if ($a != $b) {
    print "\$a != \$b 结果 true\n";
} else {
    print "\$a != \$b 结果 false\n";
}

$c = $a <=> $b;
print "\$a <=> \$b 返回 $c\n";

if ($a > $b) {
    print "\$a > \$b 结果 true\n";
} else {
    print "\$a > \$b 结果 false\n";
}

if ($a >= $b){
    print "\$a >= \$b 结果 true\n";
} else {
    print "\$a >= \$b 结果 false\n";
}

if ($a < $b) {
    print "\$a < \$b 结果 true\n";
} else {
    print "\$a < \$b 结果 false\n";
}

if ($a <= $b) {
    print "\$a <= \$b 结果 true\n";
} else {
    print "\$a <= \$b 结果 false\n";
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
$a = "abc";
$b = "xyz";

print "\$a = $a ，\$b = $b\n";

if ($a lt $b) {
    print "$a lt \$b 返回 true\n";
} else {
    print "\$a lt \$b 返回 false\n";
}

if ($a gt $b) {
    print "\$a gt \$b 返回 true\n";
} else {
    print "\$a gt \$b 返回 false\n";
}

if ($a le $b) {
    print "\$a le \$b 返回 true\n";
} else {
    print "\$a le \$b 返回 false\n";
}

if ($a ge $b) {
    print "\$a ge \$b 返回 true\n";
} else {
    print "\$a ge \$b 返回 false\n";
}

if ($a ne $b) {
    print "\$a ne \$b 返回 true\n";
} else {
    print "\$a ne \$b 返回 false\n";
}

$c = $a cmp $b;
print "\$a cmp \$b 返回 $c\n";
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

```perl
$a = 10;
$b = 20;

print "\$a = $a ，\$b = $b\n";

$c = $a + $b;
print "赋值后 \$c = $c\n";

$c += $a;
print "\$c = $c ，运算语句 \$c += \$a\n";

$c -= $a;
print "\$c = $c ，运算语句 \$c -= \$a\n";

$c *= $a;
print "\$c = $c ，运算语句 \$c *= \$a\n";

$c /= $a;
print "\$c = $c ，运算语句 \$c /= \$a\n";

$c %= $a;
print "\$c = $c ，运算语句 \$c %= \$a\n";

$c = 2;
$a = 4;
print "\$a = $a ， \$c = $c\n";
$c **= $a;
print "\$c = $c ，运算语句 \$c **= \$a\n";
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
 
$a = 60;
$b = 13;

print "\$a = $a , \$b = $b\n";

$c = $a & $b;
print "\$a & \$b = $c\n";

$c = $a | $b;
print "\$a | \$b = $c\n";

$c = $a ^ $b;
print "\$a ^ \$b = $c\n";

$c = ~$a;
print "~\$a = $c\n";

$c = $a << 2;
print "\$a << 2 = $c\n";

$c = $a >> 2;
print "\$a >> 2 = $c\n";
```

## 5.6 逻辑运算

1. `and`
1. `&&`
1. `or`
1. `||`
1. `not`

```perl
$a = true;
$b = false;

print "\$a = $a , \$b = $b\n";

$c = ($a and $b);
print "\$a and \$b = $c\n";

$c = ($a  && $b);
print "\$a && \$b = $c\n";

$c = ($a or $b);
print "\$a or \$b = $c\n";

$c = ($a || $b);
print "\$a || \$b = $c\n";

$a = 0;
$c = not($a);
print "not(\$a)= $c\n";
```

## 5.7 引号运算

1. `q{}/q()`：为字符串添加单引号，`q{abcd}`结果为`'abcd'`
1. `qq{}/qq()`：为字符串添加双引号，`qq{abcd}`结果为`"abcd"`
1. `qx{}/qx()`：为字符串添加反引号，`qx{abcd}`结果为`` `abcd` ``

```perl
$a = 10;
 
$b = q{a = $a};
print "q{a = \$a} = $b\n";

$b = qq{a = $a};
print "qq{a = \$a} = $b\n";

# 使用 unix 的 date 命令执行
$t = qx{date};
print "qx{date} = $t\n";
```

## 5.8 qw

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

## 5.9 其他运算符

1. `.`：用于连接两个字符串
1. `x`：将给定字符串重复给定次数
1. `..`：范围运算符
1. `++`：自增
1. `--`：自减
1. `->`：用于指定一个类的方法

```perl
$a = "run";
$b = "oob";

print "\$a  = $a ， \$b = $b\n";
 
$c = $a . $b;
print "\$a . \$b = $c\n";

$c = "-" x 3;
print "\"-\" x 3 = $c\n";

@c = (2..5);
print "(2..5) = @c\n";

$a = 10;
$b = 15;
print "\$a  = $a ， \$b = $b\n";

$a++;
$c = $a ;
print "\$a 执行 \$a++ = $c\n";

$b--;
$c = $b ;
print "\$b 执行 \$b-- = $c\n";
```

# 6 子程序

1. `Perl`子程序也就是用户定义的函数
1. `Perl`子程序即执行一个特殊任务的一段分离的代码，它可以使减少重复代码且使程序易读。
1. `Perl`子程序可以出现在程序的任何地方，语法格式如下

```perl
sub subroutine {
    statements;
}
```

## 6.1 向子程序传递参数

1. `Perl`子程序可以和其他编程一样接受多个参数，子程序参数使用特殊数组`@_`标明
1. 因此子程序第一个参数为`$_[0]`，第二个参数为`$_[1]`，以此类推
1. 不论参数是标量型还是数组型的，用户把参数传给子程序时，`Perl`默认按引用的方式调用它们

```perl
# 定义求平均值函数
sub Average{
    # 获取所有传入的参数
    $n = scalar(@_);
    $sum = 0;

    foreach $item (@_) {
       $sum += $item;
    }
    $average = $sum / $n;
    print '传入的参数为 : ',"@_\n";           # 打印整个数组
    print "第一个参数值为 : $_[0]\n";         # 打印第一个参数
    print "传入参数的平均值为 : $average\n";  # 打印平均值
}

# 调用函数
Average(10, 20, 30);
```

### 6.1.1 向子程序传递列表

1. 由于`@_`变量是一个数组，所以它可以向子程序中传递列表
1. 但如果我们需要传入标量和数组参数时，需要把列表放在最后一个参数上

```perl
# 定义函数
sub PrintList {
    my @list = @_;
    print "列表为 : @list\n";
}
$a = 10;
@b = (1, 2, 3, 4);

# 列表参数
PrintList($a, @b);
```

### 6.1.2 向子程序传递哈希

当向子程序传递哈希表时，它将复制到`@_`中，哈希表将被展开为键/值组合的列表

```perl
# 方法定义
sub PrintHash {
    my (%hash) = @_;

    foreach my $key (keys %hash) {
        my $value = $hash{$key};
        print "$key : $value\n";
    }
}
%hash = ('name' => 'youj', 'age' => 3);

# 传递哈希
PrintHash(%hash);
```

## 6.2 子程序返回值

1. 子程序可以向其他编程语言一样使用`return`语句来返回函数值
1. 如果没有使用`return`语句，则子程序的最后一行语句将作为返回值

```perl
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

print add_a_b_1(1, 2), "\n";
print add_a_b_2(1, 2), "\n";
```

## 6.3 子程序的私有变量

1. 默认情况下，`Perl`中所有的变量都是全局变量，这就是说变量在程序的任何地方都可以调用
1. 如果我们需要设置私有变量，可以使用`my`操作符来设置
1. `my`操作符用于创建词法作用域变量，通过`my`创建的变量，存活于声明开始的地方，直到闭合作用域的结尾
1. 闭合作用域指的可以是一对花括号中的区域，可以是一个文件，也可以是一个`if`、`while`、`for`、`foreach`、`eval`字符串

```perl
# 全局变量
$string = "Hello, World!";

# 函数定义
sub PrintHello {
    # PrintHello 函数的私有变量
    my $string;
    $string = "Hello, W3Cschool!";
    print "函数内字符串：$string\n";
}

# 调用函数
PrintHello();
print "函数外字符串：$string\n";
```

## 6.4 变量的临时赋值

1. 我们可以使用`local`为全局变量提供临时的值，在退出作用域后将原来的值还回去
1. `local`定义的变量不存在于主程序中，但存在于该子程序和该子程序调用的子程序中。定义时可以给其赋值

```perl
# 全局变量
$string = "Hello, World!";

sub PrintW3CSchool {
    # PrintHello 函数私有变量
    local $string;
    $string = "Hello, W3Cschool!";
    # 子程序调用的子程序
    PrintMe();
    print "PrintW3CSchool 函数内字符串值：$string\n";
}

sub PrintMe {
    print "PrintMe 函数内字符串值：$string\n";
}

sub PrintHello {
    print "PrintHello 函数内字符串值：$string\n";
}

# 函数调用
PrintW3CSchool();
PrintHello();
print "函数外部字符串值：$string\n";
```

## 6.5 静态变量

1. `state`操作符功能类似于`C`里面的`static`修饰符，`state`关键字将局部变量变得持久
1. `state`也是词法变量，所以只在定义该变量的词法作用域中有效

```perl
use feature 'state';

sub PrintCount {
    state $count = 0; # 初始化变量

    print "counter 值为：$count\n";
    $count++;
}

for (1..5) {
    PrintCount();
}
```

## 6.6 子程序调用上下文

子程序调用过程中，会根据上下文来返回不同类型的值，比如以下`localtime()`子程序，在标量上下文返回字符串，在列表上下文返回列表

```perl
# 标量上下文
my $datestring = localtime(time);
print $datestring;

print "\n";

# 列表上下文
($sec,$min,$hour,$mday,$mon, $year,$wday,$yday,$isdst) = localtime(time);
printf("%d-%d-%d %d:%d:%d", $year+1990, $mon+1, $mday, $hour, $min, $sec);

print "\n";
```

# 7 引用

引用就是指针，`Perl`引用是一个标量类型，可以指向变量、数组、哈希表（也叫关联数组）甚至子程序，可以应用在程序的任何地方

## 7.1 创建引用

定义变量的时候，在变量名前面加个`\`，就得到了这个变量的一个引用

```perl
$scalarref = \$foo;     # 标量变量引用
$arrayref  = \@ARGV;    # 列表的引用
$hashref   = \%ENV;     # 哈希的引用
$coderef   = \&handler; # 子过程引用
$globref   = \*foo;     # GLOB句柄引用
```

此外，还可以创建匿名数组的引用、匿名哈希的引用、匿名子程序的引用

```perl
$aref1= [ 1,"foo",undef,13 ];
$aref2 = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9],
];

$href= { APR => 4, AUG => 8 };

$coderef = sub { print "W3CSchool!\n" };
```

## 7.2 使用引用

使用引用可以根据不同的类型使用`$`、`@`或`%`

```perl
$var = 10;

# $r 引用 $var 标量
$r = \$var;

# 输出本地存储的 $r 的变量值
print "$var 为 : ", $$r, "\n";

@var = (1, 2, 3);
# $r 引用  @var 数组
$r = \@var;
# 输出本地存储的 $r 的变量值
print "@var 为: ",  @$r, "\n";

%var = ('key1' => 10, 'key2' => 20);
# $r 引用  %var 数组
$r = \%var;
# 输出本地存储的 $r 的变量值
print "%var 为 : ", %$r, "\n";
```

如果你不能确定变量类型，你可以使用`ref`来判断，返回值列表如下，如果没有以下的值返回`false`

```perl
$var = 10;
$r = \$var;
print "r 的引用类型 : ", ref($r), "\n";

@var = (1, 2, 3);
$r = \@var;
print "r 的引用类型 : ", ref($r), "\n";

%var = ('key1' => 10, 'key2' => 20);
$r = \%var;
print "r 的引用类型 : ", ref($r), "\n";
```

## 7.3 循环引用

循环引用在两个引用相互包含时出现。你需要小心使用，不然会导致内存泄露

```perl
my $foo = 100;
$foo = \$foo;

print "Value of foo is : ", $$foo, "\n";
```

## 7.4 引用函数

1. 函数引用格式：`\&`
1. 调用引用函数格式：`& + 创建的引用名`

```perl
# 函数定义
sub PrintHash {
   my (%hash) = @_;
   
   foreach $item (%hash) {
      print "元素 : $item\n";
   }
}
%hash = ('name' => 'youj', 'age' => 3);

# 创建函数的引用
$cref = \&PrintHash;

# 使用引用调用函数
&$cref(%hash);
```

# 8 Perl 格式化输出

1. `Perl`是一个非常强大的文本数据处理语言
1. `Perl`中可以使用`format`来定义一个模板，然后使用`write`按指定模板输出数据
1. `Perl`格式化定义语法格式如下

# 9 TODO

```perl
print "Starting analysis\n" if $verbose;
```

# 10 参考

* [w3cschool-perl](https://www.w3cschool.cn/perl/)
* [perl仓库-cpan](https://www.cpan.org/)
* [Perl Tutorial](https://www.tutorialspoint.com/perl/perl_function_references.htm)
* [什么编程语言写脚本好？](https://www.zhihu.com/question/505203283/answer/2266164064)
* [Perl | qw Operator](https://www.geeksforgeeks.org/perl-qw-operator/?ref=lbp)
* [$_ the default variable of Perl](https://perlmaven.com/the-default-variable-of-perl)
