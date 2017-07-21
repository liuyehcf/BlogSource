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

# 1 Question-11

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

# 2 Question-72

递推表达式

* `dp[i][j] = min(dp[i - 1][j - 1], dp[i][j - 1] + 1, dp[i - 1][j] + 1)`
* `dp[i][j] = min(dp[i - 1][j - 1] + 1, dp[i][j - 1] + 1, dp[i - 1][j] + 1)`

另外注意一下初始化

```Java
public class Solution {
    public int minDistance(String word1, String word2) {
        int[][] dp = new int[word1.length() + 1][word2.length() + 1];

        //需要进行初始化
        for (int i = 1; i <= word1.length(); i++) {
            dp[i][0] = i;
        }

        for (int j = 1; j <= word2.length(); j++) {
            dp[0][j] = j;
        }

        for (int i = 1; i <= word1.length(); i++) {
            for (int j = 1; j <= word2.length(); j++) {
                char c1 = word1.charAt(i - 1);
                char c2 = word2.charAt(j - 1);
                if (c1 == c2) {
                    dp[i][j] = min(dp[i - 1][j - 1], dp[i][j - 1] + 1, dp[i - 1][j] + 1);
                } else {
                    dp[i][j] = min(dp[i - 1][j - 1] + 1, dp[i][j - 1] + 1, dp[i - 1][j] + 1);
                }
            }
        }

        return dp[word1.length()][word2.length()];
    }

    private int min(int... args) {
        int res = Integer.MAX_VALUE;
        for (int i = 0; i < args.length; i++) {
            res = Math.min(res, args[i]);
        }
        return res;
    }
}
```

# 3 Question-188

递推表达式

1. `buys[i] = Math.max(buys[i], sells[i - 1] - prices[day])`
1. `sells[i] = Math.max(sells[i], buys[i] + prices[day])`

```Java
public class Solution {
    public int maxProfit(int k, int[] prices) {
        if (k > prices.length) {
            return simpleSolution(prices);
        }

        int[] buys = new int[k + 1];

        Arrays.fill(buys, Integer.MIN_VALUE);

        int[] sells = new int[k + 1];

        for (int day = 0; day < prices.length; day++) {
            for (int i = 1; i <= k; i++) {
                buys[i] = Math.max(buys[i], sells[i - 1] - prices[day]);
                sells[i] = Math.max(sells[i], buys[i] + prices[day]);
            }
        }

        return sells[k];
    }

    private int simpleSolution(int[] prices) {
        int res = 0;
        for (int i = 1; i < prices.length; i++) {
            if (prices[i] > prices[i - 1])
                res += prices[i] - prices[i - 1];
        }
        return res;
    }
}
```
