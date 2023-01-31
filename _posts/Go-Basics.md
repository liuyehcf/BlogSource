---
title: Go-Basics
date: 2019-01-14 18:52:47
tags: 
- 原创
categories: 
- Go
- Basic
---

**阅读更多**

<!--more-->

# 1 基本概念

## 1.1 包

包是结构化代码的一种方式：每个程序都由包（通常简称为`pkg`）的概念组成，可以使用自身的包或者从其它包中导入内容。

如同其它一些编程语言中的类库或命名空间的概念，每个`Go`文件都`属于且仅属于`一个包。一个包可以由许多以`.go`为扩展名的源文件组成，因此文件名和包名一般来说都是不相同的。

你必须在源文件中非注释的第一行指明这个文件属于哪个包，如：`package main`。`package main`表示一个可独立执行的程序，每个`Go`应用程序都包含一个名为`main`的包。

一个应用程序可以包含不同的包，而且即使你只使用`main`包也不必把所有的代码都写在一个巨大的文件里：你可以用一些较小的文件，并且在每个文件非注释的第一行都使用`package main`来指明这些文件都属于`main`包。如果你打算编译包名不是为`main`的源文件，如`pack1`，编译后产生的对象文件将会是`pack1.a`而不是可执行程序。另外要注意的是，所有的包名都应该使用小写字母。

## 1.2 可见性规则

当标识符（包括常量、变量、类型、函数名、结构字段等等）以一个大写字母开头，如：Group1，那么使用这种形式的标识符的对象就可以被外部包的代码所使用（客户端程序需要先导入这个包），这被称为导出（像面向对象语言中的`public`）；标识符如果以小写字母开头，则对包外是不可见的，但是他们在整个包的内部是可见并且可用的（像面向对象语言中的`private`）。

（大写字母可以使用任何`Unicode`编码的字符，比如希腊文，不仅仅是`ASCII`码中的大写字母）。

因此，在导入一个外部包后，能够且只能够访问该包中导出的对象。

假设在包`pack1`中我们有一个变量或函数叫做`Thing`（以`T`开头，所以它能够被导出），那么在当前包中导入`pack1`包，`Thing`就可以像面向对象语言那样使用点标记来调用：`pack1.Thing`（**`pack1`在这里是不可以省略的**）。

因此包也可以作为命名空间使用，帮助避免命名冲突（名称冲突）：两个包中的同名变量的区别在于他们的包名，例如`pack1.Thing`和`pack2.Thing`。

你可以通过使用包的别名来解决包名之间的名称冲突，或者说根据你的个人喜好对包名进行重新设置，如：`import fm "fmt"`。下面的代码展示了如何使用包的别名：

```go
package main

import fm "fmt" // alias3

func main() {
   fm.Println("hello, world")
}
```

# 2 Tips

## 2.1 值类型与引用类型

1. `int`、`float`、`bool`、`array`、`struct`是值类型
1. `slice`、`map`、`func`、`method`、`chan`、`interface`、`string`是引用类型

## 2.2 数组与切片

1. 数组是固定大小的 `[<n>]Type`
1. 引用是可变的（可理解为动态数组）`[]Type`

## 2.3 类型转换

`Type(v)`

## 2.4 类型识别

```go
   if value, ok := obj.(T); ok {
		
   } 
   
   switch t := obj.(type) {
	case T1:
      //xxx
   case *T2:
      //xxx
   default:
      //xxx
	}
```

## 2.5 字符串拼接

`fmt.Sprintf`

## 2.6 各种类型转为字符串

`fmt.Sprintf`

## 2.7 go文件命名规范

**区分平台和cpu架构：`<name>_<platform>_<cpu arch>.go`**

* `file.go`
* `file_linux.go`
* `file_linux_amd64.go`

**测试：`<name>_<platform>_<cpu arch>_test.go`**

* `file_test.go`
* `file_linux_test.go`
* `file_linux_amd64_test.go`

## 2.8 交叉编译

```sh
# 查看环境变量
go env

# 编译指定cpuArch的二进制
env GOOS=linux GOARCH=amd64 go build -o <target_binary> <src.go> 
```

## 2.9 类似try...catch

1. `panic`：抛出异常
1. `defer`&`recover`：捕获异常

## 2.10 bindata-打包资源文件

`go build`只能编译go文件，但是项目中如果存在资源文件，比如`css`，`html`等文件，是无法被`go build`打包进二进制文件的

`go-bindata`提供了打包资源文件的方式，原理很简单：就是将这些资源文件序列化成`[]byte`，包含在自动创建的`go`文件中

