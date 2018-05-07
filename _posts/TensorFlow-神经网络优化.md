---
title: TensorFlow-神经网络优化
date: 2018-05-07 16:12:08
mathjax: true
tags: 
- 摘录
categories: 
- Machine Learning
---

__目录__

<!-- toc -->
<!--more-->

# 1 神经元模型

神经元模型，用数学公式表示为{% raw %}$$f(\sum_{i}{x_{i}w_{i}}+b)$${% endraw %}

1. {% raw %}$f${% endraw %}为激活函数
1. {% raw %}$b${% endraw %}为偏置项

__激活函数引入非线性激活因素，提高模型的表达力__，常用的激活函数有

1. __relu__，tensorflow中表示为`tf.nn.relu()`{% raw %}$$f(x)=max(x,0)$${% endraw %}
1. __sigmoid__，tensorflow中表示为`tf.nn.sigmoid()`{% raw %}$$f(x)=\frac{1}{1+e^{-x}}$${% endraw %}
1. __tanh__，tensorflow中表示为`tf.nn.tanh()`{% raw %}$$f(x)=\frac{1-e^{-2x}}{1+e^{-2x}}$${% endraw %}

## 1.1 神经网络的层数

* 一般不计入输入层
* __层数 = n个隐藏层 + 1个输出层__

## 1.2 神经网路待优化的参数

神经网络中所有参数{% raw %}$w${% endraw %}的个数 + 所有参数{% raw %}$b${% endraw %}的个数

# 2 损失函数(loss)

用来表示预测值{% raw %}$y${% endraw %}与已知答案{% raw %}$y\_${% endraw %}的差距。在训练神经网络时，通过不断改变神经网络中所有参数，__使损失函数不断减小__，从而训练出更高准确率的神经网络模型

常用的损失函数有均方误差、自定义和交叉熵等

## 2.1 均方误差

均方误差{% raw %}$mse${% endraw %}：{% raw %}$n${% endraw %}个样本的预测值{% raw %}$y${% endraw %}与已知答案{% raw %}$y\_${% endraw %}之差的平方和，再求平均值，其数学形式如下：

{% raw %}$$MSE(y\_, y)=\frac{\sum_{i=1}^{n}{(y-y\_)^2}}{n}$${% endraw %}

在Tensorflow中用`loss_mse = tf.reduce_mean(tf.square(y_ - y))`表示

## 2.2 自定义损失函数

根据问题的实际情况，定制合理的损失函数

## 2.3 交叉熵

交叉熵(Cross Entropy)表示两个概率分布之间的__距离__

* 交叉熵越大，两个概率分布距离越远，两个概率分布越相异
* 交叉熵越小，两个概率分布距离越近，两个概率分布越相似

交叉熵计算公式如下：

{% raw %}$$
H(y\_, y) = - \sum{y\_} * \log{y}
$${% endraw %}

在Tensorflow中用`ce= -tf.reduce_mean(y_* tf.log(tf.clip_by_value(y, 1e-12, 1.0)))`表示

__softmax 函数__：将n分类的n个输出(y1,y2...yn)变为满足以下概率分布要求的函数{% raw %}$$\forall{x} \;\; P(X=x)\in[0,1) \; and \; \sum{P_x(X=x)} = 1$${% endraw %}

在Tensorflow中，一般让模型的输出经过`sofemax`函数，以获得输出分类的概率分布，再与标准答案对比，求出交叉熵，得到损失函数，用如下函数实现

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

指数衰减学习率是指，学习率随着训练轮数变化而动态更新

# 4 滑动平均

# 5 正则化

# 6 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [人工智能实践：Tensorflow笔记-曹健](https://www.icourse163.org/course/PKU-1002536002)

