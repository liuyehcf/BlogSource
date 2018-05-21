---
title: FastJson-解析多级泛型
date: 2017-12-15 16:03:33
tags: 
- 原创
categories: 
- Java
- Framework
- FastJson
---

__阅读更多__

<!--more-->

# 1 代码清单

__OuterEntity__：第一级

* 包含泛型参数T

```Java
package org.liuyehcf.fastjson.entity;

/**
 * Created by Liuye on 2017/12/15.
 */
public class OuterEntity<T> {
    private int id;

    private String name;

    private T middleEntity;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public T getMiddleEntity() {
        return middleEntity;
    }

    public void setMiddleEntity(T middleEntity) {
        this.middleEntity = middleEntity;
    }
}
```

__MiddleEntity__：第二级

* 包含泛型参数T

```Java
package org.liuyehcf.fastjson.entity;

/**
 * Created by Liuye on 2017/12/15.
 */
public class MiddleEntity<T> {
    private int id;

    private String name;

    private T innerEntity;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public T getInnerEntity() {
        return innerEntity;
    }

    public void setInnerEntity(T innerEntity) {
        this.innerEntity = innerEntity;
    }
}
```

__InnerEntity__：第三级

```Java
package org.liuyehcf.fastjson.entity;

/**
 * Created by Liuye on 2017/12/15.
 */
public class InnerEntity {
    private int id;

    private String name;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

__测试代码__

* 将Java对象转化为Json字符串
* 将Json字符串，配合类型信息，转化为Java对象

```Java
package org.liuyehcf.fastjson;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.TypeReference;
import org.liuyehcf.fastjson.entity.InnerEntity;
import org.liuyehcf.fastjson.entity.MiddleEntity;
import org.liuyehcf.fastjson.entity.OuterEntity;

/**
 * Created by Liuye on 2017/12/15.
 */
public class FastJsonDemo {
    public static void main(String[] args) {
        // 创建多级对象
        OuterEntity<MiddleEntity<InnerEntity>> outerEntity = new OuterEntity<>();
        MiddleEntity<InnerEntity> middleEntity = new MiddleEntity<>();
        InnerEntity innerEntity = new InnerEntity();

        innerEntity.setId(1);
        innerEntity.setName("InnerEntity");

        middleEntity.setId(2);
        middleEntity.setName("middleEntity");
        middleEntity.setInnerEntity(innerEntity);

        outerEntity.setId(3);
        outerEntity.setName("outerEntity");
        outerEntity.setMiddleEntity(middleEntity);

        // 将Java对象转化为Json字符串
        String json = JSON.toJSONString(outerEntity);

        System.out.println(json);

        // 将Json字符串，配合类型信息，转化为Java对象
        OuterEntity<MiddleEntity<InnerEntity>> parsedOuterEntity = JSON.parseObject(
                json,
                new TypeReference<OuterEntity<MiddleEntity<InnerEntity>>>() {
                });

        System.out.println(parsedOuterEntity.getMiddleEntity().getClass().getName());
        System.out.println(parsedOuterEntity.getMiddleEntity().getInnerEntity().getClass().getName());

    }
}
```

输出如下

```
{"id":3,"middleEntity":{"id":2,"innerEntity":{"id":1,"name":"InnerEntity"},"name":"middleEntity"},"name":"outerEntity"}
org.liuyehcf.fastjson.entity.MiddleEntity
org.liuyehcf.fastjson.entity.InnerEntity
```

能够解析多级泛型的关键语句是：`new TypeReference<OuterEntity<MiddleEntity<InnerEntity>>>() {}`

# 2 Java如何保留编译期的泛型信息

Java中的泛型的实现方式是擦除。也就是说，所有包含不同泛型参数的类型共享着同一个.class文件，或者Class对象。很显然，这个Class对象或者.class文件中必然不会存有泛型参数的信息（已经被擦除了）

Java采用另外一种方式来存储泛型信息，对于一个类型C而言，沿着继承链路往上走，其直接父类F到根基类Object，这条链路上的所有泛型信息都是确定的（指定了或者未指定）

* C1的直接父类是`ArrayList<String>`，泛型参数为String
* C2的直接父类是`ArrayList`，泛型参数未指定，其实也就是Object

```Java
class C1 extends ArrayList<String> {
    ...
}

class C2 extends ArrayList {

}
```

由于类型的定义在编译期就已经确定了，因此Java能够通过某种机制将继承链路上的类型信息（包括指定了的泛型参数）保存下来。具体来说，Class包含如下方法，该方法可以获取直接父类的信息（Type对象），该对象包含了泛型参数等信息

```Java
public Type getGenericSuperclass()
```

## 2.1 示例代码

泛型类型MyTypeReference，将其设置为抽象类，避免实例化。在构造方法中初始化type字段，即泛型参数。其中getClass()方法具有多态性质

```Java
package org.liuyehcf.fastjson;

import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;

/**
 * Created by HCF on 2017/12/15.
 */
public abstract class MyTypeReference<T> {
    private final Type type;

    public MyTypeReference() {
        // getClass()方法多态
        Type superClass = getClass().getGenericSuperclass();

        // 强制转型成ParameterizedType，然后获取泛型参数
        Type type = ((ParameterizedType) superClass).getActualTypeArguments()[0];

        this.type = type;
    }

    public final Type getType() {
        return type;
    }
}
```

测试代码。注意大括号，即创建子类，但是不重写任何方法。输出为`java.util.List<java.util.List<java.lang.String>>`

```Java
package org.liuyehcf.fastjson;

import java.util.List;

/**
 * Created by Liuye on 2017/12/15.
 */
public class GenericTypeDemo<T> {

    public static void main(String[] args) {
        System.out.println(
                new MyTypeReference<List<List<String>>>() {
                    // override nothing
                }.getType().getTypeName());
    }
}
```
