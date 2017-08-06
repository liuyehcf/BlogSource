---
title: Algorithm BinarySearch
date: 2017-07-16 21:15:03
tags: 
- 原创
categories: 
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 tips

## 1.1 左右边界的递归

由于数组是有序的，假设是一个递增的序列

* 如果`nums[mid] > target`，只要找到一个能包括target的子集即可，因此下一次迭代的范围就是`[left,mid-1]`
* 如果`nums[mid] < target`，只要找到一个能包括target的子集集合，因此下一次迭代的范围就是`[mid+1,right]`

## 1.2 返回值的讨论

循环条件是`left <= right`，因此循环结束时`left = right + 1`，只需要讨论以下三种情况即可

* `target nums[left] nums[right]`
* `nums[left] target nums[right]`
* `nums[left] nums[right] target`

## 1.3 循环位移的二分查找

共有四题，分别是33、81、153、154

__对于查找给定值__

* 这个给定值可能位于任意一段序列中
* 通过nums[mid]与nums[right]的大小关系来确定mid位于第一段还是第二段序列中，再根据target的值来进行left和right的更新

__查找最值(最大或最小)__

* 这个最值必定位于某一段序列中，因此必须保证[left,right]，要么包含两段序列，要么位于那段存在最值的序列
* 对于153和154而言(最小值)，当`nums[mid] < nums[right]`时，只能`right = mid`，而不能`right = mid - 1`。因为如果执行`right = mid - 1`，可能会使得[left,right]只包含第一段序列，这样的话找到的是第一段的最小值，而非整个的最小值

# 2 Question-4[★★★★]

__Median of Two Sorted Arrays__

> There are two sorted arrays nums1 and nums2 of size m and n respectively.

> Find the median of the two sorted arrays. The overall run time complexity should be `O(log (m+n))`.

```Java
public class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int len = nums1.length + nums2.length;

        return (helper(nums1, 0, nums2, 0, (len + 1) / 2) + helper(nums1, 0, nums2, 0, (len + 2) / 2)) / 2;
    }

    private double helper(int[] nums1, int pos1, int[] nums2, int pos2, int index) {
        if (pos1 == nums1.length) return nums2[pos2 + index - 1];
        else if (pos2 == nums2.length) return nums1[pos1 + index - 1];
        else if (index == 1) return nums1[pos1] < nums2[pos2] ? nums1[pos1] : nums2[pos2];

        int stepForward = index / 2;

        int nextPos1 = pos1 + stepForward - 1;
        int nextPos2 = pos2 + stepForward - 1;

        int val1 = nextPos1 < nums1.length ? nums1[nextPos1] : Integer.MAX_VALUE;
        int val2 = nextPos2 < nums2.length ? nums2[nextPos2] : Integer.MAX_VALUE;

        if (val1 < val2)
            return helper(nums1, nextPos1 + 1, nums2, pos2, index - stepForward);
        else
            return helper(nums1, pos1, nums2, nextPos2 + 1, index - stepForward);
    }
}
```

# 3 Question-33[★★★★★]

__Search in Rotated Sorted Array__

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

```Java
public class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] == target) return mid;
                // 意味着mid位于左半段上
            else if (nums[mid] > nums[right]) {
                // target位于mid左边
                if (target >= nums[left] && target < nums[mid]) {
                    right = mid - 1;
                }
                // target位于mid右边
                else {
                    left = mid + 1;
                }
            }
            // 意味着m位于右半段上，或者[left,right]本身就是有序的
            else {
                // target位于mid右边
                if (target > nums[mid] && target <= nums[right]) {
                    left = mid + 1;
                }
                // target位于mid左边
                else {
                    right = mid - 1;
                }
            }
        }

        return -1;
    }
}
```

# 4 Question-34[★★★]

__Search for a Range__

> Given an array of integers sorted in ascending order, find the starting and ending position of a given target value.

> Your algorithm's runtime complexity must be in the order of `O(log n)`.

> If the target is not found in the array, return `[-1, -1]`.

```Java
public class Solution {
    public int[] searchRange(int[] nums, int target) {
        return new int[]{leftBoundary(nums, target), rightBoundary(nums, target)};
    }

    private int leftBoundary(int[] nums, int target) {
        if (nums == null || nums.length == 0) return -1;

        int left = 0, right = nums.length - 1;

        if (nums[left] > target || nums[right] < target) return -1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] >= target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return nums[left] == target ? left : -1;
    }

    private int rightBoundary(int[] nums, int target) {
        if (nums == null || nums.length == 0) return -1;

        int left = 0, right = nums.length - 1;

        if (nums[left] > target || nums[right] < target) return -1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] <= target) {
                left = mid + 1;
            } else {
                right = mid - 1;
            }
        }

        return nums[right] == target ? right : -1;
    }
}
```

