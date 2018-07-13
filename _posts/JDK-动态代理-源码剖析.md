---
title: JDK-动态代理-源码剖析
date: 2017-07-27 16:24:07
tags: 
- 原创
categories: 
- Java
- Dynamic proxy
---

__阅读更多__

<!--more-->

# 1 前言

相比于静态代理，动态代理避免了开发人员编写各个繁锁的静态代理类，只需简单地指定一组接口及目标类对象就能动态的获得代理对象

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
        //如果h为空则抛出异常
        Objects.requireNonNull(h);

        //拷贝一下接口数组，这里拷贝一下干嘛？
        final Class<?>[] intfs = interfaces.clone();
        //进行一些安全检查，这里不再展开了，与代理实现不太相关
        final SecurityManager sm = System.getSecurityManager();
        if (sm != null) {
            checkProxyAccess(Reflection.getCallerClass(), loader, intfs);
        }

        /*
         * Look up or generate the designated proxy class.
         */
        //关键方法，产生代理类的Class对象
        Class<?> cl = getProxyClass0(loader, intfs);

        /*
         * Invoke its constructor with the designated invocation handler.
         */
        try {
            if (sm != null) {
                checkNewProxyPermission(Reflection.getCallerClass(), cl);
            }

            //获取代理类的指定构造方法
            //其中private static final Class<?>[] constructorParams ={ InvocationHandler.class };
            //说明代理类的构造方法接受InvocationHandler作为其
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
            //创建代理类对象
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
        //接口数量不得超过限制，这个限制出自JVM规范
        if (interfaces.length > 65535) {
            throw new IllegalArgumentException("interface limit exceeded");
        }

        //If the proxy class defined by the given loader implementing
        //the given interfaces exists, this will simply return the cached copy;
        //otherwise, it will create the proxy class via the ProxyClassFactory

        //核心方法
        return proxyClassCache.get(loader, interfaces);
    }
