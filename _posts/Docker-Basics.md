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

# 1 Installation

## 1.1 CentOS

```sh
# --step 1: install dependent softwares
yum install -y yum-utils device-mapper-persistent-data lvm2
# --step 2: add repo
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
# --step 3
sed -i 's+download.docker.com+mirrors.aliyun.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
# --step 4: install docker
yum list docker-ce --showduplicates | sort -r
yum makecache fast
yum -y install docker-ce-20.10.5-3.el7
# --step 5: enable docker service
systemctl enable docker
systemctl start docker
```

## 1.2 Ubuntu

[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

## 1.3 MacOS (Apple Chip)

Colima runs a minimal Linux VM using Lima under the hood. Docker Engine runs inside that VM. The Docker CLI talks to it through a Unix socket just like Docker Desktop would.

```sh
brew install docker
brew install colima
colima start
# colima start --memory 4 --cpu 2 --disk 60
docker version
```

### 1.3.1 colima

Colima (short for Container on Lima) is a fast, lightweight Docker and Kubernetes runtime for macOS and Linux that provides a Docker-compatible environment using a virtual machine under the hood — specifically Lima (Linux virtual machines).

It's often used as a drop-in replacement for Docker Desktop — especially after Docker Desktop introduced licensing changes in 2022.

**Commands:**

* `colima status`
* `colima list`
* `colima ssh`
* `colima start --cpu 6 --memory 8 --disk 100`
* `colima stop`
* `colima start --edit`

# 2 Container Lifecycle

![container_lifecycle](/images/Docker-Basics/container_lifecycle.webp)

# 3 Filesystem

## 3.1 overlay2

[Example OverlayFS Usage [duplicate]](https://askubuntu.com/questions/699565/example-overlayfs-usage)

# 4 Build Image

**Write `Dockerfile`**

1. **`FROM`: Specifies a base image**
    * In most cases, a valid Dockerfile starts with a `FROM` instruction.
    * `FROM` must be the first non-comment instruction in a Dockerfile.
    * `FROM` can appear multiple times in a Dockerfile to create multi-stage builds.
    * If no tag is specified, `latest` will be used as the default version of the base image.
1. **`MAINTAINER`: Specifies the author of the image**
    * (Note: This instruction is deprecated. Use a `LABEL` instead to define metadata such as the maintainer.)
1. **`RUN`: Executes commands during image build**
    * `RUN` instructions create intermediate image layers and are persisted in the final image.
    * Layered `RUN` instructions support Docker's core philosophy of image versioning and reproducibility.
    * `RUN` command cache is not invalidated automatically in the next instruction. For example, a cached `RUN apt-get dist-upgrade -y` might be reused.
    * Use the `--no-cache` flag to force disable caching.
1. **`ENV`: Sets environment variables inside the Docker container**
    * Environment variables set by `ENV` can be viewed using the `docker inspect` command.
    * These variables can also be overridden at runtime using `docker run --env <key>=<value>`.
1. **`ARG`: Defines environment variables that are available only during the image build**
    * Available only during `docker build`, not persisted in the final image.
    * Values can be passed with `--build-arg <key>=<value>` when building the image.
1. **`USER`: Changes the user under which the container runs**
    * By default, Docker containers run as the `root` user.
1. **`WORKDIR`: Sets the working directory for instructions that follow**
    * The default working directory is `/`. While `cd` can be used within `RUN`, it only affects the current `RUN` instruction.
    * `WORKDIR` changes are persistent and apply to all following instructions, so you don't need to repeat `WORKDIR` for each command.
1. **`COPY`: Copies files or directories from `<src>` on the host to `<dest>` in the container**
    * `<src>` must be a path relative to the build context, or a file/dir.
    * `<dest>` must be an absolute path inside the container.
    * All copied files/folders are assigned UID and GID. If `<src>` is a remote URL, the destination file permissions default to 600.
1. **`ADD`: Similar to `COPY`, but with extended features**
    * `<src>` can be a file, directory, or a remote URL.
    * `<dest>` is an absolute path inside the container.
    * Files are assigned UID and GID. If `<src>` is a remote URL, permissions default to 600.
    * `ADD` can also auto-extract local tar archives, which `COPY` cannot.
1. **`VOLUME`: Creates a mount point for external storage (host or other containers)**
    * Commonly used for databases or persistent data.
1. **`EXPOSE`: Informs Docker that the container listens on the specified port**
    * Does not publish the port itself; it only serves as documentation or for use with Docker networking.
1. **`CMD`: Provides default command to run when the container starts**
    * Only one `CMD` instruction is allowed per Dockerfile; if multiple are specified, only the last one is used.
    * Can be overridden by passing a command when running the container: `docker run $image $override_command`.
1. **`ENTRYPOINT`: Configures a container to run as an executable**
    * The default `ENTRYPOINT` is `/bin/sh -c`, but there is no default `CMD`.
    * For example, in `docker run -i -t ubuntu bash`, the default `ENTRYPOINT` is `/bin/sh -c` and the `CMD` is `bash`.
    * **CMD essentially acts as arguments to ENTRYPOINT**.
1. **`ONBUILD`: Defers the execution of instructions**
    * These instructions are triggered when the resulting image is used as a base image in another build.
    * Each ONBUILD instruction is triggered only once.

## 4.1 Relative Path in a Dockerfile

**In Dockerfiles, relative paths (like `./myfile.txt` or `src/`) are always relative to the build context. The build context is the directory you specify when you run (Here, the `<path-to-context>` is the build context.):**

* `docker build -t <image> <path-to-context>`

**Docker will throw an error if `COPY` or `ADD` refers to something outside the build context, like `../secret.txt`.**

## 4.2 Demo

```sh
mkdir -p friendlyhello
cd friendlyhello

cat > Dockerfile << 'EOF'
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
EOF

cat > requirements.txt << 'EOF'
Flask
Redis
EOF

cat > app.py << 'EOF'
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
EOF

docker build -t friendlyhello .

docker run -p 4000:80 friendlyhello
```

# 5 Frequently-Used Images

## 5.1 alpine

Alpine Linux is a lightweight Linux distribution. Unlike typical Linux distributions, Alpine uses musl libc and BusyBox to reduce system size and runtime resource usage. Alpine Linux provides its own package manager: apk.

Here's an example of how to build a Docker image with bash.

```docker
FROM alpine:3.10.2

MAINTAINER Rethink 
# update repo
RUN echo "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/main/" > /etc/apk/repositories

RUN apk update \
        && apk upgrade \
        && apk add --no-cache bash \
        bash-doc \
        bash-completion \
        && rm -rf /var/cache/apk/* \
        && /bin/bash

# Solving the Timezone Issue (For Alpine images, setting the environment variable TZ=Asia/Shanghai alone is not sufficient)
RUN apk add -U tzdata
```

## 5.2 jib

```xml
            <plugin>
                <groupId>com.google.cloud.tools</groupId>
                <artifactId>jib-maven-plugin</artifactId>
                <version>1.6.1</version>
                <configuration>
                    <from>
                        <!-- Without this base image, the built image will not include bash -->
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
                        <!-- Without this parameter, the built image will be from 49 years ago -->
                        <useCurrentTimestamp>true</useCurrentTimestamp>
                    </container>
                </configuration>
            </plugin>
```

## 5.3 minio

```sh
docker run -d --name minio \
  -p 21900:9000 -p 21990:9090 \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=password123 \
  quay.io/minio/minio server /data --console-address ":9090"
```

```sh
mc alias set local http://localhost:9000 admin password123
```

Client tools: `aws`

* `aws s3 --endpoint http://127.0.0.1:21900 ls s3://my_bucket/file.txt`

# 6 Docker Compose

## 6.1 Install

```sh
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## 6.2 Usage

* `docker-compose [ -f <compose_file> ] [-p <project_name>] up`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] up -d`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] down`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] start`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] stop`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] restart`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] rm`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] ps`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] exec -it <service_name> bash`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] config`
* `docker-compose [ -f <compose_file> ] [-p <project_name>] config --services`

