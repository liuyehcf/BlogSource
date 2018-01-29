---
title: Java-安全模型
date: 2018-01-19 19:03:38
tags: 
- 摘录
categories: 
- Java
- Security Model
---

__目录__

<!-- toc -->
<!--more-->

# 1 基本概念

## 1.1 代码源（CodeSource）

CodeSource就是一个简单的类，用来声明从哪里加载类

CodeSource有一个重要的字段

```Java
    private URL location;
```

## 1.2 权限（Permission）

Permission类是AccessController处理的基本实体

__Permission类本身是抽象的，它的一个实例代表一个具体的权限（例如FilePermission的实例就表示了哪个文件的什么权限，读/写等等）__。权限有两个作用，一个是允许Java API完成对某些资源的访问。另一个是可以为自定义权限提供一个范本。权限包含了权限类型、权限名和一组权限操作。具体可以看看BasicPermission类的代码。典型的也可以参看FilePermission的实现。

__Permission继承属性结构如下（从这里可以得知Java对哪些资源进行了管理）__：

* Permission (java.security)
    * CryptoPermission (javax.crypto)
        * CryptoAllPermission (javax.crypto)
    * BasicPermission (java.security)
        * SecureCookiePermission (com.sun.deploy.security)
        * NetworkPermission (jdk.net)
        * DelegationPermission (javax.security.auth.kerberos)
        * BridgePermission (sun.corba)
        * SubjectDelegationPermission (javax.management.remote)
        * BufferSecretsPermission (com.oracle.nio)
        * InquireSecContextPermission (com.sun.security.jgss)
        * PropertyPermission (java.util)
        * SerializablePermission (java.io)
        * NetPermission (java.net)
        * OgnlInvokePermission (org.apache.ibatis.ognl)
        * DeployXmlPermission (org.apache.catalina.security)
        * AWTPermission (java.awt)
        * WebServicePermission (javax.xml.ws)
        * AudioPermission (javax.sound.sampled)
        * SSLPermission (com.sun.net.ssl)
        * ReflectPermission (java.lang.reflect)
        * SecurityPermission (java.security)
        * AttachPermission (com.sun.tools.attach)
        * SSLPermission (javax.net.ssl)
        * JavaScriptPermission (sun.plugin.liveconnect)
        * SQLPermission (java.sql)
        * MBeanTrustPermission (javax.management)
        * JDIPermission (com.sun.jdi)
        * MBeanServerPermission (javax.management)
        * LoggingPermission (java.util.logging)
        * DynamicAccessPermission (com.sun.corba.se.impl.presentation.rmi)
        * JAXBPermission (javax.xml.bind)
        * HibernateValidatorPermission (org.hibernate.validator)
        * RuntimePermission (java.lang)
        * SnmpPermission (com.sun.jmx.snmp)
        * ManagementPermission (java.lang.management)
        * AuthPermission (javax.security.auth)
        * LinkPermission (java.nio.file)
    * UnresolvedPermission (java.security)
    * PrivateCredentialPermission (javax.security.auth)
    * SelfPermission in PolicyFile (sun.security.provider)
    * URLPermission (java.net)
    * MBeanPermission (javax.management)
    * AllPermission (java.security)
    * ExecOptionPermission (com.sun.rmi.rmid)
    * CardPermission (javax.smartcardio)
    * FilePermission (java.io)
    * ServicePermission (javax.security.auth.kerberos)
    * SocketPermission (java.net)
    * ExecPermission (com.sun.rmi.rmid)

## 1.3 策略（Policy）

策略是一组权限的总称，用于确定权限应该用于哪些代码源。话说回来，代码源标识了类的来源，权限声明了具体的限制。那么策略就是将二者联系起来，策略类Policy主要的方法就是getPermissions(CodeSource)和refresh()方法。Policy类在老版本中是abstract的，且这两个方法也是。在jdk1.8中已经不再有abstract方法。这两个方法也都有了默认实现。

在JVM中，任何情况下只能安装一个策略类的实例。安装策略类可以通过Policy.setPolicy()方法来进行，也可以通过java.security文件里的policy.provider=sun.security.provider.PolicyFile来进行。jdk1.6以后，Policy引入了PolicySpi，后续的扩展基于SPI进行。

