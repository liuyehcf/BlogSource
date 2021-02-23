---
title: 编译原理-自定义Hua语言
date: 2018-06-27 16:07:13
mathjax: true
tags: 
- 原创
categories: 
- Compile Principle
---

**阅读更多**

<!--more-->

# 1 基本概念

## 1.1 文法符号

在文法定义中会有两种类型的符号：一种称为**终结符**，另一种称为**非终结符**

所谓终结符就是**不可再分**的符号，是**原子**的，是**具体的语法成分**。例如，在英文文法中，每个字母就是终结符，标点符号就是终结符。又例如，在Java文法中，所有关键字（int、boolean、void、abstract、public、return等等），分号，逗号、括号都属于终结符

所谓非终结符就是**可以再分**的符号，是**非原子**的，是**抽象的语法成分**。例如，在英文文法中，单词，祈使句、宾语从句、状语从句就是非终结符。又例如，在Java文法中，if语句、while语句，方法定义、类定义、赋值语句等等都属于非终结符

**为了方便描述，我们有如下约定**

1. 排在前面的大写字母表示**非终结符**，例如{% raw %}$A${% endraw %}、{% raw %}$B${% endraw %}、{% raw %}$C${% endraw %}、{% raw %}$D${% endraw %}、{% raw %}$E${% endraw %}、{% raw %}$F${% endraw %}、{% raw %}$G${% endraw %}
1. {% raw %}$S${% endraw %}表示**文法开始符号**
1. 排在前面的小写字母表示**终结符**，例如{% raw %}$a${% endraw %}、{% raw %}$b${% endraw %}、{% raw %}$c${% endraw %}
1. {% raw %}$w${% endraw %}表示**终结符号串**
1. 排在后面的大写字母表示文法符号，例如{% raw %}$X${% endraw %}、{% raw %}$Y${% endraw %}、{% raw %}$Z${% endraw %}
1. {% raw %}$α${% endraw %}、{% raw %}$β${% endraw %}等希腊字母表示**文法符号串**

## 1.2 文法符号串

文法符号串由文法符号组合而成，文法符号包括终结符和非终结符。当然单个的文法符号也属于文法符号串

## 1.3 产生式

产生式描述了不同文法符号串之间的**转换关系**，这种关系是单向的。例如

{% raw %}$$
\alpha \to \beta
$${% endraw %}

## 1.4 文法

文法由一系列产生式构成，根据产生式形式的不同，我们将文法分为四种类型

* 0-型文法，又称为无限制文法{% raw %}$$\alpha \to \beta$${% endraw %}
* 1-型文法，又称为上下文有关文法{% raw %}$$\alpha_1A\alpha_2 \to \alpha_1\beta\alpha_2,|\alpha|≤|\beta|$${% endraw %}
* 2-型文法，又称为上下文无关文法{% raw %}$$A \to \beta$${% endraw %}
* 3-型文法，又称为正则文法{% raw %}$$A \to wB\;\;\;or\;\;\;A \to w$${% endraw %} or {% raw %}$$A \to Bw\;\;\;or\;\;\;A \to w$${% endraw %}

**一般的编程语言都是2-型文法，即上下文无关文法**

## 1.5 分析法概述

这里，我们只讨论上下文无关文法（3-型文法)

一般而言，分析法有{% raw %}$LL(n)${% endraw %}和{% raw %}$LR(n)${% endraw %}分析两种，其中

1. {% raw %}$LL(n)${% endraw %}：第一个{% raw %}$L${% endraw %}表示从左到右扫描输入串，第二个{% raw %}$L${% endraw %}表示最左推导，{% raw %}$n${% endraw %}表示向后看几个输入符号，通常只有1才有实践意义
1. {% raw %}$LR(n)${% endraw %}：第一个{% raw %}$L${% endraw %}表示从左到右扫描输入串，第二个{% raw %}$R${% endraw %}表示最右规约，{% raw %}$n${% endraw %}表示向后看几个输入符号，通常取0和1才有实践意义

对于{% raw %}$LL(n)${% endraw %}分析法，语法分析过程可以概括为以下几个步骤

1. 计算first集合
1. 计算follow集合
1. 计算select集合
1. 生成预测分析表

对于{% raw %}$LR(n)${% endraw %}分析法，预发分析过程可以概括为以下几个步骤

1. 计算first集合
1. 计算follow集合
1. 生成LR自动机
1. 生成预测分析表

### 1.5.1 first集

{% raw %}$First(X)${% endraw %}定义为可以由**文法符号**{% raw %}$X${% endraw %}推导出的所有**终结符集合**

* 显然如果{% raw %}$X${% endraw %}是终结符，那么{% raw %}$First(X)=\{X\}${% endraw %}

### 1.5.2 follow集

