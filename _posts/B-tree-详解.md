---
title: B-tree 详解
date: 2017-07-14 18:45:53
tags: 原创
categories:
- 数据结构
- 树
---

__目录__

<!-- toc -->
<!--more-->

# B树的定义

## 节点

__节点的属性__
1. n：关键字个数
1. key：关键字数组
1. c：孩子数组
1. leaf：是否为叶节点

__每个节点具有以下性质__
1. x.n：当前存储在节点x中的关键字个数
1. x.n个关键字本身x.key<sub>1</sub>, x.key<sub>2</sub>, ..., x.key<sub>x.n</sub>，以非降序存放，使得
x.key<sub>1</sub>≤x.key<sub>2</sub>≤...≤x.key<sub>x.n</sub>
1. x.leaf：一个布尔值，如果x是叶节点，则为TRUE，如果x为内部节点，则为FALSE
1. 每个内部节点x还包含x.n+1个指向其孩子的指针，x.c<sub>1</sub>, x.c<sub>2</sub>, ..., x.c<sub>x.n+1</sub>，叶节点没有孩子，所以他们的c属性没有定义
1. 关键字x.key<sub>i</sub>对存储在各子树中的关键字范围加以分割：如果k<sub>i</sub>为任意一个存储在以x.c<sub>i</sub>为根的子树中的关键字，那么
k<sub>1</sub>≤x.key<sub>1</sub>≤k<sub>2</sub>≤x.key<sub>2</sub>≤…≤x.key<sub>x.n</sub>≤k<sub>x.n+1</sub>
1. __每个叶节点都具有相同的深度，即树的高度h__
1. __每个节点所包含的关键字个数有上界和下界，用一个被称为B数的最小度数(minimum degree)的固定整数t≥2来表示这些界__

* __除了根节点以外的每个节点必须至少有t-1个关键字，因此除了根节点以外的每个内部节点至少有t个孩子，如果树非空，根节点至少含有一个关键字__
* __每个节点至多可包含2t-1个关键字，因此，一个内部节点最多可有2t个孩子，当一个节点恰好有2t-1个关键字时，称该节点是满的__
* t=2时的B树是最简单的，在实际中，t的值越大，B树的高度就越小


## 树

__属性__
1. t：B树的度
1. root：B树的根节点

__性质__

1. 对于节点x ，关键字x.key<sub>i</sub>与子树指针x.c<sub>i</sub>的索引相同，就说x.c<sub>i</sub>是关键字x.key<sub>i</sub>对应的子树指针
1. 子树x.c<sub>i</sub>的元素介于x.key<sub>i-1</sub>~x.key<sub>i</sub>之间 1≤i≤x.n+1，为保持一致性，记x.key<sub>0</sub>= -∞，x.key<sub>x.n+1</sub>=+∞


# 伪代码

## Split

分裂给定节点，分裂操作会产生一个新的节点，该新节点会插入到父节点当中，并含有分裂前一半的关键字数量以及孩子数量(非叶子节点的分裂才需要考虑孩子)

1. 要分裂的节点必须是满节点，即关键字数目为2t-1
1. 要分裂的节点的父节点必须是非满节点

```
B-TREE-SPLIT-CHILD(x,i)//x.ci是满节点，x是非满节点
z=ALLOCATE-NODE()//z是由y的一半分裂得到
y=x.c[i]
z.leaf=y.leaf
z.n=t-1
for j=1 to t-1
    z.key[j]=y.key[j+t] //将y中[t+1…2t-1]总共t-1个关键字复制到节点z中作为[1…t-1]的关键字，其中第t个关键字会提取出来作为x节点的关键字
if not y.leaf//如果y不是叶节点，那么y还有t个指针需要复制到z中
    for j=1 to t
        z.c[j]=y.c[j+t]
y.n=t-1
for j=x.n+1 downto i+1//指针y和z必然是相邻的，并且他们所夹的关键字就是原来y中第t个
    x.c[j+1]=x.c[j]
x.c[i+1]=z
for j=x.n downto i
    x.key[j+1]=x.key[j]
x.key[i]=y.key[t]
x.n=x.n+1
DISK-WRITE(y)
DISK-WRITE(z)
DISK-WRITE(x)
```

## Merge

合并两个节点

1. 合并的两个节点，其关键字数量必须是t-1
1. 合并节点的父节点含有的关键字数目必须大于t-1

