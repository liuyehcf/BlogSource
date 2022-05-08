---
title: Cpp-排坑日志
date: 2021-09-06 10:59:52
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 莫名crash

下面这段逻辑可以复现该问题，大致含义如下：

* `Partitioner`用于存储一些键值对，且允许`key`为空。当`key`为空时，存储到`_null_key_value`中
* `Partitioner::accept`用于遍历所有已存储的数据，包括`_hash_map`和`_null_key_value`，且遍历过程满足如下要求
    * `consumer`可通过返回值自行决定是否继续遍历
    * 若`consumer`中断遍历，则需要能够从上一次迭代的位置继续遍历

```cpp
#include <any>
#include <functional>
#include <iostream>
#include <string>
#include <unordered_map>
#include <utility>
#include <vector>

// This class is used to defer a function when this object is deconstruct
template <class DeferFunction>
class DeferOp {
public:
    explicit DeferOp(DeferFunction func) : _func(std::move(func)) {}

    ~DeferOp() { _func(); };

private:
    DeferFunction _func;
};

class Partitioner {
public:
    void offer(const int32_t key, const std::string& value) { _hash_map[key].push_back(value); }
    void offer_for_null(const std::string& value) { _null_key_value.push_back(value); }
    void accept(const std::function<bool(int, const std::string)>& consumer) {
        _fetch_from_hash_map(consumer);
        _fetch_from_null_key_value(consumer);
    }

private:
    bool _fetch_from_hash_map(const std::function<bool(int, const std::string)>& consumer) {
        if (_hash_map_eos) {
            return true;
        }
        if (!_partition_it.has_value()) {
            _partition_it = _hash_map.begin();
            _partition_idx = 0;
        }

        using PartitionIterator = typename decltype(_hash_map)::iterator;
        PartitionIterator partition_it = std::any_cast<PartitionIterator>(_partition_it);
        PartitionIterator partition_end = _hash_map.end();

        using ItemIterator = typename std::vector<std::string>::iterator;
        ItemIterator chunk_it;
        DeferOp defer([&]() {
            if (partition_it == partition_end) {
                _hash_map_eos = true;
                _partition_it.reset();
                _chunk_it.reset();
            } else {
                _partition_it = partition_it;
                _chunk_it = chunk_it;
            }
        });

        while (partition_it != partition_end) {
            std::vector<std::string>& chunks = partition_it->second;
            if (!_chunk_it.has_value()) {
                _chunk_it = chunks.begin();
            }

            chunk_it = std::any_cast<ItemIterator>(_chunk_it);
            ItemIterator chunk_end = chunks.end();

            while (chunk_it != chunk_end) {
                if (!consumer(_partition_idx, *chunk_it++)) {
                    return false;
                }
            }

            // Move to next partition
            if (chunk_it == chunk_end) {
                ++partition_it;
                ++_partition_idx;
                _chunk_it.reset();
            }
        }
    }

    bool _fetch_from_null_key_value(const std::function<bool(int, const std::string)>& consumer) {
        if (_null_key_eos) {
            return true;
        }

        std::vector<std::string>& chunks = _null_key_value;

        if (!_chunk_it.has_value()) {
            _chunk_it = chunks.begin();
        }

        using ChunkIterator = typename std::vector<std::string>::iterator;
        ChunkIterator chunk_it = std::any_cast<ChunkIterator>(_chunk_it);
        ChunkIterator chunk_end = chunks.end();

        DeferOp defer([&]() {
            if (chunk_it == chunk_end) {
                _null_key_eos = true;
                _chunk_it.reset();
            } else {
                _chunk_it = chunk_it;
            }
        });

        while (chunk_it != chunk_end) {
            // Because we first fetch chunks from hash_map, so the _partition_idx here
            // is already set to hash_map.size()
            if (!consumer(_partition_idx, *chunk_it++)) {
                return false;
            }
        }
    }

private:
    std::unordered_map<int32_t, std::vector<std::string>> _hash_map;
    std::vector<std::string> _null_key_value;

    std::any _partition_it;
    std::any _chunk_it;
    int32_t _partition_idx = -1;
    bool _hash_map_eos = false;
    bool _null_key_eos = false;
};

int main() {
    Partitioner partitioner;
    for (int i = 0; i < 10; i++) {
        std::string content;
        content.append("null-key: ");
        content.append(std::to_string(i));
        partitioner.offer_for_null(content);
    }
    for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 10; j++) {
            std::string content;
            content.append("key: ");
            content.append(std::to_string(j));
            partitioner.offer(i, content);
        }
    }

    partitioner.accept([](const int32_t partition_id, const std::string& content) {
        std::cout << "partition_id=" << partition_id << ", content=" << content << std::endl;
        return true;
    });

    return 0;
}
```

分别用`-O0`和`-O3`对上述代码进行编译

* `-O0`：可以正常执行
* `-O3`：crash

```sh
gcc -o main main.cpp -O0 -lstdc++ -std=gnu++17 -Wall
./main

gcc -o main main.cpp -O3 -lstdc++ -std=gnu++17 -Wall
./main
```

**错误原因：编译上述代码时，编译器已经提示了，就是`_fetch_from_hash_map`和`_fetch_from_null_key_value`这两个函数，缺少返回值。导致在内联的时候出现了逻辑性的问题**

* 同样逻辑的代码在项目中并未提示缺少返回值（项目中用到了模板，逻辑更复杂，编译器并未分析出来）
* core的堆栈也十分奇怪，要么是挂在`std::function`上，要么挂在`std::any::has_value`上，十分具有迷惑性