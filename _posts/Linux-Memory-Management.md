---
title: Linux-Memory-Management
date: 2020-04-11 22:07:59
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 虚拟内存

**摘录自[20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)**

**单片机的CPU是直接操作内存的「物理地址」**

![mcu](/images/Linux-Memory-Management/mcu.png)

在这种情况下，要想在内存中同时运行两个程序是不可能的。如果第一个程序在`2000`的位置写入一个新的值，将会擦掉第二个程序存放在相同位置上的所有内容，所以同时运行两个程序是根本行不通的，这两个程序会立刻崩溃

> 操作系统是如何解决这个问题呢？

这里关键的问题是这两个程序都引用了绝对物理地址，而这正是我们最需要避免的

我们可以把进程所使用的地址「隔离」开来，即让操作系统为每个进程分配独立的一套「虚拟地址」，人人都有，大家自己玩自己的地址就行，互不干涉。但是有个前提每个进程都不能访问物理地址，至于虚拟地址最终怎么落到物理内存里，对进程来说是透明的，操作系统已经把这些都安排的明明白白了

![virtual](/images/Linux-Memory-Management/virtual.png)

**操作系统会提供一种机制，将不同进程的虚拟地址和不同内存的物理地址映射起来**

如果程序要访问虚拟地址的时候，由操作系统转换成不同的物理地址，这样不同的进程运行的时候，写入的是不同的物理地址，这样就不会冲突了

**于是，这里就引出了两种地址的概念：**

我们程序所使用的内存地址叫做**虚拟内存地址（Virtual Memory Address）**
实际存在硬件里面的空间地址叫**物理内存地址（Physical Memory Address）**
操作系统引入了虚拟内存，进程持有的虚拟地址会通过 CPU 芯片中的内存管理单元（MMU）的映射关系，来转换变成物理地址，然后再通过物理地址访问内存，如下图所示：

![virtual_mmu](/images/Linux-Memory-Management/virtual_mmu.jpg)

> 操作系统是如何管理虚拟地址与物理地址之间的关系？

主要有两种方式，分别是内存分段和内存分页，分段是比较早提出的，我们先来看看内存分段

# 2 内存分段

**摘录自[20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)**

程序是由若干个逻辑分段组成的，如可由代码分段、数据分段、栈段、堆段组成。**不同的段是有不同的属性的，所以就用分段（Segmentation）的形式把这些段分离出来**

> 分段机制下，虚拟地址和物理地址是如何映射的？

分段机制下的虚拟地址由两部分组成，**段选择子**和**段内偏移量**

![segment_1](/images/Linux-Memory-Management/segment_1.jpg)

* `段选择子`就保存在段寄存器里面。段选择子里面最重要的是`段号`，用作段表的索引。`段表`里面保存的是这个`段的基地址`、`段的界限`和`特权等级`等
* 虚拟地址中的`段内偏移量`应该位于0和段界限之间，如果段内偏移量是合法的，就将段基地址加上段内偏移量得到物理内存地址

在上面，知道了虚拟地址是通过段表与物理地址进行映射的，分段机制会把程序的虚拟地址分成4个段，每个段在段表中有一个项，在这一项找到段的基地址，再加上偏移量，于是就能找到物理内存中的地址，如下图：

![segment_2](/images/Linux-Memory-Management/segment_2.jpg)

如果要访问段`3`中偏移量`500`的虚拟地址，我们可以计算出物理地址为，段`3`基地址`700` + 偏移量`500` = `7500`

分段的办法很好，解决了程序本身不需要关心具体的物理内存地址的问题，但它也有一些不足之处：

1. 第一个就是**内存碎片**的问题
1. 第二个就是**内存交换的效率低**的问题

接下来，说说为什么会有这两个问题

我们来看看这样一个例子。假设有1G的物理内存，用户执行了多个程序，其中：

* 游戏占用了`512MB`内存
* 浏览器占用了`128MB`内存
* 音乐占用了`256MB`内存

这个时候，如果我们关闭了浏览器，则空闲内存还有`1024 - 512 - 256 = 256MB`

如果这个`256MB`不是连续的，被分成了两段`128MB`内存，这就会导致没有空间再打开一个`200MB`的程序

![segment_fragment](/images/Linux-Memory-Management/segment_fragment.jpg)

这里的内存碎片的问题共有两处地方：

