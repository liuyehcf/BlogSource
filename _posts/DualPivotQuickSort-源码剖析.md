---
title: DualPivotQuickSort 源码剖析
date: 2017-07-25 11:03:45
tags: 原创
categories:
- 算法
- 排序
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

Java中Arrays.sort排序方法对于基本类型的排序采用的是双轴快速排序。本篇博客首先介绍几种快速排序的实现方式，然后再来分析JDK源码

# 2 快排种类

## 2.1 工具类

该工具类仅提供exchange方法

```Java
package org.liuyehcf.sort.quicksort;

/**
 * Created by HCF on 2017/7/25.
 */
public class SortUtils {
    public static void exchange(int[] nums, int i, int j) {
        int temp = nums[i];
        nums[i] = nums[j];
        nums[j] = temp;
    }
}

```

## 2.2 经典快排

下面给出经典快排的源码，包含递归模式和非递归模式

```Java
package org.liuyehcf.sort.quicksort;

import java.util.LinkedList;

import static org.liuyehcf.sort.quicksort.SortUtils.*;

/**
 * Created by HCF on 2017/4/23.
 */

public class QuickSort {
    public static void sortRecursive(int[] nums) {
        sortRecursive(nums, 0, nums.length - 1);
    }

    public static void sort(int[] nums) {
        sortStack(nums, 0, nums.length - 1);
    }

    private static void sortRecursive(int[] nums, int lo, int hi) {
        if (lo < hi) {
            int mid = partition(nums, lo, hi);
            sortRecursive(nums, lo, mid - 1);
            sortRecursive(nums, mid + 1, hi);
        }
    }

    private static void sortStack(int[] nums, int lo, int hi) {
        LinkedList<int[]> stack = new LinkedList<int[]>();

        if (lo < hi) {
            stack.push(new int[]{lo, hi});
        }

        while (!stack.isEmpty()) {
            int[] peek = stack.pop();

            int peekLo = peek[0], peekHi = peek[1];

            int mid = partition(nums, peekLo, peekHi);

            if (peekLo < mid - 1) {
                stack.push(new int[]{peekLo, mid - 1});
            }
            if (mid + 1 < peekHi) {
                stack.push(new int[]{mid + 1, peekHi});
            }
        }
    }

    private static int partition(int[] nums, int lo, int hi) {
        int i = lo - 1;
        int pivot = nums[hi];

        for (int j = lo; j < hi; j++) {
            if (nums[j] < pivot) {
                exchange(nums, ++i, j);
            }
        }

        exchange(nums, ++i, hi);

        return i;
    }
}
```

## 2.3 3-way快排

下面直接给出3-way快排的源码，包括递归模式和非递归模式

partition方法中lt和gt的含义如下

1. lt代表小于pivot的右边界
1. gt代表大于pivot的左边界
1. 因此满足`nums[lo~lt]<pivot nums[lt+1~gt-1]==pivot nums[gt~hi]>pivot`

```Java
package org.liuyehcf.sort.quicksort;

import java.util.LinkedList;

import static org.liuyehcf.sort.quicksort.SortUtils.*;

/**
 * Created by HCF on 2017/7/25.
 */
public class ThreeWayQuickSort {

    public static void sortRecursive(int[] nums) {
        sortRecursive(nums, 0, nums.length - 1);
    }

    public static void sort(int[] nums) {
        sortStack(nums, 0, nums.length - 1);
    }

    private static void sortRecursive(int[] nums, int lo, int hi) {
        if (lo < hi) {
            int[] range = partition(nums, lo, hi);

            sortRecursive(nums, lo, range[0]);

            sortRecursive(nums, range[1], hi);
        }
    }

    private static void sortStack(int[] nums, int lo, int hi) {
        LinkedList<int[]> stack = new LinkedList<int[]>();

        if (lo < hi) {
            stack.push(new int[]{lo, hi});
        }

        while (!stack.isEmpty()) {
            int[] peek = stack.pop();

            int peekLo = peek[0], peekHi = peek[1];

            int[] range = partition(nums, peekLo, peekHi);

            if (peekLo < range[0]) {
                stack.push(new int[]{peekLo, range[0]});
            }
            if (range[1] < peekHi) {
                stack.push(new int[]{range[1], peekHi});
            }
        }
    }

    private static int[] partition(int[] nums, int lo, int hi) {
        int lt = lo - 1;
        int gt = hi + 1;

        int pivot = nums[hi];

        int j = lo;
        while (j < gt) {
            if (nums[j] < pivot) {
                exchange(nums, ++lt, j++);
            } else if (nums[j] > pivot) {
                exchange(nums, --gt, j);
            } else {
                j++;
            }
        }

        return new int[]{lt, gt};
    }
}

```

