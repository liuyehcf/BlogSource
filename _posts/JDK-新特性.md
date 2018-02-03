---
title: JDK-新特性
date: 2017-07-27 23:16:06
tags: 
- 摘录
categories: 
- Java
- Grammar
---

__目录__

<!-- toc -->
<!--more-->

# 1 JDK 5

## 1.1 自动装箱与拆箱

自动装箱的过程：每当需要一种类型的对象时，这种基本类型就自动地封装到与它相同类型的包装中

自动拆箱的过程：每当需要一个值时，被装箱对象中的值就被自动地提取出来，没必要再去调用intValue()和doubleValue()方法

自动装箱，只需将该值赋给一个类型包装器引用，java会自动创建一个对象

自动拆箱，只需将该对象值赋给一个基本类型即可

类型包装器有：Double,Float,Long,Integer,Short,Character和Boolean

## 1.2 枚举

把集合里的对象元素一个一个提取出来。枚举类型使代码更具可读性，理解清晰，易于维护。枚举类型是强类型的，从而保证了系统安全性。而以类的静态字段实现的类似替代模型，不具有枚举的简单性和类型安全性
简单的用法：JavaEnum简单的用法一般用于代表一组常用常量，可用来代表一类相同类型的常量值
复杂用法：Java为枚举类型提供了一些内置的方法，同事枚举常量还可以有自己的方法。可以很方便的遍历枚举对象

## 1.3 静态导入

通过使用`import static`，就可以不用指定Constants类名而直接使用静态成员，包括静态方法
`import xxxx`和`import static xxxx`的区别是前者一般导入的是类文件，例如`import java.util.Scanner;`；后者一般是导入静态的方法，例如`import static java.lang.System.out;`

## 1.4 可变参数

可变参数的简单语法格式为：`methodName([argumentList], dataType...argumentName);`

## 1.5 内省

是 Java语言对Bean类属性、事件的一种缺省处理方法。例如类A中有属性`name`,那我们可以通过`getName,setName`来得到其值或者设置新的值。通过`getName/setName`来访问`name`属性，这就是默认的规则。Java中提供了一套API用来访问某个属性的`getter/setter`方法，通过这些API可以使你不需要了解这个规则（但你最好还是要搞清楚），这些API存放于包java.beans中
一般的做法是通过类Introspector来获取某个对象的BeanInfo信息，然后通过BeanInfo来获取属性的描述器 （PropertyDescriptor），通过这个属性描述器就可以获取某个属性对应的`getter/setter`方法，然后我们就可以通过反射机制来调用这些方法

## 1.6 泛型

C++通过模板技术可以指定集合的元素类型，而Java在1.5之前一直没有相对应的功能。一个集合可以放任何类型的对象，相应地从集合里面拿对象的时候我们也不得不对他们进行强制得类型转换。猛虎引入了泛型，它允许指定集合里元素的类型，这样你可以得到强类型在编译时刻进行类型检查的好处

## 1.7 For-Each循环

For-Each循环得加入简化了集合的遍历。假设我们要遍历一个集合对其中的元素进行一些处理

# 2 JDK 6

## 2.1 Desktop类和SystemTray类

前者可以用来打开系统默认浏览器浏览指定的URL，打开系统默认邮件客户端给指定的邮箱发邮件，用默认应用程序打开或编辑文件(比如，用记事本打开以txt为后缀名的文件)，用系统默认的打印机打印文档；后者可以用来在系统托盘区创建一个托盘程序

## 2.2 使用JAXB2来实现对象与XML之间的映射

JAXB是Java Architecture for XML Binding的缩写，可以将一个Java对象转变成为XML格式，反之亦然

我们把对象与关系数据库之间的映射称为ORM，其实也可以把对象与XML之间的映射称为OXM(Object XML Mapping)。原来JAXB是Java EE的一部分，在JDK1.6中，SUN将其放到了Java SE中，这也是SUN的一贯做法。JDK1.6中自带的这个JAXB版本是2.0，比起1.0(JSR 31)来，JAXB2(JSR 222)用JDK5的新特性Annotation来标识要作绑定的类和属性等，这就极大简化了开发的工作量。实际上，在Java EE 5.0中，EJB和Web Services也通过Annotation来简化开发工作。另外，JAXB2在底层是用StAX(JSR 173)来处理XML文档。除了JAXB之外，我们还可以通过XMLBeans和Castor等来实现同样的功能

## 2.3 理解StAX

StAX(JSR 173)是JDK1.6.0中除了DOM和SAX之外的又一种处理XML文档的API

StAX 的来历：在JAXP1.3(JSR 206)有两种处理XML文档的方法：DOM(Document Object Model)和SAX(Simple API for XML)

由于JDK1.6.0中的JAXB2(JSR 222)和JAX-WS 2.0(JSR 224)都会用到StAX所以Sun决定把StAX加入到JAXP家族当中来，并将JAXP的版本升级到1.4(JAXP1.4是JAXP1.3的维护版本)

