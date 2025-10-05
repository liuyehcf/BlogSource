---
title: Protocol-SSL
date: 2018-12-02 18:41:43
tags: 
- 摘录
categories: 
- Network
- HTTP
---

**阅读更多**

<!--more-->

# 1 SSL协议特性

## 1.1 SNI

本小节内容转载自[HTTPS之SNI介绍](https://blog.51cto.com/zengestudy/2170245)

早期的`SSLv2`根据经典的公钥基础设施`PKI(Public Key Infrastructure)`设计，它默认认为：一台服务器（或者说一个IP）只会提供一个服务，所以在SSL握手时，服务器端可以确信客户端申请的是哪张证书

但是让人万万没有想到的是，虚拟主机大力发展起来了，这就造成了一个IP会对应多个域名的情况。解决办法有一些，例如申请泛域名证书，对所有`*.yourdomain.com`的域名都可以认证，但如果你还有一个`yourdomain.net`的域名，那就不行了。

在HTTP协议中，请求的域名作为主机头（Host）放在`HTTP Header`中，所以服务器端知道应该把请求引向哪个域名，但是早期的SSL做不到这一点，因为在SSL握手的过程中，根本不会有Host的信息，所以服务器端通常返回的是配置中的第一个可用证书。因而一些较老的环境，可能会产生多域名分别配好了证书，但返回的始终是同一个

既然问题的原因是在SSL握手时缺少主机头信息，那么补上就是了。

**`SNI（Server Name Indication）`定义在RFC 4366，是一项用于改善`SSL/TLS`的技术，在`SSLv3/TLSv1`中被启用。它允许客户端在发起SSL握手请求时（具体说来，是客户端发出SSL请求中的ClientHello阶段），就提交请求的Host信息，使得服务器能够切换到正确的域并返回相应的证书**

要使用SNI，需要客户端和服务器端同时满足条件，幸好对于现代浏览器来说，大部分都支持`SSLv3/TLSv1`，所以都可以享受SNI带来的便利

# 2 证书

## 2.1 证书格式

| 格式名称 | 格式后缀 | 文件格式 | 描述 |
|:--|:--|:--|:--|:--|
| `DER(Distinguished Encoding Rules)` | `.der/.cer` | 二进制格式 | 只保存证书，不保存私钥</br>Java和Windows服务器偏向于使用这种编码格式 |
| `PEM(Privacy-Enhanced Mail)` | `.pem` | 文本格式 | 可保存证书，也可保存私钥</br>以`-----BEGIN...`开头，以`-----END...`结尾。中间的内容是`BASE64`编码</br>有时我们也把PEM格式的私钥的后缀改为`.key`以区别证书与私钥 |
| `CRT(Certificate)` | `.crt` | 二进制格式/文本格式 | 可保存证书，也可保存私钥</br>有可能是PEM编码格式，也可能是DER编码格式 |
| `PFX(Predecessor of PKCS#12)` | `.pfx/.P12` | 二进制格式 | 同时包含证书和私钥，一般有密码保护</br>证书和私钥存在一个PFX文件中</br>一般用于Windows上的IIS服务器 |
| `JPS(Java Key Storage)` | `.jks` | 二进制格式 | 同时包含证书和私钥，一般有密码保护</br>Java的专属格式，可以用keytool进行格式转换</br>一般用于Tomcat服务器 |

### 2.1.1 X.509

X.509是公钥证书的标准格式，通常一个证书包含如下信息

* `Certificate`
    * `Version Number`: 版本号
    * `Serial Number`: 序列号
    * `Signature Algorithm`: 签名算法
    * **`Issuer Name`**: 证书颁发机构名字，即CA
    * `Validity period`: 证书有效期
        * `Not Before`: 有效起始时间
        * `Not After`: 有效的终止时间
    * **`Subject name`**: 证书持有者名字
    * `Subject Public Key Info`: 证书公钥信息
        * `Public Key Algorithm`: 公钥算法
        * `Subject Public Key`: 公钥
    * `Issuer Unique Identifier (optional)`
    * `Subject Unique Identifier (optional)`
    * `Extensions (optional)`
* `Certificate Signature Algorithm`: 证书签名算法
* `Certificate Signature`: 证书签名

`Issuer Name`/`Subject name`（又称为`DN`，`Distinguished Name`）的格式如下

1. `C`: Country
1. `ST`: 
1. `L`: Locality
1. `O`: Organization
1. `CN`: Common Name

**若`Issuer Name`与`Subject name`相同，则表示自签名，根证书都是自签名的**

## 2.2 证书类型

| 证书类型 | 类型解释 |
|:--|:--|
| 单域名证书 | 证书匹配一个`单域名` |
| 单SAN证书 | 证书匹配多个后缀不同的`单域名` |
| 泛域名证书 | 证书匹配单个`泛域名`</br>（例如，`*.test.com`可以匹配`www.test.com`和`ftp.test.com`） |
| 泛SAN证书 | 证书匹配多个后缀不同的`泛域名` |

`SAN`: `Subject Alternative Name`

## 2.3 根证书和中间证书以及证书链

大多数人都知道SSL(TLS)，但是对其工作原理知之甚少，更不用说中间证书`Intermediate Certificate`、根证书`Root Certificate`以及证书链`Certificate Chain`了

### 2.3.1 根证书

根证书，又称为信任链的起点，是信任体系（SSL/TLS）的核心基础。每个浏览器或者设备都包含一个根仓库（`root store`），`root store`包含了一组预置的根证书，根证书价值是非常高的，任何由它的私钥签发的证书都会被浏览器信任

根证书属于证书颁发机构，它是校验以及颁发SSL证书的机构

### 2.3.2 证书链

在进一步探讨证书之前，我们需要引入一个概念，叫做证书链。我们先从一个问题入手：浏览器如何判断一个证书是否合法？当你访问一个站点时，浏览器会快速地校验这个证书的合法性

浏览器会沿着证书的**证书链**进行校验，那么什么是证书链呢？我们在申请证书时，需要创建一个`Certificate Signing Request`以及`Private Key`，`Certificate Signing Request`会发送给证书颁发机构，该机构会用根证书的私钥来对证书进行签名，然后再发还给请求者

当浏览器校验这个站点证书时，发现这个证书由根证书签名（准确地说，用根证书的私钥签名），且浏览器信任这个根证书，因此浏览器信任由这个根证书签名的站点证书。在这个例子中，站点证书直链根证书

### 2.3.3 中间证书

通常情况下，证书颁发机构不会用根证书来为站点证书签名，因为这非常危险，如果发生了误发证书或者其他错误而不得不撤回根证书，那么所有由该根证书签名的证书都会立即失效

为了提供更好的隔离性，证书颁发机构通常只为中间证书签名（用根证书的私钥来为这些`Intermediate Certificate`签名），然后再用这些中间证书来为站点证书签名（用中间证书的私钥来进行签名）。通常，站点证书与根证书之间存在多级的中间证书

证书链的示意图如下，简洁起见，只保留了一级中间证书

![fig1](/images/Protocol-SSL/fig1.jpg)

**要获得中间证书，一般有两种方式**

1. 由客户端自动下载中间证书
1. 由服务器推送中间证书

#### 2.3.3.1 客户端自动下载中间证书

**一张标准的证书，都会包含自己的颁发者名称，以及颁发者机构访问信息：Authority Info Access，其中就会有颁发者CA证书的下载地址**，可以通过`openssl x509 -in <cert> -noout -text`查看证书信息。通过这个CA证书下载地址，我们就能够获得CA证书，**但有些平台不支持这种方式，例如Android，在这种平台上，仅通过站点证书就无法建立安全连接**

除了操作系统支持外，还有一个很重要的因素，就是客户端可以正常访问公网。如果客户端本身在一个封闭的网络环境内，无法访问公网下载中间证书，就会造成失败，无法建立可信连接

此外，有些CA的中间证书下载地址因为种种原因被“墙”掉了，也会造成我们无法获得中间证书，进而无法建立可信链接

虽然自动下载中间证书的机制如此不靠谱，但在有些应用中，这却是唯一有效的机制，譬如邮件签名证书，由于我们发送邮件时，无法携带颁发邮件证书的中间证书，往往只能依靠客户端自己去下载中间证书，一旦这个中间证书的URL无法访问（被“墙”掉）就会造成验证失败

#### 2.3.3.2 服务器推送中间证书

**服务器推送中间证书，就是将中间证书，预先部署在服务器上，服务器在发送证书的同时，将中间证书一起发给客户端**

如果我们在服务器上不主动推送中间证书，可能会造成下列问题：

1. Android手机无法自动下载中间证书，造成验证出错，提示证书不可信，无法建立可信连接
1. Java客户端无法自动下载中间证书，验证出错，可信连接失败
1. 内网电脑，在禁止公网的情况下，无法自动下载中间证书，验证出错，可信连接失败
1. 虽然我们不部署中间证书，在大多数情况，我们依然可以建立可信的HTTPS连接，但为了避免以上这些情况，我们必须在服务器上部署中间证书

所以，为了确保我们在各种环境下都能建立可信的HTTPS连接，我们应该尽量做到以下几点：

1. 必须在服务器上部署正确的中间证书，以确保各类浏览器都能获得完整的证书链，完成验证
1. 选择可靠的SSL服务商，有些小的CA机构，因为各种原因，造成他们的中间证书下载URL被禁止访问，即使我们在服务器上部署了中间证书，但也可能存在某种不可测的风险，这是我们应该尽力避免的
1. 中间证书往往定期会更新，所以在证书续费或者重新签发后，需要检查是否更换过中间证书

### 2.3.4 数字签名

数字签名是一种数字形式的公证。当根证书为中间证书签名时，本质上是将信任度传递到了中间证书，由于签名用的是根证书的私钥，因此中间证书也同时获得了信任

每当浏览器或设备收到SSL证书时，都会收到证书本身以及与证书关联的公钥。使用公钥解密数字签名并查看由谁签署的证书。当浏览器验证站点SSL证书时，它使用证书提供的公钥来解密签名并沿着证书链向上移动。不断重复这个过程--解密签名并跟随证书链到签署它的证书--直到最终到达浏览器信任库中的一个根证书。如果最后的根证书不在信任库中，那么浏览器就不信任该证书

**证书包含以下内容**

1. 证书包含了颁发证书的机构的名字--CA（CA可能是`Root CA`也可能是`Intermediate CA`）
1. 证书内容本身的数字签名(用**CA的私钥**对摘要加密后的结果)
1. 证书持有者的公钥
1. 证书签名用到的hash算法

### 2.3.5 `Root CA`与`Intermediate CA`

到这里就比较清晰明了了，`Root CA`是拥有一个或多个根证书的证书颁发机构，`Intermediate CA`/`Sub CA`是拥有中间证书的证书颁发机构，中间证书需要连接到上层的证书（可能是中间证书或者根证书），这个就叫做交叉验签，或多级验签

一般来说，不会用根证书来为站点证书做签名，而是通过中间证书来增加安全层级，这有助于减少以及分解由误签或者其他错误造成的危害，因为我们只需要撤销中间证书而不需要撤销根证书，因此只会让部分证书失效而不会使全部证书失效

### 2.3.6 `Chained Root`与`Single Root`

`Root CA`用`Single Root`来直接颁发证书，使得部署证书和安装证书变得更加简单。`Sub CA`用`Chained Root`来颁发证书。它是一个中间证书，因为`Sub CA`没有自己的受信任的根，所以必须链接到一个具有根证书的`Third-party CA`

下面是两者的差异

1. `Chained Root`安装起来更麻烦，**因为持有站点证书的应用最好能够同时提供中间证书（以免中间证书无法正常下载，导致验证失败）**，这就是为什么在制作证书时，需要将站点证书和中间证书一并打入证书中
1. `Chained Root`受它们所链接的`Third-party CA`支配，它们无法控制根证书，如果`Root CA`停业，那么`Chained Root`也会失效
1. 根证书和中间证书都会过期，虽然时间较长，但是中间证书的失效时间必须早于根证书，这增加了复杂度

## 2.4 认证过程

**以一个深度为3的证书链的为例进行介绍**

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

client -> server: say hello
server -> client: 发送「站点证书」
client -> client: 根据「站点证书」中的下载链接，下载「Intermediate CA」
client -> client: 用「Intermediate CA」校验「站点证书」的合法性\n计算「站点证书」的摘要，用「Intermediate CA」的公钥解码「站点证书」中的数字签名得到摘要，对比两个摘要是否相同
client -> client: 根据「Intermediate CA」中的下载链接，下载「Root CA」
client -> client: 用「Root CA」校验「Intermediate CA」的合法性\n计算「Intermediate CA」的摘要，用「Root CA」的公钥解码「Intermediate CA」中的数字签名得到摘要，对比两个摘要是否相同
client -> client: 校验「Root CA」是否在本机的可信根证书列表中
```

# 3 openssl

## 3.1 openssl req

req指令既可以直接生成一个新的自签名证书，也可以根据现有的证书请求和其相应私钥生成自签名根证书

* 如果是根据现有证书请求生成自签名根证书，那么一定要-key选项指定相应的私钥指令才能执行成功

req指令也可以生成密钥对，但在使用req同时生成密钥对是对密钥对保存和格式有限制（只能是PEM编码，DES3-CBC模式加密）。如果需要更灵活的处理，可以使用genrsa或者gendsa先生成密钥然后使用-key选项指定

**参数选项**

* **`-new`: 指定执行生成新的证书请求，此时会忽略`-in`指定的内容**
* **`-x509`: 根据现有的证书请求生成自签名根证书（要求使用-key指定证书请求里面的公钥相应的私钥，以便对自签名根证书进行签名）**
* **`-key`: 指定输入的密钥，如果不指定此选项会根据`-newkey`选项的参数生成密钥对**
* **`-newkey`: 指定生成一个新的密钥对，只有在没有`-key`选项的时候才生效，参数形式为`rsa:numbits`或者`dsa:file`**
* **`-subj`: 直接从指令行指定证书请求的主体名称，格式为/分割的键值对字符串，如果没有此选项，那么会弹出交互提示**
* **`-days`: 设定了生成的自签名根证书的有效期，单位为天；该选项只有在使用了`-x509`选项生成自签名证书的时候才生效，默认为30天**
* **`-config`: 指定req指令在生成证书请求的时候使用的OpenSSL配置文件，一般默认为`/etc/pki/tls/openssl.cnf`**
* **`-extensions`: 选项指定了生成自签名根证书的时候使用的扩展字段，其参数为OpenSSL配置文件中的某个字段名**
* **`-reqexts`: 选项指定了生成证书请求是使用的扩展字段，该字段参数也是配置文件中的某个字段名**
* `-text`: 让指令输出证书请求或者自签名根证书内容的明文解析，默认情况下，它将输出所有可能输出的内容，如果使用了reqopt选项，则输出内容取决于reqopt选项
* `-reqopt`: 指定text选项输出的内容可以为多个，每个之间使用`,`分隔
* `set_serial`: 指定生成的自签名根证书的序列号，默认情况下生成的自签名根证书序列号是0；该选项也只有在生成自签名根证书的时候有效
* `-keyout`: 置顶新生成的私钥的输出（仅在使用了`-newKey`或`-new`选项导致生成新密钥对的时候才有效，如果使用了`-key`则此选项被忽略）
* `-keyform`: 指定输入密钥的编码格式（比如PEM，DER，PKCS#12，Netscape，IIS SGC，Engine等）
* **`-in`: 指定输入证书请求文件，如果使用了`-new`或者`-newkey`选项，此选项被忽略**
* `-inform`: 指定输入证书请求文件的编码格式（比如PEM，DER）
* **`-out`: 指定输出证书请求文件或自签名证书文件**
* `-noout`: 使用此选项后，指令将不会输出编码的证书请求或者自签名根证书到-out选项指定的文件中，一般用来测试指令或者查看证书请求的信息
* `-outform`: 指定输出证书请求文件或自签名证书的编码格式（比如PEM，DER）
* `-pubkey`: 使用此选项的话，指令将输出PEM编码的公钥到`-out`指定的文件中，默认情况下只输出私钥到`-keyout`指定的文件，并不输出公钥
* `-passin`: 指定读取`-key`选项指定的私钥所需要的解密口令，如果没有指定，私钥又有密钥的话，会弹出交互提示
* `-passout`: 指定`-keyout`选项输出私钥时使用的加密口令
* `-nodes`: 表示不对私钥进行加密，如果指定此选项，则忽略-passout指定的口令；如果没有此选项，却指定了-passout则会有交互提示
* `-digest`: 指定生成证书请求或者自签名根证书是使用的信息摘要算法，一般在生成数字签名的时候使用
* `-verify`: 使用此选项对证书请求中的数字签名进行验证操作，并给出失败或者成功的提示信息，其验证的过程是从证书请求里面提取公钥，然后使用该公钥对证书请求的数字签名进行验证
* 如果没有`-key`选项也没有`-newkey`选项，则会根据`openssl.cnf`中`req`字段的`default_bits`选项的参数，生成一个RSA密钥
* 如果没有使用`-nodes`选项，并且生成了新的私钥，私钥会被输出到`-keyout`指定的文件中时将被以DES3的CBC模式加密

**示例**

```sh
# 生成一个新的证书请求，使用新的 rsa2048 位密钥
# 输出证书请求到request.pem
# 输出密钥到private.pem，密钥口令为12345678

openssl req -new \
    -newkey rsa:2048 -keyout private.pem -passout pass:12345678 \
    -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=www.liuyehcf.test" \
    -out request.pem

# 对证书请求签名进行验证
openssl req -in request.pem -verify -noout

# -----分割线-----

# 生成一个自签名的根证书
openssl req \
    -newkey rsa:2048 -keyout private.pem -passout pass:12345678 \
    -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=selfca" \
    -x509 \
    -out selfsign.crt
```

## 3.2 openssl ca

ca指令模拟一个完整的CA服务器，它包括签发用户证书，吊销证书，产生CRL及更新证书库等管理操作

**参数选项**

* **`-config`: 指定要使用的配置文件，如果没有此选项，则会先查找OPENSSL_CONF或者SSLEAY_CONF定义的文件名，如果这两个环境变量都没有定义，就使用OpenSSL安装的默认路径，一般是`/usr/local/openssl/openssl.cnf`，具体看安装配置**
* `-startdate`: 设置证书的生效时间 格式为`YYMMDDHHMMSSZ`指定年月日时分秒，如果没有则使用主配置文件中的default_startdate
* `-enddate`: 格式跟`-startdate`一样
* **`-days`: 设置证书的有效天数，生效时间到到期时间之间的天数，如果使用了`-enddate`，此选项被忽略**
* `-name`: 指定配置文件中CA选项的名称
* `-notext`: 不输出明文信息到证书文件
* **`-subj`: 直接从指令行指定证书请求的主体名称，格式为/分割的键值对字符串，如果没有此选项，那么会弹出交互提示**
* **`-cert`: 参数是一个可以包含路径的文件名，该文件是一个PEM编码的X.509证书文件**
* **`-keyfile`: 参数是一个包含路径的文件名，文件格式可以为PEM，DER，PKCS#12，Netscape，IIS SGC，Engine，但需要通过`-keyform`指定到底是哪种格式**
* `-policy`: 指定CA的匹配策略
* **`-extensions` 指定`x509 v3`扩展字段的字段名，如果没有这个选项，就由`-extfile`选项指定**
* `-extfile`: 指定`x509 v3`扩展的配置文件，如果没有`-extensions`字段，则由CA主配置文件中的`x509_extensions`选项指定
* **`-in`: 指定一个可以包含路径的证书请求文件名，应该是PEM变得PKCS#10格式的证书请求**
* `-infiles`: 指定一系列包含PEM编码证书请求的文件，包含多个，只能作为指令的最后一个选项，其后的参数都被认为是证书请求文件
* **`-out`: 选项指定了输出签发好的证书或者新生成的CRL的文件，如果没有使用`-notext`选项，那么证书的明文信息也会输出到`-out`选项指定的文件中**
* `-outdir`: 选项指定了新生成的证书的输出目录，默认输出到`newecerts`目录，并使用`.pem`作为后缀，都是PEM编码。

## 3.3 证书转换

### 3.3.1 crt与pkcs12

**将`crt`格式的站点私钥与站点证书，转存为`pkcs12`格式的证书**

```sh
openssl pkcs12 -export -in <cert> -inkey <private key> -name <aliasName> -out <pkcs12 file>

# 执行过程中，会创建pkcs12证书的密码
# 1. <cert> 指证书文件路径
# 2. <private key> 指私钥文件路径
# 3. <aliasName> 指该证书的别名
# 4. <pkcs12 file> 指待创建的pkcs12证书
```

**将`crt`格式的站点私钥与站点证书、中间证书、CA证书，转存为`pkcs12`格式的证书**

```sh
openssl pkcs12 -export -in <server cert> -inkey <server private key>  -certfile <intermediate cert> -CAfile <ca cert> -name <aliasName> -out <pkcs12 file>

# 执行过程中，会创建pkcs12证书的密码
# 1. <server cert> 指站点证书
# 2. <server private key> 指站点证书的私钥
# 3. <intermediate cert> 中间证书
# 4. <ca cert> 根证书
# 5. <aliasName> 指该证书的别名
# 6. <pkcs12 file> 指待创建的pkcs12证书
```

**将`crt`格式的根证书添加到`pkcs12`的信任证书链中**

```sh
keytool -import -trustcacerts -alias <aliasName> -file <ca cert> -keystore <pkcs12 file>

# <aliasName> 该证书在keystore中的别名，随意取，保证唯一性即可
# <ca cert> 待导入的根证书
# <pkcs12 file> pkcs12证书
```

**从`pkcs12`格式的证书中导出`der`格式的证书**

```sh
keytool -export -alias <aliasName> -keystore <pkcs12 file> -file <der file>

# <aliasName> 证书在keystore中的别名
# <pkcs12 file> pkcs12证书
# <der file> der证书
```

### 3.3.2 crt与der

**将`der`格式的证书转换为`crt`格式的证书**

* `der`格式的证书，其后缀为`.cer`或`.der`

```sh
openssl x509 -inform DER -in <der file> -out <crt file>

# <der file> der格式的证书
# <crt file> crt格式的证书
```

### 3.3.3 crt与pem

**将`pem`格式的证书转换为`crt`格式的证书**

```sh
openssl x509 -inform PEM -in <pem file> -out <crt file>

# <pem file> pem格式的证书
# <crt file> crt格式的证书
```

## 3.4 从私钥导出公钥

```sh
openssl rsa -in <private key> -pubout -out <public key>

# 1. <private key> 私钥的路径
# 2. <public key> 公钥的路径
```

## 3.5 查看证书信息

```sh
openssl x509 -in <cert file> -noout -text

# 1. <cert file> 证书的路径
```

# 4 keytool

## 4.1 cmd

`keytool command [command options]`

* `-certreq`：生成证书请求
* `-changealias`：更改条目的别名
* `-delete`：删除条目
* `-exportcert`：导出证书
* `-genkeypair`：生成密钥对
* `-genseckey`：生成密钥
* `-gencert`：根据证书请求生成证书
* `-importcert`：导入证书或证书链
* `-importpass`：导入口令
* `-importkeystore`：从其他密钥库导入一个或所有条目
* `-keypasswd`：更改条目的密钥口令
* `-list`：列出密钥库中的条目
* `-printcert`：打印证书内容
* `-printcertreq`：打印证书请求的内容
* `-printcrl`：打印 CRL 文件的内容
* `-storepasswd`：更改密钥库的存储口令

`keytool -genkeypair [options]`

* `-alias <alias>`：要处理的条目的别名
* `-keyalg <keyalg>`：密钥算法名称
* `-keysize <keysize>`：密钥位大小
* `-sigalg <sigalg>`：签名算法名称
* `-destalias <destalias>`：目标别名
* `-dname <dname>`：唯一判别名
* `-startdate <startdate>`：证书有效期开始日期/时间
* `-ext <value>`：X.509 扩展
* `-validity <valDays>`：有效天数
* `-keypass <arg>`：密钥口令
* `-keystore <keystore>`：密钥库名称
* `-storepass <arg>`：密钥库口令
* `-storetype <storetype>`：密钥库类型
* `-providername <providername>`：提供方名称
* `-providerclass <providerclass>`：提供方类名
* `-providerarg <arg>`：提供方参数
* `-providerpath <pathlist>`：提供方类路径
* `-v`：详细输出
* `-protected`：通过受保护的机制的口令

### 4.1.1 查看证书信息

```sh
# 查看keystore之外的证书的信息
keytool -printcert -file <cert file>

# 查看keystore之中的证书的信息
keytool -list -keystore <key store path> -v

# <key store path> 指本地的jks路径
```

### 4.1.2 从JKS中导出证书

```sh
keytool -export -keystore <key store path> -alias <aliasName> -file <cert file>

# <key store path> 指本地的jks路径
# <aliasName> 指证书别名
# <cert file> 指待输出的证书文件
```

### 4.1.3 将根证书导入JKS

我们如何使用Java连接到颁发了合法证书的服务端？当然，不校验服务端的合法性是可以的，但是此时客户端会存在安全风险

如果Java客户端需要校验服务端的合法性，那么我们需要将站点证书对应的**根证书**导入本地的JKS中

```sh
keytool -import -alias <aliasName> -file <root cert file> -keystore <key store path>

# 1. <aliasName> 指证书别名
# 2. <root cert file> 指待导入的根证书的别名
# 3. <key store path> 指本地的jks路径
```

于是，我们的Java客户端使用上述导入了根证书的JKS就能连接到服务端。因为该服务端的根证书位于信任池中，因此也会信任该服务端的站点证书。具体使用JKS的实例代码参见下方的Demo

### 4.1.4 将服务端证书导入JKS

**将`pkcs12`格式的证书导入JKS，并转为`jks`格式**

```sh
keytool -importkeystore -srckeystore <pkcs12 file> -destkeystore <jks file> -srcstoretype PKCS12 -deststoretype JKS

# 执行过程中，会创建jks证书的密码，以及源pkcs12证书的密码
# 1. <pkcs12 file> 指源pkcs12证书的路径
# 2. <jks file> 指待创建的jks证书的路径
```

**将`pkcs12`格式的证书直接导入JKS，保持其`pkcs12`格式**

```sh
keytool -importkeystore -srckeystore <pkcs12 file> -destkeystore <jks file> -srcstoretype PKCS12 -deststoretype PKCS12

# 执行过程中，会创建jks证书的密码，以及源pkcs12证书的密码
# 1. <pkcs12 file> 指源pkcs12证书的路径
# 2. <jks file> 指待创建的jks证书的路径
```

## 4.2 Java-Api

```java
package org.liuyehcf.ssl;

import sun.security.tools.keytool.CertAndKeyGen;
import sun.security.x509.X500Name;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.Key;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class KeyStoreExample {

    private static final String KEY_STORE_PATH = "/tmp/keyStore.ks";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_STORE_TYPE = "PKCS12";

    private static final String KEY_PASSWORD = "654321";

    private static final String ALIAS_PRIVATE = "alias_private";
    private static final String ALIAS_CERT = "alias_cert";

    public static void main(String[] args) throws Exception {
        createKeyStore();

        storePrivateEntryAndCertChain();
        loadPrivateEntryAndCertChain();

        storeCert();
        loadCert();
    }

    private static void createKeyStore() throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);

        // init the key store
        keyStore.load(null, null);

        keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
    }

    private static void storePrivateEntryAndCertChain() throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        CertAndKeyGen gen = new CertAndKeyGen("RSA", "SHA1WithRSA");
        gen.generate(1024);

        Key key = gen.getPrivateKey();
        X509Certificate cert = gen.getSelfCertificate(new X500Name("CN=ROOT"), (long) 365 * 24 * 3600);

        X509Certificate[] chain = new X509Certificate[1];
        chain[0] = cert;

        keyStore.setKeyEntry(ALIAS_PRIVATE, key, KEY_PASSWORD.toCharArray(), chain);

        keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
    }

    private static void loadPrivateEntryAndCertChain() throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        Key pvtKey = keyStore.getKey(ALIAS_PRIVATE, KEY_PASSWORD.toCharArray());
        assertNotNull(pvtKey);
        System.out.println(pvtKey.toString());

        Certificate[] chain = keyStore.getCertificateChain(ALIAS_PRIVATE);
        assertNotNull(chain);
        for (Certificate cert : chain) {
            System.out.println(cert.toString());
        }

        //or you can get cert by same alias
        Certificate cert = keyStore.getCertificate(ALIAS_PRIVATE);
        assertNotNull(cert);
        System.out.println(cert);
    }

    private static void storeCert() throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        CertAndKeyGen gen = new CertAndKeyGen("RSA", "SHA1WithRSA");
        gen.generate(1024);

        X509Certificate cert = gen.getSelfCertificate(new X500Name("CN=ROOT"), (long) 365 * 24 * 3600);

        keyStore.setCertificateEntry(ALIAS_CERT, cert);

        keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
    }

    private static void loadCert() throws Exception {
        KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        Certificate cert = keyStore.getCertificate(ALIAS_CERT);
        assertNotNull(cert);
        System.out.println(cert);
    }

    private static void assertNotNull(Object obj) {
        if (obj == null) {
            throw new IllegalArgumentException();
        }
    }
}
```

# 5 JKS

## 5.1 服务端

Java环境下，数字证书是用`keytool`生成的，这些证书被存储在`store`中，就是证书仓库。我们来调用keytool命令为服务端生成数字证书和保存它使用的证书仓库：

**生成数字证书和证书仓库**

* 证书名称：`liuyehcf_server_key`
* 证书仓库路径：`~/liuyehcf_server_ks`

```sh
keytool -genkey -v -alias liuyehcf_server_key -keyalg RSA -keystore ~/liuyehcf_server_ks -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 123456 -keypass 234567

