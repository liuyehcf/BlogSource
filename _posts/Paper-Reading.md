---
title: Paper-Reading
date: 2021-09-08 17:03:18
tags: 
- 原创
categories: 
- Paper
---

**阅读更多**

<!--more-->

# 1 [Morsel-Driven Parallelism: A NUMA-Aware Query Evaluation Framework for the Many-Core Age](/Papers/Morsel-Driven-Parallelism.pdf)

1. 为什么现在开始关注`many-core`架构：随着内存带宽的增长，出现了一些内存级的数据库（广义或者狭义，狭义指的是所有数据完全存在于内存中；广义指的是部分数据以某种形式存在于内存中，比如缓存），对于这些数据库系统，I/O不再是性能瓶颈，能否高效利用好计算机的多个`core`决定了系统整体的性能
1. 核心是调度机制：（称为`dispatcher`），能够灵活的调整pipeline的并发度
1. 我们的调度程序运行固定的、依赖于机器的线程数，这样即使有新查询到达，也不会出现资源超额订阅，并且这些线程被固定在核心上，这样就不会由于操作系统将线程移动到不同的核心
1. `morsel`：data fragment，主要指数据格式，量词，一小部分
1. `morsel-driven`调度器的关键特征：任务的分配是在运行时完成的，因此是完全弹性的。即使面对不确定的中间结果大小分布，以及现代CPU内核难以预测的性能（即使工作量相同，性能也会变化）也能有较好的表现
1. 有一些系统采用了`operator`维度的并发控制，但是这会引入不必要的同步开销，因为在大部分场景下，operator之间是存在关联关系的，下一个operator需要接受上一个operator的输入，频繁的数据同步操作会带来负增益
1. `morsel-driven`和`volcano`模型的区别诶是：`volcano`中的执行单元是相互独立的，但是`mosel-driven`中不同的pipeline之间是存在依赖的，它们之间会通过`lock-free`机制来实现数据共享
1. `morsel-at-a-time`：一次处理一组数据，随后即进入调度，避免复杂低优先级查询饿死简单高优先级查询
1. `dispatcher`的运行有两种方式：其一，用独立的线程或者线程池来完成分发相关的code；其二，每个worker分别运行分发相关的code（take task from a lock-free-queue）
1. 由于pipeline之间是有依赖关系的，因此，当前驱pipeline完成后需要通知并驱动下一个pipeline，这种机制叫做`passive state machine`
1. `elasticity`：在任何时候可以将core分配给任何查询任务的能力
1. 在`morsel-driven`架构中，取消查询的代价非常低（可能原因是用户取消查询，或者内存分配超限等等异常情况），只需要将查询相关的pipeline标记为`cancel`，那么所有的worker便不再处理这个查询了（相比于让操作系统杀掉线程的操作来说轻量很多）
1. `morsel-size`对于性能来说不是特别重要，通常它只需要保证足够大以分摊调度开销，同时提供良好的响应时间即可
1. 在一些系统中，那些共享的数据结构，即便是`lock-free`，也很容易成为性能瓶颈。而在`morsel-driven`架构中，包含如下几个特点
    * 数据会被切割成一组互补重合的区间，`worker`工作在某一个区间上，因此`cache line`基本是和每个区间对齐的，不太可能出现缓存冲突的问题（除非`worker`从其他`worker`那边窃取了数据并进行处理
    * 并发度越高，数据结构带来的压力越低（这个怎么理解？）
    * 我们总是可以通过调大`morsel-size`来降低`work-stealing`的发生。如果`morsel-size`特别大，虽然会降低线程的工作效率（本来一份工作可以由多个线程同时处理，比如scan，但现在只由一个线程处理，有些core可能没在工作）。但是随着并发度的提高，这种负增益将会被逐渐抵消（每个core都在工作）
1. `Lock-Free Tagged Hash Table`没太看懂
    * The key idea is to tag a hash bucket list with a small filter into which all elements of that partic- ular list are “hashed” to set their 1-bit.
    * 与`Bloom filter`相比，优势是？
        * `Bloom filter`是一个额外的数据结构，而`tagged hash table`不需要，并且性能开销很低，只需要几个位运算即可
        * 对于大表，`Bloom filter`体积也会比较大，很难全部加载到cache中（或者只存在于`low-level`的cache中）
        * 可以直接使用，无需依赖优化器对选择进行一个预测（是否要构建`Bloom filter`）
    * 存储的是`tuple`的地址而不是对象本身，因此不能使用开放寻址法（为什么？？？，开放寻址法不能存指针么）
        * 可以通过降低装载因子减小冲突，同时空间开销较小
        * 链表允许存储大小不同的`tuple`（开放寻址法做不到，为什么？？？）
1. `NUMA-Aware Table Partitioning`
    * 对于需要频繁执行的join查询，最好将其通过同一个key进行散列，这样有更好的locality，避免多个节点之间的交互（shuffle）
1. 聚合算子的性能与基数分布密切相关（`distinct keys`），解决这个问题，通常来说有两种途径，一种是基于优化器的预测；另一种就是两阶段聚合，第一阶段做本地聚合，第二阶段做partition聚合，每个partition也有一个hashTable，但是互不重叠
1. 通常来说，基于hash的聚合算法要比基于排序的聚合算法要更快
1. 排序也采用了两阶段，难点在于：聚合阶段，如何进行并行聚合且没有同步开销。具体做法是，在第一阶段进行本地排序后，对排序后的数据进行切分，此时需要获取全局的分布信息。这样切分完之后，就可以送往多个不同的节点进行独立的处理（不同节点上的数据也是不会存在重叠的）

