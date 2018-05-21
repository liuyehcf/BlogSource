---
title: AVL-tree-详解
date: 2017-07-14 18:45:40
tags: 
- 原创
categories: 
- 数据结构
- 树
---

__阅读更多__

<!--more-->

# 1 前言

AVL-tree是一种平衡二叉树，搜索的平均复杂度是O(log n)。本篇博客将介绍AVL-tree的两种实现方式，其中第二种方式是参考<STL源码剖析>，较第一种方式更为简单高效，推荐第二种方式

# 2 定义

在计算机科学中，AVL树是最先发明的自平衡二叉查找树。在AVL树中任何节点的两个子树的高度最大差别为一，所以它也被称为高度平衡树。查找、插入和删除在平均和最坏情况下都是O（log n）。增加和删除可能需要通过一次或多次树旋转来重新平衡这个树

__节点的属性__

1. __val__：节点的值
1. __left__：节点的左孩子
1. __right__：节点的右孩子
1. __parent__：节点的双亲
1. __height__：节点的高度
* 相比于普通的搜索二叉树，AVL树额外维护了一个高度属性，因为AVL树通过该高度属性来判断树的平衡性

__平衡性质__

1. 每个节点的左子树与右子树的高度最多不超过1
    * __节点的高度__：从给定节点到其最深叶节点所经过的边的数量

# 3 版本1

## 3.1 平衡性破坏分析

为了方便描述，定义几个符号

1. 对于一个节点X，调整(这里的调整特指旋转)之前其高度记为H<sub>x</sub>
1. 仍然对于上述节点X，调整一次后高度记为H<sub>x+</sub>

### 3.1.1 可旋性分析

首先分析左旋，见如下示意图

![fig1](/images/AVL-tree-详解/1.png)

__问题1：何时我们会进行左旋操作__

> 只有当右子树的高度大于左子树的高度才会有左旋的需求。以上图为例，即H<sub>D</sub>=H<sub>A</sub>-1或H<sub>D</sub>=H<sub>A</sub>-2

__问题2：何时左旋后能够达到平衡状态__

> 只有H<sub>C</sub> >= H<sub>E</sub>时，旋转后该子树的所有节点才满足AVL树的性质

下面对于问题2的结论进行分析

1. __旋转前，各节点高度如下__
    * H<sub>D</sub>=H<sub>A</sub>-1或H<sub>D</sub>=H<sub>A</sub>-2
    * H<sub>C</sub>=H<sub>A</sub>-1
    * H<sub>E</sub>=H<sub>A</sub>-1或H<sub>E</sub>=H<sub>A</sub>-2
1. __旋转后，各节点高度如下__
    * H<sub>D+</sub>=H<sub>D</sub>=H<sub>A</sub>-1或H<sub>A</sub>-2
    * H<sub>E+</sub>=H<sub>E</sub>=H<sub>A</sub>-1或H<sub>A</sub>-2
    * H<sub>C+</sub>=H<sub>C</sub>=H<sub>A</sub>-1
    * 旋转后，B节点平衡，H<sub>B</sub>+=H<sub>A</sub>或H<sub>B+</sub>=H<sub>A</sub>-1
    * 旋转后，A节点平衡，H<sub>A</sub>+=H<sub>A</sub>或H<sub>A+</sub>=H<sub>A</sub>+1

然后分析右旋，见如下示意图

![fig2](/images/AVL-tree-详解/2.png)

__问题1：何时我们会进行右旋操作__

> 只有当左子树的高度大于右子树的高度才会有右旋的需求。以上图为例，即H<sub>C</sub>=H<sub>B</sub>-1或H<sub>C</sub>=H<sub>B</sub>-2

__问题2：何时右旋后能够达到平衡状态__

> 只有H<sub>D</sub> >= H<sub>E</sub>时，旋转后该子树的所有节点才满足AVL树的性质

下面对于问题2的结论进行分析

1. __旋转前，各节点高度如下__
    * H<sub>C</sub>=H<sub>B</sub>-1或H<sub>C</sub>=H<sub>B</sub>-2
    * H<sub>D</sub>=H<sub>B</sub>-1
    * H<sub>E</sub>=H<sub>B</sub>-1或H<sub>E</sub>=H<sub>B</sub>-2
1. __旋转后，各节点高度如下__
    * H<sub>D+</sub>=H<sub>D</sub>=H<sub>B</sub>-1
    * H<sub>E+</sub>=H<sub>E</sub>=H<sub>B</sub>-1或H<sub>B</sub>-2
    * H<sub>C+</sub>=H<sub>C</sub>=H<sub>B</sub>-1或H<sub>B</sub>-2
    * 旋转后，A节点平衡，且H<sub>A+</sub>=H<sub>B</sub>或H<sub>A+</sub>=H<sub>B</sub>-1
    * 旋转后，B节点平衡，且H<sub>B+</sub>=H<sub>B</sub>或H<sub>B+</sub>=H<sub>B</sub>+1