# 以下为输出内容
在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 90 天):
     CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
[正在存储/Users/HCF/liuyehcf_server_ks]

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_server_ks -destkeystore /Users/HCF/liuyehcf_server_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

## 5.2 客户端

有了服务端，我们原来的客户端就不能使用了，必须要走SSL协议。由于服务端的证书是我们自己生成的，没有任何受信任机构的签名，所以客户端是无法验证服务端证书的有效性的，通信必然会失败。所以我们需要为客户端创建一个保存所有信任证书的仓库，然后把服务端证书导进这个仓库。这样，当客户端连接服务端时，会发现服务端的证书在自己的信任列表中，就可以正常通信了

因此现在我们要做的是生成一个客户端的证书仓库，**因为keytool不能仅生成一个空白仓库，所以和服务端一样，我们还是生成一个证书加一个仓库（客户端证书加仓库）**

**生成数字证书和证书仓库**

* 证书名称：`liuyehcf_client_key`
* 证书仓库路径：`~/liuyehcf_client_ks`

```sh
keytool -genkey -v -alias liuyehcf_client_key -keyalg RSA -keystore ~/liuyehcf_client_ks -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 345678 -keypass 456789

# 以下为输出内容
正在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 90 天):
     CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
[正在存储/Users/HCF/liuyehcf_client_ks]

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_client_ks -destkeystore /Users/HCF/liuyehcf_client_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

**接下来，我们要把服务端的证书导出来，并导入到客户端的仓库。第一步是导出服务端的证书**

```sh
keytool -export -alias liuyehcf_server_key -keystore ~/liuyehcf_server_ks -file ~/server_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/server_key.cer> 中的证书

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_server_ks -destkeystore /Users/HCF/liuyehcf_server_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

