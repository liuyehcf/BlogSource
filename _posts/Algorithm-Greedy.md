---
title: Algorithm-Greedy
date: 2017-07-16 21:16:16
tags: 
- 原创
categories: 
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-55[★★★★★]

__Jump Game__

> Given an array of non-negative integers, you are initially positioned at the first index of the array.

> Each element in the array represents your maximum jump length at that position.

> Determine if you are able to reach the last index.

```Java
public class Solution {
    public boolean canJump(int[] nums) {
        if (nums == null || nums.length == 0) return false;

        int farest = 0;
        int curFar = 0;
        int i = 0;

        while (farest < nums.length - 1) {
            while (i <= farest) {
                curFar = Math.max(curFar, i + nums[i++]);
            }

            if (curFar == farest) return false;
            farest = curFar;
        }

        return true;
    }
}
```

<!--

# 2 Question-000[★]

____

> 

```Java
```

-->
