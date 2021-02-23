---
title: Linux-DNS
date: 2018-12-02 10:42:02
tags: 
- 摘录
categories: 
- Operating System
- Linux
---

**阅读更多**

<!--more-->

# 1 什么是DNS

## 1.1 用网络主机名取得IP的历史渊源

**单一文件处理上网的年代：`/etc/hosts`**

* 利用某些特定的文件将主机名与IP做一个对应，如此一来，我们就可以通过主机名来取得该主机的IP了
* 但是主机名与IP的对应无法自动在所有计算机内更新，且要将主机名加入该文件仅能向INTERNIC注册，若IP数量太多时，该文件会过大，也就更不利于其他主机同步化了
* 在私有网络内部，最好将所有的私有IP与主机名对应都写入这个文件中

## 1.2 DNS的主机名对应IP的查询流程

### 1.2.1 DNS的阶层架构与TLD

**在整个DNS系统的最上方一定是`.`（小数点）这个DNS服务器，称为`root`**，最早在它下面管理的就只有`.com`、`.edu`、`.gov`、`.mil`、`.org`、`.net`这种特殊区域以及以国家为分类的第二层的主机名，这两者称为`Top Level Domains（TLDs）`

**一般顶级域名（Generic TLDs, gTLD）：例如`.com`、`.org`、`.gov`等**

**地区顶级层域名（Country Code TLDs, ccTLD）：例如`.uk`、`.jp`、`.cn`等**

**最早root管理六大领域域名，如下表：**

| 名称 | 代表意义 |
|:--|:--|
| `com` | 公司、行号、企业 |
| `org` | 组织、机构 |
| `edu` | 教育单位 |
| `gov` | 政府单位 |
| `net` | 网络、通信 |
| `mil` | 军事单位 |

### 1.2.2 授权与分层负责

1. 我们不能执行设置TLD，必须向上层ISP申请域名的授权才行
1. 每个国家之下记录的主要区域，基本与root管理的六大类类似
1. **每一个上层的DNS服务器所记录的信息，其实只有其下一层的主机名而已**
1. 这样设置的好处：每台机器管理的只有下一层的hostname对应的IP，所以减少了管理上的困扰，如果下层Client端如果有问题，只要询问上一层DNS Server即可，不需要跨越上层，排错也会比较简单

### 1.2.3 通过DNS查询主机名IP的流程

DNS是以类似树形目录的形态来进行主机名的管理的，所以每一台DNS服务器都仅管理自己的下一层主机名的转译，至于下层的下层，则授权给下层的DNS主机来管理

当你在浏览器地址输入`http://www.ksu.edu.tw`时，计算机会依据相关设置（在Linux下面就是利用`/etc/resolv.conf`这个文件）所提供的DNS（以`168.95.1.1`为例）的IP去进行连接查询

1. 收到用户的查询要求，先查看本身有没有记录，若无则向`.（root）`查询
1. 向最顶层的`.（root）`查询
    * 由于`.（root）`只记录了`.tw`的信息（因为台湾地区只有`.tw`向`.（root）`注册）
    * 从而转向`.tw`查询
1. 向第二层的`.tw`服务器查询
    * 这台机器`（.tw）`管理的仅仅有`.edu.tw`、`.com.tw`、`gov.tw`等
    * 转向`.edu.tw`这个区域的主机查询
1. 向第三层的`.edu.tw`服务器查询
    * 查询到`.ksu.edu.tw`的IP
    * 转向`.ksu.edu.tw`查询
1. 向第四层的`.ksu.edu.tw`服务器查询
    * 找到了`www.ksu.edu.tw`
1. 记录缓存并回报用户
    * DNS（168.95.1.1）会先记录一份查询结果在自己的缓存中，以方便响应下一次的相同要求

整个分层查询的流程就是这样，总要先经过`.（root）`来向下一层进行查询，这样分层的好处如下

1. 主机名修改的仅需要更改自己的DNS即可，不需要通知其他人
    * 只要你的主机名是经过上层合法的DNS服务器设置的，那么就可以在Internet上被查到
1. DNS服务器对主机名解析结果的缓存时间
    * 在缓存内的答案是有时间性的，通常是数十分钟到三天之内
    * 因此当修改了一个`domain name`后，可能要2-3天才能全面启用
1. 可持续向下授权（子域名授权）

`dig +trace www.ksu.edu.tw`：显示分层查询的过程

### 1.2.4 DNS使用的port number

DNS使用的port是`53`，在`/etc/services`这个文件搜寻`domain`关键词就可以查到53这个port
通常DNS是以UDP这个较快速的数据传输协议来查询，如果没有查到完整的信息，就会再次以TCP这个协议来重新查询，因此防火墙要放行TCP\UDP的port53

## 1.3 合法DNS的关键：申请区域查询授权

DNS服务器的架设还有合法与不合法之分，而不像其他服务器一样，架设好之后别人就查得到

向上层区域注册取得合法的区域查询授权

1. 申请一个合法的主机名就需要注册，注册就需要花钱
1. 注册取得的数据有两种
    * FQDN（Fully Qualified Domain Name，全限定域名）：只需要主机名，详细的设置数据就由ISP帮我们搞定
    * 申请区域查询权：以`.ksu.edu.tw`为例，`.ksu.edu.tw`必须要向`.edu.tw`那台主机注册申请区域授权，未来有任何`.ksu.edu.tw`的要求时，`.edu.tw`都会转向`.ksu.edu.cn`，此时我们就需要架设DNS服务器来设置`.ksu.edu.tw`相关的主机名对应才行
