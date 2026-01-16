FROM php:8.2-fpm

ARG USER_ID
ARG GROUP_ID

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    libonig-dev \
    openssl \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Install extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install mbstring pdo_mysql pcntl zip opcache

# Install Redis
RUN pecl install redis && docker-php-ext-enable redis

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add user for laravel application
RUN groupadd -g $GROUP_ID www
RUN useradd -u $USER_ID -ms /bin/bash -g www www

WORKDIR /var/www

USER www

EXPOSE 9000