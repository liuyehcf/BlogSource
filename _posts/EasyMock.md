---
title: EasyMock
date: 2017-08-28 15:13:17
tags: 
- 原创
categories: 
- Java
- Framework
- Mock
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

mock测试就是在测试过程中，对于某些不容易构造或者不容易获取的对象，用一个__虚拟的对象(不要被虚拟误导，就是Java对象，虚拟描述的是这个对象的行为)__来创建以便测试的测试方法

真实对象具有不可确定的行为，产生不可预测的效果，（如：股票行情，天气预报）真实对象很难被创建的真实对象的某些行为很难被触发真实对象实际上还不存在的（和其他开发小组或者和新的硬件打交道）等等

使用一个接口来描述这个对象。在产品代码中实现这个接口，在测试代码中实现这个接口，在被测试代码中只是通过接口来引用对象，所以它不知道这个引用的对象是真实对象，还是mock对象

# 2 示例

该示例的目的并不是教你如何去用mock进行测试，而是给出mock对象的创建过程以及它的行为

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

输出的结果很有意思，在`EasyMock.replay(mock)`语句之前用两个`EasyMock.expect`设定了"Bob"和"Alice"的预期结果，因此结果符合设定；而"Robot"并没有设定，因此抛出异常

接下来我们将分析以下上述例子中所涉及到的源码，解开mock神秘的面纱

# 3 源码详解

首先来看一下静态方法`EasyMock.createMock`，该方法返回一个Mock对象(给定接口的实例)

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

其中`createMock`是`IMocksControl`接口的方法。该方法接受Class对象，并返回Class对象所代表类型的实例

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

了解了createMock接口定义后，我们来看看具体的实现(`MocksControl#createMock`)

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

IProxyFactory接口有两个实现，JavaProxyFactory(JDK动态代理)和ClassProxyFactory(Cglib)。我们以JavaProxyFactory为例进行讲解，动态代理的实现不是本篇博客的重点。下面给出`JavaProxyFactory#createProxy`方法的源码

```Java
    public T createProxy(final Class<T> toMock, final InvocationHandler handler) {
        // 就是简单调用了JDK动态代理的接口，没有任何难度
        return (T) Proxy.newProxyInstance(toMock.getClassLoader(), new Class[] { toMock }, handler);
    }
```

我们再来回顾一下上述例子中的代码，我们发现一个很奇怪的现象。在EasyMock.replay方法前后，调用mock.isMale所产生的行为是不同的。__在这里EasyMock.replay类似于一个开关__，可以改变mock对象的行为。可是这是如何做到的呢？

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

生成代理对象的方法分析(`IMocksControl#createMock`)我们先暂时放在一边，我们现在先来跟踪一下`EasyMock.replay`方法的执行逻辑。源码如下

```Java
    /**
     * Switches the given mock objects (more exactly: the controls of the mock
     * objects) to replay mode. For details, see the EasyMock documentation.
     * 
     * @param mocks
     *            the mock objects.
     */
    public static void replay(final Object... mocks) {
        for (final Object mock : mocks) {
            // 依次对每个mock对象执行下面的逻辑
            getControl(mock).replay();
        }
    }
```

源码的官方注释中提到，该方法用于切换mock对象的控制模式。再来看下`EasyMock.getControl`方法

```Java
    private static MocksControl getControl(final Object mock) {
        return ClassExtensionHelper.getControl(mock);
    }

    public static MocksControl getControl(final Object mock) {
        try {
            ObjectMethodsFilter handler;

            // mock是由JDK动态代理产生的类型的实例
            if (Proxy.isProxyClass(mock.getClass())) {
                handler = (ObjectMethodsFilter) Proxy.getInvocationHandler(mock);
            }
            // mock是由Cglib产生的类型的实例
            else if (Enhancer.isEnhanced(mock.getClass())) {
                handler = (ObjectMethodsFilter) getInterceptor(mock).getHandler();
            } else {
                throw new IllegalArgumentException("Not a mock: " + mock.getClass().getName());
            }
            // 获取ObjectMethodsFilter封装的MockInvocationHandler的实例，并从MockInvocationHandler的实例中获取MocksControl的实例
            return handler.getDelegate().getControl();
        } catch (final ClassCastException e) {
            throw new IllegalArgumentException("Not a mock: " + mock.getClass().getName());
        }
    }
```

注意到ObjectMethodsFilter是InvocationHandler接口的实现，而ObjectMethodsFilter内部(delegate字段)又封装了一个InvocationHandler接口的实现，其类型是MockInvocationHandler。下面给出`MockInvocationHandler`的源码

```Java
public final class MockInvocationHandler implements InvocationHandler, Serializable {

    private static final long serialVersionUID = -7799769066534714634L;

    // 非常重要的字段，直接决定了下面invoke方法的行为
    private final MocksControl control;

    // 注意到构造方法接受了MocksControl作为参数
    public MockInvocationHandler(final MocksControl control) {
        this.control = control;
    }

    public Object invoke(final Object proxy, final Method method, final Object[] args) throws Throwable {
        try {
            // 如果是记录模式
            if (control.getState() instanceof RecordState) {
                LastControl.reportLastControl(control);
            }
            return control.getState().invoke(new Invocation(proxy, method, args));
        } catch (final RuntimeExceptionWrapper e) {
            throw e.getRuntimeException().fillInStackTrace();
        } catch (final AssertionErrorWrapper e) {
            throw e.getAssertionError().fillInStackTrace();
        } catch (final ThrowableWrapper t) {
            throw t.getThrowable().fillInStackTrace();
        }
        // then let all unwrapped exceptions pass unmodified
    }

    public MocksControl getControl() {
        return control;
    }
}
```

再回到`EasyMock.replay`方法中，getControl(mock)方法返回后调用`MocksControl#replay`方法，下面给出`MocksControl#replay`的源码

```Java
    public void replay() {
        try {
            state.replay();
            // 替换state，将之前收集到的行为(behavior)作为参数传给ReplayState的构造方法
            state = new ReplayState(behavior);
            LastControl.reportLastControl(null);
        } catch (final RuntimeExceptionWrapper e) {
            throw (RuntimeException) e.getRuntimeException().fillInStackTrace();
        }
    }
```

这就是为什么调用EasyMock.replay前后mock对象的行为会发生变化的原因。可以这样理解，如果state是RecordState时，调用mock的方法将会记录行为；如果state是ReplayState时，调用mock的方法将会从之前记录的行为中进行查找，如果找到了则调用，如果没有则抛出异常

EasyMock的源码就分析到这里，日后再细究ReplayState与RecordState的源码

# 4 参考

* [百度百科](https://baike.baidu.com/item/mock%E6%B5%8B%E8%AF%95/5300937?fr=aladdin)
