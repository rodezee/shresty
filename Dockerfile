FROM openresty/openresty:alpine-fat

RUN luarocks install lua-resty-session

ADD ./nginx.conf /usr/local/openresty/nginx/conf/
ADD app /app/

RUN wget -c https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-minirootfs-3.17.3-x86_64.tar.gz -O - | tar -xz -C /app/www/chrootfs/
RUN echo "nameserver  8.8.8.8" > /app/www/chrootfs/etc/resolv.conf