**然后是把导出的证书导入到客户端证书仓库**

```sh
keytool -import -trustcacerts -alias liuyehcf_server_key -file ~/server_key.cer -keystore ~/liuyehcf_client_ks

# 以下为输出内容
输入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: bd78a56
有效期为 Fri Dec 07 21:59:02 CST 2018 至 Thu Mar 07 21:59:02 CST 2019
证书指纹:
     MD5:  75:9E:FF:BB:D7:A2:70:59:CB:17:DB:4F:5E:0F:BD:67
     SHA1: AC:89:15:A2:A2:4B:90:6E:A3:FD:24:38:27:DF:F6:32:BA:1C:7B:89
     SHA256: 10:FF:A0:C6:B5:B4:CC:DF:6E:9E:61:27:3B:F1:59:01:49:55:E8:75:33:EE:0B:13:55:56:6C:38:16:08:19:F8
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 29 B6 53 D0 FB A0 DD A6   4A C7 A1 D7 51 C5 E2 07  ).S.....J...Q...
0010: 6D D6 2A 4D                                        m.*M
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_client_ks -destkeystore /Users/HCF/liuyehcf_client_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

## 5.3 SSLServer

```java
package org.liuyehcf.ssl;

import javax.net.ServerSocketFactory;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLServerSocket;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.KeyStore;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class SSLServer extends Thread {

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_server_ks";
    private static final String STORE_TYPE = "JKS";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_PASSWORD = "234567";

    private Socket socket;

    private SSLServer(Socket socket) {
        this.socket = socket;
    }

    public static void main(String[] args) throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // serverSocketFactory
        ServerSocketFactory factory = sslContext.getServerSocketFactory();
        ServerSocket socket = factory.createServerSocket(8443);
        ((SSLServerSocket) socket).setNeedClientAuth(false);

        while (!Thread.currentThread().isInterrupted()) {
            new SSLServer(socket.accept()).start();
        }
    }

    public void run() {
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter writer = new PrintWriter(socket.getOutputStream());

            String data = reader.readLine();
            writer.println(data);
            writer.close();
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## 5.4 SSLClient

```java
package org.liuyehcf.ssl;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.net.Socket;
import java.security.KeyStore;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class SSLClient {

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_client_ks";
    private static final String STORE_TYPE = "JKS";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "345678";
    private static final String KEY_PASSWORD = "456789";

    public static void main(String[] args) throws Exception {
        // Set the key store to use for validating the server cert.
        System.setProperty("javax.net.debug", "ssl,handshake");

        SSLClient client = new SSLClient();
        Socket s = client.createSslSocket();

        PrintWriter writer = new PrintWriter(s.getOutputStream());
        BufferedReader reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
        writer.println("hello");
        writer.flush();
        System.out.println(reader.readLine());
        s.close();
    }

    private Socket createSslSocket() throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // socketFactory
        SSLSocketFactory factory = sslContext.getSocketFactory();

        return factory.createSocket("localhost", 8443);
    }
}
```

## 5.5 双向认证

上述示例中，仅仅客户端对服务端做了单向认证，如果要进行双向认证，需要将客户端的证书添加到服务端的keyStore中

**接下来，我们要把客户端的证书导出来，并导入到服务端的仓库。第一步是导出客户端的证书**

```sh
keytool -export -alias liuyehcf_client_key -keystore ~/liuyehcf_client_ks -file ~/client_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/client_key.cer> 中的证书

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_client_ks -destkeystore /Users/HCF/liuyehcf_client_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

**然后是把导出的证书导入到服务端证书仓库**

```sh
keytool -import -trustcacerts -alias liuyehcf_client_key -file ~/client_key.cer -keystore ~/liuyehcf_server_ks

# 以下为输出内容
输入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: 54f5ef02
有效期为 Fri Dec 07 21:59:51 CST 2018 至 Thu Mar 07 21:59:51 CST 2019
证书指纹:
     MD5:  F2:E4:16:62:DE:1C:D1:DC:F3:E3:95:35:6E:5E:5C:3E
     SHA1: B1:7F:B5:38:AD:73:C8:D4:AF:C9:FB:F2:C4:9D:A5:8A:37:3C:E3:6D
     SHA256: 54:E8:31:2F:CF:B0:10:3B:B1:85:96:A9:0B:92:54:08:30:8E:49:BB:F5:EF:47:6F:B8:47:68:28:AA:CF:81:B5
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: B5 BF 75 DD B6 07 5A 4A   BC 7D AF F0 46 76 FE E3  ..u...ZJ....Fv..
0010: 2B AC 01 B8                                        +...
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_server_ks -destkeystore /Users/HCF/liuyehcf_server_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

**改造服务端的代码**

```java
((SSLServerSocket) socket).setNeedClientAuth(false);

// 改为

((SSLServerSocket) socket).setNeedClientAuth(true);
```

# 6 PKCS12

## 6.1 服务端

Java环境下，数字证书是用`keytool`生成的，这些证书被存储在`store`中，就是证书仓库。我们来调用keytool命令为服务端生成数字证书和保存它使用的证书仓库：

**生成数字证书和证书仓库**

* 证书名称：`liuyehcf_server_key`
* 证书仓库路径：`~/liuyehcf_server_ks`

```sh
# 注意，在指定-storetype PKCS12时，-keypass参数是无效的
keytool -genkey -v -alias liuyehcf_server_key -keyalg RSA -keystore ~/liuyehcf_server_ks -storetype PKCS12 -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 123456

# 以下为输出内容
正在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 90 天):
     CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
[正在存储/Users/HCF/liuyehcf_server_ks]
```

## 6.2 客户端

有了服务端，我们原来的客户端就不能使用了，必须要走SSL协议。由于服务端的证书是我们自己生成的，没有任何受信任机构的签名，所以客户端是无法验证服务端证书的有效性的，通信必然会失败。所以我们需要为客户端创建一个保存所有信任证书的仓库，然后把服务端证书导进这个仓库。这样，当客户端连接服务端时，会发现服务端的证书在自己的信任列表中，就可以正常通信了

因此现在我们要做的是生成一个客户端的证书仓库，**因为keytool不能仅生成一个空白仓库，所以和服务端一样，我们还是生成一个证书加一个仓库（客户端证书加仓库）**

**生成数字证书和证书仓库**

* 证书名称：`liuyehcf_client_key`
* 证书仓库路径：`~/liuyehcf_client_ks`

```sh
# 注意，在指定-storetype PKCS12时，-keypass参数是无效的
keytool -genkey -v -alias liuyehcf_client_key -keyalg RSA -keystore ~/liuyehcf_client_ks -storetype PKCS12 -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 345678

# 以下为输出内容
正在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 90 天):
     CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
[正在存储/Users/HCF/liuyehcf_client_ks]
```

**接下来，我们要把服务端的证书导出来，并导入到客户端的仓库。第一步是导出服务端的证书**

```sh
keytool -export -alias liuyehcf_server_key -keystore ~/liuyehcf_server_ks -file ~/server_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/server_key.cer> 中的证书
```

**然后是把导出的证书导入到客户端证书仓库**

```sh
keytool -import -trustcacerts -alias liuyehcf_server_key -file ~/server_key.cer -keystore ~/liuyehcf_client_ks

# 以下为输出内容
输入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: 3f428b5f
有效期为 Fri Dec 07 22:09:42 CST 2018 至 Thu Mar 07 22:09:42 CST 2019
证书指纹:
     MD5:  49:55:0E:90:8C:29:87:09:41:AA:D0:D0:8D:BE:51:9D
     SHA1: 96:12:9E:FF:AD:D8:CD:32:72:D0:01:50:01:83:06:FF:09:E2:A4:B6
     SHA256: 79:B9:DF:FD:45:98:53:8F:90:66:9B:31:4C:A1:8F:84:AF:E3:8A:CC:89:D7:F6:BC:BE:BB:52:50:D9:77:15:5E
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 4F FC 25 2B 3C DA CB 66   ED 54 E5 90 F8 31 B6 58  O.%+<..f.T...1.X
0010: A5 D5 22 A6                                        ..".
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中
```

## 6.3 SSLServer

```java
package org.liuyehcf.ssl;

import javax.net.ServerSocketFactory;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLServerSocket;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.KeyStore;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class SSLServer extends Thread {

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_server_ks";
    private static final String STORE_TYPE = "PKCS12";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    private Socket socket;

    private SSLServer(Socket socket) {
        this.socket = socket;
    }

    public static void main(String[] args) throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // serverSocketFactory
        ServerSocketFactory factory = sslContext.getServerSocketFactory();
        ServerSocket socket = factory.createServerSocket(8443);
        ((SSLServerSocket) socket).setNeedClientAuth(false);

        while (!Thread.currentThread().isInterrupted()) {
            new SSLServer(socket.accept()).start();
        }
    }

    public void run() {
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter writer = new PrintWriter(socket.getOutputStream());

            String data = reader.readLine();
            writer.println(data);
            writer.close();
            socket.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

## 6.4 SSLClient

```java
package org.liuyehcf.ssl;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManagerFactory;
import java.io.*;
import java.net.Socket;
import java.security.KeyStore;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class SSLClient {

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_client_ks";
    private static final String STORE_TYPE = "PKCS12";
    private static final String PROTOCOL = "TLS";
    private static final String KEY_STORE_PASSWORD = "345678";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    public static void main(String[] args) throws Exception {
        // Set the key store to use for validating the server cert.
        System.setProperty("javax.net.debug", "ssl,handshake");

        SSLClient client = new SSLClient();
        Socket s = client.createSslSocket();

        PrintWriter writer = new PrintWriter(s.getOutputStream());
        BufferedReader reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
        writer.println("hello");
        writer.flush();
        System.out.println(reader.readLine());
        s.close();
    }

    private Socket createSslSocket() throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        // trustManagerFactory
        TrustManagerFactory trustManagerFactory = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        trustManagerFactory.init(keyStore);

        // sslContext
        SSLContext sslContext = SSLContext.getInstance(PROTOCOL);
        sslContext.init(keyManagerFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);

        // socketFactory
        SSLSocketFactory factory = sslContext.getSocketFactory();

        return factory.createSocket("localhost", 8443);
    }
}
```

## 6.5 双向认证

上述示例中，仅仅客户端对服务端做了单向认证，如果要进行双向认证，需要将客户端的证书添加到服务端的keyStore中

**接下来，我们要把客户端的证书导出来，并导入到服务端的仓库。第一步是导出客户端的证书**

```sh
keytool -export -alias liuyehcf_client_key -keystore ~/liuyehcf_client_ks -file ~/client_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/client_key.cer> 中的证书
```

**然后是把导出的证书导入到服务端证书仓库**

```sh
keytool -import -trustcacerts -alias liuyehcf_client_key -file ~/client_key.cer -keystore ~/liuyehcf_server_ks

