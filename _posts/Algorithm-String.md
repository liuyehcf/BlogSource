---
title: Algorithm-String
date: 2017-07-16 21:17:36
tags: 
- 原创
categories: 
- Job
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-3[★★★]

**Longest Substring Without Repeating Characters**

> Given a string, find the length of the longest substring without repeating characters.

```java
public class Solution {
    public int lengthOfLongestSubstring(String s) {
        int[] cnt = new int[128];

        int begin = 0, end = 0, res = 0;

        while (end < s.length()) {
            char c = s.charAt(end);

            cnt[c]++;

            while (cnt[c] > 1) {
                cnt[s.charAt(begin++)]--;
            }

            res = Math.max(res, end - begin + 1);

            end++;
        }
        return res;
    }
}
```

# 2 Question-5[★★★]

**Longest Palindromic Substring**

> Given a string s, find the longest palindromic substring in s. You may assume that the maximum length of s is 1000.

```java
public class Solution {
    private int left;

    private int right;

    public String longestPalindrome(String s) {
        for (int i = 0; i < s.length() - 1; i++) {
            helper(s, i, i);
            helper(s, i, i + 1);
        }

        return s.substring(left, right + 1);
    }

    private void helper(String s, int i, int j) {
        while (i >= 0 && j <= s.length() - 1 && s.charAt(i) == s.charAt(j)) {
            i--;
            j++;
        }

        if (j - 1 - (i + 1) + 1 > (right - left + 1)) {
            left = i + 1;
            right = j - 1;
        }
    }
}
```

# 3 Question-20[★★★★]

**Valid Parentheses**

> Given a string containing just the characters `'('`, `')'`, `'{'`, `'}'`, `'['` and `']'`, determine if the input string is valid.

> The brackets must close in the correct order, `"()"` and `"()[]{}"` are all valid but `"(]"` and `"([)]"` are not.

**错误的版本**

* 反例：`[(])`

```java
public class Solution {
    public boolean isValid(String s) {
        int[] cnt = new int[3];

        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);

            if (c == '(') {
                cnt[0]++;
            } else if (c == '[') {
                cnt[1]++;
            } else if (c == '{') {
                cnt[2]++;
            } else if (c == ')') {
                if (--cnt[0] < 0) return false;
            } else if (c == ']') {
                if (--cnt[1] < 0) return false;
            } else if (c == '}') {
                if (--cnt[2] < 0) return false;
            }
        }

        return cnt[0] + cnt[1] + cnt[2] == 0;
    }
}
```

**正确的版本**

```java
public class Solution {
    public boolean isValid(String s) {
        LinkedList<Character> stack = new LinkedList<Character>();

        for (char c : s.toCharArray()) {
            if (c == '(' || c == '[' || c == '{') {
                stack.push(c);
            } else {
                if (stack.isEmpty()) return false;

                char top = stack.pop();

                if (!isMatch(top, c)) return false;
            }
        }

        return stack.isEmpty();
    }

    private boolean isMatch(char c1, char c2) {
        return c1 == '(' && c2 == ')'
                || c1 == '[' && c2 == ']'
                || c1 == '{' && c2 == '}';
    }
}
```

# 4 Question-22[★★★]

**Generate Parentheses**

> Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.

```java
public class Solution {
    public List<String> generateParenthesis(int n) {
        List<String> res = new ArrayList<String>();

        StringBuilder sb = new StringBuilder();

        helper(0, 0, n, res, sb);

        return res;
    }

    private void helper(int i, int j, int n, List<String> res, StringBuilder sb) {
        if (j == n) {
            res.add(sb.toString());
            return;
        } else if (i == j) {
            sb.append('(');
            helper(i + 1, j, n, res, sb);
            sb.setLength(sb.length() - 1);
        } else if (i == n) {
            sb.append(')');
            helper(i, j + 1, n, res, sb);
            sb.setLength(sb.length() - 1);
        } else {
            sb.append('(');
            helper(i + 1, j, n, res, sb);
            sb.setLength(sb.length() - 1);

            sb.append(')');
            helper(i, j + 1, n, res, sb);
            sb.setLength(sb.length() - 1);
        }
    }
}
```

# 5 Question-32[★★★★]

**Longest Valid Parentheses**

> Given a string containing just the characters `'('` and `')'`, find the length of the longest valid (well-formed) parentheses substring.

> For `"(()"`, the longest valid parentheses substring is `"()"`, which has `length = 2`.

**超时的版本**

```java
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

**改进后的版本**

```java
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

# 6 Question-49[★★★★]

**Group Anagrams**

> Given an array of strings, group anagrams together.

> For example, given: `["eat", "tea", "tan", "ate", "nat", "bat"]`

```java
public class Solution {
    public List<List<String>> groupAnagrams(String[] strs) {
        List<List<String>> res = new ArrayList<>();

        Map<String, List<String>> map = new HashMap<>();

        for (String s : strs) {
            String key = trieveKey(s);

            if (map.containsKey(key)) {
                map.get(key).add(s);
            } else {
                map.put(key, new ArrayList<String>());
                map.get(key).add(s);
            }
        }

        for (Map.Entry<String, List<String>> entry : map.entrySet()) {
            res.add(entry.getValue());
        }

        return res;
    }

    private String trieveKey(String word) {
        int[] count = new int[128];

        for (char c : word.toCharArray()) {
            count[c]++;
        }

        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < 128; i++) {
            while (count[i] != 0) {
                sb.append(i);
                count[i]--;
            }
        }

        return sb.toString();
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
