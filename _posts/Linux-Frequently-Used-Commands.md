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

This command is used to view distribution information (lsb, Linux Standard Base). Other ways to check the distribution include:

1. `uname -r`: Kernel version number  
1. `/etc/*-release`, including:
    * `/etc/os-release`
    * `/etc/centos-release`
    * `/etc/debian_version`
1. `/proc/version`

## 1.2 uname

**Pattern:**

* `uname [option]`

**Options:**

* `-a, --all`
* `-s, --kernel-name`
* `-n, --nodename`
* `-r, --kernel-release`
* `-v, --kernel-version`
* `-m, --machine`
* `-p, --processor`
* `-i, --hardware-platform`
* `-o, --operating-system`

**Examples:**

* `uname -a`
* `uname -r`
* `uname -s`

## 1.3 dmidecode

**Examples:**

* `sudo dmidecode -s system-manufacturer`
* `sudo dmidecode -s system-product-name`

## 1.4 systemd-detect-virt

This command is used to determine whether the current machine is a physical machine or a virtual machine

**Examples:**

* `systemd-detect-virt`
    * `none`: Physical machine
    * `qemu/kvm/...`: Virtual machine

## 1.5 demsg

The kernel stores boot information in the `ring buffer`. If you don't have time to view the information during boot, you can use `dmesg` to check it. Boot information is also saved in the `/var/log` directory, in a file named dmesg.

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

* `man 1`: Standard Linux commands  
* `man 2`: System calls  
* `man 3`: Library functions  
* `man 4`: Device descriptions  
* `man 5`: File formats  
* `man 6`: Games and entertainment  
* `man 7`: Miscellaneous  
* `man 8`: System administration commands  
* `man 9`: Kernel routines

## 1.8 last

**Examples:**

* `last -x`

## 1.9 who

This command is used to see who is currently logged into the system and what they are doing.

**Examples:**

* `who`
* `who -u`

## 1.10 w

This command is used to see who is currently logged into the system and what they are doing. It is slightly more powerful than `who`.

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

* `-g`: Specify the user group  
* `-G`: Additional user groups  
* `-d`: Specify the user home directory  
* `-m`: Automatically create the user home directory  
* `-s`: Specify the shell

**Examples:**

* `useradd test -g wheel -G wheel -m -s /bin/bash`
* `useradd test -d /data/test -s /bin/bash`

**`useradd` steps when creating an account**

1. Create the required user group: `/etc/group`  
1. Synchronize `/etc/group` with `/etc/gshadow`: `grpconv`  
1. Set various properties for the new account: `/etc/passwd`  
1. Synchronize `/etc/passwd` with `/etc/shadow`: `pwconv`  
1. Set the password for the account: `passwd <name>`  
1. Create the user's home directory: `cp -a /etc/skel /home/<name>`  
1. Change the ownership of the user's home directory: `chown -R <group> /home/<name>`

### 1.17.1 Migrate User Directory

```sh
# copy
rsync -avzP <old_dir> <new_dir>

# switch to root
sudo su

# kill all processes that using old home directory
fuser -k -9 <old_dir>

# update user's home directory
usermod -d <new_dir> <username>
```

## 1.18 userdel

**Options:**

* `-r`: Delete the user's home directory

**Examples:**

* `userdel -r test`

## 1.19 usermod

**Options:**

* `-d`: Modify the user directory  
* `-s`: Modify the shell  

**Examples:**

* `usermod -s /bin/zsh admin`: Modify the default shell of the specified account  
* `usermod -d /opt/home/admin admin`: Modify the user directory of the specified account  
    * Note: Do not add a trailing `/` to the new path. For example, do not write `/opt/home/admin/`, as this can cause `zsh` to fail to replace the user directory with the `~` symbol. This will make the command prompt display the absolute path instead of `~`.  
* `sudo usermod -aG docker username`: Add the specified user to a user group; the user must log in again for the change to take effect  
    * `groups username`: View the user groups  

## 1.20 chown

**Examples:**

* `chown [-R] <user> <file/dir>`
* `chown [-R] <user>:<group> <file/dir>`

## 1.21 passwd

**Examples:**

* `echo '123456' | passwd --stdin root`

## 1.22 chpasswd

**Examples:**

* `echo 'username:password' | sudo chpasswd`

## 1.23 id

This command is used to view user information, including `uid`, `gid`, and more.

**Examples:**

* `id`: View information about the current user  
* `id <username>`: View information about a specified user  
* `id -u`: View the current user's uid  
* `id -nu <uid>`: View the username corresponding to the specified uid  

## 1.24 getconf

This command is used to view system-related information.

**Examples:**

* `getconf -a | grep CACHE`: View CPU cache-related configuration items

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
* `ntpdate ntp.cloud.aliyuncs.com`: On Alibaba Cloud ECS, time synchronization requires specifying the internal NTP service.

## 1.29 hexdump

Display file contents in hexadecimal, decimal, octal, or ascii

**Examples:**

* `hexdump -C <filename> | head -n 10`

## 1.30 xxd

`xxd` is a command-line utility that creates a hex dump of a file or standard input. It can also do the reverse: convert a hex dump back into binary.

**Examples:**

* `xxd file.bin`
* `xxd -r hex_dump.txt > recovered.bin`

## 1.31 showkey

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

* `echo [-ne] [string/variable]`  
* Variables inside `''` are not interpreted, while variables inside `""` are interpreted  

**Options:**

* `-n`: Do not automatically add a newline at the end  
* `-e`: Enable backslash escape sequences. If the string contains the following characters, they are specially handled rather than output as literal text:  
    * `\a`: Emit a warning sound  
    * `\b`: Delete the previous character  
    * `\c`: Do not add a newline at the end  
    * `\f`: Newline but cursor stays at the same position  
    * `\n`: Newline and move cursor to the beginning of the line  
    * `\r`: Move cursor to the beginning of the line without newline  
    * `\t`: Insert a tab  
    * `\v`: Same as `\f`  
    * `\\`: Insert a `\` character  
    * `\nnn`: Insert the ASCII character represented by the octal number `nnn`

**Examples:**

* `echo ${a}`
* `echo -e "a\nb"`
* `echo -e "\u67e5\u8be2\u5f15\u64ce\u5f02\u5e38\uff0c\u8bf7\u7a0d\u540e\u91cd\u8bd5\u6216\u8054\u7cfb\u7ba1\u7406\u5458\u6392\u67e5\u3002"`: Transfer `Unicode` to `UTF-8`

**Others:**

* **Color control, explanation of control options:**  
    ```sh
    echo -e "\033[30m Black text \033[0m"
    echo -e "\033[31m Red text \033[0m"
    echo -e "\033[32m Green text \033[0m"
    echo -e "\033[33m Yellow text \033[0m"
    echo -e "\033[34m Blue text \033[0m"
    echo -e "\033[35m Purple text \033[0m"
    echo -e "\033[36m Cyan text \033[0m"
    echo -e "\033[37m White text \033[0m"

    echo -e "\033[40;37m Black background white text \033[0m"
    echo -e "\033[41;37m Red background white text \033[0m"
    echo -e "\033[42;37m Green background white text \033[0m"
    echo -e "\033[43;37m Yellow background white text \033[0m"
    echo -e "\033[44;37m Blue background white text \033[0m"
    echo -e "\033[45;37m Purple background white text \033[0m"
    echo -e "\033[46;37m Cyan background white text \033[0m"
    echo -e "\033[47;30m White background black text \033[0m"
    ```

* How to output text containing `*`  
    * [Printing asterisk ("*") in bash shell](https://stackoverflow.com/questions/25277037/printing-asterisk-in-bash-shell)  
    * `content="*"; echo ${content}`: `*` will be expanded by `sh/bash` (not by `zsh`) to all files and directories in the current path  
    * `content="*"; echo "${content}"`: With quotes, `*` is output as the literal character  

## 2.3 sed

**Pattern:**

* `sed [-nefr] [action] [file]`
* `STD IN | sed [-nefr] [action]`

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

* **`a`:**

```sh
echo -e "a\nb\nc" | sed '1,2anewLine'

# Output
a
newLine
b
newLine
c
```

* **`c`:**

```sh
# /^a$/ matches the first line using a regular expression and requires the -r option
echo -e "a\nb\nc" | sed -r '/^a$/,2cnewLine'

# Output
newLine
c
```

* **`d`:**

```sh
# Delete from line 2 to the first line containing the character 'c'
echo -e "a\nb\nc" | sed '2,/c/d'

# Delete the last line
echo -e "a\nb\nc" | sed '$d'

# Delete content from the first line containing 'a1' to the first line containing 'a2'
echo -e "a0\na1\na1\na1\nb1\nb2\na2\na2\na2\na3" | sed '/a1/, /a2/d'

# Output
a
```

* **`i`:**

```sh
echo -e "a\nb\nc" | sed '1,2inewLine'

# Output
newLine
a
newLine
b
c

echo -e "a\nb\nc" | sed '1inewLine'

# Output
newLine
a
b
c
```

* **`p`:**

```sh
# $ represents last line
echo -e "a\nb\nc" | sed -n '/b/,$p'

# Output
b
c

# Use regex
echo -e '<a href="https://www.baidu.com">BaiDu</a>' | sed -rn 's/^.*<a href="(.*)">.*$/\1/p'

# Output
https://www.baidu.com

# Output specific lines
echo -e "a\nb\nc\nd" | sed -n '1,3p'

# Output
a
b
c
```

* **`s`:**

```sh
# Apply to all lines, for each line, replace the first 'a' with 'A'
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/'

# Apply to all lines, for each line, replace all 'a's with 'A's
echo -e "abcabc\nbcabca\ncabcab" | sed 's/a/A/g'

# Apply to all lines, for each line, replace all 'a's with 'A's and print the result
echo -e "abcabc\nbcabca\ncabcab" | sed -n 's/a/A/gp'

# Apply from the first to the third line, for all strings where the third character is 'a', delete the 'a' and keep the first two characters
# /^abc/ matches the first line starting with 'abc', /cab$/ matches the first line ending with 'cab'
# The following two are equivalent; the delimiter can be '/' or '|'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s/(..)a/\1/gp'
echo -e "abcabc\nbcabca\ncabcab" | sed -nr '/^abc/,/cab$/s|(..)a|\1|gp'

# Apply to the last line, replace all occurrences of 'loverable' with 'lovers'
echo -e "loverable" | sed -nr '$s/(love)rable/\1rs/gp'

# Replace /root/ with /, the following two are equivalent
echo "/root/document/file.txt" | sed -nr 's|/root/|/|p'     # '/' does not need escaping here because delimiter is '|'
echo "/root/document/file.txt" | sed -nr 's/\/root\//\//p'  # '/' needs escaping here because delimiter is '/'

# Replace all 'a' or 'b' with 'A', the following two are equivalent
echo "abc" | sed -nr 's/a|b/A/gp'   # '|' does not need escaping here because delimiter is '/'
echo "abc" | sed -nr 's|a\|b|A|gp'  # '|' needs escaping here because delimiter is '|'
```

* **`r`:**

```sh
# Prepare file1
cat > file1.txt << EOF
<html>
<body>
<tag>
</tag>
</body>
</html>
EOF

# Prepare file2
cat > file2.txt << EOF
Hello world!!
EOF

