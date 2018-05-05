---
title: TensorFlow-搭建神经网络
date: 2018-05-05 17:49:39
mathjax: true
tags: 
- 摘录
categories: 
- Machine Learning
---

__目录__

<!-- toc -->
<!--more-->

# 1 基本概念

基于Tensorflow的神经网络（Neural Network，NN）

1. 用__张量__表示数据
1. 用__计算图__搭建神经网络
1. 用__会话__执行计算图，优化线上的权重(参数)，得到模型

## 1.1 张量

张量就是多维数组（列表），用“阶”表示张量的维度

1. `0阶`张量__称作标量__，表示一个单独的数
    * {% raw %}$S = 123${% endraw %}
1. `1阶`张量__称作向量__，表示一个一维数组
    * {% raw %}$V = [1,2,3]${% endraw %}
1. `2阶`张量__称作矩阵__，表示一个二维数组，它可以有`i`行`j`列个元素，每个元素可以用行号和列号共同索引到
    * {% raw %}$m = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]${% endraw %}
1. 判断张量是几阶的，就通过张量右边的方括号数

## 1.2 数据类型

Tensorflow的数据类型有

1. `tf.int8`
1. `tf.int16`
1. `tf.int32`
1. `tf.int64`
1. `tf.float32`
1. `tf.double`
1. ...

## 1.3 计算图

计算图(Graph)是搭建神经网络的计算过程，是承载一个或多个计算节点的一张图，__只搭建网络，不运算__

神经网络的基本模型是神经元，神经元的基本模型其实就是数学中的乘、加运算。神经元的形式化定义如下{% raw %}$$f(\sum_{i}{x_{i}w_{i}}+b)$${% endraw %}

1. {% raw %}$f${% endraw %}为激活函数，引入非线性激活因素，提高模型的表达能力

举个简单的例子，给定如下计算图

![fig1](/images/TensorFlow-搭建神经网络/fig1.png)

我们用tensorflow实现上述计算图

```py
import tensorflow as tf

# 定义张量
x = tf.constant([[1.0, 2.0]])
w = tf.constant([[3.0], [4.0]])

# 计算图
y = tf.matmul(x, w)
print(y)
```

## 1.4 会话

会话(Session)用于执行计算图中的节点运算

继续上一小节的例子，我们用会话执行计算图中的节点运算

```py
# 执行计算图中的节点运算
with tf.Session() as sess:
    print(sess.run(y))
```

# 2 神经网络的参数

神经网络的参数是指神经元线上的权重w，用变量表示，__一般会先随机生成这些参数__。生成参数的方法是让w等于`tf.Variable`，把生成的方式写在括号里

神经网络中常用的生成随机数/数组的函数有：

1. `tf.random_normal()`：生成正态分布随机数
    * `w = tf.Variable(tf.random_normal([2,3], stddev=2, mean=0, seed=1))`
    * stddev表示标准差
    * mean表示均值
    * seed表示随机数种子
1. `tf.truncated_normal()`：生成去掉过大偏离点的正态分布随机数
    * `w = tf.Variable(tf.Truncated_normal([2,3], stddev=2, mean=0, seed=1))`
    * 如果随机出来的数据偏离平均值超过__两个__标准差，这个数据将重新生成
1. `tf.random_uniform()`：生成均匀分布随机数
    * `w = random_uniform(shape=7, minval=0, maxval=1, dtype=tf.int32，seed=1`
    * 表示从一个均匀分布`[minval maxval)`中随机采样
1. `tf.zeros`：表示生成全0数组
1. `tf.ones`：表示生成全1数组
1. `tf.fill`：表示生成全定值数组
1. `tf.constant`：表示生成直接给定值的数组

# 3 神经网络的实现过程综述

神经网络的搭建一般按照如下过程进行

1. 准备数据集，提取特征，作为输入喂给神经网络（Neural Network，NN）
1. 搭建NN结构，从输入到输出（先搭建计算图，再用会话执行）
    * NN前向传播算法-->计算输出
