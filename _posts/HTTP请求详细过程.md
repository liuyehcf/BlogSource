---
title: HTTP请求详细过程
date: 2017-08-12 13:13:35
tags: 
- 摘录
categories: 
- Web
- HTTP
---

__阅读更多__

<!--more-->

# 1 在浏览器里输入网址

这一步没什么好说的，就输入一个网址，例如`http://facebook.com`

# 2 浏览器根据域名解析IP地址

浏览器根据访问的域名找到其IP地址。DNS查找过程如下：

1. 浏览器缓存：浏览器会缓存DNS记录一段时间。但操作系统没有告诉浏览器储存DNS记录的时间，这样不同浏览器会储存个自固定的一个时间（2分钟到30分钟不等）
1. 系统缓存：如果在浏览器缓存里没有找到需要的域名，浏览器会做一个系统调用（windows里是gethostbyname），这样便可获得系统缓存中的记录
1. 路由器缓存：如果系统缓存也没找到需要的域名，则会向路由器发送查询请求，它一般会有自己的DNS缓存
1. ISP DNS缓存：如果依然没找到需要的域名，则最后要查的就是ISP缓存DNS的服务器。在这里一般都能找到相应的缓存记录

# 3 浏览器与web服务器建立一个TCP连接

在HTTP工作开始之前，Web浏览器首先要通过网络与Web服务器建立连接，该连接是通过TCP来完成的，该协议与IP协议共同构建Internet，即著名的TCP/IP协议族，因此Internet又被称作是TCP/IP网络。HTTP是比TCP更高层次的应用层协议，根据规则，只有低层协议建立之后才能，才能进行更层协议的连接，因此，首先要建立TCP连接，一般TCP连接的端口号是80

# 4 浏览器给Web服务器发送一个http请求

一个http请求报文由请求行`<request-line>`、请求头部`<headers>`、空行`＜blank-line＞`和请求数据`＜request-body＞`4个部分组成

![fig1](/images/HTTP请求详细过程/fig1.png)

## 4.1 请求行

__请求行：由请求方法、URL和HTTP协议版本3个字段组成，它们用空格分隔__。例如，GET /index.html HTTP/1.1。HTTP协议的请求方法有GET、POST、HEAD、PUT、DELETE、OPTIONS、TRACE、CONNECT

## 4.2 请求头部

请求头部：由关键字/值对组成，每行一对，关键字和值用英文冒号":"分隔。请求头部通知服务器有关于客户端请求的信息，典型的请求头有：

1. User-Agent：产生请求的浏览器类型
1. Accept：客户端可识别的内容类型列表。星号`" * "`用于按范围将类型分组，用`" */* "`指示可接受全部类型，用`" type/* "`指示可接受`type`类型的所有子类型
1. Host：要请求的主机名，允许多个域名同处一个IP地址，即虚拟主机
1. Accept-Language：客户端可接受的自然语言
1. Accept-Encoding：客户端可接受的编码压缩格式
1. Accept-Charset：可接受的应答的字符集
1. connection：连接方式(close 或 keepalive)
1. Cookie：存储于客户端扩展字段，向同一域名的服务端发送属于该域的cookie

## 4.3 空行

空行：最后一个请求头部之后是一个空行，发送回车符和换行符，通知服务器以下不再有请求头部

## 4.4 请求数据

请求数据：请求数据不在GET方法中使用，而在POST方法中使用。POST方法适用于需要客户填写表单的场合。与请求数据相关的最常使用的请求头部是Content-Type和Content-Length

## 4.5 请求报文示例

