#!/bin/sh
set -e

# Start MariaDB in background
mysqld_safe &
pid="$!"

# Wait until MariaDB is ready
until mariadb-admin ping --silent; do
  echo "Waiting for MariaDB..."
  sleep 2
done

# Create database and user
mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "Database and user ready"

# Stop background MariaDB
mysqladmin -u root shutdown

exec mysqld_safe