1. **外部内存碎片**，也就是产生了多个不连续的小物理内存，导致新的程序无法被装载
1. **内部内存碎片**，程序所有的内存都被装载到了物理内存，但是这个程序有部分的内存可能并不是很常使用，这也会导致内存的浪费

针对上面两种内存碎片的问题，解决的方式会有所不同

解决外部内存碎片的问题就是**内存交换**

可以把音乐程序占用的那`256MB`内存写到硬盘上，然后再从硬盘上读回来到内存里。不过再读回的时候，我们不能装载回原来的位置，而是紧紧跟着那已经被占用了的`512MB`内存后面。这样就能空缺出连续的`256MB`空间，于是新的`200MB`程序就可以装载进来

这个内存交换空间，在Linux系统里，也就是我们常看到的Swap空间，这块空间是从硬盘划分出来的，用于内存与硬盘的空间交换

> 再来看看，分段为什么会导致内存交换效率低的问题？

对于多进程的系统来说，用分段的方式，内存碎片是很容易产生的，产生了内存碎片，那不得不重新`Swap`内存区域，这个过程会产生性能瓶颈

因为硬盘的访问速度要比内存慢太多了，每一次内存交换，我们都需要把一大段连续的内存数据写到硬盘上

所以，如果内存交换的时候，交换的是一个占内存空间很大的程序，这样整个机器都会显得卡顿

为了解决内存分段的内存碎片和内存交换效率低的问题，就出现了内存分页

# 3 内存分页

**摘录自[20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)**

分段的好处就是能产生连续的内存空间，但是会出现内存碎片和内存交换的空间太大的问题

要解决这些问题，那么就要想出能少出现一些内存碎片的办法。另外，当需要进行内存交换的时候，让需要交换写入或者从磁盘装载的数据更少一点，这样就可以解决问题了。这个办法，也就是**内存分页（Paging）**

**分页是把整个虚拟和物理内存空间切成一段段固定尺寸的大小**。这样一个连续并且尺寸固定的内存空间，我们叫页（Page）。在 Linux 下，每一页的大小为`4KB`

虚拟地址与物理地址之间通过页表来映射，如下图：

![paging_1](/images/Linux-Memory-Management/paging_1.jpg)

页表实际上存储在CPU的内存管理单元（MMU）中，于是CPU就可以直接通过MMU，找出要实际要访问的物理内存地址

而当进程访问的虚拟地址在页表中查不到时，系统会产生一个**缺页异常**，进入系统内核空间分配物理内存、更新进程页表，最后再返回用户空间，恢复进程的运行

> 分页是怎么解决分段的内存碎片、内存交换效率低的问题？

由于内存空间都是预先划分好的，也就不会像分段会产生间隙非常小的内存，这正是分段会产生内存碎片的原因。**而采用了分页，那么释放的内存都是以页为单位释放的，也就不会产生无法给进程使用的小内存**

如果内存空间不够，操作系统会把其他正在运行的进程中的「最近没被使用」的内存页面给释放掉，也就是暂时写在硬盘上，称为**换出**（Swap Out）。一旦需要的时候，再加载进来，称为**换入**（Swap In）。所以，一次性写入磁盘的也只有少数的一个页或者几个页，不会花太多时间，**内存交换的效率就相对比较高**

![paging_2](/images/Linux-Memory-Management/paging_2.jpg)

更进一步地，分页的方式使得我们在加载程序的时候，不再需要一次性都把程序加载到物理内存中。我们完全可以在进行虚拟内存和物理内存的页之间的映射之后，并不真的把页加载到物理内存里，**而是只有在程序运行中，需要用到对应虚拟内存页里面的指令和数据时，再加载到物理内存里面去**

> 分页机制下，虚拟地址和物理地址是如何映射的？

在分页机制下，虚拟地址分为两部分，**页号**和**页内偏移**。页号作为页表的索引，**页表**包含物理页每页所在**物理内存的基地址**，这个基地址与页内偏移的组合就形成了物理内存地址，见下图

![paging_3](/images/Linux-Memory-Management/paging_3.jpg)

总结一下，对于一个内存地址转换，其实就是这样三个步骤：

1. 把虚拟内存地址，切分成页号和偏移量
1. 根据页号，从页表里面，查询对应的物理页号
1. 直接拿物理页号，加上前面的偏移量，就得到了物理内存地址

下面举个例子，虚拟内存中的页通过页表映射为了物理内存中的页，如下图：

