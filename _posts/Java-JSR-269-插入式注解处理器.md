---
title: Java-JSR-269-插入式注解处理器
date: 2018-02-02 19:04:57
tags: 
- 原创
categories: 
- Java
- Annotation
---

**阅读更多**

<!--more-->

# 1 编译过程

从Sun Javac的代码来看，编译过程大致可以分为3个过程:

1. 解析与填充符号表过程
1. 插入式注解处理器的注解处理过程
1. 分析与字节码生成过程

```flow
st=>start: 开始
en=>end: 结束
op1=>operation: 解析与填充符号表
op2=>operation: 插入式注解处理器进行注解处理
op3=>operation: 分析与字节码生成
cond=>condition: 语法树没有变动 ?

st->op1
op1->op2
op2->cond
cond(yes)->op3
cond(no)->op1
op3->en
```

**Javac编译动作的入口是`com.sun.tools.javac.main.JavaCompiler`类**，上述3个过程的代码逻辑集中在这个类的**`compile()`和`compile2()`**方法中，下面给出整个编译过程中最关键的几个步骤

```java
public void compile(List<JavaFileObject> var1, List<String> var2, Iterable<? extends Processor> var3) {
        //... 

        this.initProcessAnnotations(var3); //(1)
        this.delegateCompiler = this.processAnnotations( //(4)
            this.enterTrees( //(3)
                this.stopIfError(
                    CompileState.PARSE, 
                    this.parseFiles(var1)  //(2)
                )
            ), 
            var2
        );
        this.delegateCompiler.compile2(); //(5)
        
        //... 
}

private void compile2() {
    //...
    
    this.generate( //(9)
        this.desugar( //(8)
            this.flow( //(7)
                this.attribute( //(6)
                    (Env)this.todo.remove()
                )
            )
        )
    );
    
    //...
}
```

* `(1)`：准备过程，初始化插入式注解处理器
* `(2)`：词法分析，语法分析
* `(3)`：输入到符号表
* `(4)`：注解处理
* `(5)`：分析及字节码生成
* `(6)`：标注
* `(7)`：数据流分析
* `(8)`：解语法糖
* `(9)`：字节码生成

## 1.1 解析

解析步骤由上述代码清单中的`parseFiles()`方法（过程`(2)`）完成，解析步骤包括了经典程序编译原理中的词法分析和语法分析两个过程

**词法分析是将源代码的字符流转变为标记（Token）集合**，单个字符是程序编写过程的最小元素，而标记则是编译过程的最小元素，关键字、变量名、字面量、运算符都可以成为标记，如`int a= b + 2`这句代码包含了6个标记，分别是`int`、`a`、`=`、`b`、`+`、`2`，虽然关键字int由3个字符构成，但是它只是一个Token，不可再拆分。**在Javac的源码中，词法分析过程由`com.sun.tools.javac.parser.Scanner`类来实现**

**语法分析是根据Token序列构造抽象语法树的过程**，抽象语法树（Abstract Syntax Tree,AST）是一种用来描述程序代码语法结构的树形表示方式，语法树的每一个节点都代表着程序代码中的一个语法结构（Construct），例如包、类型、修饰符、运算符、接口、返回值甚至代码注释等都可以是一个语法结构。在Javac的源码中，**语法分析过程由`com.sun.tools.javac.parser.Parser`类实现，这个阶段产出的抽象语法树由`com.sun.tools.javac.tree.JCTree`类表示**，经过这个步骤之后，编译器就基本不会再对源码文件进行操作了，后续的操作都建立在抽象语法树之上

## 1.2 填充符号表

完成了语法分析和词法分析之后，下一步就是填充符号表的过程，也就是`enterTrees()`方法（过程`(3)`）所做的事情。**符号表（Symbol Table）是由一组符号地址和符号信息构成的表格，可以把它想象成哈希表中K-V值对的形式（实际上符号表不一定是哈希表实现，可以是有序符号表、树状符号表、栈结构符号表等）**。符号表中所登记的信息在编译的不同阶段都要用到。在语义分析中，符号表所登记的内容将用于语义检查（如检查一个名字的使用和原先的说明是否一致）和产生中间代码。在目标代码生成阶段，当对符号名进行地址分配时，符号表是地址分配的依据

**在Javac源代码中，填充符号表的过程由`com.sun.tools.javac.comp.Enter`类实现**，此过程的出口是一个待处理列表（To Do List），包含了每一个编译单元的抽象语法树的顶级节点，以及package-info.java（如果存在的话）的顶级节点

# 2 JSR-269简介

在Javac源码中，插入式注解处理器的初始化过程是在`initPorcessAnnotations()`方法中完成的，而它的执行过程则是在`processAnnotations()`方法中完成的，这个方法判断是否还有新的注解处理器需要执行，如果有的话，通过`com.sun.tools.javac.processing.JavacProcessingEnvironment`类的`doProcessing()`方法生成一个新的JavaCompiler对象对编译的后续步骤进行处理

在JDK 1.5之后，Java语言提供了对注解（Annotation）的支持，这些注解与普通的Java代码一样，是在运行期间发挥作用的。**在JDK 1.6中实现了JSR-269规范JSR-269：Pluggable Annotations Processing API（插入式注解处理API）。提供了一组插入式注解处理器的标准API在编译期间对注解进行处理**。我们可以把它看做是一组编译器的插件，在这些插件里面，可以读取、修改、添加抽象语法树中的任意元素。**如果这些插件在处理注解期间对语法树进行了修改，编译器将回到解析及填充符号表的过程重新处理，直到所有插入式注解处理器都没有再对语法树进行修改为止，每一次循环称为一个Round，也就是第一张图中的回环过程**。 有了编译器注解处理的标准API后，我们的代码才有可能干涉编译器的行为，由于语法树中的任意元素，甚至包括代码注释都可以在插件之中访问到，所以通过插入式注解处理器实现的插件在功能上有很大的发挥空间。只要有足够的创意，程序员可以使用插入式注解处理器来实现许多原本只能在编码中完成的事情

我们知道编译器在把Java程序源码编译为字节码的时候，会对Java程序源码做各方面的检查校验。这些校验主要以程序“写得对不对”为出发点，虽然也有各种WARNING的信息，但总体来讲还是较少去校验程序“写得好不好”。**有鉴于此，业界出现了许多针对程序“写得好不好”的辅助校验工具，如CheckStyle、FindBug、Klocwork等。这些代码校验工具有一些是基于Java的源码进行校验，还有一些是通过扫描字节码来完成**

# 3 编译相关的数据结构与API

## 3.1 JCTree

JCTree是语法树元素的基类，**包含一个重要的字段`pos`，该字段用于指明当前语法树节点（JCTree）在语法树中的位置**，因此我们不能直接用new关键字来创建语法树节点，即使创建了也没有意义。此外，**结合访问者模式，将数据结构与数据的处理进行解耦**，部分源码如下：

```java
public abstract class JCTree implements Tree, Cloneable, DiagnosticPosition {

    public int pos = -1;

    ...

    public abstract void accept(JCTree.Visitor visitor);

    ...
}
```

这里重点介绍几个JCTree的子类，下面的Demo会用到

