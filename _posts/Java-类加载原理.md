---
title: Java-类加载原理
date: 2018-01-06 14:56:15
tags: 
- 摘录
categories: 
- Java
- 容器
- 类隔离技术
password: 19930101
---

__目录__

<!-- toc -->
<!--more-->

# 1 类加载器的分类

通常，在我们需要动态加载一个类的时候，总有三个类加载器可以使用，它们分别是

1. system classloader：系统类加载器（或者称为应用类加载器，application classloader）
1. current classloader：当前类加载器（__CCL的加载过程是由JVM运行时来控制的，是无法通过Java编程来更改的__）
1. current thread context classloader：线程上下文类加载器

那么问题来了，我们应该选择哪个类加载器去加载呢，或者说JVM会使用哪个类加载器去加载呢

首先排除掉的是system classloader（系统类加载器），这个类加载器用于加载`-classpath`路径下的类，并且可以通过静态方法`ClassLoader.getSystemClassLoader()`来获得。实际上，我们很少在代码中明确使用系统类加载器来加载类，因为我们总是可以通过其他类加载器并通过委托到达系统类加载器。如果你编写的程序运行在__最后一个ClassLoader__是AppClassLoader的情况下，那么你的代码就只能工作于命令行中，即通过`-classpath`参数来指定类加载路径，如果程序运行于Web容器中，那么这种方式就行不通了

current classloader是当前方法所属类的类加载器。通俗来讲，类A中使用了类B（类B在此前并未加载），那么会使用加载A的加载器来加载B。等效于通过`A.class.getClassLoader().loadClass("B");`来加载。另外还可以通过查询栈信息（`sun.misc.VM.latestUserDefinedLoader()`），获取第一个不为空的classloader

ContextClassLoader是作为Thread的一个成员变量出现的，一个线程在构造的时候，它会从parent线程中继承这个ClassLoader。__使用线程上下文类加载器，可以在执行线程中抛弃双亲委派加载链模式，使用线程上下文里的类加载器加载类__。CurrentClassLoader对用户来说是自动的，隐式的，而ContextClassLoader需要显示的使用，先进行设置然后再进行使用

## 1.1 Class#forName的类加载过程

forName用于加载一个类并且会执行后续操作，包括验证，解析，初始化。并且触发static字段以及static域的执行

```Java
    public static Class<?> forName(String className)
                throws ClassNotFoundException {
        Class<?> caller = Reflection.getCallerClass();
        return forName0(className, true, ClassLoader.getClassLoader(caller), caller);
    }
```

这里`Reflection.getCallerClass`是一个native方法，用于获取调用`Class#forName`方法的实例所属的Class对象。其次，forName0也是一个native方法

接下来我们会查看openjdk中的相关C++源码，openjdk的起始路径记为`${OPEN_JDK}`，我们将以如下形式来表示源码文件的位置

* `${OPEN_JDK}/path1/path2/path3/source.c`

首先查看forName0对应的native方法，路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/Class.c`

```C
JNIEXPORT jclass JNICALL
Java_java_lang_Class_forName0(JNIEnv *env, jclass this, jstring classname,
                              jboolean initialize, jobject loader, jclass caller)
{
    char *clname;
    jclass cls = 0;
    char buf[128];
    jsize len;
    jsize unicode_len;

    if (classname == NULL) {
        JNU_ThrowNullPointerException(env, 0);
        return 0;
    }

    len = (*env)->GetStringUTFLength(env, classname);
    unicode_len = (*env)->GetStringLength(env, classname);
    if (len >= (jsize)sizeof(buf)) {
        clname = malloc(len + 1);
        if (clname == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            return NULL;
        }
    } else {
        clname = buf;
    }
    (*env)->GetStringUTFRegion(env, classname, 0, unicode_len, clname);

    if (VerifyFixClassname(clname) == JNI_TRUE) {
        /* slashes present in clname, use name b4 translation for exception */
        (*env)->GetStringUTFRegion(env, classname, 0, unicode_len, clname);
        JNU_ThrowClassNotFoundException(env, clname);
        goto done;
    }

    if (!VerifyClassname(clname, JNI_TRUE)) {  /* expects slashed name */
        JNU_ThrowClassNotFoundException(env, clname);
        goto done;
    }

    // 重点看这里，调用了JVM_FindClassFromCaller方法
    cls = JVM_FindClassFromCaller(env, clname, initialize, loader, caller);

 done:
    if (clname != buf) {
        free(clname);
    }
    return cls;
}
```

我们继续查找JVM_FindClassFromCaller的声明，文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`