__注意：上述分析仅仅讨论了左旋或者右旋一棵子树时，旋转后该子树是否平衡，但是旋转后该子树的高度是可能变化的，也就是对于该子树的父节点而言，可能又会造成不平衡。因此在AVL性质维护函数中需要充分考虑到这一点__

### 3.1.2 平衡性的维护

__当平衡性质被破坏需要右旋来维护性质时__

当C为平衡被破坏的节点，且C的左子树比右子树的高度大2，示意图如下

![fig3](/images/AVL-tree-详解/3.png)

* 需要对C进行一次右旋
* 右旋的前提是H<sub>B</sub> >= H<sub>D</sub>
* 若不满足H<sub>B</sub> >= H<sub>D</sub>，则需要首先对A进行一次左旋，而左旋又存在前提
* 一直往下递归，直至满足旋转条件

__其实，以上的过程存在一个可以优化的点__：

> __假设对C节点的右旋条件不满足，即H<sub>B</sub> < H<sub>D</sub>__，那么此时需要对A节点进行一次左旋。__但是A节点左旋后可能会导致A子树的高度发生变化(可能A节点的高度比旋转前少1)__。如果A子树的高度少1，那么对于节点C就成为一个平衡节点了，就不需要再进行右旋操作了。但是对于下面将要讲的伪代码中，并没有进行这样的优化。也就意味着不管A子树的高度是否发生变化，C的右旋仍然会执行，这样做并不会破坏平衡性(旋转前后都会处于平衡状态)，只是复杂度增高了

__当平衡性质被破坏需要左旋来维护性质时__

当A为平衡被破坏的节点，且A的右子树比左子树的高度大2，示意图如下

![fig4](/images/AVL-tree-详解/4.png)

* 需要对A进行一次左旋
* 左旋的前提是H<sub>E</sub> >= H<sub>D</sub>
* 若不满足H<sub>E</sub> >= H<sub>D</sub>，则需要首先对C进行一次右旋，而右旋又存在前提
* 一直往下递归，直至满足旋转条件

__这里存在一个相同的优化点，不再赘述__

## 3.2 伪代码

### 3.2.1 基本操作

更新指定节点的高度，只有当该节点的左右孩子节点的高度都正确时，才能得到正确的结果

```C
AVL-TREE-HEIGHT(T,x)
if x.left.height≥x.right.height   // 左右节点均存在
    x.height=x.left.height+1
else x.height=x.right.height+1
```

将一棵子树替换掉另一棵子树

```C
AVL-TREE-TRANSPLANT(T,u,v)   // 该函数与红黑树完全一致(都含有哨兵节点)
if u.p==T.nil
    T.root=v
elseif u==u.p.left
    u.p.left=v
else u.p.right=v
    v.p=u.p
```

### 3.2.2 左旋和右旋

左旋给定节点，更新旋转后节点的高度，并返回旋转后子树的根节点

```C
AVL-TREE-LEFT-ROTATE(T,x)
y=x.right
x.right=y.left
if y.left≠T.nil
    y.left.p=x
y.p=x.p
if x.p== T.nil
    T.root=y
elseif x==x.p.left
    x.p.left=y
else x.p.right=y
y.left=x
x.p=y
AVL-TREE-HEIGHT(T,x)
AVL-TREE-HEIGHT(T,y)
// 以上两行顺序不得交换
return y   // 返回旋转后的子树根节点
```

右旋给定节点，更新旋转后节点的高度，并返回旋转后子树的根节点

```C
AVL-TREE-RIGH-TROTATE(T,y)
x=y.left
y.left=x.right
if x.right≠T.nil
    x.right.p=y
x.p=y.p
if y.p==T.nil
    root=x
elseif y==y.p.left
    y.p.left=x
else y.p.right=x
x.right=y
y.p=x
AVL-TREE-HEIGHT(T,y)   
AVL-TREE-HEIGHT(T,x)
// 以上两行顺序不得交换
return x      // 返回旋转后的子树根节点
```

### 3.2.3  性质维护

根据指定方向旋转给定节点，旋转后该子树满足平衡的性质，并且输入的节点必须满足如下性质

> X节点必定是以X为根节点的子树中__唯一__不满足平衡性的节点。意味着X节点的孩子子树的所有节点均满足平衡性。因此，必须从下往上找到第一个不平衡的节点来调用该方法

```C
AVL-TREE-HOLD-ROTATE(T,x,orientation)
let stack1,stack2 be two stacks// 不考虑实际用到的大小，直接用树的大小来分配堆栈空间大小
stack1.push(x)
stack2.push(orientation)
cur=Nil
rotateRoot=Nil // 对x尝试旋转后，返回最终旋转后的根节点
curOrientation=INVALID;
while(!stack1.Empty())
    cur=stack1.top()
    curOrientation=stack2.top()
    if curOrientation==LEFT // 需要对cur尝试进行左旋
        if cur.right.right.height≥cur.right.left.height
            stack1.pop()
            stack2.pop()
            rotateRoot=AVL-TREE-LEFT-ROTATE(T,cur)
        else
            stack1.push(cur.right)// 否则cur右孩子需要尝试进行右旋来调整
            stack2.push(RIGHT);
    elseif curOrientation ==RIGHT// 需要对cur尝试进行右旋
        if cur.left.left.height≥cur.left.right.height
            stack1.pop()
            stack2.pop()
            rotateRoot=AVL-TREE-RIGHT-ROTATE(T,cur)
        else
            stack1.push(cur.left) // 否则cur左孩子需要尝试进行左旋来调整
            stack2.push(LEFT)
return rotateRoot
```

