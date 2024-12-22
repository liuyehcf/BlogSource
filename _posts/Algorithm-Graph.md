---
title: Algorithm-Graph
date: 2017-01-19 15:55:23
tags: 
- 摘录
categories: 
- Algorithm
- Graph
---

**阅读更多**

<!--more-->

# 1 Question-207[★★★★★]

```cpp
#include <cstddef>
#include <cstdint>
#include <queue>
#include <set>
#include <vector>

class Solution {
public:
    bool canFinish(int num_courses, std::vector<std::vector<int32_t>>& prerequisites) {
        std::vector<std::set<int32_t>> neighbors(num_courses);
        std::vector<int32_t> degree(num_courses, 0);
        for (auto& prerequisite : prerequisites) {
            int32_t next = prerequisite[0];
            int32_t prev = prerequisite[1];
            neighbors[prev].insert(next);
            degree[next]++;
        }

        std::queue<int32_t> queue;
        size_t visited = 0;

        for (size_t i = 0; i < num_courses; ++i) {
            if (degree[i] == 0) {
                visited++;
                queue.push(i);
            }
        }

        while (!queue.empty()) {
            int32_t cur = queue.front();
            queue.pop();
            for (const auto& next : neighbors[cur]) {
                if (--degree[next] == 0) {
                    visited++;
                    queue.push(next);
                }
            }
        }

        return visited == num_courses;
    }
};
```

# 2 Question-210[★★★★★]

```cpp
#include <cstddef>
#include <cstdint>
#include <queue>
#include <set>
#include <vector>

class Solution {
public:
    std::vector<int32_t> findOrder(int num_courses, std::vector<std::vector<int32_t>>& prerequisites) {
        std::vector<std::set<int32_t>> neighbors(num_courses);
        std::vector<int32_t> degree(num_courses, 0);
        for (auto& prerequisite : prerequisites) {
            int32_t next = prerequisite[0];
            int32_t prev = prerequisite[1];
            neighbors[prev].insert(next);
            degree[next]++;
        }

        std::queue<int32_t> queue;
        std::vector<int32_t> order;
        size_t visited = 0;

        for (size_t i = 0; i < num_courses; ++i) {
            if (degree[i] == 0) {
                visited++;
                queue.push(i);
                order.push_back(i);
            }
        }

        while (!queue.empty()) {
            int32_t cur = queue.front();
            queue.pop();
            for (const auto& next : neighbors[cur]) {
                if (--degree[next] == 0) {
                    visited++;
                    queue.push(next);
                    order.push_back(next);
                }
            }
        }

        return (visited == num_courses) ? order : std::vector<int32_t>();
    }
};
```

## 2.1 Find All Orders

```cpp
#include <cstdint>
#include <set>
#include <vector>

class Solution {
public:
    std::vector<int32_t> findOrder(int num_courses, std::vector<std::vector<int32_t>>& prerequisites) {
        std::vector<std::set<int32_t>> neighbors(num_courses);
        std::vector<int32_t> degree(num_courses, 0);
        for (auto& prerequisite : prerequisites) {
            int32_t next = prerequisite[0];
            int32_t prev = prerequisite[1];
            neighbors[prev].insert(next);
            degree[next]++;
        }

        std::set<int32_t> candidates;
        for (int32_t i = 0; i < num_courses; ++i) {
            if (degree[i] == 0) {
                candidates.insert(i);
            }
        }

        std::vector<std::vector<int32_t>> orders;
        std::vector<int32_t> order;

        findAllOrders(orders, order, neighbors, degree, candidates);
        if (orders.empty()) {
            return {};
        } else {
            return orders[0];
        }
    }

private:
    void findAllOrders(std::vector<std::vector<int32_t>>& orders, std::vector<int32_t>& order,
                       const std::vector<std::set<int32_t>>& neighbors, std::vector<int32_t>& degree,
                       std::set<int32_t>& candidates) {
        std::vector<int32_t> candidates_copy(candidates.begin(), candidates.end());
        for (const auto candidate : candidates_copy) {
            order.push_back(candidate);
            candidates.erase(candidate);

            // Check if this is a complete order
            bool complete = (order.size() == degree.size());
            if (complete) {
                orders.push_back(order);
            } else {
                // Explore neighbors
                for (const auto neighbor : neighbors[candidate]) {
                    if (--degree[neighbor] == 0) {
                        candidates.insert(neighbor);
                    }
                }

                findAllOrders(orders, order, neighbors, degree, candidates);
            }

            // Backtrack
            order.pop_back();
            candidates.insert(candidate);
            if (!complete) {
                for (const auto neighbor : neighbors[candidate]) {
                    if (++degree[neighbor] == 1) {
                        candidates.erase(neighbor);
                    }
                }
            }
        }
    }
};
```

# 3 Tiktok Interview Problem

The task is to implement an algorithm to generate all possible valid topological orderings of a Directed Acyclic Graph (DAG).

A Directed Acyclic Graph (DAG) consists of nodes connected by directed edges, with no cycles present. Each node has a unique identifier (id) and may have directed edges pointing to other nodes (neighbors).

Input:

* A list of nodes in the graph (graph), where each node contains:
* An integer id representing the node's unique identifier.
* A list of neighbors that the current node points to.

