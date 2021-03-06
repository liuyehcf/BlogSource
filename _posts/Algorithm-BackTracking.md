---
title: Algorithm-BackTracking
date: 2017-07-16 21:15:33
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-17[★★]

**Letter Combinations of a Phone Number**

> Given a digit string, return all possible letter combinations that the number could represent.

```java
public class Solution {

    String[] mappings = new String[]{
            "abc",
            "def",
            "ghi",
            "jkl",
            "mno",
            "pqrs",
            "tuv",
            "wxyz"
    };

    public List<String> letterCombinations(String digits) {
        List<String> res = new ArrayList<String>();

        if (digits.length() == 0) return res;

        StringBuilder sb = new StringBuilder();

        helper(digits, 0, res, sb);

        return res;
    }

    private void helper(String digits, int index, List<String> res, StringBuilder sb) {
        if (index == digits.length()) {
            res.add(sb.toString());
            return;
        }

        String map = getMap(digits, index);

        for (int i = 0; i < map.length(); i++) {
            sb.append(map.charAt(i));

            helper(digits, index + 1, res, sb);

            sb.setLength(sb.length() - 1);
        }
    }

    private String getMap(String digits, int index) {
        return mappings[digits.charAt(index) - '2'];
    }
}
```

# 2 Question-39[★★★★]

**Combination Sum**

> Given a set of candidate numbers (C) (without duplicates) and a target number (T), find all unique combinations in C where the candidate numbers sums to T.

> The same repeated number may be chosen from C unlimited number of times.

```java
public class Solution {
    public List<List<Integer>> combinationSum(int[] candidates, int target) {
        Arrays.sort(candidates);

        List<List<Integer>> res = new ArrayList<>();

        List<Integer> pre = new ArrayList<>();

        helper(candidates, target, 0, res, pre);

        return res;
    }

    private void helper(int[] candidates, int target, int index, List<List<Integer>> res, List<Integer> pre) {
        if (index == candidates.length) {
            return;
        }

        if (target == 0) {
            res.add(new ArrayList<Integer>(pre));
            return;
        }

        for (int start = index; start < candidates.length; start++) {
            if (start > index && candidates[start] == candidates[start - 1]) continue;
            if (candidates[start] > target) return;

            pre.add(candidates[start]);

            helper(candidates, target - candidates[start], start, res, pre);

            pre.remove(pre.size() - 1);
        }
    }
}
```

# 3 Question-46[★★★★★]

**Permutations**

> Given a collection of distinct numbers, return all possible permutations.

```java
public class Solution {
    public List<List<Integer>> permute(int[] nums) {

        List<List<Integer>> res = new ArrayList<>();

        if (nums == null || nums.length == 0) return res;

        boolean[] used = new boolean[nums.length];

        List<Integer> pre = new ArrayList<Integer>();

        helper(nums, 0, res, pre, used);

        return res;
    }

    private void helper(int[] nums, int index, List<List<Integer>> res, List<Integer> pre, boolean[] used) {
        if (index == nums.length) {
            res.add(new ArrayList<Integer>(pre));
            return;
        }

        for (int i = 0; i < nums.length; i++) {
            if (used[i]) continue;

            pre.add(nums[i]);
            used[i] = true;

            helper(nums, index + 1, res, pre, used);

            used[i] = false;
            pre.remove(pre.size() - 1);
        }

    }
}
```

# 4 Question-78[★★★★★]

**Subsets**

> Given a set of distinct integers, nums, return all possible subsets.

```java
class Solution {
    public List<List<Integer>> subsets(int[] nums) {
      List<List<Integer>> res = new ArrayList<List<Integer>>();

        List<Integer> pre = new ArrayList<Integer>();

        helper(nums, 0, res, pre);

        return res;
    }

    private void helper(int[] nums, int pos, List<List<Integer>> res, List<Integer> pre) {
        res.add(new ArrayList<Integer>(pre));
        if (pos == nums.length) return;

        for (int start = pos; start < nums.length; start++) {

            pre.add(nums[start]);

            helper(nums, start + 1, res, pre);

            pre.remove(pre.size() - 1);
        }
    }
}
```

# 5 Question-79[★★★★]

**Word Search**

> Given a 2D board and a word, find if the word exists in the grid.

> The word can be constructed from letters of sequentially adjacent cell, where "adjacent" cells are those horizontally or vertically neighboring. The same letter cell may not be used more than once.

```java
class Solution {
    public boolean exist(char[][] board, String word) {
        int m, n;
        if ((m = board.length) == 0 || (n = board[0].length) == 0) {
            return false;
        }

        boolean[][] used = new boolean[m][n];

        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (helper(board, used, i, j, word, 0)) return true;
            }
        }

        return false;
    }

    private boolean helper(char[][] board, boolean[][] used, int row, int col, String word, int index) {
        int m = board.length, n = board[0].length;

        if (board[row][col] != word.charAt(index)) return false;

        if (index == word.length() - 1) return true;

        used[row][col] = true;

        if (row > 0 && !used[row - 1][col] && helper(board, used, row - 1, col, word, index + 1))
            return true;
        if (row < m - 1 && !used[row + 1][col] && helper(board, used, row + 1, col, word, index + 1))
            return true;
        if (col > 0 && !used[row][col - 1] && helper(board, used, row, col - 1, word, index + 1))
            return true;
        if (col < n - 1 && !used[row][col + 1] && helper(board, used, row, col + 1, word, index + 1))
            return true;

        used[row][col] = false;

        return false;
    }
}
```

# 6 Question-90[★★★★★]

**Subsets II**

> Given a collection of integers that might contain duplicates, nums, return all possible subsets.

```java
public class Solution {
    public List<List<Integer>> subsetsWithDup(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();

        List<Integer> pre = new ArrayList<Integer>();

        Arrays.sort(nums);

        helper(nums, 0, res, pre);

        return res;
    }

    private void helper(int[] nums, int pos, List<List<Integer>> res, List<Integer> pre) {
        res.add(new ArrayList<Integer>(pre));
        if (pos == nums.length) return;

        for (int start = pos; start < nums.length; start++) {

            if (start > pos && nums[start] == nums[start - 1]) continue;

            pre.add(nums[start]);

            helper(nums, start + 1, res, pre);

            pre.remove(pre.size() - 1);
        }
    }
}
```

<!--

# 7 Question-000[★]

____

> 

```java
```

-->