# 5 Question-35[★★★]

__Search Insert Position__

> Given a sorted array and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

```Java
public class Solution {
    public int searchInsert(int[] nums, int target) {
        if (nums.length == 0) return 0;
        if (target < nums[0]) return 0;
        if (target > nums[nums.length - 1]) return nums.length;

        int left = 0, right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);
            if (nums[mid] == target) return mid;
            else if (nums[mid] > target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return left;
    }
}
```

# 6 Question-50[★★]

__`Pow(x, n)`__

> Implement `pow(x, n)`.

```Java
public class Solution {
    public double myPow(double x, int n) {
        if (n == 0) return 1;
        else if (n == 1) return x;
        else if (n == -1) return 1 / x;

        int half = n / 2;

        double temp = myPow(x, half);
        return temp * temp * myPow(x, n - half * 2);
    }
}
```

# 7 Question-74[★★★★★]

__Search a 2D Matrix__

> Write an efficient algorithm that searches for a value in an m x n matrix. This matrix has the following properties:

> * Integers in each row are sorted from left to right.
> * The first integer of each row is greater than the last integer of the previous row.

```Java
public class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        if (matrix.length == 0 || matrix[0].length == 0) return false;

        int top = 0, bottom = matrix.length - 1;

        if (target < matrix[0][0]) return false;

        while (top <= bottom) {
            int mid = top + (bottom - top >> 1);

            if (matrix[mid][0] == target) return true;
            else if (matrix[mid][0] > target) {
                bottom = mid - 1;
            } else {
                top = mid + 1;
            }
        }

        int row = top - 1;

        int left = 0, right = matrix[row].length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            if (matrix[row][mid] == target) return true;
            else if (matrix[row][mid] > target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
        return false;
    }
}
```

以下这种方法的思路是，先往上升row，然后再减col。不可能出现先递减col再递增row然后找到target的情况，因为递减col说明`target < matrix[row][col]`，那么`matrix[row][col] < matrix[row+1][?]`，因此`target < matrix[row+1][?]`。

```Java
public class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        if (matrix.length == 0 || matrix[0].length == 0) return false;

        int m = matrix.length, n = matrix[0].length;
        if (target < matrix[0][0] || target > matrix[m - 1][n - 1]) return false;

        int row = 0, col = n - 1;

        while (row < m && col >= 0) {
            if (target == matrix[row][col]) return true;
            else if (target > matrix[row][col]) {
                row++;
            } else {
                col--;
            }
        }

        return false;
    }
}
```

# 8 Question-81[★★★★★]

__Search in Rotated Sorted Array II__

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

思路：通过`nums[mid]`与`nums[right]`的关系来判断mid位于那一段有序的序列上。如果`nums[mid]>nums[right]`，那么意味着`[left,right]`必然存在两段序列且mid位于左边这段序列上，而`nums[mid]<nums[right]`意味着可能`[left,right]`本身就是有序的，或者存在两端序列且mid位于右边这段

```Java
public class Solution {
    public boolean search(int[] nums, int target) {
        int left = 0, right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);

            // 若找到了，直接返回
            if (nums[mid] == target) return true;
            // mid位于左半段上
            if (nums[mid] > nums[right]) {
                // 此时target位于mid右边
                if (target > nums[mid] || target <= nums[right]) {
                    left = mid + 1;
                }
                // 此时target位于mid左边
                else {
                    right = mid - 1;
                }
            }
            // mid位于右半段上(或者[left,right]本身就是有序的)
            else if (nums[mid] < nums[right]) {
                // 此时target位于mid右边
                if (target > nums[mid] && target <= nums[right]) {
                    left = mid + 1;
                }
                // 此时target位于mid左边
                else {
                    right = mid - 1;
                }
            } else {
                right--;
            }
        }

        return false;
    }
}
```

# 9 Question-153[★★★★★]

__Find Minimum in Rotated Sorted Array__

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

> Find the minimum element.

> You may assume no duplicate exists in the array.

如果一个数组经过了循环位移，那么存在两段单调序列，最小值必然位于第二段单调序列中。二分查找时，必须保证[left,right]包含两个序列，或者位于第二个单调序列中

