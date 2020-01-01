---
title: MyBatis-映射器
date: 2018-01-23 18:52:55
tags: 
- 摘录
categories: 
- Java
- Framework
- MyBatis
---

__阅读更多__

<!--more-->

# 1 映射器主要元素

Java映射器（即Mapper），由两个元素组成

1. Java接口
1. XML配置文件（或注解）

映射器XML配置文件主要元素如下：

| 元素名称 | 描述 | 备注 |
|:--|:--|:--|
| select | 查询语句、最常用、最复杂的元素 | 可自定义参数、返回结果集 |
| insert | 插入语句 | 执行后返回一个整数，代表插入的行数 |
| update | 更新语句 | 执行后返回一个整数，代表更新的条数 |
| delete | 删除语句 | 执行后返回一个整数，代表删除的条数 |
| parameterMap | 定义参数映射关系 | 即将被删除的元素，不建议使用 |
| sql | 允许定义一部分SQL，然后在各个地方引用 | 例如，一张表列名，我们可以一次定义，在多个SQL语句中引用 |
| resultMap | 用来描述从数据库结果集中来加载对象，它是最复杂、最强大的元素 | 提供映射规则 |
| cache | 给定命名空间的缓存配置 | \ |
| cache-ref | 其他命名空间缓存配置的引用 | \ |

# 2 select元素

| 元素 | 说明 | 备注 |
|:--|:--|:--|
| __id__ | 它和__Mapper的命名空间__组合起来是唯一的，提供给MyBatis调用 | 如果命名空间和id组合起来不唯一，MyBatis将抛出异常 |
| __parameterType__ | 你可以给出类的全命名，也可以给出类的别名，__但使用别名必须是MyBatis内部定义或者自定义的__ | 我们可以选择JavaBean、Map等复杂的参数类型传递给SQL |
| parameterMap | 即将废弃的元素，不做讨论 | \ |
| __resultType__ | __定义类的全路径，在允许自动匹配的情况下，结果集将通过JavaBean的规范映射；或定义为int、double、float等基本类型；也可以使用别名，但是要符合别名规范，不能喝resultMap同时使用__ | 它是我们常用的参数之一，比如我们统计总条数就可以把它设置为int |
| __resultMap__ | 它是映射集的引用，执行强大的映射功能，我们可以使用resultType或者resultMap其中的一个，__resultMap可以给予我们自定义映射规则的机会__ | __它是MyBatis最复杂的元素，可以配置映射规则、级联、typeHandler等__ |
| flushCache | 它的作用是在调用SQL后，是否要求MyBatis清空之前查询的本地缓存和二级缓存 | 取值为布尔值，默认false |
| useCache | 启动二级缓存的开关，是否要求MyBatis将此次结果缓存 | 取值为布尔值，默认true |
| timeout | 设置超时参数，等超时的时候将抛出异常，单位为秒 | 默认值是数据库厂商提供的JDBC驱动所设置的秒数 |
| fetchSize | 获取记录的总条数设定 | 默认值是数据库厂商提供的JDBC驱动所设置的条数 |
| statementType | 告诉MyBatis使用哪个JDBC的Statement工作，取值为STATEMENT（Statement）、PREPARED（PreparedStatement）、CallableStatement | 默认值为PREPARED |
| resultSetType | 这是对JDBC的resultSet接口而言，它的值包括`FORWARD_ONLY`（游标允许向前访问）、`SCROLL_SENSITIVE`(双向滚动，但不及时更新，就是如果数据库里的数据修改过，并不在resultSet中反映出来）、`SCROLL_INSENSITIVE`（双向滚动，并及时跟踪数据库的更新，以便更改resultSet中的数据) | 默认值是数据库厂商提供的JDBC驱动所设置的 |
| databaseId | 数据库标识 | 提供多种数据库的支持 |
| resultOrdered | 这个设置仅适用于嵌套结果集select语句。如果为true，就是假设包含了嵌套结果或者是分组了。当返回一个主结果行的时候，就不能对前面结果集的引用。这就确保了在获取嵌套的结果集的时候不至于导致内存不够用 | 取值为布尔值，true/false，默认值为false |
| resultSets | 适合于多个结果集的情况，它将列出执行SQL后每个结果集的名称，每个名称之间用逗号分隔 | 很少使用 |

