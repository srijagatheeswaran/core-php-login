# Stage 1: Composer dependencies install
FROM composer:2 as composer_stage

WORKDIR /app

# Copy only composer files
COPY composer.json composer.lock ./

# Install dependencies (no dev)
RUN composer install --no-dev --optimize-autoloader

# Stage 2: Build the full PHP + Apache image
FROM php:8.1-apache

# System dependencies
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

# PHP extensions
RUN pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis

RUN docker-php-ext-install pdo pdo_mysql zip gd

# Enable Apache Rewrite
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy app source
COPY . .

# Copy composer vendor folder from previous stage
COPY --from=composer_stage /app/vendor ./vendor

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads
