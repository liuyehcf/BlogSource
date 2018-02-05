---
title: MyBatis-动态SQL
date: 2018-02-05 19:45:41
tags: 
- 摘录
categories: 
- Java
- Framework
- MyBatis
---

__目录__

<!-- toc -->
<!--more-->

# 1 概述

MyBatis的动态SQL包括以下几种元素

| 元素 | 作用 | 备注 |
|:--|:--|:--|
| if | 判断语句 | 单条件分支判断 |
| choose(when、otherwise) | 相当于Java中的case when语句 | 多条件分支判断 |
| trim(where、set) | 辅助元素 | 用于处理一些SQL拼装问题 |
| foreach | 循环语句 | 在in语句等列举条件常用 |

# 2 if元素

if元素是最常用的判断语句，相当于Java中的if语句，它常常与test属性联合使用

```xml
<select id="findRoles" parameterType="string" resultMap="roleResultMap">
    select role_no, role_name, note from t_role where 1=1
    <if test="roleName != null and roleName != ''">
        and role_name like concat('%', #{roleName}, '%')
    </if>
</select>
```

# 3 choose、when、otherwise元素

有时候，if语句不能满足我们的需求，我们还需要第三种选择甚至更多的选择，这时可以使用choose、when、otherwise元素，它相当于Java中的switch-case-default语句

```xml
<select id="findRoles" parameterType="role" resultMap="roleResultMap">
    select role_no, role_name, note from t_role
    where 1=1
    <choose>
        <when test="roleNo != null and roleNo != ''">
            and role_no = #{roleNo}
        </when>
        <when test="roleName != null and roleName != ''">
            and role_name like concat('%', #{roleName}, '%')
        </when>
        <otherwise>
            and note is not null
        </otherwise>
    </choose>
</select>
```

# 4 trim、where、set元素

前面的例子中加入了"1=1"这样一个条件，如果没有这个条件，得到的SQL语句是有语法错误的（where后面直接跟了一个and）

我们可以使用where元素，如下

```xml
<select id="findRoles" parameterType="string" resultMap="roleResultMap">
    select role_no, role_name, note from t_role
    <where>
        <if test="roleName != null and roleName != ''">
            and role_name like concat('%', #{roleName}, '%')
        </if>
    </where>
</select>
```

这样一来，当where元素里面的条件成立时，才会加入where这个SQL关键字到组装的SQL里面，否则就不加入

有时候，我们需要去掉一些特殊的SQL语法，比如常见的and、or，使用trim元素可以达到这个效果

```xml
<select id="findRoles" parameterType="string" resultMap="roleResultMap">
    select role_no, role_name, note from t_role
    <trim prefix="where" prefixOverrides="and">
        <if test="roleName != null and roleName != ''">
            and role_name like concat('%', #{roleName}, '%')
        </if>
    </trim>
</select>
```

在更新数据的时候，我们往往只想更新某几个字段，而其他字段不更新，set元素可以为我们动态地生成SQL语句

```xml
<update id="updateRole" parameterType="role">
    update t_role
    <set>
        <if test="roleName != null and roleName != ''">
            role_name = #{roleName},
        </if>
        <if test="note != null and note != ''">
            note = #{note}
        </if>
    </set>
    where role_no = #{roleNo}
</update>
```

当set元素遇到了逗号，它会把对应的逗号去掉

trim元素意味着我们需要去掉一些特殊的字符串，__prefix代表的是语句的前缀__，而__prefixOverrides代表的是你需要去掉的那种字符串__

# 5 foreach元素

foreach元素是一个循环语句，它的作用是遍历集合。它能够很好地支持数组和List、Set接口的集合，对此提供遍历的功能

```xml
<select id="findUserBySex" resultType="user">
    select * from t_user where sex in
    <foreach item="sex" index="index" collection="sexList" open="(" separator="," close=")">
        #{sex}
    </foreach>
</select>
```

其中

1. collection：传递进来的参数名称，它可以是一个数组或者List、Set等集合
1. item：循环中当前的元素
1. index：当前元素在集合的位置下标
1. open和close：以什么符号将这些元素包装起来
1. separator：各个元素间的分隔符

# 6 test的属性

test属性用于条件判断语句中，它在MyBatis中广泛使用。它的作用相当于判断真假。在大部分场景中我们都是用它判断空和非空。有时候需要判断字符串、数字和枚举等

# 7 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《深入浅出MyBatis技术原理与实战》
* [MyBatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
