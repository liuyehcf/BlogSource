---
title: JDK 动态代理 源码剖析
date: 2017-07-27 16:24:07
tags: 原创
categories:
- Java
- 动态代理
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

相比于静态代理，动态代理避免了开发人员编写各个繁锁的静态代理类，只需简单地指定一组接口及目标类对象就能动态的获得代理对象。

# 2 字段

```Java
    /** parameter types of a proxy class constructor */
    private static final Class<?>[] constructorParams =
        { InvocationHandler.class };

    /**
     * a cache of proxy classes
     */
    private static final WeakCache<ClassLoader, Class<?>[], Class<?>>
        proxyClassCache = new WeakCache<>(new KeyFactory(), new ProxyClassFactory());
```

* __constructorParams__：代理类的构造方法的参数的类型列表，说明所有代理类的构造方法只接受InvocationHandler的对象作为参数
* __proxyClassCache__：代理类Class对象的缓存，如果代理类已经被生成了，那么会从缓存中取出

# 3 方法

## 3.1 newProxyInstance

参数说明

* loader：类加载器
* interfaces：代理类需要实现的接口列表
* h：InvocationHandler的对象

```Java
    /**
     * Returns an instance of a proxy class for the specified interfaces
     * that dispatches method invocations to the specified invocation
     * handler.
     *
     * <p>{@code Proxy.newProxyInstance} throws
     * {@code IllegalArgumentException} for the same reasons that
     * {@code Proxy.getProxyClass} does.
     *
     * @param   loader the class loader to define the proxy class
     * @param   interfaces the list of interfaces for the proxy class
     *          to implement
     * @param   h the invocation handler to dispatch method invocations to
     * @return  a proxy instance with the specified invocation handler of a
     *          proxy class that is defined by the specified class loader
     *          and that implements the specified interfaces
     * @throws  IllegalArgumentException if any of the restrictions on the
     *          parameters that may be passed to {@code getProxyClass}
     *          are violated
     * @throws  SecurityException if a security manager, <em>s</em>, is present
     *          and any of the following conditions is met:
     *          <ul>
     *          <li> the given {@code loader} is {@code null} and
     *               the caller's class loader is not {@code null} and the
     *               invocation of {@link SecurityManager#checkPermission
     *               s.checkPermission} with
     *               {@code RuntimePermission("getClassLoader")} permission
     *               denies access;</li>
     *          <li> for each proxy interface, {@code intf},
     *               the caller's class loader is not the same as or an
     *               ancestor of the class loader for {@code intf} and
     *               invocation of {@link SecurityManager#checkPackageAccess
     *               s.checkPackageAccess()} denies access to {@code intf};</li>
     *          <li> any of the given proxy interfaces is non-public and the
     *               caller class is not in the same {@linkplain Package runtime package}
     *               as the non-public interface and the invocation of
     *               {@link SecurityManager#checkPermission s.checkPermission} with
     *               {@code ReflectPermission("newProxyInPackage.{package name}")}
     *               permission denies access.</li>
     *          </ul>
     * @throws  NullPointerException if the {@code interfaces} array
     *          argument or any of its elements are {@code null}, or
     *          if the invocation handler, {@code h}, is
     *          {@code null}
     */
    @CallerSensitive
    public static Object newProxyInstance(ClassLoader loader,
                                          Class<?>[] interfaces,
                                          InvocationHandler h)
        throws IllegalArgumentException
    {
        // 如果h为空则抛出异常
        Objects.requireNonNull(h);

        // 拷贝一下接口数组，这里拷贝一下干嘛？
        final Class<?>[] intfs = interfaces.clone();
        // 进行一些安全检查，这里不再展开了，与代理实现不太相关
        final SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
        }

        /*
         * Look up or generate the designated proxy class.
         */
        // 关键方法，产生代理类的Class对象
        Class<?> cl = getProxyClass0(loader, intfs);

        /*
         * Invoke its constructor with the designated invocation handler.
         */
        try {
            if (sm != null) {
                checkNewProxyPermission(Reflection.getCallerClass(), cl);
            }

            // 获取代理类的指定构造方法
            // 其中private static final Class<?>[] constructorParams ={ InvocationHandler.class };
            // 说明代理类的构造方法接受InvocationHandler作为其
            final Constructor<?> cons = cl.getConstructor(constructorParams);
            final InvocationHandler ih = h;
            if (!Modifier.isPublic(cl.getModifiers())) {
                AccessController.doPrivileged(new PrivilegedAction<Void>() {
                    public Void run() {
                        cons.setAccessible(true);
                        return null;
                    }
                });
            }
            // 创建代理类对象
            return cons.newInstance(new Object[]{h});
        } catch (IllegalAccessException|InstantiationException e) {
            throw new InternalError(e.toString(), e);
        } catch (InvocationTargetException e) {
            Throwable t = e.getCause();
            if (t instanceof RuntimeException) {
                throw (RuntimeException) t;
            } else {
                throw new InternalError(t.toString(), t);
            }
        } catch (NoSuchMethodException e) {
            throw new InternalError(e.toString(), e);
        }
    }
```