1. JCStatement：`声明`语法树节点，常见的子类如下
    * JCBlock：`语句块`语法树节点
    * JCReturn：`return语句`语法树节点
    * JCClassDecl：`类定义`语法树节点
    * JCVariableDecl：`字段/变量定义`语法树节点
1. JCMethodDecl：`方法定义`语法树节点
1. JCModifiers：`访问标志`语法树节点
1. JCExpression：`表达式`语法树节点，常见的子类如下
    * JCAssign：`赋值语句`语法树节点
    * JCIdent：`标识符`语法树节点，**可以是变量，类型，关键字等等**

## 3.2 TreeMaker

TreeMaker用于创建一系列`语法树节点`，**创建时会为创建出来的JCTree设置pos字段，所以必须用上下文相关的TreeMaker对象来创建语法树节点，而不能直接new语法树节点**

源码可以参考[TreeMaker DOC](http://www.docjar.com/docs/api/com/sun/tools/javac/tree/TreeMaker.html)

### 3.2.1 TreeMaker.Modifiers

TreeMaker.Modifiers方法用于创建`访问标志`语法树节点(JCModifiers)，源码如下：

1. flags：访问标志
1. annotations：注解列表

```java
public JCModifiers Modifiers(long flags) {
    return Modifiers(flags, List.< JCAnnotation >nil());
}

public JCModifiers Modifiers(long flags,
    List<JCAnnotation> annotations) {
        JCModifiers tree = new JCModifiers(flags, annotations);
        boolean noFlags = (flags & (Flags.ModifierFlags | Flags.ANNOTATION)) == 0;
        tree.pos = (noFlags && annotations.isEmpty()) ? Position.NOPOS : pos;
        return tree;
}
```

其中入参`flags`可以用枚举类型`com.sun.tools.javac.code.Flags`，且支持拼接（枚举值经过精心设计）

例如，我们可以这样用

```java
    treeMaker.Modifiers(Flags.PUBLIC + Flags.STATIC + Flags.FINAL);
```

### 3.2.2 TreeMaker.ClassDef

TreeMaker.ClassDef用于创建`类定义`语法树节点(JCClassDecl)，源码如下：

1. mods：访问标志
1. name：类名
1. typarams：泛型参数列表
1. extending：父类
1. implementing：接口列表
1. defs：类定义的详细语句，包括字段，方法定义等等

```java
public JCClassDecl ClassDef(JCModifiers mods,
    Name name,
    List<JCTypeParameter> typarams,
    JCExpression extending,
    List<JCExpression> implementing,
    List<JCTree> defs) {
        JCClassDecl tree = new JCClassDecl(mods,
                                     name,
                                     typarams,
                                     extending,
                                     implementing,
                                     defs,
                                     null);
        tree.pos = pos;
        return tree;
}
```

### 3.2.3 TreeMaker.MethodDef

TreeMaker.MethodDef用于创建`方法定义`语法树节点（JCMethodDecl），源码如下：

1. mods：访问标志
1. name：方法名
1. restype：返回类型
1. typarams：泛型参数列表
1. params：参数列表
1. thrown：异常声明列表
1. body：方法体
1. defaultValue：默认方法（可能是interface中的那个default）
1. m：方法符号
1. mtype：方法类型。包含多种类型，泛型参数类型、方法参数类型，异常参数类型、返回参数类型

```java
public JCMethodDecl MethodDef(JCModifiers mods,
    Name name,
    JCExpression restype,
    List<JCTypeParameter> typarams,
    List<JCVariableDecl> params,
    List<JCExpression> thrown,
    JCBlock body,
    JCExpression defaultValue) {
        JCMethodDecl tree = new JCMethodDecl(mods,
                                       name,
                                       restype,
                                       typarams,
                                       params,
                                       thrown,
                                       body,
                                       defaultValue,
                                       null);
        tree.pos = pos;
        return tree;
}

public JCMethodDecl MethodDef(MethodSymbol m,
    Type mtype,
    JCBlock body) {
        return (JCMethodDecl)
            new JCMethodDecl(
                Modifiers(m.flags(), Annotations(m.getAnnotationMirrors())),
                m.name,
                Type(mtype.getReturnType()),
                TypeParams(mtype.getTypeArguments()),
                Params(mtype.getParameterTypes(), m),
                Types(mtype.getThrownTypes()),
                body,
                null,
                m).setPos(pos).setType(mtype);
}
```

**其中，返回类型填`null`或者`treeMaker.TypeIdent(TypeTag.VOID)`都代表返回void类型**

### 3.2.4 TreeMaker.VarDef

TreeMaker.VarDef用于创建`字段/变量定义`语法树节点（JCVariableDecl），源码如下：

1. mods：访问标志
1. vartype：类型
1. init：初始化语句
1. v：变量符号

```java
public JCVariableDecl VarDef(JCModifiers mods,
    Name name,
    JCExpression vartype,
    JCExpression init) {
        JCVariableDecl tree = new JCVariableDecl(mods, name, vartype, init, null);
        tree.pos = pos;
        return tree;
}

public JCVariableDecl VarDef(VarSymbol v,
    JCExpression init) {
        return (JCVariableDecl)
            new JCVariableDecl(
                Modifiers(v.flags(), Annotations(v.getAnnotationMirrors())),
                v.name,
                Type(v.type),
                init,
                v).setPos(pos).setType(v.type);
}
```

### 3.2.5 TreeMaker.Ident

TreeMaker.Ident用于创建`标识符`语法树节点（JCIdent），源码如下：

```java
public JCIdent Ident(Name name) {
        JCIdent tree = new JCIdent(name, null);
        tree.pos = pos;
        return tree;
}

public JCIdent Ident(Symbol sym) {
        return (JCIdent)new JCIdent((sym.name != names.empty)
                                ? sym.name
                                : sym.flatName(), sym)
            .setPos(pos)
            .setType(sym.type);
}

public JCExpression Ident(JCVariableDecl param) {
        return Ident(param.sym);
}
```

### 3.2.6 TreeMaker.Return

TreeMaker.Return用于创建`return语句`语法树节点（JCReturn），源码如下：

```java
public JCReturn Return(JCExpression expr) {
        JCReturn tree = new JCReturn(expr);
        tree.pos = pos;
        return tree;
}
```

### 3.2.7 TreeMaker.Select

TreeMaker.Select用于创建`域访问/方法访问`（这里的方法访问只是取到名字，方法的调用需要用TreeMaker.Apply）语法树节点（JCFieldAccess），源码如下：

1. selected：`.`运算符左边的表达式
1. selector：`.`运算符右边的名字

```java
public JCFieldAccess Select(JCExpression selected,
    Name selector) 
{
        JCFieldAccess tree = new JCFieldAccess(selected, selector, null);
        tree.pos = pos;
        return tree;
}

public JCExpression Select(JCExpression base,
    Symbol sym) {
        return new JCFieldAccess(base, sym.name, sym).setPos(pos).setType(sym.type);
}
```

### 3.2.8 TreeMaker.NewClass

TreeMaker.NewClass用于创建`new语句`语法树节点（JCNewClass），源码如下：

1. encl：不太明白此参数含义
1. typeargs：参数类型列表
1. clazz：待创建对象的类型
1. args：参数列表
1. def：类定义

```java
public JCNewClass NewClass(JCExpression encl,
    List<JCExpression> typeargs,
    JCExpression clazz,
    List<JCExpression> args,
    JCClassDecl def) {
        JCNewClass tree = new JCNewClass(encl, typeargs, clazz, args, def);
        tree.pos = pos;
        return tree;
}
```

### 3.2.9 TreeMaker.Apply

TreeMaker.Apply用于创建`方法调用`语法树节点（JCMethodInvocation），源码如下：

1. typeargs：参数类型列表
1. fn：调用语句
1. args：参数列表

```java
public JCMethodInvocation Apply(List<JCExpression> typeargs,
    JCExpression fn,
    List<JCExpression> args) {
        JCMethodInvocation tree = new JCMethodInvocation(typeargs, fn, args);
        tree.pos = pos;
        return tree;
}
```

### 3.2.10 TreeMaker.Assign

TreeMaker.Assign用于创建`赋值语句`语法树节点（JCAssign），源码如下：

1. lhs：赋值语句左边表达式
1. rhs：赋值语句右边表达式

```java
public JCAssign Assign(JCExpression lhs,
    JCExpression rhs) {
        JCAssign tree = new JCAssign(lhs, rhs);
        tree.pos = pos;
        return tree;
}
```

### 3.2.11 TreeMaker.Exec

TreeMaker.Exec用于创建`可执行语句`语法树节点（JCExpressionStatement），源码如下：

```java
public JCExpressionStatement Exec(JCExpression expr) {
        JCExpressionStatement tree = new JCExpressionStatement(expr);
        tree.pos = pos;
        return tree;
}
```

**例如，TreeMaker.Apply以及TreeMaker.Assign就需要外面包一层TreeMaker.Exec来获得一个JCExpressionStatement**

### 3.2.12 TreeMaker.Block

TreeMaker.Block用于创建`组合语句`语法树节点（JCBlock），源码如下：

1. flags：访问标志
1. stats：语句列表

```java
public JCBlock Block(long flags,
    List<JCStatement> stats) {
        JCBlock tree = new JCBlock(flags, stats);
        tree.pos = pos;
        return tree;
}
```

## 3.3 com.sun.tools.javac.util.List

上述JSR-269 API中会涉及到一个List，这个List不是java.util.List，它是com.sun.tools.javac.util.List，这个List的操作比较奇特，不支持链式操作。下面给出部分源码，List包含两个字段，head和tail，其中head只是一个节点，而tail是一个List

```java
public class List<A> extends AbstractCollection<A> implements java.util.List<A> {
    public A head;
    public List<A> tail;
    private static final List<?> EMPTY_LIST = new List<Object>((Object)null, (List)null) {
        public List<Object> setTail(List<Object> var1) {
            throw new UnsupportedOperationException();
        }

        public boolean isEmpty() {
            return true;
        }
    };

    List(A head, List<A> tail) {
        this.tail = tail;
        this.head = head;
    }

    public static <A> List<A> nil() {
        return EMPTY_LIST;
    }

    public List<A> prepend(A var1) {
        return new List(var1, this);
    }

    public List<A> append(A var1) {
        return of(var1).prependList(this);
    }

    public static <A> List<A> of(A var0) {
        return new List(var0, nil());
    }

    public static <A> List<A> of(A var0, A var1) {
        return new List(var0, of(var1));
    }

    public static <A> List<A> of(A var0, A var1, A var2) {
        return new List(var0, of(var1, var2));
    }

    public static <A> List<A> of(A var0, A var1, A var2, A... var3) {
        return new List(var0, new List(var1, new List(var2, from(var3))));
    }

    ...
}
```

## 3.4 com.sun.tools.javac.util.ListBuffer

由于com.sun.tools.javac.util.List用起来不是很方便，而ListBuffer的行为与java.util.List的行为类似，并且提供了转换成com.sun.tools.javac.util.List的方法

```java
        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加语句 " this.xxx = xxx; "
        jcStatements.append(...);

        //添加Builder模式中的返回语句 " return this; "
        jcStatements.append(...);

        List<JCTree.JCStatement> lst = jcStatements.toList();
```

## 3.5 tricky

### 3.5.1 创建一个构造方法

**注意点：方法的名字就是`<init>`**

```java
treeMaker.MethodDef(
        treeMaker.Modifiers(Flags.PUBLIC), //访问标志
        names.fromString("<init>"), //名字
        treeMaker.TypeIdent(TypeTag.VOID), //返回类型
        List.nil(), //泛型形参列表
        List.nil(), //参数列表
        List.nil(), //异常列表
        jcBlock, //方法体
        null //默认方法（可能是interface中的那个default）
);
```

### 3.5.2 创建一个方法的参数

**注意点：访问标志设置成`Flags.PARAMETER`**

```java
treeMaker.VarDef(
        treeMaker.Modifiers(Flags.PARAMETER), //访问标志。极其坑爹！！！
        prototypeJCVariable.name, //名字
        prototypeJCVariable.vartype, //类型
        null //初始化语句
);
```

### 3.5.3 创建一条赋值语句

```java
treeMaker.Exec(
        treeMaker.Assign(
                treeMaker.Select(
                        treeMaker.Ident(names.fromString(THIS)),
                        jcVariable.name
                ),
                treeMaker.Ident(jcVariable.name)
        )
)
```

### 3.5.4 创建一条new语句

```java
treeMaker.NewClass(
        null, //尚不清楚含义
        List.nil(), //泛型参数列表
        treeMaker.Ident(builderClassName), //创建的类名
        List.nil(), //参数列表
        null //类定义，估计是用于创建匿名内部类
)
```

### 3.5.5 创建一条方法调用语句

```java
treeMaker.Exec(
        treeMaker.Apply(
                List.nil(),
                treeMaker.Select(
                        treeMaker.Ident(getNameFromString(IDENTIFIER_DATA)),
                        jcMethodDecl.getName()
                ),
                List.of(treeMaker.Ident(jcVariableDecl.getName())) //传入的参数集合
        )
)
````

### 3.5.6 从JCTree.JCVariable中获取类型信息

注意，直接拿`vartype`字段，而不是`type`字段或者`getType()`方法

* `vartype`的类型是`JCTree.JCExpression`
* `type`的类型是`com.sun.tools.javac.code.Type`，**这是个非标准api，理应不该使用**

# 4 手撸lombok经典注解

1. @AllArgsConstructor：创建全量参数的构造方法
1. @NoArgsConstructor：创建无参构造方法
1. @Data：为所有属性，创建set方法以及get方法
1. @Builder：创建Builder模式的静态内部类

## 4.1 目标

例如现在有一个DTO

```java
public class UserDTO {
    private String firstName;

    private String lastName;
}
```

我希望在编译期插入一些构造方法、set/get方法，以及一个Builder模式的静态内部类，如下

```java
public class TestUserDTO {
    private String firstName;
    private String lastName;

    public TestUserDTO() {
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getFirstName() {
        return this.firstName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getLastName() {
        return this.lastName;
    }

    public TestUserDTO(String firstName, String lastName) {
        this.firstName = firstName;
        this.lastName = lastName;
    }

    public static TestUserDTO.TestUserDTOBuilder builder() {
        return new TestUserDTO.TestUserDTOBuilder();
    }

    public static final class TestUserDTOBuilder {
        private String firstName;
        private String lastName;

        public TestUserDTOBuilder() {
        }

        public TestUserDTO.TestUserDTOBuilder firstName(String firstName) {
            this.firstName = firstName;
            return this;
        }

        public TestUserDTO.TestUserDTOBuilder lastName(String lastName) {
            this.lastName = lastName;
            return this;
        }

        public TestUserDTO build() {
            return new TestUserDTO(this.firstName, this.lastName);
        }
    }
}
```

## 4.2 插入式注解处理器源码

工程结构

```
.
├── annotation.iml
├── pom.xml
└── src
    └── main
        ├── java
        │   ├── classes
        │   └── org
        │       └── liuyehcf
        │           └── annotation
        │               └── source
        │                   ├── annotation
        │                   │   ├── AllArgsConstructor.java
        │                   │   ├── Builder.java
        │                   │   ├── Data.java
        │                   │   └── NoArgsConstructor.java
        │                   └── processor
        │                       ├── AllArgsConstructorProcessor.java
        │                       ├── BaseProcessor.java
        │                       ├── BuilderProcessor.java
        │                       ├── DataProcessor.java
        │                       ├── NoArgsConstructorProcessor.java
        │                       └── ProcessUtil.java
        └── resources
            ├── META-INF
            │   └── services
            │       └── javax.annotation.processing.Processor
            ├── UserDTO.java
            └── compile.sh
```

### 4.2.1 注解定义源码

**定义4个注解，源码如下：**

* 将`@Retention`指定为`RetentionPolicy.SOURCE`，即该注解仅在源码期间有效

#### 4.2.1.1 NoArgsConstructor

```java
package org.liuyehcf.annotation.source.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.SOURCE)
public @interface NoArgsConstructor {
}
```

#### 4.2.1.2 AllArgsConstructor

```java
package org.liuyehcf.annotation.source.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.SOURCE)
public @interface AllArgsConstructor {
}
```

#### 4.2.1.3 Data

```java
package org.liuyehcf.annotation.source.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.SOURCE)
public @interface Data {
}
```

#### 4.2.1.4 Builder

```java
package org.liuyehcf.annotation.source;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.SOURCE)
public @interface Builder {
}
```

### 4.2.2 注解处理器源码

**编写插入式注解处理器，要点如下：**

1. 重写`init`方法，获取一些必要的构建对象
1. 重写`process`方法，实现Builder逻辑，源码已经给出足够的注释，配合上一小节JSR-269 API的介绍，理解起来应该没什么大问题
1. 用`@SupportedAnnotationTypes`注解指明感兴趣的注解类型
1. 用`@SupportedSourceVersion`注解指明源码版本

#### 4.2.2.1 BaseProcessor

**注解处理器基类**，抽出了一些公用的字段以及初始化方法

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.api.JavacTrees;
import com.sun.tools.javac.processing.JavacProcessingEnvironment;
import com.sun.tools.javac.tree.TreeMaker;
import com.sun.tools.javac.util.Context;
import com.sun.tools.javac.util.Names;

import javax.annotation.processing.AbstractProcessor;
import javax.annotation.processing.Messager;
import javax.annotation.processing.ProcessingEnvironment;

public abstract class BaseProcessor extends AbstractProcessor {

    /**
     * 用于在编译器打印消息的组件
     */
    Messager messager;

    /**
     * 语法树
     */
    JavacTrees trees;

    /**
     * 用来构造语法树节点
     */
    TreeMaker treeMaker;

    /**
     * 用于创建标识符的对象
     */
    Names names;

    /**
     * 获取一些注解处理器执行处理逻辑时需要用到的一些关键对象
     *
     * @param processingEnv 处理环境
     */
    @Override
    public final synchronized void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        this.messager = processingEnv.getMessager();
        this.trees = JavacTrees.instance(processingEnv);
        Context context = ((JavacProcessingEnvironment) processingEnv).getContext();
        this.treeMaker = TreeMaker.instance(context);
        this.names = Names.instance(context);
    }
}
```