```C
/*
 * Find a class from a given class loader.  Throws ClassNotFoundException.
 *  name:   name of class
 *  init:   whether initialization is done
 *  loader: class loader to look up the class. This may not be the same as the caller's
 *          class loader.
 *  caller: initiating class. The initiating class may be null when a security
 *          manager is not installed.
 */
JNIEXPORT jclass JNICALL
JVM_FindClassFromCaller(JNIEnv *env, const char *name, jboolean init,
                        jobject loader, jclass caller);

```

只找到了声明，定义包含在dll中无法查看。该方法以类全限定名和ClassLoader的引用来查找指定的Class。如果命中了，那么返回Class对象，并且执行后续验证、解析、初始化的操作，至此Class#forName结束

如果没有命中，通过debug可以发现，该方法会继续调用ClassLoader.loadClass(String)方法，此时回传的ClassLoader就是Class#forName中的`ClassLoader.getClassLoader(caller)`获取的类加载器，一般来说就是`AppClassLoader`

```Java
    public Class<?> loadClass(String name) throws ClassNotFoundException {
        return loadClass(name, false);
    }
```

通过debug发现继续调用`sun.misc.Launcher.AppClassLoader.loadClass`方法，该方法

```Java
        public Class<?> loadClass(String var1, boolean var2) throws ClassNotFoundException {
            int var3 = var1.lastIndexOf(46);
            if(var3 != -1) {
                SecurityManager var4 = System.getSecurityManager();
                if(var4 != null) {
                    var4.checkPackageAccess(var1.substring(0, var3));
                }
            }

            if(this.ucp.knownToNotExist(var1)) {
                Class var5 = this.findLoadedClass(var1);
                if(var5 != null) {
                    if(var2) {
                        this.resolveClass(var5);
                    }

                    return var5;
                } else {
                    throw new ClassNotFoundException(var1);
                }
            } else {
                // 会走到这里，继续调用父类的loadClass方法
                return super.loadClass(var1, var2);
            }
        }
```

AppClassLoader的父类是ClassLoader，其loadClass方法如下

```Java
    protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            // First, check if the class has already been loaded
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                // 双亲委派逻辑的体现之处
                try {
                    if (parent != null) {
                        c = parent.loadClass(name, false);
                    } else {
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                    // ClassNotFoundException thrown if class not found
                    // from the non-null parent class loader
                }

                if (c == null) {
                    // If still not found, then invoke findClass in order
                    // to find the class.
                    long t1 = System.nanoTime();
                    c = findClass(name);

                    // this is the defining class loader; record the stats
                    sun.misc.PerfCounter.getParentDelegationTime().addTime(t1 - t0);
                    sun.misc.PerfCounter.getFindClassTime().addElapsedTimeFrom(t1);
                    sun.misc.PerfCounter.getFindClasses().increment();
                }
            }
            if (resolve) {
                resolveClass(c);
            }
            return c;
        }
    }

    protected final Class<?> findLoadedClass(String name) {
        if (!checkName(name))
            return null;
        // native方法
        return findLoadedClass0(name);
    }
```

loadClass(String,bool)方法首先调用native方法findLoadedClass0在JVM中查找缓存，findLoadedClass0定义所在的文件路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/ClassLoader.c`

```C
JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_findLoadedClass0(JNIEnv *env, jobject loader,
                                           jstring name)
{
    if (name == NULL) {
        return 0;
    } else {
        return JVM_FindLoadedClass(env, loader, name);
    }
}
```

继续定位JVM_FindLoadedClass，该函数的定义同样无法查看，该函数的声明所在文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`

```C
/* Find a loaded class cached by the VM */
JNIEXPORT jclass JNICALL
JVM_FindLoadedClass(JNIEnv *env, jobject loader, jstring name);
```

如果命中了直接返回。如果没有命中，则根据双亲委派模型依次调用双亲类加载器加载。

如果仍然没有加载到，那么调用findClass方法，findClass在ClassLoader中定义，但是提供了空实现，不同的子类负责实现不同的逻辑，用以达到不同的类加载路径的效果。

我们继续以AppClassLoader为例进行分析，AppClassLoader的findClass实现如下：

```Java
    protected Class<?> findClass(final String name)
        throws ClassNotFoundException
    {
        final Class<?> result;
        try {
            result = AccessController.doPrivileged(
                new PrivilegedExceptionAction<Class<?>>() {
                    public Class<?> run() throws ClassNotFoundException {
                        String path = name.replace('.', '/').concat(".class");
                        Resource res = ucp.getResource(path, false);
                        if (res != null) {
                            try {
                                return defineClass(name, res);
                            } catch (IOException e) {
                                throw new ClassNotFoundException(name, e);
                            }
                        } else {
                            return null;
                        }
                    }
                }, acc);
        } catch (java.security.PrivilegedActionException pae) {
            throw (ClassNotFoundException) pae.getException();
        }
        if (result == null) {
            throw new ClassNotFoundException(name);
        }
        return result;
    }
```

关注核心调用，defineClass（AppClassLoader中的private方法），如下：

```Java
    private Class<?> defineClass(String name, Resource res) throws IOException {
        long t0 = System.nanoTime();
        int i = name.lastIndexOf('.');
        URL url = res.getCodeSourceURL();
        if (i != -1) {
            String pkgname = name.substring(0, i);
            // Check if package already loaded.
            Manifest man = res.getManifest();
            definePackageInternal(pkgname, man, url);
        }
        // Now read the class bytes and define the class
        java.nio.ByteBuffer bb = res.getByteBuffer();
        if (bb != null) {
            // Use (direct) ByteBuffer:
            CodeSigner[] signers = res.getCodeSigners();
            CodeSource cs = new CodeSource(url, signers);
            sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);

            // 核心调用
            return defineClass(name, bb, cs);
        } else {
            byte[] b = res.getBytes();
            // must read certificates AFTER reading bytes.
            CodeSigner[] signers = res.getCodeSigners();
            CodeSource cs = new CodeSource(url, signers);
            sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);

            // 核心调用
            return defineClass(name, b, 0, b.length, cs);
        }
    }
```

其中不同支路的defineClass都会定向为native方法defineClass0、defineClass1、defineClass2。它们负责将class文件代表的字节数组交给VM，然后由VM验证其格式的正确性。Class与ClassLoader实例关系的绑定就是在defineClass的调用过程中确定的

native方法defineClass0、defineClass1、defineClass2所在的文件路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/ClassLoader.c`

```C
// The existence or signature of this method is not guaranteed since it
// supports a private method.  This method will be changed in 1.7.
JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_defineClass0(JNIEnv *env,
                                        jobject loader,
                                        jstring name,
                                        jbyteArray data,
                                        jint offset,
                                        jint length,
                                        jobject pd)
{
    // 转调用Java_java_lang_ClassLoader_defineClass1
    return Java_java_lang_ClassLoader_defineClass1(env, loader, name, data, offset,
                                                   length, pd, NULL);
}

JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_defineClass1(JNIEnv *env,
                                        jobject loader,
                                        jstring name,
                                        jbyteArray data,
                                        jint offset,
                                        jint length,
                                        jobject pd,
                                        jstring source)
{
    jbyte *body;
    char *utfName;
    jclass result = 0;
    char buf[128];
    char* utfSource;
    char sourceBuf[1024];

    if (data == NULL) {
        JNU_ThrowNullPointerException(env, 0);
        return 0;
    }

    /* Work around 4153825. malloc crashes on Solaris when passed a
     * negative size.
     */
    if (length < 0) {
        JNU_ThrowArrayIndexOutOfBoundsException(env, 0);
        return 0;
    }

    body = (jbyte *)malloc(length);

    if (body == 0) {
        JNU_ThrowOutOfMemoryError(env, 0);
        return 0;
    }

    (*env)->GetByteArrayRegion(env, data, offset, length, body);

    if ((*env)->ExceptionOccurred(env))
        goto free_body;

    if (name != NULL) {
        utfName = getUTF(env, name, buf, sizeof(buf));
        if (utfName == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            goto free_body;
        }
        VerifyFixClassname(utfName);
    } else {
        utfName = NULL;
    }

    if (source != NULL) {
        utfSource = getUTF(env, source, sourceBuf, sizeof(sourceBuf));
        if (utfSource == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            goto free_utfName;
        }
    } else {
        utfSource = NULL;
    }

    // 核心调用
    result = JVM_DefineClassWithSource(env, utfName, loader, body, length, pd, utfSource);

    if (utfSource && utfSource != sourceBuf)
        free(utfSource);

 free_utfName:
    if (utfName && utfName != buf)
        free(utfName);

 free_body:
    free(body);
    return result;
}

JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_defineClass2(JNIEnv *env,
                                        jobject loader,
                                        jstring name,
                                        jobject data,
                                        jint offset,
                                        jint length,
                                        jobject pd,
                                        jstring source)
{
    jbyte *body;
    char *utfName;
    jclass result = 0;
    char buf[128];
    char* utfSource;
    char sourceBuf[1024];

    assert(data != NULL); // caller fails if data is null.
    assert(length >= 0);  // caller passes ByteBuffer.remaining() for length, so never neg.
    // caller passes ByteBuffer.position() for offset, and capacity() >= position() + remaining()
    assert((*env)->GetDirectBufferCapacity(env, data) >= (offset + length));

    body = (*env)->GetDirectBufferAddress(env, data);

    if (body == 0) {
        JNU_ThrowNullPointerException(env, 0);
        return 0;
    }

    body += offset;

    if (name != NULL) {
        utfName = getUTF(env, name, buf, sizeof(buf));
        if (utfName == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            return result;
        }
        VerifyFixClassname(utfName);
    } else {
        utfName = NULL;
    }

    if (source != NULL) {
        utfSource = getUTF(env, source, sourceBuf, sizeof(sourceBuf));
        if (utfSource == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            goto free_utfName;
        }
    } else {
        utfSource = NULL;
    }

    // 核心调用
    result = JVM_DefineClassWithSource(env, utfName, loader, body, length, pd, utfSource);

    if (utfSource && utfSource != sourceBuf)
        free(utfSource);

 free_utfName:
    if (utfName && utfName != buf)
        free(utfName);

    return result;
}
```

继续定位JVM_DefineClassWithSource，该函数的定义同样无法查看，该函数的声明所在文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`

```C
/* Define a class with a source (added in JDK1.5) */
JNIEXPORT jclass JNICALL
JVM_DefineClassWithSource(JNIEnv *env, const char *name, jobject loader,
                          const jbyte *buf, jsize len, jobject pd,
                          const char *source);
```

# 2 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf@163.com)，博主将在第一时间删除__

* [Find a way out of the ClassLoader maze](https://www.javaworld.com/article/2077344/core-java/find-a-way-out-of-the-classloader-maze.html)
* [深入理解Java类加载器(2)：线程上下文类加载器](http://blog.csdn.net/zhoudaxia/article/details/35897057)
