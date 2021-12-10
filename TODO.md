1. Linux-常用命令
    * blktrace/iowatcher
    * [Linux查看实时网卡流量的几种方式](jianshu.com/p/b9e942f3682c)
    * 如何编写TUI程序(https://github.com/marcusolsson/tui-go)
    * ag
    * xquartz
    * vncserver-vncviewer
    * nx
    * https://www.nomachine.com/
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
    * tpcds测试集
1. opensource
    * PMC
        * [WHAT IS A PMC?](https://www.apache.org/dev/pmc.html#what-is-a-pmc)
        * [How to become an open-source committer (and why you'd want to)](https://www.gridgain.com/resources/blog/how-become-open-source-committer-and-why-youd-want)
        * Podling Project Management Committee.
    * OSI
    * apache license/elastic license
1. cpp
    * cpp summit
    * jemalloc/jcmalloc/mimalloc
    * 如何安装boost？ `yum install -y boost-devel`
    * map下标访问是非const的，因为可能会插入数据
    * 性能优化
        * ck /AggregateFunctions/IAggregateFunction.h
    * [Google 开源项目风格指南](https://zh-google-styleguide.readthedocs.io/en/latest/google-cpp-styleguide/)
1. 函数式编程
    * 高阶函数
        * 入参出参可以是函数
        * 可以在方法内定义函数
    * 代数数据结构
        * 子类正交，比如：是否常量、是否可空、是否可空且常量，是用2个子类实现还是3个子类实现？代数数据结构会选择用3个子类实现，这样每个实现都是正交的
1. vim
    * filereadable 无法识别 ~  expand
    * vimscript https://zhuanlan.zhihu.com/p/37352209
    * ex模式
1. 汇编
    * avx2指令
1. 其他
    * [macOS开启HiDPI](https://zhuanlan.zhihu.com/p/227788155)
    * 伙伴算法
    * 异常中断的区别
    * rpc框架，thrift
    * codegen原理
    * 什么是体系结构
    * sa（Solution Architect）：解决方案架构师
    * sre（Site Reliability Engineering）：站点可靠工程师
    * [cpu的制造和](https://plantegg.github.io/2021/06/01/CPU%E7%9A%84%E5%88%B6%E9%80%A0%E5%92%8C%E6%A6%82%E5%BF%B5/)
    * [Mac 安装 iTerm2 + Oh My Zsh 实现命令提示](http://www.manoner.com/tools/iTerm2+OhMyZsh/)