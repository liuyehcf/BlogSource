---
title: Java-SourceAnalysis-MyBatis
date: 2018-02-07 08:30:09
tags: 
- 原创
categories: 
- Java
- Framework
- MyBatis
---

**阅读更多**

<!--more-->

# 1 前言

本文围绕以下几个问题展开对MyBatis源码的研究（不涉及Spring，纯MyBatis）

1. SqlSession如何生成
1. MyBatis如何为我们定义的DAO接口生成实现类
1. 映射器的两个组件：Java接口和映射器配置文件如何建立关联
1. 映射器如何执行SQL操作

**分析用到的Demo源码详见{% post_link MyBatis-Demo %}**

分析的源码版本为

```xml
    <dependency>
        <groupId>org.mybatis</groupId>
        <artifactId>mybatis</artifactId>
        <version>3.4.5</version>
    </dependency>
```

# 2 SqlSessionFactory生成

**分析起点**

```java
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

MyBatis采用建造者模式来创建SqlSessionFactory，SqlSessionFactoryBuilder就是一个建造者，我们首先来看一下build方法

```java
    public SqlSessionFactory build(InputStream inputStream) {
        return build(inputStream, null, null);
    }

    public SqlSessionFactory build(InputStream inputStream, String environment, Properties properties) {
        try {
            //构建配置文件解析器
            XMLConfigBuilder parser = new XMLConfigBuilder(inputStream, environment, properties);

            //parser.parse()将生成Configuration对象
            return build(parser.parse());
        } catch (Exception e) {
            throw ExceptionFactory.wrapException("Error building SqlSession.", e);
        } finally {
            ErrorContext.instance().reset();
            try {
                inputStream.close();
            } catch (IOException e) {
                //Intentionally ignore. Prefer previous error.
            }
        }
    }
```

关于XMLConfigBuilder的构建，这里不做分析，这是XML解析相关的内容，其本质就是读取配置文件，然后生成一颗DOM树

我们接着看一下XMLConfigBuilder.parse方法（该方法将在后面的小节中详细分析），该方法从XML的DOM树节点中取出相应的配置项，初始化Configuration，然后返回Configuration的对象

**至此，配置文件的生命周期已经结束，所有的配置信息都保存在了这个Configuration的对象之中**

接着，我们回到SqlSessionFactoryBuilder的build方法中，继续看同名的build方法，该方法返回一个SqlSessionFactory的对象

```java
    public SqlSessionFactory build(Configuration config) {
        return new DefaultSqlSessionFactory(config);
    }
```

DefaultSqlSessionFactory的构造方法如下

```java
    private final Configuration configuration;

    public DefaultSqlSessionFactory(Configuration configuration) {
        this.configuration = configuration;
    }
```

至此，SqlSessionFactory的创建工作完毕。简单来说，SqlSessionFactory的初始化过程如下

1. 读取MyBatis的配置文件，封装成Configuration对象
1. 生成SqlSessionFactory接口的实例，该SqlSessionFactory的实例持有这个Configuration对象

## 2.1 Configuration对象的创建

SqlSessionFactoryBuilder.build方法中调用了XMLConfigBuilder.parse方法来创建Configuration对象，主干源码如下：

```java
    public Configuration parse() {
        if (parsed) {
            throw new BuilderException("Each XMLConfigBuilder can only be used once.");
        }
        parsed = true;
        //这里从DOM树中取出相应元素的属性值，初始化configuration
        parseConfiguration(parser.evalNode("/configuration"));

        //返回Configuration的对象
        return configuration;
    }

    private void parseConfiguration(XNode root) {
        try {
            //issue #117 read properties first
            propertiesElement(root.evalNode("properties"));
            Properties settings = settingsAsProperties(root.evalNode("settings"));
            loadCustomVfs(settings);
            typeAliasesElement(root.evalNode("typeAliases"));
            pluginElement(root.evalNode("plugins"));
            objectFactoryElement(root.evalNode("objectFactory"));
            objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
            reflectorFactoryElement(root.evalNode("reflectorFactory"));
            settingsElement(settings);
            //read it after objectFactory and objectWrapperFactory issue #631
            environmentsElement(root.evalNode("environments"));
            databaseIdProviderElement(root.evalNode("databaseIdProvider"));
            typeHandlerElement(root.evalNode("typeHandlers"));
            mapperElement(root.evalNode("mappers"));
        } catch (Exception e) {
            throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
        }
    }