#### 4.2.2.2 ProcessUtil

**工具类**

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeMaker;
import com.sun.tools.javac.util.List;
import com.sun.tools.javac.util.ListBuffer;

import javax.lang.model.element.Modifier;
import java.util.Set;

class ProcessUtil {
    static final String THIS = "this";

    private static final String SET = "set";

    private static final String GET = "get";

    /**
     * 创建建造者的静态方法名
     */
    static final String BUILDER_STATIC_METHOD_NAME = "builder";

    /**
     * 建造方法名
     */
    static final String BUILD_METHOD_NAME = "build";

    /**
     * 构造方法名字，比较特殊
     */
    static final String CONSTRUCTOR_NAME = "<init>";

    /**
     * 克隆一个字段的语法树节点，该节点作为方法的参数
     * 具有位置信息的语法树节点是不能复用的！
     *
     * @param treeMaker           语法树节点构造器
     * @param prototypeJCVariable 字段的语法树节点
     * @return 方法参数的语法树节点
     */
    static JCTree.JCVariableDecl cloneJCVariableAsParam(TreeMaker treeMaker, JCTree.JCVariableDecl prototypeJCVariable) {
        return treeMaker.VarDef(
                treeMaker.Modifiers(Flags.PARAMETER), //访问标志。极其坑爹！！！
                prototypeJCVariable.name, //名字
                prototypeJCVariable.vartype, //类型
                null //初始化语句
        );
    }