{% raw %}$First(A)${% endraw %}定义为可以紧跟在**非终结符{% raw %}$A${% endraw %}**之后的所有**终结符集合**，不包括{% raw %}$\epsilon${% endraw %}

# 2 正则表达式实践篇

**正则表达式引擎**

* base package: `org.liuyehcf.grammar.rg`
* 包括nfa自动机以及dfa自动机
* 支持以下正则表达式通配符: `.`、`?`、`*`、`+`、`|`
* 支持量词`{}`
* 支持部分转义，包括`\d`、`\D`、`\w`、`\W`、`\s`、`\S`
* 支持`[]`
* nfa自动机支持捕获组（nfa转dfa时，捕获组信息会丢失，因此dfa自动机尚不支持捕获组。目前还没有很好的解决方法）

# 3 编译引擎介绍

我们来回顾一下编译过程

1. 词法分析
1. 语法分析
1. 语义分析
1. 中间代码生成
1. 代码优化
1. 存储管理

由于词法分析、语法分析过程对于任何语言来说都是相同的，而语义分析是针对特定语言的，是无法泛化的。因此，我设计的编译引擎将`词法分析`、`语法分析`与`语义分析`及后续进行了解耦，语法分析的过程交给编译引擎来完成。在设计Hua语言时，只需要关注语义分析即可

# 4 Hua语言实践篇

## 4.1 文法定义

Hua文法的定义参考了Java的文法定义，且大部分保持一致。包含如下主要的语法成分

1. 支持方法定义、方法重载、方法调用
1. 支持变量定义
1. 支持基本类型int和boolean
1. 支持数组类型、多维数组
1. 支持基本的控制流语句，包括
    * if then
    * if then else
    * while
    * do while
    * for
    * condition expression
1. 支持二元运算符
    * `*`
    * `/`
    * `%`
    * `+`
    * `-`
    * `<<`
    * `>>`
    * `>>>`
    * `&`
    * `^`
    * `|`
    * `||`
    * `&&`
1. 支持一些系统函数，目前仅包含
    * print(int)
    * print(boolean)
    * nextInt(int,int)
    * nextInt()
    * nextBoolean()

以下就是HUA语言的文法定义

