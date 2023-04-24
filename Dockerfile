FROM openresty/openresty:alpine-fat

RUN luarocks install lua-resty-session

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/
