---
title: Java-Lambda
date: 2018-02-02 19:10:24
tags: 
- 原创
categories: 
- Java
- Grammar
---

**阅读更多**

<!--more-->

# 1 Programming Paradigm

A programming paradigm is a fundamental style or approach to programming that is characterized by distinct features and methodologies. It influences the structure and elements of the programs we write. Different paradigms offer different perspectives on the way problems should be solved and code should be organized. Here are some of the most common programming paradigms:

1. `Procedural Programming`: This paradigm is based on the concept of "procedure calls" where programs are a series of computational steps to be carried out. Each procedure contains a series of computational steps to be carried out. Procedural programming languages include C, Go, and Rust.
1. `Object-oriented Programming (OOP)`: In OOP, programs are designed using objects that interact with each other. An object is an instance of a class, which can contain data and methods. The main principles of OOP are encapsulation, inheritance, and polymorphism. Examples of OOP languages include Java, C++, and Python.
1. `Functional Programming`: In functional programming, computation is treated as the evaluation of mathematical functions and avoids changing-state and mutable data. It promotes code that is more predictable and easier to test. Some examples of functional languages are Haskell, Erlang, and Lisp. However, many modern languages like Python, JavaScript, and C# support functional programming to a certain degree.
1. `Declarative Programming`: In declarative programming, developers write code to describe what the program should accomplish, rather than how to achieve it. SQL and HTML are examples of declarative languages. The declarative paradigm also includes functional programming as a subset.
1. `Logic Programming`: This paradigm is primarily used in artificial intelligence. Programs are written in the form of logic statements, and the system finds the solution that satisfies these statements. Prolog is a well-known logic programming language.
1. `Event-Driven Programming`: In this paradigm, the flow of the program is determined by events such as user actions, sensor outputs, or messages from other programs. JavaScript, used for front-end web development, is an example of an event-driven programming language.
1. `Concurrent Programming`: This paradigm deals with constructing software systems that are capable of running multiple computations and processes concurrently. This is different from parallel programming where multiple computations are literally running at the same time on different cores or machines. Some languages designed with concurrency in mind are Erlang and Go.

Each of these paradigms have their own strengths and weaknesses and are used in different contexts. It's also important to note that many programming languages support multiple paradigms. For instance, Python supports both procedural and object-oriented programming.
 
# 2 Lambda Expression

A lambda expression is a small anonymous function that is defined using the keyword lambda. It is a feature in many programming languages including Python, Java, C# and others, and is a concept derived from lambda calculus, a framework developed in the 1930s to study functions and their evaluation.

A lambda expression can take any number of arguments, but can only have one expression. The lambda function can be used wherever function objects are required. Because it's limited to an expression, a lambda is less general than a function - you can only squeeze so much logic into a single expression.

## 2.1 Grammar

In Java, lambda expressions were introduced in Java 8. They are used to implement methods in functional interfaces without creating a separate class. The general syntax of a lambda expression in Java is:

```
(parameter1, parameter2, ...) -> expression
```

or 

```
(parameter1, parameter2, ...) -> { statements; }
```

## 2.2 Functional Interface

Functional interfaces in Java are a key concept related to lambda expressions. A functional interface is an interface that contains just one abstract method. They are used as the basis for lambda expressions in functional programming.

In Java 8, a special annotation @FunctionalInterface has been introduced which can be used for indicating that an interface is intended to be a functional interface. This annotation is optional but it's a good practice to use it. The Java compiler will generate an error message if a type annotated with @FunctionalInterface is not a valid functional interface.

Here is a simple example of a functional interface:

```java
@FunctionalInterface
public interface SimpleInterface {
    void doSomething();
}
```

# 3 Stream

In Java, the Stream API was introduced in Java 8 to support functional-style operations on streams of elements. The Stream API is in the java.util.stream package. It provides a high-level abstraction for performing complex data processing operations, such as filtering, mapping, reducing, finding, matching, etc.

A Stream in Java is a sequence of elements from a source that supports data processing operations. Sources can be collections, lists, sets, ints, longs, doubles, arrays, lines of a file, etc.

Here are some key characteristics of Java Stream:

* `Stream Operations Are Lazy`: Many stream operations, such as filtering and mapping, are implemented lazily, meaning they only process the elements of the stream when it's absolutely necessary.
* `Streams Are Consumable`: The elements of a stream are only visited once during the life of a stream. Like an Iterator, a new stream must be generated to revisit the same elements of the source.
* `Stream Can Be Parallel`: The data processing operations can either be executed sequentially or parallely which can significantly reduce the processing time.

There are several commonly used interfaces in the Java Stream API, including:

* `Stream<T>`: This is the most commonly used Stream interface, representing a sequence of objects. The `"<T>"` is a type parameter that represents the type of object in the stream. It has methods like filter, map, reduce, collect, forEach, and many others.
* `IntStream, LongStream, DoubleStream`: These are primitive specializations of the Stream interface for working with streams of ints, longs and doubles respectively, to avoid the overhead of boxing and unboxing. They have methods like sum, average, range, etc.
* `Function<T,R>`: A functional interface used for lambda expressions that take an object of one type and return an object of another type. It's often used with the map function to transform a stream of objects.
* `Predicate<T>`: This functional interface is used for lambda expressions that take an object and return a boolean. It's often used with the filter function to filter a stream of objects.
* `Consumer<T>`: This functional interface represents an operation that takes an input and returns no result. It's often used with the forEach method to consume (or process) a stream of objects.
* `Supplier<T>`: Represents a function that supplies values. It takes no arguments but returns a value. It can be used in the generate method of a stream to provide new values for a stream.
* `Comparator<T>`: Used for defining the logic for sorting elements of a stream.