## 3.2 getProxyClass0

getProxyClass0方法将根据`类加载器对象`和`接口数组`从缓存中获取指定的Class，如果在缓存中不存在，那么将由ProxyClassFactory创建代理类对象，具体参见proxyClassCache的定义

```Java
    /**
     * Generate a proxy class.  Must call the checkProxyAccess method
     * to perform permission checks before calling this.
     */
    private static Class<?> getProxyClass0(ClassLoader loader,
                                           Class<?>... interfaces) {
        // 接口数量不得超过限制，这个限制出自JVM规范
        if (interfaces.length > 65535) {
            throw new IllegalArgumentException("interface limit exceeded");
        }

        // If the proxy class defined by the given loader implementing
        // the given interfaces exists, this will simply return the cached copy;
        // otherwise, it will create the proxy class via the ProxyClassFactory

        // 核心方法
        return proxyClassCache.get(loader, interfaces);
    }
```

## 3.3 ProxyClassFactory

ProxyClassFactory是位于Proxy中的静态内部类，用于产生代理类的`.class文件`以及Class对象。

apply方法中主要进行一些校验工作以及确定代理类的全限定名，然后调用`ProxyGenerator.generateProxyClass`来产生字节码文件。

```Java
    /**
     * A factory function that generates, defines and returns the proxy class given
     * the ClassLoader and array of interfaces.
     */
    private static final class ProxyClassFactory
        implements BiFunction<ClassLoader, Class<?>[], Class<?>>
    {
        // prefix for all proxy class names
        // 代理类统一前缀
        private static final String proxyClassNamePrefix = "$Proxy";

        // next number to use for generation of unique proxy class names
        // 代理类计数值，将作为代理类类名的一部分
        private static final AtomicLong nextUniqueNumber = new AtomicLong();

        @Override
        public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {

            Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
            for (Class<?> intf : interfaces) {
                /*
                 * Verify that the class loader resolves the name of this
                 * interface to the same Class object.
                 */
                // 由于Class对象由全限定名和类加载器共同决定，因此这里判断一下intf的类加载器是否是给定的loader
                Class<?> interfaceClass = null;
                try {
                    interfaceClass = Class.forName(intf.getName(), false, loader);
                } catch (ClassNotFoundException e) {
                }
                if (interfaceClass != intf) {
                    throw new IllegalArgumentException(
                        intf + " is not visible from class loader");
                }
                /*
                 * Verify that the Class object actually represents an
                 * interface.
                 */
                // 由于JDK 动态代理只能实现接口代理，因此这里校验一下是intf是否为接口
                if (!interfaceClass.isInterface()) {
                    throw new IllegalArgumentException(
                        interfaceClass.getName() + " is not an interface");
                }
                /*
                 * Verify that this interface is not a duplicate.
                 */
                // 校验一下给定的接口列表是否存在重复
                if (interfaceSet.put(interfaceClass, Boolean.TRUE) != null) {
                    throw new IllegalArgumentException(
                        "repeated interface: " + interfaceClass.getName());
                }
            }

            // 代理类所在的包
            String proxyPkg = null;     // package to define proxy class in
            // 代理类的访问权限
            int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

            /*
             * Record the package of a non-public proxy interface so that the
             * proxy class will be defined in the same package.  Verify that
             * all non-public proxy interfaces are in the same package.
             */
            // 验证你传入的接口中是否有非public的接口，只要有一个是非public的，那么这些非public的接口都必须在同一个包中
            for (Class<?> intf : interfaces) {
                int flags = intf.getModifiers();
                if (!Modifier.isPublic(flags)) {
                    accessFlags = Modifier.FINAL;
                    String name = intf.getName();
                    int n = name.lastIndexOf('.');

                    // 获取完整包名
                    String pkg = ((n == -1) ? "" : name.substring(0, n + 1));
                    if (proxyPkg == null) {
                        proxyPkg = pkg;
                    } else if (!pkg.equals(proxyPkg)) {
                        throw new IllegalArgumentException(
                            "non-public interfaces from different packages");
                    }
                }
            }

            if (proxyPkg == null) {
                // if no non-public proxy interfaces, use com.sun.proxy package
                // 如果接口都是public的，那么代理类的包名就是com.sun.proxy
                proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
            }

            /*
             * Choose a name for the proxy class to generate.
             */
            // 当前类名中包含的计数值
            long num = nextUniqueNumber.getAndIncrement();

            // 代理类的完全限定名
            String proxyName = proxyPkg + proxyClassNamePrefix + num;

            /*
             * Generate the specified proxy class.
             */
            // 生成代理类字节码文件，关建中的关键
            byte[] proxyClassFile = ProxyGenerator.generateProxyClass(
                proxyName, interfaces, accessFlags);
            try {
                return defineClass0(loader, proxyName,
                                    proxyClassFile, 0, proxyClassFile.length);
            } catch (ClassFormatError e) {
                /*
                 * A ClassFormatError here means that (barring bugs in the
                 * proxy class generation code) there was some other
                 * invalid aspect of the arguments supplied to the proxy
                 * class creation (such as virtual machine limitations
                 * exceeded).
                 */
                throw new IllegalArgumentException(e.toString());
            }
        }
    }
```

