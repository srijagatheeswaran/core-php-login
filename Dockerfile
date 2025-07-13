# Stage 1: Install PHP dependencies with Composer
FROM composer:2 AS composer_stage

WORKDIR /app

# Only copy composer files
COPY composer.json composer.lock ./

# Install dependencies
# RUN composer install --no-dev --optimize-autoloader

# Stage 2: Final PHP-Apache image
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libssl-dev \
    curl \
    && docker-php-ext-install pdo pdo_mysql zip gd \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis \
    && a2enmod rewrite

WORKDIR /var/www/html

# Copy all your project files into the container
COPY . .

# Copy vendor folder from composer stage
COPY --from=composer_stage /app/vendor/ /var/www/html/php/vendor/

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads

EXPOSE 80
