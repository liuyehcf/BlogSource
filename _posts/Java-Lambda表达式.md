---
title: Java-Lambda表达式
date: 2018-02-02 19:10:24
tags: 
- 原创
categories: 
- Java
- Grammar
---

__目录__

<!-- toc -->
<!--more-->

# 1 编程范式简介

__编程范型__或__编程范式__（英语：Programming paradigm），（范即模范之意，范式即模式、方法），是一类典型的编程风格，是指从事软件工程的一类典型的风格（可以对照方法学）。如：__函数式编程、程序编程、面向对象编程、指令式编程__等等为不同的编程范型

编程范型提供了（同时决定了）程序员对程序执行的看法。例如，在面向对象编程中，程序员认为程序是一系列相互作用的对象，而在函数式编程中一个程序会被看作是一个无状态的函数计算的序列

## 1.1 函数式编程

函数式编程作为一种编程范式，在科学领域，是一种编写计算机程序数据结构和元素的方式，它把计算过程当做是数学函数的求值，而避免更改状态和可变数据

函数式编程并非近几年的新技术或新思维，距离它诞生已有大概50多年的时间了。它一直不是主流的编程思维，但在众多的所谓顶级编程高手的科学工作者间，函数式编程是十分盛行的

什么是函数式编程？简单的回答：一切都是数学函数。函数式编程语言里也可以有对象，但通常这些对象都是恒定不变的：要么是函数参数，要什么是函数返回值。函数式编程语言里没有 for/next 循环，因为这些逻辑意味着有状态的改变。相替代的是，这种循环逻辑在函数式编程语言里是通过递归、把函数当成参数传递的方式实现的

# 2 Lambda表达式

## 2.1 Lambda表达式的定义

什么是Lambda表达式？在计算机编程中，__Lambda表达式，又称匿名函数__（anonymous function）是指__一类无需定义标识符（函数名）的`函数或子程序`，普遍存在于多种编程语言中__

## 2.2 Lambda表达式在Java中的表现形式

Java 中 Lambda 表达式一共有五种基本形式，具体如下：

①

```Java
Runnable noArguments = () -> System.out.println("Hello World");
```

②

```Java
ActionListener oneArgument = event -> System.out.println("button clicked");
```

③

```Java
Runnable multiStatement = () -> {
    System.out.print("Hello");
    System.out.println(" World");
};
```

④

```Java
BinaryOperator<Long> add = (x, y) -> x + y;
```

⑤

```Java
BinaryOperator<Long> addExplicit = (Long x, Long y) -> x + y;
```

其语法可以总结如下：

* `left -> right`
1. 对于__形参列表为空__的接口方法，`left`写成`()`即可（例如①和③）
1. 对于__仅有一个形参__的接口方法，`left`可以只写参数名，不需要`()`包裹，当然用`()`包裹自然是对的（例如②）
1. 对于__含有多个形参__的接口方法，`left`必须用`()`包裹（例如④和⑤）
1. 对于__形参列表不为空__的接口方法，`left`可以只写参数名，也可以带上类型（例如②、④和⑤）
1. 对于__仅包含一条语句__的函数体，`right`__可以不__用`{}`包裹，当然用`{}`包裹自然是对的（例如①、②、④和⑤）
    * 如果该条语句是return语句，且__不用__`{}`包裹，那么return关键字__不能写__
1. 对于__包含多条语句__的函数体，`right`必须用`{}`包裹（例如③）
    * 此时的语法与正常方法中的语法一致

## 2.3 函数式接口

__函数式接口必须满足以下条件__

* 有且仅有一个抽象方法
* 接口中的静态方法和默认方法，都__不算__是抽象方法
* 接口默认继承java.lang.Object，所以如果接口显示声明覆盖了Object中方法，那么也__不算__抽象方法

__对于函数式接口，其实例可以通过Lambda表达式、方法引用或者构造器引用创建__

JDK 1.8中新增了@FunctionalInterface注解用于标记函数式接口。该注解__不是必须__的，如果一个接口符合“函数式接口”定义，那么加不加该注解都没有影响。加上该注解能够更好地让编译器进行检查。如果编写的不是函数式接口，但是加上了@FunctionInterface，那么编译器会报错。事实上，每个用作函数接口的接口都__应该__添加这个注解。__该注解会强制`javac`检查一个接口是否符合函数接口的标准。如果该注解添加给一个枚举类型、类或另一个注解，或者接口包含不止一个抽象方法，javac就会报错。重构代码时，使用它能很容易发现问题__

# 3 Stream简介

JDK 1.8中，引入了流（Stream）的概念，这个流和以前我们使用的IO中的流并不太相同

__所有继承自`Collection`的接口都可以转换为`Stream`__

我们来看一下Stream接口的源码

```Java
public interface Stream<T> extends BaseStream<T, Stream<T>> {

    Stream<T> filter(Predicate<? super T> predicate);

    <R> Stream<R> map(Function<? super T, ? extends R> mapper);

    IntStream mapToInt(ToIntFunction<? super T> mapper);

    LongStream mapToLong(ToLongFunction<? super T> mapper);

    DoubleStream mapToDouble(ToDoubleFunction<? super T> mapper);

    <R> Stream<R> flatMap(Function<? super T, ? extends Stream<? extends R>> mapper);

    LongStream flatMapToLong(Function<? super T, ? extends LongStream> mapper);

    DoubleStream flatMapToDouble(Function<? super T, ? extends DoubleStream> mapper);

    Stream<T> distinct();

    Stream<T> sorted();

    Stream<T> sorted(Comparator<? super T> comparator);

    Stream<T> peek(Consumer<? super T> action);

    Stream<T> limit(long maxSize);

    Stream<T> skip(long n);

    void forEach(Consumer<? super T> action);

    void forEachOrdered(Consumer<? super T> action);

    Object[] toArray();

    <A> A[] toArray(IntFunction<A[]> generator);

    T reduce(T identity, BinaryOperator<T> accumulator);

    Optional<T> reduce(BinaryOperator<T> accumulator);

    <U> U reduce(U identity,
                 BiFunction<U, ? super T, U> accumulator,
                 BinaryOperator<U> combiner);

    <R> R collect(Supplier<R> supplier,
                  BiConsumer<R, ? super T> accumulator,
                  BiConsumer<R, R> combiner);

    <R, A> R collect(Collector<? super T, A, R> collector);

    Optional<T> min(Comparator<? super T> comparator);

    Optional<T> max(Comparator<? super T> comparator);

    long count();

    boolean anyMatch(Predicate<? super T> predicate);

    boolean allMatch(Predicate<? super T> predicate);

    boolean noneMatch(Predicate<? super T> predicate);

    Optional<T> findFirst();

    Optional<T> findAny();

    // Static factories
    public static<T> Builder<T> builder() {
        return new Streams.StreamBuilderImpl<>();
    }

    public static<T> Stream<T> empty() {
        return StreamSupport.stream(Spliterators.<T>emptySpliterator(), false);
    }

    public static<T> Stream<T> of(T t) {
        return StreamSupport.stream(new Streams.StreamBuilderImpl<>(t), false);
    }

    @SafeVarargs
    @SuppressWarnings("varargs") // Creating a stream from an array is safe
    public static<T> Stream<T> of(T... values) {
        return Arrays.stream(values);
    }

    public static<T> Stream<T> iterate(final T seed, final UnaryOperator<T> f) {
        Objects.requireNonNull(f);
        final Iterator<T> iterator = new Iterator<T>() {
            @SuppressWarnings("unchecked")
            T t = (T) Streams.NONE;

            @Override
            public boolean hasNext() {
                return true;
            }

            @Override
            public T next() {
                return t = (t == Streams.NONE) ? seed : f.apply(t);
            }
        };
        return StreamSupport.stream(Spliterators.spliteratorUnknownSize(
                iterator,
                Spliterator.ORDERED | Spliterator.IMMUTABLE), false);
    }

    public static<T> Stream<T> generate(Supplier<T> s) {
        Objects.requireNonNull(s);
        return StreamSupport.stream(
                new StreamSpliterators.InfiniteSupplyingSpliterator.OfRef<>(Long.MAX_VALUE, s), false);
    }

    public static <T> Stream<T> concat(Stream<? extends T> a, Stream<? extends T> b) {
        Objects.requireNonNull(a);
        Objects.requireNonNull(b);

        @SuppressWarnings("unchecked")
        Spliterator<T> split = new Streams.ConcatSpliterator.OfRef<>(
                (Spliterator<T>) a.spliterator(), (Spliterator<T>) b.spliterator());
        Stream<T> stream = StreamSupport.stream(split, a.isParallel() || b.isParallel());
        return stream.onClose(Streams.composedClose(a, b));
    }

    public interface Builder<T> extends Consumer<T> {

        @Override
        void accept(T t);

        default Builder<T> add(T t) {
            accept(t);
            return this;
        }

        Stream<T> build();

    }
}

```

Stream接口本身并不是函数式接口（废话），但是Stream的许多方法的参数都是函数式接口，支持Lambda表达式。以下是常用的函数式接口

| 接口 | 参数 | 返回类型 | 描述 |
|:--|:--|:--|:--|
| Predicate<T> | T | boolean | 用于判别一个对象。比如求一个人是否为男性 |
| Consumer<T> | T | void | 用于接收一个对象进行处理但没有返回，比如接收一个人并打印他的名字 |
| Function<T, R> | T | R | 转换一个对象为不同类型的对象 |
| Supplier<T> | None | T | 提供一个对象 |
| UnaryOperator<T> | T | T | 接收对象并返回同类型的对象 |
| BinaryOperator<T> | (T, T) | T | 接收两个同类型的对象，并返回一个原类型对象 |

# 4 参考

* [JDK 8 函数式编程入门](https://www.cnblogs.com/snowInPluto/p/5981400.html)
* [Lambda expression](https://en.wikipedia.org/wiki/Lambda_expression)
* [JDK8新特性：函数式接口@FunctionalInterface的使用说明](http://blog.csdn.net/aitangyong/article/details/54137067)