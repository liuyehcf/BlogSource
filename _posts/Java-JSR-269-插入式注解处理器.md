---
title: Java-JSR-269-插入式注解处理器
date: 2018-02-02 19:04:57
tags: 
- 原创
categories: 
- Java
- Annotation
---

__目录__

<!-- toc -->
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

__Javac编译动作的入口是`com.sun.tools.javac.main.JavaCompiler`类__，上述3个过程的代码逻辑集中在这个类的__`compile()`和`compile2()`__方法中，下面给出整个编译过程中最关键的几个步骤

```Java
public void compile(List<JavaFileObject> var1, List<String> var2, Iterable<? extends Processor> var3) {
        // ... 

        this.initProcessAnnotations(var3); // (1)
        this.delegateCompiler = this.processAnnotations( // (4)
            this.enterTrees( // (3)
                this.stopIfError(
                    CompileState.PARSE, 
                    this.parseFiles(var1)  // (2)
                )
            ), 
            var2
        );
        this.delegateCompiler.compile2(); // (5)
        
        // ... 
}

private void compile2() {
    // ...
    
    this.generate( // (9)
        this.desugar( // (8)
            this.flow( // (7)
                this.attribute( // (6)
                    (Env)this.todo.remove()
                )
            )
        )
    );
    
    // ...
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

__词法分析是将源代码的字符流转变为标记（Token）集合__，单个字符是程序编写过程的最小元素，而标记则是编译过程的最小元素，关键字、变量名、字面量、运算符都可以成为标记，如`int a= b + 2`这句代码包含了6个标记，分别是`int`、`a`、`=`、`b`、`+`、`2`，虽然关键字int由3个字符构成，但是它只是一个Token，不可再拆分。__在Javac的源码中，词法分析过程由`com.sun.tools.javac.parser.Scanner`类来实现__

__语法分析是根据Token序列构造抽象语法树的过程__，抽象语法树（Abstract Syntax Tree,AST）是一种用来描述程序代码语法结构的树形表示方式，语法树的每一个节点都代表着程序代码中的一个语法结构（Construct），例如包、类型、修饰符、运算符、接口、返回值甚至代码注释等都可以是一个语法结构。在Javac的源码中，__语法分析过程由`com.sun.tools.javac.parser.Parser`类实现，这个阶段产出的抽象语法树由`com.sun.tools.javac.tree.JCTree`类表示__，经过这个步骤之后，编译器就基本不会再对源码文件进行操作了，后续的操作都建立在抽象语法树之上

## 1.2 填充符号表

完成了语法分析和词法分析之后，下一步就是填充符号表的过程，也就是`enterTrees()`方法（过程`(3)`）所做的事情。__符号表（Symbol Table）是由一组符号地址和符号信息构成的表格，可以把它想象成哈希表中K-V值对的形式（实际上符号表不一定是哈希表实现，可以是有序符号表、树状符号表、栈结构符号表等）__。符号表中所登记的信息在编译的不同阶段都要用到。在语义分析中，符号表所登记的内容将用于语义检查（如检查一个名字的使用和原先的说明是否一致）和产生中间代码。在目标代码生成阶段，当对符号名进行地址分配时，符号表是地址分配的依据。

__在Javac源代码中，填充符号表的过程由`com.sun.tools.javac.comp.Enter`类实现__，此过程的出口是一个待处理列表（To Do List），包含了每一个编译单元的抽象语法树的顶级节点，以及package-info.java（如果存在的话）的顶级节点。

# 2 JSR-269简介

在Javac源码中，插入式注解处理器的初始化过程是在`initPorcessAnnotations()`方法中完成的，而它的执行过程则是在`processAnnotations()`方法中完成的，这个方法判断是否还有新的注解处理器需要执行，如果有的话，通过`com.sun.tools.javac.processing.JavacProcessingEnvironment`类的`doProcessing()`方法生成一个新的JavaCompiler对象对编译的后续步骤进行处理

在JDK 1.5之后，Java语言提供了对注解（Annotation）的支持，这些注解与普通的Java代码一样，是在运行期间发挥作用的。__在JDK 1.6中实现了JSR-269规范JSR-269：Pluggable Annotations Processing API（插入式注解处理API）。提供了一组插入式注解处理器的标准API在编译期间对注解进行处理__。我们可以把它看做是一组编译器的插件，在这些插件里面，可以读取、修改、添加抽象语法树中的任意元素。__如果这些插件在处理注解期间对语法树进行了修改，编译器将回到解析及填充符号表的过程重新处理，直到所有插入式注解处理器都没有再对语法树进行修改为止，每一次循环称为一个Round，也就是第一张图中的回环过程__。 有了编译器注解处理的标准API后，我们的代码才有可能干涉编译器的行为，由于语法树中的任意元素，甚至包括代码注释都可以在插件之中访问到，所以通过插入式注解处理器实现的插件在功能上有很大的发挥空间。只要有足够的创意，程序员可以使用插入式注解处理器来实现许多原本只能在编码中完成的事情

我们知道编译器在把Java程序源码编译为字节码的时候，会对Java程序源码做各方面的检查校验。这些校验主要以程序“写得对不对”为出发点，虽然也有各种WARNING的信息，但总体来讲还是较少去校验程序“写得好不好”。__有鉴于此，业界出现了许多针对程序“写得好不好”的辅助校验工具，如CheckStyle、FindBug、Klocwork等。这些代码校验工具有一些是基于Java的源码进行校验，还有一些是通过扫描字节码来完成__

# 3 编译相关的数据结构与API

## 3.1 JCTree

JCTree是语法树元素的基类，__包含一个重要的字段`pos`，该字段用于指明当前语法树节点（JCTree）在语法树中的位置__，因此我们不能直接用new关键字来创建语法树节点，即使创建了也没有意义。此外，__结合访问者模式，将数据结构与数据的处理进行解耦__，部分源码如下：

```Java
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
    * JCIdent：`标识符`语法树节点，__可以是变量，类型，关键字等等__

