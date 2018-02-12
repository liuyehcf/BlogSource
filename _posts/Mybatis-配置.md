---
title: MyBatis-配置
date: 2018-02-05 11:15:29
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

# 1 MyBatis的基本构成

我们先了解一下MyBatis的核心组件（__先不整合Spring，以下内容都是纯MyBatis的概念、使用以及配置方式__）

1. `SqlSessionFactoryBuilder`：构造器，它会根据配置信息或者代码来生成SqlSessionFactory
    * 利用XML(提取到流对象)或者Java编码(Configuration)对象来构建SqlSessionFactory
    * 通过它可以构建多个SessionFactory
    * 它的作用就是一个构建器，一旦构建了SqlSessionFactory，它的作用就已经完结，失去了存在的意义
    * 它的生命周期只能存在于方法的局部，它的作用就是生成SqlSessionFactory对象
1. `SqlSessionFactory`：会话工厂，用于生产SqlSession
    * SqlSessionFactory的作用是创建SqlSession，而SqlSession就是一个会话，相当于JDBC中的Connection对象
    * 每次应用程序需要访问数据库，我们就要通过SqlSessionFactory创建SqlSession，所以SqlSessionFactory应该在MyBatis应用的整个生命周期中
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
                <property name="url" value="jdbc:mysql:// 127.0.0.1:3306/mybatis"/>
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

两者本质没有区别，一个Configuration对象就对应了一个MyBatis的XML配置文件

## 1.2 创建SqlSession

SqlSession是一个接口类，在MyBatis中SqlSession接口的实现类有两个，分别是

1. DefaultSqlSession
1. SqlSessionManager

SqlSession接口类似于一个JDBC中的Connection接口对象，我们需要保证每次使用完正常关闭它，所以正确的做法是把关闭SqlSession接口的代码写在finally语句中保证每次都会关闭SqlSession，让连接资源归还给数据库

```Java
        SqlSession sqlSession = null;
        try {
            // 打开SqlSession会话
            sqlSession = sqlSessionFactory.openSession();

            // ...
            // 这里执行一些SQL语句
            // ...

            sqlSession.commit();
        } catch (Exception ex) {
            System.err.println(ex.getMessage());
        } finally {
            // 在finally中保证资源被顺利关闭
            if (sqlSession != null) {
                sqlSession.close();
            }
        }
```

SqlSession的用途主要有两种

1. 获取映射器，让映射器通过命名空间和方法名称找到对应的SQL，发送给数据库执行后，返回结果
1. 直接通过命名信息去执行SQL，然后返回结果。这是iBatis版本留下的方式。在SqlSession层我们可以通过update、insert、select、delete等方法，带上SQL的id来操作在XML中配置好的SQL

# 2 MyBatis-XML配置文件

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

__如果没有@Alias注解，MyBatis也会装载，默认的规则是：将首字母小写的类名，作为MyBatis的别名__

## 2.2 environments配置环境

配置环境可以注册多个数据源（dataSource），每一个数据源分为两大部分：

1. 一个是数据源的配置
1. 另一个是数据库事务的配置

示例如下

```xml
    <environments default="development">
        <environment id="development">
            <!-- 采用JDBC事务管理 -->
            <transactionManager type="JDBC">
                <property name="autoCommit" value="false"/>
            </transactionManager>

            <!-- 配置数据库连接信息 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql:// 127.0.0.1:3306/mybatis"/>
                <property name="username" value="root"/>
                <property name="password" value="learn"/>
            </dataSource>
        </environment>
    </environments>
```

分析一下上面的配置

1. environments中的default属性：标明在缺省的情况下，我们将启用哪个数据源配置
1. environment元素是配置一个数据源的开始，属性id是这个数据源的标志，以便在MyBatis上下文中使用它
1. transactionManager是数据库事务的配置
    * 其中type有三种配置方式
        * JDBC：采用JDBC方式管理事务，在独立编码中常常使用
        * MANAGED：采用容器方式管理事务，在JNDI数据源中常用
        * 自定义，由使用者自定义数据库事务管理拌饭，适用于特殊应用
    * property元素则是可以配置数据源的各类属性
