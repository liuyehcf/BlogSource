---
title: Mybatis-配置
date: 2018-02-05 11:15:29
tags: 
- 摘录
categories: 
- Java
- Framework
- Mybatis
---

__目录__

<!-- toc -->
<!--more-->

# 1 MyBatis的基本构成

我们先了解一下MyBatis的核心组件

1. `SqlSessionFactoryBuilder`：构造器，它会根据配置信息或者代码来生成SqlSessionFactory
    * 利用XML(提取到流对象)或者Java编码(Configuration)对象来构建SqlSessionFactory
    * 通过它可以构建多个SessionFactory
    * 它的作用就是一个构建器，一旦构建了SqlSessionFactory，它的作用就已经完结，失去了存在的意义
    * 它的生命周期只能存在于方法的局部，它的作用就是生成SqlSessionFactory对象
1. `SqlSessionFactory`：会话工厂，用于生产SqlSession
    * SqlSessionFactory的作用是创建SqlSession，而SqlSession就是一个会话，相当于JDBC中的Connection对象
    * 每次应用程序需要访问数据库，我们就要通过SqlSessionFactory创建SqlSession，所以SqlSessionFactory应该在Mybatis应用的整个生命周期中
    * 每个数据库只对应一个SqlSessionFactory
1. `SqlSession`：会话，一个可以发送SQL去执行并返回结果，也可以获取Mapper的接口
    * SqlSession是一个会话，相当于JDBC的一个Connection对象，它的生命周期应该是在请求数据库处理事务的过程中
    * 它是一个线程不安全的对象
    * 每次创建它后，都必须及时关闭它，避免浪费资源
1. `Mapper`：映射器，它由一个Java接口和XML文件（或注解）构成，需要给出对应的SQL和映射规则。它负责发送SQL去执行，并返回结果
    * 它存在于一个SqlSession事务方法之内，是一个方法级别的东西
    * 它就如同JDBC中一条SQL语句的执行，它最大的范围和SqlSession是相同的

## 1.1 构建SqlSessionFactory

通过代码构建SqlSessionFactory，需要自己构造Configuration对象，Configuration对象包含了一些基本的配置信息

```Java
        // 构建数据库连接池
        PooledDataSource dataSource = new PooledDataSource();
        dataSource.setDriver("com.mysql.jdbc.Driver");
        dataSource.setUsername("root");
        dataSource.setPassword("learn");

        // 构建数据库事务方式
        TransactionFactory transactionFactory = new JdbcTransactionFactory();

        // 创建数据库运行环境
        Environment environment = new Environment("development", transactionFactory, dataSource);

        // 构建Configuration对象
        Configuration configuration = new Configuration(environment);
        configuration.getTypeAliasRegistry().registerAlias("role", Role.class); // 注册MyBatis上下文别名
        configuration.addMapper(RoleMapper.class); // 加入一个映射器

        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(configuration);
```

通过XML文件构建SqlSessionFactory，在XML文件中进行配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-// mybatis.org// DTD Config 3.0// EN"
        "http:// mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 定义别名 -->
    <typeAliases>
        <typeAlias alias="role" type="com.learn.chapter2.po.Role"/>
    </typeAliases>

    <!-- 定义数据库信息，默认使用id为development的environment -->
    <environments default="development">
        <environment id="development">
            <!-- 采用JDBC事务管理 -->
            <transactionManager type="JDBC"/>

            <!-- 配置数据库连接信息 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql:// localhost:3306/mybatis"/>
                <property name="username" value="root"/>
                <property name="password" value="learn"/>
            </dataSource>
        </environment>
    </environments>

    <!-- 定义映射器 -->
    <mappers>
        <mapper resource="com/learn/chapter2/mapper/roleMapper.xml"/>
    </mappers>
</configuration>
```

```Java
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

两者本质没有区别，一个Configuration对象就对应了一个XML配置文件

# 2 XML配置文件

MyBatis配置XML文件的层次结构如下

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-// mybatis.org// DTD Config 3.0// EN"
        "http:// mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <properties/> <!--属性-->
    <settings/> <!--设置-->
    <typeAliases/> <!--类型别名-->
    <typeHandlers/> <!--类型处理器-->
    <objectFactory/> <!--对象工厂-->
    <plugins/> <!--插件-->
    <environments> <!--配置环境-->
        <environment> <!--环境变量-->
            <transactionManager/> <!--事务管理器-->
            <dataSource/> <!--数据源-->
        </environment>
    </environments>
    <databaseIdProvider/> <!--数据库厂商标识-->
    <mappers/> <!--映射器-->
