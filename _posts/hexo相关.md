---
title: hexo相关
date: 2017-09-24 15:15:58
tags: 
- 摘录
categories: 
- Hexo
---

__目录__

<!-- toc -->
<!--more-->

# 1 支持LaTex

首先安装hexo-math插件

`npm install hexo-math --save`

修改站点配置文件`\_config.yml`，在后面追加以下内容

```
math:
  engine: 'mathjax' # or 'katex'
  mathjax:
    src: custom_mathjax_source
    config:
      # MathJax config
  katex:
    css: custom_css_source
    js: custom_js_source # not used
    config:
      # KaTeX config
```

修改主题配置文件`\themtes\next\_config.yml`，找到`mathjax`项，修改为如下内容

```
mathjax:
  enable: true
  per_page: true # 这里设置为true，则默认关闭渲染，避免渲染所有页面，提高性能
  cdn: // cdn.bootcss.com/mathjax/2.7.1/latest.js?config=TeX-AMS-MML_HTMLorMML
```

在需要公式渲染的页面头部加上`mathjax: true`

```
---
title: hello world
date: 2017-10-14 10:14:56
mathjax: true  # 添加这句
tags: 
...
---
```

禁止markdown对`-`、`\\`、`\{`、`\}`等进行转义，修改配置文件`/node_modules/marked/lib/`

将

```
escape: /^\\([\\`*{}\[\]()# +\-.!_>])/,
```

替换为

```
escape: /^\\([`*\[\]()# +\-.!_>])/,
```

将

```
em: /^\b_((?:[^_]|__)+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

替换为

```
em: /^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

# 2 集成评论系统

1. 注册来必力账号，[来必力官网](https://livere.com/)
1. 获取来必力UID（安装-city版本-在生成的代码中找到uid字段的值）
1. 修改主题配置文件，如下

```
livere_uid: #your livere_uid
```

# 3 集成sequence/flow

[hexo-filter-sequence](https://github.com/bubkoo/hexo-filter-sequence)

`npm install --save hexo-filter-sequence`

[hexo-filter-flowchart](https://github.com/bubkoo/hexo-filter-flowchart)

`npm install --save hexo-filter-flowchart`

# 4 目录功能

[hexo-toc](https://github.com/bubkoo/hexo-toc)

`npm install hexo-toc --save`

# 5 参考

__本篇博客摘录、整理自以下博文。若存在版权侵犯，请及时联系博主(邮箱：liuyehcf#163.com，#替换成@)，博主将在第一时间删除__

* [next官方文档](http://theme-next.iissnan.com/getting-started.html)
* [搭建一个支持LaTEX的hexo博客](http://blog.csdn.net/emptyset110/article/details/50123231)
* [用 Hexo 搭建个人博客-02：进阶试验](http://www.jianshu.com/p/6c1196f12302)
* [Hexo文章简单加密访问](http://blog.csdn.net/Lancelot_Lewis/article/details/53422901)
* [Hexo文章简单加密访问](https://www.jianshu.com/p/a2330937de6c)
