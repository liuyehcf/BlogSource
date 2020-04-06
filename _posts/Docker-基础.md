---
title: Docker-基础
date: 2018-01-19 13:18:39
tags: 
- 摘录
categories: 
- Java
- Isolation Technology
---

__阅读更多__

<!--more-->

# 1 创建镜像

__创建一个空的目录__，例如`/tmp/test`

__创建Dockerfile（核心）__

1. __FROM：用于指定一个基础镜像__
    * 一般情况下一个可用的Dockerfile一定是FROM作为第一个指令。至于image则可以是任何合理存在的image镜像
    * `FROM`一定是首个非注释指令Dockerfile
    * `FROM`可以在一个Dockerfile中出现多次，以便于创建混合images
    * 如果没有指定tag，latest将会被指定为要使用的基础镜像版本
1. __MAINTAINER：用于指定镜像制作者的信息__
1. __RUN：创建镜像时执行的命令（RUN命令产生的作用是会被持久化到创建的镜像中的）__
    * 层级`RUN`指令和生成提交是符合Docker核心理念的做法。它允许像版本控制那样，在任意一个点，对image镜像进行定制化构建
    * `RUN`指令缓存不会在下个命令执行时自动失效。比如`RUN apt-get dist-upgrade -y`的缓存就可能被用于下一个指令
    * `--no-cache`标志可以被用于强制取消缓存使用
1. __ENV：用于为docker容器设置环境变量__
    * `ENV`设置的环境变量，可以使用`docker inspect`命令来查看。同时还可以使用`docker run --env <key>=<value>`来修改环境变量
1. __USER：用来切换运行属主身份__
    * Docker默认是使用root
1. __WORKDIR：用于切换工作目录__
    * Docker默认的工作目录是`/`，只有`RUN`能执行cd命令切换目录，而且还只作用在当下的`RUN`，也就是说每一个`RUN`都是独立进行的
    * 如果想让其他指令在指定的目录下执行，就得靠`WORKDIR``WORKDIR`动作的目录改变是持久的，不用每个指令前都使用一次`WORKDIR`
1. __COPY：将文件从路径`<src>`复制添加到容器内部路径`<dest>`__
    * `<src>`必须是想对于源文件夹的一个文件或目录，也可以是一个远程的url
    * `<dest>`是目标容器中的绝对路径
    * 所有的新文件和文件夹都会创建UID和GID。事实上如果`<src>`是一个远程文件URL，那么目标文件的权限将会是600
1. __ADD：将文件从路径`<src>`复制添加到容器内部路径`<dest>`__
    * `<src>`必须是想对于源文件夹的一个文件或目录，也可以是一个远程的url
    * `<dest>`是目标容器中的绝对路径
    * 所有的新文件和文件夹都会创建UID和GID。事实上如果`<src>`是一个远程文件URL，那么目标文件的权限将会是600
1. __VOLUME：创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保持的数据等__
1. __EXPOSE：指定在docker允许时指定的端口进行转发__
1. __CMD：启动容器时执行的命令__
    * Dockerfile中只能有一个CMD指令。如果你指定了多个，那么只有最后个CMD指令是生效的
    * 可以被`docker run $image $other_command`中的`$other_command`覆盖
1. __ONBUILD：让指令延迟執行__
    * 延迟到下一个使用`FROM`的Dockerfile在建立image时执行，只限延迟一次
1. __ARG：定义仅在建立image时有效的变量__
1. __ENTRYPOINT：指定Docker image运行成instance(也就是 Docker container)时，要执行的命令或者文件__
    * 默认的`ENTRYPOINT`是`/bin/sh -c`，但是没有默认的`CMD`
    * 当执行`docker run -i -t ubuntu bash`，默认的`ENTRYPOINT`就是`/bin/sh -c`，且`CMD`就是`bash`
    * __`CMD`本质上就是`ENTRYPOINT`的参数__

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

__requirements.txt（上面的Dockerfile中的Run命令用到了这个文件）__

```
Flask
Redis
```

__app.py__

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

__创建镜像：`docker build -t friendlyhello .`__

__运行应用：`docker run -p 4000:80 friendlyhello`__

# 2 docker命令行工具

学会利用`--help`参数

```sh
docker --help # 查询所有顶层的参数
docker image --help # 参数image参数的子参数
```

# 3 Alpine

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

# 4 Jib

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

## 4.1 修改系统变量

# 5 Tips

1. 启动并保持容器运行
    * 可以执行一个不会终止的程序：`docker run -dit xxx:v1`
    * 启动的同时，开启一个bash：`docker run -it 9a88e0029e3b /bin/bash`
1. 在主机与Docker容器之间拷贝文件
    * `docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH|-`
    * `docker cp [OPTIONS] SRC_PATH|- CONTAINER:DEST_PATH`
1. 打开`D-Bus connection`
    * `docker run -d -e "container=docker" --privileged=true [ID] /usr/sbin/init`
    * 容器启动的`CMD`包含`/usr/sbin/init`即可
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

# 6 参考

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