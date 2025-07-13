# Use the official PHP image
FROM php:8.1-apache


WORKDIR /var/www/html

# Copy all project files
COPY . .

# Expose Apache port
EXPOSE 80
