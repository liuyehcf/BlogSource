---
title: Netty-ByteBuf
date: 2019-03-27 20:37:53
tags: 
- 原创
categories: 
- Java
- Framework
- Netty
---

__阅读更多__

<!--more-->

# 1 Netty ByteBuf

## 1.1 CompositeByteBuf

有时，我们想将多个`ByteBuf`拼接成一个`ByteBuf`，但是又不想进行拷贝操作（数据量大时有性能开销），那么`CompositeByteBuf`就是最好的解决方案。`CompositeByteBuf`封装了一组`ByteBuf`，我们可以像操作普通`ByteBuf`一样操作这一组`ByteBuf`，同时又可避免拷贝，极大地提高了效率

__注意，writeXXX不要和addComponent混用__

```java
    public static void main(String[] args) {
        CompositeByteBuf compositeByteBuf = Unpooled.compositeBuffer();

        compositeByteBuf.addComponent(true, Unpooled.wrappedBuffer("hello, ".getBytes()));
        compositeByteBuf.addComponent(true, Unpooled.wrappedBuffer("world".getBytes()));

        System.out.println(new String(ByteBufUtil.getBytes(compositeByteBuf)));
    }
```

```java
    public static void main(String[] args) {
        CompositeByteBuf compositeByteBuf = Unpooled.compositeBuffer();

        compositeByteBuf.writeBytes("hello, ".getBytes());
        compositeByteBuf.writeBytes("world".getBytes());

        System.out.println(new String(ByteBufUtil.getBytes(compositeByteBuf)));
    }
```

# 2 Java Direct Buffer

通俗来说，`Direct Buffer`就是一块在Java堆外分配的，但是可以在Java程序中访问的内存

```java
    public static void main(String[] args) {
        ByteBuffer dorectButeBiffer = ByteBuffer.allocateDirect(1024);
        ByteBuffer heapByteBuffer = ByteBuffer.allocate(1024);
    }

    public static ByteBuffer allocate(int capacity) {
        if (capacity < 0)
            throw new IllegalArgumentException();
        return new HeapByteBuffer(capacity, capacity);
    }

    public static ByteBuffer allocateDirect(int capacity) {
        return new DirectByteBuffer(capacity);
    }
```

# 3 内存泄漏

最近在实现一个自定义协议的时候用到了`ByteToMessageCodec`这个抽象类，该类由个`encode`方法需要实现，该方法的定义如下

```java
package com.github.liuyehcf.framework.io.athena.protocol.handler;

import com.github.liuyehcf.framework.io.athena.protocol.AthenaFrame;
import com.github.liuyehcf.framework.io.athena.protocol.ProtocolConstant;
import com.github.liuyehcf.framework.io.athena.util.ByteUtils;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.ByteToMessageCodec;

import java.util.List;

/**
 * @author hechenfeng
 * @date 2020/2/6
 */
public class AthenaFrameHandler extends ByteToMessageCodec<AthenaFrame> {

    @Override
    protected void encode(ChannelHandlerContext ctx, AthenaFrame msg, ByteBuf out) {
        out.writeBytes(msg.serialize());
    }

    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf in, List<Object> out) {
        while (in.readableBytes() >= ProtocolConstant.MIN_HEADER_LENGTH) {
            final int originReaderIndex = in.readerIndex();

            in.setIndex(originReaderIndex + ProtocolConstant.TOTAL_LENGTH_OFFSET, in.writerIndex());
            int totalLength = ByteUtils.toInt(in.readByte(), in.readByte());

            // reset readable index to read all frame bytes
            in.setIndex(originReaderIndex, in.writerIndex());

            if (in.readableBytes() < totalLength) {
                break;
            }

            // 重点在这里，这里通过ByteBuf.readBytes(int length)方法获取了一个新的ByteBuf
            out.add(AthenaFrame.deserialize(in.readBytes(totalLength)));
        }
    }
}
```

问题在于`in.readBytes(totalLength)`，该方法创建了一个新的`ByteBuf`，但是这个`ByteBuf`并没有被释放掉，造成了内存泄漏

__如何筛查堆外内存泄露？可以通过反射查看`PlatformDependent`类中的静态字段`DIRECT_MEMORY_COUNTER`__

# 4 参考

* [Direct Buffer](https://zhuanlan.zhihu.com/p/27625923)
