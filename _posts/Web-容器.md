---
title: Web-容器
date: 2017-12-30 20:35:20
tags: 
- 摘录
categories: 
- Web
- Service
---

**阅读更多**

<!--more-->

# 1 什么是Web容器？

Servlet没有main方法，那我们如何启动一个Servlet，如何结束一个Servlet，如何寻找一个Servlet等等，都受控于另一个Java应用，这个应用我们就称之为Web容器

我们最常见的Tomcat就是这样一个容器。如果Web服务器应用得到一个指向某个Servlet的请求，此时服务器不是把Servlet交给Servlet本身，而是交给部署该Servlet的容器。要有容器向Servlet提供Http请求和响应，而且要由容器调用Servlet的方法，如doPost或者doGet

# 2 Web容器的作用

Servlet需要由Web容器来管理，那么采取这种机制有什么好处呢？

* **通信支持**：利用容器提供的方法，你可以简单的实现Servlet与Web服务器的对话。否则你就要自己建立server搜创可贴，监听端口，创建新的流等等一系列复杂的操作。而容器的存在就帮我们封装这一系列复杂的操作。使我们能够专注于Servlet中的业务逻辑的实现
* **生命周期管理**：容器负责Servlet的整个生命周期。如何加载类，实例化和初始化Servlet，调用Servlet方法，并使Servlet实例能够被垃圾回收。有了容器，我们就不用花精力去考虑这些资源管理垃圾回收之类的事情
* **多线程支持**：容器会自动为接收的每个Servlet请求创建一个新的Java线程，Servlet运行完之后，容器会自动结束这个线程
* **声明式实现安全**：利用容器，可以使用xml部署描述文件来配置安全性，而不必将其硬编码到Servlet中
* **JSP支持**：容器将JSP翻译成Java！

# 3 参考

* [Web开发中 Web 容器的作用（如tomcat）](https://www.jianshu.com/p/99f34a91aefe)
