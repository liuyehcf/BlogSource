---
title: Algorithm Array
date: 2017-07-16 21:14:35
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question [4]

```Java
public class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int len = nums1.length + nums2.length;

        return (helper(nums1, 0, nums2, 0, (len + 1) / 2) + helper(nums1, 0, nums2, 0, (len + 2) / 2)) / 2;
    }

    private double helper(int[] nums1, int pos1, int[] nums2, int pos2, int index) {
        if (pos1 == nums1.length) return nums2[pos2 + index - 1];
        else if (pos2 == nums2.length) return nums1[pos1 + index - 1];
        else if (index == 1) return nums1[pos1] < nums2[pos2] ? nums1[pos1] : nums2[pos2];

        int stepForward = index / 2;

        int nextPos1 = pos1 + stepForward - 1;
        int nextPos2 = pos2 + stepForward - 1;

        int val1 = nextPos1 < nums1.length ? nums1[nextPos1] : Integer.MAX_VALUE;
        int val2 = nextPos2 < nums2.length ? nums2[nextPos2] : Integer.MAX_VALUE;

        if (val1 < val2)
            return helper(nums1, nextPos1 + 1, nums2, pos2, index - stepForward);
        else
            return helper(nums1, pos1, nums2, nextPos2 + 1, index - stepForward);
    }
}
```
