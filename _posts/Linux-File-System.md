---
title: Linux-File-System
date: 2017-08-15 20:25:40
tags: 
- 原创
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 Core Concepts

* **`Inode`**: Data structures that store metadata about files, such as file size, ownership, permissions, and timestamps, but not the file name or data
* **`Superblock`**: A metadata structure that contains information about the filesystem as a whole, including its size, the size of the blocks, the number of inodes, and pointers to other metadata structures
* **`Mounting`**: The process of attaching a filesystem to the directory tree at a specified mount point, allowing access to the files and directories in that filesystem
* **`Permissions and Ownership`**: Each file and directory has associated permissions (`read`, `write`, `execute`) and ownership (`user`, `group`, `others`), controlling access and modifications
* **`File Types`**: Regular files, directories, symbolic links, special files (character and block devices), sockets, and named pipes (FIFOs)
* **`Hard Links`**: Multiple directory entries that reference the same inode
* **`Symbolic Links (Symlinks)`**: Special files that reference another file or directory by path
* **`Filesystem Types`**: Various types of filesystems supported by Linux, such as ext4, XFS, Btrfs, and others, each with its own features and use cases
* **`Virtual File System (VFS)`**: An abstraction layer that provides a common interface for different filesystem types, allowing uniform access to different storage devices and filesystems
* **`Block Devices and Block Size`**: Storage devices (like hard drives and SSDs) managed in blocks, which are the smallest unit of data transfer
* **`Journal`**：A feature in journaling filesystems (e.g., `ext3`, `ext4`)
* **`Filesystem Checks and Repair`**: Utilities like `fsck` to check and repair filesystem integrity

## 1.1 Ext Filesystem

* **`Superblock`**
    * Stores critical data structures of the file system, including its size, block size, number of free blocks, and inodes
    * Read into memory when the file system is mounted
* **`Block Group`**
    * The file system is divided into several block groups, each containing a fixed number of blocks
    * Each block group includes data blocks, an inode table, a block bitmap, and an inode bitmap
* **`Data Block`**
    * Blocks used to store the actual file data
    * Block sizes are typically `1KB`, `2KB`, `4KB`, or `8KB`
* **`Inode (Index Node)`**
    * Stores metadata about files and directories, including file type, permissions, owner, size, timestamps, and pointers to data blocks
    * Each file and directory has a unique inode
* **`Block Bitmap`**
    * Records which data blocks in a block group are used and which are free
* **`Inode Bitmap`**
    * Records which inodes in a block group are used and which are free
* **`Inode Table`**
    * An array containing all the inodes in the file system, with each inode representing a file or directory's metadata
* **`Directory Entry`**
    * Links file names in a directory to their corresponding inode numbers
* **`Journal`**
    * Available in `Ext3` and `Ext4`, it logs metadata operations to enhance file system reliability and recovery
* **`Extended Attributes`**
    * Allow users and applications to add extra metadata to files
* **`Disk Quotas`**
    * Control the amount of disk space and number of inodes that users and groups can use in the file system
* **`Reserved Blocks`**
    * Typically reserve some blocks for the system administrator to prevent the file system from being completely filled by regular users, which could affect system operations

# 2 Trouble-shooting

## 2.1 inode

**Observations:**

* The more the number of `inodes`, the lower the reading performance will be, and read performance can be significantly affected when number of `inode` reaches million level

**Tools:**

* `df -ih`
* `ls -i`

## 2.2 superblock

**Tools:**

* `sudo dumpe2fs /dev/sda | grep -i superblock`

# 3 Reference

* [Linux 操作系统原理-文件系统(1).md](https://github.com/0voice/linux_kernel_wiki/blob/main/%E6%96%87%E7%AB%A0/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F/Linux%20%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E5%8E%9F%E7%90%86-%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F(1).md)
* [Linux 操作系统原理-文件系统(2).md](https://github.com/0voice/linux_kernel_wiki/blob/main/%E6%96%87%E7%AB%A0/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F/Linux%20%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F%E5%8E%9F%E7%90%86-%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F(2).md)
* [Linux内核文件系统挂载.md](https://github.com/0voice/linux_kernel_wiki/blob/main/%E6%96%87%E7%AB%A0/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F/Linux%E5%86%85%E6%A0%B8%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F%E6%8C%82%E8%BD%BD.md)