```

依据MyBatis配置文件元素的划分，Configuration的初始化分为了若干个步骤，每个步骤对应于一个配置项的解析与初始化

### 2.1.1 读取映射器配置文件

我们着重看一下Mapper初始化过程，对应于XMLConfigBuilder.mapperElement方法

```java
    private void mapperElement(XNode parent) throws Exception {
        if (parent != null) {
            for (XNode child : parent.getChildren()) {
                //若子元素是package元素，即扫描包名
                if ("package".equals(child.getName())) {
                    String mapperPackage = child.getStringAttribute("name");
                    configuration.addMappers(mapperPackage);
                } 
                //若子元素是mapper元素
                else {
                    String resource = child.getStringAttribute("resource");
                    String url = child.getStringAttribute("url");
                    String mapperClass = child.getStringAttribute("class");
                    //配置了resource属性，对应于路径配置
                    if (resource != null && url == null && mapperClass == null) {
                        ErrorContext.instance().resource(resource);
                        //获取输入流
                        InputStream inputStream = Resources.getResourceAsStream(resource);

                        //创建映射器配置文件的解析器
                        XMLMapperBuilder mapperParser = new XMLMapperBuilder(inputStream, configuration, resource, configuration.getSqlFragments());

                        //进行解析，里面会调用Configuration.addMapper方法添加Mapper
                        mapperParser.parse();
                    } 
                    //配置了url属性，对应于url配置
                    else if (resource == null && url != null && mapperClass == null) {
                        ErrorContext.instance().resource(url);
                        //获取输入流
                        InputStream inputStream = Resources.getUrlAsStream(url);

                        //创建映射器配置文件的解析器
                        XMLMapperBuilder mapperParser = new XMLMapperBuilder(inputStream, configuration, url, configuration.getSqlFragments());

                        //进行解析，里面会调用Configuration.addMapper方法添加Mapper
                        mapperParser.parse();
                    } 
                    //配置了class属性，对应于类的配置
                    else if (resource == null && url == null && mapperClass != null) {
                        Class<?> mapperInterface = Resources.classForName(mapperClass);
                        //添加Mapper
                        configuration.addMapper(mapperInterface);
                    } else {
                        throw new BuilderException("A mapper element may only specify a url, resource or class, but not more than one.");
                    }
                }
            }
        }
    }
```

我们以mapper子元素且配置了resrouce为例进行分析，其余方式最终结果都是一样的，即调用configuration.addMapper方法添加映射器的配置信息

接下来，我们看一下XMLMapperBuilder.parse方法

```java
    public void parse() {
        if (!configuration.isResourceLoaded(resource)) {
            //解析元素
            configurationElement(parser.evalNode("/mapper"));

            //添加到队列中，标记为已经加载过
            configuration.addLoadedResource(resource);

            //将一个Mapper的两个组件进行绑定，这两个组件分别是Java接口和XML配置文件
            bindMapperForNamespace();
        }

        parsePendingResultMaps();
        parsePendingCacheRefs();
        parsePendingStatements();
    }
```

首先，我们来看一下configurationElement方法，该方法用于解析映射器配置文件，读入相应的配置信息

```java
    private void configurationElement(XNode context) {
        try {
            String namespace = context.getStringAttribute("namespace");
            if (namespace == null || namespace.equals("")) {
                throw new BuilderException("Mapper's namespace cannot be empty");
            }
            builderAssistant.setCurrentNamespace(namespace);
            cacheRefElement(context.evalNode("cache-ref"));
            cacheElement(context.evalNode("cache"));
            parameterMapElement(context.evalNodes("/mapper/parameterMap"));
            resultMapElements(context.evalNodes("/mapper/resultMap"));
            sqlElement(context.evalNodes("/mapper/sql"));

            //每一条SQL语句都作为一个MappedStatement存在于Configuration中
            buildStatementFromContext(context.evalNodes("select|insert|update|delete"));
        } catch (Exception e) {
            throw new BuilderException("Error parsing Mapper XML. Cause: " + e, e);
        }
    }
```

其次，bindMapperForNamespace方法为映射器绑定命名空间（namespace）

```java
    private void bindMapperForNamespace() {
        //获取刚才读入的命名空间的配置信息
        String namespace = builderAssistant.getCurrentNamespace();
        if (namespace != null) {
            Class<?> boundType = null;
            try {
                //首先，尝试根据命名空间找到对应的Class对象
                boundType = Resources.classForName(namespace);
            } catch (ClassNotFoundException e) {
                //ignore, bound type is not required
            }

            //根据命名空间成功找到Class对象
            if (boundType != null) {
                if (!configuration.hasMapper(boundType)) {
                    //Spring may not know the real resource name so we set a flag
                    //to prevent loading again this resource from the mapper interface
                    //look at MapperAnnotationBuilder#loadXmlResource
                    configuration.addLoadedResource("namespace:" + namespace);

                    //添加Mapper到Configuration中
                    configuration.addMapper(boundType);
                }
            }
        }
    }
```

继续看Configuration.addMapper方法

```java
    public <T> void addMapper(Class<T> type) {
        mapperRegistry.addMapper(type);
    }
