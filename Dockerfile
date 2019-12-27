#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------

FROM php:7.2-apache

ARG APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APACHE_DOCUMENT_ROOT ${APACHE_DOCUMENT_ROOT}

ARG APACHE_LOG_DIR=/var/log/apache2/
ENV APACHE_LOG_DIR ${APACHE_LOG_DIR}

ARG SUPERVISOR_WORKERS=/var/www/html/workers/*.conf
ENV SUPERVISOR_WORKERS ${SUPERVISOR_WORKERS}

#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------

# Packages
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    nano \
    zip \
    unzip \
    libmemcached-dev \
    libz-dev \
    libpq-dev \
    libssl-dev \
    libmcrypt-dev \
    libzip-dev \
    supervisor \
  && rm -rf /var/lib/apt/lists/*

# PHP extensions
RUN docker-php-ext-install \
    pdo_mysql \
    bcmath \
    zip \
    && pecl install redis && docker-php-ext-enable redis

# Composer
RUN curl -s https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

#--------------------------------------------------------------------------
# Software's Configuration
#--------------------------------------------------------------------------

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY php.ini /usr/local/etc/php/php.ini
COPY apache-site.conf /etc/apache2/sites-enabled/000-default.conf
RUN mv /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled
