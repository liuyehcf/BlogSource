---
title: Linux-Shell
date: 2018-05-20 18:48:20
top: true
tags: 
- 原创
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 Basics

## 1.1 I/O Redirectio

| 命令（可以加空格地方都加了空格，否则就是不能加空格） | 说明 |
|:--|:--|
| `[command] 0< [file]` | 重定向命令的`stdin`到文件`file`，其中`0`可以省略 |
| `[command] 1> [file]` | 重定向命令的`stdout`到文件`file`，其中`1`可以省略 |
| `[command] 1>> [file]` | 重定向并追加命令的`stdout`到文件`file`，其中`1`可以省略 |
| `[command] 2> [file]` | 重定向命令的`stderr`到文件`file` |
| `[command] 2>> [file]` | 重定向并追加命令的`stderr`到文件`file` |
| `&> [file]` | 重定向`stdout`和`stderr`到文件`file` |
| `&>> [file]` | 重定向并追加`stdout`和`stderr`到文件`file` |
| `[fd_m]> [file]` | 重定向文件描述符`fd_m`到文件`file`，`fd_m`可以省略，默认为`1` |
| `[fd_m]>&[fd_n]` | 重定向文件描述符`fd_m`到文件描述符`fd_n`，`fd_m`可以省略，默认为`1` |
| `[fd_m]>>&[fd_n]` | 重定向并追加文件描述符`fd_m`到文件描述符`fd_n`，`fd_m`可以省略，默认为`1` |
| `[fd_m]<> [file]` | 把文件`file`打开, 并且将文件描述符`fd_m`分配给它，`fd_m`可以省略，默认为`0` |
| `0<&-` | 关闭`stdin`，其中`0`可以省略 |
| `[fd_in]<&-` | 关闭输入文件描述符`fd_in` |
| `1>&-` | 关闭`stdout`，其中`1`可以省略 |
| `[fd_out]>&-` | 关闭输出文件描述符`fd_out` |
| `<< tag` | 将开始标记 tag 和结束标记 tag 之间的内容作为输入 |

**注意：**

* `0`：`stdin`的文件描述符
* `1`：`stdout`的文件描述符
* `2`：`stderr`的文件描述符
* `&-`：用于关闭文件描述符

### 1.1.1 Here Document

`Here Document`是`Shell`中的一种特殊的重定向方式，用来将输入重定向到一个交互式`Shell`脚本或程序

它的基本的形式如下

```sh
command << delimiter
    document
delimiter
```

例如

```sh
wc -l << EOF
    欢迎来到
    菜鸟教程
    www.runoob.com
EOF
3          # 输出结果为 3 行
```

### 1.1.2 Here String

A here string is a feature in Unix-like operating systems that allows you to pass a single string as input to a command, without the need for command substitution or creating a separate file. It's a convenient way to provide input to a command that expects data from standard input.

In Bash and other Unix-like shells, the syntax for a here string is `<<<`. You use it like this:

```sh
command <<< "your_string_here"
```

For example, if you have a command `grep 'pattern'` that searches for a specific pattern in text, you can use a here string to provide the text directly as input without the need to create a separate file. Here's how it would look:

```sh
text="This is some example text containing the pattern"
grep 'pattern' <<< "$text"
```

The here string is particularly useful when you want to avoid the overhead of creating temporary files for passing small amounts of input data to a command.

### 1.1.3 How to capture stderr while discarding stdout

```sh
error_msg=$(cmd 2>&1 >/dev/null)
```

* `2>&1`: redirects stderr (file descriptor 2) to where stdout (file descriptor 1) is currently pointing, which means the terminal for this example.
* `>/dev/null`: redirects stdout (file descriptor 1) to /dev/null.

## 1.2 Pipe

**管道命令使用的是`|`这个界定符号，这个管道命令`|`仅能处理有前面一个命令传来的`正确信息`，也就是`standard output`的信息，对于standard error并没有直接处理的能力**

**每个管道后面接的`第一个数据必须是命令`，而且这个命令必须能够接受`standard input`的数据才行，例如`less，more，head，tail`等都可以接受standard input的管道命令**

**管道是作为子进程的方式来运行的。因此在管道中进行一些变量赋值操作，在管道结束后会丢失**

## 1.3 Command Substitution

**`命令替换（command substitution）`可以让`括号里`或`单引号里`的命令提前于整个命令运行，然后将`执行结果`插入在命令替换符号处。由于命令替换的结果经常交给外部命令，不应该让结果有换行的行为，所以默认将所有的换行符替换为了空格（实际上所有的空白符都被压缩成了单个空格）**

**`命令替换（command substitution）`有如下种形式**

1. `` `command` ``
1. `$(command)`
* **同时，上述两种方式也可以被包围在`""`之中，这样就可以保留命令行执行结果的空白**

```sh
echo "what date it is? $(date +%F)"

# 看看下面两个指令的差异
echo "$(ls)"
echo $(ls)
```

## 1.4 Process Substitution

**Process substitution works somewhat like a pipe, but differs in its implementation. Pipes run as subprocesses, whereas process substitution creates temporary files such as `/dev/fd/63`, `/dev/fd/62` under `/dev/fd/` to pass data. Usage is as follows:**

1. **`<(command)`: Generates standard output. Using input redirection, its result can serve as input for another command.**
    * `cat <(ls)`
1. **`>(command)`: Receives standard input. Using output redirection, it can accept the output of another command.**
    * `ls > >(cat)`
* **Note that there must be no spaces between `<`, `>`, and `(`**

```sh
# Treat <(ls) as a temporary file, the content of the file is the result of ls, then cat this temporary file
cat <(ls)
# Treat >(cat) as a temporary file, redirect the result of ls to this file, which is then read by cat
ls > >(cat)

# Pass <(date) as an argument to cat, which will display the date
cat <(date)
# Pass <(date) as an argument to echo, which will display the file descriptor
echo <(date)

# Pass multiple <(date) as arguments to cat, which will display the date
cat <(date) <(date) <(date)
# Pass multiple <(date) as arguments to echo, which will display the file descriptors
echo <(date) <(date) <(date)

# Redirect <(date) to the standard input of cat, which will display the date
cat < <(date)
# Redirect <(date) to the standard input of echo, but since echo does not read from standard input, the output will be blank
echo < <(date)
```

**Typical example: count the number of files**

```sh
# Correct way
count=0
while IFS= read -r line
do
    ((count++))
done < <(ls)
echo ${count}

# Incorrect way
count=0
ls | while IFS= read -r line
do
    # Because the pipeline is executed in a subprocess, the variable update is lost after the subprocess ends
    ((count++))
    echo "count=${count}"
done
echo ${count} # Always 0
```

