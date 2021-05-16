---
title: Algorithm-BinarySearch
date: 2017-07-16 21:15:03
tags: 
- 原创
categories: 
- Job
- Leetcode
---

**阅读更多**

<!--more-->

# 1 tips

## 1.1 左右边界的递归

循环条件是`while(left < right)`，递增必然是`left = mid +1`与`right = mid`，这是定死的，否则对于`left = right -1`时，`left < right`将会永远成立

## 1.2 返回值的讨论

循环条件是`left < right`，因此循环结束时`left == right`，只需要讨论以下三种情况即可

* `nums[left] < target`
* `nums[left] == target`
* `nums[left] > target`

## 1.3 循环位移的二分查找

共有四题，分别是33、81、153、154

**对于查找给定值**

* 这个给定值可能位于任意一段序列中
* 通过nums[mid]与nums[right]的大小关系来确定mid位于第一段还是第二段序列中，再根据target的值来进行left和right的更新

**查找最值(最大或最小)**

* 这个最值必定位于某一段序列中，因此必须保证[left,right]，要么包含两段序列，要么位于那段存在最值的序列
* 对于153和154而言(最小值)，当`nums[mid] < nums[right]`时，只能`right = mid`，而不能`right = mid - 1`。因为如果执行`right = mid - 1`，可能会使得[left,right]只包含第一段序列，这样的话找到的是第一段的最小值，而非整个的最小值

# 2 Question-4[★★★★]

**Median of Two Sorted Arrays**

> There are two sorted arrays nums1 and nums2 of size m and n respectively.

> Find the median of the two sorted arrays. The overall run time complexity should be `O(log (m+n))`.

```java
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

还有一个非常简单的思路，与合并两个有序数组是一样的

```java
class Solution {
    public double findMedianSortedArrays(int[] nums1, int[] nums2) {
        int totalLength = nums1.length + nums2.length;
        int mid1Index = totalLength - 1 >> 1;
        int mid2Index = totalLength >> 1;

        int iter1 = 0, iter2 = 0;
        int cnt = 0;
        int curVal;
        int mid1 = 0, mid2 = 0;
        while (iter1 < nums1.length && iter2 < nums2.length) {
            if (nums1[iter1] <= nums2[iter2]) {
                curVal = nums1[iter1++];
            } else {
                curVal = nums2[iter2++];
            }

            if (cnt == mid1Index) {
                mid1 = curVal;
            }
            if (cnt == mid2Index) {
                mid2 = curVal;
            }

            cnt++;
        }

        while (iter1 < nums1.length) {
            curVal = nums1[iter1++];

            if (cnt == mid1Index) {
                mid1 = curVal;
            }
            if (cnt == mid2Index) {
                mid2 = curVal;
            }

            cnt++;
        }

        while (iter2 < nums2.length) {
            curVal = nums2[iter2++];

            if (cnt == mid1Index) {
                mid1 = curVal;
            }
            if (cnt == mid2Index) {
                mid2 = curVal;
            }

            cnt++;
        }

        return 1.0d * (mid1 + mid2) / 2;
    }
}
```

# 3 Question-33[★★★★★]

**Search in Rotated Sorted Array**

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

**分类讨论条件**

> 由于循环条件是`left < right`，当`right = left + 1`时，`left == mid`，而`mid < right`一定成立，为了避免讨论特殊情况，可以用`nums[mid]`与`nums[right]`的大小关系作为分类条件

**版本1（需要讨论特殊情况，即left==mid）**

```java
class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] == target) {
                return mid;
            }
            // [left, mid] 这个区间是有序的
            // 等号一定要在这，因为，若mid==left时，一定要取右半边
            else if (nums[mid] >= nums[left]) {
                if (nums[left] <= target && target < nums[mid]) {
                    right = mid;
                } else {
                    left = mid + 1;
                }
            }
            // [left, mid] 这个区间是无序的，那么[mid, right]就一定是有序的
            else {
                if (nums[mid] < target && target <= nums[right]) {
                    left = mid + 1;
                } else {
                    right = mid;
                }
            }
        }

        return nums[left] == target ? left : -1;
    }
}
```

**版本2（无须讨论特殊情况）**

```java
class Solution {
    public int search(int[] nums, int target) {
        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] == target) {
                return mid;
            }
            // [mid, right] 这个区间是有序的
            else if (nums[mid] < nums[right]) {
                if (nums[mid] < target && target <= nums[right]) {
                    left = mid + 1;
                } else {
                    right = mid;
                }
            }
            // [mid, right] 这个区间是无序的，那么[left, mid]就一定是有序的
            else {
                if (nums[left] <= target && target < nums[mid]) {
                    right = mid;
                } else {
                    left = mid + 1;
                }
            }
        }

        return nums[left] == target ? left : -1;
    }
}
```

# 4 Question-34[★★★]

**Search for a Range**

> Given an array of integers sorted in ascending order, find the starting and ending position of a given target value.

> Your algorithm's runtime complexity must be in the order of `O(log n)`.

> If the target is not found in the array, return `[-1, -1]`.

```java
public class Solution {
    public int[] searchRange(int[] nums, int target) {
        return new int[]{leftBoundary(nums, target), rightBoundary(nums, target)};
    }