### 3.2.4 插入

插入一个节点

```C
AVL-TREE-TREE-INSERT(T,z)
y=T.nil
x=T.root
while x≠T.nil// 循环结束时x指向空，y指向上一个x
    y=x
    if z.key<x.key
        x=x.left
    else x=x.right
z.p=y// 将这个叶节点作为z的父节点
if y==T.nil
    T.root=z
elseif z.key<y.key
    y.left=z
else y.right=z
z.left=T.nil
z.right=T.nil
AVL-TREE-FIXUP(T,z)
```

从指定节点向上遍历查找不平衡的节点，并维护平衡树的性质

```C
AVL-TREE-FIXUP(T,y) 
if y==T.nil// 为了使删除函数也能调用该函数，因为删除函数传入的参数可能是哨兵
    y=y.p
while(y≠T.nil) // 沿着y节点向上遍历该条路径
    AVL-TREE-HEIGHT(y)
    if y.left.height==y.right.height+2 // 左子树比右子树高2
        y= AVL-TREE-HOLD-ROTATE(T,y,2)
    elseif y.right.height=y.left.height+2    
        y= AVL-TREE-HOLD-ROTATE(T,y,1)
    y=y.p
```

### 3.2.5 删除

删除一个节点

```C
AVL-TREE-DELETE(T,z)
y=z   // x指向将要移动到y原本位置的节点，或者原本y节点的父节点
if z.left==T.nil
    x=y.right
    AVL-TREE-TRANSPLANT(T,z,z.right)
elseif z.right==T.nil
    x=y.left      
    AVL-TREE-TRANSPLANT(T,z,z.left)
 else y=AVL-TREE-MINIMUM(z.right) // 找到z的后继，由于z存在左右孩子，故后继为右子树中的最小值
    x=y.right
    if y.p==z// 如果y是z的右孩子，需要将x的parent指向y(使得x为哨兵节点也满足)
        x.p=y
    else AVL-TREE-TRANSPLANT (T,y,y.right)
        y.right=z.right
        y.right.p=y
    AVL-TREE-TRANSPLANT (T,z,y)
    y.left=z.left
    y.left.p=y
AVL-TREE-FIXUP(T,x)
```

# 4 版本2

与版本1的实现不同，这个版本的分析将会更加简单，实现效率也会更高

## 4.1 几类不平衡情况

当插入一个节点后，某节点A为从插入节点往上找到的第一个平衡性被破坏的节点，__可以分为如下四种情况，又可分为两大类__

1. __第一类：外侧__
    * 插入点位于A的左子节点的左子树--左左
    * 插入点位于A的右子节点的右子树--右右
1. __第二类：内侧__
    * 插入点位于A的左子节点的右子树--左右
    * 插入点位于A的右子节点的左子树--右左

### 4.1.1 第一类不平衡(以左左为例)

为了方便描述，定义几个符号

1. 对于一个节点X，调整(这里的调整特指旋转)之前其高度记为H<sub>x</sub>
1. 仍然对于上述节点X，调整一次后高度记为H<sub>x+</sub>

插入点位于A的左子节点的左子树--左左，见如下示意图

![fig5](/images/AVL-tree-详解/5.png)

__调整前，各节点的高度如下__

* H<sub>B</sub>=H<sub>C</sub>+2
* H<sub>A</sub>=H<sub>C</sub>+2(为什么A和B高度相同，因为B的高度已经更新过了，而A仍然是是插入新节点之前的高度，即尚未维护A节点的height字段)
* H<sub>D</sub>=H<sub>B</sub>-1=H<sub>C</sub>+1
* H<sub>E</sub>必定小于H<sub>D</sub>(否则在新节点插入到节点D为根节点的子树之前，A节点就是不平衡的)，因此H<sub>E</sub>=H<sub>C</sub>

__右旋调整后，各节点的高度如下__

* H<sub>D+</sub>=H<sub>D</sub>=H<sub>C</sub>+1
* H<sub>E+</sub>=H<sub>E</sub>=H<sub>C</sub>
* H<sub>C+</sub>=H<sub>C</sub>
* 由于H<sub>E+</sub>=H<sub>C+</sub>，于是A节点平衡，且H<sub>A+</sub>=H<sub>C</sub>+1
* B节点也是平衡的，且H<sub>B+</sub>=H<sub>C</sub>+2

__可以发现，调整前后子树根节点的高度都是HC+2，因此该节点上层的节点的平衡性不会被破坏，于是通过一次右旋，不平衡性即被消除__

### 4.1.2 第二类不平衡(以左右为例)

为了方便描述，定义几个符号