**[Process substitution and pipe](https://unix.stackexchange.com/questions/17107/process-substitution-and-pipe)：**

1. `Multiple process inputs`: Process substitution can handle multiple inputs simultaneously, unlike pipes. For example:

    ```sh
    diff <(cd /foo/bar/; ls) <(cd /foo/baz; ls)
    ```

1. `Preserving stdin`: Process substitution can preserve standard input, unlike pipes. For example:

    ```sh
    cat > script.sh << 'EOF'
    #/bin/bash
    read LINE
    echo "You said ${LINE}!"
    EOF

    # wrong way
    cat script.sh | bash

    # right way
    bash <(cat script.sh)
    ```

1. `Outbound process substitution`: Process substitution can direct standard output and standard error to different programs, unlike pipes. For example:

    ```sh
    cat > main.cp << 'EOF'
    #include <iostream>

    int main() {
        std::cout << "This is normal output" << std::endl;
        std::cerr << "This is error output" << std::endl;
        return 0;
    }
    EOF

    gcc -o main -lstdc++ -std=gnu++11 main.cpp

    ./main 1> >(sed -n '/output/s/^.*$/Find stdout/p') 2> >(sed -n '/output/s/^.*$/Find stderr/p')
    ```

1. In pipes, modifications to variables and control flow commands like `continue`, `break`, and `return` do not affect the external environment, for example:

    ```sh
    function return_inside_pipe() {
        echo "return_inside_pipe"
        content="a\nb\nc"
        for((i=0;i<3;i++))
        do
            echo -e "${content}" | while IFS= read -r item
            do
                echo "item=${item}"
                if [ "${item}" == "b" ]; then
                    return
                fi 
            done
        done
    }

    function return_inside_substitution() {
        echo "return_inside_substitution"
        content="a\nb\nc"
        for((i=0;i<3;i++))
        do
            while IFS= read -r item
            do
                echo "item=${item}"
                if [ "${item}" == "b" ]; then
                    return
                fi 
            done < <(echo -e "${content}")
        done
    }

    return_inside_pipe
    return_inside_substitution
    ```

1. Interactive commands can be used in pipes but not in process substitution, for example:
    ```sh
    while IFS= read -r line
    do
        echo "${line}"
    done < <(docker exec -it trino trino --output-format CSV --execute "show create table tpcds.sf1.call_center" | sed '1d;$d' | sed 's/\r//')

    docker exec -it trino trino --output-format CSV --execute "show create table tpcds.sf1.call_center" | sed '1d;$d' | sed 's/\r//' | while IFS= read -r line
    do
        echo "${line}"
    done
    ```

## 1.5 Env

### 1.5.1 Pass to specific program

```sh
FOO=bar env | grep FOO
env | grep FOO
```

### 1.5.2 Pass to all programs of the pipe

```sh
FOO=bar bash -c 'somecommand someargs | somecommand2'
```

### 1.5.3 Pass to all programs of the session

```sh
export FOO=bar
env | grep FOO
unset FOO
env | grep FOO
```

### 1.5.4 Frequently-used env variables

* `SHELL`：当前使用的shell
* `TERM`
* `LANG`：语言
* `Locale Category`
    * `LC_ALL`: Overrides all other individual locale-related variables and sets a specific locale for all aspects of the system.
    * `LC_COLLATE`: Specifies the collation order used for sorting and comparison of strings.
    * `LC_CTYPE`: Defines the character classification and case conversion rules.
    * `LC_MESSAGES`: Sets the language used for system messages and the output of certain programs.
    * `LC_MONETARY`: Determines the formatting of monetary values (currency symbols, decimal separators, etc.).
    * `LC_NUMERIC`: Defines the formatting of numeric values (decimal point, thousands separator, etc.).
    * `LC_TIME`: Specifies the format used for date and time representation.
* `TMPDIR`：自定义tmp目录

## 1.6 Conditional Expressions

**`man bash` for details (Search `CONDITIONAL EXPRESSIONS`):**

Conditional expressions are used by the `[[` compound command and the `test` and `[` builtin commands to test file attributes and perform string and arithmetic comparisons. The test and `[` commands determine their behavior based on the number of arguments

* `-a file`: True if file exists.
* `-b file`: True if file exists and is a block special file.
* ` -c file`: True if file exists and is a character special file.
* `-d file`: True if file exists and is a directory.
* `-e file`: True if file exists.
* `-f file`: True if file exists and is a regular file.
* `-g file`: True if file exists and is set-group-id.
* `-h file`: True if file exists and is a symbolic link.
* `-k file`: True if file exists and its ``sticky'' bit is set.
* `-p file`: True if file exists and is a named pipe (FIFO).
* `-r file`: True if file exists and is readable.
* `-s file`: True if file exists and has a size greater than zero.
* `-t fd`: True if file descriptor fd is open and refers to a terminal.
* `-u file`: True if file exists and its set-user-id bit is set.
* `-w file`: True if file exists and is writable.
* `-x file`: True if file exists and is executable.
* `-G file`: True if file exists and is owned by the effective group id.
* `-L file`: True if file exists and is a symbolic link.
* `-N file`: True if file exists and has been modified since it was last read.
* `-O file`: True if file exists and is owned by the effective user id.
* `-S file`: True if file exists and is a socket.
* `file1 -ef file2`: True if file1 and file2 refer to the same device and inode numbers.
* `file1 -nt file2`: True if file1 is newer (according to modification date) than file2, or if file1 exists and file2 does not.
* `file1 -ot file2`: True if file1 is older than file2, or if file2 exists and file1 does not.
* `-o optname`: True if the shell option optname is enabled. See the list of options under the description of the `-o` option to the set builtin below.
* `-v varname`: True if the shell variable varname is set (has been assigned a value).
* `-R varname`: True if the shell variable varname is set and is a name reference.
* `-z string`: True if the length of string is zero.
* `-n string`: True if the length of string is non-zero.
* `string1 == string2`: True if the strings are equal. Only for `[[` command.
* `string1 = string2`: True if the strings are equal.
* `string1 != string2`: True if the strings are not equal.
* `string1 < string2`: True if string1 sorts before string2 lexicographically.
* `string1 > string2`: True if string1 sorts after string2 lexicographically.

# 2 Special Symbols

shell中的特殊符号包括如下几种

1. **`#`：注释符号（Hashmark[Comments]）**
    * 在shell文件的行首，作为shebang标记，`#!/bin/bash`
    * 其他地方作为注释使用，在一行中，#后面的内容并不会被执行
    * 但是用单/双引号包围时，#作为#号字符本身，不具有注释作用
1. **`;`：分号，作为多语句的分隔符（Command separator [semicolon]）**
    * 多个语句要放在同一行的时候，可以使用分号分隔
1. **`;;`：连续分号（Terminator [double semicolon]）**
    * 在使用case选项的时候，作为每个选项的终结符
1. **`.`：点号（dot command [period]）**
    * 相当于`bash`内建命令`source`
    * 作为文件名的一部分，在文件名的开头
    * 作为目录名，一个点代表当前目录，两个点号代表上层目录（当前目录的父目录）
    * 正则表达式中，点号表示任意一个字符
1. **`"`：双引号（partial quoting [double quote]）**
    * 双引号包围的内容可以允许变量扩展，**允许转义字符的存在**。如果字符串内出现双引号本身，需要转义。因此不一定双引号是成对的
1. **`'`：单引号（full quoting [single quote]）**
    * 单引号内的禁止变量扩展，**不允许转义字符的存在，所有字符均作为字符本身处理（除单引号本身之外）**。单引号必须成对出现
1. **`,`：逗号（comma operator [comma]）**
    * 用在连接一连串的数学表达式中，这串数学表达式均被求值，但只有最后一个求值结果被返回。例如`echo $[1+2,3+4,5+6]`返回11
    * 用于参数替代中，表示首字母小写，如果是两个逗号，则表示全部小写。这个特性在`bash version 4`的时候被添加的（Mac OS不支持）
        * `a="ATest";echo ${a,}` 输出aTest
        * `a="ATest";echo ${a,,}` 输出atest
1. **`\`：反斜线，反斜杆（escape [backslash]）**
    * 放在特殊符号之前，转义特殊符号的作用，仅表示特殊符号本身，这在字符串中常用
    * 放在一行指令的最末端，表示紧接着的回车无效（其实也就是转义了Enter），后继新行的输入仍然作为当前指令的一部分
1. **`/`：斜线，斜杆（Filename path separator [forward slash]）**
    * 作为路径的分隔符，路径中仅有一个斜杆表示根目录，以斜杆开头的路径表示从根目录开始的路径
    * 在作为运算符的时候，表示除法符号
1. **`` ` ``：反引号，后引号（Command substitution[backquotes]）**
    * 命令替换。这个引号包围的为命令，可以执行包围的命令，并将执行的结果赋值给变量
1. **`:`：冒号（null command [colon]）**
    * 空命令，这个命令什么都不做，但是有返回值，返回值为0
    * 可做while死循环的条件
    * 在if分支中作为占位符（即某一分支什么都不做的时候）
    * 放在必须要有两元操作的地方作为分隔符
    * 可以作为域分隔符，比如环境变量$PATH中，或者passwd中，都有冒号的作为域分隔符的存在
1. **`!`：感叹号，取反一个测试结果或退出状态（reverse （or negate） [bang],[exclamation mark]）**
    * 表示反逻辑，例如`!=`表示不等于
1. **`*`：星号（wildcard/arithmetic operator[asterisk]）**
    * 作为匹配文件名扩展的一个通配符，能自动匹配给定目录下的每一个文件
    * 正则表达式中可以作为字符限定符，表示其前面的匹配规则匹配任意次
    * 算术运算中表示乘法
1. **`**`：双星号（double asterisk）**
    * 算术运算中表示求幂运算
1. **`?`：问号（test operator/wildcard[Question mark]）**
    * 表示条件测试
    * 条件语句（三元运算符）
    * 参数替换表达式中用来测试一个变量是否设置了值，例如`echo ${a?}`，若a已经设定过值，则与`echo ${a}`相同，否则会出现异常信息`parameter null or not set`
    * 作为通配符，用于匹配文件名扩展特性中，用于匹配单个字符
    * 正则表达式中，表示匹配其前面规则0次或者1次
1. **`$`：美元符号（Variable substitution[Dollar sign]）**
    * 作为变量的前导符，用作变量替换，即引用一个变量的内容
    * 在正则表达式中被定义为行末
    * 特殊变量
        * **`$*`**：返回调用脚本文件的所有参数，且将所有参数作为一个整体（字符串）返回
        * **`$@`**：返回调用脚本文件的所有参数，且返回的是一个列表，每个参数作为一项。如果原参数是一个包含空格的字符串，那么最好用`"$@"`，这样会保留这个参数中的空格，而不是拆成多个参数
            ```sh
            cat > test.sh << 'EOF'
            #!/bin/bash

            echo "Using \"\$*\":"
            for a in "$*"; do
                echo $a;
            done

            echo -e "\nUsing \$*:"
            for a in $*; do
                echo $a;
            done

            echo -e "\nUsing \"\$@\":"
            for a in "$@"; do
                echo $a;
            done

            echo -e "\nUsing \$@:"
            for a in $@; do
                echo $a;
            done              
            EOF

            bash test.sh one two "three four"
            ```

        * **`$#`**：表示传递给脚本的参数数量
        * **`$?`**：此变量值在使用的时候，返回的是最后一个命令、函数、或脚本的退出状态码值，如果没有错误则是0，如果为非0，则表示在此之前的最后一次执行有错误
        * **`$$`**：进程ID变量，这个变量保存了运行当前脚本的进程ID值
1. **`()`：圆括号（parentheses）**
    * 命令组（Command group）。由一组圆括号括起来的命令是命令组，**命令组中的命令是在子shell（subshell）中执行**。因为是在子shell内运行，因此在括号外面是没有办法获取括号内变量的值，但反过来，命令组内是可以获取到外面的值，这点有点像局部变量和全局变量的关系，在实作中，如果碰到要cd到子目录操作，并在操作完成后要返回到当前目录的时候，可以考虑使用subshell来处理
    * 用于数组初始化
1. **`{}`：代码块（curly brackets）**
    * 这个是匿名函数，但是又与函数不同，在代码块里面的变量在代码块后面仍能访问
1. **`[]`：中括号（brackets）**
    * **`[`是bash的内部命令**（注意与`[[`的区别）
    * 作为test用途，不支持正则
    * 在数组的上下文中，表示数组元素的索引，方括号内填上数组元素的位置就能获得对应位置的内容，例如`${ary[1]}`
    * 在正表达式中，方括号表示该位置可以匹配的字符集范围
1. **`[[]]`：双中括号（double brackets）**
    * **`[[`是 bash 程序语言的关键字**（注意与`[`的区别）
    * 作为test用途。`[[]]`比`[]`支持更多的运算符，比如：`&&,||,<,>`操作符。同时，支持正则，例如`[[ hello = hell? ]]`
    * bash把双中括号中的表达式看作一个单独的元素，并返回一个退出状态码
1. **`$[...]`：表示整数扩展（integer expansion）**
    * 详见[数值运算](#数值运算)
1. **`(())`：双括号（double parentheses）**
    * 详见[数值运算](#数值运算)
1. **`> >& >> < &< << <>`：重定向（redirection）**
    * 详见[I/O重定向](#I/O重定向)
1. **`|`：管道**
    * 详见[管道](#管道)
1. **`(command)>  <(command)`：进程替换（Process Substitution)**
    * 详见[进程替换](#进程替换)
1. **`&& ||`：逻辑操作符**
    * 在测试结构中，可以用这两个操作符来进行连接两个逻辑值
1. **`&`：与号（Run job in background[ampersand]）**
    * 如果命令后面跟上一个&符号，这个命令将会在后台运行
1. **`-`：命令中的单个`-`表示标准输入或输出。具体代表标准输入还是标准输出取决于程序本身**
    * `cat -`：此时，`-`代表标准输入
    * `echo "This is Test" | socat - /tmp/hello.html`：此时，`-`代表标准输出
    * `socat - /tmp/hello.html`：此时，`-`代表标准输入

# 3 Variable Type

## 3.1 Default/Normal/String

### 3.1.1 Concat

```sh
your_name="qinjx"
greeting="hello, "${your_name}" \!"
echo ${greeting}
```

### 3.1.2 Length

```sh
text="abcdefg"
echo "字符串长度为 ${#text}"
```

### 3.1.3 Substring Removal

下面以字符串`http://www.aaa.com/123.htm`为例，介绍几种不同的截取方式

**`#`：删除左边字符，保留右边字符**

* 其中`var`是变量名，`#`是运算符，`*`是通配符，表示从左边开始删除第一个`//`号及左边的所有字符。即删除`http://`，结果是`www.aaa.com/123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var#*//}
```

**`##`：删除左边字符，保留右边字符**

* 其中`var`是变量名，`##`是运算符，`*`是通配符，表示从左边开始删除最后（最右边）一个`/`号及左边的所有字符。即删除`http://www.aaa.com/`，结果是`123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var##*/}
```

**`%`：删除右边字符，保留左边字符**

* 其中`var`是变量名，`%`是运算符，`*`是通配符，表示从从右边开始，删除第一个`/`号及右边的字符。即删除`/123.htm`，结果是`http://www.aaa.com`

```sh
var='http://www.aaa.com/123.htm'
echo ${var%/*}
```

**`%%`：删除右边字符，保留左边字符**

* 其中`var`是变量名，`%%`是运算符，`*`是通配符，表示从右边开始，删除最后（最左边）一个`/`号及右边的字符。即删除`//www.aaa.com/123.htm`，结果是`http:`

```sh
var='http://www.aaa.com/123.htm'
echo ${var%%/*}
```

**从左边第几个字符开始，从左往右截取若干个字符**

* 其中`var`是变量名，`0`表示从左边第`1`个字符开始，`5`表示截取`5`个字符，结果是`http:`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0:5}
```

**从左边第几个字符开始，从左往右截取，一直到结束**

* 其中`var`是变量名，`7`表示从左边第`8`个字符开始，结果是`www.aaa.com/123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:7}
```

**从右边第几个字符开始，从左往右截取若干个字符**

* 其中`var`是变量名，`0-7`表示从右边第`7`字符开始，`3`表示截取`3`个字符，结果是`123`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7:3}
```

**从右边第几个字符开始，从左往右截取，一直到结束**

* 其中`var`是变量名，`0-7`表示从右边第`7`字符开始，结果是`123.htm`

```sh
var='http://www.aaa.com/123.htm'
echo ${var:0-7}
```

### 3.1.4 Substring Replacement

* **`${variable/pattern/string}`**: Replaces the first match of `pattern` with `string`.
* **`${variable//pattern/string}`**: Replaces all matches of `pattern` with `string`.
* **`${variable/#pattern/string}`**: If `pattern` matches the beginning of `$variable`, it's replaced with `string`.
* **`${variable/%pattern/string}`**: If `pattern` matches the end of `$variable`, it's replaced with `string`.

```sh
ips=( "1.1.1.1" "2.2.2.2" "3.3.3.3" )

echo ${ips[@]//./-}

# % indicates that the replacement should happen at the end of each array element.
echo ${ips[@]/%/:4500}

# # indicates that the replacement should happen at the start of each array element.
echo ${ips[@]/#/address:}
```

### 3.1.5 Conditional Assignment

**变量为空时，返回默认值**

```sh
echo ${FOO:-val2} # 输出val2
test -z "${FOO}"; echo $? # 输出0
FOO=val1
echo ${FOO:-val2} # 输出val1
```

**变量为空时，将变量设置为默认值，然后返回变量的值**

```sh
echo ${FOO:=val2} # 输出val2
test -z "${FOO}"; echo $? # 输出1
FOO=val1
echo ${FOO:=val2} # 输出val1
```

**变量不为空时，返回默认值**

```sh
FOO=val1
echo ${FOO:+val2} # 输出val2
FOO=
echo ${FOO:+val2} # 输出空白
```

**当变量为空时，输出错误信息并退出**

```sh
echo ${FOO:?error} # 输出error
```

### 3.1.6 Read by Line

**方式1**

```sh
# 文件名不包含空格的话，可以不要引号
# 文件名若包含空格，且不用引号，则会报错：ambiguous redirect
while IFS= read -r line
do
    echo $line
done < "test.txt"

# 或者利用 进程替换

while IFS= read -r line
do
    echo $line
done < <(cmd) 
```

**方式2**

* **注意，在这种方式下，在while循环内的变量的赋值会丢失，因为管道相当于开启另一个进程**

```sh
STDOUT | while IFS= read -r line
do
    echo $line
done
```

### 3.1.7 Contains

**方式1：利用运算符`=~`**

```sh
str1="abcd"
str2="bc"
if [[ "${str1}" =~ "${str2}" ]]; then
    echo "contains"
else
    echo "not contains"
fi
```

**方式2：利用通配符**

```sh
str1="abcd"
str2="bc"
if [[ "${str1}" = *"${str2}"* ]]; then
    echo "contains"
else
    echo "not contains"
fi
```

**方式3：利用grep**

```sh
str1="abcd"
str2="bc"
result=$(echo ${str1} | grep ${str2})
if [ -n "${result}" ]; then
    echo "contains"
else
    echo "not contains"
fi
```

### 3.1.8 trim

#### 3.1.8.1 Method 1

```sh
function trim() {
    local trimmed="$1"

    # Strip leading spaces.
    while [[ "${trimmed}" = " "* ]]; do
       trimmed="${trimmed## }"
    done
    # Strip trailing spaces.
    while [[ "${trimmed}" = *" " ]]; do
        trimmed="${trimmed%% }"
    done

    echo -n "$trimmed"
}

test4="$(trim "  two leading")"
test5="$(trim "two trailing  ")"
test6="$(trim "  two leading and two trailing  ")"
test1="$(trim " one leading")"
test2="$(trim "one trailing ")"
test3="$(trim " one leading and one trailing ")"
echo "'$test1', '$test2', '$test3', '$test4', '$test5', '$test6'"
```

#### 3.1.8.2 Method 2

```sh
function trim() {
    local trimmed="$1"

    echo $(echo -n ${trimmed} | xargs)
}

test4="$(trim "  two leading")"
test5="$(trim "two trailing  ")"
test6="$(trim "  two leading and two trailing  ")"
test1="$(trim " one leading")"
test2="$(trim "one trailing ")"
test3="$(trim " one leading and one trailing ")"
echo "'$test1', '$test2', '$test3', '$test4', '$test5', '$test6'"
```

### 3.1.9 Case Conversion

```sh
echo 'hello' | tr 'a-z' 'A-Z'
echo 'HELLO' | tr 'A-Z' 'a-z'
```

### 3.1.10 Extract

```sh
var='[hello]'
var=${var#\[}
var=${var%\]}
echo ${var}
```

### 3.1.11 String with special character

```sh
var="SELECT * FROM t0"
# 会有额外的内容输出
echo ${var}
# 加上双引号即可解决
echo "${var}"
```

### 3.1.12 Array to String

```sh
items=( "hello world" "how have you been" )
printf '%s\n' ${items[@]} | tr '\n' ',' | sed 's/,$//g' | paste -sd ',' -
```

### 3.1.13 Multi-line Content

```sh
item="something"
content=$(cat << EOF
This is line 1
This is line 2
This is line 3
This is line 4, item=${item}
EOF
)

echo "${content}"

content=$(cat << 'EOF'
This is line 1
This is line 2
This is line 3
This is line 4, item=${item}
EOF
)

echo "${content}"
```

## 3.2 Numerical Calculation

### 3.2.1 `$[]`

**整数扩展，会返回执行后的结果。如果有`,`分隔，那么只返回最后一个表达式执行的结果**

```sh
echo $[ 1 + 3 ]

a=10;b=5
echo $[ $a + $b ]
echo $[ $a - $b ]
echo $[ $a * $b ]       #此时不用对*转义
echo $[ $a / $b ]
echo $[ $a % $b ]

echo $[ 1 + 3, 5 + 6 ]
```

### 3.2.2 `$(())`

**`$(())`有如下两个功能**

1. 数值计算
1. 进制转换
* **在`$(())`中的变量名称，可于其前面加$符号来替换，也可以不用**

```sh
# 数值计算
a=5;b=7;c=2
echo $((a+b*c))
echo $(($a+$b*$c))

# 进制转换
a=06;b=09;c=02;
echo $(( 10#$a + 10#$b + 10#$c ))
echo $((16#ff))
echo $((8#77))
```

### 3.2.3 `(())`

**整数扩展，只计算，不返回值。通常用于重定义变量值，只有赋值语句才能起到重定义变量的作用**

```sh
a=1
((a+10))
echo $a     # 输出1

((a+=10))
echo $a     # 输出11

((a++))
echo $a     # 输出12
```

### 3.2.4 expr

**`expr`是一个用于数值计算的命令，运算符号两边必须加空格，不加空格会原样输出，不会计算**

```sh
expr 1 + 3
 
a=10;b=5
expr $a + $b
expr $a - $b
expr $a \* $b   #因为乘号*在shell中有特殊的含义，所以要转义
expr $a / $b    #除法取商
expr $a % $b    #除法取模
```

### 3.2.5 bc

**浮点数运算：**

```sh
echo "scale=2; 1/3" | bc
```

**浮点数比较：**

```sh
if [ $(echo "1.2 < 1.212" | bc) -eq 1 ]; then
    echo "1.2 < 1.212, ok"
fi

if [ $(echo "1.22 >= 1.21" | bc) -eq 1 ]; then
    echo "1.22 >= 1.21, ok"
fi
```

## 3.3 Array

Shell 数组用括号来表示，元素用`空格`符号分割开，语法格式如下：

```sh
array_name=()
array_name=(value1 ... valuen)

# 或者直接这样定义，注意，不需要${}
array_name[1]=value1
array_name[2]=value2
...
array_name[n]=valuen
```

### 3.3.1 Operations

#### 3.3.1.1 Get All Elements
 
```sh
${array[@]}
${array[*]}
```

#### 3.3.1.2 Get Length

```sh
${#array[@]}
${#array[*]}
```

#### 3.3.1.3 Get All Indexes

```sh
${!array[@]}
${!array[*]}
```

#### 3.3.1.4 Combine Arrays

```sh
array1=(1 2 3)
array2=(4 5 6)
array3=( ${array1[@]} ${array2[@]} )
echo "array3='${array3[@]}'"
```

#### 3.3.1.5 Append Elements

```sh
# 方法1
array1=()
array1+=( 1 )
array1+=( 2 )
array1+=( 3 )
echo "array1='${array1[@]}'"

# 方法2
array2=()
array2=( ${array2[@]} 1 )
array2=( ${array2[@]} 2 )
array2=( ${array2[@]} 3 )
echo "array2='${array2[@]}'"

# 方法3，针对bash，数组下标从0开始
array3=()
array3[${#array3[@]}]=1
array3[${#array3[@]}]=2
array3[${#array3[@]}]=3
echo "array3='${array3[@]}'"

# 方法4，针对zsh，数组下标从1开始（bash也适用）
array4=()
array4[${#array4[@]}+1]=1
array4[${#array4[@]}+1]=2
array4[${#array4[@]}+1]=3
echo "array4='${array4[@]}'"
```

**Examples:**

```sh
text='my name is liuye'
array=( $(echo ${text}) )

echo "数组元素为：${array[@]}"
echo "数组元素为：${array[*]}"

echo "数组长度为：${#array[@]}"
echo "数组长度为：${#array[*]}"

echo "数组下标为：${!array[@]}"
echo "数组下标为：${!array[*]}"

for element in ${array[@]}
do
    echo $element
done
```

### 3.3.2 Start Index

1. `sh/bash`：数组下标从0开始
1. `zsh`：数组下标从1开始

**要始终获得一致的行为，请使用：`${array[@]:offset:length}`**

* `offset`：起始索引，`sh/bash/zsh`都是从`0`开始
* `length`：取多少个元素。若`length = 1`，那么只取某个元素；若`length > 1`，那么取的是一个子集
    * 不写length表示直到最后一个元素

```sh
array=(1 2 3 4 5 6 7 8 9 10)
# output 1
echo ${array[@]:0:1}

# output 1 2
echo ${array[@]:0:2}

# output 1 2 3
echo ${array[@]:0:3}

# output 4 5 6
echo ${array[@]:3:3}

# output 4 5 6 7 8 9 10
echo ${array[@]:3}
```

### 3.3.3 Collection Calculation

假设`F1`和`F2`是两个数组

**F1和F2的交集**

```sh
F1=( 1 2 3 )
F2=( 2 3 4 )
echo ${F1[@]} ${F2[@]} | tr ' ' '\n' | sort | uniq -d
```

**F1和F2的并集**

```sh
F1=( 1 2 3 )
F2=( 2 3 4 )
echo ${F1[@]} ${F2[@]} | tr ' ' '\n' | sort | uniq
```

**F1和F2的并集-F1和F2的交集，即差集**

```sh
F1=( 1 2 3 )
F2=( 2 3 4 )
echo ${F1[@]} ${F2[@]} | tr ' ' '\n' | sort | uniq -u
```

### 3.3.4 Iterate Array

```sh
array=(1 2 3 4 5)
for v in ${array[@]}
do
    echo ${v}
done
```

```sh
array=(1 2 3 4 5)
for ((i=0;i<${#array[@]};i++))
do
    v=${array[@]:i:1}
    echo ${v}
done
```

#### 3.3.4.1 Array Delimiter

**如果数组中的内容包含空白，`foreach`默认会以空格作为分隔符，这就有可能破坏数组元素原有的结构，例如**

```sh
array=("Hello Foo" "I'm Bar!")
for v in ${array[@]}
do
    echo ${v}
done

# this one works fine
for ((i=0;i<${#array[@]};i++))
do
    v=${array[@]:i:1}
    echo ${v}
done
```

**我们可以通过修改`IFS`来修改`foreach`的默认行为**

```sh
array=("Hello Foo！" "I'm Bar!")
ifs_bak="${IFS}"
IFS=$'\n'
for v in ${array[@]}
do
    echo ${v}
done
IFS="${ifs_bak}"
```

### 3.3.5 Echo the array with a specified delimiter

```sh
# echo not respect IFS
array=(1 2 3 4 5 6)
IFS=/ echo ${array[@]}

# works fine
IFS=/ output=${array[@]}
echo ${output}
```

## 3.4 Map

Shell map用括号来表示，元素用`空格`符号分割开，语法格式如下：

```sh
declare -A map_name=([key1]=value1 ... [keyn]=valuen)

# 或者直接这样定义，注意，不需要${}
declare -A map_name
map_name[key1]=value1
map_name[key2]=value2
...
map_name[keyn]=valuen
```

**属性**

* `@`或`*`可以获取map中的所有value
```
${map[@]}
${map[*]}
```

* 获取map长度的方法与获取字符串长度的方法相同，即利用`#`
```
${#map[@]}
${#map[*]}
```

* `!`可以获取map中关键字集合
```
${!map[@]}
${!map[*]}
```

**Examples:**

```sh
declare -A map
map['a']=1
map['b']=2
map['c']=3

echo ${map[@]}
echo ${map[*]}

echo ${#map[@]}
echo ${#map[*]}

echo ${!map[@]}
echo ${!map[*]}

for key in ${!map[*]}
do
    echo "value=${map[${key}]}"
done
```

## 3.5 Indirect Variable Expansion

```sh
foo="bar"
bar="Hello, World"

# Direct expansion
echo "$foo"

# Indirect expansion
echo "${!foo}"
```

# 4 Condition

## 4.1 test

### 4.1.1 Filetype

**关于某个文件名的文件类型判断，如`test -e filename`**

* **`-e`：该名字对应的文件或目录是否存在**
* **`-f`：该名字对应的文件是否存在**
* **`-d`：该名字对应的目录是否存在**
* **`-s`：该名字对应的文件或目录是否存在且不为空**
    * 如果名字对应的是一个已存在的文件，那判断文件内容是否为空，非空返回真
    * 如果名字对应的是一个已存在的目录，那返回真
    * 如果名字不存在，返回假
* `-b`：该文件名是否存在且为一个block device设备
* `-c`：该文件名是否存在且为一个character device设备
* `-S`：该文件名是否存在且为一个Socket文件
* `-p`：该文件名是否存在且为以FIFO（pipe）文件
* `-L`：该文件名是否存在且为一个链接文件

### 4.1.2 Permission

**关于文件的权限检测，如`test -r filename`**

* **`-r`：检测该文件名是否存在且具有"可读"的权限**
* **`-w`：检测该文件名是否存在且具有"可写"的权限**
* **`-x`：检测该文件名是否存在且具有"可执行"的权限**
* `-u`：检测该文件名是否存在且具有"SUID"的属性
* `-g`：检测该文件名是否存在且具有"GUID"的属性
* `-k`：检测该文件名是否存在且具有"Sticky bit（SBIT）"的属性
* `-s`：检测该文件名是否存在且为"非空白文件"

**两个文件之间的比较，如`test file1 -nt file2`**

* `-nt`：（newer than） 判断file1是否比file2新
* `-ot`：（older than） 判断file1是否比file2旧
* `-ef`：判断file1与file2是否为同一文件，可用在判断hard link的判断上，主要意义在于判断两个文件是否均指向同一个inode

### 4.1.3 Number

**数值比较，如`test n1 -eq n2`**

* **`-eq`：两数值相等（equal）**
* **`-ne`：两数值不等（not equal）**
* **`-gt`：n1大于n1（greater than）**
* **`-lt`：n1小于n2（less than）**
* **`-ge`：n1大于等于n2（greater than or equal）**
* **`-le`：n1小于n2（less than or equal）**

### 4.1.4 String

**字符串比较，例如`test n1 = n2`**

* **`-z`：判定字符串是否为空，空返回true**
    * **在`[]`中，变量需要加引号，例如`[ -z "${a}" ]`**
    * **在`[[]]`中，变量不需要加引号，例如`[[ -z ${a} ]]`**
* **`-n`：判断字符串是否为空，非空返回true**
    * **在`[]`中，变量需要加引号，例如`[ -n "${a}" ]`**
    * **在`[[]]`中，变量不需要加引号，例如`[[ -n ${a} ]]`**
* **`=`：判断str1是否等于str2**
* **`!=`：判断str1是否等于str2**
* **字符串变量的引用方式：`"${var_name}"`，即必须加上双引号`""`**

### 4.1.5 Logical

**逻辑与/或/非**

* **`-a`：两个条件同时成立，返回true，如test -r file1 -a -x file2**
* **`-o`：任一条件成立，返回true，如test -r file1 -o -x file2**
* **`!`：反向状态**

## 4.2 `[]`

**判断符号`[]`与判断式`test`用法基本一致，有以下几条注意事项**

1. 如果要在bash的语法当中使用括号作为shell的判断式时，**必须要注意在中括号的两端需要有空格符来分隔**
1. **逻辑与逻辑或，用的是`&&`和`||`，且需要将条件分开写，如下**
    * `[ condition1 ] && [ condition2 ]`
    * `[ condition1 ] || [ condition2 ]`
1. **不可以使用通配符**
1. **仅支持`=`作为相等比较的运算符，不支持`==`（取决于shell的实现，`bash`就支持这两种，但是`zsh`对语法更严格，仅支持`=`）**

**Examples:**

```sh
# 正确写法
if [ 2 -gt 1 ] && [ 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [ 2 -gt 1 && 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 正确写法
if [ 2 -gt 1 -a 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [ 2 -gt 1 ] -a [ 3 -gt 2 ]
then
    echo "yes"
else
    echo "no"
fi
```

## 4.3 `[[]]`

**判断符号`[[]]`与判断式`test`用法基本一致，有以下几条注意事项**

1. 如果要在bash的语法当中使用括号作为shell的判断式时，**必须要注意在中括号的两端需要有空格符来分隔**
1. **逻辑与逻辑或，用的是`&&`和`||`，用一个`[]`或者用两个`[[]]`都可以，但使用`[[]]`时不能用`-a`和`-o`**
1. **可以使用通配符**
1. **支持`=`与`==`作为相等比较的运算符**

**Examples:**

```sh
# 正确写法
if [[ 2 -gt 1 ]] && [[ 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 正确写法
if [[ 2 -gt 1 && 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [[ 2 -gt 1 -a 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi

# 错误写法
if [[ 2 -gt 1 ]] -a [[ 3 -gt 2 ]]
then
    echo "yes"
else
    echo "no"
fi
```

## 4.4 Command

我们可以用如下方式来判断命令执行是否成功：

```sh
if <cmd> [<options>]; then
    ...
fi
```

例如：

```sh
if ls ~ > /dev/null; then
    echo "success"
fi

output="warning: xxxxx"
if grep -q 'error' <<< ${output} || grep -q 'warning' <<< ${output}; then
    echo "error occurs"
fi
```

# 5 Control Flow

## 5.1 if

```sh
if condition
then
    command1 
    command2
    ...
    commandN 
fi
```

## 5.2 if else

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

## 5.3 if else-if else

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

## 5.4 for

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
for ((i=1;i<=10;i++))
do
    command1
    command2
    ...
    commandN
done
```

## 5.5 while

```sh
while condition
do
    command
done
```

## 5.6 until

```sh
until condition
do
    command
done
```

## 5.7 case

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

### 5.7.1 Determine if numerical number

```sh
function isNumber() {
    local content=$1
    case "${content}" in
    [0-9])
        echo "'${content}' is number"
        ;;
    [1-9][0-9]*)
        echo "'${content}' is number"
        ;;
    *)
        echo "'${content}' is not number"
        ;;
    esac
}