## 3.2 TreeMaker

TreeMaker用于创建一系列`语法树节点`，__创建时会为创建出来的JCTree设置pos字段，所以必须用上下文相关的TreeMaker对象来创建语法树节点，而不能直接new语法树节点__

源码可以参考[TreeMaker DOC](http://www.docjar.com/docs/api/com/sun/tools/javac/tree/TreeMaker.html)

### 3.2.1 TreeMaker.Modifiers

TreeMaker.Modifiers方法用于创建`访问标志`语法树节点(JCModifiers)，源码如下：

1. flags：访问标志
1. annotations：注解列表

```Java
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

```Java
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

```Java
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

```Java
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

### 3.2.4 TreeMaker.VarDef

TreeMaker.VarDef用于创建`字段/变量定义`语法树节点（JCVariableDecl），源码如下：

1. mods：访问标志
1. vartype：类型
1. init：初始化语句
1. v：变量符号

```Java
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

```Java
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

```Java
public JCReturn Return(JCExpression expr) {
        JCReturn tree = new JCReturn(expr);
        tree.pos = pos;
        return tree;
}
```

### 3.2.7 TreeMaker.Select

TreeMaker.Select用于创建`域访问语句`语法树节点（JCFieldAccess），源码如下：

1. selected：`.`运算符左边的表达式
1. selector：`.`运算符右边的名字

```Java
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

```Java
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

```Java
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

```Java
public JCAssign Assign(JCExpression lhs,
    JCExpression rhs) {
        JCAssign tree = new JCAssign(lhs, rhs);
        tree.pos = pos;
        return tree;
}
```

### 3.2.11 TreeMaker.Exec

TreeMaker.Exec用于创建`可执行语句`语法树节点（JCExpressionStatement），源码如下：

```Java
public JCExpressionStatement Exec(JCExpression expr) {
        JCExpressionStatement tree = new JCExpressionStatement(expr);
        tree.pos = pos;
        return tree;
}
```

__例如，TreeMaker.Apply以及TreeMaker.Assign就需要外面包一层TreeMaker.Exec来获得一个JCExpressionStatement__

### 3.2.12 TreeMaker.Block

TreeMaker.Block用于创建`组合语句`语法树节点（JCBlock），源码如下：

1. flags：访问标志
1. stats：语句列表

```Java
public JCBlock Block(long flags,
    List<JCStatement> stats) {
        JCBlock tree = new JCBlock(flags, stats);
        tree.pos = pos;
        return tree;
}
```

## 3.3 com.sun.tools.javac.util.List

上述JSR-269 API中会涉及到一个List，这个List不是java.util.List，它是com.sun.tools.javac.util.List，这个List的操作比较奇特，不支持链式操作。下面给出部分源码，List包含两个字段，head和tail，其中head只是一个节点，而tail是一个List

```Java
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

# 4 手撸Builder

## 4.1 目标

例如现在有一个DTO

```Java
public class UserDTO {
    private String name;

    public void setName(String name) {
        this.name = name;
    }

    public void getName() {
        return this.name;
    }
}
```

我希望在编译期自动创建一个Builder模式的静态内部类，如下

```Java
public class UserDTO {
    private String name;

    public void setName(String name) {
        this.name = name;
    }

    public void getName() {
        return this.name;
    }

    public static final class UserDTOBuilder {
        private UserDTO data = new UserDTO();

        public UserDTO.UserDTOBuilder setName(String name) {
            this.data.setName(name);
            return this;
        }

        public UserDTO build() {
            return data;
        }
    }
}
```

## 4.2 插入式注解处理器源码

__定义Builder注解，源码如下：__

* 将`@Retention`指定为`RetentionPolicy.SOURCE`，即该注解仅在源码期间有效

```Java
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

__编写插入式注解处理器BuilderProcessor，源码如下：__

1. 重写`init`方法，获取一些必要的构建对象
1. 重写`process`方法，实现Builder逻辑，源码已经给出足够的注释，配合上一小节JSR-269 API的介绍，理解起来应该没什么大问题
1. 用`@SupportedAnnotationTypes`注解指明感兴趣的注解类型
1. 用`@SupportedSourceVersion`注解指明源码版本

```Java
package org.liuyehcf.annotation.source;

import com.sun.tools.javac.api.JavacTrees;
import com.sun.tools.javac.code.Flags;
import com.sun.tools.javac.processing.JavacProcessingEnvironment;
import com.sun.tools.javac.tree.JCTree;
import com.sun.tools.javac.tree.TreeMaker;
import com.sun.tools.javac.tree.TreeTranslator;
import com.sun.tools.javac.util.*;

import javax.annotation.processing.*;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import java.util.Set;

@SupportedAnnotationTypes("org.liuyehcf.annotation.source.Builder")
@SupportedSourceVersion(SourceVersion.RELEASE_8)
public class BuilderProcessor extends AbstractProcessor {

    private static final String IDENTIFIER_THIS = "this";

    private static final String IDENTIFIER_DATA = "data";

    private static final String IDENTIFIER_SET = "set";

    private static final String IDENTIFIER_BUILD = "build";

    /**
     * 用于在编译器打印消息的组件
     */
    private Messager messager;

    /**
     * 语法树
     */
    private JavacTrees trees;

    /**
     * 用来构造语法树节点
     */
    private TreeMaker treeMaker;

    /**
     * 创建标识符的方法
     */
    private Names names;

    /**
     * 插入式注解处理器的处理逻辑
     *
     * @param annotations
     * @param roundEnv
     * @return
     */
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {
        // 首先获取被Builder注解标记的元素
        Set<? extends Element> set = roundEnv.getElementsAnnotatedWith(Builder.class);

        set.forEach(element -> {

            // 获取当前元素的JCTree对象
            JCTree jcTree = trees.getTree(element);

            // JCTree利用的是访问者模式，将数据与数据的处理进行解耦，TreeTranslator就是访问者，这里我们重写访问类时的逻辑
            jcTree.accept(new TreeTranslator() {
                @Override
                public void visitClassDef(JCTree.JCClassDecl jcClassDecl) {

                    // 为当前jcClassDecl添加JCTree节点
                    jcClassDecl.defs = jcClassDecl.defs.append(
                            // 创建了一个静态内部类作为一个Builder
                            createJCClassDecl(
                                    jcClassDecl,
                                    getSetJCMethodDecls(jcClassDecl)
                            )
                    );
                }
            });
        });

        return true;
    }

    /**
     * 提取出所有set方法
     *
     * @param jcClassDecl
     * @return
     */
    private List<JCTree.JCMethodDecl> getSetJCMethodDecls(JCTree.JCClassDecl jcClassDecl) {
        List<JCTree.JCMethodDecl> setJCMethodDecls = List.nil();

        // 遍历jcClassDecl的所有内部节点，可能是字段，方法等等
        for (JCTree jTree : jcClassDecl.defs) {
            // 找出所有set方法节点，并添加
            if (isSetJCMethodDecl(jTree)) {
                // 注意这个com.sun.tools.javac.util.List的用法，不支持链式操作，更改后必须赋值
                setJCMethodDecls = setJCMethodDecls.prepend((JCTree.JCMethodDecl) jTree);
            }
        }

        return setJCMethodDecls;
    }

    /**
     * 判断是否为set方法
     *
     * @param jTree
     * @return
     */
    private boolean isSetJCMethodDecl(JCTree jTree) {
        if (jTree.getKind().equals(JCTree.Kind.METHOD)) {
            JCTree.JCMethodDecl jcMethodDecl = (JCTree.JCMethodDecl) jTree;
            if (jcMethodDecl.getName().startsWith(getNameFromString(IDENTIFIER_SET))
                    && jcMethodDecl.getParameters().size() == 1) {
                return true;
            }
        }
        return false;
    }

    private Name getNameFromString(String name) {
        return names.fromString(name);
    }

    /**
     * 创建一个语法树节点，其类型为JCClassDecl。作为Builder模式中的Builder类
     *
     * @param jcClassDecl
     * @param jcMethodDecls
     * @return
     */
    private JCTree.JCClassDecl createJCClassDecl(JCTree.JCClassDecl jcClassDecl, List<JCTree.JCMethodDecl> jcMethodDecls) {

        List<JCTree> jcTrees = List.nil();

        JCTree.JCVariableDecl jcVariableDecl = createDataField(jcClassDecl);
        jcTrees = jcTrees.append(jcVariableDecl);
        jcTrees = jcTrees.appendList(createSetJCMethodDecls(jcClassDecl, jcMethodDecls, jcVariableDecl));
        jcTrees = jcTrees.append(createBuildJCMethodDecl(jcClassDecl));

        return treeMaker.ClassDef(
                treeMaker.Modifiers(Flags.PUBLIC + Flags.STATIC + Flags.FINAL), // 访问标志
                getNameFromString(jcClassDecl.getSimpleName().toString() + "Builder"), // 名字
                List.nil(), // 泛型形参列表
                null, // 继承
                List.nil(), // 接口列表
                jcTrees); // 定义
    }

    /**
     * 创建一个语法树节点，其类型为JCVariableDecl。作为Builder模式中被Build的对象
     *
     * @param jcClassDecl
     * @return
     */
    private JCTree.JCVariableDecl createDataField(JCTree.JCClassDecl jcClassDecl) {
        return treeMaker.VarDef(
                treeMaker.Modifiers(Flags.PRIVATE), // 访问标志
                getNameFromString(IDENTIFIER_DATA), // 名字
                treeMaker.Ident(getNameFromString(jcClassDecl.getSimpleName().toString())), // 类型
                createInitializeJCExpression(jcClassDecl) // 初始化表达式
        );
    }

    /**
     * 创建一个语法树节点，其类型为JCExpression。即" new XXX(); "的语句
     *
     * @param jcClassDecl
     * @return
     */
    private JCTree.JCExpression createInitializeJCExpression(JCTree.JCClassDecl jcClassDecl) {
        return treeMaker.NewClass(
                null, // 尚不清楚含义
                List.nil(), // 构造器方法参数
                treeMaker.Ident(jcClassDecl.getSimpleName()), // 创建的类名
                List.nil(), // 构造器方法列表
                null // 尚不清楚含义
        );
    }

    /**
     * 创建一些语法树节点，其类型为JCMethodDecl。作为Builder模式中的setXXX方法
     *
     * @param jcClassDecl
     * @param methodDecls
     * @param jcVariableDecl
     * @return
     */
    private List<JCTree> createSetJCMethodDecls(JCTree.JCClassDecl jcClassDecl, List<JCTree.JCMethodDecl> methodDecls, JCTree.JCVariableDecl jcVariableDecl) {
        List<JCTree> setJCMethodDecls = List.nil();

        for (JCTree.JCMethodDecl jcMethodDecl : methodDecls) {
            setJCMethodDecls = setJCMethodDecls.append(createSetJCMethodDecl(jcClassDecl, jcMethodDecl));
        }

        return setJCMethodDecls;
    }

    /**
     * 创建一个语法树节点，其类型为JCMethodDecl。作为Builder模式中的setXXX方法
     *
     * @param jcClassDecl
     * @param jcMethodDecl
     * @return
     */
    private JCTree.JCMethodDecl createSetJCMethodDecl(JCTree.JCClassDecl jcClassDecl, JCTree.JCMethodDecl jcMethodDecl) {
        JCTree.JCVariableDecl jcVariableDecl = jcMethodDecl.getParameters().get(0);

        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        // 添加调用语句" data.setXXX(xxx); "
        jcStatements.append(
                treeMaker.Exec(
                        treeMaker.Apply(
                                List.nil(),
                                treeMaker.Select(
                                        treeMaker.Ident(getNameFromString(IDENTIFIER_DATA)),
                                        jcMethodDecl.getName()
                                ),
                                List.of(treeMaker.Ident(jcVariableDecl.getName()))
                        )
                )
        );

        // 添加Builder模式中的返回语句 " return this; "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.Ident(getNameFromString(IDENTIFIER_THIS)
                        )
                )
        );

        // 转换成代码块
        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 // 访问标志
                , jcStatements.toList() // 所有的语句
        );

        return treeMaker.MethodDef(
                jcMethodDecl.getModifiers(), // 访问标志
                jcMethodDecl.getName(), // 名字
                treeMaker.Ident(getNameFromString(jcClassDecl.getSimpleName().toString() + "Builder")), // 返回类型
                jcMethodDecl.getTypeParameters(), // 泛型形参列表
                List.of(copyJCVariableDecl(jcVariableDecl)), // 参数列表，这里必须创建一个新的JCVariableDecl，否则注解处理时就会抛异常，原因目前还不清楚
                jcMethodDecl.getThrows(), // 异常列表
                jcBlock, // 方法体
                null // 默认值
        );
    }

    private JCTree.JCMethodDecl createBuildJCMethodDecl(JCTree.JCClassDecl jcClassDecl) {
        ListBuffer<JCTree.JCStatement> jcStatements = new ListBuffer<>();

        // 添加返回语句 " return data; "
        jcStatements.append(
                treeMaker.Return(
                        treeMaker.Ident(
                                getNameFromString(IDENTIFIER_DATA)
                        )
                )
        );

        // 转换成代码块
        JCTree.JCBlock jcBlock = treeMaker.Block(
                0 // 访问标志
                , jcStatements.toList() // 所有的语句
        );

        return treeMaker.MethodDef(
                treeMaker.Modifiers(Flags.PUBLIC), // 访问标志
                getNameFromString(IDENTIFIER_BUILD), // 名字
                treeMaker.Ident(jcClassDecl.getSimpleName()), // 返回类型
                List.nil(), // 泛型形参列表
                List.nil(), // 参数列表，这里必须创建一个新的JCVariableDecl，否则注解处理时就会抛异常，原因目前还不清楚
                List.nil(), // 异常列表
                jcBlock, // 方法体
                null // 默认值
        );
    }

    /**
     * 克隆一个JCVariableDecl语法树节点
     * 我觉得TreeMaker.MethodDef()方法需要克隆参数列表的原因是：从JCMethodDecl拿到的JCVariableDecl会与这个JCMethodDecl有关联，因此需要创建一个与该JCMethodDecl无关的语法树节点（JCVariableDecl）
     *
     * @param prototypeJCVariableDecl
     * @return
     */
    private JCTree.JCVariableDecl copyJCVariableDecl(JCTree.JCVariableDecl prototypeJCVariableDecl) {
        return treeMaker.VarDef(prototypeJCVariableDecl.sym, prototypeJCVariableDecl.getNameExpression());
    }

    /**
     * 获取一些注解处理器执行处理逻辑时需要用到的一些关键对象
     *
     * @param processingEnv
     */
    @Override
    public synchronized void init(ProcessingEnvironment processingEnv) {
        super.init(processingEnv);
        this.messager = processingEnv.getMessager();
        this.trees = JavacTrees.instance(processingEnv);
        Context context = ((JavacProcessingEnvironment) processingEnv).getContext();
        this.treeMaker = TreeMaker.instance(context);
        this.names = Names.instance(context);
    }
}
```

__编写测试类，源码如下__

```Java
package org.liuyehcf.annotation.source;

