---
title: LC
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
| 28 | Implement strStr() | Array | ★★★★★ | KMP算法 |
| 29 | ~~Divide Two Integers~~ | \ | \ | 垃圾题目 |
| 30 | Substring with Concatenation of All Words | String | ★★★★★ | 无思路 |
| 31 | Next Permutation | Array | ★★★ | 从右往左找逆序对（先高位循环，再低位循环，都是递减），然后以此为边界进行排序即可，若未找到，排序整个数组即可 |
| 32 | Longest Valid Parentheses | Stack | ★★★★★ | 同20（进栈逻辑略有不同），当遍历结束后，栈中存的是无法匹配的索引，但是两两之间是匹配的，需要依次出栈然后计算长度并取最大值。也可以用dp，`dp[i]`表示的是以`s[i-1]`为结尾的最大有效括号的长度 |
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
| 48 | Rotate Image | Array | ★★★ | 以正方形为操作单元，从外层到内层依次旋转，每层计算时，通过`boundary`和`offset`计算坐标点 |
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
| 61 | Rotate List | LinkList | ★★★ | 循环位移等价于3次反转。注意，左半部分反转会导致边界更新；找到left head/tail和right head/tail |
| 62 | Unique Paths | Dp | ★★ | 经典dp，递推式：`dp[i][j] = dp[i - 1][j] + dp[i][j - 1`，注意边界初始化 |
| 63 | Unique Paths II | Dp | ★★ | 同62，经典dp，注意有障碍物的位置直接将`dp[i][j]`设置为0，边界初始化也是如此 |
| 64 | Minimum Path Sum | Dp | ★★ | 经典dp，递推式：`dp[i][j] = Math.min(dp[i - 1][j], dp[i][j - 1]) + grid[i][j]` |
| 65 | ~~Valid Number~~ | \ | \ | 垃圾题目 |
| 66 | Plus One | Numerical | ★ | 处理好进位就行 |
| 67 | Add Binary | Numerical | ★ | 二进制加法，处理好进位就行 |
| 68 |  |  |  |  |
| 69 | Sqrt(x) | Numerical |  | 没啥意思 |
| 70 | Climbing Stairs | Dp | ★★ | 经典dp，递推式：`dp[i] = dp[i - 1] + dp[i - 2]` |
| 71 |  |  |  |  |
| 72 | Edit Distance | Dp | ★★★★ | 经典dp，若c1==c2，`dp[i][j] = Math.min(dp[i - 1][j - 1], dp[i][j - 1] + 1, dp[i - 1][j] + 1)`；若c1!=c2，`dp[i][j] = Math.min(dp[i - 1][j - 1] + 1, dp[i][j - 1] + 1, dp[i - 1][j] + 1)` |
| 73 | Set Matrix Zeroes | Array | ★★ | 先记录下为0的row和col，然后最后把这些row和col置为0 |
| 74 |  |  |  |  |
| 75 | Sort Colors | Array | ★★ | 基数排序的思路，统计0、1、2的次数，然后填充原数组即可 |
| 76 | Minimum Window Substring | String | ★★★★ | 移动窗口。首先统计子串中各个字符的数量，当有效长度等于各字符数量之和时，保留子串，并调整左边界，使得有效长度小于各字符数量之和 |
| 77 | Combinations | Recursion | ★★★ | 经典递归，n个元素中取k个元素的取法，由于不同排列算一种，因此可以按递增的顺序取，且不需要isUsed作为辅助 |
| 78 | Subsets | Recursion | ★★★ | 经典递归，无递归终止条件，任何一种状态都是一个解 |
| 79 | Word Search | Recursion | ★★★ | 经典递归，每一个位置都可以是一个单词的起始位置 |
| 80 | Remove Duplicates from Sorted Array II | Array | ★★★ | 判断相同只能向后找，因为前面的部分已经重新赋值了 |
| 81 | Search in Rotated Sorted Array II | BinarySearch | ★★★★ | 同33，要用`[mid, right]`这个区间来判断单调性，因为在`left < right`这个循环条件下，`mid`不可能等于`right`，省去多余讨论 |
| 82 | Remove Duplicates from Sorted List II | LinkList | ★★★ | pre在去重时无须更新 |
| 83 | Remove Duplicates from Sorted List | LinkList | ★★★ | 同82，无须pre，更简单一些 |
| 84 | Largest Rectangle in Histogram | Stack | ★★★★★ | 尝试将每个索引入栈，入栈前检查高度是否严格递增，若当前高度小于或等于栈顶索引对应的高度，那么计算栈顶高度对应的面积，并将其出栈，直至当前高度为栈中的最高高度 |
| 85 | Maximal Rectangle | Stack | ★★★★★ | 同84 |
| 86 | Partition List | LinkList | ★★★ | 用两个链表分别接收两部分节点，然后再拼起来就可以了 |
| 87 |  |  |  |  |
| 88 | Merge Sorted Array | ArrayList | ★★ | 由于nums1要放两个数组的所有元素，因此首先要把nums1中原始的元素放到最后面，然后再开始合并，这样不会撞车 |
| 89 | Gray Code |  |  |  |
| 90 | Subsets II | Recursion | ★★★★ | 同78，去重即可，对于某一次递归而言，不添加相同的元素即可去重。且过程中任何一个状态都在结果集中 |
| 91 | Decode Ways | Dp | ★★★★ | 若`s[i-1,i]`可以解码，那么`dp[i] += dp[i - 1]`；若`s[i-2,i]`可以解码，那么`dp[i]+=dp[i-2]` |
| 92 | Reverse Linked List II | LinkList | ★★★ | 找到pseudoHead以及tail，然后再reverse即可 |
| 93 | Restore IP Addresses | Recursion | ★★★ | 经典递归，分别尝试1位、2位、3位，注意递归结束的条件：总共解析出4个数，且没有剩余字符 |
| 94 | Binary Tree Inorder Traversal | Tree/Stack | ★★★ | 中序遍历，栈式，需要cur以及栈，根节点赋值给cur，不入栈 |
| 95 | Unique Binary Search Trees II | Tree/Dp | ★★★★ | `dp[i][j]`表示由数字(i, i+1, ..., j)可以构成的所有二叉树。最外层的循环是步长 |
| 96 | Unique Binary Search Trees | Tree/Dp | ★★★★ | 同95，`dp[i][j]`表示由数字(i, i+1, ..., j)可以构成的所有二叉树的数量 |
| 97 | Interleaving String | Recursion | ★★★ | 经典dp，第一级循环是总长度；经典递归，若`s1[i1] == s3[i3]`，那么尝试继续匹配；若`s2[i2] == s3[i3]`，那么尝试继续匹配，否则匹配失败 |
| 98 | Validate Binary Search Tree | Tree/Recursion | ★★ | 递归的时候，传入取值范围，最开始的范围是`[Long.MIN_VALUE, Long.MAX_VALUE]` |
| 99 | Recover Binary Search Tree | Tree/Stack | ★★★★ | 在中序遍历的过程中，找到不满足约束的节点。不满足约束的位置可能有1个（两个异常节点在中序遍历中相邻），也可能有2个（两个异常节点在中序遍历中不相邻） |
| 100 | Same Tree | Tree/Recursion | ★ | 最简单的递归，不解释了 |
| 101 | Symmetric Tree | Tree/Recursion | ★★ | 同100 |
| 102 | Binary Tree Level Order Traversal | Tree/Queue | ★★★ | 经典层序遍历，用队列，每次处理一层 |
| 103 | Binary Tree Zigzag Level Order Traversal | Tree/Queue | ★★ | 同102，每层数值的收集逻辑反转一下，即加入到尾部还是插入到头部 |
| 104 | Maximum Depth of Binary Tree | Tree/Recursion | ★★ | 简单递归思路，注意叶节点的判断逻辑 |
| 105 | Construct Binary Tree from Preorder and Inorder Traversal | Tree/Recursion | ★★★ | 存下每个元素在中序遍历中的位置，这样可以知道左右子树的长度，找到左右子树在前序遍历和中序遍历的边界，并继续递归 |
| 106 | Construct Binary Tree from Inorder and Postorder Traversal | Tree/Recursion | ★★★ | 同106，存下每个元素在中序遍历中的位置，这样可以知道左右子树的长度，找到左右子树在后续遍历和中序遍历的边界，并继续递归 |
| 107 | Binary Tree Level Order Traversal II | Tree/Queue | ★★ | 同102 |
| 108 | Convert Sorted Array to Binary Search Tree | Tree/Recursion | ★★ | 递归即可，每次递归，中间的元素作为根 |
| 109 | Convert Sorted List to Binary Search Tree | Tree/Recursion/LinkList | ★★ | 同108，取中点的逻辑需要用两个指针来完成，即slowIter以及fastIter |
| 110 | Balanced Binary Tree | Tree/Recursion | ★★ | 递归即可，每次递归时比较当前节点是否平衡，并向上返回深度 |
| 111 | Minimum Depth of Binary Tree | Tree/Recursion | ★★ | 同104 |
| 112 | Path Sum | Tree/Recursion | ★★ | 递归即可，递归时将路径和传递下去 |
| 113 | Path Sum II | Tree/Recursion | ★★ | 递归即可，递归时将solution和路径和传递下去，当路径和等于target时，将solution拷贝后添加到res中 |
| 114 | Flatten Binary Tree to Linked List | Tree/Recursion | ★★ | 递归即可，递归时将左子树插入到当前节点和右孩子中间 |
| 115 | Distinct Subsequences | Dp | ★★★★ | 想不到用dp。当`s[i]==t[j]`时，`dp[i][j] = dp[i - 1][j - 1] + dp[i - 1][j]`；当`s[i]!=t[j]`时，`dp[i][j] = dp[i - 1][j]` |
| 116 | Populating Next Right Pointers in Each Node | Tree/Queue | ★★ | 经典层序遍历，用队列，每次处理一层 |
| 117 | Populating Next Right Pointers in Each Node II | Tree/Queue | ★★ | 同116 |
| 118 | Pascal's Triangle | Array | ★ | 太简单了，略 |
| 119 | Pascal's Triangle II | Array | ★ | 同118 |
| 120 | Triangle | Array | ★★ | 依次计算每一层的最小路径和即可 |
| 121 | Best Time to Buy and Sell Stock | Array | ★★ | 遍历一遍，更新buyPrice以及sellPrice即可 |
| 122 | Best Time to Buy and Sell Stock II | Array | ★★★★ | 遍历一遍，如果今天的价格比昨天高，就交易一次 |
| 123 | Best Time to Buy and Sell Stock III | Array | ★★★★ | 思路同121，更新buyPrice1、sellPrice1、buyPrice2、sellPrice2即可 |
| 124 | Binary Tree Maximum Path Sum | Tree/Recursion | ★★★★ | 递归方法返回的是当前节点到叶节点的最大和，同时维护最大路径，可能是：左子树路径和+当前节点+右子树路径和、左（右）子树路径和+当前节点、当前节点 |
| 125 | Valid Palindrome | String | ★ | 首先将非法字符过滤掉，然后转成小写，再判断是否对称 |
| 126 | Word Ladder II | BFS/Recursion | ★★★★★ | 首先计算出所有单词的neighbor（仅有一个字符不同），利用单元最短路径的算法依次计算出每个单词与起始单词的距离。然后从目标单词往前，用递归收集所有可能的组合 |
| 127 | Word Ladder | BFS | ★★★★★ | 同126 |
| 128 | Longest Consecutive Sequence | Array | ★★★★★ | 首先将所有数字添加到set中，再循环，找到最长的连续片段，找的过程中将数字remove出来，避免重复计算。此外O(N)复杂度的那个算法看不懂 |
| 129 | Sum Root to Leaf Numbers | Tree/Recursion | ★★★ | 经典递归，抵达叶节点时，计算List中对应的数字 |
| 130 | Surrounded Regions | Array/Recursion | ★★★★ | 先从边界上，递归将未被包围的`O`改成`1`，然后将剩下的`O`改成`X`，再将`1`改回`O` |
| 131 | Palindrome Partitioning | String/Recursion | ★★★ | 经典递归，递归时，`end from start to len-1`，若子串是对称的，则继续递归 |
| 132 | Palindrome Partitioning II | String/Dp | ★★★★★ |  |
| 133 | Clone Graph | Recursion | ★★★ | 维护老节点和新节点的映射关系，当克隆节点已存在时，从映射关系中取，否则新建 |
| 134 | Gas Station | Array | ★★★★ | 从第一个加油站出发，维护剩余油量以及欠的油量。当剩余油量够用时，只需要更新剩余油量，当剩余油量不足时，更新欠的油量，并且出发地从下一个站点开始。遍历结束后，查看剩余油量和欠的油量，若剩余油量大于欠的油量，那么可以走完；否则不行 |
| 135 | Candy | Array | ★★★★ | 1. 从左向右维护关系；2. 再从右向左维护关系，若期间有增发糖果，那么不断循环步骤1和2 |
| 136 | Single Number | Array | ★★★★ | 异或 |
| 137 | Single Number II | Array | ★★★★ |  |
| 138 | Copy List with Random Pointer | LinkList/Recursion | ★★★ | 同133，random属性在递归结束后再维护即可 |
| 139 | Word Break | Dp | ★★★ | `dp[i]`表示`s[1...i]`是否可以拆分 |
| 140 | Word Break II | Recursion | ★★★ | 普通递归思路，从start开始，遍历每个word，看当前子串是否与word相同，若相同则继续递归 |
| 141 | Linked List Cycle | LinkList | ★★ | 一个fast指针，一个slow指针，若flow==slow那么说明存在循环 |
| 142 | Linked List Cycle II | LinkList | ★★★ | 同样一个fast指针，一个slow指针。假设`k`步骤后相遇，那么`2k - k = nr`，其中`r`是循环部分的长度，`n`可能是任意非零整数。假设非循环部分的长度是`s1`，循环起始到相遇点部分的长度是`s2`，相遇点经循环到达循环起始点的长度是`s3`，那么slow指针走过的路程就是`s1 + n1r + s2`、fast指针走过的路程就是`s1 + n2r +s2`，于是可以得到`2 * (s1 + n1r + s2) = s1 + n2r +s2`，即`s1 + s2 = (n2 - 2n1)r`。而`s2 + s3 = r`，可以推导出`s1 = s3 + (n2 - 2n1 -1)r`。此时用两个slow指针，一个在起始位置，一个在相遇点，它们最终会在循环起始点碰头 |
| 143 | Reorder List | LinkList | ★★★★ | 找到中点（`fast != null && fast.next != null`，若把条件不成立时的slow当成中点，那么slow要么是中间那个，要么是第二段第一个元素），把后面部分逆序，然后前后两段交替合并即可 |
| 144 | Binary Tree Preorder Traversal | Tree/Stack/Recursion | ★★★ | 前序遍历，经典题 |
| 145 | Binary Tree Postorder Traversal | Tree/Stack/Recursion | ★★★ | 后续遍历，经典题。两种栈式：一种可以理解成先当前节点，再右子树再左子树的逆向操作，这样就与前序、中序遍历的逻辑对称了；另一种需要维护pre，当pre是当前节点的孩子时，说明当前节点可以访问 |
| 146 | LRU Cache | LinkList | ★★★ | 一个map和一个双向链表，注意用两个额外的节点当作为head和tail，避免讨论 |
| 147 | Insertion Sort List | LinkList | ★★★ | 链表的插入排序 |
| 148 | Sort List | LinkList | ★★★★ | 链表的归并排序。找到中点（`fast.next != null && fast.next.next != null`，若把条件不成立时的slow当成中点，那么slow要么是中间那个，要么是第一段最后一个元素） |
| 149 |  |  |  |  |
| 150 | Evaluate Reverse Polish Notation | Stack | ★★★ | 逆波兰式，遍历token序列，遇到数值就压入栈，遇到运算符就计算，并将结果压入栈 |
| 151 | Reverse Words in a String | String | ★★ | 挨个扫描，过滤非法字符即可 |
| 152 | Maximum Product Subarray | Dp | ★★★ | 负负可以得正，分别维护以i结尾的子序列的最大值和最小值 |
| 153 | Find Minimum in Rotated Sorted Array | BinarySearch | ★★★★ | 用mid和left和right的大小关系，来判断左右哪个部分是有序的 |
| 154 | Find Minimum in Rotated Sorted Array II | BinarySearch | ★★★★ | 思路同153，由于存在重复元素，当无法判断时，边界减一 |
| 155 | Min Stack | Stack | ★★★ | 栈中的节点维护两个属性：本身的值和以该节点为栈顶元素时的最小值 |
| 156 |  |  |  |  |
| 157 |  |  |  |  |
| 158 |  |  |  |  |
| 159 |  |  |  |  |
| 160 | Intersection of Two Linked Lists | LinkList | ★★ | 先计算两个链的长度，较长的那个链先移动iter，等长后，两个iter同时前进，然后找到相同的节点即可 |
| 161 |  |  |  |  |
| 162 | Find Peak Element | BinarySearch | ★★★★★ | 维护不变性约束：`nums[left-1] < nums[left] && nums[right] > nums[right+1]`，比较`nums[mid]`和`nums[mid+1]`的大小关系。若两者相等，则从`[left, right]`找到一组相邻且不等并比较大小关系，继续缩减搜索范围 |
| 163 |  |  |  |  |
| 164 | Maximum Gap | Bucket | ★★★★★ | 首先，找出最大值和最小值。桶的个数是数组的大小，桶的步长是差值除以桶的个数。初始化两个桶，最大桶和最小桶。然后遍历每个元素，维护最大桶和最小桶，入桶时维护最大差值。最后，两个相邻桶之间的差值也要考虑在内 |
| 165 | Compare Version Numbers | String | ★★ | 挺无聊的题目 |
| 166 | Fraction to Recurring Decimal | Numerical | ★★★ | 纯数学题，无限循环小数的表示 |
| 167 | Two Sum II - Input array is sorted | Numerical | ★ | 左右两个索引，按照比较结果将left右移或者左移即可 |
| 168 | Excel Sheet Column Title | Numerical | ★★★ | 字母可以看成是26进制，但是是从1开始的26进制，因此每次计算余数前需要先把数值-1 |
| 169 | Majority Element | Array | ★★★ | majority记录当前出现次数最多的值，cnt记录次数。遍历数组，若当前值不等于majority，减小cnt，若cnt减值0，那么更新majority和cnt；若当前值等于majority，递增cnt |
| 170 |  |  |  |  |
| 171 | Excel Sheet Column Number | Numerical | ★★★ | 168的反向逻辑。每次追加的时候要加上1 |
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