for ((i=0; i<100; i++)) 
do
    isNumber ${i}
done
```

# 6 Function

## 6.1 Pass Parameter

**传递数组**

1. 用`""`将数组转化成字符串

```sh
function func() {
    # 这里将传入的字符串解析成数组
    param=( $(echo $1) )
    echo "param=${param[*]}"
}

array=('a', 'b', 'c', 'd', 'e')

# 这里用""将数组转为字符串
func "${array[*]}"
```

## 6.2 Standard Output

**返回数组**

```sh
function func() {
    # 这里将传入的字符串解析成数组
    array=('a' 'b' 'c' 'd' 'e')
    echo "${array[*]}"
}

# 这里用""将数组转为字符串
array=( $(func) )
echo ${array[*]}
```

## 6.3 Return Value

```sh
function func() {
    # 这里必须返回非负整数
    return 66
}

func

# 获取函数返回值
echo $?
```

# 7 builtin

`bash shell`的命令分为两类：外部命令和内部命令。外部命令是通过系统调用或独立的程序实现的，如`sed`、`awk`等等。内部命令是由特殊的文件格式（`.def`）所实现，如`cd`、`history`、`exec`等等

通过`man builtins`查看说明文档

## 7.1 shift

shift用于移动参数的位置

**Pattern:**

* `shift [n]`：n是数字，默认是1

```sh
eval set -- a b c d

