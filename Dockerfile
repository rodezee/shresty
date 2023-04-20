FROM openresty/openresty:alpine-fat

RUN luarocks install lua-resty-session
#RUN luarocks install shell-games

RUN apk add --no-cache fcgiwrap

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/