## 3.4 ProxyGenerator.generateProxyClass

```Java
    public static byte[] generateProxyClass(final String var0, Class<?>[] var1, int var2) {
        ProxyGenerator var3 = new ProxyGenerator(var0, var1, var2);
        // 生成字节码文件的真正方法
        final byte[] var4 = var3.generateClassFile();

        // 保存文件，不做过多讨论
        if(saveGeneratedFiles) {
            AccessController.doPrivileged(new PrivilegedAction() {
                public Void run() {
                    try {
                        int var1 = var0.lastIndexOf(46);
                        Path var2;
                        if(var1 > 0) {
                            Path var3 = Paths.get(var0.substring(0, var1).replace('.', File.separatorChar), new String[0]);
                            Files.createDirectories(var3, new FileAttribute[0]);
                            var2 = var3.resolve(var0.substring(var1 + 1, var0.length()) + ".class");
                        } else {
                            var2 = Paths.get(var0 + ".class", new String[0]);
                        }

                        Files.write(var2, var4, new OpenOption[0]);
                        return null;
                    } catch (IOException var4x) {
                        throw new InternalError("I/O exception saving generated file: " + var4x);
                    }
                }
            });
        }

        return var4;
    }
```

## 3.5 ProxyGenerator.generateClassFile

层层调用后，最终generateClassFile才是真正生成代理类字节码文件的方法，注意开头的三个addProxyMethod方法是只将Object的hashcode,equals,toString方法添加到代理方法容器中，代理类除此之外并没有重写其他Object的方法，所以除这三个方法外，代理类调用其他方法的行为与Object调用这些方法的行为一样不通过Invoke

