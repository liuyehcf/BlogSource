---
title: DataStructure-Heap
date: 2017-07-14 19:45:40
tags: 
- 原创
categories: 
- Data Structure
- Heap
---

**阅读更多**

<!--more-->

# 1 Demo

```cpp
#include <algorithm>
#include <iostream>
#include <random>
#include <stdexcept>
#include <vector>

template <bool IsMaxHeap>
struct HeapCmp {
    auto operator()(const int32_t& num1, const int32_t& num2) const {
        if constexpr (IsMaxHeap) {
            return num1 >= num2;
        } else {
            return num1 <= num2;
        }
    }
};

template <bool IsMaxHeap, typename Cmp = HeapCmp<IsMaxHeap>>
class Heap {
private:
public:
    Heap(std::vector<int32_t> nums) : _nums(std::move(nums)), _size(_nums.size()) { _build(); }

    bool empty() { return _size == 0; }
    int32_t pop() {
        _assert(_size >= 1);
        int32_t res = _nums[0];

        _nums[0] = _nums[_size - 1];
        _size -= 1;
        _adjust(0);
        _check();

        return res;
    }

private:
    void _assert(bool flag) {
        if (!flag) {
            throw std::logic_error("asssertion failed");
        }
    }
    void _build() {
        for (int i = (_size >> 1); i >= 0; i--) {
            _adjust(i);
        }
        _check();
    }
    void _adjust(size_t i) {
        while (i < _size) {
            size_t child1 = i * 2 + 1;
            size_t child2 = i * 2 + 2;
            if (child1 >= _size) {
                return;
            }
            size_t next = i;
            if (_cmp(_nums[child1], _nums[next])) {
                next = child1;
            }
            if (child2 < _size && _cmp(_nums[child2], _nums[next])) {
                next = child2;
            }
            if (next == i) {
                return;
            }

            std::swap(_nums[i], _nums[next]);
            i = next;
        }
    }
    void _check() {
        for (size_t i = 0; i < _size; ++i) {
            size_t child1 = i * 2 + 1;
            size_t child2 = i * 2 + 2;
            _assert(child1 >= _size || _cmp(_nums[i], _nums[child1]));
            _assert(child2 >= _size || _cmp(_nums[i], _nums[child2]));
        }
    }

    Cmp _cmp;
    std::vector<int32_t> _nums;
    size_t _size;
};

int main() {
    std::default_random_engine e;
    std::uniform_int_distribution<int32_t> u32(0, 100);
    for (size_t size = 0; size < 100; ++size) {
        std::cout << "check size=" << size << std::endl;
        std::vector<int32_t> nums;
        for (size_t i = 0; i < size; ++i) {
            nums.emplace_back(u32(e));
        }
        {
            Heap<true> max_heap(nums);
            std::vector<int32_t> ordered;
            while (!max_heap.empty()) {
                ordered.push_back(max_heap.pop());
            }
            std::vector<int32_t> expected(nums);
            std::sort(expected.begin(), expected.end(),
                      [](const int32_t& num1, const int32_t& num2) { return num1 > num2; });
            for (int i = 0; i < size; ++i) {
                if (ordered[i] != expected[i]) {
                    throw std::logic_error("check failed");
                }
            }
        }
        {
            Heap<false> min_heap(nums);
            std::vector<int32_t> ordered;
            while (!min_heap.empty()) {
                ordered.push_back(min_heap.pop());
            }
            std::vector<int32_t> expected(nums);
            std::sort(expected.begin(), expected.end());
            for (int i = 0; i < size; ++i) {
                if (ordered[i] != expected[i]) {
                    throw std::logic_error("check failed");
                }
            }
        }
    }
}
```
