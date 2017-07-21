---
title: Algorithm String
date: 2017-07-16 21:17:36
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-32

__超时的版本__

```Java
public class Solution {
    public int longestValidParentheses(String s) {
        int[] dp = new int[s.length() + 1];

        dp[0] = 0;

        int res = 0;

        for (int i = 1; i <= s.length(); i++) {
            if (getChar(s, i) == ')') {
                int j = i - 1, cnt = 1;
                while (cnt != 0 && j >= 1) {
                    if (getChar(s, j) == ')') cnt++;
                    else cnt--;
                    j--;
                }

                if (cnt == 0) {
                    dp[i] = i - (j + 1) + 1 + dp[j];
                    res = Math.max(res, dp[i]);
                }
            }
        }

        return res;
    }

    private char getChar(String s, int index) {
        return s.charAt(index - 1);
    }
}
```

__改进后的版本__

```Java
public class Solution {
    public int longestValidParentheses(String s) {
        int[] dp = new int[s.length() + 1];

        dp[0] = 0;

        int res = 0;

        for (int i = 1; i <= s.length(); i++) {
            if (getChar(s, i) == ')') {
                int len = dp[i - 1];

                int begin = i - len;

                if (begin - 1 >= 1 && getChar(s, begin - 1) == '(') {
                    dp[i] = dp[begin - 2] + len + 2;
                    res = Math.max(res, dp[i]);
                }
            }
        }

        return res;
    }

    private char getChar(String s, int index) {
        return s.charAt(index - 1);
    }
}
```
