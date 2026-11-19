#!/bin/sh

set -e

if [ ! -d "/var/www/html" ]; then
   
fi

 i=0
    until mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        i=$((i + 1))
        if [ "$i" -ge 20 ]; then
            echo "MariaDB did not become ready after 20 attempts" >&2
            exit 1
        fi
        sleep 1
    done