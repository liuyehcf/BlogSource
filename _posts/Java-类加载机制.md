---
title: Java-类加载机制
date: 2017-07-02 23:00:31
tags: 
- 摘录
categories: 
- Java
- Java Virtual Machine
- ClassLoader
---

**阅读更多**

<!--more-->

# 1 概述

虚拟机把描述类的数据从Class文件加载到内存，并对数据进行校验、转换解析和初始化、最终形成可以被虚拟机直接使用的Java类型，这就是虚拟机类加载机制

与那些在编译时需要进行连接工作的语言不同，在Java语言里，类型的加载、连接和初始化过程都是在程序运行期完成的

* 这种策略虽然会令类加载时稍微增加一些性能开销，但是会为Java应用提供高度的灵活性
* Java里天生可以动态扩展的语言特性就是依赖运行期动态加载和动态连接这个特点实现的
    * 例如，如果编写一个面向接口的应用程序，可以等到运行时再指定其实际的实现类
    * 用户可以通过Java预定义的和自定义类加载器，让一个本地的应用程序可以在运行时从网络或其他地方加载一个二进制流作为程序代码的一部分
    * 这种组装应用程序的方式目前已广泛应用于Java程序之中

**本篇博客描述的两个约定**

* 每个Class文件都有可能代表着Java语言中的一个类或接口
* 提到的Class文件并非某个存在于具体磁盘中的文件，而是指一串二进制的字节流

# 2 类加载时机

**类从被加载到虚拟机内存中开始，到卸载出内存为止，整个生命周期包括：**

* 加载(Loading)
* 验证(Verification)
* 准备(Preparation)
* 解析(Resolution)
* 初始化(Initialization)
* 使用(Using)和卸载(Unloading)
* 其中验证、准备、解析部分统称为连接(Linking)

**加载、验证、准备、初始化和卸载这5个阶段的顺序是确定的，类的加载过程必须按照这种顺序按部就班地开始，而解析阶段则不一定**

* 解析在某些情况下可以在初始化阶段之后在开始，这是为了支持Java语言的运行时绑定(动态绑定)
* 注意：按部就班指的是按部就班地开始，而非按部就班地进行或完成，因为这些阶段通常都是互相交叉地混合式进行的，通常会在一个阶段执行过程中调用、激活另外一个阶段

**对于加载阶段**

* 虚拟机规范中并没有强制约束，这点可以交由虚拟机的具体实现来自由把握

**对于初始化阶段，虚拟机规范严格规定了有且仅有5种情况必须立即对类进行"初始化"(加载、验证、准备自然需要在此之前开始)**

* 遇到new、getstatic、putstatic或invokestatic这四条字节码指令时，如果类没有进行过初始化，则需要先触发其初始化(使用new关键字实例化对象的时候，读取或设置一个类的静态字段时(被final修饰，已在编译期把结果放入常量池的静态字段除外)，以及调用一个类的静态方法的时候)
* 使用java.lang.reflect包的方法对类进行反射调用的时候，如果类没有进行过初始化，则需要先触发其初始化
* 当初始化一个类的时候，如果发现其父类还没有进行过初始化，则需要先触发其父类的初始化
* 当虚拟机启动时，用户需要指定一个要执行的主类(包含main()方法的类，虚拟机会先初始化这个主类)
* 当使用JDK 1.7的动态语言支持时，如果一个java.lang.invoke.MethodHandle实例最后解析结果REF_getStatic、REF_putStatic、REF_invokeStatic的方法句柄，并且这个方法句柄所对应的类没有进行初始化，则需要先触发初始化

**对于静态字段**

* 只有直接定义这个字段的类才会被初始化，因此通过其子类来引用父类中定义的静态字段，只会触发父类的初始化而不会触发子类的初始化

**接口的加载过程与类加载过程稍微有些不同**

