FROM php:8.2-apache

# Install system dependencies & required PHP extensions
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql zip mbstring sockets

# Enable apache rewrite module
RUN a2enmod rewrite

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Create the php directory for composer files
RUN mkdir -p php

# Copy only the composer files into the php directory first to leverage caching
COPY php/composer.json php/composer.lock ./php/

# Run composer install within the php directory
RUN composer install --working-dir=/var/www/html/php --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Now copy the rest of the application code
COPY . .

# Set permissions for uploads directory
RUN chown -R www-data:www-data /var/www/html/uploads

# Expose port 80 for the web server
EXPOSE 80