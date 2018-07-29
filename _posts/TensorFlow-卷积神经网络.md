---
title: TensorFlow-卷积神经网络
date: 2018-05-13 10:29:35
mathjax: true
tags: 
- 摘录
categories: 
- Machine Learning
---

__阅读更多__

<!--more-->

# 1 卷积

全连接NN：每个神经元与前后相邻层的每一个神经元都有连接关系，输入是特征，输出为预测的结果

__待优化的参数过多，容易导致模型过拟合__。为避免这种现象，实际应用中一般不会将原始图片直接喂入全连接网络

在实际应用中，会先对原始图像进行特征提取，把提取到的特征喂给全连接网络，再让全连接网络计算出分类评估值

![fig1](/images/TensorFlow-卷积神经网络/fig1.png)

__卷积是一种有效提取图片特征的方法__。一般用一个正方形__卷积核__，遍历图片上的每一个像素点。图片与卷积核重合区域内相对应的每一个像素值乘卷积核内相对应点的权重，然后求和，再加上偏置后，最后得到输出图片中的一个像素值

![fig2](/images/TensorFlow-卷积神经网络/fig2.png)

有时会在输入图片周围进行__全零填充__，这样可以保证输出图片的尺寸和输入图片一致

![fig3](/images/TensorFlow-卷积神经网络/fig3.png)

在TensorFlow中，计算卷积的方式如下

```py
tf.nn.conv2d(
    输入描述，eg. [batch, 5, 5, 1] # [喂入几组数据，行分辨率，列分辨率，通道数]
    卷积核描述，eg. [3, 3, 1, 16] # [卷积核行分辨率，卷积核列分辨率，通道数，核数量]
    核滑动步长，eg. [1, 1, 1, 1] # [固定1，行步长，列步长，固定1]
    padding='VALID' # 'VALID'不填充，'SAME'全零填充
)
```

__参数解释__

1. 输入描述：用`batch`给出一次喂入多少张图片，每张图片的分辨率大小，比如`5`行`5`列，以及这些图片包含几个通道的信息，如果是灰度图则为单通道，参数写`1`，如果是彩色图则为红绿蓝三通道，参数写`3`
1. 卷积核描述：要给出卷积核的行分辨率和列分辨率、通道数以及用 了几个卷积核。比如上图描述，表示卷积核行列分辨率分别为`3`行和 `3`列，且是`1`通道的，一共有`16`个这样的卷积核，卷积核的通道数是由输入图片的通道数决定的，卷积核的通道数等于输入图片的通道数，所以卷积核的通道数也是1。__一共有`16`个这样的卷积核，说明卷积操作后输出图片的深度是`16`，也就是输出为`16`通道__
1. 核滑动步长：上图第二个参数表示__横向滑动步长__，第三个参数表示__纵向滑动步长__，这句表示横向纵向都以`1`为步长。__第一个`1`和最后一个`1`这里固定的__
1. 是否使用padding：'SAME'表示填充，'VALID'表示不填充

# 2 池化

TensorFlow给出了计算池化的函数。最大池化用`tf.nn.max_pool`函数，平均池化用`tf.nn.avg_pool`函数

```py
pool = tf.nn.max_pool(
    输入描述，eg. [batch, 28, 28, 6] # [喂入几组数据，行分辨率，列分辨率，通道数]
    池化核描述（仅大小），eg. [1, 2, 2, 1] # [固定1，行分辨率，列分辨率，固定1]
    池化核滑动步长，eg. [1, 2, 2, 1] # [固定1，行步长，列步长，固定1]
    padding = 'SAME'
)
```

__参数解释__

1. __输入描述__：给出一次输入`batch`张图片、行列分辨率、输入通道的个数
1. __池化核描述__：只描述行分辨率和列分辨率，__第一个和最后一个参数固定是`1`__
1. 对池化核滑动步长的描述：只描述横向滑动步长和纵向滑动步长，__第一个和最后一个参数固定是`1`__
1. __是否使用padding__：`padding`可以是使用零填充`SAME`或者不使用零填充`VALID`

# 3 舍弃

在神经网络训练过程中，为了减少过多参数常使用`dropout`的方法，__将一部分神经元按照一定概率从神经网络中舍弃__。这种舍弃是__临时性__的，仅在训练时舍弃一些神经元；在使用神经网络时，会把所有的神经元恢复到神经网络中。Dropout可以有效减少过拟合

![fig4](/images/TensorFlow-卷积神经网络/fig4.png)

在实际应用中，常常在前向传播构建神经网络时使用`dropout`来减小过拟合加快模型的训练速度

`dropout`一般会放到全连接网络中。如果在训练参数的过程中，`输出 =tf.nn.dropout(上层输出，暂时舍弃神经元的概率)`，这样就有指定概率的神经元被随机置零，置零的神经元不参加当前轮的参数优化

## 3.1 卷积

__卷积神经网络可以认为由两部分组成，一部分是对输入图片进行特征提取，另一部分就是全连接网络__，只不过喂入全连接网络的不再是原始图片，而是经过若干次卷积、激活和池化后的__特征信息__

卷积神经网络从诞生到现在，已经出现了许多经典网络结构，比如 `Lenet-5`、`Alenet`、`VGGNet`、`GoogleNet`和`ResNet`等。每一种网络结构都是以__卷积、激活、池化、全连__接这四种操作为基础进行扩展

`Lenet-5`是最早出现的卷积神经网络，由Lecun团队首先提出，`Lenet-5`有效解决了手写数字的识别问题

# 4 代码

## 4.1 mnist_lenet5_forward.py

```py
import tensorflow as tf

IMAGE_SIZE = 28
NUM_CHANNELS = 1
CONV1_SIZE = 5
CONV1_KERNEL_NUM = 32
CONV2_SIZE = 5
CONV2_KERNEL_NUM = 64
FC_SIZE = 512
OUTPUT_NODE = 10

def get_weight(shape, regularizer):
    w = tf.Variable(tf.truncated_normal(shape, stddev=0.1))
    if regularizer is not None:
        tf.add_to_collection('losses', tf.contrib.layers.l2_regularizer(regularizer)(w))
    return w

def get_bias(shape):
    b = tf.Variable(tf.zeros(shape))
    return b

def conv2d(x, w):
    return tf.nn.conv2d(x, w, strides=[1, 1, 1, 1], padding='SAME')

def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')

def forward(x, train, regularizer):
    conv1_w = get_weight(shape=[CONV1_SIZE, CONV1_SIZE, NUM_CHANNELS, CONV1_KERNEL_NUM], regularizer=regularizer)
    conv1_b = get_bias([CONV1_KERNEL_NUM])
    conv1 = conv2d(x, conv1_w)
    relu1 = tf.nn.relu(tf.nn.bias_add(conv1, conv1_b))
    pool1 = max_pool_2x2(relu1)

    conv2_w = get_weight(shape=[CONV2_SIZE, CONV2_SIZE, CONV1_KERNEL_NUM, CONV2_KERNEL_NUM], regularizer=regularizer)
    conv2_b = get_bias([CONV2_KERNEL_NUM])
    conv2 = conv2d(pool1, conv2_w)
    relu2 = tf.nn.relu(tf.nn.bias_add(conv2, conv2_b))
    pool2 = max_pool_2x2(relu2)

    pool_shape = pool2.get_shape().as_list()
    nodes = pool_shape[1] * pool_shape[2] * pool_shape[3]
    reshaped = tf.reshape(pool2, [pool_shape[0], nodes])

    fc1_w = get_weight([nodes, FC_SIZE], regularizer)
    fc1_b = get_bias([FC_SIZE])
    fc1 = tf.nn.relu(tf.matmul(reshaped, fc1_w) + fc1_b)
    if train:
        fc1 = tf.nn.dropout(fc1, 0.5)

    fc2_w = get_weight([FC_SIZE, OUTPUT_NODE], regularizer)
    fc2_b = get_bias([OUTPUT_NODE])
    y = tf.matmul(fc1, fc2_w) + fc2_b

    return y

```

## 4.2 mnist_lenet5_backward.py