* 接口也有初始化过程，这点与类一致
* 接口中不能有static{}语句块
* 编译器仍然会为接口生成&lt;clinit&gt;类构造器
* **与类初始化的区别**：
    * 当一个类在初始化时，要求其父类全部都已经初始化过
    * 当一个接口在初始化时，并不要求其父接口全部都完成了初始化，只有在真正使用到父接口的时候(如引用接口中定义的常量)才会初始化

**神奇的例子**

```java
class ConstClass{
    static{System.out.println("ConstClass.init!");}
    public static final String HELLOWORLD="Hello world";
}
public class NotInitialization{
    public static void main(String[] args){
        System.out.println(ConstClass.HELLOWORLD);
    }
}
```

* 结果不会输出"ConstClass init!"，因为虽然在Java源码中引用了ConstClass类中的常量，但是在编译阶段通过常量传播优化，已经将常量的值存储到了NotInitialization类的常量池中，即这两个类在编译成Class之后就不存在任何联系了

# 3 类加载过程

## 3.1 加载

**"加载"是"类加载"过程的一个阶段，在该阶段，虚拟机需要完成以下3件事**

1. 通过一个类的全限定名来获取此类的二进制字节流
2. 将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构
3. 在内存中生成一个代表这个类的java.lang.Class对象，作为方法区这个类的各种数据的访问入口

**虚拟机规范的这三点要求不算具体，并没有指明从哪里获取、怎样获取**

* 从ZIP包中读取，这很常见，最终成为日后的JAR、EAR、WAR格式的基础
* 从网络中获取，这种场景典型的应用就是Applet
* 运行时计算生成，这种场景使用得最多的就是动态代理技术，在java.lang.reflect.Proxy中，就是用了ProxyGenerator.generateProxyClass来为特定接口生成形式为"*$Proxy"的代理类的二进制字节流
* 由其他文件生成，典型场景是JSP应用，即由JSP文件生成对应的Class类
* 从数据库中读取，这种场景相对少些，例如有些中间件服务器(SAP Netweaver)可以选择把程序安装到数据库中来完成程序代码在集群间的分发

**相对于类加载过程的其他阶段**

* 一个非数组类的加载阶段(准确的说，是加载阶段中获取二进制字节流的动作)是开发人员可控性最强的
    * 因为加载阶段既可以使用系统提供的引导类加载器来完成
    * 也可以由用户自定义的类加载器去完成，开发人员可以通过定义自己的类加载器去控制字节流的获取方式(重写一个类加载器的loadClass()方法)
* **对于数组类而言**
    * 数组类本身不通过类加载器创建，它是由Java虚拟机直接创建的，但数组类与类加载器仍然有很密切的关系
    * 因为数组类的&lt;元素类型&gt;(Element Type，指的是数组去掉所有维度的类型)最终是要靠类加载器去创建
    * 一个数组类(下面简称C)创建过程遵循以下原则
    * 如果数组类的&lt;组件类型&gt;(Component Type，指的是数组去掉第一个维度的类型)是引用类型，那就递归采用本节中定义的加载过程去加载这个组件类型，数组C将在加载该组件的类加载器的类名称空间上被标识(一个类必须与类加载器一起确定唯一性)
    * 如果数组的组件不是引用类型，例如int[]，Java虚拟机会把数组C标记为与引导类加载器关联
    * 数组类的可见性与它的组件类型的可见一致性，如果组件类型不是引用类型，那数组类的可见性将默认为public

加载阶段完成后

* 虚拟机外部的二进制字节流就按照虚拟机所需的格式存储在方法区之中，方法区中的数据存储格式由虚拟机实现自行定义，虚拟机规范未规定此区域的具体数据结构
* 然后在内存中实例化一个java.lang.Class类的对象(并没有明确规定是在Java堆中，对于HotSpot虚拟机而言，Class对象比较特殊，它虽然是对象，但是存放在方法区)，这个Class对象将作为程序访问方法区中的这些类型数据的外部接口