echo $1 # 输出a
shift
echo $1 # 输出b
shift 2
echo $1 # 输出d
```

## 7.2 eval

The args are read and concatenated together into a single command. This command is then read and executed by the shell, and its exit status is returned as the value of eval. If there are no args, or only null arguments, eval returns 0.

```sh
# Execute command exactly you wrote
cmd="date '+%Y-%m-%d %H:%M:%S'"
${cmd}
eval ${cmd}

# Variable expansion, one eval can have one more expansion process.
var0="hello world"
var1='${var0}'
var2='${var1}'
echo ${var1}            # output: ${var0}
eval echo ${var1}       # output: hello world
eval echo ${var2}       # output: ${var0}
eval eval echo ${var2}  # output: hello world
```

## 7.3 set

**Pattern:**

* `set [option]`

**Options:**

* `-e`: Exit immediately if a pipeline (which may consist of a single simple command), a list, or a compound command (see `SHELL GRAMMAR` in bash(1)), exits with a non-zero status.
* `-x`: After expanding each simple command, for command, case command, select command, or arithmetic for command, display the expanded value of PS4, followed by the command and its expanded arguments or associated word list.
* `-o [option]`/`+o [option]`: Enable/Disable options, option can be:
    * `<none>`: Print all options.
    * `noglob`: Disable pathname expansion (Same as `-f`).
    * `pipefail`: If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully. This option is disabled by de‐fault.
    * `vi/emacs`: vi/emacs mode.
* `-H`: Enable `!` style history substitution
* `--`: If no arguments follow this option, then the positional parameters are unset. Otherwise, the positional parameters are set to the args, even if some of them begin with a `-`

**Examples:**

* `set`: Print all envs and variables.
* `set -e`
* `set -x`
* `set -o pipefail`
* `eval set -- "some new params" && echo "\$1='$1', \$2='$2', \$3='$3'"`: Setup multi-args, seperated by space.
* `set -- "some" "new" "params" && echo "\$1='$1', \$2='$2', \$3='$3'"`: Setup multi-args.
* `set -- "some new params" && echo "\$1='$1', \$2='$2', \$3='$3'"`: Setup one arg.

## 7.4 source

**Two ways of executing `shell script`:**

1. **`./script.sh` or `sh script.sh`**
    * The current `shell` is the parent process, which generates a child `shell` process to execute the script. After the script finishes executing, the child `shell` exits, returning to the current `shell`.
1. **`source script.sh` or `. script.sh`**
    * The script is executed in the current context without generating a new process. After the script finishes executing, it returns to the current `shell`.

**Examples:**

```sh
cat > test.sh << 'EOF'
#!/bin/bash

