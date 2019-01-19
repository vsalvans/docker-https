FROM php:7.1-apache
ARG domain
RUN apt-get update && \
    apt-get install -y \
        zlib1g-dev
RUN docker-php-ext-install mysqli pdo pdo_mysql zip mbstring
RUN a2enmod rewrite
RUN a2enmod ssl
COPY certs/$domain.crt /etc/apache2/ssl/$domain.crt
COPY certs/$domain.key /etc/apache2/ssl/$domain.key
COPY dev.conf /etc/apache2/sites-enabled/dev.conf
RUN sed -i.bak s/%%DOMAIN%%/"$domain"/g /etc/apache2/sites-enabled/dev.conf
RUN service apache2 restart