1. 架设DNS，而且是可以连上Internet上面的DNS，就必须通过上层DNS服务器的授权才行
1. 让你的主机名对应IP且让其他计算机可以查询到，可以有如下两种方式
    * 上层DNS授权区域查询权，让你自己设置DNS服务器
    * 直接请上层DNS服务器来帮你设置主机名对应

拥有区域查询权后，所有的主机名信息都以自己为准，与上层无关。DNS系统记录的信息非常多，重点有两个

1. **记录服务器所在的NS（NameServer）标志**
1. **记录主机名对应的A（Address）标志**
1. **架设的DNS主机在其上层DNS主机中记录的是NS标志**

## 1.4 主机名交由ISP代管还是自己设置DNS服务器

无论如何你只有两个选择

1. 请上层DNS帮你设置好Hostname与IP
1. 请上层DNS将某个domain name段授权给你作为DNS的主要管理区域

需要架设DNS的时机

1. 你所负责需要连上Internet的主机数量庞大，例如负责公司几十台的网络Server，而这些Server都是挂载在你公司的区域之下
1. 你可能需要时常修改你的Server的名字，或者你的Server有随时增加的可能性与变动性

不需要架设DNS的时机

1. 网络主机数量很少
1. 你可以直接请上层DNS主机管理员帮你设置好Hostname的对应
1. 你对于DNS的认知不足，如果架设反而容易造成网络不通的情况
1. 架设DNS费用很高

## 1.5 DNS数据库的记录：正解、反解、Zone的意义

记录的东西可以称为数据库，在数据库里针对每个要解析的域（domain），就称为一个区域（zone）

**概念**：

1. 正解：从主机名查询到IP的流程
1. 反解：从IP反解析到主机名的流程
1. 无论正解还是反解，每个域记录的就是一个区域（zone）
1. 举例来说
    * 昆山科大DNS服务器管理的就是`*.ksu.edu.tw`这个域的查询权，任何想要知道`*.ksu.edu.tw`主机名的IP都得向昆山科大的DNS服务器查询，此时`.ksu.edu.tw`就是一个“正解的区域”
    * 昆山科大有几个`Class C`的子域，例如`120.114.140.0/24`，如果这254个可用IP都要设置主机名，那么这个`120.114.140.0/24`就是一个“反解的区域”

**正解的设置权以及DNS正解Zone记录的标志**

1. 只要该域没有人使用，那谁先抢到了，就能够使用了
1. 正解的Zone通常有以下几种标志
    * `SOA`：就是开始验证（Start of Authority）的缩写
    * `NS`：就是名称服务器（Name Server）的缩写，后面记录的数据时DNS服务器
    * `A`：就是地址（Address）的缩写，后面记录的是IP的对应

**反解的设置权以及DNS反解Zone记录的标志**

1. 反解主要是由IP找到主机名，重点是IP所有人是谁
1. IP都是INTERNIC发放给各家ISP的，而且IP不能乱设置（路由问题）
1. **因此能够设置反解的就只有IP的拥有人，亦即ISP才有权利设置反解**
1. 除非你取得是整个`Class C`以上等级的IP网段，那你的ISP才可能给你IP反解授权，否则，若有反解的需求，就需要向你的直属上层ISP申请才行
1. 反解的Zone记录的主要信息如下：
    * `NS`
    * `SOA`
    * `PTR`：就是指向（PoinTeR）的缩写，后面记录的数据就是反解到的主机名

每台DNS都需要的正解`Zone：hint`

1. 一个正解或一个反解就可以称为一个`Zone`了
1. `.`这个`Zone`是最重要的
    * 当DNS服务器在自己的数据找不到所需的信息时，一定会去找`.`
    * 因此就必须具有记录`.`在哪里的记录`Zone`才行
    * 这个记录`.`的`Zone`类型，就被称为`hint`类型，这个几乎是每个DNS服务器都需要知道的`Zone`
1. 一台简单的正解DNS服务器，基本就要有两个`Zone`才行，一个是`hint`，一个是关于自己域的正解`Zone`

正反解是否一定要成对

1. 正反解不需要成对
1. 在很多情况下，常常会只有正解的设置需求
1. 事实上，需要正反解成对需求的大概仅有`Mail Server`，由于目前网络带宽经常被垃圾邮件、广告邮件占光，所以Internet的社会对于合法的`Mail Server`规定也就越来越严格

## 1.6 DNS数据库的类型：hint、Master/Slave架构

现在注册域名，那么ISP都会要求你填写两台DNS服务器的IP，因为需要作为备份之用

1. 如果有两台以上的DNS服务器，那么网络上会搜寻到哪一台是不确定的，因为是随机的
1. 这两台DNS服务器的内容必须一模一样，如果不同步将会造成用户无法取得正确数据的问题
1. 为了解决这个问题，因此在`.（root）`这个`hint`类型的数据库文件外，还有两种基本类型
    * `Master`（主人，主要）数据库
    * `Slave`（奴隶，次要）数据库

**Master**

1. 这种类型的DNS数据库中，里面所有的主机名相关信息，都需要管理员自己手动去修改与设置，设置完毕后还需要重新启动DNS服务去读取正确的数据库内容，才算完成数据库更新
1. 一般来说，我们说的DNS架设，就是指这种数据库的类型
1. 同时这种类型的数据库，还能够提供数据库内容给`Slave`的DNS服务器

**Slave**

1. 通常不会只有一台DNS服务器，如果每台DNS都使用Master数据库类型，当有用户想我们要求修改或添加、删除数据时，一笔数据就需要做三次
1. `Slave`必须与`Master`相互搭配
1. 假如有三台主机提供DNS服务，且三台内容相同，那么只需要指定一台服务器为Master，其他两台为该Master的Slave服务器，那么当要修改的一笔名称对应时，我们只要手动更改Master那台机器的配置文件，然后重新启动BIND这个服务后，其他两台Slave就会自动被通知更新了