JDK1.6里面JAXP的版本就是1.4。StAX是The Streaming API for XML的缩写，一种利用拉模式解析(pull-parsing)XML文档的API.StAX通过提供一种基于事件迭代器(Iterator)的API让程序员去控制xml文档解析过程，程序遍历这个事件迭代器去处理每一个解析事件，解析事件可以看做是程序拉出来的，也就是程序促使解析器产生一个解析事件然后处理该事件，之后又促使解析器产生下一个解析事件，如此循环直到碰到文档结束符；SAX也是基于事件处理xml文档，但却是用推模式解析，解析器解析完整个xml文档后，才产生解析事件，然后推给程序去处理这些事件；DOM采用的方式是将整个xml文档映射到一颗内存树，这样就可以很容易地得到父节点和子结点以及兄弟节点的数据，但如果文档很大，将会严重影响性能

## 2.4 使用Compiler API

现在我们可以用JDK1.6 的Compiler API(JSR 199)去动态编译Java源文件，Compiler API结合反射功能就可以实现动态的产生Java代码并编译执行这些代码，有点动态语言的特征

这个特性对于某些需要用到动态编译的应用程序相当有用，比如JSP Web Server，当我们手动修改JSP后，是不希望需要重启Web Server才可以看到效果的，这时候我们就可以用Compiler API来实现动态编译JSP文件，当然，现在的JSP Web Server也是支持JSP热部署的，现在的JSP Web Server通过在运行期间通过Runtime.exec或ProcessBuilder来调用javac来编译代码，这种方式需要我们产生另一个进程去做编译工作，不够优雅而且容易使代码依赖与特定的操作系统；Compiler API通过一套易用的标准的API提供了更加丰富的方式去做动态编译，而且是跨平台的

## 2.5 轻量级Http Server API

JDK1.6 提供了一个简单的Http Server API，据此我们可以构建自己的嵌入式Http Server，它支持Http和Https协议，提供了HTTP1.1的部分实现，没有被实现的那部分可以通过扩展已有的Http Server API来实现，程序员必须自己实现HttpHandler接口，HttpServer会调用HttpHandler实现类的回调方法来处理客户端请求，在这里，我们把一个Http请求和它的响应称为一个交换，包装成HttpExchange类，HttpServer负责将HttpExchange传给HttpHandler实现类的回调方法

## 2.6 插入式注解处理API(Pluggable Annotation Processing API)

插入式注解处理API(JSR 269)提供一套标准API来处理Annotations(JSR 175)。实际上JSR 269不仅仅用来处理Annotation，我觉得更强大的功能是它建立了Java语言本身的一个模型，它把method，package，constructor，type，variable，enum，annotation等Java语言元素映射为Types和Elements(两者有什么区别?)，从而将Java语言的语义映射成为对象，我们可以在javax.lang.model包下面可以看到这些类。所以我们可以利用JSR 269提供的API来构建一个功能丰富的元编程(metaprogramming)环境。JSR 269用Annotation Processor在编译期间而不是运行期间处理Annotation，Annotation Processor相当于编译器的一个插件，所以称为插入式注解处理。如果Annotation Processor处理Annotation时(执行process方法)产生了新的Java代码，编译器会再调用一次Annotation Processor，如果第二次处理还有新代码产生，就会接着调用Annotation Processor，直到没有新代码产生为止.每执行一次process()方法被称为一个"round"，这样整个Annotation processing过程可以看作是一个round的序列

JSR 269主要被设计成为针对Tools或者容器的API. 举个例子，我们想建立一套基于Annotation的单元测试框架(如TestNG)，在测试类里面用Annotation来标识测试期间需要执行的测试方法

## 2.7 用Console开发控制台程序

JDK1.6中提供了`java.io.Console`类专用来访问基于字符的控制台设备。你的程序如果要与Windows下的cmd或者Linux下的Terminal交互，就可以用Console类代劳。但我们不总是能得到可用的Console，一个JVM是否有可用的Console依赖于底层平台和JVM如何被调用。如果JVM是在交互式命令行(比如Windows的cmd)中启动的，并且输入输出没有重定向到另外的地方，那么就可以得到一个可用的Console实例

## 2.8 对脚本语言的支持

ruby，groovy，javascript

## 2.9 Common Annotations

Common annotations原本是Java EE 5.0(JSR 244)规范的一部分，现在SUN把它的一部分放到了Java SE 6.0中

随着Annotation元数据功能(JSR 175)加入到Java SE 5.0里面，很多Java技术(比如EJB，Web Services)都会用Annotation部分代替XML文件来配置运行参数（或者说是支持声明式编程，如EJB的声明式事务），如果这些技术为通用目的都单独定义了自己的otations，显然有点重复建设，所以，为其他相关的Java技术定义一套公共的Annotation是有价值的，可以避免重复建设的同时，也保证Java SE和Java EE各种技术的一致性

# 3 JDK 7

