FROM php:8.3-apache

# 1. Inštalácia systémových závislostí
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

# 2. RADIKÁLNE riešenie MPM konfliktu
# Vymažeme všetky načítané MPM moduly a manuálne povolíme len prefork
RUN rm -f /etc/apache2/mods-enabled/mpm_* && \
    a2enmod mpm_prefork && \
    a2enmod rewrite

# 3. Nastavenie pracovného adresára
WORKDIR /var/www/html
COPY . .

# 4. Inštalácia Composeru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=php

# 5. Oprava práv
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 6. Porty (Railway vyžaduje 8080)
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

EXPOSE 8080

# 7. Spúšťací skript, ktorý zaistí čistý štart
CMD ["apache2-foreground"]