```

Configuration.addMapper将任务转交给了MapperRegistry的同名方法，MapperRegistry这个类就是用于管理Mapper注册信息的。我们继续看MapperRegistry.addMapper方法

```java
    public <T> void addMapper(Class<T> type) {
        //只有当type是接口时，才会对其进行管理
        if (type.isInterface()) {
            if (hasMapper(type)) {
                throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
            }
            boolean loadCompleted = false;
            try {
                //添加一个<Class<?>, MapperProxyFactory<?>>的键值对，其中MapperProxyFactory是代理工厂类，为Mapper指定接口创建代理类
                knownMappers.put(type, new MapperProxyFactory<T>(type));
                //It's important that the type is added before the parser is run
                //otherwise the binding may automatically be attempted by the
                //mapper parser. If the type is already known, it won't try.
                
                //如果该接口配置了相关注解（@Select之类的SQL注解），那么进行扫描解析
                MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
                parser.parse();
                loadCompleted = true;
            } finally {
                if (!loadCompleted) {
                    knownMappers.remove(type);
                }
            }
        }
    }
```

该方法首先创建一个键值对，类型为`<Class<?>, MapperProxyFactory<?>>`，**其中MapperProxyFactory为代理工厂，其主要职能是为Mapper创建代理类，这是MyBatis的核心内容**，在后面的小节将会详细介绍，这里不再赘述。其次，该方法会**扫描接口中配置的注解**，譬如@Select、@Insert、@Update、@Delete等（但是**不会解析@Param这种参数注解**）

因此，**如果一个映射器的配置方式是Java接口加上注解**，那么配置Mapper的属性为class，根据XMLConfigBuilder.mapperElement的逻辑，将会直接调用Configuration.addMapper方法，于是同样会走到MapperRegistry.addMapper的逻辑来扫描注解

注意一下，**MyBatis`不要求`映射器配置文件的namespace必须对应着一个接口**。如果namespace不是一个接口的话，无法使用Mapper方式来操作SQL，不过还是能通过iBatis的方式进行SQL操作，例如

```java
sqlSession.selectList("some-namespace.update", map);
```

# 3 SqlSession生成

**分析起点**

```java
sqlSession = sqlSessionFactory.openSession();
```

一般而言，SqlSessionFactory的实现类就是DefaultSqlSessionFactory，于是，我们来看一下DefaultSqlSessionFactory的openSession方法

```java
    public SqlSession openSession() {
        return openSessionFromDataSource(configuration.getDefaultExecutorType(), null, false);
    }
```

该方法从configuration中获取了一个执行器的类型（ExecutorType），这里简单介绍一下执行器的种类（对应着枚举类型ExecutorType）

1. `SIMPLE`：没有什么特别之处
1. `REUSE`：重用预处理语句
1. `BATCH`：执行器重用语句和批量更新

我们继续看openSessionFromDataSource方法，该方法也位于DefaultSqlSessionFactory中

```java
    private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
        Transaction tx = null;
        try {
            //获取环境配置信息
            final Environment environment = configuration.getEnvironment();

            //获取事务工厂
            final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);

            //创建事务对象
            tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);

            //根据配置信息生成执行器
            final Executor executor = configuration.newExecutor(tx, execType);

            //创建会话
            return new DefaultSqlSession(configuration, executor, autoCommit);
        } catch (Exception e) {
            closeTransaction(tx); //may have fetched a connection so lets call close()
            throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
        } finally {
            ErrorContext.instance().reset();
        }
    }
```

我们首先来看一下创建事务对象这一步，即`tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);`

这里这个TransactionFactory的实现类是JdbcTransactionFactory

```java
    public Transaction newTransaction(DataSource ds, TransactionIsolationLevel level, boolean autoCommit) {
        return new JdbcTransaction(ds, level, autoCommit);
    }
```

接着，我们来看一下JdbcTransaction的类结构（这里列出了所有字段，以及一部分方法）

```java
public class JdbcTransaction implements Transaction {
    //...

    //jdbc连接
    protected Connection connection;

    //数据源
    protected DataSource dataSource;

    //事务隔离级别
    protected TransactionIsolationLevel level;
    //MEMO: We are aware of the typo. See #941

    //是否自动提交
    protected boolean autoCommmit;

    public JdbcTransaction(DataSource ds, TransactionIsolationLevel desiredLevel, boolean desiredAutoCommit) {
        dataSource = ds;
        level = desiredLevel;
        autoCommmit = desiredAutoCommit;
    }

    @Override
    public Connection getConnection() throws SQLException {
        if (connection == null) {
            openConnection();
        }
        return connection;
    }

    @Override
    public void commit() throws SQLException {
        if (connection != null && !connection.getAutoCommit()) {
            if (log.isDebugEnabled()) {
                log.debug("Committing JDBC Connection [" + connection + "]");
            }
            connection.commit();
        }
    }

    @Override
    public void rollback() throws SQLException {
        if (connection != null && !connection.getAutoCommit()) {
            if (log.isDebugEnabled()) {
                log.debug("Rolling back JDBC Connection [" + connection + "]");
            }
            connection.rollback();
        }
    }

