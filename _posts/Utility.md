---
title: Utility
date: 2020-07-25 10:47:33
tags: 
- 原创
categories: 
- Tools
---

**阅读更多**

<!--more-->

# 1 Graph

1. [excalidraw](https://excalidraw.com/)
   * [github-excalidraw](https://github.com/excalidraw/excalidraw)
1. [asciiflow](https://asciiflow.com/)
1. [textik](https://textik.com/)
   * 同样是ascii作图，但是比`asciiflow`好用很多

## 1.1 Ascii

Unicode Box Drawing character set, which includes a variety of horizontal, vertical, and corner elements for creating box-like structures and tables. Here are some symbols from the Box Drawing character set:

* `┌ (U+250C)`: Box Drawings Light Down and Right (corner)
* `┐ (U+2510)`: Box Drawings Light Down and Left (corner)
* `┘ (U+2518)`: Box Drawings Light Up and Left (corner)
* `┤ (U+2524)`: Box Drawings Light Vertical and Left (T-junction)
* `├ (U+251C)`: Box Drawings Light Vertical and Right (T-junction)
* `┴ (U+2534)`: Box Drawings Light Up and Horizontal (T-junction)
* `┬ (U+252C)`: Box Drawings Light Down and Horizontal (T-junction)
* `─ (U+2500)`: Box Drawings Light Horizontal (horizontal line)
* `│ (U+2502)`: Box Drawings Light Vertical (vertical line)
* `━ (U+2501)`: Box Drawings Heavy Horizontal (thicker horizontal line)
* `┃ (U+2503)`: Box Drawings Heavy Vertical (thicker vertical line)
* `┼ (U+253C)`: Box Drawings Light Vertical and Horizontal (cross)
* `╔ (U+2554)`: Box Drawings Double Down and Right (double line corner)
* `╗ (U+2557)`: Box Drawings Double Down and Left (double line corner)
* `╚ (U+255A)`: Box Drawings Double Up and Right (double line corner)
* `╝ (U+255D)`: Box Drawings Double Up and Left (double line corner)
* `→ (U+2192)`: Rightwards Arrow
* `← (U+2190)`: Leftwards Arrow
* `↑ (U+2191)`: Upwards Arrow
* `↓ (U+2193)`: Downwards Arrow
* `↔ (U+2194)`: Left Right Arrow (horizontal bidirectional arrow)
* `↕ (U+2195)`: Up Down Arrow (vertical bidirectional arrow)
* `↖ (U+2196)`: Northwest Arrow (diagonal arrow pointing to the upper-left)
* `↗ (U+2197)`: Northeast Arrow (diagonal arrow pointing to the upper-right)
* `↘ (U+2198)`: Southeast Arrow (diagonal arrow pointing to the lower-right)
* `↙ (U+2199)`: Southwest Arrow (diagonal arrow pointing to the lower-left)
* `↞ (U+219E)`: Leftwards Two Headed Arrow (double-headed arrow pointing left)
* `↠ (U+21A0)`: Rightwards Two Headed Arrow (double-headed arrow pointing right)
* `↢ (U+21A2)`: Leftwards Arrow with Tail (arrow with a curved tail pointing left)
* `↣ (U+21A3)`: Rightwards Arrow with Tail (arrow with a curved tail pointing right)
* `↦ (U+21A6)`: Rightwards Arrow from Bar (arrow with a horizontal line through the shaft pointing right)
* `↧ (U+21A7)`: Downwards Arrow from Bar (arrow with a horizontal line through the shaft pointing down)
* `↩ (U+21A9)`: Leftwards Arrow with Hook (arrow with a hook tail pointing left)
* `↪ (U+21AA)`: Rightwards Arrow with Hook (arrow with a hook tail pointing right)

## 1.2 Reference

* [一个好用的画图工具 excalidraw](https://learnku.com/articles/47662)
* [纯文本作图-asciiflow.com](http://asciiflow.com/)

# 2 Chrome Plugin

## 2.1 GitHub Speed Up

国内github下载速度较慢，可以安装chrome扩展程序「GitHub加速」

![fig1](/images/实用工具/chrome_fig1)

启用该扩展程序后，在github上就可以看到加速地址了

![fig2](/images/实用工具/chrome_fig2)

# 3 How to access Internet

下面这段文字引用自[科学上网的主流协议大对比！这里面有你在使用的吗？](https://www.techfens.com/posts/kexueshangwang.html) 

> 还是那句话，有墙不一定是坏事，没墙不一定是好事。
> 
> 烂的是国内的中文互联网，大家也不要把怨气全撒在墙上，墙只是一个工具，是一项政策，各位可以讨厌它，但还希望可以给它基本的尊重，我们翻出去，找到自己需要的东西，收好就可以了。
> 
> 说句好听的，在大环境带墙的情况下，能出来的各位都是《特权阶级》，不要一边吃饭一边摔碗。
> 
> 这个世界上没有密不透风的墙，也没有永恒不倒的梯子，墙和梯子的关系是微妙的，梯子更像是一个准入门槛，而不是漏洞，很多时候不过是睁一只眼闭一只眼罢了。

## 3.1 VPN

`VPN`的原本目的并不是用来翻墙，而是在公用网络上建立专用网络，进行加密通讯

**协议：**

* `IPsec`
* `OpenVPN`
* `WireGuard`

**优缺点：**

* 优点：
   * 成熟、稳定
   * 工作在底层，可以实现真正意义上的全局代理。大多数的游戏代理需要通过VPN来实现
* 缺点
   * 特征明显，容易被墙准确识别
   * 主打传输安全性，性能较差

**服务商：**

* [ExpressVPN](https://www.expressvpn.com/)

## 3.2 Socks5

工作在应用层，只能代理特定流量（当然利用特定工具还是可以实现全局代理的，比如`SSTAP`、`tun2socks`等）

### 3.2.1 Protocol

| 项目名称 | 创建时间 | 支持协议 | 速度评分 | 推荐评分 | 推荐理由 |
|:--|:--|:--|:--|:--|:--|
| [Shadowsocks](https://github.com/shadowsocks/shadowsocks) | 2015 | <li>`Shadowsocks`</li> | ★★★★★ | ★★★★★ | <li>被广泛使用，一般作为各大机场的默认协议</li><li>最近项目无更新</li> |
| [Shadowsocks-R](https://github.com/shadowsocksrr/shadowsocksr) | 2016 | <li>`Shadowsocks-R`</li> | ★★★★★ | ★★★ | <li>`Shadowsocks`的升级版，增强了混淆能力</li><li>最近项目无更新</li><li>作为普通用户而言，无需纠结，用常见的`Shadowsocks`即可</li> |
| [Trojan](https://github.com/trojan-gfw/trojan) | 2019 | <li>`Trojan`</li> | ★★ | ★★ | <li>相比`V2Ray`速度更快，更轻量</li><li>相比`Trojan-go`较老</li><li>最近项目无更新</li> |
| [Trojan-go](https://github.com/p4gefau1t/trojan-go) | 2020.8 | <li>`Trojan`</li> | ★★★ | ★★★ | <li>速度次于`Xray`</li><li>隐秘性更强</li><li>客户端单一</li> |

### 3.2.2 Kernel

#### 3.2.2.1 Clash

**Projects(The repositories of this core and its derivative products have been deleted in 2023.11):**

* [Clash-Core](https://github.com/Dreamacro/clash)
* [ClashForAndroid](https://github.com/Kr328/ClashForAndroid)
* [ClassForWindows](https://github.com/Fndroid/clash_for_windows_pkg)

#### 3.2.2.2 Clash.Meta

**Protocol:**

* VMess
* VLESS
* Shadowsocks
* Trojan
* Snell
* TUIC
* Hysteria

**Projects:**

* [Clash.Meta-Core](https://github.com/MetaCubeX/Clash.Meta)
* [Clash-Verge](https://github.com/zzzgydi/clash-verge)
* [ClashX.Meta](https://github.com/MetaCubeX/ClashX.Meta)
* [ClashMetaForAndroid](https://github.com/MetaCubeX/ClashMetaForAndroid)

#### 3.2.2.3 v2ray

**Protocol:**

* Shadowsocks
* Trojan
* Vmess
* VLESS

**Projects:**

* [v2ray-core](https://github.com/v2fly/v2ray-core)

#### 3.2.2.4 Xray

**Protocol:**

* VLESS
* XTLS

**Projects:**

* [Xray-core](https://github.com/XTLS/Xray-core)
* [V2rayU](https://github.com/yanue/V2rayU)

#### 3.2.2.5 sing-box

**Protocol:**

**Projects:**

* [sing-box](https://github.com/SagerNet/sing-box)

### 3.2.3 Airport

[机场推荐](https://2022vpn.net/ss-v2ray-trojan-providers/)

| 机场名 | 支持的协议 | 支持的客户端 |推荐评分 | 推荐理由 |
|:--|:--|:--|:--|:--|
| [WgetCloud](https://wgetcloud.org/) | <li>`Shadowsocks`</li><li>`Shadowsocks-R`</li><li>`V2Ray`</li><li>`Trojan`</li> | <li>`Clash`</li> | ★★★★★ | `WgetCloud`是一家主打稳定翻墙的机场服务商，采用国内优质服务器接入，亚马逊`Global Accelerator`专线加速。`WgetCloud`由海外团队运作，套餐价格相对偏贵，属于高端翻墙机场，适合追求极致稳定的翻墙用户，如外贸工作、开发人员使用 |
| [Nirvana](https://portal.meomiao.xyz/) | <li>`Shadowsocks`</li> | <li>`Clash`</li> | ★★★★★ | 萌喵加速`Nirvana`是一家老牌翻墙服务商，由海外团队运营，采用国内中转和`IEPL`内网专线节点，服务稳定可靠 |
| [Flyint](https://www.flyint.win/) | <li>`Shadowsocks`</li> | <li>`Clash`</li> | ★★★★★ | `Flyint`飞数机场是一家运营时间比较长的翻墙机场，采用中转服务器出境，支持游戏加速。新用户可免费试用 |
| [paofu](https://www.paofu.cloud) | <li>`Shadowsocks`</li><li>`Shadowsocks-R`</li> | <li>`Clash`</li> | ★★★★★ | 泡芙云是一家稳定运营了多年的翻墙机场，由海外团队运作，提供`IEPL`内网专线服务，不过墙敏感时期也可用。新用户可1元试用 |
| [GLaDOS](https://glados.rocks/) | <li>`Shadowsocks`</li><li>`V2Ray`</li><li>`Xray`</li> | <li>`Clash`</li><li>`V2Ray`客户端</li> | ★★★★★ | `GLaDOS`是一家技术流翻墙机场，网站面板完全自主开发，除了支持常见的`Vmess`、`Trojan`翻墙协议，还支持 `Vless`协议和`Wire Guard VPN`协议。新用户可免费试用 |
| [fastlink](https://fastlink.pro/) | <li>`Shadowsocks`</li><li>`V2Ray`</li> | <li>`Clash`</li><li>`V2Ray`客户端</li> | ★★★★★ | 便宜稳定。有个问题访问不了ChatGpt |

### 3.2.4 Github Proxy

* [GitHub Proxy](https://ghproxy.com/)
* [GitMirror](https://gitmirror.com/)

## 3.3 Reference

* [Project V/V2Ray](https://www.v2ray.com/awesome/tools.html)
* [Project X/X2Ray](https://xtls.github.io/)

# 4 How to search

## 4.1 Exclusion

可以用关键词`-`来起到排除的作用，例如：`王刚 -百科`，就会搜到非百科的一些信息

## 4.2 Specific Site

可以用`site:xxx.yyy`来内容来自哪个站点，例如：`王刚 site:zhihu.com`，搜到的内容全部来自知乎

## 4.3 Specific Format

可以用`filetype:xxx`来指定内容的格式，例如：`王刚 filetype:pdf`，搜到的内容全部都是`pdf`格式

## 4.4 Content Containment

可以用`intext:<content>`来指定要搜索的内容必须出现在内容中，例如：`intext:王刚`

## 4.5 Title Containment

可以用`intitle:<content>`来指定要搜索的内容必须出现在标题中，例如：`intitle:王刚`

## 4.6 Word Segmentation Prohibition

可以用`"<content>"`来禁止搜索引擎对搜索内容进行分词，例如：`"美食家王刚"`

# 5 Tunnel

```sh
curl -s https://edge-tunnel.oss-cn-shanghai.aliyuncs.com/enableTunnel.sh | sudo bash -s <pk> <dn> <ds>
curl -s https://edge-tunnel.oss-cn-shanghai.aliyuncs.com/disableTunnel.sh | sudo bash -s
```
