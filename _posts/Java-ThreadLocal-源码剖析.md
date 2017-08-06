---
title: Java ThreadLocal 源码剖析
date: 2017-07-10 18:46:54
tags: 
- 原创
categories: 
- Java
- Java 并发
- Java concurrent 源码剖析
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

JDK 1.2的版本中就提供java.lang.ThreadLocal，ThreadLocal为解决多线程程序的并发问题提供了一种新的思路。使用这个工具类可以很简洁地编写出优美的多线程程序，ThreadLocal并不是一个Thread，而是Thread的局部变量。

# 2 内部类 ThreadLocalMap

ThreadLocalMap用于存放<ThreadLocal,T>这样的键值对，ThreadLocal对象为键值

1. 一个线程中可以存放着很多个以ThreadLocal为键值的键值对

```Java
    static class ThreadLocalMap {

        /**
         * The entries in this hash map extend WeakReference, using
         * its main ref field as the key (which is always a
         * ThreadLocal object).  Note that null keys (i.e. entry.get()
         * == null) mean that the key is no longer referenced, so the
         * entry can be expunged from table.  Such entries are referred to
         * as "stale entries" in the code that follows.
         */
        static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }

        // ...省略其他
    }
```

# 3 重要方法

ThreadLocalMap仅有三个接口方法，即get、set、remove方法，我们以这三个方法为切入点慢慢揭开ThreadLocal的奥秘

## 3.1 get

get方法用于从当前线程中取出该线程本地的对象，当前线程指的就是调用get方法的线程。如果该变量在当前线程中的副本尚未初始化，那么调用initialValue方法进行初始化

```Java
    /**
     * Returns the value in the current thread's copy of this
     * thread-local variable.  If the variable has no value for the
     * current thread, it is first initialized to the value returned
     * by an invocation of the {@link #initialValue} method.
     *
     * @return the current thread's value of this thread-local
     */
    public T get() {
        // 获取当前线程
        Thread t = Thread.currentThread();
        // 获取当前线程所关联的一个Map
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            // 找到了已经初始化过的线程本地对象，那么转型后返回即可
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        // 执行到这里说明map为空或者线程本地对象尚未初始化，那么继续初始化逻辑
        return setInitialValue();
    }
```

### 3.1.1 getMap

getMap方法用于获取给定线程对象所关联的Map。可以看出ThreadLocal的实现还需要Thread的配合，Thread对象中含有一个`threadLocals`字段

```Java
    /**
     * Get the map associated with a ThreadLocal. Overridden in
     * InheritableThreadLocal.
     *
     * @param  t the current thread
     * @return the map
     */
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
```

### 3.1.2 setInitialValue

setInitialValue方法用于初始化线程本地对象或者初始化给定线程关联的map

```Java
    /**
     * Variant of set() to establish initialValue. Used instead
     * of set() in case user has overridden the set() method.
     *
     * @return the initial value
     */
    private T setInitialValue() {
        // 首先调用initialValue来初始化对象
        T value = initialValue();
        // 获取线程对象
        Thread t = Thread.currentThread();
        // 获取线程对象关联的map
        ThreadLocalMap map = getMap(t);
        // 如果map已经初始化了
        if (map != null)
            // 那么直接将value存入即可，注意以ThreadLocal对象为键值
            map.set(this, value);
        else
            // 初始化map并且存入value
            createMap(t, value);
        return value;
    }
```

### 3.1.3 initialValue

该方法用于定义线程本地对象的初始化操作，类似于一个工厂方法，用于生产线程本地的对象

该方法是一个protected修饰的方法，线程本地变量的初始化操作交给子类去实现

```Java
    /**
     * Returns the current thread's "initial value" for this
     * thread-local variable.  This method will be invoked the first
     * time a thread accesses the variable with the {@link #get}
     * method, unless the thread previously invoked the {@link #set}
     * method, in which case the {@code initialValue} method will not
     * be invoked for the thread.  Normally, this method is invoked at
     * most once per thread, but it may be invoked again in case of
     * subsequent invocations of {@link #remove} followed by {@link #get}.
     *
     * <p>This implementation simply returns {@code null}; if the
     * programmer desires thread-local variables to have an initial
     * value other than {@code null}, {@code ThreadLocal} must be
     * subclassed, and this method overridden.  Typically, an
     * anonymous inner class will be used.
     *
     * @return the initial value for this thread-local
     */
    protected T initialValue() {
        return null;
    }
```

### 3.1.4 createMap

就是新建一个Map然后赋值给指定的Thread对象，并且存入一个指定的value，很简单，不多说

```Java
    /**
     * Create the map associated with a ThreadLocal. Overridden in
     * InheritableThreadLocal.
     *
     * @param t the current thread
     * @param firstValue value for the initial entry of the map
     */
    void createMap(Thread t, T firstValue) {
        t.threadLocals = new ThreadLocalMap(this, firstValue);
    }
```

## 3.2 set

set方法就是用于将一个对象存入线程关联的Map中去，以当前线程对象为键值

```Java
    /**
     * Sets the current thread's copy of this thread-local variable
     * to the specified value.  Most subclasses will have no need to
     * override this method, relying solely on the {@link #initialValue}
     * method to set the values of thread-locals.
     *
     * @param value the value to be stored in the current thread's copy of
     *        this thread-local.
     */
    public void set(T value) {
        // 获取当前线程对象
        Thread t = Thread.currentThread();
        // 获取当前线程对象关联的map
        ThreadLocalMap map = getMap(t);
        // 如果map已经初始化过了
        if (map != null)
            // 直接存入值即可
            map.set(this, value);
        else
            // 否则初始化map并且存入值
            createMap(t, value);
    }
```

## 3.3 remove

remove方法用于将当前ThreadLocal为键值的键值对从当前线程的map中除去

```Java
    /**
     * Removes the current thread's value for this thread-local
     * variable.  If this thread-local variable is subsequently
     * {@linkplain #get read} by the current thread, its value will be
     * reinitialized by invoking its {@link #initialValue} method,
     * unless its value is {@linkplain #set set} by the current thread
     * in the interim.  This may result in multiple invocations of the
     * {@code initialValue} method in the current thread.
     *
     * @since 1.5
     */
     public void remove() {
         ThreadLocalMap m = getMap(Thread.currentThread());
         if (m != null)
             m.remove(this);
     }
```
