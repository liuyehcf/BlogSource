---
title: Druid-Demo
date: 2019-01-18 09:17:36
tags: 
- 原创
categories: 
- Java
- Framework
- Druid
---

__阅读更多__

<!--more-->

# 1 Slf4jLogFilter

__Slf4jLogFilter的日志级别都是DEBUG的__

```Java
@Bean
    public Slf4jLogFilter logFilter() {
        Slf4jLogFilter filter = new Slf4jLogFilter();
        filter.setDataSourceLogger(LOGGER);
        filter.setStatementLogger(LOGGER);
        filter.setConnectionLogger(LOGGER);
        filter.setResultSetLogger(LOGGER);

//        filter.setStatementLogEnabled(false);
//        filter.setStatementParameterClearLogEnable(false);
//        filter.setStatementLogErrorEnabled(false);
//        filter.setStatementCreateAfterLogEnabled(false);
//        filter.setStatementCloseAfterLogEnabled(false);
//        filter.setStatementPrepareCallAfterLogEnabled(false);
//        filter.setStatementParameterClearLogEnable(false);
//        filter.setStatementParameterSetLogEnabled(false);
//        filter.setStatementExecuteAfterLogEnabled(false);
//        filter.setStatementExecuteBatchAfterLogEnabled(false);
//        filter.setStatementExecuteUpdateAfterLogEnabled(false);
//        filter.setStatementExecutableSqlLogEnable(true);
//        filter.setStatementExecuteQueryAfterLogEnabled(false);
//
//        filter.setConnectionLogEnabled(false);
//        filter.setConnectionLogErrorEnabled(false);
//        filter.setConnectionConnectBeforeLogEnabled(false);
//        filter.setConnectionCloseAfterLogEnabled(false);
//        filter.setConnectionCommitAfterLogEnabled(false);
//        filter.setConnectionConnectAfterLogEnabled(false);
//        filter.setConnectionRollbackAfterLogEnabled(false);
//
//        filter.setDataSourceLogEnabled(false);
//
//        filter.setResultSetLogEnabled(false);
//        filter.setResultSetOpenAfterLogEnabled(false);
//        filter.setResultSetLogErrorEnabled(false);
//        filter.setResultSetCloseAfterLogEnabled(false);
//        filter.setResultSetNextAfterLogEnabled(false);

        return filter;
    }
```

# 2 StatFilter 

StatFilter 与 Slf4jLogFilter 无关，StatFilter有自己的Logger，即

```Java
public class StatFilter extends FilterEventAdapter implements StatFilterMBean {

    private final static Log          LOG                        = LogFactory.getLog(StatFilter.class);
}
```

示例

```Java
    @Bean
    public StatFilter statFilter() {
        StatFilter statFilter = new StatFilter();
        statFilter.setLogSlowSql(true);
        statFilter.setSlowSqlMillis(50);
        statFilter.setMergeSql(true);
        return statFilter;
    }

    @Bean
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/test");
        dataSource.setUsername("liuye");
        dataSource.setPassword("123456");
        dataSource.setMaxActive(50);
        dataSource.setMaxWait(3000);
        dataSource.setProxyFilters(Collections.singletonList(statFilter()));
        return dataSource;
    }
```

# 3 参考

* [druid-github-配置_LogFilter](https://github.com/alibaba/druid/wiki/%E9%85%8D%E7%BD%AE_LogFilter)
* [Druid中使用log4j2进行日志输出(2018)](https://blog.csdn.net/q343509740/article/details/80577091)
* [druid日志logback.xml配置只记录sql和时间](https://blog.csdn.net/yan061322/article/details/64130891)
