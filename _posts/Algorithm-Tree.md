---
title: Algorithm-Tree
date: 2017-07-16 21:14:53
tags: 
- 原创
categories: 
- Job
- Leetcode
---

__阅读更多__

<!--more-->

# 1 Question-105[★★★★★]

__Construct Binary Tree from Preorder and Inorder Traversal__

> Given preorder and inorder traversal of a tree, construct the binary tree.

```Java
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

# 2 Question-106[★★★★★]

__Construct Binary Tree from Inorder and Postorder Traversal__

> Given inorder and postorder traversal of a tree, construct the binary tree.

```Java
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

# 3 Question-124[★★★★★]

__Binary Tree Maximum Path Sum__

> Given a binary tree, find the maximum path sum.

> For this problem, a path is defined as any sequence of nodes from some starting node to any node in the tree along the parent-child connections. The path must contain at least one node and does not need to go through the root.

```Java
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

# 4 Question-222[★★★★★]

__Count Complete Tree Nodes__

> Given a complete binary tree, count the number of nodes.

```Java
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

# 5 Question-230[★★]

__Kth Smallest Element in a BST__

> Given a binary search tree, write a function kthSmallest to find the kth smallest element in it.

```Java
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

# 6 Question-236[★★★★★]

__Lowest Common Ancestor of a Binary Tree__

> Given a binary tree, find the lowest common ancestor (LCA) of two given nodes in the tree.

> According to the definition of LCA on Wikipedia: “The lowest common ancestor is defined between two nodes v and w as the lowest node in T that has both v and w as descendants (where we allow a node to be a descendant of itself).”

```Java
public class Solution {
    public TreeNode lowestCommonAncestor(TreeNode root, TreeNode p, TreeNode q) {
        if (root == null) return root;

        if (root == p || root == q) return root;

        TreeNode left = lowestCommonAncestor(root.left, p, q);
        TreeNode right = lowestCommonAncestor(root.right, p, q);

        // p和q分别位于root的左右子树中，因此root是ancestor
        if (left != null && right != null) return root;

        // 否则left或right是ancestor
        return left == null ? right : left;
    }
}
```

<!--

# 7 Question-000[★]

____

> 

```Java
```

-->
