---
title: Algorithm-Array
date: 2017-07-16 21:14:35
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-11[★★★]

**Container With Most Water**

> Given n non-negative integers a1, a2, ..., an, where each represents a point at coordinate (i, ai). n vertical lines are drawn such that the two endpoints of line i is at (i, ai) and (i, 0). Find two lines, which together with x-axis forms a container, such that the container contains the most water.

```java
public class Solution {
    public int maxArea(int[] height) {
        int left = 0, right = height.length - 1;

        int res = area(height, left, right);

        int leftMaxHeight = height[left];
        int rightMaxHeight = height[right];

        while (left < right) {
            if (leftMaxHeight < rightMaxHeight) {
                left++;

                if (height[left] > leftMaxHeight) {
                    leftMaxHeight = height[left];
                    res = Math.max(res, area(height, left, right));
                }
            } else {
                right--;

                if (height[right] > rightMaxHeight) {
                    rightMaxHeight = height[right];
                    res = Math.max(res, area(height, left, right));
                }
            }
        }

        return res;
    }

    private int area(int[] height, int left, int right) {
        return Math.min(height[left], height[right]) * (right - left);
    }
}
```

# 2 Question-15[★★]

**3Sum**

> Given an array S of n integers, are there elements a, b, c in S such that `a + b + c = 0`? Find all unique triplets in the array which gives the sum of zero.

```java
public class Solution {
    public List<List<Integer>> threeSum(int[] nums) {
        List<List<Integer>> res = new ArrayList<List<Integer>>();

        Arrays.sort(nums);

        for (int i = 0; i < nums.length - 2; i++) {
            if (i > 0 && nums[i] == nums[i - 1]) continue;

            int left = i + 1, right = nums.length - 1;

            while (left < right) {
                if (nums[left] + nums[right] == -nums[i]) {
                    res.add(Arrays.asList(nums[i], nums[left], nums[right]));

                    ++left;
                    --right;

                    while (left < right && nums[left] == nums[left - 1]) left++;

                    while (left < right && nums[right] == nums[right + 1]) right--;
                } else if (nums[left] + nums[right] > -nums[i]) {
                    right--;
                } else {
                    left++;
                }
            }
        }

        return res;
    }
}
```

# 3 Question-31[★★★★★]

**Next Permutation**

> Implement next permutation, which rearranges numbers into the lexicographically next greater permutation of numbers.

> If such arrangement is not possible, it must rearrange it as the lowest possible order (ie, sorted in ascending order).

> The replacement must be in-place, do not allocate extra memory.

二分查找还是需要重点关注一下的，最后返回值的一个判断。另外就是逆序一个子数组，如何取中间，一个很好的办法是判断`left < right`即可，对应本题就是`i < nums.length - 1 - (i - begin)`

```java
public class Solution {
    public void nextPermutation(int[] nums) {
        int i = nums.length - 1;

        while (i >= 1 && nums[i - 1] >= nums[i]) {
            i--;
        }

        if (i == 0) {
            reverse(nums, 0);
            return;
        }

        //需要交换的值
        int val = nums[i - 1];

        //在有序子数组中找出大于val的最小值的位置
        int index = smallestLarger(nums, i, val);

        //交换这两个值
        exchange(nums, i - 1, index);

        //重排序子数组
        reverse(nums, i);
    }

    private int smallestLarger(int[] nums, int left, int target) {
        int right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] > target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        if (left < nums.length && nums[left] > target) return left;
        else return left - 1;
    }

    private void exchange(int[] nums, int i, int j) {
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
    }

    private void reverse(int[] nums, int begin) {
        for (int i = begin; i < nums.length - 1 - (i - begin); i++) {
            exchange(nums, i, nums.length - 1 - (i - begin));
        }
    }
}
```

# 4 Question-42[★★★★★]

**Trapping Rain Water**

> Given n non-negative integers representing an elevation map where the width of each bar is 1, compute how much water it is able to trap after raining.

```java
public class Solution {
    public int trap(int[] height) {
        if (height == null || height.length == 0) return 0;

        int left = 0, right = height.length - 1;

        int leftMost = height[left];
        int rightMost = height[right];

        int res = 0;

        while (left < right) {
            int tmp = 0;
            if (leftMost < rightMost) {
                tmp = height[++left];
                leftMost = Math.max(leftMost, height[left]);
            } else {
                tmp = height[--right];
                rightMost = Math.max(rightMost, height[right]);
            }

            res += Math.max(0, Math.min(leftMost, rightMost) - tmp);
        }

        return res;
    }
}
```

# 5 Question-56[★★★★]

**Merge Intervals**

> Given a collection of intervals, merge all overlapping intervals.

