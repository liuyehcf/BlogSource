---
title: Algorithm-List
date: 2017-07-16 21:14:48
tags: 
- 原创
categories: 
- Algorithm
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-21[★★]

**Merge Two Sorted Lists**

> Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.

```java
public class Solution {
    public ListNode mergeTwoLists(ListNode l1, ListNode l2) {
        ListNode pseudoHead = new ListNode(0);

        ListNode iter = pseudoHead;

        while (l1 != null && l2 != null) {
            if (l1.val <= l2.val) {
                iter.next = l1;
                l1 = l1.next;
            } else {
                iter.next = l2;
                l2 = l2.next;
            }
            iter = iter.next;
        }

        if (l1 != null) {
            iter.next = l1;
        }

        if (l2 != null) {
            iter.next = l2;
        }

        return pseudoHead.next;
    }
}
```

# 2 Question-23[★★★★★]

**Merge k Sorted Lists**

> Merge k sorted linked lists and return it as one sorted list. Analyze and describe its complexity.

```java
/**
 * Definition for singly-linked list.
 * public class ListNode {
 * int val;
 * ListNode next;
 * ListNode(int x) { val = x; }
 * }
 */
public class Solution {
    public ListNode mergeKLists(ListNode[] lists) {
        Queue<ListNode> queue = new PriorityQueue<ListNode>(
                new Comparator<ListNode>() {
                    @Override
                    public int compare(ListNode obj1, ListNode obj2) {
                        return obj1.val - obj2.val;
                    }
                }
        );

        for (ListNode head : lists) {
            if (head != null)
                queue.offer(head);
        }

        ListNode pseudoHead = new ListNode(0);

        ListNode iter = pseudoHead;

        while (!queue.isEmpty()) {
            ListNode top = queue.poll();

            if (top.next != null) {
                queue.offer(top.next);
            }

            iter.next = top;
            iter = iter.next;
        }

        return pseudoHead.next;
    }
}
```

# 3 Question-148[★★★★★]

**Sort List**

> Sort a linked list in O(n log n) time using constant space complexity.

```java
public class Solution {
    public ListNode sortList(ListNode head) {
        ListNode pseudoHead = new ListNode(0);
        pseudoHead.next = head;
        mergeSort(pseudoHead, null);
        return pseudoHead.next;
    }

    private void mergeSort(ListNode pseudoHead, ListNode tail) {
        //边界
        if (pseudoHead.next == tail || pseudoHead.next.next == tail) return;

        //链表找中点的方式
        ListNode slow = pseudoHead, fast = pseudoHead;
        while (fast != tail && fast.next != tail) {
            fast = fast.next.next;
            slow = slow.next;
        }

        mergeSort(pseudoHead, slow.next);
        mergeSort(slow, tail);

        merge(pseudoHead, slow, tail);
    }

    private void merge(ListNode pseudoHead, ListNode mid, ListNode tail) {
        ListNode midTail = mid.next;

        ListNode iter1 = pseudoHead.next;
        ListNode iter2 = mid.next;

        ListNode iter = pseudoHead;

        while (iter1 != midTail && iter2 != tail) {
            if (iter1.val <= iter2.val) {
                iter.next = iter1;
                iter1 = iter1.next;
            } else {
                iter.next = iter2;
                iter2 = iter2.next;
            }
            iter = iter.next;
        }

        while (iter1 != midTail) {
            iter.next = iter1;
            iter1 = iter1.next;
            iter = iter.next;
        }

        while (iter2 != tail) {
            iter.next = iter2;
            iter2 = iter2.next;
            iter = iter.next;
        }

        iter.next = tail;
    }
}
```

<!--

# 4 Question-000[★]

____

> 

```java
```

-->
