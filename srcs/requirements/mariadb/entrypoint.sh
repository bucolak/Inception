#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &

    i=0
    until mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -ge 20 ]; then
            echo "MariaDB did not become ready after 20 attempts" >&2
            exit 1
        fi
        sleep 1
    done

    mariadb --socket=/run/mysqld/mysqld.sock -u root -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mariadb --socket=/run/mysqld/mysqld.sock -u root -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    mariadb --socket=/run/mysqld/mysqld.sock -u root -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mariadb --socket=/run/mysqld/mysqld.sock -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"

    mariadb-admin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

exec mariadbd --user=mysql --console