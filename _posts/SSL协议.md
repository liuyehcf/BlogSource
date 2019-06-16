---
title: SSL协议
date: 2018-12-02 18:41:43
tags: 
- 摘录
categories: 
- Network
- HTTP
---

__阅读更多__

<!--more-->

# 1 证书

## 1.1 证书种类

| 格式名称 | 格式后缀 | 文件格式 | 描述 |
|:--|:--|:--|:--|:--|
| `DER(Distinguished Encoding Rules)` | `.der/.cer` | 二进制格式 | 只保存证书，不保存私钥</br>Java和Windows服务器偏向于使用这种编码格式 |
| `PEM(Privacy-Enhanced Mail)` | `.pem` | 文本格式 | 可保存证书，也可保存私钥</br>以`-----BEGIN...`开头，以`-----END...`结尾。中间的内容是`BASE64`编码</br>有时我们也把PEM格式的私钥的后缀改为`.key`以区别证书与私钥 |
| `CRT(Certificate)` | `.crt` | 二进制格式/文本格式 | 可保存证书，也可保存私钥</br>有可能是PEM编码格式，也可能是DER编码格式 |
| `PFX(Predecessor of PKCS#12)` | `.pfx/.P12` | 二进制格式 | 同时包含证书和私钥，一般有密码保护</br>证书和私钥存在一个PFX文件中</br>一般用于Windows上的IIS服务器 |
| `JPS(Java Key Storage)` | `.jks` | 二进制格式 | 同时包含证书和私钥，一般有密码保护</br>Java的专属格式，可以用keytool进行格式转换</br>一般用于Tomcat服务器 |

## 1.2 证书转换

__将`crt`证书转为`pkcs12`格式的证书__

```sh
openssl pkcs12 -export -in <cert> -inkey <private key> -name <friendly name> -out <pkcs12 file>

# 执行过程中，会创建pkcs12证书的密码
# 1. <cert> 指证书文件路径
# 2. <private key> 指私钥文件路径
# 3. <friendly name> 指该证书的别名
# 4. <pkcs12 file> 指待创建的pkcs12证书的路径
```

__将`pkcs12`格式的证书转为`jks`格式的证书__

```sh
keytool -importkeystore -srckeystore <pkcs12 file> -destkeystore <jks file> -srcstoretype PKCS12 -deststoretype JKS

# 执行过程中，会创建jks证书的密码，以及源pkcs12证书的密码
# 1. <pkcs12 file> 指源pkcs12证书的路径
# 2. <jks file> 指待创建的jks证书的路径
```

## 1.3 将根证书导入JKS

我们如何使用Java连接到颁发了合法证书的服务端？当然，不校验服务端的合法性是可以的，但是此时客户端会存在安全风险

如果Java客户端需要校验服务端的合法性，那么我们需要将站点证书对应的__根证书__导入本地的JKS中

```sh
keytool -import -alias <friendly name> -file <root cert file> -keystore <key store path>

# 1. <friendly name> 指证书别名
# 2. <root cert file> 指待导入的根证书的别名
# 3. <key store path> 指本地的jks路径
```

于是，我们的Java客户端使用上述导入了根证书的JKS就能连接到服务端。因为该服务端的根证书位于信任池中，因此也会信任该服务端的站点证书。具体使用JKS的实例代码参见下方的Demo

## 1.4 根证书和中间证书以及证书链

大多数人都知道SSL(TLS)，但是对其工作原理知之甚少，更不用说中间证书`Intermediate Certificate`、根证书`Root Certificate`以及证书链`Certificate Chain`了

### 1.4.1 根证书

根证书，又称为信任链的起点，是信任体系（SSL/TLS）的核心基础。每个浏览器或者设备都包含一个根仓库（`root store`），`root store`包含了一组预置的根证书，根证书价值是非常高的，任何由它的私钥签发的证书都会被浏览器信任

根证书属于证书颁发机构，它是校验以及颁发SSL证书的机构

## 1.5 证书链

在进一步探讨证书之前，我们需要引入一个概念，叫做证书链。我们先从一个问题入手：浏览器如何判断一个证书是否合法？当你访问一个站点时，浏览器会快速地校验这个证书的合法性

