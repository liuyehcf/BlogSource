---
title: Scripting-Language
date: 2017-12-02 15:45:01
tags: 
- 摘录
categories: 
- Computer Concept
---

**阅读更多**

<!--more-->

# 1 语言种类

计算机不能直接理解高级语言，只能直接理解机器语言，所以必须要把高级语言翻译成机器语言，计算机才能执行高级语言编写的程序

把高级语言翻译成机器语言的两种方式：**一种是编译，一种是解释。两种方式只是翻译的时间不通。**

## 1.1 编译型语言

编译型语言写的程序执行之前，需要一个专门的编译过程，把程序编译成为机器语言的文件，比如exe文件，以后要运行的话就不用重新翻译了，直接使用编译的结果就行了（exe文件），因为翻译只做了一次，运行时不需要翻译，所以编译型语言的程序执行效率高，但也不能一概而论，部分解释型语言的解释器通过在运行时动态优化代码，甚至能够使解释型语言的性能超过编译型语言

编译型语言最典型的例子就是C语言

## 1.2 解释性语言

解释则不同，解释性语言的程序不需要编译，省了道工序，解释性语言在运行程序的时候才翻译，比如解释性Basic语言，专门有一个解释器能够直接执行Basic程序，每个语句都是执行的时候才翻译。这样解释性语言每执行一次就要翻译一次，效率比较低。解释是一句一句的翻译

**此外，随着Java等基于虚拟机的语言的兴起，我们又不能把语言纯粹地分成解释型和编译型这两种**。Java首先是通过编译器编译成字节码文件，然后在运行时通过解释器给解释成机器文件。所以我们说Java是一种**先编译后解释**的语言

再换成C#，C#首先是通过编译器将C#文件编译成IL文件，然后在通过CLR将IL文件编译成机器文件。所以我们说C#是一门**纯编译语言**，但是C#是一门需要二次编译的语言。同理也可等效运用到基于.NET平台上的其他语言

## 1.3 脚本语言

**脚本语言是一种解释性的语言**。脚本语言又被称为扩建的语言，或者动态语言，脚本语言不需要编译，可以直接用，由解释器来负责解释。脚本语言一般都是以文本形式存在，类似于一种命令

举个例子说，如果你建立了一个程序，叫`func.exe`，可以打开`.aa`为扩展名的文件。你为`.aa`文件的编写指定了一套规则(语法)，当别人编写了`.aa`文件后，你的程序用这种规则来理解编写人的意图，并作出回应。那么，这一套规则就是脚本语言

脚本语言是一种**不需要明确编译步骤**的编程语言

* 对于C语言源代码来说，我们在运行之前，首先要将源代码编译成可执行文件；对于JavaScript来说，我们可以直接运行它的源代码而不需要进行编译的操作。因此C语言被称为编译型语言，而JavaScript被称为脚本语言
* 这条分界线将随着硬件以及编译器的发展变得越来越模糊，因为编译过程变得非常快。例如，JavaScript的引擎V8会将JavaScript编译成二进制机器码然后再执行，而非解释执行
* 另外，**一种语言是否被称为脚本语言取决于环境而非语言本身**。例如，我们完全可以写一个C语言的解释器，然后将C语言当成一种脚本语言来用；也可以写一个JavaScript的编译器，然后将JavaScript当成一种编译型语言来用

### 1.3.1 解释型语言是不是完全等同于脚本语言? 

何为解释型语言？典型的是Java，凡是运行Java作的程序都得装个虚拟机(JRE),这个JRE就是解释器。脚本，我比较熟悉的是Perl，也是典型的解释型语言。但是显然Java不是脚本语言，脚本语言的特征主要有无类型、无内存管理等等，功能较弱，但是使用方便

# 2 常见的脚本语言

1. Lua
1. JavaScript
1. VBScript and VBA
1. Perl

# 3 常见的编译型语言

1. C
1. C++
1. D
1. Java
    * 需要注意的是，Java编译产生的是字节码，字节码会通过解释器解释执行或者通过JIT编译执行

# 4 参考

* [Scripting Language vs Programming Language](https://stackoverflow.com/questions/17253545/scripting-language-vs-programming-language)
* [编译型语言、解释型语言、脚本语言的区别](http://blog.csdn.net/u011026329/article/details/51119402)