```Java
    private byte[] generateClassFile() {
        // 这三个方法将Object的hashcode，equals，toString方法添加到代理方法容器中，代理类除此之外并没有重写Object的其他方法
        // 除了这三个方法之外，代理类调用Object的其他方法不通过invoke
        this.addProxyMethod(hashCodeMethod, Object.class);
        this.addProxyMethod(equalsMethod, Object.class);
        this.addProxyMethod(toStringMethod, Object.class);
        Class[] var1 = this.interfaces;
        int var2 = var1.length;

        int var3;
        Class var4;// 接口的Class对象
        // 获得所有接口中的方法，并将方法添加到代理方法中
        for(var3 = 0; var3 < var2; ++var3) {
            var4 = var1[var3];
            // 获取所有的方法
            Method[] var5 = var4.getMethods();
            int var6 = var5.length;

            for(int var7 = 0; var7 < var6; ++var7) {
                Method var8 = var5[var7];
                // 添加到方法容器中，显然如果接口存在相同的方法，应该会被过滤掉
                this.addProxyMethod(var8, var4);
            }
        }

        // proxyMethods是一个map，其定义为：private Map<String, List<ProxyGenerator.ProxyMethod>> proxyMethods = new HashMap();
        Iterator var11 = this.proxyMethods.values().iterator();

        List var12;
        while(var11.hasNext()) {
            var12 = (List)var11.next();
            checkReturnTypes(var12);
        }

        // 接下来就是写代理类文件的步骤了
        Iterator var15;
        try {
            // 生成代理类的构造函数
            this.methods.add(this.generateConstructor());
            var11 = this.proxyMethods.values().iterator();

            while(var11.hasNext()) {
                var12 = (List)var11.next();
                var15 = var12.iterator();

                while(var15.hasNext()) {
                    ProxyGenerator.ProxyMethod var16 = (ProxyGenerator.ProxyMethod)var15.next();
                    this.fields.add(new ProxyGenerator.FieldInfo(var16.methodFieldName, "Ljava/lang/reflect/Method;", 10));
                    // 生成代理类的代理方法，重要方法
                    this.methods.add(var16.generateMethod());
                }
            }

            // 为代理类生成静态代码块
            this.methods.add(this.generateStaticInitializer());
        } catch (IOException var10) {
            throw new InternalError("unexpected I/O Exception", var10);
        }

        // 方法数目不得超过65535
        if(this.methods.size() > '\uffff') {
            throw new IllegalArgumentException("method limit exceeded");
        } 
        // 字段数目不得超过65535
        else if(this.fields.size() > '\uffff') {
            throw new IllegalArgumentException("field limit exceeded");
        } else {
            // 下面开始按照Class文件的格式进行字节码文件的生成
            this.cp.getClass(dotToSlash(this.className));
            this.cp.getClass("java/lang/reflect/Proxy");
            var1 = this.interfaces;
            var2 = var1.length;

            for(var3 = 0; var3 < var2; ++var3) {
                var4 = var1[var3];
                this.cp.getClass(dotToSlash(var4.getName()));
            }

            this.cp.setReadOnly();
            ByteArrayOutputStream var13 = new ByteArrayOutputStream();
            DataOutputStream var14 = new DataOutputStream(var13);

            try {
                var14.writeInt(-889275714);// 魔数
                var14.writeShort(0);// 次版本号
                var14.writeShort(49);// 主版本号
                this.cp.write(var14);
                var14.writeShort(this.accessFlags);// 访问标志
                var14.writeShort(this.cp.getClass(dotToSlash(this.className)));// 类索引
                var14.writeShort(this.cp.getClass("java/lang/reflect/Proxy"));// 父类索引
                var14.writeShort(this.interfaces.length);// 接口计数值
                Class[] var17 = this.interfaces;
                int var18 = var17.length;

                for(int var19 = 0; var19 < var18; ++var19) {
                    Class var22 = var17[var19];
                    var14.writeShort(this.cp.getClass(dotToSlash(var22.getName())));
                }

                var14.writeShort(this.fields.size());// 字段计数值
                var15 = this.fields.iterator();

                while(var15.hasNext()) {
                    ProxyGenerator.FieldInfo var20 = (ProxyGenerator.FieldInfo)var15.next();
                    var20.write(var14);
                }

                var14.writeShort(this.methods.size());// 方法计数值
                var15 = this.methods.iterator();

                while(var15.hasNext()) {
                    ProxyGenerator.MethodInfo var21 = (ProxyGenerator.MethodInfo)var15.next();
                    var21.write(var14);
                }

                var14.writeShort(0);
                return var13.toByteArray();
            } catch (IOException var9) {
                throw new InternalError("unexpected I/O Exception", var9);
            }
        }
    }
```

