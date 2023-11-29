---
title: '使用Docker安装hyperf-admin'
date: 2023-11-29 13:41:37
tags: 
- Docker
- hyperf
categories:
- Docker
- hyperf

---



近期有项目用到 [**hyperf-admin**](https://github.com/hyperf-admin/hyperf-admin), 顺便学习记录一下基于官方的镜像开始构建到部署过程 

👉 [hyperf官方地址](https://hyperf.wiki/2.0/#/zh-cn/quick-start/install)

<!--more-->



## 安装&配置

由于官方默认是在Linux执行的, 但实际我是在Win10下的 git-bash 终端执行, 所以命令稍微有点不一样, 比如指定项目路径的方式和不需要指定终端为 **/bin/sh**

```bash
# 官方镜像
winpty docker run -v "D:\phpstudy\WWW\online-chat:/hyperf" -p 9501:9501 -it hyperf/hyperf:7.4-alpine-v3.11-swoole

# 官方镜像重制后的镜像
winpty docker run -v "D:\phpstudy\WWW\online-chat:/hyperf" -p 9501:9501 -it my-hyperf:latest bash
```



执行完后进入容器内执行

```bash
#安装应用
apk add vim wget tzdata

#修改时区为上海东八区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone

#输出时间查看
date

#修改配置文件
vim ~/.bashrc

#修改PS1
export PS1='\[\033]0;Bash\007\]\n\[\033[32;1m\] ➜ \[\033[33;1m\]\W\[\033[34;1m\] [\t] \[\033[36m\]'

#添加alias
alias e='exit'
alias www='cd /hyperf'
alias ll='ls -al'
alias vp='vim ~/.bashrc'
alias sp='source ~/.bashrc'

#保存后执行
source ~/.bashrc
```



由于 Docker 容器默认是以非交互式且不登录的情况进入容器的, 我们需要以交互式的情况进入

```bash
# 以 sh 方式启动 则需要在后面添加 -il 参数, 表示以交互式并且模拟登录的情况进入容器, 只有模拟登陆才会初始化执行 ~/.bashrc
winpty docker exec -it e61fb6c63c38 sh -il

# 以 bash 方式启动, 会默认初始化执行 ~/.bashrc文件
winpty docker exec -it e61fb6c63c38 bash
```



## 启动hyperf

```bash
# 进入hyperf目录
cd /hyperf

# 将 Composer 镜像设置为阿里云镜像，加速国内下载速度
composer config -g repo.packagist composer https://mirrors.aliyun.com/composer

# 由于项目已经从github拉取下来 所以无需执行安装hyperf命令, 只需要执行composer update 获取依赖
composer update

# 启动 Hyperf
php bin/hyperf.php start

# 浏览器输入http://127.0.0.1:9501访问
http://127.0.0.1:9501
```



## Linux shell 配置文件关系表

附带上文为什么修改 `~/.bashrc` 原因, 因为想要在容器内定义一些alias命令, 而容器默认是非登录进入的, 所以说明一下初始化时读取的是哪个配置文件

| 文件              | 位置                 | 作用和描述                                                   |
| ----------------- | -------------------- | ------------------------------------------------------------ |
| `~/.profile`      | 用户主目录 (`$HOME`) | 用户登录时执行的个人配置文件。通常在登录时执行一次，用于设置用户环境变量和执行用户的个人配置。 |
| `~/.bashrc`       | 用户主目录 (`$HOME`) | 非登录的 Bash shell 启动时执行的个人配置文件。用于设置 Bash shell 的特定配置，如别名、自定义函数等。 |
| `~/.bash_profile` | 用户主目录 (`$HOME`) | 用户登录时执行的个人配置文件。如果存在该文件，则通常会覆盖 `~/.profile`。用于设置用户环境变量和执行用户的个人配置。 |
| `/etc/profile`    | `/etc/` 目录         | 系统级别的 Bash shell 配置文件。在系统启动时，用于设置全局环境变量和执行系统范围的配置。用户登录时也会执行一次。 |



## 把容器制作为镜像并导出为tar

为了把修改过的容器方便在其他机器上使用, 打包制作成镜像

```bash
#容器制作为镜像
docker commit e61fb6c63c38 my-hyperf

#镜像导出为tar文件
docker save -o my-hyperf-image.tar my-hyperf
```



## 制作docker-compose.yml启动

为了省去配置命令的麻烦和方便后续扩展, 添加docker-compose.yml文件

```yaml
version: '3'

x-project-settings: &project-settings
  project_name: hyperf-app

services:
  hyperf-app:
    image: my-hyperf:latest
    container_name: my-hyperf
    ports:
      - "9501:9501"
      - "9502:9502"
      - "9503:9503"
    volumes:
      - D:\phpstudy\WWW\online-chat:/hyperf
    working_dir: /hyperf/hyperf
    command: ["php", "bin/hyperf.php", "start"]
```



接下来就是 ~~原神⭕🗽~~ hyperf, 启动！

```bash
docker-compose up -d
```



## DB与redis连接配置

1. 修改.env配置, 连接宿主机mysql, 先在宿主机执行 **ipconfig**  查看 **WSL** 的IPv4地址, 比如我的是172.21.240.1, 则 env配置文件的**DB_HOST**填写的就是**172.21.240.1**

![](use-Docker-install-hyperf\image-20231129091510911.png)

2. 如果mysql拒绝连接, 则修改一下mysql的用户授权

```sql
#用户授权,记得换成对应的库名和用户名及密码
GRANT ALL PRIVILEGES ON your_database.* TO 'your_username'@'%' IDENTIFIED BY 'your_password';

#刷新权限
FLUSH PRIVILEGES;
```



2. **redis**连接宿主机同上, 记得确保 Redis 服务器的配置允许远程连接, 修改**redis.conf**

```bash
#只允许本地和 172.21.240.1 连接
bind 127.0.0.1 172.21.240.1

#允许任何ip连接, 不推荐,特别是在生产服务器上或者没设置密码的
bind 0.0.0.0
```



## server配置

在config/autoload/server.php的 **server**配置如下, 端口具体根据实际情况修改

```php
    'servers' => [
        [
            'name' => 'http',
            'type' => Server::SERVER_HTTP,
            'host' => '0.0.0.0',
            'port' => 9502,
            'sock_type' => SWOOLE_SOCK_TCP,
            'callbacks' => [
                Event::ON_REQUEST => [Hyperf\HttpServer\Server::class, 'onRequest'],
            ],
        ],
        [
            'name' => 'ws',
            'type' => Server::SERVER_WEBSOCKET,
            'host' => '0.0.0.0',
            'port' => 9503,
            'sock_type' => SWOOLE_SOCK_TCP,
            'callbacks' => [
                Event::ON_HAND_SHAKE => [Hyperf\WebSocketServer\Server::class, 'onHandShake'],
                Event::ON_MESSAGE => [Hyperf\WebSocketServer\Server::class, 'onMessage'],
                Event::ON_CLOSE => [Hyperf\WebSocketServer\Server::class, 'onClose'],
            ],
        ],
    ],
```



## VUE

### 安装

```
# 环境依赖
# 1.  node ^v11.2.0 https://nodejs.org/zh-cn/download/
# 2.  npm ^6.4.1
git clone https://github.com/hyperf-admin/hyperf-admin-frontend.git vue-admin
cd vue-admin
npm i
npm run dev
```



```
# 打包
npm run build:prod
npm run build:test
```



### vue.config.js配置

主要留意 **module.exports** 模块里的 **devServer** 和 **proxy** 配置要和hyperf对应上

```vue
module.exports = {
  /**
   * You will need to set publicPath if you plan to deploy your site under a sub path,
   * for example GitHub Pages. If you plan to deploy your site to https://foo.github.io/bar/,
   * then publicPath should be set to "/bar/".
   * In most cases please use '/' !!!
   * Detail: https://cli.vuejs.org/config/#publicpath
   */
  publicPath: '/',
  outputDir: 'dist',
  assetsDir: 'static',
  lintOnSave: process.env.NODE_ENV === 'development',
  productionSourceMap: false,
  devServer: {
    port: port,
    open: true,
    overlay: {
      warnings: false,
      errors: true
    },
    proxy: {
      '/api': {
        target: 'http://127.0.0.1:9502',  // 后台接口地址
        ws: 'ws://127.0.0.1:9503',        //如果要代理 websockets，配置这个参数
        secure: false,  // 如果是https接口，需要配置这个参数
        changeOrigin: true,  //是否跨域
        pathRewrite:{	// 重写路径
          '^/api':''
        }
      }
    },
    // before: require('./mock/mock-server.js')
  },
  ...
```



### 生产环境

留意 **.env.production**文件配置的 **VUE_APP_BASE_API** 域名改为线上域名
