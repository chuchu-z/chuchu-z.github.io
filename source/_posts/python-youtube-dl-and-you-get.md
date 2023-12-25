---
title: 'Python youtube-dl与you-get工具爬取视频'
date: 2023-12-25 11:23:21
categories: Python
---



**youtube-dl** 和 **you-get** 都是用于从互联网上下载视频的命令行工具，它们支持多种网站和服务

- **youtube-dl**  功能更加全面，支持的网站更多，但也可能更复杂一些。
- **you-get** 相对来说更简单，更容易上手，适用于一般用户。



<!--more-->



## 查看Python版本

```shell
# 安装Python后 查看Python版本
python --version
```



## youtube-dl

```shell
# 下载youtube-dl工具
pip install youtube-dl

# 使用工具
youtube-dl --list-formats [url] # 列出可用的视频格式和质量

youtube-dl -oif [ -o 指定输出文件名或目录] [-i 忽略下载过程中的错误] [-f 指定下载的视频格式/质量, 如mp4] [url]
```



## you-get

```shell
# 下载you-get工具
pip install you-get

# 使用工具
you-get -F [url]  # 列出可用的格式

you-get -i [url]  # 显示视频信息

you-get -o <输出目录> <视频链接>
```