## 3.6 ProxyGenerator.addProxyMethod

将指定方法添加到方法容器中。该容器中的所有方法将会被写入到代理对象中

```Java
    private void addProxyMethod(Method var1, Class<?> var2) {
        // 方法名
        String var3 = var1.getName();
        // 方法参数类型数组
        Class[] var4 = var1.getParameterTypes();
        // 方法返回类型
        Class var5 = var1.getReturnType();
        // 方法异常列表
        Class[] var6 = var1.getExceptionTypes();
        // 获取方法签名
        String var7 = var3 + getParameterDescriptors(var4);
        // 根据方法签名获取proxyMethods的value
        Object var8 = (List)this.proxyMethods.get(var7);
        // 如果方法出现了重复，保证子类只有一个方法
        if(var8 != null) {
            Iterator var9 = ((List)var8).iterator();

            while(var9.hasNext()) {
                ProxyGenerator.ProxyMethod var10 = (ProxyGenerator.ProxyMethod)var9.next();
                if(var5 == var10.returnType) {
                    // 规约异常类型，让重写的方法抛出合适的异常类型。也就是说不同的接口中包含了方法签名相同的方法，但是这些方法的异常参数列表不同，因此这里需要整合出一个恰当的异常列表
                    ArrayList var11 = new ArrayList();
                    collectCompatibleTypes(var6, var10.exceptionTypes, var11);
                    collectCompatibleTypes(var10.exceptionTypes, var6, var11);
                    var10.exceptionTypes = new Class[var11.size()];
                    var10.exceptionTypes = (Class[])var11.toArray(var10.exceptionTypes);
                    return;
                }
            }
        } else {
            var8 = new ArrayList(3);
            this.proxyMethods.put(var7, var8);
        }

        ((List)var8).add(new ProxyGenerator.ProxyMethod(var3, var4, var5, var6, var2, null));
    }
```

## 3.7 ProxyMethod.generateMethod

这个方法非常重要，该方法勾勒出代理对象的代理逻辑。该方法的阅读需要对字节码的格式以及方法属性表的格式非常了解，否则将会一头雾水

