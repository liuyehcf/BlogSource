---
title: Algorithm-Tree
date: 2017-07-16 21:14:53
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

# 1 How to traverse tree

## 1.1 节点定义

```java
public class TreeNode {
    int val;
    TreeNode left;
    TreeNode right;
    TreeNode parent;

    TreeNode(int x) {
        val = x;
    }
}
```

## 1.2 先序遍历

LeetCode：144

### 1.2.1 递归

先访问当前节点，然后递归左子树，再递归右子树

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> preorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        helper(root);

        return visitedList;
    }

    private void helper(TreeNode root) {
        if (root != null) {
            visit(root);
            helper(root.left);
            helper(root.right);
        }
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.2.2 栈

对于某个节点

1. 沿着左孩子往下走依次访问经过的节点，该过程的所有节点会进栈
1. 当前节点为null，意味着遍历完毕或者说该访问该节点的右子树了

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> preorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        LinkedList<TreeNode> stack = new LinkedList<TreeNode>();

        TreeNode cur = root;

        while (cur != null || !stack.isEmpty()) {
            while (cur != null) {
                visit(cur);
                stack.push(cur);
                cur = cur.left;
            }

            if (!stack.isEmpty()) {
                TreeNode top = stack.pop();
                
                cur = top.right;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

或者

```java
public class Solution {
    public List<Integer> preorderTraversal(TreeNode root) {
        visitedList = new ArrayList<>();

        LinkedList<TreeNode> stack = new LinkedList<>();

        if (root != null) {
            stack.push(root);
        }

        while (!stack.isEmpty()) {
            TreeNode top = stack.pop();

            visit(top);

            if (top.right != null) {
                stack.push(top.right);
            }

            if (top.left != null) {
                stack.push(top.left);
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.2.3 非栈非递归

这个方法本质上与栈差不多，只是利用的空间更少了，但是要求TreeNode的定义必须有parent字段，而栈的方法不需要parent字段

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> preorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        TreeNode cur = root;

        TreeNode pre = null;

        while (cur != null) {
            pre = cur;
            if (pre == cur.parent) {
                visit(cur);
                if (cur.left != null) {
                    cur = cur.left;
                } else if (cur.right != null) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                if (cur.right != null) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else {
                cur = cur.parent;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

## 1.3 中序遍历

LeetCode：94

### 1.3.1 递归

先递归左子树，访问当前节点，再递归右子树

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> inorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        helper(root);

        return visitedList;
    }

    private void helper(TreeNode root) {
        if (root != null) {
            helper(root.left);
            visit(root);
            helper(root.right);
        }
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.3.2 栈

对于某个节点

1. 首先沿着左孩子节点一直到叶节点，该过程的所有节点会进栈
1. 当前节点为null，意味着遍历完毕或者说该访问栈中的元素了

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> inorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        LinkedList<TreeNode> stack = new LinkedList<TreeNode>();

        TreeNode cur = root;

        while (cur != null || !stack.isEmpty()) {
            while (cur != null) {
                stack.push(cur);
                cur = cur.left;
            }

            if (!stack.isEmpty()) {
                TreeNode top = stack.pop();

                visit(top);

                cur = top.right;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

或者

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> inorderTraversal(TreeNode root) {
        visitedList = new ArrayList<>();

        LinkedList<TreeNode> stack = new LinkedList<>();

        TreeNode iter = root;
        while (iter != null) {
            stack.push(iter);
            iter = iter.left;
        }

        while (!stack.isEmpty()) {
            TreeNode top = stack.pop();

            visit(top);

            if (top.right != null) {
                iter = top.right;
                while (iter != null) {
                    stack.push(iter);
                    iter = iter.left;
                }
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.3.3 非栈非递归

这个方法本质上与栈差不多，只是利用的空间更少了，但是要求TreeNode的定义必须有parent字段，而栈的方法不需要parent字段

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> inorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        TreeNode cur = root;

        TreeNode pre = null;

        while (cur != null) {
            pre = cur;
            if (pre == cur.parent) {
                if (cur.left != null) {
                    cur = cur.left;
                } else if (cur.right != null) {
                    visit(cur);
                    cur = cur.right;
                } else {
                    visit(cur);
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                visit(cur);
                if (cur.right != null) {
                    cur = cur.right;
                } else {
                    cur = cur.parent;
                }
            } else {
                cur = cur.parent;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

## 1.4 后续遍历

LeetCode：145

### 1.4.1 递归

先递归左子树，然后递归右子树，再访问当前节点

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        helper(root);

        return visitedList;
    }

    private void helper(TreeNode root) {
        if (root != null) {
            helper(root.left);
            helper(root.right);
            visit(root);
        }
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.4.2 栈1

由于后续遍历是：左子树-右子树-当前节点。反过来看就是，当前节点-右子树-左子树，这是相反方向的先序遍历

对于某个节点

1. 沿着右孩子往下走依次访问(将元素添加到访问List的头部即可，即做一个逆序操作)经过的节点，该过程的所有节点会进栈
1. 当前节点为null，意味着遍历完毕或者说该访问该节点的左子树了

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new LinkedList<Integer>();//这里用ListedList作为实现，因为要在头部插入元素

        LinkedList<TreeNode> stack = new LinkedList<TreeNode>();

        TreeNode cur = root;

        while (cur != null || !stack.isEmpty()) {
            while (cur != null) {
                visit(cur);
                stack.push(cur);
                cur = cur.right;
            }

            if (!stack.isEmpty()) {
                TreeNode top = stack.pop();
                cur = top.left;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(0,root.val);
    }
}
```

或者

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new LinkedList<Integer>();

        LinkedList<TreeNode> stack = new LinkedList<>();

        if (root != null) {
            stack.push(root);
        }

        while (!stack.isEmpty()) {
            TreeNode top = stack.pop();

            visit(top);

            if (top.left != null) {
                stack.push(top.left);
            }

            if (top.right != null) {
                stack.push(top.right);
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(0, root.val);
    }
}
```

### 1.4.3 栈2

另一种栈的思路

1. 首先将根节点入栈
1. 访问栈顶节点，如果栈顶节点没有孩子，或者栈顶节点是pre的父节点(说明回溯上去了)，此时访问该节点，并更新pre
1. 否则若右孩子不为空，则右孩子入栈，左孩子不为空，则左孩子入栈(因为先访问的节点要后入栈，因此是先右后左的顺序)

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new ArrayList<>();

        LinkedList<TreeNode> stack = new LinkedList<>();

        if (root != null) {
            stack.push(root);
        }

        TreeNode pre = null;

        while (!stack.isEmpty()) {
            TreeNode peek = stack.peek();

            if (peek.left == null && peek.right == null
                    || (pre != null && (peek.left == pre || peek.right == pre))) {
                stack.pop();
                visit(peek);
                pre = peek;
            } else {
                if (peek.right != null) {
                    stack.push(peek.right);
                }
                if (peek.left != null) {
                    stack.push(peek.left);
                }
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.4.4 栈3

对于某个节点

1. 首先沿着左孩子节点一直到叶节点，该过程的所有节点会进栈，并且记录入栈次数为1
1. 当前节点为null，意味着遍历完毕或者说该访问栈中的元素了，取出栈顶元素，如果该元素入栈2次，那么访问该元素，否则重新入栈，并递增入栈计数值

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        LinkedList<TreeNode> stack = new LinkedList<TreeNode>();

        Map<TreeNode, Integer> count = new HashMap<TreeNode, Integer>();

        TreeNode cur = root;

        while (cur != null || !stack.isEmpty()) {
            while (cur != null) {
                stack.push(cur);
                count.put(cur, 1);
                cur = cur.left;
            }

            if (!stack.isEmpty()) {
                TreeNode top = stack.pop();

                if (count.get(top) == 2) {
                    visit(top);
                } else {
                    count.put(top, 2);
                    stack.push(top);
                    cur = top.right;
                }
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

或者

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new ArrayList<>();

        LinkedList<TreeNode> stack = new LinkedList<>();
        Map<TreeNode, Integer> count = new HashMap<>();

        if (root != null) {
            stack.push(root);
            count.put(root, 1);
        }

        while (!stack.isEmpty()) {
            TreeNode top = stack.pop();

            if (count.get(top) == 1) {
                stack.push(top);
                count.put(top, 2);
                if (top.right != null) {
                    stack.push(top.right);
                    count.put(top.right, 1);
                }

                if (top.left != null) {
                    stack.push(top.left);
                    count.put(top.left, 1);
                }
            } else {
                visit(top);
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

### 1.4.5 非栈非递归

这个方法本质上与栈差不多，只是利用的空间更少了，但是要求TreeNode的定义必须有parent字段，而栈的方法不需要parent字段

```java
public class Solution {
    private List<Integer> visitedList;

    public List<Integer> postorderTraversal(TreeNode root) {
        visitedList = new ArrayList<Integer>();

        TreeNode cur = root;

        TreeNode pre = null;

        while (cur != null) {
            pre = cur;
            if (pre == cur.parent) {
                if (cur.left != null) {
                    cur = cur.left;
                } else if (cur.right != null) {
                    cur = cur.right;
                } else {
                    visit(cur);
                    cur = cur.parent;
                }
            } else if (pre == cur.left) {
                if (cur.right != null) {
                    cur = cur.right;
                } else {
                    visit(cur);
                    cur = cur.parent;
                }
            } else {
                visit(cur);
                cur = cur.parent;
            }
        }

        return visitedList;
    }

    private void visit(TreeNode root) {
        visitedList.add(root.val);
    }
}
```

## 1.5 层序遍历

### 1.5.1 队列

遍历每层前先记录队列的大小，该大小就是该层元素的个数，并且依次将左右孩子入队列

```java
public class Solution {
    public List<List<Integer>> levelOrder(TreeNode root) {
        List<List<Integer>> visitedLevel = new ArrayList<List<Integer>>();

        Queue<TreeNode> queue = new LinkedList<TreeNode>();

        if (root != null)
            queue.offer(root);

        while (!queue.isEmpty()) {
            List<Integer> curLevel = new ArrayList<Integer>();
            int count = queue.size();

            while (--count >= 0) {
                TreeNode cur = queue.poll();
                if (cur.left != null)
                    queue.offer(cur.left);
                if (cur.right != null)
                    queue.offer(cur.right);
                curLevel.add(cur.val);
            }

            visitedLevel.add(curLevel);
        }

        return visitedLevel;
    }
}
```

# 2 Question-105[★★★★★]

**Construct Binary Tree from Preorder and Inorder Traversal**

> Given preorder and inorder traversal of a tree, construct the binary tree.

```java
public class Solution {
    public TreeNode buildTree(int[] preorder, int[] inorder) {
        Map<Integer, Integer> posMap = new HashMap<>();

        for (int i = 0; i < inorder.length; i++) {
            posMap.put(inorder[i], i);
        }

        return build(preorder, 0, preorder.length - 1,
                inorder, 0, inorder.length - 1,
                posMap);
    }

    private TreeNode build(int[] preorder, int begin1, int end1,
                           int[] inorder, int begin2, int end2,
                           Map<Integer, Integer> posMap) {
        if (begin1 > end1) return null;

        int val = preorder[begin1];

        int posOfVal = posMap.get(val);

        TreeNode root = new TreeNode(val);

        int leftTreeSize = (posOfVal - 1) - begin2 + 1;
        int rightTreeSize = end2 - (posOfVal + 1) + 1;

        root.left = build(preorder, begin1 + 1, begin1 + 1 + leftTreeSize - 1,
                inorder, begin2, posOfVal - 1,
                posMap);

        root.right = build(preorder, begin1 + 1 + leftTreeSize - 1 + 1, end1,
                inorder, posOfVal + 1, end2,
                posMap);

        return root;

    }
}
```

# 3 Question-106[★★★★★]

**Construct Binary Tree from Inorder and Postorder Traversal**

> Given inorder and postorder traversal of a tree, construct the binary tree.

```java
public class Solution {
    public TreeNode buildTree(int[] inorder, int[] postorder) {
        Map<Integer, Integer> posMap = new HashMap<>();

        for (int i = 0; i < inorder.length; i++) {
            posMap.put(inorder[i], i);
        }

        return build(postorder, 0, postorder.length - 1,
                inorder, 0, inorder.length - 1,
                posMap);
    }

    private TreeNode build(int[] postorder, int begin1, int end1,
                           int[] inorder, int begin2, int end2,
                           Map<Integer, Integer> posMap) {
        if (begin1 > end1) return null;

        int val = postorder[end1];

        int posOfVal = posMap.get(val);

        TreeNode root = new TreeNode(val);

        int leftTreeSize = (posOfVal - 1) - begin2 + 1;
        int rightTreeSize = end2 - (posOfVal + 1) + 1;

        root.left = build(postorder, begin1, begin1 + leftTreeSize - 1,
                inorder, begin2, posOfVal - 1,
                posMap);

        root.right = build(postorder, begin1 + leftTreeSize - 1 + 1, end1 - 1,
                inorder, posOfVal + 1, end2,
                posMap);

        return root;
    }
}
```

# 4 Question-124[★★★★★]

**Binary Tree Maximum Path Sum**

> Given a binary tree, find the maximum path sum.

> For this problem, a path is defined as any sequence of nodes from some starting node to any node in the tree along the parent-child connections. The path must contain at least one node and does not need to go through the root.

```java
/**
 * Definition for a binary tree node.
 * public class TreeNode {
 * int val;
 * TreeNode left;
 * TreeNode right;
 * TreeNode(int x) { val = x; }
 * }
 */
public class Solution {

    int max;

    public int maxPathSum(TreeNode root) {
        Map<TreeNode, Integer> cache = new HashMap<TreeNode, Integer>();

        max = Integer.MIN_VALUE;

        maxLength(root, cache);

        return max;
    }

    private int maxLength(TreeNode root, Map<TreeNode, Integer> cache) {
        if (root == null) return 0;

        if (cache.containsKey(root)) return cache.get(root);

        int leftMax = maxLength(root.left, cache);
        int rightMax = maxLength(root.right, cache);

        int curMax = Math.max(0, Math.max(leftMax, rightMax)) + root.val;

        max = Math.max(max, (leftMax < 0 ? 0 : leftMax) + (rightMax < 0 ? 0 : rightMax) + root.val);

        cache.put(root, curMax);

        return curMax;
    }
}
```

maxLength方法计算以给定节点为根节点的子树中，从根到叶节点的路径和最大值。注意与0比较

# 5 Question-222[★★★★★]

**Count Complete Tree Nodes**

> Given a complete binary tree, count the number of nodes.

```java
public class Solution {
    public int countNodes(TreeNode root) {
        int leftDepth = getLeftDepth(root);
        int rightDepth = getRightDepth(root);

        if (leftDepth == rightDepth) return (1 << leftDepth) - 1;

        return countNodes(root.left) + countNodes(root.right) + 1;
    }

    private int getLeftDepth(TreeNode root) {
        int depth = 0;

        while (root != null) {
            depth++;
            root = root.left;
        }

        return depth;
    }

    private int getRightDepth(TreeNode root) {
        int depth = 0;

        while (root != null) {
            depth++;
            root = root.right;
        }

        return depth;
    }

}
```

# 6 Question-230[★★]

**Kth Smallest Element in a BST**

> Given a binary search tree, write a function kthSmallest to find the kth smallest element in it.

```java
public class Solution {
    private int cnt = 0;
    private int res;

    public int kthSmallest(TreeNode root, int k) {
        cnt = 0;
        helper(root, k);
        return res;
    }

    private void helper(TreeNode root, int k) {
        if (root == null) return;
        helper(root.left, k);
        if (++cnt == k) {
            res = root.val;
            return;
        }
        helper(root.right, k);
    }
}
```

# 7 Question-236[★★★★★]

**Lowest Common Ancestor of a Binary Tree**

> Given a binary tree, find the lowest common ancestor (LCA) of two given nodes in the tree.

> According to the definition of LCA on Wikipedia: “The lowest common ancestor is defined between two nodes v and w as the lowest node in T that has both v and w as descendants (where we allow a node to be a descendant of itself).”

```java
public class Solution {
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null) return root;

        if (root == p || root == q) return root;

        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);

        //p和q分别位于root的左右子树中，因此root是ancestor
        if (left != null && right != null) return root;

        //否则left或right是ancestor
        return left == null ? right : left;
    }
}
```

<!--

# 8 Question-000[★]

____

> 

```java
```

-->