    @Override
    public void close() throws SQLException {
        if (connection != null) {
            resetAutoCommit();
            if (log.isDebugEnabled()) {
                log.debug("Closing JDBC Connection [" + connection + "]");
            }
            connection.close();
        }
    }
    //...
}
```

可以看到JdbcTransaction依赖于底层的JDBC接口实现事务的相关操作

接着，我们回到DefaultSqlSessionFactory.openSessionFromDataSource方法中，看一下执行器的生成

```java
    public Executor newExecutor(Transaction transaction, ExecutorType executorType) {
        executorType = executorType == null ? defaultExecutorType : executorType;
        executorType = executorType == null ? ExecutorType.SIMPLE : executorType;
        Executor executor;
        if (ExecutorType.BATCH == executorType) {
            executor = new BatchExecutor(this, transaction);
        } else if (ExecutorType.REUSE == executorType) {
            executor = new ReuseExecutor(this, transaction);
        } else {
            executor = new SimpleExecutor(this, transaction);
        }

        //是否允许缓存
        if (cacheEnabled) {
            //将执行器封装成可缓存的执行器
            executor = new CachingExecutor(executor);
        }

        //MyBatis允许我们自定义插件，这里织入插件的逻辑
        executor = (Executor) interceptorChain.pluginAll(executor);
        return executor;
    }
```

逻辑很简单，就是根据传入的ExecutorType的实际类型，来选择生成不同的执行器。这里我们选择SimpleExecutor接着往下分析。Executor（MyBatis中定义的一个接口）继承结构如下

```
Executor
    ├── CachingExecutor
    ├── BaseExecutor
    │       ├── SimpleExecutor
    │       ├── ReuseExecutor
    │       ├── BatchExecutor
```

接下来看一下SimpleExecutor的构造方法，以及父类BaseExecutor的构造方法

```java
    public SimpleExecutor(Configuration configuration, Transaction transaction) {
        super(configuration, transaction);
    }

    protected BaseExecutor(Configuration configuration, Transaction transaction) {
        this.transaction = transaction;
        this.deferredLoads = new ConcurrentLinkedQueue<BaseExecutor.DeferredLoad>();
        this.localCache = new PerpetualCache("LocalCache");
        this.localOutputParameterCache = new PerpetualCache("LocalOutputParameterCache");
        this.closed = false;
        this.configuration = configuration;
        this.wrapper = this;
    }
```

可以看到，SimpleExecutor的初始化，仅仅做了字段赋值的操作

现在，我们再次回到DefaultSqlSessionFactory.openSessionFromDataSource方法中，看一下SqlSession的创建，这里创建了一个DefaultSqlSession，持有了刚才创建好的Configuration以及Executor对象

```java
    public DefaultSqlSession(Configuration configuration, Executor executor, boolean autoCommit) {
        this.configuration = configuration;
        this.executor = executor;
        this.dirty = false;
        this.autoCommit = autoCommit;
    }
```

至此，SqlSession的创建分析完毕，构建SqlSession之前，需要获取两项内容

1. Configuration对象，这个可以从SqlSessionFactory中获取
1. Executor对象，该对象的创建又依赖于数据库事务对象（Transaction）。所有通过SqlSession执行的SQL操作，最终都会由该Executor对象来执行

# 4 Mapper代理生成

**分析起点**

首先，我们要明确，**每次**我们通过SqlSession接口的getMapper方法获取Mapper时，MyBatis就会为我们创建一个Mapper的代理对象

```java
CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);
```

以DefaultSqlSession为例，getMapper方法如下

```java
    public <T> T getMapper(Class<T> type) {
        return configuration.<T>getMapper(type, this);
    }
```

继续跟踪Configuration的同名方法

```java
    public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        return mapperRegistry.getMapper(type, sqlSession);
    }
```

同样，Configuration还是将请求转发给了MapperRegistry的同名方法，在分析Configuration对象创建的过程中，我们已经知道MapperRegistry是用于管理Mapper注册信息的

继续跟踪MapperRegistry的同名方法，该方法的逻辑如下

1. **首先从MapperRegistry的缓存中（knownMappers）以Class对象为键，拿到MapperProxyFactory对象**
    * **如果无法获取到，那么意味着namespace没有对应着一个Java接口，因此，无法使用Mapper方式操作SQL**，于是直接抛出异常
1. 然后用这个获取到的MapperProxyFactory对象来为当前Java接口创建代理对象

在Configuration对象创建的分析中，我们已经分析过了knownMappers的添加流程，关键逻辑在MapperRegistry.addMapper方法中，这里不再赘述

```java
    public <T> T getMapper(Class<T> type, SqlSession sqlSession) {
        //首先从缓存中，依据Class对象获取到MapperProxyFactory的实例
        final MapperProxyFactory<T> mapperProxyFactory = (MapperProxyFactory<T>) knownMappers.get(type);
        //如果获取不到MapperProxyFactory的实例，那么意味着映射器namespace并未对应着一个Java接口，之前我们分析过，因此无法用Mapper方式来进行SQL操作，这里直接抛异常
        if (mapperProxyFactory == null) {
            throw new BindingException("Type " + type + " is not known to the MapperRegistry.");
        }
        try {
            //通过代理工厂类为当前Java接口创建代理对象，这是核心
            return mapperProxyFactory.newInstance(sqlSession);
        } catch (Exception e) {
            throw new BindingException("Error getting mapper instance. Cause: " + e, e);
        }
    }