![paging_4](/images/Linux-Memory-Management/paging_4.jpg)

这看起来似乎没什么毛病，但是放到实际中操作系统，这种简单的分页是肯定是会有问题的

> 简单的分页有什么缺陷吗？

有空间上的缺陷

因为操作系统是可以同时运行非常多的进程的，那这不就意味着页表会非常的庞大

在32位的环境下，虚拟地址空间共有`4GB`，假设一个页的大小是`4KB（2^12）`，那么就需要大约`100 万 （2^20）`个页，每个「页表项」需要`4`个字节大小来存储，那么整个`4GB`空间的映射就需要有`4MB`的内存来存储页表

这`4MB`大小的页表，看起来也不是很大。但是要知道每个进程都是有自己的虚拟地址空间的，也就说都有自己的页表

那么，`100`个进程的话，就需要`400MB`的内存来存储页表，这是非常大的内存了，更别说`64`位的环境了

**要解决上面的问题，就需要采用的是一种叫作多级页表（Multi-Level Page Table）的解决方案**

在前面我们知道了，对于单页表的实现方式，在32位和页大小`4KB`的环境下，一个进程的页表需要装下`100`多万个「页表项」，并且每个页表项是占用`4`字节大小的，于是相当于每个页表需占用`4MB`大小的空间。

我们把这个`100`多万个「页表项」的单级页表再分页，将页表（一级页表）分为`1024`个页表（二级页表），每个表（二级页表）中包含`1024`个「页表项」，**形成二级分页**。如下图所示：

![paging_5](/images/Linux-Memory-Management/paging_5.jpg)

> 你可能会问，分了二级表，映射`4GB`地址空间就需要`4KB`（一级页表）+ `4MB`（二级页表）的内存，这样占用空间不是更大了吗？

当然如果`4GB`的虚拟地址全部都映射到了物理内存上的话，二级分页占用空间确实是更大了，但是，我们往往不会为一个进程分配那么多内存

其实我们应该换个角度来看问题，还记得计算机组成原理里面无处不在的**局部性原理**么？

每个进程都有`4GB`的虚拟地址空间，而显然对于大多数程序来说，其使用到的空间远未达到`4GB`，因为会存在部分对应的页表项都是空的，根本没有分配，对于已分配的页表项，如果存在最近一定时间未访问的页表，在物理内存紧张的情况下，操作系统会将页面换出到硬盘，也就是说不会占用物理内存

如果使用了二级分页，一级页表就可以覆盖整个`4GB`虚拟地址空间，**但如果某个一级页表的页表项没有被用到，也就不需要创建这个页表项对应的二级页表了，即可以在需要时才创建二级页表**。做个简单的计算，假设只有`20%`的一级页表项被用到了，那么页表占用的内存空间就只有 `4KB`（一级页表） + `20% * 4MB`（二级页表）= `0.804MB`，这对比单级页表的`4MB`是不是一个巨大的节约？

那么为什么不分级的页表就做不到这样节约内存呢？我们从页表的性质来看，保存在内存中的页表承担的职责是将虚拟地址翻译成物理地址。假如虚拟地址在页表中找不到对应的页表项，计算机系统就不能工作了。**所以页表一定要覆盖全部虚拟地址空间，不分级的页表就需要有`100`多万个页表项来映射，而二级分页则只需要`1024`个页表项**（此时一级页表覆盖到了全部虚拟地址空间，二级页表在需要时创建）

我们把二级分页再推广到多级页表，就会发现页表占用的内存空间更少了，这一切都要归功于对局部性原理的充分应用

对于64位的系统，两级分页肯定不够了，就变成了四级目录，分别是：

* 全局页目录项 PGD（Page Global Directory）；
* 上层页目录项 PUD（Page Upper Directory）；
* 中间页目录项 PMD（Page Middle Directory）；
* 页表项 PTE（Page Table Entry）；

![paging_6](/images/Linux-Memory-Management/paging_6.jpg)

多级页表虽然解决了空间上的问题，但是虚拟地址到物理地址的转换就多了几道转换的工序，这显然就降低了这俩地址转换的速度，也就是带来了时间上的开销。

程序是有局部性的，即在一段时间内，整个程序的执行仅限于程序中的某一部分。相应地，执行所访问的存储空间也局限于某个内存区域

![paging_tlb_1](/images/Linux-Memory-Management/paging_tlb_1.png)

