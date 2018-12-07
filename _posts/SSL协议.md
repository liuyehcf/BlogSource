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

# 1 keytool

## 1.1 cmd

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

## 1.2 Java-Api

```Java
package org.liuyehcf.ssl;

import sun.security.tools.keytool.CertAndKeyGen;
import sun.security.x509.X500Name;

import javax.crypto.KeyGenerator;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.security.Key;
import java.security.KeyStore;
import java.security.cert.X509Certificate;

/**
 * @author hechenfeng
 * @date 2018/12/7
 */
public class KeyTool {

    private static final String KEY_STORE_PATH = "/tmp/keyStore.ks";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String KEY_STORE_TYPE = "PKCS12";

    private static final String KEY_PASSWORD = "654321";

    private static final String ALIAS_SECRET = "key_secret";
    private static final String ALIAS_PRIVATE = "key_private";
    private static final String ALIAS_CERT = "key_cert";

    public static void main(String[] args) {
        createKeyStore();
        createSecretEntry();
        createPrivateEntryAndCert();
        storeCert();
        loadPrivateEntry();
        getCert();
        loadCert();
    }

    private static void createKeyStore() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(null, null);

            keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void createSecretEntry() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
            keyGen.init(128);
            Key key = keyGen.generateKey();
            keyStore.setKeyEntry(ALIAS_SECRET, key, KEY_PASSWORD.toCharArray(), null);

            keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void createPrivateEntryAndCert() {
        try {
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
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void storeCert() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

            CertAndKeyGen gen = new CertAndKeyGen("RSA", "SHA1WithRSA");
            gen.generate(1024);

            X509Certificate cert = gen.getSelfCertificate(new X500Name("CN=ROOT"), (long) 365 * 24 * 3600);

            keyStore.setCertificateEntry(ALIAS_CERT, cert);

            keyStore.store(new FileOutputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void loadPrivateEntry() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

            Key pvtKey = keyStore.getKey(ALIAS_PRIVATE, KEY_PASSWORD.toCharArray());
            System.out.println(pvtKey.toString());
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void loadCert() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

            Key pvtKey = keyStore.getKey(ALIAS_PRIVATE, KEY_PASSWORD.toCharArray());
            System.out.println(pvtKey.toString());

            java.security.cert.Certificate[] chain = keyStore.getCertificateChain(ALIAS_PRIVATE);
            for (java.security.cert.Certificate cert : chain) {
                System.out.println(cert.toString());
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    private static void getCert() {
        try {
            KeyStore keyStore = KeyStore.getInstance(KEY_STORE_TYPE);
            keyStore.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());

            java.security.cert.Certificate cert = keyStore.getCertificate(ALIAS_PRIVATE);

            System.out.println(cert);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
```

# 2 JKS

## 2.1 服务端

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

## 2.2 客户端

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

## 2.3 SSLServer

```Java
package org.liuyehcf.ssl;

import javax.net.ServerSocketFactory;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLServerSocket;
import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.security.KeyStore;

public class SSLServer extends Thread {

    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_server_ks";
    private static final String KEY_STORE_PASSWORD = "123456";
    private static final String PRIVATE_PASSWORD = "234567";

    private Socket socket;

    private SSLServer(Socket socket) {
        this.socket = socket;
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

    public static void main(String[] args) throws Exception {
        System.setProperty("javax.net.ssl.trustStore", KEY_STORE_PATH);

        KeyStore ks = KeyStore.getInstance("jceks");
        ks.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
        KeyManagerFactory kf = KeyManagerFactory.getInstance("SunX509");
        kf.init(ks, PRIVATE_PASSWORD.toCharArray());

        SSLContext context = SSLContext.getInstance("TLS");
        context.init(kf.getKeyManagers(), null, null);
        ServerSocketFactory factory = context.getServerSocketFactory();
        ServerSocket socket = factory.createServerSocket(8443);
        ((SSLServerSocket) socket).setNeedClientAuth(false);

        while (!Thread.currentThread().isInterrupted()) {
            new SSLServer(socket.accept()).start();
        }
    }
}
```

## 2.4 SSLClient

```Java
package org.liuyehcf.ssl;

import javax.net.SocketFactory;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import java.io.*;
import java.net.Socket;
import java.security.KeyStore;

public class SSLClient {
    private static final String KEY_STORE_PATH = System.getProperty("user.home") + File.separator + "liuyehcf_client_ks";
    private static final String KEY_STORE_PASSWORD = "345678";
    private static final String KEY_PASSWORD = "456789";

    public static void main(String[] args) throws Exception {
        // Set the key store to use for validating the server cert.
        System.setProperty("javax.net.ssl.trustStore", KEY_STORE_PATH);
        System.setProperty("javax.net.debug", "ssl,handshake");
        SSLClient client = new SSLClient();
        Socket s = client.clientWithoutCert();

        PrintWriter writer = new PrintWriter(s.getOutputStream());
        BufferedReader reader = new BufferedReader(new InputStreamReader(s.getInputStream()));
        writer.println("hello");
        writer.flush();
        System.out.println(reader.readLine());
        s.close();
    }

    private Socket clientWithoutCert() throws Exception {
        SocketFactory sf = SSLSocketFactory.getDefault();
        return sf.createSocket("localhost", 8443);
    }

    private Socket clientWithCert() throws Exception {
        KeyStore ks = KeyStore.getInstance("jceks");

        ks.load(new FileInputStream(KEY_STORE_PATH), KEY_STORE_PASSWORD.toCharArray());
        KeyManagerFactory kf = KeyManagerFactory.getInstance("SunX509");
        kf.init(ks, KEY_PASSWORD.toCharArray());

        SSLContext context = SSLContext.getInstance("TLS");
        context.init(kf.getKeyManagers(), null, null);
        SocketFactory factory = context.getSocketFactory();
        return factory.createSocket("localhost", 8443);
    }
}
```

## 2.5 双向认证

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

__改造客户端的代码__

```Java
Socket s = client.clientWithoutCert();

// 改为

Socket s = client.clientWithCert();
```

# 3 PKCS12

## 3.1 服务端

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

## 3.2 客户端

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

# 4 参考

* [Java SSL](https://blog.csdn.net/everyok/article/details/82882156)
* [SSL介绍与Java实例](http://www.cnblogs.com/crazyacking/p/5648520.html)
* [Java不同类型密钥库之PKCS12和JCEKS](https://www.csdn.net/article/2015-01-06/2823434)
* [PKCS12 证书的生成及验证](https://blog.csdn.net/kmyhy/article/details/6431609)
* [Java Code Examples for javax.net.ssl.SSLContext](https://www.programcreek.com/java-api-examples/?api=javax.net.ssl.SSLContext)
* [java PKCS12双向认证](https://blog.csdn.net/bolg_hero/article/details/71170606)