**Master/Slave的查询优先权**

1. 不论是`Master`还是`Slave`服务器，都必须可以同时提供DNS服务才行，因为在DNS系统中，域名的查询是“先进先出”的状态
1. 每一台DNS服务器的数据库内容需要完全一致，否则就会造成客户端找到的IP是错误的

**Master/Slave数据的同步化过程**

1. `Slave`需要更新来自`Master`的数据，所以当然`Slave`在设置之初就需要存在`Master`才行
1. 不论`Master`还是`Slave`数据库，都会有一个代表该数据库新旧的“序号”，这个序号数值的大小，是会影响是否要更新的操作
1. 更新的方式主要有以下两种
    * **Master主动告知**：在Master修改了数据库内容，并加大数据库序号后，重新启动DNS服务，那Master会主动告知Slave来更新数据库，此时能实现数据同步
    * **Slave主动提出要求**：Slave会定时向Master查看数据库的序号，当发现Master数据库序号比Slave序号更大时，那么Slave就会开始更新，如果序号不变，就判断数据库没有变动，不会进行同步更新

# 2 Client端的设置

## 2.1 相关配置文件

**问题：**

1. 从主机名对应到IP有两种方法，`/etc/hosts`或者通过DNS架构
1. 那么这两种方法分别使用什么配置文件
1. 可否同时存在
1. 若可以同时存在，哪种优先

**如下几个配置文件**

1. `/etc/hosts`：最早的Hostname对应IP的文件
1. `/etc/reslov.conf`：就是ISP的DNS服务器IP记录处
1.` /etc/nsswitch.conf`：决定先使用`/etc/hosts`还是`/etc/reslov.conf`的设置

**一般而言，默认的Linux主机与IP的对应解析都以/etc/hosts优先**

**`/etc/resolv.conf`**

1. DNS服务器的IP可以设置多个，为什么要多个（避免DNS服务器宕机找不到IP），有点类似DNS备份功能
1. 在正常情况下，永远只有第一台DNS服务器会被用来查询
1. 为什么`/etc/resolv.conf`内容会被自动修改
    * 当使用DHCP时，系统会主动使用DHCP服务器传来的数据进行系统配置文件的修订
    * 如果不想使用DHCP传来的服务器设置值，可以在/etc/sysconfig/network-scripts/ifcfg-eth0等相关文件内增加`PEERDNS=no`一行，然后重新启动即可

## 2.2 DNS的正解、反解查询命令：host、nslookup、dig

### 2.2.1 host

**格式：**

* `host [-a] FQDN [server]`
* `host -l domain [server]`

**参数说明：**

* `-a`：代表列出该主机所有的相关信息，包括IP、TTL与排错信息等
* `-l`：若后面接的那个domian设置允许allow-transfer时，则列出该domain所管理的所有主机名对应数据
* `server`：这个参数可有可无，当想要利用非`/etc/resolv.conf`内的DNS主机来查询主机名与IP的对应时，就可以利用这个参数了

### 2.2.2 nslookup

**格式：**

* `nslookup [FQDN] [server]`
* `nslookup`

### 2.2.3 dig

**格式：**

* `dig [option] FQDN [@server]`

**参数说明：**

* `+trace`：从`.`开始追踪
* `-t type`：查询的数据主要有MX，NS，SOA等类型
* `-x`：查询反解信息，非常重要
* `@server`：如果不以`/etc/resolv.conf`的设置来作为DNS查询，可在此填入其他的IP

**查询结果介绍**

1. 整个显示出的信息包括以下几个部分
1. QUESTION（问题）：显示所要查询的内容
1. ANSWER（回答）：依据刚刚的QUESTION去查询所得到的结果
1. AUTHORITY（验证）：查询结果是由哪台服务器提供的（好像没有了???）

**示例：**

* `dig linux.vbird.org`
* `dig -x 120.114.100.20`

### 2.2.4 whois

whiois用于查询这个域是谁管的

# 3 DNS服务器的软件、种类与Caching only DNS服务器设置

## 3.1 搭建DNS所需要的软件

我们要使用的DNS软件就是使用伯克莱大学发展出来的BIND（Berkeley Internet Name Domain）

```sh
yum install bind-libs
yum install bind-utils
yum install bind
yum install bind-chroot
rpm -qa | grep '^bind'
```

chroot代表的是“change to root（根目录）”，root代表的是根目录

* 早期BIND默认将程序启动在`var/named`当中，但是该程序可以在根目录下的其他目录到处转移，若BIND程序有问题，则该程序会造成整个系统的危害
* 为了避免这个问题，我们将目录指定为BIND程序的根目录，由于已经是根目录，所以BIND便不能离开该目录
* CentOS 默认将BIND锁在`/var/named/chroot`目录中

## 3.2 BIND的默认路径设置与chroot

搭建好BIND需要设置的两个主要数据

1. BIND本身的配置文件（`/etc/named.conf`）：主要规范主机的设置、zone file的存在、权限的设置等
1. 正反解数据库文件（zone file）：记录主机名与IP的对应等

一般来说，CentOS的默认目录如下

1. `/etc/named.conf`：配置文件
1. `/etc/sysconfig/named`：是否启动chroot及额外参数
1. `/var/named/`：数据库文件默认放置的目录
1. `/var/run/named`：named这支程序执行时默认放置`pid-file`在此目录内

一般来说，目前主要的distribution都已经自动地将BIND相关程序给chroot了

