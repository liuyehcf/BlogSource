---
title: BPlus-tree-详解
date: 2017-07-14 18:47:22
tags: 
- 原创
categories: 
- Data Structure
- Tree
---

__阅读更多__

<!--more-->

# 1 定义

## 1.1 节点

__节点的属性__

1. n：关键字个数
1. key：关键字数组
1. c：孩子数组
1. leaf：是否为叶节点
1. next：右兄弟节点，当节点为叶子节点时该字段才有用

__节点的性质__

1. 节点关键字的个数
    * 根节点：[1,2t]个关键字
    * 非根节点[t,2t]个关键字
1. 所有叶子节点连接成一个单向链表

## 1.2 树

__属性__

1. t：B+树的度
1. root：根节点
1. data：第一个叶节点

__与B树的区别__

1. 所有的关键字均存储在叶节点中
1. 非叶节点中的关键字仅仅起到索引作用
1. 索引关键字不一定存在于叶节点中(由于删除，会导致该索引关键字从叶节点删除，但是索引关键字的索引作用仍然成立)
1. 每个非叶节点的索引关键字是该索引关键字对应的子树的最值的上届(由于删除，可能取不到)，可以任选一种来实现(本章选用的是最大值)
1. 非叶子节点的关键字数量和孩子数量一一对应，而B-tree中，孩子数量要比关键字数量多1
1. 所有叶子节点通过next指针串接起来，这样一来范围内的遍历要非常快捷

B+-tree示意图如下

![fig1](/images/BPlus-tree-详解/1.png)

# 2 伪代码

B+-tree的操作与B-tree的操作基本类似，注意维护好非叶子节点关键字的索引性质即可

## 2.1 Split

分裂一个节点

1. x.c[i]是满节点
1. x是非满节点

```C
B+-TREE-SPLIT-CHILD(x,i)//x.ci是满节点，x是非满节点
y=x.c[i]
z= ALLOCATE-NODE()
y.n=z.n=t
for j=1 to t
    z.key[j]=y.key[j+t]
if not y.leaf
    for j=1 to t
        z.c[j]=y.c[j+t]
else
    z.next=y.next
    y.next=z
z.leaf=y.leaf
for j=x.n+1 downto i+2
    x.key[j]=x.key[j-1]
    x.c[j]=x.c[j-1]
x.key[i+1]=x.key[i]//新增节点的索引值为原索引值
x.key[i]=y.key[y.n]//原节点的索引值为现有y中最大的值
x.c[i+1]=z
x.n++
```

## 2.2 Merge

合并指定节点，合并x.c[i]和x.c[i+1]

1. x.c[i]和x.c[i+1]关键字数量必定为t
1. x的关键字数量必定大于t

```C
B+-TREE-MERGE(x,i)
y=x.c[i]
z=x.c[i+1]
y.n=2t
for j=1 to t
    y.key[j+t]=z.key[j]
if not y.leaf
    for j=1 to t
        y.c[j+t]=z.c[j]
else
    y.next=z.next
for j=i+1 to x.n-1
    x.key[j]=x.key[j+1]
    x.c[j]=x.c[j+1]
x.key[i]=y.key[y.n]//更新索引值
x.n--
```

## 2.3 Shift

shift方法用于删除操作时，为了保证递归的节点关键字数量大于t，要从左边或者右边挪一个节点到当前节点，这两个方法就是执行这个操作，当且仅当左右节点的关键字数量均为t时(即没有多余的关键字可以挪给其他节点了)，才执行merge操作

shift操作会导致左侧节点的索引失效，但仅仅需要改动该父节点即可（即不会触发递归向上的索引值修改），因为父节点需要修改的索引必定不是父节点的最值

```C
B+-TREE-SHIFT-TO-LEFT-CHILD(x,i)
y=x.c[i]
z=x.c[i+1]
y.key[y.n+1]=z.key[1]
for j=1 to z.n-1
    z.key[j]=z.key[j+1]
if not y.leaf
    y.c[y.n+1]=z.c[1]
    for j=1 to z.n-1
        z.c[j]=z.c[j+1]
y.n++
z.n--
x.key[i]=y.key[y.n]
```

```C
B+-TREE-SHIFT-TO-RIGHT-CHILD(x,i)
p=x.c[i]
y=x.c[i+1]
for j=y.n+1 downto 2
    y.key[j]=y.key[j-1]
y.key[1]=p.key[p.n]
if not y.leaf
    for j=y.n+1 downto 2
        y.c[j]=y.c[j-1]
    y.c[1]=p.c[p.n]
y.n++
p.n--
x.key[i]=p.key[p.n]
```

## 2.4 插入

