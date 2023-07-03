---
title: DataStructure-Skip-List
date: 2021-07-03 19:11:54
tags: 
- 摘录
categories: 
- Data Structure
- Tree
---

<!--more-->

# 1 Introduction

A Skip List is a data structure that provides an efficient way to search, insert, and delete elements in a sorted list. It is similar to a linked list with multiple layers of forward pointers, allowing for faster search times compared to a simple linked list.

The Skip List consists of nodes arranged in levels, with the bottom level containing all the elements of the list. Each node contains a key-value pair, and the keys are sorted in ascending order. In addition to the next pointer that points to the next node in the same level, each node also has a forward pointer that can skip some nodes and point to a node further down the list.

The forward pointers create a "skipping" effect, enabling efficient search operations. When searching for a specific key, the Skip List starts from the topmost level and moves forward until it finds a node with a key greater than or equal to the target key. It then drops down to the next level and continues the search until it reaches the bottom level.

The probability of including a node in a higher level is determined by a randomized process. Typically, nodes are included in higher levels with a decreasing probability, resulting in a pyramid-like structure of levels.

The benefits of Skip List include:

1. Fast search operations: With multiple levels and skipping pointers, the Skip List provides efficient search times similar to balanced search trees.
1. Simple implementation: Skip Lists are easier to implement compared to other balanced search tree data structures such as AVL trees or red-black trees.
1. Dynamic structure: Skip Lists can easily handle insertions and deletions without the need for rebalancing operations, making them suitable for dynamic data sets.
1. Space efficiency: The space complexity of a Skip List is proportional to the number of elements, making it a viable choice for memory-constrained environments.

Skip Lists are commonly used in various applications, including databases, concurrent data structures, and randomized algorithms that require efficient search operations.

```
Level 3:           Head ----------------------------------------> 50 -------------> NULL
                     |                                            |
Level 2:           Head -------------> 20 ----------------------------------------> 70 -----> NULL
                     |                 |                                             |
Level 1(bottom):   Head ----> 10 ----> 20 ----> 30 ----> 40 ----> 50 ----> 60 ----> 70 ----> 80 ----> 90 ----> NULL
```