cd /
EOF

dir=$(pwd)
echo "current dir: '$(pwd)'"

# The current working directory has not been changed
cd ${dir} && bash test.sh && echo "current dir: '$(pwd)' after execute script"

# The current working directory has been changed to /
cd ${dir} && source test.sh && echo "current dir: '$(pwd)' after execute script using source"

cd ${dir}
```

## 7.5 exec

`exec`用于进程替换（类似系统调用`exec`），或者标准输入输出的重定向

**Examples:**

* `exec 1>my.log 2>&1`：将标准输出、以及标准异常重定向到my.log文件中，对后续的所有命令都生效

### 7.5.1 Work with pipe

```sh
#!/bin/bash

# 总数
count=20 

# 并行度
paracount=5 

# $$表示当前执行文件的PID
tempfifo=$$.fifo        

# 捕获信号 2 （ctrl C），并执行相应的动作
trap "exec 1000>&-; exec 1000<&-; exit 0" 2

# 创建fifo
mkfifo ${tempfifo}

# 将文件描述符 1000 分配给 tempfifo
exec 1000<> ${tempfifo}
rm -rf ${tempfifo}

for ((i=1; i<=${paracount}; i++))
do
    # 向文件描述符中输入空行
    echo >&1000
done

for((i=1; i<=${count}; i++))
do
    # 从文件描述符中读取一行
    read -u 1000
    {
        echo "$i, sleep $(($i%5))s"
        sleep $(($i%5))
        echo >&1000
    } &