```java
/**
 * Definition for an interval.
 * public class Interval {
 * int start;
 * int end;
 * Interval() { start = 0; end = 0; }
 * Interval(int s, int e) { start = s; end = e; }
 * }
 */
public class Solution {
    public List<Interval> merge(List<Interval> intervals) {
        List<Interval> res = new ArrayList<>();

        if (intervals.isEmpty()) return res;

        Collections.sort(intervals, (obj1, obj2) -> {
            return obj1.start - obj2.start;
        });

        Iterator<Interval> iterator = intervals.iterator();

        Interval pre = iterator.next();

        while (iterator.hasNext()) {
            Interval cur = iterator.next();

            if (pre.end < cur.start) {
                res.add(pre);
                pre = cur;
            } else if (pre.start > cur.end) {
                res.add(cur);
            } else {
                pre.start = Math.min(pre.start, cur.start);
                pre.end = Math.max(pre.end, cur.end);
            }
        }

        res.add(pre);

        return res;
    }
}
```

# 6 Question-75[★★]

**Sort Colors**

> Given an array with n objects colored red, white or blue, sort them so that objects of the same color are adjacent, with the colors in the order red, white and blue.

> Here, we will use the integers 0, 1, and 2 to represent the color red, white, and blue respectively.

```java
class Solution {
    public void sortColors(int[] nums) {
        int[] cnt = new int[3];
        for (int num : nums) {
            cnt[num]++;
        }

        int iter = 0;

        for (int i = 0; i <= 2; i++) {
            while (--cnt[i] >= 0) {
                nums[iter++] = i;
            }
        }
    }
}
```

# 7 Question-76[★★★★★]

**Minimum Window Substring**

> Given a string S and a string T, find the minimum window in S which will contain all the characters in T in complexity O(n).

```java
class Solution {
    public String minWindow(String s, String t) {
        String res = null;

        int[] cnt = new int[128];

        for (char c : t.toCharArray()) {
            cnt[c]++;
        }

        int len = t.length();

        int left = 0, right = 0;
        int[] tmp = new int[128];
        int count = 0;

        while (right < s.length()) {
            char c;
            if (++tmp[c = s.charAt(right++)] <= cnt[c]) {
                count++;
            }

            while (count == len) {
                if (res == null || right - left < res.length()) {
                    res = s.substring(left, right);
                }
                if (--tmp[c = s.charAt(left++)] < cnt[c]) {
                    count--;
                }
            }
        }

        return res == null ? "" : res;

    }
}
```

# 8 Question-130[★★★★★]

**Surrounded Regions**

> Given a 2D board containing 'X' and 'O' (the letter O), capture all regions surrounded by 'X'.

> A region is captured by flipping all 'O's into 'X's in that surrounded region.

```java
public class Solution {
    class Node {
        int row;

        int col;

        Node parent;

        boolean isRegion;

        Node(int row, int col) {
            this.row = row;
            this.col = col;
        }

        Node getRoot() {
            Node n = this;
            while (n.parent != null) {
                n = n.parent;
            }
            return n;
        }

        List<Node> children = new ArrayList<>();

        void addChild(Node child) {
            child.parent = this;
            children.add(child);
        }

        void union(Node root) {
            for (Node child : root.children) {
                addChild(child);
            }
            root.children.clear();
            addChild(root);
            isRegion |= root.isRegion;
        }
    }

    public void solve(char[][] board) {
        int m, n;
        if ((m = board.length) == 0 || (n = board[0].length) == 0) return;

        Node[][] nodes = new Node[m][n];

        Set<Node> set = new HashSet<>();

        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (board[i][j] == 'O') {
                    Node root1 = null, root2 = null;

                    if (j > 0 && board[i][j - 1] == 'O') root1 = nodes[i][j - 1].getRoot();
                    if (i > 0 && board[i - 1][j] == 'O') root2 = nodes[i - 1][j].getRoot();

                    if (root1 != null && root2 != null) {
                        if (root1 != root2) {
                            root1.union(root2);
                            set.remove(root2);
                        }
                        root1.addChild(nodes[i][j] = new Node(i, j));
                    } else if (root1 != null) {
                        root1.addChild(nodes[i][j] = new Node(i, j));
                    } else if (root2 != null) {
                        root2.addChild(nodes[i][j] = new Node(i, j));
                    } else {
                        set.add(nodes[i][j] = new Node(i, j));
                    }

                    if (i == 0 || j == 0 || i == m - 1 || j == n - 1) {
                        nodes[i][j].getRoot().isRegion = true;
                    }
                }
            }
        }

        for (Node root : set) {
            if (!root.isRegion) {
                for (Node child : root.children) {
                    board[child.row][child.col] = 'X';
                }
                board[root.row][root.col] = 'X';
            }
        }
    }
}
```

# 9 Question-134[★★★★★]

**Gas Station**

> There are N gas stations along a circular route, where the amount of gas at station i is gas[i].

> You have a car with an unlimited gas tank and it costs cost[i] of gas to travel from station i to its next station (i+1). You begin the journey with an empty tank at one of the gas stations.

> Return the starting gas station's index if you can travel around the circuit once, otherwise return -1.

```java
public class Solution {
    public int canCompleteCircuit(int[] gas, int[] cost) {
        int remain = 0;
        int start = 0;
        int lack = 0;

        for (int i = 0; i < gas.length; i++) {
            remain -= cost[i];
            remain += gas[i];
            if (remain < 0) {
                lack -= remain;
                remain = 0;
                start = i + 1;
            }
        }

        return remain >= lack ? start : -1;
    }
}
```

