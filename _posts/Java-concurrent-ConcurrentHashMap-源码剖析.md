---
title: Java concurrent ConcurrentHashMap 源码剖析
date: 2017-07-03 18:52:25
tags:
categories:
- Java concurrent 源码剖析
---

__目录__

<!-- toc -->
<!--more-->

# 1 前言

__本篇博客分析的是JDK 1.8 的ConcurrentHashMap，该版本的ConcurrentHashMap与JDK 1.7有较大的差异__

__ConcurrentHashMap源码分析分为以下几个部分__

* 常量简介
* 字段简介
* 内部类简介
* Utils方法简介
* 重要方法源码分析

# 2 常量简介
```Java
    /**
     * The largest possible table capacity.  This value must be
     * exactly 1<<30 to stay within Java array allocation and indexing
     * bounds for power of two table sizes, and is further required
     * because the top two bits of 32bit hash fields are used for
     * control purposes.
     */
    private static final int MAXIMUM_CAPACITY = 1 << 30;

    /**
     * The default initial table capacity.  Must be a power of 2
     * (i.e., at least 1) and at most MAXIMUM_CAPACITY.
     */
    private static final int DEFAULT_CAPACITY = 16;

    /**
     * The largest possible (non-power of two) array size.
     * Needed by toArray and related methods.
     */
    static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

    /**
     * The default concurrency level for this table. Unused but
     * defined for compatibility with previous versions of this class.
     */
    private static final int DEFAULT_CONCURRENCY_LEVEL = 16;

    /**
     * The load factor for this table. Overrides of this value in
     * constructors affect only the initial table capacity.  The
     * actual floating point value isn't normally used -- it is
     * simpler to use expressions such as {@code n - (n >>> 2)} for
     * the associated resizing threshold.
     */
    private static final float LOAD_FACTOR = 0.75f;

    /**
     * The bin count threshold for using a tree rather than list for a
     * bin.  Bins are converted to trees when adding an element to a
     * bin with at least this many nodes. The value must be greater
     * than 2, and should be at least 8 to mesh with assumptions in
     * tree removal about conversion back to plain bins upon
     * shrinkage.
     */
    static final int TREEIFY_THRESHOLD = 8;

    /**
     * The bin count threshold for untreeifying a (split) bin during a
     * resize operation. Should be less than TREEIFY_THRESHOLD, and at
     * most 6 to mesh with shrinkage detection under removal.
     */
    static final int UNTREEIFY_THRESHOLD = 6;

    /**
     * The smallest table capacity for which bins may be treeified.
     * (Otherwise the table is resized if too many nodes in a bin.)
     * The value should be at least 4 * TREEIFY_THRESHOLD to avoid
     * conflicts between resizing and treeification thresholds.
     */
    static final int MIN_TREEIFY_CAPACITY = 64;

    /**
     * Minimum number of rebinnings per transfer step. Ranges are
     * subdivided to allow multiple resizer threads.  This value
     * serves as a lower bound to avoid resizers encountering
     * excessive memory contention.  The value should be at least
     * DEFAULT_CAPACITY.
     */
    private static final int MIN_TRANSFER_STRIDE = 16;

    /**
     * The number of bits used for generation stamp in sizeCtl.
     * Must be at least 6 for 32bit arrays.
     */
    private static int RESIZE_STAMP_BITS = 16;

    /**
     * The maximum number of threads that can help resize.
     * Must fit in 32 - RESIZE_STAMP_BITS bits.
     */
    private static final int MAX_RESIZERS = (1 << (32 - RESIZE_STAMP_BITS)) - 1;

    /**
     * The bit shift for recording size stamp in sizeCtl.
     */
    private static final int RESIZE_STAMP_SHIFT = 32 - RESIZE_STAMP_BITS;

    /*
     * Encodings for Node hash fields. See above for explanation.
     */
    static final int MOVED     = -1; // hash for forwarding nodes
    static final int TREEBIN   = -2; // hash for roots of trees
    static final int RESERVED  = -3; // hash for transient reservations
    static final int HASH_BITS = 0x7fffffff; // usable bits of normal node hash
```

__常量分为两大类__

