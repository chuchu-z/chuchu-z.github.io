---
title: '[记录] Install Python3 and OpenSSL'
date: 2023-7-18 16:31:05
tags:
- Python
categories:
- Python

---



因为有个项目要用到 Python 爬取直播间主播和弹幕数据, 所以记录一下安装过程以及途中遇到的问题

<!--more-->



先查看当前 Python 版本是2.7的, 后面要重新安装 Python3, 如果还没有安装过后面就更省事了

> python --version
>
> #输出为 Python 2.7.16



## OpenSSL Install

#安装py3新版本之前先安装openssl, 否则后面缺少ssl又需要重装， 如果 /usr/local  目录下已经有 openssl 文件夹，先把openssl 改名为 opensslbak 备份, 防止后面出现问题能恢复

> cd /usr/local
>
> mv openssl opensslbak
>
> 
>
> wget https://www.openssl.org/source/openssl-3.0.2.tar.gz --no-check-certificate
>
> tar -zxvf openssl-3.0.2.tar.gz
>
> cd openssl-3.0.2/
>
>  ./Configure --prefix=/usr/local/openssl
>
> #一般上面命令都会失败报错：Can‘t locate IPC/Cmd.pm in xxx
>
>  
>
> yum install -y perl-CPAN
>
> perl -MCPAN -e shell
>
> #进入后第一步选yes，第二步选manual，第三步选yes，出现 cpan[1]> 就可以了
>
> 
>
> install IPC/Cmd.pm
>
> 
>
> #按Ctrl+D退出cpan，重新执行./Configure --prefix=/usr/local/openssl
>
> ./Configure --prefix=/usr/local/openssl
>
> make && make install
>
> cd /usr/local/openssl
>
> cp -rf /usr/local/openssl/lib64 /usr/local/openssl/lib



## Python3 install

> cd ~
>
> wget https://www.python.org/ftp/python/3.10.11/Python-3.10.11.tgz
>
> 
>
> tar -zxvf Python-3.10.11.tgz
>
> cd Python-3.10.11/
>
> ./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl --with-openssl-rpath=auto
>
> yum update -y
>
> yum install -y make gcc gcc-c++
>
> make -j && make install
>
> 
>
> cd /usr/local/bin/
>
> #把原有的python2改成python.bak
>
> mv /usr/bin/python /usr/bin/python.bak
>
> 
>
> 建立软链接
>
> ln -s /usr/local/bin/python3 /usr/bin/python
>
> python --version
>
> 
>
> #升级python版本之后将由默认的python指向了python3，yum不能正常使用，需要更改2个配置文件
>
> 
>
> vim /usr/bin/yum
>
> vim /usr/libexec/urlgrabber-ext-down
>
> 
>
> 2个文件都是把开头第一行的 #!/usr/bin/python =>  #!/usr/bin/python2.7



注: 如果遇到了 php 程序正在使用openssl, 新安装的openssl缺少文件导致php那边报错
看具体缺少哪个文件, 去原来的 opensslbak 文件夹里复制过来到现有的openssl对应的目录下
然后重启一下Nginx和php就行了



## pip Install 

> pip install requests urllib3 pymysql websocket websocket-client mysql-connector-python pytz python-dotenv



## USE

> python LiveChatCrawler.py



## Error

> ```shell
> 1. pip is configured with locations that require TLS/SSL
> 
> mkdir -p ~/.pip
> vim ~/.pip/pip.conf
> 
> # 修改镜像源为阿里云
> [global]
> index-url = http://mirrors.aliyun.com/pypi/simple/
> 
> [install]
> trusted-host = mirrors.aliyun.com
> ```



本文参考 [ CSDN 文章 => Caused by SSLError(“Can‘t connect to HTTPS URL because the SSL module is not available.“](https://blog.csdn.net/Yaphets_dan/article/details/129421953)

且在原基础上根据实际情况有所改动
