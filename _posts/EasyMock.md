---
title: EasyMock
date: 2017-08-28 15:13:17
tags: 
- 摘录
categories: 
- Java
- Framework
- Mock
- EasyMock 源码分析
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

mock测试就是在测试过程中，对于某些不容易构造或者不容易获取的对象，用一个__虚拟的对象(不要被虚拟误导，就是Java对象，虚拟描述的是这个对象的行为)__来创建以便测试的测试方法。

真实对象具有不可确定的行为，产生不可预测的效果，（如：股票行情，天气预报）真实对象很难被创建的真实对象的某些行为很难被触发真实对象实际上还不存在的（和其他开发小组或者和新的硬件打交道）等等。

使用一个接口来描述这个对象。在产品代码中实现这个接口，在测试代码中实现这个接口，在被测试代码中只是通过接口来引用对象，所以它不知道这个引用的对象是真实对象，还是mock对象。

# 2 示例

该示例的目的并不是教你如何去用mock进行测试，而是给出mock对象的创建过程以及它的行为。

1. 首先创建Mock对象，即代理对象
1. 设定EasyMock的相应逻辑，即打桩
1. 调用mock对象的相应逻辑

```Java
interface Human {
    boolean isMale(String name);
}

public class TestEasyMock {
    public static void main(String[] args) {
        Human mock = EasyMock.createMock(Human.class);

        EasyMock.expect(mock.isMale("Bob")).andReturn(true);
        EasyMock.expect(mock.isMale("Alice")).andReturn(true);

        EasyMock.replay(mock);

        System.out.println(mock.isMale("Bob"));
        System.out.println(mock.isMale("Alice"));
        System.out.println(mock.isMale("Robot"));
    }
}
```

以下是输出

```Java
true
true
java.lang.AssertionError: 
  Unexpected method call Human.isMale("Robot"):
	at org.easymock.internal.MockInvocationHandler.invoke(MockInvocationHandler.java:44)
	at org.easymock.internal.ObjectMethodsFilter.invoke(ObjectMethodsFilter.java:85)
Disconnected from the target VM, address: '127.0.0.1:59825', transport: 'socket'
	at org.liuyehcf.easymock.$Proxy0.isMale(Unknown Source)
	at org.liuyehcf.easymock.TestEasyMock.main(TestEasyMock.java:28)
```

输出的结果很有意思，在`EasyMock.replay(mock)`语句之前用两个`EasyMock.expect`设定了"Bob"和"Alice"的预期结果，因此结果符合设定；而"Robot"并没有设定，因此抛出异常。

接下来我们将分析以下上述例子中所涉及到的源码，解开mock神秘的面纱。

# 3 EasyMock.createMock

首先来看一下静态方法EasyMock.createMock，该方法返回一个Mock对象(给定接口的实例)

```Java
    /**
     * Creates a mock object that implements the given interface, order checking
     * is disabled by default.
     * 
     * @param <T>
     *            the interface that the mock object should implement.
     * @param toMock
     *            the class of the interface that the mock object should
     *            implement.
     * @return the mock object.
     */
    public static <T> T createMock(final Class<T> toMock) {
        return createControl().createMock(toMock);
    }
```

其中createMock是IMocksControl接口的方法，接受指定Class对象，并返回该类型的实例

```Java
    /**
     * Creates a mock object that implements the given interface.
     * 
     * @param <T>
     *            the interface or class that the mock object should
     *            implement/extend.
     * @param toMock
     *            the interface or class that the mock object should
     *            implement/extend.
     * @return the mock object.
     */
    <T> T createMock(Class<T> toMock);
```

了解了createMock接口定义后，我们来看看具体的实现(MocksControl#createMock)

```Java
    public <T> T createMock(final Class<T> toMock) {
        try {
            state.assertRecordState();
            // 创建一个代理工厂
            final IProxyFactory<T> proxyFactory = createProxyFactory(toMock);
            // 利用工厂产生代理类的对象
            return proxyFactory.createProxy(toMock, new ObjectMethodsFilter(toMock,
                    new MockInvocationHandler(this), null));
        } catch (final RuntimeExceptionWrapper e) {
            throw (RuntimeException) e.getRuntimeException().fillInStackTrace();
        }
    }
```

IProxyFactory接口有两个实现，JavaProxyFactory(JDK动态代理)和ClassProxyFactory(Cglib)。我们以JavaProxyFactory为例进行讲解，动态代理的实现不是本篇博客的重点。下面给出JavaProxyFactory#createProxy方法的源码

```Java
    public T createProxy(final Class<T> toMock, final InvocationHandler handler) {
        // 就是简单调用了JDK动态代理的接口，没有任何难度
        return (T) Proxy.newProxyInstance(toMock.getClassLoader(), new Class[] { toMock }, handler);
    }
```

我们再来回顾一下上述例子中的代码，我们发现一个很奇怪的现象。在EasyMock.replay方法前后，调用mock.isMale所产生的行为是不同的。__在这里EasyMock.replay类似于一个开关__，可以改变mock对象的行为。可是这是如何做到的呢？__这就要借助于ObjectMethodsFilter这个InvocationHandler的实现类了。__

```Java
        // 这里调用mock的isMale方法不会抛出异常
        EasyMock.expect(mock.isMale("Bob")).andReturn(true);
        EasyMock.expect(mock.isMale("Alice")).andReturn(true);

        // 关键开关语句
        EasyMock.replay(mock);

        // 这里只能调用上面预定义行为的方法，若没有设定预期值那么将抛出异常
        System.out.println(mock.isMale("Bob"));
        System.out.println(mock.isMale("Alice"));
        System.out.println(mock.isMale("Robot"));
```

# 4 参考

* [百度百科](https://baike.baidu.com/item/mock%E6%B5%8B%E8%AF%95/5300937?fr=aladdin)