1. chroot指定的目录记录在`/etc/sysconfig/named`

## 3.3 单纯的cache-only DNS服务器与forwarding功能

**什么是cache-only与forwarding DNS服务器**

1. 有个只需要`.`这个zone file的简单DNS服务器，我们称这种没有公开的DNS数据库的服务器为cache-only（唯高速缓存） DNS Server
    * 这个DNS Server只有缓存搜寻结果的功能
    * 它本身并没有主机名与IP正反解的配置文件，完全是由对外的查询来提供它的数据源
    * 不论谁来查询数据，这台DNS一律开始从自己的缓存以及`.`找起
1. 如果连`.`都不想要，那就需要指定一个上层DNS服务器作为forwarding目标
    * 将原本自己要往`.`查询的任务，丢给上层DNS服务器去处理即可
    * 即便forwarding DNS具有`.`这个zone file，还是会将查询权委托请求上层DNS查询

**什么时候有搭建cache-only DNS的需求**

* 在某些公司，为了预防员工利用公司网络资源做自己的事情，所以都会针对Internet的连接作比较严格的限制，连port 53这个DNS会用到的port也可能会被挡在防火墙外，此时，可以在防火墙那台机器上面，加装一个cache-only DNS服务器
* 即利用自己的防火墙主机上的DNS服务区帮你的Client端解析`hostname<-->IP`，因为防火墙主机可以设置放行自己的DNS功能，而Client端就设置该防火墙IP为DNS服务器的IP即可，这样就可以取得主机名与IP的转译了
* 通常搭建cache-only DNS服务器大都是为了系统安全

**实际设置cache-only DNS Server**

* 由于不需要设置正反解的Zone，只需要`.`的Zone支持即可
* 所以只需要设置一个文件（`named.conf`主配置文件）
* 另外，cache-only只要加上forwarders的设置即可指定forwarding的数据
* 详细步骤如下
    1. 编辑主要配置文件`/etc/named.conf`，以下为参数解释
        * `listen-on port 53{any;}`：监听在这台主机系统上面的哪个网络接口，默认是监听在localhost，亦即只有本机可以对DNS服务器进行查询，因此要改成any。注意，由于可以监听多个接口，因此any后面必须有分号
        * `directory /var/named`：如果此文件下面有规范到正/反解的zone file文件，该文件名默认应该存储到哪个目录，默认放到/var/named下面，由于chroot的关系，最终这些数据库文件会被主动链接到/var/named/chroot/var/named/这个目录
        * `dump-file`、`statistics-file`、`memstatistics-file`：与named这个服务有关的许多统计信息
        * `allow-query{any;}`：针对客户端的设置，表示到底谁可以对该DNS服务器提出查询请求的意思。原本文件的内容默认是针对localhost开放，这里改成对所有用户开放。默认的DNS就是对所有用户放行，因此这个设置值可以不用写（注意原本文件内容与默认的DNS的区别）
        * `forward only;`：这个设置可以让DNS服务仅进行forward，即便有`.`这个zone file，也不会使用`.`的数据，只会将查询权上交给上层DNS服务器，这个是cache only DNS最常见的设置
        * `forwarders{10.3.9.6;};`：可以设置多个DNS服务器，避免其中一台宕机导致服务停止，每一个forwarder服务器的IP都需要有`;`来结尾，另外大括号外也要有`;`
    1. 启动named并查看服务器的端口
        `systemctl restart named.service`
        `netstat -tunlp | grep named`

    1. 检查`/var/log/messages`的日志信息（极重要）
    1. 测试
        * 如果你的DNS服务器具有连上因特网的功能，那么通过`dig www.baidu.com @127.0.0.1`
        * 如果找到`www.baidu.com`的IP，并且最先面显示`SERVER:127.0.0.1#53（127.0.0.1）`字样，就代表成功了

**forwarders的好处与问题分析**

1. 利用forwarders的功能来提高效率的理论
    * 当很多下层DNS服务器都使用forwarders时，那么那个被设置为forwarder的主机，由于会记录很多的查询信息记录
    * 因此对那些下层的DNS服务器而言，查询速度回快很多，亦即节省很多查询时间，因为forwarder服务器里面有较多缓存记录
    * 因此包括forwarder本身，以及所有向这台forwarder要求数据的DNS服务器，都能减少往`.`查询的机会，因此速度当然加快
1. 利用forwarders反而会使整体的效率降低
    * 当DNS本身的业务量就很繁忙时，那么你的cache-only DNS服务器还要向他要求数据，因为它原本的数据传输量就太大了，带宽方面可能负荷过大，而太多的下层DNS还向它要求数据，所以它的查询速度会变慢
    * 而你的cache-only Server又是向它提出要求的，因此自然两边的查询速度都会同步下降
1. 如果上层DNS速度很快的话，那么它被设置为forwarder时，或许真的可以提高不少效率

# 4 DNS服务器的详细设置

**架设DNS服务器的细节**

1. DNS服务器的架设需要上层DNS的授权才可以成为合法的DNS服务器（否则只是练习）
    * 没有注册，就代表在上层的DNS服务器中是没有这台DNS服务器的记录的，即本台DNS服务器是没有一个合法域名，因此不具备分配主机名的能力
    * 但是没有注册，只要该DNS可以正常联网，那么其他主机仍然可以通过这台DNS来查询“合法主机名”的IP，这里的合法主机名必然是在其他DNS服务器进行注册过的主机名