The Java Stream API offers a rich set of methods for processing sequences of elements. Here are some commonly used ones:

* `map(Function mapper)`: Returns a stream consisting of the results of applying the given function to the elements of this stream.
* `filter(Predicate predicate)`: Returns a stream consisting of the elements of this stream that match the given predicate.
* `forEach(Consumer action)`: Performs an action for each element of this stream.
* `collect(Collector collector)`: Performs a mutable reduction operation on the elements of this stream using a Collector.
* `reduce(BinaryOperator accumulator)`: Performs a reduction on the elements of this stream, using an associative accumulation function, and returns an Optional describing the reduced value, if any.
* `sorted() and sorted(Comparator comparator)`: Returns a stream consisting of the elements of the original stream, sorted according to natural order or by a provided Comparator.
* `limit(long maxSize)`: Returns a stream consisting of the elements of this stream, truncated to be no longer than maxSize in length.
* `skip(long n)`: Returns a stream consisting of the remaining elements of this stream after discarding the first n elements of the stream.
* `anyMatch(Predicate predicate), allMatch(Predicate predicate), noneMatch(Predicate predicate)`: These methods return a boolean and are used to test whether a certain property holds for elements of the stream.
* `findFirst() and findAny()`: Return an Optional describing the first or any element of this stream, respectively.
* `toArray()`: Returns an array containing the elements of this stream.
* `count()`: Returns the count of elements in the stream.
* `flatMap(Function mapper)`: Returns a stream consisting of the results of replacing each element of this stream with the contents of a mapped stream produced by applying the provided mapping function to each element.

# 4 Collectors

Java's Collectors class provides a number of methods that can be used in conjunction with the collect method of the Stream API to reduce the stream's elements into a summary result.

Here are some commonly used methods provided by the Collectors class:

* `toList()`: Collects the stream's elements into a new List.
* `toSet()`: Collects the stream's elements into a new Set.
* `toMap(Function keyMapper, Function valueMapper)`: Collects the stream's elements into a Map. The keyMapper function generates the map's keys, and the valueMapper function generates the map's values.
* `joining(CharSequence delimiter)`: Concatenates the stream's CharSequence elements into a single CharSequence separated by the specified delimiter.
* `counting()`: Counts the number of elements in the stream.
* `summingInt(ToIntFunction mapper), summingLong(ToLongFunction mapper), summingDouble(ToDoubleFunction mapper)`: Sums the results of applying a mapping function to the stream's elements.
* `averagingInt(ToIntFunction mapper), averagingLong(ToLongFunction mapper), averagingDouble(ToDoubleFunction mapper)`: Computes the average of the results of applying a mapping function to the stream's elements.
* `minBy(Comparator comparator) and maxBy(Comparator comparator)`: Find the minimum or maximum element of the stream according to a comparator.
* `groupingBy(Function classifier)`: Groups the stream's elements according to a classifier function, and returns a Map.
* `partitioningBy(Predicate predicate)`: Partitions the stream's elements into two groups according to a predicate.

## 4.1 Examples

**`flatMap`**

```java
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

class Main {
    public static void main(String[] args) {
        List<List<Integer>> listOfLists =
                Arrays.asList(
                        Arrays.asList(1, 2, 3), Arrays.asList(4, 5, 6), Arrays.asList(7, 8, 9));

        List<Integer> allIntegers =
                listOfLists.stream()
                        .flatMap(List::stream) // replaces each list with the stream of its integers
                        .collect(Collectors.toList());

        System.out.println(allIntegers); // prints [1, 2, 3, 4, 5, 6, 7, 8, 9]
    }
}
```

**`Collectors.groupingBy`**

```java
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

class KV {
    public KV(int key, int value) {
        this.key = key;
        this.value = value;
    }

    public int key;
    public int value;

    public int key() {
        return key;
    }

    public int value() {
        return value;
    }
}

class Main {
    public static void main(String[] args) {
        List<KV> pairs = new ArrayList<>();
        pairs.add(new KV(1, 1));
        pairs.add(new KV(1, 2));
        pairs.add(new KV(1, 3));
        pairs.add(new KV(2, 2));
        pairs.add(new KV(2, 3));

        Map<Integer, Integer> sums =
                pairs.stream()
                        .collect(Collectors.groupingBy(KV::key, Collectors.summingInt(KV::value)));

        System.out.println(sums); // {1=6, 2=5}
    }
}
```

# 5 参考

* [JDK 8 函数式编程入门](https://www.cnblogs.com/snowInPluto/p/5981400.html)
* [Lambda expression](https://en.wikipedia.org/wiki/Lambda_expression)
* [JDK8新特性：函数式接口@FunctionalInterface的使用说明](http://blog.csdn.net/aitangyong/article/details/54137067)
