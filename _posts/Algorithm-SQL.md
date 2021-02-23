---
title: Algorithm-SQL
date: 2018-09-21 11:34:23
tags: 
- 原创
categories: 
- Job
- Leetcode
---

**阅读更多**

<!--more-->

# 1 Question-175[★★★]

> Write a SQL query for a report that provides the following information for each person in the Person table, regardless if there is an address for each of those people: **FirstName, LastName, City, State**

```
Table: Person

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| PersonId    | int     |
| FirstName   | varchar |
| LastName    | varchar |
+-------------+---------+

Table: Address
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| AddressId   | int     |
| PersonId    | int     |
| City        | varchar |
| State       | varchar |
+-------------+---------+
```

```sql
SELECT Person.FirstName, Person.LastName, Address.City, Address.State
FROM Person LEFT JOIN Address
ON Person.PersonId = Address.PersonId
```

# 2 Question-182[★★★★★]

**Duplicate Emails**

> Write a SQL query to find all duplicate emails in a table named Person.

```
Table: Person
+----+---------+
| Id | Email   |
+----+---------+
| 1  | a@b.com |
| 2  | c@d.com |
| 3  | a@b.com |
+----+---------+

-->

+---------+
| Email   |
+---------+
| a@b.com |
+---------+
```

```sql
SELECT Email FROM Person
GROUP BY Email
HAVING COUNT(*) > 1
```

<!--

# 3 Question-000[★]

____

> 

```sql
```

-->

# 4 查询在一个表，但是不在另一个表中的数据

```sql
SELECT A.ID FROM A LEFT JOIN B ON A.ID WHERE B.ID IS NULL
```

# 5 查询某个数据库中所有表的行数

```sql
SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = '<your database name>';
```