```Java
B-TREE-MERGE(x,i,y,z)
y.n=2t-1
for j=t+1 to 2t-1
    y.key[j]=z.key[j-t]
y.key[t]=x.key[i] //the key from node x merge to node y as the tth key
if not y.leaf
    for j=t+1 to 2t
        y.c[j]=z.c[j-t]
for j=i+1 to x.n
    x.key[j-1]=x.key[j]
    x.c[j]=x.c[j+1]
x.n=x.n-1   
Free(z)
```

## Shift

shift方法用于删除操作时，为了保证递归的节点关键字数量大于t-1，要从左边或者右边挪一个节点到当前节点，这两个方法就是执行这个操作，当且仅当左右节点的关键字数量均为t-1时(即没有多余的关键字可以挪给其他节点了)，才执行merge操作

```C
B-TREE-SHIFT-TO-LEFT-CHILD(x,i,y,z)
y.n=y.n+1
y.key[y.n]=x.key[i]
x.key[i]=z.key[1]
z.n=z.n-1
j=1
while j≤z.n
    z.key[j]=z.key[j+1]
    j=j+1
if not z.leaf
    y.c[y.n+1]=z.c[1]
    j=1 
    while j≤z.n+1
        z.c[j]=z.c[j+1]
        j++     
DISK-WRITE(y)
DISK-WRITE(z)
DISK-WRITE(x)
```


```C
B-TREE-SHIFT-TO-RIGHT-CHILD(x,i,y,z)
z.n=z.n+1
j=z.n
while j>1
    z.key[j]=z.key[j-1]
    j--
z.key[1]=x.key[i]
x.key[i]=y.key[y.n]
if not z.leaf
    j=z.n
    while j>0
        z.c[j+1]=z.c[j]
        j--
    z.c[1]=y.c[y.n+1]
y.n=y.n-1
DISK-WRITE(y)
DISK-WRITE(z)
DISK-WRITE(x)

```

## 插入

B树的插入操作从本质上来说是自底向上的

1. 首先将关键字插入到叶节点
1. 如果叶节点在插入之前就是满的，那么需要进行分裂操作，而分裂操作又会产生一个新节点插入到父节点中，如果父节点此时也是满的，那么首先需要分裂父节点...递归向上...

> 这种做法存在一个问题，因为需要访问父节点，如果持有一个父节点的指针那么会导致空间浪费，如果不持有父节点的指针，那么父节点的查找又会比较耗时。而且这种做法复杂度相对较高，实现较繁琐

因此采用了一种自顶向下__预分裂__的做法

1. 进行关键字插入操作时，会有一条从根节点到叶节点的访问路径
1. 在该条访问路径上，一旦某个节点已经满了，那么预先进行一次分裂操作(需要区分根节点与其他节点，如果根节点满了，则树高需要增加1)
1. 在进行分裂操作时，由于上一条规则可以保证，进行分裂操作的节点的父节点必定不为满节点，因此不会触发递归向上的分裂操作

下面的伪代码就是自顶向下的__预分裂__


根节点需要单独讨论

```
B-TREE-INSERT(T,k)
r=T.root
if r.n==2t-1 //需要处理根节点，若满了，则进行一次分裂，这是树增高的唯一方式
    s=ALLOCATE-NODE()//分配一个节点作为根节点
    T.root=s
    s.leaf=FLASE//显然由分裂生成的根必然是内部节点
    s.n=0
    s.c[1]=r//之前的根节点作为新根节点的第一个孩子
    B-TREE-SPLIT-CHILD(s,1)
    B-TREE-INSERT-NONFULL(s,k)
else B-TREE-INSERT-NONFULL(r,k)
```

以下是非根节点的递归插入操作

1. 参数x必定是非满节点

```
B-TREE-INSERT-NONFULL(x,k)
i=x.n
if x.leaf //如果是叶节点，保证是非满的，找到适当的位置插入即可
    while i ≥1 and k<x.key[i]
        x.key[i+1]=x.key[i]
        i=i-1
    x.key[i+1]=k
    x.n=x.n+1
    DISK-WRITE(x)
else while i ≥ 1 and k<x.key[i]
        i=i-1
    i=i+1//转到对应的指针坐标
    DISK-READ(x.c[i])
    if x.c[i.n]==2t-1
        B-TREE-SPLIT-CHILD(x,i)
        if k>x.key[i]  //原来在i位置的关键字现在在i+1位置上，i位置上是y.key[t]
            i=i+1
    B-TREE-INSERT-NONFULL(x.c[i],k) 
```

