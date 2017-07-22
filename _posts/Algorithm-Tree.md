---
title: Algorithm Tree
date: 2017-07-16 21:14:53
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-124[★★★★★]

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

# 2 Question-222[★★★★★]

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

# 3 Question-230[★★]

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
