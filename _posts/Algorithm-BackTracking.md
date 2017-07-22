---
title: Algorithm BackTracking
date: 2017-07-16 21:15:33
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-17[★★]

__Letter Combinations of a Phone Number__

> Given a digit string, return all possible letter combinations that the number could represent.

```Java
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

# 2 Question-90[★★★★★]

__Subsets II__

> Given a collection of integers that might contain duplicates, nums, return all possible subsets.

```Java
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
