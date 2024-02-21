---
title: 'Dockerfile中的COPY与volume挂载冲突问题'
date: 2024-2-21 10:52:28
categories: 
- Docker
---



闲来无事, 想起之前本地构建博客想看看效果时, 老是出现文章内容丢失的问题, 后来构建时尝试加上`--no-cache`可以解决该问题, 现在又想折腾一下容器静态文件挂载到宿主机

<!--more-->

```
docker-compose build --no-cache && docker-compose up -d
```



## Dockerfile

```dockerfile
FROM node:14 AS builder

WORKDIR /app

COPY . .

RUN npm install --no-fund && npx hexo clean && npx hexo generate

FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/public /usr/share/nginx/html

EXPOSE 8080
```



## docker-compose.yml

```yaml
version: '3'
services:
  hexo:
    build:
      context: .
      dockerfile: Dockerfile
    image: chuchuzz426/blog-hexo:1.0
    ports:
      - "8080:80"
	volume:
      - ./public:/usr/share/nginx/html # 挂载会把Dockerfile中的COPY覆盖
```



## 想法

我想把 `COPY --from=builder /app/public /usr/share/nginx/html` 这一步的/usr/share/nginx/html目录下的静态资源挂载到宿主机

当时脑回路有点迷糊, 想着这样能方便查看或者在宿主机也能刷新静态资源? 但是犯傻忘了每次新的静态资源也是要先通过容器才能生成的😓, 还折腾了起来 

最后挂载没成功, 倒是遇到了个COPY与挂载的冲突问题。



## 问题

> 如果已经在 Dockerfile 中使用`COPY --from=builder /app/public /usr/share/nginx/html`将一阶段的静态文件复制到Nginx阶段，然后在运行容器时再试图使用`-v`或`--volume`在宿主机上把./public目录挂载到容器的`/usr/share/nginx/html`，会导致挂载冲突, 具体表现方式为, COPY的文件被宿主机上挂载的目录覆盖。



## 原因

> 在Docker中，一旦使用`COPY`命令将文件复制到容器中，该文件就会被视为镜像的一部分，并且在运行容器时使用`-v`或`--volume`挂载宿主机目录到这个位置时，宿主机的内容将覆盖容器中的内容，导致挂载冲突。



## 方案

#### 1. 不挂载，只使用Dockerfile中的COPY：

如果只关心构建时的操作而不需要在运行时修改文件，那么可以仅使用Dockerfile中的`COPY`命令，而不进行挂载。

```yaml
version: '3'
services:
  hexo:
    build:
      context: .
      dockerfile: Dockerfile
    image: chuchuzz426/blog-hexo:1.0
    ports:
      - "8080:80"
```

这样构建时会将静态文件复制到镜像中，但在运行时对容器的`/usr/share/nginx/html`目录将不会受到冲突。

#### 2. 分阶段处理:

之所以要分阶段处理, 是因为构建过程中, 是没办法把内部文件拷贝或挂载到宿主机的,只能等构建完成后单独处理。

Dockerfile.build

```dockerfile
# 第一阶段：构建阶段
FROM node:14 AS builder
WORKDIR /app
COPY . .
RUN npm install --no-fund && npx hexo clean && npx hexo generate

# 第二阶段：导出静态资源到临时目录
FROM alpine as export
WORKDIR /export
COPY --from=builder /app/public /export/public
```

```bash
# 运行构建
docker build -t myimage -f Dockerfile.build .

# 创建一个临时容器，从中复制文件到宿主机
docker create --name extract myimage
docker cp extract:/export/public ./public
docker rm -f extract
```

Dockerfile.run

```dockerfile
# 第三阶段：Nginx阶段
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
COPY --from=export /export/public /usr/share/nginx/html
EXPOSE 8080
```

然而这样的做法虽然能实现挂载, 但对我来说已经没有意义了



## 总结

我的初衷是新发布的文章能在本地执行编译, 然后生成的静态文件资源能够和容器中的/usr/share/nginx/html互通, 避免本地每次发布新文章都要重新构建容器很麻烦, 但是现在回头想想, 其实写完新文章不想重新构建的话直接进入容器执行`hexo g`效果也一样的, 没白折腾, 又学到了有用的知识。
