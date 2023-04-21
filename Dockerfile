FROM openresty/openresty:alpine-fat

RUN luarocks install lua-resty-session

RUN apk add --no-cache docker-cli

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/