```py
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

import chapter7.mnist_lenet5_forward as mnist_lenet5_forward
import os
import numpy as np

BATCH_SIZE = 100
LEARNING_RATE_BASE = 0.005
LEARNING_RATE_DECAY = 0.99
REGULARIZER = 0.0001
STEPS = 50000
MOVING_AVERAGE_DECAY = 0.99
MODEL_SAVE_PATH = "./model/"
MODEL_NAME = "mnist_model"

def backward(mnist):
    x = tf.placeholder(tf.float32, [
        BATCH_SIZE,
        mnist_lenet5_forward.IMAGE_SIZE,
        mnist_lenet5_forward.IMAGE_SIZE,
        mnist_lenet5_forward.NUM_CHANNELS])

    y_ = tf.placeholder(tf.float32, [None, mnist_lenet5_forward.OUTPUT_NODE])
    y = mnist_lenet5_forward.forward(x, True, REGULARIZER)
    global_step = tf.Variable(0, trainable=False)

    ce = tf.nn.sparse_softmax_cross_entropy_with_logits(logits=y, labels=tf.argmax(y_, 1))
    cem = tf.reduce_mean(ce)
    loss = cem + tf.add_n(tf.get_collection('losses'))

    learning_rate = tf.train.exponential_decay(
        LEARNING_RATE_BASE,
        global_step,
        mnist.train.num_examples / BATCH_SIZE,
        LEARNING_RATE_DECAY,
        staircase=True)

    train_step = tf.train.GradientDescentOptimizer(learning_rate).minimize(loss, global_step=global_step)

    ema = tf.train.ExponentialMovingAverage(MOVING_AVERAGE_DECAY, global_step)
    ema_op = ema.apply(tf.trainable_variables())
    with tf.control_dependencies([train_step, ema_op]):
        train_op = tf.no_op(name='train')

    saver = tf.train.Saver()

    with tf.Session() as sess:
        init_op = tf.global_variables_initializer()
        sess.run(init_op)

        ckpt = tf.train.get_checkpoint_state(MODEL_SAVE_PATH)
        if ckpt and ckpt.model_checkpoint_path:
            saver.restore(sess, ckpt.model_checkpoint_path)

        for i in range(STEPS):
            xs, ys = mnist.train.next_batch(BATCH_SIZE)
            reshaped_xs = np.reshape(xs, (
                BATCH_SIZE,
                mnist_lenet5_forward.IMAGE_SIZE,
                mnist_lenet5_forward.IMAGE_SIZE,
                mnist_lenet5_forward.NUM_CHANNELS))
            _, loss_value, step = sess.run([train_op, loss, global_step], feed_dict={x: reshaped_xs, y_: ys})
            if i % 100 == 0:
                print("After %d training step(s), loss on training batch is %g." % (step, loss_value))
                saver.save(sess, os.path.join(MODEL_SAVE_PATH, MODEL_NAME), global_step=global_step)

def main():
    mnist = input_data.read_data_sets('./data/', one_hot=True)
    backward(mnist)

if __name__ == "__main__":
    main()

```

## 4.3 mnist_lenet5_test.py