**progress：5/12 3.3**

# 2 [The Google File System](/Papers/Google-File-System.pdf)

1. GFS的目标包括：performance（高性能）、scalability（高可扩展）、reliability（高可靠）、availability（高可用）
1. 在设计中，把失败视为常态而非异常。因此系统必须具备的核心能力包括：持续监控、错误勘探、错误容忍、自动恢复
1. 管理几十亿个`KB`大小的文件不是一种好方法，需要重新设计文件格式、`I/O`操作的块大小等参数
1. 绝大部分情况下，文件总是追加写入而不是覆盖写入，因此并无随机写入的需求
1. GFS放宽了一致性模型的要求，从而大大简化了文件系统的设计，降低用户的使用心智
1. GFS的假设
    * 文件系统由许多廉价的机器构成，并且这些机器容易出错（宕机等）。因此必须能够持续监控自身、探测错误、容错，并且敏捷地从异常中恢复
    * 系统存储少量大文件，大小在100M、1G甚至更大。并且能够基于这些大文件提供高效的操作。小文件肯定支持，但是不会针对小文件做太多优化
    * 工作负载包含两类读操作：大数据量的流式读取以及小数据量的随机读取。对于小数据量的随机读取，性能敏感性应用通常会进行批处理和排序，以稳定地浏览文件而不是来回移动
    * 工作负载支持两类写操作：大数据量的顺序写入以及小数据量的随机写入。其中小数据量的随机写入性能不会很好
    * 系统必须为并发写入提供高效的实现，并且提供明确的语义
    * 可持续的高带宽比低延迟更重要
1. GFS具有常规文件系统的接口，包括：`create`、`delete`、`open`、`close`、`read`、`write`。同时增加了两个新操作`snapshot`以及`record append`
    * `snapshot`以非常低的开销进行文件或者目录树的拷贝
    * `record append`能够处理大量客户端的并发请求，并且保证其写入的原子性
1. GFS包含一个`master`、多个`chunkserver`以及大量的`clients`
    * 文件被拆分成大小固定的`chunks`，每个`chunk`由一个全局唯一的`chunk handler`标识，该标识由`master`签发
    * `chunkserver`将`chunk`以linux文件的形式存储在本地磁盘上，并且通过`chunk handler`进行操作。基于可靠性考虑，每个`chunk`都会存在多个副本，并且分布在不同的`chunkserver`中
    * `master`中存储了全部的元信息，包括`namespace`、`access control`、文件与`chunk`的映射关系、`chunk`的位置信息等。同时，`master`也控制着`chunk lease`、垃圾回收（无用chunk）、`chunk`迁移等过程。`master`与`chunkserver`之间通过心跳包保持通信，用于传递指令以及采集状态信息
    * `client`从`master`中获取元数据，然后直接从`chunkserver`中读写数据
    * 无论是`client`（`client`会缓存元数据，但是不会缓存数据）或者`chunkserver`都不用缓存（这里的缓存指的是GFS层面的缓存），这是由工作负载决定的，大部分的时间都在读写大批量的数据，缓存在这种场景中，用处很小。无缓存降低了系统的复杂度。虽然`chunkserver`不用缓存，但是其存储是基于Linux文件系统的，Linux文件系统本身是有缓存的，对于频繁读写的数据是有性能增益的
1. `single-master`能够有效的降低系统复杂度，并且使得`master`能够借助全局信息处理诸如`chunk`替换以及克隆等复杂操作。同时，我们要尽最大努力降低`master`在普通读写操作中的参与度，避免其成为性能瓶颈。虽然`client`不从`master`中读取数据，但是它需要知道从`master`中获取哪些`chunkserver`存储了相应的数据，因此`client`可以缓存这些信息，从而降低与`master`的交互频率
1. `chunk size`是GFS的关键参数，建议值是`64MB`。大的`chunk size`包含如下优势
    * 降低了`client`与`master`的交互频率，如果读取的数据在同一个`chunk`中，那么直接从`chunkserver`中读取即可，无需与`master`交互
    * 使得`client`的大部分操作集中在一个`chunk`中，避免多机网络开销
    * 降低了`master`中元数据的大小，`chunk size`越大，元数据数量越少，从而使得`master`将元数据存储在内存中成为可能
1. 大的`chunk size`也存在劣势，包括
    * 增大了热点chunk出现的概率。但是对于GFS的预设的工作负载来说，热点不会是主要问题，因为大部分都是顺序读写大批量的chunk
1. `master`存储了如下三种元数据
    1. 文件以及`chunk`的`namespace`
    1. `file`到`chunk`的映射关系
    1. `chunk`的每个副本的具体位置信息
    * 所有的元数据都存储在`master`的内存中，前两种类型也会以日志的形式持久化到本地磁盘上
    * `master`不存储`chunk`的具体位置信息，而是在`master`每次启动或者有新的`chunkserver`加入集群时主动询问
