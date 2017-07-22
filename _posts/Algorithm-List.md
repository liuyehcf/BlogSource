---
title: Algorithm List
date: 2017-07-16 21:14:48
tags:
- 原创
categories:
- Job
- Leetcode
---

__目录__

<!-- toc -->
<!--more-->

# 1 Question-21[★★]

__Merge Two Sorted Lists__

> Merge two sorted linked lists and return it as a new list. The new list should be made by splicing together the nodes of the first two lists.

```Java
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

__Merge k Sorted Lists__

> Merge k sorted linked lists and return it as one sorted list. Analyze and describe its complexity.

```Java
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