# 以下为输出内容
输入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: 7e402030
有效期为 Sat Dec 08 09:45:48 CST 2018 至 Fri Mar 08 09:45:48 CST 2019
证书指纹:
     MD5:  5C:54:D1:FC:B5:3C:D4:F7:F4:44:0B:9D:43:83:05:06
     SHA1: 1D:A6:E8:E7:83:3B:CC:A9:CC:BF:0D:93:20:77:9F:25:9F:FC:CE:EB
     SHA256: B5:92:A3:C8:82:6F:D6:1E:FB:53:DF:D7:89:17:75:B3:F5:00:24:9E:9D:23:5B:FD:B8:D5:0F:5F:EB:3D:E5:22
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 9E 34 C8 DB A2 C5 77 6E   14 67 97 6E 77 F6 81 5F  .4....wn.g.nw.._
0010: 72 F1 3B DD                                        r.;.
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中
```

**改造服务端的代码**

```java
((SSLServerSocket) socket).setNeedClientAuth(false);

// 改为

((SSLServerSocket) socket).setNeedClientAuth(true);
```

# 7 最佳实践

## 7.1 证书生成及签名

### 7.1.1 创建自签名的单域名证书

**第一步：创建自签名ca**

```sh
# 创建ca私钥
openssl genrsa -out ca.key 2048

