---
title: Zookeeper-Overview
date: 2018-07-13 11:48:40
tags: 
- 摘录
categories: 
- Distributed
- Zookeeper
---

**阅读更多**

<!--more-->

# 1 下载

[传送门](https://www.apache.org/dyn/closer.cgi/zookeeper/)

下载后，解压即可

# 2 启动Server

```sh
cd <zookeeper所在目录>

bin/zkServer.sh start
```

# 3 启动Client

```sh
cd <zookeeper所在目录>

bin/zkCli.sh
```

# 4 Cmd-Overview

Zookeeper客户端提供如下命令（可用`help`查看）

1. **`ls`**：列出指定节点的孩子节点列表
1. **`ls2`**：列出指定节点的孩子节点列表，以及该节点的状态信息
1. **`create`**：创建节点
1. **`get`**：获取节点的数据以及状态信息
1. **`set`**：设置节点的数据
1. **`rmr`**：移除指定的znode并递归其所有子节点
1. **`delete`**：移除指定的znode节点（该节点不能有孩子节点）
1. **`stat`**：获取节点的状态信息
1. **`listquota`**：查询节点的配额
1. **`setquota`**：设置节点的配额
1. **`delquota`**：删除节点的配额
1. **`getAcl`**：获取ACL权限
1. **`setAcl`**：设置ACL权限
1. **`history`**：列出命令历史
1. **`redo`**：重新执行指定命令
1. **`printwatches`**：开启/关闭在输出流打印watch触发的信息
1. **`sync`**：同步
1. **`addauth`**：添加授权用户信息
1. **`quit`**：关闭当前Zookeeper会话（连接），并退出客户端程序
1. **`close`**：仅关闭当前Zookeeper会话（连接）
1. **`connect`**：连接到指定Zookeeper服务器

# 5 Znode Status

znode包含如下状态

1. **cZxid**：创建节点时的zxid
1. **mZxid**：修改节点时的zxid
1. **pZxid**：修改节点的子节点列表的zxid
1. **ctime**：创建节点的时间
1. **mtime**：修改节点的时间
1. **dataVersion**：节点数据修改的次数
1. **cversion**：节点的子节点列表修改的次数
1. **aclVersion**：节点的ACL权限修改的次数
1. **ephemeralOwner**：临时节点的会话id，若不是临时节点，那么此id为0
1. **dataLength**：数据长度
1. **numChildren**：子节点数量

# 6 ACL

**Zookeeper使用ACL来控制访问znode**。ACL的实现和UNIX的实现非常相似：它采用权限位来控制那些操作被允许，那些操作被禁止。但是和标准的UNIX权限不同的是，znode没有限制用户（user，即文件的所有者），组（group）和其他（world）。Zookeepr是没有所有者的概念的

**每个znode的ACL是独立的，且子节点不会继承父节点的ACL**。例如：znode `/app`对于ip为172.16.16.1只有只读权限，而`/app/status`是world可读，那么任何人都可以获取`/app/status`;所以在Zookeeper中权限是没有继承和传递关系的，每个znode的权限都是独立存在的

**ACL权限是针对当前会话（连接）起作用的**。例如，在当前会话中执行`addauth digest user1:password1`以及`setAcl /app auth:user1:password1:crwda`。那么此时开启另一个会话后，对`/app`节点是没有访问权限的，通过执行`addauth digest user1:password1`可以获取到`/app`节点的相关权限。**因此`addauth digest <username>:<password>`命令，就是给当前会话增加了某个角色，从而能够获取到该角色的权限**

**Zookeeper支持可插拔的权限认证方案，分为三个维度**：

1. **`scheme`**：表示使用何种方式来进行访问控制
1. **`id`**：表示在指定scheme下的**表达式**（该表达式可能包含`:`）
1. **`permission`**：表示有什么权限
* 通常表示为`<scheme>:<id>:<permissions>`

**Zookeeper支持如下几种permission**

1. `CREATE`：允许创建子节点
1. `READ`：允许获取节点元数据以及子节点列表
1. `WRITE`：允许设置Data
1. `DELETE`：允许删除子节点
1. `ADMIN`：允许设置权限

**Zookeeper支持如下几种scheme**

1. **world**：只有一个id，即`anyone`
    * **`ACL Exp`**：`world:anyone:<permissions>`
1. **auth**：可以指定id或不用id，只要是通过auth的user都有权限。**当使用addauth命令添加多个认证用户后（作用域是当前会话，关闭会话后，添加的认证用户即被清除了），使用auth策略来设置acl，那么所有认证过的用户都被会加入到acl中**
    * **`ACL Exp`**：`auth::<permissions>`
    * **`ACL Exp`**：`auth:<username>:<password>:<permissions>`
1. **digest**：使用用户名/密码的方式验证，采用`<username>:BASE64(SHA1(<username>:<password>))`的字符串作为ACL的`id`
    * **`ACL Exp`**：`digest:<username>:<encriedUserPassowrd>:<permissions>`
    * 其中，`<encriedUserPassowrd>=BASE64(SHA1(<username>:<password>))`，**换言之，你得自己做加密操作**
    * **`echo -n <username>:<password> | openssl dgst -binary -sha1 | openssl base64`可以实现加密功能**
1. **ip**：使用客户端的IP地址作为ACL的ID，设置的时候可以设置一个IP段，比如ip:192.168.1.0/16, 表示匹配前16个bit的IP段
    * **`ACL Exp`**：`ip:192.168.0.1:<permissions>`
    * **`ACL Exp`**：`ip:192.168.0.0/16:<permissions>`

**设定ACL权限后，忘记密码怎么办**

1. 如果这个节点是`/`的子节点，由于我们有`/`目录的权限，所以我们还是可以通过`delete`来删除这个节点的
1. 如果这个节点不是`/`的子节点，且父节点也没有权限，那么只能通过**设置配置文件`skipACL=yes`然后重启服务**，这样就能跳过acl控制

# 7 Watch

我们可以为znode设置watch，**znode的任何改变都会触发这个watch，watch一旦触发就被清除了**。当一个watch被触发时，Zookeeper会给对应的Client发送一个通知（notification）

Zookeeper中的所有读操作，都可以设置一个watch作为它的副作用（side effect）

**以下是Zookeeper官方文档对watch的定义以及解释**

> All of the read operations in ZooKeeper - getData(), getChildren(), and exists() - have the option of setting a watch as a side effect. Here is ZooKeeper's definition of a watch: a watch event is one-time trigger, sent to the client that set the watch, which occurs when the data for which the watch was set changes. There are three key points to consider in this definition of a watch:
> * **One-time trigger**
> One watch event will be sent to the client when the data has changed. For example, if a client does a getData("/znode1", true) and later the data for /znode1 is changed or deleted, the client will get a watch event for /znode1. If /znode1 changes again, no watch event will be sent unless the client has done another read that sets a new watch.
> * **Sent to the client**
> his implies that an event is on the way to the client, but may not reach the client before the successful return code to the change operation reaches the client that initiated the change. Watches are sent asynchronously to watchers. ZooKeeper provides an ordering guarantee: a client will never see a change for which it has set a watch until it first sees the watch event. Network delays or other factors may cause different clients to see watches and return codes from updates at different times. The key point is that everything seen by the different clients will have a consistent order.
> * **The data for which the watch was set**
> This refers to the different ways a node can change. It helps to think of ZooKeeper as maintaining two lists of watches: data watches and child watches. getData() and exists() set data watches. getChildren() sets child watches. Alternatively, it may help to think of watches being set according to the kind of data returned. getData() and exists() return information about the data of the node, whereas getChildren() returns a list of children. Thus, setData() will trigger data watches for the znode being set (assuming the set is successful). A successful create() will trigger a data watch for the znode being created and a child watch for the parent znode. A successful delete() will trigger both a data watch and a child watch (since there can be no more children) for a znode being deleted as well as a child watch for the parent znode.

> Watches are maintained locally at the ZooKeeper server to which the client is connected. This allows watches to be lightweight to set, maintain, and dispatch. When a client connects to a new server, the watch will be triggered for any session events. Watches will not be received while disconnected from a server. When a client reconnects, any previously registered watches will be reregistered and triggered if needed. In general this all occurs transparently. There is one case where a watch may be missed: a watch for the existence of a znode not yet created will be missed if the znode is created and deleted while disconnected.

# 8 ls

**描述**：列出指定节点的孩子节点列表

**语法**

* `ls path [watch]`

**参数解释**

* `path`：必填参数，节点路径
* `watch`：选填参数，**任意字符均表示设置一个watch**。**当节点的孩子列表发生变动时（仅当前路径的孩子列表，不包含孩子的孩子列表）**，会触发该watch

**示例**

```sh
# 查询子节点列表
[zk: localhost:2181(CONNECTED) 2] ls /
[FirstNode0000000013, zookeeper, FirstNode]

# 查询子节点列表，并设置一个watch
[zk: localhost:2181(CONNECTED) 7] ls / myWatch
[FirstNode0000000013, zookeeper, FirstNode]

# 当另一个客户端在/路径下删除FirstNode0000000013节点时，该watch会被触发，在屏幕上会打印如下内容
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/
```

# 9 ls2

**描述**：列出指定节点的孩子节点列表，以及该节点的状态信息

**语法**

* `ls2 path [watch]`

**参数解释**

* `path`：必填参数，节点路径
* `watch`：选填参数，**任意字符均表示设置一个watch**。**当节点的孩子列表发生变动时（仅当前路径的孩子列表，不包含孩子的孩子列表）**，会触发该watch

**示例**

```sh
# 查询子节点列表及状态
[zk: localhost:2181(CONNECTED) 9] ls2 /
[zookeeper, FirstNode]
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0xca
cversion = 32
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 2

# 查询子节点列表及状态，并设置一个watch
[zk: localhost:2181(CONNECTED) 10] ls2 / myWatch
[zookeeper, FirstNode]
cZxid = 0x0
ctime = Thu Jan 01 08:00:00 CST 1970
mZxid = 0x0
mtime = Thu Jan 01 08:00:00 CST 1970
pZxid = 0xca
cversion = 32
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 2

# 当另一个客户端在/路径下增加一个节点时，该watch会被触发，在屏幕上会打印如下内容
WATCHER::

WatchedEvent state:SyncConnected type:NodeChildrenChanged path:/
```

# 10 create

**描述**：创建节点

**语法**

* `create [-s] [-e] path data acl`

**选项解释**

* `-s`：创建一个顺序节点（每个节点都会维护一个严格递增的序列）
* `-e`：创建一个临时节点，所谓临时节点，就是当前会话（连接）退出时，该节点就会被删除

**参数解释**

* `path`：必填参数，节点路径
* `data`：必填参数，节点数据
* `acl`：必填参数，访问控制，默认值为`world:anyone:crwda`

**示例**

```sh
# 创建永久节点
[zk: localhost:2181(CONNECTED) 0] create /FirstNode myData
Created /FirstNode

# 创建永久顺序节点
[zk: localhost:2181(CONNECTED) 2] create -s  /FirstNode myData
Created /FirstNode0000000013

# 创建临时节点
[zk: localhost:2181(CONNECTED) 3] create -e /FirstTempNode myData
Created /FirstTempNode

# 创建永久临时节点，并设置ACL
[zk: localhost:2181(CONNECTED) 4] create -s -e /FirstNode myData world:anyone:crwd
Created /FirstNode0000000015

# 添加授权用户，然后创建节点，并设置ACL
# 必须要先addauth，否则在当前会话中，如果没有授权用户，那么使用auth作为acl将会失败
[zk: localhost:2181(CONNECTED) 11] addauth digest user1:password1
[zk: localhost:2181(CONNECTED) 12] create /SecondNode myData auth::cr
Created /SecondNode
```

# 11 get

**描述**：获取节点的数据以及状态信息

**语法**

* `get path [watch]`

**参数解释**

* `path`：必填参数，节点路径
* `watch`：选填参数，**任意字符均表示设置一个watch**。**当节点数据发生变动时**，会触发该watch

**示例**

```sh
# 查看节点元数据及状态信息
[zk: localhost:2181(CONNECTED) 28] get /FirstNode
1
cZxid = 0xc6
ctime = Sat Jul 14 18:28:57 CST 2018
mZxid = 0xd3
mtime = Sat Jul 14 18:38:15 CST 2018
pZxid = 0xc7
cversion = 1
dataVersion = 3
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 1

# 查看节点元数据及状态信息并设置一个watch
[zk: localhost:2181(CONNECTED) 29] get /FirstNode myWatch
1
cZxid = 0xc6
ctime = Sat Jul 14 18:28:57 CST 2018
mZxid = 0xd3
mtime = Sat Jul 14 18:38:15 CST 2018
pZxid = 0xc7
cversion = 1
dataVersion = 3
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 1

# 当另一个客户端修改 /FirstNode 节点的数据时，会触发该watch，在屏幕上打印如下内容
WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/FirstNode
```

# 12 set

**描述**：设置节点的数据

**语法**

* `set path data [version]`

**参数解释**

* `path`：必填参数，节点路径
* `data`：必填参数，节点数据
* `version`：选填参数，指定版本号，当且仅当版本号一致时修改成功

**示例**

```sh
# 设置节点数据
[zk: localhost:2181(CONNECTED) 30] set /FirstNode 2
cZxid = 0xc6
ctime = Sat Jul 14 18:28:57 CST 2018
mZxid = 0xd5
mtime = Sat Jul 14 18:44:09 CST 2018
pZxid = 0xc7
cversion = 1
dataVersion = 5
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 1

# 设置节点数据，并指定了版本号（版本号正确）
[zk: localhost:2181(CONNECTED) 37] set /FirstNode 2 8
cZxid = 0xc6
ctime = Sat Jul 14 18:28:57 CST 2018
mZxid = 0xdd
mtime = Sat Jul 14 18:45:43 CST 2018
pZxid = 0xc7
cversion = 1
dataVersion = 9
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 1

# 设置节点数据，并指定了版本号（版本号错误，版本号大于当前版本号）
[zk: localhost:2181(CONNECTED) 38] set /FirstNode 2 100
version No is not valid : /FirstNode

# 设置节点数据，并指定了版本号（版本号错误，版本号小于当前版本号）
[zk: localhost:2181(CONNECTED) 39] set /FirstNode 2 1
version No is not valid : /FirstNode
```

# 13 rmr

**描述**：移除指定的znode并递归其所有子节点

**语法**

* `rmr path`

**参数解释**

* `path`：必填参数，节点路径

**示例**

```sh
[zk: localhost:2181(CONNECTED) 40] rmr /FirstNode
```

# 14 delete

**描述**：移除指定的znode节点（该节点不能有孩子节点）

**语法**

* `delete path [version]`

**参数解释**

* `path`：必填参数，节点路径
* `version`：选填参数，当且仅当版本号一致时，才允许删除

**示例**

```sh
# 删除节点
[zk: localhost:2181(CONNECTED) 45] delete /FirstNode

# 删除节点（版本号正确）
[zk: localhost:2181(CONNECTED) 47] delete /FirstNode 0

# 删除节点（版本号错误，大于正确版本号）
[zk: localhost:2181(CONNECTED) 49] delete /FirstNode 100
version No is not valid : /FirstNode

# 删除节点（版本号错误，小于正确版本号）
# 先创建节点，然后修改节点的值，使版本号增加，至少大于1
[zk: localhost:2181(CONNECTED) 54] delete /FirstNode 1
version No is not valid : /FirstNode
```

# 15 stat

**描述**：获取节点的状态信息

**语法**

* `stat path [watch]`

**参数解释**

* `path`：必填参数，节点路径
* `watch`：选填参数，**任意字符均表示设置一个watch**。**当节点数据发生变动时**，会触发该watch

**示例**

```sh
# 查看节点状态
[zk: localhost:2181(CONNECTED) 55] stat /FirstNode
cZxid = 0xea
ctime = Sat Jul 14 18:51:25 CST 2018
mZxid = 0xec
mtime = Sat Jul 14 18:51:29 CST 2018
pZxid = 0xea
cversion = 0
dataVersion = 2
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 0

# 查看节点状态，并设置一个watch
[zk: localhost:2181(CONNECTED) 57] stat /FirstNode myWatch
cZxid = 0xea
ctime = Sat Jul 14 18:51:25 CST 2018
mZxid = 0xee
mtime = Sat Jul 14 18:53:47 CST 2018
pZxid = 0xea
cversion = 0
dataVersion = 3
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 1
numChildren = 0

# 当另一个客户端修改 /FirstNode 节点的数据时，会触发该watch，在屏幕上打印如下内容
WATCHER::

WatchedEvent state:SyncConnected type:NodeDataChanged path:/FirstNode
```

# 16 listquota

**描述**：查询节点的配额，其中`-1`表示不限制

**语法**

* `listquota path`

**参数解释**

* `path`：必填参数，节点路径

**示例**

```sh
# 查询节点配额
[zk: localhost:2181(CONNECTED) 26] listquota /app
absolute path is /zookeeper/quota/app/zookeeper_limits
Output quota for /app count=-1,bytes=10000
Output stat for /app count=1,bytes=4

# 该结果表明，节点数量不限，大小限制为10000byte
# 当前节点数量为1，大小为4
```

# 17 setquota

**描述**：设置节点的配额（**一旦节点配额被设定，便不能重写，只能删掉再设置**）

**语法**

* `setquota -n|-b val path`

**选项解释**

* `-n`：设置节点个数（包括当前节点以及所有子节点，包括层层嵌套的子节点）
* `-b`：设置节点的数据大小（包括当前节点以及所有子节点，包括层层嵌套的子节点）
* **只能选择其中之一进行设置**

**参数解释**

* `val`：必填参数，设置的值
* `path`：必填参数，节点路径

**示例**

```sh
# 为节点 /app 设置配额，节点数量为100
[zk: localhost:2181(CONNECTED) 23] setquota -n 100 /app
Comment: the parts are option -n val 100 path /app

# 为节点 /app 设置配额，节点大小为10000bytes
[zk: localhost:2181(CONNECTED) 25] setquota -b 10000 /app
Comment: the parts are option -b val 10000 path /app
```

# 18 delquota

**描述**：删除节点的配额

**语法**

* `delquota [-n|-b] path`

**选项解释**

* `-n`：删除节点数量限制，置为`-1`
* `-b`：删除节点大小限制，置为`-1`
* 不填选项代表删除配额设置，此时用`listquota`查询配额会报错

**参数解释**

* `path`：必填参数，节点路径

**示例**

```sh
[zk: localhost:2181(CONNECTED) 38] delquota -b /app
[zk: localhost:2181(CONNECTED) 39] delquota -n /app
[zk: localhost:2181(CONNECTED) 40] delquota /app
```

# 19 getAcl

**描述**：获取ACL权限

**语法**

* `getAcl path`

**参数解释**

* `path`：必填参数，节点路径

**示例**

```sh
# 获取节点的ACL权限
[zk: localhost:2181(CONNECTED) 6] getAcl /FirstNode
'world,'anyone
: cdrwa
```

# 20 setAcl

**描述**：设置ACL权限

**语法**

* `setAcl path acl`

**参数解释**

* `path`：必填参数，节点路径
* `acl`：必填参数，ACL权限

**示例**

```sh
# 设置节点ACL权限(world schema)
[zk: localhost:2181(CONNECTED) 8] setAcl /FirstNode world:anyone:cr
cZxid = 0xea
ctime = Sat Jul 14 18:51:25 CST 2018
mZxid = 0xf1
mtime = Sat Jul 14 18:57:38 CST 2018
pZxid = 0xea
cversion = 0
dataVersion = 6
aclVersion = 1
ephemeralOwner = 0x0
dataLength = 1
numChildren = 0

# 添加授权用户，然后设置节点的ACL权限(auth schema)
# 必须要先addauth，否则在当前会话中，如果没有授权用户，那么使用auth作为acl将会失败
[zk: localhost:2181(CONNECTED) 27] addauth digest user1:passowrd1
[zk: localhost:2181(CONNECTED) 28] setAcl /ThirdNode auth::crwda
cZxid = 0x102
ctime = Sat Jul 14 19:21:33 CST 2018
mZxid = 0x102
mtime = Sat Jul 14 19:21:33 CST 2018
pZxid = 0x102
cversion = 0
dataVersion = 0
aclVersion = 1
ephemeralOwner = 0x0
dataLength = 6
numChildren = 0

# 添加授权用户，然后设置节点的ACL权限(auth schema)
# 必须要先addauth，否则在当前会话中，如果没有授权用户，那么使用auth作为acl将会失败
[zk: localhost:2181(CONNECTED) 9] addauth digest user2:password2
[zk: localhost:2181(CONNECTED) 10] setAcl /ThirdNode auth:user2:password:crwda
cZxid = 0x29
ctime = Sat Jul 14 22:34:23 CST 2018
mZxid = 0x29
mtime = Sat Jul 14 22:34:23 CST 2018
pZxid = 0x29
cversion = 0
dataVersion = 0
aclVersion = 3
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0

# 设置acl权限(digest schema)
# 其中<password>部分利用`echo -n user1:password1 | openssl dgst -binary -sha1 | openssl base64`命令计算得到
[zk: localhost:2181(CONNECTED) 1] setAcl /ThirdNode digest:user1:XDkd2dsEuhc9ImU3q8pa8UOdtpI=:crwda
cZxid = 0x29
ctime = Sat Jul 14 22:34:23 CST 2018
mZxid = 0x29
mtime = Sat Jul 14 22:34:23 CST 2018
pZxid = 0x29
cversion = 0
dataVersion = 0
aclVersion = 1
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0

# 设置acl权限(ip schema)
[zk: localhost:2181(CONNECTED) 11] setAcl /ThirdNode ip:192.168.1.1:crwda
cZxid = 0x29
ctime = Sat Jul 14 22:34:23 CST 2018
mZxid = 0x29
mtime = Sat Jul 14 22:34:23 CST 2018
pZxid = 0x29
cversion = 0
dataVersion = 0
aclVersion = 4
ephemeralOwner = 0x0
dataLength = 4
numChildren = 0
```

# 21 history

**描述**：列出命令历史

**语法**

* `history`

**示例**

```sh
# 列出历史命令
[zk: localhost:2181(CONNECTED) 59] history
49 - delete /FirstNode 100
50 - delete /FirstNode -1
51 - create /FirstNode 1
52 - set /FirstNode 2
53 - set /FirstNode 3
54 - delete /FirstNode 1
55 - stat /FirstNode
56 - stat /FirstNode myWatch
57 - stat /FirstNode myWatch
58 - his
59 - history
```

# 22 redo

**描述**：重新执行指定命令

**语法**

* `redo cmdno`

**参数解释**

* `cmdno`：必填参数，命令编号

**示例**

```sh
# 重新执行第61条命令
[zk: localhost:2181(CONNECTED) 62] redo 61
52 - set /FirstNode 2
53 - set /FirstNode 3
54 - delete /FirstNode 1
55 - stat /FirstNode
56 - stat /FirstNode myWatch
57 - stat /FirstNode myWatch
58 - his
59 - history
60 - his
61 - history
62 - history
```

# 23 printwatches

**描述**：开启/关闭在输出流打印watch触发的信息

**语法**

* `printwatches on|off`

**参数解释**

* `on`：开启
* `off`：关闭

**示例**

```sh
# 开启
[zk: localhost:2181(CONNECTED) 70] printwatches on

# 关闭
[zk: localhost:2181(CONNECTED) 71] printwatches off
```

# 24 sync

**描述**：同步

**语法**

* `sync path`

**参数解释**

* `path`：必填参数，节点路径

**示例**

```sh
# 强制同步 /app 的数据
[zk: localhost:2181(CONNECTED) 45] sync /app
[zk: localhost:2181(CONNECTED) 46] Sync returned 0
```

# 25 addauth

**描述**：添加授权用户信息

**语法**

* `addauth scheme auth`

**参数解释**

* `scheme`：必填参数，策略
* `auth`：授权用户信息，与scheme相关

**示例**

```sh
# 添加scheme为digest的认证用户
[zk: localhost:2181(CONNECTED) 11] addauth digest user1:password1
```

# 26 quit

**描述**：关闭当前Zookeeper会话（连接），并退出客户端程序

**语法**

* `quit`

**示例**

```sh
[zk: localhost:2181(CONNECTED) 72] quit
Quitting...
2018-07-14 19:00:09,346 [myid:] - INFO  [main:ZooKeeper@687] - Session: 0x1000056482b0005 closed
2018-07-14 19:00:09,348 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@521] - EventThread shut down for session: 0x1000056482b0005
```

# 27 close

**描述**：仅关闭当前Zookeeper会话（连接）

**语法**

* `close`

**示例**

```sh
# 关闭当前会话
[zk: localhost:2181(CONNECTED) 0] close
2018-07-14 19:00:29,350 [myid:] - INFO  [main:ZooKeeper@687] - Session: 0x1000056482b0006 closed
[zk: localhost:2181(CLOSED) 1] 2018-07-14 19:00:29,351 [myid:] - INFO  [main-EventThread:ClientCnxn$EventThread@521] - EventThread shut down for session: 0x1000056482b0006
```

# 28 connect

**描述**：连接到指定Zookeeper服务器

**语法**

* `connect host:port`

**参数解释**

* `host`：主机名
* `port`：端口号

**示例**

```sh
# 连接到 localhost:2181
[zk: localhost:2181(CLOSED) 4] connect localhost:2181
2018-07-14 19:04:17,738 [myid:] - INFO  [main:ZooKeeper@441] - Initiating client connection, connectString=localhost:2181 sessionTimeout=30000 watcher=org.apache.zookeeper.ZooKeeperMain$MyWatcher@e73f9ac
[zk: localhost:2181(CONNECTING) 5] 2018-07-14 19:04:17,739 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@1028] - Opening socket connection to server localhost/0:0:0:0:0:0:0:1:2181. Will not attempt to authenticate using SASL (unknown error)
2018-07-14 19:04:17,740 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@878] - Socket connection established to localhost/0:0:0:0:0:0:0:1:2181, initiating session
2018-07-14 19:04:17,742 [myid:] - INFO  [main-SendThread(localhost:2181):ClientCnxn$SendThread@1302] - Session establishment complete on server localhost/0:0:0:0:0:0:0:1:2181, sessionid = 0x1000056482b0008, negotiated timeout = 30000

WATCHER::

WatchedEvent state:SyncConnected type:None path:null
```

# 29 参考

* [Zookeeper官网](http://zookeeper.apache.org/)
* [Zookeeper-官方Doc](https://zookeeper.apache.org/doc/r3.4.12/zookeeperProgrammers.html)
* [Zookeeper教程-英文版](https://www.tutorialspoint.com/zookeeper/zookeeper_cli.htm)
* [Zookeeper教程-中文版](https://www.w3cschool.cn/zookeeper/)
* [zookeeper-04-基本命令](https://blog.csdn.net/hylexus/article/details/53352789)
* [Zookeeper ACL权限控制](https://blog.csdn.net/qianshangding0708/article/details/50114671)
* [ZooKeeper commands](http://www.corejavaguru.com/bigdata/zookeeper/cli)
* [Zookeeper03 - Zookeeper之ACL](https://blog.csdn.net/cdu09/article/details/51637451)
* [Zookeeper权限管理之坑](https://www.jianshu.com/p/147ca2533aff)