1. __第一大类是配置参数__

    * __MAXIMUM_CAPACITY__：32位整型中最高两位作为控制参数，因此hashtable的最大容量是1<<30，必须是2的幂次(至于为什么必须是2的幂次，以及2的幂次能带来的好处，下面的分析会多次提到)
    * __DEFAULT_CAPACITY__：hashtable的默认初始容量，当构造函数不指定大小时，以该值为默认的初始hashtable大小
    * __MAX_ARRAY_SIZE__：toArray方法中会用到，大小可以是非2的幂次
    * __DEFAULT_CONCURRENCY_LEVEL__：并发等级，用于兼容之前的版本(暂时不用关心这个常数)
    * __LOAD_FACTOR__：负载因子，计算公式为：factor=元素总个数/bucket数量。实际上代码中并不用这个浮点数来计算，而是用(n-n>>2)来计算n*LOAD_FACTORY，因为位运算比乘法效率更高
    * __TREEIFY_THRESHOLD__：树化的临界值，当一个bin/bucket新增一个元素后，节点数量达到该值时，就要从链表转为红黑树
    * __UNTREEIFY_THRESHOLD__：逆树化的临界值，当一个bin/bucket删除一个元素后，节点数量到达该值时，就要从红黑树转为链表。
        * 这两个临界值设置为不同的值，我认为是为了避免当节点数量到达临界值时的多次树化与逆树化操作(增加节点/删除节点交替进行这种特殊情况)
    * __MIN_TREEIFY_CAPACITY__：树化时，hashtable的最小容量。如果一个bin/bucket需要进行树化操作，但是此时hashtable的容量小于该常量，则hashtable应该扩容而不是树化该bin/bucket
    * __MIN_TRANSFER_STRIDE__：进行并发扩容时，每个线程分得的最小bin/bucket数量
    * __RESIZE_STAMP_BITS__：
    * __MAX_RESIZERS__：参与并发扩容的最大线程数量
    * __RESIZE_STAMP_SHIFT__：32-RESIZE_STAMP_BITS
        * RESIZE_STAMP_BITS与RESIZE_STAMP_SHIFT的含义并没有弄明白
1. __第二大类是特殊节点的hash值__
    * __MOVED__：forwarding节点的hash值
    * __TREEBIN__：树根节点的hash值
    * __RESERVED__：
    * __HASH_BITS__：用于节点hash值的计算

# 3 字段简介

```Java
    /**
     * The array of bins. Lazily initialized upon first insertion.
     * Size is always a power of two. Accessed directly by iterators.
     */
    transient volatile Node<K,V>[] table;

    /**
     * The next table to use; non-null only while resizing.
     */
    private transient volatile Node<K,V>[] nextTable;

    /**
     * Base counter value, used mainly when there is no contention,
     * but also as a fallback during table initialization
     * races. Updated via CAS.
     */
    private transient volatile long baseCount;

    /**
     * Table initialization and resizing control.  When negative, the
     * table is being initialized or resized: -1 for initialization,
     * else -(1 + the number of active resizing threads).  Otherwise,
     * when table is null, holds the initial table size to use upon
     * creation, or 0 for default. After initialization, holds the
     * next element count value upon which to resize the table.
     */
    private transient volatile int sizeCtl;

    /**
     * The next table index (plus one) to split while resizing.
     */
    private transient volatile int transferIndex;

    /**
     * Spinlock (locked via CAS) used when resizing and/or creating CounterCells.
     */
    private transient volatile int cellsBusy;

    /**
     * Table of counter cells. When non-null, size is a power of 2.
     */
    private transient volatile CounterCell[] counterCells;

    // views
    private transient KeySetView<K,V> keySet;
    private transient ValuesView<K,V> values;
    private transient EntrySetView<K,V> entrySet;
```

* __table__：bin/bucket的数组，其大小一定是2的幂次
* __nextTable__：仅在扩容时有用，扩容后的数组
* __baseCount__：节点计数值
* __sizeCtl__：非常重要的字段
    * 若为负数则代表正在初始化或者扩容。-1代表正在初始化，其余值代表正在扩容-(1 + 参与扩容的线程数量)
    * 当table == null时，代表table初始化大小
    * 当table != null时，代表table需要扩容时的节点数量临界值，即容器中节点数量超过sizeCtl时，需要进行扩容操作