1. 配置文件的位置：目前BIND程序已进行chroot，相关目录参考`/etc/sysconfig/named`
1. named主要配置文件：`/etc/named.conf`
1. 每个正、反解区域都需要一个数据库文件，而文件名则是由`/etc/named.conf`所设置
1. 当DNS查询时，若本身没有数据库文件，则前往root（`.`）或farwarders服务器查询
1. named能否成功启动务必要查询`/var/log/messages`内的信息（其实`systemctl restart named.service`，若失败则会提供日志查询的命令的）

## 4.1 正解文件记录的数据（Resource Record,RR）

**正解文件资源记录（Resource Record，RR）格式**，我们可以发现，dig命令输出结果的格式几乎是固定的
```
[domain]        [ttl]             [class]      [[RR type]       [RR data]]
[待查数据]       [暂存时间（秒）]     IN           [资源类型]        [资源内容]
```

* `domain`：域名
* `ttl`：time ro live，缓存时间，单位秒
* `class`：要查询信息的类别，`IN`代表类别为`IP协议`，即`Internet`。还有其它类别，比如`chaos`等，由于现在都是互联网，所以其它基本不用
* `RR type`与`RR data`是互相有关联性的
    * `A`<==>`IPv4`
	* `AAAA`<==>`IPv6`
    * `NS`<==>`主机名`
* 此外，在domain部分，若可能的话，请尽量使用FQDN，即主机名结尾加一个小数点（`.`），就被称为FQDN（Fully Qualified Domain Name，全限定域名）
* `ttl`：time to live的缩写，这笔记录被其他DNS服务器查询到后，这个记录会在对方DNS服务器的缓存中，保持多少秒钟的意思，由于ttl可由特定参数统一管理，因此在RR记录格式中，通常这个ttl字段是可以忽略的

**正解文件的RR记录格式汇整如下**

| `[domian]` | `IN` | `[[RR type]` | `[RR data]]` |
|:--|:--|:--|:--|
| `主机名.` | `IN` | `A`| `IPv4的IP地址` |
| `主机名.` | `IN` | `AAAA` | `IPv6的IP地址`|
| `域名.` | `IN` | `NS` | `管理这个域名的服务器主机名` |
| `域名.` | `IN` | `SOA` | `管理这个域名的七个重要参数` |
| `域名.` | `IN` | `MX` | `顺序数字，接收邮件的服务器主机名` |
| `主机别名.` | `IN` | `CNAME` | `实际代表这个主机别名的主机名` |

**A、AAAA（Address）：查询IP的记录**

* `dig -t a www.ksu.edu.tw`
* 这个A的RR类型是在查询某个主机名的IP，也是最常被查询的一个RR标志
* 如果IP设置的是IPv6的话，那么查询就需要使用AAAA类型才行

**NS（Name Server）：查询管理区域名（Zone）的服务器主机名**

* `dig -t ns ksu.edu.cn`

**SOA（Start of Authority）：查询管理域名的服务器管理信息**

* 如果有多台DNS服务器管理同一个域名，那么最好使用Master/Slave的方式来进行管理，就需要声明被管理的zone file是如何进行传输的，此时就需要SOA（Start Of Authorty）的标志了
* `dig -t soa ksu.edu.tw`

**SOA后面总共会接七个参数**

1. `Master DNS服务器主机名`：这个区域主要是哪台DNS作为Master的意思
1. `管理员的E-mail`：由于@在数据库文件中是有特殊意义的，因此就将@替换为mail
1. `序号（Serial）`：当修改了数据库内容时，需要将这个值放大才行，通常的格式为`YYYYMMDDNU`，例如2010080369代表2010年08月03当天第69次更改
1. `更新频率（Refresh）`：Salve向Master要求数据更新的频率，如果发现序号没有增大，则不会下载数据库文件
1. `失败重新尝试时间（Retry）`：由于某些因素导致Slave无法对Master实现连接，那么在多长时间内，Slave会尝试重新连接到Master，若连接成功了，又恢复为原来的更新频率
1. `时效时间（Expire）`：如果一直尝试失败，持续连接到这个设置值时限，那么Save将不再继续尝试连接，并尝试删除这份下载的zone file信息
1. `缓存时间（Mimumum TTL）`：如果数据库zone file中，每笔RR记录都没有写到TTL缓存时间的话，那么就以SOA的设置值为主

**参数限制**

1. `Refresh>=Retry*2`
1. `Refresh+Retry<Expire`
1. `Expire>=Retry*10`
1. `Expire>=7Days`

**CNAME（Canonical Name）：设置某主机名的别名（alias）**

* 有时候你不想针对某个主机名设置A标志，而是想通过另外一台主机名的A来规范这个新主机名，这时可以使用CNAME的设置
* 为什么要用CNAME?
    * 如果你有一个IP，这个IP是给很多主机名使用的，那么当你的IP更改时，所有的数据就得全部更新A标志才行
    * 如果你只有一个主要主机名设置A，而其他的标志使用CNAME，那么当IP更改时你只需要修订一个A标志，其他的CNAME就跟着变动了，处理起来比较容易

**MX（Mail Exchanger）：查询某域名的邮件服务器主机名**

* MX是Mail eXchanger（邮件交换）的意思
* 通常整个区域会设置一个MX，表示所有寄给这个区域的E-mail应该要送到后头的E-mail Server主机名上才行
* 通常大型的企业会有多台上层的邮件服务器来预先接受信件，那么数字较小的邮件服务器优先

## 4.2 反解文件记录的RR数据

以`www.ksu.edu.tw.`为例，从整个域的概念来看，越右边出现的名称代表域越大，即`.（root）>.tw>.edu`