import org.liuyehcf.annotation.source.Builder;

@Builder
public class TestUserDTO {
    private String firstName;

    private String lastName;

    private Integer age;

    private String address;

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "firstName: " + firstName + "\n" +
                "lastName: " + lastName + "\n" +
                "age: " + age + "\n" +
                "address: " + address;
    }

    public static void main(String[] args) {
        TestUserDTO.TestUserDTOBuilder builder = new TestUserDTO.TestUserDTOBuilder();

        TestUserDTO userDTO = builder.setFirstName("小")
                .setLastName("六")
                .setAge(100)
                .setAddress("中国")
                .build();

        System.out.println(userDTO);
    }
}
```

## 4.3 命令行运行

编写完之后，接下来就是运行，首先我们来看一下文件结构

```
.
├── src
│   └── org
│       ├── liuyehcf
│       │   └── annotation
│       │       └── source
|       |           |── Builder.java
|       |           |── BuilderProcessor.java
|       |           |── TestUserDTO.java
```

要运TestUserDTO之前，我们需要编译Builder以及BuilderProcessor，然后在编译TestUserDTO时指定插入式注解处理器。于是，我们编写如下脚本来执行上述过程

```bash
#!/bin/bash

if [ -d classes ]; then
    rm -rf classes;
fi

mkdir classes