* __transferIndex__：用于并发扩容时槽位的分配
* __cellsBusy__：？？？
* __counterCells__：初始化时counterCells为空，在并发量很高时，如果存在两个线程同时执行CAS修改baseCount值，则失败的线程会继续执行方法体中的逻辑，使用CounterCell记录元素个数的变化
* __keySet__：Key集合
* __values__：Value集合
* __entrySet__：键值对集合

# 4 内部类简介

## 4.1 Node

__Node继承自Map.Entry，是其余节点的父类__

* Node子类中如果hash值为负数，代表这类节点是特殊节点，特殊节点不持有key-value。例如TreeBin，ForwardingNode，ReservationNode
* Node子类中如果hash值非负数，代表这类节点是正常节点，持有key-value。例如Node本身以及TreeNode

## 4.2 TreeNode

__TreeNode节点是树节点__

* 增加了左右孩子字段，父节点字段，颜色字段等
* 采用的树形结构是：红黑树

## 4.3 TreeBin

__当一个bin/bucket持有一颗树时，该槽位放置的节点是TreeBin__

* TreeBin节点持有红黑树根节点
* TreeBin节点持有读写锁，该读写所强制写操作必须等待读操作执行完毕
* TreeBin内部定义了一些红黑树性质维护的静态方法

## 4.4 ForwardingNode

__ForwardingNode节点表明此时正在进行扩容__

* 同时表明当前槽位中的节点已经转移到新的hashtable中去了
* 该节点持有nextTable的引用

## 4.5 ReservationNode

__??__

# 5 Utils方法简介

## 5.1 spread

__spread用于转换hash值__

* 由于table的大小是2的幂次，槽位的计算利用的是求余运算，因此那些高位有区别的散列值在低容量时将始终冲突
    * 举个例子，假设当前table的大小是16，hash值为5，(5+1<<7)，(5+1<<8),...这些元素将始终冲突，因为求余后，这些元素都位于同一个槽位中
* h ^ (h >>> 16)：h逻辑右移16位与原值异或，得到的结果其高16位与原来相同，低16位由原来的高16位与原来的低16位共同决定。这样做的好处是：即便hashtable的容量较小，hash值的高16位在槽位计算上仍然能起到作用

```Java
    /**
     * Spreads (XORs) higher bits of hash to lower and also forces top
     * bit to 0. Because the table uses power-of-two masking, sets of
     * hashes that vary only in bits above the current mask will
     * always collide. (Among known examples are sets of Float keys
     * holding consecutive whole numbers in small tables.)  So we
     * apply a transform that spreads the impact of higher bits
     * downward. There is a tradeoff between speed, utility, and
     * quality of bit-spreading. Because many common sets of hashes
     * are already reasonably distributed (so don't benefit from
     * spreading), and because we use trees to handle large sets of
     * collisions in bins, we just XOR some shifted bits in the
     * cheapest possible way to reduce systematic lossage, as well as
     * to incorporate impact of the highest bits that would otherwise
     * never be used in index calculations because of table bounds.
     */
    static final int spread(int h) {
        return (h ^ (h >>> 16)) & HASH_BITS;
    }
```

## 5.2 tableSizeFor

__tableSizeFor方法用于计算不小于给定数值的最大2的幂次__

* 该方法等效的逻辑是：找到c-1的最高位，假设为第i位，生成一个从第i位到第0位都是1，其余位全是0的数值，然后返回该数值+1
* 5条位或语句就可以生成一个从第i位到第0位都是1，其余位全是0的数值

```Java
    /**
     * Returns a power of two table size for the given desired capacity.
     * See Hackers Delight, sec 3.2
     */
    private static final int tableSizeFor(int c) {
        int n = c - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```

## 5.3 access方法

__访问table元素的方法__

* 其中ASHIFT是指数组元素的大小
* ABASE指的是数组头元素的偏移量
* 因此((long)i << ASHIFT) + ABASE指的是数组第i个元素的偏移量

