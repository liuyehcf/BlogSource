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
    // This implementation is for k-way merging: each leaf represents one input run's "current element".
    // Internal nodes store the loser leaf index; _loser[0] stores the overall winner (leaf index with min key).
    // Classic loser-tree implementation, works when k is not a power of two.
    // Notes on sentinels:
    // - We use +INF for empty/exhausted runs.
    // - We use a dedicated sentinel leaf with -INF to bootstrap tree building.
    static constexpr int64_t INF = std::numeric_limits<int64_t>::max();
    static constexpr int64_t NEG_INF = std::numeric_limits<int64_t>::min();

private:
    size_t _k;                  // number of real runs (leaves)
    size_t _n;                  // number of leaves in the underlying complete tree (power of two)
    std::vector<int64_t> _keys; // leaf keys, size n+1; the (n)-th is a sentinel (NEG_INF)
    std::vector<size_t> _loser; // size n; index 0 stores winner; 1..n-1 store internal-node losers

    static size_t _next_pow2(size_t x) {
        size_t n = 1;
        while (n < x) {
            n <<= 1;
        }
        return n;
    }

    // Adjust leaf s up to the root.
    void _adjust(size_t s) {
        // Use a complete binary tree with _n leaves (power of two).
        // Parent starts from (s + _n) / 2 and moves up to the root.
        for (size_t t = (s + _n) / 2; t > 0; t /= 2) {
            size_t l = _loser[t];
            // Keep s as the smaller one (winner) to move upward; loser[t] stores the larger one (loser).
            // If values tie, the smaller index wins to make the result deterministic.
            if (_keys[s] > _keys[l] || (_keys[s] == _keys[l] && s > l)) {
                std::swap(s, _loser[t]);
            }
        }
        _loser[0] = s;
    }

public:
    explicit WinnerLoserTree(const std::vector<int32_t>& keys) : _k(keys.size()), _n(_next_pow2(_k)) {
        _keys.assign(_n, INF);
        for (size_t i = 0; i < _k; ++i) {
            _keys[i] = static_cast<int64_t>(keys[i]);
        }
        // Sentinel at index n.
        _keys.push_back(NEG_INF);

        _loser.assign(_n, _n);
        // Initialize losers.
        std::fill(_loser.begin(), _loser.end(), _n);

        // Build: adjust from back to front.
        for (int i = static_cast<int>(_n) - 1; i >= 0; --i) {
            _adjust(static_cast<size_t>(i));
        }
    }

    size_t winner_index() const { return _k == 0 ? 0 : _loser[0]; }
    int32_t winner_value() const {
        const size_t w = winner_index();
        if (w >= _n) {
            return static_cast<int32_t>(INF);
        }
        return static_cast<int32_t>(_keys[w]);
    }

    // Replace the key of one run (leaf) and re-adjust.
    void replace(size_t leaf, int32_t new_value) {
        _keys[leaf] = static_cast<int64_t>(new_value);
        _adjust(leaf);
    }

    void replace_inf(size_t leaf) {
        _keys[leaf] = INF;
        _adjust(leaf);
    }
};

std::vector<int32_t> merge_k_sorte_arrays(const std::vector<std::vector<int32_t>>& arrays) {
    const size_t k = arrays.size();
    std::vector<int32_t> merged;
    if (k == 0) {
        return merged;
    }

    std::vector<size_t> pos(k, 0);
    std::vector<int32_t> init_keys;
    init_keys.reserve(k);

    size_t total = 0;
    for (size_t i = 0; i < k; ++i) {
        total += arrays[i].size();
        if (arrays[i].empty()) {
            init_keys.push_back(std::numeric_limits<int32_t>::max());
        } else {
            init_keys.push_back(arrays[i][0]);
        }
    }

    WinnerLoserTree lt(init_keys);
    merged.reserve(total);

    for (size_t out = 0; out < total; ++out) {
        const size_t w = lt.winner_index();
        const int32_t v = lt.winner_value();
        merged.push_back(v);

        // Consume the current element from run w, advance its cursor, and replace the leaf key.
        ++pos[w];
        if (pos[w] < arrays[w].size()) {
            lt.replace(w, arrays[w][pos[w]]);
        } else {
            lt.replace_inf(w);
        }
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
            // k-way merge requires each run to be sorted.
            std::sort(input.begin(), input.end());
            expected.insert(expected.end(), input.begin(), input.end());
            arrays.push_back(std::move(input));
        }

        std::vector<int32_t> result = merge_k_sorte_arrays(arrays);
        std::sort(expected.begin(), expected.end());

        for (size_t i = 0; i < result.size(); ++i) {
            if (result[i] != expected[i]) {
                throw std::logic_error("assertion failed");
            }
        }
        std::cout << "test(" << test << "): size=" << expected.size() << std::endl;
    }

    return 0;
}
```