done

# 等待所有后台任务结束
wait

echo "done"
```

**文件描述符用变量替代的版本1：**

* 在`exec`中用`{}`而不是`${}`来引用变量

```sh
#!/bin/bash

# 总数
count=20 

# 并行度
paracount=5 

# 文件描述符（随意定）
fd_fifo=1000

# $$表示当前执行文件的PID
tempfifo=$$.fifo        

# 捕获信号 2 （ctrl C），并执行相应的动作
trap "exec {fd_fifo}>&-; exec {fd_fifo}<&-; exit 0" 2

# 创建fifo
mkfifo ${tempfifo}

# 将文件描述符 fd_fifo 分配给 tempfifo
exec {fd_fifo}<> ${tempfifo}
rm -rf ${tempfifo}

for ((i=1; i<=${paracount}; i++))
do
    # 向文件描述符中输入空行
    echo >&${fd_fifo}
done

for((i=1; i<=${count}; i++))
do
    # 从文件描述符中读取一行
    read -u ${fd_fifo}
    {
        echo "$i, sleep $(($i%5))s"
        sleep $(($i%5))
        echo >&${fd_fifo}
    } &
done

# 等待所有后台任务结束
wait

echo "done"
```

**文件描述符用变量替代的版本2：**

* 使用`eval`

```sh
#!/bin/bash

# 总数
count=20 

# 并行度
paracount=5 

# 文件描述符（随意定）
fd_fifo=1000

# $$表示当前执行文件的PID
tempfifo=$$.fifo        

# 捕获信号 2 （ctrl C），并执行相应的动作
trap "eval 'exec ${fd_fifo}>&-; exec ${fd_fifo}<&-; exit 0'" 2

# 创建fifo
mkfifo ${tempfifo}

# 将文件描述符 fd_fifo 分配给 tempfifo
eval "exec ${fd_fifo}<> ${tempfifo}"
rm -rf ${tempfifo}

for ((i=1; i<=${paracount}; i++))
do
    # 向文件描述符中输入空行
    echo >&${fd_fifo}
done

for((i=1; i<=${count}; i++))
do
    # 从文件描述符中读取一行
    read -u ${fd_fifo}
    {
        echo "$i, sleep $(($i%5))s"
        sleep $(($i%5))
        echo >&${fd_fifo}
    } &
done

# 等待所有后台任务结束
wait

echo "done"
```

## 7.6 shopt

用于启用/禁用shell扩展功能

**Examples:**

* `shopt -s extglob`：启用`extglob`
* `shopt -u extglob`：禁用`extglob`

## 7.7 read

**Pattern:**

* `read [-ers] [-a name] [-d delim] [-i text] [-n nchars] [-N nchars] [-p prompt] [-t timeout] [-u fd] [name ...]`

**Options:**

`-a`：后跟一个变量，该变量会被认为是个数组，然后给其赋值，**默认是以空格为分割符**
`-d`：后面跟一个标志符，其实只有其后的第一个字符有用，作为结束的标志
`-p`：后面跟提示信息，即在输入前打印提示信息
`-e`：在输入的时候可以使用命令补全功能
`-n`：后跟一个数字，定义输入文本的长度，很实用
`-r`：屏蔽`\`，如果没有该选项，则`\`作为一个转义字符，有的话`\`就是个正常的字符了
`-s`：安静模式，在输入字符时不再屏幕上显示，例如login时输入密码
`-t`：后面跟秒数，定义输入字符的等待时间
`-u`：后面跟fd，从文件描述符中读入，该文件描述符可以是exec新开启的

**简单读取**

```sh
#!/bin/bash

#这里默认会换行  
echo "输入网站名: "  
#读取从键盘的输入  
read website  
echo "你输入的网站名是 $website"  
exit 0  #退出
```

**`-p`参数，允许在`read`命令行中直接指定一个提示**

```sh
#!/bin/bash

read -p "输入网站名:" website
echo "你输入的网站名是 $website" 
exit 0
```

**`-t`参数指定`read`命令等待输入的秒数，当计时满时，`read`命令返回一个非零退出状态**

```sh
#!/bin/bash

if read -t 5 -p "输入网站名:" website
then
    echo "你输入的网站名是 $website"
else
    echo "\n抱歉，你输入超时了。"
fi
exit 0
```

**`-n`参数设置`read`命令计数输入的字符。当输入的字符数目达到预定数目时，自动退出，并将输入的数据赋值给变量**

```sh
#!/bin/bash

read -n1 -p "Do you want to continue [Y/N]?" answer
case $answer in
    Y|y)
      echo "fine ,continue";;
    N|n)
      echo "ok,good bye";;
    *)
     echo "error choice";;
esac
exit 0
```

**`-s`选项能够使`read`命令中输入的数据不显示在命令终端上（实际上，数据是显示的，只是`read`命令将文本颜色设置成与背景相同的颜色）。输入密码常用这个选项**

```sh
#!/bin/bash

read  -s  -p "请输入您的密码:" pass
echo "\n您输入的密码是 $pass"
exit 0
```

**按行读取文件**

```sh
#!/bin/bash
  
count=1    # 赋值语句，不加空格
cat test.txt | while IFS= read -r line      # cat 命令的输出作为read命令的输入,read读到>的值放在line中
do
   echo "Line $count:$line"
   count=$[ $count + 1 ]          # 注意中括号中的空格。
done
echo "finish"
exit 0
```

## 7.8 getopts

**格式：`getopts [option[:]] VARIABLE`**

* `option`：选项，为单个字母
* `:`：如果某个选项（option）后面出现了冒号（`:`），则表示这个选项后面可以接参数
* `VARIABLE`：表示将某个选项保存在变量`VARIABLE`中

`getopts`是linux系统中的一个内置变量，一般用在循环中。每当执行循环时，`getopts`都会检查下一个命令选项，如果这些选项出现
在option中，则表示是合法选项，否则不是合法选项。并将这些合法选项保存在`VARIABLE`这个变量中

`getopts`还包含两个内置变量，及`OPTARG`和`OPTIND`

1. `OPTARG`：选项后面的参数
1. `OPTIND`：下一个选项的索引（该索引是相对于`$*`的索引，因此如果选项有参数的话，索引是非连续的）

**Examples:**：`getopts ":a:bc:" opt`（参数部分：`-a 11 -b -c 5`）

* 第一个冒号表示忽略错误
* 字符后面的冒号表示该选项必须有自己的参数
* `$OPTARG`存储相应选项的参数，如例中的`11`、`5`两个参数
* `$OPTIND`总是存储原始`$*`中下一个要处理的选项的索引（注意不是参数，而是选项），此处指的是`a`,`b`,`c`这三个选项（而不是那些数字，当然数字也是会占有位置的）的索引
    * **`OPTIND`初值为1，遇到`x`（选项不带参数），则`OPTIND += 1`；遇到`x:`（选项带参数），则`OPTARG`=argv[OPTIND+1]，`OPTIND += 2`**

```sh
#!/bin/sh

echo "args: ($@)"
while getopts ":a:bc:" opt
do
    case $opt in
        a)
            echo "option '-a', OPTARG: '${OPTARG}', OPTIND: '${OPTIND}'"
            ;;
        b)
            echo "option '-b', OPTIND: '${OPTIND}'"
            ;;
        c)
            echo "option '-c', OPTIND: '${OPTIND}'"
            ;;
        :)
            echo "option '$OPTARG' must have argument"
            exit 1
            ;;
        ?)
            echo "error"
            exit 1
            ;;
    esac
done
```

```sh
# case0
./testGetopts.sh -f
args: (-f)
error

# case1
./testGetopts.sh -a
args: (-a)
option 'a' must have argument

# case2
./testGetopts.sh -a 5
args: (-a 5)
option '-a', OPTARG: '5', OPTIND: '3'

# case3
./testGetopts.sh -a 5 -b
args: (-a 5 -b)
option '-a', OPTARG: '5', OPTIND: '3'
option '-b', OPTIND: '4'

# case4
./testGetopts.sh -a 5 -b -c 5
args: (-a 5 -b -c 5)
option '-a', OPTARG: '5', OPTIND: '3'
option '-b', OPTIND: '4'
option '-c', OPTIND: '6'

