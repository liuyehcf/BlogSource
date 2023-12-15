---
title: Algorithm-Sort
date: 2017-07-26 21:10:17
tags: 
- 原创
categories: 
- Algorithm
- Sort
---

**阅读更多**

<!--more-->

# 1 Bubble Sort

冒泡排序，每次从底部(数组末尾)往上(数组有效左边界，该左边界会递增)找到最小值，并置于左边界上，再递增左边界。很简单，直接上代码

```java
package org.liuyehcf.sort.bubblesort;

import static org.liuyehcf.sort.SortUtils.*;

/**
 * Created by HCF on 2017/7/26.
 */
public class BubbleSort {

    public static void sort(int[] nums) {
        for (int i = 0; i < nums.length; i++) {
            for (int j = nums.length - 1; j > i; j--) {
                compareAndExchange(nums, j - 1, j);
            }
        }
    }

    private static void compareAndExchange(int[] nums, int left, int right) {
        if (nums[left] > nums[right]) {
            exchange(nums, left, right);
        }
    }
}
```

# 2 Insertion Sort

## 2.1 经典版本

循环不变式：`nums[0]~nums[i-1]为有序片段`

```java
/**
 * Created by HCF on 2017/7/26.
 */
public class InsertSort {
    public static void sort(int[] nums) {
        for (int i = 1; i < nums.length; i++) {
            int pivot = nums[i];
            int j = i - 1;
            while (j >= 0 && nums[j] > pivot) {
                nums[j + 1] = nums[j];
                j--;
            }
            nums[j + 1] = pivot;
        }
    }
}
```

## 2.2 二分插入排序

```java
public class BinaryInsertSort {
    public static void sort(int[] nums) {
        for (int i = 1; i < nums.length; i++) {
            int pivot = nums[i];

            int left = 0, right = i - 1;

            //首先检查两种特殊情况
            if (nums[right] <= pivot) {
                continue;
            } else if (nums[0] > pivot) {
                System.arraycopy(nums, 0, nums, 1, i);
                nums[0] = pivot;
                continue;
            }

            while (left < right) {
                int mid = left + (right - left >> 1);

                if (nums[mid] <= pivot) {
                    left = mid + 1;
                } else {
                    right = mid;
                }
            }

            System.arraycopy(nums, left, nums, left + 1, i - left);
            nums[left] = pivot;
        }
    }
}
```

# 3 Merge Sort

```java
public class MergeSort {
    public static void sort(int[] nums) {
        sort(nums, 0, nums.length - 1);
    }

    private static void sort(int[] nums, int left, int right) {
        if (left < right) {
            int mid = left + (right - left >> 1);

            //注意这里不能变为[left,mid-1]与[mid,right]
            sort(nums, left, mid);

            sort(nums, mid + 1, right);

            merge(nums, left, mid, mid + 1, right);
        }
    }

    private static void merge(int[] nums, int left1, int right1, int left2, int right2) {
        int[] tmp = new int[right1 - left1 + 1];

        System.arraycopy(nums, left1, tmp, 0, tmp.length);

        int i1 = 0, i2 = left2, i = left1;

        while (i1 <= tmp.length - 1 && i2 <= right2) {
            if (tmp[i1] <= nums[i2]) {
                nums[i++] = tmp[i1++];
            } else {
                nums[i++] = nums[i2++];
            }
        }

        if (i1 <= tmp.length - 1) {
            System.arraycopy(tmp, i1, nums, i, tmp.length - i1);
        } else if (i2 <= right2) {
            System.arraycopy(nums, i2, nums, i, right2 - i2 + 1);
        }
    }
}
```

归并排序还有一个优化版本TimSort，关于TimSort的实现可以参考JDK Arrays.sort的源码 {% post_link SourceAnalysis-ComparableTimSort %}

## 3.1 Paralle Merge

