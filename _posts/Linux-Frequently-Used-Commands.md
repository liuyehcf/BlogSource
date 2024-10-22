---
title: Linux-Frequently-Used-Commands
date: 2017-08-15 20:17:57
top: true
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 System Information

## 1.1 lsb_release

查看发行版信息（lsb, Linux Standard Base），其他查看发行版的方式还包括：

1. `uname -r`：内核版本号
1. `/etc/*-release`，包括
    * `/etc/os-release`
    * `/etc/centos-release`
    * `/etc/debian_version`
1. `/proc/version`

## 1.2 uname

**Pattern:**

* `uname [option]`

**Options:**

* `-a, --all`：以如下次序输出所有信息。其中若`-p`和`-i`的探测结果不可知则被省略：
* `-s, --kernel-name`：输出内核名称
* `-n, --nodename`：输出网络节点上的主机名
* `-r, --kernel-release`：输出内核发行号
* `-v, --kernel-version`：输出内核版本
* `-m, --machine`：输出主机的硬件架构名称
* `-p, --processor`：输出处理器类型或"unknown"
* `-i, --hardware-platform`：输出硬件平台或"unknown"
* `-o, --operating-system`：输出操作系统名称

**Examples:**

* `uname -a`
* `uname -r`
* `uname -s`

## 1.3 dmidecode

**Examples:**

* `sudo dmidecode -s system-manufacturer`
* `sudo dmidecode -s system-product-name`

## 1.4 systemd-detect-virt

用于判断当前机器是物理机还是虚拟机

**Examples:**

* `systemd-detect-virt`
    * `none`：物理机
    * `qemu/kvm/...`：虚拟机

## 1.5 demsg

kernel会将开机信息存储在`ring buffer`中。您若是开机时来不及查看信息，可利用`dmesg`来查看。开机信息亦保存在`/var/log`目录中，名称为dmesg的文件里

**Examples:**

* `dmesg -TL`
* `dmesg --level=warn,err`

## 1.6 chsh

**Pattern:**

* `chsh [-ls]`

**Options:**

* `-s`: The name of the user's new login shell.

**Examples:**

* `chsh -s /bin/zsh`: Change login shell for current user.
* `chsh -s /bin/zsh test`: Change login shell for user test.

## 1.7 man

* `man 1`：标准Linux命令
* `man 2`：系统调用
* `man 3`：库函数
* `man 4`：设备说明
* `man 5`：文件格式
* `man 6`：游戏娱乐
* `man 7`：杂项
* `man 8`：系统管理员命令
* `man 9`：常规内核文件

## 1.8 last

**Examples:**

* `last -x`

## 1.9 who

该命令用于查看当前谁登录了系统，并且正在做什么事情

**Examples:**

* `who`
* `who -u`

## 1.10 w

该命令用于查看当前谁登录了系统，并且正在做什么事情，比`who`更强大一点

**Examples:**

* `w`

## 1.11 which

**Examples:**

* `which -a ls`

## 1.12 whereis

**Examples:**

* `whereis ls`

## 1.13 file

The file command is used to determine the type of a file. It does this by examining the file's content, rather than relying on its file extension. This command is useful for identifying various file types, such as text files, executable files, directories, etc.

**Examples:**

* `file ~/.bashrc`
* `file $(which ls)`

## 1.14 type

The type command is used to describe how its arguments would be interpreted if used as command names. It indicates if a command is built-in, an alias, a function, or an external executable. This command is helpful for understanding how a particular command is being resolved and executed by the shell.

**Examples:**

* `type ls`

## 1.15 command

The command command is used to execute a command, ignoring shell functions and aliases. It ensures that the original external command is executed, which can be useful if a command name has been redefined as a function or an alias.

* `command -v ls`
* `command -V ls`
* Difference between `ls` and `comomand ls`
    ```sh
    alias ls='ls --color=auto -l'
    ls # execute the alias
    command ls # execute the original command
    ```

## 1.16 stat

The command stat is used to display file or file system status.

**Examples:**

* `stat <file>`

## 1.17 useradd

**Options:**

* `-g`：指定用户组
* `-G`：附加的用户组
* `-d`：指定用户目录
* `-m`：自动创建用户目录
* `-s`：指定shell

**Examples:**

* `useradd test -g wheel -G wheel -m -s /bin/bash`
* `useradd test -d /data/test -s /bin/bash`

**`useradd`在创建账号时执行的步骤**

1. 新建所需要的用户组：`/etc/group`
1. 将`/etc/group`与`/etc/gshadow`同步：`grpconv`
1. 新建账号的各个属性：`/etc/passwd`
1. 将`/etc/passwd`与`/etc/shadow`同步：`pwconv`
1. 新建该账号的密码，`passwd <name>`
1. 新建用户主文件夹：`cp -a /etc/sekl /home/<name>`
1. 更改用户文件夹的属性：`chown -R <group>/home/<name>`

### 1.17.1 Migrate User Directory

```sh
# 拷贝数据
rsync -avzP <old_dir> <new_dir>

# 切换到root
sudo su

# 更新用户目录
usermod -d <new_dir> <username>
```

## 1.18 userdel

**Options:**

* `-r`：删除用户主目录

**Examples:**

* `userdel -r test`

## 1.19 usermod

**Options:**

* `-d`：修改用户目录
* `-s`：修改shell

**Examples:**

* `usermod -s /bin/zsh admin`：修改指定账号的默认shell
* `usermod -d /opt/home/admin admin`：修改指定账号的用户目录
    * 注意，新的路径最后不要加`/`，例如，不要写成`/opt/home/admin/`，这样会导致`zsh`无法将用户目录替换成`~`符号，这样命令行提示符中的路径就会是绝对路径，而不是`~`了
* `sudo usermod -aG docker username`：给指定用户增加用户组，要重新登录才能生效
    * `groups username`：查看用户组

## 1.20 chown

**Examples:**

* `chown [-R] 账号名称 文件或目录`
* `chown [-R] 账号名称:用户组名称 文件或目录`

## 1.21 passwd

**Examples:**

* `echo '123456' | passwd --stdin root`

## 1.22 chpasswd

**Examples:**

* `echo 'username:password' | sudo chpasswd`

## 1.23 id

用于查看用户信息，包括`uid`，`gid`等

**Examples:**

* `id`：查看当前用户的信息
* `id <username>`：查看指定用户的信息
* `id -u`：查看当前用户的uid
* `id -nu <uid>`：查看指定uid对应的用户名

## 1.24 getconf

查看系统相关的信息

**Examples:**

* `getconf -a | grep CACHE`：查看CPU cache相关的配置项

## 1.25 hostnamectl

**Examples:**

```sh
hostnamectl set-hostname <name>
```

## 1.26 date

**Examples:**

* `date`
* `date "+%Y-%m-%d %H:%M:%S"`
* `date -s '2014-12-25 12:34:56'`: Change system time.

## 1.27 timedatectl

**Examples:**

* `timedatectl`: Show time info
* `timedatectl set-timezone Asia/Shanghai`: Change timezone

## 1.28 ntpdate

**Examples:**

* `ntpdate ntp.aliyun.com`
* `ntpdate ntp.cloud.aliyuncs.com`：阿里云ecs同步时间需要指定内网的ntp服务

## 1.29 hexdump

Display file contents in hexadecimal, decimal, octal, or ascii

**Examples:**

* `hexdump -C <filename> | head -n 10`

## 1.30 showkey

Examine the codes sent by the keyboard

**Examples:**

* `showkey -a`

# 2 Common Processing Tools

## 2.1 ls

**Options:**

* `-a`: do not ignore entries starting with `.`.
* `-l`: use a long listing format.
* `-t`: sort by time, newest first; see `--time`.
* `-S`: sort by file size, largest first.
* `-r`: reverse order while sorting.
* `-h`: with `-l` and `-s`, print sizes like `1K` `234M` `2G` etc.
* `-I`: do not list implied entries matching shell PATTERN.
* `-1`: list one file per line.

**Examples:**

* `ls -1`
* `ls -lht | head -n 5`
* `ls -lhtr`
* `ls -lhS`
* `ls *.txt`: Find all files with the `.txt` extension, and note that you should not use `ls "*.txt"`.
* `ls -I "*.txt" -I "*.cpp"`
* `ls -d */`: List all subdirectories in the current directory.

## 2.2 echo

**Pattern:**

* `echo [-ne] [字符串/变量]`
* `''`中的变量不会被解析，`""`中的变量会被解析

**Options:**

* `-n`：不要在最后自动换行
* `-e`：打开反斜杠ESC转义。若字符串中出现以下字符，则特别加以处理，而不会将它当成一般文字输出
    * `\a`：发出警告声
    * `\b`：删除前一个字符
    * `\c`：最后不加上换行符号
    * `\f`：换行但光标仍旧停留在原来的位置
    * `\n`：换行且光标移至行首
    * `\r`：光标移至行首，但不换行
    * `\t`：插入tab
    * `\v`：与\f相同
    * `\\`：插入\字符
    * `\nnn`：插入nnn（八进制）所代表的ASCII字符

**Examples:**

* `echo ${a}`
* `echo -e "a\nb"`
* `echo -e "\u67e5\u8be2\u5f15\u64ce\u5f02\u5e38\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5\u6216\u8054\u7cfb\u7ba1\u7406\u5458\u6392\u67e5\u3002"`：`Unicode`转`UTF-8`

**其他：**

* **颜色控制，控制选项说明：** 
    ```sh
    echo -e "\033[30m 黑色字 \033[0m"
    echo -e "\033[31m 红色字 \033[0m"
    echo -e "\033[32m 绿色字 \033[0m"
    echo -e "\033[33m 黄色字 \033[0m"
    echo -e "\033[34m 蓝色字 \033[0m"
    echo -e "\033[35m 紫色字 \033[0m"
    echo -e "\033[36m 天蓝字 \033[0m"
    echo -e "\033[37m 白色字 \033[0m"

    echo -e "\033[40;37m 黑底白字 \033[0m"
    echo -e "\033[41;37m 红底白字 \033[0m"
    echo -e "\033[42;37m 绿底白字 \033[0m"
    echo -e "\033[43;37m 黄底白字 \033[0m"
    echo -e "\033[44;37m 蓝底白字 \033[0m"
    echo -e "\033[45;37m 紫底白字 \033[0m"
    echo -e "\033[46;37m 天蓝底白字 \033[0m"
    echo -e "\033[47;30m 白底黑字 \033[0m"
    ```