为了避免额外的父节点指针以及实现复杂度，采用了自顶向下的__预分裂__式的插入操作

```C
B+-TREE-INSERT(k)
if root.n==2t
    newRoot= ALLOCATE-NODE()
    newRoot.n=1
    newRoot.key[1]=root.key[2t]
    newRoot.c[1]=root
    newRoot.leaf=false
    root=newRoot
    B+-TREE-SPLIT-CHILD (root,1)
B+TREE-INSERT-NOT-FULL(root,k)
```

```C
B+TREE-INSERT-NOT-FULL(x,k)
i=x.n
if x.leaf
    while i>=1 and x.key[i]>k
        x.key[i+1]=x.key[i]
        i--
    i++
    x.key[i]=k
    x.n++
else
    while i>=1 and x.key[i]>=k   //这个等于至关重要，虽然B+树节点不会重复，但是由于删除操作的存在，留在树中的索引关键字未必存在于叶节点中，因此这里需要加上等号
        i--
    i++
    if x.n+1==i   //这里至关重要，插入节点时需要维护索引的正确性，就在这唯一一处进行维护
        x.key[x.n]=k
        i--
y=x.c[i]
if y.n==2t
    B+-TREE-SPLIT-CHILD(x,i)
    if k>y.key[y.n]
        i++
B+TREE-INSERT-NOT-FULL(x.c[i],k)
```

## 2.5 删除

为了避免额外的父节点指针以及实现复杂度，采用了自顶向下的__预分裂__式的插入操作

```C
B+-TREE-DELETE(k)
if not root.leaf and root.n==1
    root=root.c[1]
if root.n==2
    if not root.leaf and root.c[1].n==t and root.c[2].n==t
        B+-TREE-MERGE(root,1)
B+-TREE-DELETE-NOT-NONE(root,k)
```

```C
B+-TREE-DELETE-NOT-NONE(x,k)
i=1
if x.leaf
    while i<=x.n and x.key[i]<k
        i++
    while i<=x.n-1
        x.key[i]=x.key[i+1]
        i++
    x.n--
else
    while i<=x.n and x.key[i]<k  //这里必须严格小于，找到第一个满足k<=x.key[i]的i
        i++
    y=x.c[i]
    if i>1
        p=x.c[i-1]
    if i<x.n
        z=x.c[i+1]
if y.n==t
    if p!=null and p.n>t
        B+-TREE-SHIFT-TO-RIGHT-CHILD(x,i-1)
    else if z!=null and z.n>t
        B+-TREE-SHIFT-TO-LEFT-CHILD(x,i)
    else if p!=null
        B+-TREE-MERGE(x,i-1)
        y=p
    else
        B+-TREE-MERGE(x,i)
B+-TREE-DELETE-NOT-NONE(y,k)
 

```

# 3 Java代码

## 3.1 节点

```Java
public class BPlusTreeNode {
    /**
     * 关键字个数
     */
    int n;

    /**
     * 关键字
     */
    int[] keys;

    /**
     * 孩子
     */
    BPlusTreeNode[] children;

    /**
     * 叶子节点
     */
    boolean isLeaf;

    /**
     * 兄弟节点
     */
    BPlusTreeNode next;

    public BPlusTreeNode(int t){
        n=0;
        keys=new int[2*t];
        children=new BPlusTreeNode[2*t];
        isLeaf=false;
        next=null;
    }

    public String toString(){
        StringBuilder sb=new StringBuilder();
        sb.append("{ size: "+n+", keys: [");
        for(int i=0;i<n;i++){
            sb.append(keys[i]+", ");
        }
        sb.append("] }");
        return sb.toString();

    }
}
```

## 3.2 BPlus-tree

