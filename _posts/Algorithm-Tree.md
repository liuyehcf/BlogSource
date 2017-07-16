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

# 1 Question [124]

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