</configuration>
```

## 2.1 别名

别名(typeAliases)是一个指代的名称，用一个简短的名称去指代一个类全限定名，而这个别名可以在MyBatis上下文中使用。在MyBatis中，别名是不区分大小写的

一个typeAliases的实例是在解析配置文件时生成的，然后长期保存在Configuration对象中

### 2.1.1 系统别名

```Java
public TypeAliasRegistry() {
    registerAlias("string", String.class);

    registerAlias("byte", Byte.class);
    registerAlias("long", Long.class);
    registerAlias("short", Short.class);
    registerAlias("int", Integer.class);
    registerAlias("integer", Integer.class);
    registerAlias("double", Double.class);
    registerAlias("float", Float.class);
    registerAlias("boolean", Boolean.class);

    registerAlias("byte[]", Byte[].class);
    registerAlias("long[]", Long[].class);
    registerAlias("short[]", Short[].class);
    registerAlias("int[]", Integer[].class);
    registerAlias("integer[]", Integer[].class);
    registerAlias("double[]", Double[].class);
    registerAlias("float[]", Float[].class);
    registerAlias("boolean[]", Boolean[].class);

    registerAlias("_byte", byte.class);
    registerAlias("_long", long.class);
    registerAlias("_short", short.class);
    registerAlias("_int", int.class);
    registerAlias("_integer", int.class);
    registerAlias("_double", double.class);
    registerAlias("_float", float.class);
    registerAlias("_boolean", boolean.class);

    registerAlias("_byte[]", byte[].class);
    registerAlias("_long[]", long[].class);
    registerAlias("_short[]", short[].class);
    registerAlias("_int[]", int[].class);
    registerAlias("_integer[]", int[].class);
    registerAlias("_double[]", double[].class);
    registerAlias("_float[]", float[].class);
    registerAlias("_boolean[]", boolean[].class);

    registerAlias("date", Date.class);
    registerAlias("decimal", BigDecimal.class);
    registerAlias("bigdecimal", BigDecimal.class);
    registerAlias("biginteger", BigInteger.class);
    registerAlias("object", Object.class);

    registerAlias("date[]", Date[].class);
    registerAlias("decimal[]", BigDecimal[].class);
    registerAlias("bigdecimal[]", BigDecimal[].class);
    registerAlias("biginteger[]", BigInteger[].class);
    registerAlias("object[]", Object[].class);

    registerAlias("map", Map.class);
    registerAlias("hashmap", HashMap.class);
    registerAlias("list", List.class);
    registerAlias("arraylist", ArrayList.class);
    registerAlias("collection", Collection.class);
    registerAlias("iterator", Iterator.class);

    registerAlias("ResultSet", ResultSet.class);
  }
```

### 2.1.2 自定义别名

我们可以用typeAliases配置别名，也可以用代码方式注册别名

```xml

    <typeAliases>
        <typeAlias alias="role" type="com.learn.chapter2.po.Role"/>
    </typeAliases>
```

如果POJO过多，那么配置起来也是非常麻烦的，MyBatis允许我们通过自动扫描的形式自定义别名

```xml
    <typeAliases>
        <package name="com.learn.chapter2.po"/>
    </typeAliases>
```

__我们可以通过@Alias自定义别名，如下：__

```Java
@Alias("role")
public class Role{
    // some code
}
```

__如果没有@Alias注解，MyBatis也会装载，默认的规则是：将类名的第一个字母小写，作为MyBatis的别名__

## 2.2 引入映射器

__用文件路径引入映射器__

```xml
<mappers>
    <mapper resource="com/learn/chapter3/mapper/roleMapper.xml"/>
</mappers>
```

__用包名引入映射器__

```xml
<mappers>
    <package name="com.learn.chapter3.mapper"/>
</mappers>
```

__用类注册引入映射器__

```xml
<mappers>
    <mapper class="com.learn.chapter3.mapper.UserMapper"/>
    <mapper class="com.learn.chapter3.mapper.RoleMapper"/>
</mappers>
```

__用userMapper.xml引入映射器__

```xml
<mappers>
    <mapper url="file:// /var/mappers/com/learn/chapter3/mapper/userMapper.xml"/>
    <mapper url="file:// /var/mappers/com/learn/chapter3/mapper/roleMapper.xml"/>
</mappers>
```

# 3 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《深入浅出MyBatis技术原理与实战》
* [Mybatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
