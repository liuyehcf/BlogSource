---
title: Java 重排序
date: 2017-07-08 21:01:00
ags:
- 摘录
categories:
- Java
- Java Virtual Machine
- Java Memory Model
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

重排序是指编译器和处理器为了优化程序性能而对指令序列进行重新排序的一种手段

# 2 数据依赖性

如果两个操作访问__同一个变量__，且这两个操作中__有一个为写操作__，此时这两个操作之间就存在数据依赖性。数据依赖性分为以下三种

| 名称 | 代码示例 | 说明 |
|:--:|:--:|:--:|
| 写后读 | a = 1;  b = a; | 写一个变量之后，再读这个位置 |
| 写后写 | a = 1;  a = 2; | 写一个变量之后，再写这个变量 |
| 读后写 | a = b;  b = 1; | 读一个变量之后，再写这个变量 |

* 上面三种情况，只要重排序两个操作的执行顺序，程序的执行结果就会被改变

编译器和处理器可能会对操作做重排序。编译器和处理器在重排序时，会遵守数据依赖性，编译器和处理器不会改变存在数据依赖关系的两个操作的执行顺序

* 这里所说的数据依赖性仅针对__单个处理器__中执行的指令序列和__单个线程__中执行的操作，不同处理器之间和不同线程之间的数据依赖性不被编译器和处理器考虑

# 3 控制依赖性

在单线程程序中，对存在控制依赖的操作重排序，不会改变执行结果(这也是as-if-serial语义允许对存在控制依赖的操作做重排序的原因)；但在多线程程序中，对存在控制依赖的操作重排序，可能会改变程序的执行结果

例如如下示例代码

```
if (flag)// 1
    int i = a * a;// 2
```

* 可能的执行时序如下

```sequence
Note over 线程B:temp = a * a;
Note over 线程B:if (flag)
Note over 线程B:int i = temp;
```

* 当代码中存在控制依赖性时，会影响指令序列执行的并行度。为此，编译器和处理器会采用猜测(speculation)执行来克服控制相关性对并行度的影响。以处理器的猜测执行为例，执行线程B的处理器可以提前读取并计算a * a，然后把计算结果临时保存到一个名为重排序缓冲(Recorder Buffer, ROB)的硬件缓存中。当操作1的条件判断为真时，就把该计算结果写入变量i中

# 4 as-if-serial语义

__as-if-serial语义的意思是：不管怎么重排序(编译器和处理器为了提高并行度)，(单线程)程序的执行结果不能被改变。编译器、runtime和处理器都必须遵守as-if-serial语义__

为了遵守as-if-serial语义，编译器和处理器不会对存在数据依赖关系的操作做重排序，因为这种重排序会改变执行结果。但是，如果操作之间不存在数据依赖关系，这些操作就可能被编译器和处理器重排。以下面的示例代码进行讲解

```Java
double pi = 3.14;// A
double r = 1.0;// B
double area = pi * r * r;// C
```

* 利用javap解析字节码，输出片段如下

```Java
public void writer();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=4, locals=7, args_size=1
         0: ldc2_w        #2                  // double 3.14d
         3: dstore_1
         4: dconst_1
         5: dstore_3
         6: dload_1
         7: dload_3
         8: dmul
         9: dload_3
        10: dmul
        11: dstore        5
        13: return
      LineNumberTable:
        line 13: 0
        line 14: 4
        line 15: 6
        line 16: 13
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      14     0  this   LReentrantLockExample;
            4      10     1    pi   D
            6       8     3     r   D
           13       1     5  area   D
```

* A和C之间存在数据依赖性，同时B和C之间存在数据依赖性。因此在最终执行的指令序列中，C不能被重排序到A和B的前面。但是A和B之间没有数据依赖关系，编译器和处理器可以重排序A和B之间的执行顺序
* javap输出内容中
    * `0: ldc2_w`必须在`3: dstore_1`之前，这两条字节码代表了`double pi = 3.14;//A`
    * `4: dconst_1`必须在`5: dstore_3`之前，这两条字节码代表了`double r = 1.0;//B`
    * 在保证上述两条规则下，这4条字节码可以任意重排序，即A和B之间可以重排序
    * 但是这四条字节码必须排在`6: dload_1`和`7: dload_3`这两条字节码的前面