```Java
    static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
        return (Node<K,V>)U.getObjectVolatile(tab, ((long)i << ASHIFT) + ABASE);
    }

    static final <K,V> boolean casTabAt(Node<K,V>[] tab, int i,
                                        Node<K,V> c, Node<K,V> v) {
        return U.compareAndSwapObject(tab, ((long)i << ASHIFT) + ABASE, c, v);
    }

    static final <K,V> void setTabAt(Node<K,V>[] tab, int i, Node<K,V> v) {
        U.putObjectVolatile(tab, ((long)i << ASHIFT) + ABASE, v);
    }
```

# 6 重要方法源码分析

## 6.1 put

__put方法用于向HashMap中插入一个键值对__

* 键和值都必须不为null(为什么)

```Java
    /**
     * Maps the specified key to the specified value in this table.
     * Neither the key nor the value can be null.
     *
     * <p>The value can be retrieved by calling the {@code get} method
     * with a key that is equal to the original key.
     *
     * @param key key with which the specified value is to be associated
     * @param value value to be associated with the specified key
     * @return the previous value associated with {@code key}, or
     *         {@code null} if there was no mapping for {@code key}
     * @throws NullPointerException if the specified key or value is null
     */
    public V put(K key, V value) {
        return putVal(key, value, false);
    }
```

## 6.2 putVal

__putVal是真正执行插入操作的方法__

* 第三个参数为true时代表插入的键值必须不存在，否则不会更新原值，而是返回null
* 

```Java
    /** Implementation for put and putIfAbsent */
    final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        //获取经过修饰的hash值
        int hash = spread(key.hashCode());
        //槽位计数值
        int binCount = 0;
        //死循环，常规模式
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
            //当hashtable未初始化时，首先初始化
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
                //当对应的bin/bucket中是空时，通过一个CAS操作插入一个Node节点，这个操作不需要加锁，仅需要CAS即可，保证有且只有一个线程执行成功即可
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            //当前槽位中的节点存放的是ForwardingNode，说明此时正在进行扩容，当前线程参与到扩容操作中去
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            //此时槽位中放置的是正常节点
                //1. 可能是一个链表
                //2. 可能是一个红黑树
            else {
                V oldVal = null;
                //同一时刻，只能有一个线程能访问一个bin/bucket
                synchronized (f) {
                    //double-check，看是否被其他线程修改了
                    if (tabAt(tab, i) == f) {
                        //bin/bucket中的节点构成一个链表
                        if (fh >= 0) {
                            //该变量用于统计bin中节点的数据
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                //找到了键值相同的节点
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    //当允许重复时，更新原值，否则不更新
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                //更新迭代的节点。当e处于链表尾部时，说明插入的键值对不存在，因此追加到链表的尾部即可
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        //bin/bucket中的节点构成一个红黑树
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            //直接赋值为2，大于0小于TREEIFY_THRESHOLD的整数均可
                            binCount = 2;
                            //将节点插入到红黑树中
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                //
                if (binCount != 0) {
                    //bin/bucket中放置的是链表，并且元素数量到达树化的临界值，将链表转为红黑树
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        addCount(1L, binCount);
        return null;
    }
```

## 6.3 initTable

__initTable方法用于初始化hashtable__

* sizeCtl字段的值代表的就是初始化的hashtable的大小
* 初始化过程仅能通过一个线程来完成

```Java
    /**
     * Initializes table, using the size recorded in sizeCtl.
     */
    private final Node<K,V>[] initTable() {
        Node<K,V>[] tab; int sc;
        while ((tab = table) == null || tab.length == 0) {
            //此时，说明正有其他线程在初始化，为了确保仅有一个线程能够进行初始化操作，当前线程只需要让出CPU时间进行等待即可
            if ((sc = sizeCtl) < 0)
                Thread.yield(); // lost initialization race; just spin
            //利用CAS操作将sizeCtl改为-1，若失败，说明有其他线程枪战成功，当前线程只需要等待即可
            else if (U.compareAndSwapInt(this, SIZECTL, sc, -1)) {
                try {
                    //这里为什么需要double-check?
                    if ((tab = table) == null || tab.length == 0) {
                        int n = (sc > 0) ? sc : DEFAULT_CAPACITY;
                        @SuppressWarnings("unchecked")
                        Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n];
                        table = tab = nt;
                        //这里将sc设定为0.75*n，当hashtable中元素个数达到该数值时，说明hashtable需要进行扩容操作了
                        sc = n - (n >>> 2);
                    }
                } finally {
                    sizeCtl = sc;
                }
                break;
            }
        }
        return tab;
    }
```