但是IP不同，以`120.114.100.101`为例，`120>114>100>101`，与默认的DNS从右边向左边查询不一样，于是反解的Zone必须要将IP反过来，而在结尾时加上`.in-addr-arpa.`的结尾字样即可`dig -x 120.114.100.101`得到以下输出：
```
...

;; ANSWER SECTION:
101.100.114.120.in-addr.arpa. 3600 IN	PTR	120-114-100-101.ksu.edu.tw.

...
```

**PRT就是反解，即是查询IP所对应的主机名**：反解最重要的地方就是：后面的主机名尽量使用完整的FQDN，亦即机上小数点`.`，

## 4.3 步骤一：DNS的环境规划

1、假设在局域网中要设置DNS服务器，局域网域名为`centos.liuye`，搭配的IP网段为`192.168.100.0/24`，因此主要正解区域为`centos.liuye`，反解的区域是`192.168.100.0/24`。并且想要寻找`.`而不通过forwarders的辅助，因此还需要`.`的区域正解文件，以下为需要的配置文件

1. `named.conf`：主要配置文件
1. `named.centos.liuye`：主要的`centos.liuye`的正解文件
1. `named.192.168.100`：主要的`192.168.100.0/24`的反解文件
1. `named.ca`：由bind软件提供的`.`正解文件

## 4.4 步骤二：主配置文件/etc/named.conf的设置

该文件的主要任务

* `options`：规范DNS服务器的权限（可否查询、forward与否等）
* `zone`：设置出Zone（domain name）以及zone file的所在（包含master/slave/hint）
* 其他：设置DNS本机管理接口以及相关的密钥文件（key file）

**以下为配置内容**

```
options {
	listen-on port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	recursion yes;

	allow-transfer {none;};
};

zone "." IN{
	type hint;
	file "named.ca";
};

zone "centos.liuye." IN{
	type master;
	file "named.centos.liuye";
};

zone "200.168.192.in-addr.arpa." IN {
	type master;
	file "named.192.168.200";
};
```

## 4.5 步骤三：最上层.（root）数据库文件的设置

`.`是由INTERNIC所管理维护的，全世界共有13台管理`.`的DNS服务器

BIND软件已经提供了一个名为`namced.ca`的文件了

## 4.6 步骤四：正解数据库文件的设置

正解文件一定要有的RR标志有下面几个

1. 关于本区域的基础设置方面：例如缓存记忆时间（TTL）、域名（ORIGIN）等
1. 关于Master/Slave的认证方面（SOA）
1. 关于本区域的域名服务器所在的主机名与IP对应（NS、A）
1. 其他正反解相关的资源记录（A、MX、CNAME等）

正解文件中的特殊符号

| 字符 | 意义 |
|:--|:--|
| 一定从行首开始 | **所有设置数据一定要从行首开始，前面不可有空格符，若有空格符，代表延续前一个domain的意思，非常重要** |
| `@` | 代表Zone的意思，例如写在`named.centso.liuye`中，@代表`centos.liuye.`（注意最后的点），如果写在`named.192.168.200`文件中，则`@`代表200.168.192.in-addr.arpa.（注意最后的点）|
| `.` | 非常重要，因为它带包一个完整主机名（FQDN）而不是仅有hostname而已。例如在`named.centos.liuye`当中写`www.centos.liuye`则FQDN为`www.centos.liuye.@`==>`www.centos.liuye.centos.liuye.`，因此自然要写成`www.centos.liuye.` |
| `;` | 代表批注符号，似乎`#`也是批注，两个都能用 |

**以下为配置内容**
```
$TTL 600
@  IN  SOA  master.centos.liuye.  liuye.www.centos.liuye.  
(2011080401 3H 15M 1W 1D)
@  IN  NS  master.centos.liuye.
master.centos.liuye.  IN A  192.168.200.254
@  IN  MX  10  www.centos.liuye.

www.centos.liuye.  IN A  192.168.200.254
linux.centos.liuye.  IN CNAME  www.centos.liuye.
ftp.centos.liuye.  IN CNAME  www.centos.liuye.

Linux2.centos.liuye.  IN  A  192.168.200.101
```

**务必注意完整主机名（FQDN）之后的点**

* 加上了`.`表示这是个完整的主机名（FQDN），亦即`hostname+domain name`
* 若没有加上`.`，表示该名称仅为`hostname`，因此完整的FQDN要加上Zone，即`hostname.@`

## 4.7 步骤五：反解数据库文件的设置

由于反解的Zone名称是`zz.yy.xx.in-addr.arpa.`模样，因此只要在反解里面用到主机名时，务必使用FQDN来设置

由于我们的Zone是`200.168.192.in-addr.arpa.`，因此IP的全名部分已经含有192.168.200了，因此我们只需要写出最后一个IP即可，而且不用加点，利用hostname.@来帮助我们补全

**以下为配置内容**

```
$TTL    600
@  IN  SOA  master.centos.liuye.  liuye.www.centos.liuye.  
(2011080401 3H 15M 1W 1D)
@  IN  NS  master.centos.liuye.
254  IN  PTR  master.centos.liuye.

254  IN  PTR  www.centos.liuye.
101  IN  PTR  Linux2.centos.liuye.
```

* 同理，反解的主机名也得记得自后加`.`，否则给你自动补上`.@`了

## 4.8 步骤六：DNS启动查看与防火墙

```sh
systemctl restart named.service
systemctl enable named.service
```
**利用firewall-cmd或者firewall-config来配置防火墙**

## 4.9 测试与数据库更新

**测试有两种方式**

1. 一种通过Client端的查询功能，目的是检验数据库设置有无错误
1. 利用`http://thednsreport.com/`来检验，但是该网站的检验主要是以合法授权的Zone为主，我们自己乱搞的DNS是没法检验的

**修改`/etc/resolv.conf`**