## 2.1 自动映射

__有这样一个参数`autoMappingBehavior`，当它不设置为NONE的时候，MyBatis会提供自动映射功能：只要返回的`SQL列名`和`JavaBean属性`一致，MyBatis就会帮助我们回填这些字段而无需任何配置__

在实际的情况中，大部分的数据库规范都是要求每个单词用下划线分隔，而Java则是用驼峰命名法来命名，于是__使用列的别名（`AS`）__就可以使得MyBatis自动映射，__或者直接在配置文件中开启驼峰命名方式__

自动映射可以在settings元素中配置autoMappingBehavior属性值来设置其策略。它包含3个值

1. `NONE`：取消自动映射
1. `PARTIAL`：只会自动映射，没有定义嵌套结果集映射的结果集
1. `FULL`：会自动映射任意复杂的结果集（无论是否嵌套）
* 默认值为PARTIAL，所以在默认情况下，可以做到当前对象的映射，使用FULL是嵌套映射，在性能上会下降

## 2.2 传递多个参数

### 2.2.1 Map接口

我们可以使用MyBatis提供的__Map接口__作为参数来实现它，这种方法的弊端是：Map需要键值对应，由于业务关联性不强，需要深入到程序中看代码，造成可读性下降

```xml
<select id="findRoleByaMap" parameterType="map" resultMap="roleMap">
    select id, role_name, note from t_role
    where role_name like concat('%', #{roleName}, '%')
    and note like concat('%', #{note}, '%')
</select>
```

```Java
public List<Role> findRoleByMap(Map<String, String> params);
```

### 2.2.2 @Param注解

我们也可以使用MyBatis提供的参数注解__@Param(org.apache.ibatis.annotations.Param)__来实现想要的功能。但如果参数多于5个，那么@Param注解也会造成可读性的下降

```xml
<select id="findRoleByAnnotation" resultMap="roleMap">
    select id, role_name, note from t_role
    where role_name like concat('%', #{roleName}, '%')
    and note like concat('%', #{note}, '%')
</select>
```

```Java
public List<Role> findRoleByAnnotation(@Param("roleName") String roleName, @Param("note") String note);
```

### 2.2.3 JavaBean

此外，我们还可以通过__JavaBean__来传递参数。MyBatis允许组织一个JavaBean，通过简单的setter和getter方法设置参数，就可以提高我们的可读性

```xml
<select id="findRoleByParams" parameterType="com.learn.params.RoleParam" resultMap="roleMap">
    select id, role_name, note from t_role
    where role_name like concat('%', #{roleName}, '%')
    and note like concat('%', #{note}, '%')
</select>
```

```Java
public List<Role> findRoleByParams(RoleParam params);
```

```Java
package com.learn.params;

public class RoleParam {
    private String roleName;
    private String note;

    public String getRoleName() {
        return roleName;
    }

    public void setRoleName(String roleName) {
        this.roleName = roleName;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
```

### 2.2.4 建议

__当参数少于5个，用@Param注解__

__当参数多于5个，用JavaBean__

# 3 insert元素

MyBatis会在执行插入之后返回一个整数，以表示你进行操作后插入的记录数