加载阶段与连接阶段的部分内容是交叉进行的，加载阶段尚未完成，连接阶段可能已经开始，但这些夹在加载阶段之中进行的动作，仍然属于连接阶段的内容，这两个阶段的开始时间仍然保持着固定的先后顺序

## 3.2 验证

验证是连接阶段的第一步，**这一阶段的目的是：确保Class文件的字节流中包含的信息符合当前虚拟机的要求，并且不会危害虚拟机自身的安全**

Java语言本身是相对安全的语言(相对于C/C++来说)

* 使用纯粹的Java代码无法做到诸如访问数组边界以外的数据，将一个对象转型为它并未实现的类型，跳转到不存在的代码之类的事情，如果这样做了，编译器将拒绝编译
* Class文件并不一定要用Java源码编译而来，可以使用任何途径产生，甚至包括用16进制编辑器直接编写来产生Class文件，在字节码层面上，上述Java代码无法做到的事情都是可以实现的
* 如果虚拟机不检查输入的字节流，对其完全信任的话，很可能会因载入了有害的字节流而导致系统崩溃，所以验证是虚拟机对自身保护的一项重要工作

**验证阶段大致会完成下面4个动作**

1. **文件格式验证：验证字节流是否符合Class文件格式的规范，并且能被当前版本的虚拟机处理**
    * 是否以魔数0xCAFEBABE开头
    * 主次版本号是否在当前虚拟机的处理范围之内
    * 常量池中的常量是否有不被支持的常量类型(检查常量tag标志)
    * 指向常量的各种索引值中是否有指向不存在的常量或不符合类型的常量
    * CONSTANT_Utf8_info型的长两种是否有不符合UTF8编码的数据
    * Class文件中各个部分及文件本身是否有被删除的或附加的其他信息
    * ......
    * 这个阶段的主要目的是保证输入的字节流能正确地解析并且存储于方法区之内，格式上符合描述一个Java类型信息的要求
    * 只有通过这个阶段的验证之后，字节流才会进入内存的方法区中进行存储
1. **元数据验证：对字节码描述的信息进行语义分析，以保证其描述的信息符合Java语言规范的要求**
    * 这个类是否有父类(除了Object之外，任何类都有父类)
    * 这个类的父类是否继承了不允许被继承的类(被final修饰的类)
    * 如果这个类不是抽象类，是否实现了其父类或接口中要求实现的所有方法
    * 类中的字段、方法、是否与父类产生矛盾
    * ......
    * 这个阶段的主要目的是对类的元数据信息进行语义校验，保证不存在不符合Java语言规范的元数据信息
1. **字节码验证：通过数据流和控制流分析，确定程序语义是合法的，符合逻辑的，保证被校验类的方法在运行时不会做出危害虚拟机安全的事件**
    * 保证任意时刻操作数栈的数据类型与指令代码序列都能配合工作，例如不会出现类似这样的情况：在操作栈放置了一个int类型的数据，使用时却按long类型来加载如本地变量表中
    * 保证跳转指令不会跳转到方法体以外的字节码指令上
    * 保证方法体中的类型转换是有效的
    * ......
    * 如果一个类方法体的字节码没有通过字节码验证，那肯定是有问题的，但通过了字节码验证也未必是安全的，即便做了大量的检查，也无法保证"通过程序去校验程序逻辑无法做到绝对准确--不能通过程序准确地检查出程序是否能在有限时间之内结束运行"
    * 虚拟机设计团队为了避免过多的时间消耗在字节码验证阶段，在JDK 1.6之后的Javac编译器和Java虚拟机中进行了一项优化，给方法体的Code属性表中增加了一项"StackMapTable"属性，该属性描述了方法体中所有基本块(Basic Block，按照控制流拆分的代码块)开始时本地变量表和操作栈应有的状态，在字节码验证期间，就不需要根据程序推导这些状态的合理性，只需要检查StackMapTable属性中的记录是否合法即可
    * 但理论上StackMapTable属性也存在错误或者被篡改的可能
