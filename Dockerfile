ARG php_version="7.4"
ARG wintercms_version="dev-develop"

FROM php:${php_version}-apache
LABEL maintainer="Daniel A. Hawton <daniel@hawton.org>"

RUN a2enmod expires rewrite

# Install CMS dependencies
RUN apt update && apt install -y --no-install-recommends \
    unzip libfreetype6-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libyaml-dev libzip4 \
    libzip-dev zlib1g-dev libicu-dev libpq-dev libsqlite3-dev g++ git cron nano ssh-client && \
    docker-php-ext-install opcache && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install pdo_pgsql && \
    rm -rf /var/lib/apt/lists/*

# Install apcu and yaml
RUN pecl install apcu && \
    pecl install yaml && \
    docker-php-ext-enable apcu yaml

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY files/ /

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["sh","-c", "cron && apache2-foreground"]