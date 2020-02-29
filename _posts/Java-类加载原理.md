---
title: Java-类加载原理
date: 2018-01-06 14:56:15
tags: 
- 摘录
categories: 
- Java
- Isolation Technology
---

__阅读更多__

<!--more-->

# 1 类加载器的分类

通常，在我们需要动态加载一个类的时候，总有三个类加载器可以使用，它们分别是

1. system classloader：系统类加载器（或者称为应用类加载器，application classloader）
1. current classloader：当前类加载器（__CCL的加载过程是由JVM运行时来控制的，是无法通过Java编程来更改的__）
1. current thread context classloader：线程上下文类加载器

那么问题来了，我们应该选择哪个类加载器去加载呢，或者说JVM会使用哪个类加载器去加载呢？

首先排除掉的是system classloader（系统类加载器），这个类加载器用于加载`-classpath`路径下的类，并且可以通过静态方法`ClassLoader.getSystemClassLoader()`来获得。实际上，我们很少在代码中明确使用系统类加载器来加载类，因为我们总是可以通过其他类加载器并__通过委托__到达系统类加载器。如果你编写的程序运行在__最后一个ClassLoader__是AppClassLoader的情况下，那么你的代码就只能工作于命令行中，即通过`-classpath`参数来指定类加载路径，如果程序运行于Web容器中，那么这种方式就行不通了

current classloader是当前方法所属类的类加载器。通俗来讲，类A中使用了类B（类B在此前并未加载），那么会使用加载A的加载器来加载B。等效于通过`A.class.getClassLoader().loadClass("B");`来加载

在deSerialization中也需要知道类型的信息。在序列化后的内容中，已经包含了当前用户自定义类的类型信息，那么如何在ObjectInputStream调用中，能够拿到客户端的类型呢？通过调用Class.forName？肯定不可以，因为在ObjectInputStream中调用这个，会使用bootstrap来加载，那么它肯定加载不到所需要的类

答案是通过查询栈信息，通过sun.misc.VM.latestUserDefinedLoader(); 获取从栈上开始计算，第一个不为空（bootstrap classloader是空）的ClassLoader便返回

可以试想，在ObjectInputStream运作中，通过直接获取当前调用栈中，第一个非空的ClassLoader，这种做法能够非常便捷的定位用户的ClassLoader，也就是用户在进行：
```java
ObjectInputStream ois = new ObjectInputStream(new FileInputStream(“xx.dat”));
B b = (B) ois.readObject();
```
这种调用的时候，依旧能够通过“当前”的ClassLoader正确的加载用户的类

ContextClassLoader是作为Thread的一个成员变量出现的，一个线程在构造的时候，它会从parent线程中继承这个ClassLoader。__使用线程上下文类加载器，可以在执行线程中抛弃双亲委派加载链模式，使用线程上下文里的类加载器加载类__。CurrentClassLoader对用户来说是自动的，隐式的，而ContextClassLoader需要显示的使用，先进行设置然后再进行使用

# 2 Class#forName的类加载过程

__接下来我们会查看openjdk中的相关C++源码（源码下载请参考参考文献），openjdk的起始路径记为`${OPEN_JDK}`，我们将以如下形式来表示源码文件的位置__

* `${OPEN_JDK}/path1/path2/path3/source.c`

forName用于加载一个类并且会执行后续操作，包括验证，解析，初始化。并且触发static字段以及static域的执行。__下面仅分析类加载过程__

```java
    public static Class<?> forName(String className)
                throws ClassNotFoundException {
        Class<?> caller = Reflection.getCallerClass();
        return forName0(className, true, ClassLoader.getClassLoader(caller), caller);
    }
```

这里`Reflection.getCallerClass`是一个native方法，用于获取调用`Class#forName`方法的实例所属的Class对象。其次，forName0也是一个native方法