1. **符号引用验证：对类自身以外(常量池中的各种符号引用)的信息进行匹配性校验**
    * 符号引用中通过字符串描述的全限定名是否能找到对应的类
    * 在指定类中是否存在符合方法的字段描述符以及简单名称所描述的方法和字段
    * 符号引用中的类、字段、方法的访问性是否可被当前类访问
    * 符号引用验证的目的是：确保解析动作能正常执行，如果无法通过符号引用验证，将会抛出java.lang.IncompatibleClassChangeError异常的子类
    * 对于虚拟机类加载机制来说，验证阶段是非常重要的，但不是一定必要的阶段，如果所运行的全部代码已经被反复使用和验证过，在实施阶段就可以考虑用-Xverfy:none来关闭大部分的类验证措施，以缩短虚拟机类加载的时间

## 3.3 准备

**准备阶段：正式为类变量分配内存并设置类变量初始值的阶段，这些变量所使用的内存都将在方法区中进行分配**

**概念明确**

* 这时候进行内存分配的仅包括类变量(被static修饰的变量)，而不包括实例变量，实例变量将会在对象实例化时随着对象一起分配在Java堆中
* 这里提到的初始值，通常情况下是零值
    * 假设定义一个类变量
    * public static int value=123
    * 变量value在准备阶段后的初始值为0而不是123，因为这时候尚未开始执行任何Java方法，而把value赋值为123的putstatic指令是程序被编译后，存放于类构造器&lt;clinit&gt;()方法之中，所以把value赋值为123的动作将在初始化阶段才会开始

**基本数据类型的零值**

| 数据类型 | 零值 | 
|:---|:---|
| int | 0 | 
| long | 0L |
| short | (short)0 | 
| char | '\u0000' | 
| byte | (byte)0 | 
| boolean | false | 
| float | 0.0f | 
| double | 0.0d | 
| reference | null | 

## 3.4 解析

**解析阶段是虚拟机将常量池内的符号引用替换为直接引用的过程**

1. **符号引用(Symbolic References)：**
    * 符号引用以一组符号来描述所引用的目标，符号可以是任何形式的字面量，只要使用时无歧义地定位到目标即可
    * 符号引用与虚拟机实现的内存布局无关，引用的目标不一定已经加载到内存中
    * 各种虚拟机实现的内存布局可以各不相同，但是它们能接受的符号引用必须一致，因为符号引用的字面量形式明确定义在Java虚拟机规范的Class文件格式中
1. **直接引用(Direct References)：**
    * 直接引用可以是指向目标的指针、相对偏移量或是一个能间接定位到目标的句柄
    * 直接引用是和虚拟机实现的内存布局相关的
    * 同一个符号引用在不同虚拟机实例上翻译出来的直接引用一般不会相同
    * 如果有了直接引用，那引用的目标必定已经存在内存中

**虚拟机规范中并未规定解析阶段发生的具体时间，只要求了在执行anewarray、checkcast、getfield、getstatic、instanceof、invokedynamic、invokeinterface、invokespecial、invokestatic、invokevertual、ldc、ldc_w、multianewarray、new、putfield、putstatic这16个用于操作符号引用的字节码指令之前，先对它们所使用的符号引用进行解析**

* 因此，虚拟机实现可以根据需要来判断到底是在类被加载器加载时就对常量池中的符号引用进行解析还是等到一个符号引用将要被使用前才去解析它

**对同一个符号引用进行多次解析请求是很常见的事情，除invokedynamic外**

* 虚拟机实现可以对第一次解析的结果进行缓存(在运行时常量池中记录直接引用，并把常量标识为解析状态)从而避免解析动作重复进行
* 无论是否真正执行了多次解析动作，虚拟机需要保证的是在同一个实体中
* 如果一个符号引用之前已经被成功解析过，那么后续的引用请求就已应当一直成功，否则将会收到相同的异常

