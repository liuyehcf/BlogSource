1. Linux-常用命令
    * blktrace/iowatcher
    * 如何编写TUI程序(https://github.com/marcusolsson/tui-go)
    * [如何查看磁盘是gpt还是mbr](https://unix.stackexchange.com/questions/120221/gpt-or-mbr-how-do-i-know)
    * 链接器
        * export STARROCKS_CXX_LINKER_FLAGS=""
        * export STARROCKS_CXX_LINKER_FLAGS="-fuse-ld=gold"
        * export STARROCKS_CXX_LINKER_FLAGS="-B/usr/local/bin/gcc-mold"
1. 性能分析
    * vtune
1. 数据库
    * 相关概念
        * 确定性事务
        * 2pc
    * 时序数据库
        * [LSM树详解](https://zhuanlan.zhihu.com/p/181498475)
    * starrocks
        * [apache-incubator-doris](https://github.com/apache/incubator-doris/wiki)
        * [query-schedule](https://15445.courses.cs.cmu.edu/fall2020/schedule.html)
        * [数据库内核杂谈](https://www.infoq.cn/theme/46)
        * [Develop your own Database](https://hpi.de/plattner/teaching/archive/winter-term-201819/develop-your-own-database.html)
        * [DorisDB doc](http://doc.dorisdb.com)
    * 相关工具
        * [sqlancer](https://github.com/sqlancer/sqlancer)
        * sqlmith
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
    * ssb测试集
        * https://www.cnblogs.com/tgzhu/p/9083092.html
1. 大数据
    * hive
    * hbase
    * spark
    * hadoop
1. 缩写
    * PMC（Project Management Committee）
        * [WHAT IS A PMC?](https://www.apache.org/dev/pmc.html#what-is-a-pmc)
        * [How to become an open-source committer (and why you'd want to)](https://www.gridgain.com/resources/blog/how-become-open-source-committer-and-why-youd-want)
        * Podling Project Management Committee.
    * OSI
    * apache license/elastic license
    * bsd：Berkeley Software Distribution
    * gpl：GNU General Public License
    * POSIX：The Portable Operating System Interface 
    * sa（Solution Architect）：解决方案架构师
    * sre（Site Reliability Engineering）：站点可靠工程师
1. cpp
    * 内存管理
        * 库：jemalloc/jcmalloc/mimalloc，位于用户态
        * 涉及的系统调用（只涉及虚拟内存，物理内存只能通过缺页异常来分配）
            * brk：调整堆顶指针
            * sbrk：
            * mmap：mmap是在进程的虚拟地址空间中（堆和栈中间，称为文件映射区域的地方）找一块空闲的虚拟内存
    * map下标访问是非const的，因为可能会插入数据
    * 性能优化
        * ck /AggregateFunctions/IAggregateFunction.h
    * 序列化框架arrow；https://zhuanlan.zhihu.com/p/339132159
    * 打印堆栈：https://stackoverflow.com/Questions/3899870/print-call-stack-in-c-or-c
        * -ldl，libdl干嘛的？dynamic linking library
        * [Library Interfaces and Headers](https://docs.oracle.com/cd/E86824_01/html/E54772/makehtml-id-7.html#scrolltoc)
    * ldd
    * `std::make_integer_sequence`、元编程：https://www.cnblogs.com/happenlee/p/14219925.html
        * https://github.com/ClickHouse/ClickHouse/blob/785cb6510f65050f706a95f258529c4097d9e453/base/base/constexpr_helpers.h
        * [C/C++ 宏编程的艺术](https://bot-man-jl.github.io/articles/?post=2020/Macro-Programming-Art)
    * `constexpr`
    * `static_assert`
    * string和整数相互转化，std::to_string(), std::atoi
    * `std::optional`
1. 汇编
    * avx, advanced vector extension
    * avx2指令
    * avx512
1. 其他
    * 内存分配，伙伴算法
    * rpc框架，thrift
    * codegen原理
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)
    * [构建工具bazel](https://github.com/bazelbuild/bazel)