## 2.4 双轴快排

下面直接给出双轴快排的源码，包括递归模式和非递归模式

其中partition方法中的lt、le、ge、lt含义如下

1. lt代表小于pivot1的右边界
1. le代表等于pivot1的右边界
1. ge代表等于pivot2的左边界
1. gt代表大于pivot2的右边界
1. 因此满足`nums[lo~lt]<pivot1 nums[lt+1~le]==pivot2  pivot1<nums[le+1~ge-1]<pivot2 nums[ge~gt-1]==pivot2 nums[gt~hi]>pivot2`

```Java
package org.liuyehcf.sort.quicksort;

import java.util.Arrays;
import java.util.LinkedList;

import static org.liuyehcf.sort.quicksort.SortUtils.*;

/**
 * Created by HCF on 2017/7/25.
 */
public class DualPivotQuickSort {
    public static void sortRecursive(int[] nums) {
        sortRecursive(nums, 0, nums.length - 1);
    }

    public static void sort(int[] nums) {
        sortStack(nums, 0, nums.length - 1);
    }

    private static void sortRecursive(int[] nums, int lo, int hi) {
        if (lo < hi) {
            int[] range = partition(nums, lo, hi);
            sortRecursive(nums, lo, range[0]);
            sortRecursive(nums, range[1] + 1, range[2] - 1);
            sortRecursive(nums, range[3], hi);
        }
    }

    private static void sortStack(int[] nums, int lo, int hi) {
        LinkedList<int[]> stack = new LinkedList<int[]>();

        if (lo < hi) {
            stack.push(new int[]{lo, hi});
        }

        while (!stack.isEmpty()) {
            int[] peek = stack.pop();

            int peekLo = peek[0];
            int peekHi = peek[1];

            int[] range = partition(nums, peekLo, peekHi);

            if (peekLo < range[0]) {
                stack.push(new int[]{peekLo, range[0]});
            }

            if (range[1] + 1 < range[2] - 1) {
                stack.push(new int[]{range[1] + 1, range[2] - 1});
            }

            if (range[3] < peekHi) {
                stack.push(new int[]{range[3], peekHi});
            }
        }
    }

    private static int[] partition(int[] nums, int lo, int hi) {
        int lt = lo - 1;
        int le = lt;
        int gt = hi + 1;
        int ge = gt;

        int pivot1 = nums[lo];
        int pivot2 = nums[hi];

        if (pivot1 > pivot2) {
            exchange(nums, lo, hi);
            pivot1 = nums[lo];
            pivot2 = nums[hi];
        }

        int j = lo;

        while (j < ge) {
            if (nums[j] == pivot1) {
                exchange(nums, ++le, j++);
            } else if (nums[j] < pivot1) {
                if (le == lt) {
                    ++lt;
                    ++le;
                    exchange(nums, lt, j++);
                } else {
                    exchange(nums, ++lt, j);
                    exchange(nums, ++le, j++);
                }
            } else if (nums[j] == pivot2) {
                exchange(nums, --ge, j);
            } else if (nums[j] > pivot2) {
                if (ge == gt) {
                    --gt;
                    --ge;
                    exchange(nums, gt, j);
                } else {
                    exchange(nums, --gt, j);
                    exchange(nums, --ge, j);
                }
            } else {
                j++;
            }
        }

        return new int[]{lt, le, ge, gt};
    }
}
```

# 3 参考

* [DualPivotQuickSort 双轴快速排序 源码 笔记](http://www.jianshu.com/p/6d26d525bb96)
* [QUICKSORTING - 3-WAY AND DUAL PIVOT](http://rerun.me/2013/06/13/quicksorting-3-way-and-dual-pivot/)
