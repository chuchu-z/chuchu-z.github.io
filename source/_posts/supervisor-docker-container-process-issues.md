---
title: 'Supervisor 管理 Docker 容器内进程问题'
date: 2024-07-24 17:49:33
categories: 
- Linux
- Docker

---



**问题描述**：在测试环境中发现，宿主机的 Supervisor 进程管理工具无法有效管理 Docker 容器内由 `docker exec php7` 命令创建的 PHP 进程。这导致 Supervisor 对 Docker 容器内的 PHP 进程无法进行有效的控制和重启

**预期行为**：宿主机的 Supervisor 应能够控制 Docker 容器内由 `docker exec php7` 命令创建的 PHP 进程，包括启动、停止和重启



<!--more-->



supervisor 配置如下:

```shell
[program:laikeduo_test_rabbitmq_processor]
command=docker exec php7 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
directory=/var/www/laikeduo_test
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/www/laikeduo_test/storage/logs/laikeduo_test_rabbitmq_processor.err.log
stdout_logfile=/var/www/laikeduo_test/storage/logs/laikeduo_test_rabbitmq_processor.out.log
```

### 现象与分析

**现象**：关闭或重启Supervisor, 只会对本身的`docker exec php7`命令生效, 容器内部已经启动的进程不受影响

```shell
[root@iZwz995otwrhk15lyjqnpkZ laikeduo_test]# ps -aux | grep artisan
root     19379  0.0  0.9 1307524 16776 ?       Sl   16:47   0:00 docker exec php7 php /var/www/laikeduo_test/artisan queue:work
root     19380  0.1  0.9 1307780 16584 ?       Sl   16:47   0:00 docker exec php7 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19407  0.6  1.7  92228 30780 ?        Ss   16:47   0:00 php /var/www/laikeduo_test/artisan queue:work
www      19416  0.7  1.6  92228 30200 ?        Ss   16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19433  0.0  1.3  92228 23532 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19434  0.0  1.3  92228 23528 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19435  0.0  1.3  92228 23524 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19436  0.0  1.3  92228 23532 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
root     19441  0.0  0.0 112816   980 pts/0    R+   16:47   0:00 grep --color=auto artisan
[root@iZwz995otwrhk15lyjqnpkZ laikeduo_test]# systemctl stop supervisord
[root@iZwz995otwrhk15lyjqnpkZ laikeduo_test]# ps -aux | grep artisan
www      19407  0.3  1.7  92228 30780 ?        Ss   16:47   0:00 php /var/www/laikeduo_test/artisan queue:work
www      19416  0.3  1.6  92228 30200 ?        Ss   16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19433  0.0  1.3  92228 23532 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19434  0.0  1.3  92228 23528 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19435  0.0  1.3  92228 23524 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
www      19436  0.0  1.3  92228 23532 ?        S    16:47   0:00 php /var/www/laikeduo_test/artisan rabbitmq:process-messages
root     19451  0.0  0.0 112812   980 pts/0    R+   16:47   0:00 grep --color=auto artisan
[root@iZwz995otwrhk15lyjqnpkZ laikeduo_test]# ps -aux | grep 'artisan' | grep -v grep | awk '{print $2}' | xargs kill -9
[root@iZwz995otwrhk15lyjqnpkZ laikeduo_test]# ps -aux | grep artisan
root     19493  0.0  0.0 112812   980 pts/0    S+   16:48   0:00 grep --color=auto artisan
```

**分析**：

-   `docker exec` 命令在宿主机上启动，并不能直接控制容器内的进程。Supervisor 对 `docker exec` 命令的控制只限于启动和停止 `docker exec` 进程，而不会直接影响容器内部的进程
-   Supervisor 对宿主机上的 `docker exec` 命令进行管理，但不具备对容器内 PHP 进程的控制能力，因此无法有效管理已经在容器内启动的 PHP 进程



### 解决方案

如果容器内部已经存在过多相关的进程无法删除, 只能指定删除包含`artisan`关键词的所有进程或者直接关闭再启动php7容器



**方法 1**：直接 kill 掉包含 `artisan` 关键词的进程

```shell
ps -aux | grep 'artisan' | grep -v grep | awk '{print $2}' | xargs kill -9
```

**方法 2**：先关闭再启动 PHP 容器, 经测试, `docker-compose restart php7` 可能无效

```
docker-compose stop php7
docker-compose start php7
```



