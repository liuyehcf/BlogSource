---
title: Lombok-Overview
date: 2018-07-27 09:55:25
tags: 
- 原创
categories: 
- Java
- Framework
- Lombok
---

__阅读更多__

<!--more-->

# 1 Overview

__lombok中常用的注解__

1. `@AllArgsConstructor`
1. `@NoArgsConstructor`
1. `@RequiredArgsConstructor`
1. `@Builder`
1. `@Getter`
1. `@Setter`
1. `@Data`
1. `@ToString`
1. `@EqualsAndHashCode`
1. `@Singular`
1. `@Slf4j`

__原理：lombok注解都是`编译期`注解，`编译期`注解最大的魅力就是能够干预编译器的行为，相关技术就是`JSR-269`__。我在另一篇博客中详细介绍了`JSR-269`的相关原理以及接口的使用方式，并且实现了类似lombok的`@Builder`注解。__对原理部分感兴趣的话，请移步{% post_link Java-JSR-269-插入式注解处理器 %}__

# 2 构造方法

lombok提供了3个注解，用于创建构造方法，它们分别是

1. __`@AllArgsConstructor`__：`@AllArgsConstructor`会生成一个全量的构造方法，包括所有的字段（非final字段以及未在定义处初始化的final字段）
1. __`@NoArgsConstructor`__：`@NoArgsConstructor`会生成一个无参构造方法（当然，不允许类中含有未在定义处初始化的final字段）
1. __`@RequiredArgsConstructor`__：`@RequiredArgsConstructor`会生成一个仅包含必要参数的构造方法，什么是必要参数呢？就是那些未在定义处初始化的final字段

# 3 @Builder

__`@Builder`是我最爱的lombok注解，没有之一__。通常我们在业务代码中，时时刻刻都会用到数据传输对象（DTO），例如，我们调用一个RPC接口，需要传入一个DTO，代码通常是这样的

```java
// 首先构造DTO对象
XxxDTO xxxDTO = new XxxDTO();
xxxDTO.setPro1(...);
xxxDTO.setPro2(...);
...
xxxDTO.setPron(...);

// 然后调用接口
rpcService.doSomething(xxxDTO);
```

其实，上述代码中的`xxxDTO`对象的创建以及赋值的过程，仅与`rpcService`有关，但是从肉眼来看，这确确实实又是两部分，我们无法快速确定`xxxDTO`对象只在`rpcService.doSomething`方法中用到。显然，这个代码片段最核心的部分就是`rpcService.doSomething`方法调用，__而上面这种写法使得核心代码淹没在非核心代码中__

借助lombok的`@Builder`注解，我们便可以这样重构上面这段代码

```java
rpcService.doSomething(
    XxxDTO.builder()
        .setPro1(...)
        .setPro2(...)
        ...
        .setPron(...)
        .build()
);
```

这样一来，由于`XxxDTO`的实例仅在`rpcService.doSomething`方法中用到，我们就把创建的步骤放到方法参数里面去完成，代码更内聚了。__通过这种方式，业务流程的脉络将会更清晰地展现出来，而不至于淹没在一大堆`set`方法的调用之中__

## 3.1 使用方式

如果是一个简单的DTO，__那么直接在类上方标记`@Builder`注解，同时需要提供一个全参构造方法__，lombok就会在编译期为该类创建一个`建造者模式`的静态内部类

```java
@Builder
public class BaseCarDTO {
    private Double width;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}
```

将编译后的`.class`文件反编译得到的`.java`文件如下。可以很清楚的看到，多了一个静态内部类，且采用了建造者模式，这也是`@Builder`注解名称的由来

```java
public class BaseCarDTO {
    private Double width;
    private Double length;
    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return this.width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return this.length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return this.weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public static BaseCarDTO.BaseCarDTOBuilder builder() {
        return new BaseCarDTO.BaseCarDTOBuilder();
    }

    public static class BaseCarDTOBuilder {
        private Double width;
        private Double length;
        private Double weight;

        BaseCarDTOBuilder() {
        }

        public BaseCarDTO.BaseCarDTOBuilder width(Double width) {
            this.width = width;
            return this;
        }

        public BaseCarDTO.BaseCarDTOBuilder length(Double length) {
            this.length = length;
            return this;
        }

        public BaseCarDTO.BaseCarDTOBuilder weight(Double weight) {
            this.weight = weight;
            return this;
        }

        public BaseCarDTO build() {
            return new BaseCarDTO(this.width, this.length, this.weight);
        }

        public String toString() {
            return "BaseCarDTO.BaseCarDTOBuilder(width=" + this.width + ", length=" + this.length + ", weight=" + this.weight + ")";
        }
    }
}
```

## 3.2 具有继承关系的DTO

我们来考虑一种更特殊的情况，假设有两个DTO，一个是`TruckDTO`，另一个是`BaseCarDTO`。`TruckDTO`继承了`BaseCarDTO`。其中`BaseCarDTO`与`TruckDTO`如下

* 我们需要在`@Builder`注解指定`builderMethodName`属性，区分一下两个静态方法

