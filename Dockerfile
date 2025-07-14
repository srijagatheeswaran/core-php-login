# Stage 1: Build dependencies using Composer
FROM composer:latest AS build

WORKDIR /app

# Copy only composer files first (cache optimization)
COPY composer.json composer.lock ./

# Install dependencies into /app/vendor
RUN composer install --no-dev --prefer-dist --no-interaction

# Stage 2: Final PHP-Apache image
FROM php:8.2-apache

# Install required system libraries and PHP extensions
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy app source code
COPY . .

# Copy vendor folder from build stage
COPY --from=build /app/vendor ./vendor

# Set correct permissions for uploads
RUN mkdir -p uploads && chown -R www-data:www-data /var/www/html/uploads

# Expose port
EXPOSE 80