```

接下来，我们看下这个MapperProxyFactory是如何为我们创建代理对象的

```java
    public T newInstance(SqlSession sqlSession) {
        //这个MapperProxy实现了InvocationHandler，即JDK动态代理的核心接口
        final MapperProxy<T> mapperProxy = new MapperProxy<T>(sqlSession, mapperInterface, methodCache);
        return newInstance(mapperProxy);
    }

    protected T newInstance(MapperProxy<T> mapperProxy) {
        //JDK动态代理的核心API，不多说了
        return (T) Proxy.newProxyInstance(mapperInterface.getClassLoader(), new Class[] { mapperInterface }, mapperProxy);
    }
```

这个MapperProxy实现了InvocationHandler，即JDK动态代理的核心接口，因此这个MapperProxy包含了代理了的核心逻辑，该类源码如下

```java
package org.apache.ibatis.binding;

import java.io.Serializable;
import java.lang.invoke.MethodHandles;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Map;

import org.apache.ibatis.lang.UsesJava7;
import org.apache.ibatis.reflection.ExceptionUtil;
import org.apache.ibatis.session.SqlSession;

/**
 * @author Clinton Begin
 * @author Eduardo Macarron
 */
public class MapperProxy<T> implements InvocationHandler, Serializable {

    private static final long serialVersionUID = -6424540398559729838L;
    //会话
    private final SqlSession sqlSession;

    //Mapper对应的Java接口
    private final Class<T> mapperInterface;

    //缓存
    private final Map<Method, MapperMethod> methodCache;

    public MapperProxy(SqlSession sqlSession, Class<T> mapperInterface, Map<Method, MapperMethod> methodCache) {
        this.sqlSession = sqlSession;
        this.mapperInterface = mapperInterface;
        this.methodCache = methodCache;
    }

    //InvocationHandler核心方法，JDK动态代理核心入口
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        try {
            //不代理Object的方法
            if (Object.class.equals(method.getDeclaringClass())) {
                return method.invoke(this, args);
            } else if (isDefaultMethod(method)) {
                return invokeDefaultMethod(proxy, method, args);
            }
        } catch (Throwable t) {
            throw ExceptionUtil.unwrapThrowable(t);
        }
        //实现SQL逻辑的核心，可以看到，所有通过Mapper的Java接口方法的操作最终都会转化为MapperMethod方法的调用
        final MapperMethod mapperMethod = cachedMapperMethod(method);
        return mapperMethod.execute(sqlSession, args);
    }

    private MapperMethod cachedMapperMethod(Method method) {
        MapperMethod mapperMethod = methodCache.get(method);
        if (mapperMethod == null) {
            mapperMethod = new MapperMethod(mapperInterface, method, sqlSession.getConfiguration());
            methodCache.put(method, mapperMethod);
        }
        return mapperMethod;
    }

    @UsesJava7
    private Object invokeDefaultMethod(Object proxy, Method method, Object[] args)
            throws Throwable {
        final Constructor<MethodHandles.Lookup> constructor = MethodHandles.Lookup.class
                .getDeclaredConstructor(Class.class, int.class);
        if (!constructor.isAccessible()) {
            constructor.setAccessible(true);
        }
        final Class<?> declaringClass = method.getDeclaringClass();
        return constructor
                .newInstance(declaringClass,
                        MethodHandles.Lookup.PRIVATE | MethodHandles.Lookup.PROTECTED
                                | MethodHandles.Lookup.PACKAGE | MethodHandles.Lookup.PUBLIC)
                .unreflectSpecial(method, declaringClass).bindTo(proxy).invokeWithArguments(args);
    }

    /**
     * Backport of java.lang.reflect.Method#isDefault()
     */
    private boolean isDefaultMethod(Method method) {
        return ((method.getModifiers()
                & (Modifier.ABSTRACT | Modifier.PUBLIC | Modifier.STATIC)) == Modifier.PUBLIC)
                && method.getDeclaringClass().isInterface();
    }
}
```

我们关注一下invoke方法的逻辑

1. 不代理Object的方法
1. 所有Mapper的Java接口方法的调用，最终都转化为MapperMethod方法的调用。因此所有SQL核心逻辑的实现，被封装在MapperMethod中

接着，我们看一下MapperMethod的构造方法

```java
    private final SqlCommand command;
    private final MethodSignature method;

    public MapperMethod(Class<?> mapperInterface, Method method, Configuration config) {
        this.command = new SqlCommand(config, mapperInterface, method);
        this.method = new MethodSignature(config, mapperInterface, method);
    }