    private int leftBoundary(int[] nums, int target) {
        if (nums == null || nums.length == 0) return -1;

        int left = 0, right = nums.length - 1;

        if (nums[left] > target || nums[right] < target) return -1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] >= target) {
                right = mid;
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

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] <= target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return nums[left] == target ? left :
                left - 1 >= 0 && nums[left - 1] == target ? left - 1 : -1;
    }
}
```

# 5 Question-35[★★★]

**Search Insert Position**

> Given a sorted array and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.

```java
public class Solution {
    public int searchInsert(int[] nums, int target) {
        if (nums.length == 0) return 0;
        if (target < nums[0]) return 0;
        if (target > nums[nums.length - 1]) return nums.length;

        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);
            if (nums[mid] == target) return mid;
            else if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return left;
    }
}
```

# 6 Question-50[★★]

**`Pow(x, n)`**

> Implement `pow(x, n)`.

```java
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

**Search a 2D Matrix**

> Write an efficient algorithm that searches for a value in an m x n matrix. This matrix has the following properties:

> * Integers in each row are sorted from left to right.
> * The first integer of each row is greater than the last integer of the previous row.

```java
public class Solution {
    public boolean searchMatrix(int[][] matrix, int target) {
        if (matrix.length == 0 || matrix[0].length == 0) return false;

        int top = 0, bottom = matrix.length - 1;

        if (target < matrix[0][0]) return false;

        while (top < bottom) {
            int mid = top + (bottom - top >> 1);

            if (matrix[mid][0] == target) return true;
            else if (matrix[mid][0] < target) {
                top = mid + 1;
            } else {
                bottom = mid;
            }
        }

        int row = matrix[top][0] > target ? top - 1 : top;

        int left = 0, right = matrix[row].length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (matrix[row][mid] == target) return true;
            else if (matrix[row][mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        return matrix[row][left] == target;
    }
}
```

以下这种方法的思路是，先往上升row，然后再减col。不可能出现先递减col再递增row然后找到target的情况，因为递减col说明`target < matrix[row][col]`，那么`matrix[row][col] < matrix[row+1][?]`，因此`target < matrix[row+1][?]`