sed '/<tag>/ r file2.txt' file1.txt
```

* **`reverse match`:**

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

**Note**: On macOS, the `-i` option must be followed by an extension suffix to back up the original file. If the extension length is 0, no backup is made.

* `sed -i ".back" "s/a/b/g" example`: Backup file will be `example.back`  
* `sed -i "" "s/a/b/g" example`: No backup is made  

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

### 2.4.4 Best Practice

```sh
echo "1 2 3 4 5 3 2 1" | tr ' ' '\n' | awk '{count[$1]++} END {for (num in count) print count[num], num}' | sort -k1,1nr -k2,2n
```

## 2.5 cut

**Pattern:**

* `cut -b list [-n] [file ...]`
* `cut -c list [file ...]`
* `cut -f list [-s] [-d delim] [file ...]`

**Options:**

* `list`: Range  
    * `N`: The Nth byte, character, or field counting from the first  
    * `N-`: From the Nth to the end of the line, all characters, bytes, or fields  
    * `N-M`: From the Nth to the Mth (inclusive), all characters, bytes, or fields  
    * `-M`: From the first to the Mth (inclusive), all characters, bytes, or fields  
* `-b`: Split by bytes. These byte positions ignore multibyte character boundaries unless the `-n` flag is also specified  
* `-c`: Split by characters  
* `-d`: Custom delimiter, default is tab  
* `-f`: Used with `-d`, specify which fields to display  
* `-n`: Disable splitting multibyte characters. Only used with the `-b` flag. If the last byte of a character falls within the range specified by the `List` parameter of the `-b` flag, the character will be output; otherwise, it will be excluded

**Examples:**

* `echo "a:b:c:d:e" | cut -d ":" -f3`: Outputs `c`  
* `ll | cut -c 1-10`: Displays characters 1 to 10 of the query result  

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
* `-i`: Ignore case distinctions in patterns and input data, so that characters that differ only in case match each other.
* `-o`: Print only the matched (non-empty) parts of a matching line, with each such part on a separate output line.
* `-e`: Use `PATTERNS` as the patterns.
* `-E`: Interpret `PATTERNS` as extended regular expressions.
* `-F`: Interpret `PATTERNS` as fixed strings, not regular expressions.
* `-P`: Interpret `PATTERNS` as Perl-compatible regular expressions.
* `-l`: Suppress normal output; instead print the name of each input file from which output would normally have been printed. Scanning each input file stops upon first match.
* `-n`: Prefix each line of output with the 1-based line number within its input file.
* `-v`: Invert the sense of matching, to select non-matching lines.
* `-r`: Read all files under each directory, recursively, following symbolic links only if they are on the command line.
* `--color=auto|never|always`: Surround the matched (non-empty) strings, matching lines, context lines, file names, line numbers, byte offsets, and separators (for fields and groups of context lines) with escape sequences to display them in color on the terminal. The colors are defined by the environment variable GREP_COLORS. Can be never, always, or auto.
* `-A <NUM>`: Print `NUM` lines of trailing context after matching lines.
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

`ack` is an enhanced version of `grep`, and `ag` (The Silver Searcher) is an enhanced version of `ack`. `ag` uses extended regular expressions by default and recursively searches in the current directory.

**Pattern:**

* `ag [options] pattern [path ...]`

**Options:**

* `-c`: Count the number of times the 'search string' is found  
* `-i`: Ignore case differences  
* `-l`: Output matching filenames instead of matching content  
* `-n`: Disable recursion  
* `-v`: Invert match, i.e., output lines that do NOT contain the 'search string'  
* `-r`: Recursively search in the specified directory (default behavior)  
* `-A`: Followed by a number, meaning "after" — output the matched line plus the following n lines  
* `-B`: Followed by a number, meaning "before" — output the matched line plus the preceding n lines  
* `-C`: Followed by a number — output the matched line plus n lines before and after  

**Examples:**

* `ag printf`

## 2.8 sort

**Pattern:**

* `sort [-fbMnrtuk] [file or stdin]`

**Options:**

* `-f`: Ignore case differences  
* `-b`: Ignore leading spaces  
* `-M`: Sort by month name, e.g., JAN, DEC  
* `-n`: Sort numerically (default is lexicographical sort)  
* `-r`: Reverse sort order  
* `-u`: Like `uniq`, output only one line for duplicate data  
* `-t`: Field delimiter, default is Tab  
* `-k`: Specify which field(s) to sort by  

**Examples:**

* `cat /etc/passwd | sort`  
* `cat /etc/passwd | sort -t ':' -k 3`  
* `echo -e "a\nb\nb\na\nb\na\na\nc\na" | sort | uniq -c | sort -nr`  
    * `sort | uniq -c | sort -nr`: Common way to count occurrences of identical patterns  
* `echo "1 2 3 4 5 3 2 1" | tr ' ' '\n' | awk '{count[$1]++} END {for (num in count) print count[num], num}' | sort -k1,1nr -k2,2n`: Sort by first column descending, then second column ascending  

## 2.9 uniq

**Pattern:**

* `sort [options] [file or stdin]`

**Options:**

* `-c`: Count the number of occurrences  
* `-d`: Only count duplicated entries  
* `-i`: Ignore case differences  
* `-u`: Only count entries that appear once  

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

* `-c`: Output in compact form (one line)

**Examples:**

* Iterate over an array
    ```sh
    content='[{"item":"a"},{"item":"b"}]'
    while IFS= read -r element; do
        echo "Element: $element"
    done < <(jq -c '.[]' <<< "$content")
    ```

* Extract elements
    ```sh
    content='{"person":{"name":"Alice","age":28,"address":{"street":"123 Main St","city":"Wonderland","country":"Fantasyland"},"contacts":[{"type":"email","value":"alice@example.com"},{"type":"phone","value":"555-1234"}]}}'
    jq -c '.person | .address | .city' <<< ${content}
    jq -c '.person.address.city' <<< ${content}
    jq -c '.person.contacts[1].value' <<< ${content}
    ```

## 2.12 xargs

**Options:**

* `-r, --no-run-if-empty`: Do not run the command if input is empty  
* `-I {}`: Replace the placeholder `{}` in the following command with standard input  
* `-t`: Print the commands to be executed  

**Examples:**

* `docker ps -aq | xargs docker rm -f`
* `echo "   a  b  c  " | xargs`: Implementing `trim`
* `ls | xargs -I {} rm -f {}`

## 2.13 tee

`>`, `>>`, etc. redirect the data stream to a file or device, so unless you read that file or device, you cannot further use the data stream. If you want to save part of the data stream during processing, you can use `tee` (essentially, `tee` duplicates `stdout`).

`tee` sends the data stream both to a file and to the screen (the output to the screen is `stdout`), allowing the next command to continue processing it (**`>`, `>>` truncate `stdout`, thus cannot pass it as `stdin` to the next command**).

**Pattern:**

* `tee [-a] file`

**Options:**

* `-a`: Append data to the file instead of overwriting  

**Examples:**

* `command | tee <file> | command`

## 2.14 cat

**Pattern:**

* `cat > [newfile] <<'END_MARKER'`

**Example: Note the difference between `EOF` and `'EOF'`**

* Search `Here Documents` in `man bash` to see the difference between these two

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
* `cat -A <file>`: equivalent to -vET.

## 2.15 tail

**Examples:**

* `tail -f xxx.txt`  
* `tail -n +2 xxx.txt`: Output from the second line to the last line  

## 2.16 find

**Pattern:**

* `find [file_path] [option] [action]`

**Options:**

* `-name`: Followed by a filename, supports wildcards. **Note this matches relative paths**
* `-regex`: Followed by a regular expression, **Note this matches the full path**
* `-maxdepth`: Followed by search depth
* `-regextype`: Type of regular expression
    * `emacs`: Default type
    * `posix-awk`
    * `posix-basic`
    * `posix-egrep`
    * `posix-extended`
* `-type`: Followed by type
    * `f`: Regular file, default type
    * `d`: Directory

**Examples:**

* `find . -name "*.c"`
* `find . -maxdepth 1 -name "*.c"`
* `find . -regex ".*/.*\.c"`
* Find files with suffixes `.cfg` and `.conf`
    * `find ./ -name '*.cfg' -o -name '*.conf'`
    * `find ./ -regex '.*\.cfg\|.*\.conf'`
    * `find ./ -regextype posix-extended -regex '.*\.(cfg|conf)'`
* `find . -type f -executable`: Find executable binary files  

## 2.17 locate

**`locate` searches data inside an existing database `/var/lib/mlocate`, so it does not directly access the hard drive. Therefore, compared to `find`, it is faster.**

**Install:**

```sh
yum install -y mlocate
```

**Usage:**

```sh
# When using for the first time, update the database first
updatedb