# 创建ca自签名证书
openssl req -new \
    -sha256 \
    -key ca.key \
    -x509 \
    -days 365 \
    -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=selfca" \
    -out ca.crt
```

**第二步：创建服务端私钥**

```sh
# 创建服务端私钥
openssl genrsa -out server.key 2048

# 查看私钥
file server.key
cat server.key
openssl rsa -in server.key -noout -text
```

**第三步：根据私钥生成证书签名请求**

```sh
# 创建证书签名请求
openssl req -new \
     -sha256 \
     -key server.key \
     -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=www.liuyehcf.test" \
     -out server.csr

# 上面这几个字段的含义
# C  => Country
# ST => State
# L  => City
# O  => Organization
# OU => Organization Unit
# CN => Common Name (证书所请求的域名)
# emailAddress => main administrative point of contact for the certificate

# 查看证书签名请求
file server.csr
cat server.csr
openssl req -noout -text -in server.csr
```

**第四步：用自签名ca进行证书签名**

```sh
# 使用CA的私钥和证书对用户证书签名，下面有两种方式，效果一样
# 1. 使用 openssl ca 进行签名
# 2. 使用 openssl x509 进行签名

# 方式1: openssl ca
# 创建一些必要的文件，否则签名时会有问题
mkdir -p /etc/pki/CA/newcerts
touch /etc/pki/CA/index.txt
echo "01" > /etc/pki/CA/serial
openssl ca -in server.csr \
    -md sha256 \
    -days 3650 \
    -keyfile ca.key \
    -cert ca.crt \
    -config <(cat /etc/pki/tls/openssl.cnf) \
    -out server.crt