    /**
     * 克隆一个字段的语法树节点集合，作为方法的参数列表
     *
     * @param treeMaker            语法树节点构造器
     * @param prototypeJCVariables 字段的语法树节点集合
     * @return 方法参数的语法树节点集合
     */
    static List<JCTree.JCVariableDecl> cloneJCVariablesAsParams(TreeMaker treeMaker, List<JCTree.JCVariableDecl> prototypeJCVariables) {
        ListBuffer<JCTree.JCVariableDecl> jcVariables = new ListBuffer<>();
        for (JCTree.JCVariableDecl jcVariable : prototypeJCVariables) {
            jcVariables.append(cloneJCVariableAsParam(treeMaker, jcVariable));
        }
        return jcVariables.toList();
    }

    /**
     * 判断是否是合法的字段
     *
     * @param jcTree 语法树节点
     * @return 是否是合法字段
     */
    private static boolean isValidField(JCTree jcTree) {
        if (jcTree.getKind().equals(JCTree.Kind.VARIABLE)) {
            JCTree.JCVariableDecl jcVariable = (JCTree.JCVariableDecl) jcTree;

            Set<Modifier> flagSets = jcVariable.mods.getFlags();
            return (!flagSets.contains(Modifier.STATIC)
                    && !flagSets.contains(Modifier.FINAL));
        }

        return false;
    }

    /**
     * 获取字段的语法树节点的集合
     *
     * @param jcClass 类的语法树节点
     * @return 字段的语法树节点的集合
     */
    static List<JCTree.JCVariableDecl> getJCVariables(JCTree.JCClassDecl jcClass) {
        ListBuffer<JCTree.JCVariableDecl> jcVariables = new ListBuffer<>();

        //遍历jcClass的所有内部节点，可能是字段，方法等等
        for (JCTree jcTree : jcClass.defs) {
            //找出所有set方法节点，并添加
            if (isValidField(jcTree)) {
                //注意这个com.sun.tools.javac.util.List的用法，不支持链式操作，更改后必须赋值
                jcVariables.append((JCTree.JCVariableDecl) jcTree);
            }
        }

        return jcVariables.toList();
    }

