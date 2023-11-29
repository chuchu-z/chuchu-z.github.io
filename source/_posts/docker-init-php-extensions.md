---
title: 'Docker环境初始化及安装php扩展'
date: 2021-12-30 14:53:42
categories: Docker
---



> 这只是一段操作命令的过程, 没有任何值得学习的地方...😁

<!--more-->

```bash
yum -y install vim
vim /root/.bashrc

# 设置alias
alias e='exit'
alias www='cd /home/www/task_server'

# 写入设置utf8编码,否则乱码,设置好后先保存退出,并执行source /root/.bashrc生效,再设置PS1变量
export LANG="en_US.utf8"

# 设置完编码后这里先退出保存一次,先让编码生效, 然后再打开编辑
source /root/.bashrc

# 设置PS1变量
export PS1="\[\033]0;Docker\007\]\n\[\033[32;1m\] ➜ \[\033[33;1m\]\W\[\033[34;1m\] [\t]\[\033[31m\]\[\033[36m\] "

# 保存退出
source /root/.bashrc

# 新框架资产中心需要用到GRPC, Docker环境下安装GRPC

# 查看版本
pecl version 

#如果没有安装 pecl

# php版本 > 7
wget http://pear.php.net/go-pear.phar
php go-pear.phar

# php版本 < 7
yum install php-pear
#否则会报错PHP Parse error:  syntax error, unexpected //'new' (T_NEW) in /usr/share/pear/PEAR/Frontend.php on //line 91

# 安装 grpc
pecl install grpc

# 因为pecl没有加入PATH变量, 如果默认pecl PHP版本小于7.0 则可以使用一下路径方式或者把/usr/local/php/bin/加入PATH变量
/usr/local/php/bin/pecl install protobuf
/usr/local/php/bin/pecl install grpc
/usr/local/php/bin/pecl install apcu

# GCC版本4.8编译报错, 升级版本到gcc 7.3
yum -y install centos-release-scl
yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
scl enable devtoolset-7 bash

echo "source /opt/rh/devtoolset-7/enable" >>/etc/profile

# ssh证书问题 如果没有openssl文件夹先创建
wget http://curl.haxx.se/ca/cacert.pem && mv cacert.pem /usr/local/openssl/cert.pem

# 写入配置
echo "extension=grpc.so" >> /usr/local/php/etc/php.ini
echo "extension=protobuf.so" >> /usr/local/php/etc/php.ini
echo "extension=apcu.so" >> /usr/local/php/etc/php.ini

#重启Docker
```



### Docker 启动报错

```bash
Docker.Core.Backend.BackendException:
Error response from daemon: open \\.\pipe\docker_engine_linux: The system cannot find the file specified.
```

**在win10 管理员身份打开cmd命令行提示符执行:**

```bash
Net stop com.docker.service
Net start com.docker.service
```



### 以往安装时执行过的命令参考

```bash
1   vp
2   php -m
3   e
4   logout
5   exit
6   exit
7   yum -y install vim
8   vim /root/.bashrc
9   source /root/.bashrc
10  vim /root/.bashrc
11  source /root/.bashrc
12  pecl version 
13  wget http://pear.php.net/go-pear.phar
14  php go-pear.phar
15  wget http://pear.php.net/go-pear.phar
16  php go-pear.phar
17  yum install php-pear
18  pecl install grpc
19  /usr/local/php/bin/pecl install protobuf
20  /usr/local/php/bin/pecl install protobuf
21  /usr/local/php/bin/pecl install grpc
22  yum install php70w-devel
23  /usr/bin/phpize
24  which phpize
25  /usr/bin/phpize
26  yum install php-devel 
27  php -v
28  yum install php70w-devel 
29  /usr/bin/phpize
30  which php
31  cd /usr/local/bin/php
32  pwd
33  ll
34  /usr/local/php/bin/pecl install protobuf
35  /usr/local/php/bin/pecl install grpc
36  gcc --version
37  g++ --version
38  yum -y install centos-release-scl
39  yum -y install devtoolset-6-gcc devtoolset-6-gcc-c++ devtoolset-6-binutils
40  scl enable devtoolset-6 bash
41  yum install centos-release-scl scl-utils-build
42  yum list all --enablerepo='centos-sclo-rh'
43  yum install devtoolset-4-gcc.x86_64 devtoolset-4-gcc-c++.x86_64 devtoolset-4-gcc-gdb-plugin.x86_64 
44  scl --list 或 scl -l
45  scl --list
46  gcc -v
47  php -m
48  e
49  /usr/local/php/bin/pecl install protobuf
50  /usr/local/php/bin/pecl channel-update pecl.php.net
51  /usr/local/php/bin/pecl install protobuf
52  e
53  pecl version 
54  wget http://pear.php.net/go-pear.phar
55  php go-pear.phar
56  vim /etc/profile
57  vim ~/.bashrc 
58  vim ~/.bashrc 
59  source ~/.bashrc
60  gcc --version
61  g++ --version
62  /usr/local/php/bin/pecl install protobuf
63  wget http://curl.haxx.se/ca/cacert.pem && mv cacert.pem /usr/local/openssl/cert.pem
64  ll
65  /usr/local/php/bin/pecl install protobuf
66  /usr/local/php/bin/pecl install grpc
67  /usr/local/php/bin/pecl install grpc
68  /usr/local/php/bin/pecl install apcu
69  /usr/local/php/bin/pecl install apcu
70  wget http://curl.haxx.se/ca/cacert.pem && mv cacert.pem /usr/local/openssl/cert.pem
71  ll
72  cd /usr/local/openssl
73  cd /usr/local/
74  mkdir openssl
75  cd -
76  mv cacert.pem /usr/local/openssl/cert.pem
77  /usr/local/php/bin/pecl install apcu
78  vim /usr/local/php/etc/php.ini
79  e
80  pecl install grpc
81  pecl channel-update pecl.php.net
82  pecl install grpc
83  yum -y install centos-release-scl
84  yum -y install devtoolset-7-gcc devtoolset-7-gcc-c++ devtoolset-7-binutils
85  scl enable devtoolset-7 bash
86  e
87  www
88  php tinyBell.php
89  php tinyBell.php start
90  php tinyBell.php start
91  pwd
92  e
```