# 方式2: openssl x509
openssl x509 -req \
    -in server.csr \
    -sha256 \
    -days 3650 \
    -CAkey ca.key \
    -CA ca.crt \
    -CAcreateserial \
    -out server.crt

# 查看证书
file server.crt
cat server.crt
openssl x509 -in server.crt -noout -text
```

**验证**

启动Http服务（参考`[Java验证]`小节），并配置host

* `127.0.0.1 www.liuyehcf.test`

浏览器访问

* [https://www.liuyehcf.test:8866/](https://www.liuyehcf.test:8866/)

此时浏览器会提示该证书非法。将`ca.crt`添加到系统根证书中后，可正常访问

### 7.1.2 创建自签名的SAN证书

**第一步：创建自签名ca**

```sh
# 创建ca私钥
openssl genrsa -out ca.key 2048

# 创建ca自签名证书
openssl req -new \
    -sha256 \
    -key ca.key \
    -x509 \
    -days 365 \
    -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=selfca" \
    -out ca.crt
```

**第二步：创建服务端私钥**

```sh
# 创建服务端私钥
openssl genrsa -out server.key 2048
```

**第三步：根据私钥生成证书签名请求**

```sh
# 创建证书签名请求
openssl req -new \
    -sha256 \
    -key server.key \
    -subj "/C=CN/ST=ZJ/L=HZ/O=LiuYe/OU=Study/CN=liuyeSAN" \
    -out server.csr