    /**
     * 判断是否为set方法
     *
     * @param jcTree 语法树节点
     * @return 判断是否是Set方法
     */
    private static boolean isSetJCMethod(JCTree jcTree) {
        if (jcTree.getKind().equals(JCTree.Kind.METHOD)) {
            JCTree.JCMethodDecl jcMethod = (JCTree.JCMethodDecl) jcTree;
            return jcMethod.name.toString().startsWith(SET)
                    && jcMethod.params.size() == 1
                    && !jcMethod.mods.getFlags().contains(Modifier.STATIC);
        }
        return false;
    }

    /**
     * 提取出所有set方法的语法树节点
     *
     * @param jcClass 类的语法树节点
     * @return set方法的语法树节点的集合
     */
    static List<JCTree.JCMethodDecl> getSetJCMethods(JCTree.JCClassDecl jcClass) {
        ListBuffer<JCTree.JCMethodDecl> setJCMethods = new ListBuffer<>();

        //遍历jcClass的所有内部节点，可能是字段，方法等等
        for (JCTree jcTree : jcClass.defs) {
            //找出所有set方法节点，并添加
            if (isSetJCMethod(jcTree)) {
                //注意这个com.sun.tools.javac.util.List的用法，不支持链式操作，更改后必须赋值
                setJCMethods.append((JCTree.JCMethodDecl) jcTree);
            }
        }

        return setJCMethods.toList();
    }

    /**
     * 判断是否存在无参构造方法
     *
     * @param jcClass 类的语法树节点
     * @return 是否存在
     */
    static boolean hasNoArgsConstructor(JCTree.JCClassDecl jcClass) {
        for (JCTree jcTree : jcClass.defs) {
            if (jcTree.getKind().equals(JCTree.Kind.METHOD)) {
                JCTree.JCMethodDecl jcMethod = (JCTree.JCMethodDecl) jcTree;
                if (CONSTRUCTOR_NAME.equals(jcMethod.name.toString())) {
                    if (jcMethod.params.isEmpty()) {
                        return true;
                    }
                }
            }
        }
        return false;
    }