```cpp
#include <algorithm>
#include <chrono>
#include <exception>
#include <iostream>
#include <random>
#include <thread>
#include <tuple>
#include <typeinfo>
#include <utility>
#include <vector>

class ParallelMerger {
public:
    void merge(std::vector<int32_t>& A, std::vector<int32_t>& B, std::vector<int32_t>& S, int32_t p) {
        int32_t length = (A.size() + B.size()) / p + 1;
        for (int i = 0; i <= p; ++i) {
            auto pair = diagnoal_intersection(A, B, i, p);
            int32_t a_start = pair.first;
            int32_t b_start = pair.second;
            int32_t s_start = i * (A.size() + B.size()) / p;
            do_merge_along_path(A, a_start, B, b_start, S, s_start, length);
        }
    }

private:
    std::pair<int32_t, int32_t> diagnoal_intersection(std::vector<int32_t>& A, std::vector<int32_t>& B, int32_t p_i,
                                                      int32_t p) {
        int32_t diag = p_i * (A.size() + B.size()) / p;
        if (diag > A.size() + B.size() - 1) {
            diag = A.size() + B.size() - 1;
        }

        int32_t i_high = diag;
        int32_t i_low = 0;
        if (i_high > A.size()) {
            i_high = A.size();
        }

        // binary search
        while (i_low < i_high) {
            int32_t i = i_low + (i_high - i_low) / 2;
            int32_t j = diag - i;

            auto pair = is_intersection(A, i, B, j);
            bool is_intersection = pair.first;
            bool all_true = pair.second;

            if (is_intersection) {
                return std::make_pair(i, j);
            } else if (all_true) {
                i_high = i;
            } else {
                i_low = i + 1;
            }
        }

        // edge cases
        for (int offset = 0; offset <= 1; offset++) {
            int32_t i = i_low + offset;
            int32_t j = diag - i;

            auto pair = is_intersection(A, i, B, j);
            bool is_intersection = pair.first;

            if (is_intersection) {
                return std::make_pair(i, j);
            }
        }

        throw std::logic_error("unexpected");
    }

    std::pair<bool, bool> is_intersection(const std::vector<int32_t>& A, const int32_t i, const std::vector<int32_t>& B,
                                          const int32_t j) {
        // M matrix is a matrix conprising of only boolean value
        // if A[i] > B[j], then M[i, j] = true
        // if A[i] <= B[j], then M[i, j] = false
        // and for the edge cases (i or j beyond the matrix), think about the merge path, with A as the vertical vector and B as the horizontal vector,
        // which goes from left top to right bottom, the positions below the merge path should be true, and otherwise should be false
        auto evaluator = [&A, &B](int32_t i, int32_t j) {
            if (i < 0) {
                return false;
            } else if (i >= A.size()) {
                return true;
            } else if (j < 0) {
                return true;
            } else if (j >= B.size()) {
                return false;
            } else {
                return A[i] > B[j];
            }
        };

        bool has_true = false;
        bool has_false = false;

        if (evaluator(i - 1, j - 1)) {
            has_true = true;
        } else {
            has_false = true;
        }
        if (evaluator(i - 1, j)) {
            has_true = true;
        } else {
            has_false = true;
        }
        if (evaluator(i, j - 1)) {
            has_true = true;
        } else {
            has_false = true;
        }
        if (evaluator(i, j)) {
            has_true = true;
        } else {
            has_false = true;
        }

        return std::make_pair(has_true && has_false, has_true);
    }

    void do_merge_along_path(const std::vector<int32_t>& A, const int32_t a_start, const std::vector<int32_t>& B,
                             const int32_t b_start, std::vector<int32_t>& S, int32_t s_start, int32_t length) {
        int32_t i = a_start;
        int32_t j = b_start;
        int32_t k = s_start;

        while (k - s_start < length && k < S.size()) {
            if (i >= A.size()) {
                S[k] = B[j];
                k++;
                j++;
            } else if (j >= B.size()) {
                S[k] = A[i];
                k++;
                i++;
            } else if (A[i] <= B[j]) {
                S[k] = A[i];
                k++;
                i++;
            } else {
                S[k] = B[j];
                k++;
                j++;
            }
        }
    }
};

void print(const std::vector<int32_t>& v) {
    for (int32_t i = 0; i < v.size(); i++) {
        if (i != 0) {
            std::cout << ", ";
        }
        std::cout << v[i];
    }
    std::cout << std::endl;
}

int main() {
    constexpr int32_t max = 100;
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u(1, max);

    for (int times = 0; times < max; ++times) {
        int32_t size_A = u(e);
        int32_t size_B = u(e);

        std::vector<int32_t> A;
        std::vector<int32_t> B;
        std::vector<int32_t> expected;

        for (int32_t i = 0; i < size_A; ++i) {
            int32_t item = u(e);
            A.push_back(item);
            expected.push_back(item);
        }
        for (int32_t i = 0; i < size_B; ++i) {
            int32_t item = u(e);
            B.push_back(item);
            expected.push_back(item);
        }

        std::sort(A.begin(), A.end());
        std::sort(B.begin(), B.end());
        std::sort(expected.begin(), expected.end());
        std::cout << "A's size=" << A.size() << ", B's size=" << B.size() << std::endl;

        for (int p = 1; p <= 128; p++) {
            std::cout << "times=" << times << ", p=" << p << std::endl;
            std::vector<int32_t> S;
            S.assign(A.size() + B.size(), -1);

            ParallelMerger merger;
            merger.merge(A, B, S, p);

            bool is_ok = true;
            for (int32_t i = 0; i < S.size(); i++) {
                if (S[i] != expected[i]) {
                    is_ok = false;
                    break;
                }
            }

            if (!is_ok) {
                std::cerr << "not ok" << std::endl;
                print(A);
                print(B);
                print(S);
                print(expected);
                return 1;
            }
        }
    }

    return 0;
}
```