首先查看forName0对应的native方法，路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/Class.c`

```c
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

    //重点看这里，调用了JVM_FindClassFromCaller方法
    cls = JVM_FindClassFromCaller(env, clname, initialize, loader, caller);

 done:
    if (clname != buf) {
        free(clname);
    }
    return cls;
}
```

我们继续查找JVM_FindClassFromCaller的声明以及定义，文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`
* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.cpp`

__声明如下__
```c
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

__定义如下__
```c
JVM_ENTRY(jclass, JVM_FindClassFromCaller(JNIEnv* env, const char* name,
                                          jboolean init, jobject loader,
                                          jclass caller))
  JVMWrapper2("JVM_FindClassFromCaller %s throws ClassNotFoundException", name);
  //Java libraries should ensure that name is never null...
  if (name == NULL || (int)strlen(name) > Symbol::max_length()) {
    //It's impossible to create this class;  the name cannot fit
    //into the constant pool.
    THROW_MSG_0(vmSymbols::java_lang_ClassNotFoundException(), name);
  }

  TempNewSymbol h_name = SymbolTable::new_symbol(name, CHECK_NULL);

  oop loader_oop = JNIHandles::resolve(loader);
  oop from_class = JNIHandles::resolve(caller);
  oop protection_domain = NULL;
  //If loader is null, shouldn't call ClassLoader.checkPackageAccess; otherwise get
  //NPE. Put it in another way, the bootstrap class loader has all permission and
  //thus no checkPackageAccess equivalence in the VM class loader.
  //The caller is also passed as NULL by the java code if there is no security
  //manager to avoid the performance cost of getting the calling class.
  if (from_class != NULL && loader_oop != NULL) {
    protection_domain = java_lang_Class::as_Klass(from_class)->protection_domain();
  }

  Handle h_loader(THREAD, loader_oop);
  Handle h_prot(THREAD, protection_domain);
  //核心方法调用
  jclass result = find_class_from_class_loader(env, h_name, init, h_loader,
                                               h_prot, false, THREAD);

  if (TraceClassResolution && result != NULL) {
    trace_class_resolution(java_lang_Class::as_Klass(JNIHandles::resolve_non_null(result)));
  }
  return result;
JVM_END

jclass find_class_from_class_loader(JNIEnv* env, Symbol* name, jboolean init,
                                    Handle loader, Handle protection_domain,
                                    jboolean throwError, TRAPS) {
  //Security Note:
  //The Java level wrapper will perform the necessary security check allowing
  //us to pass the NULL as the initiating class loader.  The VM is responsible for
  //the checkPackageAccess relative to the initiating class loader via the
  //protection_domain. The protection_domain is passed as NULL by the java code
  //if there is no security manager in 3-arg Class.forName().
  Klass* klass = SystemDictionary::resolve_or_fail(name, loader, protection_domain, throwError != 0, CHECK_NULL);

  KlassHandle klass_handle(THREAD, klass);
  //Check if we should initialize the class
  if (init && klass_handle->oop_is_instance()) {
    klass_handle->initialize(CHECK_NULL);
  }
  return (jclass) JNIHandles::make_local(env, klass_handle->java_mirror());
}
```

从声明中可以看出，该方法以类全限定名和ClassLoader的引用来查找指定的Class。如果命中了，那么返回Class对象，并且执行后续验证、解析、初始化的操作，至此Class#forName结束

如果没有命中，通过debug可以发现，该native方法会继续调用Java中的ClassLoader.loadClass(String)方法，ClassLoader的实例就是Class#forName中的`ClassLoader.getClassLoader(caller)`获取的类加载器，一般来说就是`AppClassLoader`

```java
    public Class<?> loadClass(String name) throws ClassNotFoundException {
        return loadClass(name, false);
    }
```

通过debug发现继续调用`sun.misc.Launcher.AppClassLoader.loadClass`方法，如下：

```java
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
                //会走到这里，继续调用父类的loadClass方法
                return super.loadClass(var1, var2);
            }
        }
```

AppClassLoader的父类是ClassLoader，其loadClass方法如下：