```

MapperMethod的构造方法初始化了两个字段，其类型为SqlCommand和MethodSignature，这两个类是MapperMethod的静态内部类

SqlCommand如下，该类的主要作用就是获取一条SQL语句的名字（映射器`namespace.id`）以及SQL的类型（SELECT、INSERT等）

```java
    public static class SqlCommand {

        private final String name;
        private final SqlCommandType type;

        public SqlCommand(Configuration configuration, Class<?> mapperInterface, Method method) {
            final String methodName = method.getName();
            final Class<?> declaringClass = method.getDeclaringClass();
            MappedStatement ms = resolveMappedStatement(mapperInterface, methodName, declaringClass,
                    configuration);
            if (ms == null) {
                if (method.getAnnotation(Flush.class) != null) {
                    name = null;
                    type = SqlCommandType.FLUSH;
                } else {
                    throw new BindingException("Invalid bound statement (not found): "
                            + mapperInterface.getName() + "." + methodName);
                }
            } else {
                name = ms.getId();
                type = ms.getSqlCommandType();
                if (type == SqlCommandType.UNKNOWN) {
                    throw new BindingException("Unknown execution method for: " + name);
                }
            }
        }

        public String getName() {
            return name;
        }

        public SqlCommandType getType() {
            return type;
        }

        private MappedStatement resolveMappedStatement(Class<?> mapperInterface, String methodName,
                                                       Class<?> declaringClass, Configuration configuration) {
            String statementId = mapperInterface.getName() + "." + methodName;
            //在Configuration对象初始化的过程中，会从映射器配置文件中读取MappedStatement，包含了一条SQL语句的各种属性
            if (configuration.hasStatement(statementId)) {
                return configuration.getMappedStatement(statementId);
            } else if (mapperInterface.equals(declaringClass)) {
                return null;
            }
            //尝试沿着结构的继承体系找到定义该方法的接口
            for (Class<?> superInterface : mapperInterface.getInterfaces()) {
                if (declaringClass.isAssignableFrom(superInterface)) {
                    MappedStatement ms = resolveMappedStatement(superInterface, methodName,
                            declaringClass, configuration);
                    if (ms != null) {
                        return ms;
                    }
                }
            }
            return null;
        }
    }
```

MethodSignature如下，该类的主要作用就是封装一个Method（映射器的Java接口的方法）的各类信息，**还包含了一个重要的方法convertArgsToSqlCommandParam，该方法定义了参数的映射方法（参数的传递方式），也是@Param注解生效的地方**

```java
    public static class MethodSignature {

        //返回值是一个列表
        private final boolean returnsMany;

        //返回值是一个Map
        private final boolean returnsMap;

        //返回值为空
        private final boolean returnsVoid;
        private final boolean returnsCursor;
        private final Class<?> returnType;
        private final String mapKey;
        private final Integer resultHandlerIndex;
        private final Integer rowBoundsIndex;

        //参数名字解析器
        private final ParamNameResolver paramNameResolver;

        public MethodSignature(Configuration configuration, Class<?> mapperInterface, Method method) {
            Type resolvedReturnType = TypeParameterResolver.resolveReturnType(method, mapperInterface);
            if (resolvedReturnType instanceof Class<?>) {
                this.returnType = (Class<?>) resolvedReturnType;
            } else if (resolvedReturnType instanceof ParameterizedType) {
                this.returnType = (Class<?>) ((ParameterizedType) resolvedReturnType).getRawType();
            } else {
                this.returnType = method.getReturnType();
            }
            this.returnsVoid = void.class.equals(this.returnType);
            this.returnsMany = (configuration.getObjectFactory().isCollection(this.returnType) || this.returnType.isArray());
            this.returnsCursor = Cursor.class.equals(this.returnType);
            this.mapKey = getMapKey(method);
            this.returnsMap = (this.mapKey != null);
            this.rowBoundsIndex = getUniqueParamIndex(method, RowBounds.class);
            this.resultHandlerIndex = getUniqueParamIndex(method, ResultHandler.class);
            this.paramNameResolver = new ParamNameResolver(configuration, method);
        }

        public Object convertArgsToSqlCommandParam(Object[] args) {
            //对参数进行解析以及封装
            return paramNameResolver.getNamedParams(args);
        }

        public boolean hasRowBounds() {
            return rowBoundsIndex != null;
        }

        public RowBounds extractRowBounds(Object[] args) {
            return hasRowBounds() ? (RowBounds) args[rowBoundsIndex] : null;
        }

        public boolean hasResultHandler() {
            return resultHandlerIndex != null;
        }

        public ResultHandler extractResultHandler(Object[] args) {
            return hasResultHandler() ? (ResultHandler) args[resultHandlerIndex] : null;
        }

        public String getMapKey() {
            return mapKey;
        }

        public Class<?> getReturnType() {
            return returnType;
        }

        public boolean returnsMany() {
            return returnsMany;
        }

        public boolean returnsMap() {
            return returnsMap;
        }

        public boolean returnsVoid() {
            return returnsVoid;
        }

        public boolean returnsCursor() {
            return returnsCursor;
        }

        private Integer getUniqueParamIndex(Method method, Class<?> paramType) {
            Integer index = null;
            final Class<?>[] argTypes = method.getParameterTypes();
            for (int i = 0; i < argTypes.length; i++) {
                if (paramType.isAssignableFrom(argTypes[i])) {
                    if (index == null) {
                        index = i;
                    } else {
                        throw new BindingException(method.getName() + " cannot have multiple " + paramType.getSimpleName() + " parameters");
                    }
                }
            }
            return index;
        }

        private String getMapKey(Method method) {
            String mapKey = null;
            if (Map.class.isAssignableFrom(method.getReturnType())) {
                final MapKey mapKeyAnnotation = method.getAnnotation(MapKey.class);
                if (mapKeyAnnotation != null) {
                    mapKey = mapKeyAnnotation.value();
                }
            }
            return mapKey;
        }
    }
