---
title: Java-泛型
date: 2018-02-01 20:59:51
tags: 
- 原创
categories: 
- Java
- Generic
---

__阅读更多__

<!--more-->

# 1 Type接口

众所周知，JDK 1.5之后引入了泛型。Java中的泛型与C++中的泛型（说模板更确切）实现方式完全不同。C++中的泛型利用的是__模板技术__，在预处理期将为每个不同的__泛型实参__生成一份源码。而Java中的泛型利用的是__擦除技术__，在将源文件`.java`编译成字节码文件`.class`的时候，将所有泛型形参都替换成了Object，称之为擦除，因此，__不同的泛型实参对应的是同一份字节码__

Java泛型新增了一个Type接口，__我们熟知的Class类实现了该接口__。因此Type接口是整个类型体系的顶层

```
Type 
|
├── GenericArrayType
├── ParameterizedType
├── TypeVariable
├── WildcardType
├── Class
```

下面介绍一下Type接口的几个重要的实现以及子接口

## 1.1 Class类

Class是Type接口的实现，是运行时获取类型信息的入口

## 1.2 ParameterizedType接口

ParameterizedType接口实现了Type接口，增加了如下方法

1. getActualTypeArguments：用于获取__泛型实参__列表，例如`AbstractMap.SimpleEntry<String, List>`返回的就是`String`和`List`
1. getRawType：用于获取类型本身，例如`AbstractMap.SimpleEntry<String, List>`返回的就是`AbstractMap.SimpleEntry`
1. getOwnerType：用于获取所有者类型，例如`AbstractMap.SimpleEntry<String, List>`返回的就是`AbstractMap`

```java
    Type[] getActualTypeArguments();
    Type getRawType();
    Type getOwnerType();
```

ParameterizedType是如何保留泛型实参的呢？答案就是：我们可以将泛型实参保留在一条继承链路中，举个例子

```java
import java.util.HashMap;
import java.util.List;

public class TypeHolder extends HashMap.SimpleEntry<String, List> {

    public TypeHolder(String key, List value) {
        super(key, value);
    }
}
```

这个`TypeHolder`类继承了`HashMap.SimpleEntry<String, List>`，__这个父类的类型信息（HashMap.SimpleEntry以及泛型实参String、List）在`编译期`就可以完全确定了，Java将它的父类的类型信息封装成`ParameterizedType`，保留在字节码文件中__

那么，我们如何能够获取到这个类型信息呢？我们可以通过`Class.getGenericSuperclass`获取到`ParameterizedType`

1. 如果一个类的__父类不是泛型__，那么`Class.getGenericSuperclass`返回的就是一个Class
1. 如果一个类的__父类是泛型__，那么`Class.getGenericSuperclass`返回的就是`ParameterizedType`

下面以一个例子来说明：

```java
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.List;

public class TypeHolder extends HashMap.SimpleEntry<String, List> {

    public TypeHolder(String key, List value) {
        super(key, value);
    }

    public static void main(String[] args) {
        Class clazz = TypeHolder.class;

        Type type = clazz.getGenericSuperclass();

        if (type instanceof ParameterizedType) {
            ParameterizedType parameterizedType = (ParameterizedType) type;

            System.out.println("ParameterizedType: " + parameterizedType);

            for (Type actualTypeArgument : parameterizedType.getActualTypeArguments()) {
                System.out.println("ActualTypeArgument: " + actualTypeArgument);
            }

            System.out.println("RawType: " + parameterizedType.getRawType());

            System.out.println("OwnerType: " + parameterizedType.getOwnerType());
        }
    }
}
```

输出

```
ParameterizedType: java.util.AbstractMap.java.util.AbstractMap$SimpleEntry<java.lang.String, java.util.List>
ActualTypeArgument: class java.lang.String
ActualTypeArgument: interface java.util.List
RawType: class java.util.AbstractMap$SimpleEntry
OwnerType: class java.util.AbstractMap
```

## 1.3 TypeVariable接口

