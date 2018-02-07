---
title: MyBatis-源码剖析
date: 2018-02-07 08:30:09
tags: 
- 原创
categories: 
- Java
- Framework
- MyBatis
---

__目录__

<!-- toc -->
<!--more-->

# 前言

本文围绕以下几个问题展开对MyBatis源码的研究（不涉及Spring，纯MyBatis）

1. SqlSession如何生成
1. MyBatis如何为我们定义的DAO接口生成实现类
1. DAO接口与映射器的XML文件如何关联
1. DAO接口的实现类如何进行SQL操作

__分析用到的Demo源码详见{% post_link MyBatis-Demo %}__

# SqlSessionFactory生成

__分析起点__

```Java
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
```

MyBatis采用建造者模式来创建SqlSessionFactory，SqlSessionFactoryBuilder就是一个建造者，我们首先来看一下build方法

```Java
    public SqlSessionFactory build(InputStream inputStream) {
        return build(inputStream, null, null);
    }

    public SqlSessionFactory build(InputStream inputStream, String environment, Properties properties) {
        try {
            // 构建配置文件解析器
            XMLConfigBuilder parser = new XMLConfigBuilder(inputStream, environment, properties);

            // parser.parse()将生成Configuration对象
            return build(parser.parse());
        } catch (Exception e) {
            throw ExceptionFactory.wrapException("Error building SqlSession.", e);
        } finally {
            ErrorContext.instance().reset();
            try {
                inputStream.close();
            } catch (IOException e) {
                // Intentionally ignore. Prefer previous error.
            }
        }
    }
```

关于XMLConfigBuilder的构建，这里不做分析，这是XML解析相关的内容。我们接着看一下XMLConfigBuilder.parse方法

```Java
    public Configuration parse() {
        if (parsed) {
            throw new BuilderException("Each XMLConfigBuilder can only be used once.");
        }
        parsed = true;
        // 这里从DOM树中取出相应元素的属性值，初始化configuration
        parseConfiguration(parser.evalNode("/configuration"));

        // 返回Configuration的对象
        return configuration;
    }

    private void parseConfiguration(XNode root) {
        try {
            propertiesElement(root.evalNode("properties")); //issue #117 read properties first
            typeAliasesElement(root.evalNode("typeAliases"));
            pluginElement(root.evalNode("plugins"));
            objectFactoryElement(root.evalNode("objectFactory"));
            objectWrapperFactoryElement(root.evalNode("objectWrapperFactory"));
            settingsElement(root.evalNode("settings"));
            environmentsElement(root.evalNode("environments")); // read it after objectFactory and objectWrapperFactory issue #631
            databaseIdProviderElement(root.evalNode("databaseIdProvider"));
            typeHandlerElement(root.evalNode("typeHandlers"));
            mapperElement(root.evalNode("mappers"));
        } catch (Exception e) {
            throw new BuilderException("Error parsing SQL Mapper Configuration. Cause: " + e, e);
        }
    }
```

XMLConfigBuilder.parse方法从XML的DOM树节点中取出相应的配置项，初始化Configuration，然后返回Configuration的对象。__至此，配置文件的生命周期已经结束，所有的配置信息都保存在了这个Configuration的对象之中__

接着，我们回到SqlSessionFactoryBuilder的build方法中，继续看同名的build方法，该方法返回一个SqlSessionFactory的对象

```Java
    public SqlSessionFactory build(Configuration config) {
        return new DefaultSqlSessionFactory(config);
    }
```

DefaultSqlSessionFactory的构造方法如下

```Java
  private final Configuration configuration;

  public DefaultSqlSessionFactory(Configuration configuration) {
    this.configuration = configuration;
  }
```

至此，SqlSessionFactory的创建工作完毕。简单来说，SqlSessionFactory的初始化过程如下

1. 读取MyBatis的配置文件，封装成Configuration对象
1. 生成SqlSessionFactory接口的实例，该SqlSessionFactory的实例持有这个Configuration对象

# SqlSession生成

__分析起点__

```Java
sqlSession = sqlSessionFactory.openSession();
```

一般而言，SqlSessionFactory的实现类就是DefaultSqlSessionFactory，于是，我们来看一下DefaultSqlSessionFactory的openSession方法

```Java
    public SqlSession openSession() {
        return openSessionFromDataSource(configuration.getDefaultExecutorType(), null, false);
    }
```

该方法从configuration中获取了一个执行器的类型（ExecutorType），这里简单介绍一下执行器的种类（对应着枚举类型ExecutorType）

1. `SIMPLE`：没有什么特别之处
1. `REUSE`：重用预处理语句
1. `BATCH`：执行器重用语句和批量更新

我们继续看openSessionFromDataSource方法，该方法也位于DefaultSqlSessionFactory中