```

## 3.3 ProxyClassFactory

ProxyClassFactory是位于Proxy中的静态内部类，用于产生代理类的`.class文件`以及Class对象

apply方法中主要进行一些校验工作以及确定代理类的全限定名，然后调用`ProxyGenerator.generateProxyClass`来产生字节码文件

```Java
    /**
     * A factory function that generates, defines and returns the proxy class given
     * the ClassLoader and array of interfaces.
     */
    private static final class ProxyClassFactory
        implements BiFunction<ClassLoader, Class<?>[], Class<?>>
    {
        //prefix for all proxy class names
        //代理类统一前缀
        private static final String proxyClassNamePrefix = "$Proxy";

        //next number to use for generation of unique proxy class names
        //代理类计数值，将作为代理类类名的一部分
        private static final AtomicLong nextUniqueNumber = new AtomicLong();

        @Override
        public Class<?> apply(ClassLoader loader, Class<?>[] interfaces) {

            Map<Class<?>, Boolean> interfaceSet = new IdentityHashMap<>(interfaces.length);
            for (Class<?> intf : interfaces) {
                /*
                 * Verify that the class loader resolves the name of this
                 * interface to the same Class object.
                 */
                //由于Class对象由全限定名和类加载器共同决定，因此这里判断一下intf的类加载器是否是给定的loader
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
                //由于JDK 动态代理只能实现接口代理，因此这里校验一下是intf是否为接口
                if (!interfaceClass.isInterface()) {
                    throw new IllegalArgumentException(
                        interfaceClass.getName() + " is not an interface");
                }
                /*
                 * Verify that this interface is not a duplicate.
                 */
                //校验一下给定的接口列表是否存在重复
                if (interfaceSet.put(interfaceClass, Boolean.TRUE) != null) {
                    throw new IllegalArgumentException(
                        "repeated interface: " + interfaceClass.getName());
                }
            }

            //代理类所在的包
            String proxyPkg = null;     //package to define proxy class in
            //代理类的访问权限
            int accessFlags = Modifier.PUBLIC | Modifier.FINAL;

            /*
             * Record the package of a non-public proxy interface so that the
             * proxy class will be defined in the same package.  Verify that
             * all non-public proxy interfaces are in the same package.
             */
            //验证你传入的接口中是否有非public的接口，只要有一个是非public的，那么这些非public的接口都必须在同一个包中
            for (Class<?> intf : interfaces) {
                int flags = intf.getModifiers();
                if (!Modifier.isPublic(flags)) {
                    accessFlags = Modifier.FINAL;
                    String name = intf.getName();
                    int n = name.lastIndexOf('.');

                    //获取完整包名
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
                //if no non-public proxy interfaces, use com.sun.proxy package
                //如果接口都是public的，那么代理类的包名就是com.sun.proxy
                proxyPkg = ReflectUtil.PROXY_PACKAGE + ".";
            }

            /*
             * Choose a name for the proxy class to generate.
             */
            //当前类名中包含的计数值
            long num = nextUniqueNumber.getAndIncrement();

            //代理类的完全限定名
            String proxyName = proxyPkg + proxyClassNamePrefix + num;

            /*
             * Generate the specified proxy class.
             */
            //生成代理类字节码文件，关建中的关键
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
    /**
     * Generate a proxy class given a name and a list of proxy interfaces.
     */
    public static byte[] generateProxyClass(final String name,
                                            Class[] interfaces) {
        ProxyGenerator gen = new ProxyGenerator(name, interfaces);
        
        //生成字节码文件的真正方法
        final byte[] classFile = gen.generateClassFile();

        //根据saveGeneratedFiles来确定是否保存.class文件，默认是不保存的
        if (saveGeneratedFiles) {
            java.security.AccessController.doPrivileged(
                    new java.security.PrivilegedAction() {
                        public Object run() {
                            try {
                                FileOutputStream file =
                                        new FileOutputStream(dotToSlash(name) + ".class");
                                file.write(classFile);
                                file.close();
                                return null;
                            } catch (IOException e) {
                                throw new InternalError(
                                        "I/O exception saving generated file: " + e);
                            }
                        }
                    });
        }

        return classFile;
    }

```

## 3.5 ProxyGenerator.generateClassFile

层层调用后，最终generateClassFile才是真正生成代理类字节码文件的方法，注意开头的三个addProxyMethod方法是只将Object的hashcode,equals,toString方法添加到代理方法容器中，代理类除此之外并没有重写其他Object的方法，所以除这三个方法外，代理类调用其他方法的行为与Object调用这些方法的行为一样不通过Invoke

```Java
    /**
     * Generate a class file for the proxy class.  This method drives the
     * class file generation process.
     */
    private byte[] generateClassFile() {

	/* ============================================================
     * Step 1: Assemble ProxyMethod objects for all methods to
	 * generate proxy dispatching code for.
	 */

	/*
     * Record that proxy methods are needed for the hashCode, equals,
	 * and toString methods of java.lang.Object.  This is done before
	 * the methods from the proxy interfaces so that the methods from
	 * java.lang.Object take precedence over duplicate methods in the
	 * proxy interfaces.
	 */
        //这三个方法将Object的hashcode，equals，toString方法添加到代理方法容器中，代理类除此之外并没有重写Object的其他方法
        //除了这三个方法之外，代理类调用Object的其他方法不通过invoke
        addProxyMethod(hashCodeMethod, Object.class);
        addProxyMethod(equalsMethod, Object.class);
        addProxyMethod(toStringMethod, Object.class);

	/*
     * Now record all of the methods from the proxy interfaces, giving
	 * earlier interfaces precedence over later ones with duplicate
	 * methods.
	 */

        //获得所有接口中的方法，并将方法添加到代理方法中
        for (int i = 0; i < interfaces.length; i++) {
            Method[] methods = interfaces[i].getMethods();
            for (int j = 0; j < methods.length; j++) {
                addProxyMethod(methods[j], interfaces[i]);
            }
        }

	/*
	 * For each set of proxy methods with the same signature,
	 * verify that the methods' return types are compatible.
	 */
        for (List<ProxyMethod> sigmethods : proxyMethods.values()) {
            checkReturnTypes(sigmethods);
        }

	/* ============================================================
	 * Step 2: Assemble FieldInfo and MethodInfo structs for all of
	 * fields and methods in the class we are generating.
	 */
        try {
            //添加构造方法
            methods.add(generateConstructor());

            for (List<ProxyMethod> sigmethods : proxyMethods.values()) {
                for (ProxyMethod pm : sigmethods) {

                    //add static field for method's Method object
                    fields.add(new FieldInfo(pm.methodFieldName,
                            "Ljava/lang/reflect/Method;",
                            ACC_PRIVATE | ACC_STATIC));

                    //generate code for proxy method and add it

                    //为每个方法生成具有统一结构的方法体，这个方法很重要
                    methods.add(pm.generateMethod());
                }
            }

            //添加静态初始化方法
            methods.add(generateStaticInitializer());

        } catch (IOException e) {
            throw new InternalError("unexpected I/O Exception");
        }

        //方法个数不得超过65535
        if (methods.size() > 65535) {
            throw new IllegalArgumentException("method limit exceeded");
        }

        //字段个数不得超过65535
        if (fields.size() > 65535) {
            throw new IllegalArgumentException("field limit exceeded");
        }

	/* ============================================================
	 * Step 3: Write the final class file.
	 */

	/*
	 * Make sure that constant pool indexes are reserved for the
	 * following items before starting to write the final class file.
	 */
        cp.getClass(dotToSlash(className));
        cp.getClass(superclassName);
        for (int i = 0; i < interfaces.length; i++) {
            cp.getClass(dotToSlash(interfaces[i].getName()));
        }

	/*
	 * Disallow new constant pool additions beyond this point, since
	 * we are about to write the final constant pool table.
	 */
        cp.setReadOnly();

        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);

        try {
	    /*
	     * Write all the items of the "ClassFile" structure.
	     * See JVMS section 4.1.
	     */
            //u4 magic;
            dout.writeInt(0xCAFEBABE);
            //u2 minor_version;
            dout.writeShort(CLASSFILE_MINOR_VERSION);
            //u2 major_version;
            dout.writeShort(CLASSFILE_MAJOR_VERSION);

            cp.write(dout);        //(write constant pool)

            //u2 access_flags;
            dout.writeShort(ACC_PUBLIC | ACC_FINAL | ACC_SUPER);
            //u2 this_class;
            dout.writeShort(cp.getClass(dotToSlash(className)));
            //u2 super_class;
            dout.writeShort(cp.getClass(superclassName));

            //u2 interfaces_count;
            dout.writeShort(interfaces.length);
            //u2 interfaces[interfaces_count];
            for (int i = 0; i < interfaces.length; i++) {
                dout.writeShort(cp.getClass(
                        dotToSlash(interfaces[i].getName())));
            }

            //u2 fields_count;
            dout.writeShort(fields.size());
            //field_info fields[fields_count];
            for (FieldInfo f : fields) {
                f.write(dout);
            }

            //u2 methods_count;
            dout.writeShort(methods.size());
            //method_info methods[methods_count];
            for (MethodInfo m : methods) {
                m.write(dout);
            }

            //u2 attributes_count;
            dout.writeShort(0);    //(no ClassFile attributes for proxy classes)

        } catch (IOException e) {
            throw new InternalError("unexpected I/O Exception");
        }

        return bout.toByteArray();
    }
```

## 3.6 ProxyGenerator.addProxyMethod

将指定方法添加到方法容器中。该容器中的所有方法将会被写入到代理对象中

```Java
    /**
     * Add another method to be proxied, either by creating a new
     * ProxyMethod object or augmenting an old one for a duplicate
     * method.
     * <p>
     * "fromClass" indicates the proxy interface that the method was
     * found through, which may be different from (a subinterface of)
     * the method's "declaring class".  Note that the first Method
     * object passed for a given name and descriptor identifies the
     * Method object (and thus the declaring class) that will be
     * passed to the invocation handler's "invoke" method for a given
     * set of duplicate methods.
     */
    private void addProxyMethod(Method m, Class fromClass) {
        String name = m.getName();
        Class[] parameterTypes = m.getParameterTypes();
        Class returnType = m.getReturnType();
        Class[] exceptionTypes = m.getExceptionTypes();

        //获取方法签名
        String sig = name + getParameterDescriptors(parameterTypes);

        //找到方法签名对应的方法列表
        List<ProxyMethod> sigmethods = proxyMethods.get(sig);
        //检查方法是否已经存在
        if (sigmethods != null) {
            for (ProxyMethod pm : sigmethods) {
                if (returnType == pm.returnType) {
		    /*
		     * Found a match: reduce exception types to the
		     * greatest set of exceptions that can thrown
		     * compatibly with the throws clauses of both
		     * overridden methods.
		     */
                    //方法签名相同的两个方法可能异常列表可能不同，因此需要整合一个最恰当的异常列表
                    List<Class> legalExceptions = new ArrayList<Class>();
                    collectCompatibleTypes(
                            exceptionTypes, pm.exceptionTypes, legalExceptions);
                    collectCompatibleTypes(
                            pm.exceptionTypes, exceptionTypes, legalExceptions);
                    pm.exceptionTypes = new Class[legalExceptions.size()];
                    pm.exceptionTypes =
                            legalExceptions.toArray(pm.exceptionTypes);
                    return;
                }
            }
        } else {
            sigmethods = new ArrayList<ProxyMethod>(3);
            proxyMethods.put(sig, sigmethods);
        }

        //将该方法添加到容器中去
        sigmethods.add(new ProxyMethod(name, parameterTypes, returnType,
                exceptionTypes, fromClass));
    }
```

## 3.7 ProxyMethod.generateMethod

这个方法非常重要，该方法勾勒出代理对象的代理逻辑(对应的是.class文件中的方法属性表部分，即实际存储代码块的区域)。该方法的阅读需要对字节码的格式以及方法属性表的格式非常了解，否则将会一头雾水

```Java
        /**
         * Return a MethodInfo object for this method, including generating
         * the code and exception table entry.
         */
        private MethodInfo generateMethod() throws IOException {
            String desc = getMethodDescriptor(parameterTypes, returnType);
            MethodInfo minfo = new MethodInfo(methodName, desc,
                    ACC_PUBLIC | ACC_FINAL);

            int[] parameterSlot = new int[parameterTypes.length];
            int nextSlot = 1;
            for (int i = 0; i < parameterSlot.length; i++) {
                parameterSlot[i] = nextSlot;
                nextSlot += getWordsPerType(parameterTypes[i]);
            }
            int localSlot0 = nextSlot;
            short pc, tryBegin = 0, tryEnd;

            DataOutputStream out = new DataOutputStream(minfo.code);

            code_aload(0, out);

            out.writeByte(opc_getfield);
            out.writeShort(cp.getFieldRef(
                    superclassName,
                    handlerFieldName, "Ljava/lang/reflect/InvocationHandler;"));

            code_aload(0, out);

            out.writeByte(opc_getstatic);
            out.writeShort(cp.getFieldRef(
                    dotToSlash(className),
                    methodFieldName, "Ljava/lang/reflect/Method;"));

            if (parameterTypes.length > 0) {

                code_ipush(parameterTypes.length, out);

                out.writeByte(opc_anewarray);
                out.writeShort(cp.getClass("java/lang/Object"));

                for (int i = 0; i < parameterTypes.length; i++) {

                    out.writeByte(opc_dup);

                    code_ipush(i, out);

                    codeWrapArgument(parameterTypes[i], parameterSlot[i], out);

                    out.writeByte(opc_aastore);
                }
            } else {

                out.writeByte(opc_aconst_null);
            }

            out.writeByte(opc_invokeinterface);
            out.writeShort(cp.getInterfaceMethodRef(
                    "java/lang/reflect/InvocationHandler",
                    "invoke",
                    "(Ljava/lang/Object;Ljava/lang/reflect/Method;" +
                            "[Ljava/lang/Object;)Ljava/lang/Object;"));
            out.writeByte(4);
            out.writeByte(0);

            if (returnType == void.class) {

                out.writeByte(opc_pop);

                out.writeByte(opc_return);

            } else {

                codeUnwrapReturnValue(returnType, out);
            }

            tryEnd = pc = (short) minfo.code.size();

            List<Class> catchList = computeUniqueCatchList(exceptionTypes);
            if (catchList.size() > 0) {

                for (Class ex : catchList) {
                    minfo.exceptionTable.add(new ExceptionTableEntry(
                            tryBegin, tryEnd, pc,
                            cp.getClass(dotToSlash(ex.getName()))));
                }

                out.writeByte(opc_athrow);

                pc = (short) minfo.code.size();

                minfo.exceptionTable.add(new ExceptionTableEntry(
                        tryBegin, tryEnd, pc, cp.getClass("java/lang/Throwable")));

                code_astore(localSlot0, out);

                out.writeByte(opc_new);
                out.writeShort(cp.getClass(
                        "java/lang/reflect/UndeclaredThrowableException"));

                out.writeByte(opc_dup);

                code_aload(localSlot0, out);

                out.writeByte(opc_invokespecial);

                out.writeShort(cp.getMethodRef(
                        "java/lang/reflect/UndeclaredThrowableException",
                        "<init>", "(Ljava/lang/Throwable;)V"));

                out.writeByte(opc_athrow);
            }

            if (minfo.code.size() > 65535) {
                throw new IllegalArgumentException("code size limit exceeded");
            }

            minfo.maxStack = 10;
            minfo.maxLocals = (short) (localSlot0 + 1);
            minfo.declaredExceptions = new short[exceptionTypes.length];
            for (int i = 0; i < exceptionTypes.length; i++) {
                minfo.declaredExceptions[i] = cp.getClass(
                        dotToSlash(exceptionTypes[i].getName()));
            }

            return minfo;
        }
```

下面这段java代码就是`ProxyMethod.generateMethod`所构造的方法的模板。可以看出，所有的方法调用都必须通过InvocationHandler对象，因此我们可以将增强逻辑写在InvocationHandler#invoke方法中

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

# 4 例子

## 4.1 源码

__Person__：接口

```Java
package org.liuyehcf.jdkproxy;

public interface Person {
    void sayHello();
}
```

__Chinese__：Person接口的实现类

```Java
package org.liuyehcf.jdkproxy;

public class Chinese implements Person {
    public void sayHello() {
        System.out.println("Chinese says hello");
    }
}
```

__Handler__：增强

```Java
package org.liuyehcf.jdkproxy;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;

public class JdkProxyHandler implements InvocationHandler {
    public JdkProxyHandler(Object obj) {
        this.obj = obj;
    }

    private Object obj;

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        System.out.println("pre-processor");

        Object result = method.invoke(obj, args);

        System.out.println("after-processor");

        return result;
    }
}
```

__Demo__

```Java
package org.liuyehcf.jdkproxy;

import sun.misc.ProxyGenerator;

import java.io.FileOutputStream;
import java.lang.reflect.Proxy;

public class JdkProxyDemo {

    public static void main(String[] args) throws Exception {

        Chinese target = new Chinese();

        JdkProxyHandler jdkProxyHandler = new JdkProxyHandler(target);

        Person p = (Person) Proxy.newProxyInstance(target.getClass().getClassLoader(), new Class<?>[]{Person.class}, jdkProxyHandler);

        p.sayHello();

        saveClassFileOfProxy();
    }

    private static void saveClassFileOfProxy() {
        byte[] classFile = ProxyGenerator.generateProxyClass("MyProxy", Chinese.class.getInterfaces());

        FileOutputStream out;

        try {
            out = new FileOutputStream("proxy/target/MyProxy.class");
            out.write(classFile);
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
```

## 4.2 反编译后的代理类源码

直接用IDEA打开class文件就能够自动反编译.class文件了。下面就是反编译后的代理对象的源码

```Java
//
//Source code recreated from a .class file by IntelliJ IDEA
//(powered by Fernflower decompiler)
//

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.lang.reflect.UndeclaredThrowableException;
import org.liuyehcf.jdkproxy.Person;

public final class MyProxy extends Proxy implements Person {
    private static Method m1;
    private static Method m3;
    private static Method m2;
    private static Method m0;

    public MyProxy(InvocationHandler var1) throws  {
        super(var1);
    }

    public final boolean equals(Object var1) throws  {
        try {
            return ((Boolean)super.h.invoke(this, m1, new Object[]{var1})).booleanValue();
        } catch (RuntimeException | Error var3) {
            throw var3;
        } catch (Throwable var4) {
            throw new UndeclaredThrowableException(var4);
        }
    }

    public final void sayHello() throws  {
        try {
            super.h.invoke(this, m3, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final String toString() throws  {
        try {
            return (String)super.h.invoke(this, m2, (Object[])null);
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    public final int hashCode() throws  {
        try {
            return ((Integer)super.h.invoke(this, m0, (Object[])null)).intValue();
        } catch (RuntimeException | Error var2) {
            throw var2;
        } catch (Throwable var3) {
            throw new UndeclaredThrowableException(var3);
        }
    }

    static {
        try {
            m1 = Class.forName("java.lang.Object").getMethod("equals", new Class[]{Class.forName("java.lang.Object")});
            m3 = Class.forName("org.liuyehcf.jdkproxy.Person").getMethod("sayHello", new Class[0]);
            m2 = Class.forName("java.lang.Object").getMethod("toString", new Class[0]);
            m0 = Class.forName("java.lang.Object").getMethod("hashCode", new Class[0]);
        } catch (NoSuchMethodException var2) {
            throw new NoSuchMethodError(var2.getMessage());
        } catch (ClassNotFoundException var3) {
            throw new NoClassDefFoundError(var3.getMessage());
        }
    }
}
```

# 5 参考

* [深度剖析JDK动态代理机制](http://www.cnblogs.com/MOBIN/p/5597215.html)