TypeVariable接口实现了Type接口，TypeVariable接口__主要用于封装泛型形参__。增加了如下方法

1. getBounds：用于获取泛型边界
1. getGenericDeclaration：用于获取泛型声明
1. getName：用于获取泛型形参名字。例如List<T>中的T
1. getAnnotatedBounds：返回一个AnnotatedType对象数组，表示使用类型来表示由此TypeVariable表示的类型参数的上限。数组中对象的顺序对应于类型参数声明中边界的顺序

```java
    Type[] getBounds();

    D getGenericDeclaration();

    String getName();

    AnnotatedType[] getAnnotatedBounds();
```

下面以一个例子来说明：

```java
public class GenericType<T extends ArrayList> {

    public static void main(String[] args) {
        Class clazz = GenericType.class;

        TypeVariable[] typeVariables = clazz.getTypeParameters();

        for (TypeVariable typeVariable : typeVariables) {

            System.out.println(Arrays.toString(typeVariable.getBounds()));

            System.out.println(typeVariable.getGenericDeclaration());

            System.out.println(typeVariable.getName());

            System.out.println(Arrays.toString(typeVariable.getAnnotatedBounds()));
        }
    }
}
```

输出如下

```
[class java.util.ArrayList]
class GenericType
T
[sun.reflect.annotation.AnnotatedTypeFactory$AnnotatedTypeBaseImpl@5e2de80c]
```

# 2 手撸JavaBeanInitializer

## 2.1 需求

在业务代码中会定义许多的DTO，这些DTO有些非常庞大，嵌套层级非常多，这时候写测试代码将会非常讨厌，我们必须先new一个DTO，然后用set方法一个个去填充值，动辄就30多行，十分臃肿

那么，__如果对DTO填充的内容并不关心的话__，我们可以用一个工具类`JavaBeanInitializerUtils`来帮助我们自动填充这个DTO，它有如下特点

1. 支持泛型以及泛型嵌套
1. 对常用的容器类型，例如List、Map进行自动填充

## 2.2 实现思路

为了支持泛型，我们必须解决以下问题

1. 如果我们要初始化这样一个类`DataDTO<UserDTO>`，我们如何保留其泛型实参`UserDTO`，显然，通过DataDTO.class是无法得到的
1. 对于`setXXX(T data)`这样一个含有泛型形参的方法，其中T是泛型形参，我们如何传入一个泛型实参的实例

__上一小节介绍过ParameterizedType可以将泛型实参保留在继承链路中。因此，对于第一个问题，我们通过如下方式来解决：__

1. TypeReference是一个抽象类，避免实例化本类
1. TypeReference包含一个type字段，用于保留父类的类型信息

```java
    public abstract class TypeReference<T> {
        private final Type type;

        protected TypeReference() {
            Type superClass = getClass().getGenericSuperclass(); //(1)

            Type type = ((ParameterizedType) superClass).getActualTypeArguments()[0]; //(2)

            this.type = type;
        }

        public final Type getType() {
            return type;
        }
    }
```

TypeReference的使用方式如下：

* 注意这个大括号`{}`。这个语句的意思是，__创建一个TypeReference的匿名内部类__
* 在创建对象时，`(1)`中`getClass()`获取到的是这个匿名内部类的Class对象，通过getGenericSuperclass方法得到的就是`TypeReference<DataDTO<UserDTO>>`，然后通过`(2)`得到泛型实参`DataDTO<UserDTO>`。__因此类型信息通过继承链路保留了下来，这是一个比较tricky的地方__

```java
    public static void main(String[] args) {
        TypeReference<DataDTO<UserDTO>> typeReference = new TypeReference<DataDTO<UserDTO>>() {
        };
        System.out.println(typeReference.getType());
    }
```

输出如下

```
DataDTO<UserDTO>
```

__对于第二个问题，我们可以建立一个Map<String, Type>，从泛型形参映射到泛型实参，这样每当遇到setXXX(T data)这样含有泛型形参的方法时，我们通过这个Map字典查询到泛型实参__