| 元素 | 说明 | 备注 |
|:--|:--|:--|
| __id__ | 它和__Mapper的命名空间__组合起来是唯一的，提供给MyBatis调用 | 如果命名空间和id组合起来不唯一，MyBatis将抛出异常 |
| __parameterType__ | 你可以给出类的全命名，也可以给出类的别名，__但使用别名必须是MyBatis内部定义或者自定义的__ | 我们可以选择JavaBean、Map等复杂的参数类型传递给SQL |
| parameterMap | 即将废弃的元素，不做讨论 | \ |
| flushCache | 它的作用是在调用SQL后，是否要求MyBatis清空之前查询的本地缓存和二级缓存 | 取值为布尔值，默认false |
| timeout | 设置超时参数，等超时的时候将抛出异常，单位为秒 | 默认值是数据库厂商提供的JDBC驱动所设置的秒数 |
| statementType | 告诉MyBatis使用哪个JDBC的Statement工作，取值为STATEMENT（Statement）、PREPARED（PreparedStatement）、CallableStatement | 默认值为PREPARED |
| __keyProperty__ | __表示以哪个列作为属性的主键__。不能和keyColumn同时使用 | 设置哪个列为主键，__如果你是联合主键可以用逗号将其隔开__ |
| __useGeneratedKeys__ | __这会令MyBatis使用JDBC的getGeneratedKeys方法来取出由数据库内部生成的主键__。例如，MySQL和SQL Server自动递增字段，Oracle的序列等，但是使用它就必须要给keyProperty或keyColumn赋值 | 取值为布尔值，默认值为false |
| keyColumn | 指明第几列是主键，不能和keyProperty同时使用，只接受整型参数 | 和keyProperty一样，联合主键可以用逗号隔开 |
| databaseId | 数据库标识 | 提供多种数据库的支持 |

## 3.1 主键回填和自定义

有时候，在插入一条数据之后，我们往往需要获得这个主键，以便于未来的操作，而MyBatis提供了实现的方法

__我们可以使用keyProperty属性（注意：keyProperty属性填的值是JavaBean中的属性名，而不是表中的列名）指定哪个是主键字段，同时使用useGeneratedKeys属性告诉MyBatis这个主键是否使用数据库内置策略生成__

有时候，我们需要根据一些特殊的关系设置主键id的值。假设我们取消表`t_role`的id自增规则，改为如下自定义规则

* 如果表`t_role`没有记录，则我们需要设置id=1
* 否则，我们就取最大id加2

这个时候，__我们可以使用selectKey元素进行处理__

```xml
<insert id="insertRole" parameterType="role" useGeneratedKeys="true" keyProperty="id">
    <selectKey keyProperty="id" resultType="int" order="BEFORE">
        select if(max(id)) is null, 1, max(id) + 2) as newId from t_role
    </selectKey>

    insert into t_role(id, role_name, note) 
    values(#{id}, #{roleName}, #{note})
</insert>
```

# 4 update元素和delete元素

和insert元素一样，MyBatis执行完update元素和delete元素后会返回一个整数，标出执行后影响的记录条数

# 5 sql元素

sql元素的意义，在于我们可以__定义一串SQL语句的组成部分，其他的语句可以通过引用来使用它__。例如，有一条SQL需要select几十个字段映射到JavaBean中去，另一条SQL也是这几十个字段映射到JavaBean中去，显然这些字段写两遍不太合适，那么可以用sql元素来完成

```xml
<sql id="role_columns">
    id, role_name, note
</sql>

<select parameterType="long" id="getRole" resultMap="roleMap">
    select <include refid="role_columns"/> from t_role where id = #{id}
</select>
```

# 6 参数

## 6.1 特殊字符串替换和处理（\#和$）

`#{}`写法会将传入的数据都当成一个字符串，会对传入的数据加一个双引号。`#{}`方式一般用于传入字段值，并将该值作为字符串加到执行sql中，__一定程度防止sql注入__

使用`${}`时，MyBatis不会将传入的数据当成一个字符串。`${}`方式一般用于传入数据库对象，例如传入表名，__不能防止sql注入，存在风险__

# 7 参考

* 《深入浅出MyBatis技术原理与实战》
* [MyBatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
