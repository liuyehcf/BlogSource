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

# 1 tips

## 1.1 左右边界的递归

由于数组是有序的，假设是一个递增的序列

* 如果`nums[mid] > target`，只要找到一个能包括target的子集即可，因此下一次迭代的范围就是`[left,mid-1]`
* 如果`nums[mid] < target`，只要找到一个能包括target的子集集合，因此下一次迭代的范围就是`[mid+1,right]`

## 1.2 返回值的讨论

循环条件是`left <= right`，因此循环结束时`left = right + 1`，只需要讨论以下三种情况即可

* `target nums[left] nums[right]`
* `nums[left] target nums[right]`
* `nums[left] nums[right] target`

# 2 Question-4

__Median of Two Sorted Arrays__

> There are two sorted arrays nums1 and nums2 of size m and n respectively.

> Find the median of the two sorted arrays. The overall run time complexity should be `O(log (m+n))`.

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

# 3 Question-34

__Search for a Range__

> Given an array of integers sorted in ascending order, find the starting and ending position of a given target value.

> Your algorithm's runtime complexity must be in the order of `O(log n)`.

> If the target is not found in the array, return `[-1, -1]`.

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

# 4 Question-35

__Search Insert Position__

> Given a sorted array and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

```Java
public class Solution {
    public int searchInsert(int[] nums, int target) {
        if (nums.length == 0) return 0;
        if (target < nums[0]) return 0;
        if (target > nums[nums.length - 1]) return nums.length;

        int left = 0, right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);
            if (nums[mid] == target) return mid;
            else if (nums[mid] > target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return left;
    }
}
```

# 5 Question-50

__`Pow(x, n)`__

> Implement `pow(x, n)`.

```Java
public class Solution {
    public double myPow(double x, int n) {
        if (n == 0) return 1;
        else if (n == 1) return x;
        else if (n == -1) return 1 / x;

        int half = n / 2;

        double temp = myPow(x, half);
        return temp * temp * myPow(x, n - half * 2);
    }
}
```