# case5
./testGetopts.sh -a 5 -b -c 5 -b
args: (-a 5 -b -c 5 -b)
option '-a', OPTARG: '5', OPTIND: '3'
option '-b', OPTIND: '4'
option '-c', OPTIND: '6'
option '-b', OPTIND: '7'
```

**注意：如果getopts置于函数内部时，getopts解析的是函数的所有入参，可以通过`$@`将脚本的所有参数传递给函数**

## 7.9 getopt

**格式：`getopt [options] -- parameters`**

**Options:**

* `-o, --options <选项字符串>`：要识别的短选项
    * 单个字符表示选项。例如`-o "abc"`，`a`、`b`、`c`表示3个选项
    * 第一个冒号`:`表示忽略错误
    * 单个字符后接一个冒号`:`，表示该选项后必须跟一个参数，参数紧跟在选项后或者以空格隔开。例如`-o a:bc`，选项`a`必须要有参数，选项`b`、`c`无需参数
    * 单个字符后接两个冒号`::`，表示该选项后必须跟一个参数，且参数必须紧跟在选项后不能以空格隔开。例如`-o a::bc`
* `-a, --alternative`：允许长选项以`-`开始，否则默认长选项要求以`--`开头
* `-l, --longoptions <长选项>`：要识别的长选项
    * **只有`-l`选项，无`-o`选项时，`-l`选项无效（如果没有短选项，可以加上`-o ''`或者`-o ':'`）**
    * 以逗号`,`分隔的长字符串表示选项。例如`-l "along,blong"`，`along`、`blong`表示2个选项
    * **字符串后接一个冒号`:`，表示该选项后必须跟一个参数，参数和选项必须用空格隔开（仅有这一条冒号规则）**
* `-n, --name <程序名>`：将错误报告给的程序名

**输出：getopt会将参数项进行重组和排序，会分成两组，以`--`符号分隔**

1. **`--`之前是合法的`选项`、`参数`集合**
1. **`--`之后是多余的`参数`集合，注意，这里不包含非法`选项`**

```sh
getopt -o 'a' -- -a
#-------------------------↓↓↓↓↓↓-------------------------
 -a --
#-------------------------↑↑↑↑↑↑-------------------------

getopt -o 'a' -- -a 1
#-------------------------↓↓↓↓↓↓-------------------------
 -a -- '1'
#-------------------------↑↑↑↑↑↑-------------------------

getopt -o 'a' -- -b
#-------------------------↓↓↓↓↓↓-------------------------
getopt: invalid option -- 'b'
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 加上第一个:之后，可以忽略错误的选项
getopt -o ':a' -- -b
#-------------------------↓↓↓↓↓↓-------------------------
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 选项和参数紧贴
getopt -o ':a:' -- -a1
#-------------------------↓↓↓↓↓↓-------------------------
 -a '1' --
#-------------------------↑↑↑↑↑↑-------------------------

# 选项和参数以空格分开
getopt -o ':a:' -- -a 1
#-------------------------↓↓↓↓↓↓-------------------------
 -a '1' --
#-------------------------↑↑↑↑↑↑-------------------------

# 选项和参数紧贴
getopt -o ':a::' -- -a1
#-------------------------↓↓↓↓↓↓-------------------------
 -a '1' --
#-------------------------↑↑↑↑↑↑-------------------------

# 选项和'参数'分开，其实'1'并没有被识别为参数
getopt -o ':a::' -- -a 1
#-------------------------↓↓↓↓↓↓-------------------------
 -a '' -- '1'
#-------------------------↑↑↑↑↑↑-------------------------
```

```sh
# 当没有-o选项时，-l无效
getopt -l 'along' -- --along
#-------------------------↓↓↓↓↓↓-------------------------
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 正常case
getopt -o '' -l 'along' -- --along
#-------------------------↓↓↓↓↓↓-------------------------
 --along --
#-------------------------↑↑↑↑↑↑-------------------------

# 没有指定 -a 选项，且选项以 - 开头时
getopt -o '' -l 'along' -- -along
#-------------------------↓↓↓↓↓↓-------------------------
getopt: invalid option -- 'a'
getopt: invalid option -- 'l'
getopt: invalid option -- 'o'
getopt: invalid option -- 'n'
getopt: invalid option -- 'g'
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 传入错误参数，且未忽略错误
getopt -o '' -l 'along' -- --blong
#-------------------------↓↓↓↓↓↓-------------------------
getopt: unrecognized option '--blong'
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 没有指定 -a 选项，且选项以 - 开头，忽略错误
getopt -o ':' -l 'along' -- -along
#-------------------------↓↓↓↓↓↓-------------------------
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 传入错误参数，忽略错误
getopt -o ':' -l 'along' -- --blong
#-------------------------↓↓↓↓↓↓-------------------------
 --
#-------------------------↑↑↑↑↑↑-------------------------

# 必须指定参数，且指定参数，以空格分隔
getopt -o '' -al 'along:' -- -along arg1
#-------------------------↓↓↓↓↓↓-------------------------
 --along 'arg1' --
#-------------------------↑↑↑↑↑↑-------------------------

# 必须指定参数，且未指定参数，未忽略错误
getopt -o '' -al 'along:' -- -along
#-------------------------↓↓↓↓↓↓-------------------------
getopt: option '--along' requires an argument
 --
#-------------------------↑↑↑↑↑↑-------------------------
```

**Examples:**

```sh
cat > test.sh << 'EOF'
#!/bin/bash
 
TEMP=`getopt -o ab:c:: --long a-long,b-long:,c-long:: \
     -n 'example.bash' -- "$@"`
 
if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# 重新设置参数 
eval set -- "$TEMP"
 
while true ; do
        case "$1" in
                -a|--a-long) echo "Option a" ; shift ;;
                -b|--b-long) echo "Option b, argument \`$2'" ; shift 2 ;;
                -c|--c-long)
                        # c has an optional argument. As we are in quoted mode,
                        # an empty parameter will be generated if its optional
                        # argument is not found.
                        case "$2" in
                                "") echo "Option c, no argument"; shift 2 ;;
                                *)  echo "Option c, argument \`$2'" ; shift 2 ;;
                        esac ;;
                --) shift ; break ;;
                *) echo "Internal error!" ; exit 1 ;;
        esac
done
echo "Remaining arguments:"
for arg do
   echo '--> '"\`$arg'" ;
done
EOF

bash test.sh -a -b arg arg1 -c
#-------------------------↓↓↓↓↓↓-------------------------
Option a
Option b, argument `arg'
Option c, no argument
Remaining arguments:
--> `arg1'
#-------------------------↑↑↑↑↑↑-------------------------
```

## 7.10 printf

主要用于格式转换，以及格式化输出，当入参是数组的时候，会对数组的每个元素应用指定的格式化模式

```sh
printf %x 255
#-------------------------↓↓↓↓↓↓-------------------------
ff
#-------------------------↑↑↑↑↑↑-------------------------

items=(1 2 3 4 5)
printf '%d\n' ${items[@]}
#-------------------------↓↓↓↓↓↓-------------------------
1
2
3
4
5
#-------------------------↑↑↑↑↑↑-------------------------

items=("hello" "world")
printf '%s\n' ${items[@]}
#-------------------------↓↓↓↓↓↓-------------------------
hello
world
#-------------------------↑↑↑↑↑↑-------------------------
```

## 7.11 declare

`declare`用于定义变量、增减属性、查看变量信息。若在函数内部使用`declare`，那么默认是`local`的

**格式：`declare [-/+ aAfFgilrtux] [-p] [name[=value] ...]`**

**Options:**

* `-/+`：`-`增加属性，`+`删除属性
    * `a`：数组
    * `A`：map
    * `f`：函数
    * `i`：整数
* `-p`：查看变量信息，包括类型以及值

**Examples:**

```sh
# 查看函数定义
declare -f <function>
# 查看普通变量
declare -p <variable>

# 定义数组
declare -a <array>

# 定义map
declare -A <map>

# 定义整数
declare -i <integer>
```

## 7.12 local

用于在函数内定义局部变量，其作用域就是函数本身

**格式：`local [option] [name[=value] ...]`，其中`option`部分参考`declare`即可**

**Examples:**

```sh
function test() {
    local -a arr
    arr=( 1 2 3 )
    echo "inside function: '${arr[@]}'"
}

test
echo "outside function: '${arr[@]}'"
```

## 7.13 typeset

**功能属于`declare`的子集，不推荐使用**

## 7.14 alias

**`alias`用于设置别名**

**Examples:**

* `alias lh='ls -alt'`
* `alias xxx="${BASE_DIR}/xxx.sh"`，`${BASE_DIR}`的解析发生在配置时，在`zsh`等shell中，`xxx`会高亮
* `alias xxx='${BASE_DIR}/xxx.sh'`，`${BASE_DIR}`的解析发生在执行时，在`zsh`等shell中，`xxx`不会高亮

**How to disable alias: `\cp` will use the original `cp` command, rather than the alias if there exists.**

## 7.15 export

**Examples:**

* `export -p`：打印所有导出的符号
* `export <name>`：导出变量
* `export -f <func_name>`：导出函数

## 7.16 ulimit

设置或查看各类限制

**Examples:**

* `ulimit -a`
* `ulimit -v 1000000`：将进程的最大内存设置为`1000000`字节，仅在当前`shell`以及`shell`的子进程中生效

## 7.17 pushd & popd

`pushd`和`popd`是用于操作目录栈的命令，在切换目录时非常有用。它们可以让你在不同目录之间快速切换，并在需要时返回到先前的目录

**Examples:**

```sh
set -x
pwd
pushd /usr
dirs
pushd /var
dirs
popd
dirs
popd
dirs
```

## 7.18 compgen

The `compgen` command is used to generate possible completions for a given prefix. It can list commands, functions, aliases, and variables that match a given pattern, making it useful for both interactive shell usage and scripting.

**Options:**

* `-c`: List all commands in the PATH.
* `-a`: List all aliases.
* `-b`: List all built-ins.
* `-k`: List all keywords.
* `-A function`: List all functions.
* `-v`: List all shell variables.
* `-e`: List all environment variables.
* `-u`: List all user names.

# 8 Tips

## 8.1 Option Separator

选项分隔符为`--`，它有什么用呢？

举个简单的例子，如何创建一个名为`-f`的目录？`mkdir -f`肯定是不行的，因为`-f`会被当做mkdir命令的选项，此时我们就需要选项分隔符来终止`mkdir`对于后续字符串的解析，即`mkdir -- -f`

## 8.2 Trap Signal

`trap`常用来做一些清理工作，比如你在脚本中将一些进程放到后台执行，但如果脚本异常终止（比如用ctrl+c），那么这些后台进程可能得不到及时处理，这个时候就可以用`trap`来捕获信号，从而执行清理动作

**格式**

* `trap "commands" signal-list`

**注意**

* 如果commands中包含变量，那么该变量在执行`trap`语句时就已解析，而非到真正捕获信号的时候才解析

**示例1**

```sh
# do other things

