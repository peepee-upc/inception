FROM debian:bullseye

RUN apt-get update && apt-get install -y nginx openssl && apt-get clean

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

COPY --chmod=770 tools/generate_cert.sh /usr/local/bin/generate_cert.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/generate_cert.sh"]

CMD ["nginx", "-g", "daemon off;"]
