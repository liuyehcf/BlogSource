---
title: Algorithm DP
date: 2017-07-16 21:15:39
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question [11]

```Java
public class Solution {
    public boolean isMatch(String s, String p) {
        boolean[][] dp = new boolean[s.length() + 1][p.length() + 1];

        dp[0][0] = true;

        for (int i = 2; ; i += 2) {
            if (getChar(p, i) == '*')
                dp[0][i] = true;
            else
                break;
        }

        for (int i = 1; i <= s.length(); i++) {
            for (int j = 1; j <= p.length(); j++) {
                if (getChar(p, j + 1) == '*') {
                    continue;
                } else if (getChar(p, j) == '*') {
                    if (getChar(p, j - 1) == '.' || getChar(s, i) == getChar(p, j - 1)) {
                        dp[i][j] = dp[i][j - 2] || dp[i - 1][j];
                    } else {
                        dp[i][j] = dp[i][j - 2];
                    }
                } else if (getChar(p, j) == '.' || getChar(s, i) == getChar(p, j)) {
                    dp[i][j] = dp[i - 1][j - 1];
                } else {
                    dp[i][j] = false;
                }
            }
        }

        return dp[s.length()][p.length()];
    }

    private char getChar(String s, int i) {
        if (i < 1 || i > s.length()) return '\0';
        return s.charAt(i - 1);
    }
}
```
