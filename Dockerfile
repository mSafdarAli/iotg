FROM php:8.1-fpm-alpine

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN set -ex \
    	&& apk --no-cache add nodejs libzip-dev libpng-dev yarn npm\
    	&& docker-php-ext-install zip bcmath pdo gd pdo_mysql

WORKDIR /var/www/html