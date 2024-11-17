---
title: Linux-IO
date: 2024-06-18 13:41:34
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

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

# 2 Classic I/O Models

## 2.1 Blocking I/O

Blocking I/O waits until the data is available before returning.

```cpp
#include <fcntl.h>
#include <unistd.h>

#include <cstdio>

int main() {
    int fd = open("example.txt", O_RDONLY);
    if (fd == -1) {
        perror("open");
        return 1;
    }

    char buffer[1024];
    ssize_t bytes_read = read(fd, buffer, sizeof(buffer)); // Blocks until data is available
    if (bytes_read > 0) {
        buffer[bytes_read] = '\0'; // Null-terminate the buffer
        printf("Read: %s\n", buffer);
    } else {
        perror("read");
    }

    close(fd);
    return 0;
}
```

## 2.2 Non-Blocking I/O

Non-blocking I/O returns immediately if no data is available, requiring error handling.

```cpp
#include <fcntl.h>
#include <unistd.h>

#include <cerrno>
#include <cstdio>

int main() {
    int fd = open("example.txt", O_RDONLY | O_NONBLOCK); // Set non-blocking flag
    if (fd == -1) {
        perror("open");
        return 1;
    }

    char buffer[1024];
    ssize_t bytes_read = read(fd, buffer, sizeof(buffer));
    if (bytes_read == -1) {
        if (errno == EAGAIN || errno == EWOULDBLOCK) {
            printf("No data available (non-blocking mode)\n");
        } else {
            perror("read");
        }
    } else {
        buffer[bytes_read] = '\0';
        printf("Read: %s\n", buffer);
    }

    close(fd);
    return 0;
}
```

## 2.3 I/O Multiplexing

I/O multiplexing allows you to monitor multiple file descriptors at once.

### 2.3.1 select

```cpp
#include <fcntl.h>
#include <sys/select.h>
#include <unistd.h>

#include <algorithm>
#include <cstdio>
#include <cstring>

int main() {
    // Open two files in non-blocking mode
    int fd1 = open("example1.txt", O_RDONLY | O_NONBLOCK);
    int fd2 = open("example2.txt", O_RDONLY | O_NONBLOCK);

    if (fd1 == -1 || fd2 == -1) {
        perror("open");
        if (fd1 != -1) close(fd1);
        if (fd2 != -1) close(fd2);
        return 1;
    }

    // Set up file descriptor set
    fd_set read_fds;
    int max_fd = std::max(fd1, fd2) + 1;

    printf("Monitoring example1.txt and example2.txt for readability...\n");

    while (true) {
        // Clear the file descriptor set and add our fds
        FD_ZERO(&read_fds);
        FD_SET(fd1, &read_fds);
        FD_SET(fd2, &read_fds);

        // Wait for data to become available on either file
        int result = select(max_fd, &read_fds, nullptr, nullptr, nullptr);
        if (result == -1) {
            perror("select");
            break;
        }

        // Check which file descriptor is ready
        if (FD_ISSET(fd1, &read_fds)) {
            char buffer[1024];
            ssize_t bytes_read = read(fd1, buffer, sizeof(buffer) - 1);
            if (bytes_read > 0) {
                buffer[bytes_read] = '\0';
                printf("Read from example1.txt: %s\n", buffer);
            } else if (bytes_read == 0) {
                printf("EOF reached on example1.txt\n");
                close(fd1);
                FD_CLR(fd1, &read_fds); // Remove fd1 from the set
            } else {
                perror("read from example1.txt");
            }
        }

        if (FD_ISSET(fd2, &read_fds)) {
            char buffer[1024];
            ssize_t bytes_read = read(fd2, buffer, sizeof(buffer) - 1);
            if (bytes_read > 0) {
                buffer[bytes_read] = '\0';
                printf("Read from example2.txt: %s\n", buffer);
            } else if (bytes_read == 0) {
                printf("EOF reached on example2.txt\n");
                close(fd2);
                FD_CLR(fd2, &read_fds); // Remove fd2 from the set
            } else {
                perror("read from example2.txt");
            }
        }

        // Exit if both files are closed
        if (fd1 == -1 && fd2 == -1) {
            break;
        }
    }

    return 0;
}
```

### 2.3.2 epoll

