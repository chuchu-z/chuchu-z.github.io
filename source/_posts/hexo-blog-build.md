---
title: '[记录] Hexo-Blog Docker搭建本地环境与持续集成'
date: 2023-5-22 17:59:58
tags: 
- Docker
- Hexo
categories: 
- Docker
- Hexo

---



# Hexo-Blog (indigo-hexo6)

该博客使用了 [GitHub Pages](https://docs.github.com/zh/pages/quickstart) +  [Hexo](https://hexo.io/zh-cn/)  + [indigo-hexo6 主题](https://github.com/chuchu-z/hexo-theme-indigo) 搭建

`GitHub Pages` 允许我们 创建以自己用户名开头的`username.github.io`仓库用来搭建自己的静态页面网站或者博客

而 `Hexo` 本身就是一款支持 Markdown 静态化博客框架 有多种主题可供选择 并且上手简单 刚好契合我的需求

<!--more-->

另外为了解决平时在写好文章想先本地预览

但是又不在自己电脑旁边或者使用公司电脑的时候要重新安装部署一遍 `nodejs ` 和 `hexo` 这些东西

所以增加了`docker`来解决环境的问题

使用 `Dockerfile` + `docker-compose` 文件

### Dockerfile

```dockerfile
FROM node:14 AS builder

WORKDIR /app

COPY . .

RUN npm install --no-fund && npx hexo clean && npx hexo generate

FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/public /usr/share/nginx/html

EXPOSE 80

```

### docker-compose

```
version: '3'
services:
  hexo:
    build:
      context: .
      dockerfile: Dockerfile
    image: chuchuzz426/blog-hexo:1.0
    ports:
      - "80:80"

```



如此 `git clone` 下来的时候 能立马部署出一套本地环境

使用简单, 开袋即食😋

```
# 拉取src分支源码
git clone -b src git@github.com:chuchu-z/chuchu-z.github.io.git

# 在项目目录执行
docker-compose up -d
```

### 然后就可以打开 http://localhost/ 预览啦✨



# 持续集成自动部署

为了发布文章`push` 到 `src` 分支后能自动更新到博客, 使用了 `GitHub Actions` 来实现自动部署

通过使用 `GitHub Actions`，我们可以实现自动化的软件开发流程，提高开发效率和代码质量

它还可以帮助团队协同工作，确保代码的集成和部署过程更加可靠和一致

```yml
# Action 的名字
name: Hexo Auto Deploy

on:
  # 触发条件1：src 分支收到 push 后执行任务。
  push:
    branches:
      - src
  # 触发条件2：手动按钮
  workflow_dispatch:

# 这里放环境变量,需要替换成你自己的
env:
  # Hexo 编译后使用此 git 用户部署到 github 仓库
  GIT_USER: chuchu-z
  # Hexo 编译后使用此 git 邮箱部署到 github 仓库
  GIT_EMAIL: chuchuzz426@gmail.com
  # Hexo 编译后要部署的 github 仓库
  GIT_DEPLOY_REPO: chuchu-z/chuchu-z.github.io
  # Hexo 编译后要部署到的分支
  GIT_DEPLOY_BRANCH: master

jobs:
  build:
    name: Build on node ${{ matrix.node_version }} and ${{ matrix.os }}
    runs-on: ubuntu-latest
    if: github.event.repository.owner.id == github.event.sender.id
    strategy:
      matrix:
        os: [ubuntu-latest]
        node_version: [14]

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Checkout deploy repo
        uses: actions/checkout@v2
        with:
          repository: ${{ env.GIT_DEPLOY_REPO }}
          ref: ${{ env.GIT_DEPLOY_BRANCH }}
          path: .deploy_git

      - name: Use Node.js ${{ matrix.node_version }}
        uses: actions/setup-node@v1
        with:
          node-version: ${{ matrix.node_version }}

      - name: Configuration environment
        env:
          HEXO_DEPLOY_PRI: ${{secrets.HEXO_DEPLOY_PRI}}
        run: |
          sudo timedatectl set-timezone "Asia/Shanghai"
          mkdir -p ~/.ssh/
          echo "$HEXO_DEPLOY_PRI" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
          ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts
          # coding 已取消同步
          ssh-keyscan -t rsa e.coding.net >> ~/.ssh/known_hosts
          ssh-keyscan -t rsa gitee.com >> ~/.ssh/known_hosts
          git config --global user.name $GIT_USER
          git config --global user.email $GIT_EMAIL

      - name: Install dependencies
        run: npm install --no-fund

      - name: Deploy hexo
        run: |
          npm run deploy
```

触发条件为每当有`push` 代码的时候将自动按照`.github/workflows/deploy.yml`下的配置文件构造部署环境

相当于帮我们执行了 `hexo generate` 和 `hexo deploy` 然后`hexo deploy`会根据项目根目录下的`_config.yml`配置文件

把编译好的静态文件更新到以自己用户名开头的`username.github.io`仓库的 `master` 分支上

这样就完成了自动化部署啦

```yml
deploy:
  type: git
  # repo: git@github.com:chuchu-z/chuchu-z.github.io.git #构建机器上没有配置 ssh 免密,所以使用https
  repo: https://github_token@github.com/chuchu-z/chuchu-z.github.io.git
  branch: master
  message: GitHub Actions 自动部署:{{ now('YYYY-MM-DD HH:mm:ss') }}

```



## 👉 博客地址: [http://chuchu-z.com](http://chuchu-z.com)

## 👉 GitHub地址: [https://github.com/chuchu-z/chuchu-z.github.io](https://github.com/chuchu-z/chuchu-z.github.io)