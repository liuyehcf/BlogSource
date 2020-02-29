---
title: Java-Apache-HttpClient
date: 2019-06-23 14:08:28
tags: 
- 原创
categories: 
- Java
- JMH
---

__阅读更多__

<!--more-->

# 1 Maven依赖

```xml
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
            <version>4.5.5</version>
        </dependency>
```

# 2 重试机制

```java
    private static final HttpClient HTTP_CLIENT = HttpClientBuilder.create()
            .setRetryHandler((IOException exception, int executionCount, HttpContext context) -> {
                if (executionCount > 3) {
                    return false;
                }
                return exception instanceof NoHttpResponseException || exception instanceof ConnectTimeoutException;
            })
            .build();

```

# 3 超时设置

```java
    HttpRequestBase request = new HttpGet();

    RequestConfig config = RequestConfig.custom()
            .setConnectTimeout(3000).setConnectionRequestTimeout(1000)
            .setSocketTimeout(5000).build();
    
    request.setConfig(config);
```

# 4 参考

* [HttpClient超时设置详解](https://blog.csdn.net/u011191463/article/details/78664896)
