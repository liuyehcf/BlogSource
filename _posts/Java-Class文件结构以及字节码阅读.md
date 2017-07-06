---
title: Java Class文件结构以及字节码阅读
date: 2017-07-02 22:58:50
tags:
categories:
- Java Virtual Machine
---

__目录__

<!-- toc -->
<!--more-->

# 1 Class文件结构简介

Class文件格式采用一种类似于C语言结构体的伪结构来存储数据。整个Class文件本质上就是一张表

* 这种伪结构中只有两类数据类型：__无符号数和表__，后面的解析都要以这两种数据类型为基础
* 无符号数属于基本的数据类型，以u1、u2、u4、u8来分别代表一个字节、2个字节、4个字节和8个字节的无符号数，无符号数可以用来描述数字、索引引用、数量值或者按照UTF-8编码构成字符串值
* 表是由多个无符号数或者其他表作为数据项构成的复合数据类型，所有表都习惯性地以"_info"结尾
* 无论是无符号数还是表，当需要描述同一类型但数量不定的多个数据时，经常会使用一个前置的容量计数器加若干个连续的数据项的形式，这时称这一系列连续的某一类型数据为某一类型的集合

## 1.1 Class文件内部结构如下表所示
| 类型         | 名称           | 数量  |
|:------------- |:--------------|:-------|
| u4 | magic(魔数) | 1 |
| u2 | minor_version(次版本号) | 1 |
| u2 | major_version(主版本号) | 1 |
| u2 | constant_pool_count(常量池计数器) | 1 |
| cp_info | constant_pool(常量池) | constant_pool_count-1 |
| u2 | access_flag(访问标志) | 1 |
| u2 | this_class(类索引) | 1 |
| u2 | super_class(父类索引 | 1 |
| u2 | interfaces_count(接口计数值) | 1 |
| u2 | interfaces(接口索引集合) | interfaces_count |
| u2 | fields_count(字段计数值) | 1 |
| field_info | fields(字段) | fields_count |
| u2 | methods_count(方法计数值) | 1 |
| method_info | methods(方法) | methods_count |
| u2 | attributes_count(属性计数值) | 1 |
| attribute_info | attributes(属性) | attributes_count |

## 1.2 常量池
紧接着主次版本号之后的是常量池入口

* 常量池可以理解为Class文件之中的资源仓库
* 它是Class文件结构中与其他项目关联最多的数据类型
* 也是Class文件空间最大的数据项目之一
* 同时它还是在Class文件中第一个出现的表类型数据项目

由于产量池中常量的数量是不固定的，所以在常量池的入口需要放置一项u2类型的数据，代表常量池容量计数器(constant_pool_count)

* 与Java中语言习惯不一样的是，这个容量计数从1而不是从0开始，这样做是由特殊考虑的，这样做的目的是在于满足后面某些指向常量池的索引值的数据在特定情况下需要表达"不引用任何一个常量池"的含义，这种情况就可以把索引值置为0来表示
* Class文件结构中，只有常量池的容量计数从1开始，对其他集合类型，包括接口索引集合，字段表集合，方法表集合等的容量计数都与一般习惯相同，从0开始
* 常量的数量=常量计数值-1(例如0x0016=22，代表常量池中有21项常量，索引范围1~21)

### 1.2.1 符号引用
常量池中主要存放两大类常量：字面量(Literal)和 __符号引用(Symbolic References)__

* 字面量比较接近于Java语言层面的常量概念，如文本字符串、声明为final的常量值等
* <符号引用>则属于编译原理方面的概念，包括以下三类常量
    * 类和接口的全限定名(Fully Qualified Name)
    * 字段的名称和描述符(Descriptor)
    * 方法的名称和描述符

Java代码在进行Javac编译的时候，并不像C和C++那样有"连接"这一步骤，而是在虚拟机加载Class文件的时候进行动态连接

* Class文件中不会保存各个方法、字段的最终内存布局信息，因为这些字段、方法的符号引用不经过运行期转换的话无法得到真正的内存入口地址，也就无法直接被虚拟机使用
* 当虚拟机运行时，需要从常量池获得对应的符号引用，再在类创建时或运行时解析、翻译到具体的内存地址之中

#### 1.2.1.1 那么什么是符号引用呢？
符号引用(Symbolic References)具有如下性质

* 符号引用以一组符号来描述所引用的目标，符号可以是任何形式的字面量，只要使用时无歧义地定位到目标即可
* 符号引用与虚拟机实现的内存布局无关，引用的目标不一定已经加载到内存中
* 各种虚拟机实现的内存布局可以各不相同，但是它们能接受的符号引用必须一致，因为符号引用的字面量形式明确定义在Java虚拟机规范的Class文件格式中

#### 1.2.1.2 为什么要使用符号引用呢？
我的理解是：Class文件是一种平台无关的存储格式，字节码(ByteCode)是构成平台无关的基石，Class文件的常量池中存有大量的符号引用，字节码中的方法调用指令就以常量池中指向方法的符号引用作为参数

* 这些符号引用一部分会在类加载阶段或者第一次使用的时候就转化为直接引用，这种转化称为<静态解析>
* 另外一部分将在每一次运行期间转化为直接引用，这部分称为<动态连接>

### 1.2.2  常量池中的类型
常量池中每一项都是一个表

* 在JDK 1.7之前共有11中结构各不相同的表结构数据
* 在JDK 1.7中为了更好地支持动态语言调用，又额外增加了3种(CONSTANT_MethodHandle_info、CONSTANT_MethodType_info和CONSTANT_InvokeDynamic_info)
* 这14个表有一个共同特点，就是表开始的第一位是一个u1类型的标志位，代表当前这个常量属于哪种常量类型
* 这14种常量类型各自均有自己的结构

| 类型 | 标志 | 描述 |
|:------------- |:--------------|:-------|
| CONSTANT_Utf8_info | 1 | UTF-8编码的字符串 | 
| CONSTANT_Integer_info | 3 | 整型字面量 | 
| CONSTANT_Float_info | 4 | 浮点型字面量 | 
| CONSTANT_Long_info | 5 | 长整型字面量 | 
| CONSTANT_Double_info | 6 | 双精度浮点型字面量 | 
| CONSTANT_Class_info | 7 | 类或接口的符号引用 | 
| CONSTANT_String_info | 8 | 字符串类型字面量 | 
| CONSTANT_Fieldref_info | 9 | 字段的符号引用 | 
| CONSTANT_Methodref_info | 10 | 类中方法的符号引用 | 
| CONSTANT_InterfaceMethodref_info | 11 | 接口中方法的符号引用 | 
| CONSTANT_NameAndType_info | 12 | 字段或方法的部分符号引用 | 
| CONSTANT_MethodHandle_info | 15 | 表示方法句柄 | 
| CONSTANT_MethodType_info | 16 | 标志方法类型 | 
| CONSTANT_InvokeDynamic_info | 18 | 表示一个动态方法调用点 | 

## 1.3 访问标志
在常量池结束之后，紧接着的两个字节代表访问标志(access_flags)

* 这个标志用于识别一些类或者接口层次的访问信息，包括：
    * 这个Class是类还是接口；
    * 是否定义为public类型
    * 是否定义为abstract类型
    * 如果是类的话，是否被声明为final等
* 这些含义可以组合使用，例如0x0021代表ACC_PUBLIC和ACC_SUPER
* access_flags共有16个标志位可用，当前只定义了8个，没有使用到的一律为0

| 标志名称 | 标志值 | 含义 | 
|:------------- |:--------------|:-------|
| ACC_PUBLIC | 0x0001 | 是否为public类型 | 
| ACC_FINAL | 0x0010 | 是否被声明为final，只有类可设置 | 
| ACC_SUPER | 0x0020 | 是否允许使用invokespecial字节码指令的新语意，invokespecial指令的语意在JDK 1.0.2发生过改变，为了区别这条指令使用哪种语意，JDK 1.0.2之后编译出来的类的这个标志都必须为真 | 
| ACC_INTERFACE | 0x0200 | 标志这是一个接口 | 
| ACC_ABSTRACT | 0x0400 | 是否为abstract类型，对于接口或者抽象类来说，此标志值为真，其他类型值为假 | 
| ACC_SYNTHETIC | 0x1000 | 标志这个类并非由用户代码产生的 | 
| ACC_ANNOTATION | 0x2000 | 标志这是一个注解 | 
| ACC_ENUM | 0x4000 | 标志这是一个枚举 | 

## 1.4 类索引、父类索引与接口索引集合
类索引(this_class)和父类索引(super_class)都是一个u2类型的数据，而接口索引集合(interfaces)是一组u2类型的数据的集合，Class文件中由这三项数据来确定这个类的继承关系

* 类索引用于确定这个类的全限定名，父类索引用于确定这个类的父类的全限定名
    * Java不允许多重继承，所以父类索引只有一个
    * 除了java.lang.Object之外，所有类都有父类
* 接口索引集合就用来描述这个类实现了哪些接口，这些被实现的接口将按implements(如果这个类本身是一个接口，那么是extends关键字)语句后的接口顺序从左到右排列在接口索引集合中

数据结构

* 类索引和父类索引各自指向一个类型为CONSTANT_Class_info的类描述符常量，通过CONSTANT_Class_info类型的常量中索引值可以找到定义在CONSTANT_Utf8_info类型的常量中的全限定名字符串
* 对于接口索引集合，入口的第一项---u2类型的数据为接口计数器(interfaces_count)，表示索引表的容量
* 如果该类没有实现任何接口，计数器为0，后面接的索引表将不再占用任何字节

## 1.5 字段表集合
字段表(field_info)用于描述接口或者类中声明的变量

字段包含的信息，概括起来就是分为以下三类

1. 字段名
1. 字段类型
1. 字段修饰符(public,private,protected,static,final,volatile,transient的子集)

字段表结构如下

| 类型 | 名称 | 数量 | 
|:------------- |:--------------|:-------|
| u2 | access_flags | 1 | 
| u2 | name_index | 1 | 
| u2 | descriptor_index | 1 | 
| u2 | attributes_count | 1 | 
| attribute_info | attributes | attributes_count | 

* 其中，access_flags项目可以设置的标志位和含义见下表

| 标志名称 | 标志值 | 含义 | 
|:------------- |:--------------|:-------|
| ACC_PUBLIC | 0x0001 | 字段是否public | 
| ACC_PRIVATE | 0x0002 | 字段是否private | 
| ACC_PROTECTED | 0x0004 | 字段是否protected | 
| ACC_STATIC | 0x0008 | 字段是否static | 
| ACC_FINAL | 0x0010 | 字段是否final | 
| ACC_VOLATILE | 0x0040 | 字段是否volatile | 
| ACC_TRANSIENT | 0x0080 | 字段是否transient | 
| ACC_SYNTHETIC | 0x1000 | 字段是否由编译器自动产生 | 
| ACC_ENUM | 0x4000 | 字段是否enum | 

* 跟随access_flags标志的是两项索引值：name_index和descriptor_index：它们都是对常量池的引用，分别代表字段的简单名称以及字段的描述符
* 字段表都包含的固定数据项到descriptor_index为止就结束了，不过在descriptor_index之后跟随者一个属性表集合用于存储一些额外的信息，字段都可以在属性表中描述零至多项额外信息
    * 例如"final static int m=123"，需要一项名称为ConstantValue的属性，其值指向常量123 

### 1.5.1 概念解析：全限定名、简单名称、描述符

__全限定名__

* 含有包名的完整类名
* 并且将'.'换成了'/'
* 并且为了使连续的多个全限定名之间不产生混淆，在使用时最后一般会加一个";"表示全限定名结束

__简单名称__

* 没有类型和参数修饰的方法或者字段名称
* 例如int a;中的a
* 例如void f();中的f

__描述符__

* 描述符的作用是用来描述字段的数据类型、方法的参数列表(包括数量、类型以及顺序)和返回值
* 基本数据类型以及代表无返回值的void类型都用一个大写字符来表示，而对象则用字符L加对象的全限定名来表示
* 对于数组类型，每一维度将使用一个前置的"["字符来描述
    * 例如java.lang.String[][]类型的二维数组，被记录为:"[[Ljava/lang/String;"
    * 例如整型数组int[]将被记录为"[I"
* 描述符用来描述方法时
    * 按照先参数列表，后返回值的顺序描述顺序
    * 参数列表按照参数的严格顺序放在一组小括号内"()"之内
    * 例如void inc()的描述符为"()V"
    * 例如java.lang.String toString()的描述符为()Ljava/lang/String
    * 例如int indexOf(char[]source ,int sourceOffset,int sourceCount,char[] target,int targetOffset,int targetCount,int fromIndex)的描述符为"([CII[CIII)I"

描述符标志字符含义表

| 标志字符 | 含义 | 
|:------------- |:--------------|
| B | 基本类型byte | 
| C | 基本类型char | 
| D | 基本类型double | 
| F | 基本类型float | 
| I | 基本类型int | 
| J | 基本类型long | 
| S | 基本类型short | 
| Z | 基本类型boolean | 
| V | 特殊类型void | 
| L | 对象类型，例如Ljava/lang/Object | 

## 1.6 方法表集合
Class文件存储格式中对方法的表述与对字段的描述几乎采用了完全一致的方式，方法表的结构如同字段一样，依次包括

* 访问标志(access_flags)，即方法修饰符
* 名称索引(name_index)
* 描述符索引(descriptor_index)
* 属性表集合(attributes)

方法表结构如下

| 类型 | 名称 | 数量 | 
|:-----|:-----|:----| 
| u2 | access_flags | 1 | 
| u2 | name_index | 1 | 
| u2 | descriptor_index | 1 | 
| u2 | attributes_count | 1 | 
| attribute_info | attributes | attributes_count | 

* 其中，access_flags项目可以设置的标志位和含义见下表

| 标志名称 | 标志值 | 含义 | 
|:-----|:-----|:----| 
| ACC_PUBLIC | 0x0001 | 方法是否为public | 
| ACC_PRIVATE | 0x0002 | 方法是否为private | 
| ACC_PROTECTED | 0x0004 | 方法是否为protected | 
| ACC_STATIC | 0x0008 | 方法是否为static | 
| ACC_FINAL | 0x0010 | 方法是否为final | 
| ACC_SYNCHRONIZED | 0x0020 | 方法是否为synchronized | 
| ACC_BRIDGE | 0x0040 | 方法是否是由编译器产生的桥接方法 | 
| ACC_VARARGS | 0x0080 | 方法是否接受不定参数 | 
| ACC_NATIVE | 0x0100 | 方法是否为native | 
| ACC_ABSTRACT | 0x0400 | 方法是否为abstract | 
| ACC_STRICTFP | 0x0800 | 方法是否为strictfp | 
| ACC_SYNTHETIC | 0x1000 | 方法是否是由编译器自动产生的 | 

* 跟随access_flags标志的是两项索引值：name_index和descriptor_index：它们都是对常量池的引用，分别代表字段的简单名称以及字段和方法的描述符
* 方法表包含的固定数据项到descriptor_index为止就结束了，不过在descriptor_index之后跟随者一个属性表集合用于存储一些额外的信息。方法里的Java代码，经过编译器编译成字节码指令后，存放在方法属性表集合中一个名为"Code"的属性里面，属性表作为Class文件格式中最具扩展性的一种数据项目

与字段表集合相对应，如果父类方法在子类中没有被重写，方法表集合中就不会出现来自父类的方法信息，但是有可能会出现编译器自动添加的方法，最典型的便是类构造器<clinit>方法和实例构造器<init>方法

在Java中，要重载一个方法，除了要与原方法具有相同的简单名称之外，还要求必须拥有一个与原方法不同的特征签名，特征签名就是一个方法中各个参数在常量池中的字段符号引用集合

* Java语言无法依靠返回值的不同来对一个已有方法进行重载
* 在Class文件格式中，特征签名的范围更大，只要描述符不是完全一致的两个方法也可以共存

## 1.7 属性表集合

# 2 javap参数简介

* __-c：输出类中各方法的未解析的代码，即构成java字节码的指令__
* -classpath &lt;pathlist&gt;：指定javap用来查找类的路径。目录用：分隔
* -extdirs &lt;dirs&gt;：覆盖搜索安装方式扩展的位置，扩展的缺省位置为jre/lib/ext
* -help：输出帮助信息
* -J &lt;flag&gt;： 直接将flag传给运行时系统
* __-l：输出行及局部变量表__
* -public：只显示public类及成员
* -protected：只显示protected和public类及成员。
* -package：只显示包、protected和public类及成员，，这是缺省设置
* -private：显示所有的类和成员
* -s：输出内部类型签名
* -bootclasspath &lt;pathlist&gt;：指定加载自举类所用的路径，如jre/lib/rt.jar或i18n.jar
* __-verbose：打印堆栈大小、各方法的locals及args参数，以及class文件的编译版本__

__javap或者用文本形式表示Java字节码时，那些带offset参数的字节码指令通常都不是把裸的offset写出来，而是把计算过后的跳转目标写出来__

* 例如goto 有两个byte操作数，而javap会直接把这两个byte offset所代表的数值计算出来

# 3 字节码简介

## 3.1 参考文献
若有异议或疑问，请参考以下3个参考文献

 __[Java bytecode instruction listings](https://en.wikipedia.org/wiki/Java_bytecode_instruction_listings)__
 __[Java Virtual Machine Specification](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.jsr)__
 __深入理解Java虚拟机__

## 3.2 什么是字节码
Java虚拟机就的指令由一个字节长度的、代表着某种特定操作含义的数字(称为操作码，Opcode)以及跟随其后的零个或多个代表此操作所需参数(称为操作数，Operands)而构成
 
__由于Java虚拟机采用面向操作数栈而不是寄存器的架构，所以大多数指令都不包含操作数，只有一个操作码__

字节码指令集是一种具有鲜明特点、优劣势都很突出的指令集架构

* 由于限制了Java虚拟机操作码的长度为一个字节(0~255)，这意味着操作码总数不可能超过256条
* 由于Class文件格式放弃了编码后代码的操作数长度对齐，这就意味着虚拟机处理那些超过一个字节数据的时候，不得不在运行时从字节中重建出具体数据的结构，如果要将一个16位长度的无符号整数使用两个无符号字节存储起来(byte1<<8)|byte2
* 这种操作在某种程度上会导致解释执行字节码时损失一些性能，但这样做的优势也很明显，放弃了操作数长度对齐，这就意味着可以省略很多填充和间隔符号
* 用一个字节来代表操作码，也是为了尽可能获得短小精干的编译代码，这种追求尽可能小数据量、高传输效率的设计是由Java语言设计之初面向网络、智能家电的技术背景所决定的，并一直沿用至今

__Java解释器的伪代码模型__
```
    do{
        自动计算PC寄存器值+1
        根据PC寄存器的指示位置，从字节码流中取出操作码
        if(字节码存在操作数) 从字节码流中取出操作数
        执行操作码所定义的操作
    }while(字节码流长度>0)
```

## 3.3 字节码与数据类型
__Java虚拟机的指令集中，大多数的指令都包含了其操作对应的数据类型__

* 例如iload指用于从局部变量表中加载int型的数据到操作数栈中
* fload指令加载的则是float类型的数据
* 这两条指令的操作在虚拟机内部可能会是由同一段代码实现的，但在Class文件中它们必须拥有各自独立的代码

__对于大部分与数据类型相关的字节码指令，它们的操作码助记符中都有特殊的字符来表明专门为哪种数据类型服务__

* i：int类型
* l：long类型
* s：short类型
* b：byte类型
* c：char类型
* f：float类型
* d：double类型
* __a：reference类型__

## 3.4 加载和存储指令

__加载和存储指令用于将数据在栈帧中的局部变量和操作数栈之间来回传输(伴随着操作数栈的入栈和出栈操作)__

* 将一个局部变量加载到操作数栈：iload、iload_&lt;n&gt;、lload、lload_&lt;n&gt;、fload、fload_&lt;n&gt;、dload、dload_&lt;n&gt;、aload、aload&lt;n&gt;
    * 其中 __0<=n<=3__，__带有_&lt;n&gt; 后缀的字节码不带有操作数__，后缀即代表局部变量表的偏移量
    * __不带有_&lt;n&gt;后缀的字节码有一个操作数__，该操作数代表局部变量表的偏移量
    * __这些字节码伴随着入栈操作__
* 将一个数值从操作数栈存储到局部变量表：istore、istore_&lt;n&gt;、lstore、lstore_&lt;n&gt;、fstore、fstore_&lt;n&gt;、dstore、dstore_&lt;n&gt;、astore、astore_&lt;n&gt;
    * 其中 __0<=n<=3__，__带有_&lt;n&gt;后缀的字节码不带有操作数__，后缀即代表局部变量表的偏移量
    * __不带有_&lt;n&gt;后缀的字节码有一个操作数__，该操作数代表局部变量表的偏移量
    * __这些字节码伴随着出栈操作__
* 将一个常量加载到操作数栈：bipush、sipush、ldc、ldc_w、ldc2_w、aconst_null、iconst_m1、iconst_&lt;i&gt;、lconst_&lt;l&gt;、fconst_&lt;f&gt;、dconst_&lt;d&gt;
    * bipush：将操作数指定的字节push到栈顶，作为一个int。__一个操作数__，类型为字节
    * sipush：将操作数指定的short(该shrot由操作数提供)push到栈顶，作为一个int，__一个操作数__，类型为short
    * ldc、ldc_w：将一个位于常量池的String, int, float, Class, java.lang.invoke.MethodType, or java.lang.invoke.MethodHandle push到栈顶，这两个字节码的区别是操作数的含义不同，__ldc的操作数只有一个__，是常量池偏移量；__ldc_w有两个字节操作数__，这两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
    * ldc_w2：将一个位于常量池的double或long push到栈顶，__有两个字节操作数__，这两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
    * aconst_null：将一个null push到栈顶，__没有操作数__
    * iconst_m1：将常量-1 push到栈顶，__没有操作数__
    * iconst_&lt;i&gt;、lconst_&lt;l&gt;、fconst_&lt;f&gt;、dconst_&lt;d&gt;：其中0<=i<=5，0<=l<=1，0<=f<=2，0<=d<=1。将一个指定的 整数、长整数、浮点数、双精度浮点数压入栈顶。__这些字节码均没有操作数__
* 扩充局部变量表的访问索引的指令：wide

__注意：不同数据类型的同类字节码，例如iload、lload、fload、dload、aload共享同一个局部变量表偏移量，例如局部变量大小为5，分别存放着：reference，int，long，float，double，那么可能涉及到的字节码就是aload_0，iload_1，lload_2，fload_3，dload 4。!!!不要认为!!! iload_0作用的是局部变量表中第0个int型变量，aload_0作用的是局部变量表中第0个引用__

## 3.5 运算指令

运算或算数指令用于对操作数栈上的两个值进行某种特定运算，并把结果重新存入到操作数栈顶

__大体上算数指令可以分为两种：对整数数据进行运算的指令与对浮点型数据进行运算的指令__

* 无论是哪种算数指令，都是用Java虚拟机的数据类型
* 由于没有直接支持byte、short、char、boolean类型的算数指令，对于这些数据的运算，应使用操作int类型的指令代替

__算数指令__

* 加法指令：iadd、ladd、fadd、dadd：计算 __栈次顶元素 + 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 减法指令：isub、lsub、fsub、dsub：计算 __栈次顶元素 - 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 乘法指令：imul、lmul、fmul、dmul：计算 __栈次顶元素 * 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 触发指令：idiv、ldiv、fdiv、ddiv：计算 __栈次顶元素 / 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 求余指令：irem、lrem、frem、drem：计算 __栈次顶元素 % 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 取反指令：ineg、lneg、fneg、dneg：计算 __栈顶元素的相反数__ ，然后弹出栈顶元素并将相反数push到栈顶。__没有操作数__
* 位移指令：ishl、ishr、iushr、lshl、lshr、lushr：计算 __栈次顶元素<< or >> or >>>栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__。其中iushr和lushr为逻辑右移
* 按位或指令：ior、lor：计算 __栈次顶元素 | 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 按位与指令：iand、land：计算 __栈次顶元素 & 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 按位异或指令：ixor、lxor：计算 __栈次顶元素 ^ 栈顶元素__ 的结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__
* 局部变量自增指令：iinc：__该字节码不操作操作数栈。有2个操作数，第一个操作数代表局部变量表的偏移量，第二个操作数是一个常量，将第一个操作数所指定的局部变量表中的变量加上指定的常量__
* 比较指令：dcmpg、dcmpl、fcmpg、fcmpl、lcmp：计算 __栈次顶元素 和 栈顶元素__ 的大小关系结果，然后弹出栈顶和栈次顶元素并将结果push到栈顶。__没有操作数__

## 3.6 类型转换指令

类型转换指令可以将两种不同的数值类型进行相互转换，这些转换操作一般用于实现用户代码中的显式类型转换操作

__Java虚拟机直接支持以下数值类型的宽化类型转换(Widening Numeric Conversions，即小范围向大范围类型的安全转换)__

* i2l：将栈顶元素转从int转换成long。__没有操作数__
* i2f：将栈顶元素转从int转换成float。__没有操作数__
* i2d：将栈顶元素转从int转换成double。__没有操作数__
* l2f：将栈顶元素转从long转换成float。__没有操作数__
* l2d：将栈顶元素转从long转换成double。__没有操作数__
* f2d：将栈顶元素转从float转换成double。__没有操作数__

__处理窄化类型转换(Narrowing Numeric Conversions)时，必须显式地使用转换指令来完成，包括__

* i2b：将栈顶元素转从int转换成byte。__没有操作数__
* i2c：将栈顶元素转从int转换成char。__没有操作数__
* i2s：将栈顶元素转从int转换成short。__没有操作数__
* l2i：将栈顶元素转从long转换成int。__没有操作数__
* f2i：将栈顶元素转从float转换成int。__没有操作数__
* f2l：将栈顶元素转从long转换成long。__没有操作数__
* d2i：将栈顶元素转从double转换成int。__没有操作数__
* d2l：将栈顶元素转从double转换成long。__没有操作数__
* d2f：将栈顶元素转从double转换成float。__没有操作数__

## 3.7 对象创建与访问指令

虽然类实例和数组都是对象，但Java虚拟机对实例和数组的创建与操作使用了不同的字节码指令，对象创建后，就可以通过对象访问指令获取对象实例或者数组实例中的字段或者数组元素
__创建类实例的指令__

* new：创建指定类的实例，并将创建的对象的引用push到栈顶。__2个字节操作数__，这2个字节操作数构成一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)

__创建数组的指令__

* newarray：栈顶元素即数组大小，创建指定类的数组，然后将栈顶元素出栈，并将创建的数组对象的引用push到栈顶。__1个操作数__，这个操作数表示数组元素的类型
* anewarray：栈顶元素即数组大小，创建指定类的数组，然后将栈顶元素出栈，并将创建的数组对象的引用push到栈顶。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定数组元素的类型
* multianewarray：???

__访问类字段(static字段、或称为类变量)和实例字段(非static字段，或者称为实例变量)的指令__

* getfield：访问栈顶元素所代表对象的指定字段，然后将栈顶元素出栈，将访问的结果puhs到栈顶。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定字段
* putfield：将栈顶元素的值赋值给栈次顶元素所代表的对象的指定字段，然后将栈顶元素和次顶元素出栈。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定字段
* getstatic：访问指定的静态字段并push到栈顶。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定静态字段
* putstatic：将栈顶元素的值赋值给指定静态字段，并弹出栈顶元素。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定静态字段

__把一个数组元素加载到操作数栈的指令：baload、caload、saload、iaload、laload、faload、daload、aaload__

* 栈顶元素为数组下标，栈次顶元素为数组对象的引用，访问指定元素，然后将栈顶元素和栈次顶元素出栈。并将访问到的元素push到栈顶。__没有操作数__

__将一个操作数栈的值存储到数组元素中的指令：bastore、castore、sastore、iastore、fastore、dastore、aastore__

* 栈顶元素为值，栈次顶元素为下标，栈次次顶元素为数组对象的引用，将指定值赋值给指定数组元素，然后将栈顶元素和栈次顶元素和栈次次顶元素出栈。__没有操作数__

__取数组长度的指令__

* arraylength：访问栈顶元素代表的数组对象的长度，然后将栈顶元素出栈，并且将数组长度push到栈顶。__没有操作数__

__检查类实例类型的指令__

* instanceof：检查栈顶元素是否为指定类型的对象。弹出栈顶元素，并将检查结果push到栈顶。__2个字节操作数__，这2个字节操作数共同表示常量池偏移量(index=indexbyte1 << 8 + indexbyte2)，用于确定类型
* checkcast：???

## 3.8 操作数栈管理指令

如果操作一个普通数据结构中的堆栈那样，Java虚拟机提供了一些用于直接操作操作数栈的指令
__将操作数栈顶的一个或两个元素出栈__

* pop：将栈顶元素出栈。__没有操作数__
* pop2：将栈顶两个元素出栈，或者将一个元素出栈(这个元素是double或者long)。__没有操作数__

__赋值栈顶一个或两个数值并将赋值值或双份的赋值值重新压入栈顶__

* dup：复制栈顶元素，然后将拷贝push到栈顶。__没有操作数__
* dup2：如果栈顶元素和栈次顶元素非double或long类型，那么复制这对元素，并push到栈顶；如果栈顶元素是long或double，那么复制该元素并push到栈顶。__没有操作数__
* dup_x1：
* dup2_x1：
* dup_x2：
* dup2_x2：

__将栈最顶端的两个数值互换__

* swap：交换栈顶两个元素，这两个元素必须是非long或double类型的。__没有操作数__

## 3.9 控制转移指令

控制转义指令可以让Java虚拟机有条件或无条件地从指定位置指令而不是控制转移指令的下一条指令继续执行程序，从概念模型上理解，可以认为控制转义指令就是在有条件或无条件地修改PC寄存器的值

__条件分支__

* ifeq：如果栈顶元素等于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* iflt：如果栈顶元素小于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifle：如果栈顶元素小于或等于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifne：如果栈顶元素不等于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifgt：如果栈顶元素大于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifge：如果栈顶元素大于或等于0，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifnull：如果栈顶元素为null，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* ifnonnull：如果栈顶元素不为null，跳转到指定的字节码位置，并将栈顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmpeq：如果栈次顶元素与栈顶元素相等，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmpne：如果栈次顶元素与栈顶元素不相等，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmplt：如果栈次顶元素小于栈顶元素，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmpgt：如果栈次顶元素大于栈顶元素，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmple：如果栈次顶元素小于或等于栈顶元素，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_icmpge：如果栈次顶元素大于或等于栈顶元素，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_acmpeq：如果栈次顶元素与栈顶元素是同一个引用，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* if_acmpne：如果栈次顶元素与栈顶元素不是同一个引用，跳转到指定的字节码位置，并将栈顶元素和栈次顶元素出栈。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)

