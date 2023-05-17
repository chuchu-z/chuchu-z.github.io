# 使用 Node.js 镜像作为基础镜像
FROM node:14

# 设置工作目录
WORKDIR /app

# 复制项目文件到工作目录
COPY . /app

# 安装依赖并执行 hexo clean 和 hexo generate
RUN npm install hexo-cli --no-fund \
    && npm install https://github.com/xcodebuild/hexo-asset-image --save \
    && npm install --no-fund \
    && npx hexo clean \
    && npx hexo generate

# 对外暴露Hexo的默认端口
EXPOSE 4000

# 启动Hexo服务
CMD ["hexo", "clean", "&&", "hexo", "generate", "&&", "hexo", "server", "-p", "4000", "-i", "0.0.0.0"]