**我们就可以利用这一特性，把最常访问的几个页表项存储到访问速度更快的硬件，于是计算机科学家们，就在CPU芯片中，加入了一个专门存放程序最常访问的页表项的Cache，这个Cache 就是 TLB（Translation Lookaside Buffer），通常称为页表缓存、转址旁路缓存、快表等**

![paging_tlb_2](/images/Linux-Memory-Management/paging_tlb_2.png)

在CPU芯片里面，封装了内存管理单元（Memory Management Unit）芯片，它用来完成地址转换和`TLB`的访问与交互

有了`TLB`后，那么CPU在寻址时，会先查`TLB`，如果没找到，才会继续查常规的页表

`TLB`的命中率其实是很高的，因为程序最常访问的页就那么几个

# 4 段页式内存管理

**摘录自[20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)**

内存分段和内存分页并不是对立的，它们是可以组合起来在同一个系统中使用的，那么组合起来后，通常称为**段页式内存管理**

![segment_paging_1](/images/Linux-Memory-Management/segment_paging_1.png)

段页式内存管理实现的方式：

1. 先将程序划分为多个有逻辑意义的段，也就是前面提到的分段机制
2. 接着再把每个段划分为多个页，也就是对分段划分出来的连续空间，再划分固定大小的页；

这样，地址结构就由**段号、段内页号和页内位移**三部分组成

用于段页式地址变换的数据结构是每一个程序一张段表，每个段又建立一张页表，段表中的地址是页表的起始地址，而页表中的地址则为某页的物理页号，如图所示：

![segment_paging_2](/images/Linux-Memory-Management/segment_paging_2.jpg)

段页式地址变换中要得到物理地址须经过三次内存访问：

* 第一次访问段表，得到页表起始地址
* 第二次访问页表，得到物理页号
* 第三次将物理页号与页内位移组合，得到物理地址

可用软、硬件相结合的方法实现段页式地址变换，这样虽然增加了硬件成本和系统开销，但提高了内存的利用率

# 5 Linux内存管理

**摘录自[20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)**

那么，Linux操作系统采用了哪种方式来管理内存呢？

> 在回答这个问题前，我们得先看看Intel处理器的发展历史

早期Intel的处理器从`80286`开始使用的是段式内存管理。但是很快发现，光有段式内存管理而没有页式内存管理是不够的，这会使它的x86系列会失去市场的竞争力。因此，在不久以后的`80386`中就实现了对页式内存管理。也就是说，`80386`除了完成并完善从`80286`开始的段式内存管理的同时还实现了页式内存管理

但是这个`80386`的页式内存管理设计时，没有绕开段式内存管理，而是建立在段式内存管理的基础上，这就意味着，**页式内存管理的作用是在由段式内存管理所映射而成的地址上再加上一层地址映射**

由于此时由段式内存管理映射而成的地址不再是「物理地址」了，Intel就称之为「线性地址」（也称虚拟地址）。于是，段式内存管理先将逻辑地址映射成线性地址，然后再由页式内存管理将线性地址映射成物理地址

![linux_1](/images/Linux-Memory-Management/linux_1.png)

这里说明下逻辑地址和线性地址：

* 程序所使用的地址，通常是没被段式内存管理映射的地址，称为逻辑地址；
* 通过段式内存管理映射的地址，称为线性地址，也叫虚拟地址；

逻辑地址是「段式内存管理」转换前的地址，线性地址则是「页式内存管理」转换前的地址。

> 了解完Intel处理器的发展历史后，我们再来说说Linux采用了什么方式管理内存？

**Linux内存主要采用的是页式内存管理，但同时也不可避免地涉及了段机制**

这主要是上面Intel处理器发展历史导致的，因为Intel X86 CPU一律对程序中使用的地址先进行段式映射，然后才能进行页式映射。既然CPU的硬件结构是这样，Linux内核也只好服从Intel的选择

但是事实上，Linux内核所采取的办法是使段式映射的过程实际上不起什么作用。也就是说，「上有政策，下有对策」，若惹不起就躲着走。

**Linux系统中的每个段都是从0地址开始的整个4GB虚拟空间（32 位环境下），也就是所有的段的起始地址都是一样的。这意味着，Linux系统中的代码，包括操作系统本身的代码和应用程序代码，所面对的地址空间都是线性地址空间（虚拟地址），这种做法相当于屏蔽了处理器中的逻辑地址概念，段只被用于访问控制和内存保护**