## 1.4 保护域（ProtectionDomain）

保护域可以理解为代码源和相应权限的一个组合。表示指派给一个代码源的所有权限。看概念，感觉和策略很像，其实策略要比这个大一点，保护域是一个代码源的一组权限，而策略是所有的代码源对应的所有的权限的关系。

JVM中的每一个类都一定属于且仅属于一个保护域，这由ClassLoader在define class的时候决定。但不是每个ClassLoader都有相应的保护域，核心Java API的ClassLoader就没有指定保护域，可以理解为属于系统保护域。

# 2 AccessController

了解了组成，再回头看AccessController。这是一个无法实例化的类——仅仅可以使用其static方法

AccessController最重要的方法就是checkPermission()方法，作用是基于已经安装的Policy对象，能否得到某个权限

例如FileInputStream的构造方法就利用SecurityManager来checkRead

```Java
    public FileInputStream(File file) throws FileNotFoundException {
        String name = (file != null ? file.getPath() : null);
        SecurityManager security = System.getSecurityManager();
        if (security != null) {
            /* ！看这里！ */
            security.checkRead(name);
        }
        if (name == null) {
            throw new NullPointerException();
        }
        if (file.isInvalid()) {
            throw new FileNotFoundException("Invalid file path");
        }
        fd = new FileDescriptor();
        fd.attach(this);
        path = name;
        open(name);
    }
```

继续查看SecurityManager的checkRead方法

```Java
    public void checkRead(String file) {
        checkPermission(new FilePermission(file,
            SecurityConstants.FILE_READ_ACTION));
    }
```

然而，AccessController的使用还是重度关联类加载器的。__如果都是一个类加载器且都从一个保护域加载类，那么你构造的checkPermission的方法将正常返回__

当使用了其他类加载器或者使用了Java扩展包时，这种情况比较普遍。AccessController另一个比较实用的功能是doPrivilege（授权）：__假设一个保护域A有读文件的权限，另一个保护域B没有。那么通过AccessController.doPrivileged方法，可以将该权限临时授予B保护域的类。而这种授权是单向的。__也就是说，它__可以为调用它的代码授权__，但是__不能为它调用的代码授权__

# 3 Demo

__我的IDEA工程目录如下，其中security是一个子模块，下面的代码中会涉及到多个路径的配置，这些路径都是基于父模块的相对路径__

* ![fig1](/images/Java-安全模型/fig1)

首先，有一个代码源，我这里提供一个`external.jar`，该jar中只包含一个class文件，其源码如下：
```Java
package org.liuyehcf.security;

import java.io.File;
import java.io.IOException;
import java.security.AccessControlException;
import java.security.AccessController;
import java.security.PrivilegedAction;

/**
 * Created by HCF on 2018/1/10.
 */
public class FileUtils {
    public static void createFile(String baseDir, String simpleName) {
        File file = new File(baseDir + "/" + simpleName);

        System.out.println("[ INFO ] - " + "FILE PATH: " + file.getAbsolutePath());

        try {
            if (file.exists() && file.isFile()) {
                file.delete();
            }
            if (file.createNewFile()) {
                System.out.println("[ INFO ] - Create File Success!");
            }
        } catch (IOException | AccessControlException e) {
            System.err.println("[ ERROR ] - Create File Failure!");
            e.printStackTrace();
        }
    }

    public static void createFilePrivilege(String baseDir, String simpleName) {
        AccessController.doPrivileged(new PrivilegedAction<Object>() {
            @Override
            public Object run() {
                createFile(baseDir, simpleName);
                return null;
            }
        });
    }
}
```

其次，编写policy文件。policy文件的编写可以利用Java命令行工具：`policytool`

```
grant codeBase "file:security/src/main/resources/external.jar" {
    permission java.io.FilePermission "security/src/main/resources/targetDir/*", "write, read, delete";
    permission java.util.PropertyPermission "user.dir", "read";
};
```

上述配置文件的含义如下：

