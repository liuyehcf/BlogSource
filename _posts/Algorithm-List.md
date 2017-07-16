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

# 1 Question [23]

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