> 我们再来瞧一瞧，Linux的虚拟地址空间是如何分布的？

在Linux操作系统中，虚拟地址空间的内部又被分为**内核空间和用户空间**两部分，不同位数的系统，地址空间的范围也不同。比如最常见的32位和64位系统，如下所示：

![linux_2](/images/Linux-Memory-Management/linux_2.jpg)

通过这里可以看出：

* 32位系统的内核空间占用`1G`，位于最高处，剩下的`3G`是用户空间
* 64位系统的内核空间和用户空间都是`128T`，分别占据整个内存空间的最高和最低处，剩下的中间部分是未定义的

再来说说，内核空间与用户空间的区别：

* 进程在用户态时，只能访问用户空间内存
* 只有进入内核态后，才可以访问内核空间的内存

虽然每个进程都各自有独立的虚拟内存，但是**每个虚拟内存中的内核地址**，其实关联的都是相同的物理内存。这样，进程切换到内核态后，就可以很方便地访问内核空间内存

![linux_3](/images/Linux-Memory-Management/linux_3.jpg)

接下来，进一步了解虚拟空间的划分情况，用户空间和内核空间划分的方式是不同的，内核空间的分布情况就不多说了

我们看看用户空间分布的情况，以32位系统为例，我画了一张图来表示它们的关系：

![linux_4](/images/Linux-Memory-Management/linux_4.jpg)

通过这张图你可以看到，用户空间内存，从低到高分别是`7`种不同的内存段：

* 程序文件段，包括二进制可执行代码
* 已初始化数据段，包括静态常量
* 未初始化数据段，包括未初始化的静态变量
* 堆段，包括动态分配的内存，从低地址开始向上增长
* 文件映射段，包括动态库、共享内存等，从低地址开始向上增长（跟硬件和内核版本有关）
* 栈段，包括局部变量和函数调用的上下文等。栈的大小是固定的，一般是`8`MB。当然系统也提供了参数，以便我们自定义大小
* 在这`7`个内存段中，堆和文件映射段的内存是动态分配的。比如说，使用`C`标准库的`malloc()`或者`mmap()`，就可以分别在堆和文件映射段动态分配内存

## 5.1 逻辑地址如何转换为物理地址

