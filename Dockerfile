FROM php:8.2-apache

# Install system dependencies & mongodb extension
RUN apt-get update && apt-get install -y     libssl-dev     libonig-dev     libzip-dev     unzip     && pecl install mongodb     && docker-php-ext-enable mongodb

# Install other PHP extensions
RUN docker-php-ext-install pdo pdo_mysql zip

# Enable apache rewrite module
RUN a2enmod rewrite

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Copy application files
# This is done before composer install to leverage Docker layer caching
COPY . .

# Run composer install in the php directory where the correct composer.json is located
RUN composer install --working-dir=/var/www/html/php --no-dev --prefer-dist --no-interaction --optimize-autoloader

# Set permissions for uploads directory
RUN chown -R www-data:www-data /var/www/html/uploads

# Expose port 80 for the web server
EXPOSE 80