**对于invokedynamic指令**

* 当碰到某个前面已经由invokedynamic指令触发过解析的符号引用时，并不意味着这个解析结果对于其他invokedynamic指令也同样生效
* 动态的含义：必须等到程序实际运行到这条指令时，解析动作才能进行
* 静态的含义：可以在刚刚完成加载阶段，还没有开始执行代码时就进行解析

**解析动作针对的对象**

* 类或接口(CONSTANT_Class_info)
* 字段(CONSTANT_Fieldref_info)
* 类方法(CONSTANT_Methodref_info)
* 接口方法(CONSTANT_InterfaceMethodref_info)
* 方法类型(CONSTANT_MethodType_info)
* 方法句柄(CONSTANT_MethodHandle_info)
* 调用点限定符(CONSTANT_InvokeDynamic_info)

### 3.4.1 类或接口的解析

**如果当前代码所处的类为D，如果要把一个从未解析过的符号引用N解析为一个类或接口C的直接引用，那么虚拟机需要完成以下3个步骤**

1. 如果C不是一个数组类型
    * 那虚拟机将会把代表N的全限定名传给D的类加载器去加载这个类C
    * 在加载过程中，由于元数据验证、字节码验证的需要，有可能触发其他相关类的加载动作，例如加载这个类的父类或实现的接口
    * 一旦这个加载过程出现任何异常，解析过程宣告失败
1. 如果C是一个数组类型，并且数组的元素类型为对象，也就是N的描述符是类似"[Ljava/lang/Integer]"的形式
    * 那将会按照第一点的规则加载数组元素类型
    * 接着由虚拟机生成一个代表此数组维度和元素的数组对象
1. 如果上面的步骤没有任何异常，那么C在虚拟机中实际上已经成为一个有效的类或接口了，但在解析完成之前还要进行符号引用验证，确认D是否具备对C的访问权限，若不具备，则抛出java.lang.IllegalAccessError异常

### 3.4.2 字段解析

**要解析一个未被解析过的字段符号引用，首先将会对字段表内class_index项中索引的CONSTANT_Class_info符号引用进行解析，即字段所属类或接口的符号引用，要是在这个过程中出现了异常，都会导致字段符号引用解析的失败，如果解析成功完成，将这个字段所属的类或接口用C表示，接下来虚拟机按照以下步骤对C进行后续字段的搜索**

* 如果C本身包含了简单名称和字段描述符都与目标相匹配的字段，则返回这个字段的直接引用，查找结束
* 否则，如果在C中实现了接口，将会按照继承关系从下往上递归搜索各个接口和它的父接口，如果接口中包含了简单名称和字段描述符都与目标相匹配的字段，则返回这个字段的直接引用，查找结束
* 否则，如果C不是java.lang.Object的话，将会按照继承关系从下往上递归搜索其父类，如果在父类中包含了简单名称和字段描述符都与目标相匹配的字段，则返回这个字段的直接引用，查找结束
* 否则，查找失败，抛出java.lang.NoSuchFiledError异常
* 如果查找过程成功返回了引用，将会对这个字段进行权限验证，如果发现不具备对字段的访问权限，将抛出java.lang.IllegalAccessError

### 3.4.3 类方法解析

**类方法解析的第一个步骤与字段解析一样，也需要先解析出类方法表的class_index项中的方法所属的类或接口的符号引用，如果解析成功，用C来表示这个类，接下来虚拟机会按照如下步骤进行后续类方法搜索**

