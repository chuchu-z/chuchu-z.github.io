---
title: 'Windows10 激活产品密钥'
date: 2023-12-26 09:37:20
categories:
- Other
---





> 帮同事电脑重装系统 需要激活产品密钥 网上有很多 但是很大部分都不可用 找了挺久 找到一个挺多人反馈可用的 记录下来看后面用不用的上

<!--more-->



## 激活方法

win+Q, 搜索cmd, 以管理员身份打开cmd工具， 按顺序执行下面4条命令, 也有人说把第三个命令行输入后去掉 `http://`  只保留域名部分才可以成功

实在不行就去 **设置-更新和安全-激活** 里面激活, 产品密钥 **W269N-WFGWX-YVC9B-4J6C9-T83GX**

```shell
slmgr /ckms
slmgr /ipk W269N-WFGWX-YVC9B-4J6C9-T83GX
slmgr /skms http://kms.03k.org
slmgr /ato
```



## 结语

上面这个密钥不知道什么时候会失效, 以前也用过一些软件激活的, 现在想想这个东西, 其实就是写个循环 用枚举暴力破解, 假如我把网络上的产品密钥都收集起来放到一个文本文件里, 一个密钥一行, 脚本再一行一行的去读取该文本文件, 脚本循环执行上面的几行激活代码, 替换掉固定的密钥, 是不是也是一个自动激活工具呢