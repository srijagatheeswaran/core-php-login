# Stage 1: Composer dependencies
FROM composer:latest AS composer

# Stage 2: Application image
FROM php:8.2-apache

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql zip

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy composer files and install dependencies
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-scripts --prefer-dist --no-interaction --verbose

# Copy application files
COPY . .

# Set permissions for uploads directory
RUN chown -R www-data:www-data /var/www/html/uploads

# Expose port 80
EXPOSE 80