# 4 Heap Sort

首先创建一个最大堆，然后将堆顶元素与当前边界元素交换，并将边界减少1，对堆顶元素维护性质

```java
public class HeapSort {
    public static void sort(int[] nums) {
        buildMaxHeap(nums);

        for (int len = nums.length; len >= 2; len--) {
            exchange(nums, 0, len - 1);
            maxHeapFix(nums, len - 1, 0);
        }
    }

    private static void maxHeapFix(int[] nums, int heapSize, int i) {
        int left = i * 2 + 1, right = i * 2 + 2;

        if (left >= heapSize) {
            left = -1;
        }
        if (right >= heapSize) {
            right = -1;
        }

        int max = i;

        if (left != -1 && nums[left] > nums[i]) {
            max = left;
        }

        if (right != -1 && nums[right] > nums[max]) {
            max = right;
        }

        if (max != i) {
            exchange(nums, i, max);
            maxHeapFix(nums, heapSize, max);
        }
    }

    private static void buildMaxHeap(int[] nums) {
        for (int i = nums.length >> 1; i >= 0; i--) {
            maxHeapFix(nums, nums.length, i);
        }
    }
}
```

## 4.1 TopK

```cpp
#include <algorithm>
#include <functional>
#include <iostream>
#include <list>
#include <queue>
#include <random>

std::vector<int32_t> top_k(const std::vector<int32_t>& nums, size_t k) {
    std::priority_queue<int32_t, std::vector<int32_t>, std::greater<int32_t>> min_queue;
    for (auto num : nums) {
        if (min_queue.size() < k) {
            min_queue.push(num);
        } else if (num > min_queue.top()) {
            min_queue.pop();
            min_queue.push(num);
        }
    }
    std::list<int32_t> res;
    while (!min_queue.empty()) {
        res.insert(res.begin(), min_queue.top());
        min_queue.pop();
    }

    return {res.begin(), res.end()};
}

int main() {
    size_t test_times = 100;
    std::default_random_engine e;
    std::uniform_int_distribution<size_t> u_k(1, 20);
    std::uniform_int_distribution<size_t> u_size(1, 50);
    std::uniform_int_distribution<int32_t> u_num(1, 10000);

    for (size_t i = 0; i < test_times; ++i) {
        const size_t k = u_k(e);
        const size_t size = u_size(e);
        std::cout << "test_time=" << i << ", k=" << k << ", size=" << size << std::endl;
        std::vector<int32_t> nums;
        for (size_t j = 0; j < size; ++j) {
            nums.push_back(u_num(e));
        }

        std::vector<int32_t> res = top_k(nums, k);
        std::sort(nums.begin(), nums.end(), std::greater<int32_t>());
        if (k < size) {
            nums = std::vector<int32_t>(nums.begin(), nums.begin() + k);
        }

        for (size_t j = 0; j < res.size(); ++j) {
            if (res[j] != nums[j]) {
                std::cerr << "wrong result" << std::endl;
                return 1;
            }
        }
    }
    return 0;
}
```