1. 大量特征数据喂给NN，迭代优化NN参数
    * NN反向传播算法 优化参数训练模型
1. 使用训练好的模型预测和分类

# 4 前向传播

前向传播是指__搭建模型的计算过程__，让模型具有推理能力，可以针对一组输入给出相应的输出

举个简单的例子，给出如下神经网络。由__输入{% raw %}$\vec{X}${% endraw %}经过神经网络计算得到{% raw %}$\vec{Y}${% endraw %}的过程就称为前向传播过程__

![fig2](/images/TensorFlow-搭建神经网络/fig2.png)

该神经网络可表示成如下形式

{% raw %}$$
\vec{Y} = \vec{X} \cdot \vec{W^{1}} \cdot \vec{W^{2}}
$${% endraw %}

1. {% raw %}$\vec{X}${% endraw %}是输入向量
1. {% raw %}$\vec{W^{1}}${% endraw %}是2行3列的参数矩阵
1. {% raw %}$\vec{W^{2}}${% endraw %}是3行1列的参数矩阵
1. {% raw %}$\vec{Y}${% endraw %}是输出向量

上述例子的前向传播过程的tensorflow描述（__变量初始化__、__计算图节点运算__都要用__会话__实现）

* __变量初始化__：在`sess.run`函数中用`tf.global_variables_initializer()`汇总所有待优化变量

```py
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
```

* __计算图节点运算__：在`sess.run`函数中写入待运算的节点

```py
sess.run(y)
```

* __喂数据__：用`tf.placeholder`占位，在`sess.run`函数中用`feed_dict`喂数据（以这种方式实现__计算图__与__运算__的分离）

```py
# 一组数据
x = tf.placeholder(tf.float32, shape=(1, 2))
sess.run(y, feed_dict={x: [[0.5,0.6]]})
```

```py
# 多组数据
x = tf.placeholder(tf.float32, shape=(None, 2))
sess.run(y, feed_dict={x: [[0.1,0.2],[0.2,0.3],[0.3,0.4],[0.4,0.5]]})
```

## 4.1 完整程序

__喂一组数据__

```py
# coding:utf-8
import tensorflow as tf

# 定义输入和参数
x = tf.placeholder(tf.float32, shape=(1, 2))
w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

# 定义前向传播过程
a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

# 用会话计算结果
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    print("y in tf3_3.py is:\n", sess.run(y, feed_dict={x: [[0.7, 0.5]]}))
```

__喂多组数据__

```py
# coding:utf-8
import tensorflow as tf

# 定义输入和参数
x = tf.placeholder(tf.float32, shape=(None, 2))
w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

# 定义前向传播过程
a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

# 用会话计算结果
with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)
    print("y in tf3_3.py is:\n", sess.run(y, feed_dict={x: [[0.1,0.2],[0.2,0.3],[0.3,0.4],[0.4,0.5]]}))

```

# 5 反向传播

反向传播是指__训练模型参数__，在所有参数上用梯度下降，使NN模型在训练数据上的__损失函数__最小

## 5.1 损失函数

损失函数(loss)：计算得到的预测值`y`与已知答案`y_`的差距

损失函数的计算有很多方法，均方误差MSE是比较常用的方法之一

{% raw %}$$
MSE(y\_, y)=\frac{\sum_{i=1}^{n}{(y-y\_)^2}}{n}
$${% endraw %}

在tensorflow中可以表示为`loss_mse = tf.reduce_mean(tf.square(y_ - y))`

## 5.2 反向传播训练方法

反向传播训练方法是指，__以减小loss值为优化目标__。有梯度下降、momentum优化器、adam优化器等优化方法。这三种优化方法用tensorflow的函数可以表示为

1. `train_step=tf.train.GradientDescentOptimizer(learning_rate).minimize(loss)`
1. `train_step=tf.train.MomentumOptimizer(learning_rate, momentum).minimize(loss)`
1. `train_step=tf.train.AdamOptimizer(learning_rate).minimize(loss)`