## 2.3 代码清单

下面就是JavaBeanInitializerUtils的实现代码，注释写的比较充分，就不再赘述了

```java
package org.liuyehcf.reflect;

import java.lang.reflect.*;
import java.util.*;

public class JavaBeanInitializerUtils {
    private static final Byte BYTE_DEFAULT_VALUE = 1;
    private static final Character CHAR_DEFAULT_VALUE = 'a';
    private static final Short SHORT_DEFAULT_VALUE = 2;
    private static final Integer INTEGER_DEFAULT_VALUE = 3;
    private static final Long LONG_DEFAULT_VALUE = 6L;
    private static final Float FLOAT_DEFAULT_VALUE = 1.0F;
    private static final Double DOUBLE_DEFAULT_VALUE = 2.0D;
    private static final String STRING_DEFAULT_VALUE = "default";

    private static final Map<Class, Object> DEFAULT_VALUE_OF_BASIC_CLASS = new HashMap<>();

    private static final String SET_METHOD_PREFIX = "set";
    private static final Integer SET_METHOD_PARAM_COUNT = 1;
    private static final Class SET_METHOD_RETURN_TYPE = void.class;

    private static final Set<Class> CONTAINER_CLASS_SET = new HashSet<>();
    private static final Integer CONTAINER_DEFAULT_SIZE = 3;

    static {
        DEFAULT_VALUE_OF_BASIC_CLASS.put(Byte.class, BYTE_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(byte.class, BYTE_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Character.class, CHAR_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(char.class, CHAR_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Short.class, SHORT_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(short.class, SHORT_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Integer.class, INTEGER_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(int.class, INTEGER_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Long.class, LONG_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(long.class, LONG_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Float.class, FLOAT_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(float.class, FLOAT_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Double.class, DOUBLE_DEFAULT_VALUE);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(double.class, DOUBLE_DEFAULT_VALUE);

        DEFAULT_VALUE_OF_BASIC_CLASS.put(Boolean.class, false);
        DEFAULT_VALUE_OF_BASIC_CLASS.put(boolean.class, false);
    }

    static {
        CONTAINER_CLASS_SET.add(List.class);
        CONTAINER_CLASS_SET.add(Map.class);
        CONTAINER_CLASS_SET.add(Set.class);
        CONTAINER_CLASS_SET.add(Queue.class);
    }

    /**
     * 要初始化的类型
     */
    private final Type type;
    /**
     * 从泛型参数名映射到实际的类型
     */
    private Map<String, Type> genericTypes;

    private JavaBeanInitializerUtils(Type type, Map<String, Type> superClassGenericTypes) {
        this.type = type;
        genericTypes = new HashMap<>();
        init(superClassGenericTypes);
    }

    /**
     * 唯一对外接口
     */
    @SuppressWarnings("unchecked")
    public static <T> T createJavaBean(TypeReference<T> typeReference) {
        if (typeReference == null) {
            throw new NullPointerException();
        }
        return (T) createJavaBean(typeReference.getType(), null, null);
    }

    /**
     * 初始化JavaBean
     */
    private static Object createJavaBean(Type type, Map<String, Type> superClassGenericTypes, Type superType) {
        if (type == null) {
            throw new NullPointerException();
        }
        // 如果一个DTO嵌套了自己，避免死循环
        if (type.equals(superType)) {
            return null;
        }
        return new JavaBeanInitializerUtils(type, superClassGenericTypes)
                .doCreateJavaBean();
    }

    /**
     * 对于泛型类型，初始化泛型参数描述与实际泛型参数的映射关系
     * 例如List有一个泛型参数T，如果传入的是List<String>类型，那么建立 "T"->java.lang.String 的映射
     */
    private void init(Map<String, Type> superClassGenericTypes) {
        if (type instanceof ParameterizedType) {
            ParameterizedType parameterizedType = (ParameterizedType) type;

            Class clazz = (Class) parameterizedType.getRawType();

            // 通过Class可以拿到泛型形参，但无法拿到泛型实参
            TypeVariable[] typeVariables = clazz.getTypeParameters();

            // 通过ParameterizedType可以拿到泛型实参，通过继承结构保留泛型实参
            Type[] actualTypeArguments = parameterizedType.getActualTypeArguments();
            for (int i = 0; i < actualTypeArguments.length; i++) {
                Type actualTypeArgument = actualTypeArguments[i];
                if (actualTypeArgument instanceof TypeVariable) {
                    if (superClassGenericTypes == null
                            || (actualTypeArgument = superClassGenericTypes.get(getNameOfTypeVariable(actualTypeArgument))) == null) {
                        throw new RuntimeException();
                    }
                    actualTypeArguments[i] = actualTypeArgument;
                }
            }

            // 维护泛型形参到泛型实参的映射关系
            for (int i = 0; i < typeVariables.length; i++) {
                genericTypes.put(
                        // 这里需要拼接一下，使得泛型形参有一个命名空间的保护，否则泛型形参可能会出现覆盖的情况
                        getNameOfTypeVariable(typeVariables[i]),
                        actualTypeArguments[i]
                );
            }
        }
    }

    private String getNameOfTypeVariable(Type typeVariable) {
        return ((TypeVariable) typeVariable).getName();
    }

    /**
     * 创建JavaBean，根据type的实际类型进行分发
     */
    private Object doCreateJavaBean() {
        if (type instanceof Class) {
            // 创建非泛型实例
            return createJavaBeanWithClass((Class) type);
        } else if (type instanceof ParameterizedType) {
            // 创建泛型实例
            return createJavaBeanWithGenericType((ParameterizedType) type);
        } else {
            throw new UnsupportedOperationException("暂不支持此类型的默认初始化，type: " + type);
        }
    }

    /**
     * 通过普通的Class创建JavaBean
     */
    private Object createJavaBeanWithClass(Class clazz) {

        if (DEFAULT_VALUE_OF_BASIC_CLASS.containsKey(clazz)) {
            return DEFAULT_VALUE_OF_BASIC_CLASS.get(clazz);
        } else if (String.class.equals(clazz)) {
            return STRING_DEFAULT_VALUE;
        }

        Object obj = createInstance(clazz);

        for (Method setMethod : getSetMethods(clazz)) {

            // 拿到set方法的参数类型
            Type paramType = setMethod.getGenericParameterTypes()[0];

            // 填充默认值
            setDefaultValue(obj, setMethod, paramType);
        }

        return obj;
    }

    /**
     * 通过带有泛型实参的ParameterizedType创建JavaBean
     */
    private Object createJavaBeanWithGenericType(ParameterizedType type) {

        Class clazz = (Class) type.getRawType();

        Object obj = createInstance(clazz);

        for (Method setMethod : getSetMethods(clazz)) {
            // 拿到set方法的参数类型
            Type paramType = setMethod.getGenericParameterTypes()[0];

            if (paramType instanceof TypeVariable) {
                // 如果参数类型是泛型形参，根据映射关系找到泛型形参对应的泛型实参
                Type actualType = genericTypes.get(getNameOfTypeVariable(paramType));
                setDefaultValue(obj, setMethod, actualType);
            } else {
                // 参数类型是确切的类型，可能是Class，也可能是ParameterizedType
                setDefaultValue(obj, setMethod, paramType);
            }
        }

        return obj;
    }

    /**
     * 通过反射创建实例
     */
    private Object createInstance(Class clazz) {
        Object obj;
        try {
            obj = clazz.newInstance();
        } catch (IllegalAccessException | InstantiationException e) {
            throw new RuntimeException("不能实例化接口/抽象类/没有无参构造方法的类");
        }
        return obj;
    }

    /**
     * 返回所有set方法
     */
    private List<Method> getSetMethods(Class clazz) {
        List<Method> setMethods = new ArrayList<>();
        Method[] methods = clazz.getMethods();

        for (Method method : methods) {
            if (method.getName().startsWith(SET_METHOD_PREFIX)
                    && SET_METHOD_PARAM_COUNT.equals(method.getParameterCount())
                    && SET_METHOD_RETURN_TYPE.equals(method.getReturnType())) {
                setMethods.add(method);
            }
        }
        return setMethods;
    }

    /**
     * 为属性设置默认值，根据参数类型进行分发
     */
    private void setDefaultValue(Object obj, Method method, Type paramType) {
        try {
            if (paramType instanceof Class) {
                // 普通参数
                setDefaultValueOfNormal(obj, method, (Class) paramType);
            } else if (paramType instanceof ParameterizedType) {
                // 泛型实参
                setDefaultValueOfGeneric(obj, method, (ParameterizedType) paramType);
            } else {
                throw new UnsupportedOperationException();
            }
        } catch (IllegalAccessException | InvocationTargetException e) {
            throw new RuntimeException();
        }
    }

    /**
     * 获取属性名
     */
    private String getFieldName(Method method) {
        return method.getName().substring(3);
    }

    /**
     * set方法参数是普通的类型
     */
    private void setDefaultValueOfNormal(Object obj, Method method, Class paramClass) throws IllegalAccessException, InvocationTargetException {
        if (DEFAULT_VALUE_OF_BASIC_CLASS.containsKey(paramClass)) {
            // 填充基本类型
            method.invoke(obj, DEFAULT_VALUE_OF_BASIC_CLASS.get(paramClass));
        } else if (String.class.equals(paramClass)) {
            // 填充String类型
            method.invoke(obj, STRING_DEFAULT_VALUE + getFieldName(method));
        } else {
            // 填充其他类型
            method.invoke(obj, createJavaBean(paramClass, genericTypes, type));
        }
    }

    /**
     * set方法的参数是泛型
     */
    private void setDefaultValueOfGeneric(Object obj, Method method, ParameterizedType paramType) throws IllegalAccessException, InvocationTargetException {
        Class clazz = (Class) paramType.getRawType();

        if (instanceOfContainer(clazz)) {
            // 如果是容器的话，特殊处理一下
            setDefaultValueForContainer(obj, method, paramType);
        } else {
            // 其他类型
            method.invoke(obj, createJavaBean(paramType, genericTypes, type));
        }
    }

    /**
     * 判断是否是容器类型
     */
    private boolean instanceOfContainer(Class clazz) {
        return CONTAINER_CLASS_SET.contains(clazz);
    }

    /**
     * 为几种不同的容器设置默认值，由于容器没有set方法，走默认逻辑就会得到一个空的容器。因此为容器填充一个值
     */
    @SuppressWarnings("unchecked")
    private void setDefaultValueForContainer(Object obj, Method method, ParameterizedType paramType) throws IllegalAccessException, InvocationTargetException {
        Class clazz = (Class) paramType.getRawType();

        if (List.class.equals(clazz)) {
            List list = new ArrayList();

            Type genericParam = paramType.getActualTypeArguments()[0];

            for (int i = 0; i < CONTAINER_DEFAULT_SIZE; i++) {
                list.add(createJavaBeanWithTypeVariable(genericParam));
            }

            method.invoke(obj, list);
        } else if (Set.class.equals(clazz)) {
            Set set = new HashSet();

            Type genericParam = paramType.getActualTypeArguments()[0];

            for (int i = 0; i < CONTAINER_DEFAULT_SIZE; i++) {
                set.add(createJavaBeanWithTypeVariable(genericParam));
            }

            method.invoke(obj, set);
        } else if (Queue.class.equals(clazz)) {
            Queue queue = new LinkedList();

            Type genericParam = paramType.getActualTypeArguments()[0];

            for (int i = 0; i < CONTAINER_DEFAULT_SIZE; i++) {
                queue.add(createJavaBeanWithTypeVariable(genericParam));
            }

            method.invoke(obj, queue);
        } else if (Map.class.equals(clazz)) {
            Map map = new HashMap();

            Type genericParam1 = paramType.getActualTypeArguments()[0];
            Type genericParam2 = paramType.getActualTypeArguments()[1];

            Object key;
            Object value;

            for (int i = 0; i < CONTAINER_DEFAULT_SIZE; i++) {
                key = createJavaBeanWithTypeVariable(genericParam1);
                value = createJavaBeanWithTypeVariable(genericParam2);

                map.put(key, value);
            }

            method.invoke(obj, map);
        } else {
            throw new UnsupportedOperationException();
        }
    }

    private Object createJavaBeanWithTypeVariable(Type type) {
        if (type instanceof TypeVariable) {
            return createJavaBean(genericTypes.get(getNameOfTypeVariable(type)), genericTypes, this.type);
        } else {
            return createJavaBean(type, genericTypes, this.type);
        }
    }

    public static abstract class TypeReference<T> {
        private final Type type;

        protected TypeReference() {
            Type superClass = getClass().getGenericSuperclass();

            Type type = ((ParameterizedType) superClass).getActualTypeArguments()[0];

            this.type = type;
        }

        public final Type getType() {
            return type;
        }
    }
}
```

