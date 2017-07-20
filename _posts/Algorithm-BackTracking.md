---
title: Algorithm Recall
date: 2017-07-16 21:15:33
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-90

```Java
public class Solution {
    public List<List<Integer>> subsetsWithDup(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();

        List<Integer> pre = new ArrayList<Integer>();

        Arrays.sort(nums);

        helper(nums, 0, res, pre);

        return res;
    }

    private void helper(int[] nums, int pos, List<List<Integer>> res, List<Integer> pre) {
        res.add(new ArrayList<Integer>(pre));
        if (pos == nums.length) return;

        for (int start = pos; start < nums.length; start++) {

            if (start > pos && nums[start] == nums[start - 1]) continue;

            pre.add(nums[start]);

            helper(nums, start + 1, res, pre);

            pre.remove(pre.size() - 1);
        }
    }
}
```
