FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget curl php7.4 php7.4-fpm php7.4-mysql mariadb-client unzip less procps \
    && apt-get clean
RUN apt install 
# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info

# PHP-FPM config: listen on all interfaces port 9000
RUN sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

WORKDIR /var/www/html

COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh
# Create the run directory for PHP-FPM
RUN mkdir -p /run/php

ENTRYPOINT ["/usr/local/bin/setup.sh"]
