FROM php:8.2-apache

# Inštalácia systémových závislostí
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip libzip-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql zip bcmath

# Zapnutie Apache mod_rewrite (nutné pre Laravel/TastyIgniter)
RUN a2enmod rewrite

# Nastavenie pracovného adresára
WORKDIR /var/www/html
COPY . .

# Inštalácia Composeru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Nastavenie práv (Railway vyžaduje prístup k storage)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Zmena portu Apache na 8080 (Railway štandard)
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

EXPOSE 8080
