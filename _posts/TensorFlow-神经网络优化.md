---
title: TensorFlow-神经网络优化
date: 2018-05-07 16:12:08
mathjax: true
tags: 
- 摘录
categories: 
- Machine Learning
---

**阅读更多**

<!--more-->

# 1 神经元模型

神经元模型，用数学公式表示为{% raw %}$$f(\sum_{i}{x_{i}w_{i}}+b)$${% endraw %}

1. {% raw %}$f${% endraw %}为激活函数
1. {% raw %}$b${% endraw %}为偏置项

**激活函数引入非线性激活因素，提高模型的表达力**，常用的激活函数有

1. **relu**，TensorFlow中表示为`tf.nn.relu()`{% raw %}$$f(x)=max(x,0)$${% endraw %}
1. **sigmoid**，TensorFlow中表示为`tf.nn.sigmoid()`{% raw %}$$f(x)=\frac{1}{1+e^{-x}}$${% endraw %}
1. **tanh**，TensorFlow中表示为`tf.nn.tanh()`{% raw %}$$f(x)=\frac{1-e^{-2x}}{1+e^{-2x}}$${% endraw %}

## 1.1 神经网络的层数

* 一般不计入输入层
* **层数 = n个隐藏层 + 1个输出层**

## 1.2 神经网路待优化的参数

神经网络中所有参数{% raw %}$w${% endraw %}的个数 + 所有参数{% raw %}$b${% endraw %}的个数

# 2 损失函数(loss)

用来表示预测值{% raw %}$y${% endraw %}与已知答案{% raw %}$y\_${% endraw %}的差距。在训练神经网络时，通过不断改变神经网络中所有参数，**使损失函数不断减小**，从而训练出更高准确率的神经网络模型

常用的损失函数有均方误差、自定义和交叉熵等

## 2.1 均方误差

均方误差{% raw %}$mse${% endraw %}：{% raw %}$n${% endraw %}个样本的预测值{% raw %}$y${% endraw %}与已知答案{% raw %}$y\_${% endraw %}之差的平方和，再求平均值，其数学形式如下：

{% raw %}$$MSE(y\_, y)=\frac{\sum_{i=1}^{n}{(y-y\_)^2}}{n}$${% endraw %}

在TensorFlow中表示为

```py
loss_mse = tf.reduce_mean(tf.square(y_ - y))
```

## 2.2 自定义损失函数

根据问题的实际情况，定制合理的损失函数

## 2.3 交叉熵

交叉熵(Cross Entropy)表示两个概率分布之间的**距离**

* 交叉熵越大，两个概率分布距离越远，两个概率分布越相异
* 交叉熵越小，两个概率分布距离越近，两个概率分布越相似

交叉熵计算公式如下：

{% raw %}$$H(y\_, y) = - \sum{y\_} * \log{y}$${% endraw %}

在TensorFlow中表示为

```py
ce= -tf.reduce_mean(y_* tf.log(tf.clip_by_value(y, 1e-12, 1.0)))
```

**softmax 函数**：将n分类的n个输出(y1,y2...yn)变为满足以下概率分布要求的函数{% raw %}$$\forall{x} \;\; P(X=x)\in[0,1) \; and \; \sum{P_x(X=x)} = 1$${% endraw %}

softmax函数表示为{% raw %}$$softmax(y_i)=\frac{e^{y_i}}{\sum_{i=1}^{n}{e^{y_i}}}$${% endraw %}

在TensorFlow中，一般让模型的输出经过`sofemax`函数，以获得输出分类的概率分布，再与标准答案对比，求出交叉熵，得到损失函数，用如下函数实现

```py
ce = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=y, labels=tf.argmax(y_, 1))
cem = tf.reduce_mean(ce)
```

# 3 学习率

学习率（learning_rate）表示了每次参数更新的幅度大小

1. 学习率过大，会导致待优化的参数在最小值附近波动，不收敛
1. 学习率过小，会导致待优化的参数收敛缓慢

