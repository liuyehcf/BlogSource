---
title: Linux-虚拟化
date: 2021-02-22 13:55:07
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 简介

## 1.1 什么是虚拟化（virtualization）？

虚拟化技术可以帮助我们创建基于软件的计算机资源，包括CPU、存储、网络等等

借助虚拟化技术，可以将单个物理计算机或服务器划分为多个虚拟机（VM）。在同一个硬件资源上，每个VM可以独立运行不同的操作系统以及应用软件

## 1.2 虚拟化发展史

计算虚拟化发展有几个关键节点。虚拟化技术最早60年代中期年在IBM大型机上实现，当时主流大型虚拟化有`IBM Z/VM`与`KVM for Z Systems`。80年代IBM与HP开始研究面向UNIX小型机虚拟化，当时主流的有`IBM PowerVM`与`HP vPar`，`IVM`等。1999年VMware推出针对x86服务器虚拟化，当时主流x86虚拟化有`VMware ESXi`、`Microsoft Hyper-V`，以及开源的`KVM`和`Xen`。2006年Intel和AMD推出硬件辅助虚拟化技术`Intel-VT`，`AMD-V`将部分需要通过软件来实现的虚拟化功能进行硬件化，大幅提升虚拟化的性能。容器作为一种更加轻量的应用级虚拟化技术，最早于1979年提出，不过2013年推出docker解决了标准化与可移植等问题，目前已成为最流行的容器技术。基于x86服务器的虚拟化技术对云计算发展发挥了重要作用，接下来将重点介绍

![milestone](/images/Linux-虚拟化/milestone.jpg)

## 1.3 参考