```
POST /search HTTP/1.1  
Accept: image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/vnd.ms-excel, application/vnd.ms-powerpoint, 
application/msword, application/x-silverlight, application/x-shockwave-flash, */*  
Referer: <a href="http://www.google.cn/">http://www.google.cn/</a>  
Accept-Language: zh-cn  
Accept-Encoding: gzip, deflate  
User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727; TheWorld)  
Host: <a href="http://www.google.cn">www.google.cn</a>  
Connection: Keep-Alive  
Cookie: PREF=ID=80a06da87be9ae3c:U=f7167333e2c3b714:NW=1:TM=1261551909:LM=1261551917:S=ybYcq2wpfefs4V9g; 
NID=31=ojj8d-IygaEtSxLgaJmqSjVhCspkviJrB6omjamNrSm8lZhKy_yMfO2M4QMRKcH1g0iQv9u-2hfBW7bUFwVh7pGaRUb0RnHcJU37y-
FxlRugatx63JLv7CWMD6UB_O_r  

hl=zh-CN&source=hp&q=domety  
```

# 5 服务器的永久重定向响应

服务器给浏览器响应一个301永久重定向响应，这样浏览器就会访问"http://www.facebook.com/"而非"http://facebook.com/"。为什么服务器一定要重定向而不是直接发送用户想看的网页内容呢？其中一个原因跟搜索引擎排名有关。如果一个页面有两个地址，就像http://www.igoro.com/和http://igoro.com/，搜索引擎会认为它们是两个网站，结果造成每个搜索链接都减少从而降低排名。而搜索引擎知道301永久重定向是什么意思，这样就会把访问带www的和不带www的地址归到同一个网站排名下。还有就是用不同的地址会造成缓存友好性变差，当一个页面有好几个名字时，它可能会在缓存里出现好几次

一个http响应报文由状态行`<status-line>`、响应头部`<headers>`、空行`＜blank-line＞`和响应数据`＜response-body＞`4个部分组成，响应报文的一般格式如下图：

![fig2](/images/HTTP请求详细过程/fig2.png)

## 5.1 状态行

状态行：由HTTP协议版本、服务器返回的响应状态码和响应状态码的文本描述组成

状态代码由三位数字组成，第一个数字定义了响应的类别，且有五种可能取值

1. __1xx - 信息性状态码__：表示服务器已接收了客户端请求，客户端可继续发送请求
    * 100 Continue
    * 101 Switching Protocols
1. __2xx - 成功状态码__：表示服务器已成功接收到请求并进行处理
    * 200 OK 表示客户端请求成功
    * 204 No Content 成功，但不返回任何实体的主体部分
    * 206 Partial Content 成功执行了一个范围（Range）请求
1. __3xx - 重定向状态码__：表示服务器要求客户端重定向
    * 301 Moved Permanently 永久性重定向，响应报文的Location首部应该有该资源的新URL
    * 302 Found 临时性重定向，响应报文的Location首部给出的URL用来临时定位资源
    * 303 See Other 请求的资源存在着另一个URI，客户端应使用GET方法定向获取请求的资源
    * 304 Not Modified 客户端发送附带条件的请求（请求首部中包含如If-Modified-Since等指定首部）时，服务端有可能返回304，此时，响应报文中不包含任何报文主体
    * 307 Temporary Redirect 临时重定向。与302 Found含义一样。302禁止POST变换为GET，但实际使用时并不一定，307则更多浏览器可能会遵循这一标准，但也依赖于浏览器具体实现
1. __4xx - 客户端错误状态码__：表示客户端的请求有非法内容
    * 400 Bad Request 表示客户端请求有语法错误，不能被服务器所理解
    * 401 Unauthonzed 表示请求未经授权，该状态代码必须与WWW-Authenticate 报头域一起使用
    * 403 Forbidden 表示服务器收到请求，但是拒绝提供服务，通常会在响应正文中给出不提供服务的原因
    * 404 Not Found 请求的资源不存在，例如，输入了错误的URL
1. __5xx - 服务器错误状态码__：表示服务器未能正常处理客户端的请求而出现意外错误
    * 500 Internel Server Error 表示服务器发生不可预期的错误，导致无法完成客户端的请求
    * 503 Service Unavailable 表示服务器当前不能够处理客户端的请求，在一段时间之后，服务器可能会恢复正常

## 5.2 响应头部