1. dataSource标签，是配置数据源连接的信息
    * type属性是提供我们队数据库连接方式的配置，MyBatis支持如下几种配置方式
        * UNPOOLED：非连接池数据库，UnpooledDataSrouce
        * POOLED：连接池数据库，PooledDataSource
        * JNDI：JNDI数据源，JNDIDataSrouce
    * property元素可以定义数据库各类参数

## 2.3 引入映射器的方法

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

# 3 MyBatis-Spring

配置MyBatis-Spring分为下面几个部分

1. 配置数据源
1. 配置SqlSessionFactory
1. 配置SqlSessionTemplate
1. 配置Mapper
1. 事务处理

在Spring中要构建SqlSessionTemplate对象，让它来产生SqlSession，而在MyBatis-Spring项目中SqlSession的使用是通过SqlSessionTemplate来实现的，它实现了SqlSession接口。所以通过SqlSessionTemplate可以得到Mapper

## 3.1 配置SqlSessionFactory

MyBatis-Spring项目提供了`org.mybatis.spring.SqlSessionFactoryBean`来配置SqlSessionFactory，一般而言需要提供两个参数

1. 数据源
1. MyBatis配置文件路径

__示例：__

```xml
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql:// 127.0.0.1:3306/mybatis"/>
        <property name="username" value="root"/>
        <property name="password" value="learn"/>
    </bean>

    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource" ref="dataSource"/>
        <property name="configLocation" value="classpath:sqlMapConfig.xml"/>
    </bean>
```

__MyBatis配置文件`sqlMapConfig.xml`如下__

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-// mybatis.org// DTD Config 3.0// EN"
        "http:// mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>

    <settings>
        <!-- 这个配置使全局的映射器启用或禁用 -->
        <setting name="cacheEnabled" value="true"/>

        <!-- 允许JDBC支持生成的键 -->
        <setting name="useGeneratedKeys" value="true"/>

        <!-- 配置默认的执行器
            SIMPLE执行器没有什么特别之处
            REUSE执行器重用预处理语句
            BATCH执行器重用语句和批量更新
            -->
        <setting name="defaultExecutorType" value="REUSE"/>

        <!-- 全局启用或禁用延迟加载。当禁用时，所有关联对象都会即使加载 -->
        <setting name="lazyLoadingEnabled" value="true"/>

        <!-- 设置超时时间，它决定驱动等待一个数据库响应的时间 -->
        <setting name="defaultStatementTimeout" value="25000"/>
    </settings>

    <!-- 定义别名 -->
    <typeAliases>
        <typeAlias alias="role" type="com.learn.chapter2.po.Role"/>
    </typeAliases>

    <!-- 定义映射器 -->
    <mappers>
        <mapper resource="com/learn/chapter2/mapper/roleMapper.xml"/>
    </mappers>
</configuration>
```

事实上，SqlSessionFactoryBean已经可以通过Spring IoC配置了，因此，我们完全可以通过Spring IoC来代替原来的配置。SqlSessionFactoryBean包含如下字段

```Java
    private Resource configLocation;

    private Configuration configuration;

    private Resource[] mapperLocations;

    private DataSource dataSource;

    private TransactionFactory transactionFactory;

    private Properties configurationProperties;

    private SqlSessionFactoryBuilder sqlSessionFactoryBuilder = new SqlSessionFactoryBuilder();

    private SqlSessionFactory sqlSessionFactory;

    // EnvironmentAware requires spring 3.1
    private String environment = SqlSessionFactoryBean.class.getSimpleName();

    private boolean failFast;

    private Interceptor[] plugins;

    private TypeHandler<?>[] typeHandlers;

    private String typeHandlersPackage;

    private Class<?>[] typeAliases;

    private String typeAliasesPackage;

    private Class<?> typeAliasesSuperType;

    // issue #19. No default provider.
    private DatabaseIdProvider databaseIdProvider;

    private Class<? extends VFS> vfs;

    private Cache cache;

    private ObjectFactory objectFactory;

    private ObjectWrapperFactory objectWrapperFactory;