```Java
package org.liuyehcf.algorithm.datastructure.tree.bplustree;

import java.util.*;

/**
 * Created by liuye on 2017/5/3 0003.
 * 该版本的B+树同样不支持重复关键字
 */
public class BPlusTree {
    private int t;

    private BPlusTreeNode root;
    private BPlusTreeNode data;

    public BPlusTree(int t) {
        this.t = t;
        root = new BPlusTreeNode(t);
        root.n = 0;
        root.isLeaf = true;

        data = root;
    }

    public void insert(int k) {
        if (root.n == 2 * t) {
            BPlusTreeNode newRoot = new BPlusTreeNode(t);
            newRoot.n = 1;
            newRoot.keys[0] = root.keys[2 * t - 1];
            newRoot.children[0] = root;
            newRoot.isLeaf = false;
            root = newRoot;
            split(root, 0);
        }
        insertNotFull(root, k);

        if (!check()) {
            throw new RuntimeException();
        }
    }

    private void split(BPlusTreeNode x, int i) {
        BPlusTreeNode y = x.children[i];
        BPlusTreeNode z = new BPlusTreeNode(t);

        y.n = z.n = t;
        for (int j = 0; j < t; j++) {
            z.keys[j] = y.keys[j + t];
        }
        if (!y.isLeaf) {
            for (int j = 0; j < t; j++) {
                z.children[j] = y.children[j + t];
            }
        } else {
            z.next = y.next;
            y.next = z;
        }
        z.isLeaf = y.isLeaf;

        for (int j = x.n; j > i + 1; j--) {
            x.keys[j] = x.keys[j - 1];
            x.children[j] = x.children[j - 1];
        }

        x.keys[i + 1] = x.keys[i];
        x.keys[i] = y.keys[y.n - 1];

        x.children[i + 1] = z;
        x.n++;
    }

    private void insertNotFull(BPlusTreeNode x, int k) {
        int i = x.n - 1;
        if (x.isLeaf) {
            while (i >= 0 && x.keys[i] > k) {
                x.keys[i + 1] = x.keys[i];
                i--;
            }
            if (i >= 0 && x.keys[i] == k) {
                throw new RuntimeException();
            }
            i++;
            x.keys[i] = k;
            x.n++;
        } else {
            //todo 这个等号非常关键，执行过删除操作后，遗留下来的元素可能并不存在于叶节点中
            while (i >= 0 && x.keys[i] >= k) {
                i--;
            }
            i++;
            //todo 关键，自上而下寻找插入点时，即维护了索引的正确性
            if (i == x.n) {
                //此时说明新插入的值k比当前节点中所有关键字都要大，因此当前节点的最后一个索引需要改变
                x.keys[x.n - 1] = k;
                i--;
            }

            BPlusTreeNode y = x.children[i];
            if (y.n == 2 * t) {
                split(x, i);
                if (k > y.keys[y.n - 1])
                    i++;
            }
            insertNotFull(x.children[i], k);
        }
    }

    private boolean check() {
        return checkIndex(root)
                && checkN(root)
                && checkOrder();
    }

    private boolean checkIndex(BPlusTreeNode x) {
        if (x == null) return true;
        for (int i = 1; i < x.n; i++) {
            if (x.keys[i] <= x.keys[i - 1]) {
                return false;
            }
        }
        if (!x.isLeaf) {
            for (int i = 0; i < x.n; i++) {
                BPlusTreeNode child = x.children[i];
                if (x.keys[i] < child.keys[child.n - 1]) return false;
                if (i > 0 && child.keys[0] <= x.keys[i - 1]) return false;
                if (!checkIndex(child)) return false;
            }
        }
        return true;
    }

    private boolean checkN(BPlusTreeNode x) {
        if (x.isLeaf) {
            return (x == root) || (x.n >= t && x.n <= 2 * t);
        } else {
            boolean flag = (x == root) || (x.n >= t && x.n <= 2 * t);
            for (int i = 0; i < x.n; i++) {
                flag = flag && checkN(x.children[i]);
            }
            return flag;
        }
    }

    private boolean checkOrder() {
        BPlusTreeNode x = data;
        Integer pre = null;
        int i = 0;
        while (x != null && x.n > 0) {
            if (pre == null) {
                pre = x.keys[i++];
            } else {
                if (pre >= x.keys[i]) return false;
                pre = x.keys[i++];
            }
            if (i == x.n) {
                x = x.next;
                i = 0;
            }
        }
        return true;
    }

    private BPlusTreeNode search(BPlusTreeNode x, int k) {
        while (!x.isLeaf) {
            int i = 0;
            while (i < x.n && k > x.keys[i]) {
                i++;
            }
            x = x.children[i];
        }
        for (int i = 0; i < x.n; i++) {
            if (x.keys[i] == k) return x;
        }
        return null;
    }

    public void delete(int k) {
        if (!root.isLeaf && root.n == 1) {
            root = root.children[0];
        }
        if (root.n == 2) {
            if (!root.isLeaf && root.children[0].n == t && root.children[1].n == t) {
                merge(root, 0);
            }
        }
        deleteNotNone(root, k);
        if (!check()) {
            throw new RuntimeException();
        }
    }

    private void deleteNotNone(BPlusTreeNode x, int k) {
        int i = 0;
        if (x.isLeaf) {
            while (i < x.n && x.keys[i] < k) {
                i++;
            }
            if (k != x.keys[i]) {
                throw new RuntimeException();
            }
            while (i < x.n - 1) {
                x.keys[i] = x.keys[i + 1];
                i++;
            }
            x.n--;
        } else {
            while (i < x.n && x.keys[i] < k) {
                i++;
            }
            BPlusTreeNode y = x.children[i];
            BPlusTreeNode p = null, z = null;
            if (i > 0) {
                p = x.children[i - 1];
            }
            if (i < x.n - 1) {
                z = x.children[i + 1];
            }
            if (y.n == t) {
                if (p != null && p.n > t) {
                    shiftToRight(x, i - 1);
                } else if (z != null && z.n > t) {
                    shiftToLeft(x, i);
                } else if (p != null) {
                    merge(x, i - 1);
                    y = p;
                } else {
                    merge(x, i);
                }
            }
            deleteNotNone(y, k);
        }
    }

    private void merge(BPlusTreeNode x, int i) {
        BPlusTreeNode y = x.children[i];
        BPlusTreeNode z = x.children[i + 1];

        y.n = 2 * t;
        for (int j = 0; j < t; j++) {
            y.keys[j + t] = z.keys[j];
        }
        if (!y.isLeaf) {
            for (int j = 0; j < t; j++) {
                y.children[j + t] = z.children[j];
            }
        } else {
            y.next = z.next;
        }

        for (int j = i + 1; j < x.n - 1; j++) {
            x.keys[j] = x.keys[j + 1];
            x.children[j] = x.children[j + 1];
        }
        x.keys[i] = y.keys[y.n - 1];
        x.n--;
    }

    private void shiftToLeft(BPlusTreeNode x, int i) {
        BPlusTreeNode y = x.children[i];
        BPlusTreeNode z = x.children[i + 1];

        y.keys[y.n] = z.keys[0];
        for (int j = 0; j < z.n - 1; j++) {
            z.keys[j] = z.keys[j + 1];
        }
        if (!y.isLeaf) {
            y.children[y.n] = z.children[0];
            for (int j = 0; j < z.n - 1; j++) {
                z.children[j] = z.children[j + 1];
            }
        }
        y.n++;
        z.n--;

        x.keys[i] = y.keys[y.n - 1];
    }

    private void shiftToRight(BPlusTreeNode x, int i) {
        BPlusTreeNode p = x.children[i];
        BPlusTreeNode y = x.children[i + 1];

        for (int j = y.n; j > 0; j--) {
            y.keys[j] = y.keys[j - 1];
        }
        y.keys[0] = p.keys[p.n - 1];

        if (!y.isLeaf) {
            for (int j = y.n; j > 0; j--) {
                y.children[j] = y.children[j - 1];
            }
            y.children[0] = p.children[p.n - 1];
        }
        y.n++;
        p.n--;

        x.keys[i] = p.keys[p.n - 1];
    }

    public void levelOrderTraverse() {
        Queue<BPlusTreeNode> queue = new LinkedList<BPlusTreeNode>();
        queue.offer(root);
        while (!queue.isEmpty()) {
            int len = queue.size();
            while (len-- > 0) {
                BPlusTreeNode peek = queue.poll();
                System.out.print(peek + ", ");
                if (!peek.isLeaf) {
                    for (int i = 0; i < peek.n; i++) {
                        queue.offer(peek.children[i]);
                    }
                }
            }
            System.out.println();
        }
    }

    public List<Integer> getOrderedList() {
        List<Integer> list = new ArrayList<Integer>();
        BPlusTreeNode x = data;
        while (x != null) {
            for (int i = 0; i < x.n; i++) {
                list.add(x.keys[i]);
            }
            x = x.next;
        }
        return list;
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();

        Random random = new Random();

        int TIMES = 500;

        while (--TIMES > 0) {
            System.out.println("剩余测试次数: " + TIMES);
            BPlusTree bPlusTree = new BPlusTree(random.nextInt(20) + 2);

            int N = 10000;

            Set<Integer> set = new HashSet<Integer>();
            for (int i = 0; i < N; i++) {
                set.add(random.nextInt());
            }

            List<Integer> list = new ArrayList<Integer>(set);
            Collections.shuffle(list, random);
            //插入N个数据
            for (int i : list) {
                bPlusTree.insert(i);
            }

            int M = list.size() / 2;

            //删除M个数据
            Collections.shuffle(list, random);

            for (int i = 0; i < M; i++) {
                set.remove(list.get(i));
                bPlusTree.delete(list.get(i));
            }

            //再插入M个数据
            for (int i = 0; i < M; i++) {
                int k = random.nextInt();
                if (set.add(k)) {
                    bPlusTree.insert(k);
                }
            }
            list.clear();
            list.addAll(set);
            Collections.shuffle(list, random);

            //再删除所有元素
            for (int i : list) {
                bPlusTree.delete(i);
            }
        }
        long end = System.currentTimeMillis();
        System.out.println("Run time: " + (end - start) / 1000 + "s");
    }
}
```