__复合条件分支__

* tableswitch：操作数有点复杂，暂时没搞明白
* lookupswitch：操作数有点复杂，暂时没搞明白

__无条件分支__

* goto：跳转到指定字节码位置。__该字节码不操作操作数栈__。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
* goto_w：跳转到指定字节码位置。__该字节码不操作操作数栈__。__4个操作数__，这4个操作数共同决定了一个字节码偏移量(index=branchbyte1 << 24 + branchbyte2 << 16 + branchbyte3 << 8 + branchbyte4)
* jsr：跳转到指定偏移量的字节码处。__并且将jsr这条字节码之后的字节码地址压到操作数栈__。__2个字节操作数__，这两个字节操作数共同决定了一个字节码偏移量(index=indexbyte1 << 8 + indexbyte2)
    * 该字节码曾经用于实现try{}finally{}语句。JDK 1.4.2之后已经弃用，现在的做法是：javac采用的办法是把finally块的内容复制到原本每个jsr指令所在的地方。这样就不需要jsr/ret了，代价则是字节码大小会膨胀
* jsr_w：跳转到指定偏移量的字节码处。__并且将jsr_w这条字节码之后的字节码地址压到操作数栈__。__4个字节操作数__，这4个字节操作数共同决定了一个字节码偏移量(index=branchbyte1 << 24 + branchbyte2 << 16 + branchbyte3 << 8 + branchbyte4)
* ret：从指定的局部变量表中变量(该变量保存了jsr字节码压入的字节码地址???)
* __[jsr/ret字节码剖析](https://www.zhihu.com/question/29056872)__

### 3.9.1 其他类型的条件分支

* 对于boolean、char、byte、shrot类型的条件分支比较操作，都是使用int类型的比较指令来完成
* 对于long类型、float类型和double类型的条件分支比较操作，则会先执行相应类型的比较运算指令(dcmpg、dcmpl、fcmpg、fcmpl、lcmp)，运算指令会返回一个整型值到操作数栈中，随后再执行int类型的条件分支比较操作来完成整个分支跳转
* 由于各种类型的比较最终都会转化为int类型的比较操作，int类型比较是否方便完善就显得尤为重要，所以Java虚拟机提供的int类型的条件分支指令是最为丰富和强大的

## 3.10 方法调用和返回指令

### 3.10.1 invokevirtual

__invokevirtual字节码调用对象实例的方法，根据对象的实际类型进行分派(动态单分派)，这也是Java语言中最常见的分派方式__

* __该字节码有两个字节操作数__，这两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
* 操作数栈：.., objectref, [arg1, [arg2 ...]] →...
* 不能用于调用实例的初始化方法

__实际被调用的方法将按照下面的步骤进行(假设C是objectref的类型)__

* 如果C中存在名字和描述符与调用方法的名字和描述符完全一致的方法，那么调用这个实例方法即可
* 否则，沿着继承体系向上迭代查找与调用方法名字和描述符完全一致的方法，如果找到了，则调用这个实例方法即可
* 否则，抛出异常，根据不同的情况将会抛出不同的异常，详见[jvms-6.5.invokevirtual](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokevirtual)

### 3.10.2 invokeinterface
__invokeinterface字节码用于调用接口方法__

* __该字节码有4个字节操作数__   (indexbyte1, indexbyte2, count, 0)
    * 前两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
    * 第3个操作数count用于记录参数的度量，(double和long类型度量值为2，其他类型度量值为1。__这个信息完全可以从方法描述符中获取，因此该参数是冗余的，这个冗余是历史性的__
    * 第4个操作数必须为0，作为扩展之用
* 操作数栈：..., objectref, [arg1, [arg2 ...]] →...
* 不能用于调用实例的初始化方法

__实际被调用的方法将按照下面的步骤进行(假设C是objectref的类型)__

* 如果C中存在名字和描述符与调用方法的名字和描述符完全一致的方法，那么调用这个实例方法即可
* 否则，沿着继承体系向上迭代查找与调用方法名字和描述符完全一致的方法，如果找到了，则调用这个实例方法即可
* 否则，抛出异常，根据不同的情况将会抛出不同的异常，详见[jvms-6.5.invokeinterface](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokeinterface)

### 3.10.3 invokespecial
__invokespecial：用于调用一些需要特殊处理的实例方法，包括实力初始化方法、私有方法和父类方法__

* __该字节码有两个字节操作数__，这两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
* 操作数栈：.., objectref, [arg1, [arg2 ...]] →...

__满足以下3个条件时，C被解析为objectref的父类，否则C被解析为objectref的类型__

1. 调用方法不是实例初始化方法
2. 符号引用包含类型，且该类型是objectref的父类
3. access_flag中含有ACC_SUPER

__实际被调用的方法将按照下面的步骤进行(类型C的解析按照上述要求进行)__

* 如果C中存在名字和描述符与调用方法的名字和描述符完全一致的方法，那么调用这个实例方法即可
* 否则，沿着继承体系向上迭代查找与调用方法名字和描述符完全一致的方法，如果找到了，则调用这个实例方法即可
* 否则，如果C是一个接口，并且Object中包含与调用方法的名字和描述符完全一致的方法，则调用这个实例方法即可
* 否则，抛出异常，根据不同的情况将会抛出不同的异常，详见[jvms-6.5.invokespecial](https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-6.html#jvms-6.5.invokespecial)

```Java
class Test {
    public static void main(String[] args){
        Test test=new Test();   //调用构造方法

        test.func();   //调用私有方法
    }

    private void func(){
        super.toString();    //调用父类方法
    }
}
```

### 3.10.4 invokestatic
__invokestatic：用于调用类方法(static)__

* __该字节码有两个字节操作数__，这两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)
* 操作数栈：..., [arg1, [arg2 ...]] →...

### 3.10.5 invokedynamic
__invokedynamic：用于在运行时动态解析出调用点限定符所引用的方法，并执行该方法，前面4条指令的分派逻辑都固化在Java虚拟机内部，而invokedynamic指令的分派逻辑是由用户设定的引导方法决定的__

* __该字节码有4个字节操作数__   (indexbyte1, indexbyte2, 0, 0)
    * 前两个字节操作数共同决定一个常量池偏移量(index=indexbyte1 << 8 + indexbyte2)

### 3.10.6 方法返回指令
__方法调用指令与数据类型无关，而方法返回指令是根据返回值的类型区分的，包括ireturn(当返回值是boolean、byte、char、short和int类型时使用)、lreturn、freturn、dreturn和areturn，另外还有一条return指令供声明为void的方法、实例初始化方法以及类和接口的类初始化方法使用__

* ireturn：返回栈顶元素，并且将栈顶元素出栈。__没有操作数__
* lreturn：返回栈顶元素，并且将栈顶元素出栈。__没有操作数__
* freturn：返回栈顶元素，并且将栈顶元素出栈。__没有操作数__
* dreturn：返回栈顶元素，并且将栈顶元素出栈。__没有操作数__
* areturn：返回栈顶元素，并且将栈顶元素出栈。__没有操作数__

## 3.11 异常处理指令
在Java程序中显式抛出异常的操作(throw语句)都由athrow指令来实现，除了用throw语句显式抛出异常情况之外，Java虚拟机规范还规定了许多运行时异常会在其他Java虚拟机指令检测到异常状况时抛出

__在Java虚拟机中，处理异常(catch语句)不是由字节码指令来实现的，而是采用异常表来完成的__

## 3.12 同步指令

Java虚拟机可以支持方法级的同步和方法内部一段指令序列的同步，这两种同步结构都是使用管理(Monitor)来支持的

__方法级同步是隐式的，即无需通过字节码指令来控制，它实现在方法调用和返回操作之中__

* 虚拟机可以从方法常量池的方法表结构中的ACC_SYNCHRONIZED访问标志得知一个方法是否声明为同步方法
* 当方法调用时，调用指令将会检查方法的ACC_SYNCHRONIZED访问标志是否被设置，如果设置了，执行线程就要求先成功持有锁，然后才能执行方法，最后当方法完成(无论是正常还是非正常完成)时释放锁
* 在方法执行期间，执行线程持有了锁，其他任何线程都无法在获取到同一个锁
* 如果一个同步方法执行期间抛出了异常，并且在方法内部无法处理此异常，那么这个同步方法所持有的锁将在异常抛到同步方法之外时自动释放

__同步一段指令集序列通常是由Java语言中的synchronized语句块来表示的__

* Java虚拟机的指令集有monitorenter和monitorexit两条指令来支持synchronized关键字的语义
    * monitorenter：获取栈顶元素的锁，并且将栈顶元素出栈。__没有操作数__
    * monitorexit：释放栈顶元素的锁，并且将栈顶元素出栈。__没有操作数__
* 正确实现synchronized关键字需要Javac编译器与Java虚拟机两者共同协作支持
* 编译器必须确保无论方法通过何种方式完成，方法中调用过的每条monitorenter指令都必须执行其对应的monitorexit指令，而无论这个方法是正常结束还是异常结束

## 3.13 以下是所有不改变操作数栈的字节码指令

* goto
* goto_w
* iinc
* nop
* ret

## 3.14 16个以符号引用为参数的字节码

1. anewarray
1. checkcast
1. getfield
1. getstatic
1. instanceof
1. invokedynamic
1. invokeinterface
1. invokespecial
1. invokestatic
1. invokevertual
1. ldc
1. ldc_w
1. multianewarray
1. new
1. putfield
1. putstatic

# 4 阅读javap解析后的字节码文件
本节将对不同的java语法(例如循环、条件控制、方法、构造方法、synchronized关键字等等)进行字节码层面的分析

## 4.1 循环字节码分析

本小节将比较for循环，while循环，以及for each循环在字节码层面上的异同点
### 4.1.1 for循环

以一个简单的加法程序进行分析
```Java
1 public class Test{
2     public int testFor(){
3         int val=0;
4         for(int i=0;i<10;i++)
5             val+=i;
6         return val;
7     }
8 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出
```
  Last modified Jun 21, 2017; size 381 bytes
  MD5 checksum 16aa41fa84971176496b06f0ebcb7fd5
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #3.#18         // java/lang/Object."<init>":()V
   #2 = Class              #19            // Test
   #3 = Class              #20            // java/lang/Object
   #4 = Utf8               <init>
   #5 = Utf8               ()V
   #6 = Utf8               Code
   #7 = Utf8               LineNumberTable
   #8 = Utf8               LocalVariableTable
   #9 = Utf8               this
  #10 = Utf8               LTest;
  #11 = Utf8               testFor
  #12 = Utf8               ()I
  #13 = Utf8               i
  #14 = Utf8               I
  #15 = Utf8               val
  #16 = Utf8               SourceFile
  #17 = Utf8               Test.java
  #18 = NameAndType        #4:#5          // "<init>":()V
  #19 = Utf8               Test
  #20 = Utf8               java/lang/Object
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public int testFor();
    descriptor: ()I
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=3, args_size=1
         0: iconst_0
         1: istore_1
         2: iconst_0
         3: istore_2
         4: iload_2
         5: bipush        10
         7: if_icmpge     20
        10: iload_1
        11: iload_2
        12: iadd
        13: istore_1
        14: iinc          2, 1
        17: goto          4
        20: iload_1
        21: ireturn
      LineNumberTable:
        line 3: 0
        line 4: 2
        line 5: 10
        line 4: 14
        line 6: 20
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            4      16     2     i   I
            0      22     0  this   LTest;
            2      20     1   val   I
}
SourceFile: "Test.java"
```
__着重对testFor方法的字节码进行分析__

* &lt;0: iconst_0&gt;：将整形 __常数0__ push到栈顶
* &lt;1: istore_1&gt;：将栈顶元素存入local variable 1，此处指的就是var变量
* &lt;2: iconst_0&gt;：将整形 __常数0__ push到栈顶
* &lt;3: istore_2&gt;：将栈顶元素存入local variable 2，此处指的就是循环变量i
* &lt;4: iload_2&gt;：将local variable 2的值push到栈顶，此处就是将变量i的值push到栈顶
* &lt;5: bipush        10&gt;：将整形常 __数10__，push到栈顶
* &lt;7: if_icmpge     20&gt;：如果栈次顶元素大于等于(greater equal)栈顶元素，跳转到偏移量为20的字节码指令处
    * __以下为if_icmpge不成立时的执行逻辑__
    * &lt;10: iload_1&gt;：将local variable 1的值push到栈顶，此处就是将变量var的值push到栈顶
    * &lt;11: iload_2&gt;：将local variable 2的值push到栈顶，此处就是将变量i的值push到栈顶
    * &lt;12: iadd&gt;：取出栈顶和栈次顶元素相加，并将结果push到栈顶
    * &lt;13: istore_1&gt;：将栈顶元素存入local variable 1，就是将相加后的结果保存到变量var中
    * &lt;14: iinc          2, 1&gt;：将local variable 2的值增加1，iinc第一个参数指的是local variable的偏移量，第二个参数指的是一个有符号整数。__这个字节码不操作操作数栈，而是直接操作局部变量__
    * &lt;17: goto          4&gt;：跳转到偏移量为4的字节码指令处
    * __以下为if_icmpge成立时的执行逻辑__
    * &lt;20: iload_1&gt;：将local variable 1的值push到栈顶，这里就是将变量var的值push到栈顶
    * &lt;21: ireturn&gt;：将栈顶元素作为整形返回

__注意点__：注意到local variable 0被保留了，这个是用于存放this引用的

### 4.1.2 while循环

仍然以一个同样的加法程序进行分析
```Java
1  public class Test {
2      public int testWhile() {
3          int val = 0;
4          int i = 0;
5          while (i < 10) {
6              val += i;
7              i++;
8          }
9          return val;
10     }
11 }
```
执行 __javap -c -v .\Test.class__ 得到以下输出
```
  Last modified Jun 21, 2017; size 387 bytes
  MD5 checksum 95a3da37e5574195d4b7dae5f9e0919d
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #3.#18         // java/lang/Object."<init>":()V
   #2 = Class              #19            // Test
   #3 = Class              #20            // java/lang/Object
   #4 = Utf8               <init>
   #5 = Utf8               ()V
   #6 = Utf8               Code
   #7 = Utf8               LineNumberTable
   #8 = Utf8               LocalVariableTable
   #9 = Utf8               this
  #10 = Utf8               LTest;
  #11 = Utf8               testWhile
  #12 = Utf8               ()I
  #13 = Utf8               val
  #14 = Utf8               I
  #15 = Utf8               i
  #16 = Utf8               SourceFile
  #17 = Utf8               Test.java
  #18 = NameAndType        #4:#5          // "<init>":()V
  #19 = Utf8               Test
  #20 = Utf8               java/lang/Object
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public int testWhile();
    descriptor: ()I
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=3, args_size=1
         0: iconst_0
         1: istore_1
         2: iconst_0
         3: istore_2
         4: iload_2
         5: bipush        10
         7: if_icmpge     20
        10: iload_1
        11: iload_2
        12: iadd
        13: istore_1
        14: iinc          2, 1
        17: goto          4
        20: iload_1
        21: ireturn
      LineNumberTable:
        line 3: 0
        line 4: 2
        line 5: 4
        line 6: 10
        line 7: 14
        line 9: 20
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0      22     0  this   LTest;
            2      20     1   val   I
            4      18     2     i   I
}
SourceFile: "Test.java"
```
__着重对testWhile方法的字节码进行分析__

* &lt;0: iconst_0&gt;：将整形 __常数0__ push到栈顶
* &lt;1: istore_1&gt;：将栈顶元素存入local variable 1，此处指的就是var变量
* &lt;2: iconst_0&gt;：将整形 __常数0__ push到栈顶
* &lt;3: istore_2&gt;：将栈顶元素存入local variable 2，此处指的就是循环变量i
* &lt;4: iload_2&gt;：将local variable 2的值push到栈顶，此处就是将变量i的值push到栈顶
* &lt;5: bipush        10&gt;：将整形常 __数10__，push到栈顶
* &lt;7: if_icmpge     20&gt;：如果栈次顶元素大于等于(greater equal)栈顶元素，跳转到偏移量为20的字节码指令处
    * __以下为if_icmpge不成立时的执行逻辑__
    * &lt;10: iload_1&gt;：将local variable 1的值push到栈顶，此处指的就是变量var
    * &lt;11: iload_2&gt;：将local variable 2的值push到栈顶，此处指的就是循环变量i
    * &lt;12: iadd&gt;：取出栈顶和栈次顶元素相加，并将结果push到栈顶
    * &lt;13: istore_1&gt;：将栈顶元素存入local variable 1，就是将相加后的结果保存到变量var中
    * &lt;14: iinc          2, 1&gt;：将local variable 2的值增加1，iinc第一个参数指的是local variable的偏移量，第二个参数指的是一个有符号整数。__这个字节码不操作操作数栈，而是直接操作局部变量__
    * &lt;17: goto          4&gt;：跳转到偏移量为4的字节码指令处
    * __以下为if_icmpge成立时的执行逻辑__
    * &lt;20: iload_1&gt;：将local variable 1的值push到栈顶，这里就是将变量var的值push到栈顶
    * &lt;21: ireturn&gt;：将栈顶元素作为整形返回

__可以看出，while循环的字节码与for循环的字节码没什么区别__

### 4.1.3 for each循环

fo each需要用到实现了Iterable接口的容器

```Java
1  import java.util.List;
2  
3  public class Test {
4      public int testForeach(List<Integer> list) {
5          int val = 0;
6          for (Integer i : list) {
7              val += i;
8          }
9          return val;
10     }
11 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出，可以看出foreach的字节码稍微复杂一点

```
  Last modified Jun 21, 2017; size 831 bytes
  MD5 checksum 6add3976b2cc53b1aca651210588e28d
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #8.#30         // java/lang/Object."<init>":()V
   #2 = InterfaceMethodref #31.#32        // java/util/List.iterator:()Ljava/util/Iterator;
   #3 = InterfaceMethodref #33.#34        // java/util/Iterator.hasNext:()Z
   #4 = InterfaceMethodref #33.#35        // java/util/Iterator.next:()Ljava/lang/Object;
   #5 = Class              #36            // java/lang/Integer
   #6 = Methodref          #5.#37         // java/lang/Integer.intValue:()I
   #7 = Class              #38            // Test
   #8 = Class              #39            // java/lang/Object
   #9 = Utf8               <init>
  #10 = Utf8               ()V
  #11 = Utf8               Code
  #12 = Utf8               LineNumberTable
  #13 = Utf8               LocalVariableTable
  #14 = Utf8               this
  #15 = Utf8               LTest;
  #16 = Utf8               testForeach
  #17 = Utf8               (Ljava/util/List;)I
  #18 = Utf8               i
  #19 = Utf8               Ljava/lang/Integer;
  #20 = Utf8               list
  #21 = Utf8               Ljava/util/List;
  #22 = Utf8               val
  #23 = Utf8               I
  #24 = Utf8               LocalVariableTypeTable
  #25 = Utf8               Ljava/util/List<Ljava/lang/Integer;>;
  #26 = Utf8               Signature
  #27 = Utf8               (Ljava/util/List<Ljava/lang/Integer;>;)I
  #28 = Utf8               SourceFile
  #29 = Utf8               Test.java
  #30 = NameAndType        #9:#10         // "<init>":()V
  #31 = Class              #40            // java/util/List
  #32 = NameAndType        #41:#42        // iterator:()Ljava/util/Iterator;
  #33 = Class              #43            // java/util/Iterator
  #34 = NameAndType        #44:#45        // hasNext:()Z
  #35 = NameAndType        #46:#47        // next:()Ljava/lang/Object;
  #36 = Utf8               java/lang/Integer
  #37 = NameAndType        #48:#49        // intValue:()I
  #38 = Utf8               Test
  #39 = Utf8               java/lang/Object
  #40 = Utf8               java/util/List
  #41 = Utf8               iterator
  #42 = Utf8               ()Ljava/util/Iterator;
  #43 = Utf8               java/util/Iterator
  #44 = Utf8               hasNext
  #45 = Utf8               ()Z
  #46 = Utf8               next
  #47 = Utf8               ()Ljava/lang/Object;
  #48 = Utf8               intValue
  #49 = Utf8               ()I
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 3: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public int testForeach(java.util.List<java.lang.Integer>);
    descriptor: (Ljava/util/List;)I
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=5, args_size=2
         0: iconst_0
         1: istore_2
         2: aload_1
         3: invokeinterface #2,  1            // InterfaceMethod java/util/List.iterator:()Ljava/util/Iterator;
         8: astore_3
         9: aload_3
        10: invokeinterface #3,  1            // InterfaceMethod java/util/Iterator.hasNext:()Z
        15: ifeq          40
        18: aload_3
        19: invokeinterface #4,  1            // InterfaceMethod java/util/Iterator.next:()Ljava/lang/Object;
        24: checkcast     #5                  // class java/lang/Integer
        27: astore        4
        29: iload_2
        30: aload         4
        32: invokevirtual #6                  // Method java/lang/Integer.intValue:()I
        35: iadd
        36: istore_2
        37: goto          9
        40: iload_2
        41: ireturn
      LineNumberTable:
        line 5: 0
        line 6: 2
        line 7: 29
        line 8: 37
        line 9: 40
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
           29       8     4     i   Ljava/lang/Integer;
            0      42     0  this   LTest;
            0      42     1  list   Ljava/util/List;
            2      40     2   val   I
      LocalVariableTypeTable:
        Start  Length  Slot  Name   Signature
            0      42     1  list   Ljava/util/List<Ljava/lang/Integer;>;
    Signature: #27                          // (Ljava/util/List<Ljava/lang/Integer;>;)I
}
SourceFile: "Test.java"
```

__着重对testForeach方法的字节码进行分析__

* &lt;0: iconst_0&gt;：将整形 __常数0__ push到栈顶
* &lt;1: istore_2&gt;：将栈顶元素存入local variable 2，此处指的就是var变量
* &lt;2: aload_1&gt;：将local variable 1的引用push到栈顶，即将入参list的引用push到栈顶
* &lt;3: invokeinterface #2,  1&gt;：对栈顶元素执行#2符号引用所表示的接口方法，并将方法执行的结果push到栈顶，这里就是调用iterator方法并返回一个Iterator对象
* &lt;8: astore_3&gt;：将栈顶元素存入local variable 3，此处就是将Iterator对象存入局部变量表(虽然在代码中并没有体现)
* &lt;9: aload_3&gt;：将local variable 3的值push到栈顶，这里就是将Iterator对象的引用push到栈顶
* &lt;10: invokeinterface #3,  1&gt;：对栈顶元素执行#3符号引用所表示的接口方法，并将方法执行结果push到栈顶，这里就是调用Iterator#hasNext()方法，并返回一个boolean值
* &lt;15: ifeq          40&gt;：如果栈顶元素为0，则跳转到偏移量为40的字节码指令处
    * __以下为ifeq不成立时的执行逻辑__
    * &lt;18: aload_3&gt;：将local variable 3的值push到栈顶，这里就是将Iterator对象的引用push到栈顶
    * &lt;19: invokeinterface #4,  1&gt;：对栈顶元素执行#4符号引用所表示的接口方法，并将方法执行结果push到栈顶，这里就是调用Iterator#next()方法，并返回一个Object
    * &lt;24: checkcast     #5&gt;：取出栈顶元素，并强制转换成#5符号引用所表示的类型，并重新push到栈顶
    * &lt;27: astore        4&gt;：将栈顶元素存入local variable 4，此处就是将转型后的Integer的引用存入
    * &lt;29: iload_2&gt;：将local variable 2的值push到栈顶，这里指的就是变量var
    * &lt;30: aload         4&gt;：将local variable 4push到栈顶，这里就是将Integer引用push到栈顶
    * &lt;32: invokevirtual #6&gt;：对栈顶元素执行#6符号引用所表示的方法，并将方法执行结果push到栈顶，这里就是调用Integer.intValue()方法，返回一个int
    * &lt;35: iadd&gt;：取出栈顶和栈次顶元素相加，并将结果push到栈顶
    * &lt;36: istore_2&gt;：将栈顶元素存入local variable 2，此处指的就是变量var
    * &lt;37: goto          9&gt;：跳转到偏移量为9的字节码指令处
    * __以下为ifeq成立时的执行逻辑__
    * &lt;40: iload_2&gt;：将local variable 2的值push到栈顶，这里指的就是变量var
    * &lt;41: ireturn&gt;：将栈顶元素作为整形返回

__可以看出，for each本质上就是通过返回一个迭代器Iterator，并且通过hasNext以及next来进行循环操作__

## 4.2 方法调用字节码分析

### 4.2.1 调用接口方法
```Java
1 import java.util.List;
2 
3 public class Test {
4     public void invokeInterfaceMethod(List<Object> list) {
5         list.add(null);
6     }
7 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出

```
  Last modified Jun 21, 2017; size 592 bytes
  MD5 checksum 743755c9f90a51e1a5963c09fa0565f8
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #4.#22         // java/lang/Object."<init>":()V
   #2 = InterfaceMethodref #23.#24        // java/util/List.add:(Ljava/lang/Object;)Z
   #3 = Class              #25            // Test
   #4 = Class              #26            // java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Utf8               Code
   #8 = Utf8               LineNumberTable
   #9 = Utf8               LocalVariableTable
  #10 = Utf8               this
  #11 = Utf8               LTest;
  #12 = Utf8               invokeInterfaceMethod
  #13 = Utf8               (Ljava/util/List;)V
  #14 = Utf8               list
  #15 = Utf8               Ljava/util/List;
  #16 = Utf8               LocalVariableTypeTable
  #17 = Utf8               Ljava/util/List<Ljava/lang/Object;>;
  #18 = Utf8               Signature
  #19 = Utf8               (Ljava/util/List<Ljava/lang/Object;>;)V
  #20 = Utf8               SourceFile
  #21 = Utf8               Test.java
  #22 = NameAndType        #5:#6          // "<init>":()V
  #23 = Class              #27            // java/util/List
  #24 = NameAndType        #28:#29        // add:(Ljava/lang/Object;)Z
  #25 = Utf8               Test
  #26 = Utf8               java/lang/Object
  #27 = Utf8               java/util/List
  #28 = Utf8               add
  #29 = Utf8               (Ljava/lang/Object;)Z
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 3: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public void invokeInterfaceMethod(java.util.List<java.lang.Object>);
    descriptor: (Ljava/util/List;)V
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=2, args_size=2
         0: aload_1
         1: aconst_null
         2: invokeinterface #2,  2            // InterfaceMethod java/util/List.add:(Ljava/lang/Object;)Z
         7: pop
         8: return
      LineNumberTable:
        line 5: 0
        line 6: 8
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       9     0  this   LTest;
            0       9     1  list   Ljava/util/List;
      LocalVariableTypeTable:
        Start  Length  Slot  Name   Signature
            0       9     1  list   Ljava/util/List<Ljava/lang/Object;>;
    Signature: #19                          // (Ljava/util/List<Ljava/lang/Object;>;)V
}
SourceFile: "Test.java"
```
__着重对invokeInterfaceMethod方法的字节码进行分析__

* &lt;0: aload_1&gt;：将local variable 1的引用push到栈顶，此处就是将方法的入参list push到栈顶
* &lt;1: aconst_null&gt;：将null push到栈顶
* &lt;__2: invokeinterface #2,  2__&gt;： __对次顶元素调用#2符号引用所代表的接口方法，并将栈顶元素作为入参__。方法返回结果push到栈顶
* &lt;7: pop&gt;：弹出栈顶元素
* &lt;8: return&gt;：返回

### 4.2.2 调用静态方法
```Java
1 public class Test {
2     public static void staticMethod(int i) {}
3     public void invokeStaticMethod() {
4         staticMethod(1);
5     }
6 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出

```
  Last modified Jun 21, 2017; size 420 bytes
  MD5 checksum a1809274672fdce26c74996446daf497
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #4.#19         // java/lang/Object."<init>":()V
   #2 = Methodref          #3.#20         // Test.staticMethod:(I)V
   #3 = Class              #21            // Test
   #4 = Class              #22            // java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Utf8               Code
   #8 = Utf8               LineNumberTable
   #9 = Utf8               LocalVariableTable
  #10 = Utf8               this
  #11 = Utf8               LTest;
  #12 = Utf8               staticMethod
  #13 = Utf8               (I)V
  #14 = Utf8               i
  #15 = Utf8               I
  #16 = Utf8               invokeStaticMethod
  #17 = Utf8               SourceFile
  #18 = Utf8               Test.java
  #19 = NameAndType        #5:#6          // "<init>":()V
  #20 = NameAndType        #12:#13        // staticMethod:(I)V
  #21 = Utf8               Test
  #22 = Utf8               java/lang/Object
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public static void staticMethod(int);
    descriptor: (I)V
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=0, locals=1, args_size=1
         0: return
      LineNumberTable:
        line 2: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       1     0     i   I

  public void invokeStaticMethod();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: iconst_1
         1: invokestatic  #2                  // Method staticMethod:(I)V
         4: return
      LineNumberTable:
        line 4: 0
        line 5: 4
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;
}
SourceFile: "Test.java"
```

__着重对invokeStaticMethod方法的字节码进行分析__

* &lt;0: iconst_1&gt;：0: iconst_1：将 __常数0__ push到栈顶
* &lt;1: invokestatic  #2&gt;：调用#2符号引用所表示的静态方法
* &lt;4: return&gt;：返回

__对比invokeinterface字节码指令，invokestatic少了一个表示操作数数量的参数__，因为静态方法不需要调用对象，而非静态方法需要指定调用对象。因此invokeinterface字节码必须确定方法调用所需要的操作数数量，最下面的操作数就是调用对象的引用

### 4.2.3 调用private方法
```Java
1 public class Test {
2    private void privateMethod(int i) {}
3    public void invokePrivateMethod() {
4         privateMethod(1);
5     }
6 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出

```
  Last modified Jun 21, 2017; size 433 bytes
  MD5 checksum 74872d7701be5f85281991b341c63cb1
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #4.#19         // java/lang/Object."<init>":()V
   #2 = Methodref          #3.#20         // Test.privateMethod:(I)V
   #3 = Class              #21            // Test
   #4 = Class              #22            // java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Utf8               Code
   #8 = Utf8               LineNumberTable
   #9 = Utf8               LocalVariableTable
  #10 = Utf8               this
  #11 = Utf8               LTest;
  #12 = Utf8               privateMethod
  #13 = Utf8               (I)V
  #14 = Utf8               i
  #15 = Utf8               I
  #16 = Utf8               invokePrivateMethod
  #17 = Utf8               SourceFile
  #18 = Utf8               Test.java
  #19 = NameAndType        #5:#6          // "<init>":()V
  #20 = NameAndType        #12:#13        // privateMethod:(I)V
  #21 = Utf8               Test
  #22 = Utf8               java/lang/Object
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public void invokePrivateMethod();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=1, args_size=1
         0: aload_0
         1: iconst_1
         2: invokespecial #2                  // Method privateMethod:(I)V
         5: return
      LineNumberTable:
        line 4: 0
        line 5: 5
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       6     0  this   LTest;
}
SourceFile: "Test.java"
```

__着重对invokePrivateMethod方法的字节码进行分析__

* &lt;0: aload_0&gt;：将local variable 0 push到栈顶，这里指的就是this
* &lt;1: iconst_1&gt;：将 __常数1__ push到栈顶
* &lt;2: invokespecial #2&gt;：调用#2符号引用所表示的方法，并将结果push到栈顶
* &lt;5: return&gt;：返回

## 4.3 synchronized字节码分析

### 4.3.1 synchronized修饰的方法
```Java
1 public class Test {
2    public synchronized void synchronizedMethod(int i) {}
3     public void invokeSynchronizedMethod() {
4         synchronizedMethod(1);
5     }
6 }
```

执行 __javap -c -v .\Test.class__ 得到以下输出

```
  Last modified Jun 21, 2017; size 443 bytes
  MD5 checksum 146a5267512761084351997ca83334bd
  Compiled from "Test.java"