# 5 Quick Sort

## 5.1 2-way Quick Sort

下面给出经典快排的源码，包含递归模式和非递归模式

```java
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

## 5.2 3-way Quick Sort

下面直接给出3-way快排的源码，包括递归模式和非递归模式

partition方法中lt和gt的含义如下

1. lt代表小于pivot的右边界
1. gt代表大于pivot的左边界
1. 因此满足`nums[lo~lt]<pivot nums[lt+1~gt-1]==pivot nums[gt~hi]>pivot`

```java
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

## 5.3 Dual-Pivot Quick Sort

下面直接给出双轴快排的源码，包括递归模式和非递归模式

其中partition方法中的lt、le、ge、lt含义如下

1. lt代表小于pivot1的右边界
1. le代表等于pivot1的右边界
1. ge代表等于pivot2的左边界
1. gt代表大于pivot2的右边界
1. 因此满足`nums[lo~lt]<pivot1 nums[lt+1~le]==pivot2  pivot1<nums[le+1~ge-1]<pivot2 nums[ge~gt-1]==pivot2 nums[gt~hi]>pivot2`

```java
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

关于双轴快排的更多实现可以参考JDK Arrays.sort的源码 {% post_link SourceAnalysis-DualPivotQuickSort %}

# 6 Counting Sort

计数排序复杂度是O(n)，以牺牲空间复杂度来提高时间效率。适用于可枚举且范围较小的类型的排序，例如short、char、byte等

```java
public class CountSort {
    public static void sort(int[] nums) {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;

        for (int num : nums) {
            if (num < min) {
                min = num;
            }

            if (num > max) {
                max = num;
            }
        }

        int len = max - min + 1;

        int[] counts = new int[len];

        for (int num : nums) {
            counts[num - min]++;
        }

        int index = 0;
        for (int i = 0; i < counts.length; i++) {
            int count = counts[i];
            while (count-- > 0) {
                nums[index++] = min + i;
            }
        }
    }

    public static void main(String[] args) {
        final int LEN = 500000;

        final int TIMES = 100;

        final Random random = new Random();

        long duration = 0;
        for (int t = 0; t < TIMES; t++) {

            int[] nums = new int[LEN];

            for (int i = 0; i < LEN; i++) {
                nums[i] = random.nextInt(100000);
            }

            long start = System.currentTimeMillis();

            sort(nums);

            duration += System.currentTimeMillis() - start;

            for (int j = 1; j < nums.length; j++) {
                if (nums[j] < nums[j - 1]) throw new RuntimeException();
            }
        }
        System.out.format("%-20s : %d ms\n", "CountSort", duration);

        System.out.println("\n------------------------------------------\n");
    }
}
```

# 7 Bitonic Sort

**`Bitonic Sequence`又称为双调序列，即一个长为`2^n`的序列，前半部分递增，后半部分递减（当然也可以反过来）。特别地，当`n = 1`时，即仅包含两个元素的序列也是双调序列**

下面以一个例子来说明，如何利用双调序列来进行排序，原始序列如下：

```
3    7     4    8     6    2     1    5
```

由于当`n = 1`时，已经是4个双调序列了，分别为`(3, 7)`、`(4, 8)`、`(6, 2)`、`(1, 5)`。因此，我们下一步需要构造2个`(n + 1) = 2`的双调序列，此时：

* `current distance, cd = 2^(n-1) = 1 | n = 1`

```
group 1 │ group 2  │ group 3  │ group 4
        │          │          │
3    7  │  4    8  │  6    2  │  1    5

                   │
                   ▼

      group 1      │       group 2
                   │
3    7     4    8  │  6    2     1    5
│    ▲     ▲    │  │  │    ▲     ▲    │
└────┘     └─sw─┘  │  └─sw─┘     └─sw─┘
        │          │          │
        ▼          │          ▼