## 6.4 transfer

__transfer方法用于hashtable的扩张__

* 多个线程将会同时参与扩张过程
* 利用transferIndex字段来串行化槽位的分配
* 表大小始终保持为2的幂次，在表的扩张中起到非常重要的作用。原槽位中的节点仅有两个去向，一个就是原槽位i，另一个就是i+n/2，其中n是新表大小

```Java
    /**
     * Moves and/or copies the nodes in each bin to new table. See
     * above for explanation.
     */
    private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
        int n = tab.length, stride;
        //条件为真时，每个线程分片数量设置为MIN_TRANSFER_STRIDE
            //1. 当含有一个CPU时，且n<MIN_TRANSFER_STRIDE
            //2. 当含有多个CPU时，且n/8/NCPU<MIN_TRANSFER_STRIDE
        if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
            stride = MIN_TRANSFER_STRIDE; // subdivide range
        //当新表为空时，进行新表的初始化。这里没有加锁也没有CAS，如何保证只有一个线程执行了初始化操作???
        if (nextTab == null) {            // initiating
            try {
                @SuppressWarnings("unchecked")
                Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];
                nextTab = nt;
            } catch (Throwable ex) {      // try to cope with OOME
                sizeCtl = Integer.MAX_VALUE;
                return;
            }
            nextTable = nextTab;
            //初始化分片索引
            transferIndex = n;
        }
        int nextn = nextTab.length;
        //创建一个ForwardingNode节点用于标记已经transfer的bin/bucket
        ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);
        boolean advance = true;
        boolean finishing = false; // to ensure sweep before committing nextTab
        //bound是当前线程所分得的分片的下边界，当前线程处理的分片区域为[bound,bound+stride)，即i∈[bound，nextIndex-1]
        for (int i = 0, bound = 0;;) {
            Node<K,V> f; int fh;
            //下面的循环递减i或者进行分片操作
            while (advance) {
                int nextIndex, nextBound;
                //进行循环变量的递减操作
                    //--i >= bound表示，当前领取的分片尚未处理完毕
                    //finishing代表当前线程是最后一个线程
                if (--i >= bound || finishing)
                    advance = false;
                //没有分片可以领取了
                else if ((nextIndex = transferIndex) <= 0) {
                    i = -1;
                    advance = false;
                }
                //重新尝试领取一个分片任务，通过CAS操作串行化分片领取操作
                else if (U.compareAndSwapInt
                         (this, TRANSFERINDEX, nextIndex,
                          nextBound = (nextIndex > stride ?
                                       nextIndex - stride : 0))) {
                    //分片区间是[bound,nextIndex-1]
                    bound = nextBound;
                    i = nextIndex - 1;
                    advance = false;
                }
            }
            //当前线程已经完成当前领取分片的节点转移任务
                //1. i < 0：当(nextIndex = transferIndex) <= 0时主动设置为-1，或者领取的就是[0,stride)的分片区间，并且该区间所有节点均已转移完成
                //2. i >= n：不懂
                //3. i + n >= nextn：不懂
            if (i < 0 || i >= n || i + n >= nextn) {
                int sc;
                //当前线程是执行transfer操作的最后一个线程，该线程负责收尾工作
                if (finishing) {
                    nextTable = null;
                    table = nextTab;
                    sizeCtl = (n << 1) - (n >>> 1);
                    return;
                }
                //当前线程不是执行transfer操作的最后一个线程，将sizeCtl-1，根据注释的说明，sizeCtl=-(1+numThread)，因此这里将线程的计数值递增(为什么是递增，不是应该递减么，这与注释的描述有点不一致)
                //其实线程数量的统计并不重要，重要的是必须保证只有一个线程来执行收尾工作，sc+1也好，sc-1也好，与(resizeStamp(n) << RESIZE_STAMP_SHIFT)+2的差值的绝对值就是线程数量
                if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {
                    //addCount方法中，在第一个线程执行transfer方法时会将sizeCtl赋值为(resizeStamp(n) << RESIZE_STAMP_SHIFT)+2，因此这里用一个相同的值来判断是否还有其他线程存在
                    if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
                        return;
                    finishing = advance = true;
                    i = n; // recheck before commit
                }
            }
            //i指向的bin/bucket中没有节点，只需要将该节点赋值为fwd，即ForwardingNode节点即可，标记该bin/bucket已经转移到新表中了。这样其他线程在访问到原hashtable时，就可以进行判断
            else if ((f = tabAt(tab, i)) == null)
                advance = casTabAt(tab, i, null, fwd);
            //i指向的bin/bucket中的节点已经是ForwardingNode节点了，因此已经处理完毕了
            else if ((fh = f.hash) == MOVED)
                advance = true; // already processed
            else {
                //直接用内建的synchronized来进行加锁操作
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        Node<K,V> ln, hn;
                        //如果bin/bucket中存放的是链表
                        if (fh >= 0) {
                            int runBit = fh & n;
                            Node<K,V> lastRun = f;
                            for (Node<K,V> p = f.next; p != null; p = p.next) {
                                int b = p.hash & n;
                                if (b != runBit) {
                                    runBit = b;
                                    lastRun = p;
                                }
                            }
                            if (runBit == 0) {
                                ln = lastRun;
                                hn = null;
                            }
                            else {
                                hn = lastRun;
                                ln = null;
                            }
                            for (Node<K,V> p = f; p != lastRun; p = p.next) {
                                int ph = p.hash; K pk = p.key; V pv = p.val;
                                if ((ph & n) == 0)
                                    ln = new Node<K,V>(ph, pk, pv, ln);
                                else
                                    hn = new Node<K,V>(ph, pk, pv, hn);
                            }
                            setTabAt(nextTab, i, ln);
                            setTabAt(nextTab, i + n, hn);
                            setTabAt(tab, i, fwd);
                            advance = true;
                        }
                        //如果bin/bucket中存放的是红黑树
                        else if (f instanceof TreeBin) {
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> lo = null, loTail = null;
                            TreeNode<K,V> hi = null, hiTail = null;
                            int lc = 0, hc = 0;
                            for (Node<K,V> e = t.first; e != null; e = e.next) {
                                int h = e.hash;
                                TreeNode<K,V> p = new TreeNode<K,V>
                                    (h, e.key, e.val, null, null);
                                if ((h & n) == 0) {
                                    if ((p.prev = loTail) == null)
                                        lo = p;
                                    else
                                        loTail.next = p;
                                    loTail = p;
                                    ++lc;
                                }
                                else {
                                    if ((p.prev = hiTail) == null)
                                        hi = p;
                                    else
                                        hiTail.next = p;
                                    hiTail = p;
                                    ++hc;
                                }
                            }
                            ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                                (hc != 0) ? new TreeBin<K,V>(lo) : t;
                            hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                                (lc != 0) ? new TreeBin<K,V>(hi) : t;
                            setTabAt(nextTab, i, ln);
                            setTabAt(nextTab, i + n, hn);
                            setTabAt(tab, i, fwd);
                            advance = true;
                        }
                    }
                }
            }
        }
    }
```