* 如何输出带有`*`的文本
    * [Printing asterisk ("*") in bash shell](https://stackoverflow.com/questions/25277037/printing-asterisk-in-bash-shell)
    * `content="*"; echo ${content}`：`*`会被`sh/bash`（`zsh`不会）替换为当前路径下的所有文件和目录
    * `content="*"; echo "${content}"`：加引号后，正常输出字符`*`

## 2.3 sed

**Pattern:**

* `sed [-nefr] [动作] [文件]`
* `STD IN | sed [-nefr] [动作]`

**Options:**

* **`-n`**: Use silent mode. In standard sed, all data from `STDIN` is usually displayed on the screen. With the `-n` parameter, only lines specially processed by sed will be displayed.
* **`-e`**: Edit sed actions directly on the command line.
* **`-f`**: Write sed actions in a file, and `-f filename` can execute the sed actions in the filename.
* **`-E/-r`**: Sed actions support extended regular expression syntax.
    * **Without the `-r` parameter, even `()` needs to be escaped, so it's best to add the `-r` parameter.**
    * `\0`: Represents the entire matching string, `\1` represents group1, and so on.
    * `&`: Represents the entire matching string.
* **`-i`**: Modify the file content directly instead of outputting it to the screen.

**Action Format:**

* **`<action>`: Applies to all lines.**
    * `echo -e "a1\na2\nb1\nb2\n" | sed 's/[0-9]//g'`
* **`/<pattern>/<action>`: Applies to lines matching `<pattern>`.**
    * `echo -e "a1\na2\nb1\nb2\n" | sed '/a/s/[0-9]//g'`
* **`<n1>[,<n2>]<action>`: Applies to lines from `<n1>` to `<n2>` (if `<n2>` is not provided, it applies only to `<n1>`).**
    * **`$` represents the last line.**
    * **`/<pattern1>/, /<pattern2>/`: From the first line matching `<pattern1>` to the first line matching `<pattern2>`.**
    * **To use other symbols as separators, the first symbol needs to be escaped, e.g., `\|<pattern1>|` and `\|<pattern1>|, \|<pattern2>|`.**
    * `echo -e "a1\na2\nb1\nb2\n" | sed '1s/[0-9]//g'`
    * `echo -e "a1\na2\nb1\nb2\n" | sed '1,3s/[0-9]//g'`
    * `echo -e "a1\na2\nb1\nb2\n" | sed '/a/,/b/s/[0-9]//g'`
* **`/<pattern>/{<n1>[,<n2>]<action>}`: Applies to lines from `<n1>` to `<n2>` that match `<pattern>` (if `<n2>` is not provided, it applies only to `<n1>`).**
    * `echo -e "a1\na2\nb1\nb2\n" | sed '/a/{1,3s/[0-9]//g}'`
* **`<n1>[,<n2>]{/<pattern>/<action>}`: Applies to lines from `<n1>` to `<n2>` that match `<pattern>` (if `<n2>` is not provided, it applies only to `<n1>`).**
    * `echo -e "a1\na2\nb1\nb2\n" | sed '1,3{/a/s/[0-9]//g}'`
* **`!`: Negates the match.**
    * `echo -e "a1\na2\nb1\nb2\n" | sed '/a/!s/[0-9]//g'`
    * `echo -e "a1\na2\nb1\nb2\n" | sed '/a/!{1,3s/[0-9]//g}'`
    * `echo -e "a1\na2\nb1\nb2\n" | sed '1,3{/a/!s/[0-9]//g}'`

**Action Explanation:**

* **`a`**: Append. Strings following `a` will appear on a new line (the next line of the current line).
* **`c`**: Change. Strings following `c` can replace the lines between `n1` and `n2`.
* **`d`**: Delete. Usually followed by no parameters.
* **`i`**: Insert. Strings following `i` will appear on a new line (the previous line of the current line).
* **`p`**: Print. Prints selected data, usually run with the `sed -n` parameter.
* **`s`**: Substitute. Performs substitution, usually with regular expressions, e.g., `1,20s/lod/new/g`.
    * **The separator can be `/` or `|`.**
    * **If the separator is `/`, ordinary `|` does not need to be escaped, but `/` does.**
    * **If the separator is `|`, ordinary `/` does not need to be escaped, but `|` does.**
    * `g`: Replaces all occurrences in each line, otherwise only the first occurrence.
    * `I`: Case-insensitive.
* **`r`**: Insert the contents of another text.

**Examples:**

* **`a`**：

```sh
echo -e "a\nb\nc" | sed '1,2anewLine'

# 输出如下
a
newLine
b
newLine
c
```

* **`c`**：

```sh
# /^a$/通过正则表达式匹配第一行，需要配合-r参数
echo -e "a\nb\nc" | sed -r '/^a$/,2cnewLine'

# 输出如下
newLine
c
```

* **`d`**：

```sh
# 删除第2行，到第一个包含字符'c'的行
echo -e "a\nb\nc" | sed '2,/c/d'

# 删除最后一行
echo -e "a\nb\nc" | sed '$d'

# 删除第一个包含字符'a1'的行 到 第一个包含字符'a2'的行 之间的内容
echo -e "a0\na1\na1\na1\nb1\nb2\na2\na2\na2\na3" | sed '/a1/, /a2/d'

# 输出如下
a
```

* **`i`**：

```sh
echo -e "a\nb\nc" | sed '1,2inewLine'

# 输出如下
newLine
a
newLine
b
c

echo -e "a\nb\nc" | sed '1inewLine'

# 输出如下
newLine
a
b
c
```

* **`p`**：

```sh
# $表示最后一行
echo -e "a\nb\nc" | sed -n '/b/,$p'

# 输出如下
b
c

# 利用正则表达式输出指定内容
echo -e '<a href="https://www.baidu.com">BaiDu</a>' | sed -rn 's/^.*<a href="(.*)">.*$/\1/p'

# 输出如下
https://www.baidu.com

# 输出指定行
echo -e "a\nb\nc\nd" | sed -n '1,3p'

# 输出如下
a
b
c
```

* **`s`**：

```sh
# 作用于所有行，对于每一行，将第一个a替换为A
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/'

# 作用于所有行，对于每一行，将所有a替换为A
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/g'

# 作用于所有行，对于每一行，将所有a替换为A，并打印出来
echo -e "abcabc\nbcabca\ncabcab" | sed -n 's/a/A/gp'

# 作用于第一行到第三行，对于所有第三个字符为a的串，删掉字符a，保留前两个字符
# /^abc/匹配第一个以abc开头的行，/cab$/匹配第一个以cab结尾的行
# 以下两个等价，分隔符可以用'/'，可以用'|'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s/(..)a/\1/gp'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s|(..)a|\1|gp'

# 作用于最后一行，对于所有串loverable，替换成lovers
echo -e "loverable" | sed -nr '$s/(love)rable/\1rs/gp'

# 将/root/替换为/，下面两个等价
echo "/root/document/file.txt" | sed -nr 's|/root/|/|p'     # 此时'/'不需要转义，因为分隔符是'|'
echo "/root/document/file.txt" | sed -nr 's/\/root\//\//p'  # 此时'/'需要转义，因为分隔符也是'/'（看起来就不直观）

# 将所有a或b替换成A，下面两个等价
echo "abc" | sed -nr 's/a|b/A/gp'   # 此时'|'不需要转义，因为分隔符是'/'
echo "abc" | sed -nr 's|a\|b|A|gp'  # 此时'|'需要转义，因为分隔符是'|'
```

* **`r`：**

```sh
# 准备文件1
cat > file1.txt << EOF
<html>
<body>
<tag>
</tag>
</body>
</html>
EOF

# 准备文件2
cat > file2.txt << EOF
Hello world!!
EOF

sed '/<tag>/ r file2.txt' file1.txt
```

* **`reverse match`：**

```sh
echo -e "a\nb\nc\nd\ne" | sed '/a/!d'

echo -e "a\nb\nc\nd\ne" | sed '/a/!s/b/B/g'

# "!s" inside " will trigger history expansion
# turn off history expansion
set +H
echo -e "a\nb\nc\nd\ne" | sed "/a/!d"

echo -e "a\nb\nc\nd\ne" | sed "/a/!s/b/B/g"
# turn on history expansion

set -H
```

**注意**：在macOS中，`-i`参数后面要跟一个扩展符，用于备份源文件。如果扩展符长度是0，那么不进行备份

* `sed -i ".back" "s/a/b/g" example`：备份文件为`example.back`
* `sed -i "" "s/a/b/g" example`：不备份

## 2.4 awk

Compared to `sed` (a pipeline command) which often acts on an entire line, `awk` (a pipeline command) tends to split a line into several "fields" for processing, making `awk` quite suitable for small-scale data processing.

**Pattern:**

* `awk [-F] '[/regex/] [condition] {action}' [filename]`

**Options:**

* `-F`: Specifies the delimiter. For example: `-F ':'`, `-F '[,.;]'`, `-F '[][]'`

Note that all subsequent actions in `awk` are enclosed in single quotes, and when printing with `print`, non-variable text, including formats (like tab `\t`, newline `\n`, etc.), must be defined in double quotes since single quotes are reserved for `awk` commands. For example, `last -n 5 | awk '{print $1 "\t" $3}'`.

**`awk` Processing Flow:**

1. Reads the first line.
    * **If it contains a regular expression match (`[/regex/]`), it skips the line if there is no match. If it matches (any substring), the first line's data is assigned to variables like `$0`, `$1`, etc.**
    * If there is no regex match, the first line's data is assigned to `$0`, `$1`, etc.
2. Based on the condition type, determines if subsequent actions need to be performed.
3. Executes all actions and condition types.
4. If there are more lines, repeats the steps above until all data is processed.

**`awk` Built-in Variables:**

* `ARGC`: Number of command-line arguments.
* `ARGV`: Command-line argument array.
* `ENVIRON`: Access to system environment variables in a queue.
* `FILENAME`: Name of the file `awk` is processing.
* `FNR`: Record number within the current file.
* **`FS`**: Input field separator, default is a space, equivalent to the command-line `-F` option.
* **`NF`**: Total number of fields in each line (`$0`).
* **`NR`**: Line number currently being processed by `awk`.
* `OFS`: Output field separator.
* `ORS`: Output record separator.
* `RS`: Record separator.
* These variables can be referenced within actions without `$`, for example, `last -n 5 | awk '{print $1 "\t  lines: " NR "\t columns: " NF}'`.
* Additionally, the `$0` variable refers to the entire record. `$1` represents the first field of the current line, `$2` the second field, and so on.

**`awk` Built-in Functions**

* `sub(r, s [, t])`: Replaces the first occurrence of the regular expression `r` in string `t` with `s`. By default, `t` is `$0`.
* `gsub(r, s [, t])`: Replaces all occurrences of the regular expression `r` in string `t` with `s`. By default, `t` is `$0`.
* `gensub(r, s, h [, t])`: Replaces the regular expression `r` in string `t` with `s`. By default, `t` is `$0`.
    * `h`: If it starts with `g/G`, behaves like `gsub`.
    * `h`: A number, replaces the specified occurrence.
* `tolower(s)`: Converts every character in string `s` to lowercase.
* `toupper(s)`: Converts every character in string `s` to uppercase.
* `length(s)`: Returns the length of the string.
* `split(s, a [, r [, seps] ])`: Split the string s into the array a and the separators array seps on the regular expression r, and return the number of fields. If r is omitted, `FS` is used instead.
* `strtonum(s)`: Examine str, and return its numeric value. If str begins with a leading `0x` or `0X`, treat it as a hexadecimal number.
    * `echo 'FF' | awk '{ print strtonum("0x"$0) }'`
* `print` vs. `printf`: `print expr-list` prints with a newline character, `printf fmt, expr-list` does not print a newline character.
    * `cat /etc/passwd | awk '{FS=":"} $3<10 {print $1 "\t" $3}'`: **Note that `{FS=":"}` acts as an action, so the delimiter changes to `:` from the second line onward; for the first line, the delimiter is still a space.**
    * `cat /etc/passwd | awk 'BEGIN {FS=":"} $3<10 {print $1 "\t" $3}'`: **Here, `{FS=":"}` is effective for the first line.**
    * `echo -e "abcdefg\nhijklmn\nopqrst\nuvwxyz" | awk '/[au]/ {print $0}'`.
    * `lvdisplay|awk  '/LV Name/{n=$3} /Block device/{d=$3; sub(".*:","dm-",d); print d,n;}'`:
        * There are two actions, each with its own condition: one contains `LV Name`, and the other contains `Block device`. Each condition executes its corresponding action if met; if both are satisfied, both actions are executed (in this case, simultaneous satisfaction is impossible).
        * First, match the first condition; `n` stores the volume group name, assumed to be `swap`.
        * Next, match the second condition; `d` stores the disk name, assumed to be `253:1`. Using the `sub` function, replace `253:` with `dm-`, resulting in `d` being `dm-1`. Print `d` and `n`.
        * Then, match the first condition; `n` stores the volume group name, assumed to be `root`. The content of `d` is still `dm-1`.
        * Finally, match the second condition; `d` stores the disk name, assumed to be `253:0`. Using the `sub` function, replace `253:` with `dm-`, resulting in `d` being `dm-0`. Print `d` and `n`.

**Action Descriptions:**

* In `awk`, any action inside `{}` can be separated by a semicolon `;` if multiple commands are needed, or they can be separated by pressing the `Enter` key.

**`BEGIN` and `END`:**

* In Unix `awk`, two special expressions are `BEGIN` and `END`. These can be used in patterns (refer to the `awk` syntax mentioned earlier). **`BEGIN` and `END` give the program initial states and allow it to perform final tasks after scanning is complete.**
* **Any operation listed after `BEGIN` (inside `{}`) is executed before `awk` starts scanning the input, and operations listed after `END` are executed after all input has been scanned.** Therefore, `BEGIN` is usually used to display and initialize variables, and `END` is used to output the final result.

### 2.4.1 Using Shell Variables

**Method 1:**

* Surround the shell variable with `'"` and `"'` (i.e., single quote + double quote + shell variable + double quote + single quote).
* **This method can only reference numerical variables.**

```sh
var=4
awk 'BEGIN{print '"$var"'}'
```

**Method 2:**

* Surround the shell variable with `"'` and `'"` (i.e., double quote + single quote + shell variable + single quote + double quote).
* **This method can reference string variables, but the string cannot contain spaces.**

```sh
var=4
awk 'BEGIN{print "'$var'"}'
var="abc"
awk 'BEGIN{print "'$var'"}'
```

**Method 3:**

* Surround the shell variable with `"'"` (i.e., double quote + single quote + double quote + shell variable + double quote + single quote + double quote).
* **This method allows referencing variables of any type.**

```sh
var=4
awk 'BEGIN{print "'"$var"'"}'
var="abc"
awk 'BEGIN{print "'"$var"'"}'
var="this a test"
awk 'BEGIN{print "'"$var"'"}'
```

**Method 4:**

* Use the `-v` parameter. This method is quite simple and clear when there are not many variables.

```sh
var="this a test"
awk -v awkVar="$var" 'BEGIN{print awkVar}'
```

### 2.4.2 Control Statements

All of the following examples are in `BEGIN` and are executed only once, without the need to specify a file or input stream.

**`if` Statement:**

```sh
awk 'BEGIN{ 
test=100;
if(test>90)
{
    print "very good";
}
else if(test>60)
{
    print "good";
}
else
{
    print "no pass";
}
}'
```

**`while` Statement:**

```sh
awk 'BEGIN{ 
test=100;
total=0;
while(i<=test)
{
    total+=i;
    i++;
}
print total;
}'
```

**`for` Statement:**

```sh
awk 'BEGIN{ 
for(k in ENVIRON)
{
    print k"="ENVIRON[k];
}
}'

awk 'BEGIN{ 
total=0;
for(i=0;i<=100;i++)
{
    total+=i;
}
print total;
}'
```

**`do` Statement:**

```sh
awk 'BEGIN{ 
total=0;
i=0;
do
{
    total+=i;
    i++;
}while(i<=100)
print total;
}'
```

### 2.4.3 Regular Expressions

```sh
echo "123" | awk '{if($0 ~ /^[0-9]+$/) print $0;}'
```

## 2.5 cut

**Pattern:**

* `cut -b list [-n] [file ...]`
* `cut -c list [file ...]`
* `cut -f list [-s] [-d delim] [file ...]`

**Options:**

* `list`：范围
    * `N`：从第1个开始数的第N个字节、字符或域
    * `N-`：从第N个开始到所在行结束的所有字符、字节或域
    * `N-M`：从第N个开始到第M个之间(包括第M个)的所有字符、字节或域
    * `-M`：从第1个开始到第M个之间(包括第M个)的所有字符、字节或域
* `-b`：以字节为单位进行分割。这些字节位置将忽略多字节字符边界，除非也指定了`-n`标志
* `-c`：以字符为单位进行分割
* `-d`：自定义分隔符，默认为制表符
* `-f`：与`-d`一起使用，指定显示哪个区域
* `-n`：取消分割多字节字符。仅和`-b`标志一起使用。如果字符的最后一个字节落在由`-b`标志的`List`参数指示的范围之内，该字符将被写出；否则，该字符将被排除

**Examples:**

* `echo "a:b:c:d:e" | cut -d ":" -f3`：输出c
* `ll | cut -c 1-10`：显示查询结果的 1-10个字符

## 2.6 grep

grep searches for `PATTERNS` in each `FILE`

**Pattern:**

```sh
       grep [OPTION...] PATTERNS [FILE...]
       grep [OPTION...] -e PATTERNS ... [FILE...]
       grep [OPTION...] -f PATTERN_FILE ... [FILE...]
```

**Options:**

* `-c`: Suppress normal output; instead print a count of matching lines for each input file.
* `-i`: Ignore case distinctions in patterns and input data, so that characters that differ only in case match each other
* `-e`: Use `PATTERNS` as the patterns
* `-E`: Interpret PATTERNS as extended regular expressions
* `-F`: Interpret PATTERNS as fixed strings, not regular expressions
* `-P`: Interpret PATTERNS as Perl-compatible regular expressions
* `-l`: Suppress normal output; instead print the name of each input file from which output would normally have been printed. Scanning each input file stops upon first match.
* `-n`: Prefix each line of output with the 1-based line number within its input file.
* `-v`: Invert the sense of matching, to select non-matching lines.
* `-r`: Read all files under each directory, recursively, following symbolic links only if they are on the command line.
* `--color=auto|never|always`: Surround the matched (non-empty) strings, matching lines, context lines, file names, line numbers, byte offsets, and separators (for fields and groups of context lines) with escape sequences to display them in color on the terminal. The colors are defined by the environment variable GREP_COLORS. Can be never, always, or auto.
* `-A <NUM>`：Print `NUM` lines of trailing context after matching lines.
* `-B <NUM>`: Print `NUM` lines of leading context before matching lines.
* `-C <NUM>`: Print `NUM` lines of output context
* `--binary-files=<TYPE>`: If a file's data or metadata indicate that the file contains binary data, assume that the file is of type `TYPE`.
    * If `TYPE` is `without-match`, when grep discovers null input binary data it assumes that the rest of the file does not match; this is equivalent to the `-I` option.
    * If `TYPE` is `text`, grep processes a binary file as if it were text; this is equivalent to the `-a` option.

**Examples:**

* `grep -rn '<content>' <dir>`
* `grep -P '\t'`
* `ls | grep -E "customer[_0-9]*\.dat"`

## 2.7 ag

`ack`是`grep`的升级版，`ag`是`ack`的升级版。`ag`默认使用扩展的正则表达式，并且在当前目录递归搜索

**Pattern:**

* `ag [options] pattern [path ...]`

**Options:**

* `-c`：计算找到'查找字符串'的次数
* `-i`：忽略大小写的不同
* `-l`：输出匹配的文件名，而不是匹配的内容
* `-n`：禁止递归
* `-v`：反向选择，即输出没有'查找字符串'内容的哪一行
* `-r`：在指定目录中递归查找，这是默认行为
* `-A`：后面可加数字，为after的意思，除了列出该行外，后面的n行也列出来
* `-B`：后面可加数字，为before的意思，除了列出该行外，前面的n行也列出来
* `-C`：后面可加数字，除了列出该行外，前后的n行也列出来

**Examples:**

* `ag printf`

## 2.8 sort

**Pattern:**

* `sort [-fbMnrtuk] [file or stdin]`

**Options:**

* `-f`：忽略大小写的差异
* `-b`：忽略最前面的空格符部分
* `-M`：以月份的名字来排序，例如JAN，DEC等排序方法
* `-n`：使用"纯数字"进行排序（默认是以文字类型来排序的）
* `-r`：反向排序
* `-u`：就是uniq，相同的数据中，仅出现一行代表
* `-t`：分隔符，默认使用`Tab`来分隔
* `-k`：以哪个区间（field）来进行排序的意思

**Examples:**

* `cat /etc/passwd | sort`
* `cat /etc/passwd | sort -t ':' -k 3`
* `echo -e "a\nb\nb\na\nb\na\na\nc\na" | sort | uniq -c | sort -nr`

## 2.9 uniq

**Pattern:**

* `sort [options] [file or stdin]`

**Options:**

* `-c`：统计出现的次数
* `-d`：仅统计重复出现的内容
* `-i`：忽略大小写
* `-u`：仅统计只出现一次的内容

**Examples:**

* `echo -e 'a\na\nb' | uniq -c`
* `echo -e 'a\na\nb' | uniq -d`
* `echo -e 'a\na\nb' | uniq -u`
* `echo -e "a\nb\nb\na\nb\na\na\nc\na" | sort | uniq -c | sort -nr`

## 2.10 tr

`tr` is used for character processing, and its smallest processing unit is a character.

**Pattern:**

* `tr [-cdst] SET1 [SET2]`

**Options:**

* `-c, --complement`: Complement the specified characters. This means the part matching `SET1` is not processed, while the remaining unmatched part is transformed.
* `-d, --delete`: Delete specified characters.
* `-s, --squeeze-repeats`: Squeeze repeated characters into a single specified character.
* `-t, --truncate-set1`: Truncate the range of `SET1` to match the length of `SET2`.

**Character set ranges:**

* `\NNN`: Character with octal value NNN (1 to 3 octal digits).
* `\\`: Backslash.
* `\a`: Ctrl-G, bell character.
* `\b`: Ctrl-H, backspace.
* `\f`: Ctrl-L, form feed.
* `\n`: Ctrl-J, new line.
* `\r`: Ctrl-M, carriage return.
* `\t`: Ctrl-I, tab key.
* `\v`: Ctrl-X, vertical tab.
* `CHAR1-CHAR2`: A range of characters from CHAR1 to CHAR2, specified in ASCII order. The range must be from smaller to larger, not the other way around.
* `[CHAR*]`: This is specific to SET2, used to repeat the specified character until it matches the length of SET1.
* `[CHAR*REPEAT]`: Also specific to SET2, this repeats the specified character for the given REPEAT times (REPEAT is calculated in octal, starting from 0).
* `[:alnum:]`: All alphabetic characters and digits.
* `[:alpha:]`: All alphabetic characters.
* `[:blank:]`: All horizontal spaces.
* `[:cntrl:]`: All control characters.
* `[:digit:]`: All digits.
* `[:graph:]`: All printable characters (excluding space).
* `[:lower:]`: All lowercase letters.
* `[:print:]`: All printable characters (including space).
* `[:punct:]`: All punctuation characters.
* `[:space:]`: All horizontal and vertical space characters.
* `[:upper:]`: All uppercase letters.
* `[:xdigit:]`: All hexadecimal digits.
* `[=CHAR=]`: All characters equivalent to the specified character (the `CHAR` inside the equals sign represents a custom-defined character).

**Examples:**

* `echo "abcdefg" | tr "[:lower:]" "[:upper:]"`: Converts lowercase letters to uppercase.
* `echo -e "a\nb\nc" | tr "\n" " "`: Replaces `\n` with a space.
* `echo "hello 123 world 456" | tr -d '0-9'`: Deletes digits from `0-9`.
* `echo "'hello world'" | tr -d "'"`: Deletes single quotes.
* `echo -e "aa.,a 1 b#$bb 2 c*/cc 3 \nddd 4" | tr -d -c '0-9 \n'`: Deletes everything except `0-9`, space, and newline characters.
* `echo "thissss is      a text linnnnnnne." | tr -s ' sn'`: Removes redundant spaces, `s`, and `n`.
* `head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20`: Generates a random string.

## 2.11 jq

**Options:**

* `-c`：压缩成一行输出

**Examples:**

* 遍历数组
    ```sh
    content='[{"item":"a"},{"item":"b"}]'
    while IFS= read -r element; do
        echo "Element: $element"
    done < <(jq -c '.[]' <<< "$content")
    ```

* 提取元素
    ```sh
    content='{"person":{"name":"Alice","age":28,"address":{"street":"123 Main St","city":"Wonderland","country":"Fantasyland"},"contacts":[{"type":"email","value":"alice@example.com"},{"type":"phone","value":"555-1234"}]}}'
    jq -c '.person | .address | .city' <<< ${content}
    jq -c '.person.address.city' <<< ${content}
    jq -c '.person.contacts[1].value' <<< ${content}
    ```

## 2.12 xargs

**Options:**

* `-r, --no-run-if-empty`：输入为空就不执行后续操作了
* `-I {}`：用标准输入替换后续命令中的占位符`{}`
* `-t`：输出要执行的命令

**Examples:**

* `docker ps -aq | xargs docker rm -f`
* `echo "   a  b  c  " | xargs`：实现`trim`
* `ls | xargs -I {} rm -f {}`

## 2.13 tee

`>`、`>>`等会将数据流传送给文件或设备，因此除非去读取该文件或设备，否则就无法继续利用这个数据流，如果我们想要将这个数据流的处理过程中将某段信息存下来，可以利用`tee`（`tee`本质上，就是将`stdout`复制一份）

`tee`会将数据流送与文件与屏幕(screen)，输出到屏幕的就是`stdout`可以让下个命令继续处理(**`>`,`>>`会截断`stdout`，从而无法以`stdin`传递给下一个命令**)

**Pattern:**

* `tee [-a] file`

**Options:**

* `-a`：以累加(append)的方式，将数据加入到file当中

**Examples:**

* `command | tee <文件名> | command`

## 2.14 cat

**Pattern:**

* `cat > [newfile] <<'结束字符'`

**示例：注意`EOF`与`'EOF'`的区别**

* `man bash`搜索`Here Documents`查看这两者的区别

```sh
name="test"
cat > /tmp/test << EOF
hello ${name}!
EOF
echo "↓↓↓↓↓↓↓↓↓content↓↓↓↓↓↓↓↓↓"
cat /tmp/test
echo "↑↑↑↑↑↑↑↑↑content↑↑↑↑↑↑↑↑↑"

cat > /tmp/test << 'EOF'
hello ${name}!
EOF
echo "↓↓↓↓↓↓↓↓↓content↓↓↓↓↓↓↓↓↓"
cat /tmp/test
echo "↑↑↑↑↑↑↑↑↑content↑↑↑↑↑↑↑↑↑"
```

**Examples:**

* `cat -v <file>`: Show all invisible characters.

## 2.15 tail

**Examples:**

* `tail -f xxx.txt`
* `tail -n +2 xxx.txt`：输出第二行到最后一行

## 2.16 find

**Pattern:**

* `find [文件路径] [option] [action]`

**Options:**

* `-name`：后接文件名，支持通配符。**注意匹配的是相对路径**
* `-regex`：后接正则表达式，**注意匹配的是完整路径**
* `-maxdepth`：后接查找深度
* `-regextype`：正则表达式类型
    * `emacs`：默认类型
    * `posix-awk`
    * `posix-basic`
    * `posix-egrep`
    * `posix-extended`
* `-type`：后接类型
    * `f`：普通文件，默认的类型
    * `d`：目录

**Examples:**

* `find . -name "*.c"`
* `find . -maxdepth 1 -name "*.c"`
* `find . -regex ".*/.*\.c"`
* 查找后缀为cfg以及后缀为conf的文件
    * `find ./ -name '*.cfg' -o -name '*.conf'`
    * `find ./ -regex '.*\.cfg\|.*\.conf'`
    * `find ./ -regextype posix-extended -regex '.*\.(cfg|conf)'`
* `find . -type f -executable`：查找二进制文件

## 2.17 locate

**`locate`是在已创建的数据库`/var/lib/mlocate`里面的数据所查找到的，所以不用直接在硬盘当中去访问，因此，相比于`find`，速度更快**

**Install:**

```sh
yum install -y mlocate
```

**如何使用：**

```sh
# 第一次使用时，需要先更新db
updatedb

locate stl_vector.h
```

## 2.18 cp

**Examples:**

* `cp -vrf /a /b`：递归拷贝目录`/a`到目录`/b`中，包含目录`/a`中所有的文件、目录、隐藏文件和隐藏目录
* `cp -vrf /a/* /b`：递归拷贝目录`/a`下的所有文件、目录，但不包括隐藏文件和隐藏目录
* `cp -vrf /a/. /b`：递归拷贝目录`/a`中所有的文件、目录、隐藏文件和隐藏目录到目录`/b`中

## 2.19 rsync

[rsync 用法教程](https://www.ruanyifeng.com/blog/2020/08/rsync.html)

`rsync`用于文件同步。它可以在本地计算机与远程计算机之间，或者两个本地目录之间同步文件。它也可以当作文件复制工具，替代`cp`和`mv`命令

它名称里面的`r`指的是`remote`，`rsync`其实就是远程同步（`remote sync`）的意思。与其他文件传输工具（如`FTP`或`scp`）不同，`rsync`的最大特点是会检查发送方和接收方已有的文件，仅传输有变动的部分（默认规则是文件大小或修改时间有变动

**Pattern:**

* `rsync [options] [src1] [src2] ... [dest]`
* `rsync [options] [user@host:src1] ... [dest]`
* `rsync [options] [src1] [src2] ... [user@host:dest]`
* 关于`/`
    * `src`
        * 如果`src1`是文件，那只有一种写法，那就是`src1`
        * 如果`src1`是目录，那有两种写法
            * `src1`：拷贝整个目录，包括`src1`本身
            * `src1/`：拷贝目录中的内容，不包括`src1`本身
    * `dest`
        * `dest`：如果拷贝的是单个文件，那么`dest`表示的就是目标文件。如果拷贝的不是单个文件，那么`dest`表示目录
        * `dest/`：只能表示目录
        * 有一个例外，若要表示远端机器的用户目录，要写成`user@host:~/`，否则`~`会被当成一个普通目录名

**Options:**

* `-r`：递归。该参数是必须的，否则会执行失败
* `-a`：包含`-r`，还可以同步原信息（比如修改时间、权限等）。`rsync`默认使用文件大小和修改时间决定文件是否需要更新，加了`-a`参数后，权限不同也会触发更新
* `-n`：模拟命令结果
* `--delete`：默认情况下，`rsync`只确保源目录的所有内容（明确排除的文件除外）都复制到目标目录。它不会使两个目录保持相同，并且不会删除文件。如果要使得目标目录成为源目录的镜像副本，则必须使用`--delete`参数，这将删除只存在于目标目录、不存在于源目录的文件
* `--exclude`：指定排除模式，如果要排除多个文件，可以重复指定该参数
    * `--exclude='.*'`：排除隐藏文件
    * `--exclude='dir1/'`排除某个目录
    * `--exclude='dir1/*'`排除某个目录里面的所有文件，但不希望排除目录本身
* `--include`：指定必须同步的文件模式，往往与`--exclude`结合使用
* `--progress`：显示进度

**Examples:**

* `rsync -av /src/foo /dest`：将整个目录`/src/foo`拷贝到目录`/dest`中
* `rsync -av /src/foo/ /dest`：将目录`/src/foo`中的内容拷贝到目录`/dest`中
* `rsync -a --exclude=log/ dir1/ dir2`：将`dir1`中的内容拷贝到目录`dir2`中，且排除所有名字为`log`的子目录
* `rsync -a --exclude=log/ dir1 dir2`：将整个目录`dir1`拷贝到目录`dir2`中，且排除所有名字为`log`的子目录
* `rsync -a dir1 user1@192.168.0.1:~`：将整个目录`dir1`拷贝到`192.168.0.1`机器的`user1`的用户目录下的一个名为`~`的目录中，即`~/\~/dir1`（**巨坑的一个问题**）
* `rsync -a dir1 user1@192.168.0.1:~/`：将整个目录`dir1`拷贝到`192.168.0.1`机器的`user1`的用户目录，即`~/dir1`

## 2.20 rm

**Examples:**

* `rm -rf /a/*`：递归删除目录`/a`下的所有文件、目录，但不包括隐藏文件和隐藏目录
* `rm -rf /path/{..?*,.[!.]*,*}`：递归删除目录`/path`下的所有文件、目录、隐藏文件和隐藏目录
* `rm -rf /path/!(a.txt|b.txt)`：递归删除目录`path`下的除了`a.txt`以及`b.txt`之外的所有文件、目录，但不包括隐藏文件和隐藏目录
    * 需要通过命令`shopt -s extglob`开启`extglob`
    * 如何在`/bin/bash -c`中使用`extglob`
        ```sh
        mkdir -p rmtest
        touch rmtest/keep
        touch rmtest/text1
        touch rmtest/text2
        mkdir -p rmtest/sub
        touch rmtest/sub/keep
        touch rmtest/sub/text3

        tree -N rmtest
        /bin/bash -O extglob -c 'rm -rf rmtest/!(keep)'
        # rmtest/sub/keep cannot be preserve
        tree -N rmtest
        ```

## 2.21 tar

**Pattern:**

* Compression:
    * `tar -jcv [-f ARCHIVE] [-C WORKING_DIR] [FILE...]`
    * `tar -zcv [-f ARCHIVE] [-C WORKING_DIR] [FILE...]`
* Query:
    * `tar -jtv [-f ARCHIVE] [MEMBER...]`
    * `tar -ztv [-f ARCHIVE] [MEMBER...]`
* Decompression:
    * `tar -jxv [-f ARCHIVE] [-C WORKING_DIR] [MEMBER...]`
    * `tar -zxv [-f ARCHIVE] [-C WORKING_DIR] [MEMBER...]`

**Options:**

* `-c`: Create a new archive file, can be used with -v to view the filenames being archived during the process
* `-t`: View the contents of the archive file to see which filenames are included
* `-x`: Extract or decompress, can be used with -C to extract in a specific directory
* **Note, c t x are mutually exclusive**
* `-j`: Compress/decompress with bzip2 support, it's best to use the filename extension *.tar.bz2
* `-z`: Compress/decompress with gzip support, it's best to use the filename extension *.tar.gz
* `-v`: Display the filenames being processed during compression/decompression
* `-f` filename: The filename to be processed follows -f, it's recommended to write -f as a separate parameter
* `-C`: Change the working directory, subsequent filenames can use relative paths
    * `tar -czvf test.tar.gz /home/liuye/data/volumn1`: After archiving, the file paths inside the compressed package are full paths, i.e., `/home/liuye/data/volumn1/xxx`
    * `tar -czvf test.tar.gz data/volumn1`: Executing this command, the file paths inside the compressed package are relative to the current directory, i.e., `data/volumn1/xxx`
    * `tar -czvf test.tar.gz volumn1 -C /home/liuye/data`: The file paths inside the compressed package are relative to `/home/liuye/data`, i.e., `volumn1/xxx`
* `-p`: Preserve the original permissions and attributes of the backup data, commonly used for backing up (-c) important configuration files
* `-P`: Preserve absolute paths, i.e., allow the backup data to include the root directory

**Examples:**

* `tar -czvf /test.tar.gz -C /home/liuye aaa bbb ccc`
* `tar -zxvf /test.tar.gz -C /home/liuye`: Extract to the `/home/liuye` directory
    * `tar -zxvf /test.tar.gz -C /home/liuye path/a.txt`: Extract only `path/a.txt` to the `/home/liuye` directory`
* `tar cvf - /home/liuye | sha1sum`: `-` indicates standard input/output, here it represents standard output
* `wget -qO- xxx.tar.gz | tar -xz -C /tmp/target`

## 2.22 curl

**Pattern:**

* `curl [options] [URL...]`

**Options:**

* `-s`：Silent mode。只显示内容，一般用于执行脚本，例如`curl -s '<url>' | bash -s`
* `-L`：如果原链接有重定向，那么会继续从新链接访问
* `-o`：指定下载文件名
* `-X`：指定`Http Method`，例如`POST`
* `-H`：增加`Http Header`
* `-d`：指定`Http Body`
* `-u <username>:<password>`：对于需要鉴权的服务，需要指定用户名或密码，`:<password>`可以省略，以交互的方式输入

**Examples:**

* `curl -L -o <filename> '<url>'`

## 2.23 wget

**Pattern:**

* `wget [options] [URL]...`

**Options:**

* `-O`：后接下载文件的文件名
* `-r`：递归下载（用于下载文件夹）
* `-nH`：下载文件夹时，不创建host目录
* `-np`：不访问上层目录
* `-P`：指定下载的目录
* `-R`：指定排除的列表
* `--proxy`：后接proxy地址

**Examples:**

* `wget -O myfile 'https://www.baidu.com'`
* `wget -r -np -nH -P /root/test -R "index.html*" 'http://192.168.66.1/stuff'`
* `wget -r -np -nH -P /root/test 'ftp://192.168.66.1/stuff'`
* `wget --proxy=http://proxy.example.com:8080 http://example.com/file`

## 2.24 tree

**Pattern:**

* `tree [option]`

**Options:**

* `-N`：显示非ASCII字符，可以显示中文
* `-L [num]`：控制显示层级

## 2.25 split

**Examples:**

* `split -b 2048M bigfile bigfile-slice-`：按大小切分文件，切分后的文件最大为`2048M`，文件的前缀是`bigfile-slice-`
* `split -l 10000 bigfile bigfile-slice-`：按行切分文件，切分后的文件最大行数为`10000`，文件的前缀是`bigfile-slice-`

## 2.26 base64

用于对输入进行`base64`编码以及解码

**Examples:**

* `echo "hello" | base64`
* `echo "hello" | base64 | base64 -d`

## 2.27 md5sum

计算输入或文件的MD5值

**Examples:**

* `echo "hello" | md5sum`

## 2.28 openssl

openssl可以对文件，以指定算法进行加密或者解密

**Examples:**

* `openssl -h`：查看所有支持的加解密算法
* `openssl aes-256-cbc -a -salt -in blob.txt -out cipher`
* `openssl aes-256-cbc -a -d -in cipher -out blob-rebuild.txt`

## 2.29 bc

bc可以用于进制转换

**Examples:**

* `echo "obase=8;255" | bc`：十进制转8进制
* `echo "obase=16;255" | bc`：十进制转16进制
* `((num=8#77)); echo ${num}`：8进制转十进制
* `((num=16#FF)); echo ${num}`：16进制转十进制

## 2.30 dirname

`dirname`用于返回文件路径的目录部分，该命令不会检查路径所对应的目录或文件是否真实存在

**Examples:**

* `dirname /var/log/messages`：返回的是`/var/log`
* `dirname dirname aaa/bbb/ccc`：返回的是`aaa/bbb`
* `dirname .././../.././././a`：返回的是`.././../../././.`

通常在脚本中用于获取脚本所在的目录，示例如下：

```sh
# 其中$0代表脚本的路径（相对或绝对路径）
ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)
```

## 2.31 addr2line

该工具用于查看二进制的偏移量与源码的对应关系。如果二进制和产生core文件的机器不是同一台，那么可能会产生符号表不匹配的问题，导致得到的源码位置是有问题的

**Examples:**

* `addr2line 4005f5 -e test`：查看二进制`test`中位置为`4005f5`指令对应的源码

## 2.32 ldd

该工具用于查看可执行文件链接了哪些动态库

**Examples:**

* `ldd main`
    * `readelf -a ./main | grep NEEDED`
    * `objdump -x ./main | grep NEEDED`

## 2.33 ldconfig

**生成动态库缓存或从缓存读取动态库信息**

**Examples:**

* `ldconfig`：重新生成`/etc/ld.so.cache`
* `ldconfig -v`：重新生成`/etc/ld.so.cache`，并输出详细信息
* `ldconfig -p`：从`/etc/ld.so.cache`中读取并展示动态库信息

## 2.34 objdump

该工具用于反汇编

**Examples:**

* `objdump -drwCS main.o`
* `objdump -drwCS -M intel main.o`
* `objdump -p main`

## 2.35 objcopy & strip

该工具用于将debug信息从二进制中提取出来，示例：[[Enhancement] strip debug symbol in release mode](https://github.com/StarRocks/starrocks/pull/24442)

```sh
objcopy --only-keep-debug main main.debuginfo
strip --strip-debug main
objcopy --add-gnu-debuglink=main.debuginfo main main-with-debug
```

When you're debugging the binary through `gdb`, it will automatically load the corresponding debug info file, and you can also manually load it using the `symbol-file` command, like `(gdb) symbol-file /path/to/binary_file.debuginfo`.

## 2.36 nm

该工具用于查看符号表

**Examples:**

* `nm -C main`
* `nm -D xxx.so`

## 2.37 strings

该工具用于查看二进制文件包含的所有字符串信息

**Examples:**

* `strings main`

## 2.38 iconf

**Options:**

* `-l`：列出所有编码
* `-f`：来源编码
* `-t`：目标编码
* `-c`：忽略有问题的编码
* `-s`：忽略警告
* `-o`：输出文件
* `--verbose`：输出处理文件进度

**Examples:**

* `iconv -f gbk -t utf-8 s.txt > t.txt`

## 2.39 expect

expect是一个自动交互的工具，通过编写自定义的配置，就可以实现自动填充数据的功能

**Examples:**

```sh
cat > /tmp/interact.cpp << 'EOF'
#include <iostream>
#include <string>

int main() {
    std::cout << "please input your first name: ";
    std::string first_name;
    std::cin >> first_name;

    std::cout << "please input your last name: ";
    std::string last_name;
    std::cin >> last_name;

    std::cout << "Welcome " << last_name << " " << first_name << std::endl;
}
EOF

gcc -o /tmp/interact /tmp/interact.cpp -lstdc++

cat > /tmp/test_expect.config << 'EOF'
spawn /tmp/interact
expect {
    "*first name*" {
        send "Bruce\n";
        exp_continue;
    }
    "*last name*" { send "Lee\n"; }
}
interact
EOF

expect /tmp/test_expect.config
```

## 2.40 parallel

The parallel command is a powerful utility in Unix-like operating systems designed for running multiple shell commands in parallel, rather than sequentially. This can significantly speed up the execution of tasks that can be performed concurrently, especially when processing large amounts of data or performing operations on multiple files or processes at the same time.

**Pattern:**

* `parallel command ::: argument1 argument2 argument3`

**Options:**

* `-j N`: Specifies the number of jobs to run in parallel. If not specified, parallel attempts to run as many jobs in parallel as there are CPU cores.
* `-k`: Keep sequence of output same as the order of input. Normally the output of a job will be printed as soon as the job completes.
* `-n max-args`: Use at most max-args arguments per command line.
    * `-n 0`means read one argument, but insert 0 arguments on the command line.
* `:::`: Used to specify arguments directly on the command line.

**Examples:**

* `parallel -j1 sleep {}\; echo {} ::: 2 1 4 3`
* `parallel -j4 sleep {}\; echo {} ::: 2 1 4 3`
* `parallel -j4 -k sleep {}\; echo {} ::: 2 1 4 3`
* `seq 10 | parallel -n0 echo "hello world"`: Run the same command 10 times
* `seq 2 | parallel -n0 cat test.sql '|' mysql -h 127.0.0.1 -P 3306 -u root -D test`
* `seq 2 | parallel -n0 mysql -h 127.0.0.1 -P 3306 -u root -D test -e \'source test.sql\'`

# 3 Device Management

## 3.1 mount

mount用于挂载一个文件系统

**Pattern:**

* `mount [-t vfstype] [-o options] device dir`

**Options:**

* `-t`：后接文件系统类型，不指定类型的话会自适应
* `-o`：后接挂载选项

**Examples:**

* `mount -o loop /CentOS-7-x86_64-Minimal-1908.iso /mnt/iso`

### 3.1.1 Propagation Level

内核引入`mount namespace`之初，各个`namespace`之间的隔离性较差，例如在某个`namespace`下做了`mount`或者`umount`动作，那么这一事件会被传播到其他的`namespace`中，在某些场景下，是不适用的

因此，在`2.6.15`版本之后，内核允许将一个挂载点标记为`shared`、`private`、`slave`、`unbindable`，以此来提供细粒度的隔离性控制

* `shared`：默认的传播级别，`mount`、`unmount`事件会在不同`namespace`之间相互传播
* `private`：禁止`mount`、`unmount`事件在不同`namespace`之间相互传播
* `slave`：仅允许单向传播，即只允许`master`产生的事件传播到`slave`中
* `unbindable`：不允许`bind`操作，在这种传播级别下，无法创建新的`namespace`

## 3.2 umount

umount用于卸载一个文件系统

**Examples:**

* `umount /home`

## 3.3 findmnt

findmnt用于查看挂载点的信息

**Options:**

* `-o [option]`：指定要显示的列

**Examples:**

* `findmnt -o TARGET,PROPAGATION`

## 3.4 free

**Pattern:**

* `free [-b|-k|-m|-g|-h] [-t]`

**Options:**

* `-b`：bytes
* `-m`：MB
* `-k`：KB
* `-g`：GB
* `-h`：单位自适应

**显示参数介绍**：

* `Men`：物理内存
* `Swap`：虚拟内存
* `total`：内存总大小，该信息可以从`/proc/meminfo`中获取（`MemTotal`、`SwapTotal`）
* `user`：已使用的内存大小，计算方式为`total - free - buffers - cache`
* `free`：未被使用的内存大小，该信息可以从`/proc/meminfo`中获取（`MemFree`、`SwapFree`）
* `shared`：被`tmpfs`使用的内存大小，该信息可以从`/proc/meminfo`中获取（`Shmem`）
* `buffers`：内核`buffer`使用的内存大小，该信息可以从`/proc/meminfo`中获取（`Buffers`）
* `cached`：`slabs`以及`page cache`使用的内存大小，该信息可以从`/proc/meminfo`（`Cached`）
* `available`：仍然可以分配给应用程序的内存大小（非`swap`内存），该信息可以从`/proc/meminfo`（`MemAvailable`）
* **一般来说系统会很有效地将所有内存用光，目的是为了让系统的访问性能加速，这一点与Windows很不同，因此对于Linux系统来说，内存越大越好**

**Examples:**

* `free -m`

## 3.5 swap

**制作swap：**

```sh
dd if=/dev/zero of=/tmp/swap bs=1M count=128
mkswap /tmp/swap
swapon /tmp/swap
free
```

## 3.6 df

**Options:**

* `-h`：以`K`，`M`，`G`为单位，提高信息的可读性
* `-i`：显示`inode`信息
* `-T`：显式文件系统类型

**Examples:**

* `df -h`
* `df -ih`
* `df -Th`

## 3.7 du

**Pattern:**

* `du`

**Options:**

* `-h`: Use `K`, `M`, `G` units to improve readability
* `-s`: Show only the total
* `-d <depth>`: Specify the depth of files/folders to display

**Examples:**

* `du -sh`: Total size of the current folder
* `du -h -d 1`: List the sizes of all files/folders at depth 1
    * `du -h -d 1 | sort -h`
    * `du -h -d 1 | sort -hr`

## 3.8 ncdu

ncdu (NCurses Disk Usage) is a curses-based version of the well-known `du`, and provides a fast way to see what directories are using your disk space.

**Examples:**

* `ncdu`
* `ncdu /`

## 3.9 lsblk

`lsblk`命令用于列出所有可用块设备的信息

**Pattern:**

* `lsblk [option]`

**Options:**

* `-a, --all`：打印所有设备
* `-b, --bytes`：以字节为单位而非易读的格式来打印 SIZE
* `-d, --nodeps`：不打印从属设备(slave)或占位设备(holder)
* `-D, --discard`：打印时丢弃能力
* `-e, --exclude <列表>`：根据主设备号排除设备(默认：内存盘)
* `-I, --include <列表>`：只显示有指定主设备号的设备
* `-f, --fs`：输出文件系统信息
* `-h, --help`：使用信息(此信息)
* `-i, --ascii`：只使用 ascii 字符
* `-m, --perms`：输出权限信息
* `-l, --list`：使用列表格式的输出
* `-n, --noheadings`：不打印标题
* `-o, --output <列表>`：输出列
* `-p, --paths`：打印完整设备路径
* `-P, --pairs`：使用 key=“value” 输出格式
* `-r, --raw`：使用原生输出格式
* `-s, --inverse`：反向依赖
* `-t, --topology`：输出拓扑信息
* `-S, --scsi`：输出有关 SCSI 设备的信息

**Examples:**

* `lsblk -fp`
* `lsblk -o name,mountpoint,label,size,uuid`

## 3.10 lsusb

`lsusb`命令用于列出所有usb接口的设备

## 3.11 lspci

`lspci`命令用于列出所有pci接口的设备

## 3.12 lscpu

`lscpu`命令用于列出cpu设备

## 3.13 sync

`sync`指令会将存于`buffer`中的资料强制写入硬盘中

## 3.14 numactl

`numactl`用于设置和查看`NUMA`信息

**Options:**

* `--hardware`：显示硬件信息，包括`NUMA-Node`数量、每个`Node`对应的CPU，内存大小，以及一个矩阵，用于表示`node[i][j]`的内存访问开销
* `--show`：显示当前的`NUMA`设置
* `--physcpubind=<cpus>`：表示绑定到`<cpus>`上执行。`<cpus>`是`/proc/cpuinfo`中的`processor`字段。其中，`<cpus>`可以是：`all`、`0,5,10`、`2-8`
* `--cpunodebind=<nodes>`：表示绑定到`<nodes>`上执行。其中，`<nodes>`可以是：`all`、`0,1,6`、`0-3`
* `Memory Policy`
    * `--interleave=<nodes>`：表示在`<nodes>`上轮循分配内存
    * `--preferred=<node>`：表示优先从`<node>`上分配内存
    * `--membind=<nodes>`：表示在`<nodes>`上进行内存分配
    * `--localalloc`：表示在CPU所在的`node`上进行内存分配，需要配合绑核才能起到优化的效果
    * 其中，`<nodes>`可以是：`all`、`0,1,6`、`0-3`

**Examples:**

* `numactl --hardware`：
* `numactl --show`：显示当前的`NUMA`设置

## 3.15 hdparm

`hdparm` is a command-line utility in Linux used primarily for querying and setting hard disk parameters. It's a powerful tool that provides a variety of functions allowing users to manage the performance of their disk drives. The most common use of `hdparm` is to measure the reading speed of a disk drive, but its capabilities extend much further.

**Examples:**

* `hdparm -Tt /dev/sda`

## 3.16 file

determine file type

**Examples:**

* `file xxx`

## 3.17 realpath

print the resolved path

**Examples:**

* `realpath xxx`

## 3.18 readelf

用于读取、解析可执行程序

**Options:**

* `-d`：输出动态链接的相关信息（如果有的话）
* `-s`：输出符号信息

**Examples:**

* `readelf -d libc.so.6`
* `readelf -s --wide xxx.so`

## 3.19 readlink

print resolved symbolic links or canonical file names

**Examples:**

* `readlink -f $(which java)`

# 4 Process Management

**后台进程（&）：**

在命令最后加上`&`代表将命令丢到后台执行

* 此时bash会给予这个命令一个工作号码(job number)，后接该命令触发的PID
* 不能被[Ctrl]+C中断
* 在后台中执行的命令，如果有stdout以及stderr时，它的数据依旧是输出到屏幕上面，所以我们会无法看到提示符，命令结束后，必须按下[Enter]才能看到命令提示符，同时也无法用[Ctrl]+C中断。解决方法就是利用数据流重定向

**Examples:**

* `tar -zpcv -f /tmp/etc.tar.gz /etc > /tmp/log.txt 2>&1 &`

**`Ctrl+C`**：终止当前进程

**`Ctrl+Z`**：暂停当前进程

## 4.1 jobs

**Pattern:**

* `jobs [option]`

**Options:**

* `-l`：除了列出job number与命令串之外，同时列出PID号码
* `-r`：仅列出正在后台run的工作
* `-s`：仅列出正在后台中暂停(stop)的工作
* 输出信息中的'+'与'-'号的意义：
    * +：最近被放到后台的工作号码，代表默认的取用工作，即仅输入'fg'时，被拿到前台的工作
    * -：代表最近后第二个被放置到后台的工作号码
    * 超过最后第三个以后，就不会有'+'与'-'号存在了

**Examples:**

* `jobs -lr`
* `jobs -ls`

## 4.2 fg

将后台工作拿到前台来处理

**Examples:**

* `fg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `fg +`：取出标记为+的工作
* `fg -`：取出标记为-的工作

## 4.3 bg

让工作在后台下的状态变为运行中

**Examples:**

* `bg %jobnumber`：取出编号为`jobnumber`的工作。jubnumber为工作号码(数字)，%是可有可无的
* `bg +`：取出标记为+的工作
* `bg -`：取出标记为-的工作
* 不能让类似vim的工作变为运行中，即便使用该命令会，该工作又立即变为暂停状态

## 4.4 kill

管理后台当中的工作

**Pattern:**

* `kill [-signal] PID`
* `kill [-signal] %jobnumber`
* `kill -l`

**Options:**

* `-l`：列出目前kill能够使用的signal有哪些
* `-signal`：
    * `-1`：重新读取一次参数的配置文件，类似reload
    * `-2`：代表与由键盘输入[Ctrl]+C同样的操作
    * `-6`：触发core dump
    * `-9`：立刻强制删除一个工作，通常在强制删除一个不正常的工作时使用
    * `-15`：以正常的程序方式终止一项工作，与-9是不同的，-15以正常步骤结束一项工作，这是默认值
* 与bg、fg不同，若要管理工作，kill中的%不可省略，因为kill默认接PID

## 4.5 pkill

**Pattern:**

* `pkill [-signal] PID`
* `pkill [-signal] [-Ptu] [arg]`

**Options:**

* `-f`：匹配完整的`command line`，默认情况下只能匹配15个字符
* `-signal`：同`kill`
* `-P ppid,...`：匹配指定`parent id`
* `-s sid,...`：匹配指定`session id`
* `-t term,...`：匹配指定`terminal`
* `-u euid,...`：匹配指定`effective user id`
* `-U uid,...`：匹配指定`real user id`
* **不指定匹配规则时，默认匹配进程名字**

**Examples:**

* `pkill -9 -t pts/0`
* `pkill -9 -u user1`

## 4.6 ps

**Options:**

* `a`：不与terminal有关的所有进程
* `u`：有效用户相关进程
* `x`：通常与`a`这个参数一起使用，可列出较完整的信息
* `A/e`：所有的进程均显示出来
* `-f/-l`：详细信息，内容有所差别
* `-T/-L`：线程信息，结合`-f/-l`参数时，显式的信息有所不同
* `-o`：后接以逗号分隔的列名，指定需要输出的信息
    * `%cpu`
    * `%mem`
    * `args`
    * `uid`
    * `pid`
    * `ppid`
    * `lwp/tid/spid`：线程`TID`，`lwp, light weight process, i.e. thread`
    * `comm/ucomm/ucmd`：线程名
    * `time`
    * `tty`
    * `flags`：进程标识
        * `1`：forked but didn't exec
        * `4`：used super-user privileges
    * `stat`：进程状态
        * `D`：uninterruptible sleep (usually IO)
        * `R`：running or runnable (on run queue)
        * `S`：interruptible sleep (waiting for an event to complete)
        * `T`：stopped by job control signal
        * `t`：stopped by debugger during the tracing
        * `W`：paging (not valid since the 2.6.xx kernel)
        * `X`：dead (should never be seen)
        * `Z`：defunct ("zombie") process, terminated but not reaped by its parent
* `-w`：Wide output.  Use this option twice for unlimited width.

**Examples:**

* `ps aux`
* `ps -ef`
* `ps -efww`
* `ps -el`
* `ps -e -o pid,ppid,stat | grep Z`：查找僵尸进程
* `ps -T -o tid,ucmd -p 212381`：查看指定进程的所有的线程id以及线程名

## 4.7 pgrep

**Pattern:**

* `pgrep [-lon] <pattern>`

**Options:**

* `-a`：列出pid以及完整的程序名
* `-l`：列出pid以及程序名
* `-f`：匹配完整的进程名
* `-o`：列出oldest的进程
* `-n`：列出newest的进程

**Examples:**

* `pgrep sshd`
* `pgrep -l sshd`
* `pgrep -lo sshd`
* `pgrep -ln sshd`
* `pgrep -l ssh*`
* `pgrep -a sshd`

## 4.8 pstree

**Pattern:**

* `pstree [-A|U] [-up]`

**Options:**

* `-a`：显示命令
* `-l`：不截断
* `-A`：各进程树之间的连接以`ascii`字符来连接（连接符号是`ascii`字符）
* `-U`：各进程树之间的连接以`utf8`码的字符来连接，在某些终端接口下可能会有错误（连接符号是`utf8`字符，比较圆滑好看）
* `-p`：同时列出每个进程的进程号
* `-u`：同时列出每个进程所属账号名称
* `-s`：显示指定进程的父进程

**Examples:**

* `pstree`：整个进程树
* `pstree -alps <pid>`：以该进程为根节点的进程树

## 4.9 pstack

**Install:**

```sh
yum install -y gdb
```

查看指定进程的堆栈

**Examples:**

```sh
pstack 12345
```

## 4.10 prlimit

`prlimit` is used to get and set process resource limits.

**Examples:**

* `prlimit --pid=<PID> --core=<soft_limit>:<hard_limit>`
* `prlimit --pid=<PID> --core=unlimited:unlimited`

## 4.11 taskset

查看或者设置进程的cpu亲和性

**Pattern:**

* `taskset [options] -p pid`
* `taskset [options] -p [mask|list] pid`

**Options:**

* `-c`：以列表格式显示cpu亲和性
* `-p`：指定进程的pid

**Examples:**

* `taskset -p 152694`：查看pid为`152694`的进程的cpu亲和性，显示方式为掩码
* `taskset -c -p 152694`：查看pid为`152694`的进程的cpu亲和性，显示方式为列表
* `taskset -p f 152694`：设置pid为`152694`的进程的cpu亲和性，设置方式为掩码
* `taskset -c -p 0,1,2,3,4,5 152694`：设置pid为`152694`的进程的cpu亲和性，设置方式为列表

**什么是cpu亲和性掩码（16进制）**

* `cpu0 = 1`
* `cpu1 = cpu0 * 2 = 2`
* `cpu2 = cpu1 * 2 = 4`
* `cpu(n) = cpu(n-1) * 2`
* `mask = cpu0 + cpu1 + ... + cpu(n)`
* 举几个例子
    * `0 ==> 1 = 0x1`
    * `0,1,2,3 ==> 1 + 2 + 4 + 8 = 15 = 0xf`
    * `0,1,2,3,4,5 ==> 1 + 2 + 4 + 8 + 16 + 32 = 0x3f`
    * `2,3 ==> 4 + 8 = 12 = 0xc`

## 4.12 su

su command is used to switch users

* `su`: Switches to the root user in a `non-login-shell` manner
* `su -`: Switches to the root user in a `login-shell` manner (changing directories, environment variables, etc.)
* `su test`: Switches to the test user in a `non-login-shell` manner
* `su - test`: Switches to the test user in a `login-shell` manner (changing directories, environment variables, etc.)

**Examples:**

* `sudo su -`
* `sudo su - -c 'ls -al /'`

## 4.13 sudo

`sudo` is used to execute a command as another user.

**Note, sudo itself is a process. For example, using `sudo tail -f xxx`, in another session `ps aux | grep tail` will find two processes**

**Configuration file: `/etc/sudoers`**

**How to add `sudoer` privileges to the `test` user? Append the following content to `/etc/sudoers` (choose either one)**

```conf
# Execute sudo commands without a password
test ALL=(ALL) NOPASSWD: ALL

# Execute sudo commands with a password
test ALL=(ALL) ALL
```

**Options:**

* `-E`: Indicates to the security policy that the user wishes to preserve their existing environment variables.
* `-i, --login`: Run login shell as the target user.

**Examples:**

* `sudo -u root ls /`
* `sudo -u root -E ls /`
* `sudo -i hdfs dfs -ls /`

## 4.14 pkexec

允许授权用户以其他身份执行程序

**Pattern:**

* `pkexec [command]`

## 4.15 nohup

**`nohup`会忽略所有挂断（SIGHUP）信号**。比如通过`ssh`登录到远程服务器上，然后启动一个程序，当`ssh`登出时，这个程序就会随即终止。如果用`nohup`方式启动，那么当`ssh`登出时，这个程序仍然会继续运行

**Pattern:**

* `nohup command [args] [&]`

**Options:**

* `command`：要执行的命令
* `args`：命令所需的参数
* `&`：在后台执行

**Examples:**

* `nohup java -jar xxx.jar &`

## 4.16 screen

**如果想在关闭`ssh`连接后继续运行启动的程序，可以使用`nohup`。如果要求下次`ssh`登录时，还能查看到上一次`ssh`登录时运行的程序的状态，那么就需要使用`screen`**

**Pattern:**

* `screen`
* `screen cmd [ args ]`
* `screen [–ls] [-r pid]`
* `screen -X -S <pid> kill`
* `screen -d -m cmd [ args ]`

**Options:**

* `cmd`：执行的命令
* `args`：执行的命令所需要的参数
* `-ls`：列出所有`screen`会话的详情
* `-r`：后接`pid`，进入指定进程号的`screen`会话
* `-d`：退出当前运行的session

**Examples:**

* `screen`
* `screen -ls`
* `screen -r 123`

**会话管理：**

1. `Ctrl a + w`：显示所有窗口列表
1. `Ctrl a + Ctrl a`：切换到之前显示的窗口
1. `Ctrl a + c`：创建一个新的运行shell的窗口并切换到该窗口
1. `Ctrl a + n`：切换到下一个窗口
1. `Ctrl a + p`：切换到前一个窗口(与`Ctrl a + n`相对)
1. `Ctrl a + 0-9`：切换到窗口0..9
1. `Ctrl a + d`：暂时断开screen会话
1. `Ctrl a + k`：杀掉当前窗口

## 4.17 tmux

**`tmux` is like an advanced version of `screen`, for example, it allows features such as pair programming (allowing two terminals to enter the same `tmux` session, whereas `screen` does not allow this).**

**Usage:**

* `tmux`: Start a new session, named with an incrementing number.
* `tmux new -s <name>`: Start a new session with a specified name.
* `tmux ls`: List all sessions.
* `tmux attach-session -t <name>`: Attach to a session with a specific name.
* `tmux kill-session -t <name>`: Kill a session with a specific name.
* `tmux rename-session -t <old-name> <new-name>`: Rename a session.
* `tmux source-file ~/.tmux.conf`: Reload config.
* `tmux clear-history`: Clean history.
* `tmux kill-server`: Kill server.
* **`<prefix> ?`: List key bindings.**
    * **Pane:**
        * `<prefix> "`: Split pane vertically.
        * `<prefix> %`: Split pane horizontally.
        * `<prefix> !`: Break pane to a new window.
        * `<prefix> Up`
        * `<prefix> Down`
        * `<prefix> Left`
        * `<prefix> Right`
        * `<prefix> q`: Prints the pane numbers and their sizes on top of the panes for a short time.
            * `<prefix> q <num>`: Change to pane `<num>`.
        * `<prefix> o`: Move to the next pane by pane number.
        * `<prefix> <c-o>`: Swaps that pane with the active pane.
        * `<prefix> E`: Spread panes out evenly.
        * `<prefix> Spac`: Select next layout.
    * **Window:**
        * `<prefix> <num>`: Change to window `<num>`.
        * `<prefix> '`: Prompt for a window index and changes to that window.
        * `<prefix> n`: Change to the next window in the window list by number.
        * `<prefix> p`: Change to the previous window in the window list by number.
        * `<prefix> l`: Changes to the last window, which is the window that was last the current window before the window that is now.
        * `<prefix> w`: Prints the window numbers for choose.
    * **Session:**
        * `<prefix> s`: Prints the session numbers for choose.
        * `<prefix> $`: Rename current session.
* **Options:**
    * `Session Options`
        * `tmux set-option -g <key> <value>`/`tmux set -g <key> <value>`
        * `tmux show-options -g`/`tmux show-options -g <key>`
        * `tmux set -g escape-time 50`: Controls how long tmux waits to distinguish between an escape sequence (like a function key or arrow key) and a standalone Escape key press.
    * `Window Options`
        * `tmux set-window-option -g <key> <value>`/`tmux setw -g <key> <value>`
        * `tmux show-window-options -g`/`tmux show-window-options -g <key>`
        * `tmux setw -g mode-keys vi`: Use vi mode.

**Tips:**

* In `tmux`, vim's color configuration may not work, so you need to set the environment variable `export TERM="xterm-256color"`.
* Change the prefix key (the default prefix key is `C-b`):
    1. Method 1: `tmux set -g prefix C-x`, only effective for the current session.
    1. Method 2: Add the following configuration to `~/.tmux.conf`: `set -g prefix C-x`.
* Change the default shell:
    1. Method 1: `tmux set -g default-shell /usr/bin/zsh`, only effective for the current session.
    1. Method 2: Add the following configuration to `~/.tmux.conf`: `set -g default-shell /usr/bin/zsh`.
* Support scroll with mouse: 
    1. Method 1: `tmux set -g mouse on`, only effective for the current session.
    1. Method 2: Add the following configuration to `~/.tmux.conf`: `set -g mouse on`.

**My `~/.tmux.conf`**

```sh
set -g prefix C-x
set -g default-shell ${SHELL}
set -g escape-time 50
setw -g mode-keys vi
set -g display-panes-time 60000 # 60 seconds

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# [Option] + h, which is「˙」
# [Option] + j, which is「∆」
# [Option] + k, which is「˚」
# [Option] + l, which is「¬」
# [Option] + [shift] + h, which is「Ó」
# [Option] + [shift] + l, which is「Ò」

# Pane switch
# send-keys means passing the key to current command, i.e. vim/nvim.
# bind -n ˙ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ˙" "select-pane -L"
# bind -n ¬ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ¬" "select-pane -R"
# bind -n ∆ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ∆" "select-pane -U"
# bind -n ˚ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ˚" "select-pane -D"
bind -n ˙ select-pane -L
bind -n ¬ select-pane -R
bind -n ∆ select-pane -U
bind -n ˚ select-pane -D

# Window switch
# bind -n Ó if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys Ó" "previous-window"
# bind -n Ò if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys Ò" "next-window"
bind -n Ó previous-window
bind -n Ò next-window

# Create the 'ktb_vim'(or any identifier you like) key table for Vim mode (pass keys to Vim/Neovim)
bind -T ktb_vim ˙ send-keys ˙
bind -T ktb_vim ¬ send-keys ¬
bind -T ktb_vim ∆ send-keys ∆
bind -T ktb_vim ˚ send-keys ˚
bind -T ktb_vim Ó send-keys Ó
bind -T ktb_vim Ò send-keys Ò

# Toggle between the 'ktb_vim' and default 'root' key tables
bind v if -F '#{==:#{key-table},ktb_vim}' 'set -w key-table root; switch-client -T root' 'set -w key-table ktb_vim; switch-client -T ktb_vim'

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# Set the status bar at the bottom
set -g status-position bottom

# Set the status bar refresh interval (in seconds)
set -g status-interval 5

# Style the status bar
set -g status-style bg=black,fg=brightcyan

# Left side of the status bar (session and window info)
set -g status-left-length 100
set -g status-left '#[bg=green,fg=black,bold] #S #[bg=black,fg=green]'

# Right side of the status bar (battery, time, hostname, etc.)
set -g status-right-length 150
set -g status-right '#[bg=black,fg=yellow]#[bg=yellow,fg=black,bold] %Y-%m-%d #[bg=yellow,fg=black] %H:%M #[bg=yellow,fg=black] #(whoami) #[bg=yellow,fg=black]#[bg=cyan,fg=black,bold] #(hostname) #[bg=cyan,fg=black] #(battery-status.sh) #[bg=cyan,fg=black]#[bg=brightblue,fg=black,bold] #(uptime -p) '

# Window status (active/inactive windows)
setw -g window-status-format ' #[bg=black,fg=cyan] #I:#W '
setw -g window-status-current-format ' #[bg=yellow,fg=black,bold] #I:#W #[fg=yellow]'

# Pane border styles (active/inactive panes)
set -g pane-border-style fg=blue
set -g pane-active-border-style fg=green

# Highlight active window
setw -g window-status-current-style bg=brightyellow,fg=black,bold

# Show the status bar always
set -g status on
```

## 4.18 reptyr

[reptyr](https://github.com/nelhage/reptyr)用于将当前终端的`pid`作为指定进程的父进程。有时候，我们会ssh到远程机器执行命令，但是后来发现这个命令会持续执行很长时间，但是又不得不断开ssh，此时我们就可以另开一个`screen`或者`tmux`，将目标进程挂到新开的终端上

注：`reptyr`依赖`ptrace`这一系统调用，可以通过`echo 0 > /proc/sys/kernel/yama/ptrace_scope`开启

**Examples:**

* `reptyr <pid>`

# 5 Network Management

## 5.1 netstat

**Pattern:**

* `netstat -[rn]`
* `netstat -[antulpc]`

**Options:**

1. **与路由有关的参数**
    * `-r`：列出路由表(route table)，功能如同route
    * `-n`：不使用主机名与服务名称，使用IP与port number，如同route -n
1. **与网络接口有关的参数**
    * `-a`：列出所有的连接状态，包括tcp/udp/unix socket等
    * `-t`：仅列出TCP数据包的连接
    * `-u`：仅列出UDP数据包的连接
    * `-l`：仅列出已在Listen(监听)的服务的网络状态
    * `-p`：列出PID与Program的文件名
    * `-c`：可以设置几秒种后自动更新一次，例如-c 5为每5s更新一次网络状态的显示

**与路由有关的显示参数说明**

* `Destination`：Network的意思
* `Gateway`：该接口的Gateway的IP，若为0.0.0.0，表示不需要额外的IP
* `Genmask`：就是Netmask，与Destination组合成为一台主机或网络
* `Flags`：共有多个标志来表示该网络或主机代表的意义
    * `U`：代表该路由可用
    * `G`：代表该网络需要经由Gateway来帮忙传递
    * `H`：代表该行路由为一台主机，而非一整个网络
    * `D`：代表该路由是由重定向报文创建的
    * `M`：代表该路由已被重定向报文修改
    * `Iface`：就是Interface(接口)的意思

**与网络接口有关的显示参数说明：**

* `Proto`：该连接的数据包协议，主要为TCP/UDP等数据包
* `Recv-Q`：非用户程序连接所复制而来的总byte数
* `Send-Q`：由远程主机发送而来，但不具有ACK标志的总byte数，亦指主动连接SYN或其他标志的数据包所占的byte数
* `Local Address`：本地端的地址，可以使IP，也可以是完整的主机名，使用的格式是"IP:port"
* `Foreign Address`：远程主机IP与port number
* `stat`：状态栏
    * `ESTABLISED`：已建立连接的状态
    * `SYN_SENT`：发出主动连接(SYN标志)的连接数据包
    * `SYN_RECV`：接收到一个要求连接的主动连接数据包
    * `FIN_WAIT1`：该套接字服务已中断，该连接正在断线当中
    * `FIN_WAIT2`：该连接已挂断，但正在等待对方主机响应断线确认的数据包中
    * `TIME_WAIT`：该连接已挂断，但socket还在网络上等待结束
    * `LISTEN`：通常在服务的监听port，可以使用-l参数查阅

netstat的功能就是查看网络的连接状态，而网络连接状态中，又以**我目前开了多少port在等待客户端的连接**以及**目前我的网络连接状态中，有多少连接已建立或产生问题**最常见

**Examples:**

1. **`netstat -n | awk '/^tcp/ {++y[$NF]} END {for(w in y) print w, y[w]}'`**
1. **`netstat -nlp | grep <pid>`** 

## 5.2 tc

流量的处理由三种对象控制，它们是：`qdisc`（排队规则）、`class`（类别）和`filter`（过滤器）。

**Pattern:**

* `tc qdisc [ add | change | replace | link ] dev DEV [ parent qdisc-id | root ] [ handle qdisc-id ] qdisc [ qdisc specific parameters ]`
* `tc class [ add | change | replace ] dev DEV parent qdisc-id [ classid class-id ] qdisc [ qdisc specific parameters ]`
* `tc filter [ add | change | replace ] dev DEV [ parent qdisc-id | root ] protocol protocol prio priority filtertype [ filtertype specific parameters ] flowid flow-id`
* `tc [-s | -d ] qdisc show [ dev DEV ]`
* `tc [-s | -d ] class show dev DEV`
* `tc filter show dev DEV`

**Options:**

**Examples:**

* `tc qdisc add dev em1 root netem delay 300ms`：设置网络延迟300ms
* `tc qdisc add dev em1 root netem loss 8% 20%`：设置8%~20%的丢包率 
* `tc qdisc del dev em1 root `：删除指定设置

## 5.3 ss

`ss`是`Socket Statistics`的缩写。顾名思义，`ss`命令可以用来获取`socket`统计信息，它可以显示和`netstat`类似的内容。`ss`的优势在于它能够显示更多更详细的有关TCP和连接状态的信息，而且比`netstat`更快速更高效。

当服务器的socket连接数量变得非常大时，无论是使用`netstat`命令还是直接`cat /proc/net/tcp`，执行速度都会很慢。

`ss`快的秘诀在于，它利用到了TCP协议栈中`tcp_diag`。`tcp_diag`是一个用于分析统计的模块，可以获得Linux内核中第一手的信息，这就确保了`ss`的快捷高效

**Pattern:**

* `ss [-talspnr]`

**Options:**

* `-t`：列出tcp-socket
* `-u`：列出udp-socket
* `-a`：列出所有socket
* `-l`：列出所有监听的socket
* `-e`：显式socket的详细信息，包括`indoe`号
* `-s`：仅显示摘要信息
* `-p`：显示用了该socket的进程
* `-n`：不解析服务名称
* `-r`：解析服务名称
* `-m`：显示内存占用情况
* `-h`：查看帮助文档
* `-i`：显示tcp-socket详情

**Examples:**

* `ss -t -a`：显示所有tcp-socket
* `ss -ti -a`：显示所有tcp-socket以及详情
* `ss -u –a`：显示所有udp-socket
* `ss -nlp | grep 22`：找出打开套接字/端口应用程序
* `ss -o state established`：显示所有状态为established的socket
* `ss -o state FIN-WAIT-1 dst 192.168.25.100/24`：显示出处于`FIN-WAIT-1`状态的，目标网络为`192.168.25.100/24`所有socket
* `ss -nap`
* `ss -nap -e`
* `ss -naptu`

## 5.4 ip

### 5.4.1 ip address

具体用法参考`ip address help`

**Examples:**

* `ip -4 addr show scope global`
* `ip -6 addr show scope global`
* `ip -4 addr show scope host`

### 5.4.2 ip link

具体用法参考`ip link help`

**Examples:**

* `ip link`：查看所有网卡
* `ip link up`：查看up状态的网卡
* `ip -d link`：查看详细的信息
    * `ip -d link show lo`
* `ip link set eth0 up`：开启网卡
* `ip link set eth0 down`：关闭网卡
* `ip link delete tunl0`：删除网卡
* `cat /sys/class/net/xxx/carrier`：查看网卡是否插了网线（对应于`ip link`的`state UP`或`state DOWN`

### 5.4.3 ip route

具体用法参考`ip route help`

#### 5.4.3.1 route table

**linux最多可以支持255张路由表，每张路由表有一个`table id`和`table name`。其中有4张表是linux系统内置的**

* **`table id = 0`：系统保留**
* **`table id = 255`：本地路由表，表名为`local`**。像本地接口地址，广播地址，以及NAT地址都放在这个表。该路由表由系统自动维护，管理员不能直接修改
    * `ip r show table local`
* **`table id = 254`：主路由表，表名为`main`**。如果没有指明路由所属的表，所有的路由都默认都放在这个表里。一般来说，旧的路由工具（如`route`）所添加的路由都会加到这个表。`main`表中路由记录都是普通的路由记录。而且，使用`ip route`配置路由时，如果不明确指定要操作的路由表，默认情况下也是对主路由表进行操作
    * `ip r show table main`
* **`table id = 253`：称为默认路由表，表名为`default`**。一般来说默认的路由都放在这张表
    * `ip r show table default`

**此外：**

* 系统管理员可以根据需要自己添加路由表，并向路由表中添加路由记录
* 可以通过`/etc/iproute2/rt_tables`文件查看`table id`和`table name`的映射关系。
* 如果管理员新增了一张路由表，需要在`/etc/iproute2/rt_tables`文件中为新路由表添加`table id`和`table name`的映射
* 路由表存储于内存中，通过`procfs`文件系统对用户态露出，具体的文件位置是`/proc/net/route`

#### 5.4.3.2 route type

**`unicast`**：单播路由是路由表中最常见的路由。这是到目标网络地址的典型路由，它描述了到目标的路径。即使是复杂的路由（如下一跳路由）也被视为单播路由。如果在命令行上未指定路由类型，则假定该路由为单播路由

```sh
ip route add unicast 192.168.0.0/24 via 192.168.100.5
ip route add default via 193.7.255.1
ip route add unicast default via 206.59.29.193
ip route add 10.40.0.0/16 via 10.72.75.254
```

**`broadcast`**：此路由类型用于支持广播地址概念的链路层设备（例如以太网卡）。此路由类型仅在本地路由表中使用，通常由内核处理

```sh
ip route add table local broadcast 10.10.20.255 dev eth0 proto kernel scope link src 10.10.20.67
ip route add table local broadcast 192.168.43.31 dev eth4 proto kernel scope link src 192.168.43.14
```

**`local`**：当IP地址添加到接口时，内核会将条目添加到本地路由表中。这意味着IP是本地托管的IP

```sh
ip route add table local local 10.10.20.64 dev eth0 proto kernel scope host src 10.10.20.67
ip route add table local local 192.168.43.12 dev eth4 proto kernel scope host src 192.168.43.14
```

**`nat`**：当用户尝试配置无状态NAT时，内核会将此路由条目添加到本地路由表中

```sh
ip route add nat 193.7.255.184 via 172.16.82.184
ip route add nat 10.40.0.0/16 via 172.40.0.0
```

**`unreachable`**：当对路由决策的请求返回的路由类型不可达的目的地时，将生成ICMP unreachable并返回到源地址

```sh
ip route add unreachable 172.16.82.184
ip route add unreachable 192.168.14.0/26
ip route add unreachable 209.10.26.51
```

**`prohibit`**：当路由选择请求返回具有禁止路由类型的目的地时，内核会生成禁止返回源地址的ICMP

```sh
ip route add prohibit 10.21.82.157
ip route add prohibit 172.28.113.0/28
ip route add prohibit 209.10.26.51
```

**`blackhole`**：匹配路由类型为黑洞的路由的报文将被丢弃。没有发送ICMP，也没有转发数据包

```sh
ip route add blackhole default
ip route add blackhole 202.143.170.0/24
ip route add blackhole 64.65.64.0/18
```

**`throw`**：引发路由类型是一种便捷的路由类型，它会导致路由表中的路由查找失败，从而将路由选择过程返回到RPDB。当有其他路由表时，这很有用。请注意，如果路由表中没有默认路由，则存在隐式抛出，因此尽管合法，但是示例中第一个命令创建的路由是多余的

```sh
ip route add throw default
ip route add throw 10.79.0.0/16
ip route add throw 172.16.0.0/12
```

#### 5.4.3.3 route scope

**`global`**：全局有效

**`site`**：仅在当前站点有效（IPV6）

**`link`**：仅在当前设备有效

**`host`**：仅在当前主机有效

#### 5.4.3.4 route proto

**`proto`：表示路由的添加时机。可由数字或字符串表示，数字与字符串的对应关系详见`/etc/iproute2/rt_protos`**

1. **`redirect`**：表示该路由是因为发生`ICMP`重定向而添加的
1. **`kernel`**：该路由是内核在安装期间安装的自动配置
1. **`boot`**：该路由是在启动过程中安装的。如果路由守护程序启动，它将会清除这些路由规则
1. **`static`**：该路由由管理员安装，以覆盖动态路由

#### 5.4.3.5 route src

这被视为对内核的提示（用于回答：如果我要将数据包发往host X，我该用本机的哪个IP作为Source IP），该提示是关于要为该接口上的`传出`数据包上的源地址选择哪个IP地址

#### 5.4.3.6 Parameter Explanation

**`ip r show table local`参数解释（示例如下）**

1. 第一个字段指明该路由是用于`广播地址`、`IP地址`还是`IP范围`，例如
    * `local 192.168.99.35`表示`IP地址`
    * `broadcast 127.255.255.255`表示`广播地址`
    * `local 127.0.0.0/8 dev`表示`IP范围`
1. 第二个字段指明该路由通过哪个设备到达目标地址，例如
    * `dev eth0 proto kernel`
    * `dev lo proto kernel`
1. 第三个字段指明该路由的作用范围，例如
    * `scope host`
    * `scope link`
1. 第四个字段指明传出数据包的源IP地址
    * `src 127.0.0.1`

```sh
ip route show table local

#-------------------------↓↓↓↓↓↓-------------------------
local 192.168.99.35 dev eth0  proto kernel  scope host  src 192.168.99.35 
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src 127.0.0.1 
broadcast 192.168.99.255 dev eth0  proto kernel  scope link  src 192.168.99.35 
broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1 
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1 
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
#-------------------------↑↑↑↑↑↑-------------------------
```

### 5.4.4 ip rule

基于策略的路由比传统路由在功能上更强大，使用更灵活，它使网络管理员不仅能够根据目的地址而且能够根据报文大小、应用或IP源地址等属性来选择转发路径。简单地来说，linux系统有多张路由表，而路由策略会根据一些条件，将路由请求转向不同的路由表。例如源地址在某些范围走路由表A，另外的数据包走路由表，类似这样的规则是有路由策略rule来控制

在linux系统中，一条路由策略`rule`主要包含三个信息，即`rule`的优先级，条件，路由表。其中rule的优先级数字越小表示优先级越高，然后是满足什么条件下由指定的路由表来进行路由。**在linux系统启动时，内核会为路由策略数据库配置三条缺省的规则，即`rule 0`，`rule 32766`，`rule 32767`（数字是rule的优先级），具体含义如下**：

1. **`rule 0`**：匹配任何条件的数据包，查询路由表`local（table id = 255）`。`rule 0`非常特殊，不能被删除或者覆盖。
1. **`rule 32766`**：匹配任何条件的数据包，查询路由表`main（table id = 254）`。系统管理员可以删除或者使用另外的策略覆盖这条策略
1. **`rule 32767`**：匹配任何条件的数据包，查询路由表`default（table id = 253）`。对于前面的缺省策略没有匹配到的数据包，系统使用这个策略进行处理。这个规则也可以删除
* 在linux系统中是按照rule的优先级顺序依次匹配。假设系统中只有优先级为`0`，`32766`及`32767`这三条规则。那么系统首先会根据规则`0`在本地路由表里寻找路由，如果目的地址是本网络，或是广播地址的话，在这里就可以找到匹配的路由；如果没有找到路由，就会匹配下一个不空的规则，在这里只有`32766`规则，那么将会在主路由表里寻找路由；如果没有找到匹配的路由，就会依据`32767`规则，即寻找默认路由表；如果失败，路由将失败

**Examples:**

```sh
# 增加一条规则，规则匹配的对象是所有的数据包，动作是选用路由表1的路由，这条规则的优先级是32800
ip rule add [from 0/0] table 1 pref 32800

# 增加一条规则，规则匹配的对象是IP为192.168.3.112, tos等于0x10的包，使用路由表2，这条规则的优先级是1500，动作是丢弃。
ip rule add from 192.168.3.112/32 [tos 0x10] table 2 pref 1500 prohibit
```

### 5.4.5 ip netns

```sh
Usage: ip netns list
       ip netns add NAME
       ip netns set NAME NETNSID
       ip [-all] netns delete [NAME]
       ip netns identify [PID]
       ip netns pids NAME
       ip [-all] netns exec [NAME] cmd ...
       ip netns monitor
       ip netns list-id
```

**Examples:**

* `ip netns list`：列出网络命名空间（只会从`/var/run/netns`下读取）
* `ip netns exec test-ns ifconfig`：在网络命名空间`test-ns`中执行`ifconfig`

**与nsenter的区别**：由于`ip netns`只从`/var/run/netns`下读取网络命名空间，而`nsenter`默认会读取`/proc/${pid}/ns/net`。但是`docker`会隐藏容器的网络命名空间，即默认不会在`/var/run/netns`目录下创建命名空间，因此如果要使用`ip netns`进入到容器的命名空间，还需要做个软连接

```sh
pid=$(docker inspect -f '{{.State.Pid}}' ${container_id})
mkdir -p /var/run/netns/
ln -sfT /proc/$pid/ns/net /var/run/netns/$container_id
```

## 5.5 iptables

### 5.5.1 Viewing Rules

**Pattern:**

* `iptables [-S] [-t tables] [-L] [-nv]`

**Options:**

* `-S`：输出指定table的规则，若没有指定table，则输出所有的规则，类似`iptables-save`
* `-t`：后面接table，例如nat或filter，若省略此项目，则使用默认的filter
* `-L`：列出目前的table的规则
* `-n`：不进行IP与HOSTNAME的反查，显示信息的速度回快很多
* `-v`：列出更多的信息，包括通过该规则的数据包总数，相关的网络接

**Output Details:**

* 每一个Chain就是每个链，Chain所在的括号里面的是默认的策略(即没有规则匹配时采取的操作(target))
* `target`：代表进行的操作
    * **`ACCEPT`**：表示放行
    * **`DROP`**：表示丢弃
    * **`QUEUE`**：将数据包传递到用户空间
    * **`RETURN`**：表示停止遍历当前链，并在上一个链中的下一个规则处恢复（假设在`Chain A`中调用了`Chain B`，`Chain B RETURN`后，继续`Chain A`的下一个规则）
    * **还可以是一个自定义的Chain**
* `port`：代表使用的数据包协议，主要有TCP、UDP、ICMP3中数据包
* `opt`：额外的选项说明
* `source`：代表此规则是针对哪个来源IP进行限制
* `destination`：代表此规则是针对哪个目标IP进行限制

**Examples:**

* `iptables -nL`
* `iptables -t nat -nL`

由于`iptables`的上述命令的查看只是做格式化的查阅，要详细解释每个规则可能会与原规则有出入，因此，建议使用`iptables-save`这个命令来查看防火墙规则

**Pattern:**

* `iptables-save [-t table]`

**Options:**

* `-t`：可以针对某些表格来输出，例如仅针对NAT或Filter等

**Output Details:**

* 星号开头的指的是表格，这里为Filter
* 冒号开头的指的是链，3条内建的链，后面跟策略
* 链后面跟的是`[Packets:Bytes]`，分别表示通过该链的数据包/字节的数量

### 5.5.2 Clearing Rules

**Pattern:**

* `iptables [-t tables] [-FXZ] [chain]`

**Options:**

* `-F [chain]`：清除指定chain或者所有chian中的所有的已制定的规则
* `-X [chain]`：清除指定`user-defined chain`或所有`user-defined chain`
* `-Z [chain]`：将指定chain或所有的chain的计数与流量统计都归零

### 5.5.3 Defining Default Policies

当数据包不在我们设置的规则之内时，该数据包的通过与否都以Policy的设置为准

**Pattern:**

* `iptables [-t nat] -P [INPUT,OUTPUT,FORWARD] [ACCEPT,DROP]`

**Options:**

* `-P`：定义策略(Policy)
    * `ACCEPT`：该数据包可接受
    * `DROP`：该数据包直接丢弃，不会让Client知道为何被丢弃

**Examples:**

* `iptables -P INPUT DROP`
* `iptables -P OUTPUT ACCEPT`
* `iptables -P FORWARD ACCEPT`

### 5.5.4 Basic Packet Matching: IP, Network, and Interface Devices

**Pattern:**

* `iptables [-t tables] [-AI chain] [-io ifname] [-p prop] [-s ip/net] [-d ip/net] -j [ACCEPT|DROP|REJECT|LOG]`

**Options:**

* `-t tables`：指定tables，默认的tables是`filter`
* `-AI chain`：针对某条链进行规则的"插入"或"累加"
    * `-A chain`：新增加一条规则，该规则增加在原规则后面，例如原来有4条规则，使用-A就可以加上第五条规则
    * `-I chain [rule num]`：插入一条规则，可以指定插入的位置。如果没有指定此规则的顺序，默认插入变成第一条规则
    * `链`：可以是内建链（`INPUT`、`OUTPUT`、`FORWARD`、`PREROUTING`、`POSTROUTING`）；也可以是自定义链
* `-io ifname`：设置数据包进出的接口规范
    * `-i`：数据包所进入的那个网络接口，例如eth0，lo等，需要与INPUT链配合
    * `-o`：数据包所传出的网络接口，需要与OUTPUT配合
* `-p prop`：设置此规则适用于哪种数据包格式
    * 主要的数据包格式有：tcp、udp、icmp以及all
* `-s ip/net`：设置此规则之数据包的来源地，可指定单纯的IP或网络
    * `ip`：例如`192.168.0.100`
    * `net`：例如`192.168.0.0/24`、`192.168.0.0/255.255.255.0`均可
    * **若规范为"不许"时，加上`!`即可，例如`! -s 192.168.100.0/24`**
* `-d ip/net`：同-s，只不过这里是目标的
* `-j target`：后面接`target`
    * `ACCEPT`
    * `DROP`
    * `QUEUE`
    * `RETURN`
    * **其他Chain**
    * **规则的匹配过程类似于函数栈，从一个链跳到另一个链相当于函数调用。某些target会停止匹配过程，比如常见的`ACCEPT`、`DROP`、`SNAT`、`MASQUERADE`等等；某些target不会停止匹配过程，比如当target是另一个`Chain`时，或者常见的`LOG`、`ULOG`、`TOS`等**
* **重要的原则：没有指定的项目，就表示该项目完全接受**
    * 例如`-s`和`-d`不指定，就表示来源或去向的任意IP/网络都接受

**Examples:**

* `iptables -A INPUT -i lo -j ACCEPT`：不论数据包来自何处或去向哪里，只要是lo这个接口，就予以接受，这就是所谓的信任设备
* `iptables -A INPUT -i eth1 -j ACCEPT`：添加接口为eth1的网卡为信任设备
* `iptables -A INPUT -s 192.168.2.200 -j LOG`：该网段的数据包，其相关信息就会被写入到内核日志文件中，即`/var/log/messages`，然后，该数据包会继续进行后续的规则比对(这一点与其他规则不同)
* 配置打印日志的规则（这些规则要放在第一条，否则命中其他规则时，当前规则就不执行了）
    * `iptables -I INPUT -p icmp -j LOG --log-prefix "liuye-input: "`
    * `iptables -I FORWARD -p icmp -j LOG --log-prefix "liuye-forward: "`
    * `iptables -I OUTPUT -p icmp -j LOG --log-prefix "liuye-output: "`
    * `iptables -t nat -I PREROUTING -p icmp -j LOG --log-prefix "liuye-prerouting: "`
    * `iptables -t nat -I POSTROUTING -p icmp -j LOG --log-prefix "liuye-postrouting: "`

### 5.5.5 Rules for TCP and UDP: Port-based Rules

TCP与UDP比较特殊的就是端口(port)，在TCP方面则另外有所谓的连接数据包状态，包括最常见的SYN主动连接的数据包格式

**Pattern:**

* `iptables [-AI 链] [-io 网络接口] [-p tcp|udp] [-s 来源IP/网络] [--sport 端口范围] [-d 目标IP/网络] [--dport 端口范围] --syn -j [ACCEPT|DROP|REJECT]`

**Options:**

* `--sport 端口范围`：限制来源的端口号码，端口号码可以是连续的，例如1024:65535
* `--dport 端口范围`：限制目标的端口号码
* `--syn`：主动连接的意思
* **与之前的命令相比，就是多了`--sport`以及`--dport`这两个选项，因此想要使用`--dport`或`--sport`必须加上`-p tcp`或`-p udp`才行**

**Examples:**

* `iptables -A INPUT -i eth0 -p tcp --dport 21 -j DROP`：想要进入本机port 21的数据包都阻挡掉
* `iptables -A INPUT -i eth0 -p tcp --sport 1:1023 --dport 1:1023 --syn -j DROP`：来自任何来源port 1:1023的主动连接到本机端的1:1023连接丢弃

### 5.5.6 iptables Matching Extensions

`iptables`可以使用扩展的数据包匹配模块。当指定`-p`或`--protocol`时，或者使用`-m`或`--match`选项，后跟匹配的模块名称；之后，取决于特定的模块，可以使用各种其他命令行选项。可以在一行中指定多个扩展匹配模块，并且可以在指定模块后使用`-h`或`--help`选项来接收特定于该模块的帮助文档（`iptables -m comment -h`，输出信息的最下方有`comment`模块的参数说明）

**常用模块**，详细内容请参考[Match Extensions](https://linux.die.net/man/8/iptables)

1. `comment`：增加注释
1. `conntrack`：与连接跟踪结合使用时，此模块允许访问比“状态”匹配更多的连接跟踪信息。（仅当iptables在支持该功能的内核下编译时，此模块才存在）
1. `tcp`
1. `udp`

### 5.5.7 iptables Target Extensions

iptables可以使用扩展目标模块，并且可以在指定目标后使用`-h`或`--help`选项来接收特定于该目标的帮助文档（`iptables -j DNAT -h`）

**常用（可以通过`man iptables`或`man 8 iptables-extensions`，并搜索关键词`target`）：**

1. `ACCEPT`
1. `DROP`
1. `RETURN`
1. `REJECT`
1. `DNAT`
1. `SNAT`
1. `MASQUERADE`：用于实现自动化SNAT，若出口ip经常变化的话，可以通过该目标来实现SNAT

### 5.5.8 ICMP Packet Rules Comparison: Designed to Control Ping Responses

**Pattern:**

* `iptables -A INPUT [-p icmp] [--icmp-type 类型] -j ACCEPT`

**Options:**

* `--icmp-type`：后面必须要接ICMP的数据包类型，也可以使用代号

## 5.6 bridge

### 5.6.1 bridge link

Bridge port

**Examples:**

1. `bridge link show`

### 5.6.2 bridge fdb

Forwarding Database entry

**Examples:**

1. `bridge fdb show`

### 5.6.3 bridge mdb

Multicast group database entry

### 5.6.4 bridge vlan

VLAN filter list

### 5.6.5 bridge monitor

## 5.7 route

**Pattern:**

* `route [-nee]`
* `route add [-net|-host] [网络或主机] netmask [mask] [gw|dev]`
* `route del [-net|-host] [网络或主机] netmask [mask] [gw|dev]`

**Options:**

* `-n`：不要使用通信协议或主机名，直接使用IP或port number，即在默认情况下，route会解析出该IP的主机名，若解析不到则会有延迟，因此一般加上这个参数
* `-ee`：显示更详细的信息
* `-net`：表示后面接的路由为一个网络
* `-host`：表示后面接的为连接到单个主机的路由
* `netmask`：与网络有关，可设置netmask决定网络的大小
* `gw`：gateway的缩写，后接IP数值
* `dev`：如果只是要制定由哪块网卡连接出去，则使用这个设置，后接网卡名，例如eth0等

**打印参数说明：**

* **Destination、Genmask**：这两个参数就分别是network与netmask
* **Gateway**：该网络通过哪个Gateway连接出去，若显示`0.0.0.0(default)`表示该路由直接由本级传送，也就是通过局域网的MAC直接传送，如果显示IP的话，表示该路由需要经过路由器(网关)的帮忙才能发送出去
* **Flags**：
    * `U(route is up)`：该路由是启动的
    * `H(target is a host)`：目标是一台主机而非网络
    * `G(use gateway)`：需要通过外部的主机来传递数据包
    * `R(reinstate route for dynamic routing)`：使用动态路由时，恢复路由信息的标志
    * `D(Dynamically installed by daemon or redirect)`：动态路由
    * `M(modified from routing daemon or redirect)`：路由已经被修改了
    * `!(reject route)`：这个路由将不会被接受
* **Iface**：该路由传递数据包的接口

**Examples:**

* `route -n`
* `route add -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`
* `route del -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`

## 5.8 nsenter

nsenter用于在某个网络命名空间下执行某个命令。例如某些docker容器是没有curl命令的，但是又想在docker容器的环境下执行，这个时候就可以在宿主机上使用nsenter

**Pattern:**

* `nsenter -t <pid> -n <cmd>`

**Options:**

* `-t`：后接进程id
* `-n`：后接需要执行的命令

**Examples:**

* `nsenter -t 123 -n curl baidu.com`

## 5.9 tcpdump

**Pattern:**

* `tcpdump [-AennqX] [-i 接口] [port 端口号] [-w 存储文件名] [-c 次数] [-r 文件] [所要摘取数据包的格式]`

**Options:**

* `-A`：数据包的内容以ASCII显示，通常用来抓取WWW的网页数据包数据
* `-e`：使用数据链路层(OSI第二层)的MAC数据包数据来显示
* `-n`：直接以IP以及port number显示，而非主机名与服务名称
* `-q`：仅列出较为简短的数据包信息，每一行的内容比较精简
* `-X`：可以列出十六进制(hex)以及ASCII的数据包内容，对于监听数据包很有用
* `-i`：后面接要监听的网络接口，例如eth0等
* `port`：后接要监听的端口号，例如22等
* `-w`：将监听得到的数据包存储下来
* `-r`：从后面接的文件将数据包数据读出来
* `-c`：监听数据包数，没有这个参数则会一直监听，直到[ctrl]+C
* `-vv/-vvv`：输出更多的信息，配合`-w`使用时，会显示目前监听的多少数据包
* 此外，还可以用`and`拼接多个条件

**显示格式说明：**

* `src > dst: flags data-seqno ack window urgent options`
* `src`: 源ip/port（或域名）
* `dst`: 宿ip/port（或域名）
* `flags`: TCP标志位的组合
    * `S`: `SYNC`
    * `F`: `FIN`
    * `P`: `PUSH`
    * `R`: `RST`
    * `U`: `URG`
    * `W`: `ECN CWR`
    * `E`: `ECN-Echo`
    * `.`: `ACK`
    * `none`: 无任何标志位
* `data-seqno`: 数据包的序号，可能是一个或多个（`1:4`）
* `ack`: 表示期望收到的下一个数据包的序号
* `window`: 接收缓存的大小
* `urgent`: 表示当前数据包是否包含紧急数据
* `option`: 用`<>`包围的部分

**Examples:**

* `tcpdump -i lo0 port 22 -w output7.cap`
* `tcpdump -i eth0 host www.baidu.com`
* `tcpdump -i any -w output1.cap`
* `tcpdump -n -i any -e icmp and host www.baidu.com`

### 5.9.1 tcpdump Conditional Expressions

该表达式用于决定哪些数据包将被打印。如果不给定条件表达式，网络上所有被捕获的包都会被打印，否则，只有满足条件表达式的数据包被打印

表达式由一个或多个`表达元`组成（表达元, 可理解为组成表达式的基本元素）。一个表达元通常由一个或多个修饰符`qualifiers`后跟一个名字或数字表示的`id`组成（即：`qualifiers id`）。有三种不同类型的修饰符：`type`，`direction`以及`protocol`

**表达元格式：`[protocol] [direction] [type] id`**

* **type**：包括`host`、`net`、`port`、`portrange`。默认值为`host`
* **direction**：包括`src`、`dst`、`src and dst`、`src or dst`4种可能的方向。默认值为`src or dst`
* **protocol**：包括`ether`、`fddi`、`tr`、`wlan`、`ip`、`ip6`、`arp`、`rarp`、`decnet`、`tcp`、`upd`等等。默认包含所有协议
    * **其中`protocol`要与`type`相匹配，比如当`protocol`是`tcp`时，那么`type`就不能是`host`或`net`，而应该是`port`或`portrange`**
* **逻辑运算**：`条件表达式`可由多个`表达元`通过`逻辑运算`组合而成。逻辑运算包括（`!`或`not`）、（`&&`或`and`）、（`||`或`or`）三种逻辑运算

**Examples:**

* `tcp src port 123`
* `tcp src portrange 100-200`
* `host www.baidu.com and port 443`

### 5.9.2 tips

如何查看具体的协议，例如ssh协议

利用wireshark

1. 任意选中一个`length`不为`0`的数据包，右键选择解码（`decode as`），右边`Current`一栏，选择对应的协议即可

### 5.9.3 How to Use tcpdump to Capture HTTP Protocol Data from docker

docker使用的是域套接字，对应的套接字文件是`/var/run/docker.sock`，而域套接字是不经过网卡设备的，因此tcpdump无法直接抓取相应的数据

**方式1：改变client的访问方式**

```sh
# 在终端1执行，监听本机的18080，然后将流量转到docker的域套接字
# 两个-d参数会输出fatel、error以及notice级别的信息
socat -d -d TCP-LISTEN:18080,fork,bind=127.0.0.1 UNIX:/var/run/docker.sock

# 在终端2执行tcpdump进行抓包
tcpdump -i lo -netvv port 18080 -w file1.cap

# 在终端3执行docker命令
docker -H tcp://localhost:18080 images
```

**方式2：不改变client的访问方式**

```sh
# 在终端1执行，mv命令修改原始域套接字的文件名，这个操作不会改变文件的fd，因此，在移动后，docker监听的套接字是/var/run/docker.sock.original
sudo mv /var/run/docker.sock /var/run/docker.sock.original
sudo socat TCP-LISTEN:18081,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock.original

# 在终端2执行
sudo socat UNIX-LISTEN:/var/run/docker.sock,fork TCP-CONNECT:127.0.0.1:18081

# 在终端3执行tcpdump进行抓包
tcpdump -i lo -vv port 18081 -w file2.cap

# 在终端3执行docker命令
docker -H tcp://localhost:18081 images
```

## 5.10 tcpflow

tcpflow is a command-line tool used to capture and analyze network traffic, specifically Transmission Control Protocol (TCP) connections. It is often used by network administrators and developers for debugging and monitoring network communication.

**Key Features of tcpflow:**

* Capture TCP Streams: `tcpflow` captures and records data transmitted in TCP connections. Unlike packet capture tools like `tcpdump`, which show individual packets, `tcpflow` reconstructs and displays the actual data streams as they appear at the application layer.
* Session Reconstruction: It organizes captured data by connection, storing the data streams in separate files or displaying them on the console. This allows for easy inspection of the content exchanged during a session.
* Readable Output: The tool provides human-readable output by reconstructing the sequence of bytes sent in each TCP connection, making it easier to analyze protocols and troubleshoot issues.
* Filtering: Similar to tools like `tcpdump`, `tcpflow` can filter traffic based on criteria like source/destination IP addresses, ports, or other protocol-level details

**Examples:**

* `tcpflow -i eth0`
* `tcpflow -i any host www.google.com`

## 5.11 tcpkill

`tcpkill`用于杀死tcp连接，语法与`tcpdump`基本类似。其工作原理非常简单，首先会监听相关的数据报文，获取了`sequence number`之后，然后发起`Reset`报文。因此，当且仅当连接有报文交互的时候，`tcpkill`才能起作用

**Install:**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 dsniff
yum install -y dsniff
```

**Pattern:**

* `tcpkill [-i interface] [-1...9] expression`

**Options:**

* `-i`：指定网卡
* `-1...9`：优先级，优先级越高越容易杀死
* `expression`：表达元，与tcpdump类似

**Examples:**

* `tcpkill -9 -i any host 127.0.0.1 and port 22`

## 5.12 socat

**Pattern:**

* `socat [options] <address> <address>`
* 其中这2个`address`就是关键了，`address`类似于一个文件描述符，Socat所做的工作就是在2个`address`指定的描述符间建立一个 `pipe`用于发送和接收数据

**Options:**

* `address`：可以是如下几种形式之一
    * `-`：表示标准输入输出
    * `/var/log/syslog`：也可以是任意路径，如果是相对路径要使用`./`，打开一个文件作为数据流。
    * `TCP:127.0.0.1:1080`：建立一个TCP连接作为数据流，TCP也可以替换为UDP
    * `TCP-LISTEN:12345`：建立TCP监听端口，TCP也可以替换为UDP
    * `EXEC:/bin/bash`：执行一个程序作为数据流。

**Examples:**

* `socat - /var/www/html/flag.php`：通过Socat读取文件，绝对路径
* `socat - ./flag.php`：通过Socat读取文件，相对路径
* `echo "This is Test" | socat - /tmp/hello.html`：写入文件
* `socat TCP-LISTEN:80,fork TCP:www.baidu.com:80`：将本地端口转到远端
* `socat TCP-LISTEN:12345 EXEC:/bin/bash`：在本地开启shell代理

## 5.13 dhclient

**Pattern:**

* `dhclient [-dqr]`

**Options:**

* `-d`：总是以前台方式运行程序
* `-q`：安静模式，不打印任何错误的提示信息
* `-r`：释放ip地址

**Examples:**

* `dhclient`：获取ip
* `dhclient -r`：释放ip

## 5.14 arp

**Examples:**

* `arp`：查看arp缓存
* `arp -n`：查看arp缓存，显示ip不显示域名
* `arp 192.168.56.1`：查看`192.168.56.1`这个ip的mac地址

## 5.15 [arp-scan](https://github.com/royhills/arp-scan)

**Install:**

```sh
yum install -y git
git clone https://github.com/royhills/arp-scan.git

cd arp-scan

yum install -y autoconf automake libtool
autoreconf --install

yum install -y libpcap.x86_64 libpcap-devel.x86_64
./configure

yum install -y make
make

make install
```

**Examples:**

* `arp-scan -l`
* `arp-scan 10.0.2.0/24`
* `arp-scan -I enp0s8 -l`
* `arp-scan -I enp0s8 192.168.56.1/24`

## 5.16 ping

**Options:**

* `-c`：后接发包次数
* `-s`：指定数据大小
* `-M [do|want|dont]`：设置MTU策略，`do`表示不允许分片；`want`表示当数据包比较大时可以分片；`dont`表示不设置`DF`标志位

**Examples:**

* `ping -c 3 www.baidu.com`
* `ping -s 1460 -M do baidu.com`：发送大小包大小是1460（+28）字节，且禁止分片

## 5.17 arping

**Pattern:**

* `arping [-fqbDUAV] [-c count] [-w timeout] [-I device] [-s source] destination`

**Options:**

* `-c`：指定发包次数
* `-b`：持续用广播的方式发送request
* `-w`：指定超时时间
* `-I`：指定使用哪个以太网设备
* `-D`：开启地址冲突检测模式

**Examples:**

* `arping -c 1 -w 1 -I eth0 -b -D 192.168.1.1`：该命令可以用于检测局域网是否存在IP冲突
    * 若该命令行返回0：说明不存在冲突；否则存在冲突

**-D参数为啥能够检测ip冲突**

* 环境说明
    * 机器A，ip为：`192.168.2.2/24`，mac地址为`68:ed:a4:39:92:4b`
    * 机器B，ip为：`192.168.2.2/24`，mac地址为`68:ed:a4:39:91:e6`
    * 路由器，ip为：`192.168.2.1/24`，mac地址为`c8:94:bb:af:bd:8c`
* 在机器A执行`arping -c 1 -w 1 -I eno1 -b 192.168.2.2`，分别在机器A、机器B上抓包，抓包结果如下
    * ![arping-1](/images/Linux-Frequently-Used-Commands/arping-1.png)
    * ![arping-2](/images/Linux-Frequently-Used-Commands/arping-2.png)
    * arp-reply发送到路由器后，路由器不知道将数据包转发给谁，就直接丢弃了
* 在机器A执行`arping -c 1 -w 1 -I eno1 -D -b 192.168.2.2`，分别在机器A、机器B上抓包，抓包结果如下
    * ![arping-3](/images/Linux-Frequently-Used-Commands/arping-3.png)
    * ![arping-3](/images/Linux-Frequently-Used-Commands/arping-4.png)
    * arp-reply直接指定了目标机器的mac地址，因此直接送达机器A

## 5.18 hping3

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 hping3
yum install -y hping3
```

**Options:**

* `-c`：发送、接收数据包的数量（如果只发包不收包是不会停止的）
* `-d`：指定数据包大小（不包含header）
* `-S`：只发送syn数据包
* `-w`：设置tcp窗口大小
* `-p`：目的端口
* `--flood`：洪范模式，尽可能快地发送数据包
* `--rand-source`：使用随机ip作为源IP

**Examples:**

* `hping3 -c 10000 -d 120 -S -w 64 -p 21 --flood --rand-source www.baidu.com`

## 5.19 iperf

**网络测速工具，一般用于局域网测试。互联网测速：[speedtest](https://github.com/sivel/speedtest-cli)**

**Examples:**

* `iperf -s -p 3389 -i 1`：服务端
* `iperf -c <server_addr> -p 3389 -i 1`：客户端

## 5.20 nc

**Examples:**

* `nc -zv 127.0.0.1 22`: Test connectivity.

# 6 Monitoring

## 6.1 ssh

**Pattern:**

* `ssh [-f] [-o options] [-p port] [account@]host [command]`

**Options:**

* `-f`：需要配合后面的[command]，不登录远程主机直接发送一个命令过去而已
* `-o`：后接`options`
    * `ConnectTimeout=<seconds>`：等待连接的秒数，减少等待的事件
    * `StrictHostKeyChecking=[yes|no|ask]`：默认是ask，若要让public key主动加入known_hosts，则可以设置为no即可
* `-p`：后接端口号，如果sshd服务启动在非标准的端口，需要使用此项目

**Examples:**

* `ssh 127.0.0.1`：由于SSH后面没有加上账号，因此默认采用当前的账号来登录远程服务器
* `ssh student@127.0.0.1`：账号为该IP的主机上的账号，而非本地账号哦
* `ssh student@127.0.0.1 find / &> ~/find1.log`
* `ssh -f student@127.0.0.1 find / &> ~/find1.log`：会立即注销127.0.0.1，find在远程服务器运行
* `ssh demo@1.2.3.4 '/bin/bash -l -c "xxx.sh"'`：以`login shell`登录远端，并执行脚本，其中`bash`的参数`-l`就是指定以`login shell`的方式
    * 整个命令最好用引号包围起来，否则复杂命令的参数可能会解析失败，例如
        ```sh
        # -al 参数会丢失
        ssh -o StrictHostKeyChecking=no test@1.2.3.4 /bin/bash -l -c 'ls -al'
        # -al 参数正常传递
        ssh -o StrictHostKeyChecking=no test@1.2.3.4 "/bin/bash -l -c 'ls -al'"
        # 用 eval 时，也需要加上引号，注意需要转义
        eval "ssh -o StrictHostKeyChecking=no test@1.2.3.4 \"/bin/bash -l -c 'ls -al'\""
        ```

### 6.1.1 Passwordless Login

**方法1（手动)：**

```sh
# 创建 rsa 密钥对（如果之前没有的话）
ssh-keygen -t rsa

# 将本机的公钥 ~/.ssh/id_rsa.pub 放入目标机器目标用户的 ~/.ssh/authorized_keys 文件中
ssh user@target 'mkdir ~/.ssh; chmod 700 ~/.ssh'
cat ~/.ssh/id_rsa.pub | ssh user@target 'cat >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys'
```

**方法2（自动，`ssh-copy-id`）**

```sh
# 创建 rsa 密钥对（如果之前没有的话）
ssh-keygen -t rsa

# 将本机的公钥 ~/.ssh/id_rsa.pub 放入目标机器目标用户的 ~/.ssh/authorized_keys 文件中
ssh-copy-id user@target
```

### 6.1.2 Disable Password Login

Modify `/etc/ssh/sshd_config`

```
PasswordAuthentication no
```

### 6.1.3 Prevent Disconnection Due to Inactivity

Modify `/etc/ssh/sshd_config`, it is worked on SSH-level. And there's another config named `TCPKeepAlive`, which is worked on TCP-level.

```
ClientAliveInterval 60
ClientAliveCountMax 3
```

### 6.1.4 Tunnels

**Pattern:**

* `ssh -L [local_bind_addr:]local_port:remote_host:remote_port [-fN] middle_host`
    * `local`与`middle_host`互通
    * `middle_host`与`remote_host`互通（当然，`remote_host`可以与`middle_host`相同）
    * **路径：`frontend --tcp--> local_host:local_port --tcp over ssh--> middle_host:22 --tcp--> remote_host:remote_port`**

**Options:**

* `-f`：在后台运行
* `-N`：不要执行远程命令

**Examples:**

* `ssh -L 5901:127.0.0.1:5901 -N -f user@remote_host`：仅监听在`127.0.0.1`上
* `ssh -L "*:5901:127.0.0.1:5901" -N -f user@remote_host`：监听在所有ip上
    * 同`ssh -g -L 5901:127.0.0.1:5901 -N -f user@remote_host`

### 6.1.5 WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED

远端机器的RSA指纹发生变化后，再次ssh登录就会出现上述错误信息。有两种修复方式：

1. 删除`.ssh/known_hosts`中与指定`hostname or IP`相关的记录
1. 使用`ssh-keygen`删除`.ssh/known_hosts`中与指定`hostname or IP`相关的记录
    ```sh
    # 不加 -f 参数，则会默认修改当前用户对应的 .ssh/known_hosts 文件
    ssh-keygen -f "/Users/hechenfeng/.ssh/known_hosts" -R "<hostname or IP>"
    ```

### 6.1.6 Specify Password

```sh
sshpass -p 'xxxxx' ssh -o StrictHostKeyChecking=no test@1.2.3.4
```

## 6.2 scp

**Pattern:**

* `scp [-pPr] [-l 速率] local_file [account@]host:dir`
* `scp [-pPr] [-l 速率] [account@]host:file local_dir`

**Options:**

* `-p`：保留源文件的权限信息
* `-P`：指定端口号
* `-r`：复制来源为目录时，可以复制整个目录(含子目录)
* `-l`：可以限制传输速率，单位Kbits/s

**Examples:**

* `scp /etc/hosts* student@127.0.0.1:~`
* `scp /tmp/Ubuntu.txt root@192.168.136.130:~/Desktop`
* `scp -P 16666 root@192.168.136.130:/tmp/test.log ~/Desktop`：指定主机`192.168.136.130`的端口号为16666
* `scp -r local_folder remote_username@remote_ip:remote_folder `

## 6.3 watch

**Pattern:**

* `watch [option] [cmd]`

**Options:**

* `-n`：watch缺省该参数时，每2秒运行一下程序，可以用`-n`或`-interval`来指定间隔的时间
* `-d`：`watch`会高亮显示变化的区域。`-d=cumulative`选项会把变动过的地方(不管最近的那次有没有变动)都高亮显示出来
* `-t`：关闭watch命令在顶部的时间间隔命令，当前时间的输出

**Examples:**

* `watch -n 1 -d netstat -ant`：每隔一秒高亮显示网络链接数的变化情况
* `watch -n 1 -d 'pstree | grep http'`：每隔一秒高亮显示http链接数的变化情况
* `watch 'netstat -an | grep :21 | grep <ip> | wc -l'`：实时查看模拟攻击客户机建立起来的连接数
* `watch -d 'ls -l | grep scf'`：监测当前目录中 scf' 的文件的变化
* `watch -n 10 'cat /proc/loadavg'`：10秒一次输出系统的平均负载

## 6.4 top

**Pattern:**

* `top [-H] [-p <pid>]`

**Options:**

* `-H`：显示线程
* `-p`：查看指定进程
* `-b`：非交互式，通常与`-n`参数一起使用，`-n`用于指定统计的次数

**Examples:**

* `top -p 123`：查看进程号为123的进程
* `top -Hp 123`：查看进程号为123以及该进程的所有线程
* `top -b -n 3`

**打印参数说明：**

* **第一行**：
    * 目前的时间
    * 开机到目前为止所经过的时间
    * 已经登录的人数
    * 系统在1，5，15分钟的平均工作负载
* **第二行**：显示的是目前进程的总量，与各个状态下进程的数量
* **第三行**：显示的CPU整体负载，特别注意wa，这个代表的是I/Owait，通常系统变慢都是I/O产生的问题比较大
* **第四五行**：物理内存与虚拟内存的使用情况，注意swap的使用量越少越好，大量swap被使用说明系统物理内存不足
* **第六行**：top进程中，输入命令时显示的地方
* **第七行以及以后**：每个进程的资源使用情况
    * PID：每个进程的ID
    * USER：进程所属用户名称
    * PR：Priority，优先顺序，越小优先级越高
    * NI：Nice，与Priority有关，越小优先级越高
    * %CPU：CPU使用率
    * %MEN：内存使用率
    * TIME+：CPU使用时间累加
    * COMMAND
* **top默认使用CPU使用率作为排序的终点，键入`h`显示帮助菜单**
* **排序顺序**
    * `P`：按CPU使用量排序，默认从大到小，`R`更改为从小到大
    * `M`：按内存使用量排序，默认从大到小，`R`更改为从小到大
    * `T`：按使用时间排序，默认从大到小，`R`更改为从小到大
* **其他功能按键**
    * `1`：概览信息中分别展示每个核的使用状态
    * `2`：概览信息和只展示所有核的平均使用状态
    * `x`：高亮排序的列
    * `-R`：反转排序
    * `n [num]`：只显示前几列，当num=0时，表示无限制
    * `l`：调整cpu负载信息的展示方式
    * `t`：调整cpu以及任务详情的展示方式
    * `m`：调整memory详情的展示方式
    * `c`：展示完整command
    * `V`：以树型格式展示command
    * `H`：展示线程
    * `W`：将当前交互式的一些配置（比如是否展示每个cpu的状态，是否以cpu使用量排序等等）存储到配置文件`~/.toprc`中，然后我们就可以用`top -b -n 1`这种非交互的方式来获取top的输出了（会读取`~/.toprc`中的内容）
* `VIRT, virtual memory size`：进程使用的总虚拟内存，包括代码、数据、共享库、被置换的`page`、已映射但未使用的`page`
    * `VIRT = SWAP + RES`
* `SWAP, swapped size`：进程被置换的虚拟内存
* `RES, resident memory size`：进程非被置换的物理内存
    * `RES = CODE + DATA`
* `CODE, text resident set size or TRS`：进程代码所占的物理内存
* `DATA, data resident set size or DRS`：进程非代码所占的物理内存（包括数据以及堆栈）
* `SHR, shared memory size`：进程使用的共享内存大小

## 6.5 htop

**`htop`在界面上提供了非常详细的操作方式**

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 htop
yum install -y htop
```

**Examples:**

* `htop`

## 6.6 slabtop

`slabtop`用于展示内核的`slab cache`相关信息

**Examples:**

* `slabtop`

## 6.7 sar

sar是由有类似日志切割的功能的，它会依据`/etc/cron.d/sysstat`中的计划任务，将日志放入`/var/log/sa/`中

**安装：**

```sh
yum install -y sysstat
```

**Pattern:**

* `sar [ 选项 ] [ <时间间隔> [ <次数> ] ]`

**Options:**

* `-u`：查看cpu使用率
* `-q`：查看cpu负载
* `-r`：查看内存使用情况
* `-b`：查看I/O和传输速率信息状况
* `-d`：查看各个磁盘的I/O情况
* `-B`：查看paging使用情况
* `-f <filename>`：指定sa日志文件
* `-P <cpu num>|ALL`：查看某个cpu的统计信息，`ALL`表示所有CPU
* `-n [关键词]`：查看网络相关的情况，其中关键词可以是
    * `DEV`：网络接口
    * `EDEV`：网络接口错误
    * `SOCK`：套接字
    * `IP`：IP流
    * `TCP`：TCP流
    * `UDP`：UDP流
* `-h`：以人类可读的形式输出

**Examples:**

* `sar -u ALL 1`：输出cpu的相关信息（聚合了所有核）
* `sar -P ALL 1`：输出每个核的cpu的相关信息
* `sar -r ALL -h 1`：输出内存相关信息
* `sar -B 1`：输出paging信息
* `sar -n TCP,UDP -h 1`：查看TCP/UDP的汇总信息
* `sar -n DEV -h 1`：查看网卡实时流量
* `sar -b 1`：查看汇总的I/O信息
* `sar -d -h 1`：查看每个磁盘的I/O信息

## 6.8 tsar

**Pattern:**

* `tsar [-l]`

**Options:**

* `-l`：查看实时数据

**Examples:**

* `tsar -l`

## 6.9 vmstat

**Pattern:**

* `vmstat [options] [delay [count]]`

**Options:**

* `-a, --active`：显示活跃和非活跃内存
* `-f, --forks`：从系统启动至今的fork数量，linux下创建进程的系统调用是fork
    * 信息是从`/proc/stat`中的processes字段里取得的
* `-m, --slabs`：查看系统的slab信息
* `-s, --stats`：查看内存使用的详细信息
* `-d, --disk`：查看磁盘使用的详细信息
* `-D, --disk-sum`         summarize disk statistics
* `-p, --partition <dev>`：查看指定分区的详细信息
* `-S, --unit <char>`：指定输出单位，只支持`k/K`以及`m/M`，默认是`K`
* `-w, --wide`：输出更详细的信息
* `-t, --timestamp`：输出时间戳
* `delay`：采样间隔
* `count`：采样次数

**Output Details:**

* `process`
    * `r`：运行中的进程数量（`running`或`waiting`状态
    * `b`：阻塞中的进程数量
* `memory`
    * `swpd`：虚拟内存总量
    * `free`：空闲内存总量
    * `buff`：被用作`Buffer`的内存总量
    * `cache`：被用作`Cache`的内存总量
    * `inact`：无效内存总量（需要加`-a`参数）
    * `active`：有效内存总量（需要加`-a`参数）
* `swap`
    * `si`：每秒从磁盘交换的内存总量
    * `so`：每秒交换到磁盘的内存总量
* `io`
    * `bi`：每秒从块设备接收的`Block`数量
    * `bo`：每秒写入块设备的`Block`数量
* `system`
    * `in`：每秒中断次数，包括时钟中断
    * `cs`：每秒上下文切换的次数
* `cpu`
    * `us`：用户`CPU`时间
    * `sy`：系统（内核）`CPU`时间
    * `id`：空闲`CPU`时间
    * `wa`：等待`IO`的`CPU`时间
    * `st`：从虚拟机窃取的时间

**Examples:**

* `vmstat`
* `vmstat 2`
* `vmstat 2 5`
* `vmstat -s`
* `vmstat -s -S m`
* `vmstat -f`
* `vmstat -d`
* `vmstat -p /dev/sda1`
* `vmstat -m`

## 6.10 mpstat

`mpstat` (multiprocessor statistics) is a real-time monitoring tool that reports various statistics related to the CPU. These statistics are stored in the `/proc/stat` file. On multi-CPU systems, `mpstat` not only provides information about the average status of all CPUs but also allows you to view statistics for specific CPUs. The greatest feature of `mpstat` is its ability to display statistical data for each individual computing core in multi-core CPUs. In contrast, similar tools like `vmstat` can only provide overall CPU statistics for the entire system.

**Output Details:**

* `%usr`: Show the percentage of CPU utilization that occurred while executing at the user level (application).
* ` %nice`: Show the percentage of CPU utilization that occurred while executing at the user level with nice priority.
* `%sys`: Show the percentage of CPU utilization that occurred while executing at the system level (kernel). Note that this does not include time spent servicing hardware and software interrupts.
* `%iowait`: Show the percentage of time that the CPU or CPUs were idle during which the system had an outstanding disk I/O request.
* `%irq`: Show the percentage of time spent by the CPU or CPUs to service hardware interrupts.
* `%soft`: Show the percentage of time spent by the CPU or CPUs to service software interrupts.
* `%steal`: Show the percentage of time spent in involuntary wait by the virtual CPU or CPUs while the hypervisor was servicing another virtual processor.
* `%guest`: Show the percentage of time spent by the CPU or CPUs to run a virtual processor.
* `%gnice`: Show the percentage of time spent by the CPU or CPUs to run a niced guest.
* `%idle`: Show the percentage of time that the CPU or CPUs were idle and the system did not have an outstanding disk I/O request.

**Examples:**

* `mpstat 2 5`
* `mpstat -P ALL 2 5`
* `mpstat -P 0,2,4-7 1`

## 6.11 iostat

**Pattern:**

* `iostat [ -c | -d ] [ -k | -m ] [ -t ] [ -x ] [ interval [ count ] ]`

**Options:**

* `-c`：与`-d`互斥，只显示`CPU`相关的信息
* `-d`：与`-c`互斥，只显示磁盘相关的信息
* `-k`：以`kB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-m`：以`MB`的方式显示io速率（默认是`Blk`，即文件系统中的`block`）
* `-t`：打印日期信息
* `-x`：打印扩展信息
* `-z`：省略在采样期间没有产生任何事件的设备
* `interval`: 打印间隔
* `count`: 打印几次，不填一直打印

**Output Details:(`man iostat`)**

* `cpu`: Search for `CPU Utilization Report` in man page
* `device`: Search for `Device Utilization Report` in man page

**Examples:**

* `iostat -dtx 1`
* `iostat -dtx 1 sda`
* `iostat -tx 3`

## 6.12 dstat

`dstat`是用于生成系统资源统计信息的通用工具

**Pattern:**

* `dstat [options]`

**Options:**

* `-c, --cpu`：`CPU`统计信息
    * `usr`（`user`）
    * `sys`（`system`）
    * `idl`（`idle`）
    * `wai`（`wait`）
    * `hiq`（`hardware interrupt`）
    * `siq`（`software interrupt`）
* `-d, --disk`：磁盘统计信息
    * `read`
    * `writ`（`write`）
* `-i, --int`：中断统计信息
* `-l, --load`：`CPU`负载统计信息
    * `1 min`
    * `5 mins`
    * `15mins`
* `-m, --mem`：内存统计信息
    * `used`
    * `buff`（`buffers`）
    * `cach`（`cache`）
    * `free`
* `-n, --net`：网络统计信息
    * `recv`（`receive`）
    * `send`
* `-p, --proc`：进程统计信息
    * `run`（`runnable`）
    * `blk`（`uninterruptible`）
    * `new`
* `-r, --io`：I/O统计信息
    * `read`（`read requests`）
    * `writ`（`write requests`）
* `-s, --swap`：swap统计信息
    * `used`
    * `free`
* `-t, --time`：时间信息
* `-v, --vmstat`：等效于`dstat -pmgdsc -D total`，类似于`vmstat`的输出
* `--vm`：虚拟内存相关的信息
    * `majpf`（`hard pagefaults`）
    * `minpf`（`soft pagefaults`）
    * `alloc`
    * `free`
* `-y, --sys`：系统统计信息
    * `int`（`interrupts`）
    * `csw`（`context switches`）
* `--fs, --filesystem`：文件系统统计信息
    * `files`（`open files`）
    * `inodes`
* `--ipc`：ipc统计信息
    * `msg`（`message queue`）
    * `sem`（`semaphores`）
    * `shm`（`shared memory`）
* `--lock`：文件锁统计信息
    * `pos`（`posix`）
    * `lck`（`flock`）
    * `rea`（`read`）
    * `wri`（`write`）
* `--socket`：socket统计信息
    * `tot`（`total`）
    * `tcp`
    * `udp`
    * `raw`
    * `frg`（`ip-fragments`）
* `--tcp`：tcp统计信息，包括
    * `lis`（`listen`）
    * `act`（`established`）
    * `syn`
    * `tim`（`time_wait`）
    * `clo`（`close`）
* `--udp`：udp统计信息，包括
    * `lis`（`listen`）
    * `act`（`active`）
* **`-f, --full`**：显示详情，例如`CPU`会按每个`CPU`分别展示，network会按网卡分别展示
* **`--top-cpu`：显示最耗`CPU`资源的进程**
* **`--top-cpu-adv`：显示最耗`CPU`资源的进程，以及进程的其他信息（`advanced`）**
* **`--top-io`：显示最耗`IO`资源的进程**
* **`--top-io-adv`：显示最耗`IO`资源的进程，以及进程的其他信息（`advanced`）**
* **`--top-mem`：显示最耗mem资源的进程**

**Examples:**

* `dstat 5 10`：5秒刷新一次，刷新10次
* `dstat -tvln`
* `dstat -tc`
* `dstat -tc -C total,1,2,3,4,5,6`
* `dstat -td`
* `dstat -td -D total,sda,sdb`
* `dstat -td --disk-util`
* `dstat -tn`
* `dstat -tn -N total,eth0,eth2`

## 6.13 ifstat

该命令用于查看网卡的流量状况，包括成功接收/发送，以及错误接收/发送的数据包，看到的东西基本上和`ifconfig`类似

## 6.14 pidstat

`pidstat`是`sysstat`工具的一个命令，用于监控全部或指定进程的`CPU`、内存、线程、设备IO等系统资源的占用情况。首次运行`pidstat`时，显示自系统启动开始的各项统计信息；之后运行`pidstat`，将显示自上次运行该命令以后的统计信息。用户可以通过指定统计的次数和时间来获得所需的统计信息

**Pattern:**

* `dstat [options] [ interval [ count ] ]`

**Options:**

* `-d`：显示`I/O`使用情况
    * `kB_rd/s`：磁盘的读速率，单位`KB`
    * `kB_wr/s`：磁盘的写速率，单位`KB`
    * `kB_ccwr/s`：本应写入，但是取消的写速率，单位`KB`。任务丢弃`dirty pagecache`时可能会触发`cancel`
* `-r`：显示内存使用情况
    * `minflt/s`：`minor faults per second`
    * `majflt/s`：`major faults per second`
* `-s`：显示栈使用情况
    * `StkSize`：系统为该任务保留的栈空间大小，单位`KB`
    * `StkRef`：该任务当前实际使用的栈空间大小，单位`KB`
* `-u`：显示`CPU`使用情况，默认
    * `-I`：在`SMP, Symmetric Multi-Processing`环境下，`CPU`使用率需要考虑处理器的数量，这样得到的`%CPU`指标才是符合实际的
    * `%usr`、`%system`、`%guest`这三个指标无论加不加`-I`都不会超过100%，[pidstat do not report %usr %system correctly in SMP environment](https://github.com/sysstat/sysstat/issues/344)
* `-w`：显式上下文切换（不包含线程，通常与`-t`一起用）
* `-t`：显式所有线程
* `-p <pid>`：指定进程

**Examples:**

* `pidstat -d -p <pid> 5`
* `pidstat -r -p <pid> 5`
* `pidstat -s -p <pid> 5`
* `pidstat -uI -p <pid> 5`
* `pidstat -ut -p <pid> 5`
* `pidstat -wt -p <pid> 5`

## 6.15 nethogs

nethogs会以进程为单位，列出每个进程占用的网卡以及带宽

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 nethogs
yum install -y nethogs
```

**Examples:**

* `nethogs`

## 6.16 iptraf

## 6.17 iftop

iftop会以连接为单位，列出每个连接的进出流量

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 iftop
yum install -y iftop
```

**Examples:**

* `iftop`

## 6.18 iotop

**安装：**

```sh
# 安装 yum 源
yum install -y epel-release

# 安装 iotop
yum install -y iotop
```

**Options:**

* `-o`：只显示正在执行io操作的进程或者线程
* `-u`：后接用户名
* `-P`：只显示进程不显示线程
* `-b`：批处理，即非交互模式
* `-n`：后接次数

**Examples:**

* `iotop`
* `iotop -oP`
* `iotop -oP -b -n 10`
* `iotop -u admin`

## 6.19 blktrace

[IO神器blktrace使用介绍](https://developer.aliyun.com/article/698568)

**一个I/O请求的处理过程，可以梳理为这样一张简单的图：**

![blktrace_1](/images/Linux-Frequently-Used-Commands/blktrace_1.png)

**`blktrace`用于采集`I/O`数据，采集得到的数据一般无法直接分析，通常需要经过一些分析工具进行分析，这些工具包括：**

1. `blkparse`
1. `btt`
1. `blkiomon`
1. `iowatcher`

**使用`blktrace`前提需要挂载`debugfs`：**

```sh
mount      –t debugfs    debugfs /sys/kernel/debug
```

**`blkparse`输出参数说明：**

* `8,0    0    21311     3.618501874  5099  Q WFSM 101872094 + 2 [kworker/0:2]`
* 第一个参数：`8,0`，表示设备号`major device ID`和`minor device ID`
* 第二个字段：`0`，表示`CPU`
* 第三个字段：`21311`，表示序列号
* 第四个字段：`3.618501874`，表示时间偏移
* 第五个字段：`5099`，表示本次`I/O`对应的`pid`
* **第六个字段：`Q`，表示`I/O Event`，这个字段非常重要，反映了`I/O`进行到了哪一步**
    ```
    Q – 即将生成IO请求
    |
    G – IO请求生成
    |
    I – IO请求进入IO Scheduler队列
    |
    D – IO请求进入driver
    |
    C – IO请求执行完毕
    ```

* 第七个字段：`WFSM`
* 第八个字段：`101872094 + 2`，表示的是起始`block number`和 `number of blocks`，即我们常说的`Offset`和`Size`
* 第九个字段：`[kworker/0:2]`，表示进程名

**Examples:**

1. 先采集后分析
    ```sh
    # 该命令会在当前目录生成 sda.blktrace.<cpu> 文件簇
    # Ctrl + C 终止采集
    blktrace -d /dev/sda

    # 分析 sda.blktrace.<cpu> 文件簇，并输出分析结果
    blkparse sda
    ```

1. 变采集边分析
    ```sh
    # blktrace 产生的标准输出直接通过管道送入 blkparse 的标准输入
    # Ctrl + C 终止采集
    blktrace -d /dev/sda -o - | blkparse -i -
    ```

1. 使用`btt`进行分析
    ```sh
    blktrace -d /dev/sda

    # 该命令会将 sda.blktrace.<cpu> 文件簇合并成一个文件 sda.blktrace.bin
    blkparse -i sda -d sda.blktrace.bin

    # 该命令会分析 sda.blktrace.bin 并输出分析结果
    btt -i sda.blktrace.bin -l sda.d2c_latency
    ```

## 6.20 lsof

`lsof` is used to list open files, including socket files.

**Options:**

* `-U`: selects the listing of UNIX domain socket files
* `-i <address>`: selects the listing of files any of whose Internet address matches the address specified. Address format: `[46][protocol][@hostname|hostaddr][:service|port]`
    * `46`: ipv4/ipv6
    * `protocol`: tcp/udp
    * `hostname`
    * `hostaddr`
    * `service`: like `smtp`
    * `port`
* `-p <expr>`: excludes or selects the listing of files for the processes whose optional process IDentification (PID) numbers are in the comma-separated set - e.g., `123` or `123,^456`
* `+|-w`: Enables (+) or disables (-) the suppression of warning messages

**Examples:**

* `lsof -n | awk '{print $2}' | sort | uniq -c | sort -nr -k 1`: View the number of file handles opened by the process
* `lsof -i 6tcp@localhost:22`
* `lsof -i 4tcp@127.0.0.1:22`
* `lsof -i tcp@127.0.0.1:22`
* `lsof -i tcp@localhost`
* `lsof -i tcp:22`
* `lsof -i :22`
* `lsof -U -w | grep docker.sock`

## 6.21 fuser

`fuser` is used to identify processes using files or sockets.

**Options:**

* `-n <NAMESPACE>`: Select a different name space. The name spaces `file` (**file names, the default**), `udp` (local UDP ports), and `tcp` (local TCP ports) are supported. For ports, either the port number or the symbolic name can be specified. If there is no ambiguity, the shortcut notation `name/space` (e.g., `80/tcp`) can be used
    * `fuser /tmp/a.txt` equals to `fuser -n file /tmp/a.txt`
    * `fuser -n tcp 7061` equals to `fuser 7061/tcp`
* `-m <NAME>`: `NAME` specifies a file on a mounted file system or a block device that is mounted. All processes accessing files on that file system are listed
* `-k`: Kill processes accessing the file. Unless changed with `-SIGNAL`, `SIGKILL` is sent
* `-u`: Append the user name of the process owner to each PID
* `-v`: Verbose mode

**Examples:**

* `fuser -uv /tmp/a.txt`
* `fuser -m /tmp -uv`
* `fuser -uv 80/tcp`
* `fuser -k /tmp/a.txt`
* `fuser -k 80/tcp`

# 7 Performance Analysis

## 7.1 strace

`strace` is a powerful diagnostic, debugging, and instructional tool for Linux and other Unix-like operating systems. It's used primarily to trace system calls made by a process and the signals received by the process. The name `strace` stands for "system call trace."

**Key aspects of strace include:**

* **Tracing System Calls**: strace displays a list of system calls made by a program as it runs. This includes calls for opening files, reading/writing data, allocating memory, and interacting with the kernel.
* **Signals and Interrupts**: It also monitors the signals received by the process, which can be crucial in debugging issues related to signal handling.
* **Output Details**: For each system call, strace shows the call name, passed arguments, returned value, and error code (if any). This information is invaluable for understanding what a program is doing at a system level.
* **Usage for Debugging**: It's widely used for debugging applications during development. By examining system call traces, developers can identify if a program is behaving unexpectedly or inefficiently.
* **Performance Analysis**: strace can help in identifying performance bottlenecks by highlighting frequent or time-consuming system calls.
* **Security Analysis**: In security, it's used to analyze how an application interacts with the system, which can reveal potential security flaws or unauthorized actions.
* **Learning Tool**: For those learning about operating systems and programming, strace offers a practical way to understand the interaction between software and the Linux kernel.

**Options:**

* `-p [PID]`: This option is used to attach strace to an already running process.
* `-f`: Traces not only the main process but also all the forked child processes.
* `-e trace=[system calls]`: This option allows you to filter the trace to only specific system calls.
    * `-e trace=memory`: Filters the trace to only show system calls related to memory-related system calls.
    * `-e trace=desc`: Filters the trace to only show system calls related to file descriptor-related system calls.
    * `-e trace=file`: Filters the trace to only show system calls related to file-related system calls.
    * `-e trace=network`: Filters the trace to only show system calls related to network-related system calls.
    * `-e trace=signal`: Filters the trace to only show system calls related to signal-related system calls.
    * `-e trace=process`: Filters the trace to only show system calls related to process-related system calls.
    * `-e trace=ipc`: Filters the trace to only show system calls related to inter-process communication-related system calls.
* `-c`: Rather than showing every system call, this option provides a summary upon completion.

**Examples:**

1. `strace cat /etc/fstab`
1. `strace -e trace=read cat /etc/fstab`
1. `strace -e trace=memory -c cat /etc/fstab`
1. `strace -e trace=network -c curl www.baidu.com`
1. `strace -c cat /etc/fstab`
1. `timeout 10 strace -p {PID} -f -c`

## 7.2 perf

**`perf`的原理是这样的：每隔一个固定的时间，就在`CPU`上（每个核上都有）产生一个中断，在中断上看看，当前是哪个`pid`，哪个函数，然后给对应的`pid`和函数加一个统计值，这样，我们就知道`CPU`有百分几的时间在某个`pid`，或者某个函数上了**

**常用子命令**

* `archive`：由于`perf.data`的解析需要一些其他信息，比如符号表、`pid`、进程对应关系等，该命令就是将这些相关的文件都打成一个包，这样在别的机器上也能进行分析
* `diff`：用于展示两个`perf.data`之间的差异
* `evlist`：列出`perf.data`中包含的额事件
* `list`：查看支持的所有事件
* `record`：启动分析，并将记录写入`perf.data`
    * `perf record`在当前目录产生一个`perf.data`文件（如果这个文件已经存在，旧的文件会被改名为`perf.data.old`）
    * `perf record`不一定用于跟踪自己启动的进程，通过指定`pid`，可以直接跟踪固定的一组进程。另外，大家应该也注意到了，上面给出的跟踪都仅仅跟踪发生在特定pid的事件。但很多模型，比如一个`WebServer`，你其实关心的是整个系统的性能，网络上会占掉一部分`CPU`，`WebServer`本身占一部分`CPU`，存储子系统也会占据部分的`CPU`，网络和存储不一定就属于你的WebServer这个`pid`。**所以，对于全系统调优，我们常常给`perf record`命令加上`-a`参数，这样可以跟踪整个系统的性能**
* `report`：读取`perf.data`并展示
* `stat`：仅展示一些统计信息
* `top`：以交互式的方式进行分析
    * `?`: help doc

**关键参数：**

* `-e`：指定跟踪的事件
    * `perf top -e branch-misses,cycles`
    * `perf top -e branch-misses:u,cycles`：事件可以指定后缀，只跟踪发生在用户态时产生的分支预测失败
    * `perf top -e '{branch-misses,cycles}:u'`：全部事件都只关注用户态部分
* `-s`：指定按什么参数来进行分类
    * `perf top -e 'cycles' -s comm,pid,dso`
* `-p`：指定跟踪的`pid`

**常用事件：**

* `cycles/cpu-cycles & instructions`
* `branch-instructions & branch-misses`
* `cache-references & cache-misses`
    * `cache-misses`表示无法命中任何一级缓存，而需要访问主存的次数。对于`L1-miss, L2-hit`这种情况，不包含在内
    * [What are perf cache events meaning?](https://stackoverflow.com/questions/12601474/what-are-perf-cache-events-meaning)
    * [How does Linux perf calculate the cache-references and cache-misses events](https://stackoverflow.com/questions/55035313/how-does-linux-perf-calculate-the-cache-references-and-cache-misses-events)
* `LLC, last level cache`：
    * `LLC-loads & LLC-load-misses`
    * `LLC-stores & LLC-store-misses`
* `L1`：
    * `L1-dcache-loads & L1-dcache-load-misses`
    * `L1-dcache-stores`
    * `L1-icache-load-misses`
    * `mem_load_retired.l1_hit & mem_load_retired.l1_miss`
* `L2`：
    * `mem_load_retired.l2_hit & mem_load_retired.l2_miss`
* `L3`：
    * `mem_load_retired.l3_hit & mem_load_retired.l3_miss`
* `context-switches & sched:sched_switch`
* `page-faults & major-faults & minor-faults`
* `block`
    * `block:block_rq_issue`：发出`device I/O request`触发该事件。`rq`是`request`的缩写
* `kmem`
    * `kmem:kmalloc`
    * `kmem:kfree`

**Examples:**

1. `perf list`查看支持的所有事件
1. `perf stat -e L1-dcache-load-misses,L1-dcache-loads -- cat /etc/passwd`：统计缓存miss率
1. `timeout 10 perf record -e 'cycles' -a`：统计整个系统，统计10秒
1. `perf record -e 'cycles' -p xxx`：统计指定的进程
1. `perf record -e 'cycles' -- myapplication arg1 arg2`：启动程序并进行统计
1. `perf report`：查看分析报告
1. **`perf top -p <pid> -g`：以交互式的方式分析一个程序的性能（神器）**
    * `-g`可以展示某个函数自身的占比以及孩子的占比。每个项目最多可以继续展开成父堆栈和子堆栈，至于是父堆栈还是子堆栈，还是两者都有，要看具体情况
    * 选中某个条目，然后选择`Anotate xxx`可以查看对应的汇编
1. **`perf stat -p <pid> -e branch-instructions,branch-misses,cache-misses,cache-references,cpu-cycles,ref-cycles,instructions,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,cpu-migrations,context-switches,page-faults,major-faults,minor-faults`**
    * 该命令会在右边输出一个百分比，该百分比的含义是：`perf`统计指定`event`所花费的时间与`peft`统计总时间的比例

# 8 Remote Desktop

**`X Window System, X11, X`是一个图形显示系统。包含2个组件：`X Server`**

* **`X Server`：必须运行在一个有图形显示能力的主机上，管理主机上与显示相关的硬件设置（如显卡、硬盘、鼠标等），它负责屏幕画面的绘制与显示，以及将输入设置（如键盘、鼠标）的动作告知`X Client`**
    * `X Server`的实现包括
        * `XFree86`
        * `Xorg`：`XFree86`的衍生版本。这是运行在大多数Linux系统上的`X Server`
        * `Accelerated X`：由`Accelerated X Product`开发，在图形的加速显示上做了改进
        * `X Server suSE`：`SuSE Team’s`开发
        * `Xquartz`：运行在`MacOS`系统上的`X Server`
* **`X Client`：是应用程序的核心部分，它与硬件无关，每个应用程序就是一个`X Client`。`X Client`可以是终端仿真器（`Xterm`）或图形界面程序，它不直接对显示器绘制或者操作图形，而是与`X Server`通信，由`X Server`控制显示**
* **`X Server`和`X Client`可以在同一台机器上，也可以在不同机器上。两种通过`xlib`进行通信**

![X-Window-System](/images/Linux-Frequently-Used-Commands/X-Window-System.awebp)

## 8.1 xquartz (Not Recommended)

**工作原理：纯`X Window System`方案，其中，`xquartz`就是`X Server`的一种实现**

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
    ArrowColor DeepSkyBlue
    ActorBorderColor DeepSkyBlue
    LifeLineBorderColor blue
    LifeLineBackgroundColor #A9DCDF
    
    ParticipantBorderColor DeepSkyBlue
    ParticipantBackgroundColor DodgerBlue
    ParticipantFontName Impact
    ParticipantFontSize 17
    ParticipantFontColor #A9DCDF
    
    ActorBackgroundColor aqua
    ActorFontColor DeepSkyBlue
    ActorFontSize 17
    ActorFontName Aapex
}

box "带有显示相关硬件的主机"
participant X_Quartz as "X Quartz"
end box

box "远程Linux主机"
participant X_Client as "X client"
end box

X_Quartz -> X_Client: ssh -Y user@target
X_Client -> X_Client: 运行图形化程序，例如xclock
X_Client -> X_Quartz: X request
X_Quartz -> X_Client: X reply
```

**如何使用：**

* 在本地电脑（以`Mac`为例）安装`Xquartz`
* 远程Linux主机安装`xauth`，并且开启`sshd`的`X11 Forwarding`功能
    * `yum install -y xauth`
    * `/etc/ssh/sshd_config`设置`X11Forwarding yes`
* 本地电脑用`ssh`以`X11 Forwarding`方式连接到远程Linux主机
    * `ssh -Y user@target`
* 在远程ssh会话中，运行`X Client`程序，例如`xclock`

**缺点：占用大量带宽，且一个`ssh`会话只能运行一个`X Client`程序**

## 8.2 VNC (Recommended)

**`Virtual Network Computing, VNC`。主要由两个部分组成：`VNC Server`及`VNC Viewer`**

* **`VNC Server`：运行了`Xvnc`（`X Server`的一种实现），只不过`Xvnc`并不直接控制与显示相关的硬件，而是通过`VNC Protocol`与`VNC Viewer`进行通信，并控制`VNC Viewer`所在的主机上与显示相关的硬件。一个主机可以运行多个`Xvnc`，每个`Xvnc`会在本地监听一个端口（`590x`）**
* **`VNC Client`：与`VNC Server`暴露的端口连接，获取图形化输出所需的信息（包括传递I/O设备的信号）**

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
    ArrowColor DeepSkyBlue
    ActorBorderColor DeepSkyBlue
    LifeLineBorderColor blue
    LifeLineBackgroundColor #A9DCDF
    
    ParticipantBorderColor DeepSkyBlue
    ParticipantBackgroundColor DodgerBlue
    ParticipantFontName Impact
    ParticipantFontSize 17
    ParticipantFontColor #A9DCDF
    
    ActorBackgroundColor aqua
    ActorFontColor DeepSkyBlue
    ActorFontSize 17
    ActorFontName Aapex
}

box "带有显示相关硬件的主机"
participant VNC_Viewer as "VNC Viewer"
end box

box "远程Linux主机"
participant X_VNC as "Xvnc"
participant X_Client as "X Client"
end box

VNC_Viewer <--> X_VNC: VNC Protocol
X_VNC <--> X_Client: X Protocol
```

**如何使用：**

1. **在Linux上安装`VNC Server`：以CentOS为例**
    * `yum install -y tigervnc-server`
    * `vncserver :x`：在`5900 + x`端口上启动服务
    * `vncserver -kill :x`：关闭`5900 + x`端口上的服务
    * `vncserver -list`：显示所有`Xvnc`
1. **从官网下载`VNC Viewer`**
    * 默认可以用`Linux`的账号密码登录

**Tips：**

* `vncserver -SecurityTypes None :x`：允许免密登录
* 键盘无法输入：按住`ctrl + shift`，再打开终端
* 在远程桌面的终端中执行`vncconfig -display :x`，会弹出一个小框，可以进行一些选项配置
* **如何在Mac与远程Linux之间拷贝，参考[copy paste between mac and remote desktop](https://discussions.apple.com/thread/8470438)**
    * `Remote Linux -> Mac`：
        1. 在`VNC Viewer`中，鼠标选中再按`Ctrl + Shift + C`（貌似鼠标选中即可）进行复制
        1. 在Mac上，`Command + V`进行粘贴
    * `Mac -> Remote Linux`（很大概率失败，不知道为啥）：
        1. 在Mac上，鼠标选中，再按`Command + C`进行复制
        1. 在`VNC Viewer`中，按`Ctrl + Shift + V`进行粘贴
    * `Remote Linux -> Remote Linux`
        1. 在`VNC Viewer`中，鼠标选中再按`Ctrl + Shift + C`进行复制
        1. 在`VNC Viewer`中，按`Ctrl + Shift + V`进行粘贴

## 8.3 NX (Recommended)

[No Machine官网](https://www.nomachine.com/)

**工作原理：与`VNC`类似，但是使用了`NX`协议，占用带宽更小**

**如何使用：**

1. **在Linux上安装`NX Server`：以CentOS为例，从官网下载rpm包并安装**
    * `rpm -ivh nomachine_7.7.4_1_x86_64.rpm`
    * `/etc/NX/nxserver --restart`
1. **从官网下载`NX Client`**
    * `NX Server`的默认端口号是`4000`
    * 默认可以用`Linux`的账号密码登录

**配置文件：`/usr/NX/etc/server.cfg`**

* `NXPort`：修改启动端口号
* `EnableUserDB/EnablePasswordDB`：是否用额外的账号进行登录（1开启，0关闭，默认关闭）
    * `/etc/NX/nxserver --useradd admin --system --administrator`：该命令本质上也会创建一个Linux账号，第一个密码是Linux账号的密码，第二个密码是`NX Server`独立的密码（仅用于`NX`登录）

# 9 audit

[红帽企业版 Linux 7安全性指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/index)

## 9.1 Architecture

![audit_architecture](/images/Linux-Frequently-Used-Commands/audit_architecture.png)

审核系统包含两个主要部分：用户空间的应用程序、实用程序，以及`kernel-side`系统调用处理。Kernel的组件从用户空间的应用程序接受系统调用，并且通过三个过滤器中的一个过滤器来进行筛选：`user`、`task`或者`exit`。一旦系统调用通过其中的一个过滤器，就将通过`exclude`过滤器进行传送，这是基于审核规则的配置，并把它传送给审核的守护程序做进一步的处理

处理过程和`iptables`差不多，有规则链，可以在链中增加规则，它发现一个`syscall`或者特殊事件的时候会去遍历这个链，然后按规则处理，吐不同的日志

**与audit相关的内核编译参数**

```
CONFIG_AUDIT_ARCH=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
CONFIG_NETFILTER_XT_TARGET_AUDIT=m
CONFIG_IMA_AUDIT=y
CONFIG_KVM_MMU_AUDIT=y
```

**只要编译内核时，开启了审计的选项，那么内核就会产生审计事件，并将审计事件送往一个socket，然后auditd负责从这个socket读出审计事件并记录**

## 9.2 auditctl

### 9.2.1 Control Rules

**Options:**

* `-b`：设置允许的未完成审核缓冲区的最大数量，默认值是`64`
* `-e [0..2]`：设置启用标志位
    * `0`：关闭审计功能
    * `1`：开启审计功能，且允许修改配置
    * `2`：开启审计功能，且不允许修改配置
* `-f [0..2]`：设置异常标志位（告诉内如如何处理这些异常）
    * `0`：silent，当发现异常时，不处理（静默）
    * `1`：printk，打日志（这是默认值）
    * `2`：panic，崩溃
* `-r`：消息产生的速率，单位秒
* `-s`：报告审核系统状态
* `-l`：列出所有当前装载的审核规则
* `-D`：清空所有规则以及watch

**Examples:**

* `auditctl -b 8192`
* `auditctl -e 0`
* `auditctl -r 0`
* `auditctl -s`
* `auditctl -l`

### 9.2.2 File System Rules

**Pattern:**

* `auditctl -w <path_to_file> -p <permissions> -k <key_name>`

**Options:**

* `-w`：路径名称
* `-p`：后接权限，包括
    * `r`：读取文件或者目录
    * `w`：写入文件或者目录
    * `x`：运行文件或者目录
    * `a`：改变在文件或者目录中的属性
* `-k`：后接字符串，可以任意指定，用于搜索

**Examples:**

* `auditctl -w /etc/shadow -p wa -k passwd_changes`：等价于`auditctl -a always,exit -F path=/etc/shadow -F perm=wa -k passwd_changes`

### 9.2.3 System Call Rules

**Pattern:**

* `auditctl -a <action>,<filter> -S <system_call> -F field=value -k <key_name>`

**Options:**

* `-a`：后接`action`和`filter`
    * `action`：决定匹配`filter`的审计事件是否要记录，可选值包括
        * `always`：记录
        * `never`：不记录
    * `filter`：审计事件过滤器，可选值包括
        * `task`：匹配进程创建时（`fork`或`clone`）产生的审计事件
        * **`exit`：匹配系统调用结束时产生的审计事件**
        * `user`：匹配来自用户空间的审计事件
        * `exclude`：用于屏蔽不想要的审计事件
* `-S`：后接系统调用名称，系统调用清单可以参考`/usr/include/asm/unistd_64.h`，如果要指定多个系统调用名称，那么需要多个`-S`参数，每个指定一个系统调用
* `-F`：扩展选项，键值对
* `-k`：后接字符串，可以任意指定，用于搜索

**Examples:**

* `auditctl -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change`

## 9.3 ausearch

**Options:**

* `-i`：翻译结果，使其更可读
* `-m`：指定类型
* `-sc`：指定系统调用名称
* `-sv`：系统调用是否成功

**Examples:**

* `ausearch -i`：搜索全量事件
* `ausearch --message USER_LOGIN --success no --interpret`：搜索登录失败的相关事件
* `ausearch -m ADD_USER -m DEL_USER -m ADD_GROUP -m USER_CHAUTHTOK -m DEL_GROUP -m CHGRP_ID -m ROLE_ASSIGN -m ROLE_REMOVE -i`：搜索所有的账户，群组，角色变更相关的事件
* `ausearch --start yesterday --end now -m SYSCALL -sv no -i`：搜寻从昨天至今所有的失败的系统调用相关的事件
* `ausearch -m SYSCALL -sc open -i`：搜寻系统调用open相关的事件

## 9.4 Audit Record Types

[B.2. 审核记录类型](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/sec-Audit_Record_Types)

# 10 Package Management Tools

## 10.1 rpm

**Examples:**

* `rpm -qa | grep openjdk`
* `rpm -ql java-11-openjdk-devel-11.0.8.10-1.el7.x86_64`：查看软件安装路径

## 10.2 yum

**源管理（`/etc/yum.repos.d`）：**

* `yum repolist`
* `yum-config-manager --enable <repo>`
* `yum-config-manager --disable <repo>`
* `yum-config-manager --add-repo <repo_url>`

**安装、卸载：**

* `yum install <software>`
* `yum remove <software>`
* `yum localinstall <rpms>`

**缓存：**

* `yum makecache`
    * `yum makecache fast`：确保缓存仅包含最新的信息，等效于`yum clean expire-cache`
* `yum clean`：清除缓存
    * `yum clean expire-cache`：清除无效的缓存
    * `yum clean all`：清除所有缓存

**软件列表：**

* `yum list`：列出所有可安装的软件
    * `yum list docker-ce --showduplicates | sort -r`：查询软件的版本信息

**安装jdk：**

```sh
sudo yum install java-1.8.0-openjdk-devel
```

### 10.2.1 scl

`SCL` stands for Software Collections. It's a mechanism that allows you to install multiple versions of software on the same system, without them conflicting with each other. This is especially helpful for software like databases, web servers, or development tools where you might need different versions for different projects.

**Examples:**

* `scl -l`: Lists all the available software collections on your system.
* `scl enable <collection> <command>`: This command runs a specified `<command>` within the environment of the given software `<collection>`. This means that when you run a command under a specific software collection, you're using the version of the software provided by that collection.

**安装指定版本的gcc：**

```sh
yum -y install centos-release-scl

yum list devtoolset* --showduplicates | sort -r

yum -y install devtoolset-7
yum -y install devtoolset-8
yum -y install devtoolset-9
yum -y install devtoolset-10
yum -y install devtoolset-11

scl enable devtoolset-11 bash
```

**删除：**

```sh
yum -y remove devtoolset-7\*
yum -y remove devtoolset-8\*
yum -y remove devtoolset-9\*
yum -y remove devtoolset-10\*
yum -y remove devtoolset-11\*
```

## 10.3 dnf

**Examples:**

* `dnf provides /usr/lib/grub/x86_64-efi`

<!--

**Pattern:**

* `find [文件路径] [option] [action]`

**Options:**

* `-name`：后接文件名，支持通配符。**注意匹配的是相对路径**

**Examples:**

* `find . -name "*.c"`

-->

## 10.4 apt

**Examples:**

```sh
add-apt-repository "deb https://apt.llvm.org/your-ubuntu-version/ llvm-toolchain-your-ubuntu-version main"
apt update
apt search clang-format
apt install clang-format-X.Y
```

# 11 FAQ

## 11.1 System Information

### 11.1.1 Basic

#### 11.1.1.1 Determine physical/virtual machine

* `systemd-detect-virt`

#### 11.1.1.2 Get Ip Address

* `ip -4 addr show scope global | grep inet | awk '{print $2}' | cut -d/ -f1`

### 11.1.2 Disk & Filesystem

#### 11.1.2.1 Determine disk type

* `lsblk -d --output NAME,ROTA`
    * `ROTA: 0`：SSD
    * `ROTA: 1`：HDD
* `cat /sys/block/<device_name>/queue/rotational`
    * `<device_name>` may be sda

#### 11.1.2.2 Get inode related information

* `df -i`
* `ls -i`
* `stat <file_path>`
* `find <path> -inum <inode_number>`
* `tune2fs -l /dev/sda1 | grep -i 'inode'`

## 11.2 System Monitoring

### 11.2.1 Real-time Dashboard

* `dstat -tvln`

#### 11.2.1.1 CPU

* `dstat -tc`
* `dstat -tc -C total,1,2,3,4,5,6`
* `mpstat 1`
* `mpstat -P ALL 1`
* `mpstat -P 0,2,4-7 1`
* `sar -u ALL 1`
* `sar -P ALL 1`

#### 11.2.1.2 Memory

* `dstat -tm --vm --page --swap`
* `sar -r ALL -h 1`

#### 11.2.1.3 I/O

* `dstat -td`
* `dstat -td -D total,sda,sdb`
* `iostat -dtx 1`
* `sar -b 1`
* `sar -d -h 1`

#### 11.2.1.4 Network

* `dstat -tn`
* `dstat -tn -N total,eth0,eth2`
* `sar -n TCP,UDP -h 1`
* `sar -n DEV -h 1`

#### 11.2.1.5 Analysis

**CPU**:

* `large %nice`: In system monitoring, the `%nice` metric indicates the percentage of CPU time spent executing processes that have had their priority adjusted using the nice command. A high `%nice` value generally means that there are many low-priority tasks running. These tasks have been set to a lower priority to minimize their impact on other higher-priority tasks
* **`large %iowait`**: indicates that a significant amount of CPU time is being spent waiting for I/O (Input/Output) operations to complete. This is a measure of how much time the CPU is idle while waiting for data transfer to and from storage devices such as hard disks, SSDs, or network file systems. High `%iowait` can be a sign of several underlying issues or conditions:
    * Disk Bottlenecks
    * High I/O Demand
    * Insufficient Disk Bandwidth
    * Disk Fragmentation
    * Network Storage Latency
    * Hardware Issues
* `large %steal`: `%steal` value in system monitoring refers to the percentage of CPU time that the virtual machine (VM) was ready to run but had to wait because the hypervisor was servicing another virtual CPU (vCPU) on the physical host. This is a specific metric in virtualized environments and is typically indicative of resource contention on the physical host. Here are some key points and possible reasons for a high `%steal` value:
    * Overcommitted Host Resources
    * High Load on Other VMs
    * Inadequate Host Capacity
    * Suboptimal Resource Allocation
* **`large %irq`**: indicates that a significant portion of the CPU's time is being spent handling hardware interrupts. Interrupts are signals sent to the CPU by hardware devices (like network cards, disk controllers, and other peripherals) to indicate that they need processing. While handling interrupts is a normal part of system operation, an unusually high `%irq` can indicate potential issues or inefficiencies:
    * High Network Traffic
    * High Disk I/O
    * Faulty Hardware
    * Driver Issues
    * Interrupt Storms
* **`large %soft`**: indicates that a significant portion of the CPU's time is being spent handling software interrupts, which are used in many operating systems to handle tasks that require timely processing but can be deferred for a short period. Softirqs are typically used for networking, disk I/O, and other system-level tasks that are not as critical as hardware interrupts but still need prompt attention
    * High Network Traffic
    * High Disk I/O
    * Interrupt Coalescing

**Memory**:

* `large majpf`: indicates that the system is experiencing a lot of disk I/O due to pages being read from disk into memory. This can be a sign of insufficient physical memory (RAM) for the workload being handled, leading to the following scenarios:
    * Memory Overcommitment
    * Heavy Memory Usage
    * Insufficient RAM
* `large minpf`: indicates that the system is frequently accessing pages that are not in the process's working set but are still in physical memory. While minor page faults are less costly than major page faults because they do not require disk I/O, a large number of them can still have performance implications. Here are some reasons and implications for a high number of minor page faults:
    * Frequent Context Switching
    * Large Working Sets
    * Memory-Mapped Files
    * Shared Libraries

### 11.2.2 Process

#### 11.2.2.1 Find process with most CPU consumption

* `dstat --top-cpu-adv`
* `ps aux --sort=-%cpu | head -n 10`
* `ps -eo pid,comm,%cpu --sort=-%cpu | head -n 10`

#### 11.2.2.2 Find process with most Memory consumption

* `dstat --top-mem`
* `ps aux --sort=-%mem | head -n 10`
* `ps -eo pid,comm,%mem --sort=-%mem | head -n 10`

#### 11.2.2.3 Find process with most I/O consumption

* `dstat --top-io-adv`
* `iotop -oP`

#### 11.2.2.4 Find process with most brand consumption

* `nethogs`

#### 11.2.2.5 Find process listening on specific port

* `lsof -n -i :80`
* `fuser -uv 80/tcp`
* `ss -npl | grep 80`

#### 11.2.2.6 Find process using specific file

* `lsof /opt/config/xxx`
* `fuser -uv /opt/config/xxx`

#### 11.2.2.7 Get full command of a process

* `lsof -p xxx | grep txt`

#### 11.2.2.8 Get start time of a process

* `ps -p xxx -o lstart`

### 11.2.3 Network

#### 11.2.3.1 Find connection with most brand consumption

* `iftop`

#### 11.2.3.2 Get start time of a tcp connection

* `lsof -i :<port>`: Get pid and fd
* `ll /proc/<pid>/fd/<fd>`: The create time of this file is the create time of corresponding connection

#### 11.2.3.3 How to kill a tcp connection

* `tcpkill -9 -i any host 127.0.0.1 and port 22`

#### 11.2.3.4 How to kill tcp connections with specific state

* `ss --tcp state CLOSE-WAIT --kill`

## 11.3 Assorted

### 11.3.1 Allow using docker command without sudo

* `sudo usermod -aG docker username`

### 11.3.2 Check symbols of binary

* `nm -D xxx.so`
* `readelf -s --wide xxx.so`

### 11.3.3 List all commands start with xxx

* `compgen -c | grep -E '^xxx`

### 11.3.4 How to check file's modification time

* `ls --full-time <file>`
* `stat <file>`
* `date -r <file>`

# 12 Reference

* 《鸟哥的Linux私房菜》
* [Linux Tools Quick Tutorial](https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/index.html)
* [linux shell awk 流程控制语句（if,for,while,do)详细介绍](https://www.cnblogs.com/chengmo/archive/2010/10/04/1842073.html)
* [awk 正则表达式、正则运算符详细介绍](https://www.cnblogs.com/chengmo/archive/2010/10/11/1847772.html)
* [解决Linux关闭终端(关闭SSH等)后运行的程序自动停止](https://blog.csdn.net/gatieme/article/details/52777721)
* [Linux ss命令详解](https://www.cnblogs.com/ftl1012/p/ss.html)
* [Socat 入门教程](https://www.hi-linux.com/posts/61543.html)
* [Linux 流量控制工具 TC 详解](https://blog.csdn.net/wuruixn/article/details/8210760)
* [docker networking namespace not visible in ip netns list](https://stackoverflow.com/questions/31265993/docker-networking-namespace-not-visible-in-ip-netns-list)
* [Guide to IP Layer Network Administration with Linux](http://linux-ip.net/html/)
* [Linux ip命令详解](https://www.jellythink.com/archives/469)
* [linux中路由策略rule和路由表table](https://blog.csdn.net/wangjianno2/article/details/72853735)
* [ip address scope parameter](https://serverfault.com/questions/63014/ip-address-scope-parameter)
* [Displaying a routing table with ip route show](http://linux-ip.net/html/tools-ip-route.html)
* [What does “proto kernel” means in Unix Routing Table?](https://stackoverflow.com/questions/10259266/what-does-proto-kernel-means-in-unix-routing-table)
* [Routing Tables](http://linux-ip.net/html/routing-tables.html)
* [How to execute a command in screen and detach?](https://superuser.com/questions/454907/how-to-execute-a-command-in-screen-and-detach)
* [Linux使echo命令输出结果带颜色](https://www.cnblogs.com/yoo2767/p/6016300.html)
* [How to insert the content of a file into another file before a pattern (marker)?](https://unix.stackexchange.com/questions/32908/how-to-insert-the-content-of-a-file-into-another-file-before-a-pattern-marker)
* [Insert contents of a file after specific pattern match](https://stackoverflow.com/questions/16715373/insert-contents-of-a-file-after-specific-pattern-match)
* [How can I copy a hidden directory recursively and preserving its permissions?](https://unix.stackexchange.com/questions/285644/how-can-i-copy-a-hidden-directory-recursively-and-preserving-its-permissions)
* [rm -rf all files and all hidden files without . & .. error](https://unix.stackexchange.com/questions/77127/rm-rf-all-files-and-all-hidden-files-without-error)
* [通过tcpdump对Unix Domain Socket 进行抓包解析](https://plantegg.github.io/2018/01/01/%E9%80%9A%E8%BF%87tcpdump%E5%AF%B9Unix%20Socket%20%E8%BF%9B%E8%A1%8C%E6%8A%93%E5%8C%85%E8%A7%A3%E6%9E%90/)
* [tcpdump 选项及过滤规则](https://www.cnblogs.com/tangxiaosheng/p/4950055.html)
* [如何知道进程运行在哪个 CPU 内核上？](https://www.jianshu.com/p/48ca58e55077)
* [Don't understand [0:0] iptable syntax](https://serverfault.com/questions/373871/dont-understand-00-iptable-syntax)
* [Linux iptables drop日志记录](https://blog.csdn.net/magerguo/article/details/81052106)
* [Iptables 指南 1.1.19](https://www.frozentux.net/iptables-tutorial/cn/iptables-tutorial-cn-1.1.19.html)
* [redhat-安全性指南-定义审核规则](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/sec-defining_audit_rules_and_controls)
* [addr2line](https://www.jianshu.com/p/c2e2b8f8ea0d)
* [How to use OpenSSL to encrypt/decrypt files?](https://stackoverflow.com/questions/16056135/how-to-use-openssl-to-encrypt-decrypt-files)
* [confusion about mount options](https://unix.stackexchange.com/questions/117414/confusion-about-mount-options)
* [在Linux下做性能分析3：perf](https://zhuanlan.zhihu.com/p/22194920)
* [tmux使用指南：比screen好用n倍！](https://zhuanlan.zhihu.com/p/386085431)
* [Perf: what do [<n percent>] records mean in perf stat output?](https://stackoverflow.com/questions/33679408/perf-what-do-n-percent-records-mean-in-perf-stat-output)
* [SSH隧道：端口转发功能详解](https://www.cnblogs.com/f-ck-need-u/p/10482832.html)
* [X Window系统](https://juejin.cn/post/6971037787575451661)
