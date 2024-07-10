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

# 1 Shortcuts

## 1.1 Refactor

HotKey Name: `Refactor This`
HotKey In Mac: `⌃T`
HotKey In Windows: `Ctrl+Alt+Shift+T`

## 1.2 Gode Generator

### 1.2.1 Template

HotKey Name: `Insert Live Template...`
HotKey In Mac: `⌘J`
HotKey In Windows: `Ctrl+J`

**常用的几个模板**

1. 生成main函数：`psvm+Tab`
1. 生成for循环模板：`fori+Tab`
1. 生成System.out.println()语句：`sout+Tab`

### 1.2.2 Generator

HotKey Name: `Generate...`
HotKey In Mac: `⌘N`
HotKey In Windows: `Alt+Insert`

## 1.3 Edit

### 1.3.1 Extend Selection

HotKey Name: `Extend Selection`
HotKey In Mac: `⌥↑`
HotKey In Windows: `Ctrl+W`

### 1.3.2 Shrink Selection

HotKey Name: `Shrink Selection`
HotKey In Mac: `⌥↓`
HotKey In Windows: `Ctrl+Shitf+W`

### 1.3.3 Move Caret to Previous Word

HotKey Name: `Move Caret to Previous Word`
HotKey In Mac: `⌥←`、`⌥⇧←`
HotKey In Windows: `Ctrl+向左箭头`、`Ctrl+Shift+向左箭头`

### 1.3.4 Move Caret to Next Word

HotKey Name: `Move Caret to Next Word`
HotKey In Mac: `⌥→`、`⌥⇧→`
HotKey In Windows: `Ctrl+向右箭头`、`Ctrl+Shift+向右箭头`

### 1.3.5 Move Caret to Code Block Start

HotKey Name: `Move Caret to Code Block Start`
HotKey In Mac: `⌥⌘[`、`⌥⇧⌘[`
HotKey In Windows: `Ctrl+左方括号`、`Ctrl+Shift+左方括号`

### 1.3.6 Move Caret to Code Block End

HotKey Name: `Move Caret to Code Block End`
HotKey In Mac: `⌥⌘]`、`⌥⇧⌘]`
HotKey In Windows: `Ctrl+右方括号`、`Ctrl+Shift+右方括号`

### 1.3.7 Copilot

#### 1.3.7.1 Apply Completions to Editor

HotKey Name: `Apply Completions to Editor`

### 1.3.8 Appearance

#### 1.3.8.1 Inlay Hints

Path: `Settings` -> `Editor` -> `Inlay Hints`
Items:

* Inheritors
* Related problems
* Usages
* Code author

## 1.4 Navigate

### 1.4.1 Open Class

HotKey Name: `Class...`
HotKey In Mac: `⌘O`
HotKey In Windows: `Ctrl+N`

### 1.4.2 Search

HotKey Name: `Search Everywhere`
HotKey In Mac: `⇧⇧`
HotKey In Windows: `Double Shift`

### 1.4.3 Hierarchy

HotKey Name: `Type Hierarchy`
HotKey In Mac: `⌃H`
HotKey In Windows: `Ctrl+H`

### 1.4.4 Declaration

HotKey Name: `Declaration`
HotKey In Mac: `⌘B`、`⌘Click`
HotKey In Windows: `Ctrl+B`、`Ctrl+Click`

### 1.4.5 Implementation

HotKey Name: `Implementation(s)`
HotKey In Mac: `⌥⌘B`、`⌥⌘Click`
HotKey In Windows: `Ctrl+Alt+B`、`Ctrl+Alt+Click`

### 1.4.6 Structure

HotKey Name: `File Structure`
HotKey In Mac: `⌘F12`
HotKey In Windows: `Ctrl+F12`

### 1.4.7 Reference

HotKey Name: `Find Usages`
HotKey In Mac: `⌥F7`
HotKey In Windows: `Alt+F7`

### 1.4.8 Content Search

HotKey Name: `Find...`、`Find in Path...`
HotKey In Mac: `⌘F`、`⇧⌘F`
HotKey In Windows: `Ctrl+F`、`Ctrl+Shift+F`

### 1.4.9 Move in Results

