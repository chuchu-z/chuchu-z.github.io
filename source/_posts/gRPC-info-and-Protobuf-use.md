---
title: gRPC的简介与Protobuf的使用
date: 2023-2-14 03:36:50
tags: 其他
categories: 其他

---



# gRPC的简介与Protobuf的使用

> **[gRPC](https://grpc.io/docs/)**实现微服务，将大的项目拆分为多个小且独立的业务模块；即服务；各服务之间使用高效的**Protobuf**协议进行RPC调用。
>
> [**Protobuf**](https://developers.google.com/protocol-buffers/docs/overview) 实际是一套类似**Json或者XML**的数据传输格式和规范，用于不同应用或进程之间进行通信时使用。通信时所传递的信息是通过**Protobuf定义的message数据结构**进行打包，然后编译成**二进制**的码流再进行传输或者存储。
>
> gRPC开发的核心文件是***.proto**文件 ，它定义了gRPC服务和消息的约定。根据这个文件，gRPC框架可以通过**protoc 工具**生成服务基类，消息和完整的客户端代码, 支持 **C++、Java、Go、Python、Ruby、C#、Node.js、Android Java、Objective-C、PHP**等多种编程语言。
>
> **protoc** 是用于将**proto文件**编程成各种语言源码文件的工具。



## PHP使用gRPC

### 安装扩展

在**PHP**中使用**gRPC**需要先安装**[gRPC扩展](http://pecl.php.net/package/gRPC)**和[**protobuf扩展**](http://pecl.php.net/package/protobuf)

```shell
# 使用pecl安装

# 查看pecl版本
pecl version 

#如果没有安装 pecl
# php版本 > 7
wget http://pear.php.net/go-pear.phar
php go-pear.phar

# php版本 < 7
yum install php-pear
#否则会报错PHP Parse error:  syntax error, unexpected //'new' (T_NEW) in /usr/share/pear/PEAR/Frontend.php on //line 91

# 查看版本
/usr/local/php/bin/pear version

# 使用pecl安装grpc和protobuf
/usr/local/php/bin/pecl install grpc
/usr/local/php/bin/pecl install protobuf

# 写入到php.ini配置(重启php生效)
echo "extension=grpc.so" >> /usr/local/php/etc/php.ini
echo "extension=protobuf.so" >> /usr/local/php/etc/php.ini

php -m | grep grpc
php -m | grep protobuf
```



### 安装protoc工具

下载 **[protoc源码](https://github.com/protocolbuffers/protobuf/releases)**  具体版本要选择与**proto文件**中定义一致, 否则报错无法解析**proto文件**, 目前我们使用的是**proto3**,  所以我当前使用的**protoc**工具是[3.10.1版本](https://github.com/protocolbuffers/protobuf/releases/tag/v3.10.1)

```shell
# 先安装协议缓存编译器(否则解析proto文件生成对应代码时会乱码)
yum install protobuf-compiler libtool libsysfs

# 解压
tar -xvf protobuf-3.10.1.tar.gz

# 编译安装
cd protobuf-3.10.1
./autogen.sh
./configure

# 如果报错 configure: WARNING: no configuration information is in third_party/googletest
# 需要下载googletest，下载地址:https://github.com/google/googletest/releases
# 直接解压并重命名googletest,放在 protobuf-3.10.1/third_party/googletest，然后重新执行./autogen.sh之后的

make
make install

# 查看protoc版本
protoc --version
```



### 使用protoc工具

使用protoc工具, 生成PHP代码文件

```shell
# 执行命令
protoc --php_out=out_dir file.proto

# --php_out 表示生成PHP代码格式
# out_dir 生成代码要存放的路径
# file.proto 要编译的proto文件
```

示例:

![protoc工具生成php代码1](http://42.193.238.253:18888/p/file/get_file/f91a56d9cea146efa2bd31cb3e807d8e.png) 

![protoc工具生成php代码2](http://42.193.238.253:18888/p/file/get_file/257d88446cac4982a7338bb6978ce117.png) 



### aexlib（工作目录）中调用gRPC

生成的代码放到**aexlib/Lib/Plugin/** 目录下, 新建一个**Api.php**和**Client.php**, 编写具体的业务逻辑, 并在**aexlib/Lib/Model/**下新建**model**, **model**内调用**Api.php**具体方法

