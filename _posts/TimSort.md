---
title: TimSort
date: 2017-07-24 15:52:16
tags: 摘录
categories:
- 算法
- 排序
---

__目录__

<!-- toc -->
<!--more-->


# 前言

Timsort是结合了合并排序（merge sort）和插入排序（insertion sort）而得出的排序算法，它在现实中有很好的效率。Tim Peters在2002年设计了该算法并在Python中使用（TimSort是python中list.sort的默认实现）。该算法找到数据中已经排好序的块-分区，每一个分区叫一个run，然后按规则合并这些run。Pyhton自从2.3版以来一直采用Timsort算法排序，现在Java SE7和Android也采用Timsort算法对数组排序。

JDK 1.8的实现中，Arrays.sort根据数组元素的类型会采用两种不同的排序算法。__对于基本类型(byte,short,int,long,float,double)__，采用的是一种优化过的快速排序（本篇博客不做介绍），虽然快速排序是不稳定的排序，但是对于基本类型而言，稳定与否没有任何区别。__对于类类型（reference）__，采用的是就是本篇博客将要讨论的TimSort，TimSort是一种优化过的归并排序，具有稳定性


# 术语

Timsort算法中用到了几个术语，为了方便阅读JDK源码，在这里先简单介绍一下

1. __run__

> run是数组中一段已排序的片段


# JDK 源码剖析

## Arrays.sort

`Arrays.sort()`是排序的接口方法

```Java
    public static void sort(Object[] a) {
        //如果需要使用旧版的Merge sort
        if (LegacyMergeSort.userRequested)
            //使用旧版的MergeSort进行排序操作
            legacyMergeSort(a);
        else
            //使用TimSort
            ComparableTimSort.sort(a, 0, a.length, null, 0, 0);
    }
```


## ComparableTimSort.sort

`ComparableTimSort.sort()`包含了TimSort的主要逻辑

1. 若范围内的元素少于2，那么直接返回，因为一定是有序的
1. 若范围内的元素少于MIN_MERGE，采用二分插入排序算法

```Java
    /**
     * Sorts the given range, using the given workspace array slice
     * for temp storage when possible. This method is designed to be
     * invoked from public methods (in class Arrays) after performing
     * any necessary array bounds checks and expanding parameters into
     * the required forms.
     *
     * @param a the array to be sorted
     * @param lo the index of the first element, inclusive, to be sorted
     * @param hi the index of the last element, exclusive, to be sorted
     * @param work a workspace array (slice)
     * @param workBase origin of usable space in work array
     * @param workLen usable size of work array
     * @since 1.8
     */
    static void sort(Object[] a, int lo, int hi, Object[] work, int workBase, int workLen) {
        assert a != null && lo >= 0 && lo <= hi && hi <= a.length;
        
        // 待排序元素数量
        int nRemaining  = hi - lo;
        if (nRemaining < 2)
            return;  // Arrays of size 0 and 1 are always sorted

        // If array is small, do a "mini-TimSort" with no merges
        // 如果待排序元素数量小于MIN_MERGE就使用"mini-TimSort"即二分插入排序算法
        if (nRemaining < MIN_MERGE) {
            // 返回包含头元素的最长递增序列的长度
            int initRunLen = countRunAndMakeAscending(a, lo, hi);
            // 进行二分插入排序算法
            binarySort(a, lo, hi, lo + initRunLen);
            return;
        }

        /**
         * March over the array once, left to right, finding natural runs,
         * extending short natural runs to minRun elements, and merging runs
         * to maintain stack invariant.
         */
        ComparableTimSort ts = new ComparableTimSort(a, work, workBase, workLen);

        //根据元素数量计算出run的最小大小
        int minRun = minRunLength(nRemaining);
        do {
            // Identify next run
            // 计算出下一个run的大小
            int runLen = countRunAndMakeAscending(a, lo, hi);

            // If run is short, extend to min(minRun, nRemaining)
            if (runLen < minRun) {
                int force = nRemaining <= minRun ? nRemaining : minRun;
                binarySort(a, lo, lo + force, lo + runLen);
                runLen = force;
            }

            // Push run onto pending-run stack, and maybe merge
            ts.pushRun(lo, runLen);
            ts.mergeCollapse();

            // Advance to find next run
            lo += runLen;
            nRemaining -= runLen;
        } while (nRemaining != 0);

        // Merge all remaining runs to complete sort
        assert lo == hi;
        ts.mergeForceCollapse();
        assert ts.stackSize == 1;
    }
```

## countRunAndMakeAscending


```Java
    /**
     * Returns the length of the run beginning at the specified position in
     * the specified array and reverses the run if it is descending (ensuring
     * that the run will always be ascending when the method returns).
     *
     * A run is the longest ascending sequence with:
     *
     *    a[lo] <= a[lo + 1] <= a[lo + 2] <= ...
     *
     * or the longest descending sequence with:
     *
     *    a[lo] >  a[lo + 1] >  a[lo + 2] >  ...
     *
     * For its intended use in a stable mergesort, the strictness of the
     * definition of "descending" is needed so that the call can safely
     * reverse a descending sequence without violating stability.
     *
     * @param a the array in which a run is to be counted and possibly reversed
     * @param lo index of the first element in the run
     * @param hi index after the last element that may be contained in the run.
              It is required that {@code lo < hi}.
     * @return  the length of the run beginning at the specified position in
     *          the specified array
     */
    @SuppressWarnings({"unchecked", "rawtypes"})
    private static int countRunAndMakeAscending(Object[] a, int lo, int hi) {
        assert lo < hi;
        int runHi = lo + 1;
        //如果当前run中只有一个元素，那么一定是有序的，返回即可。如果从sort方法中调用该方法，那么必然保证runLen>1，因此以下if一定返回false
        if (runHi == hi)
            return 1;

        // Find end of run, and reverse range if descending
        //如果run中第二个元素严格小于第一个元素，即严格递减
        if (((Comparable) a[runHi++]).compareTo(a[lo]) < 0) { // Descending
            //找到严格递减的最长序列
            while (runHi < hi && ((Comparable) a[runHi]).compareTo(a[runHi - 1]) < 0)
                runHi++;
            //将递减序列进行反转，因为TimSort必须保证稳定性，所以前面才必须是严格递减的，否则如果交换两个相等的元素则会导致稳定性被破坏
            reverseRange(a, lo, runHi);
        } else {                              // Ascending
            //找到递增(可以非严格递增)的最长序列
            while (runHi < hi && ((Comparable) a[runHi]).compareTo(a[runHi - 1]) >= 0)
                runHi++;
        }

        //返回递增序列的长度
        return runHi - lo;
    }
```

## reverseRange

反转指定片段，这是一种最简洁的写法了，不用考虑奇数偶数之类的，只要`lo<hi`就交换

```Java
    /**
     * Reverse the specified range of the specified array.
     *
     * @param a the array in which a range is to be reversed
     * @param lo the index of the first element in the range to be reversed
     * @param hi the index after the last element in the range to be reversed
     */
    private static void reverseRange(Object[] a, int lo, int hi) {
        hi--;
        while (lo < hi) {
            Object t = a[lo];
            a[lo++] = a[hi];
            a[hi--] = t;
        }
    }
```


## binarySort

二分插入排序，对于一个较小的数组来说，二分插入排序是最优的一种算法。

二分插入排序算法相比于插入排序算法而言进行了一些优化：__对于开头已排序的部分，二分插入排序算法能够充分利用已排序这一点来减少的次数，提升交换的速度(System.arraycopy)__

```Java

    /**
     * Sorts the specified portion of the specified array using a binary
     * insertion sort.  This is the best method for sorting small numbers
     * of elements.  It requires O(n log n) compares, but O(n^2) data
     * movement (worst case).
     *
     * If the initial part of the specified range is already sorted,
     * this method can take advantage of it: the method assumes that the
     * elements from index {@code lo}, inclusive, to {@code start},
     * exclusive are already sorted.
     *
     * @param a the array in which a range is to be sorted
     * @param lo the index of the first element in the range to be sorted
     * @param hi the index after the last element in the range to be sorted
     * @param start the index of the first element in the range that is
     *        not already known to be sorted ({@code lo <= start <= hi})
     */
    @SuppressWarnings({"fallthrough", "rawtypes", "unchecked"})
    private static void binarySort(Object[] a, int lo, int hi, int start) {
        assert lo <= start && start <= hi;
        //如果start与lo相同，那么将start递增1，因为第一个元素一定是有序的，因此未排序的部分从第二个元素开始
        if (start == lo)
            start++;
        for ( ; start < hi; start++) {
            Comparable pivot = (Comparable) a[start];

            //因为[lo,start-]范围内的元素是已排序的，那么将一个元素插入到这个范围内可以采用二分法，而不用从后面依次向前比较
            // Set left (and right) to the index where a[start] (pivot) belongs
            int left = lo;
            int right = start;
            assert left <= right;
            /*
             * Invariants:
             *   pivot >= all in [lo, left).
             *   pivot <  all in [right, start).
             */
            while (left < right) {
                int mid = (left + right) >>> 1;
                if (pivot.compareTo(a[mid]) < 0)
                    right = mid;
                else
                    left = mid + 1;
            }
            assert left == right;

            /*
             * The invariants still hold: pivot >= all in [lo, left) and
             * pivot < all in [left, start), so pivot belongs at left.  Note
             * that if there are elements equal to pivot, left points to the
             * first slot after them -- that's why this sort is stable.
             * Slide elements over to make room for pivot.
             */
            //n表示需要移动的元素数量
            int n = start - left;  // The number of elements to move
            // Switch is just an optimization for arraycopy in default case
            //元素的移动分为两类情况，第一类是只需要移动一个或者两个元素，那么直接手动移动即可；第二类是需要移动比较多的元素，那么使用System.arraycopy来进行内存拷贝，提高效率
            switch (n) {
                case 2:  a[left + 2] = a[left + 1];
                case 1:  a[left + 1] = a[left];
                         break;
                default: System.arraycopy(a, left, a, left + 1, n);
            }
            a[left] = pivot;
        }
    }
```