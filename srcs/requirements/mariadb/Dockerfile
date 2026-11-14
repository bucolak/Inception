FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server \
    && rm -rf /var/lib/apt/lists/* && mkdir -p /run/mysqld \
    && chown mysql:mysql /run/mysqld

COPY entrypoint.sh /usr/local/bin/entrypoint.sh    

COPY conf/70-mariadb-config.cnf /etc/mysql/mariadb.conf.d/70-mariadb-config.cnf

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

EXPOSE 3306