1. 对于存储在内存中的元数据，`master`会对其进行周期性的扫描，主要实现以下功能
    * 实现垃圾回收，清理那些被标记删除的chunk
    * `chunk`克隆，用以应对`chunkserver`宕机
    * `chunk`迁移，实现负载均衡
1. `master`不会存储`chunk`的位置信息，而是在启动时，主动向`chunkserver`拉取这些信息，`master`始终保持原信息的有效性，因为它控制着所有`chunk`的迁移、拷贝等操作，并且与`chunkserver`通过周期性的心跳包来定期同步状态
    * **采用这种设计的另一个原因是：`chunkserver`对一个`chunk`是否在其本地磁盘上有最终解释权，没有必要维护一个`master`视角下的一致性视图。大大降低了复杂度**
1. `operation log`记录了`metadata`的历史变更。`master`必须确保操作日志落盘后（本机以及用以备份的远程主机），才能返回`client`，
    * `master`可以通过重放日志来恢复自身的状态
    * 当日志数量超过一定的阈值后，可以通过`checkpoint`来解决这个问题，`checkpoint`可以简单理解成某个时刻`master`内存数据的快照，其数据结构类似B-tree
1. GFS采用了一种松一致性模型。引入两个概念`consistent`以及`defined`
    * `consistent`：所有客户端看到的数据都是一样的（从任意副本上）
    * `defined`：所有客户端都能看到引起数据变更的操作具体是什么
    * `a serial success mutation`：`consistent and difined`
    * `concurrent success mutations`：`consistent and undefined`
    * `failed mutations`：`inconsistent and undefined`
1. `Data mutations`包含两种操作`write`以及`record append`
    * `write`：表示往指定的offset写入数据
    * `record append`：表示往文件最后追加数据。在并发的场景下，至少有一个能追加成功
1. GFS的松一致性模型保证的约束有
    * 文件命名空间变更是个原子操作
    * 在`a sequence of successful mutations`之后，相应的文件是`consistent`，`difined`。GFS通过在副本上重放操作来保证`defined`特性，并且通过版本号来检测那些过时的`chunk`（`chunkserver`从错误中恢复回来，但是错过了一些变更），这些过时的`chunk`将不包含在`master`中。此外，由于`client`会缓存`chunk`的位置信息，因此在缓存失效之前可能读到旧的数据，而大部分的文件都是`append-only`的，因此大概率读到的是不完整的数据而不是错误的数据，又进一步降低了影响
    * 当一个`chunk`的所有副本均丢失后，`chunk`才算丢失。在恢复之前，GFS会返回清晰的错误信息而不是错误的数据
1. 使用GFS的应用，最好使用追加写而不是覆盖写，因为追加写具有更好的性能以及错误恢复能力
1. 系统被设计为尽量避免与master交互
1. `Leases and Mutation Order`
    * 在执行变更操作时，`master`会挑选出某一个副本作为`primary`，然后由这个`primary`决定这一组操作的执行顺序，然后将这个执行顺序同步给其他副本
    * 租赁机制是为了降低`master`的参与度，避免`master`成为系统的瓶颈
    * 在执行变更的过程中，`master`还有可能通过心跳包发送额外的变更请求，或者直接终止变更操作
        * 假设有2个副本A、B，A变更结束，B还在变更，此时`master`发送终止变更的消息，A和B将如何恢复？
    * 变更操作的整体流程（看论文就行，这里不赘述）
        * 第三步：论文中是由client向所有的replicas推送待写入的数据，这就要求clients必须知道集群中的所有副本情况，才知道发给谁，感觉有点怪。更好的做法是：发给其中某个副本，然后让这个副本同步给其他副本
        * 第六步：如果部分副本变更成功，部分副本变更失败时，怎么回滚？不需要回滚，因为数据有版本的概念，假设有三个副本A、B、C，A、B都写入成功了，`chunk`的版本号是6；C写失败，版本号还是5。但此时，A和B构成了一个多数派，变更操作成功，并且将版本信息告知`master`，下次`client`读的时候，仍然可以从A、B、C三个副本中随机读取，假设选择的是C，但是一看版本号不是最新的，那么就会重新发起读操作，直至读取到最新的数据。此外，失败的副本会有补偿机制来进行修复
    * 如果需要写入大量数据（规模超过`chunkSize`），`client`会首先将其拆分成多个小块，但是这多个小块的多次写操作可能不是原子的。因为在写入的过程中，可能会插入其他client的写入操作。最终多个副本上的数据一定是相同的，但是从不同client的视角上来说，变更的顺序可能是不同的。因此此时就是`consistent but undefined`
1. `Data Flow`
    * 控制流与数据流解耦（控制流中不要阻塞等待io事件）
    * 为了最大程度地利用机器带宽，数据被组织在线性的`pipeline`中，而不是其他复杂的拓扑结构。目的是为了更快的传递数据，而不是将时间消耗在拓扑结构处理中（效果会很好？） 
    * 更具体来说，当有数据需要传送到多个节点时，机器只会将数据发送给离自己最近的节点，然后依次类推。如何计算距离：通过ip地址（估计通过网段的差异性来判断距离的远近）
    * 当机器收到数据的同时，就立即将数据`forward`到其他节点
