---
title: HTTPS协议
date: 2017-09-01 21:01:23
tags: 
- 摘录
categories: 
- Network
- HTTP
---

**阅读更多**

<!--more-->

# 1 HTTP协议存在的问题

HTTP协议存在以下问题

1. **容易被监听**：HTTP通信都是明文，数据在客户端与服务器通信过程中，任何一点都可能被劫持。比如，发送了银行卡号和密码，hacker劫取到数据，就能看到卡号和密码，这是很危险的
1. **被伪装**：HTTP通信时，无法保证通行双方是合法的，通信方可能是伪装的。比如你请求www.taobao.com，你怎么知道返回的数据就是来自淘宝，中间人可能返回数据伪装成淘宝
1. **被篡改**：hacker中间篡改数据后，接收方并不知道数据已经被更改

# 2 HTTPS解决的问题

HTTPS很好的解决了HTTP的三个缺点（被监听、被篡改、被伪装），HTTPS不是一种新的协议，它是HTTP+SSL(Secure Sockets Layer)或TLS(Transport Layer Security)的结合体，SSL是一种独立协议，所以其它协议比如smtp等也可以跟ssl结合。HTTPS改变了通信方式，它由以前的HTTP—–>TCP，改为HTTP——>SSL—–>TCP；HTTPS采用了共享密钥加密+公开密钥加密的方式

1. **防监听**：数据是加密的，所以监听得到的数据是密文，hacker看不懂
1. **防伪装**：伪装分为客户端伪装和服务器伪装，通信双方携带证书，证书相当于身份证，有证书就认为合法，没有证书就认为非法，证书由第三方颁布，很难伪造
1. **防篡改**：HTTPS对数据做了摘要，篡改数据会被感知到。hacker即使从中改了数据也白搭

# 3 HTTPS连接过程

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
client->server: 发送客户端支持的加密协议以及版本，例如SSL，TLS
server->server: 服务器端从中筛选合适的加密协议
server->client: 服务器端返回证书，证书中有公钥
client->client: 客户端使用根证书验证证书合法性
client->server: 客户端生成对称密钥，通过证书中的公钥加密，发送到服务端
server->client: 服务器端使用私钥解密，获取对称密钥，使用对称密钥加密数据
client->server: 客户端解密数据，SSL开始通信
```

# 4 证书

**什么是根证书**：根证书是**证书颁发机构(CA)**给自己颁发的证书，是信任链的起始点。安装根证书意味着对这个CA认证中心的信任(类似并查集？)

**数字签名与摘要**：简单的来说，"摘要"就是对传输的内容，通过hash算法计算出一段固定长度的串。然后，在通过**CA的私钥**对这段摘要进行加密，加密后得到的结果就是"数字签名"
```
明文->hash运算->摘要->CA私钥加密->数字签名
```

**证书包含如下内容**

1. 证书包含了颁发证书的机构的名字--CA
1. 证书内容本身的数字签名(用**CA私钥**对摘要加密后的结果)
1. 证书持有者的公钥
1. 证书签名用到的hash算法

**如果证书被伪造**

1. 证书颁发的机构(CA)是伪造的：浏览器不认识，直接认为是危险证书
1. 证书颁发的机构确实存在，于是根据CA名，找到对应内置的CA根证书，CA公钥
1. 用CA公钥，对伪造的证书的摘要进行解密，发现解不了。认为是危险证书

**如果证书被篡改**

1. 检查证书，根据CA名，找到对应的CA根证书，以及CA的公钥
1. 用CA的公钥，对证书的数字签名进行解密，得到对应的证书摘要AA
1. 根据证书签名使用hash算法，计算出当前证书的摘要BB
1. 对比AA跟BB，如果发现不一致就判定为危险证书

# 5 其他思考

**怎样保证公开密钥的有效性**：你也许会想到，怎么保证客户端收到的公开密钥是合法的，不是伪造的，证书很好的完成了这个任务。证书由权威的第三方机构颁发，并且对公开密钥做了签名
**HTTPS的缺点**：HTTPS保证了通信的安全，但带来了加密解密消耗计算机cpu资源的问题，不过，有专门的HTTPS加解密硬件服务器
**各大互联网公司，百度、淘宝、支付宝、知乎都使用HTTPS协议，为什么？**：支付宝涉及到金融，所以出于安全考虑采用HTTPS这个，可以理解，为什么百度、知乎等也采用这种方式？为了防止运营商劫持！http通信时，运营商在数据中插入各种广告，用户看到后，怒火发到互联网公司，其实这些坏事都是运营商(移动、联通、电信)干的，用了HTTPS，运营商就没法插播广告篡改数据了

# 6 参考

* [HTTPS 建立连接过程](HTTP://blog.csdn.net/wangjun5159/article/details/51510594)
* [SSL与TLS的区别以及介绍](http://kb.cnblogs.com/page/197396/)
* [详解HTTPS是如何确保安全性的？](http://www.jianshu.com/p/544c0a2d47f4)
* [数字证书原理](https://www.cnblogs.com/JeffreySun/archive/2010/06/24/1627247.html)

