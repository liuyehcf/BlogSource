---
title: Netty-ByteBuf
date: 2019-03-27 20:37:53
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__阅读更多__

<!--more-->

# 1 Direct Buffer

通俗来说，`Direct Buffer`就是一块在Java堆外分配的，但是可以在Java程序中访问的内存

```Java
    public static void main(String[] args) {
        ByteBuffer dorectButeBiffer = ByteBuffer.allocateDirect(1024);
        ByteBuffer heapByteBuffer = ByteBuffer.allocate(1024);
    }

    public static ByteBuffer allocate(int capacity) {
        if (capacity < 0)
            throw new IllegalArgumentException();
        return new HeapByteBuffer(capacity, capacity);
    }

    public static ByteBuffer allocateDirect(int capacity) {
        return new DirectByteBuffer(capacity);
    }
```

# 2 参考

* [Direct Buffer](https://zhuanlan.zhihu.com/p/27625923)