1. 对于一个节点X，调整(这里的调整特指旋转)之前其高度记为H<sub>x</sub>
1. 仍然对于上述节点X，调整一次后高度记为H<sub>x+</sub>
1. 仍然对于上述节点X，调整二次后高度记为H<sub>x++</sub>

插入点位于A的左子节点的右子树--左右，见如下示意图

![fig6](/images/AVL-tree-详解/6.png)

__调整前，各节点的高度如下__

* H<sub>B</sub>=H<sub>C</sub>+2
* H<sub>A</sub>=H<sub>C</sub>+2(为什么A和B高度相同，因为B的高度已经更新过了，而A仍然是是插入新节点之前的高度，即尚未维护A节点的height字段)
* H<sub>E</sub>=H<sub>B</sub>-1=H<sub>C</sub>+1
* H<sub>D</sub>必定小于H<sub>E</sub>，因此H<sub>D</sub>=H<sub>C</sub>
* H<sub>H</sub>与H<sub>I</sub>至少有一个是H<sub>C</sub>，另一个可以是H<sub>C</sub>或H<sub>C</sub>-1

__对B节点进行一次左旋后，各节点高度如下__

* H<sub>D+</sub>=H<sub>D</sub>=H<sub>C</sub>
* H<sub>H+</sub>=H<sub>H</sub>=H<sub>C</sub> or H<sub>C</sub>-1
* H<sub>I+</sub>=H<sub>I</sub>=H<sub>C</sub> or H<sub>C</sub>-1
* H<sub>C+</sub>=H<sub>C</sub>
* H<sub>A+</sub>=H<sub>A</sub>=H<sub>C</sub>+2
* H<sub>B+</sub>=H<sub>C</sub>+1
* 当H<sub>I+</sub>=H<sub>C</sub>-1时，节点E可能是不平衡的，但是没关系，这只是个中间状态，H<sub>E</sub>=H<sub>C</sub>+2

__对A节点进行一次右旋，各节点高度如下__

* H<sub>D++</sub>=H<sub>D+</sub>=H<sub>C</sub>
* H<sub>H++</sub>=H<sub>H+</sub>= H<sub>C</sub> or H<sub>C</sub>-1
* H<sub>I++</sub>=H<sub>I+</sub>=H<sub>C</sub> or H<sub>C</sub>-1
* H<sub>C++</sub>=H<sub>C+</sub>=H<sub>C</sub>
* 旋转后，B节点平衡，H<sub>B++</sub>=H<sub>C</sub>+1
* 旋转后，A节点平衡，H<sub>A++</sub>=H<sub>C</sub>+1
* 因此旋转后，E节点平衡，H<sub>E++</sub>=H<sub>C</sub>+2

__可以发现，调整前后子树根节点的高度都是HC+2，因此该节点上层的节点的平衡性不会被破坏，于是通过一次左旋和一次右旋，不平衡性即被消除__

## 4.2 伪代码

### 4.2.1 基本操作

更新指定节点的高度，只有当该节点的左右孩子节点的高度都正确时，才能得到正确的结果

```C
AVL-TREE-HEIGHT(T,x)
if x.left.height≥x.right.height   // 左右节点均存在
    x.height=x.left.height+1
else x.height=x.right.height+1
```

将一棵子树替换掉另一棵子树

```C
AVL-TREE-TRANSPLANT(T,u,v)   // 该函数与红黑树完全一致(都含有哨兵节点)
if u.p==T.nil
    T.root=v
elseif u==u.p.left
    u.p.left=v
else u.p.right=v
    v.p=u.p
```

### 4.2.2 左旋和右旋

左旋给定节点，更新旋转后节点的高度，并返回旋转后子树的根节点

```C
AVL-TREE-LEFT-ROTATE(T,x)
y=x.right
x.right=y.left
if y.left≠T.nil
    y.left.p=x
y.p=x.p
if x.p== T.nil
    T.root=y
elseif x==x.p.left
    x.p.left=y
else x.p.right=y
y.left=x
x.p=y
AVL-TREE-HEIGHT(T,x)
AVL-TREE-HEIGHT(T,y)
// 以上两行顺序不得交换
return y   // 返回旋转后的子树根节点
```

右旋给定节点，更新旋转后节点的高度，并返回旋转后子树的根节点

```C
AVL-TREE-RIGHT-ROTATE(T,y)
x=y.left
y.left=x.right
if x.right≠T.nil
    x.right.p=y
x.p=y.p
if y.p==T.nil
    root=x
elseif y==y.p.left
    y.p.left=x
else y.p.right=x
x.right=y
y.p=x
AVL-TREE-HEIGHT(T,y)   
AVL-TREE-HEIGHT(T,x)
// 以上两行顺序不得交换
return x      // 返回旋转后的子树根节点
```

### 4.2.3 插入

插入一个节点

```C
AVL-TREE-INSERT(T,z)
y=T.nil
x=T.root
while x≠T.nil// 循环结束时x指向空，y指向上一个x
    y=x
    if z.key<x.key
        x=x.left
    else x=x.right
z.p=y// 将这个叶节点作为z的父节点
if y==T.nil
    T.root=z
elseif z.key<y.key
    y.left=z
else y.right=z
z.left=T.nil
z.right=T.nil
AVL-TREE-BALANCE-FIX (T,z)
```

维护平衡性质，分别讨论第一类第二类的四种不平衡情况

```C
AVL-TREE--BALANCE-FIX(T,z)
originHigh=z.h
AVL-TREE-HEIGHT(z)
r=z
if z.left.h==z.right.h+2
    if z.left.left.h>=z.left.right.h   // 第一类，等号在插入过程中不可能取到，删除过程中能取到
        r=AVL-TREE-RIGHT-ROTATE(z)
    elseif z.left.left.h<z.left.right.h     // 第二类
        AVL-TREE-LEFT-ROTATE(z.left)
        r=AVL-TREE-RIGHT-ROTATE(z)
    // 不可能出现左右子树高度相同的情况，但是DELETE-FIX中可能出现，注意
elseif z.right.h==z.left.h+2
    if z.right.right.h>=z.right.left.h   // 第一类，等号在插入过程中不可能取到，删除过程中能取到
        r=AVL-TREE-LEFT-ROTATE(z)
    elseif z.right.right.h<z.right.left.h      // 第二类
        AVL-TREE-RIGHT-ROTATE(z.right)
        r=AVL-TREE-LEFT-ROTATE(z)
    // 不可能出现左右子树高度相同的情况，但是DELETE-FIX中可能出现，注意
if r.h!=originHigh and r!=root
    AVL-TREE--BALANCE-FIX(r.parent)
```

### 4.2.4 删除

删除给定关键字

```C
AVL-TREE-DELETE(T,z)
y=z   // x指向将要移动到y原本位置的节点，或者原本y节点的父节点
p=y.parent   // p为被删除节点的父节点
if z.left==T.nil
    AVL-TREE-TRANSPLANT(T,z,z.right)
elseif z.right==T.nil
    AVL-TREE-TRANSPLANT(T,z,z.left)
else y=AVL-TREE-MINIMUM(z.right) // 找到z的后继，由于z存在左右孩子，故后继为右子树中的最小值
    if y==z.right    // 这个边界判断必须，因为p必须定位到被删除节点的父节点
        p=y
    else
        p=y.parent
    AVL-TREE-TRANSPLANT(y,y.right)
    y.right=z.right
    y.right.parent=y
    y.left=z.left
    y.left.parent=y
    AVL-TREE-TRANSPLANT (T,z,y)
    y.height=z.height
if p!=nil
    AVL-TREE--BALANCE-FIX(p)
```

# 5 Java源码

## 5.1 节点定义

```Java
public class AVLTreeNode {
    /**
     * 该节点的高度(从该节点到叶节点的最多边数)
     */
    int h;

    /**
     * 节点的值
     */
    int val;

    /**
     * 该节点的左孩子节点，右孩子节点，父节点
     */
    AVLTreeNode left, right, parent;

    public AVLTreeNode(int val) {
        h = 0;
        this.val = val;
        left = null;
        right = null;
        parent = null;
    }
}
```

## 5.2 版本1