## 6.5 addCount

__addCount方法用于更新键值对计数值baseCount__

```Java
    /**
     * Adds to count, and if table is too small and not already
     * resizing, initiates transfer. If already resizing, helps
     * perform transfer if work is available.  Rechecks occupancy
     * after a transfer to see if another resize is already needed
     * because resizings are lagging additions.
     *
     * @param x the count to add
     * @param check if <0, don't check resize, if <= 1 only check if uncontended
     */
    private final void addCount(long x, int check) {
        CounterCell[] as; long b, s;
        //条件成立时
            //1. counterCells != null 说明有冲突，baseCount的数值的更新需要结合counterCells
            //2. baseCount CAS更新失败
        if ((as = counterCells) != null ||
            !U.compareAndSwapLong(this, BASECOUNT, b = baseCount, s = b + x)) {
            CounterCell a; long v; int m;
            boolean uncontended = true;
            //此时已经出现冲突，但是counterCells尚未初始化，那么调用fullAddCount进行初始化操作
            if (as == null || (m = as.length - 1) < 0 ||
                (a = as[ThreadLocalRandom.getProbe() & m]) == null ||
                !(uncontended =
                  U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))) {
                fullAddCount(x, uncontended);
                return;
            }
            if (check <= 1)
                return;
            s = sumCount();
        }
        if (check >= 0) {
            Node<K,V>[] tab, nt; int n, sc;
            while (s >= (long)(sc = sizeCtl) && (tab = table) != null &&
                   (n = tab.length) < MAXIMUM_CAPACITY) {
                int rs = resizeStamp(n);
                if (sc < 0) {
                    if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
                        sc == rs + MAX_RESIZERS || (nt = nextTable) == null ||
                        transferIndex <= 0)
                        break;
                    if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1))
                        transfer(tab, nt);
                }
                else if (U.compareAndSwapInt(this, SIZECTL, sc,
                                             (rs << RESIZE_STAMP_SHIFT) + 2))
                    transfer(tab, null);
                s = sumCount();
            }
        }
    }
```

