# Stage 1: Install PHP dependencies with Composer
FROM composer:2 as composer_stage

WORKDIR /app

# Copy composer files from root directory
COPY composer.json composer.lock ./

# Install dependencies
#RUN composer install --no-dev --optimize-autoloader

# Stage 2: Build the final application image
FROM php:8.1-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libzip-dev \
    unzip \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    curl \
    libssl-dev \
    && docker-php-ext-install pdo pdo_mysql zip gd \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis \
    && a2enmod rewrite \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www/html

# Copy your app source code
COPY . .

# Copy installed vendor folder from composer stage
COPY --from=composer_stage /app/vendor/ /var/www/html/vendor/

# Set permissions (especially for uploads folder)
RUN chown -R www-data:www-data ./uploads && chmod -R 775 ./uploads

# Expose port 80 for Apache
EXPOSE 80