**摘录自[线性地址转换为物理地址是硬件实现还是软件实现？具体过程如何？](https://www.zhihu.com/question/23898566)**

机器语言指令中出现的内存地址，都是逻辑地址，需要转换成线性地址，再经过MMU（CPU中的内存管理单元）转换成物理地址才能够被访问到

我们写个最简单的hello world程序，用gccs编译，再反编译后会看到以下指令：

```
mov 0x80495b0, %eax
```

这里的内存地址`0x80495b0`就是一个**逻辑地址**，必须加上隐含的**DS数据段的基地址**，才能构成线性地址。**也就是说`0x80495b0`是当前任务的DS数据段内的偏移**

在x86保护模式下，段的信息（段基线性地址、长度、权限等）即**段描述符**占8个字节，段信息无法直接存放在段寄存器中（段寄存器只有2字节）。**Intel的设计是段描述符集中存放在GDT或LDT中，而段寄存器存放的是段描述符在GDT或LDT内的索引值(index)**

**Linux中逻辑地址等于线性地址**。为什么这么说呢？因为Linux所有的段（用户代码段、用户数据段、内核代码段、内核数据段）的线性地址都是从`0x00000000`开始，长度4G，这样`线性地址 = 逻辑地址 + 0x00000000`，也就是说逻辑地址等于线性地址了

从上面可以看到，Linux在x86的分段机制上运行，却通过一个巧妙的方式绕开了分段。Linux主要以分页的方式实现内存管理

![linux_5](/images/Linux-Memory-Management/linux_5.jpg)

前面说了Linux中逻辑地址等于线性地址，那么线性地址怎么对应到物理地址呢？这个大家都知道，那就是通过分页机制，具体的说，就是通过页表查找来对应物理地址

**准确的说分页是CPU提供的一种机制，Linux只是根据这种机制的规则，利用它实现了内存管理**

在保护模式下，控制寄存器`CR0`的最高位`PG`位控制着分页管理机制是否生效，如果`PG=1`，分页机制生效，需通过页表查找才能把线性地址转换物理地址。如果`PG=0`，则分页机制无效，线性地址就直接做为物理地址

分页的基本原理是把内存划分成大小固定的若干单元，每个单元称为一页（page），每页包含4k字节的地址空间（为简化分析，我们不考虑扩展分页的情况）。这样每一页的起始地址都是`4k`字节对齐的。为了能转换成物理地址，我们需要给CPU提供当前任务的线性地址转物理地址的查找表，即页表(page table)。注意，**为了实现每个任务的平坦的虚拟内存，每个任务都有自己的页目录表和页表**

为了节约页表占用的内存空间，x86将线性地址通过页目录表和页表两级查找转换成物理地址

32位的线性地址被分成3个部分

* 最高`10`位`Directory`页目录表偏移量，中间`10`位`Table`是页表偏移量，最低`12`位`Offset`是物理页内的字节偏移量
* 页目录表的大小为`4k`（刚好是一个页的大小），包含`1024`项，每个项`4`字节（32位），项目里存储的内容就是页表的物理地址。如果页目录表中的页表尚未分配，则物理地址填0
* 页表的大小也是`4k`，同样包含`1024`项，每个项`4`字节，内容为最终物理页的物理内存起始地址

**每个活动的任务，必须要先分配给它一个页目录表，并把页目录表的物理地址存入`cr3`寄存器。页表可以提前分配好，也可以在用到的时候再分配**

还是以`mov 0x80495b0, %eax`中的地址为例分析一下线性地址转物理地址的过程

前面说到Linux中逻辑地址等于线性地址，那么我们要转换的线性地址就是`0x80495b0`。转换的过程是由CPU自动完成的，Linux所要做的就是准备好转换所需的页目录表和页表（假设已经准备好，给页目录表和页表分配物理内存的过程很复杂，后面再分析）

内核先将当前任务的页目录表的物理地址填入`cr3`寄存器

线性地址`0x80495b0`转换成二进制后是`0000 1000 0000 0100 1001 0101 1011 0000`，最高`10`位`0000 1000 00`的十进制是`32`，CPU查看页目录表第`32`项，里面存放的是页表的物理地址。线性地址中间`10`位`00 0100 1001`的十进制是`73`，页表的第`73`项存储的是最终物理页的物理起始地址。物理页基地址加上线性地址中最低`12`位的偏移量，CPU就找到了线性地址最终对应的物理内存单元

我们知道Linux中用户进程线性地址能寻址的范围是`0~3G`，那么是不是需要提前先把这3G虚拟内存的页表都建立好呢？一般情况下，物理内存是远远小于3G的，加上同时有很多进程都在运行，根本无法给每个进程提前建立3G的线性地址页表。Linux利用CPU的一个机制解决了这个问题。**进程创建后我们可以给页目录表的表项值都填0，CPU在查找页表时，如果表项的内容为0，则会引发一个缺页异常，进程暂停执行，Linux内核这时候可以通过一系列复杂的算法给分配一个物理页，并把物理页的地址填入表项中，进程再恢复执行**。当然进程在这个过程中是被蒙蔽的，它自己的感觉还是正常访问到了物理内存。

![linux_6](/images/Linux-Memory-Management/linux_6.gif)

# 6 总结

1. 为了解决物理内存地址易导致程序之间相互冲突而崩溃的问题，引入了「内存分段」，或称「段式内存管理」
1. 为了解决「内存分段」的「外部碎片」以及「内存交换效率低」这两个问题，引入了「内存分页」，或称「页式内存管理」
1. 为了解决「内存分页」的「页表空间占用」问题，引入了「多级页表」
1. 为了实现「程序逻辑划分」，同时保持「内存分页」的优势，引入了「段页式内存管理」
1. 由于分段、分页是CPU引入的机制，Linux实现了一种「假的」段页式内存管理，本质上是「页式内存管理」，实现方式是：所有程序，所有段的基地址都是0

# 7 知识碎片

## 7.1 相关命令行

1. `free`
1. `vmstat`
1. `cat /proc/meminfo`
1. `top`
1. `slabtop`

## 7.2 buff/cache

### 7.2.1 什么是buffer/cache？

**简单来说，buffer是为了解决读写速率不一致的问题，比如从内存往磁盘上写数据，往往需要通过buffer来进行缓冲；cache是为了解决热点问题，比如频繁访问一些热点数据，那么就可以把这些热点数据放到读性能更高的存储介质中**

`buffer`和`cache`是两个在计算机技术中被用滥的名词，放在不通语境下会有不同的意义。在Linux的内存管理中，这里的`buffer`指Linux内存的：`buffer cache`。这里的`cache`指Linux内存中的：`page cache`。翻译成中文可以叫做缓冲区缓存和页面缓存。在历史上，它们一个（`buffer`）被用来当成对io设备写的缓存，而另一个（`cache`）被用来当作对io设备的读缓存，这里的io设备，主要指的是块设备文件和文件系统上的普通文件。但是现在，它们的意义已经不一样了。在当前的内核中，`page cache`顾名思义就是针对内存页的缓存，说白了就是，如果有内存是以`page`进行分配管理的，都可以使用`page cache`作为其缓存来管理使用。当然，不是所有的内存都是以页（`page`）进行管理的，也有很多是针对块（`block`）进行管理的，这部分内存使用如果要用到`cache`功能，则都集中到`buffer cache`中来使用。（从这个角度出发，是不是`buffer cache`改名叫做`block cache`更好？）然而，也不是所有块（`block`）都有固定长度，系统上块的长度主要是根据所使用的块设备决定的，而页长度在x86上无论是32位还是64位都是4k

### 7.2.2 什么是page cache？

`page cache`主要用来作为文件系统上的文件数据的缓存来用，尤其是针对当进程对文件有`read／write`操作的时候。如果你仔细想想的话，作为可以映射文件到内存的系统调用：`mmap`是不是很自然的也应该用到`page cache`？在当前的系统实现里，`page cache`也被作为其它文件类型的缓存设备来用，所以事实上`page cache`也负责了大部分的块设备文件的缓存工作

### 7.2.3 什么是buffer cache?

`buffer cache`则主要是设计用来在系统对块设备进行读写的时候，对块进行数据缓存的系统来使用。这意味着某些对块的操作会使用`buffer cache`进行缓存，比如我们在格式化文件系统的时候。一般情况下两个缓存系统是一起配合使用的，比如当我们对一个文件进行写操作的时候，`page cache`的内容会被改变，而`buffer cache`则可以用来将page标记为不同的缓冲区，并记录是哪一个缓冲区被修改了。这样，内核在后续执行脏数据的回写（writeback）时，就不用将整个page写回，而只需要写回修改的部分即可

### 7.2.4 如何回收

Linux内核会在内存将要耗尽的时候，触发内存回收的工作，以便释放出内存给急需内存的进程使用。一般情况下，这个操作中主要的内存释放都来自于对`buffer／cache`的释放。尤其是被使用更多的`cache`空间。既然它主要用来做缓存，只是在内存够用的时候加快进程对文件的读写速度，那么在内存压力较大的情况下，当然有必要清空释放`cache`，作为free空间分给相关进程使用。所以一般情况下，我们认为`buffer/cache`空间可以被释放，这个理解是正确的。

但是这种清缓存的工作也并不是没有成本。理解`cache`是干什么的就可以明白清缓存必须保证`cache`中的数据跟对应文件中的数据一致，才能对`cache`进行释放。所以伴随着`cache`清除的行为的，一般都是系统IO飙高。因为内核要对比`cache`中的数据和对应硬盘文件上的数据是否一致，如果不一致需要写回，之后才能回收。

**如何清理**

1. `sync; echo 1 > /proc/sys/vm/drop_caches`：只清理`PageCache`
1. `sync; echo 2 > /proc/sys/vm/drop_caches`：清理`dentries`以及`inodes`
1. `sync; echo 3 > /proc/sys/vm/drop_caches`：清理`PageCache`、`dentries`以及`inodes`

# 8 参考

* [20 张图揭开「内存管理」的迷雾，瞬间豁然开朗](https://zhuanlan.zhihu.com/p/152119007)
* [线性地址转换为物理地址是硬件实现还是软件实现？具体过程如何？](https://www.zhihu.com/question/23898566)
* [How to Clear RAM Memory Cache, Buffer and Swap Space on Linux](https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/)
* [Linux使用free命令buff/cache过高](https://blog.csdn.net/u014520745/article/details/79949874)
* [linux内存占用问题调查——slab](https://blog.csdn.net/liuxiao723846/article/details/72625394)
* [How much RAM does the kernel use?](https://unix.stackexchange.com/questions/97261/how-much-ram-does-the-kernel-use)
* [Linux系统排查1——内存篇](https://www.cnblogs.com/Security-Darren/p/4685629.html)