---
title: Cpp-Standard-Library
date: 2021-09-06 10:54:02
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

[C++ Standard Library headers](https://en.cppreference.com/w/cpp/header)

# 1 algorithm

[Standard library header <algorithm>](https://en.cppreference.com/w/cpp/header/algorithm)

## 1.1 Modifying Sequence Operations

1. `std::copy`
1. `std::copy_if`
1. `std::copy_n`
1. `std::copy_backward`
1. `std::move`
1. `std::move_backward`
1. `std::fill`
1. `std::fill_n`
1. `std::transform`
1. `std::generate`
1. `std::generate_n`
1. `std::remove`
1. `std::remove_if`
1. `std::remove_copy`
1. `std::remove_copy_if`
1. `std::replace`
1. `std::replace_if`
1. `std::replace_copy`
1. `std::replace_copy_if`
1. `std::swap`
1. `std::swap_ranges`
1. `std::iter_swap`
1. `std::reverse`
1. `std::reverse_copy`
1. `std::rotate`
1. `std::rotate_copy`
1. `std::shift_left`
1. `std::shift_right`
1. `std::random_shuffle`
1. `std::shuffle`
1. `std::sample`
1. `std::unique`
1. `std::unique_copy`

### 1.1.1 std::copy

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int32_t> source{1, 3, 5, 7, 9};

    std::vector<int32_t> dest1;
    std::copy(source.begin(), source.end(), std::back_inserter(dest1));
    std::copy(dest1.begin(), dest1.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    std::vector<int32_t> dest2;
    dest2.resize(source.size());
    std::copy(source.begin(), source.end(), dest2.begin());
    std::copy(dest2.begin(), dest2.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    return 0;
}
```

### 1.1.2 std::transform

```cpp
#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <numeric>
#include <vector>

int main() {
    {
        std::vector<std::string> strs{"hello,", " Jack!", " How are you?"};
        std::vector<size_t> sizes;
        std::transform(strs.begin(), strs.end(), std::back_inserter(sizes),
                       [](const std::string& str) { return str.size(); });
        std::string size_str =
                std::accumulate(sizes.begin(), sizes.end(), std::string(), [](const std::string& str, size_t size) {
                    return str.empty() ? std::to_string(size) : str + "," + std::to_string(size);
                });

        std::cout << size_str << std::endl;
    }

    {
        struct Foo {
            const std::string name;
            const int value;
        };
        std::vector<Foo> foos;
        foos.emplace_back(Foo{"foo1", 1});
        foos.emplace_back(Foo{"foo2", 2});
        foos.emplace_back(Foo{"foo3", 3});
        foos.emplace_back(Foo{"foo4", 4});
        foos.emplace_back(Foo{"foo5", 5});

        std::map<std::string, int> name_to_value;
        std::transform(foos.begin(), foos.end(), std::inserter(name_to_value, name_to_value.end()),
                       [](const Foo& foo) { return std::make_pair(foo.name, foo.value); });

        for (const auto& [name, value] : name_to_value) {
            std::cout << name << " -> " << value << std::endl;
        }
    }

    return 0;
}
```

### 1.1.3 std::remove_if

Used to move the elements in the container that meet the condition to the end, and return an iterator pointing to the beginning of these elements, usually used together with `erase`.

```cpp
#include <algorithm>
#include <iostream>
#include <vector>

int main() {
    std::vector<int> container{1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    container.erase(std::remove_if(container.begin(), container.end(), [](int v) { return v % 2 != 0; }),
                    container.end());
    for (const auto& v : container) {
        std::cout << v << std::endl;
    }
    return 0;
}
```

## 1.2 Sorting operations

1. `std::is_sorted`
1. `std::is_sorted_until`
1. `std::sort`
1. `std::partial_sort`
1. `std::partial_sort_copy`
1. `std::stable_sort`
1. `std::nth_element`
1. `std::merge`
1. `std::inplace_merge`

### 1.2.1 std::sort

**Note: `comparator` should return `bool`, not an integer**

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int32_t> nums{1, 4, 2, 5, 7};

    std::sort(nums.begin(), nums.end());
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    std::sort(nums.begin(), nums.end(), [](int32_t i, int32_t j) { return j < i; });
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    std::vector<std::vector<int>> intervals;
    intervals.emplace_back(std::vector<int>{1, 3});
    intervals.emplace_back(std::vector<int>{2, 6});
    intervals.emplace_back(std::vector<int>{8, 10});
    intervals.emplace_back(std::vector<int>{15, 18});

    // Get wrong order if using i1[0] - i2[0], should be i1[0] < i2[0] here
    std::sort(intervals.begin(), intervals.end(), [](auto& i1, auto& i2) { return i1[0] - i2[0]; });

    std::cout << intervals[0][0] << std::endl;

    return 0;
}
```

### 1.2.2 std::merge

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int32_t> left{1, 3, 5, 7, 9};
    std::vector<int32_t> right{2, 4, 6, 8, 10};

    std::vector<int32_t> dest1;
    std::merge(left.begin(), left.end(), right.begin(), right.end(), std::back_inserter(dest1));
    std::copy(dest1.begin(), dest1.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    std::vector<int32_t> dest2;
    dest2.resize(left.size() + right.size());
    std::merge(left.begin(), left.end(), right.begin(), right.end(), dest2.begin());
    std::copy(dest2.begin(), dest2.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    return 0;
}
```

### 1.2.3 std::inplace_merge

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int32_t> nums{2, 4, 6, 8, 10, 1, 3, 5, 7, 9};

    std::vector<int32_t> dest;
    std::inplace_merge(nums.begin(), nums.begin() + 5, nums.end());
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int32_t>(std::cout, ","));
    std::cout << std::endl;

    return 0;
}
```

## 1.3 Non-modifying Sequence Operations

1. `std::all_of`
1. `std::any_of`
1. `std::none_of`
1. `std::for_each`
1. `std::for_each_n`
1. `std::count`
1. `std::count_if`
1. `std::mismatch`
1. `std::find`
1. `std::find_if`
1. `std::find_if_not`
1. `std::find_end`
1. `std::find_first_of`
1. `std::adjacent_find`
1. `std::search`
1. `std::search_n`
1. `std::max_element`：return iterator of the max element
1. `std::min_element`：return iterator of the min element
1. `std::max`
1. `std::min`
 
### 1.3.1 std::for_each

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <vector>

int main() {
    std::vector<int32_t> nums{1, 3, 5, 7, 9};

    std::for_each(nums.begin(), nums.end(), [](int32_t num) { std::cout << num << ", "; });

    return 0;
}
```

## 1.4 Binary Search Operations (on sorted ranges)

1. `std::lower_bound(first, last, value, comp)`: Searches for the first element in the partitioned range `[first, last)` which is not ordered before value.
1. `std::upper_bound`: Searches for the first element in the partitioned range `[first, last)` which is ordered after value.
1. `std::binary_search`
1. `std::equal_range`

### 1.4.1 std::lower_bound & std::upper_bound

**Case 1:**

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int> nums{0, 1, 2, 3, 3, 3, 4, 4, 5, 10, 11, 13};
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int>(std::cout, ","));
    std::cout << std::endl;

    auto find_lower_bound = [&nums](int target) {
        std::cout << "the lower_bound of " << target << " is: ";
        auto it = std::lower_bound(nums.begin(), nums.end(), target);
        if (it == nums.end()) {
            std::cout << "nullptr" << std::endl;
        } else {
            std::cout << *it << std::endl;
        }
    };

    for (int i = -1; i < 15; ++i) {
        find_lower_bound(i);
    }

    return 0;
}
```

Output:

```
0,1,2,3,3,3,4,4,5,10,11,13,
the lower_bound of -1 is: 0
the lower_bound of 0 is: 0
the lower_bound of 1 is: 1
the lower_bound of 2 is: 2
the lower_bound of 3 is: 3
the lower_bound of 4 is: 4
the lower_bound of 5 is: 5
the lower_bound of 6 is: 10
the lower_bound of 7 is: 10
the lower_bound of 8 is: 10
the lower_bound of 9 is: 10
the lower_bound of 10 is: 10
the lower_bound of 11 is: 11
the lower_bound of 12 is: 13
the lower_bound of 13 is: 13
the lower_bound of 14 is: nullptr
```

**Case 2:**

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int> nums{0, 1, 2, 3, 3, 3, 4, 4, 5, 10, 11, 13};
    std::copy(nums.begin(), nums.end(), std::ostream_iterator<int>(std::cout, ","));
    std::cout << std::endl;

    auto find_upper_bound = [&nums](int target) {
        std::cout << "the upper_bound of " << target << " is: ";
        auto it = std::upper_bound(nums.begin(), nums.end(), target);
        if (it == nums.end()) {
            std::cout << "nullptr" << std::endl;
        } else {
            std::cout << *it << std::endl;
        }
    };

    for (int i = -1; i < 15; ++i) {
        find_upper_bound(i);
    }

    return 0;
}
```

Output:

```
0,1,2,3,3,3,4,4,5,10,11,13,
the upper_bound of -1 is: 0
the upper_bound of 0 is: 1
the upper_bound of 1 is: 2
the upper_bound of 2 is: 3
the upper_bound of 3 is: 4
the upper_bound of 4 is: 5
the upper_bound of 5 is: 10
the upper_bound of 6 is: 10
the upper_bound of 7 is: 10
the upper_bound of 8 is: 10
the upper_bound of 9 is: 10
the upper_bound of 10 is: 11
the upper_bound of 11 is: 13
the upper_bound of 12 is: 13
the upper_bound of 13 is: nullptr
the upper_bound of 14 is: nullptr
```

**Case 3:**

```cpp
#include <algorithm>
#include <iostream>
#include <list>
#include <vector>

struct Value {
    size_t pos;
    int32_t val;
    Value(const size_t pos, const int32_t val) : pos(pos), val(val) {}

    static bool comp(const Value& v1, const Value& v2) { return v1.val < v2.val; }
};

std::ostream& operator<<(std::ostream& os, const Value& value) {
    os << "(" << value.pos << ", " << value.val << ")";
    return os;
}

int main() {
    auto lower_bound_insert = [](std::list<Value>& l, const Value& value) {
        l.insert(std::lower_bound(l.begin(), l.end(), value, Value::comp), value);
    };
    auto upper_bound_insert = [](std::list<Value>& l, const Value& value) {
        l.insert(std::upper_bound(l.begin(), l.end(), value, Value::comp), value);
    };

    {
        std::list<Value> l;
        lower_bound_insert(l, {1, 1});
        lower_bound_insert(l, {2, 1});
        lower_bound_insert(l, {3, 2});
        lower_bound_insert(l, {4, 2});
        lower_bound_insert(l, {5, 2});
        lower_bound_insert(l, {6, 2});
        lower_bound_insert(l, {7, 3});
        lower_bound_insert(l, {8, 4});
        std::copy(l.begin(), l.end(), std::ostream_iterator<Value>(std::cout, ","));
        std::cout << std::endl;
    }

    {
        std::list<Value> l;
        upper_bound_insert(l, {1, 1});
        upper_bound_insert(l, {2, 1});
        upper_bound_insert(l, {3, 2});
        upper_bound_insert(l, {4, 2});
        upper_bound_insert(l, {5, 2});
        upper_bound_insert(l, {6, 2});
        upper_bound_insert(l, {7, 3});
        upper_bound_insert(l, {8, 4});
        std::copy(l.begin(), l.end(), std::ostream_iterator<Value>(std::cout, ","));
        std::cout << std::endl;
    }

    return 0;
}
```

Output:

```
(2, 1),(1, 1),(6, 2),(5, 2),(4, 2),(3, 2),(7, 3),(8, 4),
(1, 1),(2, 1),(3, 2),(4, 2),(5, 2),(6, 2),(7, 3),(8, 4),
```

## 1.5 Set Operations

1. `std::set_intersection`
1. `std::set_union`
1. `std::set_difference`

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

int main() {
    std::vector<int32_t> nums1{1, 2, 3, 4, 5, 6};
    std::vector<int32_t> nums2{3, 4, 5, 6, 7, 8};

    std::vector<int32_t> intersection_res;
    std::vector<int32_t> union_res;
    std::vector<int32_t> difference_res;

    std::set_intersection(nums1.begin(), nums1.end(), nums2.begin(), nums2.end(), std::back_inserter(intersection_res));
    std::set_union(nums1.begin(), nums1.end(), nums2.begin(), nums2.end(), std::back_inserter(union_res));
    std::set_difference(nums1.begin(), nums1.end(), nums2.begin(), nums2.end(), std::back_inserter(difference_res));

    auto print = [](const std::string& name, const std::vector<int32_t>& nums) {
        std::cout << name << ": ";
        std::copy(nums.begin(), nums.end(), std::ostream_iterator<int32_t>(std::cout, ","));
        std::cout << std::endl;
    };

    print("intersection", intersection_res);
    print("union", union_res);
    print("difference", difference_res);

    return 0;
}
```

# 2 any

**`std::any` is used to hold objects of any type, similar to `java.lang.Object` in Java**

* `std::any_cast` is used to convert an `any` object to the corresponding type. If the type is incorrect, it will throw `std::bad_any_cast`

**Its implementation is also straightforward: it allocates memory on the heap and stores the copied object in that allocated memory**

```cpp
#include <any>
#include <iostream>

struct Object {
    Object() { std::cout << "Object()" << std::endl; }
    Object(const Object& obj) { std::cout << "Object(const Object& obj)" << std::endl; }
    Object(Object&& obj) { std::cout << "Object(Object&& obj)" << std::endl; }
    Object operator=(const Object&) = delete;
    Object operator=(Object&&) = delete;
};

int main() {
    Object obj1;
    Object obj2;

    std::cout << "declare any" << std::endl;
    std::any a1 = obj1;
    std::any a2 = std::move(obj2);

    std::cout << "any_cast" << std::endl;
    [[maybe_unused]] Object obj3 = std::any_cast<Object>(a1);

    std::cout << "any_cast reference" << std::endl;
    [[maybe_unused]] Object& obj4 = std::any_cast<Object&>(a2);

    return 0;
}
```

# 3 atomic

The first parameter of the `compare_exchange_strong(T& expected_value, T new_value)` method is an lvalue

* When the current value is equal to the expected value `expected_value`, it sets the current value to `new_value` and returns true
* When the current value is not equal to the expected value `expected_value`, it updates the expected value to the current value and returns false (this makes looping more convenient, otherwise you would have to read it again manually)

```c++
std::atomic_bool flag = false;
bool expected = false;

std::cout << "result: " << flag.compare_exchange_strong(expected, true)
              << ", flag: " << flag << ", expected: " << expected << std::endl;
std::cout << "result: " << flag.compare_exchange_strong(expected, true)
              << ", flag: " << flag << ", expected: " << expected << std::endl;
```

```
result: 1, flag: 1, expected: 0
result: 0, flag: 1, expected: 1
```

**The `compare_exchange_weak(T& expected_value, T new_value)` method is basically the same as the `strong` version, with the only difference being that the `weak` version allows occasional spurious failures (returning false even when they are equal). In most cases, such failures are acceptable and the `weak` version usually has better performance than the `strong` version.**

## 3.1 std::memory_order

This is an enum type that contains 6 enumerators.

* `memory_order_relaxed`
* `memory_order_consume`
* `memory_order_acquire`
* `memory_order_release`
* `memory_order_acq_rel`
* `memory_order_seq_cst`

### 3.1.1 Sequential Consistency Ordering

`memory_order_seq_cst` belongs to this memory model.

`SC` is the default memory order because it treats the program as a simple sequence. If operations on an atomic variable are sequentially consistent, then the behavior of a multithreaded program appears as if these operations were executed in a specific order by a single-threaded program.

**Reads and writes before and after this atomic operation (including non-atomic reads and writes) cannot be reordered across this operation; all write operations before this atomic operation (including non-atomic writes) can be observed by all threads.**

### 3.1.2 Relaxed Ordering

`memory_order_relaxed` belongs to this memory model.

* Does not satisfy the `atomic-write happens-before atomic-read` rule
* Multiple operations on the same atomic variable within the same thread cannot be reordered
* Operations on different atomic variables within the same thread can be reordered (x86 does not allow this)
* `Normal write` and `atomic write` within the same thread can be reordered (x86 does not allow this)
* `Normal read` and `atomic read` within the same thread can be reordered (x86 does not allow this)
* **The only guarantee is that different threads see modifications to the variable in the same order**

### 3.1.3 Acquire-Release Ordering

`memory_order_release`, `memory_order_acquire`, and `memory_order_acq_rel` belong to this memory model.

`memory_order_release` is used for write operations (`store`), and `memory_order_acquire` is used for read operations (`load`).

* `memory_order_release` ensures that "reads and writes before the atomic operation (including non-atomic reads and writes)" cannot be reordered after it; and previous writes (including non-atomic writes) can be observed by threads using `acquire/consume`. Note that unlike `seq_cst`, only related threads can observe these write changes. Related threads are those that load the same shared variable using `acquire` or `consume`; `seq_cst` is observed by all threads.
* `memory_order_acquire` ensures that "reads and writes after the atomic operation" cannot be reordered before it; it can see the write operations performed by the releasing thread before calling `load`.
* `memory_order_acq_rel` combines `memory_order_release` and `memory_order_acquire`; reads and writes before and after this atomic operation cannot cross it, but only related threads can see the previous writes.
* `memory_order_consume` is similar to `memory_order_acquire` and is used with `memory_order_release`; the difference is that it imposes a restriction: subsequent reads and writes that depend on this read cannot be reordered before it. It can see dependent writes performed by the releasing thread before the `load`, where "dependent" means writes related to the shared variable.

Here's an example:

```
-Thread 1-
 n = 1
 m = 1
 p.store (&n, memory_order_release)

-Thread 2-
 t = p.load (memory_order_acquire);
 if (*t == 1)
    assert(m == 1);

-Thread 3-
 t = p.load (memory_order_consume);
 if (*t == 1)
    assert(m == 1);
```

* The assertion in thread 2 will succeed because thread 1 modified `n` and `m` before the store; after the `load`, thread 2 can observe the modification of `m`.
* However, the assertion in thread 3 may not succeed because `m` is a variable unrelated to the `load/store` operation, so thread 3 may not observe it.

# 4 chrono

## 4.1 clock

**Three types of clocks:**

1. `steady_clock`: A monotonic clock. Its absolute value is meaningless; it only increases, making it suitable for measuring program duration.
1. `system_clock`: The system clock, which can be modified and synchronized over the network. Therefore, calculating time differences using system time may be inaccurate.
1. `high_resolution_clock`: The highest precision clock that the system can provide. It is also not modifiable and is essentially a high-precision version of `steady_clock`.

```cpp
auto start = std::chrono::steady_clock::now();
auto end = std::chrono::steady_clock::now();
auto nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count();
auto now_nanos = std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count();
```

## 4.2 time_point

```cpp
#include <chrono>
#include <ctime>
#include <iostream>

int main() {
    using Clock = std::chrono::system_clock;
    // Convert from std::chrono::time_point to time_t
    Clock::time_point now_tp = Clock::now();
    time_t now_tt = Clock::to_time_t(now_tp);
    std::cout << "Current time (time_t): " << now_tt << std::endl;

    // Convert from time_t to std::tm (local time)
    std::tm now_tm = *std::localtime(&now_tt);
    std::cout << "Current time (std::tm): " << now_tm.tm_hour << ":" << now_tm.tm_min << ":" << now_tm.tm_sec
              << std::endl;

    // Convert from std::tm to std::chrono::time_point
    time_t back_to_tt = std::mktime(&now_tm);
    Clock::time_point back_to_tp = Clock::from_time_t(back_to_tt);
    std::cout << "Back to std::chrono::time_point" << std::endl;

    return 0;
}
```

# 5 filesystem

1. `std::filesystem::copy`
1. `std::filesystem::copy_file`
1. `std::filesystem::exist`
1. `std::filesystem::file_size`
1. `std::filesystem::is_directory`
1. `std::filesystem::is_regular_file`
1. `std::filesystem::remove`
1. `std::filesystem::rename`

# 6 fstream

## 6.1 std::ifstream

**Case 1: Read entire content at one time.**

```cpp
#include <fstream>
#include <iostream>
#include <sstream>

int main() {
    std::ifstream ifs("main.cpp");
    std::stringstream ss;
    // Read entire content
    ss << ifs.rdbuf();
    std::cout << ss.str() << std::endl;
    ifs.close();
    return 0;
}
```

**Case 2: Read line.**

```cpp
#include <fstream>
#include <iostream>
#include <string>

int main() {
    std::ifstream file("main.cpp");
    if (!file.is_open()) {
        std::cerr << "Error opening file" << std::endl;
        return 1;
    }

    std::string line;
    while (std::getline(file, line)) {
        std::cout << line << std::endl;
    }

    file.close();
    return 0;
}
```

**Case 3: Read content separated by a specific delimiter.**

```cpp
#include <fstream>
#include <iostream>
#include <string>

int main() {
    std::ifstream file("main.cpp");
    if (!file.is_open()) {
        std::cerr << "Error opening file" << std::endl;
        return 1;
    }

    std::string line;
    const char delimiter = ' ';
    while (std::getline(file, line, delimiter)) {
        std::cout << line << std::endl;
    }

    file.close();
    return 0;
}
```

1. `std::ofstream`

# 7 functional

1. `std::less`, `std::greater`, `std::less_equal`, `std::greater_equal`: Comparators
1. `std::function`: Functions similarly to a function pointer; in places where a function pointer is needed, you can pass an object of type `std::function` (not a pointer)
1. `std::bind`
1. `std::hash`: Function object, use it like this `std::hash<int>()(5)`
1. `std::mem_fn`
1. `std::reference_wrapper`
    ```cpp
    #include <algorithm>
    #include <functional>
    #include <iostream>
    #include <iterator>
    #include <list>
    #include <numeric>
    #include <random>
    #include <vector>

    void print(auto const rem, const auto& c) {
        std::cout << rem;
        std::ranges::copy(c, std::ostream_iterator<int32_t>(std::cout, ","));
        std::cout << std::endl;
    }

    int main() {
        std::list<int> l(10);
        std::iota(l.begin(), l.end(), -4);
        // can't use shuffle on a list (requires random access), but can use it on a vector
        std::vector<std::reference_wrapper<int>> v(l.begin(), l.end());
        std::ranges::shuffle(v, std::mt19937{std::random_device{}()});
        print("Contents of the list: ", l);
        print("Contents of the list, as seen through a shuffled vector: ", v);
        std::cout << "Doubling the values in the initial list...\n";
        std::ranges::for_each(l, [](int& i) { i *= 2; });
        print("Contents of the list, as seen through a shuffled vector: ", v);

        return 0;
    }
    ```

## 7.1 Reference

* [C++11 中的std::function和std::bind](https://www.jianshu.com/p/f191e88dcc80)

# 8 future

1. `std::promise`
1. `std::future`

# 9 iomanip

iomanip stands for input/output manipulators

1. `std::get_time`: Refer to [std::get_time](https://en.cppreference.com/w/cpp/io/manip/get_time) for all supported time format.
1. `std::put_time`
    ```cpp
    #include <chrono>
    #include <ctime>
    #include <iomanip>
    #include <iostream>
    #include <sstream>

    int main() {
        std::string date_str = "2023-09-15 20:30";
        std::tm tm = {};
        std::istringstream ss(date_str);

        ss >> std::get_time(&tm, "%Y-%m-%d %H:%M");
        if (ss.fail()) {
            std::cout << "Parse error." << std::endl;
        } else {
            std::cout << "Successfully parsed: "
                    << "Year: " << tm.tm_year + 1900 << ", Month: " << tm.tm_mon + 1 << ", Day: " << tm.tm_mday
                    << ", Hour: " << tm.tm_hour << ", Minute: " << tm.tm_min << std::endl;
        }

        auto now = std::chrono::system_clock::now();
        time_t now_c = std::chrono::system_clock::to_time_t(now);
        std::tm* now_tm = std::localtime(&now_c);

        std::cout << "Current time: " << std::put_time(now_tm, "%Y-%m-%d %H:%M:%S") << std::endl;
        return 0;
    }
    ```

1. `std::get_money`
1. `std::put_money`

# 10 iostream

1. `std::cout`
1. `std::cin`
1. `std::endl`
1. `std::boolalpha`
1. `std::noboolalpha`

# 11 iterator

## 11.1 Stream Iterators

1. `std::istream_iterator`
1. `std::ostream_iterator`
1. `std::istreambuf_iterator`
1. `std::ostreambuf_iterator`

## 11.2 Operations

1. `std::advance`
1. `std::distance`
1. `std::next`
1. `std::prev`

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <vector>

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};

    // Using std::distance to find the number of elements between two iterators
    auto first = numbers.begin();
    auto last = numbers.end();
    std::cout << "Number of elements in the vector: " << std::distance(first, last) << std::endl;
    std::cout << "Number of elements in the vector (reverse): " << std::distance(last, first) << std::endl;

    auto it = std::find(numbers.begin(), numbers.end(), 3);
    std::cout << "Distance between start and 3 is: " << std::distance(it, numbers.begin()) << std::endl;
    std::cout << "Distance between start and 3 is (reverse): " << std::distance(numbers.begin(), it) << std::endl;

    // Using std::advance to move an iterator by a specific number of positions
    it = numbers.begin();
    std::advance(it, 2); // Advance the iterator by 2 positions
    std::cout << "Value at position 2: " << *it << std::endl;

    // Using std::next to get an iterator pointing to an element at a specific position
    auto nextIt = std::next(numbers.begin(), 3); // Get an iterator to the element at position 3
    std::cout << "Value at position 3: " << *nextIt << std::endl;

    // Using std::prev to get an iterator pointing to an element at a specific position
    auto prevIt = std::prev(numbers.end(), 2); // Get an iterator to the element at position 3 from the end
    std::cout << "Value at position 3 from the end: " << *prevIt << std::endl;

    return 0;
}
```

```
Number of elements in the vector: 5
Number of elements in the vector (reverse): -5
Distance between start and 3 is: -2
Distance between start and 3 is (reverse): 2
Value at position 2: 3
Value at position 3: 4
Value at position 3 from the end: 4
```

## 11.3 Adaptors

1. `std::make_reverse_iterator`
1. `std::make_move_iterator`
1. `make_const_iterator`

# 12 limits

1. `std::numeric_limits`
    * `std::numeric_limits<int32_t>::max()`

# 13 memory

## 13.1 std::shared_ptr

**Type case:**

* `std::static_pointer_cast`
* `std::dynamic_pointer_cast`
* `std::const_pointer_cast`
* `std::reinterpret_pointer_cast`

**Only use the pointer within the function without storing the object content**

If we only need to use the object within the function for some operations, but do not intend to manage its lifetime or extend the `shared_ptr` lifetime through function parameters, we can use a `raw pointer` or a `const shared_ptr&` in this case.

```c++
void func(Widget*);
// No copy occurs, reference count is not increased
void func(const shared_ptr<Widget>&)
```

**Storing a smart pointer in a function**

If we need to store the smart pointer within the function, it is recommended to pass it by value.

```c++
// A copy occurs when passing the argument, and the reference count increases
void func(std::shared_ptr<Widget> ptr);
```

In this case, when a value is passed from outside, you can choose to `move` it or assign it. Inside the function, you can directly store this object using `move`.

## 13.2 std::enable_shared_from_this

**`std::enable_shared_from_this` allows an object managed by a `std::shared_ptr` to safely create additional `std::shared_ptr` instances, sharing ownership with the original instance**

* Instances must be created via `std::make_shared` (cannot use `new`), otherwise an error occurs
* Calling `std::enable_shared_from_this::shared_from_this` on a regular object (not managed by a smart pointer) will also result in an error

**Use case:** When you hold a raw pointer to an object (whose lifetime is managed by a smart pointer) but want to obtain a `shared_ptr` to that object, you need to rely on `std::enable_shared_from_this`

* You cannot directly put `this` into a `std::shared_ptr`, as this would lead to a dangling pointer on deletion

```cpp
class Demo : public std::enable_shared_from_this<Demo> {
};

int main() {
    auto ptr = std::make_shared<Demo>();
    auto another_ptr = ptr->shared_from_this();

    std::cout << ptr << std::endl;
    std::cout << another_ptr.get() << std::endl;
}
```

## 13.3 std::unique_ptr

* `release` means relinquishing control and no longer managing the object's lifetime, not deleting it. To actually release the object, you can use the `reset` method or directly assign `nullptr`.

```cpp
#include <iostream>
#include <memory>

class Foo {
public:
    Foo() { std::cout << "ctor" << std::endl; }
    ~Foo() { std::cout << "dctor" << std::endl; }
};

int main(void) {
    {
        std::unique_ptr<Foo> u_ptr = std::make_unique<Foo>();
        u_ptr.release();
        std::cout << "after calling unique_ptr::release\n" << std::endl;
    }
    {
        std::unique_ptr<Foo> u_ptr = std::make_unique<Foo>();
        u_ptr.reset();
        std::cout << "after calling unique_ptr::reset\n" << std::endl;
    }
    {
        std::unique_ptr<Foo> u_ptr = std::make_unique<Foo>();
        u_ptr = nullptr;
        std::cout << "after assigning to nullptr direcly\n" << std::endl;
    }
    return 0;
}
```

## 13.4 std::weak_ptr

Used to point to an object managed by `std::shared_ptr` but does not manage the object's lifetime. In other words, the object it points to may have already been destroyed.

```cpp
#include <iostream>
#include <memory>

int main() {
    auto print = [](auto& w_ptr) {
        if (auto ptr = w_ptr.lock()) {
            std::cout << "active" << std::endl;
        } else {
            std::cout << "inactive" << std::endl;
        }
    };
    std::shared_ptr<int32_t> s_ptr;
    std::weak_ptr<int32_t> w_ptr = s_ptr;

    print(w_ptr);

    s_ptr = std::make_shared<int32_t>(1);
    print(w_ptr);

    w_ptr = s_ptr;
    print(w_ptr);

    s_ptr.reset();
    print(w_ptr);

    return 0;
}
```

## 13.5 Pointer Cast

1. `std::static_pointer_cast`
1. `std::dynamic_pointer_cast`
1. `std::const_pointer_cast`
1. `std::reinterpret_pointer_cast`

## 13.6 Reference

* [C++ 智能指针的正确使用方式](https://www.cyhone.com/articles/right-way-to-use-cpp-smart-pointer/)

# 14 memory_resource

```cpp
#include <iostream>
#include <memory_resource>

int main() {
    // Create a polymorphic allocator using the default memory resource
    std::pmr::polymorphic_allocator<int> allocator;

    // Allocate memory for an array of integers
    int* p = allocator.allocate(10);

    // Initialize the allocated memory
    for (int i = 0; i < 10; ++i) {
        p[i] = i;
    }

    // Do something with the allocated memory

    // Deallocate memory when done
    allocator.deallocate(p, 10);

    return 0;
}
```

# 15 mutex

1. `std::mutex`: Non-reentrant mutex
1. `std::recursive_mutex`: Reentrant mutex
1. `std::lock_guard`
    * Directly used with `std::mutex`, as in the example below. If the `getVar` method throws an exception, `m.unlock()` will not be executed, which may lead to a deadlock.
    ```c++
    mutex m;
    m.lock();
    sharedVariable= getVar();
    m.unlock();
    ```

    * An elegant way is to use `std::lock_guard`, whose destructor releases the lock. You need to enclose the critical section within `{}`. When exiting this scope, the `std::lock_guard` object will be destructed and release the lock, ensuring the lock is released in both normal and exceptional cases.

    ```c++
    {
        std::mutex m;
        std::lock_guard<std::mutex> lockGuard(m);
        sharedVariable= getVar();
    }
    ```

1. `std::unique_lock`: Provides more operations than `std::lock_guard`, allowing manual lock and unlock.
1. `std::condition_variable`
    * Requires linking with the `libpthread` library; otherwise, the `wait` method will wake up immediately, and compilation will not report an error.
    * When calling the `wait` method, the monitor must be acquired. When calling `notify`, acquiring the monitor is not required.
    * After being awakened by `wait`, the thread still holds the monitor.
    ```cpp
    std::mutex m;
    std::condition_variable cv;
    std::unique_lock<std::mutex> l(m);
    cv.wait(l);
    // wake up here, and still under lock
    ```

1. `std::call_once`、`std::once_flag`
    ```cpp
    #include <iostream>
    #include <mutex>
    #include <thread>
    #include <vector>

    void say_hello() {
        std::cout << "hello world" << std::endl;
    }

    int main() {
        std::once_flag flag;
        std::vector<std::thread> threads;
        for (int i = 0; i < 10; i++) {
            threads.emplace_back([&]() { std::call_once(flag, say_hello); });
        }
        for (int i = 0; i < 10; i++) {
            threads[i].join();
        }
        return 0;
    }
    ```

## 15.1 Reference

* [Do I have to acquire lock before calling condition_variable.notify_one()?](https://stackoverflow.com/questions/17101922/do-i-have-to-acquire-lock-before-calling-condition-variable-notify-one)

# 16 numeric

1. `std::accumulate`
    ```cpp
    int main() {
        std::set<std::string> col = {"a", "b", "c"};

        std::string res = std::accumulate(std::begin(col),
                                        std::end(col),
                                        std::string(),
                                        [](const std::string &a, const std::string &b) {
                                            return a.empty() ? b
                                                            : a + ", " + b;
                                        });

        std::cout << res << std::endl;
    }
    ```

1. `std::iota`: Assigns values to a specified range in an increasing order.
    ```cpp
    #include <algorithm>
    #include <iostream>
    #include <numeric>
    #include <ranges>
    #include <vector>

    int main() {
        std::vector<int> nums(10);
        std::iota(nums.begin(), nums.end(), 1);
        std::ranges::copy(nums, std::ostream_iterator<int32_t>(std::cout, ","));
        std::cout << std::endl;

        return 0;
    }
    ```

# 17 optional

1. `std::optional`
    * `std::nullopt`

```cpp
#include <iostream>
#include <optional>

std::optional<std::string> create(bool flag) {
    if (flag) {
        return "Godzilla";
    } else {
        return {};
    }
}

int main() {
    create(false).value_or("empty"); // == "empty"
    create(true).value();            // == "Godzilla"
    // optional-returning factory functions are usable as conditions of while and if
    if (auto str = create(true)) {
        std::cout << "create(true) is true, str=" << str.value() << std::endl;
    } else {
        std::cout << "create(true) is false" << std::endl;
    }

    if (auto str = create(false)) {
        std::cout << "create(false) is true, str=" << str.value() << std::endl;
    } else {
        std::cout << "create(false) is false" << std::endl;
    }
}
```

# 18 queue

## 18.1 std::priority_queue

`std::priority_queue` in C++ Standard Template Library (STL) is a container adapter that provides functionality to maintain a collection of elements sorted by priority. It is typically implemented as a max-heap, meaning the largest element is always at the front of the queue. There are three template parameters in `std::priority_queue`, each serving a specific purpose:

* **First Template Parameter - `T`:**
    * This represents the type of elements stored in the priority queue. For example, if you want a priority queue that stores integers, you would use `std::priority_queue<int>`.
* **Second Template Parameter - `Container`:**
    * This specifies the type of the underlying container used to store the elements of the queue. By default, `std::priority_queue` uses `std::vector` as its underlying container, but you can use other container types like `std::deque`. The chosen container must support `front()`, `push_back()`, and `pop_back()` operations.
* **Third Template Parameter - `Compare`:**
    * This is a comparison function object that determines the order of priority of the elements. By default, `std::priority_queue` uses `std::less<T>`, meaning that larger elements are considered to have higher priority. If you want a min-heap (where the smallest element is at the front), you can use `std::greater<T>` as this parameter.

```cpp
#include <iostream>
#include <queue>
#include <vector>

struct Item {
    int32_t value;

    struct Cmp {
        bool operator()(const Item& i1, const Item& i2) { return i1.value < i2.value; }
    };
};

int main() {
    std::priority_queue<Item, std::vector<Item>, Item::Cmp> max_heap;

    max_heap.push({1});
    max_heap.push({2});
    max_heap.push({3});
    max_heap.push({4});
    max_heap.push({5});

    while (!max_heap.empty()) {
        std::cout << max_heap.top().value << std::endl;
        max_heap.pop();
    }

    return 0;
}
```

# 19 random

1. `std::default_random_engine`
1. `std::uniform_int_distribution`: closed interval [inclusive on both ends]

# 20 ranges

`ranges` can be seen as a wrapper around the algorithms in `algorithm`, eliminating the need to call `begin()`, `end()`, etc., as shown below:

```cpp
#include <stdint.h>

#include <algorithm>
#include <iostream>
#include <iterator>
#include <ranges>
#include <vector>

int main() {
    std::vector<int32_t> nums{1, 3, 5, 7, 9};

    std::for_each(nums.begin(), nums.end(), [](int32_t num) { std::cout << num << ","; });
    std::cout << std::endl;

    std::ranges::for_each(nums, [](int32_t num) { std::cout << num << ","; });
    std::cout << std::endl;

    std::ranges::copy(nums, std::ostream_iterator<int32_t>(std::cout, ","));

    return 0;
}
```

# 21 stdexcept

1. `std::logic_error`
1. `std::invalid_argument`
1. `std::domain_error`
1. `std::length_error`
1. `std::out_of_range`
1. `std::runtime_error`
1. `std::range_error`
1. `std::overflow_error`
1. `std::underflow_error`

# 22 exception

1. `std::uncaught_exceptions`
    ```cpp
    #include <exception>
    #include <iostream>
    #include <stdexcept>

    struct Foo {
        char id{'?'};
        int count = std::uncaught_exceptions();

        ~Foo() {
            count == std::uncaught_exceptions() ? std::cout << id << ".~Foo() called normally\n"
                                                : std::cout << id << ".~Foo() called during stack unwinding\n";
        }
    };

    int main() {
        Foo f{'f'};

        try {
            Foo g{'g'};
            std::cout << "Exception thrown\n";
            throw std::runtime_error("test exception");
        } catch (const std::exception& e) {
            std::cout << "Exception caught: " << e.what() << '\n';
        }
    }
    ```
    ```
    Exception thrown
    g.~Foo() called during stack unwinding
    Exception caught: test exception
    f.~Foo() called normally
    ```

1. `std::current_exception`
    ```cpp
    #include <exception>
    #include <iostream>
    #include <stdexcept>

    int main() {
        try {
            throw std::runtime_error("An error occurred");
        } catch (...) {
            std::exception_ptr ptr = std::current_exception();
            if (ptr) {
                try {
                    std::rethrow_exception(ptr);
                } catch (const std::exception& e) {
                    std::cout << "Caught exception: " << e.what() << std::endl;
                }
            } else {
                std::cout << "Caught unknown exception" << std::endl;
            }
        }
        return 0;
    }
    ```

## 22.1 sstring

1. `std::stringstream`
1. `std::istringstream`: Use this and `std::getline` to achieve the function of spliting a string
1. `std::ostringstream`

```cpp
#include <iostream>
#include <sstream>
#include <string>

int main(int32_t argc, char* argv[]) {
    std::istringstream str("a,b,c,d,e,f,g");
    std::string next;
    while (std::getline(str, next, ',')) {
        std::cout << next << std::endl;
    }

    return 0;
}
```

# 23 shared_mutex

1. `std::shared_mutex`
1. `std::shared_timed_mutex`
1. `std::shared_lock`

# 24 string

1. `std::string`: char
1. `std::wstring`: wchar_t
1. `std::u8string`: char8_t
1. `std::u16string`: char16_t
1. `std::u32string`: char32_t
1. `std::to_string`
1. `std::string::npos`: This is a special value equal to the maximum value representable by the type size_type.
1. `std::getline`: getline reads characters from an input stream and places them into a string.

Numeric conversions:

* `std::stoi`
* `std::stol` 
* `std::stoll`
* `std::stoul`
* `std::stoull`
* `std::stof`
* `std::stod`
* `std::stold`
* `std::to_string`
* `std::to_wstring`

Matching member functions:

* `find`: Searches for a **substring** in the string.
* `find_first_of`: Searches for the **first character** that matches any character in a given set.
* `find_first_not_of`: Searches for the **first character** that is not in the given set.
* `find_last_of`: Searches from the end for the **last character** that matches any character in a given set.
* `find_last_not_of`: Searches from the end for the **last character** that is not in the given set.
    ```cpp
    #include <iostream>

    int main() {
        std::string content = "Hello, World!";
        if (content.find("World") != std::string::npos) {
            std::cout << "Substring 'World' found!" << std::endl;
        } else {
            std::cout << "Substring 'World' not found." << std::endl;
        }
        if (content.find("Worla") != std::string::npos) {
            std::cout << "Substring 'Worla' found!" << std::endl;
        } else {
            std::cout << "Substring 'Worla' not found." << std::endl;
        }
        if (content.find_first_of("Worla") != std::string::npos) {
            std::cout << "Any character from 'Worla' found!" << std::endl;
        } else {
            std::cout << "No character from 'Worla' found." << std::endl;
        }
        if (content.find_last_of("Worla") != std::string::npos) {
            std::cout << "Any character from 'Worla' found!" << std::endl;
        } else {
            std::cout << "No character from 'Worla' found." << std::endl;
        }
        return 0;
    }
    ```

# 25 string_view

# 26 thread

1. `std::thread::hardware_concurrency`
1. `std::this_thread`

## 26.1 How to set thread name

1. `pthread_setname_np/pthread_getname_np`: Requires including the `<pthread.h>` header. `np` stands for `non-portable`, meaning platform-specific.
1. `prctl(PR_GET_NAME, name)/prctl(PR_SET_NAME, name)`: Requires including the `<sys/prctl.h>` header.

```cpp
#include <pthread.h>
#include <sys/prctl.h>

#include <chrono>
#include <functional>
#include <iostream>
#include <sstream>
#include <thread>

void* change_thread_name(void* = nullptr) {
    // avoid change name before set original thread name
    std::this_thread::sleep_for(std::chrono::seconds(1));

    char original_thread_name[16];
    prctl(PR_GET_NAME, original_thread_name);
    uint32_t cnt = 0;

    while (true) {
        if (cnt > 1000) {
            cnt = 0;
        }

        std::stringstream ss;
        ss << original_thread_name << "-" << cnt++;
        prctl(PR_SET_NAME, ss.str().data());

        char current_thread_name[16];
        prctl(PR_GET_NAME, current_thread_name);
        std::cout << current_thread_name << std::endl;

        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    return nullptr;
}

void create_thread_by_pthread() {
    pthread_t tid;
    pthread_create(&tid, nullptr, change_thread_name, nullptr);
    pthread_setname_np(tid, "pthread");
    pthread_detach(tid);
}

void create_thread_by_std() {
    std::function<void()> func = []() { change_thread_name(); };
    std::thread t(func);
    pthread_setname_np(t.native_handle(), "std-thread");
    t.detach();
}

int main() {
    std::this_thread::sleep_for(std::chrono::milliseconds(333));
    create_thread_by_pthread();

    std::this_thread::sleep_for(std::chrono::milliseconds(333));
    create_thread_by_std();

    prctl(PR_SET_NAME, "main");
    change_thread_name();
}
```

## 26.2 How to set thread affinity

The example code below is used to test the performance of each CPU.

* `CPU_ZERO`: Initialize
* `CPU_SET`: Add affinity to a specific CPU; can be called multiple times for different CPUs
* `CPU_ISSET`: Check if there is affinity to a specific CPU
* `pthread_setaffinity_np`: Set the CPU affinity of a thread
* `pthread_getaffinity_np`: Get the CPU affinity of a thread

```cpp
#include <pthread.h>

#include <iostream>

int main(int argc, char* argv[]) {
    pthread_t thread = pthread_self();

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(1, &cpuset);
    CPU_SET(2, &cpuset);
    CPU_SET(3, &cpuset);
    CPU_SET(4, &cpuset);

    // Bind to core 1,2,3,4
    if (pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
        return 1;
    }

    if (pthread_getaffinity_np(thread, sizeof(cpu_set_t), &cpuset) != 0) {
        return 1;
    }
    for (int i = 0; i < CPU_SETSIZE; i++) {
        if (CPU_ISSET(i, &cpuset)) {
            std::cout << "core " << i << " is set" << std::endl;
        }
    }

    return 0;
}
```

# 27 tuple

1. `std::tuple`
1. `std::apply`: Invokes a function where the arguments are packaged in a `tuple`
    ```cpp
    #include <iostream>
    #include <tuple>
    #include <utility>

    int add(int a, int b) {
        return a + b;
    }

    int main() {
        std::cout << std::apply(add, std::make_tuple(1, 2)) << std::endl;
        std::cout << std::apply(add, std::make_pair(1, 2)) << std::endl;
        return 0;
    }
    ```

1. `std::tie`
    ```cpp
    #include <stdint.h>

    #include <string>
    #include <tuple>

    std::pair<int32_t, std::string> createPair() {
        return std::pair<int32_t, std::string>(1, "Hello, World!");
    }

    std::tuple<int32_t, std::string, float> createTuple() {
        return std::tuple<int32_t, std::string, float>(2, "Hi, World!", 3.14f);
    }

    int main() {
        int32_t num;
        std::string str;

        std::tie(num, std::ignore) = createPair();
        std::tie(num, str, std::ignore) = createTuple();
        return 0;
    }
    ```

# 28 type_traits

[Standard library header <type_traits>](https://en.cppreference.com/w/cpp/header/type_traits)

## 28.1 Helper Class

1. `std::integral_constant`
1. `std::bool_constant`
1. `std::true_type`
1. `std::false_type`

## 28.2 Primary type categories

1. `std::is_void`
1. `std::is_null_pointer`
1. `std::is_integral`
1. `std::is_array`
1. `std::is_pointer`
1. ...

## 28.3 Composite type categories

1. `std::is_fundamental`
1. `std::is_arithmetic`
1. `std::is_scalar`
1. `std::is_reference`
1. `std::is_member_pointer`
1. ...

## 28.4 Type properties

1. `std::is_const`
1. `std::is_volatile`
1. `std::is_final`
1. `std::is_empty`
1. `std::is_abstract`
1. ...

## 28.5 Supported operations

1. `std::is_constructible`
1. `std::is_copy_constructible`
1. `std::is_assignable`
1. `std::is_copy_assignable`
1. `std::is_destructible`
1. ...

## 28.6 Property queries

1. `std::alignment_of`
1. `std::rank`
1. `std::extent`

## 28.7 Type relationships

1. `std::is_same`
1. `std::is_base_of`
1. ...

## 28.8 Const-volatility specifiers

1. `std::remove_cv`
1. `std::remove_const`
1. `std::remove_volatile`
1. `std::add_cv`
1. `std::add_const`
1. `std::add_volatile`

## 28.9 References

1. `std::remove_reference`
1. `std::add_lvalue_reference`
1. `std::add_rvalue_reference`
  
## 28.10 Pointers

1. `std::remove_pointer`
1. `std::add_pointer`
  
## 28.11 Sign modifiers

1. `std::make_signed`
1. `std::make_unsigned`

## 28.12 Arrays

1. `std::remove_extent`
1. `std::remove_all_extents`

## 28.13 Miscellaneous transformations

1. `std::enable_if_t`: Often used in SFINAE.
1. `std::conditional`
1. `std::underlying_type`: Get the underlying numeric type of enum type.
1. `std::void_t`: Often used in SFINAE.
1. `std::decay`: Applies reference-remove, cv-qualifiers-remove (const and volatile), array-to-pointer, and function-to-pointer implicit conversions to the type T.
    * [What is std::decay and when it should be used?](https://stackoverflow.com/questions/25732386/what-is-stddecay-and-when-it-should-be-used)
    * [N2609](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2006/n2069.html)
    ```cpp
    #include <type_traits>

    template <typename T, typename U>
    constexpr bool is_decay_equ = std::is_same_v<std::decay_t<T>, U>;

    int main() {
        static_assert(is_decay_equ<int&, int>);
        static_assert(is_decay_equ<int&&, int>);
        static_assert(is_decay_equ<const int&, int>);
        static_assert(is_decay_equ<int[2], int*>);
        static_assert(is_decay_equ<int[2][3], int(*)[3]>);
        static_assert(is_decay_equ<void(int, int), void (*)(int, int)>);
        return 0;
    }    
    ```

## 28.14 Alias

`using template`: Used to simplify the above templates. For example, `std::enable_if_t` is equivalent to `typename enable_if<b, T>::type`

1. `std::enable_if_t`
1. `std::conditional_t`
1. `std::remove_reference_t`
1. `std::result_of_t`
1. `std::invoke_result_t`
    ```cpp
    #include <type_traits>

    char create_char(char) {
        return 0;
    }

    class Foo {
    public:
        static int create_int(int) { return 0; }
        int create_double(int) { return 0; }
    };

    int main() {
        std::invoke_result_t<decltype(create_char), char> c1;
        std::invoke_result_t<decltype(&create_char), char> c2;

        std::invoke_result_t<decltype(Foo::create_int), int> i1;
        std::invoke_result_t<decltype(&Foo::create_int), int> i2;

        // std::invoke_result_t<decltype(Foo::create_double), Foo, int> d1;
        std::invoke_result_t<decltype(&Foo::create_double), Foo, int> d2;

        return 0;
    }    
    ```

1. ...

## 28.15 std::move

**Implementation:**

```cpp
  template<typename _Tp>
    constexpr typename std::remove_reference<_Tp>::type&&
    move(_Tp&& __t) noexcept
    { return static_cast<typename std::remove_reference<_Tp>::type&&>(__t); }
```

Essentially, it performs a type transformation, and the returned type is guaranteed to be an rvalue.

For non-reference type parameters, using std::move during argument passing will invoke the move constructor to create the argument. Here's an example:

```cpp
#include <iostream>

class Foo {
public:
    Foo() { std::cout << "Default ctor" << std::endl; }
    Foo(const Foo&) { std::cout << "Copy ctor" << std::endl; }
    Foo(Foo&&) { std::cout << "Move ctor" << std::endl; }
};

void test_foo(Foo foo) {
    std::cout << "test_foo" << std::endl;
}

int main() {
    Foo foo;
    test_foo(std::move(foo));
}
```

## 28.16 std::forward

`std::forward` is mainly used to implement perfect forwarding: For a variable, regardless of whether its type is an lvalue reference or rvalue reference, the variable itself is an lvalue. If the variable is passed directly to another function, it will always match the overload as an lvalue. `std::forward` is used to solve this problem. See the example below:

```cpp
#include <iostream>

std::string func(int& value) {
    return "left reference version";
}

std::string func(int&& value) {
    return "right reference version";
}

template <typename T>
std::string dispatch_without_forward(T&& t) {
    return func(t);
}

template <typename T>
std::string dispatch_with_forward(T&& t) {
    return func(std::forward<T>(t));
}

#define TEST(expr) std::cout << #expr << " -> " << expr << std::endl;

int main() {
    int value = 0;
    int& value_l_ref = value;
    auto get_r_value = []() { return 2; };

    TEST(dispatch_without_forward(value));
    TEST(dispatch_without_forward(value_l_ref));
    TEST(dispatch_without_forward(get_r_value()));
    TEST(dispatch_without_forward(1));
    std::cout << std::endl;

    TEST(dispatch_with_forward(value));
    TEST(dispatch_with_forward(value_l_ref));
    TEST(dispatch_with_forward(get_r_value()));
    TEST(dispatch_with_forward(1));
    std::cout << std::endl;

    TEST(func(std::forward<int>(value)));
    TEST(func(std::forward<int&>(value)));
    TEST(func(std::forward<int&&>(value)));
    std::cout << std::endl;

    TEST(func(std::forward<int>(value_l_ref)));
    TEST(func(std::forward<int&>(value_l_ref)));
    TEST(func(std::forward<int&&>(value_l_ref)));
    std::cout << std::endl;

    TEST(func(std::forward<int>(get_r_value())));
    TEST(func(std::forward<int&&>(get_r_value())));
    std::cout << std::endl;

    TEST(func(std::forward<int>(1)));
    TEST(func(std::forward<int&&>(1)));

    return 0;
}
```

**Output:**

```
dispatch_without_forward(value) -> left reference version
dispatch_without_forward(value_l_ref) -> left reference version
dispatch_without_forward(get_r_value()) -> left reference version
dispatch_without_forward(1) -> left reference version

dispatch_with_forward(value) -> left reference version
dispatch_with_forward(value_l_ref) -> left reference version
dispatch_with_forward(get_r_value()) -> right reference version
dispatch_with_forward(1) -> right reference version

func(std::forward<int>(value)) -> right reference version
func(std::forward<int&>(value)) -> left reference version
func(std::forward<int&&>(value)) -> right reference version

func(std::forward<int>(value_l_ref)) -> right reference version
func(std::forward<int&>(value_l_ref)) -> left reference version
func(std::forward<int&&>(value_l_ref)) -> right reference version

func(std::forward<int>(get_r_value())) -> right reference version
func(std::forward<int&&>(get_r_value())) -> right reference version

func(std::forward<int>(1)) -> right reference version
func(std::forward<int&&>(1)) -> right reference version
```

**When using `std::forward`, the template arguments must be explicitly specified, not deduced.**

**The standard library implementation of `std::forward` is as follows:**

* If the template argument is an lvalue, lvalue reference, or rvalue reference, it matches the first overload:
    * Lvalue: `_Tp&&` results in an rvalue (strange, because this is generally not how it's used)
    * **Lvalue reference: `_Tp&&` results in an lvalue reference (used in perfect forwarding)**
    * **Rvalue reference: `_Tp&&` results in an rvalue reference (used in perfect forwarding)**
* If the template argument is an lvalue or rvalue, it matches the second overload:
    * Rvalue: `_Tp&&` results in an rvalue
```cpp
  template<typename _Tp>
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type& __t) noexcept
    { return static_cast<_Tp&&>(__t); }

  template<typename _Tp>
    constexpr _Tp&&
    forward(typename std::remove_reference<_Tp>::type&& __t) noexcept
    {
      static_assert(!std::is_lvalue_reference<_Tp>::value, "template argument"
                    " substituting _Tp is an lvalue reference type");
      return static_cast<_Tp&&>(__t);
    }
```

### 28.16.1 forwarding reference

**A `T&&` is called a forwarding reference if and only if `T` is a template type parameter of a function template; any other form is not a forwarding reference. For example:**

* **`std::vector<T>&&` is not a forwarding reference, but just an rvalue reference**
* **`T&&` in `C(T&& t)` is also not a forwarding reference, because the type `T` is already determined when `C` is instantiated, no deduction is needed**

```cpp
#include <type_traits>
#include <vector>

class S {};

template <typename T>
void g(const T& t);
template <typename T>
void g(T&& t);

template <typename T>
void gt(T&& t) {
    g(std::move(t)); // Noncompliant : std::move applied to a forwarding reference
}

void use_g() {
    S s;
    g(s);
    g(std::forward<S>(s)); // Noncompliant : S isn't a forwarding reference.
}

template <typename T>
void foo(std::vector<T>&& t) {
    std::forward<T>(t); // Noncompliant : std::vector<T>&& isn't a forwarding reference.
}

template <typename T>
struct C {
    // In class template argument deduction, template parameter of a class template is never a forwarding reference.
    C(T&& t) {
        g(std::forward<T>(t)); // Noncompliant : T&& isn't a forwarding reference. It is an r-value reference.
    }
};
```

**The correct way to write the above program is:**

```cpp
#include <type_traits>
#include <vector>

class S {};

template <typename T>
void g(const T& t);
template <typename T>
void g(T&& t);

template <typename T>
void gt(T&& t) {
    g(std::forward(t));
}

void use_g() {
    S s;
    g(s);
    g(std::move(s));
}

template <typename T>
void foo(std::vector<T>&& t) {
    std::move(t);
}

template <typename T>
struct C {
    C(T&& t) { g(std::move(t)); }
};
```

# 29 unordered_map

# 30 unordered_set

Both `equal` and `hash` functions should be marked with `const`

```cpp
#include <functional>
#include <iostream>
#include <unordered_set>

struct Item {
    int32_t value1;
    int32_t value2;

    bool operator==(const Item& other) const { return value1 == other.value1 && value2 == other.value2; }

    struct Eq {
        auto operator()(const Item& i1, const Item& i2) const {
            return i1.value1 == i2.value2 && i1.value2 == i2.value2;
        }
    };

    struct Hash {
        auto operator()(const Item& i) const { return std::hash<int32_t>()(i.value1) ^ std::hash<int32_t>()(i.value2); }
    };
};

std::ostream& operator<<(std::ostream& os, const Item& item) {
    os << "(" << item.value1 << ", " << item.value2 << ")";
    return os;
}

int main() {
    {
        // Use member function operator== as equal function
        std::unordered_set<Item, Item::Hash> visited;

        auto add = [](auto& visited, const Item& item) {
            if (auto it = visited.insert(item); it.second) {
                std::cout << "add " << item << " successfully" << std::endl;
            } else {
                std::cout << item << " already exists" << std::endl;
            }
        };

        add(visited, {.value1 = 1, .value2 = 1});
        add(visited, {.value1 = 1, .value2 = 2});
        add(visited, {.value1 = 2, .value2 = 2});
        add(visited, {.value1 = 3, .value2 = 3});
        add(visited, {.value1 = 1, .value2 = 1});
    }

    {
        // Use type Item::Eq as equal function
        std::unordered_set<Item, Item::Hash, Item::Eq> visited;

        auto add = [](auto& visited, const Item& item) {
            if (auto it = visited.insert(item); it.second) {
                std::cout << "add " << item << " successfully" << std::endl;
            } else {
                std::cout << item << " already exists" << std::endl;
            }
        };

        add(visited, {.value1 = 1, .value2 = 1});
        add(visited, {.value1 = 1, .value2 = 2});
        add(visited, {.value1 = 2, .value2 = 2});
        add(visited, {.value1 = 3, .value2 = 3});
        add(visited, {.value1 = 1, .value2 = 1});
    }

    return 0;
}
```

# 31 utility

1. `std::exchange`：
    ```cpp
    #include <iostream>
    #include <utility>
    #include <vector>

    int main() {
        std::vector<int32_t> nums{1, 2, 3, 4, 5};
        bool visit_first = false;
        for (size_t i = 0; i < nums.size(); ++i) {
            if (auto previous = std::exchange(visit_first, true)) {
                std::cout << ", ";
            }
            std::cout << nums[i];
        }
        return 0;
    }
    ```

1. `std::pair`: Essentially, it is a special case of `std::tuple`
1. `std::declval`: Used with `decltype` for type deduction. Its implementation principle is as follows:
    * `__declval` is a method used to return a specified type (only defined without implementation, as it is only used for type deduction)
    * The `_Tp __declval(long);` version is used for types like `void`, because `void` has no reference type
    ```cpp
    /// @cond undocumented
    template <typename _Tp, typename _Up = _Tp&&>
    _Up __declval(int);

    template <typename _Tp>
    _Tp __declval(long);
    /// @endcond

    template <typename _Tp>
    auto declval() noexcept -> decltype(__declval<_Tp>(0));
    ```

    * Demo:
    ```cpp
    #include <iostream>
    #include <type_traits>
    #include <utility>

    struct Default {
        int foo() const { return 1; }
    };

    struct NonDefault {
        NonDefault(const NonDefault&) {}
        int foo() const { return 1; }
    };

    NonDefault get_non_default();

    int main() {
        decltype(Default().foo()) n1 = 1;
        // decltype(NonDefault().foo()) n2 = n1;               // will not compile
        decltype(std::declval<NonDefault>().foo()) n2 = 2;
        decltype(get_non_default().foo()) n3 = 3;
        std::cout << "n1 = " << n1 << std::endl;
        std::cout << "n2 = " << n2 << std::endl;
        std::cout << "n3 = " << n3 << std::endl;
        return 0;
    }
    ```

1. `std::integer_sequence`
1. `std::make_integer_sequence`
1. `std::integer_sequence`
1. `std::make_integer_sequence`

## 31.1 How to return pair containing reference type

Demo:

```cpp
#include <algorithm>
#include <functional>
#include <iostream>
#include <iterator>
#include <type_traits>
#include <utility>
#include <vector>

class Thing {
public:
    std::pair<const std::vector<int>&, int> get_data_1() { return std::make_pair(_data, _data.size()); }
    std::pair<const std::vector<int>&, int> get_data_2() { return std::make_pair(std::ref(_data), _data.size()); }
    std::pair<const std::vector<int>&, int> get_data_3() {
        return std::pair<const std::vector<int>&, int>(_data, _data.size());
    }

private:
    std::vector<int> _data{1, 2, 3, 4, 5};
};

int main() {
    Thing t;

    auto printer = [](auto& pair) {
        std::ranges::copy(pair.first, std::ostream_iterator<int>(std::cout, ", "));
        std::cout << std::endl;
    };

    auto pair1 = t.get_data_1();
    // printer(pair1); // crash

    auto pair2 = t.get_data_2();
    printer(pair2);

    auto pair3 = t.get_data_3();
    printer(pair3);
    return 0;
}
```

* First, let's look at the source code of `std::make_pair`:
    * `__decay_and_strip`: For `std::reference_wrapper`, it removes the wrapper and returns a reference type; for other types, it returns a non-reference type
    ```cpp
    template<typename _T1, typename _T2>
    constexpr pair<typename __decay_and_strip<_T1>::__type,
                    typename __decay_and_strip<_T2>::__type>
    make_pair(_T1&& __x, _T2&& __y)
    {
        typedef typename __decay_and_strip<_T1>::__type __ds_type1;
        typedef typename __decay_and_strip<_T2>::__type __ds_type2;
        typedef pair<__ds_type1, __ds_type2> 	      __pair_type;
        return __pair_type(std::forward<_T1>(__x), std::forward<_T2>(__y));
    }
    ```

* `get_data_1`: Incorrect approach. `std::make_pair` creates an object of type `std::pair<std::vector<int>, int>`, which is then cast to `std::pair<const std::vector<int>&, int>`. The reference is incorrectly initialized (bound to a temporary), causing subsequent errors.
* `get_data_2`: Correct approach. With `std::ref` (which returns a `std::reference_wrapper`), `std::make_pair` creates an object of type `std::pair<const std::vector<int>&, int>`, and the reference is correctly initialized.
* `get_data_3`: Correct approach. Without using `std::make_pair`, the reference is correctly initialized.

# 32 variant

1. `std::visit`
1. `std::variant`: A type-safe union that only allows access with the correct type
    * `std::get<{type}>`: Access by specifying the type
    * `std::get<{index}>`: Access by specifying the index
    * `std::variant::index()`: Records the index of the currently stored type

```cpp
#include <iostream>
#include <variant>

int main() {
    std::cout << "sizeof(std::variant<int8_t>): " << sizeof(std::variant<int8_t>) << std::endl;
    std::cout << "sizeof(std::variant<int16_t>): " << sizeof(std::variant<int16_t>) << std::endl;
    std::cout << "sizeof(std::variant<int32_t>): " << sizeof(std::variant<int32_t>) << std::endl;
    std::cout << "sizeof(std::variant<int64_t>): " << sizeof(std::variant<int64_t>) << std::endl;
    std::cout << "sizeof(std::variant<int8_t, int64_t>): " << sizeof(std::variant<int8_t, int64_t>) << std::endl;

    std::variant<int, double> v;
    v = 1;
    std::cout << "index: " << v.index() << ", value: " << std::get<int>(v) << std::endl;
    v = 1.2;
    std::cout << "index: " << v.index() << ", value: " << std::get<1>(v) << std::endl;
    return 0;
}
```

## 32.1 Dynamic Binding

`std::variant` combined with `std::visit` can achieve dynamic dispatch. Example code is as follows:

```cpp
#include <iostream>
#include <type_traits>
#include <variant>

void visit(std::variant<int, double>& v) {
    auto visitor = [](auto& item) {
        using type = std::remove_reference_t<decltype(item)>;
        if constexpr (std::is_integral_v<type>) {
            std::cout << "is integral" << std::endl;
        } else if constexpr (std::is_floating_point_v<type>) {
            std::cout << "is floating_point" << std::endl;
        }
    };
    std::visit(visitor, v);
}

int main() {
    std::variant<int, double> v;
    v = 1;
    visit(v);
    v = 1.2;
    visit(v);
    return 0;
}
```

**The general implementation principle is as follows:**

* During assignment, the `std::variant::index` property is maintained.
* Each `Visitor, variant` pair generates a `vtable` that stores all function pointers, ordered according to the declaration order of types in the `std::variant`.
* When accessing with `std::visit`, the function pointer in the `vtable` is located using `std::variant::index` and then invoked.

# 33 Containers

1. `<vector>`: Internally, it is an array. When resizing or shrinking, data is copied or moved, so the element type must have at least a copy constructor or a move constructor. For example, `std::vector<std::atomic_bool>` cannot use `push_back` or `emplace_back` to add elements.
1. `<array>`
1. `<list>`
1. `<queue>`
1. `<deque>`: Implemented using a two-level array. The first-level array stores the data, and the second-level array stores information about the first-level array (such as starting addresses). When expansion is needed, a new first-level array is added, and the existing data does not need to be moved.
1. `<map>`
1. `<unordered_map>`
1. `<set>`
1. `<unordered_set>`

## 33.1 Tips

1. Accessing `std::map` or `std::set` with an index will insert a default value if the element does not exist, so index access is non-`const`.
1. When a container expands, the element's copy constructor is called.
1. `std::vector<T> v(n)` creates `n` default-initialized elements, rather than reserving space for `n` elements.
1. Do not pass the iterator returned by the `end` method to the `erase` method.

# 34 SIMD

[Header files for x86 SIMD intrinsics](https://stackoverflow.com/questions/11228855/header-files-for-x86-simd-intrinsics)

1. `<mmintrin.h>`：MMX
1. `<xmmintrin.h>`：SSE
1. `<emmintrin.h>`：SSE2
1. `<pmmintrin.h>`：SSE3
1. `<tmmintrin.h>`：SSSE3
1. `<smmintrin.h>`：SSE4.1
1. `<nmmintrin.h>`：SSE4.2
1. `<ammintrin.h>`：SSE4A
1. `<wmmintrin.h>`：AES
1. **`<immintrin.h>`**: AVX, AVX2, FMA
    * Generally, this is sufficient as it includes the other headers mentioned above.

**Note:** `gcc` and `clang` by default prohibit the use of vectorized types and operations. When using the above headers, the corresponding compilation flags need to be specified:

* `-mmmx`
* `-msse`
* `-msse2`
* `-msse3`
* `-mssse3`
* `-msse4`
* `-msse4a`
* `-msse4.1`
* `-msse4.2`
* `-mavx`
* `-mavx2`
* `-mavx512f`
* `-mavx512pf`, supports prefetching for gather/scatter, mentioned by [Interleaved Multi-Vectorizing](/resources/paper/Interleaved-Multi-Vectorizing.pdf)
* `-mavx512er`
* `-mavx512cd`
* `-mavx512vl`
* `-mavx512bw`
* `-mavx512dq`
* `-mavx512ifma`
* `-mavx512vbmi`
* ...

# 35 C Standard Library

Since `C++` is a superset of `C`, the standard library of `C` has also been added to the `std` namespace, but the header files differ: `xxx.h -> cxxx`. Among them, `xxx.h` is the original `C` standard library header file, and its symbols are not in any namespace; `cxxx` is the corresponding `C++` version of the header file, and its symbols are in the `std` namespace.

1. `cstddef`
    * `size_t`
1. `cstdint`
    * `int8_t/int16_t/int32_t/int64_t`
1. `cerrno`: The error codes for system calls and some library functions are written to the global variable `errno`.
1. `cstdio`
    * `std::tmpnam`: Use with caution for the following reasons:
        * The tmpnam() function generates a different string each time it is called, up to TMP_MAX times. If it is called more than TMP_MAX times, the behavior is implementation defined.
    * `std::printf`
1. `cstring`
    * `std::memset`: Use `<num> * sizeof(<type>)` to obtain the length.
    * `std::memcpy`: Use `<num> * sizeof(<type>)` to obtain the length.
    * `std::strcmp`: Compare two `const char *` to check if they are identical.
1. `cstdlib`
    * **Memory Allocation Related**
        * `malloc/free`: Functions from `C` that can also be used in `C++`. `malloc` allocates memory of a specified size, and `free` releases the allocated memory.
        * `calloc`: Allocates a specified number of contiguous memory spaces and initializes them to 0.
        * `realloc`: Resizes previously allocated memory.
        * `aligned_alloc`: Allocates memory of a specified size and ensures it is aligned to a specific byte boundary.
        * `posix_memalign`: Allocates memory of a specified size and ensures it is aligned to a specified byte boundary.
        * `memalign`: Allocates memory of a specified size and ensures it is aligned to a specific byte boundary.
        * `valloc`: Allocates memory of a specified size and ensures it is aligned to the page size.
        * `pvalloc`: Allocates memory of a specified size and ensures it is aligned to the page size.
    * `std::atexit`: Registers a hook method to be called upon program exit.
    * `std::system`: Used to execute commands.
    * `std::mkstemp`: Creates a temporary file, requiring a filename template where the last six characters are `XXXXXX`, which will be replaced by random characters.
    * `std::atoi`
    * `std::atol`
    * `std::atoll`
    * `std::getenv`
    * `setenv`: A POSIX API, not included in the C++ standard library.
1. `cctype`
    * `std::isblank`: Returns true only for spaces and horizontal tabs.
    * `std::isspace`: Returns true for spaces, form feed, newline, carriage return, horizontal tab, and vertical tab.
1. POSIX headers
    1. `fcntl.h`: Provides an interface for controlling file descriptors. It includes constants and function declarations for working with file descriptors, managing file locks, and configuring file options.
    1. `unistd.h`: (Unix Standard) Provides access to the POSIX (Portable Operating System Interface) operating system API. It is available on Unix-based operating systems (like Linux and macOS) and offers a collection of system calls and library functions for various low-level operations.
        * General POSIX functions like `fork`, `exec`, `pipe`, `getpid`.
        * File operations: `read`, `write`, `close`, `lseek`.
        * Process management: `getuid`, `setuid`.
    1. `signal.h`: Provides signal handling: `signal`, `sigaction`, `raise`.
    1. `pthread.h`: Provides thread operations: `pthread_create`, `pthread_join`, `pthread_mutex_lock`.
    1. `sys/stat.h`: Provides file status functions: `stat`, `fstat`, `lstat`.

## 35.1 csignal

All signals are defined in the `signum.h` header file.

The following example code is used to catch `OOM` and output the process status at that time:

* Use optimization level `O0`, otherwise `v.reserve` may be optimized away
* `ulimit -v 1000000`: Sets the maximum memory for the process
* `./main <size>`: Continuously increase `size`, and you can observe that `VmPeak` and `VmSize` keep increasing. When `OOM` is triggered, both `VmPeak` and `VmSize` are small and do not include the memory of the object that caused the `OOM`.

```cpp
#include <csignal>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>

void display_self_status() {
    std::ifstream in("/proc/self/status");
    constexpr size_t BUFFER_SIZE = 512;
    char buf[BUFFER_SIZE];

    while (!in.eof()) {
        in.getline(buf, BUFFER_SIZE);
        std::cout << buf << std::endl;
    }

    in.close();
}

void func(int sig) {
    std::cout << "Cath a signal, sig=" << sig << std::endl;
    display_self_status();
    exit(sig);
}

int main(int argc, char* argv[]) {
    for (int sig = SIGHUP; sig <= SIGSYS; sig++) {
        signal(sig, func);
    }

    display_self_status();

    // trigger OOM
    std::vector<int64_t> v;
    v.reserve(std::atoi(argv[1]));

    display_self_status();

    return 0;
}
```

## 35.2 cstring

* `std::strcmp`
* `std::strcpy`
* `std::memcmp`
* `std::memcpy`
* `std::memmove`

## 35.3 Execute Command

```cpp
#include <cstdlib>
#include <fstream>
#include <iostream>

int main() {
    char file_name[] = "/tmp/fileXXXXXX";
    mkstemp(file_name);
    std::cout << "tmp_file=" << file_name << std::endl;
    std::system(("ls -l > " + std::string(file_name)).c_str());
    std::cout << std::ifstream(file_name).rdbuf();
    return 0;
}
```

# 36 Builtin Functions

[6.63 Other Built-in Functions Provided by GCC](https://gcc.gnu.org/onlinedocs/gcc/Other-Builtins.html)

1. `__builtin_unreachable`
1. `__builtin_prefetch`
1. `__builtin_expect`
    * `#define LIKELY(x) __builtin_expect(!!(x), 1)`
    * `#define UNLIKELY(x) __builtin_expect(!!(x), 0)`
1. `__builtin_bswap32`: Perform a byte-swap operation on a 32-bit integer. Byte-swapping reverses the byte order of a value, which is useful for handling data in systems with different endianness (e.g., converting between big-endian and little-endian formats).
1. `__builtin_offsetof(type, member)`: Calculate member's offset.
    * One alternative implementation is: `#define my_offsetof(type, member) ((size_t) & (((type*)0)->member))`

# 37 Frequently-Used Compoments for Interview

**Data Structure:**

* `std::vector`
* `std::list`
    * `splice`
* `std::map`
* `std::set`
* `std::stack`
* `std::queue`
* `std::priority_queue`

**Algorithm:**

* `std::sort`
* `std::lower_bound`,`std::upper_bound` : binary search.
* `std::find`
* `std::remove_if`: return the iterator pointing at the first elements to be removed.
* `std::erase_if`: remove the specific elements.
* `std::set_intersection`、`std::set_union`、`std::set_difference`

**Function Objects:**

* `std::hash`
* `std::less`/`std::less_equals`/`std::greater`/`std::greater_equal`
* `std::equal_to`

**I/O:**

* `std::ifstream`、`std::ofstream`
* `std::getline`
* `std::get_time`、`std::put_time`