```py
import time
import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data
import chapter7.mnist_lenet5_forward as mnist_lenet5_forward
import chapter7.mnist_lenet5_backward as mnist_lenet5_backward
import numpy as np

TEST_INTERVAL_SECS = 5

def test(mnist):
    with tf.Graph().as_default() as g:
        x = tf.placeholder(tf.float32, [
            mnist.test.num_examples,
            mnist_lenet5_forward.IMAGE_SIZE,
            mnist_lenet5_forward.IMAGE_SIZE,
            mnist_lenet5_forward.NUM_CHANNELS])
        y_ = tf.placeholder(tf.float32, [None, mnist_lenet5_forward.OUTPUT_NODE])
        y = mnist_lenet5_forward.forward(x, False, None)

        ema = tf.train.ExponentialMovingAverage(mnist_lenet5_backward.MOVING_AVERAGE_DECAY)
        ema_restore = ema.variables_to_restore()
        saver = tf.train.Saver(ema_restore)

        correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))

        while True:
            with tf.Session() as sess:
                ckpt = tf.train.get_checkpoint_state(mnist_lenet5_backward.MODEL_SAVE_PATH)
                if ckpt and ckpt.model_checkpoint_path:
                    saver.restore(sess, ckpt.model_checkpoint_path)

                    global_step = ckpt.model_checkpoint_path.split('/')[-1].split('-')[-1]
                    reshaped_x = np.reshape(mnist.test.images, (
                        mnist.test.num_examples,
                        mnist_lenet5_forward.IMAGE_SIZE,
                        mnist_lenet5_forward.IMAGE_SIZE,
                        mnist_lenet5_forward.NUM_CHANNELS))
                    accuracy_score = sess.run(accuracy, feed_dict={x: reshaped_x, y_: mnist.test.labels})
                    print("After %s training step(s), test accuracy = %g" % (global_step, accuracy_score))
                else:
                    print('No checkpoint file found')
                    return

            time.sleep(TEST_INTERVAL_SECS)

def main():
    mnist = input_data.read_data_sets("./data/", one_hot=True)
    test(mnist)

if __name__ == '__main__':
    main()

```

## 4.4 mnist_lenet5_app.py

在相对路径下创建文件夹image，放入名字为`0.png`、`1.png`、...`9.png`的十张手写数字图片

```py
import tensorflow as tf
import numpy as np
from PIL import Image
import chapter7.mnist_lenet5_forward as mnist_lenet5_forward
import chapter7.mnist_lenet5_backward as mnist_lenet5_backward

def restore_model(test_pic_arr):
    with tf.Graph().as_default() as tg:
        x = tf.placeholder(tf.float32, [
            1,
            mnist_lenet5_forward.IMAGE_SIZE,
            mnist_lenet5_forward.IMAGE_SIZE,
            mnist_lenet5_forward.NUM_CHANNELS])
        y = mnist_lenet5_forward.forward(x, False, None)
        pre_value = tf.argmax(y, 1)

        variable_averages = tf.train.ExponentialMovingAverage(mnist_lenet5_backward.MOVING_AVERAGE_DECAY)
        variables_to_restore = variable_averages.variables_to_restore()
        saver = tf.train.Saver(variables_to_restore)

        with tf.Session() as sess:
            ckpt = tf.train.get_checkpoint_state(mnist_lenet5_backward.MODEL_SAVE_PATH)
            if ckpt and ckpt.model_checkpoint_path:
                saver.restore(sess, ckpt.model_checkpoint_path)

                pre_value = sess.run(pre_value, feed_dict={x: test_pic_arr})
                return pre_value
            else:
                print("No checkpoint file found")
                return -1

def pre_pic(pic_name):
    img = Image.open(pic_name)
    re_im = img.resize((28, 28), Image.ANTIALIAS)
    im_arr = np.array(re_im.convert('L'))
    threshold = 50

    for i in range(28):
        for j in range(28):
            im_arr[i][j] = 255 - im_arr[i][j]
            if im_arr[i][j] < threshold:
                im_arr[i][j] = 0
            else:
                im_arr[i][j] = 255

    nm_arr = im_arr.reshape([
        1,
        mnist_lenet5_forward.IMAGE_SIZE,
        mnist_lenet5_forward.IMAGE_SIZE,
        mnist_lenet5_forward.NUM_CHANNELS])
    nm_arr = nm_arr.astype(np.float32)
    img_ready = np.multiply(nm_arr, 1.0 / 255.0)

    return img_ready

def application():
    for i in range(0, 10):
        file_name = "./image/" + str(i) + ".png"
        test_pic_arr = pre_pic(file_name)
        pre_value = restore_model(test_pic_arr)
        print("%s : The prediction number is %d:" % (file_name, pre_value))

def main():
    application()

if __name__ == '__main__':
    main()

```

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [人工智能实践：TensorFlow笔记-曹健](https://www.icourse163.org/course/PKU-1002536002)
* [人工智能、机器学习和深度学习的区别?](https://www.zhihu.com/question/57770020)