```

**第四步：用自签名ca进行证书签名**

```sh
# 使用CA的私钥和证书对用户证书签名，下面有两种方式，效果一样
# 1. 使用 openssl ca 进行签名
# 2. 使用 openssl x509 进行签名

# 方式1: openssl ca
# 创建一些必要的文件，否则签名时会有问题
mkdir -p /etc/pki/CA/newcerts
touch /etc/pki/CA/index.txt
echo "01" > /etc/pki/CA/serial
openssl ca -in server.csr \
    -md sha256 \
    -keyfile ca.key \
    -cert ca.crt \
    -extensions SAN \
    -config <(cat /etc/pki/tls/openssl.cnf \
        <(printf "[SAN]\nsubjectAltName=DNS:*.test1.liuyehcf.test,DNS:*.test2.liuyehcf.test,DNS:www.liuyehcf.test")) \
    -out server.crt

# 方式2: openssl x509
cat > server_ext << EOF
basicConstraints=CA:FALSE
extendedKeyUsage=serverAuth,OCSPSigning
subjectAltName=@alt_names

[alt_names]
DNS.1=*.test1.liuyehcf.test
DNS.2=*.test2.liuyehcf.test
DNS.3=www.liuyehcf.test
EOF
openssl x509 -req \
    -in server.csr \
    -sha256 \
    -days 3650 \
    -CAkey ca.key \
    -CA ca.crt \
    -CAcreateserial \
    -extfile server_ext \
    -out server.crt
```

**验证**

启动Http服务（参考`[Java验证]`小节），并配置三个host

* `127.0.0.1 www.liuyehcf.test`
* `127.0.0.1 www.test1.liuyehcf.test`
* `127.0.0.1 www.test2.liuyehcf.test`
* `127.0.0.1 www.liuyehcf.test2`（非证书保护的域名）

浏览器访问如下地址

* [https://www.liuyehcf.test:8866/](https://www.liuyehcf.test:8866/)
* [https://www.test1.liuyehcf.test:8866/](https://www.test1.liuyehcf.test:8866/)
* [https://www.test2.liuyehcf.test:8866/](https://www.test2.liuyehcf.test:8866/)

此时浏览器会提示该证书非法。将`ca.crt`添加到系统根证书中后，可正常访问，可用`curl`来验证

* `curl https://www.liuyehcf.test:8866/`
    * `hello world. origin host='www.liuyehcf.test:8866'`
* `curl https://www.test1.liuyehcf.test:8866/`
    * `hello world. origin host='www.test1.liuyehcf.test:8866'`
* `curl https://www.test2.liuyehcf.test:8866/`
    * `hello world. origin host='www.test2.liuyehcf.test:8866'`
* `curl https://www.liuyehcf.test2:8866/`
    * `curl: (51) SSL: no alternative certificate subject name matches target host name 'www.liuyehcf.test2'`

**问题**

1. **在用`openssl ca`进行签名时，要确保`.csr`文件包含的CN必须是唯一的，否则在签名时会出现`TXT_DB error number 2`的问题**

### 7.1.3 Java验证

**将证书导入JavaKeyStore**

```sh
# 转成pkcs12格式的证书，会要求创建密码，我创建的是 123456
openssl pkcs12 -export -in server.crt -inkey server.key -name liuyehcf -out server.p12

# 将pkcs12格式的证书导入keystore，会要求输入keystore的密码，以及pkcs12的密码，我填的都是 123456
keytool -importkeystore -srckeystore server.p12 -destkeystore liuyehcf_server_ks -srcstoretype PKCS12 -deststoretype PKCS12
```