```

paramNameResolver是一个非常重要的字段，其类型是ParamNameResolver。SQL上下文参数的解析与传递就依赖于这个对象，我们看下这个类是如何实现的

```java
public class ParamNameResolver {

    //通用参数名前缀
    private static final String GENERIC_NAME_PREFIX = "param";

    /**
     * <p>
     * The key is the index and the value is the name of the parameter.<br />
     * The name is obtained from {@link Param} if specified. When {@link Param} is not specified,
     * the parameter index is used. Note that this index could be different from the actual index
     * when the method has special parameters (i.e. {@link RowBounds} or {@link ResultHandler}).
     * </p>
     * <ul>
     * <li>aMethod(@Param("M") int a, @Param("N") int b) -&gt; {{0, "M"}, {1, "N"}}</li>
     * <li>aMethod(int a, int b) -&gt; {{0, "0"}, {1, "1"}}</li>
     * <li>aMethod(int a, RowBounds rb, int b) -&gt; {{0, "0"}, {2, "1"}}</li>
     * </ul>
     */
    //该字段用于存放参数键值对，key为参数在参数列表中的位置，value为参数名（如果有@Param修饰，那就是@Param修饰的名字；否则就是"0"、"1"、"2"这样的字符串）
    private final SortedMap<Integer, String> names;

    private boolean hasParamAnnotation;

    public ParamNameResolver(Configuration config, Method method) {
        final Class<?>[] paramTypes = method.getParameterTypes();
        final Annotation[][] paramAnnotations = method.getParameterAnnotations();
        final SortedMap<Integer, String> map = new TreeMap<Integer, String>();
        int paramCount = paramAnnotations.length;
        //get names from @Param annotations
        for (int paramIndex = 0; paramIndex < paramCount; paramIndex++) {
            if (isSpecialParameter(paramTypes[paramIndex])) {
                //skip special parameters
                continue;
            }
            String name = null;

            //查看当前参数是否被@Param注解修饰
            for (Annotation annotation : paramAnnotations[paramIndex]) {
                if (annotation instanceof Param) {
                    hasParamAnnotation = true;
                    //如果当前参数被@Param注解修饰，那么名字为@Param注解设定的名字
                    name = ((Param) annotation).value();
                    break;
                }
            }
            //如果当前参数没有被@Param注解修饰
            if (name == null) {
                //@Param was not specified.
                //这里尝试从Method对象获取参数名字，一般通过反射获取到的参数名字是arg0，arg1，arg2等等
                if (config.isUseActualParamName()) {
                    name = getActualParamName(method, paramIndex);
                }

                //用"0"，"1"，"2"作为参数的名字
                if (name == null) {
                    //use the parameter index as the name ("0", "1", ...)
                    //gcode issue #71
                    name = String.valueOf(map.size());
                }
            }
            map.put(paramIndex, name);
        }
        names = Collections.unmodifiableSortedMap(map);
    }

    //通过反射获取参数的名字，一般而言，参数名字是arg0，arg1，arg2等等
    private String getActualParamName(Method method, int paramIndex) {
        if (Jdk.parameterExists) {
            return ParamNameUtil.getParamNames(method).get(paramIndex);
        }
        return null;
    }

    //是否被占位符标记
    private static boolean isSpecialParameter(Class<?> clazz) {
        return RowBounds.class.isAssignableFrom(clazz) || ResultHandler.class.isAssignableFrom(clazz);
    }

    /**
     * Returns parameter names referenced by SQL providers.
     */
    public String[] getNames() {
        return names.values().toArray(new String[0]);
    }