```Java
public class Solution {
    public int findMin(int[] nums) {
        int left = 0, right = nums.length - 1;

        // 不得不采用left<right作为条件
        while (left < right) {
            int mid = left + (right - left >> 1);

            // 可能会造成[left=mid+1,right]是一个单调区间，但是是右边那个单调区间，没有关系，递归逻辑会向左边移动(即最小值的那一边)
            if (nums[mid] > nums[right]) {
                left = mid + 1;
            } 
            // 若right=mid-1会造成[left,right=mid-1]是一个单调区间，如果是左边的单调区间，则最后会跑到最左边，这样是找不到最小值的，因此，每次迭代后，必须保证[left,right]包含最小值，或者是一个单调区间，但是是右边那个单调区间
            else {
                right = mid;
            }
        }

        int num1 = Integer.MAX_VALUE, num2 = Integer.MAX_VALUE, num3 = Integer.MAX_VALUE;

        // 懒得进行讨论了，反正结果总在这里面
        if (left > 0) num1 = nums[left - 1];
        if (left >= 0 && left < nums.length) num2 = nums[left];
        if (left < nums.length - 1) num3 = nums[left + 1];

        return Math.min(Math.min(num1, num2), num3);
    }
}
```

__变体1：查找最大值__

> 最大值必定位于第一段序列中。二分查找时，必须保证[left,right]包含两个序列，或者位于第一个单调序列中

```Java
...
while (left < right) {
    int mid = left + (right - left >> 1);

    if (nums[mid] > nums[right]) {
        right = mid - 1;
    } 
    else {
        left = mid;
    }
}
...
```

__变体2：递增序列改为递减序列，然后查找最小值__

> 最小值必定位于第一段序列中。二分查找时，必须保证[left,right]包含两段序列，或者位于第一个单调序列中

```Java
...
while (left < right) {
    int mid = left + (right - left >> 1);

    if (nums[mid] > nums[left]) {
        right = mid - 1;
    } 
    else {
        left = mid;
    }
}
...
```

__变体3：递增序列改为递减序列，然后查找最大值__

> 最大值必定位于第二段序列中。二分查找时，必须保证[left,right]包含两端序列，或者位于第二个单调序列中

```Java
...
while (left < right) {
    int mid = left + (right - left >> 1);

    if (nums[mid] > nums[left]) {
        left = mid + 1;
    } 
    else {
        right = mid;
    }
}
...
```

# 10 Question-154[★★★★★]

__Find Minimum in Rotated Sorted Array II__

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

> Find the minimum element.

> The array may contain duplicates.

这题思路与153一样，只是在nums[mid]与nums[right]相等时特殊处理一下，因为此时并不知道mid位于哪一段

```Java
public class Solution {
    public int findMin(int[] nums) {
        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] > nums[right]) {
                left = mid + 1;
            } else if (nums[mid] < nums[right]) {
                right = mid;
            } else {
                right--;
            }
        }

        int num1 = Integer.MAX_VALUE, num2 = Integer.MAX_VALUE, num3 = Integer.MAX_VALUE;

        // 懒得进行讨论了，反正结果总在这里面
        if (left > 0) num1 = nums[left - 1];
        if (left >= 0 && left < nums.length) num2 = nums[left];
        if (left < nums.length - 1) num3 = nums[left + 1];

        return Math.min(Math.min(num1, num2), num3);
    }
}
```

# 11 Question-167[★★]

__Two Sum II - Input array is sorted__

> Given an array of integers that is already sorted in ascending order, find two numbers such that they add up to a specific target number.

> The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2. Please note that your returned answers (both index1 and index2) are not zero-based.

> You may assume that each input would have exactly one solution and you may not use the same element twice.

```Java
public class Solution {
    public int[] twoSum(int[] nums, int target) {
        for (int i = 0; i < nums.length - 1; i++) {
            int j = findTarget(nums, i + 1, target - nums[i]);

            if (j != -1) {
                return new int[]{i + 1, j + 1};
            }
        }

        return null;
    }

    private int findTarget(int[] nums, int left, int target) {
        int right = nums.length - 1;

        while (left <= right) {
            int mid = left + (right - left >> 1);
            if (nums[mid] == target) return mid;
            else if (nums[mid] > target) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }

        return -1;
    }
}
```

# 12 Question-240[★★★]

__Search a 2D Matrix II__

> Write an efficient algorithm that searches for a value in an m x n matrix. This matrix has the following properties:

> 1. Integers in each row are sorted in ascending from left to right.
> 1. Integers in each column are sorted in ascending from top to bottom.

```Java
public class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        if (matrix.length == 0) return false;
        int m = matrix.length;

        if (matrix[0].length == 0) return false;
        int n = matrix[0].length;

        if (target < matrix[0][0] || target > matrix[m - 1][n - 1]) return false;

        int row = 0, col = n - 1;

        while (row < m && col >= 0) {
            if (matrix[row][col] == target) return true;
            else if (matrix[row][col] > target) {
                col--;
            } else {
                row++;
            }
        }

        return false;
    }
}
```

<!--

# 13 Question-000[★]

____

> 

```Java
```

-->