## 3.1 二进制面值

在java7里，整形(byte,short,int,long)类型的值可以用二进制类型来表示了，在使用二进制的值时，需要在前面加上ob或oB，例如：

* `int a =0b01111_00000_11111_00000_10101_01010_10;`
* `short b = (short)0b01100_00000_11111_0;`
* `byte c = (byte)0B0000_0001`;

## 3.2 数字变量对下滑线的支持

JDK1.7可以在数值类型的变量里添加下滑线

但是有几个地方是不能添加的

1. 数字的开头和结尾
1. 小数点前后
1. F或者L前

例如：

* `int num = 1234_5678_9;`
* `float num2 = 222_33F;`
* `long num3 = 123_000_111L;`

## 3.3 switch对String的支持

之前就一直有一个打问号？为什么C#可以Java却不行呢？哈，不过还有JDK1.7以后Java也可以了

例如：

```Java
        String status = "orderState";
        switch (status) {
            case "ordercancel":
                System.out.println("订单取消");
                break;
            case "orderSuccess":
                System.out.println("预订成功");
                break;
            default:
                System.out.println("状态未知");
        }
```

## 3.4 try-with-resource

try-with-resources是一个定义了一个或多个资源的try声明，这个资源是指程序处理完它之后需要关闭它的对象。try-with-resources确保每一个资源在处理完成后都会被关闭

可以使用try-with-resources的资源有：任何实现了java.lang.AutoCloseable接口java.io.Closeable接口的对象。例如：

```Java
    public static String readFirstLineFromFile(String path) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            return br.readLine();
        }
    }
```

在java 7以及以后的版本里，BufferedReader实现了java.lang.AutoCloseable接口。由于BufferedReader定义在try-with-resources声明里，无论try语句正常还是异常的结束，它都会自动的关掉。而在java7以前，你需要使用finally块来关掉这个对象

## 3.5 捕获多种异常并用改进后的类型检查来重新抛出异常

```Java
    public static void first() {
        try {
            BufferedReader reader = new BufferedReader(new FileReader(""));
            Connection con = null;
            Statement stmt = con.createStatement();
        } catch (IOException | SQLException e) {
            // 捕获多个异常，e就是final类型的   
            e.printStackTrace();
        }
    }
```

优点：用一个catch处理多个异常，比用多个catch每个处理一个异常生成的字节码要更小更高效。 

## 3.6 创建泛型时类型推断

只要编译器可以从上下文中推断出类型参数，你就可以用一对空着的尖括号<>来代替泛型参数。这对括号私下被称为菱形(diamond)。在Java SE 7之前，你声明泛型对象时要这样`List<String> list = new ArrayList<String>();`。而在Java SE7以后，你可以这样`List<String> list = new ArrayList<>();`

## 3.7 新增一些取环境信息的工具方法

```Java
        File System.getUserHomeDir() // 当前用户目录
        File System.getUserDir() // 启动java进程时所在的目录5
        File System.getJavaIoTempDir() // IO临时文件夹
        File System.getJavaHomeDir() // JRE的安装目录
```

## 3.8 安全的加减乘除

```Java
    int Math.safeToInt(long value)
    int Math.safeNegate(int value)
    long Math.safeSubtract(long value1, int value2)
    long Math.safeSubtract(long value1, long value2)
    int Math.safeMultiply(int value1, int value2)
    long Math.safeMultiply(long value1, int value2)
    long Math.safeMultiply(long value1, long value2)
    long Math.safeNegate(long value)
    int Math.safeAdd(int value1, int value2)
    long Math.safeAdd(long value1, int value2)
    long Math.safeAdd(long value1, long value2)
    int Math.safeSubtract(int value1, int value2)
```

## 3.9 fork/join

# 4 JDK 8

## 4.1 语言新特性

### 4.1.1 Lambdas表达式与Functional接口

### 4.1.2 接口的默认与静态方法

### 4.1.3 方法引用

### 4.1.4 重复注解

### 4.1.5 更好的类型推测机制

### 4.1.6 扩展注解的支持

## 4.2 编译器新特性

### 4.2.1 参数名字

## 4.3 类库新特性

### 4.3.1 Optional

### 4.3.2 Streams

### 4.3.3 Data/Time API

### 4.3.4 JavaScript引擎Nashorn

### 4.3.5 Base64

### 4.3.6 并行(parallel)数组

### 4.3.7 并发

## 4.4 新增Java工具

### 4.4.1 Nashorn引擎：jjs

### 4.4.2 类依赖分析器：jdeps

## 4.5 JVM新特性

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [JDK各个版本的新特性jdk1.5-jdk8](http://www.cnblogs.com/langtianya/p/3757993.html)
* [Java7的那些新特性](http://blog.csdn.net/chenleixing/article/details/47802653)
* [Java7的新特性一览表](http://www.oschina.net/news/20119/new-features-of-java-7)
* [Java8新特性终极指南](http://www.importnew.com/11908.html)