    /**
     * 是否存在全参的构造方法
     *
     * @param jcVariables 字段的语法树节点集合
     * @param jcClass     类的语法树节点
     * @return 是否存在
     */
    static boolean hasAllArgsConstructor(List<JCTree.JCVariableDecl> jcVariables, JCTree.JCClassDecl jcClass) {
        for (JCTree jcTree : jcClass.defs) {
            if (jcTree.getKind().equals(JCTree.Kind.METHOD)) {
                JCTree.JCMethodDecl jcMethod = (JCTree.JCMethodDecl) jcTree;
                if (CONSTRUCTOR_NAME.equals(jcMethod.name.toString())) {
                    if (jcVariables.size() == jcMethod.params.size()) {
                        boolean isEqual = true;
                        for (int i = 0; i < jcVariables.size(); i++) {
                            if (!jcVariables.get(i).vartype.type.equals(jcMethod.params.get(i).vartype.type)) {
                                isEqual = false;
                                break;
                            }
                        }
                        if (isEqual) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    /**
     * 判断是否存在指定字段的set方法，返回类型不作为判断依据，因为Java中方法重载与返回类型无关
     *
     * @param jcVariable 字段的语法树节点
     * @param jcClass    类的语法树节点
     * @return 是否存在
     */
    static boolean hasSetMethod(JCTree.JCVariableDecl jcVariable, JCTree.JCClassDecl jcClass) {
        String setMethodName = fromPropertyNameToSetMethodName(jcVariable.name.toString());
        for (JCTree jcTree : jcClass.defs) {
            if (jcTree.getKind().equals(JCTree.Kind.METHOD)) {
                JCTree.JCMethodDecl jcMethod = (JCTree.JCMethodDecl) jcTree;
                if (setMethodName.equals(jcMethod.name.toString())
                        && jcMethod.params.size() == 1
                        && jcMethod.params.get(0).vartype.type.equals(jcVariable.vartype.type)) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 判断是否存在指定字段的get方法，返回类型不作为判断依据，因为Java中方法重载与返回类型无关
     *
     * @param jcVariable 字段的语法树节点
     * @param jcClass    类的语法树节点
     * @return 是否存在
     */
    static boolean hasGetMethod(JCTree.JCVariableDecl jcVariable, JCTree.JCClassDecl jcClass) {
        String getMethodName = fromPropertyNameToGetMethodName(jcVariable.name.toString());
        for (JCTree jcTree : jcClass.defs) {
            if (jcTree.getKind().equals(JCTree.Kind.METHOD)) {
                JCTree.JCMethodDecl jcMethod = (JCTree.JCMethodDecl) jcTree;
                if (getMethodName.equals(jcMethod.name.toString())
                        && jcMethod.params.size() == 0) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * 字段名转换为set方法名
     *
     * @param propertyName 字段名
     * @return set方法名
     */
    static String fromPropertyNameToSetMethodName(String propertyName) {
        return SET + propertyName.substring(0, 1).toUpperCase() + propertyName.substring(1);
    }

    /**
     * 字段名转换为get方法名
     *
     * @param propertyName 字段名
     * @return get方法名
     */
    static String fromPropertyNameToGetMethodName(String propertyName) {
        return GET + propertyName.substring(0, 1).toUpperCase() + propertyName.substring(1);
    }
}
```

#### 4.2.2.3 NoArgsConstructorProcessor

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.code.TypeTag;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.List;
import org.liuyehcf.annotation.source.annotation.NoArgsConstructor;

import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import java.util.Set;

import static org.liuyehcf.annotation.source.processor.ProcessUtil.CONSTRUCTOR_NAME;
import static org.liuyehcf.annotation.source.processor.ProcessUtil.hasNoArgsConstructor;

@SupportedAnnotationTypes("org.liuyehcf.annotation.source.annotation.NoArgsConstructor")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class NoArgsConstructorProcessor extends BaseProcessor {

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        //首先获取被NoArgsConstructor注解标记的元素
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(NoArgsConstructor.class);

        set.forEach(element -> {

            //获取当前元素的JCTree对象
            JCTree jcTree = trees.getTree(element);

            //JCTree利用的是访问者模式，将数据与数据的处理进行解耦，TreeTranslator就是访问者，这里我们重写访问类时的逻辑
            jcTree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClass) {
                    messager.printMessage(Diagnostic.Kind.NOTE, "@NoArgsConstructor process [" + jcClass.name.toString() + "] begin!");

                    //添加无参构造方法
                    if (!hasNoArgsConstructor(jcClass)) {
                        jcClass.defs = jcClass.defs.append(
                                createNoArgsConstructor()
                        );
                    }

                    messager.printMessage(Diagnostic.Kind.NOTE, "@NoArgsConstructor process [" + jcClass.name.toString() + "] end!");
                }
            });
        });

        return true;
    }

    /**
     * 创建无参数构造方法
     *
     * @return 无参构造方法语法树节点
     */
    private JCTree.JCMethodDecl createNoArgsConstructor() {

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , List.nil() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(CONSTRUCTOR_NAME), //名字
                treeMaker.TypeIdent(TypeTag.VOID), //返回类型
                List.nil(), //泛型形参列表
                List.nil(), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }
}
```

#### 4.2.2.4 AllArgsConstructorProcessor

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.code.TypeTag;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.List;
import com.sun.tools.javac.util.ListBuffer;
import org.liuyehcf.annotation.source.annotation.AllArgsConstructor;

import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import java.util.Set;

import static org.liuyehcf.annotation.source.processor.ProcessUtil.*;

@SupportedAnnotationTypes("org.liuyehcf.annotation.source.annotation.AllArgsConstructor")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class AllArgsConstructorProcessor extends BaseProcessor {

    /**
     * 字段的语法树节点的集合
     */
    private List<JCTree.JCVariableDecl> fieldJCVariables;

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        //首先获取被AllArgsConstructor注解标记的元素
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(AllArgsConstructor.class);

        set.forEach(element -> {

            //获取当前元素的JCTree对象
            JCTree jcTree = trees.getTree(element);

            //JCTree利用的是访问者模式，将数据与数据的处理进行解耦，TreeTranslator就是访问者，这里我们重写访问类时的逻辑
            jcTree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClass) {
                    messager.printMessage(Diagnostic.Kind.NOTE, "process class [" + jcClass.name.toString() + "], start");

                    before(jcClass);

                    //添加全参构造方法
                    if (!hasAllArgsConstructor(fieldJCVariables, jcClass)) {
                        jcClass.defs = jcClass.defs.append(
                                createAllArgsConstructor()
                        );
                    }

                    after();

                    messager.printMessage(Diagnostic.Kind.NOTE, "process class [" + jcClass.name.toString() + "], end");
                }
            });
        });

        return true;
    }

    /**
     * 进行一些初始化工作
     *
     * @param jcClass 类的语法树节点
     */
    private void before(JCTree.JCClassDecl jcClass) {
        this.fieldJCVariables = getJCVariables(jcClass);
    }

    /**
     * 进行一些清理工作
     */
    private void after() {
        this.fieldJCVariables = null;
    }

    /**
     * 创建全参数构造方法
     *
     * @return 全参构造方法语法树节点
     */
    private JCTree.JCMethodDecl createAllArgsConstructor() {

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();
        for (JCTree.JCVariableDecl jcVariable : fieldJCVariables) {
            //添加构造方法的赋值语句 " this.xxx = xxx; "
            jcStatements.append(
                    treeMaker.Exec(
                            treeMaker.Assign(
                                    treeMaker.Select(
                                            treeMaker.Ident(names.fromString(THIS)),
                                            names.fromString(jcVariable.name.toString())
                                    ),
                                    treeMaker.Ident(names.fromString(jcVariable.name.toString()))
                            )
                    )
            );
        }

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(CONSTRUCTOR_NAME), //名字
                treeMaker.TypeIdent(TypeTag.VOID), //返回类型
                List.nil(), //泛型形参列表
                cloneJCVariablesAsParams(treeMaker, fieldJCVariables), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }
}
```

#### 4.2.2.5 DataProcessor

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.code.TypeTag;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.List;
import com.sun.tools.javac.util.ListBuffer;
import org.liuyehcf.annotation.source.annotation.Data;

import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import java.util.Set;

import static org.liuyehcf.annotation.source.processor.ProcessUtil.*;

@SupportedAnnotationTypes("org.liuyehcf.annotation.source.annotation.Data")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class DataProcessor extends BaseProcessor {

    /**
     * 类的语法树节点
     */
    private JCTree.JCClassDecl jcClass;

    /**
     * 字段的语法树节点的集合
     */
    private List<JCTree.JCVariableDecl> fieldJCVariables;

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        //首先获取被Data注解标记的元素
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(Data.class);

        set.forEach(element -> {

            //获取当前元素的JCTree对象
            JCTree jcTree = trees.getTree(element);

            //JCTree利用的是访问者模式，将数据与数据的处理进行解耦，TreeTranslator就是访问者，这里我们重写访问类时的逻辑
            jcTree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClass) {
                    messager.printMessage(Diagnostic.Kind.NOTE, "@Data process [" + jcClass.name.toString() + "] begin!");

                    before(jcClass);

                    //添加全参构造方法
                    jcClass.defs = jcClass.defs.appendList(
                            createDataMethods()
                    );

                    after();

                    messager.printMessage(Diagnostic.Kind.NOTE, "@Data process [" + jcClass.name.toString() + "] end!");
                }
            });
        });

        return true;
    }

    /**
     * 进行一些初始化工作
     *
     * @param jcClass 类的语法树节点
     */
    private void before(JCTree.JCClassDecl jcClass) {
        this.jcClass = jcClass;
        this.fieldJCVariables = getJCVariables(jcClass);
    }

    /**
     * 进行一些清理工作
     */
    private void after() {
        this.jcClass = null;
        this.fieldJCVariables = null;
    }

    /**
     * 创建get/set方法
     *
     * @return get/set方法的语法树节点集合
     */
    private List<JCTree> createDataMethods() {
        ListBuffer<JCTree> dataMethods = new ListBuffer<>();

        for (JCTree.JCVariableDecl jcVariable : fieldJCVariables) {
            if (!jcVariable.mods.getFlags().contains(Modifier.FINAL)
                    && !hasSetMethod(jcVariable, jcClass)) {
                dataMethods.append(createSetJCMethod(jcVariable));
            }

            if (!hasGetMethod(jcVariable, jcClass)) {
                dataMethods.append(createGetJCMethod(jcVariable));
            }
        }

        return dataMethods.toList();
    }

    /**
     * 根据字段的语法树节点，创建对应的set方法
     *
     * @param jcVariable 字段的语法树节点
     * @return set方法的语法树节点
     */
    private JCTree.JCMethodDecl createSetJCMethod(JCTree.JCVariableDecl jcVariable) {

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加语句 " this.xxx = xxx; "
        jcStatements.append(
                treeMaker.Exec(
                        treeMaker.Assign(
                                treeMaker.Select(
                                        treeMaker.Ident(names.fromString(THIS)),
                                        jcVariable.name
                                ),
                                treeMaker.Ident(jcVariable.name)
                        )
                )
        );

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(fromPropertyNameToSetMethodName(jcVariable.name.toString())), //名字
                treeMaker.TypeIdent(TypeTag.VOID), //返回类型
                List.nil(), //泛型形参列表
                List.of(cloneJCVariableAsParam(treeMaker, jcVariable)), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }

    /**
     * 根据字段的语法树节点，创建对应的get方法的语法树节点
     *
     * @param jcVariable 字段的语法树节点
     * @return get方法的语法树节点
     */
    private JCTree.JCMethodDecl createGetJCMethod(JCTree.JCVariableDecl jcVariable) {
        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加语句 " return this.xxx; "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.Select(
                                treeMaker.Ident(names.fromString(THIS)),
                                jcVariable.name
                        )
                )
        );

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(fromPropertyNameToGetMethodName(jcVariable.name.toString())), //名字
                jcVariable.vartype, //返回类型
                List.nil(), //泛型形参列表
                List.nil(), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }
}
```

#### 4.2.2.6 BuilderProcessor

```java
package org.liuyehcf.annotation.source.processor;

import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.List;
import com.sun.tools.javac.util.ListBuffer;
import com.sun.tools.javac.util.Name;
import org.liuyehcf.annotation.source.annotation.Builder;

import javax.annotation.processing.RoundEnvironment;
import javax.annotation.processing.SupportedAnnotationTypes;
import javax.annotation.processing.SupportedSourceVersion;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.tools.Diagnostic;
import java.util.Set;

import static org.liuyehcf.annotation.source.processor.ProcessUtil.*;

@SupportedAnnotationTypes("org.liuyehcf.annotation.source.annotation.Builder")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class BuilderProcessor extends BaseProcessor {

    /**
     * 类名
     */
    private Name className;

    /**
     * Builder模式中的类名，例如原始类是User，那么建造者类名就是UserBuilder
     */
    private Name builderClassName;

    /**
     * 字段的语法树节点的集合
     */
    private List<JCTree.JCVariableDecl> fieldJCVariables;

    /**
     * 插入式注解处理器的处理逻辑
     *
     * @param annotations 注解
     * @param roundEnv    环境
     * @return 处理结果
     */
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        //首先获取被Builder注解标记的元素
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(Builder.class);

        set.forEach(element -> {

            //获取当前元素的JCTree对象
            JCTree jcTree = trees.getTree(element);

            //JCTree利用的是访问者模式，将数据与数据的处理进行解耦，TreeTranslator就是访问者，这里我们重写访问类时的逻辑
            jcTree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClass) {
                    messager.printMessage(Diagnostic.Kind.NOTE, "@Builder process [" + jcClass.name.toString() + "] begin!");

                    before(jcClass);

                    //添加builder方法
                    jcClass.defs = jcClass.defs.append(
                            createStaticBuilderMethod()
                    );

                    //添加静态内部类
                    jcClass.defs = jcClass.defs.append(
                            createJCClass()
                    );

                    after();

                    messager.printMessage(Diagnostic.Kind.NOTE, "@Builder process [" + jcClass.name.toString() + "] end!");
                }
            });
        });

        return true;
    }

    /**
     * 进行一些初始化工作
     *
     * @param jcClass 类的语法树节点
     */
    private void before(JCTree.JCClassDecl jcClass) {
        this.className = names.fromString(jcClass.name.toString());
        this.builderClassName = names.fromString(this.className + "Builder");
        this.fieldJCVariables = getJCVariables(jcClass);
    }

    /**
     * 进行一些清理工作
     */
    private void after() {
        this.className = null;
        this.builderClassName = null;
        this.fieldJCVariables = null;
    }

    /**
     * 创建静态方法，即builder方法，返回静态内部类的实例
     *
     * @return builder方法的语法树节点
     */
    private JCTree.JCMethodDecl createStaticBuilderMethod() {

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加Builder模式中的返回语句 " return new XXXBuilder(); "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.NewClass(
                                null, //尚不清楚含义
                                List.nil(), //泛型参数列表
                                treeMaker.Ident(builderClassName), //创建的类名
                                List.nil(), //参数列表
                                null //类定义，估计是用于创建匿名内部类
                        )
                )
        );

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC + Flags.STATIC), //访问标志
                names.fromString(BUILDER_STATIC_METHOD_NAME), //名字
                treeMaker.Ident(builderClassName), //返回类型
                List.nil(), //泛型形参列表
                List.nil(), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }

    /**
     * 创建一个类的语法树节点。作为Builder模式中的Builder类
     *
     * @return 创建出来的类的语法树节点
     */
    private JCTree.JCClassDecl createJCClass() {

        ListBuffer<JCTree> jcTrees = new ListBuffer<>();

        jcTrees.appendList(createVariables());
        jcTrees.appendList(createSetJCMethods());
        jcTrees.append(createBuildJCMethod());

        return treeMaker.ClassDef(
                treeMaker.Modifiers(Flags.PUBLIC + Flags.STATIC + Flags.FINAL), //访问标志
                builderClassName, //名字
                List.nil(), //泛型形参列表
                null, //继承
                List.nil(), //接口列表
                jcTrees.toList()); //定义
    }

    /**
     * 根据方法集合创建对应的字段的语法树节点集合
     *
     * @return 静态内部类的字段的语法树节点集合
     */
    private List<JCTree> createVariables() {
        ListBuffer<JCTree> jcVariables = new ListBuffer<>();

        for (JCTree.JCVariableDecl fieldJCVariable : fieldJCVariables) {
            jcVariables.append(
                    treeMaker.VarDef(
                            treeMaker.Modifiers(Flags.PRIVATE), //访问标志
                            names.fromString((fieldJCVariable.name.toString())), //名字
                            fieldJCVariable.vartype //类型
                            , null //初始化语句
                    )
            );
        }

        return jcVariables.toList();
    }

    /**
     * 创建方法的语法树节点的集合。作为Builder模式中的setXXX方法
     *
     * @return 方法节点集合
     */
    private List<JCTree> createSetJCMethods() {
        ListBuffer<JCTree> setJCMethods = new ListBuffer<>();

        for (JCTree.JCVariableDecl fieldJCVariable : fieldJCVariables) {
            setJCMethods.append(createSetJCMethod(fieldJCVariable));
        }

        return setJCMethods.toList();
    }

    /**
     * 创建一个方法的语法树节点。作为Builder模式中的setXXX方法
     *
     * @return 方法节点
     */
    private JCTree.JCMethodDecl createSetJCMethod(JCTree.JCVariableDecl jcVariable) {

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加语句 " this.xxx = xxx; "
        jcStatements.append(
                treeMaker.Exec(
                        treeMaker.Assign(
                                treeMaker.Select(
                                        treeMaker.Ident(names.fromString(THIS)),
                                        names.fromString(jcVariable.name.toString())
                                ),
                                treeMaker.Ident(names.fromString(jcVariable.name.toString()))
                        )
                )
        );

        //添加Builder模式中的返回语句 " return this; "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.Ident(names.fromString(THIS)
                        )
                )
        );

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(jcVariable.name.toString()), //名字
                treeMaker.Ident(builderClassName), //返回类型
                List.nil(), //泛型形参列表
                List.of(cloneJCVariableAsParam(treeMaker, jcVariable)), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }

    /**
     * 创建build方法的语法树节点
     *
     * @return build方法的语法树节点
     */
    private JCTree.JCMethodDecl createBuildJCMethod() {
        ListBuffer<JCTree.JCExpression> jcVariableExpressions = new ListBuffer<>();

        for (JCTree.JCVariableDecl jcVariable : fieldJCVariables) {
            jcVariableExpressions.append(
                    treeMaker.Select(
                            treeMaker.Ident(names.fromString(THIS)),
                            names.fromString(jcVariable.name.toString())
                    )
            );
        }

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        //添加返回语句 " return new XXX(arg1, arg2, ...); "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.NewClass(
                                null, //尚不清楚含义
                                List.nil(), //泛型参数列表
                                treeMaker.Ident(className), //创建的类名
                                jcVariableExpressions.toList(), //参数列表
                                null //类定义，估计是用于创建匿名内部类
                        )
                )
        );

        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 //访问标志
                , jcStatements.toList() //所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), //访问标志
                names.fromString(BUILD_METHOD_NAME), //名字
                treeMaker.Ident(className), //返回类型
                List.nil(), //泛型形参列表
                List.nil(), //参数列表
                List.nil(), //异常列表
                jcBlock, //方法体
                null //默认方法（可能是interface中的那个default）
        );
    }
}
```

## 4.3 测试

这个测试类没有放在main/java目录下是因为必须将Processor的编译过程与测试类的编译过程分开

### 4.3.1 UserDTO

```java
import org.liuyehcf.annotation.source.annotation.AllArgsConstructor;
import org.liuyehcf.annotation.source.annotation.Builder;
import org.liuyehcf.annotation.source.annotation.Data;
import org.liuyehcf.annotation.source.annotation.NoArgsConstructor;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class UserDTO {
    private String firstName;

    private String lastName;

    private Integer age;

    private String address;

    public static void main(String[] args) {
        UserDTO userDTO = UserDTO.builder()
                .firstName("明")
                .lastName("小")
                .age(25)
                .address("火星")
                .build();

        System.out.println(userDTO);
    }

    @Override
    public String toString() {
        return "UserDTO{" +
                "firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", age=" + age +
                ", address='" + address + '\'' +
                '}';
    }
}
```

### 4.3.2 compile.sh

```sh
#!/bin/bash

TARGET_DIR=./classes

# 删除目录
if [ -d ${TARGET_DIR} ]; then
    rm -rf ${TARGET_DIR}
fi

# 创建目录
mkdir ${TARGET_DIR}

# tools.jar的路径
TOOLS_PATH=${JAVA_HOME}/lib/tools.jar

# 编译Builder注解以及注解处理器
javac -cp ${TOOLS_PATH} $(find ../java -name "*.java")  -d ${TARGET_DIR}/

# 统计文件 `META-INF/services/javax.annotation.processing.Processor` 的行数
LINE_NUM=$(cat META-INF/services/javax.annotation.processing.Processor | wc -l)
LINE_NUM=$((LINE_NUM+1))

# 将文件 `META-INF/services/javax.annotation.processing.Processor` 中的内容合并成串，以','分隔
PROCESSORS=$(cat META-INF/services/javax.annotation.processing.Processor | awk '{ { printf $0 } if(NR < "'"${LINE_NUM}"'") { printf "," } }')

# 编译UserDTO.java，通过-process参数指定注解处理器
javac -cp ${TARGET_DIR} -d ${TARGET_DIR} -processor ${PROCESSORS} UserDTO.java

# 反编译静态内部类
javap -cp ${TARGET_DIR} -p UserDTO$UserDTOBuilder

# 运行UserDTO
java -cp ${TARGET_DIR} UserDTO

# 删除目录
rm -rf classes
```

运行后输出如下：

```
注: @Data process [UserDTO] begin!
注: @Data process [UserDTO] end!
注: @NoArgsConstructor process [UserDTO] begin!
注: @NoArgsConstructor process [UserDTO] end!
注: process class [UserDTO], start
注: process class [UserDTO], end
注: @Builder process [UserDTO] begin!
注: @Builder process [UserDTO] end!
Compiled from "UserDTO.java"
public class UserDTO {
  private java.lang.String firstName;
  private java.lang.String lastName;
  private java.lang.Integer age;
  private java.lang.String address;
  public UserDTO();
  public static void main(java.lang.String[]);
  public java.lang.String toString();
  public void setFirstName(java.lang.String);
  public java.lang.String getFirstName();
  public void setLastName(java.lang.String);
  public java.lang.String getLastName();
  public void setAge(java.lang.Integer);
  public java.lang.Integer getAge();
  public void setAddress(java.lang.String);
  public java.lang.String getAddress();
  public UserDTO(java.lang.String, java.lang.String, java.lang.Integer, java.lang.String);
  public static UserDTO$UserDTOBuilder builder();
}
UserDTO{firstName='明', lastName='小', age=25, address='火星'}
```

## 4.4 maven运行

上述命令行执行的过程比较复杂，而且需要在编译TestUserDTO的时候，通过-processor指定注解处理器的类型

如果我们想让上述过程自动发生，可以借助maven来实现

那么如何在调用的时候不用加参数呢，其实我们知道Java在编译的时候会去资源文件夹下读一个META-INF文件夹，这个文件夹下面除了MANIFEST.MF文件之外，还可以添加一个`services`文件夹，我们可以在这个文件夹下创建一个文件，文件名是`javax.annotation.processing.Processor`，具体内容将在下一小节给出

我们知道maven在编译前会先拷贝资源文件夹，然后当他在编译时候发现了资源文件夹下的META-INF/serivces文件夹时，他就会读取里面的文件，并将文件名所代表的接口用文件内容表示的类来实现。**这就相当于做了-processor参数该做的事了**

当然这个文件我们并不希望调用者去写，而是希望在processor项目里集成，调用的时候能直接继承META-INF

首先，创建名为builder（你可以随便取，为了方便描述，这里用builder）的maven工程，编写pom文件如下：

1. 配置tools.jar的本地依赖，该文件在JAVA_HOME中
1. 配置`<resource>`排除`META-INF/services/javax.annotation.processing.Processor`文件
1. 配置`<plugin>`，利用`maven-resources-plugin`在pre-package阶段将`META-INF/services/javax.annotation.processing.Processor`文件再拷贝到`target/classes`目录中

### 4.4.1 javax.annotation.processing.Processor

```
org.liuyehcf.annotation.source.processor.DataProcessor
org.liuyehcf.annotation.source.processor.NoArgsConstructorProcessor
org.liuyehcf.annotation.source.processor.AllArgsConstructorProcessor
org.liuyehcf.annotation.source.processor.BuilderProcessor
```

### 4.4.2 pom.xml文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <groupId>org.liuyehcf</groupId>
    <artifactId>annotation</artifactId>
    <version>1.0-SNAPSHOT</version>

    <dependencies>
        <dependency>
            <groupId>com.sun</groupId>
            <artifactId>tools</artifactId>
            <version>1.8</version>
            <scope>system</scope>
            <systemPath>${java.home}/../lib/tools.jar</systemPath>
        </dependency>
    </dependencies>

    <build>
        <resources>
            <resource>
                <directory>src/main/resources</directory>
                <excludes>
                    <exclude>META-INF/**/*</exclude>
                </excludes>
            </resource>
        </resources>

        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-resources-plugin</artifactId>
                <version>2.6</version>
                <executions>
                    <execution>
                        <id>process-META</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>copy-resources</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>target/classes</outputDirectory>
                            <resources>
                                <resource>
                                    <directory>${basedir}/src/main/resources/</directory>
                                    <includes>
                                        <include>**/*</include>
                                    </includes>
                                </resource>
                            </resources>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

</project>
```

# 5 参考

* [Javac早期(编译期)](https://www.cnblogs.com/wade-luffy/p/6050331.html)
* [Lombok简介](https://www.jianshu.com/p/365ea41b3573)
* [Lombok原理文章总结](http://blog.csdn.net/hotdust/article/details/75042465)
* [Lombok原理分析与功能实现](https://blog.mythsman.com/2017/12/19/1/)
* [Java API Examples](https://www.programcreek.com/java-api-examples/index.php?action=search)
* [grepcode](http://grepcode.com/search)
* [soucecode-github](https://github.com/liuyehcf/javac/tree/master/src/main/java/com/sun/tools/javac/tree)
* [TreeMake Q&A](http://wiki.netbeans.org/JavaHT_TreeMakerQA)

