FROM php:8.3-fpm

# 1. Inštalácia systémových závislostí a Nginxu
RUN apt-get update && apt-get install -y \
    nginx \
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

# 2. Konfigurácia Nginxu pre TastyIgniter (Laravel)
RUN echo 'server { \n\
    listen 8080; \n\
    root /var/www/html/public; \n\
    index index.php index.html; \n\
    location / { \n\
        try_files $uri $uri/ /index.php?$query_string; \n\
    } \n\
    location ~ \.php$ { \n\
        include fastcgi_params; \n\
        fastcgi_pass 127.0.0.1:9000; \n\
        fastcgi_index index.php; \n\
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; \n\
    } \n\
}' > /etc/nginx/sites-available/default

# 3. Nastavenie pracovného adresára
WORKDIR /var/www/html
COPY . .

# 4. Inštalácia Composeru
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader --ignore-platform-req=php

# 5. Práva a čistenie
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# 6. Spúšťací skript (musíme spustiť PHP-FPM aj Nginx súčasne)
EXPOSE 8080
CMD php-fpm -D && nginx -g "daemon off;"