```java
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

**Search in Rotated Sorted Array II**

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

思路：通过`nums[mid]`与`nums[right]`的关系来判断mid位于那一段有序的序列上。如果`nums[mid]>nums[right]`，那么意味着`[left,right]`必然存在两段序列且mid位于左边这段序列上，而`nums[mid]<nums[right]`意味着可能`[left,right]`本身就是有序的，或者存在两端序列且mid位于右边这段

**分类讨论条件**

> 由于循环条件是`left < right`，当`right = left + 1`时，`left == mid`，而`mid < right`一定成立，为了避免讨论特殊情况，可以用`nums[mid]`与`nums[right]`的大小关系作为分类条件

```java
public class Solution {
    public boolean search(int[] nums, int target) {
        if (nums == null || nums.length == 0) return false;

        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            if (nums[mid] == target) {
                return true;
            }
            // [mid, right] 是有序的
            else if (nums[mid] < nums[right]) {
                if (nums[mid] < target && target <= nums[right]) {
                    left = mid + 1;
                } else {
                    right = mid;
                }
            }
            // [mid, right] 是无序的，因此[left, mid]一定是有序的
            else if (nums[mid] > nums[right]) {
                if (nums[left] <= target && target < nums[mid]) {
                    right = mid;
                } else {
                    left = mid + 1;
                }
            }
            // 无法判断
            else {
                right--;
            }
        }

        return nums[left] == target;
    }
}
```

# 9 Question-153[★★★★★]

**Find Minimum in Rotated Sorted Array**

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

> Find the minimum element.

> You may assume no duplicate exists in the array.

**分类讨论条件**

> 由于循环条件是`left < right`，当`right = left + 1`时，`left == mid`，而`mid < right`一定成立，为了避免讨论特殊情况，可以用`nums[mid]`与`nums[right]`的大小关系作为分类条件

```java
class Solution {
    public int findMin(int[] nums) {
        int left = 0, right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            // [mid, right]是有序的
            if (nums[mid] < nums[right]) {
                // 即便mid是最小值，仍然包含在[left, mid]中
                right = mid;
            }
            // [mid, right]是无序的
            else {
                // [mid, right]中的最小值一定小于nums[left]，因此最小值一定包含在[mid + 1, right]中
                left = mid + 1;
            }
        }

        return nums[left];
    }
}
```

# 10 Question-154[★★★★★]

**Find Minimum in Rotated Sorted Array II**

> Suppose an array sorted in ascending order is rotated at some pivot unknown to you beforehand.

> Find the minimum element.

> The array may contain duplicates.

这题思路与153一样，只是在nums[mid]与nums[right]相等时特殊处理一下，因为此时并不知道mid位于哪一段

```java
class Solution {
    public int findMin(int[] nums) {
        int left = 0;
        int right = nums.length - 1;

        while (left < right) {
            int mid = left + (right - left >> 1);

            // [mid, right]是有序的
            if (nums[mid] < nums[right]) {
                // 即便mid是最小值，仍然会包含在[left, mid]中
                right = mid;
            } else if (nums[mid] > nums[right]) {
                // [mid, right]是无序的，最小值一定包含在[mid+1, right]中
                left = mid + 1;
            } else {
                // 只能right--，比如[1,3,3],left=0, right=2, mid=1
                right--;
            }
        }

        return nums[left];
    }
}
```

# 11 Question-167[★★]

**Two Sum II - Input array is sorted**

> Given an array of integers that is already sorted in ascending order, find two numbers such that they add up to a specific target number.

> The function twoSum should return indices of the two numbers such that they add up to the target, where index1 must be less than index2. Please note that your returned answers (both index1 and index2) are not zero-based.

> You may assume that each input would have exactly one solution and you may not use the same element twice.

```java
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

        while (left < right) {
            int mid = left + (right - left >> 1);
            if (nums[mid] == target) return mid;
            else if (nums[mid] < target) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }

        return nums[left] == target ? left : -1;
    }
}
```

# 12 Question-240[★★★]

**Search a 2D Matrix II**

> Write an efficient algorithm that searches for a value in an m x n matrix. This matrix has the following properties:

> 1. Integers in each row are sorted in ascending from left to right.
> 1. Integers in each column are sorted in ascending from top to bottom.

```java
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

```java
```

-->
