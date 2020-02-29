---
title: HttpURLConnection-简介
date: 2017-12-15 20:20:11
tags: 
- 原创
categories: 
- Java
- Framework
- HTTP
---

__阅读更多__

<!--more-->

# 1 GET方法

__代码清单如下__

```java
    public static void doGet(String value1, String value2, String operator) {
        try {
            URL url = new URL("http://localhost:8080/compute?value1=" + value1 + "&value2=" + value2);//(1)

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();//(2)
            conn.setRequestMethod("GET");//(3)
            conn.setRequestProperty("operator", operator);//(4)
            conn.setDoInput(true);//(5)

            conn.connect();//(6)

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));//(7)
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        } catch (MalformedURLException e) {
            System.err.println("URL初始化错误");
            e.printStackTrace(System.err);
        } catch (IOException e) {
            System.err.println("数据流错误");
            e.printStackTrace(System.err);
        }
    }
```

__详细步骤分析__

1. 创建URL对象，将String类型的URL转为URL类型
1. 利用URL对象创建URLConnection对象，并转型为HttpURLConnection
1. 设置方法类型为`GET`，可以不写，默认方法就是`GET`
1. 设置自定义的Header键值对
1. 打开输入流，用于读取返回的响应数据，默认打开，可以不写
1. 进行连接，也可以不写，`getInputStream()`/`getOutputStream()`等操作会隐式进行连接操作
1. 获取输入流，用于读取返回的响应数据

# 2 POST方法

__代码清单如下__

```java
    public static void doPost() {
        try {
            URL url = new URL("http://localhost:8080/login");//(1)

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();//(2)
            conn.setRequestMethod("POST");//(3)
            conn.setRequestProperty("Content-Type", "application/json");//(4)
            conn.setDoInput(true);//(5)
            conn.setDoOutput(true);//(5)

            conn.connect();//(6)

            String requestBody = "{\"name\":\"张三\",\"password\":\"123456789\"}";
            PrintWriter out = new PrintWriter(conn.getOutputStream());
            out.print(requestBody);//(7)
            out.flush();//(8)

            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));//(9)
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line);
            }
        } catch (MalformedURLException e) {
            System.err.println("URL初始化错误");
            e.printStackTrace(System.err);
        } catch (IOException e) {
            System.err.println("数据流错误");
            e.printStackTrace(System.err);
        }
    }
```

__详细步骤分析__

1. 创建URL对象，将String类型的URL转为URL类型
1. 利用URL对象创建URLConnection对象，并转型为HttpURLConnection
1. 设置方法类型为`POST`，不可省略，因为默认的方法是`GET`
1. 设置Header，指定Content（RequestBody）的格式为JSON
1. 打开输入流，以及输出流。输出流用于写入RequestBody，必须写，默认关闭；输入流用于读取返回的响应数据，默认打开，可以不写
1. 进行连接，也可以不写，`getInputStream()`/`getOutputStream()`等操作会隐式进行连接操作
1. 通过`getOutputStream()`获取输出流，传入RequestBody
1. 刷新写缓冲区，将RequestBody传送到到Server端
1. 获取输入流，用于读取返回的响应数据

# 3 HttpURLConnection默认参数

__代码清单__
```java
public class DefaultParameters {
    public static void main(String[] args) {
        try {
            URL url = new URL("http://localhost:8080/home");

            HttpURLConnection conn = (HttpURLConnection) url.openConnection();

            System.out.println("Default RequestMethod: " + conn.getRequestMethod());
            System.out.println("Default doInput: " + conn.getDoInput());
            System.out.println("Default doOutput: " + conn.getDoOutput());

        } catch (MalformedURLException e) {
            System.err.println("URL初始化错误");
            e.printStackTrace(System.err);
        } catch (IOException e) {
            System.err.println("数据流错误");
            e.printStackTrace(System.err);
        }
    }
}
```

__输出如下__

```
Default RequestMethod: GET
Default doInput: true
Default doOutput: false
```

# 4 HttpURLConnection继承结构

![HttpURLConnection](/images/HttpURLConnection-简介/HttpURLConnection.png)