* 类方法和接口方法符号引用的常量类型定义是分开的，如果类方法表中发现class_index中索引的C是个接口，就直接抛出java.lang.IncompatibleClassChangeError异常
* 否则，在C中查找是否有简单名称和描述符都与目标相匹配的方法，如果有则返回这个方法的直接引用，查找结束
* 否则，在C的父类中递归查找是否有简单名称和描述符都与目标相匹配的方法，如果有则返回这个方法的直接引用，查找结束
* 否则，在类C实现的接口列表及他们的父接口中递归查找是否有简单名称和描述符都与目标相匹配的方法，如果存在匹配的方法，说明C是一个抽象类，这时候查找结束，抛出java.lang.AbstractMethodError异常
* 否则宣告方法查找失败，抛出java.lang.NoSuchMethodError
* 最后，如果查找过程成功返回了直接引用，将会对这个方法进行权限验证，如果发现不具备对此方法的访问权限，将抛出java.lang.IllegalAccessError异常

### 3.4.4 接口方法解析

**接口方法也需要先解析出接口方法表的class_index项中索引的方法所属的类或接口的符号引用，如果解析成功，依然用C表示这个接口，接下来虚拟机会按以下步骤进行后续接口方法搜索**

* 与类方法解析不同，如果在接口方法表中发现class_index中索引C是个类而不是接口，那就直接抛出java.lang.IncompatibleClassChangeError异常
* 否则，在接口C中查找是否有简单名称和描述符都与目标相匹配的方法，如果有，则返回这个方法的直接引用，查找结束
* 否则，在接口C的父接口中递归查找，知道java.lang.Object类，看是否有简单名称和描述符都与目标相匹配的方法，如果有则返回这个方法的直接引用，查找结束
* 否则，宣告方法查找失败，抛出java.lang.NoSuchMethodError异常
* 由于接口中的所有方法默认都是public的，所以不存在访问权限的问题，因此接口方法的符号解析应当不会抛出java.lang.IllegalAccessError

## 3.5 初始化

类初始化阶段是类加载过程的最后一步，前面的类加载过程中，除了在加载阶段用户应用程序可以通过自定义类加载器参与之外，其余动作完全由虚拟机主导和控制，到了初始化阶段，才真正开始执行类中定义的Java代码(或者说字节码)

**在准备阶段，变量已经赋值过一次系统要求的初始值，而在初始化阶段，则根据程序员通过程序制定的主观计划去初始化类变量和其他资源，或者可以从另外一个角度来表达：初始化阶段是执行类构造器&lt;clinit&gt;()方法的过程**

* &lt;clinit&gt;()方法是由编译器自动收集类中所有变量的赋值动作和静态语句块(static{})中的语句合并产生的
    * 编译器收集的顺序是由语句在源文件中出现的顺序决定的
    * 静态语句块中只能访问到定义在静态语句块之前的变量
    * 定义在它之后的变量，在前面的静态语句块可以赋值，但是不能访问
* &lt;clinit&gt;()方法与类的构造器(或者说实例构造器&lt;init&gt;())不同
    * 它不需要显式地调用父类构造器
    * 虚拟机会保证在子类的&lt;clinit&gt;()方法执行之前，父类的&lt;clinit&gt;()方法已经执行完毕
    * 因此在虚拟机中第一个被执行的&lt;clinit&gt;()方法肯定是java.lang.Object
* 由于父类的&lt;clinit&gt;()方法先执行，意味着父类中定义的静态语句块要优先于子类的变量赋值操作
    * &lt;clinit&gt;()方法对于类或接口来说并不是必须的，如果一个类中没有静态语句块，也就没有对变量的赋值操作，那么编译器可以不为这个类生成&lt;clinit&gt;()方法

# 4 类加载器

虚拟机设计团队把类加载阶段中"通过一个类的全限定名来获取描述此类的二进制字节流"这个动作放到Java虚拟机外部去实现，以便让应用程序自己决定如何去获取所需要的类，实现这个动作的代码模块称为"类加载器"

**类加载器是Java语言的一项创新，也是Java流行的重要原因之一**

* 类加载器最初是为了满足Java Applet的需求而开发的
* 虽然目前Java Applet技术基本上已经死掉，但是类加载器却在类层次划分、OSGi、热部署、代码加密等领域大放异彩