### 5.2.1 学习率

优化器中都需要一个叫做学习率的参数，使用时，如果学习率选择过大会出现震荡不收敛的情况，如果学习率选择过小，会出现收敛速度慢的情况

### 5.2.2 随机梯度下降算法

随机梯度下降算法，使参数沿着梯度的反方向，即总损失减小的方向移动，实现更新参数

{% raw %}$$
\theta_{n+1} = \theta_{n} - \alpha \frac{\partial{J(\theta_{n})}}{\theta_{n}}
$${% endraw %}

* {% raw %}$J(\theta_{n})${% endraw %}表示损失函数
* {% raw %}$\theta${% endraw %}表示参数，其下标表示迭代次数
* {% raw %}$\alpha${% endraw %}表示学习率

### 5.2.3 Momentum算法

该算法在更新参数时，利用了超参数，参数更新公式如下

{% raw %}$$
d_{i} = \beta d_{i-1} + g(\theta_{i-1}) \\
\theta_{i} = \theta_{i-1} - \alpha d_{i}
$${% endraw %}

* {% raw %}$\alpha${% endraw %}表示学习率
* {% raw %}$\beta${% endraw %}表示超参数
* {% raw %}$g(\theta_{i-1}) ${% endraw %}表示损失函数的梯度

### 5.2.4 自适应学习率的优化算法

Adam算法和随机梯度下降算法不同。随机梯度下降算法保持单一的学习率更新所有的参数，学习率在训练过程中并不会改变。而Adam算法通过计算梯度的一阶矩估计和二阶矩估计而为不同的参数设计独立的自适应性学习率

## 5.3 完整程序

```py
# coding:utf-8

import tensorflow as tf
import numpy as np

BATCH_SIZE = 8
seed = 23455

# 基于seed产生随机数
rng = np.random.RandomState(seed)

# 随机数返回32行2列的矩阵，表示32组体积和重量作为输入数据集
X = rng.rand(32, 2)

# 产生数据标签
Y = [[int(x0 + x1 < 1)] for (x0, x1) in X]

print("X:\n", X)
print("Y:\n", Y)

# 1 定义神经网络的输入、参数和输出，定义前向传播过程
x = tf.placeholder(tf.float32, shape=(None, 2))
y_ = tf.placeholder(tf.float32, shape=(None, 1))

w1 = tf.Variable(tf.random_normal([2, 3], stddev=1, seed=1))
w2 = tf.Variable(tf.random_normal([3, 1], stddev=1, seed=1))

a = tf.matmul(x, w1)
y = tf.matmul(a, w2)

# 2 定义损失函数及反向传播方法
loss = tf.reduce_mean(tf.square(y - y_))
train_step = tf.train.GradientDescentOptimizer(0.001).minimize(loss)
# train_step = tf.train.MomentumOptimizer(0.001).minimize(loss)
# train_step = tf.train.AdamOptimizer(0.001).minimize(loss)

# 3 生成会话，训练STEPS轮

with tf.Session() as sess:
    init_op = tf.global_variables_initializer()
    sess.run(init_op)

    # 输出目前（未经训练）的参数取值
    print("w1:\n", sess.run(w1))
    print("w1:\n", sess.run(w2))
    print("\n")

    # 训练模型
    STEPS = 3000
    for i in range(STEPS):
        start = (i * BATCH_SIZE) % 32
        end = start + BATCH_SIZE
        sess.run(train_step, feed_dict={x: X[start:end], y_: Y[start:end]})
        if i % 500 == 0:
            total_loss = sess.run(loss, feed_dict={x: X, y_: Y})
            print("After %d training step(s), loss on all data is %g" % (i, total_loss))

    # 输出训练后的参数取值
    print("\n")
    print("w1:\n", sess.run(w1))
    print("w1:\n", sess.run(w2))
```

# 6 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [人工智能实践：Tensorflow笔记-曹健](https://www.icourse163.org/course/PKU-1002536002)
