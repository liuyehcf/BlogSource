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

# 1 Question-4

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

# 2 Question-31

二分查找还是需要重点关注一下的，最后返回值的一个判断。另外就是逆序一个子数组，如何取中间，一个很好的办法是判断`left < right`即可，对应本题就是`i < nums.length - 1 - (i - begin)`

```Java
public class Solution {
    public void nextPermutation(int[] nums) {
        int i = nums.length - 1;

        while (i >= 1 && nums[i - 1] >= nums[i]) {
            i--;
        }

        if (i == 0) {
            reverse(nums, 0);
            return;
        }

        //需要交换的值
        int val = nums[i - 1];

        //在有序子数组中找出大于val的最小值的位置
        int index = smallestLarger(nums, i, val);

        //交换这两个值
        exchange(nums, i - 1, index);

        //重排序子数组
        reverse(nums, i);
    }

    private int smallestLarger(int[] nums, int left, int target) {
        int right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] > target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        if (left < nums.length && nums[left] > target) return left;
        else return left - 1;
    }

    private void exchange(int[] nums, int i, int j) {
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
    }

    private void reverse(int[] nums, int begin) {
        for (int i = begin; i < nums.length - 1 - (i - begin); i++) {
            exchange(nums, i, nums.length - 1 - (i - begin));
        }
    }
}
```