public class Test
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #4.#19         // java/lang/Object."<init>":()V
   #2 = Methodref          #3.#20         // Test.synchronizedMethod:(I)V
   #3 = Class              #21            // Test
   #4 = Class              #22            // java/lang/Object
   #5 = Utf8               <init>
   #6 = Utf8               ()V
   #7 = Utf8               Code
   #8 = Utf8               LineNumberTable
   #9 = Utf8               LocalVariableTable
  #10 = Utf8               this
  #11 = Utf8               LTest;
  #12 = Utf8               synchronizedMethod
  #13 = Utf8               (I)V
  #14 = Utf8               i
  #15 = Utf8               I
  #16 = Utf8               invokeSynchronizedMethod
  #17 = Utf8               SourceFile
  #18 = Utf8               Test.java
  #19 = NameAndType        #5:#6          // "<init>":()V
  #20 = NameAndType        #12:#13        // synchronizedMethod:(I)V
  #21 = Utf8               Test
  #22 = Utf8               java/lang/Object
{
  public Test();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
      LineNumberTable:
        line 1: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LTest;

  public synchronized void synchronizedMethod(int);
    descriptor: (I)V
    flags: ACC_PUBLIC, ACC_SYNCHRONIZED
    Code:
      stack=0, locals=2, args_size=2
         0: return
      LineNumberTable:
        line 2: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       1     0  this   LTest;
            0       1     1     i   I

  public void invokeSynchronizedMethod();
    descriptor: ()V
    flags: ACC_PUBLIC
    Code:
      stack=2, locals=1, args_size=1
         0: aload_0
         1: iconst_1
         2: invokevirtual #2                  // Method synchronizedMethod:(I)V
         5: return
      LineNumberTable:
        line 4: 0
        line 5: 5
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       6     0  this   LTest;
}
SourceFile: "Test.java"
```

__着重对invokeSynchronizedMethod方法的字节码进行分析__

* &lt;0: aload_0&gt;：将local variable 0 push到栈顶，这里指的就是this
* &lt;1: iconst_1&gt;：将 __常数1__ push到栈顶
* &lt;2: invokevirtual #2&gt;：调用#2符号引用所表示的方法，并将方法执行结果push到栈顶
* &lt;5: return&gt;：返回

__很奇怪，在字节码中并没有发现monitorenter与monitorexit，那么这两个字节码何时会插入呢__

### 4.3.2 synchronized块
__以一个单例模式为例子，其中父类Base，接口Interface1和Interface2是空类以及空接口__
```Java
1  public class Singleton extends Base implements Interface1,Interface2{
2      private static volatile Singleton instance;
3 
4      private Singleton(){}
5 
6      public static Singleton getSingleton(){
7          if(instance==null){
8              synchronized (Singleton.class){
9                  if(instance==null){
10                     instance=new Singleton();
11                 }
12             }
13         }
14         return instance;
15     }
16 }
```

执行命令 __javap -c -l -verbose Singleton.class__ 后得到以下输出

```
  Last modified Jun 20, 2017; size 456 bytes
  MD5 checksum a3a903928f93299240809723a6576a86
  Compiled from "Singleton.java"
