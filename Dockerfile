FROM openresty/openresty:1.21.4.1-0-jammy

RUN luarocks install lua-resty-session
#RUN luarocks install shell-games

RUN apt install -y fcgiwrap

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/
