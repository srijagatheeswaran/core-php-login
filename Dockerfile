# Stage 1: Composer - install PHP dependencies
FROM composer:2 as composer_stage

# Set working directory in Composer container
WORKDIR /app/php

# Copy composer files
COPY php/composer.json php/composer.lock ./

# Install dependencies without dev for production
RUN composer install --no-dev --optimize-autoloader

# Stage 2: Apache + PHP runtime
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions (PDO MySQL, ZIP, GD, Redis, MongoDB)
RUN docker-php-ext-install pdo pdo_mysql zip gd \
    && pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory for app
WORKDIR /var/www/html

# Copy your project files
COPY . .

# Copy specific folders to ensure proper structure
COPY edit-profile.html ./
COPY index.html ./
COPY profile.html ./
COPY register.html ./
COPY assets/ ./assets/
COPY css/ ./css/
COPY js/ ./js/
COPY php/ ./php/
COPY uploads/ ./uploads/

# Copy composer-installed vendor folder from composer stage
COPY --from=composer_stage /app/php/vendor/ /var/www/html/php/vendor/

# Optional: copy the .env file (make sure it's not in .dockerignore)
COPY .env /var/www/html/php/.env

# Set proper permissions for uploads
RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads

# Expose Apache port
EXPOSE 80