* [Introduction to Virtualization](https://www.baeldung.com/cs/virtualization-intro)
* [Virtualization](https://www.ibm.com/cloud/learn/virtualization-a-complete-guide#toc-hypervisor-UrK7TB8Y)
* [PC架构系列：CPU/RAM/IO总线的发展历史！](https://blog.csdn.net/xport/article/details/1387928)
* [CPU 的工作原理是什么？](https://www.zhihu.com/question/40571490)
* [计算机如何执行一条机器指令](https://blog.csdn.net/gexiaoyizhimei/article/details/102497589)
* [虚拟化技术 - CPU虚拟化](https://zhuanlan.zhihu.com/p/69625751)
* [计算虚拟化详解](https://zhuanlan.zhihu.com/p/100526650)

# 2 汇编语言

计算机真正能够理解的是低级语言，它专门用来控制硬件。汇编语言就是低级语言，直接描述/控制CPU 的运行。如果你想了解CPU到底干了些什么，以及代码的运行步骤，就一定要学习汇编语言。另外，学习汇编语言也能帮助我们更好地理解虚拟化过程

## 2.1 汇编语言是什么？

我们知道，CPU只负责计算，本身不具备智能。你输入一条指令（instruction），它就运行一次，然后停下来，等待下一条指令

这些指令都是二进制的，称为操作码（`opcode`），比如加法指令就是`00000011`。编译器的作用，就是将高级语言写好的程序，翻译成一条条操作码

对于人类来说，二进制程序是不可读的，根本看不出来机器干了什么。为了解决可读性的问题，以及偶尔的编辑需求，就诞生了汇编语言

汇编语言是二进制指令的文本形式，与指令是一一对应的关系。比如，加法指令`00000011`写成汇编语言就是`ADD`。只要还原成二进制，汇编语言就可以被CPU直接执行，所以它是最底层的低级语言

## 2.2 来历

最早的时候，编写程序就是手写二进制指令，然后通过各种开关输入计算机，比如要做加法了，就按一下加法开关。后来，发明了纸带打孔机，通过在纸带上打孔，将二进制指令自动输入计算机

为了解决二进制指令的可读性问题，工程师将那些指令写成了八进制。二进制转八进制是轻而易举的，但是八进制的可读性也不行。很自然地，最后还是用文字表达，加法指令写成`ADD`。内存地址也不再直接引用，而是用标签表示

这样的话，就多出一个步骤，要把这些文字指令翻译成二进制，这个步骤就称为`assembling`，完成这个步骤的程序就叫做`assembler`。它处理的文本，自然就叫做`aseembly code`。标准化以后，称为`assembly language`，缩写为`asm`，中文译为汇编语言

每一种CPU的机器指令都是不一样的，因此对应的汇编语言也不一样。本文介绍的是目前最常见的x86汇编语言，即Intel公司的CPU使用的那一种

## 2.3 寄存器

**更多内容请参考{% post_link 寄存器 %}**

学习汇编语言，首先必须了解两个知识点：寄存器和内存模型

先来看寄存器。CPU本身只负责运算，不负责储存数据。数据一般都储存在内存之中，CPU要用的时候就去内存读写数据。但是，CPU的运算速度远高于内存的读写速度，为了避免被拖慢，CPU都自带一级缓存和二级缓存。基本上，CPU缓存可以看作是读写速度较快的内存

但是，CPU缓存还是不够快，另外数据在缓存里面的地址是不固定的，CPU每次读写都要寻址也会拖慢速度。因此，除了缓存之外，CPU还自带了寄存器（`register`），用来储存最常用的数据。也就是说，那些最频繁读写的数据（比如循环变量），都会放在寄存器里面，CPU优先读写寄存器，再由寄存器跟内存交换数据

![asm_register](/images/Linux-虚拟化/asm_register.png)

寄存器不依靠地址区分数据，而依靠名称。每一个寄存器都有自己的名称，我们告诉CPU去具体的哪一个寄存器拿数据，这样的速度是最快的。有人比喻寄存器是CPU的零级缓存

## 2.4 寄存器的种类

早期的x86 CPU只有8个寄存器，而且每个都有不同的用途。现在的寄存器已经有100多个了，都变成通用寄存器，不特别指定用途了，但是早期寄存器的名字都被保存了下来

* EAX：通用寄存器
* EBX：通用寄存器
* ECX：通用寄存器
* EDX：通用寄存器
* EDI：通用寄存器
* ESI：通用寄存器
* EBP：通用寄存器
* **ESP：保存当前Stack的地址**

**我们常常看到32位CPU、64位CPU这样的名称，其实指的就是寄存器的大小。32位CPU的寄存器大小就是4个字节**

## 2.5 内存模型：Heap

寄存器只能存放很少量的数据，大多数时候，CPU要指挥寄存器，直接跟内存交换数据。所以，除了寄存器，还必须了解内存怎么储存数据

程序运行的时候，操作系统会给它分配一段内存，用来储存程序和运行产生的数据。这段内存有起始地址和结束地址，比如从`0x1000`到`0x8000`，起始地址是较小的那个地址，结束地址是较大的那个地址

![asm_mem_heap](/images/Linux-虚拟化/asm_mem_heap.png)

程序运行过程中，对于动态的内存占用请求（比如新建对象，或者使用`malloc`命令），系统就会从预先分配好的那段内存之中，划出一部分给用户，具体规则是从起始地址开始划分（实际上，起始地址会有一段静态数据，这里忽略）。举例来说，用户要求得到10个字节内存，那么从起始地址`0x1000`开始给他分配，一直分配到地址`0x100A`，如果再要求得到22个字节，那么就分配到`0x1020`

这种因为用户主动请求而划分出来的内存区域，叫做`Heap（堆）`。它由起始地址开始，从低位（地址）向高位（地址）增长。`Heap`的一个重要特点就是不会自动消失，必须手动释放，或者由垃圾回收机制来回收

## 2.6 内存模型：Stack

除了`Heap`以外，其他的内存占用叫做`Stack（栈）`。简单说，`Stack`是由于函数运行而临时占用的内存区域

![asm_mem_stack](/images/Linux-虚拟化/asm_mem_stack.png)

```c
int main() {
   int a = 2;
   int b = 3;
}
```

上面代码中，系统开始执行`main`函数时，会为它在内存里面建立一个`帧（frame）`，所有`main`的内部变量（比如`a`和`b`）都保存在这个帧里面。`main`函数执行结束后，该帧就会被回收，释放所有的内部变量，不再占用空间

![asm_mem_stack_main](/images/Linux-虚拟化/asm_mem_stack_main.png)

如果函数内部调用了其他函数，会发生什么情况？

```c
int main() {
   int a = 2;
   int b = 3;
   return add_a_and_b(a, b);
}
```

上面代码中，`main`函数内部调用了`add_a_and_b`函数。执行到这一行的时候，系统也会为`add_a_and_b`新建一个帧，用来储存它的内部变量。也就是说，此时同时存在两个帧：`main`和`add_a_and_b`。一般来说，调用栈有多少层，就有多少帧

![asm_mem_stack_main_addab](/images/Linux-虚拟化/asm_mem_stack_main_addab.png)

等到`add_a_and_b`运行结束，它的帧就会被回收，系统会回到函数`main`刚才中断执行的地方，继续往下执行。通过这种机制，就实现了函数的层层调用，并且每一层都能使用自己的本地变量

所有的帧都存放在`Stack`，由于帧是一层层叠加的，所以`Stack`叫做栈。生成新的帧，叫做`入栈`，英文是`push`；栈的回收叫做`出栈`，英文是`pop`。`Stack`的特点就是，最晚入栈的帧最早出栈（因为最内层的函数调用，最先结束运行），这就叫做`后进先出`的数据结构。每一次函数执行结束，就自动释放一个帧，所有函数执行结束，整个`Stack`就都释放了

![asm_mem_stack_push](/images/Linux-虚拟化/asm_mem_stack_push.jpg)

![asm_mem_stack_pop](/images/Linux-虚拟化/asm_mem_stack_pop.jpg)

`Stack`是由内存区域的结束地址开始，从高位（地址）向低位（地址）分配。比如，内存区域的结束地址是`0x8000`，第一帧假定是`16`字节，那么下一次分配的地址就会从`0x7FF0`开始；第二帧假定需要`64`字节，那么地址就会移动到`0x7FB0`

![asm_mem_stack_address](/images/Linux-虚拟化/asm_mem_stack_address.png)

## 2.7 参考

* [汇编语言入门教程](http://www.ruanyifeng.com/blog/2018/01/assembly-language-primer.html)
* [一口气看完45个寄存器，CPU核心技术大揭秘](https://zhuanlan.zhihu.com/p/272135463?utm_source=qzone)

# 3 CPU虚拟化

**x86操作系统是设计在直接运行在裸硬件设备上的，因此它们自动认为它们完全占有计算机硬件**。x86架构提供四个特权级别给操作系统和应用程序来访问硬件。`Ring`是指CPU的运行级别，`Ring 0`是最高级别，`Ring 1`次之，`Ring 2`再次之

操作系统（内核）需要直接访问硬件和内存，因此它的代码需要运行在最高运行级别`Ring0`上，这样它可以使用特权指令，控制中断、修改页表、访问设备等等。 
应用程序的代码运行在最低运行级别上`Ring 3`上，不能做受控操作。如果要做，比如要访问磁盘，写文件，那就要通过执行系统调用（函数），执行系统调用的时候，CPU的运行级别会发生从`Ring 3`到`Ring 0`的切换，并跳转到系统调用对应的内核代码位置执行，这样内核就为你完成了设备访问，完成之后再从`Ring 0`返回`Ring 3`。这个过程也称作用户态和内核态的切换

![cpu_normal](/images/Linux-虚拟化/cpu_normal.jpg)

**那么，虚拟化在这里就遇到了一个难题，因为宿主操作系统是工作在`Ring 0`的，客户操作系统就不能也在`Ring 0`了，但是它不知道这一点，以前执行什么指令，现在还是执行什么指令，但是没有执行权限是会出错的。所以这时候虚拟机管理程序（`VMM`）需要避免这件事情发生。 虚机怎么通过`VMM`实现 `Guest CPU`对硬件的访问，根据其原理不同有三种实现技术：**

1. 全虚拟化
2. 半虚拟化
3. 硬件辅助的虚拟化 

## 3.1 基于二进制翻译的全虚拟化（Full Virtualization with Binary Translation）

![cpu_full](/images/Linux-虚拟化/cpu_full.jpg)

客户操作系统运行在`Ring 1`，它在执行特权指令时，会触发异常（CPU的机制，没权限的指令会触发异常），然后`VMM`捕获这个异常，在异常里面做翻译，模拟，最后返回到客户操作系统内，客户操作系统认为自己的特权指令工作正常，继续运行。但是这个性能损耗，就非常的大，简单的一条指令，执行完，了事，现在却要通过复杂的异常处理过程。

异常「捕获（trap）-翻译（handle）-模拟（emulate）」过程：

![cpu_full_progress](/images/Linux-虚拟化/cpu_full_progress.jpg)

**为什么`VMM`可以捕获到`Guest OS`执行特权指令时触发的异常？**

> 中断向量表中记录了每个异常/中断所对应的处理程序，该中断表的首地址记录在`idtr`寄存器中，但是当`Guest OS`在执行的时候，`idtr`是中记录的是`Guest OS`的线性地址。但是`Guest OS`中的所有线性地址，都通过「影子页表」被`Host OS`接管了，因此，中断向量表也是可以被`Host OS`完全管控的（这是我的猜测）

## 3.2 超虚拟化（或者半虚拟化/操作系统辅助虚拟化 Paravirtualization） 

半虚拟化的思想就是，修改操作系统内核，替换掉不能虚拟化的指令，通过超级调用（hypercall）直接和底层的虚拟化层`hypervisor`来通讯，`hypervisor`同时也提供了超级调用接口来满足其他关键内核操作，比如内存管理、中断和时间保持

这种做法省去了全虚拟化中的捕获和模拟，大大提高了效率。所以像XEN这种半虚拟化技术，客户机操作系统都是有一个专门的定制内核版本，和x86、mips、arm这些内核版本等价。这样以来，就不会有捕获异常、翻译、模拟的过程了，性能损耗非常低。这就是XEN这种半虚拟化架构的优势。这也是为什么XEN只支持虚拟化Linux，无法虚拟化windows原因，微软不改代码啊

![cpu_half](/images/Linux-虚拟化/cpu_half.jpg)

## 3.3 硬件辅助的全虚拟化 

2005年后，CPU厂商Intel和AMD开始支持虚拟化了。Intel引入了`Intel-VT （Virtualization Technology）`技术。 这种CPU，有`VMX root operation`和`VMX non-root operation`两种模式，两种模式都支持`Ring 0` ~ `Ring 3`共 4 个运行级别。这样，`VMM`可以运行在`VMX root operation`模式下，客户`OS`运行在VMX `non-root operation`模式下

![cpu_full_with_hardware](/images/Linux-虚拟化/cpu_full_with_hardware.jpg)

而且两种操作模式可以互相转换。运行在`VMX root operation`模式下的`VMM`通过显式调用`VMLAUNCH`或`VMRESUME`指令切换到`VMX non-root operation`模式，硬件自动加载`Guest OS`的上下文，于是`Guest OS`获得运行，这种转换称为`VM entry`。`Guest OS`运行过程中遇到需要`VMM`处理的事件，例如外部中断或缺页异常，或者主动调用`VMCALL`指令调用`VMM`的服务的时候（与系统调用类似），硬件自动挂起`Guest OS`，切换到`VMX root operation`模式，恢复`VMM`的运行，这种转换称为`VM exit`。`VMX root operation`模式下软件的行为与在没有`VT-x`技术的处理器上的行为基本一致；而`VMX non-root operation`模式则有很大不同，最主要的区别是此时运行某些指令或遇到某些事件时，发生`VM exit`
 
也就说，硬件这层就做了些区分，这样全虚拟化下，那些靠「捕获异常-翻译-模拟」的实现就不需要了。而且CPU厂商，支持虚拟化的力度越来越大，靠硬件辅助的全虚拟化技术的性能逐渐逼近半虚拟化，再加上全虚拟化不需要修改客户操作系统这一优势，全虚拟化技术应该是未来的发展趋势

|  | 利用二进制翻译的全虚拟化 | 硬件辅助虚拟化 | 操作系统协助/半虚拟化 |
|:--|:--|:--|:--|
| 实现技术 | BT和直接执行 | 遇到特权指令转到root模式执行 | hypercall |
| 客户操作系统修改/兼容性 | 无需修改客户操作系统，最佳兼容性 | 无需修改客户操作系统，最佳兼容性 | 客户操作系统需要修改来支持hypercall，因此它不能运行在物理硬件本身或其他的hypervisor上，兼容性差，不支持Windows |
| 性能 | 差 | 全虚拟化下，CPU需要在两种模式之间切换，带来性能开销；但是，其性能在逐渐逼近半虚拟化 | 好。半虚拟化下CPU性能开销几乎为0，虚机的性能接近于物理机 |
| 应用厂商 | VMware Workstation/QEMU/Virtual PC | VMware ESXi/Microsoft Hyper-V/Xen 3.0/KVM | Xen |

## 3.4 参考

* [KVM 介绍（2）：CPU 和内存虚拟化](https://www.cnblogs.com/sammyliu/p/4543597.html)
* [KVM之CPU虚拟化](https://www.cnblogs.com/clsn/p/10175960.html)
* [分不清ARM和X86架构，别跟我说你懂CPU！](https://zhuanlan.zhihu.com/p/21266987)
* [CPU环，特权和保护](https://blog.csdn.net/langb2014/article/details/79372104)
* [CPU如何区分指令来自操作系统还是用户进程的？](https://www.zhihu.com/question/410762507)

## 3.5 问题

1. 访问内存需要在`Ring 0`上么？用户态程序也存在大量的内存读写，如何访问的？
1. 客户机的kernel为什么运行在`Ring 1`上，它不是应该认为自己跑在`Ring 0`上才对么，`Ring x`这个属性是谁赋予的？操作系统本身感知么？
   * 特权信息是记录在段选择因子（段式内存管理、段页式内存管理）中的，段描述符表GDT、LDT只有一个
   * 虚拟机的内核代码所在的段其实对应了`USER_CODE`以及`USER_DATA`（类似cr3，影子页表）
1. 普通程序在执行的过程中（用户态），需要操作系统参与吗？参与了哪些过程
1. 在内核态执行指令与在用户态执行指令有什么区别？为什么VMM能拦截到客户机的特权指令的执行？（`VMM`通过显式调用`VMLAUNCH`或`VMRESUME`）
1. 有操作系统和没有操作系统时，程序分别是如何执行的。对于有操作系统的情况下，操作系统对程序执行多了哪些干预操作？
1. `Ring x`这个信息记录在哪
1. Guest Machine本身并不感知自己跑在一个虚拟的环境中，但是CPU知道！！！

# 4 内存虚拟化

**内存管理相关知识点参考{% post_link Linux-内存管理 %}**

**本小节转载摘录自[虚拟化技术 - 内存虚拟化 [一]](https://zhuanlan.zhihu.com/p/69828213)**

大型操作系统（比如Linux）的内存管理的内容是很丰富的，而内存的虚拟化技术在OS内存管理的基础上又叠加了一层复杂性，比如我们常说的虚拟内存（virtual memory），如果使用虚拟内存的OS是运行在虚拟机中的，那么需要对虚拟内存再进行虚拟化，也就是`vitualizing virtualized memory`。本文将仅从「内存地址转换」和「内存回收」两个方面探讨内存虚拟化技术

在Linux这种使用虚拟地址的OS中，虚拟地址经过`page table`转换可得到物理地址

![memory_1](/images/Linux-虚拟化/memory_1.jpg)

如果这个操作系统是运行在虚拟机上的，那么这只是一个中间的物理地址（`Intermediate Phyical Address - IPA`），需要经过`VMM/hypervisor`的转换，才能得到最终的物理地址（`Host Phyical Address - HPA`）。从`VMM`的角度，`guest VM`中的虚拟地址就成了`GVA（Guest Virtual Address）`，`IPA`就成了`GPA（Guest Phyical Address）`

![memory_2](/images/Linux-虚拟化/memory_2.jpg)

可见，如果使用VMM，并且`guest VM`中的程序使用虚拟地址（如果`guest VM`中运行的是不支持虚拟地址的`RTOS（real time OS）`，则在虚拟机层面不需要地址转换），那么就需要两次地址转换

![memory_3](/images/Linux-虚拟化/memory_3.jpg)

**但是传统的`IA32`架构从硬件上只支持一次地址转换，即由`CR3`寄存器指向进程第一级页表的首地址，通过MMU查询进程的各级页表，获得物理地址**

针对`GVA->GPA->HPA`的两次转换的问题，存在2种解决方案

1. 软件实现「影子页表」
1. 硬件辅助「EPT/NPT」

**首先介绍「影子页表」的实现方式**

在一个运行Linux的`guest VM`中，每个进程有一个由内核维护的页表，用于`GVA->GPA`的转换，这里我们把它称作`gPT（guest Page Table）`。VMM层的软件会将`gPT`本身使用的物理页面设为`write protected`的，也就是说`gPT`的每次写操作都会触发`page fault`，该异常会被VM捕获，然后由VM来维护`gPT`的相关数据（该页表在VMM视角下，称为`sPT（shadow Page Table）`）。**「影子页表」是将`GVA-GPA`和`GPA-HPA`的两次转换合并成一次转换`GVA-HPA`，因此`gPT`和`sPT`指代的是同一个页表，只是视角不同而已**

1. 在`guest VM`的视角下，这就是一个普通的`page table`，负责将线性地址转换成物理地址（`GVA->GPA`），**`guest VM`并不知道这个页表的维护实际上是VMM负责的（被骗了）**
1. 在`VVM`的视角下，这就是一个影子页表`shadow page table`，它可以直接将虚拟机的虚拟地址转换成物理机的物理地址（`GVA->HPA`）

「影子页表」存在如下两个缺点：

1. 实现较为复杂，需要为每个`guest VM`中的每个进程的`gPT`都维护一个对应的`sPT`，增加了内存的开销
1. VMM使用的截获方法增多了`page fault`和`trap/vm-exit`的数量，加重了CPU的负担
   * 在一些场景下，这种影子页表机制造成的开销可以占到整个VMM软件负载的75%

![memory_4](/images/Linux-虚拟化/memory_4.jpg)

**在「影子页表」的方案中，CPU还是按照传统的方式来进行内存的寻址（一次转换），因此CPU并不感知**，为了更好的支持虚拟化，各大CPU厂商相继推出了硬件辅助的内存虚拟化技术，比如Intel的`EPT（Extended Page Table）`和AMD的`NPT（Nested Page Table）`，它们都能够从硬件上同时支持`GVA->GPA`和`GPA->HPA`的地址转换的技术

`GVA->GPA`的转换依然是通过查找`gPT`页表完成的，而`GPA->HPA`的转换则通过查找`nPT`页表来实现，每个`guest VM`有一个由VMM维护的`nPT`。其实，`EPT/NPT`就是一种扩展的MMU（以下称`EPT/NPT MMU`），它可以交叉地查找`gPT`和`nPT`两个页表。在这种方案下，**CPU是明确感知这是虚拟机的寻址过程**

![memory_5](/images/Linux-虚拟化/memory_5.jpg)

假设`gPT`和`nPT`都是4级页表，那么`EPT/NPT MMU`完成一次地址转换的过程是这样的（不考虑TLB）：

首先它会查找`guest VM`中`CR3`寄存器（`gCR3`）指向的`PML4`页表，由于`gCR3`中存储的地址是`GPA`，因此CPU需要查找`nPT`来获取`gCR3`的`GPA`对应的`HPA`。`nPT`的查找和前面文章讲的页表查找方法是一样的，这里我们称一次`nPT`的查找过程为一次`nested walk`

![memory_6](/images/Linux-虚拟化/memory_6.jpg)

如果在`nPT`中没有找到，则产生`EPT violation`异常（可理解为VMM层的`page fault`）。如果找到了，也就是获得了`PML4`页表的物理地址后，就可以用`GVA`中的bit位子集作为`PML4`页表的索引，得到`PDPE`页表的`GPA`。接下来又是通过一次`nested walk`进行`PDPE`页表的`GPA->HPA`转换，然后重复上述过程，依次查找PD和PE页表，最终获得该`GVA`对应的`HPA`

![memory_7](/images/Linux-虚拟化/memory_7.jpg)

不同于影子页表是一个进程需要一个`sPT`，`EPT/NPT MMU`解耦了`GVA->GPA`转换和`GPA->HPA`转换之间的依赖关系，一个VM只需要一个`nPT`，减少了内存开销。如果`guest VM`中发生了`page fault`，可直接由`guest OS`处理，不会产生`vm-exit`，减少了CPU的开销。可以说，`EPT/NPT MMU`这种硬件辅助的内存虚拟化技术解决了纯软件实现存在的两个问题

**EPT/NPT MMU优化**

事实上，`EPT/NPT MMU`作为传统`MMU`的扩展，自然也是有`TLB`的，它在查找`gPT`和`nPT`之前，会先去查找自己的`TLB`（前面为了描述的方便省略了这一步）。**但这里的`TLB`存储的并不是一个`GVA->GPA`的映射关系，也不是一个`GPA->HPA`的映射关系，而是最终的转换结果，也就是`GVA->HPA`的映射**

不同的进程可能会有相同的虚拟地址，为了避免进程切换的时候flush所有的TLB，可通过给`TLB entry`加上一个标识进程的`PCID/ASID`的`tag`来区分（参考[这篇文章](https://zhuanlan.zhihu.com/p/66971714)）。同样地，不同的`guest VM`也会有相同的`GVA`，为了flush的时候有所区分，需要再加上一个标识虚拟机的`tag`，这个`tag`在ARM体系中被叫做`VMID`，在Intel体系中则被叫做`VPID`

![memory_8](/images/Linux-虚拟化/memory_8.jpg)

在最坏的情况下（也就是`TLB`完全没有命中），`gPT`中的每一级转换都需要一次`nested walk`，而每次`nested walk`需要`4`次内存访问，因此`5`次`nested walk`总共需要`(4 + 1) * 5 - 1 =24`次内存访问（就像一个5x5的二维矩阵一样）：

![memory_9](/images/Linux-虚拟化/memory_9.jpg)

虽然这24次内存访问都是由硬件自动完成的，不需要软件的参与，但是内存访问的速度毕竟不能与CPU的运行速度同日而语，而且内存访问还涉及到对总线的争夺，次数自然是越少越好。

要想减少内存访问次数，要么是增大`EPT/NPT TLB`的容量，增加`TLB`的命中率，要么是减少`gPT`和`nPT`的级数。`gPT`是为`guest VM`中的进程服务的，通常采用4KB粒度的页，那么在64位系统下使用4级页表是非常合适的（参考[这篇文章](https://zhuanlan.zhihu.com/p/64978946)）。

而`nPT`是为`guset VM`服务的，对于划分给一个VM的内存，粒度不用太小。64位的x86_64支持`2MB`和`1GB`的`large page`，假设创建一个VM的时候申请的是2G物理内存，那么只需要给这个VM分配2个1G的`large pages`就可以了（这2个`large pages`不用相邻，但`large page`内部的物理内存是连续的），这样`nPT`只需要2级（`nPML4`和`nPDPE`）

如果现在物理内存中确实找不到2个连续的`1G`内存区域，那么就退而求其次，使用`2MB`的`large page`，这样`nPT`就是3级（`nPML4`，`nPDPE`和`nPD`）

## 4.1 问题

1. 内核是直接访问内存的么？（内核和内存之间是否存在抽象层）。内核面向的是内存的物理地址还是逻辑地址？（固定的起始地址？）。内核是怎么感知到物理地址的范围的
1. 在内存分页的方案中，cpu访问的是虚拟内存地址，即页号+页内偏移。但是程序本身应该不感知这个事情，程序又是如何使用内存的呢
1. 内存管理是CPU完成的还是OS完成的？（MMU是CPU的一个芯片）
1. 每个进程的页表目录都不同么？页表目录本身不经过内存管理么？
1. Guest上的进程在访问内存时，如果产生了一个缺页异常，为啥捕获到异常的是Guest Kernel而不是Host Kernel
   * CPU在发现缺页异常后，会通过寄存idtr查询中断描述符表（Interrupt Descriptor Table，IDT），并根据表中的地址来获取相应的中断处理程序。当Guest运行的时候，CPU的该寄存器内填写的是Guest OS的IDT，因此捕获到异常的是Guest Kernel而不是Host Kernel
1. 段寄存器中包含了特权指令级别（ring0-ring3），当Guest访问ring0级别的段时，为啥会报错？寄存器中的ring级别又没有虚拟化，Guest的ring0和Host的ring0有什么差别呢？
1. 影子页表如何起作用？GVA->GPA，内存的寻址过程已经结束了，为啥可以再插入一个GPA-HPA的过程？
   * 并不是插入一个GPA-HPA的过程，而是让GVA直接映射到HPA（Guest在一次正常的寻址就能直接定位到物理机的内存）

## 4.2 参考

* [20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)
* [线性地址转换为物理地址是硬件实现还是软件实现？具体过程如何？](https://www.zhihu.com/question/23898566)
* [浅谈Linux内存管理](https://zhuanlan.zhihu.com/p/67059173)
* [虚拟化技术 - 内存虚拟化 [一]](https://zhuanlan.zhihu.com/p/69828213)
* [虚拟化技术 - 内存虚拟化 [二]](https://zhuanlan.zhihu.com/p/75468128)
* [内存虚拟化之影子页表](https://www.cnblogs.com/miachel-zheng/p/7860369.html)
* [影子页表的问题？](https://www.zhihu.com/question/41224767)
* [What exactly do shadow page tables (for VMMs) do?](https://stackoverflow.com/questions/9832140/what-exactly-do-shadow-page-tables-for-vmms-do)
* [内存虚拟化之基本原理](https://www.codenong.com/cs106434119/)

# 5 QEMU

## 5.1 参考

* [qemu-doc](https://wiki.qemu.org/Documentation/Architecture?spm=ata.13261165.0.0.74b56b0btmdUQy)

# 6 KVM

## 6.1 参考

* [随笔分类 - KVM](https://www.cnblogs.com/sammyliu/category/696699.html)
* [[原] KVM 虚拟化原理探究 —— 目录](https://www.cnblogs.com/Bozh/p/5788431.html)
* [虚拟化技术基础原理](https://www.cnblogs.com/yinzhengjie/p/7478797.html)
* [使用KVM API实现Emulator Demo](http://soulxu.github.io/blog/2014/08/11/use-kvm-api-write-emulator/)
* [KVM 学习笔记](https://blog.opskumu.com/kvm-notes.html)
* [KVM的原理与使用](https://www.jianshu.com/p/03d3afff3b5f)

# 7 KVM初体验

物理机系统：`CentOS-7-x86_64-DVD-1810.iso`

查看系统是否支持kvm

```sh
lsmod | grep kvm
#-------------------------↓↓↓↓↓↓-------------------------
kvm_intel             183621  0
kvm                   586948  1 kvm_intel
irqbypass              13503  1 kvm
#-------------------------↑↑↑↑↑↑-------------------------
```

软件安装：

```sh
yum install -y qemu-kvm qemu-img
yum install -y virt-manager libvirt libvirt-python python-virtinst libvirt-client virt-install

systemctl enable libvirtd
systemctl start libvirtd
```

用于安装虚拟机的镜像为：`CentOS-7-x86_64-Minimal-1908.iso`，运行虚拟机的命令如下

```sh
# 创建虚拟网桥br0
ip link add br0 type bridge
ip addr add 10.0.2.1/24 broadcast 10.0.2.255 dev br0
ip link set br0 up
iptables -t nat -A POSTROUTING -s 10.0.2.0/24 -o eno1 -j MASQUERADE # eno1是我主机上的外网网卡

# 创建disk目录
mkdir -p /kvm/disk

# 创建虚拟机
virt-install \
   --virt-type=kvm \
   --name myvm_centos7 \
   --ram 2048 \
   --vcpus=2 \
   --os-variant=rhel7.6 \
   --cdrom=/root/CentOS-7-x86_64-Minimal-1908.iso \
   --network=bridge=br0,model=virtio \
   --graphics vnc \
   --disk path=/kvm/disk/myvm_centos7.disk,size=10,bus=virtio,format=qcow2
#-------------------------↓↓↓↓↓↓-------------------------
WARNING  无法连接到图形控制台：没有安装 virt-viewer。请安装 'virt-viewer' 软件包。
WARNING  没有控制台用于启动客户机，默认为 --wait -1

开始安装......
正在分配 'myvm_centos7.disk'                                                                                                                                                   |  10 GB  00:00:00
ERROR    internal error: qemu unexpectedly closed the monitor: 2021-02-27T03:55:11.298881Z qemu-kvm: -drive file=/root/CentOS-7-x86_64-Minimal-1908.iso,format=raw,if=none,id=drive-ide0-0-0,readonly=on: could not open disk image /root/CentOS-7-x86_64-Minimal-1908.iso: Could not open '/root/CentOS-7-x86_64-Minimal-1908.iso': Permission denied
正在删除磁盘 'myvm_centos7.disk'                                                                                                                                             |    0 B  00:00:00
域安装失败，您可以运行下列命令重启您的域：
'virsh start virsh --connect qemu:///system start myvm_centos7'
否则请重新开始安装。
#-------------------------↑↑↑↑↑↑-------------------------

# 修改配置文件，取消以下两行的注释
   #user = "root"
   #group = "root"
vi /etc/libvirt/qemu.conf

# 重启服务
systemctl daemon-reload
systemctl restart libvirtd

# 再次执行virt-install
virt-install \
   --virt-type=kvm \
   --name myvm_centos7 \
   --ram 2048 \
   --vcpus=2 \
   --os-variant=rhel7.6 \
   --cdrom=/root/CentOS-7-x86_64-Minimal-1908.iso \
   --network=bridge=br0,model=virtio \
   --graphics vnc \
   --disk path=/kvm/disk/myvm_centos7.disk,size=10,bus=virtio,format=qcow2
#-------------------------↓↓↓↓↓↓-------------------------
WARNING  无法连接到图形控制台：没有安装 virt-viewer。请安装 'virt-viewer' 软件包。
WARNING  没有控制台用于启动客户机，默认为 --wait -1

开始安装......
正在分配 'myvm_centos7.disk'                                                                                                                                                   |  10 GB  00:00:00
ERROR    unsupported format character '�' (0xffffffe7) at index 47
域安装失败，您可以运行下列命令重启您的域：
'virsh start virsh --connect qemu:///system start myvm_centos7'
否则请重新开始安装。
#-------------------------↑↑↑↑↑↑-------------------------
```

看起来是因为没有安装图形化的工具

```sh
yum install -y 'virt-viewer'

# 重新尝试创建虚拟机
virsh destroy myvm_centos7
virsh undefine myvm_centos7
rm -f /kvm/disk/myvm_centos7.disk
virt-install \
   --virt-type=kvm \
   --name myvm_centos7 \
   --ram 2048 \
   --vcpus=2 \
   --os-variant=rhel7.6 \
   --cdrom=/root/CentOS-7-x86_64-Minimal-1908.iso \
   --network=bridge=br0,model=virtio \
   --graphics vnc \
   --disk path=/kvm/disk/myvm_centos7.disk,size=10,bus=virtio,format=qcow2
#-------------------------↓↓↓↓↓↓-------------------------
WARNING  需要图形显示，但未设置 DISPLAY。不能运行 virt-viewer。
WARNING  没有控制台用于启动客户机，默认为 --wait -1

开始安装......
正在分配 'myvm_centos7.disk'                                                                                                                                                   |  10 GB  00:00:00
ERROR    unsupported format character '�' (0xffffffe7) at index 47
域安装失败，您可以运行下列命令重启您的域：
'virsh start virsh --connect qemu:///system start myvm_centos7'
否则请重新开始安装。
#-------------------------↑↑↑↑↑↑-------------------------
```

由于我是通过ssh连到服务器上，然后执行相关指令的，看起来这种方式不行，得在服务器上装一个桌面应用，然后通过vnc连接过去，再执行`virt-install`进行安装

```sh
# 安装桌面应用
yum groupinstall -y 'GNOME Desktop' 'Graphical Administration Tools'

# 安装vncserver
yum -y install "vnc-server"
# 启动vncserver，:x表示端口号为 5900+x。例如:1表示监听端口号为5901
vncserver :1
#-------------------------↓↓↓↓↓↓-------------------------
Password:
Verify:
Would you like to enter a view-only password (y/n)? y
Password:
Verify:
xauth:  file /root/.Xauthority does not exist

New 'iot-6wbudf-name-nick-name:1 (root)' desktop is iot-6wbudf-name-nick-name:1

Creating default startup script /root/.vnc/xstartup
Creating default config /root/.vnc/config
Starting applications specified in /root/.vnc/xstartup
Log file is /root/.vnc/iot-6wbudf-name-nick-name:1.log
#-------------------------↑↑↑↑↑↑-------------------------

# 检查端口号是否已启动
lsof -i tcp:5901
#-------------------------↓↓↓↓↓↓-------------------------
COMMAND   PID USER   FD   TYPE  DEVICE SIZE/OFF NODE NAME
Xvnc    64424 root   10u  IPv4 1850241      0t0  TCP *:5901 (LISTEN)
Xvnc    64424 root   11u  IPv6 1850242      0t0  TCP *:5901 (LISTEN)
#-------------------------↑↑↑↑↑↑-------------------------
```

通过`vnc-client`登录到该机器上之后，再执行下面的操作

```sh
virsh destroy myvm_centos7
virsh undefine myvm_centos7
rm -f /kvm/disk/myvm_centos7.disk
virt-install \
   --virt-type=kvm \
   --name myvm_centos7 \
   --ram 2048 \
   --vcpus=2 \
   --os-variant=rhel7.6 \
   --cdrom=/root/CentOS-7-x86_64-Minimal-1908.iso \
   --network=bridge=br0,model=virtio \
   --graphics vnc \
   --disk path=/kvm/disk/myvm_centos7.disk,size=10,bus=virtio,format=qcow2
```

**以图形化的方式连入虚拟机：**

1. 通过`vnc-client`连接到服务器上
1. `virt-viewer -a <vmname>`

**以文本的方式连入虚拟机：**

1. 通过`ssh`或其他方式连接到服务器上
1. `virsh console <vmname>`

```sh
virsh console myvm_centos7
#-------------------------↓↓↓↓↓↓-------------------------
连接到域 myvm_centos7
换码符为 ^]

#-------------------------↑↑↑↑↑↑-------------------------

# 需要在虚拟机进行一些配置（以下三行命令要在虚拟机上执行，可以通过图形化的方式连上去执行）
echo "ttyS0" >> /etc/securetty 
grubby --update-kernel=ALL --args="console=ttyS0" # 更新内核参数
reboot
```

## 7.1 常用命令

1. `virsh domiflist <vmname>`
1. `virsh attach-interface <vmname> --type bridge --source <主机上的网卡名>`
1. `virsh detach-interface <vmname> --type bridge --mac <网卡mac地址>`

## 7.2 参考

* [KVM 介绍（1）：简介及安装](https://www.cnblogs.com/sammyliu/p/4543110.html)
* [virsh console连接虚拟机遇到的问题](https://www.cnblogs.com/zhimao/p/13744257.html)
* [【虚拟化】KVM、Qemu、Virsh的区别与联系](https://blog.csdn.net/qq_34018840/article/details/101194571)
* [How to install KVM on CentOS 7 / RHEL 7 Headless Server](https://www.cyberciti.biz/faq/how-to-install-kvm-on-centos-7-rhel-7-headless-server/)
* [Install and Configure VNC Server in CentOS 7 and RHEL 7](https://www.linuxtechi.com/install-configure-vnc-server-centos-7-rhel-7/)
* [阿里云CentOS7.x服务器安装GNOME桌面并使用VNC server](https://blog.csdn.net/weixin_38312031/article/details/79415394)

# 8 TODO

1. 物理机的内核如何与硬件交互？软件分层之后，下层才能屏蔽差异（欺骗）。虚拟机又是如何被虚拟硬件欺骗的？
1. 总线、RAM、CPU、时钟。内存和CPU如何通信。VM使用的是物理内存中的某一段，VM中内存与CPU的交互与普通进程的内存与CPU的交互是类似的
1. 基于二进制翻译的全虚拟化，VMM如何捕获异常？
1. 客户机代码执行流程（内核or用户代码）
