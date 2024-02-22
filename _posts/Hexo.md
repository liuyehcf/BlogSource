---
title: Hexo
date: 2017-09-24 15:15:58
mathjax: true
tags: 
- 摘录
categories: 
- Hexo
---

**阅读更多**

<!--more-->

# 1 Hexo related projects

| 项目 | 描述 |
|:--|:--|
| [theme-yilia](https://github.com/litten/hexo-theme-yilia) | hexo主题 |
| [theme-next](https://github.com/theme-next/hexo-theme-next) | hexo主题 |
| [hexo-filter-sequence](https://github.com/bubkoo/hexo-filter-sequence) | hexo插件-序列图 |
| [hexo-filter-mermaid-diagrams](https://github.com/webappdevelp/hexo-filter-mermaid-diagrams) | hexo插件-序列图 |
| [hexo-filter-plantuml](https://github.com/wafer-li/hexo-filter-plantuml) | hexo插件-高级时序图 |
| [hexo-filter-flowchart](https://github.com/bubkoo/hexo-filter-flowchart) | hexo插件-流程图 |
| [hexo-simple-mindmap](https://github.com/HunterXuan/hexo-simple-mindmap) | hexo插件-思维导图 |
| [hexo-markmap](https://github.com/MaxChang3/hexo-markmap) | hexo插件-思维导图 |
| [hexo-toc](https://github.com/bubkoo/hexo-toc) | hexo插件-目录 |
| [hexo-wordcount](https://github.com/willin/hexo-wordcount) | hexo插件-字数统计 |
| [hexo-symbols-count-time](https://github.com/theme-next/hexo-symbols-count-time) | 阅读时间统计 |

# 2 markdown-renderer

[Hexo的多种Markdown渲染器对比分析](https://bugwz.com/2019/09/17/hexo-markdown-renderer/#2-4-hexo-renderer-markdown-it)

更换markdown渲染引擎，默认的是`hexo-renderer-marked`，换成`hexo-renderer-markdown-it-plus`（我更换渲染引擎的原因是，默认的引擎在更新之后，对加粗的支持反而变弱了，比如`测试**加粗**测试`）

```sh
# 卸载默认的渲染引擎
npm uninstall hexo-renderer-marked

# 安装新的渲染引擎
npm install hexo-renderer-markdown-it-plus
```

更换后会导致latex中无法通过`\\`进行换行，可以通过使用`\begin{split}`和`\end{split}`

```
$$
\begin{split}
&first \\
&second
\end{split}
$$
```

效果如下

{% raw %}$$\begin{split}
&first \\
&second
\end{split}$${% endraw %}

# 3 Math

[Hexo渲染LaTeX公式](https://www.jianshu.com/p/9b9c241146bc)

[MathJax-配置](http://theme-next.iissnan.com/third-party-services.html#mathjax)

**禁止markdown对`-`、`\\`、`\{`、`\}`等进行转义**：修改配置文件`node_modules/marked/lib/marked.js`

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
em: /^\b_((?:[^_]|**)+?)_\b|^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

替换为

```
em: /^\*((?:\*\*|[\s\S])+?)\*(?!\*)/,
```

## 3.1 Latex

[LaTeX 格式、字母、符号、公式 （总结）](https://blog.csdn.net/CareChere/article/details/115939268)

# 4 Livere Comment System

[来必力-配置](http://theme-next.iissnan.com/third-party-services.html#livere)

# 5 mermaid

[hexo-filter-mermaid-diagrams](https://github.com/webappdevelp/hexo-filter-mermaid-diagrams)

**步骤1：安装插件**

```sh
npm install hexo-filter-mermaid-diagrams --save
```

**步骤2：修改主题配置文件`themes/next/_config.yml`，找到`mermaid`的配置项，将`enable`改为true即可**

用法参考{% post_link Markdown %}

# 6 plantuml

**Doc：[plantuml doc](http://plantuml.com/sequence-diagram)**

**步骤1：安装插件**

```sh
npm install hexo-filter-plantuml --save
```

## 6.1 Example

**源码：**

```
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}

actor User
box "foo1"
participant "First Class" as A
end box
box "foo2"
participant "Second Class" as B
end box
box "foo3"
participant "Last Class" as C
end box

User -> A: DoWork
activate A

A -> B: Create Request
activate B

B -> C: DoWork
activate C
C --> B: WorkDone
destroy C

B --> A: Request Created
deactivate B

A --> User: Done
deactivate A
```

**渲染后：**

```plantuml
skinparam backgroundColor #EEEBDC
skinparam handwritten true

skinparam sequence {
	ArrowColor DeepSkyBlue
	ActorBorderColor DeepSkyBlue
	LifeLineBorderColor blue
	LifeLineBackgroundColor #A9DCDF
	
	ParticipantBorderColor DeepSkyBlue
	ParticipantBackgroundColor DodgerBlue
	ParticipantFontName Impact
	ParticipantFontSize 17
	ParticipantFontColor #A9DCDF
	
	ActorBackgroundColor aqua
	ActorFontColor DeepSkyBlue
	ActorFontSize 17
	ActorFontName Aapex
}

actor User
box "foo1"
participant "First Class" as A
end box
box "foo2"
participant "Second Class" as B
end box
box "foo3"
participant "Last Class" as C
end box

User -> A: DoWork
activate A

A -> B: Create Request
activate B

B -> C: DoWork
activate C
C --> B: WorkDone
destroy C

B --> A: Request Created
deactivate B

A --> User: Done
deactivate A
```

# 7 sequence

[hexo-filter-sequence](https://github.com/bubkoo/hexo-filter-sequence)

# 8 mindmap

## 8.1 simple-mindmap

[hexo-simple-mindmap](https://github.com/HunterXuan/hexo-simple-mindmap)

**示例：**

```
{% pullquote mindmap mindmap-md %}
- Test A
    - Test a
        - Test 1
        - Test 2
    - Test b
        - Test 3
        - Test 4
- Test B
    - Test c
        - Test 5
        - Test 6
    - Test d
        - Test 7
        - Test 8
{% endpullquote %}
```

**效果：**

{% pullquote mindmap mindmap-md %}
- Test A
    - Test a
        - Test 1
        - Test 2
    - Test b
        - Test 3
        - Test 4
- Test B
    - Test c
        - Test 5
        - Test 6
    - Test d
        - Test 7
        - Test 8
{% endpullquote %}

## 8.2 markmap

[hexo-markmap](https://github.com/MaxChang3/hexo-markmap)

**示例：**

```
{% markmap %}
- Test A
    - Test a
        - Test 1
        - Test 2
    - Test b
        - Test 3
        - Test 4
- Test B
    - Test c
        - Test 5
        - Test 6
    - Test d
        - Test 7
        - Test 8
{% endmarkmap %}
```

**效果：**

{% markmap %}
- Test A
    - Test a
        - Test 1
        - Test 2
    - Test b
        - Test 3
        - Test 4
- Test B
    - Test c
        - Test 5
        - Test 6
    - Test d
        - Test 7
        - Test 8
{% endmarkmap %}

# 9 Directory

[hexo-toc](https://github.com/bubkoo/hexo-toc)

# 10 Access Statistics

[阅读次数统计-配置](http://theme-next.iissnan.com/third-party-services.html#analytics-tencent-mta)

[解决使用LEANCLOUD配置NEXT主题文章浏览量显示不正常的问题](https://www.freesion.com/article/6399428835/)

[Hexo Next主题 使用LeanCloud统计文章阅读次数、添加热度排行页面](https://blog.qust.cc/archives/48665.html)

编辑`主题`配置文件

1. 关闭`leancloud_visitors`配置
    * `enable`置为false
1. 打开`valine`配置
    * `enable`设置为true
    * 配置`appid`以及`appkey`
    * `visitor`设置为true

编辑`站点`配置文件

```yaml
deploy:
...
- type: leancloud_counter_security_sync
...

leancloud_counter_security:
  enable_sync: true # 先关了，开启有问题，总是报 Too many requests. [429 GET https://qhehlume.api.lncld.net/1.1/classes/Counter]
  app_id: xxx
  app_key: xxx
  server_url: https://leancloud.cn # 内地region需要配置这个
  username: 'liuyehcf'
  password: '19990101' # 究极大坑，这里需要用引号
```

# 11 Local Search

```sh
npm install hexo-generator-searchdb --save
```

[本地搜索-配置](http://theme-next.iissnan.com/third-party-services.html#local-search)

[搜索失效](https://www.v2ex.com/amp/t/298727)

[Mac 上的 VSCode 编写 Markdown 总是出现隐藏字符？](https://www.zhihu.com/question/61638859)

## 11.1 How to title-only search?

For theme next, we can modify `source/js/local-search.js` like this:

```diff
@@ -91,6 +91,7 @@ document.addEventListener('DOMContentLoaded', () => {
   const inputEventFunction = () => {
     if (!isfetched) return;
     let searchText = input.value.trim().toLowerCase();
+    let onlyTitle = searchText.startsWith('title:');
     let keywords = searchText.split(/[-\s]+/);
     if (keywords.length > 1) {
       keywords.push(searchText);
@@ -106,7 +107,9 @@ document.addEventListener('DOMContentLoaded', () => {
         let searchTextCount = 0;
         keywords.forEach(keyword => {
           indexOfTitle = indexOfTitle.concat(getIndexByWord(keyword, titleInLowerCase, false));
-          indexOfContent = indexOfContent.concat(getIndexByWord(keyword, contentInLowerCase, false));
+          if (!onlyTitle) {
+            indexOfContent = indexOfContent.concat(getIndexByWord(keyword, contentInLowerCase, false));
+          }
         });

         // Show search results
```

# 12 Background Animation

[背景动画-配置](http://theme-next.iissnan.com/theme-settings.html#use-bg-animation)

# 13 Add Menu Bar

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

# 14 Disable Sidebar Numbering

主题配置文件修改如下配置，将number改为false即可

```sh
toc:
  enable: true

  # Automatically add list number to toc.
  number: false 

  # If true, all words will placed on next lines if header width longer then sidebar width.
  wrap: false
```

# 15 Modify Inline Code Style

修改方式（这个方式在最新的next版本中好像失效了）：在`themes/next/source/css/_custom/custom.styl`中增加如下代码

```css
// Custom styles.
code {
    color: #C33258;
    background: #F9F2F4;
    margin: 2px;
}
```

修改方式：在`themes/next/source/css/_common/scaffolding/highlight/highlight.styl`中修改`code`的样式定义

```css
// Custom styles.
code {
    color: #C33258;
    background: #F9F2F4;
    margin: 2px;
}
```

# 16 Modify Link Style

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

# 17 Adjust Font Size in the NexT Theme

文件相对路径：`themes/next/source/css/_variables/base.styl`

将`Font size`以及`Headings font size`部分的配置修改成如下内容

```
// Font size
$font-size-base           = 14px
$font-size-base           = unit(hexo-config('font.global.size'), px) if hexo-config('font.global.size') is a 'unit'
$font-size-small          = $font-size-base - 2px
$font-size-smaller        = $font-size-base - 4px
$font-size-large          = $font-size-base + 2px
$font-size-larger         = $font-size-base + 4px

// Headings font size
$font-size-headings-step    = 2px
$font-size-headings-base    = 24px
$font-size-headings-base    = unit(hexo-config('font.headings.size'), px) if hexo-config('font.headings.size') is a 'unit'
$font-size-headings-small   = $font-size-headings-base - $font-size-headings-step
$font-size-headings-smaller = $font-size-headings-small - $font-size-headings-step
$font-size-headings-large   = $font-size-headings-base + $font-size-headings-step
$font-size-headings-larger  = $font-size-headings-large + $font-size-headings-step
```

# 18 Pin Post

```sh

npm uninstall hexo-generator-index --save
npm install hexo-generator-index-pin-top --save
```

然后在文章的header中加上`top:true`即可，例如

```
---
title: test
tags:
  - test
categories:
  - test
date: 2021-09-11 11:45:59
top: true
---
```

# 19 Deploy

```sh
npm install hexo-deployer-git --save
```

[nodejs更新后hexo没法deploy](https://blog.csdn.net/qq_41535611/article/details/106309335)

# 20 Config Migration

1. 参考[hexo-README](https://github.com/hexojs/hexo)，安装`hexo`
1. 参考[theme-next-README](https://github.com/theme-next/hexo-theme-next)，安装`hexo`主题`theme-next`
1. 在老电脑上查看`theme-next`的修改项，将改动应用于新电脑，由于新老电脑`theme-next`的版本可能不一致，所以可能存在一些差异，看情况调整即可
1. 修改站点配置文件，该文件没有被git仓库管理，修改前备份一下。并根据老电脑上的改动项依次调整即可，主要包含如下几个配置
    * title
    * description
    * author
    * language
    * theme
    * deploy
    * search

# 21 参考

* [next官方文档](http://theme-next.iissnan.com/getting-started.html)
* [搭建一个支持LaTEX的hexo博客](http://blog.csdn.net/emptyset110/article/details/50123231)
* [用 Hexo 搭建个人博客-02：进阶试验](http://www.jianshu.com/p/6c1196f12302)
* [Hexo文章简单加密访问](https://www.jianshu.com/p/a2330937de6c)
* [hexo的next主题个性化配置教程](https://segmentfault.com/a/1190000009544924)
* [icon库](https://fontawesome.com/icons?d=gallery)
* [Leancloud访客统计插件重大安全漏洞修复指南](https://leaferx.online/2018/02/11/lc-security/)
* [hexo的next主题个性化教程:打造炫酷网站](http://shenzekun.cn/hexo%E7%9A%84next%E4%B8%BB%E9%A2%98%E4%B8%AA%E6%80%A7%E5%8C%96%E9%85%8D%E7%BD%AE%E6%95%99%E7%A8%8B.html)
* [hexo-filter-plantuml](https://github.com/wafer-li/hexo-filter-plantuml)
* [Hexo中引入Mermaid流程图](https://tyloafer.github.io/posts/7790/)
* [如何解决next5主题目录无法跳转的问题](https://www.cnblogs.com/Createsequence/p/14150758.html)