```cpp
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cstdio>
#include <cstring>

#define MAX_EVENTS 10
#define PORT 8080

int main() {
    int epoll_fd = epoll_create1(0); // Create epoll instance
    if (epoll_fd == -1) {
        perror("epoll_create1");
        return 1;
    }

    // Create a listening socket
    int server_fd = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
    if (server_fd == -1) {
        perror("socket");
        close(epoll_fd);
        return 1;
    }

    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(PORT);

    // Bind and listen on the socket
    if (bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind");
        close(server_fd);
        close(epoll_fd);
        return 1;
    }

    if (listen(server_fd, 1) == -1) {
        perror("listen");
        close(server_fd);
        close(epoll_fd);
        return 1;
    }

    // Register the server socket with epoll to watch for incoming connections
    struct epoll_event ev;
    ev.events = EPOLLIN;
    ev.data.fd = server_fd;
    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, server_fd, &ev) == -1) {
        perror("epoll_ctl: server_fd");
        close(server_fd);
        close(epoll_fd);
        return 1;
    }

    struct epoll_event events[MAX_EVENTS];
    printf("Waiting for events on port %d...\n", PORT);

    while (true) {
        int num_events = epoll_wait(epoll_fd, events, MAX_EVENTS, -1);
        if (num_events == -1) {
            perror("epoll_wait");
            break;
        }

        for (int i = 0; i < num_events; i++) {
            if (events[i].data.fd == server_fd) {
                // Accept a new connection
                int client_fd = accept(server_fd, nullptr, nullptr);
                if (client_fd == -1) {
                    perror("accept");
                    continue;
                }

                // Make the client socket non-blocking
                fcntl(client_fd, F_SETFL, O_NONBLOCK);

                // Register the client socket with epoll
                struct epoll_event client_ev;
                client_ev.events = EPOLLIN;
                client_ev.data.fd = client_fd;
                if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, client_fd, &client_ev) == -1) {
                    perror("epoll_ctl: client_fd");
                    close(client_fd);
                    continue;
                }

                printf("Accepted new connection\n");
            } else {
                // Handle data from a client socket
                int client_fd = events[i].data.fd;
                char buffer[1024];
                ssize_t bytes_read = read(client_fd, buffer, sizeof(buffer) - 1);
                if (bytes_read > 0) {
                    buffer[bytes_read] = '\0';
                    printf("Received from client: %s\n", buffer);
                    // Echo the data back to the client
                    write(client_fd, buffer, bytes_read);
                } else if (bytes_read == 0) {
                    printf("Client disconnected\n");
                    epoll_ctl(epoll_fd, EPOLL_CTL_DEL, client_fd, nullptr);
                    close(client_fd);
                } else {
                    perror("read");
                }
            }
        }
    }

    close(server_fd);
    close(epoll_fd);
    return 0;
}
```

## 2.4 Signal-Driven I/O

Signal-driven I/O uses a signal handler to be notified when the file descriptor is ready.

```cpp
#include <fcntl.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <csignal>
#include <cstdio>
#include <cstring>

int server_fd, client_fd; // Global variables to access the socket in the signal handler

// Signal handler for SIGIO
void sigio_handler(int signo) {
    if (signo == SIGIO && client_fd != -1) {
        char buffer[1024];
        ssize_t bytes_read = read(client_fd, buffer, sizeof(buffer) - 1);
        if (bytes_read > 0) {
            buffer[bytes_read] = '\0';
            printf("Received from client: %s\n", buffer);
            // Echo the message back to the client
            write(client_fd, buffer, bytes_read);
        } else if (bytes_read == 0) {
            printf("Closing client socket %d\n", client_fd);
            close(client_fd);
            client_fd = -1; // Mark client as disconnected
        } else {
            perror("read");
        }
    }
}

int main() {
    // Create a server socket
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    if (server_fd == -1) {
        perror("socket");
        return 1;
    }

    // Bind the socket to an address and port
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(8080);

    if (bind(server_fd, (struct sockaddr*)&server_addr, sizeof(server_addr)) == -1) {
        perror("bind");
        close(server_fd);
        return 1;
    }

    // Listen for incoming connections
    if (listen(server_fd, 1) == -1) {
        perror("listen");
        close(server_fd);
        return 1;
    }

    printf("Waiting for a connection on port 8080...\n");

    // Accept a client connection (this will initially block until a client connects)
    client_fd = accept(server_fd, nullptr, nullptr);
    if (client_fd == -1) {
        perror("accept");
        close(server_fd);
        return 1;
    }
    printf("Client connected!\n");

    // Set client socket to non-blocking mode and enable asynchronous I/O
    fcntl(client_fd, F_SETFL, O_NONBLOCK | O_ASYNC);

    // Set up the signal handler for SIGIO
    struct sigaction sa;
    sa.sa_handler = sigio_handler;
    sa.sa_flags = 0;
    sigemptyset(&sa.sa_mask);
    if (sigaction(SIGIO, &sa, nullptr) == -1) {
        perror("sigaction");
        close(client_fd);
        close(server_fd);
        return 1;
    }

    // Set the process to be the owner of the socket file descriptor for SIGIO signals
    fcntl(client_fd, F_SETOWN, getpid());

    printf("Waiting for SIGIO events...\n");

    // Keep the program running to receive and handle signals
    while (client_fd != -1) {
        pause(); // Wait for signals
    }

    close(server_fd);
    return 0;
}
```

