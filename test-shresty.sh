#! /bin/sh
docker-compose stop shresty
docker-compose rm -f shresty
docker-compose build
docker-compose up -d
echo -e "curl http://$(hostname -i | awk '{print $1}'):1080/exec/echo%20hello%20world'"
docker-compose logs -f shresty
