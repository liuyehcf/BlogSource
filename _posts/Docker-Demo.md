---
title: Docker-Demo
date: 2018-01-19 13:18:39
tags: 
- 摘录
categories: 
- Java
- 隔离技术
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

下面给出几个常用的命令

```sh
```

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [docker](https://www.docker.com/)
* [Docker 教程](http://www.runoob.com/docker/docker-tutorial.html)
* [Docker 原理篇](https://www.jianshu.com/p/7a58ad7fade4)
* [深入分析Docker镜像原理](https://www.csdn.net/article/2015-08-21/2825511)
* [Docker之Dockerfile语法详解](https://www.jianshu.com/p/690844302df5)