3    7     8    4  │  2    6     5    1
```

此时，我们得到了2个`n = 2`的双调序列，分别为`(3, 7, 8, 4)`、`(2, 6, 5, 1)`，因此，我们下一步需要构造1个`(n + 1) = 3`的双调序列，此时：

* `cd = 2^(n-1) = 2 | n = 2`
* `cd = cd / 2 = 1`

```
      group 1      │      group 2
                   │
3    7     8    4  │  2    6     5    1

                   │
                   ▼

                group 1

3    7     8    4     2    6     5    1
│    │     ▲    ▲     ▲    ▲     │    │
└────┼─────┘    │     └────┬─sw──┘    │
     │          │          │          │
     └────sw────┘          └──────────┘
                   │
                   ▼
3    4     8    7     5    6     2    1
│    ▲     │    ▲     ▲    │     ▲    │
└────┘     └─sw─┘     └─sw─┘     └────┘
                   │
                   ▼
3    4     7    8     6    5     2    1
```

此时，我们得到了1个`n = 3`的双调序列，即`(3, 4, 7, 8, 6, 5, 2, 1)`，因此，我们下一步需要构造1个`(n + 1) = 4`的双调序列，此时：

* 由于原序列只有8个元素，因此我们只关注左半部分即可（升序的半边），这是双调序列可用于排序的精妙所在（双调排序）
* `cd = 2^(n-1) = 4 | n = 3`
* `cd = cd/2 = 2`
* `cd = cd/2 = 1`

```
                group 1

3    4     7    8     6    5     2    1
                  │
                  ▼

                            group 1

3    4     7    8     6    5     2    1   x x x x x x x x
│    │     │    │     ▲    ▲     ▲    ▲
└────┼─────┼────┼─────┘    │     │    │
     │     │    │          │     │    │
     └─────┼────┼──────────┘     │    │
           │    │                │    │
           └────┼────sw──────────┘    │
                │                     │
                └──────────sw─────────┘

                   │
                   ▼
3    4     2    1     6    5     7    8   x x x x x x x x
│    │     ▲    ▲     │    │     ▲    ▲
└──sw├─────┘    │     └────┼─────┘    │
     │          │          │          │
     └────sw────┘          └──────────┘
                   │
                   ▼
2    1     3    4     6    5     7    8   x x x x x x x x
│    ▲     │    ▲     │    ▲     │    ▲
└─sw─┘     └────┘     └─sw─┘     └────┘
                   │
                   ▼
1    2     3    4     5    6     7    8   x x x x x x x x
```

此时，我们得到了一个`n = 4`的双调序列，即`(1, 2, 3, 4, 5, 6, 7, 8, x, x, x, x, x, x, x, x)`，升序部分就是排序的输出

## 7.1 参考

* [Bitonic Merge Sort | Explanation and Code Tutorial | Everything you need to know!](https://www.youtube.com/watch?v=w544Rn4KC8I)
* [Bitonic Sort](https://wiki.rice.edu/confluence/download/attachments/4435861/comp322-s12-lec28-slides-JMC.pdf?version=1&modificationDate=1333163955158)

# 8 Parallel Merge Sort

思路：假设有`N`路输入，每路有序，先统计这`N`路数据的分布，找到`N-1`个分界点（切`N-1`刀变`N`块），每路输入按照这`N-1`个分界点对数据进行shuffle，分别送入`N`路输入中。这样`N`路输入就不相交了，每路再进行归并，最后直接合并即可

## 8.1 Merge Path

[Merge Path - A Visually Intuitive Approach](/resources/paper/Merge-Path-A-Visually-Intuitive-Approach-to-Parallel-Merging.pdf)

## 8.2 Pipelined Multi-staged Merge Sort

[Parallel Merge Sort](/resources/paper/Parallel-Merge-Sort.pdf)

# 9 Approx Top K

[Efficient Computation of Frequent and Top-k Elements in Data Streams ](/resources/paper/Efficient-Computation-of-Frequent-and-Top-k-Elements-in-Data-Streams.pdf)

```cpp
#include <iostream>
#include <unordered_map>
#include <vector>

struct ItemCounter {
    int32_t item;
    size_t counter;
};

