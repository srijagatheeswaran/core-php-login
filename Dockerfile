# FROM php:8.2-apache

# # Install system dependencies & required PHP extensions
# RUN apt-get update && apt-get install -y \
#     libssl-dev \
#     libonig-dev \
#     libzip-dev \
#     unzip \
#     && pecl install mongodb \
#     && docker-php-ext-enable mongodb \
#     && docker-php-ext-install pdo pdo_mysql zip mbstring sockets

# # Enable apache rewrite module
# RUN a2enmod rewrite

# # Install Composer
# COPY --from=composer /usr/bin/composer /usr/bin/composer

# # Set working directory
# WORKDIR /var/www/html

# # Copy all project files (including composer.json etc.)
# COPY . .

# # Install PHP dependencies
# RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader --ignore-platform-req=ext-mongodb

# # Set permissions for uploads directory
# RUN chown -R www-data:www-data /var/www/html/uploads

# # Expose port 80
# EXPOSE 80
FROM php:8.2-apache

# Install system dependencies & required PHP extensions
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    && pecl install mongodb-1.18.1 \
    && docker-php-ext-enable mongodb \
    && docker-php-ext-install pdo pdo_mysql zip mbstring sockets

# Enable apache rewrite module
RUN a2enmod rewrite

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy all project files
COPY . .

# Install PHP dependencies
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Set permissions
RUN chown -R www-data:www-data /var/www/html/uploads

# Expose port
EXPOSE 80
