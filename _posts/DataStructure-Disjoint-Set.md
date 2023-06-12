---
title: DataStructure-Disjoint-Set
date: 2017-08-09 20:11:02
tags: 
- 原创
categories: 
- Algorithm
- Graph
---

**阅读更多**

<!--more-->

# 1 并查集定义

Union-Find data structure, also known as Disjoint-set data structure

其实并查集顾名思义就是有`合并集合`和`查找集合`两种操作的关于数据结构的一种算法

## 1.1 代表元

用集合中的某个元素来代表这个集合，该元素称为集合的代表元。一个集合内的所有元素组织成以`代表元`为根的树形结构

## 1.2 节点的定义

```java
class Node{
    Node parent;
    int val;
}
```

# 2 查找

给定某个元素，如何确定该元素位于哪个集合？只需要沿着parent往上直至根节点，即代表元

```java
class Node {
    Node parent;
    int val;

    Node getRoot() {
        Node n = this;
        while (n.parent != null) {
            n = n.parent;
        }
        return n;
    }
}
```

# 3 合并

如果两个节点位于两个集合中，现在需要联通这两个节点，那么只需要对这两个集合进行合并即可。合并的过程就是将某个集合的代表元的parent字段赋值为另一个集合的代表元

```java
class Node {
    Node parent;
    int val;

    Node getRoot() {
        Node n = this;
        while (n.parent != null) {
            n = n.parent;
        }
        return n;
    }

    Node union(Node root){
        root.parent = this;
    }
}
```

# 4 查找的优化

为了提高查找的效率，可以将一个集合中所有非代表元的节点的parent字段全部设置为代表元即可。这一做法称为路径压缩

在合并过程中，假设集合A和集合B，将集合B合并到集合A中。为了保持这一个性质，必须将集合B中的所有节点的parent字段设置为A的代表元。为了方便遍历，集合B的代表元需要保存一下所有的节点

# 5 Example Code

```cpp
#include <iostream>
#include <unordered_map>
#include <vector>

template <typename T>
class UnionFindSet {
private:
    std::unordered_map<T, T> parents;
    std::unordered_map<T, T> ranks;

public:
    UnionFindSet() = default;

    T find_root(T element) {
        if (parents[element] != element) {
            parents[element] = find_root(parents[element]); // Path compression
        }
        return parents[element];
    }

    void add(T element) {
        parents[element] = element;
        ranks[element] = 0;
    }

    void union_of(T element1, T element2) {
        T root1 = find_root(element1);
        T root2 = find_root(element2);

        if (root1 == root2) {
            // Already in the same set
            return;
        }

        // Union by rank (attach the tree with lower rank to the one with higher rank)
        if (ranks[root1] < ranks[root2]) {
            parents[root1] = root2;
        } else if (ranks[root1] > ranks[root2]) {
            parents[root2] = root1;
        } else {
            parents[root2] = root1;
            ranks[root1]++;
        }
    }
};

int main() {
    UnionFindSet<int32_t> uf;

    for (int32_t i = 1; i <= 10; i++) {
        uf.add(i);
    }

    auto print = [&]() {
        std::cout << "-------------------------------" << std::endl;
        for (int32_t i = 1; i <= 10; i++) {
            std::cout << "element '" << i << "''s root is: " << uf.find_root(i) << std::endl;
        }
    };

    print();

    uf.union_of(1, 2);
    uf.union_of(3, 4);
    uf.union_of(5, 6);
    uf.union_of(7, 8);
    uf.union_of(9, 10);

    print();

    uf.union_of(2, 3);
    uf.union_of(4, 5);
    uf.union_of(6, 7);
    uf.union_of(8, 9);

    print();

    return 0;
}
```

# 6 对应的习题

1. Leetcode-130
1. Leetcode-200

# 7 参考

* [傻子都能看懂的并查集入门](https://segmentfault.com/a/1190000004023326)