TOOLS_PATH="/Library/Java/JavaVirtualMachines/jdk1.8.0_121.jdk/Contents/Home/lib/tools.jar"

# 编译Builder注解以及注解处理器
javac -classpath ${TOOLS_PATH} src/org/liuyehcf/annotation/source/Builder.java src/org/liuyehcf/annotation/source/BuilderProcessor.java -d classes/

# 编译TestUserDTO.java，通过-process参数指定注解处理器
javac -classpath classes -d classes -processor org.liuyehcf.annotation.source.BuilderProcessor src/org/liuyehcf/annotation/source/TestUserDTO.java

# 反编译静态内部类
javap -classpath classes -p org.liuyehcf.annotation.source.TestUserDTO.TestUserDTOBuilder

# 运行UserDTO
java -classpath classes org.liuyehcf.annotation.source.TestUserDTO

```

运行后输出如下：

```
Compiled from "TestUserDTO.java"
public final class org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder {
  private org.liuyehcf.annotation.source.TestUserDTO data;
  public org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder();
  public org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder setAddress(java.lang.String);
  public org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder setAge(java.lang.Integer);
  public org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder setLastName(java.lang.String);
  public org.liuyehcf.annotation.source.TestUserDTO$TestUserDTOBuilder setFirstName(java.lang.String);
  public org.liuyehcf.annotation.source.TestUserDTO build();
}
firstName: 小
lastName: 六
age: 100
address: 中国
```

## 4.4 maven运行

上述命令行执行的过程比较复杂，而且需要在编译TestUserDTO的时候，通过-processor指定注解处理器的类型

如果我们想让上述过程自动发生，可以借助maven来实现。

那么如何在调用的时候不用加参数呢，其实我们知道Java在编译的时候会去资源文件夹下读一个META-INF文件夹，这个文件夹下面除了MANIFEST.MF文件之外，还可以添加一个`services`文件夹，我们可以在这个文件夹下创建一个文件，文件名是`javax.annotation.processing.Processor`，文件内容是`org.liuyehcf.annotation.source.BuilderProcessor`

我们知道maven在编译前会先拷贝资源文件夹，然后当他在编译时候发现了资源文件夹下的META-INF/serivces文件夹时，他就会读取里面的文件，并将文件名所代表的接口用文件内容表示的类来实现。__这就相当于做了-processor参数该做的事了__。

当然这个文件我们并不希望调用者去写，而是希望在processor项目里集成，调用的时候能直接继承META-INF

首先，创建名为builder（你可以随便取，为了方便描述，这里用builder）的maven工程，编写pom文件如下：

1. 配置tools.jar的本地依赖，该文件在JAVA_HOME中
1. 配置`<resource>`排除`META-INF/services/javax.annotation.processing.Processor`文件
1. 配置`<plugin>`，利用`maven-resources-plugin`在pre-package阶段将`META-INF/services/javax.annotation.processing.Processor`文件再拷贝到`target/classes`目录中

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http:// maven.apache.org/POM/4.0.0"
         xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
    
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>builder</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>builder</name>

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

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.6.0</version>
                <configuration>
                    <source>1.8</source>
                    <target>1.8</target>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

此时builder工程的文件结构大致如下：

```
.
├── pom.xml
├── src
│   └── main
│       ├── java
│       │   └── org
│       │       └── liuyehcf
│       │           └── annotation
|       |               └── source
|       |                   |── Builder.java
|       |                   |── BuilderProcessor.java
│       └── resources
│           └── META-INF
│               └── services
│                   └── javax.annotation.processing.Processor

