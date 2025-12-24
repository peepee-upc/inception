#!/bin/bash

set -e

until mysqladmin ping -h mariadb -u $SQL_USER -p"$SQL_PASSWORD" --silent; do
    echo "waiting for mariadb..."
    sleep 2
done



if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    
    wp core download --allow-root
    
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root
    
    wp core install \
        --url=$DOMAINE_NAME \
        --title=$SITE_TITLE \
        --admin_user=$ADMIN_USER \
        --admin_password=$ADMIN_PASSWORD \
        --admin_email=$ADMIN_EMAIL \
        --allow-root
    wp user create \
            $SQL_USER \
            $SQL_USER@$DOMAINE_NAME \
        --user_pass=$SQL_PASSWORD \
        --role=author \
        --allow-root
fi

echo "WordPress started on port 9000"
exec /usr/sbin/php-fpm7.4 -F