1. `Atomic Record Appends`
    * 传统的写操作，需要提供数据以及写入的`offset`，并发写无法做同步（为啥？？？），导致最终结果包含多个`client`的数据
    * 在`append write`中，客户端只需要提供数据，GFS会提供该操作的至少写入一次的原子语义，并且将数据写入的`offset`发送给`client`。这与Unix中的`O APPEND`文件模式相同
    * 如果任何一个副本写失败，客户端都会重试。这就会导致不同副本上的同一个chunk可能包含不同的数据（由于重试导致的重复）。GFS并不保证chunk在字节层面完全一致，它只保证数据至少被写入一次
    * 写操作成功意味着，数据以相同的`offset`被写入到所有副本的chunk中。这不是跟上条矛盾了么，如何解决？为后续的写操作分配一致的offset，一般来说，就是那个包含重复数据最多的chunk的末尾的`offset`，这样能够保证相同`offset`这个语义（会导致`chunk`中存在空白块）
1. `Snapshot`
    * GFS几乎在瞬间就可以生成文件或者目录树的快照，尽量减少在生成期间由于其他变更引入的数据不一致。在实际场景中，会大量使用该功能来创建海量数据的副本（或者副本的副本），以及创建`checkpoint`
    * GFS使用了`Copy-On-Write`技术来实现快照
    * 当`master`收到了创建快照的请求时，会先回收相关`chunk`的租赁，于是后续针对这些`chunk`的写操作都需要与`master`进行交互。然后`master`创建该`chunk`的一个副本
        * 拷贝一份文件或者目录树的元数据，新老两份元数据指向的是同一个`chunk`
        * 当对副本进行写操作时，才会进行`chunk`的拷贝动作
1. `master`允许同时处理多个请求，并采用适当粒度的锁来保证同步
    1. 与传统文件系统不同，GFS没有为目录提供用于保存该目录下所有文件和子目录的数据结构，也不支持别名（类似于软硬链接）。GFS在逻辑上将其命名空间表示为将完整路径名映射到元数据的查找表。使用前缀压缩算法，该查找表可以保存在内存中
    1. 每个命名空间（文件或者目录）都有一个读写锁。每个操作都需要获取一系列的锁，例如对`/d1/d2/.../dn/leaf`的操作，需要先后获取`/d1`、`/d1/d2`、`/d1/d2/d3`、...、`/d1/d2/.../dn`以及`/d1/d2/.../dn/leaf`的锁，这里`leaf`可以是文件也可以是目录
        * 以一个例子来说明锁机制是如何工作的：在创建`/home/user`的快照`/save/user`的过程中，创建`/home/user/foo`文件。首先，快照操作会获取`/home`、`/save`的读锁以及`/home/user`、`/save/user`的写锁。文件创建操作需要获取`/home`以及`/home/user`的读锁以及`/home/user/foo`的写锁。因此这两个操作会被串行执行，因为它们都需要获取`/home/user`这个锁（读写锁冲突）
        * 可以看到，我们在创建文件时，在其父目录上只加了一把读锁，这种锁机制的好处在于，它允许在同一个目录上进行并发操作。例如我们可以并发地在一个目录上创建多个文件。同时，该读锁可以确保目录不被删除、重命名、创建快照
        * 由于`namespace`包含了非常多的节点，因此读写锁被设计成延迟加载，以及在不用时，锁会被删除
        * GFS会严格保证按照namespace的层次结构依次顺序获取锁，以免发生死锁
1. `Replica Placement`
    * GFS集群可以包含多个层级结构。通常一个GFS集群包含成百上千个节点，这些节点可能跨机房部署，因此两台机器之间的通信也可能跨机房。显然跨机房的网络带宽一般小于同机房的网络带宽。因此`multi-level`分布式架构对高可用、高可靠、高可扩展提出了全新的挑战
    * `hunk replica placement policy`有两个目标
        * 最大化可靠性和可用性
        * 最大化带宽利用率
    * 为了达到上述两个目的，仅跨机传播副本是不够的，还必须跨机房传播副本，以提高容灾能力。即便一个机房挂了，服务也照样可用。同时跨机传输会带来带宽的开销，因此需要在两者之间做一个权衡
1. `Creation, Re-replication, Rebalancing`
    * `chunk`副本的主要原因有三个：`chunk`的创建、恢复以及负载均衡
    * 当`master`创建一个新的`chunk`时，需要决定将这个`chunk`放到哪个`chunkserver`上，会考虑如下几个因素
        * 挑选一个磁盘负载最低的`chunkserver`
        * 控制每个`chunksever`近期创建`chunk`的数量。尽管`chunk`创建本身开销很低，但是创建通常伴随着大量的写入操作，因此整体上来讲需要做一个动态平衡
        * 将`chunk`跨机房分布
    * 当`chunk`的副本数量小于一个阈值时，`master`会开启副本拷贝的流程
    * 此外，`chunk`克隆也有优先级。因素包括：缺失的`chunk`数量
    * 为了避免克隆带来的网络开销，`master`会在集群维度和`chunkserver`维度分别限制克隆任务的数量
    * `master`还会周期性的迁移这些`chunk`，以获得更好的分布情况，磁盘利用率以及负载均衡
