---
title: Algorithm BinarySearch
date: 2017-07-16 21:15:03
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-34

```Java
public class Solution {
    public int[] searchRange(int[] nums, int target) {
        return new int[]{leftBoundary(nums, target), rightBoundary(nums, target)};
    }

    private int leftBoundary(int[] nums, int target) {
        if (nums == null || nums.length == 0) return -1;

        int left = 0, right = nums.length - 1;

        if (nums[left] > target || nums[right] < target) return -1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] >= target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return nums[left] == target ? left : -1;
    }

    private int rightBoundary(int[] nums, int target) {
        if (nums == null || nums.length == 0) return -1;

        int left = 0, right = nums.length - 1;

        if (nums[left] > target || nums[right] < target) return -1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] <= target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return nums[right] == target ? right : -1;
    }
}
```
