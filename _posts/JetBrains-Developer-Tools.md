---
title: JetBrains-Developer-Tools
date: 2017-12-08 23:13:10
tags: 
- 原创
categories: 
- IDE
---

**阅读更多**

<!--more-->

# 1 快捷键

## 1.1 重构

**HotKey Name**：`Refactor This`
**HotKey In Mac**：`⌃T`
**HotKey In Windows**：`Ctrl+Alt+Shift+T`

## 1.2 代码生成

### 1.2.1 模板

**HotKey Name**：`Insert Live Template...`
**HotKey In Mac**：`⌘J`
**HotKey In Windows**：`Ctrl+J`

**常用的几个模板**

1. 生成main函数：`psvm+Tab`
1. 生成for循环模板：`fori+Tab`
1. 生成System.out.println()语句：`sout+Tab`

### 1.2.2 创建

**HotKey Name**：`Generate...`
**HotKey In Mac**：`⌘N`
**HotKey In Windows**：`Alt+Insert`

## 1.3 编辑

### 1.3.1 按语法选择扩张

**HotKey Name**：`Extend Selection`
**HotKey In Mac**：`⌥↑`
**HotKey In Windows**：`Ctrl+W`

### 1.3.2 按语法选择收缩

**HotKey Name**：`Shrink Selection`
**HotKey In Mac**：`⌥↓`
**HotKey In Windows**：`Ctrl+Shitf+W`

### 1.3.3 光标移动到前一个单词

**HotKey Name**：`Move Caret to Previous Word`
**HotKey In Mac**：`⌥←`、`⌥⇧←`
**HotKey In Windows**：`Ctrl+向左箭头`、`Ctrl+Shift+向左箭头`

### 1.3.4 光标移动到后一个单词

**HotKey Name**：`Move Caret to Next Word`
**HotKey In Mac**：`⌥→`、`⌥⇧→`
**HotKey In Windows**：`Ctrl+向右箭头`、`Ctrl+Shift+向右箭头`

### 1.3.5 光标移动到代码块开始处

**HotKey Name**：`Move Caret to Code Block Start`
**HotKey In Mac**：`⌥⌘[`、`⌥⇧⌘[`
**HotKey In Windows**：`Ctrl+左方括号`、`Ctrl+Shift+左方括号`

### 1.3.6 光标移动到代码块结束处

**HotKey Name**：`Move Caret to Code Block End`
**HotKey In Mac**：`⌥⌘]`、`⌥⇧⌘]`
**HotKey In Windows**：`Ctrl+右方括号`、`Ctrl+Shift+右方括号`

## 1.4 导航

### 1.4.1 打开类或资源

**HotKey Name**：`Class...`
**HotKey In Mac**：`⌘O`
**HotKey In Windows**：`Ctrl+N`

### 1.4.2 查找一切

**HotKey Name**：`Search Everywhere`
**HotKey In Mac**：`⇧⇧`
**HotKey In Windows**：`Double Shift`

### 1.4.3 类层次结构

**HotKey Name**：`Type Hierarchy`
**HotKey In Mac**：`⌃H`
**HotKey In Windows**：`Ctrl+H`

### 1.4.4 跳转到方法的定义处

**HotKey Name**：`Declaration`
**HotKey In Mac**：`⌘B`、`⌘Click`
**HotKey In Windows**：`Ctrl+B`、`Ctrl+Click`

### 1.4.5 跳转到方法的实现处

**HotKey Name**：`Implementation(s)`
**HotKey In Mac**：`⌥⌘B`、`⌥⌘Click`
**HotKey In Windows**：`Ctrl+Alt+B`、`Ctrl+Alt+Click`

### 1.4.6 查看当前类的所有方法

**HotKey Name**：`File Structure`
**HotKey In Mac**：`⌘F12`
**HotKey In Windows**：`Ctrl+F12`

### 1.4.7 找到方法的所有使用处

**HotKey Name**：`Find Usages`
**HotKey In Mac**：`⌥F7`
**HotKey In Windows**：`Alt+F7`

### 1.4.8 查找文本

**HotKey Name**：`Find...`、`Find in Path...`
**HotKey In Mac**：`⌘F`、`⇧⌘F`
**HotKey In Windows**：`Ctrl+F`、`Ctrl+Shift+F`

### 1.4.9 在查找的结果中前后移动

**HotKey Name**：`Find Previous / Move to Previous Occurrence`
**HotKey In Mac**：`⌘G`、`⇧⌘G`
**HotKey In Windows**：`F3`/`Ctrl+L`、`Shift+F3`/`Ctrl+Shift+L`

### 1.4.10 查找IntelliJ的命令

**HotKey Name**：`Find Action...`
**HotKey In Mac**：`⇧⌘A`
**HotKey In Windows**：`Ctrl+Shift+A`

### 1.4.11 切换标签页

**HotKey Name**：`Switcher`
**HotKey In Mac**：`⌃Tab`
**HotKey In Windows**：`Ctrl+Tab`

### 1.4.12 打开最近打开过的文件

**HotKey Name**：`Recent Files`
**HotKey In Mac**：`⌘E`
**HotKey In Windows**：`Ctrl+E`

### 1.4.13 打开最近编辑过的文件

**HotKey Name**：`Recent Changed Files`
**HotKey In Mac**：`⇧⌘E`
**HotKey In Windows**：`Ctrl+Shift+E`

## 1.5 格式化

### 1.5.1 格式化代码

**HotKey Name**：`Reformat Code`
**HotKey In Mac**：`⌥⌘L`
**HotKey In Windows**：`Ctrl+Alt+L`

### 1.5.2 格式化import

**HotKey Name**：`Optimize Imports`
**HotKey In Mac**：`⌃⌥O`
**HotKey In Windows**：`Ctrl+Alt+O`

## 1.6 参考

* [十大Intellij IDEA快捷键](http://blog.csdn.net/dc_726/article/details/42784275)

# 2 Intellij-IDEA

## 2.1 设置选中标识符高亮

1. 打开Preference
1. 搜索`Identifier under caret`，如下图所示：
    * ![fig1](/images/JetBrains-Developer-Tools/fig1.jpg)

## 2.2 自动添加序列化字段

1. `Preference`
1. `Editor`
1. `Inspections`
1. `右边列表选择Java`
1. `Serialization issues`
1. `Java | Serialization issues | Serializable class without 'serialVersionUID'`

## 2.3 创建类时自动创建作者日期信息

1. `Preference`
1. `Editor`
1. `File and Code Templates`
1. `includes`
1. `File Header`

```java
/**
 * @author xxx
 * @date ${DATE}
 */
```

## 2.4 wrong tag 'date'

`alt + enter` -> `add to custom tags`

## 2.5 控制台日志颜色

安装插件`grop console`

## 2.6 高亮选中的变量

1. `Preference`
1. `Editor`
1. `Color Scheme`
1. `General`
1. 右侧`Code`
    * `Identifier under caret`
    * `Identifier under caret (write)`

## 2.7 Debug 'Debugger' missing

`restore layout`

## 2.8 插件

1. `lombok`

## 2.9 参考

* [IntelliJ IDEA 设置选中标识符高亮](http://blog.csdn.net/wskinght/article/details/43052407)
* [IntelliJ IDEA 总结](https://www.zhihu.com/question/20450079)
* [idea 双击选中一个变量，及高亮显示相同的变量](https://blog.csdn.net/lxzpp/article/details/81081162)
* [Missing Debug window](https://stackoverflow.com/questions/46829125/intellij-idea-2017-missing-debug-window)

# 3 CLion

## 3.1 插件

1. `thrift`
