FROM nginx:1.30.3-alpine

RUN apk upgrade --no-cache && \
    curl -sSL https://ssl-config.mozilla.org/ffdhe2048.txt -o /etc/ssl/dhparam.pem
COPY ./www /var/www


CMD ["nginx", "-g", "daemon off;"]