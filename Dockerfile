# Stage 1: Install PHP dependencies with Composer
FROM composer:2 as composer_stage
RUN apk add --no-cache autoconf build-base
WORKDIR /app/php
# Copy only the composer files for the main application
COPY php/ ./
# Install dependencies
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Stage 2: Build the final application image
FROM php:8.1-apache

# Install system dependencies required for PHP extensions
# libssl-dev is needed for the mongodb pecl extension
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

# Install required PHP extensions
# The mongodb and redis extensions provide better performance
RUN pecl install mongodb redis \
    && docker-php-ext-enable mongodb redis

# Install other core extensions
RUN docker-php-ext-install pdo pdo_mysql zip gd

# Enable Apache's mod_rewrite for clean URLs (e.g., for routing)
RUN a2enmod rewrite

# Set the working directory to Apache's default document root
WORKDIR /var/www/html

# Copy the application source code
# We copy the specific directories and files needed by the app

COPY .env .
COPY edit-profile.html .
COPY index.html .
COPY profile.html .
COPY register.html .
COPY assets/ ./assets/
COPY css/ ./css/
COPY js/ ./js/
COPY php/ ./php/
COPY uploads/ ./uploads/

# Copy the installed dependencies from the composer stage
COPY --from=composer_stage /app/php/vendor/ /var/www/html/php/vendor/

# Set permissions
# Make the uploads directory writable by the web server
RUN chown -R www-data:www-data /var/www/html/uploads \
    && chmod -R 775 /var/www/html/uploads

# Set ownership for all application files to the web server user
RUN chown -R www-data:www-data /var/w...TRUNCATED