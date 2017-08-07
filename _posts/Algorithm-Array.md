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

# 1 Question-11[★★★]

__Container With Most Water__

> Given n non-negative integers a1, a2, ..., an, where each represents a point at coordinate (i, ai). n vertical lines are drawn such that the two endpoints of line i is at (i, ai) and (i, 0). Find two lines, which together with x-axis forms a container, such that the container contains the most water.

```Java
public class Solution {
    public int maxArea(int[] height) {
        int left = 0, right = height.length - 1;

        int res = area(height, left, right);

        int leftMaxHeight = height[left];
        int rightMaxHeight = height[right];

        while (left < right) {
            if (leftMaxHeight < rightMaxHeight) {
                left++;

                if (height[left] > leftMaxHeight) {
                    leftMaxHeight = height[left];
                    res = Math.max(res, area(height, left, right));
                }
            } else {
                right--;

                if (height[right] > rightMaxHeight) {
                    rightMaxHeight = height[right];
                    res = Math.max(res, area(height, left, right));
                }
            }
        }

        return res;
    }

    private int area(int[] height, int left, int right) {
        return Math.min(height[left], height[right]) * (right - left);
    }
}
```

# 2 Question-15[★★]

__3Sum__

> Given an array S of n integers, are there elements a, b, c in S such that `a + b + c = 0`? Find all unique triplets in the array which gives the sum of zero.

```Java
public class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();

        Arrays.sort(nums);

        for (int i = 0; i < nums.length - 2; i++) {
            if (i > 0 && nums[i] == nums[i - 1]) continue;

            int left = i + 1, right = nums.length - 1;

            while (left < right) {
                if (nums[left] + nums[right] == -nums[i]) {
                    res.add(Arrays.asList(nums[i], nums[left], nums[right]));

                    ++left;
                    --right;

                    while (left < right && nums[left] == nums[left - 1]) left++;

                    while (left < right && nums[right] == nums[right + 1]) right--;
                } else if (nums[left] + nums[right] > -nums[i]) {
                    right--;
                } else {
                    left++;
                }
            }
        }

        return res;
    }
}
```

# 3 Question-31[★★★★★]

__Next Permutation__

> Implement next permutation, which rearranges numbers into the lexicographically next greater permutation of numbers.

> If such arrangement is not possible, it must rearrange it as the lowest possible order (ie, sorted in ascending order).

> The replacement must be in-place, do not allocate extra memory.

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

        // 需要交换的值
        int val = nums[i - 1];

        // 在有序子数组中找出大于val的最小值的位置
        int index = smallestLarger(nums, i, val);

        // 交换这两个值
        exchange(nums, i - 1, index);

        // 重排序子数组
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

# 4 Question-42[★★★★★]

__Trapping Rain Water__

> Given n non-negative integers representing an elevation map where the width of each bar is 1, compute how much water it is able to trap after raining.

```Java
public class Solution {
    public int trap(int[] height) {
        if (height == null || height.length == 0) return 0;

        int left = 0, right = height.length - 1;

        int leftMost = height[left];
        int rightMost = height[right];

        int res = 0;

        while (left < right) {
            int tmp = 0;
            if (leftMost < rightMost) {
                tmp = height[++left];
                leftMost = Math.max(leftMost, height[left]);
            } else {
                tmp = height[--right];
                rightMost = Math.max(rightMost, height[right]);
            }

            res += Math.max(0, Math.min(leftMost, rightMost) - tmp);
        }

        return res;
    }
}
```

# 5 Question-56[★★★★]

__Merge Intervals__

> Given a collection of intervals, merge all overlapping intervals.

```Java
/**
 * Definition for an interval.
 * public class Interval {
 * int start;
 * int end;
 * Interval() { start = 0; end = 0; }
 * Interval(int s, int e) { start = s; end = e; }
 * }
 */
public class Solution {
    public List<Interval> merge(List<Interval> intervals) {
        List<Interval> res = new ArrayList<>();

        if (intervals.isEmpty()) return res;

        Collections.sort(intervals, (obj1, obj2) -> {
            return obj1.start - obj2.start;
        });

        Iterator<Interval> iterator = intervals.iterator();

        Interval pre = iterator.next();

        while (iterator.hasNext()) {
            Interval cur = iterator.next();

            if (pre.end < cur.start) {
                res.add(pre);
                pre = cur;
            } else if (pre.start > cur.end) {
                res.add(cur);
            } else {
                pre.start = Math.min(pre.start, cur.start);
                pre.end = Math.max(pre.end, cur.end);
            }
        }

        res.add(pre);

        return res;
    }
}
```

# 6 Question-134[★★★★★]

__Gas Station__

> There are N gas stations along a circular route, where the amount of gas at station i is gas[i].

> You have a car with an unlimited gas tank and it costs cost[i] of gas to travel from station i to its next station (i+1). You begin the journey with an empty tank at one of the gas stations.

> Return the starting gas station's index if you can travel around the circuit once, otherwise return -1.

```Java
public class Solution {
    public int canCompleteCircuit(int[] gas, int[] cost) {
        int remain = 0;
        int start = 0;
        int lack = 0;

        for (int i = 0; i < gas.length; i++) {
            remain -= cost[i];
            remain += gas[i];
            if (remain < 0) {
                lack -= remain;
                remain = 0;
                start = i + 1;
            }
        }

        return remain >= lack ? start : -1;
    }
}
```

# 7 Question-209[★★★]

__Minimum Size Subarray Sum__

> Given an array of n positive integers and a positive integer s, find the minimal length of a contiguous subarray of which the sum ≥ s. If there isn't one, return 0 instead.

```Java
public class Solution {
    public int minSubArrayLen(int s, int[] nums) {
        int begin = 0, end = 0;
        int sum = 0;
        int maxLen = Integer.MAX_VALUE;

        while (end < nums.length) {
            sum += nums[end];

            while (sum >= s) {
                maxLen = Math.min(maxLen, end - begin + 1);

                sum -= nums[begin++];
            }

            end++;
        }

        return maxLen == Integer.MAX_VALUE ? 0 : maxLen;
    }
}
```

<!--

# 8 Question-000[★]

____

> 

```Java
```

-->