## 2.4 测试

### 2.4.1 DTO定义

__首先定义几个DTO__

AddressDTO

```java
package org.liuyehcf.reflect.dto;

public class AddressDTO {
    private String country;
    private String province;
    private String city;

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getProvince() {
        return province;
    }

    public void setProvince(String province) {
        this.province = province;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }
}
```

GenericDTO

```java
package org.liuyehcf.reflect.dto;

public class GenericDTO<Data, Value> {
    private Data data;
    private Value value;

    public Data getData() {
        return data;
    }

    public void setData(Data data) {
        this.data = data;
    }

    public Value getValue() {
        return value;
    }

    public void setValue(Value value) {
        this.value = value;
    }
}
```

UserDTO

```java
package org.liuyehcf.reflect.dto;

import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;

public class UserDTO<Data> {
    private String name;
    private Integer age;
    private Map<String, Data> map;
    private List<Data> list;
    private Set<Data> set;
    private Queue<Data> queue;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public Map<String, Data> getMap() {
        return map;
    }

    public void setMap(Map<String, Data> map) {
        this.map = map;
    }

    public List<Data> getList() {
        return list;
    }

    public void setList(List<Data> list) {
        this.list = list;
    }

    public Set<Data> getSet() {
        return set;
    }

    public void setSet(Set<Data> set) {
        this.set = set;
    }

    public Queue<Data> getQueue() {
        return queue;
    }

    public void setQueue(Queue<Data> queue) {
        this.queue = queue;
    }
}
```

### 2.4.2 测试代码

```java
package org.liuyehcf.reflect;

import com.alibaba.fastjson.JSON;
import org.junit.Test;
import org.liuyehcf.reflect.dto.AddressDTO;
import org.liuyehcf.reflect.dto.GenericDTO;
import org.liuyehcf.reflect.dto.UserDTO;

public class TestJavaBeanBuilder {
    @Test
    public void testGeneric1() {
        System.out.println(JSON.toJSONString(JavaBeanInitializerUtils.createJavaBean(
                new JavaBeanInitializerUtils.TypeReference<UserDTO<GenericDTO<UserDTO<AddressDTO>, AddressDTO>>>() {
                }
        )));
    }

    @Test
    public void testGeneric2() {
        System.out.println(JSON.toJSONString(JavaBeanInitializerUtils.createJavaBean(
                new JavaBeanInitializerUtils.TypeReference<GenericDTO<GenericDTO<UserDTO<AddressDTO>, AddressDTO>, GenericDTO<UserDTO<GenericDTO<UserDTO<AddressDTO>, AddressDTO>>, AddressDTO>>>() {
                }
        )));
    }
}
```

输出结果太大了，这里就不放了
