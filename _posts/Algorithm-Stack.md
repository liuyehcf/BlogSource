---
title: Algorithm-Stack
date: 2017-07-16 21:14:54
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-32[★★★★★]

> Given a string containing just the characters '(' and ')', find the length of the longest valid (well-formed) parentheses substring.

```java
class Solution {
    public int longestValidParentheses(String s) {
        LinkedList<Integer> stack = new LinkedList<>();

        int max = 0;

        for (int i = 0; i < s.length(); i++) {
            if (s.charAt(i) == '(') {
                stack.push(i);
            } else {
                if (!stack.isEmpty()) {
                    // find a match
                    if (s.charAt(stack.peek()) == '(') {
                        stack.pop();
                    } else {
                        stack.push(i);
                    }
                } else {
                    stack.push(i);
                }
            }
        }

        // now stack contains the indices of characters which cannot be matched

        if (stack.isEmpty()) {
            max = s.length();
        } else {
            int right = s.length();

            while (!stack.isEmpty()) {
                int left = stack.pop();

                // [left+1, right) is matched
                max = Math.max(max, right - (left + 1));

                right = left;
            }

            // [0, right) is matched
            max = Math.max(max, right);
        }
        return max;
    }
}
```

# 2 Question-84[★★★★★]

**Largest Rectangle in Histogram**

> Given n non-negative integers representing the histogram's bar height where the width of each bar is 1, find the area of largest rectangle in the histogram.

```java
public class Solution {
    public int largestRectangleArea(int[] heights) {
        LinkedList<Integer> stack = new LinkedList<Integer>();

        int res = 0;

        for (int i = 0; i < heights.length; i++) {
            int curHeight = heights[i];

            while (!canPushToStack(heights, stack, curHeight)) {
                int topHeight = heights[stack.pop()];

                int beginIndex = getBeginIndex(stack);

                //注意这里的endIndex是i-1
                res = Math.max(res, topHeight * (i - 1 - beginIndex + 1));
            }

            stack.push(i);
        }

        while (!stack.isEmpty()) {
            int topHeight = heights[stack.pop()];

            int beginIndex = getBeginIndex(stack);

            //注意这里的endIndex是heights.length - 1
            res = Math.max(res, topHeight * (heights.length - 1 - beginIndex + 1));
        }

        return res;
    }

    private boolean canPushToStack(int[] heights, LinkedList<Integer> stack, int val) {
        if (stack.isEmpty()) return true;

        //这里注意，必须严格单调
        return val > heights[stack.peek()];
    }

    private int getBeginIndex(LinkedList<Integer> stack) {
        if (stack.isEmpty()) return 0;
        return stack.peek() + 1;
    }
}
```

<!--

# 3 Question-000[★]

____

> 

```java
```

-->
