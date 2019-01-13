---
title: hexo相关
date: 2017-09-24 15:15:58
tags: 
- 摘录
categories: 
- Hexo
---

__阅读更多__

<!--more-->

# 1 Math

[MathJax-配置](http://theme-next.iissnan.com/third-party-services.html#mathjax)

__禁止markdown对`-`、`\\`、`\{`、`\}`等进行转义__：修改配置文件`/node_modules/marked/lib/`

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

# 2 来必力评论系统

[来必力-配置](http://theme-next.iissnan.com/third-party-services.html#livere)

# 3 sequence/flow

[hexo-filter-sequence](https://github.com/bubkoo/hexo-filter-sequence)

[hexo-filter-flowchart](https://github.com/bubkoo/hexo-filter-flowchart)

# 4 目录功能

[hexo-toc](https://github.com/bubkoo/hexo-toc)

# 5 访问统计

[阅读次数统计-配置](http://theme-next.iissnan.com/third-party-services.html#analytics-tencent-mta)

# 6 本地搜索

[本地搜索-配置](http://theme-next.iissnan.com/third-party-services.html#local-search)

[搜索失效](https://www.v2ex.com/amp/t/298727)

[Mac 上的 VSCode 编写 Markdown 总是出现隐藏字符？](https://www.zhihu.com/question/61638859)

# 7 背景动画

[背景动画-配置](http://theme-next.iissnan.com/theme-settings.html#use-bg-animation)

# 8 增加菜单

`hexo new page "explore"`

修改主题配置文件`/themes/next/_config.yml`

```
menu:
  home: / || home
  about: /about/ || user
  tags: /tags/ || tags
  categories: /categories/ || th
  archives: /archives/ || archive
  explore: /explore/ || sitemap # 添加这个
```

修改国际化配置文件`/themes/next/languages/_en.yml`

```
menu:
  home: Home
  archives: Archives
  categories: Categories
  tags: Tags
  about: About
  explore: Explore  # 添加这个
  search: Search
  schedule: Schedule
  sitemap: Sitemap
  commonweal: Commonweal 404
```

修改国际化配置文件`/themes/next/languages/zh-CN.yml`

```
menu:
  home: 首页
  archives: 归档
  categories: 分类
  tags: 标签
  about: 关于
  explore: 发现  # 添加这个
  search: 搜索
  schedule: 日程表
  sitemap: 站点地图
  commonweal: 公益404
```

# 9 hexo相关的项目

| 项目 | 描述 |
|:--|:--|
| [theme-yilia](https://github.com/litten/hexo-theme-yilia) | hexo主题 |
| [theme-next](https://github.com/theme-next/hexo-theme-next) | hexo主题 |
| [hexo-filter-sequence](https://github.com/bubkoo/hexo-filter-sequence) | hexo插件-序列图 |
| [hexo-filter-plantuml](https://github.com/wafer-li/hexo-filter-plantuml) | hexo插件-高级时序图 |
| [hexo-filter-flowchart](https://github.com/bubkoo/hexo-filter-flowchart) | hexo插件-流程图 |
| [hexo-toc](https://github.com/bubkoo/hexo-toc) | hexo插件-目录 |
| [hexo-wordcount](https://github.com/willin/hexo-wordcount) | hexo插件-字数统计 |
| [hexo-symbols-count-time](https://github.com/theme-next/hexo-symbols-count-time) | 阅读时间统计 |

# 10 取消侧栏编号

主题配置文件修改如下配置，将number改为false即可

```sh
toc:
  enable: true

  # Automatically add list number to toc.
  number: false 

  # If true, all words will placed on next lines if header width longer then sidebar width.
  wrap: false
```

# 11 修改行内代码样式

修改方式：在`themes/next/source/css/_custom/custom.styl`中增加如下代码

```css
// Custom styles.
code {
    color: #C33258;
    background: #F9F2F4;
    margin: 2px;
}
```

# 12 修改链接样式

链接即如下的语法

```
{% post_link <文章名> %}
[description](url)
```

修改方式：在`themes\next\source\css\_common\components\post\post.styl`中增加如下代码

```css
// 文章链接文本样式
.post-body p a{
  color: #0593d3;
  border-bottom: none;
  border-bottom: 1px solid #0593d3;
  &:hover {
    color: #fc6423;
    border-bottom: none;
    border-bottom: 1px solid #fc6423;
  }
}
```

# 13 参考

* [next官方文档](http://theme-next.iissnan.com/getting-started.html)
* [搭建一个支持LaTEX的hexo博客](http://blog.csdn.net/emptyset110/article/details/50123231)
* [用 Hexo 搭建个人博客-02：进阶试验](http://www.jianshu.com/p/6c1196f12302)
* [Hexo文章简单加密访问](https://www.jianshu.com/p/a2330937de6c)
* [hexo的next主题个性化配置教程](https://segmentfault.com/a/1190000009544924)
* [icon库](https://fontawesome.com/icons?d=gallery)
* [Leancloud访客统计插件重大安全漏洞修复指南](https://leaferx.online/2018/02/11/lc-security/)
* [hexo的next主题个性化教程:打造炫酷网站](http://shenzekun.cn/hexo%E7%9A%84next%E4%B8%BB%E9%A2%98%E4%B8%AA%E6%80%A7%E5%8C%96%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B.html)
* [hexo-filter-plantuml](https://github.com/wafer-li/hexo-filter-plantuml)
* [时序图](http://plantuml.com/sequence-diagram)
