---
title: RB-tree-详解
date: 2017-07-14 18:45:48
tags: 
- 原创
categories: 
- 数据结构
- 树
---

__阅读更多__

<!--more-->

# 1 定义

## 1.1 节点

__节点的属性__

1. val：关键字
1. left：左孩子节点
1. right：右孩子节点
1. parent：父节点
1. color：颜色

__节点的性质（非常重要的5条性质）__

1. 每个节点或是红色的，或是黑色的
1. 根节点是黑色的
1. 每个叶节点（nil）是黑色的
1. 如果一个节点是红色的，则它的两个子节点都是黑色的
1. 对每个节点，从该节点到其所有后代叶节点的简单路径上，均包含相同数目的黑色节点

## 1.2 树

__属性__

1. nil：哨兵节点
1. root：根节点

# 2 基本操作

## 2.1 旋转

```
        y                                            x
    x       γ       ---------右旋-------->        α       y                       
  α   β             <--------左旋---------              β   γ
```

```C
LEFT-ROTATE(T,x)
y=x.right
x.right=y.left
if y.left≠T.nil
    y.left.p=x
y.p=x.p
if x.p==T.nil
    T.root=y
elseif x==x.p.left
    x.p.left=y
else x.p.right=y
y.left=x
x.p=y
```

```C
RIGHT-ROTATE(T,y)
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
```

## 2.2 插入

```C
RB-INSERT(T,z)
y=T.nil
x=T.root
while x≠T.nil
    y=x
    if z.key<x.key
        x=x.left
    else x=x.right
z.p=y
if y==T.nil
    T.root=z
elseif z.key<y.key
    y.left=z
else y.right=z
z.left=T.nil
z.right=T.nil
z.colcor=RED
RB-INSERT-FIXUP(T,z)
```

插入的节点被设定为红色：那么可能会违背性质2或4，但只能是其中之一

* ①：当插入的节点是第一个节点时，此时根节点是红色，违背了性质2，但其子节点与父节点均为T.nil 是黑色，没有违反性质4
* ②：当插入的节点不是根节点，并且其父节点也为红色时，违背了性质4

### 2.2.1 插入纠正

纠正思路：

* 对于错误①的修正，只需要将根节点设为黑色即可
* 对于错误②的修正，由于z与其父节点均为红色，那么祖父节点必为黑色，根据z的叔节点的颜色状况以及z作为z.p的左右孩子，分三种情况讨论：

__当z的父节点是祖父节点的左孩子时：（叔节点为祖父节点的右孩子）__

* 情况1：z节点的父节点以及z节点的叔节点都是红色：将z节点的父节点以及叔节点置为黑色，z节点的祖父节点置为红色，继续循环z的祖父节点（z=z.p.p）（z可为z.p的左或右孩子）
```
        z.p.p(B)                            z.p.p(R)
    z.p(R)      y(R)     -------->      z.p(B)      y(B)
z(R)                                  z(R)
```

* 情况2：z节点的父节点为红色，叔节点为黑色，z为父节点的右孩子，对z的父节点做一次左旋，转为情况3:（旋转前后z所表示的关键字发生改变，但是z的祖父节点没有变）
```
        z.p.p(B)                            z.p.p(B)
    z.p(R)      y(B)     -------->      z(R)        y(B)
       z(R)                          z.p(R)
```

* 情况3：z节点的父节点为红色，叔节点为黑色，z为父节点的左孩子，首先将父节点设为黑色，祖父节点设为红色，然后对祖父节点做一次右旋
```
        z.p.p(B)                            z.p(B)
    z.p(R)      y(B)     -------->      z(R)        z.p.p(R)
  z(R)                                                y(B)
```
__当z的父节点是祖父节点的右孩子时：（叔节点为祖父节点的左孩子）__：也分为三种情况，与上述三种情况镜像对称，不再赘述

下面给出__插入纠正函数__伪代码