public class Singleton extends Base implements Interface1,Interface2
  minor version: 0
  major version: 49
  flags: ACC_PUBLIC, ACC_SUPER
Constant pool:
   #1 = Methodref          #5.#20         // Base."<init>":()V
   #2 = Fieldref           #3.#21         // Singleton.instance:LSingleton;
   #3 = Class              #22            // Singleton
   #4 = Methodref          #3.#20         // Singleton."<init>":()V
   #5 = Class              #23            // Base
   #6 = Class              #24            // Interface1
   #7 = Class              #25            // Interface2
   #8 = Utf8               instance
   #9 = Utf8               LSingleton;
  #10 = Utf8               <init>
  #11 = Utf8               ()V
  #12 = Utf8               Code
  #13 = Utf8               LineNumberTable
  #14 = Utf8               LocalVariableTable
  #15 = Utf8               this
  #16 = Utf8               getSingleton
  #17 = Utf8               ()LSingleton;
  #18 = Utf8               SourceFile
  #19 = Utf8               Singleton.java
  #20 = NameAndType        #10:#11        // "<init>":()V
  #21 = NameAndType        #8:#9          // instance:LSingleton;
  #22 = Utf8               Singleton
  #23 = Utf8               Base
  #24 = Utf8               Interface1
  #25 = Utf8               Interface2
{
  private static volatile Singleton instance;
    descriptor: LSingleton;
    flags: ACC_PRIVATE, ACC_STATIC, ACC_VOLATILE

  private Singleton();
    descriptor: ()V
    flags: ACC_PRIVATE
    Code:
      stack=1, locals=1, args_size=1
         0: aload_0
         1: invokespecial #1                  // Method Base."<init>":()V
         4: return
      LineNumberTable:
        line 4: 0
      LocalVariableTable:
        Start  Length  Slot  Name   Signature
            0       5     0  this   LSingleton;

  public static Singleton getSingleton();
    descriptor: ()LSingleton;
    flags: ACC_PUBLIC, ACC_STATIC
    Code:
      stack=2, locals=2, args_size=0
         0: getstatic     #2                  // Field instance:LSingleton;
         3: ifnonnull     37
         6: ldc           #3                  // class Singleton
         8: dup
         9: astore_0
        10: monitorenter
        11: getstatic     #2                  // Field instance:LSingleton;
        14: ifnonnull     27
        17: new           #3                  // class Singleton
        20: dup
        21: invokespecial #4                  // Method "<init>":()V
        24: putstatic     #2                  // Field instance:LSingleton;
        27: aload_0
        28: monitorexit
        29: goto          37
        32: astore_1
        33: aload_0
        34: monitorexit
        35: aload_1
        36: athrow
        37: getstatic     #2                  // Field instance:LSingleton;
        40: areturn
      Exception table:
         from    to  target type
            11    29    32   any
            32    35    32   any
      LineNumberTable:
        line 7: 0
        line 8: 6
        line 9: 11
        line 10: 17
        line 12: 27
        line 14: 37
}
SourceFile: "Singleton.java"
```

__javap对于class文件的解析是根据java源文件的书写顺序来展现的，这是为了便于我们的理解，所以解析结果出现的顺序与上述介绍的Class文件结构并不一致__

* 最开始是minor version以及major version
* 紧跟着的是flags(访问标志)，Singleton的访问标志有ACC_PUBLIC(即public)，和ACC_SUPER(是否允许使用invokespecial字节码指令的新语意，invokespecial指令的语意在JDK 1.0.2发生过改变，为了区别这条指令使用哪种语意，JDK 1.0.2之后编译出来的类的这个标志都必须为真)
* 然后是常量池：常量池中包含了大量的字符串，以及方法，字段等等的符号引用。其中符号引用采用的是常量池中的字符串拼接而成，这样表示是为了提高字符串的重用率。
* 接下来是字段的描述符以及访问标志
* 然后是私有的构造方法的描述符、访问标志以及Code属性表
* 最后是getSingleton方法的描述符、访问标志以及Code属性表

__着重对getSingleton方法的字节码进行分析__

* &lt;0: getstatic     #2&gt;：getstatic获取类的静态字段，其中字段由常量池的符号引用表示，并push到操作数栈
* &lt;3: ifnonnull     37&gt;：判断栈顶元素是否为null，如果不是null则跳转到偏移量为37的字节码指令处，指令结束后，栈顶元素出栈
    * __以下为ifnonnull不成立时的执行逻辑__
    * &lt;6: ldc           #3&gt;：ldc从常量池中将一个(String, int, float, Class, java.lang.invoke.MethodType, or java.lang.invoke.MethodHandle) ，这里指的应该是Class对象，push 到操作数栈(stack)
    * &lt;8: dup&gt;：复制栈顶元素，并将副本入栈
    * &lt;9: astore_0&gt;：弹出栈顶元素，并存入local variable 0(???)
    * &lt;10: monitorenter&gt;：进入synchronized代码块，必须与monitorexit成对出现
    * &lt;11: getstatic     #2&gt;：getstatic获取类的静态字段，其中字段由常量池的符号引用表示，并push到操作数栈
    * &lt;14: ifnonnull     27&gt;：判断栈顶元素是否为null，如果不是null则跳转到偏移量为27的字节码指令处，指令结束后，栈顶元素出栈
        * __以下为ifnonnull不成立时的执行逻辑__
        * &lt;17: new           #3&gt;：根据常量池的符号引用，创建相应的对象，并push到操作数栈
        * &lt;20: dup&gt;：复制栈顶元素，并将副本入栈。__该条字节码通常与new成对出现，由于之后会执行invokespecial字节码来进行初始化操作，该字节码会消耗栈顶元素，为了在初始化完毕后操作数栈还保留着new出来的对象的引用，于是这里进行一次dup__
        * &lt;21: invokespecial #4&gt;：调用符号引用所指定的方法
        * &lt;24: putstatic     #2&gt;：将栈顶元素存入指定静态域
        * &lt;27: aload_0&gt;：将local variable 0存入操作数栈
        * &lt;28: monitorexit&gt;：退出synchronized代码块，__该字节码必须与monitorenter成对出现，保证代码在任何情况下退出(正常执行，或抛出异常)都可以正常释放锁__
        * &lt;29: goto          37&gt;：跳转到偏移量为37的字节码指令处，该字节码不改变操作数栈
        * &lt;37: getstatic     #2&gt;：getstatic获取类的静态字段，其中字段由常量池的符号引用表示，并push到操作数栈
        * &lt;40: areturn&gt;：返回操作数顶部元素，方法结束
        * __以下为ifnonnull成立时的执行逻辑__
        * &lt;27: aload_0&gt;：将local variable 0存入操作数栈
        * &lt;28: monitorexit&gt;：退出synchronized代码块，__该字节码必须与monitorenter成对出现，保证代码在任何情况下退出(正常执行，或抛出异常)都可以正常释放锁__
        * &lt;29: goto          37&gt;：跳转到偏移量为37的字节码指令处，该字节码不改变操作数栈
        * &lt;37: getstatic     #2&gt;：getstatic获取类的静态字段，其中字段由常量池的符号引用表示，并push到操作数栈
        * &lt;40: areturn&gt;：返回操作数顶部元素，方法结束

    * __以下为ifnonnull成立时的执行逻辑__
    * &lt;37: getstatic     #2&gt;：getstatic获取类的静态字段，其中字段由常量池的符号引用表示，并push到操作数栈
    * &lt;40: areturn&gt;：返回操作数顶部元素，方法结束

__Exception table该如何解读__
