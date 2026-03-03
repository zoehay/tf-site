FROM nginx:1.28.2-alpine

RUN curl -sSL https://ssl-config.mozilla.org/ffdhe2048.txt -o /etc/ssl/dhparam.pem
COPY ./www /var/www

# ARG CONFIG_FILE
# COPY ../etc/nginx/${CONFIG_FILE}.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]