```C
RB-INSERT-FIXUP(T,z)
while z.p.color==RED//由于z.p是红色，于是z.p.p一定存在，因此访问z.p.p的任何属性都是安全的
    if z.p==z.p.p.left
        y=z.p.p.right
        if y.color==RED
            z.p.color=BLACK
            y.color=BLACK
            z.p.p.color=RED
            z=z.p.p//继续循环
        else
            if z==z.p.right
                z=z.p
                LEFT-ROTATE(T,z)
            z.p.color=BLACK
            z.p.p.color=RED
            RIGHT-ROTATE(T,z.p.p)//循环结束
    else z.p==z.p.p.right
        y=z.p.p.left
        if y.color==RED
            z.p.color=BLACK
            y.color=BLACK
            z.p.p.color=RED
            z=z.p.p//继续循环
        else
            if z==z.p.left
                z=z.p
                RIGHT-ROTATE(T,z)
            z.p.color=BLACK
            z.p.p.color=RED
            LEFT-ROTATE(T,z.p.p) //循环结束
T.root.color=BLACK//针对第一个插入的z，不会进入循环(性质4成立，但性质2破坏，这里纠正)
```

## 2.3 节点移植

__将v为根节点的子树代替u为根节点的子树__

```C
RB-TRANSPLANT(T,u,v)
if u.p==T.nil
    T.root=v
elseif u==u.p.left
    u.p.left=v
else u.p.right=v
v.p=u.p//与搜索二叉树相比，这里没有判断，即使v是哨兵，也执行此句,对于移动到y位置的节点x(可能是哨兵)，会访问x.p，因此这里需要进行赋值
```

## 2.4 删除

__z是`真正`被删除的节点__

__y是`等效`被删除的节点（或者说，y是被删除的节点或者即将移动到被删除节点的节点）__

* 当z最多只有一个孩子时，y就是被删除的节点
* 当z有两个孩子时，y就是即将移动到被删除节点的节点（替代原来的z，于是原来的y节点被删除了）

__x是`将要`移动到y节点的节点（即x代表占有y原来位置的节点）__

```C
RB-DELETE(T,z)
y=z
y-original-color=y.color
if z.left==T.nil
    x=z.right
    RB-TRANSPLANT(T,z,z.right)
elseif z.right==T.nil
    x=z.left
    RB-TRANSPLANT(T,z,z.left)
else y=TREE-MINIMUM(z.right)
    y-original-color=y.color
    x=y.right
    if y.p==z
        x.p=y//使得x为哨兵节点时也成立
    else RB-TRANSPLANT(T,y,y.right)//即使y.right是哨兵，也会指向y的父节点
        y.right=z.right
        y.right.p=y
    RB-TRANSPLANT(T,z,y)
    y.left=z.left
    y.left.p=y
    y.color=z.color
if y-original-color==BLACK
    RB-DELETE-FIXUP(T,x)
```

__此外，还有另一个版本（避免讨论，即不用讨论(y.parent==z)），两个版本等价__

```C
RB-DELETE(T,z)
y=z
y-original-color=y.color
if z.left==T.nil
    x=z.right
    RB-TRANSPLANT(T,z,z.right)
elseif z.right==T.nil
    x=z.left
    RB-TRANSPLANT(T,z,z.left)
else y=TREE-MINIMUM(z.right)
    y-original-color=y.color
    x=y.right
    RB-TRANSPLANT(T,y,y.right)//即使y.right是哨兵，也会指向y的父节点
    y.right=z.right
    y.right.p=y
    RB-TRANSPLANT(T,z,y)
    y.left=z.left
    y.left.p=y
    y.color=z.color
if y-original-color==BLACK
    RB-DELETE-FIXUP(T,x)
```

总结：

1. __删除最终等效为删除一个最多只有一个孩子的节点__
    * 当被删除节点z最多只有只有一个孩子，满足该条规律
    * 当被删除节点z有两个孩子，那么找到该节点z的后继节点y，__此时y节点必然最多只有一个右孩子__，于是将其右孩子y.right transplant到到y节点处以删除y节点，然后再将y节点移动到z节点处，并保持z节点原来的颜色，那么等价于删除y节点
1. 当被删除节点的颜色为红色，那么不会破坏红黑树的性质
1. 当被删除的节点是黑色，那么transplant到该节点的节点x如果是黑色，那么为了保持黑高不变的性质，x必须含有双重黑色，此时又破坏了性质1，需要进行维护矫正

__红黑树性质破坏分析__

