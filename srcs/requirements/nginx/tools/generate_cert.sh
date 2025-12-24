#!/bin/sh
set -e

# Create directories if missing
mkdir -p /etc/nginx/ssl

# Generate a self-signed certificate
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/cert.key \
  -out /etc/nginx/ssl/cert.crt \
  -subj "/CN=${DOMAINE_NAME}"

exec "$@"

