---
title: 'Win10 自定义 Git-Bash 终端界面 + 一言API与终端结合'
date: 2022-2-25 10:39:27
tags: Git
categories: Git
---



# Win10 自定义 Git-Bash 终端界面 + 一言API与终端结合



由于Git默认的界面长的实在是不够美观, 平时用起来都无法赏心悦目, 参考网上的一些文章资料, 做了下改动

<!--more-->



### 修改Git Bash 窗口左上角标题

```shell
#该命令是一次性的,关闭后重新打开会恢复, 后面有完整的 
echo -ne "\\e]0;title name\\a"
```



### 修改命令提示符

具体操作

打开 git-prompt.sh 文件

```shell
vim /etc/profile.d/git-prompt.sh
```



将其修改为如下内容：

```shell
if test -f /etc/profile.d/git-sdk.sh
then
    TITLEPREFIX=SDK-${MSYSTEM#MINGW}
else
    TITLEPREFIX=$MSYSTEM
fi

if test -f ~/.config/git/git-prompt.sh
then
    . ~/.config/git/git-prompt.sh
else
    PS1='\[\033]0;Bash\007\]'      # 窗口标题
    PS1="$PS1"'\n'                 # 换行
    PS1="$PS1"'\[\033[32;1m\]'     # 高亮绿色
    PS1="$PS1"' ➜ '               # unicode 字符，右箭头, 如果显示不出来大概率是utf-8编码问题
    PS1="$PS1"'\[\033[33;1m\]'     # 高亮黄色
    PS1="$PS1"'\W'                 # 当前目录
    PS1="$PS1"'\[\033[34;1m\]'     # 高亮蓝色
    PS1="$PS1"' [\t]'              # 当前时间
    
    if test -z "$WINELOADERNOEXEC"
    then
        GIT_EXEC_PATH="$(git --exec-path 2>/dev/null)"
        COMPLETION_PATH="${GIT_EXEC_PATH%/libexec/git-core}"
        COMPLETION_PATH="${COMPLETION_PATH%/lib/git-core}"
        COMPLETION_PATH="$COMPLETION_PATH/share/git/completion"
        if test -f "$COMPLETION_PATH/git-prompt.sh"
        then
            . "$COMPLETION_PATH/git-completion.bash"
            . "$COMPLETION_PATH/git-prompt.sh"
            PS1="$PS1"'\[\033[31m\]'   # 红色
            PS1="$PS1"'`__git_ps1`'    # git 插件
        fi
    fi
    PS1="$PS1"'\[\033[36m\] '      # 青色
fi

MSYS2_PS1="$PS1"
```



这个非常像 oh-my-zsh 的风格, 其实一开始就是想用zsh终端的, 奈何windows不支持, 如果平时日常开发想装的话也可以在linux虚拟主机或者docker里面装一个, zsh在目前来说可以说是最强大的shell了, 谁用谁知道



### 修改界面主题



```shell
vim ~/.minttyrc
```



默认配置如下:

```shell
Transparency=low
Language=
ForegroundColour=0,255,64
CursorColour=0,255,64
CursorType=block
Scrollbar=none
FontHeight=12
```



把以下内容添加到配置文件里面：

```shell
Font=Fira Code Medium
FontHeight=14
FontHeight=14
Transparency=low
FontSmoothing=default
Locale=C
Charset=UTF-8
Columns=88
Rows=26
OpaqueWhenFocused=no
Scrollbar=none
Language=zh_CN

ForegroundColour=131,148,150
BackgroundColour=0,43,54
CursorColour=220,130,71

BoldBlack=128,128,128
Red=255,64,40
BoldRed=255,128,64
Green=64,200,64
BoldGreen=64,255,64
Yellow=190,190,0
BoldYellow=255,255,64
Blue=0,128,255
BoldBlue=128,160,255
Magenta=211,54,130
BoldMagenta=255,128,255
Cyan=64,190,190
BoldCyan=128,255,255
White=200,200,200
BoldWhite=255,255,255

BellTaskbar=no
Term=xterm
FontWeight=400
FontIsBold=no
```



最后重启Git-Bash就可以看到配置好的界面了

效果图:

![image-20220225095728006](https://aexphoto-1251755124.file.myqcloud.com/img/2022/02/b59d6821407fde73b5f757df99c3b600.png)





另外说一下第一行是在 Options 中选择字体时设置的，我使用了 Fira Code， 14号字体,   Fira Code就是一款为写程序而生的字体

以上内容参考网络文章 有兴趣的可以深入了解[这里](http://www.voidcn.com/article/p-wavhthxe-tr.html), 不过也有可能无法访问了



### Fira Code

[Fira](https://www.jianshu.com/p/266b4fa2c446?tdsourcetag=s_pctim_aiomsg) 是 Mozilla 公司（火狐浏览器她爹）主推的字体系列。Fira Code 是其中的一员，专为写程序而生。出来具有`等宽`等基本属性外，还加入了编程连字特性（ligatures）。

Fira Code 就是利用这个特性对编程中的常用符号进行优化，比如把输入的「!=」直接显示成「≠」或者把「>=」变成「≥ 」等等，以此来提高代码的可读性

本人的使用的IDE也是装的这一款字体, 咳咳跑题了..



### 一言与终端结合

去年无意发现一个名叫 [一言](https://hitokoto.cn/) 的网站, 这个网站只是单纯的提供一句话,  可以是动漫中的台词，也可以是网络上的各种小段子。 或是感动，或是开心，有或是单纯的回忆



 并且还官方还提供了 [API接口文档](https://developer.hitokoto.cn/sentence/#%E7%AE%80%E4%BB%8B) 供我们免费调用, 于是并尝试了把该功能与终端做结合, 大概就是, 启动终端时请求API, 把随机返回的句子显示在终端上, 我认为是个有趣的想法, 具体实现思路, 写一个请求一言API的脚本, 终端启动时自动调用一次这个脚本



效果如下:

![图片](https://aexphoto-1251755124.file.myqcloud.com/img/2022/02/6000258bf5290f8a45b134500f78ed39.png)



编写一言脚本, 文件名和路径没有具体要求, 看个人

```shell
vim yy
```



具体代码[GitHub](https://github.com/chuchu-z/local-config/blob/master/yy)上也有,  直接拿下面的也行:

```shell
# 一言

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



编写完后可以试着执行 yy脚本一下试试 (代码里有说明要安装jq处理json数据)

![具体效果](https://aexphoto-1251755124.file.myqcloud.com/img/2022/02/4bafe9395e8ebc8797efa3ffe93e244e.png)



最后编辑~/.bashrc文件, 因为Git-Bash启动时会加载此文件

```shell
vim ~/.bashrc
```



在文件内容里加上yy后保存退出重新启动Git-Bash就行, (我能直接执行yy是配置了环境变量的, 如果没有配置的话需要写绝对路径)

```bash
# vim ~/.bashrc
# Git-Bash 初始化加载此配置文件
# shopt -s expand_aliases
# 允许shell脚本中使用 alias 命令
# 经测试, 在 #!/bin/sh 下, 该命令可有可无, 不影响 alias 的使用
# 在 !/bin/bash 下，才有影响

yy
```