* __当y-original-color为红色时：不会违反红黑树的任何性质__
    * ①：当y为被删除节点时，若y为红色，那么它的父节点为黑色，孩子节点也必为黑色，将孩子移植到该位置不会违反任何性质
    * ②：当y节点为z节点的后继时，若y为红色，那么y节点的父节点以及y节点的右子节点(可能为哨兵)必为黑色，将y.right移植到y的位置，不会违反任何性质；如果z节点是黑色的，那么删除z节点后z的任意祖先的黑高将少一，但是由于将y的颜色设为黑色，做了补偿。如果z节点是红色的，将y节点也设为红色，那么删除z节点不会违反性质5
    * 因此y-original-color为红色时，不会违反红黑树的任何性质
* __当y-original-color为黑色时：可能会违反性质2或4或5__
    * ①：如果y是根节点，而y的一个红色孩子成为新的根节点，违反了性质2
    * ②：如果x和x.p是红色，违反了性质4
    * ③：在树中删除或移动y将导致先前包含y的简单路径上的黑色节点少1
    * 若z节点的孩子均不为T.nil，会违反性质的部分是以y的原位置为根节点的子树(包括其父节点)

## 2.5 删除纠正

__当x是其父亲的左孩子时：x为双重黑色__

* 情况1：x的兄弟节点w是红色的(w必有两个黑色的非哨兵子节点，且父亲必为黑色)。将x.p置为红色，w置为黑色，对x.p做一次左旋并更新w，即可将情况1转为234的一种
```
            x.p(B)                                      w(B)
    x(B)            w(R)         -------->      x.p(R)          w.r(B)
                w.l(B)   w.r(B)             x(B)   w.l(B)
```

* 情况2：x的兄弟节点w是黑色，并且w的两个子节点都是黑色(可以是哨兵)。由于x为双重黑色，为了取消x的双重性，将x与w都去掉一层黑色属性，因此x变为单黑，w变为红色，并更新x(将双重属性赋予x的父节点)，并继续循环
```
            x.p(?)                                      x.p(?)
    x(B)            w(B)         -------->      x(B)            w(R)
                w.l(B)   w.r(B)                             w.l(B)   w.r(B)
```

* 情况3：x的兄弟节点w是黑色，w的左孩子是红色，右孩子是黑色。交换w与其左孩子的颜色，对w进行右旋，并更新w，即可转为情况4
```
            x.p(?)                                      x.p(?)
    x(B)            w(B)         -------->     x(B)            w.l(B)
                w.l(R)   w.r(B)                                     w(R)
                                                                      w.r(B)
```

* 情况4：x的兄弟节点是黑色，且w的右孩子是红色。交换x与x.p的颜色，将w的右孩子置为黑色，并对x.p做一次左旋，即可退出循环
```
            x.p(?)                                      w(?)
    x(B)            w(B)         -------->      x.p(B)          w.r(B)
                w.l(?)   w.r(R)             x(B)    w.l(?)
```

__当x是其父亲的右孩子时：x为双重黑色__，也可分为四种情况，与上面4种情况镜像对称，不再赘述

```C
RB-DELETE-FIXUP(T,x)
while x≠T.root and x.color ==BLACK//若x是红色的，那么将x改为黑色即可
    if x==x.p.left//x可以是哨兵，访问x.p是合法的，因为在Delete中已经设置过
        w=x.p.right
        if w.color==RED
            w.color=BLACK
            x.p.color=RED
            LEFT-ROTATE(T,x.p)
            w=x.p.right
        if w.left.color==BLACK and w.right.color==BLACK
            w.color=RED
            x=x.p
        else
            if w.right.color==BLACK
                w.left.color=BLACK
                w.color=RED
                RIGHT-ROTATE(T,w)
                w=x.p.right
            w.color=x.p.color
            x.p.color=BLACK
            w.right.color=BLACK
            LEFT-ROTATE(T,x.p)
            x=T.root
    elseif x==x.p.right
        w=x.p.left
        if w.color==RED
            w.color=BLACK
            x.p.color=RED
            RIGHT-ROTATE(T,x.p)
            w=x.p.left
        if w.left.color==BLACK and w.right.color==BLACK
            w.color=RED
            x=x.p
        else
            if w.left.color==BLACK
                w.right.color=BLACK
                w.color=RED
                LEFT-ROTATE(T,w)
                w=x.p.left
            w.color=x.p.color
            x.p.color=BLACK
            w.left.color=BLACK
            RIGHT-ROTATE(T,x.p)
            x=T.root
x.color=BLACK
```

# 3 Java源码

## 3.1 颜色枚举类型

```Java
package org.liuyehcf.algorithm.datastructure.tree.rbtree;

/**
 * Created by HCF on 2017/4/6.
 */
public enum Color {
    BLACK,
    RED
}
```

## 3.2 节点定义

```Java
package org.liuyehcf.algorithm.datastructure.tree.rbtree;

/**
 * Created by HCF on 2017/4/29.
 */
public class RBTreeNode {
    int val;
    RBTreeNode left;
    RBTreeNode right;
    RBTreeNode parent;
    Color color;

    RBTreeNode(int val) {
        this.val = val;
    }
}
```

## 3.3 RB-tree实现

```Java
package org.liuyehcf.algorithm.datastructure.tree.rbtree;

import java.util.*;

import static org.liuyehcf.algorithm.datastructure.tree.rbtree.Color.BLACK;
import static org.liuyehcf.algorithm.datastructure.tree.rbtree.Color.RED;

/**
 * Created by HCF on 2017/4/6.
 */

public class RBTree {
    private RBTreeNode nil;

    private RBTreeNode root;
    private boolean rule5;

    public RBTree() {
        nil = new RBTreeNode(0);
        nil.color = BLACK;
        nil.left = nil;
        nil.right = nil;
        nil.parent = nil;

        root = nil;
    }

    public void insert(int val) {
        RBTreeNode x = root;
        RBTreeNode y = nil;
        RBTreeNode z = new RBTreeNode(val);
        while (x != nil) {
            y = x;
            if (z.val < x.val) {
                x = x.left;
            } else {
                x = x.right;
            }
        }
        z.parent = y;
        z.left = nil;
        z.right = nil;
        z.color = RED;
        if (y == nil) {
            root = z;
        } else if (z.val < y.val) {
            y.left = z;
        } else {
            y.right = z;
        }
        insertFix(z);
        if (!check()) throw new RuntimeException();
    }

    private void insertFix(RBTreeNode x) {
        while (x.parent.color == RED) {
            if (x.parent == x.parent.parent.left) {
                RBTreeNode y = x.parent.parent.right;
                if (y.color == RED) {
                    x.parent.color = BLACK;
                    y.color = BLACK;
                    x.parent.parent.color = RED;
                    x = x.parent.parent;
                } else {
                    if (x == x.parent.right) {
                        x = x.parent;
                        leftRotate(x);
                    }
                    x.parent.color = BLACK;
                    x.parent.parent.color = RED;
                    rightRotate(x.parent.parent);
                }
            } else {
                RBTreeNode y = x.parent.parent.left;
                if (y.color == RED) {
                    x.parent.color = BLACK;
                    y.color = BLACK;
                    x.parent.parent.color = RED;
                    x = x.parent.parent;
                } else {
                    if (x == x.parent.left) {
                        x = x.parent;
                        rightRotate(x);
                    }
                    x.parent.color = BLACK;
                    x.parent.parent.color = RED;
                    leftRotate(x.parent.parent);
                }
            }
        }
        root.color = BLACK;
    }

    private void leftRotate(RBTreeNode x) {
        RBTreeNode y = x.right;
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
    }

    private void rightRotate(RBTreeNode y) {
        RBTreeNode x = y.left;
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
    }

    public void insert(int[] vals) {
        for (int val : vals) {
            insert(val);
        }
    }

    public int max() {
        RBTreeNode x = max(root);
        if (x == nil) throw new RuntimeException();
        return x.val;
    }

    private RBTreeNode max(RBTreeNode x) {
        while (x.right != nil) {
            x = x.right;
        }
        return x;
    }

    public int min() {
        RBTreeNode x = min(root);
        if (x == nil) throw new RuntimeException();
        return x.val;
    }

    private RBTreeNode min(RBTreeNode x) {
        while (x.left != nil) {
            x = x.left;
        }
        return x;
    }

    public boolean search(int val) {
        RBTreeNode x = search(root, val);
        return x != nil;
    }

    private RBTreeNode search(RBTreeNode x, int val) {
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
        RBTreeNode z = search(root, val);
        if (z == nil) throw new RuntimeException();

        RBTreeNode y = z;//y代表"被删除"的节点
        RBTreeNode x = nil;//x代表移动到"被删除"节点的节点
        Color yOriginColor = y.color;
        if (z.left == nil) {
            x = z.right;
            transplant(z, z.right);
        } else if (z.right == nil) {
            x = z.left;
            transplant(z, z.left);
        } else {
            y = min(z.right);
            yOriginColor = y.color;
            x = y.right;
            transplant(y, x);

            //TODO 以下6句改为z.val=y.val也是可以的
            y.right = z.right;
            y.right.parent = y;

            y.left = z.left;
            y.left.parent = y;

            transplant(z, y);
            y.color = z.color;
        }

        if (yOriginColor == BLACK) {
            deleteFix(x);
        }

        if (!check()) throw new RuntimeException();
    }

    private void transplant(RBTreeNode u, RBTreeNode v) {
        v.parent = u.parent;
        if (u.parent == nil) {
            root = v;
        } else if (u == u.parent.left) {
            u.parent.left = v;
        } else {
            u.parent.right = v;
        }
    }

    private void deleteFix(RBTreeNode x) {
        while (x != root && x.color == BLACK) {
            if (x == x.parent.left) {
                RBTreeNode w = x.parent.right;
                if (w.color == RED) {
                    w.color = BLACK;
                    x.parent.color = RED;
                    leftRotate(x.parent);
                    w = x.parent.right;
                }
                if (w.left.color == BLACK && w.right.color == BLACK) {
                    w.color = RED;
                    x = x.parent;
                    //这里是可能直接退出循环的,此时x若为红色，那么x就是红色带额外的黑色，因此将其改为黑色就行
                } else {
                    if (w.left.color == RED) {
                        w.left.color = BLACK;
                        w.color = RED;
                        rightRotate(w);
                        w = x.parent.right;
                    }
                    w.color = x.parent.color;
                    x.parent.color = BLACK;
                    w.right.color = BLACK;
                    leftRotate(x.parent);
                    x = root;
                }

            } else {
                RBTreeNode w = x.parent.left;
                if (w.color == RED) {
                    w.color = BLACK;
                    x.parent.color = RED;
                    rightRotate(x.parent);
                    w = x.parent.left;
                }
                if (w.left.color == BLACK && w.right.color == BLACK) {
                    w.color = RED;
                    x = x.parent;
                    //这里是可能直接退出循环的,此时x若为红色，那么x就是红色带额外的黑色，因此将其改为黑色就行
                } else {
                    if (w.right.color == RED) {
                        w.right.color = BLACK;
                        w.color = RED;
                        leftRotate(w);
                        w = x.parent.left;
                    }
                    w.color = x.parent.color;
                    x.parent.color = BLACK;
                    w.left.color = BLACK;
                    rightRotate(x.parent);
                    x = root;
                }
            }
        }
        x.color = BLACK;
    }

    private boolean check() {
        if (root.color == RED) return false;
        if (nil.color == RED) return false;
        if (!checkRule4(root)) return false;
        rule5 = true;
        checkRule5(root);
        if (!rule5) return false;
        return true;
    }

    private boolean checkRule4(RBTreeNode root) {
        if (root == nil) return true;
        if (root.color == RED &&
                (root.left.color == RED || root.right.color == RED))
            return false;
        return checkRule4(root.left) && checkRule4(root.right);
    }

    private int checkRule5(RBTreeNode root) {
        if (root == nil) return 1;
        int leftBlackHigh = checkRule5(root.left);
        int rightBlackHigh = checkRule5(root.right);
        if (leftBlackHigh != rightBlackHigh) {
            rule5 = false;
            return -1;
        }
        return leftBlackHigh + (root.color == BLACK ? 1 : 0);
    }

    public void preOrderTraverse() {
        StringBuilder sbRecursive = new StringBuilder();
        StringBuilder sbStack = new StringBuilder();
        StringBuilder sbElse = new StringBuilder();

        preOrderTraverseRecursive(root, sbRecursive);
        preOrderTraverseStack(sbStack);
        preOrderTraverseElse(sbElse);

        System.out.println(sbRecursive.toString());
        System.out.println(sbStack.toString());
        System.out.println(sbElse.toString());

        if (!sbRecursive.toString().equals(sbStack.toString()) ||
                !sbRecursive.toString().equals(sbElse.toString()))
            throw new RuntimeException();
    }

    private void preOrderTraverseRecursive(RBTreeNode root, StringBuilder sb) {
        if (root != nil) {
            sb.append(root.val + ", ");
            preOrderTraverseRecursive(root.left, sb);
            preOrderTraverseRecursive(root.right, sb);
        }
    }

    private void preOrderTraverseStack(StringBuilder sb) {
        LinkedList<RBTreeNode> stack = new LinkedList<RBTreeNode>();
        RBTreeNode cur = root;
        while (cur != nil || !stack.isEmpty()) {
            while (cur != nil) {
                sb.append(cur.val + ", ");
                stack.push(cur);
                cur = cur.left;
            }
            if (!stack.isEmpty()) {
                RBTreeNode peek = stack.pop();
                cur = peek.right;
            }
        }
    }

    private void preOrderTraverseElse(StringBuilder sb) {
        RBTreeNode cur = root;
        RBTreeNode pre = nil;
        while (cur != nil) {
            if (pre == cur.parent) {
                sb.append(cur.val + ", ");
                pre = cur;
                if (cur.left != nil) {
                    cur = cur.left;
                } else if (cur.right != nil) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                pre = cur;
                if (cur.right != nil) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else {
                pre = cur;
                cur = cur.parent;
            }
        }
    }

    public void inOrderTraverse() {
        StringBuilder sbRecursive = new StringBuilder();
        StringBuilder sbStack = new StringBuilder();
        StringBuilder sbElse = new StringBuilder();

        inOrderTraverseRecursive(root, sbRecursive);
        inOrderTraverseStack(sbStack);
        inOrderTraverseElse(sbElse);

        System.out.println(sbRecursive.toString());
        System.out.println(sbStack.toString());
        System.out.println(sbElse.toString());

        if (!sbRecursive.toString().equals(sbStack.toString()) ||
                !sbRecursive.toString().equals(sbElse.toString()))
            throw new RuntimeException();
    }

    private void inOrderTraverseRecursive(RBTreeNode root, StringBuilder sb) {
        if (root != nil) {
            inOrderTraverseRecursive(root.left, sb);
            sb.append(root.val + ", ");
            inOrderTraverseRecursive(root.right, sb);
        }
    }

    private void inOrderTraverseStack(StringBuilder sb) {
        LinkedList<RBTreeNode> stack = new LinkedList<RBTreeNode>();
        RBTreeNode cur = root;
        while (cur != nil || !stack.isEmpty()) {
            while (cur != nil) {
                stack.push(cur);
                cur = cur.left;
            }
            if (!stack.isEmpty()) {
                RBTreeNode peek = stack.pop();
                sb.append(peek.val + ", ");
                cur = peek.right;
            }
        }
    }

    private void inOrderTraverseElse(StringBuilder sb) {
        RBTreeNode cur = root;
        RBTreeNode pre = nil;
        while (cur != nil) {
            if (pre == cur.parent) {
                pre = cur;
                if (cur.left != nil) {
                    cur = cur.left;
                } else if (cur.right != nil) {
                    sb.append(cur.val + ", ");
                    cur = cur.right;
                } else {
                    sb.append(cur.val + ", ");
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                pre = cur;
                sb.append(cur.val + ", ");
                if (cur.right != nil) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else {
                pre = cur;
                cur = cur.parent;
            }
        }
    }

    public void postOrderTraverse() {
        StringBuilder sbRecursive = new StringBuilder();
        StringBuilder sbStack1 = new StringBuilder();
        StringBuilder sbStack2 = new StringBuilder();
        StringBuilder sbStack3 = new StringBuilder();
        StringBuilder sbElse = new StringBuilder();

        postOrderTraverseRecursive(root, sbRecursive);
        postOrderTraverseStack1(sbStack1);
        postOrderTraverseStack2(sbStack2);
        postOrderTraverseStack3(sbStack3);
        postOrderTraverseElse(sbElse);

        System.out.println(sbRecursive.toString());
        System.out.println(sbStack1.toString());
        System.out.println(sbStack2.toString());
        System.out.println(sbStack3.toString());
        System.out.println(sbElse.toString());

        if (!sbRecursive.toString().equals(sbStack1.toString()) ||
                !sbRecursive.toString().equals(sbStack2.toString()) ||
                !sbRecursive.toString().equals(sbStack3.toString()) ||
                !sbRecursive.toString().equals(sbElse.toString()))
            throw new RuntimeException();
    }

    private void postOrderTraverseRecursive(RBTreeNode root, StringBuilder sb) {
        if (root != nil) {
            postOrderTraverseRecursive(root.left, sb);
            postOrderTraverseRecursive(root.right, sb);
            sb.append(root.val + ", ");
        }
    }

    private void postOrderTraverseStack1(StringBuilder sb) {
        LinkedList<RBTreeNode> stack = new LinkedList<RBTreeNode>();
        RBTreeNode cur = root;
        while (cur != nil || !stack.isEmpty()) {
            while (cur != nil) {
                sb.insert(0, cur.val + ", ");
                stack.push(cur);
                cur = cur.right;
            }
            if (!stack.isEmpty()) {
                RBTreeNode peek = stack.pop();
                cur = peek.left;
            }
        }
    }

    private void postOrderTraverseStack2(StringBuilder sb) {
        LinkedList<RBTreeNode> stack = new LinkedList<RBTreeNode>();
        RBTreeNode cur = root;
        Map<RBTreeNode, Integer> map = new HashMap<RBTreeNode, Integer>();
        while (cur != nil || !stack.isEmpty()) {
            while (cur != nil) {
                stack.push(cur);
                map.put(cur, 1);
                cur = cur.left;
            }
            if (!stack.isEmpty()) {
                RBTreeNode peek = stack.pop();
                if (map.get(peek) == 2) {
                    sb.append(peek.val + ", ");
                    cur = nil;
                } else {
                    stack.push(peek);
                    map.put(peek, 2);
                    cur = peek.right;
                }
            }
        }
    }

    private void postOrderTraverseStack3(StringBuilder sb) {
        RBTreeNode pre = nil;
        LinkedList<RBTreeNode> stack = new LinkedList<RBTreeNode>();
        stack.push(root);
        while (!stack.isEmpty()) {
            RBTreeNode peek = stack.peek();
            if (peek.left == nil && peek.right == nil || pre.parent == peek) {
                pre = peek;
                sb.append(peek.val + ", ");
                stack.pop();
            } else {
                if (peek.right != nil) {
                    stack.push(peek.right);
                }
                if (peek.left != nil) {
                    stack.push(peek.left);
                }
            }
        }
    }

    private void postOrderTraverseElse(StringBuilder sb) {
        RBTreeNode cur = root;
        RBTreeNode pre = nil;
        while (cur != nil) {
            if (pre == cur.parent) {
                pre = cur;
                if (cur.left != nil) {
                    cur = cur.left;
                } else if (cur.right != nil) {
                    cur = cur.right;
                } else {
                    sb.append(cur.val + ", ");
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                pre = cur;
                if (cur.right != nil) {
                    cur = cur.right;
                } else {
                    sb.append(cur.val + ", ");
                    cur = cur.parent;
                }
            } else {
                sb.append(cur.val + ", ");
                pre = cur;
                cur = cur.parent;
            }
        }
    }

    public static void main(String[] args) {
        long start = System.currentTimeMillis();

        Random random = new Random();

        int TIMES = 10;

        while (--TIMES > 0) {
            System.out.println("剩余测试次数: " + TIMES);
            RBTree rbTree = new RBTree();

            int N = 10000;
            int M = N / 2;

            Set<Integer> set = new HashSet<Integer>();
            for (int i = 0; i < N; i++) {
                set.add(random.nextInt());
            }

            List<Integer> list = new ArrayList<Integer>(set);
            Collections.shuffle(list, random);
            //插入N个数据
            for (int i : list) {
                rbTree.insert(i);
            }

//rbTree.preOrderTraverse();
//rbTree.inOrderTraverse();
//rbTree.postOrderTraverse();

            //删除M个数据
            Collections.shuffle(list, random);

            for (int i = 0; i < M; i++) {
                set.remove(list.get(i));
                rbTree.delete(list.get(i));
            }

            //再插入M个数据
            for (int i = 0; i < M; i++) {
                int k = random.nextInt();
                set.add(k);
                rbTree.insert(k);
            }
            list.clear();
            list.addAll(set);
            Collections.shuffle(list, random);

            //再删除所有元素
            for (int i : list) {
                rbTree.delete(i);
            }
        }
        long end = System.currentTimeMillis();
        System.out.println("Run time: " + (end - start) / 1000 + "s");
    }
}
```
