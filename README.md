# Hexo-Blog (indigo-hexo6)

该博客使用了 [Hexo](https://hexo.io/zh-cn/)  + [indigo-hexo6 主题](https://github.com/chuchu-z/hexo-theme-indigo) 搭建

另外为了解决平时想要在本地折腾一下博客, 但是又不在自己电脑旁边或者使用公司电脑的时候要重新安装部署一遍 `nodejs ` 和 `hexo` 这些东西

所以加上了 `Dockerfile`, 方便 `git clone` 下来的时候 能立马部署出一套本地环境, 使用简单, 开袋即食😋



```
git clone -b src git@github.com:chuchu-z/chuchu-z.github.io.git
docker-compose up -d
```

### 然后就可以打开 http://localhost/ 预览啦✨



### 👉 博客地址: [http://chuchu-z.com](http://chuchu-z.com)