```Java
        private ProxyGenerator.MethodInfo generateMethod() throws IOException {
            String var1 = ProxyGenerator.getMethodDescriptor(this.parameterTypes, this.returnType);
            ProxyGenerator.MethodInfo var2 = ProxyGenerator.this.new MethodInfo(this.methodName, var1, 17);
            int[] var3 = new int[this.parameterTypes.length];
            int var4 = 1;

            for(int var5 = 0; var5 < var3.length; ++var5) {
                var3[var5] = var4;
                var4 += ProxyGenerator.getWordsPerType(this.parameterTypes[var5]);
            }

            byte var7 = 0;
            DataOutputStream var9 = new DataOutputStream(var2.code);
            ProxyGenerator.this.code_aload(0, var9);
            var9.writeByte(180);
            // 这里获取InvocationHandler的对象
            var9.writeShort(ProxyGenerator.this.cp.getFieldRef("java/lang/reflect/Proxy", "h", "Ljava/lang/reflect/InvocationHandler;"));
            ProxyGenerator.this.code_aload(0, var9);
            var9.writeByte(178);
            var9.writeShort(ProxyGenerator.this.cp.getFieldRef(ProxyGenerator.dotToSlash(ProxyGenerator.this.className), this.methodFieldName, "Ljava/lang/reflect/Method;"));
            if(this.parameterTypes.length > 0) {
                ProxyGenerator.this.code_ipush(this.parameterTypes.length, var9);
                var9.writeByte(189);
                var9.writeShort(ProxyGenerator.this.cp.getClass("java/lang/Object"));

                for(int var10 = 0; var10 < this.parameterTypes.length; ++var10) {
                    var9.writeByte(89);
                    ProxyGenerator.this.code_ipush(var10, var9);
                    this.codeWrapArgument(this.parameterTypes[var10], var3[var10], var9);
                    var9.writeByte(83);
                }
            } else {
                var9.writeByte(1);
            }

            var9.writeByte(185);
            var9.writeShort(ProxyGenerator.this.cp.getInterfaceMethodRef("java/lang/reflect/InvocationHandler", "invoke", "(Ljava/lang/Object;Ljava/lang/reflect/Method;[Ljava/lang/Object;)Ljava/lang/Object;"));
            var9.writeByte(4);
            var9.writeByte(0);
            if(this.returnType == Void.TYPE) {
                var9.writeByte(87);
                var9.writeByte(177);
            } else {
                this.codeUnwrapReturnValue(this.returnType, var9);
            }

            short var6;
            short var8 = var6 = (short)var2.code.size();
            List var13 = ProxyGenerator.computeUniqueCatchList(this.exceptionTypes);
            if(var13.size() > 0) {
                Iterator var11 = var13.iterator();

                while(var11.hasNext()) {
                    Class var12 = (Class)var11.next();
                    var2.exceptionTable.add(new ProxyGenerator.ExceptionTableEntry(var7, var8, var6, ProxyGenerator.this.cp.getClass(ProxyGenerator.dotToSlash(var12.getName()))));
                }

                var9.writeByte(191);
                var6 = (short)var2.code.size();
                var2.exceptionTable.add(new ProxyGenerator.ExceptionTableEntry(var7, var8, var6, ProxyGenerator.this.cp.getClass("java/lang/Throwable")));
                ProxyGenerator.this.code_astore(var4, var9);
                var9.writeByte(187);
                var9.writeShort(ProxyGenerator.this.cp.getClass("java/lang/reflect/UndeclaredThrowableException"));
                var9.writeByte(89);
                ProxyGenerator.this.code_aload(var4, var9);
                var9.writeByte(183);
                var9.writeShort(ProxyGenerator.this.cp.getMethodRef("java/lang/reflect/UndeclaredThrowableException", "<init>", "(Ljava/lang/Throwable;)V"));
                var9.writeByte(191);
            }

            if(var2.code.size() > '\uffff') {
                throw new IllegalArgumentException("code size limit exceeded");
            } else {
                var2.maxStack = 10;
                var2.maxLocals = (short)(var4 + 1);
                var2.declaredExceptions = new short[this.exceptionTypes.length];

                for(int var14 = 0; var14 < this.exceptionTypes.length; ++var14) {
                    var2.declaredExceptions[var14] = ProxyGenerator.this.cp.getClass(ProxyGenerator.dotToSlash(this.exceptionTypes[var14].getName()));
                }

                return var2;
            }
        }
```

下面这段java代码就是ProxyMethod.generateMethod所写入的方法的样子。可以看出，所有的方法调用都必须通过InvocationHandler对象，因此我们可以将增强逻辑写在InvocationHandler#invoke方法中

```Java
    public final void <methodName> ( <Params> ) throws <Exceptions> {
        try {
            super.h.invoke(this, <Method>, <Params>);
        } catch (RuntimeException | Error e1) {
            throw e1;
        } catch (Throwable e2) {
            throw new UndeclaredThrowableException(e2);
        }
    }
```

# 4 参考

* [深度剖析JDK动态代理机制](http://www.cnblogs.com/MOBIN/p/5597215.html)
