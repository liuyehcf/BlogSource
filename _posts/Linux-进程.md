---
title: Linux-进程
date: 2020-08-27 14:24:08
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

__阅读更多__

<!--more-->

# 1 如何创建进程

__两个系统调用（这是Linux创建进程的唯一途径）__

1. `fork`：以当前进程作为原型进行复制，几乎包含进程的所有相关信息，包括代码和数据
1. `exec`：将当前进程空间的数据完全替换为另一个进程的数据

Linux提供了一系列的机制和策略

1. 机制就是原子操作，所有Linux支持的系统调用都可以理解为一种机制
1. 策略是将这些机制进行组合达到最终的目的，在Linux中创建进程的策略就是通过`fork`+`exec`

# 2 进程父子关系

父进程可以通过`fork`+`exec`来创建子进程，例如进程`A`创建了进程`B`，那么此时进程`B`的父进程就是进程`A`

那么当进程`A`退出之后，进程`B`的父进程该如何变化呢？

__情景1__

```sh
# 通过shell执行一个后台进程
[root@liuyehcf ~]$ tail -f /dev/null &
127775

# 查看这个tail进程的信息
[root@liuyehcf ~]$ ps -f --pid 127775
UID         PID   PPID  C STIME TTY          TIME CMD
root     127775 126213  0 16:28 pts/0    00:00:00 tail -f /dev/null

# 查看父进程的信息
[root@liuyehcf ~]$ ps -f --pid 126213
UID         PID   PPID  C STIME TTY          TIME CMD
root     126213 125787  0 16:28 pts/0    00:00:00 -bash

# 我们发现，此时tail进程的父进程就是shell本身（-bash进程）
# 此时我们退出终端
[root@liuyehcf ~]$ exit

# 再次登录，并查看tail进程
[root@liuyehcf ~]$ ps -f --pid 127775
UID         PID   PPID  C STIME TTY          TIME CMD
root     127775      1  0 16:28 ?        00:00:00 tail -f /dev/null

# 此时发现，tail进程仍然存在，但是它的父进程变成了1
```

__情景2__

```sh
# 通过shell执行一个后台进程
[root@liuyehcf ~]$ tail -f /dev/null &
62925

# 查看这个tail进程的信息
[root@liuyehcf ~]$ ps -f --pid 62925
UID         PID   PPID  C STIME TTY          TIME CMD
root      62925  23709  0 16:37 pts/1    00:00:00 tail -f /dev/null

# 查看父进程的信息
[root@liuyehcf ~]$ ps -f --pid 23709
UID         PID   PPID  C STIME TTY          TIME CMD
root      23709  23636  0 16:32 pts/1    00:00:00 -bash

# 我们发现，此时tail进程的父进程就是shell本身（-bash进程）
# 此时我们通过sighup停止shell
[root@liuyehcf ~]$ kill -sighup 23709

# 再次登录，并查看tail进程
[root@liuyehcf ~]$ ps -f --pid 62925
UID         PID   PPID  C STIME TTY          TIME CMD

# 此时发现，tail进程已经退出了
```

__情景3__

```sh
# 通过shell执行一个后台进程，且使用nohup
[root@liuyehcf ~]$ nohup tail -f /dev/null &
84964

# 查看这个tail进程的信息
[root@liuyehcf ~]$ ps -f --pid 84964
UID         PID   PPID  C STIME TTY          TIME CMD
root      84964  78471  0 16:40 pts/0    00:00:00 tail -f /dev/null

# 查看父进程的信息
[root@liuyehcf ~]$ ps -f --pid 78471
UID         PID   PPID  C STIME TTY          TIME CMD
root      78471  78213  0 16:40 pts/0    00:00:00 -bash

# 我们发现，此时tail进程的父进程就是shell本身（-bash进程）
# 此时我们通过sighup停止shell
[root@liuyehcf ~]$ kill -sighup 78471

# 再次登录，并查看tail进程
[root@liuyehcf ~]$ ps -f --pid 84964
UID         PID   PPID  C STIME TTY          TIME CMD
root      84964      1  0 16:40 ?        00:00:00 tail -f /dev/null

# 此时发现，tail进程仍然存在，但是它的父进程变成了1
```

__情景4__

```sh
# 编写脚本
[root@liuyehcf ~]$ cat > tail1.sh << 'EOF'
#!/bin/sh

tail -f /dev/null &
EOF
[root@liuyehcf ~]$ chmod a+x tail1.sh

# 执行脚本
[root@liuyehcf ~]$ ./tail1.sh

# 查看这个tail进程的信息
[root@liuyehcf ~]$ ps -ef | grep 'tail -f'
root      31417      1  0 16:52 pts/0    00:00:00 tail -f /dev/null

# 发现tail进程的进程id是31417，其父进程的进程id是1
```

__情景5__