1. `Garbage Collection`
    * 当一个文件或被删除后，`GFS`不会立即进行物理删除，而是记录日志，并且将其名字改成一个隐藏名。同时`master`会定期扫描所有`namespace`，并对这些特殊名称且过期的文件（超过一定时间，默认3天）进行物理删除。而在此之前，仍然可以通过这个特殊的隐藏名访问读写文件，或者将其重命名为正常文件
    * `chunkserver`会与`master`通过心跳包交换信息，`chunkserver`会告知`master`自身存储的所有`chunk`，而`master`会告知`chunkserver`哪些`chunk`已经可以删除了（没有被任何一个文件关联），`chunkserver`会在空闲时间删除它们
    * GFS中的`garbage collection`特别简单，它能够快速确认哪些`chunk`可以删除，因为`master`在元数据中维护了`file->chunk`的映射。同时可以很容易地确认所有`chunk`副本的信息，任何不在`master`中记录的副本都可以当成是`garbage`
    * 与传统的即时删除相比，GFS的垃圾回收有如下优势
        * 简单可靠
        * 定期与`chunkserver`同步chunk信息，确保信息的正确性
        * 批量写操作，开销低
        * 仅在`master`空闲的时候进行，避免影响正常业务
        * 容错性更好，由于删除只是写日志以及重命名，当有异常时，可以非常方便的进行错误恢复，比如回滚等等
    * 与传统的即时删除相比，GFS的垃圾回收有如下劣势
        * 存储资源紧张时，可能会存在问题，此时需要调整过期的阈值，让文件尽早物理删除
        * 频繁的创建、删除同名文件可能会占用不同的存储资源
    * GFS允许为不同的`namespace`设置不同的存储策略，包括副本数量、是否即时删除等等来解决上面的问题
1. `Stale Replica Detection`
    * `master`通过给每个`chunk`维护一个`version`，来判断`chunk`是否是最新的
    * `master`在垃圾回收时，进行过期副本的处理。因此`master`仅可简单地认为自己维护的副本都是最新的即可。此外，作为补偿，在进行写操作或者进行`chunk`克隆的时候，都会校验`version`
1. GFS最大的挑战之一就是如何处理频繁发生的组件异常
    * 不能完全信任硬件设备（包括磁盘等）
    * 组件异常可能导致服务不可用，或者数据损坏
1. `High Availability`
    * `Fast Recovery`
        * 无论`master`或者`chunkserver`正常或异常终止，都需要在启动时进行信息同步
    * `chunk replication`
        * 前面讨论到，`chunk`的不同副本存放在不同机器，以及不同机架上，当`chunkserver`宕机后，`master`便会开启克隆任务，确保副本数量不小于某个值（默认3）
    * `master replication`
        * 处于可靠性考虑，`master`的状态也会以多副本存储在多个机器上。一个写操作当且仅当其操作日志在当前机器以及所有副本机器上成功落盘后，才算成功
        * 正常情况下，只有一个`master`提供服务，并管理所有的任务（包括克隆等等）
        * 当`master`宕机后，一个GFS之外的监控系统就会在另一台机器上重新拉起`master`，并且按照日志重建状态即可
        * `client`需要使用dns、而不是`master ip`，这样当`master`发生切换时，`client`无需感知
        * `shadow master`会提供读服务（即便`primary master`宕机）

# 3 [Bigtable: A Distributed Storage System for Structured Data](/Papers/Google-Bigtable.pdf)

1. GBT的目标包括
    * 适用范围广
    * 高可扩展
    * 高性能
    * 高可用
    * 高可靠
1. GBT不完全支持关系型数据模型。相反，它提供了一种简单的数据模型，但是支持对数据的布局以及格式进行动态修改
1. `Data Model`
    * 一个稀疏的、分布式的、持久化的、多维度的、有序字典
    * `key`可以是行、列、时间戳等等
    * `value`是一个不能修改的字节数组
    * `Rows`
        * GBT中的行键是string，针对行键的读写操作都是原子的
        * GBT通过行键值的字典序维护数据
        * `row range`会动态分区，每个分区叫做`tablet`。`tablet`是分布和负载均衡的最小单元
        * `client`通过指定`row key`可以获得很好的`locality`
    * `Column Families`
        * `column families`主要用于访问控制
    * `Timestamps`
        * GBT中的版本通过时间戳进行索引
        * 为了避免版本号的不断累积，GBT提供了版本号的回收机制（仅保留最后n个版本或者仅保留最新的版本等等）
1. `Building Blocks`
    * `SSTable`使用了一种持久化的、有序的、不可变的字典，`key`和`value`都是`byte string`
    * `SSTable`内部使用了`blocks`来存储数据，并且提供了索引来加速查询，减少磁盘访问频率
    * GBT依赖一个高可靠、持久化、分布式的锁（`Chubby`）
        * `Chubby`提供了`namespace`，包含了目录和文件。每个文件可以当做一个锁来使用，文件的读写都是原子的
        * `Chubby client`会在会话中保存租约信息，当租约过期时，会释放所有占有的文件以及目录
        * `Chubby client`可以注册回调来感知数据变更以及租约信息
        * 一旦`Chubby`不可用，那么GBT也变得不可用
    * GBT使用`Chubby`来完成如下事情
        * 确保同时只有一个master
        * 存储GBT数据的引导程序位置
        * 用于`tablet service`的服务发现以及`tablet service`死亡后的清理工作
        * 存储GBT的`schema`信息
        * 存储权限控制相关的数据