## 删除

B树的删除操作本质上来说是自底向上的

1. 首先找到要删除关键字的节点
1. 如果该节点的关键字数量为t-1，则需要进行shift或者merge操作
1. 如果执行了merge操作会使得父节点的关键字数量减少1，如果父节点的关键字数量也是t-1，则父节点可能首先要进行一次merge...递归向上...

> 这种做法存在一个问题，因为需要访问父节点，如果持有一个父节点的指针那么会导致空间浪费，如果不持有父节点的指针，那么父节点的查找又会比较耗时。而且这种做法复杂度相对较高，实现较繁琐

因此采用了一种自顶向下__预合并__的做法

1. 进行关键字删除操作时，会有一条从根节点到被删除的关键字所在节点的访问路径
1. 在该条访问路径上，一旦某个节点的关键字数量为t-1，那么预先进行一次合并操作(需要区分根节点与其他节点，如果根节点关键字数量为1，则树高需要减少1)
1. 在进行合并操作时，由于上一条规则可以保证，进行合并操作的节点的父节点的关键字数量必定大于t-1，因此不会触发递归向上的合并操作


下面的伪代码就是自顶向下的__预合并__


根节点需要单独讨论

```
B-TREE-DELETE(T,k) //以下都是delete会用到的函数
r=T.root
if r.n==1
    DISK-READ(r.c[1])
    DISK-READ(r.c[2])
    y=r.c[1]
    z=r.c[2]
    if not r.leaf and y.n==z.n==t-1
        B-TREE-MERGE-CHILD(r,1,y,z)
        T.root=y
        FREE-NODE(r)
        B-TREE-DELETE-NOTNONE(y,k)
    else B-TREE-DELETE-NOTNONE(r,k)
else B-TREE-DELETE-NOTNONE(r,k)
```

以下是非根节点的递归删除操作

1. 参数x的关键字数量必定大于t-1


```
B-TREE-DELETE-NOTNONE(x,k)
i=1
if x.leaf
    while i ≤ x.n and k>x.key[i]
        i=i+1
    if k==x.key[i]
        for j=i+1 to x.n
            x.key[j-1]=x.key[j]
        x.n=x.n-1
        DISK-WRITE(x)
    else error:”the key does not exist”
else 
    while i ≤ x.n and k>x.key[i]
        i=i+1
    DISK-READ(x.c[i])
    y=x.c[i]
    if i ≤ x.n
        DISK-READ(x.c[i+1])
        z=x.c[i+1]
    if i ≤ x.n and k==x.key[i]       //Cases 2
        if y.n>t-1    //Cases 2a
            k’=B-TREE-MIMIMUM(y)
            B-TREE-DELETE-NOTNONE(y,k’)
            x.key[i]=k’
        elseif z.n>t-1  //Case 2b
            k’=B-TREE-MAXIMUM(z)
            B-TREE-DELETE-NOTNONE(z,k’)
            x.key[i]=k’
        else B-TREE-MERGE-CHILD(x,i,y,z) //Cases 2c
            B-TREE-DELETE-NOTNONE(y,k)
    else   //Cases3
        if i>1
            DISK-READ(x.c[i-1])
            p=x.c[i-1]
        if y.n==t-1
            if i>1 and p.n>t-1  //Cases 3a
                B-TREE-SHIFT-TO-RIGHT-CHILD(x,i-1,p,y)
            elseif i ≤ x.n and z.n>t-1
                B-TREE-SHIFT-TO-LEFT-CHILD(x,i,y,z)
            elseif i>1  //Cases 3b
                B-TREE-MERGE-CHILD(x,i-1,p,y)
                y=p
            else B-TREE-MERGE-CHILD(x,i,y,z) //Cases 3c
        B-TREE-DELETE-NOTNONE(y,k)
```

删除操作大致上可以分为三类

1. 删除的关键字在叶节点上，删除即可
1. 删除的关键字位于某个中间节点，在左子树中找最大值或者右子树中找最小值代替当前的值，然后递归删除这个最小或者最大值
1. 继续在子树中查找被删除的节点，必须保证递归时的节点关键字大于t-1，当关键字为t-1时，需要执行shift或者merge操作

# Java代码



