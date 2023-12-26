---
title: '一言网（hitokoto.cn）API接入shell脚本'
date: 2022-2-24 11:49:48
categories:
- Linux

---



## 前言

之前发现个很不错的网站 [ 一言网（hitokoto.cn）](hitokoto.cn) 很喜欢该网站的提供的服务

<img src="hitokoto-api-shell/image-20231225124236829.png" style="zoom:150%;" />

并且他们还提供了免费的API接口, 只需要访问该接口, 就会返回一段话 [https://v1.hitokoto.cn/?encode=text](https://v1.hitokoto.cn/?encode=text) 

于是我就更想把它做进我的**shell**终端里

<!--more-->



## 接口文档

> 一言接口文档
>
> https://developer.hitokoto.cn/sentence/



## 具体脚本代码

```shell
# 返回普通文本
#`curl -ks https://v1.hitokoto.cn/?encode=text`

url='https://v1.hitokoto.cn'
if [ x$1 != x ]; then
    url='https://v1.hitokoto.cn?'$1
fi

# 处理 json 数据(处理json数据需要安装jq)
json=`curl -ks $url`

# linux 安裝jq
# yum install epel-release
# yum list jq
# yum install jq

# windows 安裝jq
# https://stedolan.github.io/jq/

random=$[RANDOM%7+31]

echo -e
content=`echo ${json} | jq '.hitokoto' | sed 's/"//g' | tr -d '\n'`
printf "\033[1;${random}m%s\033[0m" "『 " $content " 』"
from_who=`echo ${json} | jq '.from_who' | sed 's/"//g' | tr -d '\n'`
echo -e

if [ "$from_who" == 'null' ]
then
    from_who='匿名'
fi

length=`expr ${#content} \* 2`
printf "\033[1;${random}m%${length}s\033[0m" "—— $from_who"

from=`echo ${json} | jq '.from' | sed 's/"//g' | tr -d '\n'`
printf "\033[1;${random}m%s\033[0m" "「" $from "」"
echo -e

exit 0
```