浏览器会沿着证书的__证书链__进行校验，那么什么是证书链呢？我们在申请证书时，需要创建一个`Certificate Signing Request`以及`Private Key`，`Certificate Signing Request`会发送给证书颁发机构，该机构会用根证书的私钥来对证书进行签名，然后再发还给请求者

当浏览器校验这个站点证书时，发现这个证书由根证书签名（准确地说，用根证书的私钥签名），且浏览器信任这个根证书，因此浏览器信任由这个根证书签名的站点证书。在这个例子中，站点证书直链根证书

## 1.6 中间证书

通常情况下，证书颁发机构不会用根证书来为站点证书签名，因为这非常危险，如果发生了误发证书或者其他错误而不得不撤回根证书，那么所有由该根证书签名的证书都会立即失效

为了提供更好的隔离性，证书颁发机构通常只为中间证书签名（用根证书的私钥来为这些`Intermediate Certificate`签名），然后再用这些中间证书来为站点证书签名（用中间证书的私钥来进行签名）。通常，站点证书与根证书之间存在多级的中间证书

证书链的示意图如下，简洁起见，只保留了一级中间证书

![fig1](/images/SSL协议/fig1.jpg)

## 1.7 数字签名

数字签名是一种数字形式的公证。当根证书为中间证书签名时，本质上是将信任度传递到了中间证书，由于签名用的是根证书的私钥，因此中间证书也同时获得了信任

每当浏览器或设备收到SSL证书时，都会收到证书本身以及与证书关联的公钥。使用公钥解密数字签名并查看由谁签署的证书。当浏览器验证站点SSL证书时，它使用证书提供的公钥来解密签名并沿着证书链向上移动。不断重复这个过程--解密签名并跟随证书链到签署它的证书--直到最终到达浏览器信任库中的一个根证书。如果最后的根证书不在信任库中，那么浏览器就不信任该证书

__证书包含以下内容__

1. 证书包含了颁发证书的机构的名字--CA（CA可能是`Root CA`也可能是`Intermediate CA`）
1. 证书内容本身的数字签名(用__CA的私钥__对摘要加密后的结果)
1. 证书持有者的公钥
1. 证书签名用到的hash算法

## 1.8 `Root CA`与`Intermediate CA`

到这里就比较清晰明了了，`Root CA`是拥有一个或多个根证书的证书颁发机构，`Intermediate CA`/`Sub CA`是拥有中间证书的证书颁发机构，中间证书需要连接到上层的证书（可能是中间证书或者根证书），这个就叫做交叉验签，或多级验签

一般来说，不会用根证书来为站点证书做签名，而是通过中间证书来增加安全层级，这有助于减少以及分解由误签或者其他错误造成的危害，因为我们只需要撤销中间证书而不需要撤销根证书，因此只会让部分证书失效而不会使全部证书失效

## 1.9 `Chained Root`与`Single Root`

`Root CA`用`Single Root`来直接颁发证书，使得部署证书和安装证书变得更加简单。`Sub CA`用`Chained Root`来颁发证书。它是一个中间证书，因为`Sub CA`没有自己的受信任的根，所以必须链接到一个具有根证书的`Third-party CA`

下面是两者的差异

1. `Chained Root`安装起来更麻烦，__因为持有站点证书的应用必须加载中间证书__，这就是为什么在制作证书时，需要将站点证书和中间证书一并打入证书中
1. `Chained Root`受它们所链接的`Third-party CA`支配，它们无法控制根证书，如果`Root CA`停业，那么`Chained Root`也会失效
1. 根证书和中间证书都会过期，虽然时间较长，但是中间证书的失效时间必须早于根证书，这增加了复杂度

# 2 keytool

## 2.1 cmd

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

## 2.2 Java-Api

```Java
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

# 3 JKS

## 3.1 服务端

Java环境下，数字证书是用`keytool`生成的，这些证书被存储在`store`中，就是证书仓库。我们来调用keytool命令为服务端生成数字证书和保存它使用的证书仓库：

__生成数字证书和证书仓库__

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

## 3.2 客户端

有了服务端，我们原来的客户端就不能使用了，必须要走SSL协议。由于服务端的证书是我们自己生成的，没有任何受信任机构的签名，所以客户端是无法验证服务端证书的有效性的，通信必然会失败。所以我们需要为客户端创建一个保存所有信任证书的仓库，然后把服务端证书导进这个仓库。这样，当客户端连接服务端时，会发现服务端的证书在自己的信任列表中，就可以正常通信了。

因此现在我们要做的是生成一个客户端的证书仓库，__因为keytool不能仅生成一个空白仓库，所以和服务端一样，我们还是生成一个证书加一个仓库（客户端证书加仓库）__

__生成数字证书和证书仓库__

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

__接下来，我们要把服务端的证书导出来，并导入到客户端的仓库。第一步是导出服务端的证书__

```sh
keytool -export -alias liuyehcf_server_key -keystore ~/liuyehcf_server_ks -file ~/server_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/server_key.cer> 中的证书

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_server_ks -destkeystore /Users/HCF/liuyehcf_server_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

__然后是把导出的证书导入到客户端证书仓库__

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

## 3.3 SSLServer

```Java
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

## 3.4 SSLClient

```Java
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

## 3.5 双向认证

上述示例中，仅仅客户端对服务端做了单向认证，如果要进行双向认证，需要将客户端的证书添加到服务端的keyStore中

__接下来，我们要把客户端的证书导出来，并导入到服务端的仓库。第一步是导出客户端的证书__

```sh
keytool -export -alias liuyehcf_client_key -keystore ~/liuyehcf_client_ks -file ~/client_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/client_key.cer> 中的证书

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_client_ks -destkeystore /Users/HCF/liuyehcf_client_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

__然后是把导出的证书导入到服务端证书仓库__

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

__改造服务端的代码__

```Java
((SSLServerSocket) socket).setNeedClientAuth(false);

// 改为

((SSLServerSocket) socket).setNeedClientAuth(true);
```

# 4 PKCS12

## 4.1 服务端

Java环境下，数字证书是用`keytool`生成的，这些证书被存储在`store`中，就是证书仓库。我们来调用keytool命令为服务端生成数字证书和保存它使用的证书仓库：

__生成数字证书和证书仓库__

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

## 4.2 客户端

有了服务端，我们原来的客户端就不能使用了，必须要走SSL协议。由于服务端的证书是我们自己生成的，没有任何受信任机构的签名，所以客户端是无法验证服务端证书的有效性的，通信必然会失败。所以我们需要为客户端创建一个保存所有信任证书的仓库，然后把服务端证书导进这个仓库。这样，当客户端连接服务端时，会发现服务端的证书在自己的信任列表中，就可以正常通信了。

因此现在我们要做的是生成一个客户端的证书仓库，__因为keytool不能仅生成一个空白仓库，所以和服务端一样，我们还是生成一个证书加一个仓库（客户端证书加仓库）__

__生成数字证书和证书仓库__

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

__接下来，我们要把服务端的证书导出来，并导入到客户端的仓库。第一步是导出服务端的证书__

```sh
keytool -export -alias liuyehcf_server_key -keystore ~/liuyehcf_server_ks -file ~/server_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/server_key.cer> 中的证书
```

__然后是把导出的证书导入到客户端证书仓库__

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

## 4.3 SSLServer

```Java
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

## 4.4 SSLClient

```Java
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

## 4.5 双向认证

上述示例中，仅仅客户端对服务端做了单向认证，如果要进行双向认证，需要将客户端的证书添加到服务端的keyStore中

__接下来，我们要把客户端的证书导出来，并导入到服务端的仓库。第一步是导出客户端的证书__

```sh
keytool -export -alias liuyehcf_client_key -keystore ~/liuyehcf_client_ks -file ~/client_key.cer

# 以下为输出内容
输入密钥库口令:
存储在文件 </Users/HCF/client_key.cer> 中的证书
```

__然后是把导出的证书导入到服务端证书仓库__

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

__改造服务端的代码__

```Java
((SSLServerSocket) socket).setNeedClientAuth(false);

// 改为

((SSLServerSocket) socket).setNeedClientAuth(true);
```

# 5 在Netty中使用SSL

详见{% post_link Netty-Demo %}

# 6 参考

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
