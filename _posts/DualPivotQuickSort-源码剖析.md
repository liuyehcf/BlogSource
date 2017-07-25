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

# 3 常量

```Java
    /**
     * The maximum number of runs in merge sort.
     */
    private static final int MAX_RUN_COUNT = 67;

    /**
     * The maximum length of run in merge sort.
     */
    private static final int MAX_RUN_LENGTH = 33;

    /**
     * If the length of an array to be sorted is less than this
     * constant, Quicksort is used in preference to merge sort.
     */
    private static final int QUICKSORT_THRESHOLD = 286;

    /**
     * If the length of an array to be sorted is less than this
     * constant, insertion sort is used in preference to Quicksort.
     */
    private static final int INSERTION_SORT_THRESHOLD = 47;

    /**
     * If the length of a byte array to be sorted is greater than this
     * constant, counting sort is used in preference to insertion sort.
     */
    private static final int COUNTING_SORT_THRESHOLD_FOR_BYTE = 29;

    /**
     * If the length of a short or char array to be sorted is greater
     * than this constant, counting sort is used in preference to Quicksort.
     */
    private static final int COUNTING_SORT_THRESHOLD_FOR_SHORT_OR_CHAR = 3200;
```

* __`MAX_RUN_COUNT`__：run数量的最大值，如果超过这个值，那么便认为数组不是特别的有序
* __`MAX_RUN_LENGTH`__：run长度的最大值
* __`QUICKSORT_THRESHOLD`__：如果数组长度小于这个值，那么快排的效率会比归并排序的效率要高
* __`INSERTION_SORT_THRESHOLD`__：如果数组长度小于这个值，那么插入排序的效率会比快排的效率要高
* __`COUNTING_SORT_THRESHOLD_FOR_BYTE`__：对于字节数组而言，如果长度大于这个数值，那么用计数排序效率比较高，因为额外的内存空间是确定的，256
* __`COUNTING_SORT_THRESHOLD_FOR_SHORT_OR_CHAR`__：对于char或者short而言，如果数组长度大于这个数值，那么计数排序效率会比较高

> 从这几个常量就能清晰地看出，DualPivotQuickSort对于不同的基本类型的排序方式是不同的，对于short、char以及byte等16bit或者8bit的基本类型而言，计数排序不会造成特别大的空间开销。而对于其他基本类型，比如int，long，float，double等。则会根据数组的长度来选择相应的排序算法，包括插入排序、快速排序和归并排序

# 4 方法

## 4.1 sort

参数说明

* a：待排序的数组
* left：左边界，闭区间
* right：右边界，闭区间
* work：
* workBase：
* workLen