Output:

* All valid topological orderings of the graph, where:
* A topological ordering is a linear ordering of the graph's nodes such that for every directed edge `u -> v`, node `u` appears before node `v` in the ordering.

```cpp
#include <iostream>
#include <iterator>
#include <set>
#include <vector>

struct DirectedGraphNode {
    int32_t id;
    std::vector<DirectedGraphNode*> neighbors;
    DirectedGraphNode(int32_t x) : id(x){};
};

void visit(const std::vector<DirectedGraphNode>& graph, std::vector<std::vector<int32_t>>& paths,
           std::vector<int32_t>& path, std::vector<int32_t>& next_ids, std::vector<int32_t>& degree) {
    std::set<int32_t> visited;

    for (size_t i = 0; i < next_ids.size(); i++) {
        auto& node = graph[next_ids[i]];

        if (degree[node.id] > 0) {
            continue;
        }

        auto it = visited.insert(node.id);
        if (!it.second) {
            continue;
        }

        path.push_back(node.id);

        if (path.size() == graph.size()) {
            paths.push_back(path);
            path.resize(path.size() - 1);
            continue;
        }

        for (auto* neighbor : node.neighbors) {
            int32_t backup = next_ids[i];

            next_ids[i] = neighbor->id;
            degree[neighbor->id]--;

            visit(graph, paths, path, next_ids, degree);

            next_ids[i] = backup;
            degree[neighbor->id]++;
        }

        path.resize(path.size() - 1);
    }
}

void printAll(std::vector<DirectedGraphNode>& graph) {
    std::set<int32_t> all_ids;
    std::vector<int32_t> degree(graph.size(), 0);
    for (auto& node : graph) {
        all_ids.insert(node.id);
        for (auto* next : node.neighbors) {
            degree[next->id]++;
        }
    }

    std::vector<int32_t> next_ids;
    for (auto& id : all_ids) {
        if (degree[id] == 0) {
            next_ids.push_back(id);
        }
    }

    std::vector<std::vector<int32_t>> paths;
    std::vector<int32_t> path;

    visit(graph, paths, path, next_ids, degree);

    for (auto& path : paths) {
        std::copy(path.begin(), path.end(), std::ostream_iterator<int32_t>(std::cout, "->"));
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

int main() {
    std::vector<DirectedGraphNode> graph;
    graph.emplace_back(0);
    graph.emplace_back(1);
    graph.emplace_back(2);
    graph.emplace_back(3);
    graph[0].neighbors.push_back(&graph[1]);
    graph[1].neighbors.push_back(&graph[2]);
    graph[3].neighbors.push_back(&graph[2]);

    printAll(graph);

    return 0;
}
```

Or another simpler version:

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <set>
#include <vector>

struct DirectedGraphNode {
    int32_t id;
    std::vector<DirectedGraphNode*> neighbors;
    DirectedGraphNode(int32_t x) : id(x){};
};

void visit(const std::vector<DirectedGraphNode>& graph, std::vector<std::vector<int32_t>>& paths,
           std::vector<int32_t>& path, std::vector<int32_t>& degree, std::set<int32_t>& candidates) {
    std::vector<int32_t> candidates_copy(candidates.begin(), candidates.end());
    for (const auto candidate : candidates_copy) {
        auto& node = graph[candidate];
        path.push_back(node.id);
        candidates.erase(node.id);

        // Check if this is a complete order
        bool complete = (path.size() == graph.size());
        if (complete) {
            paths.push_back(path);
        } else {
            // Explore neighbors
            for (auto* neighbor : node.neighbors) {
                if (--degree[neighbor->id] == 0) {
                    candidates.insert(neighbor->id);
                }
            }

            visit(graph, paths, path, degree, candidates);
        }

        // Backtrack
        path.pop_back();
        candidates.insert(node.id);
        if (!complete) {
            for (auto* neighbor : node.neighbors) {
                if (++degree[neighbor->id] == 1) {
                    candidates.erase(neighbor->id);
                }
            }
        }
    }
}

void printAll(std::vector<DirectedGraphNode>& graph) {
    std::set<int32_t> all_ids;
    std::vector<int32_t> degree(graph.size(), 0);
    for (auto& node : graph) {
        all_ids.insert(node.id);
        for (auto* next : node.neighbors) {
            degree[next->id]++;
        }
    }

    std::vector<std::vector<int32_t>> paths;
    std::vector<int32_t> path;
    std::set<int32_t> candidates;
    for (const auto id : all_ids) {
        if (degree[id] == 0) {
            candidates.insert(id);
        }
    }
    visit(graph, paths, path, degree, candidates);

    for (auto& path : paths) {
        std::copy(path.begin(), path.end(), std::ostream_iterator<int32_t>(std::cout, "->"));
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

int main() {
    std::vector<DirectedGraphNode> graph;
    graph.emplace_back(0);
    graph.emplace_back(1);
    graph.emplace_back(2);
    graph.emplace_back(3);
    graph[0].neighbors.push_back(&graph[1]);
    graph[1].neighbors.push_back(&graph[2]);
    graph[3].neighbors.push_back(&graph[2]);

    printAll(graph);

    return 0;
}
```