locate stl_vector.h
```

## 2.18 cp

**Examples:**

* `cp -vrf /a /b`: Recursively copy directory `/a` into directory `/b`, including all files, directories, hidden files, and hidden directories inside `/a`
* `cp -vrf /a/* /b`: Recursively copy all files and directories under `/a` but excluding hidden files and hidden directories
* `cp -vrf /a/. /b`: Recursively copy all files, directories, hidden files, and hidden directories inside `/a` into directory `/b`

## 2.19 rsync

`rsync` is used for file synchronization. It can synchronize files between a local computer and a remote computer, or between two local directories. It can also serve as a file copying tool, replacing the `cp` and `mv` commands.

The `r` in its name stands for `remote`, and `rsync` essentially means remote synchronization (`remote sync`). Unlike other file transfer tools (such as `FTP` or `scp`), the biggest feature of `rsync` is that it checks the existing files on both the sender and the receiver, transmitting only the parts that have changed (the default rule is changes in file size or modification time).

**Pattern:**

* `rsync [options] [src1] [src2] ... [dest]`
* `rsync [options] [user@host:src1] ... [dest]`
* `rsync [options] [src1] [src2] ... [user@host:dest]`
* About `/`
    * `src`
        * If `src1` is a file, there is only one way to write it: `src1`.
        * If `src1` is a directory, there are two ways to write it:
            * `src1`: Copies the entire directory, including `src1` itself.
            * `src1/`: Copies the contents of the directory without including `src1` itself.
    * `dest`
        * `dest`: If copying a single file, `dest` represents the target file. If not copying a single file, `dest` represents a directory.
        * `dest/`: Always represents a directory.
        * There is one exception: to represent the user directory on a remote machine, write it as `user@host:~/`, otherwise `~` will be treated as a normal directory name.

**Options:**

* `-r`: Recursive. This parameter is mandatory; otherwise, the command will fail.
* `-a`: Includes `-r` and also synchronizes metadata (e.g., modification time, permissions). By default, `rsync` uses file size and modification time to determine if a file needs to be updated. With the `-a` parameter, differences in permissions will also trigger updates.
* `-n`: Simulate the command results.
* `--delete`: By default, `rsync` ensures that all contents of the source directory (excluding explicitly excluded files) are copied to the destination directory. It does not make the two directories identical and does not delete files. To make the destination directory a mirror copy of the source directory, use the `--delete` parameter, which will remove files that exist only in the destination directory but not in the source directory.
* `--exclude`: Specifies exclude patterns. To exclude multiple files, this parameter can be repeated.
    * `--exclude='.*'`: Exclude hidden files.
    * `--exclude='dir1/'`: Exclude a specific directory.
    * `--exclude='dir1/*'`: Exclude all files in a specific directory but not the directory itself.
* `--include`: Specifies file patterns that must be synchronized, often used together with `--exclude`.
* `--compress, -z`: Compress file data during the transfer.
* `--progress, -P`: Show progress.

**Examples:**

* `rsync -av /src/foo /dest`: Copies the entire directory `/src/foo` into the directory `/dest`.
* `rsync -av /src/foo/ /dest`: Copies the contents of the directory `/src/foo` into the directory `/dest`.
* `rsync -a --exclude=log/ dir1/ dir2`: Copies the contents of `dir1` into the directory `dir2`, excluding all subdirectories named `log`.
* `rsync -a --exclude=log/ dir1 dir2`: Copies the entire `dir1` directory into the `dir2` directory, excluding all subdirectories named `log`.
* `rsync -a dir1 user1@192.168.0.1:~`: Copies the entire `dir1` directory to a directory named `~` under the user directory of `user1` on the machine `192.168.0.1`, resulting in `~/\~/dir1` (**a very tricky issue**).
* `rsync -a dir1 user1@192.168.0.1:~/`: Copies the entire `dir1` directory to the user directory of `user1` on the machine `192.168.0.1`, resulting in `~/dir1`.

## 2.20 rm

**Examples:**

* `rm -rf /a/*`: Recursively delete all files and directories under `/a`, but excluding hidden files and hidden directories
* `rm -rf /path/{..?*,.[!.]*,*}`: Recursively delete all files, directories, hidden files, and hidden directories under `/path`
* `rm -rf /path/!(a.txt|b.txt)`: Recursively delete all files and directories under `/path` except for `a.txt` and `b.txt`, excluding hidden files and hidden directories
    * Requires enabling `extglob` with the command `shopt -s extglob`
    * How to use `extglob` inside `/bin/bash -c`:
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
        # rmtest/sub/keep cannot be preserved
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

* `-s`: Silent mode. Only displays content, generally used for executing scripts, for example `curl -s '<url>' | bash -s`
* `-L`: If the original link has a redirect, it will continue to access the new link
* `-o`: Specify the download filename
* `-X`: Specify the `Http Method`, for example `POST`
* `-H`: Add `Http Header`
* `-d`: Specify the `Http Body`
* `-u <username>:<password>`: For services that require authentication, you need to specify the username or password. `:<password>` can be omitted and entered interactively

**Examples:**

* `curl -L -o <filename> '<url>'`

## 2.23 wget

**Pattern:**

* `wget [options] [URL]...`

**Options:**

* `-O`: Followed by the name of the file to be downloaded
* `-r`: Recursive download (used for downloading folders)
* `-nH`: When downloading folders, do not create a host directory
* `-np`: Do not access the parent directory
* `-P`: Specify the download directory
* `-R`: Specify the exclusion list
* `--proxy`: Followed by the proxy address

**Examples:**

* `wget -O myfile 'https://www.baidu.com'`
* `wget -r -np -nH -P /root/test 'http://192.168.66.1/stuff'`: Recursive download.
* `wget -r -np -nH -P /root/test -R "index.html*" 'http://192.168.66.1/stuff'`: Recursive download but excluding pattern `index.html*`.
* `wget -r -np -nH -P /root/test 'ftp://192.168.66.1/stuff'`: Recursive download.
* `wget --proxy=http://proxy.example.com:8080 http://example.com/file`

## 2.24 tree

**Pattern:**

* `tree [option]`

**Options:**

* `-N`: Display non-ASCII characters, can show Chinese
* `-L [num]`: Control the display depth level

## 2.25 split

**Examples:**

* `split -b 2048M bigfile bigfile-slice-`: Split the file by size, each split file is up to `2048M`, with the prefix `bigfile-slice-`
* `split -l 10000 bigfile bigfile-slice-`: Split the file by lines, each split file contains up to `10000` lines, with the prefix `bigfile-slice-`

## 2.26 base64

Used for `base64` encoding and decoding of input

**Examples:**

* `echo "hello" | base64`
* `echo "hello" | base64 | base64 -d`

## 2.27 md5sum

Calculate the MD5 checksum of input or file

**Examples:**

* `echo -n "hello" | md5sum`

## 2.28 openssl

This command is used to encrypt or decrypt files using a specified algorithm

**Examples:**

* `openssl -h`: View all supported encryption and decryption algorithms
* `openssl aes-256-cbc -a -salt -in blob.txt -out cipher`
* `openssl aes-256-cbc -a -d -in cipher -out blob-rebuild.txt`

## 2.29 bc

bc can be used for base conversion

**Examples:**

* `echo "obase=8;255" | bc`: Convert decimal to octal
* `echo "obase=16;255" | bc`: Convert decimal to hexadecimal
* `((num=8#77)); echo ${num}`: Convert octal to decimal
* `((num=16#FF)); echo ${num}`: Convert hexadecimal to decimal

## 2.30 dirname

`dirname` is used to return the directory part of a file path. This command does not check whether the directory or file corresponding to the path actually exists.

**Examples:**

* `dirname /var/log/messages`: returns `/var/log`
* `dirname dirname aaa/bbb/ccc`: returns `aaa/bbb`
* `dirname .././../.././././a`: returns `.././../../././.`

Usually used in scripts to get the directory where the script is located, example shown below:

```sh
# Here $0 represents the script path (relative or absolute)
ROOT=$(dirname "$0")
ROOT=$(cd "$ROOT"; pwd)
```

## 2.31 addr2line

This command is used to view the correspondence between binary offsets and source code. If the binary and the machine that produced the core file are not the same, symbol table mismatches may occur, resulting in incorrect source code locations.

**Examples:**

* `addr2line 4005f5 -e test`: View the source code corresponding to the instruction at position `4005f5` in the binary `test`

## 2.32 ldd

This command is used to see which dynamic libraries an executable file is linked to

**Examples:**

* `ldd main`
    * `readelf -a ./main | grep NEEDED`
    * `objdump -x ./main | grep NEEDED`

## 2.33 ldconfig

**Generate dynamic library cache or read dynamic library information from cache**

**Examples:**

* `ldconfig`: Regenerate `/etc/ld.so.cache`
* `ldconfig -v`: Regenerate `/etc/ld.so.cache` and output detailed information
* `ldconfig -p`: Read and display dynamic library information from `/etc/ld.so.cache`

## 2.34 objdump

This command is used for disassembly

**Examples:**

* `objdump -drwCS main.o`
* `objdump -drwCS -M intel main.o`
* `objdump -p main`

## 2.35 objcopy & strip

This command is used to extract debug information from binaries. Example:

[[Enhancement] strip debug symbol in release mode](https://github.com/StarRocks/starrocks/pull/24442)

```sh
objcopy --only-keep-debug main main.debuginfo
strip --strip-debug main
objcopy --add-gnu-debuglink=main.debuginfo main main-with-debug

# check the .gnu_debuglink section
readelf --string-dump=.gnu_debuglink main-with-debug
```

When you're debugging the binary through `gdb`, it will automatically load the corresponding debug info file, and you can also manually load it using the `symbol-file` command, like `(gdb) symbol-file /path/to/binary_file.debuginfo`.

## 2.36 nm

This command is used to view the symbol table

**Examples:**

* `nm -C main`
* `nm -D xxx.so`

## 2.37 strings

This command is used to view all string information contained in a binary file

**Examples:**

* `strings main`

## 2.38 iconf

**Options:**

* `-l`: List all encodings
* `-f`: Source encoding
* `-t`: Target encoding
* `-c`: Ignore problematic encodings
* `-s`: Suppress warnings
* `-o`: Output file
* `--verbose`: Output file processing progress

**Examples:**

* `iconv -f gbk -t utf-8 s.txt > t.txt`

## 2.39 expect

expect is an automation tool for interactive sessions. By writing custom configurations, it can automatically fill in data.

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

This command is used to mount a file system

**Pattern:**

* `mount [-t vfstype] [-o options] device dir`

**Options:**

* `-t`: Followed by the file system type; if not specified, it will auto-detect
* `-o`: Followed by mount options

**Examples:**

* `mount -o loop /CentOS-7-x86_64-Minimal-1908.iso /mnt/iso`

### 3.1.1 Propagation Level

When the kernel initially introduced `mount namespace`, the isolation between namespaces was weak. For example, if a `mount` or `umount` action was performed in one namespace, the event would propagate to other namespaces, which is unsuitable in certain scenarios.

Therefore, starting from version `2.6.15`, the kernel allows marking a mount point as `shared`, `private`, `slave`, or `unbindable` to provide fine-grained isolation control:

* `shared`: The default propagation level; `mount` and `unmount` events propagate between different namespaces
* `private`: Prohibits `mount` and `unmount` events from propagating between different namespaces
* `slave`: Allows only one-way propagation, i.e., events generated by the `master` propagate to the `slave`
* `unbindable`: Disallows `bind` operations; under this propagation level, new namespaces cannot be created

## 3.2 umount

This command is used to unmount a file system

**Examples:**

* `umount /home`

## 3.3 findmnt

This command is used to view information about mount points

**Options:**

* `-o [option]`: Specify the columns to display

**Examples:**

* `findmnt -o TARGET,PROPAGATION`

## 3.4 free

**Pattern:**

* `free [-b|-k|-m|-g|-h] [-t]`

**Options:**

* `-b`: bytes
* `-m`: MB
* `-k`: KB
* `-g`: GB
* `-h`: Adaptive

**Description of Display Parameters:**

* `Mem`: Physical memory
* `Swap`: Virtual memory
* `total`: Total memory size, this information can be obtained from `/proc/meminfo` (`MemTotal`, `SwapTotal`)
* `user`: Used memory size, calculated as `total - free - buffers - cache`
* `free`: Unused memory size, this information can be obtained from `/proc/meminfo` (`MemFree`, `SwapFree`)
* `shared`: Memory used by `tmpfs`, this information can be obtained from `/proc/meminfo` (`Shmem`)
* `buffers`: Memory used by kernel buffers, this information can be obtained from `/proc/meminfo` (`Buffers`)
* `cached`: Memory used by `slabs` and `page cache`, this information can be obtained from `/proc/meminfo` (`Cached`)
* `available`: Memory still available for allocation to applications (excluding `swap` memory), this information can be obtained from `/proc/meminfo` (`MemAvailable`)
* **Generally, the system will efficiently use all available memory to accelerate system access performance, which is different from Windows. Therefore, for Linux systems, the larger the memory, the better.**

**Examples:**

* `free -m`

## 3.5 swap

**Make swap:**

```sh
dd if=/dev/zero of=/tmp/swap bs=1M count=128
mkswap /tmp/swap
swapon /tmp/swap
free
```

## 3.6 df

**Options:**

* `-h`: Use `K`, `M`, `G` units to improve readability of the information
* `-i`: Display `inode` information
* `-T`: Display the file system type explicitly

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

This command is used to list information about all available block devices

**Pattern:**

* `lsblk [option]`

**Options:**

* `-a, --all`: Print all devices
* `-b, --bytes`: Print SIZE in bytes instead of a human-readable format
* `-d, --nodeps`: Do not print slave or holder devices
* `-D, --discard`: Print discard capabilities
* `-e, --exclude <list>`: Exclude devices by major device number (default: memory disks)
* `-I, --include <list>`: Only show devices with the specified major device numbers
* `-f, --fs`: Output file system information
* `-h, --help`: Show help information (this message)
* `-i, --ascii`: Use only ASCII characters
* `-m, --perms`: Output permission information
* `-l, --list`: Use list format output
* `-n, --noheadings`: Do not print headings
* `-o, --output <list>`: Specify output columns
* `-p, --paths`: Print full device paths
* `-P, --pairs`: Use key="value" output format
* `-r, --raw`: Use raw output format
* `-s, --inverse`: Inverse dependencies
* `-t, --topology`: Output topology information
* `-S, --scsi`: Output information about SCSI devices

**Examples:**

* `lsblk -fp`
* `lsblk -o name,mountpoint,label,size,uuid`

## 3.10 lsusb

This command is used to list all devices on USB interfaces

## 3.11 lspci

This command is used to list all devices on PCI interfaces

## 3.12 lscpu

This command is used to list CPU devices

## 3.13 sync

This command is used to force data stored in the buffer to be written to the hard disk

## 3.14 numactl

This command is used to set and view `NUMA` information

**Options:**

* `--hardware`: Display hardware information, including the number of `NUMA-Nodes`, CPUs corresponding to each `Node`, memory size, and a matrix representing the memory access cost between `node[i][j]`
* `--show`: Display the current `NUMA` settings
* `--physcpubind=<cpus>`: Bind execution to `<cpus>`. `<cpus>` refers to the `processor` field in `/proc/cpuinfo`. `<cpus>` can be: `all`, `0,5,10`, `2-8`
* `--cpunodebind=<nodes>`: Bind execution to `<nodes>`. `<nodes>` can be: `all`, `0,1,6`, `0-3`
* `Memory Policy`
    * `--interleave=<nodes>`: Allocate memory in a round-robin manner across `<nodes>`
    * `--preferred=<node>`: Prefer allocating memory from `<node>`
    * `--membind=<nodes>`: Allocate memory on `<nodes>`
    * `--localalloc`: Allocate memory on the node where the CPU is located; requires CPU binding to optimize
    * `<nodes>` can be: `all`, `0,1,6`, `0-3`

**Examples:**

* `numactl --hardware`
* `numactl --show`: Display current `NUMA` settings

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

This command is used to read and analyze executable programs

**Options:**

* `-d`: Output information related to dynamic linking (if any)
* `-s`: Output symbol information

**Examples:**

* `readelf -d libc.so.6`
* `readelf -s --wide xxx.so`

## 3.19 readlink

print resolved symbolic links or canonical file names

**Examples:**

* `readlink -f $(which java)`

# 4 Process Management

**Background Process (&):**

Appending `&` at the end of a command means executing the command in the background.

* At this point, bash will assign the command a job number, followed by the PID triggered by the command.
* It cannot be interrupted with `[Ctrl]+C`.
* For commands executed in the background, if there is stdout or stderr, their output still goes to the screen. As a result, the prompt may not be visible. After the command finishes, you must press `[Enter]` to see the command prompt again. It also cannot be interrupted using `[Ctrl]+C`. The solution is to use stream redirection.

**Examples:**

* `tar -zpcv -f /tmp/etc.tar.gz /etc > /tmp/log.txt 2>&1 &`
* `Ctrl+C`: Terminates the current process
* `Ctrl+Z`: Pauses the current process
* `$!`: Stores the PID of the most recently started background process

## 4.1 jobs

**Pattern:**

* `jobs [option]`

**Options:**

* `-l`: In addition to listing the job number and command string, also displays the PID number  
* `-r`: Lists only the jobs currently running in the background  
* `-s`: Lists only the jobs currently stopped in the background  
* Meaning of the `+` and `-` symbols in the output:  
    * `+`: The most recently placed job in the background, representing the default job to be brought to the foreground when just 'fg' is entered  
    * `-`: The second most recently placed job in the background  
    * For jobs older than the last two, there will be no `+` or `-` symbols

**Examples:**

* `jobs -lr`
* `jobs -ls`

## 4.2 fg

Bring background jobs to the foreground for processing

**Examples:**

* `fg %jobnumber`: Brings the job with the specified `jobnumber` to the foreground. `jobnumber` is the job number (a digit), and the `%` is optional  
* `fg +`: Brings the job marked with `+` to the foreground  
* `fg -`: Brings the job marked with `-` to the foreground

## 4.3 bg

Resume a job to running state in the background

**Examples:**

* `bg %jobnumber`: Resumes the job with the specified `jobnumber`. `jobnumber` is the job number (a digit), and the `%` is optional  
* `bg +`: Resumes the job marked with `+`
* `bg -`: Resumes the job marked with `-`
* Jobs like vim cannot be resumed to running state in the background—even if this command is used, such jobs will immediately return to a stopped state

## 4.4 kill

The command is used to terminate processes.

**Pattern:**

* `kill [-signal] PID`
* `kill [-signal] %jobnumber`
* `kill -l`

**Options:**

* `-l`: Lists the signals currently available for use with the `kill` command  
* `-signal`:  
    * `-1`: Reloads the configuration file, similar to a reload operation  
    * `-2`: Same as pressing [Ctrl]+C on the keyboard  
    * `-6`: Triggers a core dump  
    * `-9`: Immediately and forcibly terminates a job; commonly used for forcefully killing abnormal jobs  
    * `-15`: Terminates a job gracefully using the normal program procedure. Unlike `-9`, `-15` ends a job through the regular shutdown process and is the default signal  
* Unlike `bg` and `fg`, when managing jobs with `kill`, the `%` symbol **cannot** be omitted, because `kill` interprets the argument as a PID by default

## 4.5 pkill

**Pattern:**

* `pkill [-signal] PID`
* `pkill [-signal] [-Ptu] [arg]`

**Options:**

* `-f`: Matches the full `command line`; by default, only the first 15 characters are matched  
* `-signal`: Same as in `kill`  
* `-P ppid,...`: Matches the specified `parent id`  
* `-s sid,...`: Matches the specified `session id`  
* `-t term,...`: Matches the specified `terminal`  
* `-u euid,...`: Matches the specified `effective user id`  
* `-U uid,...`: Matches the specified `real user id`  
* **If no matching rule is specified, the default behavior is to match the process name**

**Examples:**

* `pkill -9 -t pts/0`
* `pkill -9 -u user1`

## 4.6 ps

**Options:**

* `a`: All processes not associated with a terminal  
* `u`: Processes related to the effective user  
* `x`: Usually used together with `a` to display more complete information  
* `A/e`: Displays all processes  
* `-f/-l`: Detailed information; the content differs between the two  
* `-T/-L`: Thread information; when used with `-f/-l`, the displayed details vary  
* `-o`: Followed by comma-separated column names to specify which information to display  
    * `%cpu`  
    * `%mem`  
    * `args`  
    * `uid`  
    * `pid`  
    * `ppid`  
    * `lwp/tid/spid`: Thread `TID`, `lwp` stands for "light weight process", i.e., a thread  
    * `comm/ucomm/ucmd`: Thread name  
    * `time`  
    * `tty`  
    * `flags`: Process flags  
        * `1`: Forked but didn't exec  
        * `4`: Used super-user privileges  
    * `stat`: Process status
        * `D`: uninterruptible sleep (usually IO)
        * `R`: running or runnable (on run queue)
        * `S`: interruptible sleep (waiting for an event to complete)
        * `T`: stopped by job control signal
        * `t`: stopped by debugger during the tracing
        * `W`: paging (not valid since the 2.6.xx kernel)
        * `X`: dead (should never be seen)
        * `Z`: defunct ("zombie") process, terminated but not reaped by its parent
* `-w`: Wide output.  Use this option twice for unlimited width.

**Examples:**

* `ps aux`
* `ps -ef`
* `ps -efww`
* `ps -el`
* `ps -e -o pid,ppid,stat | grep Z`: Find zombie processes  
* `ps -T -o tid,ucmd -p 212381`: View all thread IDs and thread names of the specified process

## 4.7 pgrep

**Pattern:**

* `pgrep [-lon] <pattern>`

**Options:**

* `-a`: Lists the PID and the full program name  
* `-l`: Lists the PID and the program name  
* `-f`: Matches the full process name  
* `-o`: Lists the oldest process  
* `-n`: Lists the newest process

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

* `-a`: Displays the command  
* `-l`: Does not truncate output  
* `-A`: Connects process trees using ASCII characters (connection symbols are ASCII characters)  
* `-U`: Connects process trees using UTF-8 characters, which may cause errors in some terminal interfaces (connection symbols are UTF-8 characters, smoother and more visually appealing)  
* `-p`: Also lists the PID of each process  
* `-u`: Also lists the account name each process belongs to  
* `-s`: Displays the parent process of the specified process

**Examples:**

* `pstree`: Displays the entire process tree  
* `pstree -alps <pid>`: Displays the process tree rooted at the specified `<pid>`

## 4.9 pstack

This command is used to view the stack of a specified process

**Install:**

```sh
yum install -y gdb
```

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

This command is used to view or set the CPU affinity of a process

**Pattern:**

* `taskset [options] -p pid`
* `taskset [options] -p [mask|list] pid`

**Options:**

* `-c`: Displays CPU affinity in list format  
* `-p`: Specifies the PID of the process  

**Examples:**

* `taskset -p 152694`: View the CPU affinity of the process with PID `152694`, displayed as a mask  
* `taskset -c -p 152694`: View the CPU affinity of the process with PID `152694`, displayed as a list  
* `taskset -p f 152694`: Set the CPU affinity of the process with PID `152694` using a mask  
* `taskset -c -p 0,1,2,3,4,5 152694`: Set the CPU affinity of the process with PID `152694` using a list

**What is a CPU affinity mask (hexadecimal)**

* `cpu0 = 1`  
* `cpu1 = cpu0 * 2 = 2`  
* `cpu2 = cpu1 * 2 = 4`  
* `cpu(n) = cpu(n-1) * 2`  
* `mask = cpu0 + cpu1 + ... + cpu(n)`  
* Some examples:  
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

This command is used to allow authorized users to execute programs as another user

**Pattern:**

* `pkexec [command]`

## 4.15 nohup

**`nohup` ignores all hangup (SIGHUP) signals**. For example, when logging into a remote server via `ssh` and starting a program, that program will terminate once the `ssh` session ends. If started with `nohup`, the program will continue running even after logging out of `ssh`.

**Pattern:**

* `nohup command [args] [&]`

**Options:**

* `command`: The command to execute  
* `args`: Arguments required by the command  
* `&`: Run in the background

**Examples:**

* `nohup java -jar xxx.jar &`

## 4.16 screen

**If you want a program to continue running after closing the `ssh` connection, you can use `nohup`. If you want to be able to check the status of the program started in a previous `ssh` session the next time you log in via `ssh`, then you need to use `screen`.**

**Pattern:**

* `screen`
* `screen cmd [ args ]`
* `screen [–ls] [-r pid]`
* `screen -X -S <pid> kill`
* `screen -d -m cmd [ args ]`

**Options:**

* `cmd`: The command to execute  
* `args`: Arguments required by the command  
* `-ls`: Lists details of all `screen` sessions  
* `-r`: Followed by a `pid`, attaches to the `screen` session with the specified process ID  
* `-d`: Detaches from the current running session

**Examples:**

* `screen`
* `screen -ls`
* `screen -r 123`

**Session Management:**

1. `Ctrl a + w`: Show the list of all windows  
2. `Ctrl a + Ctrl a`: Switch to the previously displayed window  
3. `Ctrl a + c`: Create a new window running a shell and switch to it  
4. `Ctrl a + n`: Switch to the next window  
5. `Ctrl a + p`: Switch to the previous window (opposite of `Ctrl a + n`)  
6. `Ctrl a + 0-9`: Switch to window 0..9  
7. `Ctrl a + d`: Temporarily detach the screen session  
8. `Ctrl a + k`: Kill the current window

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
        * `<prefix> &`: Kill current session.
* **Options:**
    * `Session Options`
        * `tmux set-option -g <key> <value>`/`tmux set -g <key> <value>`
        * `tmux show-options -g`/`tmux show-options -g <key>`
        * `tmux set -g escape-time 50`: Controls how long tmux waits to distinguish between an escape sequence (like a function key or arrow key) and a standalone Escape key press.
    * `Window Options`
        * `tmux set-window-option -g <key> <value>`/`tmux setw -g <key> <value>`
        * `tmux show-window-options -g`/`tmux show-window-options -g <key>`
        * `tmux setw -g mode-keys vi`: Use vi mode.
        * `tmux set-hook -g after-rename-window 'set -w allow-rename off'`

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
set-hook -g after-rename-window 'set -w allow-rename off'

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# [Option] + h, which is「˙」
# [Option] + j, which is「∆」
# [Option] + k, which is「˚」
# [Option] + l, which is「¬」
# [Option] + [shift] + p, which is「∏」
# [Option] + [shift] + n, which is「˜」

# Pane switch
# send-keys means passing the key to current command, i.e. vim/nvim.
bind -n ˙ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ˙" "select-pane -L"
bind -n ¬ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ¬" "select-pane -R"
bind -n ∆ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ∆" "select-pane -U"
bind -n ˚ if-shell -F "#{||:#{==:#{pane_current_command},vim},#{==:#{pane_current_command},nvim}}" "send-keys ˚" "select-pane -D"

# Window switch
bind -n ∏ previous-window
bind -n ˜ next-window

# Create the 'ktb_vim'(or any identifier you like) key table for Vim mode (pass keys to Vim/Neovim)
bind -T ktb_vim ∏ send-keys ∏
bind -T ktb_vim ˜ send-keys ˜

# Toggle between the 'ktb_vim' and default 'root' key tables
bind v if -F '#{==:#{key-table},ktb_vim}' 'set -w key-table root; switch-client -T root' 'set -w key-table ktb_vim; switch-client -T ktb_vim'

# Clear history
bind C-k clear-history \; send-keys C-l \; refresh-client

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

[reptyr](https://github.com/nelhage/reptyr) is used to reparent a specified process to the current terminal's `pid`. Sometimes, when we ssh into a remote machine to run a command and later realize that the command will run for a long time but must disconnect the ssh session, we can open a new `screen` or `tmux` session and attach the target process to the new terminal.

Note: `reptyr` relies on the `ptrace` system call, which can be enabled by running `echo 0 > /proc/sys/kernel/yama/ptrace_scope`.

**Examples:**

* `reptyr <pid>`

# 5 Network Management

## 5.1 netstat

**Pattern:**

* `netstat -[rn]`
* `netstat -[antulpc]`

**Options:**

1. **Routing-related parameters**
    * `-r`: List the routing table, functions like `route`  
    * `-n`: Do not use hostnames and service names; use IP addresses and port numbers, similar to `route -n`  
2. **Network interface-related parameters**
    * `-a`: List all connection states, including tcp/udp/unix sockets, etc.  
    * `-t`: List only TCP packet connections  
    * `-u`: List only UDP packet connections  
    * `-l`: List only network states of services that are in Listen mode  
    * `-p`: List PID and program filename  
    * `-c`: Auto-update display every few seconds, e.g., `-c 5` updates every 5 seconds  

**Explanation of routing-related display fields**

* `Destination`: Means network  
* `Gateway`: The gateway IP of the interface; if 0.0.0.0, no extra IP is needed  
* `Genmask`: The netmask; combined with Destination to define a host or network  
* `Flags`: Various flags indicating the meaning of the route or host  
    * `U`: Route is usable  
    * `G`: Network requires forwarding via gateway  
    * `H`: This route is for a host, not a whole network  
    * `D`: Route created by redirect message  
    * `M`: Route modified by redirect message  
    * `Iface`: Interface  

**Explanation of network interface-related display fields:**

* `Proto`: Packet protocol of the connection, mainly TCP/UDP  
* `Recv-Q`: Total bytes copied from non-user program connections  
* `Send-Q`: Bytes sent by remote host without ACK flag; also refers to bytes occupied by active connection SYN or other flag packets  
* `Local Address`: Local endpoint address, can be IP or full hostname, formatted as "IP:port"  
* `Foreign Address`: Remote host IP and port number  
* `stat`: Status bar  
    * `ESTABLISHED`: Connection established  
    * `SYN_SENT`: Sent an active connection (SYN flag) packet  
    * `SYN_RECV`: Received an active connection request packet  
    * `FIN_WAIT1`: Socket service interrupted, connection is closing  
    * `FIN_WAIT2`: Connection closed, waiting for remote host to acknowledge close  
    * `TIME_WAIT`: Connection closed, socket waiting on network to finish  
    * `LISTEN`: Usually a service listening port; can be viewed with `-l`  

The function of `netstat` is to check network connection status. The most common aspects are **how many ports I have open waiting for client connections** and **the current state of my network connections, including how many are established or have issues**.

**Examples:**

1. **`netstat -n | awk '/^tcp/ {++y[$NF]} END {for(w in y) print w, y[w]}'`**
1. **`netstat -nlp | grep <pid>`** 

## 5.2 tc

Traffic management is controlled by three types of objects: `qdisc` (queueing discipline), `class`, and `filter`.

**Pattern:**

* `tc qdisc [ add | change | replace | link ] dev DEV [ parent qdisc-id | root ] [ handle qdisc-id ] qdisc [ qdisc specific parameters ]`
* `tc class [ add | change | replace ] dev DEV parent qdisc-id [ classid class-id ] qdisc [ qdisc specific parameters ]`
* `tc filter [ add | change | replace ] dev DEV [ parent qdisc-id | root ] protocol protocol prio priority filtertype [ filtertype specific parameters ] flowid flow-id`
* `tc [-s | -d ] qdisc show [ dev DEV ]`
* `tc [-s | -d ] class show dev DEV`
* `tc filter show dev DEV`

**Options:**

**Examples:**

* `tc qdisc add dev em1 root netem delay 300ms`: Set network delay to 300ms  
* `tc qdisc add dev em1 root netem loss 8% 20%`: Set packet loss rate between 8% and 20%  
* `tc qdisc del dev em1 root`: Delete the specified settings  

## 5.3 ss

`ss` stands for Socket Statistics. As the name suggests, the `ss` command is used to obtain socket statistics information and can display content similar to `netstat`. The advantage of `ss` is that it can show more detailed information about TCP and connection states, and it is faster and more efficient than `netstat`.

When the number of socket connections on a server becomes very large, both the `netstat` command and directly using `cat /proc/net/tcp` become slow.

The secret to `ss`’s speed lies in its use of the `tcp_diag` module in the TCP protocol stack. `tcp_diag` is a module for analysis and statistics that can get first-hand information from the Linux kernel, ensuring that `ss` is fast and efficient.

**Pattern:**

* `ss [-talspnr]`

**Options:**

* `-t`: List tcp sockets  
* `-u`: List udp sockets  
* `-a`: List all sockets  
* `-l`: List all listening sockets  
* `-e`: Show detailed socket information, including inode number  
* `-s`: Show summary information only  
* `-p`: Show processes using the socket  
* `-n`: Do not resolve service names  
* `-r`: Resolve service names  
* `-m`: Show memory usage  
* `-h`: Show help documentation  
* `-i`: Show tcp socket details  

**Examples:**

* `ss -s`  
* `ss -t -a`: Show all tcp sockets  
* `ss -ti -a`: Show all tcp sockets with details  
* `ss -u -a`: Show all udp sockets  
* `ss -nlp | grep 22`: Find the program that opened socket/port 22  
* `ss -o state established`: Show all sockets in established state  
* `ss -o state FIN-WAIT-1 dst 192.168.25.100/24`: Show all sockets in `FIN-WAIT-1` state with destination network `192.168.25.100/24`  
* `ss -nap`  
* `ss -nap -e`  
* `ss -naptu`

## 5.4 ip

### 5.4.1 ip address

For detailed usage, refer to `ip address help`.

**Examples:**

* `ip -4 addr show scope global`
* `ip -6 addr show scope global`
* `ip -4 addr show scope host`

### 5.4.2 ip link

For detailed usage, refer to `ip link help`

**Examples:**

* `ip link`: View all network interfaces  
* `ip link up`: View interfaces in the up state  
* `ip -d link`: View detailed information  
    * `ip -d link show lo`  
* `ip link set eth0 up`: Enable the network interface  
* `ip link set eth0 down`: Disable the network interface  
* `ip link delete tunl0`: Delete the network interface  
* `cat /sys/class/net/xxx/carrier`: Check if the network cable is plugged in (corresponds to `ip link` showing `state UP` or `state DOWN`)  

### 5.4.3 ip route

For detailed usage, refer to `ip route help`

#### 5.4.3.1 Route Table

**Linux supports up to 255 routing tables, each with a `table id` and `table name`. Among them, 4 tables are built into the Linux system:**

* **`table id = 0`: Reserved by the system**
* **`table id = 255`: Local routing table, named `local`**. This table contains local interface addresses, broadcast addresses, and NAT addresses. It is automatically maintained by the system and cannot be modified directly by administrators.  
    * `ip r show table local`
* **`table id = 254`: Main routing table, named `main`**. If no routing table is specified, all routes are placed here by default. Routes added by older tools like `route` are usually added here. Routes in the `main` table are normal routing entries. When using `ip route` to configure routes, if no table is specified, operations default to this table.  
    * `ip r show table main`
* **`table id = 253`: Default routing table, named `default`**. Default routes usually reside in this table.  
    * `ip r show table default`

**Additional notes:**

* Administrators can add custom routing tables and routes as needed.
* The mapping between `table id` and `table name` can be viewed in `/etc/iproute2/rt_tables`.
* When adding a new routing table, the administrator needs to add its `table id` and `table name` mapping in `/etc/iproute2/rt_tables`.
* Routing tables are stored in memory and exposed to user space via the procfs filesystem at `/proc/net/route`.

#### 5.4.3.2 route type

**`unicast`**: Unicast routing is the most common type of routing in the routing table. This is a typical route to the destination network address, describing the path to the destination. Even complex routes (such as next-hop routes) are considered unicast routes. If the route type is not specified on the command line, the route is assumed to be a unicast route.

```sh
ip route add unicast 192.168.0.0/24 via 192.168.100.5
ip route add default via 193.7.255.1
ip route add unicast default via 206.59.29.193
ip route add 10.40.0.0/16 via 10.72.75.254
```

**`broadcast`**: This route type is used for link-layer devices that support the concept of broadcast addresses (such as Ethernet cards). This route type is only used in the local routing table and is typically handled by the kernel.

```sh
ip route add table local broadcast 10.10.20.255 dev eth0 proto kernel scope link src 10.10.20.67
ip route add table local broadcast 192.168.43.31 dev eth4 proto kernel scope link src 192.168.43.14
```

**`local`**: When an IP address is added to an interface, the kernel adds an entry to the local routing table. This means the IP is locally hosted.

```sh
ip route add table local local 10.10.20.64 dev eth0 proto kernel scope host src 10.10.20.67
ip route add table local local 192.168.43.12 dev eth4 proto kernel scope host src 192.168.43.14
```

**`nat`**: When a user attempts to configure stateless NAT, the kernel adds this route entry to the local routing table.

```sh
ip route add nat 193.7.255.184 via 172.16.82.184
ip route add nat 10.40.0.0/16 via 172.40.0.0
```

**`unreachable`**: When a request for a routing decision returns a route type indicating an unreachable destination, an ICMP unreachable message is generated and returned to the source address.

```sh
ip route add unreachable 172.16.82.184
ip route add unreachable 192.168.14.0/26
ip route add unreachable 209.10.26.51
```

**`prohibit`**: When a routing request returns a destination with a prohibit route type, the kernel generates an ICMP prohibit message returned to the source address.

```sh
ip route add prohibit 10.21.82.157
ip route add prohibit 172.28.113.0/28
ip route add prohibit 209.10.26.51
```

**`blackhole`**: Packets matching a route with the blackhole route type will be discarded. No ICMP is sent, and the packets are not forwarded.

```sh
ip route add blackhole default
ip route add blackhole 202.143.170.0/24
ip route add blackhole 64.65.64.0/18
```

**`throw`**: The throw route type is a convenient route type that causes the route lookup in the routing table to fail, thereby returning the routing process to the RPDB (Routing Policy Database). This is useful when there are other routing tables. Note that if there is no default route in the routing table, an implicit throw exists, so although it is valid, the route created by the first command in the example is redundant.

```sh
ip route add throw default
ip route add throw 10.79.0.0/16
ip route add throw 172.16.0.0/12
```

#### 5.4.3.3 route scope

**`global`**: Globally valid

**`site`**: Valid only within the current site (IPv6)

**`link`**: Valid only on the current device

**`host`**: Valid only on the current host

#### 5.4.3.4 route proto

**`proto`**: Indicates the timing of the route addition. It can be represented by a number or a string. The correspondence between numbers and strings can be found in `/etc/iproute2/rt_protos`.

1. **`redirect`**: Indicates that the route was added due to an `ICMP` redirect.
2. **`kernel`**: The route is automatically configured by the kernel during installation.
3. **`boot`**: The route is installed during the boot process. If a routing daemon starts, it will clear these route rules.
4. **`static`**: The route is installed by the administrator to override dynamic routes.

#### 5.4.3.5 route src

This is considered a hint to the kernel (used to answer: if I want to send a packet to host X, which local IP should I use as the Source IP). This hint is about which IP address to select as the source address for `outgoing` packets on that interface.

#### 5.4.3.6 Parameter Explanation

**Explanation of the `ip r show table local` parameters (example below):**

1. The first field indicates whether the route is for a `broadcast address`, an `IP address`, or an `IP range`, for example:
    * `local 192.168.99.35` indicates an `IP address`
    * `broadcast 127.255.255.255` indicates a `broadcast address`
    * `local 127.0.0.0/8 dev` indicates an `IP range`
1. The second field indicates through which device the route reaches the destination address, for example:
    * `dev eth0 proto kernel`
    * `dev lo proto kernel`
1. The third field indicates the scope of the route, for example:
    * `scope host`
    * `scope link`
1. The fourth field indicates the source IP address of outgoing packets:
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

Policy-based routing is more powerful and flexible than traditional routing. It allows network administrators to select forwarding paths not only based on the destination address but also based on packet size, application, source IP address, and other attributes. Simply put, Linux systems have multiple routing tables, and routing policies direct routing requests to different tables based on certain conditions. For example, packets with source addresses in a certain range use routing table A, while other packets use another routing table. Such rules are controlled by routing policy `rules`.

In Linux, a routing policy `rule` mainly contains three pieces of information: the priority of the `rule`, the conditions, and the routing table. The lower the priority number, the higher the priority. Then, depending on which conditions are met, the specified routing table is used for routing. **At Linux system startup, the kernel configures three default rules in the routing policy database: `rule 0`, `rule 32766`, and `rule 32767` (the numbers indicate the rule priorities). Their specific meanings are as follows:**

1. **`rule 0`**: Matches packets under any condition and looks up the `local` routing table (table id = 255). `rule 0` is very special and cannot be deleted or overridden.
2. **`rule 32766`**: Matches packets under any condition and looks up the `main` routing table (table id = 254). System administrators can delete or override this rule with another policy.
3. **`rule 32767`**: Matches packets under any condition and looks up the `default` routing table (table id = 253). This rule handles packets not matched by the previous default rules. This rule can also be deleted.
* In Linux, rules are matched sequentially according to their priority. Suppose the system only has the three rules with priorities `0`, `32766`, and `32767`. The system first tries rule `0` to find routes in the local routing table. If the destination is in the local network or is a broadcast address, a matching route will be found here. If no route is found, it moves to the next non-empty rule — here, rule `32766` — to search the main routing table. If no matching route is found, it falls back to rule `32767` to look up the default routing table. If this also fails, routing fails.

**Examples:**

```sh
# Add a rule that matches all packets and uses routing table 1; the rule priority is 32800
ip rule add [from 0/0] table 1 pref 32800

# Add a rule that matches packets from IP 192.168.3.112 with TOS equal to 0x10, uses routing table 2,
# has priority 1500, and the action is to prohibit (drop) the packets.
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

* `ip netns list`: Lists network namespaces (only reads from `/var/run/netns`)
* `ip netns exec test-ns ifconfig`: Executes `ifconfig` inside the network namespace `test-ns`

**Difference from nsenter**: Since `ip netns` only reads network namespaces from `/var/run/netns`, while `nsenter` by default reads from `/proc/${pid}/ns/net`. However, Docker hides the container's network namespace, meaning it does not create namespaces by default in the `/var/run/netns` directory. Therefore, to use `ip netns` to enter a container's namespace, a symbolic link must be created.

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

* `-S`: Outputs the rules of the specified table; if no table is specified, outputs all rules, similar to `iptables-save`.
* `-t`: Specifies the table, such as `nat` or `filter`. If omitted, the default is `filter`.
* `-L`: Lists the rules of the current table.
* `-n`: Disables reverse lookup of IP and HOSTNAME, greatly speeding up the display.
* `-v`: Lists more information, including the total number of packets matched by the rule and related network interfaces.

**Output Details:**

* Each Chain represents a chain; the parentheses next to the Chain show the default policy (i.e., the action taken when no rules match — the target).
* `target`: Represents the action to take
    * **`ACCEPT`**: Allow the packet
    * **`DROP`**: Discard the packet
    * **`QUEUE`**: Pass the packet to userspace
    * **`RETURN`**: Stop traversing the current chain and resume at the next rule in the previous chain (e.g., if `Chain A` calls `Chain B`, after `Chain B RETURN` it continues with the next rule in `Chain A`)
    * It can also be a custom Chain
* `port`: Indicates the protocol used by the packet, mainly TCP, UDP, or ICMP
* `opt`: Additional option details
* `source`: The source IP the rule applies to
* `destination`: The destination IP the rule applies to

**Examples:**

* `iptables -nL`
* `iptables -t nat -nL`

Since the above `iptables` commands only show formatted views, which may differ from the original rules in detail, it is recommended to use the command `iptables-save` to view firewall rules in detail.

**Pattern:**

* `iptables-save [-t table]`

**Options:**

* `-t`: Outputs rules for a specific table, e.g., only for NAT or Filter

**Output Details:**

* Lines starting with an asterisk (*) indicate the table, here it is Filter.
* Lines starting with a colon (:) indicate chains; the 3 built-in chains followed by their policies.
* After the chain is `[Packets:Bytes]`, indicating the number of packets and bytes passed through that chain.

### 5.5.2 Clearing Rules

**Pattern:**

* `iptables [-t tables] [-FXZ] [chain]`

**Options:**

* `-F [chain]`: Flushes all specified rules in the given chain or all chains if none specified.
* `-X [chain]`: Deletes the specified `user-defined chain` or all `user-defined chains` if none specified.
* `-Z [chain]`: Zeroes the packet and byte counters for the specified chain or all chains if none specified.

### 5.5.3 Defining Default Policies

When a packet does not match any of the rules we set, whether the packet is accepted or dropped depends on the Policy setting.

**Pattern:**

* `iptables [-t nat] -P [INPUT,OUTPUT,FORWARD] [ACCEPT,DROP]`

**Options:**

* `-P`: Defines the policy
    * `ACCEPT`: The packet is accepted
    * `DROP`: The packet is dropped immediately, without notifying the client why it was dropped

**Examples:**

* `iptables -P INPUT DROP`
* `iptables -P OUTPUT ACCEPT`
* `iptables -P FORWARD ACCEPT`

### 5.5.4 Basic Packet Matching: IP, Network, and Interface Devices

**Pattern:**

* `iptables [-t tables] [-AI chain] [-io ifname] [-p prop] [-s ip/net] [-d ip/net] -j [ACCEPT|DROP|REJECT|LOG]`

**Options:**

* `-t tables`: Specifies the tables, the default table is `filter`.
* `-AI chain`: Insert or append rules for a specific chain.
    * `-A chain`: Append a new rule at the end of existing rules. For example, if there are 4 rules, `-A` adds a fifth.
    * `-I chain [rule num]`: Insert a rule at a specified position. If no position is specified, it inserts as the first rule.
    * `chain`: Can be a built-in chain (`INPUT`, `OUTPUT`, `FORWARD`, `PREROUTING`, `POSTROUTING`) or a user-defined chain.
* `-io ifname`: Specify input/output network interfaces for packets.
    * `-i`: The incoming network interface for the packet, e.g., eth0, lo; used with the INPUT chain.
    * `-o`: The outgoing network interface for the packet; used with the OUTPUT chain.
* `-p prop`: Specifies the packet protocol the rule applies to.
    * Common protocols include: tcp, udp, icmp, and all.
* `-s ip/net`: Specifies the source IP or network for packets that match this rule.
    * `ip`: e.g., `192.168.0.100`
    * `net`: e.g., `192.168.0.0/24` or `192.168.0.0/255.255.255.0`
    * **To negate, add `!`, e.g., `! -s 192.168.100.0/24`**
* `-d ip/net`: Same as `-s`, but for destination IP or network.
* `-j target`: Specifies the target action.
    * `ACCEPT`
    * `DROP`
    * `QUEUE`
    * `RETURN`
    * **Other Chains**
    * **Matching works like a function call stack: jumping between chains is like function calls. Some targets stop matching (e.g., `ACCEPT`, `DROP`, `SNAT`, `MASQUERADE`), others continue (e.g., jumping to another `Chain`, `LOG`, `ULOG`, `TOS`).**
* **Important principle: If an option is not specified, it means that condition is fully accepted.**
    * For example, if `-s` and `-d` are not specified, it means any source or destination IP/network is accepted.

**Examples:**

* `iptables -A INPUT -i lo -j ACCEPT`: Accept packets from any source or destination as long as they come through the `lo` interface—this is called a trusted device.
* `iptables -A INPUT -i eth1 -j ACCEPT`: Adds the interface `eth1` as a trusted device.
* `iptables -A INPUT -s 192.168.2.200 -j LOG`: Logs packets from this source IP to the kernel log file (e.g., `/var/log/messages`), then continues to match further rules (different from most rules).
* Logging rules (should be placed first, otherwise if other rules match first, these won’t execute):
    * `iptables -I INPUT -p icmp -j LOG --log-prefix "liuye-input: "`
    * `iptables -I FORWARD -p icmp -j LOG --log-prefix "liuye-forward: "`
    * `iptables -I OUTPUT -p icmp -j LOG --log-prefix "liuye-output: "`
    * `iptables -t nat -I PREROUTING -p icmp -j LOG --log-prefix "liuye-prerouting: "`
    * `iptables -t nat -I POSTROUTING -p icmp -j LOG --log-prefix "liuye-postrouting: "`

### 5.5.5 Rules for TCP and UDP: Port-based Rules

TCP and UDP are special because of ports, and for TCP there is also the concept of connection packet states, including the common SYN active connection packet format.

**Pattern:**

* `iptables [-AI chain] [-io network interface] [-p tcp|udp] [-s source IP/network] [--sport source port range] [-d destination IP/network] [--dport destination port range] --syn -j [ACCEPT|DROP|REJECT]`

**Options:**

* `--sport port range`: Restricts the source port number; port ranges can be continuous, e.g., 1024:65535.
* `--dport port range`: Restricts the destination port number.
* `--syn`: Indicates an active connection (SYN flag).
* **Compared to previous commands, these add the `--sport` and `--dport` options, so you must specify `-p tcp` or `-p udp` to use them.**

**Examples:**

* `iptables -A INPUT -i eth0 -p tcp --dport 21 -j DROP`: Blocks all packets trying to enter the machine on port 21.
* `iptables -A INPUT -i eth0 -p tcp --sport 1:1023 --dport 1:1023 --syn -j DROP`: Drops active connections from any source port 1-1023 to destination ports 1-1023.

### 5.5.6 iptables Matching Extensions

`iptables` can use extended packet matching modules. When specifying `-p` or `--protocol`, or using the `-m` or `--match` option followed by the name of the matching module, various additional command line options can be used depending on the specific module. Multiple extended match modules can be specified on a single line, and after specifying a module, you can use `-h` or `--help` to get module-specific help documentation (e.g., `iptables -m comment -h` will show parameters for the `comment` module at the bottom of the output).

**Common Modules**, for detailed information please refer to [Match Extensions](https://linux.die.net/man/8/iptables):

1. `comment`: Adds comments
1. `conntrack`: When used with connection tracking, this module allows access to more connection tracking information than the "state" match. (This module exists only if iptables is compiled with support for this feature in the kernel.)
1. `tcp`
1. `udp`

### 5.5.7 iptables Target Extensions

iptables can use extended target modules, and after specifying a target, you can use `-h` or `--help` to get target-specific help documentation (e.g., `iptables -j DNAT -h`).

**Common targets (can be found by running `man iptables` or `man 8 iptables-extensions` and searching for the keyword `target`):**

1. `ACCEPT`
1. `DROP`
1. `RETURN`
1. `REJECT`
1. `DNAT`
1. `SNAT`
1. `MASQUERADE`: Used to implement automatic SNAT. If the outbound IP changes frequently, this target can be used to achieve SNAT.

### 5.5.8 ICMP Packet Rules Comparison: Designed to Control Ping Responses

**Pattern:**

* `iptables -A INPUT [-p icmp] [--icmp-type 类型] -j ACCEPT`

**Options:**

* `--icmp-type`: Must be followed by the ICMP packet type, which can also be specified by a code.

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

* `-n`: Do not resolve protocol or hostname, use IP or port number directly. By default, `route` tries to resolve the hostname of the IP, which may cause delays if it fails to resolve, so this option is generally added.
* `-ee`: Display more detailed information.
* `-net`: Indicates that the following route is for a network.
* `-host`: Indicates that the following route is for a single host.
* `netmask`: Related to the network, used to set the netmask to determine the size of the network.
* `gw`: Abbreviation for gateway, followed by an IP address.
* `dev`: If you just want to specify which network interface card to use for outgoing connection, use this setting followed by the interface name, e.g., `eth0`.

**Explanation of print parameters:**

* **Destination, Genmask**: These two parameters correspond to the network and netmask respectively.
* **Gateway**: Indicates through which gateway the network is connected. If it shows `0.0.0.0 (default)`, it means the route sends packets directly on the local network via MAC addresses. If an IP is shown, it means the route requires a router (gateway) to forward packets.
* **Flags:**
    * `U (route is up)`: The route is active.
    * `H (target is a host)`: The destination is a single host, not a network.
    * `G (use gateway)`: Requires forwarding packets through an external host (gateway).
    * `R (reinstate route for dynamic routing)`: Flag indicating reinstatement of route during dynamic routing.
    * `D (Dynamically installed by daemon or redirect)`: Dynamically installed route.
    * `M (modified from routing daemon or redirect)`: Route has been modified.
    * `! (reject route)`: This route will not be accepted.
* **Iface**: The interface used to transmit packets for this route.

**Examples:**

* `route -n`
* `route add -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`
* `route del -net 169.254.0.0 netmask 255.255.0.0 dev enp0s8`

## 5.8 nsenter

`nsenter` is used to execute a command within a specific network namespace. For example, some Docker containers do not have the `curl` command, but you may want to run it inside the Docker container's environment. In this case, you can use `nsenter` on the host machine.

**Pattern:**

* `nsenter -t <pid> -n <cmd>`

**Options:**

* `-t`: followed by the process ID  
* `-n`: followed by the command to execute

**Examples:**

* `nsenter -t 123 -n curl baidu.com`

## 5.9 tcpdump

**Options:**

* `-A`: Print each packet (minus its link level header) in ASCII. Handy for capturing web pages.
* `-e`: Print the link-level header on each dump line. This can be used, for example, to print MAC layer addresses for protocols such as Ethernet and IEEE 802.11.
* `-n`: Don't convert addresses (i.e., host addresses, port numbers, etc.) to names.
* `-q`: Quick (quiet?) output. Print less protocol information so output lines are shorter.
* `-i <interface>`: Listen, report the list of link-layer types, report the list of time stamp types, or report the results of compiling a filter expression on interface.
* `-w <file>`: Write the raw packets to file rather than parsing and printing them out.
* `-r <file>`: Read packets from file (which was created with the -w option or by other tools that write pcap or pcapng files). Standard input is used if file is `-`.
* `-c <count>`: Exit after receiving count packets.
* `-vv/-vvv`: Even more verbose output.
* `-t`: Don't print a timestamp on each dump line.
    * `-tt`: Print the timestamp, as seconds since January 1, 1970, 00:00:00, UTC, and fractions of a second since that time, on each dump line.
    * `-ttt`: Print a delta (microsecond or nanosecond resolution depending on the --time-stamp-precision option) between current and previous line on each dump line. The default is microsecond resolution.
    * `-tttt`: Print a timestamp, as hours, minutes, seconds, and fractions of a second since midnight, preceded by the date, on each dump line.
    * `-ttttt`: Print a delta (microsecond or nanosecond resolution depending on the --time-stamp-precision option) between current and first line on each dump line. The default is microsecond resolution.

**Output columns specification:**

* `src > dst: Flags data-seqno ack window urgent options`
* `src`: Source `ip/port` (or domain)
* `dst`: Dest `ip/port` (or domain)
* `Flags`
    * `S`: `SYNC`
    * `F`: `FIN`
    * `P`: `PUSH`
    * `R`: `RST`
    * `U`: `URG`
    * `W`: `ECN CWR`
    * `E`: `ECN-Echo`
    * `.`: `ACK`
    * `none`
* `data-seqno`: The sequence number of the data packet, which can be one or more (`1:4`)
* `ack`: Indicates the sequence number of the next expected data packet
* `window`: The size of the receive buffer
* `urgent`: Indicates whether the current data packet contains urgent data
* `option`: The part enclosed in `[]`

**Examples:**

* `tcpdump -i lo0 port 22 -w output7.cap`
* `tcpdump -i eth0 host www.baidu.com`
* `tcpdump -i any -w output1.cap`
* `tcpdump -n -i any -e icmp and host www.baidu.com`

### 5.9.1 tcpdump Conditional Expressions

This expression is used to determine which packets will be printed. If no condition expression is given, all packets captured on the network will be printed; otherwise, only packets that satisfy the condition expression will be printed.

The expression consists of one or more *primitives* (primitives, which can be understood as the basic elements of an expression). A primitive usually consists of one or more modifiers called `qualifiers` followed by an `id`, which is represented by a name or number (i.e., `qualifiers id`). There are three different types of qualifiers: `type`, `direction`, and `protocol`.

**Primitive Format: `[protocol] [direction] [type] id`**

* **type**: Includes `host`, `net`, `port`, `portrange`. The default value is `host`.
* **direction**: Includes `src`, `dst`, `src and dst`, `src or dst` as the four possible directions. The default value is `src or dst`.
* **protocol**: Includes `ether`, `fddi`, `tr`, `wlan`, `ip`, `ip6`, `arp`, `rarp`, `decnet`, `tcp`, `udp`, etc. By default, all protocols are included.
    * **The `protocol` must match the `type`. For example, when `protocol` is `tcp`, the `type` cannot be `host` or `net`, but should be `port` or `portrange`.**
* **Logical Operations**: A `condition expression` can be composed of multiple `primitives` combined using `logical operations`. The logical operations include `!` or `not`, `&&` or `and`, and `||` or `or`.

**Examples:**

* `tcp src port 123`
* `tcp src portrange 100-200`
* `host www.baidu.com and port 443`

### 5.9.2 tips

How to view a specific protocol, for example, the SSH protocol

Use Wireshark

1. Select any packet with a `length` not equal to `0`, right-click and choose "Decode As", then in the right-side `Current` column, select the corresponding protocol.

### 5.9.3 How to Use tcpdump to Capture HTTP Protocol Data from docker

Docker uses a Unix domain socket, corresponding to the socket file `/var/run/docker.sock`. Since domain sockets do not go through the network interface, `tcpdump` cannot directly capture the related data.

**Method 1: Change the client's access method**

```sh
# In terminal 1, listen on local port 18080 and forward the traffic to Docker's domain socket  
# The two `-d` options output fatal, error, and notice level information  
socat -d -d TCP-LISTEN:18080,fork,bind=127.0.0.1 UNIX:/var/run/docker.sock

# In terminal 2, run tcpdump to capture packets  
tcpdump -i lo -netvv port 18080 -w file1.cap

# In terminal 3, run the Docker command  
docker -H tcp://localhost:18080 images
```

**Method 2: Do not change the client's access method**

```sh
# In terminal 1, run the `mv` command to rename the original domain socket file. This operation does not change the file descriptor, so after moving, Docker listens on the socket `/var/run/docker.sock.original`  
sudo mv /var/run/docker.sock /var/run/docker.sock.original
sudo socat TCP-LISTEN:18081,reuseaddr,fork UNIX-CONNECT:/var/run/docker.sock.original

# In terminal 2, run  
sudo socat UNIX-LISTEN:/var/run/docker.sock,fork TCP-CONNECT:127.0.0.1:18081

# In terminal 3, run tcpdump to capture packets  
tcpdump -i lo -vv port 18081 -w file2.cap

# In terminal 3, run the Docker command  
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

`tcpkill` is used to kill TCP connections, and its syntax is basically similar to `tcpdump`. Its working principle is quite simple: it first listens to the relevant packets, obtains the `sequence number`, and then sends a `Reset` packet. Therefore, `tcpkill` only works when there is packet exchange in the connection.

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install dsniff
yum install -y dsniff
```

**Pattern:**

* `tcpkill [-i interface] [-1...9] expression`

**Options:**

* `-i`: specify the network interface  
* `-1...9`: priority level; the higher the priority, the easier it is to kill the connection  
* `expression`: filter expression, similar to tcpdump  

**Examples:**

* `tcpkill -9 -i any host 127.0.0.1 and port 22`

## 5.12 socat

**Pattern:**

* `socat [options] <address> <address>`  
* The two `address` arguments are the key. An `address` is similar to a file descriptor. Socat works by creating a `pipe` between the two specified `address` descriptors for sending and receiving data.

**Options:**

* `address`: can be one of the following forms  
    * `-`: represents standard input/output  
    * `/var/log/syslog`: can be any file path; if relative, use `./` to open a file as a data stream  
    * `TCP:127.0.0.1:1080`: establish a TCP connection as a data stream (TCP can be replaced by UDP)  
    * `TCP-LISTEN:12345`: create a TCP listening port (TCP can be replaced by UDP)  
    * `EXEC:/bin/bash`: execute a program as a data stream  

**Examples:**

* `socat - /var/www/html/flag.php`: read a file via Socat, absolute path  
* `socat - ./flag.php`: read a file via Socat, relative path  
* `echo "This is Test" | socat - /tmp/hello.html`: write to a file  
* `socat TCP-LISTEN:80,fork TCP:www.baidu.com:80`: forward local port to remote  
* `socat TCP-LISTEN:12345 EXEC:/bin/bash`: open a shell proxy locally  

## 5.13 dhclient

**Pattern:**

* `dhclient [-dqr]`

**Options:**

* `-d`: always run the program in the foreground  
* `-q`: quiet mode, do not print any error messages  
* `-r`: release the IP address  

**Examples:**

* `dhclient`: obtain an IP address  
* `dhclient -r`: release the IP address  

## 5.14 arp

**Examples:**

* `arp`: view the ARP cache  
* `arp -n`: view the ARP cache, display IP addresses without domain names  
* `arp 192.168.56.1`: view the MAC address of the IP `192.168.56.1`  

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

* `-c`: followed by the number of packets to send  
* `-s`: specify the size of the data  
* `-M [do|want|dont]`: set the MTU strategy, where  
  * `do` means do not allow fragmentation;  
  * `want` means allow fragmentation when the packet is large;  
  * `dont` means do not set the `DF` (Don't Fragment) flag  

**Examples:**

* `ping -c 3 www.baidu.com`  
* `ping -s 1460 -M do baidu.com`: send packets with a size of 1460 (+28) bytes and forbid fragmentation  

## 5.17 arping

**Pattern:**

* `arping [-fqbDUAV] [-c count] [-w timeout] [-I device] [-s source] destination`

**Options:**

* `-c`: specify the number of packets to send  
* `-b`: continuously send requests using broadcast  
* `-w`: specify the timeout duration  
* `-I`: specify which Ethernet device to use  
* `-D`: enable address conflict detection mode  

**Examples:**

* `arping -c 1 -w 1 -I eth0 -b -D 192.168.1.1`: this command can be used to detect if there is an IP conflict in the local network  
  * If this command returns 0: it means no conflict exists; otherwise, a conflict exists  

**Why can the `-D` option detect IP conflicts**

* Environment description:  
  * Machine A, IP: `192.168.2.2/24`, MAC address: `68:ed:a4:39:92:4b`  
  * Machine B, IP: `192.168.2.2/24`, MAC address: `68:ed:a4:39:91:e6`  
  * Router, IP: `192.168.2.1/24`, MAC address: `c8:94:bb:af:bd:8c`  
* When running `arping -c 1 -w 1 -I eno1 -b 192.168.2.2` on Machine A, and capturing packets on both Machine A and Machine B, the capture results are as follows:  
  * ![arping-1](/images/Linux-Frequently-Used-Commands/arping-1.png)  
  * ![arping-2](/images/Linux-Frequently-Used-Commands/arping-2.png)  
  * After the ARP reply is sent to the router, the router does not know which device to forward the packet to, so it simply discards it  
* When running `arping -c 1 -w 1 -I eno1 -D -b 192.168.2.2` on Machine A, and capturing packets on both Machine A and Machine B, the capture results are as follows:  
  * ![arping-3](/images/Linux-Frequently-Used-Commands/arping-3.png)  
  * ![arping-4](/images/Linux-Frequently-Used-Commands/arping-4.png)  
  * The ARP reply directly specifies the target machine's MAC address, so it is delivered directly to Machine A  

## 5.18 hping3

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install hping3
yum install -y hping3
```

**Options:**

* `-c`: Number of packets to send and receive (if only sending packets without receiving, it will not stop)
* `-d`: Specify packet size (excluding header)
* `-S`: Send only SYN packets
* `-w`: Set TCP window size
* `-p`: Destination port
* `--flood`: Flood mode, sending packets as fast as possible
* `--rand-source`: Use random IP as source IP

**Examples:**

* `hping3 -c 10000 -d 120 -S -w 64 -p 21 --flood --rand-source www.baidu.com`

## 5.19 iperf

**Network testing tool, generally used for LAN testing. Internet speed test: [speedtest](https://github.com/sivel/speedtest-cli)**

**Examples:**

* IPv4
    * `iperf -s -p 3389 -i 1`: Server
    * `iperf -c <server_addr> -p 3389 -i 1`: Client
* IPv6
    * `iperf3 -s -6 -p 3389 -i 1`: Server
    * `iperf3 -c <server_addr> -p 3389 -6 -i 1`: Client

## 5.20 nc

**Examples:**

* `nc -zv 127.0.0.1 22`: Test connectivity.

# 6 Monitoring

## 6.1 ssh

**Pattern:**

* `ssh [-f] [-o options] [-p port] [account@]host [command]`

**Options:**

* `-f`: Used with the following [command], it sends a command to the remote host without logging in
* `-o`: Followed by `options`
    * `ConnectTimeout=<seconds>`: Number of seconds to wait for a connection, reduces wait time
    * `StrictHostKeyChecking=[yes|no|ask]`: Default is ask; to automatically add a public key to known_hosts, set it to no
* `-p`: Followed by a port number; if the sshd service runs on a non-standard port, this option is needed

**Examples:**

* `ssh 127.0.0.1`: Since no username is provided, the current user's account is used to log in to the remote server
* `ssh student@127.0.0.1`: The account is for the host at this IP, not a local account
* `ssh student@127.0.0.1 find / &> ~/find1.log`
* `ssh -f student@127.0.0.1 find / &> ~/find1.log`: Logs out of 127.0.0.1 immediately; `find` runs on the remote server
* `ssh demo@1.2.3.4 '/bin/bash -l -c "xxx.sh"'`: Logs into the remote using a `login shell` and executes the script; the `-l` argument to `bash` specifies login shell mode
    * It's best to wrap the whole command in quotes, otherwise arguments in complex commands may fail to parse, for example:
        ```sh
        # The -al argument will be lost
        ssh -o StrictHostKeyChecking=no test@1.2.3.4 /bin/bash -l -c 'ls -al'
        # The -al argument is passed correctly
        ssh -o StrictHostKeyChecking=no test@1.2.3.4 "/bin/bash -l -c 'ls -al'"
        # When using eval, quotes are also needed, and must be escaped
        eval "ssh -o StrictHostKeyChecking=no test@1.2.3.4 \"/bin/bash -l -c 'ls -al'\""
        ```

### 6.1.1 Passwordless Login

**Method 1 (Manual):**

```sh
# Create an RSA key pair (if one doesn't already exist)
ssh-keygen -t rsa

# Copy the local public key ~/.ssh/id_rsa.pub to the target user's ~/.ssh/authorized_keys on the target machine
ssh user@target 'mkdir ~/.ssh; chmod 700 ~/.ssh'
cat ~/.ssh/id_rsa.pub | ssh user@target 'cat >> ~/.ssh/authorized_keys; chmod 644 ~/.ssh/authorized_keys'
```

**Method 2 (Automatic, `ssh-copy-id`)**

```sh
# Create an RSA key pair (if one doesn't already exist)
ssh-keygen -t rsa

# Copy the local public key ~/.ssh/id_rsa.pub to the target user's ~/.ssh/authorized_keys on the target machine
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
    * `local` communicates with `middle_host`
    * `middle_host` communicates with `remote_host` (of course, `remote_host` can be the same as `middle_host`)
    * **Path: `frontend --tcp--> local_host:local_port --tcp over ssh--> middle_host:22 --tcp--> remote_host:remote_port`**

**Options:**

* `-f`: Run in the background
* `-N`: Do not execute remote commands

**Examples:**

* `ssh -L 5901:127.0.0.1:5901 -N -f user@remote_host`: Listens only on `127.0.0.1`
* `ssh -L "*:5901:127.0.0.1:5901" -N -f user@remote_host`: Listens on all IPs
    * Same as `ssh -g -L 5901:127.0.0.1:5901 -N -f user@remote_host`

### 6.1.5 WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED

When the RSA fingerprint of the remote machine changes, the above error message will appear when trying to ssh again. There are two ways to fix this:

1. Delete the entry related to the specified `hostname or IP` from `.ssh/known_hosts`
2. Use `ssh-keygen` to remove the entry related to the specified `hostname or IP` from `.ssh/known_hosts`
    ```sh
    # If the -f option is not used, it will modify the .ssh/known_hosts file for the current user by default
    ssh-keygen -f "/Users/hechenfeng/.ssh/known_hosts" -R "<hostname or IP>"
    ```

### 6.1.6 Specify Password

```sh
sshpass -p 'xxxxx' ssh -o StrictHostKeyChecking=no test@1.2.3.4
```

## 6.2 scp

**Pattern:**

* `scp [-pPr] [-l <rate>] local_file [account@]host:dir`
* `scp [-pPr] [-l <rate>] [account@]host:file local_dir`

**Options:**

* `-p`: Preserve the source file's permission information  
* `-P`: Specify the port number  
* `-r`: When the source is a directory, recursively copy the entire directory (including subdirectories)  
* `-l`: Limit the transfer rate, unit is Kbits/s  

**Examples:**

* `scp /etc/hosts* student@127.0.0.1:~`
* `scp /tmp/Ubuntu.txt root@192.168.136.130:~/Desktop`
* `scp -P 16666 root@192.168.136.130:/tmp/test.log ~/Desktop`: Specify port number 16666 for host `192.168.136.130`  
* `scp -r local_folder remote_username@remote_ip:remote_folder `

## 6.3 watch

**Pattern:**

* `watch [option] [cmd]`

**Options:**

* `-n`: When `watch` is used without this parameter, it runs the program every 2 seconds by default. Use `-n` or `--interval` to specify a different interval time
* `-d`: `watch` will highlight areas that have changed. The `-d=cumulative` option highlights all areas that have changed at any time (regardless of whether they changed in the most recent update)
* `-t`: Disable the header showing interval and current time at the top of the `watch` output

**Examples:**

* `watch -n 1 -d netstat -ant`: Every second, highlight changes in network connection counts
* `watch -n 1 -d 'pstree | grep http'`: Every second, highlight changes in the number of HTTP connections
* `watch 'netstat -an | grep :21 | grep <ip> | wc -l'`: Monitor in real-time the number of connections established by a simulated attack client
* `watch -d 'ls -l | grep scf'`: Monitor changes in files containing `scf` in the current directory
* `watch -n 10 'cat /proc/loadavg'`: Output the system's load average every 10 seconds

## 6.4 top

**Pattern:**

* `top [-H] [-p <pid>]`

**Options:**

* `-H`: Show threads  
* `-p`: View a specified process  
* `-b`: Non-interactive mode, typically used with `-n` to specify the number of iterations  

**Examples:**

* `top -p 123`: View the process with PID 123  
* `top -Hp 123`: View the process with PID 123 and all its threads  
* `top -b -n 3`: Run in batch mode and update 3 times  

**Output Description:**

* **First line:**
    * Current time  
    * Uptime  
    * Number of logged-in users  
    * System load averages over 1, 5, and 15 minutes  
* **Second line**: Total number of processes and counts in various states  
* **Third line**: CPU usage; note that `wa` (I/O wait) is important—high `wa` often indicates I/O bottlenecks  
* **Fourth and fifth lines**: Physical and virtual memory usage; the less swap used, the better—high swap usage means insufficient physical memory  
* **Sixth line**: The command input area in `top` interactive mode  
* **Seventh line and onward**: Per-process resource usage  
    * `PID`: Process ID  
    * `USER`: User who owns the process  
    * `PR`: Priority (lower is higher priority)  
    * `NI`: Nice value (affects priority; lower is higher priority)  
    * `%CPU`: CPU usage  
    * `%MEM`: Memory usage  
    * `TIME+`: Cumulative CPU time used  
    * `COMMAND`: Command name  
* **By default, top sorts by CPU usage. Press `h` for help.**
* **Sorting keys:**
    * `P`: Sort by CPU usage (default descending, press `R` to reverse)  
    * `M`: Sort by memory usage  
    * `T`: Sort by time used  
* **Other interactive commands:**
    * `1`: Show each CPU core’s usage separately  
    * `2`: Show only average CPU usage  
    * `x`: Highlight the sorted column  
    * `-R`: Reverse sort order  
    * `n [num]`: Show only the top `num` entries (`0` means no limit)  
    * `l`: Toggle display of CPU load info  
    * `t`: Toggle task and CPU details  
    * `m`: Toggle memory details  
    * `c`: Show full command line  
    * `V`: Show commands in a tree format  
    * `H`: Show threads  
    * `W`: Save current interactive settings to `~/.toprc`, enabling consistent output when using non-interactive mode like `top -b -n 1`  
* **Memory-related fields:**
    * `VIRT` (virtual memory size): Total virtual memory used by the process, including code, data, shared libs, swapped pages, and mapped-but-unused pages  
        * `VIRT = SWAP + RES`
    * `SWAP`: Amount of virtual memory swapped out  
    * `RES`: Non-swapped physical memory  
        * `RES = CODE + DATA`
    * `CODE` (TRS): Physical memory used by the process code  
    * `DATA` (DRS): Physical memory used by non-code (data and stack)  
    * `SHR`: Shared memory used  

## 6.5 htop

**`htop` provides very detailed interaction options on its interface**

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install htop
yum install -y htop
```

**Examples:**

* `htop`

## 6.6 slabtop

`slabtop` is used to display information related to the kernel's `slab cache`

**Examples:**

* `slabtop`

## 6.7 sar

`sar` has a log rotation-like feature. It uses scheduled tasks defined in `/etc/cron.d/sysstat` to store logs under `/var/log/sa/`.

**Install:**

```sh
yum install -y sysstat
```

**Pattern:**

* `sar [ options ] [ <interval> [ <count> ] ]`

**Options:**

* `-u`: View CPU usage  
* `-q`: View CPU load  
* `-r`: View memory usage  
* `-b`: View I/O and transfer rate information  
* `-d`: View I/O status for each disk  
* `-B`: View paging activity  
* `-f <filename>`: Specify sa log file  
* `-P <cpu num>|ALL`: View stats for a specific CPU, `ALL` means all CPUs  
* `-n [keyword]`: View network-related info; keywords can be:  
    * `DEV`: Network interfaces  
    * `EDEV`: Network interface errors  
    * `SOCK`: Sockets  
    * `IP`: IP traffic  
    * `TCP`: TCP traffic  
    * `UDP`: UDP traffic  
* `-h`: Output in human-readable format  

**Examples:**

* `sar -u ALL 1`: Output CPU info aggregated for all cores every second  
* `sar -P ALL 1`: Output CPU info per core every second  
* `sar -r ALL -h 1`: Output memory info every second in human-readable form  
* `sar -B 1`: Output paging info every second  
* `sar -n TCP,UDP -h 1`: View TCP/UDP summary every second  
* `sar -n DEV -h 1`: View real-time network interface traffic every second  
* `sar -b 1`: View summary I/O info every second  
* `sar -d -h 1`: View per-disk I/O info every second  

## 6.8 tsar

**Pattern:**

* `tsar [-l]`

**Options:**

* `-l`: View real-time data

**Examples:**

* `tsar -l`

## 6.9 vmstat

**Pattern:**

* `vmstat [options] [delay [count]]`

**Options:**

* `-a, --active`: Show active and inactive memory  
* `-f, --forks`: Number of forks since system start (in Linux, process creation uses the fork syscall)  
    * Info is retrieved from the `processes` field in `/proc/stat`  
* `-m, --slabs`: View system slab info  
* `-s, --stats`: View detailed memory usage info  
* `-d, --disk`: View detailed disk usage info  
* `-D, --disk-sum`: Summarize disk statistics  
* `-p, --partition <dev>`: View detailed info of specified partition  
* `-S, --unit <char>`: Specify output unit, supports only `k/K` and `m/M`, default is `K`  
* `-w, --wide`: Output more detailed info  
* `-t, --timestamp`: Output timestamps  
* `delay`: Sampling interval  
* `count`: Sampling count  

**Output Details:**

* `process`  
    * `r`: Number of running processes (in `running` or `waiting` state)  
    * `b`: Number of blocked processes  
* `memory`  
    * `swpd`: Total virtual memory  
    * `free`: Total free memory  
    * `buff`: Total memory used as Buffer  
    * `cache`: Total memory used as Cache  
    * `inact`: Total inactive memory (requires `-a` option)  
    * `active`: Total active memory (requires `-a` option)  
* `swap`  
    * `si`: Amount of memory swapped in from disk per second  
    * `so`: Amount of memory swapped out to disk per second  
* `io`  
    * `bi`: Blocks received from block device per second  
    * `bo`: Blocks sent to block device per second  
* `system`  
    * `in`: Number of interrupts per second, including clock interrupts  
    * `cs`: Number of context switches per second  
* `cpu`  
    * `us`: User CPU time  
    * `sy`: System (kernel) CPU time  
    * `id`: Idle CPU time  
    * `wa`: CPU time waiting for IO  
    * `st`: Time stolen from a virtual machine  

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

* `-c`: Mutually exclusive with `-d`, shows only CPU-related information  
* `-d`: Mutually exclusive with `-c`, shows only disk-related information  
* `-k`: Display I/O rate in kB (default is `Blk`, the filesystem block)  
* `-m`: Display I/O rate in MB (default is `Blk`, the filesystem block)  
* `-t`: Print date information  
* `-x`: Print extended information  
* `-z`: Omit devices with no events during sampling  
* `interval`: Print interval  
* `count`: Number of times to print; if omitted, print continuously  

**Output Details:(`man iostat`)**

* `cpu`: Search for `CPU Utilization Report` in man page
* `device`: Search for `Device Utilization Report` in man page

**Examples:**

* `iostat -dtx 1`
* `iostat -dtx 1 sda`
* `iostat -tx 3`

## 6.12 dstat

`dstat` is a versatile tool for generating system resource statistics.

**Pattern:**

* `dstat [options]`

**Options:**

* `-c, --cpu`: `CPU` statistics
    * `usr` (`user`)
    * `sys` (`system`)
    * `idl` (`idle`)
    * `wai` (`wait`)
    * `hiq` (`hardware interrupt`)
    * `siq` (`software interrupt`)
* `-d, --disk`: Disk statistics
    * `read`
    * `writ` (`write`)
* `-i, --int`: Interrupt statistics
* `-l, --load`: `CPU` load statistics
    * `1 min`
    * `5 mins`
    * `15mins`
* `-m, --mem`: Memory statistics
    * `used`
    * `buff` (`buffers`)
    * `cach` (`cache`)
    * `free`
* `-n, --net`: Network statistics
    * `recv` (`receive`)
    * `send`
* `-p, --proc`: Process statistics
    * `run` (`runnable`)
    * `blk` (`uninterruptible`)
    * `new`
* `-r, --io`: I/O statistics
    * `read` (`read requests`)
    * `writ` (`write requests`)
* `-s, --swap`: Swap statistics
    * `used`
    * `free`
* `-t, --time`: Time information
* `-v, --vmstat`: Equivalent to `dstat -pmgdsc -D total`, similar to `vmstat` output
* `--vm`: Virtual memory related information
    * `majpf` (`hard pagefaults`)
    * `minpf` (`soft pagefaults`)
    * `alloc`
    * `free`
* `-y, --sys`: System statistics
    * `int` (`interrupts`)
    * `csw` (`context switches`)
* `--fs, --filesystem`: Filesystem statistics
    * `files` (`open files`)
    * `inodes`
* `--ipc`: IPC statistics
    * `msg` (`message queue`)
    * `sem` (`semaphores`)
    * `shm` (`shared memory`)
* `--lock`: File lock statistics
    * `pos` (`posix`)
    * `lck` (`flock`)
    * `rea` (`read`)
    * `wri` (`write`)
* `--socket`: Socket statistics
    * `tot` (`total`)
    * `tcp`
    * `udp`
    * `raw`
    * `frg` (`ip-fragments`)
* `--tcp`: TCP statistics, including
    * `lis` (`listen`)
    * `act` (`established`)
    * `syn`
    * `tim` (`time_wait`)
    * `clo` (`close`)
* `--udp`: UDP statistics, including
    * `lis` (`listen`)
    * `act` (`active`)
* **`-f, --full`**: Show details, for example `CPU` shown per CPU, network shown per network card
* **`--top-cpu`**: Show processes consuming the most `CPU` resources
* **`--top-cpu-adv`**: Show processes consuming the most `CPU` resources, with additional process information (`advanced`)
* **`--top-io`**: Show processes consuming the most `IO` resources
* **`--top-io-adv`**: Show processes consuming the most `IO` resources, with additional process information (`advanced`)
* **`--top-mem`**: Show processes consuming the most memory resources

**Examples:**

* `dstat 5 10`: Refresh every 5 seconds, 10 times
* `dstat -tvln`
* `dstat -tc`
* `dstat -tc -C total,1,2,3,4,5,6`
* `dstat -td`
* `dstat -td -D total,sda,sdb`
* `dstat -td --disk-util`
* `dstat -tn`
* `dstat -tn -N total,eth0,eth2`

## 6.13 ifstat

This command is used to view the network interface card's traffic status, including successfully received/sent packets as well as error received/sent packets. What you see is basically similar to `ifconfig`.

## 6.14 pidstat

`pidstat` is a command from the `sysstat` toolset, used to monitor system resource usage of all or specified processes, including `CPU`, memory, threads, device I/O, and more. When run for the first time, `pidstat` displays statistics since the system startup; subsequent runs show statistics since the last time the command was executed. Users can specify the number of samples and the interval to obtain the desired statistics.

**Pattern:**

* `dstat [options] [ interval [ count ] ]`

**Options:**

* `-d`: Display `I/O` usage
    * `kB_rd/s`: Disk read rate in `KB`
    * `kB_wr/s`: Disk write rate in `KB`
    * `kB_ccwr/s`: Write rate in `KB` that was supposed to be done but canceled. This may be triggered when tasks discard `dirty pagecache` due to canceling
* `-r`: Display memory usage
    * `minflt/s`: `minor faults per second`
    * `majflt/s`: `major faults per second`
* `-s`: Display stack usage
    * `StkSize`: Stack size reserved by the system for the task, in `KB`
    * `StkRef`: Current actual stack usage by the task, in `KB`
* `-u`: Display `CPU` usage (default)
    * `-I`: In `SMP, Symmetric Multi-Processing` environments, the `CPU` usage needs to consider the number of processors for the `%CPU` metric to be accurate
    * The `%usr`, `%system`, `%guest` metrics will not exceed 100% whether or not `-I` is used, see [pidstat do not report %usr %system correctly in SMP environment](https://github.com/sysstat/sysstat/issues/344)
* `-w`: Display context switches explicitly (does not include threads, usually used with `-t`)
* `-t`: Display all threads explicitly
* `-p <pid>`: Specify process

**Examples:**

* `pidstat -d -p <pid> 5`
* `pidstat -r -p <pid> 5`
* `pidstat -s -p <pid> 5`
* `pidstat -uI -p <pid> 5`
* `pidstat -ut -p <pid> 5`
* `pidstat -wt -p <pid> 5`

## 6.15 nethogs

nethogs lists each process with the network interface and bandwidth it occupies, shown on a per-process basis.

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install nethogs
yum install -y nethogs
```

**Examples:**

* `nethogs`

## 6.16 iptraf

## 6.17 iftop

iftop lists the incoming and outgoing traffic for each connection, shown on a per-connection basis.

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install iftop
yum install -y iftop
```

**Examples:**

* `iftop`

## 6.18 iotop

**Install:**

```sh
# Install yum repo
yum install -y epel-release

# Install iotop
yum install -y iotop
```

**Options:**

* `-o`: Only display processes or threads currently performing I/O operations
* `-u`: Followed by a username
* `-P`: Display processes only, not threads
* `-b`: Batch mode, i.e., non-interactive mode
* `-n`: Followed by the number of iterations

**Examples:**

* `iotop`
* `iotop -oP`
* `iotop -oP -b -n 10`
* `iotop -u admin`

## 6.19 blktrace

[Introduction to the IO tool blktrace](https://developer.aliyun.com/article/698568)

**The handling process of an I/O request can be summarized with this simple diagram:**

![blktrace_1](/images/Linux-Frequently-Used-Commands/blktrace_1.png)

**`blktrace` is used to collect `I/O` data. The collected data generally cannot be analyzed directly and usually needs to be processed with some analysis tools, including:**

1. `blkparse`
1. `btt`
1. `blkiomon`
1. `iowatcher`

**Before using `blktrace`, it is necessary to mount `debugfs`:**

```sh
mount      –t debugfs    debugfs /sys/kernel/debug
```

**`blkparse` output parameter explanation:**

* `8,0    0    21311     3.618501874  5099  Q WFSM 101872094 + 2 [kworker/0:2]`
* First parameter: `8,0`, represents the device number `major device ID` and `minor device ID`
* Second field: `0`, represents the `CPU`
* Third field: `21311`, represents the sequence number
* Fourth field: `3.618501874`, represents the time offset
* Fifth field: `5099`, represents the `pid` of this `I/O` operation
* **Sixth field: `Q`, represents the `I/O Event`. This field is very important as it reflects the current stage of the `I/O` operation:**
    ```
    Q – I/O request about to be generated
    |
    G – I/O request generated
    |
    I – I/O request entered IO Scheduler queue
    |
    D – I/O request entered driver
    |
    C – I/O request completed
    ```

* Seventh field: `WFSM`
* Eighth field: `101872094 + 2`, represents the starting `block number` and `number of blocks`, i.e., the commonly referred `Offset` and `Size`
* Ninth field: `[kworker/0:2]`, represents the process name

**Examples:**

1. Collect first, then analyze
    ```sh
    # This command generates a cluster of sda.blktrace.<cpu> files in the current directory
    # Press Ctrl + C to stop collection
    blktrace -d /dev/sda

    # Analyze the sda.blktrace.<cpu> file cluster and output the analysis results
    blkparse sda
    ```

1. Collect and analyze simultaneously
    ```sh
    # The standard output of blktrace is piped directly to the standard input of blkparse
    # Press Ctrl + C to stop collection
    blktrace -d /dev/sda -o - | blkparse -i -
    ```

1. Analyze using `btt`
    ```sh
    blktrace -d /dev/sda

    # This command merges the sda.blktrace.<cpu> file cluster into a single file sda.blktrace.bin
    blkparse -i sda -d sda.blktrace.bin

    # This command analyzes sda.blktrace.bin and outputs the analysis results
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

**The principle of `perf` is as follows: every fixed interval, an interrupt is generated on the `CPU` (on each core). During the interrupt, it checks the current `pid` and function, then adds a count to the corresponding `pid` and function. In this way, we know what percentage of `CPU` time is spent on a certain `pid` or function.**

**Common Subcommands:**

* `archive`: Since parsing `perf.data` requires additional information, such as symbol tables, `pid`, and process relationships, this command packages all relevant files together, enabling analysis on other machines.
* `diff`: Displays the differences between two `perf.data` files.
* `evlist`: Lists the events contained in `perf.data`.
* `list`: Shows all supported events.
* `record`: Starts analysis and writes records to `perf.data`.
    * `perf record` generates a `perf.data` file in the current directory (if this file already exists, the old file is renamed to `perf.data.old`).
    * `perf record` is not necessarily used to track processes it starts itself. By specifying `pid`, it can directly track a fixed group of processes. Also, as you may have noticed, the tracking given above only monitors events occurring in a specific pid. However, in many scenarios, like a `WebServer`, you may be concerned with the entire system's performance, as the network might take up part of the `CPU`, the `WebServer` itself uses some `CPU`, and the storage subsystem also occupies part of the `CPU`. The network and storage don't necessarily belong to your WebServer's `pid`. **Therefore, for full-system tuning, we often add the `-a` parameter to the `perf record` command, allowing us to track the performance of the entire system.**
* `report`: Reads and displays `perf.data`.
* `stat`: Only shows some statistical information.
* `top`: Analyzes in an interactive mode.
    * `?`: help doc
* `lock`: Used for analyzing and profiling lock contention in multi-threaded applications or the kernel.

**Key Parameters:**

* `-e`: Specifies the event to track
    * `perf top -e branch-misses,cycles`
    * `perf top -e branch-misses:u,cycles`: The event can have a suffix, tracking only branch prediction failures occurring in user mode.
    * `perf top -e '{branch-misses,cycles}:u'`: All events focus only on the user mode portion.
    * `perf stat -e "syscalls:sys_enter_*" ls`: All system calls.
* `-s`: Specifies the parameter to categorize by
    * `perf top -e 'cycles' -s comm,pid,dso`
* `-p`: Specifies the `pid` to track

**Frequently Used Events:**

* `cycles/cpu-cycles & instructions`
* `branch-instructions & branch-misses`
* `cache-references & cache-misses`
    * `cache-misses` indicates the number of times access to main memory is required due to a miss in all cache levels. Cases like `L1-miss, L2-hit` are not included.
    * [What are perf cache events meaning?](https://stackoverflow.com/questions/12601474/what-are-perf-cache-events-meaning)
    * [How does Linux perf calculate the cache-references and cache-misses events](https://stackoverflow.com/questions/55035313/how-does-linux-perf-calculate-the-cache-references-and-cache-misses-events)
* `LLC, last level cache`:
    * `LLC-loads & LLC-load-misses`
    * `LLC-stores & LLC-store-misses`
* `L1`:
    * `L1-dcache-loads & L1-dcache-load-misses`
    * `L1-dcache-stores`
    * `L1-icache-load-misses`
    * `mem_load_retired.l1_hit & mem_load_retired.l1_miss`
* `L2`:
    * `mem_load_retired.l2_hit & mem_load_retired.l2_miss`
* `L3`:
    * `mem_load_retired.l3_hit & mem_load_retired.l3_miss`
* `context-switches & sched:sched_switch`
* `page-faults & major-faults & minor-faults`
* `block`
    * `block:block_rq_issue`: This event is triggered by issuing a `device I/O request`. `rq` is short for `request`.
* `kmem`
    * `kmem:kmalloc`
    * `kmem:kfree`

**Examples:**

1. `perf list`: View all supported events.
1. `perf stat -e L1-dcache-load-misses,L1-dcache-loads -- cat /etc/passwd`: Calculate cache miss rate.
1. `timeout 10 perf record -e 'cycles' -a`: Record statistics for the entire system for 10 seconds.
1. `perf record -e 'cycles' -p xxx`: Record statistics for a specified process.
1. `perf record -e 'cycles' -- myapplication arg1 arg2`: Start an application and record statistics.
1. `perf report`: View the analysis report.
1. `perf lock record -p <pid>; perf lock report`
1. **`perf top -p <pid> -g`: Interactively analyze the performance of a program (a powerful tool)**
    * `-g` shows the percentage of a function itself and its children. Each item can be expanded to show the parent stack, child stack, or both, depending on the specific case.
    * Selecting an entry and choosing `Annotate xxx` allows viewing the corresponding assembly code.
1. **`perf stat -p <pid> -e branch-instructions,branch-misses,cache-misses,cache-references,cpu-cycles,ref-cycles,instructions,mem_load_retired.l1_hit,mem_load_retired.l1_miss,mem_load_retired.l2_hit,mem_load_retired.l2_miss,cpu-migrations,context-switches,page-faults,major-faults,minor-faults`**
    * This command outputs a percentage on the right side, representing the ratio of the time `perf` spends on the specified `event` compared to the total time `perf` records.
1. **`perf stat -p <pid> -e "syscalls:sys_enter_*"`: Focus on system calls.**

# 8 Remote Desktop

**`X Window System, X11, X` is a graphical display system. It consists of two components: `X Server`**

* **`X Server`: Must run on a host with graphical display capabilities. It manages the display-related hardware settings on the host (such as graphics card, hard drive, mouse, etc.). It is responsible for drawing and displaying the screen content, and notifying the `X Client` of input actions (such as keyboard and mouse).**
    * Implementations of `X Server` include:
        * `XFree86`
        * `Xorg`: A derivative of `XFree86`. This is the `X Server` running on most Linux systems.
        * `Accelerated X`: Developed by the `Accelerated X Product`, with improvements in accelerated graphical display.
        * `X Server suSE`: Developed by the `SuSE Team`.
        * `Xquartz`: The `X Server` running on `MacOS` systems.
* **`X Client`: The core part of applications, hardware-independent. Each application is an `X Client`. An `X Client` can be a terminal emulator (`Xterm`) or a graphical interface program. It does not directly draw or manipulate graphics on the display but communicates with the `X Server`, which controls the display.**
* **`X Server` and `X Client` can be on the same machine or different machines. They communicate via `xlib`.**

![X-Window-System](/images/Linux-Frequently-Used-Commands/X-Window-System.awebp)

## 8.1 xquartz (Not Recommended)

**Working principle:** A pure `X Window System` solution, where `xquartz` is one implementation of the `X Server`.

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

box "Host with display-related hardware"
participant X_Quartz as "X Quartz"
end box

box "Remote Linux Host"
participant X_Client as "X client"
end box

X_Quartz -> X_Client: ssh -Y user@target
X_Client -> X_Client: Run graphical program, e.g., xclock
X_Client -> X_Quartz: X request
X_Quartz -> X_Client: X reply
```

**How to use:**

* Install `Xquartz` on the local computer (taking `Mac` as an example)
* Install `xauth` on the remote Linux host and enable `X11 Forwarding` in `sshd`
    * `yum install -y xauth`
    * Set `X11Forwarding yes` in `/etc/ssh/sshd_config`
* Use `ssh` with `X11 Forwarding` from the local computer to connect to the remote Linux host
    * `ssh -Y user@target`
* In the remote ssh session, run the `X Client` program, e.g., `xclock`

**Disadvantages:** Consumes a large amount of bandwidth, and only one `X Client` program can run per `ssh` session.

## 8.2 VNC (Recommended)

**`Virtual Network Computing, VNC`. It mainly consists of two parts: `VNC Server` and `VNC Viewer`.**

* **`VNC Server`: Runs `Xvnc` (an implementation of `X Server`), but `Xvnc` does not directly control display-related hardware. Instead, it communicates with the `VNC Viewer` via the `VNC Protocol` and controls the display-related hardware on the host where the `VNC Viewer` is running. A host can run multiple `Xvnc` instances, each listening locally on a port (`590x`).**
* **`VNC Client`: Connects to the port exposed by the `VNC Server` to obtain the graphical output information (including transmitting I/O device signals).**

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

box "Host with display-related hardware"
participant VNC_Viewer as "VNC Viewer"
end box

box "Remote Linux Host"
participant X_VNC as "Xvnc"
participant X_Client as "X Client"
end box

VNC_Viewer <--> X_VNC: VNC Protocol
X_VNC <--> X_Client: X Protocol
```

**How to use:**

1. **Install `VNC Server` on Linux: example with CentOS**
    * `yum install -y tigervnc-server`
    * `vncserver :x` — start service on port `5900 + x`
    * `vncserver -kill :x` — stop service on port `5900 + x`
    * `vncserver -list` — show all running `Xvnc` instances
2. **Download `VNC Viewer` from official website**
    * By default, you can log in with your Linux username and password

**Tips:**

* `vncserver -SecurityTypes None :x` — allow passwordless login
* Keyboard input issues: hold `ctrl + shift`, then open the terminal
* Running `vncconfig -display :x` in the remote desktop terminal pops up a small window for configuring options
* **How to copy and paste between Mac and remote Linux, see [copy paste between mac and remote desktop](https://discussions.apple.com/thread/8470438)**
    * `Remote Linux -> Mac`:
        1. In `VNC Viewer`, select text and press `Ctrl + Shift + C` (sometimes just selecting the text is enough)
        2. On Mac, paste with `Command + V`
    * `Mac -> Remote Linux` (often fails for unknown reasons):
        1. On Mac, select text and press `Command + C`
        2. In `VNC Viewer`, paste with `Ctrl + Shift + V`
    * `Remote Linux -> Remote Linux`:
        1. In `VNC Viewer`, select text and press `Ctrl + Shift + C`
        2. In `VNC Viewer`, paste with `Ctrl + Shift + V`

## 8.3 NX (Recommended)

[No Machine Official Website](https://www.nomachine.com/)

**Working principle:** Similar to `VNC`, but uses the `NX` protocol, which consumes less bandwidth.

**How to use:**

1. **Install `NX Server` on Linux: example with CentOS, download the rpm package and install**
    * `rpm -ivh nomachine_7.7.4_1_x86_64.rpm`
    * `/etc/NX/nxserver --restart`
2. **Download `NX Client` from the official website**
    * The default port for `NX Server` is `4000`
    * You can log in with your Linux username and password by default

**Configuration file: `/usr/NX/etc/server.cfg`**

* `NXPort`: Modify the startup port number
* `EnableUserDB/EnablePasswordDB`: Whether to use an additional user database for login (1 to enable, 0 to disable, default is disabled)
    * `/etc/NX/nxserver --useradd admin --system --administrator`: This command essentially creates a Linux account; the first password is for the Linux account, and the second password is an independent password for `NX Server` (used only for `NX` login)

# 9 audit

[红帽企业版 Linux 7安全性指南](https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/7/html/security_guide/index)

## 9.1 Architecture

![audit_architecture](/images/Linux-Frequently-Used-Commands/audit_architecture.png)

The audit system consists of two main parts: user-space applications and utilities, and kernel-side system call handling. The kernel component accepts system calls from user-space applications and filters them through one of three filters: `user`, `task`, or `exit`. Once a system call passes through one of these filters, it is further processed by the `exclude` filter based on audit rule configuration, then passed to the audit daemon for further handling.

The processing is similar to `iptables`, with rule chains where rules can be added. When a `syscall` or special event is detected, the chain is traversed and processed according to the rules, producing different logs.

**Kernel compile options related to audit**

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

**As long as the audit option is enabled during kernel compilation, the kernel will generate audit events and send them to a socket. The audit daemon (`auditd`) is responsible for reading audit events from this socket and recording them.**

## 9.2 auditctl

### 9.2.1 Control Rules

**Options:**

* `-b`: Set the maximum allowed number of unfinished audit buffers, default is `64`
* `-e [0..2]`: Set the enable flag
    * `0`: Disable audit functionality
    * `1`: Enable audit functionality and allow configuration changes
    * `2`: Enable audit functionality and disallow configuration changes
* `-f [0..2]`: Set the failure flag (how to handle exceptions)
    * `0`: silent, do nothing on exceptions (silent mode)
    * `1`: printk, log the event (default)
    * `2`: panic, crash the system
* `-r`: Message generation rate, in seconds
* `-s`: Report audit system status
* `-l`: List all currently loaded audit rules
* `-D`: Delete all rules and watches

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

* `-w`: Path name
* `-p`: Followed by permissions, including
    * `r`: Read file or directory
    * `w`: Write file or directory
    * `x`: Execute file or directory
    * `a`: Change attributes in file or directory
* `-k`: Followed by a string, can be arbitrarily specified, used for searching

**Examples:**

* `auditctl -w /etc/shadow -p wa -k passwd_changes`: Equals to `auditctl -a always,exit -F path=/etc/shadow -F perm=wa -k passwd_changes`

### 9.2.3 System Call Rules

**Pattern:**

* `auditctl -a <action>,<filter> -S <system_call> -F field=value -k <key_name>`

**Options:**

* `-a`: Followed by `action` and `filter`
    * `action`: Determines whether to record audit events matching the `filter`, options include
        * `always`: record
        * `never`: do not record
    * `filter`: audit event filter, options include
        * `task`: matches audit events generated when processes are created (`fork` or `clone`)
        * **`exit`: matches audit events generated at the end of system calls**
        * `user`: matches audit events from user space
        * `exclude`: used to mask unwanted audit events
* `-S`: Followed by system call names; the list of system calls can be found in `/usr/include/asm/unistd_64.h`. To specify multiple system calls, use multiple `-S` options, each specifying one system call.
* `-F`: Extended option, key-value pair
* `-k`: Followed by a string, can be arbitrarily specified, used for searching

**Examples:**

* `auditctl -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time_change`

## 9.3 ausearch

**Options:**

* `-i`: Translate the results to make them more readable
* `-m`: Specify the type
* `-sc`: Specify the system call name
* `-sv`: Whether the system call was successful

**Examples:**

* `ausearch -i`: Search all events
* `ausearch --message USER_LOGIN --success no --interpret`: Search for events related to failed logins
* `ausearch -m ADD_USER -m DEL_USER -m ADD_GROUP -m USER_CHAUTHTOK -m DEL_GROUP -m CHGRP_ID -m ROLE_ASSIGN -m ROLE_REMOVE -i`: Search for all events related to account, group, and role changes
* `ausearch --start yesterday --end now -m SYSCALL -sv no -i`: Search for all failed system call events from yesterday until now
* `ausearch -m SYSCALL -sc open -i`: Search for events related to the system call "open"

## 9.4 Audit Record Types

# 10 Package Management Tools

## 10.1 rpm

**Examples:**

* `rpm -qa | grep openjdk`
* `rpm -ql java-11-openjdk-devel-11.0.8.10-1.el7.x86_64`: View the software installation path

## 10.2 yum

**Source Management (`/etc/yum.repos.d`):**

* `yum repolist`
* `yum-config-manager --enable <repo>`
* `yum-config-manager --disable <repo>`
* `yum-config-manager --add-repo <repo_url>`

**Install and Uninstall:**

* `yum install <software>`
* `yum remove <software>`
* `yum localinstall <rpms>`

**Cache:**

* `yum makecache`
    * `yum makecache fast`: Ensure the cache only contains the latest information, equivalent to `yum clean expire-cache`
* `yum clean`: Clear the cache
    * `yum clean expire-cache`: Clear expired cache
    * `yum clean all`: Clear all caches

**Software List:**

* `yum list`: List all installable software
    * `yum list docker-ce --showduplicates | sort -r`: Query version information of the software

**Install jdk:**

```sh
sudo yum install java-1.8.0-openjdk-devel
```

### 10.2.1 scl

`SCL` stands for Software Collections. It's a mechanism that allows you to install multiple versions of software on the same system, without them conflicting with each other. This is especially helpful for software like databases, web servers, or development tools where you might need different versions for different projects.

**Examples:**

* `scl -l`: Lists all the available software collections on your system.
* `scl enable <collection> <command>`: This command runs a specified `<command>` within the environment of the given software `<collection>`. This means that when you run a command under a specific software collection, you're using the version of the software provided by that collection.

**Install a specific version of gcc:**

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

**Delete:**

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
    * `ROTA: 0`: SSD
    * `ROTA: 1`: HDD
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

**CPU:**

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

**Memory:**

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

* `dstat --top-bio-adv`
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

## 11.4 Health Thresholds for Monitoring Metrics

1. `CPU Usage`: Less than `70%`.
1. `CPU Load`: Less than `<coreNum> * 0.7`.
1. `Memory Usage`: Less than `50%`.
1. `Disk Usage`: Less than `70%`.
1. `iowait`: Less than `50ms`.
1. `Threads`: Less than `10K`.
1. `IOPS`: Less than `1K`.
1. `inode`: Less than `50%`.

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
