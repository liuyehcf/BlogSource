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

# 1 Java&SSL

## 1.1 keytool

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

## 1.2 服务端

Java环境下，数字证书是用`keytool`生成的，这些证书被存储在`store`中，就是证书仓库。我们来调用keytool命令为服务端生成数字证书和保存它使用的证书仓库：

__生成数字证书和证书仓库__

* 证书名称：`liuyehcf_server_key`
* 证书仓库路径：`~/liuyehcf_server_ks`

```sh
keytool -genkey -v -alias liuyehcf_server_key -keyalg RSA -keystore ~/liuyehcf_server_ks -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 123456 -keypass 123456

# 以下为输出内容
正在为以下对象生成 2,048 位RSA密钥对和自签名证书 (SHA256withRSA) (有效期为 90 天):
	 CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
[正在存储/Users/HCF/liuyehcf_server_ks]

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_server_ks -destkeystore /Users/HCF/liuyehcf_server_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

## 1.3 客户端

有了服务端，我们原来的客户端就不能使用了，必须要走SSL协议。由于服务端的证书是我们自己生成的，没有任何受信任机构的签名，所以客户端是无法验证服务端证书的有效性的，通信必然会失败。所以我们需要为客户端创建一个保存所有信任证书的仓库，然后把服务端证书导进这个仓库。这样，当客户端连接服务端时，会发现服务端的证书在自己的信任列表中，就可以正常通信了。

因此现在我们要做的是生成一个客户端的证书仓库，__因为keytool不能仅生成一个空白仓库，所以和服务端一样，我们还是生成一个证书加一个仓库（客户端证书加仓库）__

__生成数字证书和证书仓库__

* 证书名称：`liuyehcf_client_key`
* 证书仓库路径：`~/liuyehcf_client_ks`

```sh
keytool -genkey -v -alias liuyehcf_client_key -keyalg RSA -keystore ~/liuyehcf_client_ks -dname "CN=localhost,OU=cn,O=cn,L=cn,ST=cn,C=cn" -storepass 123456 -keypass 123456

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
入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: 17e9c12
有效期为 Sun Dec 02 19:50:14 CST 2018 至 Sat Mar 02 19:50:14 CST 2019
证书指纹:
	 MD5:  0C:FB:7C:19:27:66:65:CC:61:DF:AE:77:20:E0:06:B4
	 SHA1: 1F:B7:E9:C6:C7:63:A7:DD:1A:D0:13:47:DC:21:4E:6D:EE:25:44:CF
	 SHA256: 3B:0F:74:58:2F:D3:30:3B:73:2F:10:C5:1D:46:E4:31:E0:3D:A3:2C:BD:C7:F1:D1:92:56:FD:60:E5:3A:F9:A2
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 89 02 0F 51 D6 DE 82 4D   EC F7 E6 12 3F 91 02 C4  ...Q...M....?...
0010: 3C 17 FB 66                                        <..f
]
]

是否信任此证书? [否]:  y
证书已添加到密钥库中

Warning:
JKS 密钥库使用专用格式。建议使用 "keytool -importkeystore -srckeystore /Users/HCF/liuyehcf_client_ks -destkeystore /Users/HCF/liuyehcf_client_ks -deststoretype pkcs12" 迁移到行业标准格式 PKCS12。
```

## 1.4 SSLServer

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

    private static final String SERVER_KEY_STORE = "/Users/HCF/liuyehcf_server_ks";
    private static final String SERVER_KEY_STORE_PASSWORD = "123456";

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
        System.setProperty("javax.net.ssl.trustStore", SERVER_KEY_STORE);
        SSLContext context = SSLContext.getInstance("TLS");

        KeyStore ks = KeyStore.getInstance("jceks");
        ks.load(new FileInputStream(SERVER_KEY_STORE), null);
        KeyManagerFactory kf = KeyManagerFactory.getInstance("SunX509");
        kf.init(ks, SERVER_KEY_STORE_PASSWORD.toCharArray());
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

## 1.5 SSLClient

```Java
package org.liuyehcf.ssl;

import javax.net.SocketFactory;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.security.KeyStore;

public class SSLClient {
    private static final String CLIENT_KEY_STORE = "/Users/HCF/liuyehcf_client_ks";
    private static final String CLIENT_KEY_STORE_PASSWORD = "123456";

    public static void main(String[] args) throws Exception {
        // Set the key store to use for validating the server cert.
        System.setProperty("javax.net.ssl.trustStore", CLIENT_KEY_STORE);
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
        SSLContext context = SSLContext.getInstance("TLS");
        KeyStore ks = KeyStore.getInstance("jceks");

        ks.load(new FileInputStream(CLIENT_KEY_STORE), null);
        KeyManagerFactory kf = KeyManagerFactory.getInstance("SunX509");
        kf.init(ks, CLIENT_KEY_STORE_PASSWORD.toCharArray());
        context.init(kf.getKeyManagers(), null, null);

        SocketFactory factory = context.getSocketFactory();
        return factory.createSocket("localhost", 8443);
    }
}
```

## 1.6 双向认证

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
入密钥库口令:
所有者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
发布者: CN=localhost, OU=cn, O=cn, L=cn, ST=cn, C=cn
序列号: 1d127483
有效期为 Sun Dec 02 19:50:37 CST 2018 至 Sat Mar 02 19:50:37 CST 2019
证书指纹:
	 MD5:  65:BF:31:22:C2:FE:06:72:B9:49:53:E8:98:33:6F:30
	 SHA1: 2B:74:99:F4:44:22:31:28:06:27:55:01:0F:FE:8A:54:E8:3F:EF:1A
	 SHA256: FD:6A:9E:DB:3C:2A:22:10:A2:C0:69:89:A4:81:A9:13:6B:86:1D:4B:CC:7C:DA:97:5B:B0:32:37:7E:A4:3A:2A
签名算法名称: SHA256withRSA
主体公共密钥算法: 2048 位 RSA 密钥
版本: 3

扩展:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 02 9C 65 8D D8 65 55 2A   22 0A 1E C8 62 50 6B FE  ..e..eU*"...bPk.
0010: 87 79 1F 67                                        .y.g
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

# 2 参考

* [Java SSL](https://blog.csdn.net/everyok/article/details/82882156)
* [SSL介绍与Java实例](http://www.cnblogs.com/crazyacking/p/5648520.html)