```sh
# 编写脚本
[root@liuyehcf ~]$ cat > tail2.sh << 'EOF'
#!/bin/sh

tail -f /dev/null &

sleep 60
EOF
[root@liuyehcf ~]$ chmod a+x tail2.sh

# 执行脚本
[root@liuyehcf ~]$ ./tail2.sh

# 1分钟内，在另一个终端中，查看这个tail进程的信息
[root@liuyehcf ~]$ ps -ef | grep 'tail -f'
root      67472  67471  0 16:57 pts/0    00:00:00 tail -f /dev/null

# 发现tail进程的进程id是67472，其父进程的进程id是67471
# 在另一个终端中，查看父进程的信息
[root@liuyehcf ~]$ ps -f --pid 67471
UID         PID   PPID  C STIME TTY          TIME CMD
root      67471  91584  0 16:57 pts/0    00:00:00 /bin/sh ./tail2.sh

# 过一分钟之后，在另一个终端中，再次查看tail进程
[root@liuyehcf ~]$ ps -f --pid 67472
UID         PID   PPID  C STIME TTY          TIME CMD
root      67472      1  0 16:57 pts/0    00:00:00 tail -f /dev/null

# 此时，tail进程仍然存在，父进程变成了1
```

__总结：__

1. 通过`情景1`和`情景2`的对比，我们可以发现，只有当父进程（在这里就是`bash`进程）收到了`hup`信号时，才会终止所有子进程
1. 通过`情景2`和`情景3`的对比，我们可以发现，当使用`nohup`时，即便`bash`收到了`hup`信号，也不会杀死该`nohup`的子进程
1. 通过`情景4`和`情景5`的对比，我们可以发现，在`shell`中执行脚本，其实是用`#!/bin/sh`指定的shell来执行对应的脚本，脚本中进程的父进程就是`/bin/sh`这个shell，且退出后没有收到`hup`信号时，不会杀死子进程
1. 子进程的父进程终止后，子进程的父进程会变为1
* 在shell（这里就是`bash`）中执行命令，其简单过程如下：
    1. `bash`进程收到标准输入
    1. `bash`进程通过执行`fork`+`exec`两次系统调用来启动子进程
    1. `bash`编写了一套信号处理函数，当收到了`hup`信号时，会终止对应的子进程
* `nohup command args...`这个命令执行过程如下
    1. `bash`进程收到输入`nohup command args...`，通过系统调用`fork`+`exec`启动子进程`nohup`
    1. `nohup`进程收到入参`command args...`，首先注册`hup`信号的处理方法（该方法会忽略`hup`信号），然后通过系统调用`fork`+`exec`启动子进程`command`
    1. 当`bash`收到`hup`信号时，会将`hup`信号传递给子进程，而此时由于子进程已经注册了特殊的`hup`信号处理方法，于是将`hup`信号忽略，子进程得以存活

# 3 进程、进程组、会话、终端、tty、作业、前台、后台

## 3.1 终端（terminal）

终端（termimal）= tty（Teletypewriter，电传打印机），作用是提供一个命令的输入输出环境，在linux下使用组合键`ctrl+alt+T`打开的就是终端，可以认为`terminal`和`tty`是同义词

## 3.2 shell

shell是一个命令行解释器，是linux内核的一个外壳,负责外界与linux内核的交互。shell接收用户或者其他应用程序的命令, 然后将这些命令转化成内核能理解的语言并传给内核，内核执行命令完成后将结果返回给用户或者应用程序。当你打开一个terminal时，操作系统会将terminal和shell关联起来，当我们在terminal中输入命令后，shell就负责解释命令

## 3.3 console

在计算机发展的早期，计算机的外表上通常会存在一个面板，面板包含很多按钮和指示灯，可以通过面板来对计算机进行底层的管理，也可以通过指示灯来得知计算机的运行状态，这个面板就叫console。在现代计算机上，在电脑开机时（比如ubuntu）屏幕上会打印出一些日志信息，但在系统启动完成之前，terminal不能连接到主机上，所以为了记录主机的重要日志（比如开关机日志，重要应用程序的日志），系统中就多了一个名为console的设备，这些日志信息就是显示在console上。一台电脑有且只有一个console，但可以有多个terminal。举个例子，电视机上的某个区域一般都会有一些按钮，比如开机，调音量等，这个区域就可以当做console，且这个区域在电视上只有一个，遥控器就可以类比成terminal，terminal可以有多个

## 3.4 bash

linux系统上可以包含多种不同的shell（可以使用命令`cat /etc/shells`查看），比较常见的有`Bourne shell(sh)`、`C shell (csh)`和`Korn shell(ksh)`，三种shell都有它们的优点和缺点。`Bourne shell`的作者是`Steven Bourne`，它是`UNIX`最初使用的shell并且在每种`UNIX`上都可以使用。bash的全称叫做`Bourne Again shell`，从名字上可以看出bash是`Bourne shell`的扩展，bash与`Bourne shell`完全向后兼容，并且在`Bourne shell`的基础上增加和增强了很多特性，如命令补全、命令编辑和命令历史表等功能，它还包含了很多`C shell`和`Korn shell`中的优点，有灵活和强大的编程接口，同时又有很友好的用户界面。总而言之，bash是shell的一种，是增强的shell

# 4 参考

* [终端(terminal)、tty、shell、控制台（console）、bash之间的区别与联系](https://www.cnblogs.com/sench/p/8920292.html)
* [What is the exact difference between a 'terminal', a 'shell', a 'tty' and a 'console'?](https://unix.stackexchange.com/questions/4126/what-is-the-exact-difference-between-a-terminal-a-shell-a-tty-and-a-con)
* [进程、进程组、作业、会话](https://www.cnblogs.com/cangqinglang/p/12110843.html)
