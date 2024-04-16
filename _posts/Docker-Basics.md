---
title: Docker-Basics
date: 2018-01-19 13:18:39
tags: 
- 摘录
categories: 
- Java
- Isolation Technology
---

**阅读更多**

<!--more-->

# 1 安装docker

## 1.1 centos

```sh
# docker安装
# --step 1: 安装必要的一些系统工具
yum install -y yum-utils device-mapper-persistent-data lvm2
# --step 2: 添加软件源信息
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# --step 3
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# --step 4: 更新并安装docker-ce，可以通过 yum list docker-ce --showduplicates | sort -r 查询可以安装的版本列表
yum makecache fast
yum -y install docker-ce-20.10.5-3.el7
# --step 5: 开启docker服务
systemctl enable docker
systemctl start docker
```

# 2 容器的生命周期

![container_lifecycle](/images/Docker-Basics/container_lifecycle.webp)

# 3 文件系统

## 3.1 overlay2

[Example OverlayFS Usage [duplicate]](https://askubuntu.com/questions/699565/example-overlayfs-usage)

# 4 创建镜像

**创建一个空的目录**，例如`/tmp/test`

**创建Dockerfile（核心）**

1. **FROM：用于指定一个基础镜像**
    * 一般情况下一个可用的Dockerfile一定是FROM作为第一个指令。至于image则可以是任何合理存在的image镜像
    * `FROM`一定是首个非注释指令Dockerfile
    * `FROM`可以在一个Dockerfile中出现多次，以便于创建混合images
    * 如果没有指定tag，latest将会被指定为要使用的基础镜像版本
1. **MAINTAINER：用于指定镜像制作者的信息**
1. **RUN：创建镜像时执行的命令（RUN命令产生的作用是会被持久化到创建的镜像中的）**
    * 层级`RUN`指令和生成提交是符合Docker核心理念的做法。它允许像版本控制那样，在任意一个点，对image镜像进行定制化构建
    * `RUN`指令缓存不会在下个命令执行时自动失效。比如`RUN apt-get dist-upgrade -y`的缓存就可能被用于下一个指令
    * `--no-cache`标志可以被用于强制取消缓存使用
1. **ENV：用于为docker容器设置环境变量**
    * `ENV`设置的环境变量，可以使用`docker inspect`命令来查看。同时还可以使用`docker run --env <key>=<value>`来修改环境变量
1. **USER：用来切换运行属主身份**
    * Docker默认是使用root
1. **WORKDIR：用于切换工作目录**
    * Docker默认的工作目录是`/`，只有`RUN`能执行cd命令切换目录，而且还只作用在当下的`RUN`，也就是说每一个`RUN`都是独立进行的
    * 如果想让其他指令在指定的目录下执行，就得靠`WORKDIR`，`WORKDIR`动作的目录改变是持久的，不用每个指令前都使用一次`WORKDIR`
1. **COPY：将文件从路径`<src>`复制添加到容器内部路径`<dest>`**
    * `<src>`必须是想对于源文件夹的一个文件或目录，也可以是一个远程的url
    * `<dest>`是目标容器中的绝对路径
    * 所有的新文件和文件夹都会创建UID和GID。事实上如果`<src>`是一个远程文件URL，那么目标文件的权限将会是600
1. **ADD：将文件从路径`<src>`复制添加到容器内部路径`<dest>`**
    * `<src>`必须是想对于源文件夹的一个文件或目录，也可以是一个远程的url
    * `<dest>`是目标容器中的绝对路径
    * 所有的新文件和文件夹都会创建UID和GID。事实上如果`<src>`是一个远程文件URL，那么目标文件的权限将会是600
1. **VOLUME：创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等**
1. **EXPOSE：指定在docker允许时指定的端口进行转发**
1. **CMD：启动容器时执行的命令**
    * Dockerfile中只能有一个CMD指令。如果你指定了多个，那么只有最后个CMD指令是生效的
    * 可以被`docker run $image $other_command`中的`$other_command`覆盖
1. **ONBUILD：让指令延迟執行**
    * 延迟到下一个使用`FROM`的Dockerfile在建立image时执行，只限延迟一次
1. **ARG：定义仅在建立image时有效的变量**
1. **ENTRYPOINT：指定Docker image运行成instance(也就是 Docker container)时，要执行的命令或者文件**
    * 默认的`ENTRYPOINT`是`/bin/sh -c`，但是没有默认的`CMD`
    * 当执行`docker run -i -t ubuntu bash`，默认的`ENTRYPOINT`就是`/bin/sh -c`，且`CMD`就是`bash`
    * **`CMD`本质上就是`ENTRYPOINT`的参数**

```sh
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```

**requirements.txt（上面的Dockerfile中的Run命令用到了这个文件）**

```
Flask
Redis
```

**app.py**

```py
from flask import Flask
from redis import Redis, RedisError
import os
import socket

# Connect to Redis
redis = Redis(host="redis", db=0, socket_connect_timeout=2, socket_timeout=2)

app = Flask(__name__)

@app.route("/")
def hello():
    try:
        visits = redis.incr("counter")
    except RedisError:
        visits = "<i>cannot connect to Redis, counter disabled</i>"

    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>" \
           "<b>Visits:</b> {visits}"
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname(), visits=visits)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```

**创建镜像：`docker build -t friendlyhello .`**

**运行应用：`docker run -p 4000:80 friendlyhello`**

# 5 docker命令行工具

学会利用`--help`参数

```sh
docker --help # 查询所有顶层的参数
docker image --help # 参数image参数的子参数
```

# 6 基础镜像

## 6.1 Alpine

Alpine Linux是一个轻型Linux发行版，它不同于通常的Linux发行版，Alpine采用了musl libc 和 BusyBox以减少系统的体积和运行时的资源消耗。Alpine Linux提供了自己的包管理工具：apk

构建一个带有bash的docker镜像

```docker
FROM alpine:3.10.2

MAINTAINER Rethink 
# 更新Alpine的软件源为国内（清华大学）的站点，因为从默认官源拉取实在太慢了。。。
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/main/" > /etc/apk/repositories

RUN apk update \
        && apk upgrade \
        && apk add --no-cache bash \
        bash-doc \
        bash-completion \
        && rm -rf /var/cache/apk/* \
        && /bin/bash

# 解决时区的问题（对于alpine镜像，仅仅设置环境变量TZ=Asia/Shanghai是不够的）
RUN apk add -U tzdata
```

## 6.2 Jib

```xml
            <plugin>
                <groupId>com.google.cloud.tools</groupId>
                <artifactId>jib-maven-plugin</artifactId>
                <version>1.6.1</version>
                <configuration>
                    <from>
                        <!-- 不带这个基础镜像的话，构建出来的镜像是不包含bash的 -->
                        <image>openjdk:8u222-jdk</image> 
                    </from>
                    <to>
                        <image>my-app:v1</image>
                        <auth>
                            <username>xxx</username>
                            <password>xxx</password>
                        </auth>
                    </to>
                    <container>
                        <!-- 不加这个参数的话，构建出来的镜像时49年前的 -->
                        <useCurrentTimestamp>true</useCurrentTimestamp>
                    </container>
                </configuration>
            </plugin>
```

# 7 Tips

1. 启动并保持容器运行
    * 可以执行一个不会终止的程序：`docker run -dit xxx:v1`
    * 启动的同时，开启一个bash：`docker run -it 9a88e0029e3b /bin/bash`
1. 在主机与Docker容器之间拷贝文件
    * `docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-`
    * `docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH`
1. 打开`D-Bus connection`
    * `docker run -d -e "container=docker" --privileged=true [ID] /usr/sbin/init`
    * 容器启动的`CMD`包含`/usr/sbin/init`即可
1. 启停容器：
    * `docker start <container-id>`
    * `docker stop <container-id>`
1. 在指定容器中执行命令
    * `docker exec -ti my_container /bin/bash -c "echo a && echo b"`
1. 查看docker container对应的pid
    * `docker inspect <container-id> | grep Pid`
1. 删除某个tag
    * `docker rmi <repository>:<tag>`，不要用镜像id
1. 列出所有的镜像id
    * `docker images -q`
1. 将镜像打包成文件，从文件中导入镜像
    * `docker save -o alpine.tar alpine:3.10.2`
    * `docker load < alpine.tar`
1. 设置时区
    * `docker run -e TZ=Asia/Shanghai ...`
1. 设置内核参数（需要使用特权模式）
    * 编写DockerFile的时候，把修改的内核参数写到CMD中（不能在制作DockerFile的时候通过RUN进行修改，因为这些内核文件是只读的）
    * 启动的时候指定特权模式：`docker run --privileged`
1. 在容器中使用docker命令
    * `--privileged`：使用特权模式
    * `-v /var/run/docker.sock:/var/run/docker.sock`：将docker socket文件挂载到容器
    * `-v $(which docker):/bin/docker `：将docker命令挂载到容器
1. 启动容器时，加入网络命名空间
    * `docker run [--pid string] [--userns string] [--uts string] [--network string] <other options>`
    * `docker run -d --net=container:<已有容器id> <镜像id>`
1. 删除docker命令后，docker的工作目录仍然是保留的（包含了镜像）若要彻底删除，可以通过如下命令
    * `rm -rf /var/lib/docker`
1. 查看img的构建记录：`docker history <img>`
1. 查看img的详情：`docker inspect <img>`
1. 查看容器资源占用情况：`docker stats <container>`
1. 清理无用镜像：`docker system prune -a`
1. 让普通用户有权限使用`docker`：`sudo usermod -aG docker username`

## 7.1 修改存储路径

默认情况下，docker相关的数据会存储在`/var/lib/docker`。编辑配置文件`/etc/docker/daemon.json`（没有就新建），增加如下配置项：

```json
{
    "data-root": "<some path>"
}
```

然后通过`systemctl restart docker`重启docker即可

## 7.2 修改镜像源

编辑配置文件`/etc/docker/daemon.json`（没有就新建），增加如下配置项：

```json
{
    "registry-mirrors": [
        "http://registry.docker-cn.com",
        "http://docker.mirrors.ustc.edu.cn",
        "http://hub-mirror.c.163.com"
    ],
    "insecure-registries": [
        "registry.docker-cn.com",
        "docker.mirrors.ustc.edu.cn"
    ]
}
```

然后通过`systemctl restart docker`重启docker即可

## 7.3 跨平台运行容器

默认情况下，docker是不支持`--platform`参数的，可以通过修改`/etc/docker/daemon.json`，添加如下配置项后，重启docker，开启该功能

```json
{
  ...
  "experimental": true,
  ...
}
```

如果我们在x86的平台上运行arm64的docker镜像，会得到如下错误信息

```sh
docker run --platform linux/arm64 --rm arm64v8/ubuntu:18.04 uname -a

#-------------------------↓↓↓↓↓↓-------------------------
standard_init_linux.go:219: exec user process caused: exec format error
#-------------------------↑↑↑↑↑↑-------------------------
```

此时，我们可以借助跨平台工具`qemu`，[下载地址](https://github.com/multiarch/qemu-user-static/releases)。该方法对内核版本有要求，貌似要4.x以上，我的测试环境的内核版本是`4.14.134`

```sh
# 下载qemu-aarch64-static
wget 'https://github.com/multiarch/qemu-user-static/releases/download/v5.2.0-2/qemu-aarch64-static.tar.gz'
tar -zxvf qemu-aarch64-static.tar.gz -C /usr/bin

# 安装qume
docker run --rm --privileged multiarch/qemu-user-static:register

#-------------------------↓↓↓↓↓↓-------------------------
Setting /usr/bin/qemu-alpha-static as binfmt interpreter for alpha
Setting /usr/bin/qemu-arm-static as binfmt interpreter for arm
Setting /usr/bin/qemu-armeb-static as binfmt interpreter for armeb
Setting /usr/bin/qemu-sparc-static as binfmt interpreter for sparc
Setting /usr/bin/qemu-sparc32plus-static as binfmt interpreter for sparc32plus
Setting /usr/bin/qemu-sparc64-static as binfmt interpreter for sparc64
Setting /usr/bin/qemu-ppc-static as binfmt interpreter for ppc
Setting /usr/bin/qemu-ppc64-static as binfmt interpreter for ppc64
Setting /usr/bin/qemu-ppc64le-static as binfmt interpreter for ppc64le
Setting /usr/bin/qemu-m68k-static as binfmt interpreter for m68k
Setting /usr/bin/qemu-mips-static as binfmt interpreter for mips
Setting /usr/bin/qemu-mipsel-static as binfmt interpreter for mipsel
Setting /usr/bin/qemu-mipsn32-static as binfmt interpreter for mipsn32
Setting /usr/bin/qemu-mipsn32el-static as binfmt interpreter for mipsn32el
Setting /usr/bin/qemu-mips64-static as binfmt interpreter for mips64
Setting /usr/bin/qemu-mips64el-static as binfmt interpreter for mips64el
Setting /usr/bin/qemu-sh4-static as binfmt interpreter for sh4
Setting /usr/bin/qemu-sh4eb-static as binfmt interpreter for sh4eb
Setting /usr/bin/qemu-s390x-static as binfmt interpreter for s390x
Setting /usr/bin/qemu-aarch64-static as binfmt interpreter for aarch64
Setting /usr/bin/qemu-aarch64_be-static as binfmt interpreter for aarch64_be
Setting /usr/bin/qemu-hppa-static as binfmt interpreter for hppa
Setting /usr/bin/qemu-riscv32-static as binfmt interpreter for riscv32
Setting /usr/bin/qemu-riscv64-static as binfmt interpreter for riscv64
Setting /usr/bin/qemu-xtensa-static as binfmt interpreter for xtensa
Setting /usr/bin/qemu-xtensaeb-static as binfmt interpreter for xtensaeb
Setting /usr/bin/qemu-microblaze-static as binfmt interpreter for microblaze
Setting /usr/bin/qemu-microblazeel-static as binfmt interpreter for microblazeel
Setting /usr/bin/qemu-or1k-static as binfmt interpreter for or1k
#-------------------------↑↑↑↑↑↑-------------------------

# 再次运行
docker run --platform linux/arm64 --rm arm64v8/ubuntu:18.04 uname -a

#-------------------------↓↓↓↓↓↓-------------------------
standard_init_linux.go:219: exec user process caused: no such file or directory
#-------------------------↑↑↑↑↑↑-------------------------

# 将qemu挂到容器内，再次运行
docker run --platform linux/arm64 --rm -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static arm64v8/ubuntu:18.04 uname -a

#-------------------------↓↓↓↓↓↓-------------------------
Linux c3fb58ea543c 4.14.134 #1 SMP Tue Dec 29 21:27:58 EST 2020 aarch64 aarch64 aarch64 GNU/Linux
#-------------------------↑↑↑↑↑↑-------------------------
```

* `docker run --rm --privileged multiarch/qemu-user-static:register`是向内核注册了各异构平台的`binfmt handler`，包括`aarch64`等等，这些注册信息就包括了`binfmt handler`的路径，比如`/usr/bin/qemu-aarch64-static`等等，注册信息都在`/proc/sys/fs/binfmt_misc`目录下，每个注册项都是该目录下的一个文件。**实际的`qemu-xxx-static`文件还得手动放置到对应目录中才能生效**

## 7.4 镜像裁剪工具-dockerslim

```sh
docker-slim build --http-probe=false centos:7.6.1810
```

裁剪之后，镜像的体积从`202MB`变为`3.55MB`。但是裁剪之后，大部分的命令都被裁剪了（包括`ls`这种最基础的命令）

## 7.5 如何感知程序是否运行在容器中

一般来说，如果运行环境是容器，那么会存在`/.dockerenv`这个文件

## 7.6 从容器构建镜像

**保留镜像原本的layer，每次commit都会生成一个layer，这样会导致镜像越来越大：**

```sh
docker commit <container-id> <new_image>
```

**将容器导出成单层的镜像：**

```sh
docker export <container-id> -o centos7.9.2009-my.tar
docker import centos7.9.2009-my.tar centos7.9.2009-my:latest
```

# 8 FAQ

## 8.1 k8s环境docker异常

在k8s环境中，若容器运行时用的是`docker`，那么该`docker`会依赖`containerd`，当`containerd`不正常的时候，`docker`也就不正常了。恢复`containerd`的办法：将`/var/lib/containerd/io.containerd.metadata.v1.bolt`这个文件删掉

## 8.2 read unix @->/var/run/docker.sock: read: connection reset by peer

1. 没有权限
1. 多套`docker`共用了同一个`/var/run/docker.sock`套接字文件，可以用`lsof -U | grep docker.sock`查看。默认情况下只有2个记录，一个是`systemd`的，另一个是`dockerd`的

# 9 参考

* [Docker Hub](https://hub.docker.com/)
* [Docker历史版本下载](https://docs.docker.com/docker-for-mac/release-notes/#docker-community-edition-17120-ce-mac49-2018-01-19)
* [Docker](https://www.docker.com/)
* [Docker Command](https://docs.docker.com/engine/reference/commandline/docker/)
* [Docker 教程](http://www.runoob.com/docker/docker-tutorial.html)
* [Docker 原理篇](https://www.jianshu.com/p/7a58ad7fade4)
* [深入分析Docker镜像原理](https://www.csdn.net/article/2015-08-21/2825511)
* [Docker之Dockerfile语法详解](https://www.jianshu.com/p/690844302df5)
* [docker容器与虚拟机有什么区别？](https://www.zhihu.com/question/48174633)
* [docker与虚拟机性能比较](https://blog.csdn.net/cbl709/article/details/43955687)
* [RunC 简介](http://www.cnblogs.com/sparkdev/p/9032209.html)
* [Containerd 简介](http://www.cnblogs.com/sparkdev/p/9063042.html)
* [从 docker 到 runC](https://www.cnblogs.com/sparkdev/p/9129334.html)
* [jib](https://github.com/GoogleContainerTools/jib)
* [探讨Docker容器中修改系统变量的方法](https://tonybai.com/2014/10/14/discussion-on-the-approach-to-modify-system-variables-in-docker/)
* [What is the difference between CMD and ENTRYPOINT in a Dockerfile?](https://stackoverflow.com/questions/21553353/what-is-the-difference-between-cmd-and-entrypoint-in-a-dockerfile)
* [Sharing Network Namespaces in Docker](https://blog.mikesir87.io/2019/03/sharing-network-namespaces-in-docker/)
* [x86机器上运行arm64 docker](https://blog.csdn.net/xiang_freedom/article/details/92724299)
* [github-qemu](https://github.com/multiarch/qemu-user-static/releases)
* [跨平台构建 Docker 镜像](https://juejin.cn/post/6844903605355577358)
* [跨平台构建 Docker 镜像新姿势，x86、arm 一把梭](https://cloud.tencent.com/developer/article/1543689)
* [QEMU和KVM的关系](https://zhuanlan.zhihu.com/p/48664113)
* [dockerslim](https://dockersl.im/)
* [第三章 Docker容器的生命周期](https://www.jianshu.com/p/442b726f8cca)