1. `Impletation`
    * GBT包含3个核心组件
        * 支持各种语言的`client-sdk`
            * 与大多数单`master`的分布式系统类似，`client`仅在必要时才与`master`进行通信，大部分时候都直接与`tablet server`进行交互
            * 在GBT中，`client`不依赖于`master`就能获取`tablet`信息，这进一步降低了`master`的负载
        * 一个`master`
             * 将表分配给`tablet server`
            * 负责管理`tablet server`的生命周期
            * 负责`tablet server`的负载均衡
        * 多个`tablet server`，并且支持扩缩容
             * 负责管理一组`tablet`，大约10-1000
            * 负责响应读写请求
            * 当`tablet`过大后，拆分`tablet`
    * `Table Location`
        * GBT使用一个三层类似于`B+-tree`的树形结构来存储`Table Location Information`
            * 存储在`Chubby`中
        * 第一级是一个文件（存储在`Chubby`中），该文件包含了`root table`的位置信息。`root table`中存储的是各个`tablet`在`METADATA table`中的位置，每个`METADATA table`包含了`User tablet`的具体位置。此外，`root table`是`METADATA table`中的第一个`tablet`，但是它被特殊对待了，它永远不会分裂，确保层级永远是三层
        * `METADATA table`存储的是由`tablet`相关信息（`table identifier`、`row end`等信息）经过编码得到的一个`key`。`METADATA table`中的每行大约`1K`的内存。假设内存`128M`的话，三级的结构可以存储$(128 * 1000)^2 ≈ 2^{34}$个`tablet`
            * `METADATA table`存在哪？
        * `client`会缓存`tablet location`。当发现缓存不存在，或者缓存信息有问题时（如何发现有问题？），会重新获取正确的信息。此外，`client`在获取`table location`时，会多获取一些（即便用不到），这样下次访问`tablet`时，可能直接就命中缓存了
    * `Tablet Assignment`
        * 一个`tablet`在同一时刻只能分配给一个`tablet server`
        * `master`负责`tablet`在不同`tablet server`的调度
        * GBT通过`Chubby`来追踪`tablet server`，每当`tablet server`启动时，都会在`Chubyy`的特殊目录下创建文件（锁）。`master`通过监视这个特殊目录来发现并管理`table server`
        * `master`在启动时会做如下步骤
            1. 尝试获取一把特殊的锁（避免多个master）
            1. 扫描`Chubby`获取所有活跃状态的`tablet server`
            1. 与每个活跃的`tablet server`通信，获取相关的`tablet`信息
            1. 扫描`METADATA tabble`，获取`tablet`的分配情况
        * `tablet`当数据过大时，会分裂成两个`tablet`，或者两个较小的`tablet`会合并成一个大的`tablet`，并且`tablet server`会将这些变更信息同步给`master`，同步的信息丢失也没关系，假设`master`仍然感知的是老的`tablet`，当要求对这个`tablet`进行读写操作时，也会再一次进行信息的同步
    * `Tablet serving`
        * `tablet`的持久化信息存储在GFS中（这部分信息参考论文中的原图`Figure 5`），涉及到的组件包括
            * memtable（mem），存储最近更新的数据
            * tablet log（GFS），用于记录更新操作的的`commit log`
            * SSTable Files（GFS），存储`tablet`的数据
        * 对于更新操作，先写`commit log`（包含`redo log`），最近的更新会存储在`memtable`中
        * `tablet`恢复：`tablet server`首先从`METADATA table`中读取该`tablet`的元信息，该元信息包含一系列的`SSTables`，而`SSTable`包含了一系列的`tablet`以及`redo point`，`redo point`指向`commit log`（可能包含数据）。`tablet server`根据这些信息就可以重建`memtable`
        * 当`tablet server`接收到读操作时，它会在`memtable`和`SSTable`上进行合并查找，因为`memtable`和`SSTable`中对于键值的存储都是字典顺序的，所以整个读操作的执行会非常快
    * `Compactions`
        * 随着写入操作增多，`memtable`的大小也随之增大，当其达到一个阈值后，`memtable`会转换成`SSTable`，并且写入到GFS中
        * 这种`micro-compaction`有两个目的
            1. 缩小`table server`的的内存占用量
            1. 当`server`从宕机中恢复，并要恢复之前的数据时，可以减少从`commit log`中读取的数据量
        * 在进行`compaction`的过程时，仍然可以进行读写操作
        * `merging compaction`会周期性地将一小部分`SSTable`以及`memtable`写入到一个新的`SSTable`中，操作完成后，原来的`SSTable`以及`memtable`可以被丢弃
        * 将所有`SSTable`写入一个新的`SSTable`中的过程叫做`major compaction`。`non-major compaction`产生的`SSTable`可能包含某些条目的删除信息，这些条目的数据还存储在其他`SSTable`中。因此`major compaction`可以消除这部分数据。GBT会周期性的对所有`table`执行`major compaction`过程
