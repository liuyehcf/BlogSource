---
title: Algorithm Stack
date: 2017-07-16 21:14:54
tags: 
- 原创
categories: 
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-84[★★★★★]

__Largest Rectangle in Histogram__

> Given n non-negative integers representing the histogram's bar height where the width of each bar is 1, find the area of largest rectangle in the histogram.

```Java
public class Solution {
    public int largestRectangleArea(int[] heights) {
        LinkedList<Integer> stack = new LinkedList<Integer>();

        int res = 0;

        for (int i = 0; i < heights.length; i++) {
            int curHeight = heights[i];

            while (!canPushToStack(heights, stack, curHeight)) {
                int topHeight = heights[stack.pop()];

                int beginIndex = getBeginIndex(stack);

                // 注意这里的endIndex是i-1
                res = Math.max(res, topHeight * (i - 1 - beginIndex + 1));
            }

            stack.push(i);
        }

        while (!stack.isEmpty()) {
            int topHeight = heights[stack.pop()];

            int beginIndex = getBeginIndex(stack);

            // 注意这里的endIndex是heights.length - 1
            res = Math.max(res, topHeight * (heights.length - 1 - beginIndex + 1));
        }

        return res;
    }

    private boolean canPushToStack(int[] heights, LinkedList<Integer> stack, int val) {
        if (stack.isEmpty()) return true;

        // 这里注意，必须严格单调
        return val > heights[stack.peek()];
    }

    private int getBeginIndex(LinkedList<Integer> stack) {
        if (stack.isEmpty()) return 0;
        return stack.peek() + 1;
    }
}
```
