FROM node:14 AS builder

WORKDIR /app

COPY . .

RUN npm install --no-fund && npx hexo clean && npx hexo generate

FROM nginx:alpine

WORKDIR /usr/share/nginx/html

COPY --from=builder /app/public /usr/share/nginx/html

EXPOSE 80
