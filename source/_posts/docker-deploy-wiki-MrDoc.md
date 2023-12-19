---
title: 'Docker 私有化部署 wiki-MrDoc'
date: 2023-12-19 11:52:09
categories: 
- Docker
- wiki

---



为完善公司内部技术人员沟通以及共享信息文档, 使用wiki工具是很有必要的, 私有化部署可以避免信息外泄, **MrDoc** 是一款很不错的wiki工具, 有开源版以及功能更全的专业版



👉[Gitee 地址](https://gitee.com/zmister/MrDoc)

👉[MrDoc 官方文档](https://doc.mrdoc.pro/doc/3958/)



<!--more-->



```shell
cd /www/wwwroot

# close下来时顺便定义项目名称为wiki-Mrdoc
git clone https://gitee.com/zmister/MrDoc.git wiki-Mrdoc

# pull镜像
docker pull zmister/mrdoc:v7

# 注意修改挂载的项目目录为/www/wwwroot/wiki-Mrdoc
docker run -d --name mrdoc -p 10086:10086 -v /www/wwwroot/wiki-Mrdoc:/app/MrDoc zmister/mrdoc:v7

# 创建用户
docker exec -it mrdoc python manage.py createsuperuser
```



```nginx
# 配置反向代理

server {
    listen 80;
    server_name wiki.chuchu-z.com;

    # 托管静态文件资源
    location ^~ /static/ {
      alias /www/wwwroot/wiki-Mrdoc/static/;
    }
    
    # 配置反向代理
    location / {
        proxy_pass http://127.0.0.1:10086;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST $remote_addr;
        proxy_set_header  X-Forwarded-Proto  $scheme;
        #Set Nginx Cache
        add_header Cache-Control no-cache;
        add_header X-Cache $upstream_cache_status;
        proxy_ignore_headers Set-Cookie Cache-Control expires;
        proxy_read_timeout 300;
    }
}

```

