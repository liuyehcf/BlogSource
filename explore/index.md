---
title: explore
date: 2018-02-05 09:25:59
---

# 1 GNU

* [Free the Software](https://sourceware.org/) - ★★★★★
    * [GNU Binutils](https://sourceware.org/binutils/)
        * [Using as](https://sourceware.org/binutils/docs/as/index.html)
* [GNU Manuals Online](https://www.gnu.org/manual/manual.html)
    * [Using the GNU Compiler Collection (GCC)](https://gcc.gnu.org/onlinedocs/gcc/)
* [GNU FTP](https://ftp.gnu.org)

# 2 Cpp

* [News, Status & Discussion about Standard C++](https://isocpp.org/) - ★★★★★
    * [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
    * [C++ FAQ](https://isocpp.org/faq)
        * [Conferences Worldwide](https://isocpp.org/wiki/faq/conferences-worldwide/)
* [CppCon](https://cppcon.org/)
    * [CppCon-Download](https://github.com/CppCon)
    * [Branchless Programming in C++ - Fedor Pikus - CppCon 2021](https://www.youtube.com/watch?v=g-WPhYREFjk)
* [Modern C++ Features](https://github.com/AnthonyCalandra/modern-cpp-features)
* [C++ static code analysis rules](https://rules.sonarsource.com/cpp)
* [C++ reference](https://en.cppreference.com/w/)
    * [C++ Standard Library headers](https://en.cppreference.com/w/cpp/header)
* [C++ 语言构造参考手册](https://www.bookstack.cn/books/cppreference-language)
* [C++ Notes for Professionals book](https://goalkicker.com/CPlusPlusBook/)
* [Google-Abseil](https://abseil.io/)
* [Online Compiler](https://godbolt.org/)
* [Online Benchmark](https://quick-bench.com/)
* [Where do I find the current C or C++ standard documents?](https://stackoverflow.com/questions/81656/where-do-i-find-the-current-c-or-c-standard-documents)
    * **[cplusplus/draft](https://github.com/cplusplus/draft)**：草稿版本，相对于发行版可能会有错误，但是免费
* 《A Tour of C++》
* Celebrity
    * `Bjarne Stroustrup`：C++之父
    * `Walter E. Brown`：2000年开始参与C++标准制定工作，引入了`cbegin/cend`、`common_type`等特性，以及负责`<random>`、`<ratio>`等头文件的开发
* Projects
    * [Apache Calcite](https://github.com/apache/calcite)

# 3 Kernel

* [Doc](https://www.kernel.org/doc/Documentation/)
    * [cgroup-v2](https://www.kernel.org/doc/Documentation/admin-guide/cgroup-v2.rst)
* [Linux-进程的管理与调度](https://github.com/gatieme/LDD-LinuxDeviceDrivers)
* [调度系统设计精要](https://draveness.me/system-design-scheduler/)

# 4 Code Standard

* [Google 开源项目风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/)
* [LLVM Coding Standards](https://llvm.org/docs/CodingStandards.html)
* [The Standard of Code Review](https://google.github.io/eng-practices/review/reviewer/standard.html)

# 5 Performance Analysis

* [Brendan Gregg's Homepage](https://www.brendangregg.com/) - ★★★★★
    * [Linux Performance](https://www.brendangregg.com/linuxperf.html)
* [Denis Bakhvalov](https://easyperf.net/)
    * 《Performance Analysis and Tuning on Modern CPUs》
* [Julia Evans](https://jvns.ca/)

# 6 DMBS

* [编程小梦](https://blog.bcmeng.com/) - ★★★★★
    * [数据库学习资料（持续更新中）](https://blog.bcmeng.com/post/database-learning.html)
    * [OLAP 数据库性能优化指南](https://perf.bcmeng.com/)
* [satanson](https://www.zhihu.com/people/grakra) - ★★★★★
    * [有什么好的数据库学习路径推荐？](https://www.zhihu.com/question/451898647/answer/1813178673)
* Celebrity
    * `Edgar F. Codd/Ted Codd`：关系型数据库之父
    * `Andy Pavlo`：顶尖的数据库领域专家，执教CMU数据库系统相关课程
        * [Databases in 2021: A Year in Review](https://ottertune.com/blog/2021-databases-retrospective/#big-data-big-money)
        * [Databases in 2022: A Year in Review](https://ottertune.com/blog/2022-databases-retrospective/)
* Top conferences
    * [MOD](https://dl.acm.org/conference/mod/)
    * [ACM SIGMOD, Special Interest Group On Management Of Data](https://sigmod.org/)
    * [VLDB, Very Large Data Base](https://vldb.org/)
    * [ICDE, International Conference On Data Engineering](https://www.icde.org/)
* [Compare Projects](https://ossinsight.io/compare/)
* [DB Fiddle](https://www.db-fiddle.com/)
* [Database of Databases](https://dbdb.io/)
* [Sort Benchmark Home Page](https://sortbenchmark.org/)
* [DB-Engines Ranking](https://db-engines.com/en/ranking)
* [database-startups](https://www.crunchbase.com/hub/database-startups)
* [35 of the Most Successful Database Startups](https://www.failory.com/startups/database)

## 6.1 Blog

* [Alex DeBrie](https://www.alexdebrie.com/)
* [Ottertune](https://ottertune.com/blog/)

## 6.2 Other

* [Meaning of ‘i’,‘g’ and ‘c’ in Oracle Database Version](https://www.linkedin.com/pulse/meaning-ig-c-oracle-database-version-piyush-prakash)
* [数据库内核杂谈](https://www.infoq.cn/theme/46)
* [Develop your own Database](https://hpi.de/plattner/teaching/archive/winter-term-201819/develop-your-own-database.html)
* [ClickHouse/ClickBench](https://github.com/ClickHouse/ClickBench)
* [AlloyDB for PostgreSQL under the hood: Intelligent, database-aware storage](https://cloud.google.com/blog/products/databases/alloydb-for-postgresql-intelligent-scalable-storage)
* Segment Tree
    * [Segment Tree | Set 1 (Sum of given range)](https://www.geeksforgeeks.org/segment-tree-set-1-sum-of-given-range/)
    * [Segment Tree | Set 2 (Range Minimum Query)](https://www.geeksforgeeks.org/segment-tree-set-1-range-minimum-query/)
    * 为什么`min`、`max`的最小复杂度就是`NlogM`，因为`min`、`max`需要维护有序性
* Materialized Views
    * [Understanding Materialized Views — Part 1](https://medium.com/event-driven-utopia/understanding-materialized-views-bb18206f1782)
    * [Understanding Materialized Views — Part 2](https://medium.com/event-driven-utopia/understanding-materialized-views-part-2-ae957d40a403)
* [Streaming Data Warehouse 存储：需求与架构](https://mp.weixin.qq.com/s/ptRJY4jAmZrDmwMYCd9mjA)
* [Teradata中QUALIFY函数](https://zhuanlan.zhihu.com/p/53599236)
* [LSM树详解](https://zhuanlan.zhihu.com/p/181498475)

# 7 ChatGpt

* [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
* Derivative Products
    * Jasper
    * Midjourney
    * Copilot

# 8 Mirrors

* [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)

# 9 Uncategorized

* [How to Read a Paper.pdf](/resources/paper/How-to-Read-a-Paper.pdf) - ★★★★★
* [陈皓-耗子哥](https://coolshell.cn/articles/author/haoel)
* [美团技术博客](https://tech.meituan.com/)
* [Richard Stallman-Make作者](https://www.stallman.org/)
* [BOT Man | John Lee](https://bot-man-jl.github.io/articles/)
* [CloudNative 架构](http://team.jiunile.com/)
* [敖小剑的博客](https://skyao.io/)
* [米开朗基杨](https://fuckcloudnative.io/posts/)
* `Jeff Dean`：Google Research Scientists and Engineers
* `Fabrice Bellard`：A legend programmer, author of FFmpeg, QEMU
* [Tutorials for Software Developers and Technopreneurs](http://tutorials.jenkov.com/)
* [The-Art-of-Linear-Algebra](https://github.com/kenjihiranabe/The-Art-of-Linear-Algebra)
