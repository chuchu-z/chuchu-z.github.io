---
title: '关于谷歌Chrome浏览器非安全端口限制问题'
date: 2022-3-24 12:38:16
categories: Other

---



关于前段时间深圳疫情严重, 公司选择通过VPN居家远程办公

有个项目在App端测试由于无法通过VPN请求Api, 运维开放了外网地址并指定端口

<!--more-->

但在`Chrome`浏览器上打开时无法正常得到正常的响应, 而使用`postman`等测试工具是可以正常响应的



这个问题以前有遇到过，是因为 `Chrome` 浏览器对非安全端口进行了限制, 具体端口可在这里查看

https://chromium.googlesource.com/chromium/src.git/+/refs/heads/master/net/base/port_util.cc



## 解决的办法

windows只需要右键`Chrome`浏览器快捷图标, 在`属性`设置里面的`目标`处增加以下参数,  然后关闭`Chrome`重新打开即可正常访问

```bash
 # 多个端口号以英文逗号隔开
 --explicitly-allowed-ports=10080,30300
```



![image-20220324140658057](https://aexphoto-1251755124.file.myqcloud.com/img/2022/03/69ffe943a57fbc38de7c4e6b52f30fec.png)





Mac

```bash
# Chrome浏览器的解决方案
open -a /Applications/Google Chrome.app/Contents/MacOS/Google Chrome --explicitly-allowed-ports=6666,8888
```



## Chrome 302重定向

本以为解决完端口问题后就可以快乐地编码, 然而当我正常打开页面登录后, 又遇到了另一个问题

登录成功后, 只要点击其他任意跳转, 页面会被重定向跳回到登录界面, 初步判断是因为`Cookies`的问题, 导致登录态没有了

>   遗留问题1. 无法确定是因为端口的问题导致`Cookies`丢失



具体是事例在网上只找到了这个, 不确定是否同样的原因, 但因为我的`Chrome`浏览器版本目前是`99.0.4844.82`版本, 正如此博主所说

在`chrome91`及其以上版本，无法找到`SameSite by default cookies`和`Cookies without SameSite must be secure`两项配置

虽然没有解决我的问题, 但起码提供了参考

![](https://aexphoto-1251755124.file.myqcloud.com/img/2022/03/2067d66b7b939b94f21ae22acabc8668.png)



>   遗留问题2. 无法验证该方案是否可行
