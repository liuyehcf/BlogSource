1. Linux-常用命令
    * blktrace/iowatcher
    * 如何编写TUI程序(https://github.com/marcusolsson/tui-go)
    * ag
    * 僵尸进程：https://zhuanlan.zhihu.com/p/92381918
1. 性能分析
    * Perf
    * vtune
    * [socket tracer](https://mp.weixin.qq.com/s/0w5t_KkHRLXkEY1_qbdTtw)
1. 数据库
    * 相关概念
        * 确定性事务
        * 2pc
    * 时序数据库
        * [关于时序数据库的一些思考](https://zhuanlan.zhihu.com/p/100146332)
        * [LSM树详解](https://zhuanlan.zhihu.com/p/181498475)
    * starrocks
        * [apache-incubator-doris](https://github.com/apache/incubator-doris/wiki)
        * [query-schedule](https://15445.courses.cs.cmu.edu/fall2020/schedule.html)
        * [数据库内核杂谈](https://www.infoq.cn/theme/46)
        * [Develop your own Database](https://hpi.de/plattner/teaching/archive/winter-term-201819/develop-your-own-database.html)
        * [DorisDB doc](http://doc.dorisdb.com)
        * 一些概念
            * 桶就是tablet
            * 如何查看数据分布情况：show tablet from test_basic;
    * 相关工具
        * sqlancher
        * sqlmith
        * https://godbolt.org/
    * doc
        * [sqlite-window-function](https://www.sqlite.org/windowfunctions.html)
        * [ck-blog](https://clickhouse.com/docs/zh/whats-new/changelog/)
    * ssb测试集
        * https://www.cnblogs.com/tgzhu/p/9083092.html
    * [sqlancer](https://github.com/sqlancer/sqlancer)
    * [数据库学习资料（持续更新中）](https://blog.bcmeng.com/post/database-learning.html)
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
    * cpp summit
    * 内存管理
        * 库：jemalloc/jcmalloc/mimalloc，位于用户态
        * 涉及的系统调用（只涉及虚拟内存，物理内存只能通过缺页异常来分配）
            * brk：调整堆顶指针
            * sbrk：
            * mmap：mmap是在进程的虚拟地址空间中（堆和栈中间，称为文件映射区域的地方）找一块空闲的虚拟内存
    * 如何安装boost？ `yum install -y boost-devel`
    * map下标访问是非const的，因为可能会插入数据
    * 性能优化
        * ck /AggregateFunctions/IAggregateFunction.h
    * [Google 开源项目风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/)
    * `pointer stability`
    * 设置线程名，https://blog.csdn.net/Betterc5/article/details/111996038
        * prctl
    * 序列化框架arrow；https://zhuanlan.zhihu.com/p/339132159
    * 异常安全：在任何位置抛出异常，都要确保资源能够清理
    * gcc
        * `-fsized-deallocation`，http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2013/n3778.html
    * gcc-ar
1. 汇编
    * avx2指令
1. 其他
    * [macOS开启HiDPI](https://zhuanlan.zhihu.com/p/227788155)
    * 内存分配，伙伴算法
    * rpc框架，thrift
    * codegen原理
    * [调度系统设计精要](https://draveness.me/system-design-scheduler/)