* 使得自己的非合法DNS主机IP写在最上面，否则只要上面的DNS网络通畅，那么该DNS便是无效的，因此自然查不到自己设定的非法主机名

**判断成功与否**

* 是否与预期相符合
* 如果出现错误信息或者找不到某个反解的IP或者正解的主机名那么就说明不正确了

**数据库更新，例如主机名或IP变更，或者添加某个主机名与IP对应**

* 先针对要更改的那个Zone的数据库文件去做更新，就是加入RR（Resource Record）标志
* 更改该zone file的序号（Serial），就是SOA的第三个参数（第一个数字），因为这个数字会影响到Master/Slave的判定更新与否
* 重新启动named，或者让named重新读取配置文件即可

# 5 协同工作的DNS：Slave DNS及子域授权设定

**Slave DNS的特色**

* 为了不间断地提供DNS服务，你的领域至少需要有两台DNS服务器来提供查询的功能
* 这几台DNS服务器应该要分散在两个以上的不同IP网段才好
* 为方便管理，通常除了一台主要Master DNS之外，其他的DNS会使用Slave模式
* Slave DNS服务器本身并没有数据库，它的数据库是由Master DNS所提供的
* Master/Slave DNS需要有可以相互传输zone file的相关信息才行，这部分需要/etc/named.conf的设置加以辅助

## 5.1 masterDNS权限的开放

**基本假设**

1. 提供Slave DNS服务器进行zone transfer的服务器为`master.centos.liuye`
1. `centos.liuye`以及`200.168.192.in-addr.arpa`两个Zone都提供给Slave DNS使用
1. `master.centos.liuye`的named仅提供给`slave.centos.liuye`这台主机进行zone transfer
1. Slave DNS Server架设在192.168.200.101这台服务器上面（所以zone file要修订）
1. 将上面的Master主机修改后如下

```
options {
	listen-on port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	recursion yes;

	allow-transfer {none;};
};

zone "." IN{
	type hint;
	file "named.ca";
};

zone "centos.liuye." IN{
	type master;
	file "named.centos.liuye";
	allow-transfer { 192.168.200.101; };
};

zone "200.168.192.in-addr.arpa." IN {
	type master;
	file "named.192.168.200";
	allow-transfer { 192.168.200.101; };
};
```

## 5.2 Slave DNS的设置与数据库权限问题

既然Slave DNS也是DNS服务器，所以也要安装bind、bind-chroot等软件

既然Master/Slave的数据库是相同的，那么理论上`/etc/named.conf`内容就是大同小异了

* 唯一要注意的就是zone type类型，以及声明Master在哪里
* 至于zone filename部分，由于zone file都是从Master取得的，通过named这个程序来主动建立起需要的zone file，因此这个zone file放置的目录权限就很重要

**以下是`/etc/named.conf`配置内容**

```
options {
	listen-on port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	recursion yes;

	allow-transfer {none;};
};

zone "." IN{
	type hint;
	file "named.ca";
};

zone "centos.liuye." IN{
	type slave;
	file "slaves/named.centos.liuye";
	masters { 192.168.200.254; };   //注意大括号与IP之间有空格，不然会高亮红色显示
};

zone "200.168.192.in-addr.arpa." IN {
	type slave;
	file "slaves/named.192.168.200";
	masters { 192.168.200.254; };
};
```

## 5.3 配置子域DNS服务器：子域授权课题

我们以刚在Master上面建立的`centos.liuye`这个Zone为例，假设今天你是个ISP，有人想和你申请domain name，他要的domian是`lh.centos.liuye`，该如何处理

* 上层DNS服务器：也就是`master.centos.liuye`这一台，只要在`centos.liuye`那个zone file内，增加指定NS并指向下层DNS主机名与IP对应即可，而zone file的需要也要增加才行
* 下层DNS服务器：申请的域名必须是上层DNS所可以提供的名称，并告知上层DNS管理员，我们这个Zone所需指定的DNS主机名与对应的IP即可，然后就可以开始设置自己的Zone与zone file相关数据了

**上层DNS服务器**：只需要添加zone file的`NS`与`A`即可，在`/etc/named.conf`中添加如下两行
```
lh.centos.liuye.	IN NS	dns.lh.centos.liuye.
dns.lh.centos.liuye.	IN A	192.168.200.102
```
**下层DNS服务器**：需要有完整的Zone相关设置，`/etc/named.conf`中内容如下
```
options {
	listen-on port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	recursion yes;

	allow-transfer {none;};
};

zone "." IN{
	type hint;
	file "named.ca";
};

zone "lh.centos.liuye." IN{
	type master;
	file "named.lh.centos.liuye";
};
```

**`/var/named/named.lh.centos.liuye`内容如下**
```
$TTL	600
@		IN SOA	dns.lh.centos.liuye. root.lh.centos.liuye. 
(2016112901 3H 15M 1W 1D)
@		IN NS 	dns.lh.centos.liuye.
dns		IN A	192.168.200.101
```

## 5.4 依不同接口给予不同的DNS主机名：view功能的应用

以目前的局域网服务器来说，我的`master.centos.liuye`有两个接口，分别是`192.168.200.254/24`（对内）以及`192.168.136.166`（对外）

* 外边的用户想要了解到`master.centos.liuye`这台服务器的IP时，取得的是`192.168.200.254`，因此需要通过NAT才能连接到该接口
* 但是明明`192.168.136.166`与`192.168.200.254`是同一台服务器主机，有没有办法让外部查询找到`master.centos.liuye`是`192.168.136.166`而内部的找到则回应1`92.168.200.254`---**通过view功能**

**设置view**

