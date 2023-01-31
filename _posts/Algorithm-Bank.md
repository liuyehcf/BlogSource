---
title: Algorithm-Bank
date: 2017-08-16 21:20:29
tags: 
- 摘录
categories: 
- Algorithm
- Others
---

**阅读更多**

<!--more-->

# 1 需求分析

## 1.1 银行家算法的实现思想

允许进程动态地申请资源，**系统在每次实施资源分配之前，先计算资源分配的安全性**，若此次资源分配安全（即资源分配后，系统能按某种顺序来为每个进程分配其所需的资源，直至最大需求，使每个进程都可以顺利地完成），便将资源分配给进程，否则不分配资源，让进程等待

## 1.2 死锁的概念

死锁是指两个或两个以上的进程在执行过程中，由于竞争资源或者由于彼此通信而造成的一种阻塞的现象，若无外力作用，它们都将无法推进下去。此时称系统处于死锁状态或系统产生了死锁，这些永远在互相等待的进程称为死锁进程

银行家算法是避免死锁的一种重要方法。操作系统按照银行家制定的规则为进程分配资源，当进程首次申请资源时，要测试该进程对资源的最大需求量，如果系统现存的资源可以满足它的最大需求量则按当前的申请量分配资源，否则就推迟分配。当进程在执行中继续申请资源时，先测试该进程已占用的资源数与本次申请的资源数之和是否超过了该进程对资源的最大需求量。若超过则拒绝分配资源，若没有超过则再测试系统现存的资源能否满足该进程尚需的最大资源量，若能满足则按当前的申请量分配资源，否则也要推迟分配

## 1.3 产生死锁的必要条件

1. **互斥条件**：指进程对所分配到的资源进行排它性使用，即在一段时间内某资源只由一个进程占用。如果此时还有其它进程请求资源，则请求者只能等待，直至占有资源的进程用毕释放
1. **请求和保持条件**：指进程已经保持至少一个资源，但又提出了新的资源请求，而该资源已被其它进程占有，此时请求进程阻塞，但又对自己已获得的其它资源保持不放
1. **不剥夺条件**：指进程已获得的资源，在未使用完之前，不能被剥夺，只能在使用完时由自己释放
1. **环路等待条件**：指在发生死锁时，必然存在一个进程——资源的环形链，即进程集合`{P0, P1, P2, ..., Pn}`中的`P0`正在等待一个`P1`占用的资源；`P1`正在等待`P2`占用的资源，......，`Pn`正在等待已被`P0`占用的资源

## 1.4 功能实现

理解了死锁的原因，尤其是产生死锁的四个必要条件，就可以最大可能地避免、预防和解除死锁。所以，在系统设计、进程调度等方面注意如何能够不让这四个必要条件成立，如何确定资源的合理分配算法，避免进程永久占据系统资源。此外，也要防止进程在处于等待状态的情况下占用资源，在系统运行过程中，对进程发出的每一个系统能够满足的资源申请进行动态检查，并根据检查结果决定是否分配资源，若分配后系统可能发生死锁，则不予分配，否则予以分配。因此，对资源的分配要给予合理的规划

# 2 概要设计

## 2.1 数据结构

1. **可利用资源向量Available**：这是一个含有m个元素的数组，其中的而每一个元素代表一类可利用资源数目，其初始值是系统中所配置的该类全部可用资源的数目，其数值随该类资源的分配和回收而动态的改变。如果`Available[j] = K`，则表示系统中现有`Rj类资源`的数目为`K`
1. **最大需求矩阵Max**：这是一个n*m的矩阵，它定义了系统中n个进程中的每一个进程对m类资源的最大需求。如果`Max[i][j] = K`，则表示`进程i`需要`Rj类资源`的最大数目为`K`
1. **分配矩阵Allocation**：这也是一个n*m的矩阵，它定义了系统中每一类资源当前已分配给每一进程的资源数。如果`Allocation[i][j] = K`，则表示`进程i`当前已分得`Rj类资源`的数目为`K`
1. **需求矩阵Need**：这也是一个n*m的矩阵，用以表示每一个进程尚需的各类资源数。如果`Need[i][j] = K`，则表示`进程i`还需要`Rj类资源`的数目为`K`个，方能完成任务
* 上述三个矩阵间存在下述关系：`Need[i][j] = Max[i][j] - Allocation[i][j]`

## 2.2 设计思路

**第一部分：银行家算法模块**

1. 如果`Request <= Need`，则转向2；否则出错
1. 如果`Request <= Available`，则转向3；否则等待
1. 系统试探分配请求的资源给进程
1. 系统执行安全性算法