```Java
package org.liuyehcf.algorithm.datastructure.tree.avltree;

import java.util.*;

/**
 * Created by Liuye on 2017/4/27.
 */

public class AVLTree1 {
    private enum RotateOrientation {
        INVALID,
        LEFT,
        RIGHT
    }

    private AVLTreeNode root;

    private AVLTreeNode nil;
    private Map<AVLTreeNode, Integer> highMap;

    public AVLTree1() {
        nil = new AVLTreeNode(0);
        nil.left = nil;
        nil.right = nil;
        nil.parent = nil;
        root = nil;
    }

    public void insert(int val) {
        AVLTreeNode x = root;
        AVLTreeNode y = nil;
        AVLTreeNode z = new AVLTreeNode(val);
        while (x != nil) {
            y = x;
            if (val < x.val) {
                x = x.left;
            } else {
                x = x.right;
            }
        }
        z.parent = y;
        if (y == nil) {
            root = z;
        } else if (z.val < y.val) {
            y.left = z;
        } else {
            y.right = z;
        }
        z.left = nil;
        z.right = nil;
        fixUp(z);
        if (!check())
            throw new RuntimeException();
    }

    private void fixUp(AVLTreeNode y) {
        if (y == nil) {
            y = y.parent;
        }
        while (y != nil) {
            updateHigh(y);
            if (y.left.h == y.right.h + 2)
                y = holdRotate(y, RotateOrientation.RIGHT);
            else if (y.right.h == y.left.h + 2)
                y = holdRotate(y, RotateOrientation.LEFT);
            y = y.parent;
        }
    }

    private AVLTreeNode holdRotate(AVLTreeNode x, RotateOrientation orientation) {
        LinkedList<AVLTreeNode> stack1 = new LinkedList<AVLTreeNode>();
        LinkedList<RotateOrientation> stack2 = new LinkedList<RotateOrientation>();
        stack1.push(x);
        stack2.push(orientation);
        AVLTreeNode cur = nil;
        AVLTreeNode rotateRoot = nil;
        RotateOrientation curOrientation = RotateOrientation.INVALID;
        while (!stack1.isEmpty()) {
            cur = stack1.peek();
            curOrientation = stack2.peek();
            if (curOrientation == RotateOrientation.LEFT) {
                if (cur.right.right.h >= cur.right.left.h) {
                    stack1.pop();
                    stack2.pop();
                    rotateRoot = leftRotate(cur);
                } else {
                    stack1.push(cur.right);
                    stack2.push(RotateOrientation.RIGHT);
                }
            } else if (curOrientation == RotateOrientation.RIGHT) {
                if (cur.left.left.h >= cur.left.right.h) {
                    stack1.pop();
                    stack2.pop();
                    rotateRoot = rightRotate(cur);
                } else {
                    stack1.push(cur.left);
                    stack2.push(RotateOrientation.LEFT);
                }
            }
        }
        return rotateRoot;
    }

    private void updateHigh(AVLTreeNode z) {
        z.h = Math.max(z.left.h, z.right.h) + 1;
    }

    /**
     * 左旋
     *
     * @param x
     * @return 返回旋转后的根节点
     */
    private AVLTreeNode leftRotate(AVLTreeNode x) {
        AVLTreeNode y = x.right;
        x.right = y.left;
        if (y.left != nil) {
            y.left.parent = x;
        }
        y.parent = x.parent;
        if (x.parent == nil) {
            root = y;
        } else if (x == x.parent.left) {
            x.parent.left = y;
        } else {
            x.parent.right = y;
        }
        y.left = x;
        x.parent = y;

        // 更新高度
        updateHigh(x);
        updateHigh(y);
        return y;
    }

    /**
     * 右旋
     *
     * @param y
     * @return 返回旋转后的根节点
     */
    private AVLTreeNode rightRotate(AVLTreeNode y) {
        AVLTreeNode x = y.left;
        y.left = x.right;
        if (x.right != nil) {
            x.right.parent = y;
        }
        x.parent = y.parent;
        if (y.parent == nil) {
            root = x;
        } else if (y == y.parent.left) {
            y.parent.left = x;
        } else {
            y.parent.right = x;
        }
        x.right = y;
        y.parent = x;

        // 更新高度
        updateHigh(y);
        updateHigh(x);
        return x;
    }

    private boolean check() {
        highMap = new HashMap<AVLTreeNode, Integer>();
        return checkHigh(root) && checkBalance(root);
    }

    private boolean checkHigh(AVLTreeNode root) {
        if (root == nil) return true;
        return checkHigh(root.left) && checkHigh(root.right) && root.h == high(root);
    }

    private int high(AVLTreeNode root) {
        if (root == nil) {
            return 0;
        }
        if (highMap.containsKey(root)) return highMap.get(root);
        int leftHigh = high(root.left);
        int rightHigh = high(root.right);
        highMap.put(root, Math.max(leftHigh, rightHigh) + 1);
        return highMap.get(root);
    }

    private boolean checkBalance(AVLTreeNode root) {
        if (root == nil) {
            return true;
        }
        int leftHigh = root.left.h;
        int rightHigh = root.right.h;
        if (Math.abs(leftHigh - rightHigh) == 2) return false;
        return checkBalance(root.left) && checkBalance(root.right);
    }

    public boolean search(int val) {
        return search(root, val) != nil;
    }

    private AVLTreeNode search(AVLTreeNode x, int val) {
        while (x != nil) {
            if (x.val == val) return x;
            else if (val < x.val) {
                x = x.left;
            } else {
                x = x.right;
            }
        }
        return nil;
    }

    public void delete(int val) {
        AVLTreeNode z = search(root, val);
        if (z == nil) {
            throw new RuntimeException();
        }
        AVLTreeNode y = z;
        AVLTreeNode x = nil;
        if (z.left == nil) {
            x = y.right;
            transplant(z, z.right);
        } else if (z.right == nil) {
            x = y.left;
            transplant(z, z.left);
        } else {
            y = min(z.right);
            x = y.right;
            if (y.parent == z) {
                x.parent = y;
            } else {
                transplant(y, y.right);
                y.right = z.right;
                y.right.parent = y;
            }
            transplant(z, y);

            y.left = z.left;
            y.left.parent = y;

            // todo 这里不需要更新p的高度,因为p的子树的高度此时并不知道是否正确,因此更新也没有意义,这也是deleteFixBalance必须遍历到root的原因
        }
        fixUp(x);
        if (!check())
            throw new RuntimeException();
    }

    private void transplant(AVLTreeNode u, AVLTreeNode v) {
        v.parent = u.parent;
        if (u.parent == nil) {
            root = v;
        } else if (u == u.parent.left) {
            u.parent.left = v;
        } else {
            u.parent.right = v;
        }
    }

    private AVLTreeNode min(AVLTreeNode x) {
        while (x.left != nil) {
            x = x.left;
        }
        return x;
    }

    public void inOrderTraverse() {
        inOrderTraverse(root);
        System.out.println();
    }

    public void levelOrderTraversal() {
        Queue<AVLTreeNode> queue = new LinkedList<AVLTreeNode>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int len = queue.size();
            for (int i = 0; i < len; i++) {
                AVLTreeNode peek = queue.poll();
                System.out.print("[" + peek.val + "," + peek.h + "], ");
                if (peek.left != nil) queue.offer(peek.left);
                if (peek.right != nil) queue.offer(peek.right);
            }
        }
        System.out.println();
    }

    private void inOrderTraverse(AVLTreeNode root) {
        if (root != nil) {
            inOrderTraverse(root.left);
            System.out.print(root.val + ", ");
            inOrderTraverse(root.right);
        }
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();

        Random random = new Random();

        int TIMES = 10;

        while (--TIMES > 0) {
            System.out.println("剩余测试次数: " + TIMES);
            AVLTree1 avlTree2 = new AVLTree1();

            int N = 1000;
            int M = N / 2;

            Set<Integer> set = new HashSet<Integer>();
            for (int i = 0; i < N; i++) {
                set.add(random.nextInt());
            }

            List<Integer> list = new ArrayList<Integer>(set);
            Collections.shuffle(list, random);
            // 插入N个数据
            for (int i : list) {
                avlTree2.insert(i);
            }

            // 删除M个数据
            Collections.shuffle(list, random);

            for (int i = 0; i < M; i++) {
                set.remove(list.get(i));
                avlTree2.delete(list.get(i));
            }

            // 再插入M个数据
            for (int i = 0; i < M; i++) {
                int k = random.nextInt();
                set.add(k);
                avlTree2.insert(k);
            }
            list.clear();
            list.addAll(set);
            Collections.shuffle(list, random);

            // 再删除所有元素
            for (int i : list) {
                avlTree2.delete(i);
            }
        }
        long end = System.currentTimeMillis();
        System.out.println("Run time: " + (end - start) / 1000 + "s");
    }
}
```

