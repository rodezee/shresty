FROM openresty/openresty:alpine-fat

RUN luarocks install lua-resty-session
RUN luarocks install shell-games

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/
