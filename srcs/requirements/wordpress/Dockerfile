FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-xml \
    php8.2-mbstring \
    php8.2-zip \
    php8.2-intl \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html \
    && curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

COPY wp-config.php /var/www/html/wp-config.php

CMD ["php-fpm8.2", "-F"]