
# ==========================================
# Stage 1: Build Frontend Assets
# ==========================================
FROM node:22-alpine AS frontend

WORKDIR /var/www/html

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build


# ==========================================
# Stage 2: Laravel PHP Production
# ==========================================
FROM php:8.4-fpm AS production

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libicu-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    default-mysql-client \
    && docker-php-ext-configure gd \
       --with-freetype \
       --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
       pdo_mysql \
       mbstring \
       bcmath \
       exif \
       pcntl \
       gd \
       zip \
       intl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader

COPY --from=frontend /var/www/html/public/build ./public/build

RUN mkdir -p storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache

EXPOSE 9000

CMD ["php-fpm"]
