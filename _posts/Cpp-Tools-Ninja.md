---
title: Cpp-Tools-Ninja
date: 2021-09-25 12:01:33
tags: 
- 原创
categories: 
- Cpp
---

**阅读更多**

<!--more-->

# 1 Install

[ninja-releases](https://github.com/ninja-build/ninja/releases)

```sh
wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip
unzip ninja-linux.zip
mv ninja /usr/local/bin/ninja
```

# 2 How to work with CMake

```sh
cmake -B build -G Ninja
```

# 3 Tips

## 3.1 Check Target

* `ninja -C build -t targets`
* `cat build/build.ninja | grep 'build all:'`
