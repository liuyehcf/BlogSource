---
title: DataStructure-WinnerLoser-Tree
date: 2021-08-25 15:12:30
tags: 
- 摘录
categories: 
- Data Structure
- Tree
---

# 1 Merge K Sorted Array

```cpp
#include <climits>
#include <iostream>
#include <vector>

class LoserTree {
private:
    std::vector<int> loser_tree;
    std::vector<int> leaves;
    int size;

    void adjust(int leaf) {
        int parent = (leaf + size) / 2;
        while (parent > 0) {
            if (leaf >= 0 && (loser_tree[parent] == -1 || leaves[leaf] > leaves[loser_tree[parent]])) {
                std::swap(leaf, loser_tree[parent]);
            }
            parent /= 2;
        }
        loser_tree[0] = leaf;
    }

public:
    LoserTree(const std::vector<int>& nums) : loser_tree(nums.size(), -1), leaves(nums), size(nums.size()) {}

    void build() {
        for (int i = size - 1; i >= 0; i--) {
            adjust(i);
        }
    }

    int popMin() {
        int min_index = loser_tree[0];
        int min_value = leaves[min_index];
        leaves[min_index] = INT_MAX;
        adjust(min_index);
        return min_value;
    }
};

std::vector<int> merge_k_sorte_arrays(const std::vector<std::vector<int>>& arrays) {
    std::vector<int> merged;
    std::vector<int> all_elements;

    for (const auto& arr : arrays) {
        all_elements.insert(all_elements.end(), arr.begin(), arr.end());
    }

    LoserTree lt(all_elements);
    lt.build();

    for (int i = 0; i < all_elements.size(); i++) {
        merged.push_back(lt.popMin());
    }

    return merged;
}

int main() {
    std::vector<std::vector<int>> arrays = {{1, 4, 7}, {2, 5, 8}, {3, 6, 9}};

    std::vector<int> result = merge_k_sorte_arrays(arrays);

    for (int num : result) {
        std::cout << num << " ";
    }

    return 0;
}
```