## 6.3 Tips

### 6.3.1 Find docker-compose information for given docker container

* `docker inspect <container_id> | grep 'com.docker.compose'`

# 7 Tips

1. Start and keep a container running  
    * Run a program that doesn't exit: `docker run -dit xxx:v1`  
    * Start with an interactive bash shell: `docker run -it 9a88e0029e3b /bin/bash`
1. Copy files between host and Docker container  
    * `docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-`  
    * `docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH`
1. Open a `D-Bus connection`  
    * `docker run -d -e "container=docker" --privileged=true [ID] /usr/sbin/init`  
    * The container's `CMD` should include `/usr/sbin/init`
1. Start and stop containers:  
    * `docker start <container-id>`  
    * `docker stop <container-id>`
1. Execute commands in a specific container  
    * `docker exec -ti my_container /bin/bash -c "echo a && echo b"`
1. View `pid` and `ip` of a docker container  
    * `docker inspect <container-id> | grep Pid`  
    * `docker inspect -f '{{.State.Pid}}' <container-id>`  
    * `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <container-id>`
1. Delete a specific tag  
    * `docker rmi <repository>:<tag>` — do not use the image ID
1. List all image IDs  
    * `docker images -q`
1. Save an image to a file and load from a file  
    * `docker save -o alpine.tar alpine:3.10.2`  
    * `docker load < alpine.tar`
1. Set timezone  
    * `docker run -e TZ=Asia/Shanghai ...`