响应头部：由关键字/值对组成，每行一对，关键字和值用英文冒号":"分隔，典型的响应头有：

1. __Location__：用于重定向接受者到一个新的位置。例如：客户端所请求的页面已不存在原先的位置，为了让客户端重定向到这个页面新的位置，服务器端可以发回Location响应报头后使用重定向语句，让客户端去访问新的域名所对应的服务器上的资源
1. __Server__：包含了服务器用来处理请求的软件信息及其版本。它和User-Agent请求报头域是相对应的，前者发送服务器端软件的信息，后者发送客户端软件(浏览器)和操作系统的信息
1. __Vary__：指示不可缓存的请求头列表
1. __Connection__：连接方式
    * 对于请求来说：close(告诉WEB服务器或者代理服务器，在完成本次请求的响应后，断开连接，不等待本次连接的后续请求了)。keepalive(告诉WEB服务器或者代理服务器，在完成本次请求的响应后，保持连接，等待本次连接的后续请求);
    * 对于响应来说：close(连接已经关闭)；keepalive(连接保持着，在等待本次连接的后续请求)；Keep-Alive：如果浏览器请求保持连接，则该头部表明希望WEB服务器保持连接多长时间(秒)，例如：Keep-Alive：300
1. __WWW-Authenticate__：必须被包含在401(未授权的)响应消息中，这个报头域和前面讲到的Authorization请求报头域是相关的，当客户端收到401响应消息，就要决定是否请求服务器对其进行验证。如果要求服务器对其进行验证，就可以发送一个包含了Authorization报头域的请求

## 5.3 空行

空行：最后一个响应头部之后是一个空行，发送回车符和换行符，通知浏览器以下不再有响应头部

## 5.4 响应数据

响应数据：服务器返回给客户端的文本信息

## 5.5 响应报文示例

```
HTTP/1.1 301 Moved Permanently
Cache-Control: private, no-store, no-cache, must-revalidate, post-check=0,
pre-check=0
Expires: Sat, 01 Jan 2000 00:00:00 GMT
Location: <a target=_blank href="http://www.facebook.com/">http://www.facebook.com/</a>
P3P: CP="DSP LAW"
Pragma: no-cache
Set-Cookie: made_write_conn=deleted; expires=Thu, 12-Feb-2009 05:09:50 GMT;
path=/; domain=.facebook.com; httponly
Content-Type: text/html; charset=utf-8
X-Cnection: close
Date: Fri, 12 Feb 2010 05:09:51 GMT
Content-Length: 0
```

# 6 浏览器跟踪重定向地址

现在浏览器知道了"HTTP://www.facebook.com/"才是要访问的正确地址，所以它会发送另一个http请求

# 7 服务器"处理"请求

服务器接收到获取请求，然后处理并返回一个响应。这表面上看起来是一个顺向的任务，但其实这中间发生了很多有意思的东西，就像作者博客这样简单的网站，何况像facebook那样访问量大的网站呢！web服务器软件（像IIS和阿帕奇）接收到HTTP请求，然后确定执行某一请求处理来处理它。请求处理就是一个能够读懂请求并且能生成HTML来进行响应的程序（像ASP.NET，PHP，RUBY...）

# 8 服务器发回一个HTML响应

# 9 释放TCP连接

若connection模式为close，则服务器主动关闭TCP连接，客户端被动关闭连接，释放TCP连接

若connection模式为keepalive，则该连接会保持一段时间，在该时间内可以继续接收请求

# 10 客户端浏览器解析HTML内容

客户端将服务器响应的html文本解析并显示

# 11 浏览器获取嵌入在HTML中的对象

在浏览器显示HTML时，它会注意到需要获取其他地址内容的标签。这时浏览器会发送一个获取请求来重新获得这些文件。这些地址都要经历一个和HTML读取类似的过程。所以浏览器会在DNS中查找这些域名，发送请求，重定向等等

# 12 参考

* [http请求与响应全过程](http://www.mamicode.com/info-detail-1357508.html)