class SpaceSaved {
private:
    std::unordered_map<int32_t, ItemCounter*> _table;
    std::vector<ItemCounter> _counters;
    size_t empty_idx = 0;

public:
    SpaceSaved(int32_t k) : _counters(k) {}

    void process(int32_t item) {
        if (_table.find(item) != _table.end()) {
            _table[item]->counter++;
        } else {
            if (empty_idx < _counters.size()) {
                ItemCounter* empty_counter = &_counters[empty_idx++];
                empty_counter->item = item;
                empty_counter->counter = 1;
                _table[item] = empty_counter;
            } else {
                ItemCounter* minCounter = &_counters[0];
                for (auto& counter : _counters) {
                    if (counter.counter < minCounter->counter) {
                        minCounter = &counter;
                    }
                }
                _table.erase(minCounter->item);
                minCounter->item = item;
                minCounter->counter++;
                _table[item] = minCounter;
            }
        }
    }

    std::vector<ItemCounter> get_frequent_items() { return _counters; }
};

int main() {
    SpaceSaved ss(5);

    // A simple test case
    std::vector<int32_t> stream = {1, 1, 2, 2, 2, 3, 4, 4, 5, 5, 6, 7, 7, 7, 8};

    for (int32_t item : stream) {
        ss.process(item);
    }

    auto frequentItems = ss.get_frequent_items();
    for (const auto& entry : frequentItems) {
        std::cout << "Item: " << entry.item << ", Count: " << entry.counter << std::endl;
    }

    return 0;
}
```

## 9.1 Two-stage Aggregation

The Space Saving Algorithm is commonly used for estimating the top-K frequent items in a stream of data with limited memory. To implement this as a two-stage aggregate function for a distributed database management system (DBMS), you'll need to handle the aggregation in two main phases:

1. `Local Aggregation` (First-stage aggregate on each node)
1. `Global Aggregation` (Second-stage aggregate on a single node)

Here's how you can design and execute the two-stage aggregation:

**Local Aggregation (First-stage):** Each node will maintain a list of counters based on the Space Saving Algorithm:

1. For each incoming item in the stream:
    1. If the item is already in the list of counters, increment its count.
    1. If the item is not in the list and there is space available, add it to the list with a count of 1.
    1. If the item is not in the list and there is no space available, find the item with the smallest count, replace it with the new item and increment the count of the new item.
1. At the end of this phase, each node will have its local top-K counters.

**Global Aggregation (Second-stage):** After the local aggregation phase, the intermediate counters from all nodes will be sent to a particular aggregation node. On this node:

1. For each counter from the nodes:
    1. If the item is already in the global list of counters, add the local count to the global count.
    1. If the item is not in the global list and there is space available, add it to the global list with its local count.
    1. If the item is not in the global list and there is no space available, determine if its local count is greater than the smallest global counter. If it is, replace the global counter with the new item and its count. Otherwise, discard the counter.
1. Once all the local counters have been processed, the global list will contain the estimated top-K frequent items across all the nodes.

**Some considerations:**

* Due to the nature of the Space Saving Algorithm, the accuracy of the results will depend on the number of counters you maintain in your list. The more counters you have, the more accurate the result, but at the cost of increased memory usage.
* In the global aggregation phase, you might be merging a lot of counters, especially if you have many nodes. Ensure your global counter list is sufficiently large to maintain accuracy.
* Depending on the distribution of your data across nodes, there might be significant overlap between local top-K items. This can make your global results more accurate.
* Implementing the Space Saving Algorithm for a distributed DBMS can be a challenging task, but with careful design and attention to detail, it's possible to get accurate top-K estimations with limited memory.

# 10 总结

| 排序算法 | 是否稳定 | 是否原址 | 复杂度 |
|:--|:--|:--|:--|
| 冒泡排序 | 是 | 是 | O(N2) |
| 插入排序 | 是 | 是 | O(N2) |
| 归并排序 | 是 | 否 | O(NlgN) |
| 堆排序 | 否 | 是 | O(NlgN) |
| 快速排序 | 否 | 是 | O(NlgN) |
| 计数排序 | 是(对于基本类型) | 否 | O(N) |

**可以用leetcode第912题来验证算法是否正确**
