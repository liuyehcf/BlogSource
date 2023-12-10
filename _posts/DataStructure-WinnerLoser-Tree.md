---
title: DataStructure-WinnerLoser-Tree
date: 2021-08-25 15:12:30
tags: 
- 摘录
categories: 
- Data Structure
- Tree
---

# 1 Implementation

A Winner Loser Tree is a specialized data structure that is typically used in sorting and merging algorithms, particularly in scenarios like external sorting or multiway merges. The concept is derived from tournament trees, which are a form of binary tree.

* A Winner Loser Tree is a complete binary tree.
* It has internal nodes and leaf nodes. The leaf nodes usually represent the elements being merged or sorted (like the heads of sorted arrays in multiway merging).
* The tree is essentially a tournament where each internal node represents a match between two elements (the children nodes). In each match (internal node), one element is the "winner" (the smaller or larger one, depending on whether the goal is to sort in ascending or descending order), and the other is the "loser". **And the internal node always keeps the "lower".**
* And we need to record the final "winner" additionally (outside of the tree).

```cpp
#include <algorithm>
#include <iostream>
#include <limits>
#include <random>
#include <vector>

class WinnerLoserTree {
private:
    struct Cmp {
        bool operator()(const int32_t& num1, const int32_t& num2) const { return num1 < num2; }
        static constexpr int32_t INVALID = std::numeric_limits<int32_t>::max();
    };

private:
    const Cmp _cmp;
    const size_t _size;
    // Stores the actual leaf nodes.
    std::vector<int32_t> _leaves;
    // Stores the internal nodes (winners or losers) of the tree, which is actually the indexes of the leaf nodes.
    // Each internal node store the loser of its children.
    std::vector<size_t> _lower_tree;
    // Store the final winner, which is the index of the leaf nodes.
    size_t _winner;

    void _adjust(size_t leaf) {
        // For a complete binary tree, the leaf size is power of two, we have `_size - 1` internal nodes,
        // And here, the leaf nodes and internal nodes are separately stored. So the actual index of the leaf node in the
        // tree should be `leaf + (_size - 1)`, so the parent should be `(leaf + (_size - 1) - 1) / 2`
        //
        // For a non-complete binary tree, the formula still works, but I can't prove it here.
        size_t parent = (leaf + (_size - 1) - 1) / 2;
        while (true) {
            if (leaf < _size && (_lower_tree[parent] == _size || !_cmp(_leaves[leaf], _leaves[_lower_tree[parent]]))) {
                std::swap(leaf, _lower_tree[parent]);
            }
            if (parent == 0) {
                break;
            }
            parent = (parent - 1) / 2;
        }
        _winner = leaf;
    }

public:
    WinnerLoserTree(const std::vector<int32_t>& nums)
            : _cmp({}), _size(nums.size()), _leaves(nums), _lower_tree(_size, _size), _winner(_size) {}

    void build() {
        for (int32_t i = _size - 1; i >= 0; i--) {
            _adjust(i);
        }
    }

    int pop() {
        int32_t winner_num = _leaves[_winner];
        _leaves[_winner] = _cmp.INVALID;
        _adjust(_winner);
        return winner_num;
    }
};

std::vector<int> merge_k_sorte_arrays(const std::vector<std::vector<int>>& arrays) {
    std::vector<int> merged;
    std::vector<int> all_elements;

    for (const auto& arr : arrays) {
        all_elements.insert(all_elements.end(), arr.begin(), arr.end());
    }

    WinnerLoserTree lt(all_elements);
    lt.build();

    for (int i = 0; i < all_elements.size(); i++) {
        merged.push_back(lt.pop());
    }

    return merged;
}

int main() {
    std::default_random_engine e;
    std::uniform_int_distribution<size_t> u_size(1, 16);
    std::uniform_int_distribution<int32_t> u_num(0, 100);

    for (size_t test = 0; test < 100; ++test) {
        std::vector<std::vector<int32_t>> arrays;
        std::vector<int32_t> expected;
        const size_t input_num = u_size(e);

        for (size_t i = 0; i < input_num; ++i) {
            const size_t input_size = u_size(e);
            std::vector<int32_t> input;
            for (size_t j = 0; j < input_size; j++) {
                input.push_back(u_num(e));
            }
            expected.insert(expected.end(), input.begin(), input.end());
            arrays.push_back(std::move(input));
        }

        std::vector<int32_t> result = merge_k_sorte_arrays(arrays);
        std::sort(expected.begin(), expected.end());

        for (size_t i = 0; i < result.size(); ++i) {
            if (result[i] != expected[i]) {
                throw std::logic_error("assertiont failed");
            }
        }
        std::cout << "test(" << test << "): size=" << expected.size() << std::endl;
    }

    return 0;
}
```