```

执行命令`mvn clean install`，输出如下

```
[INFO] Scanning for projects...
[INFO]
[INFO] ------------------------------------------------------------------------
[INFO] Building builder 1.0-SNAPSHOT
[INFO] ------------------------------------------------------------------------
[INFO]
[INFO] --- maven-clean-plugin:2.5:clean (default-clean) @ builder ---
[INFO] Deleting /Users/HCF/Desktop/maven/target
[INFO]
[INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ builder ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 0 resource
[INFO]
[INFO] --- maven-compiler-plugin:3.6.0:compile (default-compile) @ builder ---
[INFO] Changes detected - recompiling the module!
[WARNING] File encoding has not been set, using platform encoding UTF-8, i.e. build is platform dependent!
[INFO] Compiling 2 source files to /Users/HCF/Desktop/maven/target/classes
[INFO]
[INFO] --- maven-resources-plugin:2.6:testResources (default-testResources) @ builder ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] skip non existing resourceDirectory /Users/HCF/Desktop/maven/src/test/resources
[INFO]
[INFO] --- maven-compiler-plugin:3.6.0:testCompile (default-testCompile) @ builder ---
[INFO] No sources to compile
[INFO]
[INFO] --- maven-surefire-plugin:2.12.4:test (default-test) @ builder ---
[INFO] No tests to run.
[INFO]
[INFO] --- maven-resources-plugin:2.6:copy-resources (process-META) @ builder ---
[WARNING] Using platform encoding (UTF-8 actually) to copy filtered resources, i.e. build is platform dependent!
[INFO] Copying 1 resource
[INFO]
[INFO] --- maven-jar-plugin:2.4:jar (default-jar) @ builder ---
[INFO] Building jar: /Users/HCF/Desktop/maven/target/builder-1.0-SNAPSHOT.jar
[INFO]
[INFO] --- maven-install-plugin:2.4:install (default-install) @ builder ---
[INFO] Installing /Users/HCF/Desktop/maven/target/builder-1.0-SNAPSHOT.jar to /Users/HCF/.m2/repository/org/liuyehcf/builder/1.0-SNAPSHOT/builder-1.0-SNAPSHOT.jar
[INFO] Installing /Users/HCF/Desktop/maven/pom.xml to /Users/HCF/.m2/repository/org/liuyehcf/builder/1.0-SNAPSHOT/builder-1.0-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 1.572 s
[INFO] Finished at: 2018-02-03T22:16:44+08:00
[INFO] Final Memory: 23M/306M
[INFO] ------------------------------------------------------------------------
```

__至此，builder工程构建成功__

---

__接下来，创建另一个名为test的maven工程__，编写pom文件如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http:// www.w3.org/2001/XMLSchema-instance"
         xmlns="http:// maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http:// maven.apache.org/POM/4.0.0 http:// maven.apache.org/xsd/maven-4.0.0.xsd">
        
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.liuyehcf</groupId>
    <artifactId>test</artifactId>
    <packaging>jar</packaging>
    <version>1.0-SNAPSHOT</version>
    <name>test</name>

    <dependencies>
        <dependency>
            <groupId>org.liuyehcf</groupId>
            <artifactId>builder</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>

</project>
```