as-if-serial语义把单线程程序保护了起来，遵守as-if-serial语义的编译器、runtime和处理器共同为编写__单线程程序__的程序员创建了一个幻觉：单线程程序是按照程序的顺序来执行的。as-if-serial语义使单线程程序员无需担心重排序会干扰他们，也无需担心内存可见性问题。

# 5 程序顺序规则

根据happens-before的程序顺序规则，上面计算圆的面积的示例代码存在3个happens-before关系

1. A happens-before B
1. B happens-before C
1. A happens-before C
* 这里第3个happens-before关系时根据happens-before的传递性推导出来的

这里A happens-before B，但实际执行时B却可以排在A之前执行

* JMM仅仅要求前一个操作(执行的结果)对后一个操作可见，且前一个操作按顺序排在第二个操作之前
* 这里A操作的执行结果不需要对B操作可见；而且重排序操作A和操作B后的执行结果，与操作A和操作B按happens-before顺序执行的结果一致。在这种情况下，JMM会认为这种重排序并不非法，JMM允许这种重排序

在计算机中，软件技术和硬件技术有一个共同的目标：在不改变程序执行结果的前提下，尽可能提高并行速度。编译器和处理器遵从这一目标，从happens-before的定义我们可以看出，JMM同样遵从这一目标

# 6 重排序对多线程的影响

现在来看看，重排序是否会改变多线程程序的执行结果，请看下面的示例程序

```Java
class ReorderExample {
    int a = 0;

    boolean flag = false;

    public void writer() {
        a = 1;              // 1
        flag = true;        // 2
    }

    public void reader() {
        if (flag) {         // 3
            int i = a * a;  // 4
            ...
        }
    }
}
```

* flag变量是个标记，用来标识变量a是否已经被写入

这里假设有两个线程A和B，A__首先__执行writer()方法，随后B线程接着执行reader()方法。那么线程B在执行操作4时，能否看到线程A在操作1时对变量的写入呢？

* 不一定能看到，由于操作1和操作2之间没有数据依赖关系，编译器和处理器可以对这两个操作重排序；同时操作3和操作4没有数据依赖关系(注意，这里指的是数据的依赖关系，即`flag`与`a`变量的读取没有关系，而不是指`if (flag) {         //3`与`int i = a * a;  //4`没有关系)，编译器和处理器也可以对这两个操作进行重排序

当操作1和操作2重排序时，可能产生如下的执行时序

```sequence
Note over 线程A:flag = true;
Note over 线程B:if (flag)
Note over 线程B:int i = a * a;
Note over 线程A:a = 1;
```

* 操作1和操作2做了重排序
* 线程A首先写标记变量flag，随后线程B读取这个变量。由于条件判断为真，线程B将读取变量a。此时变量a还没有被线程A写入，在这里多线程程序的语义被重排序破坏了

当操作3和操作4重排序时(借助这个重排序，顺便说明控制依赖性)，可能产生如下的执行时序

```sequence
Note over 线程B:temp = a * a;
Note over 线程A:a = 1;
Note over 线程A:flag = true;
Note over 线程B:if (flag)
Note over 线程B:int i = temp;
```

* 在程序中，操作3和操作4存在__控制依赖关系__，当代码中存在控制依赖性时，会影响指令序列执行的并行度。为此，编译器和处理器会采用猜测(speculation)执行来克服控制相关性对并行度的影响。以处理器的猜测执行为例，执行线程B的处理器可以提前读取并计算a * a，然后把计算结果临时保存到一个名为重排序缓冲(Recorder Buffer, ROB)的硬件缓存中。当操作3的条件判断为真时，就把该计算结果写入变量i中
* 在上述程序中，猜测执行实质上对操作3和4做了重排序。重排序在这里破坏了多线程的语义

在单线程程序中，对存在控制依赖的操作重排序，不会改变执行结果(这也是as-if-serial语义允许对存在控制依赖的操作做重排序的原因)；但在多线程程序中，对存在控制依赖的操作重排序，可能会改变程序的执行结果

# 7 参考

* Java并发编程的艺术

 <!--以下这句不加，sequence不能识别，呵呵了-->
```flow
```
