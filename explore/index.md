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

# 8 Uncategorized

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

# 9 Abbreviation

<table>
  <tr> <th width="80px" align="center">缩写</th> <th width="240px" align="center">全称</th> <th width="200px" align="center">其他</th> </tr>
  <tr> <td>BSD</td> <td>Berkeley Software Distribution</td> <td></td> </tr>
  <tr> <td>GPL</td> <td>GNU General Public License</td> <td></td> </tr>
  <tr> <td>POSIX</td> <td>The Portable Operating System Interface</td> <td></td> </tr>
  <tr> <td>OSI</td> <td>Open Systems Interconnection</td> <td></td> </tr>
  <tr> <td>POC</td> <td>Proof of Concept</td> <td></td> </tr>
  <tr> <td>ROI</td> <td>Return On Investment</td> <td></td> </tr>
  <tr> <td>SLA</td> <td>Service Level Agreement</td> <td></td> </tr>
  <tr> <td>FWD</td> <td>Forward Declaration</td> <td></td> </tr>
  <tr> <td>SMT</td> <td>Simultaneous Multithreading</td> <td></td> </tr>
  <tr> <td>OEM/ODM/OBM</td> <td>Original Equipment/Design/Brand Manufacturer</td> <td></td> </tr>
  <tr> <td></td> <td></td> <td></td> </tr>
  <tr> <th colspan="3" align="center">Position</th> </tr>
  <tr> <td>R&D</td> <td>Research and Development</td> <td></td> </tr>
  <tr> <td>SA</td> <td>Solution Architect</td> <td></td> </tr>
  <tr> <td>SRE</td> <td>Site Reliability Engineering </br> (Server Restart Engineer😁)</td> <td></td> </tr>
  <tr> <td>DBA</td> <td>Database Administration</td> <td></td> </tr>
  <tr> <td>QA</td> <td>Quality Assurance</td> <td></td> </tr>
  <tr> <th colspan="3" align="center">Github</th> </tr>
  <tr> <td>PMC</td> <td>Project Management Committee</td> <td> 1. <a href="https://www.apache.org/dev/pmc.html#what-is-a-pmc">what-is-a-pmc</a> </br> 2. <a href="https://www.gridgain.com/resources/blog/how-become-open-source-committer-and-why-youd-want">how-become-open-source-committer-and-why-youd-want</a> </td> </tr>
  <tr> <td>PPMC</td> <td>Podling Project Management Committee</td> <td><a href="https://incubator.apache.org/guides/ppmc.html">ppmc</a></td> </tr>
  <tr> <td>PR</td> <td>Pull Request</td> <td></td> </tr>
  <tr> <td>LGTM</td> <td>Looks Good To Me</td> <td>代码已经过 review，可以合并</td> </tr>
  <tr> <td>SGTM</td> <td>Sounds Good To Me</td> <td>代码已经过 review，可以合并</td> </tr>
  <tr> <td>WIP</td> <td>Work In Progress</td> <td>如果你有个改动很大的 PR，可以在写了一部分的情况下先提交，但是在标题里写上 WIP，以告诉项目维护者这个功能还未完成，方便维护者提前 review 部分提交的代码</td> </tr>
  <tr> <td>PTAL</td> <td>Please Take A Look</td> <td>请其他人 review 代码</td> </tr>
  <tr> <td>TBR</td> <td>To Be Reviewed</td> <td>提示维护者进行 review</td> </tr>
  <tr> <td>TL;DR</td> <td>Too Long; Didn't Read</td> <td>太长懒得看。也有很多文档在做简略描述之前会写这么一句</td> </tr>
  <tr> <td>TBD</td> <td>To Be Done(or Defined/Discussed/Decided/Determined)</td> <td>根据语境不同意义有所区别，但一般都是还没搞定的意思</td> </tr>
  <tr> <td>RC</td> <td>Release Candidate</td> <td>有可能成为稳定版本的版本</td> </tr>
  <tr> <th colspan="3" align="center">Uncategorized</th> </tr>
  <tr> <td>ETL</td> <td>Extract, Transform and Load</td> <td></td> </tr>
  <tr> <td>RFC</td> <td>Request for Comments</td> <td></td> </tr>
  <tr> <td>EMR</td> <td>Elastic MapReduce</td> <td></td> </tr>
  <tr> <td>EA</td> <td>Electronic Arts(company name)</td> <td></td> </tr>
  <tr> <td>LSM</td> <td>Log Structured Merge Tree</td> <td></td> </tr>
  <tr> <td>MFA/2FA</td> <td>Multi-Factor Authentication/Two-Factor Authentication</td> <td></td> </tr>
</table>