```java
    protected Class<?> loadClass(String name, boolean resolve)
        throws ClassNotFoundException
    {
        synchronized (getClassLoadingLock(name)) {
            //First, check if the class has already been loaded
            Class<?> c = findLoadedClass(name);
            if (c == null) {
                long t0 = System.nanoTime();
                //双亲委派逻辑的体现之处
                try {
                    if (parent != null) {
                        c = parent.loadClass(name, false);
                    } else {
                        c = findBootstrapClassOrNull(name);
                    }
                } catch (ClassNotFoundException e) {
                    //ClassNotFoundException thrown if class not found
                    //from the non-null parent class loader
                }

                if (c == null) {
                    //If still not found, then invoke findClass in order
                    //to find the class.
                    long t1 = System.nanoTime();
                    c = findClass(name);

                    //this is the defining class loader; record the stats
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
        //native方法
        return findLoadedClass0(name);
    }
```

loadClass(String,bool)方法首先调用native方法findLoadedClass0在JVM中查找缓存，findLoadedClass0定义所在的文件路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/ClassLoader.c`

```c
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

继续定位JVM_FindLoadedClass，该函数的声明以及定义所在文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`
`${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.cpp`

__声明如下__

```c
/* Find a loaded class cached by the VM */
JNIEXPORT jclass JNICALL
JVM_FindLoadedClass(JNIEnv *env, jobject loader, jstring name);
```

__定义如下__

```c
JVM_ENTRY(jclass, JVM_FindLoadedClass(JNIEnv *env, jobject loader, jstring name))
  JVMWrapper("JVM_FindLoadedClass");
  ResourceMark rm(THREAD);

  Handle h_name (THREAD, JNIHandles::resolve_non_null(name));
  Handle string = java_lang_String::internalize_classname(h_name, CHECK_NULL);

  const char* str   = java_lang_String::as_utf8_string(string());
  //Sanity check, don't expect null
  if (str == NULL) return NULL;

  const int str_len = (int)strlen(str);
  if (str_len > Symbol::max_length()) {
    //It's impossible to create this class;  the name cannot fit
    //into the constant pool.
    return NULL;
  }
  TempNewSymbol klass_name = SymbolTable::new_symbol(str, str_len, CHECK_NULL);

  //Security Note:
  //The Java level wrapper will perform the necessary security check allowing
  //us to pass the NULL as the initiating class loader.
  Handle h_loader(THREAD, JNIHandles::resolve(loader));
  if (UsePerfData) {
    is_lock_held_by_thread(h_loader,
                           ClassLoader::sync_JVMFindLoadedClassLockFreeCounter(),
                           THREAD);
  }

  //核心调用
  Klass* k = SystemDictionary::find_instance_or_array_klass(klass_name,
                                                              h_loader,
                                                              Handle(),
                                                              CHECK_NULL);
#if INCLUDE_CDS
  if (k == NULL) {
    //If the class is not already loaded, try to see if it's in the shared
    //archive for the current classloader (h_loader).
    instanceKlassHandle ik = SystemDictionaryShared::find_or_load_shared_class(
        klass_name, h_loader, CHECK_NULL);
    k = ik();
  }
#endif
  return (k == NULL) ? NULL :
            (jclass) JNIHandles::make_local(env, k->java_mirror());
JVM_END
```

该方法会以__类加载器实例以及类全限定名作为key__，在缓存中查找Class实例

如果命中了直接返回。如果没有命中，则根据双亲委派模型依次调用双亲类加载器加载

如果仍然没有加载到，那么调用findClass方法，findClass在ClassLoader中定义，但是提供了空实现，不同的子类负责实现不同的逻辑，用以达到不同的类加载路径的效果

我们继续以AppClassLoader为例进行分析，AppClassLoader的findClass实现如下：

```java
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
                                //核心调用
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

```java
    private Class<?> defineClass(String name, Resource res) throws IOException {
        long t0 = System.nanoTime();
        int i = name.lastIndexOf('.');
        URL url = res.getCodeSourceURL();
        if (i != -1) {
            String pkgname = name.substring(0, i);
            //Check if package already loaded.
            Manifest man = res.getManifest();
            definePackageInternal(pkgname, man, url);
        }
        //Now read the class bytes and define the class
        java.nio.ByteBuffer bb = res.getByteBuffer();
        if (bb != null) {
            //Use (direct) ByteBuffer:
            CodeSigner[] signers = res.getCodeSigners();
            CodeSource cs = new CodeSource(url, signers);
            sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);

            //核心调用
            return defineClass(name, bb, cs);
        } else {
            byte[] b = res.getBytes();
            //must read certificates AFTER reading bytes.
            CodeSigner[] signers = res.getCodeSigners();
            CodeSource cs = new CodeSource(url, signers);
            sun.misc.PerfCounter.getReadClassBytesTime().addElapsedTimeFrom(t0);

            //核心调用
            return defineClass(name, b, 0, b.length, cs);
        }
    }
```

其中不同支路的defineClass都会定向为native方法defineClass0、defineClass1、defineClass2。它们负责将class文件代表的字节数组交给VM，然后由VM验证其格式的正确性。Class与ClassLoader实例关系的绑定就是在defineClass的调用过程中确定的

native方法defineClass0、defineClass1、defineClass2所在的文件路径如下：

* `${OPEN_JDK}/jdk/src/share/native/java/lang/ClassLoader.c`

```c
//The existence or signature of this method is not guaranteed since it
//supports a private method.  This method will be changed in 1.7.
JNIEXPORT jclass JNICALL
Java_java_lang_ClassLoader_defineClass0(JNIEnv *env,
                                        jobject loader,
                                        jstring name,
                                        jbyteArray data,
                                        jint offset,
                                        jint length,
                                        jobject pd)
{
    //转调用Java_java_lang_ClassLoader_defineClass1
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

    //核心调用
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

    assert(data != NULL); //caller fails if data is null.
    assert(length >= 0);  //caller passes ByteBuffer.remaining() for length, so never neg.
    //caller passes ByteBuffer.position() for offset, and capacity() >= position() + remaining()
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

    //核心调用
    result = JVM_DefineClassWithSource(env, utfName, loader, body, length, pd, utfSource);

    if (utfSource && utfSource != sourceBuf)
        free(utfSource);

 free_utfName:
    if (utfName && utfName != buf)
        free(utfName);

    return result;
}
```

继续定位JVM_DefineClassWithSource，该函数的声明以及定义所在文件路径如下：

* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.h`
* `${OPEN_JDK}/hotspot/src/share/vm/prims/jvm.cpp`

__声明如下__

```c
/* Define a class with a source (added in JDK1.5) */
JNIEXPORT jclass JNICALL
JVM_DefineClassWithSource(JNIEnv *env, const char *name, jobject loader,
                          const jbyte *buf, jsize len, jobject pd,
                          const char *source);
```

__定义如下__

```c
JVM_ENTRY(jclass, JVM_DefineClassWithSource(JNIEnv *env, const char *name, jobject loader, const jbyte *buf, jsize len, jobject pd, const char *source))
  JVMWrapper2("JVM_DefineClassWithSource %s", name);

  return jvm_define_class_common(env, name, loader, buf, len, pd, source, true, THREAD);
JVM_END

//common code for JVM_DefineClass() and JVM_DefineClassWithSource()
//and JVM_DefineClassWithSourceCond()
static jclass jvm_define_class_common(JNIEnv *env, const char *name,
                                      jobject loader, const jbyte *buf,
                                      jsize len, jobject pd, const char *source,
                                      jboolean verify, TRAPS) {
  if (source == NULL)  source = "__JVM_DefineClass__";

  assert(THREAD->is_Java_thread(), "must be a JavaThread");
  JavaThread* jt = (JavaThread*) THREAD;

  PerfClassTraceTime vmtimer(ClassLoader::perf_define_appclass_time(),
                             ClassLoader::perf_define_appclass_selftime(),
                             ClassLoader::perf_define_appclasses(),
                             jt->get_thread_stat()->perf_recursion_counts_addr(),
                             jt->get_thread_stat()->perf_timers_addr(),
                             PerfClassTraceTime::DEFINE_CLASS);

  if (UsePerfData) {
    ClassLoader::perf_app_classfile_bytes_read()->inc(len);
  }

  //Since exceptions can be thrown, class initialization can take place
  //if name is NULL no check for class name in .class stream has to be made.
  TempNewSymbol class_name = NULL;
  if (name != NULL) {
    const int str_len = (int)strlen(name);
    if (str_len > Symbol::max_length()) {
      //It's impossible to create this class;  the name cannot fit
      //into the constant pool.
      THROW_MSG_0(vmSymbols::java_lang_NoClassDefFoundError(), name);
    }
    class_name = SymbolTable::new_symbol(name, str_len, CHECK_NULL);
  }

  ResourceMark rm(THREAD);
  ClassFileStream st((u1*) buf, len, (char *)source);
  Handle class_loader (THREAD, JNIHandles::resolve(loader));
  if (UsePerfData) {
    is_lock_held_by_thread(class_loader,
                           ClassLoader::sync_JVMDefineClassLockFreeCounter(),
                           THREAD);
  }
  Handle protection_domain (THREAD, JNIHandles::resolve(pd));
  Klass* k = SystemDictionary::resolve_from_stream(class_name, class_loader,
                                                     protection_domain, &st,
                                                     verify != 0,
                                                     CHECK_NULL);

  if (TraceClassResolution && k != NULL) {
    trace_class_resolution(k);
  }

  return (jclass) JNIHandles::make_local(env, k->java_mirror());
}
```

该方法根据传入的字节数组来创建一个Class对象，并验证其正确性。__如果创建成功，那么建立一条`<类加载器实例，类全限定名，Class对象实例>`的缓存，也就是说Class对象的命名空间是由传给defineClass0、defineClass1、defineClass2的ClassLoader的实例提供的，因此并不一定是执行loadClass的类加载器实例__

# 3 Class#forName流程分析

我们知道Class#forName与ClassLoader.loadClass()的差异在于Class#forName会在加载类后执行后续的验证解析初始化动作，而ClassLoader.loadClass()仅仅加载类。因此，这里__仅针对__Class#forName于ClassLoader.loadClass()的类加载过程进行分析

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
participant "Java Code" as JC
participant JVM
JC-->JC:Class@forName(...)
JC-->JVM:Reflection@getCallerClass()\n用以获取调用类的Class对象
JVM-->JC:return
JC-->JVM:ClassLoader@forName0(...)
JVM-->JVM:JVM_FindClassFromCaller在缓存中查找Class对象\n以类加载器实例以及全限定名作为key
JVM-->JC:若命中了，则结束加载过程\n若没有命中，调用传入JVM的类加载器实例的loadClass方法
JC-->JC:...省略双亲委派的流程跳转...
JC-->JC:ClassLoader.loadClass(...)
JC-->JC:ClassLoader.findLoadedClass(...)
JC-->JVM:ClassLoader.findLoadedClass0(...)
JVM-->JVM:JVM_FindLoadedClass在缓存中查找Class对象\n以类加载器实例以及全限定名作为key
JVM-->JC:若命中了，则结束加载过程\n若没有命中，继续回到loadClass方法中
JC-->JC:ClassLoader.findClass(...)
JC-->JC:ClassLoader.defineClass(...)
JC-->JVM:ClassLoader.defineClass0(...)
JVM-->JVM:JVM_DefineClassWithSource验证字节码格式的正确性\n记录缓存{"key":"ClassLoader实例+name","value":"Class实例"}
JVM-->JC:return
JC-->JC:后续可能会有验证解析初始化操作
```

# 4 参考

* [Find a way out of the ClassLoader maze](https://www.javaworld.com/article/2077344/core-java/find-a-way-out-of-the-classloader-maze.html)
* [深入理解Java类加载器(2)：线程上下文类加载器](http://blog.csdn.net/zhoudaxia/article/details/35897057)
* [openjdk source](http://openjdk.java.net/)
