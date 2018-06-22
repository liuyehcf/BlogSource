---
title: IntelliJ-IDEA-Settings
date: 2018-01-12 21:27:58
tags: 
- 原创
categories: 
- IDE
---

__阅读更多__

<!--more-->

# 1 设置选中标识符高亮

1. 打开Preference
1. 搜索`Identifier under caret`，如下图所示：
    * ![fig1](/images/IntelliJ-IDEA-Settings/fig1.jpg)

# 2 自动添加序列化字段

1. `Preference`
1. `Editor`
1. `Inspections`
1. `右边列表选择Java`
1. `Serialization issues`
1. `Java | Serialization issues | Serializable class without 'serialVersionUID'`

# 3 创建类时自动创建作者日期信息

1. `Preference`
1. `Editor`
1. `File and Code Templates`
1. `includes`
1. `File Header`

```Java
/**
 * @author xxx
 * @date ${DATE}
 */
```

# 4 wrong tag 'date'

`alt + enter` -> `add to custom tags`

# 5 参考

* [IntelliJ IDEA 设置选中标识符高亮](http://blog.csdn.net/wskinght/article/details/43052407)
* [IntelliJ IDEA 总结](https://www.zhihu.com/question/20450079)