## 2.5 Asynchronous I/O (AIO)

Asynchronous I/O allows you to start the I/O and be notified when it's done without waiting.

```cpp
#include <aio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

// AIO completion handler
void aio_completion_handler(sigval_t sigval) {
    struct aiocb* req = static_cast<struct aiocb*>(sigval.sival_ptr);
    if (aio_error(req) == 0) {
        ssize_t bytes_read = aio_return(req); // Check bytes read
        if (bytes_read > 0) {
            ((char*)req->aio_buf)[bytes_read] = '\0';
            printf("Read (AIO): %s\n", static_cast<volatile char*>(req->aio_buf));
        }
    } else {
        perror("aio_error");
    }
    free((void*)req->aio_buf); // Free buffer memory
    free(req);                 // Free request struct
}

int main() {
    int fd = open("example.txt", O_RDONLY);
    if (fd == -1) {
        perror("open");
        return 1;
    }

    // Allocate memory for aiocb structure
    struct aiocb* cb = static_cast<struct aiocb*>(malloc(sizeof(struct aiocb)));
    memset(cb, 0, sizeof(struct aiocb));
    cb->aio_fildes = fd;
    cb->aio_nbytes = 1024;
    cb->aio_buf = malloc(1024); // Allocate buffer for data
    cb->aio_offset = 0;

    // Set up notification for AIO completion using a thread
    cb->aio_sigevent.sigev_notify = SIGEV_THREAD;
    cb->aio_sigevent.sigev_notify_function = aio_completion_handler;
    cb->aio_sigevent.sigev_notify_attributes = nullptr;
    cb->aio_sigevent.sigev_value.sival_ptr = cb;

    // Start asynchronous read
    if (aio_read(cb) == -1) {
        perror("aio_read");
        free((void*)cb->aio_buf);
        free(cb);
        close(fd);
        return 1;
    }

    // Keep the process running until the AIO completes
    printf("Waiting for AIO completion...\n");
    pause(); // Wait for AIO completion signal
    close(fd);
    return 0;
}
```

## 2.6 I/O Uring

io_uring is a high-performance asynchronous I/O framework introduced in Linux kernel 5.1 to improve I/O efficiency and performance. Developed by Jens Axboe, io_uring aims to provide a more efficient and flexible interface for asynchronous I/O operations by leveraging ring buffers for communication between user space and kernel space, minimizing the need for system calls, and reducing context switching.

```cpp
#include <fcntl.h>
#include <liburing.h>
#include <unistd.h>

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#define QUEUE_DEPTH 1
#define BUFFER_SIZE 1024

int main() {
    struct io_uring ring;
    struct io_uring_cqe* cqe;
    struct io_uring_sqe* sqe;
    int fd;
    char buffer[BUFFER_SIZE] = {0};

    // Open the file to read
    fd = open("example.txt", O_RDONLY);
    if (fd < 0) {
        perror("open");
        return 1;
    }

    // Initialize io_uring with a single-entry queue
    if (io_uring_queue_init(QUEUE_DEPTH, &ring, 0) < 0) {
        perror("io_uring_queue_init");
        close(fd);
        return 1;
    }

    // Get a submission queue entry (SQE)
    sqe = io_uring_get_sqe(&ring);
    if (!sqe) {
        fprintf(stderr, "Failed to get SQE\n");
        io_uring_queue_exit(&ring);
        close(fd);
        return 1;
    }

    // Prepare the SQE for a read operation
    io_uring_prep_read(sqe, fd, buffer, BUFFER_SIZE, 0);

    // Submit the SQE to the queue
    if (io_uring_submit(&ring) < 0) {
        perror("io_uring_submit");
        io_uring_queue_exit(&ring);
        close(fd);
        return 1;
    }

    // Wait for the completion queue entry (CQE)
    if (io_uring_wait_cqe(&ring, &cqe) < 0) {
        perror("io_uring_wait_cqe");
        io_uring_queue_exit(&ring);
        close(fd);
        return 1;
    }

    // Check the result of the operation
    if (cqe->res < 0) {
        fprintf(stderr, "Async read failed: %s\n", strerror(-cqe->res));
    } else {
        printf("Read %d bytes: %s\n", cqe->res, buffer);
    }

    // Mark CQE as seen
    io_uring_cqe_seen(&ring, cqe);

    // Clean up
    io_uring_queue_exit(&ring);
    close(fd);

    return 0;
}
```