## 6.6 fullAddCount

__fullAddCount方法用于__

```Java
    // See LongAdder version for explanation
    private final void fullAddCount(long x, boolean wasUncontended) {
        int h;
        //h可以认为是获取的一个随机数
        if ((h = ThreadLocalRandom.getProbe()) == 0) {
            ThreadLocalRandom.localInit();      // force initialization
            h = ThreadLocalRandom.getProbe();
            wasUncontended = true;
        }
        boolean collide = false;                // True if last slot nonempty
        for (;;) {
            CounterCell[] as; CounterCell a; int n; long v;
            //如果counterCells已经初始化
            if ((as = counterCells) != null && (n = as.length) > 0) {
                if ((a = as[(n - 1) & h]) == null) {
                    if (cellsBusy == 0) {            // Try to attach new Cell
                        CounterCell r = new CounterCell(x); // Optimistic create
                        if (cellsBusy == 0 &&
                            U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) {
                            boolean created = false;
                            try {               // Recheck under lock
                                CounterCell[] rs; int m, j;
                                if ((rs = counterCells) != null &&
                                    (m = rs.length) > 0 &&
                                    rs[j = (m - 1) & h] == null) {
                                    rs[j] = r;
                                    created = true;
                                }
                            } finally {
                                cellsBusy = 0;
                            }
                            if (created)
                                break;
                            continue;           // Slot is now non-empty
                        }
                    }
                    collide = false;
                }
                else if (!wasUncontended)       // CAS already known to fail
                    wasUncontended = true;      // Continue after rehash
                else if (U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))
                    break;
                else if (counterCells != as || n >= NCPU)
                    collide = false;            // At max size or stale
                else if (!collide)
                    collide = true;
                else if (cellsBusy == 0 &&
                         U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) {
                    try {
                        if (counterCells == as) {// Expand table unless stale
                            CounterCell[] rs = new CounterCell[n << 1];
                            for (int i = 0; i < n; ++i)
                                rs[i] = as[i];
                            counterCells = rs;
                        }
                    } finally {
                        cellsBusy = 0;
                    }
                    collide = false;
                    continue;                   // Retry with expanded table
                }
                h = ThreadLocalRandom.advanceProbe(h);
            }
            //counterCells尚未初始化
            else if (cellsBusy == 0 && counterCells == as &&
                     U.compareAndSwapInt(this, CELLSBUSY, 0, 1)) {
                boolean init = false;
                try {                           // Initialize table
                    //初始化counterCells
                    if (counterCells == as) {
                        CounterCell[] rs = new CounterCell[2];
                        rs[h & 1] = new CounterCell(x);
                        counterCells = rs;
                        init = true;
                    }
                } finally {
                    cellsBusy = 0;
                }
                if (init)
                    break;
            }
            else if (U.compareAndSwapLong(this, BASECOUNT, v = baseCount, v + x))
                break;                          // Fall back on using base
        }
    }
```

## 6.7 sumCount

__sumCount方法用于__

```Java
    final long sumCount() {
        CounterCell[] as = counterCells; CounterCell a;
        long sum = baseCount;
        if (as != null) {
            for (int i = 0; i < as.length; ++i) {
                if ((a = as[i]) != null)
                    sum += a.value;
            }
        }
        return sum;
    }
```

## 6.8 

## 6.9 

## 6.10 

## 6.11 

##
