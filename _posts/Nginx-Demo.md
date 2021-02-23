---
title: Nginx-Demo
date: 2019-10-13 16:58:45
tags: 
- 原创
categories: 
- Web
- Oauth
---

**阅读更多**

<!--more-->

# 1 匹配规则

优先级从上到下

1. `location =`：精确匹配
1. `location <absolute path>`：完整路径
1. `location ^~ <path>`：以某个字符串开头，非正则
1. `location ~|~* <regex>`：正则匹配，`~`表示大小写敏感，`~*`表示大小写不敏感
1. `location <relative path>`：相对路径
1. `location /`：通用匹配

# 2 配置示例

```nginx
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;
		root   /Users/hechenfeng/resources;
		index index.html;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
        }

        location ~ /api/ {
            proxy_pass http://localhost:8080;
        }

        location ~ \.html$ {
            proxy_pass http://localhost:8080;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        # error_page   500 502 503 504  /50x.html;
        # location = /50x.html {
        #     root   html;
        # }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }

    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}
    include servers/*;
```

# 3 DockerFile

```
FROM centos:7.5.1804

WORKDIR /

ADD ./nginx-1.8.0.tar.gz /

RUN yum install -y net-tools.x86_64
RUN yum install -y sudo
RUN yum install -y vim

# install nginx
# 安装后，配置文件位置 /usr/local/nginx/conf
# 安装后，nginx二进制文件的位置 /usr/local/nginx/sbin/nginx
RUN yum install -y gcc-c++
RUN yum install -y pcre pcre-devel
RUN yum install -y zlib zlib-devel
RUN yum install -y openssl openssl-devel
RUN cd nginx-1.8.0 && ./configure \
    --prefix=/usr/local/nginx \
    --pid-path=/var/run/nginx/nginx.pid \
    --lock-path=/var/lock/nginx.lock \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --with-http_gzip_static_module \
    --http-client-body-temp-path=/var/temp/nginx/client \
    --http-proxy-temp-path=/var/temp/nginx/proxy \
    --http-fastcgi-temp-path=/var/temp/nginx/fastcgi \
    --http-uwsgi-temp-path=/var/temp/nginx/uwsgi \
    --http-scgi-temp-path=/var/temp/nginx/scgi && make && make install
RUN mkdir -p /var/temp/nginx/client
RUN cp /usr/local/nginx/sbin/nginx /usr/local/bin
```

# 4 文件路径

## 4.1 Mac

配置文件：`/usr/local/etc/nginx/nginx.conf`
日志：`/usr/local/var/log/nginx`

# 5 参考

* [下载地址](http://nginx.org/download/)
* [匹配规则示例](https://www.cnblogs.com/qinyujie/p/8979464.html)
* [配置详解](https://www.cnblogs.com/luyucheng/p/6149926.html)
* [匹配顺序](https://www.jianshu.com/p/38810b49bc29)