```java
@Builder
public class BaseCarDTO {
    private Double width;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}

@Builder(builderMethodName = "trunkBuilder")
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double volume) {
        this.volume = volume;
    }

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

我们来看一下`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件的样子，如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double volume) {
        this.volume = volume;
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public static TrunkDTO.TrunkDTOBuilder trunkBuilder() {
        return new TrunkDTO.TrunkDTOBuilder();
    }

    public static class TrunkDTOBuilder {
        private Double volume;

        TrunkDTOBuilder() {
        }

        public TrunkDTO.TrunkDTOBuilder volume(Double volume) {
            this.volume = volume;
            return this;
        }

        public TrunkDTO build() {
            return new TrunkDTO(this.volume);
        }

        public String toString() {
            return "TrunkDTO.TrunkDTOBuilder(volume=" + this.volume + ")";
        }
    }
}
```

可以看到，这个内部类`TrunkDTOBuilder`仅包含了子类`TrunkDTO`的字段，而不包含父类`BaseCarDTO`的字段

那么，我们如何让`TrunkDTOBuilder`也包含父类的字段呢？答案就是，我们需要将`@Builder`注解标记在构造方法处，构造方法包含多少字段，那么这个静态内部类就包含多少个字段，如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    @Builder(builderMethodName = "trunkBuilder")
    public TrunkDTO(Double width, Double length, Double weight, Double volume) {
        super(width, length, weight);
        this.volume = volume;
    }

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

上述`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO(Double width, Double length, Double weight, Double volume) {
        super(width, length, weight);
        this.volume = volume;
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public static TrunkDTO.TrunkDTOBuilder trunkBuilder() {
        return new TrunkDTO.TrunkDTOBuilder();
    }

    public static class TrunkDTOBuilder {
        private Double width;
        private Double length;
        private Double weight;
        private Double volume;

        TrunkDTOBuilder() {
        }

        public TrunkDTO.TrunkDTOBuilder width(Double width) {
            this.width = width;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder length(Double length) {
            this.length = length;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder weight(Double weight) {
            this.weight = weight;
            return this;
        }

        public TrunkDTO.TrunkDTOBuilder volume(Double volume) {
            this.volume = volume;
            return this;
        }

        public TrunkDTO build() {
            return new TrunkDTO(this.width, this.length, this.weight, this.volume);
        }

        public String toString() {
            return "TrunkDTO.TrunkDTOBuilder(width=" + this.width + ", length=" + this.length + ", weight=" + this.weight + ", volume=" + this.volume + ")";
        }
    }
}
```

## 3.3 初始值

仅靠`@Builder`注解，那么生成的静态内部类是不会处理初始值的，如果我们要让静态内部类处理初始值，那么就需要在相关的字段上标记`@Builder.Default`注解

```java
@Builder
public class BaseCarDTO {
    @Builder.Default
    private Double width = 5.0;

    private Double length;

    private Double weight;

    public BaseCarDTO() {
    }

    public BaseCarDTO(Double width, Double length, Double weight) {
        this.width = width;
        this.length = length;
        this.weight = weight;
    }

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}
```

__注意，字段在被`@Builder.Default`修饰后，生成class文件中是没有初始值的，这是个大坑！__

## 3.4 @EqualsAndHashCode

`@EqualsAndHashCode`注解用于创建Object的`hashCode`方法以及`equals`方法，同样地，如果一个DTO包含父类，那么最平凡的`@EqualsAndHashCode`注解不会考虑父类包含的字段。__因此如果子类的`hashCode`方法以及`equals`方法需要考虑父类的字段，那么需要将`@EqualsAndHashCode`注解的`callSuper`属性设置为true，这样就会调用父类的同名方法__

```java
public class BaseCarDTO {

    private Double width = 5.0;

    private Double length;

    private Double weight;

    public Double getWidth() {
        return width;
    }

    public void setWidth(Double width) {
        this.width = width;
    }

    public Double getLength() {
        return length;
    }

    public void setLength(Double length) {
        this.length = length;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }
}

@EqualsAndHashCode(callSuper = true)
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public Double getVolume() {
        return volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }
}
```

上述`TrunkDTO`编译得到的`.class`文件经过反编译得到的`.java`文件如下

```java
public class TrunkDTO extends BaseCarDTO {
    private Double volume;

    public TrunkDTO() {
    }

    public Double getVolume() {
        return this.volume;
    }

    public void setVolume(Double volume) {
        this.volume = volume;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        } else if (!(o instanceof TrunkDTO)) {
            return false;
        } else {
            TrunkDTO other = (TrunkDTO)o;
            if (!other.canEqual(this)) {
                return false;
            } else if (!super.equals(o)) {
                return false;
            } else {
                Object this$volume = this.getVolume();
                Object other$volume = other.getVolume();
                if (this$volume == null) {
                    if (other$volume != null) {
                        return false;
                    }
                } else if (!this$volume.equals(other$volume)) {
                    return false;
                }

                return true;
            }
        }
    }

    protected boolean canEqual(Object other) {
        return other instanceof TrunkDTO;
    }

    public int hashCode() {
        int PRIME = true;
        int result = 1;
        int result = result * 59 + super.hashCode();
        Object $volume = this.getVolume();
        result = result * 59 + ($volume == null ? 43 : $volume.hashCode());
        return result;
    }
}
```

# 4 @Getter/@Setter

`@Getter`以及`@Setter`注解用于为字段创建getter方法以及setter方法

# 5 @ToString

`@ToString`注解用于创建Object的`toString`方法

# 6 @Data

`Data`注解包含了`@Getter`、`@Setter`、`@RequiredArgsConstructor`、`@ToString`以及`@EqualsAndHashCode`、的功能

# 7 @Slf4j

`@Slf4j`注解用于生成一个`log`字段，可以指定参数`topic`的值，其值代表`loggerName`

`@Slf4j(topic = "error")`等效于下面这段代码

```java
  private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger("error");
```