```Java
    /**
     * Sorts the specified range of the array using the given
     * workspace array slice if possible for merging
     *
     * @param a the array to be sorted
     * @param left the index of the first element, inclusive, to be sorted
     * @param right the index of the last element, inclusive, to be sorted
     * @param work a workspace array (slice)
     * @param workBase origin of usable space in work array
     * @param workLen usable size of work array
     */
    static void sort(int[] a, int left, int right,
                     int[] work, int workBase, int workLen) {
        // Use Quicksort on small arrays
        // 待排序序列长度小于QUICKSORT_THRESHOLD，则采用快速排序
        if (right - left < QUICKSORT_THRESHOLD) {
            sort(a, left, right, true);
            return;
        }

        /*
         * Index run[i] is the start of i-th run
         * (ascending or descending sequence).
         */
        // run用于保存所有run的起始下标
        int[] run = new int[MAX_RUN_COUNT + 1];
        int count = 0; run[0] = left;

        // Check if the array is nearly sorted
        for (int k = left; k < right; run[count] = k) {
            if (a[k] < a[k + 1]) { // ascending
                // 找到整个递增序列
                while (++k <= right && a[k - 1] <= a[k]);
            } else if (a[k] > a[k + 1]) { // descending
                // 找到整个递减序列
                while (++k <= right && a[k - 1] >= a[k]);
                // 反转这个递减序列，使其变为递增
                for (int lo = run[count] - 1, hi = k; ++lo < --hi; ) {
                    int t = a[lo]; a[lo] = a[hi]; a[hi] = t;
                }
            } else { // equal
                for (int m = MAX_RUN_LENGTH; ++k <= right && a[k - 1] == a[k]; ) {
                    // 当发现相等的元素超过MAX_RUN_LENGTH时，采用快速排序？可是为什么要这样做呢？
                    if (--m == 0) {
                        sort(a, left, right, true);
                        return;
                    }
                }
            }

            /*
             * The array is not highly structured,
             * use Quicksort instead of merge sort.
             */
            // 当发现run非常多，意味着这些run都是一些很短的片段，大致上可以判定为无规律，即无序状态。这个时候采用快速排序
            if (++count == MAX_RUN_COUNT) {
                sort(a, left, right, true);
                return;
            }
        }

        // Check special cases
        // Implementation note: variable "right" is increased by 1.
        // 注意，这里会使得right增加1
        if (run[count] == right++) { // The last run contains one element
            run[++count] = right;
        } else if (count == 1) { // The array is already sorted
            // 说明整个数组就是有序的，直接返回就行了
            return;
        }

        // 下面开始归并排序

        // Determine alternation base for merge
        byte odd = 0;
        for (int n = 1; (n <<= 1) < count; odd ^= 1);

        // Use or create temporary array b for merging
        int[] b;                 // temp array; alternates with a
        int ao, bo;              // array offsets from 'left'
        int blen = right - left; // space needed for b
        if (work == null || workLen < blen || workBase + blen > work.length) {
            work = new int[blen];
            workBase = 0;
        }
        if (odd == 0) {
            System.arraycopy(a, left, work, workBase, blen);
            b = a;
            bo = 0;
            a = work;
            ao = workBase - left;
        } else {
            b = work;
            ao = 0;
            bo = workBase - left;
        }

        // Merging
        for (int last; count > 1; count = last) {
            for (int k = (last = 0) + 2; k <= count; k += 2) {
                int hi = run[k], mi = run[k - 1];
                for (int i = run[k - 2], p = i, q = mi; i < hi; ++i) {
                    if (q >= hi || p < mi && a[p + ao] <= a[q + ao]) {
                        b[i + bo] = a[p++ + ao];
                    } else {
                        b[i + bo] = a[q++ + ao];
                    }
                }
                run[++last] = hi;
            }
            if ((count & 1) != 0) {
                for (int i = right, lo = run[count - 1]; --i >= lo;
                    b[i + bo] = a[i + ao]
                );
                run[++last] = right;
            }
            int[] t = a; a = b; b = t;
            int o = ao; ao = bo; bo = o;
        }
    }
```

## 4.2 sort

