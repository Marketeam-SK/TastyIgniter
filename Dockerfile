# Zmena na PHP 8.3
FROM php:8.3-apache

# Inštalácia systémových závislostí vrátane libicu-dev pre intl
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    libzip-dev \
    unzip \
    git \
    libicu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install gd pdo pdo_mysql zip bcmath intl \
    && docker-php-ext-enable intl

# Zapnutie Apache mod_rewrite
RUN a2enmod rewrite

# Nastavenie pracovného adresára
WORKDIR /var/www/html
COPY . .

# Inštalácia Composeru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Spustenie inštalácie závislostí
# Pridal som --ignore-platform-reqs pre istotu, ak by Railway build environment hlásil drobné nezhody
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=php

# Nastavenie práv
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Zmena portu na 8080 pre Railway
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

EXPOSE 8080
