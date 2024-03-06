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



## 部署

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

## 迁移到其他服务器部署

如果使用一段时间后, 需要将其部署到其他服务器

项目源代码在 **/www/wwwroot/wiki-Mrdoc** 目录下, 并且使用docker部署的

只需要将整个 **wiki-Mrdoc** 项目打包成压缩包文件, 并上传到其他服务器, 然后在新的服务器上执行部署命令

```bash
cd /www/wwwroot

# 压缩
tar -czvf wiki-Mrdoc.tar.gz wiki-Mrdoc

# 传输到新服务器
scp /www/wwwroot/wiki-Mrdoc.tar.gz root@{ip}:/www/wwwroot/
```

```bash
cd /www/wwwroot

# 解压 .tar.gz 文件
tar -xzvf wiki-Mrdoc.tar.gz

cd wiki-Mrdoc

# pull镜像(先安装docker)
docker pull zmister/mrdoc:v7

# 修改挂载的项目目录为/www/wwwroot/wiki-Mrdoc
docker run -d --name mrdoc -p 10086:10086 -v /www/wwwroot/wiki-Mrdoc:/app/MrDoc zmister/mrdoc:v7
```

然后正常配置网站站点, 配置反向代理即可
