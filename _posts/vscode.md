---
title: vscode
date: 2021-02-09 13:58:20
tags: 
- 摘录
categories: 
- Editor
---

**阅读更多**

<!--more-->

# 1 快捷键

[keybindings](https://code.visualstudio.com/docs/getstarted/keybindings)

1. 搜索文件：`ctrl+p`
1. 回到上一个/下一个编辑处：`ctrl + -`/`ctrl + shift + -`
1. `⇧⌘P`：打开命令列表
    * `upper`：转为大写
    * `lower`：转为小写
1. `⌘]`：增加缩进
1. `⌘[`：减少缩进
1. `⇧⌘O`：函数列表
1. `⌘T`：在当前工作目录中查询符号
1. `⇧⌥F`：格式化代码
1. `⌘⌥[`：折叠鼠标所在代码段
1. `⌘⌥]`：展开鼠标所在代码段

# 2 配置

1. 禁用行内作者提示链接：`gitlens.codeLens.authors.enabled`
1. 禁用引用补全：`editor.autoClosingQuotes`

# 3 插件

**c++相关**

* `C/C++`
* `C++ Intellisense`
* `Remote Development`
* `Better C++ Syntax`

**markdown相关**

* `Markdown Preview Enhanced`

# 4 c_cpp_properties.json

如何打开该配置：`⇧⌘P`，然后输入`Edit Configurations`

# 5 settings.json

* `MacOS`：`~/Library/Application\ Support/Code/User/settings.json`
* `Linux`：`~/.config/Code/User/settings.json`

# 6 vim

`Commands`可以参考[keybindings](https://code.visualstudio.com/docs/getstarted/keybindings)

```json
    "vim.normalModeKeyBindingsNonRecursive": [
        {
            "before": [
                "ctrl+n"
            ],
            "commands": [
                "workbench.action.quickOpen"
            ]
        },
        {
            "before": [
                "ctrl+l"
            ],
            "commands": [
                "editor.action.formatDocument"
            ]
        },
        {
            "before": [
                "<leader>",
                "r",
                "g"
            ],
            "commands": [
                "workbench.view.search"
            ]
        }
    ]
```

# 7 参考

* [How to disable inline author link?](https://github.com/eamodio/vscode-gitlens/issues/54)
* [vscode快捷键（Mac版）](https://zhuanlan.zhihu.com/p/66331018)
* [Edit C++ in Visual Studio Code](https://code.visualstudio.com/docs/cpp/cpp-ide)
* [Frequently asked questions](https://code.visualstudio.com/docs/cpp/faq-cpp)
* [c_cpp_properties.json reference](https://code.visualstudio.com/docs/cpp/c-cpp-properties-schema-reference)
* [vscode使用compile_commands.json配置includePath环境](https://blog.csdn.net/qq_37868450/article/details/105013325)
* [VS Code 的常用快捷键](https://zhuanlan.zhihu.com/p/44044896)