**第二部分:安全性算法模块**

1. 设置两个向量
    * `Work = Available`：表示系统可提供给进程继续运行所需要的各类资源数目
    * `Finish`：表示系统是否有足够资源分配给进程
1. 若`Finish[i] == False && Need <= Work`(i为资源类别)，则执行3；否则执行4
1. 进程P获得第i类资源，则顺利执行直至完成，并释放资源：`Work = Work + Allocation`以及`Finish[i] = true`；转2
1. 若所有进程的`Finish[i] == true`，则表示系统安全；否则不安全！

## 2.3 系统安全性判断

**什么叫做系统安全性：即不会产生死锁的条件，所有的进程都能够按照一定顺序结束运行。某个时刻，某一进程的完成不依赖于其他进程所占有的资源。**

**详细过程与解释如下(类似于一个BFS遍历有向图的过程，每次访问degree为0的节点)**

1. 以进程i1为例，进程i1对资源j的需求量为`Need[i1][j]`，如果对于所有资源，均满足`Need[i1][j] <= Available[j]`，**意味着进程i1的完成只需要从系统剩余资源中获取即可，并不需要其他进程让出资源**，因此进程i1是安全的，于是进程i1在当前状态下是可独立完成的，其完成的顺序记为1
1. 现在我们需要假设进程i1完成了，那么在进程i1完成的基础上，是否有其他进程也能够独立完成任务？此时我们需要将i1占有的资源全部退还到Available中，即对所有资源执行`Available[j] += Allocation[i][j]`。那么在Available的新状态下，如果进程i2对于所有资源均满足`Need[i2][j] <= Available[j]`，**意味着进程i2的完成只需要从系统剩余资源中获取即可，并不需要其他进程让出资源**，因此进程i2也是安全的，于是进程i2在当前状态下是可独立完成的，其完成的顺序记为2
1. 重复上述步骤...直至**所有进程均可完成(安全状态)**或者**存在某个或某些进程无法完成(不安全状态)**

# 3 Java源码