1. `Refinements`
    * `Locality groups`
        * `client`可以将一组`column family`作为一个`locality group`
        * 通常，将不会一起访问的`column family`分离到不同的`locality group`中可以实现更高效的读取
        * 每个`locality group`支持独立设置参数。例如声明某个`locality group`直接在内存中存储，这个`locality group`中的数据会延迟加载进内存，一旦在内存中存在后，就可以避免磁盘访问，进一步提高效率。在GBT内部，`METADATA table`中存储的`location column family`就使用了这个功能
    * `Compression`
        * `client`可以控制`SSTable`中的某个`locality group`是否需要压缩，若需要压缩，可以指定压缩算法
        * 尽管独立压缩会增加复杂度以及降低空间利用率。但是某一部分不压缩的数据，可以提高读取的效率
        * 大部分的`client`会采用`two-pass`的压缩方案
            * `first pass`：采用`Bentley and McIlroy’s scheme`，对长`string`进行压缩
            * `second pass`：采用快速压缩算法，在数据的`16 KB`小窗口中查找重复项
        * `two-pass`不仅及其高效，而且压缩效率很高，能够达到`10-1`
    * `Caching for read performance`
        * 为了提高读性能，`tablet server`使用了两级缓存，分别是`scan cache`以及`block cache`，其中`scan cache`是`high level cache`，存储的是`SSTable`接口返回的键值对；`block cache`是`low level cache`，存储的是从GFS读取到的数据
        * `scan cache`对于那些需要重复读取数据的应用来说十分友好
        * `block cache`对于那些需要读取相关信息的应用来说十分友好
    * `Bloom filters`
        * 用于减少磁盘访问的速率
    * `Commit-log implementation`
        * 如果每个`tablet`的`commit log`都单独记录在不同的文件，那么会出现大量文件同时写入GFS的情况。因此，GBT中的实现是，多个`tablet`的`commit log`共享同一个日志文件
        * 使用同一个日志文件可以显著地提升性能（为啥？？？），但同时增大了恢复的复杂度。当一个`tablet server`宕机后，该机器上的所有`tablet`会被打散到其他`tablet server`中，因此，其他`tablet server`都需要全量读取一遍这个日志文件来进行数据的恢复（因为不知道某个`tablet`相关日志记录的具体位置）
        * 为了解决单日志文件造成的恢复时需要读取多次日志文件的问题。GBT会首先先对日志中的记录进行排序（`table, row name, log sequence num`）。于是同一个`tablet`的记录就会连续存储，通过少量的磁盘访问就可以全部读取出来
        * 此外，写日志可能会因为各种原因而失败，比如宕机、网络隔离等等。为了提高可用性，每个`tablet server`都由两个线程，每个线程写独立的文件。同一时刻只有一个线程是活跃状态。如果处于活跃状态的线程写入出现问题，那么会切换到另一个线程进行写入。日志条目包含序列号，以允许恢复过程消除由此日志切换过程产生的重复条目。
    * `Speeding up tablet recovery`
        * 当`master`要将某个`tablet`从一个`tablet server`迁移到另一个`tablet server`中时，第一步，会进行第一次压缩（减小数据量），且此时`tablet server`仍在提供服务；第二步，`tablet server`会停止对该`tablet`的服务；第三步，再进行一次压缩操作，因为在第一次压缩时，可能有新的数据变更产生；第四步，其他`tablet server`读取该`tablet`来重建`tablet`
    * `Exploiting immutability`
        * 由于`SStable`是不可变的，因此读取`SSTable`是不需要同步措施的。并发控制实现起来非常简单
        * 唯一可读可写的数据结构，存储在`memtable`中，为了降低冲突的可能性，采用了`COW`的技术
        * 由于`SSTable`是不可变的，清理删除的数据转变成了垃圾收集器收集过时的`SSTable`
        * 由于`SSTable`是不可变的，因此`tablet`的拆分变得很容易，因为`child tablet`可以共享`parent tablet`的`SSTable`而无需拷贝 

# 4 [MapReduce: Simplified Data Processing on Large Clusters](/Papers/Google-MapReduce.pdf)

1. `Abstract`
    * `map`用于产生一组`key/value`对
    * `reduct`用于合并具有相同`key`的`key/value`对
    * `GMR`会处理数据的分区、执行调度、异常恢复、节点通信等等细节问题。这允许用户在无任何并发和分布式的经验的前提下，就能够利用好大规模的资源来进行计算
1. `Programming Model`
    * `GMR library`暴露两个函数`Map`和`Reduce`
        * `Map function`（由用户编写），负责产生一组`key/value`。然后`GMR library`会将具有相同`key`的`pair`输送到`Reduce function`
        * `Reduce function`（由用户编写），负责接受一个`key`以及一组`value`，并将其合并成一个或少量`value`
    * `Types`
        * `GMR`只处理string，用户负责在string和正确的类型之间进行转换