参数的更新公式如下{% raw %}$$w_{n+1} = w_n -learning\_rate \nabla$${% endraw %}

## 3.1 指数衰减学习率

指数衰减学习率是指，学习率随着训练轮数变化而动态更新。其学习率计算公式如下：

{% raw %}$$learning\_rate = LEARNING\_RATE\_BASE \;\;*\;\; LEARNING\_RATE\_DECAY^{\frac{global\_step}{LEARNING\_RATE\_STEP}}$${% endraw %}

* `LEARNING_RATE_BASE`：学习率初始值
* `LEARNING_RATE_DECAY`：学习率衰减率
* `LEARNING_RATE_STEP`：多少轮更新一次学习率，一般来说是总样本数除以BATCH_SIZE

在TensorFlow中表示为

```py
global_step = tf.Variable(0, trainable=False) # 记录了当前训练轮数，为不可训练型参数
learning_rate = tf.train.exponential_decay(
    LEARNING_RATE_BASE, # 学习率初始值
    global_step, # 第几轮（计数器）
    LEARNING_RATE_STEP, LEARNING_RATE_DECAY,
    staircase=True/False)
```

其中

* 若`staircase`设置为True时，表示`global_step/LEARNING_RATE_STEP`取整数，学习率**阶梯型**衰减
* 若`staircase`设置为False时，学习率会是一条平滑下降的**曲线**

# 4 滑动平均

滑动平均记录了一段时间内模型中所有参数{% raw %}$w${% endraw %}和{% raw %}$b${% endraw %}各自的平均值。利用滑动平均值可以增强模型的泛化能力

**滑动平均值（影子）计算公式**：`影子 = 衰减率 * 影子 + (1 - 衰减率) * 参数`，其中{% raw %}$$衰减率 = min{MOVING\_AVERAGE\_DECAY, \frac{1 + 轮数}{10 + 轮数}}$${% endraw %}

在TensorFlow中表示为

```py
# MOVING_AVERAGE_DECAY表示滑动平均衰减率，一般会赋接近1的值
# global_step表示当前训练了多少轮
ema = tf.train.ExponentialMovingAverage(MOVING_AVERAGE_DECAY，global_step)

# ema.apply()函数实现对括号内参数求滑动平均
# tf.trainable_variables()函数实现把所有待训练参数汇总为列表
ema_op = ema.apply(tf.trainable_variables())
with tf.control_dependencies([train_step, ema_op]):
    # 该函数实现将滑动平均和训练过程同步运行
    train_op = tf.no_op(name='train')
```

# 5 正则化

神经网络模型在训练数据集上的准确率较高，在新的数据进行预测或分类时准确率较低，说明模型的泛化能力差。这种现象称为**过拟合**

正则化是指，在损失函数中给每个参数{% raw %}$w${% endraw %}加上权重，引入模型复杂度指标，从而抑制模型噪声，减小过拟合。使用正则化后，损失函数{% raw %}$loss${% endraw %}变为两项之和

{% raw %}$$loss = loss(y \;与\; y\_) + REGULARIZER \;*\; loss(w)$${% endraw %}

**正则化的两种方式**

1. {% raw %}$L1${% endraw %}正则化{% raw %}$$loss_{L1} = \sum_i{|w_i|}$${% endraw %}
1. {% raw %}$L2${% endraw %}正则化{% raw %}$$loss_{L1} = \sum_i{|w_i|^2}$${% endraw %}

在TensorFlow中表示为

```py
# L1正则化
loss(w) = tf.contrib.layers.l1_regularizer(REGULARIZER)(w)
# L2正则化
loss(w) = tf.contrib.layers.l2_regularizer(REGULARIZER)(w)

tf.add_to_collection('losses', tf.contrib.layers.l2_regularizer(regularizer)(w)
loss = cem + tf.add_n(tf.get_collection('losses'))
```

# 6 参考

* [人工智能实践：TensorFlow笔记-曹健](https://www.icourse163.org/course/PKU-1002536002)