    /**
     * <p>
     * A single non-special parameter is returned without a name.<br />
     * Multiple parameters are named using the naming rule.<br />
     * In addition to the default names, this method also adds the generic names (param1, param2,
     * ...).
     * </p>
     */
    //进行参数解析以及封装的核心方法
    public Object getNamedParams(Object[] args) {
        final int paramCount = names.size();
        if (args == null || paramCount == 0) {
            return null;
        } 
        //如果参数没有@Param标记，且参数只有1个
        else if (!hasParamAnnotation && paramCount == 1) {
            //直接透传，不进行封装
            return args[names.firstKey()];
        } 
        //参数多余一个，或者参数被@Param标记
        else {
            //将参数封装成一个Map
            final Map<String, Object> param = new MapperMethod.ParamMap<Object>();
            int i = 0;
            for (Map.Entry<Integer, String> entry : names.entrySet()) {
                //对于有@Param修饰的参数而言，键值就是@Param注解的值
                //对于没有@Param修饰的参数而言，键值一般就是"argi"，其中i是当前参数在参数列表中的位置，i从0计算
                //极少情况下，键值是"0"，"1"，"2"...。产生这种键值的原因是没有@Param注解修饰，且通过反射拿不到参数名
                param.put(entry.getValue(), args[entry.getKey()]);

                //add generic param names (param1, param2, ...)
                //另外，为每个参数添加param1、param2这样的参数，数字从1开始计算
                final String genericParamName = GENERIC_NAME_PREFIX + String.valueOf(i + 1);
                //ensure not to overwrite parameter named with @Param
                if (!names.containsValue(genericParamName)) {
                    param.put(genericParamName, args[entry.getKey()]);
                }
                i++;
            }
            return param;
        }
    }
}
```

**参数映射规则**

1. 如果只有一个参数，且**没有**@Param注解修饰，那么将参数透传，不将其封装成Map
1. 如果有多个参数，或者至少有一个参数被@Param注解修饰，那么将参数封装成Map
    * 若参数有@Param修饰，添加以`@Param的值作为key`的参数键值对
    * 若参数没有@Param修饰，添加以`argi`或`i`（大概率是`argi`）作为key的参数键值对（i是参数的位置，从0开始计算，具体逻辑详见`ParamNameResolver`的构造方法）
    * 无论是否有@Param修饰，添加`param1`、`param2`作为key的参数（注意，从1开始计算，具体逻辑详见`MethodSignature.convertArgsToSqlCommandParam`方法以及`ParamNameResolver.getNamedParams`方法）

接下来，我们看一下MapperMethod.execute方法

```java
    public Object execute(SqlSession sqlSession, Object[] args) {
        Object result;
        switch (command.getType()) {
            case INSERT: {
                //解析参数，并对参数进行封装
                Object param = method.convertArgsToSqlCommandParam(args);

                //转调用了sqlSession的insert方法，即iBatis的方式，并对结果进行了包装
                result = rowCountResult(sqlSession.insert(command.getName(), param));
                break;
            }
            case UPDATE: {
                //解析参数，并对参数进行封装
                Object param = method.convertArgsToSqlCommandParam(args);

                //转调用了sqlSession的update方法，即iBatis的方式，并对结果进行了包装
                result = rowCountResult(sqlSession.update(command.getName(), param));
                break;
            }
            case DELETE: {
                //解析参数，并对参数进行封装
                Object param = method.convertArgsToSqlCommandParam(args);

                //转调用了sqlSession的delete方法，即iBatis的方式，并对结果进行了包装
                result = rowCountResult(sqlSession.delete(command.getName(), param));
                break;
            }
            case SELECT:
                if (method.returnsVoid() && method.hasResultHandler()) {
                    executeWithResultHandler(sqlSession, args);
                    result = null;
                } else if (method.returnsMany()) {
                    //里面仍然转调用了sqlSession的相关方法
                    result = executeForMany(sqlSession, args);
                } else if (method.returnsMap()) {
                    //里面仍然转调用了sqlSession的相关方法
                    result = executeForMap(sqlSession, args);
                } else if (method.returnsCursor()) {
                    //里面仍然转调用了sqlSession的相关方法
                    result = executeForCursor(sqlSession, args);
                } else {
                    Object param = method.convertArgsToSqlCommandParam(args);
                    result = sqlSession.selectOne(command.getName(), param);
                }
                break;
            case FLUSH:
                result = sqlSession.flushStatements();
                break;
            default:
                throw new BindingException("Unknown execution method for: " + command.getName());
        }
        if (result == null && method.getReturnType().isPrimitive() && !method.returnsVoid()) {
            throw new BindingException("Mapper method '" + command.getName()
                    + " attempted to return null from a method with a primitive return type (" + method.getReturnType() + ").");
        }
        return result;
    }
```

**这里，每种SQL的操作流程如下**

1. 首先，通过MethodSignature.convertArgsToSqlCommandParam方法进行参数映射
1. 然后通过iBatis的接口进行SQL操作

# 5 SQL操作的执行

由上述分析可知，MyBatis只不过在iBatis的基础之上进行了一层抽象与封装，最终实际的SQL操作的核心逻辑还是落在iBatis中，这部分内容下次再补充！

## 5.1 todo

1. `_parameter`字符串，出现在`TextSqlNode`以及`DynamicContext`中
1. DynamicSqlSource
1. 生成占位符MappedStatement.getBoundSql
1. 执行真正的SQL在SimpleExecutor.doUpdate中执行
1. 参数的绑定发生在SimpleExecutor.doUpdate