```Java
    /**
     * Sorts the specified range of the array by Dual-Pivot Quicksort.
     *
     * @param a the array to be sorted
     * @param left the index of the first element, inclusive, to be sorted
     * @param right the index of the last element, inclusive, to be sorted
     * @param leftmost indicates if this part is the leftmost in the range
     */
    private static void sort(int[] a, int left, int right, boolean leftmost) {
        int length = right - left + 1;

        // Use insertion sort on tiny arrays
        if (length < INSERTION_SORT_THRESHOLD) {
            if (leftmost) {
                /*
                 * Traditional (without sentinel) insertion sort,
                 * optimized for server VM, is used in case of
                 * the leftmost part.
                 */
                for (int i = left, j = i; i < right; j = ++i) {
                    int ai = a[i + 1];
                    while (ai < a[j]) {
                        a[j + 1] = a[j];
                        if (j-- == left) {
                            break;
                        }
                    }
                    a[j + 1] = ai;
                }
            } else {
                /*
                 * Skip the longest ascending sequence.
                 */
                do {
                    if (left >= right) {
                        return;
                    }
                } while (a[++left] >= a[left - 1]);

                /*
                 * Every element from adjoining part plays the role
                 * of sentinel, therefore this allows us to avoid the
                 * left range check on each iteration. Moreover, we use
                 * the more optimized algorithm, so called pair insertion
                 * sort, which is faster (in the context of Quicksort)
                 * than traditional implementation of insertion sort.
                 */
                for (int k = left; ++left <= right; k = ++left) {
                    int a1 = a[k], a2 = a[left];

                    if (a1 < a2) {
                        a2 = a1; a1 = a[left];
                    }
                    while (a1 < a[--k]) {
                        a[k + 2] = a[k];
                    }
                    a[++k + 1] = a1;

                    while (a2 < a[--k]) {
                        a[k + 1] = a[k];
                    }
                    a[k + 1] = a2;
                }
                int last = a[right];

                while (last < a[--right]) {
                    a[right + 1] = a[right];
                }
                a[right + 1] = last;
            }
            return;
        }

        // Inexpensive approximation of length / 7
        int seventh = (length >> 3) + (length >> 6) + 1;

        /*
         * Sort five evenly spaced elements around (and including) the
         * center element in the range. These elements will be used for
         * pivot selection as described below. The choice for spacing
         * these elements was empirically determined to work well on
         * a wide variety of inputs.
         */
        int e3 = (left + right) >>> 1; // The midpoint
        int e2 = e3 - seventh;
        int e1 = e2 - seventh;
        int e4 = e3 + seventh;
        int e5 = e4 + seventh;

        // Sort these elements using insertion sort
        if (a[e2] < a[e1]) { int t = a[e2]; a[e2] = a[e1]; a[e1] = t; }

        if (a[e3] < a[e2]) { int t = a[e3]; a[e3] = a[e2]; a[e2] = t;
            if (t < a[e1]) { a[e2] = a[e1]; a[e1] = t; }
        }
        if (a[e4] < a[e3]) { int t = a[e4]; a[e4] = a[e3]; a[e3] = t;
            if (t < a[e2]) { a[e3] = a[e2]; a[e2] = t;
                if (t < a[e1]) { a[e2] = a[e1]; a[e1] = t; }
            }
        }
        if (a[e5] < a[e4]) { int t = a[e5]; a[e5] = a[e4]; a[e4] = t;
            if (t < a[e3]) { a[e4] = a[e3]; a[e3] = t;
                if (t < a[e2]) { a[e3] = a[e2]; a[e2] = t;
                    if (t < a[e1]) { a[e2] = a[e1]; a[e1] = t; }
                }
            }
        }

        // Pointers
        int less  = left;  // The index of the first element of center part
        int great = right; // The index before the first element of right part

        if (a[e1] != a[e2] && a[e2] != a[e3] && a[e3] != a[e4] && a[e4] != a[e5]) {
            /*
             * Use the second and fourth of the five sorted elements as pivots.
             * These values are inexpensive approximations of the first and
             * second terciles of the array. Note that pivot1 <= pivot2.
             */
            int pivot1 = a[e2];
            int pivot2 = a[e4];

            /*
             * The first and the last elements to be sorted are moved to the
             * locations formerly occupied by the pivots. When partitioning
             * is complete, the pivots are swapped back into their final
             * positions, and excluded from subsequent sorting.
             */
            a[e2] = a[left];
            a[e4] = a[right];

            /*
             * Skip elements, which are less or greater than pivot values.
             */
            while (a[++less] < pivot1);
            while (a[--great] > pivot2);

            /*
             * Partitioning:
             *
             *   left part           center part                   right part
             * +--------------------------------------------------------------+
             * |  < pivot1  |  pivot1 <= && <= pivot2  |    ?    |  > pivot2  |
             * +--------------------------------------------------------------+
             *               ^                          ^       ^
             *               |                          |       |
             *              less                        k     great
             *
             * Invariants:
             *
             *              all in (left, less)   < pivot1
             *    pivot1 <= all in [less, k)     <= pivot2
             *              all in (great, right) > pivot2
             *
             * Pointer k is the first index of ?-part.
             */
            outer:
            for (int k = less - 1; ++k <= great; ) {
                int ak = a[k];
                if (ak < pivot1) { // Move a[k] to left part
                    a[k] = a[less];
                    /*
                     * Here and below we use "a[i] = b; i++;" instead
                     * of "a[i++] = b;" due to performance issue.
                     */
                    a[less] = ak;
                    ++less;
                } else if (ak > pivot2) { // Move a[k] to right part
                    while (a[great] > pivot2) {
                        if (great-- == k) {
                            break outer;
                        }
                    }
                    if (a[great] < pivot1) { // a[great] <= pivot2
                        a[k] = a[less];
                        a[less] = a[great];
                        ++less;
                    } else { // pivot1 <= a[great] <= pivot2
                        a[k] = a[great];
                    }
                    /*
                     * Here and below we use "a[i] = b; i--;" instead
                     * of "a[i--] = b;" due to performance issue.
                     */
                    a[great] = ak;
                    --great;
                }
            }

            // Swap pivots into their final positions
            a[left]  = a[less  - 1]; a[less  - 1] = pivot1;
            a[right] = a[great + 1]; a[great + 1] = pivot2;

            // Sort left and right parts recursively, excluding known pivots
            sort(a, left, less - 2, leftmost);
            sort(a, great + 2, right, false);

            /*
             * If center part is too large (comprises > 4/7 of the array),
             * swap internal pivot values to ends.
             */
            if (less < e1 && e5 < great) {
                /*
                 * Skip elements, which are equal to pivot values.
                 */
                while (a[less] == pivot1) {
                    ++less;
                }

                while (a[great] == pivot2) {
                    --great;
                }

                /*
                 * Partitioning:
                 *
                 *   left part         center part                  right part
                 * +----------------------------------------------------------+
                 * | == pivot1 |  pivot1 < && < pivot2  |    ?    | == pivot2 |
                 * +----------------------------------------------------------+
                 *              ^                        ^       ^
                 *              |                        |       |
                 *             less                      k     great
                 *
                 * Invariants:
                 *
                 *              all in (*,  less) == pivot1
                 *     pivot1 < all in [less,  k)  < pivot2
                 *              all in (great, *) == pivot2
                 *
                 * Pointer k is the first index of ?-part.
                 */
                outer:
                for (int k = less - 1; ++k <= great; ) {
                    int ak = a[k];
                    if (ak == pivot1) { // Move a[k] to left part
                        a[k] = a[less];
                        a[less] = ak;
                        ++less;
                    } else if (ak == pivot2) { // Move a[k] to right part
                        while (a[great] == pivot2) {
                            if (great-- == k) {
                                break outer;
                            }
                        }
                        if (a[great] == pivot1) { // a[great] < pivot2
                            a[k] = a[less];
                            /*
                             * Even though a[great] equals to pivot1, the
                             * assignment a[less] = pivot1 may be incorrect,
                             * if a[great] and pivot1 are floating-point zeros
                             * of different signs. Therefore in float and
                             * double sorting methods we have to use more
                             * accurate assignment a[less] = a[great].
                             */
                            a[less] = pivot1;
                            ++less;
                        } else { // pivot1 < a[great] < pivot2
                            a[k] = a[great];
                        }
                        a[great] = ak;
                        --great;
                    }
                }
            }

            // Sort center part recursively
            sort(a, less, great, false);

        } else { // Partitioning with one pivot
            /*
             * Use the third of the five sorted elements as pivot.
             * This value is inexpensive approximation of the median.
             */
            int pivot = a[e3];

            /*
             * Partitioning degenerates to the traditional 3-way
             * (or "Dutch National Flag") schema:
             *
             *   left part    center part              right part
             * +-------------------------------------------------+
             * |  < pivot  |   == pivot   |     ?    |  > pivot  |
             * +-------------------------------------------------+
             *              ^              ^        ^
             *              |              |        |
             *             less            k      great
             *
             * Invariants:
             *
             *   all in (left, less)   < pivot
             *   all in [less, k)     == pivot
             *   all in (great, right) > pivot
             *
             * Pointer k is the first index of ?-part.
             */
            for (int k = less; k <= great; ++k) {
                if (a[k] == pivot) {
                    continue;
                }
                int ak = a[k];
                if (ak < pivot) { // Move a[k] to left part
                    a[k] = a[less];
                    a[less] = ak;
                    ++less;
                } else { // a[k] > pivot - Move a[k] to right part
                    while (a[great] > pivot) {
                        --great;
                    }
                    if (a[great] < pivot) { // a[great] <= pivot
                        a[k] = a[less];
                        a[less] = a[great];
                        ++less;
                    } else { // a[great] == pivot
                        /*
                         * Even though a[great] equals to pivot, the
                         * assignment a[k] = pivot may be incorrect,
                         * if a[great] and pivot are floating-point
                         * zeros of different signs. Therefore in float
                         * and double sorting methods we have to use
                         * more accurate assignment a[k] = a[great].
                         */
                        a[k] = pivot;
                    }
                    a[great] = ak;
                    --great;
                }
            }

            /*
             * Sort left and right parts recursively.
             * All elements from center part are equal
             * and, therefore, already sorted.
             */
            sort(a, left, less - 1, leftmost);
            sort(a, great + 1, right, false);
        }
    }
```

# 5 参考

* [DualPivotQuickSort 双轴快速排序 源码 笔记](http://www.jianshu.com/p/6d26d525bb96)
* [QUICKSORTING - 3-WAY AND DUAL PIVOT](http://rerun.me/2013/06/13/quicksorting-3-way-and-dual-pivot/)