```

SqlSessionFactoryBean中的这些字段对应的XML配置项如下

```xml
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
        <property name="dataSource"/>

        <property name="mapperLocations"/>

        <property name="typeAliases"/>
        <property name="typeAliasesPackage"/>
        <property name="typeAliasesSuperType"/>

        <property name="transactionFactory"/>

        <property name="sqlSessionFactoryBuilder"/>

        <property name="objectFactory"/>
        <property name="objectWrapperFactory"/>

        <property name="typeHandlers"/>
        <property name="typeHandlersPackage"/>

        <property name="configLocation"/>
        <property name="configurationProperties"/>
        <property name="plugins"/>
        <property name="databaseIdProvider"/>
        <property name="environment"/>
        <property name="failFast"/>
    </bean>
```

大部分情况下，我们无需全部配置，只需要配置其中几项即可

## 3.2 配置SqlSessionTemplate

## 3.3 配置Mapper

在大部分场景中，都不建议使用SqlSessionTemplate或者SqlSession，而是推荐采用Mapper接口编程的方式，这样更符合面向对象的编程，也更利于我们理解

### 3.3.1 MapperFactoryBean

在MyBatis中，Mapper只需要一个接口，而不是一个实现类，它是由MyBatis体系通过动态代理的形式生成代理对象去运行的，所以Spring也没有办法为其生成实现类

为了处理这个问题，MyBatis-Spring团队提供了一个MapperFactoryBean类作为中介，我们可以通过它来实现我们想要的Mapper。配置MapperFactoryBean有三个参数

1. mapperInterface：用来定制接口，当我们的接口继承了配置的接口，那么MyBatis就认为它是一个Mapper
1. sqlSessionFactory：当sqlSessionTemplate属性不被配置的时候，MyBatis-Spring才会去设置它
1. sqlSessionTemplate：当它被设置的时候，sqlSessionFactory将被作废

```xml
    <bean id="userDao" class="org.mybatis.spring.mapper.MapperFactoryBean">
        <property name="mapperInterface" value="com.learn.dao.UserDAO"/>

        <!-- 同时注入sqlSessionTemplate和sqlSessionFactory，则只会启用sqlSessionTemplate -->
        <property name="sqlSessionTemplate" ref="sqlSessionTemplate"/>
        <property name="sqlSessionFactory" ref="sqlSessionFactory"/>
    </bean>
```

### 3.3.2 MapperScannerConfigurer

如果每个DAO都需要单独配置，那么工作量会非常大，MyBatis-Spring团队已经考虑到了这种场景，我们可以通过配置MapperScannerConfigurer来实现自动扫描我们的映射器

MapperScannerConfigurer有如下几个属性

1. basePackage：指定让Spring自动扫描什么包，它会逐层深入扫描
1. annotationClass：表示如果类被这个注解标识的时候，才进行扫描
1. sqlSessionFactoryBeanName：指定在Spring中定义sqlSessionFactory的bean名称。如果它被定义，sqlSessionFactory将不起作用
1. sqlSessionTemplateBeanName：指定在Spring中定义sqlSessionTemplate的bean的名称。如果它被定义，sqlSessionFactoryBeanName将不起作用
1. makerInterface：指定是实现了什么借口就认为它是Mapper，我们需要提供一个公共的接口去标记。在Spring配置前需要给DAO一个注解，在Spring中往往是使用注解@Repository表示DAO层

```xml
    <bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
        <property name="basePackage" value="com.learn.dao"/>
        <property name="sqlSessionTemplateBeanName" value="sqlSessionTemplate"/>
        <property name="annotationClass" value="org.springframework.stereotype.Repository"/>
    </bean>
```

这样，Spring上下文就会自动扫描com.learn.dao从而找到标注了Repository的接口，自动生成Mapper

## 3.4 配置事务

声明式事务配置

```xml
    <!-- 配置事务管理器 -->
    <bean id="txManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
        <property name="dataSource" ref="dataSource"/>
    </bean>

    <!-- 使用声明式事务管理方式 -->
    <tx:annotation-driven transaction-manager="txManager"/>
```

## 3.5 总结

配置Mapper，是让MyBatis为这些接口生成动态代理，然后根据实际的方法，通过mapperLocations配置的xml找到对应的SQL模板进行调用

# 4 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* 《深入浅出MyBatis技术原理与实战》
* [MyBatis教程](http://www.mybatis.org/mybatis-3/zh/index.html)
