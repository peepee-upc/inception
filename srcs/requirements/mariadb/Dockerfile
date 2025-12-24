FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server && apt-get clean && sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY --chmod=770 tools/db_setup.sh /usr/local/bin/

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/db_setup.sh"]
