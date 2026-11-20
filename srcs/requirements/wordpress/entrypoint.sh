#!/bin/sh

set -e

i=0
until mariadb-admin -h "${WORDPRESS_DB_HOST}" ping >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 30 ]; then
        echo "MariaDB is not reachable after 30 attempts" >&2
        exit 1
    fi
    sleep 1
done

# 2) Create wp-config.php if missing
if [ ! -f "/var/www/html/wp-config.php" ]; then
    wp config create \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --allow-root
fi

# 3) Install WordPress if not installed
if ! wp core is-installed --path=/var/www/html --allow-root; then
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --path=/var/www/html \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

# Give file ownership to the PHP-FPM worker user
chown -R www-data:www-data /var/www/html

# 4) Start PHP-FPM as PID 1
exec php-fpm8.2 -F