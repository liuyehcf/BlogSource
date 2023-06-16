---
title: Algorithm-String
date: 2017-07-16 21:17:36
tags: 
- 原创
categories: 
- Algorithm
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

# 5 Question-28[★★★★]

这题可以由KMP算法解决

> The algorithm is designed to improve upon the performance of traditional pattern-matching algorithms, such as the naïve approach or the brute-force method. The key idea behind the KMP algorithm is to avoid unnecessary character comparisons by utilizing information about the pattern itself.
> 
> Here's a high-level overview of how the KMP algorithm works:
> 
> 1. Preprocessing (Building the "Partial Match" Table):
>   * The algorithm analyzes the pattern and constructs a "partial match" table, also known as the "failure function" or "pi function."
>   * This table helps determine the number of characters to shift the pattern when a mismatch occurs during the search.
> 2. Searching:
>   * The algorithm starts matching characters of the pattern against the text from left to right.
>   * If a character in the pattern matches the corresponding character in the text, both pointers are advanced.
>   * If a mismatch occurs:
>       * The algorithm uses the partial match table to determine the maximum number of characters it can safely skip in the pattern.
>       * It shifts the pattern by that amount and resumes matching from the new position, avoiding redundant comparisons.
> 
> By utilizing the partial match table, the KMP algorithm achieves a linear time complexity for pattern matching, specifically O(n + m), where n is the length of the text and m is the length of the pattern. This improvement makes it more efficient than the brute-force method, which has a time complexity of O(n * m).
> 
> The KMP algorithm is widely used in various applications that involve pattern matching, such as text editors, search engines, bioinformatics, and data mining, where efficient string searching is required.
> 
> It's worth noting that while the KMP algorithm provides an efficient solution for pattern matching, it may not always be the optimal choice depending on the specific requirements and characteristics of the problem at hand. Other algorithms, such as Boyer-Moore or Rabin-Karp, may be more suitable in certain scenarios.

```cpp
class Solution {
public:
    int strStr(std::string text, std::string pattern) {
        if (pattern.length() == 0) {
            return 0;
        }

        // pi[i] represents the length of the longest proper suffix, which is also a prefix,
        // of the pattern's substring ending at position i, [0, i]
        std::vector<int> pi(pattern.length(), 0);

        // Empty string's longest suffix is empty itself, the lenght is zero
        int j = 0;

        for (int i = 1; i < pattern.size(); i++) {
            while (j > 0 && pattern[i] != pattern[j]) {
                // pi[j - 1] means the legnth of the longest pre-suffix of range [0, i - 1]
                // so the next position to be checked is at pi[j - 1], we can continue to search at pattern[pi[j - 1]]
                j = pi[j - 1];
            }

            if (pattern[i] == pattern[j]) {
                // j is the index, so (index + 1) means the length
                pi[i] = ++j;
            }
        }

        j = 0;

        for (int i = 0; i < text.length(); i++) {
            while (j > 0 && text[i] != pattern[j]) {
                j = pi[j - 1];
            }

            if (text[i] == pattern[j]) {
                if (j == pattern.length() - 1) {
                    return i - j;
                } else {
                    j++;
                }
            }
        }

        return -1;
    }
};
```

# 6 Question-32[★★★★]

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

# 7 Question-49[★★★★]

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

# 8 Question-000[★]

____

> 

```java
```

-->