ping www.baidu.com &

ping_pid=$!
trap "kill -9 ${ping_pid}; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

**示例2（错误），该示例与示例1的差别就是用sudo执行ping命令**

* 这样是没法杀死`ping`这个后台进程的，因为`ping_pid`变量获取到的并不是`ping`的`pid`，而是`sudo`的`pid`

```sh
# do other things

sudo ping www.baidu.com &

ping_pid=$!
trap "kill -9 ${ping_pid}; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

**实例3（对实例2进行调整）**

```sh
# do other things

sudo ping www.baidu.com &

ping_pid=$!
trap "pkill -9 ping; exit 0" SIGINT SIGTERM EXIT

sleep 2
# do other things
```

## 8.3 Color

### 8.3.1  ANSI escape codes

**Color:**

```sh
NOCOLOR='\033[0m'

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'

echo -e ${BLACK} 黑色 ${NOCOLOR}
echo -e ${RED} 红色 ${NOCOLOR}
echo -e ${GREEN} 绿色 ${NOCOLOR}
echo -e ${ORANGE} 橘黄色 ${NOCOLOR}
echo -e ${BLUE} 蓝色 ${NOCOLOR}
echo -e ${PURPLE} 紫色 ${NOCOLOR}
echo -e ${CYAN} 青色 ${NOCOLOR}
echo -e ${LIGHTGRAY} 浅灰色 ${NOCOLOR}
echo -e ${DARKGRAY} 深灰色 ${NOCOLOR}
echo -e ${LIGHTRED} 浅红色 ${NOCOLOR}
echo -e ${LIGHTGREEN} 浅绿色 ${NOCOLOR}
echo -e ${YELLOW} 黄色 ${NOCOLOR}
echo -e ${LIGHTBLUE} 浅蓝色 ${NOCOLOR}
echo -e ${LIGHTPURPLE} 浅紫色 ${NOCOLOR}
echo -e ${LIGHTCYAN} 浅青色 ${NOCOLOR}
echo -e ${WHITE} 白色 ${NOCOLOR}
```

**Cursor Position:**

```sh
RED="\033[0;31m"
NOCOLOR="\033[0m"

CURSOR_MOVE_STRAIGHT_UP="\033[A"
CURSOR_MOVE_STRAIGHT_DOWN="\033[B"
CURSOR_MOVE_STRAIGHT_RIGHT="\033[C"
CURSOR_MOVE_STRAIGHT_LEFT="\033[D"
CURSOR_MOVE_DOWN_HEAD="\033[E"
CURSOR_MOVE_UP_HEAD="\033[F"

echo -e "Line 1: Initial output"
echo -e "Line 2: Initial output"
echo -e "Line 3: Initial output"
echo -en "Line 4: Initial output"

function fallback_PROMPT() {
    local prompt=$1
    local len=${#prompt}
    for ((i=0;i<len;i++)) do
        echo -en "${CURSOR_MOVE_STRAIGHT_LEFT}"
    done
}

CONTENT="${RED}NEW_CONTENT_HERE!!!${NOCOLOR}"

sleep 2
PROMPT="Moving up two line";
echo -n "${PROMPT}"
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_STRAIGHT_UP}${CURSOR_MOVE_STRAIGHT_UP}${CONTENT}"

sleep 2
PROMPT="Moving down one line";
echo -n "${PROMPT}"
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_STRAIGHT_DOWN}${CONTENT}"

sleep 2
PROMPT="Moving right one column";
echo -n "${PROMPT}";
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_STRAIGHT_RIGHT}${CONTENT}"

sleep 2
PROMPT="Moving left one column";
echo -n "${PROMPT}"
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_STRAIGHT_LEFT}${CONTENT}"

sleep 2
PROMPT="Moving to the 2 previous line head";
echo -n "${PROMPT}"
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_UP_HEAD}${CURSOR_MOVE_UP_HEAD}${CONTENT}"

sleep 2
PROMPT="Moving to the next line head";
echo -n "${PROMPT}"
sleep 2
fallback_PROMPT "${PROMPT}"
echo -en "${CURSOR_MOVE_DOWN_HEAD}${CONTENT}"

echo -e "Done"
```

### 8.3.2 tput

**设置颜色：**

```sh
tput setab [1-7] # Set the background colour using ANSI escape
tput setaf [1-7] # Set the foreground colour using ANSI escape
```

其中颜色编号表如下：

```
Num  Colour    #define         R G B

0    black     COLOR_BLACK     0,0,0
1    red       COLOR_RED       1,0,0
2    green     COLOR_GREEN     0,1,0
3    yellow    COLOR_YELLOW    1,1,0
4    blue      COLOR_BLUE      0,0,1
5    magenta   COLOR_MAGENTA   1,0,1
6    cyan      COLOR_CYAN      0,1,1
7    white     COLOR_WHITE     1,1,1
```

**样式设置：**

```sh
tput bold    # Select bold mode
tput dim     # Select dim （half-bright） mode
tput smul    # Enable underline mode
tput rmul    # Disable underline mode
tput rev     # Turn on reverse video mode
tput smso    # Enter standout （bold） mode
tput rmso    # Exit standout mode
```

**其他：**

```sh
tput sgr0    # Reset text format to the terminal's default
tput bel     # Play a bell
```

**Examples:**

```sh
tput setaf 1; tput setab 2; tput bold; echo "this is text"
```

## 8.4 Assorted

### 8.4.1 What is globbing

`Globbing` is a term used in Unix-like operating systems, including Linux and macOS, to refer to the process of pattern matching or wildcard expansion used by the shell to match filenames and paths.

When you use wildcards in the command line or in a shell script, the shell automatically expands these patterns to match files and directories in the filesystem. This process is called `globbing`.

### 8.4.2 `${var}` vs. `"${var}"`

`${var}`: Word splitting and globbing are performed, so spaces in `var` may cause it to be split into multiple words or match filenames in the current directory.
`"${var}"`: Treats `var` as a single string, preserving spaces and special characters without splitting or globbing.

```sh
content="a b c"
for word in ${content}; do
    echo $word
done

content="a b c"
for word in "${content}"; do
    echo $word
done
```

### 8.4.3 Multi-line String

```sh
content=$(cat <<EOF
This is a multi-line
string in a shell script.
EOF
)

echo "${content}"
```

### 8.4.4 How to disable expansion of `*`/`?`

```sh
set -o | grep noglob
set -f # disable
set +f # enable
```

### 8.4.5 How to remove both first line and last line

```sh
cat xxx.txt | sed '1d;$d'
```

### 8.4.6 How to display invisible characters in file

```sh
cat -v xxx.txt
```

# 9 Reference

* [shell教程](http://www.runoob.com/linux/linux-shell.html)
* [linux exec与重定向](http://xstarcd.github.io/wiki/shell/exec_redirect.html)
* [Shell脚本8种字符串截取方法总结](https://www.jb51.net/article/56563.htm)
* [shell的命令替换和命令组合](https://www.cnblogs.com/f-ck-need-u/archive/2017/08/20/7401591.html)
* [shell脚本--数值计算](https://www.cnblogs.com/-beyond/p/8232496.html)
* [Linux—shell中`$(())`、`$()`与`${}`的区别](https://www.cnblogs.com/chengd/p/7803664.html)
* [shell中各种括号的作用`()`、`(())`、`[]`、`[[]]`、`{}`](https://www.cnblogs.com/fengkui/p/6122702.html)
* [shell特殊符号用法大全](https://www.cnblogs.com/guochaoxxl/p/6871619.html)
* [shell的getopts命令](https://www.jianshu.com/p/baf6e5b7e70a)
* [如何获取后台进程的PID？](https://www.liangzl.com/get-article-detail-168597.html)
* [shell——trap捕捉信号（附信号表）](https://www.cnblogs.com/maxgongzuo/p/6372898.html)
* [Shell进程替换](http://c.biancheng.net/view/3025.html)
* [Bash scripting cheatsheet](https://devhints.io/bash)
* [how-to-trim-whitespace-from-a-bash-variable](https://stackoverflow.com/questions/369758/how-to-trim-whitespace-from-a-bash-variable)
* [How to change the output color of echo in Linux](https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux)
* [jonsuh/.bash_profile](https://gist.github.com/jonsuh/3c89c004888dfc7352be)
* [shell并行执行程序](https://blog.csdn.net/d2457638978/article/details/80178847)
* [How to use a variable to indicate a file descriptor in bash?](https://stackoverflow.com/questions/8295908/how-to-use-a-variable-to-indicate-a-file-descriptor-in-bash)