```
<additive expression> → <additive expression> + <multiplicative expression> | <additive expression> - <multiplicative expression> | <multiplicative expression>
<and expression> → <and expression> & <equality expression> | <equality expression>
<argument list> → <argument list> , <expression> | <expression>
<array access> → <expression name> <mark 286_1_1> [ <expression> ] | <primary no new array> [ <expression> ]
<array creation expression> → new <primitive type> <dim exprs> <epsilon or dims>
<array type> → <type> [ ]
<assignment expression> → <assignment> | <conditional expression>
<assignment operator> → %= | &= | *= | += | -= | /= | <<= | = | >>= | >>>= | ^= | |=
<assignment> → <left hand side> <assignment operator> <mark 222_1_1> <assignment expression>
<block statement> → <local variable declaration statement> | <statement>
<block statements> → <block statement> | <block statements> <block statement>
<block> → { <mark 139_1_1> <epsilon or block statements> }
<boolean literal> → false | true
<cast expression> → ( <primitive type> ) <unary expression> | ( <reference type> ) <unary expression not plus minus>
<conditional and expression> → <conditional and expression> && <mark 232_2_1> <inclusive or expression> | <inclusive or expression>
<conditional expression> → <conditional or expression> | <conditional or expression> ? <mark true block> <expression> : <mark false block> <conditional expression>
<conditional or expression> → <conditional and expression> | <conditional or expression> || <mark 230_2_1> <conditional and expression>
<decimal integer literal> → <decimal numeral>
<decimal numeral> → 0 | <non zero digit> <epsilon or digits>
<digit> → 0 | <non zero digit>
<digits> → <digit> | <digits> <digit>
<dim expr> → [ <expression> ]
<dim exprs> → <dim expr> | <dim exprs> <dim expr>
<dims> → [ ] | <dims> [ ]
<do statement> → do <mark loop offset> <statement> while ( <expression> ) ;
<empty statement> → ;
<epsilon or argument list> → **ε** | <argument list>
<epsilon or block statements> → **ε** | <block statements>
<epsilon or digits> → **ε** | <digits>
<epsilon or dims> → **ε** | <dims>
<epsilon or expression> → **ε** | <expression>
<epsilon or for init> → **ε** | <for init>
<epsilon or for update> → **ε** | <for update>
<epsilon or formal parameter list> → **ε** | <formal parameter list>
<equality expression> → <equality expression> != <relational expression> | <equality expression> == <relational expression> | <relational expression>
<exclusive or expression> → <and expression> | <exclusive or expression> ^ <and expression>
<expression name> → @identifier
<expression statement> → <statement expression> ;
<expression> → <assignment expression>
<floating-point type> → float
<for init> → <local variable declaration> | <statement expression list>
<for statement no short if> → for ( <mark before init> <epsilon or for init> ; <mark loop offset> <epsilon or expression> ; <mark before update> <epsilon or for update> ) <mark after update> <statement no short if>
<for statement> → for ( <mark before init> <epsilon or for init> ; <mark loop offset> <epsilon or expression> ; <mark before update> <epsilon or for update> ) <mark after update> <statement>
<for update> → <statement expression list>
<formal parameter list> → <formal parameter list> , <formal parameter> | <formal parameter>
<formal parameter> → <type> <mark 50_1_1> <variable declarator id>
<if then else statement no short if> → if ( <expression> ) <mark true block> <statement no short if> else <mark false block> <statement no short if>
<if then else statement> → if ( <expression> ) <mark true block> <statement no short if> else <mark false block> <statement>
<if then statement> → if ( <expression> ) <mark true block> <statement>
<inclusive or expression> → <exclusive or expression> | <inclusive or expression> | <exclusive or expression>
<integer literal> → <decimal integer literal>
<integral type> → int
<left hand side> → <array access> | <expression name>
<literal> → <boolean literal> | <integer literal>
<local variable declaration statement> → <local variable declaration> ;
<local variable declaration> → <type> <mark 146_1_1> <variable declarators>
<mark 139_1_1> → **ε**
<mark 146_1_1> → **ε**
<mark 222_1_1> → **ε**
<mark 230_2_1> → **ε**
<mark 232_2_1> → **ε**
<mark 286_1_1> → **ε**
<mark 50_1_1> → **ε**
<mark 66_2_1> → **ε**
<mark 74_1_1> → **ε**
<mark 74_1_2> → **ε**
<mark after update> → **ε**
<mark before init> → **ε**
<mark before update> → **ε**
<mark false block> → **ε**
<mark loop offset> → **ε**
<mark prefix expression> → **ε**
<mark true block> → **ε**
<method body> → ; | <block>
<method declaration> → <mark 74_1_1> <method header> <mark 74_1_2> <method body>
<method declarations> → <method declaration> | <method declarations> <method declaration>
<method declarator> → @identifier ( <epsilon or formal parameter list> )
<method header> → <result type> <method declarator>
<method invocation> → <method name> ( <epsilon or argument list> )
<method name> → @identifier
<multiplicative expression> → <multiplicative expression> % <unary expression> | <multiplicative expression> * <unary expression> | <multiplicative expression> / <unary expression> | <unary expression>
<non zero digit> → @nonZeroDigit
<numeric type> → <floating-point type> | <integral type>
<postdecrement expression> → <postfix expression> --
<postfix expression> → <expression name> | <postdecrement expression> | <postincrement expression> | <primary>
<postincrement expression> → <postfix expression> ++
<predecrement expression> → -- <mark prefix expression> <unary expression>
<preincrement expression> → ++ <mark prefix expression> <unary expression>
<primary no new array> → ( <expression> ) | <array access> | <literal> | <method invocation>
<primary> → <array creation expression> | <primary no new array>
<primitive type> → boolean | <numeric type>
<programs> → <method declarations>
<reference type> → <array type>
<relational expression> → <relational expression> < <shift expression> | <relational expression> <= <shift expression> | <relational expression> > <shift expression> | <relational expression> >= <shift expression> | <shift expression>
<result type> → void | <type>
<return statement> → return <epsilon or expression> ;
<shift expression> → <additive expression> | <shift expression> << <additive expression> | <shift expression> >> <additive expression> | <shift expression> >>> <additive expression>
<statement expression list> → <statement expression list> , <statement expression> | <statement expression>
<statement expression> → <assignment> | <method invocation> | <postdecrement expression> | <postincrement expression> | <predecrement expression> | <preincrement expression>
<statement no short if> → <for statement no short if> | <if then else statement no short if> | <statement without trailing substatement> | <while statement no short if>
<statement without trailing substatement> → <block> | <do statement> | <empty statement> | <expression statement> | <return statement>
<statement> → <for statement> | <if then else statement> | <if then statement> | <statement without trailing substatement> | <while statement>
<type> → <primitive type> | <reference type>
<unary expression not plus minus> → ! <unary expression> | ~ <unary expression> | <cast expression> | <postfix expression>
<unary expression> → + <unary expression> | - <unary expression> | <predecrement expression> | <preincrement expression> | <unary expression not plus minus>
<variable declarator id> → @identifier | <variable declarator id> [ ]
<variable declarator> → <variable declarator id> | <variable declarator id> = <variable initializer>
<variable declarators> → <variable declarator> | <variable declarators> , <mark 66_2_1> <variable declarator>
<variable initializer> → <expression>
<while statement no short if> → while ( <mark loop offset> <expression> ) <mark true block> <statement no short if>
<while statement> → while ( <mark loop offset> <expression> ) <mark true block> <statement>
```