1. Set kernel parameters (requires privileged mode)  
    * When writing the Dockerfile, add the kernel parameter changes to the `CMD` (you can't modify them with `RUN` since kernel files are read-only during build)  
    * Use privileged mode when starting: `docker run --privileged`
1. Use docker commands inside a container  
    * `--privileged`: use privileged mode  
    * `-v /var/run/docker.sock:/var/run/docker.sock`: mount the Docker socket file  
    * `-v $(which docker):/bin/docker`: mount the Docker CLI binary
1. Join the network namespace of another container when starting  
    * `docker run [--pid string] [--userns string] [--uts string] [--network string] <other options>`  
    * `docker run -d --net=container:<existing container id> <image id>`
1. After deleting the Docker CLI, Docker's working directory (including images) still exists. To completely remove it:  
    * `rm -rf /var/lib/docker`
1. View image build history: `docker history <img>`  
1. View image details: `docker inspect <img>`  
1. Check container resource usage: `docker stats <container>`  
1. Clean up unused images: `docker system prune -a`  
1. Grant a regular user permission to use `docker`: `sudo usermod -aG docker username`

## 7.1 Modify docker storage path

默认情况下，docker相关的数据会存储在`/var/lib/docker`。编辑配置文件`/etc/docker/daemon.json`（没有就新建），增加如下配置项：

```json
{
    "data-root": "<some path>"
}
```

然后通过`systemctl restart docker`重启docker即可

## 7.2 Modify Mirror Address

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

## 7.3 Run docker across platform

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

# 安装qemu
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

**Steps for ubuntu:**

```sh
sudo apt-get update

# Install qemu-user-static to enable emulation for different architectures
sudo apt-get install qemu-user-static

# Try to enable QEMU binary formats to support aarch64 and x86_64 architectures
sudo update-binfmts --enable qemu-aarch64
sudo update-binfmts --enable qemu-x86_64

# Install binfmt-support to provide support for the update-binfmts command
sudo apt-get install binfmt-support

# Try again to enable QEMU binary formats to support aarch64 and x86_64 architectures
sudo update-binfmts --enable qemu-aarch64
sudo update-binfmts --enable qemu-x86_64

# Run the multiarch/qemu-user-static Docker image to register QEMU for all supported architectures
sudo docker run --rm --privileged --platform linux/arm64 multiarch/qemu-user-static --reset -p yes

# Register all supported binary formats using tonistiigi/binfmt
docker run --rm --privileged tonistiigi/binfmt --install all

# Test running an amd64 container on the ARM host
docker run --platform linux/amd64 hello-world
```

## 7.4 Docker Image Prune Tools - dockerslim

```sh
docker-slim build --http-probe=false centos:7.6.1810
```

裁剪之后，镜像的体积从`202MB`变为`3.55MB`。但是裁剪之后，大部分的命令都被裁剪了（包括`ls`这种最基础的命令）

## 7.5 Be Aware of Running as a Container

一般来说，如果运行环境是容器，那么会存在`/.dockerenv`这个文件

## 7.6 Build Image from Container

**保留镜像原本的layer，每次commit都会生成一个layer，这样会导致镜像越来越大：**

```sh
docker commit <container-id> <new_image>
```

**将容器导出成单层的镜像：**

```sh
docker export <container-id> -o centos7.9.2009-my.tar
docker import centos7.9.2009-my.tar centos7.9.2009-my:latest
```

## 7.7 Setup Http Proxy

Add file `/etc/systemd/system/docker.service.d/http-proxy.conf` with following content:

```sh
[Service]
Environment="HTTPS_PROXY=xxx"
Environment="HTTP_PROXY=xxx"
Environment="NO_PROXY=localhost,127.0.0.1,yyy"
```

Check and restart

```sh
systemctl daemon-reload
systemctl show docker --property Environment
systemctl restart docker
```

## 7.8 Access Host Ip from Container

The host has a changing IP address, or none if you have no network access. We recommend that you connect to the special DNS name `host.docker.internal`, which resolves to the internal IP address used by the host.

## 7.9 How to delete exited containers

```sh
docker ps -a -f status=exited -q | xargs docker rm -f
```

## 7.10 How to create container with host user

```sh
docker run --user $(id -u):$(id -g) -v /etc/passwd:/etc/passwd
```

## 7.11 Find containers using network

```sh
docker network inspect <ns-name>
```

## 7.12 Config Path

1. Client: `~/.docker/config.json`
1. Daemon: `/etc/docker/daemon.json`

# 8 FAQ

## 8.1 K8S Env docker error

在k8s环境中，若容器运行时用的是`docker`，那么该`docker`会依赖`containerd`，当`containerd`不正常的时候，`docker`也就不正常了。恢复`containerd`的办法：将`/var/lib/containerd/io.containerd.metadata.v1.bolt`这个文件删掉

## 8.2 read unix @->/var/run/docker.sock: read: connection reset by peer

1. 没有权限
1. 多套`docker`共用了同一个`/var/run/docker.sock`套接字文件，可以用`lsof -U | grep docker.sock`查看。默认情况下只有2个记录，一个是`systemd`的，另一个是`dockerd`的

# 9 Reference

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