## 4.1 类与类加载器

**类加载器虽然只用于实现类的加载动作，但它在Java程序中起到的作用却远远不限于类加载阶段**

* **对于任意一个类，都需要由加载它的类加载器和这个类本身一同确立其在Java虚拟机中的唯一性**
* 每一个类加载器都拥有一个独立的类名称空间，通俗地说"比较两个类是否相等，只有在这两个类是由同一个类加载器加载的前提下才有意义，否则即使这两个类来源于同一个Class文件，被同一个虚拟机加载，只要加载它们的类加载器不同，那么这两个类就必定不等"
* 注意，上面提到的相等，包括代表类的Class对象的equals()方法、isAssignableFrom()方法、isInstance()方法的返回结果，也包括使用instanceof关键字做对象所属关系判定等情况

## 4.2 双亲委派模型

**从Java虚拟机的角度来讲，只存在两种不同的类加载器**

* 一种是启动类加载器(Bootstrap ClassLoader)，这个类加载器使用C++语言实现，是虚拟机自身的一部分
* 另外一种就是所有其他的类加载器，这些类加载器由Java语言实现，独立于虚拟机外部，并且全都继承自抽象类java.lang.ClassLoader

从Java开发人员的角度来看，类加载器还可以划分的更细致一些，绝大部分程序都会使用到以下3种系统提供的类加载器

* **启动类加载器(Bootstrap ClassLoader)**
    * 负责将存放在&lt;JAVA_HOME&gt;\lib目录中的，或者被-Xbootclasspath参数所指定的路径中的，并且是虚拟机识别的(仅按文件名识别，例如rt.jar，即名字不符合的类库即使放在lib目录中也不会被加载)类库加载到虚拟机内存中
    * 启动类加载器无法被Java程序直接引用，用户在编写自定义类加载器时，如果需要把加载请求委派给引导类加载器，那直接使用null代替即可
* **扩展类加载器(Extension ClassLoader)**
    * 这个加载器由sun.misc.Launcher$ExtClassLoader实现，它负责加载&lt;JAVA_HOME&gt;\lib\ext目录中的，或者被java.ext.dirs系统变量所指定的路径中的所有类库
    * 开发者可以直接使用扩展类加载器
* **应用程序类加载器(Application ClassLoader)**
    * 这个类加载器由sun.misc.Launcher$AppClassLoader实现
    * 由于这个类加载器是ClassLoader中的getSystemClassLoader()方法的返回值，所以一般也称它为系统类加载器

![](/images/Java-类加载机制/类加载器.gif)

**类加载器之间的层次关系成为类加载器的双亲委派模型(parents Delegation Model)**

* 双亲委派模型要求除了顶层的启动类加载器外，其余的类加载器都应当有自己的父类加载器
* 这里类加载器之间的父子关系一般不会以继承(Inheritance)的关系来实现，而都是使用组合(Composition)关系来复用父加载器的代码
 
![](/images/Java-类加载机制/双亲委派模型.png)

**双亲委派模型的工作过程**

* 如果一个类加载器收到了加载请求，它首先不会自己去尝试加载这个类，而是把这个请求为派给父类加载器去完成，每一个层次的类加载器都是如此
* 因此所有的加载请求最终都应该传送到顶层的启动类加载器当中，只有父类加载器反馈自己无法完成这个加载请求(它的搜索范围中没有找到所需的类)时，子加载器才会尝试自己去加载

**双亲委派模型组织类加载器之间的关系的好处：Java类随着它的类加载器一起具备了一种带有优先级的层次关系，防止内存中出现多份同样的字节码**

* 例如java.lang.Object，它存放在rt.jar中，无论哪一个类加载器要加载这个类，最终都是会委派给处于模型最顶端的启动类加载器进行加载，因此Object类在程序的各种类加载器环境中都是同一个类

# 5 参考

* 《深入理解Java虚拟机》
