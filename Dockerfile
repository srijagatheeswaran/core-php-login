# Stage 1: Composer - install PHP dependencies
FROM composer:2 as composer_stage

WORKDIR /app/php
COPY php/composer.json php/composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Stage 2: Apache + PHP runtime
FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    curl \
    libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql zip gd \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis

RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .
COPY edit-profile.html ./
COPY index.html ./
COPY profile.html ./
COPY register.html ./
COPY assets/ ./assets/
COPY css/ ./css/
COPY js/ ./js/
COPY php/ ./php/
COPY uploads/ ./uploads/

COPY --from=composer_stage /app/php/vendor/ /var/www/html/php/vendor/

RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads

EXPOSE 80