HotKey Name: `Find Previous / Move to Previous Occurrence`
HotKey In Mac: `⌘G`、`⇧⌘G`
HotKey In Windows: `F3`/`Ctrl+L`、`Shift+F3`/`Ctrl+Shift+L`

### 1.4.10 Find Action

HotKey Name: `Find Action...`
HotKey In Mac: `⇧⌘A`
HotKey In Windows: `Ctrl+Shift+A`

### 1.4.11 Switch Tab

HotKey Name: `Switcher`
HotKey In Mac: `⌃Tab`
HotKey In Windows: `Ctrl+Tab`

### 1.4.12 Recent Files

HotKey Name: `Recent Files`
HotKey In Mac: `⌘E`
HotKey In Windows: `Ctrl+E`

### 1.4.13 Recent Changed Files

HotKey Name: `Recent Changed Files`
HotKey In Mac: `⇧⌘E`
HotKey In Windows: `Ctrl+Shift+E`

### 1.4.14 Scroll Page

HotKey Name: `Scroll to Top`、`Scroll to Bottom`
HotKey In Mac: `Undefined`
HotKey In Windows: `Undefined`

## 1.5 Format

### 1.5.1 Code

HotKey Name: `Reformat Code`
HotKey In Mac: `⌥⌘L`
HotKey In Windows: `Ctrl+Alt+L`

### 1.5.2 Import

HotKey Name: `Optimize Imports`
HotKey In Mac: `⌃⌥O`
HotKey In Windows: `Ctrl+Alt+O`

### 1.5.3 Google Style