```Java
    private SqlSession openSessionFromDataSource(ExecutorType execType, TransactionIsolationLevel level, boolean autoCommit) {
        Transaction tx = null;
        try {
            // 获取环境配置信息
            final Environment environment = configuration.getEnvironment();

            // 获取事务工厂
            final TransactionFactory transactionFactory = getTransactionFactoryFromEnvironment(environment);

            // 创建事务对象
            tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);

            // 根据配置信息生成执行器
            final Executor executor = configuration.newExecutor(tx, execType, autoCommit);

            // 创建会话
            return new DefaultSqlSession(configuration, executor);
        } catch (Exception e) {
            closeTransaction(tx); // may have fetched a connection so lets call close()
            throw ExceptionFactory.wrapException("Error opening session.  Cause: " + e, e);
        } finally {
            ErrorContext.instance().reset();
        }
    }
```

我们首先来看一下创建事务对象这一步，即`tx = transactionFactory.newTransaction(environment.getDataSource(), level, autoCommit);`

这里这个TransactionFactory的实现类是JdbcTransactionFactory

```Java
    public Transaction newTransaction(DataSource ds, TransactionIsolationLevel level, boolean autoCommit) {
        return new JdbcTransaction(ds, level, autoCommit);
    }
```

接着，我们来看一下JdbcTransaction的类结构（这里列出了所有字段，以及一部分方法）

```Java
public class JdbcTransaction implements Transaction {
    // ...

    // jdbc连接
    protected Connection connection;

    // 数据源
    protected DataSource dataSource;

    // 事务隔离级别
    protected TransactionIsolationLevel level;

    // 是否自动提交
    protected boolean autoCommmit;

    public JdbcTransaction(DataSource ds, TransactionIsolationLevel desiredLevel, boolean desiredAutoCommit) {
        dataSource = ds;
        level = desiredLevel;
        autoCommmit = desiredAutoCommit;
    }

    public Connection getConnection() throws SQLException {
        if (connection == null) {
            openConnection();
        }
        return connection;
    }

    public void commit() throws SQLException {
        if (connection != null && !connection.getAutoCommit()) {
            if (log.isDebugEnabled()) {
                log.debug("Committing JDBC Connection [" + connection + "]");
            }
            connection.commit();
        }
    }

    public void rollback() throws SQLException {
        if (connection != null && !connection.getAutoCommit()) {
            if (log.isDebugEnabled()) {
                log.debug("Rolling back JDBC Connection [" + connection + "]");
            }
            connection.rollback();
        }
    }

    public void close() throws SQLException {
        if (connection != null) {
            resetAutoCommit();
            if (log.isDebugEnabled()) {
                log.debug("Closing JDBC Connection [" + connection + "]");
            }
            connection.close();
        }
    }

    // ...
}
```

可以看到JdbcTransaction依赖于底层的JDBC接口实现事务的相关操作

接着，我们回到DefaultSqlSessionFactory.openSessionFromDataSource方法中，看一下执行器的生成

```Java
    public Executor newExecutor(Transaction transaction, ExecutorType executorType, boolean autoCommit) {
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

        // 是否允许缓存
        if (cacheEnabled) {
            // 将执行器封装成可缓存的执行器
            executor = new CachingExecutor(executor, autoCommit);
        }

        // MyBatis允许我们自定义插件，这里织入插件的逻辑
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

```Java
    public SimpleExecutor(Configuration configuration, Transaction transaction) {
        super(configuration, transaction);
    }

    protected BaseExecutor(Configuration configuration, Transaction transaction) {
        this.transaction = transaction;
        this.deferredLoads = new ConcurrentLinkedQueue<DeferredLoad>();
        this.localCache = new PerpetualCache("LocalCache");
        this.localOutputParameterCache = new PerpetualCache("LocalOutputParameterCache");
        this.closed = false;
        this.configuration = configuration;
    }
```

可以看到，SimpleExecutor的初始化，仅仅做了字段赋值的操作

现在，我们再次回到DefaultSqlSessionFactory.openSessionFromDataSource方法中，看一下SqlSession的创建，这里创建了一个DefaultSqlSession，持有了刚才创建好的Configuration以及Executor对象

```Java
    public DefaultSqlSession(Configuration configuration, Executor executor) {
        this.configuration = configuration;
        this.executor = executor;
        this.dirty = false;
    }
```

至此，SqlSession的创建分析完毕，构建SqlSession之前，需要获取两项内容

1. Configuration对象，这个可以从SqlSessionFactory中获取
1. Executor对象，该对象的创建又依赖于数据库事务对象（Transaction）。所有通过SqlSession执行的SQL操作，最终都会由该Executor对象来执行

# 代理生成

# 映射器绑定

# 参数映射


