---
title: Algorithm-Assorted
date: 2019-10-04 16:15:22
tags: 
- 原创
categories: 
- Algorithm
---

# 1 Reservoir Sampling

```cpp
#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>

// Function to perform reservoir sampling
std::vector<int> reservoirSampling(std::vector<int>& stream, int k) {
    std::vector<int> reservoir(k);
    int n = stream.size();

    // Fill the reservoir with the first k elements from the stream
    for (int i = 0; i < k; ++i) {
        reservoir[i] = stream[i];
    }

    // Iterate through the remaining elements in the stream
    for (int i = k; i < n; ++i) {
        // Generate a random number between 0 and i (inclusive)
        int j = std::rand() % (i + 1);

        // If j is less than k, replace the j-th element in the reservoir with the current element
        if (j < k) {
            reservoir[j] = stream[i];
        }
    }

    return reservoir;
}

int main() {
    // Seed the random number generator with the current time
    std::srand(std::time(0));

    // Example stream of data
    std::vector<int> dataStream = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

    // Number of samples to select
    int k = 3;

    // Perform reservoir sampling
    std::vector<int> sampledData = reservoirSampling(dataStream, k);

    // Print the sampled data
    std::cout << "Sampled Data: ";
    for (int i = 0; i < k; ++i) {
        std::cout << sampledData[i] << " ";
    }
    std::cout << std::endl;

    return 0;
}
```