**Java验证代码**

```java
package org.liuyehcf.netty.https;

import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.*;
import io.netty.handler.ssl.SslContextBuilder;
import io.netty.handler.stream.ChunkedWriteHandler;
import io.netty.handler.timeout.IdleStateHandler;

import javax.net.ssl.KeyManagerFactory;
import java.io.File;
import java.io.FileInputStream;
import java.nio.charset.Charset;
import java.security.KeyStore;
import java.util.concurrent.TimeUnit;

/**
 * @author hechenfeng
 * @date 2019/7/29
 */
public class Server {
    private static final String HOST = "localhost";
    private static final int PORT = 8866;

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_server_ks";
    private static final String STORE_TYPE = "PKCS12";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_PASSWORD = KEY_STORE_PASSWORD;

    public static void main(String[] args) throws Exception {
        final EventLoopGroup boss = new NioEventLoopGroup();
        final EventLoopGroup worker = new NioEventLoopGroup();

        final ServerBootstrap bootstrap = new ServerBootstrap();
        bootstrap.group(boss, worker)
                .channel(NioServerSocketChannel.class)
                .childHandler(new ChannelInitializer<SocketChannel>() {
                    @Override
                    protected void initChannel(SocketChannel socketChannel) throws Exception {
                        ChannelPipeline pipeline = socketChannel.pipeline();
                        pipeline.addLast(new IdleStateHandler(0, 0, 60, TimeUnit.SECONDS));
                        pipeline.addLast(createSslHandlerUsingNetty(pipeline));
                        pipeline.addLast(new HttpServerCodec());
                        pipeline.addLast(new HttpObjectAggregator(65535));
                        pipeline.addLast(new ChunkedWriteHandler());
                        pipeline.addLast(new ServerHandler());
                    }
                })
                .option(ChannelOption.SO_BACKLOG, 1024)
                .childOption(ChannelOption.SO_KEEPALIVE, true)
                .childOption(ChannelOption.TCP_NODELAY, true)
                .childOption(ChannelOption.SO_REUSEADDR, true);

        final ChannelFuture future = bootstrap.bind(PORT).sync();
        System.out.println("server start ...... ");

        future.channel().closeFuture().sync();
    }

    private static ChannelHandler createSslHandlerUsingNetty(ChannelPipeline pipeline) throws Exception {
        // keyStore
        KeyStore keyStore = KeyStore.getInstance(STORE_TYPE);
        keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

        // keyManagerFactory
        KeyManagerFactory keyManagerFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        keyManagerFactory.init(keyStore, KEY_PASSWORD.toCharArray());

        return SslContextBuilder.forServer(keyManagerFactory).build()
                .newHandler(pipeline.channel().alloc(), HOST, PORT);
    }

    private static final class ServerHandler extends SimpleChannelInboundHandler<FullHttpRequest> {

        @Override
        protected void channelRead0(ChannelHandlerContext ctx, FullHttpRequest msg) {
            FullHttpResponse response = new DefaultFullHttpResponse(
                    HttpVersion.HTTP_1_1,
                    HttpResponseStatus.BAD_REQUEST,
                    Unpooled.copiedBuffer("hello world", Charset.defaultCharset()));
            response.headers().set(HttpHeaderNames.CONTENT_TYPE, "text/plain;charset=UTF-8");

            ctx.channel().writeAndFlush(response).addListener(ChannelFutureListener.CLOSE);
        }
    }
}
```

## 7.2 CentOS安装CA根证书

```sh
yum install ca-certificates
```

# 8 在Netty中使用SSL

详见{% post_link Netty-Demo %}

# 9 查看证书信息

可以通过网站`https://myssl.com/`来查看证书信息

比如查看aliyun的证书信息，可以访问`https://myssl.com/www.aliyun.com`

此外，可以通过openssl来查看证书详情以及过期时间等等信息

```sh
# 查看证书详情
echo | openssl s_client -servername www.aliyun.com -connect www.aliyun.com:443 2>/dev/null | openssl x509 -text

# 查看证书过期时间
echo | openssl s_client -servername www.aliyun.com -connect www.aliyun.com:443 2>/dev/null | openssl x509 -noout -dates
```

# 10 参考

* [Java SSL](https://blog.csdn.net/everyok/article/details/82882156)
* [SSL介绍与Java实例](http://www.cnblogs.com/crazyacking/p/5648520.html)
* [Java不同类型密钥库之PKCS12和JCEKS](https://www.csdn.net/article/2015-01-06/2823434)
* [PKCS12 证书的生成及验证](https://blog.csdn.net/kmyhy/article/details/6431609)
* [Java Code Examples for javax.net.ssl.SSLContext](https://www.programcreek.com/java-api-examples/?api=javax.net.ssl.SSLContext)
* [java PKCS12双向认证](https://blog.csdn.net/bolg_hero/article/details/71170606)
* [Okhttp3配置Https访问(使用PKCS12)证书](https://www.aliyun.com/jiaocheng/1738033.html?spm=5176.100033.2.5.490a4571JCeVLU)
* [Import private key and certificate into java keystore](https://coderwall.com/p/3t4xka/import-private-key-and-certificate-into-java-keystore)
* [Convert the certificate and private key to PKCS 12](https://www.wowza.com/docs/how-to-import-an-existing-ssl-certificate-and-private-key)
* [SSL 证书格式普及，PEM、CER、JKS、PKCS12](https://blog.freessl.cn/ssl-cert-format-introduce/)
* [The Difference Between Root Certificates and Intermediate Certificates](https://www.thesslstore.com/blog/root-certificates-intermediate/)
* [中间证书的使用（组图）](https://www.58ssl.com/ssl_wenti/4156.html)
* [使用 OpenSSL 制作一个包含 SAN（Subject Alternative Name）的证书](http://liaoph.com/openssl-san/)
* [如何使用openssl生成证书及签名](https://www.jianshu.com/p/7d940d7a07d9)
* [keytool使用大全：p12(PKCS12)和jks互相转换等](https://blog.csdn.net/NewTWG/article/details/85330895)
* [HTTPS SAN自签名证书](https://www.jianshu.com/p/24ed15c973ec)
* [OpenSSL创建带SAN扩展的证书并进行CA自签](https://blog.csdn.net/dotalee/article/details/78041691)
* [使用OpenSSL生成多域名自签名证书进行HTTPS开发调试](https://zhuanlan.zhihu.com/p/26646377)
* [使用 openssl 生成证书](https://www.cnblogs.com/littleatp/p/5878763.html)
* [Requirements for trusted certificates in iOS 13 and macOS 10.15](https://support.apple.com/en-us/HT210176)
* [HTTPS之SNI介绍](https://blog.51cto.com/zengestudy/2170245)
* [centos 添加CA 证书](https://blog.csdn.net/coder9999/article/details/79664282)
* [阮一峰-数字签名是什么？](http://www.ruanyifeng.com/blog/2011/08/what_is_a_digital_signature.html)
* [SSL证书文件校验工具](https://www.chinassl.net/ssltools/decoder-ssl.html)