## 5.3 版本2

```Java
package org.liuyehcf.algorithm.datastructure.tree.avltree;

import java.util.*;

/**
 * Created by liuye on 2017/4/24 0024.
 */

public class AVLTree2 {
    private AVLTreeNode root;

    private AVLTreeNode nil;
    private Map<AVLTreeNode, Integer> highMap;

    public AVLTree2() {
        nil = new AVLTreeNode(0);
        nil.left = nil;
        nil.right = nil;
        nil.parent = nil;
        root = nil;
    }

    public void insert(int val) {
        AVLTreeNode x = root;
        AVLTreeNode y = nil;
        AVLTreeNode z = new AVLTreeNode(val);
        while (x != nil) {
            y = x;
            if (val < x.val) {
                x = x.left;
            } else {
                x = x.right;
            }
        }
        z.parent = y;
        if (y == nil) {
            root = z;
        } else if (z.val < y.val) {
            y.left = z;
        } else {
            y.right = z;
        }
        z.left = nil;
        z.right = nil;
        balanceFix(z);
        if (!check())
            throw new RuntimeException();
    }

    private void balanceFix(AVLTreeNode z) {
        // 当前节点的初始高度
        int originHigh = z.h;

        updateHigh(z);

        // 经过调整后的子树根节点(调整之前子树根节点为z)
        AVLTreeNode r = z;

        if (z.left.h == z.right.h + 2) {
            // todo 这里的等号非常重要(插入过程时不可能取等号，删除过程可能取等号)
            if (z.left.left.h >= z.left.right.h) {
                r = rightRotate(z);
            } else if (z.left.left.h < z.left.right.h) {
                leftRotate(z.left);
                r = rightRotate(z);
            }

        } else if (z.right.h == z.left.h + 2) {
            // todo 这里的等号非常重要(插入过程时不可能取等号，删除过程可能取等号)
            if (z.right.right.h >= z.right.left.h) {
                r = leftRotate(z);
            } else if (z.right.right.h < z.right.left.h) {
                rightRotate(z.right);
                r = leftRotate(z);
            }
        }

        // 递归其父节点
        if (r.h != originHigh && r != root)
            balanceFix(r.parent);
    }

    private void updateHigh(AVLTreeNode z) {
        z.h = Math.max(z.left.h, z.right.h) + 1;
    }

    /**
     * 左旋
     *
     * @param x
     * @return 返回旋转后的根节点
     */
    private AVLTreeNode leftRotate(AVLTreeNode x) {
        AVLTreeNode y = x.right;
        x.right = y.left;
        if (y.left != nil) {
            y.left.parent = x;
        }
        y.parent = x.parent;
        if (x.parent == nil) {
            root = y;
        } else if (x == x.parent.left) {
            x.parent.left = y;
        } else {
            x.parent.right = y;
        }
        y.left = x;
        x.parent = y;

        // 更新高度
        updateHigh(x);
        updateHigh(y);
        return y;
    }

    /**
     * 右旋
     *
     * @param y
     * @return 返回旋转后的根节点
     */
    private AVLTreeNode rightRotate(AVLTreeNode y) {
        AVLTreeNode x = y.left;
        y.left = x.right;
        if (x.right != nil) {
            x.right.parent = y;
        }
        x.parent = y.parent;
        if (y.parent == nil) {
            root = x;
        } else if (y == y.parent.left) {
            y.parent.left = x;
        } else {
            y.parent.right = x;
        }
        x.right = y;
        y.parent = x;

        // 更新高度
        updateHigh(y);
        updateHigh(x);
        return x;
    }

    private boolean check() {
        highMap = new HashMap<AVLTreeNode, Integer>();
        return checkHigh(root) && checkBalance(root);
    }

    private boolean checkHigh(AVLTreeNode root) {
        if (root == nil) return true;
        return checkHigh(root.left) && checkHigh(root.right) && root.h == high(root);
    }

    private int high(AVLTreeNode root) {
        if (root == nil) {
            return 0;
        }
        if (highMap.containsKey(root)) return highMap.get(root);
        int leftHigh = high(root.left);
        int rightHigh = high(root.right);
        highMap.put(root, Math.max(leftHigh, rightHigh) + 1);
        return highMap.get(root);
    }

    private boolean checkBalance(AVLTreeNode root) {
        if (root == nil) {
            return true;
        }
        int leftHigh = root.left.h;
        int rightHigh = root.right.h;
        if (Math.abs(leftHigh - rightHigh) == 2) return false;
        return checkBalance(root.left) && checkBalance(root.right);
    }

    public boolean search(int val) {
        return search(root, val) != nil;
    }

    private AVLTreeNode search(AVLTreeNode x, int val) {
        while (x != nil) {
            if (x.val == val) return x;
            else if (val < x.val) {
                x = x.left;
            } else {
                x = x.right;
            }
        }
        return nil;
    }

    public void delete(int val) {
        AVLTreeNode z = search(root, val);
        if (z == nil) {
            throw new RuntimeException();
        }
        // y代表真正被删除的节点
        AVLTreeNode y = z;
        // x为被删除节点的父节点，如果平衡被破坏，从该节点开始
        AVLTreeNode p = y.parent;
        if (z.left == nil) {
            transplant(z, z.right);
        } else if (z.right == nil) {
            transplant(z, z.left);
        } else {
            y = min(z.right);
            // todo 这里的分类讨论非常重要,否则将会定位到错误的父节点
            if (y == z.right) {
                p = y;
            } else {
                p = y.parent;
            }
            transplant(y, y.right);

            // todo 下面六句可以用z.val=y.val来代替,效果一样
            y.right = z.right;
            y.right.parent = y;

            y.left = z.left;
            y.left.parent = y;

            transplant(z, y);
            y.h = z.h;// todo 这里高度必须维护
            // todo 这里不需要更新p的高度,因为p的子树的高度此时并不知道是否正确,因此更新也没有意义,这也是deleteFixBalance必须遍历到root的原因
        }
        if (p != nil)
            balanceFix(p);
        if (!check())
            throw new RuntimeException();
    }

    private void transplant(AVLTreeNode u, AVLTreeNode v) {
        v.parent = u.parent;
        if (u.parent == nil) {
            root = v;
        } else if (u == u.parent.left) {
            u.parent.left = v;
        } else {
            u.parent.right = v;
        }
    }

    private AVLTreeNode min(AVLTreeNode x) {
        while (x.left != nil) {
            x = x.left;
        }
        return x;
    }

    public void inOrderTraverse() {
        inOrderTraverse(root);
        System.out.println();
    }

    public void levelOrderTraversal() {
        Queue<AVLTreeNode> queue = new LinkedList<AVLTreeNode>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int len = queue.size();
            for (int i = 0; i < len; i++) {
                AVLTreeNode peek = queue.poll();
                System.out.print("[" + peek.val + "," + peek.h + "], ");
                if (peek.left != nil) queue.offer(peek.left);
                if (peek.right != nil) queue.offer(peek.right);
            }
        }
        System.out.println();
    }

    private void inOrderTraverse(AVLTreeNode root) {
        if (root != nil) {
            inOrderTraverse(root.left);
            System.out.print(root.val + ", ");
            inOrderTraverse(root.right);
        }
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();

        Random random = new Random();

        int TIMES = 10;

        while (--TIMES > 0) {
            System.out.println("剩余测试次数: " + TIMES);
            AVLTree2 avlTree = new AVLTree2();

            int N = 10000;
            int M = N / 2;

            List<Integer> list = new ArrayList<Integer>();
            for (int i = 0; i < N; i++) {
                list.add(random.nextInt());
            }

            Collections.shuffle(list, random);
            // 插入N个数据
            for (int i : list) {
                avlTree.insert(i);
            }

            // 删除M个数据
            Collections.shuffle(list, random);

            for (int i = 0; i < M; i++) {
                int k = list.get(list.size() - 1);
                list.remove(list.size() - 1);
                avlTree.delete(k);
            }

            // 再插入M个数据
            for (int i = 0; i < M; i++) {
                int k = random.nextInt();
                list.add(k);
                avlTree.insert(k);
            }
            Collections.shuffle(list, random);

            // 再删除所有元素
            for (int i : list) {
                avlTree.delete(i);
            }
        }
        long end = System.currentTimeMillis();
        System.out.println("Run time: " + (end - start) / 1000 + "s");
    }
}
```