此时builder工程的文件结构大致如下：

```
.
├── pom.xml
├── src
│   └── main
│       ├── java
│       │   └── org
│       │       └── liuyehcf
│       │           └── annotation
|       |               └── source
|       |                  |── TestUserDTO.java
```

执行命令

1. `mvn clean compile`
1. `java -classpath target/classes org.liuyehcf.annotation.source.TestUserDTO`

输出如下

```
firstName: 小
lastName: 六
age: 100
address: 中国
```

__DONE__

# 5 参考

* [Lombok简介](https://www.jianshu.com/p/365ea41b3573)
* [Lombok原理文章总结](http://blog.csdn.net/hotdust/article/details/75042465)
* [Lombok原理分析与功能实现](https://blog.mythsman.com/2017/12/19/1/)
* [Java:Annotation(注解)--原理到案例](https://www.jianshu.com/p/28edf5352b63)
* [Javac早期(编译期)](https://www.cnblogs.com/wade-luffy/p/6050331.html)
* [DocJar: Search Open Source Java API](http://www.docjar.com/index.html)
* [Java Code Examples for com.sun.tools.javac.tree.JCTree.JCMethodDecl](https://www.programcreek.com/java-api-examples/index.php?api=com.sun.tools.javac.tree.JCTree.JCMethodDecl)
* [grepcode](http://grepcode.com/file/repository.grepcode.com/java/root/jdk/openjdk/6-b14/com/sun/tools/javac/tree/TreeMaker.java#TreeMaker.Apply%28com.sun.tools.javac.util.List%2Ccom.sun.tools.javac.tree.JCTree.JCExpression%2Ccom.sun.tools.javac.util.List%29)
* [AlbertoSH/MagicBuilder](https://github.com/AlbertoSH/MagicBuilder/tree/master/magic-builder-compiler/src/main/java/com/github/albertosh)