# 10 Question-200[★★★★★]

**Number of Islands**

> Given a 2d grid map of '1's (land) and '0's (water), count the number of islands. An island is surrounded by water and is formed by connecting adjacent lands horizontally or vertically. You may assume all four edges of the grid are all surrounded by water.

```java
public class Solution {

    class Node {
        Node parent;

        Node() {
            this.parent = null;
        }

        Node getRoot() {
            Node n = this;
            while (n.parent != null) {
                n = n.parent;
            }
            return n;
        }

        void addChild(Node child) {
            child.parent = this;
        }

        void union(Node root) {
            addChild(root);
        }
    }

    public int numIslands(char[][] grid) {
        int m, n;
        if ((m = grid.length) == 0 || (n = grid[0].length) == 0) return 0;

        Set<Node> set = new HashSet<>();

        Node[][] nodes = new Node[m][n];

        for (int i = 0; i < m; i++) {
            for (int j = 0; j < n; j++) {
                if (grid[i][j] == '1') {
                    Node root1 = null, root2 = null;
                    if (j > 0 && grid[i][j - 1] == '1') root1 = nodes[i][j - 1].getRoot();
                    if (i > 0 && grid[i - 1][j] == '1') root2 = nodes[i - 1][j].getRoot();

                    if (root1 != null && root2 != null) {
                        if (root1 != root2) {
                            root1.union(root2);
                            set.remove(root2);
                        }
                        root1.addChild(nodes[i][j] = new Node());
                    } else if (root1 != null) {
                        nodes[i][j] = new Node();
                        root1.addChild(nodes[i][j] = new Node());
                    } else if (root2 != null) {
                        nodes[i][j] = new Node();
                        root2.addChild(nodes[i][j] = new Node());
                    } else {
                        set.add(nodes[i][j] = new Node());
                    }
                }
            }
        }

        return set.size();

    }
}
```

# 11 Question-209[★★★]

**Minimum Size Subarray Sum**

> Given an array of n positive integers and a positive integer s, find the minimal length of a contiguous subarray of which the sum ≥ s. If there isn't one, return 0 instead.

```java
public class Solution {
    public int minSubArrayLen(int s, int[] nums) {
        int begin = 0, end = 0;
        int sum = 0;
        int maxLen = Integer.MAX_VALUE;

        while (end < nums.length) {
            sum += nums[end];

            while (sum >= s) {
                maxLen = Math.min(maxLen, end - begin + 1);

                sum -= nums[begin++];
            }

            end++;
        }

        return maxLen == Integer.MAX_VALUE ? 0 : maxLen;
    }
}
```

## 11.1 Top K Pair Sums from Two Sorted Arrays

Given two sorted arrays, A and B, create a new array C which contains the sum of each possible pair of elements, one from A and one from B. Your task is to find the top K largest sums in the array C.

* Arrays A and B are sorted in ascending order.
* The size of arrays A and B may differ.
* Array C should consist of sums of pairs formed by taking one element from A and another from B.
* You need to find and return the K largest sums in C.

```cpp
#include <iostream>
#include <queue>
#include <unordered_set>
#include <vector>

std::vector<std::pair<int, int>> k_largest_pairs(std::vector<int>& nums1, std::vector<int>& nums2, int k) {
    std::vector<std::pair<int, int>> top_k;
    if (nums1.empty() || nums2.empty() || k <= 0) return top_k;

    auto comp = [&nums1, &nums2](const std::pair<int, int>& p1, const std::pair<int, int>& p2) {
        return nums1[p1.first] + nums2[p1.second] < nums1[p2.first] + nums2[p2.second];
    };

    struct hash {
        inline std::size_t operator()(const std::pair<int, int>& p) const {
            return std::hash<int>()(p.first) ^ std::hash<int>()(p.second);
        }
    };

    std::priority_queue<std::pair<int, int>, std::vector<std::pair<int, int>>, decltype(comp)> max_heap(comp);
    std::unordered_set<std::pair<int, int>, hash> visited;

    max_heap.push({nums1.size() - 1, nums2.size() - 1});
    visited.insert({nums1.size() - 1, nums2.size() - 1});

    while (!max_heap.empty() && k-- > 0) {
        auto [i, j] = max_heap.top();
        max_heap.pop();

        top_k.emplace_back(nums1[i], nums2[j]);

        if (i > 0 && !visited.count({i - 1, j})) {
            max_heap.push({i - 1, j});
            visited.insert({i - 1, j});
        }

        if (j > 0 && !visited.count({i, j - 1})) {
            max_heap.push({i, j - 1});
            visited.insert({i, j - 1});
        }
    }

    return top_k;
}

int main() {
    std::vector<int> nums1 = {1, 2, 4, 5};
    std::vector<int> nums2 = {2, 3, 6};
    int k = 5;

    auto topk = k_largest_pairs(nums1, nums2, k);

    for (auto& p : topk) {
        std::cout << "(" << p.first << ", " << p.second << ") ";
    }
    std::cout << std::endl;

    return 0;
}
```

<!--

# 12 Question-000[★]

____

> 

```java
```

-->
