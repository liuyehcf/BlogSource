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
#include <optional>
#include <random>
#include <vector>

class LoserTree {
private:
    // This implementation is for k-way merging: each leaf represents one input run's "current element".
    // Internal nodes store the loser leaf index; _losers[_num_pow2 - 1] stores the overall winner
    // (leaf index with the minimum key).
    // Classic loser-tree implementation, works when k is not a power of two.
    // No +/-INF sentinels are used. Instead, LeafNode has state flags:
    // - uninitialized: used by an internal sentinel leaf to bootstrap tree building.
    // - exhausted: the run is finished and should always lose against non-exhausted runs.

    struct LeafNode {
        int32_t value;
        bool uninitialized;
        bool exhausted;

        LeafNode() : value(0), uninitialized(true), exhausted(false) {}
        LeafNode(int32_t value) : value(value), uninitialized(true), exhausted(false) {}
        LeafNode(int32_t value_, bool uninitialized_, bool exhausted_)
                : value(value_), uninitialized(uninitialized_), exhausted(exhausted_) {}
    };

private:
    size_t _num_runs; // number of real runs (leaves)
    size_t _num_pow2; // number of leaves in the underlying complete tree (power of two)
    std::vector<LeafNode> _leaf_nodes;
    std::vector<size_t> _losers; // size n; 0...n-2 store internal-node losers, (n-1)-th stores winner

    static size_t _next_pow2(size_t x) {
        size_t n = 1;
        while (n < x) {
            n <<= 1;
        }
        return n;
    }

    // Return true if leaf a is worse (should lose) than leaf b.
    // Order: exhausted (worst) > normal-by-value > uninitialized sentinel (best, only for bootstrapping).
    bool _is_greater(size_t a, size_t b) const {
        const LeafNode& A = _leaf_nodes[a];
        const LeafNode& B = _leaf_nodes[b];

        // Uninitialized leaf is a special sentinel used only to bootstrap building.
        // It should be considered smaller (better) than any normal/exhausted leaf.
        if (A.uninitialized != B.uninitialized) {
            return !A.uninitialized && B.uninitialized;
        }

        // Exhausted leaf behaves like +infinity (always worse than non-exhausted).
        if (A.exhausted != B.exhausted) {
            return A.exhausted && !B.exhausted;
        }

        // Both are normal leaves: compare by value.
        if (!A.exhausted && !A.uninitialized) {
            if (A.value != B.value) {
                return A.value > B.value;
            }
        }
        // Tie-breaker: larger index loses.
        return a > b;
    }

    // Adjust leaf to the root.
    // leaf_idx starts from 0.
    void _adjust(size_t leaf_idx) {
        // Special case: only one leaf, no internal nodes.
        if (_num_pow2 == 1) {
            _losers[0] = leaf_idx;
            return;
        }

        // Use a complete binary tree with _num_pow2 leaves.
        // Internal nodes use 0-based heap indexing: root=0, children=2*i+1/2*i+2.
        // The first match node for a leaf is: (leaf_idx + _num_pow2) / 2 - 1.
        // Then we go upward using parent = (idx - 1) / 2, and we MUST include idx==0.
        // Inner:          0
        // Inner:     1         2
        // Leaf :  0    1     2    3
        //   (0 + 4) / 2 - 1 = 1
        //   (1 + 4) / 2 - 1 = 1
        //   (2 + 4) / 2 - 1 = 2
        //   (3 + 4) / 2 - 1 = 2
        size_t parent_idx = (leaf_idx + _num_pow2) / 2 - 1;
        while (true) {
            size_t parent_value = _losers[parent_idx];
            // Keep leaf_idx as the smaller one (winner) to move upward; loser[parent_idx] stores the larger one (loser).
            // If values tie, the smaller index wins to make the result deterministic.
            if (_is_greater(leaf_idx, parent_value)) {
                std::swap(leaf_idx, _losers[parent_idx]);
            }

            if (parent_idx == 0) {
                break;
            }
            parent_idx = (parent_idx - 1) / 2;
        }
        _losers[_num_pow2 - 1] = leaf_idx;
    }

public:
    explicit LoserTree(const std::vector<std::optional<int32_t>>& keys)
            : _num_runs(keys.size()), _num_pow2(_next_pow2(_num_runs)) {
        // Allocate an extra sentinel leaf at index _num_pow2.
        _leaf_nodes.assign(_num_pow2 + 1, LeafNode());

        // Initialize all real/padded leaves as exhausted.
        for (size_t i = 0; i < _num_pow2; ++i) {
            _leaf_nodes[i] = LeafNode(0, false, true);
        }
        for (size_t i = 0; i < _num_runs; ++i) {
            const auto& key = keys[i];
            if (key.has_value()) {
                _leaf_nodes[i] = LeafNode(key.value(), false, false);
            } else {
                _leaf_nodes[i] = LeafNode(0, false, true);
            }
        }

        // Sentinel leaf used only for bootstrapping the build.
        _leaf_nodes[_num_pow2] = LeafNode(0, true, false);

        // Initialize losers to the sentinel leaf.
        _losers.assign(_num_pow2, _num_pow2);

        // Build: adjust from front to back.
        for (size_t i = 0; i < _num_pow2; ++i) {
            _adjust(i);
        }
    }

    size_t winner_index() const { return _losers[_num_pow2 - 1]; }
    int32_t winner_value() const {
        const size_t idx = winner_index();
        if (idx >= _num_pow2 || _leaf_nodes[idx].exhausted || _leaf_nodes[idx].uninitialized) {
            throw std::logic_error("invalid winner");
        }
        return _leaf_nodes[idx].value;
    }

    // Replace the key of one run (leaf) and re-adjust.
    void replace(size_t leaf, int32_t new_value) {
        _leaf_nodes[leaf] = LeafNode(new_value, false, false);
        _adjust(leaf);
    }

    void replace_inf(size_t leaf) {
        _leaf_nodes[leaf] = LeafNode(0, false, true);
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
    std::vector<std::optional<int32_t>> init_keys;
    init_keys.reserve(k);

    size_t total = 0;
    for (size_t i = 0; i < k; ++i) {
        total += arrays[i].size();
        if (arrays[i].empty()) {
            init_keys.push_back(std::nullopt);
        } else {
            init_keys.push_back(arrays[i][0]);
        }
    }

    LoserTree lt(init_keys);

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