1. 建立一个名为intranet的名字，这个名字代表客户端为`192.168.200.0/24`的来源
1. 建立一个名为internet的名字，这个名字代表客户端为非`192.168.136.0/24`的其他来源
1. intranet使用的zone file为前面所建立的zone filename，internet使用的zone filename则在原本的文件名后面累加inter的扩展名，并修订各标志的结果
1. 最终的结果中，从内网查到的`www.centos.liuye`的IP应该是`192.168.200.254`，从外网中查询到的`www.centos.liuye`的IP应该是`192.168.136.166`

**以下为修改后的`/etc/named.conf`**

```
options {
	listen-on port 53 { any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };

	recursion yes;

	allow-transfer {none;};
};

acl intranet { 192.168.200.0/24; };
acl internet { ! 192.168.200.0/24; any; };

view "lan"{
	match-clients { "intranet"; };
	zone "." IN{
		type hint;
		file "named.ca";
	};

	zone "centos.liuye." IN{
		type master;
		file "named.centos.liuye";
		allow-transfer { 192.168.200.101; };
	};

	zone "200.168.192.in-addr.arpa." IN {
		type master;
		file "named.192.168.200";
		allow-transfer { 192.168.200.101; };
	};
};

view "wan" {
	match-clients { "internet"; };
	zone "." IN {
		type hint;
		file "named.ca";
	};

	zone "centos.liuye." IN{
		type master;
		file "named.centos.liuye.inter";
	};
};
```

# 6 DNS服务器的高级设定

##	架设一个合法授权的DNS服务器

1. 必须要上层服务器将子域的查询权开放给你来设置
1. 申请一个合法的domian name（缴费）
1. 以DNS服务器的详细设置的内容来设置主机
1. 测试

## 6.1 LAME Server的问题

当DNS服务器在向外面的DNS系统查询某些正反解时，可能由于对方DNS主机的设置错误，导致无法解析到预期的正反解结果，这时候就是所谓的Lame Server的错误

## 6.2 利用RNDC命令管理DNS服务器

rndc是BIND version9以后所提供的功能，可以让你轻松管理DNS服务器，包括检查已经存在DNS缓存当中的资料，重新更新某个Zone而不需要重新启动整个DNS，以及检查DNS的状态与统计资料等

由于rndc可以很深入地管理你的DNS服务器，所以要进行一些控制

* 通过rndc的设置来建立密钥（rndc key），并将密钥相关的信息写入named.conf配置文件当中
* 通过以下步骤进行配置（详见P639-P640）
    * rndc-confgen
    * 然后将输出的信息中的`key "rndc-key"{...};`部分复制
    * `vim /etc/rndc.key`
    * 将复制的信息覆盖掉原内容
    * `vim /etc/named.conf`
    * 在最后面添加上述复制的内容
    * 然后追加以下
        * 
```
controls{
inet 127.0.0.1 port 953 allow { 127.0.0.1; } keys { "rndc-key"; };
}
```

## 6.3 搭建动态DNS服务器：让你成为ISP

如果以拨号方式的ADSL连上Internet，那么IP通常是ISP随机提供的，因此，每次上网的IP都不固定，因此DDNS（Dynamic DNS,DDNS）主机就必须提供一个机制，让客户端可以通过这个机制来修改他们在DDNS主机上面的zone file内的数据才行

**如何实现**

* BIND9就提供类似的机制
* 我们的DDNS主机现提供Client一个key（就是认证用的数据，你可以将它理解成账号与密码的概念）
* Client端利用这个key，并配合BIND9的nsupdate命令，就可以连上DDNS主机，并且修改主机上面zone file内的对应表了

**DDNS Server端的设置**

* `<dnssec-keygen>`
    * `dnssec-keygen -a [算法] -b [密码长度] -n [类型] 名称`
    * `-a`：后面接的type为盐酸方式，主要有RSAMD5、RSA、DSA、DH、HMAC-MD5等
    * `-b`：密码长度，通常给予512位的HMAC-MD5
    * `-n`：后面接的则是客户端能够更新的类型，主要有下面两种
        * `ZONE`：客户端可以更新任何标志及整个ZONE
        * `HOST`：客户端仅可以针对他的主机名来更新
    * `cd /etc/named`
    * `dnssec-keygen -a HMAC-MD5 -b 512 -n HOST web`
    * 接下来将公钥的密码复制到`/etc/named.conf`中，将私钥传给`web.centos.liuye`那台主机
    * `vim /etc/named.conf`
        * 
```
key "web" {
	algorithm hmac-md5;
	secret "<这里是公钥密码>";
};

zone "centos.liuye." IN{
	type master;
	file "named.centos.liuye";
	allow-transfer { 192.168.200.101; };
	update-policy{   #添加这一段
		grant web name web.centos.liuye. A;
	};
};
```

        * `grant [key_name] name [hostname] 标签`：允许指定主机通过指定密码修改指定标签
    * `chmod g+w /var/named`
    * `chown named /var/named/named.centos.liuye`
    * `systemctl restart named.service`
    * `setsebool -P named_write_master_zones=1`

**设置Client端**

* 将Server端的密码公钥与私钥文件通过sftp传送到客户端的`/usr/local/ddns`目录下
* `cd /usr/local/ddns`
* `nsupdate -k *.key`
    * server 192.168.200.254
    * update add web.centos.liuye 600 A 192.168.200.102
    * send
    * [ctrl]+D   <==退出
* 于是就会发现在DNS服务器端的/var/named/里面多出一个临时文件，那就是named.centos.liuye.jnl，用于记录客户端要求而更新的数据

# 7 参考

* 《鸟哥的Linux私房菜：服务器架设篇（第三版）》
