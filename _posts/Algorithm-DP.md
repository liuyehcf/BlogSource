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

# 1 Question-10[★★★★★]

__Regular Expression Matching__

> Implement regular expression matching with support for `'.'` and `'*'`.

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

# 2 Question-53[★★★]

__Maximum Subarray__

> Find the contiguous subarray within an array (containing at least one number) which has the largest sum.

> For example, given the array `[-2,1,-3,4,-1,2,1,-5,4]`,
> the contiguous subarray `[4,-1,2,1]` has the largest `sum = 6`.

```Java
public class Solution {
    public int maxSubArray(int[] nums) {
        if(nums==null||nums.length==0) return 0;
        
        int[] dp=new int[nums.length+1];
        
        int res=nums[0];
        
        for(int i=1;i<=nums.length;i++){
            dp[i]=(dp[i-1]>0?dp[i-1]:0)+nums[i-1];
            res=Math.max(res,dp[i]);
        }
        
        return res;
    }
}
```

# 3 Question-72[★★★★★]

__Edit Distance__

> Given two words word1 and word2, find the minimum number of steps required to convert word1 to word2. (each operation is counted as 1 step.)

> You have the following 3 operations permitted on a word:

> 1. Insert a character
> 1. Delete a character
> 1. Replace a character

递推表达式(LCS)

* `dp[i][j] = min(dp[i - 1][j - 1], dp[i][j - 1] + 1, dp[i - 1][j] + 1)`
* `dp[i][j] = min(dp[i - 1][j - 1] + 1, dp[i][j - 1] + 1, dp[i - 1][j] + 1)`

另外注意一下初始化

```Java
public class Solution {
    public int minDistance(String word1, String word2) {
        int[][] dp = new int[word1.length() + 1][word2.length() + 1];

        // 需要进行初始化
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

# 4 Question-174[★★★★★]

__Dungeon Game__

> The demons had captured the princess (P) and imprisoned her in the bottom-right corner of a dungeon. The dungeon consists of M x N rooms laid out in a 2D grid. Our valiant knight (K) was initially positioned in the top-left room and must fight his way through the dungeon to rescue the princess.

> The knight has an initial health point represented by a positive integer. If at any point his health point drops to 0 or below, he dies immediately.

> Some of the rooms are guarded by demons, so the knight loses health (negative integers) upon entering these rooms; other rooms are either empty (0's) or contain magic orbs that increase the knight's health (positive integers).

> In order to reach the princess as quickly as possible, the knight decides to move only rightward or downward in each step.

递推表达式

* `dp[row][col]=Math.max(Math.min(dp[row+1][col],dp[row][col+1])-dungeon[row][col],1);`

```Java
public class Solution {
    public int calculateMinimumHP(int[][] dungeon) {
        int m=dungeon.length;
        int n=dungeon[0].length;
        
        int[][] dp=new int[m][n];
        
        dp[m-1][n-1]=Math.max(1-dungeon[m-1][n-1],1);
        
        for(int row=m-2;row>=0;row--){
            dp[row][n-1]=Math.max(1,dp[row+1][n-1]-dungeon[row][n-1]);
        }
        
        for(int col=n-2;col>=0;col--){
            dp[m-1][col]=Math.max(1,dp[m-1][col+1]-dungeon[m-1][col]);
        }
        
        for(int row=m-2;row>=0;row--){
            for(int col=n-2;col>=0;col--){
                dp[row][col]=Math.max(Math.min(dp[row+1][col],dp[row][col+1])-dungeon[row][col],1);
            }
        }
        
        return dp[0][0];
    }
}
```

# 5 Question-188[★★★★★]

__Best Time to Buy and Sell Stock IV__

> Say you have an array for which the ith element is the price of a given stock on day i.

> Design an algorithm to find the maximum profit. You may complete at most k transactions.

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

<!--

# 6 Question-000[★]

____

> 

```Java
```

-->
