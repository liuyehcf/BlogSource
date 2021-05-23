---
title: LeetCode解题思路
date: 2018-10-24 06:36:36
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

<style>
table th:nth-of-type(1) {
    width: 1px;
}
table th:nth-of-type(2) {
    width: 200px;
}
table th:nth-of-type(3) {
    width: 50px;
}
table th:nth-of-type(4) {
    width: 50px;
}
table th:nth-of-type(5) {
    width: 500px;
}
</style>

| 题号 | 题目 | 类型 | 难度 | 解题思路 |
|:--|:--|:--|:--|:--|
| 1 | Two Sum | Numerical | ★★ | 遍历一遍，用map保存remain值 |
| 2 | Add Two Numbers | Numerical | ★ | 注意进位即可 |
| 3 | Longest Substring Without Repeating Characters | String | ★★★ | 滑动窗口，注意左索引更新的条件即可 |
| 4 | Median of Two Sorted Arrays | Array | ★★★★ | 合并两个有序数组的思路即可找到中值 |
| 5 | Longest Palindromic Substring | String | ★★★ | 从对称中心往两边衍生，找到最长的对称序列。对称中心可能是单个数也可能是2个数 |
| 6 | ~~ZigZag Conversion~~ | \ | \ | 垃圾题目 |
| 7 | Reverse Integer | Numerical | ★★ | 符号单独处理；循环式：`reverse = reverse * 10 + absX % 10` |
| 8 | ~~String to Integer (atoi)~~  | \ | \ | 垃圾题目 |
| 9 | Palindrome Number | Numerical | ★ | 把每一位保存下来，然后看是否首位对称即可 |
| 10 | Regular Expression Matching | Dp | ★★★★ | 通配符`*`的边界初始化，注意递推式 |
| 11 | Container With Most Water | Array | ★★★ | 左右边界，谁矮谁往中间靠 |
| 12 | Integer to Roman | Numerical | ★★ | 没啥意思 |
| 13 | Roman to Integer | Numerical | ★★ | 没啥意思 |
| 14 | Longest Common Prefix | String | ★ | 朴素的思路，找到第一个不相同的字符或者触达尾部 |
| 15 | 3Sum | Array | ★★★ | 首先排序。第一个数循环，注意跳过重复的，剩下两个数从两端向中间靠近，且同时要跳过重复的 |
| 16 | 3Sum Closest | Array | ★★★ | 思路同15 |
| 17 | Letter Combinations of a Phone Number | Recursion | ★★★ | 递归，每个位置把对应的字母都遍历一遍 |
| 18 | 4Sum | Array | ★★★ | 思路同15。前两个数两层循环，后面逻辑一样 |
| 19 | Remove Nth Node From End of List | LinkList | ★★ | 用pseudoHead避免head讨论。首先看下总长度，就能得出正向是第几个元素 |
| 20 | Valid Parentheses | Stack | ★★★★ | 若是左括号则进栈，若是右括号，则将栈顶出栈，且判断是否构成一对括号。最后判断栈是否为空 |
| 21 | Merge Two Sorted Lists | LinkList | ★ | 用pseudoHead避免head讨论。基本操作，合并有序数组 |
| 22 | Generate Parentheses | Recursion | ★★★ | 递归时，注意右括号的数量不能大于左括号 |
| 23 | Merge k Sorted Lists | LinkList | ★★★ | 用pseudoHead避免head讨论。与合并两个有序数组并无太大区别，只是需要维护k个索引 |
| 24 | Swap Nodes in Pairs | LinkList | ★★★ | 用pseudoHead避免head讨论。遍历时需要维护pre、first、second、next四个节点之间的关系 |
| 25 | Reverse Nodes in k-Group | LinkList | ★★★ | 用pseudoHead避免head讨论。每段的reverse操作用函数来进行，入参是pseudoHead以及tail |
| 26 | Remove Duplicates from Sorted Array | Array | ★★ | 维护left、right两个索引，跳过重复的值，将right的值放入left位置中即可 |
| 27 | Remove Element | Array | ★★ | 维护left、right两个索引，跳过指定的值，将right的值放入left位置中即可 |
| 28 | Implement strStr() | Array | ★★★★★ | KMP算法，`next[i]`表示，`[0, i)`这个区间内的最大前后缀长度，计算next时，j从-1开始，因为不能计算本身的前后缀，但是在后续匹配时，j从0开始 |
| 29 | ~~Divide Two Integers~~ | \ | \ | 垃圾题目 |
| 30 | Substring with Concatenation of All Words | String | ★★★★★ | 无思路 |
| 31 | Next Permutation | Array | ★★★ | 从右往左找逆序对（先高位循环，再低位循环，都是递减），然后以此为边界进行排序即可，若未找到，排序整个数组即可 |
| 32 | Longest Valid Parentheses | Stack | ★★★★★ | 同20（进栈逻辑略有不同），当遍历结束后，栈中存的是无法匹配的索引，但是两两之间是匹配的，需要依次出栈然后计算长度并取最大值 |
| 33 | Search in Rotated Sorted Array | BinarySearch | ★★★★ | 循环条件用`left < right`，这样能保证`mid`与`right`永远不相等 |
| 34 | Find First and Last Position of Element in Sorted Array | BinarySearch | ★★★ | `nums[mid]`与`target`在何种条件下取等号，可以控制左边界还是右边界 |
| 35 | Search Insert Position | BinarySearch | ★★★ | 先判断边界条件，再用二分法，最后left就是插入位置 |
| 36 | Valid Sudoku | Array | ★★★ | 检查横，纵，九宫格是否满足数独规范即可。`(row, col)`的九宫格序号：`row / 3 * 3 + col / 3`|
| 37 | Sudoku Solver | Recursion | ★★★ | 从左上到右下的遍历思路。判断方式同36，记得赋初值 |
| 38 | ~~Count and Say~~ | \ | \ | 垃圾题目 |
| 39 | Combination Sum | Recursion | ★★★ | 经典递归，递归思路：当前取第`i`个值，下一个值的取值范围是`[i, end)` |
| 40 | Combination Sum II | Recursion | ★★★ | 经典递归，递归思路：当前取第`i`个值，下一个值的取值范围是`[i+1, end)` |
| 41 | First Missing Positive | Array | ★★★★ | 基数排序，数组的长度就可以确定最大值，因此超过该范围的值都可以丢弃 |
| 42 | Trapping Rain Water | Array | ★★★ | 同11，左右边界，谁矮谁往中间靠 |
| 43 | Multiply Strings | String | ★★★ | 无聊 |
| 44 | Wildcard Matching | Dp | ★★★★ | 同10，通配符`*`的边界初始化，注意递推式 |
| 45 | Jump Game II | Greedy | ★★★★★ | 不用关注具体跳到哪个位置，维护3个变量，iter、curFar、curFarest，当`iter<=curFar`时，更新`curFarest` |
| 46 | Permutations | Recursion | ★★★ | 经典递归，记录某个索引是否被使用过 |
| 47 | Permutations II | Recursion | ★★★ | 同46，跳过相同的元素 |
| 48 | Rotate Image | Array | ★★★ | 如何拆分正方形。用两条对角线拆分，这样坐标好计算，更直观 |
| 49 | Group Anagrams | String | ★★★ | 将字符串按字典序排序得到key，然后进行分组 |
| 50 | Pow(x, n) | Numerical |  | 太数学了 |
| 51 | N-Queens | Recursion | ★★★ | 经典递归，横纵、对角线都不能冲突 |
| 52 | N-Queens II | Recursion | ★★★ | 同51 |
| 53 | Maximum Subarray | Array/Dp | ★★★ | dp思路：`dp[i]`表示以`i`作为最后元素的最大和，递推式：`dp[i] = (Math.max(dp[i - 1], 0)) + nums[i - 1]` |
| 54 |  |  |  |  |
| 55 | Jump Game | Greedy | ★★★★★ | 同45 |
| 56 | Merge Intervals | Array | ★★★ | 先按左边界排序，这样就只需要讨论右边界就可以了 |
| 57 | Insert Interval | Array | ★★★ | 同56，就三种情况，左分离、右分离、重合 |
| 58 | Length of Last Word | String | ★ | 毫无意义 |
| 59 |  |  |  |  |
| 60 | Permutation Sequence | Array | ★★★★ | 首先计算出total数组，`total[i]`表示i个整数有多少种排列方式。首位取第几个数？`int index = (k - 1) / total[i - 1]`，将该数从`candidates`中取出，并更新`k -= index * total[i - 1]` |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |
