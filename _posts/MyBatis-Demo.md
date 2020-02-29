---
title: MyBatis-Demo
date: 2018-02-07 09:22:04
tags: 
- 原创
categories: 
- Java
- Framework
- MyBatis
---

__阅读更多__

<!--more-->

# 1 纯MyBatisDemo

## 1.1 Demo目录结构

```
.
├── pom.xml
└── src
    ├── main
    │   ├── java
    │   │   └── org
    │   │       └── liuyehcf
    │   │           └── mybatis
    │   │               ├── CrmUserDAO.java
    │   │               └── CrmUserDO.java
    │   └── resources
    │       ├── logback.xml
    │       ├── mybatis-config.xml
    │       ├── org
    │       │   └── liuyehcf
    │       │       └── mybatis
    │       │           └── crm-user.xml
    │       └── testDatabase.sql
    └── test
        └── java
            └── org
                └── liuyehcf
                    └── mybatis
                        ├── TestTemplate.java
                        ├── TestWithParam.java
                        └── TestWithoutParam.java
```

## 1.2 pom文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <groupId>org.liuyehcf</groupId>
    <artifactId>mybatis</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modelVersion>4.0.0</modelVersion>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
        </dependency>

        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>1.2.3</version>
        </dependency>

        <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.5</version>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <version>6.0.6</version>
        </dependency>
    </dependencies>

    <build>
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
        </plugins>
    </build>
</project>
```

## 1.3 mybatis-config.xml

MyBatis配置文件

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <!-- 定义别名 -->
    <typeAliases>
        <typeAlias alias="crmUserDO" type="org.liuyehcf.mybatis.CrmUserDO"/>
    </typeAliases>

    <!-- 定义数据库信息，默认使用id为development的environment -->
    <environments default="development">
        <environment id="development">
            <!-- 采用JDBC事务管理 -->
            <transactionManager type="JDBC"/>

            <!-- 配置数据库连接信息 -->
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver"/>
                <property name="url" value="jdbc:mysql://127.0.0.1:3306/mybatis"/>
                <property name="username" value="root"/>
                <property name="password" value="123456"/>
            </dataSource>
        </environment>
    </environments>

    <!-- 定义映射器 -->
    <mappers>
        <mapper resource="org/liuyehcf/mybatis/crm-user.xml"/>
    </mappers>
</configuration>
```

## 1.4 Java源码清单

### 1.4.1 CrmUserDAO.java

映射器（Mapper）的Java接口。__为了搞清参数传递的方式，这里的参数命名比较恶心，接口中的参数名字anyName在映射器配置文件中不会出现__

```java
package org.liuyehcf.mybatis;

import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * Created by HCF on 2017/3/31.
 */
public interface CrmUserDAO {

    CrmUserDO selectById(Long anyName);

    int insert(CrmUserDO anyName);

    int update(CrmUserDO anyName);

    List<CrmUserDO> selectByFirstName(String anyName);

    List<CrmUserDO> selectByFirstNameAndLastName(String anyName1, String anyName2);

    CrmUserDO selectByIdWithParam(@Param("specificName") Long anyName);

    int insertWithParam(@Param("specificName") CrmUserDO anyName);

    int updateWithParam(@Param("specificName") CrmUserDO anyName);

    List<CrmUserDO> selectByFirstNameWithParam(@Param("specificName") String anyName);

    List<CrmUserDO> selectByFirstNameAndLastNameWithParam(@Param("specificName1") String anyName1, @Param("specificName2") String anyName2);

}
```

### 1.4.2 CrmUserDO.java

DataObject

```java
package org.liuyehcf.mybatis;

/**
 * Created by HCF on 2017/3/31.
 */
public class CrmUserDO {
    private Long id;
    private String firstName;
    private String lastName;
    private Integer age;
    private Boolean sex;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public Boolean getSex() {
        return sex;
    }

    public void setSex(Boolean sex) {
        this.sex = sex;
    }

    @Override
    public String toString() {
        return '{' +
                "id:'" + id + '\'' +
                ", firstName: '" + firstName + '\'' +
                ", lastName: '" + lastName + '\'' +
                ", age: '" + age + '\'' +
                ", sex: '" + sex + '\''
                + "" +
                '}';
    }
}
```

### 1.4.3 TestTemplate.java

测试模板类，由于测试方法中每次都需要构造SqlSessionFactory，然后用SqlSessionFactory获取一个SqlSession，利用SqlSession执行相应的SQL操作之后，提交或者回滚，最后关闭SqlSession，这些操作都是可以固化的，因此使用模板方法模式

```java
package org.liuyehcf.mybatis;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

import java.io.IOException;
import java.io.InputStream;

public abstract class TestTemplate {

    static final String DEFAULT_FIRST_NAME = "default_first_name";
    static final String DEFAULT_LAST_NAME = "default_last_name";
    static final Integer DEFAULT_AGE = 100;
    static final Boolean DEFAULT_SEX = true;

    static final String MODIFIED_FIRST_NAME = "modified_first_name";
    static final String MODIFIED_LAST_NAME = "modified_last_name";
    static final Boolean MODIFIED_SEX = false;

    static final Long ID = 1L;

    public void execute() {
        String resource = "mybatis-config.xml";
        InputStream inputStream;
        try {
            inputStream = Resources.getResourceAsStream(resource);
        } catch (IOException e) {
            System.err.println(e.getMessage());
            e.printStackTrace();
            return;
        }

        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);

        SqlSession sqlSession = null;
        try {
            sqlSession = sqlSessionFactory.openSession();

            doExecute(sqlSession);

            sqlSession.commit();
        } catch (Exception e) {
            if (sqlSession != null) {
                sqlSession.rollback();
            }
            System.err.println(e.getMessage());
            e.printStackTrace();
        } finally {
            if (sqlSession != null) {
                sqlSession.close();
            }
        }
    }

    protected abstract void doExecute(SqlSession sqlSession) throws Exception;
}
```

### 1.4.4 TestWithParam.java

测试含有@Param注解的方法

```java
package org.liuyehcf.mybatis;

import org.apache.ibatis.session.SqlSession;
import org.junit.Test;

import java.util.List;

public class TestWithParam {
    @Test
    public void select() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = mapper.selectByIdWithParam(ID);

                System.out.println(crmUserDO);
            }
        }.execute();
    }

    @Test
    public void insert() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = new CrmUserDO();
                crmUserDO.setFirstName(DEFAULT_FIRST_NAME);
                crmUserDO.setLastName(DEFAULT_LAST_NAME);
                crmUserDO.setAge(DEFAULT_AGE);
                crmUserDO.setSex(DEFAULT_SEX);

                System.out.println("before insert: " + crmUserDO);
                mapper.insertWithParam(crmUserDO);
                System.out.println("after insert: " + crmUserDO);
            }
        }.execute();
    }

    @Test
    public void update() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = new CrmUserDO();

                crmUserDO.setId(ID);
                crmUserDO.setLastName(MODIFIED_LAST_NAME);
                crmUserDO.setFirstName(MODIFIED_FIRST_NAME);
                crmUserDO.setSex(MODIFIED_SEX);

                mapper.updateWithParam(crmUserDO);

                System.out.println(mapper.selectByIdWithParam(ID));
            }
        }.execute();
    }

    @Test
    public void selectByFirstName() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                List<CrmUserDO> crmUserDOS = mapper.selectByFirstNameWithParam(MODIFIED_FIRST_NAME);

                System.out.println(crmUserDOS.size());
            }
        }.execute();
    }

    @Test
    public void selectByFirstNameAndLastName() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                List<CrmUserDO> crmUserDOS;

                crmUserDOS = mapper.selectByFirstNameAndLastNameWithParam(MODIFIED_FIRST_NAME, null);
                System.out.println(crmUserDOS.size());

                crmUserDOS = mapper.selectByFirstNameAndLastNameWithParam(null, MODIFIED_LAST_NAME);
                System.out.println(crmUserDOS.size());

                crmUserDOS = mapper.selectByFirstNameAndLastNameWithParam(MODIFIED_FIRST_NAME, MODIFIED_LAST_NAME);
                System.out.println(crmUserDOS.size());
            }
        }.execute();
    }
}
```

### 1.4.5 TestWithoutParam.java

测试不含有@Param注解的方法

```java
package org.liuyehcf.mybatis;

import org.apache.ibatis.session.SqlSession;
import org.junit.Test;

import java.util.List;

public class TestWithoutParam {

    @Test
    public void select() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = mapper.selectById(ID);

                System.out.println(crmUserDO);
            }
        }.execute();
    }

    @Test
    public void insert() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = new CrmUserDO();
                crmUserDO.setFirstName(DEFAULT_FIRST_NAME);
                crmUserDO.setLastName(DEFAULT_LAST_NAME);
                crmUserDO.setAge(DEFAULT_AGE);
                crmUserDO.setSex(DEFAULT_SEX);

                System.out.println("before insert: " + crmUserDO);
                mapper.insert(crmUserDO);
                System.out.println("after insert: " + crmUserDO);
            }
        }.execute();
    }

    @Test
    public void update() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                CrmUserDO crmUserDO = new CrmUserDO();

                crmUserDO.setId(ID);
                crmUserDO.setLastName(MODIFIED_LAST_NAME);
                crmUserDO.setFirstName(MODIFIED_FIRST_NAME);
                crmUserDO.setSex(MODIFIED_SEX);

                mapper.update(crmUserDO);

                System.out.println(mapper.selectById(ID));
            }
        }.execute();
    }

    @Test
    public void selectByFirstName() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                List<CrmUserDO> crmUserDOS = mapper.selectByFirstName(MODIFIED_FIRST_NAME);

                System.out.println(crmUserDOS.size());
            }
        }.execute();
    }

    @Test
    public void selectByFirstNameAndLastName() {
        new TestTemplate() {
            @Override
            protected void doExecute(SqlSession sqlSession) throws Exception {
                CrmUserDAO mapper = sqlSession.getMapper(CrmUserDAO.class);

                List<CrmUserDO> crmUserDOS;

                crmUserDOS = mapper.selectByFirstNameAndLastName(MODIFIED_FIRST_NAME, null);
                System.out.println(crmUserDOS.size());

                crmUserDOS = mapper.selectByFirstNameAndLastName(null, MODIFIED_LAST_NAME);
                System.out.println(crmUserDOS.size());

                crmUserDOS = mapper.selectByFirstNameAndLastName(MODIFIED_FIRST_NAME, MODIFIED_LAST_NAME);
                System.out.println(crmUserDOS.size());
            }
        }.execute();
    }
}
```

## 1.5 crm-user.xml

映射器配置文件，以下是我总结的参数映射规则

1. 对于__不含有__@Param注解的方法
    * 一个参数
        * 对于非JavaBean参数：`${}`与`#{}`里面可以填任何字符，无所谓；test属性只能填写`_parameter`
        * 对于JavaBean参数：`${}`与`#{}`以及test属性只能填写JavaBean的属性名（set方法去掉set字符串并小写首字母）
    * 多个参数：`${}`与`#{}`
        * 对于JavaBean参数：`${}`与`#{}`以及test属性只能填写JavaBean的属性名（set方法去掉set字符串并小写首字母）
        * 对于非JavaBean参数：`${}`与`#{}`以及test属性只能填写`arg0、arg1、...`以及`param1、param2、...`
1. 对于__含有__@Param注解的方法（假设注解配置的值是`myParam`）
    * 对于JavaBean参数：`${}`与`#{}`以及test属性只能以@Param注解配置的值或者`param1、param2、...`作为前缀，再加上JavaBean属性名。例如，`#{param1.id}`以及`#{myParam.id}`
    * 对于非JavaBean参数：`${}`与`#{}`以及test属性只能填写@Param注解配置的值或者`param1、param2、...`
* __产生上述规则的原因，请参考{% post_link MyBatis-源码剖析 %}__

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="org.liuyehcf.mybatis.CrmUserDAO">
    <sql id="columns">
        id AS id,
        first_name AS firstName,
        last_name AS lastName,
        age AS age,
        sex AS sex
    </sql>

    <select id="selectById" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        WHERE id = #{anotherName}
    </select>

    <insert id="insert" useGeneratedKeys="true" keyProperty="id">
        INSERT INTO crm_user(
        first_name,
        last_name,
        age,
        sex
        )
        VALUES(
        #{firstName},
        #{lastName},
        #{age},
        #{sex}
        )
    </insert>

    <update id="update" parameterType="crmUserDO">
        UPDATE crm_user
        <set>
            <if test="firstName != null and firstName != ''">
                first_name = #{firstName},
            </if>

            <if test="lastName != null and lastName != ''">
                last_name = #{lastName},
            </if>
            <if test="age != null">
                age = #{age},
            </if>
            <if test="sex != null">
                sex= #{sex},
            </if>
        </set>
        WHERE id = #{id}
    </update>

    <select id="selectByFirstName" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        <where>
            <if test="_parameter != null and _parameter !=''">
                AND first_name = #{anotherName}
            </if>
        </where>
    </select>

    <select id="selectByFirstNameAndLastName" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        <where>
            <if test="param1 != null and arg0 !=''">
                AND first_name = #{arg0}
            </if>
            <if test="arg1 != null and param2 !=''">
                AND last_name = #{param2}
            </if>
        </where>
    </select>

    <select id="selectByIdWithParam" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        WHERE id = #{specificName}
    </select>

    <insert id="insertWithParam" useGeneratedKeys="true" keyProperty="specificName.id">
        INSERT INTO crm_user(
        first_name,
        last_name,
        age,
        sex
        )
        VALUES(
        #{specificName.firstName},
        #{specificName.lastName},
        #{param1.age},
        #{param1.sex}
        )
    </insert>

    <update id="updateWithParam" parameterType="crmUserDO">
        UPDATE crm_user
        <set>
            <if test="specificName.firstName != null and param1.firstName != ''">
                first_name = #{specificName.firstName},
            </if>

            <if test="param1.lastName != null and specificName.lastName != ''">
                last_name = #{specificName.lastName},
            </if>
            <if test="specificName.age != null">
                age = #{param1.age},
            </if>
            <if test="param1.sex != null">
                sex= #{param1.sex},
            </if>
        </set>
        WHERE id = #{specificName.id}
    </update>

    <select id="selectByFirstNameWithParam" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        <where>
            <if test="param1 != null and specificName !=''">
                AND first_name = #{specificName}
            </if>
        </where>
    </select>

    <select id="selectByFirstNameAndLastNameWithParam" resultType="crmUserDO">
        SELECT
        <include refid="columns"/>
        FROM crm_user
        <where>
            <if test="param1 != null and param1 !=''">
                AND first_name = #{specificName1}
            </if>
            <if test="specificName2 != null and specificName2 !=''">
                AND last_name = #{param2}
            </if>
        </where>
    </select>

</mapper>
```

## 1.6 logback.xml

日志框架用的是slf4j+logback，用于看mybatis内部打印的日志

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- Logback Configuration. -->
<configuration scan="true" scanPeriod="60 second" debug="false">

    <appender name="stdout" class="ch.qos.logback.core.ConsoleAppender">
        <target>System.out</target>

        <encoder class="ch.qos.logback.core.encoder.LayoutWrappingEncoder">
            <layout class="ch.qos.logback.classic.PatternLayout">
                <pattern><![CDATA[
             [%d{yyyy-MM-dd HH:mm:ss}]  %-5level %logger{0} - %m%n
            ]]></pattern>
            </layout>
        </encoder>
    </appender>

    <root>
        <level value="DEBUG"/>
        <appender-ref ref="stdout"/>
    </root>
</configuration>
```

## 1.7 testDatabase.sql

建表sql

```sql
CREATE DATABASE mybatis;

USE mybatis;

CREATE TABLE crm_user(
id BIGINT NOT NULL AUTO_INCREMENT,
first_name VARCHAR(20) NOT NULL DEFAULT "",
last_name VARCHAR(20) NOT NULL DEFAULT "",
age SMALLINT NOT NULL,
sex TINYINT NOT NULL,
key(id)
);
```