1. 为`file:security/src/main/resources/external.jar`配置`security/src/main/resources/targetDir/*`中写、读、删除文件的权限
1. 为`file:security/src/main/resources/external.jar`配置__读用户目录这一系统属性__的权限

然后编写测试类ReflectAccessControllerDemo，如下

```Java
package org.liuyehcf.security;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.URL;
import java.net.URLClassLoader;

/**
 * Created by HCF on 2018/1/10.
 */
public class ReflectAccessControllerDemo {

    private static final String TARGET_DIR = "security/src/main/resources/targetDir";
    private static final String JAR = "security/src/main/resources/external.jar";
    private static final String TEST_CLASS = "org.liuyehcf.security.FileUtils";

    public static void main(String[] args) {
        Class clazz;
        try {
            // 构造类加载器，加载位于resources路径下的external.jar中的类
            clazz = new URLClassLoader(
                    new URL[]{
                            new URL("file:" + JAR)
                    }).loadClass(TEST_CLASS);
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            return;
        }

        // 打开安全管理器
        System.setSecurityManager(new SecurityManager());

        Method createFileMethod;
        Method createFilePrivilegeMethod;
        try {
            createFileMethod = clazz.getMethod("createFile", String.class, String.class);
            createFilePrivilegeMethod = clazz.getMethod("createFilePrivilege", String.class, String.class);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
            return;
        }

        try {
            // 普通方法
            createFileMethod.invoke(null, TARGET_DIR, "file1.md");
        } catch (InvocationTargetException | IllegalAccessException e) {
            e.printStackTrace();
        }

        try {
            // 特权方法
            createFilePrivilegeMethod.invoke(null, TARGET_DIR, "file2.md");
        } catch (InvocationTargetException | IllegalAccessException e) {
            e.printStackTrace();
        }
    }
}
```

最后，执行。注意添加VM参数指定policy文件的路径，例如

* `-Djava.security.policy=security/src/main/resources/security.policy`

运行结果如下：

```Java
java.lang.reflect.InvocationTargetException
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:498)
	at org.liuyehcf.security.ReflectAccessControllerDemo.main(ReflectAccessControllerDemo.java:43)
Caused by: java.security.AccessControlException: access denied ("java.util.PropertyPermission" "user.dir" "read")
	at java.security.AccessControlContext.checkPermission(AccessControlContext.java:472)
	at java.security.AccessController.checkPermission(AccessController.java:884)
	at java.lang.SecurityManager.checkPermission(SecurityManager.java:549)
	at java.lang.SecurityManager.checkPropertyAccess(SecurityManager.java:1294)
	at java.lang.System.getProperty(System.java:717)
	at java.io.UnixFileSystem.resolve(UnixFileSystem.java:133)
	at java.io.File.getAbsolutePath(File.java:556)
	at org.liuyehcf.security.FileUtils.createFile(FileUtils.java:16)
	... 5 more
[ INFO ] - FILE PATH: /Users/HCF/Workspaces/IdeaWorkspace/JavaLearning/security/src/main/resources/targetDir/file2.md
[ INFO ] - Create File Success!

```

解释一下这个Demo的意义：

1. 首先，为代码源`external.jar`中的`FileUtils`配置了一些权限（在指定路径读写文件的权限，以及读取用户主目录的权限）
1. 让`ReflectAccessControllerDemo`通过调用`FileUtils`的`createFilePrivilege`方法（该方法会调用AccessController.doPrivileged来绕过权限检查）来获取访问这些资源的特权。__即为调用它的代码授权__，它指的是`FileUtils`，代码指的是`ReflectAccessControllerDemo`

# 4 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [Fusion Middleware Security Guide](https://docs.oracle.com/cd/E12839_01/core.1111/e10043/introjps.htm#JISEC3817)
* [Java安全——安全管理器、访问控制器和类装载器](https://yq.aliyun.com/articles/57223?&utm_source=qq)
* [Java 授权内幕](https://www.ibm.com/developerworks/cn/java/j-javaauth/)
* [关于AccessController.doPrivileged](http://blog.csdn.net/laiwenqiang/article/details/54321588)
* [JAVA安全模型](https://www.cnblogs.com/metoy/p/5347487.html)