1. `Implementation`
    * `MapReduce`大致包含如下几个步骤
        1. 用户程序中的`MapReduce`库函数将数据源拆分成`16M-64M`的多个小块
        1. 总共有`M`个`map task`以及`N`个`reduce task`，`master`根据负载情况，将这些`task`分配给`worker`
        1. `map worker`收到`map task`后，将输入数据解析成键值对（`key/value pair`），并将其作为输入传入用户自定义的`Map function`，然后产生中间键值对，并缓存在内存中
        1. 上一步被缓存在内存中的中间键值对会通过`partitioning function`分成`R`个分区，并写入本地磁盘，这些数据的位置信息会被传送给`master`，后面的`Reduce`过程会用到这些信息
        1. `reduce worker`收到`reduce task`（包含上一步提到的位置信息）后，会发起远程调用，读取远端机器（`map worker`）上的中间键值对。读取完毕后，会根据键值进行排序，相同键值的会进行聚合（链表的形式）
        1. `reduce worker`对排序后的键值对进行遍历，并将每个`key/value set`送入用户自定义的`Reduce function`，其结果会追加到`final output file`
        1. 当所有`map task`以及`reduce task`处理完毕后，`master`会唤醒用户程序，并将结果返回给该程序
    * `Master Data Structures`
        * `master`会存储每个`map task`和`reduce task`的状态（空闲、处理中、完成）
        * `master`是将中间文件区域的位置从`map task`传播到`reduce task`的管道。因此，对于每个完成的`map task`，`master`会存储`map task`产生的中间文件的位置和大小，并且将这些信息推送给正在执行的`reduece task`
    * `Fault Tolerance`
        * `Worker Failure`
            * `master`会周期性地`ping`每个`worker`
            * `failed worker`上的`map task`以及`reduce task`会被发送到其他空闲的`worker`中进行重新计算
        * `Master Failure`
            * `master`会周期性的记录`checkpoint`，当`master`宕机后，一个新的机器会从最新的`checkpoint`中恢复
        * `Semantics in the Presence of Failures`
            * 当用户提供的`map`和`reduce`操作是它们输入值的确定性函数时，我们的分布式实现产生的输出与整个程序的无故障顺序执行产生的输出相同。`GMR`通过`map task`以及`reduce task`的原子提交来实现这个属性。每个`task`会将其结果保存在私有的临时文件中
            * 当`map task`完成时，会发送一条消息到`master`，告知其文件的位置。若`master`此前已经收到过该消息了，那么会直接忽略当前消息
            * 当`reduct task`完成时，会将私有的临时文件重命名为一个全局文件，当多个`reduce task`在不同机器上执行时，`GMR`中的原子重命名操作会保证只有一个会成功
    * `Locality`
        * `master`更倾向于将`map task`调度到包含更多相关输入的机器上，或者相关输入距离最近的机器上（比如相关输入位于同一个交换机下的不同机器）。这样能够极大程度地降低网络资源的开销
    * `Task Granularity`
        * `map-task`会被切分为更小的`M`份，而`reduce task`会被切分为更小的`N`份。理论上`M`和`N`的大小要远远大于机器的数量。这样能够获得更均衡的负载，也能够提升异常恢复的速度
        * 如何确定`M`和`N`的具体数值呢？有如下几点考量
            1. 这些任务的信息必须能够保存在`master`的内存中
            1. `M`与输入的总量有关，最好将输入文件的大小控制在`16M-64M`之间
            1. `N`是机器数量的几倍（2-3倍）
    * `Backup Tasks`
        * `MapReduce`的整体耗时与最慢的`task`密切相关
        * `GMR`提供了一种机制来解决这个问题，在任务完成后，`master`会将尚未结束的任务分配给这台机器，称为`backup-task`。一旦`original-task`或是`backup-task`完成，那么该任务就算完成
1. `Refinements`
    * `Partitioning Function`：用于将输入拆分成多份，通常来说，`hash`可以将输入均匀地拆分成多份。但是在某些场景中，比如将网站的URL进行拆分，更希望于将相同host的URL拆分到同一个分区中，此时就需要一个特殊的分区函数
    * `Ordering Guarantees`：对于某个分区，GBR保证输入是按照key的升序排列。基于这个约束，可以很容易地得到一个有序的输出
    * `Combiner Function`：在许多场景下，`map-task`产生的数据中包含大量的重复。`Combiner Function`用于合并这些重复的数据，以减少网络开销
    * `Input and Output Types`：`Input Types`与如何切割输入流有关。例如按行读入和按单词读入，对数据流的切分是不同的
    * `Side-effects`：在一些场景中，用户会在`map-reduce`的过程中，产生一些额外的输出（文件）。这些额外的操作需要保证原子以及幂等。通常，应用会写临时文件，结束时重命名文件
    * `Skipping Bad Records`：有时候`map`或者`reduce`的实现中可能存在bug，导致crash，这些bug会导致整个`MapReduce`过程无法完成。通常来说，最好的方法是修复bug，但有时是无法修复的，比如bug来自三方库，或者源码未开放。因此，在适当的情况下，忽略一些数据（会触发bug的数据）是可接受的
    * `Location Execution`：GBR很难debug，因为任务分布在不同的机器上。为此，开发了一个`MapReduce`库用户debug，该库会将所有任务都在本地运行
    * `Status Information`：`master`会启动一个HTTP服务，用于管理和展示
    * `Counters`：GBR提供了一系列的Counter来统计数据。每个`worker`中的`Counters`信息会定期的同步给`master`并做汇总。如果有相同的任务，`master`可以基于已完成的任务的`Counter`对尚在进行的任务做出预测

## 4.1 参考

* [浅析 Bigtable 和 LevelDB 的实现](https://www.cnblogs.com/jpfss/p/10721384.html)

# 5 Efficiency in the Columbia Database Query Optimizer

# 6 Fast Selection and Aggregation on Encoded Data using Operator Specialization

# 7 Shared memory consistency models - A tutorial

