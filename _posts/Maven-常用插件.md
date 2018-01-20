---
title: Maven-常用插件
date: 2018-01-19 16:59:56
tags:
---

# shade



# autoconfig

```xml
<plugin>
    <groupId>com.alibaba.citrus.tool</groupId>
    <artifactId>autoconfig-maven-plugin</artifactId>
    <version>1.2.1-SNAPSHOT</version>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>autoconfig</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

__搜索步骤__

1. 通过命令行-P参数指定profile的属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若根目录存在antx.properties属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若用户目录存在antx.properties属性文件
    * 若该属性文件中的属性值不全，那么会将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错
1. 若用户目录不存在antx.properties属性文件
    * 那么会在用户目录下新建该属性文件，并且将auto-config.xml中的默认值写入该属性文件中，若默认值为空，则报错


__对于web项目（打包方式为war）__，则会过滤所有依赖中包含占位符的文件

# 参考

* [maven-shade-plugin 入门指南](https://www.jianshu.com/p/7a0e20b30401)
* [maven-将依赖的 jar包一起打包到项目 jar 包中](https://www.jianshu.com/p/0c60f6ef3a4c)