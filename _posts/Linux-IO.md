---
title: Linux-IO
date: 2024-06-18 13:41:34
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

# 1 Terms

1. `Standard I/O`: Basic read and write operations using standard C library functions.
1. `Buffered I/O`: Uses buffers to minimize the number of read and write operations.
1. `Unbuffered I/O`: Directly interacts with the underlying hardware without buffering.
1. `Zero-Copy`: Techniques that avoid copying data between buffers in the kernel and user space, such as sendfile, splice, and mmap.
1. `Direct I/O`: Bypasses the OS cache, allowing data to be transferred directly between user space and the storage device.
1. `Memory-Mapped I/O (mmap)`: Maps files or devices into memory, enabling applications to access them as if they were in memory.
1. `Asynchronous I/O (AIO)`: Allows operations to be performed without blocking the executing thread, using functions like io_submit and io_getevents.
1. `Synchronous I/O`: Operations that block the executing thread until they are completed.
1. `Blocking I/O`: The default behavior where system calls wait for operations to complete before returning.
1. `Non-blocking I/O`: System calls return immediately if an operation cannot be completed, using mechanisms like select, poll, and epoll.
1. `Scatter-Gather I/O`: Allows data to be transferred between non-contiguous memory areas and a single I/O operation.
1. `Kernel I/O Subsystem`: The part of the Linux kernel responsible for managing I/O operations.
1. `Character Device I/O`: Interfaces with devices that handle data as a stream of characters.
1. `Block Device I/O`: Interfaces with devices that handle data in fixed-size blocks.
1. `Network I/O`: Handling data transfer over network connections.
1. `DMA (Direct Memory Access)`: Allows devices to transfer data directly to and from memory without CPU involvement.
1. `I/O Scheduling`: The method by which the kernel decides the order in which I/O operations are executed.
1. `I/O Priorities`: Assigning priorities to I/O operations to influence their order of execution.
1. `IOCTL (Input/Output Control)`: System calls for device-specific input/output operations and other operations which cannot be expressed by regular system calls.
1. `Device Drivers`: Kernel modules that manage communication with hardware devices.

## 1.1 mmap vs. sequential I/O

