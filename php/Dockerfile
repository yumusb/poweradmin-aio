FROM php:8.1-fpm-alpine
RUN apk update && apk add icu icu-dev gettext-dev && docker-php-ext-install gettext mysqli pdo pdo_mysql intl