[intellij-java-google-style.xml](https://github.com/google/styleguide/blob/gh-pages/intellij-java-google-style.xml)

### 1.5.4 Customized Stype

**如何导入自定义格式化`schema`：`Perference -> Editor -> Code Style`**

[starrocks-示例](https://github.com/StarRocks/starrocks/blob/main/fe/starrocks_intellij_style.xml)

```xml
<code_scheme name="starrocks" version="173">
  <JavaCodeStyleSettings>
    <option name="CLASS_COUNT_TO_USE_IMPORT_ON_DEMAND" value="999" />
    <option name="NAMES_COUNT_TO_USE_IMPORT_ON_DEMAND" value="999" />
    <option name="IMPORT_LAYOUT_TABLE">
      <value>
        <package name="" withSubpackages="true" static="false" />
        <emptyLine />
        <package name="java" withSubpackages="true" static="false" />
        <package name="javax" withSubpackages="true" static="false" />
        <emptyLine />
        <package name="" withSubpackages="true" static="true" />
      </value>
    </option>
  </JavaCodeStyleSettings>
  <codeStyleSettings language="JAVA">
    <option name="KEEP_FIRST_COLUMN_COMMENT" value="false" />
    <option name="KEEP_CONTROL_STATEMENT_IN_ONE_LINE" value="false" />
    <option name="KEEP_BLANK_LINES_IN_DECLARATIONS" value="1" />
    <option name="KEEP_BLANK_LINES_IN_CODE" value="1" />
    <option name="KEEP_BLANK_LINES_BEFORE_RBRACE" value="1" />
    <option name="ALIGN_MULTILINE_RESOURCES" value="false" />
    <option name="ALIGN_MULTILINE_FOR" value="false" />
    <option name="SPACE_BEFORE_ARRAY_INITIALIZER_LBRACE" value="true" />
    <option name="CALL_PARAMETERS_WRAP" value="1" />
    <option name="METHOD_PARAMETERS_WRAP" value="1" />
    <option name="RESOURCE_LIST_WRAP" value="1" />
    <option name="EXTENDS_LIST_WRAP" value="1" />
    <option name="THROWS_LIST_WRAP" value="1" />
    <option name="EXTENDS_KEYWORD_WRAP" value="1" />
    <option name="THROWS_KEYWORD_WRAP" value="1" />
    <option name="METHOD_CALL_CHAIN_WRAP" value="1" />
    <option name="BINARY_OPERATION_WRAP" value="1" />
    <option name="TERNARY_OPERATION_WRAP" value="1" />
    <option name="FOR_STATEMENT_WRAP" value="1" />
    <option name="ARRAY_INITIALIZER_WRAP" value="1" />
    <option name="ASSIGNMENT_WRAP" value="1" />
    <option name="ASSERT_STATEMENT_WRAP" value="1" />
    <option name="IF_BRACE_FORCE" value="3" />
    <option name="DOWHILE_BRACE_FORCE" value="3" />
    <option name="WHILE_BRACE_FORCE" value="3" />
    <option name="FOR_BRACE_FORCE" value="3" />
    <option name="PARAMETER_ANNOTATION_WRAP" value="1" />
    <option name="VARIABLE_ANNOTATION_WRAP" value="2" />
    <option name="ENUM_CONSTANTS_WRAP" value="1" />
  </codeStyleSettings>
</code_scheme>
```

### 1.5.5 Util

参考[command-line-formatter](https://www.jetbrains.com/help/idea/command-line-formatter.html)

格式化工具的路径：`<安装目录>/bin/format.sh`

## 1.6 Reference

* [十大Intellij IDEA快捷键](http://blog.csdn.net/dc_726/article/details/42784275)

# 2 Intellij-IDEA

## 2.1 Color

1. 打开Preference
1. 搜索`Identifier under caret`，如下图所示：
    * ![fig1](/images/JetBrains-Developer-Tools/fig1.jpg)

## 2.2 Serialize Field

1. `Preference`
1. `Editor`
1. `Inspections`
1. `右边列表选择Java`
1. `Serialization issues`
1. `Java | Serialization issues | Serializable class without 'serialVersionUID'`

## 2.3 Customized Information Of Class Comment

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

## 2.5 Console Color

安装插件`grop console`

## 2.6 Highlight Selection

1. `Preference`
1. `Editor`
1. `Color Scheme`
1. `General`
1. 右侧`Code`
    * `Identifier under caret`
    * `Identifier under caret (write)`

## 2.7 Debug 'Debugger' missing

`restore layout`

## 2.8 Plugin

* `Maven Helper`
* `Lombok`
* `IdeaVim`
* `Github Copilot`

## 2.9 Compile OOM

[How can I give the Intellij compiler more heap space?](https://stackoverflow.com/questions/8581501/how-can-i-give-the-intellij-compiler-more-heap-space)

**For `${InstallPath}/bin/idea.vmoptions`:**

```
-Xms128m
-Xmx2048m
-XX:MaxPermSize=1024m
-XX:ReservedCodeCacheSize=64m
-ea
```

**Config path:** `Preferences` -> `Build, Execution, Deployment` -> `Compiler` -> `Shared build process heap size`

* Compiler runs in a separate JVM by default so IDEA heap settings that you set in idea.vmoptions have no effect on the compiler.

## 2.10 Download JDK

**Config path:** `Project Structure` -> `Platform Settings` -> `SDKs` -> `+` -> `Download JDK...`

If you want to install jdk into `/Library/Java/JavaVirtualMachines`, you need to start IDEA as root.

* `cd /Applications/IntelliJ\ IDEA\ CE.app/Contents/MacOS`
* `sudo ./idea`

## 2.11 Reference

* [IntelliJ IDEA 设置选中标识符高亮](http://blog.csdn.net/wskinght/article/details/43052407)
* [IntelliJ IDEA 总结](https://www.zhihu.com/question/20450079)
* [idea 双击选中一个变量，及高亮显示相同的变量](https://blog.csdn.net/lxzpp/article/details/81081162)
* [Missing Debug window](https://stackoverflow.com/questions/46829125/intellij-idea-2017-missing-debug-window)

# 3 CLion

## 3.1 Plugin

1. `thrift`

# 4 IdeaVim

1. **配置文件路径：`~/.ideavimrc`**
1. **查看所有的`action`：`:actionlist`**
1. **目前不支持vim插件管理器，例如`Plug`等**

**为了保持{% post_link vim %}中的按键习惯，以下是`~/.ideavimrc`的内容**

* `Copilot`：触发补全的`action`是`copilot.applyInlays`，但是在`~/.ideavimrc`配置映射，却不起作用。只能在IDEA中进行设置

```vim
" embedded vim-surround
set surround
set argtextobj

" Edit position
nnoremap <c-o> :action Back<cr>
nnoremap <c-i> :action Forward<cr>

" keep keymap with Plug 'neoclide/coc.nvim'
nnoremap <leader>rd :action GotoDeclaration<cr>
nnoremap <leader>ri :action GotoImplementation<cr>
nnoremap <leader>rr :action ShowUsages<cr>
nnoremap <leader>rn :action RenameElement<cr>
nnoremap <c-j> :action GotoNextError<cr>
nnoremap <c-k> :action GotoPreviousError<cr>
nnoremap <leader>rgo :action OverrideMethods<cr>
nnoremap <leader>rgi :action ImplementMethods<cr>
smap <c-s> :action EditorSelectWord<cr>
xmap <c-s> :action EditorSelectWord<cr>
smap <c-b> :action EditorUnSelectWord<cr>
xmap <c-b> :action EditorUnSelectWord<cr>

" keep keymap with Plug 'Yggdroot/LeaderF'
nnoremap <c-p> :action SearchEverywhere<cr>
nnoremap <c-n> :action RecentFiles<cr>
nnoremap π :action FileStructurePopup<cr>

" keep keymap with Plug 'junegunn/fzf'
nnoremap <leader>rg :action FindInPath<cr>

" keep keymap with Plug 'preservim/nerdcommenter'
noremap <leader>c<space> :action CommentByLineComment<cr>

" keep keymap with Plug 'google/vim-codefmt'
nnoremap <c-l> :action ReformatCode<cr>
xnoremap <c-l> :action ReformatCode<cr>

" Reset registers
function! Clean_up_registers()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endfunction
noremap <silent> <leader>rc :call Clean_up_registers()<cr>

" Insert mode, cursor movement shortcuts
" [Option] + h，即「˙」
" [Option] + j，即「∆」
" [Option] + k，即「˚」
" [Option] + l，即「¬」
inoremap ˙ <c-o>h
inoremap ∆ <c-o>j
inoremap ˚ <c-o>k
inoremap ¬ <c-o>l
inoremap <c-w> <c-o>w
" inoremap <c-e> <c-o>e
inoremap <c-b> <c-o>b
inoremap <c-x> <c-o>x

" Map "replace" to [Option] + r, which is 「®」
" <c-r><c-w> means [Ctrl] + r and [Ctrl] + w, used to fill the word under the cursor into the search/replace field
nnoremap ® :%s/<c-r><c-w>

" When pasting in Visual mode, by default, the deleted content is placed in the default register
" gv reselects the replaced area
" y places the selected content into the default register
xnoremap p pgvy

" Select the current line
nnoremap <leader>sl ^vg_

" Cancel search highlight by default when pressing Enter
nnoremap <cr> :nohlsearch<cr><cr>

" Window switching
" [Option] + h，即「˙」
" [Option] + j，即「∆」
" [Option] + k，即「˚」
" [Option] + l，即「¬」
nnoremap ˙ :wincmd h<cr>
nnoremap ∆ :wincmd j<cr>
nnoremap ˚ :wincmd k<cr>
nnoremap ¬ :wincmd l<cr>

" Tab switching
" [Option] + h，即「Ó」
" [Option] + l，即「Ò」
nnoremap Ó :action PreviousTab<cr>
nnoremap Ò :action NextTab<cr>

" \qc to close quickfix
nnoremap <leader>qc :cclose<cr>

" Some general configurations
" Folding, disabled by default
set nofoldenable
set foldmethod=manual
set foldlevel=0
" Set file encoding format
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
" Set mouse mode for different modes (normal/visual/...), see :help mouse for details
" The configuration below means no mode is entered
set mouse=
" Other commonly used settings
set backspace=indent,eol,start
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hlsearch
set number
set cursorline
set matchpairs+=<:>
```

# 5 Assorted

1. 开启长按表示重复
    * `defaults write com.jetbrains.intellij ApplePressAndHoldEnabled -bool false`
1. [Writing classes when compiling is suddenly very, very slow](https://youtrack.jetbrains.com/issue/IDEA-162091/Writing-classes-when-compiling-is-suddenly-very-very-slow)