```java
package org.liuyehcf.other;

import java.util.Arrays;
import java.util.Random;

/**
 * Created by HCF on 2017/8/16.
 */
public class BankAlgorithm {
    /**
     * 可用资源数目
     */
    private static final int RESOURCE_NUM = 3;

    /**
     * 进程数量
     */
    private static final int PROCESS_NUM = 10;

    /**
     * 初始化的系统资源总量
     */
    private int[] total;

    /**
     * 目前可用资源
     * available[i]代表第i类资源的可用数目
     * available[i]的初始值就是系统配置的该类资源的全部数目
     */
    private int[] available;

    /**
     * max[i][j]代表进程i需要j类资源的最大数目
     */
    private int[][] max;

    /**
     * allocation[i][j]代表进程i分得j类资源的数目
     */
    private int[][] allocation;

    /**
     * need[i][j]代表进程i还需要j类资源的数目
     */
    private int[][] need;

    /**
     * state[i]表示进程i是否处于安全状态，true是，false否
     * isSafeState的临时变量，避免重复分配内存，因此设为字段
     */
    private boolean[] state;

    /**
     * finished[i]==true说明进程i执行完毕了
     */
    private boolean[] finished;

    /**
     * 执行完毕的进程数量
     */
    private int finishedCnt;

    /**
     * available数组的拷贝，临时数组
     */
    private int[] pause;

    /**
     * 随机数，用于随机产生需要分配资源的进程id以及资源数量
     */
    private Random random = new Random();

    public void serve() {
        initialize();

        while (finishedCnt != PROCESS_NUM) {
            int processId = getRandomProcessId();

            int[] request = getRandomRequest(processId);

            check();
            requestResource(processId, request);
            check();
        }
    }

    /**
     * 初始化系统
     */
    private void initialize() {
        total = new int[RESOURCE_NUM];
        available = new int[RESOURCE_NUM];
        max = new int[PROCESS_NUM][RESOURCE_NUM];
        allocation = new int[PROCESS_NUM][RESOURCE_NUM];
        need = new int[PROCESS_NUM][RESOURCE_NUM];
        state = new boolean[PROCESS_NUM];
        finished = new boolean[PROCESS_NUM];
        pause = new int[RESOURCE_NUM];

        finishedCnt = 0;

        Arrays.fill(total, 10);
        Arrays.fill(available, 10);
        for (int i = 0; i < PROCESS_NUM; i++) {
            for (int j = 0; j < RESOURCE_NUM; j++) {
                max[i][j] = random.nextInt(5) + 1;
                need[i][j] = max[i][j];
            }
        }
    }

    private int getRandomProcessId() {
        int remainProcessNum = PROCESS_NUM - finishedCnt;

        int index = random.nextInt(remainProcessNum);

        for (int i = 0; i < PROCESS_NUM; i++) {
            if (finished[i]) continue;
            if (index-- == 0) {
                return i;
            }
        }
        throw new RuntimeException();
    }

    private int[] getRandomRequest(int processId) {
        int[] request = new int[RESOURCE_NUM];

        for (int j = 0; j < RESOURCE_NUM; j++) {
            request[j] = random.nextInt(Math.min(available[j], need[processId][j]) + 1);
        }

        return request;
    }

    /**
     * 为进程processId申请指定的资源
     *
     * @param processId
     * @param request
     */
    private void requestResource(int processId, int[] request) {
        //首先检查一下输入的合法性
        for (int j = 0; j < RESOURCE_NUM; j++) {
            if (request[j] > need[processId][j]) {
                throw new RuntimeException();
            }
            if (request[j] > available[j]) {
                throw new RuntimeException();
            }
        }

        //试探性分配
        for (int j = 0; j < RESOURCE_NUM; j++) {
            available[j] -= request[j];
            allocation[processId][j] += request[j];
            need[processId][j] -= request[j];
        }

        if (isSafeState()) {
            System.err.println("Safe!");
            //对于进程processId，已经分配完毕的资源种类的计数值
            int count = 0;

            for (int j = 0; j < RESOURCE_NUM; j++) {
                if (need[processId][j] == 0) {
                    count++;
                }
            }

            if (count == RESOURCE_NUM) {
                for (int j = 0; j < RESOURCE_NUM; j++) {
                    available[j] += allocation[processId][j];
                    allocation[processId][j] = 0;
                    need[processId][j] = max[processId][j];
                }
                finishedCnt++;
                finished[processId] = true;
                System.out.println("Process " + processId + " is finished!");
            }
        } else {
            System.err.println("Not safe!");
            //撤销试探性分配
            for (int j = 0; j < RESOURCE_NUM; j++) {
                available[j] += request[j];
                allocation[processId][j] -= request[j];
                need[processId][j] += request[j];
            }
        }
    }

    /**
     * 判断当前系统是否满足安全性
     *
     * @return
     */
    private boolean isSafeState() {

        System.arraycopy(available, 0, pause, 0, RESOURCE_NUM);
        Arrays.fill(state, false);

        boolean canBreak = false;
        while (!canBreak) {
            canBreak = true;
            for (int i = 0; i < PROCESS_NUM; i++) {
                if (finished[i]) {
                    state[i] = true;
                    continue;
                }
                int count = 0;
                for (int j = 0; j < RESOURCE_NUM; j++) {
                    //资源j的现有量能够满足进程i对资源j的需求
                    if (need[i][j] <= pause[j]) {
                        count++;
                    }
                }

                //现有的所有资源均能满足进程i的需求，也就是说进程i不依赖其他进程所占有的资源也能够完成执行
                if (!state[i] && count == RESOURCE_NUM) {
                    state[i] = true;
                    //由于进程i是安全的，因此当进程i结束并释放所有占用的资源后，可能还会有别的进程被判定为安全，因此while循环不能结束
                    canBreak = false;
                    //现在假定进程i执行完毕了，现在退还i占用的所有资源
                    for (int j = 0; j < RESOURCE_NUM; j++) {
                        pause[j] += allocation[i][j];
                    }
                }
            }
        }

        int safeProcessNum = 0;

        for (boolean b : state) {
            safeProcessNum += (b ? 1 : 0);
        }

        return safeProcessNum == PROCESS_NUM;
    }

    private void check() {
        for (int i = 0; i < PROCESS_NUM; i++) {
            for (int j = 0; j < RESOURCE_NUM; j++) {
                if (max[i][j] != need[i][j] + allocation[i][j]) throw new RuntimeException();
                if (max[i][j] > total[j]) throw new RuntimeException();
            }
        }

        if (!isSafeState()) throw new RuntimeException();
    }

    public static void main(String[] args) {
        BankAlgorithm bankAlgorithm = new BankAlgorithm();

        bankAlgorithm.serve();
    }
}
```

# 4 参考

* [银行家算法1](http://www.cnblogs.com/Lynn-Zhang/p/5672080.html)
* [银行家算法2](http://blog.csdn.net/yaopeng_2005/article/details/6935235)
* [死锁及其解决方案（避免、预防、检测）](http://blog.csdn.net/yyf_it/article/details/52412071)
