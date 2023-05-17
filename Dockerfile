FROM node:14

WORKDIR /app

RUN npm install -g hexo-cli --no-fund

CMD ["npm", "start"]