[go-bindata-github](https://github.com/elazarl/go-bindata-assetfs)

```sh
# 安装go-bindata
go get github.com/jteeuwen/go-bindata/...
go get github.com/elazarl/go-bindata-assetfs/...

# 生成包含指定资源文件的go文件
go-bindata -pkg <package> -o <go file path> <resource path1> <resource path2> ...
# <package> : 生成go文件的包
# <go file path> : 生成的go文件路径
# <resource path1> : 具体要打包的资源路径
```

## 2.11 log-framework

[lumberjack](https://github.com/natefinch/lumberjack)

[Golang 获取用户 home 目录路径](https://studygolang.com/articles/2772)

[logback-for-go](https://github.com/liuyehcf/common-gtools)

## 2.12 同步

### 2.12.1 Cond

go中的Cond类似于Java中的`AbstractQueuedSynchronizer以及ConditionObject`

```go
package main

import (
    "sync"
    "time"
)

func main() {
    m := sync.Mutex{}
    c := sync.NewCond(&m)
    go func() {
        time.Sleep(1 * time.Second)
        c.Broadcast()
    }()
    m.Lock()
    time.Sleep(2 * time.Second)
    c.Wait()
}
```

## 2.13 [FAQ](https://golang.org/doc/faq)

1. [new和make的区别](https://golang.org/doc/faq#new_and_make)
1. [方法参数引用和非引用](https://golang.org/doc/faq#methods_on_values_or_pointers)

# 3 包管理工具

## 3.1 go get

1. 要求工程必须在`GOPATH`中

### 3.1.1 从gitlab上下载依赖包

需要开启交互，默认是禁止的（在下载过程中需要进行auth，输入用户名和密码）

```sh
export GIT_TERMINAL_PROMPT=1
```

## 3.2 go module

### 3.2.1 如何开启

1. go版本大于`1.12`
1. 满足下面两个条件中的任意一个
   1. 在`GOPATH/src`目录之外，且目录中（当前目录或父目录）存在`go.mod`
   1. 设置环境变量`GO111MODULE=on`

### 3.2.2 如何使用

```sh
# 初始化go module项目，执行完毕之后，会在当前路径下生成go.mod文件
go mod init github.com/aaa/bbb

# 更新依赖
go get github.com/aaa/bbb@master

# 显示依赖
go list -m all

# 显示依赖及可升级的版本
go list -u -m all

# 引入不存在的依赖/删除多余的依赖
go mod tidy

# 将外部依赖包缓存到vendor/目录中
go mod vendor

# 使用vendor/目录下的包进行编译
go build -mod=vendor
```

### 3.2.3 版本管理

go module支持在报名后增加`/v2`，`/v3`这样的后缀和对应的三位版本号标签（`git tag`），解决兼容性问题，**包的版本号格式为：`v{major}.{minor}.{patch}`**

go module对版本号的约定

1. `v0`、`v1`版本不存在兼容性问题
1. `v2`开始，不同的`major`代表和前一个版本不兼容
1. 如果一个go程序导入（直接依赖或间接依赖）同一个包的多个兼容版本，默认会使用版本号较高的那个
    * 如果同时依赖了`v0.1.2`和`v1.0.1`，那么会使用`v1.0.1`
    * 如果同时依赖了`v2.0.1`和`v2.0.2`，那么会使用`v2.0.2`
1. 如果一个go程序导入（直接依赖或间接依赖）同一个包的多个不兼容版本，则使用各自版本的包
    * 如果同时依赖了`v1.1.0`和`v2.1.0`，那么会同时存在

### 3.2.4 部分包想用本地版本

用replace指向本地的依赖

### 3.2.5 从github上下载依赖包

#### 3.2.5.1 修改proxy

在墙内下载依赖包，很有可能会timeout，可以通过配置proxy来解决这个问题

```sh
go env -w GOPROXY=https://goproxy.cn,direct
```

#### 3.2.5.2 修改sum

go module默认会从`sum.golang.org`对依赖包进行一个校验，但是在墙内环境，`sum.golang.org`是无法访问的，通常会报如下的一个错误

```
verifying github.com/xxx/yyy/go.mod: github.com/xxxyyy@v0.1.11/go.mod: Get https://sum.golang.org/lookup/github.com/xxx/yyy@v0.1.11: dial tcp 216.58.197.113:443: i/o timeout
```

此时，我们有两种选择

1. 关闭校验：`go env -w GOSUMDB=off`
1. 修改校验地址：`go env -w GOSUMDB="sum.golang.google.cn"`

### 3.2.6 从gitlab上下载依赖包

需要设置环境变量`GOPROXY`以及`GOPRIVATE`

```sh
# 不使用代理，默认会使用 proxy.golang.org
export GOPROXY=direct

# 这样配置后，就可以从gitlab中下载tom以及jerry这两个组织中的所有代码了，否则会出现 410 Gone 这样的错误信息
export GOPRIVATE=gitlab.com/tom/*, gitlab.com/jerry/*
```

**[unable to install go module (private nested repository)](https://gitlab.com/gitlab-org/gitlab-foss/issues/65681)**

在设置完`GOPROXY`以及`GOPRIVATE`之后，有时会出现如下问题

```
... imports
        gitlab.com/xxx/yyy: git ls-remote -q https://gitlab.com/xxx/yyy.git in /Users/hechenfeng/.gorepo/pkg/mod/cache/vcs/82c21665246dae55cc8f78cc6ebbe6bed9f6ccc4d86a36f71bfb28f7477c0aee: exit status 128:
        fatal: could not read Username for 'https://gitlab.com': terminal prompts disabled
Confirm the import path was entered correctly.
If this is a private repository, see https://golang.org/doc/faq#git_https for additional information.
```

我们可以通过设置`export GIT_TERMINAL_PROMPT=1`来开启交互模式，**但是随后执行`go mod tidy`时，auth的交互是有bug的，他会让你输入两次密码（很坑）**。所以我们换另一种方式来解决，执行`git ls-remote -q https://gitlab.com/xxx/yyy.git`，执行过程中会要求你输入`gitlab`的账号和密码

随后，我们继续执行`go mod tidy`，还是报错，但报错信息如下

```sh
... imports
        gitlab.com/xxx/yyy: git ls-remote -q https://gitlab.com/xxx.git in /Users/hechenfeng/.gorepo/pkg/mod/cache/vcs/abaeae1021d76630bfb57ffb11ec22f4a1f393859f7c63b7c849108ca94a2157: exit status 128:
        remote: Not Found
        fatal: repository 'https://gitlab.com/xxx.git/' not found
```

这里就有点奇怪了，我的gitlab项目地址其实是`gitlab.com/xxx/yyy.git`，但是错误信息里面确尝试下载的是`gitlab.com/xxx.git`。最后发现，我只是在代码里面引入了`gitlab.com/xxx/yyy`，但并未在`go.mod`文件的`require`中配置`gitlab.com/xxx/yyy`的依赖项，所以`go mod`误认为`gitlab.com/xxx`是仓库地址

所以我们现在在`go.mod`文件中，将依赖加上即可

**此外，如果我们`gitlab`的账号密码更新了，那么`git`仍然会用上一次的密码来进行鉴权，此时需要将该过期的密码从系统的秘钥中删除**

* 如果是Mac的OSX系统，在钥匙串的密码一项中，找到gitlab相关的数据，删掉即可

### 3.2.7 IDE-GoLand

**新建go module项目**

1. 在新建时，可以直接选择go module项目（`Go Modules (vgo)`）
1. 创建完毕之后，会自动在项目根目录创建go.mod文件

**将非go module项目改造成go module项目**

1. 在工程根目录执行`go mod init xxx/xxx`创建`go.mod`文件
1. `Preferences`->`GO`->`Go Modules (vgo)`->勾上`Enable Go Modules (vgo) integration`

## 3.3 go dep

### 3.3.1 安装

```sh
# 在工程中执行下面的命令安装dep
go get -u github.com/golang/dep/cmd/dep

# 查看是否安装成功
dep help
```

### 3.3.2 使用

```sh
# 初始化，会创建两个文件Gopkg.lock、Gopkg.toml，以及目录vendor
dep init

# 添加依赖项到当前工程中
dep ensure -add github.com/pkg/errors

# 安装依赖项到vendor目录汇总
dep ensure
```

# 4 pprof

# 5 Common-Libs

## 5.1 mysql

[使用go语言操作mysql数据库](https://studygolang.com/articles/3022)

## 5.2 template

[gotemplate](https://golang.org/pkg/text/template/）

# 6 GoLand

## 6.1 build tags

例如，我在Mac上安装了GoLand，但是我想要调用linux环境下的syscall，但是在GoLand默认解析的是Mac版本的源码（`syscall_darwin_amd64.go`）

可以通过配置`build tags`，将OS配置成linux，配置方式：

* `Preferences`
    * `Go`
        * `Vendoring & Build Tags`，然后将`OS`改成`linux`即可

# 7 参考

* [Frequently Asked Questions](https://golang.org/doc/faq)
* [go中包的概念、导入与可见性](https://studygolang.com/articles/7165)
* [Go语言入门教程，Golang入门教程（非常详细）](http://c.biancheng.net/golang/)
* [Go log 日志](https://www.jianshu.com/p/d634316a9487)
* [go mod](https://juejin.im/post/5c8e503a6fb9a070d878184a)
* [go mod常用命令 已经 常见问题](https://blog.csdn.net/zzhongcy/article/details/97243826)
* [Configuring GoLand for WebAssembly](https://github.com/golang/go/wiki/Configuring-GoLand-for-WebAssembly)
* [Go语言的%d,%p,%v等占位符的使用](https://www.jianshu.com/p/66aaf908045e)
* [go-get-results-in-terminal-prompts-disabled-error-for-github-private-repo](https://stackoverflow.com/questions/32232655/go-get-results-in-terminal-prompts-disabled-error-for-github-private-repo)
* [git报错remote: Repository not found的一种可能](https://www.jianshu.com/p/5eb3a91458de)
* [How to correctly use sync.Cond?](https://stackoverflow.com/questions/36857167/how-to-correctly-use-sync-cond)
* [go安装gin框架失败错误解决：sum.golang.org被墙](https://blog.csdn.net/LXDOS/article/details/104749071/)
* [pprof doc](https://pkg.go.dev/net/http/pprof)
* [如何使用go pprof定位内存泄露](http://team.jiunile.com/blog/2020/09/go-pprof.html)
* [Golang 大杀器之性能剖析 PProf](https://www.jianshu.com/p/4e4ff6be6af9)
* [How to run go pprof on Docker daemon](https://gist.github.com/Jimmy-Xu/85fb01cd7620454c6d65)
