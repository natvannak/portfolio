FROM node:22-alpine AS frontend
WORKDIR /var/www/html
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:1.28-alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --from=frontend /var/www/html/public /var/www/html/public
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
